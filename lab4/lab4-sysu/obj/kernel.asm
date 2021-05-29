
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 50 12 00       	mov    $0x125000,%eax
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
c0100020:	a3 00 50 12 c0       	mov    %eax,0xc0125000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 40 12 c0       	mov    $0xc0124000,%esp
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
c010003c:	ba 64 a1 12 c0       	mov    $0xc012a164,%edx
c0100041:	b8 00 70 12 c0       	mov    $0xc0127000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 70 12 c0 	movl   $0xc0127000,(%esp)
c010005d:	e8 7b 8f 00 00       	call   c0108fdd <memset>

    cons_init();                // init the console
c0100062:	e8 db 1d 00 00       	call   c0101e42 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 98 10 c0 	movl   $0xc01098e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 98 10 c0 	movl   $0xc01098fc,(%esp)
c010007c:	e8 28 02 00 00       	call   c01002a9 <cprintf>

    print_kerninfo();
c0100081:	e8 c9 08 00 00       	call   c010094f <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a0 00 00 00       	call   c010012b <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 4a 6f 00 00       	call   c0106fda <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 12 1f 00 00       	call   c0101fa7 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 72 20 00 00       	call   c010210c <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 7d 34 00 00       	call   c010351c <vmm_init>
    proc_init();                // init process table
c010009f:	e8 f3 88 00 00       	call   c0108997 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 51 0d 00 00       	call   c0100dfa <ide_init>
    swap_init();                // init swap
c01000a9:	e8 a3 48 00 00       	call   c0104951 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 32 15 00 00       	call   c01015e5 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 29 20 00 00       	call   c01020e1 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 97 8a 00 00       	call   c0108b54 <cpu_idle>

c01000bd <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000bd:	55                   	push   %ebp
c01000be:	89 e5                	mov    %esp,%ebp
c01000c0:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000ca:	00 
c01000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d2:	00 
c01000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000da:	e8 b0 0c 00 00       	call   c0100d8f <mon_backtrace>
}
c01000df:	90                   	nop
c01000e0:	c9                   	leave  
c01000e1:	c3                   	ret    

c01000e2 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e2:	55                   	push   %ebp
c01000e3:	89 e5                	mov    %esp,%ebp
c01000e5:	53                   	push   %ebx
c01000e6:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000ef:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100101:	89 04 24             	mov    %eax,(%esp)
c0100104:	e8 b4 ff ff ff       	call   c01000bd <grade_backtrace2>
}
c0100109:	90                   	nop
c010010a:	83 c4 14             	add    $0x14,%esp
c010010d:	5b                   	pop    %ebx
c010010e:	5d                   	pop    %ebp
c010010f:	c3                   	ret    

c0100110 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100110:	55                   	push   %ebp
c0100111:	89 e5                	mov    %esp,%ebp
c0100113:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100116:	8b 45 10             	mov    0x10(%ebp),%eax
c0100119:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100120:	89 04 24             	mov    %eax,(%esp)
c0100123:	e8 ba ff ff ff       	call   c01000e2 <grade_backtrace1>
}
c0100128:	90                   	nop
c0100129:	c9                   	leave  
c010012a:	c3                   	ret    

c010012b <grade_backtrace>:

void
grade_backtrace(void) {
c010012b:	55                   	push   %ebp
c010012c:	89 e5                	mov    %esp,%ebp
c010012e:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100131:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100136:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013d:	ff 
c010013e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100149:	e8 c2 ff ff ff       	call   c0100110 <grade_backtrace0>
}
c010014e:	90                   	nop
c010014f:	c9                   	leave  
c0100150:	c3                   	ret    

c0100151 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100151:	55                   	push   %ebp
c0100152:	89 e5                	mov    %esp,%ebp
c0100154:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100157:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015a:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015d:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100160:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100163:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100167:	83 e0 03             	and    $0x3,%eax
c010016a:	89 c2                	mov    %eax,%edx
c010016c:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100171:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100175:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100179:	c7 04 24 01 99 10 c0 	movl   $0xc0109901,(%esp)
c0100180:	e8 24 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100185:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100189:	89 c2                	mov    %eax,%edx
c010018b:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 0f 99 10 c0 	movl   $0xc010990f,(%esp)
c010019f:	e8 05 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	89 c2                	mov    %eax,%edx
c01001aa:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b7:	c7 04 24 1d 99 10 c0 	movl   $0xc010991d,(%esp)
c01001be:	e8 e6 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c7:	89 c2                	mov    %eax,%edx
c01001c9:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001ce:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d6:	c7 04 24 2b 99 10 c0 	movl   $0xc010992b,(%esp)
c01001dd:	e8 c7 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e6:	89 c2                	mov    %eax,%edx
c01001e8:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001ed:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f5:	c7 04 24 39 99 10 c0 	movl   $0xc0109939,(%esp)
c01001fc:	e8 a8 00 00 00       	call   c01002a9 <cprintf>
    round ++;
c0100201:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100206:	40                   	inc    %eax
c0100207:	a3 00 70 12 c0       	mov    %eax,0xc0127000
}
c010020c:	90                   	nop
c010020d:	c9                   	leave  
c010020e:	c3                   	ret    

c010020f <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020f:	55                   	push   %ebp
c0100210:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100212:	90                   	nop
c0100213:	5d                   	pop    %ebp
c0100214:	c3                   	ret    

c0100215 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100218:	90                   	nop
c0100219:	5d                   	pop    %ebp
c010021a:	c3                   	ret    

c010021b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021b:	55                   	push   %ebp
c010021c:	89 e5                	mov    %esp,%ebp
c010021e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100221:	e8 2b ff ff ff       	call   c0100151 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100226:	c7 04 24 48 99 10 c0 	movl   $0xc0109948,(%esp)
c010022d:	e8 77 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_user();
c0100232:	e8 d8 ff ff ff       	call   c010020f <lab1_switch_to_user>
    lab1_print_cur_status();
c0100237:	e8 15 ff ff ff       	call   c0100151 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023c:	c7 04 24 68 99 10 c0 	movl   $0xc0109968,(%esp)
c0100243:	e8 61 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_kernel();
c0100248:	e8 c8 ff ff ff       	call   c0100215 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024d:	e8 ff fe ff ff       	call   c0100151 <lab1_print_cur_status>
}
c0100252:	90                   	nop
c0100253:	c9                   	leave  
c0100254:	c3                   	ret    

c0100255 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100255:	55                   	push   %ebp
c0100256:	89 e5                	mov    %esp,%ebp
c0100258:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010025b:	8b 45 08             	mov    0x8(%ebp),%eax
c010025e:	89 04 24             	mov    %eax,(%esp)
c0100261:	e8 09 1c 00 00       	call   c0101e6f <cons_putc>
    (*cnt) ++;
c0100266:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100269:	8b 00                	mov    (%eax),%eax
c010026b:	8d 50 01             	lea    0x1(%eax),%edx
c010026e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100271:	89 10                	mov    %edx,(%eax)
}
c0100273:	90                   	nop
c0100274:	c9                   	leave  
c0100275:	c3                   	ret    

c0100276 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100276:	55                   	push   %ebp
c0100277:	89 e5                	mov    %esp,%ebp
c0100279:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010027c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100283:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100286:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010028a:	8b 45 08             	mov    0x8(%ebp),%eax
c010028d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100291:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100294:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100298:	c7 04 24 55 02 10 c0 	movl   $0xc0100255,(%esp)
c010029f:	e8 8c 90 00 00       	call   c0109330 <vprintfmt>
    return cnt;
c01002a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a7:	c9                   	leave  
c01002a8:	c3                   	ret    

c01002a9 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a9:	55                   	push   %ebp
c01002aa:	89 e5                	mov    %esp,%ebp
c01002ac:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002af:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 af ff ff ff       	call   c0100276 <vcprintf>
c01002c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002cd:	c9                   	leave  
c01002ce:	c3                   	ret    

c01002cf <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002cf:	55                   	push   %ebp
c01002d0:	89 e5                	mov    %esp,%ebp
c01002d2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d8:	89 04 24             	mov    %eax,(%esp)
c01002db:	e8 8f 1b 00 00       	call   c0101e6f <cons_putc>
}
c01002e0:	90                   	nop
c01002e1:	c9                   	leave  
c01002e2:	c3                   	ret    

c01002e3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002e3:	55                   	push   %ebp
c01002e4:	89 e5                	mov    %esp,%ebp
c01002e6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002f0:	eb 13                	jmp    c0100305 <cputs+0x22>
        cputch(c, &cnt);
c01002f2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002f6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002fd:	89 04 24             	mov    %eax,(%esp)
c0100300:	e8 50 ff ff ff       	call   c0100255 <cputch>
    while ((c = *str ++) != '\0') {
c0100305:	8b 45 08             	mov    0x8(%ebp),%eax
c0100308:	8d 50 01             	lea    0x1(%eax),%edx
c010030b:	89 55 08             	mov    %edx,0x8(%ebp)
c010030e:	0f b6 00             	movzbl (%eax),%eax
c0100311:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100314:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100318:	75 d8                	jne    c01002f2 <cputs+0xf>
    }
    cputch('\n', &cnt);
c010031a:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010031d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100321:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100328:	e8 28 ff ff ff       	call   c0100255 <cputch>
    return cnt;
c010032d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100330:	c9                   	leave  
c0100331:	c3                   	ret    

c0100332 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100332:	55                   	push   %ebp
c0100333:	89 e5                	mov    %esp,%ebp
c0100335:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100338:	e8 6f 1b 00 00       	call   c0101eac <cons_getc>
c010033d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100340:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100344:	74 f2                	je     c0100338 <getchar+0x6>
        /* do nothing */;
    return c;
c0100346:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100349:	c9                   	leave  
c010034a:	c3                   	ret    

c010034b <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010034b:	55                   	push   %ebp
c010034c:	89 e5                	mov    %esp,%ebp
c010034e:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100351:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100355:	74 13                	je     c010036a <readline+0x1f>
        cprintf("%s", prompt);
c0100357:	8b 45 08             	mov    0x8(%ebp),%eax
c010035a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035e:	c7 04 24 87 99 10 c0 	movl   $0xc0109987,(%esp)
c0100365:	e8 3f ff ff ff       	call   c01002a9 <cprintf>
    }
    int i = 0, c;
c010036a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100371:	e8 bc ff ff ff       	call   c0100332 <getchar>
c0100376:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100379:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010037d:	79 07                	jns    c0100386 <readline+0x3b>
            return NULL;
c010037f:	b8 00 00 00 00       	mov    $0x0,%eax
c0100384:	eb 78                	jmp    c01003fe <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100386:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010038a:	7e 28                	jle    c01003b4 <readline+0x69>
c010038c:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100393:	7f 1f                	jg     c01003b4 <readline+0x69>
            cputchar(c);
c0100395:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100398:	89 04 24             	mov    %eax,(%esp)
c010039b:	e8 2f ff ff ff       	call   c01002cf <cputchar>
            buf[i ++] = c;
c01003a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003a3:	8d 50 01             	lea    0x1(%eax),%edx
c01003a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003ac:	88 90 20 70 12 c0    	mov    %dl,-0x3fed8fe0(%eax)
c01003b2:	eb 45                	jmp    c01003f9 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003b4:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b8:	75 16                	jne    c01003d0 <readline+0x85>
c01003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003be:	7e 10                	jle    c01003d0 <readline+0x85>
            cputchar(c);
c01003c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c3:	89 04 24             	mov    %eax,(%esp)
c01003c6:	e8 04 ff ff ff       	call   c01002cf <cputchar>
            i --;
c01003cb:	ff 4d f4             	decl   -0xc(%ebp)
c01003ce:	eb 29                	jmp    c01003f9 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003d4:	74 06                	je     c01003dc <readline+0x91>
c01003d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003da:	75 95                	jne    c0100371 <readline+0x26>
            cputchar(c);
c01003dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003df:	89 04 24             	mov    %eax,(%esp)
c01003e2:	e8 e8 fe ff ff       	call   c01002cf <cputchar>
            buf[i] = '\0';
c01003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ea:	05 20 70 12 c0       	add    $0xc0127020,%eax
c01003ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f2:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
c01003f7:	eb 05                	jmp    c01003fe <readline+0xb3>
        c = getchar();
c01003f9:	e9 73 ff ff ff       	jmp    c0100371 <readline+0x26>
        }
    }
}
c01003fe:	c9                   	leave  
c01003ff:	c3                   	ret    

c0100400 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100400:	55                   	push   %ebp
c0100401:	89 e5                	mov    %esp,%ebp
c0100403:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100406:	a1 20 74 12 c0       	mov    0xc0127420,%eax
c010040b:	85 c0                	test   %eax,%eax
c010040d:	75 5b                	jne    c010046a <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c010040f:	c7 05 20 74 12 c0 01 	movl   $0x1,0xc0127420
c0100416:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100419:	8d 45 14             	lea    0x14(%ebp),%eax
c010041c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010041f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100422:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100426:	8b 45 08             	mov    0x8(%ebp),%eax
c0100429:	89 44 24 04          	mov    %eax,0x4(%esp)
c010042d:	c7 04 24 8a 99 10 c0 	movl   $0xc010998a,(%esp)
c0100434:	e8 70 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c0100439:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010043c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100440:	8b 45 10             	mov    0x10(%ebp),%eax
c0100443:	89 04 24             	mov    %eax,(%esp)
c0100446:	e8 2b fe ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c010044b:	c7 04 24 a6 99 10 c0 	movl   $0xc01099a6,(%esp)
c0100452:	e8 52 fe ff ff       	call   c01002a9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100457:	c7 04 24 a8 99 10 c0 	movl   $0xc01099a8,(%esp)
c010045e:	e8 46 fe ff ff       	call   c01002a9 <cprintf>
    print_stackframe();
c0100463:	e8 32 06 00 00       	call   c0100a9a <print_stackframe>
c0100468:	eb 01                	jmp    c010046b <__panic+0x6b>
        goto panic_dead;
c010046a:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046b:	e8 78 1c 00 00       	call   c01020e8 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100477:	e8 46 08 00 00       	call   c0100cc2 <kmonitor>
c010047c:	eb f2                	jmp    c0100470 <__panic+0x70>

c010047e <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010047e:	55                   	push   %ebp
c010047f:	89 e5                	mov    %esp,%ebp
c0100481:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100484:	8d 45 14             	lea    0x14(%ebp),%eax
c0100487:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010048a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100491:	8b 45 08             	mov    0x8(%ebp),%eax
c0100494:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100498:	c7 04 24 ba 99 10 c0 	movl   $0xc01099ba,(%esp)
c010049f:	e8 05 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c01004a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ae:	89 04 24             	mov    %eax,(%esp)
c01004b1:	e8 c0 fd ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c01004b6:	c7 04 24 a6 99 10 c0 	movl   $0xc01099a6,(%esp)
c01004bd:	e8 e7 fd ff ff       	call   c01002a9 <cprintf>
    va_end(ap);
}
c01004c2:	90                   	nop
c01004c3:	c9                   	leave  
c01004c4:	c3                   	ret    

c01004c5 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004c5:	55                   	push   %ebp
c01004c6:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c8:	a1 20 74 12 c0       	mov    0xc0127420,%eax
}
c01004cd:	5d                   	pop    %ebp
c01004ce:	c3                   	ret    

c01004cf <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004cf:	55                   	push   %ebp
c01004d0:	89 e5                	mov    %esp,%ebp
c01004d2:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d8:	8b 00                	mov    (%eax),%eax
c01004da:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e0:	8b 00                	mov    (%eax),%eax
c01004e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ec:	e9 ca 00 00 00       	jmp    c01005bb <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004f7:	01 d0                	add    %edx,%eax
c01004f9:	89 c2                	mov    %eax,%edx
c01004fb:	c1 ea 1f             	shr    $0x1f,%edx
c01004fe:	01 d0                	add    %edx,%eax
c0100500:	d1 f8                	sar    %eax
c0100502:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100505:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100508:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010050b:	eb 03                	jmp    c0100510 <stab_binsearch+0x41>
            m --;
c010050d:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100510:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100513:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100516:	7c 1f                	jl     c0100537 <stab_binsearch+0x68>
c0100518:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051b:	89 d0                	mov    %edx,%eax
c010051d:	01 c0                	add    %eax,%eax
c010051f:	01 d0                	add    %edx,%eax
c0100521:	c1 e0 02             	shl    $0x2,%eax
c0100524:	89 c2                	mov    %eax,%edx
c0100526:	8b 45 08             	mov    0x8(%ebp),%eax
c0100529:	01 d0                	add    %edx,%eax
c010052b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052f:	0f b6 c0             	movzbl %al,%eax
c0100532:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100535:	75 d6                	jne    c010050d <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100537:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010053a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010053d:	7d 09                	jge    c0100548 <stab_binsearch+0x79>
            l = true_m + 1;
c010053f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100542:	40                   	inc    %eax
c0100543:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100546:	eb 73                	jmp    c01005bb <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100548:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010054f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100552:	89 d0                	mov    %edx,%eax
c0100554:	01 c0                	add    %eax,%eax
c0100556:	01 d0                	add    %edx,%eax
c0100558:	c1 e0 02             	shl    $0x2,%eax
c010055b:	89 c2                	mov    %eax,%edx
c010055d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100560:	01 d0                	add    %edx,%eax
c0100562:	8b 40 08             	mov    0x8(%eax),%eax
c0100565:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100568:	76 11                	jbe    c010057b <stab_binsearch+0xac>
            *region_left = m;
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100570:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100572:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100575:	40                   	inc    %eax
c0100576:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100579:	eb 40                	jmp    c01005bb <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c010057b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010057e:	89 d0                	mov    %edx,%eax
c0100580:	01 c0                	add    %eax,%eax
c0100582:	01 d0                	add    %edx,%eax
c0100584:	c1 e0 02             	shl    $0x2,%eax
c0100587:	89 c2                	mov    %eax,%edx
c0100589:	8b 45 08             	mov    0x8(%ebp),%eax
c010058c:	01 d0                	add    %edx,%eax
c010058e:	8b 40 08             	mov    0x8(%eax),%eax
c0100591:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100594:	73 14                	jae    c01005aa <stab_binsearch+0xdb>
            *region_right = m - 1;
c0100596:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100599:	8d 50 ff             	lea    -0x1(%eax),%edx
c010059c:	8b 45 10             	mov    0x10(%ebp),%eax
c010059f:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a4:	48                   	dec    %eax
c01005a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a8:	eb 11                	jmp    c01005bb <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b0:	89 10                	mov    %edx,(%eax)
            l = m;
c01005b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b8:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005c1:	0f 8e 2a ff ff ff    	jle    c01004f1 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005cb:	75 0f                	jne    c01005dc <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d0:	8b 00                	mov    (%eax),%eax
c01005d2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d8:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005da:	eb 3e                	jmp    c010061a <stab_binsearch+0x14b>
        l = *region_right;
c01005dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01005df:	8b 00                	mov    (%eax),%eax
c01005e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005e4:	eb 03                	jmp    c01005e9 <stab_binsearch+0x11a>
c01005e6:	ff 4d fc             	decl   -0x4(%ebp)
c01005e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ec:	8b 00                	mov    (%eax),%eax
c01005ee:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005f1:	7e 1f                	jle    c0100612 <stab_binsearch+0x143>
c01005f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005f6:	89 d0                	mov    %edx,%eax
c01005f8:	01 c0                	add    %eax,%eax
c01005fa:	01 d0                	add    %edx,%eax
c01005fc:	c1 e0 02             	shl    $0x2,%eax
c01005ff:	89 c2                	mov    %eax,%edx
c0100601:	8b 45 08             	mov    0x8(%ebp),%eax
c0100604:	01 d0                	add    %edx,%eax
c0100606:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010060a:	0f b6 c0             	movzbl %al,%eax
c010060d:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100610:	75 d4                	jne    c01005e6 <stab_binsearch+0x117>
        *region_left = l;
c0100612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100615:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100618:	89 10                	mov    %edx,(%eax)
}
c010061a:	90                   	nop
c010061b:	c9                   	leave  
c010061c:	c3                   	ret    

c010061d <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010061d:	55                   	push   %ebp
c010061e:	89 e5                	mov    %esp,%ebp
c0100620:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100623:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100626:	c7 00 d8 99 10 c0    	movl   $0xc01099d8,(%eax)
    info->eip_line = 0;
c010062c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100639:	c7 40 08 d8 99 10 c0 	movl   $0xc01099d8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100640:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100643:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010064a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064d:	8b 55 08             	mov    0x8(%ebp),%edx
c0100650:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100653:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100656:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010065d:	c7 45 f4 b0 ba 10 c0 	movl   $0xc010bab0,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100664:	c7 45 f0 c8 d1 11 c0 	movl   $0xc011d1c8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010066b:	c7 45 ec c9 d1 11 c0 	movl   $0xc011d1c9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100672:	c7 45 e8 52 1a 12 c0 	movl   $0xc0121a52,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100679:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010067f:	76 0b                	jbe    c010068c <debuginfo_eip+0x6f>
c0100681:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100684:	48                   	dec    %eax
c0100685:	0f b6 00             	movzbl (%eax),%eax
c0100688:	84 c0                	test   %al,%al
c010068a:	74 0a                	je     c0100696 <debuginfo_eip+0x79>
        return -1;
c010068c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100691:	e9 b7 02 00 00       	jmp    c010094d <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100696:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010069d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a3:	29 c2                	sub    %eax,%edx
c01006a5:	89 d0                	mov    %edx,%eax
c01006a7:	c1 f8 02             	sar    $0x2,%eax
c01006aa:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006b0:	48                   	dec    %eax
c01006b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01006b7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006bb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006c2:	00 
c01006c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d4:	89 04 24             	mov    %eax,(%esp)
c01006d7:	e8 f3 fd ff ff       	call   c01004cf <stab_binsearch>
    if (lfile == 0)
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	85 c0                	test   %eax,%eax
c01006e1:	75 0a                	jne    c01006ed <debuginfo_eip+0xd0>
        return -1;
c01006e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e8:	e9 60 02 00 00       	jmp    c010094d <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01006fc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100700:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100707:	00 
c0100708:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010070b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010070f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100712:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100719:	89 04 24             	mov    %eax,(%esp)
c010071c:	e8 ae fd ff ff       	call   c01004cf <stab_binsearch>

    if (lfun <= rfun) {
c0100721:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100724:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100727:	39 c2                	cmp    %eax,%edx
c0100729:	7f 7c                	jg     c01007a7 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010072b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010072e:	89 c2                	mov    %eax,%edx
c0100730:	89 d0                	mov    %edx,%eax
c0100732:	01 c0                	add    %eax,%eax
c0100734:	01 d0                	add    %edx,%eax
c0100736:	c1 e0 02             	shl    $0x2,%eax
c0100739:	89 c2                	mov    %eax,%edx
c010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073e:	01 d0                	add    %edx,%eax
c0100740:	8b 00                	mov    (%eax),%eax
c0100742:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100745:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100748:	29 d1                	sub    %edx,%ecx
c010074a:	89 ca                	mov    %ecx,%edx
c010074c:	39 d0                	cmp    %edx,%eax
c010074e:	73 22                	jae    c0100772 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100750:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100753:	89 c2                	mov    %eax,%edx
c0100755:	89 d0                	mov    %edx,%eax
c0100757:	01 c0                	add    %eax,%eax
c0100759:	01 d0                	add    %edx,%eax
c010075b:	c1 e0 02             	shl    $0x2,%eax
c010075e:	89 c2                	mov    %eax,%edx
c0100760:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100763:	01 d0                	add    %edx,%eax
c0100765:	8b 10                	mov    (%eax),%edx
c0100767:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010076a:	01 c2                	add    %eax,%edx
c010076c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100772:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100775:	89 c2                	mov    %eax,%edx
c0100777:	89 d0                	mov    %edx,%eax
c0100779:	01 c0                	add    %eax,%eax
c010077b:	01 d0                	add    %edx,%eax
c010077d:	c1 e0 02             	shl    $0x2,%eax
c0100780:	89 c2                	mov    %eax,%edx
c0100782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100785:	01 d0                	add    %edx,%eax
c0100787:	8b 50 08             	mov    0x8(%eax),%edx
c010078a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100793:	8b 40 10             	mov    0x10(%eax),%eax
c0100796:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100799:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010079f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007a5:	eb 15                	jmp    c01007bc <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007aa:	8b 55 08             	mov    0x8(%ebp),%edx
c01007ad:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007bf:	8b 40 08             	mov    0x8(%eax),%eax
c01007c2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007c9:	00 
c01007ca:	89 04 24             	mov    %eax,(%esp)
c01007cd:	e8 87 86 00 00       	call   c0108e59 <strfind>
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d7:	8b 40 08             	mov    0x8(%eax),%eax
c01007da:	29 c2                	sub    %eax,%edx
c01007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007df:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01007e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007e9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007f0:	00 
c01007f1:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100802:	89 04 24             	mov    %eax,(%esp)
c0100805:	e8 c5 fc ff ff       	call   c01004cf <stab_binsearch>
    if (lline <= rline) {
c010080a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010080d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100810:	39 c2                	cmp    %eax,%edx
c0100812:	7f 23                	jg     c0100837 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c0100814:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100817:	89 c2                	mov    %eax,%edx
c0100819:	89 d0                	mov    %edx,%eax
c010081b:	01 c0                	add    %eax,%eax
c010081d:	01 d0                	add    %edx,%eax
c010081f:	c1 e0 02             	shl    $0x2,%eax
c0100822:	89 c2                	mov    %eax,%edx
c0100824:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100827:	01 d0                	add    %edx,%eax
c0100829:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010082d:	89 c2                	mov    %eax,%edx
c010082f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100832:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100835:	eb 11                	jmp    c0100848 <debuginfo_eip+0x22b>
        return -1;
c0100837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010083c:	e9 0c 01 00 00       	jmp    c010094d <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100841:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100844:	48                   	dec    %eax
c0100845:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100848:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010084e:	39 c2                	cmp    %eax,%edx
c0100850:	7c 56                	jl     c01008a8 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c0100852:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100855:	89 c2                	mov    %eax,%edx
c0100857:	89 d0                	mov    %edx,%eax
c0100859:	01 c0                	add    %eax,%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	c1 e0 02             	shl    $0x2,%eax
c0100860:	89 c2                	mov    %eax,%edx
c0100862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100865:	01 d0                	add    %edx,%eax
c0100867:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086b:	3c 84                	cmp    $0x84,%al
c010086d:	74 39                	je     c01008a8 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010086f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100872:	89 c2                	mov    %eax,%edx
c0100874:	89 d0                	mov    %edx,%eax
c0100876:	01 c0                	add    %eax,%eax
c0100878:	01 d0                	add    %edx,%eax
c010087a:	c1 e0 02             	shl    $0x2,%eax
c010087d:	89 c2                	mov    %eax,%edx
c010087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100882:	01 d0                	add    %edx,%eax
c0100884:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100888:	3c 64                	cmp    $0x64,%al
c010088a:	75 b5                	jne    c0100841 <debuginfo_eip+0x224>
c010088c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010088f:	89 c2                	mov    %eax,%edx
c0100891:	89 d0                	mov    %edx,%eax
c0100893:	01 c0                	add    %eax,%eax
c0100895:	01 d0                	add    %edx,%eax
c0100897:	c1 e0 02             	shl    $0x2,%eax
c010089a:	89 c2                	mov    %eax,%edx
c010089c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089f:	01 d0                	add    %edx,%eax
c01008a1:	8b 40 08             	mov    0x8(%eax),%eax
c01008a4:	85 c0                	test   %eax,%eax
c01008a6:	74 99                	je     c0100841 <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008ae:	39 c2                	cmp    %eax,%edx
c01008b0:	7c 46                	jl     c01008f8 <debuginfo_eip+0x2db>
c01008b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b5:	89 c2                	mov    %eax,%edx
c01008b7:	89 d0                	mov    %edx,%eax
c01008b9:	01 c0                	add    %eax,%eax
c01008bb:	01 d0                	add    %edx,%eax
c01008bd:	c1 e0 02             	shl    $0x2,%eax
c01008c0:	89 c2                	mov    %eax,%edx
c01008c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c5:	01 d0                	add    %edx,%eax
c01008c7:	8b 00                	mov    (%eax),%eax
c01008c9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008cf:	29 d1                	sub    %edx,%ecx
c01008d1:	89 ca                	mov    %ecx,%edx
c01008d3:	39 d0                	cmp    %edx,%eax
c01008d5:	73 21                	jae    c01008f8 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008da:	89 c2                	mov    %eax,%edx
c01008dc:	89 d0                	mov    %edx,%eax
c01008de:	01 c0                	add    %eax,%eax
c01008e0:	01 d0                	add    %edx,%eax
c01008e2:	c1 e0 02             	shl    $0x2,%eax
c01008e5:	89 c2                	mov    %eax,%edx
c01008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ea:	01 d0                	add    %edx,%eax
c01008ec:	8b 10                	mov    (%eax),%edx
c01008ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008f1:	01 c2                	add    %eax,%edx
c01008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f6:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008fe:	39 c2                	cmp    %eax,%edx
c0100900:	7d 46                	jge    c0100948 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c0100902:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100905:	40                   	inc    %eax
c0100906:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100909:	eb 16                	jmp    c0100921 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010090b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010090e:	8b 40 14             	mov    0x14(%eax),%eax
c0100911:	8d 50 01             	lea    0x1(%eax),%edx
c0100914:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100917:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c010091a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010091d:	40                   	inc    %eax
c010091e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100921:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100924:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100927:	39 c2                	cmp    %eax,%edx
c0100929:	7d 1d                	jge    c0100948 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010092b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010092e:	89 c2                	mov    %eax,%edx
c0100930:	89 d0                	mov    %edx,%eax
c0100932:	01 c0                	add    %eax,%eax
c0100934:	01 d0                	add    %edx,%eax
c0100936:	c1 e0 02             	shl    $0x2,%eax
c0100939:	89 c2                	mov    %eax,%edx
c010093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010093e:	01 d0                	add    %edx,%eax
c0100940:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100944:	3c a0                	cmp    $0xa0,%al
c0100946:	74 c3                	je     c010090b <debuginfo_eip+0x2ee>
        }
    }
    return 0;
c0100948:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010094d:	c9                   	leave  
c010094e:	c3                   	ret    

c010094f <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010094f:	55                   	push   %ebp
c0100950:	89 e5                	mov    %esp,%ebp
c0100952:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100955:	c7 04 24 e2 99 10 c0 	movl   $0xc01099e2,(%esp)
c010095c:	e8 48 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100961:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100968:	c0 
c0100969:	c7 04 24 fb 99 10 c0 	movl   $0xc01099fb,(%esp)
c0100970:	e8 34 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100975:	c7 44 24 04 d9 98 10 	movl   $0xc01098d9,0x4(%esp)
c010097c:	c0 
c010097d:	c7 04 24 13 9a 10 c0 	movl   $0xc0109a13,(%esp)
c0100984:	e8 20 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100989:	c7 44 24 04 00 70 12 	movl   $0xc0127000,0x4(%esp)
c0100990:	c0 
c0100991:	c7 04 24 2b 9a 10 c0 	movl   $0xc0109a2b,(%esp)
c0100998:	e8 0c f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c010099d:	c7 44 24 04 64 a1 12 	movl   $0xc012a164,0x4(%esp)
c01009a4:	c0 
c01009a5:	c7 04 24 43 9a 10 c0 	movl   $0xc0109a43,(%esp)
c01009ac:	e8 f8 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009b1:	b8 64 a1 12 c0       	mov    $0xc012a164,%eax
c01009b6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009bc:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009c1:	29 c2                	sub    %eax,%edx
c01009c3:	89 d0                	mov    %edx,%eax
c01009c5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009cb:	85 c0                	test   %eax,%eax
c01009cd:	0f 48 c2             	cmovs  %edx,%eax
c01009d0:	c1 f8 0a             	sar    $0xa,%eax
c01009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d7:	c7 04 24 5c 9a 10 c0 	movl   $0xc0109a5c,(%esp)
c01009de:	e8 c6 f8 ff ff       	call   c01002a9 <cprintf>
}
c01009e3:	90                   	nop
c01009e4:	c9                   	leave  
c01009e5:	c3                   	ret    

c01009e6 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009e6:	55                   	push   %ebp
c01009e7:	89 e5                	mov    %esp,%ebp
c01009e9:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009ef:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f9:	89 04 24             	mov    %eax,(%esp)
c01009fc:	e8 1c fc ff ff       	call   c010061d <debuginfo_eip>
c0100a01:	85 c0                	test   %eax,%eax
c0100a03:	74 15                	je     c0100a1a <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0c:	c7 04 24 86 9a 10 c0 	movl   $0xc0109a86,(%esp)
c0100a13:	e8 91 f8 ff ff       	call   c01002a9 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a18:	eb 6c                	jmp    c0100a86 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a21:	eb 1b                	jmp    c0100a3e <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a29:	01 d0                	add    %edx,%eax
c0100a2b:	0f b6 00             	movzbl (%eax),%eax
c0100a2e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a37:	01 ca                	add    %ecx,%edx
c0100a39:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a3b:	ff 45 f4             	incl   -0xc(%ebp)
c0100a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a41:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a44:	7c dd                	jl     c0100a23 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a46:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a4f:	01 d0                	add    %edx,%eax
c0100a51:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a57:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a5a:	89 d1                	mov    %edx,%ecx
c0100a5c:	29 c1                	sub    %eax,%ecx
c0100a5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a61:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a64:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a68:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a72:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a7a:	c7 04 24 a2 9a 10 c0 	movl   $0xc0109aa2,(%esp)
c0100a81:	e8 23 f8 ff ff       	call   c01002a9 <cprintf>
}
c0100a86:	90                   	nop
c0100a87:	c9                   	leave  
c0100a88:	c3                   	ret    

c0100a89 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a89:	55                   	push   %ebp
c0100a8a:	89 e5                	mov    %esp,%ebp
c0100a8c:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a8f:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a92:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a98:	c9                   	leave  
c0100a99:	c3                   	ret    

c0100a9a <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a9a:	55                   	push   %ebp
c0100a9b:	89 e5                	mov    %esp,%ebp
c0100a9d:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100aa0:	89 e8                	mov    %ebp,%eax
c0100aa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100aa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
c0100aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
c0100aab:	e8 d9 ff ff ff       	call   c0100a89 <read_eip>
c0100ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for(uint32_t i = 0; ebp && i < STACKFRAME_DEPTH; i++) {
c0100ab3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aba:	e9 84 00 00 00       	jmp    c0100b43 <print_stackframe+0xa9>
          cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100acd:	c7 04 24 b4 9a 10 c0 	movl   $0xc0109ab4,(%esp)
c0100ad4:	e8 d0 f7 ff ff       	call   c01002a9 <cprintf>
          uint32_t* args = (uint32_t*)ebp + 2;
c0100ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adc:	83 c0 08             	add    $0x8,%eax
c0100adf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          for(uint32_t j = 0; j < 4; j++)
c0100ae2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ae9:	eb 24                	jmp    c0100b0f <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100af8:	01 d0                	add    %edx,%eax
c0100afa:	8b 00                	mov    (%eax),%eax
c0100afc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b00:	c7 04 24 d0 9a 10 c0 	movl   $0xc0109ad0,(%esp)
c0100b07:	e8 9d f7 ff ff       	call   c01002a9 <cprintf>
          for(uint32_t j = 0; j < 4; j++)
c0100b0c:	ff 45 e8             	incl   -0x18(%ebp)
c0100b0f:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b13:	76 d6                	jbe    c0100aeb <print_stackframe+0x51>
        cprintf("\n");
c0100b15:	c7 04 24 d8 9a 10 c0 	movl   $0xc0109ad8,(%esp)
c0100b1c:	e8 88 f7 ff ff       	call   c01002a9 <cprintf>
        print_debuginfo(eip-1);
c0100b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b24:	48                   	dec    %eax
c0100b25:	89 04 24             	mov    %eax,(%esp)
c0100b28:	e8 b9 fe ff ff       	call   c01009e6 <print_debuginfo>
        eip = ((uint32_t*)ebp)[1];
c0100b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b30:	83 c0 04             	add    $0x4,%eax
c0100b33:	8b 00                	mov    (%eax),%eax
c0100b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t*)ebp)[0];
c0100b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3b:	8b 00                	mov    (%eax),%eax
c0100b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(uint32_t i = 0; ebp && i < STACKFRAME_DEPTH; i++) {
c0100b40:	ff 45 ec             	incl   -0x14(%ebp)
c0100b43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b47:	74 0a                	je     c0100b53 <print_stackframe+0xb9>
c0100b49:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b4d:	0f 86 6c ff ff ff    	jbe    c0100abf <print_stackframe+0x25>
      }
c0100b53:	90                   	nop
c0100b54:	c9                   	leave  
c0100b55:	c3                   	ret    

c0100b56 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b56:	55                   	push   %ebp
c0100b57:	89 e5                	mov    %esp,%ebp
c0100b59:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b63:	eb 0c                	jmp    c0100b71 <parse+0x1b>
            *buf ++ = '\0';
c0100b65:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b68:	8d 50 01             	lea    0x1(%eax),%edx
c0100b6b:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b6e:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b71:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b74:	0f b6 00             	movzbl (%eax),%eax
c0100b77:	84 c0                	test   %al,%al
c0100b79:	74 1d                	je     c0100b98 <parse+0x42>
c0100b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7e:	0f b6 00             	movzbl (%eax),%eax
c0100b81:	0f be c0             	movsbl %al,%eax
c0100b84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b88:	c7 04 24 5c 9b 10 c0 	movl   $0xc0109b5c,(%esp)
c0100b8f:	e8 93 82 00 00       	call   c0108e27 <strchr>
c0100b94:	85 c0                	test   %eax,%eax
c0100b96:	75 cd                	jne    c0100b65 <parse+0xf>
        }
        if (*buf == '\0') {
c0100b98:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9b:	0f b6 00             	movzbl (%eax),%eax
c0100b9e:	84 c0                	test   %al,%al
c0100ba0:	74 65                	je     c0100c07 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ba2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ba6:	75 14                	jne    c0100bbc <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ba8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100baf:	00 
c0100bb0:	c7 04 24 61 9b 10 c0 	movl   $0xc0109b61,(%esp)
c0100bb7:	e8 ed f6 ff ff       	call   c01002a9 <cprintf>
        }
        argv[argc ++] = buf;
c0100bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bbf:	8d 50 01             	lea    0x1(%eax),%edx
c0100bc2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bcf:	01 c2                	add    %eax,%edx
c0100bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd4:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bd6:	eb 03                	jmp    c0100bdb <parse+0x85>
            buf ++;
c0100bd8:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bde:	0f b6 00             	movzbl (%eax),%eax
c0100be1:	84 c0                	test   %al,%al
c0100be3:	74 8c                	je     c0100b71 <parse+0x1b>
c0100be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be8:	0f b6 00             	movzbl (%eax),%eax
c0100beb:	0f be c0             	movsbl %al,%eax
c0100bee:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf2:	c7 04 24 5c 9b 10 c0 	movl   $0xc0109b5c,(%esp)
c0100bf9:	e8 29 82 00 00       	call   c0108e27 <strchr>
c0100bfe:	85 c0                	test   %eax,%eax
c0100c00:	74 d6                	je     c0100bd8 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c02:	e9 6a ff ff ff       	jmp    c0100b71 <parse+0x1b>
            break;
c0100c07:	90                   	nop
        }
    }
    return argc;
c0100c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c0b:	c9                   	leave  
c0100c0c:	c3                   	ret    

c0100c0d <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c0d:	55                   	push   %ebp
c0100c0e:	89 e5                	mov    %esp,%ebp
c0100c10:	53                   	push   %ebx
c0100c11:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c14:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1e:	89 04 24             	mov    %eax,(%esp)
c0100c21:	e8 30 ff ff ff       	call   c0100b56 <parse>
c0100c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c2d:	75 0a                	jne    c0100c39 <runcmd+0x2c>
        return 0;
c0100c2f:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c34:	e9 83 00 00 00       	jmp    c0100cbc <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c40:	eb 5a                	jmp    c0100c9c <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c42:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c48:	89 d0                	mov    %edx,%eax
c0100c4a:	01 c0                	add    %eax,%eax
c0100c4c:	01 d0                	add    %edx,%eax
c0100c4e:	c1 e0 02             	shl    $0x2,%eax
c0100c51:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100c56:	8b 00                	mov    (%eax),%eax
c0100c58:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c5c:	89 04 24             	mov    %eax,(%esp)
c0100c5f:	e8 26 81 00 00       	call   c0108d8a <strcmp>
c0100c64:	85 c0                	test   %eax,%eax
c0100c66:	75 31                	jne    c0100c99 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c6b:	89 d0                	mov    %edx,%eax
c0100c6d:	01 c0                	add    %eax,%eax
c0100c6f:	01 d0                	add    %edx,%eax
c0100c71:	c1 e0 02             	shl    $0x2,%eax
c0100c74:	05 08 40 12 c0       	add    $0xc0124008,%eax
c0100c79:	8b 10                	mov    (%eax),%edx
c0100c7b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c7e:	83 c0 04             	add    $0x4,%eax
c0100c81:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c84:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c92:	89 1c 24             	mov    %ebx,(%esp)
c0100c95:	ff d2                	call   *%edx
c0100c97:	eb 23                	jmp    c0100cbc <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c99:	ff 45 f4             	incl   -0xc(%ebp)
c0100c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c9f:	83 f8 02             	cmp    $0x2,%eax
c0100ca2:	76 9e                	jbe    c0100c42 <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100ca4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cab:	c7 04 24 7f 9b 10 c0 	movl   $0xc0109b7f,(%esp)
c0100cb2:	e8 f2 f5 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0100cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbc:	83 c4 64             	add    $0x64,%esp
c0100cbf:	5b                   	pop    %ebx
c0100cc0:	5d                   	pop    %ebp
c0100cc1:	c3                   	ret    

c0100cc2 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cc2:	55                   	push   %ebp
c0100cc3:	89 e5                	mov    %esp,%ebp
c0100cc5:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cc8:	c7 04 24 98 9b 10 c0 	movl   $0xc0109b98,(%esp)
c0100ccf:	e8 d5 f5 ff ff       	call   c01002a9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cd4:	c7 04 24 c0 9b 10 c0 	movl   $0xc0109bc0,(%esp)
c0100cdb:	e8 c9 f5 ff ff       	call   c01002a9 <cprintf>

    if (tf != NULL) {
c0100ce0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ce4:	74 0b                	je     c0100cf1 <kmonitor+0x2f>
        print_trapframe(tf);
c0100ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce9:	89 04 24             	mov    %eax,(%esp)
c0100cec:	e8 d3 15 00 00       	call   c01022c4 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cf1:	c7 04 24 e5 9b 10 c0 	movl   $0xc0109be5,(%esp)
c0100cf8:	e8 4e f6 ff ff       	call   c010034b <readline>
c0100cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d04:	74 eb                	je     c0100cf1 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d06:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d10:	89 04 24             	mov    %eax,(%esp)
c0100d13:	e8 f5 fe ff ff       	call   c0100c0d <runcmd>
c0100d18:	85 c0                	test   %eax,%eax
c0100d1a:	78 02                	js     c0100d1e <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d1c:	eb d3                	jmp    c0100cf1 <kmonitor+0x2f>
                break;
c0100d1e:	90                   	nop
            }
        }
    }
}
c0100d1f:	90                   	nop
c0100d20:	c9                   	leave  
c0100d21:	c3                   	ret    

c0100d22 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d22:	55                   	push   %ebp
c0100d23:	89 e5                	mov    %esp,%ebp
c0100d25:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d2f:	eb 3d                	jmp    c0100d6e <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d34:	89 d0                	mov    %edx,%eax
c0100d36:	01 c0                	add    %eax,%eax
c0100d38:	01 d0                	add    %edx,%eax
c0100d3a:	c1 e0 02             	shl    $0x2,%eax
c0100d3d:	05 04 40 12 c0       	add    $0xc0124004,%eax
c0100d42:	8b 08                	mov    (%eax),%ecx
c0100d44:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d47:	89 d0                	mov    %edx,%eax
c0100d49:	01 c0                	add    %eax,%eax
c0100d4b:	01 d0                	add    %edx,%eax
c0100d4d:	c1 e0 02             	shl    $0x2,%eax
c0100d50:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100d55:	8b 00                	mov    (%eax),%eax
c0100d57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d5f:	c7 04 24 e9 9b 10 c0 	movl   $0xc0109be9,(%esp)
c0100d66:	e8 3e f5 ff ff       	call   c01002a9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d6b:	ff 45 f4             	incl   -0xc(%ebp)
c0100d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d71:	83 f8 02             	cmp    $0x2,%eax
c0100d74:	76 bb                	jbe    c0100d31 <mon_help+0xf>
    }
    return 0;
c0100d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7b:	c9                   	leave  
c0100d7c:	c3                   	ret    

c0100d7d <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d7d:	55                   	push   %ebp
c0100d7e:	89 e5                	mov    %esp,%ebp
c0100d80:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d83:	e8 c7 fb ff ff       	call   c010094f <print_kerninfo>
    return 0;
c0100d88:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d8d:	c9                   	leave  
c0100d8e:	c3                   	ret    

c0100d8f <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d8f:	55                   	push   %ebp
c0100d90:	89 e5                	mov    %esp,%ebp
c0100d92:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d95:	e8 00 fd ff ff       	call   c0100a9a <print_stackframe>
    return 0;
c0100d9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d9f:	c9                   	leave  
c0100da0:	c3                   	ret    

c0100da1 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100da1:	55                   	push   %ebp
c0100da2:	89 e5                	mov    %esp,%ebp
c0100da4:	83 ec 14             	sub    $0x14,%esp
c0100da7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100daa:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100dae:	90                   	nop
c0100daf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100db2:	83 c0 07             	add    $0x7,%eax
c0100db5:	0f b7 c0             	movzwl %ax,%eax
c0100db8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100dbc:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100dc0:	89 c2                	mov    %eax,%edx
c0100dc2:	ec                   	in     (%dx),%al
c0100dc3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dc6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dca:	0f b6 c0             	movzbl %al,%eax
c0100dcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dd3:	25 80 00 00 00       	and    $0x80,%eax
c0100dd8:	85 c0                	test   %eax,%eax
c0100dda:	75 d3                	jne    c0100daf <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100ddc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100de0:	74 11                	je     c0100df3 <ide_wait_ready+0x52>
c0100de2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100de5:	83 e0 21             	and    $0x21,%eax
c0100de8:	85 c0                	test   %eax,%eax
c0100dea:	74 07                	je     c0100df3 <ide_wait_ready+0x52>
        return -1;
c0100dec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100df1:	eb 05                	jmp    c0100df8 <ide_wait_ready+0x57>
    }
    return 0;
c0100df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df8:	c9                   	leave  
c0100df9:	c3                   	ret    

c0100dfa <ide_init>:

void
ide_init(void) {
c0100dfa:	55                   	push   %ebp
c0100dfb:	89 e5                	mov    %esp,%ebp
c0100dfd:	57                   	push   %edi
c0100dfe:	53                   	push   %ebx
c0100dff:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e05:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e0b:	e9 ba 02 00 00       	jmp    c01010ca <ide_init+0x2d0>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e10:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e14:	89 d0                	mov    %edx,%eax
c0100e16:	c1 e0 03             	shl    $0x3,%eax
c0100e19:	29 d0                	sub    %edx,%eax
c0100e1b:	c1 e0 03             	shl    $0x3,%eax
c0100e1e:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100e23:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e26:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e2a:	d1 e8                	shr    %eax
c0100e2c:	0f b7 c0             	movzwl %ax,%eax
c0100e2f:	8b 04 85 f4 9b 10 c0 	mov    -0x3fef640c(,%eax,4),%eax
c0100e36:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e3a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e45:	00 
c0100e46:	89 04 24             	mov    %eax,(%esp)
c0100e49:	e8 53 ff ff ff       	call   c0100da1 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e4e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e52:	c1 e0 04             	shl    $0x4,%eax
c0100e55:	24 10                	and    $0x10,%al
c0100e57:	0c e0                	or     $0xe0,%al
c0100e59:	0f b6 c0             	movzbl %al,%eax
c0100e5c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e60:	83 c2 06             	add    $0x6,%edx
c0100e63:	0f b7 d2             	movzwl %dx,%edx
c0100e66:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100e6a:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e6d:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100e71:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100e75:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e76:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e81:	00 
c0100e82:	89 04 24             	mov    %eax,(%esp)
c0100e85:	e8 17 ff ff ff       	call   c0100da1 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e8a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e8e:	83 c0 07             	add    $0x7,%eax
c0100e91:	0f b7 c0             	movzwl %ax,%eax
c0100e94:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100e98:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100e9c:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100ea0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100ea4:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100ea5:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ea9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100eb0:	00 
c0100eb1:	89 04 24             	mov    %eax,(%esp)
c0100eb4:	e8 e8 fe ff ff       	call   c0100da1 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100eb9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ebd:	83 c0 07             	add    $0x7,%eax
c0100ec0:	0f b7 c0             	movzwl %ax,%eax
c0100ec3:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ec7:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100ecb:	89 c2                	mov    %eax,%edx
c0100ecd:	ec                   	in     (%dx),%al
c0100ece:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0100ed1:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100ed5:	84 c0                	test   %al,%al
c0100ed7:	0f 84 e3 01 00 00    	je     c01010c0 <ide_init+0x2c6>
c0100edd:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ee1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100ee8:	00 
c0100ee9:	89 04 24             	mov    %eax,(%esp)
c0100eec:	e8 b0 fe ff ff       	call   c0100da1 <ide_wait_ready>
c0100ef1:	85 c0                	test   %eax,%eax
c0100ef3:	0f 85 c7 01 00 00    	jne    c01010c0 <ide_init+0x2c6>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ef9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100efd:	89 d0                	mov    %edx,%eax
c0100eff:	c1 e0 03             	shl    $0x3,%eax
c0100f02:	29 d0                	sub    %edx,%eax
c0100f04:	c1 e0 03             	shl    $0x3,%eax
c0100f07:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100f0c:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f0f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f13:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100f16:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f1c:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f1f:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100f26:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100f29:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f2c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f2f:	89 cb                	mov    %ecx,%ebx
c0100f31:	89 df                	mov    %ebx,%edi
c0100f33:	89 c1                	mov    %eax,%ecx
c0100f35:	fc                   	cld    
c0100f36:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f38:	89 c8                	mov    %ecx,%eax
c0100f3a:	89 fb                	mov    %edi,%ebx
c0100f3c:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f3f:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f42:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f4e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f57:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f5a:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f5f:	85 c0                	test   %eax,%eax
c0100f61:	74 0e                	je     c0100f71 <ide_init+0x177>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f66:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f6f:	eb 09                	jmp    c0100f7a <ide_init+0x180>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f74:	8b 40 78             	mov    0x78(%eax),%eax
c0100f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f7a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f7e:	89 d0                	mov    %edx,%eax
c0100f80:	c1 e0 03             	shl    $0x3,%eax
c0100f83:	29 d0                	sub    %edx,%eax
c0100f85:	c1 e0 03             	shl    $0x3,%eax
c0100f88:	8d 90 44 74 12 c0    	lea    -0x3fed8bbc(%eax),%edx
c0100f8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f91:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f93:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f97:	89 d0                	mov    %edx,%eax
c0100f99:	c1 e0 03             	shl    $0x3,%eax
c0100f9c:	29 d0                	sub    %edx,%eax
c0100f9e:	c1 e0 03             	shl    $0x3,%eax
c0100fa1:	8d 90 48 74 12 c0    	lea    -0x3fed8bb8(%eax),%edx
c0100fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100faa:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100faf:	83 c0 62             	add    $0x62,%eax
c0100fb2:	0f b7 00             	movzwl (%eax),%eax
c0100fb5:	25 00 02 00 00       	and    $0x200,%eax
c0100fba:	85 c0                	test   %eax,%eax
c0100fbc:	75 24                	jne    c0100fe2 <ide_init+0x1e8>
c0100fbe:	c7 44 24 0c fc 9b 10 	movl   $0xc0109bfc,0xc(%esp)
c0100fc5:	c0 
c0100fc6:	c7 44 24 08 3f 9c 10 	movl   $0xc0109c3f,0x8(%esp)
c0100fcd:	c0 
c0100fce:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0100fd5:	00 
c0100fd6:	c7 04 24 54 9c 10 c0 	movl   $0xc0109c54,(%esp)
c0100fdd:	e8 1e f4 ff ff       	call   c0100400 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100fe2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100fe6:	89 d0                	mov    %edx,%eax
c0100fe8:	c1 e0 03             	shl    $0x3,%eax
c0100feb:	29 d0                	sub    %edx,%eax
c0100fed:	c1 e0 03             	shl    $0x3,%eax
c0100ff0:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0100ff5:	83 c0 0c             	add    $0xc,%eax
c0100ff8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ffe:	83 c0 36             	add    $0x36,%eax
c0101001:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101004:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c010100b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101012:	eb 34                	jmp    c0101048 <ide_init+0x24e>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101014:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101017:	8d 50 01             	lea    0x1(%eax),%edx
c010101a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010101d:	01 d0                	add    %edx,%eax
c010101f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101022:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101025:	01 ca                	add    %ecx,%edx
c0101027:	0f b6 00             	movzbl (%eax),%eax
c010102a:	88 02                	mov    %al,(%edx)
c010102c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010102f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101032:	01 d0                	add    %edx,%eax
c0101034:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101037:	8d 4a 01             	lea    0x1(%edx),%ecx
c010103a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010103d:	01 ca                	add    %ecx,%edx
c010103f:	0f b6 00             	movzbl (%eax),%eax
c0101042:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0101044:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101048:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010104e:	72 c4                	jb     c0101014 <ide_init+0x21a>
        }
        do {
            model[i] = '\0';
c0101050:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101053:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101056:	01 d0                	add    %edx,%eax
c0101058:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010105b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010105e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101061:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101064:	85 c0                	test   %eax,%eax
c0101066:	74 0f                	je     c0101077 <ide_init+0x27d>
c0101068:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010106b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010106e:	01 d0                	add    %edx,%eax
c0101070:	0f b6 00             	movzbl (%eax),%eax
c0101073:	3c 20                	cmp    $0x20,%al
c0101075:	74 d9                	je     c0101050 <ide_init+0x256>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101077:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010107b:	89 d0                	mov    %edx,%eax
c010107d:	c1 e0 03             	shl    $0x3,%eax
c0101080:	29 d0                	sub    %edx,%eax
c0101082:	c1 e0 03             	shl    $0x3,%eax
c0101085:	05 40 74 12 c0       	add    $0xc0127440,%eax
c010108a:	8d 48 0c             	lea    0xc(%eax),%ecx
c010108d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101091:	89 d0                	mov    %edx,%eax
c0101093:	c1 e0 03             	shl    $0x3,%eax
c0101096:	29 d0                	sub    %edx,%eax
c0101098:	c1 e0 03             	shl    $0x3,%eax
c010109b:	05 48 74 12 c0       	add    $0xc0127448,%eax
c01010a0:	8b 10                	mov    (%eax),%edx
c01010a2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010b2:	c7 04 24 66 9c 10 c0 	movl   $0xc0109c66,(%esp)
c01010b9:	e8 eb f1 ff ff       	call   c01002a9 <cprintf>
c01010be:	eb 01                	jmp    c01010c1 <ide_init+0x2c7>
            continue ;
c01010c0:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010c1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010c5:	40                   	inc    %eax
c01010c6:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010ca:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010ce:	83 f8 03             	cmp    $0x3,%eax
c01010d1:	0f 86 39 fd ff ff    	jbe    c0100e10 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01010d7:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01010de:	e8 91 0e 00 00       	call   c0101f74 <pic_enable>
    pic_enable(IRQ_IDE2);
c01010e3:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c01010ea:	e8 85 0e 00 00       	call   c0101f74 <pic_enable>
}
c01010ef:	90                   	nop
c01010f0:	81 c4 50 02 00 00    	add    $0x250,%esp
c01010f6:	5b                   	pop    %ebx
c01010f7:	5f                   	pop    %edi
c01010f8:	5d                   	pop    %ebp
c01010f9:	c3                   	ret    

c01010fa <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01010fa:	55                   	push   %ebp
c01010fb:	89 e5                	mov    %esp,%ebp
c01010fd:	83 ec 04             	sub    $0x4,%esp
c0101100:	8b 45 08             	mov    0x8(%ebp),%eax
c0101103:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101107:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010110b:	83 f8 03             	cmp    $0x3,%eax
c010110e:	77 21                	ja     c0101131 <ide_device_valid+0x37>
c0101110:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101114:	89 d0                	mov    %edx,%eax
c0101116:	c1 e0 03             	shl    $0x3,%eax
c0101119:	29 d0                	sub    %edx,%eax
c010111b:	c1 e0 03             	shl    $0x3,%eax
c010111e:	05 40 74 12 c0       	add    $0xc0127440,%eax
c0101123:	0f b6 00             	movzbl (%eax),%eax
c0101126:	84 c0                	test   %al,%al
c0101128:	74 07                	je     c0101131 <ide_device_valid+0x37>
c010112a:	b8 01 00 00 00       	mov    $0x1,%eax
c010112f:	eb 05                	jmp    c0101136 <ide_device_valid+0x3c>
c0101131:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101136:	c9                   	leave  
c0101137:	c3                   	ret    

c0101138 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101138:	55                   	push   %ebp
c0101139:	89 e5                	mov    %esp,%ebp
c010113b:	83 ec 08             	sub    $0x8,%esp
c010113e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101141:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101145:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101149:	89 04 24             	mov    %eax,(%esp)
c010114c:	e8 a9 ff ff ff       	call   c01010fa <ide_device_valid>
c0101151:	85 c0                	test   %eax,%eax
c0101153:	74 17                	je     c010116c <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101155:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101159:	89 d0                	mov    %edx,%eax
c010115b:	c1 e0 03             	shl    $0x3,%eax
c010115e:	29 d0                	sub    %edx,%eax
c0101160:	c1 e0 03             	shl    $0x3,%eax
c0101163:	05 48 74 12 c0       	add    $0xc0127448,%eax
c0101168:	8b 00                	mov    (%eax),%eax
c010116a:	eb 05                	jmp    c0101171 <ide_device_size+0x39>
    }
    return 0;
c010116c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101171:	c9                   	leave  
c0101172:	c3                   	ret    

c0101173 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101173:	55                   	push   %ebp
c0101174:	89 e5                	mov    %esp,%ebp
c0101176:	57                   	push   %edi
c0101177:	53                   	push   %ebx
c0101178:	83 ec 50             	sub    $0x50,%esp
c010117b:	8b 45 08             	mov    0x8(%ebp),%eax
c010117e:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101182:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101189:	77 23                	ja     c01011ae <ide_read_secs+0x3b>
c010118b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010118f:	83 f8 03             	cmp    $0x3,%eax
c0101192:	77 1a                	ja     c01011ae <ide_read_secs+0x3b>
c0101194:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101198:	89 d0                	mov    %edx,%eax
c010119a:	c1 e0 03             	shl    $0x3,%eax
c010119d:	29 d0                	sub    %edx,%eax
c010119f:	c1 e0 03             	shl    $0x3,%eax
c01011a2:	05 40 74 12 c0       	add    $0xc0127440,%eax
c01011a7:	0f b6 00             	movzbl (%eax),%eax
c01011aa:	84 c0                	test   %al,%al
c01011ac:	75 24                	jne    c01011d2 <ide_read_secs+0x5f>
c01011ae:	c7 44 24 0c 84 9c 10 	movl   $0xc0109c84,0xc(%esp)
c01011b5:	c0 
c01011b6:	c7 44 24 08 3f 9c 10 	movl   $0xc0109c3f,0x8(%esp)
c01011bd:	c0 
c01011be:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01011c5:	00 
c01011c6:	c7 04 24 54 9c 10 c0 	movl   $0xc0109c54,(%esp)
c01011cd:	e8 2e f2 ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01011d2:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01011d9:	77 0f                	ja     c01011ea <ide_read_secs+0x77>
c01011db:	8b 55 0c             	mov    0xc(%ebp),%edx
c01011de:	8b 45 14             	mov    0x14(%ebp),%eax
c01011e1:	01 d0                	add    %edx,%eax
c01011e3:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01011e8:	76 24                	jbe    c010120e <ide_read_secs+0x9b>
c01011ea:	c7 44 24 0c ac 9c 10 	movl   $0xc0109cac,0xc(%esp)
c01011f1:	c0 
c01011f2:	c7 44 24 08 3f 9c 10 	movl   $0xc0109c3f,0x8(%esp)
c01011f9:	c0 
c01011fa:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101201:	00 
c0101202:	c7 04 24 54 9c 10 c0 	movl   $0xc0109c54,(%esp)
c0101209:	e8 f2 f1 ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010120e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101212:	d1 e8                	shr    %eax
c0101214:	0f b7 c0             	movzwl %ax,%eax
c0101217:	8b 04 85 f4 9b 10 c0 	mov    -0x3fef640c(,%eax,4),%eax
c010121e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101222:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101226:	d1 e8                	shr    %eax
c0101228:	0f b7 c0             	movzwl %ax,%eax
c010122b:	0f b7 04 85 f6 9b 10 	movzwl -0x3fef640a(,%eax,4),%eax
c0101232:	c0 
c0101233:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101237:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010123b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101242:	00 
c0101243:	89 04 24             	mov    %eax,(%esp)
c0101246:	e8 56 fb ff ff       	call   c0100da1 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010124b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010124e:	83 c0 02             	add    $0x2,%eax
c0101251:	0f b7 c0             	movzwl %ax,%eax
c0101254:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101258:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010125c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101260:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101264:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101265:	8b 45 14             	mov    0x14(%ebp),%eax
c0101268:	0f b6 c0             	movzbl %al,%eax
c010126b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010126f:	83 c2 02             	add    $0x2,%edx
c0101272:	0f b7 d2             	movzwl %dx,%edx
c0101275:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101279:	88 45 d9             	mov    %al,-0x27(%ebp)
c010127c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101280:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101284:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101285:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101288:	0f b6 c0             	movzbl %al,%eax
c010128b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010128f:	83 c2 03             	add    $0x3,%edx
c0101292:	0f b7 d2             	movzwl %dx,%edx
c0101295:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101299:	88 45 dd             	mov    %al,-0x23(%ebp)
c010129c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01012a0:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01012a4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012a8:	c1 e8 08             	shr    $0x8,%eax
c01012ab:	0f b6 c0             	movzbl %al,%eax
c01012ae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b2:	83 c2 04             	add    $0x4,%edx
c01012b5:	0f b7 d2             	movzwl %dx,%edx
c01012b8:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01012bc:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01012bf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01012c3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01012c7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012cb:	c1 e8 10             	shr    $0x10,%eax
c01012ce:	0f b6 c0             	movzbl %al,%eax
c01012d1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d5:	83 c2 05             	add    $0x5,%edx
c01012d8:	0f b7 d2             	movzwl %dx,%edx
c01012db:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012df:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012e2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012e6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ea:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01012eb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01012ee:	c0 e0 04             	shl    $0x4,%al
c01012f1:	24 10                	and    $0x10,%al
c01012f3:	88 c2                	mov    %al,%dl
c01012f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012f8:	c1 e8 18             	shr    $0x18,%eax
c01012fb:	24 0f                	and    $0xf,%al
c01012fd:	08 d0                	or     %dl,%al
c01012ff:	0c e0                	or     $0xe0,%al
c0101301:	0f b6 c0             	movzbl %al,%eax
c0101304:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101308:	83 c2 06             	add    $0x6,%edx
c010130b:	0f b7 d2             	movzwl %dx,%edx
c010130e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101312:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101315:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101319:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010131d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c010131e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101322:	83 c0 07             	add    $0x7,%eax
c0101325:	0f b7 c0             	movzwl %ax,%eax
c0101328:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010132c:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
c0101330:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101334:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101338:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101340:	eb 57                	jmp    c0101399 <ide_read_secs+0x226>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101342:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101346:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010134d:	00 
c010134e:	89 04 24             	mov    %eax,(%esp)
c0101351:	e8 4b fa ff ff       	call   c0100da1 <ide_wait_ready>
c0101356:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101359:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010135d:	75 42                	jne    c01013a1 <ide_read_secs+0x22e>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c010135f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101363:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101366:	8b 45 10             	mov    0x10(%ebp),%eax
c0101369:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010136c:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101373:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101376:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101379:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010137c:	89 cb                	mov    %ecx,%ebx
c010137e:	89 df                	mov    %ebx,%edi
c0101380:	89 c1                	mov    %eax,%ecx
c0101382:	fc                   	cld    
c0101383:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101385:	89 c8                	mov    %ecx,%eax
c0101387:	89 fb                	mov    %edi,%ebx
c0101389:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010138c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010138f:	ff 4d 14             	decl   0x14(%ebp)
c0101392:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101399:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010139d:	75 a3                	jne    c0101342 <ide_read_secs+0x1cf>
    }

out:
c010139f:	eb 01                	jmp    c01013a2 <ide_read_secs+0x22f>
            goto out;
c01013a1:	90                   	nop
    return ret;
c01013a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013a5:	83 c4 50             	add    $0x50,%esp
c01013a8:	5b                   	pop    %ebx
c01013a9:	5f                   	pop    %edi
c01013aa:	5d                   	pop    %ebp
c01013ab:	c3                   	ret    

c01013ac <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013ac:	55                   	push   %ebp
c01013ad:	89 e5                	mov    %esp,%ebp
c01013af:	56                   	push   %esi
c01013b0:	53                   	push   %ebx
c01013b1:	83 ec 50             	sub    $0x50,%esp
c01013b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b7:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01013bb:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01013c2:	77 23                	ja     c01013e7 <ide_write_secs+0x3b>
c01013c4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013c8:	83 f8 03             	cmp    $0x3,%eax
c01013cb:	77 1a                	ja     c01013e7 <ide_write_secs+0x3b>
c01013cd:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c01013d1:	89 d0                	mov    %edx,%eax
c01013d3:	c1 e0 03             	shl    $0x3,%eax
c01013d6:	29 d0                	sub    %edx,%eax
c01013d8:	c1 e0 03             	shl    $0x3,%eax
c01013db:	05 40 74 12 c0       	add    $0xc0127440,%eax
c01013e0:	0f b6 00             	movzbl (%eax),%eax
c01013e3:	84 c0                	test   %al,%al
c01013e5:	75 24                	jne    c010140b <ide_write_secs+0x5f>
c01013e7:	c7 44 24 0c 84 9c 10 	movl   $0xc0109c84,0xc(%esp)
c01013ee:	c0 
c01013ef:	c7 44 24 08 3f 9c 10 	movl   $0xc0109c3f,0x8(%esp)
c01013f6:	c0 
c01013f7:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01013fe:	00 
c01013ff:	c7 04 24 54 9c 10 c0 	movl   $0xc0109c54,(%esp)
c0101406:	e8 f5 ef ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010140b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101412:	77 0f                	ja     c0101423 <ide_write_secs+0x77>
c0101414:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101417:	8b 45 14             	mov    0x14(%ebp),%eax
c010141a:	01 d0                	add    %edx,%eax
c010141c:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101421:	76 24                	jbe    c0101447 <ide_write_secs+0x9b>
c0101423:	c7 44 24 0c ac 9c 10 	movl   $0xc0109cac,0xc(%esp)
c010142a:	c0 
c010142b:	c7 44 24 08 3f 9c 10 	movl   $0xc0109c3f,0x8(%esp)
c0101432:	c0 
c0101433:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010143a:	00 
c010143b:	c7 04 24 54 9c 10 c0 	movl   $0xc0109c54,(%esp)
c0101442:	e8 b9 ef ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101447:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010144b:	d1 e8                	shr    %eax
c010144d:	0f b7 c0             	movzwl %ax,%eax
c0101450:	8b 04 85 f4 9b 10 c0 	mov    -0x3fef640c(,%eax,4),%eax
c0101457:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010145b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010145f:	d1 e8                	shr    %eax
c0101461:	0f b7 c0             	movzwl %ax,%eax
c0101464:	0f b7 04 85 f6 9b 10 	movzwl -0x3fef640a(,%eax,4),%eax
c010146b:	c0 
c010146c:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101470:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101474:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010147b:	00 
c010147c:	89 04 24             	mov    %eax,(%esp)
c010147f:	e8 1d f9 ff ff       	call   c0100da1 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101484:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101487:	83 c0 02             	add    $0x2,%eax
c010148a:	0f b7 c0             	movzwl %ax,%eax
c010148d:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101491:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101495:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101499:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010149d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c010149e:	8b 45 14             	mov    0x14(%ebp),%eax
c01014a1:	0f b6 c0             	movzbl %al,%eax
c01014a4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014a8:	83 c2 02             	add    $0x2,%edx
c01014ab:	0f b7 d2             	movzwl %dx,%edx
c01014ae:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01014b2:	88 45 d9             	mov    %al,-0x27(%ebp)
c01014b5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01014b9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01014bd:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01014be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014c1:	0f b6 c0             	movzbl %al,%eax
c01014c4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014c8:	83 c2 03             	add    $0x3,%edx
c01014cb:	0f b7 d2             	movzwl %dx,%edx
c01014ce:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01014d2:	88 45 dd             	mov    %al,-0x23(%ebp)
c01014d5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01014d9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01014dd:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01014de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014e1:	c1 e8 08             	shr    $0x8,%eax
c01014e4:	0f b6 c0             	movzbl %al,%eax
c01014e7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014eb:	83 c2 04             	add    $0x4,%edx
c01014ee:	0f b7 d2             	movzwl %dx,%edx
c01014f1:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01014f5:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01014f8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01014fc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101500:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101501:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101504:	c1 e8 10             	shr    $0x10,%eax
c0101507:	0f b6 c0             	movzbl %al,%eax
c010150a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010150e:	83 c2 05             	add    $0x5,%edx
c0101511:	0f b7 d2             	movzwl %dx,%edx
c0101514:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101518:	88 45 e5             	mov    %al,-0x1b(%ebp)
c010151b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010151f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101523:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101524:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101527:	c0 e0 04             	shl    $0x4,%al
c010152a:	24 10                	and    $0x10,%al
c010152c:	88 c2                	mov    %al,%dl
c010152e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101531:	c1 e8 18             	shr    $0x18,%eax
c0101534:	24 0f                	and    $0xf,%al
c0101536:	08 d0                	or     %dl,%al
c0101538:	0c e0                	or     $0xe0,%al
c010153a:	0f b6 c0             	movzbl %al,%eax
c010153d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101541:	83 c2 06             	add    $0x6,%edx
c0101544:	0f b7 d2             	movzwl %dx,%edx
c0101547:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010154b:	88 45 e9             	mov    %al,-0x17(%ebp)
c010154e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101552:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101556:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101557:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010155b:	83 c0 07             	add    $0x7,%eax
c010155e:	0f b7 c0             	movzwl %ax,%eax
c0101561:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101565:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
c0101569:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010156d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101571:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101572:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101579:	eb 57                	jmp    c01015d2 <ide_write_secs+0x226>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010157b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010157f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101586:	00 
c0101587:	89 04 24             	mov    %eax,(%esp)
c010158a:	e8 12 f8 ff ff       	call   c0100da1 <ide_wait_ready>
c010158f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101592:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101596:	75 42                	jne    c01015da <ide_write_secs+0x22e>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101598:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010159c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010159f:	8b 45 10             	mov    0x10(%ebp),%eax
c01015a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01015a5:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01015ac:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01015af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01015b2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01015b5:	89 cb                	mov    %ecx,%ebx
c01015b7:	89 de                	mov    %ebx,%esi
c01015b9:	89 c1                	mov    %eax,%ecx
c01015bb:	fc                   	cld    
c01015bc:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01015be:	89 c8                	mov    %ecx,%eax
c01015c0:	89 f3                	mov    %esi,%ebx
c01015c2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01015c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015c8:	ff 4d 14             	decl   0x14(%ebp)
c01015cb:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015d2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015d6:	75 a3                	jne    c010157b <ide_write_secs+0x1cf>
    }

out:
c01015d8:	eb 01                	jmp    c01015db <ide_write_secs+0x22f>
            goto out;
c01015da:	90                   	nop
    return ret;
c01015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015de:	83 c4 50             	add    $0x50,%esp
c01015e1:	5b                   	pop    %ebx
c01015e2:	5e                   	pop    %esi
c01015e3:	5d                   	pop    %ebp
c01015e4:	c3                   	ret    

c01015e5 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c01015e5:	55                   	push   %ebp
c01015e6:	89 e5                	mov    %esp,%ebp
c01015e8:	83 ec 28             	sub    $0x28,%esp
c01015eb:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c01015f1:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015f5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01015f9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015fd:	ee                   	out    %al,(%dx)
c01015fe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101604:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101608:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010160c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101610:	ee                   	out    %al,(%dx)
c0101611:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0101617:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c010161b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010161f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101623:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101624:	c7 05 54 a0 12 c0 00 	movl   $0x0,0xc012a054
c010162b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010162e:	c7 04 24 e6 9c 10 c0 	movl   $0xc0109ce6,(%esp)
c0101635:	e8 6f ec ff ff       	call   c01002a9 <cprintf>
    pic_enable(IRQ_TIMER);
c010163a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101641:	e8 2e 09 00 00       	call   c0101f74 <pic_enable>
}
c0101646:	90                   	nop
c0101647:	c9                   	leave  
c0101648:	c3                   	ret    

c0101649 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101649:	55                   	push   %ebp
c010164a:	89 e5                	mov    %esp,%ebp
c010164c:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010164f:	9c                   	pushf  
c0101650:	58                   	pop    %eax
c0101651:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101654:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0101657:	25 00 02 00 00       	and    $0x200,%eax
c010165c:	85 c0                	test   %eax,%eax
c010165e:	74 0c                	je     c010166c <__intr_save+0x23>
        intr_disable();
c0101660:	e8 83 0a 00 00       	call   c01020e8 <intr_disable>
        return 1;
c0101665:	b8 01 00 00 00       	mov    $0x1,%eax
c010166a:	eb 05                	jmp    c0101671 <__intr_save+0x28>
    }
    return 0;
c010166c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101671:	c9                   	leave  
c0101672:	c3                   	ret    

c0101673 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101673:	55                   	push   %ebp
c0101674:	89 e5                	mov    %esp,%ebp
c0101676:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101679:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010167d:	74 05                	je     c0101684 <__intr_restore+0x11>
        intr_enable();
c010167f:	e8 5d 0a 00 00       	call   c01020e1 <intr_enable>
    }
}
c0101684:	90                   	nop
c0101685:	c9                   	leave  
c0101686:	c3                   	ret    

c0101687 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0101687:	55                   	push   %ebp
c0101688:	89 e5                	mov    %esp,%ebp
c010168a:	83 ec 10             	sub    $0x10,%esp
c010168d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101693:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101697:	89 c2                	mov    %eax,%edx
c0101699:	ec                   	in     (%dx),%al
c010169a:	88 45 f1             	mov    %al,-0xf(%ebp)
c010169d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01016a3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01016a7:	89 c2                	mov    %eax,%edx
c01016a9:	ec                   	in     (%dx),%al
c01016aa:	88 45 f5             	mov    %al,-0xb(%ebp)
c01016ad:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016b3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016b7:	89 c2                	mov    %eax,%edx
c01016b9:	ec                   	in     (%dx),%al
c01016ba:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016bd:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c01016c3:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016c7:	89 c2                	mov    %eax,%edx
c01016c9:	ec                   	in     (%dx),%al
c01016ca:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016cd:	90                   	nop
c01016ce:	c9                   	leave  
c01016cf:	c3                   	ret    

c01016d0 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016d0:	55                   	push   %ebp
c01016d1:	89 e5                	mov    %esp,%ebp
c01016d3:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016d6:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01016dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016e0:	0f b7 00             	movzwl (%eax),%eax
c01016e3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c01016e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016ea:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c01016ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016f2:	0f b7 00             	movzwl (%eax),%eax
c01016f5:	0f b7 c0             	movzwl %ax,%eax
c01016f8:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c01016fd:	74 12                	je     c0101711 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c01016ff:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101706:	66 c7 05 26 75 12 c0 	movw   $0x3b4,0xc0127526
c010170d:	b4 03 
c010170f:	eb 13                	jmp    c0101724 <cga_init+0x54>
    } else {
        *cp = was;
c0101711:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101714:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101718:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010171b:	66 c7 05 26 75 12 c0 	movw   $0x3d4,0xc0127526
c0101722:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101724:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c010172b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010172f:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101733:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101737:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010173b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010173c:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101743:	40                   	inc    %eax
c0101744:	0f b7 c0             	movzwl %ax,%eax
c0101747:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010174b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010174f:	89 c2                	mov    %eax,%edx
c0101751:	ec                   	in     (%dx),%al
c0101752:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0101755:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101759:	0f b6 c0             	movzbl %al,%eax
c010175c:	c1 e0 08             	shl    $0x8,%eax
c010175f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101762:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101769:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010176d:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101771:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101775:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101779:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c010177a:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101781:	40                   	inc    %eax
c0101782:	0f b7 c0             	movzwl %ax,%eax
c0101785:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101789:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010178d:	89 c2                	mov    %eax,%edx
c010178f:	ec                   	in     (%dx),%al
c0101790:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0101793:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101797:	0f b6 c0             	movzbl %al,%eax
c010179a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c010179d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017a0:	a3 20 75 12 c0       	mov    %eax,0xc0127520
    crt_pos = pos;
c01017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017a8:	0f b7 c0             	movzwl %ax,%eax
c01017ab:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
}
c01017b1:	90                   	nop
c01017b2:	c9                   	leave  
c01017b3:	c3                   	ret    

c01017b4 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01017b4:	55                   	push   %ebp
c01017b5:	89 e5                	mov    %esp,%ebp
c01017b7:	83 ec 48             	sub    $0x48,%esp
c01017ba:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c01017c0:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017c4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017c8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017cc:	ee                   	out    %al,(%dx)
c01017cd:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c01017d3:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c01017d7:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017db:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017df:	ee                   	out    %al,(%dx)
c01017e0:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c01017e6:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c01017ea:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017ee:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017f2:	ee                   	out    %al,(%dx)
c01017f3:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01017f9:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c01017fd:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101801:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101805:	ee                   	out    %al,(%dx)
c0101806:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c010180c:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0101810:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101814:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101818:	ee                   	out    %al,(%dx)
c0101819:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010181f:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0101823:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101827:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010182b:	ee                   	out    %al,(%dx)
c010182c:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101832:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0101836:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010183a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010183e:	ee                   	out    %al,(%dx)
c010183f:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101845:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101849:	89 c2                	mov    %eax,%edx
c010184b:	ec                   	in     (%dx),%al
c010184c:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010184f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101853:	3c ff                	cmp    $0xff,%al
c0101855:	0f 95 c0             	setne  %al
c0101858:	0f b6 c0             	movzbl %al,%eax
c010185b:	a3 28 75 12 c0       	mov    %eax,0xc0127528
c0101860:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101866:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010186a:	89 c2                	mov    %eax,%edx
c010186c:	ec                   	in     (%dx),%al
c010186d:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101870:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101876:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010187a:	89 c2                	mov    %eax,%edx
c010187c:	ec                   	in     (%dx),%al
c010187d:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101880:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101885:	85 c0                	test   %eax,%eax
c0101887:	74 0c                	je     c0101895 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101889:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101890:	e8 df 06 00 00       	call   c0101f74 <pic_enable>
    }
}
c0101895:	90                   	nop
c0101896:	c9                   	leave  
c0101897:	c3                   	ret    

c0101898 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101898:	55                   	push   %ebp
c0101899:	89 e5                	mov    %esp,%ebp
c010189b:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010189e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018a5:	eb 08                	jmp    c01018af <lpt_putc_sub+0x17>
        delay();
c01018a7:	e8 db fd ff ff       	call   c0101687 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018ac:	ff 45 fc             	incl   -0x4(%ebp)
c01018af:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01018b5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01018b9:	89 c2                	mov    %eax,%edx
c01018bb:	ec                   	in     (%dx),%al
c01018bc:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01018bf:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018c3:	84 c0                	test   %al,%al
c01018c5:	78 09                	js     c01018d0 <lpt_putc_sub+0x38>
c01018c7:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018ce:	7e d7                	jle    c01018a7 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01018d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01018d3:	0f b6 c0             	movzbl %al,%eax
c01018d6:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01018dc:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018df:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018e3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018e7:	ee                   	out    %al,(%dx)
c01018e8:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01018ee:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01018f2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018f6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018fa:	ee                   	out    %al,(%dx)
c01018fb:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101901:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c0101905:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101909:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010190d:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010190e:	90                   	nop
c010190f:	c9                   	leave  
c0101910:	c3                   	ret    

c0101911 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101911:	55                   	push   %ebp
c0101912:	89 e5                	mov    %esp,%ebp
c0101914:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101917:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010191b:	74 0d                	je     c010192a <lpt_putc+0x19>
        lpt_putc_sub(c);
c010191d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101920:	89 04 24             	mov    %eax,(%esp)
c0101923:	e8 70 ff ff ff       	call   c0101898 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101928:	eb 24                	jmp    c010194e <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010192a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101931:	e8 62 ff ff ff       	call   c0101898 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101936:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010193d:	e8 56 ff ff ff       	call   c0101898 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101942:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101949:	e8 4a ff ff ff       	call   c0101898 <lpt_putc_sub>
}
c010194e:	90                   	nop
c010194f:	c9                   	leave  
c0101950:	c3                   	ret    

c0101951 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101951:	55                   	push   %ebp
c0101952:	89 e5                	mov    %esp,%ebp
c0101954:	53                   	push   %ebx
c0101955:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101958:	8b 45 08             	mov    0x8(%ebp),%eax
c010195b:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101960:	85 c0                	test   %eax,%eax
c0101962:	75 07                	jne    c010196b <cga_putc+0x1a>
        c |= 0x0700;
c0101964:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010196b:	8b 45 08             	mov    0x8(%ebp),%eax
c010196e:	0f b6 c0             	movzbl %al,%eax
c0101971:	83 f8 0a             	cmp    $0xa,%eax
c0101974:	74 55                	je     c01019cb <cga_putc+0x7a>
c0101976:	83 f8 0d             	cmp    $0xd,%eax
c0101979:	74 63                	je     c01019de <cga_putc+0x8d>
c010197b:	83 f8 08             	cmp    $0x8,%eax
c010197e:	0f 85 94 00 00 00    	jne    c0101a18 <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101984:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c010198b:	85 c0                	test   %eax,%eax
c010198d:	0f 84 af 00 00 00    	je     c0101a42 <cga_putc+0xf1>
            crt_pos --;
c0101993:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c010199a:	48                   	dec    %eax
c010199b:	0f b7 c0             	movzwl %ax,%eax
c010199e:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a7:	98                   	cwtl   
c01019a8:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01019ad:	98                   	cwtl   
c01019ae:	83 c8 20             	or     $0x20,%eax
c01019b1:	98                   	cwtl   
c01019b2:	8b 15 20 75 12 c0    	mov    0xc0127520,%edx
c01019b8:	0f b7 0d 24 75 12 c0 	movzwl 0xc0127524,%ecx
c01019bf:	01 c9                	add    %ecx,%ecx
c01019c1:	01 ca                	add    %ecx,%edx
c01019c3:	0f b7 c0             	movzwl %ax,%eax
c01019c6:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01019c9:	eb 77                	jmp    c0101a42 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c01019cb:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01019d2:	83 c0 50             	add    $0x50,%eax
c01019d5:	0f b7 c0             	movzwl %ax,%eax
c01019d8:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019de:	0f b7 1d 24 75 12 c0 	movzwl 0xc0127524,%ebx
c01019e5:	0f b7 0d 24 75 12 c0 	movzwl 0xc0127524,%ecx
c01019ec:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01019f1:	89 c8                	mov    %ecx,%eax
c01019f3:	f7 e2                	mul    %edx
c01019f5:	c1 ea 06             	shr    $0x6,%edx
c01019f8:	89 d0                	mov    %edx,%eax
c01019fa:	c1 e0 02             	shl    $0x2,%eax
c01019fd:	01 d0                	add    %edx,%eax
c01019ff:	c1 e0 04             	shl    $0x4,%eax
c0101a02:	29 c1                	sub    %eax,%ecx
c0101a04:	89 c8                	mov    %ecx,%eax
c0101a06:	0f b7 c0             	movzwl %ax,%eax
c0101a09:	29 c3                	sub    %eax,%ebx
c0101a0b:	89 d8                	mov    %ebx,%eax
c0101a0d:	0f b7 c0             	movzwl %ax,%eax
c0101a10:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
        break;
c0101a16:	eb 2b                	jmp    c0101a43 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a18:	8b 0d 20 75 12 c0    	mov    0xc0127520,%ecx
c0101a1e:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101a25:	8d 50 01             	lea    0x1(%eax),%edx
c0101a28:	0f b7 d2             	movzwl %dx,%edx
c0101a2b:	66 89 15 24 75 12 c0 	mov    %dx,0xc0127524
c0101a32:	01 c0                	add    %eax,%eax
c0101a34:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3a:	0f b7 c0             	movzwl %ax,%eax
c0101a3d:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a40:	eb 01                	jmp    c0101a43 <cga_putc+0xf2>
        break;
c0101a42:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a43:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101a4a:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101a4f:	76 5d                	jbe    c0101aae <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a51:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101a56:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a5c:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101a61:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a68:	00 
c0101a69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a6d:	89 04 24             	mov    %eax,(%esp)
c0101a70:	e8 a8 75 00 00       	call   c010901d <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a75:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a7c:	eb 14                	jmp    c0101a92 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101a7e:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101a83:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101a86:	01 d2                	add    %edx,%edx
c0101a88:	01 d0                	add    %edx,%eax
c0101a8a:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a8f:	ff 45 f4             	incl   -0xc(%ebp)
c0101a92:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101a99:	7e e3                	jle    c0101a7e <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101a9b:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101aa2:	83 e8 50             	sub    $0x50,%eax
c0101aa5:	0f b7 c0             	movzwl %ax,%eax
c0101aa8:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101aae:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101ab5:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101ab9:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101abd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101ac1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101ac5:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101ac6:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101acd:	c1 e8 08             	shr    $0x8,%eax
c0101ad0:	0f b7 c0             	movzwl %ax,%eax
c0101ad3:	0f b6 c0             	movzbl %al,%eax
c0101ad6:	0f b7 15 26 75 12 c0 	movzwl 0xc0127526,%edx
c0101add:	42                   	inc    %edx
c0101ade:	0f b7 d2             	movzwl %dx,%edx
c0101ae1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ae5:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101ae8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101aec:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101af0:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101af1:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101af8:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101afc:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c0101b00:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101b04:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b08:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b09:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101b10:	0f b6 c0             	movzbl %al,%eax
c0101b13:	0f b7 15 26 75 12 c0 	movzwl 0xc0127526,%edx
c0101b1a:	42                   	inc    %edx
c0101b1b:	0f b7 d2             	movzwl %dx,%edx
c0101b1e:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101b22:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101b25:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101b29:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b2d:	ee                   	out    %al,(%dx)
}
c0101b2e:	90                   	nop
c0101b2f:	83 c4 34             	add    $0x34,%esp
c0101b32:	5b                   	pop    %ebx
c0101b33:	5d                   	pop    %ebp
c0101b34:	c3                   	ret    

c0101b35 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b35:	55                   	push   %ebp
c0101b36:	89 e5                	mov    %esp,%ebp
c0101b38:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b3b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b42:	eb 08                	jmp    c0101b4c <serial_putc_sub+0x17>
        delay();
c0101b44:	e8 3e fb ff ff       	call   c0101687 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b49:	ff 45 fc             	incl   -0x4(%ebp)
c0101b4c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b52:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b56:	89 c2                	mov    %eax,%edx
c0101b58:	ec                   	in     (%dx),%al
c0101b59:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101b5c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101b60:	0f b6 c0             	movzbl %al,%eax
c0101b63:	83 e0 20             	and    $0x20,%eax
c0101b66:	85 c0                	test   %eax,%eax
c0101b68:	75 09                	jne    c0101b73 <serial_putc_sub+0x3e>
c0101b6a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b71:	7e d1                	jle    c0101b44 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b76:	0f b6 c0             	movzbl %al,%eax
c0101b79:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101b7f:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b82:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101b86:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b8a:	ee                   	out    %al,(%dx)
}
c0101b8b:	90                   	nop
c0101b8c:	c9                   	leave  
c0101b8d:	c3                   	ret    

c0101b8e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101b8e:	55                   	push   %ebp
c0101b8f:	89 e5                	mov    %esp,%ebp
c0101b91:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101b94:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101b98:	74 0d                	je     c0101ba7 <serial_putc+0x19>
        serial_putc_sub(c);
c0101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9d:	89 04 24             	mov    %eax,(%esp)
c0101ba0:	e8 90 ff ff ff       	call   c0101b35 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101ba5:	eb 24                	jmp    c0101bcb <serial_putc+0x3d>
        serial_putc_sub('\b');
c0101ba7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bae:	e8 82 ff ff ff       	call   c0101b35 <serial_putc_sub>
        serial_putc_sub(' ');
c0101bb3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bba:	e8 76 ff ff ff       	call   c0101b35 <serial_putc_sub>
        serial_putc_sub('\b');
c0101bbf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bc6:	e8 6a ff ff ff       	call   c0101b35 <serial_putc_sub>
}
c0101bcb:	90                   	nop
c0101bcc:	c9                   	leave  
c0101bcd:	c3                   	ret    

c0101bce <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101bce:	55                   	push   %ebp
c0101bcf:	89 e5                	mov    %esp,%ebp
c0101bd1:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101bd4:	eb 33                	jmp    c0101c09 <cons_intr+0x3b>
        if (c != 0) {
c0101bd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101bda:	74 2d                	je     c0101c09 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101bdc:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101be1:	8d 50 01             	lea    0x1(%eax),%edx
c0101be4:	89 15 44 77 12 c0    	mov    %edx,0xc0127744
c0101bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bed:	88 90 40 75 12 c0    	mov    %dl,-0x3fed8ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101bf3:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101bf8:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101bfd:	75 0a                	jne    c0101c09 <cons_intr+0x3b>
                cons.wpos = 0;
c0101bff:	c7 05 44 77 12 c0 00 	movl   $0x0,0xc0127744
c0101c06:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0c:	ff d0                	call   *%eax
c0101c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c11:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c15:	75 bf                	jne    c0101bd6 <cons_intr+0x8>
            }
        }
    }
}
c0101c17:	90                   	nop
c0101c18:	c9                   	leave  
c0101c19:	c3                   	ret    

c0101c1a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c1a:	55                   	push   %ebp
c0101c1b:	89 e5                	mov    %esp,%ebp
c0101c1d:	83 ec 10             	sub    $0x10,%esp
c0101c20:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c26:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c2a:	89 c2                	mov    %eax,%edx
c0101c2c:	ec                   	in     (%dx),%al
c0101c2d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c30:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c34:	0f b6 c0             	movzbl %al,%eax
c0101c37:	83 e0 01             	and    $0x1,%eax
c0101c3a:	85 c0                	test   %eax,%eax
c0101c3c:	75 07                	jne    c0101c45 <serial_proc_data+0x2b>
        return -1;
c0101c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c43:	eb 2a                	jmp    c0101c6f <serial_proc_data+0x55>
c0101c45:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c4b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101c4f:	89 c2                	mov    %eax,%edx
c0101c51:	ec                   	in     (%dx),%al
c0101c52:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101c55:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c59:	0f b6 c0             	movzbl %al,%eax
c0101c5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c5f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c63:	75 07                	jne    c0101c6c <serial_proc_data+0x52>
        c = '\b';
c0101c65:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c6f:	c9                   	leave  
c0101c70:	c3                   	ret    

c0101c71 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c71:	55                   	push   %ebp
c0101c72:	89 e5                	mov    %esp,%ebp
c0101c74:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101c77:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101c7c:	85 c0                	test   %eax,%eax
c0101c7e:	74 0c                	je     c0101c8c <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101c80:	c7 04 24 1a 1c 10 c0 	movl   $0xc0101c1a,(%esp)
c0101c87:	e8 42 ff ff ff       	call   c0101bce <cons_intr>
    }
}
c0101c8c:	90                   	nop
c0101c8d:	c9                   	leave  
c0101c8e:	c3                   	ret    

c0101c8f <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101c8f:	55                   	push   %ebp
c0101c90:	89 e5                	mov    %esp,%ebp
c0101c92:	83 ec 38             	sub    $0x38,%esp
c0101c95:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c9e:	89 c2                	mov    %eax,%edx
c0101ca0:	ec                   	in     (%dx),%al
c0101ca1:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101ca4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101ca8:	0f b6 c0             	movzbl %al,%eax
c0101cab:	83 e0 01             	and    $0x1,%eax
c0101cae:	85 c0                	test   %eax,%eax
c0101cb0:	75 0a                	jne    c0101cbc <kbd_proc_data+0x2d>
        return -1;
c0101cb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cb7:	e9 55 01 00 00       	jmp    c0101e11 <kbd_proc_data+0x182>
c0101cbc:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101cc5:	89 c2                	mov    %eax,%edx
c0101cc7:	ec                   	in     (%dx),%al
c0101cc8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101ccb:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101ccf:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101cd2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101cd6:	75 17                	jne    c0101cef <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101cd8:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101cdd:	83 c8 40             	or     $0x40,%eax
c0101ce0:	a3 48 77 12 c0       	mov    %eax,0xc0127748
        return 0;
c0101ce5:	b8 00 00 00 00       	mov    $0x0,%eax
c0101cea:	e9 22 01 00 00       	jmp    c0101e11 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c0101cef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cf3:	84 c0                	test   %al,%al
c0101cf5:	79 45                	jns    c0101d3c <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101cf7:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101cfc:	83 e0 40             	and    $0x40,%eax
c0101cff:	85 c0                	test   %eax,%eax
c0101d01:	75 08                	jne    c0101d0b <kbd_proc_data+0x7c>
c0101d03:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d07:	24 7f                	and    $0x7f,%al
c0101d09:	eb 04                	jmp    c0101d0f <kbd_proc_data+0x80>
c0101d0b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d0f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d12:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d16:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c0101d1d:	0c 40                	or     $0x40,%al
c0101d1f:	0f b6 c0             	movzbl %al,%eax
c0101d22:	f7 d0                	not    %eax
c0101d24:	89 c2                	mov    %eax,%edx
c0101d26:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d2b:	21 d0                	and    %edx,%eax
c0101d2d:	a3 48 77 12 c0       	mov    %eax,0xc0127748
        return 0;
c0101d32:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d37:	e9 d5 00 00 00       	jmp    c0101e11 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c0101d3c:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d41:	83 e0 40             	and    $0x40,%eax
c0101d44:	85 c0                	test   %eax,%eax
c0101d46:	74 11                	je     c0101d59 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d48:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d4c:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d51:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d54:	a3 48 77 12 c0       	mov    %eax,0xc0127748
    }

    shift |= shiftcode[data];
c0101d59:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d5d:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c0101d64:	0f b6 d0             	movzbl %al,%edx
c0101d67:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d6c:	09 d0                	or     %edx,%eax
c0101d6e:	a3 48 77 12 c0       	mov    %eax,0xc0127748
    shift ^= togglecode[data];
c0101d73:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d77:	0f b6 80 40 41 12 c0 	movzbl -0x3fedbec0(%eax),%eax
c0101d7e:	0f b6 d0             	movzbl %al,%edx
c0101d81:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d86:	31 d0                	xor    %edx,%eax
c0101d88:	a3 48 77 12 c0       	mov    %eax,0xc0127748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101d8d:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d92:	83 e0 03             	and    $0x3,%eax
c0101d95:	8b 14 85 40 45 12 c0 	mov    -0x3fedbac0(,%eax,4),%edx
c0101d9c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101da0:	01 d0                	add    %edx,%eax
c0101da2:	0f b6 00             	movzbl (%eax),%eax
c0101da5:	0f b6 c0             	movzbl %al,%eax
c0101da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101dab:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101db0:	83 e0 08             	and    $0x8,%eax
c0101db3:	85 c0                	test   %eax,%eax
c0101db5:	74 22                	je     c0101dd9 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101db7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101dbb:	7e 0c                	jle    c0101dc9 <kbd_proc_data+0x13a>
c0101dbd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101dc1:	7f 06                	jg     c0101dc9 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101dc3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101dc7:	eb 10                	jmp    c0101dd9 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101dc9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101dcd:	7e 0a                	jle    c0101dd9 <kbd_proc_data+0x14a>
c0101dcf:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101dd3:	7f 04                	jg     c0101dd9 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101dd5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101dd9:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101dde:	f7 d0                	not    %eax
c0101de0:	83 e0 06             	and    $0x6,%eax
c0101de3:	85 c0                	test   %eax,%eax
c0101de5:	75 27                	jne    c0101e0e <kbd_proc_data+0x17f>
c0101de7:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101dee:	75 1e                	jne    c0101e0e <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c0101df0:	c7 04 24 01 9d 10 c0 	movl   $0xc0109d01,(%esp)
c0101df7:	e8 ad e4 ff ff       	call   c01002a9 <cprintf>
c0101dfc:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101e02:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e06:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101e0a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101e0d:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e11:	c9                   	leave  
c0101e12:	c3                   	ret    

c0101e13 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e13:	55                   	push   %ebp
c0101e14:	89 e5                	mov    %esp,%ebp
c0101e16:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e19:	c7 04 24 8f 1c 10 c0 	movl   $0xc0101c8f,(%esp)
c0101e20:	e8 a9 fd ff ff       	call   c0101bce <cons_intr>
}
c0101e25:	90                   	nop
c0101e26:	c9                   	leave  
c0101e27:	c3                   	ret    

c0101e28 <kbd_init>:

static void
kbd_init(void) {
c0101e28:	55                   	push   %ebp
c0101e29:	89 e5                	mov    %esp,%ebp
c0101e2b:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e2e:	e8 e0 ff ff ff       	call   c0101e13 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e3a:	e8 35 01 00 00       	call   c0101f74 <pic_enable>
}
c0101e3f:	90                   	nop
c0101e40:	c9                   	leave  
c0101e41:	c3                   	ret    

c0101e42 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e42:	55                   	push   %ebp
c0101e43:	89 e5                	mov    %esp,%ebp
c0101e45:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e48:	e8 83 f8 ff ff       	call   c01016d0 <cga_init>
    serial_init();
c0101e4d:	e8 62 f9 ff ff       	call   c01017b4 <serial_init>
    kbd_init();
c0101e52:	e8 d1 ff ff ff       	call   c0101e28 <kbd_init>
    if (!serial_exists) {
c0101e57:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101e5c:	85 c0                	test   %eax,%eax
c0101e5e:	75 0c                	jne    c0101e6c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e60:	c7 04 24 0d 9d 10 c0 	movl   $0xc0109d0d,(%esp)
c0101e67:	e8 3d e4 ff ff       	call   c01002a9 <cprintf>
    }
}
c0101e6c:	90                   	nop
c0101e6d:	c9                   	leave  
c0101e6e:	c3                   	ret    

c0101e6f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101e6f:	55                   	push   %ebp
c0101e70:	89 e5                	mov    %esp,%ebp
c0101e72:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e75:	e8 cf f7 ff ff       	call   c0101649 <__intr_save>
c0101e7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e80:	89 04 24             	mov    %eax,(%esp)
c0101e83:	e8 89 fa ff ff       	call   c0101911 <lpt_putc>
        cga_putc(c);
c0101e88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8b:	89 04 24             	mov    %eax,(%esp)
c0101e8e:	e8 be fa ff ff       	call   c0101951 <cga_putc>
        serial_putc(c);
c0101e93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e96:	89 04 24             	mov    %eax,(%esp)
c0101e99:	e8 f0 fc ff ff       	call   c0101b8e <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ea1:	89 04 24             	mov    %eax,(%esp)
c0101ea4:	e8 ca f7 ff ff       	call   c0101673 <__intr_restore>
}
c0101ea9:	90                   	nop
c0101eaa:	c9                   	leave  
c0101eab:	c3                   	ret    

c0101eac <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101eac:	55                   	push   %ebp
c0101ead:	89 e5                	mov    %esp,%ebp
c0101eaf:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101eb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101eb9:	e8 8b f7 ff ff       	call   c0101649 <__intr_save>
c0101ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ec1:	e8 ab fd ff ff       	call   c0101c71 <serial_intr>
        kbd_intr();
c0101ec6:	e8 48 ff ff ff       	call   c0101e13 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101ecb:	8b 15 40 77 12 c0    	mov    0xc0127740,%edx
c0101ed1:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101ed6:	39 c2                	cmp    %eax,%edx
c0101ed8:	74 31                	je     c0101f0b <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101eda:	a1 40 77 12 c0       	mov    0xc0127740,%eax
c0101edf:	8d 50 01             	lea    0x1(%eax),%edx
c0101ee2:	89 15 40 77 12 c0    	mov    %edx,0xc0127740
c0101ee8:	0f b6 80 40 75 12 c0 	movzbl -0x3fed8ac0(%eax),%eax
c0101eef:	0f b6 c0             	movzbl %al,%eax
c0101ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101ef5:	a1 40 77 12 c0       	mov    0xc0127740,%eax
c0101efa:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101eff:	75 0a                	jne    c0101f0b <cons_getc+0x5f>
                cons.rpos = 0;
c0101f01:	c7 05 40 77 12 c0 00 	movl   $0x0,0xc0127740
c0101f08:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f0e:	89 04 24             	mov    %eax,(%esp)
c0101f11:	e8 5d f7 ff ff       	call   c0101673 <__intr_restore>
    return c;
c0101f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f19:	c9                   	leave  
c0101f1a:	c3                   	ret    

c0101f1b <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f1b:	55                   	push   %ebp
c0101f1c:	89 e5                	mov    %esp,%ebp
c0101f1e:	83 ec 14             	sub    $0x14,%esp
c0101f21:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f24:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f2b:	66 a3 50 45 12 c0    	mov    %ax,0xc0124550
    if (did_init) {
c0101f31:	a1 4c 77 12 c0       	mov    0xc012774c,%eax
c0101f36:	85 c0                	test   %eax,%eax
c0101f38:	74 37                	je     c0101f71 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f3d:	0f b6 c0             	movzbl %al,%eax
c0101f40:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101f46:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101f49:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101f4d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101f51:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f52:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f56:	c1 e8 08             	shr    $0x8,%eax
c0101f59:	0f b7 c0             	movzwl %ax,%eax
c0101f5c:	0f b6 c0             	movzbl %al,%eax
c0101f5f:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101f65:	88 45 fd             	mov    %al,-0x3(%ebp)
c0101f68:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f6c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f70:	ee                   	out    %al,(%dx)
    }
}
c0101f71:	90                   	nop
c0101f72:	c9                   	leave  
c0101f73:	c3                   	ret    

c0101f74 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101f74:	55                   	push   %ebp
c0101f75:	89 e5                	mov    %esp,%ebp
c0101f77:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101f7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f7d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101f82:	88 c1                	mov    %al,%cl
c0101f84:	d3 e2                	shl    %cl,%edx
c0101f86:	89 d0                	mov    %edx,%eax
c0101f88:	98                   	cwtl   
c0101f89:	f7 d0                	not    %eax
c0101f8b:	0f bf d0             	movswl %ax,%edx
c0101f8e:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0101f95:	98                   	cwtl   
c0101f96:	21 d0                	and    %edx,%eax
c0101f98:	98                   	cwtl   
c0101f99:	0f b7 c0             	movzwl %ax,%eax
c0101f9c:	89 04 24             	mov    %eax,(%esp)
c0101f9f:	e8 77 ff ff ff       	call   c0101f1b <pic_setmask>
}
c0101fa4:	90                   	nop
c0101fa5:	c9                   	leave  
c0101fa6:	c3                   	ret    

c0101fa7 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fa7:	55                   	push   %ebp
c0101fa8:	89 e5                	mov    %esp,%ebp
c0101faa:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fad:	c7 05 4c 77 12 c0 01 	movl   $0x1,0xc012774c
c0101fb4:	00 00 00 
c0101fb7:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101fbd:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101fc1:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101fc5:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101fc9:	ee                   	out    %al,(%dx)
c0101fca:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101fd0:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c0101fd4:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101fd8:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101fdc:	ee                   	out    %al,(%dx)
c0101fdd:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101fe3:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c0101fe7:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101feb:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101fef:	ee                   	out    %al,(%dx)
c0101ff0:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101ff6:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101ffa:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101ffe:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102002:	ee                   	out    %al,(%dx)
c0102003:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0102009:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c010200d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102011:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102015:	ee                   	out    %al,(%dx)
c0102016:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010201c:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c0102020:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102024:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102028:	ee                   	out    %al,(%dx)
c0102029:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c010202f:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c0102033:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102037:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010203b:	ee                   	out    %al,(%dx)
c010203c:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102042:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c0102046:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010204a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010204e:	ee                   	out    %al,(%dx)
c010204f:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0102055:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c0102059:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010205d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102061:	ee                   	out    %al,(%dx)
c0102062:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102068:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c010206c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102070:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102074:	ee                   	out    %al,(%dx)
c0102075:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010207b:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c010207f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102083:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102087:	ee                   	out    %al,(%dx)
c0102088:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010208e:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0102092:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102096:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010209a:	ee                   	out    %al,(%dx)
c010209b:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01020a1:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c01020a5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020a9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020ad:	ee                   	out    %al,(%dx)
c01020ae:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01020b4:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c01020b8:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020bc:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020c0:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020c1:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c01020c8:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01020cd:	74 0f                	je     c01020de <pic_init+0x137>
        pic_setmask(irq_mask);
c01020cf:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c01020d6:	89 04 24             	mov    %eax,(%esp)
c01020d9:	e8 3d fe ff ff       	call   c0101f1b <pic_setmask>
    }
}
c01020de:	90                   	nop
c01020df:	c9                   	leave  
c01020e0:	c3                   	ret    

c01020e1 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01020e1:	55                   	push   %ebp
c01020e2:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01020e4:	fb                   	sti    
    sti();
}
c01020e5:	90                   	nop
c01020e6:	5d                   	pop    %ebp
c01020e7:	c3                   	ret    

c01020e8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020e8:	55                   	push   %ebp
c01020e9:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01020eb:	fa                   	cli    
    cli();
}
c01020ec:	90                   	nop
c01020ed:	5d                   	pop    %ebp
c01020ee:	c3                   	ret    

c01020ef <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01020ef:	55                   	push   %ebp
c01020f0:	89 e5                	mov    %esp,%ebp
c01020f2:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01020f5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01020fc:	00 
c01020fd:	c7 04 24 40 9d 10 c0 	movl   $0xc0109d40,(%esp)
c0102104:	e8 a0 e1 ff ff       	call   c01002a9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102109:	90                   	nop
c010210a:	c9                   	leave  
c010210b:	c3                   	ret    

c010210c <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010210c:	55                   	push   %ebp
c010210d:	89 e5                	mov    %esp,%ebp
c010210f:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      for(int i = 0; i < (sizeof(idt)/sizeof(struct gatedesc)); i++) {
c0102112:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102119:	e9 4f 01 00 00       	jmp    c010226d <idt_init+0x161>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010211e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102121:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c0102128:	0f b7 d0             	movzwl %ax,%edx
c010212b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010212e:	66 89 14 c5 60 77 12 	mov    %dx,-0x3fed88a0(,%eax,8)
c0102135:	c0 
c0102136:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102139:	66 c7 04 c5 62 77 12 	movw   $0x8,-0x3fed889e(,%eax,8)
c0102140:	c0 08 00 
c0102143:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102146:	0f b6 14 c5 64 77 12 	movzbl -0x3fed889c(,%eax,8),%edx
c010214d:	c0 
c010214e:	80 e2 e0             	and    $0xe0,%dl
c0102151:	88 14 c5 64 77 12 c0 	mov    %dl,-0x3fed889c(,%eax,8)
c0102158:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010215b:	0f b6 14 c5 64 77 12 	movzbl -0x3fed889c(,%eax,8),%edx
c0102162:	c0 
c0102163:	80 e2 1f             	and    $0x1f,%dl
c0102166:	88 14 c5 64 77 12 c0 	mov    %dl,-0x3fed889c(,%eax,8)
c010216d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102170:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c0102177:	c0 
c0102178:	80 e2 f0             	and    $0xf0,%dl
c010217b:	80 ca 0e             	or     $0xe,%dl
c010217e:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c0102185:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102188:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c010218f:	c0 
c0102190:	80 e2 ef             	and    $0xef,%dl
c0102193:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c010219a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010219d:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01021a4:	c0 
c01021a5:	80 e2 9f             	and    $0x9f,%dl
c01021a8:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01021af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b2:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01021b9:	c0 
c01021ba:	80 ca 80             	or     $0x80,%dl
c01021bd:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01021c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c7:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c01021ce:	c1 e8 10             	shr    $0x10,%eax
c01021d1:	0f b7 d0             	movzwl %ax,%edx
c01021d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021d7:	66 89 14 c5 66 77 12 	mov    %dx,-0x3fed889a(,%eax,8)
c01021de:	c0 
        SETGATE(idt[T_SYSCALL], 0, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c01021df:	a1 e0 47 12 c0       	mov    0xc01247e0,%eax
c01021e4:	0f b7 c0             	movzwl %ax,%eax
c01021e7:	66 a3 60 7b 12 c0    	mov    %ax,0xc0127b60
c01021ed:	66 c7 05 62 7b 12 c0 	movw   $0x8,0xc0127b62
c01021f4:	08 00 
c01021f6:	0f b6 05 64 7b 12 c0 	movzbl 0xc0127b64,%eax
c01021fd:	24 e0                	and    $0xe0,%al
c01021ff:	a2 64 7b 12 c0       	mov    %al,0xc0127b64
c0102204:	0f b6 05 64 7b 12 c0 	movzbl 0xc0127b64,%eax
c010220b:	24 1f                	and    $0x1f,%al
c010220d:	a2 64 7b 12 c0       	mov    %al,0xc0127b64
c0102212:	0f b6 05 65 7b 12 c0 	movzbl 0xc0127b65,%eax
c0102219:	24 f0                	and    $0xf0,%al
c010221b:	0c 0e                	or     $0xe,%al
c010221d:	a2 65 7b 12 c0       	mov    %al,0xc0127b65
c0102222:	0f b6 05 65 7b 12 c0 	movzbl 0xc0127b65,%eax
c0102229:	24 ef                	and    $0xef,%al
c010222b:	a2 65 7b 12 c0       	mov    %al,0xc0127b65
c0102230:	0f b6 05 65 7b 12 c0 	movzbl 0xc0127b65,%eax
c0102237:	0c 60                	or     $0x60,%al
c0102239:	a2 65 7b 12 c0       	mov    %al,0xc0127b65
c010223e:	0f b6 05 65 7b 12 c0 	movzbl 0xc0127b65,%eax
c0102245:	0c 80                	or     $0x80,%al
c0102247:	a2 65 7b 12 c0       	mov    %al,0xc0127b65
c010224c:	a1 e0 47 12 c0       	mov    0xc01247e0,%eax
c0102251:	c1 e8 10             	shr    $0x10,%eax
c0102254:	0f b7 c0             	movzwl %ax,%eax
c0102257:	66 a3 66 7b 12 c0    	mov    %ax,0xc0127b66
c010225d:	c7 45 f8 60 45 12 c0 	movl   $0xc0124560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102264:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102267:	0f 01 18             	lidtl  (%eax)
      for(int i = 0; i < (sizeof(idt)/sizeof(struct gatedesc)); i++) {
c010226a:	ff 45 fc             	incl   -0x4(%ebp)
c010226d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102270:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102275:	0f 86 a3 fe ff ff    	jbe    c010211e <idt_init+0x12>
        lidt(&idt_pd);
      }
}
c010227b:	90                   	nop
c010227c:	c9                   	leave  
c010227d:	c3                   	ret    

c010227e <trapname>:

static const char *
trapname(int trapno) {
c010227e:	55                   	push   %ebp
c010227f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102281:	8b 45 08             	mov    0x8(%ebp),%eax
c0102284:	83 f8 13             	cmp    $0x13,%eax
c0102287:	77 0c                	ja     c0102295 <trapname+0x17>
        return excnames[trapno];
c0102289:	8b 45 08             	mov    0x8(%ebp),%eax
c010228c:	8b 04 85 a0 a0 10 c0 	mov    -0x3fef5f60(,%eax,4),%eax
c0102293:	eb 18                	jmp    c01022ad <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0102295:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102299:	7e 0d                	jle    c01022a8 <trapname+0x2a>
c010229b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010229f:	7f 07                	jg     c01022a8 <trapname+0x2a>
        return "Hardware Interrupt";
c01022a1:	b8 4a 9d 10 c0       	mov    $0xc0109d4a,%eax
c01022a6:	eb 05                	jmp    c01022ad <trapname+0x2f>
    }
    return "(unknown trap)";
c01022a8:	b8 5d 9d 10 c0       	mov    $0xc0109d5d,%eax
}
c01022ad:	5d                   	pop    %ebp
c01022ae:	c3                   	ret    

c01022af <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01022af:	55                   	push   %ebp
c01022b0:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01022b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01022b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022b9:	83 f8 08             	cmp    $0x8,%eax
c01022bc:	0f 94 c0             	sete   %al
c01022bf:	0f b6 c0             	movzbl %al,%eax
}
c01022c2:	5d                   	pop    %ebp
c01022c3:	c3                   	ret    

c01022c4 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01022c4:	55                   	push   %ebp
c01022c5:	89 e5                	mov    %esp,%ebp
c01022c7:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01022ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022d1:	c7 04 24 9e 9d 10 c0 	movl   $0xc0109d9e,(%esp)
c01022d8:	e8 cc df ff ff       	call   c01002a9 <cprintf>
    print_regs(&tf->tf_regs);
c01022dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e0:	89 04 24             	mov    %eax,(%esp)
c01022e3:	e8 8f 01 00 00       	call   c0102477 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01022e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022eb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01022ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022f3:	c7 04 24 af 9d 10 c0 	movl   $0xc0109daf,(%esp)
c01022fa:	e8 aa df ff ff       	call   c01002a9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01022ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102302:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102306:	89 44 24 04          	mov    %eax,0x4(%esp)
c010230a:	c7 04 24 c2 9d 10 c0 	movl   $0xc0109dc2,(%esp)
c0102311:	e8 93 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102316:	8b 45 08             	mov    0x8(%ebp),%eax
c0102319:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010231d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102321:	c7 04 24 d5 9d 10 c0 	movl   $0xc0109dd5,(%esp)
c0102328:	e8 7c df ff ff       	call   c01002a9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010232d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102330:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102334:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102338:	c7 04 24 e8 9d 10 c0 	movl   $0xc0109de8,(%esp)
c010233f:	e8 65 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102344:	8b 45 08             	mov    0x8(%ebp),%eax
c0102347:	8b 40 30             	mov    0x30(%eax),%eax
c010234a:	89 04 24             	mov    %eax,(%esp)
c010234d:	e8 2c ff ff ff       	call   c010227e <trapname>
c0102352:	89 c2                	mov    %eax,%edx
c0102354:	8b 45 08             	mov    0x8(%ebp),%eax
c0102357:	8b 40 30             	mov    0x30(%eax),%eax
c010235a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010235e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102362:	c7 04 24 fb 9d 10 c0 	movl   $0xc0109dfb,(%esp)
c0102369:	e8 3b df ff ff       	call   c01002a9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010236e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102371:	8b 40 34             	mov    0x34(%eax),%eax
c0102374:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102378:	c7 04 24 0d 9e 10 c0 	movl   $0xc0109e0d,(%esp)
c010237f:	e8 25 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102384:	8b 45 08             	mov    0x8(%ebp),%eax
c0102387:	8b 40 38             	mov    0x38(%eax),%eax
c010238a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010238e:	c7 04 24 1c 9e 10 c0 	movl   $0xc0109e1c,(%esp)
c0102395:	e8 0f df ff ff       	call   c01002a9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010239a:	8b 45 08             	mov    0x8(%ebp),%eax
c010239d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023a5:	c7 04 24 2b 9e 10 c0 	movl   $0xc0109e2b,(%esp)
c01023ac:	e8 f8 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01023b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b4:	8b 40 40             	mov    0x40(%eax),%eax
c01023b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023bb:	c7 04 24 3e 9e 10 c0 	movl   $0xc0109e3e,(%esp)
c01023c2:	e8 e2 de ff ff       	call   c01002a9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01023ce:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01023d5:	eb 3d                	jmp    c0102414 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01023d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023da:	8b 50 40             	mov    0x40(%eax),%edx
c01023dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01023e0:	21 d0                	and    %edx,%eax
c01023e2:	85 c0                	test   %eax,%eax
c01023e4:	74 28                	je     c010240e <print_trapframe+0x14a>
c01023e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023e9:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c01023f0:	85 c0                	test   %eax,%eax
c01023f2:	74 1a                	je     c010240e <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c01023f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023f7:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c01023fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102402:	c7 04 24 4d 9e 10 c0 	movl   $0xc0109e4d,(%esp)
c0102409:	e8 9b de ff ff       	call   c01002a9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010240e:	ff 45 f4             	incl   -0xc(%ebp)
c0102411:	d1 65 f0             	shll   -0x10(%ebp)
c0102414:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102417:	83 f8 17             	cmp    $0x17,%eax
c010241a:	76 bb                	jbe    c01023d7 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010241c:	8b 45 08             	mov    0x8(%ebp),%eax
c010241f:	8b 40 40             	mov    0x40(%eax),%eax
c0102422:	c1 e8 0c             	shr    $0xc,%eax
c0102425:	83 e0 03             	and    $0x3,%eax
c0102428:	89 44 24 04          	mov    %eax,0x4(%esp)
c010242c:	c7 04 24 51 9e 10 c0 	movl   $0xc0109e51,(%esp)
c0102433:	e8 71 de ff ff       	call   c01002a9 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102438:	8b 45 08             	mov    0x8(%ebp),%eax
c010243b:	89 04 24             	mov    %eax,(%esp)
c010243e:	e8 6c fe ff ff       	call   c01022af <trap_in_kernel>
c0102443:	85 c0                	test   %eax,%eax
c0102445:	75 2d                	jne    c0102474 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102447:	8b 45 08             	mov    0x8(%ebp),%eax
c010244a:	8b 40 44             	mov    0x44(%eax),%eax
c010244d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102451:	c7 04 24 5a 9e 10 c0 	movl   $0xc0109e5a,(%esp)
c0102458:	e8 4c de ff ff       	call   c01002a9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010245d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102460:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102464:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102468:	c7 04 24 69 9e 10 c0 	movl   $0xc0109e69,(%esp)
c010246f:	e8 35 de ff ff       	call   c01002a9 <cprintf>
    }
}
c0102474:	90                   	nop
c0102475:	c9                   	leave  
c0102476:	c3                   	ret    

c0102477 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102477:	55                   	push   %ebp
c0102478:	89 e5                	mov    %esp,%ebp
c010247a:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010247d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102480:	8b 00                	mov    (%eax),%eax
c0102482:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102486:	c7 04 24 7c 9e 10 c0 	movl   $0xc0109e7c,(%esp)
c010248d:	e8 17 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102492:	8b 45 08             	mov    0x8(%ebp),%eax
c0102495:	8b 40 04             	mov    0x4(%eax),%eax
c0102498:	89 44 24 04          	mov    %eax,0x4(%esp)
c010249c:	c7 04 24 8b 9e 10 c0 	movl   $0xc0109e8b,(%esp)
c01024a3:	e8 01 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01024a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ab:	8b 40 08             	mov    0x8(%eax),%eax
c01024ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b2:	c7 04 24 9a 9e 10 c0 	movl   $0xc0109e9a,(%esp)
c01024b9:	e8 eb dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01024be:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c1:	8b 40 0c             	mov    0xc(%eax),%eax
c01024c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c8:	c7 04 24 a9 9e 10 c0 	movl   $0xc0109ea9,(%esp)
c01024cf:	e8 d5 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01024d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d7:	8b 40 10             	mov    0x10(%eax),%eax
c01024da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024de:	c7 04 24 b8 9e 10 c0 	movl   $0xc0109eb8,(%esp)
c01024e5:	e8 bf dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01024ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ed:	8b 40 14             	mov    0x14(%eax),%eax
c01024f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f4:	c7 04 24 c7 9e 10 c0 	movl   $0xc0109ec7,(%esp)
c01024fb:	e8 a9 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102500:	8b 45 08             	mov    0x8(%ebp),%eax
c0102503:	8b 40 18             	mov    0x18(%eax),%eax
c0102506:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250a:	c7 04 24 d6 9e 10 c0 	movl   $0xc0109ed6,(%esp)
c0102511:	e8 93 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102516:	8b 45 08             	mov    0x8(%ebp),%eax
c0102519:	8b 40 1c             	mov    0x1c(%eax),%eax
c010251c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102520:	c7 04 24 e5 9e 10 c0 	movl   $0xc0109ee5,(%esp)
c0102527:	e8 7d dd ff ff       	call   c01002a9 <cprintf>
}
c010252c:	90                   	nop
c010252d:	c9                   	leave  
c010252e:	c3                   	ret    

c010252f <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c010252f:	55                   	push   %ebp
c0102530:	89 e5                	mov    %esp,%ebp
c0102532:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0102535:	8b 45 08             	mov    0x8(%ebp),%eax
c0102538:	8b 40 30             	mov    0x30(%eax),%eax
c010253b:	83 f8 2f             	cmp    $0x2f,%eax
c010253e:	77 21                	ja     c0102561 <trap_dispatch+0x32>
c0102540:	83 f8 2e             	cmp    $0x2e,%eax
c0102543:	0f 83 16 01 00 00    	jae    c010265f <trap_dispatch+0x130>
c0102549:	83 f8 21             	cmp    $0x21,%eax
c010254c:	0f 84 96 00 00 00    	je     c01025e8 <trap_dispatch+0xb9>
c0102552:	83 f8 24             	cmp    $0x24,%eax
c0102555:	74 6b                	je     c01025c2 <trap_dispatch+0x93>
c0102557:	83 f8 20             	cmp    $0x20,%eax
c010255a:	74 16                	je     c0102572 <trap_dispatch+0x43>
c010255c:	e9 c9 00 00 00       	jmp    c010262a <trap_dispatch+0xfb>
c0102561:	83 e8 78             	sub    $0x78,%eax
c0102564:	83 f8 01             	cmp    $0x1,%eax
c0102567:	0f 87 bd 00 00 00    	ja     c010262a <trap_dispatch+0xfb>
c010256d:	e9 9c 00 00 00       	jmp    c010260e <trap_dispatch+0xdf>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
         ticks++;
c0102572:	a1 54 a0 12 c0       	mov    0xc012a054,%eax
c0102577:	40                   	inc    %eax
c0102578:	a3 54 a0 12 c0       	mov    %eax,0xc012a054
         if(ticks % TICK_NUM == 0) {
c010257d:	8b 0d 54 a0 12 c0    	mov    0xc012a054,%ecx
c0102583:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102588:	89 c8                	mov    %ecx,%eax
c010258a:	f7 e2                	mul    %edx
c010258c:	c1 ea 05             	shr    $0x5,%edx
c010258f:	89 d0                	mov    %edx,%eax
c0102591:	c1 e0 02             	shl    $0x2,%eax
c0102594:	01 d0                	add    %edx,%eax
c0102596:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010259d:	01 d0                	add    %edx,%eax
c010259f:	c1 e0 02             	shl    $0x2,%eax
c01025a2:	29 c1                	sub    %eax,%ecx
c01025a4:	89 ca                	mov    %ecx,%edx
c01025a6:	85 d2                	test   %edx,%edx
c01025a8:	0f 85 b4 00 00 00    	jne    c0102662 <trap_dispatch+0x133>
             print_ticks();
c01025ae:	e8 3c fb ff ff       	call   c01020ef <print_ticks>
             ticks = 0;
c01025b3:	c7 05 54 a0 12 c0 00 	movl   $0x0,0xc012a054
c01025ba:	00 00 00 
         }
        break;
c01025bd:	e9 a0 00 00 00       	jmp    c0102662 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01025c2:	e8 e5 f8 ff ff       	call   c0101eac <cons_getc>
c01025c7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01025ca:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01025ce:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01025d2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01025d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025da:	c7 04 24 f4 9e 10 c0 	movl   $0xc0109ef4,(%esp)
c01025e1:	e8 c3 dc ff ff       	call   c01002a9 <cprintf>
        break;
c01025e6:	eb 7b                	jmp    c0102663 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01025e8:	e8 bf f8 ff ff       	call   c0101eac <cons_getc>
c01025ed:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01025f0:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01025f4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01025f8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01025fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102600:	c7 04 24 06 9f 10 c0 	movl   $0xc0109f06,(%esp)
c0102607:	e8 9d dc ff ff       	call   c01002a9 <cprintf>
        break;
c010260c:	eb 55                	jmp    c0102663 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c010260e:	c7 44 24 08 15 9f 10 	movl   $0xc0109f15,0x8(%esp)
c0102615:	c0 
c0102616:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c010261d:	00 
c010261e:	c7 04 24 25 9f 10 c0 	movl   $0xc0109f25,(%esp)
c0102625:	e8 d6 dd ff ff       	call   c0100400 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c010262a:	8b 45 08             	mov    0x8(%ebp),%eax
c010262d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102631:	83 e0 03             	and    $0x3,%eax
c0102634:	85 c0                	test   %eax,%eax
c0102636:	75 2b                	jne    c0102663 <trap_dispatch+0x134>
            print_trapframe(tf);
c0102638:	8b 45 08             	mov    0x8(%ebp),%eax
c010263b:	89 04 24             	mov    %eax,(%esp)
c010263e:	e8 81 fc ff ff       	call   c01022c4 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102643:	c7 44 24 08 36 9f 10 	movl   $0xc0109f36,0x8(%esp)
c010264a:	c0 
c010264b:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0102652:	00 
c0102653:	c7 04 24 25 9f 10 c0 	movl   $0xc0109f25,(%esp)
c010265a:	e8 a1 dd ff ff       	call   c0100400 <__panic>
        break;
c010265f:	90                   	nop
c0102660:	eb 01                	jmp    c0102663 <trap_dispatch+0x134>
        break;
c0102662:	90                   	nop
        }
    }
}
c0102663:	90                   	nop
c0102664:	c9                   	leave  
c0102665:	c3                   	ret    

c0102666 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102666:	55                   	push   %ebp
c0102667:	89 e5                	mov    %esp,%ebp
c0102669:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010266c:	8b 45 08             	mov    0x8(%ebp),%eax
c010266f:	89 04 24             	mov    %eax,(%esp)
c0102672:	e8 b8 fe ff ff       	call   c010252f <trap_dispatch>
c0102677:	90                   	nop
c0102678:	c9                   	leave  
c0102679:	c3                   	ret    

c010267a <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010267a:	6a 00                	push   $0x0
  pushl $0
c010267c:	6a 00                	push   $0x0
  jmp __alltraps
c010267e:	e9 69 0a 00 00       	jmp    c01030ec <__alltraps>

c0102683 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102683:	6a 00                	push   $0x0
  pushl $1
c0102685:	6a 01                	push   $0x1
  jmp __alltraps
c0102687:	e9 60 0a 00 00       	jmp    c01030ec <__alltraps>

c010268c <vector2>:
.globl vector2
vector2:
  pushl $0
c010268c:	6a 00                	push   $0x0
  pushl $2
c010268e:	6a 02                	push   $0x2
  jmp __alltraps
c0102690:	e9 57 0a 00 00       	jmp    c01030ec <__alltraps>

c0102695 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $3
c0102697:	6a 03                	push   $0x3
  jmp __alltraps
c0102699:	e9 4e 0a 00 00       	jmp    c01030ec <__alltraps>

c010269e <vector4>:
.globl vector4
vector4:
  pushl $0
c010269e:	6a 00                	push   $0x0
  pushl $4
c01026a0:	6a 04                	push   $0x4
  jmp __alltraps
c01026a2:	e9 45 0a 00 00       	jmp    c01030ec <__alltraps>

c01026a7 <vector5>:
.globl vector5
vector5:
  pushl $0
c01026a7:	6a 00                	push   $0x0
  pushl $5
c01026a9:	6a 05                	push   $0x5
  jmp __alltraps
c01026ab:	e9 3c 0a 00 00       	jmp    c01030ec <__alltraps>

c01026b0 <vector6>:
.globl vector6
vector6:
  pushl $0
c01026b0:	6a 00                	push   $0x0
  pushl $6
c01026b2:	6a 06                	push   $0x6
  jmp __alltraps
c01026b4:	e9 33 0a 00 00       	jmp    c01030ec <__alltraps>

c01026b9 <vector7>:
.globl vector7
vector7:
  pushl $0
c01026b9:	6a 00                	push   $0x0
  pushl $7
c01026bb:	6a 07                	push   $0x7
  jmp __alltraps
c01026bd:	e9 2a 0a 00 00       	jmp    c01030ec <__alltraps>

c01026c2 <vector8>:
.globl vector8
vector8:
  pushl $8
c01026c2:	6a 08                	push   $0x8
  jmp __alltraps
c01026c4:	e9 23 0a 00 00       	jmp    c01030ec <__alltraps>

c01026c9 <vector9>:
.globl vector9
vector9:
  pushl $0
c01026c9:	6a 00                	push   $0x0
  pushl $9
c01026cb:	6a 09                	push   $0x9
  jmp __alltraps
c01026cd:	e9 1a 0a 00 00       	jmp    c01030ec <__alltraps>

c01026d2 <vector10>:
.globl vector10
vector10:
  pushl $10
c01026d2:	6a 0a                	push   $0xa
  jmp __alltraps
c01026d4:	e9 13 0a 00 00       	jmp    c01030ec <__alltraps>

c01026d9 <vector11>:
.globl vector11
vector11:
  pushl $11
c01026d9:	6a 0b                	push   $0xb
  jmp __alltraps
c01026db:	e9 0c 0a 00 00       	jmp    c01030ec <__alltraps>

c01026e0 <vector12>:
.globl vector12
vector12:
  pushl $12
c01026e0:	6a 0c                	push   $0xc
  jmp __alltraps
c01026e2:	e9 05 0a 00 00       	jmp    c01030ec <__alltraps>

c01026e7 <vector13>:
.globl vector13
vector13:
  pushl $13
c01026e7:	6a 0d                	push   $0xd
  jmp __alltraps
c01026e9:	e9 fe 09 00 00       	jmp    c01030ec <__alltraps>

c01026ee <vector14>:
.globl vector14
vector14:
  pushl $14
c01026ee:	6a 0e                	push   $0xe
  jmp __alltraps
c01026f0:	e9 f7 09 00 00       	jmp    c01030ec <__alltraps>

c01026f5 <vector15>:
.globl vector15
vector15:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $15
c01026f7:	6a 0f                	push   $0xf
  jmp __alltraps
c01026f9:	e9 ee 09 00 00       	jmp    c01030ec <__alltraps>

c01026fe <vector16>:
.globl vector16
vector16:
  pushl $0
c01026fe:	6a 00                	push   $0x0
  pushl $16
c0102700:	6a 10                	push   $0x10
  jmp __alltraps
c0102702:	e9 e5 09 00 00       	jmp    c01030ec <__alltraps>

c0102707 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102707:	6a 11                	push   $0x11
  jmp __alltraps
c0102709:	e9 de 09 00 00       	jmp    c01030ec <__alltraps>

c010270e <vector18>:
.globl vector18
vector18:
  pushl $0
c010270e:	6a 00                	push   $0x0
  pushl $18
c0102710:	6a 12                	push   $0x12
  jmp __alltraps
c0102712:	e9 d5 09 00 00       	jmp    c01030ec <__alltraps>

c0102717 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102717:	6a 00                	push   $0x0
  pushl $19
c0102719:	6a 13                	push   $0x13
  jmp __alltraps
c010271b:	e9 cc 09 00 00       	jmp    c01030ec <__alltraps>

c0102720 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102720:	6a 00                	push   $0x0
  pushl $20
c0102722:	6a 14                	push   $0x14
  jmp __alltraps
c0102724:	e9 c3 09 00 00       	jmp    c01030ec <__alltraps>

c0102729 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102729:	6a 00                	push   $0x0
  pushl $21
c010272b:	6a 15                	push   $0x15
  jmp __alltraps
c010272d:	e9 ba 09 00 00       	jmp    c01030ec <__alltraps>

c0102732 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102732:	6a 00                	push   $0x0
  pushl $22
c0102734:	6a 16                	push   $0x16
  jmp __alltraps
c0102736:	e9 b1 09 00 00       	jmp    c01030ec <__alltraps>

c010273b <vector23>:
.globl vector23
vector23:
  pushl $0
c010273b:	6a 00                	push   $0x0
  pushl $23
c010273d:	6a 17                	push   $0x17
  jmp __alltraps
c010273f:	e9 a8 09 00 00       	jmp    c01030ec <__alltraps>

c0102744 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102744:	6a 00                	push   $0x0
  pushl $24
c0102746:	6a 18                	push   $0x18
  jmp __alltraps
c0102748:	e9 9f 09 00 00       	jmp    c01030ec <__alltraps>

c010274d <vector25>:
.globl vector25
vector25:
  pushl $0
c010274d:	6a 00                	push   $0x0
  pushl $25
c010274f:	6a 19                	push   $0x19
  jmp __alltraps
c0102751:	e9 96 09 00 00       	jmp    c01030ec <__alltraps>

c0102756 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102756:	6a 00                	push   $0x0
  pushl $26
c0102758:	6a 1a                	push   $0x1a
  jmp __alltraps
c010275a:	e9 8d 09 00 00       	jmp    c01030ec <__alltraps>

c010275f <vector27>:
.globl vector27
vector27:
  pushl $0
c010275f:	6a 00                	push   $0x0
  pushl $27
c0102761:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102763:	e9 84 09 00 00       	jmp    c01030ec <__alltraps>

c0102768 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102768:	6a 00                	push   $0x0
  pushl $28
c010276a:	6a 1c                	push   $0x1c
  jmp __alltraps
c010276c:	e9 7b 09 00 00       	jmp    c01030ec <__alltraps>

c0102771 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102771:	6a 00                	push   $0x0
  pushl $29
c0102773:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102775:	e9 72 09 00 00       	jmp    c01030ec <__alltraps>

c010277a <vector30>:
.globl vector30
vector30:
  pushl $0
c010277a:	6a 00                	push   $0x0
  pushl $30
c010277c:	6a 1e                	push   $0x1e
  jmp __alltraps
c010277e:	e9 69 09 00 00       	jmp    c01030ec <__alltraps>

c0102783 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102783:	6a 00                	push   $0x0
  pushl $31
c0102785:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102787:	e9 60 09 00 00       	jmp    c01030ec <__alltraps>

c010278c <vector32>:
.globl vector32
vector32:
  pushl $0
c010278c:	6a 00                	push   $0x0
  pushl $32
c010278e:	6a 20                	push   $0x20
  jmp __alltraps
c0102790:	e9 57 09 00 00       	jmp    c01030ec <__alltraps>

c0102795 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102795:	6a 00                	push   $0x0
  pushl $33
c0102797:	6a 21                	push   $0x21
  jmp __alltraps
c0102799:	e9 4e 09 00 00       	jmp    c01030ec <__alltraps>

c010279e <vector34>:
.globl vector34
vector34:
  pushl $0
c010279e:	6a 00                	push   $0x0
  pushl $34
c01027a0:	6a 22                	push   $0x22
  jmp __alltraps
c01027a2:	e9 45 09 00 00       	jmp    c01030ec <__alltraps>

c01027a7 <vector35>:
.globl vector35
vector35:
  pushl $0
c01027a7:	6a 00                	push   $0x0
  pushl $35
c01027a9:	6a 23                	push   $0x23
  jmp __alltraps
c01027ab:	e9 3c 09 00 00       	jmp    c01030ec <__alltraps>

c01027b0 <vector36>:
.globl vector36
vector36:
  pushl $0
c01027b0:	6a 00                	push   $0x0
  pushl $36
c01027b2:	6a 24                	push   $0x24
  jmp __alltraps
c01027b4:	e9 33 09 00 00       	jmp    c01030ec <__alltraps>

c01027b9 <vector37>:
.globl vector37
vector37:
  pushl $0
c01027b9:	6a 00                	push   $0x0
  pushl $37
c01027bb:	6a 25                	push   $0x25
  jmp __alltraps
c01027bd:	e9 2a 09 00 00       	jmp    c01030ec <__alltraps>

c01027c2 <vector38>:
.globl vector38
vector38:
  pushl $0
c01027c2:	6a 00                	push   $0x0
  pushl $38
c01027c4:	6a 26                	push   $0x26
  jmp __alltraps
c01027c6:	e9 21 09 00 00       	jmp    c01030ec <__alltraps>

c01027cb <vector39>:
.globl vector39
vector39:
  pushl $0
c01027cb:	6a 00                	push   $0x0
  pushl $39
c01027cd:	6a 27                	push   $0x27
  jmp __alltraps
c01027cf:	e9 18 09 00 00       	jmp    c01030ec <__alltraps>

c01027d4 <vector40>:
.globl vector40
vector40:
  pushl $0
c01027d4:	6a 00                	push   $0x0
  pushl $40
c01027d6:	6a 28                	push   $0x28
  jmp __alltraps
c01027d8:	e9 0f 09 00 00       	jmp    c01030ec <__alltraps>

c01027dd <vector41>:
.globl vector41
vector41:
  pushl $0
c01027dd:	6a 00                	push   $0x0
  pushl $41
c01027df:	6a 29                	push   $0x29
  jmp __alltraps
c01027e1:	e9 06 09 00 00       	jmp    c01030ec <__alltraps>

c01027e6 <vector42>:
.globl vector42
vector42:
  pushl $0
c01027e6:	6a 00                	push   $0x0
  pushl $42
c01027e8:	6a 2a                	push   $0x2a
  jmp __alltraps
c01027ea:	e9 fd 08 00 00       	jmp    c01030ec <__alltraps>

c01027ef <vector43>:
.globl vector43
vector43:
  pushl $0
c01027ef:	6a 00                	push   $0x0
  pushl $43
c01027f1:	6a 2b                	push   $0x2b
  jmp __alltraps
c01027f3:	e9 f4 08 00 00       	jmp    c01030ec <__alltraps>

c01027f8 <vector44>:
.globl vector44
vector44:
  pushl $0
c01027f8:	6a 00                	push   $0x0
  pushl $44
c01027fa:	6a 2c                	push   $0x2c
  jmp __alltraps
c01027fc:	e9 eb 08 00 00       	jmp    c01030ec <__alltraps>

c0102801 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102801:	6a 00                	push   $0x0
  pushl $45
c0102803:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102805:	e9 e2 08 00 00       	jmp    c01030ec <__alltraps>

c010280a <vector46>:
.globl vector46
vector46:
  pushl $0
c010280a:	6a 00                	push   $0x0
  pushl $46
c010280c:	6a 2e                	push   $0x2e
  jmp __alltraps
c010280e:	e9 d9 08 00 00       	jmp    c01030ec <__alltraps>

c0102813 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102813:	6a 00                	push   $0x0
  pushl $47
c0102815:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102817:	e9 d0 08 00 00       	jmp    c01030ec <__alltraps>

c010281c <vector48>:
.globl vector48
vector48:
  pushl $0
c010281c:	6a 00                	push   $0x0
  pushl $48
c010281e:	6a 30                	push   $0x30
  jmp __alltraps
c0102820:	e9 c7 08 00 00       	jmp    c01030ec <__alltraps>

c0102825 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102825:	6a 00                	push   $0x0
  pushl $49
c0102827:	6a 31                	push   $0x31
  jmp __alltraps
c0102829:	e9 be 08 00 00       	jmp    c01030ec <__alltraps>

c010282e <vector50>:
.globl vector50
vector50:
  pushl $0
c010282e:	6a 00                	push   $0x0
  pushl $50
c0102830:	6a 32                	push   $0x32
  jmp __alltraps
c0102832:	e9 b5 08 00 00       	jmp    c01030ec <__alltraps>

c0102837 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102837:	6a 00                	push   $0x0
  pushl $51
c0102839:	6a 33                	push   $0x33
  jmp __alltraps
c010283b:	e9 ac 08 00 00       	jmp    c01030ec <__alltraps>

c0102840 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102840:	6a 00                	push   $0x0
  pushl $52
c0102842:	6a 34                	push   $0x34
  jmp __alltraps
c0102844:	e9 a3 08 00 00       	jmp    c01030ec <__alltraps>

c0102849 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102849:	6a 00                	push   $0x0
  pushl $53
c010284b:	6a 35                	push   $0x35
  jmp __alltraps
c010284d:	e9 9a 08 00 00       	jmp    c01030ec <__alltraps>

c0102852 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102852:	6a 00                	push   $0x0
  pushl $54
c0102854:	6a 36                	push   $0x36
  jmp __alltraps
c0102856:	e9 91 08 00 00       	jmp    c01030ec <__alltraps>

c010285b <vector55>:
.globl vector55
vector55:
  pushl $0
c010285b:	6a 00                	push   $0x0
  pushl $55
c010285d:	6a 37                	push   $0x37
  jmp __alltraps
c010285f:	e9 88 08 00 00       	jmp    c01030ec <__alltraps>

c0102864 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102864:	6a 00                	push   $0x0
  pushl $56
c0102866:	6a 38                	push   $0x38
  jmp __alltraps
c0102868:	e9 7f 08 00 00       	jmp    c01030ec <__alltraps>

c010286d <vector57>:
.globl vector57
vector57:
  pushl $0
c010286d:	6a 00                	push   $0x0
  pushl $57
c010286f:	6a 39                	push   $0x39
  jmp __alltraps
c0102871:	e9 76 08 00 00       	jmp    c01030ec <__alltraps>

c0102876 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102876:	6a 00                	push   $0x0
  pushl $58
c0102878:	6a 3a                	push   $0x3a
  jmp __alltraps
c010287a:	e9 6d 08 00 00       	jmp    c01030ec <__alltraps>

c010287f <vector59>:
.globl vector59
vector59:
  pushl $0
c010287f:	6a 00                	push   $0x0
  pushl $59
c0102881:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102883:	e9 64 08 00 00       	jmp    c01030ec <__alltraps>

c0102888 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102888:	6a 00                	push   $0x0
  pushl $60
c010288a:	6a 3c                	push   $0x3c
  jmp __alltraps
c010288c:	e9 5b 08 00 00       	jmp    c01030ec <__alltraps>

c0102891 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102891:	6a 00                	push   $0x0
  pushl $61
c0102893:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102895:	e9 52 08 00 00       	jmp    c01030ec <__alltraps>

c010289a <vector62>:
.globl vector62
vector62:
  pushl $0
c010289a:	6a 00                	push   $0x0
  pushl $62
c010289c:	6a 3e                	push   $0x3e
  jmp __alltraps
c010289e:	e9 49 08 00 00       	jmp    c01030ec <__alltraps>

c01028a3 <vector63>:
.globl vector63
vector63:
  pushl $0
c01028a3:	6a 00                	push   $0x0
  pushl $63
c01028a5:	6a 3f                	push   $0x3f
  jmp __alltraps
c01028a7:	e9 40 08 00 00       	jmp    c01030ec <__alltraps>

c01028ac <vector64>:
.globl vector64
vector64:
  pushl $0
c01028ac:	6a 00                	push   $0x0
  pushl $64
c01028ae:	6a 40                	push   $0x40
  jmp __alltraps
c01028b0:	e9 37 08 00 00       	jmp    c01030ec <__alltraps>

c01028b5 <vector65>:
.globl vector65
vector65:
  pushl $0
c01028b5:	6a 00                	push   $0x0
  pushl $65
c01028b7:	6a 41                	push   $0x41
  jmp __alltraps
c01028b9:	e9 2e 08 00 00       	jmp    c01030ec <__alltraps>

c01028be <vector66>:
.globl vector66
vector66:
  pushl $0
c01028be:	6a 00                	push   $0x0
  pushl $66
c01028c0:	6a 42                	push   $0x42
  jmp __alltraps
c01028c2:	e9 25 08 00 00       	jmp    c01030ec <__alltraps>

c01028c7 <vector67>:
.globl vector67
vector67:
  pushl $0
c01028c7:	6a 00                	push   $0x0
  pushl $67
c01028c9:	6a 43                	push   $0x43
  jmp __alltraps
c01028cb:	e9 1c 08 00 00       	jmp    c01030ec <__alltraps>

c01028d0 <vector68>:
.globl vector68
vector68:
  pushl $0
c01028d0:	6a 00                	push   $0x0
  pushl $68
c01028d2:	6a 44                	push   $0x44
  jmp __alltraps
c01028d4:	e9 13 08 00 00       	jmp    c01030ec <__alltraps>

c01028d9 <vector69>:
.globl vector69
vector69:
  pushl $0
c01028d9:	6a 00                	push   $0x0
  pushl $69
c01028db:	6a 45                	push   $0x45
  jmp __alltraps
c01028dd:	e9 0a 08 00 00       	jmp    c01030ec <__alltraps>

c01028e2 <vector70>:
.globl vector70
vector70:
  pushl $0
c01028e2:	6a 00                	push   $0x0
  pushl $70
c01028e4:	6a 46                	push   $0x46
  jmp __alltraps
c01028e6:	e9 01 08 00 00       	jmp    c01030ec <__alltraps>

c01028eb <vector71>:
.globl vector71
vector71:
  pushl $0
c01028eb:	6a 00                	push   $0x0
  pushl $71
c01028ed:	6a 47                	push   $0x47
  jmp __alltraps
c01028ef:	e9 f8 07 00 00       	jmp    c01030ec <__alltraps>

c01028f4 <vector72>:
.globl vector72
vector72:
  pushl $0
c01028f4:	6a 00                	push   $0x0
  pushl $72
c01028f6:	6a 48                	push   $0x48
  jmp __alltraps
c01028f8:	e9 ef 07 00 00       	jmp    c01030ec <__alltraps>

c01028fd <vector73>:
.globl vector73
vector73:
  pushl $0
c01028fd:	6a 00                	push   $0x0
  pushl $73
c01028ff:	6a 49                	push   $0x49
  jmp __alltraps
c0102901:	e9 e6 07 00 00       	jmp    c01030ec <__alltraps>

c0102906 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102906:	6a 00                	push   $0x0
  pushl $74
c0102908:	6a 4a                	push   $0x4a
  jmp __alltraps
c010290a:	e9 dd 07 00 00       	jmp    c01030ec <__alltraps>

c010290f <vector75>:
.globl vector75
vector75:
  pushl $0
c010290f:	6a 00                	push   $0x0
  pushl $75
c0102911:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102913:	e9 d4 07 00 00       	jmp    c01030ec <__alltraps>

c0102918 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102918:	6a 00                	push   $0x0
  pushl $76
c010291a:	6a 4c                	push   $0x4c
  jmp __alltraps
c010291c:	e9 cb 07 00 00       	jmp    c01030ec <__alltraps>

c0102921 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102921:	6a 00                	push   $0x0
  pushl $77
c0102923:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102925:	e9 c2 07 00 00       	jmp    c01030ec <__alltraps>

c010292a <vector78>:
.globl vector78
vector78:
  pushl $0
c010292a:	6a 00                	push   $0x0
  pushl $78
c010292c:	6a 4e                	push   $0x4e
  jmp __alltraps
c010292e:	e9 b9 07 00 00       	jmp    c01030ec <__alltraps>

c0102933 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102933:	6a 00                	push   $0x0
  pushl $79
c0102935:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102937:	e9 b0 07 00 00       	jmp    c01030ec <__alltraps>

c010293c <vector80>:
.globl vector80
vector80:
  pushl $0
c010293c:	6a 00                	push   $0x0
  pushl $80
c010293e:	6a 50                	push   $0x50
  jmp __alltraps
c0102940:	e9 a7 07 00 00       	jmp    c01030ec <__alltraps>

c0102945 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102945:	6a 00                	push   $0x0
  pushl $81
c0102947:	6a 51                	push   $0x51
  jmp __alltraps
c0102949:	e9 9e 07 00 00       	jmp    c01030ec <__alltraps>

c010294e <vector82>:
.globl vector82
vector82:
  pushl $0
c010294e:	6a 00                	push   $0x0
  pushl $82
c0102950:	6a 52                	push   $0x52
  jmp __alltraps
c0102952:	e9 95 07 00 00       	jmp    c01030ec <__alltraps>

c0102957 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102957:	6a 00                	push   $0x0
  pushl $83
c0102959:	6a 53                	push   $0x53
  jmp __alltraps
c010295b:	e9 8c 07 00 00       	jmp    c01030ec <__alltraps>

c0102960 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102960:	6a 00                	push   $0x0
  pushl $84
c0102962:	6a 54                	push   $0x54
  jmp __alltraps
c0102964:	e9 83 07 00 00       	jmp    c01030ec <__alltraps>

c0102969 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102969:	6a 00                	push   $0x0
  pushl $85
c010296b:	6a 55                	push   $0x55
  jmp __alltraps
c010296d:	e9 7a 07 00 00       	jmp    c01030ec <__alltraps>

c0102972 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102972:	6a 00                	push   $0x0
  pushl $86
c0102974:	6a 56                	push   $0x56
  jmp __alltraps
c0102976:	e9 71 07 00 00       	jmp    c01030ec <__alltraps>

c010297b <vector87>:
.globl vector87
vector87:
  pushl $0
c010297b:	6a 00                	push   $0x0
  pushl $87
c010297d:	6a 57                	push   $0x57
  jmp __alltraps
c010297f:	e9 68 07 00 00       	jmp    c01030ec <__alltraps>

c0102984 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102984:	6a 00                	push   $0x0
  pushl $88
c0102986:	6a 58                	push   $0x58
  jmp __alltraps
c0102988:	e9 5f 07 00 00       	jmp    c01030ec <__alltraps>

c010298d <vector89>:
.globl vector89
vector89:
  pushl $0
c010298d:	6a 00                	push   $0x0
  pushl $89
c010298f:	6a 59                	push   $0x59
  jmp __alltraps
c0102991:	e9 56 07 00 00       	jmp    c01030ec <__alltraps>

c0102996 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102996:	6a 00                	push   $0x0
  pushl $90
c0102998:	6a 5a                	push   $0x5a
  jmp __alltraps
c010299a:	e9 4d 07 00 00       	jmp    c01030ec <__alltraps>

c010299f <vector91>:
.globl vector91
vector91:
  pushl $0
c010299f:	6a 00                	push   $0x0
  pushl $91
c01029a1:	6a 5b                	push   $0x5b
  jmp __alltraps
c01029a3:	e9 44 07 00 00       	jmp    c01030ec <__alltraps>

c01029a8 <vector92>:
.globl vector92
vector92:
  pushl $0
c01029a8:	6a 00                	push   $0x0
  pushl $92
c01029aa:	6a 5c                	push   $0x5c
  jmp __alltraps
c01029ac:	e9 3b 07 00 00       	jmp    c01030ec <__alltraps>

c01029b1 <vector93>:
.globl vector93
vector93:
  pushl $0
c01029b1:	6a 00                	push   $0x0
  pushl $93
c01029b3:	6a 5d                	push   $0x5d
  jmp __alltraps
c01029b5:	e9 32 07 00 00       	jmp    c01030ec <__alltraps>

c01029ba <vector94>:
.globl vector94
vector94:
  pushl $0
c01029ba:	6a 00                	push   $0x0
  pushl $94
c01029bc:	6a 5e                	push   $0x5e
  jmp __alltraps
c01029be:	e9 29 07 00 00       	jmp    c01030ec <__alltraps>

c01029c3 <vector95>:
.globl vector95
vector95:
  pushl $0
c01029c3:	6a 00                	push   $0x0
  pushl $95
c01029c5:	6a 5f                	push   $0x5f
  jmp __alltraps
c01029c7:	e9 20 07 00 00       	jmp    c01030ec <__alltraps>

c01029cc <vector96>:
.globl vector96
vector96:
  pushl $0
c01029cc:	6a 00                	push   $0x0
  pushl $96
c01029ce:	6a 60                	push   $0x60
  jmp __alltraps
c01029d0:	e9 17 07 00 00       	jmp    c01030ec <__alltraps>

c01029d5 <vector97>:
.globl vector97
vector97:
  pushl $0
c01029d5:	6a 00                	push   $0x0
  pushl $97
c01029d7:	6a 61                	push   $0x61
  jmp __alltraps
c01029d9:	e9 0e 07 00 00       	jmp    c01030ec <__alltraps>

c01029de <vector98>:
.globl vector98
vector98:
  pushl $0
c01029de:	6a 00                	push   $0x0
  pushl $98
c01029e0:	6a 62                	push   $0x62
  jmp __alltraps
c01029e2:	e9 05 07 00 00       	jmp    c01030ec <__alltraps>

c01029e7 <vector99>:
.globl vector99
vector99:
  pushl $0
c01029e7:	6a 00                	push   $0x0
  pushl $99
c01029e9:	6a 63                	push   $0x63
  jmp __alltraps
c01029eb:	e9 fc 06 00 00       	jmp    c01030ec <__alltraps>

c01029f0 <vector100>:
.globl vector100
vector100:
  pushl $0
c01029f0:	6a 00                	push   $0x0
  pushl $100
c01029f2:	6a 64                	push   $0x64
  jmp __alltraps
c01029f4:	e9 f3 06 00 00       	jmp    c01030ec <__alltraps>

c01029f9 <vector101>:
.globl vector101
vector101:
  pushl $0
c01029f9:	6a 00                	push   $0x0
  pushl $101
c01029fb:	6a 65                	push   $0x65
  jmp __alltraps
c01029fd:	e9 ea 06 00 00       	jmp    c01030ec <__alltraps>

c0102a02 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102a02:	6a 00                	push   $0x0
  pushl $102
c0102a04:	6a 66                	push   $0x66
  jmp __alltraps
c0102a06:	e9 e1 06 00 00       	jmp    c01030ec <__alltraps>

c0102a0b <vector103>:
.globl vector103
vector103:
  pushl $0
c0102a0b:	6a 00                	push   $0x0
  pushl $103
c0102a0d:	6a 67                	push   $0x67
  jmp __alltraps
c0102a0f:	e9 d8 06 00 00       	jmp    c01030ec <__alltraps>

c0102a14 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102a14:	6a 00                	push   $0x0
  pushl $104
c0102a16:	6a 68                	push   $0x68
  jmp __alltraps
c0102a18:	e9 cf 06 00 00       	jmp    c01030ec <__alltraps>

c0102a1d <vector105>:
.globl vector105
vector105:
  pushl $0
c0102a1d:	6a 00                	push   $0x0
  pushl $105
c0102a1f:	6a 69                	push   $0x69
  jmp __alltraps
c0102a21:	e9 c6 06 00 00       	jmp    c01030ec <__alltraps>

c0102a26 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102a26:	6a 00                	push   $0x0
  pushl $106
c0102a28:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102a2a:	e9 bd 06 00 00       	jmp    c01030ec <__alltraps>

c0102a2f <vector107>:
.globl vector107
vector107:
  pushl $0
c0102a2f:	6a 00                	push   $0x0
  pushl $107
c0102a31:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102a33:	e9 b4 06 00 00       	jmp    c01030ec <__alltraps>

c0102a38 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102a38:	6a 00                	push   $0x0
  pushl $108
c0102a3a:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102a3c:	e9 ab 06 00 00       	jmp    c01030ec <__alltraps>

c0102a41 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102a41:	6a 00                	push   $0x0
  pushl $109
c0102a43:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102a45:	e9 a2 06 00 00       	jmp    c01030ec <__alltraps>

c0102a4a <vector110>:
.globl vector110
vector110:
  pushl $0
c0102a4a:	6a 00                	push   $0x0
  pushl $110
c0102a4c:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102a4e:	e9 99 06 00 00       	jmp    c01030ec <__alltraps>

c0102a53 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102a53:	6a 00                	push   $0x0
  pushl $111
c0102a55:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102a57:	e9 90 06 00 00       	jmp    c01030ec <__alltraps>

c0102a5c <vector112>:
.globl vector112
vector112:
  pushl $0
c0102a5c:	6a 00                	push   $0x0
  pushl $112
c0102a5e:	6a 70                	push   $0x70
  jmp __alltraps
c0102a60:	e9 87 06 00 00       	jmp    c01030ec <__alltraps>

c0102a65 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102a65:	6a 00                	push   $0x0
  pushl $113
c0102a67:	6a 71                	push   $0x71
  jmp __alltraps
c0102a69:	e9 7e 06 00 00       	jmp    c01030ec <__alltraps>

c0102a6e <vector114>:
.globl vector114
vector114:
  pushl $0
c0102a6e:	6a 00                	push   $0x0
  pushl $114
c0102a70:	6a 72                	push   $0x72
  jmp __alltraps
c0102a72:	e9 75 06 00 00       	jmp    c01030ec <__alltraps>

c0102a77 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102a77:	6a 00                	push   $0x0
  pushl $115
c0102a79:	6a 73                	push   $0x73
  jmp __alltraps
c0102a7b:	e9 6c 06 00 00       	jmp    c01030ec <__alltraps>

c0102a80 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102a80:	6a 00                	push   $0x0
  pushl $116
c0102a82:	6a 74                	push   $0x74
  jmp __alltraps
c0102a84:	e9 63 06 00 00       	jmp    c01030ec <__alltraps>

c0102a89 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102a89:	6a 00                	push   $0x0
  pushl $117
c0102a8b:	6a 75                	push   $0x75
  jmp __alltraps
c0102a8d:	e9 5a 06 00 00       	jmp    c01030ec <__alltraps>

c0102a92 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102a92:	6a 00                	push   $0x0
  pushl $118
c0102a94:	6a 76                	push   $0x76
  jmp __alltraps
c0102a96:	e9 51 06 00 00       	jmp    c01030ec <__alltraps>

c0102a9b <vector119>:
.globl vector119
vector119:
  pushl $0
c0102a9b:	6a 00                	push   $0x0
  pushl $119
c0102a9d:	6a 77                	push   $0x77
  jmp __alltraps
c0102a9f:	e9 48 06 00 00       	jmp    c01030ec <__alltraps>

c0102aa4 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102aa4:	6a 00                	push   $0x0
  pushl $120
c0102aa6:	6a 78                	push   $0x78
  jmp __alltraps
c0102aa8:	e9 3f 06 00 00       	jmp    c01030ec <__alltraps>

c0102aad <vector121>:
.globl vector121
vector121:
  pushl $0
c0102aad:	6a 00                	push   $0x0
  pushl $121
c0102aaf:	6a 79                	push   $0x79
  jmp __alltraps
c0102ab1:	e9 36 06 00 00       	jmp    c01030ec <__alltraps>

c0102ab6 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ab6:	6a 00                	push   $0x0
  pushl $122
c0102ab8:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102aba:	e9 2d 06 00 00       	jmp    c01030ec <__alltraps>

c0102abf <vector123>:
.globl vector123
vector123:
  pushl $0
c0102abf:	6a 00                	push   $0x0
  pushl $123
c0102ac1:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ac3:	e9 24 06 00 00       	jmp    c01030ec <__alltraps>

c0102ac8 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ac8:	6a 00                	push   $0x0
  pushl $124
c0102aca:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102acc:	e9 1b 06 00 00       	jmp    c01030ec <__alltraps>

c0102ad1 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ad1:	6a 00                	push   $0x0
  pushl $125
c0102ad3:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ad5:	e9 12 06 00 00       	jmp    c01030ec <__alltraps>

c0102ada <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ada:	6a 00                	push   $0x0
  pushl $126
c0102adc:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ade:	e9 09 06 00 00       	jmp    c01030ec <__alltraps>

c0102ae3 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ae3:	6a 00                	push   $0x0
  pushl $127
c0102ae5:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102ae7:	e9 00 06 00 00       	jmp    c01030ec <__alltraps>

c0102aec <vector128>:
.globl vector128
vector128:
  pushl $0
c0102aec:	6a 00                	push   $0x0
  pushl $128
c0102aee:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102af3:	e9 f4 05 00 00       	jmp    c01030ec <__alltraps>

c0102af8 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102af8:	6a 00                	push   $0x0
  pushl $129
c0102afa:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102aff:	e9 e8 05 00 00       	jmp    c01030ec <__alltraps>

c0102b04 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102b04:	6a 00                	push   $0x0
  pushl $130
c0102b06:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102b0b:	e9 dc 05 00 00       	jmp    c01030ec <__alltraps>

c0102b10 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102b10:	6a 00                	push   $0x0
  pushl $131
c0102b12:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102b17:	e9 d0 05 00 00       	jmp    c01030ec <__alltraps>

c0102b1c <vector132>:
.globl vector132
vector132:
  pushl $0
c0102b1c:	6a 00                	push   $0x0
  pushl $132
c0102b1e:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102b23:	e9 c4 05 00 00       	jmp    c01030ec <__alltraps>

c0102b28 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102b28:	6a 00                	push   $0x0
  pushl $133
c0102b2a:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102b2f:	e9 b8 05 00 00       	jmp    c01030ec <__alltraps>

c0102b34 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102b34:	6a 00                	push   $0x0
  pushl $134
c0102b36:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102b3b:	e9 ac 05 00 00       	jmp    c01030ec <__alltraps>

c0102b40 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102b40:	6a 00                	push   $0x0
  pushl $135
c0102b42:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102b47:	e9 a0 05 00 00       	jmp    c01030ec <__alltraps>

c0102b4c <vector136>:
.globl vector136
vector136:
  pushl $0
c0102b4c:	6a 00                	push   $0x0
  pushl $136
c0102b4e:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102b53:	e9 94 05 00 00       	jmp    c01030ec <__alltraps>

c0102b58 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102b58:	6a 00                	push   $0x0
  pushl $137
c0102b5a:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102b5f:	e9 88 05 00 00       	jmp    c01030ec <__alltraps>

c0102b64 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102b64:	6a 00                	push   $0x0
  pushl $138
c0102b66:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102b6b:	e9 7c 05 00 00       	jmp    c01030ec <__alltraps>

c0102b70 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102b70:	6a 00                	push   $0x0
  pushl $139
c0102b72:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102b77:	e9 70 05 00 00       	jmp    c01030ec <__alltraps>

c0102b7c <vector140>:
.globl vector140
vector140:
  pushl $0
c0102b7c:	6a 00                	push   $0x0
  pushl $140
c0102b7e:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102b83:	e9 64 05 00 00       	jmp    c01030ec <__alltraps>

c0102b88 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102b88:	6a 00                	push   $0x0
  pushl $141
c0102b8a:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102b8f:	e9 58 05 00 00       	jmp    c01030ec <__alltraps>

c0102b94 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102b94:	6a 00                	push   $0x0
  pushl $142
c0102b96:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102b9b:	e9 4c 05 00 00       	jmp    c01030ec <__alltraps>

c0102ba0 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102ba0:	6a 00                	push   $0x0
  pushl $143
c0102ba2:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102ba7:	e9 40 05 00 00       	jmp    c01030ec <__alltraps>

c0102bac <vector144>:
.globl vector144
vector144:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $144
c0102bae:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102bb3:	e9 34 05 00 00       	jmp    c01030ec <__alltraps>

c0102bb8 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102bb8:	6a 00                	push   $0x0
  pushl $145
c0102bba:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102bbf:	e9 28 05 00 00       	jmp    c01030ec <__alltraps>

c0102bc4 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102bc4:	6a 00                	push   $0x0
  pushl $146
c0102bc6:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102bcb:	e9 1c 05 00 00       	jmp    c01030ec <__alltraps>

c0102bd0 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $147
c0102bd2:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102bd7:	e9 10 05 00 00       	jmp    c01030ec <__alltraps>

c0102bdc <vector148>:
.globl vector148
vector148:
  pushl $0
c0102bdc:	6a 00                	push   $0x0
  pushl $148
c0102bde:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102be3:	e9 04 05 00 00       	jmp    c01030ec <__alltraps>

c0102be8 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102be8:	6a 00                	push   $0x0
  pushl $149
c0102bea:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102bef:	e9 f8 04 00 00       	jmp    c01030ec <__alltraps>

c0102bf4 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $150
c0102bf6:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102bfb:	e9 ec 04 00 00       	jmp    c01030ec <__alltraps>

c0102c00 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102c00:	6a 00                	push   $0x0
  pushl $151
c0102c02:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102c07:	e9 e0 04 00 00       	jmp    c01030ec <__alltraps>

c0102c0c <vector152>:
.globl vector152
vector152:
  pushl $0
c0102c0c:	6a 00                	push   $0x0
  pushl $152
c0102c0e:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102c13:	e9 d4 04 00 00       	jmp    c01030ec <__alltraps>

c0102c18 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $153
c0102c1a:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102c1f:	e9 c8 04 00 00       	jmp    c01030ec <__alltraps>

c0102c24 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102c24:	6a 00                	push   $0x0
  pushl $154
c0102c26:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102c2b:	e9 bc 04 00 00       	jmp    c01030ec <__alltraps>

c0102c30 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102c30:	6a 00                	push   $0x0
  pushl $155
c0102c32:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102c37:	e9 b0 04 00 00       	jmp    c01030ec <__alltraps>

c0102c3c <vector156>:
.globl vector156
vector156:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $156
c0102c3e:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102c43:	e9 a4 04 00 00       	jmp    c01030ec <__alltraps>

c0102c48 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102c48:	6a 00                	push   $0x0
  pushl $157
c0102c4a:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102c4f:	e9 98 04 00 00       	jmp    c01030ec <__alltraps>

c0102c54 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102c54:	6a 00                	push   $0x0
  pushl $158
c0102c56:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102c5b:	e9 8c 04 00 00       	jmp    c01030ec <__alltraps>

c0102c60 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $159
c0102c62:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102c67:	e9 80 04 00 00       	jmp    c01030ec <__alltraps>

c0102c6c <vector160>:
.globl vector160
vector160:
  pushl $0
c0102c6c:	6a 00                	push   $0x0
  pushl $160
c0102c6e:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102c73:	e9 74 04 00 00       	jmp    c01030ec <__alltraps>

c0102c78 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102c78:	6a 00                	push   $0x0
  pushl $161
c0102c7a:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102c7f:	e9 68 04 00 00       	jmp    c01030ec <__alltraps>

c0102c84 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102c84:	6a 00                	push   $0x0
  pushl $162
c0102c86:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102c8b:	e9 5c 04 00 00       	jmp    c01030ec <__alltraps>

c0102c90 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102c90:	6a 00                	push   $0x0
  pushl $163
c0102c92:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102c97:	e9 50 04 00 00       	jmp    c01030ec <__alltraps>

c0102c9c <vector164>:
.globl vector164
vector164:
  pushl $0
c0102c9c:	6a 00                	push   $0x0
  pushl $164
c0102c9e:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102ca3:	e9 44 04 00 00       	jmp    c01030ec <__alltraps>

c0102ca8 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102ca8:	6a 00                	push   $0x0
  pushl $165
c0102caa:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102caf:	e9 38 04 00 00       	jmp    c01030ec <__alltraps>

c0102cb4 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102cb4:	6a 00                	push   $0x0
  pushl $166
c0102cb6:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102cbb:	e9 2c 04 00 00       	jmp    c01030ec <__alltraps>

c0102cc0 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102cc0:	6a 00                	push   $0x0
  pushl $167
c0102cc2:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102cc7:	e9 20 04 00 00       	jmp    c01030ec <__alltraps>

c0102ccc <vector168>:
.globl vector168
vector168:
  pushl $0
c0102ccc:	6a 00                	push   $0x0
  pushl $168
c0102cce:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102cd3:	e9 14 04 00 00       	jmp    c01030ec <__alltraps>

c0102cd8 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102cd8:	6a 00                	push   $0x0
  pushl $169
c0102cda:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102cdf:	e9 08 04 00 00       	jmp    c01030ec <__alltraps>

c0102ce4 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102ce4:	6a 00                	push   $0x0
  pushl $170
c0102ce6:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102ceb:	e9 fc 03 00 00       	jmp    c01030ec <__alltraps>

c0102cf0 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102cf0:	6a 00                	push   $0x0
  pushl $171
c0102cf2:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102cf7:	e9 f0 03 00 00       	jmp    c01030ec <__alltraps>

c0102cfc <vector172>:
.globl vector172
vector172:
  pushl $0
c0102cfc:	6a 00                	push   $0x0
  pushl $172
c0102cfe:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102d03:	e9 e4 03 00 00       	jmp    c01030ec <__alltraps>

c0102d08 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102d08:	6a 00                	push   $0x0
  pushl $173
c0102d0a:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102d0f:	e9 d8 03 00 00       	jmp    c01030ec <__alltraps>

c0102d14 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102d14:	6a 00                	push   $0x0
  pushl $174
c0102d16:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102d1b:	e9 cc 03 00 00       	jmp    c01030ec <__alltraps>

c0102d20 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102d20:	6a 00                	push   $0x0
  pushl $175
c0102d22:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102d27:	e9 c0 03 00 00       	jmp    c01030ec <__alltraps>

c0102d2c <vector176>:
.globl vector176
vector176:
  pushl $0
c0102d2c:	6a 00                	push   $0x0
  pushl $176
c0102d2e:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102d33:	e9 b4 03 00 00       	jmp    c01030ec <__alltraps>

c0102d38 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102d38:	6a 00                	push   $0x0
  pushl $177
c0102d3a:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102d3f:	e9 a8 03 00 00       	jmp    c01030ec <__alltraps>

c0102d44 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102d44:	6a 00                	push   $0x0
  pushl $178
c0102d46:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102d4b:	e9 9c 03 00 00       	jmp    c01030ec <__alltraps>

c0102d50 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102d50:	6a 00                	push   $0x0
  pushl $179
c0102d52:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102d57:	e9 90 03 00 00       	jmp    c01030ec <__alltraps>

c0102d5c <vector180>:
.globl vector180
vector180:
  pushl $0
c0102d5c:	6a 00                	push   $0x0
  pushl $180
c0102d5e:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102d63:	e9 84 03 00 00       	jmp    c01030ec <__alltraps>

c0102d68 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102d68:	6a 00                	push   $0x0
  pushl $181
c0102d6a:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102d6f:	e9 78 03 00 00       	jmp    c01030ec <__alltraps>

c0102d74 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102d74:	6a 00                	push   $0x0
  pushl $182
c0102d76:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102d7b:	e9 6c 03 00 00       	jmp    c01030ec <__alltraps>

c0102d80 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102d80:	6a 00                	push   $0x0
  pushl $183
c0102d82:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102d87:	e9 60 03 00 00       	jmp    c01030ec <__alltraps>

c0102d8c <vector184>:
.globl vector184
vector184:
  pushl $0
c0102d8c:	6a 00                	push   $0x0
  pushl $184
c0102d8e:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102d93:	e9 54 03 00 00       	jmp    c01030ec <__alltraps>

c0102d98 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102d98:	6a 00                	push   $0x0
  pushl $185
c0102d9a:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102d9f:	e9 48 03 00 00       	jmp    c01030ec <__alltraps>

c0102da4 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102da4:	6a 00                	push   $0x0
  pushl $186
c0102da6:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102dab:	e9 3c 03 00 00       	jmp    c01030ec <__alltraps>

c0102db0 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102db0:	6a 00                	push   $0x0
  pushl $187
c0102db2:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102db7:	e9 30 03 00 00       	jmp    c01030ec <__alltraps>

c0102dbc <vector188>:
.globl vector188
vector188:
  pushl $0
c0102dbc:	6a 00                	push   $0x0
  pushl $188
c0102dbe:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102dc3:	e9 24 03 00 00       	jmp    c01030ec <__alltraps>

c0102dc8 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102dc8:	6a 00                	push   $0x0
  pushl $189
c0102dca:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102dcf:	e9 18 03 00 00       	jmp    c01030ec <__alltraps>

c0102dd4 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102dd4:	6a 00                	push   $0x0
  pushl $190
c0102dd6:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102ddb:	e9 0c 03 00 00       	jmp    c01030ec <__alltraps>

c0102de0 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102de0:	6a 00                	push   $0x0
  pushl $191
c0102de2:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102de7:	e9 00 03 00 00       	jmp    c01030ec <__alltraps>

c0102dec <vector192>:
.globl vector192
vector192:
  pushl $0
c0102dec:	6a 00                	push   $0x0
  pushl $192
c0102dee:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102df3:	e9 f4 02 00 00       	jmp    c01030ec <__alltraps>

c0102df8 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102df8:	6a 00                	push   $0x0
  pushl $193
c0102dfa:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102dff:	e9 e8 02 00 00       	jmp    c01030ec <__alltraps>

c0102e04 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102e04:	6a 00                	push   $0x0
  pushl $194
c0102e06:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102e0b:	e9 dc 02 00 00       	jmp    c01030ec <__alltraps>

c0102e10 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102e10:	6a 00                	push   $0x0
  pushl $195
c0102e12:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102e17:	e9 d0 02 00 00       	jmp    c01030ec <__alltraps>

c0102e1c <vector196>:
.globl vector196
vector196:
  pushl $0
c0102e1c:	6a 00                	push   $0x0
  pushl $196
c0102e1e:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102e23:	e9 c4 02 00 00       	jmp    c01030ec <__alltraps>

c0102e28 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102e28:	6a 00                	push   $0x0
  pushl $197
c0102e2a:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102e2f:	e9 b8 02 00 00       	jmp    c01030ec <__alltraps>

c0102e34 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102e34:	6a 00                	push   $0x0
  pushl $198
c0102e36:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102e3b:	e9 ac 02 00 00       	jmp    c01030ec <__alltraps>

c0102e40 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102e40:	6a 00                	push   $0x0
  pushl $199
c0102e42:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102e47:	e9 a0 02 00 00       	jmp    c01030ec <__alltraps>

c0102e4c <vector200>:
.globl vector200
vector200:
  pushl $0
c0102e4c:	6a 00                	push   $0x0
  pushl $200
c0102e4e:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102e53:	e9 94 02 00 00       	jmp    c01030ec <__alltraps>

c0102e58 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102e58:	6a 00                	push   $0x0
  pushl $201
c0102e5a:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102e5f:	e9 88 02 00 00       	jmp    c01030ec <__alltraps>

c0102e64 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102e64:	6a 00                	push   $0x0
  pushl $202
c0102e66:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102e6b:	e9 7c 02 00 00       	jmp    c01030ec <__alltraps>

c0102e70 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102e70:	6a 00                	push   $0x0
  pushl $203
c0102e72:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102e77:	e9 70 02 00 00       	jmp    c01030ec <__alltraps>

c0102e7c <vector204>:
.globl vector204
vector204:
  pushl $0
c0102e7c:	6a 00                	push   $0x0
  pushl $204
c0102e7e:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102e83:	e9 64 02 00 00       	jmp    c01030ec <__alltraps>

c0102e88 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102e88:	6a 00                	push   $0x0
  pushl $205
c0102e8a:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102e8f:	e9 58 02 00 00       	jmp    c01030ec <__alltraps>

c0102e94 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102e94:	6a 00                	push   $0x0
  pushl $206
c0102e96:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102e9b:	e9 4c 02 00 00       	jmp    c01030ec <__alltraps>

c0102ea0 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102ea0:	6a 00                	push   $0x0
  pushl $207
c0102ea2:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102ea7:	e9 40 02 00 00       	jmp    c01030ec <__alltraps>

c0102eac <vector208>:
.globl vector208
vector208:
  pushl $0
c0102eac:	6a 00                	push   $0x0
  pushl $208
c0102eae:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102eb3:	e9 34 02 00 00       	jmp    c01030ec <__alltraps>

c0102eb8 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102eb8:	6a 00                	push   $0x0
  pushl $209
c0102eba:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102ebf:	e9 28 02 00 00       	jmp    c01030ec <__alltraps>

c0102ec4 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102ec4:	6a 00                	push   $0x0
  pushl $210
c0102ec6:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102ecb:	e9 1c 02 00 00       	jmp    c01030ec <__alltraps>

c0102ed0 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102ed0:	6a 00                	push   $0x0
  pushl $211
c0102ed2:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102ed7:	e9 10 02 00 00       	jmp    c01030ec <__alltraps>

c0102edc <vector212>:
.globl vector212
vector212:
  pushl $0
c0102edc:	6a 00                	push   $0x0
  pushl $212
c0102ede:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102ee3:	e9 04 02 00 00       	jmp    c01030ec <__alltraps>

c0102ee8 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102ee8:	6a 00                	push   $0x0
  pushl $213
c0102eea:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102eef:	e9 f8 01 00 00       	jmp    c01030ec <__alltraps>

c0102ef4 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102ef4:	6a 00                	push   $0x0
  pushl $214
c0102ef6:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102efb:	e9 ec 01 00 00       	jmp    c01030ec <__alltraps>

c0102f00 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102f00:	6a 00                	push   $0x0
  pushl $215
c0102f02:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102f07:	e9 e0 01 00 00       	jmp    c01030ec <__alltraps>

c0102f0c <vector216>:
.globl vector216
vector216:
  pushl $0
c0102f0c:	6a 00                	push   $0x0
  pushl $216
c0102f0e:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102f13:	e9 d4 01 00 00       	jmp    c01030ec <__alltraps>

c0102f18 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102f18:	6a 00                	push   $0x0
  pushl $217
c0102f1a:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102f1f:	e9 c8 01 00 00       	jmp    c01030ec <__alltraps>

c0102f24 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102f24:	6a 00                	push   $0x0
  pushl $218
c0102f26:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102f2b:	e9 bc 01 00 00       	jmp    c01030ec <__alltraps>

c0102f30 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102f30:	6a 00                	push   $0x0
  pushl $219
c0102f32:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102f37:	e9 b0 01 00 00       	jmp    c01030ec <__alltraps>

c0102f3c <vector220>:
.globl vector220
vector220:
  pushl $0
c0102f3c:	6a 00                	push   $0x0
  pushl $220
c0102f3e:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102f43:	e9 a4 01 00 00       	jmp    c01030ec <__alltraps>

c0102f48 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102f48:	6a 00                	push   $0x0
  pushl $221
c0102f4a:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102f4f:	e9 98 01 00 00       	jmp    c01030ec <__alltraps>

c0102f54 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102f54:	6a 00                	push   $0x0
  pushl $222
c0102f56:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102f5b:	e9 8c 01 00 00       	jmp    c01030ec <__alltraps>

c0102f60 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102f60:	6a 00                	push   $0x0
  pushl $223
c0102f62:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102f67:	e9 80 01 00 00       	jmp    c01030ec <__alltraps>

c0102f6c <vector224>:
.globl vector224
vector224:
  pushl $0
c0102f6c:	6a 00                	push   $0x0
  pushl $224
c0102f6e:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102f73:	e9 74 01 00 00       	jmp    c01030ec <__alltraps>

c0102f78 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102f78:	6a 00                	push   $0x0
  pushl $225
c0102f7a:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102f7f:	e9 68 01 00 00       	jmp    c01030ec <__alltraps>

c0102f84 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102f84:	6a 00                	push   $0x0
  pushl $226
c0102f86:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102f8b:	e9 5c 01 00 00       	jmp    c01030ec <__alltraps>

c0102f90 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102f90:	6a 00                	push   $0x0
  pushl $227
c0102f92:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102f97:	e9 50 01 00 00       	jmp    c01030ec <__alltraps>

c0102f9c <vector228>:
.globl vector228
vector228:
  pushl $0
c0102f9c:	6a 00                	push   $0x0
  pushl $228
c0102f9e:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102fa3:	e9 44 01 00 00       	jmp    c01030ec <__alltraps>

c0102fa8 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102fa8:	6a 00                	push   $0x0
  pushl $229
c0102faa:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102faf:	e9 38 01 00 00       	jmp    c01030ec <__alltraps>

c0102fb4 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102fb4:	6a 00                	push   $0x0
  pushl $230
c0102fb6:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102fbb:	e9 2c 01 00 00       	jmp    c01030ec <__alltraps>

c0102fc0 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102fc0:	6a 00                	push   $0x0
  pushl $231
c0102fc2:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102fc7:	e9 20 01 00 00       	jmp    c01030ec <__alltraps>

c0102fcc <vector232>:
.globl vector232
vector232:
  pushl $0
c0102fcc:	6a 00                	push   $0x0
  pushl $232
c0102fce:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102fd3:	e9 14 01 00 00       	jmp    c01030ec <__alltraps>

c0102fd8 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102fd8:	6a 00                	push   $0x0
  pushl $233
c0102fda:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102fdf:	e9 08 01 00 00       	jmp    c01030ec <__alltraps>

c0102fe4 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102fe4:	6a 00                	push   $0x0
  pushl $234
c0102fe6:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102feb:	e9 fc 00 00 00       	jmp    c01030ec <__alltraps>

c0102ff0 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102ff0:	6a 00                	push   $0x0
  pushl $235
c0102ff2:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102ff7:	e9 f0 00 00 00       	jmp    c01030ec <__alltraps>

c0102ffc <vector236>:
.globl vector236
vector236:
  pushl $0
c0102ffc:	6a 00                	push   $0x0
  pushl $236
c0102ffe:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103003:	e9 e4 00 00 00       	jmp    c01030ec <__alltraps>

c0103008 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103008:	6a 00                	push   $0x0
  pushl $237
c010300a:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010300f:	e9 d8 00 00 00       	jmp    c01030ec <__alltraps>

c0103014 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103014:	6a 00                	push   $0x0
  pushl $238
c0103016:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010301b:	e9 cc 00 00 00       	jmp    c01030ec <__alltraps>

c0103020 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103020:	6a 00                	push   $0x0
  pushl $239
c0103022:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103027:	e9 c0 00 00 00       	jmp    c01030ec <__alltraps>

c010302c <vector240>:
.globl vector240
vector240:
  pushl $0
c010302c:	6a 00                	push   $0x0
  pushl $240
c010302e:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103033:	e9 b4 00 00 00       	jmp    c01030ec <__alltraps>

c0103038 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103038:	6a 00                	push   $0x0
  pushl $241
c010303a:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010303f:	e9 a8 00 00 00       	jmp    c01030ec <__alltraps>

c0103044 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103044:	6a 00                	push   $0x0
  pushl $242
c0103046:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010304b:	e9 9c 00 00 00       	jmp    c01030ec <__alltraps>

c0103050 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103050:	6a 00                	push   $0x0
  pushl $243
c0103052:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103057:	e9 90 00 00 00       	jmp    c01030ec <__alltraps>

c010305c <vector244>:
.globl vector244
vector244:
  pushl $0
c010305c:	6a 00                	push   $0x0
  pushl $244
c010305e:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103063:	e9 84 00 00 00       	jmp    c01030ec <__alltraps>

c0103068 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103068:	6a 00                	push   $0x0
  pushl $245
c010306a:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010306f:	e9 78 00 00 00       	jmp    c01030ec <__alltraps>

c0103074 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103074:	6a 00                	push   $0x0
  pushl $246
c0103076:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010307b:	e9 6c 00 00 00       	jmp    c01030ec <__alltraps>

c0103080 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103080:	6a 00                	push   $0x0
  pushl $247
c0103082:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103087:	e9 60 00 00 00       	jmp    c01030ec <__alltraps>

c010308c <vector248>:
.globl vector248
vector248:
  pushl $0
c010308c:	6a 00                	push   $0x0
  pushl $248
c010308e:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103093:	e9 54 00 00 00       	jmp    c01030ec <__alltraps>

c0103098 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103098:	6a 00                	push   $0x0
  pushl $249
c010309a:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010309f:	e9 48 00 00 00       	jmp    c01030ec <__alltraps>

c01030a4 <vector250>:
.globl vector250
vector250:
  pushl $0
c01030a4:	6a 00                	push   $0x0
  pushl $250
c01030a6:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01030ab:	e9 3c 00 00 00       	jmp    c01030ec <__alltraps>

c01030b0 <vector251>:
.globl vector251
vector251:
  pushl $0
c01030b0:	6a 00                	push   $0x0
  pushl $251
c01030b2:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01030b7:	e9 30 00 00 00       	jmp    c01030ec <__alltraps>

c01030bc <vector252>:
.globl vector252
vector252:
  pushl $0
c01030bc:	6a 00                	push   $0x0
  pushl $252
c01030be:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01030c3:	e9 24 00 00 00       	jmp    c01030ec <__alltraps>

c01030c8 <vector253>:
.globl vector253
vector253:
  pushl $0
c01030c8:	6a 00                	push   $0x0
  pushl $253
c01030ca:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01030cf:	e9 18 00 00 00       	jmp    c01030ec <__alltraps>

c01030d4 <vector254>:
.globl vector254
vector254:
  pushl $0
c01030d4:	6a 00                	push   $0x0
  pushl $254
c01030d6:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01030db:	e9 0c 00 00 00       	jmp    c01030ec <__alltraps>

c01030e0 <vector255>:
.globl vector255
vector255:
  pushl $0
c01030e0:	6a 00                	push   $0x0
  pushl $255
c01030e2:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01030e7:	e9 00 00 00 00       	jmp    c01030ec <__alltraps>

c01030ec <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01030ec:	1e                   	push   %ds
    pushl %es
c01030ed:	06                   	push   %es
    pushl %fs
c01030ee:	0f a0                	push   %fs
    pushl %gs
c01030f0:	0f a8                	push   %gs
    pushal
c01030f2:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01030f3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01030f8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01030fa:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01030fc:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01030fd:	e8 64 f5 ff ff       	call   c0102666 <trap>

    # pop the pushed stack pointer
    popl %esp
c0103102:	5c                   	pop    %esp

c0103103 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103103:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103104:	0f a9                	pop    %gs
    popl %fs
c0103106:	0f a1                	pop    %fs
    popl %es
c0103108:	07                   	pop    %es
    popl %ds
c0103109:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010310a:	83 c4 08             	add    $0x8,%esp
    iret
c010310d:	cf                   	iret   

c010310e <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c010310e:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0103112:	eb ef                	jmp    c0103103 <__trapret>

c0103114 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103114:	55                   	push   %ebp
c0103115:	89 e5                	mov    %esp,%ebp
c0103117:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010311a:	8b 45 08             	mov    0x8(%ebp),%eax
c010311d:	c1 e8 0c             	shr    $0xc,%eax
c0103120:	89 c2                	mov    %eax,%edx
c0103122:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0103127:	39 c2                	cmp    %eax,%edx
c0103129:	72 1c                	jb     c0103147 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010312b:	c7 44 24 08 f0 a0 10 	movl   $0xc010a0f0,0x8(%esp)
c0103132:	c0 
c0103133:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010313a:	00 
c010313b:	c7 04 24 0f a1 10 c0 	movl   $0xc010a10f,(%esp)
c0103142:	e8 b9 d2 ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c0103147:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c010314c:	8b 55 08             	mov    0x8(%ebp),%edx
c010314f:	c1 ea 0c             	shr    $0xc,%edx
c0103152:	c1 e2 05             	shl    $0x5,%edx
c0103155:	01 d0                	add    %edx,%eax
}
c0103157:	c9                   	leave  
c0103158:	c3                   	ret    

c0103159 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0103159:	55                   	push   %ebp
c010315a:	89 e5                	mov    %esp,%ebp
c010315c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010315f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103162:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103167:	89 04 24             	mov    %eax,(%esp)
c010316a:	e8 a5 ff ff ff       	call   c0103114 <pa2page>
}
c010316f:	c9                   	leave  
c0103170:	c3                   	ret    

c0103171 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0103171:	55                   	push   %ebp
c0103172:	89 e5                	mov    %esp,%ebp
c0103174:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103177:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010317e:	e8 f2 15 00 00       	call   c0104775 <kmalloc>
c0103183:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103186:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010318a:	74 58                	je     c01031e4 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c010318c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010318f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103192:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103195:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103198:	89 50 04             	mov    %edx,0x4(%eax)
c010319b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010319e:	8b 50 04             	mov    0x4(%eax),%edx
c01031a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031a4:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01031b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031b3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01031ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031bd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01031c4:	a1 68 7f 12 c0       	mov    0xc0127f68,%eax
c01031c9:	85 c0                	test   %eax,%eax
c01031cb:	74 0d                	je     c01031da <mm_create+0x69>
c01031cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031d0:	89 04 24             	mov    %eax,(%esp)
c01031d3:	e8 09 18 00 00       	call   c01049e1 <swap_init_mm>
c01031d8:	eb 0a                	jmp    c01031e4 <mm_create+0x73>
        else mm->sm_priv = NULL;
c01031da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031dd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01031e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01031e7:	c9                   	leave  
c01031e8:	c3                   	ret    

c01031e9 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01031e9:	55                   	push   %ebp
c01031ea:	89 e5                	mov    %esp,%ebp
c01031ec:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01031ef:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01031f6:	e8 7a 15 00 00       	call   c0104775 <kmalloc>
c01031fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01031fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103202:	74 1b                	je     c010321f <vma_create+0x36>
        vma->vm_start = vm_start;
c0103204:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103207:	8b 55 08             	mov    0x8(%ebp),%edx
c010320a:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010320d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103210:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103213:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0103216:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103219:	8b 55 10             	mov    0x10(%ebp),%edx
c010321c:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010321f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103222:	c9                   	leave  
c0103223:	c3                   	ret    

c0103224 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0103224:	55                   	push   %ebp
c0103225:	89 e5                	mov    %esp,%ebp
c0103227:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010322a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0103231:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103235:	0f 84 95 00 00 00    	je     c01032d0 <find_vma+0xac>
        vma = mm->mmap_cache;
c010323b:	8b 45 08             	mov    0x8(%ebp),%eax
c010323e:	8b 40 08             	mov    0x8(%eax),%eax
c0103241:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0103244:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103248:	74 16                	je     c0103260 <find_vma+0x3c>
c010324a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010324d:	8b 40 04             	mov    0x4(%eax),%eax
c0103250:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0103253:	72 0b                	jb     c0103260 <find_vma+0x3c>
c0103255:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103258:	8b 40 08             	mov    0x8(%eax),%eax
c010325b:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010325e:	72 61                	jb     c01032c1 <find_vma+0x9d>
                bool found = 0;
c0103260:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0103267:	8b 45 08             	mov    0x8(%ebp),%eax
c010326a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010326d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103270:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0103273:	eb 28                	jmp    c010329d <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0103275:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103278:	83 e8 10             	sub    $0x10,%eax
c010327b:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010327e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103281:	8b 40 04             	mov    0x4(%eax),%eax
c0103284:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0103287:	72 14                	jb     c010329d <find_vma+0x79>
c0103289:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010328c:	8b 40 08             	mov    0x8(%eax),%eax
c010328f:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0103292:	73 09                	jae    c010329d <find_vma+0x79>
                        found = 1;
c0103294:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c010329b:	eb 17                	jmp    c01032b4 <find_vma+0x90>
c010329d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01032a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032a6:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c01032a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01032ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032af:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01032b2:	75 c1                	jne    c0103275 <find_vma+0x51>
                    }
                }
                if (!found) {
c01032b4:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01032b8:	75 07                	jne    c01032c1 <find_vma+0x9d>
                    vma = NULL;
c01032ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01032c1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01032c5:	74 09                	je     c01032d0 <find_vma+0xac>
            mm->mmap_cache = vma;
c01032c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01032cd:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01032d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01032d3:	c9                   	leave  
c01032d4:	c3                   	ret    

c01032d5 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01032d5:	55                   	push   %ebp
c01032d6:	89 e5                	mov    %esp,%ebp
c01032d8:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01032db:	8b 45 08             	mov    0x8(%ebp),%eax
c01032de:	8b 50 04             	mov    0x4(%eax),%edx
c01032e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01032e4:	8b 40 08             	mov    0x8(%eax),%eax
c01032e7:	39 c2                	cmp    %eax,%edx
c01032e9:	72 24                	jb     c010330f <check_vma_overlap+0x3a>
c01032eb:	c7 44 24 0c 1d a1 10 	movl   $0xc010a11d,0xc(%esp)
c01032f2:	c0 
c01032f3:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c01032fa:	c0 
c01032fb:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0103302:	00 
c0103303:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c010330a:	e8 f1 d0 ff ff       	call   c0100400 <__panic>
    assert(prev->vm_end <= next->vm_start);
c010330f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103312:	8b 50 08             	mov    0x8(%eax),%edx
c0103315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103318:	8b 40 04             	mov    0x4(%eax),%eax
c010331b:	39 c2                	cmp    %eax,%edx
c010331d:	76 24                	jbe    c0103343 <check_vma_overlap+0x6e>
c010331f:	c7 44 24 0c 60 a1 10 	movl   $0xc010a160,0xc(%esp)
c0103326:	c0 
c0103327:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010332e:	c0 
c010332f:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0103336:	00 
c0103337:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c010333e:	e8 bd d0 ff ff       	call   c0100400 <__panic>
    assert(next->vm_start < next->vm_end);
c0103343:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103346:	8b 50 04             	mov    0x4(%eax),%edx
c0103349:	8b 45 0c             	mov    0xc(%ebp),%eax
c010334c:	8b 40 08             	mov    0x8(%eax),%eax
c010334f:	39 c2                	cmp    %eax,%edx
c0103351:	72 24                	jb     c0103377 <check_vma_overlap+0xa2>
c0103353:	c7 44 24 0c 7f a1 10 	movl   $0xc010a17f,0xc(%esp)
c010335a:	c0 
c010335b:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103362:	c0 
c0103363:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c010336a:	00 
c010336b:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103372:	e8 89 d0 ff ff       	call   c0100400 <__panic>
}
c0103377:	90                   	nop
c0103378:	c9                   	leave  
c0103379:	c3                   	ret    

c010337a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010337a:	55                   	push   %ebp
c010337b:	89 e5                	mov    %esp,%ebp
c010337d:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0103380:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103383:	8b 50 04             	mov    0x4(%eax),%edx
c0103386:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103389:	8b 40 08             	mov    0x8(%eax),%eax
c010338c:	39 c2                	cmp    %eax,%edx
c010338e:	72 24                	jb     c01033b4 <insert_vma_struct+0x3a>
c0103390:	c7 44 24 0c 9d a1 10 	movl   $0xc010a19d,0xc(%esp)
c0103397:	c0 
c0103398:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010339f:	c0 
c01033a0:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01033a7:	00 
c01033a8:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01033af:	e8 4c d0 ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01033b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01033ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01033c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01033c6:	eb 1f                	jmp    c01033e7 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01033c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033cb:	83 e8 10             	sub    $0x10,%eax
c01033ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01033d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033d4:	8b 50 04             	mov    0x4(%eax),%edx
c01033d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033da:	8b 40 04             	mov    0x4(%eax),%eax
c01033dd:	39 c2                	cmp    %eax,%edx
c01033df:	77 1f                	ja     c0103400 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01033e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01033ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033f0:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01033f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033f9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033fc:	75 ca                	jne    c01033c8 <insert_vma_struct+0x4e>
c01033fe:	eb 01                	jmp    c0103401 <insert_vma_struct+0x87>
                break;
c0103400:	90                   	nop
c0103401:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103404:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103407:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010340a:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c010340d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0103410:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103413:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103416:	74 15                	je     c010342d <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0103418:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010341b:	8d 50 f0             	lea    -0x10(%eax),%edx
c010341e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103421:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103425:	89 14 24             	mov    %edx,(%esp)
c0103428:	e8 a8 fe ff ff       	call   c01032d5 <check_vma_overlap>
    }
    if (le_next != list) {
c010342d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103430:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103433:	74 15                	je     c010344a <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0103435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103438:	83 e8 10             	sub    $0x10,%eax
c010343b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010343f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103442:	89 04 24             	mov    %eax,(%esp)
c0103445:	e8 8b fe ff ff       	call   c01032d5 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010344a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010344d:	8b 55 08             	mov    0x8(%ebp),%edx
c0103450:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0103452:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103455:	8d 50 10             	lea    0x10(%eax),%edx
c0103458:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010345b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010345e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103461:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103464:	8b 40 04             	mov    0x4(%eax),%eax
c0103467:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010346a:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010346d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103470:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103473:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103476:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103479:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010347c:	89 10                	mov    %edx,(%eax)
c010347e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103481:	8b 10                	mov    (%eax),%edx
c0103483:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103486:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103489:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010348c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010348f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103492:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103495:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103498:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010349a:	8b 45 08             	mov    0x8(%ebp),%eax
c010349d:	8b 40 10             	mov    0x10(%eax),%eax
c01034a0:	8d 50 01             	lea    0x1(%eax),%edx
c01034a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a6:	89 50 10             	mov    %edx,0x10(%eax)
}
c01034a9:	90                   	nop
c01034aa:	c9                   	leave  
c01034ab:	c3                   	ret    

c01034ac <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01034ac:	55                   	push   %ebp
c01034ad:	89 e5                	mov    %esp,%ebp
c01034af:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c01034b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01034b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01034b8:	eb 36                	jmp    c01034f0 <mm_destroy+0x44>
c01034ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01034c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034c3:	8b 40 04             	mov    0x4(%eax),%eax
c01034c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01034c9:	8b 12                	mov    (%edx),%edx
c01034cb:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01034ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01034d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01034d7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01034da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034dd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01034e0:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c01034e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034e5:	83 e8 10             	sub    $0x10,%eax
c01034e8:	89 04 24             	mov    %eax,(%esp)
c01034eb:	e8 a0 12 00 00       	call   c0104790 <kfree>
c01034f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01034f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034f9:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c01034fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103502:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103505:	75 b3                	jne    c01034ba <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
c0103507:	8b 45 08             	mov    0x8(%ebp),%eax
c010350a:	89 04 24             	mov    %eax,(%esp)
c010350d:	e8 7e 12 00 00       	call   c0104790 <kfree>
    mm=NULL;
c0103512:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0103519:	90                   	nop
c010351a:	c9                   	leave  
c010351b:	c3                   	ret    

c010351c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c010351c:	55                   	push   %ebp
c010351d:	89 e5                	mov    %esp,%ebp
c010351f:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103522:	e8 03 00 00 00       	call   c010352a <check_vmm>
}
c0103527:	90                   	nop
c0103528:	c9                   	leave  
c0103529:	c3                   	ret    

c010352a <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010352a:	55                   	push   %ebp
c010352b:	89 e5                	mov    %esp,%ebp
c010352d:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103530:	e8 4e 35 00 00       	call   c0106a83 <nr_free_pages>
c0103535:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0103538:	e8 14 00 00 00       	call   c0103551 <check_vma_struct>
    check_pgfault();
c010353d:	e8 a1 04 00 00       	call   c01039e3 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0103542:	c7 04 24 b9 a1 10 c0 	movl   $0xc010a1b9,(%esp)
c0103549:	e8 5b cd ff ff       	call   c01002a9 <cprintf>
}
c010354e:	90                   	nop
c010354f:	c9                   	leave  
c0103550:	c3                   	ret    

c0103551 <check_vma_struct>:

static void
check_vma_struct(void) {
c0103551:	55                   	push   %ebp
c0103552:	89 e5                	mov    %esp,%ebp
c0103554:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103557:	e8 27 35 00 00       	call   c0106a83 <nr_free_pages>
c010355c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c010355f:	e8 0d fc ff ff       	call   c0103171 <mm_create>
c0103564:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103567:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010356b:	75 24                	jne    c0103591 <check_vma_struct+0x40>
c010356d:	c7 44 24 0c d1 a1 10 	movl   $0xc010a1d1,0xc(%esp)
c0103574:	c0 
c0103575:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010357c:	c0 
c010357d:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0103584:	00 
c0103585:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c010358c:	e8 6f ce ff ff       	call   c0100400 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103591:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010359b:	89 d0                	mov    %edx,%eax
c010359d:	c1 e0 02             	shl    $0x2,%eax
c01035a0:	01 d0                	add    %edx,%eax
c01035a2:	01 c0                	add    %eax,%eax
c01035a4:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01035a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01035ad:	eb 6f                	jmp    c010361e <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01035af:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035b2:	89 d0                	mov    %edx,%eax
c01035b4:	c1 e0 02             	shl    $0x2,%eax
c01035b7:	01 d0                	add    %edx,%eax
c01035b9:	83 c0 02             	add    $0x2,%eax
c01035bc:	89 c1                	mov    %eax,%ecx
c01035be:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035c1:	89 d0                	mov    %edx,%eax
c01035c3:	c1 e0 02             	shl    $0x2,%eax
c01035c6:	01 d0                	add    %edx,%eax
c01035c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035cf:	00 
c01035d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01035d4:	89 04 24             	mov    %eax,(%esp)
c01035d7:	e8 0d fc ff ff       	call   c01031e9 <vma_create>
c01035dc:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c01035df:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01035e3:	75 24                	jne    c0103609 <check_vma_struct+0xb8>
c01035e5:	c7 44 24 0c dc a1 10 	movl   $0xc010a1dc,0xc(%esp)
c01035ec:	c0 
c01035ed:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c01035f4:	c0 
c01035f5:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c01035fc:	00 
c01035fd:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103604:	e8 f7 cd ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103609:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010360c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103610:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103613:	89 04 24             	mov    %eax,(%esp)
c0103616:	e8 5f fd ff ff       	call   c010337a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c010361b:	ff 4d f4             	decl   -0xc(%ebp)
c010361e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103622:	7f 8b                	jg     c01035af <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103627:	40                   	inc    %eax
c0103628:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010362b:	eb 6f                	jmp    c010369c <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010362d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103630:	89 d0                	mov    %edx,%eax
c0103632:	c1 e0 02             	shl    $0x2,%eax
c0103635:	01 d0                	add    %edx,%eax
c0103637:	83 c0 02             	add    $0x2,%eax
c010363a:	89 c1                	mov    %eax,%ecx
c010363c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010363f:	89 d0                	mov    %edx,%eax
c0103641:	c1 e0 02             	shl    $0x2,%eax
c0103644:	01 d0                	add    %edx,%eax
c0103646:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010364d:	00 
c010364e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103652:	89 04 24             	mov    %eax,(%esp)
c0103655:	e8 8f fb ff ff       	call   c01031e9 <vma_create>
c010365a:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c010365d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0103661:	75 24                	jne    c0103687 <check_vma_struct+0x136>
c0103663:	c7 44 24 0c dc a1 10 	movl   $0xc010a1dc,0xc(%esp)
c010366a:	c0 
c010366b:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103672:	c0 
c0103673:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c010367a:	00 
c010367b:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103682:	e8 79 cd ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103687:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010368a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010368e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103691:	89 04 24             	mov    %eax,(%esp)
c0103694:	e8 e1 fc ff ff       	call   c010337a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0103699:	ff 45 f4             	incl   -0xc(%ebp)
c010369c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010369f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01036a2:	7e 89                	jle    c010362d <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01036a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036a7:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01036aa:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01036ad:	8b 40 04             	mov    0x4(%eax),%eax
c01036b0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01036b3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01036ba:	e9 96 00 00 00       	jmp    c0103755 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c01036bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036c2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01036c5:	75 24                	jne    c01036eb <check_vma_struct+0x19a>
c01036c7:	c7 44 24 0c e8 a1 10 	movl   $0xc010a1e8,0xc(%esp)
c01036ce:	c0 
c01036cf:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c01036d6:	c0 
c01036d7:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01036de:	00 
c01036df:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01036e6:	e8 15 cd ff ff       	call   c0100400 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01036eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036ee:	83 e8 10             	sub    $0x10,%eax
c01036f1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01036f4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036f7:	8b 48 04             	mov    0x4(%eax),%ecx
c01036fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036fd:	89 d0                	mov    %edx,%eax
c01036ff:	c1 e0 02             	shl    $0x2,%eax
c0103702:	01 d0                	add    %edx,%eax
c0103704:	39 c1                	cmp    %eax,%ecx
c0103706:	75 17                	jne    c010371f <check_vma_struct+0x1ce>
c0103708:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010370b:	8b 48 08             	mov    0x8(%eax),%ecx
c010370e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103711:	89 d0                	mov    %edx,%eax
c0103713:	c1 e0 02             	shl    $0x2,%eax
c0103716:	01 d0                	add    %edx,%eax
c0103718:	83 c0 02             	add    $0x2,%eax
c010371b:	39 c1                	cmp    %eax,%ecx
c010371d:	74 24                	je     c0103743 <check_vma_struct+0x1f2>
c010371f:	c7 44 24 0c 00 a2 10 	movl   $0xc010a200,0xc(%esp)
c0103726:	c0 
c0103727:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010372e:	c0 
c010372f:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0103736:	00 
c0103737:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c010373e:	e8 bd cc ff ff       	call   c0100400 <__panic>
c0103743:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103746:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103749:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010374c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010374f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0103752:	ff 45 f4             	incl   -0xc(%ebp)
c0103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103758:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010375b:	0f 8e 5e ff ff ff    	jle    c01036bf <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103761:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103768:	e9 cb 01 00 00       	jmp    c0103938 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c010376d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103770:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103774:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103777:	89 04 24             	mov    %eax,(%esp)
c010377a:	e8 a5 fa ff ff       	call   c0103224 <find_vma>
c010377f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0103782:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103786:	75 24                	jne    c01037ac <check_vma_struct+0x25b>
c0103788:	c7 44 24 0c 35 a2 10 	movl   $0xc010a235,0xc(%esp)
c010378f:	c0 
c0103790:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103797:	c0 
c0103798:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010379f:	00 
c01037a0:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01037a7:	e8 54 cc ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01037ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037af:	40                   	inc    %eax
c01037b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037b7:	89 04 24             	mov    %eax,(%esp)
c01037ba:	e8 65 fa ff ff       	call   c0103224 <find_vma>
c01037bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c01037c2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01037c6:	75 24                	jne    c01037ec <check_vma_struct+0x29b>
c01037c8:	c7 44 24 0c 42 a2 10 	movl   $0xc010a242,0xc(%esp)
c01037cf:	c0 
c01037d0:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c01037d7:	c0 
c01037d8:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c01037df:	00 
c01037e0:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01037e7:	e8 14 cc ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c01037ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037ef:	83 c0 02             	add    $0x2,%eax
c01037f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037f9:	89 04 24             	mov    %eax,(%esp)
c01037fc:	e8 23 fa ff ff       	call   c0103224 <find_vma>
c0103801:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0103804:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103808:	74 24                	je     c010382e <check_vma_struct+0x2dd>
c010380a:	c7 44 24 0c 4f a2 10 	movl   $0xc010a24f,0xc(%esp)
c0103811:	c0 
c0103812:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103819:	c0 
c010381a:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103821:	00 
c0103822:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103829:	e8 d2 cb ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c010382e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103831:	83 c0 03             	add    $0x3,%eax
c0103834:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103838:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010383b:	89 04 24             	mov    %eax,(%esp)
c010383e:	e8 e1 f9 ff ff       	call   c0103224 <find_vma>
c0103843:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0103846:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010384a:	74 24                	je     c0103870 <check_vma_struct+0x31f>
c010384c:	c7 44 24 0c 5c a2 10 	movl   $0xc010a25c,0xc(%esp)
c0103853:	c0 
c0103854:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010385b:	c0 
c010385c:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0103863:	00 
c0103864:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c010386b:	e8 90 cb ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0103870:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103873:	83 c0 04             	add    $0x4,%eax
c0103876:	89 44 24 04          	mov    %eax,0x4(%esp)
c010387a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010387d:	89 04 24             	mov    %eax,(%esp)
c0103880:	e8 9f f9 ff ff       	call   c0103224 <find_vma>
c0103885:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0103888:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010388c:	74 24                	je     c01038b2 <check_vma_struct+0x361>
c010388e:	c7 44 24 0c 69 a2 10 	movl   $0xc010a269,0xc(%esp)
c0103895:	c0 
c0103896:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010389d:	c0 
c010389e:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01038a5:	00 
c01038a6:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01038ad:	e8 4e cb ff ff       	call   c0100400 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01038b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038b5:	8b 50 04             	mov    0x4(%eax),%edx
c01038b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038bb:	39 c2                	cmp    %eax,%edx
c01038bd:	75 10                	jne    c01038cf <check_vma_struct+0x37e>
c01038bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038c2:	8b 40 08             	mov    0x8(%eax),%eax
c01038c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038c8:	83 c2 02             	add    $0x2,%edx
c01038cb:	39 d0                	cmp    %edx,%eax
c01038cd:	74 24                	je     c01038f3 <check_vma_struct+0x3a2>
c01038cf:	c7 44 24 0c 78 a2 10 	movl   $0xc010a278,0xc(%esp)
c01038d6:	c0 
c01038d7:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c01038de:	c0 
c01038df:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01038e6:	00 
c01038e7:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01038ee:	e8 0d cb ff ff       	call   c0100400 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01038f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038f6:	8b 50 04             	mov    0x4(%eax),%edx
c01038f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038fc:	39 c2                	cmp    %eax,%edx
c01038fe:	75 10                	jne    c0103910 <check_vma_struct+0x3bf>
c0103900:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103903:	8b 40 08             	mov    0x8(%eax),%eax
c0103906:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103909:	83 c2 02             	add    $0x2,%edx
c010390c:	39 d0                	cmp    %edx,%eax
c010390e:	74 24                	je     c0103934 <check_vma_struct+0x3e3>
c0103910:	c7 44 24 0c a8 a2 10 	movl   $0xc010a2a8,0xc(%esp)
c0103917:	c0 
c0103918:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c010391f:	c0 
c0103920:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103927:	00 
c0103928:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c010392f:	e8 cc ca ff ff       	call   c0100400 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0103934:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0103938:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010393b:	89 d0                	mov    %edx,%eax
c010393d:	c1 e0 02             	shl    $0x2,%eax
c0103940:	01 d0                	add    %edx,%eax
c0103942:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103945:	0f 8e 22 fe ff ff    	jle    c010376d <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c010394b:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0103952:	eb 6f                	jmp    c01039c3 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0103954:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103957:	89 44 24 04          	mov    %eax,0x4(%esp)
c010395b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010395e:	89 04 24             	mov    %eax,(%esp)
c0103961:	e8 be f8 ff ff       	call   c0103224 <find_vma>
c0103966:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0103969:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010396d:	74 27                	je     c0103996 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c010396f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103972:	8b 50 08             	mov    0x8(%eax),%edx
c0103975:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103978:	8b 40 04             	mov    0x4(%eax),%eax
c010397b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010397f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103983:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103986:	89 44 24 04          	mov    %eax,0x4(%esp)
c010398a:	c7 04 24 d8 a2 10 c0 	movl   $0xc010a2d8,(%esp)
c0103991:	e8 13 c9 ff ff       	call   c01002a9 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0103996:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010399a:	74 24                	je     c01039c0 <check_vma_struct+0x46f>
c010399c:	c7 44 24 0c fd a2 10 	movl   $0xc010a2fd,0xc(%esp)
c01039a3:	c0 
c01039a4:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c01039ab:	c0 
c01039ac:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c01039b3:	00 
c01039b4:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c01039bb:	e8 40 ca ff ff       	call   c0100400 <__panic>
    for (i =4; i>=0; i--) {
c01039c0:	ff 4d f4             	decl   -0xc(%ebp)
c01039c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039c7:	79 8b                	jns    c0103954 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c01039c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039cc:	89 04 24             	mov    %eax,(%esp)
c01039cf:	e8 d8 fa ff ff       	call   c01034ac <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c01039d4:	c7 04 24 14 a3 10 c0 	movl   $0xc010a314,(%esp)
c01039db:	e8 c9 c8 ff ff       	call   c01002a9 <cprintf>
}
c01039e0:	90                   	nop
c01039e1:	c9                   	leave  
c01039e2:	c3                   	ret    

c01039e3 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c01039e3:	55                   	push   %ebp
c01039e4:	89 e5                	mov    %esp,%ebp
c01039e6:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01039e9:	e8 95 30 00 00       	call   c0106a83 <nr_free_pages>
c01039ee:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c01039f1:	e8 7b f7 ff ff       	call   c0103171 <mm_create>
c01039f6:	a3 58 a0 12 c0       	mov    %eax,0xc012a058
    assert(check_mm_struct != NULL);
c01039fb:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0103a00:	85 c0                	test   %eax,%eax
c0103a02:	75 24                	jne    c0103a28 <check_pgfault+0x45>
c0103a04:	c7 44 24 0c 33 a3 10 	movl   $0xc010a333,0xc(%esp)
c0103a0b:	c0 
c0103a0c:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103a13:	c0 
c0103a14:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103a1b:	00 
c0103a1c:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103a23:	e8 d8 c9 ff ff       	call   c0100400 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103a28:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0103a2d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103a30:	8b 15 20 4a 12 c0    	mov    0xc0124a20,%edx
c0103a36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a39:	89 50 0c             	mov    %edx,0xc(%eax)
c0103a3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a3f:	8b 40 0c             	mov    0xc(%eax),%eax
c0103a42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a48:	8b 00                	mov    (%eax),%eax
c0103a4a:	85 c0                	test   %eax,%eax
c0103a4c:	74 24                	je     c0103a72 <check_pgfault+0x8f>
c0103a4e:	c7 44 24 0c 4b a3 10 	movl   $0xc010a34b,0xc(%esp)
c0103a55:	c0 
c0103a56:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103a5d:	c0 
c0103a5e:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0103a65:	00 
c0103a66:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103a6d:	e8 8e c9 ff ff       	call   c0100400 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103a72:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0103a79:	00 
c0103a7a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0103a81:	00 
c0103a82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0103a89:	e8 5b f7 ff ff       	call   c01031e9 <vma_create>
c0103a8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103a91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103a95:	75 24                	jne    c0103abb <check_pgfault+0xd8>
c0103a97:	c7 44 24 0c dc a1 10 	movl   $0xc010a1dc,0xc(%esp)
c0103a9e:	c0 
c0103a9f:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103aa6:	c0 
c0103aa7:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103aae:	00 
c0103aaf:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103ab6:	e8 45 c9 ff ff       	call   c0100400 <__panic>

    insert_vma_struct(mm, vma);
c0103abb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103abe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ac2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ac5:	89 04 24             	mov    %eax,(%esp)
c0103ac8:	e8 ad f8 ff ff       	call   c010337a <insert_vma_struct>

    uintptr_t addr = 0x100;
c0103acd:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103ad4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103adb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ade:	89 04 24             	mov    %eax,(%esp)
c0103ae1:	e8 3e f7 ff ff       	call   c0103224 <find_vma>
c0103ae6:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103ae9:	74 24                	je     c0103b0f <check_pgfault+0x12c>
c0103aeb:	c7 44 24 0c 59 a3 10 	movl   $0xc010a359,0xc(%esp)
c0103af2:	c0 
c0103af3:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103afa:	c0 
c0103afb:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0103b02:	00 
c0103b03:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103b0a:	e8 f1 c8 ff ff       	call   c0100400 <__panic>

    int i, sum = 0;
c0103b0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103b16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b1d:	eb 16                	jmp    c0103b35 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0103b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b22:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b25:	01 d0                	add    %edx,%eax
c0103b27:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b2a:	88 10                	mov    %dl,(%eax)
        sum += i;
c0103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b2f:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103b32:	ff 45 f4             	incl   -0xc(%ebp)
c0103b35:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103b39:	7e e4                	jle    c0103b1f <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0103b3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b42:	eb 14                	jmp    c0103b58 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0103b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b47:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b4a:	01 d0                	add    %edx,%eax
c0103b4c:	0f b6 00             	movzbl (%eax),%eax
c0103b4f:	0f be c0             	movsbl %al,%eax
c0103b52:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103b55:	ff 45 f4             	incl   -0xc(%ebp)
c0103b58:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103b5c:	7e e6                	jle    c0103b44 <check_pgfault+0x161>
    }
    assert(sum == 0);
c0103b5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b62:	74 24                	je     c0103b88 <check_pgfault+0x1a5>
c0103b64:	c7 44 24 0c 73 a3 10 	movl   $0xc010a373,0xc(%esp)
c0103b6b:	c0 
c0103b6c:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103b73:	c0 
c0103b74:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0103b7b:	00 
c0103b7c:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103b83:	e8 78 c8 ff ff       	call   c0100400 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103b88:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103b8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103b91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b9d:	89 04 24             	mov    %eax,(%esp)
c0103ba0:	e8 0f 37 00 00       	call   c01072b4 <page_remove>
    free_page(pde2page(pgdir[0]));
c0103ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ba8:	8b 00                	mov    (%eax),%eax
c0103baa:	89 04 24             	mov    %eax,(%esp)
c0103bad:	e8 a7 f5 ff ff       	call   c0103159 <pde2page>
c0103bb2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103bb9:	00 
c0103bba:	89 04 24             	mov    %eax,(%esp)
c0103bbd:	e8 8e 2e 00 00       	call   c0106a50 <free_pages>
    pgdir[0] = 0;
c0103bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103bcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103bd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bd8:	89 04 24             	mov    %eax,(%esp)
c0103bdb:	e8 cc f8 ff ff       	call   c01034ac <mm_destroy>
    check_mm_struct = NULL;
c0103be0:	c7 05 58 a0 12 c0 00 	movl   $0x0,0xc012a058
c0103be7:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103bea:	e8 94 2e 00 00       	call   c0106a83 <nr_free_pages>
c0103bef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103bf2:	74 24                	je     c0103c18 <check_pgfault+0x235>
c0103bf4:	c7 44 24 0c 7c a3 10 	movl   $0xc010a37c,0xc(%esp)
c0103bfb:	c0 
c0103bfc:	c7 44 24 08 3b a1 10 	movl   $0xc010a13b,0x8(%esp)
c0103c03:	c0 
c0103c04:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103c0b:	00 
c0103c0c:	c7 04 24 50 a1 10 c0 	movl   $0xc010a150,(%esp)
c0103c13:	e8 e8 c7 ff ff       	call   c0100400 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103c18:	c7 04 24 a3 a3 10 c0 	movl   $0xc010a3a3,(%esp)
c0103c1f:	e8 85 c6 ff ff       	call   c01002a9 <cprintf>
}
c0103c24:	90                   	nop
c0103c25:	c9                   	leave  
c0103c26:	c3                   	ret    

c0103c27 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103c27:	55                   	push   %ebp
c0103c28:	89 e5                	mov    %esp,%ebp
c0103c2a:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0103c2d:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103c34:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c3e:	89 04 24             	mov    %eax,(%esp)
c0103c41:	e8 de f5 ff ff       	call   c0103224 <find_vma>
c0103c46:	89 45 f0             	mov    %eax,-0x10(%ebp)

    pgfault_num++;
c0103c49:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103c4e:	40                   	inc    %eax
c0103c4f:	a3 60 7f 12 c0       	mov    %eax,0xc0127f60
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103c54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c58:	74 0b                	je     c0103c65 <do_pgfault+0x3e>
c0103c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c5d:	8b 40 04             	mov    0x4(%eax),%eax
c0103c60:	39 45 10             	cmp    %eax,0x10(%ebp)
c0103c63:	73 18                	jae    c0103c7d <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103c65:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c6c:	c7 04 24 c0 a3 10 c0 	movl   $0xc010a3c0,(%esp)
c0103c73:	e8 31 c6 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103c78:	e9 92 00 00 00       	jmp    c0103d0f <do_pgfault+0xe8>
    }
    //check the error_code
    switch (error_code & 3) {
c0103c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c80:	83 e0 03             	and    $0x3,%eax
c0103c83:	85 c0                	test   %eax,%eax
c0103c85:	74 2e                	je     c0103cb5 <do_pgfault+0x8e>
c0103c87:	83 f8 01             	cmp    $0x1,%eax
c0103c8a:	74 1b                	je     c0103ca7 <do_pgfault+0x80>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c8f:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c92:	83 e0 02             	and    $0x2,%eax
c0103c95:	85 c0                	test   %eax,%eax
c0103c97:	75 37                	jne    c0103cd0 <do_pgfault+0xa9>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103c99:	c7 04 24 f0 a3 10 c0 	movl   $0xc010a3f0,(%esp)
c0103ca0:	e8 04 c6 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103ca5:	eb 68                	jmp    c0103d0f <do_pgfault+0xe8>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103ca7:	c7 04 24 50 a4 10 c0 	movl   $0xc010a450,(%esp)
c0103cae:	e8 f6 c5 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103cb3:	eb 5a                	jmp    c0103d0f <do_pgfault+0xe8>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cb8:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cbb:	83 e0 05             	and    $0x5,%eax
c0103cbe:	85 c0                	test   %eax,%eax
c0103cc0:	75 0f                	jne    c0103cd1 <do_pgfault+0xaa>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103cc2:	c7 04 24 88 a4 10 c0 	movl   $0xc010a488,(%esp)
c0103cc9:	e8 db c5 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103cce:	eb 3f                	jmp    c0103d0f <do_pgfault+0xe8>
        break;
c0103cd0:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103cd1:	c7 45 ec 04 00 00 00 	movl   $0x4,-0x14(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cdb:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cde:	83 e0 02             	and    $0x2,%eax
c0103ce1:	85 c0                	test   %eax,%eax
c0103ce3:	74 04                	je     c0103ce9 <do_pgfault+0xc2>
        perm |= PTE_W;
c0103ce5:	83 4d ec 02          	orl    $0x2,-0x14(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103ce9:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103cef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103cf2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cf7:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103cfa:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103d01:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
   ret = 0;
c0103d08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0103d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103d12:	c9                   	leave  
c0103d13:	c3                   	ret    

c0103d14 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0103d14:	55                   	push   %ebp
c0103d15:	89 e5                	mov    %esp,%ebp
c0103d17:	83 ec 10             	sub    $0x10,%esp
c0103d1a:	c7 45 fc 5c a0 12 c0 	movl   $0xc012a05c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0103d21:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d24:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103d27:	89 50 04             	mov    %edx,0x4(%eax)
c0103d2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d2d:	8b 50 04             	mov    0x4(%eax),%edx
c0103d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d33:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0103d35:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d38:	c7 40 14 5c a0 12 c0 	movl   $0xc012a05c,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0103d3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103d44:	c9                   	leave  
c0103d45:	c3                   	ret    

c0103d46 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0103d46:	55                   	push   %ebp
c0103d47:	89 e5                	mov    %esp,%ebp
c0103d49:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103d4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d4f:	8b 40 14             	mov    0x14(%eax),%eax
c0103d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0103d55:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d58:	83 c0 14             	add    $0x14,%eax
c0103d5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0103d5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d62:	74 06                	je     c0103d6a <_fifo_map_swappable+0x24>
c0103d64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d68:	75 24                	jne    c0103d8e <_fifo_map_swappable+0x48>
c0103d6a:	c7 44 24 0c ec a4 10 	movl   $0xc010a4ec,0xc(%esp)
c0103d71:	c0 
c0103d72:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103d79:	c0 
c0103d7a:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0103d81:	00 
c0103d82:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103d89:	e8 72 c6 ff ff       	call   c0100400 <__panic>
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    return 0;
c0103d8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103d93:	c9                   	leave  
c0103d94:	c3                   	ret    

c0103d95 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0103d95:	55                   	push   %ebp
c0103d96:	89 e5                	mov    %esp,%ebp
c0103d98:	83 ec 28             	sub    $0x28,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103d9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d9e:	8b 40 14             	mov    0x14(%eax),%eax
c0103da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0103da4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103da8:	75 24                	jne    c0103dce <_fifo_swap_out_victim+0x39>
c0103daa:	c7 44 24 0c 33 a5 10 	movl   $0xc010a533,0xc(%esp)
c0103db1:	c0 
c0103db2:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103db9:	c0 
c0103dba:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
c0103dc1:	00 
c0103dc2:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103dc9:	e8 32 c6 ff ff       	call   c0100400 <__panic>
     assert(in_tick==0);
c0103dce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103dd2:	74 24                	je     c0103df8 <_fifo_swap_out_victim+0x63>
c0103dd4:	c7 44 24 0c 40 a5 10 	movl   $0xc010a540,0xc(%esp)
c0103ddb:	c0 
c0103ddc:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103de3:	c0 
c0103de4:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0103deb:	00 
c0103dec:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103df3:	e8 08 c6 ff ff       	call   c0100400 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     return 0;
c0103df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103dfd:	c9                   	leave  
c0103dfe:	c3                   	ret    

c0103dff <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0103dff:	55                   	push   %ebp
c0103e00:	89 e5                	mov    %esp,%ebp
c0103e02:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0103e05:	c7 04 24 4c a5 10 c0 	movl   $0xc010a54c,(%esp)
c0103e0c:	e8 98 c4 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0103e11:	b8 00 30 00 00       	mov    $0x3000,%eax
c0103e16:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0103e19:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103e1e:	83 f8 04             	cmp    $0x4,%eax
c0103e21:	74 24                	je     c0103e47 <_fifo_check_swap+0x48>
c0103e23:	c7 44 24 0c 72 a5 10 	movl   $0xc010a572,0xc(%esp)
c0103e2a:	c0 
c0103e2b:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103e32:	c0 
c0103e33:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
c0103e3a:	00 
c0103e3b:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103e42:	e8 b9 c5 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0103e47:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0103e4e:	e8 56 c4 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0103e53:	b8 00 10 00 00       	mov    $0x1000,%eax
c0103e58:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0103e5b:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103e60:	83 f8 04             	cmp    $0x4,%eax
c0103e63:	74 24                	je     c0103e89 <_fifo_check_swap+0x8a>
c0103e65:	c7 44 24 0c 72 a5 10 	movl   $0xc010a572,0xc(%esp)
c0103e6c:	c0 
c0103e6d:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103e74:	c0 
c0103e75:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c0103e7c:	00 
c0103e7d:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103e84:	e8 77 c5 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0103e89:	c7 04 24 ac a5 10 c0 	movl   $0xc010a5ac,(%esp)
c0103e90:	e8 14 c4 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0103e95:	b8 00 40 00 00       	mov    $0x4000,%eax
c0103e9a:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0103e9d:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103ea2:	83 f8 04             	cmp    $0x4,%eax
c0103ea5:	74 24                	je     c0103ecb <_fifo_check_swap+0xcc>
c0103ea7:	c7 44 24 0c 72 a5 10 	movl   $0xc010a572,0xc(%esp)
c0103eae:	c0 
c0103eaf:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103eb6:	c0 
c0103eb7:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
c0103ebe:	00 
c0103ebf:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103ec6:	e8 35 c5 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0103ecb:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0103ed2:	e8 d2 c3 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0103ed7:	b8 00 20 00 00       	mov    $0x2000,%eax
c0103edc:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0103edf:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103ee4:	83 f8 04             	cmp    $0x4,%eax
c0103ee7:	74 24                	je     c0103f0d <_fifo_check_swap+0x10e>
c0103ee9:	c7 44 24 0c 72 a5 10 	movl   $0xc010a572,0xc(%esp)
c0103ef0:	c0 
c0103ef1:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103ef8:	c0 
c0103ef9:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c0103f00:	00 
c0103f01:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103f08:	e8 f3 c4 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0103f0d:	c7 04 24 fc a5 10 c0 	movl   $0xc010a5fc,(%esp)
c0103f14:	e8 90 c3 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0103f19:	b8 00 50 00 00       	mov    $0x5000,%eax
c0103f1e:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0103f21:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103f26:	83 f8 05             	cmp    $0x5,%eax
c0103f29:	74 24                	je     c0103f4f <_fifo_check_swap+0x150>
c0103f2b:	c7 44 24 0c 22 a6 10 	movl   $0xc010a622,0xc(%esp)
c0103f32:	c0 
c0103f33:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103f3a:	c0 
c0103f3b:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c0103f42:	00 
c0103f43:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103f4a:	e8 b1 c4 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0103f4f:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0103f56:	e8 4e c3 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0103f5b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0103f60:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0103f63:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103f68:	83 f8 05             	cmp    $0x5,%eax
c0103f6b:	74 24                	je     c0103f91 <_fifo_check_swap+0x192>
c0103f6d:	c7 44 24 0c 22 a6 10 	movl   $0xc010a622,0xc(%esp)
c0103f74:	c0 
c0103f75:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103f7c:	c0 
c0103f7d:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0103f84:	00 
c0103f85:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103f8c:	e8 6f c4 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0103f91:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0103f98:	e8 0c c3 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0103f9d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0103fa2:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0103fa5:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103faa:	83 f8 06             	cmp    $0x6,%eax
c0103fad:	74 24                	je     c0103fd3 <_fifo_check_swap+0x1d4>
c0103faf:	c7 44 24 0c 31 a6 10 	movl   $0xc010a631,0xc(%esp)
c0103fb6:	c0 
c0103fb7:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0103fbe:	c0 
c0103fbf:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0103fc6:	00 
c0103fc7:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0103fce:	e8 2d c4 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0103fd3:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0103fda:	e8 ca c2 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0103fdf:	b8 00 20 00 00       	mov    $0x2000,%eax
c0103fe4:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0103fe7:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0103fec:	83 f8 07             	cmp    $0x7,%eax
c0103fef:	74 24                	je     c0104015 <_fifo_check_swap+0x216>
c0103ff1:	c7 44 24 0c 40 a6 10 	movl   $0xc010a640,0xc(%esp)
c0103ff8:	c0 
c0103ff9:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0104000:	c0 
c0104001:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0104008:	00 
c0104009:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0104010:	e8 eb c3 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104015:	c7 04 24 4c a5 10 c0 	movl   $0xc010a54c,(%esp)
c010401c:	e8 88 c2 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104021:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104026:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104029:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c010402e:	83 f8 08             	cmp    $0x8,%eax
c0104031:	74 24                	je     c0104057 <_fifo_check_swap+0x258>
c0104033:	c7 44 24 0c 4f a6 10 	movl   $0xc010a64f,0xc(%esp)
c010403a:	c0 
c010403b:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0104042:	c0 
c0104043:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010404a:	00 
c010404b:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0104052:	e8 a9 c3 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104057:	c7 04 24 ac a5 10 c0 	movl   $0xc010a5ac,(%esp)
c010405e:	e8 46 c2 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104063:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104068:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c010406b:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104070:	83 f8 09             	cmp    $0x9,%eax
c0104073:	74 24                	je     c0104099 <_fifo_check_swap+0x29a>
c0104075:	c7 44 24 0c 5e a6 10 	movl   $0xc010a65e,0xc(%esp)
c010407c:	c0 
c010407d:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0104084:	c0 
c0104085:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c010408c:	00 
c010408d:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0104094:	e8 67 c3 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104099:	c7 04 24 fc a5 10 c0 	movl   $0xc010a5fc,(%esp)
c01040a0:	e8 04 c2 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01040a5:	b8 00 50 00 00       	mov    $0x5000,%eax
c01040aa:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01040ad:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c01040b2:	83 f8 0a             	cmp    $0xa,%eax
c01040b5:	74 24                	je     c01040db <_fifo_check_swap+0x2dc>
c01040b7:	c7 44 24 0c 6d a6 10 	movl   $0xc010a66d,0xc(%esp)
c01040be:	c0 
c01040bf:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c01040c6:	c0 
c01040c7:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01040ce:	00 
c01040cf:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c01040d6:	e8 25 c3 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01040db:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c01040e2:	e8 c2 c1 ff ff       	call   c01002a9 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01040e7:	b8 00 10 00 00       	mov    $0x1000,%eax
c01040ec:	0f b6 00             	movzbl (%eax),%eax
c01040ef:	3c 0a                	cmp    $0xa,%al
c01040f1:	74 24                	je     c0104117 <_fifo_check_swap+0x318>
c01040f3:	c7 44 24 0c 80 a6 10 	movl   $0xc010a680,0xc(%esp)
c01040fa:	c0 
c01040fb:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0104102:	c0 
c0104103:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010410a:	00 
c010410b:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0104112:	e8 e9 c2 ff ff       	call   c0100400 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104117:	b8 00 10 00 00       	mov    $0x1000,%eax
c010411c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c010411f:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104124:	83 f8 0b             	cmp    $0xb,%eax
c0104127:	74 24                	je     c010414d <_fifo_check_swap+0x34e>
c0104129:	c7 44 24 0c a1 a6 10 	movl   $0xc010a6a1,0xc(%esp)
c0104130:	c0 
c0104131:	c7 44 24 08 0a a5 10 	movl   $0xc010a50a,0x8(%esp)
c0104138:	c0 
c0104139:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0104140:	00 
c0104141:	c7 04 24 1f a5 10 c0 	movl   $0xc010a51f,(%esp)
c0104148:	e8 b3 c2 ff ff       	call   c0100400 <__panic>
    return 0;
c010414d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104152:	c9                   	leave  
c0104153:	c3                   	ret    

c0104154 <_fifo_init>:


static int
_fifo_init(void)
{
c0104154:	55                   	push   %ebp
c0104155:	89 e5                	mov    %esp,%ebp
    return 0;
c0104157:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010415c:	5d                   	pop    %ebp
c010415d:	c3                   	ret    

c010415e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010415e:	55                   	push   %ebp
c010415f:	89 e5                	mov    %esp,%ebp
    return 0;
c0104161:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104166:	5d                   	pop    %ebp
c0104167:	c3                   	ret    

c0104168 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104168:	55                   	push   %ebp
c0104169:	89 e5                	mov    %esp,%ebp
c010416b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104170:	5d                   	pop    %ebp
c0104171:	c3                   	ret    

c0104172 <__intr_save>:
__intr_save(void) {
c0104172:	55                   	push   %ebp
c0104173:	89 e5                	mov    %esp,%ebp
c0104175:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104178:	9c                   	pushf  
c0104179:	58                   	pop    %eax
c010417a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010417d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104180:	25 00 02 00 00       	and    $0x200,%eax
c0104185:	85 c0                	test   %eax,%eax
c0104187:	74 0c                	je     c0104195 <__intr_save+0x23>
        intr_disable();
c0104189:	e8 5a df ff ff       	call   c01020e8 <intr_disable>
        return 1;
c010418e:	b8 01 00 00 00       	mov    $0x1,%eax
c0104193:	eb 05                	jmp    c010419a <__intr_save+0x28>
    return 0;
c0104195:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010419a:	c9                   	leave  
c010419b:	c3                   	ret    

c010419c <__intr_restore>:
__intr_restore(bool flag) {
c010419c:	55                   	push   %ebp
c010419d:	89 e5                	mov    %esp,%ebp
c010419f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01041a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01041a6:	74 05                	je     c01041ad <__intr_restore+0x11>
        intr_enable();
c01041a8:	e8 34 df ff ff       	call   c01020e1 <intr_enable>
}
c01041ad:	90                   	nop
c01041ae:	c9                   	leave  
c01041af:	c3                   	ret    

c01041b0 <page2ppn>:
page2ppn(struct Page *page) {
c01041b0:	55                   	push   %ebp
c01041b1:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01041b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01041b6:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01041bc:	29 d0                	sub    %edx,%eax
c01041be:	c1 f8 05             	sar    $0x5,%eax
}
c01041c1:	5d                   	pop    %ebp
c01041c2:	c3                   	ret    

c01041c3 <page2pa>:
page2pa(struct Page *page) {
c01041c3:	55                   	push   %ebp
c01041c4:	89 e5                	mov    %esp,%ebp
c01041c6:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01041c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01041cc:	89 04 24             	mov    %eax,(%esp)
c01041cf:	e8 dc ff ff ff       	call   c01041b0 <page2ppn>
c01041d4:	c1 e0 0c             	shl    $0xc,%eax
}
c01041d7:	c9                   	leave  
c01041d8:	c3                   	ret    

c01041d9 <pa2page>:
pa2page(uintptr_t pa) {
c01041d9:	55                   	push   %ebp
c01041da:	89 e5                	mov    %esp,%ebp
c01041dc:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01041df:	8b 45 08             	mov    0x8(%ebp),%eax
c01041e2:	c1 e8 0c             	shr    $0xc,%eax
c01041e5:	89 c2                	mov    %eax,%edx
c01041e7:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01041ec:	39 c2                	cmp    %eax,%edx
c01041ee:	72 1c                	jb     c010420c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01041f0:	c7 44 24 08 c4 a6 10 	movl   $0xc010a6c4,0x8(%esp)
c01041f7:	c0 
c01041f8:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01041ff:	00 
c0104200:	c7 04 24 e3 a6 10 c0 	movl   $0xc010a6e3,(%esp)
c0104207:	e8 f4 c1 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c010420c:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0104211:	8b 55 08             	mov    0x8(%ebp),%edx
c0104214:	c1 ea 0c             	shr    $0xc,%edx
c0104217:	c1 e2 05             	shl    $0x5,%edx
c010421a:	01 d0                	add    %edx,%eax
}
c010421c:	c9                   	leave  
c010421d:	c3                   	ret    

c010421e <page2kva>:
page2kva(struct Page *page) {
c010421e:	55                   	push   %ebp
c010421f:	89 e5                	mov    %esp,%ebp
c0104221:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104224:	8b 45 08             	mov    0x8(%ebp),%eax
c0104227:	89 04 24             	mov    %eax,(%esp)
c010422a:	e8 94 ff ff ff       	call   c01041c3 <page2pa>
c010422f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104232:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104235:	c1 e8 0c             	shr    $0xc,%eax
c0104238:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010423b:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0104240:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104243:	72 23                	jb     c0104268 <page2kva+0x4a>
c0104245:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104248:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010424c:	c7 44 24 08 f4 a6 10 	movl   $0xc010a6f4,0x8(%esp)
c0104253:	c0 
c0104254:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010425b:	00 
c010425c:	c7 04 24 e3 a6 10 c0 	movl   $0xc010a6e3,(%esp)
c0104263:	e8 98 c1 ff ff       	call   c0100400 <__panic>
c0104268:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010426b:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104270:	c9                   	leave  
c0104271:	c3                   	ret    

c0104272 <kva2page>:
kva2page(void *kva) {
c0104272:	55                   	push   %ebp
c0104273:	89 e5                	mov    %esp,%ebp
c0104275:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104278:	8b 45 08             	mov    0x8(%ebp),%eax
c010427b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010427e:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104285:	77 23                	ja     c01042aa <kva2page+0x38>
c0104287:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010428a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010428e:	c7 44 24 08 18 a7 10 	movl   $0xc010a718,0x8(%esp)
c0104295:	c0 
c0104296:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010429d:	00 
c010429e:	c7 04 24 e3 a6 10 c0 	movl   $0xc010a6e3,(%esp)
c01042a5:	e8 56 c1 ff ff       	call   c0100400 <__panic>
c01042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042ad:	05 00 00 00 40       	add    $0x40000000,%eax
c01042b2:	89 04 24             	mov    %eax,(%esp)
c01042b5:	e8 1f ff ff ff       	call   c01041d9 <pa2page>
}
c01042ba:	c9                   	leave  
c01042bb:	c3                   	ret    

c01042bc <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01042bc:	55                   	push   %ebp
c01042bd:	89 e5                	mov    %esp,%ebp
c01042bf:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c01042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042c5:	ba 01 00 00 00       	mov    $0x1,%edx
c01042ca:	88 c1                	mov    %al,%cl
c01042cc:	d3 e2                	shl    %cl,%edx
c01042ce:	89 d0                	mov    %edx,%eax
c01042d0:	89 04 24             	mov    %eax,(%esp)
c01042d3:	e8 40 27 00 00       	call   c0106a18 <alloc_pages>
c01042d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c01042db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042df:	75 07                	jne    c01042e8 <__slob_get_free_pages+0x2c>
    return NULL;
c01042e1:	b8 00 00 00 00       	mov    $0x0,%eax
c01042e6:	eb 0b                	jmp    c01042f3 <__slob_get_free_pages+0x37>
  return page2kva(page);
c01042e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042eb:	89 04 24             	mov    %eax,(%esp)
c01042ee:	e8 2b ff ff ff       	call   c010421e <page2kva>
}
c01042f3:	c9                   	leave  
c01042f4:	c3                   	ret    

c01042f5 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c01042f5:	55                   	push   %ebp
c01042f6:	89 e5                	mov    %esp,%ebp
c01042f8:	53                   	push   %ebx
c01042f9:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c01042fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042ff:	ba 01 00 00 00       	mov    $0x1,%edx
c0104304:	88 c1                	mov    %al,%cl
c0104306:	d3 e2                	shl    %cl,%edx
c0104308:	89 d0                	mov    %edx,%eax
c010430a:	89 c3                	mov    %eax,%ebx
c010430c:	8b 45 08             	mov    0x8(%ebp),%eax
c010430f:	89 04 24             	mov    %eax,(%esp)
c0104312:	e8 5b ff ff ff       	call   c0104272 <kva2page>
c0104317:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010431b:	89 04 24             	mov    %eax,(%esp)
c010431e:	e8 2d 27 00 00       	call   c0106a50 <free_pages>
}
c0104323:	90                   	nop
c0104324:	83 c4 14             	add    $0x14,%esp
c0104327:	5b                   	pop    %ebx
c0104328:	5d                   	pop    %ebp
c0104329:	c3                   	ret    

c010432a <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c010432a:	55                   	push   %ebp
c010432b:	89 e5                	mov    %esp,%ebp
c010432d:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104330:	8b 45 08             	mov    0x8(%ebp),%eax
c0104333:	83 c0 08             	add    $0x8,%eax
c0104336:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010433b:	76 24                	jbe    c0104361 <slob_alloc+0x37>
c010433d:	c7 44 24 0c 3c a7 10 	movl   $0xc010a73c,0xc(%esp)
c0104344:	c0 
c0104345:	c7 44 24 08 5b a7 10 	movl   $0xc010a75b,0x8(%esp)
c010434c:	c0 
c010434d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104354:	00 
c0104355:	c7 04 24 70 a7 10 c0 	movl   $0xc010a770,(%esp)
c010435c:	e8 9f c0 ff ff       	call   c0100400 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104361:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0104368:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010436f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104372:	83 c0 07             	add    $0x7,%eax
c0104375:	c1 e8 03             	shr    $0x3,%eax
c0104378:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c010437b:	e8 f2 fd ff ff       	call   c0104172 <__intr_save>
c0104380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104383:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104388:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010438e:	8b 40 04             	mov    0x4(%eax),%eax
c0104391:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104394:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104398:	74 25                	je     c01043bf <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010439a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010439d:	8b 45 10             	mov    0x10(%ebp),%eax
c01043a0:	01 d0                	add    %edx,%eax
c01043a2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01043a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01043a8:	f7 d8                	neg    %eax
c01043aa:	21 d0                	and    %edx,%eax
c01043ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c01043af:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01043b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043b5:	29 c2                	sub    %eax,%edx
c01043b7:	89 d0                	mov    %edx,%eax
c01043b9:	c1 f8 03             	sar    $0x3,%eax
c01043bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c01043bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043c2:	8b 00                	mov    (%eax),%eax
c01043c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01043c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01043ca:	01 ca                	add    %ecx,%edx
c01043cc:	39 d0                	cmp    %edx,%eax
c01043ce:	0f 8c aa 00 00 00    	jl     c010447e <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c01043d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01043d8:	74 38                	je     c0104412 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c01043da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043dd:	8b 00                	mov    (%eax),%eax
c01043df:	2b 45 e8             	sub    -0x18(%ebp),%eax
c01043e2:	89 c2                	mov    %eax,%edx
c01043e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043e7:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c01043e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043ec:	8b 50 04             	mov    0x4(%eax),%edx
c01043ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043f2:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01043f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01043fb:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01043fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104401:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104404:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104406:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104409:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c010440c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010440f:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104412:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104415:	8b 00                	mov    (%eax),%eax
c0104417:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010441a:	75 0e                	jne    c010442a <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c010441c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010441f:	8b 50 04             	mov    0x4(%eax),%edx
c0104422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104425:	89 50 04             	mov    %edx,0x4(%eax)
c0104428:	eb 3c                	jmp    c0104466 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c010442a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010442d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104434:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104437:	01 c2                	add    %eax,%edx
c0104439:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010443c:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c010443f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104442:	8b 10                	mov    (%eax),%edx
c0104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104447:	8b 40 04             	mov    0x4(%eax),%eax
c010444a:	2b 55 e0             	sub    -0x20(%ebp),%edx
c010444d:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104452:	8b 40 04             	mov    0x4(%eax),%eax
c0104455:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104458:	8b 52 04             	mov    0x4(%edx),%edx
c010445b:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c010445e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104461:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104464:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104466:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104469:	a3 08 4a 12 c0       	mov    %eax,0xc0124a08
			spin_unlock_irqrestore(&slob_lock, flags);
c010446e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104471:	89 04 24             	mov    %eax,(%esp)
c0104474:	e8 23 fd ff ff       	call   c010419c <__intr_restore>
			return cur;
c0104479:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010447c:	eb 7f                	jmp    c01044fd <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c010447e:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104483:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104486:	75 61                	jne    c01044e9 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104488:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010448b:	89 04 24             	mov    %eax,(%esp)
c010448e:	e8 09 fd ff ff       	call   c010419c <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104493:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c010449a:	75 07                	jne    c01044a3 <slob_alloc+0x179>
				return 0;
c010449c:	b8 00 00 00 00       	mov    $0x0,%eax
c01044a1:	eb 5a                	jmp    c01044fd <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c01044a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01044aa:	00 
c01044ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044ae:	89 04 24             	mov    %eax,(%esp)
c01044b1:	e8 06 fe ff ff       	call   c01042bc <__slob_get_free_pages>
c01044b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c01044b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044bd:	75 07                	jne    c01044c6 <slob_alloc+0x19c>
				return 0;
c01044bf:	b8 00 00 00 00       	mov    $0x0,%eax
c01044c4:	eb 37                	jmp    c01044fd <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c01044c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01044cd:	00 
c01044ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044d1:	89 04 24             	mov    %eax,(%esp)
c01044d4:	e8 26 00 00 00       	call   c01044ff <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c01044d9:	e8 94 fc ff ff       	call   c0104172 <__intr_save>
c01044de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c01044e1:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c01044e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01044e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01044ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044f2:	8b 40 04             	mov    0x4(%eax),%eax
c01044f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01044f8:	e9 97 fe ff ff       	jmp    c0104394 <slob_alloc+0x6a>
		}
	}
}
c01044fd:	c9                   	leave  
c01044fe:	c3                   	ret    

c01044ff <slob_free>:

static void slob_free(void *block, int size)
{
c01044ff:	55                   	push   %ebp
c0104500:	89 e5                	mov    %esp,%ebp
c0104502:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104505:	8b 45 08             	mov    0x8(%ebp),%eax
c0104508:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010450b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010450f:	0f 84 01 01 00 00    	je     c0104616 <slob_free+0x117>
		return;

	if (size)
c0104515:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104519:	74 10                	je     c010452b <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c010451b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010451e:	83 c0 07             	add    $0x7,%eax
c0104521:	c1 e8 03             	shr    $0x3,%eax
c0104524:	89 c2                	mov    %eax,%edx
c0104526:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104529:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c010452b:	e8 42 fc ff ff       	call   c0104172 <__intr_save>
c0104530:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104533:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104538:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010453b:	eb 27                	jmp    c0104564 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c010453d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104540:	8b 40 04             	mov    0x4(%eax),%eax
c0104543:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104546:	72 13                	jb     c010455b <slob_free+0x5c>
c0104548:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010454b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010454e:	77 27                	ja     c0104577 <slob_free+0x78>
c0104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104553:	8b 40 04             	mov    0x4(%eax),%eax
c0104556:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104559:	72 1c                	jb     c0104577 <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010455e:	8b 40 04             	mov    0x4(%eax),%eax
c0104561:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104564:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104567:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010456a:	76 d1                	jbe    c010453d <slob_free+0x3e>
c010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010456f:	8b 40 04             	mov    0x4(%eax),%eax
c0104572:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104575:	73 c6                	jae    c010453d <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c0104577:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010457a:	8b 00                	mov    (%eax),%eax
c010457c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104583:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104586:	01 c2                	add    %eax,%edx
c0104588:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010458b:	8b 40 04             	mov    0x4(%eax),%eax
c010458e:	39 c2                	cmp    %eax,%edx
c0104590:	75 25                	jne    c01045b7 <slob_free+0xb8>
		b->units += cur->next->units;
c0104592:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104595:	8b 10                	mov    (%eax),%edx
c0104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010459a:	8b 40 04             	mov    0x4(%eax),%eax
c010459d:	8b 00                	mov    (%eax),%eax
c010459f:	01 c2                	add    %eax,%edx
c01045a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045a4:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c01045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045a9:	8b 40 04             	mov    0x4(%eax),%eax
c01045ac:	8b 50 04             	mov    0x4(%eax),%edx
c01045af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045b2:	89 50 04             	mov    %edx,0x4(%eax)
c01045b5:	eb 0c                	jmp    c01045c3 <slob_free+0xc4>
	} else
		b->next = cur->next;
c01045b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ba:	8b 50 04             	mov    0x4(%eax),%edx
c01045bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045c0:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c01045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c6:	8b 00                	mov    (%eax),%eax
c01045c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d2:	01 d0                	add    %edx,%eax
c01045d4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01045d7:	75 1f                	jne    c01045f8 <slob_free+0xf9>
		cur->units += b->units;
c01045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045dc:	8b 10                	mov    (%eax),%edx
c01045de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045e1:	8b 00                	mov    (%eax),%eax
c01045e3:	01 c2                	add    %eax,%edx
c01045e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e8:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c01045ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045ed:	8b 50 04             	mov    0x4(%eax),%edx
c01045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f3:	89 50 04             	mov    %edx,0x4(%eax)
c01045f6:	eb 09                	jmp    c0104601 <slob_free+0x102>
	} else
		cur->next = b;
c01045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01045fe:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104604:	a3 08 4a 12 c0       	mov    %eax,0xc0124a08

	spin_unlock_irqrestore(&slob_lock, flags);
c0104609:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010460c:	89 04 24             	mov    %eax,(%esp)
c010460f:	e8 88 fb ff ff       	call   c010419c <__intr_restore>
c0104614:	eb 01                	jmp    c0104617 <slob_free+0x118>
		return;
c0104616:	90                   	nop
}
c0104617:	c9                   	leave  
c0104618:	c3                   	ret    

c0104619 <slob_init>:



void
slob_init(void) {
c0104619:	55                   	push   %ebp
c010461a:	89 e5                	mov    %esp,%ebp
c010461c:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c010461f:	c7 04 24 82 a7 10 c0 	movl   $0xc010a782,(%esp)
c0104626:	e8 7e bc ff ff       	call   c01002a9 <cprintf>
}
c010462b:	90                   	nop
c010462c:	c9                   	leave  
c010462d:	c3                   	ret    

c010462e <kmalloc_init>:

inline void 
kmalloc_init(void) {
c010462e:	55                   	push   %ebp
c010462f:	89 e5                	mov    %esp,%ebp
c0104631:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104634:	e8 e0 ff ff ff       	call   c0104619 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104639:	c7 04 24 96 a7 10 c0 	movl   $0xc010a796,(%esp)
c0104640:	e8 64 bc ff ff       	call   c01002a9 <cprintf>
}
c0104645:	90                   	nop
c0104646:	c9                   	leave  
c0104647:	c3                   	ret    

c0104648 <slob_allocated>:

size_t
slob_allocated(void) {
c0104648:	55                   	push   %ebp
c0104649:	89 e5                	mov    %esp,%ebp
  return 0;
c010464b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104650:	5d                   	pop    %ebp
c0104651:	c3                   	ret    

c0104652 <kallocated>:

size_t
kallocated(void) {
c0104652:	55                   	push   %ebp
c0104653:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104655:	e8 ee ff ff ff       	call   c0104648 <slob_allocated>
}
c010465a:	5d                   	pop    %ebp
c010465b:	c3                   	ret    

c010465c <find_order>:

static int find_order(int size)
{
c010465c:	55                   	push   %ebp
c010465d:	89 e5                	mov    %esp,%ebp
c010465f:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104662:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104669:	eb 06                	jmp    c0104671 <find_order+0x15>
		order++;
c010466b:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c010466e:	d1 7d 08             	sarl   0x8(%ebp)
c0104671:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104678:	7f f1                	jg     c010466b <find_order+0xf>
	return order;
c010467a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010467d:	c9                   	leave  
c010467e:	c3                   	ret    

c010467f <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c010467f:	55                   	push   %ebp
c0104680:	89 e5                	mov    %esp,%ebp
c0104682:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104685:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c010468c:	77 3b                	ja     c01046c9 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c010468e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104691:	8d 50 08             	lea    0x8(%eax),%edx
c0104694:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010469b:	00 
c010469c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010469f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046a3:	89 14 24             	mov    %edx,(%esp)
c01046a6:	e8 7f fc ff ff       	call   c010432a <slob_alloc>
c01046ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c01046ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01046b2:	74 0b                	je     c01046bf <__kmalloc+0x40>
c01046b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046b7:	83 c0 08             	add    $0x8,%eax
c01046ba:	e9 b4 00 00 00       	jmp    c0104773 <__kmalloc+0xf4>
c01046bf:	b8 00 00 00 00       	mov    $0x0,%eax
c01046c4:	e9 aa 00 00 00       	jmp    c0104773 <__kmalloc+0xf4>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c01046c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01046d0:	00 
c01046d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046d8:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c01046df:	e8 46 fc ff ff       	call   c010432a <slob_alloc>
c01046e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c01046e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046eb:	75 07                	jne    c01046f4 <__kmalloc+0x75>
		return 0;
c01046ed:	b8 00 00 00 00       	mov    $0x0,%eax
c01046f2:	eb 7f                	jmp    c0104773 <__kmalloc+0xf4>

	bb->order = find_order(size);
c01046f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f7:	89 04 24             	mov    %eax,(%esp)
c01046fa:	e8 5d ff ff ff       	call   c010465c <find_order>
c01046ff:	89 c2                	mov    %eax,%edx
c0104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104704:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104709:	8b 00                	mov    (%eax),%eax
c010470b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010470f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104712:	89 04 24             	mov    %eax,(%esp)
c0104715:	e8 a2 fb ff ff       	call   c01042bc <__slob_get_free_pages>
c010471a:	89 c2                	mov    %eax,%edx
c010471c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010471f:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c0104722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104725:	8b 40 04             	mov    0x4(%eax),%eax
c0104728:	85 c0                	test   %eax,%eax
c010472a:	74 2f                	je     c010475b <__kmalloc+0xdc>
		spin_lock_irqsave(&block_lock, flags);
c010472c:	e8 41 fa ff ff       	call   c0104172 <__intr_save>
c0104731:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0104734:	8b 15 64 7f 12 c0    	mov    0xc0127f64,%edx
c010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473d:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104743:	a3 64 7f 12 c0       	mov    %eax,0xc0127f64
		spin_unlock_irqrestore(&block_lock, flags);
c0104748:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010474b:	89 04 24             	mov    %eax,(%esp)
c010474e:	e8 49 fa ff ff       	call   c010419c <__intr_restore>
		return bb->pages;
c0104753:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104756:	8b 40 04             	mov    0x4(%eax),%eax
c0104759:	eb 18                	jmp    c0104773 <__kmalloc+0xf4>
	}

	slob_free(bb, sizeof(bigblock_t));
c010475b:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104762:	00 
c0104763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104766:	89 04 24             	mov    %eax,(%esp)
c0104769:	e8 91 fd ff ff       	call   c01044ff <slob_free>
	return 0;
c010476e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104773:	c9                   	leave  
c0104774:	c3                   	ret    

c0104775 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104775:	55                   	push   %ebp
c0104776:	89 e5                	mov    %esp,%ebp
c0104778:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c010477b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104782:	00 
c0104783:	8b 45 08             	mov    0x8(%ebp),%eax
c0104786:	89 04 24             	mov    %eax,(%esp)
c0104789:	e8 f1 fe ff ff       	call   c010467f <__kmalloc>
}
c010478e:	c9                   	leave  
c010478f:	c3                   	ret    

c0104790 <kfree>:


void kfree(void *block)
{
c0104790:	55                   	push   %ebp
c0104791:	89 e5                	mov    %esp,%ebp
c0104793:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104796:	c7 45 f0 64 7f 12 c0 	movl   $0xc0127f64,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010479d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01047a1:	0f 84 a4 00 00 00    	je     c010484b <kfree+0xbb>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01047a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01047aa:	25 ff 0f 00 00       	and    $0xfff,%eax
c01047af:	85 c0                	test   %eax,%eax
c01047b1:	75 7f                	jne    c0104832 <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c01047b3:	e8 ba f9 ff ff       	call   c0104172 <__intr_save>
c01047b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c01047bb:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01047c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047c3:	eb 5c                	jmp    c0104821 <kfree+0x91>
			if (bb->pages == block) {
c01047c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c8:	8b 40 04             	mov    0x4(%eax),%eax
c01047cb:	39 45 08             	cmp    %eax,0x8(%ebp)
c01047ce:	75 3f                	jne    c010480f <kfree+0x7f>
				*last = bb->next;
c01047d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047d3:	8b 50 08             	mov    0x8(%eax),%edx
c01047d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047d9:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c01047db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047de:	89 04 24             	mov    %eax,(%esp)
c01047e1:	e8 b6 f9 ff ff       	call   c010419c <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c01047e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047e9:	8b 10                	mov    (%eax),%edx
c01047eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ee:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047f2:	89 04 24             	mov    %eax,(%esp)
c01047f5:	e8 fb fa ff ff       	call   c01042f5 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c01047fa:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104801:	00 
c0104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104805:	89 04 24             	mov    %eax,(%esp)
c0104808:	e8 f2 fc ff ff       	call   c01044ff <slob_free>
				return;
c010480d:	eb 3d                	jmp    c010484c <kfree+0xbc>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c010480f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104812:	83 c0 08             	add    $0x8,%eax
c0104815:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104818:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010481b:	8b 40 08             	mov    0x8(%eax),%eax
c010481e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104821:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104825:	75 9e                	jne    c01047c5 <kfree+0x35>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104827:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010482a:	89 04 24             	mov    %eax,(%esp)
c010482d:	e8 6a f9 ff ff       	call   c010419c <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104832:	8b 45 08             	mov    0x8(%ebp),%eax
c0104835:	83 e8 08             	sub    $0x8,%eax
c0104838:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010483f:	00 
c0104840:	89 04 24             	mov    %eax,(%esp)
c0104843:	e8 b7 fc ff ff       	call   c01044ff <slob_free>
	return;
c0104848:	90                   	nop
c0104849:	eb 01                	jmp    c010484c <kfree+0xbc>
		return;
c010484b:	90                   	nop
}
c010484c:	c9                   	leave  
c010484d:	c3                   	ret    

c010484e <ksize>:


unsigned int ksize(const void *block)
{
c010484e:	55                   	push   %ebp
c010484f:	89 e5                	mov    %esp,%ebp
c0104851:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104854:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104858:	75 07                	jne    c0104861 <ksize+0x13>
		return 0;
c010485a:	b8 00 00 00 00       	mov    $0x0,%eax
c010485f:	eb 6b                	jmp    c01048cc <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104861:	8b 45 08             	mov    0x8(%ebp),%eax
c0104864:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104869:	85 c0                	test   %eax,%eax
c010486b:	75 54                	jne    c01048c1 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c010486d:	e8 00 f9 ff ff       	call   c0104172 <__intr_save>
c0104872:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104875:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c010487a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010487d:	eb 31                	jmp    c01048b0 <ksize+0x62>
			if (bb->pages == block) {
c010487f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104882:	8b 40 04             	mov    0x4(%eax),%eax
c0104885:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104888:	75 1d                	jne    c01048a7 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c010488a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488d:	89 04 24             	mov    %eax,(%esp)
c0104890:	e8 07 f9 ff ff       	call   c010419c <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104895:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104898:	8b 00                	mov    (%eax),%eax
c010489a:	ba 00 10 00 00       	mov    $0x1000,%edx
c010489f:	88 c1                	mov    %al,%cl
c01048a1:	d3 e2                	shl    %cl,%edx
c01048a3:	89 d0                	mov    %edx,%eax
c01048a5:	eb 25                	jmp    c01048cc <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c01048a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048aa:	8b 40 08             	mov    0x8(%eax),%eax
c01048ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048b4:	75 c9                	jne    c010487f <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c01048b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048b9:	89 04 24             	mov    %eax,(%esp)
c01048bc:	e8 db f8 ff ff       	call   c010419c <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c01048c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01048c4:	83 e8 08             	sub    $0x8,%eax
c01048c7:	8b 00                	mov    (%eax),%eax
c01048c9:	c1 e0 03             	shl    $0x3,%eax
}
c01048cc:	c9                   	leave  
c01048cd:	c3                   	ret    

c01048ce <pa2page>:
pa2page(uintptr_t pa) {
c01048ce:	55                   	push   %ebp
c01048cf:	89 e5                	mov    %esp,%ebp
c01048d1:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01048d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01048d7:	c1 e8 0c             	shr    $0xc,%eax
c01048da:	89 c2                	mov    %eax,%edx
c01048dc:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01048e1:	39 c2                	cmp    %eax,%edx
c01048e3:	72 1c                	jb     c0104901 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01048e5:	c7 44 24 08 b4 a7 10 	movl   $0xc010a7b4,0x8(%esp)
c01048ec:	c0 
c01048ed:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01048f4:	00 
c01048f5:	c7 04 24 d3 a7 10 c0 	movl   $0xc010a7d3,(%esp)
c01048fc:	e8 ff ba ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0104901:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0104906:	8b 55 08             	mov    0x8(%ebp),%edx
c0104909:	c1 ea 0c             	shr    $0xc,%edx
c010490c:	c1 e2 05             	shl    $0x5,%edx
c010490f:	01 d0                	add    %edx,%eax
}
c0104911:	c9                   	leave  
c0104912:	c3                   	ret    

c0104913 <pte2page>:
pte2page(pte_t pte) {
c0104913:	55                   	push   %ebp
c0104914:	89 e5                	mov    %esp,%ebp
c0104916:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104919:	8b 45 08             	mov    0x8(%ebp),%eax
c010491c:	83 e0 01             	and    $0x1,%eax
c010491f:	85 c0                	test   %eax,%eax
c0104921:	75 1c                	jne    c010493f <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104923:	c7 44 24 08 e4 a7 10 	movl   $0xc010a7e4,0x8(%esp)
c010492a:	c0 
c010492b:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0104932:	00 
c0104933:	c7 04 24 d3 a7 10 c0 	movl   $0xc010a7d3,(%esp)
c010493a:	e8 c1 ba ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c010493f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104942:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104947:	89 04 24             	mov    %eax,(%esp)
c010494a:	e8 7f ff ff ff       	call   c01048ce <pa2page>
}
c010494f:	c9                   	leave  
c0104950:	c3                   	ret    

c0104951 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0104951:	55                   	push   %ebp
c0104952:	89 e5                	mov    %esp,%ebp
c0104954:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0104957:	e8 d7 37 00 00       	call   c0108133 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010495c:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0104961:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0104966:	76 0c                	jbe    c0104974 <swap_init+0x23>
c0104968:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c010496d:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0104972:	76 25                	jbe    c0104999 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0104974:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0104979:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010497d:	c7 44 24 08 05 a8 10 	movl   $0xc010a805,0x8(%esp)
c0104984:	c0 
c0104985:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c010498c:	00 
c010498d:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104994:	e8 67 ba ff ff       	call   c0100400 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0104999:	c7 05 70 7f 12 c0 e0 	movl   $0xc01249e0,0xc0127f70
c01049a0:	49 12 c0 
     int r = sm->init();
c01049a3:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c01049a8:	8b 40 04             	mov    0x4(%eax),%eax
c01049ab:	ff d0                	call   *%eax
c01049ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01049b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01049b4:	75 26                	jne    c01049dc <swap_init+0x8b>
     {
          swap_init_ok = 1;
c01049b6:	c7 05 68 7f 12 c0 01 	movl   $0x1,0xc0127f68
c01049bd:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c01049c0:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c01049c5:	8b 00                	mov    (%eax),%eax
c01049c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01049cb:	c7 04 24 2f a8 10 c0 	movl   $0xc010a82f,(%esp)
c01049d2:	e8 d2 b8 ff ff       	call   c01002a9 <cprintf>
          check_swap();
c01049d7:	e8 9e 04 00 00       	call   c0104e7a <check_swap>
     }

     return r;
c01049dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01049df:	c9                   	leave  
c01049e0:	c3                   	ret    

c01049e1 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01049e1:	55                   	push   %ebp
c01049e2:	89 e5                	mov    %esp,%ebp
c01049e4:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01049e7:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c01049ec:	8b 40 08             	mov    0x8(%eax),%eax
c01049ef:	8b 55 08             	mov    0x8(%ebp),%edx
c01049f2:	89 14 24             	mov    %edx,(%esp)
c01049f5:	ff d0                	call   *%eax
}
c01049f7:	c9                   	leave  
c01049f8:	c3                   	ret    

c01049f9 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01049f9:	55                   	push   %ebp
c01049fa:	89 e5                	mov    %esp,%ebp
c01049fc:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01049ff:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c0104a04:	8b 40 0c             	mov    0xc(%eax),%eax
c0104a07:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a0a:	89 14 24             	mov    %edx,(%esp)
c0104a0d:	ff d0                	call   *%eax
}
c0104a0f:	c9                   	leave  
c0104a10:	c3                   	ret    

c0104a11 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104a11:	55                   	push   %ebp
c0104a12:	89 e5                	mov    %esp,%ebp
c0104a14:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0104a17:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c0104a1c:	8b 40 10             	mov    0x10(%eax),%eax
c0104a1f:	8b 55 14             	mov    0x14(%ebp),%edx
c0104a22:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0104a26:	8b 55 10             	mov    0x10(%ebp),%edx
c0104a29:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104a30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a34:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a37:	89 14 24             	mov    %edx,(%esp)
c0104a3a:	ff d0                	call   *%eax
}
c0104a3c:	c9                   	leave  
c0104a3d:	c3                   	ret    

c0104a3e <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104a3e:	55                   	push   %ebp
c0104a3f:	89 e5                	mov    %esp,%ebp
c0104a41:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0104a44:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c0104a49:	8b 40 14             	mov    0x14(%eax),%eax
c0104a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104a4f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a53:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a56:	89 14 24             	mov    %edx,(%esp)
c0104a59:	ff d0                	call   *%eax
}
c0104a5b:	c9                   	leave  
c0104a5c:	c3                   	ret    

c0104a5d <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0104a5d:	55                   	push   %ebp
c0104a5e:	89 e5                	mov    %esp,%ebp
c0104a60:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104a63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a6a:	e9 53 01 00 00       	jmp    c0104bc2 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104a6f:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c0104a74:	8b 40 18             	mov    0x18(%eax),%eax
c0104a77:	8b 55 10             	mov    0x10(%ebp),%edx
c0104a7a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104a7e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104a81:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a85:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a88:	89 14 24             	mov    %edx,(%esp)
c0104a8b:	ff d0                	call   *%eax
c0104a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104a90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a94:	74 18                	je     c0104aae <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a9d:	c7 04 24 44 a8 10 c0 	movl   $0xc010a844,(%esp)
c0104aa4:	e8 00 b8 ff ff       	call   c01002a9 <cprintf>
c0104aa9:	e9 20 01 00 00       	jmp    c0104bce <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0104aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ab1:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0104ab7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aba:	8b 40 0c             	mov    0xc(%eax),%eax
c0104abd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ac4:	00 
c0104ac5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104ac8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104acc:	89 04 24             	mov    %eax,(%esp)
c0104acf:	e8 ec 25 00 00       	call   c01070c0 <get_pte>
c0104ad4:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0104ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ada:	8b 00                	mov    (%eax),%eax
c0104adc:	83 e0 01             	and    $0x1,%eax
c0104adf:	85 c0                	test   %eax,%eax
c0104ae1:	75 24                	jne    c0104b07 <swap_out+0xaa>
c0104ae3:	c7 44 24 0c 71 a8 10 	movl   $0xc010a871,0xc(%esp)
c0104aea:	c0 
c0104aeb:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104af2:	c0 
c0104af3:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104afa:	00 
c0104afb:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104b02:	e8 f9 b8 ff ff       	call   c0100400 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0104b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b0d:	8b 52 1c             	mov    0x1c(%edx),%edx
c0104b10:	c1 ea 0c             	shr    $0xc,%edx
c0104b13:	42                   	inc    %edx
c0104b14:	c1 e2 08             	shl    $0x8,%edx
c0104b17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b1b:	89 14 24             	mov    %edx,(%esp)
c0104b1e:	e8 cb 36 00 00       	call   c01081ee <swapfs_write>
c0104b23:	85 c0                	test   %eax,%eax
c0104b25:	74 34                	je     c0104b5b <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0104b27:	c7 04 24 9b a8 10 c0 	movl   $0xc010a89b,(%esp)
c0104b2e:	e8 76 b7 ff ff       	call   c01002a9 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0104b33:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c0104b38:	8b 40 10             	mov    0x10(%eax),%eax
c0104b3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b3e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104b45:	00 
c0104b46:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104b4a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104b4d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b51:	8b 55 08             	mov    0x8(%ebp),%edx
c0104b54:	89 14 24             	mov    %edx,(%esp)
c0104b57:	ff d0                	call   *%eax
c0104b59:	eb 64                	jmp    c0104bbf <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0104b5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b5e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104b61:	c1 e8 0c             	shr    $0xc,%eax
c0104b64:	40                   	inc    %eax
c0104b65:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b6c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b77:	c7 04 24 b4 a8 10 c0 	movl   $0xc010a8b4,(%esp)
c0104b7e:	e8 26 b7 ff ff       	call   c01002a9 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0104b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b86:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104b89:	c1 e8 0c             	shr    $0xc,%eax
c0104b8c:	40                   	inc    %eax
c0104b8d:	c1 e0 08             	shl    $0x8,%eax
c0104b90:	89 c2                	mov    %eax,%edx
c0104b92:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b95:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ba1:	00 
c0104ba2:	89 04 24             	mov    %eax,(%esp)
c0104ba5:	e8 a6 1e 00 00       	call   c0106a50 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bad:	8b 40 0c             	mov    0xc(%eax),%eax
c0104bb0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104bb3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104bb7:	89 04 24             	mov    %eax,(%esp)
c0104bba:	e8 f3 27 00 00       	call   c01073b2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0104bbf:	ff 45 f4             	incl   -0xc(%ebp)
c0104bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bc5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104bc8:	0f 85 a1 fe ff ff    	jne    c0104a6f <swap_out+0x12>
     }
     return i;
c0104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104bd1:	c9                   	leave  
c0104bd2:	c3                   	ret    

c0104bd3 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104bd3:	55                   	push   %ebp
c0104bd4:	89 e5                	mov    %esp,%ebp
c0104bd6:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0104bd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104be0:	e8 33 1e 00 00       	call   c0106a18 <alloc_pages>
c0104be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104be8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bec:	75 24                	jne    c0104c12 <swap_in+0x3f>
c0104bee:	c7 44 24 0c f4 a8 10 	movl   $0xc010a8f4,0xc(%esp)
c0104bf5:	c0 
c0104bf6:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104bfd:	c0 
c0104bfe:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0104c05:	00 
c0104c06:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104c0d:	e8 ee b7 ff ff       	call   c0100400 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0104c12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c15:	8b 40 0c             	mov    0xc(%eax),%eax
c0104c18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c1f:	00 
c0104c20:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104c23:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c27:	89 04 24             	mov    %eax,(%esp)
c0104c2a:	e8 91 24 00 00       	call   c01070c0 <get_pte>
c0104c2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0104c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c35:	8b 00                	mov    (%eax),%eax
c0104c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c3a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c3e:	89 04 24             	mov    %eax,(%esp)
c0104c41:	e8 36 35 00 00       	call   c010817c <swapfs_read>
c0104c46:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c49:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c4d:	74 2a                	je     c0104c79 <swap_in+0xa6>
     {
        assert(r!=0);
c0104c4f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c53:	75 24                	jne    c0104c79 <swap_in+0xa6>
c0104c55:	c7 44 24 0c 01 a9 10 	movl   $0xc010a901,0xc(%esp)
c0104c5c:	c0 
c0104c5d:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104c64:	c0 
c0104c65:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0104c6c:	00 
c0104c6d:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104c74:	e8 87 b7 ff ff       	call   c0100400 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0104c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c7c:	8b 00                	mov    (%eax),%eax
c0104c7e:	c1 e8 08             	shr    $0x8,%eax
c0104c81:	89 c2                	mov    %eax,%edx
c0104c83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c86:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c8e:	c7 04 24 08 a9 10 c0 	movl   $0xc010a908,(%esp)
c0104c95:	e8 0f b6 ff ff       	call   c01002a9 <cprintf>
     *ptr_result=result;
c0104c9a:	8b 45 10             	mov    0x10(%ebp),%eax
c0104c9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ca0:	89 10                	mov    %edx,(%eax)
     return 0;
c0104ca2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ca7:	c9                   	leave  
c0104ca8:	c3                   	ret    

c0104ca9 <check_content_set>:



static inline void
check_content_set(void)
{
c0104ca9:	55                   	push   %ebp
c0104caa:	89 e5                	mov    %esp,%ebp
c0104cac:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0104caf:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104cb4:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104cb7:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104cbc:	83 f8 01             	cmp    $0x1,%eax
c0104cbf:	74 24                	je     c0104ce5 <check_content_set+0x3c>
c0104cc1:	c7 44 24 0c 46 a9 10 	movl   $0xc010a946,0xc(%esp)
c0104cc8:	c0 
c0104cc9:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104cd0:	c0 
c0104cd1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0104cd8:	00 
c0104cd9:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104ce0:	e8 1b b7 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104ce5:	b8 10 10 00 00       	mov    $0x1010,%eax
c0104cea:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104ced:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104cf2:	83 f8 01             	cmp    $0x1,%eax
c0104cf5:	74 24                	je     c0104d1b <check_content_set+0x72>
c0104cf7:	c7 44 24 0c 46 a9 10 	movl   $0xc010a946,0xc(%esp)
c0104cfe:	c0 
c0104cff:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104d06:	c0 
c0104d07:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0104d0e:	00 
c0104d0f:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104d16:	e8 e5 b6 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0104d1b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104d20:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104d23:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104d28:	83 f8 02             	cmp    $0x2,%eax
c0104d2b:	74 24                	je     c0104d51 <check_content_set+0xa8>
c0104d2d:	c7 44 24 0c 55 a9 10 	movl   $0xc010a955,0xc(%esp)
c0104d34:	c0 
c0104d35:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104d3c:	c0 
c0104d3d:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0104d44:	00 
c0104d45:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104d4c:	e8 af b6 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0104d51:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104d56:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104d59:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104d5e:	83 f8 02             	cmp    $0x2,%eax
c0104d61:	74 24                	je     c0104d87 <check_content_set+0xde>
c0104d63:	c7 44 24 0c 55 a9 10 	movl   $0xc010a955,0xc(%esp)
c0104d6a:	c0 
c0104d6b:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104d72:	c0 
c0104d73:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0104d7a:	00 
c0104d7b:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104d82:	e8 79 b6 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0104d87:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104d8c:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104d8f:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104d94:	83 f8 03             	cmp    $0x3,%eax
c0104d97:	74 24                	je     c0104dbd <check_content_set+0x114>
c0104d99:	c7 44 24 0c 64 a9 10 	movl   $0xc010a964,0xc(%esp)
c0104da0:	c0 
c0104da1:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104da8:	c0 
c0104da9:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0104db0:	00 
c0104db1:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104db8:	e8 43 b6 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0104dbd:	b8 10 30 00 00       	mov    $0x3010,%eax
c0104dc2:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104dc5:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104dca:	83 f8 03             	cmp    $0x3,%eax
c0104dcd:	74 24                	je     c0104df3 <check_content_set+0x14a>
c0104dcf:	c7 44 24 0c 64 a9 10 	movl   $0xc010a964,0xc(%esp)
c0104dd6:	c0 
c0104dd7:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104dde:	c0 
c0104ddf:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0104de6:	00 
c0104de7:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104dee:	e8 0d b6 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0104df3:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104df8:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104dfb:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104e00:	83 f8 04             	cmp    $0x4,%eax
c0104e03:	74 24                	je     c0104e29 <check_content_set+0x180>
c0104e05:	c7 44 24 0c 73 a9 10 	movl   $0xc010a973,0xc(%esp)
c0104e0c:	c0 
c0104e0d:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104e14:	c0 
c0104e15:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0104e1c:	00 
c0104e1d:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104e24:	e8 d7 b5 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0104e29:	b8 10 40 00 00       	mov    $0x4010,%eax
c0104e2e:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104e31:	a1 60 7f 12 c0       	mov    0xc0127f60,%eax
c0104e36:	83 f8 04             	cmp    $0x4,%eax
c0104e39:	74 24                	je     c0104e5f <check_content_set+0x1b6>
c0104e3b:	c7 44 24 0c 73 a9 10 	movl   $0xc010a973,0xc(%esp)
c0104e42:	c0 
c0104e43:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104e4a:	c0 
c0104e4b:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0104e52:	00 
c0104e53:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104e5a:	e8 a1 b5 ff ff       	call   c0100400 <__panic>
}
c0104e5f:	90                   	nop
c0104e60:	c9                   	leave  
c0104e61:	c3                   	ret    

c0104e62 <check_content_access>:

static inline int
check_content_access(void)
{
c0104e62:	55                   	push   %ebp
c0104e63:	89 e5                	mov    %esp,%ebp
c0104e65:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0104e68:	a1 70 7f 12 c0       	mov    0xc0127f70,%eax
c0104e6d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104e70:	ff d0                	call   *%eax
c0104e72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104e78:	c9                   	leave  
c0104e79:	c3                   	ret    

c0104e7a <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0104e7a:	55                   	push   %ebp
c0104e7b:	89 e5                	mov    %esp,%ebp
c0104e7d:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104e80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e87:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0104e8e:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104e95:	eb 6a                	jmp    c0104f01 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0104e97:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e9a:	83 e8 0c             	sub    $0xc,%eax
c0104e9d:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0104ea0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104ea3:	83 c0 04             	add    $0x4,%eax
c0104ea6:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104ead:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104eb0:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104eb3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104eb6:	0f a3 10             	bt     %edx,(%eax)
c0104eb9:	19 c0                	sbb    %eax,%eax
c0104ebb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0104ebe:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104ec2:	0f 95 c0             	setne  %al
c0104ec5:	0f b6 c0             	movzbl %al,%eax
c0104ec8:	85 c0                	test   %eax,%eax
c0104eca:	75 24                	jne    c0104ef0 <check_swap+0x76>
c0104ecc:	c7 44 24 0c 82 a9 10 	movl   $0xc010a982,0xc(%esp)
c0104ed3:	c0 
c0104ed4:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104edb:	c0 
c0104edc:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0104ee3:	00 
c0104ee4:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104eeb:	e8 10 b5 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c0104ef0:	ff 45 f4             	incl   -0xc(%ebp)
c0104ef3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104ef6:	8b 50 08             	mov    0x8(%eax),%edx
c0104ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104efc:	01 d0                	add    %edx,%eax
c0104efe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f01:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f04:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c0104f07:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104f0a:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0104f0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104f10:	81 7d e8 44 a1 12 c0 	cmpl   $0xc012a144,-0x18(%ebp)
c0104f17:	0f 85 7a ff ff ff    	jne    c0104e97 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0104f1d:	e8 61 1b 00 00       	call   c0106a83 <nr_free_pages>
c0104f22:	89 c2                	mov    %eax,%edx
c0104f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f27:	39 c2                	cmp    %eax,%edx
c0104f29:	74 24                	je     c0104f4f <check_swap+0xd5>
c0104f2b:	c7 44 24 0c 92 a9 10 	movl   $0xc010a992,0xc(%esp)
c0104f32:	c0 
c0104f33:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104f3a:	c0 
c0104f3b:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0104f42:	00 
c0104f43:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104f4a:	e8 b1 b4 ff ff       	call   c0100400 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f52:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f5d:	c7 04 24 ac a9 10 c0 	movl   $0xc010a9ac,(%esp)
c0104f64:	e8 40 b3 ff ff       	call   c01002a9 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0104f69:	e8 03 e2 ff ff       	call   c0103171 <mm_create>
c0104f6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0104f71:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104f75:	75 24                	jne    c0104f9b <check_swap+0x121>
c0104f77:	c7 44 24 0c d2 a9 10 	movl   $0xc010a9d2,0xc(%esp)
c0104f7e:	c0 
c0104f7f:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104f86:	c0 
c0104f87:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0104f8e:	00 
c0104f8f:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104f96:	e8 65 b4 ff ff       	call   c0100400 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0104f9b:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0104fa0:	85 c0                	test   %eax,%eax
c0104fa2:	74 24                	je     c0104fc8 <check_swap+0x14e>
c0104fa4:	c7 44 24 0c dd a9 10 	movl   $0xc010a9dd,0xc(%esp)
c0104fab:	c0 
c0104fac:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104fb3:	c0 
c0104fb4:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0104fbb:	00 
c0104fbc:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0104fc3:	e8 38 b4 ff ff       	call   c0100400 <__panic>

     check_mm_struct = mm;
c0104fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fcb:	a3 58 a0 12 c0       	mov    %eax,0xc012a058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104fd0:	8b 15 20 4a 12 c0    	mov    0xc0124a20,%edx
c0104fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fd9:	89 50 0c             	mov    %edx,0xc(%eax)
c0104fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fdf:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fe2:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0104fe5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fe8:	8b 00                	mov    (%eax),%eax
c0104fea:	85 c0                	test   %eax,%eax
c0104fec:	74 24                	je     c0105012 <check_swap+0x198>
c0104fee:	c7 44 24 0c f5 a9 10 	movl   $0xc010a9f5,0xc(%esp)
c0104ff5:	c0 
c0104ff6:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0104ffd:	c0 
c0104ffe:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0105005:	00 
c0105006:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c010500d:	e8 ee b3 ff ff       	call   c0100400 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0105012:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0105019:	00 
c010501a:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0105021:	00 
c0105022:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0105029:	e8 bb e1 ff ff       	call   c01031e9 <vma_create>
c010502e:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0105031:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105035:	75 24                	jne    c010505b <check_swap+0x1e1>
c0105037:	c7 44 24 0c 03 aa 10 	movl   $0xc010aa03,0xc(%esp)
c010503e:	c0 
c010503f:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0105046:	c0 
c0105047:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010504e:	00 
c010504f:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0105056:	e8 a5 b3 ff ff       	call   c0100400 <__panic>

     insert_vma_struct(mm, vma);
c010505b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010505e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105065:	89 04 24             	mov    %eax,(%esp)
c0105068:	e8 0d e3 ff ff       	call   c010337a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010506d:	c7 04 24 10 aa 10 c0 	movl   $0xc010aa10,(%esp)
c0105074:	e8 30 b2 ff ff       	call   c01002a9 <cprintf>
     pte_t *temp_ptep=NULL;
c0105079:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0105080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105083:	8b 40 0c             	mov    0xc(%eax),%eax
c0105086:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010508d:	00 
c010508e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105095:	00 
c0105096:	89 04 24             	mov    %eax,(%esp)
c0105099:	e8 22 20 00 00       	call   c01070c0 <get_pte>
c010509e:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c01050a1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01050a5:	75 24                	jne    c01050cb <check_swap+0x251>
c01050a7:	c7 44 24 0c 44 aa 10 	movl   $0xc010aa44,0xc(%esp)
c01050ae:	c0 
c01050af:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c01050b6:	c0 
c01050b7:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01050be:	00 
c01050bf:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c01050c6:	e8 35 b3 ff ff       	call   c0100400 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01050cb:	c7 04 24 58 aa 10 c0 	movl   $0xc010aa58,(%esp)
c01050d2:	e8 d2 b1 ff ff       	call   c01002a9 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01050d7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01050de:	e9 a4 00 00 00       	jmp    c0105187 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c01050e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050ea:	e8 29 19 00 00       	call   c0106a18 <alloc_pages>
c01050ef:	89 c2                	mov    %eax,%edx
c01050f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050f4:	89 14 85 80 a0 12 c0 	mov    %edx,-0x3fed5f80(,%eax,4)
          assert(check_rp[i] != NULL );
c01050fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050fe:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105105:	85 c0                	test   %eax,%eax
c0105107:	75 24                	jne    c010512d <check_swap+0x2b3>
c0105109:	c7 44 24 0c 7c aa 10 	movl   $0xc010aa7c,0xc(%esp)
c0105110:	c0 
c0105111:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0105118:	c0 
c0105119:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0105120:	00 
c0105121:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0105128:	e8 d3 b2 ff ff       	call   c0100400 <__panic>
          assert(!PageProperty(check_rp[i]));
c010512d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105130:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105137:	83 c0 04             	add    $0x4,%eax
c010513a:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0105141:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105144:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105147:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010514a:	0f a3 10             	bt     %edx,(%eax)
c010514d:	19 c0                	sbb    %eax,%eax
c010514f:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0105152:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0105156:	0f 95 c0             	setne  %al
c0105159:	0f b6 c0             	movzbl %al,%eax
c010515c:	85 c0                	test   %eax,%eax
c010515e:	74 24                	je     c0105184 <check_swap+0x30a>
c0105160:	c7 44 24 0c 90 aa 10 	movl   $0xc010aa90,0xc(%esp)
c0105167:	c0 
c0105168:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c010516f:	c0 
c0105170:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0105177:	00 
c0105178:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c010517f:	e8 7c b2 ff ff       	call   c0100400 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105184:	ff 45 ec             	incl   -0x14(%ebp)
c0105187:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010518b:	0f 8e 52 ff ff ff    	jle    c01050e3 <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c0105191:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0105196:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c010519c:	89 45 98             	mov    %eax,-0x68(%ebp)
c010519f:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01051a2:	c7 45 a4 44 a1 12 c0 	movl   $0xc012a144,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c01051a9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01051ac:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01051af:	89 50 04             	mov    %edx,0x4(%eax)
c01051b2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01051b5:	8b 50 04             	mov    0x4(%eax),%edx
c01051b8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01051bb:	89 10                	mov    %edx,(%eax)
c01051bd:	c7 45 a8 44 a1 12 c0 	movl   $0xc012a144,-0x58(%ebp)
    return list->next == list;
c01051c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01051c7:	8b 40 04             	mov    0x4(%eax),%eax
c01051ca:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c01051cd:	0f 94 c0             	sete   %al
c01051d0:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01051d3:	85 c0                	test   %eax,%eax
c01051d5:	75 24                	jne    c01051fb <check_swap+0x381>
c01051d7:	c7 44 24 0c ab aa 10 	movl   $0xc010aaab,0xc(%esp)
c01051de:	c0 
c01051df:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c01051e6:	c0 
c01051e7:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01051ee:	00 
c01051ef:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c01051f6:	e8 05 b2 ff ff       	call   c0100400 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01051fb:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105200:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0105203:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c010520a:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010520d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105214:	eb 1d                	jmp    c0105233 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0105216:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105219:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105220:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105227:	00 
c0105228:	89 04 24             	mov    %eax,(%esp)
c010522b:	e8 20 18 00 00       	call   c0106a50 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105230:	ff 45 ec             	incl   -0x14(%ebp)
c0105233:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105237:	7e dd                	jle    c0105216 <check_swap+0x39c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0105239:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c010523e:	83 f8 04             	cmp    $0x4,%eax
c0105241:	74 24                	je     c0105267 <check_swap+0x3ed>
c0105243:	c7 44 24 0c c4 aa 10 	movl   $0xc010aac4,0xc(%esp)
c010524a:	c0 
c010524b:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0105252:	c0 
c0105253:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010525a:	00 
c010525b:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0105262:	e8 99 b1 ff ff       	call   c0100400 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0105267:	c7 04 24 e8 aa 10 c0 	movl   $0xc010aae8,(%esp)
c010526e:	e8 36 b0 ff ff       	call   c01002a9 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0105273:	c7 05 60 7f 12 c0 00 	movl   $0x0,0xc0127f60
c010527a:	00 00 00 
     
     check_content_set();
c010527d:	e8 27 fa ff ff       	call   c0104ca9 <check_content_set>
     assert( nr_free == 0);         
c0105282:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105287:	85 c0                	test   %eax,%eax
c0105289:	74 24                	je     c01052af <check_swap+0x435>
c010528b:	c7 44 24 0c 0f ab 10 	movl   $0xc010ab0f,0xc(%esp)
c0105292:	c0 
c0105293:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c010529a:	c0 
c010529b:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01052a2:	00 
c01052a3:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c01052aa:	e8 51 b1 ff ff       	call   c0100400 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01052af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01052b6:	eb 25                	jmp    c01052dd <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01052b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052bb:	c7 04 85 a0 a0 12 c0 	movl   $0xffffffff,-0x3fed5f60(,%eax,4)
c01052c2:	ff ff ff ff 
c01052c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052c9:	8b 14 85 a0 a0 12 c0 	mov    -0x3fed5f60(,%eax,4),%edx
c01052d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052d3:	89 14 85 e0 a0 12 c0 	mov    %edx,-0x3fed5f20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01052da:	ff 45 ec             	incl   -0x14(%ebp)
c01052dd:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01052e1:	7e d5                	jle    c01052b8 <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01052e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01052ea:	e9 ec 00 00 00       	jmp    c01053db <check_swap+0x561>
         check_ptep[i]=0;
c01052ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052f2:	c7 04 85 34 a1 12 c0 	movl   $0x0,-0x3fed5ecc(,%eax,4)
c01052f9:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01052fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105300:	40                   	inc    %eax
c0105301:	c1 e0 0c             	shl    $0xc,%eax
c0105304:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010530b:	00 
c010530c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105310:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105313:	89 04 24             	mov    %eax,(%esp)
c0105316:	e8 a5 1d 00 00       	call   c01070c0 <get_pte>
c010531b:	89 c2                	mov    %eax,%edx
c010531d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105320:	89 14 85 34 a1 12 c0 	mov    %edx,-0x3fed5ecc(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0105327:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010532a:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c0105331:	85 c0                	test   %eax,%eax
c0105333:	75 24                	jne    c0105359 <check_swap+0x4df>
c0105335:	c7 44 24 0c 1c ab 10 	movl   $0xc010ab1c,0xc(%esp)
c010533c:	c0 
c010533d:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c0105344:	c0 
c0105345:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010534c:	00 
c010534d:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c0105354:	e8 a7 b0 ff ff       	call   c0100400 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0105359:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010535c:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c0105363:	8b 00                	mov    (%eax),%eax
c0105365:	89 04 24             	mov    %eax,(%esp)
c0105368:	e8 a6 f5 ff ff       	call   c0104913 <pte2page>
c010536d:	89 c2                	mov    %eax,%edx
c010536f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105372:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105379:	39 c2                	cmp    %eax,%edx
c010537b:	74 24                	je     c01053a1 <check_swap+0x527>
c010537d:	c7 44 24 0c 34 ab 10 	movl   $0xc010ab34,0xc(%esp)
c0105384:	c0 
c0105385:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c010538c:	c0 
c010538d:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0105394:	00 
c0105395:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c010539c:	e8 5f b0 ff ff       	call   c0100400 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01053a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053a4:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c01053ab:	8b 00                	mov    (%eax),%eax
c01053ad:	83 e0 01             	and    $0x1,%eax
c01053b0:	85 c0                	test   %eax,%eax
c01053b2:	75 24                	jne    c01053d8 <check_swap+0x55e>
c01053b4:	c7 44 24 0c 5c ab 10 	movl   $0xc010ab5c,0xc(%esp)
c01053bb:	c0 
c01053bc:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c01053c3:	c0 
c01053c4:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01053cb:	00 
c01053cc:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c01053d3:	e8 28 b0 ff ff       	call   c0100400 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01053d8:	ff 45 ec             	incl   -0x14(%ebp)
c01053db:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01053df:	0f 8e 0a ff ff ff    	jle    c01052ef <check_swap+0x475>
     }
     cprintf("set up init env for check_swap over!\n");
c01053e5:	c7 04 24 78 ab 10 c0 	movl   $0xc010ab78,(%esp)
c01053ec:	e8 b8 ae ff ff       	call   c01002a9 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01053f1:	e8 6c fa ff ff       	call   c0104e62 <check_content_access>
c01053f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c01053f9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01053fd:	74 24                	je     c0105423 <check_swap+0x5a9>
c01053ff:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c0105406:	c0 
c0105407:	c7 44 24 08 86 a8 10 	movl   $0xc010a886,0x8(%esp)
c010540e:	c0 
c010540f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0105416:	00 
c0105417:	c7 04 24 20 a8 10 c0 	movl   $0xc010a820,(%esp)
c010541e:	e8 dd af ff ff       	call   c0100400 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105423:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010542a:	eb 1d                	jmp    c0105449 <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c010542c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010542f:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c0105436:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010543d:	00 
c010543e:	89 04 24             	mov    %eax,(%esp)
c0105441:	e8 0a 16 00 00       	call   c0106a50 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105446:	ff 45 ec             	incl   -0x14(%ebp)
c0105449:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010544d:	7e dd                	jle    c010542c <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c010544f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105452:	89 04 24             	mov    %eax,(%esp)
c0105455:	e8 52 e0 ff ff       	call   c01034ac <mm_destroy>
         
     nr_free = nr_free_store;
c010545a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010545d:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
     free_list = free_list_store;
c0105462:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105465:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105468:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c010546d:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148

     
     le = &free_list;
c0105473:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010547a:	eb 1c                	jmp    c0105498 <check_swap+0x61e>
         struct Page *p = le2page(le, page_link);
c010547c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010547f:	83 e8 0c             	sub    $0xc,%eax
c0105482:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0105485:	ff 4d f4             	decl   -0xc(%ebp)
c0105488:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010548b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010548e:	8b 40 08             	mov    0x8(%eax),%eax
c0105491:	29 c2                	sub    %eax,%edx
c0105493:	89 d0                	mov    %edx,%eax
c0105495:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105498:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010549b:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c010549e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01054a1:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01054a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054a7:	81 7d e8 44 a1 12 c0 	cmpl   $0xc012a144,-0x18(%ebp)
c01054ae:	75 cc                	jne    c010547c <check_swap+0x602>
     }
     cprintf("count is %d, total is %d\n",count,total);
c01054b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054b3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01054b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054be:	c7 04 24 a5 ab 10 c0 	movl   $0xc010aba5,(%esp)
c01054c5:	e8 df ad ff ff       	call   c01002a9 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01054ca:	c7 04 24 bf ab 10 c0 	movl   $0xc010abbf,(%esp)
c01054d1:	e8 d3 ad ff ff       	call   c01002a9 <cprintf>
}
c01054d6:	90                   	nop
c01054d7:	c9                   	leave  
c01054d8:	c3                   	ret    

c01054d9 <page2ppn>:
page2ppn(struct Page *page) {
c01054d9:	55                   	push   %ebp
c01054da:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01054dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01054df:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01054e5:	29 d0                	sub    %edx,%eax
c01054e7:	c1 f8 05             	sar    $0x5,%eax
}
c01054ea:	5d                   	pop    %ebp
c01054eb:	c3                   	ret    

c01054ec <page2pa>:
page2pa(struct Page *page) {
c01054ec:	55                   	push   %ebp
c01054ed:	89 e5                	mov    %esp,%ebp
c01054ef:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01054f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01054f5:	89 04 24             	mov    %eax,(%esp)
c01054f8:	e8 dc ff ff ff       	call   c01054d9 <page2ppn>
c01054fd:	c1 e0 0c             	shl    $0xc,%eax
}
c0105500:	c9                   	leave  
c0105501:	c3                   	ret    

c0105502 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0105502:	55                   	push   %ebp
c0105503:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105505:	8b 45 08             	mov    0x8(%ebp),%eax
c0105508:	8b 00                	mov    (%eax),%eax
}
c010550a:	5d                   	pop    %ebp
c010550b:	c3                   	ret    

c010550c <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010550c:	55                   	push   %ebp
c010550d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010550f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105512:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105515:	89 10                	mov    %edx,(%eax)
}
c0105517:	90                   	nop
c0105518:	5d                   	pop    %ebp
c0105519:	c3                   	ret    

c010551a <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010551a:	55                   	push   %ebp
c010551b:	89 e5                	mov    %esp,%ebp
c010551d:	83 ec 10             	sub    $0x10,%esp
c0105520:	c7 45 fc 44 a1 12 c0 	movl   $0xc012a144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0105527:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010552a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010552d:	89 50 04             	mov    %edx,0x4(%eax)
c0105530:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105533:	8b 50 04             	mov    0x4(%eax),%edx
c0105536:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105539:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010553b:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c0105542:	00 00 00 
}
c0105545:	90                   	nop
c0105546:	c9                   	leave  
c0105547:	c3                   	ret    

c0105548 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0105548:	55                   	push   %ebp
c0105549:	89 e5                	mov    %esp,%ebp
c010554b:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010554e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105552:	75 24                	jne    c0105578 <default_init_memmap+0x30>
c0105554:	c7 44 24 0c d8 ab 10 	movl   $0xc010abd8,0xc(%esp)
c010555b:	c0 
c010555c:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105563:	c0 
c0105564:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010556b:	00 
c010556c:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105573:	e8 88 ae ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c0105578:	8b 45 08             	mov    0x8(%ebp),%eax
c010557b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010557e:	eb 7d                	jmp    c01055fd <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0105580:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105583:	83 c0 04             	add    $0x4,%eax
c0105586:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010558d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105590:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105593:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105596:	0f a3 10             	bt     %edx,(%eax)
c0105599:	19 c0                	sbb    %eax,%eax
c010559b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010559e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01055a2:	0f 95 c0             	setne  %al
c01055a5:	0f b6 c0             	movzbl %al,%eax
c01055a8:	85 c0                	test   %eax,%eax
c01055aa:	75 24                	jne    c01055d0 <default_init_memmap+0x88>
c01055ac:	c7 44 24 0c 09 ac 10 	movl   $0xc010ac09,0xc(%esp)
c01055b3:	c0 
c01055b4:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01055bb:	c0 
c01055bc:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01055c3:	00 
c01055c4:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01055cb:	e8 30 ae ff ff       	call   c0100400 <__panic>
        p->flags = p->property = 0;
c01055d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055d3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055dd:	8b 50 08             	mov    0x8(%eax),%edx
c01055e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055e3:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01055e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055ed:	00 
c01055ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055f1:	89 04 24             	mov    %eax,(%esp)
c01055f4:	e8 13 ff ff ff       	call   c010550c <set_page_ref>
    for (; p != base + n; p ++) {
c01055f9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01055fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105600:	c1 e0 05             	shl    $0x5,%eax
c0105603:	89 c2                	mov    %eax,%edx
c0105605:	8b 45 08             	mov    0x8(%ebp),%eax
c0105608:	01 d0                	add    %edx,%eax
c010560a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010560d:	0f 85 6d ff ff ff    	jne    c0105580 <default_init_memmap+0x38>
    }
    base->property = n;
c0105613:	8b 45 08             	mov    0x8(%ebp),%eax
c0105616:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105619:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010561c:	8b 45 08             	mov    0x8(%ebp),%eax
c010561f:	83 c0 04             	add    $0x4,%eax
c0105622:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105629:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010562c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010562f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105632:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0105635:	8b 15 4c a1 12 c0    	mov    0xc012a14c,%edx
c010563b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010563e:	01 d0                	add    %edx,%eax
c0105640:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
    list_add_before(&free_list, &(base->page_link));
c0105645:	8b 45 08             	mov    0x8(%ebp),%eax
c0105648:	83 c0 0c             	add    $0xc,%eax
c010564b:	c7 45 e4 44 a1 12 c0 	movl   $0xc012a144,-0x1c(%ebp)
c0105652:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0105655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105658:	8b 00                	mov    (%eax),%eax
c010565a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010565d:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105660:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105666:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0105669:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010566c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010566f:	89 10                	mov    %edx,(%eax)
c0105671:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105674:	8b 10                	mov    (%eax),%edx
c0105676:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105679:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010567c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010567f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105682:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105685:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105688:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010568b:	89 10                	mov    %edx,(%eax)
}
c010568d:	90                   	nop
c010568e:	c9                   	leave  
c010568f:	c3                   	ret    

c0105690 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0105690:	55                   	push   %ebp
c0105691:	89 e5                	mov    %esp,%ebp
c0105693:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0105696:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010569a:	75 24                	jne    c01056c0 <default_alloc_pages+0x30>
c010569c:	c7 44 24 0c d8 ab 10 	movl   $0xc010abd8,0xc(%esp)
c01056a3:	c0 
c01056a4:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01056ab:	c0 
c01056ac:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01056b3:	00 
c01056b4:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01056bb:	e8 40 ad ff ff       	call   c0100400 <__panic>
    if (n > nr_free) {
c01056c0:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01056c5:	39 45 08             	cmp    %eax,0x8(%ebp)
c01056c8:	76 0a                	jbe    c01056d4 <default_alloc_pages+0x44>
        return NULL;
c01056ca:	b8 00 00 00 00       	mov    $0x0,%eax
c01056cf:	e9 42 01 00 00       	jmp    c0105816 <default_alloc_pages+0x186>
    }
    struct Page *page = NULL;
c01056d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01056db:	c7 45 f0 44 a1 12 c0 	movl   $0xc012a144,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01056e2:	eb 1c                	jmp    c0105700 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01056e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056e7:	83 e8 0c             	sub    $0xc,%eax
c01056ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01056ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056f0:	8b 40 08             	mov    0x8(%eax),%eax
c01056f3:	39 45 08             	cmp    %eax,0x8(%ebp)
c01056f6:	77 08                	ja     c0105700 <default_alloc_pages+0x70>
            page = p;
c01056f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01056fe:	eb 18                	jmp    c0105718 <default_alloc_pages+0x88>
c0105700:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105703:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0105706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105709:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010570c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010570f:	81 7d f0 44 a1 12 c0 	cmpl   $0xc012a144,-0x10(%ebp)
c0105716:	75 cc                	jne    c01056e4 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0105718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010571c:	0f 84 f1 00 00 00    	je     c0105813 <default_alloc_pages+0x183>
        if (page->property > n) {
c0105722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105725:	8b 40 08             	mov    0x8(%eax),%eax
c0105728:	39 45 08             	cmp    %eax,0x8(%ebp)
c010572b:	0f 83 91 00 00 00    	jae    c01057c2 <default_alloc_pages+0x132>
            struct Page *p = page + n;
c0105731:	8b 45 08             	mov    0x8(%ebp),%eax
c0105734:	c1 e0 05             	shl    $0x5,%eax
c0105737:	89 c2                	mov    %eax,%edx
c0105739:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010573c:	01 d0                	add    %edx,%eax
c010573e:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0105741:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105744:	8b 40 08             	mov    0x8(%eax),%eax
c0105747:	2b 45 08             	sub    0x8(%ebp),%eax
c010574a:	89 c2                	mov    %eax,%edx
c010574c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010574f:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0105752:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105755:	83 c0 04             	add    $0x4,%eax
c0105758:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010575f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0105762:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105765:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105768:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
c010576b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010576e:	83 c0 0c             	add    $0xc,%eax
c0105771:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105774:	83 c2 0c             	add    $0xc,%edx
c0105777:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010577a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010577d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105780:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105783:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105786:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105789:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010578c:	8b 40 04             	mov    0x4(%eax),%eax
c010578f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105792:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105795:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105798:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010579b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c010579e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01057a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01057a4:	89 10                	mov    %edx,(%eax)
c01057a6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01057a9:	8b 10                	mov    (%eax),%edx
c01057ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01057ae:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01057b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01057b4:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01057b7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01057ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01057bd:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01057c0:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01057c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057c5:	83 c0 0c             	add    $0xc,%eax
c01057c8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01057cb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01057ce:	8b 40 04             	mov    0x4(%eax),%eax
c01057d1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01057d4:	8b 12                	mov    (%edx),%edx
c01057d6:	89 55 b0             	mov    %edx,-0x50(%ebp)
c01057d9:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next;
c01057dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01057df:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01057e2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01057e5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01057e8:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01057eb:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c01057ed:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01057f2:	2b 45 08             	sub    0x8(%ebp),%eax
c01057f5:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
        ClearPageProperty(page);
c01057fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057fd:	83 c0 04             	add    $0x4,%eax
c0105800:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105807:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010580a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010580d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105810:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105816:	c9                   	leave  
c0105817:	c3                   	ret    

c0105818 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0105818:	55                   	push   %ebp
c0105819:	89 e5                	mov    %esp,%ebp
c010581b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0105821:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105825:	75 24                	jne    c010584b <default_free_pages+0x33>
c0105827:	c7 44 24 0c d8 ab 10 	movl   $0xc010abd8,0xc(%esp)
c010582e:	c0 
c010582f:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105836:	c0 
c0105837:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c010583e:	00 
c010583f:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105846:	e8 b5 ab ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c010584b:	8b 45 08             	mov    0x8(%ebp),%eax
c010584e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0105851:	e9 9d 00 00 00       	jmp    c01058f3 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0105856:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105859:	83 c0 04             	add    $0x4,%eax
c010585c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105863:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105866:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105869:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010586c:	0f a3 10             	bt     %edx,(%eax)
c010586f:	19 c0                	sbb    %eax,%eax
c0105871:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105874:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105878:	0f 95 c0             	setne  %al
c010587b:	0f b6 c0             	movzbl %al,%eax
c010587e:	85 c0                	test   %eax,%eax
c0105880:	75 2c                	jne    c01058ae <default_free_pages+0x96>
c0105882:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105885:	83 c0 04             	add    $0x4,%eax
c0105888:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010588f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105892:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105895:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105898:	0f a3 10             	bt     %edx,(%eax)
c010589b:	19 c0                	sbb    %eax,%eax
c010589d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01058a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01058a4:	0f 95 c0             	setne  %al
c01058a7:	0f b6 c0             	movzbl %al,%eax
c01058aa:	85 c0                	test   %eax,%eax
c01058ac:	74 24                	je     c01058d2 <default_free_pages+0xba>
c01058ae:	c7 44 24 0c 1c ac 10 	movl   $0xc010ac1c,0xc(%esp)
c01058b5:	c0 
c01058b6:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01058bd:	c0 
c01058be:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01058c5:	00 
c01058c6:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01058cd:	e8 2e ab ff ff       	call   c0100400 <__panic>
        p->flags = 0;
c01058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01058dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01058e3:	00 
c01058e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058e7:	89 04 24             	mov    %eax,(%esp)
c01058ea:	e8 1d fc ff ff       	call   c010550c <set_page_ref>
    for (; p != base + n; p ++) {
c01058ef:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01058f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f6:	c1 e0 05             	shl    $0x5,%eax
c01058f9:	89 c2                	mov    %eax,%edx
c01058fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01058fe:	01 d0                	add    %edx,%eax
c0105900:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105903:	0f 85 4d ff ff ff    	jne    c0105856 <default_free_pages+0x3e>
    }
    base->property = n;
c0105909:	8b 45 08             	mov    0x8(%ebp),%eax
c010590c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010590f:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0105912:	8b 45 08             	mov    0x8(%ebp),%eax
c0105915:	83 c0 04             	add    $0x4,%eax
c0105918:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010591f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105922:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105925:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105928:	0f ab 10             	bts    %edx,(%eax)
c010592b:	c7 45 d4 44 a1 12 c0 	movl   $0xc012a144,-0x2c(%ebp)
    return listelm->next;
c0105932:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105935:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0105938:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010593b:	e9 fa 00 00 00       	jmp    c0105a3a <default_free_pages+0x222>
        p = le2page(le, page_link);
c0105940:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105943:	83 e8 0c             	sub    $0xc,%eax
c0105946:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105949:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010594c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010594f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105952:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0105955:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0105958:	8b 45 08             	mov    0x8(%ebp),%eax
c010595b:	8b 40 08             	mov    0x8(%eax),%eax
c010595e:	c1 e0 05             	shl    $0x5,%eax
c0105961:	89 c2                	mov    %eax,%edx
c0105963:	8b 45 08             	mov    0x8(%ebp),%eax
c0105966:	01 d0                	add    %edx,%eax
c0105968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010596b:	75 5a                	jne    c01059c7 <default_free_pages+0x1af>
            base->property += p->property;
c010596d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105970:	8b 50 08             	mov    0x8(%eax),%edx
c0105973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105976:	8b 40 08             	mov    0x8(%eax),%eax
c0105979:	01 c2                	add    %eax,%edx
c010597b:	8b 45 08             	mov    0x8(%ebp),%eax
c010597e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0105981:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105984:	83 c0 04             	add    $0x4,%eax
c0105987:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010598e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105991:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105994:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105997:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c010599a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010599d:	83 c0 0c             	add    $0xc,%eax
c01059a0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01059a3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01059a6:	8b 40 04             	mov    0x4(%eax),%eax
c01059a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01059ac:	8b 12                	mov    (%edx),%edx
c01059ae:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01059b1:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01059b4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01059b7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01059ba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01059bd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01059c0:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01059c3:	89 10                	mov    %edx,(%eax)
c01059c5:	eb 73                	jmp    c0105a3a <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c01059c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ca:	8b 40 08             	mov    0x8(%eax),%eax
c01059cd:	c1 e0 05             	shl    $0x5,%eax
c01059d0:	89 c2                	mov    %eax,%edx
c01059d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059d5:	01 d0                	add    %edx,%eax
c01059d7:	39 45 08             	cmp    %eax,0x8(%ebp)
c01059da:	75 5e                	jne    c0105a3a <default_free_pages+0x222>
            p->property += base->property;
c01059dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059df:	8b 50 08             	mov    0x8(%eax),%edx
c01059e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e5:	8b 40 08             	mov    0x8(%eax),%eax
c01059e8:	01 c2                	add    %eax,%edx
c01059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ed:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01059f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01059f3:	83 c0 04             	add    $0x4,%eax
c01059f6:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c01059fd:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0105a00:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105a03:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0105a06:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0c:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0105a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a12:	83 c0 0c             	add    $0xc,%eax
c0105a15:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105a18:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105a1b:	8b 40 04             	mov    0x4(%eax),%eax
c0105a1e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105a21:	8b 12                	mov    (%edx),%edx
c0105a23:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0105a26:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0105a29:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105a2c:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105a2f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105a32:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105a35:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105a38:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c0105a3a:	81 7d f0 44 a1 12 c0 	cmpl   $0xc012a144,-0x10(%ebp)
c0105a41:	0f 85 f9 fe ff ff    	jne    c0105940 <default_free_pages+0x128>
        }
    }
    nr_free += n;
c0105a47:	8b 15 4c a1 12 c0    	mov    0xc012a14c,%edx
c0105a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a50:	01 d0                	add    %edx,%eax
c0105a52:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
c0105a57:	c7 45 9c 44 a1 12 c0 	movl   $0xc012a144,-0x64(%ebp)
    return listelm->next;
c0105a5e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105a61:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
c0105a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a67:	eb 66                	jmp    c0105acf <default_free_pages+0x2b7>
        p = le2page(le, page_link);
c0105a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a6c:	83 e8 0c             	sub    $0xc,%eax
c0105a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(base + base->property <= p) {
c0105a72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a75:	8b 40 08             	mov    0x8(%eax),%eax
c0105a78:	c1 e0 05             	shl    $0x5,%eax
c0105a7b:	89 c2                	mov    %eax,%edx
c0105a7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a80:	01 d0                	add    %edx,%eax
c0105a82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105a85:	72 39                	jb     c0105ac0 <default_free_pages+0x2a8>
            assert(base + base->property != p);
c0105a87:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a8a:	8b 40 08             	mov    0x8(%eax),%eax
c0105a8d:	c1 e0 05             	shl    $0x5,%eax
c0105a90:	89 c2                	mov    %eax,%edx
c0105a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a95:	01 d0                	add    %edx,%eax
c0105a97:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105a9a:	75 3e                	jne    c0105ada <default_free_pages+0x2c2>
c0105a9c:	c7 44 24 0c 41 ac 10 	movl   $0xc010ac41,0xc(%esp)
c0105aa3:	c0 
c0105aa4:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105aab:	c0 
c0105aac:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0105ab3:	00 
c0105ab4:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105abb:	e8 40 a9 ff ff       	call   c0100400 <__panic>
c0105ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ac3:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105ac6:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105ac9:	8b 40 04             	mov    0x4(%eax),%eax
    for(le = list_next(&free_list); le != &free_list; le = list_next(le)) {
c0105acc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105acf:	81 7d f0 44 a1 12 c0 	cmpl   $0xc012a144,-0x10(%ebp)
c0105ad6:	75 91                	jne    c0105a69 <default_free_pages+0x251>
c0105ad8:	eb 01                	jmp    c0105adb <default_free_pages+0x2c3>
            break;
c0105ada:	90                   	nop
        }
    }
    list_add_before(le, &(base->page_link));
c0105adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ade:	8d 50 0c             	lea    0xc(%eax),%edx
c0105ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ae4:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0105ae7:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0105aea:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105aed:	8b 00                	mov    (%eax),%eax
c0105aef:	8b 55 90             	mov    -0x70(%ebp),%edx
c0105af2:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0105af5:	89 45 88             	mov    %eax,-0x78(%ebp)
c0105af8:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105afb:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0105afe:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0105b01:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0105b04:	89 10                	mov    %edx,(%eax)
c0105b06:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0105b09:	8b 10                	mov    (%eax),%edx
c0105b0b:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105b0e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105b11:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105b14:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105b17:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105b1a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105b1d:	8b 55 88             	mov    -0x78(%ebp),%edx
c0105b20:	89 10                	mov    %edx,(%eax)
}
c0105b22:	90                   	nop
c0105b23:	c9                   	leave  
c0105b24:	c3                   	ret    

c0105b25 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105b25:	55                   	push   %ebp
c0105b26:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105b28:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
}
c0105b2d:	5d                   	pop    %ebp
c0105b2e:	c3                   	ret    

c0105b2f <basic_check>:

static void
basic_check(void) {
c0105b2f:	55                   	push   %ebp
c0105b30:	89 e5                	mov    %esp,%ebp
c0105b32:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105b35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b45:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105b48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105b4f:	e8 c4 0e 00 00       	call   c0106a18 <alloc_pages>
c0105b54:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105b5b:	75 24                	jne    c0105b81 <basic_check+0x52>
c0105b5d:	c7 44 24 0c 5c ac 10 	movl   $0xc010ac5c,0xc(%esp)
c0105b64:	c0 
c0105b65:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105b6c:	c0 
c0105b6d:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0105b74:	00 
c0105b75:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105b7c:	e8 7f a8 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105b81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105b88:	e8 8b 0e 00 00       	call   c0106a18 <alloc_pages>
c0105b8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105b94:	75 24                	jne    c0105bba <basic_check+0x8b>
c0105b96:	c7 44 24 0c 78 ac 10 	movl   $0xc010ac78,0xc(%esp)
c0105b9d:	c0 
c0105b9e:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105ba5:	c0 
c0105ba6:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0105bad:	00 
c0105bae:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105bb5:	e8 46 a8 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105bba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105bc1:	e8 52 0e 00 00       	call   c0106a18 <alloc_pages>
c0105bc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bcd:	75 24                	jne    c0105bf3 <basic_check+0xc4>
c0105bcf:	c7 44 24 0c 94 ac 10 	movl   $0xc010ac94,0xc(%esp)
c0105bd6:	c0 
c0105bd7:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105bde:	c0 
c0105bdf:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0105be6:	00 
c0105be7:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105bee:	e8 0d a8 ff ff       	call   c0100400 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0105bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bf6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105bf9:	74 10                	je     c0105c0b <basic_check+0xdc>
c0105bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bfe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105c01:	74 08                	je     c0105c0b <basic_check+0xdc>
c0105c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c06:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105c09:	75 24                	jne    c0105c2f <basic_check+0x100>
c0105c0b:	c7 44 24 0c b0 ac 10 	movl   $0xc010acb0,0xc(%esp)
c0105c12:	c0 
c0105c13:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105c1a:	c0 
c0105c1b:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0105c22:	00 
c0105c23:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105c2a:	e8 d1 a7 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105c2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c32:	89 04 24             	mov    %eax,(%esp)
c0105c35:	e8 c8 f8 ff ff       	call   c0105502 <page_ref>
c0105c3a:	85 c0                	test   %eax,%eax
c0105c3c:	75 1e                	jne    c0105c5c <basic_check+0x12d>
c0105c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c41:	89 04 24             	mov    %eax,(%esp)
c0105c44:	e8 b9 f8 ff ff       	call   c0105502 <page_ref>
c0105c49:	85 c0                	test   %eax,%eax
c0105c4b:	75 0f                	jne    c0105c5c <basic_check+0x12d>
c0105c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c50:	89 04 24             	mov    %eax,(%esp)
c0105c53:	e8 aa f8 ff ff       	call   c0105502 <page_ref>
c0105c58:	85 c0                	test   %eax,%eax
c0105c5a:	74 24                	je     c0105c80 <basic_check+0x151>
c0105c5c:	c7 44 24 0c d4 ac 10 	movl   $0xc010acd4,0xc(%esp)
c0105c63:	c0 
c0105c64:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105c6b:	c0 
c0105c6c:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0105c73:	00 
c0105c74:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105c7b:	e8 80 a7 ff ff       	call   c0100400 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c83:	89 04 24             	mov    %eax,(%esp)
c0105c86:	e8 61 f8 ff ff       	call   c01054ec <page2pa>
c0105c8b:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c0105c91:	c1 e2 0c             	shl    $0xc,%edx
c0105c94:	39 d0                	cmp    %edx,%eax
c0105c96:	72 24                	jb     c0105cbc <basic_check+0x18d>
c0105c98:	c7 44 24 0c 10 ad 10 	movl   $0xc010ad10,0xc(%esp)
c0105c9f:	c0 
c0105ca0:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105ca7:	c0 
c0105ca8:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0105caf:	00 
c0105cb0:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105cb7:	e8 44 a7 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cbf:	89 04 24             	mov    %eax,(%esp)
c0105cc2:	e8 25 f8 ff ff       	call   c01054ec <page2pa>
c0105cc7:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c0105ccd:	c1 e2 0c             	shl    $0xc,%edx
c0105cd0:	39 d0                	cmp    %edx,%eax
c0105cd2:	72 24                	jb     c0105cf8 <basic_check+0x1c9>
c0105cd4:	c7 44 24 0c 2d ad 10 	movl   $0xc010ad2d,0xc(%esp)
c0105cdb:	c0 
c0105cdc:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105ce3:	c0 
c0105ce4:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0105ceb:	00 
c0105cec:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105cf3:	e8 08 a7 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cfb:	89 04 24             	mov    %eax,(%esp)
c0105cfe:	e8 e9 f7 ff ff       	call   c01054ec <page2pa>
c0105d03:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c0105d09:	c1 e2 0c             	shl    $0xc,%edx
c0105d0c:	39 d0                	cmp    %edx,%eax
c0105d0e:	72 24                	jb     c0105d34 <basic_check+0x205>
c0105d10:	c7 44 24 0c 4a ad 10 	movl   $0xc010ad4a,0xc(%esp)
c0105d17:	c0 
c0105d18:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105d1f:	c0 
c0105d20:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0105d27:	00 
c0105d28:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105d2f:	e8 cc a6 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0105d34:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0105d39:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c0105d3f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105d42:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105d45:	c7 45 dc 44 a1 12 c0 	movl   $0xc012a144,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0105d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105d52:	89 50 04             	mov    %edx,0x4(%eax)
c0105d55:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d58:	8b 50 04             	mov    0x4(%eax),%edx
c0105d5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d5e:	89 10                	mov    %edx,(%eax)
c0105d60:	c7 45 e0 44 a1 12 c0 	movl   $0xc012a144,-0x20(%ebp)
    return list->next == list;
c0105d67:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d6a:	8b 40 04             	mov    0x4(%eax),%eax
c0105d6d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105d70:	0f 94 c0             	sete   %al
c0105d73:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105d76:	85 c0                	test   %eax,%eax
c0105d78:	75 24                	jne    c0105d9e <basic_check+0x26f>
c0105d7a:	c7 44 24 0c 67 ad 10 	movl   $0xc010ad67,0xc(%esp)
c0105d81:	c0 
c0105d82:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105d89:	c0 
c0105d8a:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0105d91:	00 
c0105d92:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105d99:	e8 62 a6 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0105d9e:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105da3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0105da6:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c0105dad:	00 00 00 

    assert(alloc_page() == NULL);
c0105db0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105db7:	e8 5c 0c 00 00       	call   c0106a18 <alloc_pages>
c0105dbc:	85 c0                	test   %eax,%eax
c0105dbe:	74 24                	je     c0105de4 <basic_check+0x2b5>
c0105dc0:	c7 44 24 0c 7e ad 10 	movl   $0xc010ad7e,0xc(%esp)
c0105dc7:	c0 
c0105dc8:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105dcf:	c0 
c0105dd0:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0105dd7:	00 
c0105dd8:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105ddf:	e8 1c a6 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0105de4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105deb:	00 
c0105dec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105def:	89 04 24             	mov    %eax,(%esp)
c0105df2:	e8 59 0c 00 00       	call   c0106a50 <free_pages>
    free_page(p1);
c0105df7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105dfe:	00 
c0105dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e02:	89 04 24             	mov    %eax,(%esp)
c0105e05:	e8 46 0c 00 00       	call   c0106a50 <free_pages>
    free_page(p2);
c0105e0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105e11:	00 
c0105e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e15:	89 04 24             	mov    %eax,(%esp)
c0105e18:	e8 33 0c 00 00       	call   c0106a50 <free_pages>
    assert(nr_free == 3);
c0105e1d:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105e22:	83 f8 03             	cmp    $0x3,%eax
c0105e25:	74 24                	je     c0105e4b <basic_check+0x31c>
c0105e27:	c7 44 24 0c 93 ad 10 	movl   $0xc010ad93,0xc(%esp)
c0105e2e:	c0 
c0105e2f:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105e36:	c0 
c0105e37:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0105e3e:	00 
c0105e3f:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105e46:	e8 b5 a5 ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0105e4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e52:	e8 c1 0b 00 00       	call   c0106a18 <alloc_pages>
c0105e57:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105e5e:	75 24                	jne    c0105e84 <basic_check+0x355>
c0105e60:	c7 44 24 0c 5c ac 10 	movl   $0xc010ac5c,0xc(%esp)
c0105e67:	c0 
c0105e68:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105e6f:	c0 
c0105e70:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0105e77:	00 
c0105e78:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105e7f:	e8 7c a5 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105e84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e8b:	e8 88 0b 00 00       	call   c0106a18 <alloc_pages>
c0105e90:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e93:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e97:	75 24                	jne    c0105ebd <basic_check+0x38e>
c0105e99:	c7 44 24 0c 78 ac 10 	movl   $0xc010ac78,0xc(%esp)
c0105ea0:	c0 
c0105ea1:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105ea8:	c0 
c0105ea9:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0105eb0:	00 
c0105eb1:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105eb8:	e8 43 a5 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105ebd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ec4:	e8 4f 0b 00 00       	call   c0106a18 <alloc_pages>
c0105ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ecc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ed0:	75 24                	jne    c0105ef6 <basic_check+0x3c7>
c0105ed2:	c7 44 24 0c 94 ac 10 	movl   $0xc010ac94,0xc(%esp)
c0105ed9:	c0 
c0105eda:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105ee1:	c0 
c0105ee2:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0105ee9:	00 
c0105eea:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105ef1:	e8 0a a5 ff ff       	call   c0100400 <__panic>

    assert(alloc_page() == NULL);
c0105ef6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105efd:	e8 16 0b 00 00       	call   c0106a18 <alloc_pages>
c0105f02:	85 c0                	test   %eax,%eax
c0105f04:	74 24                	je     c0105f2a <basic_check+0x3fb>
c0105f06:	c7 44 24 0c 7e ad 10 	movl   $0xc010ad7e,0xc(%esp)
c0105f0d:	c0 
c0105f0e:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105f15:	c0 
c0105f16:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0105f1d:	00 
c0105f1e:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105f25:	e8 d6 a4 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0105f2a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105f31:	00 
c0105f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f35:	89 04 24             	mov    %eax,(%esp)
c0105f38:	e8 13 0b 00 00       	call   c0106a50 <free_pages>
c0105f3d:	c7 45 d8 44 a1 12 c0 	movl   $0xc012a144,-0x28(%ebp)
c0105f44:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f47:	8b 40 04             	mov    0x4(%eax),%eax
c0105f4a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105f4d:	0f 94 c0             	sete   %al
c0105f50:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105f53:	85 c0                	test   %eax,%eax
c0105f55:	74 24                	je     c0105f7b <basic_check+0x44c>
c0105f57:	c7 44 24 0c a0 ad 10 	movl   $0xc010ada0,0xc(%esp)
c0105f5e:	c0 
c0105f5f:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105f66:	c0 
c0105f67:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0105f6e:	00 
c0105f6f:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105f76:	e8 85 a4 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105f7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f82:	e8 91 0a 00 00       	call   c0106a18 <alloc_pages>
c0105f87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f8d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105f90:	74 24                	je     c0105fb6 <basic_check+0x487>
c0105f92:	c7 44 24 0c b8 ad 10 	movl   $0xc010adb8,0xc(%esp)
c0105f99:	c0 
c0105f9a:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105fa1:	c0 
c0105fa2:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0105fa9:	00 
c0105faa:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105fb1:	e8 4a a4 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0105fb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105fbd:	e8 56 0a 00 00       	call   c0106a18 <alloc_pages>
c0105fc2:	85 c0                	test   %eax,%eax
c0105fc4:	74 24                	je     c0105fea <basic_check+0x4bb>
c0105fc6:	c7 44 24 0c 7e ad 10 	movl   $0xc010ad7e,0xc(%esp)
c0105fcd:	c0 
c0105fce:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0105fd5:	c0 
c0105fd6:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0105fdd:	00 
c0105fde:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0105fe5:	e8 16 a4 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c0105fea:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105fef:	85 c0                	test   %eax,%eax
c0105ff1:	74 24                	je     c0106017 <basic_check+0x4e8>
c0105ff3:	c7 44 24 0c d1 ad 10 	movl   $0xc010add1,0xc(%esp)
c0105ffa:	c0 
c0105ffb:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106002:	c0 
c0106003:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c010600a:	00 
c010600b:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106012:	e8 e9 a3 ff ff       	call   c0100400 <__panic>
    free_list = free_list_store;
c0106017:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010601a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010601d:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c0106022:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148
    nr_free = nr_free_store;
c0106028:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010602b:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c

    free_page(p);
c0106030:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106037:	00 
c0106038:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010603b:	89 04 24             	mov    %eax,(%esp)
c010603e:	e8 0d 0a 00 00       	call   c0106a50 <free_pages>
    free_page(p1);
c0106043:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010604a:	00 
c010604b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010604e:	89 04 24             	mov    %eax,(%esp)
c0106051:	e8 fa 09 00 00       	call   c0106a50 <free_pages>
    free_page(p2);
c0106056:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010605d:	00 
c010605e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106061:	89 04 24             	mov    %eax,(%esp)
c0106064:	e8 e7 09 00 00       	call   c0106a50 <free_pages>
}
c0106069:	90                   	nop
c010606a:	c9                   	leave  
c010606b:	c3                   	ret    

c010606c <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010606c:	55                   	push   %ebp
c010606d:	89 e5                	mov    %esp,%ebp
c010606f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0106075:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010607c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0106083:	c7 45 ec 44 a1 12 c0 	movl   $0xc012a144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010608a:	eb 6a                	jmp    c01060f6 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c010608c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010608f:	83 e8 0c             	sub    $0xc,%eax
c0106092:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0106095:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106098:	83 c0 04             	add    $0x4,%eax
c010609b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01060a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01060a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01060a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01060ab:	0f a3 10             	bt     %edx,(%eax)
c01060ae:	19 c0                	sbb    %eax,%eax
c01060b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01060b3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01060b7:	0f 95 c0             	setne  %al
c01060ba:	0f b6 c0             	movzbl %al,%eax
c01060bd:	85 c0                	test   %eax,%eax
c01060bf:	75 24                	jne    c01060e5 <default_check+0x79>
c01060c1:	c7 44 24 0c de ad 10 	movl   $0xc010adde,0xc(%esp)
c01060c8:	c0 
c01060c9:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01060d0:	c0 
c01060d1:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01060d8:	00 
c01060d9:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01060e0:	e8 1b a3 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c01060e5:	ff 45 f4             	incl   -0xc(%ebp)
c01060e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060eb:	8b 50 08             	mov    0x8(%eax),%edx
c01060ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060f1:	01 d0                	add    %edx,%eax
c01060f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01060fc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01060ff:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106102:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106105:	81 7d ec 44 a1 12 c0 	cmpl   $0xc012a144,-0x14(%ebp)
c010610c:	0f 85 7a ff ff ff    	jne    c010608c <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0106112:	e8 6c 09 00 00       	call   c0106a83 <nr_free_pages>
c0106117:	89 c2                	mov    %eax,%edx
c0106119:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010611c:	39 c2                	cmp    %eax,%edx
c010611e:	74 24                	je     c0106144 <default_check+0xd8>
c0106120:	c7 44 24 0c ee ad 10 	movl   $0xc010adee,0xc(%esp)
c0106127:	c0 
c0106128:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c010612f:	c0 
c0106130:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0106137:	00 
c0106138:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c010613f:	e8 bc a2 ff ff       	call   c0100400 <__panic>

    basic_check();
c0106144:	e8 e6 f9 ff ff       	call   c0105b2f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106149:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106150:	e8 c3 08 00 00       	call   c0106a18 <alloc_pages>
c0106155:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0106158:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010615c:	75 24                	jne    c0106182 <default_check+0x116>
c010615e:	c7 44 24 0c 07 ae 10 	movl   $0xc010ae07,0xc(%esp)
c0106165:	c0 
c0106166:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c010616d:	c0 
c010616e:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0106175:	00 
c0106176:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c010617d:	e8 7e a2 ff ff       	call   c0100400 <__panic>
    assert(!PageProperty(p0));
c0106182:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106185:	83 c0 04             	add    $0x4,%eax
c0106188:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010618f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106192:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106195:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106198:	0f a3 10             	bt     %edx,(%eax)
c010619b:	19 c0                	sbb    %eax,%eax
c010619d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01061a0:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01061a4:	0f 95 c0             	setne  %al
c01061a7:	0f b6 c0             	movzbl %al,%eax
c01061aa:	85 c0                	test   %eax,%eax
c01061ac:	74 24                	je     c01061d2 <default_check+0x166>
c01061ae:	c7 44 24 0c 12 ae 10 	movl   $0xc010ae12,0xc(%esp)
c01061b5:	c0 
c01061b6:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01061bd:	c0 
c01061be:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01061c5:	00 
c01061c6:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01061cd:	e8 2e a2 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c01061d2:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c01061d7:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c01061dd:	89 45 80             	mov    %eax,-0x80(%ebp)
c01061e0:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01061e3:	c7 45 b0 44 a1 12 c0 	movl   $0xc012a144,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01061ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01061ed:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01061f0:	89 50 04             	mov    %edx,0x4(%eax)
c01061f3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01061f6:	8b 50 04             	mov    0x4(%eax),%edx
c01061f9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01061fc:	89 10                	mov    %edx,(%eax)
c01061fe:	c7 45 b4 44 a1 12 c0 	movl   $0xc012a144,-0x4c(%ebp)
    return list->next == list;
c0106205:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106208:	8b 40 04             	mov    0x4(%eax),%eax
c010620b:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010620e:	0f 94 c0             	sete   %al
c0106211:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106214:	85 c0                	test   %eax,%eax
c0106216:	75 24                	jne    c010623c <default_check+0x1d0>
c0106218:	c7 44 24 0c 67 ad 10 	movl   $0xc010ad67,0xc(%esp)
c010621f:	c0 
c0106220:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106227:	c0 
c0106228:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c010622f:	00 
c0106230:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106237:	e8 c4 a1 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c010623c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106243:	e8 d0 07 00 00       	call   c0106a18 <alloc_pages>
c0106248:	85 c0                	test   %eax,%eax
c010624a:	74 24                	je     c0106270 <default_check+0x204>
c010624c:	c7 44 24 0c 7e ad 10 	movl   $0xc010ad7e,0xc(%esp)
c0106253:	c0 
c0106254:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c010625b:	c0 
c010625c:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0106263:	00 
c0106264:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c010626b:	e8 90 a1 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0106270:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0106275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0106278:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c010627f:	00 00 00 

    free_pages(p0 + 2, 3);
c0106282:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106285:	83 c0 40             	add    $0x40,%eax
c0106288:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010628f:	00 
c0106290:	89 04 24             	mov    %eax,(%esp)
c0106293:	e8 b8 07 00 00       	call   c0106a50 <free_pages>
    assert(alloc_pages(4) == NULL);
c0106298:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010629f:	e8 74 07 00 00       	call   c0106a18 <alloc_pages>
c01062a4:	85 c0                	test   %eax,%eax
c01062a6:	74 24                	je     c01062cc <default_check+0x260>
c01062a8:	c7 44 24 0c 24 ae 10 	movl   $0xc010ae24,0xc(%esp)
c01062af:	c0 
c01062b0:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01062b7:	c0 
c01062b8:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c01062bf:	00 
c01062c0:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01062c7:	e8 34 a1 ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01062cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01062cf:	83 c0 40             	add    $0x40,%eax
c01062d2:	83 c0 04             	add    $0x4,%eax
c01062d5:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01062dc:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01062df:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01062e2:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01062e5:	0f a3 10             	bt     %edx,(%eax)
c01062e8:	19 c0                	sbb    %eax,%eax
c01062ea:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01062ed:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01062f1:	0f 95 c0             	setne  %al
c01062f4:	0f b6 c0             	movzbl %al,%eax
c01062f7:	85 c0                	test   %eax,%eax
c01062f9:	74 0e                	je     c0106309 <default_check+0x29d>
c01062fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01062fe:	83 c0 40             	add    $0x40,%eax
c0106301:	8b 40 08             	mov    0x8(%eax),%eax
c0106304:	83 f8 03             	cmp    $0x3,%eax
c0106307:	74 24                	je     c010632d <default_check+0x2c1>
c0106309:	c7 44 24 0c 3c ae 10 	movl   $0xc010ae3c,0xc(%esp)
c0106310:	c0 
c0106311:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106318:	c0 
c0106319:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0106320:	00 
c0106321:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106328:	e8 d3 a0 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010632d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0106334:	e8 df 06 00 00       	call   c0106a18 <alloc_pages>
c0106339:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010633c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106340:	75 24                	jne    c0106366 <default_check+0x2fa>
c0106342:	c7 44 24 0c 68 ae 10 	movl   $0xc010ae68,0xc(%esp)
c0106349:	c0 
c010634a:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106351:	c0 
c0106352:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0106359:	00 
c010635a:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106361:	e8 9a a0 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106366:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010636d:	e8 a6 06 00 00       	call   c0106a18 <alloc_pages>
c0106372:	85 c0                	test   %eax,%eax
c0106374:	74 24                	je     c010639a <default_check+0x32e>
c0106376:	c7 44 24 0c 7e ad 10 	movl   $0xc010ad7e,0xc(%esp)
c010637d:	c0 
c010637e:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106385:	c0 
c0106386:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c010638d:	00 
c010638e:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106395:	e8 66 a0 ff ff       	call   c0100400 <__panic>
    assert(p0 + 2 == p1);
c010639a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010639d:	83 c0 40             	add    $0x40,%eax
c01063a0:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01063a3:	74 24                	je     c01063c9 <default_check+0x35d>
c01063a5:	c7 44 24 0c 86 ae 10 	movl   $0xc010ae86,0xc(%esp)
c01063ac:	c0 
c01063ad:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01063b4:	c0 
c01063b5:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01063bc:	00 
c01063bd:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01063c4:	e8 37 a0 ff ff       	call   c0100400 <__panic>

    p2 = p0 + 1;
c01063c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063cc:	83 c0 20             	add    $0x20,%eax
c01063cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01063d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01063d9:	00 
c01063da:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063dd:	89 04 24             	mov    %eax,(%esp)
c01063e0:	e8 6b 06 00 00       	call   c0106a50 <free_pages>
    free_pages(p1, 3);
c01063e5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01063ec:	00 
c01063ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01063f0:	89 04 24             	mov    %eax,(%esp)
c01063f3:	e8 58 06 00 00       	call   c0106a50 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01063f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063fb:	83 c0 04             	add    $0x4,%eax
c01063fe:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0106405:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106408:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010640b:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010640e:	0f a3 10             	bt     %edx,(%eax)
c0106411:	19 c0                	sbb    %eax,%eax
c0106413:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0106416:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010641a:	0f 95 c0             	setne  %al
c010641d:	0f b6 c0             	movzbl %al,%eax
c0106420:	85 c0                	test   %eax,%eax
c0106422:	74 0b                	je     c010642f <default_check+0x3c3>
c0106424:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106427:	8b 40 08             	mov    0x8(%eax),%eax
c010642a:	83 f8 01             	cmp    $0x1,%eax
c010642d:	74 24                	je     c0106453 <default_check+0x3e7>
c010642f:	c7 44 24 0c 94 ae 10 	movl   $0xc010ae94,0xc(%esp)
c0106436:	c0 
c0106437:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c010643e:	c0 
c010643f:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0106446:	00 
c0106447:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c010644e:	e8 ad 9f ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0106453:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106456:	83 c0 04             	add    $0x4,%eax
c0106459:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0106460:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106463:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106466:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106469:	0f a3 10             	bt     %edx,(%eax)
c010646c:	19 c0                	sbb    %eax,%eax
c010646e:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0106471:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0106475:	0f 95 c0             	setne  %al
c0106478:	0f b6 c0             	movzbl %al,%eax
c010647b:	85 c0                	test   %eax,%eax
c010647d:	74 0b                	je     c010648a <default_check+0x41e>
c010647f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106482:	8b 40 08             	mov    0x8(%eax),%eax
c0106485:	83 f8 03             	cmp    $0x3,%eax
c0106488:	74 24                	je     c01064ae <default_check+0x442>
c010648a:	c7 44 24 0c bc ae 10 	movl   $0xc010aebc,0xc(%esp)
c0106491:	c0 
c0106492:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106499:	c0 
c010649a:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01064a1:	00 
c01064a2:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01064a9:	e8 52 9f ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01064ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01064b5:	e8 5e 05 00 00       	call   c0106a18 <alloc_pages>
c01064ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01064bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01064c0:	83 e8 20             	sub    $0x20,%eax
c01064c3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01064c6:	74 24                	je     c01064ec <default_check+0x480>
c01064c8:	c7 44 24 0c e2 ae 10 	movl   $0xc010aee2,0xc(%esp)
c01064cf:	c0 
c01064d0:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01064d7:	c0 
c01064d8:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01064df:	00 
c01064e0:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01064e7:	e8 14 9f ff ff       	call   c0100400 <__panic>
    free_page(p0);
c01064ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01064f3:	00 
c01064f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064f7:	89 04 24             	mov    %eax,(%esp)
c01064fa:	e8 51 05 00 00       	call   c0106a50 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01064ff:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0106506:	e8 0d 05 00 00       	call   c0106a18 <alloc_pages>
c010650b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010650e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106511:	83 c0 20             	add    $0x20,%eax
c0106514:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106517:	74 24                	je     c010653d <default_check+0x4d1>
c0106519:	c7 44 24 0c 00 af 10 	movl   $0xc010af00,0xc(%esp)
c0106520:	c0 
c0106521:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106528:	c0 
c0106529:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0106530:	00 
c0106531:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106538:	e8 c3 9e ff ff       	call   c0100400 <__panic>

    free_pages(p0, 2);
c010653d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106544:	00 
c0106545:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106548:	89 04 24             	mov    %eax,(%esp)
c010654b:	e8 00 05 00 00       	call   c0106a50 <free_pages>
    free_page(p2);
c0106550:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106557:	00 
c0106558:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010655b:	89 04 24             	mov    %eax,(%esp)
c010655e:	e8 ed 04 00 00       	call   c0106a50 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0106563:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010656a:	e8 a9 04 00 00       	call   c0106a18 <alloc_pages>
c010656f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106572:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106576:	75 24                	jne    c010659c <default_check+0x530>
c0106578:	c7 44 24 0c 20 af 10 	movl   $0xc010af20,0xc(%esp)
c010657f:	c0 
c0106580:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c0106587:	c0 
c0106588:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c010658f:	00 
c0106590:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c0106597:	e8 64 9e ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c010659c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01065a3:	e8 70 04 00 00       	call   c0106a18 <alloc_pages>
c01065a8:	85 c0                	test   %eax,%eax
c01065aa:	74 24                	je     c01065d0 <default_check+0x564>
c01065ac:	c7 44 24 0c 7e ad 10 	movl   $0xc010ad7e,0xc(%esp)
c01065b3:	c0 
c01065b4:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01065bb:	c0 
c01065bc:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c01065c3:	00 
c01065c4:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01065cb:	e8 30 9e ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c01065d0:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01065d5:	85 c0                	test   %eax,%eax
c01065d7:	74 24                	je     c01065fd <default_check+0x591>
c01065d9:	c7 44 24 0c d1 ad 10 	movl   $0xc010add1,0xc(%esp)
c01065e0:	c0 
c01065e1:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01065e8:	c0 
c01065e9:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01065f0:	00 
c01065f1:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01065f8:	e8 03 9e ff ff       	call   c0100400 <__panic>
    nr_free = nr_free_store;
c01065fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106600:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c

    free_list = free_list_store;
c0106605:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106608:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010660b:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c0106610:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148
    free_pages(p0, 5);
c0106616:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010661d:	00 
c010661e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106621:	89 04 24             	mov    %eax,(%esp)
c0106624:	e8 27 04 00 00       	call   c0106a50 <free_pages>

    le = &free_list;
c0106629:	c7 45 ec 44 a1 12 c0 	movl   $0xc012a144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106630:	eb 5a                	jmp    c010668c <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c0106632:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106635:	8b 40 04             	mov    0x4(%eax),%eax
c0106638:	8b 00                	mov    (%eax),%eax
c010663a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010663d:	75 0d                	jne    c010664c <default_check+0x5e0>
c010663f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106642:	8b 00                	mov    (%eax),%eax
c0106644:	8b 40 04             	mov    0x4(%eax),%eax
c0106647:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010664a:	74 24                	je     c0106670 <default_check+0x604>
c010664c:	c7 44 24 0c 40 af 10 	movl   $0xc010af40,0xc(%esp)
c0106653:	c0 
c0106654:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c010665b:	c0 
c010665c:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0106663:	00 
c0106664:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c010666b:	e8 90 9d ff ff       	call   c0100400 <__panic>
        struct Page *p = le2page(le, page_link);
c0106670:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106673:	83 e8 0c             	sub    $0xc,%eax
c0106676:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0106679:	ff 4d f4             	decl   -0xc(%ebp)
c010667c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010667f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106682:	8b 40 08             	mov    0x8(%eax),%eax
c0106685:	29 c2                	sub    %eax,%edx
c0106687:	89 d0                	mov    %edx,%eax
c0106689:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010668c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010668f:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0106692:	8b 45 88             	mov    -0x78(%ebp),%eax
c0106695:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106698:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010669b:	81 7d ec 44 a1 12 c0 	cmpl   $0xc012a144,-0x14(%ebp)
c01066a2:	75 8e                	jne    c0106632 <default_check+0x5c6>
    }
    assert(count == 0);
c01066a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066a8:	74 24                	je     c01066ce <default_check+0x662>
c01066aa:	c7 44 24 0c 6d af 10 	movl   $0xc010af6d,0xc(%esp)
c01066b1:	c0 
c01066b2:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01066b9:	c0 
c01066ba:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c01066c1:	00 
c01066c2:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01066c9:	e8 32 9d ff ff       	call   c0100400 <__panic>
    assert(total == 0);
c01066ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01066d2:	74 24                	je     c01066f8 <default_check+0x68c>
c01066d4:	c7 44 24 0c 78 af 10 	movl   $0xc010af78,0xc(%esp)
c01066db:	c0 
c01066dc:	c7 44 24 08 de ab 10 	movl   $0xc010abde,0x8(%esp)
c01066e3:	c0 
c01066e4:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01066eb:	00 
c01066ec:	c7 04 24 f3 ab 10 c0 	movl   $0xc010abf3,(%esp)
c01066f3:	e8 08 9d ff ff       	call   c0100400 <__panic>
}
c01066f8:	90                   	nop
c01066f9:	c9                   	leave  
c01066fa:	c3                   	ret    

c01066fb <page2ppn>:
page2ppn(struct Page *page) {
c01066fb:	55                   	push   %ebp
c01066fc:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01066fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106701:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c0106707:	29 d0                	sub    %edx,%eax
c0106709:	c1 f8 05             	sar    $0x5,%eax
}
c010670c:	5d                   	pop    %ebp
c010670d:	c3                   	ret    

c010670e <page2pa>:
page2pa(struct Page *page) {
c010670e:	55                   	push   %ebp
c010670f:	89 e5                	mov    %esp,%ebp
c0106711:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0106714:	8b 45 08             	mov    0x8(%ebp),%eax
c0106717:	89 04 24             	mov    %eax,(%esp)
c010671a:	e8 dc ff ff ff       	call   c01066fb <page2ppn>
c010671f:	c1 e0 0c             	shl    $0xc,%eax
}
c0106722:	c9                   	leave  
c0106723:	c3                   	ret    

c0106724 <pa2page>:
pa2page(uintptr_t pa) {
c0106724:	55                   	push   %ebp
c0106725:	89 e5                	mov    %esp,%ebp
c0106727:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010672a:	8b 45 08             	mov    0x8(%ebp),%eax
c010672d:	c1 e8 0c             	shr    $0xc,%eax
c0106730:	89 c2                	mov    %eax,%edx
c0106732:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106737:	39 c2                	cmp    %eax,%edx
c0106739:	72 1c                	jb     c0106757 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010673b:	c7 44 24 08 b4 af 10 	movl   $0xc010afb4,0x8(%esp)
c0106742:	c0 
c0106743:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010674a:	00 
c010674b:	c7 04 24 d3 af 10 c0 	movl   $0xc010afd3,(%esp)
c0106752:	e8 a9 9c ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0106757:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c010675c:	8b 55 08             	mov    0x8(%ebp),%edx
c010675f:	c1 ea 0c             	shr    $0xc,%edx
c0106762:	c1 e2 05             	shl    $0x5,%edx
c0106765:	01 d0                	add    %edx,%eax
}
c0106767:	c9                   	leave  
c0106768:	c3                   	ret    

c0106769 <page2kva>:
page2kva(struct Page *page) {
c0106769:	55                   	push   %ebp
c010676a:	89 e5                	mov    %esp,%ebp
c010676c:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010676f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106772:	89 04 24             	mov    %eax,(%esp)
c0106775:	e8 94 ff ff ff       	call   c010670e <page2pa>
c010677a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010677d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106780:	c1 e8 0c             	shr    $0xc,%eax
c0106783:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106786:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010678b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010678e:	72 23                	jb     c01067b3 <page2kva+0x4a>
c0106790:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106793:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106797:	c7 44 24 08 e4 af 10 	movl   $0xc010afe4,0x8(%esp)
c010679e:	c0 
c010679f:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01067a6:	00 
c01067a7:	c7 04 24 d3 af 10 c0 	movl   $0xc010afd3,(%esp)
c01067ae:	e8 4d 9c ff ff       	call   c0100400 <__panic>
c01067b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067b6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01067bb:	c9                   	leave  
c01067bc:	c3                   	ret    

c01067bd <pte2page>:
pte2page(pte_t pte) {
c01067bd:	55                   	push   %ebp
c01067be:	89 e5                	mov    %esp,%ebp
c01067c0:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01067c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01067c6:	83 e0 01             	and    $0x1,%eax
c01067c9:	85 c0                	test   %eax,%eax
c01067cb:	75 1c                	jne    c01067e9 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01067cd:	c7 44 24 08 08 b0 10 	movl   $0xc010b008,0x8(%esp)
c01067d4:	c0 
c01067d5:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01067dc:	00 
c01067dd:	c7 04 24 d3 af 10 c0 	movl   $0xc010afd3,(%esp)
c01067e4:	e8 17 9c ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c01067e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01067f1:	89 04 24             	mov    %eax,(%esp)
c01067f4:	e8 2b ff ff ff       	call   c0106724 <pa2page>
}
c01067f9:	c9                   	leave  
c01067fa:	c3                   	ret    

c01067fb <pde2page>:
pde2page(pde_t pde) {
c01067fb:	55                   	push   %ebp
c01067fc:	89 e5                	mov    %esp,%ebp
c01067fe:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106801:	8b 45 08             	mov    0x8(%ebp),%eax
c0106804:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106809:	89 04 24             	mov    %eax,(%esp)
c010680c:	e8 13 ff ff ff       	call   c0106724 <pa2page>
}
c0106811:	c9                   	leave  
c0106812:	c3                   	ret    

c0106813 <page_ref>:
page_ref(struct Page *page) {
c0106813:	55                   	push   %ebp
c0106814:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106816:	8b 45 08             	mov    0x8(%ebp),%eax
c0106819:	8b 00                	mov    (%eax),%eax
}
c010681b:	5d                   	pop    %ebp
c010681c:	c3                   	ret    

c010681d <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010681d:	55                   	push   %ebp
c010681e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106820:	8b 45 08             	mov    0x8(%ebp),%eax
c0106823:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106826:	89 10                	mov    %edx,(%eax)
}
c0106828:	90                   	nop
c0106829:	5d                   	pop    %ebp
c010682a:	c3                   	ret    

c010682b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010682b:	55                   	push   %ebp
c010682c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010682e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106831:	8b 00                	mov    (%eax),%eax
c0106833:	8d 50 01             	lea    0x1(%eax),%edx
c0106836:	8b 45 08             	mov    0x8(%ebp),%eax
c0106839:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010683b:	8b 45 08             	mov    0x8(%ebp),%eax
c010683e:	8b 00                	mov    (%eax),%eax
}
c0106840:	5d                   	pop    %ebp
c0106841:	c3                   	ret    

c0106842 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0106842:	55                   	push   %ebp
c0106843:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0106845:	8b 45 08             	mov    0x8(%ebp),%eax
c0106848:	8b 00                	mov    (%eax),%eax
c010684a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010684d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106850:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106852:	8b 45 08             	mov    0x8(%ebp),%eax
c0106855:	8b 00                	mov    (%eax),%eax
}
c0106857:	5d                   	pop    %ebp
c0106858:	c3                   	ret    

c0106859 <__intr_save>:
__intr_save(void) {
c0106859:	55                   	push   %ebp
c010685a:	89 e5                	mov    %esp,%ebp
c010685c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010685f:	9c                   	pushf  
c0106860:	58                   	pop    %eax
c0106861:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106864:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0106867:	25 00 02 00 00       	and    $0x200,%eax
c010686c:	85 c0                	test   %eax,%eax
c010686e:	74 0c                	je     c010687c <__intr_save+0x23>
        intr_disable();
c0106870:	e8 73 b8 ff ff       	call   c01020e8 <intr_disable>
        return 1;
c0106875:	b8 01 00 00 00       	mov    $0x1,%eax
c010687a:	eb 05                	jmp    c0106881 <__intr_save+0x28>
    return 0;
c010687c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106881:	c9                   	leave  
c0106882:	c3                   	ret    

c0106883 <__intr_restore>:
__intr_restore(bool flag) {
c0106883:	55                   	push   %ebp
c0106884:	89 e5                	mov    %esp,%ebp
c0106886:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0106889:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010688d:	74 05                	je     c0106894 <__intr_restore+0x11>
        intr_enable();
c010688f:	e8 4d b8 ff ff       	call   c01020e1 <intr_enable>
}
c0106894:	90                   	nop
c0106895:	c9                   	leave  
c0106896:	c3                   	ret    

c0106897 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0106897:	55                   	push   %ebp
c0106898:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010689a:	8b 45 08             	mov    0x8(%ebp),%eax
c010689d:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01068a0:	b8 23 00 00 00       	mov    $0x23,%eax
c01068a5:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01068a7:	b8 23 00 00 00       	mov    $0x23,%eax
c01068ac:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01068ae:	b8 10 00 00 00       	mov    $0x10,%eax
c01068b3:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01068b5:	b8 10 00 00 00       	mov    $0x10,%eax
c01068ba:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01068bc:	b8 10 00 00 00       	mov    $0x10,%eax
c01068c1:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01068c3:	ea ca 68 10 c0 08 00 	ljmp   $0x8,$0xc01068ca
}
c01068ca:	90                   	nop
c01068cb:	5d                   	pop    %ebp
c01068cc:	c3                   	ret    

c01068cd <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01068cd:	55                   	push   %ebp
c01068ce:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01068d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01068d3:	a3 a4 7f 12 c0       	mov    %eax,0xc0127fa4
}
c01068d8:	90                   	nop
c01068d9:	5d                   	pop    %ebp
c01068da:	c3                   	ret    

c01068db <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01068db:	55                   	push   %ebp
c01068dc:	89 e5                	mov    %esp,%ebp
c01068de:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01068e1:	b8 00 40 12 c0       	mov    $0xc0124000,%eax
c01068e6:	89 04 24             	mov    %eax,(%esp)
c01068e9:	e8 df ff ff ff       	call   c01068cd <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01068ee:	66 c7 05 a8 7f 12 c0 	movw   $0x10,0xc0127fa8
c01068f5:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01068f7:	66 c7 05 68 4a 12 c0 	movw   $0x68,0xc0124a68
c01068fe:	68 00 
c0106900:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c0106905:	0f b7 c0             	movzwl %ax,%eax
c0106908:	66 a3 6a 4a 12 c0    	mov    %ax,0xc0124a6a
c010690e:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c0106913:	c1 e8 10             	shr    $0x10,%eax
c0106916:	a2 6c 4a 12 c0       	mov    %al,0xc0124a6c
c010691b:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106922:	24 f0                	and    $0xf0,%al
c0106924:	0c 09                	or     $0x9,%al
c0106926:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c010692b:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106932:	24 ef                	and    $0xef,%al
c0106934:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106939:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106940:	24 9f                	and    $0x9f,%al
c0106942:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106947:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c010694e:	0c 80                	or     $0x80,%al
c0106950:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106955:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c010695c:	24 f0                	and    $0xf0,%al
c010695e:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106963:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c010696a:	24 ef                	and    $0xef,%al
c010696c:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106971:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106978:	24 df                	and    $0xdf,%al
c010697a:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c010697f:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106986:	0c 40                	or     $0x40,%al
c0106988:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c010698d:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106994:	24 7f                	and    $0x7f,%al
c0106996:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c010699b:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c01069a0:	c1 e8 18             	shr    $0x18,%eax
c01069a3:	a2 6f 4a 12 c0       	mov    %al,0xc0124a6f

    // reload all segment registers
    lgdt(&gdt_pd);
c01069a8:	c7 04 24 70 4a 12 c0 	movl   $0xc0124a70,(%esp)
c01069af:	e8 e3 fe ff ff       	call   c0106897 <lgdt>
c01069b4:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01069ba:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01069be:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01069c1:	90                   	nop
c01069c2:	c9                   	leave  
c01069c3:	c3                   	ret    

c01069c4 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01069c4:	55                   	push   %ebp
c01069c5:	89 e5                	mov    %esp,%ebp
c01069c7:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01069ca:	c7 05 50 a1 12 c0 98 	movl   $0xc010af98,0xc012a150
c01069d1:	af 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01069d4:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c01069d9:	8b 00                	mov    (%eax),%eax
c01069db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069df:	c7 04 24 34 b0 10 c0 	movl   $0xc010b034,(%esp)
c01069e6:	e8 be 98 ff ff       	call   c01002a9 <cprintf>
    pmm_manager->init();
c01069eb:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c01069f0:	8b 40 04             	mov    0x4(%eax),%eax
c01069f3:	ff d0                	call   *%eax
}
c01069f5:	90                   	nop
c01069f6:	c9                   	leave  
c01069f7:	c3                   	ret    

c01069f8 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01069f8:	55                   	push   %ebp
c01069f9:	89 e5                	mov    %esp,%ebp
c01069fb:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01069fe:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106a03:	8b 40 08             	mov    0x8(%eax),%eax
c0106a06:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a09:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a0d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a10:	89 14 24             	mov    %edx,(%esp)
c0106a13:	ff d0                	call   *%eax
}
c0106a15:	90                   	nop
c0106a16:	c9                   	leave  
c0106a17:	c3                   	ret    

c0106a18 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0106a18:	55                   	push   %ebp
c0106a19:	89 e5                	mov    %esp,%ebp
c0106a1b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106a1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0106a25:	e8 2f fe ff ff       	call   c0106859 <__intr_save>
c0106a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0106a2d:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106a32:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a35:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a38:	89 14 24             	mov    %edx,(%esp)
c0106a3b:	ff d0                	call   *%eax
c0106a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0106a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a43:	89 04 24             	mov    %eax,(%esp)
c0106a46:	e8 38 fe ff ff       	call   c0106883 <__intr_restore>
    return page;
c0106a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106a4e:	c9                   	leave  
c0106a4f:	c3                   	ret    

c0106a50 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0106a50:	55                   	push   %ebp
c0106a51:	89 e5                	mov    %esp,%ebp
c0106a53:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0106a56:	e8 fe fd ff ff       	call   c0106859 <__intr_save>
c0106a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0106a5e:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106a63:	8b 40 10             	mov    0x10(%eax),%eax
c0106a66:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a6d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a70:	89 14 24             	mov    %edx,(%esp)
c0106a73:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0106a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a78:	89 04 24             	mov    %eax,(%esp)
c0106a7b:	e8 03 fe ff ff       	call   c0106883 <__intr_restore>
}
c0106a80:	90                   	nop
c0106a81:	c9                   	leave  
c0106a82:	c3                   	ret    

c0106a83 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0106a83:	55                   	push   %ebp
c0106a84:	89 e5                	mov    %esp,%ebp
c0106a86:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0106a89:	e8 cb fd ff ff       	call   c0106859 <__intr_save>
c0106a8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0106a91:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106a96:	8b 40 14             	mov    0x14(%eax),%eax
c0106a99:	ff d0                	call   *%eax
c0106a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0106a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106aa1:	89 04 24             	mov    %eax,(%esp)
c0106aa4:	e8 da fd ff ff       	call   c0106883 <__intr_restore>
    return ret;
c0106aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0106aac:	c9                   	leave  
c0106aad:	c3                   	ret    

c0106aae <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0106aae:	55                   	push   %ebp
c0106aaf:	89 e5                	mov    %esp,%ebp
c0106ab1:	57                   	push   %edi
c0106ab2:	56                   	push   %esi
c0106ab3:	53                   	push   %ebx
c0106ab4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106aba:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0106ac1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106ac8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106acf:	c7 04 24 4b b0 10 c0 	movl   $0xc010b04b,(%esp)
c0106ad6:	e8 ce 97 ff ff       	call   c01002a9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106adb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106ae2:	e9 22 01 00 00       	jmp    c0106c09 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106ae7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106aea:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106aed:	89 d0                	mov    %edx,%eax
c0106aef:	c1 e0 02             	shl    $0x2,%eax
c0106af2:	01 d0                	add    %edx,%eax
c0106af4:	c1 e0 02             	shl    $0x2,%eax
c0106af7:	01 c8                	add    %ecx,%eax
c0106af9:	8b 50 08             	mov    0x8(%eax),%edx
c0106afc:	8b 40 04             	mov    0x4(%eax),%eax
c0106aff:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0106b02:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0106b05:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106b08:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106b0b:	89 d0                	mov    %edx,%eax
c0106b0d:	c1 e0 02             	shl    $0x2,%eax
c0106b10:	01 d0                	add    %edx,%eax
c0106b12:	c1 e0 02             	shl    $0x2,%eax
c0106b15:	01 c8                	add    %ecx,%eax
c0106b17:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106b1a:	8b 58 10             	mov    0x10(%eax),%ebx
c0106b1d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106b20:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106b23:	01 c8                	add    %ecx,%eax
c0106b25:	11 da                	adc    %ebx,%edx
c0106b27:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106b2a:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106b2d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106b30:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106b33:	89 d0                	mov    %edx,%eax
c0106b35:	c1 e0 02             	shl    $0x2,%eax
c0106b38:	01 d0                	add    %edx,%eax
c0106b3a:	c1 e0 02             	shl    $0x2,%eax
c0106b3d:	01 c8                	add    %ecx,%eax
c0106b3f:	83 c0 14             	add    $0x14,%eax
c0106b42:	8b 00                	mov    (%eax),%eax
c0106b44:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0106b47:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106b4a:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106b4d:	83 c0 ff             	add    $0xffffffff,%eax
c0106b50:	83 d2 ff             	adc    $0xffffffff,%edx
c0106b53:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0106b59:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0106b5f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106b62:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106b65:	89 d0                	mov    %edx,%eax
c0106b67:	c1 e0 02             	shl    $0x2,%eax
c0106b6a:	01 d0                	add    %edx,%eax
c0106b6c:	c1 e0 02             	shl    $0x2,%eax
c0106b6f:	01 c8                	add    %ecx,%eax
c0106b71:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106b74:	8b 58 10             	mov    0x10(%eax),%ebx
c0106b77:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106b7a:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0106b7e:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0106b84:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0106b8a:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106b8e:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106b92:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106b95:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106b98:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106b9c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106ba0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0106ba4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0106ba8:	c7 04 24 58 b0 10 c0 	movl   $0xc010b058,(%esp)
c0106baf:	e8 f5 96 ff ff       	call   c01002a9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0106bb4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106bb7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106bba:	89 d0                	mov    %edx,%eax
c0106bbc:	c1 e0 02             	shl    $0x2,%eax
c0106bbf:	01 d0                	add    %edx,%eax
c0106bc1:	c1 e0 02             	shl    $0x2,%eax
c0106bc4:	01 c8                	add    %ecx,%eax
c0106bc6:	83 c0 14             	add    $0x14,%eax
c0106bc9:	8b 00                	mov    (%eax),%eax
c0106bcb:	83 f8 01             	cmp    $0x1,%eax
c0106bce:	75 36                	jne    c0106c06 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0106bd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bd3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106bd6:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0106bd9:	77 2b                	ja     c0106c06 <page_init+0x158>
c0106bdb:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0106bde:	72 05                	jb     c0106be5 <page_init+0x137>
c0106be0:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0106be3:	73 21                	jae    c0106c06 <page_init+0x158>
c0106be5:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0106be9:	77 1b                	ja     c0106c06 <page_init+0x158>
c0106beb:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0106bef:	72 09                	jb     c0106bfa <page_init+0x14c>
c0106bf1:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0106bf8:	77 0c                	ja     c0106c06 <page_init+0x158>
                maxpa = end;
c0106bfa:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106bfd:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106c00:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106c03:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0106c06:	ff 45 dc             	incl   -0x24(%ebp)
c0106c09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106c0c:	8b 00                	mov    (%eax),%eax
c0106c0e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106c11:	0f 8c d0 fe ff ff    	jl     c0106ae7 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0106c17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c1b:	72 1d                	jb     c0106c3a <page_init+0x18c>
c0106c1d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c21:	77 09                	ja     c0106c2c <page_init+0x17e>
c0106c23:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106c2a:	76 0e                	jbe    c0106c3a <page_init+0x18c>
        maxpa = KMEMSIZE;
c0106c2c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0106c33:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106c3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c3d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106c40:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106c44:	c1 ea 0c             	shr    $0xc,%edx
c0106c47:	89 c1                	mov    %eax,%ecx
c0106c49:	89 d3                	mov    %edx,%ebx
c0106c4b:	89 c8                	mov    %ecx,%eax
c0106c4d:	a3 80 7f 12 c0       	mov    %eax,0xc0127f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106c52:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0106c59:	b8 64 a1 12 c0       	mov    $0xc012a164,%eax
c0106c5e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106c61:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106c64:	01 d0                	add    %edx,%eax
c0106c66:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0106c69:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106c6c:	ba 00 00 00 00       	mov    $0x0,%edx
c0106c71:	f7 75 c0             	divl   -0x40(%ebp)
c0106c74:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106c77:	29 d0                	sub    %edx,%eax
c0106c79:	a3 58 a1 12 c0       	mov    %eax,0xc012a158

    for (i = 0; i < npage; i ++) {
c0106c7e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106c85:	eb 26                	jmp    c0106cad <page_init+0x1ff>
        SetPageReserved(pages + i);
c0106c87:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0106c8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106c8f:	c1 e2 05             	shl    $0x5,%edx
c0106c92:	01 d0                	add    %edx,%eax
c0106c94:	83 c0 04             	add    $0x4,%eax
c0106c97:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0106c9e:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106ca1:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106ca4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106ca7:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0106caa:	ff 45 dc             	incl   -0x24(%ebp)
c0106cad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106cb0:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106cb5:	39 c2                	cmp    %eax,%edx
c0106cb7:	72 ce                	jb     c0106c87 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0106cb9:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106cbe:	c1 e0 05             	shl    $0x5,%eax
c0106cc1:	89 c2                	mov    %eax,%edx
c0106cc3:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0106cc8:	01 d0                	add    %edx,%eax
c0106cca:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106ccd:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0106cd4:	77 23                	ja     c0106cf9 <page_init+0x24b>
c0106cd6:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106cdd:	c7 44 24 08 88 b0 10 	movl   $0xc010b088,0x8(%esp)
c0106ce4:	c0 
c0106ce5:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0106cec:	00 
c0106ced:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0106cf4:	e8 07 97 ff ff       	call   c0100400 <__panic>
c0106cf9:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106cfc:	05 00 00 00 40       	add    $0x40000000,%eax
c0106d01:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0106d04:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106d0b:	e9 69 01 00 00       	jmp    c0106e79 <page_init+0x3cb>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106d10:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106d13:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d16:	89 d0                	mov    %edx,%eax
c0106d18:	c1 e0 02             	shl    $0x2,%eax
c0106d1b:	01 d0                	add    %edx,%eax
c0106d1d:	c1 e0 02             	shl    $0x2,%eax
c0106d20:	01 c8                	add    %ecx,%eax
c0106d22:	8b 50 08             	mov    0x8(%eax),%edx
c0106d25:	8b 40 04             	mov    0x4(%eax),%eax
c0106d28:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106d2b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106d2e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106d31:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d34:	89 d0                	mov    %edx,%eax
c0106d36:	c1 e0 02             	shl    $0x2,%eax
c0106d39:	01 d0                	add    %edx,%eax
c0106d3b:	c1 e0 02             	shl    $0x2,%eax
c0106d3e:	01 c8                	add    %ecx,%eax
c0106d40:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106d43:	8b 58 10             	mov    0x10(%eax),%ebx
c0106d46:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d49:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106d4c:	01 c8                	add    %ecx,%eax
c0106d4e:	11 da                	adc    %ebx,%edx
c0106d50:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106d53:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0106d56:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106d59:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d5c:	89 d0                	mov    %edx,%eax
c0106d5e:	c1 e0 02             	shl    $0x2,%eax
c0106d61:	01 d0                	add    %edx,%eax
c0106d63:	c1 e0 02             	shl    $0x2,%eax
c0106d66:	01 c8                	add    %ecx,%eax
c0106d68:	83 c0 14             	add    $0x14,%eax
c0106d6b:	8b 00                	mov    (%eax),%eax
c0106d6d:	83 f8 01             	cmp    $0x1,%eax
c0106d70:	0f 85 00 01 00 00    	jne    c0106e76 <page_init+0x3c8>
            if (begin < freemem) {
c0106d76:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106d79:	ba 00 00 00 00       	mov    $0x0,%edx
c0106d7e:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106d81:	77 17                	ja     c0106d9a <page_init+0x2ec>
c0106d83:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106d86:	72 05                	jb     c0106d8d <page_init+0x2df>
c0106d88:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0106d8b:	73 0d                	jae    c0106d9a <page_init+0x2ec>
                begin = freemem;
c0106d8d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106d90:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106d93:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0106d9a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106d9e:	72 1d                	jb     c0106dbd <page_init+0x30f>
c0106da0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106da4:	77 09                	ja     c0106daf <page_init+0x301>
c0106da6:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0106dad:	76 0e                	jbe    c0106dbd <page_init+0x30f>
                end = KMEMSIZE;
c0106daf:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0106db6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0106dbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106dc0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106dc3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106dc6:	0f 87 aa 00 00 00    	ja     c0106e76 <page_init+0x3c8>
c0106dcc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106dcf:	72 09                	jb     c0106dda <page_init+0x32c>
c0106dd1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106dd4:	0f 83 9c 00 00 00    	jae    c0106e76 <page_init+0x3c8>
                begin = ROUNDUP(begin, PGSIZE);
c0106dda:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0106de1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106de4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106de7:	01 d0                	add    %edx,%eax
c0106de9:	48                   	dec    %eax
c0106dea:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0106ded:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106df0:	ba 00 00 00 00       	mov    $0x0,%edx
c0106df5:	f7 75 b0             	divl   -0x50(%ebp)
c0106df8:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106dfb:	29 d0                	sub    %edx,%eax
c0106dfd:	ba 00 00 00 00       	mov    $0x0,%edx
c0106e02:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106e05:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106e08:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106e0b:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0106e0e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106e11:	ba 00 00 00 00       	mov    $0x0,%edx
c0106e16:	89 c3                	mov    %eax,%ebx
c0106e18:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0106e1e:	89 de                	mov    %ebx,%esi
c0106e20:	89 d0                	mov    %edx,%eax
c0106e22:	83 e0 00             	and    $0x0,%eax
c0106e25:	89 c7                	mov    %eax,%edi
c0106e27:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0106e2a:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0106e2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106e30:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e33:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106e36:	77 3e                	ja     c0106e76 <page_init+0x3c8>
c0106e38:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106e3b:	72 05                	jb     c0106e42 <page_init+0x394>
c0106e3d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106e40:	73 34                	jae    c0106e76 <page_init+0x3c8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0106e42:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106e45:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106e48:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0106e4b:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0106e4e:	89 c1                	mov    %eax,%ecx
c0106e50:	89 d3                	mov    %edx,%ebx
c0106e52:	89 c8                	mov    %ecx,%eax
c0106e54:	89 da                	mov    %ebx,%edx
c0106e56:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106e5a:	c1 ea 0c             	shr    $0xc,%edx
c0106e5d:	89 c3                	mov    %eax,%ebx
c0106e5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106e62:	89 04 24             	mov    %eax,(%esp)
c0106e65:	e8 ba f8 ff ff       	call   c0106724 <pa2page>
c0106e6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106e6e:	89 04 24             	mov    %eax,(%esp)
c0106e71:	e8 82 fb ff ff       	call   c01069f8 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0106e76:	ff 45 dc             	incl   -0x24(%ebp)
c0106e79:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106e7c:	8b 00                	mov    (%eax),%eax
c0106e7e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106e81:	0f 8c 89 fe ff ff    	jl     c0106d10 <page_init+0x262>
                }
            }
        }
    }
}
c0106e87:	90                   	nop
c0106e88:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0106e8e:	5b                   	pop    %ebx
c0106e8f:	5e                   	pop    %esi
c0106e90:	5f                   	pop    %edi
c0106e91:	5d                   	pop    %ebp
c0106e92:	c3                   	ret    

c0106e93 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0106e93:	55                   	push   %ebp
c0106e94:	89 e5                	mov    %esp,%ebp
c0106e96:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0106e99:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e9c:	33 45 14             	xor    0x14(%ebp),%eax
c0106e9f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106ea4:	85 c0                	test   %eax,%eax
c0106ea6:	74 24                	je     c0106ecc <boot_map_segment+0x39>
c0106ea8:	c7 44 24 0c ba b0 10 	movl   $0xc010b0ba,0xc(%esp)
c0106eaf:	c0 
c0106eb0:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0106eb7:	c0 
c0106eb8:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106ebf:	00 
c0106ec0:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0106ec7:	e8 34 95 ff ff       	call   c0100400 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0106ecc:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0106ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ed6:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106edb:	89 c2                	mov    %eax,%edx
c0106edd:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ee0:	01 c2                	add    %eax,%edx
c0106ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ee5:	01 d0                	add    %edx,%eax
c0106ee7:	48                   	dec    %eax
c0106ee8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106eeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106eee:	ba 00 00 00 00       	mov    $0x0,%edx
c0106ef3:	f7 75 f0             	divl   -0x10(%ebp)
c0106ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ef9:	29 d0                	sub    %edx,%eax
c0106efb:	c1 e8 0c             	shr    $0xc,%eax
c0106efe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0106f01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f04:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106f07:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106f0f:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0106f12:	8b 45 14             	mov    0x14(%ebp),%eax
c0106f15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106f20:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106f23:	eb 68                	jmp    c0106f8d <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0106f25:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106f2c:	00 
c0106f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f34:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f37:	89 04 24             	mov    %eax,(%esp)
c0106f3a:	e8 81 01 00 00       	call   c01070c0 <get_pte>
c0106f3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0106f42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106f46:	75 24                	jne    c0106f6c <boot_map_segment+0xd9>
c0106f48:	c7 44 24 0c e6 b0 10 	movl   $0xc010b0e6,0xc(%esp)
c0106f4f:	c0 
c0106f50:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0106f57:	c0 
c0106f58:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0106f5f:	00 
c0106f60:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0106f67:	e8 94 94 ff ff       	call   c0100400 <__panic>
        *ptep = pa | PTE_P | perm;
c0106f6c:	8b 45 14             	mov    0x14(%ebp),%eax
c0106f6f:	0b 45 18             	or     0x18(%ebp),%eax
c0106f72:	83 c8 01             	or     $0x1,%eax
c0106f75:	89 c2                	mov    %eax,%edx
c0106f77:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f7a:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106f7c:	ff 4d f4             	decl   -0xc(%ebp)
c0106f7f:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0106f86:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0106f8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f91:	75 92                	jne    c0106f25 <boot_map_segment+0x92>
    }
}
c0106f93:	90                   	nop
c0106f94:	c9                   	leave  
c0106f95:	c3                   	ret    

c0106f96 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0106f96:	55                   	push   %ebp
c0106f97:	89 e5                	mov    %esp,%ebp
c0106f99:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0106f9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106fa3:	e8 70 fa ff ff       	call   c0106a18 <alloc_pages>
c0106fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0106fab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106faf:	75 1c                	jne    c0106fcd <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0106fb1:	c7 44 24 08 f3 b0 10 	movl   $0xc010b0f3,0x8(%esp)
c0106fb8:	c0 
c0106fb9:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0106fc0:	00 
c0106fc1:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0106fc8:	e8 33 94 ff ff       	call   c0100400 <__panic>
    }
    return page2kva(p);
c0106fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fd0:	89 04 24             	mov    %eax,(%esp)
c0106fd3:	e8 91 f7 ff ff       	call   c0106769 <page2kva>
}
c0106fd8:	c9                   	leave  
c0106fd9:	c3                   	ret    

c0106fda <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0106fda:	55                   	push   %ebp
c0106fdb:	89 e5                	mov    %esp,%ebp
c0106fdd:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0106fe0:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0106fe5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106fe8:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106fef:	77 23                	ja     c0107014 <pmm_init+0x3a>
c0106ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106ff8:	c7 44 24 08 88 b0 10 	movl   $0xc010b088,0x8(%esp)
c0106fff:	c0 
c0107000:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0107007:	00 
c0107008:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010700f:	e8 ec 93 ff ff       	call   c0100400 <__panic>
c0107014:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107017:	05 00 00 00 40       	add    $0x40000000,%eax
c010701c:	a3 54 a1 12 c0       	mov    %eax,0xc012a154
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0107021:	e8 9e f9 ff ff       	call   c01069c4 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0107026:	e8 83 fa ff ff       	call   c0106aae <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010702b:	e8 de 03 00 00       	call   c010740e <check_alloc_page>

    check_pgdir();
c0107030:	e8 f8 03 00 00       	call   c010742d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0107035:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010703a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010703d:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107044:	77 23                	ja     c0107069 <pmm_init+0x8f>
c0107046:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107049:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010704d:	c7 44 24 08 88 b0 10 	movl   $0xc010b088,0x8(%esp)
c0107054:	c0 
c0107055:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010705c:	00 
c010705d:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107064:	e8 97 93 ff ff       	call   c0100400 <__panic>
c0107069:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010706c:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0107072:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107077:	05 ac 0f 00 00       	add    $0xfac,%eax
c010707c:	83 ca 03             	or     $0x3,%edx
c010707f:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0107081:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107086:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010708d:	00 
c010708e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107095:	00 
c0107096:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010709d:	38 
c010709e:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01070a5:	c0 
c01070a6:	89 04 24             	mov    %eax,(%esp)
c01070a9:	e8 e5 fd ff ff       	call   c0106e93 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01070ae:	e8 28 f8 ff ff       	call   c01068db <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01070b3:	e8 11 0a 00 00       	call   c0107ac9 <check_boot_pgdir>

    print_pgdir();
c01070b8:	e8 8a 0e 00 00       	call   c0107f47 <print_pgdir>

}
c01070bd:	90                   	nop
c01070be:	c9                   	leave  
c01070bf:	c3                   	ret    

c01070c0 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01070c0:	55                   	push   %ebp
c01070c1:	89 e5                	mov    %esp,%ebp
c01070c3:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry
c01070c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070c9:	c1 e8 16             	shr    $0x16,%eax
c01070cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01070d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01070d6:	01 d0                	add    %edx,%eax
c01070d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {              // (2) check if entry is not present
c01070db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070de:	8b 00                	mov    (%eax),%eax
c01070e0:	83 e0 01             	and    $0x1,%eax
c01070e3:	85 c0                	test   %eax,%eax
c01070e5:	0f 85 af 00 00 00    	jne    c010719a <get_pte+0xda>
        struct Page* page;
        // (3) check if creating is needed, then alloc page for page table
        // CAUTION: this page is used for page table, not for common data page
        if(!create || (page = alloc_page()) == NULL) {
c01070eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01070ef:	74 15                	je     c0107106 <get_pte+0x46>
c01070f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01070f8:	e8 1b f9 ff ff       	call   c0106a18 <alloc_pages>
c01070fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107100:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107104:	75 0a                	jne    c0107110 <get_pte+0x50>
            return NULL;
c0107106:	b8 00 00 00 00       	mov    $0x0,%eax
c010710b:	e9 e7 00 00 00       	jmp    c01071f7 <get_pte+0x137>
        }
        set_page_ref(page, 1); // (4) set page reference
c0107110:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107117:	00 
c0107118:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010711b:	89 04 24             	mov    %eax,(%esp)
c010711e:	e8 fa f6 ff ff       	call   c010681d <set_page_ref>
        uintptr_t pa = page2pa(page); // (5) get linear address of page
c0107123:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107126:	89 04 24             	mov    %eax,(%esp)
c0107129:	e8 e0 f5 ff ff       	call   c010670e <page2pa>
c010712e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); // (6) clear page content using memset
c0107131:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107134:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107137:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010713a:	c1 e8 0c             	shr    $0xc,%eax
c010713d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107140:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107145:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0107148:	72 23                	jb     c010716d <get_pte+0xad>
c010714a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010714d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107151:	c7 44 24 08 e4 af 10 	movl   $0xc010afe4,0x8(%esp)
c0107158:	c0 
c0107159:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
c0107160:	00 
c0107161:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107168:	e8 93 92 ff ff       	call   c0100400 <__panic>
c010716d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107170:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107175:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010717c:	00 
c010717d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107184:	00 
c0107185:	89 04 24             	mov    %eax,(%esp)
c0107188:	e8 50 1e 00 00       	call   c0108fdd <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;  // (7) set page directory entry's permission
c010718d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107190:	83 c8 07             	or     $0x7,%eax
c0107193:	89 c2                	mov    %eax,%edx
c0107195:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107198:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry
c010719a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010719d:	8b 00                	mov    (%eax),%eax
c010719f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01071a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01071a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071aa:	c1 e8 0c             	shr    $0xc,%eax
c01071ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01071b0:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01071b5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01071b8:	72 23                	jb     c01071dd <get_pte+0x11d>
c01071ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01071c1:	c7 44 24 08 e4 af 10 	movl   $0xc010afe4,0x8(%esp)
c01071c8:	c0 
c01071c9:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c01071d0:	00 
c01071d1:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01071d8:	e8 23 92 ff ff       	call   c0100400 <__panic>
c01071dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071e0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01071e5:	89 c2                	mov    %eax,%edx
c01071e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071ea:	c1 e8 0c             	shr    $0xc,%eax
c01071ed:	25 ff 03 00 00       	and    $0x3ff,%eax
c01071f2:	c1 e0 02             	shl    $0x2,%eax
c01071f5:	01 d0                	add    %edx,%eax
}
c01071f7:	c9                   	leave  
c01071f8:	c3                   	ret    

c01071f9 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01071f9:	55                   	push   %ebp
c01071fa:	89 e5                	mov    %esp,%ebp
c01071fc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01071ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107206:	00 
c0107207:	8b 45 0c             	mov    0xc(%ebp),%eax
c010720a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010720e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107211:	89 04 24             	mov    %eax,(%esp)
c0107214:	e8 a7 fe ff ff       	call   c01070c0 <get_pte>
c0107219:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010721c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107220:	74 08                	je     c010722a <get_page+0x31>
        *ptep_store = ptep;
c0107222:	8b 45 10             	mov    0x10(%ebp),%eax
c0107225:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107228:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010722a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010722e:	74 1b                	je     c010724b <get_page+0x52>
c0107230:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107233:	8b 00                	mov    (%eax),%eax
c0107235:	83 e0 01             	and    $0x1,%eax
c0107238:	85 c0                	test   %eax,%eax
c010723a:	74 0f                	je     c010724b <get_page+0x52>
        return pte2page(*ptep);
c010723c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010723f:	8b 00                	mov    (%eax),%eax
c0107241:	89 04 24             	mov    %eax,(%esp)
c0107244:	e8 74 f5 ff ff       	call   c01067bd <pte2page>
c0107249:	eb 05                	jmp    c0107250 <get_page+0x57>
    }
    return NULL;
c010724b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107250:	c9                   	leave  
c0107251:	c3                   	ret    

c0107252 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0107252:	55                   	push   %ebp
c0107253:	89 e5                	mov    %esp,%ebp
c0107255:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    if (*ptep & PTE_P) {                      //(1) check if this page table entry is present
c0107258:	8b 45 10             	mov    0x10(%ebp),%eax
c010725b:	8b 00                	mov    (%eax),%eax
c010725d:	83 e0 01             	and    $0x1,%eax
c0107260:	85 c0                	test   %eax,%eax
c0107262:	74 4d                	je     c01072b1 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //(2) find corresponding page to pte
c0107264:	8b 45 10             	mov    0x10(%ebp),%eax
c0107267:	8b 00                	mov    (%eax),%eax
c0107269:	89 04 24             	mov    %eax,(%esp)
c010726c:	e8 4c f5 ff ff       	call   c01067bd <pte2page>
c0107271:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0)  //(3) decrease page reference
c0107274:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107277:	89 04 24             	mov    %eax,(%esp)
c010727a:	e8 c3 f5 ff ff       	call   c0106842 <page_ref_dec>
c010727f:	85 c0                	test   %eax,%eax
c0107281:	75 13                	jne    c0107296 <page_remove_pte+0x44>
            free_page(page);  //(4) and free this page when page reference reachs 0
c0107283:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010728a:	00 
c010728b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010728e:	89 04 24             	mov    %eax,(%esp)
c0107291:	e8 ba f7 ff ff       	call   c0106a50 <free_pages>
        *ptep = 0;  //(5) clear second page table entry
c0107296:	8b 45 10             	mov    0x10(%ebp),%eax
c0107299:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);  //(6) flush tlb
c010729f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01072a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01072a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01072a9:	89 04 24             	mov    %eax,(%esp)
c01072ac:	e8 01 01 00 00       	call   c01073b2 <tlb_invalidate>
    }
}
c01072b1:	90                   	nop
c01072b2:	c9                   	leave  
c01072b3:	c3                   	ret    

c01072b4 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01072b4:	55                   	push   %ebp
c01072b5:	89 e5                	mov    %esp,%ebp
c01072b7:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01072ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01072c1:	00 
c01072c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01072c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01072c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01072cc:	89 04 24             	mov    %eax,(%esp)
c01072cf:	e8 ec fd ff ff       	call   c01070c0 <get_pte>
c01072d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01072d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01072db:	74 19                	je     c01072f6 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01072dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072e0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01072e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01072e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01072eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01072ee:	89 04 24             	mov    %eax,(%esp)
c01072f1:	e8 5c ff ff ff       	call   c0107252 <page_remove_pte>
    }
}
c01072f6:	90                   	nop
c01072f7:	c9                   	leave  
c01072f8:	c3                   	ret    

c01072f9 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01072f9:	55                   	push   %ebp
c01072fa:	89 e5                	mov    %esp,%ebp
c01072fc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01072ff:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107306:	00 
c0107307:	8b 45 10             	mov    0x10(%ebp),%eax
c010730a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010730e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107311:	89 04 24             	mov    %eax,(%esp)
c0107314:	e8 a7 fd ff ff       	call   c01070c0 <get_pte>
c0107319:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010731c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107320:	75 0a                	jne    c010732c <page_insert+0x33>
        return -E_NO_MEM;
c0107322:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0107327:	e9 84 00 00 00       	jmp    c01073b0 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010732c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010732f:	89 04 24             	mov    %eax,(%esp)
c0107332:	e8 f4 f4 ff ff       	call   c010682b <page_ref_inc>
    if (*ptep & PTE_P) {
c0107337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010733a:	8b 00                	mov    (%eax),%eax
c010733c:	83 e0 01             	and    $0x1,%eax
c010733f:	85 c0                	test   %eax,%eax
c0107341:	74 3e                	je     c0107381 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0107343:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107346:	8b 00                	mov    (%eax),%eax
c0107348:	89 04 24             	mov    %eax,(%esp)
c010734b:	e8 6d f4 ff ff       	call   c01067bd <pte2page>
c0107350:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0107353:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107356:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107359:	75 0d                	jne    c0107368 <page_insert+0x6f>
            page_ref_dec(page);
c010735b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010735e:	89 04 24             	mov    %eax,(%esp)
c0107361:	e8 dc f4 ff ff       	call   c0106842 <page_ref_dec>
c0107366:	eb 19                	jmp    c0107381 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0107368:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010736b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010736f:	8b 45 10             	mov    0x10(%ebp),%eax
c0107372:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107376:	8b 45 08             	mov    0x8(%ebp),%eax
c0107379:	89 04 24             	mov    %eax,(%esp)
c010737c:	e8 d1 fe ff ff       	call   c0107252 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0107381:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107384:	89 04 24             	mov    %eax,(%esp)
c0107387:	e8 82 f3 ff ff       	call   c010670e <page2pa>
c010738c:	0b 45 14             	or     0x14(%ebp),%eax
c010738f:	83 c8 01             	or     $0x1,%eax
c0107392:	89 c2                	mov    %eax,%edx
c0107394:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107397:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0107399:	8b 45 10             	mov    0x10(%ebp),%eax
c010739c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01073a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01073a3:	89 04 24             	mov    %eax,(%esp)
c01073a6:	e8 07 00 00 00       	call   c01073b2 <tlb_invalidate>
    return 0;
c01073ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073b0:	c9                   	leave  
c01073b1:	c3                   	ret    

c01073b2 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01073b2:	55                   	push   %ebp
c01073b3:	89 e5                	mov    %esp,%ebp
c01073b5:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01073b8:	0f 20 d8             	mov    %cr3,%eax
c01073bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01073be:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01073c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01073c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01073c7:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01073ce:	77 23                	ja     c01073f3 <tlb_invalidate+0x41>
c01073d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01073d7:	c7 44 24 08 88 b0 10 	movl   $0xc010b088,0x8(%esp)
c01073de:	c0 
c01073df:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c01073e6:	00 
c01073e7:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01073ee:	e8 0d 90 ff ff       	call   c0100400 <__panic>
c01073f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073f6:	05 00 00 00 40       	add    $0x40000000,%eax
c01073fb:	39 d0                	cmp    %edx,%eax
c01073fd:	75 0c                	jne    c010740b <tlb_invalidate+0x59>
        invlpg((void *)la);
c01073ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107402:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0107405:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107408:	0f 01 38             	invlpg (%eax)
    }
}
c010740b:	90                   	nop
c010740c:	c9                   	leave  
c010740d:	c3                   	ret    

c010740e <check_alloc_page>:

static void
check_alloc_page(void) {
c010740e:	55                   	push   %ebp
c010740f:	89 e5                	mov    %esp,%ebp
c0107411:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0107414:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0107419:	8b 40 18             	mov    0x18(%eax),%eax
c010741c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010741e:	c7 04 24 0c b1 10 c0 	movl   $0xc010b10c,(%esp)
c0107425:	e8 7f 8e ff ff       	call   c01002a9 <cprintf>
}
c010742a:	90                   	nop
c010742b:	c9                   	leave  
c010742c:	c3                   	ret    

c010742d <check_pgdir>:

static void
check_pgdir(void) {
c010742d:	55                   	push   %ebp
c010742e:	89 e5                	mov    %esp,%ebp
c0107430:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0107433:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107438:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010743d:	76 24                	jbe    c0107463 <check_pgdir+0x36>
c010743f:	c7 44 24 0c 2b b1 10 	movl   $0xc010b12b,0xc(%esp)
c0107446:	c0 
c0107447:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c010744e:	c0 
c010744f:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0107456:	00 
c0107457:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010745e:	e8 9d 8f ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0107463:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107468:	85 c0                	test   %eax,%eax
c010746a:	74 0e                	je     c010747a <check_pgdir+0x4d>
c010746c:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107471:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107476:	85 c0                	test   %eax,%eax
c0107478:	74 24                	je     c010749e <check_pgdir+0x71>
c010747a:	c7 44 24 0c 48 b1 10 	movl   $0xc010b148,0xc(%esp)
c0107481:	c0 
c0107482:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107489:	c0 
c010748a:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0107491:	00 
c0107492:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107499:	e8 62 8f ff ff       	call   c0100400 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010749e:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01074a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01074aa:	00 
c01074ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01074b2:	00 
c01074b3:	89 04 24             	mov    %eax,(%esp)
c01074b6:	e8 3e fd ff ff       	call   c01071f9 <get_page>
c01074bb:	85 c0                	test   %eax,%eax
c01074bd:	74 24                	je     c01074e3 <check_pgdir+0xb6>
c01074bf:	c7 44 24 0c 80 b1 10 	movl   $0xc010b180,0xc(%esp)
c01074c6:	c0 
c01074c7:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01074ce:	c0 
c01074cf:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c01074d6:	00 
c01074d7:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01074de:	e8 1d 8f ff ff       	call   c0100400 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01074e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01074ea:	e8 29 f5 ff ff       	call   c0106a18 <alloc_pages>
c01074ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01074f2:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01074f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01074fe:	00 
c01074ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107506:	00 
c0107507:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010750a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010750e:	89 04 24             	mov    %eax,(%esp)
c0107511:	e8 e3 fd ff ff       	call   c01072f9 <page_insert>
c0107516:	85 c0                	test   %eax,%eax
c0107518:	74 24                	je     c010753e <check_pgdir+0x111>
c010751a:	c7 44 24 0c a8 b1 10 	movl   $0xc010b1a8,0xc(%esp)
c0107521:	c0 
c0107522:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107529:	c0 
c010752a:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0107531:	00 
c0107532:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107539:	e8 c2 8e ff ff       	call   c0100400 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010753e:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107543:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010754a:	00 
c010754b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107552:	00 
c0107553:	89 04 24             	mov    %eax,(%esp)
c0107556:	e8 65 fb ff ff       	call   c01070c0 <get_pte>
c010755b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010755e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107562:	75 24                	jne    c0107588 <check_pgdir+0x15b>
c0107564:	c7 44 24 0c d4 b1 10 	movl   $0xc010b1d4,0xc(%esp)
c010756b:	c0 
c010756c:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107573:	c0 
c0107574:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c010757b:	00 
c010757c:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107583:	e8 78 8e ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c0107588:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010758b:	8b 00                	mov    (%eax),%eax
c010758d:	89 04 24             	mov    %eax,(%esp)
c0107590:	e8 28 f2 ff ff       	call   c01067bd <pte2page>
c0107595:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107598:	74 24                	je     c01075be <check_pgdir+0x191>
c010759a:	c7 44 24 0c 01 b2 10 	movl   $0xc010b201,0xc(%esp)
c01075a1:	c0 
c01075a2:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01075a9:	c0 
c01075aa:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c01075b1:	00 
c01075b2:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01075b9:	e8 42 8e ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 1);
c01075be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075c1:	89 04 24             	mov    %eax,(%esp)
c01075c4:	e8 4a f2 ff ff       	call   c0106813 <page_ref>
c01075c9:	83 f8 01             	cmp    $0x1,%eax
c01075cc:	74 24                	je     c01075f2 <check_pgdir+0x1c5>
c01075ce:	c7 44 24 0c 17 b2 10 	movl   $0xc010b217,0xc(%esp)
c01075d5:	c0 
c01075d6:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01075dd:	c0 
c01075de:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c01075e5:	00 
c01075e6:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01075ed:	e8 0e 8e ff ff       	call   c0100400 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01075f2:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01075f7:	8b 00                	mov    (%eax),%eax
c01075f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01075fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107601:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107604:	c1 e8 0c             	shr    $0xc,%eax
c0107607:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010760a:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010760f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107612:	72 23                	jb     c0107637 <check_pgdir+0x20a>
c0107614:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107617:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010761b:	c7 44 24 08 e4 af 10 	movl   $0xc010afe4,0x8(%esp)
c0107622:	c0 
c0107623:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c010762a:	00 
c010762b:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107632:	e8 c9 8d ff ff       	call   c0100400 <__panic>
c0107637:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010763a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010763f:	83 c0 04             	add    $0x4,%eax
c0107642:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0107645:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010764a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107651:	00 
c0107652:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107659:	00 
c010765a:	89 04 24             	mov    %eax,(%esp)
c010765d:	e8 5e fa ff ff       	call   c01070c0 <get_pte>
c0107662:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107665:	74 24                	je     c010768b <check_pgdir+0x25e>
c0107667:	c7 44 24 0c 2c b2 10 	movl   $0xc010b22c,0xc(%esp)
c010766e:	c0 
c010766f:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107676:	c0 
c0107677:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c010767e:	00 
c010767f:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107686:	e8 75 8d ff ff       	call   c0100400 <__panic>

    p2 = alloc_page();
c010768b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107692:	e8 81 f3 ff ff       	call   c0106a18 <alloc_pages>
c0107697:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010769a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010769f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01076a6:	00 
c01076a7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01076ae:	00 
c01076af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01076b2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01076b6:	89 04 24             	mov    %eax,(%esp)
c01076b9:	e8 3b fc ff ff       	call   c01072f9 <page_insert>
c01076be:	85 c0                	test   %eax,%eax
c01076c0:	74 24                	je     c01076e6 <check_pgdir+0x2b9>
c01076c2:	c7 44 24 0c 54 b2 10 	movl   $0xc010b254,0xc(%esp)
c01076c9:	c0 
c01076ca:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01076d1:	c0 
c01076d2:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c01076d9:	00 
c01076da:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01076e1:	e8 1a 8d ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01076e6:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01076eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01076f2:	00 
c01076f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01076fa:	00 
c01076fb:	89 04 24             	mov    %eax,(%esp)
c01076fe:	e8 bd f9 ff ff       	call   c01070c0 <get_pte>
c0107703:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107706:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010770a:	75 24                	jne    c0107730 <check_pgdir+0x303>
c010770c:	c7 44 24 0c 8c b2 10 	movl   $0xc010b28c,0xc(%esp)
c0107713:	c0 
c0107714:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c010771b:	c0 
c010771c:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0107723:	00 
c0107724:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010772b:	e8 d0 8c ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_U);
c0107730:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107733:	8b 00                	mov    (%eax),%eax
c0107735:	83 e0 04             	and    $0x4,%eax
c0107738:	85 c0                	test   %eax,%eax
c010773a:	75 24                	jne    c0107760 <check_pgdir+0x333>
c010773c:	c7 44 24 0c bc b2 10 	movl   $0xc010b2bc,0xc(%esp)
c0107743:	c0 
c0107744:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c010774b:	c0 
c010774c:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0107753:	00 
c0107754:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010775b:	e8 a0 8c ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_W);
c0107760:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107763:	8b 00                	mov    (%eax),%eax
c0107765:	83 e0 02             	and    $0x2,%eax
c0107768:	85 c0                	test   %eax,%eax
c010776a:	75 24                	jne    c0107790 <check_pgdir+0x363>
c010776c:	c7 44 24 0c ca b2 10 	movl   $0xc010b2ca,0xc(%esp)
c0107773:	c0 
c0107774:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c010777b:	c0 
c010777c:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0107783:	00 
c0107784:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010778b:	e8 70 8c ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0107790:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107795:	8b 00                	mov    (%eax),%eax
c0107797:	83 e0 04             	and    $0x4,%eax
c010779a:	85 c0                	test   %eax,%eax
c010779c:	75 24                	jne    c01077c2 <check_pgdir+0x395>
c010779e:	c7 44 24 0c d8 b2 10 	movl   $0xc010b2d8,0xc(%esp)
c01077a5:	c0 
c01077a6:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01077ad:	c0 
c01077ae:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c01077b5:	00 
c01077b6:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01077bd:	e8 3e 8c ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 1);
c01077c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01077c5:	89 04 24             	mov    %eax,(%esp)
c01077c8:	e8 46 f0 ff ff       	call   c0106813 <page_ref>
c01077cd:	83 f8 01             	cmp    $0x1,%eax
c01077d0:	74 24                	je     c01077f6 <check_pgdir+0x3c9>
c01077d2:	c7 44 24 0c ee b2 10 	movl   $0xc010b2ee,0xc(%esp)
c01077d9:	c0 
c01077da:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01077e1:	c0 
c01077e2:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01077e9:	00 
c01077ea:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01077f1:	e8 0a 8c ff ff       	call   c0100400 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01077f6:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01077fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107802:	00 
c0107803:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010780a:	00 
c010780b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010780e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107812:	89 04 24             	mov    %eax,(%esp)
c0107815:	e8 df fa ff ff       	call   c01072f9 <page_insert>
c010781a:	85 c0                	test   %eax,%eax
c010781c:	74 24                	je     c0107842 <check_pgdir+0x415>
c010781e:	c7 44 24 0c 00 b3 10 	movl   $0xc010b300,0xc(%esp)
c0107825:	c0 
c0107826:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c010782d:	c0 
c010782e:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0107835:	00 
c0107836:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010783d:	e8 be 8b ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 2);
c0107842:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107845:	89 04 24             	mov    %eax,(%esp)
c0107848:	e8 c6 ef ff ff       	call   c0106813 <page_ref>
c010784d:	83 f8 02             	cmp    $0x2,%eax
c0107850:	74 24                	je     c0107876 <check_pgdir+0x449>
c0107852:	c7 44 24 0c 2c b3 10 	movl   $0xc010b32c,0xc(%esp)
c0107859:	c0 
c010785a:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107861:	c0 
c0107862:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0107869:	00 
c010786a:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107871:	e8 8a 8b ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107876:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107879:	89 04 24             	mov    %eax,(%esp)
c010787c:	e8 92 ef ff ff       	call   c0106813 <page_ref>
c0107881:	85 c0                	test   %eax,%eax
c0107883:	74 24                	je     c01078a9 <check_pgdir+0x47c>
c0107885:	c7 44 24 0c 3e b3 10 	movl   $0xc010b33e,0xc(%esp)
c010788c:	c0 
c010788d:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107894:	c0 
c0107895:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c010789c:	00 
c010789d:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01078a4:	e8 57 8b ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01078a9:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01078ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01078b5:	00 
c01078b6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01078bd:	00 
c01078be:	89 04 24             	mov    %eax,(%esp)
c01078c1:	e8 fa f7 ff ff       	call   c01070c0 <get_pte>
c01078c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01078cd:	75 24                	jne    c01078f3 <check_pgdir+0x4c6>
c01078cf:	c7 44 24 0c 8c b2 10 	movl   $0xc010b28c,0xc(%esp)
c01078d6:	c0 
c01078d7:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01078de:	c0 
c01078df:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c01078e6:	00 
c01078e7:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01078ee:	e8 0d 8b ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c01078f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078f6:	8b 00                	mov    (%eax),%eax
c01078f8:	89 04 24             	mov    %eax,(%esp)
c01078fb:	e8 bd ee ff ff       	call   c01067bd <pte2page>
c0107900:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107903:	74 24                	je     c0107929 <check_pgdir+0x4fc>
c0107905:	c7 44 24 0c 01 b2 10 	movl   $0xc010b201,0xc(%esp)
c010790c:	c0 
c010790d:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107914:	c0 
c0107915:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c010791c:	00 
c010791d:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107924:	e8 d7 8a ff ff       	call   c0100400 <__panic>
    assert((*ptep & PTE_U) == 0);
c0107929:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010792c:	8b 00                	mov    (%eax),%eax
c010792e:	83 e0 04             	and    $0x4,%eax
c0107931:	85 c0                	test   %eax,%eax
c0107933:	74 24                	je     c0107959 <check_pgdir+0x52c>
c0107935:	c7 44 24 0c 50 b3 10 	movl   $0xc010b350,0xc(%esp)
c010793c:	c0 
c010793d:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107944:	c0 
c0107945:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c010794c:	00 
c010794d:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107954:	e8 a7 8a ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, 0x0);
c0107959:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010795e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107965:	00 
c0107966:	89 04 24             	mov    %eax,(%esp)
c0107969:	e8 46 f9 ff ff       	call   c01072b4 <page_remove>
    assert(page_ref(p1) == 1);
c010796e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107971:	89 04 24             	mov    %eax,(%esp)
c0107974:	e8 9a ee ff ff       	call   c0106813 <page_ref>
c0107979:	83 f8 01             	cmp    $0x1,%eax
c010797c:	74 24                	je     c01079a2 <check_pgdir+0x575>
c010797e:	c7 44 24 0c 17 b2 10 	movl   $0xc010b217,0xc(%esp)
c0107985:	c0 
c0107986:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c010798d:	c0 
c010798e:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0107995:	00 
c0107996:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c010799d:	e8 5e 8a ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c01079a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079a5:	89 04 24             	mov    %eax,(%esp)
c01079a8:	e8 66 ee ff ff       	call   c0106813 <page_ref>
c01079ad:	85 c0                	test   %eax,%eax
c01079af:	74 24                	je     c01079d5 <check_pgdir+0x5a8>
c01079b1:	c7 44 24 0c 3e b3 10 	movl   $0xc010b33e,0xc(%esp)
c01079b8:	c0 
c01079b9:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c01079c0:	c0 
c01079c1:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c01079c8:	00 
c01079c9:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c01079d0:	e8 2b 8a ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01079d5:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01079da:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01079e1:	00 
c01079e2:	89 04 24             	mov    %eax,(%esp)
c01079e5:	e8 ca f8 ff ff       	call   c01072b4 <page_remove>
    assert(page_ref(p1) == 0);
c01079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079ed:	89 04 24             	mov    %eax,(%esp)
c01079f0:	e8 1e ee ff ff       	call   c0106813 <page_ref>
c01079f5:	85 c0                	test   %eax,%eax
c01079f7:	74 24                	je     c0107a1d <check_pgdir+0x5f0>
c01079f9:	c7 44 24 0c 65 b3 10 	movl   $0xc010b365,0xc(%esp)
c0107a00:	c0 
c0107a01:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107a08:	c0 
c0107a09:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0107a10:	00 
c0107a11:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107a18:	e8 e3 89 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a20:	89 04 24             	mov    %eax,(%esp)
c0107a23:	e8 eb ed ff ff       	call   c0106813 <page_ref>
c0107a28:	85 c0                	test   %eax,%eax
c0107a2a:	74 24                	je     c0107a50 <check_pgdir+0x623>
c0107a2c:	c7 44 24 0c 3e b3 10 	movl   $0xc010b33e,0xc(%esp)
c0107a33:	c0 
c0107a34:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107a3b:	c0 
c0107a3c:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0107a43:	00 
c0107a44:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107a4b:	e8 b0 89 ff ff       	call   c0100400 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0107a50:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107a55:	8b 00                	mov    (%eax),%eax
c0107a57:	89 04 24             	mov    %eax,(%esp)
c0107a5a:	e8 9c ed ff ff       	call   c01067fb <pde2page>
c0107a5f:	89 04 24             	mov    %eax,(%esp)
c0107a62:	e8 ac ed ff ff       	call   c0106813 <page_ref>
c0107a67:	83 f8 01             	cmp    $0x1,%eax
c0107a6a:	74 24                	je     c0107a90 <check_pgdir+0x663>
c0107a6c:	c7 44 24 0c 78 b3 10 	movl   $0xc010b378,0xc(%esp)
c0107a73:	c0 
c0107a74:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107a7b:	c0 
c0107a7c:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0107a83:	00 
c0107a84:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107a8b:	e8 70 89 ff ff       	call   c0100400 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0107a90:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107a95:	8b 00                	mov    (%eax),%eax
c0107a97:	89 04 24             	mov    %eax,(%esp)
c0107a9a:	e8 5c ed ff ff       	call   c01067fb <pde2page>
c0107a9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107aa6:	00 
c0107aa7:	89 04 24             	mov    %eax,(%esp)
c0107aaa:	e8 a1 ef ff ff       	call   c0106a50 <free_pages>
    boot_pgdir[0] = 0;
c0107aaf:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107ab4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107aba:	c7 04 24 9f b3 10 c0 	movl   $0xc010b39f,(%esp)
c0107ac1:	e8 e3 87 ff ff       	call   c01002a9 <cprintf>
}
c0107ac6:	90                   	nop
c0107ac7:	c9                   	leave  
c0107ac8:	c3                   	ret    

c0107ac9 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107ac9:	55                   	push   %ebp
c0107aca:	89 e5                	mov    %esp,%ebp
c0107acc:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107ad6:	e9 ca 00 00 00       	jmp    c0107ba5 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ade:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ae4:	c1 e8 0c             	shr    $0xc,%eax
c0107ae7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107aea:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107aef:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107af2:	72 23                	jb     c0107b17 <check_boot_pgdir+0x4e>
c0107af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107af7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107afb:	c7 44 24 08 e4 af 10 	movl   $0xc010afe4,0x8(%esp)
c0107b02:	c0 
c0107b03:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0107b0a:	00 
c0107b0b:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107b12:	e8 e9 88 ff ff       	call   c0100400 <__panic>
c0107b17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b1a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107b1f:	89 c2                	mov    %eax,%edx
c0107b21:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107b26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107b2d:	00 
c0107b2e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107b32:	89 04 24             	mov    %eax,(%esp)
c0107b35:	e8 86 f5 ff ff       	call   c01070c0 <get_pte>
c0107b3a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107b3d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107b41:	75 24                	jne    c0107b67 <check_boot_pgdir+0x9e>
c0107b43:	c7 44 24 0c bc b3 10 	movl   $0xc010b3bc,0xc(%esp)
c0107b4a:	c0 
c0107b4b:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107b52:	c0 
c0107b53:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0107b5a:	00 
c0107b5b:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107b62:	e8 99 88 ff ff       	call   c0100400 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107b67:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b6a:	8b 00                	mov    (%eax),%eax
c0107b6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107b71:	89 c2                	mov    %eax,%edx
c0107b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b76:	39 c2                	cmp    %eax,%edx
c0107b78:	74 24                	je     c0107b9e <check_boot_pgdir+0xd5>
c0107b7a:	c7 44 24 0c f9 b3 10 	movl   $0xc010b3f9,0xc(%esp)
c0107b81:	c0 
c0107b82:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107b89:	c0 
c0107b8a:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0107b91:	00 
c0107b92:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107b99:	e8 62 88 ff ff       	call   c0100400 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0107b9e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0107ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ba8:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107bad:	39 c2                	cmp    %eax,%edx
c0107baf:	0f 82 26 ff ff ff    	jb     c0107adb <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0107bb5:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107bba:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107bbf:	8b 00                	mov    (%eax),%eax
c0107bc1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107bc6:	89 c2                	mov    %eax,%edx
c0107bc8:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107bcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bd0:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107bd7:	77 23                	ja     c0107bfc <check_boot_pgdir+0x133>
c0107bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107be0:	c7 44 24 08 88 b0 10 	movl   $0xc010b088,0x8(%esp)
c0107be7:	c0 
c0107be8:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0107bef:	00 
c0107bf0:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107bf7:	e8 04 88 ff ff       	call   c0100400 <__panic>
c0107bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bff:	05 00 00 00 40       	add    $0x40000000,%eax
c0107c04:	39 d0                	cmp    %edx,%eax
c0107c06:	74 24                	je     c0107c2c <check_boot_pgdir+0x163>
c0107c08:	c7 44 24 0c 10 b4 10 	movl   $0xc010b410,0xc(%esp)
c0107c0f:	c0 
c0107c10:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107c17:	c0 
c0107c18:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0107c1f:	00 
c0107c20:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107c27:	e8 d4 87 ff ff       	call   c0100400 <__panic>

    assert(boot_pgdir[0] == 0);
c0107c2c:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107c31:	8b 00                	mov    (%eax),%eax
c0107c33:	85 c0                	test   %eax,%eax
c0107c35:	74 24                	je     c0107c5b <check_boot_pgdir+0x192>
c0107c37:	c7 44 24 0c 44 b4 10 	movl   $0xc010b444,0xc(%esp)
c0107c3e:	c0 
c0107c3f:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107c46:	c0 
c0107c47:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0107c4e:	00 
c0107c4f:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107c56:	e8 a5 87 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    p = alloc_page();
c0107c5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107c62:	e8 b1 ed ff ff       	call   c0106a18 <alloc_pages>
c0107c67:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107c6a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107c6f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107c76:	00 
c0107c77:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0107c7e:	00 
c0107c7f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c82:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c86:	89 04 24             	mov    %eax,(%esp)
c0107c89:	e8 6b f6 ff ff       	call   c01072f9 <page_insert>
c0107c8e:	85 c0                	test   %eax,%eax
c0107c90:	74 24                	je     c0107cb6 <check_boot_pgdir+0x1ed>
c0107c92:	c7 44 24 0c 58 b4 10 	movl   $0xc010b458,0xc(%esp)
c0107c99:	c0 
c0107c9a:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107ca1:	c0 
c0107ca2:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0107ca9:	00 
c0107caa:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107cb1:	e8 4a 87 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 1);
c0107cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cb9:	89 04 24             	mov    %eax,(%esp)
c0107cbc:	e8 52 eb ff ff       	call   c0106813 <page_ref>
c0107cc1:	83 f8 01             	cmp    $0x1,%eax
c0107cc4:	74 24                	je     c0107cea <check_boot_pgdir+0x221>
c0107cc6:	c7 44 24 0c 86 b4 10 	movl   $0xc010b486,0xc(%esp)
c0107ccd:	c0 
c0107cce:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107cd5:	c0 
c0107cd6:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0107cdd:	00 
c0107cde:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107ce5:	e8 16 87 ff ff       	call   c0100400 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0107cea:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107cef:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107cf6:	00 
c0107cf7:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0107cfe:	00 
c0107cff:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d02:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d06:	89 04 24             	mov    %eax,(%esp)
c0107d09:	e8 eb f5 ff ff       	call   c01072f9 <page_insert>
c0107d0e:	85 c0                	test   %eax,%eax
c0107d10:	74 24                	je     c0107d36 <check_boot_pgdir+0x26d>
c0107d12:	c7 44 24 0c 98 b4 10 	movl   $0xc010b498,0xc(%esp)
c0107d19:	c0 
c0107d1a:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107d21:	c0 
c0107d22:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0107d29:	00 
c0107d2a:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107d31:	e8 ca 86 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 2);
c0107d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d39:	89 04 24             	mov    %eax,(%esp)
c0107d3c:	e8 d2 ea ff ff       	call   c0106813 <page_ref>
c0107d41:	83 f8 02             	cmp    $0x2,%eax
c0107d44:	74 24                	je     c0107d6a <check_boot_pgdir+0x2a1>
c0107d46:	c7 44 24 0c cf b4 10 	movl   $0xc010b4cf,0xc(%esp)
c0107d4d:	c0 
c0107d4e:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107d55:	c0 
c0107d56:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0107d5d:	00 
c0107d5e:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107d65:	e8 96 86 ff ff       	call   c0100400 <__panic>

    const char *str = "ucore: Hello world!!";
c0107d6a:	c7 45 e8 e0 b4 10 c0 	movl   $0xc010b4e0,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0107d71:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d74:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d78:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107d7f:	e8 8f 0f 00 00       	call   c0108d13 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0107d84:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0107d8b:	00 
c0107d8c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107d93:	e8 f2 0f 00 00       	call   c0108d8a <strcmp>
c0107d98:	85 c0                	test   %eax,%eax
c0107d9a:	74 24                	je     c0107dc0 <check_boot_pgdir+0x2f7>
c0107d9c:	c7 44 24 0c f8 b4 10 	movl   $0xc010b4f8,0xc(%esp)
c0107da3:	c0 
c0107da4:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107dab:	c0 
c0107dac:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0107db3:	00 
c0107db4:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107dbb:	e8 40 86 ff ff       	call   c0100400 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0107dc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107dc3:	89 04 24             	mov    %eax,(%esp)
c0107dc6:	e8 9e e9 ff ff       	call   c0106769 <page2kva>
c0107dcb:	05 00 01 00 00       	add    $0x100,%eax
c0107dd0:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0107dd3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107dda:	e8 de 0e 00 00       	call   c0108cbd <strlen>
c0107ddf:	85 c0                	test   %eax,%eax
c0107de1:	74 24                	je     c0107e07 <check_boot_pgdir+0x33e>
c0107de3:	c7 44 24 0c 30 b5 10 	movl   $0xc010b530,0xc(%esp)
c0107dea:	c0 
c0107deb:	c7 44 24 08 d1 b0 10 	movl   $0xc010b0d1,0x8(%esp)
c0107df2:	c0 
c0107df3:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0107dfa:	00 
c0107dfb:	c7 04 24 ac b0 10 c0 	movl   $0xc010b0ac,(%esp)
c0107e02:	e8 f9 85 ff ff       	call   c0100400 <__panic>

    free_page(p);
c0107e07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107e0e:	00 
c0107e0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e12:	89 04 24             	mov    %eax,(%esp)
c0107e15:	e8 36 ec ff ff       	call   c0106a50 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0107e1a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107e1f:	8b 00                	mov    (%eax),%eax
c0107e21:	89 04 24             	mov    %eax,(%esp)
c0107e24:	e8 d2 e9 ff ff       	call   c01067fb <pde2page>
c0107e29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107e30:	00 
c0107e31:	89 04 24             	mov    %eax,(%esp)
c0107e34:	e8 17 ec ff ff       	call   c0106a50 <free_pages>
    boot_pgdir[0] = 0;
c0107e39:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107e3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0107e44:	c7 04 24 54 b5 10 c0 	movl   $0xc010b554,(%esp)
c0107e4b:	e8 59 84 ff ff       	call   c01002a9 <cprintf>
}
c0107e50:	90                   	nop
c0107e51:	c9                   	leave  
c0107e52:	c3                   	ret    

c0107e53 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0107e53:	55                   	push   %ebp
c0107e54:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0107e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e59:	83 e0 04             	and    $0x4,%eax
c0107e5c:	85 c0                	test   %eax,%eax
c0107e5e:	74 04                	je     c0107e64 <perm2str+0x11>
c0107e60:	b0 75                	mov    $0x75,%al
c0107e62:	eb 02                	jmp    c0107e66 <perm2str+0x13>
c0107e64:	b0 2d                	mov    $0x2d,%al
c0107e66:	a2 08 80 12 c0       	mov    %al,0xc0128008
    str[1] = 'r';
c0107e6b:	c6 05 09 80 12 c0 72 	movb   $0x72,0xc0128009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0107e72:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e75:	83 e0 02             	and    $0x2,%eax
c0107e78:	85 c0                	test   %eax,%eax
c0107e7a:	74 04                	je     c0107e80 <perm2str+0x2d>
c0107e7c:	b0 77                	mov    $0x77,%al
c0107e7e:	eb 02                	jmp    c0107e82 <perm2str+0x2f>
c0107e80:	b0 2d                	mov    $0x2d,%al
c0107e82:	a2 0a 80 12 c0       	mov    %al,0xc012800a
    str[3] = '\0';
c0107e87:	c6 05 0b 80 12 c0 00 	movb   $0x0,0xc012800b
    return str;
c0107e8e:	b8 08 80 12 c0       	mov    $0xc0128008,%eax
}
c0107e93:	5d                   	pop    %ebp
c0107e94:	c3                   	ret    

c0107e95 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0107e95:	55                   	push   %ebp
c0107e96:	89 e5                	mov    %esp,%ebp
c0107e98:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0107e9b:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e9e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107ea1:	72 0d                	jb     c0107eb0 <get_pgtable_items+0x1b>
        return 0;
c0107ea3:	b8 00 00 00 00       	mov    $0x0,%eax
c0107ea8:	e9 98 00 00 00       	jmp    c0107f45 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0107ead:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0107eb0:	8b 45 10             	mov    0x10(%ebp),%eax
c0107eb3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107eb6:	73 18                	jae    c0107ed0 <get_pgtable_items+0x3b>
c0107eb8:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ebb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107ec2:	8b 45 14             	mov    0x14(%ebp),%eax
c0107ec5:	01 d0                	add    %edx,%eax
c0107ec7:	8b 00                	mov    (%eax),%eax
c0107ec9:	83 e0 01             	and    $0x1,%eax
c0107ecc:	85 c0                	test   %eax,%eax
c0107ece:	74 dd                	je     c0107ead <get_pgtable_items+0x18>
    }
    if (start < right) {
c0107ed0:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ed3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107ed6:	73 68                	jae    c0107f40 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0107ed8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107edc:	74 08                	je     c0107ee6 <get_pgtable_items+0x51>
            *left_store = start;
c0107ede:	8b 45 18             	mov    0x18(%ebp),%eax
c0107ee1:	8b 55 10             	mov    0x10(%ebp),%edx
c0107ee4:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0107ee6:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ee9:	8d 50 01             	lea    0x1(%eax),%edx
c0107eec:	89 55 10             	mov    %edx,0x10(%ebp)
c0107eef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107ef6:	8b 45 14             	mov    0x14(%ebp),%eax
c0107ef9:	01 d0                	add    %edx,%eax
c0107efb:	8b 00                	mov    (%eax),%eax
c0107efd:	83 e0 07             	and    $0x7,%eax
c0107f00:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107f03:	eb 03                	jmp    c0107f08 <get_pgtable_items+0x73>
            start ++;
c0107f05:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107f08:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107f0e:	73 1d                	jae    c0107f2d <get_pgtable_items+0x98>
c0107f10:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f1a:	8b 45 14             	mov    0x14(%ebp),%eax
c0107f1d:	01 d0                	add    %edx,%eax
c0107f1f:	8b 00                	mov    (%eax),%eax
c0107f21:	83 e0 07             	and    $0x7,%eax
c0107f24:	89 c2                	mov    %eax,%edx
c0107f26:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107f29:	39 c2                	cmp    %eax,%edx
c0107f2b:	74 d8                	je     c0107f05 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0107f2d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0107f31:	74 08                	je     c0107f3b <get_pgtable_items+0xa6>
            *right_store = start;
c0107f33:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0107f36:	8b 55 10             	mov    0x10(%ebp),%edx
c0107f39:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0107f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107f3e:	eb 05                	jmp    c0107f45 <get_pgtable_items+0xb0>
    }
    return 0;
c0107f40:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107f45:	c9                   	leave  
c0107f46:	c3                   	ret    

c0107f47 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0107f47:	55                   	push   %ebp
c0107f48:	89 e5                	mov    %esp,%ebp
c0107f4a:	57                   	push   %edi
c0107f4b:	56                   	push   %esi
c0107f4c:	53                   	push   %ebx
c0107f4d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0107f50:	c7 04 24 74 b5 10 c0 	movl   $0xc010b574,(%esp)
c0107f57:	e8 4d 83 ff ff       	call   c01002a9 <cprintf>
    size_t left, right = 0, perm;
c0107f5c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107f63:	e9 fa 00 00 00       	jmp    c0108062 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f6b:	89 04 24             	mov    %eax,(%esp)
c0107f6e:	e8 e0 fe ff ff       	call   c0107e53 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0107f73:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107f76:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107f79:	29 d1                	sub    %edx,%ecx
c0107f7b:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107f7d:	89 d6                	mov    %edx,%esi
c0107f7f:	c1 e6 16             	shl    $0x16,%esi
c0107f82:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107f85:	89 d3                	mov    %edx,%ebx
c0107f87:	c1 e3 16             	shl    $0x16,%ebx
c0107f8a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107f8d:	89 d1                	mov    %edx,%ecx
c0107f8f:	c1 e1 16             	shl    $0x16,%ecx
c0107f92:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0107f95:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107f98:	29 d7                	sub    %edx,%edi
c0107f9a:	89 fa                	mov    %edi,%edx
c0107f9c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107fa0:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107fa4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107fac:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107fb0:	c7 04 24 a5 b5 10 c0 	movl   $0xc010b5a5,(%esp)
c0107fb7:	e8 ed 82 ff ff       	call   c01002a9 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0107fbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107fbf:	c1 e0 0a             	shl    $0xa,%eax
c0107fc2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107fc5:	eb 54                	jmp    c010801b <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107fc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107fca:	89 04 24             	mov    %eax,(%esp)
c0107fcd:	e8 81 fe ff ff       	call   c0107e53 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107fd2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0107fd5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107fd8:	29 d1                	sub    %edx,%ecx
c0107fda:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107fdc:	89 d6                	mov    %edx,%esi
c0107fde:	c1 e6 0c             	shl    $0xc,%esi
c0107fe1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107fe4:	89 d3                	mov    %edx,%ebx
c0107fe6:	c1 e3 0c             	shl    $0xc,%ebx
c0107fe9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107fec:	89 d1                	mov    %edx,%ecx
c0107fee:	c1 e1 0c             	shl    $0xc,%ecx
c0107ff1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0107ff4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107ff7:	29 d7                	sub    %edx,%edi
c0107ff9:	89 fa                	mov    %edi,%edx
c0107ffb:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107fff:	89 74 24 10          	mov    %esi,0x10(%esp)
c0108003:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108007:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010800b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010800f:	c7 04 24 c4 b5 10 c0 	movl   $0xc010b5c4,(%esp)
c0108016:	e8 8e 82 ff ff       	call   c01002a9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010801b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0108020:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108023:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108026:	89 d3                	mov    %edx,%ebx
c0108028:	c1 e3 0a             	shl    $0xa,%ebx
c010802b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010802e:	89 d1                	mov    %edx,%ecx
c0108030:	c1 e1 0a             	shl    $0xa,%ecx
c0108033:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0108036:	89 54 24 14          	mov    %edx,0x14(%esp)
c010803a:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010803d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0108041:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108045:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010804d:	89 0c 24             	mov    %ecx,(%esp)
c0108050:	e8 40 fe ff ff       	call   c0107e95 <get_pgtable_items>
c0108055:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108058:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010805c:	0f 85 65 ff ff ff    	jne    c0107fc7 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108062:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0108067:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010806a:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010806d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108071:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0108074:	89 54 24 10          	mov    %edx,0x10(%esp)
c0108078:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010807c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108080:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0108087:	00 
c0108088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010808f:	e8 01 fe ff ff       	call   c0107e95 <get_pgtable_items>
c0108094:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108097:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010809b:	0f 85 c7 fe ff ff    	jne    c0107f68 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01080a1:	c7 04 24 e8 b5 10 c0 	movl   $0xc010b5e8,(%esp)
c01080a8:	e8 fc 81 ff ff       	call   c01002a9 <cprintf>
c01080ad:	90                   	nop
c01080ae:	83 c4 4c             	add    $0x4c,%esp
c01080b1:	5b                   	pop    %ebx
c01080b2:	5e                   	pop    %esi
c01080b3:	5f                   	pop    %edi
c01080b4:	5d                   	pop    %ebp
c01080b5:	c3                   	ret    

c01080b6 <page2ppn>:
page2ppn(struct Page *page) {
c01080b6:	55                   	push   %ebp
c01080b7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01080b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01080bc:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01080c2:	29 d0                	sub    %edx,%eax
c01080c4:	c1 f8 05             	sar    $0x5,%eax
}
c01080c7:	5d                   	pop    %ebp
c01080c8:	c3                   	ret    

c01080c9 <page2pa>:
page2pa(struct Page *page) {
c01080c9:	55                   	push   %ebp
c01080ca:	89 e5                	mov    %esp,%ebp
c01080cc:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01080cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01080d2:	89 04 24             	mov    %eax,(%esp)
c01080d5:	e8 dc ff ff ff       	call   c01080b6 <page2ppn>
c01080da:	c1 e0 0c             	shl    $0xc,%eax
}
c01080dd:	c9                   	leave  
c01080de:	c3                   	ret    

c01080df <page2kva>:
page2kva(struct Page *page) {
c01080df:	55                   	push   %ebp
c01080e0:	89 e5                	mov    %esp,%ebp
c01080e2:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01080e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01080e8:	89 04 24             	mov    %eax,(%esp)
c01080eb:	e8 d9 ff ff ff       	call   c01080c9 <page2pa>
c01080f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080f6:	c1 e8 0c             	shr    $0xc,%eax
c01080f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080fc:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0108101:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108104:	72 23                	jb     c0108129 <page2kva+0x4a>
c0108106:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108109:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010810d:	c7 44 24 08 1c b6 10 	movl   $0xc010b61c,0x8(%esp)
c0108114:	c0 
c0108115:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010811c:	00 
c010811d:	c7 04 24 3f b6 10 c0 	movl   $0xc010b63f,(%esp)
c0108124:	e8 d7 82 ff ff       	call   c0100400 <__panic>
c0108129:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010812c:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108131:	c9                   	leave  
c0108132:	c3                   	ret    

c0108133 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108133:	55                   	push   %ebp
c0108134:	89 e5                	mov    %esp,%ebp
c0108136:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0108139:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108140:	e8 b5 8f ff ff       	call   c01010fa <ide_device_valid>
c0108145:	85 c0                	test   %eax,%eax
c0108147:	75 1c                	jne    c0108165 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0108149:	c7 44 24 08 4d b6 10 	movl   $0xc010b64d,0x8(%esp)
c0108150:	c0 
c0108151:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0108158:	00 
c0108159:	c7 04 24 67 b6 10 c0 	movl   $0xc010b667,(%esp)
c0108160:	e8 9b 82 ff ff       	call   c0100400 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0108165:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010816c:	e8 c7 8f ff ff       	call   c0101138 <ide_device_size>
c0108171:	c1 e8 03             	shr    $0x3,%eax
c0108174:	a3 1c a1 12 c0       	mov    %eax,0xc012a11c
}
c0108179:	90                   	nop
c010817a:	c9                   	leave  
c010817b:	c3                   	ret    

c010817c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010817c:	55                   	push   %ebp
c010817d:	89 e5                	mov    %esp,%ebp
c010817f:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108182:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108185:	89 04 24             	mov    %eax,(%esp)
c0108188:	e8 52 ff ff ff       	call   c01080df <page2kva>
c010818d:	8b 55 08             	mov    0x8(%ebp),%edx
c0108190:	c1 ea 08             	shr    $0x8,%edx
c0108193:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108196:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010819a:	74 0b                	je     c01081a7 <swapfs_read+0x2b>
c010819c:	8b 15 1c a1 12 c0    	mov    0xc012a11c,%edx
c01081a2:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01081a5:	72 23                	jb     c01081ca <swapfs_read+0x4e>
c01081a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01081aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01081ae:	c7 44 24 08 78 b6 10 	movl   $0xc010b678,0x8(%esp)
c01081b5:	c0 
c01081b6:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01081bd:	00 
c01081be:	c7 04 24 67 b6 10 c0 	movl   $0xc010b667,(%esp)
c01081c5:	e8 36 82 ff ff       	call   c0100400 <__panic>
c01081ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01081cd:	c1 e2 03             	shl    $0x3,%edx
c01081d0:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01081d7:	00 
c01081d8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081dc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01081e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01081e7:	e8 87 8f ff ff       	call   c0101173 <ide_read_secs>
}
c01081ec:	c9                   	leave  
c01081ed:	c3                   	ret    

c01081ee <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01081ee:	55                   	push   %ebp
c01081ef:	89 e5                	mov    %esp,%ebp
c01081f1:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01081f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081f7:	89 04 24             	mov    %eax,(%esp)
c01081fa:	e8 e0 fe ff ff       	call   c01080df <page2kva>
c01081ff:	8b 55 08             	mov    0x8(%ebp),%edx
c0108202:	c1 ea 08             	shr    $0x8,%edx
c0108205:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108208:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010820c:	74 0b                	je     c0108219 <swapfs_write+0x2b>
c010820e:	8b 15 1c a1 12 c0    	mov    0xc012a11c,%edx
c0108214:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108217:	72 23                	jb     c010823c <swapfs_write+0x4e>
c0108219:	8b 45 08             	mov    0x8(%ebp),%eax
c010821c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108220:	c7 44 24 08 78 b6 10 	movl   $0xc010b678,0x8(%esp)
c0108227:	c0 
c0108228:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010822f:	00 
c0108230:	c7 04 24 67 b6 10 c0 	movl   $0xc010b667,(%esp)
c0108237:	e8 c4 81 ff ff       	call   c0100400 <__panic>
c010823c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010823f:	c1 e2 03             	shl    $0x3,%edx
c0108242:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108249:	00 
c010824a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010824e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108252:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108259:	e8 4e 91 ff ff       	call   c01013ac <ide_write_secs>
}
c010825e:	c9                   	leave  
c010825f:	c3                   	ret    

c0108260 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0108260:	52                   	push   %edx
    call *%ebx              # call fn
c0108261:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0108263:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0108264:	e8 b5 06 00 00       	call   c010891e <do_exit>

c0108269 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0108269:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010826d:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c010826f:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0108272:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c0108275:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c0108278:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c010827b:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c010827e:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c0108281:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0108284:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c0108288:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c010828b:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c010828e:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c0108291:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0108294:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c0108297:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c010829a:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010829d:	ff 30                	pushl  (%eax)

    ret
c010829f:	c3                   	ret    

c01082a0 <__intr_save>:
__intr_save(void) {
c01082a0:	55                   	push   %ebp
c01082a1:	89 e5                	mov    %esp,%ebp
c01082a3:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01082a6:	9c                   	pushf  
c01082a7:	58                   	pop    %eax
c01082a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01082ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01082ae:	25 00 02 00 00       	and    $0x200,%eax
c01082b3:	85 c0                	test   %eax,%eax
c01082b5:	74 0c                	je     c01082c3 <__intr_save+0x23>
        intr_disable();
c01082b7:	e8 2c 9e ff ff       	call   c01020e8 <intr_disable>
        return 1;
c01082bc:	b8 01 00 00 00       	mov    $0x1,%eax
c01082c1:	eb 05                	jmp    c01082c8 <__intr_save+0x28>
    return 0;
c01082c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01082c8:	c9                   	leave  
c01082c9:	c3                   	ret    

c01082ca <__intr_restore>:
__intr_restore(bool flag) {
c01082ca:	55                   	push   %ebp
c01082cb:	89 e5                	mov    %esp,%ebp
c01082cd:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01082d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01082d4:	74 05                	je     c01082db <__intr_restore+0x11>
        intr_enable();
c01082d6:	e8 06 9e ff ff       	call   c01020e1 <intr_enable>
}
c01082db:	90                   	nop
c01082dc:	c9                   	leave  
c01082dd:	c3                   	ret    

c01082de <page2ppn>:
page2ppn(struct Page *page) {
c01082de:	55                   	push   %ebp
c01082df:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01082e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01082e4:	8b 15 58 a1 12 c0    	mov    0xc012a158,%edx
c01082ea:	29 d0                	sub    %edx,%eax
c01082ec:	c1 f8 05             	sar    $0x5,%eax
}
c01082ef:	5d                   	pop    %ebp
c01082f0:	c3                   	ret    

c01082f1 <page2pa>:
page2pa(struct Page *page) {
c01082f1:	55                   	push   %ebp
c01082f2:	89 e5                	mov    %esp,%ebp
c01082f4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01082f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01082fa:	89 04 24             	mov    %eax,(%esp)
c01082fd:	e8 dc ff ff ff       	call   c01082de <page2ppn>
c0108302:	c1 e0 0c             	shl    $0xc,%eax
}
c0108305:	c9                   	leave  
c0108306:	c3                   	ret    

c0108307 <pa2page>:
pa2page(uintptr_t pa) {
c0108307:	55                   	push   %ebp
c0108308:	89 e5                	mov    %esp,%ebp
c010830a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010830d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108310:	c1 e8 0c             	shr    $0xc,%eax
c0108313:	89 c2                	mov    %eax,%edx
c0108315:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010831a:	39 c2                	cmp    %eax,%edx
c010831c:	72 1c                	jb     c010833a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010831e:	c7 44 24 08 98 b6 10 	movl   $0xc010b698,0x8(%esp)
c0108325:	c0 
c0108326:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010832d:	00 
c010832e:	c7 04 24 b7 b6 10 c0 	movl   $0xc010b6b7,(%esp)
c0108335:	e8 c6 80 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c010833a:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c010833f:	8b 55 08             	mov    0x8(%ebp),%edx
c0108342:	c1 ea 0c             	shr    $0xc,%edx
c0108345:	c1 e2 05             	shl    $0x5,%edx
c0108348:	01 d0                	add    %edx,%eax
}
c010834a:	c9                   	leave  
c010834b:	c3                   	ret    

c010834c <page2kva>:
page2kva(struct Page *page) {
c010834c:	55                   	push   %ebp
c010834d:	89 e5                	mov    %esp,%ebp
c010834f:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108352:	8b 45 08             	mov    0x8(%ebp),%eax
c0108355:	89 04 24             	mov    %eax,(%esp)
c0108358:	e8 94 ff ff ff       	call   c01082f1 <page2pa>
c010835d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108360:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108363:	c1 e8 0c             	shr    $0xc,%eax
c0108366:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108369:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010836e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108371:	72 23                	jb     c0108396 <page2kva+0x4a>
c0108373:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108376:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010837a:	c7 44 24 08 c8 b6 10 	movl   $0xc010b6c8,0x8(%esp)
c0108381:	c0 
c0108382:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0108389:	00 
c010838a:	c7 04 24 b7 b6 10 c0 	movl   $0xc010b6b7,(%esp)
c0108391:	e8 6a 80 ff ff       	call   c0100400 <__panic>
c0108396:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108399:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010839e:	c9                   	leave  
c010839f:	c3                   	ret    

c01083a0 <kva2page>:
kva2page(void *kva) {
c01083a0:	55                   	push   %ebp
c01083a1:	89 e5                	mov    %esp,%ebp
c01083a3:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01083a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01083a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083ac:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01083b3:	77 23                	ja     c01083d8 <kva2page+0x38>
c01083b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01083bc:	c7 44 24 08 ec b6 10 	movl   $0xc010b6ec,0x8(%esp)
c01083c3:	c0 
c01083c4:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01083cb:	00 
c01083cc:	c7 04 24 b7 b6 10 c0 	movl   $0xc010b6b7,(%esp)
c01083d3:	e8 28 80 ff ff       	call   c0100400 <__panic>
c01083d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083db:	05 00 00 00 40       	add    $0x40000000,%eax
c01083e0:	89 04 24             	mov    %eax,(%esp)
c01083e3:	e8 1f ff ff ff       	call   c0108307 <pa2page>
}
c01083e8:	c9                   	leave  
c01083e9:	c3                   	ret    

c01083ea <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c01083ea:	55                   	push   %ebp
c01083eb:	89 e5                	mov    %esp,%ebp
c01083ed:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c01083f0:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c01083f7:	e8 79 c3 ff ff       	call   c0104775 <kmalloc>
c01083fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    }
    return proc;
c01083ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108402:	c9                   	leave  
c0108403:	c3                   	ret    

c0108404 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0108404:	55                   	push   %ebp
c0108405:	89 e5                	mov    %esp,%ebp
c0108407:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c010840a:	8b 45 08             	mov    0x8(%ebp),%eax
c010840d:	83 c0 48             	add    $0x48,%eax
c0108410:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108417:	00 
c0108418:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010841f:	00 
c0108420:	89 04 24             	mov    %eax,(%esp)
c0108423:	e8 b5 0b 00 00       	call   c0108fdd <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0108428:	8b 45 08             	mov    0x8(%ebp),%eax
c010842b:	8d 50 48             	lea    0x48(%eax),%edx
c010842e:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108435:	00 
c0108436:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108439:	89 44 24 04          	mov    %eax,0x4(%esp)
c010843d:	89 14 24             	mov    %edx,(%esp)
c0108440:	e8 7b 0c 00 00       	call   c01090c0 <memcpy>
}
c0108445:	c9                   	leave  
c0108446:	c3                   	ret    

c0108447 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0108447:	55                   	push   %ebp
c0108448:	89 e5                	mov    %esp,%ebp
c010844a:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c010844d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108454:	00 
c0108455:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010845c:	00 
c010845d:	c7 04 24 44 a0 12 c0 	movl   $0xc012a044,(%esp)
c0108464:	e8 74 0b 00 00       	call   c0108fdd <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0108469:	8b 45 08             	mov    0x8(%ebp),%eax
c010846c:	83 c0 48             	add    $0x48,%eax
c010846f:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108476:	00 
c0108477:	89 44 24 04          	mov    %eax,0x4(%esp)
c010847b:	c7 04 24 44 a0 12 c0 	movl   $0xc012a044,(%esp)
c0108482:	e8 39 0c 00 00       	call   c01090c0 <memcpy>
}
c0108487:	c9                   	leave  
c0108488:	c3                   	ret    

c0108489 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0108489:	55                   	push   %ebp
c010848a:	89 e5                	mov    %esp,%ebp
c010848c:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010848f:	c7 45 f8 5c a1 12 c0 	movl   $0xc012a15c,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0108496:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010849b:	40                   	inc    %eax
c010849c:	a3 78 4a 12 c0       	mov    %eax,0xc0124a78
c01084a1:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c01084a6:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01084ab:	7e 0c                	jle    c01084b9 <get_pid+0x30>
        last_pid = 1;
c01084ad:	c7 05 78 4a 12 c0 01 	movl   $0x1,0xc0124a78
c01084b4:	00 00 00 
        goto inside;
c01084b7:	eb 14                	jmp    c01084cd <get_pid+0x44>
    }
    if (last_pid >= next_safe) {
c01084b9:	8b 15 78 4a 12 c0    	mov    0xc0124a78,%edx
c01084bf:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c01084c4:	39 c2                	cmp    %eax,%edx
c01084c6:	0f 8c ab 00 00 00    	jl     c0108577 <get_pid+0xee>
    inside:
c01084cc:	90                   	nop
        next_safe = MAX_PID;
c01084cd:	c7 05 7c 4a 12 c0 00 	movl   $0x2000,0xc0124a7c
c01084d4:	20 00 00 
    repeat:
        le = list;
c01084d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01084da:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c01084dd:	eb 7d                	jmp    c010855c <get_pid+0xd3>
            proc = le2proc(le, list_link);
c01084df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01084e2:	83 e8 58             	sub    $0x58,%eax
c01084e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c01084e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084eb:	8b 50 04             	mov    0x4(%eax),%edx
c01084ee:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c01084f3:	39 c2                	cmp    %eax,%edx
c01084f5:	75 3c                	jne    c0108533 <get_pid+0xaa>
                if (++ last_pid >= next_safe) {
c01084f7:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c01084fc:	40                   	inc    %eax
c01084fd:	a3 78 4a 12 c0       	mov    %eax,0xc0124a78
c0108502:	8b 15 78 4a 12 c0    	mov    0xc0124a78,%edx
c0108508:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c010850d:	39 c2                	cmp    %eax,%edx
c010850f:	7c 4b                	jl     c010855c <get_pid+0xd3>
                    if (last_pid >= MAX_PID) {
c0108511:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c0108516:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c010851b:	7e 0a                	jle    c0108527 <get_pid+0x9e>
                        last_pid = 1;
c010851d:	c7 05 78 4a 12 c0 01 	movl   $0x1,0xc0124a78
c0108524:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108527:	c7 05 7c 4a 12 c0 00 	movl   $0x2000,0xc0124a7c
c010852e:	20 00 00 
                    goto repeat;
c0108531:	eb a4                	jmp    c01084d7 <get_pid+0x4e>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0108533:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108536:	8b 50 04             	mov    0x4(%eax),%edx
c0108539:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010853e:	39 c2                	cmp    %eax,%edx
c0108540:	7e 1a                	jle    c010855c <get_pid+0xd3>
c0108542:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108545:	8b 50 04             	mov    0x4(%eax),%edx
c0108548:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c010854d:	39 c2                	cmp    %eax,%edx
c010854f:	7d 0b                	jge    c010855c <get_pid+0xd3>
                next_safe = proc->pid;
c0108551:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108554:	8b 40 04             	mov    0x4(%eax),%eax
c0108557:	a3 7c 4a 12 c0       	mov    %eax,0xc0124a7c
c010855c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010855f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108562:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108565:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0108568:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010856b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010856e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0108571:	0f 85 68 ff ff ff    	jne    c01084df <get_pid+0x56>
            }
        }
    }
    return last_pid;
c0108577:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
}
c010857c:	c9                   	leave  
c010857d:	c3                   	ret    

c010857e <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010857e:	55                   	push   %ebp
c010857f:	89 e5                	mov    %esp,%ebp
c0108581:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0108584:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108589:	39 45 08             	cmp    %eax,0x8(%ebp)
c010858c:	74 63                	je     c01085f1 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c010858e:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108593:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108596:	8b 45 08             	mov    0x8(%ebp),%eax
c0108599:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c010859c:	e8 ff fc ff ff       	call   c01082a0 <__intr_save>
c01085a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c01085a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01085a7:	a3 28 80 12 c0       	mov    %eax,0xc0128028
            load_esp0(next->kstack + KSTACKSIZE);
c01085ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085af:	8b 40 0c             	mov    0xc(%eax),%eax
c01085b2:	05 00 20 00 00       	add    $0x2000,%eax
c01085b7:	89 04 24             	mov    %eax,(%esp)
c01085ba:	e8 0e e3 ff ff       	call   c01068cd <load_esp0>
            lcr3(next->cr3);
c01085bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085c2:	8b 40 40             	mov    0x40(%eax),%eax
c01085c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01085c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085cb:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c01085ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085d1:	8d 50 1c             	lea    0x1c(%eax),%edx
c01085d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085d7:	83 c0 1c             	add    $0x1c,%eax
c01085da:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085de:	89 04 24             	mov    %eax,(%esp)
c01085e1:	e8 83 fc ff ff       	call   c0108269 <switch_to>
        }
        local_intr_restore(intr_flag);
c01085e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085e9:	89 04 24             	mov    %eax,(%esp)
c01085ec:	e8 d9 fc ff ff       	call   c01082ca <__intr_restore>
    }
}
c01085f1:	90                   	nop
c01085f2:	c9                   	leave  
c01085f3:	c3                   	ret    

c01085f4 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c01085f4:	55                   	push   %ebp
c01085f5:	89 e5                	mov    %esp,%ebp
c01085f7:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c01085fa:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01085ff:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108602:	89 04 24             	mov    %eax,(%esp)
c0108605:	e8 04 ab ff ff       	call   c010310e <forkrets>
}
c010860a:	90                   	nop
c010860b:	c9                   	leave  
c010860c:	c3                   	ret    

c010860d <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c010860d:	55                   	push   %ebp
c010860e:	89 e5                	mov    %esp,%ebp
c0108610:	53                   	push   %ebx
c0108611:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108614:	8b 45 08             	mov    0x8(%ebp),%eax
c0108617:	8d 58 60             	lea    0x60(%eax),%ebx
c010861a:	8b 45 08             	mov    0x8(%ebp),%eax
c010861d:	8b 40 04             	mov    0x4(%eax),%eax
c0108620:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108627:	00 
c0108628:	89 04 24             	mov    %eax,(%esp)
c010862b:	e8 a7 11 00 00       	call   c01097d7 <hash32>
c0108630:	c1 e0 03             	shl    $0x3,%eax
c0108633:	05 40 80 12 c0       	add    $0xc0128040,%eax
c0108638:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010863b:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c010863e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108641:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108644:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108647:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c010864a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010864d:	8b 40 04             	mov    0x4(%eax),%eax
c0108650:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108653:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108656:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108659:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010865c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c010865f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108662:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108665:	89 10                	mov    %edx,(%eax)
c0108667:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010866a:	8b 10                	mov    (%eax),%edx
c010866c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010866f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108675:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108678:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010867b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010867e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108681:	89 10                	mov    %edx,(%eax)
}
c0108683:	90                   	nop
c0108684:	83 c4 34             	add    $0x34,%esp
c0108687:	5b                   	pop    %ebx
c0108688:	5d                   	pop    %ebp
c0108689:	c3                   	ret    

c010868a <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c010868a:	55                   	push   %ebp
c010868b:	89 e5                	mov    %esp,%ebp
c010868d:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0108690:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108694:	7e 5f                	jle    c01086f5 <find_proc+0x6b>
c0108696:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c010869d:	7f 56                	jg     c01086f5 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c010869f:	8b 45 08             	mov    0x8(%ebp),%eax
c01086a2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c01086a9:	00 
c01086aa:	89 04 24             	mov    %eax,(%esp)
c01086ad:	e8 25 11 00 00       	call   c01097d7 <hash32>
c01086b2:	c1 e0 03             	shl    $0x3,%eax
c01086b5:	05 40 80 12 c0       	add    $0xc0128040,%eax
c01086ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01086bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01086c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c01086c3:	eb 19                	jmp    c01086de <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c01086c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086c8:	83 e8 60             	sub    $0x60,%eax
c01086cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c01086ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086d1:	8b 40 04             	mov    0x4(%eax),%eax
c01086d4:	39 45 08             	cmp    %eax,0x8(%ebp)
c01086d7:	75 05                	jne    c01086de <find_proc+0x54>
                return proc;
c01086d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086dc:	eb 1c                	jmp    c01086fa <find_proc+0x70>
c01086de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c01086e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01086e7:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01086ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086f0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01086f3:	75 d0                	jne    c01086c5 <find_proc+0x3b>
            }
        }
    }
    return NULL;
c01086f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01086fa:	c9                   	leave  
c01086fb:	c3                   	ret    

c01086fc <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c01086fc:	55                   	push   %ebp
c01086fd:	89 e5                	mov    %esp,%ebp
c01086ff:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108702:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108709:	00 
c010870a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108711:	00 
c0108712:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108715:	89 04 24             	mov    %eax,(%esp)
c0108718:	e8 c0 08 00 00       	call   c0108fdd <memset>
    tf.tf_cs = KERNEL_CS;
c010871d:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108723:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108729:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010872d:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108731:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108735:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108739:	8b 45 08             	mov    0x8(%ebp),%eax
c010873c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c010873f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108742:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0108745:	b8 60 82 10 c0       	mov    $0xc0108260,%eax
c010874a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c010874d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108750:	0d 00 01 00 00       	or     $0x100,%eax
c0108755:	89 c2                	mov    %eax,%edx
c0108757:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010875a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010875e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108765:	00 
c0108766:	89 14 24             	mov    %edx,(%esp)
c0108769:	e8 88 01 00 00       	call   c01088f6 <do_fork>
}
c010876e:	c9                   	leave  
c010876f:	c3                   	ret    

c0108770 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0108770:	55                   	push   %ebp
c0108771:	89 e5                	mov    %esp,%ebp
c0108773:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108776:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010877d:	e8 96 e2 ff ff       	call   c0106a18 <alloc_pages>
c0108782:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108785:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108789:	74 1a                	je     c01087a5 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c010878b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010878e:	89 04 24             	mov    %eax,(%esp)
c0108791:	e8 b6 fb ff ff       	call   c010834c <page2kva>
c0108796:	89 c2                	mov    %eax,%edx
c0108798:	8b 45 08             	mov    0x8(%ebp),%eax
c010879b:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c010879e:	b8 00 00 00 00       	mov    $0x0,%eax
c01087a3:	eb 05                	jmp    c01087aa <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c01087a5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c01087aa:	c9                   	leave  
c01087ab:	c3                   	ret    

c01087ac <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c01087ac:	55                   	push   %ebp
c01087ad:	89 e5                	mov    %esp,%ebp
c01087af:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c01087b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01087b5:	8b 40 0c             	mov    0xc(%eax),%eax
c01087b8:	89 04 24             	mov    %eax,(%esp)
c01087bb:	e8 e0 fb ff ff       	call   c01083a0 <kva2page>
c01087c0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01087c7:	00 
c01087c8:	89 04 24             	mov    %eax,(%esp)
c01087cb:	e8 80 e2 ff ff       	call   c0106a50 <free_pages>
}
c01087d0:	90                   	nop
c01087d1:	c9                   	leave  
c01087d2:	c3                   	ret    

c01087d3 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c01087d3:	55                   	push   %ebp
c01087d4:	89 e5                	mov    %esp,%ebp
c01087d6:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c01087d9:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01087de:	8b 40 18             	mov    0x18(%eax),%eax
c01087e1:	85 c0                	test   %eax,%eax
c01087e3:	74 24                	je     c0108809 <copy_mm+0x36>
c01087e5:	c7 44 24 0c 10 b7 10 	movl   $0xc010b710,0xc(%esp)
c01087ec:	c0 
c01087ed:	c7 44 24 08 24 b7 10 	movl   $0xc010b724,0x8(%esp)
c01087f4:	c0 
c01087f5:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01087fc:	00 
c01087fd:	c7 04 24 39 b7 10 c0 	movl   $0xc010b739,(%esp)
c0108804:	e8 f7 7b ff ff       	call   c0100400 <__panic>
    /* do nothing in this project */
    return 0;
c0108809:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010880e:	c9                   	leave  
c010880f:	c3                   	ret    

c0108810 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0108810:	55                   	push   %ebp
c0108811:	89 e5                	mov    %esp,%ebp
c0108813:	57                   	push   %edi
c0108814:	56                   	push   %esi
c0108815:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108816:	8b 45 08             	mov    0x8(%ebp),%eax
c0108819:	8b 40 0c             	mov    0xc(%eax),%eax
c010881c:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108821:	89 c2                	mov    %eax,%edx
c0108823:	8b 45 08             	mov    0x8(%ebp),%eax
c0108826:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108829:	8b 45 08             	mov    0x8(%ebp),%eax
c010882c:	8b 40 3c             	mov    0x3c(%eax),%eax
c010882f:	8b 55 10             	mov    0x10(%ebp),%edx
c0108832:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0108837:	89 c1                	mov    %eax,%ecx
c0108839:	83 e1 01             	and    $0x1,%ecx
c010883c:	85 c9                	test   %ecx,%ecx
c010883e:	74 0c                	je     c010884c <copy_thread+0x3c>
c0108840:	0f b6 0a             	movzbl (%edx),%ecx
c0108843:	88 08                	mov    %cl,(%eax)
c0108845:	8d 40 01             	lea    0x1(%eax),%eax
c0108848:	8d 52 01             	lea    0x1(%edx),%edx
c010884b:	4b                   	dec    %ebx
c010884c:	89 c1                	mov    %eax,%ecx
c010884e:	83 e1 02             	and    $0x2,%ecx
c0108851:	85 c9                	test   %ecx,%ecx
c0108853:	74 0f                	je     c0108864 <copy_thread+0x54>
c0108855:	0f b7 0a             	movzwl (%edx),%ecx
c0108858:	66 89 08             	mov    %cx,(%eax)
c010885b:	8d 40 02             	lea    0x2(%eax),%eax
c010885e:	8d 52 02             	lea    0x2(%edx),%edx
c0108861:	83 eb 02             	sub    $0x2,%ebx
c0108864:	89 df                	mov    %ebx,%edi
c0108866:	83 e7 fc             	and    $0xfffffffc,%edi
c0108869:	b9 00 00 00 00       	mov    $0x0,%ecx
c010886e:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0108871:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0108874:	83 c1 04             	add    $0x4,%ecx
c0108877:	39 f9                	cmp    %edi,%ecx
c0108879:	72 f3                	jb     c010886e <copy_thread+0x5e>
c010887b:	01 c8                	add    %ecx,%eax
c010887d:	01 ca                	add    %ecx,%edx
c010887f:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108884:	89 de                	mov    %ebx,%esi
c0108886:	83 e6 02             	and    $0x2,%esi
c0108889:	85 f6                	test   %esi,%esi
c010888b:	74 0b                	je     c0108898 <copy_thread+0x88>
c010888d:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0108891:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0108895:	83 c1 02             	add    $0x2,%ecx
c0108898:	83 e3 01             	and    $0x1,%ebx
c010889b:	85 db                	test   %ebx,%ebx
c010889d:	74 07                	je     c01088a6 <copy_thread+0x96>
c010889f:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c01088a3:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c01088a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a9:	8b 40 3c             	mov    0x3c(%eax),%eax
c01088ac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c01088b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01088b6:	8b 40 3c             	mov    0x3c(%eax),%eax
c01088b9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01088bc:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c01088bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01088c2:	8b 40 3c             	mov    0x3c(%eax),%eax
c01088c5:	8b 50 40             	mov    0x40(%eax),%edx
c01088c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01088cb:	8b 40 3c             	mov    0x3c(%eax),%eax
c01088ce:	81 ca 00 02 00 00    	or     $0x200,%edx
c01088d4:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c01088d7:	ba f4 85 10 c0       	mov    $0xc01085f4,%edx
c01088dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01088df:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c01088e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01088e5:	8b 40 3c             	mov    0x3c(%eax),%eax
c01088e8:	89 c2                	mov    %eax,%edx
c01088ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ed:	89 50 20             	mov    %edx,0x20(%eax)
}
c01088f0:	90                   	nop
c01088f1:	5b                   	pop    %ebx
c01088f2:	5e                   	pop    %esi
c01088f3:	5f                   	pop    %edi
c01088f4:	5d                   	pop    %ebp
c01088f5:	c3                   	ret    

c01088f6 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c01088f6:	55                   	push   %ebp
c01088f7:	89 e5                	mov    %esp,%ebp
c01088f9:	83 ec 10             	sub    $0x10,%esp
    int ret = -E_NO_FREE_PROC;
c01088fc:	c7 45 fc fb ff ff ff 	movl   $0xfffffffb,-0x4(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108903:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c0108908:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010890d:	7f 09                	jg     c0108918 <do_fork+0x22>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010890f:	c7 45 fc fc ff ff ff 	movl   $0xfffffffc,-0x4(%ebp)
c0108916:	eb 01                	jmp    c0108919 <do_fork+0x23>
        goto fork_out;
c0108918:	90                   	nop
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
fork_out:
    return ret;
c0108919:	8b 45 fc             	mov    -0x4(%ebp),%eax
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
c010891c:	c9                   	leave  
c010891d:	c3                   	ret    

c010891e <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010891e:	55                   	push   %ebp
c010891f:	89 e5                	mov    %esp,%ebp
c0108921:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c0108924:	c7 44 24 08 4d b7 10 	movl   $0xc010b74d,0x8(%esp)
c010892b:	c0 
c010892c:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108933:	00 
c0108934:	c7 04 24 39 b7 10 c0 	movl   $0xc010b739,(%esp)
c010893b:	e8 c0 7a ff ff       	call   c0100400 <__panic>

c0108940 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0108940:	55                   	push   %ebp
c0108941:	89 e5                	mov    %esp,%ebp
c0108943:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0108946:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c010894b:	89 04 24             	mov    %eax,(%esp)
c010894e:	e8 f4 fa ff ff       	call   c0108447 <get_proc_name>
c0108953:	89 c2                	mov    %eax,%edx
c0108955:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c010895a:	8b 40 04             	mov    0x4(%eax),%eax
c010895d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108961:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108965:	c7 04 24 60 b7 10 c0 	movl   $0xc010b760,(%esp)
c010896c:	e8 38 79 ff ff       	call   c01002a9 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0108971:	8b 45 08             	mov    0x8(%ebp),%eax
c0108974:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108978:	c7 04 24 86 b7 10 c0 	movl   $0xc010b786,(%esp)
c010897f:	e8 25 79 ff ff       	call   c01002a9 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0108984:	c7 04 24 93 b7 10 c0 	movl   $0xc010b793,(%esp)
c010898b:	e8 19 79 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0108990:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108995:	c9                   	leave  
c0108996:	c3                   	ret    

c0108997 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0108997:	55                   	push   %ebp
c0108998:	89 e5                	mov    %esp,%ebp
c010899a:	83 ec 28             	sub    $0x28,%esp
c010899d:	c7 45 ec 5c a1 12 c0 	movl   $0xc012a15c,-0x14(%ebp)
    elm->prev = elm->next = elm;
c01089a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01089aa:	89 50 04             	mov    %edx,0x4(%eax)
c01089ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089b0:	8b 50 04             	mov    0x4(%eax),%edx
c01089b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089b6:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c01089b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01089bf:	eb 25                	jmp    c01089e6 <proc_init+0x4f>
        list_init(hash_list + i);
c01089c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089c4:	c1 e0 03             	shl    $0x3,%eax
c01089c7:	05 40 80 12 c0       	add    $0xc0128040,%eax
c01089cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01089cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089d2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01089d5:	89 50 04             	mov    %edx,0x4(%eax)
c01089d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089db:	8b 50 04             	mov    0x4(%eax),%edx
c01089de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089e1:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c01089e3:	ff 45 f4             	incl   -0xc(%ebp)
c01089e6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c01089ed:	7e d2                	jle    c01089c1 <proc_init+0x2a>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c01089ef:	e8 f6 f9 ff ff       	call   c01083ea <alloc_proc>
c01089f4:	a3 20 80 12 c0       	mov    %eax,0xc0128020
c01089f9:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c01089fe:	85 c0                	test   %eax,%eax
c0108a00:	75 1c                	jne    c0108a1e <proc_init+0x87>
        panic("cannot alloc idleproc.\n");
c0108a02:	c7 44 24 08 af b7 10 	movl   $0xc010b7af,0x8(%esp)
c0108a09:	c0 
c0108a0a:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
c0108a11:	00 
c0108a12:	c7 04 24 39 b7 10 c0 	movl   $0xc010b739,(%esp)
c0108a19:	e8 e2 79 ff ff       	call   c0100400 <__panic>
    }

    idleproc->pid = 0;
c0108a1e:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108a23:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0108a2a:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108a2f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c0108a35:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108a3a:	ba 00 20 12 c0       	mov    $0xc0122000,%edx
c0108a3f:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0108a42:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108a47:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0108a4e:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108a53:	c7 44 24 04 c7 b7 10 	movl   $0xc010b7c7,0x4(%esp)
c0108a5a:	c0 
c0108a5b:	89 04 24             	mov    %eax,(%esp)
c0108a5e:	e8 a1 f9 ff ff       	call   c0108404 <set_proc_name>
    nr_process ++;
c0108a63:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c0108a68:	40                   	inc    %eax
c0108a69:	a3 40 a0 12 c0       	mov    %eax,0xc012a040

    current = idleproc;
c0108a6e:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108a73:	a3 28 80 12 c0       	mov    %eax,0xc0128028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0108a78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108a7f:	00 
c0108a80:	c7 44 24 04 cc b7 10 	movl   $0xc010b7cc,0x4(%esp)
c0108a87:	c0 
c0108a88:	c7 04 24 40 89 10 c0 	movl   $0xc0108940,(%esp)
c0108a8f:	e8 68 fc ff ff       	call   c01086fc <kernel_thread>
c0108a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c0108a97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108a9b:	7f 1c                	jg     c0108ab9 <proc_init+0x122>
        panic("create init_main failed.\n");
c0108a9d:	c7 44 24 08 da b7 10 	movl   $0xc010b7da,0x8(%esp)
c0108aa4:	c0 
c0108aa5:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108aac:	00 
c0108aad:	c7 04 24 39 b7 10 c0 	movl   $0xc010b739,(%esp)
c0108ab4:	e8 47 79 ff ff       	call   c0100400 <__panic>
    }

    initproc = find_proc(pid);
c0108ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108abc:	89 04 24             	mov    %eax,(%esp)
c0108abf:	e8 c6 fb ff ff       	call   c010868a <find_proc>
c0108ac4:	a3 24 80 12 c0       	mov    %eax,0xc0128024
    set_proc_name(initproc, "init");
c0108ac9:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0108ace:	c7 44 24 04 f4 b7 10 	movl   $0xc010b7f4,0x4(%esp)
c0108ad5:	c0 
c0108ad6:	89 04 24             	mov    %eax,(%esp)
c0108ad9:	e8 26 f9 ff ff       	call   c0108404 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c0108ade:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108ae3:	85 c0                	test   %eax,%eax
c0108ae5:	74 0c                	je     c0108af3 <proc_init+0x15c>
c0108ae7:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108aec:	8b 40 04             	mov    0x4(%eax),%eax
c0108aef:	85 c0                	test   %eax,%eax
c0108af1:	74 24                	je     c0108b17 <proc_init+0x180>
c0108af3:	c7 44 24 0c fc b7 10 	movl   $0xc010b7fc,0xc(%esp)
c0108afa:	c0 
c0108afb:	c7 44 24 08 24 b7 10 	movl   $0xc010b724,0x8(%esp)
c0108b02:	c0 
c0108b03:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
c0108b0a:	00 
c0108b0b:	c7 04 24 39 b7 10 c0 	movl   $0xc010b739,(%esp)
c0108b12:	e8 e9 78 ff ff       	call   c0100400 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0108b17:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0108b1c:	85 c0                	test   %eax,%eax
c0108b1e:	74 0d                	je     c0108b2d <proc_init+0x196>
c0108b20:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0108b25:	8b 40 04             	mov    0x4(%eax),%eax
c0108b28:	83 f8 01             	cmp    $0x1,%eax
c0108b2b:	74 24                	je     c0108b51 <proc_init+0x1ba>
c0108b2d:	c7 44 24 0c 24 b8 10 	movl   $0xc010b824,0xc(%esp)
c0108b34:	c0 
c0108b35:	c7 44 24 08 24 b7 10 	movl   $0xc010b724,0x8(%esp)
c0108b3c:	c0 
c0108b3d:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
c0108b44:	00 
c0108b45:	c7 04 24 39 b7 10 c0 	movl   $0xc010b739,(%esp)
c0108b4c:	e8 af 78 ff ff       	call   c0100400 <__panic>
}
c0108b51:	90                   	nop
c0108b52:	c9                   	leave  
c0108b53:	c3                   	ret    

c0108b54 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c0108b54:	55                   	push   %ebp
c0108b55:	89 e5                	mov    %esp,%ebp
c0108b57:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0108b5a:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108b5f:	8b 40 10             	mov    0x10(%eax),%eax
c0108b62:	85 c0                	test   %eax,%eax
c0108b64:	74 f4                	je     c0108b5a <cpu_idle+0x6>
            schedule();
c0108b66:	e8 8a 00 00 00       	call   c0108bf5 <schedule>
        if (current->need_resched) {
c0108b6b:	eb ed                	jmp    c0108b5a <cpu_idle+0x6>

c0108b6d <__intr_save>:
__intr_save(void) {
c0108b6d:	55                   	push   %ebp
c0108b6e:	89 e5                	mov    %esp,%ebp
c0108b70:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0108b73:	9c                   	pushf  
c0108b74:	58                   	pop    %eax
c0108b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0108b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0108b7b:	25 00 02 00 00       	and    $0x200,%eax
c0108b80:	85 c0                	test   %eax,%eax
c0108b82:	74 0c                	je     c0108b90 <__intr_save+0x23>
        intr_disable();
c0108b84:	e8 5f 95 ff ff       	call   c01020e8 <intr_disable>
        return 1;
c0108b89:	b8 01 00 00 00       	mov    $0x1,%eax
c0108b8e:	eb 05                	jmp    c0108b95 <__intr_save+0x28>
    return 0;
c0108b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108b95:	c9                   	leave  
c0108b96:	c3                   	ret    

c0108b97 <__intr_restore>:
__intr_restore(bool flag) {
c0108b97:	55                   	push   %ebp
c0108b98:	89 e5                	mov    %esp,%ebp
c0108b9a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0108b9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108ba1:	74 05                	je     c0108ba8 <__intr_restore+0x11>
        intr_enable();
c0108ba3:	e8 39 95 ff ff       	call   c01020e1 <intr_enable>
}
c0108ba8:	90                   	nop
c0108ba9:	c9                   	leave  
c0108baa:	c3                   	ret    

c0108bab <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0108bab:	55                   	push   %ebp
c0108bac:	89 e5                	mov    %esp,%ebp
c0108bae:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0108bb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bb4:	8b 00                	mov    (%eax),%eax
c0108bb6:	83 f8 03             	cmp    $0x3,%eax
c0108bb9:	74 0a                	je     c0108bc5 <wakeup_proc+0x1a>
c0108bbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bbe:	8b 00                	mov    (%eax),%eax
c0108bc0:	83 f8 02             	cmp    $0x2,%eax
c0108bc3:	75 24                	jne    c0108be9 <wakeup_proc+0x3e>
c0108bc5:	c7 44 24 0c 4c b8 10 	movl   $0xc010b84c,0xc(%esp)
c0108bcc:	c0 
c0108bcd:	c7 44 24 08 87 b8 10 	movl   $0xc010b887,0x8(%esp)
c0108bd4:	c0 
c0108bd5:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c0108bdc:	00 
c0108bdd:	c7 04 24 9c b8 10 c0 	movl   $0xc010b89c,(%esp)
c0108be4:	e8 17 78 ff ff       	call   c0100400 <__panic>
    proc->state = PROC_RUNNABLE;
c0108be9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bec:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0108bf2:	90                   	nop
c0108bf3:	c9                   	leave  
c0108bf4:	c3                   	ret    

c0108bf5 <schedule>:

void
schedule(void) {
c0108bf5:	55                   	push   %ebp
c0108bf6:	89 e5                	mov    %esp,%ebp
c0108bf8:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c0108bfb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0108c02:	e8 66 ff ff ff       	call   c0108b6d <__intr_save>
c0108c07:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0108c0a:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108c0f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c0108c16:	8b 15 28 80 12 c0    	mov    0xc0128028,%edx
c0108c1c:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108c21:	39 c2                	cmp    %eax,%edx
c0108c23:	74 0a                	je     c0108c2f <schedule+0x3a>
c0108c25:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108c2a:	83 c0 58             	add    $0x58,%eax
c0108c2d:	eb 05                	jmp    c0108c34 <schedule+0x3f>
c0108c2f:	b8 5c a1 12 c0       	mov    $0xc012a15c,%eax
c0108c34:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c0108c37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0108c43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c46:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c0108c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108c4c:	81 7d f4 5c a1 12 c0 	cmpl   $0xc012a15c,-0xc(%ebp)
c0108c53:	74 13                	je     c0108c68 <schedule+0x73>
                next = le2proc(le, list_link);
c0108c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c58:	83 e8 58             	sub    $0x58,%eax
c0108c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0108c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c61:	8b 00                	mov    (%eax),%eax
c0108c63:	83 f8 02             	cmp    $0x2,%eax
c0108c66:	74 0a                	je     c0108c72 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c0108c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c6b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0108c6e:	75 cd                	jne    c0108c3d <schedule+0x48>
c0108c70:	eb 01                	jmp    c0108c73 <schedule+0x7e>
                    break;
c0108c72:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0108c73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108c77:	74 0a                	je     c0108c83 <schedule+0x8e>
c0108c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c7c:	8b 00                	mov    (%eax),%eax
c0108c7e:	83 f8 02             	cmp    $0x2,%eax
c0108c81:	74 08                	je     c0108c8b <schedule+0x96>
            next = idleproc;
c0108c83:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108c88:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0108c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c8e:	8b 40 08             	mov    0x8(%eax),%eax
c0108c91:	8d 50 01             	lea    0x1(%eax),%edx
c0108c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c97:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0108c9a:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108c9f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108ca2:	74 0b                	je     c0108caf <schedule+0xba>
            proc_run(next);
c0108ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ca7:	89 04 24             	mov    %eax,(%esp)
c0108caa:	e8 cf f8 ff ff       	call   c010857e <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c0108caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108cb2:	89 04 24             	mov    %eax,(%esp)
c0108cb5:	e8 dd fe ff ff       	call   c0108b97 <__intr_restore>
}
c0108cba:	90                   	nop
c0108cbb:	c9                   	leave  
c0108cbc:	c3                   	ret    

c0108cbd <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108cbd:	55                   	push   %ebp
c0108cbe:	89 e5                	mov    %esp,%ebp
c0108cc0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108cc3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0108cca:	eb 03                	jmp    c0108ccf <strlen+0x12>
        cnt ++;
c0108ccc:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0108ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cd2:	8d 50 01             	lea    0x1(%eax),%edx
c0108cd5:	89 55 08             	mov    %edx,0x8(%ebp)
c0108cd8:	0f b6 00             	movzbl (%eax),%eax
c0108cdb:	84 c0                	test   %al,%al
c0108cdd:	75 ed                	jne    c0108ccc <strlen+0xf>
    }
    return cnt;
c0108cdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108ce2:	c9                   	leave  
c0108ce3:	c3                   	ret    

c0108ce4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108ce4:	55                   	push   %ebp
c0108ce5:	89 e5                	mov    %esp,%ebp
c0108ce7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108cea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cf1:	eb 03                	jmp    c0108cf6 <strnlen+0x12>
        cnt ++;
c0108cf3:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108cf9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108cfc:	73 10                	jae    c0108d0e <strnlen+0x2a>
c0108cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d01:	8d 50 01             	lea    0x1(%eax),%edx
c0108d04:	89 55 08             	mov    %edx,0x8(%ebp)
c0108d07:	0f b6 00             	movzbl (%eax),%eax
c0108d0a:	84 c0                	test   %al,%al
c0108d0c:	75 e5                	jne    c0108cf3 <strnlen+0xf>
    }
    return cnt;
c0108d0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108d11:	c9                   	leave  
c0108d12:	c3                   	ret    

c0108d13 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108d13:	55                   	push   %ebp
c0108d14:	89 e5                	mov    %esp,%ebp
c0108d16:	57                   	push   %edi
c0108d17:	56                   	push   %esi
c0108d18:	83 ec 20             	sub    $0x20,%esp
c0108d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108d27:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d2d:	89 d1                	mov    %edx,%ecx
c0108d2f:	89 c2                	mov    %eax,%edx
c0108d31:	89 ce                	mov    %ecx,%esi
c0108d33:	89 d7                	mov    %edx,%edi
c0108d35:	ac                   	lods   %ds:(%esi),%al
c0108d36:	aa                   	stos   %al,%es:(%edi)
c0108d37:	84 c0                	test   %al,%al
c0108d39:	75 fa                	jne    c0108d35 <strcpy+0x22>
c0108d3b:	89 fa                	mov    %edi,%edx
c0108d3d:	89 f1                	mov    %esi,%ecx
c0108d3f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108d42:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108d45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0108d4b:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108d4c:	83 c4 20             	add    $0x20,%esp
c0108d4f:	5e                   	pop    %esi
c0108d50:	5f                   	pop    %edi
c0108d51:	5d                   	pop    %ebp
c0108d52:	c3                   	ret    

c0108d53 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108d53:	55                   	push   %ebp
c0108d54:	89 e5                	mov    %esp,%ebp
c0108d56:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108d5f:	eb 1e                	jmp    c0108d7f <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0108d61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d64:	0f b6 10             	movzbl (%eax),%edx
c0108d67:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d6a:	88 10                	mov    %dl,(%eax)
c0108d6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d6f:	0f b6 00             	movzbl (%eax),%eax
c0108d72:	84 c0                	test   %al,%al
c0108d74:	74 03                	je     c0108d79 <strncpy+0x26>
            src ++;
c0108d76:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108d79:	ff 45 fc             	incl   -0x4(%ebp)
c0108d7c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0108d7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d83:	75 dc                	jne    c0108d61 <strncpy+0xe>
    }
    return dst;
c0108d85:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108d88:	c9                   	leave  
c0108d89:	c3                   	ret    

c0108d8a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108d8a:	55                   	push   %ebp
c0108d8b:	89 e5                	mov    %esp,%ebp
c0108d8d:	57                   	push   %edi
c0108d8e:	56                   	push   %esi
c0108d8f:	83 ec 20             	sub    $0x20,%esp
c0108d92:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0108d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108da4:	89 d1                	mov    %edx,%ecx
c0108da6:	89 c2                	mov    %eax,%edx
c0108da8:	89 ce                	mov    %ecx,%esi
c0108daa:	89 d7                	mov    %edx,%edi
c0108dac:	ac                   	lods   %ds:(%esi),%al
c0108dad:	ae                   	scas   %es:(%edi),%al
c0108dae:	75 08                	jne    c0108db8 <strcmp+0x2e>
c0108db0:	84 c0                	test   %al,%al
c0108db2:	75 f8                	jne    c0108dac <strcmp+0x22>
c0108db4:	31 c0                	xor    %eax,%eax
c0108db6:	eb 04                	jmp    c0108dbc <strcmp+0x32>
c0108db8:	19 c0                	sbb    %eax,%eax
c0108dba:	0c 01                	or     $0x1,%al
c0108dbc:	89 fa                	mov    %edi,%edx
c0108dbe:	89 f1                	mov    %esi,%ecx
c0108dc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108dc3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108dc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0108dc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0108dcc:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108dcd:	83 c4 20             	add    $0x20,%esp
c0108dd0:	5e                   	pop    %esi
c0108dd1:	5f                   	pop    %edi
c0108dd2:	5d                   	pop    %ebp
c0108dd3:	c3                   	ret    

c0108dd4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108dd4:	55                   	push   %ebp
c0108dd5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108dd7:	eb 09                	jmp    c0108de2 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0108dd9:	ff 4d 10             	decl   0x10(%ebp)
c0108ddc:	ff 45 08             	incl   0x8(%ebp)
c0108ddf:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108de2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108de6:	74 1a                	je     c0108e02 <strncmp+0x2e>
c0108de8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108deb:	0f b6 00             	movzbl (%eax),%eax
c0108dee:	84 c0                	test   %al,%al
c0108df0:	74 10                	je     c0108e02 <strncmp+0x2e>
c0108df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108df5:	0f b6 10             	movzbl (%eax),%edx
c0108df8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dfb:	0f b6 00             	movzbl (%eax),%eax
c0108dfe:	38 c2                	cmp    %al,%dl
c0108e00:	74 d7                	je     c0108dd9 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108e02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108e06:	74 18                	je     c0108e20 <strncmp+0x4c>
c0108e08:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e0b:	0f b6 00             	movzbl (%eax),%eax
c0108e0e:	0f b6 d0             	movzbl %al,%edx
c0108e11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e14:	0f b6 00             	movzbl (%eax),%eax
c0108e17:	0f b6 c0             	movzbl %al,%eax
c0108e1a:	29 c2                	sub    %eax,%edx
c0108e1c:	89 d0                	mov    %edx,%eax
c0108e1e:	eb 05                	jmp    c0108e25 <strncmp+0x51>
c0108e20:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e25:	5d                   	pop    %ebp
c0108e26:	c3                   	ret    

c0108e27 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108e27:	55                   	push   %ebp
c0108e28:	89 e5                	mov    %esp,%ebp
c0108e2a:	83 ec 04             	sub    $0x4,%esp
c0108e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e30:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e33:	eb 13                	jmp    c0108e48 <strchr+0x21>
        if (*s == c) {
c0108e35:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e38:	0f b6 00             	movzbl (%eax),%eax
c0108e3b:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108e3e:	75 05                	jne    c0108e45 <strchr+0x1e>
            return (char *)s;
c0108e40:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e43:	eb 12                	jmp    c0108e57 <strchr+0x30>
        }
        s ++;
c0108e45:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108e48:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e4b:	0f b6 00             	movzbl (%eax),%eax
c0108e4e:	84 c0                	test   %al,%al
c0108e50:	75 e3                	jne    c0108e35 <strchr+0xe>
    }
    return NULL;
c0108e52:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e57:	c9                   	leave  
c0108e58:	c3                   	ret    

c0108e59 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108e59:	55                   	push   %ebp
c0108e5a:	89 e5                	mov    %esp,%ebp
c0108e5c:	83 ec 04             	sub    $0x4,%esp
c0108e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e62:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e65:	eb 0e                	jmp    c0108e75 <strfind+0x1c>
        if (*s == c) {
c0108e67:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e6a:	0f b6 00             	movzbl (%eax),%eax
c0108e6d:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108e70:	74 0f                	je     c0108e81 <strfind+0x28>
            break;
        }
        s ++;
c0108e72:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108e75:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e78:	0f b6 00             	movzbl (%eax),%eax
c0108e7b:	84 c0                	test   %al,%al
c0108e7d:	75 e8                	jne    c0108e67 <strfind+0xe>
c0108e7f:	eb 01                	jmp    c0108e82 <strfind+0x29>
            break;
c0108e81:	90                   	nop
    }
    return (char *)s;
c0108e82:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108e85:	c9                   	leave  
c0108e86:	c3                   	ret    

c0108e87 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108e87:	55                   	push   %ebp
c0108e88:	89 e5                	mov    %esp,%ebp
c0108e8a:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108e8d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108e94:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108e9b:	eb 03                	jmp    c0108ea0 <strtol+0x19>
        s ++;
c0108e9d:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0108ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea3:	0f b6 00             	movzbl (%eax),%eax
c0108ea6:	3c 20                	cmp    $0x20,%al
c0108ea8:	74 f3                	je     c0108e9d <strtol+0x16>
c0108eaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ead:	0f b6 00             	movzbl (%eax),%eax
c0108eb0:	3c 09                	cmp    $0x9,%al
c0108eb2:	74 e9                	je     c0108e9d <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0108eb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eb7:	0f b6 00             	movzbl (%eax),%eax
c0108eba:	3c 2b                	cmp    $0x2b,%al
c0108ebc:	75 05                	jne    c0108ec3 <strtol+0x3c>
        s ++;
c0108ebe:	ff 45 08             	incl   0x8(%ebp)
c0108ec1:	eb 14                	jmp    c0108ed7 <strtol+0x50>
    }
    else if (*s == '-') {
c0108ec3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ec6:	0f b6 00             	movzbl (%eax),%eax
c0108ec9:	3c 2d                	cmp    $0x2d,%al
c0108ecb:	75 0a                	jne    c0108ed7 <strtol+0x50>
        s ++, neg = 1;
c0108ecd:	ff 45 08             	incl   0x8(%ebp)
c0108ed0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108ed7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108edb:	74 06                	je     c0108ee3 <strtol+0x5c>
c0108edd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108ee1:	75 22                	jne    c0108f05 <strtol+0x7e>
c0108ee3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ee6:	0f b6 00             	movzbl (%eax),%eax
c0108ee9:	3c 30                	cmp    $0x30,%al
c0108eeb:	75 18                	jne    c0108f05 <strtol+0x7e>
c0108eed:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ef0:	40                   	inc    %eax
c0108ef1:	0f b6 00             	movzbl (%eax),%eax
c0108ef4:	3c 78                	cmp    $0x78,%al
c0108ef6:	75 0d                	jne    c0108f05 <strtol+0x7e>
        s += 2, base = 16;
c0108ef8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108efc:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108f03:	eb 29                	jmp    c0108f2e <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108f05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108f09:	75 16                	jne    c0108f21 <strtol+0x9a>
c0108f0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f0e:	0f b6 00             	movzbl (%eax),%eax
c0108f11:	3c 30                	cmp    $0x30,%al
c0108f13:	75 0c                	jne    c0108f21 <strtol+0x9a>
        s ++, base = 8;
c0108f15:	ff 45 08             	incl   0x8(%ebp)
c0108f18:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108f1f:	eb 0d                	jmp    c0108f2e <strtol+0xa7>
    }
    else if (base == 0) {
c0108f21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108f25:	75 07                	jne    c0108f2e <strtol+0xa7>
        base = 10;
c0108f27:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108f2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f31:	0f b6 00             	movzbl (%eax),%eax
c0108f34:	3c 2f                	cmp    $0x2f,%al
c0108f36:	7e 1b                	jle    c0108f53 <strtol+0xcc>
c0108f38:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f3b:	0f b6 00             	movzbl (%eax),%eax
c0108f3e:	3c 39                	cmp    $0x39,%al
c0108f40:	7f 11                	jg     c0108f53 <strtol+0xcc>
            dig = *s - '0';
c0108f42:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f45:	0f b6 00             	movzbl (%eax),%eax
c0108f48:	0f be c0             	movsbl %al,%eax
c0108f4b:	83 e8 30             	sub    $0x30,%eax
c0108f4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f51:	eb 48                	jmp    c0108f9b <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108f53:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f56:	0f b6 00             	movzbl (%eax),%eax
c0108f59:	3c 60                	cmp    $0x60,%al
c0108f5b:	7e 1b                	jle    c0108f78 <strtol+0xf1>
c0108f5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f60:	0f b6 00             	movzbl (%eax),%eax
c0108f63:	3c 7a                	cmp    $0x7a,%al
c0108f65:	7f 11                	jg     c0108f78 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108f67:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f6a:	0f b6 00             	movzbl (%eax),%eax
c0108f6d:	0f be c0             	movsbl %al,%eax
c0108f70:	83 e8 57             	sub    $0x57,%eax
c0108f73:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f76:	eb 23                	jmp    c0108f9b <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108f78:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f7b:	0f b6 00             	movzbl (%eax),%eax
c0108f7e:	3c 40                	cmp    $0x40,%al
c0108f80:	7e 3b                	jle    c0108fbd <strtol+0x136>
c0108f82:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f85:	0f b6 00             	movzbl (%eax),%eax
c0108f88:	3c 5a                	cmp    $0x5a,%al
c0108f8a:	7f 31                	jg     c0108fbd <strtol+0x136>
            dig = *s - 'A' + 10;
c0108f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f8f:	0f b6 00             	movzbl (%eax),%eax
c0108f92:	0f be c0             	movsbl %al,%eax
c0108f95:	83 e8 37             	sub    $0x37,%eax
c0108f98:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f9e:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108fa1:	7d 19                	jge    c0108fbc <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0108fa3:	ff 45 08             	incl   0x8(%ebp)
c0108fa6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108fa9:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108fad:	89 c2                	mov    %eax,%edx
c0108faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fb2:	01 d0                	add    %edx,%eax
c0108fb4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0108fb7:	e9 72 ff ff ff       	jmp    c0108f2e <strtol+0xa7>
            break;
c0108fbc:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108fbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108fc1:	74 08                	je     c0108fcb <strtol+0x144>
        *endptr = (char *) s;
c0108fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fc6:	8b 55 08             	mov    0x8(%ebp),%edx
c0108fc9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108fcb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108fcf:	74 07                	je     c0108fd8 <strtol+0x151>
c0108fd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108fd4:	f7 d8                	neg    %eax
c0108fd6:	eb 03                	jmp    c0108fdb <strtol+0x154>
c0108fd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108fdb:	c9                   	leave  
c0108fdc:	c3                   	ret    

c0108fdd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108fdd:	55                   	push   %ebp
c0108fde:	89 e5                	mov    %esp,%ebp
c0108fe0:	57                   	push   %edi
c0108fe1:	83 ec 24             	sub    $0x24,%esp
c0108fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fe7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108fea:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108fee:	8b 55 08             	mov    0x8(%ebp),%edx
c0108ff1:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108ff4:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108ff7:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ffa:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108ffd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109000:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0109004:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109007:	89 d7                	mov    %edx,%edi
c0109009:	f3 aa                	rep stos %al,%es:(%edi)
c010900b:	89 fa                	mov    %edi,%edx
c010900d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109010:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0109013:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109016:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109017:	83 c4 24             	add    $0x24,%esp
c010901a:	5f                   	pop    %edi
c010901b:	5d                   	pop    %ebp
c010901c:	c3                   	ret    

c010901d <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010901d:	55                   	push   %ebp
c010901e:	89 e5                	mov    %esp,%ebp
c0109020:	57                   	push   %edi
c0109021:	56                   	push   %esi
c0109022:	53                   	push   %ebx
c0109023:	83 ec 30             	sub    $0x30,%esp
c0109026:	8b 45 08             	mov    0x8(%ebp),%eax
c0109029:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010902c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010902f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109032:	8b 45 10             	mov    0x10(%ebp),%eax
c0109035:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109038:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010903b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010903e:	73 42                	jae    c0109082 <memmove+0x65>
c0109040:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109046:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109049:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010904c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010904f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109052:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109055:	c1 e8 02             	shr    $0x2,%eax
c0109058:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010905a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010905d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109060:	89 d7                	mov    %edx,%edi
c0109062:	89 c6                	mov    %eax,%esi
c0109064:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109066:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109069:	83 e1 03             	and    $0x3,%ecx
c010906c:	74 02                	je     c0109070 <memmove+0x53>
c010906e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109070:	89 f0                	mov    %esi,%eax
c0109072:	89 fa                	mov    %edi,%edx
c0109074:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109077:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010907a:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010907d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0109080:	eb 36                	jmp    c01090b8 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0109082:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109085:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109088:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010908b:	01 c2                	add    %eax,%edx
c010908d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109090:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0109093:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109096:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0109099:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010909c:	89 c1                	mov    %eax,%ecx
c010909e:	89 d8                	mov    %ebx,%eax
c01090a0:	89 d6                	mov    %edx,%esi
c01090a2:	89 c7                	mov    %eax,%edi
c01090a4:	fd                   	std    
c01090a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01090a7:	fc                   	cld    
c01090a8:	89 f8                	mov    %edi,%eax
c01090aa:	89 f2                	mov    %esi,%edx
c01090ac:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01090af:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01090b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01090b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01090b8:	83 c4 30             	add    $0x30,%esp
c01090bb:	5b                   	pop    %ebx
c01090bc:	5e                   	pop    %esi
c01090bd:	5f                   	pop    %edi
c01090be:	5d                   	pop    %ebp
c01090bf:	c3                   	ret    

c01090c0 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01090c0:	55                   	push   %ebp
c01090c1:	89 e5                	mov    %esp,%ebp
c01090c3:	57                   	push   %edi
c01090c4:	56                   	push   %esi
c01090c5:	83 ec 20             	sub    $0x20,%esp
c01090c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01090cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01090d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01090d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01090da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090dd:	c1 e8 02             	shr    $0x2,%eax
c01090e0:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01090e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090e8:	89 d7                	mov    %edx,%edi
c01090ea:	89 c6                	mov    %eax,%esi
c01090ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01090ee:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01090f1:	83 e1 03             	and    $0x3,%ecx
c01090f4:	74 02                	je     c01090f8 <memcpy+0x38>
c01090f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01090f8:	89 f0                	mov    %esi,%eax
c01090fa:	89 fa                	mov    %edi,%edx
c01090fc:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01090ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109102:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0109105:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0109108:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0109109:	83 c4 20             	add    $0x20,%esp
c010910c:	5e                   	pop    %esi
c010910d:	5f                   	pop    %edi
c010910e:	5d                   	pop    %ebp
c010910f:	c3                   	ret    

c0109110 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0109110:	55                   	push   %ebp
c0109111:	89 e5                	mov    %esp,%ebp
c0109113:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0109116:	8b 45 08             	mov    0x8(%ebp),%eax
c0109119:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010911c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010911f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0109122:	eb 2e                	jmp    c0109152 <memcmp+0x42>
        if (*s1 != *s2) {
c0109124:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109127:	0f b6 10             	movzbl (%eax),%edx
c010912a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010912d:	0f b6 00             	movzbl (%eax),%eax
c0109130:	38 c2                	cmp    %al,%dl
c0109132:	74 18                	je     c010914c <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109134:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109137:	0f b6 00             	movzbl (%eax),%eax
c010913a:	0f b6 d0             	movzbl %al,%edx
c010913d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109140:	0f b6 00             	movzbl (%eax),%eax
c0109143:	0f b6 c0             	movzbl %al,%eax
c0109146:	29 c2                	sub    %eax,%edx
c0109148:	89 d0                	mov    %edx,%eax
c010914a:	eb 18                	jmp    c0109164 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010914c:	ff 45 fc             	incl   -0x4(%ebp)
c010914f:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0109152:	8b 45 10             	mov    0x10(%ebp),%eax
c0109155:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109158:	89 55 10             	mov    %edx,0x10(%ebp)
c010915b:	85 c0                	test   %eax,%eax
c010915d:	75 c5                	jne    c0109124 <memcmp+0x14>
    }
    return 0;
c010915f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109164:	c9                   	leave  
c0109165:	c3                   	ret    

c0109166 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0109166:	55                   	push   %ebp
c0109167:	89 e5                	mov    %esp,%ebp
c0109169:	83 ec 58             	sub    $0x58,%esp
c010916c:	8b 45 10             	mov    0x10(%ebp),%eax
c010916f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0109172:	8b 45 14             	mov    0x14(%ebp),%eax
c0109175:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0109178:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010917b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010917e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109181:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0109184:	8b 45 18             	mov    0x18(%ebp),%eax
c0109187:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010918a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010918d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109190:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109193:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0109196:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109199:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010919c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01091a0:	74 1c                	je     c01091be <printnum+0x58>
c01091a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091a5:	ba 00 00 00 00       	mov    $0x0,%edx
c01091aa:	f7 75 e4             	divl   -0x1c(%ebp)
c01091ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01091b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091b3:	ba 00 00 00 00       	mov    $0x0,%edx
c01091b8:	f7 75 e4             	divl   -0x1c(%ebp)
c01091bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01091be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01091c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091c4:	f7 75 e4             	divl   -0x1c(%ebp)
c01091c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01091ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01091cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01091d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01091d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01091d6:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01091d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01091dc:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01091df:	8b 45 18             	mov    0x18(%ebp),%eax
c01091e2:	ba 00 00 00 00       	mov    $0x0,%edx
c01091e7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01091ea:	72 56                	jb     c0109242 <printnum+0xdc>
c01091ec:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01091ef:	77 05                	ja     c01091f6 <printnum+0x90>
c01091f1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01091f4:	72 4c                	jb     c0109242 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01091f6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01091f9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01091fc:	8b 45 20             	mov    0x20(%ebp),%eax
c01091ff:	89 44 24 18          	mov    %eax,0x18(%esp)
c0109203:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109207:	8b 45 18             	mov    0x18(%ebp),%eax
c010920a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010920e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109211:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109214:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109218:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010921c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010921f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109223:	8b 45 08             	mov    0x8(%ebp),%eax
c0109226:	89 04 24             	mov    %eax,(%esp)
c0109229:	e8 38 ff ff ff       	call   c0109166 <printnum>
c010922e:	eb 1b                	jmp    c010924b <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0109230:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109233:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109237:	8b 45 20             	mov    0x20(%ebp),%eax
c010923a:	89 04 24             	mov    %eax,(%esp)
c010923d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109240:	ff d0                	call   *%eax
        while (-- width > 0)
c0109242:	ff 4d 1c             	decl   0x1c(%ebp)
c0109245:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0109249:	7f e5                	jg     c0109230 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010924b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010924e:	05 34 b9 10 c0       	add    $0xc010b934,%eax
c0109253:	0f b6 00             	movzbl (%eax),%eax
c0109256:	0f be c0             	movsbl %al,%eax
c0109259:	8b 55 0c             	mov    0xc(%ebp),%edx
c010925c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109260:	89 04 24             	mov    %eax,(%esp)
c0109263:	8b 45 08             	mov    0x8(%ebp),%eax
c0109266:	ff d0                	call   *%eax
}
c0109268:	90                   	nop
c0109269:	c9                   	leave  
c010926a:	c3                   	ret    

c010926b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010926b:	55                   	push   %ebp
c010926c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010926e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109272:	7e 14                	jle    c0109288 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0109274:	8b 45 08             	mov    0x8(%ebp),%eax
c0109277:	8b 00                	mov    (%eax),%eax
c0109279:	8d 48 08             	lea    0x8(%eax),%ecx
c010927c:	8b 55 08             	mov    0x8(%ebp),%edx
c010927f:	89 0a                	mov    %ecx,(%edx)
c0109281:	8b 50 04             	mov    0x4(%eax),%edx
c0109284:	8b 00                	mov    (%eax),%eax
c0109286:	eb 30                	jmp    c01092b8 <getuint+0x4d>
    }
    else if (lflag) {
c0109288:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010928c:	74 16                	je     c01092a4 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010928e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109291:	8b 00                	mov    (%eax),%eax
c0109293:	8d 48 04             	lea    0x4(%eax),%ecx
c0109296:	8b 55 08             	mov    0x8(%ebp),%edx
c0109299:	89 0a                	mov    %ecx,(%edx)
c010929b:	8b 00                	mov    (%eax),%eax
c010929d:	ba 00 00 00 00       	mov    $0x0,%edx
c01092a2:	eb 14                	jmp    c01092b8 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01092a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01092a7:	8b 00                	mov    (%eax),%eax
c01092a9:	8d 48 04             	lea    0x4(%eax),%ecx
c01092ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01092af:	89 0a                	mov    %ecx,(%edx)
c01092b1:	8b 00                	mov    (%eax),%eax
c01092b3:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01092b8:	5d                   	pop    %ebp
c01092b9:	c3                   	ret    

c01092ba <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01092ba:	55                   	push   %ebp
c01092bb:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01092bd:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01092c1:	7e 14                	jle    c01092d7 <getint+0x1d>
        return va_arg(*ap, long long);
c01092c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01092c6:	8b 00                	mov    (%eax),%eax
c01092c8:	8d 48 08             	lea    0x8(%eax),%ecx
c01092cb:	8b 55 08             	mov    0x8(%ebp),%edx
c01092ce:	89 0a                	mov    %ecx,(%edx)
c01092d0:	8b 50 04             	mov    0x4(%eax),%edx
c01092d3:	8b 00                	mov    (%eax),%eax
c01092d5:	eb 28                	jmp    c01092ff <getint+0x45>
    }
    else if (lflag) {
c01092d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01092db:	74 12                	je     c01092ef <getint+0x35>
        return va_arg(*ap, long);
c01092dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e0:	8b 00                	mov    (%eax),%eax
c01092e2:	8d 48 04             	lea    0x4(%eax),%ecx
c01092e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01092e8:	89 0a                	mov    %ecx,(%edx)
c01092ea:	8b 00                	mov    (%eax),%eax
c01092ec:	99                   	cltd   
c01092ed:	eb 10                	jmp    c01092ff <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01092ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01092f2:	8b 00                	mov    (%eax),%eax
c01092f4:	8d 48 04             	lea    0x4(%eax),%ecx
c01092f7:	8b 55 08             	mov    0x8(%ebp),%edx
c01092fa:	89 0a                	mov    %ecx,(%edx)
c01092fc:	8b 00                	mov    (%eax),%eax
c01092fe:	99                   	cltd   
    }
}
c01092ff:	5d                   	pop    %ebp
c0109300:	c3                   	ret    

c0109301 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0109301:	55                   	push   %ebp
c0109302:	89 e5                	mov    %esp,%ebp
c0109304:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0109307:	8d 45 14             	lea    0x14(%ebp),%eax
c010930a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010930d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109310:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109314:	8b 45 10             	mov    0x10(%ebp),%eax
c0109317:	89 44 24 08          	mov    %eax,0x8(%esp)
c010931b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010931e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109322:	8b 45 08             	mov    0x8(%ebp),%eax
c0109325:	89 04 24             	mov    %eax,(%esp)
c0109328:	e8 03 00 00 00       	call   c0109330 <vprintfmt>
    va_end(ap);
}
c010932d:	90                   	nop
c010932e:	c9                   	leave  
c010932f:	c3                   	ret    

c0109330 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0109330:	55                   	push   %ebp
c0109331:	89 e5                	mov    %esp,%ebp
c0109333:	56                   	push   %esi
c0109334:	53                   	push   %ebx
c0109335:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109338:	eb 17                	jmp    c0109351 <vprintfmt+0x21>
            if (ch == '\0') {
c010933a:	85 db                	test   %ebx,%ebx
c010933c:	0f 84 bf 03 00 00    	je     c0109701 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0109342:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109345:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109349:	89 1c 24             	mov    %ebx,(%esp)
c010934c:	8b 45 08             	mov    0x8(%ebp),%eax
c010934f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109351:	8b 45 10             	mov    0x10(%ebp),%eax
c0109354:	8d 50 01             	lea    0x1(%eax),%edx
c0109357:	89 55 10             	mov    %edx,0x10(%ebp)
c010935a:	0f b6 00             	movzbl (%eax),%eax
c010935d:	0f b6 d8             	movzbl %al,%ebx
c0109360:	83 fb 25             	cmp    $0x25,%ebx
c0109363:	75 d5                	jne    c010933a <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0109365:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0109369:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0109370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109373:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0109376:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010937d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109380:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0109383:	8b 45 10             	mov    0x10(%ebp),%eax
c0109386:	8d 50 01             	lea    0x1(%eax),%edx
c0109389:	89 55 10             	mov    %edx,0x10(%ebp)
c010938c:	0f b6 00             	movzbl (%eax),%eax
c010938f:	0f b6 d8             	movzbl %al,%ebx
c0109392:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0109395:	83 f8 55             	cmp    $0x55,%eax
c0109398:	0f 87 37 03 00 00    	ja     c01096d5 <vprintfmt+0x3a5>
c010939e:	8b 04 85 58 b9 10 c0 	mov    -0x3fef46a8(,%eax,4),%eax
c01093a5:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01093a7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01093ab:	eb d6                	jmp    c0109383 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01093ad:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01093b1:	eb d0                	jmp    c0109383 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01093b3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01093ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01093bd:	89 d0                	mov    %edx,%eax
c01093bf:	c1 e0 02             	shl    $0x2,%eax
c01093c2:	01 d0                	add    %edx,%eax
c01093c4:	01 c0                	add    %eax,%eax
c01093c6:	01 d8                	add    %ebx,%eax
c01093c8:	83 e8 30             	sub    $0x30,%eax
c01093cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01093ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01093d1:	0f b6 00             	movzbl (%eax),%eax
c01093d4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01093d7:	83 fb 2f             	cmp    $0x2f,%ebx
c01093da:	7e 38                	jle    c0109414 <vprintfmt+0xe4>
c01093dc:	83 fb 39             	cmp    $0x39,%ebx
c01093df:	7f 33                	jg     c0109414 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01093e1:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01093e4:	eb d4                	jmp    c01093ba <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01093e6:	8b 45 14             	mov    0x14(%ebp),%eax
c01093e9:	8d 50 04             	lea    0x4(%eax),%edx
c01093ec:	89 55 14             	mov    %edx,0x14(%ebp)
c01093ef:	8b 00                	mov    (%eax),%eax
c01093f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01093f4:	eb 1f                	jmp    c0109415 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01093f6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01093fa:	79 87                	jns    c0109383 <vprintfmt+0x53>
                width = 0;
c01093fc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0109403:	e9 7b ff ff ff       	jmp    c0109383 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0109408:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010940f:	e9 6f ff ff ff       	jmp    c0109383 <vprintfmt+0x53>
            goto process_precision;
c0109414:	90                   	nop

        process_precision:
            if (width < 0)
c0109415:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109419:	0f 89 64 ff ff ff    	jns    c0109383 <vprintfmt+0x53>
                width = precision, precision = -1;
c010941f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109422:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109425:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010942c:	e9 52 ff ff ff       	jmp    c0109383 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0109431:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0109434:	e9 4a ff ff ff       	jmp    c0109383 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0109439:	8b 45 14             	mov    0x14(%ebp),%eax
c010943c:	8d 50 04             	lea    0x4(%eax),%edx
c010943f:	89 55 14             	mov    %edx,0x14(%ebp)
c0109442:	8b 00                	mov    (%eax),%eax
c0109444:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109447:	89 54 24 04          	mov    %edx,0x4(%esp)
c010944b:	89 04 24             	mov    %eax,(%esp)
c010944e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109451:	ff d0                	call   *%eax
            break;
c0109453:	e9 a4 02 00 00       	jmp    c01096fc <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0109458:	8b 45 14             	mov    0x14(%ebp),%eax
c010945b:	8d 50 04             	lea    0x4(%eax),%edx
c010945e:	89 55 14             	mov    %edx,0x14(%ebp)
c0109461:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0109463:	85 db                	test   %ebx,%ebx
c0109465:	79 02                	jns    c0109469 <vprintfmt+0x139>
                err = -err;
c0109467:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0109469:	83 fb 06             	cmp    $0x6,%ebx
c010946c:	7f 0b                	jg     c0109479 <vprintfmt+0x149>
c010946e:	8b 34 9d 18 b9 10 c0 	mov    -0x3fef46e8(,%ebx,4),%esi
c0109475:	85 f6                	test   %esi,%esi
c0109477:	75 23                	jne    c010949c <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0109479:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010947d:	c7 44 24 08 45 b9 10 	movl   $0xc010b945,0x8(%esp)
c0109484:	c0 
c0109485:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109488:	89 44 24 04          	mov    %eax,0x4(%esp)
c010948c:	8b 45 08             	mov    0x8(%ebp),%eax
c010948f:	89 04 24             	mov    %eax,(%esp)
c0109492:	e8 6a fe ff ff       	call   c0109301 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0109497:	e9 60 02 00 00       	jmp    c01096fc <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010949c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01094a0:	c7 44 24 08 4e b9 10 	movl   $0xc010b94e,0x8(%esp)
c01094a7:	c0 
c01094a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094af:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b2:	89 04 24             	mov    %eax,(%esp)
c01094b5:	e8 47 fe ff ff       	call   c0109301 <printfmt>
            break;
c01094ba:	e9 3d 02 00 00       	jmp    c01096fc <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01094bf:	8b 45 14             	mov    0x14(%ebp),%eax
c01094c2:	8d 50 04             	lea    0x4(%eax),%edx
c01094c5:	89 55 14             	mov    %edx,0x14(%ebp)
c01094c8:	8b 30                	mov    (%eax),%esi
c01094ca:	85 f6                	test   %esi,%esi
c01094cc:	75 05                	jne    c01094d3 <vprintfmt+0x1a3>
                p = "(null)";
c01094ce:	be 51 b9 10 c0       	mov    $0xc010b951,%esi
            }
            if (width > 0 && padc != '-') {
c01094d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01094d7:	7e 76                	jle    c010954f <vprintfmt+0x21f>
c01094d9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01094dd:	74 70                	je     c010954f <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01094df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01094e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094e6:	89 34 24             	mov    %esi,(%esp)
c01094e9:	e8 f6 f7 ff ff       	call   c0108ce4 <strnlen>
c01094ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01094f1:	29 c2                	sub    %eax,%edx
c01094f3:	89 d0                	mov    %edx,%eax
c01094f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01094f8:	eb 16                	jmp    c0109510 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01094fa:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01094fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109501:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109505:	89 04 24             	mov    %eax,(%esp)
c0109508:	8b 45 08             	mov    0x8(%ebp),%eax
c010950b:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010950d:	ff 4d e8             	decl   -0x18(%ebp)
c0109510:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109514:	7f e4                	jg     c01094fa <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109516:	eb 37                	jmp    c010954f <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109518:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010951c:	74 1f                	je     c010953d <vprintfmt+0x20d>
c010951e:	83 fb 1f             	cmp    $0x1f,%ebx
c0109521:	7e 05                	jle    c0109528 <vprintfmt+0x1f8>
c0109523:	83 fb 7e             	cmp    $0x7e,%ebx
c0109526:	7e 15                	jle    c010953d <vprintfmt+0x20d>
                    putch('?', putdat);
c0109528:	8b 45 0c             	mov    0xc(%ebp),%eax
c010952b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010952f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0109536:	8b 45 08             	mov    0x8(%ebp),%eax
c0109539:	ff d0                	call   *%eax
c010953b:	eb 0f                	jmp    c010954c <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010953d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109540:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109544:	89 1c 24             	mov    %ebx,(%esp)
c0109547:	8b 45 08             	mov    0x8(%ebp),%eax
c010954a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010954c:	ff 4d e8             	decl   -0x18(%ebp)
c010954f:	89 f0                	mov    %esi,%eax
c0109551:	8d 70 01             	lea    0x1(%eax),%esi
c0109554:	0f b6 00             	movzbl (%eax),%eax
c0109557:	0f be d8             	movsbl %al,%ebx
c010955a:	85 db                	test   %ebx,%ebx
c010955c:	74 27                	je     c0109585 <vprintfmt+0x255>
c010955e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109562:	78 b4                	js     c0109518 <vprintfmt+0x1e8>
c0109564:	ff 4d e4             	decl   -0x1c(%ebp)
c0109567:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010956b:	79 ab                	jns    c0109518 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c010956d:	eb 16                	jmp    c0109585 <vprintfmt+0x255>
                putch(' ', putdat);
c010956f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109572:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109576:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010957d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109580:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0109582:	ff 4d e8             	decl   -0x18(%ebp)
c0109585:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109589:	7f e4                	jg     c010956f <vprintfmt+0x23f>
            }
            break;
c010958b:	e9 6c 01 00 00       	jmp    c01096fc <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0109590:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109593:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109597:	8d 45 14             	lea    0x14(%ebp),%eax
c010959a:	89 04 24             	mov    %eax,(%esp)
c010959d:	e8 18 fd ff ff       	call   c01092ba <getint>
c01095a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01095a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01095a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01095ae:	85 d2                	test   %edx,%edx
c01095b0:	79 26                	jns    c01095d8 <vprintfmt+0x2a8>
                putch('-', putdat);
c01095b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01095b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01095c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01095c3:	ff d0                	call   *%eax
                num = -(long long)num;
c01095c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01095cb:	f7 d8                	neg    %eax
c01095cd:	83 d2 00             	adc    $0x0,%edx
c01095d0:	f7 da                	neg    %edx
c01095d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01095d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01095d8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01095df:	e9 a8 00 00 00       	jmp    c010968c <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01095e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01095e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01095eb:	8d 45 14             	lea    0x14(%ebp),%eax
c01095ee:	89 04 24             	mov    %eax,(%esp)
c01095f1:	e8 75 fc ff ff       	call   c010926b <getuint>
c01095f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01095f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01095fc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109603:	e9 84 00 00 00       	jmp    c010968c <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109608:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010960b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010960f:	8d 45 14             	lea    0x14(%ebp),%eax
c0109612:	89 04 24             	mov    %eax,(%esp)
c0109615:	e8 51 fc ff ff       	call   c010926b <getuint>
c010961a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010961d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0109620:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0109627:	eb 63                	jmp    c010968c <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0109629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010962c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109630:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0109637:	8b 45 08             	mov    0x8(%ebp),%eax
c010963a:	ff d0                	call   *%eax
            putch('x', putdat);
c010963c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010963f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109643:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010964a:	8b 45 08             	mov    0x8(%ebp),%eax
c010964d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010964f:	8b 45 14             	mov    0x14(%ebp),%eax
c0109652:	8d 50 04             	lea    0x4(%eax),%edx
c0109655:	89 55 14             	mov    %edx,0x14(%ebp)
c0109658:	8b 00                	mov    (%eax),%eax
c010965a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010965d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0109664:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010966b:	eb 1f                	jmp    c010968c <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010966d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109670:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109674:	8d 45 14             	lea    0x14(%ebp),%eax
c0109677:	89 04 24             	mov    %eax,(%esp)
c010967a:	e8 ec fb ff ff       	call   c010926b <getuint>
c010967f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109682:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109685:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010968c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0109690:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109693:	89 54 24 18          	mov    %edx,0x18(%esp)
c0109697:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010969a:	89 54 24 14          	mov    %edx,0x14(%esp)
c010969e:	89 44 24 10          	mov    %eax,0x10(%esp)
c01096a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01096a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01096a8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01096ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01096b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01096ba:	89 04 24             	mov    %eax,(%esp)
c01096bd:	e8 a4 fa ff ff       	call   c0109166 <printnum>
            break;
c01096c2:	eb 38                	jmp    c01096fc <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01096c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096cb:	89 1c 24             	mov    %ebx,(%esp)
c01096ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01096d1:	ff d0                	call   *%eax
            break;
c01096d3:	eb 27                	jmp    c01096fc <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01096d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01096e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01096e6:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01096e8:	ff 4d 10             	decl   0x10(%ebp)
c01096eb:	eb 03                	jmp    c01096f0 <vprintfmt+0x3c0>
c01096ed:	ff 4d 10             	decl   0x10(%ebp)
c01096f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01096f3:	48                   	dec    %eax
c01096f4:	0f b6 00             	movzbl (%eax),%eax
c01096f7:	3c 25                	cmp    $0x25,%al
c01096f9:	75 f2                	jne    c01096ed <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c01096fb:	90                   	nop
    while (1) {
c01096fc:	e9 37 fc ff ff       	jmp    c0109338 <vprintfmt+0x8>
                return;
c0109701:	90                   	nop
        }
    }
}
c0109702:	83 c4 40             	add    $0x40,%esp
c0109705:	5b                   	pop    %ebx
c0109706:	5e                   	pop    %esi
c0109707:	5d                   	pop    %ebp
c0109708:	c3                   	ret    

c0109709 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109709:	55                   	push   %ebp
c010970a:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010970c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010970f:	8b 40 08             	mov    0x8(%eax),%eax
c0109712:	8d 50 01             	lea    0x1(%eax),%edx
c0109715:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109718:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010971b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010971e:	8b 10                	mov    (%eax),%edx
c0109720:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109723:	8b 40 04             	mov    0x4(%eax),%eax
c0109726:	39 c2                	cmp    %eax,%edx
c0109728:	73 12                	jae    c010973c <sprintputch+0x33>
        *b->buf ++ = ch;
c010972a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010972d:	8b 00                	mov    (%eax),%eax
c010972f:	8d 48 01             	lea    0x1(%eax),%ecx
c0109732:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109735:	89 0a                	mov    %ecx,(%edx)
c0109737:	8b 55 08             	mov    0x8(%ebp),%edx
c010973a:	88 10                	mov    %dl,(%eax)
    }
}
c010973c:	90                   	nop
c010973d:	5d                   	pop    %ebp
c010973e:	c3                   	ret    

c010973f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010973f:	55                   	push   %ebp
c0109740:	89 e5                	mov    %esp,%ebp
c0109742:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109745:	8d 45 14             	lea    0x14(%ebp),%eax
c0109748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010974b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010974e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109752:	8b 45 10             	mov    0x10(%ebp),%eax
c0109755:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109759:	8b 45 0c             	mov    0xc(%ebp),%eax
c010975c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109760:	8b 45 08             	mov    0x8(%ebp),%eax
c0109763:	89 04 24             	mov    %eax,(%esp)
c0109766:	e8 08 00 00 00       	call   c0109773 <vsnprintf>
c010976b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010976e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109771:	c9                   	leave  
c0109772:	c3                   	ret    

c0109773 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109773:	55                   	push   %ebp
c0109774:	89 e5                	mov    %esp,%ebp
c0109776:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109779:	8b 45 08             	mov    0x8(%ebp),%eax
c010977c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010977f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109782:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109785:	8b 45 08             	mov    0x8(%ebp),%eax
c0109788:	01 d0                	add    %edx,%eax
c010978a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010978d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109794:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109798:	74 0a                	je     c01097a4 <vsnprintf+0x31>
c010979a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010979d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01097a0:	39 c2                	cmp    %eax,%edx
c01097a2:	76 07                	jbe    c01097ab <vsnprintf+0x38>
        return -E_INVAL;
c01097a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01097a9:	eb 2a                	jmp    c01097d5 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01097ab:	8b 45 14             	mov    0x14(%ebp),%eax
c01097ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01097b2:	8b 45 10             	mov    0x10(%ebp),%eax
c01097b5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01097b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01097bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097c0:	c7 04 24 09 97 10 c0 	movl   $0xc0109709,(%esp)
c01097c7:	e8 64 fb ff ff       	call   c0109330 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01097cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097cf:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01097d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01097d5:	c9                   	leave  
c01097d6:	c3                   	ret    

c01097d7 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c01097d7:	55                   	push   %ebp
c01097d8:	89 e5                	mov    %esp,%ebp
c01097da:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c01097dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e0:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c01097e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c01097e9:	b8 20 00 00 00       	mov    $0x20,%eax
c01097ee:	2b 45 0c             	sub    0xc(%ebp),%eax
c01097f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01097f4:	88 c1                	mov    %al,%cl
c01097f6:	d3 ea                	shr    %cl,%edx
c01097f8:	89 d0                	mov    %edx,%eax
}
c01097fa:	c9                   	leave  
c01097fb:	c3                   	ret    

c01097fc <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c01097fc:	55                   	push   %ebp
c01097fd:	89 e5                	mov    %esp,%ebp
c01097ff:	57                   	push   %edi
c0109800:	56                   	push   %esi
c0109801:	53                   	push   %ebx
c0109802:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109805:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c010980a:	8b 15 84 4a 12 c0    	mov    0xc0124a84,%edx
c0109810:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109816:	6b f0 05             	imul   $0x5,%eax,%esi
c0109819:	01 fe                	add    %edi,%esi
c010981b:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109820:	f7 e7                	mul    %edi
c0109822:	01 d6                	add    %edx,%esi
c0109824:	89 f2                	mov    %esi,%edx
c0109826:	83 c0 0b             	add    $0xb,%eax
c0109829:	83 d2 00             	adc    $0x0,%edx
c010982c:	89 c7                	mov    %eax,%edi
c010982e:	83 e7 ff             	and    $0xffffffff,%edi
c0109831:	89 f9                	mov    %edi,%ecx
c0109833:	0f b7 da             	movzwl %dx,%ebx
c0109836:	89 0d 80 4a 12 c0    	mov    %ecx,0xc0124a80
c010983c:	89 1d 84 4a 12 c0    	mov    %ebx,0xc0124a84
    unsigned long long result = (next >> 12);
c0109842:	8b 1d 80 4a 12 c0    	mov    0xc0124a80,%ebx
c0109848:	8b 35 84 4a 12 c0    	mov    0xc0124a84,%esi
c010984e:	89 d8                	mov    %ebx,%eax
c0109850:	89 f2                	mov    %esi,%edx
c0109852:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109856:	c1 ea 0c             	shr    $0xc,%edx
c0109859:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010985c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010985f:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109866:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109869:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010986c:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010986f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109872:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109875:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109878:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010987c:	74 1c                	je     c010989a <rand+0x9e>
c010987e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109881:	ba 00 00 00 00       	mov    $0x0,%edx
c0109886:	f7 75 dc             	divl   -0x24(%ebp)
c0109889:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010988c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010988f:	ba 00 00 00 00       	mov    $0x0,%edx
c0109894:	f7 75 dc             	divl   -0x24(%ebp)
c0109897:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010989a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010989d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01098a0:	f7 75 dc             	divl   -0x24(%ebp)
c01098a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01098a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01098a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01098ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01098af:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01098b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01098b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c01098b8:	83 c4 24             	add    $0x24,%esp
c01098bb:	5b                   	pop    %ebx
c01098bc:	5e                   	pop    %esi
c01098bd:	5f                   	pop    %edi
c01098be:	5d                   	pop    %ebp
c01098bf:	c3                   	ret    

c01098c0 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c01098c0:	55                   	push   %ebp
c01098c1:	89 e5                	mov    %esp,%ebp
    next = seed;
c01098c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01098c6:	ba 00 00 00 00       	mov    $0x0,%edx
c01098cb:	a3 80 4a 12 c0       	mov    %eax,0xc0124a80
c01098d0:	89 15 84 4a 12 c0    	mov    %edx,0xc0124a84
}
c01098d6:	90                   	nop
c01098d7:	5d                   	pop    %ebp
c01098d8:	c3                   	ret    
