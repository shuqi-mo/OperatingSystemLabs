
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
  10005d:	e8 08 56 00 00       	call   10566a <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 5e 10 00 	movl   $0x105e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 5e 10 00 	movl   $0x105e9c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 14 31 00 00       	call   1031a4 <pmm_init>

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
  100162:	c7 04 24 a1 5e 10 00 	movl   $0x105ea1,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 5e 10 00 	movl   $0x105eaf,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 bd 5e 10 00 	movl   $0x105ebd,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 cb 5e 10 00 	movl   $0x105ecb,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 d9 5e 10 00 	movl   $0x105ed9,(%esp)
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
  10020f:	c7 04 24 e8 5e 10 00 	movl   $0x105ee8,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 08 5f 10 00 	movl   $0x105f08,(%esp)
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
  100288:	e8 30 57 00 00       	call   1059bd <vprintfmt>
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
  100347:	c7 04 24 27 5f 10 00 	movl   $0x105f27,(%esp)
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
  100416:	c7 04 24 2a 5f 10 00 	movl   $0x105f2a,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 46 5f 10 00 	movl   $0x105f46,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 48 5f 10 00 	movl   $0x105f48,(%esp)
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
  100481:	c7 04 24 5a 5f 10 00 	movl   $0x105f5a,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 46 5f 10 00 	movl   $0x105f46,(%esp)
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
  10060f:	c7 00 78 5f 10 00    	movl   $0x105f78,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 78 5f 10 00 	movl   $0x105f78,0x8(%eax)
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
  100646:	c7 45 f4 d0 71 10 00 	movl   $0x1071d0,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 f8 21 11 00 	movl   $0x1121f8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec f9 21 11 00 	movl   $0x1121f9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 f1 4c 11 00 	movl   $0x114cf1,-0x18(%ebp)

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
  1007b6:	e8 2b 4d 00 00       	call   1054e6 <strfind>
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
  10093e:	c7 04 24 82 5f 10 00 	movl   $0x105f82,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 9b 5f 10 00 	movl   $0x105f9b,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 64 5e 10 	movl   $0x105e64,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 b3 5f 10 00 	movl   $0x105fb3,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 cb 5f 10 00 	movl   $0x105fcb,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 e3 5f 10 00 	movl   $0x105fe3,(%esp)
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
  1009c0:	c7 04 24 fc 5f 10 00 	movl   $0x105ffc,(%esp)
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
  1009f5:	c7 04 24 26 60 10 00 	movl   $0x106026,(%esp)
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
  100a63:	c7 04 24 42 60 10 00 	movl   $0x106042,(%esp)
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
  100ab6:	c7 04 24 54 60 10 00 	movl   $0x106054,(%esp)
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
  100ae9:	c7 04 24 70 60 10 00 	movl   $0x106070,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
          for(uint32_t j = 0; j < 4; j++)
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	76 d6                	jbe    100ad4 <print_stackframe+0x51>
        cprintf("\n");
  100afe:	c7 04 24 78 60 10 00 	movl   $0x106078,(%esp)
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
  100b71:	c7 04 24 fc 60 10 00 	movl   $0x1060fc,(%esp)
  100b78:	e8 37 49 00 00       	call   1054b4 <strchr>
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
  100b99:	c7 04 24 01 61 10 00 	movl   $0x106101,(%esp)
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
  100bdb:	c7 04 24 fc 60 10 00 	movl   $0x1060fc,(%esp)
  100be2:	e8 cd 48 00 00       	call   1054b4 <strchr>
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
  100c48:	e8 ca 47 00 00       	call   105417 <strcmp>
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
  100c94:	c7 04 24 1f 61 10 00 	movl   $0x10611f,(%esp)
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
  100cb1:	c7 04 24 38 61 10 00 	movl   $0x106138,(%esp)
  100cb8:	e8 d5 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbd:	c7 04 24 60 61 10 00 	movl   $0x106160,(%esp)
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
  100cda:	c7 04 24 85 61 10 00 	movl   $0x106185,(%esp)
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
  100d48:	c7 04 24 89 61 10 00 	movl   $0x106189,(%esp)
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
  100dd3:	c7 04 24 92 61 10 00 	movl   $0x106192,(%esp)
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
  101215:	e8 90 44 00 00       	call   1056aa <memmove>
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
  101595:	c7 04 24 ad 61 10 00 	movl   $0x1061ad,(%esp)
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
  101605:	c7 04 24 b9 61 10 00 	movl   $0x1061b9,(%esp)
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
  1018a2:	c7 04 24 e0 61 10 00 	movl   $0x1061e0,(%esp)
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
  101a31:	8b 04 85 40 65 10 00 	mov    0x106540(,%eax,4),%eax
  101a38:	eb 18                	jmp    101a52 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a3a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a3e:	7e 0d                	jle    101a4d <trapname+0x2a>
  101a40:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a44:	7f 07                	jg     101a4d <trapname+0x2a>
        return "Hardware Interrupt";
  101a46:	b8 ea 61 10 00       	mov    $0x1061ea,%eax
  101a4b:	eb 05                	jmp    101a52 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a4d:	b8 fd 61 10 00       	mov    $0x1061fd,%eax
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
  101a76:	c7 04 24 3e 62 10 00 	movl   $0x10623e,(%esp)
  101a7d:	e8 10 e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a82:	8b 45 08             	mov    0x8(%ebp),%eax
  101a85:	89 04 24             	mov    %eax,(%esp)
  101a88:	e8 8f 01 00 00       	call   101c1c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a90:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a98:	c7 04 24 4f 62 10 00 	movl   $0x10624f,(%esp)
  101a9f:	e8 ee e7 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa7:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aaf:	c7 04 24 62 62 10 00 	movl   $0x106262,(%esp)
  101ab6:	e8 d7 e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101abb:	8b 45 08             	mov    0x8(%ebp),%eax
  101abe:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac6:	c7 04 24 75 62 10 00 	movl   $0x106275,(%esp)
  101acd:	e8 c0 e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101add:	c7 04 24 88 62 10 00 	movl   $0x106288,(%esp)
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
  101b07:	c7 04 24 9b 62 10 00 	movl   $0x10629b,(%esp)
  101b0e:	e8 7f e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b13:	8b 45 08             	mov    0x8(%ebp),%eax
  101b16:	8b 40 34             	mov    0x34(%eax),%eax
  101b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1d:	c7 04 24 ad 62 10 00 	movl   $0x1062ad,(%esp)
  101b24:	e8 69 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b29:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2c:	8b 40 38             	mov    0x38(%eax),%eax
  101b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b33:	c7 04 24 bc 62 10 00 	movl   $0x1062bc,(%esp)
  101b3a:	e8 53 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4a:	c7 04 24 cb 62 10 00 	movl   $0x1062cb,(%esp)
  101b51:	e8 3c e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b56:	8b 45 08             	mov    0x8(%ebp),%eax
  101b59:	8b 40 40             	mov    0x40(%eax),%eax
  101b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b60:	c7 04 24 de 62 10 00 	movl   $0x1062de,(%esp)
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
  101ba7:	c7 04 24 ed 62 10 00 	movl   $0x1062ed,(%esp)
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
  101bd1:	c7 04 24 f1 62 10 00 	movl   $0x1062f1,(%esp)
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
  101bf6:	c7 04 24 fa 62 10 00 	movl   $0x1062fa,(%esp)
  101bfd:	e8 90 e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c02:	8b 45 08             	mov    0x8(%ebp),%eax
  101c05:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0d:	c7 04 24 09 63 10 00 	movl   $0x106309,(%esp)
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
  101c2b:	c7 04 24 1c 63 10 00 	movl   $0x10631c,(%esp)
  101c32:	e8 5b e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c37:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3a:	8b 40 04             	mov    0x4(%eax),%eax
  101c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c41:	c7 04 24 2b 63 10 00 	movl   $0x10632b,(%esp)
  101c48:	e8 45 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c50:	8b 40 08             	mov    0x8(%eax),%eax
  101c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c57:	c7 04 24 3a 63 10 00 	movl   $0x10633a,(%esp)
  101c5e:	e8 2f e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c63:	8b 45 08             	mov    0x8(%ebp),%eax
  101c66:	8b 40 0c             	mov    0xc(%eax),%eax
  101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6d:	c7 04 24 49 63 10 00 	movl   $0x106349,(%esp)
  101c74:	e8 19 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c79:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7c:	8b 40 10             	mov    0x10(%eax),%eax
  101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c83:	c7 04 24 58 63 10 00 	movl   $0x106358,(%esp)
  101c8a:	e8 03 e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c92:	8b 40 14             	mov    0x14(%eax),%eax
  101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c99:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  101ca0:	e8 ed e5 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca8:	8b 40 18             	mov    0x18(%eax),%eax
  101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101caf:	c7 04 24 76 63 10 00 	movl   $0x106376,(%esp)
  101cb6:	e8 d7 e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbe:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc5:	c7 04 24 85 63 10 00 	movl   $0x106385,(%esp)
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
  101d7f:	c7 04 24 94 63 10 00 	movl   $0x106394,(%esp)
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
  101da5:	c7 04 24 a6 63 10 00 	movl   $0x1063a6,(%esp)
  101dac:	e8 e1 e4 ff ff       	call   100292 <cprintf>
        break;
  101db1:	eb 55                	jmp    101e08 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101db3:	c7 44 24 08 b5 63 10 	movl   $0x1063b5,0x8(%esp)
  101dba:	00 
  101dbb:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  101dc2:	00 
  101dc3:	c7 04 24 c5 63 10 00 	movl   $0x1063c5,(%esp)
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
  101de8:	c7 44 24 08 d6 63 10 	movl   $0x1063d6,0x8(%esp)
  101def:	00 
  101df0:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101df7:	00 
  101df8:	c7 04 24 c5 63 10 00 	movl   $0x1063c5,(%esp)
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
  1028f9:	c7 44 24 08 90 65 10 	movl   $0x106590,0x8(%esp)
  102900:	00 
  102901:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102908:	00 
  102909:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
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
  10295f:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  102966:	00 
  102967:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  10296e:	00 
  10296f:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
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
  102995:	c7 44 24 08 e4 65 10 	movl   $0x1065e4,0x8(%esp)
  10299c:	00 
  10299d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1029a4:	00 
  1029a5:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
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

001029e5 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
  1029e5:	55                   	push   %ebp
  1029e6:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029eb:	8b 00                	mov    (%eax),%eax
  1029ed:	8d 50 01             	lea    0x1(%eax),%edx
  1029f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f3:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f8:	8b 00                	mov    (%eax),%eax
}
  1029fa:	5d                   	pop    %ebp
  1029fb:	c3                   	ret    

001029fc <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1029fc:	55                   	push   %ebp
  1029fd:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1029ff:	8b 45 08             	mov    0x8(%ebp),%eax
  102a02:	8b 00                	mov    (%eax),%eax
  102a04:	8d 50 ff             	lea    -0x1(%eax),%edx
  102a07:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0a:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0f:	8b 00                	mov    (%eax),%eax
}
  102a11:	5d                   	pop    %ebp
  102a12:	c3                   	ret    

00102a13 <__intr_save>:
__intr_save(void) {
  102a13:	55                   	push   %ebp
  102a14:	89 e5                	mov    %esp,%ebp
  102a16:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a19:	9c                   	pushf  
  102a1a:	58                   	pop    %eax
  102a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a21:	25 00 02 00 00       	and    $0x200,%eax
  102a26:	85 c0                	test   %eax,%eax
  102a28:	74 0c                	je     102a36 <__intr_save+0x23>
        intr_disable();
  102a2a:	e8 5e ee ff ff       	call   10188d <intr_disable>
        return 1;
  102a2f:	b8 01 00 00 00       	mov    $0x1,%eax
  102a34:	eb 05                	jmp    102a3b <__intr_save+0x28>
    return 0;
  102a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a3b:	c9                   	leave  
  102a3c:	c3                   	ret    

00102a3d <__intr_restore>:
__intr_restore(bool flag) {
  102a3d:	55                   	push   %ebp
  102a3e:	89 e5                	mov    %esp,%ebp
  102a40:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a43:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a47:	74 05                	je     102a4e <__intr_restore+0x11>
        intr_enable();
  102a49:	e8 38 ee ff ff       	call   101886 <intr_enable>
}
  102a4e:	90                   	nop
  102a4f:	c9                   	leave  
  102a50:	c3                   	ret    

00102a51 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a51:	55                   	push   %ebp
  102a52:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a54:	8b 45 08             	mov    0x8(%ebp),%eax
  102a57:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a5a:	b8 23 00 00 00       	mov    $0x23,%eax
  102a5f:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a61:	b8 23 00 00 00       	mov    $0x23,%eax
  102a66:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a68:	b8 10 00 00 00       	mov    $0x10,%eax
  102a6d:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a6f:	b8 10 00 00 00       	mov    $0x10,%eax
  102a74:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a76:	b8 10 00 00 00       	mov    $0x10,%eax
  102a7b:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a7d:	ea 84 2a 10 00 08 00 	ljmp   $0x8,$0x102a84
}
  102a84:	90                   	nop
  102a85:	5d                   	pop    %ebp
  102a86:	c3                   	ret    

00102a87 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a87:	55                   	push   %ebp
  102a88:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a8d:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102a92:	90                   	nop
  102a93:	5d                   	pop    %ebp
  102a94:	c3                   	ret    

00102a95 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a95:	55                   	push   %ebp
  102a96:	89 e5                	mov    %esp,%ebp
  102a98:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a9b:	b8 00 70 11 00       	mov    $0x117000,%eax
  102aa0:	89 04 24             	mov    %eax,(%esp)
  102aa3:	e8 df ff ff ff       	call   102a87 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102aa8:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102aaf:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102ab1:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102ab8:	68 00 
  102aba:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102abf:	0f b7 c0             	movzwl %ax,%eax
  102ac2:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102ac8:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102acd:	c1 e8 10             	shr    $0x10,%eax
  102ad0:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102ad5:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102adc:	24 f0                	and    $0xf0,%al
  102ade:	0c 09                	or     $0x9,%al
  102ae0:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102ae5:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102aec:	24 ef                	and    $0xef,%al
  102aee:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102af3:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102afa:	24 9f                	and    $0x9f,%al
  102afc:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b01:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b08:	0c 80                	or     $0x80,%al
  102b0a:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b0f:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b16:	24 f0                	and    $0xf0,%al
  102b18:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b1d:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b24:	24 ef                	and    $0xef,%al
  102b26:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b2b:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b32:	24 df                	and    $0xdf,%al
  102b34:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b39:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b40:	0c 40                	or     $0x40,%al
  102b42:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b47:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b4e:	24 7f                	and    $0x7f,%al
  102b50:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b55:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102b5a:	c1 e8 18             	shr    $0x18,%eax
  102b5d:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b62:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102b69:	e8 e3 fe ff ff       	call   102a51 <lgdt>
  102b6e:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b74:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b78:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b7b:	90                   	nop
  102b7c:	c9                   	leave  
  102b7d:	c3                   	ret    

00102b7e <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b7e:	55                   	push   %ebp
  102b7f:	89 e5                	mov    %esp,%ebp
  102b81:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b84:	c7 05 10 af 11 00 b8 	movl   $0x106fb8,0x11af10
  102b8b:	6f 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b8e:	a1 10 af 11 00       	mov    0x11af10,%eax
  102b93:	8b 00                	mov    (%eax),%eax
  102b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b99:	c7 04 24 10 66 10 00 	movl   $0x106610,(%esp)
  102ba0:	e8 ed d6 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102ba5:	a1 10 af 11 00       	mov    0x11af10,%eax
  102baa:	8b 40 04             	mov    0x4(%eax),%eax
  102bad:	ff d0                	call   *%eax
}
  102baf:	90                   	nop
  102bb0:	c9                   	leave  
  102bb1:	c3                   	ret    

00102bb2 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102bb2:	55                   	push   %ebp
  102bb3:	89 e5                	mov    %esp,%ebp
  102bb5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102bb8:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bbd:	8b 40 08             	mov    0x8(%eax),%eax
  102bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  102bca:	89 14 24             	mov    %edx,(%esp)
  102bcd:	ff d0                	call   *%eax
}
  102bcf:	90                   	nop
  102bd0:	c9                   	leave  
  102bd1:	c3                   	ret    

00102bd2 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102bd2:	55                   	push   %ebp
  102bd3:	89 e5                	mov    %esp,%ebp
  102bd5:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102bd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102bdf:	e8 2f fe ff ff       	call   102a13 <__intr_save>
  102be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102be7:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bec:	8b 40 0c             	mov    0xc(%eax),%eax
  102bef:	8b 55 08             	mov    0x8(%ebp),%edx
  102bf2:	89 14 24             	mov    %edx,(%esp)
  102bf5:	ff d0                	call   *%eax
  102bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bfd:	89 04 24             	mov    %eax,(%esp)
  102c00:	e8 38 fe ff ff       	call   102a3d <__intr_restore>
    return page;
  102c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c08:	c9                   	leave  
  102c09:	c3                   	ret    

00102c0a <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102c0a:	55                   	push   %ebp
  102c0b:	89 e5                	mov    %esp,%ebp
  102c0d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102c10:	e8 fe fd ff ff       	call   102a13 <__intr_save>
  102c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c18:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c1d:	8b 40 10             	mov    0x10(%eax),%eax
  102c20:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c23:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c27:	8b 55 08             	mov    0x8(%ebp),%edx
  102c2a:	89 14 24             	mov    %edx,(%esp)
  102c2d:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c32:	89 04 24             	mov    %eax,(%esp)
  102c35:	e8 03 fe ff ff       	call   102a3d <__intr_restore>
}
  102c3a:	90                   	nop
  102c3b:	c9                   	leave  
  102c3c:	c3                   	ret    

00102c3d <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c3d:	55                   	push   %ebp
  102c3e:	89 e5                	mov    %esp,%ebp
  102c40:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c43:	e8 cb fd ff ff       	call   102a13 <__intr_save>
  102c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c4b:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c50:	8b 40 14             	mov    0x14(%eax),%eax
  102c53:	ff d0                	call   *%eax
  102c55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c5b:	89 04 24             	mov    %eax,(%esp)
  102c5e:	e8 da fd ff ff       	call   102a3d <__intr_restore>
    return ret;
  102c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c66:	c9                   	leave  
  102c67:	c3                   	ret    

00102c68 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c68:	55                   	push   %ebp
  102c69:	89 e5                	mov    %esp,%ebp
  102c6b:	57                   	push   %edi
  102c6c:	56                   	push   %esi
  102c6d:	53                   	push   %ebx
  102c6e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c74:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c7b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c82:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c89:	c7 04 24 27 66 10 00 	movl   $0x106627,(%esp)
  102c90:	e8 fd d5 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c95:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c9c:	e9 22 01 00 00       	jmp    102dc3 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102ca1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ca4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ca7:	89 d0                	mov    %edx,%eax
  102ca9:	c1 e0 02             	shl    $0x2,%eax
  102cac:	01 d0                	add    %edx,%eax
  102cae:	c1 e0 02             	shl    $0x2,%eax
  102cb1:	01 c8                	add    %ecx,%eax
  102cb3:	8b 50 08             	mov    0x8(%eax),%edx
  102cb6:	8b 40 04             	mov    0x4(%eax),%eax
  102cb9:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102cbc:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102cbf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cc2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cc5:	89 d0                	mov    %edx,%eax
  102cc7:	c1 e0 02             	shl    $0x2,%eax
  102cca:	01 d0                	add    %edx,%eax
  102ccc:	c1 e0 02             	shl    $0x2,%eax
  102ccf:	01 c8                	add    %ecx,%eax
  102cd1:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cd4:	8b 58 10             	mov    0x10(%eax),%ebx
  102cd7:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102cda:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102cdd:	01 c8                	add    %ecx,%eax
  102cdf:	11 da                	adc    %ebx,%edx
  102ce1:	89 45 98             	mov    %eax,-0x68(%ebp)
  102ce4:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102ce7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cea:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ced:	89 d0                	mov    %edx,%eax
  102cef:	c1 e0 02             	shl    $0x2,%eax
  102cf2:	01 d0                	add    %edx,%eax
  102cf4:	c1 e0 02             	shl    $0x2,%eax
  102cf7:	01 c8                	add    %ecx,%eax
  102cf9:	83 c0 14             	add    $0x14,%eax
  102cfc:	8b 00                	mov    (%eax),%eax
  102cfe:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102d01:	8b 45 98             	mov    -0x68(%ebp),%eax
  102d04:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102d07:	83 c0 ff             	add    $0xffffffff,%eax
  102d0a:	83 d2 ff             	adc    $0xffffffff,%edx
  102d0d:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102d13:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102d19:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d1f:	89 d0                	mov    %edx,%eax
  102d21:	c1 e0 02             	shl    $0x2,%eax
  102d24:	01 d0                	add    %edx,%eax
  102d26:	c1 e0 02             	shl    $0x2,%eax
  102d29:	01 c8                	add    %ecx,%eax
  102d2b:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d2e:	8b 58 10             	mov    0x10(%eax),%ebx
  102d31:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102d34:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102d38:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102d3e:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102d44:	89 44 24 14          	mov    %eax,0x14(%esp)
  102d48:	89 54 24 18          	mov    %edx,0x18(%esp)
  102d4c:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102d4f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102d52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d56:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d62:	c7 04 24 34 66 10 00 	movl   $0x106634,(%esp)
  102d69:	e8 24 d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d71:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d74:	89 d0                	mov    %edx,%eax
  102d76:	c1 e0 02             	shl    $0x2,%eax
  102d79:	01 d0                	add    %edx,%eax
  102d7b:	c1 e0 02             	shl    $0x2,%eax
  102d7e:	01 c8                	add    %ecx,%eax
  102d80:	83 c0 14             	add    $0x14,%eax
  102d83:	8b 00                	mov    (%eax),%eax
  102d85:	83 f8 01             	cmp    $0x1,%eax
  102d88:	75 36                	jne    102dc0 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d90:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d93:	77 2b                	ja     102dc0 <page_init+0x158>
  102d95:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d98:	72 05                	jb     102d9f <page_init+0x137>
  102d9a:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102d9d:	73 21                	jae    102dc0 <page_init+0x158>
  102d9f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102da3:	77 1b                	ja     102dc0 <page_init+0x158>
  102da5:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102da9:	72 09                	jb     102db4 <page_init+0x14c>
  102dab:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102db2:	77 0c                	ja     102dc0 <page_init+0x158>
                maxpa = end;
  102db4:	8b 45 98             	mov    -0x68(%ebp),%eax
  102db7:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102dbd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102dc0:	ff 45 dc             	incl   -0x24(%ebp)
  102dc3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102dc6:	8b 00                	mov    (%eax),%eax
  102dc8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102dcb:	0f 8c d0 fe ff ff    	jl     102ca1 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102dd1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dd5:	72 1d                	jb     102df4 <page_init+0x18c>
  102dd7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102ddb:	77 09                	ja     102de6 <page_init+0x17e>
  102ddd:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102de4:	76 0e                	jbe    102df4 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102de6:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102df7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102dfa:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102dfe:	c1 ea 0c             	shr    $0xc,%edx
  102e01:	89 c1                	mov    %eax,%ecx
  102e03:	89 d3                	mov    %edx,%ebx
  102e05:	89 c8                	mov    %ecx,%eax
  102e07:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102e0c:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102e13:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102e18:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e1b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e1e:	01 d0                	add    %edx,%eax
  102e20:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102e23:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e26:	ba 00 00 00 00       	mov    $0x0,%edx
  102e2b:	f7 75 c0             	divl   -0x40(%ebp)
  102e2e:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102e31:	29 d0                	sub    %edx,%eax
  102e33:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102e38:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e3f:	eb 2e                	jmp    102e6f <page_init+0x207>
        SetPageReserved(pages + i);
  102e41:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e4a:	89 d0                	mov    %edx,%eax
  102e4c:	c1 e0 02             	shl    $0x2,%eax
  102e4f:	01 d0                	add    %edx,%eax
  102e51:	c1 e0 02             	shl    $0x2,%eax
  102e54:	01 c8                	add    %ecx,%eax
  102e56:	83 c0 04             	add    $0x4,%eax
  102e59:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102e60:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e63:	8b 45 90             	mov    -0x70(%ebp),%eax
  102e66:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102e69:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e6c:	ff 45 dc             	incl   -0x24(%ebp)
  102e6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e72:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102e77:	39 c2                	cmp    %eax,%edx
  102e79:	72 c6                	jb     102e41 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e7b:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102e81:	89 d0                	mov    %edx,%eax
  102e83:	c1 e0 02             	shl    $0x2,%eax
  102e86:	01 d0                	add    %edx,%eax
  102e88:	c1 e0 02             	shl    $0x2,%eax
  102e8b:	89 c2                	mov    %eax,%edx
  102e8d:	a1 18 af 11 00       	mov    0x11af18,%eax
  102e92:	01 d0                	add    %edx,%eax
  102e94:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102e97:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102e9e:	77 23                	ja     102ec3 <page_init+0x25b>
  102ea0:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ea7:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  102eae:	00 
  102eaf:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  102eb6:	00 
  102eb7:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  102ebe:	e8 26 d5 ff ff       	call   1003e9 <__panic>
  102ec3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ec6:	05 00 00 00 40       	add    $0x40000000,%eax
  102ecb:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102ece:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ed5:	e9 69 01 00 00       	jmp    103043 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102eda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ee0:	89 d0                	mov    %edx,%eax
  102ee2:	c1 e0 02             	shl    $0x2,%eax
  102ee5:	01 d0                	add    %edx,%eax
  102ee7:	c1 e0 02             	shl    $0x2,%eax
  102eea:	01 c8                	add    %ecx,%eax
  102eec:	8b 50 08             	mov    0x8(%eax),%edx
  102eef:	8b 40 04             	mov    0x4(%eax),%eax
  102ef2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ef5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102ef8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102efb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102efe:	89 d0                	mov    %edx,%eax
  102f00:	c1 e0 02             	shl    $0x2,%eax
  102f03:	01 d0                	add    %edx,%eax
  102f05:	c1 e0 02             	shl    $0x2,%eax
  102f08:	01 c8                	add    %ecx,%eax
  102f0a:	8b 48 0c             	mov    0xc(%eax),%ecx
  102f0d:	8b 58 10             	mov    0x10(%eax),%ebx
  102f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f16:	01 c8                	add    %ecx,%eax
  102f18:	11 da                	adc    %ebx,%edx
  102f1a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102f1d:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102f20:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f23:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f26:	89 d0                	mov    %edx,%eax
  102f28:	c1 e0 02             	shl    $0x2,%eax
  102f2b:	01 d0                	add    %edx,%eax
  102f2d:	c1 e0 02             	shl    $0x2,%eax
  102f30:	01 c8                	add    %ecx,%eax
  102f32:	83 c0 14             	add    $0x14,%eax
  102f35:	8b 00                	mov    (%eax),%eax
  102f37:	83 f8 01             	cmp    $0x1,%eax
  102f3a:	0f 85 00 01 00 00    	jne    103040 <page_init+0x3d8>
            if (begin < freemem) {
  102f40:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f43:	ba 00 00 00 00       	mov    $0x0,%edx
  102f48:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102f4b:	77 17                	ja     102f64 <page_init+0x2fc>
  102f4d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102f50:	72 05                	jb     102f57 <page_init+0x2ef>
  102f52:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102f55:	73 0d                	jae    102f64 <page_init+0x2fc>
                begin = freemem;
  102f57:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f5d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f64:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f68:	72 1d                	jb     102f87 <page_init+0x31f>
  102f6a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f6e:	77 09                	ja     102f79 <page_init+0x311>
  102f70:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f77:	76 0e                	jbe    102f87 <page_init+0x31f>
                end = KMEMSIZE;
  102f79:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f80:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f87:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f8d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f90:	0f 87 aa 00 00 00    	ja     103040 <page_init+0x3d8>
  102f96:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f99:	72 09                	jb     102fa4 <page_init+0x33c>
  102f9b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f9e:	0f 83 9c 00 00 00    	jae    103040 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  102fa4:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  102fab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102fae:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102fb1:	01 d0                	add    %edx,%eax
  102fb3:	48                   	dec    %eax
  102fb4:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102fb7:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102fba:	ba 00 00 00 00       	mov    $0x0,%edx
  102fbf:	f7 75 b0             	divl   -0x50(%ebp)
  102fc2:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102fc5:	29 d0                	sub    %edx,%eax
  102fc7:	ba 00 00 00 00       	mov    $0x0,%edx
  102fcc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fcf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102fd2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fd5:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102fd8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  102fe0:	89 c3                	mov    %eax,%ebx
  102fe2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102fe8:	89 de                	mov    %ebx,%esi
  102fea:	89 d0                	mov    %edx,%eax
  102fec:	83 e0 00             	and    $0x0,%eax
  102fef:	89 c7                	mov    %eax,%edi
  102ff1:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102ff4:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102ff7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ffa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ffd:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103000:	77 3e                	ja     103040 <page_init+0x3d8>
  103002:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103005:	72 05                	jb     10300c <page_init+0x3a4>
  103007:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10300a:	73 34                	jae    103040 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  10300c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10300f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103012:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103015:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  103018:	89 c1                	mov    %eax,%ecx
  10301a:	89 d3                	mov    %edx,%ebx
  10301c:	89 c8                	mov    %ecx,%eax
  10301e:	89 da                	mov    %ebx,%edx
  103020:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103024:	c1 ea 0c             	shr    $0xc,%edx
  103027:	89 c3                	mov    %eax,%ebx
  103029:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10302c:	89 04 24             	mov    %eax,(%esp)
  10302f:	e8 ae f8 ff ff       	call   1028e2 <pa2page>
  103034:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103038:	89 04 24             	mov    %eax,(%esp)
  10303b:	e8 72 fb ff ff       	call   102bb2 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  103040:	ff 45 dc             	incl   -0x24(%ebp)
  103043:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103046:	8b 00                	mov    (%eax),%eax
  103048:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10304b:	0f 8c 89 fe ff ff    	jl     102eda <page_init+0x272>
                }
            }
        }
    }
}
  103051:	90                   	nop
  103052:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103058:	5b                   	pop    %ebx
  103059:	5e                   	pop    %esi
  10305a:	5f                   	pop    %edi
  10305b:	5d                   	pop    %ebp
  10305c:	c3                   	ret    

0010305d <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10305d:	55                   	push   %ebp
  10305e:	89 e5                	mov    %esp,%ebp
  103060:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103063:	8b 45 0c             	mov    0xc(%ebp),%eax
  103066:	33 45 14             	xor    0x14(%ebp),%eax
  103069:	25 ff 0f 00 00       	and    $0xfff,%eax
  10306e:	85 c0                	test   %eax,%eax
  103070:	74 24                	je     103096 <boot_map_segment+0x39>
  103072:	c7 44 24 0c 96 66 10 	movl   $0x106696,0xc(%esp)
  103079:	00 
  10307a:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103081:	00 
  103082:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  103089:	00 
  10308a:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103091:	e8 53 d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103096:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10309d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030a0:	25 ff 0f 00 00       	and    $0xfff,%eax
  1030a5:	89 c2                	mov    %eax,%edx
  1030a7:	8b 45 10             	mov    0x10(%ebp),%eax
  1030aa:	01 c2                	add    %eax,%edx
  1030ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030af:	01 d0                	add    %edx,%eax
  1030b1:	48                   	dec    %eax
  1030b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030b8:	ba 00 00 00 00       	mov    $0x0,%edx
  1030bd:	f7 75 f0             	divl   -0x10(%ebp)
  1030c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030c3:	29 d0                	sub    %edx,%eax
  1030c5:	c1 e8 0c             	shr    $0xc,%eax
  1030c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1030cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030d9:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1030dc:	8b 45 14             	mov    0x14(%ebp),%eax
  1030df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030ea:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030ed:	eb 68                	jmp    103157 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1030ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1030f6:	00 
  1030f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030fe:	8b 45 08             	mov    0x8(%ebp),%eax
  103101:	89 04 24             	mov    %eax,(%esp)
  103104:	e8 81 01 00 00       	call   10328a <get_pte>
  103109:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10310c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103110:	75 24                	jne    103136 <boot_map_segment+0xd9>
  103112:	c7 44 24 0c c2 66 10 	movl   $0x1066c2,0xc(%esp)
  103119:	00 
  10311a:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103121:	00 
  103122:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103129:	00 
  10312a:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103131:	e8 b3 d2 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  103136:	8b 45 14             	mov    0x14(%ebp),%eax
  103139:	0b 45 18             	or     0x18(%ebp),%eax
  10313c:	83 c8 01             	or     $0x1,%eax
  10313f:	89 c2                	mov    %eax,%edx
  103141:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103144:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103146:	ff 4d f4             	decl   -0xc(%ebp)
  103149:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  103150:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103157:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10315b:	75 92                	jne    1030ef <boot_map_segment+0x92>
    }
}
  10315d:	90                   	nop
  10315e:	c9                   	leave  
  10315f:	c3                   	ret    

00103160 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  103160:	55                   	push   %ebp
  103161:	89 e5                	mov    %esp,%ebp
  103163:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103166:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10316d:	e8 60 fa ff ff       	call   102bd2 <alloc_pages>
  103172:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103175:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103179:	75 1c                	jne    103197 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10317b:	c7 44 24 08 cf 66 10 	movl   $0x1066cf,0x8(%esp)
  103182:	00 
  103183:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10318a:	00 
  10318b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103192:	e8 52 d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  103197:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10319a:	89 04 24             	mov    %eax,(%esp)
  10319d:	e8 8f f7 ff ff       	call   102931 <page2kva>
}
  1031a2:	c9                   	leave  
  1031a3:	c3                   	ret    

001031a4 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1031a4:	55                   	push   %ebp
  1031a5:	89 e5                	mov    %esp,%ebp
  1031a7:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1031aa:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031b2:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1031b9:	77 23                	ja     1031de <pmm_init+0x3a>
  1031bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031c2:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  1031c9:	00 
  1031ca:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1031d1:	00 
  1031d2:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1031d9:	e8 0b d2 ff ff       	call   1003e9 <__panic>
  1031de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031e1:	05 00 00 00 40       	add    $0x40000000,%eax
  1031e6:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1031eb:	e8 8e f9 ff ff       	call   102b7e <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1031f0:	e8 73 fa ff ff       	call   102c68 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1031f5:	e8 4f 02 00 00       	call   103449 <check_alloc_page>

    check_pgdir();
  1031fa:	e8 69 02 00 00       	call   103468 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1031ff:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103204:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103207:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10320e:	77 23                	ja     103233 <pmm_init+0x8f>
  103210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103213:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103217:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  10321e:	00 
  10321f:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  103226:	00 
  103227:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10322e:	e8 b6 d1 ff ff       	call   1003e9 <__panic>
  103233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103236:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10323c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103241:	05 ac 0f 00 00       	add    $0xfac,%eax
  103246:	83 ca 03             	or     $0x3,%edx
  103249:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10324b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103250:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  103257:	00 
  103258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10325f:	00 
  103260:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  103267:	38 
  103268:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10326f:	c0 
  103270:	89 04 24             	mov    %eax,(%esp)
  103273:	e8 e5 fd ff ff       	call   10305d <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103278:	e8 18 f8 ff ff       	call   102a95 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10327d:	e8 82 08 00 00       	call   103b04 <check_boot_pgdir>

    print_pgdir();
  103282:	e8 fb 0c 00 00       	call   103f82 <print_pgdir>

}
  103287:	90                   	nop
  103288:	c9                   	leave  
  103289:	c3                   	ret    

0010328a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10328a:	55                   	push   %ebp
  10328b:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  10328d:	90                   	nop
  10328e:	5d                   	pop    %ebp
  10328f:	c3                   	ret    

00103290 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103290:	55                   	push   %ebp
  103291:	89 e5                	mov    %esp,%ebp
  103293:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103296:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10329d:	00 
  10329e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1032a8:	89 04 24             	mov    %eax,(%esp)
  1032ab:	e8 da ff ff ff       	call   10328a <get_pte>
  1032b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1032b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032b7:	74 08                	je     1032c1 <get_page+0x31>
        *ptep_store = ptep;
  1032b9:	8b 45 10             	mov    0x10(%ebp),%eax
  1032bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1032bf:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1032c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032c5:	74 1b                	je     1032e2 <get_page+0x52>
  1032c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032ca:	8b 00                	mov    (%eax),%eax
  1032cc:	83 e0 01             	and    $0x1,%eax
  1032cf:	85 c0                	test   %eax,%eax
  1032d1:	74 0f                	je     1032e2 <get_page+0x52>
        return pte2page(*ptep);
  1032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032d6:	8b 00                	mov    (%eax),%eax
  1032d8:	89 04 24             	mov    %eax,(%esp)
  1032db:	e8 a5 f6 ff ff       	call   102985 <pte2page>
  1032e0:	eb 05                	jmp    1032e7 <get_page+0x57>
    }
    return NULL;
  1032e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1032e7:	c9                   	leave  
  1032e8:	c3                   	ret    

001032e9 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1032e9:	55                   	push   %ebp
  1032ea:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  1032ec:	90                   	nop
  1032ed:	5d                   	pop    %ebp
  1032ee:	c3                   	ret    

001032ef <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1032ef:	55                   	push   %ebp
  1032f0:	89 e5                	mov    %esp,%ebp
  1032f2:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1032f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1032fc:	00 
  1032fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  103300:	89 44 24 04          	mov    %eax,0x4(%esp)
  103304:	8b 45 08             	mov    0x8(%ebp),%eax
  103307:	89 04 24             	mov    %eax,(%esp)
  10330a:	e8 7b ff ff ff       	call   10328a <get_pte>
  10330f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
  103312:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  103316:	74 19                	je     103331 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  103318:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10331b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10331f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103322:	89 44 24 04          	mov    %eax,0x4(%esp)
  103326:	8b 45 08             	mov    0x8(%ebp),%eax
  103329:	89 04 24             	mov    %eax,(%esp)
  10332c:	e8 b8 ff ff ff       	call   1032e9 <page_remove_pte>
    }
}
  103331:	90                   	nop
  103332:	c9                   	leave  
  103333:	c3                   	ret    

00103334 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103334:	55                   	push   %ebp
  103335:	89 e5                	mov    %esp,%ebp
  103337:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10333a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103341:	00 
  103342:	8b 45 10             	mov    0x10(%ebp),%eax
  103345:	89 44 24 04          	mov    %eax,0x4(%esp)
  103349:	8b 45 08             	mov    0x8(%ebp),%eax
  10334c:	89 04 24             	mov    %eax,(%esp)
  10334f:	e8 36 ff ff ff       	call   10328a <get_pte>
  103354:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10335b:	75 0a                	jne    103367 <page_insert+0x33>
        return -E_NO_MEM;
  10335d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103362:	e9 84 00 00 00       	jmp    1033eb <page_insert+0xb7>
    }
    page_ref_inc(page);
  103367:	8b 45 0c             	mov    0xc(%ebp),%eax
  10336a:	89 04 24             	mov    %eax,(%esp)
  10336d:	e8 73 f6 ff ff       	call   1029e5 <page_ref_inc>
    if (*ptep & PTE_P) {
  103372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103375:	8b 00                	mov    (%eax),%eax
  103377:	83 e0 01             	and    $0x1,%eax
  10337a:	85 c0                	test   %eax,%eax
  10337c:	74 3e                	je     1033bc <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10337e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103381:	8b 00                	mov    (%eax),%eax
  103383:	89 04 24             	mov    %eax,(%esp)
  103386:	e8 fa f5 ff ff       	call   102985 <pte2page>
  10338b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10338e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103391:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103394:	75 0d                	jne    1033a3 <page_insert+0x6f>
            page_ref_dec(page);
  103396:	8b 45 0c             	mov    0xc(%ebp),%eax
  103399:	89 04 24             	mov    %eax,(%esp)
  10339c:	e8 5b f6 ff ff       	call   1029fc <page_ref_dec>
  1033a1:	eb 19                	jmp    1033bc <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1033aa:	8b 45 10             	mov    0x10(%ebp),%eax
  1033ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1033b4:	89 04 24             	mov    %eax,(%esp)
  1033b7:	e8 2d ff ff ff       	call   1032e9 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1033bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033bf:	89 04 24             	mov    %eax,(%esp)
  1033c2:	e8 05 f5 ff ff       	call   1028cc <page2pa>
  1033c7:	0b 45 14             	or     0x14(%ebp),%eax
  1033ca:	83 c8 01             	or     $0x1,%eax
  1033cd:	89 c2                	mov    %eax,%edx
  1033cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033d2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1033d4:	8b 45 10             	mov    0x10(%ebp),%eax
  1033d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033db:	8b 45 08             	mov    0x8(%ebp),%eax
  1033de:	89 04 24             	mov    %eax,(%esp)
  1033e1:	e8 07 00 00 00       	call   1033ed <tlb_invalidate>
    return 0;
  1033e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1033eb:	c9                   	leave  
  1033ec:	c3                   	ret    

001033ed <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1033ed:	55                   	push   %ebp
  1033ee:	89 e5                	mov    %esp,%ebp
  1033f0:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1033f3:	0f 20 d8             	mov    %cr3,%eax
  1033f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1033f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1033fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103402:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103409:	77 23                	ja     10342e <tlb_invalidate+0x41>
  10340b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10340e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103412:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  103419:	00 
  10341a:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  103421:	00 
  103422:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103429:	e8 bb cf ff ff       	call   1003e9 <__panic>
  10342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103431:	05 00 00 00 40       	add    $0x40000000,%eax
  103436:	39 d0                	cmp    %edx,%eax
  103438:	75 0c                	jne    103446 <tlb_invalidate+0x59>
        invlpg((void *)la);
  10343a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10343d:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103440:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103443:	0f 01 38             	invlpg (%eax)
    }
}
  103446:	90                   	nop
  103447:	c9                   	leave  
  103448:	c3                   	ret    

00103449 <check_alloc_page>:

static void
check_alloc_page(void) {
  103449:	55                   	push   %ebp
  10344a:	89 e5                	mov    %esp,%ebp
  10344c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10344f:	a1 10 af 11 00       	mov    0x11af10,%eax
  103454:	8b 40 18             	mov    0x18(%eax),%eax
  103457:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103459:	c7 04 24 e8 66 10 00 	movl   $0x1066e8,(%esp)
  103460:	e8 2d ce ff ff       	call   100292 <cprintf>
}
  103465:	90                   	nop
  103466:	c9                   	leave  
  103467:	c3                   	ret    

00103468 <check_pgdir>:

static void
check_pgdir(void) {
  103468:	55                   	push   %ebp
  103469:	89 e5                	mov    %esp,%ebp
  10346b:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10346e:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103473:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103478:	76 24                	jbe    10349e <check_pgdir+0x36>
  10347a:	c7 44 24 0c 07 67 10 	movl   $0x106707,0xc(%esp)
  103481:	00 
  103482:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103489:	00 
  10348a:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  103491:	00 
  103492:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103499:	e8 4b cf ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10349e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1034a3:	85 c0                	test   %eax,%eax
  1034a5:	74 0e                	je     1034b5 <check_pgdir+0x4d>
  1034a7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1034ac:	25 ff 0f 00 00       	and    $0xfff,%eax
  1034b1:	85 c0                	test   %eax,%eax
  1034b3:	74 24                	je     1034d9 <check_pgdir+0x71>
  1034b5:	c7 44 24 0c 24 67 10 	movl   $0x106724,0xc(%esp)
  1034bc:	00 
  1034bd:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1034c4:	00 
  1034c5:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  1034cc:	00 
  1034cd:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1034d4:	e8 10 cf ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1034d9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1034de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1034e5:	00 
  1034e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1034ed:	00 
  1034ee:	89 04 24             	mov    %eax,(%esp)
  1034f1:	e8 9a fd ff ff       	call   103290 <get_page>
  1034f6:	85 c0                	test   %eax,%eax
  1034f8:	74 24                	je     10351e <check_pgdir+0xb6>
  1034fa:	c7 44 24 0c 5c 67 10 	movl   $0x10675c,0xc(%esp)
  103501:	00 
  103502:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103509:	00 
  10350a:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  103511:	00 
  103512:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103519:	e8 cb ce ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10351e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103525:	e8 a8 f6 ff ff       	call   102bd2 <alloc_pages>
  10352a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10352d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103532:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103539:	00 
  10353a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103541:	00 
  103542:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103545:	89 54 24 04          	mov    %edx,0x4(%esp)
  103549:	89 04 24             	mov    %eax,(%esp)
  10354c:	e8 e3 fd ff ff       	call   103334 <page_insert>
  103551:	85 c0                	test   %eax,%eax
  103553:	74 24                	je     103579 <check_pgdir+0x111>
  103555:	c7 44 24 0c 84 67 10 	movl   $0x106784,0xc(%esp)
  10355c:	00 
  10355d:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103564:	00 
  103565:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  10356c:	00 
  10356d:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103574:	e8 70 ce ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103579:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10357e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103585:	00 
  103586:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10358d:	00 
  10358e:	89 04 24             	mov    %eax,(%esp)
  103591:	e8 f4 fc ff ff       	call   10328a <get_pte>
  103596:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103599:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10359d:	75 24                	jne    1035c3 <check_pgdir+0x15b>
  10359f:	c7 44 24 0c b0 67 10 	movl   $0x1067b0,0xc(%esp)
  1035a6:	00 
  1035a7:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1035ae:	00 
  1035af:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  1035b6:	00 
  1035b7:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1035be:	e8 26 ce ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  1035c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035c6:	8b 00                	mov    (%eax),%eax
  1035c8:	89 04 24             	mov    %eax,(%esp)
  1035cb:	e8 b5 f3 ff ff       	call   102985 <pte2page>
  1035d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1035d3:	74 24                	je     1035f9 <check_pgdir+0x191>
  1035d5:	c7 44 24 0c dd 67 10 	movl   $0x1067dd,0xc(%esp)
  1035dc:	00 
  1035dd:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1035e4:	00 
  1035e5:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  1035ec:	00 
  1035ed:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1035f4:	e8 f0 cd ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  1035f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035fc:	89 04 24             	mov    %eax,(%esp)
  1035ff:	e8 d7 f3 ff ff       	call   1029db <page_ref>
  103604:	83 f8 01             	cmp    $0x1,%eax
  103607:	74 24                	je     10362d <check_pgdir+0x1c5>
  103609:	c7 44 24 0c f3 67 10 	movl   $0x1067f3,0xc(%esp)
  103610:	00 
  103611:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103618:	00 
  103619:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  103620:	00 
  103621:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103628:	e8 bc cd ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10362d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103632:	8b 00                	mov    (%eax),%eax
  103634:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103639:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10363c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10363f:	c1 e8 0c             	shr    $0xc,%eax
  103642:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103645:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10364a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10364d:	72 23                	jb     103672 <check_pgdir+0x20a>
  10364f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103652:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103656:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  10365d:	00 
  10365e:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  103665:	00 
  103666:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10366d:	e8 77 cd ff ff       	call   1003e9 <__panic>
  103672:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103675:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10367a:	83 c0 04             	add    $0x4,%eax
  10367d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103680:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103685:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10368c:	00 
  10368d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103694:	00 
  103695:	89 04 24             	mov    %eax,(%esp)
  103698:	e8 ed fb ff ff       	call   10328a <get_pte>
  10369d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1036a0:	74 24                	je     1036c6 <check_pgdir+0x25e>
  1036a2:	c7 44 24 0c 08 68 10 	movl   $0x106808,0xc(%esp)
  1036a9:	00 
  1036aa:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1036b1:	00 
  1036b2:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  1036b9:	00 
  1036ba:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1036c1:	e8 23 cd ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  1036c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036cd:	e8 00 f5 ff ff       	call   102bd2 <alloc_pages>
  1036d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1036d5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036da:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1036e1:	00 
  1036e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1036e9:	00 
  1036ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1036ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  1036f1:	89 04 24             	mov    %eax,(%esp)
  1036f4:	e8 3b fc ff ff       	call   103334 <page_insert>
  1036f9:	85 c0                	test   %eax,%eax
  1036fb:	74 24                	je     103721 <check_pgdir+0x2b9>
  1036fd:	c7 44 24 0c 30 68 10 	movl   $0x106830,0xc(%esp)
  103704:	00 
  103705:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10370c:	00 
  10370d:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  103714:	00 
  103715:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10371c:	e8 c8 cc ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103721:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103726:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10372d:	00 
  10372e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103735:	00 
  103736:	89 04 24             	mov    %eax,(%esp)
  103739:	e8 4c fb ff ff       	call   10328a <get_pte>
  10373e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103741:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103745:	75 24                	jne    10376b <check_pgdir+0x303>
  103747:	c7 44 24 0c 68 68 10 	movl   $0x106868,0xc(%esp)
  10374e:	00 
  10374f:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103756:	00 
  103757:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  10375e:	00 
  10375f:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103766:	e8 7e cc ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  10376b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10376e:	8b 00                	mov    (%eax),%eax
  103770:	83 e0 04             	and    $0x4,%eax
  103773:	85 c0                	test   %eax,%eax
  103775:	75 24                	jne    10379b <check_pgdir+0x333>
  103777:	c7 44 24 0c 98 68 10 	movl   $0x106898,0xc(%esp)
  10377e:	00 
  10377f:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103786:	00 
  103787:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  10378e:	00 
  10378f:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103796:	e8 4e cc ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  10379b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10379e:	8b 00                	mov    (%eax),%eax
  1037a0:	83 e0 02             	and    $0x2,%eax
  1037a3:	85 c0                	test   %eax,%eax
  1037a5:	75 24                	jne    1037cb <check_pgdir+0x363>
  1037a7:	c7 44 24 0c a6 68 10 	movl   $0x1068a6,0xc(%esp)
  1037ae:	00 
  1037af:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1037b6:	00 
  1037b7:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  1037be:	00 
  1037bf:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1037c6:	e8 1e cc ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  1037cb:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037d0:	8b 00                	mov    (%eax),%eax
  1037d2:	83 e0 04             	and    $0x4,%eax
  1037d5:	85 c0                	test   %eax,%eax
  1037d7:	75 24                	jne    1037fd <check_pgdir+0x395>
  1037d9:	c7 44 24 0c b4 68 10 	movl   $0x1068b4,0xc(%esp)
  1037e0:	00 
  1037e1:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1037e8:	00 
  1037e9:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  1037f0:	00 
  1037f1:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1037f8:	e8 ec cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  1037fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103800:	89 04 24             	mov    %eax,(%esp)
  103803:	e8 d3 f1 ff ff       	call   1029db <page_ref>
  103808:	83 f8 01             	cmp    $0x1,%eax
  10380b:	74 24                	je     103831 <check_pgdir+0x3c9>
  10380d:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  103814:	00 
  103815:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10381c:	00 
  10381d:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  103824:	00 
  103825:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10382c:	e8 b8 cb ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103831:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103836:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10383d:	00 
  10383e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103845:	00 
  103846:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103849:	89 54 24 04          	mov    %edx,0x4(%esp)
  10384d:	89 04 24             	mov    %eax,(%esp)
  103850:	e8 df fa ff ff       	call   103334 <page_insert>
  103855:	85 c0                	test   %eax,%eax
  103857:	74 24                	je     10387d <check_pgdir+0x415>
  103859:	c7 44 24 0c dc 68 10 	movl   $0x1068dc,0xc(%esp)
  103860:	00 
  103861:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103868:	00 
  103869:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  103870:	00 
  103871:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103878:	e8 6c cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  10387d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103880:	89 04 24             	mov    %eax,(%esp)
  103883:	e8 53 f1 ff ff       	call   1029db <page_ref>
  103888:	83 f8 02             	cmp    $0x2,%eax
  10388b:	74 24                	je     1038b1 <check_pgdir+0x449>
  10388d:	c7 44 24 0c 08 69 10 	movl   $0x106908,0xc(%esp)
  103894:	00 
  103895:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10389c:	00 
  10389d:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  1038a4:	00 
  1038a5:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1038ac:	e8 38 cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  1038b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038b4:	89 04 24             	mov    %eax,(%esp)
  1038b7:	e8 1f f1 ff ff       	call   1029db <page_ref>
  1038bc:	85 c0                	test   %eax,%eax
  1038be:	74 24                	je     1038e4 <check_pgdir+0x47c>
  1038c0:	c7 44 24 0c 1a 69 10 	movl   $0x10691a,0xc(%esp)
  1038c7:	00 
  1038c8:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1038cf:	00 
  1038d0:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  1038d7:	00 
  1038d8:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1038df:	e8 05 cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1038e4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1038e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038f0:	00 
  1038f1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1038f8:	00 
  1038f9:	89 04 24             	mov    %eax,(%esp)
  1038fc:	e8 89 f9 ff ff       	call   10328a <get_pte>
  103901:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103904:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103908:	75 24                	jne    10392e <check_pgdir+0x4c6>
  10390a:	c7 44 24 0c 68 68 10 	movl   $0x106868,0xc(%esp)
  103911:	00 
  103912:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103919:	00 
  10391a:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103921:	00 
  103922:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103929:	e8 bb ca ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  10392e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103931:	8b 00                	mov    (%eax),%eax
  103933:	89 04 24             	mov    %eax,(%esp)
  103936:	e8 4a f0 ff ff       	call   102985 <pte2page>
  10393b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10393e:	74 24                	je     103964 <check_pgdir+0x4fc>
  103940:	c7 44 24 0c dd 67 10 	movl   $0x1067dd,0xc(%esp)
  103947:	00 
  103948:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10394f:	00 
  103950:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103957:	00 
  103958:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10395f:	e8 85 ca ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103964:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103967:	8b 00                	mov    (%eax),%eax
  103969:	83 e0 04             	and    $0x4,%eax
  10396c:	85 c0                	test   %eax,%eax
  10396e:	74 24                	je     103994 <check_pgdir+0x52c>
  103970:	c7 44 24 0c 2c 69 10 	movl   $0x10692c,0xc(%esp)
  103977:	00 
  103978:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  10397f:	00 
  103980:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103987:	00 
  103988:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  10398f:	e8 55 ca ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103994:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103999:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1039a0:	00 
  1039a1:	89 04 24             	mov    %eax,(%esp)
  1039a4:	e8 46 f9 ff ff       	call   1032ef <page_remove>
    assert(page_ref(p1) == 1);
  1039a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039ac:	89 04 24             	mov    %eax,(%esp)
  1039af:	e8 27 f0 ff ff       	call   1029db <page_ref>
  1039b4:	83 f8 01             	cmp    $0x1,%eax
  1039b7:	74 24                	je     1039dd <check_pgdir+0x575>
  1039b9:	c7 44 24 0c f3 67 10 	movl   $0x1067f3,0xc(%esp)
  1039c0:	00 
  1039c1:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1039c8:	00 
  1039c9:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  1039d0:	00 
  1039d1:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  1039d8:	e8 0c ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  1039dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039e0:	89 04 24             	mov    %eax,(%esp)
  1039e3:	e8 f3 ef ff ff       	call   1029db <page_ref>
  1039e8:	85 c0                	test   %eax,%eax
  1039ea:	74 24                	je     103a10 <check_pgdir+0x5a8>
  1039ec:	c7 44 24 0c 1a 69 10 	movl   $0x10691a,0xc(%esp)
  1039f3:	00 
  1039f4:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  1039fb:	00 
  1039fc:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  103a03:	00 
  103a04:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103a0b:	e8 d9 c9 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103a10:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a15:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a1c:	00 
  103a1d:	89 04 24             	mov    %eax,(%esp)
  103a20:	e8 ca f8 ff ff       	call   1032ef <page_remove>
    assert(page_ref(p1) == 0);
  103a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a28:	89 04 24             	mov    %eax,(%esp)
  103a2b:	e8 ab ef ff ff       	call   1029db <page_ref>
  103a30:	85 c0                	test   %eax,%eax
  103a32:	74 24                	je     103a58 <check_pgdir+0x5f0>
  103a34:	c7 44 24 0c 41 69 10 	movl   $0x106941,0xc(%esp)
  103a3b:	00 
  103a3c:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103a43:	00 
  103a44:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103a4b:	00 
  103a4c:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103a53:	e8 91 c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a5b:	89 04 24             	mov    %eax,(%esp)
  103a5e:	e8 78 ef ff ff       	call   1029db <page_ref>
  103a63:	85 c0                	test   %eax,%eax
  103a65:	74 24                	je     103a8b <check_pgdir+0x623>
  103a67:	c7 44 24 0c 1a 69 10 	movl   $0x10691a,0xc(%esp)
  103a6e:	00 
  103a6f:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103a76:	00 
  103a77:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103a7e:	00 
  103a7f:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103a86:	e8 5e c9 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103a8b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a90:	8b 00                	mov    (%eax),%eax
  103a92:	89 04 24             	mov    %eax,(%esp)
  103a95:	e8 29 ef ff ff       	call   1029c3 <pde2page>
  103a9a:	89 04 24             	mov    %eax,(%esp)
  103a9d:	e8 39 ef ff ff       	call   1029db <page_ref>
  103aa2:	83 f8 01             	cmp    $0x1,%eax
  103aa5:	74 24                	je     103acb <check_pgdir+0x663>
  103aa7:	c7 44 24 0c 54 69 10 	movl   $0x106954,0xc(%esp)
  103aae:	00 
  103aaf:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103ab6:	00 
  103ab7:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103abe:	00 
  103abf:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103ac6:	e8 1e c9 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103acb:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ad0:	8b 00                	mov    (%eax),%eax
  103ad2:	89 04 24             	mov    %eax,(%esp)
  103ad5:	e8 e9 ee ff ff       	call   1029c3 <pde2page>
  103ada:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ae1:	00 
  103ae2:	89 04 24             	mov    %eax,(%esp)
  103ae5:	e8 20 f1 ff ff       	call   102c0a <free_pages>
    boot_pgdir[0] = 0;
  103aea:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103aef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103af5:	c7 04 24 7b 69 10 00 	movl   $0x10697b,(%esp)
  103afc:	e8 91 c7 ff ff       	call   100292 <cprintf>
}
  103b01:	90                   	nop
  103b02:	c9                   	leave  
  103b03:	c3                   	ret    

00103b04 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103b04:	55                   	push   %ebp
  103b05:	89 e5                	mov    %esp,%ebp
  103b07:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103b0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103b11:	e9 ca 00 00 00       	jmp    103be0 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b1f:	c1 e8 0c             	shr    $0xc,%eax
  103b22:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103b25:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b2a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103b2d:	72 23                	jb     103b52 <check_boot_pgdir+0x4e>
  103b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b36:	c7 44 24 08 c0 65 10 	movl   $0x1065c0,0x8(%esp)
  103b3d:	00 
  103b3e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103b45:	00 
  103b46:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103b4d:	e8 97 c8 ff ff       	call   1003e9 <__panic>
  103b52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b55:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103b5a:	89 c2                	mov    %eax,%edx
  103b5c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103b68:	00 
  103b69:	89 54 24 04          	mov    %edx,0x4(%esp)
  103b6d:	89 04 24             	mov    %eax,(%esp)
  103b70:	e8 15 f7 ff ff       	call   10328a <get_pte>
  103b75:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103b78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103b7c:	75 24                	jne    103ba2 <check_boot_pgdir+0x9e>
  103b7e:	c7 44 24 0c 98 69 10 	movl   $0x106998,0xc(%esp)
  103b85:	00 
  103b86:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103b8d:	00 
  103b8e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103b95:	00 
  103b96:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103b9d:	e8 47 c8 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103ba2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103ba5:	8b 00                	mov    (%eax),%eax
  103ba7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103bac:	89 c2                	mov    %eax,%edx
  103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bb1:	39 c2                	cmp    %eax,%edx
  103bb3:	74 24                	je     103bd9 <check_boot_pgdir+0xd5>
  103bb5:	c7 44 24 0c d5 69 10 	movl   $0x1069d5,0xc(%esp)
  103bbc:	00 
  103bbd:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103bc4:	00 
  103bc5:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103bcc:	00 
  103bcd:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103bd4:	e8 10 c8 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103bd9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103be0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103be3:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103be8:	39 c2                	cmp    %eax,%edx
  103bea:	0f 82 26 ff ff ff    	jb     103b16 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103bf0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103bf5:	05 ac 0f 00 00       	add    $0xfac,%eax
  103bfa:	8b 00                	mov    (%eax),%eax
  103bfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c01:	89 c2                	mov    %eax,%edx
  103c03:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c0b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103c12:	77 23                	ja     103c37 <check_boot_pgdir+0x133>
  103c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c1b:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  103c22:	00 
  103c23:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103c2a:	00 
  103c2b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103c32:	e8 b2 c7 ff ff       	call   1003e9 <__panic>
  103c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c3a:	05 00 00 00 40       	add    $0x40000000,%eax
  103c3f:	39 d0                	cmp    %edx,%eax
  103c41:	74 24                	je     103c67 <check_boot_pgdir+0x163>
  103c43:	c7 44 24 0c ec 69 10 	movl   $0x1069ec,0xc(%esp)
  103c4a:	00 
  103c4b:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103c52:	00 
  103c53:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103c5a:	00 
  103c5b:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103c62:	e8 82 c7 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103c67:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c6c:	8b 00                	mov    (%eax),%eax
  103c6e:	85 c0                	test   %eax,%eax
  103c70:	74 24                	je     103c96 <check_boot_pgdir+0x192>
  103c72:	c7 44 24 0c 20 6a 10 	movl   $0x106a20,0xc(%esp)
  103c79:	00 
  103c7a:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103c81:	00 
  103c82:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103c89:	00 
  103c8a:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103c91:	e8 53 c7 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103c9d:	e8 30 ef ff ff       	call   102bd2 <alloc_pages>
  103ca2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103ca5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103caa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103cb1:	00 
  103cb2:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103cb9:	00 
  103cba:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103cbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103cc1:	89 04 24             	mov    %eax,(%esp)
  103cc4:	e8 6b f6 ff ff       	call   103334 <page_insert>
  103cc9:	85 c0                	test   %eax,%eax
  103ccb:	74 24                	je     103cf1 <check_boot_pgdir+0x1ed>
  103ccd:	c7 44 24 0c 34 6a 10 	movl   $0x106a34,0xc(%esp)
  103cd4:	00 
  103cd5:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103cdc:	00 
  103cdd:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103ce4:	00 
  103ce5:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103cec:	e8 f8 c6 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103cf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103cf4:	89 04 24             	mov    %eax,(%esp)
  103cf7:	e8 df ec ff ff       	call   1029db <page_ref>
  103cfc:	83 f8 01             	cmp    $0x1,%eax
  103cff:	74 24                	je     103d25 <check_boot_pgdir+0x221>
  103d01:	c7 44 24 0c 62 6a 10 	movl   $0x106a62,0xc(%esp)
  103d08:	00 
  103d09:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103d10:	00 
  103d11:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103d18:	00 
  103d19:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103d20:	e8 c4 c6 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103d25:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d2a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103d31:	00 
  103d32:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103d39:	00 
  103d3a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103d3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d41:	89 04 24             	mov    %eax,(%esp)
  103d44:	e8 eb f5 ff ff       	call   103334 <page_insert>
  103d49:	85 c0                	test   %eax,%eax
  103d4b:	74 24                	je     103d71 <check_boot_pgdir+0x26d>
  103d4d:	c7 44 24 0c 74 6a 10 	movl   $0x106a74,0xc(%esp)
  103d54:	00 
  103d55:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103d5c:	00 
  103d5d:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103d64:	00 
  103d65:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103d6c:	e8 78 c6 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103d71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103d74:	89 04 24             	mov    %eax,(%esp)
  103d77:	e8 5f ec ff ff       	call   1029db <page_ref>
  103d7c:	83 f8 02             	cmp    $0x2,%eax
  103d7f:	74 24                	je     103da5 <check_boot_pgdir+0x2a1>
  103d81:	c7 44 24 0c ab 6a 10 	movl   $0x106aab,0xc(%esp)
  103d88:	00 
  103d89:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103d90:	00 
  103d91:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103d98:	00 
  103d99:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103da0:	e8 44 c6 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103da5:	c7 45 e8 bc 6a 10 00 	movl   $0x106abc,-0x18(%ebp)
    strcpy((void *)0x100, str);
  103dac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103daf:	89 44 24 04          	mov    %eax,0x4(%esp)
  103db3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103dba:	e8 e1 15 00 00       	call   1053a0 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103dbf:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103dc6:	00 
  103dc7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103dce:	e8 44 16 00 00       	call   105417 <strcmp>
  103dd3:	85 c0                	test   %eax,%eax
  103dd5:	74 24                	je     103dfb <check_boot_pgdir+0x2f7>
  103dd7:	c7 44 24 0c d4 6a 10 	movl   $0x106ad4,0xc(%esp)
  103dde:	00 
  103ddf:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103de6:	00 
  103de7:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  103dee:	00 
  103def:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103df6:	e8 ee c5 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103dfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103dfe:	89 04 24             	mov    %eax,(%esp)
  103e01:	e8 2b eb ff ff       	call   102931 <page2kva>
  103e06:	05 00 01 00 00       	add    $0x100,%eax
  103e0b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103e0e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103e15:	e8 30 15 00 00       	call   10534a <strlen>
  103e1a:	85 c0                	test   %eax,%eax
  103e1c:	74 24                	je     103e42 <check_boot_pgdir+0x33e>
  103e1e:	c7 44 24 0c 0c 6b 10 	movl   $0x106b0c,0xc(%esp)
  103e25:	00 
  103e26:	c7 44 24 08 ad 66 10 	movl   $0x1066ad,0x8(%esp)
  103e2d:	00 
  103e2e:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  103e35:	00 
  103e36:	c7 04 24 88 66 10 00 	movl   $0x106688,(%esp)
  103e3d:	e8 a7 c5 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103e42:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e49:	00 
  103e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e4d:	89 04 24             	mov    %eax,(%esp)
  103e50:	e8 b5 ed ff ff       	call   102c0a <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103e55:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e5a:	8b 00                	mov    (%eax),%eax
  103e5c:	89 04 24             	mov    %eax,(%esp)
  103e5f:	e8 5f eb ff ff       	call   1029c3 <pde2page>
  103e64:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e6b:	00 
  103e6c:	89 04 24             	mov    %eax,(%esp)
  103e6f:	e8 96 ed ff ff       	call   102c0a <free_pages>
    boot_pgdir[0] = 0;
  103e74:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103e7f:	c7 04 24 30 6b 10 00 	movl   $0x106b30,(%esp)
  103e86:	e8 07 c4 ff ff       	call   100292 <cprintf>
}
  103e8b:	90                   	nop
  103e8c:	c9                   	leave  
  103e8d:	c3                   	ret    

00103e8e <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103e8e:	55                   	push   %ebp
  103e8f:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103e91:	8b 45 08             	mov    0x8(%ebp),%eax
  103e94:	83 e0 04             	and    $0x4,%eax
  103e97:	85 c0                	test   %eax,%eax
  103e99:	74 04                	je     103e9f <perm2str+0x11>
  103e9b:	b0 75                	mov    $0x75,%al
  103e9d:	eb 02                	jmp    103ea1 <perm2str+0x13>
  103e9f:	b0 2d                	mov    $0x2d,%al
  103ea1:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  103ea6:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103ead:	8b 45 08             	mov    0x8(%ebp),%eax
  103eb0:	83 e0 02             	and    $0x2,%eax
  103eb3:	85 c0                	test   %eax,%eax
  103eb5:	74 04                	je     103ebb <perm2str+0x2d>
  103eb7:	b0 77                	mov    $0x77,%al
  103eb9:	eb 02                	jmp    103ebd <perm2str+0x2f>
  103ebb:	b0 2d                	mov    $0x2d,%al
  103ebd:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  103ec2:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  103ec9:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  103ece:	5d                   	pop    %ebp
  103ecf:	c3                   	ret    

00103ed0 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  103ed0:	55                   	push   %ebp
  103ed1:	89 e5                	mov    %esp,%ebp
  103ed3:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  103ed6:	8b 45 10             	mov    0x10(%ebp),%eax
  103ed9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103edc:	72 0d                	jb     103eeb <get_pgtable_items+0x1b>
        return 0;
  103ede:	b8 00 00 00 00       	mov    $0x0,%eax
  103ee3:	e9 98 00 00 00       	jmp    103f80 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  103ee8:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  103eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  103eee:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103ef1:	73 18                	jae    103f0b <get_pgtable_items+0x3b>
  103ef3:	8b 45 10             	mov    0x10(%ebp),%eax
  103ef6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103efd:	8b 45 14             	mov    0x14(%ebp),%eax
  103f00:	01 d0                	add    %edx,%eax
  103f02:	8b 00                	mov    (%eax),%eax
  103f04:	83 e0 01             	and    $0x1,%eax
  103f07:	85 c0                	test   %eax,%eax
  103f09:	74 dd                	je     103ee8 <get_pgtable_items+0x18>
    }
    if (start < right) {
  103f0b:	8b 45 10             	mov    0x10(%ebp),%eax
  103f0e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f11:	73 68                	jae    103f7b <get_pgtable_items+0xab>
        if (left_store != NULL) {
  103f13:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  103f17:	74 08                	je     103f21 <get_pgtable_items+0x51>
            *left_store = start;
  103f19:	8b 45 18             	mov    0x18(%ebp),%eax
  103f1c:	8b 55 10             	mov    0x10(%ebp),%edx
  103f1f:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  103f21:	8b 45 10             	mov    0x10(%ebp),%eax
  103f24:	8d 50 01             	lea    0x1(%eax),%edx
  103f27:	89 55 10             	mov    %edx,0x10(%ebp)
  103f2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103f31:	8b 45 14             	mov    0x14(%ebp),%eax
  103f34:	01 d0                	add    %edx,%eax
  103f36:	8b 00                	mov    (%eax),%eax
  103f38:	83 e0 07             	and    $0x7,%eax
  103f3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103f3e:	eb 03                	jmp    103f43 <get_pgtable_items+0x73>
            start ++;
  103f40:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103f43:	8b 45 10             	mov    0x10(%ebp),%eax
  103f46:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f49:	73 1d                	jae    103f68 <get_pgtable_items+0x98>
  103f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  103f4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103f55:	8b 45 14             	mov    0x14(%ebp),%eax
  103f58:	01 d0                	add    %edx,%eax
  103f5a:	8b 00                	mov    (%eax),%eax
  103f5c:	83 e0 07             	and    $0x7,%eax
  103f5f:	89 c2                	mov    %eax,%edx
  103f61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103f64:	39 c2                	cmp    %eax,%edx
  103f66:	74 d8                	je     103f40 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  103f68:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103f6c:	74 08                	je     103f76 <get_pgtable_items+0xa6>
            *right_store = start;
  103f6e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  103f71:	8b 55 10             	mov    0x10(%ebp),%edx
  103f74:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  103f76:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103f79:	eb 05                	jmp    103f80 <get_pgtable_items+0xb0>
    }
    return 0;
  103f7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103f80:	c9                   	leave  
  103f81:	c3                   	ret    

00103f82 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  103f82:	55                   	push   %ebp
  103f83:	89 e5                	mov    %esp,%ebp
  103f85:	57                   	push   %edi
  103f86:	56                   	push   %esi
  103f87:	53                   	push   %ebx
  103f88:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  103f8b:	c7 04 24 50 6b 10 00 	movl   $0x106b50,(%esp)
  103f92:	e8 fb c2 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  103f97:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  103f9e:	e9 fa 00 00 00       	jmp    10409d <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  103fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103fa6:	89 04 24             	mov    %eax,(%esp)
  103fa9:	e8 e0 fe ff ff       	call   103e8e <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  103fae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  103fb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103fb4:	29 d1                	sub    %edx,%ecx
  103fb6:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  103fb8:	89 d6                	mov    %edx,%esi
  103fba:	c1 e6 16             	shl    $0x16,%esi
  103fbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fc0:	89 d3                	mov    %edx,%ebx
  103fc2:	c1 e3 16             	shl    $0x16,%ebx
  103fc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103fc8:	89 d1                	mov    %edx,%ecx
  103fca:	c1 e1 16             	shl    $0x16,%ecx
  103fcd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  103fd0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103fd3:	29 d7                	sub    %edx,%edi
  103fd5:	89 fa                	mov    %edi,%edx
  103fd7:	89 44 24 14          	mov    %eax,0x14(%esp)
  103fdb:	89 74 24 10          	mov    %esi,0x10(%esp)
  103fdf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103fe3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103fe7:	89 54 24 04          	mov    %edx,0x4(%esp)
  103feb:	c7 04 24 81 6b 10 00 	movl   $0x106b81,(%esp)
  103ff2:	e8 9b c2 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  103ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103ffa:	c1 e0 0a             	shl    $0xa,%eax
  103ffd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104000:	eb 54                	jmp    104056 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104002:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104005:	89 04 24             	mov    %eax,(%esp)
  104008:	e8 81 fe ff ff       	call   103e8e <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10400d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104010:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104013:	29 d1                	sub    %edx,%ecx
  104015:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104017:	89 d6                	mov    %edx,%esi
  104019:	c1 e6 0c             	shl    $0xc,%esi
  10401c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10401f:	89 d3                	mov    %edx,%ebx
  104021:	c1 e3 0c             	shl    $0xc,%ebx
  104024:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104027:	89 d1                	mov    %edx,%ecx
  104029:	c1 e1 0c             	shl    $0xc,%ecx
  10402c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10402f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104032:	29 d7                	sub    %edx,%edi
  104034:	89 fa                	mov    %edi,%edx
  104036:	89 44 24 14          	mov    %eax,0x14(%esp)
  10403a:	89 74 24 10          	mov    %esi,0x10(%esp)
  10403e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104042:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104046:	89 54 24 04          	mov    %edx,0x4(%esp)
  10404a:	c7 04 24 a0 6b 10 00 	movl   $0x106ba0,(%esp)
  104051:	e8 3c c2 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104056:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10405b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10405e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104061:	89 d3                	mov    %edx,%ebx
  104063:	c1 e3 0a             	shl    $0xa,%ebx
  104066:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104069:	89 d1                	mov    %edx,%ecx
  10406b:	c1 e1 0a             	shl    $0xa,%ecx
  10406e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104071:	89 54 24 14          	mov    %edx,0x14(%esp)
  104075:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104078:	89 54 24 10          	mov    %edx,0x10(%esp)
  10407c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  104080:	89 44 24 08          	mov    %eax,0x8(%esp)
  104084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104088:	89 0c 24             	mov    %ecx,(%esp)
  10408b:	e8 40 fe ff ff       	call   103ed0 <get_pgtable_items>
  104090:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104093:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104097:	0f 85 65 ff ff ff    	jne    104002 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10409d:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1040a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1040a5:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1040a8:	89 54 24 14          	mov    %edx,0x14(%esp)
  1040ac:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1040af:	89 54 24 10          	mov    %edx,0x10(%esp)
  1040b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1040b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1040bb:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1040c2:	00 
  1040c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1040ca:	e8 01 fe ff ff       	call   103ed0 <get_pgtable_items>
  1040cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1040d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1040d6:	0f 85 c7 fe ff ff    	jne    103fa3 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1040dc:	c7 04 24 c4 6b 10 00 	movl   $0x106bc4,(%esp)
  1040e3:	e8 aa c1 ff ff       	call   100292 <cprintf>
}
  1040e8:	90                   	nop
  1040e9:	83 c4 4c             	add    $0x4c,%esp
  1040ec:	5b                   	pop    %ebx
  1040ed:	5e                   	pop    %esi
  1040ee:	5f                   	pop    %edi
  1040ef:	5d                   	pop    %ebp
  1040f0:	c3                   	ret    

001040f1 <page2ppn>:
page2ppn(struct Page *page) {
  1040f1:	55                   	push   %ebp
  1040f2:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1040f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1040f7:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1040fd:	29 d0                	sub    %edx,%eax
  1040ff:	c1 f8 02             	sar    $0x2,%eax
  104102:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104108:	5d                   	pop    %ebp
  104109:	c3                   	ret    

0010410a <page2pa>:
page2pa(struct Page *page) {
  10410a:	55                   	push   %ebp
  10410b:	89 e5                	mov    %esp,%ebp
  10410d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104110:	8b 45 08             	mov    0x8(%ebp),%eax
  104113:	89 04 24             	mov    %eax,(%esp)
  104116:	e8 d6 ff ff ff       	call   1040f1 <page2ppn>
  10411b:	c1 e0 0c             	shl    $0xc,%eax
}
  10411e:	c9                   	leave  
  10411f:	c3                   	ret    

00104120 <page_ref>:
page_ref(struct Page *page) {
  104120:	55                   	push   %ebp
  104121:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104123:	8b 45 08             	mov    0x8(%ebp),%eax
  104126:	8b 00                	mov    (%eax),%eax
}
  104128:	5d                   	pop    %ebp
  104129:	c3                   	ret    

0010412a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10412a:	55                   	push   %ebp
  10412b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10412d:	8b 45 08             	mov    0x8(%ebp),%eax
  104130:	8b 55 0c             	mov    0xc(%ebp),%edx
  104133:	89 10                	mov    %edx,(%eax)
}
  104135:	90                   	nop
  104136:	5d                   	pop    %ebp
  104137:	c3                   	ret    

00104138 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104138:	55                   	push   %ebp
  104139:	89 e5                	mov    %esp,%ebp
  10413b:	83 ec 10             	sub    $0x10,%esp
  10413e:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104145:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104148:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10414b:	89 50 04             	mov    %edx,0x4(%eax)
  10414e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104151:	8b 50 04             	mov    0x4(%eax),%edx
  104154:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104157:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  104159:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104160:	00 00 00 
}
  104163:	90                   	nop
  104164:	c9                   	leave  
  104165:	c3                   	ret    

00104166 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  104166:	55                   	push   %ebp
  104167:	89 e5                	mov    %esp,%ebp
  104169:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  10416c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104170:	75 24                	jne    104196 <default_init_memmap+0x30>
  104172:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  104179:	00 
  10417a:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104181:	00 
  104182:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  104189:	00 
  10418a:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104191:	e8 53 c2 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  104196:	8b 45 08             	mov    0x8(%ebp),%eax
  104199:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10419c:	eb 7d                	jmp    10421b <default_init_memmap+0xb5>
        assert(PageReserved(p));
  10419e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1041a1:	83 c0 04             	add    $0x4,%eax
  1041a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1041ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1041ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1041b4:	0f a3 10             	bt     %edx,(%eax)
  1041b7:	19 c0                	sbb    %eax,%eax
  1041b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1041bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1041c0:	0f 95 c0             	setne  %al
  1041c3:	0f b6 c0             	movzbl %al,%eax
  1041c6:	85 c0                	test   %eax,%eax
  1041c8:	75 24                	jne    1041ee <default_init_memmap+0x88>
  1041ca:	c7 44 24 0c 29 6c 10 	movl   $0x106c29,0xc(%esp)
  1041d1:	00 
  1041d2:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1041d9:	00 
  1041da:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1041e1:	00 
  1041e2:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1041e9:	e8 fb c1 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  1041ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1041f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1041fb:	8b 50 08             	mov    0x8(%eax),%edx
  1041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104201:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  104204:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10420b:	00 
  10420c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10420f:	89 04 24             	mov    %eax,(%esp)
  104212:	e8 13 ff ff ff       	call   10412a <set_page_ref>
    for (; p != base + n; p ++) {
  104217:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10421b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10421e:	89 d0                	mov    %edx,%eax
  104220:	c1 e0 02             	shl    $0x2,%eax
  104223:	01 d0                	add    %edx,%eax
  104225:	c1 e0 02             	shl    $0x2,%eax
  104228:	89 c2                	mov    %eax,%edx
  10422a:	8b 45 08             	mov    0x8(%ebp),%eax
  10422d:	01 d0                	add    %edx,%eax
  10422f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104232:	0f 85 66 ff ff ff    	jne    10419e <default_init_memmap+0x38>
    }
    base->property = n;
  104238:	8b 45 08             	mov    0x8(%ebp),%eax
  10423b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10423e:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104241:	8b 45 08             	mov    0x8(%ebp),%eax
  104244:	83 c0 04             	add    $0x4,%eax
  104247:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10424e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104251:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104254:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104257:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  10425a:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  104260:	8b 45 0c             	mov    0xc(%ebp),%eax
  104263:	01 d0                	add    %edx,%eax
  104265:	a3 24 af 11 00       	mov    %eax,0x11af24
    list_add_before(&free_list, &(base->page_link));
  10426a:	8b 45 08             	mov    0x8(%ebp),%eax
  10426d:	83 c0 0c             	add    $0xc,%eax
  104270:	c7 45 e4 1c af 11 00 	movl   $0x11af1c,-0x1c(%ebp)
  104277:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10427a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10427d:	8b 00                	mov    (%eax),%eax
  10427f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104282:	89 55 dc             	mov    %edx,-0x24(%ebp)
  104285:	89 45 d8             	mov    %eax,-0x28(%ebp)
  104288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10428b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10428e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104291:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104294:	89 10                	mov    %edx,(%eax)
  104296:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104299:	8b 10                	mov    (%eax),%edx
  10429b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10429e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1042a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042a7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1042aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1042b0:	89 10                	mov    %edx,(%eax)
}
  1042b2:	90                   	nop
  1042b3:	c9                   	leave  
  1042b4:	c3                   	ret    

001042b5 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  1042b5:	55                   	push   %ebp
  1042b6:	89 e5                	mov    %esp,%ebp
  1042b8:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1042bb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1042bf:	75 24                	jne    1042e5 <default_alloc_pages+0x30>
  1042c1:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  1042c8:	00 
  1042c9:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1042d0:	00 
  1042d1:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  1042d8:	00 
  1042d9:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1042e0:	e8 04 c1 ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  1042e5:	a1 24 af 11 00       	mov    0x11af24,%eax
  1042ea:	39 45 08             	cmp    %eax,0x8(%ebp)
  1042ed:	76 0a                	jbe    1042f9 <default_alloc_pages+0x44>
        return NULL;
  1042ef:	b8 00 00 00 00       	mov    $0x0,%eax
  1042f4:	e9 49 01 00 00       	jmp    104442 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
  1042f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104300:	c7 45 f0 1c af 11 00 	movl   $0x11af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104307:	eb 1c                	jmp    104325 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  104309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10430c:	83 e8 0c             	sub    $0xc,%eax
  10430f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  104312:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104315:	8b 40 08             	mov    0x8(%eax),%eax
  104318:	39 45 08             	cmp    %eax,0x8(%ebp)
  10431b:	77 08                	ja     104325 <default_alloc_pages+0x70>
            page = p;
  10431d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104320:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  104323:	eb 18                	jmp    10433d <default_alloc_pages+0x88>
  104325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  10432b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10432e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104331:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104334:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  10433b:	75 cc                	jne    104309 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  10433d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104341:	0f 84 f8 00 00 00    	je     10443f <default_alloc_pages+0x18a>
        if (page->property > n) {
  104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10434a:	8b 40 08             	mov    0x8(%eax),%eax
  10434d:	39 45 08             	cmp    %eax,0x8(%ebp)
  104350:	0f 83 98 00 00 00    	jae    1043ee <default_alloc_pages+0x139>
            struct Page *p = page + n;
  104356:	8b 55 08             	mov    0x8(%ebp),%edx
  104359:	89 d0                	mov    %edx,%eax
  10435b:	c1 e0 02             	shl    $0x2,%eax
  10435e:	01 d0                	add    %edx,%eax
  104360:	c1 e0 02             	shl    $0x2,%eax
  104363:	89 c2                	mov    %eax,%edx
  104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104368:	01 d0                	add    %edx,%eax
  10436a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  10436d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104370:	8b 40 08             	mov    0x8(%eax),%eax
  104373:	2b 45 08             	sub    0x8(%ebp),%eax
  104376:	89 c2                	mov    %eax,%edx
  104378:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10437b:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  10437e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104381:	83 c0 04             	add    $0x4,%eax
  104384:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  10438b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  10438e:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104391:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104394:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
  104397:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10439a:	83 c0 0c             	add    $0xc,%eax
  10439d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1043a0:	83 c2 0c             	add    $0xc,%edx
  1043a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1043a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1043a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1043ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1043af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  1043b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043b8:	8b 40 04             	mov    0x4(%eax),%eax
  1043bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043be:	89 55 d0             	mov    %edx,-0x30(%ebp)
  1043c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
  1043c7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  1043ca:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1043cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1043d0:	89 10                	mov    %edx,(%eax)
  1043d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1043d5:	8b 10                	mov    (%eax),%edx
  1043d7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043da:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1043dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043e0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1043e3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1043e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043e9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1043ec:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  1043ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043f1:	83 c0 0c             	add    $0xc,%eax
  1043f4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1043f7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1043fa:	8b 40 04             	mov    0x4(%eax),%eax
  1043fd:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104400:	8b 12                	mov    (%edx),%edx
  104402:	89 55 b0             	mov    %edx,-0x50(%ebp)
  104405:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104408:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10440b:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10440e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104411:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104414:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104417:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  104419:	a1 24 af 11 00       	mov    0x11af24,%eax
  10441e:	2b 45 08             	sub    0x8(%ebp),%eax
  104421:	a3 24 af 11 00       	mov    %eax,0x11af24
        ClearPageProperty(page);
  104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104429:	83 c0 04             	add    $0x4,%eax
  10442c:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  104433:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104436:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104439:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10443c:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  10443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104442:	c9                   	leave  
  104443:	c3                   	ret    

00104444 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  104444:	55                   	push   %ebp
  104445:	89 e5                	mov    %esp,%ebp
  104447:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  10444d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104451:	75 24                	jne    104477 <default_free_pages+0x33>
  104453:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  10445a:	00 
  10445b:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104462:	00 
  104463:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  10446a:	00 
  10446b:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104472:	e8 72 bf ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  104477:	8b 45 08             	mov    0x8(%ebp),%eax
  10447a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10447d:	e9 9d 00 00 00       	jmp    10451f <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104485:	83 c0 04             	add    $0x4,%eax
  104488:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10448f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104492:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104495:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104498:	0f a3 10             	bt     %edx,(%eax)
  10449b:	19 c0                	sbb    %eax,%eax
  10449d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1044a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1044a4:	0f 95 c0             	setne  %al
  1044a7:	0f b6 c0             	movzbl %al,%eax
  1044aa:	85 c0                	test   %eax,%eax
  1044ac:	75 2c                	jne    1044da <default_free_pages+0x96>
  1044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044b1:	83 c0 04             	add    $0x4,%eax
  1044b4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1044bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1044be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1044c4:	0f a3 10             	bt     %edx,(%eax)
  1044c7:	19 c0                	sbb    %eax,%eax
  1044c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  1044cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1044d0:	0f 95 c0             	setne  %al
  1044d3:	0f b6 c0             	movzbl %al,%eax
  1044d6:	85 c0                	test   %eax,%eax
  1044d8:	74 24                	je     1044fe <default_free_pages+0xba>
  1044da:	c7 44 24 0c 3c 6c 10 	movl   $0x106c3c,0xc(%esp)
  1044e1:	00 
  1044e2:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1044e9:	00 
  1044ea:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  1044f1:	00 
  1044f2:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1044f9:	e8 eb be ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  1044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104501:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  104508:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10450f:	00 
  104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104513:	89 04 24             	mov    %eax,(%esp)
  104516:	e8 0f fc ff ff       	call   10412a <set_page_ref>
    for (; p != base + n; p ++) {
  10451b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10451f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104522:	89 d0                	mov    %edx,%eax
  104524:	c1 e0 02             	shl    $0x2,%eax
  104527:	01 d0                	add    %edx,%eax
  104529:	c1 e0 02             	shl    $0x2,%eax
  10452c:	89 c2                	mov    %eax,%edx
  10452e:	8b 45 08             	mov    0x8(%ebp),%eax
  104531:	01 d0                	add    %edx,%eax
  104533:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104536:	0f 85 46 ff ff ff    	jne    104482 <default_free_pages+0x3e>
    }
    base->property = n;
  10453c:	8b 45 08             	mov    0x8(%ebp),%eax
  10453f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104542:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104545:	8b 45 08             	mov    0x8(%ebp),%eax
  104548:	83 c0 04             	add    $0x4,%eax
  10454b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104552:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104555:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104558:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10455b:	0f ab 10             	bts    %edx,(%eax)
  10455e:	c7 45 d4 1c af 11 00 	movl   $0x11af1c,-0x2c(%ebp)
    return listelm->next;
  104565:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104568:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  10456b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  10456e:	e9 08 01 00 00       	jmp    10467b <default_free_pages+0x237>
        p = le2page(le, page_link);
  104573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104576:	83 e8 0c             	sub    $0xc,%eax
  104579:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10457c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10457f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104582:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104585:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  104588:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  10458b:	8b 45 08             	mov    0x8(%ebp),%eax
  10458e:	8b 50 08             	mov    0x8(%eax),%edx
  104591:	89 d0                	mov    %edx,%eax
  104593:	c1 e0 02             	shl    $0x2,%eax
  104596:	01 d0                	add    %edx,%eax
  104598:	c1 e0 02             	shl    $0x2,%eax
  10459b:	89 c2                	mov    %eax,%edx
  10459d:	8b 45 08             	mov    0x8(%ebp),%eax
  1045a0:	01 d0                	add    %edx,%eax
  1045a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1045a5:	75 5a                	jne    104601 <default_free_pages+0x1bd>
            base->property += p->property;
  1045a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1045aa:	8b 50 08             	mov    0x8(%eax),%edx
  1045ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b0:	8b 40 08             	mov    0x8(%eax),%eax
  1045b3:	01 c2                	add    %eax,%edx
  1045b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1045b8:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  1045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045be:	83 c0 04             	add    $0x4,%eax
  1045c1:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  1045c8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1045cb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1045ce:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1045d1:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  1045d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045d7:	83 c0 0c             	add    $0xc,%eax
  1045da:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1045dd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1045e0:	8b 40 04             	mov    0x4(%eax),%eax
  1045e3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1045e6:	8b 12                	mov    (%edx),%edx
  1045e8:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1045eb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  1045ee:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1045f1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045f4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1045f7:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1045fa:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1045fd:	89 10                	mov    %edx,(%eax)
  1045ff:	eb 7a                	jmp    10467b <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104604:	8b 50 08             	mov    0x8(%eax),%edx
  104607:	89 d0                	mov    %edx,%eax
  104609:	c1 e0 02             	shl    $0x2,%eax
  10460c:	01 d0                	add    %edx,%eax
  10460e:	c1 e0 02             	shl    $0x2,%eax
  104611:	89 c2                	mov    %eax,%edx
  104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104616:	01 d0                	add    %edx,%eax
  104618:	39 45 08             	cmp    %eax,0x8(%ebp)
  10461b:	75 5e                	jne    10467b <default_free_pages+0x237>
            p->property += base->property;
  10461d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104620:	8b 50 08             	mov    0x8(%eax),%edx
  104623:	8b 45 08             	mov    0x8(%ebp),%eax
  104626:	8b 40 08             	mov    0x8(%eax),%eax
  104629:	01 c2                	add    %eax,%edx
  10462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10462e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104631:	8b 45 08             	mov    0x8(%ebp),%eax
  104634:	83 c0 04             	add    $0x4,%eax
  104637:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  10463e:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104641:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104644:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104647:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  10464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104653:	83 c0 0c             	add    $0xc,%eax
  104656:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  104659:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10465c:	8b 40 04             	mov    0x4(%eax),%eax
  10465f:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104662:	8b 12                	mov    (%edx),%edx
  104664:	89 55 ac             	mov    %edx,-0x54(%ebp)
  104667:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  10466a:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10466d:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104670:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104673:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104676:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104679:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  10467b:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  104682:	0f 85 eb fe ff ff    	jne    104573 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
  104688:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  10468e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104691:	01 d0                	add    %edx,%eax
  104693:	a3 24 af 11 00       	mov    %eax,0x11af24
  104698:	c7 45 9c 1c af 11 00 	movl   $0x11af1c,-0x64(%ebp)
    return listelm->next;
  10469f:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1046a2:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
  1046a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046a8:	eb 74                	jmp    10471e <default_free_pages+0x2da>
        p = le2page(le, page_link);
  1046aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046ad:	83 e8 0c             	sub    $0xc,%eax
  1046b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(base + base->property <= p) {
  1046b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1046b6:	8b 50 08             	mov    0x8(%eax),%edx
  1046b9:	89 d0                	mov    %edx,%eax
  1046bb:	c1 e0 02             	shl    $0x2,%eax
  1046be:	01 d0                	add    %edx,%eax
  1046c0:	c1 e0 02             	shl    $0x2,%eax
  1046c3:	89 c2                	mov    %eax,%edx
  1046c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c8:	01 d0                	add    %edx,%eax
  1046ca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046cd:	72 40                	jb     10470f <default_free_pages+0x2cb>
            assert(base + base->property != p);
  1046cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1046d2:	8b 50 08             	mov    0x8(%eax),%edx
  1046d5:	89 d0                	mov    %edx,%eax
  1046d7:	c1 e0 02             	shl    $0x2,%eax
  1046da:	01 d0                	add    %edx,%eax
  1046dc:	c1 e0 02             	shl    $0x2,%eax
  1046df:	89 c2                	mov    %eax,%edx
  1046e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e4:	01 d0                	add    %edx,%eax
  1046e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046e9:	75 3e                	jne    104729 <default_free_pages+0x2e5>
  1046eb:	c7 44 24 0c 61 6c 10 	movl   $0x106c61,0xc(%esp)
  1046f2:	00 
  1046f3:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1046fa:	00 
  1046fb:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  104702:	00 
  104703:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10470a:	e8 da bc ff ff       	call   1003e9 <__panic>
  10470f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104712:	89 45 98             	mov    %eax,-0x68(%ebp)
  104715:	8b 45 98             	mov    -0x68(%ebp),%eax
  104718:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
  10471b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10471e:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  104725:	75 83                	jne    1046aa <default_free_pages+0x266>
  104727:	eb 01                	jmp    10472a <default_free_pages+0x2e6>
            break;
  104729:	90                   	nop
        }
    }
    list_add_before(le, &(base->page_link));
  10472a:	8b 45 08             	mov    0x8(%ebp),%eax
  10472d:	8d 50 0c             	lea    0xc(%eax),%edx
  104730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104733:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104736:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  104739:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10473c:	8b 00                	mov    (%eax),%eax
  10473e:	8b 55 90             	mov    -0x70(%ebp),%edx
  104741:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104744:	89 45 88             	mov    %eax,-0x78(%ebp)
  104747:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10474a:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  10474d:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104750:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104753:	89 10                	mov    %edx,(%eax)
  104755:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104758:	8b 10                	mov    (%eax),%edx
  10475a:	8b 45 88             	mov    -0x78(%ebp),%eax
  10475d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104760:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104763:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104766:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104769:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10476c:	8b 55 88             	mov    -0x78(%ebp),%edx
  10476f:	89 10                	mov    %edx,(%eax)
}
  104771:	90                   	nop
  104772:	c9                   	leave  
  104773:	c3                   	ret    

00104774 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104774:	55                   	push   %ebp
  104775:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104777:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  10477c:	5d                   	pop    %ebp
  10477d:	c3                   	ret    

0010477e <basic_check>:

static void
basic_check(void) {
  10477e:	55                   	push   %ebp
  10477f:	89 e5                	mov    %esp,%ebp
  104781:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10478b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10478e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104794:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104797:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10479e:	e8 2f e4 ff ff       	call   102bd2 <alloc_pages>
  1047a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1047a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1047aa:	75 24                	jne    1047d0 <basic_check+0x52>
  1047ac:	c7 44 24 0c 7c 6c 10 	movl   $0x106c7c,0xc(%esp)
  1047b3:	00 
  1047b4:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1047bb:	00 
  1047bc:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  1047c3:	00 
  1047c4:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1047cb:	e8 19 bc ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1047d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1047d7:	e8 f6 e3 ff ff       	call   102bd2 <alloc_pages>
  1047dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1047df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1047e3:	75 24                	jne    104809 <basic_check+0x8b>
  1047e5:	c7 44 24 0c 98 6c 10 	movl   $0x106c98,0xc(%esp)
  1047ec:	00 
  1047ed:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1047f4:	00 
  1047f5:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  1047fc:	00 
  1047fd:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104804:	e8 e0 bb ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104809:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104810:	e8 bd e3 ff ff       	call   102bd2 <alloc_pages>
  104815:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104818:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10481c:	75 24                	jne    104842 <basic_check+0xc4>
  10481e:	c7 44 24 0c b4 6c 10 	movl   $0x106cb4,0xc(%esp)
  104825:	00 
  104826:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10482d:	00 
  10482e:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  104835:	00 
  104836:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10483d:	e8 a7 bb ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104842:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104845:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104848:	74 10                	je     10485a <basic_check+0xdc>
  10484a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10484d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104850:	74 08                	je     10485a <basic_check+0xdc>
  104852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104855:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104858:	75 24                	jne    10487e <basic_check+0x100>
  10485a:	c7 44 24 0c d0 6c 10 	movl   $0x106cd0,0xc(%esp)
  104861:	00 
  104862:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104869:	00 
  10486a:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  104871:	00 
  104872:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104879:	e8 6b bb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10487e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104881:	89 04 24             	mov    %eax,(%esp)
  104884:	e8 97 f8 ff ff       	call   104120 <page_ref>
  104889:	85 c0                	test   %eax,%eax
  10488b:	75 1e                	jne    1048ab <basic_check+0x12d>
  10488d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104890:	89 04 24             	mov    %eax,(%esp)
  104893:	e8 88 f8 ff ff       	call   104120 <page_ref>
  104898:	85 c0                	test   %eax,%eax
  10489a:	75 0f                	jne    1048ab <basic_check+0x12d>
  10489c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10489f:	89 04 24             	mov    %eax,(%esp)
  1048a2:	e8 79 f8 ff ff       	call   104120 <page_ref>
  1048a7:	85 c0                	test   %eax,%eax
  1048a9:	74 24                	je     1048cf <basic_check+0x151>
  1048ab:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  1048b2:	00 
  1048b3:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1048ba:	00 
  1048bb:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  1048c2:	00 
  1048c3:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1048ca:	e8 1a bb ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1048cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048d2:	89 04 24             	mov    %eax,(%esp)
  1048d5:	e8 30 f8 ff ff       	call   10410a <page2pa>
  1048da:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1048e0:	c1 e2 0c             	shl    $0xc,%edx
  1048e3:	39 d0                	cmp    %edx,%eax
  1048e5:	72 24                	jb     10490b <basic_check+0x18d>
  1048e7:	c7 44 24 0c 30 6d 10 	movl   $0x106d30,0xc(%esp)
  1048ee:	00 
  1048ef:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1048f6:	00 
  1048f7:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  1048fe:	00 
  1048ff:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104906:	e8 de ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10490b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10490e:	89 04 24             	mov    %eax,(%esp)
  104911:	e8 f4 f7 ff ff       	call   10410a <page2pa>
  104916:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10491c:	c1 e2 0c             	shl    $0xc,%edx
  10491f:	39 d0                	cmp    %edx,%eax
  104921:	72 24                	jb     104947 <basic_check+0x1c9>
  104923:	c7 44 24 0c 4d 6d 10 	movl   $0x106d4d,0xc(%esp)
  10492a:	00 
  10492b:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104932:	00 
  104933:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  10493a:	00 
  10493b:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104942:	e8 a2 ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10494a:	89 04 24             	mov    %eax,(%esp)
  10494d:	e8 b8 f7 ff ff       	call   10410a <page2pa>
  104952:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104958:	c1 e2 0c             	shl    $0xc,%edx
  10495b:	39 d0                	cmp    %edx,%eax
  10495d:	72 24                	jb     104983 <basic_check+0x205>
  10495f:	c7 44 24 0c 6a 6d 10 	movl   $0x106d6a,0xc(%esp)
  104966:	00 
  104967:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10496e:	00 
  10496f:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104976:	00 
  104977:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10497e:	e8 66 ba ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104983:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104988:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  10498e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104991:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104994:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  10499b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10499e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1049a1:	89 50 04             	mov    %edx,0x4(%eax)
  1049a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1049a7:	8b 50 04             	mov    0x4(%eax),%edx
  1049aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1049ad:	89 10                	mov    %edx,(%eax)
  1049af:	c7 45 e0 1c af 11 00 	movl   $0x11af1c,-0x20(%ebp)
    return list->next == list;
  1049b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1049b9:	8b 40 04             	mov    0x4(%eax),%eax
  1049bc:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1049bf:	0f 94 c0             	sete   %al
  1049c2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1049c5:	85 c0                	test   %eax,%eax
  1049c7:	75 24                	jne    1049ed <basic_check+0x26f>
  1049c9:	c7 44 24 0c 87 6d 10 	movl   $0x106d87,0xc(%esp)
  1049d0:	00 
  1049d1:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1049d8:	00 
  1049d9:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  1049e0:	00 
  1049e1:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1049e8:	e8 fc b9 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  1049ed:	a1 24 af 11 00       	mov    0x11af24,%eax
  1049f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1049f5:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  1049fc:	00 00 00 

    assert(alloc_page() == NULL);
  1049ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a06:	e8 c7 e1 ff ff       	call   102bd2 <alloc_pages>
  104a0b:	85 c0                	test   %eax,%eax
  104a0d:	74 24                	je     104a33 <basic_check+0x2b5>
  104a0f:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  104a16:	00 
  104a17:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104a1e:	00 
  104a1f:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104a26:	00 
  104a27:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104a2e:	e8 b6 b9 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104a33:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104a3a:	00 
  104a3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a3e:	89 04 24             	mov    %eax,(%esp)
  104a41:	e8 c4 e1 ff ff       	call   102c0a <free_pages>
    free_page(p1);
  104a46:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104a4d:	00 
  104a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a51:	89 04 24             	mov    %eax,(%esp)
  104a54:	e8 b1 e1 ff ff       	call   102c0a <free_pages>
    free_page(p2);
  104a59:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104a60:	00 
  104a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a64:	89 04 24             	mov    %eax,(%esp)
  104a67:	e8 9e e1 ff ff       	call   102c0a <free_pages>
    assert(nr_free == 3);
  104a6c:	a1 24 af 11 00       	mov    0x11af24,%eax
  104a71:	83 f8 03             	cmp    $0x3,%eax
  104a74:	74 24                	je     104a9a <basic_check+0x31c>
  104a76:	c7 44 24 0c b3 6d 10 	movl   $0x106db3,0xc(%esp)
  104a7d:	00 
  104a7e:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104a85:	00 
  104a86:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104a8d:	00 
  104a8e:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104a95:	e8 4f b9 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104a9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104aa1:	e8 2c e1 ff ff       	call   102bd2 <alloc_pages>
  104aa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104aa9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104aad:	75 24                	jne    104ad3 <basic_check+0x355>
  104aaf:	c7 44 24 0c 7c 6c 10 	movl   $0x106c7c,0xc(%esp)
  104ab6:	00 
  104ab7:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104abe:	00 
  104abf:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  104ac6:	00 
  104ac7:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104ace:	e8 16 b9 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104ad3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ada:	e8 f3 e0 ff ff       	call   102bd2 <alloc_pages>
  104adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ae2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ae6:	75 24                	jne    104b0c <basic_check+0x38e>
  104ae8:	c7 44 24 0c 98 6c 10 	movl   $0x106c98,0xc(%esp)
  104aef:	00 
  104af0:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104af7:	00 
  104af8:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  104aff:	00 
  104b00:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104b07:	e8 dd b8 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104b0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b13:	e8 ba e0 ff ff       	call   102bd2 <alloc_pages>
  104b18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104b1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104b1f:	75 24                	jne    104b45 <basic_check+0x3c7>
  104b21:	c7 44 24 0c b4 6c 10 	movl   $0x106cb4,0xc(%esp)
  104b28:	00 
  104b29:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104b30:	00 
  104b31:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104b38:	00 
  104b39:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104b40:	e8 a4 b8 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104b45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b4c:	e8 81 e0 ff ff       	call   102bd2 <alloc_pages>
  104b51:	85 c0                	test   %eax,%eax
  104b53:	74 24                	je     104b79 <basic_check+0x3fb>
  104b55:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  104b5c:	00 
  104b5d:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104b64:	00 
  104b65:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  104b6c:	00 
  104b6d:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104b74:	e8 70 b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104b79:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b80:	00 
  104b81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b84:	89 04 24             	mov    %eax,(%esp)
  104b87:	e8 7e e0 ff ff       	call   102c0a <free_pages>
  104b8c:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
  104b93:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104b96:	8b 40 04             	mov    0x4(%eax),%eax
  104b99:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104b9c:	0f 94 c0             	sete   %al
  104b9f:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104ba2:	85 c0                	test   %eax,%eax
  104ba4:	74 24                	je     104bca <basic_check+0x44c>
  104ba6:	c7 44 24 0c c0 6d 10 	movl   $0x106dc0,0xc(%esp)
  104bad:	00 
  104bae:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104bb5:	00 
  104bb6:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104bbd:	00 
  104bbe:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104bc5:	e8 1f b8 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104bca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bd1:	e8 fc df ff ff       	call   102bd2 <alloc_pages>
  104bd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bdc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104bdf:	74 24                	je     104c05 <basic_check+0x487>
  104be1:	c7 44 24 0c d8 6d 10 	movl   $0x106dd8,0xc(%esp)
  104be8:	00 
  104be9:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104bf0:	00 
  104bf1:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  104bf8:	00 
  104bf9:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104c00:	e8 e4 b7 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104c05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c0c:	e8 c1 df ff ff       	call   102bd2 <alloc_pages>
  104c11:	85 c0                	test   %eax,%eax
  104c13:	74 24                	je     104c39 <basic_check+0x4bb>
  104c15:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  104c1c:	00 
  104c1d:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104c24:	00 
  104c25:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  104c2c:	00 
  104c2d:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104c34:	e8 b0 b7 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104c39:	a1 24 af 11 00       	mov    0x11af24,%eax
  104c3e:	85 c0                	test   %eax,%eax
  104c40:	74 24                	je     104c66 <basic_check+0x4e8>
  104c42:	c7 44 24 0c f1 6d 10 	movl   $0x106df1,0xc(%esp)
  104c49:	00 
  104c4a:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104c51:	00 
  104c52:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  104c59:	00 
  104c5a:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104c61:	e8 83 b7 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104c66:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104c69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104c6c:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104c71:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104c77:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c7a:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104c7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c86:	00 
  104c87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c8a:	89 04 24             	mov    %eax,(%esp)
  104c8d:	e8 78 df ff ff       	call   102c0a <free_pages>
    free_page(p1);
  104c92:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c99:	00 
  104c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c9d:	89 04 24             	mov    %eax,(%esp)
  104ca0:	e8 65 df ff ff       	call   102c0a <free_pages>
    free_page(p2);
  104ca5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104cac:	00 
  104cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cb0:	89 04 24             	mov    %eax,(%esp)
  104cb3:	e8 52 df ff ff       	call   102c0a <free_pages>
}
  104cb8:	90                   	nop
  104cb9:	c9                   	leave  
  104cba:	c3                   	ret    

00104cbb <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104cbb:	55                   	push   %ebp
  104cbc:	89 e5                	mov    %esp,%ebp
  104cbe:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104cc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104ccb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104cd2:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104cd9:	eb 6a                	jmp    104d45 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104cde:	83 e8 0c             	sub    $0xc,%eax
  104ce1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104ce4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104ce7:	83 c0 04             	add    $0x4,%eax
  104cea:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104cf1:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104cf4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104cf7:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104cfa:	0f a3 10             	bt     %edx,(%eax)
  104cfd:	19 c0                	sbb    %eax,%eax
  104cff:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104d02:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104d06:	0f 95 c0             	setne  %al
  104d09:	0f b6 c0             	movzbl %al,%eax
  104d0c:	85 c0                	test   %eax,%eax
  104d0e:	75 24                	jne    104d34 <default_check+0x79>
  104d10:	c7 44 24 0c fe 6d 10 	movl   $0x106dfe,0xc(%esp)
  104d17:	00 
  104d18:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104d1f:	00 
  104d20:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  104d27:	00 
  104d28:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104d2f:	e8 b5 b6 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104d34:	ff 45 f4             	incl   -0xc(%ebp)
  104d37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104d3a:	8b 50 08             	mov    0x8(%eax),%edx
  104d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d40:	01 d0                	add    %edx,%eax
  104d42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d48:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104d4b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104d4e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104d51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104d54:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104d5b:	0f 85 7a ff ff ff    	jne    104cdb <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104d61:	e8 d7 de ff ff       	call   102c3d <nr_free_pages>
  104d66:	89 c2                	mov    %eax,%edx
  104d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d6b:	39 c2                	cmp    %eax,%edx
  104d6d:	74 24                	je     104d93 <default_check+0xd8>
  104d6f:	c7 44 24 0c 0e 6e 10 	movl   $0x106e0e,0xc(%esp)
  104d76:	00 
  104d77:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104d7e:	00 
  104d7f:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104d86:	00 
  104d87:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104d8e:	e8 56 b6 ff ff       	call   1003e9 <__panic>

    basic_check();
  104d93:	e8 e6 f9 ff ff       	call   10477e <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104d98:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104d9f:	e8 2e de ff ff       	call   102bd2 <alloc_pages>
  104da4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104da7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104dab:	75 24                	jne    104dd1 <default_check+0x116>
  104dad:	c7 44 24 0c 27 6e 10 	movl   $0x106e27,0xc(%esp)
  104db4:	00 
  104db5:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104dbc:	00 
  104dbd:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  104dc4:	00 
  104dc5:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104dcc:	e8 18 b6 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104dd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104dd4:	83 c0 04             	add    $0x4,%eax
  104dd7:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104dde:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104de1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104de4:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104de7:	0f a3 10             	bt     %edx,(%eax)
  104dea:	19 c0                	sbb    %eax,%eax
  104dec:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104def:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104df3:	0f 95 c0             	setne  %al
  104df6:	0f b6 c0             	movzbl %al,%eax
  104df9:	85 c0                	test   %eax,%eax
  104dfb:	74 24                	je     104e21 <default_check+0x166>
  104dfd:	c7 44 24 0c 32 6e 10 	movl   $0x106e32,0xc(%esp)
  104e04:	00 
  104e05:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104e0c:	00 
  104e0d:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104e14:	00 
  104e15:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104e1c:	e8 c8 b5 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104e21:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104e26:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104e2c:	89 45 80             	mov    %eax,-0x80(%ebp)
  104e2f:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104e32:	c7 45 b0 1c af 11 00 	movl   $0x11af1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104e39:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104e3c:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104e3f:	89 50 04             	mov    %edx,0x4(%eax)
  104e42:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104e45:	8b 50 04             	mov    0x4(%eax),%edx
  104e48:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104e4b:	89 10                	mov    %edx,(%eax)
  104e4d:	c7 45 b4 1c af 11 00 	movl   $0x11af1c,-0x4c(%ebp)
    return list->next == list;
  104e54:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104e57:	8b 40 04             	mov    0x4(%eax),%eax
  104e5a:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104e5d:	0f 94 c0             	sete   %al
  104e60:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104e63:	85 c0                	test   %eax,%eax
  104e65:	75 24                	jne    104e8b <default_check+0x1d0>
  104e67:	c7 44 24 0c 87 6d 10 	movl   $0x106d87,0xc(%esp)
  104e6e:	00 
  104e6f:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104e76:	00 
  104e77:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  104e7e:	00 
  104e7f:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104e86:	e8 5e b5 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104e8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e92:	e8 3b dd ff ff       	call   102bd2 <alloc_pages>
  104e97:	85 c0                	test   %eax,%eax
  104e99:	74 24                	je     104ebf <default_check+0x204>
  104e9b:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  104ea2:	00 
  104ea3:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104eaa:	00 
  104eab:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  104eb2:	00 
  104eb3:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104eba:	e8 2a b5 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104ebf:	a1 24 af 11 00       	mov    0x11af24,%eax
  104ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  104ec7:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104ece:	00 00 00 

    free_pages(p0 + 2, 3);
  104ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ed4:	83 c0 28             	add    $0x28,%eax
  104ed7:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104ede:	00 
  104edf:	89 04 24             	mov    %eax,(%esp)
  104ee2:	e8 23 dd ff ff       	call   102c0a <free_pages>
    assert(alloc_pages(4) == NULL);
  104ee7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104eee:	e8 df dc ff ff       	call   102bd2 <alloc_pages>
  104ef3:	85 c0                	test   %eax,%eax
  104ef5:	74 24                	je     104f1b <default_check+0x260>
  104ef7:	c7 44 24 0c 44 6e 10 	movl   $0x106e44,0xc(%esp)
  104efe:	00 
  104eff:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104f06:	00 
  104f07:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  104f0e:	00 
  104f0f:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104f16:	e8 ce b4 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104f1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f1e:	83 c0 28             	add    $0x28,%eax
  104f21:	83 c0 04             	add    $0x4,%eax
  104f24:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104f2b:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104f2e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104f31:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104f34:	0f a3 10             	bt     %edx,(%eax)
  104f37:	19 c0                	sbb    %eax,%eax
  104f39:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  104f3c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  104f40:	0f 95 c0             	setne  %al
  104f43:	0f b6 c0             	movzbl %al,%eax
  104f46:	85 c0                	test   %eax,%eax
  104f48:	74 0e                	je     104f58 <default_check+0x29d>
  104f4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f4d:	83 c0 28             	add    $0x28,%eax
  104f50:	8b 40 08             	mov    0x8(%eax),%eax
  104f53:	83 f8 03             	cmp    $0x3,%eax
  104f56:	74 24                	je     104f7c <default_check+0x2c1>
  104f58:	c7 44 24 0c 5c 6e 10 	movl   $0x106e5c,0xc(%esp)
  104f5f:	00 
  104f60:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104f67:	00 
  104f68:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104f6f:	00 
  104f70:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104f77:	e8 6d b4 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104f7c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  104f83:	e8 4a dc ff ff       	call   102bd2 <alloc_pages>
  104f88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104f8b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104f8f:	75 24                	jne    104fb5 <default_check+0x2fa>
  104f91:	c7 44 24 0c 88 6e 10 	movl   $0x106e88,0xc(%esp)
  104f98:	00 
  104f99:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104fa0:	00 
  104fa1:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  104fa8:	00 
  104fa9:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104fb0:	e8 34 b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104fb5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104fbc:	e8 11 dc ff ff       	call   102bd2 <alloc_pages>
  104fc1:	85 c0                	test   %eax,%eax
  104fc3:	74 24                	je     104fe9 <default_check+0x32e>
  104fc5:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  104fcc:	00 
  104fcd:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  104fd4:	00 
  104fd5:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  104fdc:	00 
  104fdd:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  104fe4:	e8 00 b4 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  104fe9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104fec:	83 c0 28             	add    $0x28,%eax
  104fef:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104ff2:	74 24                	je     105018 <default_check+0x35d>
  104ff4:	c7 44 24 0c a6 6e 10 	movl   $0x106ea6,0xc(%esp)
  104ffb:	00 
  104ffc:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105003:	00 
  105004:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  10500b:	00 
  10500c:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105013:	e8 d1 b3 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  105018:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10501b:	83 c0 14             	add    $0x14,%eax
  10501e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  105021:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105028:	00 
  105029:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10502c:	89 04 24             	mov    %eax,(%esp)
  10502f:	e8 d6 db ff ff       	call   102c0a <free_pages>
    free_pages(p1, 3);
  105034:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10503b:	00 
  10503c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10503f:	89 04 24             	mov    %eax,(%esp)
  105042:	e8 c3 db ff ff       	call   102c0a <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105047:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10504a:	83 c0 04             	add    $0x4,%eax
  10504d:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105054:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105057:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10505a:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10505d:	0f a3 10             	bt     %edx,(%eax)
  105060:	19 c0                	sbb    %eax,%eax
  105062:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105065:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105069:	0f 95 c0             	setne  %al
  10506c:	0f b6 c0             	movzbl %al,%eax
  10506f:	85 c0                	test   %eax,%eax
  105071:	74 0b                	je     10507e <default_check+0x3c3>
  105073:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105076:	8b 40 08             	mov    0x8(%eax),%eax
  105079:	83 f8 01             	cmp    $0x1,%eax
  10507c:	74 24                	je     1050a2 <default_check+0x3e7>
  10507e:	c7 44 24 0c b4 6e 10 	movl   $0x106eb4,0xc(%esp)
  105085:	00 
  105086:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10508d:	00 
  10508e:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  105095:	00 
  105096:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10509d:	e8 47 b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1050a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050a5:	83 c0 04             	add    $0x4,%eax
  1050a8:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1050af:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1050b2:	8b 45 90             	mov    -0x70(%ebp),%eax
  1050b5:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1050b8:	0f a3 10             	bt     %edx,(%eax)
  1050bb:	19 c0                	sbb    %eax,%eax
  1050bd:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1050c0:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1050c4:	0f 95 c0             	setne  %al
  1050c7:	0f b6 c0             	movzbl %al,%eax
  1050ca:	85 c0                	test   %eax,%eax
  1050cc:	74 0b                	je     1050d9 <default_check+0x41e>
  1050ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050d1:	8b 40 08             	mov    0x8(%eax),%eax
  1050d4:	83 f8 03             	cmp    $0x3,%eax
  1050d7:	74 24                	je     1050fd <default_check+0x442>
  1050d9:	c7 44 24 0c dc 6e 10 	movl   $0x106edc,0xc(%esp)
  1050e0:	00 
  1050e1:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1050e8:	00 
  1050e9:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  1050f0:	00 
  1050f1:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1050f8:	e8 ec b2 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1050fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105104:	e8 c9 da ff ff       	call   102bd2 <alloc_pages>
  105109:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10510c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10510f:	83 e8 14             	sub    $0x14,%eax
  105112:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105115:	74 24                	je     10513b <default_check+0x480>
  105117:	c7 44 24 0c 02 6f 10 	movl   $0x106f02,0xc(%esp)
  10511e:	00 
  10511f:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105126:	00 
  105127:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  10512e:	00 
  10512f:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105136:	e8 ae b2 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  10513b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105142:	00 
  105143:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105146:	89 04 24             	mov    %eax,(%esp)
  105149:	e8 bc da ff ff       	call   102c0a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10514e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105155:	e8 78 da ff ff       	call   102bd2 <alloc_pages>
  10515a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10515d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105160:	83 c0 14             	add    $0x14,%eax
  105163:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105166:	74 24                	je     10518c <default_check+0x4d1>
  105168:	c7 44 24 0c 20 6f 10 	movl   $0x106f20,0xc(%esp)
  10516f:	00 
  105170:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105177:	00 
  105178:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  10517f:	00 
  105180:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105187:	e8 5d b2 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  10518c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105193:	00 
  105194:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105197:	89 04 24             	mov    %eax,(%esp)
  10519a:	e8 6b da ff ff       	call   102c0a <free_pages>
    free_page(p2);
  10519f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051a6:	00 
  1051a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051aa:	89 04 24             	mov    %eax,(%esp)
  1051ad:	e8 58 da ff ff       	call   102c0a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1051b2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1051b9:	e8 14 da ff ff       	call   102bd2 <alloc_pages>
  1051be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1051c1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1051c5:	75 24                	jne    1051eb <default_check+0x530>
  1051c7:	c7 44 24 0c 40 6f 10 	movl   $0x106f40,0xc(%esp)
  1051ce:	00 
  1051cf:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1051d6:	00 
  1051d7:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  1051de:	00 
  1051df:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1051e6:	e8 fe b1 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1051eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051f2:	e8 db d9 ff ff       	call   102bd2 <alloc_pages>
  1051f7:	85 c0                	test   %eax,%eax
  1051f9:	74 24                	je     10521f <default_check+0x564>
  1051fb:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  105202:	00 
  105203:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  10520a:	00 
  10520b:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  105212:	00 
  105213:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  10521a:	e8 ca b1 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  10521f:	a1 24 af 11 00       	mov    0x11af24,%eax
  105224:	85 c0                	test   %eax,%eax
  105226:	74 24                	je     10524c <default_check+0x591>
  105228:	c7 44 24 0c f1 6d 10 	movl   $0x106df1,0xc(%esp)
  10522f:	00 
  105230:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105237:	00 
  105238:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  10523f:	00 
  105240:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105247:	e8 9d b1 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  10524c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10524f:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  105254:	8b 45 80             	mov    -0x80(%ebp),%eax
  105257:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10525a:	a3 1c af 11 00       	mov    %eax,0x11af1c
  10525f:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  105265:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10526c:	00 
  10526d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105270:	89 04 24             	mov    %eax,(%esp)
  105273:	e8 92 d9 ff ff       	call   102c0a <free_pages>

    le = &free_list;
  105278:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10527f:	eb 5a                	jmp    1052db <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  105281:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105284:	8b 40 04             	mov    0x4(%eax),%eax
  105287:	8b 00                	mov    (%eax),%eax
  105289:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  10528c:	75 0d                	jne    10529b <default_check+0x5e0>
  10528e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105291:	8b 00                	mov    (%eax),%eax
  105293:	8b 40 04             	mov    0x4(%eax),%eax
  105296:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105299:	74 24                	je     1052bf <default_check+0x604>
  10529b:	c7 44 24 0c 60 6f 10 	movl   $0x106f60,0xc(%esp)
  1052a2:	00 
  1052a3:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  1052aa:	00 
  1052ab:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  1052b2:	00 
  1052b3:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  1052ba:	e8 2a b1 ff ff       	call   1003e9 <__panic>
        struct Page *p = le2page(le, page_link);
  1052bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052c2:	83 e8 0c             	sub    $0xc,%eax
  1052c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  1052c8:	ff 4d f4             	decl   -0xc(%ebp)
  1052cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1052ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1052d1:	8b 40 08             	mov    0x8(%eax),%eax
  1052d4:	29 c2                	sub    %eax,%edx
  1052d6:	89 d0                	mov    %edx,%eax
  1052d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1052db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052de:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  1052e1:	8b 45 88             	mov    -0x78(%ebp),%eax
  1052e4:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1052e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1052ea:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  1052f1:	75 8e                	jne    105281 <default_check+0x5c6>
    }
    assert(count == 0);
  1052f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1052f7:	74 24                	je     10531d <default_check+0x662>
  1052f9:	c7 44 24 0c 8d 6f 10 	movl   $0x106f8d,0xc(%esp)
  105300:	00 
  105301:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105308:	00 
  105309:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  105310:	00 
  105311:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105318:	e8 cc b0 ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  10531d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105321:	74 24                	je     105347 <default_check+0x68c>
  105323:	c7 44 24 0c 98 6f 10 	movl   $0x106f98,0xc(%esp)
  10532a:	00 
  10532b:	c7 44 24 08 fe 6b 10 	movl   $0x106bfe,0x8(%esp)
  105332:	00 
  105333:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  10533a:	00 
  10533b:	c7 04 24 13 6c 10 00 	movl   $0x106c13,(%esp)
  105342:	e8 a2 b0 ff ff       	call   1003e9 <__panic>
}
  105347:	90                   	nop
  105348:	c9                   	leave  
  105349:	c3                   	ret    

0010534a <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10534a:	55                   	push   %ebp
  10534b:	89 e5                	mov    %esp,%ebp
  10534d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105350:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105357:	eb 03                	jmp    10535c <strlen+0x12>
        cnt ++;
  105359:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  10535c:	8b 45 08             	mov    0x8(%ebp),%eax
  10535f:	8d 50 01             	lea    0x1(%eax),%edx
  105362:	89 55 08             	mov    %edx,0x8(%ebp)
  105365:	0f b6 00             	movzbl (%eax),%eax
  105368:	84 c0                	test   %al,%al
  10536a:	75 ed                	jne    105359 <strlen+0xf>
    }
    return cnt;
  10536c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10536f:	c9                   	leave  
  105370:	c3                   	ret    

00105371 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105371:	55                   	push   %ebp
  105372:	89 e5                	mov    %esp,%ebp
  105374:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105377:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10537e:	eb 03                	jmp    105383 <strnlen+0x12>
        cnt ++;
  105380:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105383:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105386:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105389:	73 10                	jae    10539b <strnlen+0x2a>
  10538b:	8b 45 08             	mov    0x8(%ebp),%eax
  10538e:	8d 50 01             	lea    0x1(%eax),%edx
  105391:	89 55 08             	mov    %edx,0x8(%ebp)
  105394:	0f b6 00             	movzbl (%eax),%eax
  105397:	84 c0                	test   %al,%al
  105399:	75 e5                	jne    105380 <strnlen+0xf>
    }
    return cnt;
  10539b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10539e:	c9                   	leave  
  10539f:	c3                   	ret    

001053a0 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1053a0:	55                   	push   %ebp
  1053a1:	89 e5                	mov    %esp,%ebp
  1053a3:	57                   	push   %edi
  1053a4:	56                   	push   %esi
  1053a5:	83 ec 20             	sub    $0x20,%esp
  1053a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1053ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1053ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1053b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1053b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053ba:	89 d1                	mov    %edx,%ecx
  1053bc:	89 c2                	mov    %eax,%edx
  1053be:	89 ce                	mov    %ecx,%esi
  1053c0:	89 d7                	mov    %edx,%edi
  1053c2:	ac                   	lods   %ds:(%esi),%al
  1053c3:	aa                   	stos   %al,%es:(%edi)
  1053c4:	84 c0                	test   %al,%al
  1053c6:	75 fa                	jne    1053c2 <strcpy+0x22>
  1053c8:	89 fa                	mov    %edi,%edx
  1053ca:	89 f1                	mov    %esi,%ecx
  1053cc:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1053cf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1053d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1053d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1053d8:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1053d9:	83 c4 20             	add    $0x20,%esp
  1053dc:	5e                   	pop    %esi
  1053dd:	5f                   	pop    %edi
  1053de:	5d                   	pop    %ebp
  1053df:	c3                   	ret    

001053e0 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1053e0:	55                   	push   %ebp
  1053e1:	89 e5                	mov    %esp,%ebp
  1053e3:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1053e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1053e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1053ec:	eb 1e                	jmp    10540c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  1053ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053f1:	0f b6 10             	movzbl (%eax),%edx
  1053f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1053f7:	88 10                	mov    %dl,(%eax)
  1053f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1053fc:	0f b6 00             	movzbl (%eax),%eax
  1053ff:	84 c0                	test   %al,%al
  105401:	74 03                	je     105406 <strncpy+0x26>
            src ++;
  105403:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105406:	ff 45 fc             	incl   -0x4(%ebp)
  105409:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  10540c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105410:	75 dc                	jne    1053ee <strncpy+0xe>
    }
    return dst;
  105412:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105415:	c9                   	leave  
  105416:	c3                   	ret    

00105417 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105417:	55                   	push   %ebp
  105418:	89 e5                	mov    %esp,%ebp
  10541a:	57                   	push   %edi
  10541b:	56                   	push   %esi
  10541c:	83 ec 20             	sub    $0x20,%esp
  10541f:	8b 45 08             	mov    0x8(%ebp),%eax
  105422:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105425:	8b 45 0c             	mov    0xc(%ebp),%eax
  105428:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  10542b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10542e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105431:	89 d1                	mov    %edx,%ecx
  105433:	89 c2                	mov    %eax,%edx
  105435:	89 ce                	mov    %ecx,%esi
  105437:	89 d7                	mov    %edx,%edi
  105439:	ac                   	lods   %ds:(%esi),%al
  10543a:	ae                   	scas   %es:(%edi),%al
  10543b:	75 08                	jne    105445 <strcmp+0x2e>
  10543d:	84 c0                	test   %al,%al
  10543f:	75 f8                	jne    105439 <strcmp+0x22>
  105441:	31 c0                	xor    %eax,%eax
  105443:	eb 04                	jmp    105449 <strcmp+0x32>
  105445:	19 c0                	sbb    %eax,%eax
  105447:	0c 01                	or     $0x1,%al
  105449:	89 fa                	mov    %edi,%edx
  10544b:	89 f1                	mov    %esi,%ecx
  10544d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105450:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105453:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105456:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  105459:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10545a:	83 c4 20             	add    $0x20,%esp
  10545d:	5e                   	pop    %esi
  10545e:	5f                   	pop    %edi
  10545f:	5d                   	pop    %ebp
  105460:	c3                   	ret    

00105461 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105461:	55                   	push   %ebp
  105462:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105464:	eb 09                	jmp    10546f <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105466:	ff 4d 10             	decl   0x10(%ebp)
  105469:	ff 45 08             	incl   0x8(%ebp)
  10546c:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10546f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105473:	74 1a                	je     10548f <strncmp+0x2e>
  105475:	8b 45 08             	mov    0x8(%ebp),%eax
  105478:	0f b6 00             	movzbl (%eax),%eax
  10547b:	84 c0                	test   %al,%al
  10547d:	74 10                	je     10548f <strncmp+0x2e>
  10547f:	8b 45 08             	mov    0x8(%ebp),%eax
  105482:	0f b6 10             	movzbl (%eax),%edx
  105485:	8b 45 0c             	mov    0xc(%ebp),%eax
  105488:	0f b6 00             	movzbl (%eax),%eax
  10548b:	38 c2                	cmp    %al,%dl
  10548d:	74 d7                	je     105466 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10548f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105493:	74 18                	je     1054ad <strncmp+0x4c>
  105495:	8b 45 08             	mov    0x8(%ebp),%eax
  105498:	0f b6 00             	movzbl (%eax),%eax
  10549b:	0f b6 d0             	movzbl %al,%edx
  10549e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054a1:	0f b6 00             	movzbl (%eax),%eax
  1054a4:	0f b6 c0             	movzbl %al,%eax
  1054a7:	29 c2                	sub    %eax,%edx
  1054a9:	89 d0                	mov    %edx,%eax
  1054ab:	eb 05                	jmp    1054b2 <strncmp+0x51>
  1054ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1054b2:	5d                   	pop    %ebp
  1054b3:	c3                   	ret    

001054b4 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1054b4:	55                   	push   %ebp
  1054b5:	89 e5                	mov    %esp,%ebp
  1054b7:	83 ec 04             	sub    $0x4,%esp
  1054ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054bd:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1054c0:	eb 13                	jmp    1054d5 <strchr+0x21>
        if (*s == c) {
  1054c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1054c5:	0f b6 00             	movzbl (%eax),%eax
  1054c8:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1054cb:	75 05                	jne    1054d2 <strchr+0x1e>
            return (char *)s;
  1054cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1054d0:	eb 12                	jmp    1054e4 <strchr+0x30>
        }
        s ++;
  1054d2:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1054d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1054d8:	0f b6 00             	movzbl (%eax),%eax
  1054db:	84 c0                	test   %al,%al
  1054dd:	75 e3                	jne    1054c2 <strchr+0xe>
    }
    return NULL;
  1054df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1054e4:	c9                   	leave  
  1054e5:	c3                   	ret    

001054e6 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1054e6:	55                   	push   %ebp
  1054e7:	89 e5                	mov    %esp,%ebp
  1054e9:	83 ec 04             	sub    $0x4,%esp
  1054ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054ef:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1054f2:	eb 0e                	jmp    105502 <strfind+0x1c>
        if (*s == c) {
  1054f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1054f7:	0f b6 00             	movzbl (%eax),%eax
  1054fa:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1054fd:	74 0f                	je     10550e <strfind+0x28>
            break;
        }
        s ++;
  1054ff:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105502:	8b 45 08             	mov    0x8(%ebp),%eax
  105505:	0f b6 00             	movzbl (%eax),%eax
  105508:	84 c0                	test   %al,%al
  10550a:	75 e8                	jne    1054f4 <strfind+0xe>
  10550c:	eb 01                	jmp    10550f <strfind+0x29>
            break;
  10550e:	90                   	nop
    }
    return (char *)s;
  10550f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105512:	c9                   	leave  
  105513:	c3                   	ret    

00105514 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105514:	55                   	push   %ebp
  105515:	89 e5                	mov    %esp,%ebp
  105517:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10551a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105521:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105528:	eb 03                	jmp    10552d <strtol+0x19>
        s ++;
  10552a:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10552d:	8b 45 08             	mov    0x8(%ebp),%eax
  105530:	0f b6 00             	movzbl (%eax),%eax
  105533:	3c 20                	cmp    $0x20,%al
  105535:	74 f3                	je     10552a <strtol+0x16>
  105537:	8b 45 08             	mov    0x8(%ebp),%eax
  10553a:	0f b6 00             	movzbl (%eax),%eax
  10553d:	3c 09                	cmp    $0x9,%al
  10553f:	74 e9                	je     10552a <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105541:	8b 45 08             	mov    0x8(%ebp),%eax
  105544:	0f b6 00             	movzbl (%eax),%eax
  105547:	3c 2b                	cmp    $0x2b,%al
  105549:	75 05                	jne    105550 <strtol+0x3c>
        s ++;
  10554b:	ff 45 08             	incl   0x8(%ebp)
  10554e:	eb 14                	jmp    105564 <strtol+0x50>
    }
    else if (*s == '-') {
  105550:	8b 45 08             	mov    0x8(%ebp),%eax
  105553:	0f b6 00             	movzbl (%eax),%eax
  105556:	3c 2d                	cmp    $0x2d,%al
  105558:	75 0a                	jne    105564 <strtol+0x50>
        s ++, neg = 1;
  10555a:	ff 45 08             	incl   0x8(%ebp)
  10555d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105564:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105568:	74 06                	je     105570 <strtol+0x5c>
  10556a:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10556e:	75 22                	jne    105592 <strtol+0x7e>
  105570:	8b 45 08             	mov    0x8(%ebp),%eax
  105573:	0f b6 00             	movzbl (%eax),%eax
  105576:	3c 30                	cmp    $0x30,%al
  105578:	75 18                	jne    105592 <strtol+0x7e>
  10557a:	8b 45 08             	mov    0x8(%ebp),%eax
  10557d:	40                   	inc    %eax
  10557e:	0f b6 00             	movzbl (%eax),%eax
  105581:	3c 78                	cmp    $0x78,%al
  105583:	75 0d                	jne    105592 <strtol+0x7e>
        s += 2, base = 16;
  105585:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105589:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105590:	eb 29                	jmp    1055bb <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105592:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105596:	75 16                	jne    1055ae <strtol+0x9a>
  105598:	8b 45 08             	mov    0x8(%ebp),%eax
  10559b:	0f b6 00             	movzbl (%eax),%eax
  10559e:	3c 30                	cmp    $0x30,%al
  1055a0:	75 0c                	jne    1055ae <strtol+0x9a>
        s ++, base = 8;
  1055a2:	ff 45 08             	incl   0x8(%ebp)
  1055a5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1055ac:	eb 0d                	jmp    1055bb <strtol+0xa7>
    }
    else if (base == 0) {
  1055ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055b2:	75 07                	jne    1055bb <strtol+0xa7>
        base = 10;
  1055b4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1055bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1055be:	0f b6 00             	movzbl (%eax),%eax
  1055c1:	3c 2f                	cmp    $0x2f,%al
  1055c3:	7e 1b                	jle    1055e0 <strtol+0xcc>
  1055c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c8:	0f b6 00             	movzbl (%eax),%eax
  1055cb:	3c 39                	cmp    $0x39,%al
  1055cd:	7f 11                	jg     1055e0 <strtol+0xcc>
            dig = *s - '0';
  1055cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d2:	0f b6 00             	movzbl (%eax),%eax
  1055d5:	0f be c0             	movsbl %al,%eax
  1055d8:	83 e8 30             	sub    $0x30,%eax
  1055db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1055de:	eb 48                	jmp    105628 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1055e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1055e3:	0f b6 00             	movzbl (%eax),%eax
  1055e6:	3c 60                	cmp    $0x60,%al
  1055e8:	7e 1b                	jle    105605 <strtol+0xf1>
  1055ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ed:	0f b6 00             	movzbl (%eax),%eax
  1055f0:	3c 7a                	cmp    $0x7a,%al
  1055f2:	7f 11                	jg     105605 <strtol+0xf1>
            dig = *s - 'a' + 10;
  1055f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f7:	0f b6 00             	movzbl (%eax),%eax
  1055fa:	0f be c0             	movsbl %al,%eax
  1055fd:	83 e8 57             	sub    $0x57,%eax
  105600:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105603:	eb 23                	jmp    105628 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105605:	8b 45 08             	mov    0x8(%ebp),%eax
  105608:	0f b6 00             	movzbl (%eax),%eax
  10560b:	3c 40                	cmp    $0x40,%al
  10560d:	7e 3b                	jle    10564a <strtol+0x136>
  10560f:	8b 45 08             	mov    0x8(%ebp),%eax
  105612:	0f b6 00             	movzbl (%eax),%eax
  105615:	3c 5a                	cmp    $0x5a,%al
  105617:	7f 31                	jg     10564a <strtol+0x136>
            dig = *s - 'A' + 10;
  105619:	8b 45 08             	mov    0x8(%ebp),%eax
  10561c:	0f b6 00             	movzbl (%eax),%eax
  10561f:	0f be c0             	movsbl %al,%eax
  105622:	83 e8 37             	sub    $0x37,%eax
  105625:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10562b:	3b 45 10             	cmp    0x10(%ebp),%eax
  10562e:	7d 19                	jge    105649 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105630:	ff 45 08             	incl   0x8(%ebp)
  105633:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105636:	0f af 45 10          	imul   0x10(%ebp),%eax
  10563a:	89 c2                	mov    %eax,%edx
  10563c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10563f:	01 d0                	add    %edx,%eax
  105641:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  105644:	e9 72 ff ff ff       	jmp    1055bb <strtol+0xa7>
            break;
  105649:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10564a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10564e:	74 08                	je     105658 <strtol+0x144>
        *endptr = (char *) s;
  105650:	8b 45 0c             	mov    0xc(%ebp),%eax
  105653:	8b 55 08             	mov    0x8(%ebp),%edx
  105656:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105658:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10565c:	74 07                	je     105665 <strtol+0x151>
  10565e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105661:	f7 d8                	neg    %eax
  105663:	eb 03                	jmp    105668 <strtol+0x154>
  105665:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105668:	c9                   	leave  
  105669:	c3                   	ret    

0010566a <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10566a:	55                   	push   %ebp
  10566b:	89 e5                	mov    %esp,%ebp
  10566d:	57                   	push   %edi
  10566e:	83 ec 24             	sub    $0x24,%esp
  105671:	8b 45 0c             	mov    0xc(%ebp),%eax
  105674:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105677:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10567b:	8b 55 08             	mov    0x8(%ebp),%edx
  10567e:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105681:	88 45 f7             	mov    %al,-0x9(%ebp)
  105684:	8b 45 10             	mov    0x10(%ebp),%eax
  105687:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10568a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10568d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105691:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105694:	89 d7                	mov    %edx,%edi
  105696:	f3 aa                	rep stos %al,%es:(%edi)
  105698:	89 fa                	mov    %edi,%edx
  10569a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10569d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1056a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056a3:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1056a4:	83 c4 24             	add    $0x24,%esp
  1056a7:	5f                   	pop    %edi
  1056a8:	5d                   	pop    %ebp
  1056a9:	c3                   	ret    

001056aa <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1056aa:	55                   	push   %ebp
  1056ab:	89 e5                	mov    %esp,%ebp
  1056ad:	57                   	push   %edi
  1056ae:	56                   	push   %esi
  1056af:	53                   	push   %ebx
  1056b0:	83 ec 30             	sub    $0x30,%esp
  1056b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1056bf:	8b 45 10             	mov    0x10(%ebp),%eax
  1056c2:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1056c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056c8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1056cb:	73 42                	jae    10570f <memmove+0x65>
  1056cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1056d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1056d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1056df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1056e2:	c1 e8 02             	shr    $0x2,%eax
  1056e5:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1056e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1056ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1056ed:	89 d7                	mov    %edx,%edi
  1056ef:	89 c6                	mov    %eax,%esi
  1056f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1056f3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1056f6:	83 e1 03             	and    $0x3,%ecx
  1056f9:	74 02                	je     1056fd <memmove+0x53>
  1056fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1056fd:	89 f0                	mov    %esi,%eax
  1056ff:	89 fa                	mov    %edi,%edx
  105701:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105704:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105707:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10570a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  10570d:	eb 36                	jmp    105745 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10570f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105712:	8d 50 ff             	lea    -0x1(%eax),%edx
  105715:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105718:	01 c2                	add    %eax,%edx
  10571a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10571d:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105723:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105726:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105729:	89 c1                	mov    %eax,%ecx
  10572b:	89 d8                	mov    %ebx,%eax
  10572d:	89 d6                	mov    %edx,%esi
  10572f:	89 c7                	mov    %eax,%edi
  105731:	fd                   	std    
  105732:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105734:	fc                   	cld    
  105735:	89 f8                	mov    %edi,%eax
  105737:	89 f2                	mov    %esi,%edx
  105739:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  10573c:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10573f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105742:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105745:	83 c4 30             	add    $0x30,%esp
  105748:	5b                   	pop    %ebx
  105749:	5e                   	pop    %esi
  10574a:	5f                   	pop    %edi
  10574b:	5d                   	pop    %ebp
  10574c:	c3                   	ret    

0010574d <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10574d:	55                   	push   %ebp
  10574e:	89 e5                	mov    %esp,%ebp
  105750:	57                   	push   %edi
  105751:	56                   	push   %esi
  105752:	83 ec 20             	sub    $0x20,%esp
  105755:	8b 45 08             	mov    0x8(%ebp),%eax
  105758:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10575b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10575e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105761:	8b 45 10             	mov    0x10(%ebp),%eax
  105764:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105767:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10576a:	c1 e8 02             	shr    $0x2,%eax
  10576d:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10576f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105775:	89 d7                	mov    %edx,%edi
  105777:	89 c6                	mov    %eax,%esi
  105779:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10577b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10577e:	83 e1 03             	and    $0x3,%ecx
  105781:	74 02                	je     105785 <memcpy+0x38>
  105783:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105785:	89 f0                	mov    %esi,%eax
  105787:	89 fa                	mov    %edi,%edx
  105789:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10578c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10578f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105792:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105795:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105796:	83 c4 20             	add    $0x20,%esp
  105799:	5e                   	pop    %esi
  10579a:	5f                   	pop    %edi
  10579b:	5d                   	pop    %ebp
  10579c:	c3                   	ret    

0010579d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10579d:	55                   	push   %ebp
  10579e:	89 e5                	mov    %esp,%ebp
  1057a0:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1057a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1057a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1057af:	eb 2e                	jmp    1057df <memcmp+0x42>
        if (*s1 != *s2) {
  1057b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1057b4:	0f b6 10             	movzbl (%eax),%edx
  1057b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057ba:	0f b6 00             	movzbl (%eax),%eax
  1057bd:	38 c2                	cmp    %al,%dl
  1057bf:	74 18                	je     1057d9 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1057c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1057c4:	0f b6 00             	movzbl (%eax),%eax
  1057c7:	0f b6 d0             	movzbl %al,%edx
  1057ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1057cd:	0f b6 00             	movzbl (%eax),%eax
  1057d0:	0f b6 c0             	movzbl %al,%eax
  1057d3:	29 c2                	sub    %eax,%edx
  1057d5:	89 d0                	mov    %edx,%eax
  1057d7:	eb 18                	jmp    1057f1 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1057d9:	ff 45 fc             	incl   -0x4(%ebp)
  1057dc:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  1057df:	8b 45 10             	mov    0x10(%ebp),%eax
  1057e2:	8d 50 ff             	lea    -0x1(%eax),%edx
  1057e5:	89 55 10             	mov    %edx,0x10(%ebp)
  1057e8:	85 c0                	test   %eax,%eax
  1057ea:	75 c5                	jne    1057b1 <memcmp+0x14>
    }
    return 0;
  1057ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1057f1:	c9                   	leave  
  1057f2:	c3                   	ret    

001057f3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1057f3:	55                   	push   %ebp
  1057f4:	89 e5                	mov    %esp,%ebp
  1057f6:	83 ec 58             	sub    $0x58,%esp
  1057f9:	8b 45 10             	mov    0x10(%ebp),%eax
  1057fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1057ff:	8b 45 14             	mov    0x14(%ebp),%eax
  105802:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105805:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105808:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10580b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10580e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105811:	8b 45 18             	mov    0x18(%ebp),%eax
  105814:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105817:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10581a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10581d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105820:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105823:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105826:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105829:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10582d:	74 1c                	je     10584b <printnum+0x58>
  10582f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105832:	ba 00 00 00 00       	mov    $0x0,%edx
  105837:	f7 75 e4             	divl   -0x1c(%ebp)
  10583a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10583d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105840:	ba 00 00 00 00       	mov    $0x0,%edx
  105845:	f7 75 e4             	divl   -0x1c(%ebp)
  105848:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10584b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10584e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105851:	f7 75 e4             	divl   -0x1c(%ebp)
  105854:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105857:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10585a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10585d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105860:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105863:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105866:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105869:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10586c:	8b 45 18             	mov    0x18(%ebp),%eax
  10586f:	ba 00 00 00 00       	mov    $0x0,%edx
  105874:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105877:	72 56                	jb     1058cf <printnum+0xdc>
  105879:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  10587c:	77 05                	ja     105883 <printnum+0x90>
  10587e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105881:	72 4c                	jb     1058cf <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105883:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105886:	8d 50 ff             	lea    -0x1(%eax),%edx
  105889:	8b 45 20             	mov    0x20(%ebp),%eax
  10588c:	89 44 24 18          	mov    %eax,0x18(%esp)
  105890:	89 54 24 14          	mov    %edx,0x14(%esp)
  105894:	8b 45 18             	mov    0x18(%ebp),%eax
  105897:	89 44 24 10          	mov    %eax,0x10(%esp)
  10589b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10589e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1058a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1058a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1058b3:	89 04 24             	mov    %eax,(%esp)
  1058b6:	e8 38 ff ff ff       	call   1057f3 <printnum>
  1058bb:	eb 1b                	jmp    1058d8 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1058bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058c4:	8b 45 20             	mov    0x20(%ebp),%eax
  1058c7:	89 04 24             	mov    %eax,(%esp)
  1058ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1058cd:	ff d0                	call   *%eax
        while (-- width > 0)
  1058cf:	ff 4d 1c             	decl   0x1c(%ebp)
  1058d2:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1058d6:	7f e5                	jg     1058bd <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1058d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1058db:	05 54 70 10 00       	add    $0x107054,%eax
  1058e0:	0f b6 00             	movzbl (%eax),%eax
  1058e3:	0f be c0             	movsbl %al,%eax
  1058e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1058e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1058ed:	89 04 24             	mov    %eax,(%esp)
  1058f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1058f3:	ff d0                	call   *%eax
}
  1058f5:	90                   	nop
  1058f6:	c9                   	leave  
  1058f7:	c3                   	ret    

001058f8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1058f8:	55                   	push   %ebp
  1058f9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1058fb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1058ff:	7e 14                	jle    105915 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105901:	8b 45 08             	mov    0x8(%ebp),%eax
  105904:	8b 00                	mov    (%eax),%eax
  105906:	8d 48 08             	lea    0x8(%eax),%ecx
  105909:	8b 55 08             	mov    0x8(%ebp),%edx
  10590c:	89 0a                	mov    %ecx,(%edx)
  10590e:	8b 50 04             	mov    0x4(%eax),%edx
  105911:	8b 00                	mov    (%eax),%eax
  105913:	eb 30                	jmp    105945 <getuint+0x4d>
    }
    else if (lflag) {
  105915:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105919:	74 16                	je     105931 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10591b:	8b 45 08             	mov    0x8(%ebp),%eax
  10591e:	8b 00                	mov    (%eax),%eax
  105920:	8d 48 04             	lea    0x4(%eax),%ecx
  105923:	8b 55 08             	mov    0x8(%ebp),%edx
  105926:	89 0a                	mov    %ecx,(%edx)
  105928:	8b 00                	mov    (%eax),%eax
  10592a:	ba 00 00 00 00       	mov    $0x0,%edx
  10592f:	eb 14                	jmp    105945 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105931:	8b 45 08             	mov    0x8(%ebp),%eax
  105934:	8b 00                	mov    (%eax),%eax
  105936:	8d 48 04             	lea    0x4(%eax),%ecx
  105939:	8b 55 08             	mov    0x8(%ebp),%edx
  10593c:	89 0a                	mov    %ecx,(%edx)
  10593e:	8b 00                	mov    (%eax),%eax
  105940:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105945:	5d                   	pop    %ebp
  105946:	c3                   	ret    

00105947 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105947:	55                   	push   %ebp
  105948:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10594a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10594e:	7e 14                	jle    105964 <getint+0x1d>
        return va_arg(*ap, long long);
  105950:	8b 45 08             	mov    0x8(%ebp),%eax
  105953:	8b 00                	mov    (%eax),%eax
  105955:	8d 48 08             	lea    0x8(%eax),%ecx
  105958:	8b 55 08             	mov    0x8(%ebp),%edx
  10595b:	89 0a                	mov    %ecx,(%edx)
  10595d:	8b 50 04             	mov    0x4(%eax),%edx
  105960:	8b 00                	mov    (%eax),%eax
  105962:	eb 28                	jmp    10598c <getint+0x45>
    }
    else if (lflag) {
  105964:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105968:	74 12                	je     10597c <getint+0x35>
        return va_arg(*ap, long);
  10596a:	8b 45 08             	mov    0x8(%ebp),%eax
  10596d:	8b 00                	mov    (%eax),%eax
  10596f:	8d 48 04             	lea    0x4(%eax),%ecx
  105972:	8b 55 08             	mov    0x8(%ebp),%edx
  105975:	89 0a                	mov    %ecx,(%edx)
  105977:	8b 00                	mov    (%eax),%eax
  105979:	99                   	cltd   
  10597a:	eb 10                	jmp    10598c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10597c:	8b 45 08             	mov    0x8(%ebp),%eax
  10597f:	8b 00                	mov    (%eax),%eax
  105981:	8d 48 04             	lea    0x4(%eax),%ecx
  105984:	8b 55 08             	mov    0x8(%ebp),%edx
  105987:	89 0a                	mov    %ecx,(%edx)
  105989:	8b 00                	mov    (%eax),%eax
  10598b:	99                   	cltd   
    }
}
  10598c:	5d                   	pop    %ebp
  10598d:	c3                   	ret    

0010598e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10598e:	55                   	push   %ebp
  10598f:	89 e5                	mov    %esp,%ebp
  105991:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105994:	8d 45 14             	lea    0x14(%ebp),%eax
  105997:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10599a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10599d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1059a1:	8b 45 10             	mov    0x10(%ebp),%eax
  1059a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059af:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b2:	89 04 24             	mov    %eax,(%esp)
  1059b5:	e8 03 00 00 00       	call   1059bd <vprintfmt>
    va_end(ap);
}
  1059ba:	90                   	nop
  1059bb:	c9                   	leave  
  1059bc:	c3                   	ret    

001059bd <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1059bd:	55                   	push   %ebp
  1059be:	89 e5                	mov    %esp,%ebp
  1059c0:	56                   	push   %esi
  1059c1:	53                   	push   %ebx
  1059c2:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059c5:	eb 17                	jmp    1059de <vprintfmt+0x21>
            if (ch == '\0') {
  1059c7:	85 db                	test   %ebx,%ebx
  1059c9:	0f 84 bf 03 00 00    	je     105d8e <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1059cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059d6:	89 1c 24             	mov    %ebx,(%esp)
  1059d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1059dc:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059de:	8b 45 10             	mov    0x10(%ebp),%eax
  1059e1:	8d 50 01             	lea    0x1(%eax),%edx
  1059e4:	89 55 10             	mov    %edx,0x10(%ebp)
  1059e7:	0f b6 00             	movzbl (%eax),%eax
  1059ea:	0f b6 d8             	movzbl %al,%ebx
  1059ed:	83 fb 25             	cmp    $0x25,%ebx
  1059f0:	75 d5                	jne    1059c7 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1059f2:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1059f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1059fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a00:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105a03:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105a0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105a0d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105a10:	8b 45 10             	mov    0x10(%ebp),%eax
  105a13:	8d 50 01             	lea    0x1(%eax),%edx
  105a16:	89 55 10             	mov    %edx,0x10(%ebp)
  105a19:	0f b6 00             	movzbl (%eax),%eax
  105a1c:	0f b6 d8             	movzbl %al,%ebx
  105a1f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105a22:	83 f8 55             	cmp    $0x55,%eax
  105a25:	0f 87 37 03 00 00    	ja     105d62 <vprintfmt+0x3a5>
  105a2b:	8b 04 85 78 70 10 00 	mov    0x107078(,%eax,4),%eax
  105a32:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105a34:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105a38:	eb d6                	jmp    105a10 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105a3a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105a3e:	eb d0                	jmp    105a10 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105a40:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105a47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105a4a:	89 d0                	mov    %edx,%eax
  105a4c:	c1 e0 02             	shl    $0x2,%eax
  105a4f:	01 d0                	add    %edx,%eax
  105a51:	01 c0                	add    %eax,%eax
  105a53:	01 d8                	add    %ebx,%eax
  105a55:	83 e8 30             	sub    $0x30,%eax
  105a58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105a5b:	8b 45 10             	mov    0x10(%ebp),%eax
  105a5e:	0f b6 00             	movzbl (%eax),%eax
  105a61:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105a64:	83 fb 2f             	cmp    $0x2f,%ebx
  105a67:	7e 38                	jle    105aa1 <vprintfmt+0xe4>
  105a69:	83 fb 39             	cmp    $0x39,%ebx
  105a6c:	7f 33                	jg     105aa1 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105a6e:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105a71:	eb d4                	jmp    105a47 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105a73:	8b 45 14             	mov    0x14(%ebp),%eax
  105a76:	8d 50 04             	lea    0x4(%eax),%edx
  105a79:	89 55 14             	mov    %edx,0x14(%ebp)
  105a7c:	8b 00                	mov    (%eax),%eax
  105a7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105a81:	eb 1f                	jmp    105aa2 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105a83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a87:	79 87                	jns    105a10 <vprintfmt+0x53>
                width = 0;
  105a89:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105a90:	e9 7b ff ff ff       	jmp    105a10 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105a95:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105a9c:	e9 6f ff ff ff       	jmp    105a10 <vprintfmt+0x53>
            goto process_precision;
  105aa1:	90                   	nop

        process_precision:
            if (width < 0)
  105aa2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105aa6:	0f 89 64 ff ff ff    	jns    105a10 <vprintfmt+0x53>
                width = precision, precision = -1;
  105aac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105aaf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105ab2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105ab9:	e9 52 ff ff ff       	jmp    105a10 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105abe:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105ac1:	e9 4a ff ff ff       	jmp    105a10 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  105ac9:	8d 50 04             	lea    0x4(%eax),%edx
  105acc:	89 55 14             	mov    %edx,0x14(%ebp)
  105acf:	8b 00                	mov    (%eax),%eax
  105ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ad4:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ad8:	89 04 24             	mov    %eax,(%esp)
  105adb:	8b 45 08             	mov    0x8(%ebp),%eax
  105ade:	ff d0                	call   *%eax
            break;
  105ae0:	e9 a4 02 00 00       	jmp    105d89 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  105ae8:	8d 50 04             	lea    0x4(%eax),%edx
  105aeb:	89 55 14             	mov    %edx,0x14(%ebp)
  105aee:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105af0:	85 db                	test   %ebx,%ebx
  105af2:	79 02                	jns    105af6 <vprintfmt+0x139>
                err = -err;
  105af4:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105af6:	83 fb 06             	cmp    $0x6,%ebx
  105af9:	7f 0b                	jg     105b06 <vprintfmt+0x149>
  105afb:	8b 34 9d 38 70 10 00 	mov    0x107038(,%ebx,4),%esi
  105b02:	85 f6                	test   %esi,%esi
  105b04:	75 23                	jne    105b29 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105b06:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105b0a:	c7 44 24 08 65 70 10 	movl   $0x107065,0x8(%esp)
  105b11:	00 
  105b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b19:	8b 45 08             	mov    0x8(%ebp),%eax
  105b1c:	89 04 24             	mov    %eax,(%esp)
  105b1f:	e8 6a fe ff ff       	call   10598e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105b24:	e9 60 02 00 00       	jmp    105d89 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105b29:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105b2d:	c7 44 24 08 6e 70 10 	movl   $0x10706e,0x8(%esp)
  105b34:	00 
  105b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b3f:	89 04 24             	mov    %eax,(%esp)
  105b42:	e8 47 fe ff ff       	call   10598e <printfmt>
            break;
  105b47:	e9 3d 02 00 00       	jmp    105d89 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105b4c:	8b 45 14             	mov    0x14(%ebp),%eax
  105b4f:	8d 50 04             	lea    0x4(%eax),%edx
  105b52:	89 55 14             	mov    %edx,0x14(%ebp)
  105b55:	8b 30                	mov    (%eax),%esi
  105b57:	85 f6                	test   %esi,%esi
  105b59:	75 05                	jne    105b60 <vprintfmt+0x1a3>
                p = "(null)";
  105b5b:	be 71 70 10 00       	mov    $0x107071,%esi
            }
            if (width > 0 && padc != '-') {
  105b60:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b64:	7e 76                	jle    105bdc <vprintfmt+0x21f>
  105b66:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105b6a:	74 70                	je     105bdc <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105b6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b73:	89 34 24             	mov    %esi,(%esp)
  105b76:	e8 f6 f7 ff ff       	call   105371 <strnlen>
  105b7b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105b7e:	29 c2                	sub    %eax,%edx
  105b80:	89 d0                	mov    %edx,%eax
  105b82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b85:	eb 16                	jmp    105b9d <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105b87:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b92:	89 04 24             	mov    %eax,(%esp)
  105b95:	8b 45 08             	mov    0x8(%ebp),%eax
  105b98:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105b9a:	ff 4d e8             	decl   -0x18(%ebp)
  105b9d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ba1:	7f e4                	jg     105b87 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105ba3:	eb 37                	jmp    105bdc <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105ba5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105ba9:	74 1f                	je     105bca <vprintfmt+0x20d>
  105bab:	83 fb 1f             	cmp    $0x1f,%ebx
  105bae:	7e 05                	jle    105bb5 <vprintfmt+0x1f8>
  105bb0:	83 fb 7e             	cmp    $0x7e,%ebx
  105bb3:	7e 15                	jle    105bca <vprintfmt+0x20d>
                    putch('?', putdat);
  105bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bbc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  105bc6:	ff d0                	call   *%eax
  105bc8:	eb 0f                	jmp    105bd9 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd1:	89 1c 24             	mov    %ebx,(%esp)
  105bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd7:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105bd9:	ff 4d e8             	decl   -0x18(%ebp)
  105bdc:	89 f0                	mov    %esi,%eax
  105bde:	8d 70 01             	lea    0x1(%eax),%esi
  105be1:	0f b6 00             	movzbl (%eax),%eax
  105be4:	0f be d8             	movsbl %al,%ebx
  105be7:	85 db                	test   %ebx,%ebx
  105be9:	74 27                	je     105c12 <vprintfmt+0x255>
  105beb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105bef:	78 b4                	js     105ba5 <vprintfmt+0x1e8>
  105bf1:	ff 4d e4             	decl   -0x1c(%ebp)
  105bf4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105bf8:	79 ab                	jns    105ba5 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105bfa:	eb 16                	jmp    105c12 <vprintfmt+0x255>
                putch(' ', putdat);
  105bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c03:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c0d:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105c0f:	ff 4d e8             	decl   -0x18(%ebp)
  105c12:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c16:	7f e4                	jg     105bfc <vprintfmt+0x23f>
            }
            break;
  105c18:	e9 6c 01 00 00       	jmp    105d89 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105c1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c24:	8d 45 14             	lea    0x14(%ebp),%eax
  105c27:	89 04 24             	mov    %eax,(%esp)
  105c2a:	e8 18 fd ff ff       	call   105947 <getint>
  105c2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c32:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c3b:	85 d2                	test   %edx,%edx
  105c3d:	79 26                	jns    105c65 <vprintfmt+0x2a8>
                putch('-', putdat);
  105c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c46:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c50:	ff d0                	call   *%eax
                num = -(long long)num;
  105c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c58:	f7 d8                	neg    %eax
  105c5a:	83 d2 00             	adc    $0x0,%edx
  105c5d:	f7 da                	neg    %edx
  105c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c62:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105c65:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105c6c:	e9 a8 00 00 00       	jmp    105d19 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c78:	8d 45 14             	lea    0x14(%ebp),%eax
  105c7b:	89 04 24             	mov    %eax,(%esp)
  105c7e:	e8 75 fc ff ff       	call   1058f8 <getuint>
  105c83:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c86:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105c89:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105c90:	e9 84 00 00 00       	jmp    105d19 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c9c:	8d 45 14             	lea    0x14(%ebp),%eax
  105c9f:	89 04 24             	mov    %eax,(%esp)
  105ca2:	e8 51 fc ff ff       	call   1058f8 <getuint>
  105ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105caa:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105cad:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105cb4:	eb 63                	jmp    105d19 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cbd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc7:	ff d0                	call   *%eax
            putch('x', putdat);
  105cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cd0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  105cda:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105cdc:	8b 45 14             	mov    0x14(%ebp),%eax
  105cdf:	8d 50 04             	lea    0x4(%eax),%edx
  105ce2:	89 55 14             	mov    %edx,0x14(%ebp)
  105ce5:	8b 00                	mov    (%eax),%eax
  105ce7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105cf1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105cf8:	eb 1f                	jmp    105d19 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105cfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d01:	8d 45 14             	lea    0x14(%ebp),%eax
  105d04:	89 04 24             	mov    %eax,(%esp)
  105d07:	e8 ec fb ff ff       	call   1058f8 <getuint>
  105d0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105d12:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105d19:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105d1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d20:	89 54 24 18          	mov    %edx,0x18(%esp)
  105d24:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105d27:	89 54 24 14          	mov    %edx,0x14(%esp)
  105d2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d35:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d39:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d44:	8b 45 08             	mov    0x8(%ebp),%eax
  105d47:	89 04 24             	mov    %eax,(%esp)
  105d4a:	e8 a4 fa ff ff       	call   1057f3 <printnum>
            break;
  105d4f:	eb 38                	jmp    105d89 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d54:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d58:	89 1c 24             	mov    %ebx,(%esp)
  105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5e:	ff d0                	call   *%eax
            break;
  105d60:	eb 27                	jmp    105d89 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105d62:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d69:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105d70:	8b 45 08             	mov    0x8(%ebp),%eax
  105d73:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105d75:	ff 4d 10             	decl   0x10(%ebp)
  105d78:	eb 03                	jmp    105d7d <vprintfmt+0x3c0>
  105d7a:	ff 4d 10             	decl   0x10(%ebp)
  105d7d:	8b 45 10             	mov    0x10(%ebp),%eax
  105d80:	48                   	dec    %eax
  105d81:	0f b6 00             	movzbl (%eax),%eax
  105d84:	3c 25                	cmp    $0x25,%al
  105d86:	75 f2                	jne    105d7a <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105d88:	90                   	nop
    while (1) {
  105d89:	e9 37 fc ff ff       	jmp    1059c5 <vprintfmt+0x8>
                return;
  105d8e:	90                   	nop
        }
    }
}
  105d8f:	83 c4 40             	add    $0x40,%esp
  105d92:	5b                   	pop    %ebx
  105d93:	5e                   	pop    %esi
  105d94:	5d                   	pop    %ebp
  105d95:	c3                   	ret    

00105d96 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105d96:	55                   	push   %ebp
  105d97:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d9c:	8b 40 08             	mov    0x8(%eax),%eax
  105d9f:	8d 50 01             	lea    0x1(%eax),%edx
  105da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105da5:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dab:	8b 10                	mov    (%eax),%edx
  105dad:	8b 45 0c             	mov    0xc(%ebp),%eax
  105db0:	8b 40 04             	mov    0x4(%eax),%eax
  105db3:	39 c2                	cmp    %eax,%edx
  105db5:	73 12                	jae    105dc9 <sprintputch+0x33>
        *b->buf ++ = ch;
  105db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dba:	8b 00                	mov    (%eax),%eax
  105dbc:	8d 48 01             	lea    0x1(%eax),%ecx
  105dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  105dc2:	89 0a                	mov    %ecx,(%edx)
  105dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  105dc7:	88 10                	mov    %dl,(%eax)
    }
}
  105dc9:	90                   	nop
  105dca:	5d                   	pop    %ebp
  105dcb:	c3                   	ret    

00105dcc <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105dcc:	55                   	push   %ebp
  105dcd:	89 e5                	mov    %esp,%ebp
  105dcf:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105dd2:	8d 45 14             	lea    0x14(%ebp),%eax
  105dd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ddb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ddf:	8b 45 10             	mov    0x10(%ebp),%eax
  105de2:	89 44 24 08          	mov    %eax,0x8(%esp)
  105de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ded:	8b 45 08             	mov    0x8(%ebp),%eax
  105df0:	89 04 24             	mov    %eax,(%esp)
  105df3:	e8 08 00 00 00       	call   105e00 <vsnprintf>
  105df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105dfe:	c9                   	leave  
  105dff:	c3                   	ret    

00105e00 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105e00:	55                   	push   %ebp
  105e01:	89 e5                	mov    %esp,%ebp
  105e03:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105e06:	8b 45 08             	mov    0x8(%ebp),%eax
  105e09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e0f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e12:	8b 45 08             	mov    0x8(%ebp),%eax
  105e15:	01 d0                	add    %edx,%eax
  105e17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105e21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105e25:	74 0a                	je     105e31 <vsnprintf+0x31>
  105e27:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e2d:	39 c2                	cmp    %eax,%edx
  105e2f:	76 07                	jbe    105e38 <vsnprintf+0x38>
        return -E_INVAL;
  105e31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105e36:	eb 2a                	jmp    105e62 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105e38:	8b 45 14             	mov    0x14(%ebp),%eax
  105e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105e3f:	8b 45 10             	mov    0x10(%ebp),%eax
  105e42:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e46:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105e49:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e4d:	c7 04 24 96 5d 10 00 	movl   $0x105d96,(%esp)
  105e54:	e8 64 fb ff ff       	call   1059bd <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e5c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105e62:	c9                   	leave  
  105e63:	c3                   	ret    
