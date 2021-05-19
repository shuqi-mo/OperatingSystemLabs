
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 49 57 00 00       	call   1057ab <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 c0 5f 10 00 	movl   $0x105fc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 22 31 00 00       	call   1031b2 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 b7 16 00 00       	call   10174c <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 17 18 00 00       	call   1018b1 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 eb 0c 00 00       	call   100d8a <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 e2 17 00 00       	call   101886 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 b0 0c 00 00       	call   100d78 <mon_backtrace>
}
  1000c8:	90                   	nop
  1000c9:	c9                   	leave  
  1000ca:	c3                   	ret    

001000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cb:	55                   	push   %ebp
  1000cc:	89 e5                	mov    %esp,%ebp
  1000ce:	53                   	push   %ebx
  1000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b4 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	83 c4 14             	add    $0x14,%esp
  1000f6:	5b                   	pop    %ebx
  1000f7:	5d                   	pop    %ebp
  1000f8:	c3                   	ret    

001000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f9:	55                   	push   %ebp
  1000fa:	89 e5                	mov    %esp,%ebp
  1000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ff:	8b 45 10             	mov    0x10(%ebp),%eax
  100102:	89 44 24 04          	mov    %eax,0x4(%esp)
  100106:	8b 45 08             	mov    0x8(%ebp),%eax
  100109:	89 04 24             	mov    %eax,(%esp)
  10010c:	e8 ba ff ff ff       	call   1000cb <grade_backtrace1>
}
  100111:	90                   	nop
  100112:	c9                   	leave  
  100113:	c3                   	ret    

00100114 <grade_backtrace>:

void
grade_backtrace(void) {
  100114:	55                   	push   %ebp
  100115:	89 e5                	mov    %esp,%ebp
  100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011a:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100126:	ff 
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100132:	e8 c2 ff ff ff       	call   1000f9 <grade_backtrace0>
}
  100137:	90                   	nop
  100138:	c9                   	leave  
  100139:	c3                   	ret    

0010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013a:	55                   	push   %ebp
  10013b:	89 e5                	mov    %esp,%ebp
  10013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100150:	83 e0 03             	and    $0x3,%eax
  100153:	89 c2                	mov    %eax,%edx
  100155:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10015a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100162:	c7 04 24 e1 5f 10 00 	movl   $0x105fe1,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 ef 5f 10 00 	movl   $0x105fef,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 fd 5f 10 00 	movl   $0x105ffd,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 0b 60 10 00 	movl   $0x10600b,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 19 60 10 00 	movl   $0x106019,(%esp)
  1001e5:	e8 a8 00 00 00       	call   100292 <cprintf>
    round ++;
  1001ea:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001ef:	40                   	inc    %eax
  1001f0:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001f5:	90                   	nop
  1001f6:	c9                   	leave  
  1001f7:	c3                   	ret    

001001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f8:	55                   	push   %ebp
  1001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001fb:	90                   	nop
  1001fc:	5d                   	pop    %ebp
  1001fd:	c3                   	ret    

001001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001fe:	55                   	push   %ebp
  1001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100201:	90                   	nop
  100202:	5d                   	pop    %ebp
  100203:	c3                   	ret    

00100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100204:	55                   	push   %ebp
  100205:	89 e5                	mov    %esp,%ebp
  100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020a:	e8 2b ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10020f:	c7 04 24 28 60 10 00 	movl   $0x106028,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 48 60 10 00 	movl   $0x106048,(%esp)
  10022c:	e8 61 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_kernel();
  100231:	e8 c8 ff ff ff       	call   1001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100236:	e8 ff fe ff ff       	call   10013a <lab1_print_cur_status>
}
  10023b:	90                   	nop
  10023c:	c9                   	leave  
  10023d:	c3                   	ret    

0010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10023e:	55                   	push   %ebp
  10023f:	89 e5                	mov    %esp,%ebp
  100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100244:	8b 45 08             	mov    0x8(%ebp),%eax
  100247:	89 04 24             	mov    %eax,(%esp)
  10024a:	e8 c5 13 00 00       	call   101614 <cons_putc>
    (*cnt) ++;
  10024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100252:	8b 00                	mov    (%eax),%eax
  100254:	8d 50 01             	lea    0x1(%eax),%edx
  100257:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025a:	89 10                	mov    %edx,(%eax)
}
  10025c:	90                   	nop
  10025d:	c9                   	leave  
  10025e:	c3                   	ret    

0010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10025f:	55                   	push   %ebp
  100260:	89 e5                	mov    %esp,%ebp
  100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100273:	8b 45 08             	mov    0x8(%ebp),%eax
  100276:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100281:	c7 04 24 3e 02 10 00 	movl   $0x10023e,(%esp)
  100288:	e8 71 58 00 00       	call   105afe <vprintfmt>
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100298:	8d 45 0c             	lea    0xc(%ebp),%eax
  10029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 af ff ff ff       	call   10025f <vcprintf>
  1002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002b6:	c9                   	leave  
  1002b7:	c3                   	ret    

001002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002b8:	55                   	push   %ebp
  1002b9:	89 e5                	mov    %esp,%ebp
  1002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002be:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c1:	89 04 24             	mov    %eax,(%esp)
  1002c4:	e8 4b 13 00 00       	call   101614 <cons_putc>
}
  1002c9:	90                   	nop
  1002ca:	c9                   	leave  
  1002cb:	c3                   	ret    

001002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002cc:	55                   	push   %ebp
  1002cd:	89 e5                	mov    %esp,%ebp
  1002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002d9:	eb 13                	jmp    1002ee <cputs+0x22>
        cputch(c, &cnt);
  1002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002e6:	89 04 24             	mov    %eax,(%esp)
  1002e9:	e8 50 ff ff ff       	call   10023e <cputch>
    while ((c = *str ++) != '\0') {
  1002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f1:	8d 50 01             	lea    0x1(%eax),%edx
  1002f4:	89 55 08             	mov    %edx,0x8(%ebp)
  1002f7:	0f b6 00             	movzbl (%eax),%eax
  1002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100301:	75 d8                	jne    1002db <cputs+0xf>
    }
    cputch('\n', &cnt);
  100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100306:	89 44 24 04          	mov    %eax,0x4(%esp)
  10030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100311:	e8 28 ff ff ff       	call   10023e <cputch>
    return cnt;
  100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100319:	c9                   	leave  
  10031a:	c3                   	ret    

0010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10031b:	55                   	push   %ebp
  10031c:	89 e5                	mov    %esp,%ebp
  10031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100321:	e8 2b 13 00 00       	call   101651 <cons_getc>
  100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10032d:	74 f2                	je     100321 <getchar+0x6>
        /* do nothing */;
    return c;
  10032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100332:	c9                   	leave  
  100333:	c3                   	ret    

00100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100334:	55                   	push   %ebp
  100335:	89 e5                	mov    %esp,%ebp
  100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10033e:	74 13                	je     100353 <readline+0x1f>
        cprintf("%s", prompt);
  100340:	8b 45 08             	mov    0x8(%ebp),%eax
  100343:	89 44 24 04          	mov    %eax,0x4(%esp)
  100347:	c7 04 24 67 60 10 00 	movl   $0x106067,(%esp)
  10034e:	e8 3f ff ff ff       	call   100292 <cprintf>
    }
    int i = 0, c;
  100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10035a:	e8 bc ff ff ff       	call   10031b <getchar>
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100366:	79 07                	jns    10036f <readline+0x3b>
            return NULL;
  100368:	b8 00 00 00 00       	mov    $0x0,%eax
  10036d:	eb 78                	jmp    1003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100373:	7e 28                	jle    10039d <readline+0x69>
  100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10037c:	7f 1f                	jg     10039d <readline+0x69>
            cputchar(c);
  10037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100381:	89 04 24             	mov    %eax,(%esp)
  100384:	e8 2f ff ff ff       	call   1002b8 <cputchar>
            buf[i ++] = c;
  100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10038c:	8d 50 01             	lea    0x1(%eax),%edx
  10038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100395:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  10039b:	eb 45                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  10039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003a1:	75 16                	jne    1003b9 <readline+0x85>
  1003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003a7:	7e 10                	jle    1003b9 <readline+0x85>
            cputchar(c);
  1003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003ac:	89 04 24             	mov    %eax,(%esp)
  1003af:	e8 04 ff ff ff       	call   1002b8 <cputchar>
            i --;
  1003b4:	ff 4d f4             	decl   -0xc(%ebp)
  1003b7:	eb 29                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003bd:	74 06                	je     1003c5 <readline+0x91>
  1003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003c3:	75 95                	jne    10035a <readline+0x26>
            cputchar(c);
  1003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003c8:	89 04 24             	mov    %eax,(%esp)
  1003cb:	e8 e8 fe ff ff       	call   1002b8 <cputchar>
            buf[i] = '\0';
  1003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d3:	05 20 a0 11 00       	add    $0x11a020,%eax
  1003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003db:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1003e0:	eb 05                	jmp    1003e7 <readline+0xb3>
        c = getchar();
  1003e2:	e9 73 ff ff ff       	jmp    10035a <readline+0x26>
        }
    }
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ef:	a1 20 a4 11 00       	mov    0x11a420,%eax
  1003f4:	85 c0                	test   %eax,%eax
  1003f6:	75 5b                	jne    100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003f8:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  1003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100402:	8d 45 14             	lea    0x14(%ebp),%eax
  100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100408:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10040f:	8b 45 08             	mov    0x8(%ebp),%eax
  100412:	89 44 24 04          	mov    %eax,0x4(%esp)
  100416:	c7 04 24 6a 60 10 00 	movl   $0x10606a,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 86 60 10 00 	movl   $0x106086,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 88 60 10 00 	movl   $0x106088,(%esp)
  100447:	e8 46 fe ff ff       	call   100292 <cprintf>
    print_stackframe();
  10044c:	e8 32 06 00 00       	call   100a83 <print_stackframe>
  100451:	eb 01                	jmp    100454 <__panic+0x6b>
        goto panic_dead;
  100453:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100454:	e8 34 14 00 00       	call   10188d <intr_disable>
    while (1) {
        kmonitor(NULL);
  100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100460:	e8 46 08 00 00       	call   100cab <kmonitor>
  100465:	eb f2                	jmp    100459 <__panic+0x70>

00100467 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100467:	55                   	push   %ebp
  100468:	89 e5                	mov    %esp,%ebp
  10046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10046d:	8d 45 14             	lea    0x14(%ebp),%eax
  100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100473:	8b 45 0c             	mov    0xc(%ebp),%eax
  100476:	89 44 24 08          	mov    %eax,0x8(%esp)
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100481:	c7 04 24 9a 60 10 00 	movl   $0x10609a,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 86 60 10 00 	movl   $0x106086,(%esp)
  1004a6:	e8 e7 fd ff ff       	call   100292 <cprintf>
    va_end(ap);
}
  1004ab:	90                   	nop
  1004ac:	c9                   	leave  
  1004ad:	c3                   	ret    

001004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004ae:	55                   	push   %ebp
  1004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004b1:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  1004b6:	5d                   	pop    %ebp
  1004b7:	c3                   	ret    

001004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004b8:	55                   	push   %ebp
  1004b9:	89 e5                	mov    %esp,%ebp
  1004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004c1:	8b 00                	mov    (%eax),%eax
  1004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c9:	8b 00                	mov    (%eax),%eax
  1004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004d5:	e9 ca 00 00 00       	jmp    1005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004e0:	01 d0                	add    %edx,%eax
  1004e2:	89 c2                	mov    %eax,%edx
  1004e4:	c1 ea 1f             	shr    $0x1f,%edx
  1004e7:	01 d0                	add    %edx,%eax
  1004e9:	d1 f8                	sar    %eax
  1004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f4:	eb 03                	jmp    1004f9 <stab_binsearch+0x41>
            m --;
  1004f6:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ff:	7c 1f                	jl     100520 <stab_binsearch+0x68>
  100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100504:	89 d0                	mov    %edx,%eax
  100506:	01 c0                	add    %eax,%eax
  100508:	01 d0                	add    %edx,%eax
  10050a:	c1 e0 02             	shl    $0x2,%eax
  10050d:	89 c2                	mov    %eax,%edx
  10050f:	8b 45 08             	mov    0x8(%ebp),%eax
  100512:	01 d0                	add    %edx,%eax
  100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100518:	0f b6 c0             	movzbl %al,%eax
  10051b:	39 45 14             	cmp    %eax,0x14(%ebp)
  10051e:	75 d6                	jne    1004f6 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100526:	7d 09                	jge    100531 <stab_binsearch+0x79>
            l = true_m + 1;
  100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10052b:	40                   	inc    %eax
  10052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10052f:	eb 73                	jmp    1005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053b:	89 d0                	mov    %edx,%eax
  10053d:	01 c0                	add    %eax,%eax
  10053f:	01 d0                	add    %edx,%eax
  100541:	c1 e0 02             	shl    $0x2,%eax
  100544:	89 c2                	mov    %eax,%edx
  100546:	8b 45 08             	mov    0x8(%ebp),%eax
  100549:	01 d0                	add    %edx,%eax
  10054b:	8b 40 08             	mov    0x8(%eax),%eax
  10054e:	39 45 18             	cmp    %eax,0x18(%ebp)
  100551:	76 11                	jbe    100564 <stab_binsearch+0xac>
            *region_left = m;
  100553:	8b 45 0c             	mov    0xc(%ebp),%eax
  100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10055e:	40                   	inc    %eax
  10055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100562:	eb 40                	jmp    1005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100567:	89 d0                	mov    %edx,%eax
  100569:	01 c0                	add    %eax,%eax
  10056b:	01 d0                	add    %edx,%eax
  10056d:	c1 e0 02             	shl    $0x2,%eax
  100570:	89 c2                	mov    %eax,%edx
  100572:	8b 45 08             	mov    0x8(%ebp),%eax
  100575:	01 d0                	add    %edx,%eax
  100577:	8b 40 08             	mov    0x8(%eax),%eax
  10057a:	39 45 18             	cmp    %eax,0x18(%ebp)
  10057d:	73 14                	jae    100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100582:	8d 50 ff             	lea    -0x1(%eax),%edx
  100585:	8b 45 10             	mov    0x10(%ebp),%eax
  100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10058d:	48                   	dec    %eax
  10058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100591:	eb 11                	jmp    1005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100593:	8b 45 0c             	mov    0xc(%ebp),%eax
  100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100599:	89 10                	mov    %edx,(%eax)
            l = m;
  10059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005a1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005aa:	0f 8e 2a ff ff ff    	jle    1004da <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005b4:	75 0f                	jne    1005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b9:	8b 00                	mov    (%eax),%eax
  1005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005be:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005c3:	eb 3e                	jmp    100603 <stab_binsearch+0x14b>
        l = *region_right;
  1005c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c8:	8b 00                	mov    (%eax),%eax
  1005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005cd:	eb 03                	jmp    1005d2 <stab_binsearch+0x11a>
  1005cf:	ff 4d fc             	decl   -0x4(%ebp)
  1005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d5:	8b 00                	mov    (%eax),%eax
  1005d7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005da:	7e 1f                	jle    1005fb <stab_binsearch+0x143>
  1005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005df:	89 d0                	mov    %edx,%eax
  1005e1:	01 c0                	add    %eax,%eax
  1005e3:	01 d0                	add    %edx,%eax
  1005e5:	c1 e0 02             	shl    $0x2,%eax
  1005e8:	89 c2                	mov    %eax,%edx
  1005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ed:	01 d0                	add    %edx,%eax
  1005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005f3:	0f b6 c0             	movzbl %al,%eax
  1005f6:	39 45 14             	cmp    %eax,0x14(%ebp)
  1005f9:	75 d4                	jne    1005cf <stab_binsearch+0x117>
        *region_left = l;
  1005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100601:	89 10                	mov    %edx,(%eax)
}
  100603:	90                   	nop
  100604:	c9                   	leave  
  100605:	c3                   	ret    

00100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100606:	55                   	push   %ebp
  100607:	89 e5                	mov    %esp,%ebp
  100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060f:	c7 00 b8 60 10 00    	movl   $0x1060b8,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 b8 60 10 00 	movl   $0x1060b8,0x8(%eax)
    info->eip_fn_namelen = 9;
  100629:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100633:	8b 45 0c             	mov    0xc(%ebp),%eax
  100636:	8b 55 08             	mov    0x8(%ebp),%edx
  100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10063c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100646:	c7 45 f4 10 73 10 00 	movl   $0x107310,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 dc 24 11 00 	movl   $0x1124dc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec dd 24 11 00 	movl   $0x1124dd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 eb 4f 11 00 	movl   $0x114feb,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100668:	76 0b                	jbe    100675 <debuginfo_eip+0x6f>
  10066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066d:	48                   	dec    %eax
  10066e:	0f b6 00             	movzbl (%eax),%eax
  100671:	84 c0                	test   %al,%al
  100673:	74 0a                	je     10067f <debuginfo_eip+0x79>
        return -1;
  100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10067a:	e9 b7 02 00 00       	jmp    100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068c:	29 c2                	sub    %eax,%edx
  10068e:	89 d0                	mov    %edx,%eax
  100690:	c1 f8 02             	sar    $0x2,%eax
  100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100699:	48                   	dec    %eax
  10069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  10069d:	8b 45 08             	mov    0x8(%ebp),%eax
  1006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006ab:	00 
  1006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006af:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006bd:	89 04 24             	mov    %eax,(%esp)
  1006c0:	e8 f3 fd ff ff       	call   1004b8 <stab_binsearch>
    if (lfile == 0)
  1006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006c8:	85 c0                	test   %eax,%eax
  1006ca:	75 0a                	jne    1006d6 <debuginfo_eip+0xd0>
        return -1;
  1006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006d1:	e9 60 02 00 00       	jmp    100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 ae fd ff ff       	call   1004b8 <stab_binsearch>

    if (lfun <= rfun) {
  10070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 7c                	jg     100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	8b 00                	mov    (%eax),%eax
  10072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100731:	29 d1                	sub    %edx,%ecx
  100733:	89 ca                	mov    %ecx,%edx
  100735:	39 d0                	cmp    %edx,%eax
  100737:	73 22                	jae    10075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10073c:	89 c2                	mov    %eax,%edx
  10073e:	89 d0                	mov    %edx,%eax
  100740:	01 c0                	add    %eax,%eax
  100742:	01 d0                	add    %edx,%eax
  100744:	c1 e0 02             	shl    $0x2,%eax
  100747:	89 c2                	mov    %eax,%edx
  100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074c:	01 d0                	add    %edx,%eax
  10074e:	8b 10                	mov    (%eax),%edx
  100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100753:	01 c2                	add    %eax,%edx
  100755:	8b 45 0c             	mov    0xc(%ebp),%eax
  100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075e:	89 c2                	mov    %eax,%edx
  100760:	89 d0                	mov    %edx,%eax
  100762:	01 c0                	add    %eax,%eax
  100764:	01 d0                	add    %edx,%eax
  100766:	c1 e0 02             	shl    $0x2,%eax
  100769:	89 c2                	mov    %eax,%edx
  10076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	8b 50 08             	mov    0x8(%eax),%edx
  100773:	8b 45 0c             	mov    0xc(%ebp),%eax
  100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100779:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077c:	8b 40 10             	mov    0x10(%eax),%eax
  10077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10078e:	eb 15                	jmp    1007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100790:	8b 45 0c             	mov    0xc(%ebp),%eax
  100793:	8b 55 08             	mov    0x8(%ebp),%edx
  100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a8:	8b 40 08             	mov    0x8(%eax),%eax
  1007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007b2:	00 
  1007b3:	89 04 24             	mov    %eax,(%esp)
  1007b6:	e8 6c 4e 00 00       	call   105627 <strfind>
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c0:	8b 40 08             	mov    0x8(%eax),%eax
  1007c3:	29 c2                	sub    %eax,%edx
  1007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007d9:	00 
  1007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007eb:	89 04 24             	mov    %eax,(%esp)
  1007ee:	e8 c5 fc ff ff       	call   1004b8 <stab_binsearch>
    if (lline <= rline) {
  1007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007f9:	39 c2                	cmp    %eax,%edx
  1007fb:	7f 23                	jg     100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100800:	89 c2                	mov    %eax,%edx
  100802:	89 d0                	mov    %edx,%eax
  100804:	01 c0                	add    %eax,%eax
  100806:	01 d0                	add    %edx,%eax
  100808:	c1 e0 02             	shl    $0x2,%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100810:	01 d0                	add    %edx,%eax
  100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10081e:	eb 11                	jmp    100831 <debuginfo_eip+0x22b>
        return -1;
  100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100825:	e9 0c 01 00 00       	jmp    100936 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10082d:	48                   	dec    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100837:	39 c2                	cmp    %eax,%edx
  100839:	7c 56                	jl     100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  10083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083e:	89 c2                	mov    %eax,%edx
  100840:	89 d0                	mov    %edx,%eax
  100842:	01 c0                	add    %eax,%eax
  100844:	01 d0                	add    %edx,%eax
  100846:	c1 e0 02             	shl    $0x2,%eax
  100849:	89 c2                	mov    %eax,%edx
  10084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10084e:	01 d0                	add    %edx,%eax
  100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100854:	3c 84                	cmp    $0x84,%al
  100856:	74 39                	je     100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c 64                	cmp    $0x64,%al
  100873:	75 b5                	jne    10082a <debuginfo_eip+0x224>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 40 08             	mov    0x8(%eax),%eax
  10088d:	85 c0                	test   %eax,%eax
  10088f:	74 99                	je     10082a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100897:	39 c2                	cmp    %eax,%edx
  100899:	7c 46                	jl     1008e1 <debuginfo_eip+0x2db>
  10089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089e:	89 c2                	mov    %eax,%edx
  1008a0:	89 d0                	mov    %edx,%eax
  1008a2:	01 c0                	add    %eax,%eax
  1008a4:	01 d0                	add    %edx,%eax
  1008a6:	c1 e0 02             	shl    $0x2,%eax
  1008a9:	89 c2                	mov    %eax,%edx
  1008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ae:	01 d0                	add    %edx,%eax
  1008b0:	8b 00                	mov    (%eax),%eax
  1008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008b8:	29 d1                	sub    %edx,%ecx
  1008ba:	89 ca                	mov    %ecx,%edx
  1008bc:	39 d0                	cmp    %edx,%eax
  1008be:	73 21                	jae    1008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008c3:	89 c2                	mov    %eax,%edx
  1008c5:	89 d0                	mov    %edx,%eax
  1008c7:	01 c0                	add    %eax,%eax
  1008c9:	01 d0                	add    %edx,%eax
  1008cb:	c1 e0 02             	shl    $0x2,%eax
  1008ce:	89 c2                	mov    %eax,%edx
  1008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008d3:	01 d0                	add    %edx,%eax
  1008d5:	8b 10                	mov    (%eax),%edx
  1008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008da:	01 c2                	add    %eax,%edx
  1008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008e7:	39 c2                	cmp    %eax,%edx
  1008e9:	7d 46                	jge    100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008ee:	40                   	inc    %eax
  1008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008f2:	eb 16                	jmp    10090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f7:	8b 40 14             	mov    0x14(%eax),%eax
  1008fa:	8d 50 01             	lea    0x1(%eax),%edx
  1008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100900:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100906:	40                   	inc    %eax
  100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100910:	39 c2                	cmp    %eax,%edx
  100912:	7d 1d                	jge    100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100917:	89 c2                	mov    %eax,%edx
  100919:	89 d0                	mov    %edx,%eax
  10091b:	01 c0                	add    %eax,%eax
  10091d:	01 d0                	add    %edx,%eax
  10091f:	c1 e0 02             	shl    $0x2,%eax
  100922:	89 c2                	mov    %eax,%edx
  100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100927:	01 d0                	add    %edx,%eax
  100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10092d:	3c a0                	cmp    $0xa0,%al
  10092f:	74 c3                	je     1008f4 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
  100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100936:	c9                   	leave  
  100937:	c3                   	ret    

00100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100938:	55                   	push   %ebp
  100939:	89 e5                	mov    %esp,%ebp
  10093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10093e:	c7 04 24 c2 60 10 00 	movl   $0x1060c2,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 db 60 10 00 	movl   $0x1060db,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 a5 5f 10 	movl   $0x105fa5,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 f3 60 10 00 	movl   $0x1060f3,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 0b 61 10 00 	movl   $0x10610b,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 23 61 10 00 	movl   $0x106123,(%esp)
  100995:	e8 f8 f8 ff ff       	call   100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10099a:	b8 28 af 11 00       	mov    $0x11af28,%eax
  10099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009a5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009aa:	29 c2                	sub    %eax,%edx
  1009ac:	89 d0                	mov    %edx,%eax
  1009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b4:	85 c0                	test   %eax,%eax
  1009b6:	0f 48 c2             	cmovs  %edx,%eax
  1009b9:	c1 f8 0a             	sar    $0xa,%eax
  1009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c0:	c7 04 24 3c 61 10 00 	movl   $0x10613c,(%esp)
  1009c7:	e8 c6 f8 ff ff       	call   100292 <cprintf>
}
  1009cc:	90                   	nop
  1009cd:	c9                   	leave  
  1009ce:	c3                   	ret    

001009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009cf:	55                   	push   %ebp
  1009d0:	89 e5                	mov    %esp,%ebp
  1009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009df:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e2:	89 04 24             	mov    %eax,(%esp)
  1009e5:	e8 1c fc ff ff       	call   100606 <debuginfo_eip>
  1009ea:	85 c0                	test   %eax,%eax
  1009ec:	74 15                	je     100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f5:	c7 04 24 66 61 10 00 	movl   $0x106166,(%esp)
  1009fc:	e8 91 f8 ff ff       	call   100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a01:	eb 6c                	jmp    100a6f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a0a:	eb 1b                	jmp    100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	0f b6 00             	movzbl (%eax),%eax
  100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a20:	01 ca                	add    %ecx,%edx
  100a22:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a24:	ff 45 f4             	incl   -0xc(%ebp)
  100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a2d:	7c dd                	jl     100a0c <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a38:	01 d0                	add    %edx,%eax
  100a3a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a40:	8b 55 08             	mov    0x8(%ebp),%edx
  100a43:	89 d1                	mov    %edx,%ecx
  100a45:	29 c1                	sub    %eax,%ecx
  100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a63:	c7 04 24 82 61 10 00 	movl   $0x106182,(%esp)
  100a6a:	e8 23 f8 ff ff       	call   100292 <cprintf>
}
  100a6f:	90                   	nop
  100a70:	c9                   	leave  
  100a71:	c3                   	ret    

00100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a72:	55                   	push   %ebp
  100a73:	89 e5                	mov    %esp,%ebp
  100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a78:	8b 45 04             	mov    0x4(%ebp),%eax
  100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a81:	c9                   	leave  
  100a82:	c3                   	ret    

00100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a89:	89 e8                	mov    %ebp,%eax
  100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
  100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
  100a94:	e8 d9 ff ff ff       	call   100a72 <read_eip>
  100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for(uint32_t i = 0; ebp && i < STACKFRAME_DEPTH; i++) {
  100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100aa3:	e9 84 00 00 00       	jmp    100b2c <print_stackframe+0xa9>
          cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab6:	c7 04 24 94 61 10 00 	movl   $0x106194,(%esp)
  100abd:	e8 d0 f7 ff ff       	call   100292 <cprintf>
          uint32_t* args = (uint32_t*)ebp + 2;
  100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac5:	83 c0 08             	add    $0x8,%eax
  100ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          for(uint32_t j = 0; j < 4; j++)
  100acb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ad2:	eb 24                	jmp    100af8 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
  100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ae1:	01 d0                	add    %edx,%eax
  100ae3:	8b 00                	mov    (%eax),%eax
  100ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae9:	c7 04 24 b0 61 10 00 	movl   $0x1061b0,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
          for(uint32_t j = 0; j < 4; j++)
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	76 d6                	jbe    100ad4 <print_stackframe+0x51>
        cprintf("\n");
  100afe:	c7 04 24 b8 61 10 00 	movl   $0x1061b8,(%esp)
  100b05:	e8 88 f7 ff ff       	call   100292 <cprintf>
        print_debuginfo(eip-1);
  100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0d:	48                   	dec    %eax
  100b0e:	89 04 24             	mov    %eax,(%esp)
  100b11:	e8 b9 fe ff ff       	call   1009cf <print_debuginfo>
        eip = ((uint32_t*)ebp)[1];
  100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b19:	83 c0 04             	add    $0x4,%eax
  100b1c:	8b 00                	mov    (%eax),%eax
  100b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t*)ebp)[0];
  100b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b24:	8b 00                	mov    (%eax),%eax
  100b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(uint32_t i = 0; ebp && i < STACKFRAME_DEPTH; i++) {
  100b29:	ff 45 ec             	incl   -0x14(%ebp)
  100b2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b30:	74 0a                	je     100b3c <print_stackframe+0xb9>
  100b32:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b36:	0f 86 6c ff ff ff    	jbe    100aa8 <print_stackframe+0x25>
      }
}
  100b3c:	90                   	nop
  100b3d:	c9                   	leave  
  100b3e:	c3                   	ret    

00100b3f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b3f:	55                   	push   %ebp
  100b40:	89 e5                	mov    %esp,%ebp
  100b42:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4c:	eb 0c                	jmp    100b5a <parse+0x1b>
            *buf ++ = '\0';
  100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b51:	8d 50 01             	lea    0x1(%eax),%edx
  100b54:	89 55 08             	mov    %edx,0x8(%ebp)
  100b57:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5d:	0f b6 00             	movzbl (%eax),%eax
  100b60:	84 c0                	test   %al,%al
  100b62:	74 1d                	je     100b81 <parse+0x42>
  100b64:	8b 45 08             	mov    0x8(%ebp),%eax
  100b67:	0f b6 00             	movzbl (%eax),%eax
  100b6a:	0f be c0             	movsbl %al,%eax
  100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b71:	c7 04 24 3c 62 10 00 	movl   $0x10623c,(%esp)
  100b78:	e8 78 4a 00 00       	call   1055f5 <strchr>
  100b7d:	85 c0                	test   %eax,%eax
  100b7f:	75 cd                	jne    100b4e <parse+0xf>
        }
        if (*buf == '\0') {
  100b81:	8b 45 08             	mov    0x8(%ebp),%eax
  100b84:	0f b6 00             	movzbl (%eax),%eax
  100b87:	84 c0                	test   %al,%al
  100b89:	74 65                	je     100bf0 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b8b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b8f:	75 14                	jne    100ba5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b91:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b98:	00 
  100b99:	c7 04 24 41 62 10 00 	movl   $0x106241,(%esp)
  100ba0:	e8 ed f6 ff ff       	call   100292 <cprintf>
        }
        argv[argc ++] = buf;
  100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ba8:	8d 50 01             	lea    0x1(%eax),%edx
  100bab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bb8:	01 c2                	add    %eax,%edx
  100bba:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bbf:	eb 03                	jmp    100bc4 <parse+0x85>
            buf ++;
  100bc1:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc7:	0f b6 00             	movzbl (%eax),%eax
  100bca:	84 c0                	test   %al,%al
  100bcc:	74 8c                	je     100b5a <parse+0x1b>
  100bce:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd1:	0f b6 00             	movzbl (%eax),%eax
  100bd4:	0f be c0             	movsbl %al,%eax
  100bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdb:	c7 04 24 3c 62 10 00 	movl   $0x10623c,(%esp)
  100be2:	e8 0e 4a 00 00       	call   1055f5 <strchr>
  100be7:	85 c0                	test   %eax,%eax
  100be9:	74 d6                	je     100bc1 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100beb:	e9 6a ff ff ff       	jmp    100b5a <parse+0x1b>
            break;
  100bf0:	90                   	nop
        }
    }
    return argc;
  100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bf4:	c9                   	leave  
  100bf5:	c3                   	ret    

00100bf6 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bf6:	55                   	push   %ebp
  100bf7:	89 e5                	mov    %esp,%ebp
  100bf9:	53                   	push   %ebx
  100bfa:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bfd:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c04:	8b 45 08             	mov    0x8(%ebp),%eax
  100c07:	89 04 24             	mov    %eax,(%esp)
  100c0a:	e8 30 ff ff ff       	call   100b3f <parse>
  100c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c16:	75 0a                	jne    100c22 <runcmd+0x2c>
        return 0;
  100c18:	b8 00 00 00 00       	mov    $0x0,%eax
  100c1d:	e9 83 00 00 00       	jmp    100ca5 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c29:	eb 5a                	jmp    100c85 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c2b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c31:	89 d0                	mov    %edx,%eax
  100c33:	01 c0                	add    %eax,%eax
  100c35:	01 d0                	add    %edx,%eax
  100c37:	c1 e0 02             	shl    $0x2,%eax
  100c3a:	05 00 70 11 00       	add    $0x117000,%eax
  100c3f:	8b 00                	mov    (%eax),%eax
  100c41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c45:	89 04 24             	mov    %eax,(%esp)
  100c48:	e8 0b 49 00 00       	call   105558 <strcmp>
  100c4d:	85 c0                	test   %eax,%eax
  100c4f:	75 31                	jne    100c82 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c54:	89 d0                	mov    %edx,%eax
  100c56:	01 c0                	add    %eax,%eax
  100c58:	01 d0                	add    %edx,%eax
  100c5a:	c1 e0 02             	shl    $0x2,%eax
  100c5d:	05 08 70 11 00       	add    $0x117008,%eax
  100c62:	8b 10                	mov    (%eax),%edx
  100c64:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c67:	83 c0 04             	add    $0x4,%eax
  100c6a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c6d:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c7b:	89 1c 24             	mov    %ebx,(%esp)
  100c7e:	ff d2                	call   *%edx
  100c80:	eb 23                	jmp    100ca5 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c82:	ff 45 f4             	incl   -0xc(%ebp)
  100c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c88:	83 f8 02             	cmp    $0x2,%eax
  100c8b:	76 9e                	jbe    100c2b <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c8d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c94:	c7 04 24 5f 62 10 00 	movl   $0x10625f,(%esp)
  100c9b:	e8 f2 f5 ff ff       	call   100292 <cprintf>
    return 0;
  100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ca5:	83 c4 64             	add    $0x64,%esp
  100ca8:	5b                   	pop    %ebx
  100ca9:	5d                   	pop    %ebp
  100caa:	c3                   	ret    

00100cab <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cab:	55                   	push   %ebp
  100cac:	89 e5                	mov    %esp,%ebp
  100cae:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cb1:	c7 04 24 78 62 10 00 	movl   $0x106278,(%esp)
  100cb8:	e8 d5 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbd:	c7 04 24 a0 62 10 00 	movl   $0x1062a0,(%esp)
  100cc4:	e8 c9 f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ccd:	74 0b                	je     100cda <kmonitor+0x2f>
        print_trapframe(tf);
  100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd2:	89 04 24             	mov    %eax,(%esp)
  100cd5:	e8 8f 0d 00 00       	call   101a69 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cda:	c7 04 24 c5 62 10 00 	movl   $0x1062c5,(%esp)
  100ce1:	e8 4e f6 ff ff       	call   100334 <readline>
  100ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100ced:	74 eb                	je     100cda <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cef:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cf9:	89 04 24             	mov    %eax,(%esp)
  100cfc:	e8 f5 fe ff ff       	call   100bf6 <runcmd>
  100d01:	85 c0                	test   %eax,%eax
  100d03:	78 02                	js     100d07 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100d05:	eb d3                	jmp    100cda <kmonitor+0x2f>
                break;
  100d07:	90                   	nop
            }
        }
    }
}
  100d08:	90                   	nop
  100d09:	c9                   	leave  
  100d0a:	c3                   	ret    

00100d0b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d0b:	55                   	push   %ebp
  100d0c:	89 e5                	mov    %esp,%ebp
  100d0e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d18:	eb 3d                	jmp    100d57 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d1d:	89 d0                	mov    %edx,%eax
  100d1f:	01 c0                	add    %eax,%eax
  100d21:	01 d0                	add    %edx,%eax
  100d23:	c1 e0 02             	shl    $0x2,%eax
  100d26:	05 04 70 11 00       	add    $0x117004,%eax
  100d2b:	8b 08                	mov    (%eax),%ecx
  100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d30:	89 d0                	mov    %edx,%eax
  100d32:	01 c0                	add    %eax,%eax
  100d34:	01 d0                	add    %edx,%eax
  100d36:	c1 e0 02             	shl    $0x2,%eax
  100d39:	05 00 70 11 00       	add    $0x117000,%eax
  100d3e:	8b 00                	mov    (%eax),%eax
  100d40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d48:	c7 04 24 c9 62 10 00 	movl   $0x1062c9,(%esp)
  100d4f:	e8 3e f5 ff ff       	call   100292 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d54:	ff 45 f4             	incl   -0xc(%ebp)
  100d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d5a:	83 f8 02             	cmp    $0x2,%eax
  100d5d:	76 bb                	jbe    100d1a <mon_help+0xf>
    }
    return 0;
  100d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d64:	c9                   	leave  
  100d65:	c3                   	ret    

00100d66 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d66:	55                   	push   %ebp
  100d67:	89 e5                	mov    %esp,%ebp
  100d69:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d6c:	e8 c7 fb ff ff       	call   100938 <print_kerninfo>
    return 0;
  100d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d76:	c9                   	leave  
  100d77:	c3                   	ret    

00100d78 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d78:	55                   	push   %ebp
  100d79:	89 e5                	mov    %esp,%ebp
  100d7b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d7e:	e8 00 fd ff ff       	call   100a83 <print_stackframe>
    return 0;
  100d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d88:	c9                   	leave  
  100d89:	c3                   	ret    

00100d8a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d8a:	55                   	push   %ebp
  100d8b:	89 e5                	mov    %esp,%ebp
  100d8d:	83 ec 28             	sub    $0x28,%esp
  100d90:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100d96:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d9a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d9e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100da2:	ee                   	out    %al,(%dx)
  100da3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100da9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dad:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100db1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100db5:	ee                   	out    %al,(%dx)
  100db6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dbc:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100dc0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dc8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dc9:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100dd0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd3:	c7 04 24 d2 62 10 00 	movl   $0x1062d2,(%esp)
  100dda:	e8 b3 f4 ff ff       	call   100292 <cprintf>
    pic_enable(IRQ_TIMER);
  100ddf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100de6:	e8 2e 09 00 00       	call   101719 <pic_enable>
}
  100deb:	90                   	nop
  100dec:	c9                   	leave  
  100ded:	c3                   	ret    

00100dee <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100dee:	55                   	push   %ebp
  100def:	89 e5                	mov    %esp,%ebp
  100df1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100df4:	9c                   	pushf  
  100df5:	58                   	pop    %eax
  100df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100dfc:	25 00 02 00 00       	and    $0x200,%eax
  100e01:	85 c0                	test   %eax,%eax
  100e03:	74 0c                	je     100e11 <__intr_save+0x23>
        intr_disable();
  100e05:	e8 83 0a 00 00       	call   10188d <intr_disable>
        return 1;
  100e0a:	b8 01 00 00 00       	mov    $0x1,%eax
  100e0f:	eb 05                	jmp    100e16 <__intr_save+0x28>
    }
    return 0;
  100e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e16:	c9                   	leave  
  100e17:	c3                   	ret    

00100e18 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e18:	55                   	push   %ebp
  100e19:	89 e5                	mov    %esp,%ebp
  100e1b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e22:	74 05                	je     100e29 <__intr_restore+0x11>
        intr_enable();
  100e24:	e8 5d 0a 00 00       	call   101886 <intr_enable>
    }
}
  100e29:	90                   	nop
  100e2a:	c9                   	leave  
  100e2b:	c3                   	ret    

00100e2c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e2c:	55                   	push   %ebp
  100e2d:	89 e5                	mov    %esp,%ebp
  100e2f:	83 ec 10             	sub    $0x10,%esp
  100e32:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e38:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e3c:	89 c2                	mov    %eax,%edx
  100e3e:	ec                   	in     (%dx),%al
  100e3f:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e42:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e48:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e4c:	89 c2                	mov    %eax,%edx
  100e4e:	ec                   	in     (%dx),%al
  100e4f:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e52:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e58:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5c:	89 c2                	mov    %eax,%edx
  100e5e:	ec                   	in     (%dx),%al
  100e5f:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e62:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e6c:	89 c2                	mov    %eax,%edx
  100e6e:	ec                   	in     (%dx),%al
  100e6f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e72:	90                   	nop
  100e73:	c9                   	leave  
  100e74:	c3                   	ret    

00100e75 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e75:	55                   	push   %ebp
  100e76:	89 e5                	mov    %esp,%ebp
  100e78:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e7b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e85:	0f b7 00             	movzwl (%eax),%eax
  100e88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e8f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 00             	movzwl (%eax),%eax
  100e9a:	0f b7 c0             	movzwl %ax,%eax
  100e9d:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ea2:	74 12                	je     100eb6 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ea4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eab:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100eb2:	b4 03 
  100eb4:	eb 13                	jmp    100ec9 <cga_init+0x54>
    } else {
        *cp = was;
  100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ebd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ec0:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ec7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ec9:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ed0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ed4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ed8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100edc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee1:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ee8:	40                   	inc    %eax
  100ee9:	0f b7 c0             	movzwl %ax,%eax
  100eec:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100ef4:	89 c2                	mov    %eax,%edx
  100ef6:	ec                   	in     (%dx),%al
  100ef7:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100efa:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100efe:	0f b6 c0             	movzbl %al,%eax
  100f01:	c1 e0 08             	shl    $0x8,%eax
  100f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f07:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f12:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f1f:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f26:	40                   	inc    %eax
  100f27:	0f b7 c0             	movzwl %ax,%eax
  100f2a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f2e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f32:	89 c2                	mov    %eax,%edx
  100f34:	ec                   	in     (%dx),%al
  100f35:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f38:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f3c:	0f b6 c0             	movzbl %al,%eax
  100f3f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f45:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f4d:	0f b7 c0             	movzwl %ax,%eax
  100f50:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f56:	90                   	nop
  100f57:	c9                   	leave  
  100f58:	c3                   	ret    

00100f59 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f59:	55                   	push   %ebp
  100f5a:	89 e5                	mov    %esp,%ebp
  100f5c:	83 ec 48             	sub    $0x48,%esp
  100f5f:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f65:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f69:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f6d:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f71:	ee                   	out    %al,(%dx)
  100f72:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f78:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f7c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f80:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f84:	ee                   	out    %al,(%dx)
  100f85:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f8b:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100f8f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f93:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f97:	ee                   	out    %al,(%dx)
  100f98:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f9e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fa2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fa6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100faa:	ee                   	out    %al,(%dx)
  100fab:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fb1:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100fb5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fb9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fbd:	ee                   	out    %al,(%dx)
  100fbe:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fc4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100fc8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fd0:	ee                   	out    %al,(%dx)
  100fd1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fd7:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100fdb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fdf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fe3:	ee                   	out    %al,(%dx)
  100fe4:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fea:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100fee:	89 c2                	mov    %eax,%edx
  100ff0:	ec                   	in     (%dx),%al
  100ff1:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ff4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ff8:	3c ff                	cmp    $0xff,%al
  100ffa:	0f 95 c0             	setne  %al
  100ffd:	0f b6 c0             	movzbl %al,%eax
  101000:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101005:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10100b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10100f:	89 c2                	mov    %eax,%edx
  101011:	ec                   	in     (%dx),%al
  101012:	88 45 f1             	mov    %al,-0xf(%ebp)
  101015:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10101b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10101f:	89 c2                	mov    %eax,%edx
  101021:	ec                   	in     (%dx),%al
  101022:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101025:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10102a:	85 c0                	test   %eax,%eax
  10102c:	74 0c                	je     10103a <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  10102e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101035:	e8 df 06 00 00       	call   101719 <pic_enable>
    }
}
  10103a:	90                   	nop
  10103b:	c9                   	leave  
  10103c:	c3                   	ret    

0010103d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10103d:	55                   	push   %ebp
  10103e:	89 e5                	mov    %esp,%ebp
  101040:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101043:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10104a:	eb 08                	jmp    101054 <lpt_putc_sub+0x17>
        delay();
  10104c:	e8 db fd ff ff       	call   100e2c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101051:	ff 45 fc             	incl   -0x4(%ebp)
  101054:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10105a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10105e:	89 c2                	mov    %eax,%edx
  101060:	ec                   	in     (%dx),%al
  101061:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101064:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101068:	84 c0                	test   %al,%al
  10106a:	78 09                	js     101075 <lpt_putc_sub+0x38>
  10106c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101073:	7e d7                	jle    10104c <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101075:	8b 45 08             	mov    0x8(%ebp),%eax
  101078:	0f b6 c0             	movzbl %al,%eax
  10107b:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101081:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101084:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101088:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10108c:	ee                   	out    %al,(%dx)
  10108d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101093:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101097:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10109b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10109f:	ee                   	out    %al,(%dx)
  1010a0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010a6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  1010aa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010b2:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010b3:	90                   	nop
  1010b4:	c9                   	leave  
  1010b5:	c3                   	ret    

001010b6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010b6:	55                   	push   %ebp
  1010b7:	89 e5                	mov    %esp,%ebp
  1010b9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010bc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010c0:	74 0d                	je     1010cf <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c5:	89 04 24             	mov    %eax,(%esp)
  1010c8:	e8 70 ff ff ff       	call   10103d <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010cd:	eb 24                	jmp    1010f3 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010d6:	e8 62 ff ff ff       	call   10103d <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010e2:	e8 56 ff ff ff       	call   10103d <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010ee:	e8 4a ff ff ff       	call   10103d <lpt_putc_sub>
}
  1010f3:	90                   	nop
  1010f4:	c9                   	leave  
  1010f5:	c3                   	ret    

001010f6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010f6:	55                   	push   %ebp
  1010f7:	89 e5                	mov    %esp,%ebp
  1010f9:	53                   	push   %ebx
  1010fa:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  101100:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101105:	85 c0                	test   %eax,%eax
  101107:	75 07                	jne    101110 <cga_putc+0x1a>
        c |= 0x0700;
  101109:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101110:	8b 45 08             	mov    0x8(%ebp),%eax
  101113:	0f b6 c0             	movzbl %al,%eax
  101116:	83 f8 0a             	cmp    $0xa,%eax
  101119:	74 55                	je     101170 <cga_putc+0x7a>
  10111b:	83 f8 0d             	cmp    $0xd,%eax
  10111e:	74 63                	je     101183 <cga_putc+0x8d>
  101120:	83 f8 08             	cmp    $0x8,%eax
  101123:	0f 85 94 00 00 00    	jne    1011bd <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
  101129:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101130:	85 c0                	test   %eax,%eax
  101132:	0f 84 af 00 00 00    	je     1011e7 <cga_putc+0xf1>
            crt_pos --;
  101138:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10113f:	48                   	dec    %eax
  101140:	0f b7 c0             	movzwl %ax,%eax
  101143:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101149:	8b 45 08             	mov    0x8(%ebp),%eax
  10114c:	98                   	cwtl   
  10114d:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101152:	98                   	cwtl   
  101153:	83 c8 20             	or     $0x20,%eax
  101156:	98                   	cwtl   
  101157:	8b 15 40 a4 11 00    	mov    0x11a440,%edx
  10115d:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101164:	01 c9                	add    %ecx,%ecx
  101166:	01 ca                	add    %ecx,%edx
  101168:	0f b7 c0             	movzwl %ax,%eax
  10116b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10116e:	eb 77                	jmp    1011e7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  101170:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101177:	83 c0 50             	add    $0x50,%eax
  10117a:	0f b7 c0             	movzwl %ax,%eax
  10117d:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101183:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  10118a:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101191:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101196:	89 c8                	mov    %ecx,%eax
  101198:	f7 e2                	mul    %edx
  10119a:	c1 ea 06             	shr    $0x6,%edx
  10119d:	89 d0                	mov    %edx,%eax
  10119f:	c1 e0 02             	shl    $0x2,%eax
  1011a2:	01 d0                	add    %edx,%eax
  1011a4:	c1 e0 04             	shl    $0x4,%eax
  1011a7:	29 c1                	sub    %eax,%ecx
  1011a9:	89 c8                	mov    %ecx,%eax
  1011ab:	0f b7 c0             	movzwl %ax,%eax
  1011ae:	29 c3                	sub    %eax,%ebx
  1011b0:	89 d8                	mov    %ebx,%eax
  1011b2:	0f b7 c0             	movzwl %ax,%eax
  1011b5:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011bb:	eb 2b                	jmp    1011e8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011bd:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011c3:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ca:	8d 50 01             	lea    0x1(%eax),%edx
  1011cd:	0f b7 d2             	movzwl %dx,%edx
  1011d0:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011d7:	01 c0                	add    %eax,%eax
  1011d9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1011df:	0f b7 c0             	movzwl %ax,%eax
  1011e2:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e5:	eb 01                	jmp    1011e8 <cga_putc+0xf2>
        break;
  1011e7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e8:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ef:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011f4:	76 5d                	jbe    101253 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f6:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101201:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101206:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120d:	00 
  10120e:	89 54 24 04          	mov    %edx,0x4(%esp)
  101212:	89 04 24             	mov    %eax,(%esp)
  101215:	e8 d1 45 00 00       	call   1057eb <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10121a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101221:	eb 14                	jmp    101237 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  101223:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101228:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10122b:	01 d2                	add    %edx,%edx
  10122d:	01 d0                	add    %edx,%eax
  10122f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101234:	ff 45 f4             	incl   -0xc(%ebp)
  101237:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123e:	7e e3                	jle    101223 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
  101240:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101247:	83 e8 50             	sub    $0x50,%eax
  10124a:	0f b7 c0             	movzwl %ax,%eax
  10124d:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101253:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10125a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10125e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101262:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101266:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10126a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10126b:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101272:	c1 e8 08             	shr    $0x8,%eax
  101275:	0f b7 c0             	movzwl %ax,%eax
  101278:	0f b6 c0             	movzbl %al,%eax
  10127b:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  101282:	42                   	inc    %edx
  101283:	0f b7 d2             	movzwl %dx,%edx
  101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  10128a:	88 45 e9             	mov    %al,-0x17(%ebp)
  10128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101295:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101296:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10129d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012a1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  1012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012ae:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012b5:	0f b6 c0             	movzbl %al,%eax
  1012b8:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012bf:	42                   	inc    %edx
  1012c0:	0f b7 d2             	movzwl %dx,%edx
  1012c3:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012c7:	88 45 f1             	mov    %al,-0xf(%ebp)
  1012ca:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012ce:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012d2:	ee                   	out    %al,(%dx)
}
  1012d3:	90                   	nop
  1012d4:	83 c4 34             	add    $0x34,%esp
  1012d7:	5b                   	pop    %ebx
  1012d8:	5d                   	pop    %ebp
  1012d9:	c3                   	ret    

001012da <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012da:	55                   	push   %ebp
  1012db:	89 e5                	mov    %esp,%ebp
  1012dd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e7:	eb 08                	jmp    1012f1 <serial_putc_sub+0x17>
        delay();
  1012e9:	e8 3e fb ff ff       	call   100e2c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012ee:	ff 45 fc             	incl   -0x4(%ebp)
  1012f1:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012f7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fb:	89 c2                	mov    %eax,%edx
  1012fd:	ec                   	in     (%dx),%al
  1012fe:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101301:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101305:	0f b6 c0             	movzbl %al,%eax
  101308:	83 e0 20             	and    $0x20,%eax
  10130b:	85 c0                	test   %eax,%eax
  10130d:	75 09                	jne    101318 <serial_putc_sub+0x3e>
  10130f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101316:	7e d1                	jle    1012e9 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101318:	8b 45 08             	mov    0x8(%ebp),%eax
  10131b:	0f b6 c0             	movzbl %al,%eax
  10131e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101324:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101327:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10132f:	ee                   	out    %al,(%dx)
}
  101330:	90                   	nop
  101331:	c9                   	leave  
  101332:	c3                   	ret    

00101333 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101333:	55                   	push   %ebp
  101334:	89 e5                	mov    %esp,%ebp
  101336:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101339:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133d:	74 0d                	je     10134c <serial_putc+0x19>
        serial_putc_sub(c);
  10133f:	8b 45 08             	mov    0x8(%ebp),%eax
  101342:	89 04 24             	mov    %eax,(%esp)
  101345:	e8 90 ff ff ff       	call   1012da <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10134a:	eb 24                	jmp    101370 <serial_putc+0x3d>
        serial_putc_sub('\b');
  10134c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101353:	e8 82 ff ff ff       	call   1012da <serial_putc_sub>
        serial_putc_sub(' ');
  101358:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10135f:	e8 76 ff ff ff       	call   1012da <serial_putc_sub>
        serial_putc_sub('\b');
  101364:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136b:	e8 6a ff ff ff       	call   1012da <serial_putc_sub>
}
  101370:	90                   	nop
  101371:	c9                   	leave  
  101372:	c3                   	ret    

00101373 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101373:	55                   	push   %ebp
  101374:	89 e5                	mov    %esp,%ebp
  101376:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101379:	eb 33                	jmp    1013ae <cons_intr+0x3b>
        if (c != 0) {
  10137b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10137f:	74 2d                	je     1013ae <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101381:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101386:	8d 50 01             	lea    0x1(%eax),%edx
  101389:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  10138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101392:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101398:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10139d:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a2:	75 0a                	jne    1013ae <cons_intr+0x3b>
                cons.wpos = 0;
  1013a4:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013ab:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b1:	ff d0                	call   *%eax
  1013b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013ba:	75 bf                	jne    10137b <cons_intr+0x8>
            }
        }
    }
}
  1013bc:	90                   	nop
  1013bd:	c9                   	leave  
  1013be:	c3                   	ret    

001013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013bf:	55                   	push   %ebp
  1013c0:	89 e5                	mov    %esp,%ebp
  1013c2:	83 ec 10             	sub    $0x10,%esp
  1013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cf:	89 c2                	mov    %eax,%edx
  1013d1:	ec                   	in     (%dx),%al
  1013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d9:	0f b6 c0             	movzbl %al,%eax
  1013dc:	83 e0 01             	and    $0x1,%eax
  1013df:	85 c0                	test   %eax,%eax
  1013e1:	75 07                	jne    1013ea <serial_proc_data+0x2b>
        return -1;
  1013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e8:	eb 2a                	jmp    101414 <serial_proc_data+0x55>
  1013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013f4:	89 c2                	mov    %eax,%edx
  1013f6:	ec                   	in     (%dx),%al
  1013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013fe:	0f b6 c0             	movzbl %al,%eax
  101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101408:	75 07                	jne    101411 <serial_proc_data+0x52>
        c = '\b';
  10140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101414:	c9                   	leave  
  101415:	c3                   	ret    

00101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101416:	55                   	push   %ebp
  101417:	89 e5                	mov    %esp,%ebp
  101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10141c:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101421:	85 c0                	test   %eax,%eax
  101423:	74 0c                	je     101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101425:	c7 04 24 bf 13 10 00 	movl   $0x1013bf,(%esp)
  10142c:	e8 42 ff ff ff       	call   101373 <cons_intr>
    }
}
  101431:	90                   	nop
  101432:	c9                   	leave  
  101433:	c3                   	ret    

00101434 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101434:	55                   	push   %ebp
  101435:	89 e5                	mov    %esp,%ebp
  101437:	83 ec 38             	sub    $0x38,%esp
  10143a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101440:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101443:	89 c2                	mov    %eax,%edx
  101445:	ec                   	in     (%dx),%al
  101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10144d:	0f b6 c0             	movzbl %al,%eax
  101450:	83 e0 01             	and    $0x1,%eax
  101453:	85 c0                	test   %eax,%eax
  101455:	75 0a                	jne    101461 <kbd_proc_data+0x2d>
        return -1;
  101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10145c:	e9 55 01 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
  101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10146a:	89 c2                	mov    %eax,%edx
  10146c:	ec                   	in     (%dx),%al
  10146d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101470:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101474:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101477:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10147b:	75 17                	jne    101494 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  10147d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101482:	83 c8 40             	or     $0x40,%eax
  101485:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  10148a:	b8 00 00 00 00       	mov    $0x0,%eax
  10148f:	e9 22 01 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  101494:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101498:	84 c0                	test   %al,%al
  10149a:	79 45                	jns    1014e1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149c:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014a1:	83 e0 40             	and    $0x40,%eax
  1014a4:	85 c0                	test   %eax,%eax
  1014a6:	75 08                	jne    1014b0 <kbd_proc_data+0x7c>
  1014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ac:	24 7f                	and    $0x7f,%al
  1014ae:	eb 04                	jmp    1014b4 <kbd_proc_data+0x80>
  1014b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bb:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014c2:	0c 40                	or     $0x40,%al
  1014c4:	0f b6 c0             	movzbl %al,%eax
  1014c7:	f7 d0                	not    %eax
  1014c9:	89 c2                	mov    %eax,%edx
  1014cb:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d0:	21 d0                	and    %edx,%eax
  1014d2:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  1014dc:	e9 d5 00 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  1014e1:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014e6:	83 e0 40             	and    $0x40,%eax
  1014e9:	85 c0                	test   %eax,%eax
  1014eb:	74 11                	je     1014fe <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014ed:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f1:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f6:	83 e0 bf             	and    $0xffffffbf,%eax
  1014f9:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  1014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101502:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  101509:	0f b6 d0             	movzbl %al,%edx
  10150c:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101511:	09 d0                	or     %edx,%eax
  101513:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151c:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101523:	0f b6 d0             	movzbl %al,%edx
  101526:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152b:	31 d0                	xor    %edx,%eax
  10152d:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101532:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101537:	83 e0 03             	and    $0x3,%eax
  10153a:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101545:	01 d0                	add    %edx,%eax
  101547:	0f b6 00             	movzbl (%eax),%eax
  10154a:	0f b6 c0             	movzbl %al,%eax
  10154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101550:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101555:	83 e0 08             	and    $0x8,%eax
  101558:	85 c0                	test   %eax,%eax
  10155a:	74 22                	je     10157e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10155c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101560:	7e 0c                	jle    10156e <kbd_proc_data+0x13a>
  101562:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101566:	7f 06                	jg     10156e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101568:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10156c:	eb 10                	jmp    10157e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10156e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101572:	7e 0a                	jle    10157e <kbd_proc_data+0x14a>
  101574:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101578:	7f 04                	jg     10157e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10157a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10157e:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101583:	f7 d0                	not    %eax
  101585:	83 e0 06             	and    $0x6,%eax
  101588:	85 c0                	test   %eax,%eax
  10158a:	75 27                	jne    1015b3 <kbd_proc_data+0x17f>
  10158c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101593:	75 1e                	jne    1015b3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  101595:	c7 04 24 ed 62 10 00 	movl   $0x1062ed,(%esp)
  10159c:	e8 f1 ec ff ff       	call   100292 <cprintf>
  1015a1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015a7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ab:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015af:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015b2:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015b6:	c9                   	leave  
  1015b7:	c3                   	ret    

001015b8 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015b8:	55                   	push   %ebp
  1015b9:	89 e5                	mov    %esp,%ebp
  1015bb:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015be:	c7 04 24 34 14 10 00 	movl   $0x101434,(%esp)
  1015c5:	e8 a9 fd ff ff       	call   101373 <cons_intr>
}
  1015ca:	90                   	nop
  1015cb:	c9                   	leave  
  1015cc:	c3                   	ret    

001015cd <kbd_init>:

static void
kbd_init(void) {
  1015cd:	55                   	push   %ebp
  1015ce:	89 e5                	mov    %esp,%ebp
  1015d0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015d3:	e8 e0 ff ff ff       	call   1015b8 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015df:	e8 35 01 00 00       	call   101719 <pic_enable>
}
  1015e4:	90                   	nop
  1015e5:	c9                   	leave  
  1015e6:	c3                   	ret    

001015e7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e7:	55                   	push   %ebp
  1015e8:	89 e5                	mov    %esp,%ebp
  1015ea:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ed:	e8 83 f8 ff ff       	call   100e75 <cga_init>
    serial_init();
  1015f2:	e8 62 f9 ff ff       	call   100f59 <serial_init>
    kbd_init();
  1015f7:	e8 d1 ff ff ff       	call   1015cd <kbd_init>
    if (!serial_exists) {
  1015fc:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101601:	85 c0                	test   %eax,%eax
  101603:	75 0c                	jne    101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101605:	c7 04 24 f9 62 10 00 	movl   $0x1062f9,(%esp)
  10160c:	e8 81 ec ff ff       	call   100292 <cprintf>
    }
}
  101611:	90                   	nop
  101612:	c9                   	leave  
  101613:	c3                   	ret    

00101614 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101614:	55                   	push   %ebp
  101615:	89 e5                	mov    %esp,%ebp
  101617:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10161a:	e8 cf f7 ff ff       	call   100dee <__intr_save>
  10161f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101622:	8b 45 08             	mov    0x8(%ebp),%eax
  101625:	89 04 24             	mov    %eax,(%esp)
  101628:	e8 89 fa ff ff       	call   1010b6 <lpt_putc>
        cga_putc(c);
  10162d:	8b 45 08             	mov    0x8(%ebp),%eax
  101630:	89 04 24             	mov    %eax,(%esp)
  101633:	e8 be fa ff ff       	call   1010f6 <cga_putc>
        serial_putc(c);
  101638:	8b 45 08             	mov    0x8(%ebp),%eax
  10163b:	89 04 24             	mov    %eax,(%esp)
  10163e:	e8 f0 fc ff ff       	call   101333 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101646:	89 04 24             	mov    %eax,(%esp)
  101649:	e8 ca f7 ff ff       	call   100e18 <__intr_restore>
}
  10164e:	90                   	nop
  10164f:	c9                   	leave  
  101650:	c3                   	ret    

00101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101651:	55                   	push   %ebp
  101652:	89 e5                	mov    %esp,%ebp
  101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10165e:	e8 8b f7 ff ff       	call   100dee <__intr_save>
  101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101666:	e8 ab fd ff ff       	call   101416 <serial_intr>
        kbd_intr();
  10166b:	e8 48 ff ff ff       	call   1015b8 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101670:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101676:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10167b:	39 c2                	cmp    %eax,%edx
  10167d:	74 31                	je     1016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167f:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101684:	8d 50 01             	lea    0x1(%eax),%edx
  101687:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  10168d:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101694:	0f b6 c0             	movzbl %al,%eax
  101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10169a:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169f:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a4:	75 0a                	jne    1016b0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016a6:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016b3:	89 04 24             	mov    %eax,(%esp)
  1016b6:	e8 5d f7 ff ff       	call   100e18 <__intr_restore>
    return c;
  1016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016be:	c9                   	leave  
  1016bf:	c3                   	ret    

001016c0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016c0:	55                   	push   %ebp
  1016c1:	89 e5                	mov    %esp,%ebp
  1016c3:	83 ec 14             	sub    $0x14,%esp
  1016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1016c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016d0:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016d6:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016db:	85 c0                	test   %eax,%eax
  1016dd:	74 37                	je     101716 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016e2:	0f b6 c0             	movzbl %al,%eax
  1016e5:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1016eb:	88 45 f9             	mov    %al,-0x7(%ebp)
  1016ee:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016f2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016fb:	c1 e8 08             	shr    $0x8,%eax
  1016fe:	0f b7 c0             	movzwl %ax,%eax
  101701:	0f b6 c0             	movzbl %al,%eax
  101704:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10170a:	88 45 fd             	mov    %al,-0x3(%ebp)
  10170d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101711:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101715:	ee                   	out    %al,(%dx)
    }
}
  101716:	90                   	nop
  101717:	c9                   	leave  
  101718:	c3                   	ret    

00101719 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101719:	55                   	push   %ebp
  10171a:	89 e5                	mov    %esp,%ebp
  10171c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10171f:	8b 45 08             	mov    0x8(%ebp),%eax
  101722:	ba 01 00 00 00       	mov    $0x1,%edx
  101727:	88 c1                	mov    %al,%cl
  101729:	d3 e2                	shl    %cl,%edx
  10172b:	89 d0                	mov    %edx,%eax
  10172d:	98                   	cwtl   
  10172e:	f7 d0                	not    %eax
  101730:	0f bf d0             	movswl %ax,%edx
  101733:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10173a:	98                   	cwtl   
  10173b:	21 d0                	and    %edx,%eax
  10173d:	98                   	cwtl   
  10173e:	0f b7 c0             	movzwl %ax,%eax
  101741:	89 04 24             	mov    %eax,(%esp)
  101744:	e8 77 ff ff ff       	call   1016c0 <pic_setmask>
}
  101749:	90                   	nop
  10174a:	c9                   	leave  
  10174b:	c3                   	ret    

0010174c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10174c:	55                   	push   %ebp
  10174d:	89 e5                	mov    %esp,%ebp
  10174f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101752:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  101759:	00 00 00 
  10175c:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101762:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  101766:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10176a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10176e:	ee                   	out    %al,(%dx)
  10176f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101775:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  101779:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10177d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101781:	ee                   	out    %al,(%dx)
  101782:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101788:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  10178c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101790:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101794:	ee                   	out    %al,(%dx)
  101795:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  10179b:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  10179f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017a3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017a7:	ee                   	out    %al,(%dx)
  1017a8:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017ae:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  1017b2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017b6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017ba:	ee                   	out    %al,(%dx)
  1017bb:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017c1:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  1017c5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017c9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017cd:	ee                   	out    %al,(%dx)
  1017ce:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1017d4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  1017d8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017dc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017e0:	ee                   	out    %al,(%dx)
  1017e1:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1017e7:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  1017eb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017ef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017f3:	ee                   	out    %al,(%dx)
  1017f4:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  1017fa:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  1017fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101802:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101806:	ee                   	out    %al,(%dx)
  101807:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10180d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101811:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101815:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101819:	ee                   	out    %al,(%dx)
  10181a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101820:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  101824:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101828:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10182c:	ee                   	out    %al,(%dx)
  10182d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101833:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  101837:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10183b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10183f:	ee                   	out    %al,(%dx)
  101840:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101846:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  10184a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10184e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101852:	ee                   	out    %al,(%dx)
  101853:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  101859:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  10185d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101861:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101865:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101866:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10186d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101872:	74 0f                	je     101883 <pic_init+0x137>
        pic_setmask(irq_mask);
  101874:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10187b:	89 04 24             	mov    %eax,(%esp)
  10187e:	e8 3d fe ff ff       	call   1016c0 <pic_setmask>
    }
}
  101883:	90                   	nop
  101884:	c9                   	leave  
  101885:	c3                   	ret    

00101886 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101886:	55                   	push   %ebp
  101887:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101889:	fb                   	sti    
    sti();
}
  10188a:	90                   	nop
  10188b:	5d                   	pop    %ebp
  10188c:	c3                   	ret    

0010188d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10188d:	55                   	push   %ebp
  10188e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101890:	fa                   	cli    
    cli();
}
  101891:	90                   	nop
  101892:	5d                   	pop    %ebp
  101893:	c3                   	ret    

00101894 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101894:	55                   	push   %ebp
  101895:	89 e5                	mov    %esp,%ebp
  101897:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10189a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018a1:	00 
  1018a2:	c7 04 24 20 63 10 00 	movl   $0x106320,(%esp)
  1018a9:	e8 e4 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018ae:	90                   	nop
  1018af:	c9                   	leave  
  1018b0:	c3                   	ret    

001018b1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018b1:	55                   	push   %ebp
  1018b2:	89 e5                	mov    %esp,%ebp
  1018b4:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      for(int i = 0; i < (sizeof(idt)/sizeof(struct gatedesc)); i++) {
  1018b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018be:	e9 4f 01 00 00       	jmp    101a12 <idt_init+0x161>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c6:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018cd:	0f b7 d0             	movzwl %ax,%edx
  1018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d3:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018da:	00 
  1018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018de:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018e5:	00 08 00 
  1018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018eb:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018f2:	00 
  1018f3:	80 e2 e0             	and    $0xe0,%dl
  1018f6:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101900:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  101907:	00 
  101908:	80 e2 1f             	and    $0x1f,%dl
  10190b:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101915:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10191c:	00 
  10191d:	80 e2 f0             	and    $0xf0,%dl
  101920:	80 ca 0e             	or     $0xe,%dl
  101923:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192d:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101934:	00 
  101935:	80 e2 ef             	and    $0xef,%dl
  101938:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10193f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101942:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101949:	00 
  10194a:	80 e2 9f             	and    $0x9f,%dl
  10194d:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101954:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101957:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10195e:	00 
  10195f:	80 ca 80             	or     $0x80,%dl
  101962:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101969:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196c:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101973:	c1 e8 10             	shr    $0x10,%eax
  101976:	0f b7 d0             	movzwl %ax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  101983:	00 
        SETGATE(idt[T_SYSCALL], 0, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
  101984:	a1 e0 77 11 00       	mov    0x1177e0,%eax
  101989:	0f b7 c0             	movzwl %ax,%eax
  10198c:	66 a3 80 aa 11 00    	mov    %ax,0x11aa80
  101992:	66 c7 05 82 aa 11 00 	movw   $0x8,0x11aa82
  101999:	08 00 
  10199b:	0f b6 05 84 aa 11 00 	movzbl 0x11aa84,%eax
  1019a2:	24 e0                	and    $0xe0,%al
  1019a4:	a2 84 aa 11 00       	mov    %al,0x11aa84
  1019a9:	0f b6 05 84 aa 11 00 	movzbl 0x11aa84,%eax
  1019b0:	24 1f                	and    $0x1f,%al
  1019b2:	a2 84 aa 11 00       	mov    %al,0x11aa84
  1019b7:	0f b6 05 85 aa 11 00 	movzbl 0x11aa85,%eax
  1019be:	24 f0                	and    $0xf0,%al
  1019c0:	0c 0e                	or     $0xe,%al
  1019c2:	a2 85 aa 11 00       	mov    %al,0x11aa85
  1019c7:	0f b6 05 85 aa 11 00 	movzbl 0x11aa85,%eax
  1019ce:	24 ef                	and    $0xef,%al
  1019d0:	a2 85 aa 11 00       	mov    %al,0x11aa85
  1019d5:	0f b6 05 85 aa 11 00 	movzbl 0x11aa85,%eax
  1019dc:	0c 60                	or     $0x60,%al
  1019de:	a2 85 aa 11 00       	mov    %al,0x11aa85
  1019e3:	0f b6 05 85 aa 11 00 	movzbl 0x11aa85,%eax
  1019ea:	0c 80                	or     $0x80,%al
  1019ec:	a2 85 aa 11 00       	mov    %al,0x11aa85
  1019f1:	a1 e0 77 11 00       	mov    0x1177e0,%eax
  1019f6:	c1 e8 10             	shr    $0x10,%eax
  1019f9:	0f b7 c0             	movzwl %ax,%eax
  1019fc:	66 a3 86 aa 11 00    	mov    %ax,0x11aa86
  101a02:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a0c:	0f 01 18             	lidtl  (%eax)
      for(int i = 0; i < (sizeof(idt)/sizeof(struct gatedesc)); i++) {
  101a0f:	ff 45 fc             	incl   -0x4(%ebp)
  101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a15:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a1a:	0f 86 a3 fe ff ff    	jbe    1018c3 <idt_init+0x12>
        lidt(&idt_pd);
      }
}
  101a20:	90                   	nop
  101a21:	c9                   	leave  
  101a22:	c3                   	ret    

00101a23 <trapname>:

static const char *
trapname(int trapno) {
  101a23:	55                   	push   %ebp
  101a24:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a26:	8b 45 08             	mov    0x8(%ebp),%eax
  101a29:	83 f8 13             	cmp    $0x13,%eax
  101a2c:	77 0c                	ja     101a3a <trapname+0x17>
        return excnames[trapno];
  101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a31:	8b 04 85 80 66 10 00 	mov    0x106680(,%eax,4),%eax
  101a38:	eb 18                	jmp    101a52 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a3a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a3e:	7e 0d                	jle    101a4d <trapname+0x2a>
  101a40:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a44:	7f 07                	jg     101a4d <trapname+0x2a>
        return "Hardware Interrupt";
  101a46:	b8 2a 63 10 00       	mov    $0x10632a,%eax
  101a4b:	eb 05                	jmp    101a52 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a4d:	b8 3d 63 10 00       	mov    $0x10633d,%eax
}
  101a52:	5d                   	pop    %ebp
  101a53:	c3                   	ret    

00101a54 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a54:	55                   	push   %ebp
  101a55:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a57:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a5e:	83 f8 08             	cmp    $0x8,%eax
  101a61:	0f 94 c0             	sete   %al
  101a64:	0f b6 c0             	movzbl %al,%eax
}
  101a67:	5d                   	pop    %ebp
  101a68:	c3                   	ret    

00101a69 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a69:	55                   	push   %ebp
  101a6a:	89 e5                	mov    %esp,%ebp
  101a6c:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a76:	c7 04 24 7e 63 10 00 	movl   $0x10637e,(%esp)
  101a7d:	e8 10 e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a82:	8b 45 08             	mov    0x8(%ebp),%eax
  101a85:	89 04 24             	mov    %eax,(%esp)
  101a88:	e8 8f 01 00 00       	call   101c1c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a90:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a98:	c7 04 24 8f 63 10 00 	movl   $0x10638f,(%esp)
  101a9f:	e8 ee e7 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa7:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aaf:	c7 04 24 a2 63 10 00 	movl   $0x1063a2,(%esp)
  101ab6:	e8 d7 e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101abb:	8b 45 08             	mov    0x8(%ebp),%eax
  101abe:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac6:	c7 04 24 b5 63 10 00 	movl   $0x1063b5,(%esp)
  101acd:	e8 c0 e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101add:	c7 04 24 c8 63 10 00 	movl   $0x1063c8,(%esp)
  101ae4:	e8 a9 e7 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  101aec:	8b 40 30             	mov    0x30(%eax),%eax
  101aef:	89 04 24             	mov    %eax,(%esp)
  101af2:	e8 2c ff ff ff       	call   101a23 <trapname>
  101af7:	89 c2                	mov    %eax,%edx
  101af9:	8b 45 08             	mov    0x8(%ebp),%eax
  101afc:	8b 40 30             	mov    0x30(%eax),%eax
  101aff:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b07:	c7 04 24 db 63 10 00 	movl   $0x1063db,(%esp)
  101b0e:	e8 7f e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b13:	8b 45 08             	mov    0x8(%ebp),%eax
  101b16:	8b 40 34             	mov    0x34(%eax),%eax
  101b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1d:	c7 04 24 ed 63 10 00 	movl   $0x1063ed,(%esp)
  101b24:	e8 69 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b29:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2c:	8b 40 38             	mov    0x38(%eax),%eax
  101b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b33:	c7 04 24 fc 63 10 00 	movl   $0x1063fc,(%esp)
  101b3a:	e8 53 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4a:	c7 04 24 0b 64 10 00 	movl   $0x10640b,(%esp)
  101b51:	e8 3c e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b56:	8b 45 08             	mov    0x8(%ebp),%eax
  101b59:	8b 40 40             	mov    0x40(%eax),%eax
  101b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b60:	c7 04 24 1e 64 10 00 	movl   $0x10641e,(%esp)
  101b67:	e8 26 e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b73:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b7a:	eb 3d                	jmp    101bb9 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7f:	8b 50 40             	mov    0x40(%eax),%edx
  101b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b85:	21 d0                	and    %edx,%eax
  101b87:	85 c0                	test   %eax,%eax
  101b89:	74 28                	je     101bb3 <print_trapframe+0x14a>
  101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b8e:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b95:	85 c0                	test   %eax,%eax
  101b97:	74 1a                	je     101bb3 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b9c:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba7:	c7 04 24 2d 64 10 00 	movl   $0x10642d,(%esp)
  101bae:	e8 df e6 ff ff       	call   100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bb3:	ff 45 f4             	incl   -0xc(%ebp)
  101bb6:	d1 65 f0             	shll   -0x10(%ebp)
  101bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bbc:	83 f8 17             	cmp    $0x17,%eax
  101bbf:	76 bb                	jbe    101b7c <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc4:	8b 40 40             	mov    0x40(%eax),%eax
  101bc7:	c1 e8 0c             	shr    $0xc,%eax
  101bca:	83 e0 03             	and    $0x3,%eax
  101bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd1:	c7 04 24 31 64 10 00 	movl   $0x106431,(%esp)
  101bd8:	e8 b5 e6 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  101be0:	89 04 24             	mov    %eax,(%esp)
  101be3:	e8 6c fe ff ff       	call   101a54 <trap_in_kernel>
  101be8:	85 c0                	test   %eax,%eax
  101bea:	75 2d                	jne    101c19 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101bec:	8b 45 08             	mov    0x8(%ebp),%eax
  101bef:	8b 40 44             	mov    0x44(%eax),%eax
  101bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf6:	c7 04 24 3a 64 10 00 	movl   $0x10643a,(%esp)
  101bfd:	e8 90 e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c02:	8b 45 08             	mov    0x8(%ebp),%eax
  101c05:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0d:	c7 04 24 49 64 10 00 	movl   $0x106449,(%esp)
  101c14:	e8 79 e6 ff ff       	call   100292 <cprintf>
    }
}
  101c19:	90                   	nop
  101c1a:	c9                   	leave  
  101c1b:	c3                   	ret    

00101c1c <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c1c:	55                   	push   %ebp
  101c1d:	89 e5                	mov    %esp,%ebp
  101c1f:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c22:	8b 45 08             	mov    0x8(%ebp),%eax
  101c25:	8b 00                	mov    (%eax),%eax
  101c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2b:	c7 04 24 5c 64 10 00 	movl   $0x10645c,(%esp)
  101c32:	e8 5b e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c37:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3a:	8b 40 04             	mov    0x4(%eax),%eax
  101c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c41:	c7 04 24 6b 64 10 00 	movl   $0x10646b,(%esp)
  101c48:	e8 45 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c50:	8b 40 08             	mov    0x8(%eax),%eax
  101c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c57:	c7 04 24 7a 64 10 00 	movl   $0x10647a,(%esp)
  101c5e:	e8 2f e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c63:	8b 45 08             	mov    0x8(%ebp),%eax
  101c66:	8b 40 0c             	mov    0xc(%eax),%eax
  101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6d:	c7 04 24 89 64 10 00 	movl   $0x106489,(%esp)
  101c74:	e8 19 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c79:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7c:	8b 40 10             	mov    0x10(%eax),%eax
  101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c83:	c7 04 24 98 64 10 00 	movl   $0x106498,(%esp)
  101c8a:	e8 03 e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c92:	8b 40 14             	mov    0x14(%eax),%eax
  101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c99:	c7 04 24 a7 64 10 00 	movl   $0x1064a7,(%esp)
  101ca0:	e8 ed e5 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca8:	8b 40 18             	mov    0x18(%eax),%eax
  101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101caf:	c7 04 24 b6 64 10 00 	movl   $0x1064b6,(%esp)
  101cb6:	e8 d7 e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbe:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc5:	c7 04 24 c5 64 10 00 	movl   $0x1064c5,(%esp)
  101ccc:	e8 c1 e5 ff ff       	call   100292 <cprintf>
}
  101cd1:	90                   	nop
  101cd2:	c9                   	leave  
  101cd3:	c3                   	ret    

00101cd4 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cd4:	55                   	push   %ebp
  101cd5:	89 e5                	mov    %esp,%ebp
  101cd7:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101cda:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdd:	8b 40 30             	mov    0x30(%eax),%eax
  101ce0:	83 f8 2f             	cmp    $0x2f,%eax
  101ce3:	77 21                	ja     101d06 <trap_dispatch+0x32>
  101ce5:	83 f8 2e             	cmp    $0x2e,%eax
  101ce8:	0f 83 16 01 00 00    	jae    101e04 <trap_dispatch+0x130>
  101cee:	83 f8 21             	cmp    $0x21,%eax
  101cf1:	0f 84 96 00 00 00    	je     101d8d <trap_dispatch+0xb9>
  101cf7:	83 f8 24             	cmp    $0x24,%eax
  101cfa:	74 6b                	je     101d67 <trap_dispatch+0x93>
  101cfc:	83 f8 20             	cmp    $0x20,%eax
  101cff:	74 16                	je     101d17 <trap_dispatch+0x43>
  101d01:	e9 c9 00 00 00       	jmp    101dcf <trap_dispatch+0xfb>
  101d06:	83 e8 78             	sub    $0x78,%eax
  101d09:	83 f8 01             	cmp    $0x1,%eax
  101d0c:	0f 87 bd 00 00 00    	ja     101dcf <trap_dispatch+0xfb>
  101d12:	e9 9c 00 00 00       	jmp    101db3 <trap_dispatch+0xdf>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
         ticks++;
  101d17:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d1c:	40                   	inc    %eax
  101d1d:	a3 0c af 11 00       	mov    %eax,0x11af0c
         if(ticks % TICK_NUM == 0) {
  101d22:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101d28:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d2d:	89 c8                	mov    %ecx,%eax
  101d2f:	f7 e2                	mul    %edx
  101d31:	c1 ea 05             	shr    $0x5,%edx
  101d34:	89 d0                	mov    %edx,%eax
  101d36:	c1 e0 02             	shl    $0x2,%eax
  101d39:	01 d0                	add    %edx,%eax
  101d3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d42:	01 d0                	add    %edx,%eax
  101d44:	c1 e0 02             	shl    $0x2,%eax
  101d47:	29 c1                	sub    %eax,%ecx
  101d49:	89 ca                	mov    %ecx,%edx
  101d4b:	85 d2                	test   %edx,%edx
  101d4d:	0f 85 b4 00 00 00    	jne    101e07 <trap_dispatch+0x133>
             print_ticks();
  101d53:	e8 3c fb ff ff       	call   101894 <print_ticks>
             ticks = 0;
  101d58:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  101d5f:	00 00 00 
         }
        break;
  101d62:	e9 a0 00 00 00       	jmp    101e07 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d67:	e8 e5 f8 ff ff       	call   101651 <cons_getc>
  101d6c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d6f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d73:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d77:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d7f:	c7 04 24 d4 64 10 00 	movl   $0x1064d4,(%esp)
  101d86:	e8 07 e5 ff ff       	call   100292 <cprintf>
        break;
  101d8b:	eb 7b                	jmp    101e08 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d8d:	e8 bf f8 ff ff       	call   101651 <cons_getc>
  101d92:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d95:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d99:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d9d:	89 54 24 08          	mov    %edx,0x8(%esp)
  101da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da5:	c7 04 24 e6 64 10 00 	movl   $0x1064e6,(%esp)
  101dac:	e8 e1 e4 ff ff       	call   100292 <cprintf>
        break;
  101db1:	eb 55                	jmp    101e08 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101db3:	c7 44 24 08 f5 64 10 	movl   $0x1064f5,0x8(%esp)
  101dba:	00 
  101dbb:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  101dc2:	00 
  101dc3:	c7 04 24 05 65 10 00 	movl   $0x106505,(%esp)
  101dca:	e8 1a e6 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dd6:	83 e0 03             	and    $0x3,%eax
  101dd9:	85 c0                	test   %eax,%eax
  101ddb:	75 2b                	jne    101e08 <trap_dispatch+0x134>
            print_trapframe(tf);
  101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  101de0:	89 04 24             	mov    %eax,(%esp)
  101de3:	e8 81 fc ff ff       	call   101a69 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101de8:	c7 44 24 08 16 65 10 	movl   $0x106516,0x8(%esp)
  101def:	00 
  101df0:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101df7:	00 
  101df8:	c7 04 24 05 65 10 00 	movl   $0x106505,(%esp)
  101dff:	e8 e5 e5 ff ff       	call   1003e9 <__panic>
        break;
  101e04:	90                   	nop
  101e05:	eb 01                	jmp    101e08 <trap_dispatch+0x134>
        break;
  101e07:	90                   	nop
        }
    }
}
  101e08:	90                   	nop
  101e09:	c9                   	leave  
  101e0a:	c3                   	ret    

00101e0b <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e0b:	55                   	push   %ebp
  101e0c:	89 e5                	mov    %esp,%ebp
  101e0e:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e11:	8b 45 08             	mov    0x8(%ebp),%eax
  101e14:	89 04 24             	mov    %eax,(%esp)
  101e17:	e8 b8 fe ff ff       	call   101cd4 <trap_dispatch>
}
  101e1c:	90                   	nop
  101e1d:	c9                   	leave  
  101e1e:	c3                   	ret    

00101e1f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e1f:	6a 00                	push   $0x0
  pushl $0
  101e21:	6a 00                	push   $0x0
  jmp __alltraps
  101e23:	e9 69 0a 00 00       	jmp    102891 <__alltraps>

00101e28 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e28:	6a 00                	push   $0x0
  pushl $1
  101e2a:	6a 01                	push   $0x1
  jmp __alltraps
  101e2c:	e9 60 0a 00 00       	jmp    102891 <__alltraps>

00101e31 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e31:	6a 00                	push   $0x0
  pushl $2
  101e33:	6a 02                	push   $0x2
  jmp __alltraps
  101e35:	e9 57 0a 00 00       	jmp    102891 <__alltraps>

00101e3a <vector3>:
.globl vector3
vector3:
  pushl $0
  101e3a:	6a 00                	push   $0x0
  pushl $3
  101e3c:	6a 03                	push   $0x3
  jmp __alltraps
  101e3e:	e9 4e 0a 00 00       	jmp    102891 <__alltraps>

00101e43 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e43:	6a 00                	push   $0x0
  pushl $4
  101e45:	6a 04                	push   $0x4
  jmp __alltraps
  101e47:	e9 45 0a 00 00       	jmp    102891 <__alltraps>

00101e4c <vector5>:
.globl vector5
vector5:
  pushl $0
  101e4c:	6a 00                	push   $0x0
  pushl $5
  101e4e:	6a 05                	push   $0x5
  jmp __alltraps
  101e50:	e9 3c 0a 00 00       	jmp    102891 <__alltraps>

00101e55 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e55:	6a 00                	push   $0x0
  pushl $6
  101e57:	6a 06                	push   $0x6
  jmp __alltraps
  101e59:	e9 33 0a 00 00       	jmp    102891 <__alltraps>

00101e5e <vector7>:
.globl vector7
vector7:
  pushl $0
  101e5e:	6a 00                	push   $0x0
  pushl $7
  101e60:	6a 07                	push   $0x7
  jmp __alltraps
  101e62:	e9 2a 0a 00 00       	jmp    102891 <__alltraps>

00101e67 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e67:	6a 08                	push   $0x8
  jmp __alltraps
  101e69:	e9 23 0a 00 00       	jmp    102891 <__alltraps>

00101e6e <vector9>:
.globl vector9
vector9:
  pushl $0
  101e6e:	6a 00                	push   $0x0
  pushl $9
  101e70:	6a 09                	push   $0x9
  jmp __alltraps
  101e72:	e9 1a 0a 00 00       	jmp    102891 <__alltraps>

00101e77 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e77:	6a 0a                	push   $0xa
  jmp __alltraps
  101e79:	e9 13 0a 00 00       	jmp    102891 <__alltraps>

00101e7e <vector11>:
.globl vector11
vector11:
  pushl $11
  101e7e:	6a 0b                	push   $0xb
  jmp __alltraps
  101e80:	e9 0c 0a 00 00       	jmp    102891 <__alltraps>

00101e85 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e85:	6a 0c                	push   $0xc
  jmp __alltraps
  101e87:	e9 05 0a 00 00       	jmp    102891 <__alltraps>

00101e8c <vector13>:
.globl vector13
vector13:
  pushl $13
  101e8c:	6a 0d                	push   $0xd
  jmp __alltraps
  101e8e:	e9 fe 09 00 00       	jmp    102891 <__alltraps>

00101e93 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e93:	6a 0e                	push   $0xe
  jmp __alltraps
  101e95:	e9 f7 09 00 00       	jmp    102891 <__alltraps>

00101e9a <vector15>:
.globl vector15
vector15:
  pushl $0
  101e9a:	6a 00                	push   $0x0
  pushl $15
  101e9c:	6a 0f                	push   $0xf
  jmp __alltraps
  101e9e:	e9 ee 09 00 00       	jmp    102891 <__alltraps>

00101ea3 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ea3:	6a 00                	push   $0x0
  pushl $16
  101ea5:	6a 10                	push   $0x10
  jmp __alltraps
  101ea7:	e9 e5 09 00 00       	jmp    102891 <__alltraps>

00101eac <vector17>:
.globl vector17
vector17:
  pushl $17
  101eac:	6a 11                	push   $0x11
  jmp __alltraps
  101eae:	e9 de 09 00 00       	jmp    102891 <__alltraps>

00101eb3 <vector18>:
.globl vector18
vector18:
  pushl $0
  101eb3:	6a 00                	push   $0x0
  pushl $18
  101eb5:	6a 12                	push   $0x12
  jmp __alltraps
  101eb7:	e9 d5 09 00 00       	jmp    102891 <__alltraps>

00101ebc <vector19>:
.globl vector19
vector19:
  pushl $0
  101ebc:	6a 00                	push   $0x0
  pushl $19
  101ebe:	6a 13                	push   $0x13
  jmp __alltraps
  101ec0:	e9 cc 09 00 00       	jmp    102891 <__alltraps>

00101ec5 <vector20>:
.globl vector20
vector20:
  pushl $0
  101ec5:	6a 00                	push   $0x0
  pushl $20
  101ec7:	6a 14                	push   $0x14
  jmp __alltraps
  101ec9:	e9 c3 09 00 00       	jmp    102891 <__alltraps>

00101ece <vector21>:
.globl vector21
vector21:
  pushl $0
  101ece:	6a 00                	push   $0x0
  pushl $21
  101ed0:	6a 15                	push   $0x15
  jmp __alltraps
  101ed2:	e9 ba 09 00 00       	jmp    102891 <__alltraps>

00101ed7 <vector22>:
.globl vector22
vector22:
  pushl $0
  101ed7:	6a 00                	push   $0x0
  pushl $22
  101ed9:	6a 16                	push   $0x16
  jmp __alltraps
  101edb:	e9 b1 09 00 00       	jmp    102891 <__alltraps>

00101ee0 <vector23>:
.globl vector23
vector23:
  pushl $0
  101ee0:	6a 00                	push   $0x0
  pushl $23
  101ee2:	6a 17                	push   $0x17
  jmp __alltraps
  101ee4:	e9 a8 09 00 00       	jmp    102891 <__alltraps>

00101ee9 <vector24>:
.globl vector24
vector24:
  pushl $0
  101ee9:	6a 00                	push   $0x0
  pushl $24
  101eeb:	6a 18                	push   $0x18
  jmp __alltraps
  101eed:	e9 9f 09 00 00       	jmp    102891 <__alltraps>

00101ef2 <vector25>:
.globl vector25
vector25:
  pushl $0
  101ef2:	6a 00                	push   $0x0
  pushl $25
  101ef4:	6a 19                	push   $0x19
  jmp __alltraps
  101ef6:	e9 96 09 00 00       	jmp    102891 <__alltraps>

00101efb <vector26>:
.globl vector26
vector26:
  pushl $0
  101efb:	6a 00                	push   $0x0
  pushl $26
  101efd:	6a 1a                	push   $0x1a
  jmp __alltraps
  101eff:	e9 8d 09 00 00       	jmp    102891 <__alltraps>

00101f04 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f04:	6a 00                	push   $0x0
  pushl $27
  101f06:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f08:	e9 84 09 00 00       	jmp    102891 <__alltraps>

00101f0d <vector28>:
.globl vector28
vector28:
  pushl $0
  101f0d:	6a 00                	push   $0x0
  pushl $28
  101f0f:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f11:	e9 7b 09 00 00       	jmp    102891 <__alltraps>

00101f16 <vector29>:
.globl vector29
vector29:
  pushl $0
  101f16:	6a 00                	push   $0x0
  pushl $29
  101f18:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f1a:	e9 72 09 00 00       	jmp    102891 <__alltraps>

00101f1f <vector30>:
.globl vector30
vector30:
  pushl $0
  101f1f:	6a 00                	push   $0x0
  pushl $30
  101f21:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f23:	e9 69 09 00 00       	jmp    102891 <__alltraps>

00101f28 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $31
  101f2a:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f2c:	e9 60 09 00 00       	jmp    102891 <__alltraps>

00101f31 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f31:	6a 00                	push   $0x0
  pushl $32
  101f33:	6a 20                	push   $0x20
  jmp __alltraps
  101f35:	e9 57 09 00 00       	jmp    102891 <__alltraps>

00101f3a <vector33>:
.globl vector33
vector33:
  pushl $0
  101f3a:	6a 00                	push   $0x0
  pushl $33
  101f3c:	6a 21                	push   $0x21
  jmp __alltraps
  101f3e:	e9 4e 09 00 00       	jmp    102891 <__alltraps>

00101f43 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $34
  101f45:	6a 22                	push   $0x22
  jmp __alltraps
  101f47:	e9 45 09 00 00       	jmp    102891 <__alltraps>

00101f4c <vector35>:
.globl vector35
vector35:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $35
  101f4e:	6a 23                	push   $0x23
  jmp __alltraps
  101f50:	e9 3c 09 00 00       	jmp    102891 <__alltraps>

00101f55 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f55:	6a 00                	push   $0x0
  pushl $36
  101f57:	6a 24                	push   $0x24
  jmp __alltraps
  101f59:	e9 33 09 00 00       	jmp    102891 <__alltraps>

00101f5e <vector37>:
.globl vector37
vector37:
  pushl $0
  101f5e:	6a 00                	push   $0x0
  pushl $37
  101f60:	6a 25                	push   $0x25
  jmp __alltraps
  101f62:	e9 2a 09 00 00       	jmp    102891 <__alltraps>

00101f67 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f67:	6a 00                	push   $0x0
  pushl $38
  101f69:	6a 26                	push   $0x26
  jmp __alltraps
  101f6b:	e9 21 09 00 00       	jmp    102891 <__alltraps>

00101f70 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f70:	6a 00                	push   $0x0
  pushl $39
  101f72:	6a 27                	push   $0x27
  jmp __alltraps
  101f74:	e9 18 09 00 00       	jmp    102891 <__alltraps>

00101f79 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f79:	6a 00                	push   $0x0
  pushl $40
  101f7b:	6a 28                	push   $0x28
  jmp __alltraps
  101f7d:	e9 0f 09 00 00       	jmp    102891 <__alltraps>

00101f82 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f82:	6a 00                	push   $0x0
  pushl $41
  101f84:	6a 29                	push   $0x29
  jmp __alltraps
  101f86:	e9 06 09 00 00       	jmp    102891 <__alltraps>

00101f8b <vector42>:
.globl vector42
vector42:
  pushl $0
  101f8b:	6a 00                	push   $0x0
  pushl $42
  101f8d:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f8f:	e9 fd 08 00 00       	jmp    102891 <__alltraps>

00101f94 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f94:	6a 00                	push   $0x0
  pushl $43
  101f96:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f98:	e9 f4 08 00 00       	jmp    102891 <__alltraps>

00101f9d <vector44>:
.globl vector44
vector44:
  pushl $0
  101f9d:	6a 00                	push   $0x0
  pushl $44
  101f9f:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fa1:	e9 eb 08 00 00       	jmp    102891 <__alltraps>

00101fa6 <vector45>:
.globl vector45
vector45:
  pushl $0
  101fa6:	6a 00                	push   $0x0
  pushl $45
  101fa8:	6a 2d                	push   $0x2d
  jmp __alltraps
  101faa:	e9 e2 08 00 00       	jmp    102891 <__alltraps>

00101faf <vector46>:
.globl vector46
vector46:
  pushl $0
  101faf:	6a 00                	push   $0x0
  pushl $46
  101fb1:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fb3:	e9 d9 08 00 00       	jmp    102891 <__alltraps>

00101fb8 <vector47>:
.globl vector47
vector47:
  pushl $0
  101fb8:	6a 00                	push   $0x0
  pushl $47
  101fba:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fbc:	e9 d0 08 00 00       	jmp    102891 <__alltraps>

00101fc1 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fc1:	6a 00                	push   $0x0
  pushl $48
  101fc3:	6a 30                	push   $0x30
  jmp __alltraps
  101fc5:	e9 c7 08 00 00       	jmp    102891 <__alltraps>

00101fca <vector49>:
.globl vector49
vector49:
  pushl $0
  101fca:	6a 00                	push   $0x0
  pushl $49
  101fcc:	6a 31                	push   $0x31
  jmp __alltraps
  101fce:	e9 be 08 00 00       	jmp    102891 <__alltraps>

00101fd3 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fd3:	6a 00                	push   $0x0
  pushl $50
  101fd5:	6a 32                	push   $0x32
  jmp __alltraps
  101fd7:	e9 b5 08 00 00       	jmp    102891 <__alltraps>

00101fdc <vector51>:
.globl vector51
vector51:
  pushl $0
  101fdc:	6a 00                	push   $0x0
  pushl $51
  101fde:	6a 33                	push   $0x33
  jmp __alltraps
  101fe0:	e9 ac 08 00 00       	jmp    102891 <__alltraps>

00101fe5 <vector52>:
.globl vector52
vector52:
  pushl $0
  101fe5:	6a 00                	push   $0x0
  pushl $52
  101fe7:	6a 34                	push   $0x34
  jmp __alltraps
  101fe9:	e9 a3 08 00 00       	jmp    102891 <__alltraps>

00101fee <vector53>:
.globl vector53
vector53:
  pushl $0
  101fee:	6a 00                	push   $0x0
  pushl $53
  101ff0:	6a 35                	push   $0x35
  jmp __alltraps
  101ff2:	e9 9a 08 00 00       	jmp    102891 <__alltraps>

00101ff7 <vector54>:
.globl vector54
vector54:
  pushl $0
  101ff7:	6a 00                	push   $0x0
  pushl $54
  101ff9:	6a 36                	push   $0x36
  jmp __alltraps
  101ffb:	e9 91 08 00 00       	jmp    102891 <__alltraps>

00102000 <vector55>:
.globl vector55
vector55:
  pushl $0
  102000:	6a 00                	push   $0x0
  pushl $55
  102002:	6a 37                	push   $0x37
  jmp __alltraps
  102004:	e9 88 08 00 00       	jmp    102891 <__alltraps>

00102009 <vector56>:
.globl vector56
vector56:
  pushl $0
  102009:	6a 00                	push   $0x0
  pushl $56
  10200b:	6a 38                	push   $0x38
  jmp __alltraps
  10200d:	e9 7f 08 00 00       	jmp    102891 <__alltraps>

00102012 <vector57>:
.globl vector57
vector57:
  pushl $0
  102012:	6a 00                	push   $0x0
  pushl $57
  102014:	6a 39                	push   $0x39
  jmp __alltraps
  102016:	e9 76 08 00 00       	jmp    102891 <__alltraps>

0010201b <vector58>:
.globl vector58
vector58:
  pushl $0
  10201b:	6a 00                	push   $0x0
  pushl $58
  10201d:	6a 3a                	push   $0x3a
  jmp __alltraps
  10201f:	e9 6d 08 00 00       	jmp    102891 <__alltraps>

00102024 <vector59>:
.globl vector59
vector59:
  pushl $0
  102024:	6a 00                	push   $0x0
  pushl $59
  102026:	6a 3b                	push   $0x3b
  jmp __alltraps
  102028:	e9 64 08 00 00       	jmp    102891 <__alltraps>

0010202d <vector60>:
.globl vector60
vector60:
  pushl $0
  10202d:	6a 00                	push   $0x0
  pushl $60
  10202f:	6a 3c                	push   $0x3c
  jmp __alltraps
  102031:	e9 5b 08 00 00       	jmp    102891 <__alltraps>

00102036 <vector61>:
.globl vector61
vector61:
  pushl $0
  102036:	6a 00                	push   $0x0
  pushl $61
  102038:	6a 3d                	push   $0x3d
  jmp __alltraps
  10203a:	e9 52 08 00 00       	jmp    102891 <__alltraps>

0010203f <vector62>:
.globl vector62
vector62:
  pushl $0
  10203f:	6a 00                	push   $0x0
  pushl $62
  102041:	6a 3e                	push   $0x3e
  jmp __alltraps
  102043:	e9 49 08 00 00       	jmp    102891 <__alltraps>

00102048 <vector63>:
.globl vector63
vector63:
  pushl $0
  102048:	6a 00                	push   $0x0
  pushl $63
  10204a:	6a 3f                	push   $0x3f
  jmp __alltraps
  10204c:	e9 40 08 00 00       	jmp    102891 <__alltraps>

00102051 <vector64>:
.globl vector64
vector64:
  pushl $0
  102051:	6a 00                	push   $0x0
  pushl $64
  102053:	6a 40                	push   $0x40
  jmp __alltraps
  102055:	e9 37 08 00 00       	jmp    102891 <__alltraps>

0010205a <vector65>:
.globl vector65
vector65:
  pushl $0
  10205a:	6a 00                	push   $0x0
  pushl $65
  10205c:	6a 41                	push   $0x41
  jmp __alltraps
  10205e:	e9 2e 08 00 00       	jmp    102891 <__alltraps>

00102063 <vector66>:
.globl vector66
vector66:
  pushl $0
  102063:	6a 00                	push   $0x0
  pushl $66
  102065:	6a 42                	push   $0x42
  jmp __alltraps
  102067:	e9 25 08 00 00       	jmp    102891 <__alltraps>

0010206c <vector67>:
.globl vector67
vector67:
  pushl $0
  10206c:	6a 00                	push   $0x0
  pushl $67
  10206e:	6a 43                	push   $0x43
  jmp __alltraps
  102070:	e9 1c 08 00 00       	jmp    102891 <__alltraps>

00102075 <vector68>:
.globl vector68
vector68:
  pushl $0
  102075:	6a 00                	push   $0x0
  pushl $68
  102077:	6a 44                	push   $0x44
  jmp __alltraps
  102079:	e9 13 08 00 00       	jmp    102891 <__alltraps>

0010207e <vector69>:
.globl vector69
vector69:
  pushl $0
  10207e:	6a 00                	push   $0x0
  pushl $69
  102080:	6a 45                	push   $0x45
  jmp __alltraps
  102082:	e9 0a 08 00 00       	jmp    102891 <__alltraps>

00102087 <vector70>:
.globl vector70
vector70:
  pushl $0
  102087:	6a 00                	push   $0x0
  pushl $70
  102089:	6a 46                	push   $0x46
  jmp __alltraps
  10208b:	e9 01 08 00 00       	jmp    102891 <__alltraps>

00102090 <vector71>:
.globl vector71
vector71:
  pushl $0
  102090:	6a 00                	push   $0x0
  pushl $71
  102092:	6a 47                	push   $0x47
  jmp __alltraps
  102094:	e9 f8 07 00 00       	jmp    102891 <__alltraps>

00102099 <vector72>:
.globl vector72
vector72:
  pushl $0
  102099:	6a 00                	push   $0x0
  pushl $72
  10209b:	6a 48                	push   $0x48
  jmp __alltraps
  10209d:	e9 ef 07 00 00       	jmp    102891 <__alltraps>

001020a2 <vector73>:
.globl vector73
vector73:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $73
  1020a4:	6a 49                	push   $0x49
  jmp __alltraps
  1020a6:	e9 e6 07 00 00       	jmp    102891 <__alltraps>

001020ab <vector74>:
.globl vector74
vector74:
  pushl $0
  1020ab:	6a 00                	push   $0x0
  pushl $74
  1020ad:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020af:	e9 dd 07 00 00       	jmp    102891 <__alltraps>

001020b4 <vector75>:
.globl vector75
vector75:
  pushl $0
  1020b4:	6a 00                	push   $0x0
  pushl $75
  1020b6:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020b8:	e9 d4 07 00 00       	jmp    102891 <__alltraps>

001020bd <vector76>:
.globl vector76
vector76:
  pushl $0
  1020bd:	6a 00                	push   $0x0
  pushl $76
  1020bf:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020c1:	e9 cb 07 00 00       	jmp    102891 <__alltraps>

001020c6 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $77
  1020c8:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020ca:	e9 c2 07 00 00       	jmp    102891 <__alltraps>

001020cf <vector78>:
.globl vector78
vector78:
  pushl $0
  1020cf:	6a 00                	push   $0x0
  pushl $78
  1020d1:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020d3:	e9 b9 07 00 00       	jmp    102891 <__alltraps>

001020d8 <vector79>:
.globl vector79
vector79:
  pushl $0
  1020d8:	6a 00                	push   $0x0
  pushl $79
  1020da:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020dc:	e9 b0 07 00 00       	jmp    102891 <__alltraps>

001020e1 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020e1:	6a 00                	push   $0x0
  pushl $80
  1020e3:	6a 50                	push   $0x50
  jmp __alltraps
  1020e5:	e9 a7 07 00 00       	jmp    102891 <__alltraps>

001020ea <vector81>:
.globl vector81
vector81:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $81
  1020ec:	6a 51                	push   $0x51
  jmp __alltraps
  1020ee:	e9 9e 07 00 00       	jmp    102891 <__alltraps>

001020f3 <vector82>:
.globl vector82
vector82:
  pushl $0
  1020f3:	6a 00                	push   $0x0
  pushl $82
  1020f5:	6a 52                	push   $0x52
  jmp __alltraps
  1020f7:	e9 95 07 00 00       	jmp    102891 <__alltraps>

001020fc <vector83>:
.globl vector83
vector83:
  pushl $0
  1020fc:	6a 00                	push   $0x0
  pushl $83
  1020fe:	6a 53                	push   $0x53
  jmp __alltraps
  102100:	e9 8c 07 00 00       	jmp    102891 <__alltraps>

00102105 <vector84>:
.globl vector84
vector84:
  pushl $0
  102105:	6a 00                	push   $0x0
  pushl $84
  102107:	6a 54                	push   $0x54
  jmp __alltraps
  102109:	e9 83 07 00 00       	jmp    102891 <__alltraps>

0010210e <vector85>:
.globl vector85
vector85:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $85
  102110:	6a 55                	push   $0x55
  jmp __alltraps
  102112:	e9 7a 07 00 00       	jmp    102891 <__alltraps>

00102117 <vector86>:
.globl vector86
vector86:
  pushl $0
  102117:	6a 00                	push   $0x0
  pushl $86
  102119:	6a 56                	push   $0x56
  jmp __alltraps
  10211b:	e9 71 07 00 00       	jmp    102891 <__alltraps>

00102120 <vector87>:
.globl vector87
vector87:
  pushl $0
  102120:	6a 00                	push   $0x0
  pushl $87
  102122:	6a 57                	push   $0x57
  jmp __alltraps
  102124:	e9 68 07 00 00       	jmp    102891 <__alltraps>

00102129 <vector88>:
.globl vector88
vector88:
  pushl $0
  102129:	6a 00                	push   $0x0
  pushl $88
  10212b:	6a 58                	push   $0x58
  jmp __alltraps
  10212d:	e9 5f 07 00 00       	jmp    102891 <__alltraps>

00102132 <vector89>:
.globl vector89
vector89:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $89
  102134:	6a 59                	push   $0x59
  jmp __alltraps
  102136:	e9 56 07 00 00       	jmp    102891 <__alltraps>

0010213b <vector90>:
.globl vector90
vector90:
  pushl $0
  10213b:	6a 00                	push   $0x0
  pushl $90
  10213d:	6a 5a                	push   $0x5a
  jmp __alltraps
  10213f:	e9 4d 07 00 00       	jmp    102891 <__alltraps>

00102144 <vector91>:
.globl vector91
vector91:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $91
  102146:	6a 5b                	push   $0x5b
  jmp __alltraps
  102148:	e9 44 07 00 00       	jmp    102891 <__alltraps>

0010214d <vector92>:
.globl vector92
vector92:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $92
  10214f:	6a 5c                	push   $0x5c
  jmp __alltraps
  102151:	e9 3b 07 00 00       	jmp    102891 <__alltraps>

00102156 <vector93>:
.globl vector93
vector93:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $93
  102158:	6a 5d                	push   $0x5d
  jmp __alltraps
  10215a:	e9 32 07 00 00       	jmp    102891 <__alltraps>

0010215f <vector94>:
.globl vector94
vector94:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $94
  102161:	6a 5e                	push   $0x5e
  jmp __alltraps
  102163:	e9 29 07 00 00       	jmp    102891 <__alltraps>

00102168 <vector95>:
.globl vector95
vector95:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $95
  10216a:	6a 5f                	push   $0x5f
  jmp __alltraps
  10216c:	e9 20 07 00 00       	jmp    102891 <__alltraps>

00102171 <vector96>:
.globl vector96
vector96:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $96
  102173:	6a 60                	push   $0x60
  jmp __alltraps
  102175:	e9 17 07 00 00       	jmp    102891 <__alltraps>

0010217a <vector97>:
.globl vector97
vector97:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $97
  10217c:	6a 61                	push   $0x61
  jmp __alltraps
  10217e:	e9 0e 07 00 00       	jmp    102891 <__alltraps>

00102183 <vector98>:
.globl vector98
vector98:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $98
  102185:	6a 62                	push   $0x62
  jmp __alltraps
  102187:	e9 05 07 00 00       	jmp    102891 <__alltraps>

0010218c <vector99>:
.globl vector99
vector99:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $99
  10218e:	6a 63                	push   $0x63
  jmp __alltraps
  102190:	e9 fc 06 00 00       	jmp    102891 <__alltraps>

00102195 <vector100>:
.globl vector100
vector100:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $100
  102197:	6a 64                	push   $0x64
  jmp __alltraps
  102199:	e9 f3 06 00 00       	jmp    102891 <__alltraps>

0010219e <vector101>:
.globl vector101
vector101:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $101
  1021a0:	6a 65                	push   $0x65
  jmp __alltraps
  1021a2:	e9 ea 06 00 00       	jmp    102891 <__alltraps>

001021a7 <vector102>:
.globl vector102
vector102:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $102
  1021a9:	6a 66                	push   $0x66
  jmp __alltraps
  1021ab:	e9 e1 06 00 00       	jmp    102891 <__alltraps>

001021b0 <vector103>:
.globl vector103
vector103:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $103
  1021b2:	6a 67                	push   $0x67
  jmp __alltraps
  1021b4:	e9 d8 06 00 00       	jmp    102891 <__alltraps>

001021b9 <vector104>:
.globl vector104
vector104:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $104
  1021bb:	6a 68                	push   $0x68
  jmp __alltraps
  1021bd:	e9 cf 06 00 00       	jmp    102891 <__alltraps>

001021c2 <vector105>:
.globl vector105
vector105:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $105
  1021c4:	6a 69                	push   $0x69
  jmp __alltraps
  1021c6:	e9 c6 06 00 00       	jmp    102891 <__alltraps>

001021cb <vector106>:
.globl vector106
vector106:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $106
  1021cd:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021cf:	e9 bd 06 00 00       	jmp    102891 <__alltraps>

001021d4 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $107
  1021d6:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021d8:	e9 b4 06 00 00       	jmp    102891 <__alltraps>

001021dd <vector108>:
.globl vector108
vector108:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $108
  1021df:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021e1:	e9 ab 06 00 00       	jmp    102891 <__alltraps>

001021e6 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $109
  1021e8:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021ea:	e9 a2 06 00 00       	jmp    102891 <__alltraps>

001021ef <vector110>:
.globl vector110
vector110:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $110
  1021f1:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021f3:	e9 99 06 00 00       	jmp    102891 <__alltraps>

001021f8 <vector111>:
.globl vector111
vector111:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $111
  1021fa:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021fc:	e9 90 06 00 00       	jmp    102891 <__alltraps>

00102201 <vector112>:
.globl vector112
vector112:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $112
  102203:	6a 70                	push   $0x70
  jmp __alltraps
  102205:	e9 87 06 00 00       	jmp    102891 <__alltraps>

0010220a <vector113>:
.globl vector113
vector113:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $113
  10220c:	6a 71                	push   $0x71
  jmp __alltraps
  10220e:	e9 7e 06 00 00       	jmp    102891 <__alltraps>

00102213 <vector114>:
.globl vector114
vector114:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $114
  102215:	6a 72                	push   $0x72
  jmp __alltraps
  102217:	e9 75 06 00 00       	jmp    102891 <__alltraps>

0010221c <vector115>:
.globl vector115
vector115:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $115
  10221e:	6a 73                	push   $0x73
  jmp __alltraps
  102220:	e9 6c 06 00 00       	jmp    102891 <__alltraps>

00102225 <vector116>:
.globl vector116
vector116:
  pushl $0
  102225:	6a 00                	push   $0x0
  pushl $116
  102227:	6a 74                	push   $0x74
  jmp __alltraps
  102229:	e9 63 06 00 00       	jmp    102891 <__alltraps>

0010222e <vector117>:
.globl vector117
vector117:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $117
  102230:	6a 75                	push   $0x75
  jmp __alltraps
  102232:	e9 5a 06 00 00       	jmp    102891 <__alltraps>

00102237 <vector118>:
.globl vector118
vector118:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $118
  102239:	6a 76                	push   $0x76
  jmp __alltraps
  10223b:	e9 51 06 00 00       	jmp    102891 <__alltraps>

00102240 <vector119>:
.globl vector119
vector119:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $119
  102242:	6a 77                	push   $0x77
  jmp __alltraps
  102244:	e9 48 06 00 00       	jmp    102891 <__alltraps>

00102249 <vector120>:
.globl vector120
vector120:
  pushl $0
  102249:	6a 00                	push   $0x0
  pushl $120
  10224b:	6a 78                	push   $0x78
  jmp __alltraps
  10224d:	e9 3f 06 00 00       	jmp    102891 <__alltraps>

00102252 <vector121>:
.globl vector121
vector121:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $121
  102254:	6a 79                	push   $0x79
  jmp __alltraps
  102256:	e9 36 06 00 00       	jmp    102891 <__alltraps>

0010225b <vector122>:
.globl vector122
vector122:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $122
  10225d:	6a 7a                	push   $0x7a
  jmp __alltraps
  10225f:	e9 2d 06 00 00       	jmp    102891 <__alltraps>

00102264 <vector123>:
.globl vector123
vector123:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $123
  102266:	6a 7b                	push   $0x7b
  jmp __alltraps
  102268:	e9 24 06 00 00       	jmp    102891 <__alltraps>

0010226d <vector124>:
.globl vector124
vector124:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $124
  10226f:	6a 7c                	push   $0x7c
  jmp __alltraps
  102271:	e9 1b 06 00 00       	jmp    102891 <__alltraps>

00102276 <vector125>:
.globl vector125
vector125:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $125
  102278:	6a 7d                	push   $0x7d
  jmp __alltraps
  10227a:	e9 12 06 00 00       	jmp    102891 <__alltraps>

0010227f <vector126>:
.globl vector126
vector126:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $126
  102281:	6a 7e                	push   $0x7e
  jmp __alltraps
  102283:	e9 09 06 00 00       	jmp    102891 <__alltraps>

00102288 <vector127>:
.globl vector127
vector127:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $127
  10228a:	6a 7f                	push   $0x7f
  jmp __alltraps
  10228c:	e9 00 06 00 00       	jmp    102891 <__alltraps>

00102291 <vector128>:
.globl vector128
vector128:
  pushl $0
  102291:	6a 00                	push   $0x0
  pushl $128
  102293:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102298:	e9 f4 05 00 00       	jmp    102891 <__alltraps>

0010229d <vector129>:
.globl vector129
vector129:
  pushl $0
  10229d:	6a 00                	push   $0x0
  pushl $129
  10229f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022a4:	e9 e8 05 00 00       	jmp    102891 <__alltraps>

001022a9 <vector130>:
.globl vector130
vector130:
  pushl $0
  1022a9:	6a 00                	push   $0x0
  pushl $130
  1022ab:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022b0:	e9 dc 05 00 00       	jmp    102891 <__alltraps>

001022b5 <vector131>:
.globl vector131
vector131:
  pushl $0
  1022b5:	6a 00                	push   $0x0
  pushl $131
  1022b7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022bc:	e9 d0 05 00 00       	jmp    102891 <__alltraps>

001022c1 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022c1:	6a 00                	push   $0x0
  pushl $132
  1022c3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022c8:	e9 c4 05 00 00       	jmp    102891 <__alltraps>

001022cd <vector133>:
.globl vector133
vector133:
  pushl $0
  1022cd:	6a 00                	push   $0x0
  pushl $133
  1022cf:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022d4:	e9 b8 05 00 00       	jmp    102891 <__alltraps>

001022d9 <vector134>:
.globl vector134
vector134:
  pushl $0
  1022d9:	6a 00                	push   $0x0
  pushl $134
  1022db:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022e0:	e9 ac 05 00 00       	jmp    102891 <__alltraps>

001022e5 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022e5:	6a 00                	push   $0x0
  pushl $135
  1022e7:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022ec:	e9 a0 05 00 00       	jmp    102891 <__alltraps>

001022f1 <vector136>:
.globl vector136
vector136:
  pushl $0
  1022f1:	6a 00                	push   $0x0
  pushl $136
  1022f3:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022f8:	e9 94 05 00 00       	jmp    102891 <__alltraps>

001022fd <vector137>:
.globl vector137
vector137:
  pushl $0
  1022fd:	6a 00                	push   $0x0
  pushl $137
  1022ff:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102304:	e9 88 05 00 00       	jmp    102891 <__alltraps>

00102309 <vector138>:
.globl vector138
vector138:
  pushl $0
  102309:	6a 00                	push   $0x0
  pushl $138
  10230b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102310:	e9 7c 05 00 00       	jmp    102891 <__alltraps>

00102315 <vector139>:
.globl vector139
vector139:
  pushl $0
  102315:	6a 00                	push   $0x0
  pushl $139
  102317:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10231c:	e9 70 05 00 00       	jmp    102891 <__alltraps>

00102321 <vector140>:
.globl vector140
vector140:
  pushl $0
  102321:	6a 00                	push   $0x0
  pushl $140
  102323:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102328:	e9 64 05 00 00       	jmp    102891 <__alltraps>

0010232d <vector141>:
.globl vector141
vector141:
  pushl $0
  10232d:	6a 00                	push   $0x0
  pushl $141
  10232f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102334:	e9 58 05 00 00       	jmp    102891 <__alltraps>

00102339 <vector142>:
.globl vector142
vector142:
  pushl $0
  102339:	6a 00                	push   $0x0
  pushl $142
  10233b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102340:	e9 4c 05 00 00       	jmp    102891 <__alltraps>

00102345 <vector143>:
.globl vector143
vector143:
  pushl $0
  102345:	6a 00                	push   $0x0
  pushl $143
  102347:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10234c:	e9 40 05 00 00       	jmp    102891 <__alltraps>

00102351 <vector144>:
.globl vector144
vector144:
  pushl $0
  102351:	6a 00                	push   $0x0
  pushl $144
  102353:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102358:	e9 34 05 00 00       	jmp    102891 <__alltraps>

0010235d <vector145>:
.globl vector145
vector145:
  pushl $0
  10235d:	6a 00                	push   $0x0
  pushl $145
  10235f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102364:	e9 28 05 00 00       	jmp    102891 <__alltraps>

00102369 <vector146>:
.globl vector146
vector146:
  pushl $0
  102369:	6a 00                	push   $0x0
  pushl $146
  10236b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102370:	e9 1c 05 00 00       	jmp    102891 <__alltraps>

00102375 <vector147>:
.globl vector147
vector147:
  pushl $0
  102375:	6a 00                	push   $0x0
  pushl $147
  102377:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10237c:	e9 10 05 00 00       	jmp    102891 <__alltraps>

00102381 <vector148>:
.globl vector148
vector148:
  pushl $0
  102381:	6a 00                	push   $0x0
  pushl $148
  102383:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102388:	e9 04 05 00 00       	jmp    102891 <__alltraps>

0010238d <vector149>:
.globl vector149
vector149:
  pushl $0
  10238d:	6a 00                	push   $0x0
  pushl $149
  10238f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102394:	e9 f8 04 00 00       	jmp    102891 <__alltraps>

00102399 <vector150>:
.globl vector150
vector150:
  pushl $0
  102399:	6a 00                	push   $0x0
  pushl $150
  10239b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023a0:	e9 ec 04 00 00       	jmp    102891 <__alltraps>

001023a5 <vector151>:
.globl vector151
vector151:
  pushl $0
  1023a5:	6a 00                	push   $0x0
  pushl $151
  1023a7:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023ac:	e9 e0 04 00 00       	jmp    102891 <__alltraps>

001023b1 <vector152>:
.globl vector152
vector152:
  pushl $0
  1023b1:	6a 00                	push   $0x0
  pushl $152
  1023b3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023b8:	e9 d4 04 00 00       	jmp    102891 <__alltraps>

001023bd <vector153>:
.globl vector153
vector153:
  pushl $0
  1023bd:	6a 00                	push   $0x0
  pushl $153
  1023bf:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023c4:	e9 c8 04 00 00       	jmp    102891 <__alltraps>

001023c9 <vector154>:
.globl vector154
vector154:
  pushl $0
  1023c9:	6a 00                	push   $0x0
  pushl $154
  1023cb:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023d0:	e9 bc 04 00 00       	jmp    102891 <__alltraps>

001023d5 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023d5:	6a 00                	push   $0x0
  pushl $155
  1023d7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023dc:	e9 b0 04 00 00       	jmp    102891 <__alltraps>

001023e1 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023e1:	6a 00                	push   $0x0
  pushl $156
  1023e3:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023e8:	e9 a4 04 00 00       	jmp    102891 <__alltraps>

001023ed <vector157>:
.globl vector157
vector157:
  pushl $0
  1023ed:	6a 00                	push   $0x0
  pushl $157
  1023ef:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023f4:	e9 98 04 00 00       	jmp    102891 <__alltraps>

001023f9 <vector158>:
.globl vector158
vector158:
  pushl $0
  1023f9:	6a 00                	push   $0x0
  pushl $158
  1023fb:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102400:	e9 8c 04 00 00       	jmp    102891 <__alltraps>

00102405 <vector159>:
.globl vector159
vector159:
  pushl $0
  102405:	6a 00                	push   $0x0
  pushl $159
  102407:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10240c:	e9 80 04 00 00       	jmp    102891 <__alltraps>

00102411 <vector160>:
.globl vector160
vector160:
  pushl $0
  102411:	6a 00                	push   $0x0
  pushl $160
  102413:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102418:	e9 74 04 00 00       	jmp    102891 <__alltraps>

0010241d <vector161>:
.globl vector161
vector161:
  pushl $0
  10241d:	6a 00                	push   $0x0
  pushl $161
  10241f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102424:	e9 68 04 00 00       	jmp    102891 <__alltraps>

00102429 <vector162>:
.globl vector162
vector162:
  pushl $0
  102429:	6a 00                	push   $0x0
  pushl $162
  10242b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102430:	e9 5c 04 00 00       	jmp    102891 <__alltraps>

00102435 <vector163>:
.globl vector163
vector163:
  pushl $0
  102435:	6a 00                	push   $0x0
  pushl $163
  102437:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10243c:	e9 50 04 00 00       	jmp    102891 <__alltraps>

00102441 <vector164>:
.globl vector164
vector164:
  pushl $0
  102441:	6a 00                	push   $0x0
  pushl $164
  102443:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102448:	e9 44 04 00 00       	jmp    102891 <__alltraps>

0010244d <vector165>:
.globl vector165
vector165:
  pushl $0
  10244d:	6a 00                	push   $0x0
  pushl $165
  10244f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102454:	e9 38 04 00 00       	jmp    102891 <__alltraps>

00102459 <vector166>:
.globl vector166
vector166:
  pushl $0
  102459:	6a 00                	push   $0x0
  pushl $166
  10245b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102460:	e9 2c 04 00 00       	jmp    102891 <__alltraps>

00102465 <vector167>:
.globl vector167
vector167:
  pushl $0
  102465:	6a 00                	push   $0x0
  pushl $167
  102467:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10246c:	e9 20 04 00 00       	jmp    102891 <__alltraps>

00102471 <vector168>:
.globl vector168
vector168:
  pushl $0
  102471:	6a 00                	push   $0x0
  pushl $168
  102473:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102478:	e9 14 04 00 00       	jmp    102891 <__alltraps>

0010247d <vector169>:
.globl vector169
vector169:
  pushl $0
  10247d:	6a 00                	push   $0x0
  pushl $169
  10247f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102484:	e9 08 04 00 00       	jmp    102891 <__alltraps>

00102489 <vector170>:
.globl vector170
vector170:
  pushl $0
  102489:	6a 00                	push   $0x0
  pushl $170
  10248b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102490:	e9 fc 03 00 00       	jmp    102891 <__alltraps>

00102495 <vector171>:
.globl vector171
vector171:
  pushl $0
  102495:	6a 00                	push   $0x0
  pushl $171
  102497:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10249c:	e9 f0 03 00 00       	jmp    102891 <__alltraps>

001024a1 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024a1:	6a 00                	push   $0x0
  pushl $172
  1024a3:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024a8:	e9 e4 03 00 00       	jmp    102891 <__alltraps>

001024ad <vector173>:
.globl vector173
vector173:
  pushl $0
  1024ad:	6a 00                	push   $0x0
  pushl $173
  1024af:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024b4:	e9 d8 03 00 00       	jmp    102891 <__alltraps>

001024b9 <vector174>:
.globl vector174
vector174:
  pushl $0
  1024b9:	6a 00                	push   $0x0
  pushl $174
  1024bb:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024c0:	e9 cc 03 00 00       	jmp    102891 <__alltraps>

001024c5 <vector175>:
.globl vector175
vector175:
  pushl $0
  1024c5:	6a 00                	push   $0x0
  pushl $175
  1024c7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024cc:	e9 c0 03 00 00       	jmp    102891 <__alltraps>

001024d1 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024d1:	6a 00                	push   $0x0
  pushl $176
  1024d3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024d8:	e9 b4 03 00 00       	jmp    102891 <__alltraps>

001024dd <vector177>:
.globl vector177
vector177:
  pushl $0
  1024dd:	6a 00                	push   $0x0
  pushl $177
  1024df:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024e4:	e9 a8 03 00 00       	jmp    102891 <__alltraps>

001024e9 <vector178>:
.globl vector178
vector178:
  pushl $0
  1024e9:	6a 00                	push   $0x0
  pushl $178
  1024eb:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024f0:	e9 9c 03 00 00       	jmp    102891 <__alltraps>

001024f5 <vector179>:
.globl vector179
vector179:
  pushl $0
  1024f5:	6a 00                	push   $0x0
  pushl $179
  1024f7:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024fc:	e9 90 03 00 00       	jmp    102891 <__alltraps>

00102501 <vector180>:
.globl vector180
vector180:
  pushl $0
  102501:	6a 00                	push   $0x0
  pushl $180
  102503:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102508:	e9 84 03 00 00       	jmp    102891 <__alltraps>

0010250d <vector181>:
.globl vector181
vector181:
  pushl $0
  10250d:	6a 00                	push   $0x0
  pushl $181
  10250f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102514:	e9 78 03 00 00       	jmp    102891 <__alltraps>

00102519 <vector182>:
.globl vector182
vector182:
  pushl $0
  102519:	6a 00                	push   $0x0
  pushl $182
  10251b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102520:	e9 6c 03 00 00       	jmp    102891 <__alltraps>

00102525 <vector183>:
.globl vector183
vector183:
  pushl $0
  102525:	6a 00                	push   $0x0
  pushl $183
  102527:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10252c:	e9 60 03 00 00       	jmp    102891 <__alltraps>

00102531 <vector184>:
.globl vector184
vector184:
  pushl $0
  102531:	6a 00                	push   $0x0
  pushl $184
  102533:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102538:	e9 54 03 00 00       	jmp    102891 <__alltraps>

0010253d <vector185>:
.globl vector185
vector185:
  pushl $0
  10253d:	6a 00                	push   $0x0
  pushl $185
  10253f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102544:	e9 48 03 00 00       	jmp    102891 <__alltraps>

00102549 <vector186>:
.globl vector186
vector186:
  pushl $0
  102549:	6a 00                	push   $0x0
  pushl $186
  10254b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102550:	e9 3c 03 00 00       	jmp    102891 <__alltraps>

00102555 <vector187>:
.globl vector187
vector187:
  pushl $0
  102555:	6a 00                	push   $0x0
  pushl $187
  102557:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10255c:	e9 30 03 00 00       	jmp    102891 <__alltraps>

00102561 <vector188>:
.globl vector188
vector188:
  pushl $0
  102561:	6a 00                	push   $0x0
  pushl $188
  102563:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102568:	e9 24 03 00 00       	jmp    102891 <__alltraps>

0010256d <vector189>:
.globl vector189
vector189:
  pushl $0
  10256d:	6a 00                	push   $0x0
  pushl $189
  10256f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102574:	e9 18 03 00 00       	jmp    102891 <__alltraps>

00102579 <vector190>:
.globl vector190
vector190:
  pushl $0
  102579:	6a 00                	push   $0x0
  pushl $190
  10257b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102580:	e9 0c 03 00 00       	jmp    102891 <__alltraps>

00102585 <vector191>:
.globl vector191
vector191:
  pushl $0
  102585:	6a 00                	push   $0x0
  pushl $191
  102587:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10258c:	e9 00 03 00 00       	jmp    102891 <__alltraps>

00102591 <vector192>:
.globl vector192
vector192:
  pushl $0
  102591:	6a 00                	push   $0x0
  pushl $192
  102593:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102598:	e9 f4 02 00 00       	jmp    102891 <__alltraps>

0010259d <vector193>:
.globl vector193
vector193:
  pushl $0
  10259d:	6a 00                	push   $0x0
  pushl $193
  10259f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025a4:	e9 e8 02 00 00       	jmp    102891 <__alltraps>

001025a9 <vector194>:
.globl vector194
vector194:
  pushl $0
  1025a9:	6a 00                	push   $0x0
  pushl $194
  1025ab:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025b0:	e9 dc 02 00 00       	jmp    102891 <__alltraps>

001025b5 <vector195>:
.globl vector195
vector195:
  pushl $0
  1025b5:	6a 00                	push   $0x0
  pushl $195
  1025b7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025bc:	e9 d0 02 00 00       	jmp    102891 <__alltraps>

001025c1 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025c1:	6a 00                	push   $0x0
  pushl $196
  1025c3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025c8:	e9 c4 02 00 00       	jmp    102891 <__alltraps>

001025cd <vector197>:
.globl vector197
vector197:
  pushl $0
  1025cd:	6a 00                	push   $0x0
  pushl $197
  1025cf:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025d4:	e9 b8 02 00 00       	jmp    102891 <__alltraps>

001025d9 <vector198>:
.globl vector198
vector198:
  pushl $0
  1025d9:	6a 00                	push   $0x0
  pushl $198
  1025db:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025e0:	e9 ac 02 00 00       	jmp    102891 <__alltraps>

001025e5 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025e5:	6a 00                	push   $0x0
  pushl $199
  1025e7:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025ec:	e9 a0 02 00 00       	jmp    102891 <__alltraps>

001025f1 <vector200>:
.globl vector200
vector200:
  pushl $0
  1025f1:	6a 00                	push   $0x0
  pushl $200
  1025f3:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025f8:	e9 94 02 00 00       	jmp    102891 <__alltraps>

001025fd <vector201>:
.globl vector201
vector201:
  pushl $0
  1025fd:	6a 00                	push   $0x0
  pushl $201
  1025ff:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102604:	e9 88 02 00 00       	jmp    102891 <__alltraps>

00102609 <vector202>:
.globl vector202
vector202:
  pushl $0
  102609:	6a 00                	push   $0x0
  pushl $202
  10260b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102610:	e9 7c 02 00 00       	jmp    102891 <__alltraps>

00102615 <vector203>:
.globl vector203
vector203:
  pushl $0
  102615:	6a 00                	push   $0x0
  pushl $203
  102617:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10261c:	e9 70 02 00 00       	jmp    102891 <__alltraps>

00102621 <vector204>:
.globl vector204
vector204:
  pushl $0
  102621:	6a 00                	push   $0x0
  pushl $204
  102623:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102628:	e9 64 02 00 00       	jmp    102891 <__alltraps>

0010262d <vector205>:
.globl vector205
vector205:
  pushl $0
  10262d:	6a 00                	push   $0x0
  pushl $205
  10262f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102634:	e9 58 02 00 00       	jmp    102891 <__alltraps>

00102639 <vector206>:
.globl vector206
vector206:
  pushl $0
  102639:	6a 00                	push   $0x0
  pushl $206
  10263b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102640:	e9 4c 02 00 00       	jmp    102891 <__alltraps>

00102645 <vector207>:
.globl vector207
vector207:
  pushl $0
  102645:	6a 00                	push   $0x0
  pushl $207
  102647:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10264c:	e9 40 02 00 00       	jmp    102891 <__alltraps>

00102651 <vector208>:
.globl vector208
vector208:
  pushl $0
  102651:	6a 00                	push   $0x0
  pushl $208
  102653:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102658:	e9 34 02 00 00       	jmp    102891 <__alltraps>

0010265d <vector209>:
.globl vector209
vector209:
  pushl $0
  10265d:	6a 00                	push   $0x0
  pushl $209
  10265f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102664:	e9 28 02 00 00       	jmp    102891 <__alltraps>

00102669 <vector210>:
.globl vector210
vector210:
  pushl $0
  102669:	6a 00                	push   $0x0
  pushl $210
  10266b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102670:	e9 1c 02 00 00       	jmp    102891 <__alltraps>

00102675 <vector211>:
.globl vector211
vector211:
  pushl $0
  102675:	6a 00                	push   $0x0
  pushl $211
  102677:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10267c:	e9 10 02 00 00       	jmp    102891 <__alltraps>

00102681 <vector212>:
.globl vector212
vector212:
  pushl $0
  102681:	6a 00                	push   $0x0
  pushl $212
  102683:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102688:	e9 04 02 00 00       	jmp    102891 <__alltraps>

0010268d <vector213>:
.globl vector213
vector213:
  pushl $0
  10268d:	6a 00                	push   $0x0
  pushl $213
  10268f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102694:	e9 f8 01 00 00       	jmp    102891 <__alltraps>

00102699 <vector214>:
.globl vector214
vector214:
  pushl $0
  102699:	6a 00                	push   $0x0
  pushl $214
  10269b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026a0:	e9 ec 01 00 00       	jmp    102891 <__alltraps>

001026a5 <vector215>:
.globl vector215
vector215:
  pushl $0
  1026a5:	6a 00                	push   $0x0
  pushl $215
  1026a7:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026ac:	e9 e0 01 00 00       	jmp    102891 <__alltraps>

001026b1 <vector216>:
.globl vector216
vector216:
  pushl $0
  1026b1:	6a 00                	push   $0x0
  pushl $216
  1026b3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026b8:	e9 d4 01 00 00       	jmp    102891 <__alltraps>

001026bd <vector217>:
.globl vector217
vector217:
  pushl $0
  1026bd:	6a 00                	push   $0x0
  pushl $217
  1026bf:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026c4:	e9 c8 01 00 00       	jmp    102891 <__alltraps>

001026c9 <vector218>:
.globl vector218
vector218:
  pushl $0
  1026c9:	6a 00                	push   $0x0
  pushl $218
  1026cb:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026d0:	e9 bc 01 00 00       	jmp    102891 <__alltraps>

001026d5 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026d5:	6a 00                	push   $0x0
  pushl $219
  1026d7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026dc:	e9 b0 01 00 00       	jmp    102891 <__alltraps>

001026e1 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026e1:	6a 00                	push   $0x0
  pushl $220
  1026e3:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026e8:	e9 a4 01 00 00       	jmp    102891 <__alltraps>

001026ed <vector221>:
.globl vector221
vector221:
  pushl $0
  1026ed:	6a 00                	push   $0x0
  pushl $221
  1026ef:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026f4:	e9 98 01 00 00       	jmp    102891 <__alltraps>

001026f9 <vector222>:
.globl vector222
vector222:
  pushl $0
  1026f9:	6a 00                	push   $0x0
  pushl $222
  1026fb:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102700:	e9 8c 01 00 00       	jmp    102891 <__alltraps>

00102705 <vector223>:
.globl vector223
vector223:
  pushl $0
  102705:	6a 00                	push   $0x0
  pushl $223
  102707:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10270c:	e9 80 01 00 00       	jmp    102891 <__alltraps>

00102711 <vector224>:
.globl vector224
vector224:
  pushl $0
  102711:	6a 00                	push   $0x0
  pushl $224
  102713:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102718:	e9 74 01 00 00       	jmp    102891 <__alltraps>

0010271d <vector225>:
.globl vector225
vector225:
  pushl $0
  10271d:	6a 00                	push   $0x0
  pushl $225
  10271f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102724:	e9 68 01 00 00       	jmp    102891 <__alltraps>

00102729 <vector226>:
.globl vector226
vector226:
  pushl $0
  102729:	6a 00                	push   $0x0
  pushl $226
  10272b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102730:	e9 5c 01 00 00       	jmp    102891 <__alltraps>

00102735 <vector227>:
.globl vector227
vector227:
  pushl $0
  102735:	6a 00                	push   $0x0
  pushl $227
  102737:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10273c:	e9 50 01 00 00       	jmp    102891 <__alltraps>

00102741 <vector228>:
.globl vector228
vector228:
  pushl $0
  102741:	6a 00                	push   $0x0
  pushl $228
  102743:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102748:	e9 44 01 00 00       	jmp    102891 <__alltraps>

0010274d <vector229>:
.globl vector229
vector229:
  pushl $0
  10274d:	6a 00                	push   $0x0
  pushl $229
  10274f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102754:	e9 38 01 00 00       	jmp    102891 <__alltraps>

00102759 <vector230>:
.globl vector230
vector230:
  pushl $0
  102759:	6a 00                	push   $0x0
  pushl $230
  10275b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102760:	e9 2c 01 00 00       	jmp    102891 <__alltraps>

00102765 <vector231>:
.globl vector231
vector231:
  pushl $0
  102765:	6a 00                	push   $0x0
  pushl $231
  102767:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10276c:	e9 20 01 00 00       	jmp    102891 <__alltraps>

00102771 <vector232>:
.globl vector232
vector232:
  pushl $0
  102771:	6a 00                	push   $0x0
  pushl $232
  102773:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102778:	e9 14 01 00 00       	jmp    102891 <__alltraps>

0010277d <vector233>:
.globl vector233
vector233:
  pushl $0
  10277d:	6a 00                	push   $0x0
  pushl $233
  10277f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102784:	e9 08 01 00 00       	jmp    102891 <__alltraps>

00102789 <vector234>:
.globl vector234
vector234:
  pushl $0
  102789:	6a 00                	push   $0x0
  pushl $234
  10278b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102790:	e9 fc 00 00 00       	jmp    102891 <__alltraps>

00102795 <vector235>:
.globl vector235
vector235:
  pushl $0
  102795:	6a 00                	push   $0x0
  pushl $235
  102797:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10279c:	e9 f0 00 00 00       	jmp    102891 <__alltraps>

001027a1 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027a1:	6a 00                	push   $0x0
  pushl $236
  1027a3:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027a8:	e9 e4 00 00 00       	jmp    102891 <__alltraps>

001027ad <vector237>:
.globl vector237
vector237:
  pushl $0
  1027ad:	6a 00                	push   $0x0
  pushl $237
  1027af:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027b4:	e9 d8 00 00 00       	jmp    102891 <__alltraps>

001027b9 <vector238>:
.globl vector238
vector238:
  pushl $0
  1027b9:	6a 00                	push   $0x0
  pushl $238
  1027bb:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027c0:	e9 cc 00 00 00       	jmp    102891 <__alltraps>

001027c5 <vector239>:
.globl vector239
vector239:
  pushl $0
  1027c5:	6a 00                	push   $0x0
  pushl $239
  1027c7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027cc:	e9 c0 00 00 00       	jmp    102891 <__alltraps>

001027d1 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027d1:	6a 00                	push   $0x0
  pushl $240
  1027d3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027d8:	e9 b4 00 00 00       	jmp    102891 <__alltraps>

001027dd <vector241>:
.globl vector241
vector241:
  pushl $0
  1027dd:	6a 00                	push   $0x0
  pushl $241
  1027df:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027e4:	e9 a8 00 00 00       	jmp    102891 <__alltraps>

001027e9 <vector242>:
.globl vector242
vector242:
  pushl $0
  1027e9:	6a 00                	push   $0x0
  pushl $242
  1027eb:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027f0:	e9 9c 00 00 00       	jmp    102891 <__alltraps>

001027f5 <vector243>:
.globl vector243
vector243:
  pushl $0
  1027f5:	6a 00                	push   $0x0
  pushl $243
  1027f7:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027fc:	e9 90 00 00 00       	jmp    102891 <__alltraps>

00102801 <vector244>:
.globl vector244
vector244:
  pushl $0
  102801:	6a 00                	push   $0x0
  pushl $244
  102803:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102808:	e9 84 00 00 00       	jmp    102891 <__alltraps>

0010280d <vector245>:
.globl vector245
vector245:
  pushl $0
  10280d:	6a 00                	push   $0x0
  pushl $245
  10280f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102814:	e9 78 00 00 00       	jmp    102891 <__alltraps>

00102819 <vector246>:
.globl vector246
vector246:
  pushl $0
  102819:	6a 00                	push   $0x0
  pushl $246
  10281b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102820:	e9 6c 00 00 00       	jmp    102891 <__alltraps>

00102825 <vector247>:
.globl vector247
vector247:
  pushl $0
  102825:	6a 00                	push   $0x0
  pushl $247
  102827:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10282c:	e9 60 00 00 00       	jmp    102891 <__alltraps>

00102831 <vector248>:
.globl vector248
vector248:
  pushl $0
  102831:	6a 00                	push   $0x0
  pushl $248
  102833:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102838:	e9 54 00 00 00       	jmp    102891 <__alltraps>

0010283d <vector249>:
.globl vector249
vector249:
  pushl $0
  10283d:	6a 00                	push   $0x0
  pushl $249
  10283f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102844:	e9 48 00 00 00       	jmp    102891 <__alltraps>

00102849 <vector250>:
.globl vector250
vector250:
  pushl $0
  102849:	6a 00                	push   $0x0
  pushl $250
  10284b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102850:	e9 3c 00 00 00       	jmp    102891 <__alltraps>

00102855 <vector251>:
.globl vector251
vector251:
  pushl $0
  102855:	6a 00                	push   $0x0
  pushl $251
  102857:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10285c:	e9 30 00 00 00       	jmp    102891 <__alltraps>

00102861 <vector252>:
.globl vector252
vector252:
  pushl $0
  102861:	6a 00                	push   $0x0
  pushl $252
  102863:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102868:	e9 24 00 00 00       	jmp    102891 <__alltraps>

0010286d <vector253>:
.globl vector253
vector253:
  pushl $0
  10286d:	6a 00                	push   $0x0
  pushl $253
  10286f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102874:	e9 18 00 00 00       	jmp    102891 <__alltraps>

00102879 <vector254>:
.globl vector254
vector254:
  pushl $0
  102879:	6a 00                	push   $0x0
  pushl $254
  10287b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102880:	e9 0c 00 00 00       	jmp    102891 <__alltraps>

00102885 <vector255>:
.globl vector255
vector255:
  pushl $0
  102885:	6a 00                	push   $0x0
  pushl $255
  102887:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10288c:	e9 00 00 00 00       	jmp    102891 <__alltraps>

00102891 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102891:	1e                   	push   %ds
    pushl %es
  102892:	06                   	push   %es
    pushl %fs
  102893:	0f a0                	push   %fs
    pushl %gs
  102895:	0f a8                	push   %gs
    pushal
  102897:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102898:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10289d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10289f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1028a1:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1028a2:	e8 64 f5 ff ff       	call   101e0b <trap>

    # pop the pushed stack pointer
    popl %esp
  1028a7:	5c                   	pop    %esp

001028a8 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1028a8:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1028a9:	0f a9                	pop    %gs
    popl %fs
  1028ab:	0f a1                	pop    %fs
    popl %es
  1028ad:	07                   	pop    %es
    popl %ds
  1028ae:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1028af:	83 c4 08             	add    $0x8,%esp
    iret
  1028b2:	cf                   	iret   

001028b3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028b3:	55                   	push   %ebp
  1028b4:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1028b9:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1028bf:	29 d0                	sub    %edx,%eax
  1028c1:	c1 f8 02             	sar    $0x2,%eax
  1028c4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028ca:	5d                   	pop    %ebp
  1028cb:	c3                   	ret    

001028cc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028cc:	55                   	push   %ebp
  1028cd:	89 e5                	mov    %esp,%ebp
  1028cf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028d5:	89 04 24             	mov    %eax,(%esp)
  1028d8:	e8 d6 ff ff ff       	call   1028b3 <page2ppn>
  1028dd:	c1 e0 0c             	shl    $0xc,%eax
}
  1028e0:	c9                   	leave  
  1028e1:	c3                   	ret    

001028e2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1028e2:	55                   	push   %ebp
  1028e3:	89 e5                	mov    %esp,%ebp
  1028e5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  1028e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1028eb:	c1 e8 0c             	shr    $0xc,%eax
  1028ee:	89 c2                	mov    %eax,%edx
  1028f0:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1028f5:	39 c2                	cmp    %eax,%edx
  1028f7:	72 1c                	jb     102915 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  1028f9:	c7 44 24 08 d0 66 10 	movl   $0x1066d0,0x8(%esp)
  102900:	00 
  102901:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102908:	00 
  102909:	c7 04 24 ef 66 10 00 	movl   $0x1066ef,(%esp)
  102910:	e8 d4 da ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  102915:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  10291b:	8b 45 08             	mov    0x8(%ebp),%eax
  10291e:	c1 e8 0c             	shr    $0xc,%eax
  102921:	89 c2                	mov    %eax,%edx
  102923:	89 d0                	mov    %edx,%eax
  102925:	c1 e0 02             	shl    $0x2,%eax
  102928:	01 d0                	add    %edx,%eax
  10292a:	c1 e0 02             	shl    $0x2,%eax
  10292d:	01 c8                	add    %ecx,%eax
}
  10292f:	c9                   	leave  
  102930:	c3                   	ret    

00102931 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102931:	55                   	push   %ebp
  102932:	89 e5                	mov    %esp,%ebp
  102934:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102937:	8b 45 08             	mov    0x8(%ebp),%eax
  10293a:	89 04 24             	mov    %eax,(%esp)
  10293d:	e8 8a ff ff ff       	call   1028cc <page2pa>
  102942:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102945:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102948:	c1 e8 0c             	shr    $0xc,%eax
  10294b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10294e:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102953:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102956:	72 23                	jb     10297b <page2kva+0x4a>
  102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10295b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10295f:	c7 44 24 08 00 67 10 	movl   $0x106700,0x8(%esp)
  102966:	00 
  102967:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  10296e:	00 
  10296f:	c7 04 24 ef 66 10 00 	movl   $0x1066ef,(%esp)
  102976:	e8 6e da ff ff       	call   1003e9 <__panic>
  10297b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10297e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102983:	c9                   	leave  
  102984:	c3                   	ret    

00102985 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102985:	55                   	push   %ebp
  102986:	89 e5                	mov    %esp,%ebp
  102988:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  10298b:	8b 45 08             	mov    0x8(%ebp),%eax
  10298e:	83 e0 01             	and    $0x1,%eax
  102991:	85 c0                	test   %eax,%eax
  102993:	75 1c                	jne    1029b1 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102995:	c7 44 24 08 24 67 10 	movl   $0x106724,0x8(%esp)
  10299c:	00 
  10299d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1029a4:	00 
  1029a5:	c7 04 24 ef 66 10 00 	movl   $0x1066ef,(%esp)
  1029ac:	e8 38 da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  1029b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029b9:	89 04 24             	mov    %eax,(%esp)
  1029bc:	e8 21 ff ff ff       	call   1028e2 <pa2page>
}
  1029c1:	c9                   	leave  
  1029c2:	c3                   	ret    

001029c3 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1029c3:	55                   	push   %ebp
  1029c4:	89 e5                	mov    %esp,%ebp
  1029c6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  1029c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1029cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029d1:	89 04 24             	mov    %eax,(%esp)
  1029d4:	e8 09 ff ff ff       	call   1028e2 <pa2page>
}
  1029d9:	c9                   	leave  
  1029da:	c3                   	ret    

001029db <page_ref>:

static inline int
page_ref(struct Page *page) {
  1029db:	55                   	push   %ebp
  1029dc:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1029de:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e1:	8b 00                	mov    (%eax),%eax
}
  1029e3:	5d                   	pop    %ebp
  1029e4:	c3                   	ret    

001029e5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029e5:	55                   	push   %ebp
  1029e6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029ee:	89 10                	mov    %edx,(%eax)
}
  1029f0:	90                   	nop
  1029f1:	5d                   	pop    %ebp
  1029f2:	c3                   	ret    

001029f3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  1029f3:	55                   	push   %ebp
  1029f4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f9:	8b 00                	mov    (%eax),%eax
  1029fb:	8d 50 01             	lea    0x1(%eax),%edx
  1029fe:	8b 45 08             	mov    0x8(%ebp),%eax
  102a01:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a03:	8b 45 08             	mov    0x8(%ebp),%eax
  102a06:	8b 00                	mov    (%eax),%eax
}
  102a08:	5d                   	pop    %ebp
  102a09:	c3                   	ret    

00102a0a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102a0a:	55                   	push   %ebp
  102a0b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  102a10:	8b 00                	mov    (%eax),%eax
  102a12:	8d 50 ff             	lea    -0x1(%eax),%edx
  102a15:	8b 45 08             	mov    0x8(%ebp),%eax
  102a18:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a1d:	8b 00                	mov    (%eax),%eax
}
  102a1f:	5d                   	pop    %ebp
  102a20:	c3                   	ret    

00102a21 <__intr_save>:
__intr_save(void) {
  102a21:	55                   	push   %ebp
  102a22:	89 e5                	mov    %esp,%ebp
  102a24:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a27:	9c                   	pushf  
  102a28:	58                   	pop    %eax
  102a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a2f:	25 00 02 00 00       	and    $0x200,%eax
  102a34:	85 c0                	test   %eax,%eax
  102a36:	74 0c                	je     102a44 <__intr_save+0x23>
        intr_disable();
  102a38:	e8 50 ee ff ff       	call   10188d <intr_disable>
        return 1;
  102a3d:	b8 01 00 00 00       	mov    $0x1,%eax
  102a42:	eb 05                	jmp    102a49 <__intr_save+0x28>
    return 0;
  102a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a49:	c9                   	leave  
  102a4a:	c3                   	ret    

00102a4b <__intr_restore>:
__intr_restore(bool flag) {
  102a4b:	55                   	push   %ebp
  102a4c:	89 e5                	mov    %esp,%ebp
  102a4e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a55:	74 05                	je     102a5c <__intr_restore+0x11>
        intr_enable();
  102a57:	e8 2a ee ff ff       	call   101886 <intr_enable>
}
  102a5c:	90                   	nop
  102a5d:	c9                   	leave  
  102a5e:	c3                   	ret    

00102a5f <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a5f:	55                   	push   %ebp
  102a60:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a62:	8b 45 08             	mov    0x8(%ebp),%eax
  102a65:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a68:	b8 23 00 00 00       	mov    $0x23,%eax
  102a6d:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a6f:	b8 23 00 00 00       	mov    $0x23,%eax
  102a74:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a76:	b8 10 00 00 00       	mov    $0x10,%eax
  102a7b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a7d:	b8 10 00 00 00       	mov    $0x10,%eax
  102a82:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a84:	b8 10 00 00 00       	mov    $0x10,%eax
  102a89:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a8b:	ea 92 2a 10 00 08 00 	ljmp   $0x8,$0x102a92
}
  102a92:	90                   	nop
  102a93:	5d                   	pop    %ebp
  102a94:	c3                   	ret    

00102a95 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a95:	55                   	push   %ebp
  102a96:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a98:	8b 45 08             	mov    0x8(%ebp),%eax
  102a9b:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102aa0:	90                   	nop
  102aa1:	5d                   	pop    %ebp
  102aa2:	c3                   	ret    

00102aa3 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102aa3:	55                   	push   %ebp
  102aa4:	89 e5                	mov    %esp,%ebp
  102aa6:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102aa9:	b8 00 70 11 00       	mov    $0x117000,%eax
  102aae:	89 04 24             	mov    %eax,(%esp)
  102ab1:	e8 df ff ff ff       	call   102a95 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102ab6:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102abd:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102abf:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102ac6:	68 00 
  102ac8:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102acd:	0f b7 c0             	movzwl %ax,%eax
  102ad0:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102ad6:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102adb:	c1 e8 10             	shr    $0x10,%eax
  102ade:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102ae3:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102aea:	24 f0                	and    $0xf0,%al
  102aec:	0c 09                	or     $0x9,%al
  102aee:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102af3:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102afa:	24 ef                	and    $0xef,%al
  102afc:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b01:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b08:	24 9f                	and    $0x9f,%al
  102b0a:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b0f:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b16:	0c 80                	or     $0x80,%al
  102b18:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b1d:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b24:	24 f0                	and    $0xf0,%al
  102b26:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b2b:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b32:	24 ef                	and    $0xef,%al
  102b34:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b39:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b40:	24 df                	and    $0xdf,%al
  102b42:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b47:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b4e:	0c 40                	or     $0x40,%al
  102b50:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b55:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b5c:	24 7f                	and    $0x7f,%al
  102b5e:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b63:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102b68:	c1 e8 18             	shr    $0x18,%eax
  102b6b:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b70:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102b77:	e8 e3 fe ff ff       	call   102a5f <lgdt>
  102b7c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b82:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b86:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b89:	90                   	nop
  102b8a:	c9                   	leave  
  102b8b:	c3                   	ret    

00102b8c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b8c:	55                   	push   %ebp
  102b8d:	89 e5                	mov    %esp,%ebp
  102b8f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b92:	c7 05 10 af 11 00 f8 	movl   $0x1070f8,0x11af10
  102b99:	70 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b9c:	a1 10 af 11 00       	mov    0x11af10,%eax
  102ba1:	8b 00                	mov    (%eax),%eax
  102ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ba7:	c7 04 24 50 67 10 00 	movl   $0x106750,(%esp)
  102bae:	e8 df d6 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102bb3:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bb8:	8b 40 04             	mov    0x4(%eax),%eax
  102bbb:	ff d0                	call   *%eax
}
  102bbd:	90                   	nop
  102bbe:	c9                   	leave  
  102bbf:	c3                   	ret    

00102bc0 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102bc0:	55                   	push   %ebp
  102bc1:	89 e5                	mov    %esp,%ebp
  102bc3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102bc6:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bcb:	8b 40 08             	mov    0x8(%eax),%eax
  102bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  102bd8:	89 14 24             	mov    %edx,(%esp)
  102bdb:	ff d0                	call   *%eax
}
  102bdd:	90                   	nop
  102bde:	c9                   	leave  
  102bdf:	c3                   	ret    

00102be0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102be0:	55                   	push   %ebp
  102be1:	89 e5                	mov    %esp,%ebp
  102be3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102be6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102bed:	e8 2f fe ff ff       	call   102a21 <__intr_save>
  102bf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102bf5:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bfa:	8b 40 0c             	mov    0xc(%eax),%eax
  102bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  102c00:	89 14 24             	mov    %edx,(%esp)
  102c03:	ff d0                	call   *%eax
  102c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102c0b:	89 04 24             	mov    %eax,(%esp)
  102c0e:	e8 38 fe ff ff       	call   102a4b <__intr_restore>
    return page;
  102c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c16:	c9                   	leave  
  102c17:	c3                   	ret    

00102c18 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102c18:	55                   	push   %ebp
  102c19:	89 e5                	mov    %esp,%ebp
  102c1b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102c1e:	e8 fe fd ff ff       	call   102a21 <__intr_save>
  102c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c26:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c2b:	8b 40 10             	mov    0x10(%eax),%eax
  102c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c31:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c35:	8b 55 08             	mov    0x8(%ebp),%edx
  102c38:	89 14 24             	mov    %edx,(%esp)
  102c3b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c40:	89 04 24             	mov    %eax,(%esp)
  102c43:	e8 03 fe ff ff       	call   102a4b <__intr_restore>
}
  102c48:	90                   	nop
  102c49:	c9                   	leave  
  102c4a:	c3                   	ret    

00102c4b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c4b:	55                   	push   %ebp
  102c4c:	89 e5                	mov    %esp,%ebp
  102c4e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c51:	e8 cb fd ff ff       	call   102a21 <__intr_save>
  102c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c59:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c5e:	8b 40 14             	mov    0x14(%eax),%eax
  102c61:	ff d0                	call   *%eax
  102c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c69:	89 04 24             	mov    %eax,(%esp)
  102c6c:	e8 da fd ff ff       	call   102a4b <__intr_restore>
    return ret;
  102c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c74:	c9                   	leave  
  102c75:	c3                   	ret    

00102c76 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c76:	55                   	push   %ebp
  102c77:	89 e5                	mov    %esp,%ebp
  102c79:	57                   	push   %edi
  102c7a:	56                   	push   %esi
  102c7b:	53                   	push   %ebx
  102c7c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c82:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c89:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c97:	c7 04 24 67 67 10 00 	movl   $0x106767,(%esp)
  102c9e:	e8 ef d5 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102ca3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102caa:	e9 22 01 00 00       	jmp    102dd1 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102caf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cb5:	89 d0                	mov    %edx,%eax
  102cb7:	c1 e0 02             	shl    $0x2,%eax
  102cba:	01 d0                	add    %edx,%eax
  102cbc:	c1 e0 02             	shl    $0x2,%eax
  102cbf:	01 c8                	add    %ecx,%eax
  102cc1:	8b 50 08             	mov    0x8(%eax),%edx
  102cc4:	8b 40 04             	mov    0x4(%eax),%eax
  102cc7:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102cca:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102ccd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cd3:	89 d0                	mov    %edx,%eax
  102cd5:	c1 e0 02             	shl    $0x2,%eax
  102cd8:	01 d0                	add    %edx,%eax
  102cda:	c1 e0 02             	shl    $0x2,%eax
  102cdd:	01 c8                	add    %ecx,%eax
  102cdf:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ce2:	8b 58 10             	mov    0x10(%eax),%ebx
  102ce5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ce8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102ceb:	01 c8                	add    %ecx,%eax
  102ced:	11 da                	adc    %ebx,%edx
  102cef:	89 45 98             	mov    %eax,-0x68(%ebp)
  102cf2:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102cf5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cfb:	89 d0                	mov    %edx,%eax
  102cfd:	c1 e0 02             	shl    $0x2,%eax
  102d00:	01 d0                	add    %edx,%eax
  102d02:	c1 e0 02             	shl    $0x2,%eax
  102d05:	01 c8                	add    %ecx,%eax
  102d07:	83 c0 14             	add    $0x14,%eax
  102d0a:	8b 00                	mov    (%eax),%eax
  102d0c:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102d0f:	8b 45 98             	mov    -0x68(%ebp),%eax
  102d12:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102d15:	83 c0 ff             	add    $0xffffffff,%eax
  102d18:	83 d2 ff             	adc    $0xffffffff,%edx
  102d1b:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102d21:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102d27:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d2d:	89 d0                	mov    %edx,%eax
  102d2f:	c1 e0 02             	shl    $0x2,%eax
  102d32:	01 d0                	add    %edx,%eax
  102d34:	c1 e0 02             	shl    $0x2,%eax
  102d37:	01 c8                	add    %ecx,%eax
  102d39:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d3c:	8b 58 10             	mov    0x10(%eax),%ebx
  102d3f:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102d42:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102d46:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102d4c:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102d52:	89 44 24 14          	mov    %eax,0x14(%esp)
  102d56:	89 54 24 18          	mov    %edx,0x18(%esp)
  102d5a:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102d5d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102d60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d64:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d68:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d70:	c7 04 24 74 67 10 00 	movl   $0x106774,(%esp)
  102d77:	e8 16 d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d7c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d82:	89 d0                	mov    %edx,%eax
  102d84:	c1 e0 02             	shl    $0x2,%eax
  102d87:	01 d0                	add    %edx,%eax
  102d89:	c1 e0 02             	shl    $0x2,%eax
  102d8c:	01 c8                	add    %ecx,%eax
  102d8e:	83 c0 14             	add    $0x14,%eax
  102d91:	8b 00                	mov    (%eax),%eax
  102d93:	83 f8 01             	cmp    $0x1,%eax
  102d96:	75 36                	jne    102dce <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d9e:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102da1:	77 2b                	ja     102dce <page_init+0x158>
  102da3:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102da6:	72 05                	jb     102dad <page_init+0x137>
  102da8:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102dab:	73 21                	jae    102dce <page_init+0x158>
  102dad:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102db1:	77 1b                	ja     102dce <page_init+0x158>
  102db3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102db7:	72 09                	jb     102dc2 <page_init+0x14c>
  102db9:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102dc0:	77 0c                	ja     102dce <page_init+0x158>
                maxpa = end;
  102dc2:	8b 45 98             	mov    -0x68(%ebp),%eax
  102dc5:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102dc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102dcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102dce:	ff 45 dc             	incl   -0x24(%ebp)
  102dd1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102dd4:	8b 00                	mov    (%eax),%eax
  102dd6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102dd9:	0f 8c d0 fe ff ff    	jl     102caf <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102ddf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102de3:	72 1d                	jb     102e02 <page_init+0x18c>
  102de5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102de9:	77 09                	ja     102df4 <page_init+0x17e>
  102deb:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102df2:	76 0e                	jbe    102e02 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102df4:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102dfb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102e08:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102e0c:	c1 ea 0c             	shr    $0xc,%edx
  102e0f:	89 c1                	mov    %eax,%ecx
  102e11:	89 d3                	mov    %edx,%ebx
  102e13:	89 c8                	mov    %ecx,%eax
  102e15:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102e1a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102e21:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102e26:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e29:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e2c:	01 d0                	add    %edx,%eax
  102e2e:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102e31:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e34:	ba 00 00 00 00       	mov    $0x0,%edx
  102e39:	f7 75 c0             	divl   -0x40(%ebp)
  102e3c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e3f:	29 d0                	sub    %edx,%eax
  102e41:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102e46:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e4d:	eb 2e                	jmp    102e7d <page_init+0x207>
        SetPageReserved(pages + i);
  102e4f:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102e55:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e58:	89 d0                	mov    %edx,%eax
  102e5a:	c1 e0 02             	shl    $0x2,%eax
  102e5d:	01 d0                	add    %edx,%eax
  102e5f:	c1 e0 02             	shl    $0x2,%eax
  102e62:	01 c8                	add    %ecx,%eax
  102e64:	83 c0 04             	add    $0x4,%eax
  102e67:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102e6e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e71:	8b 45 90             	mov    -0x70(%ebp),%eax
  102e74:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102e77:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e7a:	ff 45 dc             	incl   -0x24(%ebp)
  102e7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e80:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102e85:	39 c2                	cmp    %eax,%edx
  102e87:	72 c6                	jb     102e4f <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e89:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102e8f:	89 d0                	mov    %edx,%eax
  102e91:	c1 e0 02             	shl    $0x2,%eax
  102e94:	01 d0                	add    %edx,%eax
  102e96:	c1 e0 02             	shl    $0x2,%eax
  102e99:	89 c2                	mov    %eax,%edx
  102e9b:	a1 18 af 11 00       	mov    0x11af18,%eax
  102ea0:	01 d0                	add    %edx,%eax
  102ea2:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102ea5:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102eac:	77 23                	ja     102ed1 <page_init+0x25b>
  102eae:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102eb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102eb5:	c7 44 24 08 a4 67 10 	movl   $0x1067a4,0x8(%esp)
  102ebc:	00 
  102ebd:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  102ec4:	00 
  102ec5:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  102ecc:	e8 18 d5 ff ff       	call   1003e9 <__panic>
  102ed1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ed4:	05 00 00 00 40       	add    $0x40000000,%eax
  102ed9:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102edc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ee3:	e9 69 01 00 00       	jmp    103051 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102ee8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eeb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eee:	89 d0                	mov    %edx,%eax
  102ef0:	c1 e0 02             	shl    $0x2,%eax
  102ef3:	01 d0                	add    %edx,%eax
  102ef5:	c1 e0 02             	shl    $0x2,%eax
  102ef8:	01 c8                	add    %ecx,%eax
  102efa:	8b 50 08             	mov    0x8(%eax),%edx
  102efd:	8b 40 04             	mov    0x4(%eax),%eax
  102f00:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f03:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102f06:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f09:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f0c:	89 d0                	mov    %edx,%eax
  102f0e:	c1 e0 02             	shl    $0x2,%eax
  102f11:	01 d0                	add    %edx,%eax
  102f13:	c1 e0 02             	shl    $0x2,%eax
  102f16:	01 c8                	add    %ecx,%eax
  102f18:	8b 48 0c             	mov    0xc(%eax),%ecx
  102f1b:	8b 58 10             	mov    0x10(%eax),%ebx
  102f1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f21:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f24:	01 c8                	add    %ecx,%eax
  102f26:	11 da                	adc    %ebx,%edx
  102f28:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102f2b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102f2e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f31:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f34:	89 d0                	mov    %edx,%eax
  102f36:	c1 e0 02             	shl    $0x2,%eax
  102f39:	01 d0                	add    %edx,%eax
  102f3b:	c1 e0 02             	shl    $0x2,%eax
  102f3e:	01 c8                	add    %ecx,%eax
  102f40:	83 c0 14             	add    $0x14,%eax
  102f43:	8b 00                	mov    (%eax),%eax
  102f45:	83 f8 01             	cmp    $0x1,%eax
  102f48:	0f 85 00 01 00 00    	jne    10304e <page_init+0x3d8>
            if (begin < freemem) {
  102f4e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f51:	ba 00 00 00 00       	mov    $0x0,%edx
  102f56:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102f59:	77 17                	ja     102f72 <page_init+0x2fc>
  102f5b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102f5e:	72 05                	jb     102f65 <page_init+0x2ef>
  102f60:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102f63:	73 0d                	jae    102f72 <page_init+0x2fc>
                begin = freemem;
  102f65:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f68:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f6b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f72:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f76:	72 1d                	jb     102f95 <page_init+0x31f>
  102f78:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f7c:	77 09                	ja     102f87 <page_init+0x311>
  102f7e:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f85:	76 0e                	jbe    102f95 <page_init+0x31f>
                end = KMEMSIZE;
  102f87:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f8e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f95:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f9b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f9e:	0f 87 aa 00 00 00    	ja     10304e <page_init+0x3d8>
  102fa4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fa7:	72 09                	jb     102fb2 <page_init+0x33c>
  102fa9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fac:	0f 83 9c 00 00 00    	jae    10304e <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  102fb2:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  102fb9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102fbc:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102fbf:	01 d0                	add    %edx,%eax
  102fc1:	48                   	dec    %eax
  102fc2:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102fc5:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102fc8:	ba 00 00 00 00       	mov    $0x0,%edx
  102fcd:	f7 75 b0             	divl   -0x50(%ebp)
  102fd0:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102fd3:	29 d0                	sub    %edx,%eax
  102fd5:	ba 00 00 00 00       	mov    $0x0,%edx
  102fda:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fdd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102fe0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fe3:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102fe6:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102fe9:	ba 00 00 00 00       	mov    $0x0,%edx
  102fee:	89 c3                	mov    %eax,%ebx
  102ff0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102ff6:	89 de                	mov    %ebx,%esi
  102ff8:	89 d0                	mov    %edx,%eax
  102ffa:	83 e0 00             	and    $0x0,%eax
  102ffd:	89 c7                	mov    %eax,%edi
  102fff:	89 75 c8             	mov    %esi,-0x38(%ebp)
  103002:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  103005:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103008:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10300b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10300e:	77 3e                	ja     10304e <page_init+0x3d8>
  103010:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103013:	72 05                	jb     10301a <page_init+0x3a4>
  103015:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103018:	73 34                	jae    10304e <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  10301a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10301d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103020:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103023:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  103026:	89 c1                	mov    %eax,%ecx
  103028:	89 d3                	mov    %edx,%ebx
  10302a:	89 c8                	mov    %ecx,%eax
  10302c:	89 da                	mov    %ebx,%edx
  10302e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103032:	c1 ea 0c             	shr    $0xc,%edx
  103035:	89 c3                	mov    %eax,%ebx
  103037:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10303a:	89 04 24             	mov    %eax,(%esp)
  10303d:	e8 a0 f8 ff ff       	call   1028e2 <pa2page>
  103042:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103046:	89 04 24             	mov    %eax,(%esp)
  103049:	e8 72 fb ff ff       	call   102bc0 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  10304e:	ff 45 dc             	incl   -0x24(%ebp)
  103051:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103054:	8b 00                	mov    (%eax),%eax
  103056:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103059:	0f 8c 89 fe ff ff    	jl     102ee8 <page_init+0x272>
                }
            }
        }
    }
}
  10305f:	90                   	nop
  103060:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103066:	5b                   	pop    %ebx
  103067:	5e                   	pop    %esi
  103068:	5f                   	pop    %edi
  103069:	5d                   	pop    %ebp
  10306a:	c3                   	ret    

0010306b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10306b:	55                   	push   %ebp
  10306c:	89 e5                	mov    %esp,%ebp
  10306e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103071:	8b 45 0c             	mov    0xc(%ebp),%eax
  103074:	33 45 14             	xor    0x14(%ebp),%eax
  103077:	25 ff 0f 00 00       	and    $0xfff,%eax
  10307c:	85 c0                	test   %eax,%eax
  10307e:	74 24                	je     1030a4 <boot_map_segment+0x39>
  103080:	c7 44 24 0c d6 67 10 	movl   $0x1067d6,0xc(%esp)
  103087:	00 
  103088:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  10308f:	00 
  103090:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  103097:	00 
  103098:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10309f:	e8 45 d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1030a4:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1030ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030ae:	25 ff 0f 00 00       	and    $0xfff,%eax
  1030b3:	89 c2                	mov    %eax,%edx
  1030b5:	8b 45 10             	mov    0x10(%ebp),%eax
  1030b8:	01 c2                	add    %eax,%edx
  1030ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030bd:	01 d0                	add    %edx,%eax
  1030bf:	48                   	dec    %eax
  1030c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030c6:	ba 00 00 00 00       	mov    $0x0,%edx
  1030cb:	f7 75 f0             	divl   -0x10(%ebp)
  1030ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030d1:	29 d0                	sub    %edx,%eax
  1030d3:	c1 e8 0c             	shr    $0xc,%eax
  1030d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1030d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030df:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030e7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1030ea:	8b 45 14             	mov    0x14(%ebp),%eax
  1030ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030f8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030fb:	eb 68                	jmp    103165 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1030fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103104:	00 
  103105:	8b 45 0c             	mov    0xc(%ebp),%eax
  103108:	89 44 24 04          	mov    %eax,0x4(%esp)
  10310c:	8b 45 08             	mov    0x8(%ebp),%eax
  10310f:	89 04 24             	mov    %eax,(%esp)
  103112:	e8 81 01 00 00       	call   103298 <get_pte>
  103117:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10311a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10311e:	75 24                	jne    103144 <boot_map_segment+0xd9>
  103120:	c7 44 24 0c 02 68 10 	movl   $0x106802,0xc(%esp)
  103127:	00 
  103128:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  10312f:	00 
  103130:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103137:	00 
  103138:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10313f:	e8 a5 d2 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  103144:	8b 45 14             	mov    0x14(%ebp),%eax
  103147:	0b 45 18             	or     0x18(%ebp),%eax
  10314a:	83 c8 01             	or     $0x1,%eax
  10314d:	89 c2                	mov    %eax,%edx
  10314f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103152:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103154:	ff 4d f4             	decl   -0xc(%ebp)
  103157:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10315e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103165:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103169:	75 92                	jne    1030fd <boot_map_segment+0x92>
    }
}
  10316b:	90                   	nop
  10316c:	c9                   	leave  
  10316d:	c3                   	ret    

0010316e <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10316e:	55                   	push   %ebp
  10316f:	89 e5                	mov    %esp,%ebp
  103171:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10317b:	e8 60 fa ff ff       	call   102be0 <alloc_pages>
  103180:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103183:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103187:	75 1c                	jne    1031a5 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  103189:	c7 44 24 08 0f 68 10 	movl   $0x10680f,0x8(%esp)
  103190:	00 
  103191:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  103198:	00 
  103199:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1031a0:	e8 44 d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  1031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031a8:	89 04 24             	mov    %eax,(%esp)
  1031ab:	e8 81 f7 ff ff       	call   102931 <page2kva>
}
  1031b0:	c9                   	leave  
  1031b1:	c3                   	ret    

001031b2 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1031b2:	55                   	push   %ebp
  1031b3:	89 e5                	mov    %esp,%ebp
  1031b5:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1031b8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031c0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1031c7:	77 23                	ja     1031ec <pmm_init+0x3a>
  1031c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031d0:	c7 44 24 08 a4 67 10 	movl   $0x1067a4,0x8(%esp)
  1031d7:	00 
  1031d8:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1031df:	00 
  1031e0:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1031e7:	e8 fd d1 ff ff       	call   1003e9 <__panic>
  1031ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031ef:	05 00 00 00 40       	add    $0x40000000,%eax
  1031f4:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1031f9:	e8 8e f9 ff ff       	call   102b8c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1031fe:	e8 73 fa ff ff       	call   102c76 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103203:	e8 82 03 00 00       	call   10358a <check_alloc_page>

    check_pgdir();
  103208:	e8 9c 03 00 00       	call   1035a9 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10320d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103212:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103215:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10321c:	77 23                	ja     103241 <pmm_init+0x8f>
  10321e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103225:	c7 44 24 08 a4 67 10 	movl   $0x1067a4,0x8(%esp)
  10322c:	00 
  10322d:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  103234:	00 
  103235:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10323c:	e8 a8 d1 ff ff       	call   1003e9 <__panic>
  103241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103244:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10324a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10324f:	05 ac 0f 00 00       	add    $0xfac,%eax
  103254:	83 ca 03             	or     $0x3,%edx
  103257:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103259:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10325e:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  103265:	00 
  103266:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10326d:	00 
  10326e:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  103275:	38 
  103276:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10327d:	c0 
  10327e:	89 04 24             	mov    %eax,(%esp)
  103281:	e8 e5 fd ff ff       	call   10306b <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103286:	e8 18 f8 ff ff       	call   102aa3 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10328b:	e8 b5 09 00 00       	call   103c45 <check_boot_pgdir>

    print_pgdir();
  103290:	e8 2e 0e 00 00       	call   1040c3 <print_pgdir>

}
  103295:	90                   	nop
  103296:	c9                   	leave  
  103297:	c3                   	ret    

00103298 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103298:	55                   	push   %ebp
  103299:	89 e5                	mov    %esp,%ebp
  10329b:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry
  10329e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032a1:	c1 e8 16             	shr    $0x16,%eax
  1032a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1032ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ae:	01 d0                	add    %edx,%eax
  1032b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {              // (2) check if entry is not present
  1032b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032b6:	8b 00                	mov    (%eax),%eax
  1032b8:	83 e0 01             	and    $0x1,%eax
  1032bb:	85 c0                	test   %eax,%eax
  1032bd:	0f 85 af 00 00 00    	jne    103372 <get_pte+0xda>
        struct Page* page;
        // (3) check if creating is needed, then alloc page for page table
        // CAUTION: this page is used for page table, not for common data page
        if(!create || (page = alloc_page()) == NULL) {
  1032c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032c7:	74 15                	je     1032de <get_pte+0x46>
  1032c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032d0:	e8 0b f9 ff ff       	call   102be0 <alloc_pages>
  1032d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1032dc:	75 0a                	jne    1032e8 <get_pte+0x50>
            return NULL;
  1032de:	b8 00 00 00 00       	mov    $0x0,%eax
  1032e3:	e9 e7 00 00 00       	jmp    1033cf <get_pte+0x137>
        }
        set_page_ref(page, 1); // (4) set page reference
  1032e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032ef:	00 
  1032f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032f3:	89 04 24             	mov    %eax,(%esp)
  1032f6:	e8 ea f6 ff ff       	call   1029e5 <set_page_ref>
        uintptr_t pa = page2pa(page); // (5) get linear address of page
  1032fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032fe:	89 04 24             	mov    %eax,(%esp)
  103301:	e8 c6 f5 ff ff       	call   1028cc <page2pa>
  103306:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); // (6) clear page content using memset
  103309:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10330c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10330f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103312:	c1 e8 0c             	shr    $0xc,%eax
  103315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103318:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10331d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103320:	72 23                	jb     103345 <get_pte+0xad>
  103322:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103329:	c7 44 24 08 00 67 10 	movl   $0x106700,0x8(%esp)
  103330:	00 
  103331:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
  103338:	00 
  103339:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103340:	e8 a4 d0 ff ff       	call   1003e9 <__panic>
  103345:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103348:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10334d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103354:	00 
  103355:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10335c:	00 
  10335d:	89 04 24             	mov    %eax,(%esp)
  103360:	e8 46 24 00 00       	call   1057ab <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;  // (7) set page directory entry's permission
  103365:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103368:	83 c8 07             	or     $0x7,%eax
  10336b:	89 c2                	mov    %eax,%edx
  10336d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103370:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry
  103372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103375:	8b 00                	mov    (%eax),%eax
  103377:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10337c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10337f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103382:	c1 e8 0c             	shr    $0xc,%eax
  103385:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103388:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10338d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103390:	72 23                	jb     1033b5 <get_pte+0x11d>
  103392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103399:	c7 44 24 08 00 67 10 	movl   $0x106700,0x8(%esp)
  1033a0:	00 
  1033a1:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
  1033a8:	00 
  1033a9:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1033b0:	e8 34 d0 ff ff       	call   1003e9 <__panic>
  1033b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033b8:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1033bd:	89 c2                	mov    %eax,%edx
  1033bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033c2:	c1 e8 0c             	shr    $0xc,%eax
  1033c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  1033ca:	c1 e0 02             	shl    $0x2,%eax
  1033cd:	01 d0                	add    %edx,%eax
}
  1033cf:	c9                   	leave  
  1033d0:	c3                   	ret    

001033d1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1033d1:	55                   	push   %ebp
  1033d2:	89 e5                	mov    %esp,%ebp
  1033d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1033d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1033de:	00 
  1033df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1033e9:	89 04 24             	mov    %eax,(%esp)
  1033ec:	e8 a7 fe ff ff       	call   103298 <get_pte>
  1033f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1033f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1033f8:	74 08                	je     103402 <get_page+0x31>
        *ptep_store = ptep;
  1033fa:	8b 45 10             	mov    0x10(%ebp),%eax
  1033fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103400:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103406:	74 1b                	je     103423 <get_page+0x52>
  103408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10340b:	8b 00                	mov    (%eax),%eax
  10340d:	83 e0 01             	and    $0x1,%eax
  103410:	85 c0                	test   %eax,%eax
  103412:	74 0f                	je     103423 <get_page+0x52>
        return pte2page(*ptep);
  103414:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103417:	8b 00                	mov    (%eax),%eax
  103419:	89 04 24             	mov    %eax,(%esp)
  10341c:	e8 64 f5 ff ff       	call   102985 <pte2page>
  103421:	eb 05                	jmp    103428 <get_page+0x57>
    }
    return NULL;
  103423:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103428:	c9                   	leave  
  103429:	c3                   	ret    

0010342a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10342a:	55                   	push   %ebp
  10342b:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  10342d:	90                   	nop
  10342e:	5d                   	pop    %ebp
  10342f:	c3                   	ret    

00103430 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103430:	55                   	push   %ebp
  103431:	89 e5                	mov    %esp,%ebp
  103433:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103436:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10343d:	00 
  10343e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103441:	89 44 24 04          	mov    %eax,0x4(%esp)
  103445:	8b 45 08             	mov    0x8(%ebp),%eax
  103448:	89 04 24             	mov    %eax,(%esp)
  10344b:	e8 48 fe ff ff       	call   103298 <get_pte>
  103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  103453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103457:	74 19                	je     103472 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  103459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10345c:	89 44 24 08          	mov    %eax,0x8(%esp)
  103460:	8b 45 0c             	mov    0xc(%ebp),%eax
  103463:	89 44 24 04          	mov    %eax,0x4(%esp)
  103467:	8b 45 08             	mov    0x8(%ebp),%eax
  10346a:	89 04 24             	mov    %eax,(%esp)
  10346d:	e8 b8 ff ff ff       	call   10342a <page_remove_pte>
    }
}
  103472:	90                   	nop
  103473:	c9                   	leave  
  103474:	c3                   	ret    

00103475 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103475:	55                   	push   %ebp
  103476:	89 e5                	mov    %esp,%ebp
  103478:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10347b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103482:	00 
  103483:	8b 45 10             	mov    0x10(%ebp),%eax
  103486:	89 44 24 04          	mov    %eax,0x4(%esp)
  10348a:	8b 45 08             	mov    0x8(%ebp),%eax
  10348d:	89 04 24             	mov    %eax,(%esp)
  103490:	e8 03 fe ff ff       	call   103298 <get_pte>
  103495:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103498:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10349c:	75 0a                	jne    1034a8 <page_insert+0x33>
        return -E_NO_MEM;
  10349e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1034a3:	e9 84 00 00 00       	jmp    10352c <page_insert+0xb7>
    }
    page_ref_inc(page);
  1034a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ab:	89 04 24             	mov    %eax,(%esp)
  1034ae:	e8 40 f5 ff ff       	call   1029f3 <page_ref_inc>
    if (*ptep & PTE_P) {
  1034b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034b6:	8b 00                	mov    (%eax),%eax
  1034b8:	83 e0 01             	and    $0x1,%eax
  1034bb:	85 c0                	test   %eax,%eax
  1034bd:	74 3e                	je     1034fd <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1034bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034c2:	8b 00                	mov    (%eax),%eax
  1034c4:	89 04 24             	mov    %eax,(%esp)
  1034c7:	e8 b9 f4 ff ff       	call   102985 <pte2page>
  1034cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1034cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1034d5:	75 0d                	jne    1034e4 <page_insert+0x6f>
            page_ref_dec(page);
  1034d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034da:	89 04 24             	mov    %eax,(%esp)
  1034dd:	e8 28 f5 ff ff       	call   102a0a <page_ref_dec>
  1034e2:	eb 19                	jmp    1034fd <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1034e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1034ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034f5:	89 04 24             	mov    %eax,(%esp)
  1034f8:	e8 2d ff ff ff       	call   10342a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1034fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  103500:	89 04 24             	mov    %eax,(%esp)
  103503:	e8 c4 f3 ff ff       	call   1028cc <page2pa>
  103508:	0b 45 14             	or     0x14(%ebp),%eax
  10350b:	83 c8 01             	or     $0x1,%eax
  10350e:	89 c2                	mov    %eax,%edx
  103510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103513:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103515:	8b 45 10             	mov    0x10(%ebp),%eax
  103518:	89 44 24 04          	mov    %eax,0x4(%esp)
  10351c:	8b 45 08             	mov    0x8(%ebp),%eax
  10351f:	89 04 24             	mov    %eax,(%esp)
  103522:	e8 07 00 00 00       	call   10352e <tlb_invalidate>
    return 0;
  103527:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10352c:	c9                   	leave  
  10352d:	c3                   	ret    

0010352e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10352e:	55                   	push   %ebp
  10352f:	89 e5                	mov    %esp,%ebp
  103531:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103534:	0f 20 d8             	mov    %cr3,%eax
  103537:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10353a:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  10353d:	8b 45 08             	mov    0x8(%ebp),%eax
  103540:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103543:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10354a:	77 23                	ja     10356f <tlb_invalidate+0x41>
  10354c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10354f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103553:	c7 44 24 08 a4 67 10 	movl   $0x1067a4,0x8(%esp)
  10355a:	00 
  10355b:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
  103562:	00 
  103563:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10356a:	e8 7a ce ff ff       	call   1003e9 <__panic>
  10356f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103572:	05 00 00 00 40       	add    $0x40000000,%eax
  103577:	39 d0                	cmp    %edx,%eax
  103579:	75 0c                	jne    103587 <tlb_invalidate+0x59>
        invlpg((void *)la);
  10357b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10357e:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103581:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103584:	0f 01 38             	invlpg (%eax)
    }
}
  103587:	90                   	nop
  103588:	c9                   	leave  
  103589:	c3                   	ret    

0010358a <check_alloc_page>:

static void
check_alloc_page(void) {
  10358a:	55                   	push   %ebp
  10358b:	89 e5                	mov    %esp,%ebp
  10358d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  103590:	a1 10 af 11 00       	mov    0x11af10,%eax
  103595:	8b 40 18             	mov    0x18(%eax),%eax
  103598:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  10359a:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1035a1:	e8 ec cc ff ff       	call   100292 <cprintf>
}
  1035a6:	90                   	nop
  1035a7:	c9                   	leave  
  1035a8:	c3                   	ret    

001035a9 <check_pgdir>:

static void
check_pgdir(void) {
  1035a9:	55                   	push   %ebp
  1035aa:	89 e5                	mov    %esp,%ebp
  1035ac:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1035af:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1035b4:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1035b9:	76 24                	jbe    1035df <check_pgdir+0x36>
  1035bb:	c7 44 24 0c 47 68 10 	movl   $0x106847,0xc(%esp)
  1035c2:	00 
  1035c3:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1035ca:	00 
  1035cb:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  1035d2:	00 
  1035d3:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1035da:	e8 0a ce ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1035df:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1035e4:	85 c0                	test   %eax,%eax
  1035e6:	74 0e                	je     1035f6 <check_pgdir+0x4d>
  1035e8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1035ed:	25 ff 0f 00 00       	and    $0xfff,%eax
  1035f2:	85 c0                	test   %eax,%eax
  1035f4:	74 24                	je     10361a <check_pgdir+0x71>
  1035f6:	c7 44 24 0c 64 68 10 	movl   $0x106864,0xc(%esp)
  1035fd:	00 
  1035fe:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103605:	00 
  103606:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  10360d:	00 
  10360e:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103615:	e8 cf cd ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10361a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10361f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103626:	00 
  103627:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10362e:	00 
  10362f:	89 04 24             	mov    %eax,(%esp)
  103632:	e8 9a fd ff ff       	call   1033d1 <get_page>
  103637:	85 c0                	test   %eax,%eax
  103639:	74 24                	je     10365f <check_pgdir+0xb6>
  10363b:	c7 44 24 0c 9c 68 10 	movl   $0x10689c,0xc(%esp)
  103642:	00 
  103643:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  10364a:	00 
  10364b:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
  103652:	00 
  103653:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10365a:	e8 8a cd ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10365f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103666:	e8 75 f5 ff ff       	call   102be0 <alloc_pages>
  10366b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10366e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103673:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10367a:	00 
  10367b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103682:	00 
  103683:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103686:	89 54 24 04          	mov    %edx,0x4(%esp)
  10368a:	89 04 24             	mov    %eax,(%esp)
  10368d:	e8 e3 fd ff ff       	call   103475 <page_insert>
  103692:	85 c0                	test   %eax,%eax
  103694:	74 24                	je     1036ba <check_pgdir+0x111>
  103696:	c7 44 24 0c c4 68 10 	movl   $0x1068c4,0xc(%esp)
  10369d:	00 
  10369e:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1036a5:	00 
  1036a6:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  1036ad:	00 
  1036ae:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1036b5:	e8 2f cd ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1036ba:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036c6:	00 
  1036c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036ce:	00 
  1036cf:	89 04 24             	mov    %eax,(%esp)
  1036d2:	e8 c1 fb ff ff       	call   103298 <get_pte>
  1036d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036de:	75 24                	jne    103704 <check_pgdir+0x15b>
  1036e0:	c7 44 24 0c f0 68 10 	movl   $0x1068f0,0xc(%esp)
  1036e7:	00 
  1036e8:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1036ef:	00 
  1036f0:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  1036f7:	00 
  1036f8:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1036ff:	e8 e5 cc ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103707:	8b 00                	mov    (%eax),%eax
  103709:	89 04 24             	mov    %eax,(%esp)
  10370c:	e8 74 f2 ff ff       	call   102985 <pte2page>
  103711:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103714:	74 24                	je     10373a <check_pgdir+0x191>
  103716:	c7 44 24 0c 1d 69 10 	movl   $0x10691d,0xc(%esp)
  10371d:	00 
  10371e:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103725:	00 
  103726:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
  10372d:	00 
  10372e:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103735:	e8 af cc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  10373a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10373d:	89 04 24             	mov    %eax,(%esp)
  103740:	e8 96 f2 ff ff       	call   1029db <page_ref>
  103745:	83 f8 01             	cmp    $0x1,%eax
  103748:	74 24                	je     10376e <check_pgdir+0x1c5>
  10374a:	c7 44 24 0c 33 69 10 	movl   $0x106933,0xc(%esp)
  103751:	00 
  103752:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103759:	00 
  10375a:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  103761:	00 
  103762:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103769:	e8 7b cc ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10376e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103773:	8b 00                	mov    (%eax),%eax
  103775:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10377a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10377d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103780:	c1 e8 0c             	shr    $0xc,%eax
  103783:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103786:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10378b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10378e:	72 23                	jb     1037b3 <check_pgdir+0x20a>
  103790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103793:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103797:	c7 44 24 08 00 67 10 	movl   $0x106700,0x8(%esp)
  10379e:	00 
  10379f:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  1037a6:	00 
  1037a7:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1037ae:	e8 36 cc ff ff       	call   1003e9 <__panic>
  1037b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037b6:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1037bb:	83 c0 04             	add    $0x4,%eax
  1037be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1037c1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037cd:	00 
  1037ce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1037d5:	00 
  1037d6:	89 04 24             	mov    %eax,(%esp)
  1037d9:	e8 ba fa ff ff       	call   103298 <get_pte>
  1037de:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1037e1:	74 24                	je     103807 <check_pgdir+0x25e>
  1037e3:	c7 44 24 0c 48 69 10 	movl   $0x106948,0xc(%esp)
  1037ea:	00 
  1037eb:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1037f2:	00 
  1037f3:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
  1037fa:	00 
  1037fb:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103802:	e8 e2 cb ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  103807:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10380e:	e8 cd f3 ff ff       	call   102be0 <alloc_pages>
  103813:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103816:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10381b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103822:	00 
  103823:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10382a:	00 
  10382b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10382e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103832:	89 04 24             	mov    %eax,(%esp)
  103835:	e8 3b fc ff ff       	call   103475 <page_insert>
  10383a:	85 c0                	test   %eax,%eax
  10383c:	74 24                	je     103862 <check_pgdir+0x2b9>
  10383e:	c7 44 24 0c 70 69 10 	movl   $0x106970,0xc(%esp)
  103845:	00 
  103846:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  10384d:	00 
  10384e:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  103855:	00 
  103856:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10385d:	e8 87 cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103862:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103867:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10386e:	00 
  10386f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103876:	00 
  103877:	89 04 24             	mov    %eax,(%esp)
  10387a:	e8 19 fa ff ff       	call   103298 <get_pte>
  10387f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103882:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103886:	75 24                	jne    1038ac <check_pgdir+0x303>
  103888:	c7 44 24 0c a8 69 10 	movl   $0x1069a8,0xc(%esp)
  10388f:	00 
  103890:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103897:	00 
  103898:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  10389f:	00 
  1038a0:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1038a7:	e8 3d cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  1038ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038af:	8b 00                	mov    (%eax),%eax
  1038b1:	83 e0 04             	and    $0x4,%eax
  1038b4:	85 c0                	test   %eax,%eax
  1038b6:	75 24                	jne    1038dc <check_pgdir+0x333>
  1038b8:	c7 44 24 0c d8 69 10 	movl   $0x1069d8,0xc(%esp)
  1038bf:	00 
  1038c0:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1038c7:	00 
  1038c8:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  1038cf:	00 
  1038d0:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1038d7:	e8 0d cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  1038dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038df:	8b 00                	mov    (%eax),%eax
  1038e1:	83 e0 02             	and    $0x2,%eax
  1038e4:	85 c0                	test   %eax,%eax
  1038e6:	75 24                	jne    10390c <check_pgdir+0x363>
  1038e8:	c7 44 24 0c e6 69 10 	movl   $0x1069e6,0xc(%esp)
  1038ef:	00 
  1038f0:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1038f7:	00 
  1038f8:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  1038ff:	00 
  103900:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103907:	e8 dd ca ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  10390c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103911:	8b 00                	mov    (%eax),%eax
  103913:	83 e0 04             	and    $0x4,%eax
  103916:	85 c0                	test   %eax,%eax
  103918:	75 24                	jne    10393e <check_pgdir+0x395>
  10391a:	c7 44 24 0c f4 69 10 	movl   $0x1069f4,0xc(%esp)
  103921:	00 
  103922:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103929:	00 
  10392a:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  103931:	00 
  103932:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103939:	e8 ab ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  10393e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103941:	89 04 24             	mov    %eax,(%esp)
  103944:	e8 92 f0 ff ff       	call   1029db <page_ref>
  103949:	83 f8 01             	cmp    $0x1,%eax
  10394c:	74 24                	je     103972 <check_pgdir+0x3c9>
  10394e:	c7 44 24 0c 0a 6a 10 	movl   $0x106a0a,0xc(%esp)
  103955:	00 
  103956:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  10395d:	00 
  10395e:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  103965:	00 
  103966:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  10396d:	e8 77 ca ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103972:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103977:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10397e:	00 
  10397f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103986:	00 
  103987:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10398a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10398e:	89 04 24             	mov    %eax,(%esp)
  103991:	e8 df fa ff ff       	call   103475 <page_insert>
  103996:	85 c0                	test   %eax,%eax
  103998:	74 24                	je     1039be <check_pgdir+0x415>
  10399a:	c7 44 24 0c 1c 6a 10 	movl   $0x106a1c,0xc(%esp)
  1039a1:	00 
  1039a2:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1039a9:	00 
  1039aa:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  1039b1:	00 
  1039b2:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1039b9:	e8 2b ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  1039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039c1:	89 04 24             	mov    %eax,(%esp)
  1039c4:	e8 12 f0 ff ff       	call   1029db <page_ref>
  1039c9:	83 f8 02             	cmp    $0x2,%eax
  1039cc:	74 24                	je     1039f2 <check_pgdir+0x449>
  1039ce:	c7 44 24 0c 48 6a 10 	movl   $0x106a48,0xc(%esp)
  1039d5:	00 
  1039d6:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  1039dd:	00 
  1039de:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  1039e5:	00 
  1039e6:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  1039ed:	e8 f7 c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  1039f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039f5:	89 04 24             	mov    %eax,(%esp)
  1039f8:	e8 de ef ff ff       	call   1029db <page_ref>
  1039fd:	85 c0                	test   %eax,%eax
  1039ff:	74 24                	je     103a25 <check_pgdir+0x47c>
  103a01:	c7 44 24 0c 5a 6a 10 	movl   $0x106a5a,0xc(%esp)
  103a08:	00 
  103a09:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103a10:	00 
  103a11:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103a18:	00 
  103a19:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103a20:	e8 c4 c9 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a25:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a31:	00 
  103a32:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a39:	00 
  103a3a:	89 04 24             	mov    %eax,(%esp)
  103a3d:	e8 56 f8 ff ff       	call   103298 <get_pte>
  103a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a49:	75 24                	jne    103a6f <check_pgdir+0x4c6>
  103a4b:	c7 44 24 0c a8 69 10 	movl   $0x1069a8,0xc(%esp)
  103a52:	00 
  103a53:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103a5a:	00 
  103a5b:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103a62:	00 
  103a63:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103a6a:	e8 7a c9 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a72:	8b 00                	mov    (%eax),%eax
  103a74:	89 04 24             	mov    %eax,(%esp)
  103a77:	e8 09 ef ff ff       	call   102985 <pte2page>
  103a7c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103a7f:	74 24                	je     103aa5 <check_pgdir+0x4fc>
  103a81:	c7 44 24 0c 1d 69 10 	movl   $0x10691d,0xc(%esp)
  103a88:	00 
  103a89:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103a90:	00 
  103a91:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103a98:	00 
  103a99:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103aa0:	e8 44 c9 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103aa8:	8b 00                	mov    (%eax),%eax
  103aaa:	83 e0 04             	and    $0x4,%eax
  103aad:	85 c0                	test   %eax,%eax
  103aaf:	74 24                	je     103ad5 <check_pgdir+0x52c>
  103ab1:	c7 44 24 0c 6c 6a 10 	movl   $0x106a6c,0xc(%esp)
  103ab8:	00 
  103ab9:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103ac0:	00 
  103ac1:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  103ac8:	00 
  103ac9:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103ad0:	e8 14 c9 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103ad5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ada:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103ae1:	00 
  103ae2:	89 04 24             	mov    %eax,(%esp)
  103ae5:	e8 46 f9 ff ff       	call   103430 <page_remove>
    assert(page_ref(p1) == 1);
  103aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103aed:	89 04 24             	mov    %eax,(%esp)
  103af0:	e8 e6 ee ff ff       	call   1029db <page_ref>
  103af5:	83 f8 01             	cmp    $0x1,%eax
  103af8:	74 24                	je     103b1e <check_pgdir+0x575>
  103afa:	c7 44 24 0c 33 69 10 	movl   $0x106933,0xc(%esp)
  103b01:	00 
  103b02:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103b09:	00 
  103b0a:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  103b11:	00 
  103b12:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103b19:	e8 cb c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b21:	89 04 24             	mov    %eax,(%esp)
  103b24:	e8 b2 ee ff ff       	call   1029db <page_ref>
  103b29:	85 c0                	test   %eax,%eax
  103b2b:	74 24                	je     103b51 <check_pgdir+0x5a8>
  103b2d:	c7 44 24 0c 5a 6a 10 	movl   $0x106a5a,0xc(%esp)
  103b34:	00 
  103b35:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103b3c:	00 
  103b3d:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  103b44:	00 
  103b45:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103b4c:	e8 98 c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103b51:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b56:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b5d:	00 
  103b5e:	89 04 24             	mov    %eax,(%esp)
  103b61:	e8 ca f8 ff ff       	call   103430 <page_remove>
    assert(page_ref(p1) == 0);
  103b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b69:	89 04 24             	mov    %eax,(%esp)
  103b6c:	e8 6a ee ff ff       	call   1029db <page_ref>
  103b71:	85 c0                	test   %eax,%eax
  103b73:	74 24                	je     103b99 <check_pgdir+0x5f0>
  103b75:	c7 44 24 0c 81 6a 10 	movl   $0x106a81,0xc(%esp)
  103b7c:	00 
  103b7d:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103b84:	00 
  103b85:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103b8c:	00 
  103b8d:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103b94:	e8 50 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b9c:	89 04 24             	mov    %eax,(%esp)
  103b9f:	e8 37 ee ff ff       	call   1029db <page_ref>
  103ba4:	85 c0                	test   %eax,%eax
  103ba6:	74 24                	je     103bcc <check_pgdir+0x623>
  103ba8:	c7 44 24 0c 5a 6a 10 	movl   $0x106a5a,0xc(%esp)
  103baf:	00 
  103bb0:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103bb7:	00 
  103bb8:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103bbf:	00 
  103bc0:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103bc7:	e8 1d c8 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103bcc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103bd1:	8b 00                	mov    (%eax),%eax
  103bd3:	89 04 24             	mov    %eax,(%esp)
  103bd6:	e8 e8 ed ff ff       	call   1029c3 <pde2page>
  103bdb:	89 04 24             	mov    %eax,(%esp)
  103bde:	e8 f8 ed ff ff       	call   1029db <page_ref>
  103be3:	83 f8 01             	cmp    $0x1,%eax
  103be6:	74 24                	je     103c0c <check_pgdir+0x663>
  103be8:	c7 44 24 0c 94 6a 10 	movl   $0x106a94,0xc(%esp)
  103bef:	00 
  103bf0:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103bf7:	00 
  103bf8:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103bff:	00 
  103c00:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103c07:	e8 dd c7 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103c0c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c11:	8b 00                	mov    (%eax),%eax
  103c13:	89 04 24             	mov    %eax,(%esp)
  103c16:	e8 a8 ed ff ff       	call   1029c3 <pde2page>
  103c1b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103c22:	00 
  103c23:	89 04 24             	mov    %eax,(%esp)
  103c26:	e8 ed ef ff ff       	call   102c18 <free_pages>
    boot_pgdir[0] = 0;
  103c2b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103c36:	c7 04 24 bb 6a 10 00 	movl   $0x106abb,(%esp)
  103c3d:	e8 50 c6 ff ff       	call   100292 <cprintf>
}
  103c42:	90                   	nop
  103c43:	c9                   	leave  
  103c44:	c3                   	ret    

00103c45 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103c45:	55                   	push   %ebp
  103c46:	89 e5                	mov    %esp,%ebp
  103c48:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103c4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103c52:	e9 ca 00 00 00       	jmp    103d21 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103c5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c60:	c1 e8 0c             	shr    $0xc,%eax
  103c63:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103c66:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103c6b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103c6e:	72 23                	jb     103c93 <check_boot_pgdir+0x4e>
  103c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c77:	c7 44 24 08 00 67 10 	movl   $0x106700,0x8(%esp)
  103c7e:	00 
  103c7f:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103c86:	00 
  103c87:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103c8e:	e8 56 c7 ff ff       	call   1003e9 <__panic>
  103c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c96:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103c9b:	89 c2                	mov    %eax,%edx
  103c9d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ca2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103ca9:	00 
  103caa:	89 54 24 04          	mov    %edx,0x4(%esp)
  103cae:	89 04 24             	mov    %eax,(%esp)
  103cb1:	e8 e2 f5 ff ff       	call   103298 <get_pte>
  103cb6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103cb9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103cbd:	75 24                	jne    103ce3 <check_boot_pgdir+0x9e>
  103cbf:	c7 44 24 0c d8 6a 10 	movl   $0x106ad8,0xc(%esp)
  103cc6:	00 
  103cc7:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103cce:	00 
  103ccf:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103cd6:	00 
  103cd7:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103cde:	e8 06 c7 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103ce3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103ce6:	8b 00                	mov    (%eax),%eax
  103ce8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ced:	89 c2                	mov    %eax,%edx
  103cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cf2:	39 c2                	cmp    %eax,%edx
  103cf4:	74 24                	je     103d1a <check_boot_pgdir+0xd5>
  103cf6:	c7 44 24 0c 15 6b 10 	movl   $0x106b15,0xc(%esp)
  103cfd:	00 
  103cfe:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103d05:	00 
  103d06:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103d0d:	00 
  103d0e:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103d15:	e8 cf c6 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103d1a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103d21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d24:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103d29:	39 c2                	cmp    %eax,%edx
  103d2b:	0f 82 26 ff ff ff    	jb     103c57 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103d31:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d36:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d3b:	8b 00                	mov    (%eax),%eax
  103d3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d42:	89 c2                	mov    %eax,%edx
  103d44:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d4c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103d53:	77 23                	ja     103d78 <check_boot_pgdir+0x133>
  103d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d5c:	c7 44 24 08 a4 67 10 	movl   $0x1067a4,0x8(%esp)
  103d63:	00 
  103d64:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103d6b:	00 
  103d6c:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103d73:	e8 71 c6 ff ff       	call   1003e9 <__panic>
  103d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d7b:	05 00 00 00 40       	add    $0x40000000,%eax
  103d80:	39 d0                	cmp    %edx,%eax
  103d82:	74 24                	je     103da8 <check_boot_pgdir+0x163>
  103d84:	c7 44 24 0c 2c 6b 10 	movl   $0x106b2c,0xc(%esp)
  103d8b:	00 
  103d8c:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103d93:	00 
  103d94:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103d9b:	00 
  103d9c:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103da3:	e8 41 c6 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103da8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dad:	8b 00                	mov    (%eax),%eax
  103daf:	85 c0                	test   %eax,%eax
  103db1:	74 24                	je     103dd7 <check_boot_pgdir+0x192>
  103db3:	c7 44 24 0c 60 6b 10 	movl   $0x106b60,0xc(%esp)
  103dba:	00 
  103dbb:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103dc2:	00 
  103dc3:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103dca:	00 
  103dcb:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103dd2:	e8 12 c6 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103dd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103dde:	e8 fd ed ff ff       	call   102be0 <alloc_pages>
  103de3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103de6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103deb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103df2:	00 
  103df3:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103dfa:	00 
  103dfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103dfe:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e02:	89 04 24             	mov    %eax,(%esp)
  103e05:	e8 6b f6 ff ff       	call   103475 <page_insert>
  103e0a:	85 c0                	test   %eax,%eax
  103e0c:	74 24                	je     103e32 <check_boot_pgdir+0x1ed>
  103e0e:	c7 44 24 0c 74 6b 10 	movl   $0x106b74,0xc(%esp)
  103e15:	00 
  103e16:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103e1d:	00 
  103e1e:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103e25:	00 
  103e26:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103e2d:	e8 b7 c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e35:	89 04 24             	mov    %eax,(%esp)
  103e38:	e8 9e eb ff ff       	call   1029db <page_ref>
  103e3d:	83 f8 01             	cmp    $0x1,%eax
  103e40:	74 24                	je     103e66 <check_boot_pgdir+0x221>
  103e42:	c7 44 24 0c a2 6b 10 	movl   $0x106ba2,0xc(%esp)
  103e49:	00 
  103e4a:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103e51:	00 
  103e52:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103e59:	00 
  103e5a:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103e61:	e8 83 c5 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103e66:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e6b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e72:	00 
  103e73:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103e7a:	00 
  103e7b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103e7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e82:	89 04 24             	mov    %eax,(%esp)
  103e85:	e8 eb f5 ff ff       	call   103475 <page_insert>
  103e8a:	85 c0                	test   %eax,%eax
  103e8c:	74 24                	je     103eb2 <check_boot_pgdir+0x26d>
  103e8e:	c7 44 24 0c b4 6b 10 	movl   $0x106bb4,0xc(%esp)
  103e95:	00 
  103e96:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103e9d:	00 
  103e9e:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  103ea5:	00 
  103ea6:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103ead:	e8 37 c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103eb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103eb5:	89 04 24             	mov    %eax,(%esp)
  103eb8:	e8 1e eb ff ff       	call   1029db <page_ref>
  103ebd:	83 f8 02             	cmp    $0x2,%eax
  103ec0:	74 24                	je     103ee6 <check_boot_pgdir+0x2a1>
  103ec2:	c7 44 24 0c eb 6b 10 	movl   $0x106beb,0xc(%esp)
  103ec9:	00 
  103eca:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103ed1:	00 
  103ed2:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103ed9:	00 
  103eda:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103ee1:	e8 03 c5 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103ee6:	c7 45 e8 fc 6b 10 00 	movl   $0x106bfc,-0x18(%ebp)
    strcpy((void *)0x100, str);
  103eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ef4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103efb:	e8 e1 15 00 00       	call   1054e1 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103f00:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103f07:	00 
  103f08:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f0f:	e8 44 16 00 00       	call   105558 <strcmp>
  103f14:	85 c0                	test   %eax,%eax
  103f16:	74 24                	je     103f3c <check_boot_pgdir+0x2f7>
  103f18:	c7 44 24 0c 14 6c 10 	movl   $0x106c14,0xc(%esp)
  103f1f:	00 
  103f20:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103f27:	00 
  103f28:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  103f2f:	00 
  103f30:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103f37:	e8 ad c4 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103f3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f3f:	89 04 24             	mov    %eax,(%esp)
  103f42:	e8 ea e9 ff ff       	call   102931 <page2kva>
  103f47:	05 00 01 00 00       	add    $0x100,%eax
  103f4c:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103f4f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f56:	e8 30 15 00 00       	call   10548b <strlen>
  103f5b:	85 c0                	test   %eax,%eax
  103f5d:	74 24                	je     103f83 <check_boot_pgdir+0x33e>
  103f5f:	c7 44 24 0c 4c 6c 10 	movl   $0x106c4c,0xc(%esp)
  103f66:	00 
  103f67:	c7 44 24 08 ed 67 10 	movl   $0x1067ed,0x8(%esp)
  103f6e:	00 
  103f6f:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  103f76:	00 
  103f77:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103f7e:	e8 66 c4 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103f83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f8a:	00 
  103f8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f8e:	89 04 24             	mov    %eax,(%esp)
  103f91:	e8 82 ec ff ff       	call   102c18 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103f96:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103f9b:	8b 00                	mov    (%eax),%eax
  103f9d:	89 04 24             	mov    %eax,(%esp)
  103fa0:	e8 1e ea ff ff       	call   1029c3 <pde2page>
  103fa5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fac:	00 
  103fad:	89 04 24             	mov    %eax,(%esp)
  103fb0:	e8 63 ec ff ff       	call   102c18 <free_pages>
    boot_pgdir[0] = 0;
  103fb5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103fba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103fc0:	c7 04 24 70 6c 10 00 	movl   $0x106c70,(%esp)
  103fc7:	e8 c6 c2 ff ff       	call   100292 <cprintf>
}
  103fcc:	90                   	nop
  103fcd:	c9                   	leave  
  103fce:	c3                   	ret    

00103fcf <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103fcf:	55                   	push   %ebp
  103fd0:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  103fd5:	83 e0 04             	and    $0x4,%eax
  103fd8:	85 c0                	test   %eax,%eax
  103fda:	74 04                	je     103fe0 <perm2str+0x11>
  103fdc:	b0 75                	mov    $0x75,%al
  103fde:	eb 02                	jmp    103fe2 <perm2str+0x13>
  103fe0:	b0 2d                	mov    $0x2d,%al
  103fe2:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  103fe7:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103fee:	8b 45 08             	mov    0x8(%ebp),%eax
  103ff1:	83 e0 02             	and    $0x2,%eax
  103ff4:	85 c0                	test   %eax,%eax
  103ff6:	74 04                	je     103ffc <perm2str+0x2d>
  103ff8:	b0 77                	mov    $0x77,%al
  103ffa:	eb 02                	jmp    103ffe <perm2str+0x2f>
  103ffc:	b0 2d                	mov    $0x2d,%al
  103ffe:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  104003:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  10400a:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  10400f:	5d                   	pop    %ebp
  104010:	c3                   	ret    

00104011 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  104011:	55                   	push   %ebp
  104012:	89 e5                	mov    %esp,%ebp
  104014:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  104017:	8b 45 10             	mov    0x10(%ebp),%eax
  10401a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10401d:	72 0d                	jb     10402c <get_pgtable_items+0x1b>
        return 0;
  10401f:	b8 00 00 00 00       	mov    $0x0,%eax
  104024:	e9 98 00 00 00       	jmp    1040c1 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  104029:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  10402c:	8b 45 10             	mov    0x10(%ebp),%eax
  10402f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104032:	73 18                	jae    10404c <get_pgtable_items+0x3b>
  104034:	8b 45 10             	mov    0x10(%ebp),%eax
  104037:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10403e:	8b 45 14             	mov    0x14(%ebp),%eax
  104041:	01 d0                	add    %edx,%eax
  104043:	8b 00                	mov    (%eax),%eax
  104045:	83 e0 01             	and    $0x1,%eax
  104048:	85 c0                	test   %eax,%eax
  10404a:	74 dd                	je     104029 <get_pgtable_items+0x18>
    }
    if (start < right) {
  10404c:	8b 45 10             	mov    0x10(%ebp),%eax
  10404f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104052:	73 68                	jae    1040bc <get_pgtable_items+0xab>
        if (left_store != NULL) {
  104054:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  104058:	74 08                	je     104062 <get_pgtable_items+0x51>
            *left_store = start;
  10405a:	8b 45 18             	mov    0x18(%ebp),%eax
  10405d:	8b 55 10             	mov    0x10(%ebp),%edx
  104060:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  104062:	8b 45 10             	mov    0x10(%ebp),%eax
  104065:	8d 50 01             	lea    0x1(%eax),%edx
  104068:	89 55 10             	mov    %edx,0x10(%ebp)
  10406b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104072:	8b 45 14             	mov    0x14(%ebp),%eax
  104075:	01 d0                	add    %edx,%eax
  104077:	8b 00                	mov    (%eax),%eax
  104079:	83 e0 07             	and    $0x7,%eax
  10407c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10407f:	eb 03                	jmp    104084 <get_pgtable_items+0x73>
            start ++;
  104081:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104084:	8b 45 10             	mov    0x10(%ebp),%eax
  104087:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10408a:	73 1d                	jae    1040a9 <get_pgtable_items+0x98>
  10408c:	8b 45 10             	mov    0x10(%ebp),%eax
  10408f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104096:	8b 45 14             	mov    0x14(%ebp),%eax
  104099:	01 d0                	add    %edx,%eax
  10409b:	8b 00                	mov    (%eax),%eax
  10409d:	83 e0 07             	and    $0x7,%eax
  1040a0:	89 c2                	mov    %eax,%edx
  1040a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040a5:	39 c2                	cmp    %eax,%edx
  1040a7:	74 d8                	je     104081 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  1040a9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1040ad:	74 08                	je     1040b7 <get_pgtable_items+0xa6>
            *right_store = start;
  1040af:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1040b2:	8b 55 10             	mov    0x10(%ebp),%edx
  1040b5:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1040b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040ba:	eb 05                	jmp    1040c1 <get_pgtable_items+0xb0>
    }
    return 0;
  1040bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1040c1:	c9                   	leave  
  1040c2:	c3                   	ret    

001040c3 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1040c3:	55                   	push   %ebp
  1040c4:	89 e5                	mov    %esp,%ebp
  1040c6:	57                   	push   %edi
  1040c7:	56                   	push   %esi
  1040c8:	53                   	push   %ebx
  1040c9:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1040cc:	c7 04 24 90 6c 10 00 	movl   $0x106c90,(%esp)
  1040d3:	e8 ba c1 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  1040d8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1040df:	e9 fa 00 00 00       	jmp    1041de <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1040e7:	89 04 24             	mov    %eax,(%esp)
  1040ea:	e8 e0 fe ff ff       	call   103fcf <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1040ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1040f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040f5:	29 d1                	sub    %edx,%ecx
  1040f7:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040f9:	89 d6                	mov    %edx,%esi
  1040fb:	c1 e6 16             	shl    $0x16,%esi
  1040fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104101:	89 d3                	mov    %edx,%ebx
  104103:	c1 e3 16             	shl    $0x16,%ebx
  104106:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104109:	89 d1                	mov    %edx,%ecx
  10410b:	c1 e1 16             	shl    $0x16,%ecx
  10410e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104111:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104114:	29 d7                	sub    %edx,%edi
  104116:	89 fa                	mov    %edi,%edx
  104118:	89 44 24 14          	mov    %eax,0x14(%esp)
  10411c:	89 74 24 10          	mov    %esi,0x10(%esp)
  104120:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104124:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104128:	89 54 24 04          	mov    %edx,0x4(%esp)
  10412c:	c7 04 24 c1 6c 10 00 	movl   $0x106cc1,(%esp)
  104133:	e8 5a c1 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  104138:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10413b:	c1 e0 0a             	shl    $0xa,%eax
  10413e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104141:	eb 54                	jmp    104197 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104146:	89 04 24             	mov    %eax,(%esp)
  104149:	e8 81 fe ff ff       	call   103fcf <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10414e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104151:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104154:	29 d1                	sub    %edx,%ecx
  104156:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104158:	89 d6                	mov    %edx,%esi
  10415a:	c1 e6 0c             	shl    $0xc,%esi
  10415d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104160:	89 d3                	mov    %edx,%ebx
  104162:	c1 e3 0c             	shl    $0xc,%ebx
  104165:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104168:	89 d1                	mov    %edx,%ecx
  10416a:	c1 e1 0c             	shl    $0xc,%ecx
  10416d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104170:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104173:	29 d7                	sub    %edx,%edi
  104175:	89 fa                	mov    %edi,%edx
  104177:	89 44 24 14          	mov    %eax,0x14(%esp)
  10417b:	89 74 24 10          	mov    %esi,0x10(%esp)
  10417f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104183:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104187:	89 54 24 04          	mov    %edx,0x4(%esp)
  10418b:	c7 04 24 e0 6c 10 00 	movl   $0x106ce0,(%esp)
  104192:	e8 fb c0 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104197:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10419c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10419f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041a2:	89 d3                	mov    %edx,%ebx
  1041a4:	c1 e3 0a             	shl    $0xa,%ebx
  1041a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041aa:	89 d1                	mov    %edx,%ecx
  1041ac:	c1 e1 0a             	shl    $0xa,%ecx
  1041af:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  1041b2:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041b6:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1041b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1041c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041c9:	89 0c 24             	mov    %ecx,(%esp)
  1041cc:	e8 40 fe ff ff       	call   104011 <get_pgtable_items>
  1041d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041d8:	0f 85 65 ff ff ff    	jne    104143 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1041de:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1041e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1041e6:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1041e9:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041ed:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1041f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041f4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1041f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041fc:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104203:	00 
  104204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10420b:	e8 01 fe ff ff       	call   104011 <get_pgtable_items>
  104210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104213:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104217:	0f 85 c7 fe ff ff    	jne    1040e4 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  10421d:	c7 04 24 04 6d 10 00 	movl   $0x106d04,(%esp)
  104224:	e8 69 c0 ff ff       	call   100292 <cprintf>
}
  104229:	90                   	nop
  10422a:	83 c4 4c             	add    $0x4c,%esp
  10422d:	5b                   	pop    %ebx
  10422e:	5e                   	pop    %esi
  10422f:	5f                   	pop    %edi
  104230:	5d                   	pop    %ebp
  104231:	c3                   	ret    

00104232 <page2ppn>:
page2ppn(struct Page *page) {
  104232:	55                   	push   %ebp
  104233:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104235:	8b 45 08             	mov    0x8(%ebp),%eax
  104238:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  10423e:	29 d0                	sub    %edx,%eax
  104240:	c1 f8 02             	sar    $0x2,%eax
  104243:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104249:	5d                   	pop    %ebp
  10424a:	c3                   	ret    

0010424b <page2pa>:
page2pa(struct Page *page) {
  10424b:	55                   	push   %ebp
  10424c:	89 e5                	mov    %esp,%ebp
  10424e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104251:	8b 45 08             	mov    0x8(%ebp),%eax
  104254:	89 04 24             	mov    %eax,(%esp)
  104257:	e8 d6 ff ff ff       	call   104232 <page2ppn>
  10425c:	c1 e0 0c             	shl    $0xc,%eax
}
  10425f:	c9                   	leave  
  104260:	c3                   	ret    

00104261 <page_ref>:
page_ref(struct Page *page) {
  104261:	55                   	push   %ebp
  104262:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104264:	8b 45 08             	mov    0x8(%ebp),%eax
  104267:	8b 00                	mov    (%eax),%eax
}
  104269:	5d                   	pop    %ebp
  10426a:	c3                   	ret    

0010426b <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10426b:	55                   	push   %ebp
  10426c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10426e:	8b 45 08             	mov    0x8(%ebp),%eax
  104271:	8b 55 0c             	mov    0xc(%ebp),%edx
  104274:	89 10                	mov    %edx,(%eax)
}
  104276:	90                   	nop
  104277:	5d                   	pop    %ebp
  104278:	c3                   	ret    

00104279 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104279:	55                   	push   %ebp
  10427a:	89 e5                	mov    %esp,%ebp
  10427c:	83 ec 10             	sub    $0x10,%esp
  10427f:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104286:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104289:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10428c:	89 50 04             	mov    %edx,0x4(%eax)
  10428f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104292:	8b 50 04             	mov    0x4(%eax),%edx
  104295:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104298:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10429a:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  1042a1:	00 00 00 
}
  1042a4:	90                   	nop
  1042a5:	c9                   	leave  
  1042a6:	c3                   	ret    

001042a7 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1042a7:	55                   	push   %ebp
  1042a8:	89 e5                	mov    %esp,%ebp
  1042aa:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1042ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1042b1:	75 24                	jne    1042d7 <default_init_memmap+0x30>
  1042b3:	c7 44 24 0c 38 6d 10 	movl   $0x106d38,0xc(%esp)
  1042ba:	00 
  1042bb:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1042c2:	00 
  1042c3:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1042ca:	00 
  1042cb:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1042d2:	e8 12 c1 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  1042d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1042da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1042dd:	eb 7d                	jmp    10435c <default_init_memmap+0xb5>
        assert(PageReserved(p));
  1042df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042e2:	83 c0 04             	add    $0x4,%eax
  1042e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1042ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1042ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1042f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1042f5:	0f a3 10             	bt     %edx,(%eax)
  1042f8:	19 c0                	sbb    %eax,%eax
  1042fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1042fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104301:	0f 95 c0             	setne  %al
  104304:	0f b6 c0             	movzbl %al,%eax
  104307:	85 c0                	test   %eax,%eax
  104309:	75 24                	jne    10432f <default_init_memmap+0x88>
  10430b:	c7 44 24 0c 69 6d 10 	movl   $0x106d69,0xc(%esp)
  104312:	00 
  104313:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  10431a:	00 
  10431b:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  104322:	00 
  104323:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10432a:	e8 ba c0 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  10432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104332:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  104339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10433c:	8b 50 08             	mov    0x8(%eax),%edx
  10433f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104342:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  104345:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10434c:	00 
  10434d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104350:	89 04 24             	mov    %eax,(%esp)
  104353:	e8 13 ff ff ff       	call   10426b <set_page_ref>
    for (; p != base + n; p ++) {
  104358:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10435c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10435f:	89 d0                	mov    %edx,%eax
  104361:	c1 e0 02             	shl    $0x2,%eax
  104364:	01 d0                	add    %edx,%eax
  104366:	c1 e0 02             	shl    $0x2,%eax
  104369:	89 c2                	mov    %eax,%edx
  10436b:	8b 45 08             	mov    0x8(%ebp),%eax
  10436e:	01 d0                	add    %edx,%eax
  104370:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104373:	0f 85 66 ff ff ff    	jne    1042df <default_init_memmap+0x38>
    }
    base->property = n;
  104379:	8b 45 08             	mov    0x8(%ebp),%eax
  10437c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10437f:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104382:	8b 45 08             	mov    0x8(%ebp),%eax
  104385:	83 c0 04             	add    $0x4,%eax
  104388:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10438f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104392:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104395:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104398:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  10439b:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  1043a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1043a4:	01 d0                	add    %edx,%eax
  1043a6:	a3 24 af 11 00       	mov    %eax,0x11af24
    list_add_before(&free_list, &(base->page_link));
  1043ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1043ae:	83 c0 0c             	add    $0xc,%eax
  1043b1:	c7 45 e4 1c af 11 00 	movl   $0x11af1c,-0x1c(%ebp)
  1043b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1043bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043be:	8b 00                	mov    (%eax),%eax
  1043c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1043c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1043c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1043c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1043cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043d5:	89 10                	mov    %edx,(%eax)
  1043d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043da:	8b 10                	mov    (%eax),%edx
  1043dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043df:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1043e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043e8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1043eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043f1:	89 10                	mov    %edx,(%eax)
}
  1043f3:	90                   	nop
  1043f4:	c9                   	leave  
  1043f5:	c3                   	ret    

001043f6 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  1043f6:	55                   	push   %ebp
  1043f7:	89 e5                	mov    %esp,%ebp
  1043f9:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1043fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104400:	75 24                	jne    104426 <default_alloc_pages+0x30>
  104402:	c7 44 24 0c 38 6d 10 	movl   $0x106d38,0xc(%esp)
  104409:	00 
  10440a:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104411:	00 
  104412:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  104419:	00 
  10441a:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104421:	e8 c3 bf ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  104426:	a1 24 af 11 00       	mov    0x11af24,%eax
  10442b:	39 45 08             	cmp    %eax,0x8(%ebp)
  10442e:	76 0a                	jbe    10443a <default_alloc_pages+0x44>
        return NULL;
  104430:	b8 00 00 00 00       	mov    $0x0,%eax
  104435:	e9 49 01 00 00       	jmp    104583 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
  10443a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104441:	c7 45 f0 1c af 11 00 	movl   $0x11af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104448:	eb 1c                	jmp    104466 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  10444a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10444d:	83 e8 0c             	sub    $0xc,%eax
  104450:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  104453:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104456:	8b 40 08             	mov    0x8(%eax),%eax
  104459:	39 45 08             	cmp    %eax,0x8(%ebp)
  10445c:	77 08                	ja     104466 <default_alloc_pages+0x70>
            page = p;
  10445e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104461:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  104464:	eb 18                	jmp    10447e <default_alloc_pages+0x88>
  104466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104469:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  10446c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10446f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104472:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104475:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  10447c:	75 cc                	jne    10444a <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  10447e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104482:	0f 84 f8 00 00 00    	je     104580 <default_alloc_pages+0x18a>
        if (page->property > n) {
  104488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10448b:	8b 40 08             	mov    0x8(%eax),%eax
  10448e:	39 45 08             	cmp    %eax,0x8(%ebp)
  104491:	0f 83 98 00 00 00    	jae    10452f <default_alloc_pages+0x139>
            struct Page *p = page + n;
  104497:	8b 55 08             	mov    0x8(%ebp),%edx
  10449a:	89 d0                	mov    %edx,%eax
  10449c:	c1 e0 02             	shl    $0x2,%eax
  10449f:	01 d0                	add    %edx,%eax
  1044a1:	c1 e0 02             	shl    $0x2,%eax
  1044a4:	89 c2                	mov    %eax,%edx
  1044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044a9:	01 d0                	add    %edx,%eax
  1044ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  1044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044b1:	8b 40 08             	mov    0x8(%eax),%eax
  1044b4:	2b 45 08             	sub    0x8(%ebp),%eax
  1044b7:	89 c2                	mov    %eax,%edx
  1044b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044bc:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  1044bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044c2:	83 c0 04             	add    $0x4,%eax
  1044c5:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  1044cc:	89 45 c0             	mov    %eax,-0x40(%ebp)
  1044cf:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1044d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1044d5:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
  1044d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044db:	83 c0 0c             	add    $0xc,%eax
  1044de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1044e1:	83 c2 0c             	add    $0xc,%edx
  1044e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1044e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1044ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1044ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1044f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  1044f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1044f9:	8b 40 04             	mov    0x4(%eax),%eax
  1044fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1044ff:	89 55 d0             	mov    %edx,-0x30(%ebp)
  104502:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104505:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104508:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  10450b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10450e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104511:	89 10                	mov    %edx,(%eax)
  104513:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104516:	8b 10                	mov    (%eax),%edx
  104518:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10451b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10451e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104521:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104524:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104527:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10452a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10452d:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  10452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104532:	83 c0 0c             	add    $0xc,%eax
  104535:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  104538:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10453b:	8b 40 04             	mov    0x4(%eax),%eax
  10453e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104541:	8b 12                	mov    (%edx),%edx
  104543:	89 55 b0             	mov    %edx,-0x50(%ebp)
  104546:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104549:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10454c:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10454f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104552:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104555:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104558:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  10455a:	a1 24 af 11 00       	mov    0x11af24,%eax
  10455f:	2b 45 08             	sub    0x8(%ebp),%eax
  104562:	a3 24 af 11 00       	mov    %eax,0x11af24
        ClearPageProperty(page);
  104567:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10456a:	83 c0 04             	add    $0x4,%eax
  10456d:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  104574:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104577:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10457a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10457d:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104583:	c9                   	leave  
  104584:	c3                   	ret    

00104585 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  104585:	55                   	push   %ebp
  104586:	89 e5                	mov    %esp,%ebp
  104588:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  10458e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104592:	75 24                	jne    1045b8 <default_free_pages+0x33>
  104594:	c7 44 24 0c 38 6d 10 	movl   $0x106d38,0xc(%esp)
  10459b:	00 
  10459c:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1045a3:	00 
  1045a4:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  1045ab:	00 
  1045ac:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1045b3:	e8 31 be ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  1045b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1045bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1045be:	e9 9d 00 00 00       	jmp    104660 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  1045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c6:	83 c0 04             	add    $0x4,%eax
  1045c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1045d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1045d9:	0f a3 10             	bt     %edx,(%eax)
  1045dc:	19 c0                	sbb    %eax,%eax
  1045de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1045e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045e5:	0f 95 c0             	setne  %al
  1045e8:	0f b6 c0             	movzbl %al,%eax
  1045eb:	85 c0                	test   %eax,%eax
  1045ed:	75 2c                	jne    10461b <default_free_pages+0x96>
  1045ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045f2:	83 c0 04             	add    $0x4,%eax
  1045f5:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1045fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104602:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104605:	0f a3 10             	bt     %edx,(%eax)
  104608:	19 c0                	sbb    %eax,%eax
  10460a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10460d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  104611:	0f 95 c0             	setne  %al
  104614:	0f b6 c0             	movzbl %al,%eax
  104617:	85 c0                	test   %eax,%eax
  104619:	74 24                	je     10463f <default_free_pages+0xba>
  10461b:	c7 44 24 0c 7c 6d 10 	movl   $0x106d7c,0xc(%esp)
  104622:	00 
  104623:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  10462a:	00 
  10462b:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  104632:	00 
  104633:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10463a:	e8 aa bd ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  10463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104642:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  104649:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104650:	00 
  104651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104654:	89 04 24             	mov    %eax,(%esp)
  104657:	e8 0f fc ff ff       	call   10426b <set_page_ref>
    for (; p != base + n; p ++) {
  10465c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104660:	8b 55 0c             	mov    0xc(%ebp),%edx
  104663:	89 d0                	mov    %edx,%eax
  104665:	c1 e0 02             	shl    $0x2,%eax
  104668:	01 d0                	add    %edx,%eax
  10466a:	c1 e0 02             	shl    $0x2,%eax
  10466d:	89 c2                	mov    %eax,%edx
  10466f:	8b 45 08             	mov    0x8(%ebp),%eax
  104672:	01 d0                	add    %edx,%eax
  104674:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104677:	0f 85 46 ff ff ff    	jne    1045c3 <default_free_pages+0x3e>
    }
    base->property = n;
  10467d:	8b 45 08             	mov    0x8(%ebp),%eax
  104680:	8b 55 0c             	mov    0xc(%ebp),%edx
  104683:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104686:	8b 45 08             	mov    0x8(%ebp),%eax
  104689:	83 c0 04             	add    $0x4,%eax
  10468c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104693:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104696:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104699:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10469c:	0f ab 10             	bts    %edx,(%eax)
  10469f:	c7 45 d4 1c af 11 00 	movl   $0x11af1c,-0x2c(%ebp)
    return listelm->next;
  1046a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046a9:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  1046ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1046af:	e9 08 01 00 00       	jmp    1047bc <default_free_pages+0x237>
        p = le2page(le, page_link);
  1046b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046b7:	83 e8 0c             	sub    $0xc,%eax
  1046ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1046bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046c0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1046c3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1046c6:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  1046c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  1046cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1046cf:	8b 50 08             	mov    0x8(%eax),%edx
  1046d2:	89 d0                	mov    %edx,%eax
  1046d4:	c1 e0 02             	shl    $0x2,%eax
  1046d7:	01 d0                	add    %edx,%eax
  1046d9:	c1 e0 02             	shl    $0x2,%eax
  1046dc:	89 c2                	mov    %eax,%edx
  1046de:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e1:	01 d0                	add    %edx,%eax
  1046e3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046e6:	75 5a                	jne    104742 <default_free_pages+0x1bd>
            base->property += p->property;
  1046e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1046eb:	8b 50 08             	mov    0x8(%eax),%edx
  1046ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046f1:	8b 40 08             	mov    0x8(%eax),%eax
  1046f4:	01 c2                	add    %eax,%edx
  1046f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1046f9:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  1046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ff:	83 c0 04             	add    $0x4,%eax
  104702:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  104709:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10470c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10470f:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104712:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  104715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104718:	83 c0 0c             	add    $0xc,%eax
  10471b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10471e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104721:	8b 40 04             	mov    0x4(%eax),%eax
  104724:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104727:	8b 12                	mov    (%edx),%edx
  104729:	89 55 c0             	mov    %edx,-0x40(%ebp)
  10472c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  10472f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104732:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104735:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104738:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10473b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10473e:	89 10                	mov    %edx,(%eax)
  104740:	eb 7a                	jmp    1047bc <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  104742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104745:	8b 50 08             	mov    0x8(%eax),%edx
  104748:	89 d0                	mov    %edx,%eax
  10474a:	c1 e0 02             	shl    $0x2,%eax
  10474d:	01 d0                	add    %edx,%eax
  10474f:	c1 e0 02             	shl    $0x2,%eax
  104752:	89 c2                	mov    %eax,%edx
  104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104757:	01 d0                	add    %edx,%eax
  104759:	39 45 08             	cmp    %eax,0x8(%ebp)
  10475c:	75 5e                	jne    1047bc <default_free_pages+0x237>
            p->property += base->property;
  10475e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104761:	8b 50 08             	mov    0x8(%eax),%edx
  104764:	8b 45 08             	mov    0x8(%ebp),%eax
  104767:	8b 40 08             	mov    0x8(%eax),%eax
  10476a:	01 c2                	add    %eax,%edx
  10476c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10476f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104772:	8b 45 08             	mov    0x8(%ebp),%eax
  104775:	83 c0 04             	add    $0x4,%eax
  104778:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  10477f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104782:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104785:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104788:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  10478b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10478e:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104794:	83 c0 0c             	add    $0xc,%eax
  104797:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  10479a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10479d:	8b 40 04             	mov    0x4(%eax),%eax
  1047a0:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1047a3:	8b 12                	mov    (%edx),%edx
  1047a5:	89 55 ac             	mov    %edx,-0x54(%ebp)
  1047a8:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  1047ab:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1047ae:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1047b1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1047b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1047b7:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1047ba:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  1047bc:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  1047c3:	0f 85 eb fe ff ff    	jne    1046b4 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
  1047c9:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  1047cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047d2:	01 d0                	add    %edx,%eax
  1047d4:	a3 24 af 11 00       	mov    %eax,0x11af24
  1047d9:	c7 45 9c 1c af 11 00 	movl   $0x11af1c,-0x64(%ebp)
    return listelm->next;
  1047e0:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1047e3:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
  1047e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1047e9:	eb 74                	jmp    10485f <default_free_pages+0x2da>
        p = le2page(le, page_link);
  1047eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047ee:	83 e8 0c             	sub    $0xc,%eax
  1047f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(base + base->property <= p) {
  1047f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1047f7:	8b 50 08             	mov    0x8(%eax),%edx
  1047fa:	89 d0                	mov    %edx,%eax
  1047fc:	c1 e0 02             	shl    $0x2,%eax
  1047ff:	01 d0                	add    %edx,%eax
  104801:	c1 e0 02             	shl    $0x2,%eax
  104804:	89 c2                	mov    %eax,%edx
  104806:	8b 45 08             	mov    0x8(%ebp),%eax
  104809:	01 d0                	add    %edx,%eax
  10480b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10480e:	72 40                	jb     104850 <default_free_pages+0x2cb>
            assert(base + base->property != p);
  104810:	8b 45 08             	mov    0x8(%ebp),%eax
  104813:	8b 50 08             	mov    0x8(%eax),%edx
  104816:	89 d0                	mov    %edx,%eax
  104818:	c1 e0 02             	shl    $0x2,%eax
  10481b:	01 d0                	add    %edx,%eax
  10481d:	c1 e0 02             	shl    $0x2,%eax
  104820:	89 c2                	mov    %eax,%edx
  104822:	8b 45 08             	mov    0x8(%ebp),%eax
  104825:	01 d0                	add    %edx,%eax
  104827:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10482a:	75 3e                	jne    10486a <default_free_pages+0x2e5>
  10482c:	c7 44 24 0c a1 6d 10 	movl   $0x106da1,0xc(%esp)
  104833:	00 
  104834:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  10483b:	00 
  10483c:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  104843:	00 
  104844:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10484b:	e8 99 bb ff ff       	call   1003e9 <__panic>
  104850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104853:	89 45 98             	mov    %eax,-0x68(%ebp)
  104856:	8b 45 98             	mov    -0x68(%ebp),%eax
  104859:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
  10485c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10485f:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  104866:	75 83                	jne    1047eb <default_free_pages+0x266>
  104868:	eb 01                	jmp    10486b <default_free_pages+0x2e6>
            break;
  10486a:	90                   	nop
        }
    }
    list_add_before(le, &(base->page_link));
  10486b:	8b 45 08             	mov    0x8(%ebp),%eax
  10486e:	8d 50 0c             	lea    0xc(%eax),%edx
  104871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104874:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104877:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  10487a:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10487d:	8b 00                	mov    (%eax),%eax
  10487f:	8b 55 90             	mov    -0x70(%ebp),%edx
  104882:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104885:	89 45 88             	mov    %eax,-0x78(%ebp)
  104888:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10488b:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  10488e:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104891:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104894:	89 10                	mov    %edx,(%eax)
  104896:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104899:	8b 10                	mov    (%eax),%edx
  10489b:	8b 45 88             	mov    -0x78(%ebp),%eax
  10489e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1048a1:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1048a4:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1048a7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1048aa:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1048ad:	8b 55 88             	mov    -0x78(%ebp),%edx
  1048b0:	89 10                	mov    %edx,(%eax)
}
  1048b2:	90                   	nop
  1048b3:	c9                   	leave  
  1048b4:	c3                   	ret    

001048b5 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  1048b5:	55                   	push   %ebp
  1048b6:	89 e5                	mov    %esp,%ebp
    return nr_free;
  1048b8:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  1048bd:	5d                   	pop    %ebp
  1048be:	c3                   	ret    

001048bf <basic_check>:

static void
basic_check(void) {
  1048bf:	55                   	push   %ebp
  1048c0:	89 e5                	mov    %esp,%ebp
  1048c2:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  1048c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1048cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  1048d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048df:	e8 fc e2 ff ff       	call   102be0 <alloc_pages>
  1048e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1048e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1048eb:	75 24                	jne    104911 <basic_check+0x52>
  1048ed:	c7 44 24 0c bc 6d 10 	movl   $0x106dbc,0xc(%esp)
  1048f4:	00 
  1048f5:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1048fc:	00 
  1048fd:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  104904:	00 
  104905:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10490c:	e8 d8 ba ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104911:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104918:	e8 c3 e2 ff ff       	call   102be0 <alloc_pages>
  10491d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104920:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104924:	75 24                	jne    10494a <basic_check+0x8b>
  104926:	c7 44 24 0c d8 6d 10 	movl   $0x106dd8,0xc(%esp)
  10492d:	00 
  10492e:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104935:	00 
  104936:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  10493d:	00 
  10493e:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104945:	e8 9f ba ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10494a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104951:	e8 8a e2 ff ff       	call   102be0 <alloc_pages>
  104956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104959:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10495d:	75 24                	jne    104983 <basic_check+0xc4>
  10495f:	c7 44 24 0c f4 6d 10 	movl   $0x106df4,0xc(%esp)
  104966:	00 
  104967:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  10496e:	00 
  10496f:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  104976:	00 
  104977:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10497e:	e8 66 ba ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104983:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104986:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104989:	74 10                	je     10499b <basic_check+0xdc>
  10498b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10498e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104991:	74 08                	je     10499b <basic_check+0xdc>
  104993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104996:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104999:	75 24                	jne    1049bf <basic_check+0x100>
  10499b:	c7 44 24 0c 10 6e 10 	movl   $0x106e10,0xc(%esp)
  1049a2:	00 
  1049a3:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1049aa:	00 
  1049ab:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  1049b2:	00 
  1049b3:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1049ba:	e8 2a ba ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  1049bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049c2:	89 04 24             	mov    %eax,(%esp)
  1049c5:	e8 97 f8 ff ff       	call   104261 <page_ref>
  1049ca:	85 c0                	test   %eax,%eax
  1049cc:	75 1e                	jne    1049ec <basic_check+0x12d>
  1049ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049d1:	89 04 24             	mov    %eax,(%esp)
  1049d4:	e8 88 f8 ff ff       	call   104261 <page_ref>
  1049d9:	85 c0                	test   %eax,%eax
  1049db:	75 0f                	jne    1049ec <basic_check+0x12d>
  1049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049e0:	89 04 24             	mov    %eax,(%esp)
  1049e3:	e8 79 f8 ff ff       	call   104261 <page_ref>
  1049e8:	85 c0                	test   %eax,%eax
  1049ea:	74 24                	je     104a10 <basic_check+0x151>
  1049ec:	c7 44 24 0c 34 6e 10 	movl   $0x106e34,0xc(%esp)
  1049f3:	00 
  1049f4:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1049fb:	00 
  1049fc:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  104a03:	00 
  104a04:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104a0b:	e8 d9 b9 ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104a10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a13:	89 04 24             	mov    %eax,(%esp)
  104a16:	e8 30 f8 ff ff       	call   10424b <page2pa>
  104a1b:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104a21:	c1 e2 0c             	shl    $0xc,%edx
  104a24:	39 d0                	cmp    %edx,%eax
  104a26:	72 24                	jb     104a4c <basic_check+0x18d>
  104a28:	c7 44 24 0c 70 6e 10 	movl   $0x106e70,0xc(%esp)
  104a2f:	00 
  104a30:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104a37:	00 
  104a38:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  104a3f:	00 
  104a40:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104a47:	e8 9d b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a4f:	89 04 24             	mov    %eax,(%esp)
  104a52:	e8 f4 f7 ff ff       	call   10424b <page2pa>
  104a57:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104a5d:	c1 e2 0c             	shl    $0xc,%edx
  104a60:	39 d0                	cmp    %edx,%eax
  104a62:	72 24                	jb     104a88 <basic_check+0x1c9>
  104a64:	c7 44 24 0c 8d 6e 10 	movl   $0x106e8d,0xc(%esp)
  104a6b:	00 
  104a6c:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104a73:	00 
  104a74:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  104a7b:	00 
  104a7c:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104a83:	e8 61 b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a8b:	89 04 24             	mov    %eax,(%esp)
  104a8e:	e8 b8 f7 ff ff       	call   10424b <page2pa>
  104a93:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104a99:	c1 e2 0c             	shl    $0xc,%edx
  104a9c:	39 d0                	cmp    %edx,%eax
  104a9e:	72 24                	jb     104ac4 <basic_check+0x205>
  104aa0:	c7 44 24 0c aa 6e 10 	movl   $0x106eaa,0xc(%esp)
  104aa7:	00 
  104aa8:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104aaf:	00 
  104ab0:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104ab7:	00 
  104ab8:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104abf:	e8 25 b9 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104ac4:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104ac9:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104acf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104ad2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104ad5:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104adc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104adf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104ae2:	89 50 04             	mov    %edx,0x4(%eax)
  104ae5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104ae8:	8b 50 04             	mov    0x4(%eax),%edx
  104aeb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104aee:	89 10                	mov    %edx,(%eax)
  104af0:	c7 45 e0 1c af 11 00 	movl   $0x11af1c,-0x20(%ebp)
    return list->next == list;
  104af7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104afa:	8b 40 04             	mov    0x4(%eax),%eax
  104afd:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104b00:	0f 94 c0             	sete   %al
  104b03:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104b06:	85 c0                	test   %eax,%eax
  104b08:	75 24                	jne    104b2e <basic_check+0x26f>
  104b0a:	c7 44 24 0c c7 6e 10 	movl   $0x106ec7,0xc(%esp)
  104b11:	00 
  104b12:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104b19:	00 
  104b1a:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  104b21:	00 
  104b22:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104b29:	e8 bb b8 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104b2e:	a1 24 af 11 00       	mov    0x11af24,%eax
  104b33:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104b36:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104b3d:	00 00 00 

    assert(alloc_page() == NULL);
  104b40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b47:	e8 94 e0 ff ff       	call   102be0 <alloc_pages>
  104b4c:	85 c0                	test   %eax,%eax
  104b4e:	74 24                	je     104b74 <basic_check+0x2b5>
  104b50:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  104b57:	00 
  104b58:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104b5f:	00 
  104b60:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104b67:	00 
  104b68:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104b6f:	e8 75 b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104b74:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b7b:	00 
  104b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b7f:	89 04 24             	mov    %eax,(%esp)
  104b82:	e8 91 e0 ff ff       	call   102c18 <free_pages>
    free_page(p1);
  104b87:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b8e:	00 
  104b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b92:	89 04 24             	mov    %eax,(%esp)
  104b95:	e8 7e e0 ff ff       	call   102c18 <free_pages>
    free_page(p2);
  104b9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ba1:	00 
  104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ba5:	89 04 24             	mov    %eax,(%esp)
  104ba8:	e8 6b e0 ff ff       	call   102c18 <free_pages>
    assert(nr_free == 3);
  104bad:	a1 24 af 11 00       	mov    0x11af24,%eax
  104bb2:	83 f8 03             	cmp    $0x3,%eax
  104bb5:	74 24                	je     104bdb <basic_check+0x31c>
  104bb7:	c7 44 24 0c f3 6e 10 	movl   $0x106ef3,0xc(%esp)
  104bbe:	00 
  104bbf:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104bc6:	00 
  104bc7:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104bce:	00 
  104bcf:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104bd6:	e8 0e b8 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104bdb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104be2:	e8 f9 df ff ff       	call   102be0 <alloc_pages>
  104be7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104bea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104bee:	75 24                	jne    104c14 <basic_check+0x355>
  104bf0:	c7 44 24 0c bc 6d 10 	movl   $0x106dbc,0xc(%esp)
  104bf7:	00 
  104bf8:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104bff:	00 
  104c00:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  104c07:	00 
  104c08:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104c0f:	e8 d5 b7 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104c14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c1b:	e8 c0 df ff ff       	call   102be0 <alloc_pages>
  104c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c27:	75 24                	jne    104c4d <basic_check+0x38e>
  104c29:	c7 44 24 0c d8 6d 10 	movl   $0x106dd8,0xc(%esp)
  104c30:	00 
  104c31:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104c38:	00 
  104c39:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  104c40:	00 
  104c41:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104c48:	e8 9c b7 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104c4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c54:	e8 87 df ff ff       	call   102be0 <alloc_pages>
  104c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104c60:	75 24                	jne    104c86 <basic_check+0x3c7>
  104c62:	c7 44 24 0c f4 6d 10 	movl   $0x106df4,0xc(%esp)
  104c69:	00 
  104c6a:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104c71:	00 
  104c72:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104c79:	00 
  104c7a:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104c81:	e8 63 b7 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104c86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c8d:	e8 4e df ff ff       	call   102be0 <alloc_pages>
  104c92:	85 c0                	test   %eax,%eax
  104c94:	74 24                	je     104cba <basic_check+0x3fb>
  104c96:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  104c9d:	00 
  104c9e:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104ca5:	00 
  104ca6:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  104cad:	00 
  104cae:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104cb5:	e8 2f b7 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104cba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104cc1:	00 
  104cc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104cc5:	89 04 24             	mov    %eax,(%esp)
  104cc8:	e8 4b df ff ff       	call   102c18 <free_pages>
  104ccd:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
  104cd4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104cd7:	8b 40 04             	mov    0x4(%eax),%eax
  104cda:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104cdd:	0f 94 c0             	sete   %al
  104ce0:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104ce3:	85 c0                	test   %eax,%eax
  104ce5:	74 24                	je     104d0b <basic_check+0x44c>
  104ce7:	c7 44 24 0c 00 6f 10 	movl   $0x106f00,0xc(%esp)
  104cee:	00 
  104cef:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104cf6:	00 
  104cf7:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104cfe:	00 
  104cff:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104d06:	e8 de b6 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104d0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d12:	e8 c9 de ff ff       	call   102be0 <alloc_pages>
  104d17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104d1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d1d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104d20:	74 24                	je     104d46 <basic_check+0x487>
  104d22:	c7 44 24 0c 18 6f 10 	movl   $0x106f18,0xc(%esp)
  104d29:	00 
  104d2a:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104d31:	00 
  104d32:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  104d39:	00 
  104d3a:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104d41:	e8 a3 b6 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104d46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d4d:	e8 8e de ff ff       	call   102be0 <alloc_pages>
  104d52:	85 c0                	test   %eax,%eax
  104d54:	74 24                	je     104d7a <basic_check+0x4bb>
  104d56:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  104d5d:	00 
  104d5e:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104d65:	00 
  104d66:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  104d6d:	00 
  104d6e:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104d75:	e8 6f b6 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104d7a:	a1 24 af 11 00       	mov    0x11af24,%eax
  104d7f:	85 c0                	test   %eax,%eax
  104d81:	74 24                	je     104da7 <basic_check+0x4e8>
  104d83:	c7 44 24 0c 31 6f 10 	movl   $0x106f31,0xc(%esp)
  104d8a:	00 
  104d8b:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104d92:	00 
  104d93:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  104d9a:	00 
  104d9b:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104da2:	e8 42 b6 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104da7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104daa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104dad:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104db2:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104db8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104dbb:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104dc0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104dc7:	00 
  104dc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dcb:	89 04 24             	mov    %eax,(%esp)
  104dce:	e8 45 de ff ff       	call   102c18 <free_pages>
    free_page(p1);
  104dd3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104dda:	00 
  104ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104dde:	89 04 24             	mov    %eax,(%esp)
  104de1:	e8 32 de ff ff       	call   102c18 <free_pages>
    free_page(p2);
  104de6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ded:	00 
  104dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104df1:	89 04 24             	mov    %eax,(%esp)
  104df4:	e8 1f de ff ff       	call   102c18 <free_pages>
}
  104df9:	90                   	nop
  104dfa:	c9                   	leave  
  104dfb:	c3                   	ret    

00104dfc <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104dfc:	55                   	push   %ebp
  104dfd:	89 e5                	mov    %esp,%ebp
  104dff:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104e05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104e13:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104e1a:	eb 6a                	jmp    104e86 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104e1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e1f:	83 e8 0c             	sub    $0xc,%eax
  104e22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104e25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104e28:	83 c0 04             	add    $0x4,%eax
  104e2b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104e32:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104e35:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104e38:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104e3b:	0f a3 10             	bt     %edx,(%eax)
  104e3e:	19 c0                	sbb    %eax,%eax
  104e40:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104e43:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104e47:	0f 95 c0             	setne  %al
  104e4a:	0f b6 c0             	movzbl %al,%eax
  104e4d:	85 c0                	test   %eax,%eax
  104e4f:	75 24                	jne    104e75 <default_check+0x79>
  104e51:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  104e58:	00 
  104e59:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104e60:	00 
  104e61:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  104e68:	00 
  104e69:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104e70:	e8 74 b5 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104e75:	ff 45 f4             	incl   -0xc(%ebp)
  104e78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104e7b:	8b 50 08             	mov    0x8(%eax),%edx
  104e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e81:	01 d0                	add    %edx,%eax
  104e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e89:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104e8c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e8f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104e92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e95:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104e9c:	0f 85 7a ff ff ff    	jne    104e1c <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104ea2:	e8 a4 dd ff ff       	call   102c4b <nr_free_pages>
  104ea7:	89 c2                	mov    %eax,%edx
  104ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104eac:	39 c2                	cmp    %eax,%edx
  104eae:	74 24                	je     104ed4 <default_check+0xd8>
  104eb0:	c7 44 24 0c 4e 6f 10 	movl   $0x106f4e,0xc(%esp)
  104eb7:	00 
  104eb8:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104ebf:	00 
  104ec0:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104ec7:	00 
  104ec8:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104ecf:	e8 15 b5 ff ff       	call   1003e9 <__panic>

    basic_check();
  104ed4:	e8 e6 f9 ff ff       	call   1048bf <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104ed9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104ee0:	e8 fb dc ff ff       	call   102be0 <alloc_pages>
  104ee5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104ee8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104eec:	75 24                	jne    104f12 <default_check+0x116>
  104eee:	c7 44 24 0c 67 6f 10 	movl   $0x106f67,0xc(%esp)
  104ef5:	00 
  104ef6:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104efd:	00 
  104efe:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  104f05:	00 
  104f06:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104f0d:	e8 d7 b4 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104f12:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f15:	83 c0 04             	add    $0x4,%eax
  104f18:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104f1f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104f22:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104f25:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104f28:	0f a3 10             	bt     %edx,(%eax)
  104f2b:	19 c0                	sbb    %eax,%eax
  104f2d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104f30:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104f34:	0f 95 c0             	setne  %al
  104f37:	0f b6 c0             	movzbl %al,%eax
  104f3a:	85 c0                	test   %eax,%eax
  104f3c:	74 24                	je     104f62 <default_check+0x166>
  104f3e:	c7 44 24 0c 72 6f 10 	movl   $0x106f72,0xc(%esp)
  104f45:	00 
  104f46:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104f4d:	00 
  104f4e:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104f55:	00 
  104f56:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104f5d:	e8 87 b4 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104f62:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104f67:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104f6d:	89 45 80             	mov    %eax,-0x80(%ebp)
  104f70:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104f73:	c7 45 b0 1c af 11 00 	movl   $0x11af1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104f7a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f7d:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104f80:	89 50 04             	mov    %edx,0x4(%eax)
  104f83:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f86:	8b 50 04             	mov    0x4(%eax),%edx
  104f89:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f8c:	89 10                	mov    %edx,(%eax)
  104f8e:	c7 45 b4 1c af 11 00 	movl   $0x11af1c,-0x4c(%ebp)
    return list->next == list;
  104f95:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f98:	8b 40 04             	mov    0x4(%eax),%eax
  104f9b:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104f9e:	0f 94 c0             	sete   %al
  104fa1:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104fa4:	85 c0                	test   %eax,%eax
  104fa6:	75 24                	jne    104fcc <default_check+0x1d0>
  104fa8:	c7 44 24 0c c7 6e 10 	movl   $0x106ec7,0xc(%esp)
  104faf:	00 
  104fb0:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104fb7:	00 
  104fb8:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  104fbf:	00 
  104fc0:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104fc7:	e8 1d b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104fcc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104fd3:	e8 08 dc ff ff       	call   102be0 <alloc_pages>
  104fd8:	85 c0                	test   %eax,%eax
  104fda:	74 24                	je     105000 <default_check+0x204>
  104fdc:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  104fe3:	00 
  104fe4:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  104feb:	00 
  104fec:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  104ff3:	00 
  104ff4:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  104ffb:	e8 e9 b3 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  105000:	a1 24 af 11 00       	mov    0x11af24,%eax
  105005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  105008:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  10500f:	00 00 00 

    free_pages(p0 + 2, 3);
  105012:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105015:	83 c0 28             	add    $0x28,%eax
  105018:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10501f:	00 
  105020:	89 04 24             	mov    %eax,(%esp)
  105023:	e8 f0 db ff ff       	call   102c18 <free_pages>
    assert(alloc_pages(4) == NULL);
  105028:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10502f:	e8 ac db ff ff       	call   102be0 <alloc_pages>
  105034:	85 c0                	test   %eax,%eax
  105036:	74 24                	je     10505c <default_check+0x260>
  105038:	c7 44 24 0c 84 6f 10 	movl   $0x106f84,0xc(%esp)
  10503f:	00 
  105040:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105047:	00 
  105048:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  10504f:	00 
  105050:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105057:	e8 8d b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10505c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10505f:	83 c0 28             	add    $0x28,%eax
  105062:	83 c0 04             	add    $0x4,%eax
  105065:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10506c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10506f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105072:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105075:	0f a3 10             	bt     %edx,(%eax)
  105078:	19 c0                	sbb    %eax,%eax
  10507a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10507d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  105081:	0f 95 c0             	setne  %al
  105084:	0f b6 c0             	movzbl %al,%eax
  105087:	85 c0                	test   %eax,%eax
  105089:	74 0e                	je     105099 <default_check+0x29d>
  10508b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10508e:	83 c0 28             	add    $0x28,%eax
  105091:	8b 40 08             	mov    0x8(%eax),%eax
  105094:	83 f8 03             	cmp    $0x3,%eax
  105097:	74 24                	je     1050bd <default_check+0x2c1>
  105099:	c7 44 24 0c 9c 6f 10 	movl   $0x106f9c,0xc(%esp)
  1050a0:	00 
  1050a1:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1050a8:	00 
  1050a9:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  1050b0:	00 
  1050b1:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1050b8:	e8 2c b3 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1050bd:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1050c4:	e8 17 db ff ff       	call   102be0 <alloc_pages>
  1050c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1050cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1050d0:	75 24                	jne    1050f6 <default_check+0x2fa>
  1050d2:	c7 44 24 0c c8 6f 10 	movl   $0x106fc8,0xc(%esp)
  1050d9:	00 
  1050da:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1050e1:	00 
  1050e2:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1050e9:	00 
  1050ea:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1050f1:	e8 f3 b2 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1050f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050fd:	e8 de da ff ff       	call   102be0 <alloc_pages>
  105102:	85 c0                	test   %eax,%eax
  105104:	74 24                	je     10512a <default_check+0x32e>
  105106:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  10510d:	00 
  10510e:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105115:	00 
  105116:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  10511d:	00 
  10511e:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105125:	e8 bf b2 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  10512a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10512d:	83 c0 28             	add    $0x28,%eax
  105130:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105133:	74 24                	je     105159 <default_check+0x35d>
  105135:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  10513c:	00 
  10513d:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105144:	00 
  105145:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  10514c:	00 
  10514d:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105154:	e8 90 b2 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  105159:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10515c:	83 c0 14             	add    $0x14,%eax
  10515f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  105162:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105169:	00 
  10516a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10516d:	89 04 24             	mov    %eax,(%esp)
  105170:	e8 a3 da ff ff       	call   102c18 <free_pages>
    free_pages(p1, 3);
  105175:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10517c:	00 
  10517d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105180:	89 04 24             	mov    %eax,(%esp)
  105183:	e8 90 da ff ff       	call   102c18 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105188:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10518b:	83 c0 04             	add    $0x4,%eax
  10518e:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105195:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105198:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10519b:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10519e:	0f a3 10             	bt     %edx,(%eax)
  1051a1:	19 c0                	sbb    %eax,%eax
  1051a3:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1051a6:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1051aa:	0f 95 c0             	setne  %al
  1051ad:	0f b6 c0             	movzbl %al,%eax
  1051b0:	85 c0                	test   %eax,%eax
  1051b2:	74 0b                	je     1051bf <default_check+0x3c3>
  1051b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051b7:	8b 40 08             	mov    0x8(%eax),%eax
  1051ba:	83 f8 01             	cmp    $0x1,%eax
  1051bd:	74 24                	je     1051e3 <default_check+0x3e7>
  1051bf:	c7 44 24 0c f4 6f 10 	movl   $0x106ff4,0xc(%esp)
  1051c6:	00 
  1051c7:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1051ce:	00 
  1051cf:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  1051d6:	00 
  1051d7:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1051de:	e8 06 b2 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1051e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051e6:	83 c0 04             	add    $0x4,%eax
  1051e9:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1051f0:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1051f3:	8b 45 90             	mov    -0x70(%ebp),%eax
  1051f6:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1051f9:	0f a3 10             	bt     %edx,(%eax)
  1051fc:	19 c0                	sbb    %eax,%eax
  1051fe:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  105201:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105205:	0f 95 c0             	setne  %al
  105208:	0f b6 c0             	movzbl %al,%eax
  10520b:	85 c0                	test   %eax,%eax
  10520d:	74 0b                	je     10521a <default_check+0x41e>
  10520f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105212:	8b 40 08             	mov    0x8(%eax),%eax
  105215:	83 f8 03             	cmp    $0x3,%eax
  105218:	74 24                	je     10523e <default_check+0x442>
  10521a:	c7 44 24 0c 1c 70 10 	movl   $0x10701c,0xc(%esp)
  105221:	00 
  105222:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105229:	00 
  10522a:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  105231:	00 
  105232:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105239:	e8 ab b1 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10523e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105245:	e8 96 d9 ff ff       	call   102be0 <alloc_pages>
  10524a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10524d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105250:	83 e8 14             	sub    $0x14,%eax
  105253:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105256:	74 24                	je     10527c <default_check+0x480>
  105258:	c7 44 24 0c 42 70 10 	movl   $0x107042,0xc(%esp)
  10525f:	00 
  105260:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105267:	00 
  105268:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  10526f:	00 
  105270:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105277:	e8 6d b1 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  10527c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105283:	00 
  105284:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105287:	89 04 24             	mov    %eax,(%esp)
  10528a:	e8 89 d9 ff ff       	call   102c18 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10528f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105296:	e8 45 d9 ff ff       	call   102be0 <alloc_pages>
  10529b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10529e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052a1:	83 c0 14             	add    $0x14,%eax
  1052a4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1052a7:	74 24                	je     1052cd <default_check+0x4d1>
  1052a9:	c7 44 24 0c 60 70 10 	movl   $0x107060,0xc(%esp)
  1052b0:	00 
  1052b1:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1052b8:	00 
  1052b9:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  1052c0:	00 
  1052c1:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1052c8:	e8 1c b1 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  1052cd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1052d4:	00 
  1052d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052d8:	89 04 24             	mov    %eax,(%esp)
  1052db:	e8 38 d9 ff ff       	call   102c18 <free_pages>
    free_page(p2);
  1052e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052e7:	00 
  1052e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052eb:	89 04 24             	mov    %eax,(%esp)
  1052ee:	e8 25 d9 ff ff       	call   102c18 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1052f3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1052fa:	e8 e1 d8 ff ff       	call   102be0 <alloc_pages>
  1052ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105302:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105306:	75 24                	jne    10532c <default_check+0x530>
  105308:	c7 44 24 0c 80 70 10 	movl   $0x107080,0xc(%esp)
  10530f:	00 
  105310:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105317:	00 
  105318:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  10531f:	00 
  105320:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105327:	e8 bd b0 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  10532c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105333:	e8 a8 d8 ff ff       	call   102be0 <alloc_pages>
  105338:	85 c0                	test   %eax,%eax
  10533a:	74 24                	je     105360 <default_check+0x564>
  10533c:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  105343:	00 
  105344:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  10534b:	00 
  10534c:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  105353:	00 
  105354:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10535b:	e8 89 b0 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  105360:	a1 24 af 11 00       	mov    0x11af24,%eax
  105365:	85 c0                	test   %eax,%eax
  105367:	74 24                	je     10538d <default_check+0x591>
  105369:	c7 44 24 0c 31 6f 10 	movl   $0x106f31,0xc(%esp)
  105370:	00 
  105371:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105378:	00 
  105379:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  105380:	00 
  105381:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105388:	e8 5c b0 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  10538d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105390:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  105395:	8b 45 80             	mov    -0x80(%ebp),%eax
  105398:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10539b:	a3 1c af 11 00       	mov    %eax,0x11af1c
  1053a0:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  1053a6:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1053ad:	00 
  1053ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053b1:	89 04 24             	mov    %eax,(%esp)
  1053b4:	e8 5f d8 ff ff       	call   102c18 <free_pages>

    le = &free_list;
  1053b9:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1053c0:	eb 5a                	jmp    10541c <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  1053c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053c5:	8b 40 04             	mov    0x4(%eax),%eax
  1053c8:	8b 00                	mov    (%eax),%eax
  1053ca:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1053cd:	75 0d                	jne    1053dc <default_check+0x5e0>
  1053cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053d2:	8b 00                	mov    (%eax),%eax
  1053d4:	8b 40 04             	mov    0x4(%eax),%eax
  1053d7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1053da:	74 24                	je     105400 <default_check+0x604>
  1053dc:	c7 44 24 0c a0 70 10 	movl   $0x1070a0,0xc(%esp)
  1053e3:	00 
  1053e4:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  1053eb:	00 
  1053ec:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  1053f3:	00 
  1053f4:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  1053fb:	e8 e9 af ff ff       	call   1003e9 <__panic>
        struct Page *p = le2page(le, page_link);
  105400:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105403:	83 e8 0c             	sub    $0xc,%eax
  105406:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  105409:	ff 4d f4             	decl   -0xc(%ebp)
  10540c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10540f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105412:	8b 40 08             	mov    0x8(%eax),%eax
  105415:	29 c2                	sub    %eax,%edx
  105417:	89 d0                	mov    %edx,%eax
  105419:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10541c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10541f:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  105422:	8b 45 88             	mov    -0x78(%ebp),%eax
  105425:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105428:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10542b:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  105432:	75 8e                	jne    1053c2 <default_check+0x5c6>
    }
    assert(count == 0);
  105434:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105438:	74 24                	je     10545e <default_check+0x662>
  10543a:	c7 44 24 0c cd 70 10 	movl   $0x1070cd,0xc(%esp)
  105441:	00 
  105442:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105449:	00 
  10544a:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  105451:	00 
  105452:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105459:	e8 8b af ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  10545e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105462:	74 24                	je     105488 <default_check+0x68c>
  105464:	c7 44 24 0c d8 70 10 	movl   $0x1070d8,0xc(%esp)
  10546b:	00 
  10546c:	c7 44 24 08 3e 6d 10 	movl   $0x106d3e,0x8(%esp)
  105473:	00 
  105474:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  10547b:	00 
  10547c:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  105483:	e8 61 af ff ff       	call   1003e9 <__panic>
}
  105488:	90                   	nop
  105489:	c9                   	leave  
  10548a:	c3                   	ret    

0010548b <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10548b:	55                   	push   %ebp
  10548c:	89 e5                	mov    %esp,%ebp
  10548e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105491:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105498:	eb 03                	jmp    10549d <strlen+0x12>
        cnt ++;
  10549a:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  10549d:	8b 45 08             	mov    0x8(%ebp),%eax
  1054a0:	8d 50 01             	lea    0x1(%eax),%edx
  1054a3:	89 55 08             	mov    %edx,0x8(%ebp)
  1054a6:	0f b6 00             	movzbl (%eax),%eax
  1054a9:	84 c0                	test   %al,%al
  1054ab:	75 ed                	jne    10549a <strlen+0xf>
    }
    return cnt;
  1054ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1054b0:	c9                   	leave  
  1054b1:	c3                   	ret    

001054b2 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1054b2:	55                   	push   %ebp
  1054b3:	89 e5                	mov    %esp,%ebp
  1054b5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1054b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1054bf:	eb 03                	jmp    1054c4 <strnlen+0x12>
        cnt ++;
  1054c1:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1054c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1054c7:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054ca:	73 10                	jae    1054dc <strnlen+0x2a>
  1054cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1054cf:	8d 50 01             	lea    0x1(%eax),%edx
  1054d2:	89 55 08             	mov    %edx,0x8(%ebp)
  1054d5:	0f b6 00             	movzbl (%eax),%eax
  1054d8:	84 c0                	test   %al,%al
  1054da:	75 e5                	jne    1054c1 <strnlen+0xf>
    }
    return cnt;
  1054dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1054df:	c9                   	leave  
  1054e0:	c3                   	ret    

001054e1 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1054e1:	55                   	push   %ebp
  1054e2:	89 e5                	mov    %esp,%ebp
  1054e4:	57                   	push   %edi
  1054e5:	56                   	push   %esi
  1054e6:	83 ec 20             	sub    $0x20,%esp
  1054e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1054ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1054f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1054f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054fb:	89 d1                	mov    %edx,%ecx
  1054fd:	89 c2                	mov    %eax,%edx
  1054ff:	89 ce                	mov    %ecx,%esi
  105501:	89 d7                	mov    %edx,%edi
  105503:	ac                   	lods   %ds:(%esi),%al
  105504:	aa                   	stos   %al,%es:(%edi)
  105505:	84 c0                	test   %al,%al
  105507:	75 fa                	jne    105503 <strcpy+0x22>
  105509:	89 fa                	mov    %edi,%edx
  10550b:	89 f1                	mov    %esi,%ecx
  10550d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105510:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105513:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105516:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  105519:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10551a:	83 c4 20             	add    $0x20,%esp
  10551d:	5e                   	pop    %esi
  10551e:	5f                   	pop    %edi
  10551f:	5d                   	pop    %ebp
  105520:	c3                   	ret    

00105521 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105521:	55                   	push   %ebp
  105522:	89 e5                	mov    %esp,%ebp
  105524:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105527:	8b 45 08             	mov    0x8(%ebp),%eax
  10552a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10552d:	eb 1e                	jmp    10554d <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  10552f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105532:	0f b6 10             	movzbl (%eax),%edx
  105535:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105538:	88 10                	mov    %dl,(%eax)
  10553a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10553d:	0f b6 00             	movzbl (%eax),%eax
  105540:	84 c0                	test   %al,%al
  105542:	74 03                	je     105547 <strncpy+0x26>
            src ++;
  105544:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105547:	ff 45 fc             	incl   -0x4(%ebp)
  10554a:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  10554d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105551:	75 dc                	jne    10552f <strncpy+0xe>
    }
    return dst;
  105553:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105556:	c9                   	leave  
  105557:	c3                   	ret    

00105558 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105558:	55                   	push   %ebp
  105559:	89 e5                	mov    %esp,%ebp
  10555b:	57                   	push   %edi
  10555c:	56                   	push   %esi
  10555d:	83 ec 20             	sub    $0x20,%esp
  105560:	8b 45 08             	mov    0x8(%ebp),%eax
  105563:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105566:	8b 45 0c             	mov    0xc(%ebp),%eax
  105569:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  10556c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10556f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105572:	89 d1                	mov    %edx,%ecx
  105574:	89 c2                	mov    %eax,%edx
  105576:	89 ce                	mov    %ecx,%esi
  105578:	89 d7                	mov    %edx,%edi
  10557a:	ac                   	lods   %ds:(%esi),%al
  10557b:	ae                   	scas   %es:(%edi),%al
  10557c:	75 08                	jne    105586 <strcmp+0x2e>
  10557e:	84 c0                	test   %al,%al
  105580:	75 f8                	jne    10557a <strcmp+0x22>
  105582:	31 c0                	xor    %eax,%eax
  105584:	eb 04                	jmp    10558a <strcmp+0x32>
  105586:	19 c0                	sbb    %eax,%eax
  105588:	0c 01                	or     $0x1,%al
  10558a:	89 fa                	mov    %edi,%edx
  10558c:	89 f1                	mov    %esi,%ecx
  10558e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105591:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105594:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105597:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  10559a:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10559b:	83 c4 20             	add    $0x20,%esp
  10559e:	5e                   	pop    %esi
  10559f:	5f                   	pop    %edi
  1055a0:	5d                   	pop    %ebp
  1055a1:	c3                   	ret    

001055a2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1055a2:	55                   	push   %ebp
  1055a3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1055a5:	eb 09                	jmp    1055b0 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1055a7:	ff 4d 10             	decl   0x10(%ebp)
  1055aa:	ff 45 08             	incl   0x8(%ebp)
  1055ad:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1055b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055b4:	74 1a                	je     1055d0 <strncmp+0x2e>
  1055b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b9:	0f b6 00             	movzbl (%eax),%eax
  1055bc:	84 c0                	test   %al,%al
  1055be:	74 10                	je     1055d0 <strncmp+0x2e>
  1055c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c3:	0f b6 10             	movzbl (%eax),%edx
  1055c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055c9:	0f b6 00             	movzbl (%eax),%eax
  1055cc:	38 c2                	cmp    %al,%dl
  1055ce:	74 d7                	je     1055a7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1055d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055d4:	74 18                	je     1055ee <strncmp+0x4c>
  1055d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d9:	0f b6 00             	movzbl (%eax),%eax
  1055dc:	0f b6 d0             	movzbl %al,%edx
  1055df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055e2:	0f b6 00             	movzbl (%eax),%eax
  1055e5:	0f b6 c0             	movzbl %al,%eax
  1055e8:	29 c2                	sub    %eax,%edx
  1055ea:	89 d0                	mov    %edx,%eax
  1055ec:	eb 05                	jmp    1055f3 <strncmp+0x51>
  1055ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1055f3:	5d                   	pop    %ebp
  1055f4:	c3                   	ret    

001055f5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1055f5:	55                   	push   %ebp
  1055f6:	89 e5                	mov    %esp,%ebp
  1055f8:	83 ec 04             	sub    $0x4,%esp
  1055fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055fe:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105601:	eb 13                	jmp    105616 <strchr+0x21>
        if (*s == c) {
  105603:	8b 45 08             	mov    0x8(%ebp),%eax
  105606:	0f b6 00             	movzbl (%eax),%eax
  105609:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10560c:	75 05                	jne    105613 <strchr+0x1e>
            return (char *)s;
  10560e:	8b 45 08             	mov    0x8(%ebp),%eax
  105611:	eb 12                	jmp    105625 <strchr+0x30>
        }
        s ++;
  105613:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105616:	8b 45 08             	mov    0x8(%ebp),%eax
  105619:	0f b6 00             	movzbl (%eax),%eax
  10561c:	84 c0                	test   %al,%al
  10561e:	75 e3                	jne    105603 <strchr+0xe>
    }
    return NULL;
  105620:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105625:	c9                   	leave  
  105626:	c3                   	ret    

00105627 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105627:	55                   	push   %ebp
  105628:	89 e5                	mov    %esp,%ebp
  10562a:	83 ec 04             	sub    $0x4,%esp
  10562d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105630:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105633:	eb 0e                	jmp    105643 <strfind+0x1c>
        if (*s == c) {
  105635:	8b 45 08             	mov    0x8(%ebp),%eax
  105638:	0f b6 00             	movzbl (%eax),%eax
  10563b:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10563e:	74 0f                	je     10564f <strfind+0x28>
            break;
        }
        s ++;
  105640:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105643:	8b 45 08             	mov    0x8(%ebp),%eax
  105646:	0f b6 00             	movzbl (%eax),%eax
  105649:	84 c0                	test   %al,%al
  10564b:	75 e8                	jne    105635 <strfind+0xe>
  10564d:	eb 01                	jmp    105650 <strfind+0x29>
            break;
  10564f:	90                   	nop
    }
    return (char *)s;
  105650:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105653:	c9                   	leave  
  105654:	c3                   	ret    

00105655 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105655:	55                   	push   %ebp
  105656:	89 e5                	mov    %esp,%ebp
  105658:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10565b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105662:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105669:	eb 03                	jmp    10566e <strtol+0x19>
        s ++;
  10566b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10566e:	8b 45 08             	mov    0x8(%ebp),%eax
  105671:	0f b6 00             	movzbl (%eax),%eax
  105674:	3c 20                	cmp    $0x20,%al
  105676:	74 f3                	je     10566b <strtol+0x16>
  105678:	8b 45 08             	mov    0x8(%ebp),%eax
  10567b:	0f b6 00             	movzbl (%eax),%eax
  10567e:	3c 09                	cmp    $0x9,%al
  105680:	74 e9                	je     10566b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105682:	8b 45 08             	mov    0x8(%ebp),%eax
  105685:	0f b6 00             	movzbl (%eax),%eax
  105688:	3c 2b                	cmp    $0x2b,%al
  10568a:	75 05                	jne    105691 <strtol+0x3c>
        s ++;
  10568c:	ff 45 08             	incl   0x8(%ebp)
  10568f:	eb 14                	jmp    1056a5 <strtol+0x50>
    }
    else if (*s == '-') {
  105691:	8b 45 08             	mov    0x8(%ebp),%eax
  105694:	0f b6 00             	movzbl (%eax),%eax
  105697:	3c 2d                	cmp    $0x2d,%al
  105699:	75 0a                	jne    1056a5 <strtol+0x50>
        s ++, neg = 1;
  10569b:	ff 45 08             	incl   0x8(%ebp)
  10569e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1056a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056a9:	74 06                	je     1056b1 <strtol+0x5c>
  1056ab:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1056af:	75 22                	jne    1056d3 <strtol+0x7e>
  1056b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b4:	0f b6 00             	movzbl (%eax),%eax
  1056b7:	3c 30                	cmp    $0x30,%al
  1056b9:	75 18                	jne    1056d3 <strtol+0x7e>
  1056bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1056be:	40                   	inc    %eax
  1056bf:	0f b6 00             	movzbl (%eax),%eax
  1056c2:	3c 78                	cmp    $0x78,%al
  1056c4:	75 0d                	jne    1056d3 <strtol+0x7e>
        s += 2, base = 16;
  1056c6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1056ca:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1056d1:	eb 29                	jmp    1056fc <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1056d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056d7:	75 16                	jne    1056ef <strtol+0x9a>
  1056d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1056dc:	0f b6 00             	movzbl (%eax),%eax
  1056df:	3c 30                	cmp    $0x30,%al
  1056e1:	75 0c                	jne    1056ef <strtol+0x9a>
        s ++, base = 8;
  1056e3:	ff 45 08             	incl   0x8(%ebp)
  1056e6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1056ed:	eb 0d                	jmp    1056fc <strtol+0xa7>
    }
    else if (base == 0) {
  1056ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056f3:	75 07                	jne    1056fc <strtol+0xa7>
        base = 10;
  1056f5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1056fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1056ff:	0f b6 00             	movzbl (%eax),%eax
  105702:	3c 2f                	cmp    $0x2f,%al
  105704:	7e 1b                	jle    105721 <strtol+0xcc>
  105706:	8b 45 08             	mov    0x8(%ebp),%eax
  105709:	0f b6 00             	movzbl (%eax),%eax
  10570c:	3c 39                	cmp    $0x39,%al
  10570e:	7f 11                	jg     105721 <strtol+0xcc>
            dig = *s - '0';
  105710:	8b 45 08             	mov    0x8(%ebp),%eax
  105713:	0f b6 00             	movzbl (%eax),%eax
  105716:	0f be c0             	movsbl %al,%eax
  105719:	83 e8 30             	sub    $0x30,%eax
  10571c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10571f:	eb 48                	jmp    105769 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105721:	8b 45 08             	mov    0x8(%ebp),%eax
  105724:	0f b6 00             	movzbl (%eax),%eax
  105727:	3c 60                	cmp    $0x60,%al
  105729:	7e 1b                	jle    105746 <strtol+0xf1>
  10572b:	8b 45 08             	mov    0x8(%ebp),%eax
  10572e:	0f b6 00             	movzbl (%eax),%eax
  105731:	3c 7a                	cmp    $0x7a,%al
  105733:	7f 11                	jg     105746 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105735:	8b 45 08             	mov    0x8(%ebp),%eax
  105738:	0f b6 00             	movzbl (%eax),%eax
  10573b:	0f be c0             	movsbl %al,%eax
  10573e:	83 e8 57             	sub    $0x57,%eax
  105741:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105744:	eb 23                	jmp    105769 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105746:	8b 45 08             	mov    0x8(%ebp),%eax
  105749:	0f b6 00             	movzbl (%eax),%eax
  10574c:	3c 40                	cmp    $0x40,%al
  10574e:	7e 3b                	jle    10578b <strtol+0x136>
  105750:	8b 45 08             	mov    0x8(%ebp),%eax
  105753:	0f b6 00             	movzbl (%eax),%eax
  105756:	3c 5a                	cmp    $0x5a,%al
  105758:	7f 31                	jg     10578b <strtol+0x136>
            dig = *s - 'A' + 10;
  10575a:	8b 45 08             	mov    0x8(%ebp),%eax
  10575d:	0f b6 00             	movzbl (%eax),%eax
  105760:	0f be c0             	movsbl %al,%eax
  105763:	83 e8 37             	sub    $0x37,%eax
  105766:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10576c:	3b 45 10             	cmp    0x10(%ebp),%eax
  10576f:	7d 19                	jge    10578a <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105771:	ff 45 08             	incl   0x8(%ebp)
  105774:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105777:	0f af 45 10          	imul   0x10(%ebp),%eax
  10577b:	89 c2                	mov    %eax,%edx
  10577d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105780:	01 d0                	add    %edx,%eax
  105782:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  105785:	e9 72 ff ff ff       	jmp    1056fc <strtol+0xa7>
            break;
  10578a:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10578b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10578f:	74 08                	je     105799 <strtol+0x144>
        *endptr = (char *) s;
  105791:	8b 45 0c             	mov    0xc(%ebp),%eax
  105794:	8b 55 08             	mov    0x8(%ebp),%edx
  105797:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105799:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10579d:	74 07                	je     1057a6 <strtol+0x151>
  10579f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057a2:	f7 d8                	neg    %eax
  1057a4:	eb 03                	jmp    1057a9 <strtol+0x154>
  1057a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1057a9:	c9                   	leave  
  1057aa:	c3                   	ret    

001057ab <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1057ab:	55                   	push   %ebp
  1057ac:	89 e5                	mov    %esp,%ebp
  1057ae:	57                   	push   %edi
  1057af:	83 ec 24             	sub    $0x24,%esp
  1057b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057b5:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1057b8:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1057bc:	8b 55 08             	mov    0x8(%ebp),%edx
  1057bf:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1057c2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1057c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1057c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1057cb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1057ce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1057d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1057d5:	89 d7                	mov    %edx,%edi
  1057d7:	f3 aa                	rep stos %al,%es:(%edi)
  1057d9:	89 fa                	mov    %edi,%edx
  1057db:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1057de:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1057e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057e4:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1057e5:	83 c4 24             	add    $0x24,%esp
  1057e8:	5f                   	pop    %edi
  1057e9:	5d                   	pop    %ebp
  1057ea:	c3                   	ret    

001057eb <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1057eb:	55                   	push   %ebp
  1057ec:	89 e5                	mov    %esp,%ebp
  1057ee:	57                   	push   %edi
  1057ef:	56                   	push   %esi
  1057f0:	53                   	push   %ebx
  1057f1:	83 ec 30             	sub    $0x30,%esp
  1057f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1057f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105800:	8b 45 10             	mov    0x10(%ebp),%eax
  105803:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105809:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10580c:	73 42                	jae    105850 <memmove+0x65>
  10580e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105811:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105814:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105817:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10581a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10581d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105820:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105823:	c1 e8 02             	shr    $0x2,%eax
  105826:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105828:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10582b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10582e:	89 d7                	mov    %edx,%edi
  105830:	89 c6                	mov    %eax,%esi
  105832:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105834:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105837:	83 e1 03             	and    $0x3,%ecx
  10583a:	74 02                	je     10583e <memmove+0x53>
  10583c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10583e:	89 f0                	mov    %esi,%eax
  105840:	89 fa                	mov    %edi,%edx
  105842:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105845:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105848:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10584b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  10584e:	eb 36                	jmp    105886 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105850:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105853:	8d 50 ff             	lea    -0x1(%eax),%edx
  105856:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105859:	01 c2                	add    %eax,%edx
  10585b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10585e:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105864:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105867:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10586a:	89 c1                	mov    %eax,%ecx
  10586c:	89 d8                	mov    %ebx,%eax
  10586e:	89 d6                	mov    %edx,%esi
  105870:	89 c7                	mov    %eax,%edi
  105872:	fd                   	std    
  105873:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105875:	fc                   	cld    
  105876:	89 f8                	mov    %edi,%eax
  105878:	89 f2                	mov    %esi,%edx
  10587a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  10587d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105880:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105883:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105886:	83 c4 30             	add    $0x30,%esp
  105889:	5b                   	pop    %ebx
  10588a:	5e                   	pop    %esi
  10588b:	5f                   	pop    %edi
  10588c:	5d                   	pop    %ebp
  10588d:	c3                   	ret    

0010588e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10588e:	55                   	push   %ebp
  10588f:	89 e5                	mov    %esp,%ebp
  105891:	57                   	push   %edi
  105892:	56                   	push   %esi
  105893:	83 ec 20             	sub    $0x20,%esp
  105896:	8b 45 08             	mov    0x8(%ebp),%eax
  105899:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10589c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10589f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058a2:	8b 45 10             	mov    0x10(%ebp),%eax
  1058a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1058a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058ab:	c1 e8 02             	shr    $0x2,%eax
  1058ae:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1058b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058b6:	89 d7                	mov    %edx,%edi
  1058b8:	89 c6                	mov    %eax,%esi
  1058ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1058bc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1058bf:	83 e1 03             	and    $0x3,%ecx
  1058c2:	74 02                	je     1058c6 <memcpy+0x38>
  1058c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1058c6:	89 f0                	mov    %esi,%eax
  1058c8:	89 fa                	mov    %edi,%edx
  1058ca:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1058cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1058d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1058d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  1058d6:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1058d7:	83 c4 20             	add    $0x20,%esp
  1058da:	5e                   	pop    %esi
  1058db:	5f                   	pop    %edi
  1058dc:	5d                   	pop    %ebp
  1058dd:	c3                   	ret    

001058de <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1058de:	55                   	push   %ebp
  1058df:	89 e5                	mov    %esp,%ebp
  1058e1:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1058e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1058e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1058ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1058f0:	eb 2e                	jmp    105920 <memcmp+0x42>
        if (*s1 != *s2) {
  1058f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1058f5:	0f b6 10             	movzbl (%eax),%edx
  1058f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058fb:	0f b6 00             	movzbl (%eax),%eax
  1058fe:	38 c2                	cmp    %al,%dl
  105900:	74 18                	je     10591a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105902:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105905:	0f b6 00             	movzbl (%eax),%eax
  105908:	0f b6 d0             	movzbl %al,%edx
  10590b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10590e:	0f b6 00             	movzbl (%eax),%eax
  105911:	0f b6 c0             	movzbl %al,%eax
  105914:	29 c2                	sub    %eax,%edx
  105916:	89 d0                	mov    %edx,%eax
  105918:	eb 18                	jmp    105932 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  10591a:	ff 45 fc             	incl   -0x4(%ebp)
  10591d:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105920:	8b 45 10             	mov    0x10(%ebp),%eax
  105923:	8d 50 ff             	lea    -0x1(%eax),%edx
  105926:	89 55 10             	mov    %edx,0x10(%ebp)
  105929:	85 c0                	test   %eax,%eax
  10592b:	75 c5                	jne    1058f2 <memcmp+0x14>
    }
    return 0;
  10592d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105932:	c9                   	leave  
  105933:	c3                   	ret    

00105934 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105934:	55                   	push   %ebp
  105935:	89 e5                	mov    %esp,%ebp
  105937:	83 ec 58             	sub    $0x58,%esp
  10593a:	8b 45 10             	mov    0x10(%ebp),%eax
  10593d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105940:	8b 45 14             	mov    0x14(%ebp),%eax
  105943:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105946:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105949:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10594c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10594f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105952:	8b 45 18             	mov    0x18(%ebp),%eax
  105955:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105958:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10595b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10595e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105961:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105967:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10596a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10596e:	74 1c                	je     10598c <printnum+0x58>
  105970:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105973:	ba 00 00 00 00       	mov    $0x0,%edx
  105978:	f7 75 e4             	divl   -0x1c(%ebp)
  10597b:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10597e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105981:	ba 00 00 00 00       	mov    $0x0,%edx
  105986:	f7 75 e4             	divl   -0x1c(%ebp)
  105989:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10598c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10598f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105992:	f7 75 e4             	divl   -0x1c(%ebp)
  105995:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105998:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10599b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10599e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1059a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1059a4:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1059a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1059aa:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1059ad:	8b 45 18             	mov    0x18(%ebp),%eax
  1059b0:	ba 00 00 00 00       	mov    $0x0,%edx
  1059b5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1059b8:	72 56                	jb     105a10 <printnum+0xdc>
  1059ba:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1059bd:	77 05                	ja     1059c4 <printnum+0x90>
  1059bf:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1059c2:	72 4c                	jb     105a10 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1059c4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1059c7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1059ca:	8b 45 20             	mov    0x20(%ebp),%eax
  1059cd:	89 44 24 18          	mov    %eax,0x18(%esp)
  1059d1:	89 54 24 14          	mov    %edx,0x14(%esp)
  1059d5:	8b 45 18             	mov    0x18(%ebp),%eax
  1059d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1059dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059df:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1059e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1059ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1059f4:	89 04 24             	mov    %eax,(%esp)
  1059f7:	e8 38 ff ff ff       	call   105934 <printnum>
  1059fc:	eb 1b                	jmp    105a19 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1059fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a05:	8b 45 20             	mov    0x20(%ebp),%eax
  105a08:	89 04 24             	mov    %eax,(%esp)
  105a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a0e:	ff d0                	call   *%eax
        while (-- width > 0)
  105a10:	ff 4d 1c             	decl   0x1c(%ebp)
  105a13:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105a17:	7f e5                	jg     1059fe <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105a19:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105a1c:	05 94 71 10 00       	add    $0x107194,%eax
  105a21:	0f b6 00             	movzbl (%eax),%eax
  105a24:	0f be c0             	movsbl %al,%eax
  105a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  105a2e:	89 04 24             	mov    %eax,(%esp)
  105a31:	8b 45 08             	mov    0x8(%ebp),%eax
  105a34:	ff d0                	call   *%eax
}
  105a36:	90                   	nop
  105a37:	c9                   	leave  
  105a38:	c3                   	ret    

00105a39 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105a39:	55                   	push   %ebp
  105a3a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105a3c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105a40:	7e 14                	jle    105a56 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105a42:	8b 45 08             	mov    0x8(%ebp),%eax
  105a45:	8b 00                	mov    (%eax),%eax
  105a47:	8d 48 08             	lea    0x8(%eax),%ecx
  105a4a:	8b 55 08             	mov    0x8(%ebp),%edx
  105a4d:	89 0a                	mov    %ecx,(%edx)
  105a4f:	8b 50 04             	mov    0x4(%eax),%edx
  105a52:	8b 00                	mov    (%eax),%eax
  105a54:	eb 30                	jmp    105a86 <getuint+0x4d>
    }
    else if (lflag) {
  105a56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105a5a:	74 16                	je     105a72 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5f:	8b 00                	mov    (%eax),%eax
  105a61:	8d 48 04             	lea    0x4(%eax),%ecx
  105a64:	8b 55 08             	mov    0x8(%ebp),%edx
  105a67:	89 0a                	mov    %ecx,(%edx)
  105a69:	8b 00                	mov    (%eax),%eax
  105a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  105a70:	eb 14                	jmp    105a86 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105a72:	8b 45 08             	mov    0x8(%ebp),%eax
  105a75:	8b 00                	mov    (%eax),%eax
  105a77:	8d 48 04             	lea    0x4(%eax),%ecx
  105a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  105a7d:	89 0a                	mov    %ecx,(%edx)
  105a7f:	8b 00                	mov    (%eax),%eax
  105a81:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105a86:	5d                   	pop    %ebp
  105a87:	c3                   	ret    

00105a88 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105a88:	55                   	push   %ebp
  105a89:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105a8b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105a8f:	7e 14                	jle    105aa5 <getint+0x1d>
        return va_arg(*ap, long long);
  105a91:	8b 45 08             	mov    0x8(%ebp),%eax
  105a94:	8b 00                	mov    (%eax),%eax
  105a96:	8d 48 08             	lea    0x8(%eax),%ecx
  105a99:	8b 55 08             	mov    0x8(%ebp),%edx
  105a9c:	89 0a                	mov    %ecx,(%edx)
  105a9e:	8b 50 04             	mov    0x4(%eax),%edx
  105aa1:	8b 00                	mov    (%eax),%eax
  105aa3:	eb 28                	jmp    105acd <getint+0x45>
    }
    else if (lflag) {
  105aa5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105aa9:	74 12                	je     105abd <getint+0x35>
        return va_arg(*ap, long);
  105aab:	8b 45 08             	mov    0x8(%ebp),%eax
  105aae:	8b 00                	mov    (%eax),%eax
  105ab0:	8d 48 04             	lea    0x4(%eax),%ecx
  105ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  105ab6:	89 0a                	mov    %ecx,(%edx)
  105ab8:	8b 00                	mov    (%eax),%eax
  105aba:	99                   	cltd   
  105abb:	eb 10                	jmp    105acd <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105abd:	8b 45 08             	mov    0x8(%ebp),%eax
  105ac0:	8b 00                	mov    (%eax),%eax
  105ac2:	8d 48 04             	lea    0x4(%eax),%ecx
  105ac5:	8b 55 08             	mov    0x8(%ebp),%edx
  105ac8:	89 0a                	mov    %ecx,(%edx)
  105aca:	8b 00                	mov    (%eax),%eax
  105acc:	99                   	cltd   
    }
}
  105acd:	5d                   	pop    %ebp
  105ace:	c3                   	ret    

00105acf <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105acf:	55                   	push   %ebp
  105ad0:	89 e5                	mov    %esp,%ebp
  105ad2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105ad5:	8d 45 14             	lea    0x14(%ebp),%eax
  105ad8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ade:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  105ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  105af0:	8b 45 08             	mov    0x8(%ebp),%eax
  105af3:	89 04 24             	mov    %eax,(%esp)
  105af6:	e8 03 00 00 00       	call   105afe <vprintfmt>
    va_end(ap);
}
  105afb:	90                   	nop
  105afc:	c9                   	leave  
  105afd:	c3                   	ret    

00105afe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105afe:	55                   	push   %ebp
  105aff:	89 e5                	mov    %esp,%ebp
  105b01:	56                   	push   %esi
  105b02:	53                   	push   %ebx
  105b03:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105b06:	eb 17                	jmp    105b1f <vprintfmt+0x21>
            if (ch == '\0') {
  105b08:	85 db                	test   %ebx,%ebx
  105b0a:	0f 84 bf 03 00 00    	je     105ecf <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b17:	89 1c 24             	mov    %ebx,(%esp)
  105b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  105b1d:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  105b22:	8d 50 01             	lea    0x1(%eax),%edx
  105b25:	89 55 10             	mov    %edx,0x10(%ebp)
  105b28:	0f b6 00             	movzbl (%eax),%eax
  105b2b:	0f b6 d8             	movzbl %al,%ebx
  105b2e:	83 fb 25             	cmp    $0x25,%ebx
  105b31:	75 d5                	jne    105b08 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105b33:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105b37:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105b3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b41:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105b44:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105b4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105b4e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105b51:	8b 45 10             	mov    0x10(%ebp),%eax
  105b54:	8d 50 01             	lea    0x1(%eax),%edx
  105b57:	89 55 10             	mov    %edx,0x10(%ebp)
  105b5a:	0f b6 00             	movzbl (%eax),%eax
  105b5d:	0f b6 d8             	movzbl %al,%ebx
  105b60:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105b63:	83 f8 55             	cmp    $0x55,%eax
  105b66:	0f 87 37 03 00 00    	ja     105ea3 <vprintfmt+0x3a5>
  105b6c:	8b 04 85 b8 71 10 00 	mov    0x1071b8(,%eax,4),%eax
  105b73:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105b75:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105b79:	eb d6                	jmp    105b51 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105b7b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105b7f:	eb d0                	jmp    105b51 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105b81:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105b88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105b8b:	89 d0                	mov    %edx,%eax
  105b8d:	c1 e0 02             	shl    $0x2,%eax
  105b90:	01 d0                	add    %edx,%eax
  105b92:	01 c0                	add    %eax,%eax
  105b94:	01 d8                	add    %ebx,%eax
  105b96:	83 e8 30             	sub    $0x30,%eax
  105b99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  105b9f:	0f b6 00             	movzbl (%eax),%eax
  105ba2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105ba5:	83 fb 2f             	cmp    $0x2f,%ebx
  105ba8:	7e 38                	jle    105be2 <vprintfmt+0xe4>
  105baa:	83 fb 39             	cmp    $0x39,%ebx
  105bad:	7f 33                	jg     105be2 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105baf:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105bb2:	eb d4                	jmp    105b88 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105bb4:	8b 45 14             	mov    0x14(%ebp),%eax
  105bb7:	8d 50 04             	lea    0x4(%eax),%edx
  105bba:	89 55 14             	mov    %edx,0x14(%ebp)
  105bbd:	8b 00                	mov    (%eax),%eax
  105bbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105bc2:	eb 1f                	jmp    105be3 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105bc4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105bc8:	79 87                	jns    105b51 <vprintfmt+0x53>
                width = 0;
  105bca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105bd1:	e9 7b ff ff ff       	jmp    105b51 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105bd6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105bdd:	e9 6f ff ff ff       	jmp    105b51 <vprintfmt+0x53>
            goto process_precision;
  105be2:	90                   	nop

        process_precision:
            if (width < 0)
  105be3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105be7:	0f 89 64 ff ff ff    	jns    105b51 <vprintfmt+0x53>
                width = precision, precision = -1;
  105bed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105bf0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105bf3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105bfa:	e9 52 ff ff ff       	jmp    105b51 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105bff:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105c02:	e9 4a ff ff ff       	jmp    105b51 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105c07:	8b 45 14             	mov    0x14(%ebp),%eax
  105c0a:	8d 50 04             	lea    0x4(%eax),%edx
  105c0d:	89 55 14             	mov    %edx,0x14(%ebp)
  105c10:	8b 00                	mov    (%eax),%eax
  105c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c15:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c19:	89 04 24             	mov    %eax,(%esp)
  105c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  105c1f:	ff d0                	call   *%eax
            break;
  105c21:	e9 a4 02 00 00       	jmp    105eca <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105c26:	8b 45 14             	mov    0x14(%ebp),%eax
  105c29:	8d 50 04             	lea    0x4(%eax),%edx
  105c2c:	89 55 14             	mov    %edx,0x14(%ebp)
  105c2f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105c31:	85 db                	test   %ebx,%ebx
  105c33:	79 02                	jns    105c37 <vprintfmt+0x139>
                err = -err;
  105c35:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105c37:	83 fb 06             	cmp    $0x6,%ebx
  105c3a:	7f 0b                	jg     105c47 <vprintfmt+0x149>
  105c3c:	8b 34 9d 78 71 10 00 	mov    0x107178(,%ebx,4),%esi
  105c43:	85 f6                	test   %esi,%esi
  105c45:	75 23                	jne    105c6a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105c47:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105c4b:	c7 44 24 08 a5 71 10 	movl   $0x1071a5,0x8(%esp)
  105c52:	00 
  105c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c5d:	89 04 24             	mov    %eax,(%esp)
  105c60:	e8 6a fe ff ff       	call   105acf <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105c65:	e9 60 02 00 00       	jmp    105eca <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105c6a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105c6e:	c7 44 24 08 ae 71 10 	movl   $0x1071ae,0x8(%esp)
  105c75:	00 
  105c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c79:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c80:	89 04 24             	mov    %eax,(%esp)
  105c83:	e8 47 fe ff ff       	call   105acf <printfmt>
            break;
  105c88:	e9 3d 02 00 00       	jmp    105eca <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  105c90:	8d 50 04             	lea    0x4(%eax),%edx
  105c93:	89 55 14             	mov    %edx,0x14(%ebp)
  105c96:	8b 30                	mov    (%eax),%esi
  105c98:	85 f6                	test   %esi,%esi
  105c9a:	75 05                	jne    105ca1 <vprintfmt+0x1a3>
                p = "(null)";
  105c9c:	be b1 71 10 00       	mov    $0x1071b1,%esi
            }
            if (width > 0 && padc != '-') {
  105ca1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ca5:	7e 76                	jle    105d1d <vprintfmt+0x21f>
  105ca7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105cab:	74 70                	je     105d1d <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cb4:	89 34 24             	mov    %esi,(%esp)
  105cb7:	e8 f6 f7 ff ff       	call   1054b2 <strnlen>
  105cbc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105cbf:	29 c2                	sub    %eax,%edx
  105cc1:	89 d0                	mov    %edx,%eax
  105cc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105cc6:	eb 16                	jmp    105cde <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105cc8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105ccc:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ccf:	89 54 24 04          	mov    %edx,0x4(%esp)
  105cd3:	89 04 24             	mov    %eax,(%esp)
  105cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd9:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105cdb:	ff 4d e8             	decl   -0x18(%ebp)
  105cde:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ce2:	7f e4                	jg     105cc8 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105ce4:	eb 37                	jmp    105d1d <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105ce6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105cea:	74 1f                	je     105d0b <vprintfmt+0x20d>
  105cec:	83 fb 1f             	cmp    $0x1f,%ebx
  105cef:	7e 05                	jle    105cf6 <vprintfmt+0x1f8>
  105cf1:	83 fb 7e             	cmp    $0x7e,%ebx
  105cf4:	7e 15                	jle    105d0b <vprintfmt+0x20d>
                    putch('?', putdat);
  105cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cfd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105d04:	8b 45 08             	mov    0x8(%ebp),%eax
  105d07:	ff d0                	call   *%eax
  105d09:	eb 0f                	jmp    105d1a <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d12:	89 1c 24             	mov    %ebx,(%esp)
  105d15:	8b 45 08             	mov    0x8(%ebp),%eax
  105d18:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105d1a:	ff 4d e8             	decl   -0x18(%ebp)
  105d1d:	89 f0                	mov    %esi,%eax
  105d1f:	8d 70 01             	lea    0x1(%eax),%esi
  105d22:	0f b6 00             	movzbl (%eax),%eax
  105d25:	0f be d8             	movsbl %al,%ebx
  105d28:	85 db                	test   %ebx,%ebx
  105d2a:	74 27                	je     105d53 <vprintfmt+0x255>
  105d2c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105d30:	78 b4                	js     105ce6 <vprintfmt+0x1e8>
  105d32:	ff 4d e4             	decl   -0x1c(%ebp)
  105d35:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105d39:	79 ab                	jns    105ce6 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105d3b:	eb 16                	jmp    105d53 <vprintfmt+0x255>
                putch(' ', putdat);
  105d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d44:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4e:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105d50:	ff 4d e8             	decl   -0x18(%ebp)
  105d53:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d57:	7f e4                	jg     105d3d <vprintfmt+0x23f>
            }
            break;
  105d59:	e9 6c 01 00 00       	jmp    105eca <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d61:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d65:	8d 45 14             	lea    0x14(%ebp),%eax
  105d68:	89 04 24             	mov    %eax,(%esp)
  105d6b:	e8 18 fd ff ff       	call   105a88 <getint>
  105d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d73:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d7c:	85 d2                	test   %edx,%edx
  105d7e:	79 26                	jns    105da6 <vprintfmt+0x2a8>
                putch('-', putdat);
  105d80:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d87:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d91:	ff d0                	call   *%eax
                num = -(long long)num;
  105d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d99:	f7 d8                	neg    %eax
  105d9b:	83 d2 00             	adc    $0x0,%edx
  105d9e:	f7 da                	neg    %edx
  105da0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105da3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105da6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105dad:	e9 a8 00 00 00       	jmp    105e5a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105db5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105db9:	8d 45 14             	lea    0x14(%ebp),%eax
  105dbc:	89 04 24             	mov    %eax,(%esp)
  105dbf:	e8 75 fc ff ff       	call   105a39 <getuint>
  105dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105dc7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105dca:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105dd1:	e9 84 00 00 00       	jmp    105e5a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105dd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ddd:	8d 45 14             	lea    0x14(%ebp),%eax
  105de0:	89 04 24             	mov    %eax,(%esp)
  105de3:	e8 51 fc ff ff       	call   105a39 <getuint>
  105de8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105deb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105dee:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105df5:	eb 63                	jmp    105e5a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105df7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dfe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105e05:	8b 45 08             	mov    0x8(%ebp),%eax
  105e08:	ff d0                	call   *%eax
            putch('x', putdat);
  105e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e11:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105e18:	8b 45 08             	mov    0x8(%ebp),%eax
  105e1b:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105e1d:	8b 45 14             	mov    0x14(%ebp),%eax
  105e20:	8d 50 04             	lea    0x4(%eax),%edx
  105e23:	89 55 14             	mov    %edx,0x14(%ebp)
  105e26:	8b 00                	mov    (%eax),%eax
  105e28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105e32:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105e39:	eb 1f                	jmp    105e5a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e42:	8d 45 14             	lea    0x14(%ebp),%eax
  105e45:	89 04 24             	mov    %eax,(%esp)
  105e48:	e8 ec fb ff ff       	call   105a39 <getuint>
  105e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e50:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105e53:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105e5a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105e5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e61:	89 54 24 18          	mov    %edx,0x18(%esp)
  105e65:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105e68:	89 54 24 14          	mov    %edx,0x14(%esp)
  105e6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  105e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e76:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e81:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e85:	8b 45 08             	mov    0x8(%ebp),%eax
  105e88:	89 04 24             	mov    %eax,(%esp)
  105e8b:	e8 a4 fa ff ff       	call   105934 <printnum>
            break;
  105e90:	eb 38                	jmp    105eca <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e95:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e99:	89 1c 24             	mov    %ebx,(%esp)
  105e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  105e9f:	ff d0                	call   *%eax
            break;
  105ea1:	eb 27                	jmp    105eca <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105eaa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  105eb4:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105eb6:	ff 4d 10             	decl   0x10(%ebp)
  105eb9:	eb 03                	jmp    105ebe <vprintfmt+0x3c0>
  105ebb:	ff 4d 10             	decl   0x10(%ebp)
  105ebe:	8b 45 10             	mov    0x10(%ebp),%eax
  105ec1:	48                   	dec    %eax
  105ec2:	0f b6 00             	movzbl (%eax),%eax
  105ec5:	3c 25                	cmp    $0x25,%al
  105ec7:	75 f2                	jne    105ebb <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105ec9:	90                   	nop
    while (1) {
  105eca:	e9 37 fc ff ff       	jmp    105b06 <vprintfmt+0x8>
                return;
  105ecf:	90                   	nop
        }
    }
}
  105ed0:	83 c4 40             	add    $0x40,%esp
  105ed3:	5b                   	pop    %ebx
  105ed4:	5e                   	pop    %esi
  105ed5:	5d                   	pop    %ebp
  105ed6:	c3                   	ret    

00105ed7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105ed7:	55                   	push   %ebp
  105ed8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  105edd:	8b 40 08             	mov    0x8(%eax),%eax
  105ee0:	8d 50 01             	lea    0x1(%eax),%edx
  105ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ee6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eec:	8b 10                	mov    (%eax),%edx
  105eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ef1:	8b 40 04             	mov    0x4(%eax),%eax
  105ef4:	39 c2                	cmp    %eax,%edx
  105ef6:	73 12                	jae    105f0a <sprintputch+0x33>
        *b->buf ++ = ch;
  105ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105efb:	8b 00                	mov    (%eax),%eax
  105efd:	8d 48 01             	lea    0x1(%eax),%ecx
  105f00:	8b 55 0c             	mov    0xc(%ebp),%edx
  105f03:	89 0a                	mov    %ecx,(%edx)
  105f05:	8b 55 08             	mov    0x8(%ebp),%edx
  105f08:	88 10                	mov    %dl,(%eax)
    }
}
  105f0a:	90                   	nop
  105f0b:	5d                   	pop    %ebp
  105f0c:	c3                   	ret    

00105f0d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105f0d:	55                   	push   %ebp
  105f0e:	89 e5                	mov    %esp,%ebp
  105f10:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105f13:	8d 45 14             	lea    0x14(%ebp),%eax
  105f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f20:	8b 45 10             	mov    0x10(%ebp),%eax
  105f23:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  105f31:	89 04 24             	mov    %eax,(%esp)
  105f34:	e8 08 00 00 00       	call   105f41 <vsnprintf>
  105f39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105f3f:	c9                   	leave  
  105f40:	c3                   	ret    

00105f41 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105f41:	55                   	push   %ebp
  105f42:	89 e5                	mov    %esp,%ebp
  105f44:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105f47:	8b 45 08             	mov    0x8(%ebp),%eax
  105f4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f50:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f53:	8b 45 08             	mov    0x8(%ebp),%eax
  105f56:	01 d0                	add    %edx,%eax
  105f58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105f62:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105f66:	74 0a                	je     105f72 <vsnprintf+0x31>
  105f68:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f6e:	39 c2                	cmp    %eax,%edx
  105f70:	76 07                	jbe    105f79 <vsnprintf+0x38>
        return -E_INVAL;
  105f72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105f77:	eb 2a                	jmp    105fa3 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105f79:	8b 45 14             	mov    0x14(%ebp),%eax
  105f7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f80:	8b 45 10             	mov    0x10(%ebp),%eax
  105f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f87:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f8e:	c7 04 24 d7 5e 10 00 	movl   $0x105ed7,(%esp)
  105f95:	e8 64 fb ff ff       	call   105afe <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105f9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f9d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105fa3:	c9                   	leave  
  105fa4:	c3                   	ret    
