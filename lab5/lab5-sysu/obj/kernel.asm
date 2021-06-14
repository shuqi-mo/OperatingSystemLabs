
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 d0 19 00       	mov    $0x19d000,%eax
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
c0100020:	a3 00 d0 19 c0       	mov    %eax,0xc019d000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 b0 12 c0       	mov    $0xc012b000,%esp
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
c010003c:	ba 64 21 1a c0       	mov    $0xc01a2164,%edx
c0100041:	b8 00 f0 19 c0       	mov    $0xc019f000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 f0 19 c0 	movl   $0xc019f000,(%esp)
c010005d:	e8 db b6 00 00       	call   c010b73d <memset>

    cons_init();                // init the console
c0100062:	e8 d3 1e 00 00       	call   c0101f3a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 40 c0 10 c0 	movl   $0xc010c040,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 5c c0 10 c0 	movl   $0xc010c05c,(%esp)
c010007c:	e8 28 02 00 00       	call   c01002a9 <cprintf>

    print_kerninfo();
c0100081:	e8 c1 09 00 00       	call   c0100a47 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a0 00 00 00       	call   c010012b <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 60 7c 00 00       	call   c0107cf0 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 0a 20 00 00       	call   c010209f <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 6a 21 00 00       	call   c0102204 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 70 3c 00 00       	call   c0103d0f <vmm_init>
    proc_init();                // init process table
c010009f:	e8 1c ae 00 00       	call   c010aec0 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 49 0e 00 00       	call   c0100ef2 <ide_init>
    swap_init();                // init swap
c01000a9:	e8 96 55 00 00       	call   c0105644 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 2a 16 00 00       	call   c01016dd <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 21 21 00 00       	call   c01021d9 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 c0 af 00 00       	call   c010b07d <cpu_idle>

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
c01000da:	e8 a8 0d 00 00       	call   c0100e87 <mon_backtrace>
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
c010016c:	a1 00 f0 19 c0       	mov    0xc019f000,%eax
c0100171:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100175:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100179:	c7 04 24 61 c0 10 c0 	movl   $0xc010c061,(%esp)
c0100180:	e8 24 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100185:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100189:	89 c2                	mov    %eax,%edx
c010018b:	a1 00 f0 19 c0       	mov    0xc019f000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 6f c0 10 c0 	movl   $0xc010c06f,(%esp)
c010019f:	e8 05 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	89 c2                	mov    %eax,%edx
c01001aa:	a1 00 f0 19 c0       	mov    0xc019f000,%eax
c01001af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b7:	c7 04 24 7d c0 10 c0 	movl   $0xc010c07d,(%esp)
c01001be:	e8 e6 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c7:	89 c2                	mov    %eax,%edx
c01001c9:	a1 00 f0 19 c0       	mov    0xc019f000,%eax
c01001ce:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d6:	c7 04 24 8b c0 10 c0 	movl   $0xc010c08b,(%esp)
c01001dd:	e8 c7 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e6:	89 c2                	mov    %eax,%edx
c01001e8:	a1 00 f0 19 c0       	mov    0xc019f000,%eax
c01001ed:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f5:	c7 04 24 99 c0 10 c0 	movl   $0xc010c099,(%esp)
c01001fc:	e8 a8 00 00 00       	call   c01002a9 <cprintf>
    round ++;
c0100201:	a1 00 f0 19 c0       	mov    0xc019f000,%eax
c0100206:	40                   	inc    %eax
c0100207:	a3 00 f0 19 c0       	mov    %eax,0xc019f000
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
c0100226:	c7 04 24 a8 c0 10 c0 	movl   $0xc010c0a8,(%esp)
c010022d:	e8 77 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_user();
c0100232:	e8 d8 ff ff ff       	call   c010020f <lab1_switch_to_user>
    lab1_print_cur_status();
c0100237:	e8 15 ff ff ff       	call   c0100151 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023c:	c7 04 24 c8 c0 10 c0 	movl   $0xc010c0c8,(%esp)
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
c0100261:	e8 01 1d 00 00       	call   c0101f67 <cons_putc>
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
c010029f:	e8 ec b7 00 00       	call   c010ba90 <vprintfmt>
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
c01002db:	e8 87 1c 00 00       	call   c0101f67 <cons_putc>
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
c0100338:	e8 67 1c 00 00       	call   c0101fa4 <cons_getc>
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
c010035e:	c7 04 24 e7 c0 10 c0 	movl   $0xc010c0e7,(%esp)
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
c01003ac:	88 90 20 f0 19 c0    	mov    %dl,-0x3fe60fe0(%eax)
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
c01003ea:	05 20 f0 19 c0       	add    $0xc019f020,%eax
c01003ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f2:	b8 20 f0 19 c0       	mov    $0xc019f020,%eax
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
c0100406:	a1 20 f4 19 c0       	mov    0xc019f420,%eax
c010040b:	85 c0                	test   %eax,%eax
c010040d:	75 5b                	jne    c010046a <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c010040f:	c7 05 20 f4 19 c0 01 	movl   $0x1,0xc019f420
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
c010042d:	c7 04 24 ea c0 10 c0 	movl   $0xc010c0ea,(%esp)
c0100434:	e8 70 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c0100439:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010043c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100440:	8b 45 10             	mov    0x10(%ebp),%eax
c0100443:	89 04 24             	mov    %eax,(%esp)
c0100446:	e8 2b fe ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c010044b:	c7 04 24 06 c1 10 c0 	movl   $0xc010c106,(%esp)
c0100452:	e8 52 fe ff ff       	call   c01002a9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100457:	c7 04 24 08 c1 10 c0 	movl   $0xc010c108,(%esp)
c010045e:	e8 46 fe ff ff       	call   c01002a9 <cprintf>
    print_stackframe();
c0100463:	e8 2a 07 00 00       	call   c0100b92 <print_stackframe>
c0100468:	eb 01                	jmp    c010046b <__panic+0x6b>
        goto panic_dead;
c010046a:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046b:	e8 70 1d 00 00       	call   c01021e0 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100477:	e8 3e 09 00 00       	call   c0100dba <kmonitor>
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
c0100498:	c7 04 24 1a c1 10 c0 	movl   $0xc010c11a,(%esp)
c010049f:	e8 05 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c01004a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ae:	89 04 24             	mov    %eax,(%esp)
c01004b1:	e8 c0 fd ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c01004b6:	c7 04 24 06 c1 10 c0 	movl   $0xc010c106,(%esp)
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
c01004c8:	a1 20 f4 19 c0       	mov    0xc019f420,%eax
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
c0100626:	c7 00 38 c1 10 c0    	movl   $0xc010c138,(%eax)
    info->eip_line = 0;
c010062c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100639:	c7 40 08 38 c1 10 c0 	movl   $0xc010c138,0x8(%eax)
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

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c010065d:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c0100664:	76 21                	jbe    c0100687 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c0100666:	c7 45 f4 60 e8 10 c0 	movl   $0xc010e860,-0xc(%ebp)
        stab_end = __STAB_END__;
c010066d:	c7 45 f0 68 39 12 c0 	movl   $0xc0123968,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c0100674:	c7 45 ec 69 39 12 c0 	movl   $0xc0123969,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c010067b:	c7 45 e8 70 87 12 c0 	movl   $0xc0128770,-0x18(%ebp)
c0100682:	e9 ea 00 00 00       	jmp    c0100771 <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c0100687:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c010068e:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0100693:	85 c0                	test   %eax,%eax
c0100695:	74 11                	je     c01006a8 <debuginfo_eip+0x8b>
c0100697:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010069c:	8b 40 18             	mov    0x18(%eax),%eax
c010069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01006a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01006a6:	75 0a                	jne    c01006b2 <debuginfo_eip+0x95>
            return -1;
c01006a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006ad:	e9 93 03 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01006b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01006bc:	00 
c01006bd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01006c4:	00 
c01006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006cc:	89 04 24             	mov    %eax,(%esp)
c01006cf:	e8 5b 3f 00 00       	call   c010462f <user_mem_check>
c01006d4:	85 c0                	test   %eax,%eax
c01006d6:	75 0a                	jne    c01006e2 <debuginfo_eip+0xc5>
            return -1;
c01006d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006dd:	e9 63 03 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>
        }

        stabs = usd->stabs;
c01006e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e5:	8b 00                	mov    (%eax),%eax
c01006e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c01006ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ed:	8b 40 04             	mov    0x4(%eax),%eax
c01006f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c01006f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f6:	8b 40 08             	mov    0x8(%eax),%eax
c01006f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c01006fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ff:	8b 40 0c             	mov    0xc(%eax),%eax
c0100702:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100705:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100708:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010070b:	29 c2                	sub    %eax,%edx
c010070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100710:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100717:	00 
c0100718:	89 54 24 08          	mov    %edx,0x8(%esp)
c010071c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100720:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100723:	89 04 24             	mov    %eax,(%esp)
c0100726:	e8 04 3f 00 00       	call   c010462f <user_mem_check>
c010072b:	85 c0                	test   %eax,%eax
c010072d:	75 0a                	jne    c0100739 <debuginfo_eip+0x11c>
            return -1;
c010072f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100734:	e9 0c 03 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100739:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010073f:	29 c2                	sub    %eax,%edx
c0100741:	89 d0                	mov    %edx,%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100748:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010074f:	00 
c0100750:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100754:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100758:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010075b:	89 04 24             	mov    %eax,(%esp)
c010075e:	e8 cc 3e 00 00       	call   c010462f <user_mem_check>
c0100763:	85 c0                	test   %eax,%eax
c0100765:	75 0a                	jne    c0100771 <debuginfo_eip+0x154>
            return -1;
c0100767:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010076c:	e9 d4 02 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100771:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100774:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100777:	76 0b                	jbe    c0100784 <debuginfo_eip+0x167>
c0100779:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010077c:	48                   	dec    %eax
c010077d:	0f b6 00             	movzbl (%eax),%eax
c0100780:	84 c0                	test   %al,%al
c0100782:	74 0a                	je     c010078e <debuginfo_eip+0x171>
        return -1;
c0100784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100789:	e9 b7 02 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010078e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0100795:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100798:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079b:	29 c2                	sub    %eax,%edx
c010079d:	89 d0                	mov    %edx,%eax
c010079f:	c1 f8 02             	sar    $0x2,%eax
c01007a2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01007a8:	48                   	dec    %eax
c01007a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01007ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01007af:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007b3:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01007ba:	00 
c01007bb:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01007be:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007c2:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cc:	89 04 24             	mov    %eax,(%esp)
c01007cf:	e8 fb fc ff ff       	call   c01004cf <stab_binsearch>
    if (lfile == 0)
c01007d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007d7:	85 c0                	test   %eax,%eax
c01007d9:	75 0a                	jne    c01007e5 <debuginfo_eip+0x1c8>
        return -1;
c01007db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007e0:	e9 60 02 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01007e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01007eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01007f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01007f4:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007f8:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01007ff:	00 
c0100800:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100803:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100807:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010080a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010080e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100811:	89 04 24             	mov    %eax,(%esp)
c0100814:	e8 b6 fc ff ff       	call   c01004cf <stab_binsearch>

    if (lfun <= rfun) {
c0100819:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010081c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010081f:	39 c2                	cmp    %eax,%edx
c0100821:	7f 7c                	jg     c010089f <debuginfo_eip+0x282>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100823:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100826:	89 c2                	mov    %eax,%edx
c0100828:	89 d0                	mov    %edx,%eax
c010082a:	01 c0                	add    %eax,%eax
c010082c:	01 d0                	add    %edx,%eax
c010082e:	c1 e0 02             	shl    $0x2,%eax
c0100831:	89 c2                	mov    %eax,%edx
c0100833:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100836:	01 d0                	add    %edx,%eax
c0100838:	8b 00                	mov    (%eax),%eax
c010083a:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010083d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100840:	29 d1                	sub    %edx,%ecx
c0100842:	89 ca                	mov    %ecx,%edx
c0100844:	39 d0                	cmp    %edx,%eax
c0100846:	73 22                	jae    c010086a <debuginfo_eip+0x24d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100848:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	89 d0                	mov    %edx,%eax
c010084f:	01 c0                	add    %eax,%eax
c0100851:	01 d0                	add    %edx,%eax
c0100853:	c1 e0 02             	shl    $0x2,%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	8b 10                	mov    (%eax),%edx
c010085f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100862:	01 c2                	add    %eax,%edx
c0100864:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100867:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010086a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086d:	89 c2                	mov    %eax,%edx
c010086f:	89 d0                	mov    %edx,%eax
c0100871:	01 c0                	add    %eax,%eax
c0100873:	01 d0                	add    %edx,%eax
c0100875:	c1 e0 02             	shl    $0x2,%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087d:	01 d0                	add    %edx,%eax
c010087f:	8b 50 08             	mov    0x8(%eax),%edx
c0100882:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100885:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100888:	8b 45 0c             	mov    0xc(%ebp),%eax
c010088b:	8b 40 10             	mov    0x10(%eax),%eax
c010088e:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100891:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100894:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c0100897:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010089a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010089d:	eb 15                	jmp    c01008b4 <debuginfo_eip+0x297>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010089f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01008a5:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01008a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01008ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008b7:	8b 40 08             	mov    0x8(%eax),%eax
c01008ba:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01008c1:	00 
c01008c2:	89 04 24             	mov    %eax,(%esp)
c01008c5:	e8 ef ac 00 00       	call   c010b5b9 <strfind>
c01008ca:	89 c2                	mov    %eax,%edx
c01008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008cf:	8b 40 08             	mov    0x8(%eax),%eax
c01008d2:	29 c2                	sub    %eax,%edx
c01008d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d7:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01008da:	8b 45 08             	mov    0x8(%ebp),%eax
c01008dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01008e1:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01008e8:	00 
c01008e9:	8d 45 c8             	lea    -0x38(%ebp),%eax
c01008ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01008f0:	8d 45 cc             	lea    -0x34(%ebp),%eax
c01008f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008fa:	89 04 24             	mov    %eax,(%esp)
c01008fd:	e8 cd fb ff ff       	call   c01004cf <stab_binsearch>
    if (lline <= rline) {
c0100902:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100905:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100908:	39 c2                	cmp    %eax,%edx
c010090a:	7f 23                	jg     c010092f <debuginfo_eip+0x312>
        info->eip_line = stabs[rline].n_desc;
c010090c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010090f:	89 c2                	mov    %eax,%edx
c0100911:	89 d0                	mov    %edx,%eax
c0100913:	01 c0                	add    %eax,%eax
c0100915:	01 d0                	add    %edx,%eax
c0100917:	c1 e0 02             	shl    $0x2,%eax
c010091a:	89 c2                	mov    %eax,%edx
c010091c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010091f:	01 d0                	add    %edx,%eax
c0100921:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100925:	89 c2                	mov    %eax,%edx
c0100927:	8b 45 0c             	mov    0xc(%ebp),%eax
c010092a:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010092d:	eb 11                	jmp    c0100940 <debuginfo_eip+0x323>
        return -1;
c010092f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100934:	e9 0c 01 00 00       	jmp    c0100a45 <debuginfo_eip+0x428>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100939:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010093c:	48                   	dec    %eax
c010093d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile
c0100940:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100943:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100946:	39 c2                	cmp    %eax,%edx
c0100948:	7c 56                	jl     c01009a0 <debuginfo_eip+0x383>
           && stabs[lline].n_type != N_SOL
c010094a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010094d:	89 c2                	mov    %eax,%edx
c010094f:	89 d0                	mov    %edx,%eax
c0100951:	01 c0                	add    %eax,%eax
c0100953:	01 d0                	add    %edx,%eax
c0100955:	c1 e0 02             	shl    $0x2,%eax
c0100958:	89 c2                	mov    %eax,%edx
c010095a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095d:	01 d0                	add    %edx,%eax
c010095f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100963:	3c 84                	cmp    $0x84,%al
c0100965:	74 39                	je     c01009a0 <debuginfo_eip+0x383>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100967:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010096a:	89 c2                	mov    %eax,%edx
c010096c:	89 d0                	mov    %edx,%eax
c010096e:	01 c0                	add    %eax,%eax
c0100970:	01 d0                	add    %edx,%eax
c0100972:	c1 e0 02             	shl    $0x2,%eax
c0100975:	89 c2                	mov    %eax,%edx
c0100977:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097a:	01 d0                	add    %edx,%eax
c010097c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100980:	3c 64                	cmp    $0x64,%al
c0100982:	75 b5                	jne    c0100939 <debuginfo_eip+0x31c>
c0100984:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100987:	89 c2                	mov    %eax,%edx
c0100989:	89 d0                	mov    %edx,%eax
c010098b:	01 c0                	add    %eax,%eax
c010098d:	01 d0                	add    %edx,%eax
c010098f:	c1 e0 02             	shl    $0x2,%eax
c0100992:	89 c2                	mov    %eax,%edx
c0100994:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100997:	01 d0                	add    %edx,%eax
c0100999:	8b 40 08             	mov    0x8(%eax),%eax
c010099c:	85 c0                	test   %eax,%eax
c010099e:	74 99                	je     c0100939 <debuginfo_eip+0x31c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01009a0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01009a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a6:	39 c2                	cmp    %eax,%edx
c01009a8:	7c 46                	jl     c01009f0 <debuginfo_eip+0x3d3>
c01009aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009ad:	89 c2                	mov    %eax,%edx
c01009af:	89 d0                	mov    %edx,%eax
c01009b1:	01 c0                	add    %eax,%eax
c01009b3:	01 d0                	add    %edx,%eax
c01009b5:	c1 e0 02             	shl    $0x2,%eax
c01009b8:	89 c2                	mov    %eax,%edx
c01009ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009bd:	01 d0                	add    %edx,%eax
c01009bf:	8b 00                	mov    (%eax),%eax
c01009c1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01009c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01009c7:	29 d1                	sub    %edx,%ecx
c01009c9:	89 ca                	mov    %ecx,%edx
c01009cb:	39 d0                	cmp    %edx,%eax
c01009cd:	73 21                	jae    c01009f0 <debuginfo_eip+0x3d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01009cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009d2:	89 c2                	mov    %eax,%edx
c01009d4:	89 d0                	mov    %edx,%eax
c01009d6:	01 c0                	add    %eax,%eax
c01009d8:	01 d0                	add    %edx,%eax
c01009da:	c1 e0 02             	shl    $0x2,%eax
c01009dd:	89 c2                	mov    %eax,%edx
c01009df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009e2:	01 d0                	add    %edx,%eax
c01009e4:	8b 10                	mov    (%eax),%edx
c01009e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009e9:	01 c2                	add    %eax,%edx
c01009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01009ee:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01009f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01009f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01009f6:	39 c2                	cmp    %eax,%edx
c01009f8:	7d 46                	jge    c0100a40 <debuginfo_eip+0x423>
        for (lline = lfun + 1;
c01009fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01009fd:	40                   	inc    %eax
c01009fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100a01:	eb 16                	jmp    c0100a19 <debuginfo_eip+0x3fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100a03:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a06:	8b 40 14             	mov    0x14(%eax),%eax
c0100a09:	8d 50 01             	lea    0x1(%eax),%edx
c0100a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a0f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100a12:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a15:	40                   	inc    %eax
c0100a16:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a19:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100a1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c0100a1f:	39 c2                	cmp    %eax,%edx
c0100a21:	7d 1d                	jge    c0100a40 <debuginfo_eip+0x423>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a23:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a26:	89 c2                	mov    %eax,%edx
c0100a28:	89 d0                	mov    %edx,%eax
c0100a2a:	01 c0                	add    %eax,%eax
c0100a2c:	01 d0                	add    %edx,%eax
c0100a2e:	c1 e0 02             	shl    $0x2,%eax
c0100a31:	89 c2                	mov    %eax,%edx
c0100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a36:	01 d0                	add    %edx,%eax
c0100a38:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100a3c:	3c a0                	cmp    $0xa0,%al
c0100a3e:	74 c3                	je     c0100a03 <debuginfo_eip+0x3e6>
        }
    }
    return 0;
c0100a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a45:	c9                   	leave  
c0100a46:	c3                   	ret    

c0100a47 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100a47:	55                   	push   %ebp
c0100a48:	89 e5                	mov    %esp,%ebp
c0100a4a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100a4d:	c7 04 24 42 c1 10 c0 	movl   $0xc010c142,(%esp)
c0100a54:	e8 50 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100a59:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100a60:	c0 
c0100a61:	c7 04 24 5b c1 10 c0 	movl   $0xc010c15b,(%esp)
c0100a68:	e8 3c f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100a6d:	c7 44 24 04 39 c0 10 	movl   $0xc010c039,0x4(%esp)
c0100a74:	c0 
c0100a75:	c7 04 24 73 c1 10 c0 	movl   $0xc010c173,(%esp)
c0100a7c:	e8 28 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100a81:	c7 44 24 04 00 f0 19 	movl   $0xc019f000,0x4(%esp)
c0100a88:	c0 
c0100a89:	c7 04 24 8b c1 10 c0 	movl   $0xc010c18b,(%esp)
c0100a90:	e8 14 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100a95:	c7 44 24 04 64 21 1a 	movl   $0xc01a2164,0x4(%esp)
c0100a9c:	c0 
c0100a9d:	c7 04 24 a3 c1 10 c0 	movl   $0xc010c1a3,(%esp)
c0100aa4:	e8 00 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100aa9:	b8 64 21 1a c0       	mov    $0xc01a2164,%eax
c0100aae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ab4:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100ab9:	29 c2                	sub    %eax,%edx
c0100abb:	89 d0                	mov    %edx,%eax
c0100abd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ac3:	85 c0                	test   %eax,%eax
c0100ac5:	0f 48 c2             	cmovs  %edx,%eax
c0100ac8:	c1 f8 0a             	sar    $0xa,%eax
c0100acb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100acf:	c7 04 24 bc c1 10 c0 	movl   $0xc010c1bc,(%esp)
c0100ad6:	e8 ce f7 ff ff       	call   c01002a9 <cprintf>
}
c0100adb:	90                   	nop
c0100adc:	c9                   	leave  
c0100add:	c3                   	ret    

c0100ade <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100ade:	55                   	push   %ebp
c0100adf:	89 e5                	mov    %esp,%ebp
c0100ae1:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100ae7:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100aea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aee:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af1:	89 04 24             	mov    %eax,(%esp)
c0100af4:	e8 24 fb ff ff       	call   c010061d <debuginfo_eip>
c0100af9:	85 c0                	test   %eax,%eax
c0100afb:	74 15                	je     c0100b12 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100afd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b04:	c7 04 24 e6 c1 10 c0 	movl   $0xc010c1e6,(%esp)
c0100b0b:	e8 99 f7 ff ff       	call   c01002a9 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100b10:	eb 6c                	jmp    c0100b7e <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b19:	eb 1b                	jmp    c0100b36 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100b1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b21:	01 d0                	add    %edx,%eax
c0100b23:	0f b6 00             	movzbl (%eax),%eax
c0100b26:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b2f:	01 ca                	add    %ecx,%edx
c0100b31:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b33:	ff 45 f4             	incl   -0xc(%ebp)
c0100b36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b39:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100b3c:	7c dd                	jl     c0100b1b <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100b3e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b47:	01 d0                	add    %edx,%eax
c0100b49:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100b4f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100b52:	89 d1                	mov    %edx,%ecx
c0100b54:	29 c1                	sub    %eax,%ecx
c0100b56:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100b59:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100b5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100b60:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b6a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b72:	c7 04 24 02 c2 10 c0 	movl   $0xc010c202,(%esp)
c0100b79:	e8 2b f7 ff ff       	call   c01002a9 <cprintf>
}
c0100b7e:	90                   	nop
c0100b7f:	c9                   	leave  
c0100b80:	c3                   	ret    

c0100b81 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100b81:	55                   	push   %ebp
c0100b82:	89 e5                	mov    %esp,%ebp
c0100b84:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100b87:	8b 45 04             	mov    0x4(%ebp),%eax
c0100b8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100b8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100b90:	c9                   	leave  
c0100b91:	c3                   	ret    

c0100b92 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100b92:	55                   	push   %ebp
c0100b93:	89 e5                	mov    %esp,%ebp
c0100b95:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100b98:	89 e8                	mov    %ebp,%eax
c0100b9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ba3:	e8 d9 ff ff ff       	call   c0100b81 <read_eip>
c0100ba8:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100bab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100bb2:	e9 84 00 00 00       	jmp    c0100c3b <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bba:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bc5:	c7 04 24 14 c2 10 c0 	movl   $0xc010c214,(%esp)
c0100bcc:	e8 d8 f6 ff ff       	call   c01002a9 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd4:	83 c0 08             	add    $0x8,%eax
c0100bd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100bda:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100be1:	eb 24                	jmp    c0100c07 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100be3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100be6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100bf0:	01 d0                	add    %edx,%eax
c0100bf2:	8b 00                	mov    (%eax),%eax
c0100bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf8:	c7 04 24 30 c2 10 c0 	movl   $0xc010c230,(%esp)
c0100bff:	e8 a5 f6 ff ff       	call   c01002a9 <cprintf>
        for (j = 0; j < 4; j ++) {
c0100c04:	ff 45 e8             	incl   -0x18(%ebp)
c0100c07:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100c0b:	7e d6                	jle    c0100be3 <print_stackframe+0x51>
        }
        cprintf("\n");
c0100c0d:	c7 04 24 38 c2 10 c0 	movl   $0xc010c238,(%esp)
c0100c14:	e8 90 f6 ff ff       	call   c01002a9 <cprintf>
        print_debuginfo(eip - 1);
c0100c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c1c:	48                   	dec    %eax
c0100c1d:	89 04 24             	mov    %eax,(%esp)
c0100c20:	e8 b9 fe ff ff       	call   c0100ade <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c28:	83 c0 04             	add    $0x4,%eax
c0100c2b:	8b 00                	mov    (%eax),%eax
c0100c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c33:	8b 00                	mov    (%eax),%eax
c0100c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100c38:	ff 45 ec             	incl   -0x14(%ebp)
c0100c3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c3f:	74 0a                	je     c0100c4b <print_stackframe+0xb9>
c0100c41:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100c45:	0f 8e 6c ff ff ff    	jle    c0100bb7 <print_stackframe+0x25>
    }
}
c0100c4b:	90                   	nop
c0100c4c:	c9                   	leave  
c0100c4d:	c3                   	ret    

c0100c4e <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100c4e:	55                   	push   %ebp
c0100c4f:	89 e5                	mov    %esp,%ebp
c0100c51:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100c54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c5b:	eb 0c                	jmp    c0100c69 <parse+0x1b>
            *buf ++ = '\0';
c0100c5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c60:	8d 50 01             	lea    0x1(%eax),%edx
c0100c63:	89 55 08             	mov    %edx,0x8(%ebp)
c0100c66:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c69:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c6c:	0f b6 00             	movzbl (%eax),%eax
c0100c6f:	84 c0                	test   %al,%al
c0100c71:	74 1d                	je     c0100c90 <parse+0x42>
c0100c73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c76:	0f b6 00             	movzbl (%eax),%eax
c0100c79:	0f be c0             	movsbl %al,%eax
c0100c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c80:	c7 04 24 bc c2 10 c0 	movl   $0xc010c2bc,(%esp)
c0100c87:	e8 fb a8 00 00       	call   c010b587 <strchr>
c0100c8c:	85 c0                	test   %eax,%eax
c0100c8e:	75 cd                	jne    c0100c5d <parse+0xf>
        }
        if (*buf == '\0') {
c0100c90:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c93:	0f b6 00             	movzbl (%eax),%eax
c0100c96:	84 c0                	test   %al,%al
c0100c98:	74 65                	je     c0100cff <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100c9a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100c9e:	75 14                	jne    c0100cb4 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ca0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ca7:	00 
c0100ca8:	c7 04 24 c1 c2 10 c0 	movl   $0xc010c2c1,(%esp)
c0100caf:	e8 f5 f5 ff ff       	call   c01002a9 <cprintf>
        }
        argv[argc ++] = buf;
c0100cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb7:	8d 50 01             	lea    0x1(%eax),%edx
c0100cba:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100cbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cc7:	01 c2                	add    %eax,%edx
c0100cc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ccc:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cce:	eb 03                	jmp    c0100cd3 <parse+0x85>
            buf ++;
c0100cd0:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd6:	0f b6 00             	movzbl (%eax),%eax
c0100cd9:	84 c0                	test   %al,%al
c0100cdb:	74 8c                	je     c0100c69 <parse+0x1b>
c0100cdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce0:	0f b6 00             	movzbl (%eax),%eax
c0100ce3:	0f be c0             	movsbl %al,%eax
c0100ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cea:	c7 04 24 bc c2 10 c0 	movl   $0xc010c2bc,(%esp)
c0100cf1:	e8 91 a8 00 00       	call   c010b587 <strchr>
c0100cf6:	85 c0                	test   %eax,%eax
c0100cf8:	74 d6                	je     c0100cd0 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100cfa:	e9 6a ff ff ff       	jmp    c0100c69 <parse+0x1b>
            break;
c0100cff:	90                   	nop
        }
    }
    return argc;
c0100d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100d03:	c9                   	leave  
c0100d04:	c3                   	ret    

c0100d05 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100d05:	55                   	push   %ebp
c0100d06:	89 e5                	mov    %esp,%ebp
c0100d08:	53                   	push   %ebx
c0100d09:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100d0c:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d16:	89 04 24             	mov    %eax,(%esp)
c0100d19:	e8 30 ff ff ff       	call   c0100c4e <parse>
c0100d1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100d21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100d25:	75 0a                	jne    c0100d31 <runcmd+0x2c>
        return 0;
c0100d27:	b8 00 00 00 00       	mov    $0x0,%eax
c0100d2c:	e9 83 00 00 00       	jmp    c0100db4 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d38:	eb 5a                	jmp    c0100d94 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100d3a:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d40:	89 d0                	mov    %edx,%eax
c0100d42:	01 c0                	add    %eax,%eax
c0100d44:	01 d0                	add    %edx,%eax
c0100d46:	c1 e0 02             	shl    $0x2,%eax
c0100d49:	05 00 b0 12 c0       	add    $0xc012b000,%eax
c0100d4e:	8b 00                	mov    (%eax),%eax
c0100d50:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100d54:	89 04 24             	mov    %eax,(%esp)
c0100d57:	e8 8e a7 00 00       	call   c010b4ea <strcmp>
c0100d5c:	85 c0                	test   %eax,%eax
c0100d5e:	75 31                	jne    c0100d91 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100d60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d63:	89 d0                	mov    %edx,%eax
c0100d65:	01 c0                	add    %eax,%eax
c0100d67:	01 d0                	add    %edx,%eax
c0100d69:	c1 e0 02             	shl    $0x2,%eax
c0100d6c:	05 08 b0 12 c0       	add    $0xc012b008,%eax
c0100d71:	8b 10                	mov    (%eax),%edx
c0100d73:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d76:	83 c0 04             	add    $0x4,%eax
c0100d79:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100d7c:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100d82:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d8a:	89 1c 24             	mov    %ebx,(%esp)
c0100d8d:	ff d2                	call   *%edx
c0100d8f:	eb 23                	jmp    c0100db4 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d91:	ff 45 f4             	incl   -0xc(%ebp)
c0100d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d97:	83 f8 02             	cmp    $0x2,%eax
c0100d9a:	76 9e                	jbe    c0100d3a <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100d9c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100da3:	c7 04 24 df c2 10 c0 	movl   $0xc010c2df,(%esp)
c0100daa:	e8 fa f4 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0100daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100db4:	83 c4 64             	add    $0x64,%esp
c0100db7:	5b                   	pop    %ebx
c0100db8:	5d                   	pop    %ebp
c0100db9:	c3                   	ret    

c0100dba <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100dba:	55                   	push   %ebp
c0100dbb:	89 e5                	mov    %esp,%ebp
c0100dbd:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100dc0:	c7 04 24 f8 c2 10 c0 	movl   $0xc010c2f8,(%esp)
c0100dc7:	e8 dd f4 ff ff       	call   c01002a9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100dcc:	c7 04 24 20 c3 10 c0 	movl   $0xc010c320,(%esp)
c0100dd3:	e8 d1 f4 ff ff       	call   c01002a9 <cprintf>

    if (tf != NULL) {
c0100dd8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ddc:	74 0b                	je     c0100de9 <kmonitor+0x2f>
        print_trapframe(tf);
c0100dde:	8b 45 08             	mov    0x8(%ebp),%eax
c0100de1:	89 04 24             	mov    %eax,(%esp)
c0100de4:	e8 d1 15 00 00       	call   c01023ba <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100de9:	c7 04 24 45 c3 10 c0 	movl   $0xc010c345,(%esp)
c0100df0:	e8 56 f5 ff ff       	call   c010034b <readline>
c0100df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100df8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100dfc:	74 eb                	je     c0100de9 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100dfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e08:	89 04 24             	mov    %eax,(%esp)
c0100e0b:	e8 f5 fe ff ff       	call   c0100d05 <runcmd>
c0100e10:	85 c0                	test   %eax,%eax
c0100e12:	78 02                	js     c0100e16 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100e14:	eb d3                	jmp    c0100de9 <kmonitor+0x2f>
                break;
c0100e16:	90                   	nop
            }
        }
    }
}
c0100e17:	90                   	nop
c0100e18:	c9                   	leave  
c0100e19:	c3                   	ret    

c0100e1a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100e1a:	55                   	push   %ebp
c0100e1b:	89 e5                	mov    %esp,%ebp
c0100e1d:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100e27:	eb 3d                	jmp    c0100e66 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100e29:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e2c:	89 d0                	mov    %edx,%eax
c0100e2e:	01 c0                	add    %eax,%eax
c0100e30:	01 d0                	add    %edx,%eax
c0100e32:	c1 e0 02             	shl    $0x2,%eax
c0100e35:	05 04 b0 12 c0       	add    $0xc012b004,%eax
c0100e3a:	8b 08                	mov    (%eax),%ecx
c0100e3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e3f:	89 d0                	mov    %edx,%eax
c0100e41:	01 c0                	add    %eax,%eax
c0100e43:	01 d0                	add    %edx,%eax
c0100e45:	c1 e0 02             	shl    $0x2,%eax
c0100e48:	05 00 b0 12 c0       	add    $0xc012b000,%eax
c0100e4d:	8b 00                	mov    (%eax),%eax
c0100e4f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100e53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e57:	c7 04 24 49 c3 10 c0 	movl   $0xc010c349,(%esp)
c0100e5e:	e8 46 f4 ff ff       	call   c01002a9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e63:	ff 45 f4             	incl   -0xc(%ebp)
c0100e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e69:	83 f8 02             	cmp    $0x2,%eax
c0100e6c:	76 bb                	jbe    c0100e29 <mon_help+0xf>
    }
    return 0;
c0100e6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e73:	c9                   	leave  
c0100e74:	c3                   	ret    

c0100e75 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100e75:	55                   	push   %ebp
c0100e76:	89 e5                	mov    %esp,%ebp
c0100e78:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100e7b:	e8 c7 fb ff ff       	call   c0100a47 <print_kerninfo>
    return 0;
c0100e80:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e85:	c9                   	leave  
c0100e86:	c3                   	ret    

c0100e87 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100e87:	55                   	push   %ebp
c0100e88:	89 e5                	mov    %esp,%ebp
c0100e8a:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100e8d:	e8 00 fd ff ff       	call   c0100b92 <print_stackframe>
    return 0;
c0100e92:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e97:	c9                   	leave  
c0100e98:	c3                   	ret    

c0100e99 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100e99:	55                   	push   %ebp
c0100e9a:	89 e5                	mov    %esp,%ebp
c0100e9c:	83 ec 14             	sub    $0x14,%esp
c0100e9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ea2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100ea6:	90                   	nop
c0100ea7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100eaa:	83 c0 07             	add    $0x7,%eax
c0100ead:	0f b7 c0             	movzwl %ax,%eax
c0100eb0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100eb4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100eb8:	89 c2                	mov    %eax,%edx
c0100eba:	ec                   	in     (%dx),%al
c0100ebb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100ebe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100ec2:	0f b6 c0             	movzbl %al,%eax
c0100ec5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ecb:	25 80 00 00 00       	and    $0x80,%eax
c0100ed0:	85 c0                	test   %eax,%eax
c0100ed2:	75 d3                	jne    c0100ea7 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100ed4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100ed8:	74 11                	je     c0100eeb <ide_wait_ready+0x52>
c0100eda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100edd:	83 e0 21             	and    $0x21,%eax
c0100ee0:	85 c0                	test   %eax,%eax
c0100ee2:	74 07                	je     c0100eeb <ide_wait_ready+0x52>
        return -1;
c0100ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100ee9:	eb 05                	jmp    c0100ef0 <ide_wait_ready+0x57>
    }
    return 0;
c0100eeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ef0:	c9                   	leave  
c0100ef1:	c3                   	ret    

c0100ef2 <ide_init>:

void
ide_init(void) {
c0100ef2:	55                   	push   %ebp
c0100ef3:	89 e5                	mov    %esp,%ebp
c0100ef5:	57                   	push   %edi
c0100ef6:	53                   	push   %ebx
c0100ef7:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100efd:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100f03:	e9 ba 02 00 00       	jmp    c01011c2 <ide_init+0x2d0>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100f08:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f0c:	89 d0                	mov    %edx,%eax
c0100f0e:	c1 e0 03             	shl    $0x3,%eax
c0100f11:	29 d0                	sub    %edx,%eax
c0100f13:	c1 e0 03             	shl    $0x3,%eax
c0100f16:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c0100f1b:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100f1e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f22:	d1 e8                	shr    %eax
c0100f24:	0f b7 c0             	movzwl %ax,%eax
c0100f27:	8b 04 85 54 c3 10 c0 	mov    -0x3fef3cac(,%eax,4),%eax
c0100f2e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100f32:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f3d:	00 
c0100f3e:	89 04 24             	mov    %eax,(%esp)
c0100f41:	e8 53 ff ff ff       	call   c0100e99 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100f46:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f4a:	c1 e0 04             	shl    $0x4,%eax
c0100f4d:	24 10                	and    $0x10,%al
c0100f4f:	0c e0                	or     $0xe0,%al
c0100f51:	0f b6 c0             	movzbl %al,%eax
c0100f54:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f58:	83 c2 06             	add    $0x6,%edx
c0100f5b:	0f b7 d2             	movzwl %dx,%edx
c0100f5e:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100f62:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f65:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100f69:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100f6d:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100f6e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f79:	00 
c0100f7a:	89 04 24             	mov    %eax,(%esp)
c0100f7d:	e8 17 ff ff ff       	call   c0100e99 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100f82:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f86:	83 c0 07             	add    $0x7,%eax
c0100f89:	0f b7 c0             	movzwl %ax,%eax
c0100f8c:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100f90:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100f94:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100f98:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100f9c:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100f9d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fa8:	00 
c0100fa9:	89 04 24             	mov    %eax,(%esp)
c0100fac:	e8 e8 fe ff ff       	call   c0100e99 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100fb1:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fb5:	83 c0 07             	add    $0x7,%eax
c0100fb8:	0f b7 c0             	movzwl %ax,%eax
c0100fbb:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fbf:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100fc3:	89 c2                	mov    %eax,%edx
c0100fc5:	ec                   	in     (%dx),%al
c0100fc6:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0100fc9:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fcd:	84 c0                	test   %al,%al
c0100fcf:	0f 84 e3 01 00 00    	je     c01011b8 <ide_init+0x2c6>
c0100fd5:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fd9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100fe0:	00 
c0100fe1:	89 04 24             	mov    %eax,(%esp)
c0100fe4:	e8 b0 fe ff ff       	call   c0100e99 <ide_wait_ready>
c0100fe9:	85 c0                	test   %eax,%eax
c0100feb:	0f 85 c7 01 00 00    	jne    c01011b8 <ide_init+0x2c6>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ff1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ff5:	89 d0                	mov    %edx,%eax
c0100ff7:	c1 e0 03             	shl    $0x3,%eax
c0100ffa:	29 d0                	sub    %edx,%eax
c0100ffc:	c1 e0 03             	shl    $0x3,%eax
c0100fff:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c0101004:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101007:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010100b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010100e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101014:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101017:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c010101e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101021:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101024:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101027:	89 cb                	mov    %ecx,%ebx
c0101029:	89 df                	mov    %ebx,%edi
c010102b:	89 c1                	mov    %eax,%ecx
c010102d:	fc                   	cld    
c010102e:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101030:	89 c8                	mov    %ecx,%eax
c0101032:	89 fb                	mov    %edi,%ebx
c0101034:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101037:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010103a:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101040:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101043:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101046:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010104c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010104f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101052:	25 00 00 00 04       	and    $0x4000000,%eax
c0101057:	85 c0                	test   %eax,%eax
c0101059:	74 0e                	je     c0101069 <ide_init+0x177>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010105b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010105e:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101064:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101067:	eb 09                	jmp    c0101072 <ide_init+0x180>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010106c:	8b 40 78             	mov    0x78(%eax),%eax
c010106f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101072:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101076:	89 d0                	mov    %edx,%eax
c0101078:	c1 e0 03             	shl    $0x3,%eax
c010107b:	29 d0                	sub    %edx,%eax
c010107d:	c1 e0 03             	shl    $0x3,%eax
c0101080:	8d 90 44 f4 19 c0    	lea    -0x3fe60bbc(%eax),%edx
c0101086:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101089:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c010108b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010108f:	89 d0                	mov    %edx,%eax
c0101091:	c1 e0 03             	shl    $0x3,%eax
c0101094:	29 d0                	sub    %edx,%eax
c0101096:	c1 e0 03             	shl    $0x3,%eax
c0101099:	8d 90 48 f4 19 c0    	lea    -0x3fe60bb8(%eax),%edx
c010109f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01010a2:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01010a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010a7:	83 c0 62             	add    $0x62,%eax
c01010aa:	0f b7 00             	movzwl (%eax),%eax
c01010ad:	25 00 02 00 00       	and    $0x200,%eax
c01010b2:	85 c0                	test   %eax,%eax
c01010b4:	75 24                	jne    c01010da <ide_init+0x1e8>
c01010b6:	c7 44 24 0c 5c c3 10 	movl   $0xc010c35c,0xc(%esp)
c01010bd:	c0 
c01010be:	c7 44 24 08 9f c3 10 	movl   $0xc010c39f,0x8(%esp)
c01010c5:	c0 
c01010c6:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01010cd:	00 
c01010ce:	c7 04 24 b4 c3 10 c0 	movl   $0xc010c3b4,(%esp)
c01010d5:	e8 26 f3 ff ff       	call   c0100400 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01010da:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010de:	89 d0                	mov    %edx,%eax
c01010e0:	c1 e0 03             	shl    $0x3,%eax
c01010e3:	29 d0                	sub    %edx,%eax
c01010e5:	c1 e0 03             	shl    $0x3,%eax
c01010e8:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c01010ed:	83 c0 0c             	add    $0xc,%eax
c01010f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01010f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010f6:	83 c0 36             	add    $0x36,%eax
c01010f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01010fc:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101103:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010110a:	eb 34                	jmp    c0101140 <ide_init+0x24e>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010110c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010110f:	8d 50 01             	lea    0x1(%eax),%edx
c0101112:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101115:	01 d0                	add    %edx,%eax
c0101117:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010111a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010111d:	01 ca                	add    %ecx,%edx
c010111f:	0f b6 00             	movzbl (%eax),%eax
c0101122:	88 02                	mov    %al,(%edx)
c0101124:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101127:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010112a:	01 d0                	add    %edx,%eax
c010112c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010112f:	8d 4a 01             	lea    0x1(%edx),%ecx
c0101132:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101135:	01 ca                	add    %ecx,%edx
c0101137:	0f b6 00             	movzbl (%eax),%eax
c010113a:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c010113c:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101140:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101143:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101146:	72 c4                	jb     c010110c <ide_init+0x21a>
        }
        do {
            model[i] = '\0';
c0101148:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010114b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010114e:	01 d0                	add    %edx,%eax
c0101150:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101153:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101156:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101159:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010115c:	85 c0                	test   %eax,%eax
c010115e:	74 0f                	je     c010116f <ide_init+0x27d>
c0101160:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101163:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101166:	01 d0                	add    %edx,%eax
c0101168:	0f b6 00             	movzbl (%eax),%eax
c010116b:	3c 20                	cmp    $0x20,%al
c010116d:	74 d9                	je     c0101148 <ide_init+0x256>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010116f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101173:	89 d0                	mov    %edx,%eax
c0101175:	c1 e0 03             	shl    $0x3,%eax
c0101178:	29 d0                	sub    %edx,%eax
c010117a:	c1 e0 03             	shl    $0x3,%eax
c010117d:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c0101182:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101185:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101189:	89 d0                	mov    %edx,%eax
c010118b:	c1 e0 03             	shl    $0x3,%eax
c010118e:	29 d0                	sub    %edx,%eax
c0101190:	c1 e0 03             	shl    $0x3,%eax
c0101193:	05 48 f4 19 c0       	add    $0xc019f448,%eax
c0101198:	8b 10                	mov    (%eax),%edx
c010119a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010119e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01011a2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01011aa:	c7 04 24 c6 c3 10 c0 	movl   $0xc010c3c6,(%esp)
c01011b1:	e8 f3 f0 ff ff       	call   c01002a9 <cprintf>
c01011b6:	eb 01                	jmp    c01011b9 <ide_init+0x2c7>
            continue ;
c01011b8:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01011b9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011bd:	40                   	inc    %eax
c01011be:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01011c2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011c6:	83 f8 03             	cmp    $0x3,%eax
c01011c9:	0f 86 39 fd ff ff    	jbe    c0100f08 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01011cf:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01011d6:	e8 91 0e 00 00       	call   c010206c <pic_enable>
    pic_enable(IRQ_IDE2);
c01011db:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c01011e2:	e8 85 0e 00 00       	call   c010206c <pic_enable>
}
c01011e7:	90                   	nop
c01011e8:	81 c4 50 02 00 00    	add    $0x250,%esp
c01011ee:	5b                   	pop    %ebx
c01011ef:	5f                   	pop    %edi
c01011f0:	5d                   	pop    %ebp
c01011f1:	c3                   	ret    

c01011f2 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01011f2:	55                   	push   %ebp
c01011f3:	89 e5                	mov    %esp,%ebp
c01011f5:	83 ec 04             	sub    $0x4,%esp
c01011f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01011fb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c01011ff:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101203:	83 f8 03             	cmp    $0x3,%eax
c0101206:	77 21                	ja     c0101229 <ide_device_valid+0x37>
c0101208:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c010120c:	89 d0                	mov    %edx,%eax
c010120e:	c1 e0 03             	shl    $0x3,%eax
c0101211:	29 d0                	sub    %edx,%eax
c0101213:	c1 e0 03             	shl    $0x3,%eax
c0101216:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c010121b:	0f b6 00             	movzbl (%eax),%eax
c010121e:	84 c0                	test   %al,%al
c0101220:	74 07                	je     c0101229 <ide_device_valid+0x37>
c0101222:	b8 01 00 00 00       	mov    $0x1,%eax
c0101227:	eb 05                	jmp    c010122e <ide_device_valid+0x3c>
c0101229:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010122e:	c9                   	leave  
c010122f:	c3                   	ret    

c0101230 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101230:	55                   	push   %ebp
c0101231:	89 e5                	mov    %esp,%ebp
c0101233:	83 ec 08             	sub    $0x8,%esp
c0101236:	8b 45 08             	mov    0x8(%ebp),%eax
c0101239:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c010123d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101241:	89 04 24             	mov    %eax,(%esp)
c0101244:	e8 a9 ff ff ff       	call   c01011f2 <ide_device_valid>
c0101249:	85 c0                	test   %eax,%eax
c010124b:	74 17                	je     c0101264 <ide_device_size+0x34>
        return ide_devices[ideno].size;
c010124d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101251:	89 d0                	mov    %edx,%eax
c0101253:	c1 e0 03             	shl    $0x3,%eax
c0101256:	29 d0                	sub    %edx,%eax
c0101258:	c1 e0 03             	shl    $0x3,%eax
c010125b:	05 48 f4 19 c0       	add    $0xc019f448,%eax
c0101260:	8b 00                	mov    (%eax),%eax
c0101262:	eb 05                	jmp    c0101269 <ide_device_size+0x39>
    }
    return 0;
c0101264:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101269:	c9                   	leave  
c010126a:	c3                   	ret    

c010126b <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c010126b:	55                   	push   %ebp
c010126c:	89 e5                	mov    %esp,%ebp
c010126e:	57                   	push   %edi
c010126f:	53                   	push   %ebx
c0101270:	83 ec 50             	sub    $0x50,%esp
c0101273:	8b 45 08             	mov    0x8(%ebp),%eax
c0101276:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010127a:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101281:	77 23                	ja     c01012a6 <ide_read_secs+0x3b>
c0101283:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101287:	83 f8 03             	cmp    $0x3,%eax
c010128a:	77 1a                	ja     c01012a6 <ide_read_secs+0x3b>
c010128c:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101290:	89 d0                	mov    %edx,%eax
c0101292:	c1 e0 03             	shl    $0x3,%eax
c0101295:	29 d0                	sub    %edx,%eax
c0101297:	c1 e0 03             	shl    $0x3,%eax
c010129a:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c010129f:	0f b6 00             	movzbl (%eax),%eax
c01012a2:	84 c0                	test   %al,%al
c01012a4:	75 24                	jne    c01012ca <ide_read_secs+0x5f>
c01012a6:	c7 44 24 0c e4 c3 10 	movl   $0xc010c3e4,0xc(%esp)
c01012ad:	c0 
c01012ae:	c7 44 24 08 9f c3 10 	movl   $0xc010c39f,0x8(%esp)
c01012b5:	c0 
c01012b6:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01012bd:	00 
c01012be:	c7 04 24 b4 c3 10 c0 	movl   $0xc010c3b4,(%esp)
c01012c5:	e8 36 f1 ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01012ca:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01012d1:	77 0f                	ja     c01012e2 <ide_read_secs+0x77>
c01012d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01012d6:	8b 45 14             	mov    0x14(%ebp),%eax
c01012d9:	01 d0                	add    %edx,%eax
c01012db:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01012e0:	76 24                	jbe    c0101306 <ide_read_secs+0x9b>
c01012e2:	c7 44 24 0c 0c c4 10 	movl   $0xc010c40c,0xc(%esp)
c01012e9:	c0 
c01012ea:	c7 44 24 08 9f c3 10 	movl   $0xc010c39f,0x8(%esp)
c01012f1:	c0 
c01012f2:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01012f9:	00 
c01012fa:	c7 04 24 b4 c3 10 c0 	movl   $0xc010c3b4,(%esp)
c0101301:	e8 fa f0 ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101306:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010130a:	d1 e8                	shr    %eax
c010130c:	0f b7 c0             	movzwl %ax,%eax
c010130f:	8b 04 85 54 c3 10 c0 	mov    -0x3fef3cac(,%eax,4),%eax
c0101316:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010131a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010131e:	d1 e8                	shr    %eax
c0101320:	0f b7 c0             	movzwl %ax,%eax
c0101323:	0f b7 04 85 56 c3 10 	movzwl -0x3fef3caa(,%eax,4),%eax
c010132a:	c0 
c010132b:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010132f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101333:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010133a:	00 
c010133b:	89 04 24             	mov    %eax,(%esp)
c010133e:	e8 56 fb ff ff       	call   c0100e99 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101343:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101346:	83 c0 02             	add    $0x2,%eax
c0101349:	0f b7 c0             	movzwl %ax,%eax
c010134c:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101350:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101354:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101358:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010135c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c010135d:	8b 45 14             	mov    0x14(%ebp),%eax
c0101360:	0f b6 c0             	movzbl %al,%eax
c0101363:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101367:	83 c2 02             	add    $0x2,%edx
c010136a:	0f b7 d2             	movzwl %dx,%edx
c010136d:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101371:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101374:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101378:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010137c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c010137d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101380:	0f b6 c0             	movzbl %al,%eax
c0101383:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101387:	83 c2 03             	add    $0x3,%edx
c010138a:	0f b7 d2             	movzwl %dx,%edx
c010138d:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101391:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101394:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101398:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010139c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c010139d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013a0:	c1 e8 08             	shr    $0x8,%eax
c01013a3:	0f b6 c0             	movzbl %al,%eax
c01013a6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013aa:	83 c2 04             	add    $0x4,%edx
c01013ad:	0f b7 d2             	movzwl %dx,%edx
c01013b0:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01013b4:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01013b7:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01013bb:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01013bf:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01013c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013c3:	c1 e8 10             	shr    $0x10,%eax
c01013c6:	0f b6 c0             	movzbl %al,%eax
c01013c9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013cd:	83 c2 05             	add    $0x5,%edx
c01013d0:	0f b7 d2             	movzwl %dx,%edx
c01013d3:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013d7:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013da:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013de:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013e2:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01013e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01013e6:	c0 e0 04             	shl    $0x4,%al
c01013e9:	24 10                	and    $0x10,%al
c01013eb:	88 c2                	mov    %al,%dl
c01013ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013f0:	c1 e8 18             	shr    $0x18,%eax
c01013f3:	24 0f                	and    $0xf,%al
c01013f5:	08 d0                	or     %dl,%al
c01013f7:	0c e0                	or     $0xe0,%al
c01013f9:	0f b6 c0             	movzbl %al,%eax
c01013fc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101400:	83 c2 06             	add    $0x6,%edx
c0101403:	0f b7 d2             	movzwl %dx,%edx
c0101406:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010140a:	88 45 e9             	mov    %al,-0x17(%ebp)
c010140d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101411:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101415:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101416:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010141a:	83 c0 07             	add    $0x7,%eax
c010141d:	0f b7 c0             	movzwl %ax,%eax
c0101420:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101424:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
c0101428:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010142c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101430:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101431:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101438:	eb 57                	jmp    c0101491 <ide_read_secs+0x226>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010143a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010143e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101445:	00 
c0101446:	89 04 24             	mov    %eax,(%esp)
c0101449:	e8 4b fa ff ff       	call   c0100e99 <ide_wait_ready>
c010144e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101451:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101455:	75 42                	jne    c0101499 <ide_read_secs+0x22e>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101457:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010145b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010145e:	8b 45 10             	mov    0x10(%ebp),%eax
c0101461:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101464:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c010146b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010146e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101471:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101474:	89 cb                	mov    %ecx,%ebx
c0101476:	89 df                	mov    %ebx,%edi
c0101478:	89 c1                	mov    %eax,%ecx
c010147a:	fc                   	cld    
c010147b:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010147d:	89 c8                	mov    %ecx,%eax
c010147f:	89 fb                	mov    %edi,%ebx
c0101481:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101484:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101487:	ff 4d 14             	decl   0x14(%ebp)
c010148a:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101491:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101495:	75 a3                	jne    c010143a <ide_read_secs+0x1cf>
    }

out:
c0101497:	eb 01                	jmp    c010149a <ide_read_secs+0x22f>
            goto out;
c0101499:	90                   	nop
    return ret;
c010149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010149d:	83 c4 50             	add    $0x50,%esp
c01014a0:	5b                   	pop    %ebx
c01014a1:	5f                   	pop    %edi
c01014a2:	5d                   	pop    %ebp
c01014a3:	c3                   	ret    

c01014a4 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01014a4:	55                   	push   %ebp
c01014a5:	89 e5                	mov    %esp,%ebp
c01014a7:	56                   	push   %esi
c01014a8:	53                   	push   %ebx
c01014a9:	83 ec 50             	sub    $0x50,%esp
c01014ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01014af:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01014b3:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01014ba:	77 23                	ja     c01014df <ide_write_secs+0x3b>
c01014bc:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014c0:	83 f8 03             	cmp    $0x3,%eax
c01014c3:	77 1a                	ja     c01014df <ide_write_secs+0x3b>
c01014c5:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c01014c9:	89 d0                	mov    %edx,%eax
c01014cb:	c1 e0 03             	shl    $0x3,%eax
c01014ce:	29 d0                	sub    %edx,%eax
c01014d0:	c1 e0 03             	shl    $0x3,%eax
c01014d3:	05 40 f4 19 c0       	add    $0xc019f440,%eax
c01014d8:	0f b6 00             	movzbl (%eax),%eax
c01014db:	84 c0                	test   %al,%al
c01014dd:	75 24                	jne    c0101503 <ide_write_secs+0x5f>
c01014df:	c7 44 24 0c e4 c3 10 	movl   $0xc010c3e4,0xc(%esp)
c01014e6:	c0 
c01014e7:	c7 44 24 08 9f c3 10 	movl   $0xc010c39f,0x8(%esp)
c01014ee:	c0 
c01014ef:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01014f6:	00 
c01014f7:	c7 04 24 b4 c3 10 c0 	movl   $0xc010c3b4,(%esp)
c01014fe:	e8 fd ee ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101503:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010150a:	77 0f                	ja     c010151b <ide_write_secs+0x77>
c010150c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010150f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101512:	01 d0                	add    %edx,%eax
c0101514:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101519:	76 24                	jbe    c010153f <ide_write_secs+0x9b>
c010151b:	c7 44 24 0c 0c c4 10 	movl   $0xc010c40c,0xc(%esp)
c0101522:	c0 
c0101523:	c7 44 24 08 9f c3 10 	movl   $0xc010c39f,0x8(%esp)
c010152a:	c0 
c010152b:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101532:	00 
c0101533:	c7 04 24 b4 c3 10 c0 	movl   $0xc010c3b4,(%esp)
c010153a:	e8 c1 ee ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010153f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101543:	d1 e8                	shr    %eax
c0101545:	0f b7 c0             	movzwl %ax,%eax
c0101548:	8b 04 85 54 c3 10 c0 	mov    -0x3fef3cac(,%eax,4),%eax
c010154f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101553:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101557:	d1 e8                	shr    %eax
c0101559:	0f b7 c0             	movzwl %ax,%eax
c010155c:	0f b7 04 85 56 c3 10 	movzwl -0x3fef3caa(,%eax,4),%eax
c0101563:	c0 
c0101564:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101568:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010156c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101573:	00 
c0101574:	89 04 24             	mov    %eax,(%esp)
c0101577:	e8 1d f9 ff ff       	call   c0100e99 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010157f:	83 c0 02             	add    $0x2,%eax
c0101582:	0f b7 c0             	movzwl %ax,%eax
c0101585:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101589:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010158d:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101591:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101595:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101596:	8b 45 14             	mov    0x14(%ebp),%eax
c0101599:	0f b6 c0             	movzbl %al,%eax
c010159c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015a0:	83 c2 02             	add    $0x2,%edx
c01015a3:	0f b7 d2             	movzwl %dx,%edx
c01015a6:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01015aa:	88 45 d9             	mov    %al,-0x27(%ebp)
c01015ad:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01015b1:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01015b5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01015b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01015b9:	0f b6 c0             	movzbl %al,%eax
c01015bc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015c0:	83 c2 03             	add    $0x3,%edx
c01015c3:	0f b7 d2             	movzwl %dx,%edx
c01015c6:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01015ca:	88 45 dd             	mov    %al,-0x23(%ebp)
c01015cd:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01015d1:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01015d5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01015d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01015d9:	c1 e8 08             	shr    $0x8,%eax
c01015dc:	0f b6 c0             	movzbl %al,%eax
c01015df:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015e3:	83 c2 04             	add    $0x4,%edx
c01015e6:	0f b7 d2             	movzwl %dx,%edx
c01015e9:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01015ed:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01015f0:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01015f4:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01015f8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01015f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01015fc:	c1 e8 10             	shr    $0x10,%eax
c01015ff:	0f b6 c0             	movzbl %al,%eax
c0101602:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101606:	83 c2 05             	add    $0x5,%edx
c0101609:	0f b7 d2             	movzwl %dx,%edx
c010160c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101610:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101613:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101617:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010161b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010161c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010161f:	c0 e0 04             	shl    $0x4,%al
c0101622:	24 10                	and    $0x10,%al
c0101624:	88 c2                	mov    %al,%dl
c0101626:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101629:	c1 e8 18             	shr    $0x18,%eax
c010162c:	24 0f                	and    $0xf,%al
c010162e:	08 d0                	or     %dl,%al
c0101630:	0c e0                	or     $0xe0,%al
c0101632:	0f b6 c0             	movzbl %al,%eax
c0101635:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101639:	83 c2 06             	add    $0x6,%edx
c010163c:	0f b7 d2             	movzwl %dx,%edx
c010163f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101643:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101646:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010164a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010164e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010164f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101653:	83 c0 07             	add    $0x7,%eax
c0101656:	0f b7 c0             	movzwl %ax,%eax
c0101659:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010165d:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
c0101661:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101665:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101669:	ee                   	out    %al,(%dx)

    int ret = 0;
c010166a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101671:	eb 57                	jmp    c01016ca <ide_write_secs+0x226>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101673:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101677:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010167e:	00 
c010167f:	89 04 24             	mov    %eax,(%esp)
c0101682:	e8 12 f8 ff ff       	call   c0100e99 <ide_wait_ready>
c0101687:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010168a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010168e:	75 42                	jne    c01016d2 <ide_write_secs+0x22e>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101690:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101694:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101697:	8b 45 10             	mov    0x10(%ebp),%eax
c010169a:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010169d:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01016a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01016a7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01016aa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01016ad:	89 cb                	mov    %ecx,%ebx
c01016af:	89 de                	mov    %ebx,%esi
c01016b1:	89 c1                	mov    %eax,%ecx
c01016b3:	fc                   	cld    
c01016b4:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01016b6:	89 c8                	mov    %ecx,%eax
c01016b8:	89 f3                	mov    %esi,%ebx
c01016ba:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01016bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01016c0:	ff 4d 14             	decl   0x14(%ebp)
c01016c3:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01016ca:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01016ce:	75 a3                	jne    c0101673 <ide_write_secs+0x1cf>
    }

out:
c01016d0:	eb 01                	jmp    c01016d3 <ide_write_secs+0x22f>
            goto out;
c01016d2:	90                   	nop
    return ret;
c01016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d6:	83 c4 50             	add    $0x50,%esp
c01016d9:	5b                   	pop    %ebx
c01016da:	5e                   	pop    %esi
c01016db:	5d                   	pop    %ebp
c01016dc:	c3                   	ret    

c01016dd <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c01016dd:	55                   	push   %ebp
c01016de:	89 e5                	mov    %esp,%ebp
c01016e0:	83 ec 28             	sub    $0x28,%esp
c01016e3:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c01016e9:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016ed:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01016f1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01016f5:	ee                   	out    %al,(%dx)
c01016f6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c01016fc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101700:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101704:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101708:	ee                   	out    %al,(%dx)
c0101709:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c010170f:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0101713:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101717:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010171b:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c010171c:	c7 05 54 20 1a c0 00 	movl   $0x0,0xc01a2054
c0101723:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101726:	c7 04 24 46 c4 10 c0 	movl   $0xc010c446,(%esp)
c010172d:	e8 77 eb ff ff       	call   c01002a9 <cprintf>
    pic_enable(IRQ_TIMER);
c0101732:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101739:	e8 2e 09 00 00       	call   c010206c <pic_enable>
}
c010173e:	90                   	nop
c010173f:	c9                   	leave  
c0101740:	c3                   	ret    

c0101741 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0101741:	55                   	push   %ebp
c0101742:	89 e5                	mov    %esp,%ebp
c0101744:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101747:	9c                   	pushf  
c0101748:	58                   	pop    %eax
c0101749:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010174f:	25 00 02 00 00       	and    $0x200,%eax
c0101754:	85 c0                	test   %eax,%eax
c0101756:	74 0c                	je     c0101764 <__intr_save+0x23>
        intr_disable();
c0101758:	e8 83 0a 00 00       	call   c01021e0 <intr_disable>
        return 1;
c010175d:	b8 01 00 00 00       	mov    $0x1,%eax
c0101762:	eb 05                	jmp    c0101769 <__intr_save+0x28>
    }
    return 0;
c0101764:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101769:	c9                   	leave  
c010176a:	c3                   	ret    

c010176b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010176b:	55                   	push   %ebp
c010176c:	89 e5                	mov    %esp,%ebp
c010176e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101771:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101775:	74 05                	je     c010177c <__intr_restore+0x11>
        intr_enable();
c0101777:	e8 5d 0a 00 00       	call   c01021d9 <intr_enable>
    }
}
c010177c:	90                   	nop
c010177d:	c9                   	leave  
c010177e:	c3                   	ret    

c010177f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c010177f:	55                   	push   %ebp
c0101780:	89 e5                	mov    %esp,%ebp
c0101782:	83 ec 10             	sub    $0x10,%esp
c0101785:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010178b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010178f:	89 c2                	mov    %eax,%edx
c0101791:	ec                   	in     (%dx),%al
c0101792:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101795:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c010179b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010179f:	89 c2                	mov    %eax,%edx
c01017a1:	ec                   	in     (%dx),%al
c01017a2:	88 45 f5             	mov    %al,-0xb(%ebp)
c01017a5:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01017ab:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017af:	89 c2                	mov    %eax,%edx
c01017b1:	ec                   	in     (%dx),%al
c01017b2:	88 45 f9             	mov    %al,-0x7(%ebp)
c01017b5:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c01017bb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01017bf:	89 c2                	mov    %eax,%edx
c01017c1:	ec                   	in     (%dx),%al
c01017c2:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01017c5:	90                   	nop
c01017c6:	c9                   	leave  
c01017c7:	c3                   	ret    

c01017c8 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01017c8:	55                   	push   %ebp
c01017c9:	89 e5                	mov    %esp,%ebp
c01017cb:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01017ce:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01017d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017d8:	0f b7 00             	movzwl (%eax),%eax
c01017db:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c01017df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017e2:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c01017e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ea:	0f b7 00             	movzwl (%eax),%eax
c01017ed:	0f b7 c0             	movzwl %ax,%eax
c01017f0:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c01017f5:	74 12                	je     c0101809 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c01017f7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c01017fe:	66 c7 05 26 f5 19 c0 	movw   $0x3b4,0xc019f526
c0101805:	b4 03 
c0101807:	eb 13                	jmp    c010181c <cga_init+0x54>
    } else {
        *cp = was;
c0101809:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010180c:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101810:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101813:	66 c7 05 26 f5 19 c0 	movw   $0x3d4,0xc019f526
c010181a:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c010181c:	0f b7 05 26 f5 19 c0 	movzwl 0xc019f526,%eax
c0101823:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101827:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010182b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010182f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101833:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101834:	0f b7 05 26 f5 19 c0 	movzwl 0xc019f526,%eax
c010183b:	40                   	inc    %eax
c010183c:	0f b7 c0             	movzwl %ax,%eax
c010183f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101843:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101847:	89 c2                	mov    %eax,%edx
c0101849:	ec                   	in     (%dx),%al
c010184a:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c010184d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101851:	0f b6 c0             	movzbl %al,%eax
c0101854:	c1 e0 08             	shl    $0x8,%eax
c0101857:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010185a:	0f b7 05 26 f5 19 c0 	movzwl 0xc019f526,%eax
c0101861:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101865:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101869:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010186d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101871:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101872:	0f b7 05 26 f5 19 c0 	movzwl 0xc019f526,%eax
c0101879:	40                   	inc    %eax
c010187a:	0f b7 c0             	movzwl %ax,%eax
c010187d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101881:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101885:	89 c2                	mov    %eax,%edx
c0101887:	ec                   	in     (%dx),%al
c0101888:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c010188b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010188f:	0f b6 c0             	movzbl %al,%eax
c0101892:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101895:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101898:	a3 20 f5 19 c0       	mov    %eax,0xc019f520
    crt_pos = pos;
c010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018a0:	0f b7 c0             	movzwl %ax,%eax
c01018a3:	66 a3 24 f5 19 c0    	mov    %ax,0xc019f524
}
c01018a9:	90                   	nop
c01018aa:	c9                   	leave  
c01018ab:	c3                   	ret    

c01018ac <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01018ac:	55                   	push   %ebp
c01018ad:	89 e5                	mov    %esp,%ebp
c01018af:	83 ec 48             	sub    $0x48,%esp
c01018b2:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c01018b8:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018bc:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018c0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01018c4:	ee                   	out    %al,(%dx)
c01018c5:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c01018cb:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c01018cf:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01018d3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01018d7:	ee                   	out    %al,(%dx)
c01018d8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c01018de:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c01018e2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01018e6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01018ea:	ee                   	out    %al,(%dx)
c01018eb:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01018f1:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c01018f5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01018f9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01018fd:	ee                   	out    %al,(%dx)
c01018fe:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101904:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0101908:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010190c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101910:	ee                   	out    %al,(%dx)
c0101911:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101917:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c010191b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010191f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101923:	ee                   	out    %al,(%dx)
c0101924:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010192a:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c010192e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101932:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101936:	ee                   	out    %al,(%dx)
c0101937:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010193d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101941:	89 c2                	mov    %eax,%edx
c0101943:	ec                   	in     (%dx),%al
c0101944:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101947:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010194b:	3c ff                	cmp    $0xff,%al
c010194d:	0f 95 c0             	setne  %al
c0101950:	0f b6 c0             	movzbl %al,%eax
c0101953:	a3 28 f5 19 c0       	mov    %eax,0xc019f528
c0101958:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010195e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101962:	89 c2                	mov    %eax,%edx
c0101964:	ec                   	in     (%dx),%al
c0101965:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101968:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010196e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101972:	89 c2                	mov    %eax,%edx
c0101974:	ec                   	in     (%dx),%al
c0101975:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101978:	a1 28 f5 19 c0       	mov    0xc019f528,%eax
c010197d:	85 c0                	test   %eax,%eax
c010197f:	74 0c                	je     c010198d <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101981:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101988:	e8 df 06 00 00       	call   c010206c <pic_enable>
    }
}
c010198d:	90                   	nop
c010198e:	c9                   	leave  
c010198f:	c3                   	ret    

c0101990 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101990:	55                   	push   %ebp
c0101991:	89 e5                	mov    %esp,%ebp
c0101993:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101996:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010199d:	eb 08                	jmp    c01019a7 <lpt_putc_sub+0x17>
        delay();
c010199f:	e8 db fd ff ff       	call   c010177f <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019a4:	ff 45 fc             	incl   -0x4(%ebp)
c01019a7:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01019ad:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01019b1:	89 c2                	mov    %eax,%edx
c01019b3:	ec                   	in     (%dx),%al
c01019b4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01019b7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01019bb:	84 c0                	test   %al,%al
c01019bd:	78 09                	js     c01019c8 <lpt_putc_sub+0x38>
c01019bf:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01019c6:	7e d7                	jle    c010199f <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01019c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01019cb:	0f b6 c0             	movzbl %al,%eax
c01019ce:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01019d4:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019d7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01019db:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01019df:	ee                   	out    %al,(%dx)
c01019e0:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01019e6:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01019ea:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01019ee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01019f2:	ee                   	out    %al,(%dx)
c01019f3:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01019f9:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c01019fd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101a01:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a05:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101a06:	90                   	nop
c0101a07:	c9                   	leave  
c0101a08:	c3                   	ret    

c0101a09 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101a09:	55                   	push   %ebp
c0101a0a:	89 e5                	mov    %esp,%ebp
c0101a0c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101a0f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101a13:	74 0d                	je     c0101a22 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a18:	89 04 24             	mov    %eax,(%esp)
c0101a1b:	e8 70 ff ff ff       	call   c0101990 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101a20:	eb 24                	jmp    c0101a46 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101a22:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a29:	e8 62 ff ff ff       	call   c0101990 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101a2e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101a35:	e8 56 ff ff ff       	call   c0101990 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101a3a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a41:	e8 4a ff ff ff       	call   c0101990 <lpt_putc_sub>
}
c0101a46:	90                   	nop
c0101a47:	c9                   	leave  
c0101a48:	c3                   	ret    

c0101a49 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101a49:	55                   	push   %ebp
c0101a4a:	89 e5                	mov    %esp,%ebp
c0101a4c:	53                   	push   %ebx
c0101a4d:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101a50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a53:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101a58:	85 c0                	test   %eax,%eax
c0101a5a:	75 07                	jne    c0101a63 <cga_putc+0x1a>
        c |= 0x0700;
c0101a5c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a66:	0f b6 c0             	movzbl %al,%eax
c0101a69:	83 f8 0a             	cmp    $0xa,%eax
c0101a6c:	74 55                	je     c0101ac3 <cga_putc+0x7a>
c0101a6e:	83 f8 0d             	cmp    $0xd,%eax
c0101a71:	74 63                	je     c0101ad6 <cga_putc+0x8d>
c0101a73:	83 f8 08             	cmp    $0x8,%eax
c0101a76:	0f 85 94 00 00 00    	jne    c0101b10 <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101a7c:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101a83:	85 c0                	test   %eax,%eax
c0101a85:	0f 84 af 00 00 00    	je     c0101b3a <cga_putc+0xf1>
            crt_pos --;
c0101a8b:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101a92:	48                   	dec    %eax
c0101a93:	0f b7 c0             	movzwl %ax,%eax
c0101a96:	66 a3 24 f5 19 c0    	mov    %ax,0xc019f524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a9f:	98                   	cwtl   
c0101aa0:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101aa5:	98                   	cwtl   
c0101aa6:	83 c8 20             	or     $0x20,%eax
c0101aa9:	98                   	cwtl   
c0101aaa:	8b 15 20 f5 19 c0    	mov    0xc019f520,%edx
c0101ab0:	0f b7 0d 24 f5 19 c0 	movzwl 0xc019f524,%ecx
c0101ab7:	01 c9                	add    %ecx,%ecx
c0101ab9:	01 ca                	add    %ecx,%edx
c0101abb:	0f b7 c0             	movzwl %ax,%eax
c0101abe:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101ac1:	eb 77                	jmp    c0101b3a <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101ac3:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101aca:	83 c0 50             	add    $0x50,%eax
c0101acd:	0f b7 c0             	movzwl %ax,%eax
c0101ad0:	66 a3 24 f5 19 c0    	mov    %ax,0xc019f524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101ad6:	0f b7 1d 24 f5 19 c0 	movzwl 0xc019f524,%ebx
c0101add:	0f b7 0d 24 f5 19 c0 	movzwl 0xc019f524,%ecx
c0101ae4:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101ae9:	89 c8                	mov    %ecx,%eax
c0101aeb:	f7 e2                	mul    %edx
c0101aed:	c1 ea 06             	shr    $0x6,%edx
c0101af0:	89 d0                	mov    %edx,%eax
c0101af2:	c1 e0 02             	shl    $0x2,%eax
c0101af5:	01 d0                	add    %edx,%eax
c0101af7:	c1 e0 04             	shl    $0x4,%eax
c0101afa:	29 c1                	sub    %eax,%ecx
c0101afc:	89 c8                	mov    %ecx,%eax
c0101afe:	0f b7 c0             	movzwl %ax,%eax
c0101b01:	29 c3                	sub    %eax,%ebx
c0101b03:	89 d8                	mov    %ebx,%eax
c0101b05:	0f b7 c0             	movzwl %ax,%eax
c0101b08:	66 a3 24 f5 19 c0    	mov    %ax,0xc019f524
        break;
c0101b0e:	eb 2b                	jmp    c0101b3b <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101b10:	8b 0d 20 f5 19 c0    	mov    0xc019f520,%ecx
c0101b16:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101b1d:	8d 50 01             	lea    0x1(%eax),%edx
c0101b20:	0f b7 d2             	movzwl %dx,%edx
c0101b23:	66 89 15 24 f5 19 c0 	mov    %dx,0xc019f524
c0101b2a:	01 c0                	add    %eax,%eax
c0101b2c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b32:	0f b7 c0             	movzwl %ax,%eax
c0101b35:	66 89 02             	mov    %ax,(%edx)
        break;
c0101b38:	eb 01                	jmp    c0101b3b <cga_putc+0xf2>
        break;
c0101b3a:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101b3b:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101b42:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101b47:	76 5d                	jbe    c0101ba6 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101b49:	a1 20 f5 19 c0       	mov    0xc019f520,%eax
c0101b4e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101b54:	a1 20 f5 19 c0       	mov    0xc019f520,%eax
c0101b59:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101b60:	00 
c0101b61:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b65:	89 04 24             	mov    %eax,(%esp)
c0101b68:	e8 10 9c 00 00       	call   c010b77d <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101b6d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101b74:	eb 14                	jmp    c0101b8a <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101b76:	a1 20 f5 19 c0       	mov    0xc019f520,%eax
c0101b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101b7e:	01 d2                	add    %edx,%edx
c0101b80:	01 d0                	add    %edx,%eax
c0101b82:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101b87:	ff 45 f4             	incl   -0xc(%ebp)
c0101b8a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101b91:	7e e3                	jle    c0101b76 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101b93:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101b9a:	83 e8 50             	sub    $0x50,%eax
c0101b9d:	0f b7 c0             	movzwl %ax,%eax
c0101ba0:	66 a3 24 f5 19 c0    	mov    %ax,0xc019f524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101ba6:	0f b7 05 26 f5 19 c0 	movzwl 0xc019f526,%eax
c0101bad:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101bb1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101bb5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101bb9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101bbd:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101bbe:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101bc5:	c1 e8 08             	shr    $0x8,%eax
c0101bc8:	0f b7 c0             	movzwl %ax,%eax
c0101bcb:	0f b6 c0             	movzbl %al,%eax
c0101bce:	0f b7 15 26 f5 19 c0 	movzwl 0xc019f526,%edx
c0101bd5:	42                   	inc    %edx
c0101bd6:	0f b7 d2             	movzwl %dx,%edx
c0101bd9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101bdd:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101be0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101be4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101be8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101be9:	0f b7 05 26 f5 19 c0 	movzwl 0xc019f526,%eax
c0101bf0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101bf4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c0101bf8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101bfc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101c00:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101c01:	0f b7 05 24 f5 19 c0 	movzwl 0xc019f524,%eax
c0101c08:	0f b6 c0             	movzbl %al,%eax
c0101c0b:	0f b7 15 26 f5 19 c0 	movzwl 0xc019f526,%edx
c0101c12:	42                   	inc    %edx
c0101c13:	0f b7 d2             	movzwl %dx,%edx
c0101c16:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101c1a:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101c1d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101c21:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c25:	ee                   	out    %al,(%dx)
}
c0101c26:	90                   	nop
c0101c27:	83 c4 34             	add    $0x34,%esp
c0101c2a:	5b                   	pop    %ebx
c0101c2b:	5d                   	pop    %ebp
c0101c2c:	c3                   	ret    

c0101c2d <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101c2d:	55                   	push   %ebp
c0101c2e:	89 e5                	mov    %esp,%ebp
c0101c30:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101c3a:	eb 08                	jmp    c0101c44 <serial_putc_sub+0x17>
        delay();
c0101c3c:	e8 3e fb ff ff       	call   c010177f <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c41:	ff 45 fc             	incl   -0x4(%ebp)
c0101c44:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c4a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c4e:	89 c2                	mov    %eax,%edx
c0101c50:	ec                   	in     (%dx),%al
c0101c51:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c54:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101c58:	0f b6 c0             	movzbl %al,%eax
c0101c5b:	83 e0 20             	and    $0x20,%eax
c0101c5e:	85 c0                	test   %eax,%eax
c0101c60:	75 09                	jne    c0101c6b <serial_putc_sub+0x3e>
c0101c62:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101c69:	7e d1                	jle    c0101c3c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6e:	0f b6 c0             	movzbl %al,%eax
c0101c71:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101c77:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c7a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101c7e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101c82:	ee                   	out    %al,(%dx)
}
c0101c83:	90                   	nop
c0101c84:	c9                   	leave  
c0101c85:	c3                   	ret    

c0101c86 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101c86:	55                   	push   %ebp
c0101c87:	89 e5                	mov    %esp,%ebp
c0101c89:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101c8c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101c90:	74 0d                	je     c0101c9f <serial_putc+0x19>
        serial_putc_sub(c);
c0101c92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c95:	89 04 24             	mov    %eax,(%esp)
c0101c98:	e8 90 ff ff ff       	call   c0101c2d <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101c9d:	eb 24                	jmp    c0101cc3 <serial_putc+0x3d>
        serial_putc_sub('\b');
c0101c9f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101ca6:	e8 82 ff ff ff       	call   c0101c2d <serial_putc_sub>
        serial_putc_sub(' ');
c0101cab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101cb2:	e8 76 ff ff ff       	call   c0101c2d <serial_putc_sub>
        serial_putc_sub('\b');
c0101cb7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101cbe:	e8 6a ff ff ff       	call   c0101c2d <serial_putc_sub>
}
c0101cc3:	90                   	nop
c0101cc4:	c9                   	leave  
c0101cc5:	c3                   	ret    

c0101cc6 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101cc6:	55                   	push   %ebp
c0101cc7:	89 e5                	mov    %esp,%ebp
c0101cc9:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101ccc:	eb 33                	jmp    c0101d01 <cons_intr+0x3b>
        if (c != 0) {
c0101cce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101cd2:	74 2d                	je     c0101d01 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101cd4:	a1 44 f7 19 c0       	mov    0xc019f744,%eax
c0101cd9:	8d 50 01             	lea    0x1(%eax),%edx
c0101cdc:	89 15 44 f7 19 c0    	mov    %edx,0xc019f744
c0101ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101ce5:	88 90 40 f5 19 c0    	mov    %dl,-0x3fe60ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101ceb:	a1 44 f7 19 c0       	mov    0xc019f744,%eax
c0101cf0:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101cf5:	75 0a                	jne    c0101d01 <cons_intr+0x3b>
                cons.wpos = 0;
c0101cf7:	c7 05 44 f7 19 c0 00 	movl   $0x0,0xc019f744
c0101cfe:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d04:	ff d0                	call   *%eax
c0101d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d09:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101d0d:	75 bf                	jne    c0101cce <cons_intr+0x8>
            }
        }
    }
}
c0101d0f:	90                   	nop
c0101d10:	c9                   	leave  
c0101d11:	c3                   	ret    

c0101d12 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101d12:	55                   	push   %ebp
c0101d13:	89 e5                	mov    %esp,%ebp
c0101d15:	83 ec 10             	sub    $0x10,%esp
c0101d18:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d1e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101d22:	89 c2                	mov    %eax,%edx
c0101d24:	ec                   	in     (%dx),%al
c0101d25:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101d28:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101d2c:	0f b6 c0             	movzbl %al,%eax
c0101d2f:	83 e0 01             	and    $0x1,%eax
c0101d32:	85 c0                	test   %eax,%eax
c0101d34:	75 07                	jne    c0101d3d <serial_proc_data+0x2b>
        return -1;
c0101d36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d3b:	eb 2a                	jmp    c0101d67 <serial_proc_data+0x55>
c0101d3d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d43:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101d47:	89 c2                	mov    %eax,%edx
c0101d49:	ec                   	in     (%dx),%al
c0101d4a:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101d4d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101d51:	0f b6 c0             	movzbl %al,%eax
c0101d54:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101d57:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101d5b:	75 07                	jne    c0101d64 <serial_proc_data+0x52>
        c = '\b';
c0101d5d:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101d64:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101d67:	c9                   	leave  
c0101d68:	c3                   	ret    

c0101d69 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101d69:	55                   	push   %ebp
c0101d6a:	89 e5                	mov    %esp,%ebp
c0101d6c:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101d6f:	a1 28 f5 19 c0       	mov    0xc019f528,%eax
c0101d74:	85 c0                	test   %eax,%eax
c0101d76:	74 0c                	je     c0101d84 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101d78:	c7 04 24 12 1d 10 c0 	movl   $0xc0101d12,(%esp)
c0101d7f:	e8 42 ff ff ff       	call   c0101cc6 <cons_intr>
    }
}
c0101d84:	90                   	nop
c0101d85:	c9                   	leave  
c0101d86:	c3                   	ret    

c0101d87 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101d87:	55                   	push   %ebp
c0101d88:	89 e5                	mov    %esp,%ebp
c0101d8a:	83 ec 38             	sub    $0x38,%esp
c0101d8d:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101d96:	89 c2                	mov    %eax,%edx
c0101d98:	ec                   	in     (%dx),%al
c0101d99:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101d9c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101da0:	0f b6 c0             	movzbl %al,%eax
c0101da3:	83 e0 01             	and    $0x1,%eax
c0101da6:	85 c0                	test   %eax,%eax
c0101da8:	75 0a                	jne    c0101db4 <kbd_proc_data+0x2d>
        return -1;
c0101daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101daf:	e9 55 01 00 00       	jmp    c0101f09 <kbd_proc_data+0x182>
c0101db4:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101dbd:	89 c2                	mov    %eax,%edx
c0101dbf:	ec                   	in     (%dx),%al
c0101dc0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101dc3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101dc7:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101dca:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101dce:	75 17                	jne    c0101de7 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101dd0:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101dd5:	83 c8 40             	or     $0x40,%eax
c0101dd8:	a3 48 f7 19 c0       	mov    %eax,0xc019f748
        return 0;
c0101ddd:	b8 00 00 00 00       	mov    $0x0,%eax
c0101de2:	e9 22 01 00 00       	jmp    c0101f09 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c0101de7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101deb:	84 c0                	test   %al,%al
c0101ded:	79 45                	jns    c0101e34 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101def:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101df4:	83 e0 40             	and    $0x40,%eax
c0101df7:	85 c0                	test   %eax,%eax
c0101df9:	75 08                	jne    c0101e03 <kbd_proc_data+0x7c>
c0101dfb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dff:	24 7f                	and    $0x7f,%al
c0101e01:	eb 04                	jmp    c0101e07 <kbd_proc_data+0x80>
c0101e03:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e07:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101e0a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e0e:	0f b6 80 40 b0 12 c0 	movzbl -0x3fed4fc0(%eax),%eax
c0101e15:	0c 40                	or     $0x40,%al
c0101e17:	0f b6 c0             	movzbl %al,%eax
c0101e1a:	f7 d0                	not    %eax
c0101e1c:	89 c2                	mov    %eax,%edx
c0101e1e:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101e23:	21 d0                	and    %edx,%eax
c0101e25:	a3 48 f7 19 c0       	mov    %eax,0xc019f748
        return 0;
c0101e2a:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e2f:	e9 d5 00 00 00       	jmp    c0101f09 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c0101e34:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101e39:	83 e0 40             	and    $0x40,%eax
c0101e3c:	85 c0                	test   %eax,%eax
c0101e3e:	74 11                	je     c0101e51 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101e40:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101e44:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101e49:	83 e0 bf             	and    $0xffffffbf,%eax
c0101e4c:	a3 48 f7 19 c0       	mov    %eax,0xc019f748
    }

    shift |= shiftcode[data];
c0101e51:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e55:	0f b6 80 40 b0 12 c0 	movzbl -0x3fed4fc0(%eax),%eax
c0101e5c:	0f b6 d0             	movzbl %al,%edx
c0101e5f:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101e64:	09 d0                	or     %edx,%eax
c0101e66:	a3 48 f7 19 c0       	mov    %eax,0xc019f748
    shift ^= togglecode[data];
c0101e6b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e6f:	0f b6 80 40 b1 12 c0 	movzbl -0x3fed4ec0(%eax),%eax
c0101e76:	0f b6 d0             	movzbl %al,%edx
c0101e79:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101e7e:	31 d0                	xor    %edx,%eax
c0101e80:	a3 48 f7 19 c0       	mov    %eax,0xc019f748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101e85:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101e8a:	83 e0 03             	and    $0x3,%eax
c0101e8d:	8b 14 85 40 b5 12 c0 	mov    -0x3fed4ac0(,%eax,4),%edx
c0101e94:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e98:	01 d0                	add    %edx,%eax
c0101e9a:	0f b6 00             	movzbl (%eax),%eax
c0101e9d:	0f b6 c0             	movzbl %al,%eax
c0101ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101ea3:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101ea8:	83 e0 08             	and    $0x8,%eax
c0101eab:	85 c0                	test   %eax,%eax
c0101ead:	74 22                	je     c0101ed1 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101eaf:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101eb3:	7e 0c                	jle    c0101ec1 <kbd_proc_data+0x13a>
c0101eb5:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101eb9:	7f 06                	jg     c0101ec1 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101ebb:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101ebf:	eb 10                	jmp    c0101ed1 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101ec1:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101ec5:	7e 0a                	jle    c0101ed1 <kbd_proc_data+0x14a>
c0101ec7:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101ecb:	7f 04                	jg     c0101ed1 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101ecd:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101ed1:	a1 48 f7 19 c0       	mov    0xc019f748,%eax
c0101ed6:	f7 d0                	not    %eax
c0101ed8:	83 e0 06             	and    $0x6,%eax
c0101edb:	85 c0                	test   %eax,%eax
c0101edd:	75 27                	jne    c0101f06 <kbd_proc_data+0x17f>
c0101edf:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101ee6:	75 1e                	jne    c0101f06 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c0101ee8:	c7 04 24 61 c4 10 c0 	movl   $0xc010c461,(%esp)
c0101eef:	e8 b5 e3 ff ff       	call   c01002a9 <cprintf>
c0101ef4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101efa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101efe:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101f02:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101f05:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f09:	c9                   	leave  
c0101f0a:	c3                   	ret    

c0101f0b <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101f0b:	55                   	push   %ebp
c0101f0c:	89 e5                	mov    %esp,%ebp
c0101f0e:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101f11:	c7 04 24 87 1d 10 c0 	movl   $0xc0101d87,(%esp)
c0101f18:	e8 a9 fd ff ff       	call   c0101cc6 <cons_intr>
}
c0101f1d:	90                   	nop
c0101f1e:	c9                   	leave  
c0101f1f:	c3                   	ret    

c0101f20 <kbd_init>:

static void
kbd_init(void) {
c0101f20:	55                   	push   %ebp
c0101f21:	89 e5                	mov    %esp,%ebp
c0101f23:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101f26:	e8 e0 ff ff ff       	call   c0101f0b <kbd_intr>
    pic_enable(IRQ_KBD);
c0101f2b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101f32:	e8 35 01 00 00       	call   c010206c <pic_enable>
}
c0101f37:	90                   	nop
c0101f38:	c9                   	leave  
c0101f39:	c3                   	ret    

c0101f3a <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101f3a:	55                   	push   %ebp
c0101f3b:	89 e5                	mov    %esp,%ebp
c0101f3d:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101f40:	e8 83 f8 ff ff       	call   c01017c8 <cga_init>
    serial_init();
c0101f45:	e8 62 f9 ff ff       	call   c01018ac <serial_init>
    kbd_init();
c0101f4a:	e8 d1 ff ff ff       	call   c0101f20 <kbd_init>
    if (!serial_exists) {
c0101f4f:	a1 28 f5 19 c0       	mov    0xc019f528,%eax
c0101f54:	85 c0                	test   %eax,%eax
c0101f56:	75 0c                	jne    c0101f64 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101f58:	c7 04 24 6d c4 10 c0 	movl   $0xc010c46d,(%esp)
c0101f5f:	e8 45 e3 ff ff       	call   c01002a9 <cprintf>
    }
}
c0101f64:	90                   	nop
c0101f65:	c9                   	leave  
c0101f66:	c3                   	ret    

c0101f67 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101f67:	55                   	push   %ebp
c0101f68:	89 e5                	mov    %esp,%ebp
c0101f6a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101f6d:	e8 cf f7 ff ff       	call   c0101741 <__intr_save>
c0101f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101f75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f78:	89 04 24             	mov    %eax,(%esp)
c0101f7b:	e8 89 fa ff ff       	call   c0101a09 <lpt_putc>
        cga_putc(c);
c0101f80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f83:	89 04 24             	mov    %eax,(%esp)
c0101f86:	e8 be fa ff ff       	call   c0101a49 <cga_putc>
        serial_putc(c);
c0101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8e:	89 04 24             	mov    %eax,(%esp)
c0101f91:	e8 f0 fc ff ff       	call   c0101c86 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f99:	89 04 24             	mov    %eax,(%esp)
c0101f9c:	e8 ca f7 ff ff       	call   c010176b <__intr_restore>
}
c0101fa1:	90                   	nop
c0101fa2:	c9                   	leave  
c0101fa3:	c3                   	ret    

c0101fa4 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101fa4:	55                   	push   %ebp
c0101fa5:	89 e5                	mov    %esp,%ebp
c0101fa7:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101faa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101fb1:	e8 8b f7 ff ff       	call   c0101741 <__intr_save>
c0101fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101fb9:	e8 ab fd ff ff       	call   c0101d69 <serial_intr>
        kbd_intr();
c0101fbe:	e8 48 ff ff ff       	call   c0101f0b <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101fc3:	8b 15 40 f7 19 c0    	mov    0xc019f740,%edx
c0101fc9:	a1 44 f7 19 c0       	mov    0xc019f744,%eax
c0101fce:	39 c2                	cmp    %eax,%edx
c0101fd0:	74 31                	je     c0102003 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101fd2:	a1 40 f7 19 c0       	mov    0xc019f740,%eax
c0101fd7:	8d 50 01             	lea    0x1(%eax),%edx
c0101fda:	89 15 40 f7 19 c0    	mov    %edx,0xc019f740
c0101fe0:	0f b6 80 40 f5 19 c0 	movzbl -0x3fe60ac0(%eax),%eax
c0101fe7:	0f b6 c0             	movzbl %al,%eax
c0101fea:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101fed:	a1 40 f7 19 c0       	mov    0xc019f740,%eax
c0101ff2:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101ff7:	75 0a                	jne    c0102003 <cons_getc+0x5f>
                cons.rpos = 0;
c0101ff9:	c7 05 40 f7 19 c0 00 	movl   $0x0,0xc019f740
c0102000:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0102003:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102006:	89 04 24             	mov    %eax,(%esp)
c0102009:	e8 5d f7 ff ff       	call   c010176b <__intr_restore>
    return c;
c010200e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102011:	c9                   	leave  
c0102012:	c3                   	ret    

c0102013 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102013:	55                   	push   %ebp
c0102014:	89 e5                	mov    %esp,%ebp
c0102016:	83 ec 14             	sub    $0x14,%esp
c0102019:	8b 45 08             	mov    0x8(%ebp),%eax
c010201c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102020:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102023:	66 a3 50 b5 12 c0    	mov    %ax,0xc012b550
    if (did_init) {
c0102029:	a1 4c f7 19 c0       	mov    0xc019f74c,%eax
c010202e:	85 c0                	test   %eax,%eax
c0102030:	74 37                	je     c0102069 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0102032:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102035:	0f b6 c0             	movzbl %al,%eax
c0102038:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c010203e:	88 45 f9             	mov    %al,-0x7(%ebp)
c0102041:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102045:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102049:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010204a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010204e:	c1 e8 08             	shr    $0x8,%eax
c0102051:	0f b7 c0             	movzwl %ax,%eax
c0102054:	0f b6 c0             	movzbl %al,%eax
c0102057:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010205d:	88 45 fd             	mov    %al,-0x3(%ebp)
c0102060:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102064:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102068:	ee                   	out    %al,(%dx)
    }
}
c0102069:	90                   	nop
c010206a:	c9                   	leave  
c010206b:	c3                   	ret    

c010206c <pic_enable>:

void
pic_enable(unsigned int irq) {
c010206c:	55                   	push   %ebp
c010206d:	89 e5                	mov    %esp,%ebp
c010206f:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102072:	8b 45 08             	mov    0x8(%ebp),%eax
c0102075:	ba 01 00 00 00       	mov    $0x1,%edx
c010207a:	88 c1                	mov    %al,%cl
c010207c:	d3 e2                	shl    %cl,%edx
c010207e:	89 d0                	mov    %edx,%eax
c0102080:	98                   	cwtl   
c0102081:	f7 d0                	not    %eax
c0102083:	0f bf d0             	movswl %ax,%edx
c0102086:	0f b7 05 50 b5 12 c0 	movzwl 0xc012b550,%eax
c010208d:	98                   	cwtl   
c010208e:	21 d0                	and    %edx,%eax
c0102090:	98                   	cwtl   
c0102091:	0f b7 c0             	movzwl %ax,%eax
c0102094:	89 04 24             	mov    %eax,(%esp)
c0102097:	e8 77 ff ff ff       	call   c0102013 <pic_setmask>
}
c010209c:	90                   	nop
c010209d:	c9                   	leave  
c010209e:	c3                   	ret    

c010209f <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010209f:	55                   	push   %ebp
c01020a0:	89 e5                	mov    %esp,%ebp
c01020a2:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020a5:	c7 05 4c f7 19 c0 01 	movl   $0x1,0xc019f74c
c01020ac:	00 00 00 
c01020af:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01020b5:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c01020b9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020bd:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01020c1:	ee                   	out    %al,(%dx)
c01020c2:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01020c8:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c01020cc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020d0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020d4:	ee                   	out    %al,(%dx)
c01020d5:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020db:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c01020df:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020e3:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020e7:	ee                   	out    %al,(%dx)
c01020e8:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01020ee:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c01020f2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020f6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020fa:	ee                   	out    %al,(%dx)
c01020fb:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0102101:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c0102105:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102109:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010210d:	ee                   	out    %al,(%dx)
c010210e:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c0102114:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c0102118:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010211c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102120:	ee                   	out    %al,(%dx)
c0102121:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0102127:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c010212b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010212f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102133:	ee                   	out    %al,(%dx)
c0102134:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c010213a:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c010213e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102142:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102146:	ee                   	out    %al,(%dx)
c0102147:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010214d:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c0102151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102155:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102159:	ee                   	out    %al,(%dx)
c010215a:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102160:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c0102164:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102168:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010216c:	ee                   	out    %al,(%dx)
c010216d:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0102173:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0102177:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010217b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010217f:	ee                   	out    %al,(%dx)
c0102180:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102186:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c010218a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010218e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102192:	ee                   	out    %al,(%dx)
c0102193:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102199:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c010219d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01021a1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01021a5:	ee                   	out    %al,(%dx)
c01021a6:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01021ac:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c01021b0:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01021b4:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01021b8:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021b9:	0f b7 05 50 b5 12 c0 	movzwl 0xc012b550,%eax
c01021c0:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01021c5:	74 0f                	je     c01021d6 <pic_init+0x137>
        pic_setmask(irq_mask);
c01021c7:	0f b7 05 50 b5 12 c0 	movzwl 0xc012b550,%eax
c01021ce:	89 04 24             	mov    %eax,(%esp)
c01021d1:	e8 3d fe ff ff       	call   c0102013 <pic_setmask>
    }
}
c01021d6:	90                   	nop
c01021d7:	c9                   	leave  
c01021d8:	c3                   	ret    

c01021d9 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01021d9:	55                   	push   %ebp
c01021da:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01021dc:	fb                   	sti    
    sti();
}
c01021dd:	90                   	nop
c01021de:	5d                   	pop    %ebp
c01021df:	c3                   	ret    

c01021e0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01021e0:	55                   	push   %ebp
c01021e1:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01021e3:	fa                   	cli    
    cli();
}
c01021e4:	90                   	nop
c01021e5:	5d                   	pop    %ebp
c01021e6:	c3                   	ret    

c01021e7 <print_ticks>:
#include <sched.h>
#include <sync.h>

#define TICK_NUM 100

static void print_ticks() {
c01021e7:	55                   	push   %ebp
c01021e8:	89 e5                	mov    %esp,%ebp
c01021ea:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021ed:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01021f4:	00 
c01021f5:	c7 04 24 a0 c4 10 c0 	movl   $0xc010c4a0,(%esp)
c01021fc:	e8 a8 e0 ff ff       	call   c01002a9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102201:	90                   	nop
c0102202:	c9                   	leave  
c0102203:	c3                   	ret    

c0102204 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102204:	55                   	push   %ebp
c0102205:	89 e5                	mov    %esp,%ebp
c0102207:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010220a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102211:	e9 c4 00 00 00       	jmp    c01022da <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102216:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102219:	8b 04 85 e0 b5 12 c0 	mov    -0x3fed4a20(,%eax,4),%eax
c0102220:	0f b7 d0             	movzwl %ax,%edx
c0102223:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102226:	66 89 14 c5 60 f7 19 	mov    %dx,-0x3fe608a0(,%eax,8)
c010222d:	c0 
c010222e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102231:	66 c7 04 c5 62 f7 19 	movw   $0x8,-0x3fe6089e(,%eax,8)
c0102238:	c0 08 00 
c010223b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010223e:	0f b6 14 c5 64 f7 19 	movzbl -0x3fe6089c(,%eax,8),%edx
c0102245:	c0 
c0102246:	80 e2 e0             	and    $0xe0,%dl
c0102249:	88 14 c5 64 f7 19 c0 	mov    %dl,-0x3fe6089c(,%eax,8)
c0102250:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102253:	0f b6 14 c5 64 f7 19 	movzbl -0x3fe6089c(,%eax,8),%edx
c010225a:	c0 
c010225b:	80 e2 1f             	and    $0x1f,%dl
c010225e:	88 14 c5 64 f7 19 c0 	mov    %dl,-0x3fe6089c(,%eax,8)
c0102265:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102268:	0f b6 14 c5 65 f7 19 	movzbl -0x3fe6089b(,%eax,8),%edx
c010226f:	c0 
c0102270:	80 e2 f0             	and    $0xf0,%dl
c0102273:	80 ca 0e             	or     $0xe,%dl
c0102276:	88 14 c5 65 f7 19 c0 	mov    %dl,-0x3fe6089b(,%eax,8)
c010227d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102280:	0f b6 14 c5 65 f7 19 	movzbl -0x3fe6089b(,%eax,8),%edx
c0102287:	c0 
c0102288:	80 e2 ef             	and    $0xef,%dl
c010228b:	88 14 c5 65 f7 19 c0 	mov    %dl,-0x3fe6089b(,%eax,8)
c0102292:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102295:	0f b6 14 c5 65 f7 19 	movzbl -0x3fe6089b(,%eax,8),%edx
c010229c:	c0 
c010229d:	80 e2 9f             	and    $0x9f,%dl
c01022a0:	88 14 c5 65 f7 19 c0 	mov    %dl,-0x3fe6089b(,%eax,8)
c01022a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022aa:	0f b6 14 c5 65 f7 19 	movzbl -0x3fe6089b(,%eax,8),%edx
c01022b1:	c0 
c01022b2:	80 ca 80             	or     $0x80,%dl
c01022b5:	88 14 c5 65 f7 19 c0 	mov    %dl,-0x3fe6089b(,%eax,8)
c01022bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022bf:	8b 04 85 e0 b5 12 c0 	mov    -0x3fed4a20(,%eax,4),%eax
c01022c6:	c1 e8 10             	shr    $0x10,%eax
c01022c9:	0f b7 d0             	movzwl %ax,%edx
c01022cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022cf:	66 89 14 c5 66 f7 19 	mov    %dx,-0x3fe6089a(,%eax,8)
c01022d6:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01022d7:	ff 45 fc             	incl   -0x4(%ebp)
c01022da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022dd:	3d ff 00 00 00       	cmp    $0xff,%eax
c01022e2:	0f 86 2e ff ff ff    	jbe    c0102216 <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL],1,GD_KTEXT,__vectors[T_SYSCALL],DPL_USER);
c01022e8:	a1 e0 b7 12 c0       	mov    0xc012b7e0,%eax
c01022ed:	0f b7 c0             	movzwl %ax,%eax
c01022f0:	66 a3 60 fb 19 c0    	mov    %ax,0xc019fb60
c01022f6:	66 c7 05 62 fb 19 c0 	movw   $0x8,0xc019fb62
c01022fd:	08 00 
c01022ff:	0f b6 05 64 fb 19 c0 	movzbl 0xc019fb64,%eax
c0102306:	24 e0                	and    $0xe0,%al
c0102308:	a2 64 fb 19 c0       	mov    %al,0xc019fb64
c010230d:	0f b6 05 64 fb 19 c0 	movzbl 0xc019fb64,%eax
c0102314:	24 1f                	and    $0x1f,%al
c0102316:	a2 64 fb 19 c0       	mov    %al,0xc019fb64
c010231b:	0f b6 05 65 fb 19 c0 	movzbl 0xc019fb65,%eax
c0102322:	0c 0f                	or     $0xf,%al
c0102324:	a2 65 fb 19 c0       	mov    %al,0xc019fb65
c0102329:	0f b6 05 65 fb 19 c0 	movzbl 0xc019fb65,%eax
c0102330:	24 ef                	and    $0xef,%al
c0102332:	a2 65 fb 19 c0       	mov    %al,0xc019fb65
c0102337:	0f b6 05 65 fb 19 c0 	movzbl 0xc019fb65,%eax
c010233e:	0c 60                	or     $0x60,%al
c0102340:	a2 65 fb 19 c0       	mov    %al,0xc019fb65
c0102345:	0f b6 05 65 fb 19 c0 	movzbl 0xc019fb65,%eax
c010234c:	0c 80                	or     $0x80,%al
c010234e:	a2 65 fb 19 c0       	mov    %al,0xc019fb65
c0102353:	a1 e0 b7 12 c0       	mov    0xc012b7e0,%eax
c0102358:	c1 e8 10             	shr    $0x10,%eax
c010235b:	0f b7 c0             	movzwl %ax,%eax
c010235e:	66 a3 66 fb 19 c0    	mov    %ax,0xc019fb66
c0102364:	c7 45 f8 60 b5 12 c0 	movl   $0xc012b560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010236b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010236e:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0102371:	90                   	nop
c0102372:	c9                   	leave  
c0102373:	c3                   	ret    

c0102374 <trapname>:

static const char *
trapname(int trapno) {
c0102374:	55                   	push   %ebp
c0102375:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102377:	8b 45 08             	mov    0x8(%ebp),%eax
c010237a:	83 f8 13             	cmp    $0x13,%eax
c010237d:	77 0c                	ja     c010238b <trapname+0x17>
        return excnames[trapno];
c010237f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102382:	8b 04 85 40 c9 10 c0 	mov    -0x3fef36c0(,%eax,4),%eax
c0102389:	eb 18                	jmp    c01023a3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010238b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010238f:	7e 0d                	jle    c010239e <trapname+0x2a>
c0102391:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102395:	7f 07                	jg     c010239e <trapname+0x2a>
        return "Hardware Interrupt";
c0102397:	b8 aa c4 10 c0       	mov    $0xc010c4aa,%eax
c010239c:	eb 05                	jmp    c01023a3 <trapname+0x2f>
    }
    return "(unknown trap)";
c010239e:	b8 bd c4 10 c0       	mov    $0xc010c4bd,%eax
}
c01023a3:	5d                   	pop    %ebp
c01023a4:	c3                   	ret    

c01023a5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023a5:	55                   	push   %ebp
c01023a6:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ab:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023af:	83 f8 08             	cmp    $0x8,%eax
c01023b2:	0f 94 c0             	sete   %al
c01023b5:	0f b6 c0             	movzbl %al,%eax
}
c01023b8:	5d                   	pop    %ebp
c01023b9:	c3                   	ret    

c01023ba <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023ba:	55                   	push   %ebp
c01023bb:	89 e5                	mov    %esp,%ebp
c01023bd:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c7:	c7 04 24 fe c4 10 c0 	movl   $0xc010c4fe,(%esp)
c01023ce:	e8 d6 de ff ff       	call   c01002a9 <cprintf>
    print_regs(&tf->tf_regs);
c01023d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d6:	89 04 24             	mov    %eax,(%esp)
c01023d9:	e8 8f 01 00 00       	call   c010256d <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023de:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e1:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023e9:	c7 04 24 0f c5 10 c0 	movl   $0xc010c50f,(%esp)
c01023f0:	e8 b4 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f8:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102400:	c7 04 24 22 c5 10 c0 	movl   $0xc010c522,(%esp)
c0102407:	e8 9d de ff ff       	call   c01002a9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010240c:	8b 45 08             	mov    0x8(%ebp),%eax
c010240f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102413:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102417:	c7 04 24 35 c5 10 c0 	movl   $0xc010c535,(%esp)
c010241e:	e8 86 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102423:	8b 45 08             	mov    0x8(%ebp),%eax
c0102426:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010242a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010242e:	c7 04 24 48 c5 10 c0 	movl   $0xc010c548,(%esp)
c0102435:	e8 6f de ff ff       	call   c01002a9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010243a:	8b 45 08             	mov    0x8(%ebp),%eax
c010243d:	8b 40 30             	mov    0x30(%eax),%eax
c0102440:	89 04 24             	mov    %eax,(%esp)
c0102443:	e8 2c ff ff ff       	call   c0102374 <trapname>
c0102448:	89 c2                	mov    %eax,%edx
c010244a:	8b 45 08             	mov    0x8(%ebp),%eax
c010244d:	8b 40 30             	mov    0x30(%eax),%eax
c0102450:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102454:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102458:	c7 04 24 5b c5 10 c0 	movl   $0xc010c55b,(%esp)
c010245f:	e8 45 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102464:	8b 45 08             	mov    0x8(%ebp),%eax
c0102467:	8b 40 34             	mov    0x34(%eax),%eax
c010246a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246e:	c7 04 24 6d c5 10 c0 	movl   $0xc010c56d,(%esp)
c0102475:	e8 2f de ff ff       	call   c01002a9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010247a:	8b 45 08             	mov    0x8(%ebp),%eax
c010247d:	8b 40 38             	mov    0x38(%eax),%eax
c0102480:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102484:	c7 04 24 7c c5 10 c0 	movl   $0xc010c57c,(%esp)
c010248b:	e8 19 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102490:	8b 45 08             	mov    0x8(%ebp),%eax
c0102493:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102497:	89 44 24 04          	mov    %eax,0x4(%esp)
c010249b:	c7 04 24 8b c5 10 c0 	movl   $0xc010c58b,(%esp)
c01024a2:	e8 02 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024aa:	8b 40 40             	mov    0x40(%eax),%eax
c01024ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b1:	c7 04 24 9e c5 10 c0 	movl   $0xc010c59e,(%esp)
c01024b8:	e8 ec dd ff ff       	call   c01002a9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01024c4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01024cb:	eb 3d                	jmp    c010250a <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01024cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d0:	8b 50 40             	mov    0x40(%eax),%edx
c01024d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01024d6:	21 d0                	and    %edx,%eax
c01024d8:	85 c0                	test   %eax,%eax
c01024da:	74 28                	je     c0102504 <print_trapframe+0x14a>
c01024dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024df:	8b 04 85 80 b5 12 c0 	mov    -0x3fed4a80(,%eax,4),%eax
c01024e6:	85 c0                	test   %eax,%eax
c01024e8:	74 1a                	je     c0102504 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c01024ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024ed:	8b 04 85 80 b5 12 c0 	mov    -0x3fed4a80(,%eax,4),%eax
c01024f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f8:	c7 04 24 ad c5 10 c0 	movl   $0xc010c5ad,(%esp)
c01024ff:	e8 a5 dd ff ff       	call   c01002a9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102504:	ff 45 f4             	incl   -0xc(%ebp)
c0102507:	d1 65 f0             	shll   -0x10(%ebp)
c010250a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010250d:	83 f8 17             	cmp    $0x17,%eax
c0102510:	76 bb                	jbe    c01024cd <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102512:	8b 45 08             	mov    0x8(%ebp),%eax
c0102515:	8b 40 40             	mov    0x40(%eax),%eax
c0102518:	c1 e8 0c             	shr    $0xc,%eax
c010251b:	83 e0 03             	and    $0x3,%eax
c010251e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102522:	c7 04 24 b1 c5 10 c0 	movl   $0xc010c5b1,(%esp)
c0102529:	e8 7b dd ff ff       	call   c01002a9 <cprintf>

    if (!trap_in_kernel(tf)) {
c010252e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102531:	89 04 24             	mov    %eax,(%esp)
c0102534:	e8 6c fe ff ff       	call   c01023a5 <trap_in_kernel>
c0102539:	85 c0                	test   %eax,%eax
c010253b:	75 2d                	jne    c010256a <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010253d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102540:	8b 40 44             	mov    0x44(%eax),%eax
c0102543:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102547:	c7 04 24 ba c5 10 c0 	movl   $0xc010c5ba,(%esp)
c010254e:	e8 56 dd ff ff       	call   c01002a9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102553:	8b 45 08             	mov    0x8(%ebp),%eax
c0102556:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010255a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255e:	c7 04 24 c9 c5 10 c0 	movl   $0xc010c5c9,(%esp)
c0102565:	e8 3f dd ff ff       	call   c01002a9 <cprintf>
    }
}
c010256a:	90                   	nop
c010256b:	c9                   	leave  
c010256c:	c3                   	ret    

c010256d <print_regs>:

void
print_regs(struct pushregs *regs) {
c010256d:	55                   	push   %ebp
c010256e:	89 e5                	mov    %esp,%ebp
c0102570:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102573:	8b 45 08             	mov    0x8(%ebp),%eax
c0102576:	8b 00                	mov    (%eax),%eax
c0102578:	89 44 24 04          	mov    %eax,0x4(%esp)
c010257c:	c7 04 24 dc c5 10 c0 	movl   $0xc010c5dc,(%esp)
c0102583:	e8 21 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102588:	8b 45 08             	mov    0x8(%ebp),%eax
c010258b:	8b 40 04             	mov    0x4(%eax),%eax
c010258e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102592:	c7 04 24 eb c5 10 c0 	movl   $0xc010c5eb,(%esp)
c0102599:	e8 0b dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c010259e:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a1:	8b 40 08             	mov    0x8(%eax),%eax
c01025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a8:	c7 04 24 fa c5 10 c0 	movl   $0xc010c5fa,(%esp)
c01025af:	e8 f5 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b7:	8b 40 0c             	mov    0xc(%eax),%eax
c01025ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025be:	c7 04 24 09 c6 10 c0 	movl   $0xc010c609,(%esp)
c01025c5:	e8 df dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01025ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01025cd:	8b 40 10             	mov    0x10(%eax),%eax
c01025d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d4:	c7 04 24 18 c6 10 c0 	movl   $0xc010c618,(%esp)
c01025db:	e8 c9 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01025e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e3:	8b 40 14             	mov    0x14(%eax),%eax
c01025e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ea:	c7 04 24 27 c6 10 c0 	movl   $0xc010c627,(%esp)
c01025f1:	e8 b3 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01025f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f9:	8b 40 18             	mov    0x18(%eax),%eax
c01025fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102600:	c7 04 24 36 c6 10 c0 	movl   $0xc010c636,(%esp)
c0102607:	e8 9d dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010260c:	8b 45 08             	mov    0x8(%ebp),%eax
c010260f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102612:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102616:	c7 04 24 45 c6 10 c0 	movl   $0xc010c645,(%esp)
c010261d:	e8 87 dc ff ff       	call   c01002a9 <cprintf>
}
c0102622:	90                   	nop
c0102623:	c9                   	leave  
c0102624:	c3                   	ret    

c0102625 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102625:	55                   	push   %ebp
c0102626:	89 e5                	mov    %esp,%ebp
c0102628:	53                   	push   %ebx
c0102629:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010262c:	8b 45 08             	mov    0x8(%ebp),%eax
c010262f:	8b 40 34             	mov    0x34(%eax),%eax
c0102632:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102635:	85 c0                	test   %eax,%eax
c0102637:	74 07                	je     c0102640 <print_pgfault+0x1b>
c0102639:	bb 54 c6 10 c0       	mov    $0xc010c654,%ebx
c010263e:	eb 05                	jmp    c0102645 <print_pgfault+0x20>
c0102640:	bb 65 c6 10 c0       	mov    $0xc010c665,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c0102645:	8b 45 08             	mov    0x8(%ebp),%eax
c0102648:	8b 40 34             	mov    0x34(%eax),%eax
c010264b:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010264e:	85 c0                	test   %eax,%eax
c0102650:	74 07                	je     c0102659 <print_pgfault+0x34>
c0102652:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102657:	eb 05                	jmp    c010265e <print_pgfault+0x39>
c0102659:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c010265e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102661:	8b 40 34             	mov    0x34(%eax),%eax
c0102664:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102667:	85 c0                	test   %eax,%eax
c0102669:	74 07                	je     c0102672 <print_pgfault+0x4d>
c010266b:	ba 55 00 00 00       	mov    $0x55,%edx
c0102670:	eb 05                	jmp    c0102677 <print_pgfault+0x52>
c0102672:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102677:	0f 20 d0             	mov    %cr2,%eax
c010267a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010267d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102680:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0102684:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102688:	89 54 24 08          	mov    %edx,0x8(%esp)
c010268c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102690:	c7 04 24 74 c6 10 c0 	movl   $0xc010c674,(%esp)
c0102697:	e8 0d dc ff ff       	call   c01002a9 <cprintf>
}
c010269c:	90                   	nop
c010269d:	83 c4 34             	add    $0x34,%esp
c01026a0:	5b                   	pop    %ebx
c01026a1:	5d                   	pop    %ebp
c01026a2:	c3                   	ret    

c01026a3 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026a3:	55                   	push   %ebp
c01026a4:	89 e5                	mov    %esp,%ebp
c01026a6:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c01026a9:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c01026ae:	85 c0                	test   %eax,%eax
c01026b0:	74 0b                	je     c01026bd <pgfault_handler+0x1a>
            print_pgfault(tf);
c01026b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b5:	89 04 24             	mov    %eax,(%esp)
c01026b8:	e8 68 ff ff ff       	call   c0102625 <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c01026bd:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c01026c2:	85 c0                	test   %eax,%eax
c01026c4:	74 3d                	je     c0102703 <pgfault_handler+0x60>
        assert(current == idleproc);
c01026c6:	8b 15 28 00 1a c0    	mov    0xc01a0028,%edx
c01026cc:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c01026d1:	39 c2                	cmp    %eax,%edx
c01026d3:	74 24                	je     c01026f9 <pgfault_handler+0x56>
c01026d5:	c7 44 24 0c 97 c6 10 	movl   $0xc010c697,0xc(%esp)
c01026dc:	c0 
c01026dd:	c7 44 24 08 ab c6 10 	movl   $0xc010c6ab,0x8(%esp)
c01026e4:	c0 
c01026e5:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c01026ec:	00 
c01026ed:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c01026f4:	e8 07 dd ff ff       	call   c0100400 <__panic>
        mm = check_mm_struct;
c01026f9:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c01026fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102701:	eb 46                	jmp    c0102749 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c0102703:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102708:	85 c0                	test   %eax,%eax
c010270a:	75 32                	jne    c010273e <pgfault_handler+0x9b>
            print_trapframe(tf);
c010270c:	8b 45 08             	mov    0x8(%ebp),%eax
c010270f:	89 04 24             	mov    %eax,(%esp)
c0102712:	e8 a3 fc ff ff       	call   c01023ba <print_trapframe>
            print_pgfault(tf);
c0102717:	8b 45 08             	mov    0x8(%ebp),%eax
c010271a:	89 04 24             	mov    %eax,(%esp)
c010271d:	e8 03 ff ff ff       	call   c0102625 <print_pgfault>
            panic("unhandled page fault.\n");
c0102722:	c7 44 24 08 d1 c6 10 	movl   $0xc010c6d1,0x8(%esp)
c0102729:	c0 
c010272a:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0102731:	00 
c0102732:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c0102739:	e8 c2 dc ff ff       	call   c0100400 <__panic>
        }
        mm = current->mm;
c010273e:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102743:	8b 40 18             	mov    0x18(%eax),%eax
c0102746:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102749:	0f 20 d0             	mov    %cr2,%eax
c010274c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c010274f:	8b 55 f0             	mov    -0x10(%ebp),%edx
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c0102752:	8b 45 08             	mov    0x8(%ebp),%eax
c0102755:	8b 40 34             	mov    0x34(%eax),%eax
c0102758:	89 54 24 08          	mov    %edx,0x8(%esp)
c010275c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102760:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102763:	89 04 24             	mov    %eax,(%esp)
c0102766:	e8 af 1c 00 00       	call   c010441a <do_pgfault>
}
c010276b:	c9                   	leave  
c010276c:	c3                   	ret    

c010276d <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010276d:	55                   	push   %ebp
c010276e:	89 e5                	mov    %esp,%ebp
c0102770:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c0102773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c010277a:	8b 45 08             	mov    0x8(%ebp),%eax
c010277d:	8b 40 30             	mov    0x30(%eax),%eax
c0102780:	83 f8 2f             	cmp    $0x2f,%eax
c0102783:	77 38                	ja     c01027bd <trap_dispatch+0x50>
c0102785:	83 f8 2e             	cmp    $0x2e,%eax
c0102788:	0f 83 38 02 00 00    	jae    c01029c6 <trap_dispatch+0x259>
c010278e:	83 f8 20             	cmp    $0x20,%eax
c0102791:	0f 84 02 01 00 00    	je     c0102899 <trap_dispatch+0x12c>
c0102797:	83 f8 20             	cmp    $0x20,%eax
c010279a:	77 0a                	ja     c01027a6 <trap_dispatch+0x39>
c010279c:	83 f8 0e             	cmp    $0xe,%eax
c010279f:	74 3e                	je     c01027df <trap_dispatch+0x72>
c01027a1:	e9 d8 01 00 00       	jmp    c010297e <trap_dispatch+0x211>
c01027a6:	83 f8 21             	cmp    $0x21,%eax
c01027a9:	0f 84 8d 01 00 00    	je     c010293c <trap_dispatch+0x1cf>
c01027af:	83 f8 24             	cmp    $0x24,%eax
c01027b2:	0f 84 5b 01 00 00    	je     c0102913 <trap_dispatch+0x1a6>
c01027b8:	e9 c1 01 00 00       	jmp    c010297e <trap_dispatch+0x211>
c01027bd:	83 f8 78             	cmp    $0x78,%eax
c01027c0:	0f 82 b8 01 00 00    	jb     c010297e <trap_dispatch+0x211>
c01027c6:	83 f8 79             	cmp    $0x79,%eax
c01027c9:	0f 86 93 01 00 00    	jbe    c0102962 <trap_dispatch+0x1f5>
c01027cf:	3d 80 00 00 00       	cmp    $0x80,%eax
c01027d4:	0f 84 b5 00 00 00    	je     c010288f <trap_dispatch+0x122>
c01027da:	e9 9f 01 00 00       	jmp    c010297e <trap_dispatch+0x211>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01027df:	8b 45 08             	mov    0x8(%ebp),%eax
c01027e2:	89 04 24             	mov    %eax,(%esp)
c01027e5:	e8 b9 fe ff ff       	call   c01026a3 <pgfault_handler>
c01027ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01027ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01027f1:	0f 84 d2 01 00 00    	je     c01029c9 <trap_dispatch+0x25c>
            print_trapframe(tf);
c01027f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01027fa:	89 04 24             	mov    %eax,(%esp)
c01027fd:	e8 b8 fb ff ff       	call   c01023ba <print_trapframe>
            if (current == NULL) {
c0102802:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102807:	85 c0                	test   %eax,%eax
c0102809:	75 23                	jne    c010282e <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c010280b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010280e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102812:	c7 44 24 08 e8 c6 10 	movl   $0xc010c6e8,0x8(%esp)
c0102819:	c0 
c010281a:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0102821:	00 
c0102822:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c0102829:	e8 d2 db ff ff       	call   c0100400 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c010282e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102831:	89 04 24             	mov    %eax,(%esp)
c0102834:	e8 6c fb ff ff       	call   c01023a5 <trap_in_kernel>
c0102839:	85 c0                	test   %eax,%eax
c010283b:	74 23                	je     c0102860 <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c010283d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102840:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102844:	c7 44 24 08 08 c7 10 	movl   $0xc010c708,0x8(%esp)
c010284b:	c0 
c010284c:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0102853:	00 
c0102854:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c010285b:	e8 a0 db ff ff       	call   c0100400 <__panic>
                }
                cprintf("killed by kernel.\n");
c0102860:	c7 04 24 36 c7 10 c0 	movl   $0xc010c736,(%esp)
c0102867:	e8 3d da ff ff       	call   c01002a9 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c010286c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010286f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102873:	c7 44 24 08 4c c7 10 	movl   $0xc010c74c,0x8(%esp)
c010287a:	c0 
c010287b:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0102882:	00 
c0102883:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c010288a:	e8 71 db ff ff       	call   c0100400 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
    case T_SYSCALL:
        syscall();
c010288f:	e8 c3 8a 00 00       	call   c010b357 <syscall>
        break;
c0102894:	e9 34 01 00 00       	jmp    c01029cd <trap_dispatch+0x260>
         */
        /* LAB5 YOUR CODE */
        /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
        ticks++;
c0102899:	a1 54 20 1a c0       	mov    0xc01a2054,%eax
c010289e:	40                   	inc    %eax
c010289f:	a3 54 20 1a c0       	mov    %eax,0xc01a2054
        if (ticks % TICK_NUM == 0) {
c01028a4:	8b 0d 54 20 1a c0    	mov    0xc01a2054,%ecx
c01028aa:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01028af:	89 c8                	mov    %ecx,%eax
c01028b1:	f7 e2                	mul    %edx
c01028b3:	c1 ea 05             	shr    $0x5,%edx
c01028b6:	89 d0                	mov    %edx,%eax
c01028b8:	c1 e0 02             	shl    $0x2,%eax
c01028bb:	01 d0                	add    %edx,%eax
c01028bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01028c4:	01 d0                	add    %edx,%eax
c01028c6:	c1 e0 02             	shl    $0x2,%eax
c01028c9:	29 c1                	sub    %eax,%ecx
c01028cb:	89 ca                	mov    %ecx,%edx
c01028cd:	85 d2                	test   %edx,%edx
c01028cf:	0f 85 f7 00 00 00    	jne    c01029cc <trap_dispatch+0x25f>
            assert(current != NULL);
c01028d5:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c01028da:	85 c0                	test   %eax,%eax
c01028dc:	75 24                	jne    c0102902 <trap_dispatch+0x195>
c01028de:	c7 44 24 0c 75 c7 10 	movl   $0xc010c775,0xc(%esp)
c01028e5:	c0 
c01028e6:	c7 44 24 08 ab c6 10 	movl   $0xc010c6ab,0x8(%esp)
c01028ed:	c0 
c01028ee:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01028f5:	00 
c01028f6:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c01028fd:	e8 fe da ff ff       	call   c0100400 <__panic>
            current->need_resched = 1;
c0102902:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102907:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
        }
        break;
c010290e:	e9 b9 00 00 00       	jmp    c01029cc <trap_dispatch+0x25f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102913:	e8 8c f6 ff ff       	call   c0101fa4 <cons_getc>
c0102918:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010291b:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010291f:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102923:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102927:	89 44 24 04          	mov    %eax,0x4(%esp)
c010292b:	c7 04 24 85 c7 10 c0 	movl   $0xc010c785,(%esp)
c0102932:	e8 72 d9 ff ff       	call   c01002a9 <cprintf>
        break;
c0102937:	e9 91 00 00 00       	jmp    c01029cd <trap_dispatch+0x260>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010293c:	e8 63 f6 ff ff       	call   c0101fa4 <cons_getc>
c0102941:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102944:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102948:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010294c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102950:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102954:	c7 04 24 97 c7 10 c0 	movl   $0xc010c797,(%esp)
c010295b:	e8 49 d9 ff ff       	call   c01002a9 <cprintf>
        break;
c0102960:	eb 6b                	jmp    c01029cd <trap_dispatch+0x260>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102962:	c7 44 24 08 a6 c7 10 	movl   $0xc010c7a6,0x8(%esp)
c0102969:	c0 
c010296a:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0102971:	00 
c0102972:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c0102979:	e8 82 da ff ff       	call   c0100400 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c010297e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102981:	89 04 24             	mov    %eax,(%esp)
c0102984:	e8 31 fa ff ff       	call   c01023ba <print_trapframe>
        if (current != NULL) {
c0102989:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010298e:	85 c0                	test   %eax,%eax
c0102990:	74 18                	je     c01029aa <trap_dispatch+0x23d>
            cprintf("unhandled trap.\n");
c0102992:	c7 04 24 b6 c7 10 c0 	movl   $0xc010c7b6,(%esp)
c0102999:	e8 0b d9 ff ff       	call   c01002a9 <cprintf>
            do_exit(-E_KILLED);
c010299e:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c01029a5:	e8 8b 77 00 00       	call   c010a135 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c01029aa:	c7 44 24 08 c7 c7 10 	movl   $0xc010c7c7,0x8(%esp)
c01029b1:	c0 
c01029b2:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c01029b9:	00 
c01029ba:	c7 04 24 c0 c6 10 c0 	movl   $0xc010c6c0,(%esp)
c01029c1:	e8 3a da ff ff       	call   c0100400 <__panic>
        break;
c01029c6:	90                   	nop
c01029c7:	eb 04                	jmp    c01029cd <trap_dispatch+0x260>
        break;
c01029c9:	90                   	nop
c01029ca:	eb 01                	jmp    c01029cd <trap_dispatch+0x260>
        break;
c01029cc:	90                   	nop

    }
}
c01029cd:	90                   	nop
c01029ce:	c9                   	leave  
c01029cf:	c3                   	ret    

c01029d0 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01029d0:	55                   	push   %ebp
c01029d1:	89 e5                	mov    %esp,%ebp
c01029d3:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c01029d6:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c01029db:	85 c0                	test   %eax,%eax
c01029dd:	75 0d                	jne    c01029ec <trap+0x1c>
        trap_dispatch(tf);
c01029df:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e2:	89 04 24             	mov    %eax,(%esp)
c01029e5:	e8 83 fd ff ff       	call   c010276d <trap_dispatch>
            if (current->need_resched) {
                schedule();
            }
        }
    }
}
c01029ea:	eb 6c                	jmp    c0102a58 <trap+0x88>
        struct trapframe *otf = current->tf;
c01029ec:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c01029f1:	8b 40 3c             	mov    0x3c(%eax),%eax
c01029f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c01029f7:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c01029fc:	8b 55 08             	mov    0x8(%ebp),%edx
c01029ff:	89 50 3c             	mov    %edx,0x3c(%eax)
        bool in_kernel = trap_in_kernel(tf);
c0102a02:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a05:	89 04 24             	mov    %eax,(%esp)
c0102a08:	e8 98 f9 ff ff       	call   c01023a5 <trap_in_kernel>
c0102a0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        trap_dispatch(tf);
c0102a10:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a13:	89 04 24             	mov    %eax,(%esp)
c0102a16:	e8 52 fd ff ff       	call   c010276d <trap_dispatch>
        current->tf = otf;
c0102a1b:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102a20:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a23:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a2a:	75 2c                	jne    c0102a58 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a2c:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102a31:	8b 40 44             	mov    0x44(%eax),%eax
c0102a34:	83 e0 01             	and    $0x1,%eax
c0102a37:	85 c0                	test   %eax,%eax
c0102a39:	74 0c                	je     c0102a47 <trap+0x77>
                do_exit(-E_KILLED);
c0102a3b:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a42:	e8 ee 76 00 00       	call   c010a135 <do_exit>
            if (current->need_resched) {
c0102a47:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0102a4c:	8b 40 10             	mov    0x10(%eax),%eax
c0102a4f:	85 c0                	test   %eax,%eax
c0102a51:	74 05                	je     c0102a58 <trap+0x88>
                schedule();
c0102a53:	e8 01 87 00 00       	call   c010b159 <schedule>
}
c0102a58:	90                   	nop
c0102a59:	c9                   	leave  
c0102a5a:	c3                   	ret    

c0102a5b <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102a5b:	6a 00                	push   $0x0
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  jmp __alltraps
c0102a5f:	e9 69 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a64 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102a64:	6a 00                	push   $0x0
  pushl $1
c0102a66:	6a 01                	push   $0x1
  jmp __alltraps
c0102a68:	e9 60 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a6d <vector2>:
.globl vector2
vector2:
  pushl $0
c0102a6d:	6a 00                	push   $0x0
  pushl $2
c0102a6f:	6a 02                	push   $0x2
  jmp __alltraps
c0102a71:	e9 57 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a76 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102a76:	6a 00                	push   $0x0
  pushl $3
c0102a78:	6a 03                	push   $0x3
  jmp __alltraps
c0102a7a:	e9 4e 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a7f <vector4>:
.globl vector4
vector4:
  pushl $0
c0102a7f:	6a 00                	push   $0x0
  pushl $4
c0102a81:	6a 04                	push   $0x4
  jmp __alltraps
c0102a83:	e9 45 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a88 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102a88:	6a 00                	push   $0x0
  pushl $5
c0102a8a:	6a 05                	push   $0x5
  jmp __alltraps
c0102a8c:	e9 3c 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a91 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102a91:	6a 00                	push   $0x0
  pushl $6
c0102a93:	6a 06                	push   $0x6
  jmp __alltraps
c0102a95:	e9 33 0a 00 00       	jmp    c01034cd <__alltraps>

c0102a9a <vector7>:
.globl vector7
vector7:
  pushl $0
c0102a9a:	6a 00                	push   $0x0
  pushl $7
c0102a9c:	6a 07                	push   $0x7
  jmp __alltraps
c0102a9e:	e9 2a 0a 00 00       	jmp    c01034cd <__alltraps>

c0102aa3 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102aa3:	6a 08                	push   $0x8
  jmp __alltraps
c0102aa5:	e9 23 0a 00 00       	jmp    c01034cd <__alltraps>

c0102aaa <vector9>:
.globl vector9
vector9:
  pushl $0
c0102aaa:	6a 00                	push   $0x0
  pushl $9
c0102aac:	6a 09                	push   $0x9
  jmp __alltraps
c0102aae:	e9 1a 0a 00 00       	jmp    c01034cd <__alltraps>

c0102ab3 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102ab3:	6a 0a                	push   $0xa
  jmp __alltraps
c0102ab5:	e9 13 0a 00 00       	jmp    c01034cd <__alltraps>

c0102aba <vector11>:
.globl vector11
vector11:
  pushl $11
c0102aba:	6a 0b                	push   $0xb
  jmp __alltraps
c0102abc:	e9 0c 0a 00 00       	jmp    c01034cd <__alltraps>

c0102ac1 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102ac1:	6a 0c                	push   $0xc
  jmp __alltraps
c0102ac3:	e9 05 0a 00 00       	jmp    c01034cd <__alltraps>

c0102ac8 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102ac8:	6a 0d                	push   $0xd
  jmp __alltraps
c0102aca:	e9 fe 09 00 00       	jmp    c01034cd <__alltraps>

c0102acf <vector14>:
.globl vector14
vector14:
  pushl $14
c0102acf:	6a 0e                	push   $0xe
  jmp __alltraps
c0102ad1:	e9 f7 09 00 00       	jmp    c01034cd <__alltraps>

c0102ad6 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $15
c0102ad8:	6a 0f                	push   $0xf
  jmp __alltraps
c0102ada:	e9 ee 09 00 00       	jmp    c01034cd <__alltraps>

c0102adf <vector16>:
.globl vector16
vector16:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $16
c0102ae1:	6a 10                	push   $0x10
  jmp __alltraps
c0102ae3:	e9 e5 09 00 00       	jmp    c01034cd <__alltraps>

c0102ae8 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102ae8:	6a 11                	push   $0x11
  jmp __alltraps
c0102aea:	e9 de 09 00 00       	jmp    c01034cd <__alltraps>

c0102aef <vector18>:
.globl vector18
vector18:
  pushl $0
c0102aef:	6a 00                	push   $0x0
  pushl $18
c0102af1:	6a 12                	push   $0x12
  jmp __alltraps
c0102af3:	e9 d5 09 00 00       	jmp    c01034cd <__alltraps>

c0102af8 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102af8:	6a 00                	push   $0x0
  pushl $19
c0102afa:	6a 13                	push   $0x13
  jmp __alltraps
c0102afc:	e9 cc 09 00 00       	jmp    c01034cd <__alltraps>

c0102b01 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102b01:	6a 00                	push   $0x0
  pushl $20
c0102b03:	6a 14                	push   $0x14
  jmp __alltraps
c0102b05:	e9 c3 09 00 00       	jmp    c01034cd <__alltraps>

c0102b0a <vector21>:
.globl vector21
vector21:
  pushl $0
c0102b0a:	6a 00                	push   $0x0
  pushl $21
c0102b0c:	6a 15                	push   $0x15
  jmp __alltraps
c0102b0e:	e9 ba 09 00 00       	jmp    c01034cd <__alltraps>

c0102b13 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102b13:	6a 00                	push   $0x0
  pushl $22
c0102b15:	6a 16                	push   $0x16
  jmp __alltraps
c0102b17:	e9 b1 09 00 00       	jmp    c01034cd <__alltraps>

c0102b1c <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b1c:	6a 00                	push   $0x0
  pushl $23
c0102b1e:	6a 17                	push   $0x17
  jmp __alltraps
c0102b20:	e9 a8 09 00 00       	jmp    c01034cd <__alltraps>

c0102b25 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b25:	6a 00                	push   $0x0
  pushl $24
c0102b27:	6a 18                	push   $0x18
  jmp __alltraps
c0102b29:	e9 9f 09 00 00       	jmp    c01034cd <__alltraps>

c0102b2e <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b2e:	6a 00                	push   $0x0
  pushl $25
c0102b30:	6a 19                	push   $0x19
  jmp __alltraps
c0102b32:	e9 96 09 00 00       	jmp    c01034cd <__alltraps>

c0102b37 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b37:	6a 00                	push   $0x0
  pushl $26
c0102b39:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b3b:	e9 8d 09 00 00       	jmp    c01034cd <__alltraps>

c0102b40 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b40:	6a 00                	push   $0x0
  pushl $27
c0102b42:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b44:	e9 84 09 00 00       	jmp    c01034cd <__alltraps>

c0102b49 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b49:	6a 00                	push   $0x0
  pushl $28
c0102b4b:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b4d:	e9 7b 09 00 00       	jmp    c01034cd <__alltraps>

c0102b52 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b52:	6a 00                	push   $0x0
  pushl $29
c0102b54:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102b56:	e9 72 09 00 00       	jmp    c01034cd <__alltraps>

c0102b5b <vector30>:
.globl vector30
vector30:
  pushl $0
c0102b5b:	6a 00                	push   $0x0
  pushl $30
c0102b5d:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102b5f:	e9 69 09 00 00       	jmp    c01034cd <__alltraps>

c0102b64 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102b64:	6a 00                	push   $0x0
  pushl $31
c0102b66:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102b68:	e9 60 09 00 00       	jmp    c01034cd <__alltraps>

c0102b6d <vector32>:
.globl vector32
vector32:
  pushl $0
c0102b6d:	6a 00                	push   $0x0
  pushl $32
c0102b6f:	6a 20                	push   $0x20
  jmp __alltraps
c0102b71:	e9 57 09 00 00       	jmp    c01034cd <__alltraps>

c0102b76 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102b76:	6a 00                	push   $0x0
  pushl $33
c0102b78:	6a 21                	push   $0x21
  jmp __alltraps
c0102b7a:	e9 4e 09 00 00       	jmp    c01034cd <__alltraps>

c0102b7f <vector34>:
.globl vector34
vector34:
  pushl $0
c0102b7f:	6a 00                	push   $0x0
  pushl $34
c0102b81:	6a 22                	push   $0x22
  jmp __alltraps
c0102b83:	e9 45 09 00 00       	jmp    c01034cd <__alltraps>

c0102b88 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102b88:	6a 00                	push   $0x0
  pushl $35
c0102b8a:	6a 23                	push   $0x23
  jmp __alltraps
c0102b8c:	e9 3c 09 00 00       	jmp    c01034cd <__alltraps>

c0102b91 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102b91:	6a 00                	push   $0x0
  pushl $36
c0102b93:	6a 24                	push   $0x24
  jmp __alltraps
c0102b95:	e9 33 09 00 00       	jmp    c01034cd <__alltraps>

c0102b9a <vector37>:
.globl vector37
vector37:
  pushl $0
c0102b9a:	6a 00                	push   $0x0
  pushl $37
c0102b9c:	6a 25                	push   $0x25
  jmp __alltraps
c0102b9e:	e9 2a 09 00 00       	jmp    c01034cd <__alltraps>

c0102ba3 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102ba3:	6a 00                	push   $0x0
  pushl $38
c0102ba5:	6a 26                	push   $0x26
  jmp __alltraps
c0102ba7:	e9 21 09 00 00       	jmp    c01034cd <__alltraps>

c0102bac <vector39>:
.globl vector39
vector39:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $39
c0102bae:	6a 27                	push   $0x27
  jmp __alltraps
c0102bb0:	e9 18 09 00 00       	jmp    c01034cd <__alltraps>

c0102bb5 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102bb5:	6a 00                	push   $0x0
  pushl $40
c0102bb7:	6a 28                	push   $0x28
  jmp __alltraps
c0102bb9:	e9 0f 09 00 00       	jmp    c01034cd <__alltraps>

c0102bbe <vector41>:
.globl vector41
vector41:
  pushl $0
c0102bbe:	6a 00                	push   $0x0
  pushl $41
c0102bc0:	6a 29                	push   $0x29
  jmp __alltraps
c0102bc2:	e9 06 09 00 00       	jmp    c01034cd <__alltraps>

c0102bc7 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102bc7:	6a 00                	push   $0x0
  pushl $42
c0102bc9:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102bcb:	e9 fd 08 00 00       	jmp    c01034cd <__alltraps>

c0102bd0 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $43
c0102bd2:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102bd4:	e9 f4 08 00 00       	jmp    c01034cd <__alltraps>

c0102bd9 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102bd9:	6a 00                	push   $0x0
  pushl $44
c0102bdb:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102bdd:	e9 eb 08 00 00       	jmp    c01034cd <__alltraps>

c0102be2 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102be2:	6a 00                	push   $0x0
  pushl $45
c0102be4:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102be6:	e9 e2 08 00 00       	jmp    c01034cd <__alltraps>

c0102beb <vector46>:
.globl vector46
vector46:
  pushl $0
c0102beb:	6a 00                	push   $0x0
  pushl $46
c0102bed:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102bef:	e9 d9 08 00 00       	jmp    c01034cd <__alltraps>

c0102bf4 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $47
c0102bf6:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102bf8:	e9 d0 08 00 00       	jmp    c01034cd <__alltraps>

c0102bfd <vector48>:
.globl vector48
vector48:
  pushl $0
c0102bfd:	6a 00                	push   $0x0
  pushl $48
c0102bff:	6a 30                	push   $0x30
  jmp __alltraps
c0102c01:	e9 c7 08 00 00       	jmp    c01034cd <__alltraps>

c0102c06 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102c06:	6a 00                	push   $0x0
  pushl $49
c0102c08:	6a 31                	push   $0x31
  jmp __alltraps
c0102c0a:	e9 be 08 00 00       	jmp    c01034cd <__alltraps>

c0102c0f <vector50>:
.globl vector50
vector50:
  pushl $0
c0102c0f:	6a 00                	push   $0x0
  pushl $50
c0102c11:	6a 32                	push   $0x32
  jmp __alltraps
c0102c13:	e9 b5 08 00 00       	jmp    c01034cd <__alltraps>

c0102c18 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $51
c0102c1a:	6a 33                	push   $0x33
  jmp __alltraps
c0102c1c:	e9 ac 08 00 00       	jmp    c01034cd <__alltraps>

c0102c21 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c21:	6a 00                	push   $0x0
  pushl $52
c0102c23:	6a 34                	push   $0x34
  jmp __alltraps
c0102c25:	e9 a3 08 00 00       	jmp    c01034cd <__alltraps>

c0102c2a <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c2a:	6a 00                	push   $0x0
  pushl $53
c0102c2c:	6a 35                	push   $0x35
  jmp __alltraps
c0102c2e:	e9 9a 08 00 00       	jmp    c01034cd <__alltraps>

c0102c33 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c33:	6a 00                	push   $0x0
  pushl $54
c0102c35:	6a 36                	push   $0x36
  jmp __alltraps
c0102c37:	e9 91 08 00 00       	jmp    c01034cd <__alltraps>

c0102c3c <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $55
c0102c3e:	6a 37                	push   $0x37
  jmp __alltraps
c0102c40:	e9 88 08 00 00       	jmp    c01034cd <__alltraps>

c0102c45 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c45:	6a 00                	push   $0x0
  pushl $56
c0102c47:	6a 38                	push   $0x38
  jmp __alltraps
c0102c49:	e9 7f 08 00 00       	jmp    c01034cd <__alltraps>

c0102c4e <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c4e:	6a 00                	push   $0x0
  pushl $57
c0102c50:	6a 39                	push   $0x39
  jmp __alltraps
c0102c52:	e9 76 08 00 00       	jmp    c01034cd <__alltraps>

c0102c57 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102c57:	6a 00                	push   $0x0
  pushl $58
c0102c59:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102c5b:	e9 6d 08 00 00       	jmp    c01034cd <__alltraps>

c0102c60 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $59
c0102c62:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102c64:	e9 64 08 00 00       	jmp    c01034cd <__alltraps>

c0102c69 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102c69:	6a 00                	push   $0x0
  pushl $60
c0102c6b:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102c6d:	e9 5b 08 00 00       	jmp    c01034cd <__alltraps>

c0102c72 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102c72:	6a 00                	push   $0x0
  pushl $61
c0102c74:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102c76:	e9 52 08 00 00       	jmp    c01034cd <__alltraps>

c0102c7b <vector62>:
.globl vector62
vector62:
  pushl $0
c0102c7b:	6a 00                	push   $0x0
  pushl $62
c0102c7d:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102c7f:	e9 49 08 00 00       	jmp    c01034cd <__alltraps>

c0102c84 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102c84:	6a 00                	push   $0x0
  pushl $63
c0102c86:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102c88:	e9 40 08 00 00       	jmp    c01034cd <__alltraps>

c0102c8d <vector64>:
.globl vector64
vector64:
  pushl $0
c0102c8d:	6a 00                	push   $0x0
  pushl $64
c0102c8f:	6a 40                	push   $0x40
  jmp __alltraps
c0102c91:	e9 37 08 00 00       	jmp    c01034cd <__alltraps>

c0102c96 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102c96:	6a 00                	push   $0x0
  pushl $65
c0102c98:	6a 41                	push   $0x41
  jmp __alltraps
c0102c9a:	e9 2e 08 00 00       	jmp    c01034cd <__alltraps>

c0102c9f <vector66>:
.globl vector66
vector66:
  pushl $0
c0102c9f:	6a 00                	push   $0x0
  pushl $66
c0102ca1:	6a 42                	push   $0x42
  jmp __alltraps
c0102ca3:	e9 25 08 00 00       	jmp    c01034cd <__alltraps>

c0102ca8 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102ca8:	6a 00                	push   $0x0
  pushl $67
c0102caa:	6a 43                	push   $0x43
  jmp __alltraps
c0102cac:	e9 1c 08 00 00       	jmp    c01034cd <__alltraps>

c0102cb1 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102cb1:	6a 00                	push   $0x0
  pushl $68
c0102cb3:	6a 44                	push   $0x44
  jmp __alltraps
c0102cb5:	e9 13 08 00 00       	jmp    c01034cd <__alltraps>

c0102cba <vector69>:
.globl vector69
vector69:
  pushl $0
c0102cba:	6a 00                	push   $0x0
  pushl $69
c0102cbc:	6a 45                	push   $0x45
  jmp __alltraps
c0102cbe:	e9 0a 08 00 00       	jmp    c01034cd <__alltraps>

c0102cc3 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102cc3:	6a 00                	push   $0x0
  pushl $70
c0102cc5:	6a 46                	push   $0x46
  jmp __alltraps
c0102cc7:	e9 01 08 00 00       	jmp    c01034cd <__alltraps>

c0102ccc <vector71>:
.globl vector71
vector71:
  pushl $0
c0102ccc:	6a 00                	push   $0x0
  pushl $71
c0102cce:	6a 47                	push   $0x47
  jmp __alltraps
c0102cd0:	e9 f8 07 00 00       	jmp    c01034cd <__alltraps>

c0102cd5 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102cd5:	6a 00                	push   $0x0
  pushl $72
c0102cd7:	6a 48                	push   $0x48
  jmp __alltraps
c0102cd9:	e9 ef 07 00 00       	jmp    c01034cd <__alltraps>

c0102cde <vector73>:
.globl vector73
vector73:
  pushl $0
c0102cde:	6a 00                	push   $0x0
  pushl $73
c0102ce0:	6a 49                	push   $0x49
  jmp __alltraps
c0102ce2:	e9 e6 07 00 00       	jmp    c01034cd <__alltraps>

c0102ce7 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102ce7:	6a 00                	push   $0x0
  pushl $74
c0102ce9:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102ceb:	e9 dd 07 00 00       	jmp    c01034cd <__alltraps>

c0102cf0 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102cf0:	6a 00                	push   $0x0
  pushl $75
c0102cf2:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102cf4:	e9 d4 07 00 00       	jmp    c01034cd <__alltraps>

c0102cf9 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102cf9:	6a 00                	push   $0x0
  pushl $76
c0102cfb:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102cfd:	e9 cb 07 00 00       	jmp    c01034cd <__alltraps>

c0102d02 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102d02:	6a 00                	push   $0x0
  pushl $77
c0102d04:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102d06:	e9 c2 07 00 00       	jmp    c01034cd <__alltraps>

c0102d0b <vector78>:
.globl vector78
vector78:
  pushl $0
c0102d0b:	6a 00                	push   $0x0
  pushl $78
c0102d0d:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102d0f:	e9 b9 07 00 00       	jmp    c01034cd <__alltraps>

c0102d14 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102d14:	6a 00                	push   $0x0
  pushl $79
c0102d16:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102d18:	e9 b0 07 00 00       	jmp    c01034cd <__alltraps>

c0102d1d <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d1d:	6a 00                	push   $0x0
  pushl $80
c0102d1f:	6a 50                	push   $0x50
  jmp __alltraps
c0102d21:	e9 a7 07 00 00       	jmp    c01034cd <__alltraps>

c0102d26 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d26:	6a 00                	push   $0x0
  pushl $81
c0102d28:	6a 51                	push   $0x51
  jmp __alltraps
c0102d2a:	e9 9e 07 00 00       	jmp    c01034cd <__alltraps>

c0102d2f <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d2f:	6a 00                	push   $0x0
  pushl $82
c0102d31:	6a 52                	push   $0x52
  jmp __alltraps
c0102d33:	e9 95 07 00 00       	jmp    c01034cd <__alltraps>

c0102d38 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d38:	6a 00                	push   $0x0
  pushl $83
c0102d3a:	6a 53                	push   $0x53
  jmp __alltraps
c0102d3c:	e9 8c 07 00 00       	jmp    c01034cd <__alltraps>

c0102d41 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d41:	6a 00                	push   $0x0
  pushl $84
c0102d43:	6a 54                	push   $0x54
  jmp __alltraps
c0102d45:	e9 83 07 00 00       	jmp    c01034cd <__alltraps>

c0102d4a <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d4a:	6a 00                	push   $0x0
  pushl $85
c0102d4c:	6a 55                	push   $0x55
  jmp __alltraps
c0102d4e:	e9 7a 07 00 00       	jmp    c01034cd <__alltraps>

c0102d53 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d53:	6a 00                	push   $0x0
  pushl $86
c0102d55:	6a 56                	push   $0x56
  jmp __alltraps
c0102d57:	e9 71 07 00 00       	jmp    c01034cd <__alltraps>

c0102d5c <vector87>:
.globl vector87
vector87:
  pushl $0
c0102d5c:	6a 00                	push   $0x0
  pushl $87
c0102d5e:	6a 57                	push   $0x57
  jmp __alltraps
c0102d60:	e9 68 07 00 00       	jmp    c01034cd <__alltraps>

c0102d65 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102d65:	6a 00                	push   $0x0
  pushl $88
c0102d67:	6a 58                	push   $0x58
  jmp __alltraps
c0102d69:	e9 5f 07 00 00       	jmp    c01034cd <__alltraps>

c0102d6e <vector89>:
.globl vector89
vector89:
  pushl $0
c0102d6e:	6a 00                	push   $0x0
  pushl $89
c0102d70:	6a 59                	push   $0x59
  jmp __alltraps
c0102d72:	e9 56 07 00 00       	jmp    c01034cd <__alltraps>

c0102d77 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102d77:	6a 00                	push   $0x0
  pushl $90
c0102d79:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102d7b:	e9 4d 07 00 00       	jmp    c01034cd <__alltraps>

c0102d80 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102d80:	6a 00                	push   $0x0
  pushl $91
c0102d82:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102d84:	e9 44 07 00 00       	jmp    c01034cd <__alltraps>

c0102d89 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102d89:	6a 00                	push   $0x0
  pushl $92
c0102d8b:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102d8d:	e9 3b 07 00 00       	jmp    c01034cd <__alltraps>

c0102d92 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102d92:	6a 00                	push   $0x0
  pushl $93
c0102d94:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102d96:	e9 32 07 00 00       	jmp    c01034cd <__alltraps>

c0102d9b <vector94>:
.globl vector94
vector94:
  pushl $0
c0102d9b:	6a 00                	push   $0x0
  pushl $94
c0102d9d:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102d9f:	e9 29 07 00 00       	jmp    c01034cd <__alltraps>

c0102da4 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102da4:	6a 00                	push   $0x0
  pushl $95
c0102da6:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102da8:	e9 20 07 00 00       	jmp    c01034cd <__alltraps>

c0102dad <vector96>:
.globl vector96
vector96:
  pushl $0
c0102dad:	6a 00                	push   $0x0
  pushl $96
c0102daf:	6a 60                	push   $0x60
  jmp __alltraps
c0102db1:	e9 17 07 00 00       	jmp    c01034cd <__alltraps>

c0102db6 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102db6:	6a 00                	push   $0x0
  pushl $97
c0102db8:	6a 61                	push   $0x61
  jmp __alltraps
c0102dba:	e9 0e 07 00 00       	jmp    c01034cd <__alltraps>

c0102dbf <vector98>:
.globl vector98
vector98:
  pushl $0
c0102dbf:	6a 00                	push   $0x0
  pushl $98
c0102dc1:	6a 62                	push   $0x62
  jmp __alltraps
c0102dc3:	e9 05 07 00 00       	jmp    c01034cd <__alltraps>

c0102dc8 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102dc8:	6a 00                	push   $0x0
  pushl $99
c0102dca:	6a 63                	push   $0x63
  jmp __alltraps
c0102dcc:	e9 fc 06 00 00       	jmp    c01034cd <__alltraps>

c0102dd1 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102dd1:	6a 00                	push   $0x0
  pushl $100
c0102dd3:	6a 64                	push   $0x64
  jmp __alltraps
c0102dd5:	e9 f3 06 00 00       	jmp    c01034cd <__alltraps>

c0102dda <vector101>:
.globl vector101
vector101:
  pushl $0
c0102dda:	6a 00                	push   $0x0
  pushl $101
c0102ddc:	6a 65                	push   $0x65
  jmp __alltraps
c0102dde:	e9 ea 06 00 00       	jmp    c01034cd <__alltraps>

c0102de3 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102de3:	6a 00                	push   $0x0
  pushl $102
c0102de5:	6a 66                	push   $0x66
  jmp __alltraps
c0102de7:	e9 e1 06 00 00       	jmp    c01034cd <__alltraps>

c0102dec <vector103>:
.globl vector103
vector103:
  pushl $0
c0102dec:	6a 00                	push   $0x0
  pushl $103
c0102dee:	6a 67                	push   $0x67
  jmp __alltraps
c0102df0:	e9 d8 06 00 00       	jmp    c01034cd <__alltraps>

c0102df5 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102df5:	6a 00                	push   $0x0
  pushl $104
c0102df7:	6a 68                	push   $0x68
  jmp __alltraps
c0102df9:	e9 cf 06 00 00       	jmp    c01034cd <__alltraps>

c0102dfe <vector105>:
.globl vector105
vector105:
  pushl $0
c0102dfe:	6a 00                	push   $0x0
  pushl $105
c0102e00:	6a 69                	push   $0x69
  jmp __alltraps
c0102e02:	e9 c6 06 00 00       	jmp    c01034cd <__alltraps>

c0102e07 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102e07:	6a 00                	push   $0x0
  pushl $106
c0102e09:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102e0b:	e9 bd 06 00 00       	jmp    c01034cd <__alltraps>

c0102e10 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102e10:	6a 00                	push   $0x0
  pushl $107
c0102e12:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102e14:	e9 b4 06 00 00       	jmp    c01034cd <__alltraps>

c0102e19 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e19:	6a 00                	push   $0x0
  pushl $108
c0102e1b:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e1d:	e9 ab 06 00 00       	jmp    c01034cd <__alltraps>

c0102e22 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e22:	6a 00                	push   $0x0
  pushl $109
c0102e24:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e26:	e9 a2 06 00 00       	jmp    c01034cd <__alltraps>

c0102e2b <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e2b:	6a 00                	push   $0x0
  pushl $110
c0102e2d:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e2f:	e9 99 06 00 00       	jmp    c01034cd <__alltraps>

c0102e34 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e34:	6a 00                	push   $0x0
  pushl $111
c0102e36:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e38:	e9 90 06 00 00       	jmp    c01034cd <__alltraps>

c0102e3d <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e3d:	6a 00                	push   $0x0
  pushl $112
c0102e3f:	6a 70                	push   $0x70
  jmp __alltraps
c0102e41:	e9 87 06 00 00       	jmp    c01034cd <__alltraps>

c0102e46 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e46:	6a 00                	push   $0x0
  pushl $113
c0102e48:	6a 71                	push   $0x71
  jmp __alltraps
c0102e4a:	e9 7e 06 00 00       	jmp    c01034cd <__alltraps>

c0102e4f <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e4f:	6a 00                	push   $0x0
  pushl $114
c0102e51:	6a 72                	push   $0x72
  jmp __alltraps
c0102e53:	e9 75 06 00 00       	jmp    c01034cd <__alltraps>

c0102e58 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102e58:	6a 00                	push   $0x0
  pushl $115
c0102e5a:	6a 73                	push   $0x73
  jmp __alltraps
c0102e5c:	e9 6c 06 00 00       	jmp    c01034cd <__alltraps>

c0102e61 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102e61:	6a 00                	push   $0x0
  pushl $116
c0102e63:	6a 74                	push   $0x74
  jmp __alltraps
c0102e65:	e9 63 06 00 00       	jmp    c01034cd <__alltraps>

c0102e6a <vector117>:
.globl vector117
vector117:
  pushl $0
c0102e6a:	6a 00                	push   $0x0
  pushl $117
c0102e6c:	6a 75                	push   $0x75
  jmp __alltraps
c0102e6e:	e9 5a 06 00 00       	jmp    c01034cd <__alltraps>

c0102e73 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102e73:	6a 00                	push   $0x0
  pushl $118
c0102e75:	6a 76                	push   $0x76
  jmp __alltraps
c0102e77:	e9 51 06 00 00       	jmp    c01034cd <__alltraps>

c0102e7c <vector119>:
.globl vector119
vector119:
  pushl $0
c0102e7c:	6a 00                	push   $0x0
  pushl $119
c0102e7e:	6a 77                	push   $0x77
  jmp __alltraps
c0102e80:	e9 48 06 00 00       	jmp    c01034cd <__alltraps>

c0102e85 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102e85:	6a 00                	push   $0x0
  pushl $120
c0102e87:	6a 78                	push   $0x78
  jmp __alltraps
c0102e89:	e9 3f 06 00 00       	jmp    c01034cd <__alltraps>

c0102e8e <vector121>:
.globl vector121
vector121:
  pushl $0
c0102e8e:	6a 00                	push   $0x0
  pushl $121
c0102e90:	6a 79                	push   $0x79
  jmp __alltraps
c0102e92:	e9 36 06 00 00       	jmp    c01034cd <__alltraps>

c0102e97 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102e97:	6a 00                	push   $0x0
  pushl $122
c0102e99:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102e9b:	e9 2d 06 00 00       	jmp    c01034cd <__alltraps>

c0102ea0 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ea0:	6a 00                	push   $0x0
  pushl $123
c0102ea2:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ea4:	e9 24 06 00 00       	jmp    c01034cd <__alltraps>

c0102ea9 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ea9:	6a 00                	push   $0x0
  pushl $124
c0102eab:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ead:	e9 1b 06 00 00       	jmp    c01034cd <__alltraps>

c0102eb2 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102eb2:	6a 00                	push   $0x0
  pushl $125
c0102eb4:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102eb6:	e9 12 06 00 00       	jmp    c01034cd <__alltraps>

c0102ebb <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ebb:	6a 00                	push   $0x0
  pushl $126
c0102ebd:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ebf:	e9 09 06 00 00       	jmp    c01034cd <__alltraps>

c0102ec4 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ec4:	6a 00                	push   $0x0
  pushl $127
c0102ec6:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102ec8:	e9 00 06 00 00       	jmp    c01034cd <__alltraps>

c0102ecd <vector128>:
.globl vector128
vector128:
  pushl $0
c0102ecd:	6a 00                	push   $0x0
  pushl $128
c0102ecf:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102ed4:	e9 f4 05 00 00       	jmp    c01034cd <__alltraps>

c0102ed9 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102ed9:	6a 00                	push   $0x0
  pushl $129
c0102edb:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ee0:	e9 e8 05 00 00       	jmp    c01034cd <__alltraps>

c0102ee5 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ee5:	6a 00                	push   $0x0
  pushl $130
c0102ee7:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102eec:	e9 dc 05 00 00       	jmp    c01034cd <__alltraps>

c0102ef1 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102ef1:	6a 00                	push   $0x0
  pushl $131
c0102ef3:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102ef8:	e9 d0 05 00 00       	jmp    c01034cd <__alltraps>

c0102efd <vector132>:
.globl vector132
vector132:
  pushl $0
c0102efd:	6a 00                	push   $0x0
  pushl $132
c0102eff:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102f04:	e9 c4 05 00 00       	jmp    c01034cd <__alltraps>

c0102f09 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102f09:	6a 00                	push   $0x0
  pushl $133
c0102f0b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102f10:	e9 b8 05 00 00       	jmp    c01034cd <__alltraps>

c0102f15 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102f15:	6a 00                	push   $0x0
  pushl $134
c0102f17:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f1c:	e9 ac 05 00 00       	jmp    c01034cd <__alltraps>

c0102f21 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f21:	6a 00                	push   $0x0
  pushl $135
c0102f23:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f28:	e9 a0 05 00 00       	jmp    c01034cd <__alltraps>

c0102f2d <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f2d:	6a 00                	push   $0x0
  pushl $136
c0102f2f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f34:	e9 94 05 00 00       	jmp    c01034cd <__alltraps>

c0102f39 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f39:	6a 00                	push   $0x0
  pushl $137
c0102f3b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f40:	e9 88 05 00 00       	jmp    c01034cd <__alltraps>

c0102f45 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f45:	6a 00                	push   $0x0
  pushl $138
c0102f47:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f4c:	e9 7c 05 00 00       	jmp    c01034cd <__alltraps>

c0102f51 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f51:	6a 00                	push   $0x0
  pushl $139
c0102f53:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102f58:	e9 70 05 00 00       	jmp    c01034cd <__alltraps>

c0102f5d <vector140>:
.globl vector140
vector140:
  pushl $0
c0102f5d:	6a 00                	push   $0x0
  pushl $140
c0102f5f:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102f64:	e9 64 05 00 00       	jmp    c01034cd <__alltraps>

c0102f69 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102f69:	6a 00                	push   $0x0
  pushl $141
c0102f6b:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102f70:	e9 58 05 00 00       	jmp    c01034cd <__alltraps>

c0102f75 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102f75:	6a 00                	push   $0x0
  pushl $142
c0102f77:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102f7c:	e9 4c 05 00 00       	jmp    c01034cd <__alltraps>

c0102f81 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102f81:	6a 00                	push   $0x0
  pushl $143
c0102f83:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102f88:	e9 40 05 00 00       	jmp    c01034cd <__alltraps>

c0102f8d <vector144>:
.globl vector144
vector144:
  pushl $0
c0102f8d:	6a 00                	push   $0x0
  pushl $144
c0102f8f:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102f94:	e9 34 05 00 00       	jmp    c01034cd <__alltraps>

c0102f99 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102f99:	6a 00                	push   $0x0
  pushl $145
c0102f9b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102fa0:	e9 28 05 00 00       	jmp    c01034cd <__alltraps>

c0102fa5 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102fa5:	6a 00                	push   $0x0
  pushl $146
c0102fa7:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102fac:	e9 1c 05 00 00       	jmp    c01034cd <__alltraps>

c0102fb1 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102fb1:	6a 00                	push   $0x0
  pushl $147
c0102fb3:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102fb8:	e9 10 05 00 00       	jmp    c01034cd <__alltraps>

c0102fbd <vector148>:
.globl vector148
vector148:
  pushl $0
c0102fbd:	6a 00                	push   $0x0
  pushl $148
c0102fbf:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102fc4:	e9 04 05 00 00       	jmp    c01034cd <__alltraps>

c0102fc9 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102fc9:	6a 00                	push   $0x0
  pushl $149
c0102fcb:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102fd0:	e9 f8 04 00 00       	jmp    c01034cd <__alltraps>

c0102fd5 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102fd5:	6a 00                	push   $0x0
  pushl $150
c0102fd7:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102fdc:	e9 ec 04 00 00       	jmp    c01034cd <__alltraps>

c0102fe1 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102fe1:	6a 00                	push   $0x0
  pushl $151
c0102fe3:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102fe8:	e9 e0 04 00 00       	jmp    c01034cd <__alltraps>

c0102fed <vector152>:
.globl vector152
vector152:
  pushl $0
c0102fed:	6a 00                	push   $0x0
  pushl $152
c0102fef:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102ff4:	e9 d4 04 00 00       	jmp    c01034cd <__alltraps>

c0102ff9 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102ff9:	6a 00                	push   $0x0
  pushl $153
c0102ffb:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103000:	e9 c8 04 00 00       	jmp    c01034cd <__alltraps>

c0103005 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103005:	6a 00                	push   $0x0
  pushl $154
c0103007:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010300c:	e9 bc 04 00 00       	jmp    c01034cd <__alltraps>

c0103011 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103011:	6a 00                	push   $0x0
  pushl $155
c0103013:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103018:	e9 b0 04 00 00       	jmp    c01034cd <__alltraps>

c010301d <vector156>:
.globl vector156
vector156:
  pushl $0
c010301d:	6a 00                	push   $0x0
  pushl $156
c010301f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103024:	e9 a4 04 00 00       	jmp    c01034cd <__alltraps>

c0103029 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103029:	6a 00                	push   $0x0
  pushl $157
c010302b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103030:	e9 98 04 00 00       	jmp    c01034cd <__alltraps>

c0103035 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103035:	6a 00                	push   $0x0
  pushl $158
c0103037:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010303c:	e9 8c 04 00 00       	jmp    c01034cd <__alltraps>

c0103041 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103041:	6a 00                	push   $0x0
  pushl $159
c0103043:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103048:	e9 80 04 00 00       	jmp    c01034cd <__alltraps>

c010304d <vector160>:
.globl vector160
vector160:
  pushl $0
c010304d:	6a 00                	push   $0x0
  pushl $160
c010304f:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0103054:	e9 74 04 00 00       	jmp    c01034cd <__alltraps>

c0103059 <vector161>:
.globl vector161
vector161:
  pushl $0
c0103059:	6a 00                	push   $0x0
  pushl $161
c010305b:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103060:	e9 68 04 00 00       	jmp    c01034cd <__alltraps>

c0103065 <vector162>:
.globl vector162
vector162:
  pushl $0
c0103065:	6a 00                	push   $0x0
  pushl $162
c0103067:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010306c:	e9 5c 04 00 00       	jmp    c01034cd <__alltraps>

c0103071 <vector163>:
.globl vector163
vector163:
  pushl $0
c0103071:	6a 00                	push   $0x0
  pushl $163
c0103073:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0103078:	e9 50 04 00 00       	jmp    c01034cd <__alltraps>

c010307d <vector164>:
.globl vector164
vector164:
  pushl $0
c010307d:	6a 00                	push   $0x0
  pushl $164
c010307f:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0103084:	e9 44 04 00 00       	jmp    c01034cd <__alltraps>

c0103089 <vector165>:
.globl vector165
vector165:
  pushl $0
c0103089:	6a 00                	push   $0x0
  pushl $165
c010308b:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0103090:	e9 38 04 00 00       	jmp    c01034cd <__alltraps>

c0103095 <vector166>:
.globl vector166
vector166:
  pushl $0
c0103095:	6a 00                	push   $0x0
  pushl $166
c0103097:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010309c:	e9 2c 04 00 00       	jmp    c01034cd <__alltraps>

c01030a1 <vector167>:
.globl vector167
vector167:
  pushl $0
c01030a1:	6a 00                	push   $0x0
  pushl $167
c01030a3:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01030a8:	e9 20 04 00 00       	jmp    c01034cd <__alltraps>

c01030ad <vector168>:
.globl vector168
vector168:
  pushl $0
c01030ad:	6a 00                	push   $0x0
  pushl $168
c01030af:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01030b4:	e9 14 04 00 00       	jmp    c01034cd <__alltraps>

c01030b9 <vector169>:
.globl vector169
vector169:
  pushl $0
c01030b9:	6a 00                	push   $0x0
  pushl $169
c01030bb:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01030c0:	e9 08 04 00 00       	jmp    c01034cd <__alltraps>

c01030c5 <vector170>:
.globl vector170
vector170:
  pushl $0
c01030c5:	6a 00                	push   $0x0
  pushl $170
c01030c7:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01030cc:	e9 fc 03 00 00       	jmp    c01034cd <__alltraps>

c01030d1 <vector171>:
.globl vector171
vector171:
  pushl $0
c01030d1:	6a 00                	push   $0x0
  pushl $171
c01030d3:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01030d8:	e9 f0 03 00 00       	jmp    c01034cd <__alltraps>

c01030dd <vector172>:
.globl vector172
vector172:
  pushl $0
c01030dd:	6a 00                	push   $0x0
  pushl $172
c01030df:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01030e4:	e9 e4 03 00 00       	jmp    c01034cd <__alltraps>

c01030e9 <vector173>:
.globl vector173
vector173:
  pushl $0
c01030e9:	6a 00                	push   $0x0
  pushl $173
c01030eb:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01030f0:	e9 d8 03 00 00       	jmp    c01034cd <__alltraps>

c01030f5 <vector174>:
.globl vector174
vector174:
  pushl $0
c01030f5:	6a 00                	push   $0x0
  pushl $174
c01030f7:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01030fc:	e9 cc 03 00 00       	jmp    c01034cd <__alltraps>

c0103101 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103101:	6a 00                	push   $0x0
  pushl $175
c0103103:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103108:	e9 c0 03 00 00       	jmp    c01034cd <__alltraps>

c010310d <vector176>:
.globl vector176
vector176:
  pushl $0
c010310d:	6a 00                	push   $0x0
  pushl $176
c010310f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103114:	e9 b4 03 00 00       	jmp    c01034cd <__alltraps>

c0103119 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103119:	6a 00                	push   $0x0
  pushl $177
c010311b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103120:	e9 a8 03 00 00       	jmp    c01034cd <__alltraps>

c0103125 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103125:	6a 00                	push   $0x0
  pushl $178
c0103127:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010312c:	e9 9c 03 00 00       	jmp    c01034cd <__alltraps>

c0103131 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103131:	6a 00                	push   $0x0
  pushl $179
c0103133:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103138:	e9 90 03 00 00       	jmp    c01034cd <__alltraps>

c010313d <vector180>:
.globl vector180
vector180:
  pushl $0
c010313d:	6a 00                	push   $0x0
  pushl $180
c010313f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103144:	e9 84 03 00 00       	jmp    c01034cd <__alltraps>

c0103149 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103149:	6a 00                	push   $0x0
  pushl $181
c010314b:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103150:	e9 78 03 00 00       	jmp    c01034cd <__alltraps>

c0103155 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103155:	6a 00                	push   $0x0
  pushl $182
c0103157:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010315c:	e9 6c 03 00 00       	jmp    c01034cd <__alltraps>

c0103161 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103161:	6a 00                	push   $0x0
  pushl $183
c0103163:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0103168:	e9 60 03 00 00       	jmp    c01034cd <__alltraps>

c010316d <vector184>:
.globl vector184
vector184:
  pushl $0
c010316d:	6a 00                	push   $0x0
  pushl $184
c010316f:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103174:	e9 54 03 00 00       	jmp    c01034cd <__alltraps>

c0103179 <vector185>:
.globl vector185
vector185:
  pushl $0
c0103179:	6a 00                	push   $0x0
  pushl $185
c010317b:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103180:	e9 48 03 00 00       	jmp    c01034cd <__alltraps>

c0103185 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103185:	6a 00                	push   $0x0
  pushl $186
c0103187:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010318c:	e9 3c 03 00 00       	jmp    c01034cd <__alltraps>

c0103191 <vector187>:
.globl vector187
vector187:
  pushl $0
c0103191:	6a 00                	push   $0x0
  pushl $187
c0103193:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0103198:	e9 30 03 00 00       	jmp    c01034cd <__alltraps>

c010319d <vector188>:
.globl vector188
vector188:
  pushl $0
c010319d:	6a 00                	push   $0x0
  pushl $188
c010319f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01031a4:	e9 24 03 00 00       	jmp    c01034cd <__alltraps>

c01031a9 <vector189>:
.globl vector189
vector189:
  pushl $0
c01031a9:	6a 00                	push   $0x0
  pushl $189
c01031ab:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01031b0:	e9 18 03 00 00       	jmp    c01034cd <__alltraps>

c01031b5 <vector190>:
.globl vector190
vector190:
  pushl $0
c01031b5:	6a 00                	push   $0x0
  pushl $190
c01031b7:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01031bc:	e9 0c 03 00 00       	jmp    c01034cd <__alltraps>

c01031c1 <vector191>:
.globl vector191
vector191:
  pushl $0
c01031c1:	6a 00                	push   $0x0
  pushl $191
c01031c3:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01031c8:	e9 00 03 00 00       	jmp    c01034cd <__alltraps>

c01031cd <vector192>:
.globl vector192
vector192:
  pushl $0
c01031cd:	6a 00                	push   $0x0
  pushl $192
c01031cf:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01031d4:	e9 f4 02 00 00       	jmp    c01034cd <__alltraps>

c01031d9 <vector193>:
.globl vector193
vector193:
  pushl $0
c01031d9:	6a 00                	push   $0x0
  pushl $193
c01031db:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01031e0:	e9 e8 02 00 00       	jmp    c01034cd <__alltraps>

c01031e5 <vector194>:
.globl vector194
vector194:
  pushl $0
c01031e5:	6a 00                	push   $0x0
  pushl $194
c01031e7:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01031ec:	e9 dc 02 00 00       	jmp    c01034cd <__alltraps>

c01031f1 <vector195>:
.globl vector195
vector195:
  pushl $0
c01031f1:	6a 00                	push   $0x0
  pushl $195
c01031f3:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01031f8:	e9 d0 02 00 00       	jmp    c01034cd <__alltraps>

c01031fd <vector196>:
.globl vector196
vector196:
  pushl $0
c01031fd:	6a 00                	push   $0x0
  pushl $196
c01031ff:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103204:	e9 c4 02 00 00       	jmp    c01034cd <__alltraps>

c0103209 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103209:	6a 00                	push   $0x0
  pushl $197
c010320b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103210:	e9 b8 02 00 00       	jmp    c01034cd <__alltraps>

c0103215 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103215:	6a 00                	push   $0x0
  pushl $198
c0103217:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010321c:	e9 ac 02 00 00       	jmp    c01034cd <__alltraps>

c0103221 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103221:	6a 00                	push   $0x0
  pushl $199
c0103223:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103228:	e9 a0 02 00 00       	jmp    c01034cd <__alltraps>

c010322d <vector200>:
.globl vector200
vector200:
  pushl $0
c010322d:	6a 00                	push   $0x0
  pushl $200
c010322f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103234:	e9 94 02 00 00       	jmp    c01034cd <__alltraps>

c0103239 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103239:	6a 00                	push   $0x0
  pushl $201
c010323b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103240:	e9 88 02 00 00       	jmp    c01034cd <__alltraps>

c0103245 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103245:	6a 00                	push   $0x0
  pushl $202
c0103247:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010324c:	e9 7c 02 00 00       	jmp    c01034cd <__alltraps>

c0103251 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103251:	6a 00                	push   $0x0
  pushl $203
c0103253:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103258:	e9 70 02 00 00       	jmp    c01034cd <__alltraps>

c010325d <vector204>:
.globl vector204
vector204:
  pushl $0
c010325d:	6a 00                	push   $0x0
  pushl $204
c010325f:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103264:	e9 64 02 00 00       	jmp    c01034cd <__alltraps>

c0103269 <vector205>:
.globl vector205
vector205:
  pushl $0
c0103269:	6a 00                	push   $0x0
  pushl $205
c010326b:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103270:	e9 58 02 00 00       	jmp    c01034cd <__alltraps>

c0103275 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103275:	6a 00                	push   $0x0
  pushl $206
c0103277:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010327c:	e9 4c 02 00 00       	jmp    c01034cd <__alltraps>

c0103281 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103281:	6a 00                	push   $0x0
  pushl $207
c0103283:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0103288:	e9 40 02 00 00       	jmp    c01034cd <__alltraps>

c010328d <vector208>:
.globl vector208
vector208:
  pushl $0
c010328d:	6a 00                	push   $0x0
  pushl $208
c010328f:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103294:	e9 34 02 00 00       	jmp    c01034cd <__alltraps>

c0103299 <vector209>:
.globl vector209
vector209:
  pushl $0
c0103299:	6a 00                	push   $0x0
  pushl $209
c010329b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01032a0:	e9 28 02 00 00       	jmp    c01034cd <__alltraps>

c01032a5 <vector210>:
.globl vector210
vector210:
  pushl $0
c01032a5:	6a 00                	push   $0x0
  pushl $210
c01032a7:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01032ac:	e9 1c 02 00 00       	jmp    c01034cd <__alltraps>

c01032b1 <vector211>:
.globl vector211
vector211:
  pushl $0
c01032b1:	6a 00                	push   $0x0
  pushl $211
c01032b3:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01032b8:	e9 10 02 00 00       	jmp    c01034cd <__alltraps>

c01032bd <vector212>:
.globl vector212
vector212:
  pushl $0
c01032bd:	6a 00                	push   $0x0
  pushl $212
c01032bf:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01032c4:	e9 04 02 00 00       	jmp    c01034cd <__alltraps>

c01032c9 <vector213>:
.globl vector213
vector213:
  pushl $0
c01032c9:	6a 00                	push   $0x0
  pushl $213
c01032cb:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01032d0:	e9 f8 01 00 00       	jmp    c01034cd <__alltraps>

c01032d5 <vector214>:
.globl vector214
vector214:
  pushl $0
c01032d5:	6a 00                	push   $0x0
  pushl $214
c01032d7:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01032dc:	e9 ec 01 00 00       	jmp    c01034cd <__alltraps>

c01032e1 <vector215>:
.globl vector215
vector215:
  pushl $0
c01032e1:	6a 00                	push   $0x0
  pushl $215
c01032e3:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01032e8:	e9 e0 01 00 00       	jmp    c01034cd <__alltraps>

c01032ed <vector216>:
.globl vector216
vector216:
  pushl $0
c01032ed:	6a 00                	push   $0x0
  pushl $216
c01032ef:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01032f4:	e9 d4 01 00 00       	jmp    c01034cd <__alltraps>

c01032f9 <vector217>:
.globl vector217
vector217:
  pushl $0
c01032f9:	6a 00                	push   $0x0
  pushl $217
c01032fb:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103300:	e9 c8 01 00 00       	jmp    c01034cd <__alltraps>

c0103305 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103305:	6a 00                	push   $0x0
  pushl $218
c0103307:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010330c:	e9 bc 01 00 00       	jmp    c01034cd <__alltraps>

c0103311 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103311:	6a 00                	push   $0x0
  pushl $219
c0103313:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103318:	e9 b0 01 00 00       	jmp    c01034cd <__alltraps>

c010331d <vector220>:
.globl vector220
vector220:
  pushl $0
c010331d:	6a 00                	push   $0x0
  pushl $220
c010331f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103324:	e9 a4 01 00 00       	jmp    c01034cd <__alltraps>

c0103329 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103329:	6a 00                	push   $0x0
  pushl $221
c010332b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103330:	e9 98 01 00 00       	jmp    c01034cd <__alltraps>

c0103335 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103335:	6a 00                	push   $0x0
  pushl $222
c0103337:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010333c:	e9 8c 01 00 00       	jmp    c01034cd <__alltraps>

c0103341 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103341:	6a 00                	push   $0x0
  pushl $223
c0103343:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103348:	e9 80 01 00 00       	jmp    c01034cd <__alltraps>

c010334d <vector224>:
.globl vector224
vector224:
  pushl $0
c010334d:	6a 00                	push   $0x0
  pushl $224
c010334f:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103354:	e9 74 01 00 00       	jmp    c01034cd <__alltraps>

c0103359 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103359:	6a 00                	push   $0x0
  pushl $225
c010335b:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103360:	e9 68 01 00 00       	jmp    c01034cd <__alltraps>

c0103365 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103365:	6a 00                	push   $0x0
  pushl $226
c0103367:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010336c:	e9 5c 01 00 00       	jmp    c01034cd <__alltraps>

c0103371 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103371:	6a 00                	push   $0x0
  pushl $227
c0103373:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103378:	e9 50 01 00 00       	jmp    c01034cd <__alltraps>

c010337d <vector228>:
.globl vector228
vector228:
  pushl $0
c010337d:	6a 00                	push   $0x0
  pushl $228
c010337f:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103384:	e9 44 01 00 00       	jmp    c01034cd <__alltraps>

c0103389 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103389:	6a 00                	push   $0x0
  pushl $229
c010338b:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103390:	e9 38 01 00 00       	jmp    c01034cd <__alltraps>

c0103395 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103395:	6a 00                	push   $0x0
  pushl $230
c0103397:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010339c:	e9 2c 01 00 00       	jmp    c01034cd <__alltraps>

c01033a1 <vector231>:
.globl vector231
vector231:
  pushl $0
c01033a1:	6a 00                	push   $0x0
  pushl $231
c01033a3:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01033a8:	e9 20 01 00 00       	jmp    c01034cd <__alltraps>

c01033ad <vector232>:
.globl vector232
vector232:
  pushl $0
c01033ad:	6a 00                	push   $0x0
  pushl $232
c01033af:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01033b4:	e9 14 01 00 00       	jmp    c01034cd <__alltraps>

c01033b9 <vector233>:
.globl vector233
vector233:
  pushl $0
c01033b9:	6a 00                	push   $0x0
  pushl $233
c01033bb:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01033c0:	e9 08 01 00 00       	jmp    c01034cd <__alltraps>

c01033c5 <vector234>:
.globl vector234
vector234:
  pushl $0
c01033c5:	6a 00                	push   $0x0
  pushl $234
c01033c7:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01033cc:	e9 fc 00 00 00       	jmp    c01034cd <__alltraps>

c01033d1 <vector235>:
.globl vector235
vector235:
  pushl $0
c01033d1:	6a 00                	push   $0x0
  pushl $235
c01033d3:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01033d8:	e9 f0 00 00 00       	jmp    c01034cd <__alltraps>

c01033dd <vector236>:
.globl vector236
vector236:
  pushl $0
c01033dd:	6a 00                	push   $0x0
  pushl $236
c01033df:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01033e4:	e9 e4 00 00 00       	jmp    c01034cd <__alltraps>

c01033e9 <vector237>:
.globl vector237
vector237:
  pushl $0
c01033e9:	6a 00                	push   $0x0
  pushl $237
c01033eb:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01033f0:	e9 d8 00 00 00       	jmp    c01034cd <__alltraps>

c01033f5 <vector238>:
.globl vector238
vector238:
  pushl $0
c01033f5:	6a 00                	push   $0x0
  pushl $238
c01033f7:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01033fc:	e9 cc 00 00 00       	jmp    c01034cd <__alltraps>

c0103401 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103401:	6a 00                	push   $0x0
  pushl $239
c0103403:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103408:	e9 c0 00 00 00       	jmp    c01034cd <__alltraps>

c010340d <vector240>:
.globl vector240
vector240:
  pushl $0
c010340d:	6a 00                	push   $0x0
  pushl $240
c010340f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103414:	e9 b4 00 00 00       	jmp    c01034cd <__alltraps>

c0103419 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103419:	6a 00                	push   $0x0
  pushl $241
c010341b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103420:	e9 a8 00 00 00       	jmp    c01034cd <__alltraps>

c0103425 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103425:	6a 00                	push   $0x0
  pushl $242
c0103427:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010342c:	e9 9c 00 00 00       	jmp    c01034cd <__alltraps>

c0103431 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103431:	6a 00                	push   $0x0
  pushl $243
c0103433:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103438:	e9 90 00 00 00       	jmp    c01034cd <__alltraps>

c010343d <vector244>:
.globl vector244
vector244:
  pushl $0
c010343d:	6a 00                	push   $0x0
  pushl $244
c010343f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103444:	e9 84 00 00 00       	jmp    c01034cd <__alltraps>

c0103449 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103449:	6a 00                	push   $0x0
  pushl $245
c010344b:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103450:	e9 78 00 00 00       	jmp    c01034cd <__alltraps>

c0103455 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103455:	6a 00                	push   $0x0
  pushl $246
c0103457:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010345c:	e9 6c 00 00 00       	jmp    c01034cd <__alltraps>

c0103461 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103461:	6a 00                	push   $0x0
  pushl $247
c0103463:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103468:	e9 60 00 00 00       	jmp    c01034cd <__alltraps>

c010346d <vector248>:
.globl vector248
vector248:
  pushl $0
c010346d:	6a 00                	push   $0x0
  pushl $248
c010346f:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103474:	e9 54 00 00 00       	jmp    c01034cd <__alltraps>

c0103479 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103479:	6a 00                	push   $0x0
  pushl $249
c010347b:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103480:	e9 48 00 00 00       	jmp    c01034cd <__alltraps>

c0103485 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103485:	6a 00                	push   $0x0
  pushl $250
c0103487:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010348c:	e9 3c 00 00 00       	jmp    c01034cd <__alltraps>

c0103491 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103491:	6a 00                	push   $0x0
  pushl $251
c0103493:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103498:	e9 30 00 00 00       	jmp    c01034cd <__alltraps>

c010349d <vector252>:
.globl vector252
vector252:
  pushl $0
c010349d:	6a 00                	push   $0x0
  pushl $252
c010349f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01034a4:	e9 24 00 00 00       	jmp    c01034cd <__alltraps>

c01034a9 <vector253>:
.globl vector253
vector253:
  pushl $0
c01034a9:	6a 00                	push   $0x0
  pushl $253
c01034ab:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01034b0:	e9 18 00 00 00       	jmp    c01034cd <__alltraps>

c01034b5 <vector254>:
.globl vector254
vector254:
  pushl $0
c01034b5:	6a 00                	push   $0x0
  pushl $254
c01034b7:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01034bc:	e9 0c 00 00 00       	jmp    c01034cd <__alltraps>

c01034c1 <vector255>:
.globl vector255
vector255:
  pushl $0
c01034c1:	6a 00                	push   $0x0
  pushl $255
c01034c3:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01034c8:	e9 00 00 00 00       	jmp    c01034cd <__alltraps>

c01034cd <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01034cd:	1e                   	push   %ds
    pushl %es
c01034ce:	06                   	push   %es
    pushl %fs
c01034cf:	0f a0                	push   %fs
    pushl %gs
c01034d1:	0f a8                	push   %gs
    pushal
c01034d3:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01034d4:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01034d9:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01034db:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01034dd:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01034de:	e8 ed f4 ff ff       	call   c01029d0 <trap>

    # pop the pushed stack pointer
    popl %esp
c01034e3:	5c                   	pop    %esp

c01034e4 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01034e4:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01034e5:	0f a9                	pop    %gs
    popl %fs
c01034e7:	0f a1                	pop    %fs
    popl %es
c01034e9:	07                   	pop    %es
    popl %ds
c01034ea:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01034eb:	83 c4 08             	add    $0x8,%esp
    iret
c01034ee:	cf                   	iret   

c01034ef <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c01034ef:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01034f3:	eb ef                	jmp    c01034e4 <__trapret>

c01034f5 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c01034f5:	55                   	push   %ebp
c01034f6:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c01034f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01034fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c0103501:	90                   	nop
c0103502:	5d                   	pop    %ebp
c0103503:	c3                   	ret    

c0103504 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0103504:	55                   	push   %ebp
c0103505:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0103507:	8b 45 08             	mov    0x8(%ebp),%eax
c010350a:	8b 40 18             	mov    0x18(%eax),%eax
}
c010350d:	5d                   	pop    %ebp
c010350e:	c3                   	ret    

c010350f <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c010350f:	55                   	push   %ebp
c0103510:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c0103512:	8b 45 08             	mov    0x8(%ebp),%eax
c0103515:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103518:	89 50 18             	mov    %edx,0x18(%eax)
}
c010351b:	90                   	nop
c010351c:	5d                   	pop    %ebp
c010351d:	c3                   	ret    

c010351e <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010351e:	55                   	push   %ebp
c010351f:	89 e5                	mov    %esp,%ebp
c0103521:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103524:	8b 45 08             	mov    0x8(%ebp),%eax
c0103527:	c1 e8 0c             	shr    $0xc,%eax
c010352a:	89 c2                	mov    %eax,%edx
c010352c:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0103531:	39 c2                	cmp    %eax,%edx
c0103533:	72 1c                	jb     c0103551 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103535:	c7 44 24 08 90 c9 10 	movl   $0xc010c990,0x8(%esp)
c010353c:	c0 
c010353d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0103544:	00 
c0103545:	c7 04 24 af c9 10 c0 	movl   $0xc010c9af,(%esp)
c010354c:	e8 af ce ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c0103551:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c0103556:	8b 55 08             	mov    0x8(%ebp),%edx
c0103559:	c1 ea 0c             	shr    $0xc,%edx
c010355c:	c1 e2 05             	shl    $0x5,%edx
c010355f:	01 d0                	add    %edx,%eax
}
c0103561:	c9                   	leave  
c0103562:	c3                   	ret    

c0103563 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0103563:	55                   	push   %ebp
c0103564:	89 e5                	mov    %esp,%ebp
c0103566:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103569:	8b 45 08             	mov    0x8(%ebp),%eax
c010356c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103571:	89 04 24             	mov    %eax,(%esp)
c0103574:	e8 a5 ff ff ff       	call   c010351e <pa2page>
}
c0103579:	c9                   	leave  
c010357a:	c3                   	ret    

c010357b <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010357b:	55                   	push   %ebp
c010357c:	89 e5                	mov    %esp,%ebp
c010357e:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103581:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0103588:	e8 c3 1e 00 00       	call   c0105450 <kmalloc>
c010358d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103590:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103594:	74 79                	je     c010360f <mm_create+0x94>
        list_init(&(mm->mmap_list));
c0103596:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103599:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010359c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010359f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01035a2:	89 50 04             	mov    %edx,0x4(%eax)
c01035a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035a8:	8b 50 04             	mov    0x4(%eax),%edx
c01035ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035ae:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01035b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01035ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035bd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01035c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035c7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01035ce:	a1 6c ff 19 c0       	mov    0xc019ff6c,%eax
c01035d3:	85 c0                	test   %eax,%eax
c01035d5:	74 0d                	je     c01035e4 <mm_create+0x69>
c01035d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035da:	89 04 24             	mov    %eax,(%esp)
c01035dd:	e8 f2 20 00 00       	call   c01056d4 <swap_init_mm>
c01035e2:	eb 0a                	jmp    c01035ee <mm_create+0x73>
        else mm->sm_priv = NULL;
c01035e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c01035ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01035f5:	00 
c01035f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f9:	89 04 24             	mov    %eax,(%esp)
c01035fc:	e8 0e ff ff ff       	call   c010350f <set_mm_count>
        lock_init(&(mm->mm_lock));
c0103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103604:	83 c0 1c             	add    $0x1c,%eax
c0103607:	89 04 24             	mov    %eax,(%esp)
c010360a:	e8 e6 fe ff ff       	call   c01034f5 <lock_init>
    }    
    return mm;
c010360f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103612:	c9                   	leave  
c0103613:	c3                   	ret    

c0103614 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0103614:	55                   	push   %ebp
c0103615:	89 e5                	mov    %esp,%ebp
c0103617:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c010361a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0103621:	e8 2a 1e 00 00       	call   c0105450 <kmalloc>
c0103626:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0103629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010362d:	74 1b                	je     c010364a <vma_create+0x36>
        vma->vm_start = vm_start;
c010362f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103632:	8b 55 08             	mov    0x8(%ebp),%edx
c0103635:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0103638:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010363e:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0103641:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103644:	8b 55 10             	mov    0x10(%ebp),%edx
c0103647:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010364d:	c9                   	leave  
c010364e:	c3                   	ret    

c010364f <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010364f:	55                   	push   %ebp
c0103650:	89 e5                	mov    %esp,%ebp
c0103652:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0103655:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010365c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103660:	0f 84 95 00 00 00    	je     c01036fb <find_vma+0xac>
        vma = mm->mmap_cache;
c0103666:	8b 45 08             	mov    0x8(%ebp),%eax
c0103669:	8b 40 08             	mov    0x8(%eax),%eax
c010366c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c010366f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103673:	74 16                	je     c010368b <find_vma+0x3c>
c0103675:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103678:	8b 40 04             	mov    0x4(%eax),%eax
c010367b:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010367e:	72 0b                	jb     c010368b <find_vma+0x3c>
c0103680:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103683:	8b 40 08             	mov    0x8(%eax),%eax
c0103686:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0103689:	72 61                	jb     c01036ec <find_vma+0x9d>
                bool found = 0;
c010368b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0103692:	8b 45 08             	mov    0x8(%ebp),%eax
c0103695:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103698:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010369b:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010369e:	eb 28                	jmp    c01036c8 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01036a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a3:	83 e8 10             	sub    $0x10,%eax
c01036a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01036a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036ac:	8b 40 04             	mov    0x4(%eax),%eax
c01036af:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01036b2:	72 14                	jb     c01036c8 <find_vma+0x79>
c01036b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036b7:	8b 40 08             	mov    0x8(%eax),%eax
c01036ba:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01036bd:	73 09                	jae    c01036c8 <find_vma+0x79>
                        found = 1;
c01036bf:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01036c6:	eb 17                	jmp    c01036df <find_vma+0x90>
c01036c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01036ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036d1:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c01036d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036da:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01036dd:	75 c1                	jne    c01036a0 <find_vma+0x51>
                    }
                }
                if (!found) {
c01036df:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01036e3:	75 07                	jne    c01036ec <find_vma+0x9d>
                    vma = NULL;
c01036e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01036ec:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01036f0:	74 09                	je     c01036fb <find_vma+0xac>
            mm->mmap_cache = vma;
c01036f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01036f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01036f8:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01036fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01036fe:	c9                   	leave  
c01036ff:	c3                   	ret    

c0103700 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0103700:	55                   	push   %ebp
c0103701:	89 e5                	mov    %esp,%ebp
c0103703:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0103706:	8b 45 08             	mov    0x8(%ebp),%eax
c0103709:	8b 50 04             	mov    0x4(%eax),%edx
c010370c:	8b 45 08             	mov    0x8(%ebp),%eax
c010370f:	8b 40 08             	mov    0x8(%eax),%eax
c0103712:	39 c2                	cmp    %eax,%edx
c0103714:	72 24                	jb     c010373a <check_vma_overlap+0x3a>
c0103716:	c7 44 24 0c bd c9 10 	movl   $0xc010c9bd,0xc(%esp)
c010371d:	c0 
c010371e:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103725:	c0 
c0103726:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010372d:	00 
c010372e:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103735:	e8 c6 cc ff ff       	call   c0100400 <__panic>
    assert(prev->vm_end <= next->vm_start);
c010373a:	8b 45 08             	mov    0x8(%ebp),%eax
c010373d:	8b 50 08             	mov    0x8(%eax),%edx
c0103740:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103743:	8b 40 04             	mov    0x4(%eax),%eax
c0103746:	39 c2                	cmp    %eax,%edx
c0103748:	76 24                	jbe    c010376e <check_vma_overlap+0x6e>
c010374a:	c7 44 24 0c 00 ca 10 	movl   $0xc010ca00,0xc(%esp)
c0103751:	c0 
c0103752:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103759:	c0 
c010375a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103761:	00 
c0103762:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103769:	e8 92 cc ff ff       	call   c0100400 <__panic>
    assert(next->vm_start < next->vm_end);
c010376e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103771:	8b 50 04             	mov    0x4(%eax),%edx
c0103774:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103777:	8b 40 08             	mov    0x8(%eax),%eax
c010377a:	39 c2                	cmp    %eax,%edx
c010377c:	72 24                	jb     c01037a2 <check_vma_overlap+0xa2>
c010377e:	c7 44 24 0c 1f ca 10 	movl   $0xc010ca1f,0xc(%esp)
c0103785:	c0 
c0103786:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c010378d:	c0 
c010378e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103795:	00 
c0103796:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c010379d:	e8 5e cc ff ff       	call   c0100400 <__panic>
}
c01037a2:	90                   	nop
c01037a3:	c9                   	leave  
c01037a4:	c3                   	ret    

c01037a5 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01037a5:	55                   	push   %ebp
c01037a6:	89 e5                	mov    %esp,%ebp
c01037a8:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01037ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037ae:	8b 50 04             	mov    0x4(%eax),%edx
c01037b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037b4:	8b 40 08             	mov    0x8(%eax),%eax
c01037b7:	39 c2                	cmp    %eax,%edx
c01037b9:	72 24                	jb     c01037df <insert_vma_struct+0x3a>
c01037bb:	c7 44 24 0c 3d ca 10 	movl   $0xc010ca3d,0xc(%esp)
c01037c2:	c0 
c01037c3:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c01037ca:	c0 
c01037cb:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01037d2:	00 
c01037d3:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c01037da:	e8 21 cc ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01037df:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01037e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037e8:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01037eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01037f1:	eb 1f                	jmp    c0103812 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01037f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037f6:	83 e8 10             	sub    $0x10,%eax
c01037f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01037fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037ff:	8b 50 04             	mov    0x4(%eax),%edx
c0103802:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103805:	8b 40 04             	mov    0x4(%eax),%eax
c0103808:	39 c2                	cmp    %eax,%edx
c010380a:	77 1f                	ja     c010382b <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c010380c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010380f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103812:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103815:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103818:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010381b:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c010381e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103821:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103824:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103827:	75 ca                	jne    c01037f3 <insert_vma_struct+0x4e>
c0103829:	eb 01                	jmp    c010382c <insert_vma_struct+0x87>
                break;
c010382b:	90                   	nop
c010382c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010382f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103832:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103835:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0103838:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c010383b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010383e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103841:	74 15                	je     c0103858 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0103843:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103846:	8d 50 f0             	lea    -0x10(%eax),%edx
c0103849:	8b 45 0c             	mov    0xc(%ebp),%eax
c010384c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103850:	89 14 24             	mov    %edx,(%esp)
c0103853:	e8 a8 fe ff ff       	call   c0103700 <check_vma_overlap>
    }
    if (le_next != list) {
c0103858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010385b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010385e:	74 15                	je     c0103875 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0103860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103863:	83 e8 10             	sub    $0x10,%eax
c0103866:	89 44 24 04          	mov    %eax,0x4(%esp)
c010386a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010386d:	89 04 24             	mov    %eax,(%esp)
c0103870:	e8 8b fe ff ff       	call   c0103700 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0103875:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103878:	8b 55 08             	mov    0x8(%ebp),%edx
c010387b:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010387d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103880:	8d 50 10             	lea    0x10(%eax),%edx
c0103883:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103886:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103889:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c010388c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010388f:	8b 40 04             	mov    0x4(%eax),%eax
c0103892:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103895:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0103898:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010389b:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010389e:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01038a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038a7:	89 10                	mov    %edx,(%eax)
c01038a9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038ac:	8b 10                	mov    (%eax),%edx
c01038ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038b1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01038b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038b7:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01038ba:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01038bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038c0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01038c3:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01038c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c8:	8b 40 10             	mov    0x10(%eax),%eax
c01038cb:	8d 50 01             	lea    0x1(%eax),%edx
c01038ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01038d1:	89 50 10             	mov    %edx,0x10(%eax)
}
c01038d4:	90                   	nop
c01038d5:	c9                   	leave  
c01038d6:	c3                   	ret    

c01038d7 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01038d7:	55                   	push   %ebp
c01038d8:	89 e5                	mov    %esp,%ebp
c01038da:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c01038dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01038e0:	89 04 24             	mov    %eax,(%esp)
c01038e3:	e8 1c fc ff ff       	call   c0103504 <mm_count>
c01038e8:	85 c0                	test   %eax,%eax
c01038ea:	74 24                	je     c0103910 <mm_destroy+0x39>
c01038ec:	c7 44 24 0c 59 ca 10 	movl   $0xc010ca59,0xc(%esp)
c01038f3:	c0 
c01038f4:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c01038fb:	c0 
c01038fc:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0103903:	00 
c0103904:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c010390b:	e8 f0 ca ff ff       	call   c0100400 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c0103910:	8b 45 08             	mov    0x8(%ebp),%eax
c0103913:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0103916:	eb 36                	jmp    c010394e <mm_destroy+0x77>
c0103918:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010391b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c010391e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103921:	8b 40 04             	mov    0x4(%eax),%eax
c0103924:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103927:	8b 12                	mov    (%edx),%edx
c0103929:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010392c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010392f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103932:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103935:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010393b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010393e:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0103940:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103943:	83 e8 10             	sub    $0x10,%eax
c0103946:	89 04 24             	mov    %eax,(%esp)
c0103949:	e8 1d 1b 00 00       	call   c010546b <kfree>
c010394e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103951:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103954:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103957:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c010395a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010395d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103960:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103963:	75 b3                	jne    c0103918 <mm_destroy+0x41>
    }
    kfree(mm); //kfree mm
c0103965:	8b 45 08             	mov    0x8(%ebp),%eax
c0103968:	89 04 24             	mov    %eax,(%esp)
c010396b:	e8 fb 1a 00 00       	call   c010546b <kfree>
    mm=NULL;
c0103970:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0103977:	90                   	nop
c0103978:	c9                   	leave  
c0103979:	c3                   	ret    

c010397a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c010397a:	55                   	push   %ebp
c010397b:	89 e5                	mov    %esp,%ebp
c010397d:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c0103980:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103983:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103986:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103989:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010398e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103991:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0103998:	8b 55 0c             	mov    0xc(%ebp),%edx
c010399b:	8b 45 10             	mov    0x10(%ebp),%eax
c010399e:	01 c2                	add    %eax,%edx
c01039a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039a3:	01 d0                	add    %edx,%eax
c01039a5:	48                   	dec    %eax
c01039a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01039a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039ac:	ba 00 00 00 00       	mov    $0x0,%edx
c01039b1:	f7 75 e8             	divl   -0x18(%ebp)
c01039b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039b7:	29 d0                	sub    %edx,%eax
c01039b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c01039bc:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c01039c3:	76 11                	jbe    c01039d6 <mm_map+0x5c>
c01039c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039c8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01039cb:	73 09                	jae    c01039d6 <mm_map+0x5c>
c01039cd:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c01039d4:	76 0a                	jbe    c01039e0 <mm_map+0x66>
        return -E_INVAL;
c01039d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01039db:	e9 b0 00 00 00       	jmp    c0103a90 <mm_map+0x116>
    }

    assert(mm != NULL);
c01039e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01039e4:	75 24                	jne    c0103a0a <mm_map+0x90>
c01039e6:	c7 44 24 0c 6b ca 10 	movl   $0xc010ca6b,0xc(%esp)
c01039ed:	c0 
c01039ee:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c01039f5:	c0 
c01039f6:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c01039fd:	00 
c01039fe:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103a05:	e8 f6 c9 ff ff       	call   c0100400 <__panic>

    int ret = -E_INVAL;
c0103a0a:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c0103a11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a18:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a1b:	89 04 24             	mov    %eax,(%esp)
c0103a1e:	e8 2c fc ff ff       	call   c010364f <find_vma>
c0103a23:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a26:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a2a:	74 0b                	je     c0103a37 <mm_map+0xbd>
c0103a2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a2f:	8b 40 04             	mov    0x4(%eax),%eax
c0103a32:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103a35:	77 52                	ja     c0103a89 <mm_map+0x10f>
        goto out;
    }
    ret = -E_NO_MEM;
c0103a37:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0103a3e:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a41:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103a45:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a4f:	89 04 24             	mov    %eax,(%esp)
c0103a52:	e8 bd fb ff ff       	call   c0103614 <vma_create>
c0103a57:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a5a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a5e:	74 2c                	je     c0103a8c <mm_map+0x112>
        goto out;
    }
    insert_vma_struct(mm, vma);
c0103a60:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a67:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a6a:	89 04 24             	mov    %eax,(%esp)
c0103a6d:	e8 33 fd ff ff       	call   c01037a5 <insert_vma_struct>
    if (vma_store != NULL) {
c0103a72:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103a76:	74 08                	je     c0103a80 <mm_map+0x106>
        *vma_store = vma;
c0103a78:	8b 45 18             	mov    0x18(%ebp),%eax
c0103a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103a7e:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0103a80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a87:	eb 04                	jmp    c0103a8d <mm_map+0x113>
        goto out;
c0103a89:	90                   	nop
c0103a8a:	eb 01                	jmp    c0103a8d <mm_map+0x113>
        goto out;
c0103a8c:	90                   	nop

out:
    return ret;
c0103a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103a90:	c9                   	leave  
c0103a91:	c3                   	ret    

c0103a92 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0103a92:	55                   	push   %ebp
c0103a93:	89 e5                	mov    %esp,%ebp
c0103a95:	56                   	push   %esi
c0103a96:	53                   	push   %ebx
c0103a97:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0103a9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103a9e:	74 06                	je     c0103aa6 <dup_mmap+0x14>
c0103aa0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103aa4:	75 24                	jne    c0103aca <dup_mmap+0x38>
c0103aa6:	c7 44 24 0c 76 ca 10 	movl   $0xc010ca76,0xc(%esp)
c0103aad:	c0 
c0103aae:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103ab5:	c0 
c0103ab6:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103abd:	00 
c0103abe:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103ac5:	e8 36 c9 ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0103aca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0103ad6:	e9 92 00 00 00       	jmp    c0103b6d <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ade:	83 e8 10             	sub    $0x10,%eax
c0103ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0103ae4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ae7:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103aea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103aed:	8b 50 08             	mov    0x8(%eax),%edx
c0103af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103af3:	8b 40 04             	mov    0x4(%eax),%eax
c0103af6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103afa:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103afe:	89 04 24             	mov    %eax,(%esp)
c0103b01:	e8 0e fb ff ff       	call   c0103614 <vma_create>
c0103b06:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0103b09:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103b0d:	75 07                	jne    c0103b16 <dup_mmap+0x84>
            return -E_NO_MEM;
c0103b0f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103b14:	eb 76                	jmp    c0103b8c <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c0103b16:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b20:	89 04 24             	mov    %eax,(%esp)
c0103b23:	e8 7d fc ff ff       	call   c01037a5 <insert_vma_struct>

        bool share = 0;
c0103b28:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c0103b2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b32:	8b 58 08             	mov    0x8(%eax),%ebx
c0103b35:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b38:	8b 48 04             	mov    0x4(%eax),%ecx
c0103b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b3e:	8b 50 0c             	mov    0xc(%eax),%edx
c0103b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b44:	8b 40 0c             	mov    0xc(%eax),%eax
c0103b47:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0103b4a:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103b4e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103b52:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103b56:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b5a:	89 04 24             	mov    %eax,(%esp)
c0103b5d:	e8 6a 46 00 00       	call   c01081cc <copy_range>
c0103b62:	85 c0                	test   %eax,%eax
c0103b64:	74 07                	je     c0103b6d <dup_mmap+0xdb>
            return -E_NO_MEM;
c0103b66:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103b6b:	eb 1f                	jmp    c0103b8c <dup_mmap+0xfa>
c0103b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b70:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0103b73:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b76:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list) {
c0103b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b7e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103b81:	0f 85 54 ff ff ff    	jne    c0103adb <dup_mmap+0x49>
        }
    }
    return 0;
c0103b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103b8c:	83 c4 40             	add    $0x40,%esp
c0103b8f:	5b                   	pop    %ebx
c0103b90:	5e                   	pop    %esi
c0103b91:	5d                   	pop    %ebp
c0103b92:	c3                   	ret    

c0103b93 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0103b93:	55                   	push   %ebp
c0103b94:	89 e5                	mov    %esp,%ebp
c0103b96:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0103b99:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103b9d:	74 0f                	je     c0103bae <exit_mmap+0x1b>
c0103b9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba2:	89 04 24             	mov    %eax,(%esp)
c0103ba5:	e8 5a f9 ff ff       	call   c0103504 <mm_count>
c0103baa:	85 c0                	test   %eax,%eax
c0103bac:	74 24                	je     c0103bd2 <exit_mmap+0x3f>
c0103bae:	c7 44 24 0c 94 ca 10 	movl   $0xc010ca94,0xc(%esp)
c0103bb5:	c0 
c0103bb6:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103bbd:	c0 
c0103bbe:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103bc5:	00 
c0103bc6:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103bcd:	e8 2e c8 ff ff       	call   c0100400 <__panic>
    pde_t *pgdir = mm->pgdir;
c0103bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd5:	8b 40 0c             	mov    0xc(%eax),%eax
c0103bd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0103bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bde:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103be4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0103be7:	eb 28                	jmp    c0103c11 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c0103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bec:	83 e8 10             	sub    $0x10,%eax
c0103bef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0103bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bf5:	8b 50 08             	mov    0x8(%eax),%edx
c0103bf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bfb:	8b 40 04             	mov    0x4(%eax),%eax
c0103bfe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c09:	89 04 24             	mov    %eax,(%esp)
c0103c0c:	e8 be 43 00 00       	call   c0107fcf <unmap_range>
c0103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c14:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103c17:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c1a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0103c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103c26:	75 c1                	jne    c0103be9 <exit_mmap+0x56>
    }
    while ((le = list_next(le)) != list) {
c0103c28:	eb 28                	jmp    c0103c52 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c0103c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c2d:	83 e8 10             	sub    $0x10,%eax
c0103c30:	89 45 e8             	mov    %eax,-0x18(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0103c33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c36:	8b 50 08             	mov    0x8(%eax),%edx
c0103c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c3c:	8b 40 04             	mov    0x4(%eax),%eax
c0103c3f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c4a:	89 04 24             	mov    %eax,(%esp)
c0103c4d:	e8 72 44 00 00       	call   c01080c4 <exit_range>
c0103c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c55:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103c58:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c5b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0103c5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c64:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103c67:	75 c1                	jne    c0103c2a <exit_mmap+0x97>
    }
}
c0103c69:	90                   	nop
c0103c6a:	c9                   	leave  
c0103c6b:	c3                   	ret    

c0103c6c <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0103c6c:	55                   	push   %ebp
c0103c6d:	89 e5                	mov    %esp,%ebp
c0103c6f:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0103c72:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c75:	8b 55 18             	mov    0x18(%ebp),%edx
c0103c78:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103c7c:	8b 55 14             	mov    0x14(%ebp),%edx
c0103c7f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c8a:	89 04 24             	mov    %eax,(%esp)
c0103c8d:	e8 9d 09 00 00       	call   c010462f <user_mem_check>
c0103c92:	85 c0                	test   %eax,%eax
c0103c94:	75 07                	jne    c0103c9d <copy_from_user+0x31>
        return 0;
c0103c96:	b8 00 00 00 00       	mov    $0x0,%eax
c0103c9b:	eb 1e                	jmp    c0103cbb <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0103c9d:	8b 45 14             	mov    0x14(%ebp),%eax
c0103ca0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103ca4:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103cae:	89 04 24             	mov    %eax,(%esp)
c0103cb1:	e8 6a 7b 00 00       	call   c010b820 <memcpy>
    return 1;
c0103cb6:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103cbb:	c9                   	leave  
c0103cbc:	c3                   	ret    

c0103cbd <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0103cbd:	55                   	push   %ebp
c0103cbe:	89 e5                	mov    %esp,%ebp
c0103cc0:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0103cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103cc6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103ccd:	00 
c0103cce:	8b 55 14             	mov    0x14(%ebp),%edx
c0103cd1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cdc:	89 04 24             	mov    %eax,(%esp)
c0103cdf:	e8 4b 09 00 00       	call   c010462f <user_mem_check>
c0103ce4:	85 c0                	test   %eax,%eax
c0103ce6:	75 07                	jne    c0103cef <copy_to_user+0x32>
        return 0;
c0103ce8:	b8 00 00 00 00       	mov    $0x0,%eax
c0103ced:	eb 1e                	jmp    c0103d0d <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c0103cef:	8b 45 14             	mov    0x14(%ebp),%eax
c0103cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103cf6:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d00:	89 04 24             	mov    %eax,(%esp)
c0103d03:	e8 18 7b 00 00       	call   c010b820 <memcpy>
    return 1;
c0103d08:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103d0d:	c9                   	leave  
c0103d0e:	c3                   	ret    

c0103d0f <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103d0f:	55                   	push   %ebp
c0103d10:	89 e5                	mov    %esp,%ebp
c0103d12:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103d15:	e8 03 00 00 00       	call   c0103d1d <check_vmm>
}
c0103d1a:	90                   	nop
c0103d1b:	c9                   	leave  
c0103d1c:	c3                   	ret    

c0103d1d <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0103d1d:	55                   	push   %ebp
c0103d1e:	89 e5                	mov    %esp,%ebp
c0103d20:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d23:	e8 71 3a 00 00       	call   c0107799 <nr_free_pages>
c0103d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0103d2b:	e8 14 00 00 00       	call   c0103d44 <check_vma_struct>
    check_pgfault();
c0103d30:	e8 a1 04 00 00       	call   c01041d6 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0103d35:	c7 04 24 b4 ca 10 c0 	movl   $0xc010cab4,(%esp)
c0103d3c:	e8 68 c5 ff ff       	call   c01002a9 <cprintf>
}
c0103d41:	90                   	nop
c0103d42:	c9                   	leave  
c0103d43:	c3                   	ret    

c0103d44 <check_vma_struct>:

static void
check_vma_struct(void) {
c0103d44:	55                   	push   %ebp
c0103d45:	89 e5                	mov    %esp,%ebp
c0103d47:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d4a:	e8 4a 3a 00 00       	call   c0107799 <nr_free_pages>
c0103d4f:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103d52:	e8 24 f8 ff ff       	call   c010357b <mm_create>
c0103d57:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103d5a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d5e:	75 24                	jne    c0103d84 <check_vma_struct+0x40>
c0103d60:	c7 44 24 0c 6b ca 10 	movl   $0xc010ca6b,0xc(%esp)
c0103d67:	c0 
c0103d68:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103d6f:	c0 
c0103d70:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103d77:	00 
c0103d78:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103d7f:	e8 7c c6 ff ff       	call   c0100400 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103d84:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103d8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103d8e:	89 d0                	mov    %edx,%eax
c0103d90:	c1 e0 02             	shl    $0x2,%eax
c0103d93:	01 d0                	add    %edx,%eax
c0103d95:	01 c0                	add    %eax,%eax
c0103d97:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0103d9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103da0:	eb 6f                	jmp    c0103e11 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103da5:	89 d0                	mov    %edx,%eax
c0103da7:	c1 e0 02             	shl    $0x2,%eax
c0103daa:	01 d0                	add    %edx,%eax
c0103dac:	83 c0 02             	add    $0x2,%eax
c0103daf:	89 c1                	mov    %eax,%ecx
c0103db1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103db4:	89 d0                	mov    %edx,%eax
c0103db6:	c1 e0 02             	shl    $0x2,%eax
c0103db9:	01 d0                	add    %edx,%eax
c0103dbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103dc2:	00 
c0103dc3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103dc7:	89 04 24             	mov    %eax,(%esp)
c0103dca:	e8 45 f8 ff ff       	call   c0103614 <vma_create>
c0103dcf:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0103dd2:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103dd6:	75 24                	jne    c0103dfc <check_vma_struct+0xb8>
c0103dd8:	c7 44 24 0c cc ca 10 	movl   $0xc010cacc,0xc(%esp)
c0103ddf:	c0 
c0103de0:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103de7:	c0 
c0103de8:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0103def:	00 
c0103df0:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103df7:	e8 04 c6 ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103dfc:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103dff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e03:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e06:	89 04 24             	mov    %eax,(%esp)
c0103e09:	e8 97 f9 ff ff       	call   c01037a5 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0103e0e:	ff 4d f4             	decl   -0xc(%ebp)
c0103e11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e15:	7f 8b                	jg     c0103da2 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e1a:	40                   	inc    %eax
c0103e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e1e:	eb 6f                	jmp    c0103e8f <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e23:	89 d0                	mov    %edx,%eax
c0103e25:	c1 e0 02             	shl    $0x2,%eax
c0103e28:	01 d0                	add    %edx,%eax
c0103e2a:	83 c0 02             	add    $0x2,%eax
c0103e2d:	89 c1                	mov    %eax,%ecx
c0103e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e32:	89 d0                	mov    %edx,%eax
c0103e34:	c1 e0 02             	shl    $0x2,%eax
c0103e37:	01 d0                	add    %edx,%eax
c0103e39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e40:	00 
c0103e41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e45:	89 04 24             	mov    %eax,(%esp)
c0103e48:	e8 c7 f7 ff ff       	call   c0103614 <vma_create>
c0103e4d:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0103e50:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0103e54:	75 24                	jne    c0103e7a <check_vma_struct+0x136>
c0103e56:	c7 44 24 0c cc ca 10 	movl   $0xc010cacc,0xc(%esp)
c0103e5d:	c0 
c0103e5e:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103e65:	c0 
c0103e66:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103e6d:	00 
c0103e6e:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103e75:	e8 86 c5 ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103e7a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e84:	89 04 24             	mov    %eax,(%esp)
c0103e87:	e8 19 f9 ff ff       	call   c01037a5 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0103e8c:	ff 45 f4             	incl   -0xc(%ebp)
c0103e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e92:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103e95:	7e 89                	jle    c0103e20 <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103e97:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e9a:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103e9d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ea0:	8b 40 04             	mov    0x4(%eax),%eax
c0103ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103ea6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103ead:	e9 96 00 00 00       	jmp    c0103f48 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0103eb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103eb5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103eb8:	75 24                	jne    c0103ede <check_vma_struct+0x19a>
c0103eba:	c7 44 24 0c d8 ca 10 	movl   $0xc010cad8,0xc(%esp)
c0103ec1:	c0 
c0103ec2:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103ec9:	c0 
c0103eca:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0103ed1:	00 
c0103ed2:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103ed9:	e8 22 c5 ff ff       	call   c0100400 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ee1:	83 e8 10             	sub    $0x10,%eax
c0103ee4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103ee7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103eea:	8b 48 04             	mov    0x4(%eax),%ecx
c0103eed:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ef0:	89 d0                	mov    %edx,%eax
c0103ef2:	c1 e0 02             	shl    $0x2,%eax
c0103ef5:	01 d0                	add    %edx,%eax
c0103ef7:	39 c1                	cmp    %eax,%ecx
c0103ef9:	75 17                	jne    c0103f12 <check_vma_struct+0x1ce>
c0103efb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103efe:	8b 48 08             	mov    0x8(%eax),%ecx
c0103f01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f04:	89 d0                	mov    %edx,%eax
c0103f06:	c1 e0 02             	shl    $0x2,%eax
c0103f09:	01 d0                	add    %edx,%eax
c0103f0b:	83 c0 02             	add    $0x2,%eax
c0103f0e:	39 c1                	cmp    %eax,%ecx
c0103f10:	74 24                	je     c0103f36 <check_vma_struct+0x1f2>
c0103f12:	c7 44 24 0c f0 ca 10 	movl   $0xc010caf0,0xc(%esp)
c0103f19:	c0 
c0103f1a:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103f21:	c0 
c0103f22:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103f29:	00 
c0103f2a:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103f31:	e8 ca c4 ff ff       	call   c0100400 <__panic>
c0103f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f39:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103f3c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103f3f:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0103f45:	ff 45 f4             	incl   -0xc(%ebp)
c0103f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f4b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103f4e:	0f 8e 5e ff ff ff    	jle    c0103eb2 <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103f54:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103f5b:	e9 cb 01 00 00       	jmp    c010412b <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0103f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f67:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f6a:	89 04 24             	mov    %eax,(%esp)
c0103f6d:	e8 dd f6 ff ff       	call   c010364f <find_vma>
c0103f72:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0103f75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103f79:	75 24                	jne    c0103f9f <check_vma_struct+0x25b>
c0103f7b:	c7 44 24 0c 25 cb 10 	movl   $0xc010cb25,0xc(%esp)
c0103f82:	c0 
c0103f83:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103f8a:	c0 
c0103f8b:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103f92:	00 
c0103f93:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103f9a:	e8 61 c4 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0103f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fa2:	40                   	inc    %eax
c0103fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103faa:	89 04 24             	mov    %eax,(%esp)
c0103fad:	e8 9d f6 ff ff       	call   c010364f <find_vma>
c0103fb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0103fb5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0103fb9:	75 24                	jne    c0103fdf <check_vma_struct+0x29b>
c0103fbb:	c7 44 24 0c 32 cb 10 	movl   $0xc010cb32,0xc(%esp)
c0103fc2:	c0 
c0103fc3:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0103fca:	c0 
c0103fcb:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0103fd2:	00 
c0103fd3:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0103fda:	e8 21 c4 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0103fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fe2:	83 c0 02             	add    $0x2,%eax
c0103fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fe9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fec:	89 04 24             	mov    %eax,(%esp)
c0103fef:	e8 5b f6 ff ff       	call   c010364f <find_vma>
c0103ff4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0103ff7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103ffb:	74 24                	je     c0104021 <check_vma_struct+0x2dd>
c0103ffd:	c7 44 24 0c 3f cb 10 	movl   $0xc010cb3f,0xc(%esp)
c0104004:	c0 
c0104005:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c010400c:	c0 
c010400d:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104014:	00 
c0104015:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c010401c:	e8 df c3 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0104021:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104024:	83 c0 03             	add    $0x3,%eax
c0104027:	89 44 24 04          	mov    %eax,0x4(%esp)
c010402b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010402e:	89 04 24             	mov    %eax,(%esp)
c0104031:	e8 19 f6 ff ff       	call   c010364f <find_vma>
c0104036:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0104039:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010403d:	74 24                	je     c0104063 <check_vma_struct+0x31f>
c010403f:	c7 44 24 0c 4c cb 10 	movl   $0xc010cb4c,0xc(%esp)
c0104046:	c0 
c0104047:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c010404e:	c0 
c010404f:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104056:	00 
c0104057:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c010405e:	e8 9d c3 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0104063:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104066:	83 c0 04             	add    $0x4,%eax
c0104069:	89 44 24 04          	mov    %eax,0x4(%esp)
c010406d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104070:	89 04 24             	mov    %eax,(%esp)
c0104073:	e8 d7 f5 ff ff       	call   c010364f <find_vma>
c0104078:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c010407b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010407f:	74 24                	je     c01040a5 <check_vma_struct+0x361>
c0104081:	c7 44 24 0c 59 cb 10 	movl   $0xc010cb59,0xc(%esp)
c0104088:	c0 
c0104089:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0104090:	c0 
c0104091:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0104098:	00 
c0104099:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c01040a0:	e8 5b c3 ff ff       	call   c0100400 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01040a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01040a8:	8b 50 04             	mov    0x4(%eax),%edx
c01040ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040ae:	39 c2                	cmp    %eax,%edx
c01040b0:	75 10                	jne    c01040c2 <check_vma_struct+0x37e>
c01040b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01040b5:	8b 40 08             	mov    0x8(%eax),%eax
c01040b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01040bb:	83 c2 02             	add    $0x2,%edx
c01040be:	39 d0                	cmp    %edx,%eax
c01040c0:	74 24                	je     c01040e6 <check_vma_struct+0x3a2>
c01040c2:	c7 44 24 0c 68 cb 10 	movl   $0xc010cb68,0xc(%esp)
c01040c9:	c0 
c01040ca:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c01040d1:	c0 
c01040d2:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01040d9:	00 
c01040da:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c01040e1:	e8 1a c3 ff ff       	call   c0100400 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01040e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01040e9:	8b 50 04             	mov    0x4(%eax),%edx
c01040ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040ef:	39 c2                	cmp    %eax,%edx
c01040f1:	75 10                	jne    c0104103 <check_vma_struct+0x3bf>
c01040f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01040f6:	8b 40 08             	mov    0x8(%eax),%eax
c01040f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01040fc:	83 c2 02             	add    $0x2,%edx
c01040ff:	39 d0                	cmp    %edx,%eax
c0104101:	74 24                	je     c0104127 <check_vma_struct+0x3e3>
c0104103:	c7 44 24 0c 98 cb 10 	movl   $0xc010cb98,0xc(%esp)
c010410a:	c0 
c010410b:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0104112:	c0 
c0104113:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c010411a:	00 
c010411b:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0104122:	e8 d9 c2 ff ff       	call   c0100400 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0104127:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010412b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010412e:	89 d0                	mov    %edx,%eax
c0104130:	c1 e0 02             	shl    $0x2,%eax
c0104133:	01 d0                	add    %edx,%eax
c0104135:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104138:	0f 8e 22 fe ff ff    	jle    c0103f60 <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c010413e:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0104145:	eb 6f                	jmp    c01041b6 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0104147:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010414a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010414e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104151:	89 04 24             	mov    %eax,(%esp)
c0104154:	e8 f6 f4 ff ff       	call   c010364f <find_vma>
c0104159:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c010415c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104160:	74 27                	je     c0104189 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0104162:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104165:	8b 50 08             	mov    0x8(%eax),%edx
c0104168:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010416b:	8b 40 04             	mov    0x4(%eax),%eax
c010416e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0104172:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104176:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104179:	89 44 24 04          	mov    %eax,0x4(%esp)
c010417d:	c7 04 24 c8 cb 10 c0 	movl   $0xc010cbc8,(%esp)
c0104184:	e8 20 c1 ff ff       	call   c01002a9 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0104189:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010418d:	74 24                	je     c01041b3 <check_vma_struct+0x46f>
c010418f:	c7 44 24 0c ed cb 10 	movl   $0xc010cbed,0xc(%esp)
c0104196:	c0 
c0104197:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c010419e:	c0 
c010419f:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c01041a6:	00 
c01041a7:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c01041ae:	e8 4d c2 ff ff       	call   c0100400 <__panic>
    for (i =4; i>=0; i--) {
c01041b3:	ff 4d f4             	decl   -0xc(%ebp)
c01041b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01041ba:	79 8b                	jns    c0104147 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c01041bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041bf:	89 04 24             	mov    %eax,(%esp)
c01041c2:	e8 10 f7 ff ff       	call   c01038d7 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c01041c7:	c7 04 24 04 cc 10 c0 	movl   $0xc010cc04,(%esp)
c01041ce:	e8 d6 c0 ff ff       	call   c01002a9 <cprintf>
}
c01041d3:	90                   	nop
c01041d4:	c9                   	leave  
c01041d5:	c3                   	ret    

c01041d6 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c01041d6:	55                   	push   %ebp
c01041d7:	89 e5                	mov    %esp,%ebp
c01041d9:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01041dc:	e8 b8 35 00 00       	call   c0107799 <nr_free_pages>
c01041e1:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c01041e4:	e8 92 f3 ff ff       	call   c010357b <mm_create>
c01041e9:	a3 58 20 1a c0       	mov    %eax,0xc01a2058
    assert(check_mm_struct != NULL);
c01041ee:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c01041f3:	85 c0                	test   %eax,%eax
c01041f5:	75 24                	jne    c010421b <check_pgfault+0x45>
c01041f7:	c7 44 24 0c 23 cc 10 	movl   $0xc010cc23,0xc(%esp)
c01041fe:	c0 
c01041ff:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0104206:	c0 
c0104207:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c010420e:	00 
c010420f:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0104216:	e8 e5 c1 ff ff       	call   c0100400 <__panic>

    struct mm_struct *mm = check_mm_struct;
c010421b:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c0104220:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104223:	8b 15 20 ba 12 c0    	mov    0xc012ba20,%edx
c0104229:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010422c:	89 50 0c             	mov    %edx,0xc(%eax)
c010422f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104232:	8b 40 0c             	mov    0xc(%eax),%eax
c0104235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0104238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010423b:	8b 00                	mov    (%eax),%eax
c010423d:	85 c0                	test   %eax,%eax
c010423f:	74 24                	je     c0104265 <check_pgfault+0x8f>
c0104241:	c7 44 24 0c 3b cc 10 	movl   $0xc010cc3b,0xc(%esp)
c0104248:	c0 
c0104249:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0104250:	c0 
c0104251:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0104258:	00 
c0104259:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0104260:	e8 9b c1 ff ff       	call   c0100400 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0104265:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c010426c:	00 
c010426d:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0104274:	00 
c0104275:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010427c:	e8 93 f3 ff ff       	call   c0103614 <vma_create>
c0104281:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0104284:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104288:	75 24                	jne    c01042ae <check_pgfault+0xd8>
c010428a:	c7 44 24 0c cc ca 10 	movl   $0xc010cacc,0xc(%esp)
c0104291:	c0 
c0104292:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0104299:	c0 
c010429a:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c01042a1:	00 
c01042a2:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c01042a9:	e8 52 c1 ff ff       	call   c0100400 <__panic>

    insert_vma_struct(mm, vma);
c01042ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042b8:	89 04 24             	mov    %eax,(%esp)
c01042bb:	e8 e5 f4 ff ff       	call   c01037a5 <insert_vma_struct>

    uintptr_t addr = 0x100;
c01042c0:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01042c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042d1:	89 04 24             	mov    %eax,(%esp)
c01042d4:	e8 76 f3 ff ff       	call   c010364f <find_vma>
c01042d9:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01042dc:	74 24                	je     c0104302 <check_pgfault+0x12c>
c01042de:	c7 44 24 0c 49 cc 10 	movl   $0xc010cc49,0xc(%esp)
c01042e5:	c0 
c01042e6:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c01042ed:	c0 
c01042ee:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c01042f5:	00 
c01042f6:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c01042fd:	e8 fe c0 ff ff       	call   c0100400 <__panic>

    int i, sum = 0;
c0104302:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104310:	eb 16                	jmp    c0104328 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0104312:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104315:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104318:	01 d0                	add    %edx,%eax
c010431a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010431d:	88 10                	mov    %dl,(%eax)
        sum += i;
c010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104322:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104325:	ff 45 f4             	incl   -0xc(%ebp)
c0104328:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010432c:	7e e4                	jle    c0104312 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c010432e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104335:	eb 14                	jmp    c010434b <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0104337:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010433a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010433d:	01 d0                	add    %edx,%eax
c010433f:	0f b6 00             	movzbl (%eax),%eax
c0104342:	0f be c0             	movsbl %al,%eax
c0104345:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104348:	ff 45 f4             	incl   -0xc(%ebp)
c010434b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010434f:	7e e6                	jle    c0104337 <check_pgfault+0x161>
    }
    assert(sum == 0);
c0104351:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104355:	74 24                	je     c010437b <check_pgfault+0x1a5>
c0104357:	c7 44 24 0c 63 cc 10 	movl   $0xc010cc63,0xc(%esp)
c010435e:	c0 
c010435f:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c0104366:	c0 
c0104367:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c010436e:	00 
c010436f:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0104376:	e8 85 c0 ff ff       	call   c0100400 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010437b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010437e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104381:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104384:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104389:	89 44 24 04          	mov    %eax,0x4(%esp)
c010438d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104390:	89 04 24             	mov    %eax,(%esp)
c0104393:	e8 57 40 00 00       	call   c01083ef <page_remove>
    free_page(pde2page(pgdir[0]));
c0104398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010439b:	8b 00                	mov    (%eax),%eax
c010439d:	89 04 24             	mov    %eax,(%esp)
c01043a0:	e8 be f1 ff ff       	call   c0103563 <pde2page>
c01043a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043ac:	00 
c01043ad:	89 04 24             	mov    %eax,(%esp)
c01043b0:	e8 b1 33 00 00       	call   c0107766 <free_pages>
    pgdir[0] = 0;
c01043b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c01043be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043c1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c01043c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043cb:	89 04 24             	mov    %eax,(%esp)
c01043ce:	e8 04 f5 ff ff       	call   c01038d7 <mm_destroy>
    check_mm_struct = NULL;
c01043d3:	c7 05 58 20 1a c0 00 	movl   $0x0,0xc01a2058
c01043da:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c01043dd:	e8 b7 33 00 00       	call   c0107799 <nr_free_pages>
c01043e2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01043e5:	74 24                	je     c010440b <check_pgfault+0x235>
c01043e7:	c7 44 24 0c 6c cc 10 	movl   $0xc010cc6c,0xc(%esp)
c01043ee:	c0 
c01043ef:	c7 44 24 08 db c9 10 	movl   $0xc010c9db,0x8(%esp)
c01043f6:	c0 
c01043f7:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c01043fe:	00 
c01043ff:	c7 04 24 f0 c9 10 c0 	movl   $0xc010c9f0,(%esp)
c0104406:	e8 f5 bf ff ff       	call   c0100400 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c010440b:	c7 04 24 93 cc 10 c0 	movl   $0xc010cc93,(%esp)
c0104412:	e8 92 be ff ff       	call   c01002a9 <cprintf>
}
c0104417:	90                   	nop
c0104418:	c9                   	leave  
c0104419:	c3                   	ret    

c010441a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010441a:	55                   	push   %ebp
c010441b:	89 e5                	mov    %esp,%ebp
c010441d:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0104420:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0104427:	8b 45 10             	mov    0x10(%ebp),%eax
c010442a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010442e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104431:	89 04 24             	mov    %eax,(%esp)
c0104434:	e8 16 f2 ff ff       	call   c010364f <find_vma>
c0104439:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c010443c:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104441:	40                   	inc    %eax
c0104442:	a3 64 ff 19 c0       	mov    %eax,0xc019ff64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0104447:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010444b:	74 0b                	je     c0104458 <do_pgfault+0x3e>
c010444d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104450:	8b 40 04             	mov    0x4(%eax),%eax
c0104453:	39 45 10             	cmp    %eax,0x10(%ebp)
c0104456:	73 18                	jae    c0104470 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0104458:	8b 45 10             	mov    0x10(%ebp),%eax
c010445b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010445f:	c7 04 24 b0 cc 10 c0 	movl   $0xc010ccb0,(%esp)
c0104466:	e8 3e be ff ff       	call   c01002a9 <cprintf>
        goto failed;
c010446b:	e9 ba 01 00 00       	jmp    c010462a <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c0104470:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104473:	83 e0 03             	and    $0x3,%eax
c0104476:	85 c0                	test   %eax,%eax
c0104478:	74 34                	je     c01044ae <do_pgfault+0x94>
c010447a:	83 f8 01             	cmp    $0x1,%eax
c010447d:	74 1e                	je     c010449d <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c010447f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104482:	8b 40 0c             	mov    0xc(%eax),%eax
c0104485:	83 e0 02             	and    $0x2,%eax
c0104488:	85 c0                	test   %eax,%eax
c010448a:	75 40                	jne    c01044cc <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010448c:	c7 04 24 e0 cc 10 c0 	movl   $0xc010cce0,(%esp)
c0104493:	e8 11 be ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0104498:	e9 8d 01 00 00       	jmp    c010462a <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010449d:	c7 04 24 40 cd 10 c0 	movl   $0xc010cd40,(%esp)
c01044a4:	e8 00 be ff ff       	call   c01002a9 <cprintf>
        goto failed;
c01044a9:	e9 7c 01 00 00       	jmp    c010462a <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c01044ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044b1:	8b 40 0c             	mov    0xc(%eax),%eax
c01044b4:	83 e0 05             	and    $0x5,%eax
c01044b7:	85 c0                	test   %eax,%eax
c01044b9:	75 12                	jne    c01044cd <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c01044bb:	c7 04 24 78 cd 10 c0 	movl   $0xc010cd78,(%esp)
c01044c2:	e8 e2 bd ff ff       	call   c01002a9 <cprintf>
            goto failed;
c01044c7:	e9 5e 01 00 00       	jmp    c010462a <do_pgfault+0x210>
        break;
c01044cc:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01044cd:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c01044d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044d7:	8b 40 0c             	mov    0xc(%eax),%eax
c01044da:	83 e0 02             	and    $0x2,%eax
c01044dd:	85 c0                	test   %eax,%eax
c01044df:	74 04                	je     c01044e5 <do_pgfault+0xcb>
        perm |= PTE_W;
c01044e1:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01044e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01044e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01044eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01044f3:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01044f6:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01044fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0104504:	8b 45 08             	mov    0x8(%ebp),%eax
c0104507:	8b 40 0c             	mov    0xc(%eax),%eax
c010450a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104511:	00 
c0104512:	8b 55 10             	mov    0x10(%ebp),%edx
c0104515:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104519:	89 04 24             	mov    %eax,(%esp)
c010451c:	e8 ba 38 00 00       	call   c0107ddb <get_pte>
c0104521:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104524:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104528:	75 11                	jne    c010453b <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c010452a:	c7 04 24 db cd 10 c0 	movl   $0xc010cddb,(%esp)
c0104531:	e8 73 bd ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0104536:	e9 ef 00 00 00       	jmp    c010462a <do_pgfault+0x210>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c010453b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010453e:	8b 00                	mov    (%eax),%eax
c0104540:	85 c0                	test   %eax,%eax
c0104542:	75 35                	jne    c0104579 <do_pgfault+0x15f>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0104544:	8b 45 08             	mov    0x8(%ebp),%eax
c0104547:	8b 40 0c             	mov    0xc(%eax),%eax
c010454a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010454d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104551:	8b 55 10             	mov    0x10(%ebp),%edx
c0104554:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104558:	89 04 24             	mov    %eax,(%esp)
c010455b:	e8 e9 3f 00 00       	call   c0108549 <pgdir_alloc_page>
c0104560:	85 c0                	test   %eax,%eax
c0104562:	0f 85 bb 00 00 00    	jne    c0104623 <do_pgfault+0x209>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0104568:	c7 04 24 fc cd 10 c0 	movl   $0xc010cdfc,(%esp)
c010456f:	e8 35 bd ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0104574:	e9 b1 00 00 00       	jmp    c010462a <do_pgfault+0x210>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0104579:	a1 6c ff 19 c0       	mov    0xc019ff6c,%eax
c010457e:	85 c0                	test   %eax,%eax
c0104580:	0f 84 86 00 00 00    	je     c010460c <do_pgfault+0x1f2>
            struct Page *page=NULL;
c0104586:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c010458d:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0104590:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104594:	8b 45 10             	mov    0x10(%ebp),%eax
c0104597:	89 44 24 04          	mov    %eax,0x4(%esp)
c010459b:	8b 45 08             	mov    0x8(%ebp),%eax
c010459e:	89 04 24             	mov    %eax,(%esp)
c01045a1:	e8 20 13 00 00       	call   c01058c6 <swap_in>
c01045a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045ad:	74 0e                	je     c01045bd <do_pgfault+0x1a3>
                cprintf("swap_in in do_pgfault failed\n");
c01045af:	c7 04 24 23 ce 10 c0 	movl   $0xc010ce23,(%esp)
c01045b6:	e8 ee bc ff ff       	call   c01002a9 <cprintf>
c01045bb:	eb 6d                	jmp    c010462a <do_pgfault+0x210>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c01045bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01045c3:	8b 40 0c             	mov    0xc(%eax),%eax
c01045c6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01045c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01045cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01045d0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01045d4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01045d8:	89 04 24             	mov    %eax,(%esp)
c01045db:	e8 54 3e 00 00       	call   c0108434 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c01045e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045e3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01045ea:	00 
c01045eb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045ef:	8b 45 10             	mov    0x10(%ebp),%eax
c01045f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f9:	89 04 24             	mov    %eax,(%esp)
c01045fc:	e8 03 11 00 00       	call   c0105704 <swap_map_swappable>
            page->pra_vaddr = addr;
c0104601:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104604:	8b 55 10             	mov    0x10(%ebp),%edx
c0104607:	89 50 1c             	mov    %edx,0x1c(%eax)
c010460a:	eb 17                	jmp    c0104623 <do_pgfault+0x209>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c010460c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010460f:	8b 00                	mov    (%eax),%eax
c0104611:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104615:	c7 04 24 44 ce 10 c0 	movl   $0xc010ce44,(%esp)
c010461c:	e8 88 bc ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0104621:	eb 07                	jmp    c010462a <do_pgfault+0x210>
        }
   }
    ret = 0;
c0104623:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010462d:	c9                   	leave  
c010462e:	c3                   	ret    

c010462f <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c010462f:	55                   	push   %ebp
c0104630:	89 e5                	mov    %esp,%ebp
c0104632:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0104635:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104639:	0f 84 e0 00 00 00    	je     c010471f <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c010463f:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0104646:	76 1c                	jbe    c0104664 <user_mem_check+0x35>
c0104648:	8b 55 0c             	mov    0xc(%ebp),%edx
c010464b:	8b 45 10             	mov    0x10(%ebp),%eax
c010464e:	01 d0                	add    %edx,%eax
c0104650:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104653:	73 0f                	jae    c0104664 <user_mem_check+0x35>
c0104655:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104658:	8b 45 10             	mov    0x10(%ebp),%eax
c010465b:	01 d0                	add    %edx,%eax
c010465d:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c0104662:	76 0a                	jbe    c010466e <user_mem_check+0x3f>
            return 0;
c0104664:	b8 00 00 00 00       	mov    $0x0,%eax
c0104669:	e9 e2 00 00 00       	jmp    c0104750 <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c010466e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104671:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0104674:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104677:	8b 45 10             	mov    0x10(%ebp),%eax
c010467a:	01 d0                	add    %edx,%eax
c010467c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c010467f:	e9 88 00 00 00       	jmp    c010470c <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c0104684:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104687:	89 44 24 04          	mov    %eax,0x4(%esp)
c010468b:	8b 45 08             	mov    0x8(%ebp),%eax
c010468e:	89 04 24             	mov    %eax,(%esp)
c0104691:	e8 b9 ef ff ff       	call   c010364f <find_vma>
c0104696:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104699:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010469d:	74 0b                	je     c01046aa <user_mem_check+0x7b>
c010469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046a2:	8b 40 04             	mov    0x4(%eax),%eax
c01046a5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01046a8:	73 0a                	jae    c01046b4 <user_mem_check+0x85>
                return 0;
c01046aa:	b8 00 00 00 00       	mov    $0x0,%eax
c01046af:	e9 9c 00 00 00       	jmp    c0104750 <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c01046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b7:	8b 40 0c             	mov    0xc(%eax),%eax
c01046ba:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01046be:	74 07                	je     c01046c7 <user_mem_check+0x98>
c01046c0:	ba 02 00 00 00       	mov    $0x2,%edx
c01046c5:	eb 05                	jmp    c01046cc <user_mem_check+0x9d>
c01046c7:	ba 01 00 00 00       	mov    $0x1,%edx
c01046cc:	21 d0                	and    %edx,%eax
c01046ce:	85 c0                	test   %eax,%eax
c01046d0:	75 07                	jne    c01046d9 <user_mem_check+0xaa>
                return 0;
c01046d2:	b8 00 00 00 00       	mov    $0x0,%eax
c01046d7:	eb 77                	jmp    c0104750 <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c01046d9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01046dd:	74 24                	je     c0104703 <user_mem_check+0xd4>
c01046df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e2:	8b 40 0c             	mov    0xc(%eax),%eax
c01046e5:	83 e0 08             	and    $0x8,%eax
c01046e8:	85 c0                	test   %eax,%eax
c01046ea:	74 17                	je     c0104703 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c01046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ef:	8b 40 04             	mov    0x4(%eax),%eax
c01046f2:	05 00 10 00 00       	add    $0x1000,%eax
c01046f7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01046fa:	73 07                	jae    c0104703 <user_mem_check+0xd4>
                    return 0;
c01046fc:	b8 00 00 00 00       	mov    $0x0,%eax
c0104701:	eb 4d                	jmp    c0104750 <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c0104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104706:	8b 40 08             	mov    0x8(%eax),%eax
c0104709:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end) {
c010470c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010470f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0104712:	0f 82 6c ff ff ff    	jb     c0104684 <user_mem_check+0x55>
        }
        return 1;
c0104718:	b8 01 00 00 00       	mov    $0x1,%eax
c010471d:	eb 31                	jmp    c0104750 <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c010471f:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c0104726:	76 23                	jbe    c010474b <user_mem_check+0x11c>
c0104728:	8b 55 0c             	mov    0xc(%ebp),%edx
c010472b:	8b 45 10             	mov    0x10(%ebp),%eax
c010472e:	01 d0                	add    %edx,%eax
c0104730:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104733:	73 16                	jae    c010474b <user_mem_check+0x11c>
c0104735:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104738:	8b 45 10             	mov    0x10(%ebp),%eax
c010473b:	01 d0                	add    %edx,%eax
c010473d:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0104742:	77 07                	ja     c010474b <user_mem_check+0x11c>
c0104744:	b8 01 00 00 00       	mov    $0x1,%eax
c0104749:	eb 05                	jmp    c0104750 <user_mem_check+0x121>
c010474b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104750:	c9                   	leave  
c0104751:	c3                   	ret    

c0104752 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0104752:	55                   	push   %ebp
c0104753:	89 e5                	mov    %esp,%ebp
c0104755:	83 ec 10             	sub    $0x10,%esp
c0104758:	c7 45 fc 5c 20 1a c0 	movl   $0xc01a205c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c010475f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104762:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104765:	89 50 04             	mov    %edx,0x4(%eax)
c0104768:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010476b:	8b 50 04             	mov    0x4(%eax),%edx
c010476e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104771:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0104773:	8b 45 08             	mov    0x8(%ebp),%eax
c0104776:	c7 40 14 5c 20 1a c0 	movl   $0xc01a205c,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c010477d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104782:	c9                   	leave  
c0104783:	c3                   	ret    

c0104784 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104784:	55                   	push   %ebp
c0104785:	89 e5                	mov    %esp,%ebp
c0104787:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010478a:	8b 45 08             	mov    0x8(%ebp),%eax
c010478d:	8b 40 14             	mov    0x14(%eax),%eax
c0104790:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0104793:	8b 45 10             	mov    0x10(%ebp),%eax
c0104796:	83 c0 14             	add    $0x14,%eax
c0104799:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c010479c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047a0:	74 06                	je     c01047a8 <_fifo_map_swappable+0x24>
c01047a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047a6:	75 24                	jne    c01047cc <_fifo_map_swappable+0x48>
c01047a8:	c7 44 24 0c 6c ce 10 	movl   $0xc010ce6c,0xc(%esp)
c01047af:	c0 
c01047b0:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c01047b7:	c0 
c01047b8:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c01047bf:	00 
c01047c0:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c01047c7:	e8 34 bc ff ff       	call   c0100400 <__panic>
c01047cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01047d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01047d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01047de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c01047e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047e7:	8b 40 04             	mov    0x4(%eax),%eax
c01047ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01047ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01047f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047f3:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01047f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c01047f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01047fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01047ff:	89 10                	mov    %edx,(%eax)
c0104801:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104804:	8b 10                	mov    (%eax),%edx
c0104806:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104809:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010480c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010480f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104812:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104815:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104818:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010481b:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c010481d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104822:	c9                   	leave  
c0104823:	c3                   	ret    

c0104824 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0104824:	55                   	push   %ebp
c0104825:	89 e5                	mov    %esp,%ebp
c0104827:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010482a:	8b 45 08             	mov    0x8(%ebp),%eax
c010482d:	8b 40 14             	mov    0x14(%eax),%eax
c0104830:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0104833:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104837:	75 24                	jne    c010485d <_fifo_swap_out_victim+0x39>
c0104839:	c7 44 24 0c b3 ce 10 	movl   $0xc010ceb3,0xc(%esp)
c0104840:	c0 
c0104841:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104848:	c0 
c0104849:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0104850:	00 
c0104851:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104858:	e8 a3 bb ff ff       	call   c0100400 <__panic>
    assert(in_tick==0);
c010485d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104861:	74 24                	je     c0104887 <_fifo_swap_out_victim+0x63>
c0104863:	c7 44 24 0c c0 ce 10 	movl   $0xc010cec0,0xc(%esp)
c010486a:	c0 
c010486b:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104872:	c0 
c0104873:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c010487a:	00 
c010487b:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104882:	e8 79 bb ff ff       	call   c0100400 <__panic>
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    /* Select the tail */
    list_entry_t *le = head->prev;
c0104887:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010488a:	8b 00                	mov    (%eax),%eax
c010488c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head!=le);
c010488f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104892:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104895:	75 24                	jne    c01048bb <_fifo_swap_out_victim+0x97>
c0104897:	c7 44 24 0c cb ce 10 	movl   $0xc010cecb,0xc(%esp)
c010489e:	c0 
c010489f:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c01048a6:	c0 
c01048a7:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01048ae:	00 
c01048af:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c01048b6:	e8 45 bb ff ff       	call   c0100400 <__panic>
    struct Page *p = le2page(le, pra_page_link);
c01048bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048be:	83 e8 14             	sub    $0x14,%eax
c01048c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01048c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c01048ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01048cd:	8b 40 04             	mov    0x4(%eax),%eax
c01048d0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01048d3:	8b 12                	mov    (%edx),%edx
c01048d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01048d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c01048db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048de:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048e1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01048e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01048ea:	89 10                	mov    %edx,(%eax)
    list_del(le);
    assert(p !=NULL);
c01048ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01048f0:	75 24                	jne    c0104916 <_fifo_swap_out_victim+0xf2>
c01048f2:	c7 44 24 0c d4 ce 10 	movl   $0xc010ced4,0xc(%esp)
c01048f9:	c0 
c01048fa:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104901:	c0 
c0104902:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c0104909:	00 
c010490a:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104911:	e8 ea ba ff ff       	call   c0100400 <__panic>
    *ptr_page = p;
c0104916:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104919:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010491c:	89 10                	mov    %edx,(%eax)
    return 0;
c010491e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104923:	c9                   	leave  
c0104924:	c3                   	ret    

c0104925 <_extended_clock_swap_out_victim>:

static int
_extended_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick) {
c0104925:	55                   	push   %ebp
c0104926:	89 e5                	mov    %esp,%ebp
c0104928:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010492b:	8b 45 08             	mov    0x8(%ebp),%eax
c010492e:	8b 40 14             	mov    0x14(%eax),%eax
c0104931:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(head!=NULL);
c0104934:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104938:	75 24                	jne    c010495e <_extended_clock_swap_out_victim+0x39>
c010493a:	c7 44 24 0c dd ce 10 	movl   $0xc010cedd,0xc(%esp)
c0104941:	c0 
c0104942:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104949:	c0 
c010494a:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0104951:	00 
c0104952:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104959:	e8 a2 ba ff ff       	call   c0100400 <__panic>
    assert(in_tick==0);
c010495e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104962:	74 24                	je     c0104988 <_extended_clock_swap_out_victim+0x63>
c0104964:	c7 44 24 0c c0 ce 10 	movl   $0xc010cec0,0xc(%esp)
c010496b:	c0 
c010496c:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104973:	c0 
c0104974:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c010497b:	00 
c010497c:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104983:	e8 78 ba ff ff       	call   c0100400 <__panic>
    for (int i = 0; i < 3; i++) {
c0104988:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010498f:	e9 35 01 00 00       	jmp    c0104ac9 <_extended_clock_swap_out_victim+0x1a4>
        list_entry_t *le = head->prev;
c0104994:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104997:	8b 00                	mov    (%eax),%eax
c0104999:	89 45 f0             	mov    %eax,-0x10(%ebp)
        assert(head!=le);
c010499c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010499f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049a2:	0f 85 12 01 00 00    	jne    c0104aba <_extended_clock_swap_out_victim+0x195>
c01049a8:	c7 44 24 0c cb ce 10 	movl   $0xc010cecb,0xc(%esp)
c01049af:	c0 
c01049b0:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c01049b7:	c0 
c01049b8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01049bf:	00 
c01049c0:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c01049c7:	e8 34 ba ff ff       	call   c0100400 <__panic>
        while (le != head) {
            struct Page *p = le2page(le, pra_page_link);
c01049cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049cf:	83 e8 14             	sub    $0x14,%eax
c01049d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
            pte_t* ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);
c01049d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01049d8:	8b 50 1c             	mov    0x1c(%eax),%edx
c01049db:	8b 45 08             	mov    0x8(%ebp),%eax
c01049de:	8b 40 0c             	mov    0xc(%eax),%eax
c01049e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049e8:	00 
c01049e9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049ed:	89 04 24             	mov    %eax,(%esp)
c01049f0:	e8 e6 33 00 00       	call   c0107ddb <get_pte>
c01049f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
c01049f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049fb:	8b 00                	mov    (%eax),%eax
c01049fd:	83 e0 20             	and    $0x20,%eax
c0104a00:	85 c0                	test   %eax,%eax
c0104a02:	75 6d                	jne    c0104a71 <_extended_clock_swap_out_victim+0x14c>
c0104a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a07:	8b 00                	mov    (%eax),%eax
c0104a09:	83 e0 40             	and    $0x40,%eax
c0104a0c:	85 c0                	test   %eax,%eax
c0104a0e:	75 61                	jne    c0104a71 <_extended_clock_swap_out_victim+0x14c>
c0104a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104a16:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a19:	8b 40 04             	mov    0x4(%eax),%eax
c0104a1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104a1f:	8b 12                	mov    (%edx),%edx
c0104a21:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104a24:	89 45 d8             	mov    %eax,-0x28(%ebp)
    prev->next = next;
c0104a27:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a2a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104a2d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104a30:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104a33:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a36:	89 10                	mov    %edx,(%eax)
                list_del(le);
                assert(p != NULL);
c0104a38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104a3c:	75 24                	jne    c0104a62 <_extended_clock_swap_out_victim+0x13d>
c0104a3e:	c7 44 24 0c e8 ce 10 	movl   $0xc010cee8,0xc(%esp)
c0104a45:	c0 
c0104a46:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104a4d:	c0 
c0104a4e:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104a55:	00 
c0104a56:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104a5d:	e8 9e b9 ff ff       	call   c0100400 <__panic>
                *ptr_page = p;
c0104a62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a65:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a68:	89 10                	mov    %edx,(%eax)
                return 0;
c0104a6a:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a6f:	eb 67                	jmp    c0104ad8 <_extended_clock_swap_out_victim+0x1b3>
            }
            if (!i) {
c0104a71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a75:	75 11                	jne    c0104a88 <_extended_clock_swap_out_victim+0x163>
                *ptep &= ~PTE_A;
c0104a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a7a:	8b 00                	mov    (%eax),%eax
c0104a7c:	83 e0 df             	and    $0xffffffdf,%eax
c0104a7f:	89 c2                	mov    %eax,%edx
c0104a81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a84:	89 10                	mov    %edx,(%eax)
c0104a86:	eb 15                	jmp    c0104a9d <_extended_clock_swap_out_victim+0x178>
            }
            else if (i == 1) {
c0104a88:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
c0104a8c:	75 0f                	jne    c0104a9d <_extended_clock_swap_out_victim+0x178>
                *ptep &= ~PTE_D;
c0104a8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a91:	8b 00                	mov    (%eax),%eax
c0104a93:	83 e0 bf             	and    $0xffffffbf,%eax
c0104a96:	89 c2                	mov    %eax,%edx
c0104a98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a9b:	89 10                	mov    %edx,(%eax)
            }
            le = le->prev;
c0104a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aa0:	8b 00                	mov    (%eax),%eax
c0104aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
            tlb_invalidate(mm->pgdir, le);
c0104aa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104aa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aab:	8b 40 0c             	mov    0xc(%eax),%eax
c0104aae:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ab2:	89 04 24             	mov    %eax,(%esp)
c0104ab5:	e8 33 3a 00 00       	call   c01084ed <tlb_invalidate>
        while (le != head) {
c0104aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104abd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104ac0:	0f 85 06 ff ff ff    	jne    c01049cc <_extended_clock_swap_out_victim+0xa7>
    for (int i = 0; i < 3; i++) {
c0104ac6:	ff 45 f4             	incl   -0xc(%ebp)
c0104ac9:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
c0104acd:	0f 8e c1 fe ff ff    	jle    c0104994 <_extended_clock_swap_out_victim+0x6f>
        }
    }
    return -1;
c0104ad3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c0104ad8:	c9                   	leave  
c0104ad9:	c3                   	ret    

c0104ada <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0104ada:	55                   	push   %ebp
c0104adb:	89 e5                	mov    %esp,%ebp
c0104add:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104ae0:	c7 04 24 f4 ce 10 c0 	movl   $0xc010cef4,(%esp)
c0104ae7:	e8 bd b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104aec:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104af1:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0104af4:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104af9:	83 f8 04             	cmp    $0x4,%eax
c0104afc:	74 24                	je     c0104b22 <_fifo_check_swap+0x48>
c0104afe:	c7 44 24 0c 1a cf 10 	movl   $0xc010cf1a,0xc(%esp)
c0104b05:	c0 
c0104b06:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104b0d:	c0 
c0104b0e:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0104b15:	00 
c0104b16:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104b1d:	e8 de b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104b22:	c7 04 24 2c cf 10 c0 	movl   $0xc010cf2c,(%esp)
c0104b29:	e8 7b b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104b2e:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104b33:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0104b36:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104b3b:	83 f8 04             	cmp    $0x4,%eax
c0104b3e:	74 24                	je     c0104b64 <_fifo_check_swap+0x8a>
c0104b40:	c7 44 24 0c 1a cf 10 	movl   $0xc010cf1a,0xc(%esp)
c0104b47:	c0 
c0104b48:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104b4f:	c0 
c0104b50:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0104b57:	00 
c0104b58:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104b5f:	e8 9c b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104b64:	c7 04 24 54 cf 10 c0 	movl   $0xc010cf54,(%esp)
c0104b6b:	e8 39 b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104b70:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104b75:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104b78:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104b7d:	83 f8 04             	cmp    $0x4,%eax
c0104b80:	74 24                	je     c0104ba6 <_fifo_check_swap+0xcc>
c0104b82:	c7 44 24 0c 1a cf 10 	movl   $0xc010cf1a,0xc(%esp)
c0104b89:	c0 
c0104b8a:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104b91:	c0 
c0104b92:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0104b99:	00 
c0104b9a:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104ba1:	e8 5a b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104ba6:	c7 04 24 7c cf 10 c0 	movl   $0xc010cf7c,(%esp)
c0104bad:	e8 f7 b6 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104bb2:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104bb7:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0104bba:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104bbf:	83 f8 04             	cmp    $0x4,%eax
c0104bc2:	74 24                	je     c0104be8 <_fifo_check_swap+0x10e>
c0104bc4:	c7 44 24 0c 1a cf 10 	movl   $0xc010cf1a,0xc(%esp)
c0104bcb:	c0 
c0104bcc:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104bd3:	c0 
c0104bd4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0104bdb:	00 
c0104bdc:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104be3:	e8 18 b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104be8:	c7 04 24 a4 cf 10 c0 	movl   $0xc010cfa4,(%esp)
c0104bef:	e8 b5 b6 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104bf4:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104bf9:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104bfc:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104c01:	83 f8 05             	cmp    $0x5,%eax
c0104c04:	74 24                	je     c0104c2a <_fifo_check_swap+0x150>
c0104c06:	c7 44 24 0c ca cf 10 	movl   $0xc010cfca,0xc(%esp)
c0104c0d:	c0 
c0104c0e:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104c15:	c0 
c0104c16:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0104c1d:	00 
c0104c1e:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104c25:	e8 d6 b7 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104c2a:	c7 04 24 7c cf 10 c0 	movl   $0xc010cf7c,(%esp)
c0104c31:	e8 73 b6 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104c36:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104c3b:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0104c3e:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104c43:	83 f8 05             	cmp    $0x5,%eax
c0104c46:	74 24                	je     c0104c6c <_fifo_check_swap+0x192>
c0104c48:	c7 44 24 0c ca cf 10 	movl   $0xc010cfca,0xc(%esp)
c0104c4f:	c0 
c0104c50:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104c57:	c0 
c0104c58:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
c0104c5f:	00 
c0104c60:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104c67:	e8 94 b7 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104c6c:	c7 04 24 2c cf 10 c0 	movl   $0xc010cf2c,(%esp)
c0104c73:	e8 31 b6 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104c78:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104c7d:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104c80:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104c85:	83 f8 06             	cmp    $0x6,%eax
c0104c88:	74 24                	je     c0104cae <_fifo_check_swap+0x1d4>
c0104c8a:	c7 44 24 0c d9 cf 10 	movl   $0xc010cfd9,0xc(%esp)
c0104c91:	c0 
c0104c92:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104c99:	c0 
c0104c9a:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0104ca1:	00 
c0104ca2:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104ca9:	e8 52 b7 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104cae:	c7 04 24 7c cf 10 c0 	movl   $0xc010cf7c,(%esp)
c0104cb5:	e8 ef b5 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104cba:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104cbf:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0104cc2:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104cc7:	83 f8 07             	cmp    $0x7,%eax
c0104cca:	74 24                	je     c0104cf0 <_fifo_check_swap+0x216>
c0104ccc:	c7 44 24 0c e8 cf 10 	movl   $0xc010cfe8,0xc(%esp)
c0104cd3:	c0 
c0104cd4:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104cdb:	c0 
c0104cdc:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
c0104ce3:	00 
c0104ce4:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104ceb:	e8 10 b7 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104cf0:	c7 04 24 f4 ce 10 c0 	movl   $0xc010cef4,(%esp)
c0104cf7:	e8 ad b5 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104cfc:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104d01:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104d04:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104d09:	83 f8 08             	cmp    $0x8,%eax
c0104d0c:	74 24                	je     c0104d32 <_fifo_check_swap+0x258>
c0104d0e:	c7 44 24 0c f7 cf 10 	movl   $0xc010cff7,0xc(%esp)
c0104d15:	c0 
c0104d16:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104d1d:	c0 
c0104d1e:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
c0104d25:	00 
c0104d26:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104d2d:	e8 ce b6 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104d32:	c7 04 24 54 cf 10 c0 	movl   $0xc010cf54,(%esp)
c0104d39:	e8 6b b5 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104d3e:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104d43:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0104d46:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104d4b:	83 f8 09             	cmp    $0x9,%eax
c0104d4e:	74 24                	je     c0104d74 <_fifo_check_swap+0x29a>
c0104d50:	c7 44 24 0c 06 d0 10 	movl   $0xc010d006,0xc(%esp)
c0104d57:	c0 
c0104d58:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104d5f:	c0 
c0104d60:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
c0104d67:	00 
c0104d68:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104d6f:	e8 8c b6 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104d74:	c7 04 24 a4 cf 10 c0 	movl   $0xc010cfa4,(%esp)
c0104d7b:	e8 29 b5 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104d80:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104d85:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0104d88:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104d8d:	83 f8 0a             	cmp    $0xa,%eax
c0104d90:	74 24                	je     c0104db6 <_fifo_check_swap+0x2dc>
c0104d92:	c7 44 24 0c 15 d0 10 	movl   $0xc010d015,0xc(%esp)
c0104d99:	c0 
c0104d9a:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104da1:	c0 
c0104da2:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
c0104da9:	00 
c0104daa:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104db1:	e8 4a b6 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104db6:	c7 04 24 2c cf 10 c0 	movl   $0xc010cf2c,(%esp)
c0104dbd:	e8 e7 b4 ff ff       	call   c01002a9 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0104dc2:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104dc7:	0f b6 00             	movzbl (%eax),%eax
c0104dca:	3c 0a                	cmp    $0xa,%al
c0104dcc:	74 24                	je     c0104df2 <_fifo_check_swap+0x318>
c0104dce:	c7 44 24 0c 28 d0 10 	movl   $0xc010d028,0xc(%esp)
c0104dd5:	c0 
c0104dd6:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104ddd:	c0 
c0104dde:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
c0104de5:	00 
c0104de6:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104ded:	e8 0e b6 ff ff       	call   c0100400 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104df2:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104df7:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0104dfa:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0104dff:	83 f8 0b             	cmp    $0xb,%eax
c0104e02:	74 24                	je     c0104e28 <_fifo_check_swap+0x34e>
c0104e04:	c7 44 24 0c 49 d0 10 	movl   $0xc010d049,0xc(%esp)
c0104e0b:	c0 
c0104e0c:	c7 44 24 08 8a ce 10 	movl   $0xc010ce8a,0x8(%esp)
c0104e13:	c0 
c0104e14:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
c0104e1b:	00 
c0104e1c:	c7 04 24 9f ce 10 c0 	movl   $0xc010ce9f,(%esp)
c0104e23:	e8 d8 b5 ff ff       	call   c0100400 <__panic>
    return 0;
c0104e28:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e2d:	c9                   	leave  
c0104e2e:	c3                   	ret    

c0104e2f <_fifo_init>:


static int
_fifo_init(void)
{
c0104e2f:	55                   	push   %ebp
c0104e30:	89 e5                	mov    %esp,%ebp
    return 0;
c0104e32:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e37:	5d                   	pop    %ebp
c0104e38:	c3                   	ret    

c0104e39 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104e39:	55                   	push   %ebp
c0104e3a:	89 e5                	mov    %esp,%ebp
    return 0;
c0104e3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e41:	5d                   	pop    %ebp
c0104e42:	c3                   	ret    

c0104e43 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104e43:	55                   	push   %ebp
c0104e44:	89 e5                	mov    %esp,%ebp
c0104e46:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e4b:	5d                   	pop    %ebp
c0104e4c:	c3                   	ret    

c0104e4d <__intr_save>:
__intr_save(void) {
c0104e4d:	55                   	push   %ebp
c0104e4e:	89 e5                	mov    %esp,%ebp
c0104e50:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104e53:	9c                   	pushf  
c0104e54:	58                   	pop    %eax
c0104e55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104e5b:	25 00 02 00 00       	and    $0x200,%eax
c0104e60:	85 c0                	test   %eax,%eax
c0104e62:	74 0c                	je     c0104e70 <__intr_save+0x23>
        intr_disable();
c0104e64:	e8 77 d3 ff ff       	call   c01021e0 <intr_disable>
        return 1;
c0104e69:	b8 01 00 00 00       	mov    $0x1,%eax
c0104e6e:	eb 05                	jmp    c0104e75 <__intr_save+0x28>
    return 0;
c0104e70:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e75:	c9                   	leave  
c0104e76:	c3                   	ret    

c0104e77 <__intr_restore>:
__intr_restore(bool flag) {
c0104e77:	55                   	push   %ebp
c0104e78:	89 e5                	mov    %esp,%ebp
c0104e7a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104e7d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104e81:	74 05                	je     c0104e88 <__intr_restore+0x11>
        intr_enable();
c0104e83:	e8 51 d3 ff ff       	call   c01021d9 <intr_enable>
}
c0104e88:	90                   	nop
c0104e89:	c9                   	leave  
c0104e8a:	c3                   	ret    

c0104e8b <page2ppn>:
page2ppn(struct Page *page) {
c0104e8b:	55                   	push   %ebp
c0104e8c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104e8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e91:	8b 15 58 21 1a c0    	mov    0xc01a2158,%edx
c0104e97:	29 d0                	sub    %edx,%eax
c0104e99:	c1 f8 05             	sar    $0x5,%eax
}
c0104e9c:	5d                   	pop    %ebp
c0104e9d:	c3                   	ret    

c0104e9e <page2pa>:
page2pa(struct Page *page) {
c0104e9e:	55                   	push   %ebp
c0104e9f:	89 e5                	mov    %esp,%ebp
c0104ea1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ea7:	89 04 24             	mov    %eax,(%esp)
c0104eaa:	e8 dc ff ff ff       	call   c0104e8b <page2ppn>
c0104eaf:	c1 e0 0c             	shl    $0xc,%eax
}
c0104eb2:	c9                   	leave  
c0104eb3:	c3                   	ret    

c0104eb4 <pa2page>:
pa2page(uintptr_t pa) {
c0104eb4:	55                   	push   %ebp
c0104eb5:	89 e5                	mov    %esp,%ebp
c0104eb7:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104eba:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ebd:	c1 e8 0c             	shr    $0xc,%eax
c0104ec0:	89 c2                	mov    %eax,%edx
c0104ec2:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0104ec7:	39 c2                	cmp    %eax,%edx
c0104ec9:	72 1c                	jb     c0104ee7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104ecb:	c7 44 24 08 6c d0 10 	movl   $0xc010d06c,0x8(%esp)
c0104ed2:	c0 
c0104ed3:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104eda:	00 
c0104edb:	c7 04 24 8b d0 10 c0 	movl   $0xc010d08b,(%esp)
c0104ee2:	e8 19 b5 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0104ee7:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c0104eec:	8b 55 08             	mov    0x8(%ebp),%edx
c0104eef:	c1 ea 0c             	shr    $0xc,%edx
c0104ef2:	c1 e2 05             	shl    $0x5,%edx
c0104ef5:	01 d0                	add    %edx,%eax
}
c0104ef7:	c9                   	leave  
c0104ef8:	c3                   	ret    

c0104ef9 <page2kva>:
page2kva(struct Page *page) {
c0104ef9:	55                   	push   %ebp
c0104efa:	89 e5                	mov    %esp,%ebp
c0104efc:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104eff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f02:	89 04 24             	mov    %eax,(%esp)
c0104f05:	e8 94 ff ff ff       	call   c0104e9e <page2pa>
c0104f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f10:	c1 e8 0c             	shr    $0xc,%eax
c0104f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f16:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0104f1b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104f1e:	72 23                	jb     c0104f43 <page2kva+0x4a>
c0104f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f23:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f27:	c7 44 24 08 9c d0 10 	movl   $0xc010d09c,0x8(%esp)
c0104f2e:	c0 
c0104f2f:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104f36:	00 
c0104f37:	c7 04 24 8b d0 10 c0 	movl   $0xc010d08b,(%esp)
c0104f3e:	e8 bd b4 ff ff       	call   c0100400 <__panic>
c0104f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f46:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104f4b:	c9                   	leave  
c0104f4c:	c3                   	ret    

c0104f4d <kva2page>:
kva2page(void *kva) {
c0104f4d:	55                   	push   %ebp
c0104f4e:	89 e5                	mov    %esp,%ebp
c0104f50:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104f53:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f59:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104f60:	77 23                	ja     c0104f85 <kva2page+0x38>
c0104f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f69:	c7 44 24 08 c0 d0 10 	movl   $0xc010d0c0,0x8(%esp)
c0104f70:	c0 
c0104f71:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104f78:	00 
c0104f79:	c7 04 24 8b d0 10 c0 	movl   $0xc010d08b,(%esp)
c0104f80:	e8 7b b4 ff ff       	call   c0100400 <__panic>
c0104f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f88:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f8d:	89 04 24             	mov    %eax,(%esp)
c0104f90:	e8 1f ff ff ff       	call   c0104eb4 <pa2page>
}
c0104f95:	c9                   	leave  
c0104f96:	c3                   	ret    

c0104f97 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104f97:	55                   	push   %ebp
c0104f98:	89 e5                	mov    %esp,%ebp
c0104f9a:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fa0:	ba 01 00 00 00       	mov    $0x1,%edx
c0104fa5:	88 c1                	mov    %al,%cl
c0104fa7:	d3 e2                	shl    %cl,%edx
c0104fa9:	89 d0                	mov    %edx,%eax
c0104fab:	89 04 24             	mov    %eax,(%esp)
c0104fae:	e8 48 27 00 00       	call   c01076fb <alloc_pages>
c0104fb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104fb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104fba:	75 07                	jne    c0104fc3 <__slob_get_free_pages+0x2c>
    return NULL;
c0104fbc:	b8 00 00 00 00       	mov    $0x0,%eax
c0104fc1:	eb 0b                	jmp    c0104fce <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fc6:	89 04 24             	mov    %eax,(%esp)
c0104fc9:	e8 2b ff ff ff       	call   c0104ef9 <page2kva>
}
c0104fce:	c9                   	leave  
c0104fcf:	c3                   	ret    

c0104fd0 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104fd0:	55                   	push   %ebp
c0104fd1:	89 e5                	mov    %esp,%ebp
c0104fd3:	53                   	push   %ebx
c0104fd4:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fda:	ba 01 00 00 00       	mov    $0x1,%edx
c0104fdf:	88 c1                	mov    %al,%cl
c0104fe1:	d3 e2                	shl    %cl,%edx
c0104fe3:	89 d0                	mov    %edx,%eax
c0104fe5:	89 c3                	mov    %eax,%ebx
c0104fe7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fea:	89 04 24             	mov    %eax,(%esp)
c0104fed:	e8 5b ff ff ff       	call   c0104f4d <kva2page>
c0104ff2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104ff6:	89 04 24             	mov    %eax,(%esp)
c0104ff9:	e8 68 27 00 00       	call   c0107766 <free_pages>
}
c0104ffe:	90                   	nop
c0104fff:	83 c4 14             	add    $0x14,%esp
c0105002:	5b                   	pop    %ebx
c0105003:	5d                   	pop    %ebp
c0105004:	c3                   	ret    

c0105005 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0105005:	55                   	push   %ebp
c0105006:	89 e5                	mov    %esp,%ebp
c0105008:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c010500b:	8b 45 08             	mov    0x8(%ebp),%eax
c010500e:	83 c0 08             	add    $0x8,%eax
c0105011:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105016:	76 24                	jbe    c010503c <slob_alloc+0x37>
c0105018:	c7 44 24 0c e4 d0 10 	movl   $0xc010d0e4,0xc(%esp)
c010501f:	c0 
c0105020:	c7 44 24 08 03 d1 10 	movl   $0xc010d103,0x8(%esp)
c0105027:	c0 
c0105028:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010502f:	00 
c0105030:	c7 04 24 18 d1 10 c0 	movl   $0xc010d118,(%esp)
c0105037:	e8 c4 b3 ff ff       	call   c0100400 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c010503c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0105043:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010504a:	8b 45 08             	mov    0x8(%ebp),%eax
c010504d:	83 c0 07             	add    $0x7,%eax
c0105050:	c1 e8 03             	shr    $0x3,%eax
c0105053:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0105056:	e8 f2 fd ff ff       	call   c0104e4d <__intr_save>
c010505b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c010505e:	a1 08 ba 12 c0       	mov    0xc012ba08,%eax
c0105063:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105066:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105069:	8b 40 04             	mov    0x4(%eax),%eax
c010506c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c010506f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105073:	74 25                	je     c010509a <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0105075:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105078:	8b 45 10             	mov    0x10(%ebp),%eax
c010507b:	01 d0                	add    %edx,%eax
c010507d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105080:	8b 45 10             	mov    0x10(%ebp),%eax
c0105083:	f7 d8                	neg    %eax
c0105085:	21 d0                	and    %edx,%eax
c0105087:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c010508a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010508d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105090:	29 c2                	sub    %eax,%edx
c0105092:	89 d0                	mov    %edx,%eax
c0105094:	c1 f8 03             	sar    $0x3,%eax
c0105097:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c010509a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010509d:	8b 00                	mov    (%eax),%eax
c010509f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01050a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01050a5:	01 ca                	add    %ecx,%edx
c01050a7:	39 d0                	cmp    %edx,%eax
c01050a9:	0f 8c aa 00 00 00    	jl     c0105159 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c01050af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01050b3:	74 38                	je     c01050ed <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c01050b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050b8:	8b 00                	mov    (%eax),%eax
c01050ba:	2b 45 e8             	sub    -0x18(%ebp),%eax
c01050bd:	89 c2                	mov    %eax,%edx
c01050bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050c2:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c01050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050c7:	8b 50 04             	mov    0x4(%eax),%edx
c01050ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050cd:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01050d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01050d6:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01050d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01050df:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01050e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01050e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01050ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050f0:	8b 00                	mov    (%eax),%eax
c01050f2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01050f5:	75 0e                	jne    c0105105 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c01050f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050fa:	8b 50 04             	mov    0x4(%eax),%edx
c01050fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105100:	89 50 04             	mov    %edx,0x4(%eax)
c0105103:	eb 3c                	jmp    c0105141 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0105105:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105108:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010510f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105112:	01 c2                	add    %eax,%edx
c0105114:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105117:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c010511a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010511d:	8b 10                	mov    (%eax),%edx
c010511f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105122:	8b 40 04             	mov    0x4(%eax),%eax
c0105125:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0105128:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c010512a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010512d:	8b 40 04             	mov    0x4(%eax),%eax
c0105130:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105133:	8b 52 04             	mov    0x4(%edx),%edx
c0105136:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0105139:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010513c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010513f:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0105141:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105144:	a3 08 ba 12 c0       	mov    %eax,0xc012ba08
			spin_unlock_irqrestore(&slob_lock, flags);
c0105149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010514c:	89 04 24             	mov    %eax,(%esp)
c010514f:	e8 23 fd ff ff       	call   c0104e77 <__intr_restore>
			return cur;
c0105154:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105157:	eb 7f                	jmp    c01051d8 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0105159:	a1 08 ba 12 c0       	mov    0xc012ba08,%eax
c010515e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105161:	75 61                	jne    c01051c4 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0105163:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105166:	89 04 24             	mov    %eax,(%esp)
c0105169:	e8 09 fd ff ff       	call   c0104e77 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c010516e:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105175:	75 07                	jne    c010517e <slob_alloc+0x179>
				return 0;
c0105177:	b8 00 00 00 00       	mov    $0x0,%eax
c010517c:	eb 5a                	jmp    c01051d8 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c010517e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105185:	00 
c0105186:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105189:	89 04 24             	mov    %eax,(%esp)
c010518c:	e8 06 fe ff ff       	call   c0104f97 <__slob_get_free_pages>
c0105191:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105194:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105198:	75 07                	jne    c01051a1 <slob_alloc+0x19c>
				return 0;
c010519a:	b8 00 00 00 00       	mov    $0x0,%eax
c010519f:	eb 37                	jmp    c01051d8 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c01051a1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01051a8:	00 
c01051a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051ac:	89 04 24             	mov    %eax,(%esp)
c01051af:	e8 26 00 00 00       	call   c01051da <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c01051b4:	e8 94 fc ff ff       	call   c0104e4d <__intr_save>
c01051b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c01051bc:	a1 08 ba 12 c0       	mov    0xc012ba08,%eax
c01051c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01051c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01051ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051cd:	8b 40 04             	mov    0x4(%eax),%eax
c01051d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01051d3:	e9 97 fe ff ff       	jmp    c010506f <slob_alloc+0x6a>
		}
	}
}
c01051d8:	c9                   	leave  
c01051d9:	c3                   	ret    

c01051da <slob_free>:

static void slob_free(void *block, int size)
{
c01051da:	55                   	push   %ebp
c01051db:	89 e5                	mov    %esp,%ebp
c01051dd:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c01051e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01051e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01051e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01051ea:	0f 84 01 01 00 00    	je     c01052f1 <slob_free+0x117>
		return;

	if (size)
c01051f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01051f4:	74 10                	je     c0105206 <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c01051f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051f9:	83 c0 07             	add    $0x7,%eax
c01051fc:	c1 e8 03             	shr    $0x3,%eax
c01051ff:	89 c2                	mov    %eax,%edx
c0105201:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105204:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0105206:	e8 42 fc ff ff       	call   c0104e4d <__intr_save>
c010520b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010520e:	a1 08 ba 12 c0       	mov    0xc012ba08,%eax
c0105213:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105216:	eb 27                	jmp    c010523f <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0105218:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521b:	8b 40 04             	mov    0x4(%eax),%eax
c010521e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105221:	72 13                	jb     c0105236 <slob_free+0x5c>
c0105223:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105226:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105229:	77 27                	ja     c0105252 <slob_free+0x78>
c010522b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010522e:	8b 40 04             	mov    0x4(%eax),%eax
c0105231:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105234:	72 1c                	jb     c0105252 <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105236:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105239:	8b 40 04             	mov    0x4(%eax),%eax
c010523c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010523f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105242:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105245:	76 d1                	jbe    c0105218 <slob_free+0x3e>
c0105247:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010524a:	8b 40 04             	mov    0x4(%eax),%eax
c010524d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105250:	73 c6                	jae    c0105218 <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c0105252:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105255:	8b 00                	mov    (%eax),%eax
c0105257:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010525e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105261:	01 c2                	add    %eax,%edx
c0105263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105266:	8b 40 04             	mov    0x4(%eax),%eax
c0105269:	39 c2                	cmp    %eax,%edx
c010526b:	75 25                	jne    c0105292 <slob_free+0xb8>
		b->units += cur->next->units;
c010526d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105270:	8b 10                	mov    (%eax),%edx
c0105272:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105275:	8b 40 04             	mov    0x4(%eax),%eax
c0105278:	8b 00                	mov    (%eax),%eax
c010527a:	01 c2                	add    %eax,%edx
c010527c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010527f:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0105281:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105284:	8b 40 04             	mov    0x4(%eax),%eax
c0105287:	8b 50 04             	mov    0x4(%eax),%edx
c010528a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010528d:	89 50 04             	mov    %edx,0x4(%eax)
c0105290:	eb 0c                	jmp    c010529e <slob_free+0xc4>
	} else
		b->next = cur->next;
c0105292:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105295:	8b 50 04             	mov    0x4(%eax),%edx
c0105298:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010529b:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c010529e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052a1:	8b 00                	mov    (%eax),%eax
c01052a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01052aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052ad:	01 d0                	add    %edx,%eax
c01052af:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01052b2:	75 1f                	jne    c01052d3 <slob_free+0xf9>
		cur->units += b->units;
c01052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b7:	8b 10                	mov    (%eax),%edx
c01052b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052bc:	8b 00                	mov    (%eax),%eax
c01052be:	01 c2                	add    %eax,%edx
c01052c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c3:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c01052c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052c8:	8b 50 04             	mov    0x4(%eax),%edx
c01052cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052ce:	89 50 04             	mov    %edx,0x4(%eax)
c01052d1:	eb 09                	jmp    c01052dc <slob_free+0x102>
	} else
		cur->next = b;
c01052d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01052d9:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c01052dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052df:	a3 08 ba 12 c0       	mov    %eax,0xc012ba08

	spin_unlock_irqrestore(&slob_lock, flags);
c01052e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052e7:	89 04 24             	mov    %eax,(%esp)
c01052ea:	e8 88 fb ff ff       	call   c0104e77 <__intr_restore>
c01052ef:	eb 01                	jmp    c01052f2 <slob_free+0x118>
		return;
c01052f1:	90                   	nop
}
c01052f2:	c9                   	leave  
c01052f3:	c3                   	ret    

c01052f4 <slob_init>:



void
slob_init(void) {
c01052f4:	55                   	push   %ebp
c01052f5:	89 e5                	mov    %esp,%ebp
c01052f7:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c01052fa:	c7 04 24 2a d1 10 c0 	movl   $0xc010d12a,(%esp)
c0105301:	e8 a3 af ff ff       	call   c01002a9 <cprintf>
}
c0105306:	90                   	nop
c0105307:	c9                   	leave  
c0105308:	c3                   	ret    

c0105309 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0105309:	55                   	push   %ebp
c010530a:	89 e5                	mov    %esp,%ebp
c010530c:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c010530f:	e8 e0 ff ff ff       	call   c01052f4 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0105314:	c7 04 24 3e d1 10 c0 	movl   $0xc010d13e,(%esp)
c010531b:	e8 89 af ff ff       	call   c01002a9 <cprintf>
}
c0105320:	90                   	nop
c0105321:	c9                   	leave  
c0105322:	c3                   	ret    

c0105323 <slob_allocated>:

size_t
slob_allocated(void) {
c0105323:	55                   	push   %ebp
c0105324:	89 e5                	mov    %esp,%ebp
  return 0;
c0105326:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010532b:	5d                   	pop    %ebp
c010532c:	c3                   	ret    

c010532d <kallocated>:

size_t
kallocated(void) {
c010532d:	55                   	push   %ebp
c010532e:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0105330:	e8 ee ff ff ff       	call   c0105323 <slob_allocated>
}
c0105335:	5d                   	pop    %ebp
c0105336:	c3                   	ret    

c0105337 <find_order>:

static int find_order(int size)
{
c0105337:	55                   	push   %ebp
c0105338:	89 e5                	mov    %esp,%ebp
c010533a:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c010533d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0105344:	eb 06                	jmp    c010534c <find_order+0x15>
		order++;
c0105346:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0105349:	d1 7d 08             	sarl   0x8(%ebp)
c010534c:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105353:	7f f1                	jg     c0105346 <find_order+0xf>
	return order;
c0105355:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105358:	c9                   	leave  
c0105359:	c3                   	ret    

c010535a <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c010535a:	55                   	push   %ebp
c010535b:	89 e5                	mov    %esp,%ebp
c010535d:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0105360:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0105367:	77 3b                	ja     c01053a4 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0105369:	8b 45 08             	mov    0x8(%ebp),%eax
c010536c:	8d 50 08             	lea    0x8(%eax),%edx
c010536f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105376:	00 
c0105377:	8b 45 0c             	mov    0xc(%ebp),%eax
c010537a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010537e:	89 14 24             	mov    %edx,(%esp)
c0105381:	e8 7f fc ff ff       	call   c0105005 <slob_alloc>
c0105386:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0105389:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010538d:	74 0b                	je     c010539a <__kmalloc+0x40>
c010538f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105392:	83 c0 08             	add    $0x8,%eax
c0105395:	e9 b4 00 00 00       	jmp    c010544e <__kmalloc+0xf4>
c010539a:	b8 00 00 00 00       	mov    $0x0,%eax
c010539f:	e9 aa 00 00 00       	jmp    c010544e <__kmalloc+0xf4>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c01053a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01053ab:	00 
c01053ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053b3:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c01053ba:	e8 46 fc ff ff       	call   c0105005 <slob_alloc>
c01053bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c01053c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053c6:	75 07                	jne    c01053cf <__kmalloc+0x75>
		return 0;
c01053c8:	b8 00 00 00 00       	mov    $0x0,%eax
c01053cd:	eb 7f                	jmp    c010544e <__kmalloc+0xf4>

	bb->order = find_order(size);
c01053cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01053d2:	89 04 24             	mov    %eax,(%esp)
c01053d5:	e8 5d ff ff ff       	call   c0105337 <find_order>
c01053da:	89 c2                	mov    %eax,%edx
c01053dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053df:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c01053e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053e4:	8b 00                	mov    (%eax),%eax
c01053e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053ed:	89 04 24             	mov    %eax,(%esp)
c01053f0:	e8 a2 fb ff ff       	call   c0104f97 <__slob_get_free_pages>
c01053f5:	89 c2                	mov    %eax,%edx
c01053f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053fa:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c01053fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105400:	8b 40 04             	mov    0x4(%eax),%eax
c0105403:	85 c0                	test   %eax,%eax
c0105405:	74 2f                	je     c0105436 <__kmalloc+0xdc>
		spin_lock_irqsave(&block_lock, flags);
c0105407:	e8 41 fa ff ff       	call   c0104e4d <__intr_save>
c010540c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c010540f:	8b 15 68 ff 19 c0    	mov    0xc019ff68,%edx
c0105415:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105418:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c010541b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010541e:	a3 68 ff 19 c0       	mov    %eax,0xc019ff68
		spin_unlock_irqrestore(&block_lock, flags);
c0105423:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105426:	89 04 24             	mov    %eax,(%esp)
c0105429:	e8 49 fa ff ff       	call   c0104e77 <__intr_restore>
		return bb->pages;
c010542e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105431:	8b 40 04             	mov    0x4(%eax),%eax
c0105434:	eb 18                	jmp    c010544e <__kmalloc+0xf4>
	}

	slob_free(bb, sizeof(bigblock_t));
c0105436:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c010543d:	00 
c010543e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105441:	89 04 24             	mov    %eax,(%esp)
c0105444:	e8 91 fd ff ff       	call   c01051da <slob_free>
	return 0;
c0105449:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010544e:	c9                   	leave  
c010544f:	c3                   	ret    

c0105450 <kmalloc>:

void *
kmalloc(size_t size)
{
c0105450:	55                   	push   %ebp
c0105451:	89 e5                	mov    %esp,%ebp
c0105453:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0105456:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010545d:	00 
c010545e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105461:	89 04 24             	mov    %eax,(%esp)
c0105464:	e8 f1 fe ff ff       	call   c010535a <__kmalloc>
}
c0105469:	c9                   	leave  
c010546a:	c3                   	ret    

c010546b <kfree>:


void kfree(void *block)
{
c010546b:	55                   	push   %ebp
c010546c:	89 e5                	mov    %esp,%ebp
c010546e:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0105471:	c7 45 f0 68 ff 19 c0 	movl   $0xc019ff68,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105478:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010547c:	0f 84 a4 00 00 00    	je     c0105526 <kfree+0xbb>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105482:	8b 45 08             	mov    0x8(%ebp),%eax
c0105485:	25 ff 0f 00 00       	and    $0xfff,%eax
c010548a:	85 c0                	test   %eax,%eax
c010548c:	75 7f                	jne    c010550d <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c010548e:	e8 ba f9 ff ff       	call   c0104e4d <__intr_save>
c0105493:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105496:	a1 68 ff 19 c0       	mov    0xc019ff68,%eax
c010549b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010549e:	eb 5c                	jmp    c01054fc <kfree+0x91>
			if (bb->pages == block) {
c01054a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054a3:	8b 40 04             	mov    0x4(%eax),%eax
c01054a6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01054a9:	75 3f                	jne    c01054ea <kfree+0x7f>
				*last = bb->next;
c01054ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054ae:	8b 50 08             	mov    0x8(%eax),%edx
c01054b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054b4:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c01054b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054b9:	89 04 24             	mov    %eax,(%esp)
c01054bc:	e8 b6 f9 ff ff       	call   c0104e77 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c01054c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054c4:	8b 10                	mov    (%eax),%edx
c01054c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01054c9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054cd:	89 04 24             	mov    %eax,(%esp)
c01054d0:	e8 fb fa ff ff       	call   c0104fd0 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c01054d5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c01054dc:	00 
c01054dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054e0:	89 04 24             	mov    %eax,(%esp)
c01054e3:	e8 f2 fc ff ff       	call   c01051da <slob_free>
				return;
c01054e8:	eb 3d                	jmp    c0105527 <kfree+0xbc>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c01054ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054ed:	83 c0 08             	add    $0x8,%eax
c01054f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054f6:	8b 40 08             	mov    0x8(%eax),%eax
c01054f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105500:	75 9e                	jne    c01054a0 <kfree+0x35>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0105502:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105505:	89 04 24             	mov    %eax,(%esp)
c0105508:	e8 6a f9 ff ff       	call   c0104e77 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c010550d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105510:	83 e8 08             	sub    $0x8,%eax
c0105513:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010551a:	00 
c010551b:	89 04 24             	mov    %eax,(%esp)
c010551e:	e8 b7 fc ff ff       	call   c01051da <slob_free>
	return;
c0105523:	90                   	nop
c0105524:	eb 01                	jmp    c0105527 <kfree+0xbc>
		return;
c0105526:	90                   	nop
}
c0105527:	c9                   	leave  
c0105528:	c3                   	ret    

c0105529 <ksize>:


unsigned int ksize(const void *block)
{
c0105529:	55                   	push   %ebp
c010552a:	89 e5                	mov    %esp,%ebp
c010552c:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c010552f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105533:	75 07                	jne    c010553c <ksize+0x13>
		return 0;
c0105535:	b8 00 00 00 00       	mov    $0x0,%eax
c010553a:	eb 6b                	jmp    c01055a7 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c010553c:	8b 45 08             	mov    0x8(%ebp),%eax
c010553f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105544:	85 c0                	test   %eax,%eax
c0105546:	75 54                	jne    c010559c <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0105548:	e8 00 f9 ff ff       	call   c0104e4d <__intr_save>
c010554d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0105550:	a1 68 ff 19 c0       	mov    0xc019ff68,%eax
c0105555:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105558:	eb 31                	jmp    c010558b <ksize+0x62>
			if (bb->pages == block) {
c010555a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010555d:	8b 40 04             	mov    0x4(%eax),%eax
c0105560:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105563:	75 1d                	jne    c0105582 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0105565:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105568:	89 04 24             	mov    %eax,(%esp)
c010556b:	e8 07 f9 ff ff       	call   c0104e77 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0105570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105573:	8b 00                	mov    (%eax),%eax
c0105575:	ba 00 10 00 00       	mov    $0x1000,%edx
c010557a:	88 c1                	mov    %al,%cl
c010557c:	d3 e2                	shl    %cl,%edx
c010557e:	89 d0                	mov    %edx,%eax
c0105580:	eb 25                	jmp    c01055a7 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0105582:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105585:	8b 40 08             	mov    0x8(%eax),%eax
c0105588:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010558b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010558f:	75 c9                	jne    c010555a <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0105591:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105594:	89 04 24             	mov    %eax,(%esp)
c0105597:	e8 db f8 ff ff       	call   c0104e77 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c010559c:	8b 45 08             	mov    0x8(%ebp),%eax
c010559f:	83 e8 08             	sub    $0x8,%eax
c01055a2:	8b 00                	mov    (%eax),%eax
c01055a4:	c1 e0 03             	shl    $0x3,%eax
}
c01055a7:	c9                   	leave  
c01055a8:	c3                   	ret    

c01055a9 <pa2page>:
pa2page(uintptr_t pa) {
c01055a9:	55                   	push   %ebp
c01055aa:	89 e5                	mov    %esp,%ebp
c01055ac:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01055af:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b2:	c1 e8 0c             	shr    $0xc,%eax
c01055b5:	89 c2                	mov    %eax,%edx
c01055b7:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c01055bc:	39 c2                	cmp    %eax,%edx
c01055be:	72 1c                	jb     c01055dc <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01055c0:	c7 44 24 08 5c d1 10 	movl   $0xc010d15c,0x8(%esp)
c01055c7:	c0 
c01055c8:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01055cf:	00 
c01055d0:	c7 04 24 7b d1 10 c0 	movl   $0xc010d17b,(%esp)
c01055d7:	e8 24 ae ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c01055dc:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c01055e1:	8b 55 08             	mov    0x8(%ebp),%edx
c01055e4:	c1 ea 0c             	shr    $0xc,%edx
c01055e7:	c1 e2 05             	shl    $0x5,%edx
c01055ea:	01 d0                	add    %edx,%eax
}
c01055ec:	c9                   	leave  
c01055ed:	c3                   	ret    

c01055ee <pte2page>:
pte2page(pte_t pte) {
c01055ee:	55                   	push   %ebp
c01055ef:	89 e5                	mov    %esp,%ebp
c01055f1:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01055f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f7:	83 e0 01             	and    $0x1,%eax
c01055fa:	85 c0                	test   %eax,%eax
c01055fc:	75 1c                	jne    c010561a <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01055fe:	c7 44 24 08 8c d1 10 	movl   $0xc010d18c,0x8(%esp)
c0105605:	c0 
c0105606:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010560d:	00 
c010560e:	c7 04 24 7b d1 10 c0 	movl   $0xc010d17b,(%esp)
c0105615:	e8 e6 ad ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c010561a:	8b 45 08             	mov    0x8(%ebp),%eax
c010561d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105622:	89 04 24             	mov    %eax,(%esp)
c0105625:	e8 7f ff ff ff       	call   c01055a9 <pa2page>
}
c010562a:	c9                   	leave  
c010562b:	c3                   	ret    

c010562c <pde2page>:
pde2page(pde_t pde) {
c010562c:	55                   	push   %ebp
c010562d:	89 e5                	mov    %esp,%ebp
c010562f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0105632:	8b 45 08             	mov    0x8(%ebp),%eax
c0105635:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010563a:	89 04 24             	mov    %eax,(%esp)
c010563d:	e8 67 ff ff ff       	call   c01055a9 <pa2page>
}
c0105642:	c9                   	leave  
c0105643:	c3                   	ret    

c0105644 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0105644:	55                   	push   %ebp
c0105645:	89 e5                	mov    %esp,%ebp
c0105647:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010564a:	e8 f3 3c 00 00       	call   c0109342 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010564f:	a1 1c 21 1a c0       	mov    0xc01a211c,%eax
c0105654:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0105659:	76 0c                	jbe    c0105667 <swap_init+0x23>
c010565b:	a1 1c 21 1a c0       	mov    0xc01a211c,%eax
c0105660:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0105665:	76 25                	jbe    c010568c <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0105667:	a1 1c 21 1a c0       	mov    0xc01a211c,%eax
c010566c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105670:	c7 44 24 08 ad d1 10 	movl   $0xc010d1ad,0x8(%esp)
c0105677:	c0 
c0105678:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c010567f:	00 
c0105680:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105687:	e8 74 ad ff ff       	call   c0100400 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010568c:	c7 05 74 ff 19 c0 e0 	movl   $0xc012b9e0,0xc019ff74
c0105693:	b9 12 c0 
     int r = sm->init();
c0105696:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c010569b:	8b 40 04             	mov    0x4(%eax),%eax
c010569e:	ff d0                	call   *%eax
c01056a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01056a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01056a7:	75 26                	jne    c01056cf <swap_init+0x8b>
     {
          swap_init_ok = 1;
c01056a9:	c7 05 6c ff 19 c0 01 	movl   $0x1,0xc019ff6c
c01056b0:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c01056b3:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c01056b8:	8b 00                	mov    (%eax),%eax
c01056ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056be:	c7 04 24 d7 d1 10 c0 	movl   $0xc010d1d7,(%esp)
c01056c5:	e8 df ab ff ff       	call   c01002a9 <cprintf>
          check_swap();
c01056ca:	e8 9e 04 00 00       	call   c0105b6d <check_swap>
     }

     return r;
c01056cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056d2:	c9                   	leave  
c01056d3:	c3                   	ret    

c01056d4 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01056d4:	55                   	push   %ebp
c01056d5:	89 e5                	mov    %esp,%ebp
c01056d7:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01056da:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c01056df:	8b 40 08             	mov    0x8(%eax),%eax
c01056e2:	8b 55 08             	mov    0x8(%ebp),%edx
c01056e5:	89 14 24             	mov    %edx,(%esp)
c01056e8:	ff d0                	call   *%eax
}
c01056ea:	c9                   	leave  
c01056eb:	c3                   	ret    

c01056ec <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01056ec:	55                   	push   %ebp
c01056ed:	89 e5                	mov    %esp,%ebp
c01056ef:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01056f2:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c01056f7:	8b 40 0c             	mov    0xc(%eax),%eax
c01056fa:	8b 55 08             	mov    0x8(%ebp),%edx
c01056fd:	89 14 24             	mov    %edx,(%esp)
c0105700:	ff d0                	call   *%eax
}
c0105702:	c9                   	leave  
c0105703:	c3                   	ret    

c0105704 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105704:	55                   	push   %ebp
c0105705:	89 e5                	mov    %esp,%ebp
c0105707:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c010570a:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c010570f:	8b 40 10             	mov    0x10(%eax),%eax
c0105712:	8b 55 14             	mov    0x14(%ebp),%edx
c0105715:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105719:	8b 55 10             	mov    0x10(%ebp),%edx
c010571c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105720:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105723:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105727:	8b 55 08             	mov    0x8(%ebp),%edx
c010572a:	89 14 24             	mov    %edx,(%esp)
c010572d:	ff d0                	call   *%eax
}
c010572f:	c9                   	leave  
c0105730:	c3                   	ret    

c0105731 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0105731:	55                   	push   %ebp
c0105732:	89 e5                	mov    %esp,%ebp
c0105734:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0105737:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c010573c:	8b 40 14             	mov    0x14(%eax),%eax
c010573f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105742:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105746:	8b 55 08             	mov    0x8(%ebp),%edx
c0105749:	89 14 24             	mov    %edx,(%esp)
c010574c:	ff d0                	call   *%eax
}
c010574e:	c9                   	leave  
c010574f:	c3                   	ret    

c0105750 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0105750:	55                   	push   %ebp
c0105751:	89 e5                	mov    %esp,%ebp
c0105753:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0105756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010575d:	e9 53 01 00 00       	jmp    c01058b5 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0105762:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c0105767:	8b 40 18             	mov    0x18(%eax),%eax
c010576a:	8b 55 10             	mov    0x10(%ebp),%edx
c010576d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105771:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0105774:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105778:	8b 55 08             	mov    0x8(%ebp),%edx
c010577b:	89 14 24             	mov    %edx,(%esp)
c010577e:	ff d0                	call   *%eax
c0105780:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0105783:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105787:	74 18                	je     c01057a1 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0105789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010578c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105790:	c7 04 24 ec d1 10 c0 	movl   $0xc010d1ec,(%esp)
c0105797:	e8 0d ab ff ff       	call   c01002a9 <cprintf>
c010579c:	e9 20 01 00 00       	jmp    c01058c1 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01057a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057a4:	8b 40 1c             	mov    0x1c(%eax),%eax
c01057a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01057aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ad:	8b 40 0c             	mov    0xc(%eax),%eax
c01057b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01057b7:	00 
c01057b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01057bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057bf:	89 04 24             	mov    %eax,(%esp)
c01057c2:	e8 14 26 00 00       	call   c0107ddb <get_pte>
c01057c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01057ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057cd:	8b 00                	mov    (%eax),%eax
c01057cf:	83 e0 01             	and    $0x1,%eax
c01057d2:	85 c0                	test   %eax,%eax
c01057d4:	75 24                	jne    c01057fa <swap_out+0xaa>
c01057d6:	c7 44 24 0c 19 d2 10 	movl   $0xc010d219,0xc(%esp)
c01057dd:	c0 
c01057de:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c01057e5:	c0 
c01057e6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01057ed:	00 
c01057ee:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c01057f5:	e8 06 ac ff ff       	call   c0100400 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01057fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105800:	8b 52 1c             	mov    0x1c(%edx),%edx
c0105803:	c1 ea 0c             	shr    $0xc,%edx
c0105806:	42                   	inc    %edx
c0105807:	c1 e2 08             	shl    $0x8,%edx
c010580a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010580e:	89 14 24             	mov    %edx,(%esp)
c0105811:	e8 e7 3b 00 00       	call   c01093fd <swapfs_write>
c0105816:	85 c0                	test   %eax,%eax
c0105818:	74 34                	je     c010584e <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c010581a:	c7 04 24 43 d2 10 c0 	movl   $0xc010d243,(%esp)
c0105821:	e8 83 aa ff ff       	call   c01002a9 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0105826:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c010582b:	8b 40 10             	mov    0x10(%eax),%eax
c010582e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105831:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105838:	00 
c0105839:	89 54 24 08          	mov    %edx,0x8(%esp)
c010583d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105840:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105844:	8b 55 08             	mov    0x8(%ebp),%edx
c0105847:	89 14 24             	mov    %edx,(%esp)
c010584a:	ff d0                	call   *%eax
c010584c:	eb 64                	jmp    c01058b2 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c010584e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105851:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105854:	c1 e8 0c             	shr    $0xc,%eax
c0105857:	40                   	inc    %eax
c0105858:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010585c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010585f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105866:	89 44 24 04          	mov    %eax,0x4(%esp)
c010586a:	c7 04 24 5c d2 10 c0 	movl   $0xc010d25c,(%esp)
c0105871:	e8 33 aa ff ff       	call   c01002a9 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0105876:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105879:	8b 40 1c             	mov    0x1c(%eax),%eax
c010587c:	c1 e8 0c             	shr    $0xc,%eax
c010587f:	40                   	inc    %eax
c0105880:	c1 e0 08             	shl    $0x8,%eax
c0105883:	89 c2                	mov    %eax,%edx
c0105885:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105888:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c010588a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010588d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105894:	00 
c0105895:	89 04 24             	mov    %eax,(%esp)
c0105898:	e8 c9 1e 00 00       	call   c0107766 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c010589d:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a0:	8b 40 0c             	mov    0xc(%eax),%eax
c01058a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01058a6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01058aa:	89 04 24             	mov    %eax,(%esp)
c01058ad:	e8 3b 2c 00 00       	call   c01084ed <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c01058b2:	ff 45 f4             	incl   -0xc(%ebp)
c01058b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01058bb:	0f 85 a1 fe ff ff    	jne    c0105762 <swap_out+0x12>
     }
     return i;
c01058c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01058c4:	c9                   	leave  
c01058c5:	c3                   	ret    

c01058c6 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01058c6:	55                   	push   %ebp
c01058c7:	89 e5                	mov    %esp,%ebp
c01058c9:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01058cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01058d3:	e8 23 1e 00 00       	call   c01076fb <alloc_pages>
c01058d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01058db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058df:	75 24                	jne    c0105905 <swap_in+0x3f>
c01058e1:	c7 44 24 0c 9c d2 10 	movl   $0xc010d29c,0xc(%esp)
c01058e8:	c0 
c01058e9:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c01058f0:	c0 
c01058f1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01058f8:	00 
c01058f9:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105900:	e8 fb aa ff ff       	call   c0100400 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0105905:	8b 45 08             	mov    0x8(%ebp),%eax
c0105908:	8b 40 0c             	mov    0xc(%eax),%eax
c010590b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105912:	00 
c0105913:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105916:	89 54 24 04          	mov    %edx,0x4(%esp)
c010591a:	89 04 24             	mov    %eax,(%esp)
c010591d:	e8 b9 24 00 00       	call   c0107ddb <get_pte>
c0105922:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0105925:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105928:	8b 00                	mov    (%eax),%eax
c010592a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010592d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105931:	89 04 24             	mov    %eax,(%esp)
c0105934:	e8 52 3a 00 00       	call   c010938b <swapfs_read>
c0105939:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010593c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105940:	74 2a                	je     c010596c <swap_in+0xa6>
     {
        assert(r!=0);
c0105942:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105946:	75 24                	jne    c010596c <swap_in+0xa6>
c0105948:	c7 44 24 0c a9 d2 10 	movl   $0xc010d2a9,0xc(%esp)
c010594f:	c0 
c0105950:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105957:	c0 
c0105958:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c010595f:	00 
c0105960:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105967:	e8 94 aa ff ff       	call   c0100400 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c010596c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010596f:	8b 00                	mov    (%eax),%eax
c0105971:	c1 e8 08             	shr    $0x8,%eax
c0105974:	89 c2                	mov    %eax,%edx
c0105976:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105979:	89 44 24 08          	mov    %eax,0x8(%esp)
c010597d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105981:	c7 04 24 b0 d2 10 c0 	movl   $0xc010d2b0,(%esp)
c0105988:	e8 1c a9 ff ff       	call   c01002a9 <cprintf>
     *ptr_result=result;
c010598d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105990:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105993:	89 10                	mov    %edx,(%eax)
     return 0;
c0105995:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010599a:	c9                   	leave  
c010599b:	c3                   	ret    

c010599c <check_content_set>:



static inline void
check_content_set(void)
{
c010599c:	55                   	push   %ebp
c010599d:	89 e5                	mov    %esp,%ebp
c010599f:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01059a2:	b8 00 10 00 00       	mov    $0x1000,%eax
c01059a7:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01059aa:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c01059af:	83 f8 01             	cmp    $0x1,%eax
c01059b2:	74 24                	je     c01059d8 <check_content_set+0x3c>
c01059b4:	c7 44 24 0c ee d2 10 	movl   $0xc010d2ee,0xc(%esp)
c01059bb:	c0 
c01059bc:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c01059c3:	c0 
c01059c4:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01059cb:	00 
c01059cc:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c01059d3:	e8 28 aa ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01059d8:	b8 10 10 00 00       	mov    $0x1010,%eax
c01059dd:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01059e0:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c01059e5:	83 f8 01             	cmp    $0x1,%eax
c01059e8:	74 24                	je     c0105a0e <check_content_set+0x72>
c01059ea:	c7 44 24 0c ee d2 10 	movl   $0xc010d2ee,0xc(%esp)
c01059f1:	c0 
c01059f2:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c01059f9:	c0 
c01059fa:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0105a01:	00 
c0105a02:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105a09:	e8 f2 a9 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105a0e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105a13:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105a16:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0105a1b:	83 f8 02             	cmp    $0x2,%eax
c0105a1e:	74 24                	je     c0105a44 <check_content_set+0xa8>
c0105a20:	c7 44 24 0c fd d2 10 	movl   $0xc010d2fd,0xc(%esp)
c0105a27:	c0 
c0105a28:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105a2f:	c0 
c0105a30:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0105a37:	00 
c0105a38:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105a3f:	e8 bc a9 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0105a44:	b8 10 20 00 00       	mov    $0x2010,%eax
c0105a49:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105a4c:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0105a51:	83 f8 02             	cmp    $0x2,%eax
c0105a54:	74 24                	je     c0105a7a <check_content_set+0xde>
c0105a56:	c7 44 24 0c fd d2 10 	movl   $0xc010d2fd,0xc(%esp)
c0105a5d:	c0 
c0105a5e:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105a65:	c0 
c0105a66:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0105a6d:	00 
c0105a6e:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105a75:	e8 86 a9 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0105a7a:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105a7f:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105a82:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0105a87:	83 f8 03             	cmp    $0x3,%eax
c0105a8a:	74 24                	je     c0105ab0 <check_content_set+0x114>
c0105a8c:	c7 44 24 0c 0c d3 10 	movl   $0xc010d30c,0xc(%esp)
c0105a93:	c0 
c0105a94:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105a9b:	c0 
c0105a9c:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0105aa3:	00 
c0105aa4:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105aab:	e8 50 a9 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0105ab0:	b8 10 30 00 00       	mov    $0x3010,%eax
c0105ab5:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105ab8:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0105abd:	83 f8 03             	cmp    $0x3,%eax
c0105ac0:	74 24                	je     c0105ae6 <check_content_set+0x14a>
c0105ac2:	c7 44 24 0c 0c d3 10 	movl   $0xc010d30c,0xc(%esp)
c0105ac9:	c0 
c0105aca:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105ad1:	c0 
c0105ad2:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0105ad9:	00 
c0105ada:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105ae1:	e8 1a a9 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0105ae6:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105aeb:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105aee:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0105af3:	83 f8 04             	cmp    $0x4,%eax
c0105af6:	74 24                	je     c0105b1c <check_content_set+0x180>
c0105af8:	c7 44 24 0c 1b d3 10 	movl   $0xc010d31b,0xc(%esp)
c0105aff:	c0 
c0105b00:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105b07:	c0 
c0105b08:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0105b0f:	00 
c0105b10:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105b17:	e8 e4 a8 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0105b1c:	b8 10 40 00 00       	mov    $0x4010,%eax
c0105b21:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105b24:	a1 64 ff 19 c0       	mov    0xc019ff64,%eax
c0105b29:	83 f8 04             	cmp    $0x4,%eax
c0105b2c:	74 24                	je     c0105b52 <check_content_set+0x1b6>
c0105b2e:	c7 44 24 0c 1b d3 10 	movl   $0xc010d31b,0xc(%esp)
c0105b35:	c0 
c0105b36:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105b3d:	c0 
c0105b3e:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0105b45:	00 
c0105b46:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105b4d:	e8 ae a8 ff ff       	call   c0100400 <__panic>
}
c0105b52:	90                   	nop
c0105b53:	c9                   	leave  
c0105b54:	c3                   	ret    

c0105b55 <check_content_access>:

static inline int
check_content_access(void)
{
c0105b55:	55                   	push   %ebp
c0105b56:	89 e5                	mov    %esp,%ebp
c0105b58:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105b5b:	a1 74 ff 19 c0       	mov    0xc019ff74,%eax
c0105b60:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105b63:	ff d0                	call   *%eax
c0105b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0105b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b6b:	c9                   	leave  
c0105b6c:	c3                   	ret    

c0105b6d <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105b6d:	55                   	push   %ebp
c0105b6e:	89 e5                	mov    %esp,%ebp
c0105b70:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0105b73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0105b81:	c7 45 e8 44 21 1a c0 	movl   $0xc01a2144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105b88:	eb 6a                	jmp    c0105bf4 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0105b8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b8d:	83 e8 0c             	sub    $0xc,%eax
c0105b90:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0105b93:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105b96:	83 c0 04             	add    $0x4,%eax
c0105b99:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0105ba0:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105ba3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105ba6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105ba9:	0f a3 10             	bt     %edx,(%eax)
c0105bac:	19 c0                	sbb    %eax,%eax
c0105bae:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0105bb1:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105bb5:	0f 95 c0             	setne  %al
c0105bb8:	0f b6 c0             	movzbl %al,%eax
c0105bbb:	85 c0                	test   %eax,%eax
c0105bbd:	75 24                	jne    c0105be3 <check_swap+0x76>
c0105bbf:	c7 44 24 0c 2a d3 10 	movl   $0xc010d32a,0xc(%esp)
c0105bc6:	c0 
c0105bc7:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105bce:	c0 
c0105bcf:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0105bd6:	00 
c0105bd7:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105bde:	e8 1d a8 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c0105be3:	ff 45 f4             	incl   -0xc(%ebp)
c0105be6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105be9:	8b 50 08             	mov    0x8(%eax),%edx
c0105bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bef:	01 d0                	add    %edx,%eax
c0105bf1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bf7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c0105bfa:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105bfd:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0105c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c03:	81 7d e8 44 21 1a c0 	cmpl   $0xc01a2144,-0x18(%ebp)
c0105c0a:	0f 85 7a ff ff ff    	jne    c0105b8a <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0105c10:	e8 84 1b 00 00       	call   c0107799 <nr_free_pages>
c0105c15:	89 c2                	mov    %eax,%edx
c0105c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c1a:	39 c2                	cmp    %eax,%edx
c0105c1c:	74 24                	je     c0105c42 <check_swap+0xd5>
c0105c1e:	c7 44 24 0c 3a d3 10 	movl   $0xc010d33a,0xc(%esp)
c0105c25:	c0 
c0105c26:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105c2d:	c0 
c0105c2e:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0105c35:	00 
c0105c36:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105c3d:	e8 be a7 ff ff       	call   c0100400 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0105c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c45:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c50:	c7 04 24 54 d3 10 c0 	movl   $0xc010d354,(%esp)
c0105c57:	e8 4d a6 ff ff       	call   c01002a9 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0105c5c:	e8 1a d9 ff ff       	call   c010357b <mm_create>
c0105c61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0105c64:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105c68:	75 24                	jne    c0105c8e <check_swap+0x121>
c0105c6a:	c7 44 24 0c 7a d3 10 	movl   $0xc010d37a,0xc(%esp)
c0105c71:	c0 
c0105c72:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105c79:	c0 
c0105c7a:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0105c81:	00 
c0105c82:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105c89:	e8 72 a7 ff ff       	call   c0100400 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0105c8e:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c0105c93:	85 c0                	test   %eax,%eax
c0105c95:	74 24                	je     c0105cbb <check_swap+0x14e>
c0105c97:	c7 44 24 0c 85 d3 10 	movl   $0xc010d385,0xc(%esp)
c0105c9e:	c0 
c0105c9f:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105ca6:	c0 
c0105ca7:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0105cae:	00 
c0105caf:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105cb6:	e8 45 a7 ff ff       	call   c0100400 <__panic>

     check_mm_struct = mm;
c0105cbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cbe:	a3 58 20 1a c0       	mov    %eax,0xc01a2058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105cc3:	8b 15 20 ba 12 c0    	mov    0xc012ba20,%edx
c0105cc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ccc:	89 50 0c             	mov    %edx,0xc(%eax)
c0105ccf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cd2:	8b 40 0c             	mov    0xc(%eax),%eax
c0105cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0105cd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cdb:	8b 00                	mov    (%eax),%eax
c0105cdd:	85 c0                	test   %eax,%eax
c0105cdf:	74 24                	je     c0105d05 <check_swap+0x198>
c0105ce1:	c7 44 24 0c 9d d3 10 	movl   $0xc010d39d,0xc(%esp)
c0105ce8:	c0 
c0105ce9:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105cf0:	c0 
c0105cf1:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0105cf8:	00 
c0105cf9:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105d00:	e8 fb a6 ff ff       	call   c0100400 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0105d05:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0105d0c:	00 
c0105d0d:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0105d14:	00 
c0105d15:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0105d1c:	e8 f3 d8 ff ff       	call   c0103614 <vma_create>
c0105d21:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0105d24:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105d28:	75 24                	jne    c0105d4e <check_swap+0x1e1>
c0105d2a:	c7 44 24 0c ab d3 10 	movl   $0xc010d3ab,0xc(%esp)
c0105d31:	c0 
c0105d32:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105d39:	c0 
c0105d3a:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0105d41:	00 
c0105d42:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105d49:	e8 b2 a6 ff ff       	call   c0100400 <__panic>

     insert_vma_struct(mm, vma);
c0105d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d58:	89 04 24             	mov    %eax,(%esp)
c0105d5b:	e8 45 da ff ff       	call   c01037a5 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0105d60:	c7 04 24 b8 d3 10 c0 	movl   $0xc010d3b8,(%esp)
c0105d67:	e8 3d a5 ff ff       	call   c01002a9 <cprintf>
     pte_t *temp_ptep=NULL;
c0105d6c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0105d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d76:	8b 40 0c             	mov    0xc(%eax),%eax
c0105d79:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105d80:	00 
c0105d81:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105d88:	00 
c0105d89:	89 04 24             	mov    %eax,(%esp)
c0105d8c:	e8 4a 20 00 00       	call   c0107ddb <get_pte>
c0105d91:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0105d94:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105d98:	75 24                	jne    c0105dbe <check_swap+0x251>
c0105d9a:	c7 44 24 0c ec d3 10 	movl   $0xc010d3ec,0xc(%esp)
c0105da1:	c0 
c0105da2:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105da9:	c0 
c0105daa:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0105db1:	00 
c0105db2:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105db9:	e8 42 a6 ff ff       	call   c0100400 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0105dbe:	c7 04 24 00 d4 10 c0 	movl   $0xc010d400,(%esp)
c0105dc5:	e8 df a4 ff ff       	call   c01002a9 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105dca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105dd1:	e9 a4 00 00 00       	jmp    c0105e7a <check_swap+0x30d>
          check_rp[i] = alloc_page();
c0105dd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ddd:	e8 19 19 00 00       	call   c01076fb <alloc_pages>
c0105de2:	89 c2                	mov    %eax,%edx
c0105de4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105de7:	89 14 85 80 20 1a c0 	mov    %edx,-0x3fe5df80(,%eax,4)
          assert(check_rp[i] != NULL );
c0105dee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105df1:	8b 04 85 80 20 1a c0 	mov    -0x3fe5df80(,%eax,4),%eax
c0105df8:	85 c0                	test   %eax,%eax
c0105dfa:	75 24                	jne    c0105e20 <check_swap+0x2b3>
c0105dfc:	c7 44 24 0c 24 d4 10 	movl   $0xc010d424,0xc(%esp)
c0105e03:	c0 
c0105e04:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105e0b:	c0 
c0105e0c:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0105e13:	00 
c0105e14:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105e1b:	e8 e0 a5 ff ff       	call   c0100400 <__panic>
          assert(!PageProperty(check_rp[i]));
c0105e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e23:	8b 04 85 80 20 1a c0 	mov    -0x3fe5df80(,%eax,4),%eax
c0105e2a:	83 c0 04             	add    $0x4,%eax
c0105e2d:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0105e34:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e37:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105e3a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105e3d:	0f a3 10             	bt     %edx,(%eax)
c0105e40:	19 c0                	sbb    %eax,%eax
c0105e42:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0105e45:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0105e49:	0f 95 c0             	setne  %al
c0105e4c:	0f b6 c0             	movzbl %al,%eax
c0105e4f:	85 c0                	test   %eax,%eax
c0105e51:	74 24                	je     c0105e77 <check_swap+0x30a>
c0105e53:	c7 44 24 0c 38 d4 10 	movl   $0xc010d438,0xc(%esp)
c0105e5a:	c0 
c0105e5b:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105e62:	c0 
c0105e63:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0105e6a:	00 
c0105e6b:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105e72:	e8 89 a5 ff ff       	call   c0100400 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105e77:	ff 45 ec             	incl   -0x14(%ebp)
c0105e7a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105e7e:	0f 8e 52 ff ff ff    	jle    c0105dd6 <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c0105e84:	a1 44 21 1a c0       	mov    0xc01a2144,%eax
c0105e89:	8b 15 48 21 1a c0    	mov    0xc01a2148,%edx
c0105e8f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105e92:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105e95:	c7 45 a4 44 21 1a c0 	movl   $0xc01a2144,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0105e9c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105e9f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0105ea2:	89 50 04             	mov    %edx,0x4(%eax)
c0105ea5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105ea8:	8b 50 04             	mov    0x4(%eax),%edx
c0105eab:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105eae:	89 10                	mov    %edx,(%eax)
c0105eb0:	c7 45 a8 44 21 1a c0 	movl   $0xc01a2144,-0x58(%ebp)
    return list->next == list;
c0105eb7:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105eba:	8b 40 04             	mov    0x4(%eax),%eax
c0105ebd:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0105ec0:	0f 94 c0             	sete   %al
c0105ec3:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0105ec6:	85 c0                	test   %eax,%eax
c0105ec8:	75 24                	jne    c0105eee <check_swap+0x381>
c0105eca:	c7 44 24 0c 53 d4 10 	movl   $0xc010d453,0xc(%esp)
c0105ed1:	c0 
c0105ed2:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105ed9:	c0 
c0105eda:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0105ee1:	00 
c0105ee2:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105ee9:	e8 12 a5 ff ff       	call   c0100400 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0105eee:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0105ef3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0105ef6:	c7 05 4c 21 1a c0 00 	movl   $0x0,0xc01a214c
c0105efd:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105f00:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105f07:	eb 1d                	jmp    c0105f26 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0105f09:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f0c:	8b 04 85 80 20 1a c0 	mov    -0x3fe5df80(,%eax,4),%eax
c0105f13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105f1a:	00 
c0105f1b:	89 04 24             	mov    %eax,(%esp)
c0105f1e:	e8 43 18 00 00       	call   c0107766 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105f23:	ff 45 ec             	incl   -0x14(%ebp)
c0105f26:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105f2a:	7e dd                	jle    c0105f09 <check_swap+0x39c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0105f2c:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0105f31:	83 f8 04             	cmp    $0x4,%eax
c0105f34:	74 24                	je     c0105f5a <check_swap+0x3ed>
c0105f36:	c7 44 24 0c 6c d4 10 	movl   $0xc010d46c,0xc(%esp)
c0105f3d:	c0 
c0105f3e:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105f45:	c0 
c0105f46:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0105f4d:	00 
c0105f4e:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105f55:	e8 a6 a4 ff ff       	call   c0100400 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0105f5a:	c7 04 24 90 d4 10 c0 	movl   $0xc010d490,(%esp)
c0105f61:	e8 43 a3 ff ff       	call   c01002a9 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0105f66:	c7 05 64 ff 19 c0 00 	movl   $0x0,0xc019ff64
c0105f6d:	00 00 00 
     
     check_content_set();
c0105f70:	e8 27 fa ff ff       	call   c010599c <check_content_set>
     assert( nr_free == 0);         
c0105f75:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0105f7a:	85 c0                	test   %eax,%eax
c0105f7c:	74 24                	je     c0105fa2 <check_swap+0x435>
c0105f7e:	c7 44 24 0c b7 d4 10 	movl   $0xc010d4b7,0xc(%esp)
c0105f85:	c0 
c0105f86:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0105f8d:	c0 
c0105f8e:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0105f95:	00 
c0105f96:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0105f9d:	e8 5e a4 ff ff       	call   c0100400 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105fa2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105fa9:	eb 25                	jmp    c0105fd0 <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0105fab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fae:	c7 04 85 a0 20 1a c0 	movl   $0xffffffff,-0x3fe5df60(,%eax,4)
c0105fb5:	ff ff ff ff 
c0105fb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fbc:	8b 14 85 a0 20 1a c0 	mov    -0x3fe5df60(,%eax,4),%edx
c0105fc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fc6:	89 14 85 e0 20 1a c0 	mov    %edx,-0x3fe5df20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105fcd:	ff 45 ec             	incl   -0x14(%ebp)
c0105fd0:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0105fd4:	7e d5                	jle    c0105fab <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105fd6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105fdd:	e9 ec 00 00 00       	jmp    c01060ce <check_swap+0x561>
         check_ptep[i]=0;
c0105fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fe5:	c7 04 85 34 21 1a c0 	movl   $0x0,-0x3fe5decc(,%eax,4)
c0105fec:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0105ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ff3:	40                   	inc    %eax
c0105ff4:	c1 e0 0c             	shl    $0xc,%eax
c0105ff7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ffe:	00 
c0105fff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106003:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106006:	89 04 24             	mov    %eax,(%esp)
c0106009:	e8 cd 1d 00 00       	call   c0107ddb <get_pte>
c010600e:	89 c2                	mov    %eax,%edx
c0106010:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106013:	89 14 85 34 21 1a c0 	mov    %edx,-0x3fe5decc(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010601a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010601d:	8b 04 85 34 21 1a c0 	mov    -0x3fe5decc(,%eax,4),%eax
c0106024:	85 c0                	test   %eax,%eax
c0106026:	75 24                	jne    c010604c <check_swap+0x4df>
c0106028:	c7 44 24 0c c4 d4 10 	movl   $0xc010d4c4,0xc(%esp)
c010602f:	c0 
c0106030:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0106037:	c0 
c0106038:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010603f:	00 
c0106040:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0106047:	e8 b4 a3 ff ff       	call   c0100400 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010604c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010604f:	8b 04 85 34 21 1a c0 	mov    -0x3fe5decc(,%eax,4),%eax
c0106056:	8b 00                	mov    (%eax),%eax
c0106058:	89 04 24             	mov    %eax,(%esp)
c010605b:	e8 8e f5 ff ff       	call   c01055ee <pte2page>
c0106060:	89 c2                	mov    %eax,%edx
c0106062:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106065:	8b 04 85 80 20 1a c0 	mov    -0x3fe5df80(,%eax,4),%eax
c010606c:	39 c2                	cmp    %eax,%edx
c010606e:	74 24                	je     c0106094 <check_swap+0x527>
c0106070:	c7 44 24 0c dc d4 10 	movl   $0xc010d4dc,0xc(%esp)
c0106077:	c0 
c0106078:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c010607f:	c0 
c0106080:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0106087:	00 
c0106088:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c010608f:	e8 6c a3 ff ff       	call   c0100400 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106094:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106097:	8b 04 85 34 21 1a c0 	mov    -0x3fe5decc(,%eax,4),%eax
c010609e:	8b 00                	mov    (%eax),%eax
c01060a0:	83 e0 01             	and    $0x1,%eax
c01060a3:	85 c0                	test   %eax,%eax
c01060a5:	75 24                	jne    c01060cb <check_swap+0x55e>
c01060a7:	c7 44 24 0c 04 d5 10 	movl   $0xc010d504,0xc(%esp)
c01060ae:	c0 
c01060af:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c01060b6:	c0 
c01060b7:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01060be:	00 
c01060bf:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c01060c6:	e8 35 a3 ff ff       	call   c0100400 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01060cb:	ff 45 ec             	incl   -0x14(%ebp)
c01060ce:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01060d2:	0f 8e 0a ff ff ff    	jle    c0105fe2 <check_swap+0x475>
     }
     cprintf("set up init env for check_swap over!\n");
c01060d8:	c7 04 24 20 d5 10 c0 	movl   $0xc010d520,(%esp)
c01060df:	e8 c5 a1 ff ff       	call   c01002a9 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01060e4:	e8 6c fa ff ff       	call   c0105b55 <check_content_access>
c01060e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c01060ec:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01060f0:	74 24                	je     c0106116 <check_swap+0x5a9>
c01060f2:	c7 44 24 0c 46 d5 10 	movl   $0xc010d546,0xc(%esp)
c01060f9:	c0 
c01060fa:	c7 44 24 08 2e d2 10 	movl   $0xc010d22e,0x8(%esp)
c0106101:	c0 
c0106102:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0106109:	00 
c010610a:	c7 04 24 c8 d1 10 c0 	movl   $0xc010d1c8,(%esp)
c0106111:	e8 ea a2 ff ff       	call   c0100400 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106116:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010611d:	eb 1d                	jmp    c010613c <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c010611f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106122:	8b 04 85 80 20 1a c0 	mov    -0x3fe5df80(,%eax,4),%eax
c0106129:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106130:	00 
c0106131:	89 04 24             	mov    %eax,(%esp)
c0106134:	e8 2d 16 00 00       	call   c0107766 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106139:	ff 45 ec             	incl   -0x14(%ebp)
c010613c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106140:	7e dd                	jle    c010611f <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0106142:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106145:	8b 00                	mov    (%eax),%eax
c0106147:	89 04 24             	mov    %eax,(%esp)
c010614a:	e8 dd f4 ff ff       	call   c010562c <pde2page>
c010614f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106156:	00 
c0106157:	89 04 24             	mov    %eax,(%esp)
c010615a:	e8 07 16 00 00       	call   c0107766 <free_pages>
     pgdir[0] = 0;
c010615f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106162:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0106168:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010616b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0106172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106175:	89 04 24             	mov    %eax,(%esp)
c0106178:	e8 5a d7 ff ff       	call   c01038d7 <mm_destroy>
     check_mm_struct = NULL;
c010617d:	c7 05 58 20 1a c0 00 	movl   $0x0,0xc01a2058
c0106184:	00 00 00 
     
     nr_free = nr_free_store;
c0106187:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010618a:	a3 4c 21 1a c0       	mov    %eax,0xc01a214c
     free_list = free_list_store;
c010618f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106192:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106195:	a3 44 21 1a c0       	mov    %eax,0xc01a2144
c010619a:	89 15 48 21 1a c0    	mov    %edx,0xc01a2148

     
     le = &free_list;
c01061a0:	c7 45 e8 44 21 1a c0 	movl   $0xc01a2144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01061a7:	eb 1c                	jmp    c01061c5 <check_swap+0x658>
         struct Page *p = le2page(le, page_link);
c01061a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01061ac:	83 e8 0c             	sub    $0xc,%eax
c01061af:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c01061b2:	ff 4d f4             	decl   -0xc(%ebp)
c01061b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01061b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01061bb:	8b 40 08             	mov    0x8(%eax),%eax
c01061be:	29 c2                	sub    %eax,%edx
c01061c0:	89 d0                	mov    %edx,%eax
c01061c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01061c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01061c8:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c01061cb:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01061ce:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01061d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01061d4:	81 7d e8 44 21 1a c0 	cmpl   $0xc01a2144,-0x18(%ebp)
c01061db:	75 cc                	jne    c01061a9 <check_swap+0x63c>
     }
     cprintf("count is %d, total is %d\n",count,total);
c01061dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061e0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01061e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061eb:	c7 04 24 4d d5 10 c0 	movl   $0xc010d54d,(%esp)
c01061f2:	e8 b2 a0 ff ff       	call   c01002a9 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01061f7:	c7 04 24 67 d5 10 c0 	movl   $0xc010d567,(%esp)
c01061fe:	e8 a6 a0 ff ff       	call   c01002a9 <cprintf>
}
c0106203:	90                   	nop
c0106204:	c9                   	leave  
c0106205:	c3                   	ret    

c0106206 <page2ppn>:
page2ppn(struct Page *page) {
c0106206:	55                   	push   %ebp
c0106207:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106209:	8b 45 08             	mov    0x8(%ebp),%eax
c010620c:	8b 15 58 21 1a c0    	mov    0xc01a2158,%edx
c0106212:	29 d0                	sub    %edx,%eax
c0106214:	c1 f8 05             	sar    $0x5,%eax
}
c0106217:	5d                   	pop    %ebp
c0106218:	c3                   	ret    

c0106219 <page2pa>:
page2pa(struct Page *page) {
c0106219:	55                   	push   %ebp
c010621a:	89 e5                	mov    %esp,%ebp
c010621c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010621f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106222:	89 04 24             	mov    %eax,(%esp)
c0106225:	e8 dc ff ff ff       	call   c0106206 <page2ppn>
c010622a:	c1 e0 0c             	shl    $0xc,%eax
}
c010622d:	c9                   	leave  
c010622e:	c3                   	ret    

c010622f <page_ref>:

static inline int
page_ref(struct Page *page) {
c010622f:	55                   	push   %ebp
c0106230:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106232:	8b 45 08             	mov    0x8(%ebp),%eax
c0106235:	8b 00                	mov    (%eax),%eax
}
c0106237:	5d                   	pop    %ebp
c0106238:	c3                   	ret    

c0106239 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106239:	55                   	push   %ebp
c010623a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010623c:	8b 45 08             	mov    0x8(%ebp),%eax
c010623f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106242:	89 10                	mov    %edx,(%eax)
}
c0106244:	90                   	nop
c0106245:	5d                   	pop    %ebp
c0106246:	c3                   	ret    

c0106247 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106247:	55                   	push   %ebp
c0106248:	89 e5                	mov    %esp,%ebp
c010624a:	83 ec 10             	sub    $0x10,%esp
c010624d:	c7 45 fc 44 21 1a c0 	movl   $0xc01a2144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106254:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106257:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010625a:	89 50 04             	mov    %edx,0x4(%eax)
c010625d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106260:	8b 50 04             	mov    0x4(%eax),%edx
c0106263:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106266:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106268:	c7 05 4c 21 1a c0 00 	movl   $0x0,0xc01a214c
c010626f:	00 00 00 
}
c0106272:	90                   	nop
c0106273:	c9                   	leave  
c0106274:	c3                   	ret    

c0106275 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0106275:	55                   	push   %ebp
c0106276:	89 e5                	mov    %esp,%ebp
c0106278:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010627b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010627f:	75 24                	jne    c01062a5 <default_init_memmap+0x30>
c0106281:	c7 44 24 0c 80 d5 10 	movl   $0xc010d580,0xc(%esp)
c0106288:	c0 
c0106289:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106290:	c0 
c0106291:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106298:	00 
c0106299:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01062a0:	e8 5b a1 ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c01062a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01062a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01062ab:	eb 7d                	jmp    c010632a <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01062ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062b0:	83 c0 04             	add    $0x4,%eax
c01062b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01062ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01062bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01062c3:	0f a3 10             	bt     %edx,(%eax)
c01062c6:	19 c0                	sbb    %eax,%eax
c01062c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01062cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01062cf:	0f 95 c0             	setne  %al
c01062d2:	0f b6 c0             	movzbl %al,%eax
c01062d5:	85 c0                	test   %eax,%eax
c01062d7:	75 24                	jne    c01062fd <default_init_memmap+0x88>
c01062d9:	c7 44 24 0c b1 d5 10 	movl   $0xc010d5b1,0xc(%esp)
c01062e0:	c0 
c01062e1:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01062e8:	c0 
c01062e9:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01062f0:	00 
c01062f1:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01062f8:	e8 03 a1 ff ff       	call   c0100400 <__panic>
        p->flags = p->property = 0;
c01062fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106300:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0106307:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010630a:	8b 50 08             	mov    0x8(%eax),%edx
c010630d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106310:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0106313:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010631a:	00 
c010631b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010631e:	89 04 24             	mov    %eax,(%esp)
c0106321:	e8 13 ff ff ff       	call   c0106239 <set_page_ref>
    for (; p != base + n; p ++) {
c0106326:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010632a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010632d:	c1 e0 05             	shl    $0x5,%eax
c0106330:	89 c2                	mov    %eax,%edx
c0106332:	8b 45 08             	mov    0x8(%ebp),%eax
c0106335:	01 d0                	add    %edx,%eax
c0106337:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010633a:	0f 85 6d ff ff ff    	jne    c01062ad <default_init_memmap+0x38>
    }
    base->property = n;
c0106340:	8b 45 08             	mov    0x8(%ebp),%eax
c0106343:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106346:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106349:	8b 45 08             	mov    0x8(%ebp),%eax
c010634c:	83 c0 04             	add    $0x4,%eax
c010634f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106356:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106359:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010635c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010635f:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0106362:	8b 15 4c 21 1a c0    	mov    0xc01a214c,%edx
c0106368:	8b 45 0c             	mov    0xc(%ebp),%eax
c010636b:	01 d0                	add    %edx,%eax
c010636d:	a3 4c 21 1a c0       	mov    %eax,0xc01a214c
    list_add_before(&free_list, &(base->page_link));
c0106372:	8b 45 08             	mov    0x8(%ebp),%eax
c0106375:	83 c0 0c             	add    $0xc,%eax
c0106378:	c7 45 e4 44 21 1a c0 	movl   $0xc01a2144,-0x1c(%ebp)
c010637f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0106382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106385:	8b 00                	mov    (%eax),%eax
c0106387:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010638a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010638d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0106390:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106393:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0106396:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106399:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010639c:	89 10                	mov    %edx,(%eax)
c010639e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01063a1:	8b 10                	mov    (%eax),%edx
c01063a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01063a6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01063a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01063ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01063af:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01063b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01063b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01063b8:	89 10                	mov    %edx,(%eax)
}
c01063ba:	90                   	nop
c01063bb:	c9                   	leave  
c01063bc:	c3                   	ret    

c01063bd <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01063bd:	55                   	push   %ebp
c01063be:	89 e5                	mov    %esp,%ebp
c01063c0:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01063c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01063c7:	75 24                	jne    c01063ed <default_alloc_pages+0x30>
c01063c9:	c7 44 24 0c 80 d5 10 	movl   $0xc010d580,0xc(%esp)
c01063d0:	c0 
c01063d1:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01063d8:	c0 
c01063d9:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01063e0:	00 
c01063e1:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01063e8:	e8 13 a0 ff ff       	call   c0100400 <__panic>
    if (n > nr_free) {
c01063ed:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c01063f2:	39 45 08             	cmp    %eax,0x8(%ebp)
c01063f5:	76 0a                	jbe    c0106401 <default_alloc_pages+0x44>
        return NULL;
c01063f7:	b8 00 00 00 00       	mov    $0x0,%eax
c01063fc:	e9 36 01 00 00       	jmp    c0106537 <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c0106401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0106408:	c7 45 f0 44 21 1a c0 	movl   $0xc01a2144,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010640f:	eb 1c                	jmp    c010642d <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0106411:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106414:	83 e8 0c             	sub    $0xc,%eax
c0106417:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010641a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010641d:	8b 40 08             	mov    0x8(%eax),%eax
c0106420:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106423:	77 08                	ja     c010642d <default_alloc_pages+0x70>
            page = p;
c0106425:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106428:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010642b:	eb 18                	jmp    c0106445 <default_alloc_pages+0x88>
c010642d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0106433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106436:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106439:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010643c:	81 7d f0 44 21 1a c0 	cmpl   $0xc01a2144,-0x10(%ebp)
c0106443:	75 cc                	jne    c0106411 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0106445:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106449:	0f 84 e5 00 00 00    	je     c0106534 <default_alloc_pages+0x177>
        if (page->property > n) {
c010644f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106452:	8b 40 08             	mov    0x8(%eax),%eax
c0106455:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106458:	0f 83 85 00 00 00    	jae    c01064e3 <default_alloc_pages+0x126>
            struct Page *p = page + n;
c010645e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106461:	c1 e0 05             	shl    $0x5,%eax
c0106464:	89 c2                	mov    %eax,%edx
c0106466:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106469:	01 d0                	add    %edx,%eax
c010646b:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c010646e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106471:	8b 40 08             	mov    0x8(%eax),%eax
c0106474:	2b 45 08             	sub    0x8(%ebp),%eax
c0106477:	89 c2                	mov    %eax,%edx
c0106479:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010647c:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c010647f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106482:	83 c0 04             	add    $0x4,%eax
c0106485:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c010648c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010648f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106492:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106495:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0106498:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010649b:	83 c0 0c             	add    $0xc,%eax
c010649e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01064a1:	83 c2 0c             	add    $0xc,%edx
c01064a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01064a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c01064aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01064ad:	8b 40 04             	mov    0x4(%eax),%eax
c01064b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01064b3:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01064b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01064b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01064bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c01064bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01064c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01064c5:	89 10                	mov    %edx,(%eax)
c01064c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01064ca:	8b 10                	mov    (%eax),%edx
c01064cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01064cf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01064d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01064d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01064d8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01064db:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01064de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01064e1:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01064e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064e6:	83 c0 0c             	add    $0xc,%eax
c01064e9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01064ec:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01064ef:	8b 40 04             	mov    0x4(%eax),%eax
c01064f2:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01064f5:	8b 12                	mov    (%edx),%edx
c01064f7:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01064fa:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next;
c01064fd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106500:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106503:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106506:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106509:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010650c:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c010650e:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0106513:	2b 45 08             	sub    0x8(%ebp),%eax
c0106516:	a3 4c 21 1a c0       	mov    %eax,0xc01a214c
        ClearPageProperty(page);
c010651b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010651e:	83 c0 04             	add    $0x4,%eax
c0106521:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106528:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010652b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010652e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106531:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0106534:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106537:	c9                   	leave  
c0106538:	c3                   	ret    

c0106539 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0106539:	55                   	push   %ebp
c010653a:	89 e5                	mov    %esp,%ebp
c010653c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0106542:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106546:	75 24                	jne    c010656c <default_free_pages+0x33>
c0106548:	c7 44 24 0c 80 d5 10 	movl   $0xc010d580,0xc(%esp)
c010654f:	c0 
c0106550:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106557:	c0 
c0106558:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c010655f:	00 
c0106560:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106567:	e8 94 9e ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c010656c:	8b 45 08             	mov    0x8(%ebp),%eax
c010656f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106572:	e9 9d 00 00 00       	jmp    c0106614 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0106577:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010657a:	83 c0 04             	add    $0x4,%eax
c010657d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106584:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106587:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010658a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010658d:	0f a3 10             	bt     %edx,(%eax)
c0106590:	19 c0                	sbb    %eax,%eax
c0106592:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0106595:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106599:	0f 95 c0             	setne  %al
c010659c:	0f b6 c0             	movzbl %al,%eax
c010659f:	85 c0                	test   %eax,%eax
c01065a1:	75 2c                	jne    c01065cf <default_free_pages+0x96>
c01065a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065a6:	83 c0 04             	add    $0x4,%eax
c01065a9:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01065b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01065b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01065b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01065b9:	0f a3 10             	bt     %edx,(%eax)
c01065bc:	19 c0                	sbb    %eax,%eax
c01065be:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01065c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01065c5:	0f 95 c0             	setne  %al
c01065c8:	0f b6 c0             	movzbl %al,%eax
c01065cb:	85 c0                	test   %eax,%eax
c01065cd:	74 24                	je     c01065f3 <default_free_pages+0xba>
c01065cf:	c7 44 24 0c c4 d5 10 	movl   $0xc010d5c4,0xc(%esp)
c01065d6:	c0 
c01065d7:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01065de:	c0 
c01065df:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01065e6:	00 
c01065e7:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01065ee:	e8 0d 9e ff ff       	call   c0100400 <__panic>
        p->flags = 0;
c01065f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065f6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01065fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106604:	00 
c0106605:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106608:	89 04 24             	mov    %eax,(%esp)
c010660b:	e8 29 fc ff ff       	call   c0106239 <set_page_ref>
    for (; p != base + n; p ++) {
c0106610:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106614:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106617:	c1 e0 05             	shl    $0x5,%eax
c010661a:	89 c2                	mov    %eax,%edx
c010661c:	8b 45 08             	mov    0x8(%ebp),%eax
c010661f:	01 d0                	add    %edx,%eax
c0106621:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106624:	0f 85 4d ff ff ff    	jne    c0106577 <default_free_pages+0x3e>
    }
    base->property = n;
c010662a:	8b 45 08             	mov    0x8(%ebp),%eax
c010662d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106630:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106633:	8b 45 08             	mov    0x8(%ebp),%eax
c0106636:	83 c0 04             	add    $0x4,%eax
c0106639:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106640:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106643:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106646:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106649:	0f ab 10             	bts    %edx,(%eax)
c010664c:	c7 45 d4 44 21 1a c0 	movl   $0xc01a2144,-0x2c(%ebp)
    return listelm->next;
c0106653:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106656:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0106659:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010665c:	e9 fa 00 00 00       	jmp    c010675b <default_free_pages+0x222>
        p = le2page(le, page_link);
c0106661:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106664:	83 e8 0c             	sub    $0xc,%eax
c0106667:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010666a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010666d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106670:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106673:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0106676:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0106679:	8b 45 08             	mov    0x8(%ebp),%eax
c010667c:	8b 40 08             	mov    0x8(%eax),%eax
c010667f:	c1 e0 05             	shl    $0x5,%eax
c0106682:	89 c2                	mov    %eax,%edx
c0106684:	8b 45 08             	mov    0x8(%ebp),%eax
c0106687:	01 d0                	add    %edx,%eax
c0106689:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010668c:	75 5a                	jne    c01066e8 <default_free_pages+0x1af>
            base->property += p->property;
c010668e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106691:	8b 50 08             	mov    0x8(%eax),%edx
c0106694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106697:	8b 40 08             	mov    0x8(%eax),%eax
c010669a:	01 c2                	add    %eax,%edx
c010669c:	8b 45 08             	mov    0x8(%ebp),%eax
c010669f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01066a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066a5:	83 c0 04             	add    $0x4,%eax
c01066a8:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01066af:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01066b2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01066b5:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01066b8:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01066bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066be:	83 c0 0c             	add    $0xc,%eax
c01066c1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01066c4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01066c7:	8b 40 04             	mov    0x4(%eax),%eax
c01066ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01066cd:	8b 12                	mov    (%edx),%edx
c01066cf:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01066d2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01066d5:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01066d8:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01066db:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01066de:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01066e1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01066e4:	89 10                	mov    %edx,(%eax)
c01066e6:	eb 73                	jmp    c010675b <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c01066e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066eb:	8b 40 08             	mov    0x8(%eax),%eax
c01066ee:	c1 e0 05             	shl    $0x5,%eax
c01066f1:	89 c2                	mov    %eax,%edx
c01066f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066f6:	01 d0                	add    %edx,%eax
c01066f8:	39 45 08             	cmp    %eax,0x8(%ebp)
c01066fb:	75 5e                	jne    c010675b <default_free_pages+0x222>
            p->property += base->property;
c01066fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106700:	8b 50 08             	mov    0x8(%eax),%edx
c0106703:	8b 45 08             	mov    0x8(%ebp),%eax
c0106706:	8b 40 08             	mov    0x8(%eax),%eax
c0106709:	01 c2                	add    %eax,%edx
c010670b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010670e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0106711:	8b 45 08             	mov    0x8(%ebp),%eax
c0106714:	83 c0 04             	add    $0x4,%eax
c0106717:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c010671e:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0106721:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106724:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106727:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010672a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010672d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0106730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106733:	83 c0 0c             	add    $0xc,%eax
c0106736:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106739:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010673c:	8b 40 04             	mov    0x4(%eax),%eax
c010673f:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0106742:	8b 12                	mov    (%edx),%edx
c0106744:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0106747:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010674a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010674d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106750:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106753:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106756:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0106759:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c010675b:	81 7d f0 44 21 1a c0 	cmpl   $0xc01a2144,-0x10(%ebp)
c0106762:	0f 85 f9 fe ff ff    	jne    c0106661 <default_free_pages+0x128>
        }
    }
    nr_free += n;
c0106768:	8b 15 4c 21 1a c0    	mov    0xc01a214c,%edx
c010676e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106771:	01 d0                	add    %edx,%eax
c0106773:	a3 4c 21 1a c0       	mov    %eax,0xc01a214c
c0106778:	c7 45 9c 44 21 1a c0 	movl   $0xc01a2144,-0x64(%ebp)
    return listelm->next;
c010677f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106782:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0106785:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0106788:	eb 66                	jmp    c01067f0 <default_free_pages+0x2b7>
        p = le2page(le, page_link);
c010678a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010678d:	83 e8 0c             	sub    $0xc,%eax
c0106790:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0106793:	8b 45 08             	mov    0x8(%ebp),%eax
c0106796:	8b 40 08             	mov    0x8(%eax),%eax
c0106799:	c1 e0 05             	shl    $0x5,%eax
c010679c:	89 c2                	mov    %eax,%edx
c010679e:	8b 45 08             	mov    0x8(%ebp),%eax
c01067a1:	01 d0                	add    %edx,%eax
c01067a3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01067a6:	72 39                	jb     c01067e1 <default_free_pages+0x2a8>
            assert(base + base->property != p);
c01067a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ab:	8b 40 08             	mov    0x8(%eax),%eax
c01067ae:	c1 e0 05             	shl    $0x5,%eax
c01067b1:	89 c2                	mov    %eax,%edx
c01067b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01067b6:	01 d0                	add    %edx,%eax
c01067b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01067bb:	75 3e                	jne    c01067fb <default_free_pages+0x2c2>
c01067bd:	c7 44 24 0c e9 d5 10 	movl   $0xc010d5e9,0xc(%esp)
c01067c4:	c0 
c01067c5:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01067cc:	c0 
c01067cd:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c01067d4:	00 
c01067d5:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01067dc:	e8 1f 9c ff ff       	call   c0100400 <__panic>
c01067e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01067e4:	89 45 98             	mov    %eax,-0x68(%ebp)
c01067e7:	8b 45 98             	mov    -0x68(%ebp),%eax
c01067ea:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01067ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01067f0:	81 7d f0 44 21 1a c0 	cmpl   $0xc01a2144,-0x10(%ebp)
c01067f7:	75 91                	jne    c010678a <default_free_pages+0x251>
c01067f9:	eb 01                	jmp    c01067fc <default_free_pages+0x2c3>
            break;
c01067fb:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c01067fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ff:	8d 50 0c             	lea    0xc(%eax),%edx
c0106802:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106805:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106808:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010680b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010680e:	8b 00                	mov    (%eax),%eax
c0106810:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106813:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0106816:	89 45 88             	mov    %eax,-0x78(%ebp)
c0106819:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010681c:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c010681f:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106822:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0106825:	89 10                	mov    %edx,(%eax)
c0106827:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010682a:	8b 10                	mov    (%eax),%edx
c010682c:	8b 45 88             	mov    -0x78(%ebp),%eax
c010682f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106832:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106835:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106838:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010683b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010683e:	8b 55 88             	mov    -0x78(%ebp),%edx
c0106841:	89 10                	mov    %edx,(%eax)
}
c0106843:	90                   	nop
c0106844:	c9                   	leave  
c0106845:	c3                   	ret    

c0106846 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0106846:	55                   	push   %ebp
c0106847:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0106849:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
}
c010684e:	5d                   	pop    %ebp
c010684f:	c3                   	ret    

c0106850 <basic_check>:

static void
basic_check(void) {
c0106850:	55                   	push   %ebp
c0106851:	89 e5                	mov    %esp,%ebp
c0106853:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0106856:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010685d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106860:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106863:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106866:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0106869:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106870:	e8 86 0e 00 00       	call   c01076fb <alloc_pages>
c0106875:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106878:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010687c:	75 24                	jne    c01068a2 <basic_check+0x52>
c010687e:	c7 44 24 0c 04 d6 10 	movl   $0xc010d604,0xc(%esp)
c0106885:	c0 
c0106886:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c010688d:	c0 
c010688e:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0106895:	00 
c0106896:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c010689d:	e8 5e 9b ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01068a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01068a9:	e8 4d 0e 00 00       	call   c01076fb <alloc_pages>
c01068ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01068b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01068b5:	75 24                	jne    c01068db <basic_check+0x8b>
c01068b7:	c7 44 24 0c 20 d6 10 	movl   $0xc010d620,0xc(%esp)
c01068be:	c0 
c01068bf:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01068c6:	c0 
c01068c7:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01068ce:	00 
c01068cf:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01068d6:	e8 25 9b ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01068db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01068e2:	e8 14 0e 00 00       	call   c01076fb <alloc_pages>
c01068e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01068ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01068ee:	75 24                	jne    c0106914 <basic_check+0xc4>
c01068f0:	c7 44 24 0c 3c d6 10 	movl   $0xc010d63c,0xc(%esp)
c01068f7:	c0 
c01068f8:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01068ff:	c0 
c0106900:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0106907:	00 
c0106908:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c010690f:	e8 ec 9a ff ff       	call   c0100400 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0106914:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106917:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010691a:	74 10                	je     c010692c <basic_check+0xdc>
c010691c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010691f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106922:	74 08                	je     c010692c <basic_check+0xdc>
c0106924:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106927:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010692a:	75 24                	jne    c0106950 <basic_check+0x100>
c010692c:	c7 44 24 0c 58 d6 10 	movl   $0xc010d658,0xc(%esp)
c0106933:	c0 
c0106934:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c010693b:	c0 
c010693c:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0106943:	00 
c0106944:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c010694b:	e8 b0 9a ff ff       	call   c0100400 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0106950:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106953:	89 04 24             	mov    %eax,(%esp)
c0106956:	e8 d4 f8 ff ff       	call   c010622f <page_ref>
c010695b:	85 c0                	test   %eax,%eax
c010695d:	75 1e                	jne    c010697d <basic_check+0x12d>
c010695f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106962:	89 04 24             	mov    %eax,(%esp)
c0106965:	e8 c5 f8 ff ff       	call   c010622f <page_ref>
c010696a:	85 c0                	test   %eax,%eax
c010696c:	75 0f                	jne    c010697d <basic_check+0x12d>
c010696e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106971:	89 04 24             	mov    %eax,(%esp)
c0106974:	e8 b6 f8 ff ff       	call   c010622f <page_ref>
c0106979:	85 c0                	test   %eax,%eax
c010697b:	74 24                	je     c01069a1 <basic_check+0x151>
c010697d:	c7 44 24 0c 7c d6 10 	movl   $0xc010d67c,0xc(%esp)
c0106984:	c0 
c0106985:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c010698c:	c0 
c010698d:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0106994:	00 
c0106995:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c010699c:	e8 5f 9a ff ff       	call   c0100400 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01069a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069a4:	89 04 24             	mov    %eax,(%esp)
c01069a7:	e8 6d f8 ff ff       	call   c0106219 <page2pa>
c01069ac:	8b 15 80 ff 19 c0    	mov    0xc019ff80,%edx
c01069b2:	c1 e2 0c             	shl    $0xc,%edx
c01069b5:	39 d0                	cmp    %edx,%eax
c01069b7:	72 24                	jb     c01069dd <basic_check+0x18d>
c01069b9:	c7 44 24 0c b8 d6 10 	movl   $0xc010d6b8,0xc(%esp)
c01069c0:	c0 
c01069c1:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01069c8:	c0 
c01069c9:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01069d0:	00 
c01069d1:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01069d8:	e8 23 9a ff ff       	call   c0100400 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01069dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069e0:	89 04 24             	mov    %eax,(%esp)
c01069e3:	e8 31 f8 ff ff       	call   c0106219 <page2pa>
c01069e8:	8b 15 80 ff 19 c0    	mov    0xc019ff80,%edx
c01069ee:	c1 e2 0c             	shl    $0xc,%edx
c01069f1:	39 d0                	cmp    %edx,%eax
c01069f3:	72 24                	jb     c0106a19 <basic_check+0x1c9>
c01069f5:	c7 44 24 0c d5 d6 10 	movl   $0xc010d6d5,0xc(%esp)
c01069fc:	c0 
c01069fd:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106a04:	c0 
c0106a05:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0106a0c:	00 
c0106a0d:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106a14:	e8 e7 99 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0106a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a1c:	89 04 24             	mov    %eax,(%esp)
c0106a1f:	e8 f5 f7 ff ff       	call   c0106219 <page2pa>
c0106a24:	8b 15 80 ff 19 c0    	mov    0xc019ff80,%edx
c0106a2a:	c1 e2 0c             	shl    $0xc,%edx
c0106a2d:	39 d0                	cmp    %edx,%eax
c0106a2f:	72 24                	jb     c0106a55 <basic_check+0x205>
c0106a31:	c7 44 24 0c f2 d6 10 	movl   $0xc010d6f2,0xc(%esp)
c0106a38:	c0 
c0106a39:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106a40:	c0 
c0106a41:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0106a48:	00 
c0106a49:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106a50:	e8 ab 99 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0106a55:	a1 44 21 1a c0       	mov    0xc01a2144,%eax
c0106a5a:	8b 15 48 21 1a c0    	mov    0xc01a2148,%edx
c0106a60:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106a63:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106a66:	c7 45 dc 44 21 1a c0 	movl   $0xc01a2144,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0106a6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a70:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106a73:	89 50 04             	mov    %edx,0x4(%eax)
c0106a76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a79:	8b 50 04             	mov    0x4(%eax),%edx
c0106a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a7f:	89 10                	mov    %edx,(%eax)
c0106a81:	c7 45 e0 44 21 1a c0 	movl   $0xc01a2144,-0x20(%ebp)
    return list->next == list;
c0106a88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a8b:	8b 40 04             	mov    0x4(%eax),%eax
c0106a8e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0106a91:	0f 94 c0             	sete   %al
c0106a94:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106a97:	85 c0                	test   %eax,%eax
c0106a99:	75 24                	jne    c0106abf <basic_check+0x26f>
c0106a9b:	c7 44 24 0c 0f d7 10 	movl   $0xc010d70f,0xc(%esp)
c0106aa2:	c0 
c0106aa3:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106aaa:	c0 
c0106aab:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0106ab2:	00 
c0106ab3:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106aba:	e8 41 99 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0106abf:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0106ac4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0106ac7:	c7 05 4c 21 1a c0 00 	movl   $0x0,0xc01a214c
c0106ace:	00 00 00 

    assert(alloc_page() == NULL);
c0106ad1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106ad8:	e8 1e 0c 00 00       	call   c01076fb <alloc_pages>
c0106add:	85 c0                	test   %eax,%eax
c0106adf:	74 24                	je     c0106b05 <basic_check+0x2b5>
c0106ae1:	c7 44 24 0c 26 d7 10 	movl   $0xc010d726,0xc(%esp)
c0106ae8:	c0 
c0106ae9:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106af0:	c0 
c0106af1:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106af8:	00 
c0106af9:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106b00:	e8 fb 98 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0106b05:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b0c:	00 
c0106b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b10:	89 04 24             	mov    %eax,(%esp)
c0106b13:	e8 4e 0c 00 00       	call   c0107766 <free_pages>
    free_page(p1);
c0106b18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b1f:	00 
c0106b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b23:	89 04 24             	mov    %eax,(%esp)
c0106b26:	e8 3b 0c 00 00       	call   c0107766 <free_pages>
    free_page(p2);
c0106b2b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b32:	00 
c0106b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b36:	89 04 24             	mov    %eax,(%esp)
c0106b39:	e8 28 0c 00 00       	call   c0107766 <free_pages>
    assert(nr_free == 3);
c0106b3e:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0106b43:	83 f8 03             	cmp    $0x3,%eax
c0106b46:	74 24                	je     c0106b6c <basic_check+0x31c>
c0106b48:	c7 44 24 0c 3b d7 10 	movl   $0xc010d73b,0xc(%esp)
c0106b4f:	c0 
c0106b50:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106b57:	c0 
c0106b58:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0106b5f:	00 
c0106b60:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106b67:	e8 94 98 ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0106b6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b73:	e8 83 0b 00 00       	call   c01076fb <alloc_pages>
c0106b78:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106b7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106b7f:	75 24                	jne    c0106ba5 <basic_check+0x355>
c0106b81:	c7 44 24 0c 04 d6 10 	movl   $0xc010d604,0xc(%esp)
c0106b88:	c0 
c0106b89:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106b90:	c0 
c0106b91:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0106b98:	00 
c0106b99:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106ba0:	e8 5b 98 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106ba5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106bac:	e8 4a 0b 00 00       	call   c01076fb <alloc_pages>
c0106bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106bb8:	75 24                	jne    c0106bde <basic_check+0x38e>
c0106bba:	c7 44 24 0c 20 d6 10 	movl   $0xc010d620,0xc(%esp)
c0106bc1:	c0 
c0106bc2:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106bc9:	c0 
c0106bca:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0106bd1:	00 
c0106bd2:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106bd9:	e8 22 98 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106bde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106be5:	e8 11 0b 00 00       	call   c01076fb <alloc_pages>
c0106bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106bed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bf1:	75 24                	jne    c0106c17 <basic_check+0x3c7>
c0106bf3:	c7 44 24 0c 3c d6 10 	movl   $0xc010d63c,0xc(%esp)
c0106bfa:	c0 
c0106bfb:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106c02:	c0 
c0106c03:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0106c0a:	00 
c0106c0b:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106c12:	e8 e9 97 ff ff       	call   c0100400 <__panic>

    assert(alloc_page() == NULL);
c0106c17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106c1e:	e8 d8 0a 00 00       	call   c01076fb <alloc_pages>
c0106c23:	85 c0                	test   %eax,%eax
c0106c25:	74 24                	je     c0106c4b <basic_check+0x3fb>
c0106c27:	c7 44 24 0c 26 d7 10 	movl   $0xc010d726,0xc(%esp)
c0106c2e:	c0 
c0106c2f:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106c36:	c0 
c0106c37:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0106c3e:	00 
c0106c3f:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106c46:	e8 b5 97 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0106c4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c52:	00 
c0106c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c56:	89 04 24             	mov    %eax,(%esp)
c0106c59:	e8 08 0b 00 00       	call   c0107766 <free_pages>
c0106c5e:	c7 45 d8 44 21 1a c0 	movl   $0xc01a2144,-0x28(%ebp)
c0106c65:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106c68:	8b 40 04             	mov    0x4(%eax),%eax
c0106c6b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0106c6e:	0f 94 c0             	sete   %al
c0106c71:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0106c74:	85 c0                	test   %eax,%eax
c0106c76:	74 24                	je     c0106c9c <basic_check+0x44c>
c0106c78:	c7 44 24 0c 48 d7 10 	movl   $0xc010d748,0xc(%esp)
c0106c7f:	c0 
c0106c80:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106c87:	c0 
c0106c88:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0106c8f:	00 
c0106c90:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106c97:	e8 64 97 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0106c9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106ca3:	e8 53 0a 00 00       	call   c01076fb <alloc_pages>
c0106ca8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106cae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106cb1:	74 24                	je     c0106cd7 <basic_check+0x487>
c0106cb3:	c7 44 24 0c 60 d7 10 	movl   $0xc010d760,0xc(%esp)
c0106cba:	c0 
c0106cbb:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106cc2:	c0 
c0106cc3:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0106cca:	00 
c0106ccb:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106cd2:	e8 29 97 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106cd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106cde:	e8 18 0a 00 00       	call   c01076fb <alloc_pages>
c0106ce3:	85 c0                	test   %eax,%eax
c0106ce5:	74 24                	je     c0106d0b <basic_check+0x4bb>
c0106ce7:	c7 44 24 0c 26 d7 10 	movl   $0xc010d726,0xc(%esp)
c0106cee:	c0 
c0106cef:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106cf6:	c0 
c0106cf7:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0106cfe:	00 
c0106cff:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106d06:	e8 f5 96 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c0106d0b:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0106d10:	85 c0                	test   %eax,%eax
c0106d12:	74 24                	je     c0106d38 <basic_check+0x4e8>
c0106d14:	c7 44 24 0c 79 d7 10 	movl   $0xc010d779,0xc(%esp)
c0106d1b:	c0 
c0106d1c:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106d23:	c0 
c0106d24:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0106d2b:	00 
c0106d2c:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106d33:	e8 c8 96 ff ff       	call   c0100400 <__panic>
    free_list = free_list_store;
c0106d38:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106d3e:	a3 44 21 1a c0       	mov    %eax,0xc01a2144
c0106d43:	89 15 48 21 1a c0    	mov    %edx,0xc01a2148
    nr_free = nr_free_store;
c0106d49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d4c:	a3 4c 21 1a c0       	mov    %eax,0xc01a214c

    free_page(p);
c0106d51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106d58:	00 
c0106d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d5c:	89 04 24             	mov    %eax,(%esp)
c0106d5f:	e8 02 0a 00 00       	call   c0107766 <free_pages>
    free_page(p1);
c0106d64:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106d6b:	00 
c0106d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d6f:	89 04 24             	mov    %eax,(%esp)
c0106d72:	e8 ef 09 00 00       	call   c0107766 <free_pages>
    free_page(p2);
c0106d77:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106d7e:	00 
c0106d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d82:	89 04 24             	mov    %eax,(%esp)
c0106d85:	e8 dc 09 00 00       	call   c0107766 <free_pages>
}
c0106d8a:	90                   	nop
c0106d8b:	c9                   	leave  
c0106d8c:	c3                   	ret    

c0106d8d <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0106d8d:	55                   	push   %ebp
c0106d8e:	89 e5                	mov    %esp,%ebp
c0106d90:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0106d96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106d9d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0106da4:	c7 45 ec 44 21 1a c0 	movl   $0xc01a2144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106dab:	eb 6a                	jmp    c0106e17 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0106dad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106db0:	83 e8 0c             	sub    $0xc,%eax
c0106db3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0106db6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106db9:	83 c0 04             	add    $0x4,%eax
c0106dbc:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106dc3:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106dc6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106dc9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106dcc:	0f a3 10             	bt     %edx,(%eax)
c0106dcf:	19 c0                	sbb    %eax,%eax
c0106dd1:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0106dd4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0106dd8:	0f 95 c0             	setne  %al
c0106ddb:	0f b6 c0             	movzbl %al,%eax
c0106dde:	85 c0                	test   %eax,%eax
c0106de0:	75 24                	jne    c0106e06 <default_check+0x79>
c0106de2:	c7 44 24 0c 86 d7 10 	movl   $0xc010d786,0xc(%esp)
c0106de9:	c0 
c0106dea:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106df1:	c0 
c0106df2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106df9:	00 
c0106dfa:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106e01:	e8 fa 95 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c0106e06:	ff 45 f4             	incl   -0xc(%ebp)
c0106e09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e0c:	8b 50 08             	mov    0x8(%eax),%edx
c0106e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e12:	01 d0                	add    %edx,%eax
c0106e14:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e1a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0106e1d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106e20:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106e23:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e26:	81 7d ec 44 21 1a c0 	cmpl   $0xc01a2144,-0x14(%ebp)
c0106e2d:	0f 85 7a ff ff ff    	jne    c0106dad <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0106e33:	e8 61 09 00 00       	call   c0107799 <nr_free_pages>
c0106e38:	89 c2                	mov    %eax,%edx
c0106e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e3d:	39 c2                	cmp    %eax,%edx
c0106e3f:	74 24                	je     c0106e65 <default_check+0xd8>
c0106e41:	c7 44 24 0c 96 d7 10 	movl   $0xc010d796,0xc(%esp)
c0106e48:	c0 
c0106e49:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106e50:	c0 
c0106e51:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0106e58:	00 
c0106e59:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106e60:	e8 9b 95 ff ff       	call   c0100400 <__panic>

    basic_check();
c0106e65:	e8 e6 f9 ff ff       	call   c0106850 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106e6a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106e71:	e8 85 08 00 00       	call   c01076fb <alloc_pages>
c0106e76:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0106e79:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106e7d:	75 24                	jne    c0106ea3 <default_check+0x116>
c0106e7f:	c7 44 24 0c af d7 10 	movl   $0xc010d7af,0xc(%esp)
c0106e86:	c0 
c0106e87:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106e8e:	c0 
c0106e8f:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0106e96:	00 
c0106e97:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106e9e:	e8 5d 95 ff ff       	call   c0100400 <__panic>
    assert(!PageProperty(p0));
c0106ea3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ea6:	83 c0 04             	add    $0x4,%eax
c0106ea9:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0106eb0:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106eb3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106eb6:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106eb9:	0f a3 10             	bt     %edx,(%eax)
c0106ebc:	19 c0                	sbb    %eax,%eax
c0106ebe:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0106ec1:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0106ec5:	0f 95 c0             	setne  %al
c0106ec8:	0f b6 c0             	movzbl %al,%eax
c0106ecb:	85 c0                	test   %eax,%eax
c0106ecd:	74 24                	je     c0106ef3 <default_check+0x166>
c0106ecf:	c7 44 24 0c ba d7 10 	movl   $0xc010d7ba,0xc(%esp)
c0106ed6:	c0 
c0106ed7:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106ede:	c0 
c0106edf:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0106ee6:	00 
c0106ee7:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106eee:	e8 0d 95 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0106ef3:	a1 44 21 1a c0       	mov    0xc01a2144,%eax
c0106ef8:	8b 15 48 21 1a c0    	mov    0xc01a2148,%edx
c0106efe:	89 45 80             	mov    %eax,-0x80(%ebp)
c0106f01:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0106f04:	c7 45 b0 44 21 1a c0 	movl   $0xc01a2144,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0106f0b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106f0e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0106f11:	89 50 04             	mov    %edx,0x4(%eax)
c0106f14:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106f17:	8b 50 04             	mov    0x4(%eax),%edx
c0106f1a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106f1d:	89 10                	mov    %edx,(%eax)
c0106f1f:	c7 45 b4 44 21 1a c0 	movl   $0xc01a2144,-0x4c(%ebp)
    return list->next == list;
c0106f26:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106f29:	8b 40 04             	mov    0x4(%eax),%eax
c0106f2c:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0106f2f:	0f 94 c0             	sete   %al
c0106f32:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106f35:	85 c0                	test   %eax,%eax
c0106f37:	75 24                	jne    c0106f5d <default_check+0x1d0>
c0106f39:	c7 44 24 0c 0f d7 10 	movl   $0xc010d70f,0xc(%esp)
c0106f40:	c0 
c0106f41:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106f48:	c0 
c0106f49:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0106f50:	00 
c0106f51:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106f58:	e8 a3 94 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106f5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f64:	e8 92 07 00 00       	call   c01076fb <alloc_pages>
c0106f69:	85 c0                	test   %eax,%eax
c0106f6b:	74 24                	je     c0106f91 <default_check+0x204>
c0106f6d:	c7 44 24 0c 26 d7 10 	movl   $0xc010d726,0xc(%esp)
c0106f74:	c0 
c0106f75:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106f7c:	c0 
c0106f7d:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0106f84:	00 
c0106f85:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106f8c:	e8 6f 94 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0106f91:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c0106f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0106f99:	c7 05 4c 21 1a c0 00 	movl   $0x0,0xc01a214c
c0106fa0:	00 00 00 

    free_pages(p0 + 2, 3);
c0106fa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106fa6:	83 c0 40             	add    $0x40,%eax
c0106fa9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106fb0:	00 
c0106fb1:	89 04 24             	mov    %eax,(%esp)
c0106fb4:	e8 ad 07 00 00       	call   c0107766 <free_pages>
    assert(alloc_pages(4) == NULL);
c0106fb9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0106fc0:	e8 36 07 00 00       	call   c01076fb <alloc_pages>
c0106fc5:	85 c0                	test   %eax,%eax
c0106fc7:	74 24                	je     c0106fed <default_check+0x260>
c0106fc9:	c7 44 24 0c cc d7 10 	movl   $0xc010d7cc,0xc(%esp)
c0106fd0:	c0 
c0106fd1:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0106fd8:	c0 
c0106fd9:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0106fe0:	00 
c0106fe1:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0106fe8:	e8 13 94 ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0106fed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ff0:	83 c0 40             	add    $0x40,%eax
c0106ff3:	83 c0 04             	add    $0x4,%eax
c0106ff6:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0106ffd:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107000:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107003:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0107006:	0f a3 10             	bt     %edx,(%eax)
c0107009:	19 c0                	sbb    %eax,%eax
c010700b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010700e:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0107012:	0f 95 c0             	setne  %al
c0107015:	0f b6 c0             	movzbl %al,%eax
c0107018:	85 c0                	test   %eax,%eax
c010701a:	74 0e                	je     c010702a <default_check+0x29d>
c010701c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010701f:	83 c0 40             	add    $0x40,%eax
c0107022:	8b 40 08             	mov    0x8(%eax),%eax
c0107025:	83 f8 03             	cmp    $0x3,%eax
c0107028:	74 24                	je     c010704e <default_check+0x2c1>
c010702a:	c7 44 24 0c e4 d7 10 	movl   $0xc010d7e4,0xc(%esp)
c0107031:	c0 
c0107032:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0107039:	c0 
c010703a:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0107041:	00 
c0107042:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0107049:	e8 b2 93 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010704e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0107055:	e8 a1 06 00 00       	call   c01076fb <alloc_pages>
c010705a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010705d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107061:	75 24                	jne    c0107087 <default_check+0x2fa>
c0107063:	c7 44 24 0c 10 d8 10 	movl   $0xc010d810,0xc(%esp)
c010706a:	c0 
c010706b:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0107072:	c0 
c0107073:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010707a:	00 
c010707b:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0107082:	e8 79 93 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0107087:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010708e:	e8 68 06 00 00       	call   c01076fb <alloc_pages>
c0107093:	85 c0                	test   %eax,%eax
c0107095:	74 24                	je     c01070bb <default_check+0x32e>
c0107097:	c7 44 24 0c 26 d7 10 	movl   $0xc010d726,0xc(%esp)
c010709e:	c0 
c010709f:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01070a6:	c0 
c01070a7:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01070ae:	00 
c01070af:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01070b6:	e8 45 93 ff ff       	call   c0100400 <__panic>
    assert(p0 + 2 == p1);
c01070bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070be:	83 c0 40             	add    $0x40,%eax
c01070c1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01070c4:	74 24                	je     c01070ea <default_check+0x35d>
c01070c6:	c7 44 24 0c 2e d8 10 	movl   $0xc010d82e,0xc(%esp)
c01070cd:	c0 
c01070ce:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01070d5:	c0 
c01070d6:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c01070dd:	00 
c01070de:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01070e5:	e8 16 93 ff ff       	call   c0100400 <__panic>

    p2 = p0 + 1;
c01070ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070ed:	83 c0 20             	add    $0x20,%eax
c01070f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01070f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01070fa:	00 
c01070fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070fe:	89 04 24             	mov    %eax,(%esp)
c0107101:	e8 60 06 00 00       	call   c0107766 <free_pages>
    free_pages(p1, 3);
c0107106:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010710d:	00 
c010710e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107111:	89 04 24             	mov    %eax,(%esp)
c0107114:	e8 4d 06 00 00       	call   c0107766 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0107119:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010711c:	83 c0 04             	add    $0x4,%eax
c010711f:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0107126:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107129:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010712c:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010712f:	0f a3 10             	bt     %edx,(%eax)
c0107132:	19 c0                	sbb    %eax,%eax
c0107134:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0107137:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010713b:	0f 95 c0             	setne  %al
c010713e:	0f b6 c0             	movzbl %al,%eax
c0107141:	85 c0                	test   %eax,%eax
c0107143:	74 0b                	je     c0107150 <default_check+0x3c3>
c0107145:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107148:	8b 40 08             	mov    0x8(%eax),%eax
c010714b:	83 f8 01             	cmp    $0x1,%eax
c010714e:	74 24                	je     c0107174 <default_check+0x3e7>
c0107150:	c7 44 24 0c 3c d8 10 	movl   $0xc010d83c,0xc(%esp)
c0107157:	c0 
c0107158:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c010715f:	c0 
c0107160:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0107167:	00 
c0107168:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c010716f:	e8 8c 92 ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0107174:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107177:	83 c0 04             	add    $0x4,%eax
c010717a:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0107181:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107184:	8b 45 90             	mov    -0x70(%ebp),%eax
c0107187:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010718a:	0f a3 10             	bt     %edx,(%eax)
c010718d:	19 c0                	sbb    %eax,%eax
c010718f:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0107192:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0107196:	0f 95 c0             	setne  %al
c0107199:	0f b6 c0             	movzbl %al,%eax
c010719c:	85 c0                	test   %eax,%eax
c010719e:	74 0b                	je     c01071ab <default_check+0x41e>
c01071a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071a3:	8b 40 08             	mov    0x8(%eax),%eax
c01071a6:	83 f8 03             	cmp    $0x3,%eax
c01071a9:	74 24                	je     c01071cf <default_check+0x442>
c01071ab:	c7 44 24 0c 64 d8 10 	movl   $0xc010d864,0xc(%esp)
c01071b2:	c0 
c01071b3:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01071ba:	c0 
c01071bb:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01071c2:	00 
c01071c3:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01071ca:	e8 31 92 ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01071cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01071d6:	e8 20 05 00 00       	call   c01076fb <alloc_pages>
c01071db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01071de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01071e1:	83 e8 20             	sub    $0x20,%eax
c01071e4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01071e7:	74 24                	je     c010720d <default_check+0x480>
c01071e9:	c7 44 24 0c 8a d8 10 	movl   $0xc010d88a,0xc(%esp)
c01071f0:	c0 
c01071f1:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01071f8:	c0 
c01071f9:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0107200:	00 
c0107201:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0107208:	e8 f3 91 ff ff       	call   c0100400 <__panic>
    free_page(p0);
c010720d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107214:	00 
c0107215:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107218:	89 04 24             	mov    %eax,(%esp)
c010721b:	e8 46 05 00 00       	call   c0107766 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107220:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0107227:	e8 cf 04 00 00       	call   c01076fb <alloc_pages>
c010722c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010722f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107232:	83 c0 20             	add    $0x20,%eax
c0107235:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107238:	74 24                	je     c010725e <default_check+0x4d1>
c010723a:	c7 44 24 0c a8 d8 10 	movl   $0xc010d8a8,0xc(%esp)
c0107241:	c0 
c0107242:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0107249:	c0 
c010724a:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0107251:	00 
c0107252:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0107259:	e8 a2 91 ff ff       	call   c0100400 <__panic>

    free_pages(p0, 2);
c010725e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0107265:	00 
c0107266:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107269:	89 04 24             	mov    %eax,(%esp)
c010726c:	e8 f5 04 00 00       	call   c0107766 <free_pages>
    free_page(p2);
c0107271:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107278:	00 
c0107279:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010727c:	89 04 24             	mov    %eax,(%esp)
c010727f:	e8 e2 04 00 00       	call   c0107766 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0107284:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010728b:	e8 6b 04 00 00       	call   c01076fb <alloc_pages>
c0107290:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107293:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107297:	75 24                	jne    c01072bd <default_check+0x530>
c0107299:	c7 44 24 0c c8 d8 10 	movl   $0xc010d8c8,0xc(%esp)
c01072a0:	c0 
c01072a1:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01072a8:	c0 
c01072a9:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c01072b0:	00 
c01072b1:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01072b8:	e8 43 91 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c01072bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01072c4:	e8 32 04 00 00       	call   c01076fb <alloc_pages>
c01072c9:	85 c0                	test   %eax,%eax
c01072cb:	74 24                	je     c01072f1 <default_check+0x564>
c01072cd:	c7 44 24 0c 26 d7 10 	movl   $0xc010d726,0xc(%esp)
c01072d4:	c0 
c01072d5:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01072dc:	c0 
c01072dd:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01072e4:	00 
c01072e5:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01072ec:	e8 0f 91 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c01072f1:	a1 4c 21 1a c0       	mov    0xc01a214c,%eax
c01072f6:	85 c0                	test   %eax,%eax
c01072f8:	74 24                	je     c010731e <default_check+0x591>
c01072fa:	c7 44 24 0c 79 d7 10 	movl   $0xc010d779,0xc(%esp)
c0107301:	c0 
c0107302:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c0107309:	c0 
c010730a:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0107311:	00 
c0107312:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c0107319:	e8 e2 90 ff ff       	call   c0100400 <__panic>
    nr_free = nr_free_store;
c010731e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107321:	a3 4c 21 1a c0       	mov    %eax,0xc01a214c

    free_list = free_list_store;
c0107326:	8b 45 80             	mov    -0x80(%ebp),%eax
c0107329:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010732c:	a3 44 21 1a c0       	mov    %eax,0xc01a2144
c0107331:	89 15 48 21 1a c0    	mov    %edx,0xc01a2148
    free_pages(p0, 5);
c0107337:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010733e:	00 
c010733f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107342:	89 04 24             	mov    %eax,(%esp)
c0107345:	e8 1c 04 00 00       	call   c0107766 <free_pages>

    le = &free_list;
c010734a:	c7 45 ec 44 21 1a c0 	movl   $0xc01a2144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107351:	eb 1c                	jmp    c010736f <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c0107353:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107356:	83 e8 0c             	sub    $0xc,%eax
c0107359:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c010735c:	ff 4d f4             	decl   -0xc(%ebp)
c010735f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107362:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107365:	8b 40 08             	mov    0x8(%eax),%eax
c0107368:	29 c2                	sub    %eax,%edx
c010736a:	89 d0                	mov    %edx,%eax
c010736c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010736f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107372:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0107375:	8b 45 88             	mov    -0x78(%ebp),%eax
c0107378:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010737b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010737e:	81 7d ec 44 21 1a c0 	cmpl   $0xc01a2144,-0x14(%ebp)
c0107385:	75 cc                	jne    c0107353 <default_check+0x5c6>
    }
    assert(count == 0);
c0107387:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010738b:	74 24                	je     c01073b1 <default_check+0x624>
c010738d:	c7 44 24 0c e6 d8 10 	movl   $0xc010d8e6,0xc(%esp)
c0107394:	c0 
c0107395:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c010739c:	c0 
c010739d:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01073a4:	00 
c01073a5:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01073ac:	e8 4f 90 ff ff       	call   c0100400 <__panic>
    assert(total == 0);
c01073b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01073b5:	74 24                	je     c01073db <default_check+0x64e>
c01073b7:	c7 44 24 0c f1 d8 10 	movl   $0xc010d8f1,0xc(%esp)
c01073be:	c0 
c01073bf:	c7 44 24 08 86 d5 10 	movl   $0xc010d586,0x8(%esp)
c01073c6:	c0 
c01073c7:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c01073ce:	00 
c01073cf:	c7 04 24 9b d5 10 c0 	movl   $0xc010d59b,(%esp)
c01073d6:	e8 25 90 ff ff       	call   c0100400 <__panic>
}
c01073db:	90                   	nop
c01073dc:	c9                   	leave  
c01073dd:	c3                   	ret    

c01073de <page2ppn>:
page2ppn(struct Page *page) {
c01073de:	55                   	push   %ebp
c01073df:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01073e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01073e4:	8b 15 58 21 1a c0    	mov    0xc01a2158,%edx
c01073ea:	29 d0                	sub    %edx,%eax
c01073ec:	c1 f8 05             	sar    $0x5,%eax
}
c01073ef:	5d                   	pop    %ebp
c01073f0:	c3                   	ret    

c01073f1 <page2pa>:
page2pa(struct Page *page) {
c01073f1:	55                   	push   %ebp
c01073f2:	89 e5                	mov    %esp,%ebp
c01073f4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01073f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01073fa:	89 04 24             	mov    %eax,(%esp)
c01073fd:	e8 dc ff ff ff       	call   c01073de <page2ppn>
c0107402:	c1 e0 0c             	shl    $0xc,%eax
}
c0107405:	c9                   	leave  
c0107406:	c3                   	ret    

c0107407 <pa2page>:
pa2page(uintptr_t pa) {
c0107407:	55                   	push   %ebp
c0107408:	89 e5                	mov    %esp,%ebp
c010740a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010740d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107410:	c1 e8 0c             	shr    $0xc,%eax
c0107413:	89 c2                	mov    %eax,%edx
c0107415:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c010741a:	39 c2                	cmp    %eax,%edx
c010741c:	72 1c                	jb     c010743a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010741e:	c7 44 24 08 2c d9 10 	movl   $0xc010d92c,0x8(%esp)
c0107425:	c0 
c0107426:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010742d:	00 
c010742e:	c7 04 24 4b d9 10 c0 	movl   $0xc010d94b,(%esp)
c0107435:	e8 c6 8f ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c010743a:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c010743f:	8b 55 08             	mov    0x8(%ebp),%edx
c0107442:	c1 ea 0c             	shr    $0xc,%edx
c0107445:	c1 e2 05             	shl    $0x5,%edx
c0107448:	01 d0                	add    %edx,%eax
}
c010744a:	c9                   	leave  
c010744b:	c3                   	ret    

c010744c <page2kva>:
page2kva(struct Page *page) {
c010744c:	55                   	push   %ebp
c010744d:	89 e5                	mov    %esp,%ebp
c010744f:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107452:	8b 45 08             	mov    0x8(%ebp),%eax
c0107455:	89 04 24             	mov    %eax,(%esp)
c0107458:	e8 94 ff ff ff       	call   c01073f1 <page2pa>
c010745d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107460:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107463:	c1 e8 0c             	shr    $0xc,%eax
c0107466:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107469:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c010746e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107471:	72 23                	jb     c0107496 <page2kva+0x4a>
c0107473:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107476:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010747a:	c7 44 24 08 5c d9 10 	movl   $0xc010d95c,0x8(%esp)
c0107481:	c0 
c0107482:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107489:	00 
c010748a:	c7 04 24 4b d9 10 c0 	movl   $0xc010d94b,(%esp)
c0107491:	e8 6a 8f ff ff       	call   c0100400 <__panic>
c0107496:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107499:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010749e:	c9                   	leave  
c010749f:	c3                   	ret    

c01074a0 <pte2page>:
pte2page(pte_t pte) {
c01074a0:	55                   	push   %ebp
c01074a1:	89 e5                	mov    %esp,%ebp
c01074a3:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01074a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01074a9:	83 e0 01             	and    $0x1,%eax
c01074ac:	85 c0                	test   %eax,%eax
c01074ae:	75 1c                	jne    c01074cc <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01074b0:	c7 44 24 08 80 d9 10 	movl   $0xc010d980,0x8(%esp)
c01074b7:	c0 
c01074b8:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01074bf:	00 
c01074c0:	c7 04 24 4b d9 10 c0 	movl   $0xc010d94b,(%esp)
c01074c7:	e8 34 8f ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c01074cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01074cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01074d4:	89 04 24             	mov    %eax,(%esp)
c01074d7:	e8 2b ff ff ff       	call   c0107407 <pa2page>
}
c01074dc:	c9                   	leave  
c01074dd:	c3                   	ret    

c01074de <pde2page>:
pde2page(pde_t pde) {
c01074de:	55                   	push   %ebp
c01074df:	89 e5                	mov    %esp,%ebp
c01074e1:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01074e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01074e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01074ec:	89 04 24             	mov    %eax,(%esp)
c01074ef:	e8 13 ff ff ff       	call   c0107407 <pa2page>
}
c01074f4:	c9                   	leave  
c01074f5:	c3                   	ret    

c01074f6 <page_ref>:
page_ref(struct Page *page) {
c01074f6:	55                   	push   %ebp
c01074f7:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01074f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01074fc:	8b 00                	mov    (%eax),%eax
}
c01074fe:	5d                   	pop    %ebp
c01074ff:	c3                   	ret    

c0107500 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0107500:	55                   	push   %ebp
c0107501:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0107503:	8b 45 08             	mov    0x8(%ebp),%eax
c0107506:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107509:	89 10                	mov    %edx,(%eax)
}
c010750b:	90                   	nop
c010750c:	5d                   	pop    %ebp
c010750d:	c3                   	ret    

c010750e <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010750e:	55                   	push   %ebp
c010750f:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0107511:	8b 45 08             	mov    0x8(%ebp),%eax
c0107514:	8b 00                	mov    (%eax),%eax
c0107516:	8d 50 01             	lea    0x1(%eax),%edx
c0107519:	8b 45 08             	mov    0x8(%ebp),%eax
c010751c:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010751e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107521:	8b 00                	mov    (%eax),%eax
}
c0107523:	5d                   	pop    %ebp
c0107524:	c3                   	ret    

c0107525 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0107525:	55                   	push   %ebp
c0107526:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0107528:	8b 45 08             	mov    0x8(%ebp),%eax
c010752b:	8b 00                	mov    (%eax),%eax
c010752d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107530:	8b 45 08             	mov    0x8(%ebp),%eax
c0107533:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0107535:	8b 45 08             	mov    0x8(%ebp),%eax
c0107538:	8b 00                	mov    (%eax),%eax
}
c010753a:	5d                   	pop    %ebp
c010753b:	c3                   	ret    

c010753c <__intr_save>:
__intr_save(void) {
c010753c:	55                   	push   %ebp
c010753d:	89 e5                	mov    %esp,%ebp
c010753f:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0107542:	9c                   	pushf  
c0107543:	58                   	pop    %eax
c0107544:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0107547:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010754a:	25 00 02 00 00       	and    $0x200,%eax
c010754f:	85 c0                	test   %eax,%eax
c0107551:	74 0c                	je     c010755f <__intr_save+0x23>
        intr_disable();
c0107553:	e8 88 ac ff ff       	call   c01021e0 <intr_disable>
        return 1;
c0107558:	b8 01 00 00 00       	mov    $0x1,%eax
c010755d:	eb 05                	jmp    c0107564 <__intr_save+0x28>
    return 0;
c010755f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107564:	c9                   	leave  
c0107565:	c3                   	ret    

c0107566 <__intr_restore>:
__intr_restore(bool flag) {
c0107566:	55                   	push   %ebp
c0107567:	89 e5                	mov    %esp,%ebp
c0107569:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010756c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107570:	74 05                	je     c0107577 <__intr_restore+0x11>
        intr_enable();
c0107572:	e8 62 ac ff ff       	call   c01021d9 <intr_enable>
}
c0107577:	90                   	nop
c0107578:	c9                   	leave  
c0107579:	c3                   	ret    

c010757a <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c010757a:	55                   	push   %ebp
c010757b:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010757d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107580:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0107583:	b8 23 00 00 00       	mov    $0x23,%eax
c0107588:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c010758a:	b8 23 00 00 00       	mov    $0x23,%eax
c010758f:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0107591:	b8 10 00 00 00       	mov    $0x10,%eax
c0107596:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0107598:	b8 10 00 00 00       	mov    $0x10,%eax
c010759d:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c010759f:	b8 10 00 00 00       	mov    $0x10,%eax
c01075a4:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01075a6:	ea ad 75 10 c0 08 00 	ljmp   $0x8,$0xc01075ad
}
c01075ad:	90                   	nop
c01075ae:	5d                   	pop    %ebp
c01075af:	c3                   	ret    

c01075b0 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01075b0:	55                   	push   %ebp
c01075b1:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01075b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01075b6:	a3 a4 ff 19 c0       	mov    %eax,0xc019ffa4
}
c01075bb:	90                   	nop
c01075bc:	5d                   	pop    %ebp
c01075bd:	c3                   	ret    

c01075be <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01075be:	55                   	push   %ebp
c01075bf:	89 e5                	mov    %esp,%ebp
c01075c1:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01075c4:	b8 00 b0 12 c0       	mov    $0xc012b000,%eax
c01075c9:	89 04 24             	mov    %eax,(%esp)
c01075cc:	e8 df ff ff ff       	call   c01075b0 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01075d1:	66 c7 05 a8 ff 19 c0 	movw   $0x10,0xc019ffa8
c01075d8:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01075da:	66 c7 05 68 ba 12 c0 	movw   $0x68,0xc012ba68
c01075e1:	68 00 
c01075e3:	b8 a0 ff 19 c0       	mov    $0xc019ffa0,%eax
c01075e8:	0f b7 c0             	movzwl %ax,%eax
c01075eb:	66 a3 6a ba 12 c0    	mov    %ax,0xc012ba6a
c01075f1:	b8 a0 ff 19 c0       	mov    $0xc019ffa0,%eax
c01075f6:	c1 e8 10             	shr    $0x10,%eax
c01075f9:	a2 6c ba 12 c0       	mov    %al,0xc012ba6c
c01075fe:	0f b6 05 6d ba 12 c0 	movzbl 0xc012ba6d,%eax
c0107605:	24 f0                	and    $0xf0,%al
c0107607:	0c 09                	or     $0x9,%al
c0107609:	a2 6d ba 12 c0       	mov    %al,0xc012ba6d
c010760e:	0f b6 05 6d ba 12 c0 	movzbl 0xc012ba6d,%eax
c0107615:	24 ef                	and    $0xef,%al
c0107617:	a2 6d ba 12 c0       	mov    %al,0xc012ba6d
c010761c:	0f b6 05 6d ba 12 c0 	movzbl 0xc012ba6d,%eax
c0107623:	24 9f                	and    $0x9f,%al
c0107625:	a2 6d ba 12 c0       	mov    %al,0xc012ba6d
c010762a:	0f b6 05 6d ba 12 c0 	movzbl 0xc012ba6d,%eax
c0107631:	0c 80                	or     $0x80,%al
c0107633:	a2 6d ba 12 c0       	mov    %al,0xc012ba6d
c0107638:	0f b6 05 6e ba 12 c0 	movzbl 0xc012ba6e,%eax
c010763f:	24 f0                	and    $0xf0,%al
c0107641:	a2 6e ba 12 c0       	mov    %al,0xc012ba6e
c0107646:	0f b6 05 6e ba 12 c0 	movzbl 0xc012ba6e,%eax
c010764d:	24 ef                	and    $0xef,%al
c010764f:	a2 6e ba 12 c0       	mov    %al,0xc012ba6e
c0107654:	0f b6 05 6e ba 12 c0 	movzbl 0xc012ba6e,%eax
c010765b:	24 df                	and    $0xdf,%al
c010765d:	a2 6e ba 12 c0       	mov    %al,0xc012ba6e
c0107662:	0f b6 05 6e ba 12 c0 	movzbl 0xc012ba6e,%eax
c0107669:	0c 40                	or     $0x40,%al
c010766b:	a2 6e ba 12 c0       	mov    %al,0xc012ba6e
c0107670:	0f b6 05 6e ba 12 c0 	movzbl 0xc012ba6e,%eax
c0107677:	24 7f                	and    $0x7f,%al
c0107679:	a2 6e ba 12 c0       	mov    %al,0xc012ba6e
c010767e:	b8 a0 ff 19 c0       	mov    $0xc019ffa0,%eax
c0107683:	c1 e8 18             	shr    $0x18,%eax
c0107686:	a2 6f ba 12 c0       	mov    %al,0xc012ba6f

    // reload all segment registers
    lgdt(&gdt_pd);
c010768b:	c7 04 24 70 ba 12 c0 	movl   $0xc012ba70,(%esp)
c0107692:	e8 e3 fe ff ff       	call   c010757a <lgdt>
c0107697:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010769d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01076a1:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01076a4:	90                   	nop
c01076a5:	c9                   	leave  
c01076a6:	c3                   	ret    

c01076a7 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01076a7:	55                   	push   %ebp
c01076a8:	89 e5                	mov    %esp,%ebp
c01076aa:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01076ad:	c7 05 50 21 1a c0 10 	movl   $0xc010d910,0xc01a2150
c01076b4:	d9 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01076b7:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c01076bc:	8b 00                	mov    (%eax),%eax
c01076be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01076c2:	c7 04 24 ac d9 10 c0 	movl   $0xc010d9ac,(%esp)
c01076c9:	e8 db 8b ff ff       	call   c01002a9 <cprintf>
    pmm_manager->init();
c01076ce:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c01076d3:	8b 40 04             	mov    0x4(%eax),%eax
c01076d6:	ff d0                	call   *%eax
}
c01076d8:	90                   	nop
c01076d9:	c9                   	leave  
c01076da:	c3                   	ret    

c01076db <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01076db:	55                   	push   %ebp
c01076dc:	89 e5                	mov    %esp,%ebp
c01076de:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01076e1:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c01076e6:	8b 40 08             	mov    0x8(%eax),%eax
c01076e9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01076ec:	89 54 24 04          	mov    %edx,0x4(%esp)
c01076f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01076f3:	89 14 24             	mov    %edx,(%esp)
c01076f6:	ff d0                	call   *%eax
}
c01076f8:	90                   	nop
c01076f9:	c9                   	leave  
c01076fa:	c3                   	ret    

c01076fb <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01076fb:	55                   	push   %ebp
c01076fc:	89 e5                	mov    %esp,%ebp
c01076fe:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0107701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0107708:	e8 2f fe ff ff       	call   c010753c <__intr_save>
c010770d:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0107710:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c0107715:	8b 40 0c             	mov    0xc(%eax),%eax
c0107718:	8b 55 08             	mov    0x8(%ebp),%edx
c010771b:	89 14 24             	mov    %edx,(%esp)
c010771e:	ff d0                	call   *%eax
c0107720:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0107723:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107726:	89 04 24             	mov    %eax,(%esp)
c0107729:	e8 38 fe ff ff       	call   c0107566 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010772e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107732:	75 2d                	jne    c0107761 <alloc_pages+0x66>
c0107734:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0107738:	77 27                	ja     c0107761 <alloc_pages+0x66>
c010773a:	a1 6c ff 19 c0       	mov    0xc019ff6c,%eax
c010773f:	85 c0                	test   %eax,%eax
c0107741:	74 1e                	je     c0107761 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0107743:	8b 55 08             	mov    0x8(%ebp),%edx
c0107746:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c010774b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107752:	00 
c0107753:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107757:	89 04 24             	mov    %eax,(%esp)
c010775a:	e8 f1 df ff ff       	call   c0105750 <swap_out>
    {
c010775f:	eb a7                	jmp    c0107708 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107764:	c9                   	leave  
c0107765:	c3                   	ret    

c0107766 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0107766:	55                   	push   %ebp
c0107767:	89 e5                	mov    %esp,%ebp
c0107769:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010776c:	e8 cb fd ff ff       	call   c010753c <__intr_save>
c0107771:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0107774:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c0107779:	8b 40 10             	mov    0x10(%eax),%eax
c010777c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010777f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107783:	8b 55 08             	mov    0x8(%ebp),%edx
c0107786:	89 14 24             	mov    %edx,(%esp)
c0107789:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010778b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010778e:	89 04 24             	mov    %eax,(%esp)
c0107791:	e8 d0 fd ff ff       	call   c0107566 <__intr_restore>
}
c0107796:	90                   	nop
c0107797:	c9                   	leave  
c0107798:	c3                   	ret    

c0107799 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0107799:	55                   	push   %ebp
c010779a:	89 e5                	mov    %esp,%ebp
c010779c:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010779f:	e8 98 fd ff ff       	call   c010753c <__intr_save>
c01077a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01077a7:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c01077ac:	8b 40 14             	mov    0x14(%eax),%eax
c01077af:	ff d0                	call   *%eax
c01077b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01077b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077b7:	89 04 24             	mov    %eax,(%esp)
c01077ba:	e8 a7 fd ff ff       	call   c0107566 <__intr_restore>
    return ret;
c01077bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01077c2:	c9                   	leave  
c01077c3:	c3                   	ret    

c01077c4 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01077c4:	55                   	push   %ebp
c01077c5:	89 e5                	mov    %esp,%ebp
c01077c7:	57                   	push   %edi
c01077c8:	56                   	push   %esi
c01077c9:	53                   	push   %ebx
c01077ca:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01077d0:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01077d7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01077de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01077e5:	c7 04 24 c3 d9 10 c0 	movl   $0xc010d9c3,(%esp)
c01077ec:	e8 b8 8a ff ff       	call   c01002a9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01077f1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01077f8:	e9 22 01 00 00       	jmp    c010791f <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01077fd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107800:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107803:	89 d0                	mov    %edx,%eax
c0107805:	c1 e0 02             	shl    $0x2,%eax
c0107808:	01 d0                	add    %edx,%eax
c010780a:	c1 e0 02             	shl    $0x2,%eax
c010780d:	01 c8                	add    %ecx,%eax
c010780f:	8b 50 08             	mov    0x8(%eax),%edx
c0107812:	8b 40 04             	mov    0x4(%eax),%eax
c0107815:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0107818:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010781b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010781e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107821:	89 d0                	mov    %edx,%eax
c0107823:	c1 e0 02             	shl    $0x2,%eax
c0107826:	01 d0                	add    %edx,%eax
c0107828:	c1 e0 02             	shl    $0x2,%eax
c010782b:	01 c8                	add    %ecx,%eax
c010782d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107830:	8b 58 10             	mov    0x10(%eax),%ebx
c0107833:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107836:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0107839:	01 c8                	add    %ecx,%eax
c010783b:	11 da                	adc    %ebx,%edx
c010783d:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107840:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0107843:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107846:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107849:	89 d0                	mov    %edx,%eax
c010784b:	c1 e0 02             	shl    $0x2,%eax
c010784e:	01 d0                	add    %edx,%eax
c0107850:	c1 e0 02             	shl    $0x2,%eax
c0107853:	01 c8                	add    %ecx,%eax
c0107855:	83 c0 14             	add    $0x14,%eax
c0107858:	8b 00                	mov    (%eax),%eax
c010785a:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010785d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107860:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107863:	83 c0 ff             	add    $0xffffffff,%eax
c0107866:	83 d2 ff             	adc    $0xffffffff,%edx
c0107869:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c010786f:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0107875:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107878:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010787b:	89 d0                	mov    %edx,%eax
c010787d:	c1 e0 02             	shl    $0x2,%eax
c0107880:	01 d0                	add    %edx,%eax
c0107882:	c1 e0 02             	shl    $0x2,%eax
c0107885:	01 c8                	add    %ecx,%eax
c0107887:	8b 48 0c             	mov    0xc(%eax),%ecx
c010788a:	8b 58 10             	mov    0x10(%eax),%ebx
c010788d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107890:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0107894:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c010789a:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c01078a0:	89 44 24 14          	mov    %eax,0x14(%esp)
c01078a4:	89 54 24 18          	mov    %edx,0x18(%esp)
c01078a8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01078ab:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01078ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01078b2:	89 54 24 10          	mov    %edx,0x10(%esp)
c01078b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01078ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01078be:	c7 04 24 d0 d9 10 c0 	movl   $0xc010d9d0,(%esp)
c01078c5:	e8 df 89 ff ff       	call   c01002a9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01078ca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01078cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01078d0:	89 d0                	mov    %edx,%eax
c01078d2:	c1 e0 02             	shl    $0x2,%eax
c01078d5:	01 d0                	add    %edx,%eax
c01078d7:	c1 e0 02             	shl    $0x2,%eax
c01078da:	01 c8                	add    %ecx,%eax
c01078dc:	83 c0 14             	add    $0x14,%eax
c01078df:	8b 00                	mov    (%eax),%eax
c01078e1:	83 f8 01             	cmp    $0x1,%eax
c01078e4:	75 36                	jne    c010791c <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c01078e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01078ec:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c01078ef:	77 2b                	ja     c010791c <page_init+0x158>
c01078f1:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c01078f4:	72 05                	jb     c01078fb <page_init+0x137>
c01078f6:	3b 45 98             	cmp    -0x68(%ebp),%eax
c01078f9:	73 21                	jae    c010791c <page_init+0x158>
c01078fb:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01078ff:	77 1b                	ja     c010791c <page_init+0x158>
c0107901:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0107905:	72 09                	jb     c0107910 <page_init+0x14c>
c0107907:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c010790e:	77 0c                	ja     c010791c <page_init+0x158>
                maxpa = end;
c0107910:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107913:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107916:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107919:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c010791c:	ff 45 dc             	incl   -0x24(%ebp)
c010791f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107922:	8b 00                	mov    (%eax),%eax
c0107924:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107927:	0f 8c d0 fe ff ff    	jl     c01077fd <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010792d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107931:	72 1d                	jb     c0107950 <page_init+0x18c>
c0107933:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107937:	77 09                	ja     c0107942 <page_init+0x17e>
c0107939:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0107940:	76 0e                	jbe    c0107950 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0107942:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0107949:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0107950:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107953:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107956:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010795a:	c1 ea 0c             	shr    $0xc,%edx
c010795d:	89 c1                	mov    %eax,%ecx
c010795f:	89 d3                	mov    %edx,%ebx
c0107961:	89 c8                	mov    %ecx,%eax
c0107963:	a3 80 ff 19 c0       	mov    %eax,0xc019ff80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0107968:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c010796f:	b8 64 21 1a c0       	mov    $0xc01a2164,%eax
c0107974:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107977:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010797a:	01 d0                	add    %edx,%eax
c010797c:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010797f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107982:	ba 00 00 00 00       	mov    $0x0,%edx
c0107987:	f7 75 c0             	divl   -0x40(%ebp)
c010798a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010798d:	29 d0                	sub    %edx,%eax
c010798f:	a3 58 21 1a c0       	mov    %eax,0xc01a2158

    for (i = 0; i < npage; i ++) {
c0107994:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010799b:	eb 26                	jmp    c01079c3 <page_init+0x1ff>
        SetPageReserved(pages + i);
c010799d:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c01079a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01079a5:	c1 e2 05             	shl    $0x5,%edx
c01079a8:	01 d0                	add    %edx,%eax
c01079aa:	83 c0 04             	add    $0x4,%eax
c01079ad:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01079b4:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01079b7:	8b 45 90             	mov    -0x70(%ebp),%eax
c01079ba:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01079bd:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c01079c0:	ff 45 dc             	incl   -0x24(%ebp)
c01079c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01079c6:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c01079cb:	39 c2                	cmp    %eax,%edx
c01079cd:	72 ce                	jb     c010799d <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01079cf:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c01079d4:	c1 e0 05             	shl    $0x5,%eax
c01079d7:	89 c2                	mov    %eax,%edx
c01079d9:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c01079de:	01 d0                	add    %edx,%eax
c01079e0:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01079e3:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c01079ea:	77 23                	ja     c0107a0f <page_init+0x24b>
c01079ec:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01079ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01079f3:	c7 44 24 08 00 da 10 	movl   $0xc010da00,0x8(%esp)
c01079fa:	c0 
c01079fb:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0107a02:	00 
c0107a03:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107a0a:	e8 f1 89 ff ff       	call   c0100400 <__panic>
c0107a0f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107a12:	05 00 00 00 40       	add    $0x40000000,%eax
c0107a17:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0107a1a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107a21:	e9 69 01 00 00       	jmp    c0107b8f <page_init+0x3cb>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107a26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107a29:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107a2c:	89 d0                	mov    %edx,%eax
c0107a2e:	c1 e0 02             	shl    $0x2,%eax
c0107a31:	01 d0                	add    %edx,%eax
c0107a33:	c1 e0 02             	shl    $0x2,%eax
c0107a36:	01 c8                	add    %ecx,%eax
c0107a38:	8b 50 08             	mov    0x8(%eax),%edx
c0107a3b:	8b 40 04             	mov    0x4(%eax),%eax
c0107a3e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107a41:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107a44:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107a47:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107a4a:	89 d0                	mov    %edx,%eax
c0107a4c:	c1 e0 02             	shl    $0x2,%eax
c0107a4f:	01 d0                	add    %edx,%eax
c0107a51:	c1 e0 02             	shl    $0x2,%eax
c0107a54:	01 c8                	add    %ecx,%eax
c0107a56:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107a59:	8b 58 10             	mov    0x10(%eax),%ebx
c0107a5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107a5f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107a62:	01 c8                	add    %ecx,%eax
c0107a64:	11 da                	adc    %ebx,%edx
c0107a66:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0107a69:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0107a6c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107a6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107a72:	89 d0                	mov    %edx,%eax
c0107a74:	c1 e0 02             	shl    $0x2,%eax
c0107a77:	01 d0                	add    %edx,%eax
c0107a79:	c1 e0 02             	shl    $0x2,%eax
c0107a7c:	01 c8                	add    %ecx,%eax
c0107a7e:	83 c0 14             	add    $0x14,%eax
c0107a81:	8b 00                	mov    (%eax),%eax
c0107a83:	83 f8 01             	cmp    $0x1,%eax
c0107a86:	0f 85 00 01 00 00    	jne    c0107b8c <page_init+0x3c8>
            if (begin < freemem) {
c0107a8c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107a8f:	ba 00 00 00 00       	mov    $0x0,%edx
c0107a94:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0107a97:	77 17                	ja     c0107ab0 <page_init+0x2ec>
c0107a99:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0107a9c:	72 05                	jb     c0107aa3 <page_init+0x2df>
c0107a9e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0107aa1:	73 0d                	jae    c0107ab0 <page_init+0x2ec>
                begin = freemem;
c0107aa3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107aa6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107aa9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0107ab0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107ab4:	72 1d                	jb     c0107ad3 <page_init+0x30f>
c0107ab6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107aba:	77 09                	ja     c0107ac5 <page_init+0x301>
c0107abc:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0107ac3:	76 0e                	jbe    c0107ad3 <page_init+0x30f>
                end = KMEMSIZE;
c0107ac5:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0107acc:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0107ad3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107ad6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107ad9:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107adc:	0f 87 aa 00 00 00    	ja     c0107b8c <page_init+0x3c8>
c0107ae2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107ae5:	72 09                	jb     c0107af0 <page_init+0x32c>
c0107ae7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107aea:	0f 83 9c 00 00 00    	jae    c0107b8c <page_init+0x3c8>
                begin = ROUNDUP(begin, PGSIZE);
c0107af0:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0107af7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107afa:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107afd:	01 d0                	add    %edx,%eax
c0107aff:	48                   	dec    %eax
c0107b00:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0107b03:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107b06:	ba 00 00 00 00       	mov    $0x0,%edx
c0107b0b:	f7 75 b0             	divl   -0x50(%ebp)
c0107b0e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107b11:	29 d0                	sub    %edx,%eax
c0107b13:	ba 00 00 00 00       	mov    $0x0,%edx
c0107b18:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107b1b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0107b1e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107b21:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0107b24:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107b27:	ba 00 00 00 00       	mov    $0x0,%edx
c0107b2c:	89 c3                	mov    %eax,%ebx
c0107b2e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0107b34:	89 de                	mov    %ebx,%esi
c0107b36:	89 d0                	mov    %edx,%eax
c0107b38:	83 e0 00             	and    $0x0,%eax
c0107b3b:	89 c7                	mov    %eax,%edi
c0107b3d:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0107b40:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0107b43:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107b46:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107b49:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107b4c:	77 3e                	ja     c0107b8c <page_init+0x3c8>
c0107b4e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107b51:	72 05                	jb     c0107b58 <page_init+0x394>
c0107b53:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107b56:	73 34                	jae    c0107b8c <page_init+0x3c8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0107b58:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107b5b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107b5e:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0107b61:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0107b64:	89 c1                	mov    %eax,%ecx
c0107b66:	89 d3                	mov    %edx,%ebx
c0107b68:	89 c8                	mov    %ecx,%eax
c0107b6a:	89 da                	mov    %ebx,%edx
c0107b6c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107b70:	c1 ea 0c             	shr    $0xc,%edx
c0107b73:	89 c3                	mov    %eax,%ebx
c0107b75:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107b78:	89 04 24             	mov    %eax,(%esp)
c0107b7b:	e8 87 f8 ff ff       	call   c0107407 <pa2page>
c0107b80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0107b84:	89 04 24             	mov    %eax,(%esp)
c0107b87:	e8 4f fb ff ff       	call   c01076db <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0107b8c:	ff 45 dc             	incl   -0x24(%ebp)
c0107b8f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107b92:	8b 00                	mov    (%eax),%eax
c0107b94:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107b97:	0f 8c 89 fe ff ff    	jl     c0107a26 <page_init+0x262>
                }
            }
        }
    }
}
c0107b9d:	90                   	nop
c0107b9e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0107ba4:	5b                   	pop    %ebx
c0107ba5:	5e                   	pop    %esi
c0107ba6:	5f                   	pop    %edi
c0107ba7:	5d                   	pop    %ebp
c0107ba8:	c3                   	ret    

c0107ba9 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0107ba9:	55                   	push   %ebp
c0107baa:	89 e5                	mov    %esp,%ebp
c0107bac:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0107baf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bb2:	33 45 14             	xor    0x14(%ebp),%eax
c0107bb5:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107bba:	85 c0                	test   %eax,%eax
c0107bbc:	74 24                	je     c0107be2 <boot_map_segment+0x39>
c0107bbe:	c7 44 24 0c 32 da 10 	movl   $0xc010da32,0xc(%esp)
c0107bc5:	c0 
c0107bc6:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0107bcd:	c0 
c0107bce:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0107bd5:	00 
c0107bd6:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107bdd:	e8 1e 88 ff ff       	call   c0100400 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0107be2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0107be9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bec:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107bf1:	89 c2                	mov    %eax,%edx
c0107bf3:	8b 45 10             	mov    0x10(%ebp),%eax
c0107bf6:	01 c2                	add    %eax,%edx
c0107bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bfb:	01 d0                	add    %edx,%eax
c0107bfd:	48                   	dec    %eax
c0107bfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c04:	ba 00 00 00 00       	mov    $0x0,%edx
c0107c09:	f7 75 f0             	divl   -0x10(%ebp)
c0107c0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c0f:	29 d0                	sub    %edx,%eax
c0107c11:	c1 e8 0c             	shr    $0xc,%eax
c0107c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0107c17:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107c25:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0107c28:	8b 45 14             	mov    0x14(%ebp),%eax
c0107c2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107c36:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107c39:	eb 68                	jmp    c0107ca3 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0107c3b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107c42:	00 
c0107c43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c4d:	89 04 24             	mov    %eax,(%esp)
c0107c50:	e8 86 01 00 00       	call   c0107ddb <get_pte>
c0107c55:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0107c58:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107c5c:	75 24                	jne    c0107c82 <boot_map_segment+0xd9>
c0107c5e:	c7 44 24 0c 5e da 10 	movl   $0xc010da5e,0xc(%esp)
c0107c65:	c0 
c0107c66:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0107c6d:	c0 
c0107c6e:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0107c75:	00 
c0107c76:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107c7d:	e8 7e 87 ff ff       	call   c0100400 <__panic>
        *ptep = pa | PTE_P | perm;
c0107c82:	8b 45 14             	mov    0x14(%ebp),%eax
c0107c85:	0b 45 18             	or     0x18(%ebp),%eax
c0107c88:	83 c8 01             	or     $0x1,%eax
c0107c8b:	89 c2                	mov    %eax,%edx
c0107c8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c90:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107c92:	ff 4d f4             	decl   -0xc(%ebp)
c0107c95:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0107c9c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0107ca3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ca7:	75 92                	jne    c0107c3b <boot_map_segment+0x92>
    }
}
c0107ca9:	90                   	nop
c0107caa:	c9                   	leave  
c0107cab:	c3                   	ret    

c0107cac <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0107cac:	55                   	push   %ebp
c0107cad:	89 e5                	mov    %esp,%ebp
c0107caf:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0107cb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107cb9:	e8 3d fa ff ff       	call   c01076fb <alloc_pages>
c0107cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0107cc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107cc5:	75 1c                	jne    c0107ce3 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0107cc7:	c7 44 24 08 6b da 10 	movl   $0xc010da6b,0x8(%esp)
c0107cce:	c0 
c0107ccf:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0107cd6:	00 
c0107cd7:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107cde:	e8 1d 87 ff ff       	call   c0100400 <__panic>
    }
    return page2kva(p);
c0107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ce6:	89 04 24             	mov    %eax,(%esp)
c0107ce9:	e8 5e f7 ff ff       	call   c010744c <page2kva>
}
c0107cee:	c9                   	leave  
c0107cef:	c3                   	ret    

c0107cf0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0107cf0:	55                   	push   %ebp
c0107cf1:	89 e5                	mov    %esp,%ebp
c0107cf3:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0107cf6:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0107cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107cfe:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107d05:	77 23                	ja     c0107d2a <pmm_init+0x3a>
c0107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107d0e:	c7 44 24 08 00 da 10 	movl   $0xc010da00,0x8(%esp)
c0107d15:	c0 
c0107d16:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0107d1d:	00 
c0107d1e:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107d25:	e8 d6 86 ff ff       	call   c0100400 <__panic>
c0107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d2d:	05 00 00 00 40       	add    $0x40000000,%eax
c0107d32:	a3 54 21 1a c0       	mov    %eax,0xc01a2154
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0107d37:	e8 6b f9 ff ff       	call   c01076a7 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0107d3c:	e8 83 fa ff ff       	call   c01077c4 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0107d41:	e8 d7 08 00 00       	call   c010861d <check_alloc_page>

    check_pgdir();
c0107d46:	e8 f1 08 00 00       	call   c010863c <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0107d4b:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0107d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107d53:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107d5a:	77 23                	ja     c0107d7f <pmm_init+0x8f>
c0107d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107d63:	c7 44 24 08 00 da 10 	movl   $0xc010da00,0x8(%esp)
c0107d6a:	c0 
c0107d6b:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0107d72:	00 
c0107d73:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107d7a:	e8 81 86 ff ff       	call   c0100400 <__panic>
c0107d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d82:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0107d88:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0107d8d:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107d92:	83 ca 03             	or     $0x3,%edx
c0107d95:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0107d97:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0107d9c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0107da3:	00 
c0107da4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107dab:	00 
c0107dac:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0107db3:	38 
c0107db4:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0107dbb:	c0 
c0107dbc:	89 04 24             	mov    %eax,(%esp)
c0107dbf:	e8 e5 fd ff ff       	call   c0107ba9 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0107dc4:	e8 f5 f7 ff ff       	call   c01075be <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0107dc9:	e8 0a 0f 00 00       	call   c0108cd8 <check_boot_pgdir>

    print_pgdir();
c0107dce:	e8 83 13 00 00       	call   c0109156 <print_pgdir>
    
    kmalloc_init();
c0107dd3:	e8 31 d5 ff ff       	call   c0105309 <kmalloc_init>

}
c0107dd8:	90                   	nop
c0107dd9:	c9                   	leave  
c0107dda:	c3                   	ret    

c0107ddb <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0107ddb:	55                   	push   %ebp
c0107ddc:	89 e5                	mov    %esp,%ebp
c0107dde:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0107de1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107de4:	c1 e8 16             	shr    $0x16,%eax
c0107de7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107dee:	8b 45 08             	mov    0x8(%ebp),%eax
c0107df1:	01 d0                	add    %edx,%eax
c0107df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107df9:	8b 00                	mov    (%eax),%eax
c0107dfb:	83 e0 01             	and    $0x1,%eax
c0107dfe:	85 c0                	test   %eax,%eax
c0107e00:	0f 85 af 00 00 00    	jne    c0107eb5 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0107e06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107e0a:	74 15                	je     c0107e21 <get_pte+0x46>
c0107e0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107e13:	e8 e3 f8 ff ff       	call   c01076fb <alloc_pages>
c0107e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107e1f:	75 0a                	jne    c0107e2b <get_pte+0x50>
            return NULL;
c0107e21:	b8 00 00 00 00       	mov    $0x0,%eax
c0107e26:	e9 e7 00 00 00       	jmp    c0107f12 <get_pte+0x137>
        }
        set_page_ref(page, 1);
c0107e2b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107e32:	00 
c0107e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e36:	89 04 24             	mov    %eax,(%esp)
c0107e39:	e8 c2 f6 ff ff       	call   c0107500 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0107e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e41:	89 04 24             	mov    %eax,(%esp)
c0107e44:	e8 a8 f5 ff ff       	call   c01073f1 <page2pa>
c0107e49:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0107e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e55:	c1 e8 0c             	shr    $0xc,%eax
c0107e58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107e5b:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0107e60:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0107e63:	72 23                	jb     c0107e88 <get_pte+0xad>
c0107e65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e68:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107e6c:	c7 44 24 08 5c d9 10 	movl   $0xc010d95c,0x8(%esp)
c0107e73:	c0 
c0107e74:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0107e7b:	00 
c0107e7c:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107e83:	e8 78 85 ff ff       	call   c0100400 <__panic>
c0107e88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e8b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107e90:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107e97:	00 
c0107e98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107e9f:	00 
c0107ea0:	89 04 24             	mov    %eax,(%esp)
c0107ea3:	e8 95 38 00 00       	call   c010b73d <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0107ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107eab:	83 c8 07             	or     $0x7,%eax
c0107eae:	89 c2                	mov    %eax,%edx
c0107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107eb3:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0107eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107eb8:	8b 00                	mov    (%eax),%eax
c0107eba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ec5:	c1 e8 0c             	shr    $0xc,%eax
c0107ec8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107ecb:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0107ed0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107ed3:	72 23                	jb     c0107ef8 <get_pte+0x11d>
c0107ed5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ed8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107edc:	c7 44 24 08 5c d9 10 	movl   $0xc010d95c,0x8(%esp)
c0107ee3:	c0 
c0107ee4:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c0107eeb:	00 
c0107eec:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0107ef3:	e8 08 85 ff ff       	call   c0100400 <__panic>
c0107ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107efb:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107f00:	89 c2                	mov    %eax,%edx
c0107f02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f05:	c1 e8 0c             	shr    $0xc,%eax
c0107f08:	25 ff 03 00 00       	and    $0x3ff,%eax
c0107f0d:	c1 e0 02             	shl    $0x2,%eax
c0107f10:	01 d0                	add    %edx,%eax
}
c0107f12:	c9                   	leave  
c0107f13:	c3                   	ret    

c0107f14 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0107f14:	55                   	push   %ebp
c0107f15:	89 e5                	mov    %esp,%ebp
c0107f17:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0107f1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107f21:	00 
c0107f22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f29:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f2c:	89 04 24             	mov    %eax,(%esp)
c0107f2f:	e8 a7 fe ff ff       	call   c0107ddb <get_pte>
c0107f34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0107f37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107f3b:	74 08                	je     c0107f45 <get_page+0x31>
        *ptep_store = ptep;
c0107f3d:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f40:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f43:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0107f45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f49:	74 1b                	je     c0107f66 <get_page+0x52>
c0107f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f4e:	8b 00                	mov    (%eax),%eax
c0107f50:	83 e0 01             	and    $0x1,%eax
c0107f53:	85 c0                	test   %eax,%eax
c0107f55:	74 0f                	je     c0107f66 <get_page+0x52>
        return pte2page(*ptep);
c0107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f5a:	8b 00                	mov    (%eax),%eax
c0107f5c:	89 04 24             	mov    %eax,(%esp)
c0107f5f:	e8 3c f5 ff ff       	call   c01074a0 <pte2page>
c0107f64:	eb 05                	jmp    c0107f6b <get_page+0x57>
    }
    return NULL;
c0107f66:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107f6b:	c9                   	leave  
c0107f6c:	c3                   	ret    

c0107f6d <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0107f6d:	55                   	push   %ebp
c0107f6e:	89 e5                	mov    %esp,%ebp
c0107f70:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0107f73:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f76:	8b 00                	mov    (%eax),%eax
c0107f78:	83 e0 01             	and    $0x1,%eax
c0107f7b:	85 c0                	test   %eax,%eax
c0107f7d:	74 4d                	je     c0107fcc <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0107f7f:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f82:	8b 00                	mov    (%eax),%eax
c0107f84:	89 04 24             	mov    %eax,(%esp)
c0107f87:	e8 14 f5 ff ff       	call   c01074a0 <pte2page>
c0107f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f92:	89 04 24             	mov    %eax,(%esp)
c0107f95:	e8 8b f5 ff ff       	call   c0107525 <page_ref_dec>
c0107f9a:	85 c0                	test   %eax,%eax
c0107f9c:	75 13                	jne    c0107fb1 <page_remove_pte+0x44>
            free_page(page);
c0107f9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107fa5:	00 
c0107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fa9:	89 04 24             	mov    %eax,(%esp)
c0107fac:	e8 b5 f7 ff ff       	call   c0107766 <free_pages>
        }
        *ptep = 0;
c0107fb1:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fb4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0107fba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107fc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fc4:	89 04 24             	mov    %eax,(%esp)
c0107fc7:	e8 21 05 00 00       	call   c01084ed <tlb_invalidate>
    }
}
c0107fcc:	90                   	nop
c0107fcd:	c9                   	leave  
c0107fce:	c3                   	ret    

c0107fcf <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107fcf:	55                   	push   %ebp
c0107fd0:	89 e5                	mov    %esp,%ebp
c0107fd2:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fd8:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107fdd:	85 c0                	test   %eax,%eax
c0107fdf:	75 0c                	jne    c0107fed <unmap_range+0x1e>
c0107fe1:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fe4:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107fe9:	85 c0                	test   %eax,%eax
c0107feb:	74 24                	je     c0108011 <unmap_range+0x42>
c0107fed:	c7 44 24 0c 84 da 10 	movl   $0xc010da84,0xc(%esp)
c0107ff4:	c0 
c0107ff5:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0107ffc:	c0 
c0107ffd:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c0108004:	00 
c0108005:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010800c:	e8 ef 83 ff ff       	call   c0100400 <__panic>
    assert(USER_ACCESS(start, end));
c0108011:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0108018:	76 11                	jbe    c010802b <unmap_range+0x5c>
c010801a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010801d:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108020:	73 09                	jae    c010802b <unmap_range+0x5c>
c0108022:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0108029:	76 24                	jbe    c010804f <unmap_range+0x80>
c010802b:	c7 44 24 0c ad da 10 	movl   $0xc010daad,0xc(%esp)
c0108032:	c0 
c0108033:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c010803a:	c0 
c010803b:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
c0108042:	00 
c0108043:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010804a:	e8 b1 83 ff ff       	call   c0100400 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c010804f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108056:	00 
c0108057:	8b 45 0c             	mov    0xc(%ebp),%eax
c010805a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010805e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108061:	89 04 24             	mov    %eax,(%esp)
c0108064:	e8 72 fd ff ff       	call   c0107ddb <get_pte>
c0108069:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c010806c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108070:	75 18                	jne    c010808a <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0108072:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108075:	05 00 00 40 00       	add    $0x400000,%eax
c010807a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010807d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108080:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0108085:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0108088:	eb 29                	jmp    c01080b3 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c010808a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010808d:	8b 00                	mov    (%eax),%eax
c010808f:	85 c0                	test   %eax,%eax
c0108091:	74 19                	je     c01080ac <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0108093:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108096:	89 44 24 08          	mov    %eax,0x8(%esp)
c010809a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010809d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01080a4:	89 04 24             	mov    %eax,(%esp)
c01080a7:	e8 c1 fe ff ff       	call   c0107f6d <page_remove_pte>
        }
        start += PGSIZE;
c01080ac:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c01080b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01080b7:	74 08                	je     c01080c1 <unmap_range+0xf2>
c01080b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080bc:	3b 45 10             	cmp    0x10(%ebp),%eax
c01080bf:	72 8e                	jb     c010804f <unmap_range+0x80>
}
c01080c1:	90                   	nop
c01080c2:	c9                   	leave  
c01080c3:	c3                   	ret    

c01080c4 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c01080c4:	55                   	push   %ebp
c01080c5:	89 e5                	mov    %esp,%ebp
c01080c7:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c01080ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080cd:	25 ff 0f 00 00       	and    $0xfff,%eax
c01080d2:	85 c0                	test   %eax,%eax
c01080d4:	75 0c                	jne    c01080e2 <exit_range+0x1e>
c01080d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01080d9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01080de:	85 c0                	test   %eax,%eax
c01080e0:	74 24                	je     c0108106 <exit_range+0x42>
c01080e2:	c7 44 24 0c 84 da 10 	movl   $0xc010da84,0xc(%esp)
c01080e9:	c0 
c01080ea:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01080f1:	c0 
c01080f2:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c01080f9:	00 
c01080fa:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108101:	e8 fa 82 ff ff       	call   c0100400 <__panic>
    assert(USER_ACCESS(start, end));
c0108106:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010810d:	76 11                	jbe    c0108120 <exit_range+0x5c>
c010810f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108112:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108115:	73 09                	jae    c0108120 <exit_range+0x5c>
c0108117:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c010811e:	76 24                	jbe    c0108144 <exit_range+0x80>
c0108120:	c7 44 24 0c ad da 10 	movl   $0xc010daad,0xc(%esp)
c0108127:	c0 
c0108128:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c010812f:	c0 
c0108130:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0108137:	00 
c0108138:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010813f:	e8 bc 82 ff ff       	call   c0100400 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0108144:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108147:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010814a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010814d:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0108152:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0108155:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108158:	c1 e8 16             	shr    $0x16,%eax
c010815b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c010815e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108161:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108168:	8b 45 08             	mov    0x8(%ebp),%eax
c010816b:	01 d0                	add    %edx,%eax
c010816d:	8b 00                	mov    (%eax),%eax
c010816f:	83 e0 01             	and    $0x1,%eax
c0108172:	85 c0                	test   %eax,%eax
c0108174:	74 3e                	je     c01081b4 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0108176:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108179:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108180:	8b 45 08             	mov    0x8(%ebp),%eax
c0108183:	01 d0                	add    %edx,%eax
c0108185:	8b 00                	mov    (%eax),%eax
c0108187:	89 04 24             	mov    %eax,(%esp)
c010818a:	e8 4f f3 ff ff       	call   c01074de <pde2page>
c010818f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108196:	00 
c0108197:	89 04 24             	mov    %eax,(%esp)
c010819a:	e8 c7 f5 ff ff       	call   c0107766 <free_pages>
            pgdir[pde_idx] = 0;
c010819f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01081a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ac:	01 d0                	add    %edx,%eax
c01081ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c01081b4:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c01081bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01081bf:	74 08                	je     c01081c9 <exit_range+0x105>
c01081c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081c4:	3b 45 10             	cmp    0x10(%ebp),%eax
c01081c7:	72 8c                	jb     c0108155 <exit_range+0x91>
}
c01081c9:	90                   	nop
c01081ca:	c9                   	leave  
c01081cb:	c3                   	ret    

c01081cc <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c01081cc:	55                   	push   %ebp
c01081cd:	89 e5                	mov    %esp,%ebp
c01081cf:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c01081d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01081d5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01081da:	85 c0                	test   %eax,%eax
c01081dc:	75 0c                	jne    c01081ea <copy_range+0x1e>
c01081de:	8b 45 14             	mov    0x14(%ebp),%eax
c01081e1:	25 ff 0f 00 00       	and    $0xfff,%eax
c01081e6:	85 c0                	test   %eax,%eax
c01081e8:	74 24                	je     c010820e <copy_range+0x42>
c01081ea:	c7 44 24 0c 84 da 10 	movl   $0xc010da84,0xc(%esp)
c01081f1:	c0 
c01081f2:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01081f9:	c0 
c01081fa:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0108201:	00 
c0108202:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108209:	e8 f2 81 ff ff       	call   c0100400 <__panic>
    assert(USER_ACCESS(start, end));
c010820e:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0108215:	76 11                	jbe    c0108228 <copy_range+0x5c>
c0108217:	8b 45 10             	mov    0x10(%ebp),%eax
c010821a:	3b 45 14             	cmp    0x14(%ebp),%eax
c010821d:	73 09                	jae    c0108228 <copy_range+0x5c>
c010821f:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0108226:	76 24                	jbe    c010824c <copy_range+0x80>
c0108228:	c7 44 24 0c ad da 10 	movl   $0xc010daad,0xc(%esp)
c010822f:	c0 
c0108230:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108237:	c0 
c0108238:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c010823f:	00 
c0108240:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108247:	e8 b4 81 ff ff       	call   c0100400 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c010824c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108253:	00 
c0108254:	8b 45 10             	mov    0x10(%ebp),%eax
c0108257:	89 44 24 04          	mov    %eax,0x4(%esp)
c010825b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010825e:	89 04 24             	mov    %eax,(%esp)
c0108261:	e8 75 fb ff ff       	call   c0107ddb <get_pte>
c0108266:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0108269:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010826d:	75 1b                	jne    c010828a <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c010826f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108272:	05 00 00 40 00       	add    $0x400000,%eax
c0108277:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010827a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010827d:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0108282:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0108285:	e9 4c 01 00 00       	jmp    c01083d6 <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c010828a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010828d:	8b 00                	mov    (%eax),%eax
c010828f:	83 e0 01             	and    $0x1,%eax
c0108292:	85 c0                	test   %eax,%eax
c0108294:	0f 84 35 01 00 00    	je     c01083cf <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c010829a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01082a1:	00 
c01082a2:	8b 45 10             	mov    0x10(%ebp),%eax
c01082a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01082a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01082ac:	89 04 24             	mov    %eax,(%esp)
c01082af:	e8 27 fb ff ff       	call   c0107ddb <get_pte>
c01082b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01082b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01082bb:	75 0a                	jne    c01082c7 <copy_range+0xfb>
                return -E_NO_MEM;
c01082bd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01082c2:	e9 26 01 00 00       	jmp    c01083ed <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c01082c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082ca:	8b 00                	mov    (%eax),%eax
c01082cc:	83 e0 07             	and    $0x7,%eax
c01082cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c01082d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082d5:	8b 00                	mov    (%eax),%eax
c01082d7:	89 04 24             	mov    %eax,(%esp)
c01082da:	e8 c1 f1 ff ff       	call   c01074a0 <pte2page>
c01082df:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c01082e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01082e9:	e8 0d f4 ff ff       	call   c01076fb <alloc_pages>
c01082ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(page!=NULL);
c01082f1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082f5:	75 24                	jne    c010831b <copy_range+0x14f>
c01082f7:	c7 44 24 0c c5 da 10 	movl   $0xc010dac5,0xc(%esp)
c01082fe:	c0 
c01082ff:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108306:	c0 
c0108307:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c010830e:	00 
c010830f:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108316:	e8 e5 80 ff ff       	call   c0100400 <__panic>
        assert(npage!=NULL);
c010831b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010831f:	75 24                	jne    c0108345 <copy_range+0x179>
c0108321:	c7 44 24 0c d0 da 10 	movl   $0xc010dad0,0xc(%esp)
c0108328:	c0 
c0108329:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108330:	c0 
c0108331:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0108338:	00 
c0108339:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108340:	e8 bb 80 ff ff       	call   c0100400 <__panic>
        int ret=0;
c0108345:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        void* kva_src = page2kva(page);
c010834c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010834f:	89 04 24             	mov    %eax,(%esp)
c0108352:	e8 f5 f0 ff ff       	call   c010744c <page2kva>
c0108357:	89 45 dc             	mov    %eax,-0x24(%ebp)
        void* kva_dst = page2kva(npage);
c010835a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010835d:	89 04 24             	mov    %eax,(%esp)
c0108360:	e8 e7 f0 ff ff       	call   c010744c <page2kva>
c0108365:	89 45 d8             	mov    %eax,-0x28(%ebp)
        memcpy(kva_dst, kva_src, PGSIZE);
c0108368:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010836f:	00 
c0108370:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108373:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108377:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010837a:	89 04 24             	mov    %eax,(%esp)
c010837d:	e8 9e 34 00 00       	call   c010b820 <memcpy>
        ret = page_insert(to, npage, start, perm);
c0108382:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108385:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108389:	8b 45 10             	mov    0x10(%ebp),%eax
c010838c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108390:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108393:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108397:	8b 45 08             	mov    0x8(%ebp),%eax
c010839a:	89 04 24             	mov    %eax,(%esp)
c010839d:	e8 92 00 00 00       	call   c0108434 <page_insert>
c01083a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ret == 0);
c01083a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01083a9:	74 24                	je     c01083cf <copy_range+0x203>
c01083ab:	c7 44 24 0c dc da 10 	movl   $0xc010dadc,0xc(%esp)
c01083b2:	c0 
c01083b3:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01083ba:	c0 
c01083bb:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c01083c2:	00 
c01083c3:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01083ca:	e8 31 80 ff ff       	call   c0100400 <__panic>
        }
        start += PGSIZE;
c01083cf:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c01083d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01083da:	74 0c                	je     c01083e8 <copy_range+0x21c>
c01083dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01083df:	3b 45 14             	cmp    0x14(%ebp),%eax
c01083e2:	0f 82 64 fe ff ff    	jb     c010824c <copy_range+0x80>
    return 0;
c01083e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01083ed:	c9                   	leave  
c01083ee:	c3                   	ret    

c01083ef <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01083ef:	55                   	push   %ebp
c01083f0:	89 e5                	mov    %esp,%ebp
c01083f2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01083f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01083fc:	00 
c01083fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108400:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108404:	8b 45 08             	mov    0x8(%ebp),%eax
c0108407:	89 04 24             	mov    %eax,(%esp)
c010840a:	e8 cc f9 ff ff       	call   c0107ddb <get_pte>
c010840f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0108412:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108416:	74 19                	je     c0108431 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010841b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010841f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108422:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108426:	8b 45 08             	mov    0x8(%ebp),%eax
c0108429:	89 04 24             	mov    %eax,(%esp)
c010842c:	e8 3c fb ff ff       	call   c0107f6d <page_remove_pte>
    }
}
c0108431:	90                   	nop
c0108432:	c9                   	leave  
c0108433:	c3                   	ret    

c0108434 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0108434:	55                   	push   %ebp
c0108435:	89 e5                	mov    %esp,%ebp
c0108437:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010843a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108441:	00 
c0108442:	8b 45 10             	mov    0x10(%ebp),%eax
c0108445:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108449:	8b 45 08             	mov    0x8(%ebp),%eax
c010844c:	89 04 24             	mov    %eax,(%esp)
c010844f:	e8 87 f9 ff ff       	call   c0107ddb <get_pte>
c0108454:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0108457:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010845b:	75 0a                	jne    c0108467 <page_insert+0x33>
        return -E_NO_MEM;
c010845d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108462:	e9 84 00 00 00       	jmp    c01084eb <page_insert+0xb7>
    }
    page_ref_inc(page);
c0108467:	8b 45 0c             	mov    0xc(%ebp),%eax
c010846a:	89 04 24             	mov    %eax,(%esp)
c010846d:	e8 9c f0 ff ff       	call   c010750e <page_ref_inc>
    if (*ptep & PTE_P) {
c0108472:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108475:	8b 00                	mov    (%eax),%eax
c0108477:	83 e0 01             	and    $0x1,%eax
c010847a:	85 c0                	test   %eax,%eax
c010847c:	74 3e                	je     c01084bc <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010847e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108481:	8b 00                	mov    (%eax),%eax
c0108483:	89 04 24             	mov    %eax,(%esp)
c0108486:	e8 15 f0 ff ff       	call   c01074a0 <pte2page>
c010848b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010848e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108491:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108494:	75 0d                	jne    c01084a3 <page_insert+0x6f>
            page_ref_dec(page);
c0108496:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108499:	89 04 24             	mov    %eax,(%esp)
c010849c:	e8 84 f0 ff ff       	call   c0107525 <page_ref_dec>
c01084a1:	eb 19                	jmp    c01084bc <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01084a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084a6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01084aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01084ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01084b4:	89 04 24             	mov    %eax,(%esp)
c01084b7:	e8 b1 fa ff ff       	call   c0107f6d <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01084bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084bf:	89 04 24             	mov    %eax,(%esp)
c01084c2:	e8 2a ef ff ff       	call   c01073f1 <page2pa>
c01084c7:	0b 45 14             	or     0x14(%ebp),%eax
c01084ca:	83 c8 01             	or     $0x1,%eax
c01084cd:	89 c2                	mov    %eax,%edx
c01084cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084d2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01084d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01084d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084db:	8b 45 08             	mov    0x8(%ebp),%eax
c01084de:	89 04 24             	mov    %eax,(%esp)
c01084e1:	e8 07 00 00 00       	call   c01084ed <tlb_invalidate>
    return 0;
c01084e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01084eb:	c9                   	leave  
c01084ec:	c3                   	ret    

c01084ed <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01084ed:	55                   	push   %ebp
c01084ee:	89 e5                	mov    %esp,%ebp
c01084f0:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01084f3:	0f 20 d8             	mov    %cr3,%eax
c01084f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01084f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01084fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01084ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108502:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0108509:	77 23                	ja     c010852e <tlb_invalidate+0x41>
c010850b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010850e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108512:	c7 44 24 08 00 da 10 	movl   $0xc010da00,0x8(%esp)
c0108519:	c0 
c010851a:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0108521:	00 
c0108522:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108529:	e8 d2 7e ff ff       	call   c0100400 <__panic>
c010852e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108531:	05 00 00 00 40       	add    $0x40000000,%eax
c0108536:	39 d0                	cmp    %edx,%eax
c0108538:	75 0c                	jne    c0108546 <tlb_invalidate+0x59>
        invlpg((void *)la);
c010853a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010853d:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0108540:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108543:	0f 01 38             	invlpg (%eax)
    }
}
c0108546:	90                   	nop
c0108547:	c9                   	leave  
c0108548:	c3                   	ret    

c0108549 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0108549:	55                   	push   %ebp
c010854a:	89 e5                	mov    %esp,%ebp
c010854c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c010854f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108556:	e8 a0 f1 ff ff       	call   c01076fb <alloc_pages>
c010855b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010855e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108562:	0f 84 b0 00 00 00    	je     c0108618 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0108568:	8b 45 10             	mov    0x10(%ebp),%eax
c010856b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010856f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108572:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108576:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108579:	89 44 24 04          	mov    %eax,0x4(%esp)
c010857d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108580:	89 04 24             	mov    %eax,(%esp)
c0108583:	e8 ac fe ff ff       	call   c0108434 <page_insert>
c0108588:	85 c0                	test   %eax,%eax
c010858a:	74 1a                	je     c01085a6 <pgdir_alloc_page+0x5d>
            free_page(page);
c010858c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108593:	00 
c0108594:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108597:	89 04 24             	mov    %eax,(%esp)
c010859a:	e8 c7 f1 ff ff       	call   c0107766 <free_pages>
            return NULL;
c010859f:	b8 00 00 00 00       	mov    $0x0,%eax
c01085a4:	eb 75                	jmp    c010861b <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c01085a6:	a1 6c ff 19 c0       	mov    0xc019ff6c,%eax
c01085ab:	85 c0                	test   %eax,%eax
c01085ad:	74 69                	je     c0108618 <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c01085af:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c01085b4:	85 c0                	test   %eax,%eax
c01085b6:	74 60                	je     c0108618 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c01085b8:	a1 58 20 1a c0       	mov    0xc01a2058,%eax
c01085bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01085c4:	00 
c01085c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085c8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01085cc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01085cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085d3:	89 04 24             	mov    %eax,(%esp)
c01085d6:	e8 29 d1 ff ff       	call   c0105704 <swap_map_swappable>
                page->pra_vaddr=la;
c01085db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01085e1:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c01085e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085e7:	89 04 24             	mov    %eax,(%esp)
c01085ea:	e8 07 ef ff ff       	call   c01074f6 <page_ref>
c01085ef:	83 f8 01             	cmp    $0x1,%eax
c01085f2:	74 24                	je     c0108618 <pgdir_alloc_page+0xcf>
c01085f4:	c7 44 24 0c e5 da 10 	movl   $0xc010dae5,0xc(%esp)
c01085fb:	c0 
c01085fc:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108603:	c0 
c0108604:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c010860b:	00 
c010860c:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108613:	e8 e8 7d ff ff       	call   c0100400 <__panic>
            }
        }

    }

    return page;
c0108618:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010861b:	c9                   	leave  
c010861c:	c3                   	ret    

c010861d <check_alloc_page>:

static void
check_alloc_page(void) {
c010861d:	55                   	push   %ebp
c010861e:	89 e5                	mov    %esp,%ebp
c0108620:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0108623:	a1 50 21 1a c0       	mov    0xc01a2150,%eax
c0108628:	8b 40 18             	mov    0x18(%eax),%eax
c010862b:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010862d:	c7 04 24 fc da 10 c0 	movl   $0xc010dafc,(%esp)
c0108634:	e8 70 7c ff ff       	call   c01002a9 <cprintf>
}
c0108639:	90                   	nop
c010863a:	c9                   	leave  
c010863b:	c3                   	ret    

c010863c <check_pgdir>:

static void
check_pgdir(void) {
c010863c:	55                   	push   %ebp
c010863d:	89 e5                	mov    %esp,%ebp
c010863f:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0108642:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0108647:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010864c:	76 24                	jbe    c0108672 <check_pgdir+0x36>
c010864e:	c7 44 24 0c 1b db 10 	movl   $0xc010db1b,0xc(%esp)
c0108655:	c0 
c0108656:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c010865d:	c0 
c010865e:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c0108665:	00 
c0108666:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010866d:	e8 8e 7d ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0108672:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108677:	85 c0                	test   %eax,%eax
c0108679:	74 0e                	je     c0108689 <check_pgdir+0x4d>
c010867b:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108680:	25 ff 0f 00 00       	and    $0xfff,%eax
c0108685:	85 c0                	test   %eax,%eax
c0108687:	74 24                	je     c01086ad <check_pgdir+0x71>
c0108689:	c7 44 24 0c 38 db 10 	movl   $0xc010db38,0xc(%esp)
c0108690:	c0 
c0108691:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108698:	c0 
c0108699:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c01086a0:	00 
c01086a1:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01086a8:	e8 53 7d ff ff       	call   c0100400 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01086ad:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c01086b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01086b9:	00 
c01086ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01086c1:	00 
c01086c2:	89 04 24             	mov    %eax,(%esp)
c01086c5:	e8 4a f8 ff ff       	call   c0107f14 <get_page>
c01086ca:	85 c0                	test   %eax,%eax
c01086cc:	74 24                	je     c01086f2 <check_pgdir+0xb6>
c01086ce:	c7 44 24 0c 70 db 10 	movl   $0xc010db70,0xc(%esp)
c01086d5:	c0 
c01086d6:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01086dd:	c0 
c01086de:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c01086e5:	00 
c01086e6:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01086ed:	e8 0e 7d ff ff       	call   c0100400 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01086f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01086f9:	e8 fd ef ff ff       	call   c01076fb <alloc_pages>
c01086fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0108701:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108706:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010870d:	00 
c010870e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108715:	00 
c0108716:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108719:	89 54 24 04          	mov    %edx,0x4(%esp)
c010871d:	89 04 24             	mov    %eax,(%esp)
c0108720:	e8 0f fd ff ff       	call   c0108434 <page_insert>
c0108725:	85 c0                	test   %eax,%eax
c0108727:	74 24                	je     c010874d <check_pgdir+0x111>
c0108729:	c7 44 24 0c 98 db 10 	movl   $0xc010db98,0xc(%esp)
c0108730:	c0 
c0108731:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108738:	c0 
c0108739:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
c0108740:	00 
c0108741:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108748:	e8 b3 7c ff ff       	call   c0100400 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010874d:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108752:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108759:	00 
c010875a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108761:	00 
c0108762:	89 04 24             	mov    %eax,(%esp)
c0108765:	e8 71 f6 ff ff       	call   c0107ddb <get_pte>
c010876a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010876d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108771:	75 24                	jne    c0108797 <check_pgdir+0x15b>
c0108773:	c7 44 24 0c c4 db 10 	movl   $0xc010dbc4,0xc(%esp)
c010877a:	c0 
c010877b:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108782:	c0 
c0108783:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
c010878a:	00 
c010878b:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108792:	e8 69 7c ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c0108797:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010879a:	8b 00                	mov    (%eax),%eax
c010879c:	89 04 24             	mov    %eax,(%esp)
c010879f:	e8 fc ec ff ff       	call   c01074a0 <pte2page>
c01087a4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01087a7:	74 24                	je     c01087cd <check_pgdir+0x191>
c01087a9:	c7 44 24 0c f1 db 10 	movl   $0xc010dbf1,0xc(%esp)
c01087b0:	c0 
c01087b1:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01087b8:	c0 
c01087b9:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c01087c0:	00 
c01087c1:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01087c8:	e8 33 7c ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 1);
c01087cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087d0:	89 04 24             	mov    %eax,(%esp)
c01087d3:	e8 1e ed ff ff       	call   c01074f6 <page_ref>
c01087d8:	83 f8 01             	cmp    $0x1,%eax
c01087db:	74 24                	je     c0108801 <check_pgdir+0x1c5>
c01087dd:	c7 44 24 0c 07 dc 10 	movl   $0xc010dc07,0xc(%esp)
c01087e4:	c0 
c01087e5:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01087ec:	c0 
c01087ed:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c01087f4:	00 
c01087f5:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01087fc:	e8 ff 7b ff ff       	call   c0100400 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0108801:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108806:	8b 00                	mov    (%eax),%eax
c0108808:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010880d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108810:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108813:	c1 e8 0c             	shr    $0xc,%eax
c0108816:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108819:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c010881e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108821:	72 23                	jb     c0108846 <check_pgdir+0x20a>
c0108823:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108826:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010882a:	c7 44 24 08 5c d9 10 	movl   $0xc010d95c,0x8(%esp)
c0108831:	c0 
c0108832:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
c0108839:	00 
c010883a:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108841:	e8 ba 7b ff ff       	call   c0100400 <__panic>
c0108846:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108849:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010884e:	83 c0 04             	add    $0x4,%eax
c0108851:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0108854:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108859:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108860:	00 
c0108861:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108868:	00 
c0108869:	89 04 24             	mov    %eax,(%esp)
c010886c:	e8 6a f5 ff ff       	call   c0107ddb <get_pte>
c0108871:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108874:	74 24                	je     c010889a <check_pgdir+0x25e>
c0108876:	c7 44 24 0c 1c dc 10 	movl   $0xc010dc1c,0xc(%esp)
c010887d:	c0 
c010887e:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108885:	c0 
c0108886:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
c010888d:	00 
c010888e:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108895:	e8 66 7b ff ff       	call   c0100400 <__panic>

    p2 = alloc_page();
c010889a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01088a1:	e8 55 ee ff ff       	call   c01076fb <alloc_pages>
c01088a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01088a9:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c01088ae:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01088b5:	00 
c01088b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01088bd:	00 
c01088be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01088c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01088c5:	89 04 24             	mov    %eax,(%esp)
c01088c8:	e8 67 fb ff ff       	call   c0108434 <page_insert>
c01088cd:	85 c0                	test   %eax,%eax
c01088cf:	74 24                	je     c01088f5 <check_pgdir+0x2b9>
c01088d1:	c7 44 24 0c 44 dc 10 	movl   $0xc010dc44,0xc(%esp)
c01088d8:	c0 
c01088d9:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01088e0:	c0 
c01088e1:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
c01088e8:	00 
c01088e9:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01088f0:	e8 0b 7b ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01088f5:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c01088fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108901:	00 
c0108902:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108909:	00 
c010890a:	89 04 24             	mov    %eax,(%esp)
c010890d:	e8 c9 f4 ff ff       	call   c0107ddb <get_pte>
c0108912:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108915:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108919:	75 24                	jne    c010893f <check_pgdir+0x303>
c010891b:	c7 44 24 0c 7c dc 10 	movl   $0xc010dc7c,0xc(%esp)
c0108922:	c0 
c0108923:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c010892a:	c0 
c010892b:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
c0108932:	00 
c0108933:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010893a:	e8 c1 7a ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_U);
c010893f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108942:	8b 00                	mov    (%eax),%eax
c0108944:	83 e0 04             	and    $0x4,%eax
c0108947:	85 c0                	test   %eax,%eax
c0108949:	75 24                	jne    c010896f <check_pgdir+0x333>
c010894b:	c7 44 24 0c ac dc 10 	movl   $0xc010dcac,0xc(%esp)
c0108952:	c0 
c0108953:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c010895a:	c0 
c010895b:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c0108962:	00 
c0108963:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010896a:	e8 91 7a ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_W);
c010896f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108972:	8b 00                	mov    (%eax),%eax
c0108974:	83 e0 02             	and    $0x2,%eax
c0108977:	85 c0                	test   %eax,%eax
c0108979:	75 24                	jne    c010899f <check_pgdir+0x363>
c010897b:	c7 44 24 0c ba dc 10 	movl   $0xc010dcba,0xc(%esp)
c0108982:	c0 
c0108983:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c010898a:	c0 
c010898b:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c0108992:	00 
c0108993:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c010899a:	e8 61 7a ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010899f:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c01089a4:	8b 00                	mov    (%eax),%eax
c01089a6:	83 e0 04             	and    $0x4,%eax
c01089a9:	85 c0                	test   %eax,%eax
c01089ab:	75 24                	jne    c01089d1 <check_pgdir+0x395>
c01089ad:	c7 44 24 0c c8 dc 10 	movl   $0xc010dcc8,0xc(%esp)
c01089b4:	c0 
c01089b5:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01089bc:	c0 
c01089bd:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c01089c4:	00 
c01089c5:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c01089cc:	e8 2f 7a ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 1);
c01089d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01089d4:	89 04 24             	mov    %eax,(%esp)
c01089d7:	e8 1a eb ff ff       	call   c01074f6 <page_ref>
c01089dc:	83 f8 01             	cmp    $0x1,%eax
c01089df:	74 24                	je     c0108a05 <check_pgdir+0x3c9>
c01089e1:	c7 44 24 0c de dc 10 	movl   $0xc010dcde,0xc(%esp)
c01089e8:	c0 
c01089e9:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c01089f0:	c0 
c01089f1:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
c01089f8:	00 
c01089f9:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108a00:	e8 fb 79 ff ff       	call   c0100400 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0108a05:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108a0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0108a11:	00 
c0108a12:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0108a19:	00 
c0108a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a1d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108a21:	89 04 24             	mov    %eax,(%esp)
c0108a24:	e8 0b fa ff ff       	call   c0108434 <page_insert>
c0108a29:	85 c0                	test   %eax,%eax
c0108a2b:	74 24                	je     c0108a51 <check_pgdir+0x415>
c0108a2d:	c7 44 24 0c f0 dc 10 	movl   $0xc010dcf0,0xc(%esp)
c0108a34:	c0 
c0108a35:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108a3c:	c0 
c0108a3d:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
c0108a44:	00 
c0108a45:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108a4c:	e8 af 79 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 2);
c0108a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a54:	89 04 24             	mov    %eax,(%esp)
c0108a57:	e8 9a ea ff ff       	call   c01074f6 <page_ref>
c0108a5c:	83 f8 02             	cmp    $0x2,%eax
c0108a5f:	74 24                	je     c0108a85 <check_pgdir+0x449>
c0108a61:	c7 44 24 0c 1c dd 10 	movl   $0xc010dd1c,0xc(%esp)
c0108a68:	c0 
c0108a69:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108a70:	c0 
c0108a71:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c0108a78:	00 
c0108a79:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108a80:	e8 7b 79 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0108a85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a88:	89 04 24             	mov    %eax,(%esp)
c0108a8b:	e8 66 ea ff ff       	call   c01074f6 <page_ref>
c0108a90:	85 c0                	test   %eax,%eax
c0108a92:	74 24                	je     c0108ab8 <check_pgdir+0x47c>
c0108a94:	c7 44 24 0c 2e dd 10 	movl   $0xc010dd2e,0xc(%esp)
c0108a9b:	c0 
c0108a9c:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108aa3:	c0 
c0108aa4:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c0108aab:	00 
c0108aac:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108ab3:	e8 48 79 ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0108ab8:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108abd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108ac4:	00 
c0108ac5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108acc:	00 
c0108acd:	89 04 24             	mov    %eax,(%esp)
c0108ad0:	e8 06 f3 ff ff       	call   c0107ddb <get_pte>
c0108ad5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ad8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108adc:	75 24                	jne    c0108b02 <check_pgdir+0x4c6>
c0108ade:	c7 44 24 0c 7c dc 10 	movl   $0xc010dc7c,0xc(%esp)
c0108ae5:	c0 
c0108ae6:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108aed:	c0 
c0108aee:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
c0108af5:	00 
c0108af6:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108afd:	e8 fe 78 ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c0108b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b05:	8b 00                	mov    (%eax),%eax
c0108b07:	89 04 24             	mov    %eax,(%esp)
c0108b0a:	e8 91 e9 ff ff       	call   c01074a0 <pte2page>
c0108b0f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108b12:	74 24                	je     c0108b38 <check_pgdir+0x4fc>
c0108b14:	c7 44 24 0c f1 db 10 	movl   $0xc010dbf1,0xc(%esp)
c0108b1b:	c0 
c0108b1c:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108b23:	c0 
c0108b24:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c0108b2b:	00 
c0108b2c:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108b33:	e8 c8 78 ff ff       	call   c0100400 <__panic>
    assert((*ptep & PTE_U) == 0);
c0108b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b3b:	8b 00                	mov    (%eax),%eax
c0108b3d:	83 e0 04             	and    $0x4,%eax
c0108b40:	85 c0                	test   %eax,%eax
c0108b42:	74 24                	je     c0108b68 <check_pgdir+0x52c>
c0108b44:	c7 44 24 0c 40 dd 10 	movl   $0xc010dd40,0xc(%esp)
c0108b4b:	c0 
c0108b4c:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108b53:	c0 
c0108b54:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c0108b5b:	00 
c0108b5c:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108b63:	e8 98 78 ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, 0x0);
c0108b68:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108b6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108b74:	00 
c0108b75:	89 04 24             	mov    %eax,(%esp)
c0108b78:	e8 72 f8 ff ff       	call   c01083ef <page_remove>
    assert(page_ref(p1) == 1);
c0108b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b80:	89 04 24             	mov    %eax,(%esp)
c0108b83:	e8 6e e9 ff ff       	call   c01074f6 <page_ref>
c0108b88:	83 f8 01             	cmp    $0x1,%eax
c0108b8b:	74 24                	je     c0108bb1 <check_pgdir+0x575>
c0108b8d:	c7 44 24 0c 07 dc 10 	movl   $0xc010dc07,0xc(%esp)
c0108b94:	c0 
c0108b95:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108b9c:	c0 
c0108b9d:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
c0108ba4:	00 
c0108ba5:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108bac:	e8 4f 78 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0108bb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bb4:	89 04 24             	mov    %eax,(%esp)
c0108bb7:	e8 3a e9 ff ff       	call   c01074f6 <page_ref>
c0108bbc:	85 c0                	test   %eax,%eax
c0108bbe:	74 24                	je     c0108be4 <check_pgdir+0x5a8>
c0108bc0:	c7 44 24 0c 2e dd 10 	movl   $0xc010dd2e,0xc(%esp)
c0108bc7:	c0 
c0108bc8:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108bcf:	c0 
c0108bd0:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
c0108bd7:	00 
c0108bd8:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108bdf:	e8 1c 78 ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0108be4:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108be9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108bf0:	00 
c0108bf1:	89 04 24             	mov    %eax,(%esp)
c0108bf4:	e8 f6 f7 ff ff       	call   c01083ef <page_remove>
    assert(page_ref(p1) == 0);
c0108bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bfc:	89 04 24             	mov    %eax,(%esp)
c0108bff:	e8 f2 e8 ff ff       	call   c01074f6 <page_ref>
c0108c04:	85 c0                	test   %eax,%eax
c0108c06:	74 24                	je     c0108c2c <check_pgdir+0x5f0>
c0108c08:	c7 44 24 0c 55 dd 10 	movl   $0xc010dd55,0xc(%esp)
c0108c0f:	c0 
c0108c10:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108c17:	c0 
c0108c18:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
c0108c1f:	00 
c0108c20:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108c27:	e8 d4 77 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0108c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c2f:	89 04 24             	mov    %eax,(%esp)
c0108c32:	e8 bf e8 ff ff       	call   c01074f6 <page_ref>
c0108c37:	85 c0                	test   %eax,%eax
c0108c39:	74 24                	je     c0108c5f <check_pgdir+0x623>
c0108c3b:	c7 44 24 0c 2e dd 10 	movl   $0xc010dd2e,0xc(%esp)
c0108c42:	c0 
c0108c43:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108c4a:	c0 
c0108c4b:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
c0108c52:	00 
c0108c53:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108c5a:	e8 a1 77 ff ff       	call   c0100400 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0108c5f:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108c64:	8b 00                	mov    (%eax),%eax
c0108c66:	89 04 24             	mov    %eax,(%esp)
c0108c69:	e8 70 e8 ff ff       	call   c01074de <pde2page>
c0108c6e:	89 04 24             	mov    %eax,(%esp)
c0108c71:	e8 80 e8 ff ff       	call   c01074f6 <page_ref>
c0108c76:	83 f8 01             	cmp    $0x1,%eax
c0108c79:	74 24                	je     c0108c9f <check_pgdir+0x663>
c0108c7b:	c7 44 24 0c 68 dd 10 	movl   $0xc010dd68,0xc(%esp)
c0108c82:	c0 
c0108c83:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108c8a:	c0 
c0108c8b:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
c0108c92:	00 
c0108c93:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108c9a:	e8 61 77 ff ff       	call   c0100400 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0108c9f:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108ca4:	8b 00                	mov    (%eax),%eax
c0108ca6:	89 04 24             	mov    %eax,(%esp)
c0108ca9:	e8 30 e8 ff ff       	call   c01074de <pde2page>
c0108cae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108cb5:	00 
c0108cb6:	89 04 24             	mov    %eax,(%esp)
c0108cb9:	e8 a8 ea ff ff       	call   c0107766 <free_pages>
    boot_pgdir[0] = 0;
c0108cbe:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108cc3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0108cc9:	c7 04 24 8f dd 10 c0 	movl   $0xc010dd8f,(%esp)
c0108cd0:	e8 d4 75 ff ff       	call   c01002a9 <cprintf>
}
c0108cd5:	90                   	nop
c0108cd6:	c9                   	leave  
c0108cd7:	c3                   	ret    

c0108cd8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0108cd8:	55                   	push   %ebp
c0108cd9:	89 e5                	mov    %esp,%ebp
c0108cdb:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108cde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ce5:	e9 ca 00 00 00       	jmp    c0108db4 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0108cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ced:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108cf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108cf3:	c1 e8 0c             	shr    $0xc,%eax
c0108cf6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108cf9:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0108cfe:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108d01:	72 23                	jb     c0108d26 <check_boot_pgdir+0x4e>
c0108d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d06:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108d0a:	c7 44 24 08 5c d9 10 	movl   $0xc010d95c,0x8(%esp)
c0108d11:	c0 
c0108d12:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
c0108d19:	00 
c0108d1a:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108d21:	e8 da 76 ff ff       	call   c0100400 <__panic>
c0108d26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d29:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108d2e:	89 c2                	mov    %eax,%edx
c0108d30:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108d35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108d3c:	00 
c0108d3d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108d41:	89 04 24             	mov    %eax,(%esp)
c0108d44:	e8 92 f0 ff ff       	call   c0107ddb <get_pte>
c0108d49:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108d4c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108d50:	75 24                	jne    c0108d76 <check_boot_pgdir+0x9e>
c0108d52:	c7 44 24 0c ac dd 10 	movl   $0xc010ddac,0xc(%esp)
c0108d59:	c0 
c0108d5a:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108d61:	c0 
c0108d62:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
c0108d69:	00 
c0108d6a:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108d71:	e8 8a 76 ff ff       	call   c0100400 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0108d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d79:	8b 00                	mov    (%eax),%eax
c0108d7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108d80:	89 c2                	mov    %eax,%edx
c0108d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d85:	39 c2                	cmp    %eax,%edx
c0108d87:	74 24                	je     c0108dad <check_boot_pgdir+0xd5>
c0108d89:	c7 44 24 0c e9 dd 10 	movl   $0xc010dde9,0xc(%esp)
c0108d90:	c0 
c0108d91:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108d98:	c0 
c0108d99:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
c0108da0:	00 
c0108da1:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108da8:	e8 53 76 ff ff       	call   c0100400 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0108dad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0108db4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108db7:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0108dbc:	39 c2                	cmp    %eax,%edx
c0108dbe:	0f 82 26 ff ff ff    	jb     c0108cea <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0108dc4:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108dc9:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108dce:	8b 00                	mov    (%eax),%eax
c0108dd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108dd5:	89 c2                	mov    %eax,%edx
c0108dd7:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ddf:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108de6:	77 23                	ja     c0108e0b <check_boot_pgdir+0x133>
c0108de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108deb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108def:	c7 44 24 08 00 da 10 	movl   $0xc010da00,0x8(%esp)
c0108df6:	c0 
c0108df7:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c0108dfe:	00 
c0108dff:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108e06:	e8 f5 75 ff ff       	call   c0100400 <__panic>
c0108e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e0e:	05 00 00 00 40       	add    $0x40000000,%eax
c0108e13:	39 d0                	cmp    %edx,%eax
c0108e15:	74 24                	je     c0108e3b <check_boot_pgdir+0x163>
c0108e17:	c7 44 24 0c 00 de 10 	movl   $0xc010de00,0xc(%esp)
c0108e1e:	c0 
c0108e1f:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108e26:	c0 
c0108e27:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c0108e2e:	00 
c0108e2f:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108e36:	e8 c5 75 ff ff       	call   c0100400 <__panic>

    assert(boot_pgdir[0] == 0);
c0108e3b:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108e40:	8b 00                	mov    (%eax),%eax
c0108e42:	85 c0                	test   %eax,%eax
c0108e44:	74 24                	je     c0108e6a <check_boot_pgdir+0x192>
c0108e46:	c7 44 24 0c 34 de 10 	movl   $0xc010de34,0xc(%esp)
c0108e4d:	c0 
c0108e4e:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108e55:	c0 
c0108e56:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0108e5d:	00 
c0108e5e:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108e65:	e8 96 75 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    p = alloc_page();
c0108e6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108e71:	e8 85 e8 ff ff       	call   c01076fb <alloc_pages>
c0108e76:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0108e79:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108e7e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108e85:	00 
c0108e86:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0108e8d:	00 
c0108e8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108e91:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108e95:	89 04 24             	mov    %eax,(%esp)
c0108e98:	e8 97 f5 ff ff       	call   c0108434 <page_insert>
c0108e9d:	85 c0                	test   %eax,%eax
c0108e9f:	74 24                	je     c0108ec5 <check_boot_pgdir+0x1ed>
c0108ea1:	c7 44 24 0c 48 de 10 	movl   $0xc010de48,0xc(%esp)
c0108ea8:	c0 
c0108ea9:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108eb0:	c0 
c0108eb1:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
c0108eb8:	00 
c0108eb9:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108ec0:	e8 3b 75 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 1);
c0108ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ec8:	89 04 24             	mov    %eax,(%esp)
c0108ecb:	e8 26 e6 ff ff       	call   c01074f6 <page_ref>
c0108ed0:	83 f8 01             	cmp    $0x1,%eax
c0108ed3:	74 24                	je     c0108ef9 <check_boot_pgdir+0x221>
c0108ed5:	c7 44 24 0c 76 de 10 	movl   $0xc010de76,0xc(%esp)
c0108edc:	c0 
c0108edd:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108ee4:	c0 
c0108ee5:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
c0108eec:	00 
c0108eed:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108ef4:	e8 07 75 ff ff       	call   c0100400 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0108ef9:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0108efe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108f05:	00 
c0108f06:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0108f0d:	00 
c0108f0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108f11:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f15:	89 04 24             	mov    %eax,(%esp)
c0108f18:	e8 17 f5 ff ff       	call   c0108434 <page_insert>
c0108f1d:	85 c0                	test   %eax,%eax
c0108f1f:	74 24                	je     c0108f45 <check_boot_pgdir+0x26d>
c0108f21:	c7 44 24 0c 88 de 10 	movl   $0xc010de88,0xc(%esp)
c0108f28:	c0 
c0108f29:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108f30:	c0 
c0108f31:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
c0108f38:	00 
c0108f39:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108f40:	e8 bb 74 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 2);
c0108f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f48:	89 04 24             	mov    %eax,(%esp)
c0108f4b:	e8 a6 e5 ff ff       	call   c01074f6 <page_ref>
c0108f50:	83 f8 02             	cmp    $0x2,%eax
c0108f53:	74 24                	je     c0108f79 <check_boot_pgdir+0x2a1>
c0108f55:	c7 44 24 0c bf de 10 	movl   $0xc010debf,0xc(%esp)
c0108f5c:	c0 
c0108f5d:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108f64:	c0 
c0108f65:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0108f6c:	00 
c0108f6d:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108f74:	e8 87 74 ff ff       	call   c0100400 <__panic>

    const char *str = "ucore: Hello world!!";
c0108f79:	c7 45 e8 d0 de 10 c0 	movl   $0xc010ded0,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0108f80:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f87:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108f8e:	e8 e0 24 00 00       	call   c010b473 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108f93:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0108f9a:	00 
c0108f9b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108fa2:	e8 43 25 00 00       	call   c010b4ea <strcmp>
c0108fa7:	85 c0                	test   %eax,%eax
c0108fa9:	74 24                	je     c0108fcf <check_boot_pgdir+0x2f7>
c0108fab:	c7 44 24 0c e8 de 10 	movl   $0xc010dee8,0xc(%esp)
c0108fb2:	c0 
c0108fb3:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0108fba:	c0 
c0108fbb:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
c0108fc2:	00 
c0108fc3:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0108fca:	e8 31 74 ff ff       	call   c0100400 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108fd2:	89 04 24             	mov    %eax,(%esp)
c0108fd5:	e8 72 e4 ff ff       	call   c010744c <page2kva>
c0108fda:	05 00 01 00 00       	add    $0x100,%eax
c0108fdf:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108fe2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108fe9:	e8 2f 24 00 00       	call   c010b41d <strlen>
c0108fee:	85 c0                	test   %eax,%eax
c0108ff0:	74 24                	je     c0109016 <check_boot_pgdir+0x33e>
c0108ff2:	c7 44 24 0c 20 df 10 	movl   $0xc010df20,0xc(%esp)
c0108ff9:	c0 
c0108ffa:	c7 44 24 08 49 da 10 	movl   $0xc010da49,0x8(%esp)
c0109001:	c0 
c0109002:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
c0109009:	00 
c010900a:	c7 04 24 24 da 10 c0 	movl   $0xc010da24,(%esp)
c0109011:	e8 ea 73 ff ff       	call   c0100400 <__panic>

    free_page(p);
c0109016:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010901d:	00 
c010901e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109021:	89 04 24             	mov    %eax,(%esp)
c0109024:	e8 3d e7 ff ff       	call   c0107766 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0109029:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c010902e:	8b 00                	mov    (%eax),%eax
c0109030:	89 04 24             	mov    %eax,(%esp)
c0109033:	e8 a6 e4 ff ff       	call   c01074de <pde2page>
c0109038:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010903f:	00 
c0109040:	89 04 24             	mov    %eax,(%esp)
c0109043:	e8 1e e7 ff ff       	call   c0107766 <free_pages>
    boot_pgdir[0] = 0;
c0109048:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c010904d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0109053:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010905a:	e8 4a 72 ff ff       	call   c01002a9 <cprintf>
}
c010905f:	90                   	nop
c0109060:	c9                   	leave  
c0109061:	c3                   	ret    

c0109062 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0109062:	55                   	push   %ebp
c0109063:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0109065:	8b 45 08             	mov    0x8(%ebp),%eax
c0109068:	83 e0 04             	and    $0x4,%eax
c010906b:	85 c0                	test   %eax,%eax
c010906d:	74 04                	je     c0109073 <perm2str+0x11>
c010906f:	b0 75                	mov    $0x75,%al
c0109071:	eb 02                	jmp    c0109075 <perm2str+0x13>
c0109073:	b0 2d                	mov    $0x2d,%al
c0109075:	a2 08 00 1a c0       	mov    %al,0xc01a0008
    str[1] = 'r';
c010907a:	c6 05 09 00 1a c0 72 	movb   $0x72,0xc01a0009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0109081:	8b 45 08             	mov    0x8(%ebp),%eax
c0109084:	83 e0 02             	and    $0x2,%eax
c0109087:	85 c0                	test   %eax,%eax
c0109089:	74 04                	je     c010908f <perm2str+0x2d>
c010908b:	b0 77                	mov    $0x77,%al
c010908d:	eb 02                	jmp    c0109091 <perm2str+0x2f>
c010908f:	b0 2d                	mov    $0x2d,%al
c0109091:	a2 0a 00 1a c0       	mov    %al,0xc01a000a
    str[3] = '\0';
c0109096:	c6 05 0b 00 1a c0 00 	movb   $0x0,0xc01a000b
    return str;
c010909d:	b8 08 00 1a c0       	mov    $0xc01a0008,%eax
}
c01090a2:	5d                   	pop    %ebp
c01090a3:	c3                   	ret    

c01090a4 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01090a4:	55                   	push   %ebp
c01090a5:	89 e5                	mov    %esp,%ebp
c01090a7:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01090aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01090ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01090b0:	72 0d                	jb     c01090bf <get_pgtable_items+0x1b>
        return 0;
c01090b2:	b8 00 00 00 00       	mov    $0x0,%eax
c01090b7:	e9 98 00 00 00       	jmp    c0109154 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01090bc:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01090bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01090c2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01090c5:	73 18                	jae    c01090df <get_pgtable_items+0x3b>
c01090c7:	8b 45 10             	mov    0x10(%ebp),%eax
c01090ca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01090d1:	8b 45 14             	mov    0x14(%ebp),%eax
c01090d4:	01 d0                	add    %edx,%eax
c01090d6:	8b 00                	mov    (%eax),%eax
c01090d8:	83 e0 01             	and    $0x1,%eax
c01090db:	85 c0                	test   %eax,%eax
c01090dd:	74 dd                	je     c01090bc <get_pgtable_items+0x18>
    }
    if (start < right) {
c01090df:	8b 45 10             	mov    0x10(%ebp),%eax
c01090e2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01090e5:	73 68                	jae    c010914f <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01090e7:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01090eb:	74 08                	je     c01090f5 <get_pgtable_items+0x51>
            *left_store = start;
c01090ed:	8b 45 18             	mov    0x18(%ebp),%eax
c01090f0:	8b 55 10             	mov    0x10(%ebp),%edx
c01090f3:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01090f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01090f8:	8d 50 01             	lea    0x1(%eax),%edx
c01090fb:	89 55 10             	mov    %edx,0x10(%ebp)
c01090fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0109105:	8b 45 14             	mov    0x14(%ebp),%eax
c0109108:	01 d0                	add    %edx,%eax
c010910a:	8b 00                	mov    (%eax),%eax
c010910c:	83 e0 07             	and    $0x7,%eax
c010910f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0109112:	eb 03                	jmp    c0109117 <get_pgtable_items+0x73>
            start ++;
c0109114:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0109117:	8b 45 10             	mov    0x10(%ebp),%eax
c010911a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010911d:	73 1d                	jae    c010913c <get_pgtable_items+0x98>
c010911f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109122:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0109129:	8b 45 14             	mov    0x14(%ebp),%eax
c010912c:	01 d0                	add    %edx,%eax
c010912e:	8b 00                	mov    (%eax),%eax
c0109130:	83 e0 07             	and    $0x7,%eax
c0109133:	89 c2                	mov    %eax,%edx
c0109135:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109138:	39 c2                	cmp    %eax,%edx
c010913a:	74 d8                	je     c0109114 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c010913c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0109140:	74 08                	je     c010914a <get_pgtable_items+0xa6>
            *right_store = start;
c0109142:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0109145:	8b 55 10             	mov    0x10(%ebp),%edx
c0109148:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010914a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010914d:	eb 05                	jmp    c0109154 <get_pgtable_items+0xb0>
    }
    return 0;
c010914f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109154:	c9                   	leave  
c0109155:	c3                   	ret    

c0109156 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0109156:	55                   	push   %ebp
c0109157:	89 e5                	mov    %esp,%ebp
c0109159:	57                   	push   %edi
c010915a:	56                   	push   %esi
c010915b:	53                   	push   %ebx
c010915c:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010915f:	c7 04 24 64 df 10 c0 	movl   $0xc010df64,(%esp)
c0109166:	e8 3e 71 ff ff       	call   c01002a9 <cprintf>
    size_t left, right = 0, perm;
c010916b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0109172:	e9 fa 00 00 00       	jmp    c0109271 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0109177:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010917a:	89 04 24             	mov    %eax,(%esp)
c010917d:	e8 e0 fe ff ff       	call   c0109062 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0109182:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109185:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109188:	29 d1                	sub    %edx,%ecx
c010918a:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010918c:	89 d6                	mov    %edx,%esi
c010918e:	c1 e6 16             	shl    $0x16,%esi
c0109191:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109194:	89 d3                	mov    %edx,%ebx
c0109196:	c1 e3 16             	shl    $0x16,%ebx
c0109199:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010919c:	89 d1                	mov    %edx,%ecx
c010919e:	c1 e1 16             	shl    $0x16,%ecx
c01091a1:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01091a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01091a7:	29 d7                	sub    %edx,%edi
c01091a9:	89 fa                	mov    %edi,%edx
c01091ab:	89 44 24 14          	mov    %eax,0x14(%esp)
c01091af:	89 74 24 10          	mov    %esi,0x10(%esp)
c01091b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01091b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01091bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01091bf:	c7 04 24 95 df 10 c0 	movl   $0xc010df95,(%esp)
c01091c6:	e8 de 70 ff ff       	call   c01002a9 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01091cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01091ce:	c1 e0 0a             	shl    $0xa,%eax
c01091d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01091d4:	eb 54                	jmp    c010922a <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01091d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01091d9:	89 04 24             	mov    %eax,(%esp)
c01091dc:	e8 81 fe ff ff       	call   c0109062 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01091e1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01091e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01091e7:	29 d1                	sub    %edx,%ecx
c01091e9:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01091eb:	89 d6                	mov    %edx,%esi
c01091ed:	c1 e6 0c             	shl    $0xc,%esi
c01091f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01091f3:	89 d3                	mov    %edx,%ebx
c01091f5:	c1 e3 0c             	shl    $0xc,%ebx
c01091f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01091fb:	89 d1                	mov    %edx,%ecx
c01091fd:	c1 e1 0c             	shl    $0xc,%ecx
c0109200:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0109203:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0109206:	29 d7                	sub    %edx,%edi
c0109208:	89 fa                	mov    %edi,%edx
c010920a:	89 44 24 14          	mov    %eax,0x14(%esp)
c010920e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0109212:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0109216:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010921a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010921e:	c7 04 24 b4 df 10 c0 	movl   $0xc010dfb4,(%esp)
c0109225:	e8 7f 70 ff ff       	call   c01002a9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010922a:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010922f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109232:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109235:	89 d3                	mov    %edx,%ebx
c0109237:	c1 e3 0a             	shl    $0xa,%ebx
c010923a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010923d:	89 d1                	mov    %edx,%ecx
c010923f:	c1 e1 0a             	shl    $0xa,%ecx
c0109242:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0109245:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109249:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010924c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0109250:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0109254:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109258:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010925c:	89 0c 24             	mov    %ecx,(%esp)
c010925f:	e8 40 fe ff ff       	call   c01090a4 <get_pgtable_items>
c0109264:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109267:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010926b:	0f 85 65 ff ff ff    	jne    c01091d6 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0109271:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0109276:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109279:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010927c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109280:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0109283:	89 54 24 10          	mov    %edx,0x10(%esp)
c0109287:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010928b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010928f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0109296:	00 
c0109297:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010929e:	e8 01 fe ff ff       	call   c01090a4 <get_pgtable_items>
c01092a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01092a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01092aa:	0f 85 c7 fe ff ff    	jne    c0109177 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01092b0:	c7 04 24 d8 df 10 c0 	movl   $0xc010dfd8,(%esp)
c01092b7:	e8 ed 6f ff ff       	call   c01002a9 <cprintf>
}
c01092bc:	90                   	nop
c01092bd:	83 c4 4c             	add    $0x4c,%esp
c01092c0:	5b                   	pop    %ebx
c01092c1:	5e                   	pop    %esi
c01092c2:	5f                   	pop    %edi
c01092c3:	5d                   	pop    %ebp
c01092c4:	c3                   	ret    

c01092c5 <page2ppn>:
page2ppn(struct Page *page) {
c01092c5:	55                   	push   %ebp
c01092c6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01092c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092cb:	8b 15 58 21 1a c0    	mov    0xc01a2158,%edx
c01092d1:	29 d0                	sub    %edx,%eax
c01092d3:	c1 f8 05             	sar    $0x5,%eax
}
c01092d6:	5d                   	pop    %ebp
c01092d7:	c3                   	ret    

c01092d8 <page2pa>:
page2pa(struct Page *page) {
c01092d8:	55                   	push   %ebp
c01092d9:	89 e5                	mov    %esp,%ebp
c01092db:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01092de:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e1:	89 04 24             	mov    %eax,(%esp)
c01092e4:	e8 dc ff ff ff       	call   c01092c5 <page2ppn>
c01092e9:	c1 e0 0c             	shl    $0xc,%eax
}
c01092ec:	c9                   	leave  
c01092ed:	c3                   	ret    

c01092ee <page2kva>:
page2kva(struct Page *page) {
c01092ee:	55                   	push   %ebp
c01092ef:	89 e5                	mov    %esp,%ebp
c01092f1:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01092f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01092f7:	89 04 24             	mov    %eax,(%esp)
c01092fa:	e8 d9 ff ff ff       	call   c01092d8 <page2pa>
c01092ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109302:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109305:	c1 e8 0c             	shr    $0xc,%eax
c0109308:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010930b:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c0109310:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109313:	72 23                	jb     c0109338 <page2kva+0x4a>
c0109315:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109318:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010931c:	c7 44 24 08 0c e0 10 	movl   $0xc010e00c,0x8(%esp)
c0109323:	c0 
c0109324:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010932b:	00 
c010932c:	c7 04 24 2f e0 10 c0 	movl   $0xc010e02f,(%esp)
c0109333:	e8 c8 70 ff ff       	call   c0100400 <__panic>
c0109338:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010933b:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109340:	c9                   	leave  
c0109341:	c3                   	ret    

c0109342 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109342:	55                   	push   %ebp
c0109343:	89 e5                	mov    %esp,%ebp
c0109345:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109348:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010934f:	e8 9e 7e ff ff       	call   c01011f2 <ide_device_valid>
c0109354:	85 c0                	test   %eax,%eax
c0109356:	75 1c                	jne    c0109374 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0109358:	c7 44 24 08 3d e0 10 	movl   $0xc010e03d,0x8(%esp)
c010935f:	c0 
c0109360:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0109367:	00 
c0109368:	c7 04 24 57 e0 10 c0 	movl   $0xc010e057,(%esp)
c010936f:	e8 8c 70 ff ff       	call   c0100400 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0109374:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010937b:	e8 b0 7e ff ff       	call   c0101230 <ide_device_size>
c0109380:	c1 e8 03             	shr    $0x3,%eax
c0109383:	a3 1c 21 1a c0       	mov    %eax,0xc01a211c
}
c0109388:	90                   	nop
c0109389:	c9                   	leave  
c010938a:	c3                   	ret    

c010938b <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010938b:	55                   	push   %ebp
c010938c:	89 e5                	mov    %esp,%ebp
c010938e:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109391:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109394:	89 04 24             	mov    %eax,(%esp)
c0109397:	e8 52 ff ff ff       	call   c01092ee <page2kva>
c010939c:	8b 55 08             	mov    0x8(%ebp),%edx
c010939f:	c1 ea 08             	shr    $0x8,%edx
c01093a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01093a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01093a9:	74 0b                	je     c01093b6 <swapfs_read+0x2b>
c01093ab:	8b 15 1c 21 1a c0    	mov    0xc01a211c,%edx
c01093b1:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01093b4:	72 23                	jb     c01093d9 <swapfs_read+0x4e>
c01093b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01093b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01093bd:	c7 44 24 08 68 e0 10 	movl   $0xc010e068,0x8(%esp)
c01093c4:	c0 
c01093c5:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01093cc:	00 
c01093cd:	c7 04 24 57 e0 10 c0 	movl   $0xc010e057,(%esp)
c01093d4:	e8 27 70 ff ff       	call   c0100400 <__panic>
c01093d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01093dc:	c1 e2 03             	shl    $0x3,%edx
c01093df:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01093e6:	00 
c01093e7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01093eb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01093ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01093f6:	e8 70 7e ff ff       	call   c010126b <ide_read_secs>
}
c01093fb:	c9                   	leave  
c01093fc:	c3                   	ret    

c01093fd <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01093fd:	55                   	push   %ebp
c01093fe:	89 e5                	mov    %esp,%ebp
c0109400:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109403:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109406:	89 04 24             	mov    %eax,(%esp)
c0109409:	e8 e0 fe ff ff       	call   c01092ee <page2kva>
c010940e:	8b 55 08             	mov    0x8(%ebp),%edx
c0109411:	c1 ea 08             	shr    $0x8,%edx
c0109414:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109417:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010941b:	74 0b                	je     c0109428 <swapfs_write+0x2b>
c010941d:	8b 15 1c 21 1a c0    	mov    0xc01a211c,%edx
c0109423:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109426:	72 23                	jb     c010944b <swapfs_write+0x4e>
c0109428:	8b 45 08             	mov    0x8(%ebp),%eax
c010942b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010942f:	c7 44 24 08 68 e0 10 	movl   $0xc010e068,0x8(%esp)
c0109436:	c0 
c0109437:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010943e:	00 
c010943f:	c7 04 24 57 e0 10 c0 	movl   $0xc010e057,(%esp)
c0109446:	e8 b5 6f ff ff       	call   c0100400 <__panic>
c010944b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010944e:	c1 e2 03             	shl    $0x3,%edx
c0109451:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109458:	00 
c0109459:	89 44 24 08          	mov    %eax,0x8(%esp)
c010945d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109461:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109468:	e8 37 80 ff ff       	call   c01014a4 <ide_write_secs>
}
c010946d:	c9                   	leave  
c010946e:	c3                   	ret    

c010946f <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010946f:	52                   	push   %edx
    call *%ebx              # call fn
c0109470:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109472:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109473:	e8 bd 0c 00 00       	call   c010a135 <do_exit>

c0109478 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0109478:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010947c:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010947e:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c0109481:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c0109484:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c0109487:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010948a:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010948d:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c0109490:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0109493:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c0109497:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010949a:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010949d:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c01094a0:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c01094a3:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c01094a6:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c01094a9:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c01094ac:	ff 30                	pushl  (%eax)

    ret
c01094ae:	c3                   	ret    

c01094af <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01094af:	55                   	push   %ebp
c01094b0:	89 e5                	mov    %esp,%ebp
c01094b2:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01094b5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01094b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01094bb:	0f ab 02             	bts    %eax,(%edx)
c01094be:	19 c0                	sbb    %eax,%eax
c01094c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01094c3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01094c7:	0f 95 c0             	setne  %al
c01094ca:	0f b6 c0             	movzbl %al,%eax
}
c01094cd:	c9                   	leave  
c01094ce:	c3                   	ret    

c01094cf <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01094cf:	55                   	push   %ebp
c01094d0:	89 e5                	mov    %esp,%ebp
c01094d2:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01094d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01094d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01094db:	0f b3 02             	btr    %eax,(%edx)
c01094de:	19 c0                	sbb    %eax,%eax
c01094e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01094e3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01094e7:	0f 95 c0             	setne  %al
c01094ea:	0f b6 c0             	movzbl %al,%eax
}
c01094ed:	c9                   	leave  
c01094ee:	c3                   	ret    

c01094ef <__intr_save>:
__intr_save(void) {
c01094ef:	55                   	push   %ebp
c01094f0:	89 e5                	mov    %esp,%ebp
c01094f2:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01094f5:	9c                   	pushf  
c01094f6:	58                   	pop    %eax
c01094f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01094fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01094fd:	25 00 02 00 00       	and    $0x200,%eax
c0109502:	85 c0                	test   %eax,%eax
c0109504:	74 0c                	je     c0109512 <__intr_save+0x23>
        intr_disable();
c0109506:	e8 d5 8c ff ff       	call   c01021e0 <intr_disable>
        return 1;
c010950b:	b8 01 00 00 00       	mov    $0x1,%eax
c0109510:	eb 05                	jmp    c0109517 <__intr_save+0x28>
    return 0;
c0109512:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109517:	c9                   	leave  
c0109518:	c3                   	ret    

c0109519 <__intr_restore>:
__intr_restore(bool flag) {
c0109519:	55                   	push   %ebp
c010951a:	89 e5                	mov    %esp,%ebp
c010951c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010951f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109523:	74 05                	je     c010952a <__intr_restore+0x11>
        intr_enable();
c0109525:	e8 af 8c ff ff       	call   c01021d9 <intr_enable>
}
c010952a:	90                   	nop
c010952b:	c9                   	leave  
c010952c:	c3                   	ret    

c010952d <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c010952d:	55                   	push   %ebp
c010952e:	89 e5                	mov    %esp,%ebp
c0109530:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c0109533:	8b 45 08             	mov    0x8(%ebp),%eax
c0109536:	89 44 24 04          	mov    %eax,0x4(%esp)
c010953a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109541:	e8 69 ff ff ff       	call   c01094af <test_and_set_bit>
c0109546:	85 c0                	test   %eax,%eax
c0109548:	0f 94 c0             	sete   %al
c010954b:	0f b6 c0             	movzbl %al,%eax
}
c010954e:	c9                   	leave  
c010954f:	c3                   	ret    

c0109550 <lock>:

static inline void
lock(lock_t *lock) {
c0109550:	55                   	push   %ebp
c0109551:	89 e5                	mov    %esp,%ebp
c0109553:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c0109556:	eb 05                	jmp    c010955d <lock+0xd>
        schedule();
c0109558:	e8 fc 1b 00 00       	call   c010b159 <schedule>
    while (!try_lock(lock)) {
c010955d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109560:	89 04 24             	mov    %eax,(%esp)
c0109563:	e8 c5 ff ff ff       	call   c010952d <try_lock>
c0109568:	85 c0                	test   %eax,%eax
c010956a:	74 ec                	je     c0109558 <lock+0x8>
    }
}
c010956c:	90                   	nop
c010956d:	c9                   	leave  
c010956e:	c3                   	ret    

c010956f <unlock>:

static inline void
unlock(lock_t *lock) {
c010956f:	55                   	push   %ebp
c0109570:	89 e5                	mov    %esp,%ebp
c0109572:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c0109575:	8b 45 08             	mov    0x8(%ebp),%eax
c0109578:	89 44 24 04          	mov    %eax,0x4(%esp)
c010957c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109583:	e8 47 ff ff ff       	call   c01094cf <test_and_clear_bit>
c0109588:	85 c0                	test   %eax,%eax
c010958a:	75 1c                	jne    c01095a8 <unlock+0x39>
        panic("Unlock failed.\n");
c010958c:	c7 44 24 08 88 e0 10 	movl   $0xc010e088,0x8(%esp)
c0109593:	c0 
c0109594:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c010959b:	00 
c010959c:	c7 04 24 98 e0 10 c0 	movl   $0xc010e098,(%esp)
c01095a3:	e8 58 6e ff ff       	call   c0100400 <__panic>
    }
}
c01095a8:	90                   	nop
c01095a9:	c9                   	leave  
c01095aa:	c3                   	ret    

c01095ab <page2ppn>:
page2ppn(struct Page *page) {
c01095ab:	55                   	push   %ebp
c01095ac:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01095ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01095b1:	8b 15 58 21 1a c0    	mov    0xc01a2158,%edx
c01095b7:	29 d0                	sub    %edx,%eax
c01095b9:	c1 f8 05             	sar    $0x5,%eax
}
c01095bc:	5d                   	pop    %ebp
c01095bd:	c3                   	ret    

c01095be <page2pa>:
page2pa(struct Page *page) {
c01095be:	55                   	push   %ebp
c01095bf:	89 e5                	mov    %esp,%ebp
c01095c1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01095c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01095c7:	89 04 24             	mov    %eax,(%esp)
c01095ca:	e8 dc ff ff ff       	call   c01095ab <page2ppn>
c01095cf:	c1 e0 0c             	shl    $0xc,%eax
}
c01095d2:	c9                   	leave  
c01095d3:	c3                   	ret    

c01095d4 <pa2page>:
pa2page(uintptr_t pa) {
c01095d4:	55                   	push   %ebp
c01095d5:	89 e5                	mov    %esp,%ebp
c01095d7:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01095da:	8b 45 08             	mov    0x8(%ebp),%eax
c01095dd:	c1 e8 0c             	shr    $0xc,%eax
c01095e0:	89 c2                	mov    %eax,%edx
c01095e2:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c01095e7:	39 c2                	cmp    %eax,%edx
c01095e9:	72 1c                	jb     c0109607 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01095eb:	c7 44 24 08 ac e0 10 	movl   $0xc010e0ac,0x8(%esp)
c01095f2:	c0 
c01095f3:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01095fa:	00 
c01095fb:	c7 04 24 cb e0 10 c0 	movl   $0xc010e0cb,(%esp)
c0109602:	e8 f9 6d ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0109607:	a1 58 21 1a c0       	mov    0xc01a2158,%eax
c010960c:	8b 55 08             	mov    0x8(%ebp),%edx
c010960f:	c1 ea 0c             	shr    $0xc,%edx
c0109612:	c1 e2 05             	shl    $0x5,%edx
c0109615:	01 d0                	add    %edx,%eax
}
c0109617:	c9                   	leave  
c0109618:	c3                   	ret    

c0109619 <page2kva>:
page2kva(struct Page *page) {
c0109619:	55                   	push   %ebp
c010961a:	89 e5                	mov    %esp,%ebp
c010961c:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010961f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109622:	89 04 24             	mov    %eax,(%esp)
c0109625:	e8 94 ff ff ff       	call   c01095be <page2pa>
c010962a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010962d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109630:	c1 e8 0c             	shr    $0xc,%eax
c0109633:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109636:	a1 80 ff 19 c0       	mov    0xc019ff80,%eax
c010963b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010963e:	72 23                	jb     c0109663 <page2kva+0x4a>
c0109640:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109643:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109647:	c7 44 24 08 dc e0 10 	movl   $0xc010e0dc,0x8(%esp)
c010964e:	c0 
c010964f:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109656:	00 
c0109657:	c7 04 24 cb e0 10 c0 	movl   $0xc010e0cb,(%esp)
c010965e:	e8 9d 6d ff ff       	call   c0100400 <__panic>
c0109663:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109666:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010966b:	c9                   	leave  
c010966c:	c3                   	ret    

c010966d <kva2page>:
kva2page(void *kva) {
c010966d:	55                   	push   %ebp
c010966e:	89 e5                	mov    %esp,%ebp
c0109670:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109673:	8b 45 08             	mov    0x8(%ebp),%eax
c0109676:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109679:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0109680:	77 23                	ja     c01096a5 <kva2page+0x38>
c0109682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109685:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109689:	c7 44 24 08 00 e1 10 	movl   $0xc010e100,0x8(%esp)
c0109690:	c0 
c0109691:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0109698:	00 
c0109699:	c7 04 24 cb e0 10 c0 	movl   $0xc010e0cb,(%esp)
c01096a0:	e8 5b 6d ff ff       	call   c0100400 <__panic>
c01096a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096a8:	05 00 00 00 40       	add    $0x40000000,%eax
c01096ad:	89 04 24             	mov    %eax,(%esp)
c01096b0:	e8 1f ff ff ff       	call   c01095d4 <pa2page>
}
c01096b5:	c9                   	leave  
c01096b6:	c3                   	ret    

c01096b7 <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01096b7:	55                   	push   %ebp
c01096b8:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01096ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01096bd:	8b 40 18             	mov    0x18(%eax),%eax
c01096c0:	8d 50 01             	lea    0x1(%eax),%edx
c01096c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01096c6:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01096c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01096cc:	8b 40 18             	mov    0x18(%eax),%eax
}
c01096cf:	5d                   	pop    %ebp
c01096d0:	c3                   	ret    

c01096d1 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01096d1:	55                   	push   %ebp
c01096d2:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01096d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01096d7:	8b 40 18             	mov    0x18(%eax),%eax
c01096da:	8d 50 ff             	lea    -0x1(%eax),%edx
c01096dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01096e0:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01096e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01096e6:	8b 40 18             	mov    0x18(%eax),%eax
}
c01096e9:	5d                   	pop    %ebp
c01096ea:	c3                   	ret    

c01096eb <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c01096eb:	55                   	push   %ebp
c01096ec:	89 e5                	mov    %esp,%ebp
c01096ee:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01096f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01096f5:	74 0e                	je     c0109705 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c01096f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01096fa:	83 c0 1c             	add    $0x1c,%eax
c01096fd:	89 04 24             	mov    %eax,(%esp)
c0109700:	e8 4b fe ff ff       	call   c0109550 <lock>
    }
}
c0109705:	90                   	nop
c0109706:	c9                   	leave  
c0109707:	c3                   	ret    

c0109708 <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c0109708:	55                   	push   %ebp
c0109709:	89 e5                	mov    %esp,%ebp
c010970b:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c010970e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109712:	74 0e                	je     c0109722 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c0109714:	8b 45 08             	mov    0x8(%ebp),%eax
c0109717:	83 c0 1c             	add    $0x1c,%eax
c010971a:	89 04 24             	mov    %eax,(%esp)
c010971d:	e8 4d fe ff ff       	call   c010956f <unlock>
    }
}
c0109722:	90                   	nop
c0109723:	c9                   	leave  
c0109724:	c3                   	ret    

c0109725 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109725:	55                   	push   %ebp
c0109726:	89 e5                	mov    %esp,%ebp
c0109728:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010972b:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c0109732:	e8 19 bd ff ff       	call   c0105450 <kmalloc>
c0109737:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010973a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010973e:	0f 84 c9 00 00 00    	je     c010980d <alloc_proc+0xe8>
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
     proc->state = PROC_UNINIT;
c0109744:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109747:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     proc->pid = -1;
c010974d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109750:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
     proc->runs = 0;
c0109757:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010975a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
     proc->kstack = 0;
c0109761:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109764:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     proc->need_resched = 0;
c010976b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010976e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     proc->parent = NULL;
c0109775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109778:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
     proc->mm = NULL;
c010977f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109782:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
     memset(&(proc->context), 0, sizeof(struct context));
c0109789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010978c:	83 c0 1c             	add    $0x1c,%eax
c010978f:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109796:	00 
c0109797:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010979e:	00 
c010979f:	89 04 24             	mov    %eax,(%esp)
c01097a2:	e8 96 1f 00 00       	call   c010b73d <memset>
     proc->tf = NULL;
c01097a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097aa:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
     proc->cr3 = boot_cr3;
c01097b1:	8b 15 54 21 1a c0    	mov    0xc01a2154,%edx
c01097b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097ba:	89 50 40             	mov    %edx,0x40(%eax)
     proc->flags = 0;
c01097bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097c0:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
     memset(proc->name, 0, PROC_NAME_LEN);
c01097c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097ca:	83 c0 48             	add    $0x48,%eax
c01097cd:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01097d4:	00 
c01097d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01097dc:	00 
c01097dd:	89 04 24             	mov    %eax,(%esp)
c01097e0:	e8 58 1f 00 00       	call   c010b73d <memset>
     proc->wait_state = 0;
c01097e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097e8:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
     proc->cptr = NULL;
c01097ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097f2:	c7 40 70 00 00 00 00 	movl   $0x0,0x70(%eax)
     proc->optr = NULL;
c01097f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097fc:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
     proc->yptr = NULL;
c0109803:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109806:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    }
    return proc;
c010980d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109810:	c9                   	leave  
c0109811:	c3                   	ret    

c0109812 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109812:	55                   	push   %ebp
c0109813:	89 e5                	mov    %esp,%ebp
c0109815:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109818:	8b 45 08             	mov    0x8(%ebp),%eax
c010981b:	83 c0 48             	add    $0x48,%eax
c010981e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109825:	00 
c0109826:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010982d:	00 
c010982e:	89 04 24             	mov    %eax,(%esp)
c0109831:	e8 07 1f 00 00       	call   c010b73d <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109836:	8b 45 08             	mov    0x8(%ebp),%eax
c0109839:	8d 50 48             	lea    0x48(%eax),%edx
c010983c:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109843:	00 
c0109844:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109847:	89 44 24 04          	mov    %eax,0x4(%esp)
c010984b:	89 14 24             	mov    %edx,(%esp)
c010984e:	e8 cd 1f 00 00       	call   c010b820 <memcpy>
}
c0109853:	c9                   	leave  
c0109854:	c3                   	ret    

c0109855 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0109855:	55                   	push   %ebp
c0109856:	89 e5                	mov    %esp,%ebp
c0109858:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c010985b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109862:	00 
c0109863:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010986a:	00 
c010986b:	c7 04 24 44 20 1a c0 	movl   $0xc01a2044,(%esp)
c0109872:	e8 c6 1e 00 00       	call   c010b73d <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109877:	8b 45 08             	mov    0x8(%ebp),%eax
c010987a:	83 c0 48             	add    $0x48,%eax
c010987d:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109884:	00 
c0109885:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109889:	c7 04 24 44 20 1a c0 	movl   $0xc01a2044,(%esp)
c0109890:	e8 8b 1f 00 00       	call   c010b820 <memcpy>
}
c0109895:	c9                   	leave  
c0109896:	c3                   	ret    

c0109897 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109897:	55                   	push   %ebp
c0109898:	89 e5                	mov    %esp,%ebp
c010989a:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c010989d:	8b 45 08             	mov    0x8(%ebp),%eax
c01098a0:	83 c0 58             	add    $0x58,%eax
c01098a3:	c7 45 fc 5c 21 1a c0 	movl   $0xc01a215c,-0x4(%ebp)
c01098aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01098ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01098b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01098b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c01098b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098bc:	8b 40 04             	mov    0x4(%eax),%eax
c01098bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01098c2:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01098c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01098c8:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01098cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c01098ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01098d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01098d4:	89 10                	mov    %edx,(%eax)
c01098d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01098d9:	8b 10                	mov    (%eax),%edx
c01098db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01098de:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01098e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01098e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01098e7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01098ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01098ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01098f0:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c01098f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01098f5:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c01098fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ff:	8b 40 14             	mov    0x14(%eax),%eax
c0109902:	8b 50 70             	mov    0x70(%eax),%edx
c0109905:	8b 45 08             	mov    0x8(%ebp),%eax
c0109908:	89 50 78             	mov    %edx,0x78(%eax)
c010990b:	8b 45 08             	mov    0x8(%ebp),%eax
c010990e:	8b 40 78             	mov    0x78(%eax),%eax
c0109911:	85 c0                	test   %eax,%eax
c0109913:	74 0c                	je     c0109921 <set_links+0x8a>
        proc->optr->yptr = proc;
c0109915:	8b 45 08             	mov    0x8(%ebp),%eax
c0109918:	8b 40 78             	mov    0x78(%eax),%eax
c010991b:	8b 55 08             	mov    0x8(%ebp),%edx
c010991e:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c0109921:	8b 45 08             	mov    0x8(%ebp),%eax
c0109924:	8b 40 14             	mov    0x14(%eax),%eax
c0109927:	8b 55 08             	mov    0x8(%ebp),%edx
c010992a:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c010992d:	a1 40 20 1a c0       	mov    0xc01a2040,%eax
c0109932:	40                   	inc    %eax
c0109933:	a3 40 20 1a c0       	mov    %eax,0xc01a2040
}
c0109938:	90                   	nop
c0109939:	c9                   	leave  
c010993a:	c3                   	ret    

c010993b <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c010993b:	55                   	push   %ebp
c010993c:	89 e5                	mov    %esp,%ebp
c010993e:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0109941:	8b 45 08             	mov    0x8(%ebp),%eax
c0109944:	83 c0 58             	add    $0x58,%eax
c0109947:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c010994a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010994d:	8b 40 04             	mov    0x4(%eax),%eax
c0109950:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109953:	8b 12                	mov    (%edx),%edx
c0109955:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109958:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c010995b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010995e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109961:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109964:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109967:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010996a:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c010996c:	8b 45 08             	mov    0x8(%ebp),%eax
c010996f:	8b 40 78             	mov    0x78(%eax),%eax
c0109972:	85 c0                	test   %eax,%eax
c0109974:	74 0f                	je     c0109985 <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c0109976:	8b 45 08             	mov    0x8(%ebp),%eax
c0109979:	8b 40 78             	mov    0x78(%eax),%eax
c010997c:	8b 55 08             	mov    0x8(%ebp),%edx
c010997f:	8b 52 74             	mov    0x74(%edx),%edx
c0109982:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0109985:	8b 45 08             	mov    0x8(%ebp),%eax
c0109988:	8b 40 74             	mov    0x74(%eax),%eax
c010998b:	85 c0                	test   %eax,%eax
c010998d:	74 11                	je     c01099a0 <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c010998f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109992:	8b 40 74             	mov    0x74(%eax),%eax
c0109995:	8b 55 08             	mov    0x8(%ebp),%edx
c0109998:	8b 52 78             	mov    0x78(%edx),%edx
c010999b:	89 50 78             	mov    %edx,0x78(%eax)
c010999e:	eb 0f                	jmp    c01099af <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c01099a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099a3:	8b 40 14             	mov    0x14(%eax),%eax
c01099a6:	8b 55 08             	mov    0x8(%ebp),%edx
c01099a9:	8b 52 78             	mov    0x78(%edx),%edx
c01099ac:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c01099af:	a1 40 20 1a c0       	mov    0xc01a2040,%eax
c01099b4:	48                   	dec    %eax
c01099b5:	a3 40 20 1a c0       	mov    %eax,0xc01a2040
}
c01099ba:	90                   	nop
c01099bb:	c9                   	leave  
c01099bc:	c3                   	ret    

c01099bd <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c01099bd:	55                   	push   %ebp
c01099be:	89 e5                	mov    %esp,%ebp
c01099c0:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01099c3:	c7 45 f8 5c 21 1a c0 	movl   $0xc01a215c,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c01099ca:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
c01099cf:	40                   	inc    %eax
c01099d0:	a3 78 ba 12 c0       	mov    %eax,0xc012ba78
c01099d5:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
c01099da:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01099df:	7e 0c                	jle    c01099ed <get_pid+0x30>
        last_pid = 1;
c01099e1:	c7 05 78 ba 12 c0 01 	movl   $0x1,0xc012ba78
c01099e8:	00 00 00 
        goto inside;
c01099eb:	eb 14                	jmp    c0109a01 <get_pid+0x44>
    }
    if (last_pid >= next_safe) {
c01099ed:	8b 15 78 ba 12 c0    	mov    0xc012ba78,%edx
c01099f3:	a1 7c ba 12 c0       	mov    0xc012ba7c,%eax
c01099f8:	39 c2                	cmp    %eax,%edx
c01099fa:	0f 8c ab 00 00 00    	jl     c0109aab <get_pid+0xee>
    inside:
c0109a00:	90                   	nop
        next_safe = MAX_PID;
c0109a01:	c7 05 7c ba 12 c0 00 	movl   $0x2000,0xc012ba7c
c0109a08:	20 00 00 
    repeat:
        le = list;
c0109a0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109a0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109a11:	eb 7d                	jmp    c0109a90 <get_pid+0xd3>
            proc = le2proc(le, list_link);
c0109a13:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a16:	83 e8 58             	sub    $0x58,%eax
c0109a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a1f:	8b 50 04             	mov    0x4(%eax),%edx
c0109a22:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
c0109a27:	39 c2                	cmp    %eax,%edx
c0109a29:	75 3c                	jne    c0109a67 <get_pid+0xaa>
                if (++ last_pid >= next_safe) {
c0109a2b:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
c0109a30:	40                   	inc    %eax
c0109a31:	a3 78 ba 12 c0       	mov    %eax,0xc012ba78
c0109a36:	8b 15 78 ba 12 c0    	mov    0xc012ba78,%edx
c0109a3c:	a1 7c ba 12 c0       	mov    0xc012ba7c,%eax
c0109a41:	39 c2                	cmp    %eax,%edx
c0109a43:	7c 4b                	jl     c0109a90 <get_pid+0xd3>
                    if (last_pid >= MAX_PID) {
c0109a45:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
c0109a4a:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109a4f:	7e 0a                	jle    c0109a5b <get_pid+0x9e>
                        last_pid = 1;
c0109a51:	c7 05 78 ba 12 c0 01 	movl   $0x1,0xc012ba78
c0109a58:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109a5b:	c7 05 7c ba 12 c0 00 	movl   $0x2000,0xc012ba7c
c0109a62:	20 00 00 
                    goto repeat;
c0109a65:	eb a4                	jmp    c0109a0b <get_pid+0x4e>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a6a:	8b 50 04             	mov    0x4(%eax),%edx
c0109a6d:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
c0109a72:	39 c2                	cmp    %eax,%edx
c0109a74:	7e 1a                	jle    c0109a90 <get_pid+0xd3>
c0109a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a79:	8b 50 04             	mov    0x4(%eax),%edx
c0109a7c:	a1 7c ba 12 c0       	mov    0xc012ba7c,%eax
c0109a81:	39 c2                	cmp    %eax,%edx
c0109a83:	7d 0b                	jge    c0109a90 <get_pid+0xd3>
                next_safe = proc->pid;
c0109a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a88:	8b 40 04             	mov    0x4(%eax),%eax
c0109a8b:	a3 7c ba 12 c0       	mov    %eax,0xc012ba7c
c0109a90:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c0109a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a99:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109a9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109a9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109aa2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109aa5:	0f 85 68 ff ff ff    	jne    c0109a13 <get_pid+0x56>
            }
        }
    }
    return last_pid;
c0109aab:	a1 78 ba 12 c0       	mov    0xc012ba78,%eax
}
c0109ab0:	c9                   	leave  
c0109ab1:	c3                   	ret    

c0109ab2 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109ab2:	55                   	push   %ebp
c0109ab3:	89 e5                	mov    %esp,%ebp
c0109ab5:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109ab8:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0109abd:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109ac0:	74 63                	je     c0109b25 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109ac2:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0109ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109aca:	8b 45 08             	mov    0x8(%ebp),%eax
c0109acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109ad0:	e8 1a fa ff ff       	call   c01094ef <__intr_save>
c0109ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109ad8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109adb:	a3 28 00 1a c0       	mov    %eax,0xc01a0028
            load_esp0(next->kstack + KSTACKSIZE);
c0109ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ae3:	8b 40 0c             	mov    0xc(%eax),%eax
c0109ae6:	05 00 20 00 00       	add    $0x2000,%eax
c0109aeb:	89 04 24             	mov    %eax,(%esp)
c0109aee:	e8 bd da ff ff       	call   c01075b0 <load_esp0>
            lcr3(next->cr3);
c0109af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109af6:	8b 40 40             	mov    0x40(%eax),%eax
c0109af9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109afc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109aff:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b05:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b0b:	83 c0 1c             	add    $0x1c,%eax
c0109b0e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109b12:	89 04 24             	mov    %eax,(%esp)
c0109b15:	e8 5e f9 ff ff       	call   c0109478 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109b1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b1d:	89 04 24             	mov    %eax,(%esp)
c0109b20:	e8 f4 f9 ff ff       	call   c0109519 <__intr_restore>
    }
}
c0109b25:	90                   	nop
c0109b26:	c9                   	leave  
c0109b27:	c3                   	ret    

c0109b28 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109b28:	55                   	push   %ebp
c0109b29:	89 e5                	mov    %esp,%ebp
c0109b2b:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109b2e:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0109b33:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109b36:	89 04 24             	mov    %eax,(%esp)
c0109b39:	e8 b1 99 ff ff       	call   c01034ef <forkrets>
}
c0109b3e:	90                   	nop
c0109b3f:	c9                   	leave  
c0109b40:	c3                   	ret    

c0109b41 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109b41:	55                   	push   %ebp
c0109b42:	89 e5                	mov    %esp,%ebp
c0109b44:	53                   	push   %ebx
c0109b45:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b4b:	8d 58 60             	lea    0x60(%eax),%ebx
c0109b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b51:	8b 40 04             	mov    0x4(%eax),%eax
c0109b54:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109b5b:	00 
c0109b5c:	89 04 24             	mov    %eax,(%esp)
c0109b5f:	e8 d3 23 00 00       	call   c010bf37 <hash32>
c0109b64:	c1 e0 03             	shl    $0x3,%eax
c0109b67:	05 40 00 1a c0       	add    $0xc01a0040,%eax
c0109b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b6f:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b75:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109b7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b81:	8b 40 04             	mov    0x4(%eax),%eax
c0109b84:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109b87:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109b8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109b8d:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109b90:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109b93:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109b99:	89 10                	mov    %edx,(%eax)
c0109b9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b9e:	8b 10                	mov    (%eax),%edx
c0109ba0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109ba3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109ba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109ba9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109bac:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109bb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109bb5:	89 10                	mov    %edx,(%eax)
}
c0109bb7:	90                   	nop
c0109bb8:	83 c4 34             	add    $0x34,%esp
c0109bbb:	5b                   	pop    %ebx
c0109bbc:	5d                   	pop    %ebp
c0109bbd:	c3                   	ret    

c0109bbe <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109bbe:	55                   	push   %ebp
c0109bbf:	89 e5                	mov    %esp,%ebp
c0109bc1:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bc7:	83 c0 60             	add    $0x60,%eax
c0109bca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109bd0:	8b 40 04             	mov    0x4(%eax),%eax
c0109bd3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109bd6:	8b 12                	mov    (%edx),%edx
c0109bd8:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109bde:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109be4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bea:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109bed:	89 10                	mov    %edx,(%eax)
}
c0109bef:	90                   	nop
c0109bf0:	c9                   	leave  
c0109bf1:	c3                   	ret    

c0109bf2 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109bf2:	55                   	push   %ebp
c0109bf3:	89 e5                	mov    %esp,%ebp
c0109bf5:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109bf8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109bfc:	7e 5f                	jle    c0109c5d <find_proc+0x6b>
c0109bfe:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109c05:	7f 56                	jg     c0109c5d <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109c07:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c0a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109c11:	00 
c0109c12:	89 04 24             	mov    %eax,(%esp)
c0109c15:	e8 1d 23 00 00       	call   c010bf37 <hash32>
c0109c1a:	c1 e0 03             	shl    $0x3,%eax
c0109c1d:	05 40 00 1a c0       	add    $0xc01a0040,%eax
c0109c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109c2b:	eb 19                	jmp    c0109c46 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c30:	83 e8 60             	sub    $0x60,%eax
c0109c33:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109c36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c39:	8b 40 04             	mov    0x4(%eax),%eax
c0109c3c:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109c3f:	75 05                	jne    c0109c46 <find_proc+0x54>
                return proc;
c0109c41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c44:	eb 1c                	jmp    c0109c62 <find_proc+0x70>
c0109c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c49:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0109c4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109c4f:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c58:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109c5b:	75 d0                	jne    c0109c2d <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0109c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c62:	c9                   	leave  
c0109c63:	c3                   	ret    

c0109c64 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109c64:	55                   	push   %ebp
c0109c65:	89 e5                	mov    %esp,%ebp
c0109c67:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109c6a:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109c71:	00 
c0109c72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c79:	00 
c0109c7a:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109c7d:	89 04 24             	mov    %eax,(%esp)
c0109c80:	e8 b8 1a 00 00       	call   c010b73d <memset>
    tf.tf_cs = KERNEL_CS;
c0109c85:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109c8b:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109c91:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109c95:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109c99:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109c9d:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ca4:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109caa:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109cad:	b8 6f 94 10 c0       	mov    $0xc010946f,%eax
c0109cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109cb5:	8b 45 10             	mov    0x10(%ebp),%eax
c0109cb8:	0d 00 01 00 00       	or     $0x100,%eax
c0109cbd:	89 c2                	mov    %eax,%edx
c0109cbf:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109cc2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109cc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109ccd:	00 
c0109cce:	89 14 24             	mov    %edx,(%esp)
c0109cd1:	e8 38 03 00 00       	call   c010a00e <do_fork>
}
c0109cd6:	c9                   	leave  
c0109cd7:	c3                   	ret    

c0109cd8 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109cd8:	55                   	push   %ebp
c0109cd9:	89 e5                	mov    %esp,%ebp
c0109cdb:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109cde:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109ce5:	e8 11 da ff ff       	call   c01076fb <alloc_pages>
c0109cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109ced:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109cf1:	74 1a                	je     c0109d0d <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cf6:	89 04 24             	mov    %eax,(%esp)
c0109cf9:	e8 1b f9 ff ff       	call   c0109619 <page2kva>
c0109cfe:	89 c2                	mov    %eax,%edx
c0109d00:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d03:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109d06:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d0b:	eb 05                	jmp    c0109d12 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109d0d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109d12:	c9                   	leave  
c0109d13:	c3                   	ret    

c0109d14 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109d14:	55                   	push   %ebp
c0109d15:	89 e5                	mov    %esp,%ebp
c0109d17:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109d1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d1d:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d20:	89 04 24             	mov    %eax,(%esp)
c0109d23:	e8 45 f9 ff ff       	call   c010966d <kva2page>
c0109d28:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109d2f:	00 
c0109d30:	89 04 24             	mov    %eax,(%esp)
c0109d33:	e8 2e da ff ff       	call   c0107766 <free_pages>
}
c0109d38:	90                   	nop
c0109d39:	c9                   	leave  
c0109d3a:	c3                   	ret    

c0109d3b <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109d3b:	55                   	push   %ebp
c0109d3c:	89 e5                	mov    %esp,%ebp
c0109d3e:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109d41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109d48:	e8 ae d9 ff ff       	call   c01076fb <alloc_pages>
c0109d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109d50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109d54:	75 0a                	jne    c0109d60 <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109d56:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109d5b:	e9 80 00 00 00       	jmp    c0109de0 <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d63:	89 04 24             	mov    %eax,(%esp)
c0109d66:	e8 ae f8 ff ff       	call   c0109619 <page2kva>
c0109d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109d6e:	a1 20 ba 12 c0       	mov    0xc012ba20,%eax
c0109d73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109d7a:	00 
c0109d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d82:	89 04 24             	mov    %eax,(%esp)
c0109d85:	e8 96 1a 00 00       	call   c010b820 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d90:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109d97:	77 23                	ja     c0109dbc <setup_pgdir+0x81>
c0109d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109da0:	c7 44 24 08 00 e1 10 	movl   $0xc010e100,0x8(%esp)
c0109da7:	c0 
c0109da8:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0109daf:	00 
c0109db0:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c0109db7:	e8 44 66 ff ff       	call   c0100400 <__panic>
c0109dbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109dbf:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109dc8:	05 ac 0f 00 00       	add    $0xfac,%eax
c0109dcd:	83 ca 03             	or     $0x3,%edx
c0109dd0:	89 10                	mov    %edx,(%eax)
    mm->pgdir = pgdir;
c0109dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109dd8:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109de0:	c9                   	leave  
c0109de1:	c3                   	ret    

c0109de2 <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109de2:	55                   	push   %ebp
c0109de3:	89 e5                	mov    %esp,%ebp
c0109de5:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109de8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109deb:	8b 40 0c             	mov    0xc(%eax),%eax
c0109dee:	89 04 24             	mov    %eax,(%esp)
c0109df1:	e8 77 f8 ff ff       	call   c010966d <kva2page>
c0109df6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109dfd:	00 
c0109dfe:	89 04 24             	mov    %eax,(%esp)
c0109e01:	e8 60 d9 ff ff       	call   c0107766 <free_pages>
}
c0109e06:	90                   	nop
c0109e07:	c9                   	leave  
c0109e08:	c3                   	ret    

c0109e09 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109e09:	55                   	push   %ebp
c0109e0a:	89 e5                	mov    %esp,%ebp
c0109e0c:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109e0f:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c0109e14:	8b 40 18             	mov    0x18(%eax),%eax
c0109e17:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109e1a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109e1e:	75 0a                	jne    c0109e2a <copy_mm+0x21>
        return 0;
c0109e20:	b8 00 00 00 00       	mov    $0x0,%eax
c0109e25:	e9 fc 00 00 00       	jmp    c0109f26 <copy_mm+0x11d>
    }
    if (clone_flags & CLONE_VM) {
c0109e2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e2d:	25 00 01 00 00       	and    $0x100,%eax
c0109e32:	85 c0                	test   %eax,%eax
c0109e34:	74 08                	je     c0109e3e <copy_mm+0x35>
        mm = oldmm;
c0109e36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e39:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109e3c:	eb 5e                	jmp    c0109e9c <copy_mm+0x93>
    }

    int ret = -E_NO_MEM;
c0109e3e:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109e45:	e8 31 97 ff ff       	call   c010357b <mm_create>
c0109e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109e4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109e51:	0f 84 cb 00 00 00    	je     c0109f22 <copy_mm+0x119>
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
c0109e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e5a:	89 04 24             	mov    %eax,(%esp)
c0109e5d:	e8 d9 fe ff ff       	call   c0109d3b <setup_pgdir>
c0109e62:	85 c0                	test   %eax,%eax
c0109e64:	0f 85 aa 00 00 00    	jne    c0109f14 <copy_mm+0x10b>
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm);
c0109e6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e6d:	89 04 24             	mov    %eax,(%esp)
c0109e70:	e8 76 f8 ff ff       	call   c01096eb <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e7f:	89 04 24             	mov    %eax,(%esp)
c0109e82:	e8 0b 9c ff ff       	call   c0103a92 <dup_mmap>
c0109e87:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109e8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e8d:	89 04 24             	mov    %eax,(%esp)
c0109e90:	e8 73 f8 ff ff       	call   c0109708 <unlock_mm>

    if (ret != 0) {
c0109e95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e99:	75 60                	jne    c0109efb <copy_mm+0xf2>
        goto bad_dup_cleanup_mmap;
    }

good_mm:
c0109e9b:	90                   	nop
    mm_count_inc(mm);
c0109e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e9f:	89 04 24             	mov    %eax,(%esp)
c0109ea2:	e8 10 f8 ff ff       	call   c01096b7 <mm_count_inc>
    proc->mm = mm;
c0109ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109eaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109ead:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109eb3:	8b 40 0c             	mov    0xc(%eax),%eax
c0109eb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109eb9:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109ec0:	77 23                	ja     c0109ee5 <copy_mm+0xdc>
c0109ec2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ec5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109ec9:	c7 44 24 08 00 e1 10 	movl   $0xc010e100,0x8(%esp)
c0109ed0:	c0 
c0109ed1:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
c0109ed8:	00 
c0109ed9:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c0109ee0:	e8 1b 65 ff ff       	call   c0100400 <__panic>
c0109ee5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ee8:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109eee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ef1:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109ef4:	b8 00 00 00 00       	mov    $0x0,%eax
c0109ef9:	eb 2b                	jmp    c0109f26 <copy_mm+0x11d>
        goto bad_dup_cleanup_mmap;
c0109efb:	90                   	nop
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109eff:	89 04 24             	mov    %eax,(%esp)
c0109f02:	e8 8c 9c ff ff       	call   c0103b93 <exit_mmap>
    put_pgdir(mm);
c0109f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f0a:	89 04 24             	mov    %eax,(%esp)
c0109f0d:	e8 d0 fe ff ff       	call   c0109de2 <put_pgdir>
c0109f12:	eb 01                	jmp    c0109f15 <copy_mm+0x10c>
        goto bad_pgdir_cleanup_mm;
c0109f14:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f18:	89 04 24             	mov    %eax,(%esp)
c0109f1b:	e8 b7 99 ff ff       	call   c01038d7 <mm_destroy>
c0109f20:	eb 01                	jmp    c0109f23 <copy_mm+0x11a>
        goto bad_mm;
c0109f22:	90                   	nop
bad_mm:
    return ret;
c0109f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109f26:	c9                   	leave  
c0109f27:	c3                   	ret    

c0109f28 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109f28:	55                   	push   %ebp
c0109f29:	89 e5                	mov    %esp,%ebp
c0109f2b:	57                   	push   %edi
c0109f2c:	56                   	push   %esi
c0109f2d:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109f2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f31:	8b 40 0c             	mov    0xc(%eax),%eax
c0109f34:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109f39:	89 c2                	mov    %eax,%edx
c0109f3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f3e:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f44:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f47:	8b 55 10             	mov    0x10(%ebp),%edx
c0109f4a:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109f4f:	89 c1                	mov    %eax,%ecx
c0109f51:	83 e1 01             	and    $0x1,%ecx
c0109f54:	85 c9                	test   %ecx,%ecx
c0109f56:	74 0c                	je     c0109f64 <copy_thread+0x3c>
c0109f58:	0f b6 0a             	movzbl (%edx),%ecx
c0109f5b:	88 08                	mov    %cl,(%eax)
c0109f5d:	8d 40 01             	lea    0x1(%eax),%eax
c0109f60:	8d 52 01             	lea    0x1(%edx),%edx
c0109f63:	4b                   	dec    %ebx
c0109f64:	89 c1                	mov    %eax,%ecx
c0109f66:	83 e1 02             	and    $0x2,%ecx
c0109f69:	85 c9                	test   %ecx,%ecx
c0109f6b:	74 0f                	je     c0109f7c <copy_thread+0x54>
c0109f6d:	0f b7 0a             	movzwl (%edx),%ecx
c0109f70:	66 89 08             	mov    %cx,(%eax)
c0109f73:	8d 40 02             	lea    0x2(%eax),%eax
c0109f76:	8d 52 02             	lea    0x2(%edx),%edx
c0109f79:	83 eb 02             	sub    $0x2,%ebx
c0109f7c:	89 df                	mov    %ebx,%edi
c0109f7e:	83 e7 fc             	and    $0xfffffffc,%edi
c0109f81:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109f86:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0109f89:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0109f8c:	83 c1 04             	add    $0x4,%ecx
c0109f8f:	39 f9                	cmp    %edi,%ecx
c0109f91:	72 f3                	jb     c0109f86 <copy_thread+0x5e>
c0109f93:	01 c8                	add    %ecx,%eax
c0109f95:	01 ca                	add    %ecx,%edx
c0109f97:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109f9c:	89 de                	mov    %ebx,%esi
c0109f9e:	83 e6 02             	and    $0x2,%esi
c0109fa1:	85 f6                	test   %esi,%esi
c0109fa3:	74 0b                	je     c0109fb0 <copy_thread+0x88>
c0109fa5:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109fa9:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109fad:	83 c1 02             	add    $0x2,%ecx
c0109fb0:	83 e3 01             	and    $0x1,%ebx
c0109fb3:	85 db                	test   %ebx,%ebx
c0109fb5:	74 07                	je     c0109fbe <copy_thread+0x96>
c0109fb7:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109fbb:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109fbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fc1:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109fc4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109fcb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fce:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109fd1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109fd4:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109fd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fda:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109fdd:	8b 50 40             	mov    0x40(%eax),%edx
c0109fe0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fe3:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109fe6:	81 ca 00 02 00 00    	or     $0x200,%edx
c0109fec:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109fef:	ba 28 9b 10 c0       	mov    $0xc0109b28,%edx
c0109ff4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ff7:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109ffa:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ffd:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a000:	89 c2                	mov    %eax,%edx
c010a002:	8b 45 08             	mov    0x8(%ebp),%eax
c010a005:	89 50 20             	mov    %edx,0x20(%eax)
}
c010a008:	90                   	nop
c010a009:	5b                   	pop    %ebx
c010a00a:	5e                   	pop    %esi
c010a00b:	5f                   	pop    %edi
c010a00c:	5d                   	pop    %ebp
c010a00d:	c3                   	ret    

c010a00e <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010a00e:	55                   	push   %ebp
c010a00f:	89 e5                	mov    %esp,%ebp
c010a011:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c010a014:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010a01b:	a1 40 20 1a c0       	mov    0xc01a2040,%eax
c010a020:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010a025:	0f 8f e3 00 00 00    	jg     c010a10e <do_fork+0x100>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010a02b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if((proc = alloc_proc()) == NULL)
c010a032:	e8 ee f6 ff ff       	call   c0109725 <alloc_proc>
c010a037:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a03a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a03e:	0f 84 cd 00 00 00    	je     c010a111 <do_fork+0x103>
       goto fork_out;
    proc->parent = current;
c010a044:	8b 15 28 00 1a c0    	mov    0xc01a0028,%edx
c010a04a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a04d:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0);
c010a050:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a055:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a058:	85 c0                	test   %eax,%eax
c010a05a:	74 24                	je     c010a080 <do_fork+0x72>
c010a05c:	c7 44 24 0c 38 e1 10 	movl   $0xc010e138,0xc(%esp)
c010a063:	c0 
c010a064:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010a06b:	c0 
c010a06c:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
c010a073:	00 
c010a074:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a07b:	e8 80 63 ff ff       	call   c0100400 <__panic>
    if(setup_kstack(proc) != 0)
c010a080:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a083:	89 04 24             	mov    %eax,(%esp)
c010a086:	e8 4d fc ff ff       	call   c0109cd8 <setup_kstack>
c010a08b:	85 c0                	test   %eax,%eax
c010a08d:	0f 85 92 00 00 00    	jne    c010a125 <do_fork+0x117>
       goto bad_fork_cleanup_proc;
    if(copy_mm(clone_flags, proc) != 0)
c010a093:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a096:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a09a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a09d:	89 04 24             	mov    %eax,(%esp)
c010a0a0:	e8 64 fd ff ff       	call   c0109e09 <copy_mm>
c010a0a5:	85 c0                	test   %eax,%eax
c010a0a7:	75 6e                	jne    c010a117 <do_fork+0x109>
       goto bad_fork_cleanup_kstack;
    copy_thread(proc, stack, tf);
c010a0a9:	8b 45 10             	mov    0x10(%ebp),%eax
c010a0ac:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a0b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a0b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a0b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0ba:	89 04 24             	mov    %eax,(%esp)
c010a0bd:	e8 66 fe ff ff       	call   c0109f28 <copy_thread>
    bool intr_flag;
    local_intr_save(intr_flag);
c010a0c2:	e8 28 f4 ff ff       	call   c01094ef <__intr_save>
c010a0c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
       proc->pid = get_pid();
c010a0ca:	e8 ee f8 ff ff       	call   c01099bd <get_pid>
c010a0cf:	89 c2                	mov    %eax,%edx
c010a0d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0d4:	89 50 04             	mov    %edx,0x4(%eax)
       hash_proc(proc);
c010a0d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0da:	89 04 24             	mov    %eax,(%esp)
c010a0dd:	e8 5f fa ff ff       	call   c0109b41 <hash_proc>
       set_links(proc);
c010a0e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0e5:	89 04 24             	mov    %eax,(%esp)
c010a0e8:	e8 aa f7 ff ff       	call   c0109897 <set_links>
    }
    local_intr_restore(intr_flag);
c010a0ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0f0:	89 04 24             	mov    %eax,(%esp)
c010a0f3:	e8 21 f4 ff ff       	call   c0109519 <__intr_restore>
    wakeup_proc(proc);
c010a0f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0fb:	89 04 24             	mov    %eax,(%esp)
c010a0fe:	e8 d1 0f 00 00       	call   c010b0d4 <wakeup_proc>
    ret = proc->pid;
c010a103:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a106:	8b 40 04             	mov    0x4(%eax),%eax
c010a109:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a10c:	eb 04                	jmp    c010a112 <do_fork+0x104>
        goto fork_out;
c010a10e:	90                   	nop
c010a10f:	eb 01                	jmp    c010a112 <do_fork+0x104>
       goto fork_out;
c010a111:	90                   	nop
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
	
fork_out:
    return ret;
c010a112:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a115:	eb 1c                	jmp    c010a133 <do_fork+0x125>
       goto bad_fork_cleanup_kstack;
c010a117:	90                   	nop

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a118:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a11b:	89 04 24             	mov    %eax,(%esp)
c010a11e:	e8 f1 fb ff ff       	call   c0109d14 <put_kstack>
c010a123:	eb 01                	jmp    c010a126 <do_fork+0x118>
       goto bad_fork_cleanup_proc;
c010a125:	90                   	nop
bad_fork_cleanup_proc:
    kfree(proc);
c010a126:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a129:	89 04 24             	mov    %eax,(%esp)
c010a12c:	e8 3a b3 ff ff       	call   c010546b <kfree>
    goto fork_out;
c010a131:	eb df                	jmp    c010a112 <do_fork+0x104>
}
c010a133:	c9                   	leave  
c010a134:	c3                   	ret    

c010a135 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a135:	55                   	push   %ebp
c010a136:	89 e5                	mov    %esp,%ebp
c010a138:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c010a13b:	8b 15 28 00 1a c0    	mov    0xc01a0028,%edx
c010a141:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010a146:	39 c2                	cmp    %eax,%edx
c010a148:	75 1c                	jne    c010a166 <do_exit+0x31>
        panic("idleproc exit.\n");
c010a14a:	c7 44 24 08 66 e1 10 	movl   $0xc010e166,0x8(%esp)
c010a151:	c0 
c010a152:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
c010a159:	00 
c010a15a:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a161:	e8 9a 62 ff ff       	call   c0100400 <__panic>
    }
    if (current == initproc) {
c010a166:	8b 15 28 00 1a c0    	mov    0xc01a0028,%edx
c010a16c:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010a171:	39 c2                	cmp    %eax,%edx
c010a173:	75 1c                	jne    c010a191 <do_exit+0x5c>
        panic("initproc exit.\n");
c010a175:	c7 44 24 08 76 e1 10 	movl   $0xc010e176,0x8(%esp)
c010a17c:	c0 
c010a17d:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
c010a184:	00 
c010a185:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a18c:	e8 6f 62 ff ff       	call   c0100400 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c010a191:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a196:	8b 40 18             	mov    0x18(%eax),%eax
c010a199:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a19c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a1a0:	74 4a                	je     c010a1ec <do_exit+0xb7>
        lcr3(boot_cr3);
c010a1a2:	a1 54 21 1a c0       	mov    0xc01a2154,%eax
c010a1a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a1aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a1ad:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a1b3:	89 04 24             	mov    %eax,(%esp)
c010a1b6:	e8 16 f5 ff ff       	call   c01096d1 <mm_count_dec>
c010a1bb:	85 c0                	test   %eax,%eax
c010a1bd:	75 21                	jne    c010a1e0 <do_exit+0xab>
            exit_mmap(mm);
c010a1bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a1c2:	89 04 24             	mov    %eax,(%esp)
c010a1c5:	e8 c9 99 ff ff       	call   c0103b93 <exit_mmap>
            put_pgdir(mm);
c010a1ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a1cd:	89 04 24             	mov    %eax,(%esp)
c010a1d0:	e8 0d fc ff ff       	call   c0109de2 <put_pgdir>
            mm_destroy(mm);
c010a1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a1d8:	89 04 24             	mov    %eax,(%esp)
c010a1db:	e8 f7 96 ff ff       	call   c01038d7 <mm_destroy>
        }
        current->mm = NULL;
c010a1e0:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a1e5:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a1ec:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a1f1:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a1f7:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a1fc:	8b 55 08             	mov    0x8(%ebp),%edx
c010a1ff:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a202:	e8 e8 f2 ff ff       	call   c01094ef <__intr_save>
c010a207:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a20a:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a20f:	8b 40 14             	mov    0x14(%eax),%eax
c010a212:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a215:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a218:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a21b:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a220:	0f 85 96 00 00 00    	jne    c010a2bc <do_exit+0x187>
            wakeup_proc(proc);
c010a226:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a229:	89 04 24             	mov    %eax,(%esp)
c010a22c:	e8 a3 0e 00 00       	call   c010b0d4 <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a231:	e9 86 00 00 00       	jmp    c010a2bc <do_exit+0x187>
            proc = current->cptr;
c010a236:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a23b:	8b 40 70             	mov    0x70(%eax),%eax
c010a23e:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a241:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a246:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a249:	8b 52 78             	mov    0x78(%edx),%edx
c010a24c:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a24f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a252:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a259:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010a25e:	8b 50 70             	mov    0x70(%eax),%edx
c010a261:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a264:	89 50 78             	mov    %edx,0x78(%eax)
c010a267:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a26a:	8b 40 78             	mov    0x78(%eax),%eax
c010a26d:	85 c0                	test   %eax,%eax
c010a26f:	74 0e                	je     c010a27f <do_exit+0x14a>
                initproc->cptr->yptr = proc;
c010a271:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010a276:	8b 40 70             	mov    0x70(%eax),%eax
c010a279:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a27c:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a27f:	8b 15 24 00 1a c0    	mov    0xc01a0024,%edx
c010a285:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a288:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a28b:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010a290:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a293:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a296:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a299:	8b 00                	mov    (%eax),%eax
c010a29b:	83 f8 03             	cmp    $0x3,%eax
c010a29e:	75 1c                	jne    c010a2bc <do_exit+0x187>
                if (initproc->wait_state == WT_CHILD) {
c010a2a0:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010a2a5:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a2a8:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a2ad:	75 0d                	jne    c010a2bc <do_exit+0x187>
                    wakeup_proc(initproc);
c010a2af:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010a2b4:	89 04 24             	mov    %eax,(%esp)
c010a2b7:	e8 18 0e 00 00       	call   c010b0d4 <wakeup_proc>
        while (current->cptr != NULL) {
c010a2bc:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a2c1:	8b 40 70             	mov    0x70(%eax),%eax
c010a2c4:	85 c0                	test   %eax,%eax
c010a2c6:	0f 85 6a ff ff ff    	jne    c010a236 <do_exit+0x101>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a2cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2cf:	89 04 24             	mov    %eax,(%esp)
c010a2d2:	e8 42 f2 ff ff       	call   c0109519 <__intr_restore>
    
    schedule();
c010a2d7:	e8 7d 0e 00 00       	call   c010b159 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a2dc:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a2e1:	8b 40 04             	mov    0x4(%eax),%eax
c010a2e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a2e8:	c7 44 24 08 88 e1 10 	movl   $0xc010e188,0x8(%esp)
c010a2ef:	c0 
c010a2f0:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c010a2f7:	00 
c010a2f8:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a2ff:	e8 fc 60 ff ff       	call   c0100400 <__panic>

c010a304 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a304:	55                   	push   %ebp
c010a305:	89 e5                	mov    %esp,%ebp
c010a307:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a30a:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a30f:	8b 40 18             	mov    0x18(%eax),%eax
c010a312:	85 c0                	test   %eax,%eax
c010a314:	74 1c                	je     c010a332 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a316:	c7 44 24 08 a8 e1 10 	movl   $0xc010e1a8,0x8(%esp)
c010a31d:	c0 
c010a31e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c010a325:	00 
c010a326:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a32d:	e8 ce 60 ff ff       	call   c0100400 <__panic>
    }

    int ret = -E_NO_MEM;
c010a332:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a339:	e8 3d 92 ff ff       	call   c010357b <mm_create>
c010a33e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a341:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a345:	0f 84 13 06 00 00    	je     c010a95e <load_icode+0x65a>
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a34b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a34e:	89 04 24             	mov    %eax,(%esp)
c010a351:	e8 e5 f9 ff ff       	call   c0109d3b <setup_pgdir>
c010a356:	85 c0                	test   %eax,%eax
c010a358:	0f 85 f2 05 00 00    	jne    c010a950 <load_icode+0x64c>
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a35e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a361:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a364:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a367:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a36a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a36d:	01 d0                	add    %edx,%eax
c010a36f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a372:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a375:	8b 00                	mov    (%eax),%eax
c010a377:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a37c:	74 0c                	je     c010a38a <load_icode+0x86>
        ret = -E_INVAL_ELF;
c010a37e:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a385:	e9 b9 05 00 00       	jmp    c010a943 <load_icode+0x63f>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a38a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a38d:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a391:	c1 e0 05             	shl    $0x5,%eax
c010a394:	89 c2                	mov    %eax,%edx
c010a396:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a399:	01 d0                	add    %edx,%eax
c010a39b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a39e:	e9 07 03 00 00       	jmp    c010a6aa <load_icode+0x3a6>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a3a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3a6:	8b 00                	mov    (%eax),%eax
c010a3a8:	83 f8 01             	cmp    $0x1,%eax
c010a3ab:	0f 85 ee 02 00 00    	jne    c010a69f <load_icode+0x39b>
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a3b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3b4:	8b 50 10             	mov    0x10(%eax),%edx
c010a3b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3ba:	8b 40 14             	mov    0x14(%eax),%eax
c010a3bd:	39 c2                	cmp    %eax,%edx
c010a3bf:	76 0c                	jbe    c010a3cd <load_icode+0xc9>
            ret = -E_INVAL_ELF;
c010a3c1:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a3c8:	e9 6b 05 00 00       	jmp    c010a938 <load_icode+0x634>
        }
        if (ph->p_filesz == 0) {
c010a3cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3d0:	8b 40 10             	mov    0x10(%eax),%eax
c010a3d3:	85 c0                	test   %eax,%eax
c010a3d5:	0f 84 c7 02 00 00    	je     c010a6a2 <load_icode+0x39e>
            continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a3db:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a3e2:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a3e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3ec:	8b 40 18             	mov    0x18(%eax),%eax
c010a3ef:	83 e0 01             	and    $0x1,%eax
c010a3f2:	85 c0                	test   %eax,%eax
c010a3f4:	74 04                	je     c010a3fa <load_icode+0xf6>
c010a3f6:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a3fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3fd:	8b 40 18             	mov    0x18(%eax),%eax
c010a400:	83 e0 02             	and    $0x2,%eax
c010a403:	85 c0                	test   %eax,%eax
c010a405:	74 04                	je     c010a40b <load_icode+0x107>
c010a407:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a40b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a40e:	8b 40 18             	mov    0x18(%eax),%eax
c010a411:	83 e0 04             	and    $0x4,%eax
c010a414:	85 c0                	test   %eax,%eax
c010a416:	74 04                	je     c010a41c <load_icode+0x118>
c010a418:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a41c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a41f:	83 e0 02             	and    $0x2,%eax
c010a422:	85 c0                	test   %eax,%eax
c010a424:	74 04                	je     c010a42a <load_icode+0x126>
c010a426:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a42a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a42d:	8b 50 14             	mov    0x14(%eax),%edx
c010a430:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a433:	8b 40 08             	mov    0x8(%eax),%eax
c010a436:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a43d:	00 
c010a43e:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a441:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a445:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a449:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a44d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a450:	89 04 24             	mov    %eax,(%esp)
c010a453:	e8 22 95 ff ff       	call   c010397a <mm_map>
c010a458:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a45b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a45f:	0f 85 c9 04 00 00    	jne    c010a92e <load_icode+0x62a>
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
c010a465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a468:	8b 50 04             	mov    0x4(%eax),%edx
c010a46b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a46e:	01 d0                	add    %edx,%eax
c010a470:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a473:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a476:	8b 40 08             	mov    0x8(%eax),%eax
c010a479:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a47c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a47f:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010a482:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a485:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a48a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a48d:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a494:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a497:	8b 50 08             	mov    0x8(%eax),%edx
c010a49a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a49d:	8b 40 10             	mov    0x10(%eax),%eax
c010a4a0:	01 d0                	add    %edx,%eax
c010a4a2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a4a5:	e9 89 00 00 00       	jmp    c010a533 <load_icode+0x22f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a4aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4ad:	8b 40 0c             	mov    0xc(%eax),%eax
c010a4b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a4b3:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a4b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a4ba:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a4be:	89 04 24             	mov    %eax,(%esp)
c010a4c1:	e8 83 e0 ff ff       	call   c0108549 <pgdir_alloc_page>
c010a4c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a4c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a4cd:	0f 84 5e 04 00 00    	je     c010a931 <load_icode+0x62d>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a4d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4d6:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a4d9:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a4dc:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a4e1:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a4e4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a4e7:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a4ee:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a4f1:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4f4:	73 09                	jae    c010a4ff <load_icode+0x1fb>
                size -= la - end;
c010a4f6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a4f9:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a4fc:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a4ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a502:	89 04 24             	mov    %eax,(%esp)
c010a505:	e8 0f f1 ff ff       	call   c0109619 <page2kva>
c010a50a:	89 c2                	mov    %eax,%edx
c010a50c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a50f:	01 c2                	add    %eax,%edx
c010a511:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a514:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a518:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a51b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a51f:	89 14 24             	mov    %edx,(%esp)
c010a522:	e8 f9 12 00 00       	call   c010b820 <memcpy>
            start += size, from += size;
c010a527:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a52a:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a52d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a530:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end) {
c010a533:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a536:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a539:	0f 82 6b ff ff ff    	jb     c010a4aa <load_icode+0x1a6>
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a53f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a542:	8b 50 08             	mov    0x8(%eax),%edx
c010a545:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a548:	8b 40 14             	mov    0x14(%eax),%eax
c010a54b:	01 d0                	add    %edx,%eax
c010a54d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        if (start < la) {
c010a550:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a553:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a556:	0f 83 35 01 00 00    	jae    c010a691 <load_icode+0x38d>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a55c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a55f:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a562:	0f 84 3d 01 00 00    	je     c010a6a5 <load_icode+0x3a1>
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a568:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a56b:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a56e:	05 00 10 00 00       	add    $0x1000,%eax
c010a573:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a576:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a57b:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a57e:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a581:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a584:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a587:	73 09                	jae    c010a592 <load_icode+0x28e>
                size -= la - end;
c010a589:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a58c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a58f:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a592:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a595:	89 04 24             	mov    %eax,(%esp)
c010a598:	e8 7c f0 ff ff       	call   c0109619 <page2kva>
c010a59d:	89 c2                	mov    %eax,%edx
c010a59f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a5a2:	01 c2                	add    %eax,%edx
c010a5a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a5a7:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a5ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a5b2:	00 
c010a5b3:	89 14 24             	mov    %edx,(%esp)
c010a5b6:	e8 82 11 00 00       	call   c010b73d <memset>
            start += size;
c010a5bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a5be:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a5c1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a5c4:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a5c7:	73 0c                	jae    c010a5d5 <load_icode+0x2d1>
c010a5c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a5cc:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a5cf:	0f 84 bc 00 00 00    	je     c010a691 <load_icode+0x38d>
c010a5d5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a5d8:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a5db:	72 0c                	jb     c010a5e9 <load_icode+0x2e5>
c010a5dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a5e0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a5e3:	0f 84 a8 00 00 00    	je     c010a691 <load_icode+0x38d>
c010a5e9:	c7 44 24 0c d0 e1 10 	movl   $0xc010e1d0,0xc(%esp)
c010a5f0:	c0 
c010a5f1:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010a5f8:	c0 
c010a5f9:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c010a600:	00 
c010a601:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a608:	e8 f3 5d ff ff       	call   c0100400 <__panic>
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a60d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a610:	8b 40 0c             	mov    0xc(%eax),%eax
c010a613:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a616:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a61a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a61d:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a621:	89 04 24             	mov    %eax,(%esp)
c010a624:	e8 20 df ff ff       	call   c0108549 <pgdir_alloc_page>
c010a629:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a62c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a630:	0f 84 fe 02 00 00    	je     c010a934 <load_icode+0x630>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a636:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a639:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a63c:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a63f:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a644:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a647:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a64a:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a651:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a654:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a657:	73 09                	jae    c010a662 <load_icode+0x35e>
                size -= la - end;
c010a659:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a65c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a65f:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a662:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a665:	89 04 24             	mov    %eax,(%esp)
c010a668:	e8 ac ef ff ff       	call   c0109619 <page2kva>
c010a66d:	89 c2                	mov    %eax,%edx
c010a66f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a672:	01 c2                	add    %eax,%edx
c010a674:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a677:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a67b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a682:	00 
c010a683:	89 14 24             	mov    %edx,(%esp)
c010a686:	e8 b2 10 00 00       	call   c010b73d <memset>
            start += size;
c010a68b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a68e:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end) {
c010a691:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a694:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a697:	0f 82 70 ff ff ff    	jb     c010a60d <load_icode+0x309>
c010a69d:	eb 07                	jmp    c010a6a6 <load_icode+0x3a2>
            continue ;
c010a69f:	90                   	nop
c010a6a0:	eb 04                	jmp    c010a6a6 <load_icode+0x3a2>
            continue ;
c010a6a2:	90                   	nop
c010a6a3:	eb 01                	jmp    c010a6a6 <load_icode+0x3a2>
                continue ;
c010a6a5:	90                   	nop
    for (; ph < ph_end; ph ++) {
c010a6a6:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a6aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a6ad:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a6b0:	0f 82 ed fc ff ff    	jb     c010a3a3 <load_icode+0x9f>
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a6b6:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a6bd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a6c4:	00 
c010a6c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a6c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a6cc:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a6d3:	00 
c010a6d4:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a6db:	af 
c010a6dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6df:	89 04 24             	mov    %eax,(%esp)
c010a6e2:	e8 93 92 ff ff       	call   c010397a <mm_map>
c010a6e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a6ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a6ee:	0f 85 43 02 00 00    	jne    c010a937 <load_icode+0x633>
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a6f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6f7:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6fa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a701:	00 
c010a702:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a709:	af 
c010a70a:	89 04 24             	mov    %eax,(%esp)
c010a70d:	e8 37 de ff ff       	call   c0108549 <pgdir_alloc_page>
c010a712:	85 c0                	test   %eax,%eax
c010a714:	75 24                	jne    c010a73a <load_icode+0x436>
c010a716:	c7 44 24 0c 0c e2 10 	movl   $0xc010e20c,0xc(%esp)
c010a71d:	c0 
c010a71e:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010a725:	c0 
c010a726:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
c010a72d:	00 
c010a72e:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a735:	e8 c6 5c ff ff       	call   c0100400 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a73a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a73d:	8b 40 0c             	mov    0xc(%eax),%eax
c010a740:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a747:	00 
c010a748:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a74f:	af 
c010a750:	89 04 24             	mov    %eax,(%esp)
c010a753:	e8 f1 dd ff ff       	call   c0108549 <pgdir_alloc_page>
c010a758:	85 c0                	test   %eax,%eax
c010a75a:	75 24                	jne    c010a780 <load_icode+0x47c>
c010a75c:	c7 44 24 0c 50 e2 10 	movl   $0xc010e250,0xc(%esp)
c010a763:	c0 
c010a764:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010a76b:	c0 
c010a76c:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
c010a773:	00 
c010a774:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a77b:	e8 80 5c ff ff       	call   c0100400 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a780:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a783:	8b 40 0c             	mov    0xc(%eax),%eax
c010a786:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a78d:	00 
c010a78e:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a795:	af 
c010a796:	89 04 24             	mov    %eax,(%esp)
c010a799:	e8 ab dd ff ff       	call   c0108549 <pgdir_alloc_page>
c010a79e:	85 c0                	test   %eax,%eax
c010a7a0:	75 24                	jne    c010a7c6 <load_icode+0x4c2>
c010a7a2:	c7 44 24 0c 94 e2 10 	movl   $0xc010e294,0xc(%esp)
c010a7a9:	c0 
c010a7aa:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010a7b1:	c0 
c010a7b2:	c7 44 24 04 6a 02 00 	movl   $0x26a,0x4(%esp)
c010a7b9:	00 
c010a7ba:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a7c1:	e8 3a 5c ff ff       	call   c0100400 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a7c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7c9:	8b 40 0c             	mov    0xc(%eax),%eax
c010a7cc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a7d3:	00 
c010a7d4:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a7db:	af 
c010a7dc:	89 04 24             	mov    %eax,(%esp)
c010a7df:	e8 65 dd ff ff       	call   c0108549 <pgdir_alloc_page>
c010a7e4:	85 c0                	test   %eax,%eax
c010a7e6:	75 24                	jne    c010a80c <load_icode+0x508>
c010a7e8:	c7 44 24 0c d8 e2 10 	movl   $0xc010e2d8,0xc(%esp)
c010a7ef:	c0 
c010a7f0:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010a7f7:	c0 
c010a7f8:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
c010a7ff:	00 
c010a800:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a807:	e8 f4 5b ff ff       	call   c0100400 <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a80c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a80f:	89 04 24             	mov    %eax,(%esp)
c010a812:	e8 a0 ee ff ff       	call   c01096b7 <mm_count_inc>
    current->mm = mm;
c010a817:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a81c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a81f:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a822:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a825:	8b 40 0c             	mov    0xc(%eax),%eax
c010a828:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a82b:	81 7d c4 ff ff ff bf 	cmpl   $0xbfffffff,-0x3c(%ebp)
c010a832:	77 23                	ja     c010a857 <load_icode+0x553>
c010a834:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a837:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a83b:	c7 44 24 08 00 e1 10 	movl   $0xc010e100,0x8(%esp)
c010a842:	c0 
c010a843:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c010a84a:	00 
c010a84b:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a852:	e8 a9 5b ff ff       	call   c0100400 <__panic>
c010a857:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a85a:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010a860:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a865:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a868:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a86b:	8b 40 0c             	mov    0xc(%eax),%eax
c010a86e:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010a871:	81 7d c0 ff ff ff bf 	cmpl   $0xbfffffff,-0x40(%ebp)
c010a878:	77 23                	ja     c010a89d <load_icode+0x599>
c010a87a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a87d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a881:	c7 44 24 08 00 e1 10 	movl   $0xc010e100,0x8(%esp)
c010a888:	c0 
c010a889:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c010a890:	00 
c010a891:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010a898:	e8 63 5b ff ff       	call   c0100400 <__panic>
c010a89d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a8a0:	05 00 00 00 40       	add    $0x40000000,%eax
c010a8a5:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a8a8:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a8ab:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a8ae:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a8b3:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a8b6:	89 45 bc             	mov    %eax,-0x44(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a8b9:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a8c0:	00 
c010a8c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a8c8:	00 
c010a8c9:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8cc:	89 04 24             	mov    %eax,(%esp)
c010a8cf:	e8 69 0e 00 00       	call   c010b73d <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010a8d4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8d7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a8dd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8e0:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a8e6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8e9:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a8ed:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8f0:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a8f4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8f7:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a8fb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a8fe:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a902:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a905:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a90c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a90f:	8b 50 18             	mov    0x18(%eax),%edx
c010a912:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a915:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a918:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a91b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a929:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a92c:	eb 33                	jmp    c010a961 <load_icode+0x65d>
            goto bad_cleanup_mmap;
c010a92e:	90                   	nop
c010a92f:	eb 07                	jmp    c010a938 <load_icode+0x634>
                goto bad_cleanup_mmap;
c010a931:	90                   	nop
c010a932:	eb 04                	jmp    c010a938 <load_icode+0x634>
                goto bad_cleanup_mmap;
c010a934:	90                   	nop
c010a935:	eb 01                	jmp    c010a938 <load_icode+0x634>
        goto bad_cleanup_mmap;
c010a937:	90                   	nop
bad_cleanup_mmap:
    exit_mmap(mm);
c010a938:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a93b:	89 04 24             	mov    %eax,(%esp)
c010a93e:	e8 50 92 ff ff       	call   c0103b93 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a943:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a946:	89 04 24             	mov    %eax,(%esp)
c010a949:	e8 94 f4 ff ff       	call   c0109de2 <put_pgdir>
c010a94e:	eb 01                	jmp    c010a951 <load_icode+0x64d>
        goto bad_pgdir_cleanup_mm;
c010a950:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a951:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a954:	89 04 24             	mov    %eax,(%esp)
c010a957:	e8 7b 8f ff ff       	call   c01038d7 <mm_destroy>
bad_mm:
    goto out;
c010a95c:	eb cb                	jmp    c010a929 <load_icode+0x625>
        goto bad_mm;
c010a95e:	90                   	nop
    goto out;
c010a95f:	eb c8                	jmp    c010a929 <load_icode+0x625>
}
c010a961:	c9                   	leave  
c010a962:	c3                   	ret    

c010a963 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a963:	55                   	push   %ebp
c010a964:	89 e5                	mov    %esp,%ebp
c010a966:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a969:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010a96e:	8b 40 18             	mov    0x18(%eax),%eax
c010a971:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a974:	8b 45 08             	mov    0x8(%ebp),%eax
c010a977:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a97e:	00 
c010a97f:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a982:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a986:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a98a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a98d:	89 04 24             	mov    %eax,(%esp)
c010a990:	e8 9a 9c ff ff       	call   c010462f <user_mem_check>
c010a995:	85 c0                	test   %eax,%eax
c010a997:	75 0a                	jne    c010a9a3 <do_execve+0x40>
        return -E_INVAL;
c010a999:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a99e:	e9 f6 00 00 00       	jmp    c010aa99 <do_execve+0x136>
    }
    if (len > PROC_NAME_LEN) {
c010a9a3:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a9a7:	76 07                	jbe    c010a9b0 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a9a9:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a9b0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a9b7:	00 
c010a9b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a9bf:	00 
c010a9c0:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a9c3:	89 04 24             	mov    %eax,(%esp)
c010a9c6:	e8 72 0d 00 00       	call   c010b73d <memset>
    memcpy(local_name, name, len);
c010a9cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9ce:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a9d2:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a9d9:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a9dc:	89 04 24             	mov    %eax,(%esp)
c010a9df:	e8 3c 0e 00 00       	call   c010b820 <memcpy>

    if (mm != NULL) {
c010a9e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a9e8:	74 4a                	je     c010aa34 <do_execve+0xd1>
        lcr3(boot_cr3);
c010a9ea:	a1 54 21 1a c0       	mov    0xc01a2154,%eax
c010a9ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a9f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a9f5:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9fb:	89 04 24             	mov    %eax,(%esp)
c010a9fe:	e8 ce ec ff ff       	call   c01096d1 <mm_count_dec>
c010aa03:	85 c0                	test   %eax,%eax
c010aa05:	75 21                	jne    c010aa28 <do_execve+0xc5>
            exit_mmap(mm);
c010aa07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa0a:	89 04 24             	mov    %eax,(%esp)
c010aa0d:	e8 81 91 ff ff       	call   c0103b93 <exit_mmap>
            put_pgdir(mm);
c010aa12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa15:	89 04 24             	mov    %eax,(%esp)
c010aa18:	e8 c5 f3 ff ff       	call   c0109de2 <put_pgdir>
            mm_destroy(mm);
c010aa1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa20:	89 04 24             	mov    %eax,(%esp)
c010aa23:	e8 af 8e ff ff       	call   c01038d7 <mm_destroy>
        }
        current->mm = NULL;
c010aa28:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010aa2d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010aa34:	8b 45 14             	mov    0x14(%ebp),%eax
c010aa37:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa3b:	8b 45 10             	mov    0x10(%ebp),%eax
c010aa3e:	89 04 24             	mov    %eax,(%esp)
c010aa41:	e8 be f8 ff ff       	call   c010a304 <load_icode>
c010aa46:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aa49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010aa4d:	75 1b                	jne    c010aa6a <do_execve+0x107>
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010aa4f:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010aa54:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010aa57:	89 54 24 04          	mov    %edx,0x4(%esp)
c010aa5b:	89 04 24             	mov    %eax,(%esp)
c010aa5e:	e8 af ed ff ff       	call   c0109812 <set_proc_name>
    return 0;
c010aa63:	b8 00 00 00 00       	mov    $0x0,%eax
c010aa68:	eb 2f                	jmp    c010aa99 <do_execve+0x136>
        goto execve_exit;
c010aa6a:	90                   	nop

execve_exit:
    do_exit(ret);
c010aa6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aa6e:	89 04 24             	mov    %eax,(%esp)
c010aa71:	e8 bf f6 ff ff       	call   c010a135 <do_exit>
    panic("already exit: %e.\n", ret);
c010aa76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aa79:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010aa7d:	c7 44 24 08 1b e3 10 	movl   $0xc010e31b,0x8(%esp)
c010aa84:	c0 
c010aa85:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
c010aa8c:	00 
c010aa8d:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010aa94:	e8 67 59 ff ff       	call   c0100400 <__panic>
}
c010aa99:	c9                   	leave  
c010aa9a:	c3                   	ret    

c010aa9b <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010aa9b:	55                   	push   %ebp
c010aa9c:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010aa9e:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010aaa3:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010aaaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aaaf:	5d                   	pop    %ebp
c010aab0:	c3                   	ret    

c010aab1 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010aab1:	55                   	push   %ebp
c010aab2:	89 e5                	mov    %esp,%ebp
c010aab4:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010aab7:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010aabc:	8b 40 18             	mov    0x18(%eax),%eax
c010aabf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010aac2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aac6:	74 30                	je     c010aaf8 <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010aac8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aacb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010aad2:	00 
c010aad3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010aada:	00 
c010aadb:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aadf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aae2:	89 04 24             	mov    %eax,(%esp)
c010aae5:	e8 45 9b ff ff       	call   c010462f <user_mem_check>
c010aaea:	85 c0                	test   %eax,%eax
c010aaec:	75 0a                	jne    c010aaf8 <do_wait+0x47>
            return -E_INVAL;
c010aaee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aaf3:	e9 47 01 00 00       	jmp    c010ac3f <do_wait+0x18e>
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
c010aaf8:	90                   	nop
    haskid = 0;
c010aaf9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010ab00:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010ab04:	74 36                	je     c010ab3c <do_wait+0x8b>
        proc = find_proc(pid);
c010ab06:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab09:	89 04 24             	mov    %eax,(%esp)
c010ab0c:	e8 e1 f0 ff ff       	call   c0109bf2 <find_proc>
c010ab11:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010ab14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ab18:	74 4f                	je     c010ab69 <do_wait+0xb8>
c010ab1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab1d:	8b 50 14             	mov    0x14(%eax),%edx
c010ab20:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010ab25:	39 c2                	cmp    %eax,%edx
c010ab27:	75 40                	jne    c010ab69 <do_wait+0xb8>
            haskid = 1;
c010ab29:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010ab30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab33:	8b 00                	mov    (%eax),%eax
c010ab35:	83 f8 03             	cmp    $0x3,%eax
c010ab38:	75 2f                	jne    c010ab69 <do_wait+0xb8>
                goto found;
c010ab3a:	eb 7e                	jmp    c010abba <do_wait+0x109>
            }
        }
    }
    else {
        proc = current->cptr;
c010ab3c:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010ab41:	8b 40 70             	mov    0x70(%eax),%eax
c010ab44:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010ab47:	eb 1a                	jmp    c010ab63 <do_wait+0xb2>
            haskid = 1;
c010ab49:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010ab50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab53:	8b 00                	mov    (%eax),%eax
c010ab55:	83 f8 03             	cmp    $0x3,%eax
c010ab58:	74 5f                	je     c010abb9 <do_wait+0x108>
        for (; proc != NULL; proc = proc->optr) {
c010ab5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab5d:	8b 40 78             	mov    0x78(%eax),%eax
c010ab60:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ab63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ab67:	75 e0                	jne    c010ab49 <do_wait+0x98>
                goto found;
            }
        }
    }
    if (haskid) {
c010ab69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ab6d:	74 40                	je     c010abaf <do_wait+0xfe>
        current->state = PROC_SLEEPING;
c010ab6f:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010ab74:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010ab7a:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010ab7f:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010ab86:	e8 ce 05 00 00       	call   c010b159 <schedule>
        if (current->flags & PF_EXITING) {
c010ab8b:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010ab90:	8b 40 44             	mov    0x44(%eax),%eax
c010ab93:	83 e0 01             	and    $0x1,%eax
c010ab96:	85 c0                	test   %eax,%eax
c010ab98:	0f 84 5b ff ff ff    	je     c010aaf9 <do_wait+0x48>
            do_exit(-E_KILLED);
c010ab9e:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010aba5:	e8 8b f5 ff ff       	call   c010a135 <do_exit>
        }
        goto repeat;
c010abaa:	e9 4a ff ff ff       	jmp    c010aaf9 <do_wait+0x48>
    }
    return -E_BAD_PROC;
c010abaf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010abb4:	e9 86 00 00 00       	jmp    c010ac3f <do_wait+0x18e>
                goto found;
c010abb9:	90                   	nop

found:
    if (proc == idleproc || proc == initproc) {
c010abba:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010abbf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010abc2:	74 0a                	je     c010abce <do_wait+0x11d>
c010abc4:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010abc9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010abcc:	75 1c                	jne    c010abea <do_wait+0x139>
        panic("wait idleproc or initproc.\n");
c010abce:	c7 44 24 08 2e e3 10 	movl   $0xc010e32e,0x8(%esp)
c010abd5:	c0 
c010abd6:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
c010abdd:	00 
c010abde:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010abe5:	e8 16 58 ff ff       	call   c0100400 <__panic>
    }
    if (code_store != NULL) {
c010abea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010abee:	74 0b                	je     c010abfb <do_wait+0x14a>
        *code_store = proc->exit_code;
c010abf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abf3:	8b 50 68             	mov    0x68(%eax),%edx
c010abf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abf9:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010abfb:	e8 ef e8 ff ff       	call   c01094ef <__intr_save>
c010ac00:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010ac03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac06:	89 04 24             	mov    %eax,(%esp)
c010ac09:	e8 b0 ef ff ff       	call   c0109bbe <unhash_proc>
        remove_links(proc);
c010ac0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac11:	89 04 24             	mov    %eax,(%esp)
c010ac14:	e8 22 ed ff ff       	call   c010993b <remove_links>
    }
    local_intr_restore(intr_flag);
c010ac19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ac1c:	89 04 24             	mov    %eax,(%esp)
c010ac1f:	e8 f5 e8 ff ff       	call   c0109519 <__intr_restore>
    put_kstack(proc);
c010ac24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac27:	89 04 24             	mov    %eax,(%esp)
c010ac2a:	e8 e5 f0 ff ff       	call   c0109d14 <put_kstack>
    kfree(proc);
c010ac2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac32:	89 04 24             	mov    %eax,(%esp)
c010ac35:	e8 31 a8 ff ff       	call   c010546b <kfree>
    return 0;
c010ac3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ac3f:	c9                   	leave  
c010ac40:	c3                   	ret    

c010ac41 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010ac41:	55                   	push   %ebp
c010ac42:	89 e5                	mov    %esp,%ebp
c010ac44:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010ac47:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac4a:	89 04 24             	mov    %eax,(%esp)
c010ac4d:	e8 a0 ef ff ff       	call   c0109bf2 <find_proc>
c010ac52:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ac55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ac59:	74 41                	je     c010ac9c <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010ac5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac5e:	8b 40 44             	mov    0x44(%eax),%eax
c010ac61:	83 e0 01             	and    $0x1,%eax
c010ac64:	85 c0                	test   %eax,%eax
c010ac66:	75 2d                	jne    c010ac95 <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010ac68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac6b:	8b 40 44             	mov    0x44(%eax),%eax
c010ac6e:	83 c8 01             	or     $0x1,%eax
c010ac71:	89 c2                	mov    %eax,%edx
c010ac73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac76:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010ac79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac7c:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ac7f:	85 c0                	test   %eax,%eax
c010ac81:	79 0b                	jns    c010ac8e <do_kill+0x4d>
                wakeup_proc(proc);
c010ac83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac86:	89 04 24             	mov    %eax,(%esp)
c010ac89:	e8 46 04 00 00       	call   c010b0d4 <wakeup_proc>
            }
            return 0;
c010ac8e:	b8 00 00 00 00       	mov    $0x0,%eax
c010ac93:	eb 0c                	jmp    c010aca1 <do_kill+0x60>
        }
        return -E_KILLED;
c010ac95:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010ac9a:	eb 05                	jmp    c010aca1 <do_kill+0x60>
    }
    return -E_INVAL;
c010ac9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010aca1:	c9                   	leave  
c010aca2:	c3                   	ret    

c010aca3 <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010aca3:	55                   	push   %ebp
c010aca4:	89 e5                	mov    %esp,%ebp
c010aca6:	57                   	push   %edi
c010aca7:	56                   	push   %esi
c010aca8:	53                   	push   %ebx
c010aca9:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010acac:	8b 45 08             	mov    0x8(%ebp),%eax
c010acaf:	89 04 24             	mov    %eax,(%esp)
c010acb2:	e8 66 07 00 00       	call   c010b41d <strlen>
c010acb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010acba:	b8 04 00 00 00       	mov    $0x4,%eax
c010acbf:	8b 55 08             	mov    0x8(%ebp),%edx
c010acc2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010acc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010acc8:	8b 75 10             	mov    0x10(%ebp),%esi
c010accb:	89 f7                	mov    %esi,%edi
c010accd:	cd 80                	int    $0x80
c010accf:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010acd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010acd5:	83 c4 2c             	add    $0x2c,%esp
c010acd8:	5b                   	pop    %ebx
c010acd9:	5e                   	pop    %esi
c010acda:	5f                   	pop    %edi
c010acdb:	5d                   	pop    %ebp
c010acdc:	c3                   	ret    

c010acdd <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010acdd:	55                   	push   %ebp
c010acde:	89 e5                	mov    %esp,%ebp
c010ace0:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
c010ace3:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010ace8:	8b 40 04             	mov    0x4(%eax),%eax
c010aceb:	c7 44 24 08 4a e3 10 	movl   $0xc010e34a,0x8(%esp)
c010acf2:	c0 
c010acf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010acf7:	c7 04 24 50 e3 10 c0 	movl   $0xc010e350,(%esp)
c010acfe:	e8 a6 55 ff ff       	call   c01002a9 <cprintf>
c010ad03:	b8 70 78 00 00       	mov    $0x7870,%eax
c010ad08:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ad0c:	c7 44 24 04 40 15 15 	movl   $0xc0151540,0x4(%esp)
c010ad13:	c0 
c010ad14:	c7 04 24 4a e3 10 c0 	movl   $0xc010e34a,(%esp)
c010ad1b:	e8 83 ff ff ff       	call   c010aca3 <kernel_execve>
#endif
    panic("user_main execve failed.\n");
c010ad20:	c7 44 24 08 77 e3 10 	movl   $0xc010e377,0x8(%esp)
c010ad27:	c0 
c010ad28:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
c010ad2f:	00 
c010ad30:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010ad37:	e8 c4 56 ff ff       	call   c0100400 <__panic>

c010ad3c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ad3c:	55                   	push   %ebp
c010ad3d:	89 e5                	mov    %esp,%ebp
c010ad3f:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ad42:	e8 52 ca ff ff       	call   c0107799 <nr_free_pages>
c010ad47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ad4a:	e8 de a5 ff ff       	call   c010532d <kallocated>
c010ad4f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ad52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ad59:	00 
c010ad5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ad61:	00 
c010ad62:	c7 04 24 dd ac 10 c0 	movl   $0xc010acdd,(%esp)
c010ad69:	e8 f6 ee ff ff       	call   c0109c64 <kernel_thread>
c010ad6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ad71:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ad75:	7f 21                	jg     c010ad98 <init_main+0x5c>
        panic("create user_main failed.\n");
c010ad77:	c7 44 24 08 91 e3 10 	movl   $0xc010e391,0x8(%esp)
c010ad7e:	c0 
c010ad7f:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
c010ad86:	00 
c010ad87:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010ad8e:	e8 6d 56 ff ff       	call   c0100400 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
c010ad93:	e8 c1 03 00 00       	call   c010b159 <schedule>
    while (do_wait(0, NULL) == 0) {
c010ad98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ad9f:	00 
c010ada0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ada7:	e8 05 fd ff ff       	call   c010aab1 <do_wait>
c010adac:	85 c0                	test   %eax,%eax
c010adae:	74 e3                	je     c010ad93 <init_main+0x57>
    }

    cprintf("all user-mode processes have quit.\n");
c010adb0:	c7 04 24 ac e3 10 c0 	movl   $0xc010e3ac,(%esp)
c010adb7:	e8 ed 54 ff ff       	call   c01002a9 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010adbc:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010adc1:	8b 40 70             	mov    0x70(%eax),%eax
c010adc4:	85 c0                	test   %eax,%eax
c010adc6:	75 18                	jne    c010ade0 <init_main+0xa4>
c010adc8:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010adcd:	8b 40 74             	mov    0x74(%eax),%eax
c010add0:	85 c0                	test   %eax,%eax
c010add2:	75 0c                	jne    c010ade0 <init_main+0xa4>
c010add4:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010add9:	8b 40 78             	mov    0x78(%eax),%eax
c010addc:	85 c0                	test   %eax,%eax
c010adde:	74 24                	je     c010ae04 <init_main+0xc8>
c010ade0:	c7 44 24 0c d0 e3 10 	movl   $0xc010e3d0,0xc(%esp)
c010ade7:	c0 
c010ade8:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010adef:	c0 
c010adf0:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
c010adf7:	00 
c010adf8:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010adff:	e8 fc 55 ff ff       	call   c0100400 <__panic>
    assert(nr_process == 2);
c010ae04:	a1 40 20 1a c0       	mov    0xc01a2040,%eax
c010ae09:	83 f8 02             	cmp    $0x2,%eax
c010ae0c:	74 24                	je     c010ae32 <init_main+0xf6>
c010ae0e:	c7 44 24 0c 1b e4 10 	movl   $0xc010e41b,0xc(%esp)
c010ae15:	c0 
c010ae16:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010ae1d:	c0 
c010ae1e:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
c010ae25:	00 
c010ae26:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010ae2d:	e8 ce 55 ff ff       	call   c0100400 <__panic>
c010ae32:	c7 45 e8 5c 21 1a c0 	movl   $0xc01a215c,-0x18(%ebp)
c010ae39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae3c:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ae3f:	8b 15 24 00 1a c0    	mov    0xc01a0024,%edx
c010ae45:	83 c2 58             	add    $0x58,%edx
c010ae48:	39 d0                	cmp    %edx,%eax
c010ae4a:	74 24                	je     c010ae70 <init_main+0x134>
c010ae4c:	c7 44 24 0c 2c e4 10 	movl   $0xc010e42c,0xc(%esp)
c010ae53:	c0 
c010ae54:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010ae5b:	c0 
c010ae5c:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
c010ae63:	00 
c010ae64:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010ae6b:	e8 90 55 ff ff       	call   c0100400 <__panic>
c010ae70:	c7 45 e4 5c 21 1a c0 	movl   $0xc01a215c,-0x1c(%ebp)
    return listelm->prev;
c010ae77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ae7a:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ae7c:	8b 15 24 00 1a c0    	mov    0xc01a0024,%edx
c010ae82:	83 c2 58             	add    $0x58,%edx
c010ae85:	39 d0                	cmp    %edx,%eax
c010ae87:	74 24                	je     c010aead <init_main+0x171>
c010ae89:	c7 44 24 0c 5c e4 10 	movl   $0xc010e45c,0xc(%esp)
c010ae90:	c0 
c010ae91:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010ae98:	c0 
c010ae99:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
c010aea0:	00 
c010aea1:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010aea8:	e8 53 55 ff ff       	call   c0100400 <__panic>

    cprintf("init check memory pass.\n");
c010aead:	c7 04 24 8c e4 10 c0 	movl   $0xc010e48c,(%esp)
c010aeb4:	e8 f0 53 ff ff       	call   c01002a9 <cprintf>
    return 0;
c010aeb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aebe:	c9                   	leave  
c010aebf:	c3                   	ret    

c010aec0 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010aec0:	55                   	push   %ebp
c010aec1:	89 e5                	mov    %esp,%ebp
c010aec3:	83 ec 28             	sub    $0x28,%esp
c010aec6:	c7 45 ec 5c 21 1a c0 	movl   $0xc01a215c,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010aecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aed0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010aed3:	89 50 04             	mov    %edx,0x4(%eax)
c010aed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aed9:	8b 50 04             	mov    0x4(%eax),%edx
c010aedc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aedf:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010aee1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010aee8:	eb 25                	jmp    c010af0f <proc_init+0x4f>
        list_init(hash_list + i);
c010aeea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aeed:	c1 e0 03             	shl    $0x3,%eax
c010aef0:	05 40 00 1a c0       	add    $0xc01a0040,%eax
c010aef5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010aef8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aefb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010aefe:	89 50 04             	mov    %edx,0x4(%eax)
c010af01:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af04:	8b 50 04             	mov    0x4(%eax),%edx
c010af07:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af0a:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010af0c:	ff 45 f4             	incl   -0xc(%ebp)
c010af0f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010af16:	7e d2                	jle    c010aeea <proc_init+0x2a>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010af18:	e8 08 e8 ff ff       	call   c0109725 <alloc_proc>
c010af1d:	a3 20 00 1a c0       	mov    %eax,0xc01a0020
c010af22:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af27:	85 c0                	test   %eax,%eax
c010af29:	75 1c                	jne    c010af47 <proc_init+0x87>
        panic("cannot alloc idleproc.\n");
c010af2b:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010af32:	c0 
c010af33:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
c010af3a:	00 
c010af3b:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010af42:	e8 b9 54 ff ff       	call   c0100400 <__panic>
    }

    idleproc->pid = 0;
c010af47:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af4c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010af53:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af58:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010af5e:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af63:	ba 00 90 12 c0       	mov    $0xc0129000,%edx
c010af68:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010af6b:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af70:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010af77:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af7c:	c7 44 24 04 bd e4 10 	movl   $0xc010e4bd,0x4(%esp)
c010af83:	c0 
c010af84:	89 04 24             	mov    %eax,(%esp)
c010af87:	e8 86 e8 ff ff       	call   c0109812 <set_proc_name>
    nr_process ++;
c010af8c:	a1 40 20 1a c0       	mov    0xc01a2040,%eax
c010af91:	40                   	inc    %eax
c010af92:	a3 40 20 1a c0       	mov    %eax,0xc01a2040

    current = idleproc;
c010af97:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010af9c:	a3 28 00 1a c0       	mov    %eax,0xc01a0028

    int pid = kernel_thread(init_main, NULL, 0);
c010afa1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010afa8:	00 
c010afa9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010afb0:	00 
c010afb1:	c7 04 24 3c ad 10 c0 	movl   $0xc010ad3c,(%esp)
c010afb8:	e8 a7 ec ff ff       	call   c0109c64 <kernel_thread>
c010afbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010afc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010afc4:	7f 1c                	jg     c010afe2 <proc_init+0x122>
        panic("create init_main failed.\n");
c010afc6:	c7 44 24 08 c2 e4 10 	movl   $0xc010e4c2,0x8(%esp)
c010afcd:	c0 
c010afce:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
c010afd5:	00 
c010afd6:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010afdd:	e8 1e 54 ff ff       	call   c0100400 <__panic>
    }

    initproc = find_proc(pid);
c010afe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afe5:	89 04 24             	mov    %eax,(%esp)
c010afe8:	e8 05 ec ff ff       	call   c0109bf2 <find_proc>
c010afed:	a3 24 00 1a c0       	mov    %eax,0xc01a0024
    set_proc_name(initproc, "init");
c010aff2:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010aff7:	c7 44 24 04 dc e4 10 	movl   $0xc010e4dc,0x4(%esp)
c010affe:	c0 
c010afff:	89 04 24             	mov    %eax,(%esp)
c010b002:	e8 0b e8 ff ff       	call   c0109812 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010b007:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010b00c:	85 c0                	test   %eax,%eax
c010b00e:	74 0c                	je     c010b01c <proc_init+0x15c>
c010b010:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010b015:	8b 40 04             	mov    0x4(%eax),%eax
c010b018:	85 c0                	test   %eax,%eax
c010b01a:	74 24                	je     c010b040 <proc_init+0x180>
c010b01c:	c7 44 24 0c e4 e4 10 	movl   $0xc010e4e4,0xc(%esp)
c010b023:	c0 
c010b024:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010b02b:	c0 
c010b02c:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
c010b033:	00 
c010b034:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010b03b:	e8 c0 53 ff ff       	call   c0100400 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010b040:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010b045:	85 c0                	test   %eax,%eax
c010b047:	74 0d                	je     c010b056 <proc_init+0x196>
c010b049:	a1 24 00 1a c0       	mov    0xc01a0024,%eax
c010b04e:	8b 40 04             	mov    0x4(%eax),%eax
c010b051:	83 f8 01             	cmp    $0x1,%eax
c010b054:	74 24                	je     c010b07a <proc_init+0x1ba>
c010b056:	c7 44 24 0c 0c e5 10 	movl   $0xc010e50c,0xc(%esp)
c010b05d:	c0 
c010b05e:	c7 44 24 08 51 e1 10 	movl   $0xc010e151,0x8(%esp)
c010b065:	c0 
c010b066:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
c010b06d:	00 
c010b06e:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c010b075:	e8 86 53 ff ff       	call   c0100400 <__panic>
}
c010b07a:	90                   	nop
c010b07b:	c9                   	leave  
c010b07c:	c3                   	ret    

c010b07d <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010b07d:	55                   	push   %ebp
c010b07e:	89 e5                	mov    %esp,%ebp
c010b080:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010b083:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b088:	8b 40 10             	mov    0x10(%eax),%eax
c010b08b:	85 c0                	test   %eax,%eax
c010b08d:	74 f4                	je     c010b083 <cpu_idle+0x6>
            schedule();
c010b08f:	e8 c5 00 00 00       	call   c010b159 <schedule>
        if (current->need_resched) {
c010b094:	eb ed                	jmp    c010b083 <cpu_idle+0x6>

c010b096 <__intr_save>:
__intr_save(void) {
c010b096:	55                   	push   %ebp
c010b097:	89 e5                	mov    %esp,%ebp
c010b099:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b09c:	9c                   	pushf  
c010b09d:	58                   	pop    %eax
c010b09e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b0a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b0a4:	25 00 02 00 00       	and    $0x200,%eax
c010b0a9:	85 c0                	test   %eax,%eax
c010b0ab:	74 0c                	je     c010b0b9 <__intr_save+0x23>
        intr_disable();
c010b0ad:	e8 2e 71 ff ff       	call   c01021e0 <intr_disable>
        return 1;
c010b0b2:	b8 01 00 00 00       	mov    $0x1,%eax
c010b0b7:	eb 05                	jmp    c010b0be <__intr_save+0x28>
    return 0;
c010b0b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b0be:	c9                   	leave  
c010b0bf:	c3                   	ret    

c010b0c0 <__intr_restore>:
__intr_restore(bool flag) {
c010b0c0:	55                   	push   %ebp
c010b0c1:	89 e5                	mov    %esp,%ebp
c010b0c3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b0c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b0ca:	74 05                	je     c010b0d1 <__intr_restore+0x11>
        intr_enable();
c010b0cc:	e8 08 71 ff ff       	call   c01021d9 <intr_enable>
}
c010b0d1:	90                   	nop
c010b0d2:	c9                   	leave  
c010b0d3:	c3                   	ret    

c010b0d4 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010b0d4:	55                   	push   %ebp
c010b0d5:	89 e5                	mov    %esp,%ebp
c010b0d7:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b0da:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0dd:	8b 00                	mov    (%eax),%eax
c010b0df:	83 f8 03             	cmp    $0x3,%eax
c010b0e2:	75 24                	jne    c010b108 <wakeup_proc+0x34>
c010b0e4:	c7 44 24 0c 33 e5 10 	movl   $0xc010e533,0xc(%esp)
c010b0eb:	c0 
c010b0ec:	c7 44 24 08 4e e5 10 	movl   $0xc010e54e,0x8(%esp)
c010b0f3:	c0 
c010b0f4:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010b0fb:	00 
c010b0fc:	c7 04 24 63 e5 10 c0 	movl   $0xc010e563,(%esp)
c010b103:	e8 f8 52 ff ff       	call   c0100400 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b108:	e8 89 ff ff ff       	call   c010b096 <__intr_save>
c010b10d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b110:	8b 45 08             	mov    0x8(%ebp),%eax
c010b113:	8b 00                	mov    (%eax),%eax
c010b115:	83 f8 02             	cmp    $0x2,%eax
c010b118:	74 15                	je     c010b12f <wakeup_proc+0x5b>
            proc->state = PROC_RUNNABLE;
c010b11a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b11d:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b123:	8b 45 08             	mov    0x8(%ebp),%eax
c010b126:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010b12d:	eb 1c                	jmp    c010b14b <wakeup_proc+0x77>
        }
        else {
            warn("wakeup runnable process.\n");
c010b12f:	c7 44 24 08 79 e5 10 	movl   $0xc010e579,0x8(%esp)
c010b136:	c0 
c010b137:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010b13e:	00 
c010b13f:	c7 04 24 63 e5 10 c0 	movl   $0xc010e563,(%esp)
c010b146:	e8 33 53 ff ff       	call   c010047e <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b14b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b14e:	89 04 24             	mov    %eax,(%esp)
c010b151:	e8 6a ff ff ff       	call   c010b0c0 <__intr_restore>
}
c010b156:	90                   	nop
c010b157:	c9                   	leave  
c010b158:	c3                   	ret    

c010b159 <schedule>:

void
schedule(void) {
c010b159:	55                   	push   %ebp
c010b15a:	89 e5                	mov    %esp,%ebp
c010b15c:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010b15f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010b166:	e8 2b ff ff ff       	call   c010b096 <__intr_save>
c010b16b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010b16e:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b173:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010b17a:	8b 15 28 00 1a c0    	mov    0xc01a0028,%edx
c010b180:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010b185:	39 c2                	cmp    %eax,%edx
c010b187:	74 0a                	je     c010b193 <schedule+0x3a>
c010b189:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b18e:	83 c0 58             	add    $0x58,%eax
c010b191:	eb 05                	jmp    c010b198 <schedule+0x3f>
c010b193:	b8 5c 21 1a c0       	mov    $0xc01a215c,%eax
c010b198:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010b19b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b19e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010b1a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b1aa:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010b1ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b1b0:	81 7d f4 5c 21 1a c0 	cmpl   $0xc01a215c,-0xc(%ebp)
c010b1b7:	74 13                	je     c010b1cc <schedule+0x73>
                next = le2proc(le, list_link);
c010b1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1bc:	83 e8 58             	sub    $0x58,%eax
c010b1bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010b1c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1c5:	8b 00                	mov    (%eax),%eax
c010b1c7:	83 f8 02             	cmp    $0x2,%eax
c010b1ca:	74 0a                	je     c010b1d6 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c010b1cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1cf:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010b1d2:	75 cd                	jne    c010b1a1 <schedule+0x48>
c010b1d4:	eb 01                	jmp    c010b1d7 <schedule+0x7e>
                    break;
c010b1d6:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010b1d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b1db:	74 0a                	je     c010b1e7 <schedule+0x8e>
c010b1dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1e0:	8b 00                	mov    (%eax),%eax
c010b1e2:	83 f8 02             	cmp    $0x2,%eax
c010b1e5:	74 08                	je     c010b1ef <schedule+0x96>
            next = idleproc;
c010b1e7:	a1 20 00 1a c0       	mov    0xc01a0020,%eax
c010b1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010b1ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1f2:	8b 40 08             	mov    0x8(%eax),%eax
c010b1f5:	8d 50 01             	lea    0x1(%eax),%edx
c010b1f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1fb:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b1fe:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b203:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b206:	74 0b                	je     c010b213 <schedule+0xba>
            proc_run(next);
c010b208:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b20b:	89 04 24             	mov    %eax,(%esp)
c010b20e:	e8 9f e8 ff ff       	call   c0109ab2 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b213:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b216:	89 04 24             	mov    %eax,(%esp)
c010b219:	e8 a2 fe ff ff       	call   c010b0c0 <__intr_restore>
}
c010b21e:	90                   	nop
c010b21f:	c9                   	leave  
c010b220:	c3                   	ret    

c010b221 <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b221:	55                   	push   %ebp
c010b222:	89 e5                	mov    %esp,%ebp
c010b224:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b227:	8b 45 08             	mov    0x8(%ebp),%eax
c010b22a:	8b 00                	mov    (%eax),%eax
c010b22c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b232:	89 04 24             	mov    %eax,(%esp)
c010b235:	e8 fb ee ff ff       	call   c010a135 <do_exit>
}
c010b23a:	c9                   	leave  
c010b23b:	c3                   	ret    

c010b23c <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b23c:	55                   	push   %ebp
c010b23d:	89 e5                	mov    %esp,%ebp
c010b23f:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b242:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b247:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b24a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b250:	8b 40 44             	mov    0x44(%eax),%eax
c010b253:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b256:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b259:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b25d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b260:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b264:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b26b:	e8 9e ed ff ff       	call   c010a00e <do_fork>
}
c010b270:	c9                   	leave  
c010b271:	c3                   	ret    

c010b272 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b272:	55                   	push   %ebp
c010b273:	89 e5                	mov    %esp,%ebp
c010b275:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b278:	8b 45 08             	mov    0x8(%ebp),%eax
c010b27b:	8b 00                	mov    (%eax),%eax
c010b27d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b280:	8b 45 08             	mov    0x8(%ebp),%eax
c010b283:	83 c0 04             	add    $0x4,%eax
c010b286:	8b 00                	mov    (%eax),%eax
c010b288:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b28b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b28e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b292:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b295:	89 04 24             	mov    %eax,(%esp)
c010b298:	e8 14 f8 ff ff       	call   c010aab1 <do_wait>
}
c010b29d:	c9                   	leave  
c010b29e:	c3                   	ret    

c010b29f <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b29f:	55                   	push   %ebp
c010b2a0:	89 e5                	mov    %esp,%ebp
c010b2a2:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b2a5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2a8:	8b 00                	mov    (%eax),%eax
c010b2aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b2ad:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2b0:	83 c0 04             	add    $0x4,%eax
c010b2b3:	8b 00                	mov    (%eax),%eax
c010b2b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b2b8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2bb:	83 c0 08             	add    $0x8,%eax
c010b2be:	8b 00                	mov    (%eax),%eax
c010b2c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b2c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2c6:	83 c0 0c             	add    $0xc,%eax
c010b2c9:	8b 00                	mov    (%eax),%eax
c010b2cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b2ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b2d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b2d8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b2dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2df:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2e6:	89 04 24             	mov    %eax,(%esp)
c010b2e9:	e8 75 f6 ff ff       	call   c010a963 <do_execve>
}
c010b2ee:	c9                   	leave  
c010b2ef:	c3                   	ret    

c010b2f0 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b2f0:	55                   	push   %ebp
c010b2f1:	89 e5                	mov    %esp,%ebp
c010b2f3:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b2f6:	e8 a0 f7 ff ff       	call   c010aa9b <do_yield>
}
c010b2fb:	c9                   	leave  
c010b2fc:	c3                   	ret    

c010b2fd <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b2fd:	55                   	push   %ebp
c010b2fe:	89 e5                	mov    %esp,%ebp
c010b300:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b303:	8b 45 08             	mov    0x8(%ebp),%eax
c010b306:	8b 00                	mov    (%eax),%eax
c010b308:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b30b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b30e:	89 04 24             	mov    %eax,(%esp)
c010b311:	e8 2b f9 ff ff       	call   c010ac41 <do_kill>
}
c010b316:	c9                   	leave  
c010b317:	c3                   	ret    

c010b318 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b318:	55                   	push   %ebp
c010b319:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b31b:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b320:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b323:	5d                   	pop    %ebp
c010b324:	c3                   	ret    

c010b325 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b325:	55                   	push   %ebp
c010b326:	89 e5                	mov    %esp,%ebp
c010b328:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b32b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b32e:	8b 00                	mov    (%eax),%eax
c010b330:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b333:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b336:	89 04 24             	mov    %eax,(%esp)
c010b339:	e8 91 4f ff ff       	call   c01002cf <cputchar>
    return 0;
c010b33e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b343:	c9                   	leave  
c010b344:	c3                   	ret    

c010b345 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b345:	55                   	push   %ebp
c010b346:	89 e5                	mov    %esp,%ebp
c010b348:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b34b:	e8 06 de ff ff       	call   c0109156 <print_pgdir>
    return 0;
c010b350:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b355:	c9                   	leave  
c010b356:	c3                   	ret    

c010b357 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b357:	55                   	push   %ebp
c010b358:	89 e5                	mov    %esp,%ebp
c010b35a:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b35d:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b362:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b365:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b368:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b36b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b36e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b371:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b375:	78 5e                	js     c010b3d5 <syscall+0x7e>
c010b377:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b37a:	83 f8 1f             	cmp    $0x1f,%eax
c010b37d:	77 56                	ja     c010b3d5 <syscall+0x7e>
        if (syscalls[num] != NULL) {
c010b37f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b382:	8b 04 85 80 ba 12 c0 	mov    -0x3fed4580(,%eax,4),%eax
c010b389:	85 c0                	test   %eax,%eax
c010b38b:	74 48                	je     c010b3d5 <syscall+0x7e>
            arg[0] = tf->tf_regs.reg_edx;
c010b38d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b390:	8b 40 14             	mov    0x14(%eax),%eax
c010b393:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b396:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b399:	8b 40 18             	mov    0x18(%eax),%eax
c010b39c:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b39f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3a2:	8b 40 10             	mov    0x10(%eax),%eax
c010b3a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b3a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3ab:	8b 00                	mov    (%eax),%eax
c010b3ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b3b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3b3:	8b 40 04             	mov    0x4(%eax),%eax
c010b3b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b3b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3bc:	8b 04 85 80 ba 12 c0 	mov    -0x3fed4580(,%eax,4),%eax
c010b3c3:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b3c6:	89 14 24             	mov    %edx,(%esp)
c010b3c9:	ff d0                	call   *%eax
c010b3cb:	89 c2                	mov    %eax,%edx
c010b3cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3d0:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b3d3:	eb 46                	jmp    c010b41b <syscall+0xc4>
        }
    }
    print_trapframe(tf);
c010b3d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3d8:	89 04 24             	mov    %eax,(%esp)
c010b3db:	e8 da 6f ff ff       	call   c01023ba <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b3e0:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b3e5:	8d 50 48             	lea    0x48(%eax),%edx
c010b3e8:	a1 28 00 1a c0       	mov    0xc01a0028,%eax
c010b3ed:	8b 40 04             	mov    0x4(%eax),%eax
c010b3f0:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b3f4:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b3f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b3ff:	c7 44 24 08 94 e5 10 	movl   $0xc010e594,0x8(%esp)
c010b406:	c0 
c010b407:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c010b40e:	00 
c010b40f:	c7 04 24 c0 e5 10 c0 	movl   $0xc010e5c0,(%esp)
c010b416:	e8 e5 4f ff ff       	call   c0100400 <__panic>
            num, current->pid, current->name);
}
c010b41b:	c9                   	leave  
c010b41c:	c3                   	ret    

c010b41d <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b41d:	55                   	push   %ebp
c010b41e:	89 e5                	mov    %esp,%ebp
c010b420:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b423:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b42a:	eb 03                	jmp    c010b42f <strlen+0x12>
        cnt ++;
c010b42c:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010b42f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b432:	8d 50 01             	lea    0x1(%eax),%edx
c010b435:	89 55 08             	mov    %edx,0x8(%ebp)
c010b438:	0f b6 00             	movzbl (%eax),%eax
c010b43b:	84 c0                	test   %al,%al
c010b43d:	75 ed                	jne    c010b42c <strlen+0xf>
    }
    return cnt;
c010b43f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b442:	c9                   	leave  
c010b443:	c3                   	ret    

c010b444 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b444:	55                   	push   %ebp
c010b445:	89 e5                	mov    %esp,%ebp
c010b447:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b44a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b451:	eb 03                	jmp    c010b456 <strnlen+0x12>
        cnt ++;
c010b453:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b456:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b459:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b45c:	73 10                	jae    c010b46e <strnlen+0x2a>
c010b45e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b461:	8d 50 01             	lea    0x1(%eax),%edx
c010b464:	89 55 08             	mov    %edx,0x8(%ebp)
c010b467:	0f b6 00             	movzbl (%eax),%eax
c010b46a:	84 c0                	test   %al,%al
c010b46c:	75 e5                	jne    c010b453 <strnlen+0xf>
    }
    return cnt;
c010b46e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b471:	c9                   	leave  
c010b472:	c3                   	ret    

c010b473 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b473:	55                   	push   %ebp
c010b474:	89 e5                	mov    %esp,%ebp
c010b476:	57                   	push   %edi
c010b477:	56                   	push   %esi
c010b478:	83 ec 20             	sub    $0x20,%esp
c010b47b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b47e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b481:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b484:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b487:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b48a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b48d:	89 d1                	mov    %edx,%ecx
c010b48f:	89 c2                	mov    %eax,%edx
c010b491:	89 ce                	mov    %ecx,%esi
c010b493:	89 d7                	mov    %edx,%edi
c010b495:	ac                   	lods   %ds:(%esi),%al
c010b496:	aa                   	stos   %al,%es:(%edi)
c010b497:	84 c0                	test   %al,%al
c010b499:	75 fa                	jne    c010b495 <strcpy+0x22>
c010b49b:	89 fa                	mov    %edi,%edx
c010b49d:	89 f1                	mov    %esi,%ecx
c010b49f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b4a2:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b4a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b4a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c010b4ab:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b4ac:	83 c4 20             	add    $0x20,%esp
c010b4af:	5e                   	pop    %esi
c010b4b0:	5f                   	pop    %edi
c010b4b1:	5d                   	pop    %ebp
c010b4b2:	c3                   	ret    

c010b4b3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b4b3:	55                   	push   %ebp
c010b4b4:	89 e5                	mov    %esp,%ebp
c010b4b6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010b4b9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b4bf:	eb 1e                	jmp    c010b4df <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010b4c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4c4:	0f b6 10             	movzbl (%eax),%edx
c010b4c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b4ca:	88 10                	mov    %dl,(%eax)
c010b4cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b4cf:	0f b6 00             	movzbl (%eax),%eax
c010b4d2:	84 c0                	test   %al,%al
c010b4d4:	74 03                	je     c010b4d9 <strncpy+0x26>
            src ++;
c010b4d6:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010b4d9:	ff 45 fc             	incl   -0x4(%ebp)
c010b4dc:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010b4df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b4e3:	75 dc                	jne    c010b4c1 <strncpy+0xe>
    }
    return dst;
c010b4e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b4e8:	c9                   	leave  
c010b4e9:	c3                   	ret    

c010b4ea <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b4ea:	55                   	push   %ebp
c010b4eb:	89 e5                	mov    %esp,%ebp
c010b4ed:	57                   	push   %edi
c010b4ee:	56                   	push   %esi
c010b4ef:	83 ec 20             	sub    $0x20,%esp
c010b4f2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b4f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010b4fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b501:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b504:	89 d1                	mov    %edx,%ecx
c010b506:	89 c2                	mov    %eax,%edx
c010b508:	89 ce                	mov    %ecx,%esi
c010b50a:	89 d7                	mov    %edx,%edi
c010b50c:	ac                   	lods   %ds:(%esi),%al
c010b50d:	ae                   	scas   %es:(%edi),%al
c010b50e:	75 08                	jne    c010b518 <strcmp+0x2e>
c010b510:	84 c0                	test   %al,%al
c010b512:	75 f8                	jne    c010b50c <strcmp+0x22>
c010b514:	31 c0                	xor    %eax,%eax
c010b516:	eb 04                	jmp    c010b51c <strcmp+0x32>
c010b518:	19 c0                	sbb    %eax,%eax
c010b51a:	0c 01                	or     $0x1,%al
c010b51c:	89 fa                	mov    %edi,%edx
c010b51e:	89 f1                	mov    %esi,%ecx
c010b520:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b523:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b526:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010b529:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c010b52c:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b52d:	83 c4 20             	add    $0x20,%esp
c010b530:	5e                   	pop    %esi
c010b531:	5f                   	pop    %edi
c010b532:	5d                   	pop    %ebp
c010b533:	c3                   	ret    

c010b534 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b534:	55                   	push   %ebp
c010b535:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b537:	eb 09                	jmp    c010b542 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c010b539:	ff 4d 10             	decl   0x10(%ebp)
c010b53c:	ff 45 08             	incl   0x8(%ebp)
c010b53f:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b542:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b546:	74 1a                	je     c010b562 <strncmp+0x2e>
c010b548:	8b 45 08             	mov    0x8(%ebp),%eax
c010b54b:	0f b6 00             	movzbl (%eax),%eax
c010b54e:	84 c0                	test   %al,%al
c010b550:	74 10                	je     c010b562 <strncmp+0x2e>
c010b552:	8b 45 08             	mov    0x8(%ebp),%eax
c010b555:	0f b6 10             	movzbl (%eax),%edx
c010b558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b55b:	0f b6 00             	movzbl (%eax),%eax
c010b55e:	38 c2                	cmp    %al,%dl
c010b560:	74 d7                	je     c010b539 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b562:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b566:	74 18                	je     c010b580 <strncmp+0x4c>
c010b568:	8b 45 08             	mov    0x8(%ebp),%eax
c010b56b:	0f b6 00             	movzbl (%eax),%eax
c010b56e:	0f b6 d0             	movzbl %al,%edx
c010b571:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b574:	0f b6 00             	movzbl (%eax),%eax
c010b577:	0f b6 c0             	movzbl %al,%eax
c010b57a:	29 c2                	sub    %eax,%edx
c010b57c:	89 d0                	mov    %edx,%eax
c010b57e:	eb 05                	jmp    c010b585 <strncmp+0x51>
c010b580:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b585:	5d                   	pop    %ebp
c010b586:	c3                   	ret    

c010b587 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b587:	55                   	push   %ebp
c010b588:	89 e5                	mov    %esp,%ebp
c010b58a:	83 ec 04             	sub    $0x4,%esp
c010b58d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b590:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b593:	eb 13                	jmp    c010b5a8 <strchr+0x21>
        if (*s == c) {
c010b595:	8b 45 08             	mov    0x8(%ebp),%eax
c010b598:	0f b6 00             	movzbl (%eax),%eax
c010b59b:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b59e:	75 05                	jne    c010b5a5 <strchr+0x1e>
            return (char *)s;
c010b5a0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5a3:	eb 12                	jmp    c010b5b7 <strchr+0x30>
        }
        s ++;
c010b5a5:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010b5a8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5ab:	0f b6 00             	movzbl (%eax),%eax
c010b5ae:	84 c0                	test   %al,%al
c010b5b0:	75 e3                	jne    c010b595 <strchr+0xe>
    }
    return NULL;
c010b5b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b5b7:	c9                   	leave  
c010b5b8:	c3                   	ret    

c010b5b9 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b5b9:	55                   	push   %ebp
c010b5ba:	89 e5                	mov    %esp,%ebp
c010b5bc:	83 ec 04             	sub    $0x4,%esp
c010b5bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5c2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b5c5:	eb 0e                	jmp    c010b5d5 <strfind+0x1c>
        if (*s == c) {
c010b5c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5ca:	0f b6 00             	movzbl (%eax),%eax
c010b5cd:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b5d0:	74 0f                	je     c010b5e1 <strfind+0x28>
            break;
        }
        s ++;
c010b5d2:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010b5d5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5d8:	0f b6 00             	movzbl (%eax),%eax
c010b5db:	84 c0                	test   %al,%al
c010b5dd:	75 e8                	jne    c010b5c7 <strfind+0xe>
c010b5df:	eb 01                	jmp    c010b5e2 <strfind+0x29>
            break;
c010b5e1:	90                   	nop
    }
    return (char *)s;
c010b5e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b5e5:	c9                   	leave  
c010b5e6:	c3                   	ret    

c010b5e7 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b5e7:	55                   	push   %ebp
c010b5e8:	89 e5                	mov    %esp,%ebp
c010b5ea:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b5ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b5f4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b5fb:	eb 03                	jmp    c010b600 <strtol+0x19>
        s ++;
c010b5fd:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010b600:	8b 45 08             	mov    0x8(%ebp),%eax
c010b603:	0f b6 00             	movzbl (%eax),%eax
c010b606:	3c 20                	cmp    $0x20,%al
c010b608:	74 f3                	je     c010b5fd <strtol+0x16>
c010b60a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b60d:	0f b6 00             	movzbl (%eax),%eax
c010b610:	3c 09                	cmp    $0x9,%al
c010b612:	74 e9                	je     c010b5fd <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010b614:	8b 45 08             	mov    0x8(%ebp),%eax
c010b617:	0f b6 00             	movzbl (%eax),%eax
c010b61a:	3c 2b                	cmp    $0x2b,%al
c010b61c:	75 05                	jne    c010b623 <strtol+0x3c>
        s ++;
c010b61e:	ff 45 08             	incl   0x8(%ebp)
c010b621:	eb 14                	jmp    c010b637 <strtol+0x50>
    }
    else if (*s == '-') {
c010b623:	8b 45 08             	mov    0x8(%ebp),%eax
c010b626:	0f b6 00             	movzbl (%eax),%eax
c010b629:	3c 2d                	cmp    $0x2d,%al
c010b62b:	75 0a                	jne    c010b637 <strtol+0x50>
        s ++, neg = 1;
c010b62d:	ff 45 08             	incl   0x8(%ebp)
c010b630:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b637:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b63b:	74 06                	je     c010b643 <strtol+0x5c>
c010b63d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b641:	75 22                	jne    c010b665 <strtol+0x7e>
c010b643:	8b 45 08             	mov    0x8(%ebp),%eax
c010b646:	0f b6 00             	movzbl (%eax),%eax
c010b649:	3c 30                	cmp    $0x30,%al
c010b64b:	75 18                	jne    c010b665 <strtol+0x7e>
c010b64d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b650:	40                   	inc    %eax
c010b651:	0f b6 00             	movzbl (%eax),%eax
c010b654:	3c 78                	cmp    $0x78,%al
c010b656:	75 0d                	jne    c010b665 <strtol+0x7e>
        s += 2, base = 16;
c010b658:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b65c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b663:	eb 29                	jmp    c010b68e <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010b665:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b669:	75 16                	jne    c010b681 <strtol+0x9a>
c010b66b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b66e:	0f b6 00             	movzbl (%eax),%eax
c010b671:	3c 30                	cmp    $0x30,%al
c010b673:	75 0c                	jne    c010b681 <strtol+0x9a>
        s ++, base = 8;
c010b675:	ff 45 08             	incl   0x8(%ebp)
c010b678:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b67f:	eb 0d                	jmp    c010b68e <strtol+0xa7>
    }
    else if (base == 0) {
c010b681:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b685:	75 07                	jne    c010b68e <strtol+0xa7>
        base = 10;
c010b687:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b68e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b691:	0f b6 00             	movzbl (%eax),%eax
c010b694:	3c 2f                	cmp    $0x2f,%al
c010b696:	7e 1b                	jle    c010b6b3 <strtol+0xcc>
c010b698:	8b 45 08             	mov    0x8(%ebp),%eax
c010b69b:	0f b6 00             	movzbl (%eax),%eax
c010b69e:	3c 39                	cmp    $0x39,%al
c010b6a0:	7f 11                	jg     c010b6b3 <strtol+0xcc>
            dig = *s - '0';
c010b6a2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6a5:	0f b6 00             	movzbl (%eax),%eax
c010b6a8:	0f be c0             	movsbl %al,%eax
c010b6ab:	83 e8 30             	sub    $0x30,%eax
c010b6ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b6b1:	eb 48                	jmp    c010b6fb <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b6b3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6b6:	0f b6 00             	movzbl (%eax),%eax
c010b6b9:	3c 60                	cmp    $0x60,%al
c010b6bb:	7e 1b                	jle    c010b6d8 <strtol+0xf1>
c010b6bd:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6c0:	0f b6 00             	movzbl (%eax),%eax
c010b6c3:	3c 7a                	cmp    $0x7a,%al
c010b6c5:	7f 11                	jg     c010b6d8 <strtol+0xf1>
            dig = *s - 'a' + 10;
c010b6c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6ca:	0f b6 00             	movzbl (%eax),%eax
c010b6cd:	0f be c0             	movsbl %al,%eax
c010b6d0:	83 e8 57             	sub    $0x57,%eax
c010b6d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b6d6:	eb 23                	jmp    c010b6fb <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b6d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6db:	0f b6 00             	movzbl (%eax),%eax
c010b6de:	3c 40                	cmp    $0x40,%al
c010b6e0:	7e 3b                	jle    c010b71d <strtol+0x136>
c010b6e2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6e5:	0f b6 00             	movzbl (%eax),%eax
c010b6e8:	3c 5a                	cmp    $0x5a,%al
c010b6ea:	7f 31                	jg     c010b71d <strtol+0x136>
            dig = *s - 'A' + 10;
c010b6ec:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6ef:	0f b6 00             	movzbl (%eax),%eax
c010b6f2:	0f be c0             	movsbl %al,%eax
c010b6f5:	83 e8 37             	sub    $0x37,%eax
c010b6f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b6fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6fe:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b701:	7d 19                	jge    c010b71c <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c010b703:	ff 45 08             	incl   0x8(%ebp)
c010b706:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b709:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b70d:	89 c2                	mov    %eax,%edx
c010b70f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b712:	01 d0                	add    %edx,%eax
c010b714:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010b717:	e9 72 ff ff ff       	jmp    c010b68e <strtol+0xa7>
            break;
c010b71c:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010b71d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b721:	74 08                	je     c010b72b <strtol+0x144>
        *endptr = (char *) s;
c010b723:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b726:	8b 55 08             	mov    0x8(%ebp),%edx
c010b729:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b72b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b72f:	74 07                	je     c010b738 <strtol+0x151>
c010b731:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b734:	f7 d8                	neg    %eax
c010b736:	eb 03                	jmp    c010b73b <strtol+0x154>
c010b738:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b73b:	c9                   	leave  
c010b73c:	c3                   	ret    

c010b73d <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b73d:	55                   	push   %ebp
c010b73e:	89 e5                	mov    %esp,%ebp
c010b740:	57                   	push   %edi
c010b741:	83 ec 24             	sub    $0x24,%esp
c010b744:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b747:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b74a:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b74e:	8b 55 08             	mov    0x8(%ebp),%edx
c010b751:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b754:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b757:	8b 45 10             	mov    0x10(%ebp),%eax
c010b75a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b75d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b760:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b764:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b767:	89 d7                	mov    %edx,%edi
c010b769:	f3 aa                	rep stos %al,%es:(%edi)
c010b76b:	89 fa                	mov    %edi,%edx
c010b76d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b770:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b773:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b776:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b777:	83 c4 24             	add    $0x24,%esp
c010b77a:	5f                   	pop    %edi
c010b77b:	5d                   	pop    %ebp
c010b77c:	c3                   	ret    

c010b77d <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b77d:	55                   	push   %ebp
c010b77e:	89 e5                	mov    %esp,%ebp
c010b780:	57                   	push   %edi
c010b781:	56                   	push   %esi
c010b782:	53                   	push   %ebx
c010b783:	83 ec 30             	sub    $0x30,%esp
c010b786:	8b 45 08             	mov    0x8(%ebp),%eax
c010b789:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b78c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b78f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b792:	8b 45 10             	mov    0x10(%ebp),%eax
c010b795:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b798:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b79b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b79e:	73 42                	jae    c010b7e2 <memmove+0x65>
c010b7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b7a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b7a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b7ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7af:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b7b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b7b5:	c1 e8 02             	shr    $0x2,%eax
c010b7b8:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b7ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b7bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b7c0:	89 d7                	mov    %edx,%edi
c010b7c2:	89 c6                	mov    %eax,%esi
c010b7c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b7c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010b7c9:	83 e1 03             	and    $0x3,%ecx
c010b7cc:	74 02                	je     c010b7d0 <memmove+0x53>
c010b7ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b7d0:	89 f0                	mov    %esi,%eax
c010b7d2:	89 fa                	mov    %edi,%edx
c010b7d4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010b7d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b7da:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010b7dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010b7e0:	eb 36                	jmp    c010b818 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010b7e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7e5:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b7e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b7eb:	01 c2                	add    %eax,%edx
c010b7ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7f0:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010b7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7f6:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010b7f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7fc:	89 c1                	mov    %eax,%ecx
c010b7fe:	89 d8                	mov    %ebx,%eax
c010b800:	89 d6                	mov    %edx,%esi
c010b802:	89 c7                	mov    %eax,%edi
c010b804:	fd                   	std    
c010b805:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b807:	fc                   	cld    
c010b808:	89 f8                	mov    %edi,%eax
c010b80a:	89 f2                	mov    %esi,%edx
c010b80c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010b80f:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010b812:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010b815:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010b818:	83 c4 30             	add    $0x30,%esp
c010b81b:	5b                   	pop    %ebx
c010b81c:	5e                   	pop    %esi
c010b81d:	5f                   	pop    %edi
c010b81e:	5d                   	pop    %ebp
c010b81f:	c3                   	ret    

c010b820 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010b820:	55                   	push   %ebp
c010b821:	89 e5                	mov    %esp,%ebp
c010b823:	57                   	push   %edi
c010b824:	56                   	push   %esi
c010b825:	83 ec 20             	sub    $0x20,%esp
c010b828:	8b 45 08             	mov    0x8(%ebp),%eax
c010b82b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b82e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b831:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b834:	8b 45 10             	mov    0x10(%ebp),%eax
c010b837:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b83a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b83d:	c1 e8 02             	shr    $0x2,%eax
c010b840:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b842:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b845:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b848:	89 d7                	mov    %edx,%edi
c010b84a:	89 c6                	mov    %eax,%esi
c010b84c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b84e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b851:	83 e1 03             	and    $0x3,%ecx
c010b854:	74 02                	je     c010b858 <memcpy+0x38>
c010b856:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b858:	89 f0                	mov    %esi,%eax
c010b85a:	89 fa                	mov    %edi,%edx
c010b85c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b85f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b862:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010b865:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c010b868:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010b869:	83 c4 20             	add    $0x20,%esp
c010b86c:	5e                   	pop    %esi
c010b86d:	5f                   	pop    %edi
c010b86e:	5d                   	pop    %ebp
c010b86f:	c3                   	ret    

c010b870 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010b870:	55                   	push   %ebp
c010b871:	89 e5                	mov    %esp,%ebp
c010b873:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010b876:	8b 45 08             	mov    0x8(%ebp),%eax
c010b879:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010b87c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b87f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010b882:	eb 2e                	jmp    c010b8b2 <memcmp+0x42>
        if (*s1 != *s2) {
c010b884:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b887:	0f b6 10             	movzbl (%eax),%edx
c010b88a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b88d:	0f b6 00             	movzbl (%eax),%eax
c010b890:	38 c2                	cmp    %al,%dl
c010b892:	74 18                	je     c010b8ac <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b894:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b897:	0f b6 00             	movzbl (%eax),%eax
c010b89a:	0f b6 d0             	movzbl %al,%edx
c010b89d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b8a0:	0f b6 00             	movzbl (%eax),%eax
c010b8a3:	0f b6 c0             	movzbl %al,%eax
c010b8a6:	29 c2                	sub    %eax,%edx
c010b8a8:	89 d0                	mov    %edx,%eax
c010b8aa:	eb 18                	jmp    c010b8c4 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010b8ac:	ff 45 fc             	incl   -0x4(%ebp)
c010b8af:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010b8b2:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8b5:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b8b8:	89 55 10             	mov    %edx,0x10(%ebp)
c010b8bb:	85 c0                	test   %eax,%eax
c010b8bd:	75 c5                	jne    c010b884 <memcmp+0x14>
    }
    return 0;
c010b8bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b8c4:	c9                   	leave  
c010b8c5:	c3                   	ret    

c010b8c6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b8c6:	55                   	push   %ebp
c010b8c7:	89 e5                	mov    %esp,%ebp
c010b8c9:	83 ec 58             	sub    $0x58,%esp
c010b8cc:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b8d2:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b8d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b8db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b8de:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b8e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b8e4:	8b 45 18             	mov    0x18(%ebp),%eax
c010b8e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b8ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b8ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b8f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b8f3:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b8f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b8f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b8fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b900:	74 1c                	je     c010b91e <printnum+0x58>
c010b902:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b905:	ba 00 00 00 00       	mov    $0x0,%edx
c010b90a:	f7 75 e4             	divl   -0x1c(%ebp)
c010b90d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b910:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b913:	ba 00 00 00 00       	mov    $0x0,%edx
c010b918:	f7 75 e4             	divl   -0x1c(%ebp)
c010b91b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b91e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b921:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b924:	f7 75 e4             	divl   -0x1c(%ebp)
c010b927:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b92a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b92d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b930:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b933:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b936:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b939:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b93c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b93f:	8b 45 18             	mov    0x18(%ebp),%eax
c010b942:	ba 00 00 00 00       	mov    $0x0,%edx
c010b947:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010b94a:	72 56                	jb     c010b9a2 <printnum+0xdc>
c010b94c:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010b94f:	77 05                	ja     c010b956 <printnum+0x90>
c010b951:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010b954:	72 4c                	jb     c010b9a2 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b956:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b959:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b95c:	8b 45 20             	mov    0x20(%ebp),%eax
c010b95f:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b963:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b967:	8b 45 18             	mov    0x18(%ebp),%eax
c010b96a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b96e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b971:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b974:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b978:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b97c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b97f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b983:	8b 45 08             	mov    0x8(%ebp),%eax
c010b986:	89 04 24             	mov    %eax,(%esp)
c010b989:	e8 38 ff ff ff       	call   c010b8c6 <printnum>
c010b98e:	eb 1b                	jmp    c010b9ab <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b990:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b993:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b997:	8b 45 20             	mov    0x20(%ebp),%eax
c010b99a:	89 04 24             	mov    %eax,(%esp)
c010b99d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9a0:	ff d0                	call   *%eax
        while (-- width > 0)
c010b9a2:	ff 4d 1c             	decl   0x1c(%ebp)
c010b9a5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b9a9:	7f e5                	jg     c010b990 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b9ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b9ae:	05 e4 e6 10 c0       	add    $0xc010e6e4,%eax
c010b9b3:	0f b6 00             	movzbl (%eax),%eax
c010b9b6:	0f be c0             	movsbl %al,%eax
c010b9b9:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b9bc:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b9c0:	89 04 24             	mov    %eax,(%esp)
c010b9c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9c6:	ff d0                	call   *%eax
}
c010b9c8:	90                   	nop
c010b9c9:	c9                   	leave  
c010b9ca:	c3                   	ret    

c010b9cb <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b9cb:	55                   	push   %ebp
c010b9cc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b9ce:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b9d2:	7e 14                	jle    c010b9e8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b9d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9d7:	8b 00                	mov    (%eax),%eax
c010b9d9:	8d 48 08             	lea    0x8(%eax),%ecx
c010b9dc:	8b 55 08             	mov    0x8(%ebp),%edx
c010b9df:	89 0a                	mov    %ecx,(%edx)
c010b9e1:	8b 50 04             	mov    0x4(%eax),%edx
c010b9e4:	8b 00                	mov    (%eax),%eax
c010b9e6:	eb 30                	jmp    c010ba18 <getuint+0x4d>
    }
    else if (lflag) {
c010b9e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b9ec:	74 16                	je     c010ba04 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b9ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9f1:	8b 00                	mov    (%eax),%eax
c010b9f3:	8d 48 04             	lea    0x4(%eax),%ecx
c010b9f6:	8b 55 08             	mov    0x8(%ebp),%edx
c010b9f9:	89 0a                	mov    %ecx,(%edx)
c010b9fb:	8b 00                	mov    (%eax),%eax
c010b9fd:	ba 00 00 00 00       	mov    $0x0,%edx
c010ba02:	eb 14                	jmp    c010ba18 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010ba04:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba07:	8b 00                	mov    (%eax),%eax
c010ba09:	8d 48 04             	lea    0x4(%eax),%ecx
c010ba0c:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba0f:	89 0a                	mov    %ecx,(%edx)
c010ba11:	8b 00                	mov    (%eax),%eax
c010ba13:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010ba18:	5d                   	pop    %ebp
c010ba19:	c3                   	ret    

c010ba1a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010ba1a:	55                   	push   %ebp
c010ba1b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010ba1d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010ba21:	7e 14                	jle    c010ba37 <getint+0x1d>
        return va_arg(*ap, long long);
c010ba23:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba26:	8b 00                	mov    (%eax),%eax
c010ba28:	8d 48 08             	lea    0x8(%eax),%ecx
c010ba2b:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba2e:	89 0a                	mov    %ecx,(%edx)
c010ba30:	8b 50 04             	mov    0x4(%eax),%edx
c010ba33:	8b 00                	mov    (%eax),%eax
c010ba35:	eb 28                	jmp    c010ba5f <getint+0x45>
    }
    else if (lflag) {
c010ba37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ba3b:	74 12                	je     c010ba4f <getint+0x35>
        return va_arg(*ap, long);
c010ba3d:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba40:	8b 00                	mov    (%eax),%eax
c010ba42:	8d 48 04             	lea    0x4(%eax),%ecx
c010ba45:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba48:	89 0a                	mov    %ecx,(%edx)
c010ba4a:	8b 00                	mov    (%eax),%eax
c010ba4c:	99                   	cltd   
c010ba4d:	eb 10                	jmp    c010ba5f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010ba4f:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba52:	8b 00                	mov    (%eax),%eax
c010ba54:	8d 48 04             	lea    0x4(%eax),%ecx
c010ba57:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba5a:	89 0a                	mov    %ecx,(%edx)
c010ba5c:	8b 00                	mov    (%eax),%eax
c010ba5e:	99                   	cltd   
    }
}
c010ba5f:	5d                   	pop    %ebp
c010ba60:	c3                   	ret    

c010ba61 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010ba61:	55                   	push   %ebp
c010ba62:	89 e5                	mov    %esp,%ebp
c010ba64:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010ba67:	8d 45 14             	lea    0x14(%ebp),%eax
c010ba6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010ba6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ba70:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ba74:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba77:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ba7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba82:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba85:	89 04 24             	mov    %eax,(%esp)
c010ba88:	e8 03 00 00 00       	call   c010ba90 <vprintfmt>
    va_end(ap);
}
c010ba8d:	90                   	nop
c010ba8e:	c9                   	leave  
c010ba8f:	c3                   	ret    

c010ba90 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010ba90:	55                   	push   %ebp
c010ba91:	89 e5                	mov    %esp,%ebp
c010ba93:	56                   	push   %esi
c010ba94:	53                   	push   %ebx
c010ba95:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010ba98:	eb 17                	jmp    c010bab1 <vprintfmt+0x21>
            if (ch == '\0') {
c010ba9a:	85 db                	test   %ebx,%ebx
c010ba9c:	0f 84 bf 03 00 00    	je     c010be61 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010baa2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010baa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010baa9:	89 1c 24             	mov    %ebx,(%esp)
c010baac:	8b 45 08             	mov    0x8(%ebp),%eax
c010baaf:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bab1:	8b 45 10             	mov    0x10(%ebp),%eax
c010bab4:	8d 50 01             	lea    0x1(%eax),%edx
c010bab7:	89 55 10             	mov    %edx,0x10(%ebp)
c010baba:	0f b6 00             	movzbl (%eax),%eax
c010babd:	0f b6 d8             	movzbl %al,%ebx
c010bac0:	83 fb 25             	cmp    $0x25,%ebx
c010bac3:	75 d5                	jne    c010ba9a <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010bac5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010bac9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010bad0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bad3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010bad6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010badd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bae0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010bae3:	8b 45 10             	mov    0x10(%ebp),%eax
c010bae6:	8d 50 01             	lea    0x1(%eax),%edx
c010bae9:	89 55 10             	mov    %edx,0x10(%ebp)
c010baec:	0f b6 00             	movzbl (%eax),%eax
c010baef:	0f b6 d8             	movzbl %al,%ebx
c010baf2:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010baf5:	83 f8 55             	cmp    $0x55,%eax
c010baf8:	0f 87 37 03 00 00    	ja     c010be35 <vprintfmt+0x3a5>
c010bafe:	8b 04 85 08 e7 10 c0 	mov    -0x3fef18f8(,%eax,4),%eax
c010bb05:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010bb07:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010bb0b:	eb d6                	jmp    c010bae3 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010bb0d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010bb11:	eb d0                	jmp    c010bae3 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bb13:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010bb1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bb1d:	89 d0                	mov    %edx,%eax
c010bb1f:	c1 e0 02             	shl    $0x2,%eax
c010bb22:	01 d0                	add    %edx,%eax
c010bb24:	01 c0                	add    %eax,%eax
c010bb26:	01 d8                	add    %ebx,%eax
c010bb28:	83 e8 30             	sub    $0x30,%eax
c010bb2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010bb2e:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb31:	0f b6 00             	movzbl (%eax),%eax
c010bb34:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010bb37:	83 fb 2f             	cmp    $0x2f,%ebx
c010bb3a:	7e 38                	jle    c010bb74 <vprintfmt+0xe4>
c010bb3c:	83 fb 39             	cmp    $0x39,%ebx
c010bb3f:	7f 33                	jg     c010bb74 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010bb41:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010bb44:	eb d4                	jmp    c010bb1a <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010bb46:	8b 45 14             	mov    0x14(%ebp),%eax
c010bb49:	8d 50 04             	lea    0x4(%eax),%edx
c010bb4c:	89 55 14             	mov    %edx,0x14(%ebp)
c010bb4f:	8b 00                	mov    (%eax),%eax
c010bb51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010bb54:	eb 1f                	jmp    c010bb75 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010bb56:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb5a:	79 87                	jns    c010bae3 <vprintfmt+0x53>
                width = 0;
c010bb5c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010bb63:	e9 7b ff ff ff       	jmp    c010bae3 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010bb68:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010bb6f:	e9 6f ff ff ff       	jmp    c010bae3 <vprintfmt+0x53>
            goto process_precision;
c010bb74:	90                   	nop

        process_precision:
            if (width < 0)
c010bb75:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb79:	0f 89 64 ff ff ff    	jns    c010bae3 <vprintfmt+0x53>
                width = precision, precision = -1;
c010bb7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bb82:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bb85:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010bb8c:	e9 52 ff ff ff       	jmp    c010bae3 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010bb91:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010bb94:	e9 4a ff ff ff       	jmp    c010bae3 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010bb99:	8b 45 14             	mov    0x14(%ebp),%eax
c010bb9c:	8d 50 04             	lea    0x4(%eax),%edx
c010bb9f:	89 55 14             	mov    %edx,0x14(%ebp)
c010bba2:	8b 00                	mov    (%eax),%eax
c010bba4:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bba7:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bbab:	89 04 24             	mov    %eax,(%esp)
c010bbae:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbb1:	ff d0                	call   *%eax
            break;
c010bbb3:	e9 a4 02 00 00       	jmp    c010be5c <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010bbb8:	8b 45 14             	mov    0x14(%ebp),%eax
c010bbbb:	8d 50 04             	lea    0x4(%eax),%edx
c010bbbe:	89 55 14             	mov    %edx,0x14(%ebp)
c010bbc1:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010bbc3:	85 db                	test   %ebx,%ebx
c010bbc5:	79 02                	jns    c010bbc9 <vprintfmt+0x139>
                err = -err;
c010bbc7:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010bbc9:	83 fb 18             	cmp    $0x18,%ebx
c010bbcc:	7f 0b                	jg     c010bbd9 <vprintfmt+0x149>
c010bbce:	8b 34 9d 80 e6 10 c0 	mov    -0x3fef1980(,%ebx,4),%esi
c010bbd5:	85 f6                	test   %esi,%esi
c010bbd7:	75 23                	jne    c010bbfc <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010bbd9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010bbdd:	c7 44 24 08 f5 e6 10 	movl   $0xc010e6f5,0x8(%esp)
c010bbe4:	c0 
c010bbe5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbe8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbec:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbef:	89 04 24             	mov    %eax,(%esp)
c010bbf2:	e8 6a fe ff ff       	call   c010ba61 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010bbf7:	e9 60 02 00 00       	jmp    c010be5c <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010bbfc:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010bc00:	c7 44 24 08 fe e6 10 	movl   $0xc010e6fe,0x8(%esp)
c010bc07:	c0 
c010bc08:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc0f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc12:	89 04 24             	mov    %eax,(%esp)
c010bc15:	e8 47 fe ff ff       	call   c010ba61 <printfmt>
            break;
c010bc1a:	e9 3d 02 00 00       	jmp    c010be5c <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010bc1f:	8b 45 14             	mov    0x14(%ebp),%eax
c010bc22:	8d 50 04             	lea    0x4(%eax),%edx
c010bc25:	89 55 14             	mov    %edx,0x14(%ebp)
c010bc28:	8b 30                	mov    (%eax),%esi
c010bc2a:	85 f6                	test   %esi,%esi
c010bc2c:	75 05                	jne    c010bc33 <vprintfmt+0x1a3>
                p = "(null)";
c010bc2e:	be 01 e7 10 c0       	mov    $0xc010e701,%esi
            }
            if (width > 0 && padc != '-') {
c010bc33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bc37:	7e 76                	jle    c010bcaf <vprintfmt+0x21f>
c010bc39:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010bc3d:	74 70                	je     c010bcaf <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bc3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bc42:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc46:	89 34 24             	mov    %esi,(%esp)
c010bc49:	e8 f6 f7 ff ff       	call   c010b444 <strnlen>
c010bc4e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bc51:	29 c2                	sub    %eax,%edx
c010bc53:	89 d0                	mov    %edx,%eax
c010bc55:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bc58:	eb 16                	jmp    c010bc70 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c010bc5a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010bc5e:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bc61:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bc65:	89 04 24             	mov    %eax,(%esp)
c010bc68:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc6b:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bc6d:	ff 4d e8             	decl   -0x18(%ebp)
c010bc70:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bc74:	7f e4                	jg     c010bc5a <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bc76:	eb 37                	jmp    c010bcaf <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c010bc78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010bc7c:	74 1f                	je     c010bc9d <vprintfmt+0x20d>
c010bc7e:	83 fb 1f             	cmp    $0x1f,%ebx
c010bc81:	7e 05                	jle    c010bc88 <vprintfmt+0x1f8>
c010bc83:	83 fb 7e             	cmp    $0x7e,%ebx
c010bc86:	7e 15                	jle    c010bc9d <vprintfmt+0x20d>
                    putch('?', putdat);
c010bc88:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc8f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bc96:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc99:	ff d0                	call   *%eax
c010bc9b:	eb 0f                	jmp    c010bcac <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010bc9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bca0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bca4:	89 1c 24             	mov    %ebx,(%esp)
c010bca7:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcaa:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bcac:	ff 4d e8             	decl   -0x18(%ebp)
c010bcaf:	89 f0                	mov    %esi,%eax
c010bcb1:	8d 70 01             	lea    0x1(%eax),%esi
c010bcb4:	0f b6 00             	movzbl (%eax),%eax
c010bcb7:	0f be d8             	movsbl %al,%ebx
c010bcba:	85 db                	test   %ebx,%ebx
c010bcbc:	74 27                	je     c010bce5 <vprintfmt+0x255>
c010bcbe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bcc2:	78 b4                	js     c010bc78 <vprintfmt+0x1e8>
c010bcc4:	ff 4d e4             	decl   -0x1c(%ebp)
c010bcc7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bccb:	79 ab                	jns    c010bc78 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c010bccd:	eb 16                	jmp    c010bce5 <vprintfmt+0x255>
                putch(' ', putdat);
c010bccf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcd2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcd6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bcdd:	8b 45 08             	mov    0x8(%ebp),%eax
c010bce0:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010bce2:	ff 4d e8             	decl   -0x18(%ebp)
c010bce5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bce9:	7f e4                	jg     c010bccf <vprintfmt+0x23f>
            }
            break;
c010bceb:	e9 6c 01 00 00       	jmp    c010be5c <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bcf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bcf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcf7:	8d 45 14             	lea    0x14(%ebp),%eax
c010bcfa:	89 04 24             	mov    %eax,(%esp)
c010bcfd:	e8 18 fd ff ff       	call   c010ba1a <getint>
c010bd02:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd05:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010bd08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bd0e:	85 d2                	test   %edx,%edx
c010bd10:	79 26                	jns    c010bd38 <vprintfmt+0x2a8>
                putch('-', putdat);
c010bd12:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd15:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd19:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010bd20:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd23:	ff d0                	call   *%eax
                num = -(long long)num;
c010bd25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd28:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bd2b:	f7 d8                	neg    %eax
c010bd2d:	83 d2 00             	adc    $0x0,%edx
c010bd30:	f7 da                	neg    %edx
c010bd32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd35:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010bd38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bd3f:	e9 a8 00 00 00       	jmp    c010bdec <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010bd44:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bd47:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd4b:	8d 45 14             	lea    0x14(%ebp),%eax
c010bd4e:	89 04 24             	mov    %eax,(%esp)
c010bd51:	e8 75 fc ff ff       	call   c010b9cb <getuint>
c010bd56:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd59:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010bd5c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bd63:	e9 84 00 00 00       	jmp    c010bdec <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010bd68:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bd6b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd6f:	8d 45 14             	lea    0x14(%ebp),%eax
c010bd72:	89 04 24             	mov    %eax,(%esp)
c010bd75:	e8 51 fc ff ff       	call   c010b9cb <getuint>
c010bd7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd7d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010bd80:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010bd87:	eb 63                	jmp    c010bdec <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c010bd89:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd90:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010bd97:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd9a:	ff d0                	call   *%eax
            putch('x', putdat);
c010bd9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bda3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010bdaa:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdad:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010bdaf:	8b 45 14             	mov    0x14(%ebp),%eax
c010bdb2:	8d 50 04             	lea    0x4(%eax),%edx
c010bdb5:	89 55 14             	mov    %edx,0x14(%ebp)
c010bdb8:	8b 00                	mov    (%eax),%eax
c010bdba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bdbd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010bdc4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010bdcb:	eb 1f                	jmp    c010bdec <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010bdcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bdd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bdd4:	8d 45 14             	lea    0x14(%ebp),%eax
c010bdd7:	89 04 24             	mov    %eax,(%esp)
c010bdda:	e8 ec fb ff ff       	call   c010b9cb <getuint>
c010bddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bde2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010bde5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010bdec:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010bdf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bdf3:	89 54 24 18          	mov    %edx,0x18(%esp)
c010bdf7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bdfa:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bdfe:	89 44 24 10          	mov    %eax,0x10(%esp)
c010be02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010be05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010be08:	89 44 24 08          	mov    %eax,0x8(%esp)
c010be0c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010be10:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be13:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be17:	8b 45 08             	mov    0x8(%ebp),%eax
c010be1a:	89 04 24             	mov    %eax,(%esp)
c010be1d:	e8 a4 fa ff ff       	call   c010b8c6 <printnum>
            break;
c010be22:	eb 38                	jmp    c010be5c <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010be24:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be27:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be2b:	89 1c 24             	mov    %ebx,(%esp)
c010be2e:	8b 45 08             	mov    0x8(%ebp),%eax
c010be31:	ff d0                	call   *%eax
            break;
c010be33:	eb 27                	jmp    c010be5c <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010be35:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be38:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be3c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010be43:	8b 45 08             	mov    0x8(%ebp),%eax
c010be46:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010be48:	ff 4d 10             	decl   0x10(%ebp)
c010be4b:	eb 03                	jmp    c010be50 <vprintfmt+0x3c0>
c010be4d:	ff 4d 10             	decl   0x10(%ebp)
c010be50:	8b 45 10             	mov    0x10(%ebp),%eax
c010be53:	48                   	dec    %eax
c010be54:	0f b6 00             	movzbl (%eax),%eax
c010be57:	3c 25                	cmp    $0x25,%al
c010be59:	75 f2                	jne    c010be4d <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c010be5b:	90                   	nop
    while (1) {
c010be5c:	e9 37 fc ff ff       	jmp    c010ba98 <vprintfmt+0x8>
                return;
c010be61:	90                   	nop
        }
    }
}
c010be62:	83 c4 40             	add    $0x40,%esp
c010be65:	5b                   	pop    %ebx
c010be66:	5e                   	pop    %esi
c010be67:	5d                   	pop    %ebp
c010be68:	c3                   	ret    

c010be69 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010be69:	55                   	push   %ebp
c010be6a:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010be6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be6f:	8b 40 08             	mov    0x8(%eax),%eax
c010be72:	8d 50 01             	lea    0x1(%eax),%edx
c010be75:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be78:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010be7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be7e:	8b 10                	mov    (%eax),%edx
c010be80:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be83:	8b 40 04             	mov    0x4(%eax),%eax
c010be86:	39 c2                	cmp    %eax,%edx
c010be88:	73 12                	jae    c010be9c <sprintputch+0x33>
        *b->buf ++ = ch;
c010be8a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be8d:	8b 00                	mov    (%eax),%eax
c010be8f:	8d 48 01             	lea    0x1(%eax),%ecx
c010be92:	8b 55 0c             	mov    0xc(%ebp),%edx
c010be95:	89 0a                	mov    %ecx,(%edx)
c010be97:	8b 55 08             	mov    0x8(%ebp),%edx
c010be9a:	88 10                	mov    %dl,(%eax)
    }
}
c010be9c:	90                   	nop
c010be9d:	5d                   	pop    %ebp
c010be9e:	c3                   	ret    

c010be9f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010be9f:	55                   	push   %ebp
c010bea0:	89 e5                	mov    %esp,%ebp
c010bea2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010bea5:	8d 45 14             	lea    0x14(%ebp),%eax
c010bea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010beab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010beae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010beb2:	8b 45 10             	mov    0x10(%ebp),%eax
c010beb5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010beb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bebc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bec0:	8b 45 08             	mov    0x8(%ebp),%eax
c010bec3:	89 04 24             	mov    %eax,(%esp)
c010bec6:	e8 08 00 00 00       	call   c010bed3 <vsnprintf>
c010becb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010bece:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bed1:	c9                   	leave  
c010bed2:	c3                   	ret    

c010bed3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010bed3:	55                   	push   %ebp
c010bed4:	89 e5                	mov    %esp,%ebp
c010bed6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010bed9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bedc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bedf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bee2:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bee5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bee8:	01 d0                	add    %edx,%eax
c010beea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010beed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010bef4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010bef8:	74 0a                	je     c010bf04 <vsnprintf+0x31>
c010befa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010befd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf00:	39 c2                	cmp    %eax,%edx
c010bf02:	76 07                	jbe    c010bf0b <vsnprintf+0x38>
        return -E_INVAL;
c010bf04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010bf09:	eb 2a                	jmp    c010bf35 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010bf0b:	8b 45 14             	mov    0x14(%ebp),%eax
c010bf0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bf12:	8b 45 10             	mov    0x10(%ebp),%eax
c010bf15:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bf19:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010bf1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf20:	c7 04 24 69 be 10 c0 	movl   $0xc010be69,(%esp)
c010bf27:	e8 64 fb ff ff       	call   c010ba90 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010bf2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bf2f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010bf32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bf35:	c9                   	leave  
c010bf36:	c3                   	ret    

c010bf37 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010bf37:	55                   	push   %ebp
c010bf38:	89 e5                	mov    %esp,%ebp
c010bf3a:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010bf3d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf40:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010bf46:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010bf49:	b8 20 00 00 00       	mov    $0x20,%eax
c010bf4e:	2b 45 0c             	sub    0xc(%ebp),%eax
c010bf51:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010bf54:	88 c1                	mov    %al,%cl
c010bf56:	d3 ea                	shr    %cl,%edx
c010bf58:	89 d0                	mov    %edx,%eax
}
c010bf5a:	c9                   	leave  
c010bf5b:	c3                   	ret    

c010bf5c <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010bf5c:	55                   	push   %ebp
c010bf5d:	89 e5                	mov    %esp,%ebp
c010bf5f:	57                   	push   %edi
c010bf60:	56                   	push   %esi
c010bf61:	53                   	push   %ebx
c010bf62:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010bf65:	a1 00 bb 12 c0       	mov    0xc012bb00,%eax
c010bf6a:	8b 15 04 bb 12 c0    	mov    0xc012bb04,%edx
c010bf70:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010bf76:	6b f0 05             	imul   $0x5,%eax,%esi
c010bf79:	01 fe                	add    %edi,%esi
c010bf7b:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010bf80:	f7 e7                	mul    %edi
c010bf82:	01 d6                	add    %edx,%esi
c010bf84:	89 f2                	mov    %esi,%edx
c010bf86:	83 c0 0b             	add    $0xb,%eax
c010bf89:	83 d2 00             	adc    $0x0,%edx
c010bf8c:	89 c7                	mov    %eax,%edi
c010bf8e:	83 e7 ff             	and    $0xffffffff,%edi
c010bf91:	89 f9                	mov    %edi,%ecx
c010bf93:	0f b7 da             	movzwl %dx,%ebx
c010bf96:	89 0d 00 bb 12 c0    	mov    %ecx,0xc012bb00
c010bf9c:	89 1d 04 bb 12 c0    	mov    %ebx,0xc012bb04
    unsigned long long result = (next >> 12);
c010bfa2:	8b 1d 00 bb 12 c0    	mov    0xc012bb00,%ebx
c010bfa8:	8b 35 04 bb 12 c0    	mov    0xc012bb04,%esi
c010bfae:	89 d8                	mov    %ebx,%eax
c010bfb0:	89 f2                	mov    %esi,%edx
c010bfb2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010bfb6:	c1 ea 0c             	shr    $0xc,%edx
c010bfb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bfbc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010bfbf:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010bfc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bfc9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bfcc:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bfcf:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bfd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bfd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bfd8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bfdc:	74 1c                	je     c010bffa <rand+0x9e>
c010bfde:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bfe1:	ba 00 00 00 00       	mov    $0x0,%edx
c010bfe6:	f7 75 dc             	divl   -0x24(%ebp)
c010bfe9:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bfec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bfef:	ba 00 00 00 00       	mov    $0x0,%edx
c010bff4:	f7 75 dc             	divl   -0x24(%ebp)
c010bff7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bffa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bffd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c000:	f7 75 dc             	divl   -0x24(%ebp)
c010c003:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c006:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c009:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c00c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c00f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c012:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c015:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010c018:	83 c4 24             	add    $0x24,%esp
c010c01b:	5b                   	pop    %ebx
c010c01c:	5e                   	pop    %esi
c010c01d:	5f                   	pop    %edi
c010c01e:	5d                   	pop    %ebp
c010c01f:	c3                   	ret    

c010c020 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010c020:	55                   	push   %ebp
c010c021:	89 e5                	mov    %esp,%ebp
    next = seed;
c010c023:	8b 45 08             	mov    0x8(%ebp),%eax
c010c026:	ba 00 00 00 00       	mov    $0x0,%edx
c010c02b:	a3 00 bb 12 c0       	mov    %eax,0xc012bb00
c010c030:	89 15 04 bb 12 c0    	mov    %edx,0xc012bb04
}
c010c036:	90                   	nop
c010c037:	5d                   	pop    %ebp
c010c038:	c3                   	ret    
