
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 11 00       	mov    $0x119000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 11 c0       	mov    %eax,0xc0119000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 11 c0       	mov    $0xc0118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 bf 11 c0       	mov    $0xc011bf28,%edx
c0100041:	b8 00 b0 11 c0       	mov    $0xc011b000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 b0 11 c0 	movl   $0xc011b000,(%esp)
c010005d:	e8 a5 57 00 00       	call   c0105807 <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 20 60 10 c0 	movl   $0xc0106020,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 3c 60 10 c0 	movl   $0xc010603c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 22 31 00 00       	call   c01031b2 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 b7 16 00 00       	call   c010174c <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 17 18 00 00       	call   c01018b1 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 eb 0c 00 00       	call   c0100d8a <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 e2 17 00 00       	call   c0101886 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 b0 0c 00 00       	call   c0100d78 <mon_backtrace>
}
c01000c8:	90                   	nop
c01000c9:	c9                   	leave  
c01000ca:	c3                   	ret    

c01000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cb:	55                   	push   %ebp
c01000cc:	89 e5                	mov    %esp,%ebp
c01000ce:	53                   	push   %ebx
c01000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b4 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	83 c4 14             	add    $0x14,%esp
c01000f6:	5b                   	pop    %ebx
c01000f7:	5d                   	pop    %ebp
c01000f8:	c3                   	ret    

c01000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f9:	55                   	push   %ebp
c01000fa:	89 e5                	mov    %esp,%ebp
c01000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0100102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100106:	8b 45 08             	mov    0x8(%ebp),%eax
c0100109:	89 04 24             	mov    %eax,(%esp)
c010010c:	e8 ba ff ff ff       	call   c01000cb <grade_backtrace1>
}
c0100111:	90                   	nop
c0100112:	c9                   	leave  
c0100113:	c3                   	ret    

c0100114 <grade_backtrace>:

void
grade_backtrace(void) {
c0100114:	55                   	push   %ebp
c0100115:	89 e5                	mov    %esp,%ebp
c0100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011a:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100126:	ff 
c0100127:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100132:	e8 c2 ff ff ff       	call   c01000f9 <grade_backtrace0>
}
c0100137:	90                   	nop
c0100138:	c9                   	leave  
c0100139:	c3                   	ret    

c010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013a:	55                   	push   %ebp
c010013b:	89 e5                	mov    %esp,%ebp
c010013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100150:	83 e0 03             	and    $0x3,%eax
c0100153:	89 c2                	mov    %eax,%edx
c0100155:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010015a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100162:	c7 04 24 41 60 10 c0 	movl   $0xc0106041,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 4f 60 10 c0 	movl   $0xc010604f,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 5d 60 10 c0 	movl   $0xc010605d,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 6b 60 10 c0 	movl   $0xc010606b,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 79 60 10 c0 	movl   $0xc0106079,(%esp)
c01001e5:	e8 a8 00 00 00       	call   c0100292 <cprintf>
    round ++;
c01001ea:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001ef:	40                   	inc    %eax
c01001f0:	a3 00 b0 11 c0       	mov    %eax,0xc011b000
}
c01001f5:	90                   	nop
c01001f6:	c9                   	leave  
c01001f7:	c3                   	ret    

c01001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f8:	55                   	push   %ebp
c01001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001fb:	90                   	nop
c01001fc:	5d                   	pop    %ebp
c01001fd:	c3                   	ret    

c01001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001fe:	55                   	push   %ebp
c01001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100201:	90                   	nop
c0100202:	5d                   	pop    %ebp
c0100203:	c3                   	ret    

c0100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100204:	55                   	push   %ebp
c0100205:	89 e5                	mov    %esp,%ebp
c0100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020a:	e8 2b ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010020f:	c7 04 24 88 60 10 c0 	movl   $0xc0106088,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 a8 60 10 c0 	movl   $0xc01060a8,(%esp)
c010022c:	e8 61 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_kernel();
c0100231:	e8 c8 ff ff ff       	call   c01001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100236:	e8 ff fe ff ff       	call   c010013a <lab1_print_cur_status>
}
c010023b:	90                   	nop
c010023c:	c9                   	leave  
c010023d:	c3                   	ret    

c010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023e:	55                   	push   %ebp
c010023f:	89 e5                	mov    %esp,%ebp
c0100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100244:	8b 45 08             	mov    0x8(%ebp),%eax
c0100247:	89 04 24             	mov    %eax,(%esp)
c010024a:	e8 c5 13 00 00       	call   c0101614 <cons_putc>
    (*cnt) ++;
c010024f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100252:	8b 00                	mov    (%eax),%eax
c0100254:	8d 50 01             	lea    0x1(%eax),%edx
c0100257:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025a:	89 10                	mov    %edx,(%eax)
}
c010025c:	90                   	nop
c010025d:	c9                   	leave  
c010025e:	c3                   	ret    

c010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010025f:	55                   	push   %ebp
c0100260:	89 e5                	mov    %esp,%ebp
c0100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100273:	8b 45 08             	mov    0x8(%ebp),%eax
c0100276:	89 44 24 08          	mov    %eax,0x8(%esp)
c010027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010027d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100281:	c7 04 24 3e 02 10 c0 	movl   $0xc010023e,(%esp)
c0100288:	e8 cd 58 00 00       	call   c0105b5a <vprintfmt>
    return cnt;
c010028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100292:	55                   	push   %ebp
c0100293:	89 e5                	mov    %esp,%ebp
c0100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100298:	8d 45 0c             	lea    0xc(%ebp),%eax
c010029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a8:	89 04 24             	mov    %eax,(%esp)
c01002ab:	e8 af ff ff ff       	call   c010025f <vcprintf>
c01002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002b6:	c9                   	leave  
c01002b7:	c3                   	ret    

c01002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b8:	55                   	push   %ebp
c01002b9:	89 e5                	mov    %esp,%ebp
c01002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002be:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c1:	89 04 24             	mov    %eax,(%esp)
c01002c4:	e8 4b 13 00 00       	call   c0101614 <cons_putc>
}
c01002c9:	90                   	nop
c01002ca:	c9                   	leave  
c01002cb:	c3                   	ret    

c01002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002cc:	55                   	push   %ebp
c01002cd:	89 e5                	mov    %esp,%ebp
c01002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d9:	eb 13                	jmp    c01002ee <cputs+0x22>
        cputch(c, &cnt);
c01002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002e6:	89 04 24             	mov    %eax,(%esp)
c01002e9:	e8 50 ff ff ff       	call   c010023e <cputch>
    while ((c = *str ++) != '\0') {
c01002ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f1:	8d 50 01             	lea    0x1(%eax),%edx
c01002f4:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f7:	0f b6 00             	movzbl (%eax),%eax
c01002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100301:	75 d8                	jne    c01002db <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100306:	89 44 24 04          	mov    %eax,0x4(%esp)
c010030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100311:	e8 28 ff ff ff       	call   c010023e <cputch>
    return cnt;
c0100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100319:	c9                   	leave  
c010031a:	c3                   	ret    

c010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010031b:	55                   	push   %ebp
c010031c:	89 e5                	mov    %esp,%ebp
c010031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100321:	e8 2b 13 00 00       	call   c0101651 <cons_getc>
c0100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010032d:	74 f2                	je     c0100321 <getchar+0x6>
        /* do nothing */;
    return c;
c010032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100332:	c9                   	leave  
c0100333:	c3                   	ret    

c0100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100334:	55                   	push   %ebp
c0100335:	89 e5                	mov    %esp,%ebp
c0100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010033e:	74 13                	je     c0100353 <readline+0x1f>
        cprintf("%s", prompt);
c0100340:	8b 45 08             	mov    0x8(%ebp),%eax
c0100343:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100347:	c7 04 24 c7 60 10 c0 	movl   $0xc01060c7,(%esp)
c010034e:	e8 3f ff ff ff       	call   c0100292 <cprintf>
    }
    int i = 0, c;
c0100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010035a:	e8 bc ff ff ff       	call   c010031b <getchar>
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100366:	79 07                	jns    c010036f <readline+0x3b>
            return NULL;
c0100368:	b8 00 00 00 00       	mov    $0x0,%eax
c010036d:	eb 78                	jmp    c01003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100373:	7e 28                	jle    c010039d <readline+0x69>
c0100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010037c:	7f 1f                	jg     c010039d <readline+0x69>
            cputchar(c);
c010037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100381:	89 04 24             	mov    %eax,(%esp)
c0100384:	e8 2f ff ff ff       	call   c01002b8 <cputchar>
            buf[i ++] = c;
c0100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010038c:	8d 50 01             	lea    0x1(%eax),%edx
c010038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100395:	88 90 20 b0 11 c0    	mov    %dl,-0x3fee4fe0(%eax)
c010039b:	eb 45                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c010039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a1:	75 16                	jne    c01003b9 <readline+0x85>
c01003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a7:	7e 10                	jle    c01003b9 <readline+0x85>
            cputchar(c);
c01003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ac:	89 04 24             	mov    %eax,(%esp)
c01003af:	e8 04 ff ff ff       	call   c01002b8 <cputchar>
            i --;
c01003b4:	ff 4d f4             	decl   -0xc(%ebp)
c01003b7:	eb 29                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003bd:	74 06                	je     c01003c5 <readline+0x91>
c01003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c3:	75 95                	jne    c010035a <readline+0x26>
            cputchar(c);
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 04 24             	mov    %eax,(%esp)
c01003cb:	e8 e8 fe ff ff       	call   c01002b8 <cputchar>
            buf[i] = '\0';
c01003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d3:	05 20 b0 11 c0       	add    $0xc011b020,%eax
c01003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003db:	b8 20 b0 11 c0       	mov    $0xc011b020,%eax
c01003e0:	eb 05                	jmp    c01003e7 <readline+0xb3>
        c = getchar();
c01003e2:	e9 73 ff ff ff       	jmp    c010035a <readline+0x26>
        }
    }
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ef:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
c01003f4:	85 c0                	test   %eax,%eax
c01003f6:	75 5b                	jne    c0100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c01003f8:	c7 05 20 b4 11 c0 01 	movl   $0x1,0xc011b420
c01003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100402:	8d 45 14             	lea    0x14(%ebp),%eax
c0100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100408:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010040f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100412:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100416:	c7 04 24 ca 60 10 c0 	movl   $0xc01060ca,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 e6 60 10 c0 	movl   $0xc01060e6,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 e8 60 10 c0 	movl   $0xc01060e8,(%esp)
c0100447:	e8 46 fe ff ff       	call   c0100292 <cprintf>
    print_stackframe();
c010044c:	e8 32 06 00 00       	call   c0100a83 <print_stackframe>
c0100451:	eb 01                	jmp    c0100454 <__panic+0x6b>
        goto panic_dead;
c0100453:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100454:	e8 34 14 00 00       	call   c010188d <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100460:	e8 46 08 00 00       	call   c0100cab <kmonitor>
c0100465:	eb f2                	jmp    c0100459 <__panic+0x70>

c0100467 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100467:	55                   	push   %ebp
c0100468:	89 e5                	mov    %esp,%ebp
c010046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010046d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100473:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100476:	89 44 24 08          	mov    %eax,0x8(%esp)
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100481:	c7 04 24 fa 60 10 c0 	movl   $0xc01060fa,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 e6 60 10 c0 	movl   $0xc01060e6,(%esp)
c01004a6:	e8 e7 fd ff ff       	call   c0100292 <cprintf>
    va_end(ap);
}
c01004ab:	90                   	nop
c01004ac:	c9                   	leave  
c01004ad:	c3                   	ret    

c01004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ae:	55                   	push   %ebp
c01004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b1:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
}
c01004b6:	5d                   	pop    %ebp
c01004b7:	c3                   	ret    

c01004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004b8:	55                   	push   %ebp
c01004b9:	89 e5                	mov    %esp,%ebp
c01004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c1:	8b 00                	mov    (%eax),%eax
c01004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	8b 00                	mov    (%eax),%eax
c01004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d5:	e9 ca 00 00 00       	jmp    c01005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e0:	01 d0                	add    %edx,%eax
c01004e2:	89 c2                	mov    %eax,%edx
c01004e4:	c1 ea 1f             	shr    $0x1f,%edx
c01004e7:	01 d0                	add    %edx,%eax
c01004e9:	d1 f8                	sar    %eax
c01004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f4:	eb 03                	jmp    c01004f9 <stab_binsearch+0x41>
            m --;
c01004f6:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c01004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004ff:	7c 1f                	jl     c0100520 <stab_binsearch+0x68>
c0100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100504:	89 d0                	mov    %edx,%eax
c0100506:	01 c0                	add    %eax,%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	c1 e0 02             	shl    $0x2,%eax
c010050d:	89 c2                	mov    %eax,%edx
c010050f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100512:	01 d0                	add    %edx,%eax
c0100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100518:	0f b6 c0             	movzbl %al,%eax
c010051b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010051e:	75 d6                	jne    c01004f6 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100526:	7d 09                	jge    c0100531 <stab_binsearch+0x79>
            l = true_m + 1;
c0100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010052b:	40                   	inc    %eax
c010052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010052f:	eb 73                	jmp    c01005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053b:	89 d0                	mov    %edx,%eax
c010053d:	01 c0                	add    %eax,%eax
c010053f:	01 d0                	add    %edx,%eax
c0100541:	c1 e0 02             	shl    $0x2,%eax
c0100544:	89 c2                	mov    %eax,%edx
c0100546:	8b 45 08             	mov    0x8(%ebp),%eax
c0100549:	01 d0                	add    %edx,%eax
c010054b:	8b 40 08             	mov    0x8(%eax),%eax
c010054e:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100551:	76 11                	jbe    c0100564 <stab_binsearch+0xac>
            *region_left = m;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010055e:	40                   	inc    %eax
c010055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100562:	eb 40                	jmp    c01005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100567:	89 d0                	mov    %edx,%eax
c0100569:	01 c0                	add    %eax,%eax
c010056b:	01 d0                	add    %edx,%eax
c010056d:	c1 e0 02             	shl    $0x2,%eax
c0100570:	89 c2                	mov    %eax,%edx
c0100572:	8b 45 08             	mov    0x8(%ebp),%eax
c0100575:	01 d0                	add    %edx,%eax
c0100577:	8b 40 08             	mov    0x8(%eax),%eax
c010057a:	39 45 18             	cmp    %eax,0x18(%ebp)
c010057d:	73 14                	jae    c0100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100582:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100585:	8b 45 10             	mov    0x10(%ebp),%eax
c0100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058d:	48                   	dec    %eax
c010058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100591:	eb 11                	jmp    c01005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100593:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100599:	89 10                	mov    %edx,(%eax)
            l = m;
c010059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005a1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005aa:	0f 8e 2a ff ff ff    	jle    c01004da <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b4:	75 0f                	jne    c01005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b9:	8b 00                	mov    (%eax),%eax
c01005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005be:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c3:	eb 3e                	jmp    c0100603 <stab_binsearch+0x14b>
        l = *region_right;
c01005c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c8:	8b 00                	mov    (%eax),%eax
c01005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005cd:	eb 03                	jmp    c01005d2 <stab_binsearch+0x11a>
c01005cf:	ff 4d fc             	decl   -0x4(%ebp)
c01005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d5:	8b 00                	mov    (%eax),%eax
c01005d7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005da:	7e 1f                	jle    c01005fb <stab_binsearch+0x143>
c01005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005df:	89 d0                	mov    %edx,%eax
c01005e1:	01 c0                	add    %eax,%eax
c01005e3:	01 d0                	add    %edx,%eax
c01005e5:	c1 e0 02             	shl    $0x2,%eax
c01005e8:	89 c2                	mov    %eax,%edx
c01005ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ed:	01 d0                	add    %edx,%eax
c01005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f3:	0f b6 c0             	movzbl %al,%eax
c01005f6:	39 45 14             	cmp    %eax,0x14(%ebp)
c01005f9:	75 d4                	jne    c01005cf <stab_binsearch+0x117>
        *region_left = l;
c01005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100601:	89 10                	mov    %edx,(%eax)
}
c0100603:	90                   	nop
c0100604:	c9                   	leave  
c0100605:	c3                   	ret    

c0100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100606:	55                   	push   %ebp
c0100607:	89 e5                	mov    %esp,%ebp
c0100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010060c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060f:	c7 00 18 61 10 c0    	movl   $0xc0106118,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 18 61 10 c0 	movl   $0xc0106118,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100633:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100636:	8b 55 08             	mov    0x8(%ebp),%edx
c0100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010063c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100646:	c7 45 f4 70 73 10 c0 	movl   $0xc0107370,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 a8 25 11 c0 	movl   $0xc01125a8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec a9 25 11 c0 	movl   $0xc01125a9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 b7 50 11 c0 	movl   $0xc01150b7,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100668:	76 0b                	jbe    c0100675 <debuginfo_eip+0x6f>
c010066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066d:	48                   	dec    %eax
c010066e:	0f b6 00             	movzbl (%eax),%eax
c0100671:	84 c0                	test   %al,%al
c0100673:	74 0a                	je     c010067f <debuginfo_eip+0x79>
        return -1;
c0100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067a:	e9 b7 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068c:	29 c2                	sub    %eax,%edx
c010068e:	89 d0                	mov    %edx,%eax
c0100690:	c1 f8 02             	sar    $0x2,%eax
c0100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100699:	48                   	dec    %eax
c010069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010069d:	8b 45 08             	mov    0x8(%ebp),%eax
c01006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ab:	00 
c01006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006af:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bd:	89 04 24             	mov    %eax,(%esp)
c01006c0:	e8 f3 fd ff ff       	call   c01004b8 <stab_binsearch>
    if (lfile == 0)
c01006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c8:	85 c0                	test   %eax,%eax
c01006ca:	75 0a                	jne    c01006d6 <debuginfo_eip+0xd0>
        return -1;
c01006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d1:	e9 60 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006f0:	00 
c01006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100702:	89 04 24             	mov    %eax,(%esp)
c0100705:	e8 ae fd ff ff       	call   c01004b8 <stab_binsearch>

    if (lfun <= rfun) {
c010070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100710:	39 c2                	cmp    %eax,%edx
c0100712:	7f 7c                	jg     c0100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100717:	89 c2                	mov    %eax,%edx
c0100719:	89 d0                	mov    %edx,%eax
c010071b:	01 c0                	add    %eax,%eax
c010071d:	01 d0                	add    %edx,%eax
c010071f:	c1 e0 02             	shl    $0x2,%eax
c0100722:	89 c2                	mov    %eax,%edx
c0100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100727:	01 d0                	add    %edx,%eax
c0100729:	8b 00                	mov    (%eax),%eax
c010072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100731:	29 d1                	sub    %edx,%ecx
c0100733:	89 ca                	mov    %ecx,%edx
c0100735:	39 d0                	cmp    %edx,%eax
c0100737:	73 22                	jae    c010075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	89 d0                	mov    %edx,%eax
c0100740:	01 c0                	add    %eax,%eax
c0100742:	01 d0                	add    %edx,%eax
c0100744:	c1 e0 02             	shl    $0x2,%eax
c0100747:	89 c2                	mov    %eax,%edx
c0100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074c:	01 d0                	add    %edx,%eax
c010074e:	8b 10                	mov    (%eax),%edx
c0100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100753:	01 c2                	add    %eax,%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010075e:	89 c2                	mov    %eax,%edx
c0100760:	89 d0                	mov    %edx,%eax
c0100762:	01 c0                	add    %eax,%eax
c0100764:	01 d0                	add    %edx,%eax
c0100766:	c1 e0 02             	shl    $0x2,%eax
c0100769:	89 c2                	mov    %eax,%edx
c010076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076e:	01 d0                	add    %edx,%eax
c0100770:	8b 50 08             	mov    0x8(%eax),%edx
c0100773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100779:	8b 45 0c             	mov    0xc(%ebp),%eax
c010077c:	8b 40 10             	mov    0x10(%eax),%eax
c010077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010078e:	eb 15                	jmp    c01007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100793:	8b 55 08             	mov    0x8(%ebp),%edx
c0100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c010079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	8b 40 08             	mov    0x8(%eax),%eax
c01007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007b2:	00 
c01007b3:	89 04 24             	mov    %eax,(%esp)
c01007b6:	e8 c8 4e 00 00       	call   c0105683 <strfind>
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c0:	8b 40 08             	mov    0x8(%eax),%eax
c01007c3:	29 c2                	sub    %eax,%edx
c01007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007d9:	00 
c01007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007eb:	89 04 24             	mov    %eax,(%esp)
c01007ee:	e8 c5 fc ff ff       	call   c01004b8 <stab_binsearch>
    if (lline <= rline) {
c01007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007f9:	39 c2                	cmp    %eax,%edx
c01007fb:	7f 23                	jg     c0100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c01007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	89 d0                	mov    %edx,%eax
c0100804:	01 c0                	add    %eax,%eax
c0100806:	01 d0                	add    %edx,%eax
c0100808:	c1 e0 02             	shl    $0x2,%eax
c010080b:	89 c2                	mov    %eax,%edx
c010080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100816:	89 c2                	mov    %eax,%edx
c0100818:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010081e:	eb 11                	jmp    c0100831 <debuginfo_eip+0x22b>
        return -1;
c0100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100825:	e9 0c 01 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082d:	48                   	dec    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100837:	39 c2                	cmp    %eax,%edx
c0100839:	7c 56                	jl     c0100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083e:	89 c2                	mov    %eax,%edx
c0100840:	89 d0                	mov    %edx,%eax
c0100842:	01 c0                	add    %eax,%eax
c0100844:	01 d0                	add    %edx,%eax
c0100846:	c1 e0 02             	shl    $0x2,%eax
c0100849:	89 c2                	mov    %eax,%edx
c010084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010084e:	01 d0                	add    %edx,%eax
c0100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100854:	3c 84                	cmp    $0x84,%al
c0100856:	74 39                	je     c0100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c 64                	cmp    $0x64,%al
c0100873:	75 b5                	jne    c010082a <debuginfo_eip+0x224>
c0100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	89 d0                	mov    %edx,%eax
c010087c:	01 c0                	add    %eax,%eax
c010087e:	01 d0                	add    %edx,%eax
c0100880:	c1 e0 02             	shl    $0x2,%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100888:	01 d0                	add    %edx,%eax
c010088a:	8b 40 08             	mov    0x8(%eax),%eax
c010088d:	85 c0                	test   %eax,%eax
c010088f:	74 99                	je     c010082a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100897:	39 c2                	cmp    %eax,%edx
c0100899:	7c 46                	jl     c01008e1 <debuginfo_eip+0x2db>
c010089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	8b 00                	mov    (%eax),%eax
c01008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008b8:	29 d1                	sub    %edx,%ecx
c01008ba:	89 ca                	mov    %ecx,%edx
c01008bc:	39 d0                	cmp    %edx,%eax
c01008be:	73 21                	jae    c01008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008c3:	89 c2                	mov    %eax,%edx
c01008c5:	89 d0                	mov    %edx,%eax
c01008c7:	01 c0                	add    %eax,%eax
c01008c9:	01 d0                	add    %edx,%eax
c01008cb:	c1 e0 02             	shl    $0x2,%eax
c01008ce:	89 c2                	mov    %eax,%edx
c01008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d3:	01 d0                	add    %edx,%eax
c01008d5:	8b 10                	mov    (%eax),%edx
c01008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008da:	01 c2                	add    %eax,%edx
c01008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008e7:	39 c2                	cmp    %eax,%edx
c01008e9:	7d 46                	jge    c0100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ee:	40                   	inc    %eax
c01008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008f2:	eb 16                	jmp    c010090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f7:	8b 40 14             	mov    0x14(%eax),%eax
c01008fa:	8d 50 01             	lea    0x1(%eax),%edx
c01008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100900:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100906:	40                   	inc    %eax
c0100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	7d 1d                	jge    c0100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010092d:	3c a0                	cmp    $0xa0,%al
c010092f:	74 c3                	je     c01008f4 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
c0100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100936:	c9                   	leave  
c0100937:	c3                   	ret    

c0100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100938:	55                   	push   %ebp
c0100939:	89 e5                	mov    %esp,%ebp
c010093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010093e:	c7 04 24 22 61 10 c0 	movl   $0xc0106122,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 3b 61 10 c0 	movl   $0xc010613b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 01 60 10 	movl   $0xc0106001,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 53 61 10 c0 	movl   $0xc0106153,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 b0 11 	movl   $0xc011b000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 6b 61 10 c0 	movl   $0xc010616b,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 28 bf 11 	movl   $0xc011bf28,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 83 61 10 c0 	movl   $0xc0106183,(%esp)
c0100995:	e8 f8 f8 ff ff       	call   c0100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010099a:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
c010099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009aa:	29 c2                	sub    %eax,%edx
c01009ac:	89 d0                	mov    %edx,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	85 c0                	test   %eax,%eax
c01009b6:	0f 48 c2             	cmovs  %edx,%eax
c01009b9:	c1 f8 0a             	sar    $0xa,%eax
c01009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c0:	c7 04 24 9c 61 10 c0 	movl   $0xc010619c,(%esp)
c01009c7:	e8 c6 f8 ff ff       	call   c0100292 <cprintf>
}
c01009cc:	90                   	nop
c01009cd:	c9                   	leave  
c01009ce:	c3                   	ret    

c01009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009cf:	55                   	push   %ebp
c01009d0:	89 e5                	mov    %esp,%ebp
c01009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009df:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e2:	89 04 24             	mov    %eax,(%esp)
c01009e5:	e8 1c fc ff ff       	call   c0100606 <debuginfo_eip>
c01009ea:	85 c0                	test   %eax,%eax
c01009ec:	74 15                	je     c0100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f5:	c7 04 24 c6 61 10 c0 	movl   $0xc01061c6,(%esp)
c01009fc:	e8 91 f8 ff ff       	call   c0100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a01:	eb 6c                	jmp    c0100a6f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a0a:	eb 1b                	jmp    c0100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a12:	01 d0                	add    %edx,%eax
c0100a14:	0f b6 00             	movzbl (%eax),%eax
c0100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a20:	01 ca                	add    %ecx,%edx
c0100a22:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a24:	ff 45 f4             	incl   -0xc(%ebp)
c0100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a2d:	7c dd                	jl     c0100a0c <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a38:	01 d0                	add    %edx,%eax
c0100a3a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a40:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a43:	89 d1                	mov    %edx,%ecx
c0100a45:	29 c1                	sub    %eax,%ecx
c0100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a63:	c7 04 24 e2 61 10 c0 	movl   $0xc01061e2,(%esp)
c0100a6a:	e8 23 f8 ff ff       	call   c0100292 <cprintf>
}
c0100a6f:	90                   	nop
c0100a70:	c9                   	leave  
c0100a71:	c3                   	ret    

c0100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a72:	55                   	push   %ebp
c0100a73:	89 e5                	mov    %esp,%ebp
c0100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a78:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a81:	c9                   	leave  
c0100a82:	c3                   	ret    

c0100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a89:	89 e8                	mov    %ebp,%eax
c0100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
c0100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
c0100a94:	e8 d9 ff ff ff       	call   c0100a72 <read_eip>
c0100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for(uint32_t i = 0; ebp && i < STACKFRAME_DEPTH; i++) {
c0100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aa3:	e9 84 00 00 00       	jmp    c0100b2c <print_stackframe+0xa9>
          cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 f4 61 10 c0 	movl   $0xc01061f4,(%esp)
c0100abd:	e8 d0 f7 ff ff       	call   c0100292 <cprintf>
          uint32_t* args = (uint32_t*)ebp + 2;
c0100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac5:	83 c0 08             	add    $0x8,%eax
c0100ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          for(uint32_t j = 0; j < 4; j++)
c0100acb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ad2:	eb 24                	jmp    c0100af8 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ae1:	01 d0                	add    %edx,%eax
c0100ae3:	8b 00                	mov    (%eax),%eax
c0100ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae9:	c7 04 24 10 62 10 c0 	movl   $0xc0106210,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
          for(uint32_t j = 0; j < 4; j++)
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	76 d6                	jbe    c0100ad4 <print_stackframe+0x51>
        cprintf("\n");
c0100afe:	c7 04 24 18 62 10 c0 	movl   $0xc0106218,(%esp)
c0100b05:	e8 88 f7 ff ff       	call   c0100292 <cprintf>
        print_debuginfo(eip-1);
c0100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0d:	48                   	dec    %eax
c0100b0e:	89 04 24             	mov    %eax,(%esp)
c0100b11:	e8 b9 fe ff ff       	call   c01009cf <print_debuginfo>
        eip = ((uint32_t*)ebp)[1];
c0100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b19:	83 c0 04             	add    $0x4,%eax
c0100b1c:	8b 00                	mov    (%eax),%eax
c0100b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t*)ebp)[0];
c0100b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b24:	8b 00                	mov    (%eax),%eax
c0100b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(uint32_t i = 0; ebp && i < STACKFRAME_DEPTH; i++) {
c0100b29:	ff 45 ec             	incl   -0x14(%ebp)
c0100b2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b30:	74 0a                	je     c0100b3c <print_stackframe+0xb9>
c0100b32:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b36:	0f 86 6c ff ff ff    	jbe    c0100aa8 <print_stackframe+0x25>
      }
}
c0100b3c:	90                   	nop
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4c:	eb 0c                	jmp    c0100b5a <parse+0x1b>
            *buf ++ = '\0';
c0100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b51:	8d 50 01             	lea    0x1(%eax),%edx
c0100b54:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b57:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5d:	0f b6 00             	movzbl (%eax),%eax
c0100b60:	84 c0                	test   %al,%al
c0100b62:	74 1d                	je     c0100b81 <parse+0x42>
c0100b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b67:	0f b6 00             	movzbl (%eax),%eax
c0100b6a:	0f be c0             	movsbl %al,%eax
c0100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b71:	c7 04 24 9c 62 10 c0 	movl   $0xc010629c,(%esp)
c0100b78:	e8 d4 4a 00 00       	call   c0105651 <strchr>
c0100b7d:	85 c0                	test   %eax,%eax
c0100b7f:	75 cd                	jne    c0100b4e <parse+0xf>
        }
        if (*buf == '\0') {
c0100b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b84:	0f b6 00             	movzbl (%eax),%eax
c0100b87:	84 c0                	test   %al,%al
c0100b89:	74 65                	je     c0100bf0 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b8b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b8f:	75 14                	jne    c0100ba5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b91:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b98:	00 
c0100b99:	c7 04 24 a1 62 10 c0 	movl   $0xc01062a1,(%esp)
c0100ba0:	e8 ed f6 ff ff       	call   c0100292 <cprintf>
        }
        argv[argc ++] = buf;
c0100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba8:	8d 50 01             	lea    0x1(%eax),%edx
c0100bab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bb8:	01 c2                	add    %eax,%edx
c0100bba:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bbf:	eb 03                	jmp    c0100bc4 <parse+0x85>
            buf ++;
c0100bc1:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc7:	0f b6 00             	movzbl (%eax),%eax
c0100bca:	84 c0                	test   %al,%al
c0100bcc:	74 8c                	je     c0100b5a <parse+0x1b>
c0100bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd1:	0f b6 00             	movzbl (%eax),%eax
c0100bd4:	0f be c0             	movsbl %al,%eax
c0100bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdb:	c7 04 24 9c 62 10 c0 	movl   $0xc010629c,(%esp)
c0100be2:	e8 6a 4a 00 00       	call   c0105651 <strchr>
c0100be7:	85 c0                	test   %eax,%eax
c0100be9:	74 d6                	je     c0100bc1 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100beb:	e9 6a ff ff ff       	jmp    c0100b5a <parse+0x1b>
            break;
c0100bf0:	90                   	nop
        }
    }
    return argc;
c0100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bf4:	c9                   	leave  
c0100bf5:	c3                   	ret    

c0100bf6 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bf6:	55                   	push   %ebp
c0100bf7:	89 e5                	mov    %esp,%ebp
c0100bf9:	53                   	push   %ebx
c0100bfa:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100bfd:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c07:	89 04 24             	mov    %eax,(%esp)
c0100c0a:	e8 30 ff ff ff       	call   c0100b3f <parse>
c0100c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c16:	75 0a                	jne    c0100c22 <runcmd+0x2c>
        return 0;
c0100c18:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c1d:	e9 83 00 00 00       	jmp    c0100ca5 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c29:	eb 5a                	jmp    c0100c85 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c2b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c31:	89 d0                	mov    %edx,%eax
c0100c33:	01 c0                	add    %eax,%eax
c0100c35:	01 d0                	add    %edx,%eax
c0100c37:	c1 e0 02             	shl    $0x2,%eax
c0100c3a:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100c3f:	8b 00                	mov    (%eax),%eax
c0100c41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c45:	89 04 24             	mov    %eax,(%esp)
c0100c48:	e8 67 49 00 00       	call   c01055b4 <strcmp>
c0100c4d:	85 c0                	test   %eax,%eax
c0100c4f:	75 31                	jne    c0100c82 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c54:	89 d0                	mov    %edx,%eax
c0100c56:	01 c0                	add    %eax,%eax
c0100c58:	01 d0                	add    %edx,%eax
c0100c5a:	c1 e0 02             	shl    $0x2,%eax
c0100c5d:	05 08 80 11 c0       	add    $0xc0118008,%eax
c0100c62:	8b 10                	mov    (%eax),%edx
c0100c64:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c67:	83 c0 04             	add    $0x4,%eax
c0100c6a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c6d:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c7b:	89 1c 24             	mov    %ebx,(%esp)
c0100c7e:	ff d2                	call   *%edx
c0100c80:	eb 23                	jmp    c0100ca5 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c82:	ff 45 f4             	incl   -0xc(%ebp)
c0100c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c88:	83 f8 02             	cmp    $0x2,%eax
c0100c8b:	76 9e                	jbe    c0100c2b <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c8d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c94:	c7 04 24 bf 62 10 c0 	movl   $0xc01062bf,(%esp)
c0100c9b:	e8 f2 f5 ff ff       	call   c0100292 <cprintf>
    return 0;
c0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ca5:	83 c4 64             	add    $0x64,%esp
c0100ca8:	5b                   	pop    %ebx
c0100ca9:	5d                   	pop    %ebp
c0100caa:	c3                   	ret    

c0100cab <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cab:	55                   	push   %ebp
c0100cac:	89 e5                	mov    %esp,%ebp
c0100cae:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cb1:	c7 04 24 d8 62 10 c0 	movl   $0xc01062d8,(%esp)
c0100cb8:	e8 d5 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbd:	c7 04 24 00 63 10 c0 	movl   $0xc0106300,(%esp)
c0100cc4:	e8 c9 f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ccd:	74 0b                	je     c0100cda <kmonitor+0x2f>
        print_trapframe(tf);
c0100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd2:	89 04 24             	mov    %eax,(%esp)
c0100cd5:	e8 8f 0d 00 00       	call   c0101a69 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cda:	c7 04 24 25 63 10 c0 	movl   $0xc0106325,(%esp)
c0100ce1:	e8 4e f6 ff ff       	call   c0100334 <readline>
c0100ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ced:	74 eb                	je     c0100cda <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100cef:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf9:	89 04 24             	mov    %eax,(%esp)
c0100cfc:	e8 f5 fe ff ff       	call   c0100bf6 <runcmd>
c0100d01:	85 c0                	test   %eax,%eax
c0100d03:	78 02                	js     c0100d07 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d05:	eb d3                	jmp    c0100cda <kmonitor+0x2f>
                break;
c0100d07:	90                   	nop
            }
        }
    }
}
c0100d08:	90                   	nop
c0100d09:	c9                   	leave  
c0100d0a:	c3                   	ret    

c0100d0b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d0b:	55                   	push   %ebp
c0100d0c:	89 e5                	mov    %esp,%ebp
c0100d0e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d18:	eb 3d                	jmp    c0100d57 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d1d:	89 d0                	mov    %edx,%eax
c0100d1f:	01 c0                	add    %eax,%eax
c0100d21:	01 d0                	add    %edx,%eax
c0100d23:	c1 e0 02             	shl    $0x2,%eax
c0100d26:	05 04 80 11 c0       	add    $0xc0118004,%eax
c0100d2b:	8b 08                	mov    (%eax),%ecx
c0100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d30:	89 d0                	mov    %edx,%eax
c0100d32:	01 c0                	add    %eax,%eax
c0100d34:	01 d0                	add    %edx,%eax
c0100d36:	c1 e0 02             	shl    $0x2,%eax
c0100d39:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100d3e:	8b 00                	mov    (%eax),%eax
c0100d40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d48:	c7 04 24 29 63 10 c0 	movl   $0xc0106329,(%esp)
c0100d4f:	e8 3e f5 ff ff       	call   c0100292 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d54:	ff 45 f4             	incl   -0xc(%ebp)
c0100d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5a:	83 f8 02             	cmp    $0x2,%eax
c0100d5d:	76 bb                	jbe    c0100d1a <mon_help+0xf>
    }
    return 0;
c0100d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d64:	c9                   	leave  
c0100d65:	c3                   	ret    

c0100d66 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d66:	55                   	push   %ebp
c0100d67:	89 e5                	mov    %esp,%ebp
c0100d69:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d6c:	e8 c7 fb ff ff       	call   c0100938 <print_kerninfo>
    return 0;
c0100d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d76:	c9                   	leave  
c0100d77:	c3                   	ret    

c0100d78 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d78:	55                   	push   %ebp
c0100d79:	89 e5                	mov    %esp,%ebp
c0100d7b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d7e:	e8 00 fd ff ff       	call   c0100a83 <print_stackframe>
    return 0;
c0100d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d88:	c9                   	leave  
c0100d89:	c3                   	ret    

c0100d8a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d8a:	55                   	push   %ebp
c0100d8b:	89 e5                	mov    %esp,%ebp
c0100d8d:	83 ec 28             	sub    $0x28,%esp
c0100d90:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100d96:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d9a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100d9e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100da2:	ee                   	out    %al,(%dx)
c0100da3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100da9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dad:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100db1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100db5:	ee                   	out    %al,(%dx)
c0100db6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100dbc:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0100dc0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dc9:	c7 05 0c bf 11 c0 00 	movl   $0x0,0xc011bf0c
c0100dd0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd3:	c7 04 24 32 63 10 c0 	movl   $0xc0106332,(%esp)
c0100dda:	e8 b3 f4 ff ff       	call   c0100292 <cprintf>
    pic_enable(IRQ_TIMER);
c0100ddf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100de6:	e8 2e 09 00 00       	call   c0101719 <pic_enable>
}
c0100deb:	90                   	nop
c0100dec:	c9                   	leave  
c0100ded:	c3                   	ret    

c0100dee <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100dee:	55                   	push   %ebp
c0100def:	89 e5                	mov    %esp,%ebp
c0100df1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100df4:	9c                   	pushf  
c0100df5:	58                   	pop    %eax
c0100df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100dfc:	25 00 02 00 00       	and    $0x200,%eax
c0100e01:	85 c0                	test   %eax,%eax
c0100e03:	74 0c                	je     c0100e11 <__intr_save+0x23>
        intr_disable();
c0100e05:	e8 83 0a 00 00       	call   c010188d <intr_disable>
        return 1;
c0100e0a:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e0f:	eb 05                	jmp    c0100e16 <__intr_save+0x28>
    }
    return 0;
c0100e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e16:	c9                   	leave  
c0100e17:	c3                   	ret    

c0100e18 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e18:	55                   	push   %ebp
c0100e19:	89 e5                	mov    %esp,%ebp
c0100e1b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e22:	74 05                	je     c0100e29 <__intr_restore+0x11>
        intr_enable();
c0100e24:	e8 5d 0a 00 00       	call   c0101886 <intr_enable>
    }
}
c0100e29:	90                   	nop
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 10             	sub    $0x10,%esp
c0100e32:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e38:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e3c:	89 c2                	mov    %eax,%edx
c0100e3e:	ec                   	in     (%dx),%al
c0100e3f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e42:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e48:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e4c:	89 c2                	mov    %eax,%edx
c0100e4e:	ec                   	in     (%dx),%al
c0100e4f:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e52:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e58:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5c:	89 c2                	mov    %eax,%edx
c0100e5e:	ec                   	in     (%dx),%al
c0100e5f:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e62:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e6c:	89 c2                	mov    %eax,%edx
c0100e6e:	ec                   	in     (%dx),%al
c0100e6f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e72:	90                   	nop
c0100e73:	c9                   	leave  
c0100e74:	c3                   	ret    

c0100e75 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e75:	55                   	push   %ebp
c0100e76:	89 e5                	mov    %esp,%ebp
c0100e78:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e7b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e85:	0f b7 00             	movzwl (%eax),%eax
c0100e88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	0f b7 c0             	movzwl %ax,%eax
c0100e9d:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ea2:	74 12                	je     c0100eb6 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ea4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eab:	66 c7 05 46 b4 11 c0 	movw   $0x3b4,0xc011b446
c0100eb2:	b4 03 
c0100eb4:	eb 13                	jmp    c0100ec9 <cga_init+0x54>
    } else {
        *cp = was;
c0100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ebd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ec0:	66 c7 05 46 b4 11 c0 	movw   $0x3d4,0xc011b446
c0100ec7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ec9:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100ed0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ed4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100edc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee1:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100ee8:	40                   	inc    %eax
c0100ee9:	0f b7 c0             	movzwl %ax,%eax
c0100eec:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ef4:	89 c2                	mov    %eax,%edx
c0100ef6:	ec                   	in     (%dx),%al
c0100ef7:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100efa:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100efe:	0f b6 c0             	movzbl %al,%eax
c0100f01:	c1 e0 08             	shl    $0x8,%eax
c0100f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f07:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f12:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f1f:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f26:	40                   	inc    %eax
c0100f27:	0f b7 c0             	movzwl %ax,%eax
c0100f2a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f2e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f32:	89 c2                	mov    %eax,%edx
c0100f34:	ec                   	in     (%dx),%al
c0100f35:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f38:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f3c:	0f b6 c0             	movzbl %al,%eax
c0100f3f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f45:	a3 40 b4 11 c0       	mov    %eax,0xc011b440
    crt_pos = pos;
c0100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f4d:	0f b7 c0             	movzwl %ax,%eax
c0100f50:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
}
c0100f56:	90                   	nop
c0100f57:	c9                   	leave  
c0100f58:	c3                   	ret    

c0100f59 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f59:	55                   	push   %ebp
c0100f5a:	89 e5                	mov    %esp,%ebp
c0100f5c:	83 ec 48             	sub    $0x48,%esp
c0100f5f:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f65:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f69:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f6d:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f71:	ee                   	out    %al,(%dx)
c0100f72:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100f78:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c0100f7c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100f80:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100f84:	ee                   	out    %al,(%dx)
c0100f85:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100f8b:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c0100f8f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100f93:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100f97:	ee                   	out    %al,(%dx)
c0100f98:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100f9e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fa2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fa6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100faa:	ee                   	out    %al,(%dx)
c0100fab:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fb1:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0100fb5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fb9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fbd:	ee                   	out    %al,(%dx)
c0100fbe:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100fc4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0100fc8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fd0:	ee                   	out    %al,(%dx)
c0100fd1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fd7:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0100fdb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fdf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fe3:	ee                   	out    %al,(%dx)
c0100fe4:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fea:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100fee:	89 c2                	mov    %eax,%edx
c0100ff0:	ec                   	in     (%dx),%al
c0100ff1:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100ff4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ff8:	3c ff                	cmp    $0xff,%al
c0100ffa:	0f 95 c0             	setne  %al
c0100ffd:	0f b6 c0             	movzbl %al,%eax
c0101000:	a3 48 b4 11 c0       	mov    %eax,0xc011b448
c0101005:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010100f:	89 c2                	mov    %eax,%edx
c0101011:	ec                   	in     (%dx),%al
c0101012:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101015:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010101b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010101f:	89 c2                	mov    %eax,%edx
c0101021:	ec                   	in     (%dx),%al
c0101022:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101025:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c010102a:	85 c0                	test   %eax,%eax
c010102c:	74 0c                	je     c010103a <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010102e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101035:	e8 df 06 00 00       	call   c0101719 <pic_enable>
    }
}
c010103a:	90                   	nop
c010103b:	c9                   	leave  
c010103c:	c3                   	ret    

c010103d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010103d:	55                   	push   %ebp
c010103e:	89 e5                	mov    %esp,%ebp
c0101040:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101043:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010104a:	eb 08                	jmp    c0101054 <lpt_putc_sub+0x17>
        delay();
c010104c:	e8 db fd ff ff       	call   c0100e2c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101051:	ff 45 fc             	incl   -0x4(%ebp)
c0101054:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010105a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010105e:	89 c2                	mov    %eax,%edx
c0101060:	ec                   	in     (%dx),%al
c0101061:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101064:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101068:	84 c0                	test   %al,%al
c010106a:	78 09                	js     c0101075 <lpt_putc_sub+0x38>
c010106c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101073:	7e d7                	jle    c010104c <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101075:	8b 45 08             	mov    0x8(%ebp),%eax
c0101078:	0f b6 c0             	movzbl %al,%eax
c010107b:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101081:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101084:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101088:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010108c:	ee                   	out    %al,(%dx)
c010108d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101093:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101097:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010109b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010109f:	ee                   	out    %al,(%dx)
c01010a0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010a6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c01010aa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010b2:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010b3:	90                   	nop
c01010b4:	c9                   	leave  
c01010b5:	c3                   	ret    

c01010b6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010b6:	55                   	push   %ebp
c01010b7:	89 e5                	mov    %esp,%ebp
c01010b9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010bc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010c0:	74 0d                	je     c01010cf <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c5:	89 04 24             	mov    %eax,(%esp)
c01010c8:	e8 70 ff ff ff       	call   c010103d <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010cd:	eb 24                	jmp    c01010f3 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c01010cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010d6:	e8 62 ff ff ff       	call   c010103d <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010e2:	e8 56 ff ff ff       	call   c010103d <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010ee:	e8 4a ff ff ff       	call   c010103d <lpt_putc_sub>
}
c01010f3:	90                   	nop
c01010f4:	c9                   	leave  
c01010f5:	c3                   	ret    

c01010f6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010f6:	55                   	push   %ebp
c01010f7:	89 e5                	mov    %esp,%ebp
c01010f9:	53                   	push   %ebx
c01010fa:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101100:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101105:	85 c0                	test   %eax,%eax
c0101107:	75 07                	jne    c0101110 <cga_putc+0x1a>
        c |= 0x0700;
c0101109:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101110:	8b 45 08             	mov    0x8(%ebp),%eax
c0101113:	0f b6 c0             	movzbl %al,%eax
c0101116:	83 f8 0a             	cmp    $0xa,%eax
c0101119:	74 55                	je     c0101170 <cga_putc+0x7a>
c010111b:	83 f8 0d             	cmp    $0xd,%eax
c010111e:	74 63                	je     c0101183 <cga_putc+0x8d>
c0101120:	83 f8 08             	cmp    $0x8,%eax
c0101123:	0f 85 94 00 00 00    	jne    c01011bd <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101129:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101130:	85 c0                	test   %eax,%eax
c0101132:	0f 84 af 00 00 00    	je     c01011e7 <cga_putc+0xf1>
            crt_pos --;
c0101138:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010113f:	48                   	dec    %eax
c0101140:	0f b7 c0             	movzwl %ax,%eax
c0101143:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101149:	8b 45 08             	mov    0x8(%ebp),%eax
c010114c:	98                   	cwtl   
c010114d:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101152:	98                   	cwtl   
c0101153:	83 c8 20             	or     $0x20,%eax
c0101156:	98                   	cwtl   
c0101157:	8b 15 40 b4 11 c0    	mov    0xc011b440,%edx
c010115d:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c0101164:	01 c9                	add    %ecx,%ecx
c0101166:	01 ca                	add    %ecx,%edx
c0101168:	0f b7 c0             	movzwl %ax,%eax
c010116b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010116e:	eb 77                	jmp    c01011e7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101170:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101177:	83 c0 50             	add    $0x50,%eax
c010117a:	0f b7 c0             	movzwl %ax,%eax
c010117d:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101183:	0f b7 1d 44 b4 11 c0 	movzwl 0xc011b444,%ebx
c010118a:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c0101191:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101196:	89 c8                	mov    %ecx,%eax
c0101198:	f7 e2                	mul    %edx
c010119a:	c1 ea 06             	shr    $0x6,%edx
c010119d:	89 d0                	mov    %edx,%eax
c010119f:	c1 e0 02             	shl    $0x2,%eax
c01011a2:	01 d0                	add    %edx,%eax
c01011a4:	c1 e0 04             	shl    $0x4,%eax
c01011a7:	29 c1                	sub    %eax,%ecx
c01011a9:	89 c8                	mov    %ecx,%eax
c01011ab:	0f b7 c0             	movzwl %ax,%eax
c01011ae:	29 c3                	sub    %eax,%ebx
c01011b0:	89 d8                	mov    %ebx,%eax
c01011b2:	0f b7 c0             	movzwl %ax,%eax
c01011b5:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
        break;
c01011bb:	eb 2b                	jmp    c01011e8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011bd:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c01011c3:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01011ca:	8d 50 01             	lea    0x1(%eax),%edx
c01011cd:	0f b7 d2             	movzwl %dx,%edx
c01011d0:	66 89 15 44 b4 11 c0 	mov    %dx,0xc011b444
c01011d7:	01 c0                	add    %eax,%eax
c01011d9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01011df:	0f b7 c0             	movzwl %ax,%eax
c01011e2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e5:	eb 01                	jmp    c01011e8 <cga_putc+0xf2>
        break;
c01011e7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e8:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01011ef:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01011f4:	76 5d                	jbe    c0101253 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f6:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c01011fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101201:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101206:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120d:	00 
c010120e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101212:	89 04 24             	mov    %eax,(%esp)
c0101215:	e8 2d 46 00 00       	call   c0105847 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010121a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101221:	eb 14                	jmp    c0101237 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101223:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101228:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010122b:	01 d2                	add    %edx,%edx
c010122d:	01 d0                	add    %edx,%eax
c010122f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101234:	ff 45 f4             	incl   -0xc(%ebp)
c0101237:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123e:	7e e3                	jle    c0101223 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101240:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101247:	83 e8 50             	sub    $0x50,%eax
c010124a:	0f b7 c0             	movzwl %ax,%eax
c010124d:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101253:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c010125a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010125e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101262:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101266:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010126a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010126b:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101272:	c1 e8 08             	shr    $0x8,%eax
c0101275:	0f b7 c0             	movzwl %ax,%eax
c0101278:	0f b6 c0             	movzbl %al,%eax
c010127b:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c0101282:	42                   	inc    %edx
c0101283:	0f b7 d2             	movzwl %dx,%edx
c0101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010128a:	88 45 e9             	mov    %al,-0x17(%ebp)
c010128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101295:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101296:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c010129d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012a1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c01012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012ae:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01012b5:	0f b6 c0             	movzbl %al,%eax
c01012b8:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c01012bf:	42                   	inc    %edx
c01012c0:	0f b7 d2             	movzwl %dx,%edx
c01012c3:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c01012c7:	88 45 f1             	mov    %al,-0xf(%ebp)
c01012ca:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01012ce:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d2:	ee                   	out    %al,(%dx)
}
c01012d3:	90                   	nop
c01012d4:	83 c4 34             	add    $0x34,%esp
c01012d7:	5b                   	pop    %ebx
c01012d8:	5d                   	pop    %ebp
c01012d9:	c3                   	ret    

c01012da <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012da:	55                   	push   %ebp
c01012db:	89 e5                	mov    %esp,%ebp
c01012dd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e7:	eb 08                	jmp    c01012f1 <serial_putc_sub+0x17>
        delay();
c01012e9:	e8 3e fb ff ff       	call   c0100e2c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012ee:	ff 45 fc             	incl   -0x4(%ebp)
c01012f1:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012f7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fb:	89 c2                	mov    %eax,%edx
c01012fd:	ec                   	in     (%dx),%al
c01012fe:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101301:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101305:	0f b6 c0             	movzbl %al,%eax
c0101308:	83 e0 20             	and    $0x20,%eax
c010130b:	85 c0                	test   %eax,%eax
c010130d:	75 09                	jne    c0101318 <serial_putc_sub+0x3e>
c010130f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101316:	7e d1                	jle    c01012e9 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101318:	8b 45 08             	mov    0x8(%ebp),%eax
c010131b:	0f b6 c0             	movzbl %al,%eax
c010131e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101324:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101327:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010132f:	ee                   	out    %al,(%dx)
}
c0101330:	90                   	nop
c0101331:	c9                   	leave  
c0101332:	c3                   	ret    

c0101333 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101333:	55                   	push   %ebp
c0101334:	89 e5                	mov    %esp,%ebp
c0101336:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101339:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133d:	74 0d                	je     c010134c <serial_putc+0x19>
        serial_putc_sub(c);
c010133f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101342:	89 04 24             	mov    %eax,(%esp)
c0101345:	e8 90 ff ff ff       	call   c01012da <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010134a:	eb 24                	jmp    c0101370 <serial_putc+0x3d>
        serial_putc_sub('\b');
c010134c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101353:	e8 82 ff ff ff       	call   c01012da <serial_putc_sub>
        serial_putc_sub(' ');
c0101358:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010135f:	e8 76 ff ff ff       	call   c01012da <serial_putc_sub>
        serial_putc_sub('\b');
c0101364:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136b:	e8 6a ff ff ff       	call   c01012da <serial_putc_sub>
}
c0101370:	90                   	nop
c0101371:	c9                   	leave  
c0101372:	c3                   	ret    

c0101373 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101373:	55                   	push   %ebp
c0101374:	89 e5                	mov    %esp,%ebp
c0101376:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101379:	eb 33                	jmp    c01013ae <cons_intr+0x3b>
        if (c != 0) {
c010137b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010137f:	74 2d                	je     c01013ae <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101381:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c0101386:	8d 50 01             	lea    0x1(%eax),%edx
c0101389:	89 15 64 b6 11 c0    	mov    %edx,0xc011b664
c010138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101392:	88 90 60 b4 11 c0    	mov    %dl,-0x3fee4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101398:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c010139d:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a2:	75 0a                	jne    c01013ae <cons_intr+0x3b>
                cons.wpos = 0;
c01013a4:	c7 05 64 b6 11 c0 00 	movl   $0x0,0xc011b664
c01013ab:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01013ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b1:	ff d0                	call   *%eax
c01013b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013ba:	75 bf                	jne    c010137b <cons_intr+0x8>
            }
        }
    }
}
c01013bc:	90                   	nop
c01013bd:	c9                   	leave  
c01013be:	c3                   	ret    

c01013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bf:	55                   	push   %ebp
c01013c0:	89 e5                	mov    %esp,%ebp
c01013c2:	83 ec 10             	sub    $0x10,%esp
c01013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cf:	89 c2                	mov    %eax,%edx
c01013d1:	ec                   	in     (%dx),%al
c01013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d9:	0f b6 c0             	movzbl %al,%eax
c01013dc:	83 e0 01             	and    $0x1,%eax
c01013df:	85 c0                	test   %eax,%eax
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x2b>
        return -1;
c01013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e8:	eb 2a                	jmp    c0101414 <serial_proc_data+0x55>
c01013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f4:	89 c2                	mov    %eax,%edx
c01013f6:	ec                   	in     (%dx),%al
c01013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fe:	0f b6 c0             	movzbl %al,%eax
c0101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101408:	75 07                	jne    c0101411 <serial_proc_data+0x52>
        c = '\b';
c010140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141c:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101421:	85 c0                	test   %eax,%eax
c0101423:	74 0c                	je     c0101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101425:	c7 04 24 bf 13 10 c0 	movl   $0xc01013bf,(%esp)
c010142c:	e8 42 ff ff ff       	call   c0101373 <cons_intr>
    }
}
c0101431:	90                   	nop
c0101432:	c9                   	leave  
c0101433:	c3                   	ret    

c0101434 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101434:	55                   	push   %ebp
c0101435:	89 e5                	mov    %esp,%ebp
c0101437:	83 ec 38             	sub    $0x38,%esp
c010143a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101440:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101443:	89 c2                	mov    %eax,%edx
c0101445:	ec                   	in     (%dx),%al
c0101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144d:	0f b6 c0             	movzbl %al,%eax
c0101450:	83 e0 01             	and    $0x1,%eax
c0101453:	85 c0                	test   %eax,%eax
c0101455:	75 0a                	jne    c0101461 <kbd_proc_data+0x2d>
        return -1;
c0101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145c:	e9 55 01 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
c0101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010146a:	89 c2                	mov    %eax,%edx
c010146c:	ec                   	in     (%dx),%al
c010146d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101470:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101474:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101477:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147b:	75 17                	jne    c0101494 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c010147d:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101482:	83 c8 40             	or     $0x40,%eax
c0101485:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c010148a:	b8 00 00 00 00       	mov    $0x0,%eax
c010148f:	e9 22 01 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c0101494:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101498:	84 c0                	test   %al,%al
c010149a:	79 45                	jns    c01014e1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149c:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014a1:	83 e0 40             	and    $0x40,%eax
c01014a4:	85 c0                	test   %eax,%eax
c01014a6:	75 08                	jne    c01014b0 <kbd_proc_data+0x7c>
c01014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ac:	24 7f                	and    $0x7f,%al
c01014ae:	eb 04                	jmp    c01014b4 <kbd_proc_data+0x80>
c01014b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bb:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c01014c2:	0c 40                	or     $0x40,%al
c01014c4:	0f b6 c0             	movzbl %al,%eax
c01014c7:	f7 d0                	not    %eax
c01014c9:	89 c2                	mov    %eax,%edx
c01014cb:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014d0:	21 d0                	and    %edx,%eax
c01014d2:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c01014d7:	b8 00 00 00 00       	mov    $0x0,%eax
c01014dc:	e9 d5 00 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c01014e1:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014e6:	83 e0 40             	and    $0x40,%eax
c01014e9:	85 c0                	test   %eax,%eax
c01014eb:	74 11                	je     c01014fe <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ed:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f1:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014f6:	83 e0 bf             	and    $0xffffffbf,%eax
c01014f9:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    }

    shift |= shiftcode[data];
c01014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101502:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c0101509:	0f b6 d0             	movzbl %al,%edx
c010150c:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101511:	09 d0                	or     %edx,%eax
c0101513:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    shift ^= togglecode[data];
c0101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151c:	0f b6 80 40 81 11 c0 	movzbl -0x3fee7ec0(%eax),%eax
c0101523:	0f b6 d0             	movzbl %al,%edx
c0101526:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010152b:	31 d0                	xor    %edx,%eax
c010152d:	a3 68 b6 11 c0       	mov    %eax,0xc011b668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101532:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101537:	83 e0 03             	and    $0x3,%eax
c010153a:	8b 14 85 40 85 11 c0 	mov    -0x3fee7ac0(,%eax,4),%edx
c0101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101545:	01 d0                	add    %edx,%eax
c0101547:	0f b6 00             	movzbl (%eax),%eax
c010154a:	0f b6 c0             	movzbl %al,%eax
c010154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101550:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101555:	83 e0 08             	and    $0x8,%eax
c0101558:	85 c0                	test   %eax,%eax
c010155a:	74 22                	je     c010157e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c010155c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101560:	7e 0c                	jle    c010156e <kbd_proc_data+0x13a>
c0101562:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101566:	7f 06                	jg     c010156e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101568:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156c:	eb 10                	jmp    c010157e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c010156e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101572:	7e 0a                	jle    c010157e <kbd_proc_data+0x14a>
c0101574:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101578:	7f 04                	jg     c010157e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010157a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010157e:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101583:	f7 d0                	not    %eax
c0101585:	83 e0 06             	and    $0x6,%eax
c0101588:	85 c0                	test   %eax,%eax
c010158a:	75 27                	jne    c01015b3 <kbd_proc_data+0x17f>
c010158c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101593:	75 1e                	jne    c01015b3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c0101595:	c7 04 24 4d 63 10 c0 	movl   $0xc010634d,(%esp)
c010159c:	e8 f1 ec ff ff       	call   c0100292 <cprintf>
c01015a1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015a7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ab:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015af:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01015b2:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015b6:	c9                   	leave  
c01015b7:	c3                   	ret    

c01015b8 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015b8:	55                   	push   %ebp
c01015b9:	89 e5                	mov    %esp,%ebp
c01015bb:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015be:	c7 04 24 34 14 10 c0 	movl   $0xc0101434,(%esp)
c01015c5:	e8 a9 fd ff ff       	call   c0101373 <cons_intr>
}
c01015ca:	90                   	nop
c01015cb:	c9                   	leave  
c01015cc:	c3                   	ret    

c01015cd <kbd_init>:

static void
kbd_init(void) {
c01015cd:	55                   	push   %ebp
c01015ce:	89 e5                	mov    %esp,%ebp
c01015d0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d3:	e8 e0 ff ff ff       	call   c01015b8 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015df:	e8 35 01 00 00       	call   c0101719 <pic_enable>
}
c01015e4:	90                   	nop
c01015e5:	c9                   	leave  
c01015e6:	c3                   	ret    

c01015e7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e7:	55                   	push   %ebp
c01015e8:	89 e5                	mov    %esp,%ebp
c01015ea:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ed:	e8 83 f8 ff ff       	call   c0100e75 <cga_init>
    serial_init();
c01015f2:	e8 62 f9 ff ff       	call   c0100f59 <serial_init>
    kbd_init();
c01015f7:	e8 d1 ff ff ff       	call   c01015cd <kbd_init>
    if (!serial_exists) {
c01015fc:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101601:	85 c0                	test   %eax,%eax
c0101603:	75 0c                	jne    c0101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101605:	c7 04 24 59 63 10 c0 	movl   $0xc0106359,(%esp)
c010160c:	e8 81 ec ff ff       	call   c0100292 <cprintf>
    }
}
c0101611:	90                   	nop
c0101612:	c9                   	leave  
c0101613:	c3                   	ret    

c0101614 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101614:	55                   	push   %ebp
c0101615:	89 e5                	mov    %esp,%ebp
c0101617:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010161a:	e8 cf f7 ff ff       	call   c0100dee <__intr_save>
c010161f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101622:	8b 45 08             	mov    0x8(%ebp),%eax
c0101625:	89 04 24             	mov    %eax,(%esp)
c0101628:	e8 89 fa ff ff       	call   c01010b6 <lpt_putc>
        cga_putc(c);
c010162d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101630:	89 04 24             	mov    %eax,(%esp)
c0101633:	e8 be fa ff ff       	call   c01010f6 <cga_putc>
        serial_putc(c);
c0101638:	8b 45 08             	mov    0x8(%ebp),%eax
c010163b:	89 04 24             	mov    %eax,(%esp)
c010163e:	e8 f0 fc ff ff       	call   c0101333 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101643:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101646:	89 04 24             	mov    %eax,(%esp)
c0101649:	e8 ca f7 ff ff       	call   c0100e18 <__intr_restore>
}
c010164e:	90                   	nop
c010164f:	c9                   	leave  
c0101650:	c3                   	ret    

c0101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101651:	55                   	push   %ebp
c0101652:	89 e5                	mov    %esp,%ebp
c0101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165e:	e8 8b f7 ff ff       	call   c0100dee <__intr_save>
c0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101666:	e8 ab fd ff ff       	call   c0101416 <serial_intr>
        kbd_intr();
c010166b:	e8 48 ff ff ff       	call   c01015b8 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101670:	8b 15 60 b6 11 c0    	mov    0xc011b660,%edx
c0101676:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 b6 11 c0    	mov    %edx,0xc011b660
c010168d:	0f b6 80 60 b4 11 c0 	movzbl -0x3fee4ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 b6 11 c0 00 	movl   $0x0,0xc011b660
c01016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b3:	89 04 24             	mov    %eax,(%esp)
c01016b6:	e8 5d f7 ff ff       	call   c0100e18 <__intr_restore>
    return c;
c01016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016be:	c9                   	leave  
c01016bf:	c3                   	ret    

c01016c0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016c0:	55                   	push   %ebp
c01016c1:	89 e5                	mov    %esp,%ebp
c01016c3:	83 ec 14             	sub    $0x14,%esp
c01016c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016d0:	66 a3 50 85 11 c0    	mov    %ax,0xc0118550
    if (did_init) {
c01016d6:	a1 6c b6 11 c0       	mov    0xc011b66c,%eax
c01016db:	85 c0                	test   %eax,%eax
c01016dd:	74 37                	je     c0101716 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016e2:	0f b6 c0             	movzbl %al,%eax
c01016e5:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01016eb:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016ee:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01016f2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016fb:	c1 e8 08             	shr    $0x8,%eax
c01016fe:	0f b7 c0             	movzwl %ax,%eax
c0101701:	0f b6 c0             	movzbl %al,%eax
c0101704:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010170a:	88 45 fd             	mov    %al,-0x3(%ebp)
c010170d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101711:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101715:	ee                   	out    %al,(%dx)
    }
}
c0101716:	90                   	nop
c0101717:	c9                   	leave  
c0101718:	c3                   	ret    

c0101719 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101719:	55                   	push   %ebp
c010171a:	89 e5                	mov    %esp,%ebp
c010171c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010171f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101722:	ba 01 00 00 00       	mov    $0x1,%edx
c0101727:	88 c1                	mov    %al,%cl
c0101729:	d3 e2                	shl    %cl,%edx
c010172b:	89 d0                	mov    %edx,%eax
c010172d:	98                   	cwtl   
c010172e:	f7 d0                	not    %eax
c0101730:	0f bf d0             	movswl %ax,%edx
c0101733:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010173a:	98                   	cwtl   
c010173b:	21 d0                	and    %edx,%eax
c010173d:	98                   	cwtl   
c010173e:	0f b7 c0             	movzwl %ax,%eax
c0101741:	89 04 24             	mov    %eax,(%esp)
c0101744:	e8 77 ff ff ff       	call   c01016c0 <pic_setmask>
}
c0101749:	90                   	nop
c010174a:	c9                   	leave  
c010174b:	c3                   	ret    

c010174c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010174c:	55                   	push   %ebp
c010174d:	89 e5                	mov    %esp,%ebp
c010174f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101752:	c7 05 6c b6 11 c0 01 	movl   $0x1,0xc011b66c
c0101759:	00 00 00 
c010175c:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101762:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101766:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010176a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010176e:	ee                   	out    %al,(%dx)
c010176f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101775:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c0101779:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010177d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101781:	ee                   	out    %al,(%dx)
c0101782:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101788:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c010178c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101790:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101794:	ee                   	out    %al,(%dx)
c0101795:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010179b:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c010179f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017a3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017a7:	ee                   	out    %al,(%dx)
c01017a8:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01017ae:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c01017b2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017b6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017ba:	ee                   	out    %al,(%dx)
c01017bb:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01017c1:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c01017c5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017c9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017cd:	ee                   	out    %al,(%dx)
c01017ce:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01017d4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c01017d8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017dc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017e0:	ee                   	out    %al,(%dx)
c01017e1:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01017e7:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c01017eb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017ef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017f3:	ee                   	out    %al,(%dx)
c01017f4:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01017fa:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c01017fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101802:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101806:	ee                   	out    %al,(%dx)
c0101807:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010180d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c0101811:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101815:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101819:	ee                   	out    %al,(%dx)
c010181a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101820:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0101824:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101828:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010182c:	ee                   	out    %al,(%dx)
c010182d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101833:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0101837:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010183b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010183f:	ee                   	out    %al,(%dx)
c0101840:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101846:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c010184a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010184e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101852:	ee                   	out    %al,(%dx)
c0101853:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0101859:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c010185d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101861:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101865:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101866:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010186d:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101872:	74 0f                	je     c0101883 <pic_init+0x137>
        pic_setmask(irq_mask);
c0101874:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010187b:	89 04 24             	mov    %eax,(%esp)
c010187e:	e8 3d fe ff ff       	call   c01016c0 <pic_setmask>
    }
}
c0101883:	90                   	nop
c0101884:	c9                   	leave  
c0101885:	c3                   	ret    

c0101886 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101886:	55                   	push   %ebp
c0101887:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101889:	fb                   	sti    
    sti();
}
c010188a:	90                   	nop
c010188b:	5d                   	pop    %ebp
c010188c:	c3                   	ret    

c010188d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101890:	fa                   	cli    
    cli();
}
c0101891:	90                   	nop
c0101892:	5d                   	pop    %ebp
c0101893:	c3                   	ret    

c0101894 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101894:	55                   	push   %ebp
c0101895:	89 e5                	mov    %esp,%ebp
c0101897:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010189a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018a1:	00 
c01018a2:	c7 04 24 80 63 10 c0 	movl   $0xc0106380,(%esp)
c01018a9:	e8 e4 e9 ff ff       	call   c0100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018ae:	90                   	nop
c01018af:	c9                   	leave  
c01018b0:	c3                   	ret    

c01018b1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018b1:	55                   	push   %ebp
c01018b2:	89 e5                	mov    %esp,%ebp
c01018b4:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      for(int i = 0; i < (sizeof(idt)/sizeof(struct gatedesc)); i++) {
c01018b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018be:	e9 4f 01 00 00       	jmp    c0101a12 <idt_init+0x161>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c6:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c01018cd:	0f b7 d0             	movzwl %ax,%edx
c01018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d3:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c01018da:	c0 
c01018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018de:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c01018e5:	c0 08 00 
c01018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018eb:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c01018f2:	c0 
c01018f3:	80 e2 e0             	and    $0xe0,%dl
c01018f6:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101900:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c0101907:	c0 
c0101908:	80 e2 1f             	and    $0x1f,%dl
c010190b:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101915:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c010191c:	c0 
c010191d:	80 e2 f0             	and    $0xf0,%dl
c0101920:	80 ca 0e             	or     $0xe,%dl
c0101923:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010192d:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101934:	c0 
c0101935:	80 e2 ef             	and    $0xef,%dl
c0101938:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010193f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101942:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101949:	c0 
c010194a:	80 e2 9f             	and    $0x9f,%dl
c010194d:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101954:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101957:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c010195e:	c0 
c010195f:	80 ca 80             	or     $0x80,%dl
c0101962:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101969:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196c:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101973:	c1 e8 10             	shr    $0x10,%eax
c0101976:	0f b7 d0             	movzwl %ax,%edx
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c0101983:	c0 
        SETGATE(idt[T_SYSCALL], 0, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c0101984:	a1 e0 87 11 c0       	mov    0xc01187e0,%eax
c0101989:	0f b7 c0             	movzwl %ax,%eax
c010198c:	66 a3 80 ba 11 c0    	mov    %ax,0xc011ba80
c0101992:	66 c7 05 82 ba 11 c0 	movw   $0x8,0xc011ba82
c0101999:	08 00 
c010199b:	0f b6 05 84 ba 11 c0 	movzbl 0xc011ba84,%eax
c01019a2:	24 e0                	and    $0xe0,%al
c01019a4:	a2 84 ba 11 c0       	mov    %al,0xc011ba84
c01019a9:	0f b6 05 84 ba 11 c0 	movzbl 0xc011ba84,%eax
c01019b0:	24 1f                	and    $0x1f,%al
c01019b2:	a2 84 ba 11 c0       	mov    %al,0xc011ba84
c01019b7:	0f b6 05 85 ba 11 c0 	movzbl 0xc011ba85,%eax
c01019be:	24 f0                	and    $0xf0,%al
c01019c0:	0c 0e                	or     $0xe,%al
c01019c2:	a2 85 ba 11 c0       	mov    %al,0xc011ba85
c01019c7:	0f b6 05 85 ba 11 c0 	movzbl 0xc011ba85,%eax
c01019ce:	24 ef                	and    $0xef,%al
c01019d0:	a2 85 ba 11 c0       	mov    %al,0xc011ba85
c01019d5:	0f b6 05 85 ba 11 c0 	movzbl 0xc011ba85,%eax
c01019dc:	0c 60                	or     $0x60,%al
c01019de:	a2 85 ba 11 c0       	mov    %al,0xc011ba85
c01019e3:	0f b6 05 85 ba 11 c0 	movzbl 0xc011ba85,%eax
c01019ea:	0c 80                	or     $0x80,%al
c01019ec:	a2 85 ba 11 c0       	mov    %al,0xc011ba85
c01019f1:	a1 e0 87 11 c0       	mov    0xc01187e0,%eax
c01019f6:	c1 e8 10             	shr    $0x10,%eax
c01019f9:	0f b7 c0             	movzwl %ax,%eax
c01019fc:	66 a3 86 ba 11 c0    	mov    %ax,0xc011ba86
c0101a02:	c7 45 f8 60 85 11 c0 	movl   $0xc0118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a0c:	0f 01 18             	lidtl  (%eax)
      for(int i = 0; i < (sizeof(idt)/sizeof(struct gatedesc)); i++) {
c0101a0f:	ff 45 fc             	incl   -0x4(%ebp)
c0101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a15:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a1a:	0f 86 a3 fe ff ff    	jbe    c01018c3 <idt_init+0x12>
        lidt(&idt_pd);
      }
}
c0101a20:	90                   	nop
c0101a21:	c9                   	leave  
c0101a22:	c3                   	ret    

c0101a23 <trapname>:

static const char *
trapname(int trapno) {
c0101a23:	55                   	push   %ebp
c0101a24:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a29:	83 f8 13             	cmp    $0x13,%eax
c0101a2c:	77 0c                	ja     c0101a3a <trapname+0x17>
        return excnames[trapno];
c0101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a31:	8b 04 85 e0 66 10 c0 	mov    -0x3fef9920(,%eax,4),%eax
c0101a38:	eb 18                	jmp    c0101a52 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a3a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a3e:	7e 0d                	jle    c0101a4d <trapname+0x2a>
c0101a40:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a44:	7f 07                	jg     c0101a4d <trapname+0x2a>
        return "Hardware Interrupt";
c0101a46:	b8 8a 63 10 c0       	mov    $0xc010638a,%eax
c0101a4b:	eb 05                	jmp    c0101a52 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a4d:	b8 9d 63 10 c0       	mov    $0xc010639d,%eax
}
c0101a52:	5d                   	pop    %ebp
c0101a53:	c3                   	ret    

c0101a54 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a54:	55                   	push   %ebp
c0101a55:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a57:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a5a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a5e:	83 f8 08             	cmp    $0x8,%eax
c0101a61:	0f 94 c0             	sete   %al
c0101a64:	0f b6 c0             	movzbl %al,%eax
}
c0101a67:	5d                   	pop    %ebp
c0101a68:	c3                   	ret    

c0101a69 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a69:	55                   	push   %ebp
c0101a6a:	89 e5                	mov    %esp,%ebp
c0101a6c:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a76:	c7 04 24 de 63 10 c0 	movl   $0xc01063de,(%esp)
c0101a7d:	e8 10 e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a85:	89 04 24             	mov    %eax,(%esp)
c0101a88:	e8 8f 01 00 00       	call   c0101c1c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a90:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a94:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a98:	c7 04 24 ef 63 10 c0 	movl   $0xc01063ef,(%esp)
c0101a9f:	e8 ee e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa7:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101aab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aaf:	c7 04 24 02 64 10 c0 	movl   $0xc0106402,(%esp)
c0101ab6:	e8 d7 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abe:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac6:	c7 04 24 15 64 10 c0 	movl   $0xc0106415,(%esp)
c0101acd:	e8 c0 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101add:	c7 04 24 28 64 10 c0 	movl   $0xc0106428,(%esp)
c0101ae4:	e8 a9 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aec:	8b 40 30             	mov    0x30(%eax),%eax
c0101aef:	89 04 24             	mov    %eax,(%esp)
c0101af2:	e8 2c ff ff ff       	call   c0101a23 <trapname>
c0101af7:	89 c2                	mov    %eax,%edx
c0101af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101afc:	8b 40 30             	mov    0x30(%eax),%eax
c0101aff:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b07:	c7 04 24 3b 64 10 c0 	movl   $0xc010643b,(%esp)
c0101b0e:	e8 7f e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b16:	8b 40 34             	mov    0x34(%eax),%eax
c0101b19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b1d:	c7 04 24 4d 64 10 c0 	movl   $0xc010644d,(%esp)
c0101b24:	e8 69 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2c:	8b 40 38             	mov    0x38(%eax),%eax
c0101b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b33:	c7 04 24 5c 64 10 c0 	movl   $0xc010645c,(%esp)
c0101b3a:	e8 53 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4a:	c7 04 24 6b 64 10 c0 	movl   $0xc010646b,(%esp)
c0101b51:	e8 3c e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b59:	8b 40 40             	mov    0x40(%eax),%eax
c0101b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b60:	c7 04 24 7e 64 10 c0 	movl   $0xc010647e,(%esp)
c0101b67:	e8 26 e7 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b73:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b7a:	eb 3d                	jmp    c0101bb9 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7f:	8b 50 40             	mov    0x40(%eax),%edx
c0101b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b85:	21 d0                	and    %edx,%eax
c0101b87:	85 c0                	test   %eax,%eax
c0101b89:	74 28                	je     c0101bb3 <print_trapframe+0x14a>
c0101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b8e:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101b95:	85 c0                	test   %eax,%eax
c0101b97:	74 1a                	je     c0101bb3 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b9c:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba7:	c7 04 24 8d 64 10 c0 	movl   $0xc010648d,(%esp)
c0101bae:	e8 df e6 ff ff       	call   c0100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bb3:	ff 45 f4             	incl   -0xc(%ebp)
c0101bb6:	d1 65 f0             	shll   -0x10(%ebp)
c0101bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bbc:	83 f8 17             	cmp    $0x17,%eax
c0101bbf:	76 bb                	jbe    c0101b7c <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc4:	8b 40 40             	mov    0x40(%eax),%eax
c0101bc7:	c1 e8 0c             	shr    $0xc,%eax
c0101bca:	83 e0 03             	and    $0x3,%eax
c0101bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd1:	c7 04 24 91 64 10 c0 	movl   $0xc0106491,(%esp)
c0101bd8:	e8 b5 e6 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be0:	89 04 24             	mov    %eax,(%esp)
c0101be3:	e8 6c fe ff ff       	call   c0101a54 <trap_in_kernel>
c0101be8:	85 c0                	test   %eax,%eax
c0101bea:	75 2d                	jne    c0101c19 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101bec:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bef:	8b 40 44             	mov    0x44(%eax),%eax
c0101bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf6:	c7 04 24 9a 64 10 c0 	movl   $0xc010649a,(%esp)
c0101bfd:	e8 90 e6 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c02:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c05:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c0d:	c7 04 24 a9 64 10 c0 	movl   $0xc01064a9,(%esp)
c0101c14:	e8 79 e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101c19:	90                   	nop
c0101c1a:	c9                   	leave  
c0101c1b:	c3                   	ret    

c0101c1c <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c1c:	55                   	push   %ebp
c0101c1d:	89 e5                	mov    %esp,%ebp
c0101c1f:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c25:	8b 00                	mov    (%eax),%eax
c0101c27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c2b:	c7 04 24 bc 64 10 c0 	movl   $0xc01064bc,(%esp)
c0101c32:	e8 5b e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c37:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3a:	8b 40 04             	mov    0x4(%eax),%eax
c0101c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c41:	c7 04 24 cb 64 10 c0 	movl   $0xc01064cb,(%esp)
c0101c48:	e8 45 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c50:	8b 40 08             	mov    0x8(%eax),%eax
c0101c53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c57:	c7 04 24 da 64 10 c0 	movl   $0xc01064da,(%esp)
c0101c5e:	e8 2f e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c66:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c6d:	c7 04 24 e9 64 10 c0 	movl   $0xc01064e9,(%esp)
c0101c74:	e8 19 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7c:	8b 40 10             	mov    0x10(%eax),%eax
c0101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c83:	c7 04 24 f8 64 10 c0 	movl   $0xc01064f8,(%esp)
c0101c8a:	e8 03 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c92:	8b 40 14             	mov    0x14(%eax),%eax
c0101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c99:	c7 04 24 07 65 10 c0 	movl   $0xc0106507,(%esp)
c0101ca0:	e8 ed e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca8:	8b 40 18             	mov    0x18(%eax),%eax
c0101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101caf:	c7 04 24 16 65 10 c0 	movl   $0xc0106516,(%esp)
c0101cb6:	e8 d7 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cbe:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc5:	c7 04 24 25 65 10 c0 	movl   $0xc0106525,(%esp)
c0101ccc:	e8 c1 e5 ff ff       	call   c0100292 <cprintf>
}
c0101cd1:	90                   	nop
c0101cd2:	c9                   	leave  
c0101cd3:	c3                   	ret    

c0101cd4 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cd4:	55                   	push   %ebp
c0101cd5:	89 e5                	mov    %esp,%ebp
c0101cd7:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cdd:	8b 40 30             	mov    0x30(%eax),%eax
c0101ce0:	83 f8 2f             	cmp    $0x2f,%eax
c0101ce3:	77 21                	ja     c0101d06 <trap_dispatch+0x32>
c0101ce5:	83 f8 2e             	cmp    $0x2e,%eax
c0101ce8:	0f 83 16 01 00 00    	jae    c0101e04 <trap_dispatch+0x130>
c0101cee:	83 f8 21             	cmp    $0x21,%eax
c0101cf1:	0f 84 96 00 00 00    	je     c0101d8d <trap_dispatch+0xb9>
c0101cf7:	83 f8 24             	cmp    $0x24,%eax
c0101cfa:	74 6b                	je     c0101d67 <trap_dispatch+0x93>
c0101cfc:	83 f8 20             	cmp    $0x20,%eax
c0101cff:	74 16                	je     c0101d17 <trap_dispatch+0x43>
c0101d01:	e9 c9 00 00 00       	jmp    c0101dcf <trap_dispatch+0xfb>
c0101d06:	83 e8 78             	sub    $0x78,%eax
c0101d09:	83 f8 01             	cmp    $0x1,%eax
c0101d0c:	0f 87 bd 00 00 00    	ja     c0101dcf <trap_dispatch+0xfb>
c0101d12:	e9 9c 00 00 00       	jmp    c0101db3 <trap_dispatch+0xdf>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
         ticks++;
c0101d17:	a1 0c bf 11 c0       	mov    0xc011bf0c,%eax
c0101d1c:	40                   	inc    %eax
c0101d1d:	a3 0c bf 11 c0       	mov    %eax,0xc011bf0c
         if(ticks % TICK_NUM == 0) {
c0101d22:	8b 0d 0c bf 11 c0    	mov    0xc011bf0c,%ecx
c0101d28:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d2d:	89 c8                	mov    %ecx,%eax
c0101d2f:	f7 e2                	mul    %edx
c0101d31:	c1 ea 05             	shr    $0x5,%edx
c0101d34:	89 d0                	mov    %edx,%eax
c0101d36:	c1 e0 02             	shl    $0x2,%eax
c0101d39:	01 d0                	add    %edx,%eax
c0101d3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101d42:	01 d0                	add    %edx,%eax
c0101d44:	c1 e0 02             	shl    $0x2,%eax
c0101d47:	29 c1                	sub    %eax,%ecx
c0101d49:	89 ca                	mov    %ecx,%edx
c0101d4b:	85 d2                	test   %edx,%edx
c0101d4d:	0f 85 b4 00 00 00    	jne    c0101e07 <trap_dispatch+0x133>
             print_ticks();
c0101d53:	e8 3c fb ff ff       	call   c0101894 <print_ticks>
             ticks = 0;
c0101d58:	c7 05 0c bf 11 c0 00 	movl   $0x0,0xc011bf0c
c0101d5f:	00 00 00 
         }
        break;
c0101d62:	e9 a0 00 00 00       	jmp    c0101e07 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d67:	e8 e5 f8 ff ff       	call   c0101651 <cons_getc>
c0101d6c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d6f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d73:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d77:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d7f:	c7 04 24 34 65 10 c0 	movl   $0xc0106534,(%esp)
c0101d86:	e8 07 e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d8b:	eb 7b                	jmp    c0101e08 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d8d:	e8 bf f8 ff ff       	call   c0101651 <cons_getc>
c0101d92:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d95:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d99:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d9d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101da1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101da5:	c7 04 24 46 65 10 c0 	movl   $0xc0106546,(%esp)
c0101dac:	e8 e1 e4 ff ff       	call   c0100292 <cprintf>
        break;
c0101db1:	eb 55                	jmp    c0101e08 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101db3:	c7 44 24 08 55 65 10 	movl   $0xc0106555,0x8(%esp)
c0101dba:	c0 
c0101dbb:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0101dc2:	00 
c0101dc3:	c7 04 24 65 65 10 c0 	movl   $0xc0106565,(%esp)
c0101dca:	e8 1a e6 ff ff       	call   c01003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dd2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dd6:	83 e0 03             	and    $0x3,%eax
c0101dd9:	85 c0                	test   %eax,%eax
c0101ddb:	75 2b                	jne    c0101e08 <trap_dispatch+0x134>
            print_trapframe(tf);
c0101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101de0:	89 04 24             	mov    %eax,(%esp)
c0101de3:	e8 81 fc ff ff       	call   c0101a69 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101de8:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0101def:	c0 
c0101df0:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0101df7:	00 
c0101df8:	c7 04 24 65 65 10 c0 	movl   $0xc0106565,(%esp)
c0101dff:	e8 e5 e5 ff ff       	call   c01003e9 <__panic>
        break;
c0101e04:	90                   	nop
c0101e05:	eb 01                	jmp    c0101e08 <trap_dispatch+0x134>
        break;
c0101e07:	90                   	nop
        }
    }
}
c0101e08:	90                   	nop
c0101e09:	c9                   	leave  
c0101e0a:	c3                   	ret    

c0101e0b <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101e0b:	55                   	push   %ebp
c0101e0c:	89 e5                	mov    %esp,%ebp
c0101e0e:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e11:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e14:	89 04 24             	mov    %eax,(%esp)
c0101e17:	e8 b8 fe ff ff       	call   c0101cd4 <trap_dispatch>
}
c0101e1c:	90                   	nop
c0101e1d:	c9                   	leave  
c0101e1e:	c3                   	ret    

c0101e1f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e1f:	6a 00                	push   $0x0
  pushl $0
c0101e21:	6a 00                	push   $0x0
  jmp __alltraps
c0101e23:	e9 69 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e28 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e28:	6a 00                	push   $0x0
  pushl $1
c0101e2a:	6a 01                	push   $0x1
  jmp __alltraps
c0101e2c:	e9 60 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e31 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e31:	6a 00                	push   $0x0
  pushl $2
c0101e33:	6a 02                	push   $0x2
  jmp __alltraps
c0101e35:	e9 57 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e3a <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e3a:	6a 00                	push   $0x0
  pushl $3
c0101e3c:	6a 03                	push   $0x3
  jmp __alltraps
c0101e3e:	e9 4e 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e43 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e43:	6a 00                	push   $0x0
  pushl $4
c0101e45:	6a 04                	push   $0x4
  jmp __alltraps
c0101e47:	e9 45 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e4c <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e4c:	6a 00                	push   $0x0
  pushl $5
c0101e4e:	6a 05                	push   $0x5
  jmp __alltraps
c0101e50:	e9 3c 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e55 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e55:	6a 00                	push   $0x0
  pushl $6
c0101e57:	6a 06                	push   $0x6
  jmp __alltraps
c0101e59:	e9 33 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e5e <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e5e:	6a 00                	push   $0x0
  pushl $7
c0101e60:	6a 07                	push   $0x7
  jmp __alltraps
c0101e62:	e9 2a 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e67 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e67:	6a 08                	push   $0x8
  jmp __alltraps
c0101e69:	e9 23 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e6e <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e6e:	6a 00                	push   $0x0
  pushl $9
c0101e70:	6a 09                	push   $0x9
  jmp __alltraps
c0101e72:	e9 1a 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e77 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e77:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e79:	e9 13 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e7e <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e7e:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e80:	e9 0c 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e85 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e85:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e87:	e9 05 0a 00 00       	jmp    c0102891 <__alltraps>

c0101e8c <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e8c:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e8e:	e9 fe 09 00 00       	jmp    c0102891 <__alltraps>

c0101e93 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e93:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e95:	e9 f7 09 00 00       	jmp    c0102891 <__alltraps>

c0101e9a <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e9a:	6a 00                	push   $0x0
  pushl $15
c0101e9c:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e9e:	e9 ee 09 00 00       	jmp    c0102891 <__alltraps>

c0101ea3 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101ea3:	6a 00                	push   $0x0
  pushl $16
c0101ea5:	6a 10                	push   $0x10
  jmp __alltraps
c0101ea7:	e9 e5 09 00 00       	jmp    c0102891 <__alltraps>

c0101eac <vector17>:
.globl vector17
vector17:
  pushl $17
c0101eac:	6a 11                	push   $0x11
  jmp __alltraps
c0101eae:	e9 de 09 00 00       	jmp    c0102891 <__alltraps>

c0101eb3 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101eb3:	6a 00                	push   $0x0
  pushl $18
c0101eb5:	6a 12                	push   $0x12
  jmp __alltraps
c0101eb7:	e9 d5 09 00 00       	jmp    c0102891 <__alltraps>

c0101ebc <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ebc:	6a 00                	push   $0x0
  pushl $19
c0101ebe:	6a 13                	push   $0x13
  jmp __alltraps
c0101ec0:	e9 cc 09 00 00       	jmp    c0102891 <__alltraps>

c0101ec5 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101ec5:	6a 00                	push   $0x0
  pushl $20
c0101ec7:	6a 14                	push   $0x14
  jmp __alltraps
c0101ec9:	e9 c3 09 00 00       	jmp    c0102891 <__alltraps>

c0101ece <vector21>:
.globl vector21
vector21:
  pushl $0
c0101ece:	6a 00                	push   $0x0
  pushl $21
c0101ed0:	6a 15                	push   $0x15
  jmp __alltraps
c0101ed2:	e9 ba 09 00 00       	jmp    c0102891 <__alltraps>

c0101ed7 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101ed7:	6a 00                	push   $0x0
  pushl $22
c0101ed9:	6a 16                	push   $0x16
  jmp __alltraps
c0101edb:	e9 b1 09 00 00       	jmp    c0102891 <__alltraps>

c0101ee0 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101ee0:	6a 00                	push   $0x0
  pushl $23
c0101ee2:	6a 17                	push   $0x17
  jmp __alltraps
c0101ee4:	e9 a8 09 00 00       	jmp    c0102891 <__alltraps>

c0101ee9 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101ee9:	6a 00                	push   $0x0
  pushl $24
c0101eeb:	6a 18                	push   $0x18
  jmp __alltraps
c0101eed:	e9 9f 09 00 00       	jmp    c0102891 <__alltraps>

c0101ef2 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101ef2:	6a 00                	push   $0x0
  pushl $25
c0101ef4:	6a 19                	push   $0x19
  jmp __alltraps
c0101ef6:	e9 96 09 00 00       	jmp    c0102891 <__alltraps>

c0101efb <vector26>:
.globl vector26
vector26:
  pushl $0
c0101efb:	6a 00                	push   $0x0
  pushl $26
c0101efd:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101eff:	e9 8d 09 00 00       	jmp    c0102891 <__alltraps>

c0101f04 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f04:	6a 00                	push   $0x0
  pushl $27
c0101f06:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f08:	e9 84 09 00 00       	jmp    c0102891 <__alltraps>

c0101f0d <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f0d:	6a 00                	push   $0x0
  pushl $28
c0101f0f:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f11:	e9 7b 09 00 00       	jmp    c0102891 <__alltraps>

c0101f16 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f16:	6a 00                	push   $0x0
  pushl $29
c0101f18:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f1a:	e9 72 09 00 00       	jmp    c0102891 <__alltraps>

c0101f1f <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f1f:	6a 00                	push   $0x0
  pushl $30
c0101f21:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f23:	e9 69 09 00 00       	jmp    c0102891 <__alltraps>

c0101f28 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f28:	6a 00                	push   $0x0
  pushl $31
c0101f2a:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f2c:	e9 60 09 00 00       	jmp    c0102891 <__alltraps>

c0101f31 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f31:	6a 00                	push   $0x0
  pushl $32
c0101f33:	6a 20                	push   $0x20
  jmp __alltraps
c0101f35:	e9 57 09 00 00       	jmp    c0102891 <__alltraps>

c0101f3a <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f3a:	6a 00                	push   $0x0
  pushl $33
c0101f3c:	6a 21                	push   $0x21
  jmp __alltraps
c0101f3e:	e9 4e 09 00 00       	jmp    c0102891 <__alltraps>

c0101f43 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f43:	6a 00                	push   $0x0
  pushl $34
c0101f45:	6a 22                	push   $0x22
  jmp __alltraps
c0101f47:	e9 45 09 00 00       	jmp    c0102891 <__alltraps>

c0101f4c <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f4c:	6a 00                	push   $0x0
  pushl $35
c0101f4e:	6a 23                	push   $0x23
  jmp __alltraps
c0101f50:	e9 3c 09 00 00       	jmp    c0102891 <__alltraps>

c0101f55 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f55:	6a 00                	push   $0x0
  pushl $36
c0101f57:	6a 24                	push   $0x24
  jmp __alltraps
c0101f59:	e9 33 09 00 00       	jmp    c0102891 <__alltraps>

c0101f5e <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f5e:	6a 00                	push   $0x0
  pushl $37
c0101f60:	6a 25                	push   $0x25
  jmp __alltraps
c0101f62:	e9 2a 09 00 00       	jmp    c0102891 <__alltraps>

c0101f67 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f67:	6a 00                	push   $0x0
  pushl $38
c0101f69:	6a 26                	push   $0x26
  jmp __alltraps
c0101f6b:	e9 21 09 00 00       	jmp    c0102891 <__alltraps>

c0101f70 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f70:	6a 00                	push   $0x0
  pushl $39
c0101f72:	6a 27                	push   $0x27
  jmp __alltraps
c0101f74:	e9 18 09 00 00       	jmp    c0102891 <__alltraps>

c0101f79 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f79:	6a 00                	push   $0x0
  pushl $40
c0101f7b:	6a 28                	push   $0x28
  jmp __alltraps
c0101f7d:	e9 0f 09 00 00       	jmp    c0102891 <__alltraps>

c0101f82 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f82:	6a 00                	push   $0x0
  pushl $41
c0101f84:	6a 29                	push   $0x29
  jmp __alltraps
c0101f86:	e9 06 09 00 00       	jmp    c0102891 <__alltraps>

c0101f8b <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f8b:	6a 00                	push   $0x0
  pushl $42
c0101f8d:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f8f:	e9 fd 08 00 00       	jmp    c0102891 <__alltraps>

c0101f94 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f94:	6a 00                	push   $0x0
  pushl $43
c0101f96:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f98:	e9 f4 08 00 00       	jmp    c0102891 <__alltraps>

c0101f9d <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f9d:	6a 00                	push   $0x0
  pushl $44
c0101f9f:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101fa1:	e9 eb 08 00 00       	jmp    c0102891 <__alltraps>

c0101fa6 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101fa6:	6a 00                	push   $0x0
  pushl $45
c0101fa8:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101faa:	e9 e2 08 00 00       	jmp    c0102891 <__alltraps>

c0101faf <vector46>:
.globl vector46
vector46:
  pushl $0
c0101faf:	6a 00                	push   $0x0
  pushl $46
c0101fb1:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101fb3:	e9 d9 08 00 00       	jmp    c0102891 <__alltraps>

c0101fb8 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101fb8:	6a 00                	push   $0x0
  pushl $47
c0101fba:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101fbc:	e9 d0 08 00 00       	jmp    c0102891 <__alltraps>

c0101fc1 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101fc1:	6a 00                	push   $0x0
  pushl $48
c0101fc3:	6a 30                	push   $0x30
  jmp __alltraps
c0101fc5:	e9 c7 08 00 00       	jmp    c0102891 <__alltraps>

c0101fca <vector49>:
.globl vector49
vector49:
  pushl $0
c0101fca:	6a 00                	push   $0x0
  pushl $49
c0101fcc:	6a 31                	push   $0x31
  jmp __alltraps
c0101fce:	e9 be 08 00 00       	jmp    c0102891 <__alltraps>

c0101fd3 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101fd3:	6a 00                	push   $0x0
  pushl $50
c0101fd5:	6a 32                	push   $0x32
  jmp __alltraps
c0101fd7:	e9 b5 08 00 00       	jmp    c0102891 <__alltraps>

c0101fdc <vector51>:
.globl vector51
vector51:
  pushl $0
c0101fdc:	6a 00                	push   $0x0
  pushl $51
c0101fde:	6a 33                	push   $0x33
  jmp __alltraps
c0101fe0:	e9 ac 08 00 00       	jmp    c0102891 <__alltraps>

c0101fe5 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101fe5:	6a 00                	push   $0x0
  pushl $52
c0101fe7:	6a 34                	push   $0x34
  jmp __alltraps
c0101fe9:	e9 a3 08 00 00       	jmp    c0102891 <__alltraps>

c0101fee <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fee:	6a 00                	push   $0x0
  pushl $53
c0101ff0:	6a 35                	push   $0x35
  jmp __alltraps
c0101ff2:	e9 9a 08 00 00       	jmp    c0102891 <__alltraps>

c0101ff7 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101ff7:	6a 00                	push   $0x0
  pushl $54
c0101ff9:	6a 36                	push   $0x36
  jmp __alltraps
c0101ffb:	e9 91 08 00 00       	jmp    c0102891 <__alltraps>

c0102000 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102000:	6a 00                	push   $0x0
  pushl $55
c0102002:	6a 37                	push   $0x37
  jmp __alltraps
c0102004:	e9 88 08 00 00       	jmp    c0102891 <__alltraps>

c0102009 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102009:	6a 00                	push   $0x0
  pushl $56
c010200b:	6a 38                	push   $0x38
  jmp __alltraps
c010200d:	e9 7f 08 00 00       	jmp    c0102891 <__alltraps>

c0102012 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102012:	6a 00                	push   $0x0
  pushl $57
c0102014:	6a 39                	push   $0x39
  jmp __alltraps
c0102016:	e9 76 08 00 00       	jmp    c0102891 <__alltraps>

c010201b <vector58>:
.globl vector58
vector58:
  pushl $0
c010201b:	6a 00                	push   $0x0
  pushl $58
c010201d:	6a 3a                	push   $0x3a
  jmp __alltraps
c010201f:	e9 6d 08 00 00       	jmp    c0102891 <__alltraps>

c0102024 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102024:	6a 00                	push   $0x0
  pushl $59
c0102026:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102028:	e9 64 08 00 00       	jmp    c0102891 <__alltraps>

c010202d <vector60>:
.globl vector60
vector60:
  pushl $0
c010202d:	6a 00                	push   $0x0
  pushl $60
c010202f:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102031:	e9 5b 08 00 00       	jmp    c0102891 <__alltraps>

c0102036 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102036:	6a 00                	push   $0x0
  pushl $61
c0102038:	6a 3d                	push   $0x3d
  jmp __alltraps
c010203a:	e9 52 08 00 00       	jmp    c0102891 <__alltraps>

c010203f <vector62>:
.globl vector62
vector62:
  pushl $0
c010203f:	6a 00                	push   $0x0
  pushl $62
c0102041:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102043:	e9 49 08 00 00       	jmp    c0102891 <__alltraps>

c0102048 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102048:	6a 00                	push   $0x0
  pushl $63
c010204a:	6a 3f                	push   $0x3f
  jmp __alltraps
c010204c:	e9 40 08 00 00       	jmp    c0102891 <__alltraps>

c0102051 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102051:	6a 00                	push   $0x0
  pushl $64
c0102053:	6a 40                	push   $0x40
  jmp __alltraps
c0102055:	e9 37 08 00 00       	jmp    c0102891 <__alltraps>

c010205a <vector65>:
.globl vector65
vector65:
  pushl $0
c010205a:	6a 00                	push   $0x0
  pushl $65
c010205c:	6a 41                	push   $0x41
  jmp __alltraps
c010205e:	e9 2e 08 00 00       	jmp    c0102891 <__alltraps>

c0102063 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102063:	6a 00                	push   $0x0
  pushl $66
c0102065:	6a 42                	push   $0x42
  jmp __alltraps
c0102067:	e9 25 08 00 00       	jmp    c0102891 <__alltraps>

c010206c <vector67>:
.globl vector67
vector67:
  pushl $0
c010206c:	6a 00                	push   $0x0
  pushl $67
c010206e:	6a 43                	push   $0x43
  jmp __alltraps
c0102070:	e9 1c 08 00 00       	jmp    c0102891 <__alltraps>

c0102075 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102075:	6a 00                	push   $0x0
  pushl $68
c0102077:	6a 44                	push   $0x44
  jmp __alltraps
c0102079:	e9 13 08 00 00       	jmp    c0102891 <__alltraps>

c010207e <vector69>:
.globl vector69
vector69:
  pushl $0
c010207e:	6a 00                	push   $0x0
  pushl $69
c0102080:	6a 45                	push   $0x45
  jmp __alltraps
c0102082:	e9 0a 08 00 00       	jmp    c0102891 <__alltraps>

c0102087 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102087:	6a 00                	push   $0x0
  pushl $70
c0102089:	6a 46                	push   $0x46
  jmp __alltraps
c010208b:	e9 01 08 00 00       	jmp    c0102891 <__alltraps>

c0102090 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102090:	6a 00                	push   $0x0
  pushl $71
c0102092:	6a 47                	push   $0x47
  jmp __alltraps
c0102094:	e9 f8 07 00 00       	jmp    c0102891 <__alltraps>

c0102099 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102099:	6a 00                	push   $0x0
  pushl $72
c010209b:	6a 48                	push   $0x48
  jmp __alltraps
c010209d:	e9 ef 07 00 00       	jmp    c0102891 <__alltraps>

c01020a2 <vector73>:
.globl vector73
vector73:
  pushl $0
c01020a2:	6a 00                	push   $0x0
  pushl $73
c01020a4:	6a 49                	push   $0x49
  jmp __alltraps
c01020a6:	e9 e6 07 00 00       	jmp    c0102891 <__alltraps>

c01020ab <vector74>:
.globl vector74
vector74:
  pushl $0
c01020ab:	6a 00                	push   $0x0
  pushl $74
c01020ad:	6a 4a                	push   $0x4a
  jmp __alltraps
c01020af:	e9 dd 07 00 00       	jmp    c0102891 <__alltraps>

c01020b4 <vector75>:
.globl vector75
vector75:
  pushl $0
c01020b4:	6a 00                	push   $0x0
  pushl $75
c01020b6:	6a 4b                	push   $0x4b
  jmp __alltraps
c01020b8:	e9 d4 07 00 00       	jmp    c0102891 <__alltraps>

c01020bd <vector76>:
.globl vector76
vector76:
  pushl $0
c01020bd:	6a 00                	push   $0x0
  pushl $76
c01020bf:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020c1:	e9 cb 07 00 00       	jmp    c0102891 <__alltraps>

c01020c6 <vector77>:
.globl vector77
vector77:
  pushl $0
c01020c6:	6a 00                	push   $0x0
  pushl $77
c01020c8:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020ca:	e9 c2 07 00 00       	jmp    c0102891 <__alltraps>

c01020cf <vector78>:
.globl vector78
vector78:
  pushl $0
c01020cf:	6a 00                	push   $0x0
  pushl $78
c01020d1:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020d3:	e9 b9 07 00 00       	jmp    c0102891 <__alltraps>

c01020d8 <vector79>:
.globl vector79
vector79:
  pushl $0
c01020d8:	6a 00                	push   $0x0
  pushl $79
c01020da:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020dc:	e9 b0 07 00 00       	jmp    c0102891 <__alltraps>

c01020e1 <vector80>:
.globl vector80
vector80:
  pushl $0
c01020e1:	6a 00                	push   $0x0
  pushl $80
c01020e3:	6a 50                	push   $0x50
  jmp __alltraps
c01020e5:	e9 a7 07 00 00       	jmp    c0102891 <__alltraps>

c01020ea <vector81>:
.globl vector81
vector81:
  pushl $0
c01020ea:	6a 00                	push   $0x0
  pushl $81
c01020ec:	6a 51                	push   $0x51
  jmp __alltraps
c01020ee:	e9 9e 07 00 00       	jmp    c0102891 <__alltraps>

c01020f3 <vector82>:
.globl vector82
vector82:
  pushl $0
c01020f3:	6a 00                	push   $0x0
  pushl $82
c01020f5:	6a 52                	push   $0x52
  jmp __alltraps
c01020f7:	e9 95 07 00 00       	jmp    c0102891 <__alltraps>

c01020fc <vector83>:
.globl vector83
vector83:
  pushl $0
c01020fc:	6a 00                	push   $0x0
  pushl $83
c01020fe:	6a 53                	push   $0x53
  jmp __alltraps
c0102100:	e9 8c 07 00 00       	jmp    c0102891 <__alltraps>

c0102105 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102105:	6a 00                	push   $0x0
  pushl $84
c0102107:	6a 54                	push   $0x54
  jmp __alltraps
c0102109:	e9 83 07 00 00       	jmp    c0102891 <__alltraps>

c010210e <vector85>:
.globl vector85
vector85:
  pushl $0
c010210e:	6a 00                	push   $0x0
  pushl $85
c0102110:	6a 55                	push   $0x55
  jmp __alltraps
c0102112:	e9 7a 07 00 00       	jmp    c0102891 <__alltraps>

c0102117 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102117:	6a 00                	push   $0x0
  pushl $86
c0102119:	6a 56                	push   $0x56
  jmp __alltraps
c010211b:	e9 71 07 00 00       	jmp    c0102891 <__alltraps>

c0102120 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102120:	6a 00                	push   $0x0
  pushl $87
c0102122:	6a 57                	push   $0x57
  jmp __alltraps
c0102124:	e9 68 07 00 00       	jmp    c0102891 <__alltraps>

c0102129 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102129:	6a 00                	push   $0x0
  pushl $88
c010212b:	6a 58                	push   $0x58
  jmp __alltraps
c010212d:	e9 5f 07 00 00       	jmp    c0102891 <__alltraps>

c0102132 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102132:	6a 00                	push   $0x0
  pushl $89
c0102134:	6a 59                	push   $0x59
  jmp __alltraps
c0102136:	e9 56 07 00 00       	jmp    c0102891 <__alltraps>

c010213b <vector90>:
.globl vector90
vector90:
  pushl $0
c010213b:	6a 00                	push   $0x0
  pushl $90
c010213d:	6a 5a                	push   $0x5a
  jmp __alltraps
c010213f:	e9 4d 07 00 00       	jmp    c0102891 <__alltraps>

c0102144 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102144:	6a 00                	push   $0x0
  pushl $91
c0102146:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102148:	e9 44 07 00 00       	jmp    c0102891 <__alltraps>

c010214d <vector92>:
.globl vector92
vector92:
  pushl $0
c010214d:	6a 00                	push   $0x0
  pushl $92
c010214f:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102151:	e9 3b 07 00 00       	jmp    c0102891 <__alltraps>

c0102156 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102156:	6a 00                	push   $0x0
  pushl $93
c0102158:	6a 5d                	push   $0x5d
  jmp __alltraps
c010215a:	e9 32 07 00 00       	jmp    c0102891 <__alltraps>

c010215f <vector94>:
.globl vector94
vector94:
  pushl $0
c010215f:	6a 00                	push   $0x0
  pushl $94
c0102161:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102163:	e9 29 07 00 00       	jmp    c0102891 <__alltraps>

c0102168 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102168:	6a 00                	push   $0x0
  pushl $95
c010216a:	6a 5f                	push   $0x5f
  jmp __alltraps
c010216c:	e9 20 07 00 00       	jmp    c0102891 <__alltraps>

c0102171 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102171:	6a 00                	push   $0x0
  pushl $96
c0102173:	6a 60                	push   $0x60
  jmp __alltraps
c0102175:	e9 17 07 00 00       	jmp    c0102891 <__alltraps>

c010217a <vector97>:
.globl vector97
vector97:
  pushl $0
c010217a:	6a 00                	push   $0x0
  pushl $97
c010217c:	6a 61                	push   $0x61
  jmp __alltraps
c010217e:	e9 0e 07 00 00       	jmp    c0102891 <__alltraps>

c0102183 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102183:	6a 00                	push   $0x0
  pushl $98
c0102185:	6a 62                	push   $0x62
  jmp __alltraps
c0102187:	e9 05 07 00 00       	jmp    c0102891 <__alltraps>

c010218c <vector99>:
.globl vector99
vector99:
  pushl $0
c010218c:	6a 00                	push   $0x0
  pushl $99
c010218e:	6a 63                	push   $0x63
  jmp __alltraps
c0102190:	e9 fc 06 00 00       	jmp    c0102891 <__alltraps>

c0102195 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102195:	6a 00                	push   $0x0
  pushl $100
c0102197:	6a 64                	push   $0x64
  jmp __alltraps
c0102199:	e9 f3 06 00 00       	jmp    c0102891 <__alltraps>

c010219e <vector101>:
.globl vector101
vector101:
  pushl $0
c010219e:	6a 00                	push   $0x0
  pushl $101
c01021a0:	6a 65                	push   $0x65
  jmp __alltraps
c01021a2:	e9 ea 06 00 00       	jmp    c0102891 <__alltraps>

c01021a7 <vector102>:
.globl vector102
vector102:
  pushl $0
c01021a7:	6a 00                	push   $0x0
  pushl $102
c01021a9:	6a 66                	push   $0x66
  jmp __alltraps
c01021ab:	e9 e1 06 00 00       	jmp    c0102891 <__alltraps>

c01021b0 <vector103>:
.globl vector103
vector103:
  pushl $0
c01021b0:	6a 00                	push   $0x0
  pushl $103
c01021b2:	6a 67                	push   $0x67
  jmp __alltraps
c01021b4:	e9 d8 06 00 00       	jmp    c0102891 <__alltraps>

c01021b9 <vector104>:
.globl vector104
vector104:
  pushl $0
c01021b9:	6a 00                	push   $0x0
  pushl $104
c01021bb:	6a 68                	push   $0x68
  jmp __alltraps
c01021bd:	e9 cf 06 00 00       	jmp    c0102891 <__alltraps>

c01021c2 <vector105>:
.globl vector105
vector105:
  pushl $0
c01021c2:	6a 00                	push   $0x0
  pushl $105
c01021c4:	6a 69                	push   $0x69
  jmp __alltraps
c01021c6:	e9 c6 06 00 00       	jmp    c0102891 <__alltraps>

c01021cb <vector106>:
.globl vector106
vector106:
  pushl $0
c01021cb:	6a 00                	push   $0x0
  pushl $106
c01021cd:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021cf:	e9 bd 06 00 00       	jmp    c0102891 <__alltraps>

c01021d4 <vector107>:
.globl vector107
vector107:
  pushl $0
c01021d4:	6a 00                	push   $0x0
  pushl $107
c01021d6:	6a 6b                	push   $0x6b
  jmp __alltraps
c01021d8:	e9 b4 06 00 00       	jmp    c0102891 <__alltraps>

c01021dd <vector108>:
.globl vector108
vector108:
  pushl $0
c01021dd:	6a 00                	push   $0x0
  pushl $108
c01021df:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021e1:	e9 ab 06 00 00       	jmp    c0102891 <__alltraps>

c01021e6 <vector109>:
.globl vector109
vector109:
  pushl $0
c01021e6:	6a 00                	push   $0x0
  pushl $109
c01021e8:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021ea:	e9 a2 06 00 00       	jmp    c0102891 <__alltraps>

c01021ef <vector110>:
.globl vector110
vector110:
  pushl $0
c01021ef:	6a 00                	push   $0x0
  pushl $110
c01021f1:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021f3:	e9 99 06 00 00       	jmp    c0102891 <__alltraps>

c01021f8 <vector111>:
.globl vector111
vector111:
  pushl $0
c01021f8:	6a 00                	push   $0x0
  pushl $111
c01021fa:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021fc:	e9 90 06 00 00       	jmp    c0102891 <__alltraps>

c0102201 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102201:	6a 00                	push   $0x0
  pushl $112
c0102203:	6a 70                	push   $0x70
  jmp __alltraps
c0102205:	e9 87 06 00 00       	jmp    c0102891 <__alltraps>

c010220a <vector113>:
.globl vector113
vector113:
  pushl $0
c010220a:	6a 00                	push   $0x0
  pushl $113
c010220c:	6a 71                	push   $0x71
  jmp __alltraps
c010220e:	e9 7e 06 00 00       	jmp    c0102891 <__alltraps>

c0102213 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102213:	6a 00                	push   $0x0
  pushl $114
c0102215:	6a 72                	push   $0x72
  jmp __alltraps
c0102217:	e9 75 06 00 00       	jmp    c0102891 <__alltraps>

c010221c <vector115>:
.globl vector115
vector115:
  pushl $0
c010221c:	6a 00                	push   $0x0
  pushl $115
c010221e:	6a 73                	push   $0x73
  jmp __alltraps
c0102220:	e9 6c 06 00 00       	jmp    c0102891 <__alltraps>

c0102225 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102225:	6a 00                	push   $0x0
  pushl $116
c0102227:	6a 74                	push   $0x74
  jmp __alltraps
c0102229:	e9 63 06 00 00       	jmp    c0102891 <__alltraps>

c010222e <vector117>:
.globl vector117
vector117:
  pushl $0
c010222e:	6a 00                	push   $0x0
  pushl $117
c0102230:	6a 75                	push   $0x75
  jmp __alltraps
c0102232:	e9 5a 06 00 00       	jmp    c0102891 <__alltraps>

c0102237 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102237:	6a 00                	push   $0x0
  pushl $118
c0102239:	6a 76                	push   $0x76
  jmp __alltraps
c010223b:	e9 51 06 00 00       	jmp    c0102891 <__alltraps>

c0102240 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102240:	6a 00                	push   $0x0
  pushl $119
c0102242:	6a 77                	push   $0x77
  jmp __alltraps
c0102244:	e9 48 06 00 00       	jmp    c0102891 <__alltraps>

c0102249 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102249:	6a 00                	push   $0x0
  pushl $120
c010224b:	6a 78                	push   $0x78
  jmp __alltraps
c010224d:	e9 3f 06 00 00       	jmp    c0102891 <__alltraps>

c0102252 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102252:	6a 00                	push   $0x0
  pushl $121
c0102254:	6a 79                	push   $0x79
  jmp __alltraps
c0102256:	e9 36 06 00 00       	jmp    c0102891 <__alltraps>

c010225b <vector122>:
.globl vector122
vector122:
  pushl $0
c010225b:	6a 00                	push   $0x0
  pushl $122
c010225d:	6a 7a                	push   $0x7a
  jmp __alltraps
c010225f:	e9 2d 06 00 00       	jmp    c0102891 <__alltraps>

c0102264 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102264:	6a 00                	push   $0x0
  pushl $123
c0102266:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102268:	e9 24 06 00 00       	jmp    c0102891 <__alltraps>

c010226d <vector124>:
.globl vector124
vector124:
  pushl $0
c010226d:	6a 00                	push   $0x0
  pushl $124
c010226f:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102271:	e9 1b 06 00 00       	jmp    c0102891 <__alltraps>

c0102276 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102276:	6a 00                	push   $0x0
  pushl $125
c0102278:	6a 7d                	push   $0x7d
  jmp __alltraps
c010227a:	e9 12 06 00 00       	jmp    c0102891 <__alltraps>

c010227f <vector126>:
.globl vector126
vector126:
  pushl $0
c010227f:	6a 00                	push   $0x0
  pushl $126
c0102281:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102283:	e9 09 06 00 00       	jmp    c0102891 <__alltraps>

c0102288 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102288:	6a 00                	push   $0x0
  pushl $127
c010228a:	6a 7f                	push   $0x7f
  jmp __alltraps
c010228c:	e9 00 06 00 00       	jmp    c0102891 <__alltraps>

c0102291 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102291:	6a 00                	push   $0x0
  pushl $128
c0102293:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102298:	e9 f4 05 00 00       	jmp    c0102891 <__alltraps>

c010229d <vector129>:
.globl vector129
vector129:
  pushl $0
c010229d:	6a 00                	push   $0x0
  pushl $129
c010229f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01022a4:	e9 e8 05 00 00       	jmp    c0102891 <__alltraps>

c01022a9 <vector130>:
.globl vector130
vector130:
  pushl $0
c01022a9:	6a 00                	push   $0x0
  pushl $130
c01022ab:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01022b0:	e9 dc 05 00 00       	jmp    c0102891 <__alltraps>

c01022b5 <vector131>:
.globl vector131
vector131:
  pushl $0
c01022b5:	6a 00                	push   $0x0
  pushl $131
c01022b7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01022bc:	e9 d0 05 00 00       	jmp    c0102891 <__alltraps>

c01022c1 <vector132>:
.globl vector132
vector132:
  pushl $0
c01022c1:	6a 00                	push   $0x0
  pushl $132
c01022c3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022c8:	e9 c4 05 00 00       	jmp    c0102891 <__alltraps>

c01022cd <vector133>:
.globl vector133
vector133:
  pushl $0
c01022cd:	6a 00                	push   $0x0
  pushl $133
c01022cf:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022d4:	e9 b8 05 00 00       	jmp    c0102891 <__alltraps>

c01022d9 <vector134>:
.globl vector134
vector134:
  pushl $0
c01022d9:	6a 00                	push   $0x0
  pushl $134
c01022db:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022e0:	e9 ac 05 00 00       	jmp    c0102891 <__alltraps>

c01022e5 <vector135>:
.globl vector135
vector135:
  pushl $0
c01022e5:	6a 00                	push   $0x0
  pushl $135
c01022e7:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022ec:	e9 a0 05 00 00       	jmp    c0102891 <__alltraps>

c01022f1 <vector136>:
.globl vector136
vector136:
  pushl $0
c01022f1:	6a 00                	push   $0x0
  pushl $136
c01022f3:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022f8:	e9 94 05 00 00       	jmp    c0102891 <__alltraps>

c01022fd <vector137>:
.globl vector137
vector137:
  pushl $0
c01022fd:	6a 00                	push   $0x0
  pushl $137
c01022ff:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102304:	e9 88 05 00 00       	jmp    c0102891 <__alltraps>

c0102309 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102309:	6a 00                	push   $0x0
  pushl $138
c010230b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102310:	e9 7c 05 00 00       	jmp    c0102891 <__alltraps>

c0102315 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102315:	6a 00                	push   $0x0
  pushl $139
c0102317:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010231c:	e9 70 05 00 00       	jmp    c0102891 <__alltraps>

c0102321 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102321:	6a 00                	push   $0x0
  pushl $140
c0102323:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102328:	e9 64 05 00 00       	jmp    c0102891 <__alltraps>

c010232d <vector141>:
.globl vector141
vector141:
  pushl $0
c010232d:	6a 00                	push   $0x0
  pushl $141
c010232f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102334:	e9 58 05 00 00       	jmp    c0102891 <__alltraps>

c0102339 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102339:	6a 00                	push   $0x0
  pushl $142
c010233b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102340:	e9 4c 05 00 00       	jmp    c0102891 <__alltraps>

c0102345 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102345:	6a 00                	push   $0x0
  pushl $143
c0102347:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010234c:	e9 40 05 00 00       	jmp    c0102891 <__alltraps>

c0102351 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102351:	6a 00                	push   $0x0
  pushl $144
c0102353:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102358:	e9 34 05 00 00       	jmp    c0102891 <__alltraps>

c010235d <vector145>:
.globl vector145
vector145:
  pushl $0
c010235d:	6a 00                	push   $0x0
  pushl $145
c010235f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102364:	e9 28 05 00 00       	jmp    c0102891 <__alltraps>

c0102369 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102369:	6a 00                	push   $0x0
  pushl $146
c010236b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102370:	e9 1c 05 00 00       	jmp    c0102891 <__alltraps>

c0102375 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102375:	6a 00                	push   $0x0
  pushl $147
c0102377:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010237c:	e9 10 05 00 00       	jmp    c0102891 <__alltraps>

c0102381 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102381:	6a 00                	push   $0x0
  pushl $148
c0102383:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102388:	e9 04 05 00 00       	jmp    c0102891 <__alltraps>

c010238d <vector149>:
.globl vector149
vector149:
  pushl $0
c010238d:	6a 00                	push   $0x0
  pushl $149
c010238f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102394:	e9 f8 04 00 00       	jmp    c0102891 <__alltraps>

c0102399 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102399:	6a 00                	push   $0x0
  pushl $150
c010239b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01023a0:	e9 ec 04 00 00       	jmp    c0102891 <__alltraps>

c01023a5 <vector151>:
.globl vector151
vector151:
  pushl $0
c01023a5:	6a 00                	push   $0x0
  pushl $151
c01023a7:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01023ac:	e9 e0 04 00 00       	jmp    c0102891 <__alltraps>

c01023b1 <vector152>:
.globl vector152
vector152:
  pushl $0
c01023b1:	6a 00                	push   $0x0
  pushl $152
c01023b3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01023b8:	e9 d4 04 00 00       	jmp    c0102891 <__alltraps>

c01023bd <vector153>:
.globl vector153
vector153:
  pushl $0
c01023bd:	6a 00                	push   $0x0
  pushl $153
c01023bf:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023c4:	e9 c8 04 00 00       	jmp    c0102891 <__alltraps>

c01023c9 <vector154>:
.globl vector154
vector154:
  pushl $0
c01023c9:	6a 00                	push   $0x0
  pushl $154
c01023cb:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023d0:	e9 bc 04 00 00       	jmp    c0102891 <__alltraps>

c01023d5 <vector155>:
.globl vector155
vector155:
  pushl $0
c01023d5:	6a 00                	push   $0x0
  pushl $155
c01023d7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023dc:	e9 b0 04 00 00       	jmp    c0102891 <__alltraps>

c01023e1 <vector156>:
.globl vector156
vector156:
  pushl $0
c01023e1:	6a 00                	push   $0x0
  pushl $156
c01023e3:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023e8:	e9 a4 04 00 00       	jmp    c0102891 <__alltraps>

c01023ed <vector157>:
.globl vector157
vector157:
  pushl $0
c01023ed:	6a 00                	push   $0x0
  pushl $157
c01023ef:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023f4:	e9 98 04 00 00       	jmp    c0102891 <__alltraps>

c01023f9 <vector158>:
.globl vector158
vector158:
  pushl $0
c01023f9:	6a 00                	push   $0x0
  pushl $158
c01023fb:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102400:	e9 8c 04 00 00       	jmp    c0102891 <__alltraps>

c0102405 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102405:	6a 00                	push   $0x0
  pushl $159
c0102407:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010240c:	e9 80 04 00 00       	jmp    c0102891 <__alltraps>

c0102411 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102411:	6a 00                	push   $0x0
  pushl $160
c0102413:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102418:	e9 74 04 00 00       	jmp    c0102891 <__alltraps>

c010241d <vector161>:
.globl vector161
vector161:
  pushl $0
c010241d:	6a 00                	push   $0x0
  pushl $161
c010241f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102424:	e9 68 04 00 00       	jmp    c0102891 <__alltraps>

c0102429 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102429:	6a 00                	push   $0x0
  pushl $162
c010242b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102430:	e9 5c 04 00 00       	jmp    c0102891 <__alltraps>

c0102435 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102435:	6a 00                	push   $0x0
  pushl $163
c0102437:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010243c:	e9 50 04 00 00       	jmp    c0102891 <__alltraps>

c0102441 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102441:	6a 00                	push   $0x0
  pushl $164
c0102443:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102448:	e9 44 04 00 00       	jmp    c0102891 <__alltraps>

c010244d <vector165>:
.globl vector165
vector165:
  pushl $0
c010244d:	6a 00                	push   $0x0
  pushl $165
c010244f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102454:	e9 38 04 00 00       	jmp    c0102891 <__alltraps>

c0102459 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102459:	6a 00                	push   $0x0
  pushl $166
c010245b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102460:	e9 2c 04 00 00       	jmp    c0102891 <__alltraps>

c0102465 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102465:	6a 00                	push   $0x0
  pushl $167
c0102467:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010246c:	e9 20 04 00 00       	jmp    c0102891 <__alltraps>

c0102471 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102471:	6a 00                	push   $0x0
  pushl $168
c0102473:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102478:	e9 14 04 00 00       	jmp    c0102891 <__alltraps>

c010247d <vector169>:
.globl vector169
vector169:
  pushl $0
c010247d:	6a 00                	push   $0x0
  pushl $169
c010247f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102484:	e9 08 04 00 00       	jmp    c0102891 <__alltraps>

c0102489 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102489:	6a 00                	push   $0x0
  pushl $170
c010248b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102490:	e9 fc 03 00 00       	jmp    c0102891 <__alltraps>

c0102495 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102495:	6a 00                	push   $0x0
  pushl $171
c0102497:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010249c:	e9 f0 03 00 00       	jmp    c0102891 <__alltraps>

c01024a1 <vector172>:
.globl vector172
vector172:
  pushl $0
c01024a1:	6a 00                	push   $0x0
  pushl $172
c01024a3:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01024a8:	e9 e4 03 00 00       	jmp    c0102891 <__alltraps>

c01024ad <vector173>:
.globl vector173
vector173:
  pushl $0
c01024ad:	6a 00                	push   $0x0
  pushl $173
c01024af:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01024b4:	e9 d8 03 00 00       	jmp    c0102891 <__alltraps>

c01024b9 <vector174>:
.globl vector174
vector174:
  pushl $0
c01024b9:	6a 00                	push   $0x0
  pushl $174
c01024bb:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01024c0:	e9 cc 03 00 00       	jmp    c0102891 <__alltraps>

c01024c5 <vector175>:
.globl vector175
vector175:
  pushl $0
c01024c5:	6a 00                	push   $0x0
  pushl $175
c01024c7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024cc:	e9 c0 03 00 00       	jmp    c0102891 <__alltraps>

c01024d1 <vector176>:
.globl vector176
vector176:
  pushl $0
c01024d1:	6a 00                	push   $0x0
  pushl $176
c01024d3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01024d8:	e9 b4 03 00 00       	jmp    c0102891 <__alltraps>

c01024dd <vector177>:
.globl vector177
vector177:
  pushl $0
c01024dd:	6a 00                	push   $0x0
  pushl $177
c01024df:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024e4:	e9 a8 03 00 00       	jmp    c0102891 <__alltraps>

c01024e9 <vector178>:
.globl vector178
vector178:
  pushl $0
c01024e9:	6a 00                	push   $0x0
  pushl $178
c01024eb:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024f0:	e9 9c 03 00 00       	jmp    c0102891 <__alltraps>

c01024f5 <vector179>:
.globl vector179
vector179:
  pushl $0
c01024f5:	6a 00                	push   $0x0
  pushl $179
c01024f7:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024fc:	e9 90 03 00 00       	jmp    c0102891 <__alltraps>

c0102501 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102501:	6a 00                	push   $0x0
  pushl $180
c0102503:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102508:	e9 84 03 00 00       	jmp    c0102891 <__alltraps>

c010250d <vector181>:
.globl vector181
vector181:
  pushl $0
c010250d:	6a 00                	push   $0x0
  pushl $181
c010250f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102514:	e9 78 03 00 00       	jmp    c0102891 <__alltraps>

c0102519 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102519:	6a 00                	push   $0x0
  pushl $182
c010251b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102520:	e9 6c 03 00 00       	jmp    c0102891 <__alltraps>

c0102525 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102525:	6a 00                	push   $0x0
  pushl $183
c0102527:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010252c:	e9 60 03 00 00       	jmp    c0102891 <__alltraps>

c0102531 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102531:	6a 00                	push   $0x0
  pushl $184
c0102533:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102538:	e9 54 03 00 00       	jmp    c0102891 <__alltraps>

c010253d <vector185>:
.globl vector185
vector185:
  pushl $0
c010253d:	6a 00                	push   $0x0
  pushl $185
c010253f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102544:	e9 48 03 00 00       	jmp    c0102891 <__alltraps>

c0102549 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102549:	6a 00                	push   $0x0
  pushl $186
c010254b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102550:	e9 3c 03 00 00       	jmp    c0102891 <__alltraps>

c0102555 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102555:	6a 00                	push   $0x0
  pushl $187
c0102557:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010255c:	e9 30 03 00 00       	jmp    c0102891 <__alltraps>

c0102561 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102561:	6a 00                	push   $0x0
  pushl $188
c0102563:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102568:	e9 24 03 00 00       	jmp    c0102891 <__alltraps>

c010256d <vector189>:
.globl vector189
vector189:
  pushl $0
c010256d:	6a 00                	push   $0x0
  pushl $189
c010256f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102574:	e9 18 03 00 00       	jmp    c0102891 <__alltraps>

c0102579 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102579:	6a 00                	push   $0x0
  pushl $190
c010257b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102580:	e9 0c 03 00 00       	jmp    c0102891 <__alltraps>

c0102585 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102585:	6a 00                	push   $0x0
  pushl $191
c0102587:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010258c:	e9 00 03 00 00       	jmp    c0102891 <__alltraps>

c0102591 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102591:	6a 00                	push   $0x0
  pushl $192
c0102593:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102598:	e9 f4 02 00 00       	jmp    c0102891 <__alltraps>

c010259d <vector193>:
.globl vector193
vector193:
  pushl $0
c010259d:	6a 00                	push   $0x0
  pushl $193
c010259f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01025a4:	e9 e8 02 00 00       	jmp    c0102891 <__alltraps>

c01025a9 <vector194>:
.globl vector194
vector194:
  pushl $0
c01025a9:	6a 00                	push   $0x0
  pushl $194
c01025ab:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01025b0:	e9 dc 02 00 00       	jmp    c0102891 <__alltraps>

c01025b5 <vector195>:
.globl vector195
vector195:
  pushl $0
c01025b5:	6a 00                	push   $0x0
  pushl $195
c01025b7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01025bc:	e9 d0 02 00 00       	jmp    c0102891 <__alltraps>

c01025c1 <vector196>:
.globl vector196
vector196:
  pushl $0
c01025c1:	6a 00                	push   $0x0
  pushl $196
c01025c3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025c8:	e9 c4 02 00 00       	jmp    c0102891 <__alltraps>

c01025cd <vector197>:
.globl vector197
vector197:
  pushl $0
c01025cd:	6a 00                	push   $0x0
  pushl $197
c01025cf:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025d4:	e9 b8 02 00 00       	jmp    c0102891 <__alltraps>

c01025d9 <vector198>:
.globl vector198
vector198:
  pushl $0
c01025d9:	6a 00                	push   $0x0
  pushl $198
c01025db:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025e0:	e9 ac 02 00 00       	jmp    c0102891 <__alltraps>

c01025e5 <vector199>:
.globl vector199
vector199:
  pushl $0
c01025e5:	6a 00                	push   $0x0
  pushl $199
c01025e7:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025ec:	e9 a0 02 00 00       	jmp    c0102891 <__alltraps>

c01025f1 <vector200>:
.globl vector200
vector200:
  pushl $0
c01025f1:	6a 00                	push   $0x0
  pushl $200
c01025f3:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025f8:	e9 94 02 00 00       	jmp    c0102891 <__alltraps>

c01025fd <vector201>:
.globl vector201
vector201:
  pushl $0
c01025fd:	6a 00                	push   $0x0
  pushl $201
c01025ff:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102604:	e9 88 02 00 00       	jmp    c0102891 <__alltraps>

c0102609 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102609:	6a 00                	push   $0x0
  pushl $202
c010260b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102610:	e9 7c 02 00 00       	jmp    c0102891 <__alltraps>

c0102615 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102615:	6a 00                	push   $0x0
  pushl $203
c0102617:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010261c:	e9 70 02 00 00       	jmp    c0102891 <__alltraps>

c0102621 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102621:	6a 00                	push   $0x0
  pushl $204
c0102623:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102628:	e9 64 02 00 00       	jmp    c0102891 <__alltraps>

c010262d <vector205>:
.globl vector205
vector205:
  pushl $0
c010262d:	6a 00                	push   $0x0
  pushl $205
c010262f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102634:	e9 58 02 00 00       	jmp    c0102891 <__alltraps>

c0102639 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102639:	6a 00                	push   $0x0
  pushl $206
c010263b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102640:	e9 4c 02 00 00       	jmp    c0102891 <__alltraps>

c0102645 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102645:	6a 00                	push   $0x0
  pushl $207
c0102647:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010264c:	e9 40 02 00 00       	jmp    c0102891 <__alltraps>

c0102651 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102651:	6a 00                	push   $0x0
  pushl $208
c0102653:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102658:	e9 34 02 00 00       	jmp    c0102891 <__alltraps>

c010265d <vector209>:
.globl vector209
vector209:
  pushl $0
c010265d:	6a 00                	push   $0x0
  pushl $209
c010265f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102664:	e9 28 02 00 00       	jmp    c0102891 <__alltraps>

c0102669 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102669:	6a 00                	push   $0x0
  pushl $210
c010266b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102670:	e9 1c 02 00 00       	jmp    c0102891 <__alltraps>

c0102675 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102675:	6a 00                	push   $0x0
  pushl $211
c0102677:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010267c:	e9 10 02 00 00       	jmp    c0102891 <__alltraps>

c0102681 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102681:	6a 00                	push   $0x0
  pushl $212
c0102683:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102688:	e9 04 02 00 00       	jmp    c0102891 <__alltraps>

c010268d <vector213>:
.globl vector213
vector213:
  pushl $0
c010268d:	6a 00                	push   $0x0
  pushl $213
c010268f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102694:	e9 f8 01 00 00       	jmp    c0102891 <__alltraps>

c0102699 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102699:	6a 00                	push   $0x0
  pushl $214
c010269b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01026a0:	e9 ec 01 00 00       	jmp    c0102891 <__alltraps>

c01026a5 <vector215>:
.globl vector215
vector215:
  pushl $0
c01026a5:	6a 00                	push   $0x0
  pushl $215
c01026a7:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01026ac:	e9 e0 01 00 00       	jmp    c0102891 <__alltraps>

c01026b1 <vector216>:
.globl vector216
vector216:
  pushl $0
c01026b1:	6a 00                	push   $0x0
  pushl $216
c01026b3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01026b8:	e9 d4 01 00 00       	jmp    c0102891 <__alltraps>

c01026bd <vector217>:
.globl vector217
vector217:
  pushl $0
c01026bd:	6a 00                	push   $0x0
  pushl $217
c01026bf:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026c4:	e9 c8 01 00 00       	jmp    c0102891 <__alltraps>

c01026c9 <vector218>:
.globl vector218
vector218:
  pushl $0
c01026c9:	6a 00                	push   $0x0
  pushl $218
c01026cb:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026d0:	e9 bc 01 00 00       	jmp    c0102891 <__alltraps>

c01026d5 <vector219>:
.globl vector219
vector219:
  pushl $0
c01026d5:	6a 00                	push   $0x0
  pushl $219
c01026d7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026dc:	e9 b0 01 00 00       	jmp    c0102891 <__alltraps>

c01026e1 <vector220>:
.globl vector220
vector220:
  pushl $0
c01026e1:	6a 00                	push   $0x0
  pushl $220
c01026e3:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026e8:	e9 a4 01 00 00       	jmp    c0102891 <__alltraps>

c01026ed <vector221>:
.globl vector221
vector221:
  pushl $0
c01026ed:	6a 00                	push   $0x0
  pushl $221
c01026ef:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026f4:	e9 98 01 00 00       	jmp    c0102891 <__alltraps>

c01026f9 <vector222>:
.globl vector222
vector222:
  pushl $0
c01026f9:	6a 00                	push   $0x0
  pushl $222
c01026fb:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102700:	e9 8c 01 00 00       	jmp    c0102891 <__alltraps>

c0102705 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102705:	6a 00                	push   $0x0
  pushl $223
c0102707:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010270c:	e9 80 01 00 00       	jmp    c0102891 <__alltraps>

c0102711 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102711:	6a 00                	push   $0x0
  pushl $224
c0102713:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102718:	e9 74 01 00 00       	jmp    c0102891 <__alltraps>

c010271d <vector225>:
.globl vector225
vector225:
  pushl $0
c010271d:	6a 00                	push   $0x0
  pushl $225
c010271f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102724:	e9 68 01 00 00       	jmp    c0102891 <__alltraps>

c0102729 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102729:	6a 00                	push   $0x0
  pushl $226
c010272b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102730:	e9 5c 01 00 00       	jmp    c0102891 <__alltraps>

c0102735 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102735:	6a 00                	push   $0x0
  pushl $227
c0102737:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010273c:	e9 50 01 00 00       	jmp    c0102891 <__alltraps>

c0102741 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102741:	6a 00                	push   $0x0
  pushl $228
c0102743:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102748:	e9 44 01 00 00       	jmp    c0102891 <__alltraps>

c010274d <vector229>:
.globl vector229
vector229:
  pushl $0
c010274d:	6a 00                	push   $0x0
  pushl $229
c010274f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102754:	e9 38 01 00 00       	jmp    c0102891 <__alltraps>

c0102759 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102759:	6a 00                	push   $0x0
  pushl $230
c010275b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102760:	e9 2c 01 00 00       	jmp    c0102891 <__alltraps>

c0102765 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102765:	6a 00                	push   $0x0
  pushl $231
c0102767:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010276c:	e9 20 01 00 00       	jmp    c0102891 <__alltraps>

c0102771 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102771:	6a 00                	push   $0x0
  pushl $232
c0102773:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102778:	e9 14 01 00 00       	jmp    c0102891 <__alltraps>

c010277d <vector233>:
.globl vector233
vector233:
  pushl $0
c010277d:	6a 00                	push   $0x0
  pushl $233
c010277f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102784:	e9 08 01 00 00       	jmp    c0102891 <__alltraps>

c0102789 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102789:	6a 00                	push   $0x0
  pushl $234
c010278b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102790:	e9 fc 00 00 00       	jmp    c0102891 <__alltraps>

c0102795 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102795:	6a 00                	push   $0x0
  pushl $235
c0102797:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010279c:	e9 f0 00 00 00       	jmp    c0102891 <__alltraps>

c01027a1 <vector236>:
.globl vector236
vector236:
  pushl $0
c01027a1:	6a 00                	push   $0x0
  pushl $236
c01027a3:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01027a8:	e9 e4 00 00 00       	jmp    c0102891 <__alltraps>

c01027ad <vector237>:
.globl vector237
vector237:
  pushl $0
c01027ad:	6a 00                	push   $0x0
  pushl $237
c01027af:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01027b4:	e9 d8 00 00 00       	jmp    c0102891 <__alltraps>

c01027b9 <vector238>:
.globl vector238
vector238:
  pushl $0
c01027b9:	6a 00                	push   $0x0
  pushl $238
c01027bb:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01027c0:	e9 cc 00 00 00       	jmp    c0102891 <__alltraps>

c01027c5 <vector239>:
.globl vector239
vector239:
  pushl $0
c01027c5:	6a 00                	push   $0x0
  pushl $239
c01027c7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027cc:	e9 c0 00 00 00       	jmp    c0102891 <__alltraps>

c01027d1 <vector240>:
.globl vector240
vector240:
  pushl $0
c01027d1:	6a 00                	push   $0x0
  pushl $240
c01027d3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01027d8:	e9 b4 00 00 00       	jmp    c0102891 <__alltraps>

c01027dd <vector241>:
.globl vector241
vector241:
  pushl $0
c01027dd:	6a 00                	push   $0x0
  pushl $241
c01027df:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027e4:	e9 a8 00 00 00       	jmp    c0102891 <__alltraps>

c01027e9 <vector242>:
.globl vector242
vector242:
  pushl $0
c01027e9:	6a 00                	push   $0x0
  pushl $242
c01027eb:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027f0:	e9 9c 00 00 00       	jmp    c0102891 <__alltraps>

c01027f5 <vector243>:
.globl vector243
vector243:
  pushl $0
c01027f5:	6a 00                	push   $0x0
  pushl $243
c01027f7:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027fc:	e9 90 00 00 00       	jmp    c0102891 <__alltraps>

c0102801 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102801:	6a 00                	push   $0x0
  pushl $244
c0102803:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102808:	e9 84 00 00 00       	jmp    c0102891 <__alltraps>

c010280d <vector245>:
.globl vector245
vector245:
  pushl $0
c010280d:	6a 00                	push   $0x0
  pushl $245
c010280f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102814:	e9 78 00 00 00       	jmp    c0102891 <__alltraps>

c0102819 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102819:	6a 00                	push   $0x0
  pushl $246
c010281b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102820:	e9 6c 00 00 00       	jmp    c0102891 <__alltraps>

c0102825 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102825:	6a 00                	push   $0x0
  pushl $247
c0102827:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010282c:	e9 60 00 00 00       	jmp    c0102891 <__alltraps>

c0102831 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102831:	6a 00                	push   $0x0
  pushl $248
c0102833:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102838:	e9 54 00 00 00       	jmp    c0102891 <__alltraps>

c010283d <vector249>:
.globl vector249
vector249:
  pushl $0
c010283d:	6a 00                	push   $0x0
  pushl $249
c010283f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102844:	e9 48 00 00 00       	jmp    c0102891 <__alltraps>

c0102849 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102849:	6a 00                	push   $0x0
  pushl $250
c010284b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102850:	e9 3c 00 00 00       	jmp    c0102891 <__alltraps>

c0102855 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102855:	6a 00                	push   $0x0
  pushl $251
c0102857:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010285c:	e9 30 00 00 00       	jmp    c0102891 <__alltraps>

c0102861 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102861:	6a 00                	push   $0x0
  pushl $252
c0102863:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102868:	e9 24 00 00 00       	jmp    c0102891 <__alltraps>

c010286d <vector253>:
.globl vector253
vector253:
  pushl $0
c010286d:	6a 00                	push   $0x0
  pushl $253
c010286f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102874:	e9 18 00 00 00       	jmp    c0102891 <__alltraps>

c0102879 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102879:	6a 00                	push   $0x0
  pushl $254
c010287b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102880:	e9 0c 00 00 00       	jmp    c0102891 <__alltraps>

c0102885 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102885:	6a 00                	push   $0x0
  pushl $255
c0102887:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010288c:	e9 00 00 00 00       	jmp    c0102891 <__alltraps>

c0102891 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102891:	1e                   	push   %ds
    pushl %es
c0102892:	06                   	push   %es
    pushl %fs
c0102893:	0f a0                	push   %fs
    pushl %gs
c0102895:	0f a8                	push   %gs
    pushal
c0102897:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102898:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010289d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010289f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01028a1:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01028a2:	e8 64 f5 ff ff       	call   c0101e0b <trap>

    # pop the pushed stack pointer
    popl %esp
c01028a7:	5c                   	pop    %esp

c01028a8 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01028a8:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01028a9:	0f a9                	pop    %gs
    popl %fs
c01028ab:	0f a1                	pop    %fs
    popl %es
c01028ad:	07                   	pop    %es
    popl %ds
c01028ae:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01028af:	83 c4 08             	add    $0x8,%esp
    iret
c01028b2:	cf                   	iret   

c01028b3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01028b3:	55                   	push   %ebp
c01028b4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01028b9:	8b 15 18 bf 11 c0    	mov    0xc011bf18,%edx
c01028bf:	29 d0                	sub    %edx,%eax
c01028c1:	c1 f8 02             	sar    $0x2,%eax
c01028c4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028ca:	5d                   	pop    %ebp
c01028cb:	c3                   	ret    

c01028cc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028cc:	55                   	push   %ebp
c01028cd:	89 e5                	mov    %esp,%ebp
c01028cf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01028d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028d5:	89 04 24             	mov    %eax,(%esp)
c01028d8:	e8 d6 ff ff ff       	call   c01028b3 <page2ppn>
c01028dd:	c1 e0 0c             	shl    $0xc,%eax
}
c01028e0:	c9                   	leave  
c01028e1:	c3                   	ret    

c01028e2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01028e2:	55                   	push   %ebp
c01028e3:	89 e5                	mov    %esp,%ebp
c01028e5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01028e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01028eb:	c1 e8 0c             	shr    $0xc,%eax
c01028ee:	89 c2                	mov    %eax,%edx
c01028f0:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c01028f5:	39 c2                	cmp    %eax,%edx
c01028f7:	72 1c                	jb     c0102915 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01028f9:	c7 44 24 08 30 67 10 	movl   $0xc0106730,0x8(%esp)
c0102900:	c0 
c0102901:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102908:	00 
c0102909:	c7 04 24 4f 67 10 c0 	movl   $0xc010674f,(%esp)
c0102910:	e8 d4 da ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c0102915:	8b 0d 18 bf 11 c0    	mov    0xc011bf18,%ecx
c010291b:	8b 45 08             	mov    0x8(%ebp),%eax
c010291e:	c1 e8 0c             	shr    $0xc,%eax
c0102921:	89 c2                	mov    %eax,%edx
c0102923:	89 d0                	mov    %edx,%eax
c0102925:	c1 e0 02             	shl    $0x2,%eax
c0102928:	01 d0                	add    %edx,%eax
c010292a:	c1 e0 02             	shl    $0x2,%eax
c010292d:	01 c8                	add    %ecx,%eax
}
c010292f:	c9                   	leave  
c0102930:	c3                   	ret    

c0102931 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102931:	55                   	push   %ebp
c0102932:	89 e5                	mov    %esp,%ebp
c0102934:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102937:	8b 45 08             	mov    0x8(%ebp),%eax
c010293a:	89 04 24             	mov    %eax,(%esp)
c010293d:	e8 8a ff ff ff       	call   c01028cc <page2pa>
c0102942:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102945:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102948:	c1 e8 0c             	shr    $0xc,%eax
c010294b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010294e:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102953:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102956:	72 23                	jb     c010297b <page2kva+0x4a>
c0102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010295b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010295f:	c7 44 24 08 60 67 10 	movl   $0xc0106760,0x8(%esp)
c0102966:	c0 
c0102967:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c010296e:	00 
c010296f:	c7 04 24 4f 67 10 c0 	movl   $0xc010674f,(%esp)
c0102976:	e8 6e da ff ff       	call   c01003e9 <__panic>
c010297b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010297e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102983:	c9                   	leave  
c0102984:	c3                   	ret    

c0102985 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102985:	55                   	push   %ebp
c0102986:	89 e5                	mov    %esp,%ebp
c0102988:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010298b:	8b 45 08             	mov    0x8(%ebp),%eax
c010298e:	83 e0 01             	and    $0x1,%eax
c0102991:	85 c0                	test   %eax,%eax
c0102993:	75 1c                	jne    c01029b1 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102995:	c7 44 24 08 84 67 10 	movl   $0xc0106784,0x8(%esp)
c010299c:	c0 
c010299d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01029a4:	00 
c01029a5:	c7 04 24 4f 67 10 c0 	movl   $0xc010674f,(%esp)
c01029ac:	e8 38 da ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01029b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029b9:	89 04 24             	mov    %eax,(%esp)
c01029bc:	e8 21 ff ff ff       	call   c01028e2 <pa2page>
}
c01029c1:	c9                   	leave  
c01029c2:	c3                   	ret    

c01029c3 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01029c3:	55                   	push   %ebp
c01029c4:	89 e5                	mov    %esp,%ebp
c01029c6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01029c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01029cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029d1:	89 04 24             	mov    %eax,(%esp)
c01029d4:	e8 09 ff ff ff       	call   c01028e2 <pa2page>
}
c01029d9:	c9                   	leave  
c01029da:	c3                   	ret    

c01029db <page_ref>:

static inline int
page_ref(struct Page *page) {
c01029db:	55                   	push   %ebp
c01029dc:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01029de:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e1:	8b 00                	mov    (%eax),%eax
}
c01029e3:	5d                   	pop    %ebp
c01029e4:	c3                   	ret    

c01029e5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01029e5:	55                   	push   %ebp
c01029e6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01029e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01029eb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029ee:	89 10                	mov    %edx,(%eax)
}
c01029f0:	90                   	nop
c01029f1:	5d                   	pop    %ebp
c01029f2:	c3                   	ret    

c01029f3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01029f3:	55                   	push   %ebp
c01029f4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01029f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f9:	8b 00                	mov    (%eax),%eax
c01029fb:	8d 50 01             	lea    0x1(%eax),%edx
c01029fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a01:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a06:	8b 00                	mov    (%eax),%eax
}
c0102a08:	5d                   	pop    %ebp
c0102a09:	c3                   	ret    

c0102a0a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102a0a:	55                   	push   %ebp
c0102a0b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a10:	8b 00                	mov    (%eax),%eax
c0102a12:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a18:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a1d:	8b 00                	mov    (%eax),%eax
}
c0102a1f:	5d                   	pop    %ebp
c0102a20:	c3                   	ret    

c0102a21 <__intr_save>:
__intr_save(void) {
c0102a21:	55                   	push   %ebp
c0102a22:	89 e5                	mov    %esp,%ebp
c0102a24:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102a27:	9c                   	pushf  
c0102a28:	58                   	pop    %eax
c0102a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a2f:	25 00 02 00 00       	and    $0x200,%eax
c0102a34:	85 c0                	test   %eax,%eax
c0102a36:	74 0c                	je     c0102a44 <__intr_save+0x23>
        intr_disable();
c0102a38:	e8 50 ee ff ff       	call   c010188d <intr_disable>
        return 1;
c0102a3d:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a42:	eb 05                	jmp    c0102a49 <__intr_save+0x28>
    return 0;
c0102a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a49:	c9                   	leave  
c0102a4a:	c3                   	ret    

c0102a4b <__intr_restore>:
__intr_restore(bool flag) {
c0102a4b:	55                   	push   %ebp
c0102a4c:	89 e5                	mov    %esp,%ebp
c0102a4e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a55:	74 05                	je     c0102a5c <__intr_restore+0x11>
        intr_enable();
c0102a57:	e8 2a ee ff ff       	call   c0101886 <intr_enable>
}
c0102a5c:	90                   	nop
c0102a5d:	c9                   	leave  
c0102a5e:	c3                   	ret    

c0102a5f <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102a5f:	55                   	push   %ebp
c0102a60:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a65:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a68:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a6d:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a6f:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a74:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a76:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a7b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a7d:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a82:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a84:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a89:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a8b:	ea 92 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a92
}
c0102a92:	90                   	nop
c0102a93:	5d                   	pop    %ebp
c0102a94:	c3                   	ret    

c0102a95 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a95:	55                   	push   %ebp
c0102a96:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a9b:	a3 a4 be 11 c0       	mov    %eax,0xc011bea4
}
c0102aa0:	90                   	nop
c0102aa1:	5d                   	pop    %ebp
c0102aa2:	c3                   	ret    

c0102aa3 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102aa3:	55                   	push   %ebp
c0102aa4:	89 e5                	mov    %esp,%ebp
c0102aa6:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102aa9:	b8 00 80 11 c0       	mov    $0xc0118000,%eax
c0102aae:	89 04 24             	mov    %eax,(%esp)
c0102ab1:	e8 df ff ff ff       	call   c0102a95 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102ab6:	66 c7 05 a8 be 11 c0 	movw   $0x10,0xc011bea8
c0102abd:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102abf:	66 c7 05 28 8a 11 c0 	movw   $0x68,0xc0118a28
c0102ac6:	68 00 
c0102ac8:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102acd:	0f b7 c0             	movzwl %ax,%eax
c0102ad0:	66 a3 2a 8a 11 c0    	mov    %ax,0xc0118a2a
c0102ad6:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102adb:	c1 e8 10             	shr    $0x10,%eax
c0102ade:	a2 2c 8a 11 c0       	mov    %al,0xc0118a2c
c0102ae3:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102aea:	24 f0                	and    $0xf0,%al
c0102aec:	0c 09                	or     $0x9,%al
c0102aee:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102af3:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102afa:	24 ef                	and    $0xef,%al
c0102afc:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102b01:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102b08:	24 9f                	and    $0x9f,%al
c0102b0a:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102b0f:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102b16:	0c 80                	or     $0x80,%al
c0102b18:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102b1d:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102b24:	24 f0                	and    $0xf0,%al
c0102b26:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102b2b:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102b32:	24 ef                	and    $0xef,%al
c0102b34:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102b39:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102b40:	24 df                	and    $0xdf,%al
c0102b42:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102b47:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102b4e:	0c 40                	or     $0x40,%al
c0102b50:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102b55:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102b5c:	24 7f                	and    $0x7f,%al
c0102b5e:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102b63:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102b68:	c1 e8 18             	shr    $0x18,%eax
c0102b6b:	a2 2f 8a 11 c0       	mov    %al,0xc0118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b70:	c7 04 24 30 8a 11 c0 	movl   $0xc0118a30,(%esp)
c0102b77:	e8 e3 fe ff ff       	call   c0102a5f <lgdt>
c0102b7c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b82:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b86:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b89:	90                   	nop
c0102b8a:	c9                   	leave  
c0102b8b:	c3                   	ret    

c0102b8c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b8c:	55                   	push   %ebp
c0102b8d:	89 e5                	mov    %esp,%ebp
c0102b8f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102b92:	c7 05 10 bf 11 c0 58 	movl   $0xc0107158,0xc011bf10
c0102b99:	71 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b9c:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102ba1:	8b 00                	mov    (%eax),%eax
c0102ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102ba7:	c7 04 24 b0 67 10 c0 	movl   $0xc01067b0,(%esp)
c0102bae:	e8 df d6 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102bb3:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102bb8:	8b 40 04             	mov    0x4(%eax),%eax
c0102bbb:	ff d0                	call   *%eax
}
c0102bbd:	90                   	nop
c0102bbe:	c9                   	leave  
c0102bbf:	c3                   	ret    

c0102bc0 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102bc0:	55                   	push   %ebp
c0102bc1:	89 e5                	mov    %esp,%ebp
c0102bc3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102bc6:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102bcb:	8b 40 08             	mov    0x8(%eax),%eax
c0102bce:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bd1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bd5:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bd8:	89 14 24             	mov    %edx,(%esp)
c0102bdb:	ff d0                	call   *%eax
}
c0102bdd:	90                   	nop
c0102bde:	c9                   	leave  
c0102bdf:	c3                   	ret    

c0102be0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102be0:	55                   	push   %ebp
c0102be1:	89 e5                	mov    %esp,%ebp
c0102be3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102be6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bed:	e8 2f fe ff ff       	call   c0102a21 <__intr_save>
c0102bf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102bf5:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102bfa:	8b 40 0c             	mov    0xc(%eax),%eax
c0102bfd:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c00:	89 14 24             	mov    %edx,(%esp)
c0102c03:	ff d0                	call   *%eax
c0102c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102c0b:	89 04 24             	mov    %eax,(%esp)
c0102c0e:	e8 38 fe ff ff       	call   c0102a4b <__intr_restore>
    return page;
c0102c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c16:	c9                   	leave  
c0102c17:	c3                   	ret    

c0102c18 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102c18:	55                   	push   %ebp
c0102c19:	89 e5                	mov    %esp,%ebp
c0102c1b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c1e:	e8 fe fd ff ff       	call   c0102a21 <__intr_save>
c0102c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102c26:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102c2b:	8b 40 10             	mov    0x10(%eax),%eax
c0102c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c31:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102c35:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c38:	89 14 24             	mov    %edx,(%esp)
c0102c3b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c40:	89 04 24             	mov    %eax,(%esp)
c0102c43:	e8 03 fe ff ff       	call   c0102a4b <__intr_restore>
}
c0102c48:	90                   	nop
c0102c49:	c9                   	leave  
c0102c4a:	c3                   	ret    

c0102c4b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102c4b:	55                   	push   %ebp
c0102c4c:	89 e5                	mov    %esp,%ebp
c0102c4e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c51:	e8 cb fd ff ff       	call   c0102a21 <__intr_save>
c0102c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102c59:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102c5e:	8b 40 14             	mov    0x14(%eax),%eax
c0102c61:	ff d0                	call   *%eax
c0102c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c69:	89 04 24             	mov    %eax,(%esp)
c0102c6c:	e8 da fd ff ff       	call   c0102a4b <__intr_restore>
    return ret;
c0102c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c74:	c9                   	leave  
c0102c75:	c3                   	ret    

c0102c76 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c76:	55                   	push   %ebp
c0102c77:	89 e5                	mov    %esp,%ebp
c0102c79:	57                   	push   %edi
c0102c7a:	56                   	push   %esi
c0102c7b:	53                   	push   %ebx
c0102c7c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c82:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c89:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c97:	c7 04 24 c7 67 10 c0 	movl   $0xc01067c7,(%esp)
c0102c9e:	e8 ef d5 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102ca3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102caa:	e9 22 01 00 00       	jmp    c0102dd1 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102caf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cb5:	89 d0                	mov    %edx,%eax
c0102cb7:	c1 e0 02             	shl    $0x2,%eax
c0102cba:	01 d0                	add    %edx,%eax
c0102cbc:	c1 e0 02             	shl    $0x2,%eax
c0102cbf:	01 c8                	add    %ecx,%eax
c0102cc1:	8b 50 08             	mov    0x8(%eax),%edx
c0102cc4:	8b 40 04             	mov    0x4(%eax),%eax
c0102cc7:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102cca:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102ccd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cd3:	89 d0                	mov    %edx,%eax
c0102cd5:	c1 e0 02             	shl    $0x2,%eax
c0102cd8:	01 d0                	add    %edx,%eax
c0102cda:	c1 e0 02             	shl    $0x2,%eax
c0102cdd:	01 c8                	add    %ecx,%eax
c0102cdf:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ce2:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ce5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ce8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102ceb:	01 c8                	add    %ecx,%eax
c0102ced:	11 da                	adc    %ebx,%edx
c0102cef:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102cf2:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102cf5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cfb:	89 d0                	mov    %edx,%eax
c0102cfd:	c1 e0 02             	shl    $0x2,%eax
c0102d00:	01 d0                	add    %edx,%eax
c0102d02:	c1 e0 02             	shl    $0x2,%eax
c0102d05:	01 c8                	add    %ecx,%eax
c0102d07:	83 c0 14             	add    $0x14,%eax
c0102d0a:	8b 00                	mov    (%eax),%eax
c0102d0c:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102d0f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102d12:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102d15:	83 c0 ff             	add    $0xffffffff,%eax
c0102d18:	83 d2 ff             	adc    $0xffffffff,%edx
c0102d1b:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102d21:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102d27:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d2d:	89 d0                	mov    %edx,%eax
c0102d2f:	c1 e0 02             	shl    $0x2,%eax
c0102d32:	01 d0                	add    %edx,%eax
c0102d34:	c1 e0 02             	shl    $0x2,%eax
c0102d37:	01 c8                	add    %ecx,%eax
c0102d39:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102d3c:	8b 58 10             	mov    0x10(%eax),%ebx
c0102d3f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102d42:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102d46:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102d4c:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102d52:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102d56:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102d5a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102d5d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102d60:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d64:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102d68:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102d6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d70:	c7 04 24 d4 67 10 c0 	movl   $0xc01067d4,(%esp)
c0102d77:	e8 16 d5 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d7c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d82:	89 d0                	mov    %edx,%eax
c0102d84:	c1 e0 02             	shl    $0x2,%eax
c0102d87:	01 d0                	add    %edx,%eax
c0102d89:	c1 e0 02             	shl    $0x2,%eax
c0102d8c:	01 c8                	add    %ecx,%eax
c0102d8e:	83 c0 14             	add    $0x14,%eax
c0102d91:	8b 00                	mov    (%eax),%eax
c0102d93:	83 f8 01             	cmp    $0x1,%eax
c0102d96:	75 36                	jne    c0102dce <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d9e:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102da1:	77 2b                	ja     c0102dce <page_init+0x158>
c0102da3:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102da6:	72 05                	jb     c0102dad <page_init+0x137>
c0102da8:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102dab:	73 21                	jae    c0102dce <page_init+0x158>
c0102dad:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102db1:	77 1b                	ja     c0102dce <page_init+0x158>
c0102db3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102db7:	72 09                	jb     c0102dc2 <page_init+0x14c>
c0102db9:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102dc0:	77 0c                	ja     c0102dce <page_init+0x158>
                maxpa = end;
c0102dc2:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102dc5:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102dc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102dcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102dce:	ff 45 dc             	incl   -0x24(%ebp)
c0102dd1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102dd4:	8b 00                	mov    (%eax),%eax
c0102dd6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102dd9:	0f 8c d0 fe ff ff    	jl     c0102caf <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102ddf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102de3:	72 1d                	jb     c0102e02 <page_init+0x18c>
c0102de5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102de9:	77 09                	ja     c0102df4 <page_init+0x17e>
c0102deb:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102df2:	76 0e                	jbe    c0102e02 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102df4:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102dfb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102e08:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102e0c:	c1 ea 0c             	shr    $0xc,%edx
c0102e0f:	89 c1                	mov    %eax,%ecx
c0102e11:	89 d3                	mov    %edx,%ebx
c0102e13:	89 c8                	mov    %ecx,%eax
c0102e15:	a3 80 be 11 c0       	mov    %eax,0xc011be80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102e1a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102e21:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
c0102e26:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e29:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102e2c:	01 d0                	add    %edx,%eax
c0102e2e:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102e31:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102e34:	ba 00 00 00 00       	mov    $0x0,%edx
c0102e39:	f7 75 c0             	divl   -0x40(%ebp)
c0102e3c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102e3f:	29 d0                	sub    %edx,%eax
c0102e41:	a3 18 bf 11 c0       	mov    %eax,0xc011bf18

    for (i = 0; i < npage; i ++) {
c0102e46:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e4d:	eb 2e                	jmp    c0102e7d <page_init+0x207>
        SetPageReserved(pages + i);
c0102e4f:	8b 0d 18 bf 11 c0    	mov    0xc011bf18,%ecx
c0102e55:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e58:	89 d0                	mov    %edx,%eax
c0102e5a:	c1 e0 02             	shl    $0x2,%eax
c0102e5d:	01 d0                	add    %edx,%eax
c0102e5f:	c1 e0 02             	shl    $0x2,%eax
c0102e62:	01 c8                	add    %ecx,%eax
c0102e64:	83 c0 04             	add    $0x4,%eax
c0102e67:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102e6e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e71:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102e74:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102e77:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102e7a:	ff 45 dc             	incl   -0x24(%ebp)
c0102e7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e80:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102e85:	39 c2                	cmp    %eax,%edx
c0102e87:	72 c6                	jb     c0102e4f <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e89:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0102e8f:	89 d0                	mov    %edx,%eax
c0102e91:	c1 e0 02             	shl    $0x2,%eax
c0102e94:	01 d0                	add    %edx,%eax
c0102e96:	c1 e0 02             	shl    $0x2,%eax
c0102e99:	89 c2                	mov    %eax,%edx
c0102e9b:	a1 18 bf 11 c0       	mov    0xc011bf18,%eax
c0102ea0:	01 d0                	add    %edx,%eax
c0102ea2:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102ea5:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0102eac:	77 23                	ja     c0102ed1 <page_init+0x25b>
c0102eae:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102eb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102eb5:	c7 44 24 08 04 68 10 	movl   $0xc0106804,0x8(%esp)
c0102ebc:	c0 
c0102ebd:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0102ec4:	00 
c0102ec5:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0102ecc:	e8 18 d5 ff ff       	call   c01003e9 <__panic>
c0102ed1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ed4:	05 00 00 00 40       	add    $0x40000000,%eax
c0102ed9:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102edc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ee3:	e9 69 01 00 00       	jmp    c0103051 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102ee8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102eeb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102eee:	89 d0                	mov    %edx,%eax
c0102ef0:	c1 e0 02             	shl    $0x2,%eax
c0102ef3:	01 d0                	add    %edx,%eax
c0102ef5:	c1 e0 02             	shl    $0x2,%eax
c0102ef8:	01 c8                	add    %ecx,%eax
c0102efa:	8b 50 08             	mov    0x8(%eax),%edx
c0102efd:	8b 40 04             	mov    0x4(%eax),%eax
c0102f00:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f03:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102f06:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f09:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f0c:	89 d0                	mov    %edx,%eax
c0102f0e:	c1 e0 02             	shl    $0x2,%eax
c0102f11:	01 d0                	add    %edx,%eax
c0102f13:	c1 e0 02             	shl    $0x2,%eax
c0102f16:	01 c8                	add    %ecx,%eax
c0102f18:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102f1b:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f21:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f24:	01 c8                	add    %ecx,%eax
c0102f26:	11 da                	adc    %ebx,%edx
c0102f28:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102f2b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102f2e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f31:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f34:	89 d0                	mov    %edx,%eax
c0102f36:	c1 e0 02             	shl    $0x2,%eax
c0102f39:	01 d0                	add    %edx,%eax
c0102f3b:	c1 e0 02             	shl    $0x2,%eax
c0102f3e:	01 c8                	add    %ecx,%eax
c0102f40:	83 c0 14             	add    $0x14,%eax
c0102f43:	8b 00                	mov    (%eax),%eax
c0102f45:	83 f8 01             	cmp    $0x1,%eax
c0102f48:	0f 85 00 01 00 00    	jne    c010304e <page_init+0x3d8>
            if (begin < freemem) {
c0102f4e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f51:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f56:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102f59:	77 17                	ja     c0102f72 <page_init+0x2fc>
c0102f5b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102f5e:	72 05                	jb     c0102f65 <page_init+0x2ef>
c0102f60:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0102f63:	73 0d                	jae    c0102f72 <page_init+0x2fc>
                begin = freemem;
c0102f65:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f68:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f6b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f72:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f76:	72 1d                	jb     c0102f95 <page_init+0x31f>
c0102f78:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f7c:	77 09                	ja     c0102f87 <page_init+0x311>
c0102f7e:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f85:	76 0e                	jbe    c0102f95 <page_init+0x31f>
                end = KMEMSIZE;
c0102f87:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f8e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f95:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f9b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f9e:	0f 87 aa 00 00 00    	ja     c010304e <page_init+0x3d8>
c0102fa4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fa7:	72 09                	jb     c0102fb2 <page_init+0x33c>
c0102fa9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102fac:	0f 83 9c 00 00 00    	jae    c010304e <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c0102fb2:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0102fb9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102fbc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102fbf:	01 d0                	add    %edx,%eax
c0102fc1:	48                   	dec    %eax
c0102fc2:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102fc5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102fc8:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fcd:	f7 75 b0             	divl   -0x50(%ebp)
c0102fd0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102fd3:	29 d0                	sub    %edx,%eax
c0102fd5:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fda:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fdd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102fe0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fe3:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102fe6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102fe9:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fee:	89 c3                	mov    %eax,%ebx
c0102ff0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102ff6:	89 de                	mov    %ebx,%esi
c0102ff8:	89 d0                	mov    %edx,%eax
c0102ffa:	83 e0 00             	and    $0x0,%eax
c0102ffd:	89 c7                	mov    %eax,%edi
c0102fff:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103002:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103005:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103008:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010300b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010300e:	77 3e                	ja     c010304e <page_init+0x3d8>
c0103010:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103013:	72 05                	jb     c010301a <page_init+0x3a4>
c0103015:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103018:	73 34                	jae    c010304e <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010301a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010301d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103020:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103023:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103026:	89 c1                	mov    %eax,%ecx
c0103028:	89 d3                	mov    %edx,%ebx
c010302a:	89 c8                	mov    %ecx,%eax
c010302c:	89 da                	mov    %ebx,%edx
c010302e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103032:	c1 ea 0c             	shr    $0xc,%edx
c0103035:	89 c3                	mov    %eax,%ebx
c0103037:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010303a:	89 04 24             	mov    %eax,(%esp)
c010303d:	e8 a0 f8 ff ff       	call   c01028e2 <pa2page>
c0103042:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103046:	89 04 24             	mov    %eax,(%esp)
c0103049:	e8 72 fb ff ff       	call   c0102bc0 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010304e:	ff 45 dc             	incl   -0x24(%ebp)
c0103051:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103054:	8b 00                	mov    (%eax),%eax
c0103056:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103059:	0f 8c 89 fe ff ff    	jl     c0102ee8 <page_init+0x272>
                }
            }
        }
    }
}
c010305f:	90                   	nop
c0103060:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103066:	5b                   	pop    %ebx
c0103067:	5e                   	pop    %esi
c0103068:	5f                   	pop    %edi
c0103069:	5d                   	pop    %ebp
c010306a:	c3                   	ret    

c010306b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010306b:	55                   	push   %ebp
c010306c:	89 e5                	mov    %esp,%ebp
c010306e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103071:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103074:	33 45 14             	xor    0x14(%ebp),%eax
c0103077:	25 ff 0f 00 00       	and    $0xfff,%eax
c010307c:	85 c0                	test   %eax,%eax
c010307e:	74 24                	je     c01030a4 <boot_map_segment+0x39>
c0103080:	c7 44 24 0c 36 68 10 	movl   $0xc0106836,0xc(%esp)
c0103087:	c0 
c0103088:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c010308f:	c0 
c0103090:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0103097:	00 
c0103098:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c010309f:	e8 45 d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01030a4:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01030ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030ae:	25 ff 0f 00 00       	and    $0xfff,%eax
c01030b3:	89 c2                	mov    %eax,%edx
c01030b5:	8b 45 10             	mov    0x10(%ebp),%eax
c01030b8:	01 c2                	add    %eax,%edx
c01030ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030bd:	01 d0                	add    %edx,%eax
c01030bf:	48                   	dec    %eax
c01030c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01030c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030c6:	ba 00 00 00 00       	mov    $0x0,%edx
c01030cb:	f7 75 f0             	divl   -0x10(%ebp)
c01030ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030d1:	29 d0                	sub    %edx,%eax
c01030d3:	c1 e8 0c             	shr    $0xc,%eax
c01030d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01030d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01030df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01030e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030e7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01030ea:	8b 45 14             	mov    0x14(%ebp),%eax
c01030ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01030f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01030f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030f8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030fb:	eb 68                	jmp    c0103165 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01030fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103104:	00 
c0103105:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103108:	89 44 24 04          	mov    %eax,0x4(%esp)
c010310c:	8b 45 08             	mov    0x8(%ebp),%eax
c010310f:	89 04 24             	mov    %eax,(%esp)
c0103112:	e8 81 01 00 00       	call   c0103298 <get_pte>
c0103117:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010311a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010311e:	75 24                	jne    c0103144 <boot_map_segment+0xd9>
c0103120:	c7 44 24 0c 62 68 10 	movl   $0xc0106862,0xc(%esp)
c0103127:	c0 
c0103128:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c010312f:	c0 
c0103130:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103137:	00 
c0103138:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c010313f:	e8 a5 d2 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103144:	8b 45 14             	mov    0x14(%ebp),%eax
c0103147:	0b 45 18             	or     0x18(%ebp),%eax
c010314a:	83 c8 01             	or     $0x1,%eax
c010314d:	89 c2                	mov    %eax,%edx
c010314f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103152:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103154:	ff 4d f4             	decl   -0xc(%ebp)
c0103157:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010315e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103165:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103169:	75 92                	jne    c01030fd <boot_map_segment+0x92>
    }
}
c010316b:	90                   	nop
c010316c:	c9                   	leave  
c010316d:	c3                   	ret    

c010316e <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010316e:	55                   	push   %ebp
c010316f:	89 e5                	mov    %esp,%ebp
c0103171:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010317b:	e8 60 fa ff ff       	call   c0102be0 <alloc_pages>
c0103180:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103183:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103187:	75 1c                	jne    c01031a5 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103189:	c7 44 24 08 6f 68 10 	movl   $0xc010686f,0x8(%esp)
c0103190:	c0 
c0103191:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103198:	00 
c0103199:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01031a0:	e8 44 d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c01031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031a8:	89 04 24             	mov    %eax,(%esp)
c01031ab:	e8 81 f7 ff ff       	call   c0102931 <page2kva>
}
c01031b0:	c9                   	leave  
c01031b1:	c3                   	ret    

c01031b2 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01031b2:	55                   	push   %ebp
c01031b3:	89 e5                	mov    %esp,%ebp
c01031b5:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01031b8:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01031bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01031c0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01031c7:	77 23                	ja     c01031ec <pmm_init+0x3a>
c01031c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031d0:	c7 44 24 08 04 68 10 	movl   $0xc0106804,0x8(%esp)
c01031d7:	c0 
c01031d8:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01031df:	00 
c01031e0:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01031e7:	e8 fd d1 ff ff       	call   c01003e9 <__panic>
c01031ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031ef:	05 00 00 00 40       	add    $0x40000000,%eax
c01031f4:	a3 14 bf 11 c0       	mov    %eax,0xc011bf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01031f9:	e8 8e f9 ff ff       	call   c0102b8c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01031fe:	e8 73 fa ff ff       	call   c0102c76 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103203:	e8 de 03 00 00       	call   c01035e6 <check_alloc_page>

    check_pgdir();
c0103208:	e8 f8 03 00 00       	call   c0103605 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010320d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103212:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103215:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010321c:	77 23                	ja     c0103241 <pmm_init+0x8f>
c010321e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103221:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103225:	c7 44 24 08 04 68 10 	movl   $0xc0106804,0x8(%esp)
c010322c:	c0 
c010322d:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0103234:	00 
c0103235:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c010323c:	e8 a8 d1 ff ff       	call   c01003e9 <__panic>
c0103241:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103244:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010324a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010324f:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103254:	83 ca 03             	or     $0x3,%edx
c0103257:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103259:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010325e:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103265:	00 
c0103266:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010326d:	00 
c010326e:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103275:	38 
c0103276:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010327d:	c0 
c010327e:	89 04 24             	mov    %eax,(%esp)
c0103281:	e8 e5 fd ff ff       	call   c010306b <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103286:	e8 18 f8 ff ff       	call   c0102aa3 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010328b:	e8 11 0a 00 00       	call   c0103ca1 <check_boot_pgdir>

    print_pgdir();
c0103290:	e8 8a 0e 00 00       	call   c010411f <print_pgdir>

}
c0103295:	90                   	nop
c0103296:	c9                   	leave  
c0103297:	c3                   	ret    

c0103298 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103298:	55                   	push   %ebp
c0103299:	89 e5                	mov    %esp,%ebp
c010329b:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry
c010329e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032a1:	c1 e8 16             	shr    $0x16,%eax
c01032a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01032ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ae:	01 d0                	add    %edx,%eax
c01032b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {              // (2) check if entry is not present
c01032b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032b6:	8b 00                	mov    (%eax),%eax
c01032b8:	83 e0 01             	and    $0x1,%eax
c01032bb:	85 c0                	test   %eax,%eax
c01032bd:	0f 85 af 00 00 00    	jne    c0103372 <get_pte+0xda>
        struct Page* page;
        // (3) check if creating is needed, then alloc page for page table
        // CAUTION: this page is used for page table, not for common data page
        if(!create || (page = alloc_page()) == NULL) {
c01032c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01032c7:	74 15                	je     c01032de <get_pte+0x46>
c01032c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032d0:	e8 0b f9 ff ff       	call   c0102be0 <alloc_pages>
c01032d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01032d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01032dc:	75 0a                	jne    c01032e8 <get_pte+0x50>
            return NULL;
c01032de:	b8 00 00 00 00       	mov    $0x0,%eax
c01032e3:	e9 e7 00 00 00       	jmp    c01033cf <get_pte+0x137>
        }
        set_page_ref(page, 1); // (4) set page reference
c01032e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032ef:	00 
c01032f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032f3:	89 04 24             	mov    %eax,(%esp)
c01032f6:	e8 ea f6 ff ff       	call   c01029e5 <set_page_ref>
        uintptr_t pa = page2pa(page); // (5) get linear address of page
c01032fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032fe:	89 04 24             	mov    %eax,(%esp)
c0103301:	e8 c6 f5 ff ff       	call   c01028cc <page2pa>
c0103306:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); // (6) clear page content using memset
c0103309:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010330c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010330f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103312:	c1 e8 0c             	shr    $0xc,%eax
c0103315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103318:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c010331d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103320:	72 23                	jb     c0103345 <get_pte+0xad>
c0103322:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103329:	c7 44 24 08 60 67 10 	movl   $0xc0106760,0x8(%esp)
c0103330:	c0 
c0103331:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
c0103338:	00 
c0103339:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103340:	e8 a4 d0 ff ff       	call   c01003e9 <__panic>
c0103345:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103348:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010334d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103354:	00 
c0103355:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010335c:	00 
c010335d:	89 04 24             	mov    %eax,(%esp)
c0103360:	e8 a2 24 00 00       	call   c0105807 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;  // (7) set page directory entry's permission
c0103365:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103368:	83 c8 07             	or     $0x7,%eax
c010336b:	89 c2                	mov    %eax,%edx
c010336d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103370:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry
c0103372:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103375:	8b 00                	mov    (%eax),%eax
c0103377:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010337c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010337f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103382:	c1 e8 0c             	shr    $0xc,%eax
c0103385:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103388:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c010338d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103390:	72 23                	jb     c01033b5 <get_pte+0x11d>
c0103392:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103395:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103399:	c7 44 24 08 60 67 10 	movl   $0xc0106760,0x8(%esp)
c01033a0:	c0 
c01033a1:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c01033a8:	00 
c01033a9:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01033b0:	e8 34 d0 ff ff       	call   c01003e9 <__panic>
c01033b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033b8:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01033bd:	89 c2                	mov    %eax,%edx
c01033bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033c2:	c1 e8 0c             	shr    $0xc,%eax
c01033c5:	25 ff 03 00 00       	and    $0x3ff,%eax
c01033ca:	c1 e0 02             	shl    $0x2,%eax
c01033cd:	01 d0                	add    %edx,%eax
}
c01033cf:	c9                   	leave  
c01033d0:	c3                   	ret    

c01033d1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01033d1:	55                   	push   %ebp
c01033d2:	89 e5                	mov    %esp,%ebp
c01033d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01033d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01033de:	00 
c01033df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01033e9:	89 04 24             	mov    %eax,(%esp)
c01033ec:	e8 a7 fe ff ff       	call   c0103298 <get_pte>
c01033f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01033f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01033f8:	74 08                	je     c0103402 <get_page+0x31>
        *ptep_store = ptep;
c01033fa:	8b 45 10             	mov    0x10(%ebp),%eax
c01033fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103400:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103406:	74 1b                	je     c0103423 <get_page+0x52>
c0103408:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010340b:	8b 00                	mov    (%eax),%eax
c010340d:	83 e0 01             	and    $0x1,%eax
c0103410:	85 c0                	test   %eax,%eax
c0103412:	74 0f                	je     c0103423 <get_page+0x52>
        return pte2page(*ptep);
c0103414:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103417:	8b 00                	mov    (%eax),%eax
c0103419:	89 04 24             	mov    %eax,(%esp)
c010341c:	e8 64 f5 ff ff       	call   c0102985 <pte2page>
c0103421:	eb 05                	jmp    c0103428 <get_page+0x57>
    }
    return NULL;
c0103423:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103428:	c9                   	leave  
c0103429:	c3                   	ret    

c010342a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010342a:	55                   	push   %ebp
c010342b:	89 e5                	mov    %esp,%ebp
c010342d:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    if (*ptep & PTE_P) {                      //(1) check if this page table entry is present
c0103430:	8b 45 10             	mov    0x10(%ebp),%eax
c0103433:	8b 00                	mov    (%eax),%eax
c0103435:	83 e0 01             	and    $0x1,%eax
c0103438:	85 c0                	test   %eax,%eax
c010343a:	74 4d                	je     c0103489 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //(2) find corresponding page to pte
c010343c:	8b 45 10             	mov    0x10(%ebp),%eax
c010343f:	8b 00                	mov    (%eax),%eax
c0103441:	89 04 24             	mov    %eax,(%esp)
c0103444:	e8 3c f5 ff ff       	call   c0102985 <pte2page>
c0103449:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0)  //(3) decrease page reference
c010344c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010344f:	89 04 24             	mov    %eax,(%esp)
c0103452:	e8 b3 f5 ff ff       	call   c0102a0a <page_ref_dec>
c0103457:	85 c0                	test   %eax,%eax
c0103459:	75 13                	jne    c010346e <page_remove_pte+0x44>
            free_page(page);  //(4) and free this page when page reference reachs 0
c010345b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103462:	00 
c0103463:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103466:	89 04 24             	mov    %eax,(%esp)
c0103469:	e8 aa f7 ff ff       	call   c0102c18 <free_pages>
        *ptep = 0;  //(5) clear second page table entry
c010346e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103471:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);  //(6) flush tlb
c0103477:	8b 45 0c             	mov    0xc(%ebp),%eax
c010347a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010347e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103481:	89 04 24             	mov    %eax,(%esp)
c0103484:	e8 01 01 00 00       	call   c010358a <tlb_invalidate>
    }
}
c0103489:	90                   	nop
c010348a:	c9                   	leave  
c010348b:	c3                   	ret    

c010348c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010348c:	55                   	push   %ebp
c010348d:	89 e5                	mov    %esp,%ebp
c010348f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103492:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103499:	00 
c010349a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010349d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a4:	89 04 24             	mov    %eax,(%esp)
c01034a7:	e8 ec fd ff ff       	call   c0103298 <get_pte>
c01034ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01034af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034b3:	74 19                	je     c01034ce <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01034b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01034bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01034c6:	89 04 24             	mov    %eax,(%esp)
c01034c9:	e8 5c ff ff ff       	call   c010342a <page_remove_pte>
    }
}
c01034ce:	90                   	nop
c01034cf:	c9                   	leave  
c01034d0:	c3                   	ret    

c01034d1 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01034d1:	55                   	push   %ebp
c01034d2:	89 e5                	mov    %esp,%ebp
c01034d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01034d7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01034de:	00 
c01034df:	8b 45 10             	mov    0x10(%ebp),%eax
c01034e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01034e9:	89 04 24             	mov    %eax,(%esp)
c01034ec:	e8 a7 fd ff ff       	call   c0103298 <get_pte>
c01034f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01034f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034f8:	75 0a                	jne    c0103504 <page_insert+0x33>
        return -E_NO_MEM;
c01034fa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01034ff:	e9 84 00 00 00       	jmp    c0103588 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103504:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103507:	89 04 24             	mov    %eax,(%esp)
c010350a:	e8 e4 f4 ff ff       	call   c01029f3 <page_ref_inc>
    if (*ptep & PTE_P) {
c010350f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103512:	8b 00                	mov    (%eax),%eax
c0103514:	83 e0 01             	and    $0x1,%eax
c0103517:	85 c0                	test   %eax,%eax
c0103519:	74 3e                	je     c0103559 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010351b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010351e:	8b 00                	mov    (%eax),%eax
c0103520:	89 04 24             	mov    %eax,(%esp)
c0103523:	e8 5d f4 ff ff       	call   c0102985 <pte2page>
c0103528:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010352b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010352e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103531:	75 0d                	jne    c0103540 <page_insert+0x6f>
            page_ref_dec(page);
c0103533:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103536:	89 04 24             	mov    %eax,(%esp)
c0103539:	e8 cc f4 ff ff       	call   c0102a0a <page_ref_dec>
c010353e:	eb 19                	jmp    c0103559 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103540:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103543:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103547:	8b 45 10             	mov    0x10(%ebp),%eax
c010354a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010354e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103551:	89 04 24             	mov    %eax,(%esp)
c0103554:	e8 d1 fe ff ff       	call   c010342a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010355c:	89 04 24             	mov    %eax,(%esp)
c010355f:	e8 68 f3 ff ff       	call   c01028cc <page2pa>
c0103564:	0b 45 14             	or     0x14(%ebp),%eax
c0103567:	83 c8 01             	or     $0x1,%eax
c010356a:	89 c2                	mov    %eax,%edx
c010356c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010356f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103571:	8b 45 10             	mov    0x10(%ebp),%eax
c0103574:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103578:	8b 45 08             	mov    0x8(%ebp),%eax
c010357b:	89 04 24             	mov    %eax,(%esp)
c010357e:	e8 07 00 00 00       	call   c010358a <tlb_invalidate>
    return 0;
c0103583:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103588:	c9                   	leave  
c0103589:	c3                   	ret    

c010358a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010358a:	55                   	push   %ebp
c010358b:	89 e5                	mov    %esp,%ebp
c010358d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103590:	0f 20 d8             	mov    %cr3,%eax
c0103593:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103596:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103599:	8b 45 08             	mov    0x8(%ebp),%eax
c010359c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010359f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01035a6:	77 23                	ja     c01035cb <tlb_invalidate+0x41>
c01035a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01035af:	c7 44 24 08 04 68 10 	movl   $0xc0106804,0x8(%esp)
c01035b6:	c0 
c01035b7:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c01035be:	00 
c01035bf:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01035c6:	e8 1e ce ff ff       	call   c01003e9 <__panic>
c01035cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ce:	05 00 00 00 40       	add    $0x40000000,%eax
c01035d3:	39 d0                	cmp    %edx,%eax
c01035d5:	75 0c                	jne    c01035e3 <tlb_invalidate+0x59>
        invlpg((void *)la);
c01035d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035da:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01035dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035e0:	0f 01 38             	invlpg (%eax)
    }
}
c01035e3:	90                   	nop
c01035e4:	c9                   	leave  
c01035e5:	c3                   	ret    

c01035e6 <check_alloc_page>:

static void
check_alloc_page(void) {
c01035e6:	55                   	push   %ebp
c01035e7:	89 e5                	mov    %esp,%ebp
c01035e9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01035ec:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c01035f1:	8b 40 18             	mov    0x18(%eax),%eax
c01035f4:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01035f6:	c7 04 24 88 68 10 c0 	movl   $0xc0106888,(%esp)
c01035fd:	e8 90 cc ff ff       	call   c0100292 <cprintf>
}
c0103602:	90                   	nop
c0103603:	c9                   	leave  
c0103604:	c3                   	ret    

c0103605 <check_pgdir>:

static void
check_pgdir(void) {
c0103605:	55                   	push   %ebp
c0103606:	89 e5                	mov    %esp,%ebp
c0103608:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010360b:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103610:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103615:	76 24                	jbe    c010363b <check_pgdir+0x36>
c0103617:	c7 44 24 0c a7 68 10 	movl   $0xc01068a7,0xc(%esp)
c010361e:	c0 
c010361f:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103626:	c0 
c0103627:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c010362e:	00 
c010362f:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103636:	e8 ae cd ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010363b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103640:	85 c0                	test   %eax,%eax
c0103642:	74 0e                	je     c0103652 <check_pgdir+0x4d>
c0103644:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103649:	25 ff 0f 00 00       	and    $0xfff,%eax
c010364e:	85 c0                	test   %eax,%eax
c0103650:	74 24                	je     c0103676 <check_pgdir+0x71>
c0103652:	c7 44 24 0c c4 68 10 	movl   $0xc01068c4,0xc(%esp)
c0103659:	c0 
c010365a:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103661:	c0 
c0103662:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0103669:	00 
c010366a:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103671:	e8 73 cd ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103676:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010367b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103682:	00 
c0103683:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010368a:	00 
c010368b:	89 04 24             	mov    %eax,(%esp)
c010368e:	e8 3e fd ff ff       	call   c01033d1 <get_page>
c0103693:	85 c0                	test   %eax,%eax
c0103695:	74 24                	je     c01036bb <check_pgdir+0xb6>
c0103697:	c7 44 24 0c fc 68 10 	movl   $0xc01068fc,0xc(%esp)
c010369e:	c0 
c010369f:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c01036a6:	c0 
c01036a7:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c01036ae:	00 
c01036af:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01036b6:	e8 2e cd ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01036bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036c2:	e8 19 f5 ff ff       	call   c0102be0 <alloc_pages>
c01036c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01036ca:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01036cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01036d6:	00 
c01036d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036de:	00 
c01036df:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01036e6:	89 04 24             	mov    %eax,(%esp)
c01036e9:	e8 e3 fd ff ff       	call   c01034d1 <page_insert>
c01036ee:	85 c0                	test   %eax,%eax
c01036f0:	74 24                	je     c0103716 <check_pgdir+0x111>
c01036f2:	c7 44 24 0c 24 69 10 	movl   $0xc0106924,0xc(%esp)
c01036f9:	c0 
c01036fa:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103701:	c0 
c0103702:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0103709:	00 
c010370a:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103711:	e8 d3 cc ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103716:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010371b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103722:	00 
c0103723:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010372a:	00 
c010372b:	89 04 24             	mov    %eax,(%esp)
c010372e:	e8 65 fb ff ff       	call   c0103298 <get_pte>
c0103733:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103736:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010373a:	75 24                	jne    c0103760 <check_pgdir+0x15b>
c010373c:	c7 44 24 0c 50 69 10 	movl   $0xc0106950,0xc(%esp)
c0103743:	c0 
c0103744:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c010374b:	c0 
c010374c:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c0103753:	00 
c0103754:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c010375b:	e8 89 cc ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103760:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103763:	8b 00                	mov    (%eax),%eax
c0103765:	89 04 24             	mov    %eax,(%esp)
c0103768:	e8 18 f2 ff ff       	call   c0102985 <pte2page>
c010376d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103770:	74 24                	je     c0103796 <check_pgdir+0x191>
c0103772:	c7 44 24 0c 7d 69 10 	movl   $0xc010697d,0xc(%esp)
c0103779:	c0 
c010377a:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103781:	c0 
c0103782:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c0103789:	00 
c010378a:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103791:	e8 53 cc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c0103796:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103799:	89 04 24             	mov    %eax,(%esp)
c010379c:	e8 3a f2 ff ff       	call   c01029db <page_ref>
c01037a1:	83 f8 01             	cmp    $0x1,%eax
c01037a4:	74 24                	je     c01037ca <check_pgdir+0x1c5>
c01037a6:	c7 44 24 0c 93 69 10 	movl   $0xc0106993,0xc(%esp)
c01037ad:	c0 
c01037ae:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c01037b5:	c0 
c01037b6:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c01037bd:	00 
c01037be:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01037c5:	e8 1f cc ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01037ca:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01037cf:	8b 00                	mov    (%eax),%eax
c01037d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01037d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01037d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037dc:	c1 e8 0c             	shr    $0xc,%eax
c01037df:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01037e2:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c01037e7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01037ea:	72 23                	jb     c010380f <check_pgdir+0x20a>
c01037ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01037f3:	c7 44 24 08 60 67 10 	movl   $0xc0106760,0x8(%esp)
c01037fa:	c0 
c01037fb:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c0103802:	00 
c0103803:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c010380a:	e8 da cb ff ff       	call   c01003e9 <__panic>
c010380f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103812:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103817:	83 c0 04             	add    $0x4,%eax
c010381a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010381d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103822:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103829:	00 
c010382a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103831:	00 
c0103832:	89 04 24             	mov    %eax,(%esp)
c0103835:	e8 5e fa ff ff       	call   c0103298 <get_pte>
c010383a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010383d:	74 24                	je     c0103863 <check_pgdir+0x25e>
c010383f:	c7 44 24 0c a8 69 10 	movl   $0xc01069a8,0xc(%esp)
c0103846:	c0 
c0103847:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c010384e:	c0 
c010384f:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c0103856:	00 
c0103857:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c010385e:	e8 86 cb ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c0103863:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010386a:	e8 71 f3 ff ff       	call   c0102be0 <alloc_pages>
c010386f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103872:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103877:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010387e:	00 
c010387f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103886:	00 
c0103887:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010388a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010388e:	89 04 24             	mov    %eax,(%esp)
c0103891:	e8 3b fc ff ff       	call   c01034d1 <page_insert>
c0103896:	85 c0                	test   %eax,%eax
c0103898:	74 24                	je     c01038be <check_pgdir+0x2b9>
c010389a:	c7 44 24 0c d0 69 10 	movl   $0xc01069d0,0xc(%esp)
c01038a1:	c0 
c01038a2:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c01038a9:	c0 
c01038aa:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c01038b1:	00 
c01038b2:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01038b9:	e8 2b cb ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01038be:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01038c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038ca:	00 
c01038cb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01038d2:	00 
c01038d3:	89 04 24             	mov    %eax,(%esp)
c01038d6:	e8 bd f9 ff ff       	call   c0103298 <get_pte>
c01038db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01038e2:	75 24                	jne    c0103908 <check_pgdir+0x303>
c01038e4:	c7 44 24 0c 08 6a 10 	movl   $0xc0106a08,0xc(%esp)
c01038eb:	c0 
c01038ec:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c01038f3:	c0 
c01038f4:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c01038fb:	00 
c01038fc:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103903:	e8 e1 ca ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c0103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010390b:	8b 00                	mov    (%eax),%eax
c010390d:	83 e0 04             	and    $0x4,%eax
c0103910:	85 c0                	test   %eax,%eax
c0103912:	75 24                	jne    c0103938 <check_pgdir+0x333>
c0103914:	c7 44 24 0c 38 6a 10 	movl   $0xc0106a38,0xc(%esp)
c010391b:	c0 
c010391c:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103923:	c0 
c0103924:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c010392b:	00 
c010392c:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103933:	e8 b1 ca ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c0103938:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010393b:	8b 00                	mov    (%eax),%eax
c010393d:	83 e0 02             	and    $0x2,%eax
c0103940:	85 c0                	test   %eax,%eax
c0103942:	75 24                	jne    c0103968 <check_pgdir+0x363>
c0103944:	c7 44 24 0c 46 6a 10 	movl   $0xc0106a46,0xc(%esp)
c010394b:	c0 
c010394c:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103953:	c0 
c0103954:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c010395b:	00 
c010395c:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103963:	e8 81 ca ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103968:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010396d:	8b 00                	mov    (%eax),%eax
c010396f:	83 e0 04             	and    $0x4,%eax
c0103972:	85 c0                	test   %eax,%eax
c0103974:	75 24                	jne    c010399a <check_pgdir+0x395>
c0103976:	c7 44 24 0c 54 6a 10 	movl   $0xc0106a54,0xc(%esp)
c010397d:	c0 
c010397e:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103985:	c0 
c0103986:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c010398d:	00 
c010398e:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103995:	e8 4f ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c010399a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010399d:	89 04 24             	mov    %eax,(%esp)
c01039a0:	e8 36 f0 ff ff       	call   c01029db <page_ref>
c01039a5:	83 f8 01             	cmp    $0x1,%eax
c01039a8:	74 24                	je     c01039ce <check_pgdir+0x3c9>
c01039aa:	c7 44 24 0c 6a 6a 10 	movl   $0xc0106a6a,0xc(%esp)
c01039b1:	c0 
c01039b2:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c01039b9:	c0 
c01039ba:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01039c1:	00 
c01039c2:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c01039c9:	e8 1b ca ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01039ce:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01039d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01039da:	00 
c01039db:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01039e2:	00 
c01039e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01039e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01039ea:	89 04 24             	mov    %eax,(%esp)
c01039ed:	e8 df fa ff ff       	call   c01034d1 <page_insert>
c01039f2:	85 c0                	test   %eax,%eax
c01039f4:	74 24                	je     c0103a1a <check_pgdir+0x415>
c01039f6:	c7 44 24 0c 7c 6a 10 	movl   $0xc0106a7c,0xc(%esp)
c01039fd:	c0 
c01039fe:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103a05:	c0 
c0103a06:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0103a0d:	00 
c0103a0e:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103a15:	e8 cf c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c0103a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a1d:	89 04 24             	mov    %eax,(%esp)
c0103a20:	e8 b6 ef ff ff       	call   c01029db <page_ref>
c0103a25:	83 f8 02             	cmp    $0x2,%eax
c0103a28:	74 24                	je     c0103a4e <check_pgdir+0x449>
c0103a2a:	c7 44 24 0c a8 6a 10 	movl   $0xc0106aa8,0xc(%esp)
c0103a31:	c0 
c0103a32:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103a39:	c0 
c0103a3a:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0103a41:	00 
c0103a42:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103a49:	e8 9b c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a51:	89 04 24             	mov    %eax,(%esp)
c0103a54:	e8 82 ef ff ff       	call   c01029db <page_ref>
c0103a59:	85 c0                	test   %eax,%eax
c0103a5b:	74 24                	je     c0103a81 <check_pgdir+0x47c>
c0103a5d:	c7 44 24 0c ba 6a 10 	movl   $0xc0106aba,0xc(%esp)
c0103a64:	c0 
c0103a65:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103a6c:	c0 
c0103a6d:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103a74:	00 
c0103a75:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103a7c:	e8 68 c9 ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103a81:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103a86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a8d:	00 
c0103a8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a95:	00 
c0103a96:	89 04 24             	mov    %eax,(%esp)
c0103a99:	e8 fa f7 ff ff       	call   c0103298 <get_pte>
c0103a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103aa1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103aa5:	75 24                	jne    c0103acb <check_pgdir+0x4c6>
c0103aa7:	c7 44 24 0c 08 6a 10 	movl   $0xc0106a08,0xc(%esp)
c0103aae:	c0 
c0103aaf:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103ab6:	c0 
c0103ab7:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103abe:	00 
c0103abf:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103ac6:	e8 1e c9 ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ace:	8b 00                	mov    (%eax),%eax
c0103ad0:	89 04 24             	mov    %eax,(%esp)
c0103ad3:	e8 ad ee ff ff       	call   c0102985 <pte2page>
c0103ad8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103adb:	74 24                	je     c0103b01 <check_pgdir+0x4fc>
c0103add:	c7 44 24 0c 7d 69 10 	movl   $0xc010697d,0xc(%esp)
c0103ae4:	c0 
c0103ae5:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103aec:	c0 
c0103aed:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103af4:	00 
c0103af5:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103afc:	e8 e8 c8 ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b04:	8b 00                	mov    (%eax),%eax
c0103b06:	83 e0 04             	and    $0x4,%eax
c0103b09:	85 c0                	test   %eax,%eax
c0103b0b:	74 24                	je     c0103b31 <check_pgdir+0x52c>
c0103b0d:	c7 44 24 0c cc 6a 10 	movl   $0xc0106acc,0xc(%esp)
c0103b14:	c0 
c0103b15:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103b24:	00 
c0103b25:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103b2c:	e8 b8 c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103b31:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103b36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103b3d:	00 
c0103b3e:	89 04 24             	mov    %eax,(%esp)
c0103b41:	e8 46 f9 ff ff       	call   c010348c <page_remove>
    assert(page_ref(p1) == 1);
c0103b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b49:	89 04 24             	mov    %eax,(%esp)
c0103b4c:	e8 8a ee ff ff       	call   c01029db <page_ref>
c0103b51:	83 f8 01             	cmp    $0x1,%eax
c0103b54:	74 24                	je     c0103b7a <check_pgdir+0x575>
c0103b56:	c7 44 24 0c 93 69 10 	movl   $0xc0106993,0xc(%esp)
c0103b5d:	c0 
c0103b5e:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103b65:	c0 
c0103b66:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103b6d:	00 
c0103b6e:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103b75:	e8 6f c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103b7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b7d:	89 04 24             	mov    %eax,(%esp)
c0103b80:	e8 56 ee ff ff       	call   c01029db <page_ref>
c0103b85:	85 c0                	test   %eax,%eax
c0103b87:	74 24                	je     c0103bad <check_pgdir+0x5a8>
c0103b89:	c7 44 24 0c ba 6a 10 	movl   $0xc0106aba,0xc(%esp)
c0103b90:	c0 
c0103b91:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103b98:	c0 
c0103b99:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103ba0:	00 
c0103ba1:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103ba8:	e8 3c c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103bad:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103bb2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103bb9:	00 
c0103bba:	89 04 24             	mov    %eax,(%esp)
c0103bbd:	e8 ca f8 ff ff       	call   c010348c <page_remove>
    assert(page_ref(p1) == 0);
c0103bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bc5:	89 04 24             	mov    %eax,(%esp)
c0103bc8:	e8 0e ee ff ff       	call   c01029db <page_ref>
c0103bcd:	85 c0                	test   %eax,%eax
c0103bcf:	74 24                	je     c0103bf5 <check_pgdir+0x5f0>
c0103bd1:	c7 44 24 0c e1 6a 10 	movl   $0xc0106ae1,0xc(%esp)
c0103bd8:	c0 
c0103bd9:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103be0:	c0 
c0103be1:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103be8:	00 
c0103be9:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103bf0:	e8 f4 c7 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103bf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bf8:	89 04 24             	mov    %eax,(%esp)
c0103bfb:	e8 db ed ff ff       	call   c01029db <page_ref>
c0103c00:	85 c0                	test   %eax,%eax
c0103c02:	74 24                	je     c0103c28 <check_pgdir+0x623>
c0103c04:	c7 44 24 0c ba 6a 10 	movl   $0xc0106aba,0xc(%esp)
c0103c0b:	c0 
c0103c0c:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103c13:	c0 
c0103c14:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103c1b:	00 
c0103c1c:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103c23:	e8 c1 c7 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103c28:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c2d:	8b 00                	mov    (%eax),%eax
c0103c2f:	89 04 24             	mov    %eax,(%esp)
c0103c32:	e8 8c ed ff ff       	call   c01029c3 <pde2page>
c0103c37:	89 04 24             	mov    %eax,(%esp)
c0103c3a:	e8 9c ed ff ff       	call   c01029db <page_ref>
c0103c3f:	83 f8 01             	cmp    $0x1,%eax
c0103c42:	74 24                	je     c0103c68 <check_pgdir+0x663>
c0103c44:	c7 44 24 0c f4 6a 10 	movl   $0xc0106af4,0xc(%esp)
c0103c4b:	c0 
c0103c4c:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103c53:	c0 
c0103c54:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103c5b:	00 
c0103c5c:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103c63:	e8 81 c7 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103c68:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c6d:	8b 00                	mov    (%eax),%eax
c0103c6f:	89 04 24             	mov    %eax,(%esp)
c0103c72:	e8 4c ed ff ff       	call   c01029c3 <pde2page>
c0103c77:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c7e:	00 
c0103c7f:	89 04 24             	mov    %eax,(%esp)
c0103c82:	e8 91 ef ff ff       	call   c0102c18 <free_pages>
    boot_pgdir[0] = 0;
c0103c87:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103c92:	c7 04 24 1b 6b 10 c0 	movl   $0xc0106b1b,(%esp)
c0103c99:	e8 f4 c5 ff ff       	call   c0100292 <cprintf>
}
c0103c9e:	90                   	nop
c0103c9f:	c9                   	leave  
c0103ca0:	c3                   	ret    

c0103ca1 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103ca1:	55                   	push   %ebp
c0103ca2:	89 e5                	mov    %esp,%ebp
c0103ca4:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103cae:	e9 ca 00 00 00       	jmp    c0103d7d <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cbc:	c1 e8 0c             	shr    $0xc,%eax
c0103cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103cc2:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103cc7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103cca:	72 23                	jb     c0103cef <check_boot_pgdir+0x4e>
c0103ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103cd3:	c7 44 24 08 60 67 10 	movl   $0xc0106760,0x8(%esp)
c0103cda:	c0 
c0103cdb:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103ce2:	00 
c0103ce3:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103cea:	e8 fa c6 ff ff       	call   c01003e9 <__panic>
c0103cef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cf2:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103cf7:	89 c2                	mov    %eax,%edx
c0103cf9:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103cfe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103d05:	00 
c0103d06:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d0a:	89 04 24             	mov    %eax,(%esp)
c0103d0d:	e8 86 f5 ff ff       	call   c0103298 <get_pte>
c0103d12:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103d15:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103d19:	75 24                	jne    c0103d3f <check_boot_pgdir+0x9e>
c0103d1b:	c7 44 24 0c 38 6b 10 	movl   $0xc0106b38,0xc(%esp)
c0103d22:	c0 
c0103d23:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103d2a:	c0 
c0103d2b:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103d32:	00 
c0103d33:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103d3a:	e8 aa c6 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103d3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d42:	8b 00                	mov    (%eax),%eax
c0103d44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d49:	89 c2                	mov    %eax,%edx
c0103d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d4e:	39 c2                	cmp    %eax,%edx
c0103d50:	74 24                	je     c0103d76 <check_boot_pgdir+0xd5>
c0103d52:	c7 44 24 0c 75 6b 10 	movl   $0xc0106b75,0xc(%esp)
c0103d59:	c0 
c0103d5a:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103d61:	c0 
c0103d62:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103d69:	00 
c0103d6a:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103d71:	e8 73 c6 ff ff       	call   c01003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103d76:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103d7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d80:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103d85:	39 c2                	cmp    %eax,%edx
c0103d87:	0f 82 26 ff ff ff    	jb     c0103cb3 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103d8d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103d92:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103d97:	8b 00                	mov    (%eax),%eax
c0103d99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d9e:	89 c2                	mov    %eax,%edx
c0103da0:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103da8:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103daf:	77 23                	ja     c0103dd4 <check_boot_pgdir+0x133>
c0103db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103db4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103db8:	c7 44 24 08 04 68 10 	movl   $0xc0106804,0x8(%esp)
c0103dbf:	c0 
c0103dc0:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103dc7:	00 
c0103dc8:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103dcf:	e8 15 c6 ff ff       	call   c01003e9 <__panic>
c0103dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103dd7:	05 00 00 00 40       	add    $0x40000000,%eax
c0103ddc:	39 d0                	cmp    %edx,%eax
c0103dde:	74 24                	je     c0103e04 <check_boot_pgdir+0x163>
c0103de0:	c7 44 24 0c 8c 6b 10 	movl   $0xc0106b8c,0xc(%esp)
c0103de7:	c0 
c0103de8:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103def:	c0 
c0103df0:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103df7:	00 
c0103df8:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103dff:	e8 e5 c5 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103e04:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103e09:	8b 00                	mov    (%eax),%eax
c0103e0b:	85 c0                	test   %eax,%eax
c0103e0d:	74 24                	je     c0103e33 <check_boot_pgdir+0x192>
c0103e0f:	c7 44 24 0c c0 6b 10 	movl   $0xc0106bc0,0xc(%esp)
c0103e16:	c0 
c0103e17:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103e1e:	c0 
c0103e1f:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103e26:	00 
c0103e27:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103e2e:	e8 b6 c5 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e3a:	e8 a1 ed ff ff       	call   c0102be0 <alloc_pages>
c0103e3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103e42:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103e47:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e4e:	00 
c0103e4f:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103e56:	00 
c0103e57:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103e5a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e5e:	89 04 24             	mov    %eax,(%esp)
c0103e61:	e8 6b f6 ff ff       	call   c01034d1 <page_insert>
c0103e66:	85 c0                	test   %eax,%eax
c0103e68:	74 24                	je     c0103e8e <check_boot_pgdir+0x1ed>
c0103e6a:	c7 44 24 0c d4 6b 10 	movl   $0xc0106bd4,0xc(%esp)
c0103e71:	c0 
c0103e72:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103e79:	c0 
c0103e7a:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103e81:	00 
c0103e82:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103e89:	e8 5b c5 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103e8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e91:	89 04 24             	mov    %eax,(%esp)
c0103e94:	e8 42 eb ff ff       	call   c01029db <page_ref>
c0103e99:	83 f8 01             	cmp    $0x1,%eax
c0103e9c:	74 24                	je     c0103ec2 <check_boot_pgdir+0x221>
c0103e9e:	c7 44 24 0c 02 6c 10 	movl   $0xc0106c02,0xc(%esp)
c0103ea5:	c0 
c0103ea6:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103ead:	c0 
c0103eae:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103eb5:	00 
c0103eb6:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103ebd:	e8 27 c5 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103ec2:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103ec7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103ece:	00 
c0103ecf:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103ed6:	00 
c0103ed7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103eda:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ede:	89 04 24             	mov    %eax,(%esp)
c0103ee1:	e8 eb f5 ff ff       	call   c01034d1 <page_insert>
c0103ee6:	85 c0                	test   %eax,%eax
c0103ee8:	74 24                	je     c0103f0e <check_boot_pgdir+0x26d>
c0103eea:	c7 44 24 0c 14 6c 10 	movl   $0xc0106c14,0xc(%esp)
c0103ef1:	c0 
c0103ef2:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103ef9:	c0 
c0103efa:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103f01:	00 
c0103f02:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103f09:	e8 db c4 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f11:	89 04 24             	mov    %eax,(%esp)
c0103f14:	e8 c2 ea ff ff       	call   c01029db <page_ref>
c0103f19:	83 f8 02             	cmp    $0x2,%eax
c0103f1c:	74 24                	je     c0103f42 <check_boot_pgdir+0x2a1>
c0103f1e:	c7 44 24 0c 4b 6c 10 	movl   $0xc0106c4b,0xc(%esp)
c0103f25:	c0 
c0103f26:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103f2d:	c0 
c0103f2e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103f35:	00 
c0103f36:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103f3d:	e8 a7 c4 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103f42:	c7 45 e8 5c 6c 10 c0 	movl   $0xc0106c5c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0103f49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f50:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f57:	e8 e1 15 00 00       	call   c010553d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103f5c:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103f63:	00 
c0103f64:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f6b:	e8 44 16 00 00       	call   c01055b4 <strcmp>
c0103f70:	85 c0                	test   %eax,%eax
c0103f72:	74 24                	je     c0103f98 <check_boot_pgdir+0x2f7>
c0103f74:	c7 44 24 0c 74 6c 10 	movl   $0xc0106c74,0xc(%esp)
c0103f7b:	c0 
c0103f7c:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103f83:	c0 
c0103f84:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0103f8b:	00 
c0103f8c:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103f93:	e8 51 c4 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f9b:	89 04 24             	mov    %eax,(%esp)
c0103f9e:	e8 8e e9 ff ff       	call   c0102931 <page2kva>
c0103fa3:	05 00 01 00 00       	add    $0x100,%eax
c0103fa8:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103fab:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103fb2:	e8 30 15 00 00       	call   c01054e7 <strlen>
c0103fb7:	85 c0                	test   %eax,%eax
c0103fb9:	74 24                	je     c0103fdf <check_boot_pgdir+0x33e>
c0103fbb:	c7 44 24 0c ac 6c 10 	movl   $0xc0106cac,0xc(%esp)
c0103fc2:	c0 
c0103fc3:	c7 44 24 08 4d 68 10 	movl   $0xc010684d,0x8(%esp)
c0103fca:	c0 
c0103fcb:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0103fd2:	00 
c0103fd3:	c7 04 24 28 68 10 c0 	movl   $0xc0106828,(%esp)
c0103fda:	e8 0a c4 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0103fdf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fe6:	00 
c0103fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fea:	89 04 24             	mov    %eax,(%esp)
c0103fed:	e8 26 ec ff ff       	call   c0102c18 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103ff2:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103ff7:	8b 00                	mov    (%eax),%eax
c0103ff9:	89 04 24             	mov    %eax,(%esp)
c0103ffc:	e8 c2 e9 ff ff       	call   c01029c3 <pde2page>
c0104001:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104008:	00 
c0104009:	89 04 24             	mov    %eax,(%esp)
c010400c:	e8 07 ec ff ff       	call   c0102c18 <free_pages>
    boot_pgdir[0] = 0;
c0104011:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104016:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010401c:	c7 04 24 d0 6c 10 c0 	movl   $0xc0106cd0,(%esp)
c0104023:	e8 6a c2 ff ff       	call   c0100292 <cprintf>
}
c0104028:	90                   	nop
c0104029:	c9                   	leave  
c010402a:	c3                   	ret    

c010402b <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c010402b:	55                   	push   %ebp
c010402c:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010402e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104031:	83 e0 04             	and    $0x4,%eax
c0104034:	85 c0                	test   %eax,%eax
c0104036:	74 04                	je     c010403c <perm2str+0x11>
c0104038:	b0 75                	mov    $0x75,%al
c010403a:	eb 02                	jmp    c010403e <perm2str+0x13>
c010403c:	b0 2d                	mov    $0x2d,%al
c010403e:	a2 08 bf 11 c0       	mov    %al,0xc011bf08
    str[1] = 'r';
c0104043:	c6 05 09 bf 11 c0 72 	movb   $0x72,0xc011bf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010404a:	8b 45 08             	mov    0x8(%ebp),%eax
c010404d:	83 e0 02             	and    $0x2,%eax
c0104050:	85 c0                	test   %eax,%eax
c0104052:	74 04                	je     c0104058 <perm2str+0x2d>
c0104054:	b0 77                	mov    $0x77,%al
c0104056:	eb 02                	jmp    c010405a <perm2str+0x2f>
c0104058:	b0 2d                	mov    $0x2d,%al
c010405a:	a2 0a bf 11 c0       	mov    %al,0xc011bf0a
    str[3] = '\0';
c010405f:	c6 05 0b bf 11 c0 00 	movb   $0x0,0xc011bf0b
    return str;
c0104066:	b8 08 bf 11 c0       	mov    $0xc011bf08,%eax
}
c010406b:	5d                   	pop    %ebp
c010406c:	c3                   	ret    

c010406d <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010406d:	55                   	push   %ebp
c010406e:	89 e5                	mov    %esp,%ebp
c0104070:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0104073:	8b 45 10             	mov    0x10(%ebp),%eax
c0104076:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104079:	72 0d                	jb     c0104088 <get_pgtable_items+0x1b>
        return 0;
c010407b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104080:	e9 98 00 00 00       	jmp    c010411d <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0104085:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0104088:	8b 45 10             	mov    0x10(%ebp),%eax
c010408b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010408e:	73 18                	jae    c01040a8 <get_pgtable_items+0x3b>
c0104090:	8b 45 10             	mov    0x10(%ebp),%eax
c0104093:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010409a:	8b 45 14             	mov    0x14(%ebp),%eax
c010409d:	01 d0                	add    %edx,%eax
c010409f:	8b 00                	mov    (%eax),%eax
c01040a1:	83 e0 01             	and    $0x1,%eax
c01040a4:	85 c0                	test   %eax,%eax
c01040a6:	74 dd                	je     c0104085 <get_pgtable_items+0x18>
    }
    if (start < right) {
c01040a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01040ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01040ae:	73 68                	jae    c0104118 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01040b0:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01040b4:	74 08                	je     c01040be <get_pgtable_items+0x51>
            *left_store = start;
c01040b6:	8b 45 18             	mov    0x18(%ebp),%eax
c01040b9:	8b 55 10             	mov    0x10(%ebp),%edx
c01040bc:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01040be:	8b 45 10             	mov    0x10(%ebp),%eax
c01040c1:	8d 50 01             	lea    0x1(%eax),%edx
c01040c4:	89 55 10             	mov    %edx,0x10(%ebp)
c01040c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01040ce:	8b 45 14             	mov    0x14(%ebp),%eax
c01040d1:	01 d0                	add    %edx,%eax
c01040d3:	8b 00                	mov    (%eax),%eax
c01040d5:	83 e0 07             	and    $0x7,%eax
c01040d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01040db:	eb 03                	jmp    c01040e0 <get_pgtable_items+0x73>
            start ++;
c01040dd:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01040e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01040e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01040e6:	73 1d                	jae    c0104105 <get_pgtable_items+0x98>
c01040e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01040eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01040f2:	8b 45 14             	mov    0x14(%ebp),%eax
c01040f5:	01 d0                	add    %edx,%eax
c01040f7:	8b 00                	mov    (%eax),%eax
c01040f9:	83 e0 07             	and    $0x7,%eax
c01040fc:	89 c2                	mov    %eax,%edx
c01040fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104101:	39 c2                	cmp    %eax,%edx
c0104103:	74 d8                	je     c01040dd <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0104105:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104109:	74 08                	je     c0104113 <get_pgtable_items+0xa6>
            *right_store = start;
c010410b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010410e:	8b 55 10             	mov    0x10(%ebp),%edx
c0104111:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104113:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104116:	eb 05                	jmp    c010411d <get_pgtable_items+0xb0>
    }
    return 0;
c0104118:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010411d:	c9                   	leave  
c010411e:	c3                   	ret    

c010411f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010411f:	55                   	push   %ebp
c0104120:	89 e5                	mov    %esp,%ebp
c0104122:	57                   	push   %edi
c0104123:	56                   	push   %esi
c0104124:	53                   	push   %ebx
c0104125:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104128:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c010412f:	e8 5e c1 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0104134:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010413b:	e9 fa 00 00 00       	jmp    c010423a <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104143:	89 04 24             	mov    %eax,(%esp)
c0104146:	e8 e0 fe ff ff       	call   c010402b <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010414b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010414e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104151:	29 d1                	sub    %edx,%ecx
c0104153:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104155:	89 d6                	mov    %edx,%esi
c0104157:	c1 e6 16             	shl    $0x16,%esi
c010415a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010415d:	89 d3                	mov    %edx,%ebx
c010415f:	c1 e3 16             	shl    $0x16,%ebx
c0104162:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104165:	89 d1                	mov    %edx,%ecx
c0104167:	c1 e1 16             	shl    $0x16,%ecx
c010416a:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010416d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104170:	29 d7                	sub    %edx,%edi
c0104172:	89 fa                	mov    %edi,%edx
c0104174:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104178:	89 74 24 10          	mov    %esi,0x10(%esp)
c010417c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104180:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104184:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104188:	c7 04 24 21 6d 10 c0 	movl   $0xc0106d21,(%esp)
c010418f:	e8 fe c0 ff ff       	call   c0100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0104194:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104197:	c1 e0 0a             	shl    $0xa,%eax
c010419a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010419d:	eb 54                	jmp    c01041f3 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010419f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041a2:	89 04 24             	mov    %eax,(%esp)
c01041a5:	e8 81 fe ff ff       	call   c010402b <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01041aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01041ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01041b0:	29 d1                	sub    %edx,%ecx
c01041b2:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01041b4:	89 d6                	mov    %edx,%esi
c01041b6:	c1 e6 0c             	shl    $0xc,%esi
c01041b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041bc:	89 d3                	mov    %edx,%ebx
c01041be:	c1 e3 0c             	shl    $0xc,%ebx
c01041c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01041c4:	89 d1                	mov    %edx,%ecx
c01041c6:	c1 e1 0c             	shl    $0xc,%ecx
c01041c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01041cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01041cf:	29 d7                	sub    %edx,%edi
c01041d1:	89 fa                	mov    %edi,%edx
c01041d3:	89 44 24 14          	mov    %eax,0x14(%esp)
c01041d7:	89 74 24 10          	mov    %esi,0x10(%esp)
c01041db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01041df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01041e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01041e7:	c7 04 24 40 6d 10 c0 	movl   $0xc0106d40,(%esp)
c01041ee:	e8 9f c0 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01041f3:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01041f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041fe:	89 d3                	mov    %edx,%ebx
c0104200:	c1 e3 0a             	shl    $0xa,%ebx
c0104203:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104206:	89 d1                	mov    %edx,%ecx
c0104208:	c1 e1 0a             	shl    $0xa,%ecx
c010420b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c010420e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104212:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104215:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104219:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010421d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104221:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104225:	89 0c 24             	mov    %ecx,(%esp)
c0104228:	e8 40 fe ff ff       	call   c010406d <get_pgtable_items>
c010422d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104230:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104234:	0f 85 65 ff ff ff    	jne    c010419f <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010423a:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010423f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104242:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104245:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104249:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010424c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104250:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104254:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104258:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010425f:	00 
c0104260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104267:	e8 01 fe ff ff       	call   c010406d <get_pgtable_items>
c010426c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010426f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104273:	0f 85 c7 fe ff ff    	jne    c0104140 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104279:	c7 04 24 64 6d 10 c0 	movl   $0xc0106d64,(%esp)
c0104280:	e8 0d c0 ff ff       	call   c0100292 <cprintf>
}
c0104285:	90                   	nop
c0104286:	83 c4 4c             	add    $0x4c,%esp
c0104289:	5b                   	pop    %ebx
c010428a:	5e                   	pop    %esi
c010428b:	5f                   	pop    %edi
c010428c:	5d                   	pop    %ebp
c010428d:	c3                   	ret    

c010428e <page2ppn>:
page2ppn(struct Page *page) {
c010428e:	55                   	push   %ebp
c010428f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104291:	8b 45 08             	mov    0x8(%ebp),%eax
c0104294:	8b 15 18 bf 11 c0    	mov    0xc011bf18,%edx
c010429a:	29 d0                	sub    %edx,%eax
c010429c:	c1 f8 02             	sar    $0x2,%eax
c010429f:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01042a5:	5d                   	pop    %ebp
c01042a6:	c3                   	ret    

c01042a7 <page2pa>:
page2pa(struct Page *page) {
c01042a7:	55                   	push   %ebp
c01042a8:	89 e5                	mov    %esp,%ebp
c01042aa:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01042ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01042b0:	89 04 24             	mov    %eax,(%esp)
c01042b3:	e8 d6 ff ff ff       	call   c010428e <page2ppn>
c01042b8:	c1 e0 0c             	shl    $0xc,%eax
}
c01042bb:	c9                   	leave  
c01042bc:	c3                   	ret    

c01042bd <page_ref>:
page_ref(struct Page *page) {
c01042bd:	55                   	push   %ebp
c01042be:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01042c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01042c3:	8b 00                	mov    (%eax),%eax
}
c01042c5:	5d                   	pop    %ebp
c01042c6:	c3                   	ret    

c01042c7 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01042c7:	55                   	push   %ebp
c01042c8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01042ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01042cd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01042d0:	89 10                	mov    %edx,(%eax)
}
c01042d2:	90                   	nop
c01042d3:	5d                   	pop    %ebp
c01042d4:	c3                   	ret    

c01042d5 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01042d5:	55                   	push   %ebp
c01042d6:	89 e5                	mov    %esp,%ebp
c01042d8:	83 ec 10             	sub    $0x10,%esp
c01042db:	c7 45 fc 1c bf 11 c0 	movl   $0xc011bf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01042e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01042e8:	89 50 04             	mov    %edx,0x4(%eax)
c01042eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042ee:	8b 50 04             	mov    0x4(%eax),%edx
c01042f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042f4:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01042f6:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c01042fd:	00 00 00 
}
c0104300:	90                   	nop
c0104301:	c9                   	leave  
c0104302:	c3                   	ret    

c0104303 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104303:	55                   	push   %ebp
c0104304:	89 e5                	mov    %esp,%ebp
c0104306:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0104309:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010430d:	75 24                	jne    c0104333 <default_init_memmap+0x30>
c010430f:	c7 44 24 0c 98 6d 10 	movl   $0xc0106d98,0xc(%esp)
c0104316:	c0 
c0104317:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c010431e:	c0 
c010431f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104326:	00 
c0104327:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c010432e:	e8 b6 c0 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c0104333:	8b 45 08             	mov    0x8(%ebp),%eax
c0104336:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104339:	eb 7d                	jmp    c01043b8 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c010433b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010433e:	83 c0 04             	add    $0x4,%eax
c0104341:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104348:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010434b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010434e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104351:	0f a3 10             	bt     %edx,(%eax)
c0104354:	19 c0                	sbb    %eax,%eax
c0104356:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104359:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010435d:	0f 95 c0             	setne  %al
c0104360:	0f b6 c0             	movzbl %al,%eax
c0104363:	85 c0                	test   %eax,%eax
c0104365:	75 24                	jne    c010438b <default_init_memmap+0x88>
c0104367:	c7 44 24 0c c9 6d 10 	movl   $0xc0106dc9,0xc(%esp)
c010436e:	c0 
c010436f:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104376:	c0 
c0104377:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010437e:	00 
c010437f:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104386:	e8 5e c0 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c010438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010438e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104395:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104398:	8b 50 08             	mov    0x8(%eax),%edx
c010439b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010439e:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01043a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01043a8:	00 
c01043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043ac:	89 04 24             	mov    %eax,(%esp)
c01043af:	e8 13 ff ff ff       	call   c01042c7 <set_page_ref>
    for (; p != base + n; p ++) {
c01043b4:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01043b8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01043bb:	89 d0                	mov    %edx,%eax
c01043bd:	c1 e0 02             	shl    $0x2,%eax
c01043c0:	01 d0                	add    %edx,%eax
c01043c2:	c1 e0 02             	shl    $0x2,%eax
c01043c5:	89 c2                	mov    %eax,%edx
c01043c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01043ca:	01 d0                	add    %edx,%eax
c01043cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01043cf:	0f 85 66 ff ff ff    	jne    c010433b <default_init_memmap+0x38>
    }
    base->property = n;
c01043d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01043d8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01043db:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01043de:	8b 45 08             	mov    0x8(%ebp),%eax
c01043e1:	83 c0 04             	add    $0x4,%eax
c01043e4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01043eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043f1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01043f4:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01043f7:	8b 15 24 bf 11 c0    	mov    0xc011bf24,%edx
c01043fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104400:	01 d0                	add    %edx,%eax
c0104402:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
    list_add_before(&free_list, &(base->page_link));
c0104407:	8b 45 08             	mov    0x8(%ebp),%eax
c010440a:	83 c0 0c             	add    $0xc,%eax
c010440d:	c7 45 e4 1c bf 11 c0 	movl   $0xc011bf1c,-0x1c(%ebp)
c0104414:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010441a:	8b 00                	mov    (%eax),%eax
c010441c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010441f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104422:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104428:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010442b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010442e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104431:	89 10                	mov    %edx,(%eax)
c0104433:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104436:	8b 10                	mov    (%eax),%edx
c0104438:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010443b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010443e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104441:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104444:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104447:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010444a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010444d:	89 10                	mov    %edx,(%eax)
}
c010444f:	90                   	nop
c0104450:	c9                   	leave  
c0104451:	c3                   	ret    

c0104452 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104452:	55                   	push   %ebp
c0104453:	89 e5                	mov    %esp,%ebp
c0104455:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0104458:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010445c:	75 24                	jne    c0104482 <default_alloc_pages+0x30>
c010445e:	c7 44 24 0c 98 6d 10 	movl   $0xc0106d98,0xc(%esp)
c0104465:	c0 
c0104466:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c010446d:	c0 
c010446e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0104475:	00 
c0104476:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c010447d:	e8 67 bf ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c0104482:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104487:	39 45 08             	cmp    %eax,0x8(%ebp)
c010448a:	76 0a                	jbe    c0104496 <default_alloc_pages+0x44>
        return NULL;
c010448c:	b8 00 00 00 00       	mov    $0x0,%eax
c0104491:	e9 49 01 00 00       	jmp    c01045df <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
c0104496:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010449d:	c7 45 f0 1c bf 11 c0 	movl   $0xc011bf1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01044a4:	eb 1c                	jmp    c01044c2 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01044a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044a9:	83 e8 0c             	sub    $0xc,%eax
c01044ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01044af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044b2:	8b 40 08             	mov    0x8(%eax),%eax
c01044b5:	39 45 08             	cmp    %eax,0x8(%ebp)
c01044b8:	77 08                	ja     c01044c2 <default_alloc_pages+0x70>
            page = p;
c01044ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01044c0:	eb 18                	jmp    c01044da <default_alloc_pages+0x88>
c01044c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01044c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044cb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01044ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044d1:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c01044d8:	75 cc                	jne    c01044a6 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c01044da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044de:	0f 84 f8 00 00 00    	je     c01045dc <default_alloc_pages+0x18a>
        if (page->property > n) {
c01044e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e7:	8b 40 08             	mov    0x8(%eax),%eax
c01044ea:	39 45 08             	cmp    %eax,0x8(%ebp)
c01044ed:	0f 83 98 00 00 00    	jae    c010458b <default_alloc_pages+0x139>
            struct Page *p = page + n;
c01044f3:	8b 55 08             	mov    0x8(%ebp),%edx
c01044f6:	89 d0                	mov    %edx,%eax
c01044f8:	c1 e0 02             	shl    $0x2,%eax
c01044fb:	01 d0                	add    %edx,%eax
c01044fd:	c1 e0 02             	shl    $0x2,%eax
c0104500:	89 c2                	mov    %eax,%edx
c0104502:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104505:	01 d0                	add    %edx,%eax
c0104507:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c010450a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010450d:	8b 40 08             	mov    0x8(%eax),%eax
c0104510:	2b 45 08             	sub    0x8(%ebp),%eax
c0104513:	89 c2                	mov    %eax,%edx
c0104515:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104518:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c010451b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010451e:	83 c0 04             	add    $0x4,%eax
c0104521:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104528:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010452b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010452e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104531:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
c0104534:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104537:	83 c0 0c             	add    $0xc,%eax
c010453a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010453d:	83 c2 0c             	add    $0xc,%edx
c0104540:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0104543:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104546:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104549:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010454c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010454f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104552:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104555:	8b 40 04             	mov    0x4(%eax),%eax
c0104558:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010455b:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010455e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104561:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104564:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0104567:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010456a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010456d:	89 10                	mov    %edx,(%eax)
c010456f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104572:	8b 10                	mov    (%eax),%edx
c0104574:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104577:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010457a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010457d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104580:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104583:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104586:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104589:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c010458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010458e:	83 c0 0c             	add    $0xc,%eax
c0104591:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104594:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104597:	8b 40 04             	mov    0x4(%eax),%eax
c010459a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010459d:	8b 12                	mov    (%edx),%edx
c010459f:	89 55 b0             	mov    %edx,-0x50(%ebp)
c01045a2:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01045a5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01045a8:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01045ab:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01045ae:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01045b1:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01045b4:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c01045b6:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c01045bb:	2b 45 08             	sub    0x8(%ebp),%eax
c01045be:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
        ClearPageProperty(page);
c01045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c6:	83 c0 04             	add    $0x4,%eax
c01045c9:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01045d0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01045d3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01045d6:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01045d9:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01045df:	c9                   	leave  
c01045e0:	c3                   	ret    

c01045e1 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01045e1:	55                   	push   %ebp
c01045e2:	89 e5                	mov    %esp,%ebp
c01045e4:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01045ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01045ee:	75 24                	jne    c0104614 <default_free_pages+0x33>
c01045f0:	c7 44 24 0c 98 6d 10 	movl   $0xc0106d98,0xc(%esp)
c01045f7:	c0 
c01045f8:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01045ff:	c0 
c0104600:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0104607:	00 
c0104608:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c010460f:	e8 d5 bd ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c0104614:	8b 45 08             	mov    0x8(%ebp),%eax
c0104617:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010461a:	e9 9d 00 00 00       	jmp    c01046bc <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c010461f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104622:	83 c0 04             	add    $0x4,%eax
c0104625:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010462c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010462f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104632:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104635:	0f a3 10             	bt     %edx,(%eax)
c0104638:	19 c0                	sbb    %eax,%eax
c010463a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010463d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104641:	0f 95 c0             	setne  %al
c0104644:	0f b6 c0             	movzbl %al,%eax
c0104647:	85 c0                	test   %eax,%eax
c0104649:	75 2c                	jne    c0104677 <default_free_pages+0x96>
c010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464e:	83 c0 04             	add    $0x4,%eax
c0104651:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104658:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010465b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010465e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104661:	0f a3 10             	bt     %edx,(%eax)
c0104664:	19 c0                	sbb    %eax,%eax
c0104666:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0104669:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010466d:	0f 95 c0             	setne  %al
c0104670:	0f b6 c0             	movzbl %al,%eax
c0104673:	85 c0                	test   %eax,%eax
c0104675:	74 24                	je     c010469b <default_free_pages+0xba>
c0104677:	c7 44 24 0c dc 6d 10 	movl   $0xc0106ddc,0xc(%esp)
c010467e:	c0 
c010467f:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104686:	c0 
c0104687:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010468e:	00 
c010468f:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104696:	e8 4e bd ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c010469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010469e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01046a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01046ac:	00 
c01046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b0:	89 04 24             	mov    %eax,(%esp)
c01046b3:	e8 0f fc ff ff       	call   c01042c7 <set_page_ref>
    for (; p != base + n; p ++) {
c01046b8:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01046bc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046bf:	89 d0                	mov    %edx,%eax
c01046c1:	c1 e0 02             	shl    $0x2,%eax
c01046c4:	01 d0                	add    %edx,%eax
c01046c6:	c1 e0 02             	shl    $0x2,%eax
c01046c9:	89 c2                	mov    %eax,%edx
c01046cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ce:	01 d0                	add    %edx,%eax
c01046d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046d3:	0f 85 46 ff ff ff    	jne    c010461f <default_free_pages+0x3e>
    }
    base->property = n;
c01046d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046df:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01046e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e5:	83 c0 04             	add    $0x4,%eax
c01046e8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01046ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01046f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01046f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01046f8:	0f ab 10             	bts    %edx,(%eax)
c01046fb:	c7 45 d4 1c bf 11 c0 	movl   $0xc011bf1c,-0x2c(%ebp)
    return listelm->next;
c0104702:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104705:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104708:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010470b:	e9 08 01 00 00       	jmp    c0104818 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104710:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104713:	83 e8 0c             	sub    $0xc,%eax
c0104716:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104719:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010471c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010471f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104722:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104725:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0104728:	8b 45 08             	mov    0x8(%ebp),%eax
c010472b:	8b 50 08             	mov    0x8(%eax),%edx
c010472e:	89 d0                	mov    %edx,%eax
c0104730:	c1 e0 02             	shl    $0x2,%eax
c0104733:	01 d0                	add    %edx,%eax
c0104735:	c1 e0 02             	shl    $0x2,%eax
c0104738:	89 c2                	mov    %eax,%edx
c010473a:	8b 45 08             	mov    0x8(%ebp),%eax
c010473d:	01 d0                	add    %edx,%eax
c010473f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104742:	75 5a                	jne    c010479e <default_free_pages+0x1bd>
            base->property += p->property;
c0104744:	8b 45 08             	mov    0x8(%ebp),%eax
c0104747:	8b 50 08             	mov    0x8(%eax),%edx
c010474a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010474d:	8b 40 08             	mov    0x8(%eax),%eax
c0104750:	01 c2                	add    %eax,%edx
c0104752:	8b 45 08             	mov    0x8(%ebp),%eax
c0104755:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0104758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010475b:	83 c0 04             	add    $0x4,%eax
c010475e:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0104765:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104768:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010476b:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010476e:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0104771:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104774:	83 c0 0c             	add    $0xc,%eax
c0104777:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010477a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010477d:	8b 40 04             	mov    0x4(%eax),%eax
c0104780:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104783:	8b 12                	mov    (%edx),%edx
c0104785:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0104788:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c010478b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010478e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104791:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104794:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104797:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010479a:	89 10                	mov    %edx,(%eax)
c010479c:	eb 7a                	jmp    c0104818 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c010479e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a1:	8b 50 08             	mov    0x8(%eax),%edx
c01047a4:	89 d0                	mov    %edx,%eax
c01047a6:	c1 e0 02             	shl    $0x2,%eax
c01047a9:	01 d0                	add    %edx,%eax
c01047ab:	c1 e0 02             	shl    $0x2,%eax
c01047ae:	89 c2                	mov    %eax,%edx
c01047b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047b3:	01 d0                	add    %edx,%eax
c01047b5:	39 45 08             	cmp    %eax,0x8(%ebp)
c01047b8:	75 5e                	jne    c0104818 <default_free_pages+0x237>
            p->property += base->property;
c01047ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047bd:	8b 50 08             	mov    0x8(%eax),%edx
c01047c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01047c3:	8b 40 08             	mov    0x8(%eax),%eax
c01047c6:	01 c2                	add    %eax,%edx
c01047c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047cb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01047ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01047d1:	83 c0 04             	add    $0x4,%eax
c01047d4:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c01047db:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01047de:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01047e1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01047e4:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c01047e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047ea:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01047ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f0:	83 c0 0c             	add    $0xc,%eax
c01047f3:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c01047f6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01047f9:	8b 40 04             	mov    0x4(%eax),%eax
c01047fc:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01047ff:	8b 12                	mov    (%edx),%edx
c0104801:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0104804:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0104807:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010480a:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010480d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104810:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104813:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104816:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c0104818:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c010481f:	0f 85 eb fe ff ff    	jne    c0104710 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
c0104825:	8b 15 24 bf 11 c0    	mov    0xc011bf24,%edx
c010482b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010482e:	01 d0                	add    %edx,%eax
c0104830:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
c0104835:	c7 45 9c 1c bf 11 c0 	movl   $0xc011bf1c,-0x64(%ebp)
    return listelm->next;
c010483c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010483f:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
c0104842:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104845:	eb 74                	jmp    c01048bb <default_free_pages+0x2da>
        p = le2page(le, page_link);
c0104847:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010484a:	83 e8 0c             	sub    $0xc,%eax
c010484d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(base + base->property <= p) {
c0104850:	8b 45 08             	mov    0x8(%ebp),%eax
c0104853:	8b 50 08             	mov    0x8(%eax),%edx
c0104856:	89 d0                	mov    %edx,%eax
c0104858:	c1 e0 02             	shl    $0x2,%eax
c010485b:	01 d0                	add    %edx,%eax
c010485d:	c1 e0 02             	shl    $0x2,%eax
c0104860:	89 c2                	mov    %eax,%edx
c0104862:	8b 45 08             	mov    0x8(%ebp),%eax
c0104865:	01 d0                	add    %edx,%eax
c0104867:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010486a:	72 40                	jb     c01048ac <default_free_pages+0x2cb>
            assert(base + base->property != p);
c010486c:	8b 45 08             	mov    0x8(%ebp),%eax
c010486f:	8b 50 08             	mov    0x8(%eax),%edx
c0104872:	89 d0                	mov    %edx,%eax
c0104874:	c1 e0 02             	shl    $0x2,%eax
c0104877:	01 d0                	add    %edx,%eax
c0104879:	c1 e0 02             	shl    $0x2,%eax
c010487c:	89 c2                	mov    %eax,%edx
c010487e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104881:	01 d0                	add    %edx,%eax
c0104883:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104886:	75 3e                	jne    c01048c6 <default_free_pages+0x2e5>
c0104888:	c7 44 24 0c 01 6e 10 	movl   $0xc0106e01,0xc(%esp)
c010488f:	c0 
c0104890:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104897:	c0 
c0104898:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c010489f:	00 
c01048a0:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01048a7:	e8 3d bb ff ff       	call   c01003e9 <__panic>
c01048ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048af:	89 45 98             	mov    %eax,-0x68(%ebp)
c01048b2:	8b 45 98             	mov    -0x68(%ebp),%eax
c01048b5:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
c01048b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048bb:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c01048c2:	75 83                	jne    c0104847 <default_free_pages+0x266>
c01048c4:	eb 01                	jmp    c01048c7 <default_free_pages+0x2e6>
            break;
c01048c6:	90                   	nop
        }
    }
    list_add_before(le, &(base->page_link));
c01048c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01048ca:	8d 50 0c             	lea    0xc(%eax),%edx
c01048cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048d0:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01048d3:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01048d6:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01048d9:	8b 00                	mov    (%eax),%eax
c01048db:	8b 55 90             	mov    -0x70(%ebp),%edx
c01048de:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01048e1:	89 45 88             	mov    %eax,-0x78(%ebp)
c01048e4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01048e7:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c01048ea:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01048ed:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01048f0:	89 10                	mov    %edx,(%eax)
c01048f2:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01048f5:	8b 10                	mov    (%eax),%edx
c01048f7:	8b 45 88             	mov    -0x78(%ebp),%eax
c01048fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01048fd:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104900:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104903:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104906:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104909:	8b 55 88             	mov    -0x78(%ebp),%edx
c010490c:	89 10                	mov    %edx,(%eax)
}
c010490e:	90                   	nop
c010490f:	c9                   	leave  
c0104910:	c3                   	ret    

c0104911 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104911:	55                   	push   %ebp
c0104912:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104914:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
}
c0104919:	5d                   	pop    %ebp
c010491a:	c3                   	ret    

c010491b <basic_check>:

static void
basic_check(void) {
c010491b:	55                   	push   %ebp
c010491c:	89 e5                	mov    %esp,%ebp
c010491e:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010492b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010492e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104931:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104934:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010493b:	e8 a0 e2 ff ff       	call   c0102be0 <alloc_pages>
c0104940:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104943:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104947:	75 24                	jne    c010496d <basic_check+0x52>
c0104949:	c7 44 24 0c 1c 6e 10 	movl   $0xc0106e1c,0xc(%esp)
c0104950:	c0 
c0104951:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104958:	c0 
c0104959:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0104960:	00 
c0104961:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104968:	e8 7c ba ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010496d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104974:	e8 67 e2 ff ff       	call   c0102be0 <alloc_pages>
c0104979:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010497c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104980:	75 24                	jne    c01049a6 <basic_check+0x8b>
c0104982:	c7 44 24 0c 38 6e 10 	movl   $0xc0106e38,0xc(%esp)
c0104989:	c0 
c010498a:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104991:	c0 
c0104992:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0104999:	00 
c010499a:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01049a1:	e8 43 ba ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01049a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01049ad:	e8 2e e2 ff ff       	call   c0102be0 <alloc_pages>
c01049b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01049b9:	75 24                	jne    c01049df <basic_check+0xc4>
c01049bb:	c7 44 24 0c 54 6e 10 	movl   $0xc0106e54,0xc(%esp)
c01049c2:	c0 
c01049c3:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01049ca:	c0 
c01049cb:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c01049d2:	00 
c01049d3:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01049da:	e8 0a ba ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01049df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049e2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049e5:	74 10                	je     c01049f7 <basic_check+0xdc>
c01049e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049ed:	74 08                	je     c01049f7 <basic_check+0xdc>
c01049ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049f5:	75 24                	jne    c0104a1b <basic_check+0x100>
c01049f7:	c7 44 24 0c 70 6e 10 	movl   $0xc0106e70,0xc(%esp)
c01049fe:	c0 
c01049ff:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104a06:	c0 
c0104a07:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0104a0e:	00 
c0104a0f:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104a16:	e8 ce b9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104a1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a1e:	89 04 24             	mov    %eax,(%esp)
c0104a21:	e8 97 f8 ff ff       	call   c01042bd <page_ref>
c0104a26:	85 c0                	test   %eax,%eax
c0104a28:	75 1e                	jne    c0104a48 <basic_check+0x12d>
c0104a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a2d:	89 04 24             	mov    %eax,(%esp)
c0104a30:	e8 88 f8 ff ff       	call   c01042bd <page_ref>
c0104a35:	85 c0                	test   %eax,%eax
c0104a37:	75 0f                	jne    c0104a48 <basic_check+0x12d>
c0104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a3c:	89 04 24             	mov    %eax,(%esp)
c0104a3f:	e8 79 f8 ff ff       	call   c01042bd <page_ref>
c0104a44:	85 c0                	test   %eax,%eax
c0104a46:	74 24                	je     c0104a6c <basic_check+0x151>
c0104a48:	c7 44 24 0c 94 6e 10 	movl   $0xc0106e94,0xc(%esp)
c0104a4f:	c0 
c0104a50:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104a57:	c0 
c0104a58:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104a5f:	00 
c0104a60:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104a67:	e8 7d b9 ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a6f:	89 04 24             	mov    %eax,(%esp)
c0104a72:	e8 30 f8 ff ff       	call   c01042a7 <page2pa>
c0104a77:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104a7d:	c1 e2 0c             	shl    $0xc,%edx
c0104a80:	39 d0                	cmp    %edx,%eax
c0104a82:	72 24                	jb     c0104aa8 <basic_check+0x18d>
c0104a84:	c7 44 24 0c d0 6e 10 	movl   $0xc0106ed0,0xc(%esp)
c0104a8b:	c0 
c0104a8c:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104a93:	c0 
c0104a94:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0104a9b:	00 
c0104a9c:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104aa3:	e8 41 b9 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aab:	89 04 24             	mov    %eax,(%esp)
c0104aae:	e8 f4 f7 ff ff       	call   c01042a7 <page2pa>
c0104ab3:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104ab9:	c1 e2 0c             	shl    $0xc,%edx
c0104abc:	39 d0                	cmp    %edx,%eax
c0104abe:	72 24                	jb     c0104ae4 <basic_check+0x1c9>
c0104ac0:	c7 44 24 0c ed 6e 10 	movl   $0xc0106eed,0xc(%esp)
c0104ac7:	c0 
c0104ac8:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104acf:	c0 
c0104ad0:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0104ad7:	00 
c0104ad8:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104adf:	e8 05 b9 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ae7:	89 04 24             	mov    %eax,(%esp)
c0104aea:	e8 b8 f7 ff ff       	call   c01042a7 <page2pa>
c0104aef:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104af5:	c1 e2 0c             	shl    $0xc,%edx
c0104af8:	39 d0                	cmp    %edx,%eax
c0104afa:	72 24                	jb     c0104b20 <basic_check+0x205>
c0104afc:	c7 44 24 0c 0a 6f 10 	movl   $0xc0106f0a,0xc(%esp)
c0104b03:	c0 
c0104b04:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104b0b:	c0 
c0104b0c:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104b13:	00 
c0104b14:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104b1b:	e8 c9 b8 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104b20:	a1 1c bf 11 c0       	mov    0xc011bf1c,%eax
c0104b25:	8b 15 20 bf 11 c0    	mov    0xc011bf20,%edx
c0104b2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104b2e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104b31:	c7 45 dc 1c bf 11 c0 	movl   $0xc011bf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104b38:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104b3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b3e:	89 50 04             	mov    %edx,0x4(%eax)
c0104b41:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104b44:	8b 50 04             	mov    0x4(%eax),%edx
c0104b47:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104b4a:	89 10                	mov    %edx,(%eax)
c0104b4c:	c7 45 e0 1c bf 11 c0 	movl   $0xc011bf1c,-0x20(%ebp)
    return list->next == list;
c0104b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b56:	8b 40 04             	mov    0x4(%eax),%eax
c0104b59:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104b5c:	0f 94 c0             	sete   %al
c0104b5f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104b62:	85 c0                	test   %eax,%eax
c0104b64:	75 24                	jne    c0104b8a <basic_check+0x26f>
c0104b66:	c7 44 24 0c 27 6f 10 	movl   $0xc0106f27,0xc(%esp)
c0104b6d:	c0 
c0104b6e:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104b75:	c0 
c0104b76:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0104b7d:	00 
c0104b7e:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104b85:	e8 5f b8 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104b8a:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104b8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104b92:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c0104b99:	00 00 00 

    assert(alloc_page() == NULL);
c0104b9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ba3:	e8 38 e0 ff ff       	call   c0102be0 <alloc_pages>
c0104ba8:	85 c0                	test   %eax,%eax
c0104baa:	74 24                	je     c0104bd0 <basic_check+0x2b5>
c0104bac:	c7 44 24 0c 3e 6f 10 	movl   $0xc0106f3e,0xc(%esp)
c0104bb3:	c0 
c0104bb4:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104bbb:	c0 
c0104bbc:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0104bc3:	00 
c0104bc4:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104bcb:	e8 19 b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104bd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bd7:	00 
c0104bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bdb:	89 04 24             	mov    %eax,(%esp)
c0104bde:	e8 35 e0 ff ff       	call   c0102c18 <free_pages>
    free_page(p1);
c0104be3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bea:	00 
c0104beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bee:	89 04 24             	mov    %eax,(%esp)
c0104bf1:	e8 22 e0 ff ff       	call   c0102c18 <free_pages>
    free_page(p2);
c0104bf6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bfd:	00 
c0104bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c01:	89 04 24             	mov    %eax,(%esp)
c0104c04:	e8 0f e0 ff ff       	call   c0102c18 <free_pages>
    assert(nr_free == 3);
c0104c09:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104c0e:	83 f8 03             	cmp    $0x3,%eax
c0104c11:	74 24                	je     c0104c37 <basic_check+0x31c>
c0104c13:	c7 44 24 0c 53 6f 10 	movl   $0xc0106f53,0xc(%esp)
c0104c1a:	c0 
c0104c1b:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104c22:	c0 
c0104c23:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104c2a:	00 
c0104c2b:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104c32:	e8 b2 b7 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104c37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c3e:	e8 9d df ff ff       	call   c0102be0 <alloc_pages>
c0104c43:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c46:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c4a:	75 24                	jne    c0104c70 <basic_check+0x355>
c0104c4c:	c7 44 24 0c 1c 6e 10 	movl   $0xc0106e1c,0xc(%esp)
c0104c53:	c0 
c0104c54:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104c5b:	c0 
c0104c5c:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0104c63:	00 
c0104c64:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104c6b:	e8 79 b7 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104c70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c77:	e8 64 df ff ff       	call   c0102be0 <alloc_pages>
c0104c7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c83:	75 24                	jne    c0104ca9 <basic_check+0x38e>
c0104c85:	c7 44 24 0c 38 6e 10 	movl   $0xc0106e38,0xc(%esp)
c0104c8c:	c0 
c0104c8d:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104c94:	c0 
c0104c95:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0104c9c:	00 
c0104c9d:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104ca4:	e8 40 b7 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104ca9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cb0:	e8 2b df ff ff       	call   c0102be0 <alloc_pages>
c0104cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104cb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104cbc:	75 24                	jne    c0104ce2 <basic_check+0x3c7>
c0104cbe:	c7 44 24 0c 54 6e 10 	movl   $0xc0106e54,0xc(%esp)
c0104cc5:	c0 
c0104cc6:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104ccd:	c0 
c0104cce:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104cd5:	00 
c0104cd6:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104cdd:	e8 07 b7 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104ce2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ce9:	e8 f2 de ff ff       	call   c0102be0 <alloc_pages>
c0104cee:	85 c0                	test   %eax,%eax
c0104cf0:	74 24                	je     c0104d16 <basic_check+0x3fb>
c0104cf2:	c7 44 24 0c 3e 6f 10 	movl   $0xc0106f3e,0xc(%esp)
c0104cf9:	c0 
c0104cfa:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104d01:	c0 
c0104d02:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0104d09:	00 
c0104d0a:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104d11:	e8 d3 b6 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104d16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d1d:	00 
c0104d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d21:	89 04 24             	mov    %eax,(%esp)
c0104d24:	e8 ef de ff ff       	call   c0102c18 <free_pages>
c0104d29:	c7 45 d8 1c bf 11 c0 	movl   $0xc011bf1c,-0x28(%ebp)
c0104d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104d33:	8b 40 04             	mov    0x4(%eax),%eax
c0104d36:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104d39:	0f 94 c0             	sete   %al
c0104d3c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104d3f:	85 c0                	test   %eax,%eax
c0104d41:	74 24                	je     c0104d67 <basic_check+0x44c>
c0104d43:	c7 44 24 0c 60 6f 10 	movl   $0xc0106f60,0xc(%esp)
c0104d4a:	c0 
c0104d4b:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104d52:	c0 
c0104d53:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104d5a:	00 
c0104d5b:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104d62:	e8 82 b6 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104d67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d6e:	e8 6d de ff ff       	call   c0102be0 <alloc_pages>
c0104d73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104d7c:	74 24                	je     c0104da2 <basic_check+0x487>
c0104d7e:	c7 44 24 0c 78 6f 10 	movl   $0xc0106f78,0xc(%esp)
c0104d85:	c0 
c0104d86:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104d8d:	c0 
c0104d8e:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104d95:	00 
c0104d96:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104d9d:	e8 47 b6 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104da2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104da9:	e8 32 de ff ff       	call   c0102be0 <alloc_pages>
c0104dae:	85 c0                	test   %eax,%eax
c0104db0:	74 24                	je     c0104dd6 <basic_check+0x4bb>
c0104db2:	c7 44 24 0c 3e 6f 10 	movl   $0xc0106f3e,0xc(%esp)
c0104db9:	c0 
c0104dba:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104dc1:	c0 
c0104dc2:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0104dc9:	00 
c0104dca:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104dd1:	e8 13 b6 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104dd6:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104ddb:	85 c0                	test   %eax,%eax
c0104ddd:	74 24                	je     c0104e03 <basic_check+0x4e8>
c0104ddf:	c7 44 24 0c 91 6f 10 	movl   $0xc0106f91,0xc(%esp)
c0104de6:	c0 
c0104de7:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104dee:	c0 
c0104def:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0104df6:	00 
c0104df7:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104dfe:	e8 e6 b5 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104e03:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104e09:	a3 1c bf 11 c0       	mov    %eax,0xc011bf1c
c0104e0e:	89 15 20 bf 11 c0    	mov    %edx,0xc011bf20
    nr_free = nr_free_store;
c0104e14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e17:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24

    free_page(p);
c0104e1c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e23:	00 
c0104e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e27:	89 04 24             	mov    %eax,(%esp)
c0104e2a:	e8 e9 dd ff ff       	call   c0102c18 <free_pages>
    free_page(p1);
c0104e2f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e36:	00 
c0104e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e3a:	89 04 24             	mov    %eax,(%esp)
c0104e3d:	e8 d6 dd ff ff       	call   c0102c18 <free_pages>
    free_page(p2);
c0104e42:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e49:	00 
c0104e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e4d:	89 04 24             	mov    %eax,(%esp)
c0104e50:	e8 c3 dd ff ff       	call   c0102c18 <free_pages>
}
c0104e55:	90                   	nop
c0104e56:	c9                   	leave  
c0104e57:	c3                   	ret    

c0104e58 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104e58:	55                   	push   %ebp
c0104e59:	89 e5                	mov    %esp,%ebp
c0104e5b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104e61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e68:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104e6f:	c7 45 ec 1c bf 11 c0 	movl   $0xc011bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104e76:	eb 6a                	jmp    c0104ee2 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104e78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e7b:	83 e8 0c             	sub    $0xc,%eax
c0104e7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104e81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104e84:	83 c0 04             	add    $0x4,%eax
c0104e87:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104e8e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104e91:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104e94:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104e97:	0f a3 10             	bt     %edx,(%eax)
c0104e9a:	19 c0                	sbb    %eax,%eax
c0104e9c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104e9f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104ea3:	0f 95 c0             	setne  %al
c0104ea6:	0f b6 c0             	movzbl %al,%eax
c0104ea9:	85 c0                	test   %eax,%eax
c0104eab:	75 24                	jne    c0104ed1 <default_check+0x79>
c0104ead:	c7 44 24 0c 9e 6f 10 	movl   $0xc0106f9e,0xc(%esp)
c0104eb4:	c0 
c0104eb5:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104ebc:	c0 
c0104ebd:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0104ec4:	00 
c0104ec5:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104ecc:	e8 18 b5 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104ed1:	ff 45 f4             	incl   -0xc(%ebp)
c0104ed4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104ed7:	8b 50 08             	mov    0x8(%eax),%edx
c0104eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104edd:	01 d0                	add    %edx,%eax
c0104edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ee5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104ee8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104eeb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104eee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ef1:	81 7d ec 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x14(%ebp)
c0104ef8:	0f 85 7a ff ff ff    	jne    c0104e78 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104efe:	e8 48 dd ff ff       	call   c0102c4b <nr_free_pages>
c0104f03:	89 c2                	mov    %eax,%edx
c0104f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f08:	39 c2                	cmp    %eax,%edx
c0104f0a:	74 24                	je     c0104f30 <default_check+0xd8>
c0104f0c:	c7 44 24 0c ae 6f 10 	movl   $0xc0106fae,0xc(%esp)
c0104f13:	c0 
c0104f14:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104f1b:	c0 
c0104f1c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104f23:	00 
c0104f24:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104f2b:	e8 b9 b4 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104f30:	e8 e6 f9 ff ff       	call   c010491b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104f35:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104f3c:	e8 9f dc ff ff       	call   c0102be0 <alloc_pages>
c0104f41:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104f44:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104f48:	75 24                	jne    c0104f6e <default_check+0x116>
c0104f4a:	c7 44 24 0c c7 6f 10 	movl   $0xc0106fc7,0xc(%esp)
c0104f51:	c0 
c0104f52:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104f59:	c0 
c0104f5a:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0104f61:	00 
c0104f62:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104f69:	e8 7b b4 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104f6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f71:	83 c0 04             	add    $0x4,%eax
c0104f74:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104f7b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104f7e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104f81:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104f84:	0f a3 10             	bt     %edx,(%eax)
c0104f87:	19 c0                	sbb    %eax,%eax
c0104f89:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104f8c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104f90:	0f 95 c0             	setne  %al
c0104f93:	0f b6 c0             	movzbl %al,%eax
c0104f96:	85 c0                	test   %eax,%eax
c0104f98:	74 24                	je     c0104fbe <default_check+0x166>
c0104f9a:	c7 44 24 0c d2 6f 10 	movl   $0xc0106fd2,0xc(%esp)
c0104fa1:	c0 
c0104fa2:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0104fa9:	c0 
c0104faa:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104fb1:	00 
c0104fb2:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0104fb9:	e8 2b b4 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104fbe:	a1 1c bf 11 c0       	mov    0xc011bf1c,%eax
c0104fc3:	8b 15 20 bf 11 c0    	mov    0xc011bf20,%edx
c0104fc9:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104fcc:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104fcf:	c7 45 b0 1c bf 11 c0 	movl   $0xc011bf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104fd6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104fd9:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104fdc:	89 50 04             	mov    %edx,0x4(%eax)
c0104fdf:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104fe2:	8b 50 04             	mov    0x4(%eax),%edx
c0104fe5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104fe8:	89 10                	mov    %edx,(%eax)
c0104fea:	c7 45 b4 1c bf 11 c0 	movl   $0xc011bf1c,-0x4c(%ebp)
    return list->next == list;
c0104ff1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104ff4:	8b 40 04             	mov    0x4(%eax),%eax
c0104ff7:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104ffa:	0f 94 c0             	sete   %al
c0104ffd:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105000:	85 c0                	test   %eax,%eax
c0105002:	75 24                	jne    c0105028 <default_check+0x1d0>
c0105004:	c7 44 24 0c 27 6f 10 	movl   $0xc0106f27,0xc(%esp)
c010500b:	c0 
c010500c:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105013:	c0 
c0105014:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c010501b:	00 
c010501c:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105023:	e8 c1 b3 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105028:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010502f:	e8 ac db ff ff       	call   c0102be0 <alloc_pages>
c0105034:	85 c0                	test   %eax,%eax
c0105036:	74 24                	je     c010505c <default_check+0x204>
c0105038:	c7 44 24 0c 3e 6f 10 	movl   $0xc0106f3e,0xc(%esp)
c010503f:	c0 
c0105040:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105047:	c0 
c0105048:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c010504f:	00 
c0105050:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105057:	e8 8d b3 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c010505c:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0105061:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0105064:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c010506b:	00 00 00 

    free_pages(p0 + 2, 3);
c010506e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105071:	83 c0 28             	add    $0x28,%eax
c0105074:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010507b:	00 
c010507c:	89 04 24             	mov    %eax,(%esp)
c010507f:	e8 94 db ff ff       	call   c0102c18 <free_pages>
    assert(alloc_pages(4) == NULL);
c0105084:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010508b:	e8 50 db ff ff       	call   c0102be0 <alloc_pages>
c0105090:	85 c0                	test   %eax,%eax
c0105092:	74 24                	je     c01050b8 <default_check+0x260>
c0105094:	c7 44 24 0c e4 6f 10 	movl   $0xc0106fe4,0xc(%esp)
c010509b:	c0 
c010509c:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01050a3:	c0 
c01050a4:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c01050ab:	00 
c01050ac:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01050b3:	e8 31 b3 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01050b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050bb:	83 c0 28             	add    $0x28,%eax
c01050be:	83 c0 04             	add    $0x4,%eax
c01050c1:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01050c8:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01050cb:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01050ce:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01050d1:	0f a3 10             	bt     %edx,(%eax)
c01050d4:	19 c0                	sbb    %eax,%eax
c01050d6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01050d9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01050dd:	0f 95 c0             	setne  %al
c01050e0:	0f b6 c0             	movzbl %al,%eax
c01050e3:	85 c0                	test   %eax,%eax
c01050e5:	74 0e                	je     c01050f5 <default_check+0x29d>
c01050e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050ea:	83 c0 28             	add    $0x28,%eax
c01050ed:	8b 40 08             	mov    0x8(%eax),%eax
c01050f0:	83 f8 03             	cmp    $0x3,%eax
c01050f3:	74 24                	je     c0105119 <default_check+0x2c1>
c01050f5:	c7 44 24 0c fc 6f 10 	movl   $0xc0106ffc,0xc(%esp)
c01050fc:	c0 
c01050fd:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105104:	c0 
c0105105:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c010510c:	00 
c010510d:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105114:	e8 d0 b2 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105119:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105120:	e8 bb da ff ff       	call   c0102be0 <alloc_pages>
c0105125:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105128:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010512c:	75 24                	jne    c0105152 <default_check+0x2fa>
c010512e:	c7 44 24 0c 28 70 10 	movl   $0xc0107028,0xc(%esp)
c0105135:	c0 
c0105136:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c010513d:	c0 
c010513e:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0105145:	00 
c0105146:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c010514d:	e8 97 b2 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105152:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105159:	e8 82 da ff ff       	call   c0102be0 <alloc_pages>
c010515e:	85 c0                	test   %eax,%eax
c0105160:	74 24                	je     c0105186 <default_check+0x32e>
c0105162:	c7 44 24 0c 3e 6f 10 	movl   $0xc0106f3e,0xc(%esp)
c0105169:	c0 
c010516a:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105171:	c0 
c0105172:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0105179:	00 
c010517a:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105181:	e8 63 b2 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c0105186:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105189:	83 c0 28             	add    $0x28,%eax
c010518c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010518f:	74 24                	je     c01051b5 <default_check+0x35d>
c0105191:	c7 44 24 0c 46 70 10 	movl   $0xc0107046,0xc(%esp)
c0105198:	c0 
c0105199:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01051a0:	c0 
c01051a1:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01051a8:	00 
c01051a9:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01051b0:	e8 34 b2 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c01051b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051b8:	83 c0 14             	add    $0x14,%eax
c01051bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01051be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051c5:	00 
c01051c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051c9:	89 04 24             	mov    %eax,(%esp)
c01051cc:	e8 47 da ff ff       	call   c0102c18 <free_pages>
    free_pages(p1, 3);
c01051d1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01051d8:	00 
c01051d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051dc:	89 04 24             	mov    %eax,(%esp)
c01051df:	e8 34 da ff ff       	call   c0102c18 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01051e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051e7:	83 c0 04             	add    $0x4,%eax
c01051ea:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01051f1:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01051f4:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01051f7:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01051fa:	0f a3 10             	bt     %edx,(%eax)
c01051fd:	19 c0                	sbb    %eax,%eax
c01051ff:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105202:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105206:	0f 95 c0             	setne  %al
c0105209:	0f b6 c0             	movzbl %al,%eax
c010520c:	85 c0                	test   %eax,%eax
c010520e:	74 0b                	je     c010521b <default_check+0x3c3>
c0105210:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105213:	8b 40 08             	mov    0x8(%eax),%eax
c0105216:	83 f8 01             	cmp    $0x1,%eax
c0105219:	74 24                	je     c010523f <default_check+0x3e7>
c010521b:	c7 44 24 0c 54 70 10 	movl   $0xc0107054,0xc(%esp)
c0105222:	c0 
c0105223:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c010522a:	c0 
c010522b:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105232:	00 
c0105233:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c010523a:	e8 aa b1 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010523f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105242:	83 c0 04             	add    $0x4,%eax
c0105245:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010524c:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010524f:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105252:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105255:	0f a3 10             	bt     %edx,(%eax)
c0105258:	19 c0                	sbb    %eax,%eax
c010525a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010525d:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105261:	0f 95 c0             	setne  %al
c0105264:	0f b6 c0             	movzbl %al,%eax
c0105267:	85 c0                	test   %eax,%eax
c0105269:	74 0b                	je     c0105276 <default_check+0x41e>
c010526b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010526e:	8b 40 08             	mov    0x8(%eax),%eax
c0105271:	83 f8 03             	cmp    $0x3,%eax
c0105274:	74 24                	je     c010529a <default_check+0x442>
c0105276:	c7 44 24 0c 7c 70 10 	movl   $0xc010707c,0xc(%esp)
c010527d:	c0 
c010527e:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105285:	c0 
c0105286:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c010528d:	00 
c010528e:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105295:	e8 4f b1 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010529a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052a1:	e8 3a d9 ff ff       	call   c0102be0 <alloc_pages>
c01052a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01052a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052ac:	83 e8 14             	sub    $0x14,%eax
c01052af:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01052b2:	74 24                	je     c01052d8 <default_check+0x480>
c01052b4:	c7 44 24 0c a2 70 10 	movl   $0xc01070a2,0xc(%esp)
c01052bb:	c0 
c01052bc:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01052c3:	c0 
c01052c4:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01052cb:	00 
c01052cc:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01052d3:	e8 11 b1 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c01052d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052df:	00 
c01052e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052e3:	89 04 24             	mov    %eax,(%esp)
c01052e6:	e8 2d d9 ff ff       	call   c0102c18 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01052eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01052f2:	e8 e9 d8 ff ff       	call   c0102be0 <alloc_pages>
c01052f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01052fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052fd:	83 c0 14             	add    $0x14,%eax
c0105300:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105303:	74 24                	je     c0105329 <default_check+0x4d1>
c0105305:	c7 44 24 0c c0 70 10 	movl   $0xc01070c0,0xc(%esp)
c010530c:	c0 
c010530d:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105314:	c0 
c0105315:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c010531c:	00 
c010531d:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105324:	e8 c0 b0 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c0105329:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105330:	00 
c0105331:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105334:	89 04 24             	mov    %eax,(%esp)
c0105337:	e8 dc d8 ff ff       	call   c0102c18 <free_pages>
    free_page(p2);
c010533c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105343:	00 
c0105344:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105347:	89 04 24             	mov    %eax,(%esp)
c010534a:	e8 c9 d8 ff ff       	call   c0102c18 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010534f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105356:	e8 85 d8 ff ff       	call   c0102be0 <alloc_pages>
c010535b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010535e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105362:	75 24                	jne    c0105388 <default_check+0x530>
c0105364:	c7 44 24 0c e0 70 10 	movl   $0xc01070e0,0xc(%esp)
c010536b:	c0 
c010536c:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105373:	c0 
c0105374:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c010537b:	00 
c010537c:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105383:	e8 61 b0 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105388:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010538f:	e8 4c d8 ff ff       	call   c0102be0 <alloc_pages>
c0105394:	85 c0                	test   %eax,%eax
c0105396:	74 24                	je     c01053bc <default_check+0x564>
c0105398:	c7 44 24 0c 3e 6f 10 	movl   $0xc0106f3e,0xc(%esp)
c010539f:	c0 
c01053a0:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01053a7:	c0 
c01053a8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c01053af:	00 
c01053b0:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01053b7:	e8 2d b0 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c01053bc:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c01053c1:	85 c0                	test   %eax,%eax
c01053c3:	74 24                	je     c01053e9 <default_check+0x591>
c01053c5:	c7 44 24 0c 91 6f 10 	movl   $0xc0106f91,0xc(%esp)
c01053cc:	c0 
c01053cd:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01053d4:	c0 
c01053d5:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01053dc:	00 
c01053dd:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01053e4:	e8 00 b0 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c01053e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053ec:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24

    free_list = free_list_store;
c01053f1:	8b 45 80             	mov    -0x80(%ebp),%eax
c01053f4:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01053f7:	a3 1c bf 11 c0       	mov    %eax,0xc011bf1c
c01053fc:	89 15 20 bf 11 c0    	mov    %edx,0xc011bf20
    free_pages(p0, 5);
c0105402:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105409:	00 
c010540a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010540d:	89 04 24             	mov    %eax,(%esp)
c0105410:	e8 03 d8 ff ff       	call   c0102c18 <free_pages>

    le = &free_list;
c0105415:	c7 45 ec 1c bf 11 c0 	movl   $0xc011bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010541c:	eb 5a                	jmp    c0105478 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c010541e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105421:	8b 40 04             	mov    0x4(%eax),%eax
c0105424:	8b 00                	mov    (%eax),%eax
c0105426:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105429:	75 0d                	jne    c0105438 <default_check+0x5e0>
c010542b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010542e:	8b 00                	mov    (%eax),%eax
c0105430:	8b 40 04             	mov    0x4(%eax),%eax
c0105433:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105436:	74 24                	je     c010545c <default_check+0x604>
c0105438:	c7 44 24 0c 00 71 10 	movl   $0xc0107100,0xc(%esp)
c010543f:	c0 
c0105440:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c0105447:	c0 
c0105448:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c010544f:	00 
c0105450:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c0105457:	e8 8d af ff ff       	call   c01003e9 <__panic>
        struct Page *p = le2page(le, page_link);
c010545c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010545f:	83 e8 0c             	sub    $0xc,%eax
c0105462:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105465:	ff 4d f4             	decl   -0xc(%ebp)
c0105468:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010546b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010546e:	8b 40 08             	mov    0x8(%eax),%eax
c0105471:	29 c2                	sub    %eax,%edx
c0105473:	89 d0                	mov    %edx,%eax
c0105475:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105478:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010547b:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010547e:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105481:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105484:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105487:	81 7d ec 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x14(%ebp)
c010548e:	75 8e                	jne    c010541e <default_check+0x5c6>
    }
    assert(count == 0);
c0105490:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105494:	74 24                	je     c01054ba <default_check+0x662>
c0105496:	c7 44 24 0c 2d 71 10 	movl   $0xc010712d,0xc(%esp)
c010549d:	c0 
c010549e:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01054a5:	c0 
c01054a6:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c01054ad:	00 
c01054ae:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01054b5:	e8 2f af ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c01054ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01054be:	74 24                	je     c01054e4 <default_check+0x68c>
c01054c0:	c7 44 24 0c 38 71 10 	movl   $0xc0107138,0xc(%esp)
c01054c7:	c0 
c01054c8:	c7 44 24 08 9e 6d 10 	movl   $0xc0106d9e,0x8(%esp)
c01054cf:	c0 
c01054d0:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01054d7:	00 
c01054d8:	c7 04 24 b3 6d 10 c0 	movl   $0xc0106db3,(%esp)
c01054df:	e8 05 af ff ff       	call   c01003e9 <__panic>
}
c01054e4:	90                   	nop
c01054e5:	c9                   	leave  
c01054e6:	c3                   	ret    

c01054e7 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01054e7:	55                   	push   %ebp
c01054e8:	89 e5                	mov    %esp,%ebp
c01054ea:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01054ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01054f4:	eb 03                	jmp    c01054f9 <strlen+0x12>
        cnt ++;
c01054f6:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01054f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01054fc:	8d 50 01             	lea    0x1(%eax),%edx
c01054ff:	89 55 08             	mov    %edx,0x8(%ebp)
c0105502:	0f b6 00             	movzbl (%eax),%eax
c0105505:	84 c0                	test   %al,%al
c0105507:	75 ed                	jne    c01054f6 <strlen+0xf>
    }
    return cnt;
c0105509:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010550c:	c9                   	leave  
c010550d:	c3                   	ret    

c010550e <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010550e:	55                   	push   %ebp
c010550f:	89 e5                	mov    %esp,%ebp
c0105511:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105514:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010551b:	eb 03                	jmp    c0105520 <strnlen+0x12>
        cnt ++;
c010551d:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105520:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105523:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105526:	73 10                	jae    c0105538 <strnlen+0x2a>
c0105528:	8b 45 08             	mov    0x8(%ebp),%eax
c010552b:	8d 50 01             	lea    0x1(%eax),%edx
c010552e:	89 55 08             	mov    %edx,0x8(%ebp)
c0105531:	0f b6 00             	movzbl (%eax),%eax
c0105534:	84 c0                	test   %al,%al
c0105536:	75 e5                	jne    c010551d <strnlen+0xf>
    }
    return cnt;
c0105538:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010553b:	c9                   	leave  
c010553c:	c3                   	ret    

c010553d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010553d:	55                   	push   %ebp
c010553e:	89 e5                	mov    %esp,%ebp
c0105540:	57                   	push   %edi
c0105541:	56                   	push   %esi
c0105542:	83 ec 20             	sub    $0x20,%esp
c0105545:	8b 45 08             	mov    0x8(%ebp),%eax
c0105548:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010554b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010554e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105551:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105554:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105557:	89 d1                	mov    %edx,%ecx
c0105559:	89 c2                	mov    %eax,%edx
c010555b:	89 ce                	mov    %ecx,%esi
c010555d:	89 d7                	mov    %edx,%edi
c010555f:	ac                   	lods   %ds:(%esi),%al
c0105560:	aa                   	stos   %al,%es:(%edi)
c0105561:	84 c0                	test   %al,%al
c0105563:	75 fa                	jne    c010555f <strcpy+0x22>
c0105565:	89 fa                	mov    %edi,%edx
c0105567:	89 f1                	mov    %esi,%ecx
c0105569:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010556c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010556f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105572:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0105575:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105576:	83 c4 20             	add    $0x20,%esp
c0105579:	5e                   	pop    %esi
c010557a:	5f                   	pop    %edi
c010557b:	5d                   	pop    %ebp
c010557c:	c3                   	ret    

c010557d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010557d:	55                   	push   %ebp
c010557e:	89 e5                	mov    %esp,%ebp
c0105580:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105583:	8b 45 08             	mov    0x8(%ebp),%eax
c0105586:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105589:	eb 1e                	jmp    c01055a9 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010558b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010558e:	0f b6 10             	movzbl (%eax),%edx
c0105591:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105594:	88 10                	mov    %dl,(%eax)
c0105596:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105599:	0f b6 00             	movzbl (%eax),%eax
c010559c:	84 c0                	test   %al,%al
c010559e:	74 03                	je     c01055a3 <strncpy+0x26>
            src ++;
c01055a0:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01055a3:	ff 45 fc             	incl   -0x4(%ebp)
c01055a6:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c01055a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055ad:	75 dc                	jne    c010558b <strncpy+0xe>
    }
    return dst;
c01055af:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01055b2:	c9                   	leave  
c01055b3:	c3                   	ret    

c01055b4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01055b4:	55                   	push   %ebp
c01055b5:	89 e5                	mov    %esp,%ebp
c01055b7:	57                   	push   %edi
c01055b8:	56                   	push   %esi
c01055b9:	83 ec 20             	sub    $0x20,%esp
c01055bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01055bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01055c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01055c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01055cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055ce:	89 d1                	mov    %edx,%ecx
c01055d0:	89 c2                	mov    %eax,%edx
c01055d2:	89 ce                	mov    %ecx,%esi
c01055d4:	89 d7                	mov    %edx,%edi
c01055d6:	ac                   	lods   %ds:(%esi),%al
c01055d7:	ae                   	scas   %es:(%edi),%al
c01055d8:	75 08                	jne    c01055e2 <strcmp+0x2e>
c01055da:	84 c0                	test   %al,%al
c01055dc:	75 f8                	jne    c01055d6 <strcmp+0x22>
c01055de:	31 c0                	xor    %eax,%eax
c01055e0:	eb 04                	jmp    c01055e6 <strcmp+0x32>
c01055e2:	19 c0                	sbb    %eax,%eax
c01055e4:	0c 01                	or     $0x1,%al
c01055e6:	89 fa                	mov    %edi,%edx
c01055e8:	89 f1                	mov    %esi,%ecx
c01055ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055ed:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01055f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01055f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01055f6:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01055f7:	83 c4 20             	add    $0x20,%esp
c01055fa:	5e                   	pop    %esi
c01055fb:	5f                   	pop    %edi
c01055fc:	5d                   	pop    %ebp
c01055fd:	c3                   	ret    

c01055fe <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01055fe:	55                   	push   %ebp
c01055ff:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105601:	eb 09                	jmp    c010560c <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105603:	ff 4d 10             	decl   0x10(%ebp)
c0105606:	ff 45 08             	incl   0x8(%ebp)
c0105609:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010560c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105610:	74 1a                	je     c010562c <strncmp+0x2e>
c0105612:	8b 45 08             	mov    0x8(%ebp),%eax
c0105615:	0f b6 00             	movzbl (%eax),%eax
c0105618:	84 c0                	test   %al,%al
c010561a:	74 10                	je     c010562c <strncmp+0x2e>
c010561c:	8b 45 08             	mov    0x8(%ebp),%eax
c010561f:	0f b6 10             	movzbl (%eax),%edx
c0105622:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105625:	0f b6 00             	movzbl (%eax),%eax
c0105628:	38 c2                	cmp    %al,%dl
c010562a:	74 d7                	je     c0105603 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010562c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105630:	74 18                	je     c010564a <strncmp+0x4c>
c0105632:	8b 45 08             	mov    0x8(%ebp),%eax
c0105635:	0f b6 00             	movzbl (%eax),%eax
c0105638:	0f b6 d0             	movzbl %al,%edx
c010563b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010563e:	0f b6 00             	movzbl (%eax),%eax
c0105641:	0f b6 c0             	movzbl %al,%eax
c0105644:	29 c2                	sub    %eax,%edx
c0105646:	89 d0                	mov    %edx,%eax
c0105648:	eb 05                	jmp    c010564f <strncmp+0x51>
c010564a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010564f:	5d                   	pop    %ebp
c0105650:	c3                   	ret    

c0105651 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105651:	55                   	push   %ebp
c0105652:	89 e5                	mov    %esp,%ebp
c0105654:	83 ec 04             	sub    $0x4,%esp
c0105657:	8b 45 0c             	mov    0xc(%ebp),%eax
c010565a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010565d:	eb 13                	jmp    c0105672 <strchr+0x21>
        if (*s == c) {
c010565f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105662:	0f b6 00             	movzbl (%eax),%eax
c0105665:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105668:	75 05                	jne    c010566f <strchr+0x1e>
            return (char *)s;
c010566a:	8b 45 08             	mov    0x8(%ebp),%eax
c010566d:	eb 12                	jmp    c0105681 <strchr+0x30>
        }
        s ++;
c010566f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105672:	8b 45 08             	mov    0x8(%ebp),%eax
c0105675:	0f b6 00             	movzbl (%eax),%eax
c0105678:	84 c0                	test   %al,%al
c010567a:	75 e3                	jne    c010565f <strchr+0xe>
    }
    return NULL;
c010567c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105681:	c9                   	leave  
c0105682:	c3                   	ret    

c0105683 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105683:	55                   	push   %ebp
c0105684:	89 e5                	mov    %esp,%ebp
c0105686:	83 ec 04             	sub    $0x4,%esp
c0105689:	8b 45 0c             	mov    0xc(%ebp),%eax
c010568c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010568f:	eb 0e                	jmp    c010569f <strfind+0x1c>
        if (*s == c) {
c0105691:	8b 45 08             	mov    0x8(%ebp),%eax
c0105694:	0f b6 00             	movzbl (%eax),%eax
c0105697:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010569a:	74 0f                	je     c01056ab <strfind+0x28>
            break;
        }
        s ++;
c010569c:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010569f:	8b 45 08             	mov    0x8(%ebp),%eax
c01056a2:	0f b6 00             	movzbl (%eax),%eax
c01056a5:	84 c0                	test   %al,%al
c01056a7:	75 e8                	jne    c0105691 <strfind+0xe>
c01056a9:	eb 01                	jmp    c01056ac <strfind+0x29>
            break;
c01056ab:	90                   	nop
    }
    return (char *)s;
c01056ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01056af:	c9                   	leave  
c01056b0:	c3                   	ret    

c01056b1 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01056b1:	55                   	push   %ebp
c01056b2:	89 e5                	mov    %esp,%ebp
c01056b4:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01056b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01056be:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01056c5:	eb 03                	jmp    c01056ca <strtol+0x19>
        s ++;
c01056c7:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01056ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01056cd:	0f b6 00             	movzbl (%eax),%eax
c01056d0:	3c 20                	cmp    $0x20,%al
c01056d2:	74 f3                	je     c01056c7 <strtol+0x16>
c01056d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01056d7:	0f b6 00             	movzbl (%eax),%eax
c01056da:	3c 09                	cmp    $0x9,%al
c01056dc:	74 e9                	je     c01056c7 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01056de:	8b 45 08             	mov    0x8(%ebp),%eax
c01056e1:	0f b6 00             	movzbl (%eax),%eax
c01056e4:	3c 2b                	cmp    $0x2b,%al
c01056e6:	75 05                	jne    c01056ed <strtol+0x3c>
        s ++;
c01056e8:	ff 45 08             	incl   0x8(%ebp)
c01056eb:	eb 14                	jmp    c0105701 <strtol+0x50>
    }
    else if (*s == '-') {
c01056ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01056f0:	0f b6 00             	movzbl (%eax),%eax
c01056f3:	3c 2d                	cmp    $0x2d,%al
c01056f5:	75 0a                	jne    c0105701 <strtol+0x50>
        s ++, neg = 1;
c01056f7:	ff 45 08             	incl   0x8(%ebp)
c01056fa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105701:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105705:	74 06                	je     c010570d <strtol+0x5c>
c0105707:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010570b:	75 22                	jne    c010572f <strtol+0x7e>
c010570d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105710:	0f b6 00             	movzbl (%eax),%eax
c0105713:	3c 30                	cmp    $0x30,%al
c0105715:	75 18                	jne    c010572f <strtol+0x7e>
c0105717:	8b 45 08             	mov    0x8(%ebp),%eax
c010571a:	40                   	inc    %eax
c010571b:	0f b6 00             	movzbl (%eax),%eax
c010571e:	3c 78                	cmp    $0x78,%al
c0105720:	75 0d                	jne    c010572f <strtol+0x7e>
        s += 2, base = 16;
c0105722:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105726:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010572d:	eb 29                	jmp    c0105758 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010572f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105733:	75 16                	jne    c010574b <strtol+0x9a>
c0105735:	8b 45 08             	mov    0x8(%ebp),%eax
c0105738:	0f b6 00             	movzbl (%eax),%eax
c010573b:	3c 30                	cmp    $0x30,%al
c010573d:	75 0c                	jne    c010574b <strtol+0x9a>
        s ++, base = 8;
c010573f:	ff 45 08             	incl   0x8(%ebp)
c0105742:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105749:	eb 0d                	jmp    c0105758 <strtol+0xa7>
    }
    else if (base == 0) {
c010574b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010574f:	75 07                	jne    c0105758 <strtol+0xa7>
        base = 10;
c0105751:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105758:	8b 45 08             	mov    0x8(%ebp),%eax
c010575b:	0f b6 00             	movzbl (%eax),%eax
c010575e:	3c 2f                	cmp    $0x2f,%al
c0105760:	7e 1b                	jle    c010577d <strtol+0xcc>
c0105762:	8b 45 08             	mov    0x8(%ebp),%eax
c0105765:	0f b6 00             	movzbl (%eax),%eax
c0105768:	3c 39                	cmp    $0x39,%al
c010576a:	7f 11                	jg     c010577d <strtol+0xcc>
            dig = *s - '0';
c010576c:	8b 45 08             	mov    0x8(%ebp),%eax
c010576f:	0f b6 00             	movzbl (%eax),%eax
c0105772:	0f be c0             	movsbl %al,%eax
c0105775:	83 e8 30             	sub    $0x30,%eax
c0105778:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010577b:	eb 48                	jmp    c01057c5 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010577d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105780:	0f b6 00             	movzbl (%eax),%eax
c0105783:	3c 60                	cmp    $0x60,%al
c0105785:	7e 1b                	jle    c01057a2 <strtol+0xf1>
c0105787:	8b 45 08             	mov    0x8(%ebp),%eax
c010578a:	0f b6 00             	movzbl (%eax),%eax
c010578d:	3c 7a                	cmp    $0x7a,%al
c010578f:	7f 11                	jg     c01057a2 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105791:	8b 45 08             	mov    0x8(%ebp),%eax
c0105794:	0f b6 00             	movzbl (%eax),%eax
c0105797:	0f be c0             	movsbl %al,%eax
c010579a:	83 e8 57             	sub    $0x57,%eax
c010579d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01057a0:	eb 23                	jmp    c01057c5 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01057a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a5:	0f b6 00             	movzbl (%eax),%eax
c01057a8:	3c 40                	cmp    $0x40,%al
c01057aa:	7e 3b                	jle    c01057e7 <strtol+0x136>
c01057ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01057af:	0f b6 00             	movzbl (%eax),%eax
c01057b2:	3c 5a                	cmp    $0x5a,%al
c01057b4:	7f 31                	jg     c01057e7 <strtol+0x136>
            dig = *s - 'A' + 10;
c01057b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b9:	0f b6 00             	movzbl (%eax),%eax
c01057bc:	0f be c0             	movsbl %al,%eax
c01057bf:	83 e8 37             	sub    $0x37,%eax
c01057c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01057c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057c8:	3b 45 10             	cmp    0x10(%ebp),%eax
c01057cb:	7d 19                	jge    c01057e6 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01057cd:	ff 45 08             	incl   0x8(%ebp)
c01057d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01057d3:	0f af 45 10          	imul   0x10(%ebp),%eax
c01057d7:	89 c2                	mov    %eax,%edx
c01057d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057dc:	01 d0                	add    %edx,%eax
c01057de:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01057e1:	e9 72 ff ff ff       	jmp    c0105758 <strtol+0xa7>
            break;
c01057e6:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01057e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01057eb:	74 08                	je     c01057f5 <strtol+0x144>
        *endptr = (char *) s;
c01057ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01057f3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01057f5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01057f9:	74 07                	je     c0105802 <strtol+0x151>
c01057fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01057fe:	f7 d8                	neg    %eax
c0105800:	eb 03                	jmp    c0105805 <strtol+0x154>
c0105802:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105805:	c9                   	leave  
c0105806:	c3                   	ret    

c0105807 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105807:	55                   	push   %ebp
c0105808:	89 e5                	mov    %esp,%ebp
c010580a:	57                   	push   %edi
c010580b:	83 ec 24             	sub    $0x24,%esp
c010580e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105811:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105814:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105818:	8b 55 08             	mov    0x8(%ebp),%edx
c010581b:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010581e:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105821:	8b 45 10             	mov    0x10(%ebp),%eax
c0105824:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105827:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010582a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010582e:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105831:	89 d7                	mov    %edx,%edi
c0105833:	f3 aa                	rep stos %al,%es:(%edi)
c0105835:	89 fa                	mov    %edi,%edx
c0105837:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010583a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010583d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105840:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105841:	83 c4 24             	add    $0x24,%esp
c0105844:	5f                   	pop    %edi
c0105845:	5d                   	pop    %ebp
c0105846:	c3                   	ret    

c0105847 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105847:	55                   	push   %ebp
c0105848:	89 e5                	mov    %esp,%ebp
c010584a:	57                   	push   %edi
c010584b:	56                   	push   %esi
c010584c:	53                   	push   %ebx
c010584d:	83 ec 30             	sub    $0x30,%esp
c0105850:	8b 45 08             	mov    0x8(%ebp),%eax
c0105853:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105856:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105859:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010585c:	8b 45 10             	mov    0x10(%ebp),%eax
c010585f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105862:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105865:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105868:	73 42                	jae    c01058ac <memmove+0x65>
c010586a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010586d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105870:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105873:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105876:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105879:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010587c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010587f:	c1 e8 02             	shr    $0x2,%eax
c0105882:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105884:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105887:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010588a:	89 d7                	mov    %edx,%edi
c010588c:	89 c6                	mov    %eax,%esi
c010588e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105890:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105893:	83 e1 03             	and    $0x3,%ecx
c0105896:	74 02                	je     c010589a <memmove+0x53>
c0105898:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010589a:	89 f0                	mov    %esi,%eax
c010589c:	89 fa                	mov    %edi,%edx
c010589e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01058a1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01058a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01058a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01058aa:	eb 36                	jmp    c01058e2 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01058ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058af:	8d 50 ff             	lea    -0x1(%eax),%edx
c01058b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058b5:	01 c2                	add    %eax,%edx
c01058b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058ba:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01058c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058c6:	89 c1                	mov    %eax,%ecx
c01058c8:	89 d8                	mov    %ebx,%eax
c01058ca:	89 d6                	mov    %edx,%esi
c01058cc:	89 c7                	mov    %eax,%edi
c01058ce:	fd                   	std    
c01058cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01058d1:	fc                   	cld    
c01058d2:	89 f8                	mov    %edi,%eax
c01058d4:	89 f2                	mov    %esi,%edx
c01058d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01058d9:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01058dc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01058df:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01058e2:	83 c4 30             	add    $0x30,%esp
c01058e5:	5b                   	pop    %ebx
c01058e6:	5e                   	pop    %esi
c01058e7:	5f                   	pop    %edi
c01058e8:	5d                   	pop    %ebp
c01058e9:	c3                   	ret    

c01058ea <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01058ea:	55                   	push   %ebp
c01058eb:	89 e5                	mov    %esp,%ebp
c01058ed:	57                   	push   %edi
c01058ee:	56                   	push   %esi
c01058ef:	83 ec 20             	sub    $0x20,%esp
c01058f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01058f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0105901:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105904:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105907:	c1 e8 02             	shr    $0x2,%eax
c010590a:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010590c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010590f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105912:	89 d7                	mov    %edx,%edi
c0105914:	89 c6                	mov    %eax,%esi
c0105916:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105918:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010591b:	83 e1 03             	and    $0x3,%ecx
c010591e:	74 02                	je     c0105922 <memcpy+0x38>
c0105920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105922:	89 f0                	mov    %esi,%eax
c0105924:	89 fa                	mov    %edi,%edx
c0105926:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105929:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010592c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010592f:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105932:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105933:	83 c4 20             	add    $0x20,%esp
c0105936:	5e                   	pop    %esi
c0105937:	5f                   	pop    %edi
c0105938:	5d                   	pop    %ebp
c0105939:	c3                   	ret    

c010593a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010593a:	55                   	push   %ebp
c010593b:	89 e5                	mov    %esp,%ebp
c010593d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105940:	8b 45 08             	mov    0x8(%ebp),%eax
c0105943:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105946:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105949:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010594c:	eb 2e                	jmp    c010597c <memcmp+0x42>
        if (*s1 != *s2) {
c010594e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105951:	0f b6 10             	movzbl (%eax),%edx
c0105954:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105957:	0f b6 00             	movzbl (%eax),%eax
c010595a:	38 c2                	cmp    %al,%dl
c010595c:	74 18                	je     c0105976 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010595e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105961:	0f b6 00             	movzbl (%eax),%eax
c0105964:	0f b6 d0             	movzbl %al,%edx
c0105967:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010596a:	0f b6 00             	movzbl (%eax),%eax
c010596d:	0f b6 c0             	movzbl %al,%eax
c0105970:	29 c2                	sub    %eax,%edx
c0105972:	89 d0                	mov    %edx,%eax
c0105974:	eb 18                	jmp    c010598e <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105976:	ff 45 fc             	incl   -0x4(%ebp)
c0105979:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010597c:	8b 45 10             	mov    0x10(%ebp),%eax
c010597f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105982:	89 55 10             	mov    %edx,0x10(%ebp)
c0105985:	85 c0                	test   %eax,%eax
c0105987:	75 c5                	jne    c010594e <memcmp+0x14>
    }
    return 0;
c0105989:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010598e:	c9                   	leave  
c010598f:	c3                   	ret    

c0105990 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105990:	55                   	push   %ebp
c0105991:	89 e5                	mov    %esp,%ebp
c0105993:	83 ec 58             	sub    $0x58,%esp
c0105996:	8b 45 10             	mov    0x10(%ebp),%eax
c0105999:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010599c:	8b 45 14             	mov    0x14(%ebp),%eax
c010599f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01059a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01059a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01059a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01059ab:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01059ae:	8b 45 18             	mov    0x18(%ebp),%eax
c01059b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01059b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01059ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01059bd:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01059c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01059ca:	74 1c                	je     c01059e8 <printnum+0x58>
c01059cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059cf:	ba 00 00 00 00       	mov    $0x0,%edx
c01059d4:	f7 75 e4             	divl   -0x1c(%ebp)
c01059d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01059da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059dd:	ba 00 00 00 00       	mov    $0x0,%edx
c01059e2:	f7 75 e4             	divl   -0x1c(%ebp)
c01059e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059ee:	f7 75 e4             	divl   -0x1c(%ebp)
c01059f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01059f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01059f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01059fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a00:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105a03:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a06:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105a09:	8b 45 18             	mov    0x18(%ebp),%eax
c0105a0c:	ba 00 00 00 00       	mov    $0x0,%edx
c0105a11:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105a14:	72 56                	jb     c0105a6c <printnum+0xdc>
c0105a16:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105a19:	77 05                	ja     c0105a20 <printnum+0x90>
c0105a1b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105a1e:	72 4c                	jb     c0105a6c <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105a20:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105a23:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a26:	8b 45 20             	mov    0x20(%ebp),%eax
c0105a29:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105a2d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105a31:	8b 45 18             	mov    0x18(%ebp),%eax
c0105a34:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105a38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a3e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a42:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105a46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a50:	89 04 24             	mov    %eax,(%esp)
c0105a53:	e8 38 ff ff ff       	call   c0105990 <printnum>
c0105a58:	eb 1b                	jmp    c0105a75 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a61:	8b 45 20             	mov    0x20(%ebp),%eax
c0105a64:	89 04 24             	mov    %eax,(%esp)
c0105a67:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a6a:	ff d0                	call   *%eax
        while (-- width > 0)
c0105a6c:	ff 4d 1c             	decl   0x1c(%ebp)
c0105a6f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105a73:	7f e5                	jg     c0105a5a <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105a75:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105a78:	05 f4 71 10 c0       	add    $0xc01071f4,%eax
c0105a7d:	0f b6 00             	movzbl (%eax),%eax
c0105a80:	0f be c0             	movsbl %al,%eax
c0105a83:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a86:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a8a:	89 04 24             	mov    %eax,(%esp)
c0105a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a90:	ff d0                	call   *%eax
}
c0105a92:	90                   	nop
c0105a93:	c9                   	leave  
c0105a94:	c3                   	ret    

c0105a95 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105a95:	55                   	push   %ebp
c0105a96:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105a98:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105a9c:	7e 14                	jle    c0105ab2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa1:	8b 00                	mov    (%eax),%eax
c0105aa3:	8d 48 08             	lea    0x8(%eax),%ecx
c0105aa6:	8b 55 08             	mov    0x8(%ebp),%edx
c0105aa9:	89 0a                	mov    %ecx,(%edx)
c0105aab:	8b 50 04             	mov    0x4(%eax),%edx
c0105aae:	8b 00                	mov    (%eax),%eax
c0105ab0:	eb 30                	jmp    c0105ae2 <getuint+0x4d>
    }
    else if (lflag) {
c0105ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ab6:	74 16                	je     c0105ace <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105ab8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105abb:	8b 00                	mov    (%eax),%eax
c0105abd:	8d 48 04             	lea    0x4(%eax),%ecx
c0105ac0:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ac3:	89 0a                	mov    %ecx,(%edx)
c0105ac5:	8b 00                	mov    (%eax),%eax
c0105ac7:	ba 00 00 00 00       	mov    $0x0,%edx
c0105acc:	eb 14                	jmp    c0105ae2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105ace:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad1:	8b 00                	mov    (%eax),%eax
c0105ad3:	8d 48 04             	lea    0x4(%eax),%ecx
c0105ad6:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ad9:	89 0a                	mov    %ecx,(%edx)
c0105adb:	8b 00                	mov    (%eax),%eax
c0105add:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105ae2:	5d                   	pop    %ebp
c0105ae3:	c3                   	ret    

c0105ae4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105ae4:	55                   	push   %ebp
c0105ae5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105ae7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105aeb:	7e 14                	jle    c0105b01 <getint+0x1d>
        return va_arg(*ap, long long);
c0105aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0105af0:	8b 00                	mov    (%eax),%eax
c0105af2:	8d 48 08             	lea    0x8(%eax),%ecx
c0105af5:	8b 55 08             	mov    0x8(%ebp),%edx
c0105af8:	89 0a                	mov    %ecx,(%edx)
c0105afa:	8b 50 04             	mov    0x4(%eax),%edx
c0105afd:	8b 00                	mov    (%eax),%eax
c0105aff:	eb 28                	jmp    c0105b29 <getint+0x45>
    }
    else if (lflag) {
c0105b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b05:	74 12                	je     c0105b19 <getint+0x35>
        return va_arg(*ap, long);
c0105b07:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0a:	8b 00                	mov    (%eax),%eax
c0105b0c:	8d 48 04             	lea    0x4(%eax),%ecx
c0105b0f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b12:	89 0a                	mov    %ecx,(%edx)
c0105b14:	8b 00                	mov    (%eax),%eax
c0105b16:	99                   	cltd   
c0105b17:	eb 10                	jmp    c0105b29 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105b19:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b1c:	8b 00                	mov    (%eax),%eax
c0105b1e:	8d 48 04             	lea    0x4(%eax),%ecx
c0105b21:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b24:	89 0a                	mov    %ecx,(%edx)
c0105b26:	8b 00                	mov    (%eax),%eax
c0105b28:	99                   	cltd   
    }
}
c0105b29:	5d                   	pop    %ebp
c0105b2a:	c3                   	ret    

c0105b2b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105b2b:	55                   	push   %ebp
c0105b2c:	89 e5                	mov    %esp,%ebp
c0105b2e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105b31:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b3e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b41:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4f:	89 04 24             	mov    %eax,(%esp)
c0105b52:	e8 03 00 00 00       	call   c0105b5a <vprintfmt>
    va_end(ap);
}
c0105b57:	90                   	nop
c0105b58:	c9                   	leave  
c0105b59:	c3                   	ret    

c0105b5a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105b5a:	55                   	push   %ebp
c0105b5b:	89 e5                	mov    %esp,%ebp
c0105b5d:	56                   	push   %esi
c0105b5e:	53                   	push   %ebx
c0105b5f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105b62:	eb 17                	jmp    c0105b7b <vprintfmt+0x21>
            if (ch == '\0') {
c0105b64:	85 db                	test   %ebx,%ebx
c0105b66:	0f 84 bf 03 00 00    	je     c0105f2b <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b73:	89 1c 24             	mov    %ebx,(%esp)
c0105b76:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b79:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105b7b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b7e:	8d 50 01             	lea    0x1(%eax),%edx
c0105b81:	89 55 10             	mov    %edx,0x10(%ebp)
c0105b84:	0f b6 00             	movzbl (%eax),%eax
c0105b87:	0f b6 d8             	movzbl %al,%ebx
c0105b8a:	83 fb 25             	cmp    $0x25,%ebx
c0105b8d:	75 d5                	jne    c0105b64 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105b8f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105b93:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105ba0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105ba7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105baa:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105bad:	8b 45 10             	mov    0x10(%ebp),%eax
c0105bb0:	8d 50 01             	lea    0x1(%eax),%edx
c0105bb3:	89 55 10             	mov    %edx,0x10(%ebp)
c0105bb6:	0f b6 00             	movzbl (%eax),%eax
c0105bb9:	0f b6 d8             	movzbl %al,%ebx
c0105bbc:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105bbf:	83 f8 55             	cmp    $0x55,%eax
c0105bc2:	0f 87 37 03 00 00    	ja     c0105eff <vprintfmt+0x3a5>
c0105bc8:	8b 04 85 18 72 10 c0 	mov    -0x3fef8de8(,%eax,4),%eax
c0105bcf:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105bd1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105bd5:	eb d6                	jmp    c0105bad <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105bd7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105bdb:	eb d0                	jmp    c0105bad <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105bdd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105be4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105be7:	89 d0                	mov    %edx,%eax
c0105be9:	c1 e0 02             	shl    $0x2,%eax
c0105bec:	01 d0                	add    %edx,%eax
c0105bee:	01 c0                	add    %eax,%eax
c0105bf0:	01 d8                	add    %ebx,%eax
c0105bf2:	83 e8 30             	sub    $0x30,%eax
c0105bf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105bf8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105bfb:	0f b6 00             	movzbl (%eax),%eax
c0105bfe:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105c01:	83 fb 2f             	cmp    $0x2f,%ebx
c0105c04:	7e 38                	jle    c0105c3e <vprintfmt+0xe4>
c0105c06:	83 fb 39             	cmp    $0x39,%ebx
c0105c09:	7f 33                	jg     c0105c3e <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105c0b:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105c0e:	eb d4                	jmp    c0105be4 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105c10:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c13:	8d 50 04             	lea    0x4(%eax),%edx
c0105c16:	89 55 14             	mov    %edx,0x14(%ebp)
c0105c19:	8b 00                	mov    (%eax),%eax
c0105c1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105c1e:	eb 1f                	jmp    c0105c3f <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105c20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c24:	79 87                	jns    c0105bad <vprintfmt+0x53>
                width = 0;
c0105c26:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105c2d:	e9 7b ff ff ff       	jmp    c0105bad <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105c32:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105c39:	e9 6f ff ff ff       	jmp    c0105bad <vprintfmt+0x53>
            goto process_precision;
c0105c3e:	90                   	nop

        process_precision:
            if (width < 0)
c0105c3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c43:	0f 89 64 ff ff ff    	jns    c0105bad <vprintfmt+0x53>
                width = precision, precision = -1;
c0105c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c4f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105c56:	e9 52 ff ff ff       	jmp    c0105bad <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105c5b:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105c5e:	e9 4a ff ff ff       	jmp    c0105bad <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105c63:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c66:	8d 50 04             	lea    0x4(%eax),%edx
c0105c69:	89 55 14             	mov    %edx,0x14(%ebp)
c0105c6c:	8b 00                	mov    (%eax),%eax
c0105c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c71:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c75:	89 04 24             	mov    %eax,(%esp)
c0105c78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c7b:	ff d0                	call   *%eax
            break;
c0105c7d:	e9 a4 02 00 00       	jmp    c0105f26 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105c82:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c85:	8d 50 04             	lea    0x4(%eax),%edx
c0105c88:	89 55 14             	mov    %edx,0x14(%ebp)
c0105c8b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105c8d:	85 db                	test   %ebx,%ebx
c0105c8f:	79 02                	jns    c0105c93 <vprintfmt+0x139>
                err = -err;
c0105c91:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105c93:	83 fb 06             	cmp    $0x6,%ebx
c0105c96:	7f 0b                	jg     c0105ca3 <vprintfmt+0x149>
c0105c98:	8b 34 9d d8 71 10 c0 	mov    -0x3fef8e28(,%ebx,4),%esi
c0105c9f:	85 f6                	test   %esi,%esi
c0105ca1:	75 23                	jne    c0105cc6 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105ca3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105ca7:	c7 44 24 08 05 72 10 	movl   $0xc0107205,0x8(%esp)
c0105cae:	c0 
c0105caf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb9:	89 04 24             	mov    %eax,(%esp)
c0105cbc:	e8 6a fe ff ff       	call   c0105b2b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105cc1:	e9 60 02 00 00       	jmp    c0105f26 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105cc6:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105cca:	c7 44 24 08 0e 72 10 	movl   $0xc010720e,0x8(%esp)
c0105cd1:	c0 
c0105cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cdc:	89 04 24             	mov    %eax,(%esp)
c0105cdf:	e8 47 fe ff ff       	call   c0105b2b <printfmt>
            break;
c0105ce4:	e9 3d 02 00 00       	jmp    c0105f26 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105ce9:	8b 45 14             	mov    0x14(%ebp),%eax
c0105cec:	8d 50 04             	lea    0x4(%eax),%edx
c0105cef:	89 55 14             	mov    %edx,0x14(%ebp)
c0105cf2:	8b 30                	mov    (%eax),%esi
c0105cf4:	85 f6                	test   %esi,%esi
c0105cf6:	75 05                	jne    c0105cfd <vprintfmt+0x1a3>
                p = "(null)";
c0105cf8:	be 11 72 10 c0       	mov    $0xc0107211,%esi
            }
            if (width > 0 && padc != '-') {
c0105cfd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d01:	7e 76                	jle    c0105d79 <vprintfmt+0x21f>
c0105d03:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105d07:	74 70                	je     c0105d79 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d10:	89 34 24             	mov    %esi,(%esp)
c0105d13:	e8 f6 f7 ff ff       	call   c010550e <strnlen>
c0105d18:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105d1b:	29 c2                	sub    %eax,%edx
c0105d1d:	89 d0                	mov    %edx,%eax
c0105d1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d22:	eb 16                	jmp    c0105d3a <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105d24:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105d28:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d2b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d2f:	89 04 24             	mov    %eax,(%esp)
c0105d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d35:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105d37:	ff 4d e8             	decl   -0x18(%ebp)
c0105d3a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d3e:	7f e4                	jg     c0105d24 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105d40:	eb 37                	jmp    c0105d79 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105d42:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105d46:	74 1f                	je     c0105d67 <vprintfmt+0x20d>
c0105d48:	83 fb 1f             	cmp    $0x1f,%ebx
c0105d4b:	7e 05                	jle    c0105d52 <vprintfmt+0x1f8>
c0105d4d:	83 fb 7e             	cmp    $0x7e,%ebx
c0105d50:	7e 15                	jle    c0105d67 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105d52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d59:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d63:	ff d0                	call   *%eax
c0105d65:	eb 0f                	jmp    c0105d76 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105d67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d6e:	89 1c 24             	mov    %ebx,(%esp)
c0105d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d74:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105d76:	ff 4d e8             	decl   -0x18(%ebp)
c0105d79:	89 f0                	mov    %esi,%eax
c0105d7b:	8d 70 01             	lea    0x1(%eax),%esi
c0105d7e:	0f b6 00             	movzbl (%eax),%eax
c0105d81:	0f be d8             	movsbl %al,%ebx
c0105d84:	85 db                	test   %ebx,%ebx
c0105d86:	74 27                	je     c0105daf <vprintfmt+0x255>
c0105d88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105d8c:	78 b4                	js     c0105d42 <vprintfmt+0x1e8>
c0105d8e:	ff 4d e4             	decl   -0x1c(%ebp)
c0105d91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105d95:	79 ab                	jns    c0105d42 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105d97:	eb 16                	jmp    c0105daf <vprintfmt+0x255>
                putch(' ', putdat);
c0105d99:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105da0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105da7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105daa:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105dac:	ff 4d e8             	decl   -0x18(%ebp)
c0105daf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105db3:	7f e4                	jg     c0105d99 <vprintfmt+0x23f>
            }
            break;
c0105db5:	e9 6c 01 00 00       	jmp    c0105f26 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dc1:	8d 45 14             	lea    0x14(%ebp),%eax
c0105dc4:	89 04 24             	mov    %eax,(%esp)
c0105dc7:	e8 18 fd ff ff       	call   c0105ae4 <getint>
c0105dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105dcf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105dd8:	85 d2                	test   %edx,%edx
c0105dda:	79 26                	jns    c0105e02 <vprintfmt+0x2a8>
                putch('-', putdat);
c0105ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105de3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105dea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ded:	ff d0                	call   *%eax
                num = -(long long)num;
c0105def:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105df5:	f7 d8                	neg    %eax
c0105df7:	83 d2 00             	adc    $0x0,%edx
c0105dfa:	f7 da                	neg    %edx
c0105dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105dff:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105e02:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105e09:	e9 a8 00 00 00       	jmp    c0105eb6 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e11:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e15:	8d 45 14             	lea    0x14(%ebp),%eax
c0105e18:	89 04 24             	mov    %eax,(%esp)
c0105e1b:	e8 75 fc ff ff       	call   c0105a95 <getuint>
c0105e20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e23:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105e26:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105e2d:	e9 84 00 00 00       	jmp    c0105eb6 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e39:	8d 45 14             	lea    0x14(%ebp),%eax
c0105e3c:	89 04 24             	mov    %eax,(%esp)
c0105e3f:	e8 51 fc ff ff       	call   c0105a95 <getuint>
c0105e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e47:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105e4a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105e51:	eb 63                	jmp    c0105eb6 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105e53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e5a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105e61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e64:	ff d0                	call   *%eax
            putch('x', putdat);
c0105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e6d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105e74:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e77:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105e79:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e7c:	8d 50 04             	lea    0x4(%eax),%edx
c0105e7f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105e82:	8b 00                	mov    (%eax),%eax
c0105e84:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105e8e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105e95:	eb 1f                	jmp    c0105eb6 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e9e:	8d 45 14             	lea    0x14(%ebp),%eax
c0105ea1:	89 04 24             	mov    %eax,(%esp)
c0105ea4:	e8 ec fb ff ff       	call   c0105a95 <getuint>
c0105ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105eac:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105eaf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105eb6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105eba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ebd:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105ec1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105ec4:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105ec8:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ecf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ed2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ed6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105eda:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105edd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ee1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ee4:	89 04 24             	mov    %eax,(%esp)
c0105ee7:	e8 a4 fa ff ff       	call   c0105990 <printnum>
            break;
c0105eec:	eb 38                	jmp    c0105f26 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105eee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ef5:	89 1c 24             	mov    %ebx,(%esp)
c0105ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105efb:	ff d0                	call   *%eax
            break;
c0105efd:	eb 27                	jmp    c0105f26 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105eff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f06:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105f0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f10:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105f12:	ff 4d 10             	decl   0x10(%ebp)
c0105f15:	eb 03                	jmp    c0105f1a <vprintfmt+0x3c0>
c0105f17:	ff 4d 10             	decl   0x10(%ebp)
c0105f1a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f1d:	48                   	dec    %eax
c0105f1e:	0f b6 00             	movzbl (%eax),%eax
c0105f21:	3c 25                	cmp    $0x25,%al
c0105f23:	75 f2                	jne    c0105f17 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105f25:	90                   	nop
    while (1) {
c0105f26:	e9 37 fc ff ff       	jmp    c0105b62 <vprintfmt+0x8>
                return;
c0105f2b:	90                   	nop
        }
    }
}
c0105f2c:	83 c4 40             	add    $0x40,%esp
c0105f2f:	5b                   	pop    %ebx
c0105f30:	5e                   	pop    %esi
c0105f31:	5d                   	pop    %ebp
c0105f32:	c3                   	ret    

c0105f33 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105f33:	55                   	push   %ebp
c0105f34:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105f36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f39:	8b 40 08             	mov    0x8(%eax),%eax
c0105f3c:	8d 50 01             	lea    0x1(%eax),%edx
c0105f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f42:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105f45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f48:	8b 10                	mov    (%eax),%edx
c0105f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f4d:	8b 40 04             	mov    0x4(%eax),%eax
c0105f50:	39 c2                	cmp    %eax,%edx
c0105f52:	73 12                	jae    c0105f66 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105f54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f57:	8b 00                	mov    (%eax),%eax
c0105f59:	8d 48 01             	lea    0x1(%eax),%ecx
c0105f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105f5f:	89 0a                	mov    %ecx,(%edx)
c0105f61:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f64:	88 10                	mov    %dl,(%eax)
    }
}
c0105f66:	90                   	nop
c0105f67:	5d                   	pop    %ebp
c0105f68:	c3                   	ret    

c0105f69 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105f69:	55                   	push   %ebp
c0105f6a:	89 e5                	mov    %esp,%ebp
c0105f6c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105f6f:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8d:	89 04 24             	mov    %eax,(%esp)
c0105f90:	e8 08 00 00 00       	call   c0105f9d <vsnprintf>
c0105f95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105f9b:	c9                   	leave  
c0105f9c:	c3                   	ret    

c0105f9d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105f9d:	55                   	push   %ebp
c0105f9e:	89 e5                	mov    %esp,%ebp
c0105fa0:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105fa3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fac:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105faf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fb2:	01 d0                	add    %edx,%eax
c0105fb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105fbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105fc2:	74 0a                	je     c0105fce <vsnprintf+0x31>
c0105fc4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fca:	39 c2                	cmp    %eax,%edx
c0105fcc:	76 07                	jbe    c0105fd5 <vsnprintf+0x38>
        return -E_INVAL;
c0105fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105fd3:	eb 2a                	jmp    c0105fff <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105fd5:	8b 45 14             	mov    0x14(%ebp),%eax
c0105fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105fdc:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fe3:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fea:	c7 04 24 33 5f 10 c0 	movl   $0xc0105f33,(%esp)
c0105ff1:	e8 64 fb ff ff       	call   c0105b5a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ff9:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105fff:	c9                   	leave  
c0106000:	c3                   	ret    
