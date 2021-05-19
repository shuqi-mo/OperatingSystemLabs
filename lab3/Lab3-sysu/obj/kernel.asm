
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
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
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 07 56 00 00       	call   c0105669 <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 5e 10 c0 	movl   $0xc0105e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 5e 10 c0 	movl   $0xc0105e9c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 14 31 00 00       	call   c01031a4 <pmm_init>

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
c0100155:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100162:	c7 04 24 a1 5e 10 c0 	movl   $0xc0105ea1,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 5e 10 c0 	movl   $0xc0105eaf,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 bd 5e 10 c0 	movl   $0xc0105ebd,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 cb 5e 10 c0 	movl   $0xc0105ecb,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 d9 5e 10 c0 	movl   $0xc0105ed9,(%esp)
c01001e5:	e8 a8 00 00 00       	call   c0100292 <cprintf>
    round ++;
c01001ea:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001ef:	40                   	inc    %eax
c01001f0:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
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
c010020f:	c7 04 24 e8 5e 10 c0 	movl   $0xc0105ee8,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 08 5f 10 c0 	movl   $0xc0105f08,(%esp)
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
c0100288:	e8 2f 57 00 00       	call   c01059bc <vprintfmt>
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
c0100347:	c7 04 24 27 5f 10 c0 	movl   $0xc0105f27,(%esp)
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
c0100395:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
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
c01003d3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003db:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
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
c01003ef:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c01003f4:	85 c0                	test   %eax,%eax
c01003f6:	75 5b                	jne    c0100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c01003f8:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
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
c0100416:	c7 04 24 2a 5f 10 c0 	movl   $0xc0105f2a,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 46 5f 10 c0 	movl   $0xc0105f46,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 48 5f 10 c0 	movl   $0xc0105f48,(%esp)
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
c0100481:	c7 04 24 5a 5f 10 c0 	movl   $0xc0105f5a,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 46 5f 10 c0 	movl   $0xc0105f46,(%esp)
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
c01004b1:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
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
c010060f:	c7 00 78 5f 10 c0    	movl   $0xc0105f78,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 78 5f 10 c0 	movl   $0xc0105f78,0x8(%eax)
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
c0100646:	c7 45 f4 d0 71 10 c0 	movl   $0xc01071d0,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 f8 21 11 c0 	movl   $0xc01121f8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec f9 21 11 c0 	movl   $0xc01121f9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 f1 4c 11 c0 	movl   $0xc0114cf1,-0x18(%ebp)

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
c01007b6:	e8 2a 4d 00 00       	call   c01054e5 <strfind>
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
c010093e:	c7 04 24 82 5f 10 c0 	movl   $0xc0105f82,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 9b 5f 10 c0 	movl   $0xc0105f9b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 63 5e 10 	movl   $0xc0105e63,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 b3 5f 10 c0 	movl   $0xc0105fb3,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 cb 5f 10 c0 	movl   $0xc0105fcb,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 e3 5f 10 c0 	movl   $0xc0105fe3,(%esp)
c0100995:	e8 f8 f8 ff ff       	call   c0100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010099a:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c010099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009aa:	29 c2                	sub    %eax,%edx
c01009ac:	89 d0                	mov    %edx,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	85 c0                	test   %eax,%eax
c01009b6:	0f 48 c2             	cmovs  %edx,%eax
c01009b9:	c1 f8 0a             	sar    $0xa,%eax
c01009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c0:	c7 04 24 fc 5f 10 c0 	movl   $0xc0105ffc,(%esp)
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
c01009f5:	c7 04 24 26 60 10 c0 	movl   $0xc0106026,(%esp)
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
c0100a63:	c7 04 24 42 60 10 c0 	movl   $0xc0106042,(%esp)
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
c0100ab6:	c7 04 24 54 60 10 c0 	movl   $0xc0106054,(%esp)
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
c0100ae9:	c7 04 24 70 60 10 c0 	movl   $0xc0106070,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
          for(uint32_t j = 0; j < 4; j++)
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	76 d6                	jbe    c0100ad4 <print_stackframe+0x51>
        cprintf("\n");
c0100afe:	c7 04 24 78 60 10 c0 	movl   $0xc0106078,(%esp)
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
c0100b71:	c7 04 24 fc 60 10 c0 	movl   $0xc01060fc,(%esp)
c0100b78:	e8 36 49 00 00       	call   c01054b3 <strchr>
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
c0100b99:	c7 04 24 01 61 10 c0 	movl   $0xc0106101,(%esp)
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
c0100bdb:	c7 04 24 fc 60 10 c0 	movl   $0xc01060fc,(%esp)
c0100be2:	e8 cc 48 00 00       	call   c01054b3 <strchr>
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
c0100c3a:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c3f:	8b 00                	mov    (%eax),%eax
c0100c41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c45:	89 04 24             	mov    %eax,(%esp)
c0100c48:	e8 c9 47 00 00       	call   c0105416 <strcmp>
c0100c4d:	85 c0                	test   %eax,%eax
c0100c4f:	75 31                	jne    c0100c82 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c54:	89 d0                	mov    %edx,%eax
c0100c56:	01 c0                	add    %eax,%eax
c0100c58:	01 d0                	add    %edx,%eax
c0100c5a:	c1 e0 02             	shl    $0x2,%eax
c0100c5d:	05 08 70 11 c0       	add    $0xc0117008,%eax
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
c0100c94:	c7 04 24 1f 61 10 c0 	movl   $0xc010611f,(%esp)
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
c0100cb1:	c7 04 24 38 61 10 c0 	movl   $0xc0106138,(%esp)
c0100cb8:	e8 d5 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbd:	c7 04 24 60 61 10 c0 	movl   $0xc0106160,(%esp)
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
c0100cda:	c7 04 24 85 61 10 c0 	movl   $0xc0106185,(%esp)
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
c0100d26:	05 04 70 11 c0       	add    $0xc0117004,%eax
c0100d2b:	8b 08                	mov    (%eax),%ecx
c0100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d30:	89 d0                	mov    %edx,%eax
c0100d32:	01 c0                	add    %eax,%eax
c0100d34:	01 d0                	add    %edx,%eax
c0100d36:	c1 e0 02             	shl    $0x2,%eax
c0100d39:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d3e:	8b 00                	mov    (%eax),%eax
c0100d40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d48:	c7 04 24 89 61 10 c0 	movl   $0xc0106189,(%esp)
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
c0100dc9:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100dd0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd3:	c7 04 24 92 61 10 c0 	movl   $0xc0106192,(%esp)
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
c0100eab:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100eb2:	b4 03 
c0100eb4:	eb 13                	jmp    c0100ec9 <cga_init+0x54>
    } else {
        *cp = was;
c0100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ebd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ec0:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ec7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ec9:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ed0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ed4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100edc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee1:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
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
c0100f07:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f12:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f1f:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
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
c0100f45:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f4d:	0f b7 c0             	movzwl %ax,%eax
c0100f50:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
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
c0101000:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
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
c0101025:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
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
c0101129:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101130:	85 c0                	test   %eax,%eax
c0101132:	0f 84 af 00 00 00    	je     c01011e7 <cga_putc+0xf1>
            crt_pos --;
c0101138:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010113f:	48                   	dec    %eax
c0101140:	0f b7 c0             	movzwl %ax,%eax
c0101143:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101149:	8b 45 08             	mov    0x8(%ebp),%eax
c010114c:	98                   	cwtl   
c010114d:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101152:	98                   	cwtl   
c0101153:	83 c8 20             	or     $0x20,%eax
c0101156:	98                   	cwtl   
c0101157:	8b 15 40 a4 11 c0    	mov    0xc011a440,%edx
c010115d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101164:	01 c9                	add    %ecx,%ecx
c0101166:	01 ca                	add    %ecx,%edx
c0101168:	0f b7 c0             	movzwl %ax,%eax
c010116b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010116e:	eb 77                	jmp    c01011e7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101170:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101177:	83 c0 50             	add    $0x50,%eax
c010117a:	0f b7 c0             	movzwl %ax,%eax
c010117d:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101183:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010118a:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
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
c01011b5:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011bb:	eb 2b                	jmp    c01011e8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011bd:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011c3:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ca:	8d 50 01             	lea    0x1(%eax),%edx
c01011cd:	0f b7 d2             	movzwl %dx,%edx
c01011d0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
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
c01011e8:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ef:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01011f4:	76 5d                	jbe    c0101253 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f6:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101201:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101206:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120d:	00 
c010120e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101212:	89 04 24             	mov    %eax,(%esp)
c0101215:	e8 8f 44 00 00       	call   c01056a9 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010121a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101221:	eb 14                	jmp    c0101237 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101223:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
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
c0101240:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101247:	83 e8 50             	sub    $0x50,%eax
c010124a:	0f b7 c0             	movzwl %ax,%eax
c010124d:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101253:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010125a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010125e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101262:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101266:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010126a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010126b:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101272:	c1 e8 08             	shr    $0x8,%eax
c0101275:	0f b7 c0             	movzwl %ax,%eax
c0101278:	0f b6 c0             	movzbl %al,%eax
c010127b:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c0101282:	42                   	inc    %edx
c0101283:	0f b7 d2             	movzwl %dx,%edx
c0101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010128a:	88 45 e9             	mov    %al,-0x17(%ebp)
c010128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101295:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101296:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010129d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012a1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c01012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012ae:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012b5:	0f b6 c0             	movzbl %al,%eax
c01012b8:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
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
c0101381:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101386:	8d 50 01             	lea    0x1(%eax),%edx
c0101389:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c010138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101392:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101398:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010139d:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a2:	75 0a                	jne    c01013ae <cons_intr+0x3b>
                cons.wpos = 0;
c01013a4:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
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
c010141c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
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
c010147d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101482:	83 c8 40             	or     $0x40,%eax
c0101485:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010148a:	b8 00 00 00 00       	mov    $0x0,%eax
c010148f:	e9 22 01 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c0101494:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101498:	84 c0                	test   %al,%al
c010149a:	79 45                	jns    c01014e1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149c:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
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
c01014bb:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014c2:	0c 40                	or     $0x40,%al
c01014c4:	0f b6 c0             	movzbl %al,%eax
c01014c7:	f7 d0                	not    %eax
c01014c9:	89 c2                	mov    %eax,%edx
c01014cb:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d0:	21 d0                	and    %edx,%eax
c01014d2:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014d7:	b8 00 00 00 00       	mov    $0x0,%eax
c01014dc:	e9 d5 00 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c01014e1:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e6:	83 e0 40             	and    $0x40,%eax
c01014e9:	85 c0                	test   %eax,%eax
c01014eb:	74 11                	je     c01014fe <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ed:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f1:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f6:	83 e0 bf             	and    $0xffffffbf,%eax
c01014f9:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c01014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101502:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c0101509:	0f b6 d0             	movzbl %al,%edx
c010150c:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101511:	09 d0                	or     %edx,%eax
c0101513:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c0101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151c:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101523:	0f b6 d0             	movzbl %al,%edx
c0101526:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152b:	31 d0                	xor    %edx,%eax
c010152d:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101532:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101537:	83 e0 03             	and    $0x3,%eax
c010153a:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101545:	01 d0                	add    %edx,%eax
c0101547:	0f b6 00             	movzbl (%eax),%eax
c010154a:	0f b6 c0             	movzbl %al,%eax
c010154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101550:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
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
c010157e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101583:	f7 d0                	not    %eax
c0101585:	83 e0 06             	and    $0x6,%eax
c0101588:	85 c0                	test   %eax,%eax
c010158a:	75 27                	jne    c01015b3 <kbd_proc_data+0x17f>
c010158c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101593:	75 1e                	jne    c01015b3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c0101595:	c7 04 24 ad 61 10 c0 	movl   $0xc01061ad,(%esp)
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
c01015fc:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101601:	85 c0                	test   %eax,%eax
c0101603:	75 0c                	jne    c0101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101605:	c7 04 24 b9 61 10 c0 	movl   $0xc01061b9,(%esp)
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
c0101670:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101676:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c010168d:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
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
c01016d0:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016d6:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
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
c0101733:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
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
c0101752:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
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
c0101866:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010186d:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101872:	74 0f                	je     c0101883 <pic_init+0x137>
        pic_setmask(irq_mask);
c0101874:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
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
c01018a2:	c7 04 24 e0 61 10 c0 	movl   $0xc01061e0,(%esp)
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
c01018c6:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018cd:	0f b7 d0             	movzwl %ax,%edx
c01018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d3:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018da:	c0 
c01018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018de:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018e5:	c0 08 00 
c01018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018eb:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018f2:	c0 
c01018f3:	80 e2 e0             	and    $0xe0,%dl
c01018f6:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101900:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c0101907:	c0 
c0101908:	80 e2 1f             	and    $0x1f,%dl
c010190b:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101915:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010191c:	c0 
c010191d:	80 e2 f0             	and    $0xf0,%dl
c0101920:	80 ca 0e             	or     $0xe,%dl
c0101923:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010192d:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101934:	c0 
c0101935:	80 e2 ef             	and    $0xef,%dl
c0101938:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010193f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101942:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101949:	c0 
c010194a:	80 e2 9f             	and    $0x9f,%dl
c010194d:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101954:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101957:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010195e:	c0 
c010195f:	80 ca 80             	or     $0x80,%dl
c0101962:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101969:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196c:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101973:	c1 e8 10             	shr    $0x10,%eax
c0101976:	0f b7 d0             	movzwl %ax,%edx
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c0101983:	c0 
        SETGATE(idt[T_SYSCALL], 0, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c0101984:	a1 e0 77 11 c0       	mov    0xc01177e0,%eax
c0101989:	0f b7 c0             	movzwl %ax,%eax
c010198c:	66 a3 80 aa 11 c0    	mov    %ax,0xc011aa80
c0101992:	66 c7 05 82 aa 11 c0 	movw   $0x8,0xc011aa82
c0101999:	08 00 
c010199b:	0f b6 05 84 aa 11 c0 	movzbl 0xc011aa84,%eax
c01019a2:	24 e0                	and    $0xe0,%al
c01019a4:	a2 84 aa 11 c0       	mov    %al,0xc011aa84
c01019a9:	0f b6 05 84 aa 11 c0 	movzbl 0xc011aa84,%eax
c01019b0:	24 1f                	and    $0x1f,%al
c01019b2:	a2 84 aa 11 c0       	mov    %al,0xc011aa84
c01019b7:	0f b6 05 85 aa 11 c0 	movzbl 0xc011aa85,%eax
c01019be:	24 f0                	and    $0xf0,%al
c01019c0:	0c 0e                	or     $0xe,%al
c01019c2:	a2 85 aa 11 c0       	mov    %al,0xc011aa85
c01019c7:	0f b6 05 85 aa 11 c0 	movzbl 0xc011aa85,%eax
c01019ce:	24 ef                	and    $0xef,%al
c01019d0:	a2 85 aa 11 c0       	mov    %al,0xc011aa85
c01019d5:	0f b6 05 85 aa 11 c0 	movzbl 0xc011aa85,%eax
c01019dc:	0c 60                	or     $0x60,%al
c01019de:	a2 85 aa 11 c0       	mov    %al,0xc011aa85
c01019e3:	0f b6 05 85 aa 11 c0 	movzbl 0xc011aa85,%eax
c01019ea:	0c 80                	or     $0x80,%al
c01019ec:	a2 85 aa 11 c0       	mov    %al,0xc011aa85
c01019f1:	a1 e0 77 11 c0       	mov    0xc01177e0,%eax
c01019f6:	c1 e8 10             	shr    $0x10,%eax
c01019f9:	0f b7 c0             	movzwl %ax,%eax
c01019fc:	66 a3 86 aa 11 c0    	mov    %ax,0xc011aa86
c0101a02:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
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
c0101a31:	8b 04 85 40 65 10 c0 	mov    -0x3fef9ac0(,%eax,4),%eax
c0101a38:	eb 18                	jmp    c0101a52 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a3a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a3e:	7e 0d                	jle    c0101a4d <trapname+0x2a>
c0101a40:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a44:	7f 07                	jg     c0101a4d <trapname+0x2a>
        return "Hardware Interrupt";
c0101a46:	b8 ea 61 10 c0       	mov    $0xc01061ea,%eax
c0101a4b:	eb 05                	jmp    c0101a52 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a4d:	b8 fd 61 10 c0       	mov    $0xc01061fd,%eax
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
c0101a76:	c7 04 24 3e 62 10 c0 	movl   $0xc010623e,(%esp)
c0101a7d:	e8 10 e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a85:	89 04 24             	mov    %eax,(%esp)
c0101a88:	e8 8f 01 00 00       	call   c0101c1c <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a90:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a94:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a98:	c7 04 24 4f 62 10 c0 	movl   $0xc010624f,(%esp)
c0101a9f:	e8 ee e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa7:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101aab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aaf:	c7 04 24 62 62 10 c0 	movl   $0xc0106262,(%esp)
c0101ab6:	e8 d7 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abe:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac6:	c7 04 24 75 62 10 c0 	movl   $0xc0106275,(%esp)
c0101acd:	e8 c0 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101add:	c7 04 24 88 62 10 c0 	movl   $0xc0106288,(%esp)
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
c0101b07:	c7 04 24 9b 62 10 c0 	movl   $0xc010629b,(%esp)
c0101b0e:	e8 7f e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b16:	8b 40 34             	mov    0x34(%eax),%eax
c0101b19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b1d:	c7 04 24 ad 62 10 c0 	movl   $0xc01062ad,(%esp)
c0101b24:	e8 69 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2c:	8b 40 38             	mov    0x38(%eax),%eax
c0101b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b33:	c7 04 24 bc 62 10 c0 	movl   $0xc01062bc,(%esp)
c0101b3a:	e8 53 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4a:	c7 04 24 cb 62 10 c0 	movl   $0xc01062cb,(%esp)
c0101b51:	e8 3c e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b59:	8b 40 40             	mov    0x40(%eax),%eax
c0101b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b60:	c7 04 24 de 62 10 c0 	movl   $0xc01062de,(%esp)
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
c0101b8e:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b95:	85 c0                	test   %eax,%eax
c0101b97:	74 1a                	je     c0101bb3 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b9c:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba7:	c7 04 24 ed 62 10 c0 	movl   $0xc01062ed,(%esp)
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
c0101bd1:	c7 04 24 f1 62 10 c0 	movl   $0xc01062f1,(%esp)
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
c0101bf6:	c7 04 24 fa 62 10 c0 	movl   $0xc01062fa,(%esp)
c0101bfd:	e8 90 e6 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c02:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c05:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c0d:	c7 04 24 09 63 10 c0 	movl   $0xc0106309,(%esp)
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
c0101c2b:	c7 04 24 1c 63 10 c0 	movl   $0xc010631c,(%esp)
c0101c32:	e8 5b e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c37:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3a:	8b 40 04             	mov    0x4(%eax),%eax
c0101c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c41:	c7 04 24 2b 63 10 c0 	movl   $0xc010632b,(%esp)
c0101c48:	e8 45 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c50:	8b 40 08             	mov    0x8(%eax),%eax
c0101c53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c57:	c7 04 24 3a 63 10 c0 	movl   $0xc010633a,(%esp)
c0101c5e:	e8 2f e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c66:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c6d:	c7 04 24 49 63 10 c0 	movl   $0xc0106349,(%esp)
c0101c74:	e8 19 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7c:	8b 40 10             	mov    0x10(%eax),%eax
c0101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c83:	c7 04 24 58 63 10 c0 	movl   $0xc0106358,(%esp)
c0101c8a:	e8 03 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c92:	8b 40 14             	mov    0x14(%eax),%eax
c0101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c99:	c7 04 24 67 63 10 c0 	movl   $0xc0106367,(%esp)
c0101ca0:	e8 ed e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca8:	8b 40 18             	mov    0x18(%eax),%eax
c0101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101caf:	c7 04 24 76 63 10 c0 	movl   $0xc0106376,(%esp)
c0101cb6:	e8 d7 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cbe:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc5:	c7 04 24 85 63 10 c0 	movl   $0xc0106385,(%esp)
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
c0101d17:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d1c:	40                   	inc    %eax
c0101d1d:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
         if(ticks % TICK_NUM == 0) {
c0101d22:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
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
c0101d58:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
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
c0101d7f:	c7 04 24 94 63 10 c0 	movl   $0xc0106394,(%esp)
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
c0101da5:	c7 04 24 a6 63 10 c0 	movl   $0xc01063a6,(%esp)
c0101dac:	e8 e1 e4 ff ff       	call   c0100292 <cprintf>
        break;
c0101db1:	eb 55                	jmp    c0101e08 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101db3:	c7 44 24 08 b5 63 10 	movl   $0xc01063b5,0x8(%esp)
c0101dba:	c0 
c0101dbb:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0101dc2:	00 
c0101dc3:	c7 04 24 c5 63 10 c0 	movl   $0xc01063c5,(%esp)
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
c0101de8:	c7 44 24 08 d6 63 10 	movl   $0xc01063d6,0x8(%esp)
c0101def:	c0 
c0101df0:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0101df7:	00 
c0101df8:	c7 04 24 c5 63 10 c0 	movl   $0xc01063c5,(%esp)
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
c01028b9:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
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
c01028f0:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01028f5:	39 c2                	cmp    %eax,%edx
c01028f7:	72 1c                	jb     c0102915 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01028f9:	c7 44 24 08 90 65 10 	movl   $0xc0106590,0x8(%esp)
c0102900:	c0 
c0102901:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102908:	00 
c0102909:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
c0102910:	e8 d4 da ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c0102915:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
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
c010294e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102953:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102956:	72 23                	jb     c010297b <page2kva+0x4a>
c0102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010295b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010295f:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c0102966:	c0 
c0102967:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c010296e:	00 
c010296f:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
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
c0102995:	c7 44 24 08 e4 65 10 	movl   $0xc01065e4,0x8(%esp)
c010299c:	c0 
c010299d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01029a4:	00 
c01029a5:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
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

c01029e5 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
c01029e5:	55                   	push   %ebp
c01029e6:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01029e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01029eb:	8b 00                	mov    (%eax),%eax
c01029ed:	8d 50 01             	lea    0x1(%eax),%edx
c01029f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f3:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f8:	8b 00                	mov    (%eax),%eax
}
c01029fa:	5d                   	pop    %ebp
c01029fb:	c3                   	ret    

c01029fc <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01029fc:	55                   	push   %ebp
c01029fd:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01029ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a02:	8b 00                	mov    (%eax),%eax
c0102a04:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102a07:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0f:	8b 00                	mov    (%eax),%eax
}
c0102a11:	5d                   	pop    %ebp
c0102a12:	c3                   	ret    

c0102a13 <__intr_save>:
__intr_save(void) {
c0102a13:	55                   	push   %ebp
c0102a14:	89 e5                	mov    %esp,%ebp
c0102a16:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102a19:	9c                   	pushf  
c0102a1a:	58                   	pop    %eax
c0102a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a21:	25 00 02 00 00       	and    $0x200,%eax
c0102a26:	85 c0                	test   %eax,%eax
c0102a28:	74 0c                	je     c0102a36 <__intr_save+0x23>
        intr_disable();
c0102a2a:	e8 5e ee ff ff       	call   c010188d <intr_disable>
        return 1;
c0102a2f:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a34:	eb 05                	jmp    c0102a3b <__intr_save+0x28>
    return 0;
c0102a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a3b:	c9                   	leave  
c0102a3c:	c3                   	ret    

c0102a3d <__intr_restore>:
__intr_restore(bool flag) {
c0102a3d:	55                   	push   %ebp
c0102a3e:	89 e5                	mov    %esp,%ebp
c0102a40:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a43:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a47:	74 05                	je     c0102a4e <__intr_restore+0x11>
        intr_enable();
c0102a49:	e8 38 ee ff ff       	call   c0101886 <intr_enable>
}
c0102a4e:	90                   	nop
c0102a4f:	c9                   	leave  
c0102a50:	c3                   	ret    

c0102a51 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102a51:	55                   	push   %ebp
c0102a52:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a57:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a5a:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a5f:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a61:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a66:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a68:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a6d:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a6f:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a74:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a76:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a7b:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a7d:	ea 84 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a84
}
c0102a84:	90                   	nop
c0102a85:	5d                   	pop    %ebp
c0102a86:	c3                   	ret    

c0102a87 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a87:	55                   	push   %ebp
c0102a88:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a8d:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102a92:	90                   	nop
c0102a93:	5d                   	pop    %ebp
c0102a94:	c3                   	ret    

c0102a95 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a95:	55                   	push   %ebp
c0102a96:	89 e5                	mov    %esp,%ebp
c0102a98:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a9b:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102aa0:	89 04 24             	mov    %eax,(%esp)
c0102aa3:	e8 df ff ff ff       	call   c0102a87 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102aa8:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102aaf:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102ab1:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102ab8:	68 00 
c0102aba:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102abf:	0f b7 c0             	movzwl %ax,%eax
c0102ac2:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102ac8:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102acd:	c1 e8 10             	shr    $0x10,%eax
c0102ad0:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102ad5:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102adc:	24 f0                	and    $0xf0,%al
c0102ade:	0c 09                	or     $0x9,%al
c0102ae0:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102ae5:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102aec:	24 ef                	and    $0xef,%al
c0102aee:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102af3:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102afa:	24 9f                	and    $0x9f,%al
c0102afc:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b01:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102b08:	0c 80                	or     $0x80,%al
c0102b0a:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b0f:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b16:	24 f0                	and    $0xf0,%al
c0102b18:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b1d:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b24:	24 ef                	and    $0xef,%al
c0102b26:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b2b:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b32:	24 df                	and    $0xdf,%al
c0102b34:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b39:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b40:	0c 40                	or     $0x40,%al
c0102b42:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b47:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b4e:	24 7f                	and    $0x7f,%al
c0102b50:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b55:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102b5a:	c1 e8 18             	shr    $0x18,%eax
c0102b5d:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b62:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0102b69:	e8 e3 fe ff ff       	call   c0102a51 <lgdt>
c0102b6e:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b74:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b78:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b7b:	90                   	nop
c0102b7c:	c9                   	leave  
c0102b7d:	c3                   	ret    

c0102b7e <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b7e:	55                   	push   %ebp
c0102b7f:	89 e5                	mov    %esp,%ebp
c0102b81:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102b84:	c7 05 10 af 11 c0 b8 	movl   $0xc0106fb8,0xc011af10
c0102b8b:	6f 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b8e:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102b93:	8b 00                	mov    (%eax),%eax
c0102b95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b99:	c7 04 24 10 66 10 c0 	movl   $0xc0106610,(%esp)
c0102ba0:	e8 ed d6 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102ba5:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102baa:	8b 40 04             	mov    0x4(%eax),%eax
c0102bad:	ff d0                	call   *%eax
}
c0102baf:	90                   	nop
c0102bb0:	c9                   	leave  
c0102bb1:	c3                   	ret    

c0102bb2 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102bb2:	55                   	push   %ebp
c0102bb3:	89 e5                	mov    %esp,%ebp
c0102bb5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102bb8:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bbd:	8b 40 08             	mov    0x8(%eax),%eax
c0102bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bc3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bc7:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bca:	89 14 24             	mov    %edx,(%esp)
c0102bcd:	ff d0                	call   *%eax
}
c0102bcf:	90                   	nop
c0102bd0:	c9                   	leave  
c0102bd1:	c3                   	ret    

c0102bd2 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102bd2:	55                   	push   %ebp
c0102bd3:	89 e5                	mov    %esp,%ebp
c0102bd5:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102bd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bdf:	e8 2f fe ff ff       	call   c0102a13 <__intr_save>
c0102be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102be7:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bec:	8b 40 0c             	mov    0xc(%eax),%eax
c0102bef:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bf2:	89 14 24             	mov    %edx,(%esp)
c0102bf5:	ff d0                	call   *%eax
c0102bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bfd:	89 04 24             	mov    %eax,(%esp)
c0102c00:	e8 38 fe ff ff       	call   c0102a3d <__intr_restore>
    return page;
c0102c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c08:	c9                   	leave  
c0102c09:	c3                   	ret    

c0102c0a <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102c0a:	55                   	push   %ebp
c0102c0b:	89 e5                	mov    %esp,%ebp
c0102c0d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c10:	e8 fe fd ff ff       	call   c0102a13 <__intr_save>
c0102c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102c18:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c1d:	8b 40 10             	mov    0x10(%eax),%eax
c0102c20:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c23:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102c27:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c2a:	89 14 24             	mov    %edx,(%esp)
c0102c2d:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c32:	89 04 24             	mov    %eax,(%esp)
c0102c35:	e8 03 fe ff ff       	call   c0102a3d <__intr_restore>
}
c0102c3a:	90                   	nop
c0102c3b:	c9                   	leave  
c0102c3c:	c3                   	ret    

c0102c3d <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102c3d:	55                   	push   %ebp
c0102c3e:	89 e5                	mov    %esp,%ebp
c0102c40:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c43:	e8 cb fd ff ff       	call   c0102a13 <__intr_save>
c0102c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102c4b:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c50:	8b 40 14             	mov    0x14(%eax),%eax
c0102c53:	ff d0                	call   *%eax
c0102c55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c5b:	89 04 24             	mov    %eax,(%esp)
c0102c5e:	e8 da fd ff ff       	call   c0102a3d <__intr_restore>
    return ret;
c0102c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c66:	c9                   	leave  
c0102c67:	c3                   	ret    

c0102c68 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c68:	55                   	push   %ebp
c0102c69:	89 e5                	mov    %esp,%ebp
c0102c6b:	57                   	push   %edi
c0102c6c:	56                   	push   %esi
c0102c6d:	53                   	push   %ebx
c0102c6e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c74:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c7b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c82:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c89:	c7 04 24 27 66 10 c0 	movl   $0xc0106627,(%esp)
c0102c90:	e8 fd d5 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c95:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c9c:	e9 22 01 00 00       	jmp    c0102dc3 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102ca1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ca4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ca7:	89 d0                	mov    %edx,%eax
c0102ca9:	c1 e0 02             	shl    $0x2,%eax
c0102cac:	01 d0                	add    %edx,%eax
c0102cae:	c1 e0 02             	shl    $0x2,%eax
c0102cb1:	01 c8                	add    %ecx,%eax
c0102cb3:	8b 50 08             	mov    0x8(%eax),%edx
c0102cb6:	8b 40 04             	mov    0x4(%eax),%eax
c0102cb9:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102cbc:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102cbf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cc2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cc5:	89 d0                	mov    %edx,%eax
c0102cc7:	c1 e0 02             	shl    $0x2,%eax
c0102cca:	01 d0                	add    %edx,%eax
c0102ccc:	c1 e0 02             	shl    $0x2,%eax
c0102ccf:	01 c8                	add    %ecx,%eax
c0102cd1:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102cd4:	8b 58 10             	mov    0x10(%eax),%ebx
c0102cd7:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102cda:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102cdd:	01 c8                	add    %ecx,%eax
c0102cdf:	11 da                	adc    %ebx,%edx
c0102ce1:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102ce4:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102ce7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cea:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ced:	89 d0                	mov    %edx,%eax
c0102cef:	c1 e0 02             	shl    $0x2,%eax
c0102cf2:	01 d0                	add    %edx,%eax
c0102cf4:	c1 e0 02             	shl    $0x2,%eax
c0102cf7:	01 c8                	add    %ecx,%eax
c0102cf9:	83 c0 14             	add    $0x14,%eax
c0102cfc:	8b 00                	mov    (%eax),%eax
c0102cfe:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102d01:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102d04:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102d07:	83 c0 ff             	add    $0xffffffff,%eax
c0102d0a:	83 d2 ff             	adc    $0xffffffff,%edx
c0102d0d:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102d13:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102d19:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d1f:	89 d0                	mov    %edx,%eax
c0102d21:	c1 e0 02             	shl    $0x2,%eax
c0102d24:	01 d0                	add    %edx,%eax
c0102d26:	c1 e0 02             	shl    $0x2,%eax
c0102d29:	01 c8                	add    %ecx,%eax
c0102d2b:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102d2e:	8b 58 10             	mov    0x10(%eax),%ebx
c0102d31:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102d34:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102d38:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102d3e:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102d44:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102d48:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102d4c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102d4f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102d52:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d56:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102d5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d62:	c7 04 24 34 66 10 c0 	movl   $0xc0106634,(%esp)
c0102d69:	e8 24 d5 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d71:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d74:	89 d0                	mov    %edx,%eax
c0102d76:	c1 e0 02             	shl    $0x2,%eax
c0102d79:	01 d0                	add    %edx,%eax
c0102d7b:	c1 e0 02             	shl    $0x2,%eax
c0102d7e:	01 c8                	add    %ecx,%eax
c0102d80:	83 c0 14             	add    $0x14,%eax
c0102d83:	8b 00                	mov    (%eax),%eax
c0102d85:	83 f8 01             	cmp    $0x1,%eax
c0102d88:	75 36                	jne    c0102dc0 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d90:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d93:	77 2b                	ja     c0102dc0 <page_init+0x158>
c0102d95:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d98:	72 05                	jb     c0102d9f <page_init+0x137>
c0102d9a:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102d9d:	73 21                	jae    c0102dc0 <page_init+0x158>
c0102d9f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102da3:	77 1b                	ja     c0102dc0 <page_init+0x158>
c0102da5:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102da9:	72 09                	jb     c0102db4 <page_init+0x14c>
c0102dab:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102db2:	77 0c                	ja     c0102dc0 <page_init+0x158>
                maxpa = end;
c0102db4:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102db7:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102dbd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102dc0:	ff 45 dc             	incl   -0x24(%ebp)
c0102dc3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102dc6:	8b 00                	mov    (%eax),%eax
c0102dc8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102dcb:	0f 8c d0 fe ff ff    	jl     c0102ca1 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102dd1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102dd5:	72 1d                	jb     c0102df4 <page_init+0x18c>
c0102dd7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102ddb:	77 09                	ja     c0102de6 <page_init+0x17e>
c0102ddd:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102de4:	76 0e                	jbe    c0102df4 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102de6:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102df7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102dfa:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102dfe:	c1 ea 0c             	shr    $0xc,%edx
c0102e01:	89 c1                	mov    %eax,%ecx
c0102e03:	89 d3                	mov    %edx,%ebx
c0102e05:	89 c8                	mov    %ecx,%eax
c0102e07:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102e0c:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102e13:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0102e18:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e1b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102e1e:	01 d0                	add    %edx,%eax
c0102e20:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102e23:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102e26:	ba 00 00 00 00       	mov    $0x0,%edx
c0102e2b:	f7 75 c0             	divl   -0x40(%ebp)
c0102e2e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102e31:	29 d0                	sub    %edx,%eax
c0102e33:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    for (i = 0; i < npage; i ++) {
c0102e38:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e3f:	eb 2e                	jmp    c0102e6f <page_init+0x207>
        SetPageReserved(pages + i);
c0102e41:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e4a:	89 d0                	mov    %edx,%eax
c0102e4c:	c1 e0 02             	shl    $0x2,%eax
c0102e4f:	01 d0                	add    %edx,%eax
c0102e51:	c1 e0 02             	shl    $0x2,%eax
c0102e54:	01 c8                	add    %ecx,%eax
c0102e56:	83 c0 04             	add    $0x4,%eax
c0102e59:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102e60:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e63:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102e66:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102e69:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102e6c:	ff 45 dc             	incl   -0x24(%ebp)
c0102e6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e72:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102e77:	39 c2                	cmp    %eax,%edx
c0102e79:	72 c6                	jb     c0102e41 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e7b:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102e81:	89 d0                	mov    %edx,%eax
c0102e83:	c1 e0 02             	shl    $0x2,%eax
c0102e86:	01 d0                	add    %edx,%eax
c0102e88:	c1 e0 02             	shl    $0x2,%eax
c0102e8b:	89 c2                	mov    %eax,%edx
c0102e8d:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102e92:	01 d0                	add    %edx,%eax
c0102e94:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102e97:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0102e9e:	77 23                	ja     c0102ec3 <page_init+0x25b>
c0102ea0:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ea7:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0102eae:	c0 
c0102eaf:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0102eb6:	00 
c0102eb7:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0102ebe:	e8 26 d5 ff ff       	call   c01003e9 <__panic>
c0102ec3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ec6:	05 00 00 00 40       	add    $0x40000000,%eax
c0102ecb:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102ece:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ed5:	e9 69 01 00 00       	jmp    c0103043 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102eda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ee0:	89 d0                	mov    %edx,%eax
c0102ee2:	c1 e0 02             	shl    $0x2,%eax
c0102ee5:	01 d0                	add    %edx,%eax
c0102ee7:	c1 e0 02             	shl    $0x2,%eax
c0102eea:	01 c8                	add    %ecx,%eax
c0102eec:	8b 50 08             	mov    0x8(%eax),%edx
c0102eef:	8b 40 04             	mov    0x4(%eax),%eax
c0102ef2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ef5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102ef8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102efb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102efe:	89 d0                	mov    %edx,%eax
c0102f00:	c1 e0 02             	shl    $0x2,%eax
c0102f03:	01 d0                	add    %edx,%eax
c0102f05:	c1 e0 02             	shl    $0x2,%eax
c0102f08:	01 c8                	add    %ecx,%eax
c0102f0a:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102f0d:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f16:	01 c8                	add    %ecx,%eax
c0102f18:	11 da                	adc    %ebx,%edx
c0102f1a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102f1d:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102f20:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f23:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f26:	89 d0                	mov    %edx,%eax
c0102f28:	c1 e0 02             	shl    $0x2,%eax
c0102f2b:	01 d0                	add    %edx,%eax
c0102f2d:	c1 e0 02             	shl    $0x2,%eax
c0102f30:	01 c8                	add    %ecx,%eax
c0102f32:	83 c0 14             	add    $0x14,%eax
c0102f35:	8b 00                	mov    (%eax),%eax
c0102f37:	83 f8 01             	cmp    $0x1,%eax
c0102f3a:	0f 85 00 01 00 00    	jne    c0103040 <page_init+0x3d8>
            if (begin < freemem) {
c0102f40:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f43:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f48:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102f4b:	77 17                	ja     c0102f64 <page_init+0x2fc>
c0102f4d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102f50:	72 05                	jb     c0102f57 <page_init+0x2ef>
c0102f52:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0102f55:	73 0d                	jae    c0102f64 <page_init+0x2fc>
                begin = freemem;
c0102f57:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f5d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f64:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f68:	72 1d                	jb     c0102f87 <page_init+0x31f>
c0102f6a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f6e:	77 09                	ja     c0102f79 <page_init+0x311>
c0102f70:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f77:	76 0e                	jbe    c0102f87 <page_init+0x31f>
                end = KMEMSIZE;
c0102f79:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f80:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f87:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f8d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f90:	0f 87 aa 00 00 00    	ja     c0103040 <page_init+0x3d8>
c0102f96:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f99:	72 09                	jb     c0102fa4 <page_init+0x33c>
c0102f9b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f9e:	0f 83 9c 00 00 00    	jae    c0103040 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c0102fa4:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0102fab:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102fae:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102fb1:	01 d0                	add    %edx,%eax
c0102fb3:	48                   	dec    %eax
c0102fb4:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102fb7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102fba:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fbf:	f7 75 b0             	divl   -0x50(%ebp)
c0102fc2:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102fc5:	29 d0                	sub    %edx,%eax
c0102fc7:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fcc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fcf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102fd2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fd5:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102fd8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102fdb:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fe0:	89 c3                	mov    %eax,%ebx
c0102fe2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102fe8:	89 de                	mov    %ebx,%esi
c0102fea:	89 d0                	mov    %edx,%eax
c0102fec:	83 e0 00             	and    $0x0,%eax
c0102fef:	89 c7                	mov    %eax,%edi
c0102ff1:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102ff4:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102ff7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ffa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102ffd:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103000:	77 3e                	ja     c0103040 <page_init+0x3d8>
c0103002:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103005:	72 05                	jb     c010300c <page_init+0x3a4>
c0103007:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010300a:	73 34                	jae    c0103040 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010300c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010300f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103012:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103015:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103018:	89 c1                	mov    %eax,%ecx
c010301a:	89 d3                	mov    %edx,%ebx
c010301c:	89 c8                	mov    %ecx,%eax
c010301e:	89 da                	mov    %ebx,%edx
c0103020:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103024:	c1 ea 0c             	shr    $0xc,%edx
c0103027:	89 c3                	mov    %eax,%ebx
c0103029:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010302c:	89 04 24             	mov    %eax,(%esp)
c010302f:	e8 ae f8 ff ff       	call   c01028e2 <pa2page>
c0103034:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103038:	89 04 24             	mov    %eax,(%esp)
c010303b:	e8 72 fb ff ff       	call   c0102bb2 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0103040:	ff 45 dc             	incl   -0x24(%ebp)
c0103043:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103046:	8b 00                	mov    (%eax),%eax
c0103048:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010304b:	0f 8c 89 fe ff ff    	jl     c0102eda <page_init+0x272>
                }
            }
        }
    }
}
c0103051:	90                   	nop
c0103052:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103058:	5b                   	pop    %ebx
c0103059:	5e                   	pop    %esi
c010305a:	5f                   	pop    %edi
c010305b:	5d                   	pop    %ebp
c010305c:	c3                   	ret    

c010305d <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010305d:	55                   	push   %ebp
c010305e:	89 e5                	mov    %esp,%ebp
c0103060:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103063:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103066:	33 45 14             	xor    0x14(%ebp),%eax
c0103069:	25 ff 0f 00 00       	and    $0xfff,%eax
c010306e:	85 c0                	test   %eax,%eax
c0103070:	74 24                	je     c0103096 <boot_map_segment+0x39>
c0103072:	c7 44 24 0c 96 66 10 	movl   $0xc0106696,0xc(%esp)
c0103079:	c0 
c010307a:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103081:	c0 
c0103082:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0103089:	00 
c010308a:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103091:	e8 53 d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103096:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010309d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030a0:	25 ff 0f 00 00       	and    $0xfff,%eax
c01030a5:	89 c2                	mov    %eax,%edx
c01030a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01030aa:	01 c2                	add    %eax,%edx
c01030ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030af:	01 d0                	add    %edx,%eax
c01030b1:	48                   	dec    %eax
c01030b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01030b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030b8:	ba 00 00 00 00       	mov    $0x0,%edx
c01030bd:	f7 75 f0             	divl   -0x10(%ebp)
c01030c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030c3:	29 d0                	sub    %edx,%eax
c01030c5:	c1 e8 0c             	shr    $0xc,%eax
c01030c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01030cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01030d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01030d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030d9:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01030dc:	8b 45 14             	mov    0x14(%ebp),%eax
c01030df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01030e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01030e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030ea:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030ed:	eb 68                	jmp    c0103157 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01030ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01030f6:	00 
c01030f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01030fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103101:	89 04 24             	mov    %eax,(%esp)
c0103104:	e8 81 01 00 00       	call   c010328a <get_pte>
c0103109:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010310c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103110:	75 24                	jne    c0103136 <boot_map_segment+0xd9>
c0103112:	c7 44 24 0c c2 66 10 	movl   $0xc01066c2,0xc(%esp)
c0103119:	c0 
c010311a:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103121:	c0 
c0103122:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103129:	00 
c010312a:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103131:	e8 b3 d2 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103136:	8b 45 14             	mov    0x14(%ebp),%eax
c0103139:	0b 45 18             	or     0x18(%ebp),%eax
c010313c:	83 c8 01             	or     $0x1,%eax
c010313f:	89 c2                	mov    %eax,%edx
c0103141:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103144:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103146:	ff 4d f4             	decl   -0xc(%ebp)
c0103149:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103150:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103157:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010315b:	75 92                	jne    c01030ef <boot_map_segment+0x92>
    }
}
c010315d:	90                   	nop
c010315e:	c9                   	leave  
c010315f:	c3                   	ret    

c0103160 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0103160:	55                   	push   %ebp
c0103161:	89 e5                	mov    %esp,%ebp
c0103163:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103166:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010316d:	e8 60 fa ff ff       	call   c0102bd2 <alloc_pages>
c0103172:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103175:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103179:	75 1c                	jne    c0103197 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010317b:	c7 44 24 08 cf 66 10 	movl   $0xc01066cf,0x8(%esp)
c0103182:	c0 
c0103183:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010318a:	00 
c010318b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103192:	e8 52 d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c0103197:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010319a:	89 04 24             	mov    %eax,(%esp)
c010319d:	e8 8f f7 ff ff       	call   c0102931 <page2kva>
}
c01031a2:	c9                   	leave  
c01031a3:	c3                   	ret    

c01031a4 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01031a4:	55                   	push   %ebp
c01031a5:	89 e5                	mov    %esp,%ebp
c01031a7:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01031aa:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031af:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01031b2:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01031b9:	77 23                	ja     c01031de <pmm_init+0x3a>
c01031bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031be:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031c2:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c01031c9:	c0 
c01031ca:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01031d1:	00 
c01031d2:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01031d9:	e8 0b d2 ff ff       	call   c01003e9 <__panic>
c01031de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031e1:	05 00 00 00 40       	add    $0x40000000,%eax
c01031e6:	a3 14 af 11 c0       	mov    %eax,0xc011af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01031eb:	e8 8e f9 ff ff       	call   c0102b7e <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01031f0:	e8 73 fa ff ff       	call   c0102c68 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01031f5:	e8 4f 02 00 00       	call   c0103449 <check_alloc_page>

    check_pgdir();
c01031fa:	e8 69 02 00 00       	call   c0103468 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01031ff:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103204:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103207:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010320e:	77 23                	ja     c0103233 <pmm_init+0x8f>
c0103210:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103213:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103217:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c010321e:	c0 
c010321f:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0103226:	00 
c0103227:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010322e:	e8 b6 d1 ff ff       	call   c01003e9 <__panic>
c0103233:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103236:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010323c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103241:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103246:	83 ca 03             	or     $0x3,%edx
c0103249:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010324b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103250:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103257:	00 
c0103258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010325f:	00 
c0103260:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103267:	38 
c0103268:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010326f:	c0 
c0103270:	89 04 24             	mov    %eax,(%esp)
c0103273:	e8 e5 fd ff ff       	call   c010305d <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103278:	e8 18 f8 ff ff       	call   c0102a95 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010327d:	e8 82 08 00 00       	call   c0103b04 <check_boot_pgdir>

    print_pgdir();
c0103282:	e8 fb 0c 00 00       	call   c0103f82 <print_pgdir>

}
c0103287:	90                   	nop
c0103288:	c9                   	leave  
c0103289:	c3                   	ret    

c010328a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010328a:	55                   	push   %ebp
c010328b:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c010328d:	90                   	nop
c010328e:	5d                   	pop    %ebp
c010328f:	c3                   	ret    

c0103290 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103290:	55                   	push   %ebp
c0103291:	89 e5                	mov    %esp,%ebp
c0103293:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103296:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010329d:	00 
c010329e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01032a8:	89 04 24             	mov    %eax,(%esp)
c01032ab:	e8 da ff ff ff       	call   c010328a <get_pte>
c01032b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01032b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01032b7:	74 08                	je     c01032c1 <get_page+0x31>
        *ptep_store = ptep;
c01032b9:	8b 45 10             	mov    0x10(%ebp),%eax
c01032bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01032bf:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01032c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032c5:	74 1b                	je     c01032e2 <get_page+0x52>
c01032c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ca:	8b 00                	mov    (%eax),%eax
c01032cc:	83 e0 01             	and    $0x1,%eax
c01032cf:	85 c0                	test   %eax,%eax
c01032d1:	74 0f                	je     c01032e2 <get_page+0x52>
        return pte2page(*ptep);
c01032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032d6:	8b 00                	mov    (%eax),%eax
c01032d8:	89 04 24             	mov    %eax,(%esp)
c01032db:	e8 a5 f6 ff ff       	call   c0102985 <pte2page>
c01032e0:	eb 05                	jmp    c01032e7 <get_page+0x57>
    }
    return NULL;
c01032e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01032e7:	c9                   	leave  
c01032e8:	c3                   	ret    

c01032e9 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01032e9:	55                   	push   %ebp
c01032ea:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c01032ec:	90                   	nop
c01032ed:	5d                   	pop    %ebp
c01032ee:	c3                   	ret    

c01032ef <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01032ef:	55                   	push   %ebp
c01032f0:	89 e5                	mov    %esp,%ebp
c01032f2:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01032f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01032fc:	00 
c01032fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103300:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103304:	8b 45 08             	mov    0x8(%ebp),%eax
c0103307:	89 04 24             	mov    %eax,(%esp)
c010330a:	e8 7b ff ff ff       	call   c010328a <get_pte>
c010330f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c0103312:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103316:	74 19                	je     c0103331 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0103318:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010331b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010331f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103322:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103326:	8b 45 08             	mov    0x8(%ebp),%eax
c0103329:	89 04 24             	mov    %eax,(%esp)
c010332c:	e8 b8 ff ff ff       	call   c01032e9 <page_remove_pte>
    }
}
c0103331:	90                   	nop
c0103332:	c9                   	leave  
c0103333:	c3                   	ret    

c0103334 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103334:	55                   	push   %ebp
c0103335:	89 e5                	mov    %esp,%ebp
c0103337:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010333a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103341:	00 
c0103342:	8b 45 10             	mov    0x10(%ebp),%eax
c0103345:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103349:	8b 45 08             	mov    0x8(%ebp),%eax
c010334c:	89 04 24             	mov    %eax,(%esp)
c010334f:	e8 36 ff ff ff       	call   c010328a <get_pte>
c0103354:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010335b:	75 0a                	jne    c0103367 <page_insert+0x33>
        return -E_NO_MEM;
c010335d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103362:	e9 84 00 00 00       	jmp    c01033eb <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103367:	8b 45 0c             	mov    0xc(%ebp),%eax
c010336a:	89 04 24             	mov    %eax,(%esp)
c010336d:	e8 73 f6 ff ff       	call   c01029e5 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103372:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103375:	8b 00                	mov    (%eax),%eax
c0103377:	83 e0 01             	and    $0x1,%eax
c010337a:	85 c0                	test   %eax,%eax
c010337c:	74 3e                	je     c01033bc <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010337e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103381:	8b 00                	mov    (%eax),%eax
c0103383:	89 04 24             	mov    %eax,(%esp)
c0103386:	e8 fa f5 ff ff       	call   c0102985 <pte2page>
c010338b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010338e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103391:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103394:	75 0d                	jne    c01033a3 <page_insert+0x6f>
            page_ref_dec(page);
c0103396:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103399:	89 04 24             	mov    %eax,(%esp)
c010339c:	e8 5b f6 ff ff       	call   c01029fc <page_ref_dec>
c01033a1:	eb 19                	jmp    c01033bc <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01033aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01033ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b4:	89 04 24             	mov    %eax,(%esp)
c01033b7:	e8 2d ff ff ff       	call   c01032e9 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01033bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033bf:	89 04 24             	mov    %eax,(%esp)
c01033c2:	e8 05 f5 ff ff       	call   c01028cc <page2pa>
c01033c7:	0b 45 14             	or     0x14(%ebp),%eax
c01033ca:	83 c8 01             	or     $0x1,%eax
c01033cd:	89 c2                	mov    %eax,%edx
c01033cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01033d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01033d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033db:	8b 45 08             	mov    0x8(%ebp),%eax
c01033de:	89 04 24             	mov    %eax,(%esp)
c01033e1:	e8 07 00 00 00       	call   c01033ed <tlb_invalidate>
    return 0;
c01033e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01033eb:	c9                   	leave  
c01033ec:	c3                   	ret    

c01033ed <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01033ed:	55                   	push   %ebp
c01033ee:	89 e5                	mov    %esp,%ebp
c01033f0:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01033f3:	0f 20 d8             	mov    %cr3,%eax
c01033f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01033f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01033fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01033ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103402:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103409:	77 23                	ja     c010342e <tlb_invalidate+0x41>
c010340b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010340e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103412:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0103419:	c0 
c010341a:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c0103421:	00 
c0103422:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103429:	e8 bb cf ff ff       	call   c01003e9 <__panic>
c010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103431:	05 00 00 00 40       	add    $0x40000000,%eax
c0103436:	39 d0                	cmp    %edx,%eax
c0103438:	75 0c                	jne    c0103446 <tlb_invalidate+0x59>
        invlpg((void *)la);
c010343a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010343d:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103440:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103443:	0f 01 38             	invlpg (%eax)
    }
}
c0103446:	90                   	nop
c0103447:	c9                   	leave  
c0103448:	c3                   	ret    

c0103449 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103449:	55                   	push   %ebp
c010344a:	89 e5                	mov    %esp,%ebp
c010344c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010344f:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0103454:	8b 40 18             	mov    0x18(%eax),%eax
c0103457:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103459:	c7 04 24 e8 66 10 c0 	movl   $0xc01066e8,(%esp)
c0103460:	e8 2d ce ff ff       	call   c0100292 <cprintf>
}
c0103465:	90                   	nop
c0103466:	c9                   	leave  
c0103467:	c3                   	ret    

c0103468 <check_pgdir>:

static void
check_pgdir(void) {
c0103468:	55                   	push   %ebp
c0103469:	89 e5                	mov    %esp,%ebp
c010346b:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010346e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103473:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103478:	76 24                	jbe    c010349e <check_pgdir+0x36>
c010347a:	c7 44 24 0c 07 67 10 	movl   $0xc0106707,0xc(%esp)
c0103481:	c0 
c0103482:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103489:	c0 
c010348a:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0103491:	00 
c0103492:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103499:	e8 4b cf ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010349e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01034a3:	85 c0                	test   %eax,%eax
c01034a5:	74 0e                	je     c01034b5 <check_pgdir+0x4d>
c01034a7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01034ac:	25 ff 0f 00 00       	and    $0xfff,%eax
c01034b1:	85 c0                	test   %eax,%eax
c01034b3:	74 24                	je     c01034d9 <check_pgdir+0x71>
c01034b5:	c7 44 24 0c 24 67 10 	movl   $0xc0106724,0xc(%esp)
c01034bc:	c0 
c01034bd:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01034c4:	c0 
c01034c5:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c01034cc:	00 
c01034cd:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01034d4:	e8 10 cf ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01034d9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01034de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01034e5:	00 
c01034e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01034ed:	00 
c01034ee:	89 04 24             	mov    %eax,(%esp)
c01034f1:	e8 9a fd ff ff       	call   c0103290 <get_page>
c01034f6:	85 c0                	test   %eax,%eax
c01034f8:	74 24                	je     c010351e <check_pgdir+0xb6>
c01034fa:	c7 44 24 0c 5c 67 10 	movl   $0xc010675c,0xc(%esp)
c0103501:	c0 
c0103502:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103509:	c0 
c010350a:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0103511:	00 
c0103512:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103519:	e8 cb ce ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010351e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103525:	e8 a8 f6 ff ff       	call   c0102bd2 <alloc_pages>
c010352a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010352d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103532:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103539:	00 
c010353a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103541:	00 
c0103542:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103545:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103549:	89 04 24             	mov    %eax,(%esp)
c010354c:	e8 e3 fd ff ff       	call   c0103334 <page_insert>
c0103551:	85 c0                	test   %eax,%eax
c0103553:	74 24                	je     c0103579 <check_pgdir+0x111>
c0103555:	c7 44 24 0c 84 67 10 	movl   $0xc0106784,0xc(%esp)
c010355c:	c0 
c010355d:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103564:	c0 
c0103565:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c010356c:	00 
c010356d:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103574:	e8 70 ce ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103579:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010357e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103585:	00 
c0103586:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010358d:	00 
c010358e:	89 04 24             	mov    %eax,(%esp)
c0103591:	e8 f4 fc ff ff       	call   c010328a <get_pte>
c0103596:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103599:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010359d:	75 24                	jne    c01035c3 <check_pgdir+0x15b>
c010359f:	c7 44 24 0c b0 67 10 	movl   $0xc01067b0,0xc(%esp)
c01035a6:	c0 
c01035a7:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01035ae:	c0 
c01035af:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c01035b6:	00 
c01035b7:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01035be:	e8 26 ce ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c01035c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035c6:	8b 00                	mov    (%eax),%eax
c01035c8:	89 04 24             	mov    %eax,(%esp)
c01035cb:	e8 b5 f3 ff ff       	call   c0102985 <pte2page>
c01035d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01035d3:	74 24                	je     c01035f9 <check_pgdir+0x191>
c01035d5:	c7 44 24 0c dd 67 10 	movl   $0xc01067dd,0xc(%esp)
c01035dc:	c0 
c01035dd:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01035e4:	c0 
c01035e5:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c01035ec:	00 
c01035ed:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01035f4:	e8 f0 cd ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c01035f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035fc:	89 04 24             	mov    %eax,(%esp)
c01035ff:	e8 d7 f3 ff ff       	call   c01029db <page_ref>
c0103604:	83 f8 01             	cmp    $0x1,%eax
c0103607:	74 24                	je     c010362d <check_pgdir+0x1c5>
c0103609:	c7 44 24 0c f3 67 10 	movl   $0xc01067f3,0xc(%esp)
c0103610:	c0 
c0103611:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103618:	c0 
c0103619:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c0103620:	00 
c0103621:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103628:	e8 bc cd ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010362d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103632:	8b 00                	mov    (%eax),%eax
c0103634:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103639:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010363c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010363f:	c1 e8 0c             	shr    $0xc,%eax
c0103642:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103645:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010364a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010364d:	72 23                	jb     c0103672 <check_pgdir+0x20a>
c010364f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103652:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103656:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c010365d:	c0 
c010365e:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c0103665:	00 
c0103666:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010366d:	e8 77 cd ff ff       	call   c01003e9 <__panic>
c0103672:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103675:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010367a:	83 c0 04             	add    $0x4,%eax
c010367d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103680:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103685:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010368c:	00 
c010368d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103694:	00 
c0103695:	89 04 24             	mov    %eax,(%esp)
c0103698:	e8 ed fb ff ff       	call   c010328a <get_pte>
c010369d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01036a0:	74 24                	je     c01036c6 <check_pgdir+0x25e>
c01036a2:	c7 44 24 0c 08 68 10 	movl   $0xc0106808,0xc(%esp)
c01036a9:	c0 
c01036aa:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01036b1:	c0 
c01036b2:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c01036b9:	00 
c01036ba:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01036c1:	e8 23 cd ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c01036c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036cd:	e8 00 f5 ff ff       	call   c0102bd2 <alloc_pages>
c01036d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01036d5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036da:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01036e1:	00 
c01036e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01036e9:	00 
c01036ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01036ed:	89 54 24 04          	mov    %edx,0x4(%esp)
c01036f1:	89 04 24             	mov    %eax,(%esp)
c01036f4:	e8 3b fc ff ff       	call   c0103334 <page_insert>
c01036f9:	85 c0                	test   %eax,%eax
c01036fb:	74 24                	je     c0103721 <check_pgdir+0x2b9>
c01036fd:	c7 44 24 0c 30 68 10 	movl   $0xc0106830,0xc(%esp)
c0103704:	c0 
c0103705:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010370c:	c0 
c010370d:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0103714:	00 
c0103715:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010371c:	e8 c8 cc ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103721:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103726:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010372d:	00 
c010372e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103735:	00 
c0103736:	89 04 24             	mov    %eax,(%esp)
c0103739:	e8 4c fb ff ff       	call   c010328a <get_pte>
c010373e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103741:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103745:	75 24                	jne    c010376b <check_pgdir+0x303>
c0103747:	c7 44 24 0c 68 68 10 	movl   $0xc0106868,0xc(%esp)
c010374e:	c0 
c010374f:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103756:	c0 
c0103757:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c010375e:	00 
c010375f:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103766:	e8 7e cc ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c010376b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010376e:	8b 00                	mov    (%eax),%eax
c0103770:	83 e0 04             	and    $0x4,%eax
c0103773:	85 c0                	test   %eax,%eax
c0103775:	75 24                	jne    c010379b <check_pgdir+0x333>
c0103777:	c7 44 24 0c 98 68 10 	movl   $0xc0106898,0xc(%esp)
c010377e:	c0 
c010377f:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103786:	c0 
c0103787:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c010378e:	00 
c010378f:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103796:	e8 4e cc ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c010379b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010379e:	8b 00                	mov    (%eax),%eax
c01037a0:	83 e0 02             	and    $0x2,%eax
c01037a3:	85 c0                	test   %eax,%eax
c01037a5:	75 24                	jne    c01037cb <check_pgdir+0x363>
c01037a7:	c7 44 24 0c a6 68 10 	movl   $0xc01068a6,0xc(%esp)
c01037ae:	c0 
c01037af:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01037b6:	c0 
c01037b7:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c01037be:	00 
c01037bf:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01037c6:	e8 1e cc ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01037cb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037d0:	8b 00                	mov    (%eax),%eax
c01037d2:	83 e0 04             	and    $0x4,%eax
c01037d5:	85 c0                	test   %eax,%eax
c01037d7:	75 24                	jne    c01037fd <check_pgdir+0x395>
c01037d9:	c7 44 24 0c b4 68 10 	movl   $0xc01068b4,0xc(%esp)
c01037e0:	c0 
c01037e1:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01037e8:	c0 
c01037e9:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c01037f0:	00 
c01037f1:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01037f8:	e8 ec cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c01037fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103800:	89 04 24             	mov    %eax,(%esp)
c0103803:	e8 d3 f1 ff ff       	call   c01029db <page_ref>
c0103808:	83 f8 01             	cmp    $0x1,%eax
c010380b:	74 24                	je     c0103831 <check_pgdir+0x3c9>
c010380d:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c0103814:	c0 
c0103815:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010381c:	c0 
c010381d:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0103824:	00 
c0103825:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010382c:	e8 b8 cb ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103831:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103836:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010383d:	00 
c010383e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103845:	00 
c0103846:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103849:	89 54 24 04          	mov    %edx,0x4(%esp)
c010384d:	89 04 24             	mov    %eax,(%esp)
c0103850:	e8 df fa ff ff       	call   c0103334 <page_insert>
c0103855:	85 c0                	test   %eax,%eax
c0103857:	74 24                	je     c010387d <check_pgdir+0x415>
c0103859:	c7 44 24 0c dc 68 10 	movl   $0xc01068dc,0xc(%esp)
c0103860:	c0 
c0103861:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103868:	c0 
c0103869:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0103870:	00 
c0103871:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103878:	e8 6c cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c010387d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103880:	89 04 24             	mov    %eax,(%esp)
c0103883:	e8 53 f1 ff ff       	call   c01029db <page_ref>
c0103888:	83 f8 02             	cmp    $0x2,%eax
c010388b:	74 24                	je     c01038b1 <check_pgdir+0x449>
c010388d:	c7 44 24 0c 08 69 10 	movl   $0xc0106908,0xc(%esp)
c0103894:	c0 
c0103895:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010389c:	c0 
c010389d:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c01038a4:	00 
c01038a5:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01038ac:	e8 38 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c01038b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038b4:	89 04 24             	mov    %eax,(%esp)
c01038b7:	e8 1f f1 ff ff       	call   c01029db <page_ref>
c01038bc:	85 c0                	test   %eax,%eax
c01038be:	74 24                	je     c01038e4 <check_pgdir+0x47c>
c01038c0:	c7 44 24 0c 1a 69 10 	movl   $0xc010691a,0xc(%esp)
c01038c7:	c0 
c01038c8:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01038cf:	c0 
c01038d0:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c01038d7:	00 
c01038d8:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01038df:	e8 05 cb ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01038e4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01038e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038f0:	00 
c01038f1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01038f8:	00 
c01038f9:	89 04 24             	mov    %eax,(%esp)
c01038fc:	e8 89 f9 ff ff       	call   c010328a <get_pte>
c0103901:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103904:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103908:	75 24                	jne    c010392e <check_pgdir+0x4c6>
c010390a:	c7 44 24 0c 68 68 10 	movl   $0xc0106868,0xc(%esp)
c0103911:	c0 
c0103912:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103919:	c0 
c010391a:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103921:	00 
c0103922:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103929:	e8 bb ca ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c010392e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103931:	8b 00                	mov    (%eax),%eax
c0103933:	89 04 24             	mov    %eax,(%esp)
c0103936:	e8 4a f0 ff ff       	call   c0102985 <pte2page>
c010393b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010393e:	74 24                	je     c0103964 <check_pgdir+0x4fc>
c0103940:	c7 44 24 0c dd 67 10 	movl   $0xc01067dd,0xc(%esp)
c0103947:	c0 
c0103948:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010394f:	c0 
c0103950:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103957:	00 
c0103958:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010395f:	e8 85 ca ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103964:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103967:	8b 00                	mov    (%eax),%eax
c0103969:	83 e0 04             	and    $0x4,%eax
c010396c:	85 c0                	test   %eax,%eax
c010396e:	74 24                	je     c0103994 <check_pgdir+0x52c>
c0103970:	c7 44 24 0c 2c 69 10 	movl   $0xc010692c,0xc(%esp)
c0103977:	c0 
c0103978:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c010397f:	c0 
c0103980:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103987:	00 
c0103988:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c010398f:	e8 55 ca ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103994:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103999:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01039a0:	00 
c01039a1:	89 04 24             	mov    %eax,(%esp)
c01039a4:	e8 46 f9 ff ff       	call   c01032ef <page_remove>
    assert(page_ref(p1) == 1);
c01039a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039ac:	89 04 24             	mov    %eax,(%esp)
c01039af:	e8 27 f0 ff ff       	call   c01029db <page_ref>
c01039b4:	83 f8 01             	cmp    $0x1,%eax
c01039b7:	74 24                	je     c01039dd <check_pgdir+0x575>
c01039b9:	c7 44 24 0c f3 67 10 	movl   $0xc01067f3,0xc(%esp)
c01039c0:	c0 
c01039c1:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01039c8:	c0 
c01039c9:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c01039d0:	00 
c01039d1:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c01039d8:	e8 0c ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c01039dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039e0:	89 04 24             	mov    %eax,(%esp)
c01039e3:	e8 f3 ef ff ff       	call   c01029db <page_ref>
c01039e8:	85 c0                	test   %eax,%eax
c01039ea:	74 24                	je     c0103a10 <check_pgdir+0x5a8>
c01039ec:	c7 44 24 0c 1a 69 10 	movl   $0xc010691a,0xc(%esp)
c01039f3:	c0 
c01039f4:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c01039fb:	c0 
c01039fc:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103a03:	00 
c0103a04:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103a0b:	e8 d9 c9 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103a10:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a15:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a1c:	00 
c0103a1d:	89 04 24             	mov    %eax,(%esp)
c0103a20:	e8 ca f8 ff ff       	call   c01032ef <page_remove>
    assert(page_ref(p1) == 0);
c0103a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a28:	89 04 24             	mov    %eax,(%esp)
c0103a2b:	e8 ab ef ff ff       	call   c01029db <page_ref>
c0103a30:	85 c0                	test   %eax,%eax
c0103a32:	74 24                	je     c0103a58 <check_pgdir+0x5f0>
c0103a34:	c7 44 24 0c 41 69 10 	movl   $0xc0106941,0xc(%esp)
c0103a3b:	c0 
c0103a3c:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103a43:	c0 
c0103a44:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103a4b:	00 
c0103a4c:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103a53:	e8 91 c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a5b:	89 04 24             	mov    %eax,(%esp)
c0103a5e:	e8 78 ef ff ff       	call   c01029db <page_ref>
c0103a63:	85 c0                	test   %eax,%eax
c0103a65:	74 24                	je     c0103a8b <check_pgdir+0x623>
c0103a67:	c7 44 24 0c 1a 69 10 	movl   $0xc010691a,0xc(%esp)
c0103a6e:	c0 
c0103a6f:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103a76:	c0 
c0103a77:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103a7e:	00 
c0103a7f:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103a86:	e8 5e c9 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103a8b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a90:	8b 00                	mov    (%eax),%eax
c0103a92:	89 04 24             	mov    %eax,(%esp)
c0103a95:	e8 29 ef ff ff       	call   c01029c3 <pde2page>
c0103a9a:	89 04 24             	mov    %eax,(%esp)
c0103a9d:	e8 39 ef ff ff       	call   c01029db <page_ref>
c0103aa2:	83 f8 01             	cmp    $0x1,%eax
c0103aa5:	74 24                	je     c0103acb <check_pgdir+0x663>
c0103aa7:	c7 44 24 0c 54 69 10 	movl   $0xc0106954,0xc(%esp)
c0103aae:	c0 
c0103aaf:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103ab6:	c0 
c0103ab7:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103abe:	00 
c0103abf:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103ac6:	e8 1e c9 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103acb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ad0:	8b 00                	mov    (%eax),%eax
c0103ad2:	89 04 24             	mov    %eax,(%esp)
c0103ad5:	e8 e9 ee ff ff       	call   c01029c3 <pde2page>
c0103ada:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ae1:	00 
c0103ae2:	89 04 24             	mov    %eax,(%esp)
c0103ae5:	e8 20 f1 ff ff       	call   c0102c0a <free_pages>
    boot_pgdir[0] = 0;
c0103aea:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103aef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103af5:	c7 04 24 7b 69 10 c0 	movl   $0xc010697b,(%esp)
c0103afc:	e8 91 c7 ff ff       	call   c0100292 <cprintf>
}
c0103b01:	90                   	nop
c0103b02:	c9                   	leave  
c0103b03:	c3                   	ret    

c0103b04 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103b04:	55                   	push   %ebp
c0103b05:	89 e5                	mov    %esp,%ebp
c0103b07:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103b0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b11:	e9 ca 00 00 00       	jmp    c0103be0 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b1f:	c1 e8 0c             	shr    $0xc,%eax
c0103b22:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103b25:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b2a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103b2d:	72 23                	jb     c0103b52 <check_boot_pgdir+0x4e>
c0103b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b32:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b36:	c7 44 24 08 c0 65 10 	movl   $0xc01065c0,0x8(%esp)
c0103b3d:	c0 
c0103b3e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103b45:	00 
c0103b46:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103b4d:	e8 97 c8 ff ff       	call   c01003e9 <__panic>
c0103b52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b55:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103b5a:	89 c2                	mov    %eax,%edx
c0103b5c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b68:	00 
c0103b69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b6d:	89 04 24             	mov    %eax,(%esp)
c0103b70:	e8 15 f7 ff ff       	call   c010328a <get_pte>
c0103b75:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103b78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103b7c:	75 24                	jne    c0103ba2 <check_boot_pgdir+0x9e>
c0103b7e:	c7 44 24 0c 98 69 10 	movl   $0xc0106998,0xc(%esp)
c0103b85:	c0 
c0103b86:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103b8d:	c0 
c0103b8e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103b95:	00 
c0103b96:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103b9d:	e8 47 c8 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103ba2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ba5:	8b 00                	mov    (%eax),%eax
c0103ba7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103bac:	89 c2                	mov    %eax,%edx
c0103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bb1:	39 c2                	cmp    %eax,%edx
c0103bb3:	74 24                	je     c0103bd9 <check_boot_pgdir+0xd5>
c0103bb5:	c7 44 24 0c d5 69 10 	movl   $0xc01069d5,0xc(%esp)
c0103bbc:	c0 
c0103bbd:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103bc4:	c0 
c0103bc5:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103bcc:	00 
c0103bcd:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103bd4:	e8 10 c8 ff ff       	call   c01003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103bd9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103be0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103be3:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103be8:	39 c2                	cmp    %eax,%edx
c0103bea:	0f 82 26 ff ff ff    	jb     c0103b16 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103bf0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103bf5:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103bfa:	8b 00                	mov    (%eax),%eax
c0103bfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c01:	89 c2                	mov    %eax,%edx
c0103c03:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c08:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c0b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103c12:	77 23                	ja     c0103c37 <check_boot_pgdir+0x133>
c0103c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c17:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c1b:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0103c22:	c0 
c0103c23:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103c2a:	00 
c0103c2b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103c32:	e8 b2 c7 ff ff       	call   c01003e9 <__panic>
c0103c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c3a:	05 00 00 00 40       	add    $0x40000000,%eax
c0103c3f:	39 d0                	cmp    %edx,%eax
c0103c41:	74 24                	je     c0103c67 <check_boot_pgdir+0x163>
c0103c43:	c7 44 24 0c ec 69 10 	movl   $0xc01069ec,0xc(%esp)
c0103c4a:	c0 
c0103c4b:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103c52:	c0 
c0103c53:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103c5a:	00 
c0103c5b:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103c62:	e8 82 c7 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103c67:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c6c:	8b 00                	mov    (%eax),%eax
c0103c6e:	85 c0                	test   %eax,%eax
c0103c70:	74 24                	je     c0103c96 <check_boot_pgdir+0x192>
c0103c72:	c7 44 24 0c 20 6a 10 	movl   $0xc0106a20,0xc(%esp)
c0103c79:	c0 
c0103c7a:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103c81:	c0 
c0103c82:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103c89:	00 
c0103c8a:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103c91:	e8 53 c7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c9d:	e8 30 ef ff ff       	call   c0102bd2 <alloc_pages>
c0103ca2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103ca5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103caa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103cb1:	00 
c0103cb2:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103cb9:	00 
c0103cba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103cbd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103cc1:	89 04 24             	mov    %eax,(%esp)
c0103cc4:	e8 6b f6 ff ff       	call   c0103334 <page_insert>
c0103cc9:	85 c0                	test   %eax,%eax
c0103ccb:	74 24                	je     c0103cf1 <check_boot_pgdir+0x1ed>
c0103ccd:	c7 44 24 0c 34 6a 10 	movl   $0xc0106a34,0xc(%esp)
c0103cd4:	c0 
c0103cd5:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103cdc:	c0 
c0103cdd:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103ce4:	00 
c0103ce5:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103cec:	e8 f8 c6 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103cf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cf4:	89 04 24             	mov    %eax,(%esp)
c0103cf7:	e8 df ec ff ff       	call   c01029db <page_ref>
c0103cfc:	83 f8 01             	cmp    $0x1,%eax
c0103cff:	74 24                	je     c0103d25 <check_boot_pgdir+0x221>
c0103d01:	c7 44 24 0c 62 6a 10 	movl   $0xc0106a62,0xc(%esp)
c0103d08:	c0 
c0103d09:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103d10:	c0 
c0103d11:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103d18:	00 
c0103d19:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103d20:	e8 c4 c6 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103d25:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d2a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103d31:	00 
c0103d32:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103d39:	00 
c0103d3a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103d3d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d41:	89 04 24             	mov    %eax,(%esp)
c0103d44:	e8 eb f5 ff ff       	call   c0103334 <page_insert>
c0103d49:	85 c0                	test   %eax,%eax
c0103d4b:	74 24                	je     c0103d71 <check_boot_pgdir+0x26d>
c0103d4d:	c7 44 24 0c 74 6a 10 	movl   $0xc0106a74,0xc(%esp)
c0103d54:	c0 
c0103d55:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103d5c:	c0 
c0103d5d:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103d64:	00 
c0103d65:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103d6c:	e8 78 c6 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103d71:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d74:	89 04 24             	mov    %eax,(%esp)
c0103d77:	e8 5f ec ff ff       	call   c01029db <page_ref>
c0103d7c:	83 f8 02             	cmp    $0x2,%eax
c0103d7f:	74 24                	je     c0103da5 <check_boot_pgdir+0x2a1>
c0103d81:	c7 44 24 0c ab 6a 10 	movl   $0xc0106aab,0xc(%esp)
c0103d88:	c0 
c0103d89:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103d90:	c0 
c0103d91:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103d98:	00 
c0103d99:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103da0:	e8 44 c6 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103da5:	c7 45 e8 bc 6a 10 c0 	movl   $0xc0106abc,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0103dac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103daf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103db3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103dba:	e8 e0 15 00 00       	call   c010539f <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103dbf:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103dc6:	00 
c0103dc7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103dce:	e8 43 16 00 00       	call   c0105416 <strcmp>
c0103dd3:	85 c0                	test   %eax,%eax
c0103dd5:	74 24                	je     c0103dfb <check_boot_pgdir+0x2f7>
c0103dd7:	c7 44 24 0c d4 6a 10 	movl   $0xc0106ad4,0xc(%esp)
c0103dde:	c0 
c0103ddf:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103de6:	c0 
c0103de7:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0103dee:	00 
c0103def:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103df6:	e8 ee c5 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103dfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dfe:	89 04 24             	mov    %eax,(%esp)
c0103e01:	e8 2b eb ff ff       	call   c0102931 <page2kva>
c0103e06:	05 00 01 00 00       	add    $0x100,%eax
c0103e0b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103e0e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103e15:	e8 2f 15 00 00       	call   c0105349 <strlen>
c0103e1a:	85 c0                	test   %eax,%eax
c0103e1c:	74 24                	je     c0103e42 <check_boot_pgdir+0x33e>
c0103e1e:	c7 44 24 0c 0c 6b 10 	movl   $0xc0106b0c,0xc(%esp)
c0103e25:	c0 
c0103e26:	c7 44 24 08 ad 66 10 	movl   $0xc01066ad,0x8(%esp)
c0103e2d:	c0 
c0103e2e:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0103e35:	00 
c0103e36:	c7 04 24 88 66 10 c0 	movl   $0xc0106688,(%esp)
c0103e3d:	e8 a7 c5 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0103e42:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e49:	00 
c0103e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e4d:	89 04 24             	mov    %eax,(%esp)
c0103e50:	e8 b5 ed ff ff       	call   c0102c0a <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103e55:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e5a:	8b 00                	mov    (%eax),%eax
c0103e5c:	89 04 24             	mov    %eax,(%esp)
c0103e5f:	e8 5f eb ff ff       	call   c01029c3 <pde2page>
c0103e64:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e6b:	00 
c0103e6c:	89 04 24             	mov    %eax,(%esp)
c0103e6f:	e8 96 ed ff ff       	call   c0102c0a <free_pages>
    boot_pgdir[0] = 0;
c0103e74:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103e7f:	c7 04 24 30 6b 10 c0 	movl   $0xc0106b30,(%esp)
c0103e86:	e8 07 c4 ff ff       	call   c0100292 <cprintf>
}
c0103e8b:	90                   	nop
c0103e8c:	c9                   	leave  
c0103e8d:	c3                   	ret    

c0103e8e <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103e8e:	55                   	push   %ebp
c0103e8f:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103e91:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e94:	83 e0 04             	and    $0x4,%eax
c0103e97:	85 c0                	test   %eax,%eax
c0103e99:	74 04                	je     c0103e9f <perm2str+0x11>
c0103e9b:	b0 75                	mov    $0x75,%al
c0103e9d:	eb 02                	jmp    c0103ea1 <perm2str+0x13>
c0103e9f:	b0 2d                	mov    $0x2d,%al
c0103ea1:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0103ea6:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103ead:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eb0:	83 e0 02             	and    $0x2,%eax
c0103eb3:	85 c0                	test   %eax,%eax
c0103eb5:	74 04                	je     c0103ebb <perm2str+0x2d>
c0103eb7:	b0 77                	mov    $0x77,%al
c0103eb9:	eb 02                	jmp    c0103ebd <perm2str+0x2f>
c0103ebb:	b0 2d                	mov    $0x2d,%al
c0103ebd:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0103ec2:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0103ec9:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0103ece:	5d                   	pop    %ebp
c0103ecf:	c3                   	ret    

c0103ed0 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103ed0:	55                   	push   %ebp
c0103ed1:	89 e5                	mov    %esp,%ebp
c0103ed3:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103ed6:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ed9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103edc:	72 0d                	jb     c0103eeb <get_pgtable_items+0x1b>
        return 0;
c0103ede:	b8 00 00 00 00       	mov    $0x0,%eax
c0103ee3:	e9 98 00 00 00       	jmp    c0103f80 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0103ee8:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0103eeb:	8b 45 10             	mov    0x10(%ebp),%eax
c0103eee:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103ef1:	73 18                	jae    c0103f0b <get_pgtable_items+0x3b>
c0103ef3:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ef6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103efd:	8b 45 14             	mov    0x14(%ebp),%eax
c0103f00:	01 d0                	add    %edx,%eax
c0103f02:	8b 00                	mov    (%eax),%eax
c0103f04:	83 e0 01             	and    $0x1,%eax
c0103f07:	85 c0                	test   %eax,%eax
c0103f09:	74 dd                	je     c0103ee8 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0103f0b:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f0e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103f11:	73 68                	jae    c0103f7b <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0103f13:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103f17:	74 08                	je     c0103f21 <get_pgtable_items+0x51>
            *left_store = start;
c0103f19:	8b 45 18             	mov    0x18(%ebp),%eax
c0103f1c:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f1f:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0103f21:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f24:	8d 50 01             	lea    0x1(%eax),%edx
c0103f27:	89 55 10             	mov    %edx,0x10(%ebp)
c0103f2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103f31:	8b 45 14             	mov    0x14(%ebp),%eax
c0103f34:	01 d0                	add    %edx,%eax
c0103f36:	8b 00                	mov    (%eax),%eax
c0103f38:	83 e0 07             	and    $0x7,%eax
c0103f3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103f3e:	eb 03                	jmp    c0103f43 <get_pgtable_items+0x73>
            start ++;
c0103f40:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103f43:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f46:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103f49:	73 1d                	jae    c0103f68 <get_pgtable_items+0x98>
c0103f4b:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103f55:	8b 45 14             	mov    0x14(%ebp),%eax
c0103f58:	01 d0                	add    %edx,%eax
c0103f5a:	8b 00                	mov    (%eax),%eax
c0103f5c:	83 e0 07             	and    $0x7,%eax
c0103f5f:	89 c2                	mov    %eax,%edx
c0103f61:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103f64:	39 c2                	cmp    %eax,%edx
c0103f66:	74 d8                	je     c0103f40 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0103f68:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103f6c:	74 08                	je     c0103f76 <get_pgtable_items+0xa6>
            *right_store = start;
c0103f6e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103f71:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f74:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0103f76:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103f79:	eb 05                	jmp    c0103f80 <get_pgtable_items+0xb0>
    }
    return 0;
c0103f7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103f80:	c9                   	leave  
c0103f81:	c3                   	ret    

c0103f82 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0103f82:	55                   	push   %ebp
c0103f83:	89 e5                	mov    %esp,%ebp
c0103f85:	57                   	push   %edi
c0103f86:	56                   	push   %esi
c0103f87:	53                   	push   %ebx
c0103f88:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0103f8b:	c7 04 24 50 6b 10 c0 	movl   $0xc0106b50,(%esp)
c0103f92:	e8 fb c2 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0103f97:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103f9e:	e9 fa 00 00 00       	jmp    c010409d <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fa6:	89 04 24             	mov    %eax,(%esp)
c0103fa9:	e8 e0 fe ff ff       	call   c0103e8e <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0103fae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0103fb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fb4:	29 d1                	sub    %edx,%ecx
c0103fb6:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103fb8:	89 d6                	mov    %edx,%esi
c0103fba:	c1 e6 16             	shl    $0x16,%esi
c0103fbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fc0:	89 d3                	mov    %edx,%ebx
c0103fc2:	c1 e3 16             	shl    $0x16,%ebx
c0103fc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fc8:	89 d1                	mov    %edx,%ecx
c0103fca:	c1 e1 16             	shl    $0x16,%ecx
c0103fcd:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0103fd0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fd3:	29 d7                	sub    %edx,%edi
c0103fd5:	89 fa                	mov    %edi,%edx
c0103fd7:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103fdb:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103fdf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103fe3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103fe7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103feb:	c7 04 24 81 6b 10 c0 	movl   $0xc0106b81,(%esp)
c0103ff2:	e8 9b c2 ff ff       	call   c0100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0103ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ffa:	c1 e0 0a             	shl    $0xa,%eax
c0103ffd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104000:	eb 54                	jmp    c0104056 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104002:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104005:	89 04 24             	mov    %eax,(%esp)
c0104008:	e8 81 fe ff ff       	call   c0103e8e <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010400d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104010:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104013:	29 d1                	sub    %edx,%ecx
c0104015:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104017:	89 d6                	mov    %edx,%esi
c0104019:	c1 e6 0c             	shl    $0xc,%esi
c010401c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010401f:	89 d3                	mov    %edx,%ebx
c0104021:	c1 e3 0c             	shl    $0xc,%ebx
c0104024:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104027:	89 d1                	mov    %edx,%ecx
c0104029:	c1 e1 0c             	shl    $0xc,%ecx
c010402c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010402f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104032:	29 d7                	sub    %edx,%edi
c0104034:	89 fa                	mov    %edi,%edx
c0104036:	89 44 24 14          	mov    %eax,0x14(%esp)
c010403a:	89 74 24 10          	mov    %esi,0x10(%esp)
c010403e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104042:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104046:	89 54 24 04          	mov    %edx,0x4(%esp)
c010404a:	c7 04 24 a0 6b 10 c0 	movl   $0xc0106ba0,(%esp)
c0104051:	e8 3c c2 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104056:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010405b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010405e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104061:	89 d3                	mov    %edx,%ebx
c0104063:	c1 e3 0a             	shl    $0xa,%ebx
c0104066:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104069:	89 d1                	mov    %edx,%ecx
c010406b:	c1 e1 0a             	shl    $0xa,%ecx
c010406e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104071:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104075:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104078:	89 54 24 10          	mov    %edx,0x10(%esp)
c010407c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104080:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104088:	89 0c 24             	mov    %ecx,(%esp)
c010408b:	e8 40 fe ff ff       	call   c0103ed0 <get_pgtable_items>
c0104090:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104093:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104097:	0f 85 65 ff ff ff    	jne    c0104002 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010409d:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01040a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01040a5:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01040a8:	89 54 24 14          	mov    %edx,0x14(%esp)
c01040ac:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01040af:	89 54 24 10          	mov    %edx,0x10(%esp)
c01040b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01040b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01040bb:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01040c2:	00 
c01040c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01040ca:	e8 01 fe ff ff       	call   c0103ed0 <get_pgtable_items>
c01040cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01040d6:	0f 85 c7 fe ff ff    	jne    c0103fa3 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01040dc:	c7 04 24 c4 6b 10 c0 	movl   $0xc0106bc4,(%esp)
c01040e3:	e8 aa c1 ff ff       	call   c0100292 <cprintf>
}
c01040e8:	90                   	nop
c01040e9:	83 c4 4c             	add    $0x4c,%esp
c01040ec:	5b                   	pop    %ebx
c01040ed:	5e                   	pop    %esi
c01040ee:	5f                   	pop    %edi
c01040ef:	5d                   	pop    %ebp
c01040f0:	c3                   	ret    

c01040f1 <page2ppn>:
page2ppn(struct Page *page) {
c01040f1:	55                   	push   %ebp
c01040f2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01040f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01040f7:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c01040fd:	29 d0                	sub    %edx,%eax
c01040ff:	c1 f8 02             	sar    $0x2,%eax
c0104102:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104108:	5d                   	pop    %ebp
c0104109:	c3                   	ret    

c010410a <page2pa>:
page2pa(struct Page *page) {
c010410a:	55                   	push   %ebp
c010410b:	89 e5                	mov    %esp,%ebp
c010410d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104110:	8b 45 08             	mov    0x8(%ebp),%eax
c0104113:	89 04 24             	mov    %eax,(%esp)
c0104116:	e8 d6 ff ff ff       	call   c01040f1 <page2ppn>
c010411b:	c1 e0 0c             	shl    $0xc,%eax
}
c010411e:	c9                   	leave  
c010411f:	c3                   	ret    

c0104120 <page_ref>:
page_ref(struct Page *page) {
c0104120:	55                   	push   %ebp
c0104121:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104123:	8b 45 08             	mov    0x8(%ebp),%eax
c0104126:	8b 00                	mov    (%eax),%eax
}
c0104128:	5d                   	pop    %ebp
c0104129:	c3                   	ret    

c010412a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010412a:	55                   	push   %ebp
c010412b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010412d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104130:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104133:	89 10                	mov    %edx,(%eax)
}
c0104135:	90                   	nop
c0104136:	5d                   	pop    %ebp
c0104137:	c3                   	ret    

c0104138 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104138:	55                   	push   %ebp
c0104139:	89 e5                	mov    %esp,%ebp
c010413b:	83 ec 10             	sub    $0x10,%esp
c010413e:	c7 45 fc 1c af 11 c0 	movl   $0xc011af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104145:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104148:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010414b:	89 50 04             	mov    %edx,0x4(%eax)
c010414e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104151:	8b 50 04             	mov    0x4(%eax),%edx
c0104154:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104157:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104159:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104160:	00 00 00 
}
c0104163:	90                   	nop
c0104164:	c9                   	leave  
c0104165:	c3                   	ret    

c0104166 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104166:	55                   	push   %ebp
c0104167:	89 e5                	mov    %esp,%ebp
c0104169:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010416c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104170:	75 24                	jne    c0104196 <default_init_memmap+0x30>
c0104172:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c0104179:	c0 
c010417a:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104181:	c0 
c0104182:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104189:	00 
c010418a:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104191:	e8 53 c2 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c0104196:	8b 45 08             	mov    0x8(%ebp),%eax
c0104199:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010419c:	eb 7d                	jmp    c010421b <default_init_memmap+0xb5>
        assert(PageReserved(p));
c010419e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041a1:	83 c0 04             	add    $0x4,%eax
c01041a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01041ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01041b4:	0f a3 10             	bt     %edx,(%eax)
c01041b7:	19 c0                	sbb    %eax,%eax
c01041b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01041bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01041c0:	0f 95 c0             	setne  %al
c01041c3:	0f b6 c0             	movzbl %al,%eax
c01041c6:	85 c0                	test   %eax,%eax
c01041c8:	75 24                	jne    c01041ee <default_init_memmap+0x88>
c01041ca:	c7 44 24 0c 29 6c 10 	movl   $0xc0106c29,0xc(%esp)
c01041d1:	c0 
c01041d2:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01041d9:	c0 
c01041da:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01041e1:	00 
c01041e2:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01041e9:	e8 fb c1 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c01041ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041fb:	8b 50 08             	mov    0x8(%eax),%edx
c01041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104201:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0104204:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010420b:	00 
c010420c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010420f:	89 04 24             	mov    %eax,(%esp)
c0104212:	e8 13 ff ff ff       	call   c010412a <set_page_ref>
    for (; p != base + n; p ++) {
c0104217:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010421b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010421e:	89 d0                	mov    %edx,%eax
c0104220:	c1 e0 02             	shl    $0x2,%eax
c0104223:	01 d0                	add    %edx,%eax
c0104225:	c1 e0 02             	shl    $0x2,%eax
c0104228:	89 c2                	mov    %eax,%edx
c010422a:	8b 45 08             	mov    0x8(%ebp),%eax
c010422d:	01 d0                	add    %edx,%eax
c010422f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104232:	0f 85 66 ff ff ff    	jne    c010419e <default_init_memmap+0x38>
    }
    base->property = n;
c0104238:	8b 45 08             	mov    0x8(%ebp),%eax
c010423b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010423e:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104241:	8b 45 08             	mov    0x8(%ebp),%eax
c0104244:	83 c0 04             	add    $0x4,%eax
c0104247:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010424e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104251:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104254:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104257:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010425a:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c0104260:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104263:	01 d0                	add    %edx,%eax
c0104265:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    list_add_before(&free_list, &(base->page_link));
c010426a:	8b 45 08             	mov    0x8(%ebp),%eax
c010426d:	83 c0 0c             	add    $0xc,%eax
c0104270:	c7 45 e4 1c af 11 c0 	movl   $0xc011af1c,-0x1c(%ebp)
c0104277:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010427a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010427d:	8b 00                	mov    (%eax),%eax
c010427f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104282:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104285:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010428b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010428e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104291:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104294:	89 10                	mov    %edx,(%eax)
c0104296:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104299:	8b 10                	mov    (%eax),%edx
c010429b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010429e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01042a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01042a7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01042aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01042b0:	89 10                	mov    %edx,(%eax)
}
c01042b2:	90                   	nop
c01042b3:	c9                   	leave  
c01042b4:	c3                   	ret    

c01042b5 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01042b5:	55                   	push   %ebp
c01042b6:	89 e5                	mov    %esp,%ebp
c01042b8:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01042bb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01042bf:	75 24                	jne    c01042e5 <default_alloc_pages+0x30>
c01042c1:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c01042c8:	c0 
c01042c9:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01042d0:	c0 
c01042d1:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01042d8:	00 
c01042d9:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01042e0:	e8 04 c1 ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c01042e5:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01042ea:	39 45 08             	cmp    %eax,0x8(%ebp)
c01042ed:	76 0a                	jbe    c01042f9 <default_alloc_pages+0x44>
        return NULL;
c01042ef:	b8 00 00 00 00       	mov    $0x0,%eax
c01042f4:	e9 47 01 00 00       	jmp    c0104440 <default_alloc_pages+0x18b>
    }
    struct Page *page = NULL;
c01042f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104300:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104307:	eb 1c                	jmp    c0104325 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0104309:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010430c:	83 e8 0c             	sub    $0xc,%eax
c010430f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0104312:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104315:	8b 40 08             	mov    0x8(%eax),%eax
c0104318:	39 45 08             	cmp    %eax,0x8(%ebp)
c010431b:	77 08                	ja     c0104325 <default_alloc_pages+0x70>
            page = p;
c010431d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104320:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104323:	eb 18                	jmp    c010433d <default_alloc_pages+0x88>
c0104325:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010432b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010432e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104331:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104334:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c010433b:	75 cc                	jne    c0104309 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c010433d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104341:	0f 84 f6 00 00 00    	je     c010443d <default_alloc_pages+0x188>
        if (page->property > n) {
c0104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010434a:	8b 40 08             	mov    0x8(%eax),%eax
c010434d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104350:	0f 83 96 00 00 00    	jae    c01043ec <default_alloc_pages+0x137>
            struct Page *p = page + n;
c0104356:	8b 55 08             	mov    0x8(%ebp),%edx
c0104359:	89 d0                	mov    %edx,%eax
c010435b:	c1 e0 02             	shl    $0x2,%eax
c010435e:	01 d0                	add    %edx,%eax
c0104360:	c1 e0 02             	shl    $0x2,%eax
c0104363:	89 c2                	mov    %eax,%edx
c0104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104368:	01 d0                	add    %edx,%eax
c010436a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c010436d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104370:	8b 40 08             	mov    0x8(%eax),%eax
c0104373:	2b 45 08             	sub    0x8(%ebp),%eax
c0104376:	89 c2                	mov    %eax,%edx
c0104378:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010437b:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c010437e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104381:	83 c0 04             	add    $0x4,%eax
c0104384:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010438b:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010438e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104391:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104394:	0f ab 10             	bts    %edx,(%eax)
            list_add(&free_list, &(p->page_link));
c0104397:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010439a:	83 c0 0c             	add    $0xc,%eax
c010439d:	c7 45 e0 1c af 11 c0 	movl   $0xc011af1c,-0x20(%ebp)
c01043a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01043a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01043aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01043ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01043b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043b6:	8b 40 04             	mov    0x4(%eax),%eax
c01043b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043bc:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01043bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043c2:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01043c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c01043c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01043ce:	89 10                	mov    %edx,(%eax)
c01043d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043d3:	8b 10                	mov    (%eax),%edx
c01043d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043d8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01043db:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043de:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01043e1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01043e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043e7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01043ea:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01043ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043ef:	83 c0 0c             	add    $0xc,%eax
c01043f2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01043f5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01043f8:	8b 40 04             	mov    0x4(%eax),%eax
c01043fb:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01043fe:	8b 12                	mov    (%edx),%edx
c0104400:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0104403:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104406:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104409:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010440c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010440f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104412:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104415:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0104417:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010441c:	2b 45 08             	sub    0x8(%ebp),%eax
c010441f:	a3 24 af 11 c0       	mov    %eax,0xc011af24
        ClearPageProperty(page);
c0104424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104427:	83 c0 04             	add    $0x4,%eax
c010442a:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104431:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104434:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104437:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010443a:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c010443d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104440:	c9                   	leave  
c0104441:	c3                   	ret    

c0104442 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0104442:	55                   	push   %ebp
c0104443:	89 e5                	mov    %esp,%ebp
c0104445:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010444b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010444f:	75 24                	jne    c0104475 <default_free_pages+0x33>
c0104451:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c0104458:	c0 
c0104459:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104460:	c0 
c0104461:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0104468:	00 
c0104469:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104470:	e8 74 bf ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c0104475:	8b 45 08             	mov    0x8(%ebp),%eax
c0104478:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010447b:	e9 9d 00 00 00       	jmp    c010451d <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104483:	83 c0 04             	add    $0x4,%eax
c0104486:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010448d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104490:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104493:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104496:	0f a3 10             	bt     %edx,(%eax)
c0104499:	19 c0                	sbb    %eax,%eax
c010449b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010449e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01044a2:	0f 95 c0             	setne  %al
c01044a5:	0f b6 c0             	movzbl %al,%eax
c01044a8:	85 c0                	test   %eax,%eax
c01044aa:	75 2c                	jne    c01044d8 <default_free_pages+0x96>
c01044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044af:	83 c0 04             	add    $0x4,%eax
c01044b2:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01044b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01044bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044bf:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01044c2:	0f a3 10             	bt     %edx,(%eax)
c01044c5:	19 c0                	sbb    %eax,%eax
c01044c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01044ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01044ce:	0f 95 c0             	setne  %al
c01044d1:	0f b6 c0             	movzbl %al,%eax
c01044d4:	85 c0                	test   %eax,%eax
c01044d6:	74 24                	je     c01044fc <default_free_pages+0xba>
c01044d8:	c7 44 24 0c 3c 6c 10 	movl   $0xc0106c3c,0xc(%esp)
c01044df:	c0 
c01044e0:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01044e7:	c0 
c01044e8:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01044ef:	00 
c01044f0:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01044f7:	e8 ed be ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c01044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044ff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0104506:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010450d:	00 
c010450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104511:	89 04 24             	mov    %eax,(%esp)
c0104514:	e8 11 fc ff ff       	call   c010412a <set_page_ref>
    for (; p != base + n; p ++) {
c0104519:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010451d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104520:	89 d0                	mov    %edx,%eax
c0104522:	c1 e0 02             	shl    $0x2,%eax
c0104525:	01 d0                	add    %edx,%eax
c0104527:	c1 e0 02             	shl    $0x2,%eax
c010452a:	89 c2                	mov    %eax,%edx
c010452c:	8b 45 08             	mov    0x8(%ebp),%eax
c010452f:	01 d0                	add    %edx,%eax
c0104531:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104534:	0f 85 46 ff ff ff    	jne    c0104480 <default_free_pages+0x3e>
    }
    base->property = n;
c010453a:	8b 45 08             	mov    0x8(%ebp),%eax
c010453d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104540:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104543:	8b 45 08             	mov    0x8(%ebp),%eax
c0104546:	83 c0 04             	add    $0x4,%eax
c0104549:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104550:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104553:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104556:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104559:	0f ab 10             	bts    %edx,(%eax)
c010455c:	c7 45 d4 1c af 11 c0 	movl   $0xc011af1c,-0x2c(%ebp)
    return listelm->next;
c0104563:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104566:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104569:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010456c:	e9 08 01 00 00       	jmp    c0104679 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104571:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104574:	83 e8 0c             	sub    $0xc,%eax
c0104577:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010457a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010457d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104580:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104583:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104586:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0104589:	8b 45 08             	mov    0x8(%ebp),%eax
c010458c:	8b 50 08             	mov    0x8(%eax),%edx
c010458f:	89 d0                	mov    %edx,%eax
c0104591:	c1 e0 02             	shl    $0x2,%eax
c0104594:	01 d0                	add    %edx,%eax
c0104596:	c1 e0 02             	shl    $0x2,%eax
c0104599:	89 c2                	mov    %eax,%edx
c010459b:	8b 45 08             	mov    0x8(%ebp),%eax
c010459e:	01 d0                	add    %edx,%eax
c01045a0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01045a3:	75 5a                	jne    c01045ff <default_free_pages+0x1bd>
            base->property += p->property;
c01045a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a8:	8b 50 08             	mov    0x8(%eax),%edx
c01045ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ae:	8b 40 08             	mov    0x8(%eax),%eax
c01045b1:	01 c2                	add    %eax,%edx
c01045b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b6:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01045b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045bc:	83 c0 04             	add    $0x4,%eax
c01045bf:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01045c6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01045c9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01045cc:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01045cf:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01045d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d5:	83 c0 0c             	add    $0xc,%eax
c01045d8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01045db:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01045de:	8b 40 04             	mov    0x4(%eax),%eax
c01045e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01045e4:	8b 12                	mov    (%edx),%edx
c01045e6:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01045e9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01045ec:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01045ef:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01045f2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01045f5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01045f8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01045fb:	89 10                	mov    %edx,(%eax)
c01045fd:	eb 7a                	jmp    c0104679 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c01045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104602:	8b 50 08             	mov    0x8(%eax),%edx
c0104605:	89 d0                	mov    %edx,%eax
c0104607:	c1 e0 02             	shl    $0x2,%eax
c010460a:	01 d0                	add    %edx,%eax
c010460c:	c1 e0 02             	shl    $0x2,%eax
c010460f:	89 c2                	mov    %eax,%edx
c0104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104614:	01 d0                	add    %edx,%eax
c0104616:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104619:	75 5e                	jne    c0104679 <default_free_pages+0x237>
            p->property += base->property;
c010461b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010461e:	8b 50 08             	mov    0x8(%eax),%edx
c0104621:	8b 45 08             	mov    0x8(%ebp),%eax
c0104624:	8b 40 08             	mov    0x8(%eax),%eax
c0104627:	01 c2                	add    %eax,%edx
c0104629:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462c:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c010462f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104632:	83 c0 04             	add    $0x4,%eax
c0104635:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c010463c:	89 45 a0             	mov    %eax,-0x60(%ebp)
c010463f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104642:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104645:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0104648:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464b:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c010464e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104651:	83 c0 0c             	add    $0xc,%eax
c0104654:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104657:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010465a:	8b 40 04             	mov    0x4(%eax),%eax
c010465d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104660:	8b 12                	mov    (%edx),%edx
c0104662:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0104665:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0104668:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010466b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010466e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104671:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104674:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104677:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c0104679:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c0104680:	0f 85 eb fe ff ff    	jne    c0104571 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
c0104686:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c010468c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010468f:	01 d0                	add    %edx,%eax
c0104691:	a3 24 af 11 c0       	mov    %eax,0xc011af24
c0104696:	c7 45 9c 1c af 11 c0 	movl   $0xc011af1c,-0x64(%ebp)
    return listelm->next;
c010469d:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01046a0:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
c01046a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046a6:	eb 74                	jmp    c010471c <default_free_pages+0x2da>
        p = le2page(le, page_link);
c01046a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046ab:	83 e8 0c             	sub    $0xc,%eax
c01046ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(base + base->property <= p) {
c01046b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b4:	8b 50 08             	mov    0x8(%eax),%edx
c01046b7:	89 d0                	mov    %edx,%eax
c01046b9:	c1 e0 02             	shl    $0x2,%eax
c01046bc:	01 d0                	add    %edx,%eax
c01046be:	c1 e0 02             	shl    $0x2,%eax
c01046c1:	89 c2                	mov    %eax,%edx
c01046c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c6:	01 d0                	add    %edx,%eax
c01046c8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046cb:	72 40                	jb     c010470d <default_free_pages+0x2cb>
            assert(base + base->property != p);
c01046cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d0:	8b 50 08             	mov    0x8(%eax),%edx
c01046d3:	89 d0                	mov    %edx,%eax
c01046d5:	c1 e0 02             	shl    $0x2,%eax
c01046d8:	01 d0                	add    %edx,%eax
c01046da:	c1 e0 02             	shl    $0x2,%eax
c01046dd:	89 c2                	mov    %eax,%edx
c01046df:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e2:	01 d0                	add    %edx,%eax
c01046e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046e7:	75 3e                	jne    c0104727 <default_free_pages+0x2e5>
c01046e9:	c7 44 24 0c 61 6c 10 	movl   $0xc0106c61,0xc(%esp)
c01046f0:	c0 
c01046f1:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01046f8:	c0 
c01046f9:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0104700:	00 
c0104701:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104708:	e8 dc bc ff ff       	call   c01003e9 <__panic>
c010470d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104710:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104713:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104716:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
c0104719:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010471c:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c0104723:	75 83                	jne    c01046a8 <default_free_pages+0x266>
c0104725:	eb 01                	jmp    c0104728 <default_free_pages+0x2e6>
            break;
c0104727:	90                   	nop
        }
    }
    list_add_before(&free_list, &(base->page_link));
c0104728:	8b 45 08             	mov    0x8(%ebp),%eax
c010472b:	83 c0 0c             	add    $0xc,%eax
c010472e:	c7 45 94 1c af 11 c0 	movl   $0xc011af1c,-0x6c(%ebp)
c0104735:	89 45 90             	mov    %eax,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104738:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010473b:	8b 00                	mov    (%eax),%eax
c010473d:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104740:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104743:	89 45 88             	mov    %eax,-0x78(%ebp)
c0104746:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104749:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c010474c:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010474f:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104752:	89 10                	mov    %edx,(%eax)
c0104754:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104757:	8b 10                	mov    (%eax),%edx
c0104759:	8b 45 88             	mov    -0x78(%ebp),%eax
c010475c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010475f:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104762:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104765:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104768:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010476b:	8b 55 88             	mov    -0x78(%ebp),%edx
c010476e:	89 10                	mov    %edx,(%eax)
}
c0104770:	90                   	nop
c0104771:	c9                   	leave  
c0104772:	c3                   	ret    

c0104773 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104773:	55                   	push   %ebp
c0104774:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104776:	a1 24 af 11 c0       	mov    0xc011af24,%eax
}
c010477b:	5d                   	pop    %ebp
c010477c:	c3                   	ret    

c010477d <basic_check>:

static void
basic_check(void) {
c010477d:	55                   	push   %ebp
c010477e:	89 e5                	mov    %esp,%ebp
c0104780:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010478a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010478d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104790:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104793:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104796:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010479d:	e8 30 e4 ff ff       	call   c0102bd2 <alloc_pages>
c01047a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01047a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01047a9:	75 24                	jne    c01047cf <basic_check+0x52>
c01047ab:	c7 44 24 0c 7c 6c 10 	movl   $0xc0106c7c,0xc(%esp)
c01047b2:	c0 
c01047b3:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01047ba:	c0 
c01047bb:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01047c2:	00 
c01047c3:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01047ca:	e8 1a bc ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01047cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047d6:	e8 f7 e3 ff ff       	call   c0102bd2 <alloc_pages>
c01047db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047e2:	75 24                	jne    c0104808 <basic_check+0x8b>
c01047e4:	c7 44 24 0c 98 6c 10 	movl   $0xc0106c98,0xc(%esp)
c01047eb:	c0 
c01047ec:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01047f3:	c0 
c01047f4:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c01047fb:	00 
c01047fc:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104803:	e8 e1 bb ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104808:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010480f:	e8 be e3 ff ff       	call   c0102bd2 <alloc_pages>
c0104814:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104817:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010481b:	75 24                	jne    c0104841 <basic_check+0xc4>
c010481d:	c7 44 24 0c b4 6c 10 	movl   $0xc0106cb4,0xc(%esp)
c0104824:	c0 
c0104825:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010482c:	c0 
c010482d:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0104834:	00 
c0104835:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010483c:	e8 a8 bb ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104841:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104844:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104847:	74 10                	je     c0104859 <basic_check+0xdc>
c0104849:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010484c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010484f:	74 08                	je     c0104859 <basic_check+0xdc>
c0104851:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104854:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104857:	75 24                	jne    c010487d <basic_check+0x100>
c0104859:	c7 44 24 0c d0 6c 10 	movl   $0xc0106cd0,0xc(%esp)
c0104860:	c0 
c0104861:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104868:	c0 
c0104869:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0104870:	00 
c0104871:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104878:	e8 6c bb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010487d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104880:	89 04 24             	mov    %eax,(%esp)
c0104883:	e8 98 f8 ff ff       	call   c0104120 <page_ref>
c0104888:	85 c0                	test   %eax,%eax
c010488a:	75 1e                	jne    c01048aa <basic_check+0x12d>
c010488c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488f:	89 04 24             	mov    %eax,(%esp)
c0104892:	e8 89 f8 ff ff       	call   c0104120 <page_ref>
c0104897:	85 c0                	test   %eax,%eax
c0104899:	75 0f                	jne    c01048aa <basic_check+0x12d>
c010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010489e:	89 04 24             	mov    %eax,(%esp)
c01048a1:	e8 7a f8 ff ff       	call   c0104120 <page_ref>
c01048a6:	85 c0                	test   %eax,%eax
c01048a8:	74 24                	je     c01048ce <basic_check+0x151>
c01048aa:	c7 44 24 0c f4 6c 10 	movl   $0xc0106cf4,0xc(%esp)
c01048b1:	c0 
c01048b2:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01048b9:	c0 
c01048ba:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01048c1:	00 
c01048c2:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01048c9:	e8 1b bb ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01048ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048d1:	89 04 24             	mov    %eax,(%esp)
c01048d4:	e8 31 f8 ff ff       	call   c010410a <page2pa>
c01048d9:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01048df:	c1 e2 0c             	shl    $0xc,%edx
c01048e2:	39 d0                	cmp    %edx,%eax
c01048e4:	72 24                	jb     c010490a <basic_check+0x18d>
c01048e6:	c7 44 24 0c 30 6d 10 	movl   $0xc0106d30,0xc(%esp)
c01048ed:	c0 
c01048ee:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01048f5:	c0 
c01048f6:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c01048fd:	00 
c01048fe:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104905:	e8 df ba ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010490a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010490d:	89 04 24             	mov    %eax,(%esp)
c0104910:	e8 f5 f7 ff ff       	call   c010410a <page2pa>
c0104915:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010491b:	c1 e2 0c             	shl    $0xc,%edx
c010491e:	39 d0                	cmp    %edx,%eax
c0104920:	72 24                	jb     c0104946 <basic_check+0x1c9>
c0104922:	c7 44 24 0c 4d 6d 10 	movl   $0xc0106d4d,0xc(%esp)
c0104929:	c0 
c010492a:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104931:	c0 
c0104932:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0104939:	00 
c010493a:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104941:	e8 a3 ba ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104946:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104949:	89 04 24             	mov    %eax,(%esp)
c010494c:	e8 b9 f7 ff ff       	call   c010410a <page2pa>
c0104951:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104957:	c1 e2 0c             	shl    $0xc,%edx
c010495a:	39 d0                	cmp    %edx,%eax
c010495c:	72 24                	jb     c0104982 <basic_check+0x205>
c010495e:	c7 44 24 0c 6a 6d 10 	movl   $0xc0106d6a,0xc(%esp)
c0104965:	c0 
c0104966:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010496d:	c0 
c010496e:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104975:	00 
c0104976:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010497d:	e8 67 ba ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104982:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104987:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c010498d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104990:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104993:	c7 45 dc 1c af 11 c0 	movl   $0xc011af1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c010499a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010499d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049a0:	89 50 04             	mov    %edx,0x4(%eax)
c01049a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01049a6:	8b 50 04             	mov    0x4(%eax),%edx
c01049a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01049ac:	89 10                	mov    %edx,(%eax)
c01049ae:	c7 45 e0 1c af 11 c0 	movl   $0xc011af1c,-0x20(%ebp)
    return list->next == list;
c01049b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049b8:	8b 40 04             	mov    0x4(%eax),%eax
c01049bb:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01049be:	0f 94 c0             	sete   %al
c01049c1:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01049c4:	85 c0                	test   %eax,%eax
c01049c6:	75 24                	jne    c01049ec <basic_check+0x26f>
c01049c8:	c7 44 24 0c 87 6d 10 	movl   $0xc0106d87,0xc(%esp)
c01049cf:	c0 
c01049d0:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01049d7:	c0 
c01049d8:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01049df:	00 
c01049e0:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01049e7:	e8 fd b9 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c01049ec:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01049f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01049f4:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c01049fb:	00 00 00 

    assert(alloc_page() == NULL);
c01049fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a05:	e8 c8 e1 ff ff       	call   c0102bd2 <alloc_pages>
c0104a0a:	85 c0                	test   %eax,%eax
c0104a0c:	74 24                	je     c0104a32 <basic_check+0x2b5>
c0104a0e:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0104a15:	c0 
c0104a16:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104a1d:	c0 
c0104a1e:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0104a25:	00 
c0104a26:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104a2d:	e8 b7 b9 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104a32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a39:	00 
c0104a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a3d:	89 04 24             	mov    %eax,(%esp)
c0104a40:	e8 c5 e1 ff ff       	call   c0102c0a <free_pages>
    free_page(p1);
c0104a45:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a4c:	00 
c0104a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a50:	89 04 24             	mov    %eax,(%esp)
c0104a53:	e8 b2 e1 ff ff       	call   c0102c0a <free_pages>
    free_page(p2);
c0104a58:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a5f:	00 
c0104a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a63:	89 04 24             	mov    %eax,(%esp)
c0104a66:	e8 9f e1 ff ff       	call   c0102c0a <free_pages>
    assert(nr_free == 3);
c0104a6b:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104a70:	83 f8 03             	cmp    $0x3,%eax
c0104a73:	74 24                	je     c0104a99 <basic_check+0x31c>
c0104a75:	c7 44 24 0c b3 6d 10 	movl   $0xc0106db3,0xc(%esp)
c0104a7c:	c0 
c0104a7d:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104a84:	c0 
c0104a85:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104a8c:	00 
c0104a8d:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104a94:	e8 50 b9 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104a99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104aa0:	e8 2d e1 ff ff       	call   c0102bd2 <alloc_pages>
c0104aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104aa8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104aac:	75 24                	jne    c0104ad2 <basic_check+0x355>
c0104aae:	c7 44 24 0c 7c 6c 10 	movl   $0xc0106c7c,0xc(%esp)
c0104ab5:	c0 
c0104ab6:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104abd:	c0 
c0104abe:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0104ac5:	00 
c0104ac6:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104acd:	e8 17 b9 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104ad2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ad9:	e8 f4 e0 ff ff       	call   c0102bd2 <alloc_pages>
c0104ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ae1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ae5:	75 24                	jne    c0104b0b <basic_check+0x38e>
c0104ae7:	c7 44 24 0c 98 6c 10 	movl   $0xc0106c98,0xc(%esp)
c0104aee:	c0 
c0104aef:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104af6:	c0 
c0104af7:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0104afe:	00 
c0104aff:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104b06:	e8 de b8 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104b0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b12:	e8 bb e0 ff ff       	call   c0102bd2 <alloc_pages>
c0104b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b1e:	75 24                	jne    c0104b44 <basic_check+0x3c7>
c0104b20:	c7 44 24 0c b4 6c 10 	movl   $0xc0106cb4,0xc(%esp)
c0104b27:	c0 
c0104b28:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104b2f:	c0 
c0104b30:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104b37:	00 
c0104b38:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104b3f:	e8 a5 b8 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104b44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b4b:	e8 82 e0 ff ff       	call   c0102bd2 <alloc_pages>
c0104b50:	85 c0                	test   %eax,%eax
c0104b52:	74 24                	je     c0104b78 <basic_check+0x3fb>
c0104b54:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0104b5b:	c0 
c0104b5c:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104b63:	c0 
c0104b64:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0104b6b:	00 
c0104b6c:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104b73:	e8 71 b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104b78:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b7f:	00 
c0104b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b83:	89 04 24             	mov    %eax,(%esp)
c0104b86:	e8 7f e0 ff ff       	call   c0102c0a <free_pages>
c0104b8b:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
c0104b92:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104b95:	8b 40 04             	mov    0x4(%eax),%eax
c0104b98:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104b9b:	0f 94 c0             	sete   %al
c0104b9e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104ba1:	85 c0                	test   %eax,%eax
c0104ba3:	74 24                	je     c0104bc9 <basic_check+0x44c>
c0104ba5:	c7 44 24 0c c0 6d 10 	movl   $0xc0106dc0,0xc(%esp)
c0104bac:	c0 
c0104bad:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104bb4:	c0 
c0104bb5:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104bbc:	00 
c0104bbd:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104bc4:	e8 20 b8 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104bc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bd0:	e8 fd df ff ff       	call   c0102bd2 <alloc_pages>
c0104bd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bdb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104bde:	74 24                	je     c0104c04 <basic_check+0x487>
c0104be0:	c7 44 24 0c d8 6d 10 	movl   $0xc0106dd8,0xc(%esp)
c0104be7:	c0 
c0104be8:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104bef:	c0 
c0104bf0:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104bf7:	00 
c0104bf8:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104bff:	e8 e5 b7 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104c04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c0b:	e8 c2 df ff ff       	call   c0102bd2 <alloc_pages>
c0104c10:	85 c0                	test   %eax,%eax
c0104c12:	74 24                	je     c0104c38 <basic_check+0x4bb>
c0104c14:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0104c1b:	c0 
c0104c1c:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104c23:	c0 
c0104c24:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0104c2b:	00 
c0104c2c:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104c33:	e8 b1 b7 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104c38:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104c3d:	85 c0                	test   %eax,%eax
c0104c3f:	74 24                	je     c0104c65 <basic_check+0x4e8>
c0104c41:	c7 44 24 0c f1 6d 10 	movl   $0xc0106df1,0xc(%esp)
c0104c48:	c0 
c0104c49:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104c50:	c0 
c0104c51:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0104c58:	00 
c0104c59:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104c60:	e8 84 b7 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104c65:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104c68:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c6b:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c0104c70:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    nr_free = nr_free_store;
c0104c76:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c79:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_page(p);
c0104c7e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c85:	00 
c0104c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c89:	89 04 24             	mov    %eax,(%esp)
c0104c8c:	e8 79 df ff ff       	call   c0102c0a <free_pages>
    free_page(p1);
c0104c91:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c98:	00 
c0104c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c9c:	89 04 24             	mov    %eax,(%esp)
c0104c9f:	e8 66 df ff ff       	call   c0102c0a <free_pages>
    free_page(p2);
c0104ca4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104cab:	00 
c0104cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104caf:	89 04 24             	mov    %eax,(%esp)
c0104cb2:	e8 53 df ff ff       	call   c0102c0a <free_pages>
}
c0104cb7:	90                   	nop
c0104cb8:	c9                   	leave  
c0104cb9:	c3                   	ret    

c0104cba <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104cba:	55                   	push   %ebp
c0104cbb:	89 e5                	mov    %esp,%ebp
c0104cbd:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104cc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104cca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104cd1:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104cd8:	eb 6a                	jmp    c0104d44 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104cda:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cdd:	83 e8 0c             	sub    $0xc,%eax
c0104ce0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104ce3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104ce6:	83 c0 04             	add    $0x4,%eax
c0104ce9:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104cf0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104cf3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104cf6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104cf9:	0f a3 10             	bt     %edx,(%eax)
c0104cfc:	19 c0                	sbb    %eax,%eax
c0104cfe:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104d01:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104d05:	0f 95 c0             	setne  %al
c0104d08:	0f b6 c0             	movzbl %al,%eax
c0104d0b:	85 c0                	test   %eax,%eax
c0104d0d:	75 24                	jne    c0104d33 <default_check+0x79>
c0104d0f:	c7 44 24 0c fe 6d 10 	movl   $0xc0106dfe,0xc(%esp)
c0104d16:	c0 
c0104d17:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104d1e:	c0 
c0104d1f:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0104d26:	00 
c0104d27:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104d2e:	e8 b6 b6 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104d33:	ff 45 f4             	incl   -0xc(%ebp)
c0104d36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104d39:	8b 50 08             	mov    0x8(%eax),%edx
c0104d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d3f:	01 d0                	add    %edx,%eax
c0104d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d47:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104d4a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d4d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104d50:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d53:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104d5a:	0f 85 7a ff ff ff    	jne    c0104cda <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104d60:	e8 d8 de ff ff       	call   c0102c3d <nr_free_pages>
c0104d65:	89 c2                	mov    %eax,%edx
c0104d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d6a:	39 c2                	cmp    %eax,%edx
c0104d6c:	74 24                	je     c0104d92 <default_check+0xd8>
c0104d6e:	c7 44 24 0c 0e 6e 10 	movl   $0xc0106e0e,0xc(%esp)
c0104d75:	c0 
c0104d76:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104d7d:	c0 
c0104d7e:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104d85:	00 
c0104d86:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104d8d:	e8 57 b6 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104d92:	e8 e6 f9 ff ff       	call   c010477d <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104d97:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104d9e:	e8 2f de ff ff       	call   c0102bd2 <alloc_pages>
c0104da3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104da6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104daa:	75 24                	jne    c0104dd0 <default_check+0x116>
c0104dac:	c7 44 24 0c 27 6e 10 	movl   $0xc0106e27,0xc(%esp)
c0104db3:	c0 
c0104db4:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104dbb:	c0 
c0104dbc:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0104dc3:	00 
c0104dc4:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104dcb:	e8 19 b6 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104dd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dd3:	83 c0 04             	add    $0x4,%eax
c0104dd6:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104ddd:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104de0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104de3:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104de6:	0f a3 10             	bt     %edx,(%eax)
c0104de9:	19 c0                	sbb    %eax,%eax
c0104deb:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104dee:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104df2:	0f 95 c0             	setne  %al
c0104df5:	0f b6 c0             	movzbl %al,%eax
c0104df8:	85 c0                	test   %eax,%eax
c0104dfa:	74 24                	je     c0104e20 <default_check+0x166>
c0104dfc:	c7 44 24 0c 32 6e 10 	movl   $0xc0106e32,0xc(%esp)
c0104e03:	c0 
c0104e04:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104e0b:	c0 
c0104e0c:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104e13:	00 
c0104e14:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104e1b:	e8 c9 b5 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104e20:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104e25:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104e2b:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104e2e:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104e31:	c7 45 b0 1c af 11 c0 	movl   $0xc011af1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104e38:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104e3b:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104e3e:	89 50 04             	mov    %edx,0x4(%eax)
c0104e41:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104e44:	8b 50 04             	mov    0x4(%eax),%edx
c0104e47:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104e4a:	89 10                	mov    %edx,(%eax)
c0104e4c:	c7 45 b4 1c af 11 c0 	movl   $0xc011af1c,-0x4c(%ebp)
    return list->next == list;
c0104e53:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104e56:	8b 40 04             	mov    0x4(%eax),%eax
c0104e59:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104e5c:	0f 94 c0             	sete   %al
c0104e5f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104e62:	85 c0                	test   %eax,%eax
c0104e64:	75 24                	jne    c0104e8a <default_check+0x1d0>
c0104e66:	c7 44 24 0c 87 6d 10 	movl   $0xc0106d87,0xc(%esp)
c0104e6d:	c0 
c0104e6e:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104e75:	c0 
c0104e76:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0104e7d:	00 
c0104e7e:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104e85:	e8 5f b5 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104e8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e91:	e8 3c dd ff ff       	call   c0102bd2 <alloc_pages>
c0104e96:	85 c0                	test   %eax,%eax
c0104e98:	74 24                	je     c0104ebe <default_check+0x204>
c0104e9a:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0104ea1:	c0 
c0104ea2:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104ea9:	c0 
c0104eaa:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0104eb1:	00 
c0104eb2:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104eb9:	e8 2b b5 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104ebe:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104ec3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104ec6:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104ecd:	00 00 00 

    free_pages(p0 + 2, 3);
c0104ed0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ed3:	83 c0 28             	add    $0x28,%eax
c0104ed6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104edd:	00 
c0104ede:	89 04 24             	mov    %eax,(%esp)
c0104ee1:	e8 24 dd ff ff       	call   c0102c0a <free_pages>
    assert(alloc_pages(4) == NULL);
c0104ee6:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104eed:	e8 e0 dc ff ff       	call   c0102bd2 <alloc_pages>
c0104ef2:	85 c0                	test   %eax,%eax
c0104ef4:	74 24                	je     c0104f1a <default_check+0x260>
c0104ef6:	c7 44 24 0c 44 6e 10 	movl   $0xc0106e44,0xc(%esp)
c0104efd:	c0 
c0104efe:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104f05:	c0 
c0104f06:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0104f0d:	00 
c0104f0e:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104f15:	e8 cf b4 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104f1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f1d:	83 c0 28             	add    $0x28,%eax
c0104f20:	83 c0 04             	add    $0x4,%eax
c0104f23:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104f2a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104f2d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104f30:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104f33:	0f a3 10             	bt     %edx,(%eax)
c0104f36:	19 c0                	sbb    %eax,%eax
c0104f38:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104f3b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104f3f:	0f 95 c0             	setne  %al
c0104f42:	0f b6 c0             	movzbl %al,%eax
c0104f45:	85 c0                	test   %eax,%eax
c0104f47:	74 0e                	je     c0104f57 <default_check+0x29d>
c0104f49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f4c:	83 c0 28             	add    $0x28,%eax
c0104f4f:	8b 40 08             	mov    0x8(%eax),%eax
c0104f52:	83 f8 03             	cmp    $0x3,%eax
c0104f55:	74 24                	je     c0104f7b <default_check+0x2c1>
c0104f57:	c7 44 24 0c 5c 6e 10 	movl   $0xc0106e5c,0xc(%esp)
c0104f5e:	c0 
c0104f5f:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104f66:	c0 
c0104f67:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104f6e:	00 
c0104f6f:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104f76:	e8 6e b4 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104f7b:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104f82:	e8 4b dc ff ff       	call   c0102bd2 <alloc_pages>
c0104f87:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104f8a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104f8e:	75 24                	jne    c0104fb4 <default_check+0x2fa>
c0104f90:	c7 44 24 0c 88 6e 10 	movl   $0xc0106e88,0xc(%esp)
c0104f97:	c0 
c0104f98:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104f9f:	c0 
c0104fa0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104fa7:	00 
c0104fa8:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104faf:	e8 35 b4 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104fb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104fbb:	e8 12 dc ff ff       	call   c0102bd2 <alloc_pages>
c0104fc0:	85 c0                	test   %eax,%eax
c0104fc2:	74 24                	je     c0104fe8 <default_check+0x32e>
c0104fc4:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0104fcb:	c0 
c0104fcc:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0104fd3:	c0 
c0104fd4:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0104fdb:	00 
c0104fdc:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0104fe3:	e8 01 b4 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c0104fe8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104feb:	83 c0 28             	add    $0x28,%eax
c0104fee:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104ff1:	74 24                	je     c0105017 <default_check+0x35d>
c0104ff3:	c7 44 24 0c a6 6e 10 	movl   $0xc0106ea6,0xc(%esp)
c0104ffa:	c0 
c0104ffb:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105002:	c0 
c0105003:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010500a:	00 
c010500b:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105012:	e8 d2 b3 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c0105017:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010501a:	83 c0 14             	add    $0x14,%eax
c010501d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0105020:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105027:	00 
c0105028:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010502b:	89 04 24             	mov    %eax,(%esp)
c010502e:	e8 d7 db ff ff       	call   c0102c0a <free_pages>
    free_pages(p1, 3);
c0105033:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010503a:	00 
c010503b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010503e:	89 04 24             	mov    %eax,(%esp)
c0105041:	e8 c4 db ff ff       	call   c0102c0a <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105046:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105049:	83 c0 04             	add    $0x4,%eax
c010504c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105053:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105056:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105059:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010505c:	0f a3 10             	bt     %edx,(%eax)
c010505f:	19 c0                	sbb    %eax,%eax
c0105061:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105064:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105068:	0f 95 c0             	setne  %al
c010506b:	0f b6 c0             	movzbl %al,%eax
c010506e:	85 c0                	test   %eax,%eax
c0105070:	74 0b                	je     c010507d <default_check+0x3c3>
c0105072:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105075:	8b 40 08             	mov    0x8(%eax),%eax
c0105078:	83 f8 01             	cmp    $0x1,%eax
c010507b:	74 24                	je     c01050a1 <default_check+0x3e7>
c010507d:	c7 44 24 0c b4 6e 10 	movl   $0xc0106eb4,0xc(%esp)
c0105084:	c0 
c0105085:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c010508c:	c0 
c010508d:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105094:	00 
c0105095:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c010509c:	e8 48 b3 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01050a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050a4:	83 c0 04             	add    $0x4,%eax
c01050a7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01050ae:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01050b1:	8b 45 90             	mov    -0x70(%ebp),%eax
c01050b4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01050b7:	0f a3 10             	bt     %edx,(%eax)
c01050ba:	19 c0                	sbb    %eax,%eax
c01050bc:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01050bf:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01050c3:	0f 95 c0             	setne  %al
c01050c6:	0f b6 c0             	movzbl %al,%eax
c01050c9:	85 c0                	test   %eax,%eax
c01050cb:	74 0b                	je     c01050d8 <default_check+0x41e>
c01050cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050d0:	8b 40 08             	mov    0x8(%eax),%eax
c01050d3:	83 f8 03             	cmp    $0x3,%eax
c01050d6:	74 24                	je     c01050fc <default_check+0x442>
c01050d8:	c7 44 24 0c dc 6e 10 	movl   $0xc0106edc,0xc(%esp)
c01050df:	c0 
c01050e0:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01050e7:	c0 
c01050e8:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01050ef:	00 
c01050f0:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01050f7:	e8 ed b2 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01050fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105103:	e8 ca da ff ff       	call   c0102bd2 <alloc_pages>
c0105108:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010510b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010510e:	83 e8 14             	sub    $0x14,%eax
c0105111:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105114:	74 24                	je     c010513a <default_check+0x480>
c0105116:	c7 44 24 0c 02 6f 10 	movl   $0xc0106f02,0xc(%esp)
c010511d:	c0 
c010511e:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105125:	c0 
c0105126:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c010512d:	00 
c010512e:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105135:	e8 af b2 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c010513a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105141:	00 
c0105142:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105145:	89 04 24             	mov    %eax,(%esp)
c0105148:	e8 bd da ff ff       	call   c0102c0a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010514d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105154:	e8 79 da ff ff       	call   c0102bd2 <alloc_pages>
c0105159:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010515c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010515f:	83 c0 14             	add    $0x14,%eax
c0105162:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105165:	74 24                	je     c010518b <default_check+0x4d1>
c0105167:	c7 44 24 0c 20 6f 10 	movl   $0xc0106f20,0xc(%esp)
c010516e:	c0 
c010516f:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105176:	c0 
c0105177:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c010517e:	00 
c010517f:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105186:	e8 5e b2 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c010518b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105192:	00 
c0105193:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105196:	89 04 24             	mov    %eax,(%esp)
c0105199:	e8 6c da ff ff       	call   c0102c0a <free_pages>
    free_page(p2);
c010519e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051a5:	00 
c01051a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051a9:	89 04 24             	mov    %eax,(%esp)
c01051ac:	e8 59 da ff ff       	call   c0102c0a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01051b1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01051b8:	e8 15 da ff ff       	call   c0102bd2 <alloc_pages>
c01051bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01051c0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01051c4:	75 24                	jne    c01051ea <default_check+0x530>
c01051c6:	c7 44 24 0c 40 6f 10 	movl   $0xc0106f40,0xc(%esp)
c01051cd:	c0 
c01051ce:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01051d5:	c0 
c01051d6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01051dd:	00 
c01051de:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01051e5:	e8 ff b1 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c01051ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051f1:	e8 dc d9 ff ff       	call   c0102bd2 <alloc_pages>
c01051f6:	85 c0                	test   %eax,%eax
c01051f8:	74 24                	je     c010521e <default_check+0x564>
c01051fa:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0105201:	c0 
c0105202:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105209:	c0 
c010520a:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0105211:	00 
c0105212:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105219:	e8 cb b1 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c010521e:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0105223:	85 c0                	test   %eax,%eax
c0105225:	74 24                	je     c010524b <default_check+0x591>
c0105227:	c7 44 24 0c f1 6d 10 	movl   $0xc0106df1,0xc(%esp)
c010522e:	c0 
c010522f:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105236:	c0 
c0105237:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c010523e:	00 
c010523f:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105246:	e8 9e b1 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c010524b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010524e:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_list = free_list_store;
c0105253:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105256:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105259:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c010525e:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    free_pages(p0, 5);
c0105264:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010526b:	00 
c010526c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010526f:	89 04 24             	mov    %eax,(%esp)
c0105272:	e8 93 d9 ff ff       	call   c0102c0a <free_pages>

    le = &free_list;
c0105277:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010527e:	eb 5a                	jmp    c01052da <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c0105280:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105283:	8b 40 04             	mov    0x4(%eax),%eax
c0105286:	8b 00                	mov    (%eax),%eax
c0105288:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010528b:	75 0d                	jne    c010529a <default_check+0x5e0>
c010528d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105290:	8b 00                	mov    (%eax),%eax
c0105292:	8b 40 04             	mov    0x4(%eax),%eax
c0105295:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105298:	74 24                	je     c01052be <default_check+0x604>
c010529a:	c7 44 24 0c 60 6f 10 	movl   $0xc0106f60,0xc(%esp)
c01052a1:	c0 
c01052a2:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c01052a9:	c0 
c01052aa:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c01052b1:	00 
c01052b2:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c01052b9:	e8 2b b1 ff ff       	call   c01003e9 <__panic>
        struct Page *p = le2page(le, page_link);
c01052be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052c1:	83 e8 0c             	sub    $0xc,%eax
c01052c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c01052c7:	ff 4d f4             	decl   -0xc(%ebp)
c01052ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01052cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01052d0:	8b 40 08             	mov    0x8(%eax),%eax
c01052d3:	29 c2                	sub    %eax,%edx
c01052d5:	89 d0                	mov    %edx,%eax
c01052d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052dd:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01052e0:	8b 45 88             	mov    -0x78(%ebp),%eax
c01052e3:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01052e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01052e9:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c01052f0:	75 8e                	jne    c0105280 <default_check+0x5c6>
    }
    assert(count == 0);
c01052f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052f6:	74 24                	je     c010531c <default_check+0x662>
c01052f8:	c7 44 24 0c 8d 6f 10 	movl   $0xc0106f8d,0xc(%esp)
c01052ff:	c0 
c0105300:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105307:	c0 
c0105308:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c010530f:	00 
c0105310:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105317:	e8 cd b0 ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c010531c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105320:	74 24                	je     c0105346 <default_check+0x68c>
c0105322:	c7 44 24 0c 98 6f 10 	movl   $0xc0106f98,0xc(%esp)
c0105329:	c0 
c010532a:	c7 44 24 08 fe 6b 10 	movl   $0xc0106bfe,0x8(%esp)
c0105331:	c0 
c0105332:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0105339:	00 
c010533a:	c7 04 24 13 6c 10 c0 	movl   $0xc0106c13,(%esp)
c0105341:	e8 a3 b0 ff ff       	call   c01003e9 <__panic>
}
c0105346:	90                   	nop
c0105347:	c9                   	leave  
c0105348:	c3                   	ret    

c0105349 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105349:	55                   	push   %ebp
c010534a:	89 e5                	mov    %esp,%ebp
c010534c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010534f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105356:	eb 03                	jmp    c010535b <strlen+0x12>
        cnt ++;
c0105358:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010535b:	8b 45 08             	mov    0x8(%ebp),%eax
c010535e:	8d 50 01             	lea    0x1(%eax),%edx
c0105361:	89 55 08             	mov    %edx,0x8(%ebp)
c0105364:	0f b6 00             	movzbl (%eax),%eax
c0105367:	84 c0                	test   %al,%al
c0105369:	75 ed                	jne    c0105358 <strlen+0xf>
    }
    return cnt;
c010536b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010536e:	c9                   	leave  
c010536f:	c3                   	ret    

c0105370 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105370:	55                   	push   %ebp
c0105371:	89 e5                	mov    %esp,%ebp
c0105373:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105376:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010537d:	eb 03                	jmp    c0105382 <strnlen+0x12>
        cnt ++;
c010537f:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105382:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105385:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105388:	73 10                	jae    c010539a <strnlen+0x2a>
c010538a:	8b 45 08             	mov    0x8(%ebp),%eax
c010538d:	8d 50 01             	lea    0x1(%eax),%edx
c0105390:	89 55 08             	mov    %edx,0x8(%ebp)
c0105393:	0f b6 00             	movzbl (%eax),%eax
c0105396:	84 c0                	test   %al,%al
c0105398:	75 e5                	jne    c010537f <strnlen+0xf>
    }
    return cnt;
c010539a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010539d:	c9                   	leave  
c010539e:	c3                   	ret    

c010539f <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010539f:	55                   	push   %ebp
c01053a0:	89 e5                	mov    %esp,%ebp
c01053a2:	57                   	push   %edi
c01053a3:	56                   	push   %esi
c01053a4:	83 ec 20             	sub    $0x20,%esp
c01053a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01053aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01053b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053b9:	89 d1                	mov    %edx,%ecx
c01053bb:	89 c2                	mov    %eax,%edx
c01053bd:	89 ce                	mov    %ecx,%esi
c01053bf:	89 d7                	mov    %edx,%edi
c01053c1:	ac                   	lods   %ds:(%esi),%al
c01053c2:	aa                   	stos   %al,%es:(%edi)
c01053c3:	84 c0                	test   %al,%al
c01053c5:	75 fa                	jne    c01053c1 <strcpy+0x22>
c01053c7:	89 fa                	mov    %edi,%edx
c01053c9:	89 f1                	mov    %esi,%ecx
c01053cb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01053ce:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01053d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01053d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01053d7:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01053d8:	83 c4 20             	add    $0x20,%esp
c01053db:	5e                   	pop    %esi
c01053dc:	5f                   	pop    %edi
c01053dd:	5d                   	pop    %ebp
c01053de:	c3                   	ret    

c01053df <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01053df:	55                   	push   %ebp
c01053e0:	89 e5                	mov    %esp,%ebp
c01053e2:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01053e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01053e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01053eb:	eb 1e                	jmp    c010540b <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c01053ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053f0:	0f b6 10             	movzbl (%eax),%edx
c01053f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01053f6:	88 10                	mov    %dl,(%eax)
c01053f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01053fb:	0f b6 00             	movzbl (%eax),%eax
c01053fe:	84 c0                	test   %al,%al
c0105400:	74 03                	je     c0105405 <strncpy+0x26>
            src ++;
c0105402:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105405:	ff 45 fc             	incl   -0x4(%ebp)
c0105408:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010540b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010540f:	75 dc                	jne    c01053ed <strncpy+0xe>
    }
    return dst;
c0105411:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105414:	c9                   	leave  
c0105415:	c3                   	ret    

c0105416 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105416:	55                   	push   %ebp
c0105417:	89 e5                	mov    %esp,%ebp
c0105419:	57                   	push   %edi
c010541a:	56                   	push   %esi
c010541b:	83 ec 20             	sub    $0x20,%esp
c010541e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105421:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105424:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105427:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010542a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010542d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105430:	89 d1                	mov    %edx,%ecx
c0105432:	89 c2                	mov    %eax,%edx
c0105434:	89 ce                	mov    %ecx,%esi
c0105436:	89 d7                	mov    %edx,%edi
c0105438:	ac                   	lods   %ds:(%esi),%al
c0105439:	ae                   	scas   %es:(%edi),%al
c010543a:	75 08                	jne    c0105444 <strcmp+0x2e>
c010543c:	84 c0                	test   %al,%al
c010543e:	75 f8                	jne    c0105438 <strcmp+0x22>
c0105440:	31 c0                	xor    %eax,%eax
c0105442:	eb 04                	jmp    c0105448 <strcmp+0x32>
c0105444:	19 c0                	sbb    %eax,%eax
c0105446:	0c 01                	or     $0x1,%al
c0105448:	89 fa                	mov    %edi,%edx
c010544a:	89 f1                	mov    %esi,%ecx
c010544c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010544f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105452:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105455:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0105458:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105459:	83 c4 20             	add    $0x20,%esp
c010545c:	5e                   	pop    %esi
c010545d:	5f                   	pop    %edi
c010545e:	5d                   	pop    %ebp
c010545f:	c3                   	ret    

c0105460 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105460:	55                   	push   %ebp
c0105461:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105463:	eb 09                	jmp    c010546e <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105465:	ff 4d 10             	decl   0x10(%ebp)
c0105468:	ff 45 08             	incl   0x8(%ebp)
c010546b:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010546e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105472:	74 1a                	je     c010548e <strncmp+0x2e>
c0105474:	8b 45 08             	mov    0x8(%ebp),%eax
c0105477:	0f b6 00             	movzbl (%eax),%eax
c010547a:	84 c0                	test   %al,%al
c010547c:	74 10                	je     c010548e <strncmp+0x2e>
c010547e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105481:	0f b6 10             	movzbl (%eax),%edx
c0105484:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105487:	0f b6 00             	movzbl (%eax),%eax
c010548a:	38 c2                	cmp    %al,%dl
c010548c:	74 d7                	je     c0105465 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010548e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105492:	74 18                	je     c01054ac <strncmp+0x4c>
c0105494:	8b 45 08             	mov    0x8(%ebp),%eax
c0105497:	0f b6 00             	movzbl (%eax),%eax
c010549a:	0f b6 d0             	movzbl %al,%edx
c010549d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054a0:	0f b6 00             	movzbl (%eax),%eax
c01054a3:	0f b6 c0             	movzbl %al,%eax
c01054a6:	29 c2                	sub    %eax,%edx
c01054a8:	89 d0                	mov    %edx,%eax
c01054aa:	eb 05                	jmp    c01054b1 <strncmp+0x51>
c01054ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054b1:	5d                   	pop    %ebp
c01054b2:	c3                   	ret    

c01054b3 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01054b3:	55                   	push   %ebp
c01054b4:	89 e5                	mov    %esp,%ebp
c01054b6:	83 ec 04             	sub    $0x4,%esp
c01054b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054bc:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01054bf:	eb 13                	jmp    c01054d4 <strchr+0x21>
        if (*s == c) {
c01054c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01054c4:	0f b6 00             	movzbl (%eax),%eax
c01054c7:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01054ca:	75 05                	jne    c01054d1 <strchr+0x1e>
            return (char *)s;
c01054cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01054cf:	eb 12                	jmp    c01054e3 <strchr+0x30>
        }
        s ++;
c01054d1:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01054d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01054d7:	0f b6 00             	movzbl (%eax),%eax
c01054da:	84 c0                	test   %al,%al
c01054dc:	75 e3                	jne    c01054c1 <strchr+0xe>
    }
    return NULL;
c01054de:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054e3:	c9                   	leave  
c01054e4:	c3                   	ret    

c01054e5 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01054e5:	55                   	push   %ebp
c01054e6:	89 e5                	mov    %esp,%ebp
c01054e8:	83 ec 04             	sub    $0x4,%esp
c01054eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054ee:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01054f1:	eb 0e                	jmp    c0105501 <strfind+0x1c>
        if (*s == c) {
c01054f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01054f6:	0f b6 00             	movzbl (%eax),%eax
c01054f9:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01054fc:	74 0f                	je     c010550d <strfind+0x28>
            break;
        }
        s ++;
c01054fe:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105501:	8b 45 08             	mov    0x8(%ebp),%eax
c0105504:	0f b6 00             	movzbl (%eax),%eax
c0105507:	84 c0                	test   %al,%al
c0105509:	75 e8                	jne    c01054f3 <strfind+0xe>
c010550b:	eb 01                	jmp    c010550e <strfind+0x29>
            break;
c010550d:	90                   	nop
    }
    return (char *)s;
c010550e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105511:	c9                   	leave  
c0105512:	c3                   	ret    

c0105513 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105513:	55                   	push   %ebp
c0105514:	89 e5                	mov    %esp,%ebp
c0105516:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105519:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105520:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105527:	eb 03                	jmp    c010552c <strtol+0x19>
        s ++;
c0105529:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010552c:	8b 45 08             	mov    0x8(%ebp),%eax
c010552f:	0f b6 00             	movzbl (%eax),%eax
c0105532:	3c 20                	cmp    $0x20,%al
c0105534:	74 f3                	je     c0105529 <strtol+0x16>
c0105536:	8b 45 08             	mov    0x8(%ebp),%eax
c0105539:	0f b6 00             	movzbl (%eax),%eax
c010553c:	3c 09                	cmp    $0x9,%al
c010553e:	74 e9                	je     c0105529 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0105540:	8b 45 08             	mov    0x8(%ebp),%eax
c0105543:	0f b6 00             	movzbl (%eax),%eax
c0105546:	3c 2b                	cmp    $0x2b,%al
c0105548:	75 05                	jne    c010554f <strtol+0x3c>
        s ++;
c010554a:	ff 45 08             	incl   0x8(%ebp)
c010554d:	eb 14                	jmp    c0105563 <strtol+0x50>
    }
    else if (*s == '-') {
c010554f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105552:	0f b6 00             	movzbl (%eax),%eax
c0105555:	3c 2d                	cmp    $0x2d,%al
c0105557:	75 0a                	jne    c0105563 <strtol+0x50>
        s ++, neg = 1;
c0105559:	ff 45 08             	incl   0x8(%ebp)
c010555c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105563:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105567:	74 06                	je     c010556f <strtol+0x5c>
c0105569:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010556d:	75 22                	jne    c0105591 <strtol+0x7e>
c010556f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105572:	0f b6 00             	movzbl (%eax),%eax
c0105575:	3c 30                	cmp    $0x30,%al
c0105577:	75 18                	jne    c0105591 <strtol+0x7e>
c0105579:	8b 45 08             	mov    0x8(%ebp),%eax
c010557c:	40                   	inc    %eax
c010557d:	0f b6 00             	movzbl (%eax),%eax
c0105580:	3c 78                	cmp    $0x78,%al
c0105582:	75 0d                	jne    c0105591 <strtol+0x7e>
        s += 2, base = 16;
c0105584:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105588:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010558f:	eb 29                	jmp    c01055ba <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105591:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105595:	75 16                	jne    c01055ad <strtol+0x9a>
c0105597:	8b 45 08             	mov    0x8(%ebp),%eax
c010559a:	0f b6 00             	movzbl (%eax),%eax
c010559d:	3c 30                	cmp    $0x30,%al
c010559f:	75 0c                	jne    c01055ad <strtol+0x9a>
        s ++, base = 8;
c01055a1:	ff 45 08             	incl   0x8(%ebp)
c01055a4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01055ab:	eb 0d                	jmp    c01055ba <strtol+0xa7>
    }
    else if (base == 0) {
c01055ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055b1:	75 07                	jne    c01055ba <strtol+0xa7>
        base = 10;
c01055b3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01055ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01055bd:	0f b6 00             	movzbl (%eax),%eax
c01055c0:	3c 2f                	cmp    $0x2f,%al
c01055c2:	7e 1b                	jle    c01055df <strtol+0xcc>
c01055c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c7:	0f b6 00             	movzbl (%eax),%eax
c01055ca:	3c 39                	cmp    $0x39,%al
c01055cc:	7f 11                	jg     c01055df <strtol+0xcc>
            dig = *s - '0';
c01055ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d1:	0f b6 00             	movzbl (%eax),%eax
c01055d4:	0f be c0             	movsbl %al,%eax
c01055d7:	83 e8 30             	sub    $0x30,%eax
c01055da:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01055dd:	eb 48                	jmp    c0105627 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01055df:	8b 45 08             	mov    0x8(%ebp),%eax
c01055e2:	0f b6 00             	movzbl (%eax),%eax
c01055e5:	3c 60                	cmp    $0x60,%al
c01055e7:	7e 1b                	jle    c0105604 <strtol+0xf1>
c01055e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ec:	0f b6 00             	movzbl (%eax),%eax
c01055ef:	3c 7a                	cmp    $0x7a,%al
c01055f1:	7f 11                	jg     c0105604 <strtol+0xf1>
            dig = *s - 'a' + 10;
c01055f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f6:	0f b6 00             	movzbl (%eax),%eax
c01055f9:	0f be c0             	movsbl %al,%eax
c01055fc:	83 e8 57             	sub    $0x57,%eax
c01055ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105602:	eb 23                	jmp    c0105627 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105604:	8b 45 08             	mov    0x8(%ebp),%eax
c0105607:	0f b6 00             	movzbl (%eax),%eax
c010560a:	3c 40                	cmp    $0x40,%al
c010560c:	7e 3b                	jle    c0105649 <strtol+0x136>
c010560e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105611:	0f b6 00             	movzbl (%eax),%eax
c0105614:	3c 5a                	cmp    $0x5a,%al
c0105616:	7f 31                	jg     c0105649 <strtol+0x136>
            dig = *s - 'A' + 10;
c0105618:	8b 45 08             	mov    0x8(%ebp),%eax
c010561b:	0f b6 00             	movzbl (%eax),%eax
c010561e:	0f be c0             	movsbl %al,%eax
c0105621:	83 e8 37             	sub    $0x37,%eax
c0105624:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010562a:	3b 45 10             	cmp    0x10(%ebp),%eax
c010562d:	7d 19                	jge    c0105648 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c010562f:	ff 45 08             	incl   0x8(%ebp)
c0105632:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105635:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105639:	89 c2                	mov    %eax,%edx
c010563b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010563e:	01 d0                	add    %edx,%eax
c0105640:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0105643:	e9 72 ff ff ff       	jmp    c01055ba <strtol+0xa7>
            break;
c0105648:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0105649:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010564d:	74 08                	je     c0105657 <strtol+0x144>
        *endptr = (char *) s;
c010564f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105652:	8b 55 08             	mov    0x8(%ebp),%edx
c0105655:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105657:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010565b:	74 07                	je     c0105664 <strtol+0x151>
c010565d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105660:	f7 d8                	neg    %eax
c0105662:	eb 03                	jmp    c0105667 <strtol+0x154>
c0105664:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105667:	c9                   	leave  
c0105668:	c3                   	ret    

c0105669 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105669:	55                   	push   %ebp
c010566a:	89 e5                	mov    %esp,%ebp
c010566c:	57                   	push   %edi
c010566d:	83 ec 24             	sub    $0x24,%esp
c0105670:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105673:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105676:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010567a:	8b 55 08             	mov    0x8(%ebp),%edx
c010567d:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105680:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105683:	8b 45 10             	mov    0x10(%ebp),%eax
c0105686:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105689:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010568c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105690:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105693:	89 d7                	mov    %edx,%edi
c0105695:	f3 aa                	rep stos %al,%es:(%edi)
c0105697:	89 fa                	mov    %edi,%edx
c0105699:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010569c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010569f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056a2:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01056a3:	83 c4 24             	add    $0x24,%esp
c01056a6:	5f                   	pop    %edi
c01056a7:	5d                   	pop    %ebp
c01056a8:	c3                   	ret    

c01056a9 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01056a9:	55                   	push   %ebp
c01056aa:	89 e5                	mov    %esp,%ebp
c01056ac:	57                   	push   %edi
c01056ad:	56                   	push   %esi
c01056ae:	53                   	push   %ebx
c01056af:	83 ec 30             	sub    $0x30,%esp
c01056b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056be:	8b 45 10             	mov    0x10(%ebp),%eax
c01056c1:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01056c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01056ca:	73 42                	jae    c010570e <memmove+0x65>
c01056cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01056d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056db:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01056de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056e1:	c1 e8 02             	shr    $0x2,%eax
c01056e4:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01056e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056ec:	89 d7                	mov    %edx,%edi
c01056ee:	89 c6                	mov    %eax,%esi
c01056f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01056f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01056f5:	83 e1 03             	and    $0x3,%ecx
c01056f8:	74 02                	je     c01056fc <memmove+0x53>
c01056fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01056fc:	89 f0                	mov    %esi,%eax
c01056fe:	89 fa                	mov    %edi,%edx
c0105700:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105703:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105706:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0105709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010570c:	eb 36                	jmp    c0105744 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010570e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105711:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105714:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105717:	01 c2                	add    %eax,%edx
c0105719:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010571c:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010571f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105722:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0105725:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105728:	89 c1                	mov    %eax,%ecx
c010572a:	89 d8                	mov    %ebx,%eax
c010572c:	89 d6                	mov    %edx,%esi
c010572e:	89 c7                	mov    %eax,%edi
c0105730:	fd                   	std    
c0105731:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105733:	fc                   	cld    
c0105734:	89 f8                	mov    %edi,%eax
c0105736:	89 f2                	mov    %esi,%edx
c0105738:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010573b:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010573e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0105741:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105744:	83 c4 30             	add    $0x30,%esp
c0105747:	5b                   	pop    %ebx
c0105748:	5e                   	pop    %esi
c0105749:	5f                   	pop    %edi
c010574a:	5d                   	pop    %ebp
c010574b:	c3                   	ret    

c010574c <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010574c:	55                   	push   %ebp
c010574d:	89 e5                	mov    %esp,%ebp
c010574f:	57                   	push   %edi
c0105750:	56                   	push   %esi
c0105751:	83 ec 20             	sub    $0x20,%esp
c0105754:	8b 45 08             	mov    0x8(%ebp),%eax
c0105757:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010575a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010575d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105760:	8b 45 10             	mov    0x10(%ebp),%eax
c0105763:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105766:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105769:	c1 e8 02             	shr    $0x2,%eax
c010576c:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010576e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105771:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105774:	89 d7                	mov    %edx,%edi
c0105776:	89 c6                	mov    %eax,%esi
c0105778:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010577a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010577d:	83 e1 03             	and    $0x3,%ecx
c0105780:	74 02                	je     c0105784 <memcpy+0x38>
c0105782:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105784:	89 f0                	mov    %esi,%eax
c0105786:	89 fa                	mov    %edi,%edx
c0105788:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010578b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010578e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105791:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105794:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105795:	83 c4 20             	add    $0x20,%esp
c0105798:	5e                   	pop    %esi
c0105799:	5f                   	pop    %edi
c010579a:	5d                   	pop    %ebp
c010579b:	c3                   	ret    

c010579c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010579c:	55                   	push   %ebp
c010579d:	89 e5                	mov    %esp,%ebp
c010579f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01057a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01057ae:	eb 2e                	jmp    c01057de <memcmp+0x42>
        if (*s1 != *s2) {
c01057b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01057b3:	0f b6 10             	movzbl (%eax),%edx
c01057b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01057b9:	0f b6 00             	movzbl (%eax),%eax
c01057bc:	38 c2                	cmp    %al,%dl
c01057be:	74 18                	je     c01057d8 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01057c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01057c3:	0f b6 00             	movzbl (%eax),%eax
c01057c6:	0f b6 d0             	movzbl %al,%edx
c01057c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01057cc:	0f b6 00             	movzbl (%eax),%eax
c01057cf:	0f b6 c0             	movzbl %al,%eax
c01057d2:	29 c2                	sub    %eax,%edx
c01057d4:	89 d0                	mov    %edx,%eax
c01057d6:	eb 18                	jmp    c01057f0 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01057d8:	ff 45 fc             	incl   -0x4(%ebp)
c01057db:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c01057de:	8b 45 10             	mov    0x10(%ebp),%eax
c01057e1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01057e4:	89 55 10             	mov    %edx,0x10(%ebp)
c01057e7:	85 c0                	test   %eax,%eax
c01057e9:	75 c5                	jne    c01057b0 <memcmp+0x14>
    }
    return 0;
c01057eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01057f0:	c9                   	leave  
c01057f1:	c3                   	ret    

c01057f2 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01057f2:	55                   	push   %ebp
c01057f3:	89 e5                	mov    %esp,%ebp
c01057f5:	83 ec 58             	sub    $0x58,%esp
c01057f8:	8b 45 10             	mov    0x10(%ebp),%eax
c01057fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01057fe:	8b 45 14             	mov    0x14(%ebp),%eax
c0105801:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105804:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105807:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010580a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010580d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105810:	8b 45 18             	mov    0x18(%ebp),%eax
c0105813:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105816:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105819:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010581c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010581f:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105822:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105825:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105828:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010582c:	74 1c                	je     c010584a <printnum+0x58>
c010582e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105831:	ba 00 00 00 00       	mov    $0x0,%edx
c0105836:	f7 75 e4             	divl   -0x1c(%ebp)
c0105839:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010583c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010583f:	ba 00 00 00 00       	mov    $0x0,%edx
c0105844:	f7 75 e4             	divl   -0x1c(%ebp)
c0105847:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010584a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010584d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105850:	f7 75 e4             	divl   -0x1c(%ebp)
c0105853:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105856:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105859:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010585c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010585f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105862:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105865:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105868:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010586b:	8b 45 18             	mov    0x18(%ebp),%eax
c010586e:	ba 00 00 00 00       	mov    $0x0,%edx
c0105873:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105876:	72 56                	jb     c01058ce <printnum+0xdc>
c0105878:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010587b:	77 05                	ja     c0105882 <printnum+0x90>
c010587d:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105880:	72 4c                	jb     c01058ce <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105882:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105885:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105888:	8b 45 20             	mov    0x20(%ebp),%eax
c010588b:	89 44 24 18          	mov    %eax,0x18(%esp)
c010588f:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105893:	8b 45 18             	mov    0x18(%ebp),%eax
c0105896:	89 44 24 10          	mov    %eax,0x10(%esp)
c010589a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010589d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01058a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01058a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058af:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b2:	89 04 24             	mov    %eax,(%esp)
c01058b5:	e8 38 ff ff ff       	call   c01057f2 <printnum>
c01058ba:	eb 1b                	jmp    c01058d7 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01058bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058c3:	8b 45 20             	mov    0x20(%ebp),%eax
c01058c6:	89 04 24             	mov    %eax,(%esp)
c01058c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01058cc:	ff d0                	call   *%eax
        while (-- width > 0)
c01058ce:	ff 4d 1c             	decl   0x1c(%ebp)
c01058d1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01058d5:	7f e5                	jg     c01058bc <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01058d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058da:	05 54 70 10 c0       	add    $0xc0107054,%eax
c01058df:	0f b6 00             	movzbl (%eax),%eax
c01058e2:	0f be c0             	movsbl %al,%eax
c01058e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01058e8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01058ec:	89 04 24             	mov    %eax,(%esp)
c01058ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01058f2:	ff d0                	call   *%eax
}
c01058f4:	90                   	nop
c01058f5:	c9                   	leave  
c01058f6:	c3                   	ret    

c01058f7 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01058f7:	55                   	push   %ebp
c01058f8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01058fa:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01058fe:	7e 14                	jle    c0105914 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105900:	8b 45 08             	mov    0x8(%ebp),%eax
c0105903:	8b 00                	mov    (%eax),%eax
c0105905:	8d 48 08             	lea    0x8(%eax),%ecx
c0105908:	8b 55 08             	mov    0x8(%ebp),%edx
c010590b:	89 0a                	mov    %ecx,(%edx)
c010590d:	8b 50 04             	mov    0x4(%eax),%edx
c0105910:	8b 00                	mov    (%eax),%eax
c0105912:	eb 30                	jmp    c0105944 <getuint+0x4d>
    }
    else if (lflag) {
c0105914:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105918:	74 16                	je     c0105930 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010591a:	8b 45 08             	mov    0x8(%ebp),%eax
c010591d:	8b 00                	mov    (%eax),%eax
c010591f:	8d 48 04             	lea    0x4(%eax),%ecx
c0105922:	8b 55 08             	mov    0x8(%ebp),%edx
c0105925:	89 0a                	mov    %ecx,(%edx)
c0105927:	8b 00                	mov    (%eax),%eax
c0105929:	ba 00 00 00 00       	mov    $0x0,%edx
c010592e:	eb 14                	jmp    c0105944 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105930:	8b 45 08             	mov    0x8(%ebp),%eax
c0105933:	8b 00                	mov    (%eax),%eax
c0105935:	8d 48 04             	lea    0x4(%eax),%ecx
c0105938:	8b 55 08             	mov    0x8(%ebp),%edx
c010593b:	89 0a                	mov    %ecx,(%edx)
c010593d:	8b 00                	mov    (%eax),%eax
c010593f:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105944:	5d                   	pop    %ebp
c0105945:	c3                   	ret    

c0105946 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105946:	55                   	push   %ebp
c0105947:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105949:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010594d:	7e 14                	jle    c0105963 <getint+0x1d>
        return va_arg(*ap, long long);
c010594f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105952:	8b 00                	mov    (%eax),%eax
c0105954:	8d 48 08             	lea    0x8(%eax),%ecx
c0105957:	8b 55 08             	mov    0x8(%ebp),%edx
c010595a:	89 0a                	mov    %ecx,(%edx)
c010595c:	8b 50 04             	mov    0x4(%eax),%edx
c010595f:	8b 00                	mov    (%eax),%eax
c0105961:	eb 28                	jmp    c010598b <getint+0x45>
    }
    else if (lflag) {
c0105963:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105967:	74 12                	je     c010597b <getint+0x35>
        return va_arg(*ap, long);
c0105969:	8b 45 08             	mov    0x8(%ebp),%eax
c010596c:	8b 00                	mov    (%eax),%eax
c010596e:	8d 48 04             	lea    0x4(%eax),%ecx
c0105971:	8b 55 08             	mov    0x8(%ebp),%edx
c0105974:	89 0a                	mov    %ecx,(%edx)
c0105976:	8b 00                	mov    (%eax),%eax
c0105978:	99                   	cltd   
c0105979:	eb 10                	jmp    c010598b <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010597b:	8b 45 08             	mov    0x8(%ebp),%eax
c010597e:	8b 00                	mov    (%eax),%eax
c0105980:	8d 48 04             	lea    0x4(%eax),%ecx
c0105983:	8b 55 08             	mov    0x8(%ebp),%edx
c0105986:	89 0a                	mov    %ecx,(%edx)
c0105988:	8b 00                	mov    (%eax),%eax
c010598a:	99                   	cltd   
    }
}
c010598b:	5d                   	pop    %ebp
c010598c:	c3                   	ret    

c010598d <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010598d:	55                   	push   %ebp
c010598e:	89 e5                	mov    %esp,%ebp
c0105990:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105993:	8d 45 14             	lea    0x14(%ebp),%eax
c0105996:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105999:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010599c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059a0:	8b 45 10             	mov    0x10(%ebp),%eax
c01059a3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b1:	89 04 24             	mov    %eax,(%esp)
c01059b4:	e8 03 00 00 00       	call   c01059bc <vprintfmt>
    va_end(ap);
}
c01059b9:	90                   	nop
c01059ba:	c9                   	leave  
c01059bb:	c3                   	ret    

c01059bc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01059bc:	55                   	push   %ebp
c01059bd:	89 e5                	mov    %esp,%ebp
c01059bf:	56                   	push   %esi
c01059c0:	53                   	push   %ebx
c01059c1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01059c4:	eb 17                	jmp    c01059dd <vprintfmt+0x21>
            if (ch == '\0') {
c01059c6:	85 db                	test   %ebx,%ebx
c01059c8:	0f 84 bf 03 00 00    	je     c0105d8d <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01059ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059d5:	89 1c 24             	mov    %ebx,(%esp)
c01059d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01059db:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01059dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01059e0:	8d 50 01             	lea    0x1(%eax),%edx
c01059e3:	89 55 10             	mov    %edx,0x10(%ebp)
c01059e6:	0f b6 00             	movzbl (%eax),%eax
c01059e9:	0f b6 d8             	movzbl %al,%ebx
c01059ec:	83 fb 25             	cmp    $0x25,%ebx
c01059ef:	75 d5                	jne    c01059c6 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01059f1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01059f5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01059fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105a02:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105a09:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a0c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105a0f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a12:	8d 50 01             	lea    0x1(%eax),%edx
c0105a15:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a18:	0f b6 00             	movzbl (%eax),%eax
c0105a1b:	0f b6 d8             	movzbl %al,%ebx
c0105a1e:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105a21:	83 f8 55             	cmp    $0x55,%eax
c0105a24:	0f 87 37 03 00 00    	ja     c0105d61 <vprintfmt+0x3a5>
c0105a2a:	8b 04 85 78 70 10 c0 	mov    -0x3fef8f88(,%eax,4),%eax
c0105a31:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105a33:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105a37:	eb d6                	jmp    c0105a0f <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105a39:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105a3d:	eb d0                	jmp    c0105a0f <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105a3f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105a46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105a49:	89 d0                	mov    %edx,%eax
c0105a4b:	c1 e0 02             	shl    $0x2,%eax
c0105a4e:	01 d0                	add    %edx,%eax
c0105a50:	01 c0                	add    %eax,%eax
c0105a52:	01 d8                	add    %ebx,%eax
c0105a54:	83 e8 30             	sub    $0x30,%eax
c0105a57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105a5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a5d:	0f b6 00             	movzbl (%eax),%eax
c0105a60:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105a63:	83 fb 2f             	cmp    $0x2f,%ebx
c0105a66:	7e 38                	jle    c0105aa0 <vprintfmt+0xe4>
c0105a68:	83 fb 39             	cmp    $0x39,%ebx
c0105a6b:	7f 33                	jg     c0105aa0 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105a6d:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105a70:	eb d4                	jmp    c0105a46 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105a72:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a75:	8d 50 04             	lea    0x4(%eax),%edx
c0105a78:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a7b:	8b 00                	mov    (%eax),%eax
c0105a7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105a80:	eb 1f                	jmp    c0105aa1 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105a82:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a86:	79 87                	jns    c0105a0f <vprintfmt+0x53>
                width = 0;
c0105a88:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105a8f:	e9 7b ff ff ff       	jmp    c0105a0f <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105a94:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105a9b:	e9 6f ff ff ff       	jmp    c0105a0f <vprintfmt+0x53>
            goto process_precision;
c0105aa0:	90                   	nop

        process_precision:
            if (width < 0)
c0105aa1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105aa5:	0f 89 64 ff ff ff    	jns    c0105a0f <vprintfmt+0x53>
                width = precision, precision = -1;
c0105aab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105aae:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ab1:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105ab8:	e9 52 ff ff ff       	jmp    c0105a0f <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105abd:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105ac0:	e9 4a ff ff ff       	jmp    c0105a0f <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105ac5:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ac8:	8d 50 04             	lea    0x4(%eax),%edx
c0105acb:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ace:	8b 00                	mov    (%eax),%eax
c0105ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ad3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ad7:	89 04 24             	mov    %eax,(%esp)
c0105ada:	8b 45 08             	mov    0x8(%ebp),%eax
c0105add:	ff d0                	call   *%eax
            break;
c0105adf:	e9 a4 02 00 00       	jmp    c0105d88 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105ae4:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ae7:	8d 50 04             	lea    0x4(%eax),%edx
c0105aea:	89 55 14             	mov    %edx,0x14(%ebp)
c0105aed:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105aef:	85 db                	test   %ebx,%ebx
c0105af1:	79 02                	jns    c0105af5 <vprintfmt+0x139>
                err = -err;
c0105af3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105af5:	83 fb 06             	cmp    $0x6,%ebx
c0105af8:	7f 0b                	jg     c0105b05 <vprintfmt+0x149>
c0105afa:	8b 34 9d 38 70 10 c0 	mov    -0x3fef8fc8(,%ebx,4),%esi
c0105b01:	85 f6                	test   %esi,%esi
c0105b03:	75 23                	jne    c0105b28 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105b05:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105b09:	c7 44 24 08 65 70 10 	movl   $0xc0107065,0x8(%esp)
c0105b10:	c0 
c0105b11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b18:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b1b:	89 04 24             	mov    %eax,(%esp)
c0105b1e:	e8 6a fe ff ff       	call   c010598d <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105b23:	e9 60 02 00 00       	jmp    c0105d88 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105b28:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105b2c:	c7 44 24 08 6e 70 10 	movl   $0xc010706e,0x8(%esp)
c0105b33:	c0 
c0105b34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b3e:	89 04 24             	mov    %eax,(%esp)
c0105b41:	e8 47 fe ff ff       	call   c010598d <printfmt>
            break;
c0105b46:	e9 3d 02 00 00       	jmp    c0105d88 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105b4b:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b4e:	8d 50 04             	lea    0x4(%eax),%edx
c0105b51:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b54:	8b 30                	mov    (%eax),%esi
c0105b56:	85 f6                	test   %esi,%esi
c0105b58:	75 05                	jne    c0105b5f <vprintfmt+0x1a3>
                p = "(null)";
c0105b5a:	be 71 70 10 c0       	mov    $0xc0107071,%esi
            }
            if (width > 0 && padc != '-') {
c0105b5f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b63:	7e 76                	jle    c0105bdb <vprintfmt+0x21f>
c0105b65:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105b69:	74 70                	je     c0105bdb <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105b6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b72:	89 34 24             	mov    %esi,(%esp)
c0105b75:	e8 f6 f7 ff ff       	call   c0105370 <strnlen>
c0105b7a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105b7d:	29 c2                	sub    %eax,%edx
c0105b7f:	89 d0                	mov    %edx,%eax
c0105b81:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b84:	eb 16                	jmp    c0105b9c <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105b86:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b8d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b91:	89 04 24             	mov    %eax,(%esp)
c0105b94:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b97:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105b99:	ff 4d e8             	decl   -0x18(%ebp)
c0105b9c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ba0:	7f e4                	jg     c0105b86 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105ba2:	eb 37                	jmp    c0105bdb <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105ba4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105ba8:	74 1f                	je     c0105bc9 <vprintfmt+0x20d>
c0105baa:	83 fb 1f             	cmp    $0x1f,%ebx
c0105bad:	7e 05                	jle    c0105bb4 <vprintfmt+0x1f8>
c0105baf:	83 fb 7e             	cmp    $0x7e,%ebx
c0105bb2:	7e 15                	jle    c0105bc9 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bbb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105bc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc5:	ff d0                	call   *%eax
c0105bc7:	eb 0f                	jmp    c0105bd8 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bd0:	89 1c 24             	mov    %ebx,(%esp)
c0105bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd6:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105bd8:	ff 4d e8             	decl   -0x18(%ebp)
c0105bdb:	89 f0                	mov    %esi,%eax
c0105bdd:	8d 70 01             	lea    0x1(%eax),%esi
c0105be0:	0f b6 00             	movzbl (%eax),%eax
c0105be3:	0f be d8             	movsbl %al,%ebx
c0105be6:	85 db                	test   %ebx,%ebx
c0105be8:	74 27                	je     c0105c11 <vprintfmt+0x255>
c0105bea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105bee:	78 b4                	js     c0105ba4 <vprintfmt+0x1e8>
c0105bf0:	ff 4d e4             	decl   -0x1c(%ebp)
c0105bf3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105bf7:	79 ab                	jns    c0105ba4 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105bf9:	eb 16                	jmp    c0105c11 <vprintfmt+0x255>
                putch(' ', putdat);
c0105bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c02:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c0c:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105c0e:	ff 4d e8             	decl   -0x18(%ebp)
c0105c11:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c15:	7f e4                	jg     c0105bfb <vprintfmt+0x23f>
            }
            break;
c0105c17:	e9 6c 01 00 00       	jmp    c0105d88 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105c1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c23:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c26:	89 04 24             	mov    %eax,(%esp)
c0105c29:	e8 18 fd ff ff       	call   c0105946 <getint>
c0105c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c31:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c3a:	85 d2                	test   %edx,%edx
c0105c3c:	79 26                	jns    c0105c64 <vprintfmt+0x2a8>
                putch('-', putdat);
c0105c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c45:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105c4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c4f:	ff d0                	call   *%eax
                num = -(long long)num;
c0105c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c57:	f7 d8                	neg    %eax
c0105c59:	83 d2 00             	adc    $0x0,%edx
c0105c5c:	f7 da                	neg    %edx
c0105c5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c61:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105c64:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105c6b:	e9 a8 00 00 00       	jmp    c0105d18 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105c70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c77:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c7a:	89 04 24             	mov    %eax,(%esp)
c0105c7d:	e8 75 fc ff ff       	call   c01058f7 <getuint>
c0105c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c85:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105c88:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105c8f:	e9 84 00 00 00       	jmp    c0105d18 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105c94:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c9b:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c9e:	89 04 24             	mov    %eax,(%esp)
c0105ca1:	e8 51 fc ff ff       	call   c01058f7 <getuint>
c0105ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ca9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105cac:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105cb3:	eb 63                	jmp    c0105d18 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cbc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105cc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc6:	ff d0                	call   *%eax
            putch('x', putdat);
c0105cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ccf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd9:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105cdb:	8b 45 14             	mov    0x14(%ebp),%eax
c0105cde:	8d 50 04             	lea    0x4(%eax),%edx
c0105ce1:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ce4:	8b 00                	mov    (%eax),%eax
c0105ce6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ce9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105cf0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105cf7:	eb 1f                	jmp    c0105d18 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105cf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d00:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d03:	89 04 24             	mov    %eax,(%esp)
c0105d06:	e8 ec fb ff ff       	call   c01058f7 <getuint>
c0105d0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d0e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105d11:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105d18:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d1f:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105d23:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105d26:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d34:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d38:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d43:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d46:	89 04 24             	mov    %eax,(%esp)
c0105d49:	e8 a4 fa ff ff       	call   c01057f2 <printnum>
            break;
c0105d4e:	eb 38                	jmp    c0105d88 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105d50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d57:	89 1c 24             	mov    %ebx,(%esp)
c0105d5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5d:	ff d0                	call   *%eax
            break;
c0105d5f:	eb 27                	jmp    c0105d88 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105d61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d68:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105d6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d72:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105d74:	ff 4d 10             	decl   0x10(%ebp)
c0105d77:	eb 03                	jmp    c0105d7c <vprintfmt+0x3c0>
c0105d79:	ff 4d 10             	decl   0x10(%ebp)
c0105d7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d7f:	48                   	dec    %eax
c0105d80:	0f b6 00             	movzbl (%eax),%eax
c0105d83:	3c 25                	cmp    $0x25,%al
c0105d85:	75 f2                	jne    c0105d79 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105d87:	90                   	nop
    while (1) {
c0105d88:	e9 37 fc ff ff       	jmp    c01059c4 <vprintfmt+0x8>
                return;
c0105d8d:	90                   	nop
        }
    }
}
c0105d8e:	83 c4 40             	add    $0x40,%esp
c0105d91:	5b                   	pop    %ebx
c0105d92:	5e                   	pop    %esi
c0105d93:	5d                   	pop    %ebp
c0105d94:	c3                   	ret    

c0105d95 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105d95:	55                   	push   %ebp
c0105d96:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105d98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d9b:	8b 40 08             	mov    0x8(%eax),%eax
c0105d9e:	8d 50 01             	lea    0x1(%eax),%edx
c0105da1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105da4:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105da7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105daa:	8b 10                	mov    (%eax),%edx
c0105dac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105daf:	8b 40 04             	mov    0x4(%eax),%eax
c0105db2:	39 c2                	cmp    %eax,%edx
c0105db4:	73 12                	jae    c0105dc8 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105db6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105db9:	8b 00                	mov    (%eax),%eax
c0105dbb:	8d 48 01             	lea    0x1(%eax),%ecx
c0105dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105dc1:	89 0a                	mov    %ecx,(%edx)
c0105dc3:	8b 55 08             	mov    0x8(%ebp),%edx
c0105dc6:	88 10                	mov    %dl,(%eax)
    }
}
c0105dc8:	90                   	nop
c0105dc9:	5d                   	pop    %ebp
c0105dca:	c3                   	ret    

c0105dcb <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105dcb:	55                   	push   %ebp
c0105dcc:	89 e5                	mov    %esp,%ebp
c0105dce:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105dd1:	8d 45 14             	lea    0x14(%ebp),%eax
c0105dd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dda:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105dde:	8b 45 10             	mov    0x10(%ebp),%eax
c0105de1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105de5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dec:	8b 45 08             	mov    0x8(%ebp),%eax
c0105def:	89 04 24             	mov    %eax,(%esp)
c0105df2:	e8 08 00 00 00       	call   c0105dff <vsnprintf>
c0105df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105dfd:	c9                   	leave  
c0105dfe:	c3                   	ret    

c0105dff <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105dff:	55                   	push   %ebp
c0105e00:	89 e5                	mov    %esp,%ebp
c0105e02:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105e05:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e0e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e11:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e14:	01 d0                	add    %edx,%eax
c0105e16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105e20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105e24:	74 0a                	je     c0105e30 <vsnprintf+0x31>
c0105e26:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e2c:	39 c2                	cmp    %eax,%edx
c0105e2e:	76 07                	jbe    c0105e37 <vsnprintf+0x38>
        return -E_INVAL;
c0105e30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105e35:	eb 2a                	jmp    c0105e61 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105e37:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105e3e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e41:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e45:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105e48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e4c:	c7 04 24 95 5d 10 c0 	movl   $0xc0105d95,(%esp)
c0105e53:	e8 64 fb ff ff       	call   c01059bc <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e5b:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105e61:	c9                   	leave  
c0105e62:	c3                   	ret    
