
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 90 11 40       	mov    $0x40119000,%eax
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
  100020:	a3 00 90 11 00       	mov    %eax,0x119000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 80 11 00       	mov    $0x118000,%esp
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
  10003c:	ba 28 bf 11 00       	mov    $0x11bf28,%edx
  100041:	b8 36 8a 11 00       	mov    $0x118a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 8a 11 00 	movl   $0x118a36,(%esp)
  10005d:	e8 a5 57 00 00       	call   105807 <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 20 60 10 00 	movl   $0x106020,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 3c 60 10 00 	movl   $0x10603c,(%esp)
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
  100155:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10015a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100162:	c7 04 24 41 60 10 00 	movl   $0x106041,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 b0 11 00       	mov    0x11b000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 4f 60 10 00 	movl   $0x10604f,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 b0 11 00       	mov    0x11b000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 5d 60 10 00 	movl   $0x10605d,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 6b 60 10 00 	movl   $0x10606b,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 79 60 10 00 	movl   $0x106079,(%esp)
  1001e5:	e8 a8 00 00 00       	call   100292 <cprintf>
    round ++;
  1001ea:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001ef:	40                   	inc    %eax
  1001f0:	a3 00 b0 11 00       	mov    %eax,0x11b000
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
  10020f:	c7 04 24 88 60 10 00 	movl   $0x106088,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 a8 60 10 00 	movl   $0x1060a8,(%esp)
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
  100288:	e8 cd 58 00 00       	call   105b5a <vprintfmt>
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
  100347:	c7 04 24 c7 60 10 00 	movl   $0x1060c7,(%esp)
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
  100395:	88 90 20 b0 11 00    	mov    %dl,0x11b020(%eax)
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
  1003d3:	05 20 b0 11 00       	add    $0x11b020,%eax
  1003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003db:	b8 20 b0 11 00       	mov    $0x11b020,%eax
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
  1003ef:	a1 20 b4 11 00       	mov    0x11b420,%eax
  1003f4:	85 c0                	test   %eax,%eax
  1003f6:	75 5b                	jne    100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003f8:	c7 05 20 b4 11 00 01 	movl   $0x1,0x11b420
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
  100416:	c7 04 24 ca 60 10 00 	movl   $0x1060ca,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 e6 60 10 00 	movl   $0x1060e6,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 e8 60 10 00 	movl   $0x1060e8,(%esp)
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
  100481:	c7 04 24 fa 60 10 00 	movl   $0x1060fa,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 e6 60 10 00 	movl   $0x1060e6,(%esp)
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
  1004b1:	a1 20 b4 11 00       	mov    0x11b420,%eax
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
  10060f:	c7 00 18 61 10 00    	movl   $0x106118,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 18 61 10 00 	movl   $0x106118,0x8(%eax)
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
  100646:	c7 45 f4 70 73 10 00 	movl   $0x107370,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 a8 25 11 00 	movl   $0x1125a8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec a9 25 11 00 	movl   $0x1125a9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 b7 50 11 00 	movl   $0x1150b7,-0x18(%ebp)

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
  1007b6:	e8 c8 4e 00 00       	call   105683 <strfind>
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
  10093e:	c7 04 24 22 61 10 00 	movl   $0x106122,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 3b 61 10 00 	movl   $0x10613b,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 01 60 10 	movl   $0x106001,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 53 61 10 00 	movl   $0x106153,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 8a 11 	movl   $0x118a36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 6b 61 10 00 	movl   $0x10616b,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 28 bf 11 	movl   $0x11bf28,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 83 61 10 00 	movl   $0x106183,(%esp)
  100995:	e8 f8 f8 ff ff       	call   100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10099a:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
  10099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009a5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009aa:	29 c2                	sub    %eax,%edx
  1009ac:	89 d0                	mov    %edx,%eax
  1009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b4:	85 c0                	test   %eax,%eax
  1009b6:	0f 48 c2             	cmovs  %edx,%eax
  1009b9:	c1 f8 0a             	sar    $0xa,%eax
  1009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c0:	c7 04 24 9c 61 10 00 	movl   $0x10619c,(%esp)
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
  1009f5:	c7 04 24 c6 61 10 00 	movl   $0x1061c6,(%esp)
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
  100a63:	c7 04 24 e2 61 10 00 	movl   $0x1061e2,(%esp)
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
  100ab6:	c7 04 24 f4 61 10 00 	movl   $0x1061f4,(%esp)
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
  100ae9:	c7 04 24 10 62 10 00 	movl   $0x106210,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
          for(uint32_t j = 0; j < 4; j++)
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	76 d6                	jbe    100ad4 <print_stackframe+0x51>
        cprintf("\n");
  100afe:	c7 04 24 18 62 10 00 	movl   $0x106218,(%esp)
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
  100b71:	c7 04 24 9c 62 10 00 	movl   $0x10629c,(%esp)
  100b78:	e8 d4 4a 00 00       	call   105651 <strchr>
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
  100b99:	c7 04 24 a1 62 10 00 	movl   $0x1062a1,(%esp)
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
  100bdb:	c7 04 24 9c 62 10 00 	movl   $0x10629c,(%esp)
  100be2:	e8 6a 4a 00 00       	call   105651 <strchr>
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
  100c3a:	05 00 80 11 00       	add    $0x118000,%eax
  100c3f:	8b 00                	mov    (%eax),%eax
  100c41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c45:	89 04 24             	mov    %eax,(%esp)
  100c48:	e8 67 49 00 00       	call   1055b4 <strcmp>
  100c4d:	85 c0                	test   %eax,%eax
  100c4f:	75 31                	jne    100c82 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c54:	89 d0                	mov    %edx,%eax
  100c56:	01 c0                	add    %eax,%eax
  100c58:	01 d0                	add    %edx,%eax
  100c5a:	c1 e0 02             	shl    $0x2,%eax
  100c5d:	05 08 80 11 00       	add    $0x118008,%eax
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
  100c94:	c7 04 24 bf 62 10 00 	movl   $0x1062bf,(%esp)
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
  100cb1:	c7 04 24 d8 62 10 00 	movl   $0x1062d8,(%esp)
  100cb8:	e8 d5 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbd:	c7 04 24 00 63 10 00 	movl   $0x106300,(%esp)
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
  100cda:	c7 04 24 25 63 10 00 	movl   $0x106325,(%esp)
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
  100d26:	05 04 80 11 00       	add    $0x118004,%eax
  100d2b:	8b 08                	mov    (%eax),%ecx
  100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d30:	89 d0                	mov    %edx,%eax
  100d32:	01 c0                	add    %eax,%eax
  100d34:	01 d0                	add    %edx,%eax
  100d36:	c1 e0 02             	shl    $0x2,%eax
  100d39:	05 00 80 11 00       	add    $0x118000,%eax
  100d3e:	8b 00                	mov    (%eax),%eax
  100d40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d48:	c7 04 24 29 63 10 00 	movl   $0x106329,(%esp)
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
  100dc9:	c7 05 0c bf 11 00 00 	movl   $0x0,0x11bf0c
  100dd0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd3:	c7 04 24 32 63 10 00 	movl   $0x106332,(%esp)
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
  100eab:	66 c7 05 46 b4 11 00 	movw   $0x3b4,0x11b446
  100eb2:	b4 03 
  100eb4:	eb 13                	jmp    100ec9 <cga_init+0x54>
    } else {
        *cp = was;
  100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ebd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ec0:	66 c7 05 46 b4 11 00 	movw   $0x3d4,0x11b446
  100ec7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ec9:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100ed0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ed4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ed8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100edc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee1:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
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
  100f07:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f12:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f1f:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
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
  100f45:	a3 40 b4 11 00       	mov    %eax,0x11b440
    crt_pos = pos;
  100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f4d:	0f b7 c0             	movzwl %ax,%eax
  100f50:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
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
  101000:	a3 48 b4 11 00       	mov    %eax,0x11b448
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
  101025:	a1 48 b4 11 00       	mov    0x11b448,%eax
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
  101129:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101130:	85 c0                	test   %eax,%eax
  101132:	0f 84 af 00 00 00    	je     1011e7 <cga_putc+0xf1>
            crt_pos --;
  101138:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10113f:	48                   	dec    %eax
  101140:	0f b7 c0             	movzwl %ax,%eax
  101143:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101149:	8b 45 08             	mov    0x8(%ebp),%eax
  10114c:	98                   	cwtl   
  10114d:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101152:	98                   	cwtl   
  101153:	83 c8 20             	or     $0x20,%eax
  101156:	98                   	cwtl   
  101157:	8b 15 40 b4 11 00    	mov    0x11b440,%edx
  10115d:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
  101164:	01 c9                	add    %ecx,%ecx
  101166:	01 ca                	add    %ecx,%edx
  101168:	0f b7 c0             	movzwl %ax,%eax
  10116b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10116e:	eb 77                	jmp    1011e7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  101170:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101177:	83 c0 50             	add    $0x50,%eax
  10117a:	0f b7 c0             	movzwl %ax,%eax
  10117d:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101183:	0f b7 1d 44 b4 11 00 	movzwl 0x11b444,%ebx
  10118a:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
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
  1011b5:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
        break;
  1011bb:	eb 2b                	jmp    1011e8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011bd:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  1011c3:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1011ca:	8d 50 01             	lea    0x1(%eax),%edx
  1011cd:	0f b7 d2             	movzwl %dx,%edx
  1011d0:	66 89 15 44 b4 11 00 	mov    %dx,0x11b444
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
  1011e8:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1011ef:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011f4:	76 5d                	jbe    101253 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f6:	a1 40 b4 11 00       	mov    0x11b440,%eax
  1011fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101201:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101206:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120d:	00 
  10120e:	89 54 24 04          	mov    %edx,0x4(%esp)
  101212:	89 04 24             	mov    %eax,(%esp)
  101215:	e8 2d 46 00 00       	call   105847 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10121a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101221:	eb 14                	jmp    101237 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  101223:	a1 40 b4 11 00       	mov    0x11b440,%eax
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
  101240:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101247:	83 e8 50             	sub    $0x50,%eax
  10124a:	0f b7 c0             	movzwl %ax,%eax
  10124d:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101253:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  10125a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10125e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101262:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101266:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10126a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10126b:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101272:	c1 e8 08             	shr    $0x8,%eax
  101275:	0f b7 c0             	movzwl %ax,%eax
  101278:	0f b6 c0             	movzbl %al,%eax
  10127b:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  101282:	42                   	inc    %edx
  101283:	0f b7 d2             	movzwl %dx,%edx
  101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  10128a:	88 45 e9             	mov    %al,-0x17(%ebp)
  10128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101295:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101296:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  10129d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012a1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  1012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012ae:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1012b5:	0f b6 c0             	movzbl %al,%eax
  1012b8:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
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
  101381:	a1 64 b6 11 00       	mov    0x11b664,%eax
  101386:	8d 50 01             	lea    0x1(%eax),%edx
  101389:	89 15 64 b6 11 00    	mov    %edx,0x11b664
  10138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101392:	88 90 60 b4 11 00    	mov    %dl,0x11b460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101398:	a1 64 b6 11 00       	mov    0x11b664,%eax
  10139d:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a2:	75 0a                	jne    1013ae <cons_intr+0x3b>
                cons.wpos = 0;
  1013a4:	c7 05 64 b6 11 00 00 	movl   $0x0,0x11b664
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
  10141c:	a1 48 b4 11 00       	mov    0x11b448,%eax
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
  10147d:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101482:	83 c8 40             	or     $0x40,%eax
  101485:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  10148a:	b8 00 00 00 00       	mov    $0x0,%eax
  10148f:	e9 22 01 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  101494:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101498:	84 c0                	test   %al,%al
  10149a:	79 45                	jns    1014e1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149c:	a1 68 b6 11 00       	mov    0x11b668,%eax
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
  1014bb:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  1014c2:	0c 40                	or     $0x40,%al
  1014c4:	0f b6 c0             	movzbl %al,%eax
  1014c7:	f7 d0                	not    %eax
  1014c9:	89 c2                	mov    %eax,%edx
  1014cb:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014d0:	21 d0                	and    %edx,%eax
  1014d2:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  1014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  1014dc:	e9 d5 00 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  1014e1:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014e6:	83 e0 40             	and    $0x40,%eax
  1014e9:	85 c0                	test   %eax,%eax
  1014eb:	74 11                	je     1014fe <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014ed:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f1:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014f6:	83 e0 bf             	and    $0xffffffbf,%eax
  1014f9:	a3 68 b6 11 00       	mov    %eax,0x11b668
    }

    shift |= shiftcode[data];
  1014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101502:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  101509:	0f b6 d0             	movzbl %al,%edx
  10150c:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101511:	09 d0                	or     %edx,%eax
  101513:	a3 68 b6 11 00       	mov    %eax,0x11b668
    shift ^= togglecode[data];
  101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151c:	0f b6 80 40 81 11 00 	movzbl 0x118140(%eax),%eax
  101523:	0f b6 d0             	movzbl %al,%edx
  101526:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10152b:	31 d0                	xor    %edx,%eax
  10152d:	a3 68 b6 11 00       	mov    %eax,0x11b668

    c = charcode[shift & (CTL | SHIFT)][data];
  101532:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101537:	83 e0 03             	and    $0x3,%eax
  10153a:	8b 14 85 40 85 11 00 	mov    0x118540(,%eax,4),%edx
  101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101545:	01 d0                	add    %edx,%eax
  101547:	0f b6 00             	movzbl (%eax),%eax
  10154a:	0f b6 c0             	movzbl %al,%eax
  10154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101550:	a1 68 b6 11 00       	mov    0x11b668,%eax
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
  10157e:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101583:	f7 d0                	not    %eax
  101585:	83 e0 06             	and    $0x6,%eax
  101588:	85 c0                	test   %eax,%eax
  10158a:	75 27                	jne    1015b3 <kbd_proc_data+0x17f>
  10158c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101593:	75 1e                	jne    1015b3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  101595:	c7 04 24 4d 63 10 00 	movl   $0x10634d,(%esp)
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
  1015fc:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101601:	85 c0                	test   %eax,%eax
  101603:	75 0c                	jne    101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101605:	c7 04 24 59 63 10 00 	movl   $0x106359,(%esp)
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
  101670:	8b 15 60 b6 11 00    	mov    0x11b660,%edx
  101676:	a1 64 b6 11 00       	mov    0x11b664,%eax
  10167b:	39 c2                	cmp    %eax,%edx
  10167d:	74 31                	je     1016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167f:	a1 60 b6 11 00       	mov    0x11b660,%eax
  101684:	8d 50 01             	lea    0x1(%eax),%edx
  101687:	89 15 60 b6 11 00    	mov    %edx,0x11b660
  10168d:	0f b6 80 60 b4 11 00 	movzbl 0x11b460(%eax),%eax
  101694:	0f b6 c0             	movzbl %al,%eax
  101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10169a:	a1 60 b6 11 00       	mov    0x11b660,%eax
  10169f:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a4:	75 0a                	jne    1016b0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016a6:	c7 05 60 b6 11 00 00 	movl   $0x0,0x11b660
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
  1016d0:	66 a3 50 85 11 00    	mov    %ax,0x118550
    if (did_init) {
  1016d6:	a1 6c b6 11 00       	mov    0x11b66c,%eax
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
  101733:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
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
  101752:	c7 05 6c b6 11 00 01 	movl   $0x1,0x11b66c
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
  101866:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10186d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101872:	74 0f                	je     101883 <pic_init+0x137>
        pic_setmask(irq_mask);
  101874:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
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
  1018a2:	c7 04 24 80 63 10 00 	movl   $0x106380,(%esp)
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
  1018c6:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  1018cd:	0f b7 d0             	movzwl %ax,%edx
  1018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d3:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  1018da:	00 
  1018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018de:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  1018e5:	00 08 00 
  1018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018eb:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  1018f2:	00 
  1018f3:	80 e2 e0             	and    $0xe0,%dl
  1018f6:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101900:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  101907:	00 
  101908:	80 e2 1f             	and    $0x1f,%dl
  10190b:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101915:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  10191c:	00 
  10191d:	80 e2 f0             	and    $0xf0,%dl
  101920:	80 ca 0e             	or     $0xe,%dl
  101923:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192d:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101934:	00 
  101935:	80 e2 ef             	and    $0xef,%dl
  101938:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10193f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101942:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101949:	00 
  10194a:	80 e2 9f             	and    $0x9f,%dl
  10194d:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101954:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101957:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  10195e:	00 
  10195f:	80 ca 80             	or     $0x80,%dl
  101962:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101969:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196c:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101973:	c1 e8 10             	shr    $0x10,%eax
  101976:	0f b7 d0             	movzwl %ax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  101983:	00 
        SETGATE(idt[T_SYSCALL], 0, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
  101984:	a1 e0 87 11 00       	mov    0x1187e0,%eax
  101989:	0f b7 c0             	movzwl %ax,%eax
  10198c:	66 a3 80 ba 11 00    	mov    %ax,0x11ba80
  101992:	66 c7 05 82 ba 11 00 	movw   $0x8,0x11ba82
  101999:	08 00 
  10199b:	0f b6 05 84 ba 11 00 	movzbl 0x11ba84,%eax
  1019a2:	24 e0                	and    $0xe0,%al
  1019a4:	a2 84 ba 11 00       	mov    %al,0x11ba84
  1019a9:	0f b6 05 84 ba 11 00 	movzbl 0x11ba84,%eax
  1019b0:	24 1f                	and    $0x1f,%al
  1019b2:	a2 84 ba 11 00       	mov    %al,0x11ba84
  1019b7:	0f b6 05 85 ba 11 00 	movzbl 0x11ba85,%eax
  1019be:	24 f0                	and    $0xf0,%al
  1019c0:	0c 0e                	or     $0xe,%al
  1019c2:	a2 85 ba 11 00       	mov    %al,0x11ba85
  1019c7:	0f b6 05 85 ba 11 00 	movzbl 0x11ba85,%eax
  1019ce:	24 ef                	and    $0xef,%al
  1019d0:	a2 85 ba 11 00       	mov    %al,0x11ba85
  1019d5:	0f b6 05 85 ba 11 00 	movzbl 0x11ba85,%eax
  1019dc:	0c 60                	or     $0x60,%al
  1019de:	a2 85 ba 11 00       	mov    %al,0x11ba85
  1019e3:	0f b6 05 85 ba 11 00 	movzbl 0x11ba85,%eax
  1019ea:	0c 80                	or     $0x80,%al
  1019ec:	a2 85 ba 11 00       	mov    %al,0x11ba85
  1019f1:	a1 e0 87 11 00       	mov    0x1187e0,%eax
  1019f6:	c1 e8 10             	shr    $0x10,%eax
  1019f9:	0f b7 c0             	movzwl %ax,%eax
  1019fc:	66 a3 86 ba 11 00    	mov    %ax,0x11ba86
  101a02:	c7 45 f8 60 85 11 00 	movl   $0x118560,-0x8(%ebp)
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
  101a31:	8b 04 85 e0 66 10 00 	mov    0x1066e0(,%eax,4),%eax
  101a38:	eb 18                	jmp    101a52 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a3a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a3e:	7e 0d                	jle    101a4d <trapname+0x2a>
  101a40:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a44:	7f 07                	jg     101a4d <trapname+0x2a>
        return "Hardware Interrupt";
  101a46:	b8 8a 63 10 00       	mov    $0x10638a,%eax
  101a4b:	eb 05                	jmp    101a52 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a4d:	b8 9d 63 10 00       	mov    $0x10639d,%eax
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
  101a76:	c7 04 24 de 63 10 00 	movl   $0x1063de,(%esp)
  101a7d:	e8 10 e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a82:	8b 45 08             	mov    0x8(%ebp),%eax
  101a85:	89 04 24             	mov    %eax,(%esp)
  101a88:	e8 8f 01 00 00       	call   101c1c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a90:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a98:	c7 04 24 ef 63 10 00 	movl   $0x1063ef,(%esp)
  101a9f:	e8 ee e7 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa7:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aaf:	c7 04 24 02 64 10 00 	movl   $0x106402,(%esp)
  101ab6:	e8 d7 e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101abb:	8b 45 08             	mov    0x8(%ebp),%eax
  101abe:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac6:	c7 04 24 15 64 10 00 	movl   $0x106415,(%esp)
  101acd:	e8 c0 e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101add:	c7 04 24 28 64 10 00 	movl   $0x106428,(%esp)
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
  101b07:	c7 04 24 3b 64 10 00 	movl   $0x10643b,(%esp)
  101b0e:	e8 7f e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b13:	8b 45 08             	mov    0x8(%ebp),%eax
  101b16:	8b 40 34             	mov    0x34(%eax),%eax
  101b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1d:	c7 04 24 4d 64 10 00 	movl   $0x10644d,(%esp)
  101b24:	e8 69 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b29:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2c:	8b 40 38             	mov    0x38(%eax),%eax
  101b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b33:	c7 04 24 5c 64 10 00 	movl   $0x10645c,(%esp)
  101b3a:	e8 53 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4a:	c7 04 24 6b 64 10 00 	movl   $0x10646b,(%esp)
  101b51:	e8 3c e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b56:	8b 45 08             	mov    0x8(%ebp),%eax
  101b59:	8b 40 40             	mov    0x40(%eax),%eax
  101b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b60:	c7 04 24 7e 64 10 00 	movl   $0x10647e,(%esp)
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
  101b8e:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101b95:	85 c0                	test   %eax,%eax
  101b97:	74 1a                	je     101bb3 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b9c:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba7:	c7 04 24 8d 64 10 00 	movl   $0x10648d,(%esp)
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
  101bd1:	c7 04 24 91 64 10 00 	movl   $0x106491,(%esp)
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
  101bf6:	c7 04 24 9a 64 10 00 	movl   $0x10649a,(%esp)
  101bfd:	e8 90 e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c02:	8b 45 08             	mov    0x8(%ebp),%eax
  101c05:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0d:	c7 04 24 a9 64 10 00 	movl   $0x1064a9,(%esp)
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
  101c2b:	c7 04 24 bc 64 10 00 	movl   $0x1064bc,(%esp)
  101c32:	e8 5b e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c37:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3a:	8b 40 04             	mov    0x4(%eax),%eax
  101c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c41:	c7 04 24 cb 64 10 00 	movl   $0x1064cb,(%esp)
  101c48:	e8 45 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c50:	8b 40 08             	mov    0x8(%eax),%eax
  101c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c57:	c7 04 24 da 64 10 00 	movl   $0x1064da,(%esp)
  101c5e:	e8 2f e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c63:	8b 45 08             	mov    0x8(%ebp),%eax
  101c66:	8b 40 0c             	mov    0xc(%eax),%eax
  101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6d:	c7 04 24 e9 64 10 00 	movl   $0x1064e9,(%esp)
  101c74:	e8 19 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c79:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7c:	8b 40 10             	mov    0x10(%eax),%eax
  101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c83:	c7 04 24 f8 64 10 00 	movl   $0x1064f8,(%esp)
  101c8a:	e8 03 e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c92:	8b 40 14             	mov    0x14(%eax),%eax
  101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c99:	c7 04 24 07 65 10 00 	movl   $0x106507,(%esp)
  101ca0:	e8 ed e5 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca8:	8b 40 18             	mov    0x18(%eax),%eax
  101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101caf:	c7 04 24 16 65 10 00 	movl   $0x106516,(%esp)
  101cb6:	e8 d7 e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbe:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc5:	c7 04 24 25 65 10 00 	movl   $0x106525,(%esp)
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
  101d17:	a1 0c bf 11 00       	mov    0x11bf0c,%eax
  101d1c:	40                   	inc    %eax
  101d1d:	a3 0c bf 11 00       	mov    %eax,0x11bf0c
         if(ticks % TICK_NUM == 0) {
  101d22:	8b 0d 0c bf 11 00    	mov    0x11bf0c,%ecx
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
  101d58:	c7 05 0c bf 11 00 00 	movl   $0x0,0x11bf0c
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
  101d7f:	c7 04 24 34 65 10 00 	movl   $0x106534,(%esp)
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
  101da5:	c7 04 24 46 65 10 00 	movl   $0x106546,(%esp)
  101dac:	e8 e1 e4 ff ff       	call   100292 <cprintf>
        break;
  101db1:	eb 55                	jmp    101e08 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101db3:	c7 44 24 08 55 65 10 	movl   $0x106555,0x8(%esp)
  101dba:	00 
  101dbb:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  101dc2:	00 
  101dc3:	c7 04 24 65 65 10 00 	movl   $0x106565,(%esp)
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
  101de8:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  101def:	00 
  101df0:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101df7:	00 
  101df8:	c7 04 24 65 65 10 00 	movl   $0x106565,(%esp)
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
  1028b9:	8b 15 18 bf 11 00    	mov    0x11bf18,%edx
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
  1028f0:	a1 80 be 11 00       	mov    0x11be80,%eax
  1028f5:	39 c2                	cmp    %eax,%edx
  1028f7:	72 1c                	jb     102915 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  1028f9:	c7 44 24 08 30 67 10 	movl   $0x106730,0x8(%esp)
  102900:	00 
  102901:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102908:	00 
  102909:	c7 04 24 4f 67 10 00 	movl   $0x10674f,(%esp)
  102910:	e8 d4 da ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  102915:	8b 0d 18 bf 11 00    	mov    0x11bf18,%ecx
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
  10294e:	a1 80 be 11 00       	mov    0x11be80,%eax
  102953:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102956:	72 23                	jb     10297b <page2kva+0x4a>
  102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10295b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10295f:	c7 44 24 08 60 67 10 	movl   $0x106760,0x8(%esp)
  102966:	00 
  102967:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  10296e:	00 
  10296f:	c7 04 24 4f 67 10 00 	movl   $0x10674f,(%esp)
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
  102995:	c7 44 24 08 84 67 10 	movl   $0x106784,0x8(%esp)
  10299c:	00 
  10299d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1029a4:	00 
  1029a5:	c7 04 24 4f 67 10 00 	movl   $0x10674f,(%esp)
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
  102a9b:	a3 a4 be 11 00       	mov    %eax,0x11bea4
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
  102aa9:	b8 00 80 11 00       	mov    $0x118000,%eax
  102aae:	89 04 24             	mov    %eax,(%esp)
  102ab1:	e8 df ff ff ff       	call   102a95 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102ab6:	66 c7 05 a8 be 11 00 	movw   $0x10,0x11bea8
  102abd:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102abf:	66 c7 05 28 8a 11 00 	movw   $0x68,0x118a28
  102ac6:	68 00 
  102ac8:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102acd:	0f b7 c0             	movzwl %ax,%eax
  102ad0:	66 a3 2a 8a 11 00    	mov    %ax,0x118a2a
  102ad6:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102adb:	c1 e8 10             	shr    $0x10,%eax
  102ade:	a2 2c 8a 11 00       	mov    %al,0x118a2c
  102ae3:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102aea:	24 f0                	and    $0xf0,%al
  102aec:	0c 09                	or     $0x9,%al
  102aee:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102af3:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102afa:	24 ef                	and    $0xef,%al
  102afc:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102b01:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102b08:	24 9f                	and    $0x9f,%al
  102b0a:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102b0f:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102b16:	0c 80                	or     $0x80,%al
  102b18:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102b1d:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102b24:	24 f0                	and    $0xf0,%al
  102b26:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102b2b:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102b32:	24 ef                	and    $0xef,%al
  102b34:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102b39:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102b40:	24 df                	and    $0xdf,%al
  102b42:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102b47:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102b4e:	0c 40                	or     $0x40,%al
  102b50:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102b55:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102b5c:	24 7f                	and    $0x7f,%al
  102b5e:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102b63:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102b68:	c1 e8 18             	shr    $0x18,%eax
  102b6b:	a2 2f 8a 11 00       	mov    %al,0x118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b70:	c7 04 24 30 8a 11 00 	movl   $0x118a30,(%esp)
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
  102b92:	c7 05 10 bf 11 00 58 	movl   $0x107158,0x11bf10
  102b99:	71 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b9c:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102ba1:	8b 00                	mov    (%eax),%eax
  102ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ba7:	c7 04 24 b0 67 10 00 	movl   $0x1067b0,(%esp)
  102bae:	e8 df d6 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102bb3:	a1 10 bf 11 00       	mov    0x11bf10,%eax
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
  102bc6:	a1 10 bf 11 00       	mov    0x11bf10,%eax
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
  102bf5:	a1 10 bf 11 00       	mov    0x11bf10,%eax
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
  102c26:	a1 10 bf 11 00       	mov    0x11bf10,%eax
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
  102c59:	a1 10 bf 11 00       	mov    0x11bf10,%eax
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
  102c97:	c7 04 24 c7 67 10 00 	movl   $0x1067c7,(%esp)
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
  102d70:	c7 04 24 d4 67 10 00 	movl   $0x1067d4,(%esp)
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
  102e15:	a3 80 be 11 00       	mov    %eax,0x11be80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102e1a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102e21:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
  102e26:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e29:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e2c:	01 d0                	add    %edx,%eax
  102e2e:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102e31:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e34:	ba 00 00 00 00       	mov    $0x0,%edx
  102e39:	f7 75 c0             	divl   -0x40(%ebp)
  102e3c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e3f:	29 d0                	sub    %edx,%eax
  102e41:	a3 18 bf 11 00       	mov    %eax,0x11bf18

    for (i = 0; i < npage; i ++) {
  102e46:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e4d:	eb 2e                	jmp    102e7d <page_init+0x207>
        SetPageReserved(pages + i);
  102e4f:	8b 0d 18 bf 11 00    	mov    0x11bf18,%ecx
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
  102e80:	a1 80 be 11 00       	mov    0x11be80,%eax
  102e85:	39 c2                	cmp    %eax,%edx
  102e87:	72 c6                	jb     102e4f <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e89:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  102e8f:	89 d0                	mov    %edx,%eax
  102e91:	c1 e0 02             	shl    $0x2,%eax
  102e94:	01 d0                	add    %edx,%eax
  102e96:	c1 e0 02             	shl    $0x2,%eax
  102e99:	89 c2                	mov    %eax,%edx
  102e9b:	a1 18 bf 11 00       	mov    0x11bf18,%eax
  102ea0:	01 d0                	add    %edx,%eax
  102ea2:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102ea5:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102eac:	77 23                	ja     102ed1 <page_init+0x25b>
  102eae:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102eb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102eb5:	c7 44 24 08 04 68 10 	movl   $0x106804,0x8(%esp)
  102ebc:	00 
  102ebd:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  102ec4:	00 
  102ec5:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
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
  103080:	c7 44 24 0c 36 68 10 	movl   $0x106836,0xc(%esp)
  103087:	00 
  103088:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  10308f:	00 
  103090:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  103097:	00 
  103098:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
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
  103120:	c7 44 24 0c 62 68 10 	movl   $0x106862,0xc(%esp)
  103127:	00 
  103128:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  10312f:	00 
  103130:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103137:	00 
  103138:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
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
  103189:	c7 44 24 08 6f 68 10 	movl   $0x10686f,0x8(%esp)
  103190:	00 
  103191:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  103198:	00 
  103199:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
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
  1031b8:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1031bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031c0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1031c7:	77 23                	ja     1031ec <pmm_init+0x3a>
  1031c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031d0:	c7 44 24 08 04 68 10 	movl   $0x106804,0x8(%esp)
  1031d7:	00 
  1031d8:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1031df:	00 
  1031e0:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1031e7:	e8 fd d1 ff ff       	call   1003e9 <__panic>
  1031ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031ef:	05 00 00 00 40       	add    $0x40000000,%eax
  1031f4:	a3 14 bf 11 00       	mov    %eax,0x11bf14
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
  103203:	e8 de 03 00 00       	call   1035e6 <check_alloc_page>

    check_pgdir();
  103208:	e8 f8 03 00 00       	call   103605 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10320d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103212:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103215:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10321c:	77 23                	ja     103241 <pmm_init+0x8f>
  10321e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103225:	c7 44 24 08 04 68 10 	movl   $0x106804,0x8(%esp)
  10322c:	00 
  10322d:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  103234:	00 
  103235:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  10323c:	e8 a8 d1 ff ff       	call   1003e9 <__panic>
  103241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103244:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10324a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10324f:	05 ac 0f 00 00       	add    $0xfac,%eax
  103254:	83 ca 03             	or     $0x3,%edx
  103257:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103259:	a1 e0 89 11 00       	mov    0x1189e0,%eax
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
  10328b:	e8 11 0a 00 00       	call   103ca1 <check_boot_pgdir>

    print_pgdir();
  103290:	e8 8a 0e 00 00       	call   10411f <print_pgdir>

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
  103318:	a1 80 be 11 00       	mov    0x11be80,%eax
  10331d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103320:	72 23                	jb     103345 <get_pte+0xad>
  103322:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103329:	c7 44 24 08 60 67 10 	movl   $0x106760,0x8(%esp)
  103330:	00 
  103331:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
  103338:	00 
  103339:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103340:	e8 a4 d0 ff ff       	call   1003e9 <__panic>
  103345:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103348:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10334d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103354:	00 
  103355:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10335c:	00 
  10335d:	89 04 24             	mov    %eax,(%esp)
  103360:	e8 a2 24 00 00       	call   105807 <memset>
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
  103388:	a1 80 be 11 00       	mov    0x11be80,%eax
  10338d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103390:	72 23                	jb     1033b5 <get_pte+0x11d>
  103392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103399:	c7 44 24 08 60 67 10 	movl   $0x106760,0x8(%esp)
  1033a0:	00 
  1033a1:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
  1033a8:	00 
  1033a9:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
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
  10342d:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    if (*ptep & PTE_P) {                      //(1) check if this page table entry is present
  103430:	8b 45 10             	mov    0x10(%ebp),%eax
  103433:	8b 00                	mov    (%eax),%eax
  103435:	83 e0 01             	and    $0x1,%eax
  103438:	85 c0                	test   %eax,%eax
  10343a:	74 4d                	je     103489 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //(2) find corresponding page to pte
  10343c:	8b 45 10             	mov    0x10(%ebp),%eax
  10343f:	8b 00                	mov    (%eax),%eax
  103441:	89 04 24             	mov    %eax,(%esp)
  103444:	e8 3c f5 ff ff       	call   102985 <pte2page>
  103449:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0)  //(3) decrease page reference
  10344c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10344f:	89 04 24             	mov    %eax,(%esp)
  103452:	e8 b3 f5 ff ff       	call   102a0a <page_ref_dec>
  103457:	85 c0                	test   %eax,%eax
  103459:	75 13                	jne    10346e <page_remove_pte+0x44>
            free_page(page);  //(4) and free this page when page reference reachs 0
  10345b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103462:	00 
  103463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103466:	89 04 24             	mov    %eax,(%esp)
  103469:	e8 aa f7 ff ff       	call   102c18 <free_pages>
        *ptep = 0;  //(5) clear second page table entry
  10346e:	8b 45 10             	mov    0x10(%ebp),%eax
  103471:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);  //(6) flush tlb
  103477:	8b 45 0c             	mov    0xc(%ebp),%eax
  10347a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10347e:	8b 45 08             	mov    0x8(%ebp),%eax
  103481:	89 04 24             	mov    %eax,(%esp)
  103484:	e8 01 01 00 00       	call   10358a <tlb_invalidate>
    }
}
  103489:	90                   	nop
  10348a:	c9                   	leave  
  10348b:	c3                   	ret    

0010348c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10348c:	55                   	push   %ebp
  10348d:	89 e5                	mov    %esp,%ebp
  10348f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103492:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103499:	00 
  10349a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10349d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1034a4:	89 04 24             	mov    %eax,(%esp)
  1034a7:	e8 ec fd ff ff       	call   103298 <get_pte>
  1034ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1034af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1034b3:	74 19                	je     1034ce <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1034b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1034c6:	89 04 24             	mov    %eax,(%esp)
  1034c9:	e8 5c ff ff ff       	call   10342a <page_remove_pte>
    }
}
  1034ce:	90                   	nop
  1034cf:	c9                   	leave  
  1034d0:	c3                   	ret    

001034d1 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1034d1:	55                   	push   %ebp
  1034d2:	89 e5                	mov    %esp,%ebp
  1034d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1034d7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1034de:	00 
  1034df:	8b 45 10             	mov    0x10(%ebp),%eax
  1034e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1034e9:	89 04 24             	mov    %eax,(%esp)
  1034ec:	e8 a7 fd ff ff       	call   103298 <get_pte>
  1034f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1034f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1034f8:	75 0a                	jne    103504 <page_insert+0x33>
        return -E_NO_MEM;
  1034fa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1034ff:	e9 84 00 00 00       	jmp    103588 <page_insert+0xb7>
    }
    page_ref_inc(page);
  103504:	8b 45 0c             	mov    0xc(%ebp),%eax
  103507:	89 04 24             	mov    %eax,(%esp)
  10350a:	e8 e4 f4 ff ff       	call   1029f3 <page_ref_inc>
    if (*ptep & PTE_P) {
  10350f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103512:	8b 00                	mov    (%eax),%eax
  103514:	83 e0 01             	and    $0x1,%eax
  103517:	85 c0                	test   %eax,%eax
  103519:	74 3e                	je     103559 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10351b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10351e:	8b 00                	mov    (%eax),%eax
  103520:	89 04 24             	mov    %eax,(%esp)
  103523:	e8 5d f4 ff ff       	call   102985 <pte2page>
  103528:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10352b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10352e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103531:	75 0d                	jne    103540 <page_insert+0x6f>
            page_ref_dec(page);
  103533:	8b 45 0c             	mov    0xc(%ebp),%eax
  103536:	89 04 24             	mov    %eax,(%esp)
  103539:	e8 cc f4 ff ff       	call   102a0a <page_ref_dec>
  10353e:	eb 19                	jmp    103559 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103543:	89 44 24 08          	mov    %eax,0x8(%esp)
  103547:	8b 45 10             	mov    0x10(%ebp),%eax
  10354a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10354e:	8b 45 08             	mov    0x8(%ebp),%eax
  103551:	89 04 24             	mov    %eax,(%esp)
  103554:	e8 d1 fe ff ff       	call   10342a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103559:	8b 45 0c             	mov    0xc(%ebp),%eax
  10355c:	89 04 24             	mov    %eax,(%esp)
  10355f:	e8 68 f3 ff ff       	call   1028cc <page2pa>
  103564:	0b 45 14             	or     0x14(%ebp),%eax
  103567:	83 c8 01             	or     $0x1,%eax
  10356a:	89 c2                	mov    %eax,%edx
  10356c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10356f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103571:	8b 45 10             	mov    0x10(%ebp),%eax
  103574:	89 44 24 04          	mov    %eax,0x4(%esp)
  103578:	8b 45 08             	mov    0x8(%ebp),%eax
  10357b:	89 04 24             	mov    %eax,(%esp)
  10357e:	e8 07 00 00 00       	call   10358a <tlb_invalidate>
    return 0;
  103583:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103588:	c9                   	leave  
  103589:	c3                   	ret    

0010358a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10358a:	55                   	push   %ebp
  10358b:	89 e5                	mov    %esp,%ebp
  10358d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103590:	0f 20 d8             	mov    %cr3,%eax
  103593:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  103596:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103599:	8b 45 08             	mov    0x8(%ebp),%eax
  10359c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10359f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1035a6:	77 23                	ja     1035cb <tlb_invalidate+0x41>
  1035a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1035af:	c7 44 24 08 04 68 10 	movl   $0x106804,0x8(%esp)
  1035b6:	00 
  1035b7:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  1035be:	00 
  1035bf:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1035c6:	e8 1e ce ff ff       	call   1003e9 <__panic>
  1035cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035ce:	05 00 00 00 40       	add    $0x40000000,%eax
  1035d3:	39 d0                	cmp    %edx,%eax
  1035d5:	75 0c                	jne    1035e3 <tlb_invalidate+0x59>
        invlpg((void *)la);
  1035d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035da:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1035dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035e0:	0f 01 38             	invlpg (%eax)
    }
}
  1035e3:	90                   	nop
  1035e4:	c9                   	leave  
  1035e5:	c3                   	ret    

001035e6 <check_alloc_page>:

static void
check_alloc_page(void) {
  1035e6:	55                   	push   %ebp
  1035e7:	89 e5                	mov    %esp,%ebp
  1035e9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1035ec:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  1035f1:	8b 40 18             	mov    0x18(%eax),%eax
  1035f4:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1035f6:	c7 04 24 88 68 10 00 	movl   $0x106888,(%esp)
  1035fd:	e8 90 cc ff ff       	call   100292 <cprintf>
}
  103602:	90                   	nop
  103603:	c9                   	leave  
  103604:	c3                   	ret    

00103605 <check_pgdir>:

static void
check_pgdir(void) {
  103605:	55                   	push   %ebp
  103606:	89 e5                	mov    %esp,%ebp
  103608:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10360b:	a1 80 be 11 00       	mov    0x11be80,%eax
  103610:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103615:	76 24                	jbe    10363b <check_pgdir+0x36>
  103617:	c7 44 24 0c a7 68 10 	movl   $0x1068a7,0xc(%esp)
  10361e:	00 
  10361f:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103626:	00 
  103627:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  10362e:	00 
  10362f:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103636:	e8 ae cd ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10363b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103640:	85 c0                	test   %eax,%eax
  103642:	74 0e                	je     103652 <check_pgdir+0x4d>
  103644:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103649:	25 ff 0f 00 00       	and    $0xfff,%eax
  10364e:	85 c0                	test   %eax,%eax
  103650:	74 24                	je     103676 <check_pgdir+0x71>
  103652:	c7 44 24 0c c4 68 10 	movl   $0x1068c4,0xc(%esp)
  103659:	00 
  10365a:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103661:	00 
  103662:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  103669:	00 
  10366a:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103671:	e8 73 cd ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103676:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10367b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103682:	00 
  103683:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10368a:	00 
  10368b:	89 04 24             	mov    %eax,(%esp)
  10368e:	e8 3e fd ff ff       	call   1033d1 <get_page>
  103693:	85 c0                	test   %eax,%eax
  103695:	74 24                	je     1036bb <check_pgdir+0xb6>
  103697:	c7 44 24 0c fc 68 10 	movl   $0x1068fc,0xc(%esp)
  10369e:	00 
  10369f:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  1036a6:	00 
  1036a7:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  1036ae:	00 
  1036af:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1036b6:	e8 2e cd ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1036bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036c2:	e8 19 f5 ff ff       	call   102be0 <alloc_pages>
  1036c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1036ca:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1036cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1036d6:	00 
  1036d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036de:	00 
  1036df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1036e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1036e6:	89 04 24             	mov    %eax,(%esp)
  1036e9:	e8 e3 fd ff ff       	call   1034d1 <page_insert>
  1036ee:	85 c0                	test   %eax,%eax
  1036f0:	74 24                	je     103716 <check_pgdir+0x111>
  1036f2:	c7 44 24 0c 24 69 10 	movl   $0x106924,0xc(%esp)
  1036f9:	00 
  1036fa:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103701:	00 
  103702:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  103709:	00 
  10370a:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103711:	e8 d3 cc ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103716:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10371b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103722:	00 
  103723:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10372a:	00 
  10372b:	89 04 24             	mov    %eax,(%esp)
  10372e:	e8 65 fb ff ff       	call   103298 <get_pte>
  103733:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103736:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10373a:	75 24                	jne    103760 <check_pgdir+0x15b>
  10373c:	c7 44 24 0c 50 69 10 	movl   $0x106950,0xc(%esp)
  103743:	00 
  103744:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  10374b:	00 
  10374c:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  103753:	00 
  103754:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  10375b:	e8 89 cc ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103760:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103763:	8b 00                	mov    (%eax),%eax
  103765:	89 04 24             	mov    %eax,(%esp)
  103768:	e8 18 f2 ff ff       	call   102985 <pte2page>
  10376d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103770:	74 24                	je     103796 <check_pgdir+0x191>
  103772:	c7 44 24 0c 7d 69 10 	movl   $0x10697d,0xc(%esp)
  103779:	00 
  10377a:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103781:	00 
  103782:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  103789:	00 
  10378a:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103791:	e8 53 cc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  103796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103799:	89 04 24             	mov    %eax,(%esp)
  10379c:	e8 3a f2 ff ff       	call   1029db <page_ref>
  1037a1:	83 f8 01             	cmp    $0x1,%eax
  1037a4:	74 24                	je     1037ca <check_pgdir+0x1c5>
  1037a6:	c7 44 24 0c 93 69 10 	movl   $0x106993,0xc(%esp)
  1037ad:	00 
  1037ae:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  1037b5:	00 
  1037b6:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  1037bd:	00 
  1037be:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1037c5:	e8 1f cc ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1037ca:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1037cf:	8b 00                	mov    (%eax),%eax
  1037d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1037d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1037d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037dc:	c1 e8 0c             	shr    $0xc,%eax
  1037df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1037e2:	a1 80 be 11 00       	mov    0x11be80,%eax
  1037e7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1037ea:	72 23                	jb     10380f <check_pgdir+0x20a>
  1037ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1037f3:	c7 44 24 08 60 67 10 	movl   $0x106760,0x8(%esp)
  1037fa:	00 
  1037fb:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  103802:	00 
  103803:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  10380a:	e8 da cb ff ff       	call   1003e9 <__panic>
  10380f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103812:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103817:	83 c0 04             	add    $0x4,%eax
  10381a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  10381d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103822:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103829:	00 
  10382a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103831:	00 
  103832:	89 04 24             	mov    %eax,(%esp)
  103835:	e8 5e fa ff ff       	call   103298 <get_pte>
  10383a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  10383d:	74 24                	je     103863 <check_pgdir+0x25e>
  10383f:	c7 44 24 0c a8 69 10 	movl   $0x1069a8,0xc(%esp)
  103846:	00 
  103847:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  10384e:	00 
  10384f:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  103856:	00 
  103857:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  10385e:	e8 86 cb ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  103863:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10386a:	e8 71 f3 ff ff       	call   102be0 <alloc_pages>
  10386f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103872:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103877:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  10387e:	00 
  10387f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103886:	00 
  103887:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10388a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10388e:	89 04 24             	mov    %eax,(%esp)
  103891:	e8 3b fc ff ff       	call   1034d1 <page_insert>
  103896:	85 c0                	test   %eax,%eax
  103898:	74 24                	je     1038be <check_pgdir+0x2b9>
  10389a:	c7 44 24 0c d0 69 10 	movl   $0x1069d0,0xc(%esp)
  1038a1:	00 
  1038a2:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  1038a9:	00 
  1038aa:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  1038b1:	00 
  1038b2:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1038b9:	e8 2b cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1038be:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1038c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038ca:	00 
  1038cb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1038d2:	00 
  1038d3:	89 04 24             	mov    %eax,(%esp)
  1038d6:	e8 bd f9 ff ff       	call   103298 <get_pte>
  1038db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1038de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1038e2:	75 24                	jne    103908 <check_pgdir+0x303>
  1038e4:	c7 44 24 0c 08 6a 10 	movl   $0x106a08,0xc(%esp)
  1038eb:	00 
  1038ec:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  1038f3:	00 
  1038f4:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  1038fb:	00 
  1038fc:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103903:	e8 e1 ca ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10390b:	8b 00                	mov    (%eax),%eax
  10390d:	83 e0 04             	and    $0x4,%eax
  103910:	85 c0                	test   %eax,%eax
  103912:	75 24                	jne    103938 <check_pgdir+0x333>
  103914:	c7 44 24 0c 38 6a 10 	movl   $0x106a38,0xc(%esp)
  10391b:	00 
  10391c:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103923:	00 
  103924:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  10392b:	00 
  10392c:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103933:	e8 b1 ca ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  103938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10393b:	8b 00                	mov    (%eax),%eax
  10393d:	83 e0 02             	and    $0x2,%eax
  103940:	85 c0                	test   %eax,%eax
  103942:	75 24                	jne    103968 <check_pgdir+0x363>
  103944:	c7 44 24 0c 46 6a 10 	movl   $0x106a46,0xc(%esp)
  10394b:	00 
  10394c:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103953:	00 
  103954:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  10395b:	00 
  10395c:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103963:	e8 81 ca ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103968:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10396d:	8b 00                	mov    (%eax),%eax
  10396f:	83 e0 04             	and    $0x4,%eax
  103972:	85 c0                	test   %eax,%eax
  103974:	75 24                	jne    10399a <check_pgdir+0x395>
  103976:	c7 44 24 0c 54 6a 10 	movl   $0x106a54,0xc(%esp)
  10397d:	00 
  10397e:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103985:	00 
  103986:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  10398d:	00 
  10398e:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103995:	e8 4f ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  10399a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10399d:	89 04 24             	mov    %eax,(%esp)
  1039a0:	e8 36 f0 ff ff       	call   1029db <page_ref>
  1039a5:	83 f8 01             	cmp    $0x1,%eax
  1039a8:	74 24                	je     1039ce <check_pgdir+0x3c9>
  1039aa:	c7 44 24 0c 6a 6a 10 	movl   $0x106a6a,0xc(%esp)
  1039b1:	00 
  1039b2:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  1039b9:	00 
  1039ba:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  1039c1:	00 
  1039c2:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  1039c9:	e8 1b ca ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  1039ce:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1039d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1039da:	00 
  1039db:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1039e2:	00 
  1039e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1039e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1039ea:	89 04 24             	mov    %eax,(%esp)
  1039ed:	e8 df fa ff ff       	call   1034d1 <page_insert>
  1039f2:	85 c0                	test   %eax,%eax
  1039f4:	74 24                	je     103a1a <check_pgdir+0x415>
  1039f6:	c7 44 24 0c 7c 6a 10 	movl   $0x106a7c,0xc(%esp)
  1039fd:	00 
  1039fe:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103a05:	00 
  103a06:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  103a0d:	00 
  103a0e:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103a15:	e8 cf c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  103a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a1d:	89 04 24             	mov    %eax,(%esp)
  103a20:	e8 b6 ef ff ff       	call   1029db <page_ref>
  103a25:	83 f8 02             	cmp    $0x2,%eax
  103a28:	74 24                	je     103a4e <check_pgdir+0x449>
  103a2a:	c7 44 24 0c a8 6a 10 	movl   $0x106aa8,0xc(%esp)
  103a31:	00 
  103a32:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103a39:	00 
  103a3a:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  103a41:	00 
  103a42:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103a49:	e8 9b c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a51:	89 04 24             	mov    %eax,(%esp)
  103a54:	e8 82 ef ff ff       	call   1029db <page_ref>
  103a59:	85 c0                	test   %eax,%eax
  103a5b:	74 24                	je     103a81 <check_pgdir+0x47c>
  103a5d:	c7 44 24 0c ba 6a 10 	movl   $0x106aba,0xc(%esp)
  103a64:	00 
  103a65:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103a6c:	00 
  103a6d:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103a74:	00 
  103a75:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103a7c:	e8 68 c9 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a81:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103a86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a8d:	00 
  103a8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a95:	00 
  103a96:	89 04 24             	mov    %eax,(%esp)
  103a99:	e8 fa f7 ff ff       	call   103298 <get_pte>
  103a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103aa1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103aa5:	75 24                	jne    103acb <check_pgdir+0x4c6>
  103aa7:	c7 44 24 0c 08 6a 10 	movl   $0x106a08,0xc(%esp)
  103aae:	00 
  103aaf:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103ab6:	00 
  103ab7:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103abe:	00 
  103abf:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103ac6:	e8 1e c9 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ace:	8b 00                	mov    (%eax),%eax
  103ad0:	89 04 24             	mov    %eax,(%esp)
  103ad3:	e8 ad ee ff ff       	call   102985 <pte2page>
  103ad8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103adb:	74 24                	je     103b01 <check_pgdir+0x4fc>
  103add:	c7 44 24 0c 7d 69 10 	movl   $0x10697d,0xc(%esp)
  103ae4:	00 
  103ae5:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103aec:	00 
  103aed:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103af4:	00 
  103af5:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103afc:	e8 e8 c8 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b04:	8b 00                	mov    (%eax),%eax
  103b06:	83 e0 04             	and    $0x4,%eax
  103b09:	85 c0                	test   %eax,%eax
  103b0b:	74 24                	je     103b31 <check_pgdir+0x52c>
  103b0d:	c7 44 24 0c cc 6a 10 	movl   $0x106acc,0xc(%esp)
  103b14:	00 
  103b15:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103b1c:	00 
  103b1d:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103b24:	00 
  103b25:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103b2c:	e8 b8 c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103b31:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103b36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103b3d:	00 
  103b3e:	89 04 24             	mov    %eax,(%esp)
  103b41:	e8 46 f9 ff ff       	call   10348c <page_remove>
    assert(page_ref(p1) == 1);
  103b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b49:	89 04 24             	mov    %eax,(%esp)
  103b4c:	e8 8a ee ff ff       	call   1029db <page_ref>
  103b51:	83 f8 01             	cmp    $0x1,%eax
  103b54:	74 24                	je     103b7a <check_pgdir+0x575>
  103b56:	c7 44 24 0c 93 69 10 	movl   $0x106993,0xc(%esp)
  103b5d:	00 
  103b5e:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103b65:	00 
  103b66:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103b6d:	00 
  103b6e:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103b75:	e8 6f c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b7d:	89 04 24             	mov    %eax,(%esp)
  103b80:	e8 56 ee ff ff       	call   1029db <page_ref>
  103b85:	85 c0                	test   %eax,%eax
  103b87:	74 24                	je     103bad <check_pgdir+0x5a8>
  103b89:	c7 44 24 0c ba 6a 10 	movl   $0x106aba,0xc(%esp)
  103b90:	00 
  103b91:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103b98:	00 
  103b99:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  103ba0:	00 
  103ba1:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103ba8:	e8 3c c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103bad:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103bb2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103bb9:	00 
  103bba:	89 04 24             	mov    %eax,(%esp)
  103bbd:	e8 ca f8 ff ff       	call   10348c <page_remove>
    assert(page_ref(p1) == 0);
  103bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bc5:	89 04 24             	mov    %eax,(%esp)
  103bc8:	e8 0e ee ff ff       	call   1029db <page_ref>
  103bcd:	85 c0                	test   %eax,%eax
  103bcf:	74 24                	je     103bf5 <check_pgdir+0x5f0>
  103bd1:	c7 44 24 0c e1 6a 10 	movl   $0x106ae1,0xc(%esp)
  103bd8:	00 
  103bd9:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103be0:	00 
  103be1:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103be8:	00 
  103be9:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103bf0:	e8 f4 c7 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103bf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bf8:	89 04 24             	mov    %eax,(%esp)
  103bfb:	e8 db ed ff ff       	call   1029db <page_ref>
  103c00:	85 c0                	test   %eax,%eax
  103c02:	74 24                	je     103c28 <check_pgdir+0x623>
  103c04:	c7 44 24 0c ba 6a 10 	movl   $0x106aba,0xc(%esp)
  103c0b:	00 
  103c0c:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103c13:	00 
  103c14:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103c1b:	00 
  103c1c:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103c23:	e8 c1 c7 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103c28:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c2d:	8b 00                	mov    (%eax),%eax
  103c2f:	89 04 24             	mov    %eax,(%esp)
  103c32:	e8 8c ed ff ff       	call   1029c3 <pde2page>
  103c37:	89 04 24             	mov    %eax,(%esp)
  103c3a:	e8 9c ed ff ff       	call   1029db <page_ref>
  103c3f:	83 f8 01             	cmp    $0x1,%eax
  103c42:	74 24                	je     103c68 <check_pgdir+0x663>
  103c44:	c7 44 24 0c f4 6a 10 	movl   $0x106af4,0xc(%esp)
  103c4b:	00 
  103c4c:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103c53:	00 
  103c54:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103c5b:	00 
  103c5c:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103c63:	e8 81 c7 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103c68:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c6d:	8b 00                	mov    (%eax),%eax
  103c6f:	89 04 24             	mov    %eax,(%esp)
  103c72:	e8 4c ed ff ff       	call   1029c3 <pde2page>
  103c77:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103c7e:	00 
  103c7f:	89 04 24             	mov    %eax,(%esp)
  103c82:	e8 91 ef ff ff       	call   102c18 <free_pages>
    boot_pgdir[0] = 0;
  103c87:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103c92:	c7 04 24 1b 6b 10 00 	movl   $0x106b1b,(%esp)
  103c99:	e8 f4 c5 ff ff       	call   100292 <cprintf>
}
  103c9e:	90                   	nop
  103c9f:	c9                   	leave  
  103ca0:	c3                   	ret    

00103ca1 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103ca1:	55                   	push   %ebp
  103ca2:	89 e5                	mov    %esp,%ebp
  103ca4:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103cae:	e9 ca 00 00 00       	jmp    103d7d <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103cbc:	c1 e8 0c             	shr    $0xc,%eax
  103cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103cc2:	a1 80 be 11 00       	mov    0x11be80,%eax
  103cc7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103cca:	72 23                	jb     103cef <check_boot_pgdir+0x4e>
  103ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103cd3:	c7 44 24 08 60 67 10 	movl   $0x106760,0x8(%esp)
  103cda:	00 
  103cdb:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103ce2:	00 
  103ce3:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103cea:	e8 fa c6 ff ff       	call   1003e9 <__panic>
  103cef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103cf2:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103cf7:	89 c2                	mov    %eax,%edx
  103cf9:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103cfe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103d05:	00 
  103d06:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d0a:	89 04 24             	mov    %eax,(%esp)
  103d0d:	e8 86 f5 ff ff       	call   103298 <get_pte>
  103d12:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103d15:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103d19:	75 24                	jne    103d3f <check_boot_pgdir+0x9e>
  103d1b:	c7 44 24 0c 38 6b 10 	movl   $0x106b38,0xc(%esp)
  103d22:	00 
  103d23:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103d2a:	00 
  103d2b:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103d32:	00 
  103d33:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103d3a:	e8 aa c6 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103d3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103d42:	8b 00                	mov    (%eax),%eax
  103d44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d49:	89 c2                	mov    %eax,%edx
  103d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d4e:	39 c2                	cmp    %eax,%edx
  103d50:	74 24                	je     103d76 <check_boot_pgdir+0xd5>
  103d52:	c7 44 24 0c 75 6b 10 	movl   $0x106b75,0xc(%esp)
  103d59:	00 
  103d5a:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103d61:	00 
  103d62:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103d69:	00 
  103d6a:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103d71:	e8 73 c6 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103d76:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103d7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d80:	a1 80 be 11 00       	mov    0x11be80,%eax
  103d85:	39 c2                	cmp    %eax,%edx
  103d87:	0f 82 26 ff ff ff    	jb     103cb3 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103d8d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103d92:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d97:	8b 00                	mov    (%eax),%eax
  103d99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d9e:	89 c2                	mov    %eax,%edx
  103da0:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103da8:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103daf:	77 23                	ja     103dd4 <check_boot_pgdir+0x133>
  103db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103db4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103db8:	c7 44 24 08 04 68 10 	movl   $0x106804,0x8(%esp)
  103dbf:	00 
  103dc0:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103dc7:	00 
  103dc8:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103dcf:	e8 15 c6 ff ff       	call   1003e9 <__panic>
  103dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103dd7:	05 00 00 00 40       	add    $0x40000000,%eax
  103ddc:	39 d0                	cmp    %edx,%eax
  103dde:	74 24                	je     103e04 <check_boot_pgdir+0x163>
  103de0:	c7 44 24 0c 8c 6b 10 	movl   $0x106b8c,0xc(%esp)
  103de7:	00 
  103de8:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103def:	00 
  103df0:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103df7:	00 
  103df8:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103dff:	e8 e5 c5 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103e04:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103e09:	8b 00                	mov    (%eax),%eax
  103e0b:	85 c0                	test   %eax,%eax
  103e0d:	74 24                	je     103e33 <check_boot_pgdir+0x192>
  103e0f:	c7 44 24 0c c0 6b 10 	movl   $0x106bc0,0xc(%esp)
  103e16:	00 
  103e17:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103e1e:	00 
  103e1f:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103e26:	00 
  103e27:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103e2e:	e8 b6 c5 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e3a:	e8 a1 ed ff ff       	call   102be0 <alloc_pages>
  103e3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103e42:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103e47:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e4e:	00 
  103e4f:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103e56:	00 
  103e57:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103e5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e5e:	89 04 24             	mov    %eax,(%esp)
  103e61:	e8 6b f6 ff ff       	call   1034d1 <page_insert>
  103e66:	85 c0                	test   %eax,%eax
  103e68:	74 24                	je     103e8e <check_boot_pgdir+0x1ed>
  103e6a:	c7 44 24 0c d4 6b 10 	movl   $0x106bd4,0xc(%esp)
  103e71:	00 
  103e72:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103e79:	00 
  103e7a:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103e81:	00 
  103e82:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103e89:	e8 5b c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103e8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e91:	89 04 24             	mov    %eax,(%esp)
  103e94:	e8 42 eb ff ff       	call   1029db <page_ref>
  103e99:	83 f8 01             	cmp    $0x1,%eax
  103e9c:	74 24                	je     103ec2 <check_boot_pgdir+0x221>
  103e9e:	c7 44 24 0c 02 6c 10 	movl   $0x106c02,0xc(%esp)
  103ea5:	00 
  103ea6:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103ead:	00 
  103eae:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103eb5:	00 
  103eb6:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103ebd:	e8 27 c5 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103ec2:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103ec7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103ece:	00 
  103ecf:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103ed6:	00 
  103ed7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103eda:	89 54 24 04          	mov    %edx,0x4(%esp)
  103ede:	89 04 24             	mov    %eax,(%esp)
  103ee1:	e8 eb f5 ff ff       	call   1034d1 <page_insert>
  103ee6:	85 c0                	test   %eax,%eax
  103ee8:	74 24                	je     103f0e <check_boot_pgdir+0x26d>
  103eea:	c7 44 24 0c 14 6c 10 	movl   $0x106c14,0xc(%esp)
  103ef1:	00 
  103ef2:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103ef9:	00 
  103efa:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103f01:	00 
  103f02:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103f09:	e8 db c4 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f11:	89 04 24             	mov    %eax,(%esp)
  103f14:	e8 c2 ea ff ff       	call   1029db <page_ref>
  103f19:	83 f8 02             	cmp    $0x2,%eax
  103f1c:	74 24                	je     103f42 <check_boot_pgdir+0x2a1>
  103f1e:	c7 44 24 0c 4b 6c 10 	movl   $0x106c4b,0xc(%esp)
  103f25:	00 
  103f26:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103f2d:	00 
  103f2e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103f35:	00 
  103f36:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103f3d:	e8 a7 c4 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103f42:	c7 45 e8 5c 6c 10 00 	movl   $0x106c5c,-0x18(%ebp)
    strcpy((void *)0x100, str);
  103f49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103f50:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f57:	e8 e1 15 00 00       	call   10553d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103f5c:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103f63:	00 
  103f64:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f6b:	e8 44 16 00 00       	call   1055b4 <strcmp>
  103f70:	85 c0                	test   %eax,%eax
  103f72:	74 24                	je     103f98 <check_boot_pgdir+0x2f7>
  103f74:	c7 44 24 0c 74 6c 10 	movl   $0x106c74,0xc(%esp)
  103f7b:	00 
  103f7c:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103f83:	00 
  103f84:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  103f8b:	00 
  103f8c:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103f93:	e8 51 c4 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f9b:	89 04 24             	mov    %eax,(%esp)
  103f9e:	e8 8e e9 ff ff       	call   102931 <page2kva>
  103fa3:	05 00 01 00 00       	add    $0x100,%eax
  103fa8:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103fab:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103fb2:	e8 30 15 00 00       	call   1054e7 <strlen>
  103fb7:	85 c0                	test   %eax,%eax
  103fb9:	74 24                	je     103fdf <check_boot_pgdir+0x33e>
  103fbb:	c7 44 24 0c ac 6c 10 	movl   $0x106cac,0xc(%esp)
  103fc2:	00 
  103fc3:	c7 44 24 08 4d 68 10 	movl   $0x10684d,0x8(%esp)
  103fca:	00 
  103fcb:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  103fd2:	00 
  103fd3:	c7 04 24 28 68 10 00 	movl   $0x106828,(%esp)
  103fda:	e8 0a c4 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103fdf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fe6:	00 
  103fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103fea:	89 04 24             	mov    %eax,(%esp)
  103fed:	e8 26 ec ff ff       	call   102c18 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103ff2:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103ff7:	8b 00                	mov    (%eax),%eax
  103ff9:	89 04 24             	mov    %eax,(%esp)
  103ffc:	e8 c2 e9 ff ff       	call   1029c3 <pde2page>
  104001:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104008:	00 
  104009:	89 04 24             	mov    %eax,(%esp)
  10400c:	e8 07 ec ff ff       	call   102c18 <free_pages>
    boot_pgdir[0] = 0;
  104011:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104016:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10401c:	c7 04 24 d0 6c 10 00 	movl   $0x106cd0,(%esp)
  104023:	e8 6a c2 ff ff       	call   100292 <cprintf>
}
  104028:	90                   	nop
  104029:	c9                   	leave  
  10402a:	c3                   	ret    

0010402b <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  10402b:	55                   	push   %ebp
  10402c:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10402e:	8b 45 08             	mov    0x8(%ebp),%eax
  104031:	83 e0 04             	and    $0x4,%eax
  104034:	85 c0                	test   %eax,%eax
  104036:	74 04                	je     10403c <perm2str+0x11>
  104038:	b0 75                	mov    $0x75,%al
  10403a:	eb 02                	jmp    10403e <perm2str+0x13>
  10403c:	b0 2d                	mov    $0x2d,%al
  10403e:	a2 08 bf 11 00       	mov    %al,0x11bf08
    str[1] = 'r';
  104043:	c6 05 09 bf 11 00 72 	movb   $0x72,0x11bf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  10404a:	8b 45 08             	mov    0x8(%ebp),%eax
  10404d:	83 e0 02             	and    $0x2,%eax
  104050:	85 c0                	test   %eax,%eax
  104052:	74 04                	je     104058 <perm2str+0x2d>
  104054:	b0 77                	mov    $0x77,%al
  104056:	eb 02                	jmp    10405a <perm2str+0x2f>
  104058:	b0 2d                	mov    $0x2d,%al
  10405a:	a2 0a bf 11 00       	mov    %al,0x11bf0a
    str[3] = '\0';
  10405f:	c6 05 0b bf 11 00 00 	movb   $0x0,0x11bf0b
    return str;
  104066:	b8 08 bf 11 00       	mov    $0x11bf08,%eax
}
  10406b:	5d                   	pop    %ebp
  10406c:	c3                   	ret    

0010406d <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  10406d:	55                   	push   %ebp
  10406e:	89 e5                	mov    %esp,%ebp
  104070:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  104073:	8b 45 10             	mov    0x10(%ebp),%eax
  104076:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104079:	72 0d                	jb     104088 <get_pgtable_items+0x1b>
        return 0;
  10407b:	b8 00 00 00 00       	mov    $0x0,%eax
  104080:	e9 98 00 00 00       	jmp    10411d <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  104085:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  104088:	8b 45 10             	mov    0x10(%ebp),%eax
  10408b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10408e:	73 18                	jae    1040a8 <get_pgtable_items+0x3b>
  104090:	8b 45 10             	mov    0x10(%ebp),%eax
  104093:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10409a:	8b 45 14             	mov    0x14(%ebp),%eax
  10409d:	01 d0                	add    %edx,%eax
  10409f:	8b 00                	mov    (%eax),%eax
  1040a1:	83 e0 01             	and    $0x1,%eax
  1040a4:	85 c0                	test   %eax,%eax
  1040a6:	74 dd                	je     104085 <get_pgtable_items+0x18>
    }
    if (start < right) {
  1040a8:	8b 45 10             	mov    0x10(%ebp),%eax
  1040ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040ae:	73 68                	jae    104118 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1040b0:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1040b4:	74 08                	je     1040be <get_pgtable_items+0x51>
            *left_store = start;
  1040b6:	8b 45 18             	mov    0x18(%ebp),%eax
  1040b9:	8b 55 10             	mov    0x10(%ebp),%edx
  1040bc:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1040be:	8b 45 10             	mov    0x10(%ebp),%eax
  1040c1:	8d 50 01             	lea    0x1(%eax),%edx
  1040c4:	89 55 10             	mov    %edx,0x10(%ebp)
  1040c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1040ce:	8b 45 14             	mov    0x14(%ebp),%eax
  1040d1:	01 d0                	add    %edx,%eax
  1040d3:	8b 00                	mov    (%eax),%eax
  1040d5:	83 e0 07             	and    $0x7,%eax
  1040d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1040db:	eb 03                	jmp    1040e0 <get_pgtable_items+0x73>
            start ++;
  1040dd:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1040e0:	8b 45 10             	mov    0x10(%ebp),%eax
  1040e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040e6:	73 1d                	jae    104105 <get_pgtable_items+0x98>
  1040e8:	8b 45 10             	mov    0x10(%ebp),%eax
  1040eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1040f2:	8b 45 14             	mov    0x14(%ebp),%eax
  1040f5:	01 d0                	add    %edx,%eax
  1040f7:	8b 00                	mov    (%eax),%eax
  1040f9:	83 e0 07             	and    $0x7,%eax
  1040fc:	89 c2                	mov    %eax,%edx
  1040fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104101:	39 c2                	cmp    %eax,%edx
  104103:	74 d8                	je     1040dd <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  104105:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104109:	74 08                	je     104113 <get_pgtable_items+0xa6>
            *right_store = start;
  10410b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10410e:	8b 55 10             	mov    0x10(%ebp),%edx
  104111:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104113:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104116:	eb 05                	jmp    10411d <get_pgtable_items+0xb0>
    }
    return 0;
  104118:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10411d:	c9                   	leave  
  10411e:	c3                   	ret    

0010411f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10411f:	55                   	push   %ebp
  104120:	89 e5                	mov    %esp,%ebp
  104122:	57                   	push   %edi
  104123:	56                   	push   %esi
  104124:	53                   	push   %ebx
  104125:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  104128:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  10412f:	e8 5e c1 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  104134:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10413b:	e9 fa 00 00 00       	jmp    10423a <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104143:	89 04 24             	mov    %eax,(%esp)
  104146:	e8 e0 fe ff ff       	call   10402b <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  10414b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10414e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104151:	29 d1                	sub    %edx,%ecx
  104153:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104155:	89 d6                	mov    %edx,%esi
  104157:	c1 e6 16             	shl    $0x16,%esi
  10415a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10415d:	89 d3                	mov    %edx,%ebx
  10415f:	c1 e3 16             	shl    $0x16,%ebx
  104162:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104165:	89 d1                	mov    %edx,%ecx
  104167:	c1 e1 16             	shl    $0x16,%ecx
  10416a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  10416d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104170:	29 d7                	sub    %edx,%edi
  104172:	89 fa                	mov    %edi,%edx
  104174:	89 44 24 14          	mov    %eax,0x14(%esp)
  104178:	89 74 24 10          	mov    %esi,0x10(%esp)
  10417c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104180:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104184:	89 54 24 04          	mov    %edx,0x4(%esp)
  104188:	c7 04 24 21 6d 10 00 	movl   $0x106d21,(%esp)
  10418f:	e8 fe c0 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  104194:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104197:	c1 e0 0a             	shl    $0xa,%eax
  10419a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10419d:	eb 54                	jmp    1041f3 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10419f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1041a2:	89 04 24             	mov    %eax,(%esp)
  1041a5:	e8 81 fe ff ff       	call   10402b <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1041aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1041ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1041b0:	29 d1                	sub    %edx,%ecx
  1041b2:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1041b4:	89 d6                	mov    %edx,%esi
  1041b6:	c1 e6 0c             	shl    $0xc,%esi
  1041b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041bc:	89 d3                	mov    %edx,%ebx
  1041be:	c1 e3 0c             	shl    $0xc,%ebx
  1041c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1041c4:	89 d1                	mov    %edx,%ecx
  1041c6:	c1 e1 0c             	shl    $0xc,%ecx
  1041c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1041cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1041cf:	29 d7                	sub    %edx,%edi
  1041d1:	89 fa                	mov    %edi,%edx
  1041d3:	89 44 24 14          	mov    %eax,0x14(%esp)
  1041d7:	89 74 24 10          	mov    %esi,0x10(%esp)
  1041db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1041df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1041e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  1041e7:	c7 04 24 40 6d 10 00 	movl   $0x106d40,(%esp)
  1041ee:	e8 9f c0 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1041f3:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1041f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1041fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041fe:	89 d3                	mov    %edx,%ebx
  104200:	c1 e3 0a             	shl    $0xa,%ebx
  104203:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104206:	89 d1                	mov    %edx,%ecx
  104208:	c1 e1 0a             	shl    $0xa,%ecx
  10420b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  10420e:	89 54 24 14          	mov    %edx,0x14(%esp)
  104212:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104215:	89 54 24 10          	mov    %edx,0x10(%esp)
  104219:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10421d:	89 44 24 08          	mov    %eax,0x8(%esp)
  104221:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104225:	89 0c 24             	mov    %ecx,(%esp)
  104228:	e8 40 fe ff ff       	call   10406d <get_pgtable_items>
  10422d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104230:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104234:	0f 85 65 ff ff ff    	jne    10419f <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10423a:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  10423f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104242:	8d 55 dc             	lea    -0x24(%ebp),%edx
  104245:	89 54 24 14          	mov    %edx,0x14(%esp)
  104249:	8d 55 e0             	lea    -0x20(%ebp),%edx
  10424c:	89 54 24 10          	mov    %edx,0x10(%esp)
  104250:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  104254:	89 44 24 08          	mov    %eax,0x8(%esp)
  104258:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10425f:	00 
  104260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104267:	e8 01 fe ff ff       	call   10406d <get_pgtable_items>
  10426c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10426f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104273:	0f 85 c7 fe ff ff    	jne    104140 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104279:	c7 04 24 64 6d 10 00 	movl   $0x106d64,(%esp)
  104280:	e8 0d c0 ff ff       	call   100292 <cprintf>
}
  104285:	90                   	nop
  104286:	83 c4 4c             	add    $0x4c,%esp
  104289:	5b                   	pop    %ebx
  10428a:	5e                   	pop    %esi
  10428b:	5f                   	pop    %edi
  10428c:	5d                   	pop    %ebp
  10428d:	c3                   	ret    

0010428e <page2ppn>:
page2ppn(struct Page *page) {
  10428e:	55                   	push   %ebp
  10428f:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104291:	8b 45 08             	mov    0x8(%ebp),%eax
  104294:	8b 15 18 bf 11 00    	mov    0x11bf18,%edx
  10429a:	29 d0                	sub    %edx,%eax
  10429c:	c1 f8 02             	sar    $0x2,%eax
  10429f:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1042a5:	5d                   	pop    %ebp
  1042a6:	c3                   	ret    

001042a7 <page2pa>:
page2pa(struct Page *page) {
  1042a7:	55                   	push   %ebp
  1042a8:	89 e5                	mov    %esp,%ebp
  1042aa:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1042ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1042b0:	89 04 24             	mov    %eax,(%esp)
  1042b3:	e8 d6 ff ff ff       	call   10428e <page2ppn>
  1042b8:	c1 e0 0c             	shl    $0xc,%eax
}
  1042bb:	c9                   	leave  
  1042bc:	c3                   	ret    

001042bd <page_ref>:
page_ref(struct Page *page) {
  1042bd:	55                   	push   %ebp
  1042be:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1042c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1042c3:	8b 00                	mov    (%eax),%eax
}
  1042c5:	5d                   	pop    %ebp
  1042c6:	c3                   	ret    

001042c7 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  1042c7:	55                   	push   %ebp
  1042c8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1042ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1042cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1042d0:	89 10                	mov    %edx,(%eax)
}
  1042d2:	90                   	nop
  1042d3:	5d                   	pop    %ebp
  1042d4:	c3                   	ret    

001042d5 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1042d5:	55                   	push   %ebp
  1042d6:	89 e5                	mov    %esp,%ebp
  1042d8:	83 ec 10             	sub    $0x10,%esp
  1042db:	c7 45 fc 1c bf 11 00 	movl   $0x11bf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1042e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1042e8:	89 50 04             	mov    %edx,0x4(%eax)
  1042eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042ee:	8b 50 04             	mov    0x4(%eax),%edx
  1042f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042f4:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1042f6:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  1042fd:	00 00 00 
}
  104300:	90                   	nop
  104301:	c9                   	leave  
  104302:	c3                   	ret    

00104303 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  104303:	55                   	push   %ebp
  104304:	89 e5                	mov    %esp,%ebp
  104306:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  104309:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10430d:	75 24                	jne    104333 <default_init_memmap+0x30>
  10430f:	c7 44 24 0c 98 6d 10 	movl   $0x106d98,0xc(%esp)
  104316:	00 
  104317:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  10431e:	00 
  10431f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  104326:	00 
  104327:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  10432e:	e8 b6 c0 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  104333:	8b 45 08             	mov    0x8(%ebp),%eax
  104336:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104339:	eb 7d                	jmp    1043b8 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  10433b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10433e:	83 c0 04             	add    $0x4,%eax
  104341:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104348:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10434b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10434e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104351:	0f a3 10             	bt     %edx,(%eax)
  104354:	19 c0                	sbb    %eax,%eax
  104356:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104359:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10435d:	0f 95 c0             	setne  %al
  104360:	0f b6 c0             	movzbl %al,%eax
  104363:	85 c0                	test   %eax,%eax
  104365:	75 24                	jne    10438b <default_init_memmap+0x88>
  104367:	c7 44 24 0c c9 6d 10 	movl   $0x106dc9,0xc(%esp)
  10436e:	00 
  10436f:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104376:	00 
  104377:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10437e:	00 
  10437f:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104386:	e8 5e c0 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  10438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10438e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  104395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104398:	8b 50 08             	mov    0x8(%eax),%edx
  10439b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10439e:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  1043a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1043a8:	00 
  1043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043ac:	89 04 24             	mov    %eax,(%esp)
  1043af:	e8 13 ff ff ff       	call   1042c7 <set_page_ref>
    for (; p != base + n; p ++) {
  1043b4:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1043b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1043bb:	89 d0                	mov    %edx,%eax
  1043bd:	c1 e0 02             	shl    $0x2,%eax
  1043c0:	01 d0                	add    %edx,%eax
  1043c2:	c1 e0 02             	shl    $0x2,%eax
  1043c5:	89 c2                	mov    %eax,%edx
  1043c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1043ca:	01 d0                	add    %edx,%eax
  1043cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1043cf:	0f 85 66 ff ff ff    	jne    10433b <default_init_memmap+0x38>
    }
    base->property = n;
  1043d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1043d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1043db:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1043de:	8b 45 08             	mov    0x8(%ebp),%eax
  1043e1:	83 c0 04             	add    $0x4,%eax
  1043e4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1043eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043f1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1043f4:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1043f7:	8b 15 24 bf 11 00    	mov    0x11bf24,%edx
  1043fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  104400:	01 d0                	add    %edx,%eax
  104402:	a3 24 bf 11 00       	mov    %eax,0x11bf24
    list_add_before(&free_list, &(base->page_link));
  104407:	8b 45 08             	mov    0x8(%ebp),%eax
  10440a:	83 c0 0c             	add    $0xc,%eax
  10440d:	c7 45 e4 1c bf 11 00 	movl   $0x11bf1c,-0x1c(%ebp)
  104414:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  104417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10441a:	8b 00                	mov    (%eax),%eax
  10441c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10441f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  104422:	89 45 d8             	mov    %eax,-0x28(%ebp)
  104425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104428:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10442b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10442e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104431:	89 10                	mov    %edx,(%eax)
  104433:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104436:	8b 10                	mov    (%eax),%edx
  104438:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10443b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10443e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104441:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104444:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104447:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10444a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10444d:	89 10                	mov    %edx,(%eax)
}
  10444f:	90                   	nop
  104450:	c9                   	leave  
  104451:	c3                   	ret    

00104452 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  104452:	55                   	push   %ebp
  104453:	89 e5                	mov    %esp,%ebp
  104455:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  104458:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10445c:	75 24                	jne    104482 <default_alloc_pages+0x30>
  10445e:	c7 44 24 0c 98 6d 10 	movl   $0x106d98,0xc(%esp)
  104465:	00 
  104466:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  10446d:	00 
  10446e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  104475:	00 
  104476:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  10447d:	e8 67 bf ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  104482:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104487:	39 45 08             	cmp    %eax,0x8(%ebp)
  10448a:	76 0a                	jbe    104496 <default_alloc_pages+0x44>
        return NULL;
  10448c:	b8 00 00 00 00       	mov    $0x0,%eax
  104491:	e9 49 01 00 00       	jmp    1045df <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
  104496:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  10449d:	c7 45 f0 1c bf 11 00 	movl   $0x11bf1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1044a4:	eb 1c                	jmp    1044c2 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  1044a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044a9:	83 e8 0c             	sub    $0xc,%eax
  1044ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  1044af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044b2:	8b 40 08             	mov    0x8(%eax),%eax
  1044b5:	39 45 08             	cmp    %eax,0x8(%ebp)
  1044b8:	77 08                	ja     1044c2 <default_alloc_pages+0x70>
            page = p;
  1044ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  1044c0:	eb 18                	jmp    1044da <default_alloc_pages+0x88>
  1044c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  1044c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1044cb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1044ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1044d1:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  1044d8:	75 cc                	jne    1044a6 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  1044da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1044de:	0f 84 f8 00 00 00    	je     1045dc <default_alloc_pages+0x18a>
        if (page->property > n) {
  1044e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044e7:	8b 40 08             	mov    0x8(%eax),%eax
  1044ea:	39 45 08             	cmp    %eax,0x8(%ebp)
  1044ed:	0f 83 98 00 00 00    	jae    10458b <default_alloc_pages+0x139>
            struct Page *p = page + n;
  1044f3:	8b 55 08             	mov    0x8(%ebp),%edx
  1044f6:	89 d0                	mov    %edx,%eax
  1044f8:	c1 e0 02             	shl    $0x2,%eax
  1044fb:	01 d0                	add    %edx,%eax
  1044fd:	c1 e0 02             	shl    $0x2,%eax
  104500:	89 c2                	mov    %eax,%edx
  104502:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104505:	01 d0                	add    %edx,%eax
  104507:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  10450a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10450d:	8b 40 08             	mov    0x8(%eax),%eax
  104510:	2b 45 08             	sub    0x8(%ebp),%eax
  104513:	89 c2                	mov    %eax,%edx
  104515:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104518:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  10451b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10451e:	83 c0 04             	add    $0x4,%eax
  104521:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  104528:	89 45 c0             	mov    %eax,-0x40(%ebp)
  10452b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10452e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104531:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
  104534:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104537:	83 c0 0c             	add    $0xc,%eax
  10453a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10453d:	83 c2 0c             	add    $0xc,%edx
  104540:	89 55 e0             	mov    %edx,-0x20(%ebp)
  104543:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104546:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  10454c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10454f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  104552:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104555:	8b 40 04             	mov    0x4(%eax),%eax
  104558:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10455b:	89 55 d0             	mov    %edx,-0x30(%ebp)
  10455e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104561:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104564:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  104567:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10456a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10456d:	89 10                	mov    %edx,(%eax)
  10456f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104572:	8b 10                	mov    (%eax),%edx
  104574:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104577:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10457a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10457d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104580:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104583:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104586:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104589:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  10458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10458e:	83 c0 0c             	add    $0xc,%eax
  104591:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  104594:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104597:	8b 40 04             	mov    0x4(%eax),%eax
  10459a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10459d:	8b 12                	mov    (%edx),%edx
  10459f:	89 55 b0             	mov    %edx,-0x50(%ebp)
  1045a2:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1045a5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1045a8:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1045ab:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1045ae:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1045b1:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1045b4:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  1045b6:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  1045bb:	2b 45 08             	sub    0x8(%ebp),%eax
  1045be:	a3 24 bf 11 00       	mov    %eax,0x11bf24
        ClearPageProperty(page);
  1045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c6:	83 c0 04             	add    $0x4,%eax
  1045c9:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  1045d0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1045d3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1045d6:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045d9:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  1045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1045df:	c9                   	leave  
  1045e0:	c3                   	ret    

001045e1 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  1045e1:	55                   	push   %ebp
  1045e2:	89 e5                	mov    %esp,%ebp
  1045e4:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  1045ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1045ee:	75 24                	jne    104614 <default_free_pages+0x33>
  1045f0:	c7 44 24 0c 98 6d 10 	movl   $0x106d98,0xc(%esp)
  1045f7:	00 
  1045f8:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1045ff:	00 
  104600:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  104607:	00 
  104608:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  10460f:	e8 d5 bd ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  104614:	8b 45 08             	mov    0x8(%ebp),%eax
  104617:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10461a:	e9 9d 00 00 00       	jmp    1046bc <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  10461f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104622:	83 c0 04             	add    $0x4,%eax
  104625:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10462c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10462f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104632:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104635:	0f a3 10             	bt     %edx,(%eax)
  104638:	19 c0                	sbb    %eax,%eax
  10463a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10463d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104641:	0f 95 c0             	setne  %al
  104644:	0f b6 c0             	movzbl %al,%eax
  104647:	85 c0                	test   %eax,%eax
  104649:	75 2c                	jne    104677 <default_free_pages+0x96>
  10464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464e:	83 c0 04             	add    $0x4,%eax
  104651:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  104658:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10465b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10465e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104661:	0f a3 10             	bt     %edx,(%eax)
  104664:	19 c0                	sbb    %eax,%eax
  104666:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  104669:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10466d:	0f 95 c0             	setne  %al
  104670:	0f b6 c0             	movzbl %al,%eax
  104673:	85 c0                	test   %eax,%eax
  104675:	74 24                	je     10469b <default_free_pages+0xba>
  104677:	c7 44 24 0c dc 6d 10 	movl   $0x106ddc,0xc(%esp)
  10467e:	00 
  10467f:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104686:	00 
  104687:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  10468e:	00 
  10468f:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104696:	e8 4e bd ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  10469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10469e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  1046a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1046ac:	00 
  1046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046b0:	89 04 24             	mov    %eax,(%esp)
  1046b3:	e8 0f fc ff ff       	call   1042c7 <set_page_ref>
    for (; p != base + n; p ++) {
  1046b8:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1046bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1046bf:	89 d0                	mov    %edx,%eax
  1046c1:	c1 e0 02             	shl    $0x2,%eax
  1046c4:	01 d0                	add    %edx,%eax
  1046c6:	c1 e0 02             	shl    $0x2,%eax
  1046c9:	89 c2                	mov    %eax,%edx
  1046cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1046ce:	01 d0                	add    %edx,%eax
  1046d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046d3:	0f 85 46 ff ff ff    	jne    10461f <default_free_pages+0x3e>
    }
    base->property = n;
  1046d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1046dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1046df:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1046e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e5:	83 c0 04             	add    $0x4,%eax
  1046e8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1046ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1046f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1046f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1046f8:	0f ab 10             	bts    %edx,(%eax)
  1046fb:	c7 45 d4 1c bf 11 00 	movl   $0x11bf1c,-0x2c(%ebp)
    return listelm->next;
  104702:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104705:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  104708:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  10470b:	e9 08 01 00 00       	jmp    104818 <default_free_pages+0x237>
        p = le2page(le, page_link);
  104710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104713:	83 e8 0c             	sub    $0xc,%eax
  104716:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104719:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10471c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10471f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104722:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  104725:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  104728:	8b 45 08             	mov    0x8(%ebp),%eax
  10472b:	8b 50 08             	mov    0x8(%eax),%edx
  10472e:	89 d0                	mov    %edx,%eax
  104730:	c1 e0 02             	shl    $0x2,%eax
  104733:	01 d0                	add    %edx,%eax
  104735:	c1 e0 02             	shl    $0x2,%eax
  104738:	89 c2                	mov    %eax,%edx
  10473a:	8b 45 08             	mov    0x8(%ebp),%eax
  10473d:	01 d0                	add    %edx,%eax
  10473f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104742:	75 5a                	jne    10479e <default_free_pages+0x1bd>
            base->property += p->property;
  104744:	8b 45 08             	mov    0x8(%ebp),%eax
  104747:	8b 50 08             	mov    0x8(%eax),%edx
  10474a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10474d:	8b 40 08             	mov    0x8(%eax),%eax
  104750:	01 c2                	add    %eax,%edx
  104752:	8b 45 08             	mov    0x8(%ebp),%eax
  104755:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  104758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10475b:	83 c0 04             	add    $0x4,%eax
  10475e:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  104765:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104768:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10476b:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10476e:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  104771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104774:	83 c0 0c             	add    $0xc,%eax
  104777:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10477a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10477d:	8b 40 04             	mov    0x4(%eax),%eax
  104780:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104783:	8b 12                	mov    (%edx),%edx
  104785:	89 55 c0             	mov    %edx,-0x40(%ebp)
  104788:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  10478b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10478e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104791:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104794:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104797:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10479a:	89 10                	mov    %edx,(%eax)
  10479c:	eb 7a                	jmp    104818 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  10479e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047a1:	8b 50 08             	mov    0x8(%eax),%edx
  1047a4:	89 d0                	mov    %edx,%eax
  1047a6:	c1 e0 02             	shl    $0x2,%eax
  1047a9:	01 d0                	add    %edx,%eax
  1047ab:	c1 e0 02             	shl    $0x2,%eax
  1047ae:	89 c2                	mov    %eax,%edx
  1047b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047b3:	01 d0                	add    %edx,%eax
  1047b5:	39 45 08             	cmp    %eax,0x8(%ebp)
  1047b8:	75 5e                	jne    104818 <default_free_pages+0x237>
            p->property += base->property;
  1047ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047bd:	8b 50 08             	mov    0x8(%eax),%edx
  1047c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1047c3:	8b 40 08             	mov    0x8(%eax),%eax
  1047c6:	01 c2                	add    %eax,%edx
  1047c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047cb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  1047ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1047d1:	83 c0 04             	add    $0x4,%eax
  1047d4:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  1047db:	89 45 a0             	mov    %eax,-0x60(%ebp)
  1047de:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1047e1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1047e4:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  1047e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047ea:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  1047ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047f0:	83 c0 0c             	add    $0xc,%eax
  1047f3:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  1047f6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1047f9:	8b 40 04             	mov    0x4(%eax),%eax
  1047fc:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1047ff:	8b 12                	mov    (%edx),%edx
  104801:	89 55 ac             	mov    %edx,-0x54(%ebp)
  104804:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  104807:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10480a:	8b 55 a8             	mov    -0x58(%ebp),%edx
  10480d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104810:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104813:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104816:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  104818:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  10481f:	0f 85 eb fe ff ff    	jne    104710 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
  104825:	8b 15 24 bf 11 00    	mov    0x11bf24,%edx
  10482b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10482e:	01 d0                	add    %edx,%eax
  104830:	a3 24 bf 11 00       	mov    %eax,0x11bf24
  104835:	c7 45 9c 1c bf 11 00 	movl   $0x11bf1c,-0x64(%ebp)
    return listelm->next;
  10483c:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10483f:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
  104842:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104845:	eb 74                	jmp    1048bb <default_free_pages+0x2da>
        p = le2page(le, page_link);
  104847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10484a:	83 e8 0c             	sub    $0xc,%eax
  10484d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(base + base->property <= p) {
  104850:	8b 45 08             	mov    0x8(%ebp),%eax
  104853:	8b 50 08             	mov    0x8(%eax),%edx
  104856:	89 d0                	mov    %edx,%eax
  104858:	c1 e0 02             	shl    $0x2,%eax
  10485b:	01 d0                	add    %edx,%eax
  10485d:	c1 e0 02             	shl    $0x2,%eax
  104860:	89 c2                	mov    %eax,%edx
  104862:	8b 45 08             	mov    0x8(%ebp),%eax
  104865:	01 d0                	add    %edx,%eax
  104867:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10486a:	72 40                	jb     1048ac <default_free_pages+0x2cb>
            assert(base + base->property != p);
  10486c:	8b 45 08             	mov    0x8(%ebp),%eax
  10486f:	8b 50 08             	mov    0x8(%eax),%edx
  104872:	89 d0                	mov    %edx,%eax
  104874:	c1 e0 02             	shl    $0x2,%eax
  104877:	01 d0                	add    %edx,%eax
  104879:	c1 e0 02             	shl    $0x2,%eax
  10487c:	89 c2                	mov    %eax,%edx
  10487e:	8b 45 08             	mov    0x8(%ebp),%eax
  104881:	01 d0                	add    %edx,%eax
  104883:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104886:	75 3e                	jne    1048c6 <default_free_pages+0x2e5>
  104888:	c7 44 24 0c 01 6e 10 	movl   $0x106e01,0xc(%esp)
  10488f:	00 
  104890:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104897:	00 
  104898:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  10489f:	00 
  1048a0:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1048a7:	e8 3d bb ff ff       	call   1003e9 <__panic>
  1048ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048af:	89 45 98             	mov    %eax,-0x68(%ebp)
  1048b2:	8b 45 98             	mov    -0x68(%ebp),%eax
  1048b5:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
  1048b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048bb:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  1048c2:	75 83                	jne    104847 <default_free_pages+0x266>
  1048c4:	eb 01                	jmp    1048c7 <default_free_pages+0x2e6>
            break;
  1048c6:	90                   	nop
        }
    }
    list_add_before(le, &(base->page_link));
  1048c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1048ca:	8d 50 0c             	lea    0xc(%eax),%edx
  1048cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048d0:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1048d3:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1048d6:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1048d9:	8b 00                	mov    (%eax),%eax
  1048db:	8b 55 90             	mov    -0x70(%ebp),%edx
  1048de:	89 55 8c             	mov    %edx,-0x74(%ebp)
  1048e1:	89 45 88             	mov    %eax,-0x78(%ebp)
  1048e4:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1048e7:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  1048ea:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1048ed:	8b 55 8c             	mov    -0x74(%ebp),%edx
  1048f0:	89 10                	mov    %edx,(%eax)
  1048f2:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1048f5:	8b 10                	mov    (%eax),%edx
  1048f7:	8b 45 88             	mov    -0x78(%ebp),%eax
  1048fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1048fd:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104900:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104903:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104906:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104909:	8b 55 88             	mov    -0x78(%ebp),%edx
  10490c:	89 10                	mov    %edx,(%eax)
}
  10490e:	90                   	nop
  10490f:	c9                   	leave  
  104910:	c3                   	ret    

00104911 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104911:	55                   	push   %ebp
  104912:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104914:	a1 24 bf 11 00       	mov    0x11bf24,%eax
}
  104919:	5d                   	pop    %ebp
  10491a:	c3                   	ret    

0010491b <basic_check>:

static void
basic_check(void) {
  10491b:	55                   	push   %ebp
  10491c:	89 e5                	mov    %esp,%ebp
  10491e:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10492b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10492e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104931:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104934:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10493b:	e8 a0 e2 ff ff       	call   102be0 <alloc_pages>
  104940:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104943:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104947:	75 24                	jne    10496d <basic_check+0x52>
  104949:	c7 44 24 0c 1c 6e 10 	movl   $0x106e1c,0xc(%esp)
  104950:	00 
  104951:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104958:	00 
  104959:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  104960:	00 
  104961:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104968:	e8 7c ba ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  10496d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104974:	e8 67 e2 ff ff       	call   102be0 <alloc_pages>
  104979:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10497c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104980:	75 24                	jne    1049a6 <basic_check+0x8b>
  104982:	c7 44 24 0c 38 6e 10 	movl   $0x106e38,0xc(%esp)
  104989:	00 
  10498a:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104991:	00 
  104992:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  104999:	00 
  10499a:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1049a1:	e8 43 ba ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1049a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1049ad:	e8 2e e2 ff ff       	call   102be0 <alloc_pages>
  1049b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1049b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1049b9:	75 24                	jne    1049df <basic_check+0xc4>
  1049bb:	c7 44 24 0c 54 6e 10 	movl   $0x106e54,0xc(%esp)
  1049c2:	00 
  1049c3:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1049ca:	00 
  1049cb:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  1049d2:	00 
  1049d3:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1049da:	e8 0a ba ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  1049df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049e2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1049e5:	74 10                	je     1049f7 <basic_check+0xdc>
  1049e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1049ed:	74 08                	je     1049f7 <basic_check+0xdc>
  1049ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1049f5:	75 24                	jne    104a1b <basic_check+0x100>
  1049f7:	c7 44 24 0c 70 6e 10 	movl   $0x106e70,0xc(%esp)
  1049fe:	00 
  1049ff:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104a06:	00 
  104a07:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  104a0e:	00 
  104a0f:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104a16:	e8 ce b9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104a1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a1e:	89 04 24             	mov    %eax,(%esp)
  104a21:	e8 97 f8 ff ff       	call   1042bd <page_ref>
  104a26:	85 c0                	test   %eax,%eax
  104a28:	75 1e                	jne    104a48 <basic_check+0x12d>
  104a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a2d:	89 04 24             	mov    %eax,(%esp)
  104a30:	e8 88 f8 ff ff       	call   1042bd <page_ref>
  104a35:	85 c0                	test   %eax,%eax
  104a37:	75 0f                	jne    104a48 <basic_check+0x12d>
  104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a3c:	89 04 24             	mov    %eax,(%esp)
  104a3f:	e8 79 f8 ff ff       	call   1042bd <page_ref>
  104a44:	85 c0                	test   %eax,%eax
  104a46:	74 24                	je     104a6c <basic_check+0x151>
  104a48:	c7 44 24 0c 94 6e 10 	movl   $0x106e94,0xc(%esp)
  104a4f:	00 
  104a50:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104a57:	00 
  104a58:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  104a5f:	00 
  104a60:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104a67:	e8 7d b9 ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a6f:	89 04 24             	mov    %eax,(%esp)
  104a72:	e8 30 f8 ff ff       	call   1042a7 <page2pa>
  104a77:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104a7d:	c1 e2 0c             	shl    $0xc,%edx
  104a80:	39 d0                	cmp    %edx,%eax
  104a82:	72 24                	jb     104aa8 <basic_check+0x18d>
  104a84:	c7 44 24 0c d0 6e 10 	movl   $0x106ed0,0xc(%esp)
  104a8b:	00 
  104a8c:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104a93:	00 
  104a94:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  104a9b:	00 
  104a9c:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104aa3:	e8 41 b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104aab:	89 04 24             	mov    %eax,(%esp)
  104aae:	e8 f4 f7 ff ff       	call   1042a7 <page2pa>
  104ab3:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104ab9:	c1 e2 0c             	shl    $0xc,%edx
  104abc:	39 d0                	cmp    %edx,%eax
  104abe:	72 24                	jb     104ae4 <basic_check+0x1c9>
  104ac0:	c7 44 24 0c ed 6e 10 	movl   $0x106eed,0xc(%esp)
  104ac7:	00 
  104ac8:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104acf:	00 
  104ad0:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  104ad7:	00 
  104ad8:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104adf:	e8 05 b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ae7:	89 04 24             	mov    %eax,(%esp)
  104aea:	e8 b8 f7 ff ff       	call   1042a7 <page2pa>
  104aef:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104af5:	c1 e2 0c             	shl    $0xc,%edx
  104af8:	39 d0                	cmp    %edx,%eax
  104afa:	72 24                	jb     104b20 <basic_check+0x205>
  104afc:	c7 44 24 0c 0a 6f 10 	movl   $0x106f0a,0xc(%esp)
  104b03:	00 
  104b04:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104b0b:	00 
  104b0c:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104b13:	00 
  104b14:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104b1b:	e8 c9 b8 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104b20:	a1 1c bf 11 00       	mov    0x11bf1c,%eax
  104b25:	8b 15 20 bf 11 00    	mov    0x11bf20,%edx
  104b2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104b2e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104b31:	c7 45 dc 1c bf 11 00 	movl   $0x11bf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104b38:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104b3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104b3e:	89 50 04             	mov    %edx,0x4(%eax)
  104b41:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104b44:	8b 50 04             	mov    0x4(%eax),%edx
  104b47:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104b4a:	89 10                	mov    %edx,(%eax)
  104b4c:	c7 45 e0 1c bf 11 00 	movl   $0x11bf1c,-0x20(%ebp)
    return list->next == list;
  104b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104b56:	8b 40 04             	mov    0x4(%eax),%eax
  104b59:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104b5c:	0f 94 c0             	sete   %al
  104b5f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104b62:	85 c0                	test   %eax,%eax
  104b64:	75 24                	jne    104b8a <basic_check+0x26f>
  104b66:	c7 44 24 0c 27 6f 10 	movl   $0x106f27,0xc(%esp)
  104b6d:	00 
  104b6e:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104b75:	00 
  104b76:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  104b7d:	00 
  104b7e:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104b85:	e8 5f b8 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104b8a:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104b8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104b92:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  104b99:	00 00 00 

    assert(alloc_page() == NULL);
  104b9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ba3:	e8 38 e0 ff ff       	call   102be0 <alloc_pages>
  104ba8:	85 c0                	test   %eax,%eax
  104baa:	74 24                	je     104bd0 <basic_check+0x2b5>
  104bac:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  104bb3:	00 
  104bb4:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104bbb:	00 
  104bbc:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104bc3:	00 
  104bc4:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104bcb:	e8 19 b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104bd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bd7:	00 
  104bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bdb:	89 04 24             	mov    %eax,(%esp)
  104bde:	e8 35 e0 ff ff       	call   102c18 <free_pages>
    free_page(p1);
  104be3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bea:	00 
  104beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bee:	89 04 24             	mov    %eax,(%esp)
  104bf1:	e8 22 e0 ff ff       	call   102c18 <free_pages>
    free_page(p2);
  104bf6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bfd:	00 
  104bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c01:	89 04 24             	mov    %eax,(%esp)
  104c04:	e8 0f e0 ff ff       	call   102c18 <free_pages>
    assert(nr_free == 3);
  104c09:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104c0e:	83 f8 03             	cmp    $0x3,%eax
  104c11:	74 24                	je     104c37 <basic_check+0x31c>
  104c13:	c7 44 24 0c 53 6f 10 	movl   $0x106f53,0xc(%esp)
  104c1a:	00 
  104c1b:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104c22:	00 
  104c23:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104c2a:	00 
  104c2b:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104c32:	e8 b2 b7 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104c37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c3e:	e8 9d df ff ff       	call   102be0 <alloc_pages>
  104c43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104c46:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104c4a:	75 24                	jne    104c70 <basic_check+0x355>
  104c4c:	c7 44 24 0c 1c 6e 10 	movl   $0x106e1c,0xc(%esp)
  104c53:	00 
  104c54:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104c5b:	00 
  104c5c:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  104c63:	00 
  104c64:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104c6b:	e8 79 b7 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104c70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c77:	e8 64 df ff ff       	call   102be0 <alloc_pages>
  104c7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c83:	75 24                	jne    104ca9 <basic_check+0x38e>
  104c85:	c7 44 24 0c 38 6e 10 	movl   $0x106e38,0xc(%esp)
  104c8c:	00 
  104c8d:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104c94:	00 
  104c95:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  104c9c:	00 
  104c9d:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104ca4:	e8 40 b7 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104ca9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cb0:	e8 2b df ff ff       	call   102be0 <alloc_pages>
  104cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104cb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104cbc:	75 24                	jne    104ce2 <basic_check+0x3c7>
  104cbe:	c7 44 24 0c 54 6e 10 	movl   $0x106e54,0xc(%esp)
  104cc5:	00 
  104cc6:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104ccd:	00 
  104cce:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104cd5:	00 
  104cd6:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104cdd:	e8 07 b7 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104ce2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ce9:	e8 f2 de ff ff       	call   102be0 <alloc_pages>
  104cee:	85 c0                	test   %eax,%eax
  104cf0:	74 24                	je     104d16 <basic_check+0x3fb>
  104cf2:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  104cf9:	00 
  104cfa:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104d01:	00 
  104d02:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  104d09:	00 
  104d0a:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104d11:	e8 d3 b6 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104d16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d1d:	00 
  104d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d21:	89 04 24             	mov    %eax,(%esp)
  104d24:	e8 ef de ff ff       	call   102c18 <free_pages>
  104d29:	c7 45 d8 1c bf 11 00 	movl   $0x11bf1c,-0x28(%ebp)
  104d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104d33:	8b 40 04             	mov    0x4(%eax),%eax
  104d36:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104d39:	0f 94 c0             	sete   %al
  104d3c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104d3f:	85 c0                	test   %eax,%eax
  104d41:	74 24                	je     104d67 <basic_check+0x44c>
  104d43:	c7 44 24 0c 60 6f 10 	movl   $0x106f60,0xc(%esp)
  104d4a:	00 
  104d4b:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104d52:	00 
  104d53:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104d5a:	00 
  104d5b:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104d62:	e8 82 b6 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104d67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d6e:	e8 6d de ff ff       	call   102be0 <alloc_pages>
  104d73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104d7c:	74 24                	je     104da2 <basic_check+0x487>
  104d7e:	c7 44 24 0c 78 6f 10 	movl   $0x106f78,0xc(%esp)
  104d85:	00 
  104d86:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104d8d:	00 
  104d8e:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  104d95:	00 
  104d96:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104d9d:	e8 47 b6 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104da2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104da9:	e8 32 de ff ff       	call   102be0 <alloc_pages>
  104dae:	85 c0                	test   %eax,%eax
  104db0:	74 24                	je     104dd6 <basic_check+0x4bb>
  104db2:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  104db9:	00 
  104dba:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104dc1:	00 
  104dc2:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  104dc9:	00 
  104dca:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104dd1:	e8 13 b6 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104dd6:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104ddb:	85 c0                	test   %eax,%eax
  104ddd:	74 24                	je     104e03 <basic_check+0x4e8>
  104ddf:	c7 44 24 0c 91 6f 10 	movl   $0x106f91,0xc(%esp)
  104de6:	00 
  104de7:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104dee:	00 
  104def:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  104df6:	00 
  104df7:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104dfe:	e8 e6 b5 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104e03:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104e06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104e09:	a3 1c bf 11 00       	mov    %eax,0x11bf1c
  104e0e:	89 15 20 bf 11 00    	mov    %edx,0x11bf20
    nr_free = nr_free_store;
  104e14:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e17:	a3 24 bf 11 00       	mov    %eax,0x11bf24

    free_page(p);
  104e1c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e23:	00 
  104e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e27:	89 04 24             	mov    %eax,(%esp)
  104e2a:	e8 e9 dd ff ff       	call   102c18 <free_pages>
    free_page(p1);
  104e2f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e36:	00 
  104e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e3a:	89 04 24             	mov    %eax,(%esp)
  104e3d:	e8 d6 dd ff ff       	call   102c18 <free_pages>
    free_page(p2);
  104e42:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e49:	00 
  104e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e4d:	89 04 24             	mov    %eax,(%esp)
  104e50:	e8 c3 dd ff ff       	call   102c18 <free_pages>
}
  104e55:	90                   	nop
  104e56:	c9                   	leave  
  104e57:	c3                   	ret    

00104e58 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104e58:	55                   	push   %ebp
  104e59:	89 e5                	mov    %esp,%ebp
  104e5b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104e61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e68:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104e6f:	c7 45 ec 1c bf 11 00 	movl   $0x11bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104e76:	eb 6a                	jmp    104ee2 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104e78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e7b:	83 e8 0c             	sub    $0xc,%eax
  104e7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104e81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104e84:	83 c0 04             	add    $0x4,%eax
  104e87:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104e8e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104e91:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104e94:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104e97:	0f a3 10             	bt     %edx,(%eax)
  104e9a:	19 c0                	sbb    %eax,%eax
  104e9c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104e9f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104ea3:	0f 95 c0             	setne  %al
  104ea6:	0f b6 c0             	movzbl %al,%eax
  104ea9:	85 c0                	test   %eax,%eax
  104eab:	75 24                	jne    104ed1 <default_check+0x79>
  104ead:	c7 44 24 0c 9e 6f 10 	movl   $0x106f9e,0xc(%esp)
  104eb4:	00 
  104eb5:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104ebc:	00 
  104ebd:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  104ec4:	00 
  104ec5:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104ecc:	e8 18 b5 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104ed1:	ff 45 f4             	incl   -0xc(%ebp)
  104ed4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104ed7:	8b 50 08             	mov    0x8(%eax),%edx
  104eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104edd:	01 d0                	add    %edx,%eax
  104edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ee5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104ee8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104eeb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104eee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104ef1:	81 7d ec 1c bf 11 00 	cmpl   $0x11bf1c,-0x14(%ebp)
  104ef8:	0f 85 7a ff ff ff    	jne    104e78 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104efe:	e8 48 dd ff ff       	call   102c4b <nr_free_pages>
  104f03:	89 c2                	mov    %eax,%edx
  104f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f08:	39 c2                	cmp    %eax,%edx
  104f0a:	74 24                	je     104f30 <default_check+0xd8>
  104f0c:	c7 44 24 0c ae 6f 10 	movl   $0x106fae,0xc(%esp)
  104f13:	00 
  104f14:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104f1b:	00 
  104f1c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104f23:	00 
  104f24:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104f2b:	e8 b9 b4 ff ff       	call   1003e9 <__panic>

    basic_check();
  104f30:	e8 e6 f9 ff ff       	call   10491b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104f35:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104f3c:	e8 9f dc ff ff       	call   102be0 <alloc_pages>
  104f41:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104f44:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104f48:	75 24                	jne    104f6e <default_check+0x116>
  104f4a:	c7 44 24 0c c7 6f 10 	movl   $0x106fc7,0xc(%esp)
  104f51:	00 
  104f52:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104f59:	00 
  104f5a:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  104f61:	00 
  104f62:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104f69:	e8 7b b4 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104f6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f71:	83 c0 04             	add    $0x4,%eax
  104f74:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104f7b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104f7e:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104f81:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104f84:	0f a3 10             	bt     %edx,(%eax)
  104f87:	19 c0                	sbb    %eax,%eax
  104f89:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104f8c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104f90:	0f 95 c0             	setne  %al
  104f93:	0f b6 c0             	movzbl %al,%eax
  104f96:	85 c0                	test   %eax,%eax
  104f98:	74 24                	je     104fbe <default_check+0x166>
  104f9a:	c7 44 24 0c d2 6f 10 	movl   $0x106fd2,0xc(%esp)
  104fa1:	00 
  104fa2:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  104fa9:	00 
  104faa:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104fb1:	00 
  104fb2:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  104fb9:	e8 2b b4 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104fbe:	a1 1c bf 11 00       	mov    0x11bf1c,%eax
  104fc3:	8b 15 20 bf 11 00    	mov    0x11bf20,%edx
  104fc9:	89 45 80             	mov    %eax,-0x80(%ebp)
  104fcc:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104fcf:	c7 45 b0 1c bf 11 00 	movl   $0x11bf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104fd6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104fd9:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104fdc:	89 50 04             	mov    %edx,0x4(%eax)
  104fdf:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104fe2:	8b 50 04             	mov    0x4(%eax),%edx
  104fe5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104fe8:	89 10                	mov    %edx,(%eax)
  104fea:	c7 45 b4 1c bf 11 00 	movl   $0x11bf1c,-0x4c(%ebp)
    return list->next == list;
  104ff1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104ff4:	8b 40 04             	mov    0x4(%eax),%eax
  104ff7:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104ffa:	0f 94 c0             	sete   %al
  104ffd:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105000:	85 c0                	test   %eax,%eax
  105002:	75 24                	jne    105028 <default_check+0x1d0>
  105004:	c7 44 24 0c 27 6f 10 	movl   $0x106f27,0xc(%esp)
  10500b:	00 
  10500c:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105013:	00 
  105014:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  10501b:	00 
  10501c:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105023:	e8 c1 b3 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105028:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10502f:	e8 ac db ff ff       	call   102be0 <alloc_pages>
  105034:	85 c0                	test   %eax,%eax
  105036:	74 24                	je     10505c <default_check+0x204>
  105038:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  10503f:	00 
  105040:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105047:	00 
  105048:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  10504f:	00 
  105050:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105057:	e8 8d b3 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  10505c:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  105061:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  105064:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  10506b:	00 00 00 

    free_pages(p0 + 2, 3);
  10506e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105071:	83 c0 28             	add    $0x28,%eax
  105074:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10507b:	00 
  10507c:	89 04 24             	mov    %eax,(%esp)
  10507f:	e8 94 db ff ff       	call   102c18 <free_pages>
    assert(alloc_pages(4) == NULL);
  105084:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10508b:	e8 50 db ff ff       	call   102be0 <alloc_pages>
  105090:	85 c0                	test   %eax,%eax
  105092:	74 24                	je     1050b8 <default_check+0x260>
  105094:	c7 44 24 0c e4 6f 10 	movl   $0x106fe4,0xc(%esp)
  10509b:	00 
  10509c:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1050a3:	00 
  1050a4:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  1050ab:	00 
  1050ac:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1050b3:	e8 31 b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1050b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050bb:	83 c0 28             	add    $0x28,%eax
  1050be:	83 c0 04             	add    $0x4,%eax
  1050c1:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1050c8:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1050cb:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1050ce:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1050d1:	0f a3 10             	bt     %edx,(%eax)
  1050d4:	19 c0                	sbb    %eax,%eax
  1050d6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1050d9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1050dd:	0f 95 c0             	setne  %al
  1050e0:	0f b6 c0             	movzbl %al,%eax
  1050e3:	85 c0                	test   %eax,%eax
  1050e5:	74 0e                	je     1050f5 <default_check+0x29d>
  1050e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050ea:	83 c0 28             	add    $0x28,%eax
  1050ed:	8b 40 08             	mov    0x8(%eax),%eax
  1050f0:	83 f8 03             	cmp    $0x3,%eax
  1050f3:	74 24                	je     105119 <default_check+0x2c1>
  1050f5:	c7 44 24 0c fc 6f 10 	movl   $0x106ffc,0xc(%esp)
  1050fc:	00 
  1050fd:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105104:	00 
  105105:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  10510c:	00 
  10510d:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105114:	e8 d0 b2 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105119:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105120:	e8 bb da ff ff       	call   102be0 <alloc_pages>
  105125:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105128:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10512c:	75 24                	jne    105152 <default_check+0x2fa>
  10512e:	c7 44 24 0c 28 70 10 	movl   $0x107028,0xc(%esp)
  105135:	00 
  105136:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  10513d:	00 
  10513e:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  105145:	00 
  105146:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  10514d:	e8 97 b2 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105152:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105159:	e8 82 da ff ff       	call   102be0 <alloc_pages>
  10515e:	85 c0                	test   %eax,%eax
  105160:	74 24                	je     105186 <default_check+0x32e>
  105162:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  105169:	00 
  10516a:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105171:	00 
  105172:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  105179:	00 
  10517a:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105181:	e8 63 b2 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  105186:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105189:	83 c0 28             	add    $0x28,%eax
  10518c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10518f:	74 24                	je     1051b5 <default_check+0x35d>
  105191:	c7 44 24 0c 46 70 10 	movl   $0x107046,0xc(%esp)
  105198:	00 
  105199:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1051a0:	00 
  1051a1:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1051a8:	00 
  1051a9:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1051b0:	e8 34 b2 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  1051b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051b8:	83 c0 14             	add    $0x14,%eax
  1051bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1051be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051c5:	00 
  1051c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051c9:	89 04 24             	mov    %eax,(%esp)
  1051cc:	e8 47 da ff ff       	call   102c18 <free_pages>
    free_pages(p1, 3);
  1051d1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1051d8:	00 
  1051d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051dc:	89 04 24             	mov    %eax,(%esp)
  1051df:	e8 34 da ff ff       	call   102c18 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1051e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051e7:	83 c0 04             	add    $0x4,%eax
  1051ea:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1051f1:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1051f4:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1051f7:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1051fa:	0f a3 10             	bt     %edx,(%eax)
  1051fd:	19 c0                	sbb    %eax,%eax
  1051ff:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105202:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105206:	0f 95 c0             	setne  %al
  105209:	0f b6 c0             	movzbl %al,%eax
  10520c:	85 c0                	test   %eax,%eax
  10520e:	74 0b                	je     10521b <default_check+0x3c3>
  105210:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105213:	8b 40 08             	mov    0x8(%eax),%eax
  105216:	83 f8 01             	cmp    $0x1,%eax
  105219:	74 24                	je     10523f <default_check+0x3e7>
  10521b:	c7 44 24 0c 54 70 10 	movl   $0x107054,0xc(%esp)
  105222:	00 
  105223:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  10522a:	00 
  10522b:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  105232:	00 
  105233:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  10523a:	e8 aa b1 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10523f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105242:	83 c0 04             	add    $0x4,%eax
  105245:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10524c:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10524f:	8b 45 90             	mov    -0x70(%ebp),%eax
  105252:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105255:	0f a3 10             	bt     %edx,(%eax)
  105258:	19 c0                	sbb    %eax,%eax
  10525a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  10525d:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105261:	0f 95 c0             	setne  %al
  105264:	0f b6 c0             	movzbl %al,%eax
  105267:	85 c0                	test   %eax,%eax
  105269:	74 0b                	je     105276 <default_check+0x41e>
  10526b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10526e:	8b 40 08             	mov    0x8(%eax),%eax
  105271:	83 f8 03             	cmp    $0x3,%eax
  105274:	74 24                	je     10529a <default_check+0x442>
  105276:	c7 44 24 0c 7c 70 10 	movl   $0x10707c,0xc(%esp)
  10527d:	00 
  10527e:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105285:	00 
  105286:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  10528d:	00 
  10528e:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105295:	e8 4f b1 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10529a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1052a1:	e8 3a d9 ff ff       	call   102be0 <alloc_pages>
  1052a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1052a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052ac:	83 e8 14             	sub    $0x14,%eax
  1052af:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1052b2:	74 24                	je     1052d8 <default_check+0x480>
  1052b4:	c7 44 24 0c a2 70 10 	movl   $0x1070a2,0xc(%esp)
  1052bb:	00 
  1052bc:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1052c3:	00 
  1052c4:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1052cb:	00 
  1052cc:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1052d3:	e8 11 b1 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  1052d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052df:	00 
  1052e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052e3:	89 04 24             	mov    %eax,(%esp)
  1052e6:	e8 2d d9 ff ff       	call   102c18 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1052eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1052f2:	e8 e9 d8 ff ff       	call   102be0 <alloc_pages>
  1052f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1052fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052fd:	83 c0 14             	add    $0x14,%eax
  105300:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105303:	74 24                	je     105329 <default_check+0x4d1>
  105305:	c7 44 24 0c c0 70 10 	movl   $0x1070c0,0xc(%esp)
  10530c:	00 
  10530d:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105314:	00 
  105315:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  10531c:	00 
  10531d:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105324:	e8 c0 b0 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  105329:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105330:	00 
  105331:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105334:	89 04 24             	mov    %eax,(%esp)
  105337:	e8 dc d8 ff ff       	call   102c18 <free_pages>
    free_page(p2);
  10533c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105343:	00 
  105344:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105347:	89 04 24             	mov    %eax,(%esp)
  10534a:	e8 c9 d8 ff ff       	call   102c18 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10534f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105356:	e8 85 d8 ff ff       	call   102be0 <alloc_pages>
  10535b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10535e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105362:	75 24                	jne    105388 <default_check+0x530>
  105364:	c7 44 24 0c e0 70 10 	movl   $0x1070e0,0xc(%esp)
  10536b:	00 
  10536c:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105373:	00 
  105374:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  10537b:	00 
  10537c:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105383:	e8 61 b0 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105388:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10538f:	e8 4c d8 ff ff       	call   102be0 <alloc_pages>
  105394:	85 c0                	test   %eax,%eax
  105396:	74 24                	je     1053bc <default_check+0x564>
  105398:	c7 44 24 0c 3e 6f 10 	movl   $0x106f3e,0xc(%esp)
  10539f:	00 
  1053a0:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1053a7:	00 
  1053a8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  1053af:	00 
  1053b0:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1053b7:	e8 2d b0 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  1053bc:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  1053c1:	85 c0                	test   %eax,%eax
  1053c3:	74 24                	je     1053e9 <default_check+0x591>
  1053c5:	c7 44 24 0c 91 6f 10 	movl   $0x106f91,0xc(%esp)
  1053cc:	00 
  1053cd:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1053d4:	00 
  1053d5:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  1053dc:	00 
  1053dd:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1053e4:	e8 00 b0 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  1053e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1053ec:	a3 24 bf 11 00       	mov    %eax,0x11bf24

    free_list = free_list_store;
  1053f1:	8b 45 80             	mov    -0x80(%ebp),%eax
  1053f4:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1053f7:	a3 1c bf 11 00       	mov    %eax,0x11bf1c
  1053fc:	89 15 20 bf 11 00    	mov    %edx,0x11bf20
    free_pages(p0, 5);
  105402:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105409:	00 
  10540a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10540d:	89 04 24             	mov    %eax,(%esp)
  105410:	e8 03 d8 ff ff       	call   102c18 <free_pages>

    le = &free_list;
  105415:	c7 45 ec 1c bf 11 00 	movl   $0x11bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10541c:	eb 5a                	jmp    105478 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  10541e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105421:	8b 40 04             	mov    0x4(%eax),%eax
  105424:	8b 00                	mov    (%eax),%eax
  105426:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105429:	75 0d                	jne    105438 <default_check+0x5e0>
  10542b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10542e:	8b 00                	mov    (%eax),%eax
  105430:	8b 40 04             	mov    0x4(%eax),%eax
  105433:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105436:	74 24                	je     10545c <default_check+0x604>
  105438:	c7 44 24 0c 00 71 10 	movl   $0x107100,0xc(%esp)
  10543f:	00 
  105440:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  105447:	00 
  105448:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  10544f:	00 
  105450:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  105457:	e8 8d af ff ff       	call   1003e9 <__panic>
        struct Page *p = le2page(le, page_link);
  10545c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10545f:	83 e8 0c             	sub    $0xc,%eax
  105462:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  105465:	ff 4d f4             	decl   -0xc(%ebp)
  105468:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10546b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10546e:	8b 40 08             	mov    0x8(%eax),%eax
  105471:	29 c2                	sub    %eax,%edx
  105473:	89 d0                	mov    %edx,%eax
  105475:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105478:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10547b:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  10547e:	8b 45 88             	mov    -0x78(%ebp),%eax
  105481:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105484:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105487:	81 7d ec 1c bf 11 00 	cmpl   $0x11bf1c,-0x14(%ebp)
  10548e:	75 8e                	jne    10541e <default_check+0x5c6>
    }
    assert(count == 0);
  105490:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105494:	74 24                	je     1054ba <default_check+0x662>
  105496:	c7 44 24 0c 2d 71 10 	movl   $0x10712d,0xc(%esp)
  10549d:	00 
  10549e:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1054a5:	00 
  1054a6:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  1054ad:	00 
  1054ae:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1054b5:	e8 2f af ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  1054ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1054be:	74 24                	je     1054e4 <default_check+0x68c>
  1054c0:	c7 44 24 0c 38 71 10 	movl   $0x107138,0xc(%esp)
  1054c7:	00 
  1054c8:	c7 44 24 08 9e 6d 10 	movl   $0x106d9e,0x8(%esp)
  1054cf:	00 
  1054d0:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  1054d7:	00 
  1054d8:	c7 04 24 b3 6d 10 00 	movl   $0x106db3,(%esp)
  1054df:	e8 05 af ff ff       	call   1003e9 <__panic>
}
  1054e4:	90                   	nop
  1054e5:	c9                   	leave  
  1054e6:	c3                   	ret    

001054e7 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1054e7:	55                   	push   %ebp
  1054e8:	89 e5                	mov    %esp,%ebp
  1054ea:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1054ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1054f4:	eb 03                	jmp    1054f9 <strlen+0x12>
        cnt ++;
  1054f6:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1054f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054fc:	8d 50 01             	lea    0x1(%eax),%edx
  1054ff:	89 55 08             	mov    %edx,0x8(%ebp)
  105502:	0f b6 00             	movzbl (%eax),%eax
  105505:	84 c0                	test   %al,%al
  105507:	75 ed                	jne    1054f6 <strlen+0xf>
    }
    return cnt;
  105509:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10550c:	c9                   	leave  
  10550d:	c3                   	ret    

0010550e <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10550e:	55                   	push   %ebp
  10550f:	89 e5                	mov    %esp,%ebp
  105511:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105514:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10551b:	eb 03                	jmp    105520 <strnlen+0x12>
        cnt ++;
  10551d:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105520:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105523:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105526:	73 10                	jae    105538 <strnlen+0x2a>
  105528:	8b 45 08             	mov    0x8(%ebp),%eax
  10552b:	8d 50 01             	lea    0x1(%eax),%edx
  10552e:	89 55 08             	mov    %edx,0x8(%ebp)
  105531:	0f b6 00             	movzbl (%eax),%eax
  105534:	84 c0                	test   %al,%al
  105536:	75 e5                	jne    10551d <strnlen+0xf>
    }
    return cnt;
  105538:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10553b:	c9                   	leave  
  10553c:	c3                   	ret    

0010553d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10553d:	55                   	push   %ebp
  10553e:	89 e5                	mov    %esp,%ebp
  105540:	57                   	push   %edi
  105541:	56                   	push   %esi
  105542:	83 ec 20             	sub    $0x20,%esp
  105545:	8b 45 08             	mov    0x8(%ebp),%eax
  105548:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10554b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10554e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105551:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105554:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105557:	89 d1                	mov    %edx,%ecx
  105559:	89 c2                	mov    %eax,%edx
  10555b:	89 ce                	mov    %ecx,%esi
  10555d:	89 d7                	mov    %edx,%edi
  10555f:	ac                   	lods   %ds:(%esi),%al
  105560:	aa                   	stos   %al,%es:(%edi)
  105561:	84 c0                	test   %al,%al
  105563:	75 fa                	jne    10555f <strcpy+0x22>
  105565:	89 fa                	mov    %edi,%edx
  105567:	89 f1                	mov    %esi,%ecx
  105569:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10556c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10556f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105572:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  105575:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105576:	83 c4 20             	add    $0x20,%esp
  105579:	5e                   	pop    %esi
  10557a:	5f                   	pop    %edi
  10557b:	5d                   	pop    %ebp
  10557c:	c3                   	ret    

0010557d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10557d:	55                   	push   %ebp
  10557e:	89 e5                	mov    %esp,%ebp
  105580:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105583:	8b 45 08             	mov    0x8(%ebp),%eax
  105586:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105589:	eb 1e                	jmp    1055a9 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  10558b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10558e:	0f b6 10             	movzbl (%eax),%edx
  105591:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105594:	88 10                	mov    %dl,(%eax)
  105596:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105599:	0f b6 00             	movzbl (%eax),%eax
  10559c:	84 c0                	test   %al,%al
  10559e:	74 03                	je     1055a3 <strncpy+0x26>
            src ++;
  1055a0:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  1055a3:	ff 45 fc             	incl   -0x4(%ebp)
  1055a6:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  1055a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055ad:	75 dc                	jne    10558b <strncpy+0xe>
    }
    return dst;
  1055af:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1055b2:	c9                   	leave  
  1055b3:	c3                   	ret    

001055b4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1055b4:	55                   	push   %ebp
  1055b5:	89 e5                	mov    %esp,%ebp
  1055b7:	57                   	push   %edi
  1055b8:	56                   	push   %esi
  1055b9:	83 ec 20             	sub    $0x20,%esp
  1055bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1055bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1055c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1055c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1055cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1055ce:	89 d1                	mov    %edx,%ecx
  1055d0:	89 c2                	mov    %eax,%edx
  1055d2:	89 ce                	mov    %ecx,%esi
  1055d4:	89 d7                	mov    %edx,%edi
  1055d6:	ac                   	lods   %ds:(%esi),%al
  1055d7:	ae                   	scas   %es:(%edi),%al
  1055d8:	75 08                	jne    1055e2 <strcmp+0x2e>
  1055da:	84 c0                	test   %al,%al
  1055dc:	75 f8                	jne    1055d6 <strcmp+0x22>
  1055de:	31 c0                	xor    %eax,%eax
  1055e0:	eb 04                	jmp    1055e6 <strcmp+0x32>
  1055e2:	19 c0                	sbb    %eax,%eax
  1055e4:	0c 01                	or     $0x1,%al
  1055e6:	89 fa                	mov    %edi,%edx
  1055e8:	89 f1                	mov    %esi,%ecx
  1055ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1055ed:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1055f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1055f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1055f6:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1055f7:	83 c4 20             	add    $0x20,%esp
  1055fa:	5e                   	pop    %esi
  1055fb:	5f                   	pop    %edi
  1055fc:	5d                   	pop    %ebp
  1055fd:	c3                   	ret    

001055fe <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1055fe:	55                   	push   %ebp
  1055ff:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105601:	eb 09                	jmp    10560c <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105603:	ff 4d 10             	decl   0x10(%ebp)
  105606:	ff 45 08             	incl   0x8(%ebp)
  105609:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10560c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105610:	74 1a                	je     10562c <strncmp+0x2e>
  105612:	8b 45 08             	mov    0x8(%ebp),%eax
  105615:	0f b6 00             	movzbl (%eax),%eax
  105618:	84 c0                	test   %al,%al
  10561a:	74 10                	je     10562c <strncmp+0x2e>
  10561c:	8b 45 08             	mov    0x8(%ebp),%eax
  10561f:	0f b6 10             	movzbl (%eax),%edx
  105622:	8b 45 0c             	mov    0xc(%ebp),%eax
  105625:	0f b6 00             	movzbl (%eax),%eax
  105628:	38 c2                	cmp    %al,%dl
  10562a:	74 d7                	je     105603 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10562c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105630:	74 18                	je     10564a <strncmp+0x4c>
  105632:	8b 45 08             	mov    0x8(%ebp),%eax
  105635:	0f b6 00             	movzbl (%eax),%eax
  105638:	0f b6 d0             	movzbl %al,%edx
  10563b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10563e:	0f b6 00             	movzbl (%eax),%eax
  105641:	0f b6 c0             	movzbl %al,%eax
  105644:	29 c2                	sub    %eax,%edx
  105646:	89 d0                	mov    %edx,%eax
  105648:	eb 05                	jmp    10564f <strncmp+0x51>
  10564a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10564f:	5d                   	pop    %ebp
  105650:	c3                   	ret    

00105651 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105651:	55                   	push   %ebp
  105652:	89 e5                	mov    %esp,%ebp
  105654:	83 ec 04             	sub    $0x4,%esp
  105657:	8b 45 0c             	mov    0xc(%ebp),%eax
  10565a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10565d:	eb 13                	jmp    105672 <strchr+0x21>
        if (*s == c) {
  10565f:	8b 45 08             	mov    0x8(%ebp),%eax
  105662:	0f b6 00             	movzbl (%eax),%eax
  105665:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105668:	75 05                	jne    10566f <strchr+0x1e>
            return (char *)s;
  10566a:	8b 45 08             	mov    0x8(%ebp),%eax
  10566d:	eb 12                	jmp    105681 <strchr+0x30>
        }
        s ++;
  10566f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105672:	8b 45 08             	mov    0x8(%ebp),%eax
  105675:	0f b6 00             	movzbl (%eax),%eax
  105678:	84 c0                	test   %al,%al
  10567a:	75 e3                	jne    10565f <strchr+0xe>
    }
    return NULL;
  10567c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105681:	c9                   	leave  
  105682:	c3                   	ret    

00105683 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105683:	55                   	push   %ebp
  105684:	89 e5                	mov    %esp,%ebp
  105686:	83 ec 04             	sub    $0x4,%esp
  105689:	8b 45 0c             	mov    0xc(%ebp),%eax
  10568c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10568f:	eb 0e                	jmp    10569f <strfind+0x1c>
        if (*s == c) {
  105691:	8b 45 08             	mov    0x8(%ebp),%eax
  105694:	0f b6 00             	movzbl (%eax),%eax
  105697:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10569a:	74 0f                	je     1056ab <strfind+0x28>
            break;
        }
        s ++;
  10569c:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  10569f:	8b 45 08             	mov    0x8(%ebp),%eax
  1056a2:	0f b6 00             	movzbl (%eax),%eax
  1056a5:	84 c0                	test   %al,%al
  1056a7:	75 e8                	jne    105691 <strfind+0xe>
  1056a9:	eb 01                	jmp    1056ac <strfind+0x29>
            break;
  1056ab:	90                   	nop
    }
    return (char *)s;
  1056ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1056af:	c9                   	leave  
  1056b0:	c3                   	ret    

001056b1 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1056b1:	55                   	push   %ebp
  1056b2:	89 e5                	mov    %esp,%ebp
  1056b4:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1056b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1056be:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1056c5:	eb 03                	jmp    1056ca <strtol+0x19>
        s ++;
  1056c7:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1056ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1056cd:	0f b6 00             	movzbl (%eax),%eax
  1056d0:	3c 20                	cmp    $0x20,%al
  1056d2:	74 f3                	je     1056c7 <strtol+0x16>
  1056d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1056d7:	0f b6 00             	movzbl (%eax),%eax
  1056da:	3c 09                	cmp    $0x9,%al
  1056dc:	74 e9                	je     1056c7 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1056de:	8b 45 08             	mov    0x8(%ebp),%eax
  1056e1:	0f b6 00             	movzbl (%eax),%eax
  1056e4:	3c 2b                	cmp    $0x2b,%al
  1056e6:	75 05                	jne    1056ed <strtol+0x3c>
        s ++;
  1056e8:	ff 45 08             	incl   0x8(%ebp)
  1056eb:	eb 14                	jmp    105701 <strtol+0x50>
    }
    else if (*s == '-') {
  1056ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1056f0:	0f b6 00             	movzbl (%eax),%eax
  1056f3:	3c 2d                	cmp    $0x2d,%al
  1056f5:	75 0a                	jne    105701 <strtol+0x50>
        s ++, neg = 1;
  1056f7:	ff 45 08             	incl   0x8(%ebp)
  1056fa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105701:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105705:	74 06                	je     10570d <strtol+0x5c>
  105707:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10570b:	75 22                	jne    10572f <strtol+0x7e>
  10570d:	8b 45 08             	mov    0x8(%ebp),%eax
  105710:	0f b6 00             	movzbl (%eax),%eax
  105713:	3c 30                	cmp    $0x30,%al
  105715:	75 18                	jne    10572f <strtol+0x7e>
  105717:	8b 45 08             	mov    0x8(%ebp),%eax
  10571a:	40                   	inc    %eax
  10571b:	0f b6 00             	movzbl (%eax),%eax
  10571e:	3c 78                	cmp    $0x78,%al
  105720:	75 0d                	jne    10572f <strtol+0x7e>
        s += 2, base = 16;
  105722:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105726:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  10572d:	eb 29                	jmp    105758 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  10572f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105733:	75 16                	jne    10574b <strtol+0x9a>
  105735:	8b 45 08             	mov    0x8(%ebp),%eax
  105738:	0f b6 00             	movzbl (%eax),%eax
  10573b:	3c 30                	cmp    $0x30,%al
  10573d:	75 0c                	jne    10574b <strtol+0x9a>
        s ++, base = 8;
  10573f:	ff 45 08             	incl   0x8(%ebp)
  105742:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105749:	eb 0d                	jmp    105758 <strtol+0xa7>
    }
    else if (base == 0) {
  10574b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10574f:	75 07                	jne    105758 <strtol+0xa7>
        base = 10;
  105751:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105758:	8b 45 08             	mov    0x8(%ebp),%eax
  10575b:	0f b6 00             	movzbl (%eax),%eax
  10575e:	3c 2f                	cmp    $0x2f,%al
  105760:	7e 1b                	jle    10577d <strtol+0xcc>
  105762:	8b 45 08             	mov    0x8(%ebp),%eax
  105765:	0f b6 00             	movzbl (%eax),%eax
  105768:	3c 39                	cmp    $0x39,%al
  10576a:	7f 11                	jg     10577d <strtol+0xcc>
            dig = *s - '0';
  10576c:	8b 45 08             	mov    0x8(%ebp),%eax
  10576f:	0f b6 00             	movzbl (%eax),%eax
  105772:	0f be c0             	movsbl %al,%eax
  105775:	83 e8 30             	sub    $0x30,%eax
  105778:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10577b:	eb 48                	jmp    1057c5 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10577d:	8b 45 08             	mov    0x8(%ebp),%eax
  105780:	0f b6 00             	movzbl (%eax),%eax
  105783:	3c 60                	cmp    $0x60,%al
  105785:	7e 1b                	jle    1057a2 <strtol+0xf1>
  105787:	8b 45 08             	mov    0x8(%ebp),%eax
  10578a:	0f b6 00             	movzbl (%eax),%eax
  10578d:	3c 7a                	cmp    $0x7a,%al
  10578f:	7f 11                	jg     1057a2 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105791:	8b 45 08             	mov    0x8(%ebp),%eax
  105794:	0f b6 00             	movzbl (%eax),%eax
  105797:	0f be c0             	movsbl %al,%eax
  10579a:	83 e8 57             	sub    $0x57,%eax
  10579d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1057a0:	eb 23                	jmp    1057c5 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1057a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a5:	0f b6 00             	movzbl (%eax),%eax
  1057a8:	3c 40                	cmp    $0x40,%al
  1057aa:	7e 3b                	jle    1057e7 <strtol+0x136>
  1057ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1057af:	0f b6 00             	movzbl (%eax),%eax
  1057b2:	3c 5a                	cmp    $0x5a,%al
  1057b4:	7f 31                	jg     1057e7 <strtol+0x136>
            dig = *s - 'A' + 10;
  1057b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1057b9:	0f b6 00             	movzbl (%eax),%eax
  1057bc:	0f be c0             	movsbl %al,%eax
  1057bf:	83 e8 37             	sub    $0x37,%eax
  1057c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1057c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057c8:	3b 45 10             	cmp    0x10(%ebp),%eax
  1057cb:	7d 19                	jge    1057e6 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  1057cd:	ff 45 08             	incl   0x8(%ebp)
  1057d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057d3:	0f af 45 10          	imul   0x10(%ebp),%eax
  1057d7:	89 c2                	mov    %eax,%edx
  1057d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057dc:	01 d0                	add    %edx,%eax
  1057de:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1057e1:	e9 72 ff ff ff       	jmp    105758 <strtol+0xa7>
            break;
  1057e6:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1057e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1057eb:	74 08                	je     1057f5 <strtol+0x144>
        *endptr = (char *) s;
  1057ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057f0:	8b 55 08             	mov    0x8(%ebp),%edx
  1057f3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1057f5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1057f9:	74 07                	je     105802 <strtol+0x151>
  1057fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057fe:	f7 d8                	neg    %eax
  105800:	eb 03                	jmp    105805 <strtol+0x154>
  105802:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105805:	c9                   	leave  
  105806:	c3                   	ret    

00105807 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105807:	55                   	push   %ebp
  105808:	89 e5                	mov    %esp,%ebp
  10580a:	57                   	push   %edi
  10580b:	83 ec 24             	sub    $0x24,%esp
  10580e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105811:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105814:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105818:	8b 55 08             	mov    0x8(%ebp),%edx
  10581b:	89 55 f8             	mov    %edx,-0x8(%ebp)
  10581e:	88 45 f7             	mov    %al,-0x9(%ebp)
  105821:	8b 45 10             	mov    0x10(%ebp),%eax
  105824:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105827:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10582a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10582e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105831:	89 d7                	mov    %edx,%edi
  105833:	f3 aa                	rep stos %al,%es:(%edi)
  105835:	89 fa                	mov    %edi,%edx
  105837:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10583a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  10583d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105840:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105841:	83 c4 24             	add    $0x24,%esp
  105844:	5f                   	pop    %edi
  105845:	5d                   	pop    %ebp
  105846:	c3                   	ret    

00105847 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105847:	55                   	push   %ebp
  105848:	89 e5                	mov    %esp,%ebp
  10584a:	57                   	push   %edi
  10584b:	56                   	push   %esi
  10584c:	53                   	push   %ebx
  10584d:	83 ec 30             	sub    $0x30,%esp
  105850:	8b 45 08             	mov    0x8(%ebp),%eax
  105853:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105856:	8b 45 0c             	mov    0xc(%ebp),%eax
  105859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10585c:	8b 45 10             	mov    0x10(%ebp),%eax
  10585f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105865:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105868:	73 42                	jae    1058ac <memmove+0x65>
  10586a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10586d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105870:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105873:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105876:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105879:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10587c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10587f:	c1 e8 02             	shr    $0x2,%eax
  105882:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105884:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105887:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10588a:	89 d7                	mov    %edx,%edi
  10588c:	89 c6                	mov    %eax,%esi
  10588e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105890:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105893:	83 e1 03             	and    $0x3,%ecx
  105896:	74 02                	je     10589a <memmove+0x53>
  105898:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10589a:	89 f0                	mov    %esi,%eax
  10589c:	89 fa                	mov    %edi,%edx
  10589e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1058a1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1058a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  1058a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  1058aa:	eb 36                	jmp    1058e2 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1058ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058af:	8d 50 ff             	lea    -0x1(%eax),%edx
  1058b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058b5:	01 c2                	add    %eax,%edx
  1058b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058ba:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058c0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1058c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058c6:	89 c1                	mov    %eax,%ecx
  1058c8:	89 d8                	mov    %ebx,%eax
  1058ca:	89 d6                	mov    %edx,%esi
  1058cc:	89 c7                	mov    %eax,%edi
  1058ce:	fd                   	std    
  1058cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1058d1:	fc                   	cld    
  1058d2:	89 f8                	mov    %edi,%eax
  1058d4:	89 f2                	mov    %esi,%edx
  1058d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1058d9:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1058dc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1058df:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1058e2:	83 c4 30             	add    $0x30,%esp
  1058e5:	5b                   	pop    %ebx
  1058e6:	5e                   	pop    %esi
  1058e7:	5f                   	pop    %edi
  1058e8:	5d                   	pop    %ebp
  1058e9:	c3                   	ret    

001058ea <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1058ea:	55                   	push   %ebp
  1058eb:	89 e5                	mov    %esp,%ebp
  1058ed:	57                   	push   %edi
  1058ee:	56                   	push   %esi
  1058ef:	83 ec 20             	sub    $0x20,%esp
  1058f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1058f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1058f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058fe:	8b 45 10             	mov    0x10(%ebp),%eax
  105901:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105904:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105907:	c1 e8 02             	shr    $0x2,%eax
  10590a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10590c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10590f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105912:	89 d7                	mov    %edx,%edi
  105914:	89 c6                	mov    %eax,%esi
  105916:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105918:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10591b:	83 e1 03             	and    $0x3,%ecx
  10591e:	74 02                	je     105922 <memcpy+0x38>
  105920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105922:	89 f0                	mov    %esi,%eax
  105924:	89 fa                	mov    %edi,%edx
  105926:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105929:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10592c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  10592f:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105932:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105933:	83 c4 20             	add    $0x20,%esp
  105936:	5e                   	pop    %esi
  105937:	5f                   	pop    %edi
  105938:	5d                   	pop    %ebp
  105939:	c3                   	ret    

0010593a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10593a:	55                   	push   %ebp
  10593b:	89 e5                	mov    %esp,%ebp
  10593d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105940:	8b 45 08             	mov    0x8(%ebp),%eax
  105943:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105946:	8b 45 0c             	mov    0xc(%ebp),%eax
  105949:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10594c:	eb 2e                	jmp    10597c <memcmp+0x42>
        if (*s1 != *s2) {
  10594e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105951:	0f b6 10             	movzbl (%eax),%edx
  105954:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105957:	0f b6 00             	movzbl (%eax),%eax
  10595a:	38 c2                	cmp    %al,%dl
  10595c:	74 18                	je     105976 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  10595e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105961:	0f b6 00             	movzbl (%eax),%eax
  105964:	0f b6 d0             	movzbl %al,%edx
  105967:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10596a:	0f b6 00             	movzbl (%eax),%eax
  10596d:	0f b6 c0             	movzbl %al,%eax
  105970:	29 c2                	sub    %eax,%edx
  105972:	89 d0                	mov    %edx,%eax
  105974:	eb 18                	jmp    10598e <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105976:	ff 45 fc             	incl   -0x4(%ebp)
  105979:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  10597c:	8b 45 10             	mov    0x10(%ebp),%eax
  10597f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105982:	89 55 10             	mov    %edx,0x10(%ebp)
  105985:	85 c0                	test   %eax,%eax
  105987:	75 c5                	jne    10594e <memcmp+0x14>
    }
    return 0;
  105989:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10598e:	c9                   	leave  
  10598f:	c3                   	ret    

00105990 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105990:	55                   	push   %ebp
  105991:	89 e5                	mov    %esp,%ebp
  105993:	83 ec 58             	sub    $0x58,%esp
  105996:	8b 45 10             	mov    0x10(%ebp),%eax
  105999:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10599c:	8b 45 14             	mov    0x14(%ebp),%eax
  10599f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1059a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1059a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1059a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1059ab:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1059ae:	8b 45 18             	mov    0x18(%ebp),%eax
  1059b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1059b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1059ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1059bd:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1059c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1059ca:	74 1c                	je     1059e8 <printnum+0x58>
  1059cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059cf:	ba 00 00 00 00       	mov    $0x0,%edx
  1059d4:	f7 75 e4             	divl   -0x1c(%ebp)
  1059d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1059da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059dd:	ba 00 00 00 00       	mov    $0x0,%edx
  1059e2:	f7 75 e4             	divl   -0x1c(%ebp)
  1059e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059ee:	f7 75 e4             	divl   -0x1c(%ebp)
  1059f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1059f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1059f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1059fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a00:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105a03:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105a06:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105a09:	8b 45 18             	mov    0x18(%ebp),%eax
  105a0c:	ba 00 00 00 00       	mov    $0x0,%edx
  105a11:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105a14:	72 56                	jb     105a6c <printnum+0xdc>
  105a16:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105a19:	77 05                	ja     105a20 <printnum+0x90>
  105a1b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105a1e:	72 4c                	jb     105a6c <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105a20:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105a23:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a26:	8b 45 20             	mov    0x20(%ebp),%eax
  105a29:	89 44 24 18          	mov    %eax,0x18(%esp)
  105a2d:	89 54 24 14          	mov    %edx,0x14(%esp)
  105a31:	8b 45 18             	mov    0x18(%ebp),%eax
  105a34:	89 44 24 10          	mov    %eax,0x10(%esp)
  105a38:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a42:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  105a50:	89 04 24             	mov    %eax,(%esp)
  105a53:	e8 38 ff ff ff       	call   105990 <printnum>
  105a58:	eb 1b                	jmp    105a75 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a61:	8b 45 20             	mov    0x20(%ebp),%eax
  105a64:	89 04 24             	mov    %eax,(%esp)
  105a67:	8b 45 08             	mov    0x8(%ebp),%eax
  105a6a:	ff d0                	call   *%eax
        while (-- width > 0)
  105a6c:	ff 4d 1c             	decl   0x1c(%ebp)
  105a6f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105a73:	7f e5                	jg     105a5a <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105a75:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105a78:	05 f4 71 10 00       	add    $0x1071f4,%eax
  105a7d:	0f b6 00             	movzbl (%eax),%eax
  105a80:	0f be c0             	movsbl %al,%eax
  105a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a86:	89 54 24 04          	mov    %edx,0x4(%esp)
  105a8a:	89 04 24             	mov    %eax,(%esp)
  105a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  105a90:	ff d0                	call   *%eax
}
  105a92:	90                   	nop
  105a93:	c9                   	leave  
  105a94:	c3                   	ret    

00105a95 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105a95:	55                   	push   %ebp
  105a96:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105a98:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105a9c:	7e 14                	jle    105ab2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa1:	8b 00                	mov    (%eax),%eax
  105aa3:	8d 48 08             	lea    0x8(%eax),%ecx
  105aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  105aa9:	89 0a                	mov    %ecx,(%edx)
  105aab:	8b 50 04             	mov    0x4(%eax),%edx
  105aae:	8b 00                	mov    (%eax),%eax
  105ab0:	eb 30                	jmp    105ae2 <getuint+0x4d>
    }
    else if (lflag) {
  105ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105ab6:	74 16                	je     105ace <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  105abb:	8b 00                	mov    (%eax),%eax
  105abd:	8d 48 04             	lea    0x4(%eax),%ecx
  105ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  105ac3:	89 0a                	mov    %ecx,(%edx)
  105ac5:	8b 00                	mov    (%eax),%eax
  105ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  105acc:	eb 14                	jmp    105ae2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105ace:	8b 45 08             	mov    0x8(%ebp),%eax
  105ad1:	8b 00                	mov    (%eax),%eax
  105ad3:	8d 48 04             	lea    0x4(%eax),%ecx
  105ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  105ad9:	89 0a                	mov    %ecx,(%edx)
  105adb:	8b 00                	mov    (%eax),%eax
  105add:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105ae2:	5d                   	pop    %ebp
  105ae3:	c3                   	ret    

00105ae4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105ae4:	55                   	push   %ebp
  105ae5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105ae7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105aeb:	7e 14                	jle    105b01 <getint+0x1d>
        return va_arg(*ap, long long);
  105aed:	8b 45 08             	mov    0x8(%ebp),%eax
  105af0:	8b 00                	mov    (%eax),%eax
  105af2:	8d 48 08             	lea    0x8(%eax),%ecx
  105af5:	8b 55 08             	mov    0x8(%ebp),%edx
  105af8:	89 0a                	mov    %ecx,(%edx)
  105afa:	8b 50 04             	mov    0x4(%eax),%edx
  105afd:	8b 00                	mov    (%eax),%eax
  105aff:	eb 28                	jmp    105b29 <getint+0x45>
    }
    else if (lflag) {
  105b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105b05:	74 12                	je     105b19 <getint+0x35>
        return va_arg(*ap, long);
  105b07:	8b 45 08             	mov    0x8(%ebp),%eax
  105b0a:	8b 00                	mov    (%eax),%eax
  105b0c:	8d 48 04             	lea    0x4(%eax),%ecx
  105b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  105b12:	89 0a                	mov    %ecx,(%edx)
  105b14:	8b 00                	mov    (%eax),%eax
  105b16:	99                   	cltd   
  105b17:	eb 10                	jmp    105b29 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105b19:	8b 45 08             	mov    0x8(%ebp),%eax
  105b1c:	8b 00                	mov    (%eax),%eax
  105b1e:	8d 48 04             	lea    0x4(%eax),%ecx
  105b21:	8b 55 08             	mov    0x8(%ebp),%edx
  105b24:	89 0a                	mov    %ecx,(%edx)
  105b26:	8b 00                	mov    (%eax),%eax
  105b28:	99                   	cltd   
    }
}
  105b29:	5d                   	pop    %ebp
  105b2a:	c3                   	ret    

00105b2b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105b2b:	55                   	push   %ebp
  105b2c:	89 e5                	mov    %esp,%ebp
  105b2e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105b31:	8d 45 14             	lea    0x14(%ebp),%eax
  105b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  105b41:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4f:	89 04 24             	mov    %eax,(%esp)
  105b52:	e8 03 00 00 00       	call   105b5a <vprintfmt>
    va_end(ap);
}
  105b57:	90                   	nop
  105b58:	c9                   	leave  
  105b59:	c3                   	ret    

00105b5a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105b5a:	55                   	push   %ebp
  105b5b:	89 e5                	mov    %esp,%ebp
  105b5d:	56                   	push   %esi
  105b5e:	53                   	push   %ebx
  105b5f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105b62:	eb 17                	jmp    105b7b <vprintfmt+0x21>
            if (ch == '\0') {
  105b64:	85 db                	test   %ebx,%ebx
  105b66:	0f 84 bf 03 00 00    	je     105f2b <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b73:	89 1c 24             	mov    %ebx,(%esp)
  105b76:	8b 45 08             	mov    0x8(%ebp),%eax
  105b79:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  105b7e:	8d 50 01             	lea    0x1(%eax),%edx
  105b81:	89 55 10             	mov    %edx,0x10(%ebp)
  105b84:	0f b6 00             	movzbl (%eax),%eax
  105b87:	0f b6 d8             	movzbl %al,%ebx
  105b8a:	83 fb 25             	cmp    $0x25,%ebx
  105b8d:	75 d5                	jne    105b64 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105b8f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105b93:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105ba0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105ba7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105baa:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105bad:	8b 45 10             	mov    0x10(%ebp),%eax
  105bb0:	8d 50 01             	lea    0x1(%eax),%edx
  105bb3:	89 55 10             	mov    %edx,0x10(%ebp)
  105bb6:	0f b6 00             	movzbl (%eax),%eax
  105bb9:	0f b6 d8             	movzbl %al,%ebx
  105bbc:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105bbf:	83 f8 55             	cmp    $0x55,%eax
  105bc2:	0f 87 37 03 00 00    	ja     105eff <vprintfmt+0x3a5>
  105bc8:	8b 04 85 18 72 10 00 	mov    0x107218(,%eax,4),%eax
  105bcf:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105bd1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105bd5:	eb d6                	jmp    105bad <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105bd7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105bdb:	eb d0                	jmp    105bad <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105bdd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105be4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105be7:	89 d0                	mov    %edx,%eax
  105be9:	c1 e0 02             	shl    $0x2,%eax
  105bec:	01 d0                	add    %edx,%eax
  105bee:	01 c0                	add    %eax,%eax
  105bf0:	01 d8                	add    %ebx,%eax
  105bf2:	83 e8 30             	sub    $0x30,%eax
  105bf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  105bfb:	0f b6 00             	movzbl (%eax),%eax
  105bfe:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105c01:	83 fb 2f             	cmp    $0x2f,%ebx
  105c04:	7e 38                	jle    105c3e <vprintfmt+0xe4>
  105c06:	83 fb 39             	cmp    $0x39,%ebx
  105c09:	7f 33                	jg     105c3e <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105c0b:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105c0e:	eb d4                	jmp    105be4 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105c10:	8b 45 14             	mov    0x14(%ebp),%eax
  105c13:	8d 50 04             	lea    0x4(%eax),%edx
  105c16:	89 55 14             	mov    %edx,0x14(%ebp)
  105c19:	8b 00                	mov    (%eax),%eax
  105c1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105c1e:	eb 1f                	jmp    105c3f <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105c20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c24:	79 87                	jns    105bad <vprintfmt+0x53>
                width = 0;
  105c26:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105c2d:	e9 7b ff ff ff       	jmp    105bad <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105c32:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105c39:	e9 6f ff ff ff       	jmp    105bad <vprintfmt+0x53>
            goto process_precision;
  105c3e:	90                   	nop

        process_precision:
            if (width < 0)
  105c3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c43:	0f 89 64 ff ff ff    	jns    105bad <vprintfmt+0x53>
                width = precision, precision = -1;
  105c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105c4f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105c56:	e9 52 ff ff ff       	jmp    105bad <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105c5b:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105c5e:	e9 4a ff ff ff       	jmp    105bad <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105c63:	8b 45 14             	mov    0x14(%ebp),%eax
  105c66:	8d 50 04             	lea    0x4(%eax),%edx
  105c69:	89 55 14             	mov    %edx,0x14(%ebp)
  105c6c:	8b 00                	mov    (%eax),%eax
  105c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c71:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c75:	89 04 24             	mov    %eax,(%esp)
  105c78:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7b:	ff d0                	call   *%eax
            break;
  105c7d:	e9 a4 02 00 00       	jmp    105f26 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105c82:	8b 45 14             	mov    0x14(%ebp),%eax
  105c85:	8d 50 04             	lea    0x4(%eax),%edx
  105c88:	89 55 14             	mov    %edx,0x14(%ebp)
  105c8b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105c8d:	85 db                	test   %ebx,%ebx
  105c8f:	79 02                	jns    105c93 <vprintfmt+0x139>
                err = -err;
  105c91:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105c93:	83 fb 06             	cmp    $0x6,%ebx
  105c96:	7f 0b                	jg     105ca3 <vprintfmt+0x149>
  105c98:	8b 34 9d d8 71 10 00 	mov    0x1071d8(,%ebx,4),%esi
  105c9f:	85 f6                	test   %esi,%esi
  105ca1:	75 23                	jne    105cc6 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105ca3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105ca7:	c7 44 24 08 05 72 10 	movl   $0x107205,0x8(%esp)
  105cae:	00 
  105caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  105cb9:	89 04 24             	mov    %eax,(%esp)
  105cbc:	e8 6a fe ff ff       	call   105b2b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105cc1:	e9 60 02 00 00       	jmp    105f26 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105cc6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105cca:	c7 44 24 08 0e 72 10 	movl   $0x10720e,0x8(%esp)
  105cd1:	00 
  105cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  105cdc:	89 04 24             	mov    %eax,(%esp)
  105cdf:	e8 47 fe ff ff       	call   105b2b <printfmt>
            break;
  105ce4:	e9 3d 02 00 00       	jmp    105f26 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105ce9:	8b 45 14             	mov    0x14(%ebp),%eax
  105cec:	8d 50 04             	lea    0x4(%eax),%edx
  105cef:	89 55 14             	mov    %edx,0x14(%ebp)
  105cf2:	8b 30                	mov    (%eax),%esi
  105cf4:	85 f6                	test   %esi,%esi
  105cf6:	75 05                	jne    105cfd <vprintfmt+0x1a3>
                p = "(null)";
  105cf8:	be 11 72 10 00       	mov    $0x107211,%esi
            }
            if (width > 0 && padc != '-') {
  105cfd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d01:	7e 76                	jle    105d79 <vprintfmt+0x21f>
  105d03:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105d07:	74 70                	je     105d79 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d10:	89 34 24             	mov    %esi,(%esp)
  105d13:	e8 f6 f7 ff ff       	call   10550e <strnlen>
  105d18:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105d1b:	29 c2                	sub    %eax,%edx
  105d1d:	89 d0                	mov    %edx,%eax
  105d1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105d22:	eb 16                	jmp    105d3a <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105d24:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105d28:	8b 55 0c             	mov    0xc(%ebp),%edx
  105d2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  105d2f:	89 04 24             	mov    %eax,(%esp)
  105d32:	8b 45 08             	mov    0x8(%ebp),%eax
  105d35:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105d37:	ff 4d e8             	decl   -0x18(%ebp)
  105d3a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d3e:	7f e4                	jg     105d24 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105d40:	eb 37                	jmp    105d79 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105d42:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105d46:	74 1f                	je     105d67 <vprintfmt+0x20d>
  105d48:	83 fb 1f             	cmp    $0x1f,%ebx
  105d4b:	7e 05                	jle    105d52 <vprintfmt+0x1f8>
  105d4d:	83 fb 7e             	cmp    $0x7e,%ebx
  105d50:	7e 15                	jle    105d67 <vprintfmt+0x20d>
                    putch('?', putdat);
  105d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d59:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105d60:	8b 45 08             	mov    0x8(%ebp),%eax
  105d63:	ff d0                	call   *%eax
  105d65:	eb 0f                	jmp    105d76 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d6e:	89 1c 24             	mov    %ebx,(%esp)
  105d71:	8b 45 08             	mov    0x8(%ebp),%eax
  105d74:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105d76:	ff 4d e8             	decl   -0x18(%ebp)
  105d79:	89 f0                	mov    %esi,%eax
  105d7b:	8d 70 01             	lea    0x1(%eax),%esi
  105d7e:	0f b6 00             	movzbl (%eax),%eax
  105d81:	0f be d8             	movsbl %al,%ebx
  105d84:	85 db                	test   %ebx,%ebx
  105d86:	74 27                	je     105daf <vprintfmt+0x255>
  105d88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105d8c:	78 b4                	js     105d42 <vprintfmt+0x1e8>
  105d8e:	ff 4d e4             	decl   -0x1c(%ebp)
  105d91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105d95:	79 ab                	jns    105d42 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105d97:	eb 16                	jmp    105daf <vprintfmt+0x255>
                putch(' ', putdat);
  105d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105da0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105da7:	8b 45 08             	mov    0x8(%ebp),%eax
  105daa:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105dac:	ff 4d e8             	decl   -0x18(%ebp)
  105daf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105db3:	7f e4                	jg     105d99 <vprintfmt+0x23f>
            }
            break;
  105db5:	e9 6c 01 00 00       	jmp    105f26 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dc1:	8d 45 14             	lea    0x14(%ebp),%eax
  105dc4:	89 04 24             	mov    %eax,(%esp)
  105dc7:	e8 18 fd ff ff       	call   105ae4 <getint>
  105dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105dcf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105dd8:	85 d2                	test   %edx,%edx
  105dda:	79 26                	jns    105e02 <vprintfmt+0x2a8>
                putch('-', putdat);
  105ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
  105de3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105dea:	8b 45 08             	mov    0x8(%ebp),%eax
  105ded:	ff d0                	call   *%eax
                num = -(long long)num;
  105def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105df5:	f7 d8                	neg    %eax
  105df7:	83 d2 00             	adc    $0x0,%edx
  105dfa:	f7 da                	neg    %edx
  105dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105dff:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105e02:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105e09:	e9 a8 00 00 00       	jmp    105eb6 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e15:	8d 45 14             	lea    0x14(%ebp),%eax
  105e18:	89 04 24             	mov    %eax,(%esp)
  105e1b:	e8 75 fc ff ff       	call   105a95 <getuint>
  105e20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e23:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105e26:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105e2d:	e9 84 00 00 00       	jmp    105eb6 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e35:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e39:	8d 45 14             	lea    0x14(%ebp),%eax
  105e3c:	89 04 24             	mov    %eax,(%esp)
  105e3f:	e8 51 fc ff ff       	call   105a95 <getuint>
  105e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e47:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105e4a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105e51:	eb 63                	jmp    105eb6 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e56:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e5a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105e61:	8b 45 08             	mov    0x8(%ebp),%eax
  105e64:	ff d0                	call   *%eax
            putch('x', putdat);
  105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e69:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e6d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105e74:	8b 45 08             	mov    0x8(%ebp),%eax
  105e77:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105e79:	8b 45 14             	mov    0x14(%ebp),%eax
  105e7c:	8d 50 04             	lea    0x4(%eax),%edx
  105e7f:	89 55 14             	mov    %edx,0x14(%ebp)
  105e82:	8b 00                	mov    (%eax),%eax
  105e84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105e8e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105e95:	eb 1f                	jmp    105eb6 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e9e:	8d 45 14             	lea    0x14(%ebp),%eax
  105ea1:	89 04 24             	mov    %eax,(%esp)
  105ea4:	e8 ec fb ff ff       	call   105a95 <getuint>
  105ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105eac:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105eaf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105eb6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105eba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ebd:	89 54 24 18          	mov    %edx,0x18(%esp)
  105ec1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105ec4:	89 54 24 14          	mov    %edx,0x14(%esp)
  105ec8:	89 44 24 10          	mov    %eax,0x10(%esp)
  105ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ecf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ed2:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ed6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  105edd:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ee4:	89 04 24             	mov    %eax,(%esp)
  105ee7:	e8 a4 fa ff ff       	call   105990 <printnum>
            break;
  105eec:	eb 38                	jmp    105f26 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ef5:	89 1c 24             	mov    %ebx,(%esp)
  105ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  105efb:	ff d0                	call   *%eax
            break;
  105efd:	eb 27                	jmp    105f26 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f02:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f06:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105f10:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105f12:	ff 4d 10             	decl   0x10(%ebp)
  105f15:	eb 03                	jmp    105f1a <vprintfmt+0x3c0>
  105f17:	ff 4d 10             	decl   0x10(%ebp)
  105f1a:	8b 45 10             	mov    0x10(%ebp),%eax
  105f1d:	48                   	dec    %eax
  105f1e:	0f b6 00             	movzbl (%eax),%eax
  105f21:	3c 25                	cmp    $0x25,%al
  105f23:	75 f2                	jne    105f17 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105f25:	90                   	nop
    while (1) {
  105f26:	e9 37 fc ff ff       	jmp    105b62 <vprintfmt+0x8>
                return;
  105f2b:	90                   	nop
        }
    }
}
  105f2c:	83 c4 40             	add    $0x40,%esp
  105f2f:	5b                   	pop    %ebx
  105f30:	5e                   	pop    %esi
  105f31:	5d                   	pop    %ebp
  105f32:	c3                   	ret    

00105f33 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105f33:	55                   	push   %ebp
  105f34:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105f36:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f39:	8b 40 08             	mov    0x8(%eax),%eax
  105f3c:	8d 50 01             	lea    0x1(%eax),%edx
  105f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f42:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105f45:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f48:	8b 10                	mov    (%eax),%edx
  105f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f4d:	8b 40 04             	mov    0x4(%eax),%eax
  105f50:	39 c2                	cmp    %eax,%edx
  105f52:	73 12                	jae    105f66 <sprintputch+0x33>
        *b->buf ++ = ch;
  105f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f57:	8b 00                	mov    (%eax),%eax
  105f59:	8d 48 01             	lea    0x1(%eax),%ecx
  105f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  105f5f:	89 0a                	mov    %ecx,(%edx)
  105f61:	8b 55 08             	mov    0x8(%ebp),%edx
  105f64:	88 10                	mov    %dl,(%eax)
    }
}
  105f66:	90                   	nop
  105f67:	5d                   	pop    %ebp
  105f68:	c3                   	ret    

00105f69 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105f69:	55                   	push   %ebp
  105f6a:	89 e5                	mov    %esp,%ebp
  105f6c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105f6f:	8d 45 14             	lea    0x14(%ebp),%eax
  105f72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  105f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f83:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  105f8d:	89 04 24             	mov    %eax,(%esp)
  105f90:	e8 08 00 00 00       	call   105f9d <vsnprintf>
  105f95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105f9b:	c9                   	leave  
  105f9c:	c3                   	ret    

00105f9d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105f9d:	55                   	push   %ebp
  105f9e:	89 e5                	mov    %esp,%ebp
  105fa0:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  105fa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fac:	8d 50 ff             	lea    -0x1(%eax),%edx
  105faf:	8b 45 08             	mov    0x8(%ebp),%eax
  105fb2:	01 d0                	add    %edx,%eax
  105fb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105fb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105fbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105fc2:	74 0a                	je     105fce <vsnprintf+0x31>
  105fc4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fca:	39 c2                	cmp    %eax,%edx
  105fcc:	76 07                	jbe    105fd5 <vsnprintf+0x38>
        return -E_INVAL;
  105fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105fd3:	eb 2a                	jmp    105fff <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105fd5:	8b 45 14             	mov    0x14(%ebp),%eax
  105fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  105fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  105fe3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fea:	c7 04 24 33 5f 10 00 	movl   $0x105f33,(%esp)
  105ff1:	e8 64 fb ff ff       	call   105b5a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ff9:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105fff:	c9                   	leave  
  106000:	c3                   	ret    
