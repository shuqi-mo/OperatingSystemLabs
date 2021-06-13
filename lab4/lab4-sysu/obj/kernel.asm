
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 12 00       	mov    $0x121000,%eax
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
c0100020:	a3 00 10 12 c0       	mov    %eax,0xc0121000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 00 12 c0       	mov    $0xc0120000,%esp
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

static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba fc 40 12 c0       	mov    $0xc01240fc,%edx
c0100041:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 30 12 c0       	push   $0xc0123000
c0100055:	e8 a6 7b 00 00       	call   c0107c00 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 2c 1d 00 00       	call   c0101d8e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 80 84 10 c0 	movl   $0xc0108480,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 9c 84 10 c0       	push   $0xc010849c
c0100074:	e8 09 02 00 00       	call   c0100282 <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 a0 08 00 00       	call   c0100921 <print_kerninfo>

    grade_backtrace();
c0100081:	e8 83 00 00 00       	call   c0100109 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 71 66 00 00       	call   c01066fc <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 70 1e 00 00       	call   c0101f00 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 d1 1f 00 00       	call   c0102066 <idt_init>

    vmm_init();                 // init virtual memory management
c0100095:	e8 63 34 00 00       	call   c01034fd <vmm_init>

    ide_init();                 // init ide devices
c010009a:	e8 3f 0d 00 00       	call   c0100dde <ide_init>
    swap_init();                // init swap
c010009f:	e8 60 43 00 00       	call   c0104404 <swap_init>

    clock_init();               // init clock interrupt
c01000a4:	e8 88 14 00 00       	call   c0101531 <clock_init>
    intr_enable();              // enable irq interrupt
c01000a9:	e8 8f 1f 00 00       	call   c010203d <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000ae:	eb fe                	jmp    c01000ae <kern_init+0x78>

c01000b0 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b0:	55                   	push   %ebp
c01000b1:	89 e5                	mov    %esp,%ebp
c01000b3:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000b6:	83 ec 04             	sub    $0x4,%esp
c01000b9:	6a 00                	push   $0x0
c01000bb:	6a 00                	push   $0x0
c01000bd:	6a 00                	push   $0x0
c01000bf:	e8 ae 0c 00 00       	call   c0100d72 <mon_backtrace>
c01000c4:	83 c4 10             	add    $0x10,%esp
}
c01000c7:	90                   	nop
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	51                   	push   %ecx
c01000de:	52                   	push   %edx
c01000df:	53                   	push   %ebx
c01000e0:	50                   	push   %eax
c01000e1:	e8 ca ff ff ff       	call   c01000b0 <grade_backtrace2>
c01000e6:	83 c4 10             	add    $0x10,%esp
}
c01000e9:	90                   	nop
c01000ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000ed:	c9                   	leave  
c01000ee:	c3                   	ret    

c01000ef <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000ef:	55                   	push   %ebp
c01000f0:	89 e5                	mov    %esp,%ebp
c01000f2:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000f5:	83 ec 08             	sub    $0x8,%esp
c01000f8:	ff 75 10             	pushl  0x10(%ebp)
c01000fb:	ff 75 08             	pushl  0x8(%ebp)
c01000fe:	e8 c7 ff ff ff       	call   c01000ca <grade_backtrace1>
c0100103:	83 c4 10             	add    $0x10,%esp
}
c0100106:	90                   	nop
c0100107:	c9                   	leave  
c0100108:	c3                   	ret    

c0100109 <grade_backtrace>:

void
grade_backtrace(void) {
c0100109:	55                   	push   %ebp
c010010a:	89 e5                	mov    %esp,%ebp
c010010c:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010010f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100114:	83 ec 04             	sub    $0x4,%esp
c0100117:	68 00 00 ff ff       	push   $0xffff0000
c010011c:	50                   	push   %eax
c010011d:	6a 00                	push   $0x0
c010011f:	e8 cb ff ff ff       	call   c01000ef <grade_backtrace0>
c0100124:	83 c4 10             	add    $0x10,%esp
}
c0100127:	90                   	nop
c0100128:	c9                   	leave  
c0100129:	c3                   	ret    

c010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010012a:	55                   	push   %ebp
c010012b:	89 e5                	mov    %esp,%ebp
c010012d:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100140:	0f b7 c0             	movzwl %ax,%eax
c0100143:	83 e0 03             	and    $0x3,%eax
c0100146:	89 c2                	mov    %eax,%edx
c0100148:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c010014d:	83 ec 04             	sub    $0x4,%esp
c0100150:	52                   	push   %edx
c0100151:	50                   	push   %eax
c0100152:	68 a1 84 10 c0       	push   $0xc01084a1
c0100157:	e8 26 01 00 00       	call   c0100282 <cprintf>
c010015c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c010015f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100163:	0f b7 d0             	movzwl %ax,%edx
c0100166:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c010016b:	83 ec 04             	sub    $0x4,%esp
c010016e:	52                   	push   %edx
c010016f:	50                   	push   %eax
c0100170:	68 af 84 10 c0       	push   $0xc01084af
c0100175:	e8 08 01 00 00       	call   c0100282 <cprintf>
c010017a:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c010017d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100181:	0f b7 d0             	movzwl %ax,%edx
c0100184:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100189:	83 ec 04             	sub    $0x4,%esp
c010018c:	52                   	push   %edx
c010018d:	50                   	push   %eax
c010018e:	68 bd 84 10 c0       	push   $0xc01084bd
c0100193:	e8 ea 00 00 00       	call   c0100282 <cprintf>
c0100198:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c010019b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010019f:	0f b7 d0             	movzwl %ax,%edx
c01001a2:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001a7:	83 ec 04             	sub    $0x4,%esp
c01001aa:	52                   	push   %edx
c01001ab:	50                   	push   %eax
c01001ac:	68 cb 84 10 c0       	push   $0xc01084cb
c01001b1:	e8 cc 00 00 00       	call   c0100282 <cprintf>
c01001b6:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001b9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001bd:	0f b7 d0             	movzwl %ax,%edx
c01001c0:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001c5:	83 ec 04             	sub    $0x4,%esp
c01001c8:	52                   	push   %edx
c01001c9:	50                   	push   %eax
c01001ca:	68 d9 84 10 c0       	push   $0xc01084d9
c01001cf:	e8 ae 00 00 00       	call   c0100282 <cprintf>
c01001d4:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001d7:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001dc:	83 c0 01             	add    $0x1,%eax
c01001df:	a3 00 30 12 c0       	mov    %eax,0xc0123000
}
c01001e4:	90                   	nop
c01001e5:	c9                   	leave  
c01001e6:	c3                   	ret    

c01001e7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001e7:	55                   	push   %ebp
c01001e8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ea:	90                   	nop
c01001eb:	5d                   	pop    %ebp
c01001ec:	c3                   	ret    

c01001ed <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001ed:	55                   	push   %ebp
c01001ee:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f0:	90                   	nop
c01001f1:	5d                   	pop    %ebp
c01001f2:	c3                   	ret    

c01001f3 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001f3:	55                   	push   %ebp
c01001f4:	89 e5                	mov    %esp,%ebp
c01001f6:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c01001f9:	e8 2c ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c01001fe:	83 ec 0c             	sub    $0xc,%esp
c0100201:	68 e8 84 10 c0       	push   $0xc01084e8
c0100206:	e8 77 00 00 00       	call   c0100282 <cprintf>
c010020b:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c010020e:	e8 d4 ff ff ff       	call   c01001e7 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100213:	e8 12 ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100218:	83 ec 0c             	sub    $0xc,%esp
c010021b:	68 08 85 10 c0       	push   $0xc0108508
c0100220:	e8 5d 00 00 00       	call   c0100282 <cprintf>
c0100225:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100228:	e8 c0 ff ff ff       	call   c01001ed <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010022d:	e8 f8 fe ff ff       	call   c010012a <lab1_print_cur_status>
}
c0100232:	90                   	nop
c0100233:	c9                   	leave  
c0100234:	c3                   	ret    

c0100235 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100235:	55                   	push   %ebp
c0100236:	89 e5                	mov    %esp,%ebp
c0100238:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010023b:	83 ec 0c             	sub    $0xc,%esp
c010023e:	ff 75 08             	pushl  0x8(%ebp)
c0100241:	e8 79 1b 00 00       	call   c0101dbf <cons_putc>
c0100246:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c0100249:	8b 45 0c             	mov    0xc(%ebp),%eax
c010024c:	8b 00                	mov    (%eax),%eax
c010024e:	8d 50 01             	lea    0x1(%eax),%edx
c0100251:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100254:	89 10                	mov    %edx,(%eax)
}
c0100256:	90                   	nop
c0100257:	c9                   	leave  
c0100258:	c3                   	ret    

c0100259 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100259:	55                   	push   %ebp
c010025a:	89 e5                	mov    %esp,%ebp
c010025c:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c010025f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100266:	ff 75 0c             	pushl  0xc(%ebp)
c0100269:	ff 75 08             	pushl  0x8(%ebp)
c010026c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010026f:	50                   	push   %eax
c0100270:	68 35 02 10 c0       	push   $0xc0100235
c0100275:	e8 bc 7c 00 00       	call   c0107f36 <vprintfmt>
c010027a:	83 c4 10             	add    $0x10,%esp
    return cnt;
c010027d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100280:	c9                   	leave  
c0100281:	c3                   	ret    

c0100282 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100282:	55                   	push   %ebp
c0100283:	89 e5                	mov    %esp,%ebp
c0100285:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100288:	8d 45 0c             	lea    0xc(%ebp),%eax
c010028b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010028e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100291:	83 ec 08             	sub    $0x8,%esp
c0100294:	50                   	push   %eax
c0100295:	ff 75 08             	pushl  0x8(%ebp)
c0100298:	e8 bc ff ff ff       	call   c0100259 <vcprintf>
c010029d:	83 c4 10             	add    $0x10,%esp
c01002a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a6:	c9                   	leave  
c01002a7:	c3                   	ret    

c01002a8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002a8:	55                   	push   %ebp
c01002a9:	89 e5                	mov    %esp,%ebp
c01002ab:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c01002ae:	83 ec 0c             	sub    $0xc,%esp
c01002b1:	ff 75 08             	pushl  0x8(%ebp)
c01002b4:	e8 06 1b 00 00       	call   c0101dbf <cons_putc>
c01002b9:	83 c4 10             	add    $0x10,%esp
}
c01002bc:	90                   	nop
c01002bd:	c9                   	leave  
c01002be:	c3                   	ret    

c01002bf <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002bf:	55                   	push   %ebp
c01002c0:	89 e5                	mov    %esp,%ebp
c01002c2:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002cc:	eb 14                	jmp    c01002e2 <cputs+0x23>
        cputch(c, &cnt);
c01002ce:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002d2:	83 ec 08             	sub    $0x8,%esp
c01002d5:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002d8:	52                   	push   %edx
c01002d9:	50                   	push   %eax
c01002da:	e8 56 ff ff ff       	call   c0100235 <cputch>
c01002df:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
c01002e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e5:	8d 50 01             	lea    0x1(%eax),%edx
c01002e8:	89 55 08             	mov    %edx,0x8(%ebp)
c01002eb:	0f b6 00             	movzbl (%eax),%eax
c01002ee:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002f1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002f5:	75 d7                	jne    c01002ce <cputs+0xf>
    }
    cputch('\n', &cnt);
c01002f7:	83 ec 08             	sub    $0x8,%esp
c01002fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01002fd:	50                   	push   %eax
c01002fe:	6a 0a                	push   $0xa
c0100300:	e8 30 ff ff ff       	call   c0100235 <cputch>
c0100305:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100308:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010030b:	c9                   	leave  
c010030c:	c3                   	ret    

c010030d <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010030d:	55                   	push   %ebp
c010030e:	89 e5                	mov    %esp,%ebp
c0100310:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100313:	e8 f0 1a 00 00       	call   c0101e08 <cons_getc>
c0100318:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010031b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010031f:	74 f2                	je     c0100313 <getchar+0x6>
        /* do nothing */;
    return c;
c0100321:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100324:	c9                   	leave  
c0100325:	c3                   	ret    

c0100326 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100326:	55                   	push   %ebp
c0100327:	89 e5                	mov    %esp,%ebp
c0100329:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c010032c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100330:	74 13                	je     c0100345 <readline+0x1f>
        cprintf("%s", prompt);
c0100332:	83 ec 08             	sub    $0x8,%esp
c0100335:	ff 75 08             	pushl  0x8(%ebp)
c0100338:	68 27 85 10 c0       	push   $0xc0108527
c010033d:	e8 40 ff ff ff       	call   c0100282 <cprintf>
c0100342:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c0100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010034c:	e8 bc ff ff ff       	call   c010030d <getchar>
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100354:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100358:	79 0a                	jns    c0100364 <readline+0x3e>
            return NULL;
c010035a:	b8 00 00 00 00       	mov    $0x0,%eax
c010035f:	e9 82 00 00 00       	jmp    c01003e6 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100364:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100368:	7e 2b                	jle    c0100395 <readline+0x6f>
c010036a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100371:	7f 22                	jg     c0100395 <readline+0x6f>
            cputchar(c);
c0100373:	83 ec 0c             	sub    $0xc,%esp
c0100376:	ff 75 f0             	pushl  -0x10(%ebp)
c0100379:	e8 2a ff ff ff       	call   c01002a8 <cputchar>
c010037e:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100381:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100384:	8d 50 01             	lea    0x1(%eax),%edx
c0100387:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010038a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010038d:	88 90 20 30 12 c0    	mov    %dl,-0x3fedcfe0(%eax)
c0100393:	eb 4c                	jmp    c01003e1 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c0100395:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0100399:	75 1a                	jne    c01003b5 <readline+0x8f>
c010039b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010039f:	7e 14                	jle    c01003b5 <readline+0x8f>
            cputchar(c);
c01003a1:	83 ec 0c             	sub    $0xc,%esp
c01003a4:	ff 75 f0             	pushl  -0x10(%ebp)
c01003a7:	e8 fc fe ff ff       	call   c01002a8 <cputchar>
c01003ac:	83 c4 10             	add    $0x10,%esp
            i --;
c01003af:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003b3:	eb 2c                	jmp    c01003e1 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c01003b5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003b9:	74 06                	je     c01003c1 <readline+0x9b>
c01003bb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003bf:	75 8b                	jne    c010034c <readline+0x26>
            cputchar(c);
c01003c1:	83 ec 0c             	sub    $0xc,%esp
c01003c4:	ff 75 f0             	pushl  -0x10(%ebp)
c01003c7:	e8 dc fe ff ff       	call   c01002a8 <cputchar>
c01003cc:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d2:	05 20 30 12 c0       	add    $0xc0123020,%eax
c01003d7:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003da:	b8 20 30 12 c0       	mov    $0xc0123020,%eax
c01003df:	eb 05                	jmp    c01003e6 <readline+0xc0>
        c = getchar();
c01003e1:	e9 66 ff ff ff       	jmp    c010034c <readline+0x26>
        }
    }
}
c01003e6:	c9                   	leave  
c01003e7:	c3                   	ret    

c01003e8 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e8:	55                   	push   %ebp
c01003e9:	89 e5                	mov    %esp,%ebp
c01003eb:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01003ee:	a1 20 34 12 c0       	mov    0xc0123420,%eax
c01003f3:	85 c0                	test   %eax,%eax
c01003f5:	75 5f                	jne    c0100456 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c01003f7:	c7 05 20 34 12 c0 01 	movl   $0x1,0xc0123420
c01003fe:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100401:	8d 45 14             	lea    0x14(%ebp),%eax
c0100404:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100407:	83 ec 04             	sub    $0x4,%esp
c010040a:	ff 75 0c             	pushl  0xc(%ebp)
c010040d:	ff 75 08             	pushl  0x8(%ebp)
c0100410:	68 2a 85 10 c0       	push   $0xc010852a
c0100415:	e8 68 fe ff ff       	call   c0100282 <cprintf>
c010041a:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010041d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100420:	83 ec 08             	sub    $0x8,%esp
c0100423:	50                   	push   %eax
c0100424:	ff 75 10             	pushl  0x10(%ebp)
c0100427:	e8 2d fe ff ff       	call   c0100259 <vcprintf>
c010042c:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c010042f:	83 ec 0c             	sub    $0xc,%esp
c0100432:	68 46 85 10 c0       	push   $0xc0108546
c0100437:	e8 46 fe ff ff       	call   c0100282 <cprintf>
c010043c:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c010043f:	83 ec 0c             	sub    $0xc,%esp
c0100442:	68 48 85 10 c0       	push   $0xc0108548
c0100447:	e8 36 fe ff ff       	call   c0100282 <cprintf>
c010044c:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c010044f:	e8 17 06 00 00       	call   c0100a6b <print_stackframe>
c0100454:	eb 01                	jmp    c0100457 <__panic+0x6f>
        goto panic_dead;
c0100456:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100457:	e8 e8 1b 00 00       	call   c0102044 <intr_disable>
    while (1) {
        kmonitor(NULL);
c010045c:	83 ec 0c             	sub    $0xc,%esp
c010045f:	6a 00                	push   $0x0
c0100461:	e8 32 08 00 00       	call   c0100c98 <kmonitor>
c0100466:	83 c4 10             	add    $0x10,%esp
c0100469:	eb f1                	jmp    c010045c <__panic+0x74>

c010046b <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010046b:	55                   	push   %ebp
c010046c:	89 e5                	mov    %esp,%ebp
c010046e:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100471:	8d 45 14             	lea    0x14(%ebp),%eax
c0100474:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100477:	83 ec 04             	sub    $0x4,%esp
c010047a:	ff 75 0c             	pushl  0xc(%ebp)
c010047d:	ff 75 08             	pushl  0x8(%ebp)
c0100480:	68 5a 85 10 c0       	push   $0xc010855a
c0100485:	e8 f8 fd ff ff       	call   c0100282 <cprintf>
c010048a:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	83 ec 08             	sub    $0x8,%esp
c0100493:	50                   	push   %eax
c0100494:	ff 75 10             	pushl  0x10(%ebp)
c0100497:	e8 bd fd ff ff       	call   c0100259 <vcprintf>
c010049c:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c010049f:	83 ec 0c             	sub    $0xc,%esp
c01004a2:	68 46 85 10 c0       	push   $0xc0108546
c01004a7:	e8 d6 fd ff ff       	call   c0100282 <cprintf>
c01004ac:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c01004af:	90                   	nop
c01004b0:	c9                   	leave  
c01004b1:	c3                   	ret    

c01004b2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004b2:	55                   	push   %ebp
c01004b3:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b5:	a1 20 34 12 c0       	mov    0xc0123420,%eax
}
c01004ba:	5d                   	pop    %ebp
c01004bb:	c3                   	ret    

c01004bc <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004bc:	55                   	push   %ebp
c01004bd:	89 e5                	mov    %esp,%ebp
c01004bf:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c5:	8b 00                	mov    (%eax),%eax
c01004c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01004cd:	8b 00                	mov    (%eax),%eax
c01004cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d9:	e9 d2 00 00 00       	jmp    c01005b0 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004de:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e4:	01 d0                	add    %edx,%eax
c01004e6:	89 c2                	mov    %eax,%edx
c01004e8:	c1 ea 1f             	shr    $0x1f,%edx
c01004eb:	01 d0                	add    %edx,%eax
c01004ed:	d1 f8                	sar    %eax
c01004ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f8:	eb 04                	jmp    c01004fe <stab_binsearch+0x42>
            m --;
c01004fa:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c01004fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100501:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100504:	7c 1f                	jl     c0100525 <stab_binsearch+0x69>
c0100506:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100509:	89 d0                	mov    %edx,%eax
c010050b:	01 c0                	add    %eax,%eax
c010050d:	01 d0                	add    %edx,%eax
c010050f:	c1 e0 02             	shl    $0x2,%eax
c0100512:	89 c2                	mov    %eax,%edx
c0100514:	8b 45 08             	mov    0x8(%ebp),%eax
c0100517:	01 d0                	add    %edx,%eax
c0100519:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010051d:	0f b6 c0             	movzbl %al,%eax
c0100520:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100523:	75 d5                	jne    c01004fa <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100525:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100528:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010052b:	7d 0b                	jge    c0100538 <stab_binsearch+0x7c>
            l = true_m + 1;
c010052d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100530:	83 c0 01             	add    $0x1,%eax
c0100533:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100536:	eb 78                	jmp    c01005b0 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100538:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010053f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100542:	89 d0                	mov    %edx,%eax
c0100544:	01 c0                	add    %eax,%eax
c0100546:	01 d0                	add    %edx,%eax
c0100548:	c1 e0 02             	shl    $0x2,%eax
c010054b:	89 c2                	mov    %eax,%edx
c010054d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100550:	01 d0                	add    %edx,%eax
c0100552:	8b 40 08             	mov    0x8(%eax),%eax
c0100555:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100558:	76 13                	jbe    c010056d <stab_binsearch+0xb1>
            *region_left = m;
c010055a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100560:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100562:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100565:	83 c0 01             	add    $0x1,%eax
c0100568:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010056b:	eb 43                	jmp    c01005b0 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010056d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100570:	89 d0                	mov    %edx,%eax
c0100572:	01 c0                	add    %eax,%eax
c0100574:	01 d0                	add    %edx,%eax
c0100576:	c1 e0 02             	shl    $0x2,%eax
c0100579:	89 c2                	mov    %eax,%edx
c010057b:	8b 45 08             	mov    0x8(%ebp),%eax
c010057e:	01 d0                	add    %edx,%eax
c0100580:	8b 40 08             	mov    0x8(%eax),%eax
c0100583:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100586:	73 16                	jae    c010059e <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100588:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010058e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100591:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100593:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100596:	83 e8 01             	sub    $0x1,%eax
c0100599:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010059c:	eb 12                	jmp    c01005b0 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010059e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a4:	89 10                	mov    %edx,(%eax)
            l = m;
c01005a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005ac:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01005b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005b6:	0f 8e 22 ff ff ff    	jle    c01004de <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c0:	75 0f                	jne    c01005d1 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c5:	8b 00                	mov    (%eax),%eax
c01005c7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01005cd:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005cf:	eb 3f                	jmp    c0100610 <stab_binsearch+0x154>
        l = *region_right;
c01005d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d4:	8b 00                	mov    (%eax),%eax
c01005d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005d9:	eb 04                	jmp    c01005df <stab_binsearch+0x123>
c01005db:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e2:	8b 00                	mov    (%eax),%eax
c01005e4:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005e7:	7e 1f                	jle    c0100608 <stab_binsearch+0x14c>
c01005e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ec:	89 d0                	mov    %edx,%eax
c01005ee:	01 c0                	add    %eax,%eax
c01005f0:	01 d0                	add    %edx,%eax
c01005f2:	c1 e0 02             	shl    $0x2,%eax
c01005f5:	89 c2                	mov    %eax,%edx
c01005f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fa:	01 d0                	add    %edx,%eax
c01005fc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100600:	0f b6 c0             	movzbl %al,%eax
c0100603:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100606:	75 d3                	jne    c01005db <stab_binsearch+0x11f>
        *region_left = l;
c0100608:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010060e:	89 10                	mov    %edx,(%eax)
}
c0100610:	90                   	nop
c0100611:	c9                   	leave  
c0100612:	c3                   	ret    

c0100613 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100613:	55                   	push   %ebp
c0100614:	89 e5                	mov    %esp,%ebp
c0100616:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100619:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061c:	c7 00 78 85 10 c0    	movl   $0xc0108578,(%eax)
    info->eip_line = 0;
c0100622:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100625:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062f:	c7 40 08 78 85 10 c0 	movl   $0xc0108578,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100639:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100640:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100643:	8b 55 08             	mov    0x8(%ebp),%edx
c0100646:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100649:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100653:	c7 45 f4 a0 a4 10 c0 	movl   $0xc010a4a0,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065a:	c7 45 f0 a0 9d 11 c0 	movl   $0xc0119da0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100661:	c7 45 ec a1 9d 11 c0 	movl   $0xc0119da1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100668:	c7 45 e8 6c d7 11 c0 	movl   $0xc011d76c,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010066f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100672:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100675:	76 0d                	jbe    c0100684 <debuginfo_eip+0x71>
c0100677:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067a:	83 e8 01             	sub    $0x1,%eax
c010067d:	0f b6 00             	movzbl (%eax),%eax
c0100680:	84 c0                	test   %al,%al
c0100682:	74 0a                	je     c010068e <debuginfo_eip+0x7b>
        return -1;
c0100684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100689:	e9 91 02 00 00       	jmp    c010091f <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100695:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069b:	29 c2                	sub    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	c1 f8 02             	sar    $0x2,%eax
c01006a2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a8:	83 e8 01             	sub    $0x1,%eax
c01006ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ae:	ff 75 08             	pushl  0x8(%ebp)
c01006b1:	6a 64                	push   $0x64
c01006b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006b6:	50                   	push   %eax
c01006b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006ba:	50                   	push   %eax
c01006bb:	ff 75 f4             	pushl  -0xc(%ebp)
c01006be:	e8 f9 fd ff ff       	call   c01004bc <stab_binsearch>
c01006c3:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c01006c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c9:	85 c0                	test   %eax,%eax
c01006cb:	75 0a                	jne    c01006d7 <debuginfo_eip+0xc4>
        return -1;
c01006cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d2:	e9 48 02 00 00       	jmp    c010091f <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006da:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e3:	ff 75 08             	pushl  0x8(%ebp)
c01006e6:	6a 24                	push   $0x24
c01006e8:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006eb:	50                   	push   %eax
c01006ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006ef:	50                   	push   %eax
c01006f0:	ff 75 f4             	pushl  -0xc(%ebp)
c01006f3:	e8 c4 fd ff ff       	call   c01004bc <stab_binsearch>
c01006f8:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c01006fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100701:	39 c2                	cmp    %eax,%edx
c0100703:	7f 7c                	jg     c0100781 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100705:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100708:	89 c2                	mov    %eax,%edx
c010070a:	89 d0                	mov    %edx,%eax
c010070c:	01 c0                	add    %eax,%eax
c010070e:	01 d0                	add    %edx,%eax
c0100710:	c1 e0 02             	shl    $0x2,%eax
c0100713:	89 c2                	mov    %eax,%edx
c0100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100718:	01 d0                	add    %edx,%eax
c010071a:	8b 00                	mov    (%eax),%eax
c010071c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010071f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100722:	29 d1                	sub    %edx,%ecx
c0100724:	89 ca                	mov    %ecx,%edx
c0100726:	39 d0                	cmp    %edx,%eax
c0100728:	73 22                	jae    c010074c <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010072a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010072d:	89 c2                	mov    %eax,%edx
c010072f:	89 d0                	mov    %edx,%eax
c0100731:	01 c0                	add    %eax,%eax
c0100733:	01 d0                	add    %edx,%eax
c0100735:	c1 e0 02             	shl    $0x2,%eax
c0100738:	89 c2                	mov    %eax,%edx
c010073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073d:	01 d0                	add    %edx,%eax
c010073f:	8b 10                	mov    (%eax),%edx
c0100741:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100744:	01 c2                	add    %eax,%edx
c0100746:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100749:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010074c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074f:	89 c2                	mov    %eax,%edx
c0100751:	89 d0                	mov    %edx,%eax
c0100753:	01 c0                	add    %eax,%eax
c0100755:	01 d0                	add    %edx,%eax
c0100757:	c1 e0 02             	shl    $0x2,%eax
c010075a:	89 c2                	mov    %eax,%edx
c010075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075f:	01 d0                	add    %edx,%eax
c0100761:	8b 50 08             	mov    0x8(%eax),%edx
c0100764:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100767:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010076a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076d:	8b 40 10             	mov    0x10(%eax),%eax
c0100770:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100773:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100779:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010077f:	eb 15                	jmp    c0100796 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100781:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100784:	8b 55 08             	mov    0x8(%ebp),%edx
c0100787:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c010078a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010078d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100790:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100793:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100796:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100799:	8b 40 08             	mov    0x8(%eax),%eax
c010079c:	83 ec 08             	sub    $0x8,%esp
c010079f:	6a 3a                	push   $0x3a
c01007a1:	50                   	push   %eax
c01007a2:	e8 cd 72 00 00       	call   c0107a74 <strfind>
c01007a7:	83 c4 10             	add    $0x10,%esp
c01007aa:	89 c2                	mov    %eax,%edx
c01007ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007af:	8b 40 08             	mov    0x8(%eax),%eax
c01007b2:	29 c2                	sub    %eax,%edx
c01007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b7:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007ba:	83 ec 0c             	sub    $0xc,%esp
c01007bd:	ff 75 08             	pushl  0x8(%ebp)
c01007c0:	6a 44                	push   $0x44
c01007c2:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007c5:	50                   	push   %eax
c01007c6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007c9:	50                   	push   %eax
c01007ca:	ff 75 f4             	pushl  -0xc(%ebp)
c01007cd:	e8 ea fc ff ff       	call   c01004bc <stab_binsearch>
c01007d2:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c01007d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007db:	39 c2                	cmp    %eax,%edx
c01007dd:	7f 24                	jg     c0100803 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c01007df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007e2:	89 c2                	mov    %eax,%edx
c01007e4:	89 d0                	mov    %edx,%eax
c01007e6:	01 c0                	add    %eax,%eax
c01007e8:	01 d0                	add    %edx,%eax
c01007ea:	c1 e0 02             	shl    $0x2,%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f2:	01 d0                	add    %edx,%eax
c01007f4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01007f8:	0f b7 d0             	movzwl %ax,%edx
c01007fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007fe:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100801:	eb 13                	jmp    c0100816 <debuginfo_eip+0x203>
        return -1;
c0100803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100808:	e9 12 01 00 00       	jmp    c010091f <debuginfo_eip+0x30c>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010080d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100810:	83 e8 01             	sub    $0x1,%eax
c0100813:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100816:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010081c:	39 c2                	cmp    %eax,%edx
c010081e:	7c 56                	jl     c0100876 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0100820:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100823:	89 c2                	mov    %eax,%edx
c0100825:	89 d0                	mov    %edx,%eax
c0100827:	01 c0                	add    %eax,%eax
c0100829:	01 d0                	add    %edx,%eax
c010082b:	c1 e0 02             	shl    $0x2,%eax
c010082e:	89 c2                	mov    %eax,%edx
c0100830:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100833:	01 d0                	add    %edx,%eax
c0100835:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100839:	3c 84                	cmp    $0x84,%al
c010083b:	74 39                	je     c0100876 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010083d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100840:	89 c2                	mov    %eax,%edx
c0100842:	89 d0                	mov    %edx,%eax
c0100844:	01 c0                	add    %eax,%eax
c0100846:	01 d0                	add    %edx,%eax
c0100848:	c1 e0 02             	shl    $0x2,%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100850:	01 d0                	add    %edx,%eax
c0100852:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100856:	3c 64                	cmp    $0x64,%al
c0100858:	75 b3                	jne    c010080d <debuginfo_eip+0x1fa>
c010085a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085d:	89 c2                	mov    %eax,%edx
c010085f:	89 d0                	mov    %edx,%eax
c0100861:	01 c0                	add    %eax,%eax
c0100863:	01 d0                	add    %edx,%eax
c0100865:	c1 e0 02             	shl    $0x2,%eax
c0100868:	89 c2                	mov    %eax,%edx
c010086a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086d:	01 d0                	add    %edx,%eax
c010086f:	8b 40 08             	mov    0x8(%eax),%eax
c0100872:	85 c0                	test   %eax,%eax
c0100874:	74 97                	je     c010080d <debuginfo_eip+0x1fa>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100876:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100879:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010087c:	39 c2                	cmp    %eax,%edx
c010087e:	7c 46                	jl     c01008c6 <debuginfo_eip+0x2b3>
c0100880:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	89 d0                	mov    %edx,%eax
c0100887:	01 c0                	add    %eax,%eax
c0100889:	01 d0                	add    %edx,%eax
c010088b:	c1 e0 02             	shl    $0x2,%eax
c010088e:	89 c2                	mov    %eax,%edx
c0100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100893:	01 d0                	add    %edx,%eax
c0100895:	8b 00                	mov    (%eax),%eax
c0100897:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010089a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010089d:	29 d1                	sub    %edx,%ecx
c010089f:	89 ca                	mov    %ecx,%edx
c01008a1:	39 d0                	cmp    %edx,%eax
c01008a3:	73 21                	jae    c01008c6 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008a8:	89 c2                	mov    %eax,%edx
c01008aa:	89 d0                	mov    %edx,%eax
c01008ac:	01 c0                	add    %eax,%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	c1 e0 02             	shl    $0x2,%eax
c01008b3:	89 c2                	mov    %eax,%edx
c01008b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b8:	01 d0                	add    %edx,%eax
c01008ba:	8b 10                	mov    (%eax),%edx
c01008bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008bf:	01 c2                	add    %eax,%edx
c01008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008c4:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008cc:	39 c2                	cmp    %eax,%edx
c01008ce:	7d 4a                	jge    c010091a <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c01008d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008d3:	83 c0 01             	add    $0x1,%eax
c01008d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008d9:	eb 18                	jmp    c01008f3 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008de:	8b 40 14             	mov    0x14(%eax),%eax
c01008e1:	8d 50 01             	lea    0x1(%eax),%edx
c01008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e7:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c01008ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ed:	83 c0 01             	add    $0x1,%eax
c01008f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c01008f9:	39 c2                	cmp    %eax,%edx
c01008fb:	7d 1d                	jge    c010091a <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100900:	89 c2                	mov    %eax,%edx
c0100902:	89 d0                	mov    %edx,%eax
c0100904:	01 c0                	add    %eax,%eax
c0100906:	01 d0                	add    %edx,%eax
c0100908:	c1 e0 02             	shl    $0x2,%eax
c010090b:	89 c2                	mov    %eax,%edx
c010090d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100910:	01 d0                	add    %edx,%eax
c0100912:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100916:	3c a0                	cmp    $0xa0,%al
c0100918:	74 c1                	je     c01008db <debuginfo_eip+0x2c8>
        }
    }
    return 0;
c010091a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010091f:	c9                   	leave  
c0100920:	c3                   	ret    

c0100921 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100921:	55                   	push   %ebp
c0100922:	89 e5                	mov    %esp,%ebp
c0100924:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100927:	83 ec 0c             	sub    $0xc,%esp
c010092a:	68 82 85 10 c0       	push   $0xc0108582
c010092f:	e8 4e f9 ff ff       	call   c0100282 <cprintf>
c0100934:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100937:	83 ec 08             	sub    $0x8,%esp
c010093a:	68 36 00 10 c0       	push   $0xc0100036
c010093f:	68 9b 85 10 c0       	push   $0xc010859b
c0100944:	e8 39 f9 ff ff       	call   c0100282 <cprintf>
c0100949:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c010094c:	83 ec 08             	sub    $0x8,%esp
c010094f:	68 74 84 10 c0       	push   $0xc0108474
c0100954:	68 b3 85 10 c0       	push   $0xc01085b3
c0100959:	e8 24 f9 ff ff       	call   c0100282 <cprintf>
c010095e:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100961:	83 ec 08             	sub    $0x8,%esp
c0100964:	68 00 30 12 c0       	push   $0xc0123000
c0100969:	68 cb 85 10 c0       	push   $0xc01085cb
c010096e:	e8 0f f9 ff ff       	call   c0100282 <cprintf>
c0100973:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0100976:	83 ec 08             	sub    $0x8,%esp
c0100979:	68 fc 40 12 c0       	push   $0xc01240fc
c010097e:	68 e3 85 10 c0       	push   $0xc01085e3
c0100983:	e8 fa f8 ff ff       	call   c0100282 <cprintf>
c0100988:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010098b:	b8 fc 40 12 c0       	mov    $0xc01240fc,%eax
c0100990:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100995:	ba 36 00 10 c0       	mov    $0xc0100036,%edx
c010099a:	29 d0                	sub    %edx,%eax
c010099c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a2:	85 c0                	test   %eax,%eax
c01009a4:	0f 48 c2             	cmovs  %edx,%eax
c01009a7:	c1 f8 0a             	sar    $0xa,%eax
c01009aa:	83 ec 08             	sub    $0x8,%esp
c01009ad:	50                   	push   %eax
c01009ae:	68 fc 85 10 c0       	push   $0xc01085fc
c01009b3:	e8 ca f8 ff ff       	call   c0100282 <cprintf>
c01009b8:	83 c4 10             	add    $0x10,%esp
}
c01009bb:	90                   	nop
c01009bc:	c9                   	leave  
c01009bd:	c3                   	ret    

c01009be <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009be:	55                   	push   %ebp
c01009bf:	89 e5                	mov    %esp,%ebp
c01009c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009c7:	83 ec 08             	sub    $0x8,%esp
c01009ca:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009cd:	50                   	push   %eax
c01009ce:	ff 75 08             	pushl  0x8(%ebp)
c01009d1:	e8 3d fc ff ff       	call   c0100613 <debuginfo_eip>
c01009d6:	83 c4 10             	add    $0x10,%esp
c01009d9:	85 c0                	test   %eax,%eax
c01009db:	74 15                	je     c01009f2 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009dd:	83 ec 08             	sub    $0x8,%esp
c01009e0:	ff 75 08             	pushl  0x8(%ebp)
c01009e3:	68 26 86 10 c0       	push   $0xc0108626
c01009e8:	e8 95 f8 ff ff       	call   c0100282 <cprintf>
c01009ed:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01009f0:	eb 65                	jmp    c0100a57 <print_debuginfo+0x99>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009f9:	eb 1c                	jmp    c0100a17 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01009fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01009fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a01:	01 d0                	add    %edx,%eax
c0100a03:	0f b6 00             	movzbl (%eax),%eax
c0100a06:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a0f:	01 ca                	add    %ecx,%edx
c0100a11:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a1d:	7c dc                	jl     c01009fb <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a1f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a28:	01 d0                	add    %edx,%eax
c0100a2a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a30:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a33:	89 d1                	mov    %edx,%ecx
c0100a35:	29 c1                	sub    %eax,%ecx
c0100a37:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a3d:	83 ec 0c             	sub    $0xc,%esp
c0100a40:	51                   	push   %ecx
c0100a41:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a47:	51                   	push   %ecx
c0100a48:	52                   	push   %edx
c0100a49:	50                   	push   %eax
c0100a4a:	68 42 86 10 c0       	push   $0xc0108642
c0100a4f:	e8 2e f8 ff ff       	call   c0100282 <cprintf>
c0100a54:	83 c4 20             	add    $0x20,%esp
}
c0100a57:	90                   	nop
c0100a58:	c9                   	leave  
c0100a59:	c3                   	ret    

c0100a5a <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a5a:	55                   	push   %ebp
c0100a5b:	89 e5                	mov    %esp,%ebp
c0100a5d:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a60:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a63:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a69:	c9                   	leave  
c0100a6a:	c3                   	ret    

c0100a6b <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a6b:	55                   	push   %ebp
c0100a6c:	89 e5                	mov    %esp,%ebp
c0100a6e:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a71:	89 e8                	mov    %ebp,%eax
c0100a73:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a7c:	e8 d9 ff ff ff       	call   c0100a5a <read_eip>
c0100a81:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a84:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a8b:	e9 8d 00 00 00       	jmp    c0100b1d <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100a90:	83 ec 04             	sub    $0x4,%esp
c0100a93:	ff 75 f0             	pushl  -0x10(%ebp)
c0100a96:	ff 75 f4             	pushl  -0xc(%ebp)
c0100a99:	68 54 86 10 c0       	push   $0xc0108654
c0100a9e:	e8 df f7 ff ff       	call   c0100282 <cprintf>
c0100aa3:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0100aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa9:	83 c0 08             	add    $0x8,%eax
c0100aac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100aaf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ab6:	eb 26                	jmp    c0100ade <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
c0100ab8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100abb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ac5:	01 d0                	add    %edx,%eax
c0100ac7:	8b 00                	mov    (%eax),%eax
c0100ac9:	83 ec 08             	sub    $0x8,%esp
c0100acc:	50                   	push   %eax
c0100acd:	68 70 86 10 c0       	push   $0xc0108670
c0100ad2:	e8 ab f7 ff ff       	call   c0100282 <cprintf>
c0100ad7:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j ++) {
c0100ada:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100ade:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100ae2:	7e d4                	jle    c0100ab8 <print_stackframe+0x4d>
        }
        cprintf("\n");
c0100ae4:	83 ec 0c             	sub    $0xc,%esp
c0100ae7:	68 78 86 10 c0       	push   $0xc0108678
c0100aec:	e8 91 f7 ff ff       	call   c0100282 <cprintf>
c0100af1:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0100af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100af7:	83 e8 01             	sub    $0x1,%eax
c0100afa:	83 ec 0c             	sub    $0xc,%esp
c0100afd:	50                   	push   %eax
c0100afe:	e8 bb fe ff ff       	call   c01009be <print_debuginfo>
c0100b03:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0100b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b09:	83 c0 04             	add    $0x4,%eax
c0100b0c:	8b 00                	mov    (%eax),%eax
c0100b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b14:	8b 00                	mov    (%eax),%eax
c0100b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b19:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b21:	74 0a                	je     c0100b2d <print_stackframe+0xc2>
c0100b23:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b27:	0f 8e 63 ff ff ff    	jle    c0100a90 <print_stackframe+0x25>
    }
}
c0100b2d:	90                   	nop
c0100b2e:	c9                   	leave  
c0100b2f:	c3                   	ret    

c0100b30 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b30:	55                   	push   %ebp
c0100b31:	89 e5                	mov    %esp,%ebp
c0100b33:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0100b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b3d:	eb 0c                	jmp    c0100b4b <parse+0x1b>
            *buf ++ = '\0';
c0100b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b42:	8d 50 01             	lea    0x1(%eax),%edx
c0100b45:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b48:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4e:	0f b6 00             	movzbl (%eax),%eax
c0100b51:	84 c0                	test   %al,%al
c0100b53:	74 1e                	je     c0100b73 <parse+0x43>
c0100b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b58:	0f b6 00             	movzbl (%eax),%eax
c0100b5b:	0f be c0             	movsbl %al,%eax
c0100b5e:	83 ec 08             	sub    $0x8,%esp
c0100b61:	50                   	push   %eax
c0100b62:	68 fc 86 10 c0       	push   $0xc01086fc
c0100b67:	e8 d5 6e 00 00       	call   c0107a41 <strchr>
c0100b6c:	83 c4 10             	add    $0x10,%esp
c0100b6f:	85 c0                	test   %eax,%eax
c0100b71:	75 cc                	jne    c0100b3f <parse+0xf>
        }
        if (*buf == '\0') {
c0100b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b76:	0f b6 00             	movzbl (%eax),%eax
c0100b79:	84 c0                	test   %al,%al
c0100b7b:	74 65                	je     c0100be2 <parse+0xb2>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b7d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b81:	75 12                	jne    c0100b95 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b83:	83 ec 08             	sub    $0x8,%esp
c0100b86:	6a 10                	push   $0x10
c0100b88:	68 01 87 10 c0       	push   $0xc0108701
c0100b8d:	e8 f0 f6 ff ff       	call   c0100282 <cprintf>
c0100b92:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b98:	8d 50 01             	lea    0x1(%eax),%edx
c0100b9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ba8:	01 c2                	add    %eax,%edx
c0100baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bad:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100baf:	eb 04                	jmp    c0100bb5 <parse+0x85>
            buf ++;
c0100bb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb8:	0f b6 00             	movzbl (%eax),%eax
c0100bbb:	84 c0                	test   %al,%al
c0100bbd:	74 8c                	je     c0100b4b <parse+0x1b>
c0100bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc2:	0f b6 00             	movzbl (%eax),%eax
c0100bc5:	0f be c0             	movsbl %al,%eax
c0100bc8:	83 ec 08             	sub    $0x8,%esp
c0100bcb:	50                   	push   %eax
c0100bcc:	68 fc 86 10 c0       	push   $0xc01086fc
c0100bd1:	e8 6b 6e 00 00       	call   c0107a41 <strchr>
c0100bd6:	83 c4 10             	add    $0x10,%esp
c0100bd9:	85 c0                	test   %eax,%eax
c0100bdb:	74 d4                	je     c0100bb1 <parse+0x81>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bdd:	e9 69 ff ff ff       	jmp    c0100b4b <parse+0x1b>
            break;
c0100be2:	90                   	nop
        }
    }
    return argc;
c0100be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100be6:	c9                   	leave  
c0100be7:	c3                   	ret    

c0100be8 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100be8:	55                   	push   %ebp
c0100be9:	89 e5                	mov    %esp,%ebp
c0100beb:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100bee:	83 ec 08             	sub    $0x8,%esp
c0100bf1:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bf4:	50                   	push   %eax
c0100bf5:	ff 75 08             	pushl  0x8(%ebp)
c0100bf8:	e8 33 ff ff ff       	call   c0100b30 <parse>
c0100bfd:	83 c4 10             	add    $0x10,%esp
c0100c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c07:	75 0a                	jne    c0100c13 <runcmd+0x2b>
        return 0;
c0100c09:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c0e:	e9 83 00 00 00       	jmp    c0100c96 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c1a:	eb 59                	jmp    c0100c75 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c1c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c22:	89 d0                	mov    %edx,%eax
c0100c24:	01 c0                	add    %eax,%eax
c0100c26:	01 d0                	add    %edx,%eax
c0100c28:	c1 e0 02             	shl    $0x2,%eax
c0100c2b:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c30:	8b 00                	mov    (%eax),%eax
c0100c32:	83 ec 08             	sub    $0x8,%esp
c0100c35:	51                   	push   %ecx
c0100c36:	50                   	push   %eax
c0100c37:	e8 65 6d 00 00       	call   c01079a1 <strcmp>
c0100c3c:	83 c4 10             	add    $0x10,%esp
c0100c3f:	85 c0                	test   %eax,%eax
c0100c41:	75 2e                	jne    c0100c71 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c43:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c46:	89 d0                	mov    %edx,%eax
c0100c48:	01 c0                	add    %eax,%eax
c0100c4a:	01 d0                	add    %edx,%eax
c0100c4c:	c1 e0 02             	shl    $0x2,%eax
c0100c4f:	05 08 00 12 c0       	add    $0xc0120008,%eax
c0100c54:	8b 10                	mov    (%eax),%edx
c0100c56:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c59:	83 c0 04             	add    $0x4,%eax
c0100c5c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c5f:	83 e9 01             	sub    $0x1,%ecx
c0100c62:	83 ec 04             	sub    $0x4,%esp
c0100c65:	ff 75 0c             	pushl  0xc(%ebp)
c0100c68:	50                   	push   %eax
c0100c69:	51                   	push   %ecx
c0100c6a:	ff d2                	call   *%edx
c0100c6c:	83 c4 10             	add    $0x10,%esp
c0100c6f:	eb 25                	jmp    c0100c96 <runcmd+0xae>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c71:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c78:	83 f8 02             	cmp    $0x2,%eax
c0100c7b:	76 9f                	jbe    c0100c1c <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c7d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c80:	83 ec 08             	sub    $0x8,%esp
c0100c83:	50                   	push   %eax
c0100c84:	68 1f 87 10 c0       	push   $0xc010871f
c0100c89:	e8 f4 f5 ff ff       	call   c0100282 <cprintf>
c0100c8e:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100c91:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c96:	c9                   	leave  
c0100c97:	c3                   	ret    

c0100c98 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c98:	55                   	push   %ebp
c0100c99:	89 e5                	mov    %esp,%ebp
c0100c9b:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c9e:	83 ec 0c             	sub    $0xc,%esp
c0100ca1:	68 38 87 10 c0       	push   $0xc0108738
c0100ca6:	e8 d7 f5 ff ff       	call   c0100282 <cprintf>
c0100cab:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100cae:	83 ec 0c             	sub    $0xc,%esp
c0100cb1:	68 60 87 10 c0       	push   $0xc0108760
c0100cb6:	e8 c7 f5 ff ff       	call   c0100282 <cprintf>
c0100cbb:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0100cbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cc2:	74 0e                	je     c0100cd2 <kmonitor+0x3a>
        print_trapframe(tf);
c0100cc4:	83 ec 0c             	sub    $0xc,%esp
c0100cc7:	ff 75 08             	pushl  0x8(%ebp)
c0100cca:	e8 d1 14 00 00       	call   c01021a0 <print_trapframe>
c0100ccf:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cd2:	83 ec 0c             	sub    $0xc,%esp
c0100cd5:	68 85 87 10 c0       	push   $0xc0108785
c0100cda:	e8 47 f6 ff ff       	call   c0100326 <readline>
c0100cdf:	83 c4 10             	add    $0x10,%esp
c0100ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ce5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ce9:	74 e7                	je     c0100cd2 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c0100ceb:	83 ec 08             	sub    $0x8,%esp
c0100cee:	ff 75 08             	pushl  0x8(%ebp)
c0100cf1:	ff 75 f4             	pushl  -0xc(%ebp)
c0100cf4:	e8 ef fe ff ff       	call   c0100be8 <runcmd>
c0100cf9:	83 c4 10             	add    $0x10,%esp
c0100cfc:	85 c0                	test   %eax,%eax
c0100cfe:	78 02                	js     c0100d02 <kmonitor+0x6a>
        if ((buf = readline("K> ")) != NULL) {
c0100d00:	eb d0                	jmp    c0100cd2 <kmonitor+0x3a>
                break;
c0100d02:	90                   	nop
            }
        }
    }
}
c0100d03:	90                   	nop
c0100d04:	c9                   	leave  
c0100d05:	c3                   	ret    

c0100d06 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d06:	55                   	push   %ebp
c0100d07:	89 e5                	mov    %esp,%ebp
c0100d09:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d13:	eb 3c                	jmp    c0100d51 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d18:	89 d0                	mov    %edx,%eax
c0100d1a:	01 c0                	add    %eax,%eax
c0100d1c:	01 d0                	add    %edx,%eax
c0100d1e:	c1 e0 02             	shl    $0x2,%eax
c0100d21:	05 04 00 12 c0       	add    $0xc0120004,%eax
c0100d26:	8b 08                	mov    (%eax),%ecx
c0100d28:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d2b:	89 d0                	mov    %edx,%eax
c0100d2d:	01 c0                	add    %eax,%eax
c0100d2f:	01 d0                	add    %edx,%eax
c0100d31:	c1 e0 02             	shl    $0x2,%eax
c0100d34:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100d39:	8b 00                	mov    (%eax),%eax
c0100d3b:	83 ec 04             	sub    $0x4,%esp
c0100d3e:	51                   	push   %ecx
c0100d3f:	50                   	push   %eax
c0100d40:	68 89 87 10 c0       	push   $0xc0108789
c0100d45:	e8 38 f5 ff ff       	call   c0100282 <cprintf>
c0100d4a:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d4d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d54:	83 f8 02             	cmp    $0x2,%eax
c0100d57:	76 bc                	jbe    c0100d15 <mon_help+0xf>
    }
    return 0;
c0100d59:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d5e:	c9                   	leave  
c0100d5f:	c3                   	ret    

c0100d60 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d60:	55                   	push   %ebp
c0100d61:	89 e5                	mov    %esp,%ebp
c0100d63:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d66:	e8 b6 fb ff ff       	call   c0100921 <print_kerninfo>
    return 0;
c0100d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d70:	c9                   	leave  
c0100d71:	c3                   	ret    

c0100d72 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d72:	55                   	push   %ebp
c0100d73:	89 e5                	mov    %esp,%ebp
c0100d75:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d78:	e8 ee fc ff ff       	call   c0100a6b <print_stackframe>
    return 0;
c0100d7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d82:	c9                   	leave  
c0100d83:	c3                   	ret    

c0100d84 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100d84:	55                   	push   %ebp
c0100d85:	89 e5                	mov    %esp,%ebp
c0100d87:	83 ec 14             	sub    $0x14,%esp
c0100d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d8d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100d91:	90                   	nop
c0100d92:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100d96:	83 c0 07             	add    $0x7,%eax
c0100d99:	0f b7 c0             	movzwl %ax,%eax
c0100d9c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100da0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100da4:	89 c2                	mov    %eax,%edx
c0100da6:	ec                   	in     (%dx),%al
c0100da7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100daa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dae:	0f b6 c0             	movzbl %al,%eax
c0100db1:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100db4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100db7:	25 80 00 00 00       	and    $0x80,%eax
c0100dbc:	85 c0                	test   %eax,%eax
c0100dbe:	75 d2                	jne    c0100d92 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100dc0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100dc4:	74 11                	je     c0100dd7 <ide_wait_ready+0x53>
c0100dc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dc9:	83 e0 21             	and    $0x21,%eax
c0100dcc:	85 c0                	test   %eax,%eax
c0100dce:	74 07                	je     c0100dd7 <ide_wait_ready+0x53>
        return -1;
c0100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100dd5:	eb 05                	jmp    c0100ddc <ide_wait_ready+0x58>
    }
    return 0;
c0100dd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ddc:	c9                   	leave  
c0100ddd:	c3                   	ret    

c0100dde <ide_init>:

void
ide_init(void) {
c0100dde:	55                   	push   %ebp
c0100ddf:	89 e5                	mov    %esp,%ebp
c0100de1:	57                   	push   %edi
c0100de2:	53                   	push   %ebx
c0100de3:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100de9:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100def:	e9 68 02 00 00       	jmp    c010105c <ide_init+0x27e>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100df4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100df8:	6b c0 38             	imul   $0x38,%eax,%eax
c0100dfb:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0100e00:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e03:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e07:	66 d1 e8             	shr    %ax
c0100e0a:	0f b7 c0             	movzwl %ax,%eax
c0100e0d:	0f b7 04 85 94 87 10 	movzwl -0x3fef786c(,%eax,4),%eax
c0100e14:	c0 
c0100e15:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e19:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e1d:	6a 00                	push   $0x0
c0100e1f:	50                   	push   %eax
c0100e20:	e8 5f ff ff ff       	call   c0100d84 <ide_wait_ready>
c0100e25:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e28:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e2c:	c1 e0 04             	shl    $0x4,%eax
c0100e2f:	83 e0 10             	and    $0x10,%eax
c0100e32:	83 c8 e0             	or     $0xffffffe0,%eax
c0100e35:	0f b6 c0             	movzbl %al,%eax
c0100e38:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e3c:	83 c2 06             	add    $0x6,%edx
c0100e3f:	0f b7 d2             	movzwl %dx,%edx
c0100e42:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100e46:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e49:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100e4d:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100e51:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e52:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e56:	6a 00                	push   $0x0
c0100e58:	50                   	push   %eax
c0100e59:	e8 26 ff ff ff       	call   c0100d84 <ide_wait_ready>
c0100e5e:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e61:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e65:	83 c0 07             	add    $0x7,%eax
c0100e68:	0f b7 c0             	movzwl %ax,%eax
c0100e6b:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100e6f:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100e73:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100e77:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100e7b:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e7c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e80:	6a 00                	push   $0x0
c0100e82:	50                   	push   %eax
c0100e83:	e8 fc fe ff ff       	call   c0100d84 <ide_wait_ready>
c0100e88:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100e8b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e8f:	83 c0 07             	add    $0x7,%eax
c0100e92:	0f b7 c0             	movzwl %ax,%eax
c0100e95:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e99:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100e9d:	89 c2                	mov    %eax,%edx
c0100e9f:	ec                   	in     (%dx),%al
c0100ea0:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0100ea3:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100ea7:	84 c0                	test   %al,%al
c0100ea9:	0f 84 a1 01 00 00    	je     c0101050 <ide_init+0x272>
c0100eaf:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eb3:	6a 01                	push   $0x1
c0100eb5:	50                   	push   %eax
c0100eb6:	e8 c9 fe ff ff       	call   c0100d84 <ide_wait_ready>
c0100ebb:	83 c4 08             	add    $0x8,%esp
c0100ebe:	85 c0                	test   %eax,%eax
c0100ec0:	0f 85 8a 01 00 00    	jne    c0101050 <ide_init+0x272>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ec6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100eca:	6b c0 38             	imul   $0x38,%eax,%eax
c0100ecd:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0100ed2:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100ed5:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ed9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100edc:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100ee2:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100ee5:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100eec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100eef:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100ef2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100ef5:	89 cb                	mov    %ecx,%ebx
c0100ef7:	89 df                	mov    %ebx,%edi
c0100ef9:	89 c1                	mov    %eax,%ecx
c0100efb:	fc                   	cld    
c0100efc:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100efe:	89 c8                	mov    %ecx,%eax
c0100f00:	89 fb                	mov    %edi,%ebx
c0100f02:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f05:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f08:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f14:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f20:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f25:	85 c0                	test   %eax,%eax
c0100f27:	74 0e                	je     c0100f37 <ide_init+0x159>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f2c:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f35:	eb 09                	jmp    c0100f40 <ide_init+0x162>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f3a:	8b 40 78             	mov    0x78(%eax),%eax
c0100f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f40:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f44:	6b c0 38             	imul   $0x38,%eax,%eax
c0100f47:	8d 90 44 34 12 c0    	lea    -0x3fedcbbc(%eax),%edx
c0100f4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f50:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f52:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f56:	6b c0 38             	imul   $0x38,%eax,%eax
c0100f59:	8d 90 48 34 12 c0    	lea    -0x3fedcbb8(%eax),%edx
c0100f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100f62:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100f64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f67:	83 c0 62             	add    $0x62,%eax
c0100f6a:	0f b7 00             	movzwl (%eax),%eax
c0100f6d:	0f b7 c0             	movzwl %ax,%eax
c0100f70:	25 00 02 00 00       	and    $0x200,%eax
c0100f75:	85 c0                	test   %eax,%eax
c0100f77:	75 16                	jne    c0100f8f <ide_init+0x1b1>
c0100f79:	68 9c 87 10 c0       	push   $0xc010879c
c0100f7e:	68 df 87 10 c0       	push   $0xc01087df
c0100f83:	6a 7d                	push   $0x7d
c0100f85:	68 f4 87 10 c0       	push   $0xc01087f4
c0100f8a:	e8 59 f4 ff ff       	call   c01003e8 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100f8f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f93:	6b c0 38             	imul   $0x38,%eax,%eax
c0100f96:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0100f9b:	83 c0 0c             	add    $0xc,%eax
c0100f9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100fa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fa4:	83 c0 36             	add    $0x36,%eax
c0100fa7:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0100faa:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0100fb1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100fb8:	eb 34                	jmp    c0100fee <ide_init+0x210>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0100fba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fbd:	8d 50 01             	lea    0x1(%eax),%edx
c0100fc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100fc3:	01 d0                	add    %edx,%eax
c0100fc5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0100fc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100fcb:	01 ca                	add    %ecx,%edx
c0100fcd:	0f b6 00             	movzbl (%eax),%eax
c0100fd0:	88 02                	mov    %al,(%edx)
c0100fd2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0100fd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fd8:	01 d0                	add    %edx,%eax
c0100fda:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100fdd:	8d 4a 01             	lea    0x1(%edx),%ecx
c0100fe0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100fe3:	01 ca                	add    %ecx,%edx
c0100fe5:	0f b6 00             	movzbl (%eax),%eax
c0100fe8:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0100fea:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0100fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100ff1:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0100ff4:	72 c4                	jb     c0100fba <ide_init+0x1dc>
        }
        do {
            model[i] = '\0';
c0100ff6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100ffc:	01 d0                	add    %edx,%eax
c0100ffe:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101001:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101004:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101007:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010100a:	85 c0                	test   %eax,%eax
c010100c:	74 0f                	je     c010101d <ide_init+0x23f>
c010100e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101011:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101014:	01 d0                	add    %edx,%eax
c0101016:	0f b6 00             	movzbl (%eax),%eax
c0101019:	3c 20                	cmp    $0x20,%al
c010101b:	74 d9                	je     c0100ff6 <ide_init+0x218>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010101d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101021:	6b c0 38             	imul   $0x38,%eax,%eax
c0101024:	05 40 34 12 c0       	add    $0xc0123440,%eax
c0101029:	8d 48 0c             	lea    0xc(%eax),%ecx
c010102c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101030:	6b c0 38             	imul   $0x38,%eax,%eax
c0101033:	05 48 34 12 c0       	add    $0xc0123448,%eax
c0101038:	8b 10                	mov    (%eax),%edx
c010103a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010103e:	51                   	push   %ecx
c010103f:	52                   	push   %edx
c0101040:	50                   	push   %eax
c0101041:	68 06 88 10 c0       	push   $0xc0108806
c0101046:	e8 37 f2 ff ff       	call   c0100282 <cprintf>
c010104b:	83 c4 10             	add    $0x10,%esp
c010104e:	eb 01                	jmp    c0101051 <ide_init+0x273>
            continue ;
c0101050:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101051:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101055:	83 c0 01             	add    $0x1,%eax
c0101058:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c010105c:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101061:	0f 86 8d fd ff ff    	jbe    c0100df4 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101067:	83 ec 0c             	sub    $0xc,%esp
c010106a:	6a 0e                	push   $0xe
c010106c:	e8 62 0e 00 00       	call   c0101ed3 <pic_enable>
c0101071:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c0101074:	83 ec 0c             	sub    $0xc,%esp
c0101077:	6a 0f                	push   $0xf
c0101079:	e8 55 0e 00 00       	call   c0101ed3 <pic_enable>
c010107e:	83 c4 10             	add    $0x10,%esp
}
c0101081:	90                   	nop
c0101082:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101085:	5b                   	pop    %ebx
c0101086:	5f                   	pop    %edi
c0101087:	5d                   	pop    %ebp
c0101088:	c3                   	ret    

c0101089 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101089:	55                   	push   %ebp
c010108a:	89 e5                	mov    %esp,%ebp
c010108c:	83 ec 04             	sub    $0x4,%esp
c010108f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101092:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101096:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c010109b:	77 1a                	ja     c01010b7 <ide_device_valid+0x2e>
c010109d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01010a1:	6b c0 38             	imul   $0x38,%eax,%eax
c01010a4:	05 40 34 12 c0       	add    $0xc0123440,%eax
c01010a9:	0f b6 00             	movzbl (%eax),%eax
c01010ac:	84 c0                	test   %al,%al
c01010ae:	74 07                	je     c01010b7 <ide_device_valid+0x2e>
c01010b0:	b8 01 00 00 00       	mov    $0x1,%eax
c01010b5:	eb 05                	jmp    c01010bc <ide_device_valid+0x33>
c01010b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01010bc:	c9                   	leave  
c01010bd:	c3                   	ret    

c01010be <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c01010be:	55                   	push   %ebp
c01010bf:	89 e5                	mov    %esp,%ebp
c01010c1:	83 ec 04             	sub    $0x4,%esp
c01010c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c01010cb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01010cf:	50                   	push   %eax
c01010d0:	e8 b4 ff ff ff       	call   c0101089 <ide_device_valid>
c01010d5:	83 c4 04             	add    $0x4,%esp
c01010d8:	85 c0                	test   %eax,%eax
c01010da:	74 10                	je     c01010ec <ide_device_size+0x2e>
        return ide_devices[ideno].size;
c01010dc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01010e0:	6b c0 38             	imul   $0x38,%eax,%eax
c01010e3:	05 48 34 12 c0       	add    $0xc0123448,%eax
c01010e8:	8b 00                	mov    (%eax),%eax
c01010ea:	eb 05                	jmp    c01010f1 <ide_device_size+0x33>
    }
    return 0;
c01010ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01010f1:	c9                   	leave  
c01010f2:	c3                   	ret    

c01010f3 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01010f3:	55                   	push   %ebp
c01010f4:	89 e5                	mov    %esp,%ebp
c01010f6:	57                   	push   %edi
c01010f7:	53                   	push   %ebx
c01010f8:	83 ec 40             	sub    $0x40,%esp
c01010fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01010fe:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101102:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101109:	77 1a                	ja     c0101125 <ide_read_secs+0x32>
c010110b:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101110:	77 13                	ja     c0101125 <ide_read_secs+0x32>
c0101112:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101116:	6b c0 38             	imul   $0x38,%eax,%eax
c0101119:	05 40 34 12 c0       	add    $0xc0123440,%eax
c010111e:	0f b6 00             	movzbl (%eax),%eax
c0101121:	84 c0                	test   %al,%al
c0101123:	75 19                	jne    c010113e <ide_read_secs+0x4b>
c0101125:	68 24 88 10 c0       	push   $0xc0108824
c010112a:	68 df 87 10 c0       	push   $0xc01087df
c010112f:	68 9f 00 00 00       	push   $0x9f
c0101134:	68 f4 87 10 c0       	push   $0xc01087f4
c0101139:	e8 aa f2 ff ff       	call   c01003e8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010113e:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101145:	77 0f                	ja     c0101156 <ide_read_secs+0x63>
c0101147:	8b 55 0c             	mov    0xc(%ebp),%edx
c010114a:	8b 45 14             	mov    0x14(%ebp),%eax
c010114d:	01 d0                	add    %edx,%eax
c010114f:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101154:	76 19                	jbe    c010116f <ide_read_secs+0x7c>
c0101156:	68 4c 88 10 c0       	push   $0xc010884c
c010115b:	68 df 87 10 c0       	push   $0xc01087df
c0101160:	68 a0 00 00 00       	push   $0xa0
c0101165:	68 f4 87 10 c0       	push   $0xc01087f4
c010116a:	e8 79 f2 ff ff       	call   c01003e8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010116f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101173:	66 d1 e8             	shr    %ax
c0101176:	0f b7 c0             	movzwl %ax,%eax
c0101179:	0f b7 04 85 94 87 10 	movzwl -0x3fef786c(,%eax,4),%eax
c0101180:	c0 
c0101181:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101185:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101189:	66 d1 e8             	shr    %ax
c010118c:	0f b7 c0             	movzwl %ax,%eax
c010118f:	0f b7 04 85 96 87 10 	movzwl -0x3fef786a(,%eax,4),%eax
c0101196:	c0 
c0101197:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010119b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010119f:	83 ec 08             	sub    $0x8,%esp
c01011a2:	6a 00                	push   $0x0
c01011a4:	50                   	push   %eax
c01011a5:	e8 da fb ff ff       	call   c0100d84 <ide_wait_ready>
c01011aa:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01011ad:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01011b1:	83 c0 02             	add    $0x2,%eax
c01011b4:	0f b7 c0             	movzwl %ax,%eax
c01011b7:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01011bb:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011bf:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01011c3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01011c7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01011c8:	8b 45 14             	mov    0x14(%ebp),%eax
c01011cb:	0f b6 c0             	movzbl %al,%eax
c01011ce:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011d2:	83 c2 02             	add    $0x2,%edx
c01011d5:	0f b7 d2             	movzwl %dx,%edx
c01011d8:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01011dc:	88 45 d9             	mov    %al,-0x27(%ebp)
c01011df:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01011e3:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01011e7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01011e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011eb:	0f b6 c0             	movzbl %al,%eax
c01011ee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011f2:	83 c2 03             	add    $0x3,%edx
c01011f5:	0f b7 d2             	movzwl %dx,%edx
c01011f8:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01011fc:	88 45 dd             	mov    %al,-0x23(%ebp)
c01011ff:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101203:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101207:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101208:	8b 45 0c             	mov    0xc(%ebp),%eax
c010120b:	c1 e8 08             	shr    $0x8,%eax
c010120e:	0f b6 c0             	movzbl %al,%eax
c0101211:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101215:	83 c2 04             	add    $0x4,%edx
c0101218:	0f b7 d2             	movzwl %dx,%edx
c010121b:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010121f:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101222:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101226:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010122a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010122b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010122e:	c1 e8 10             	shr    $0x10,%eax
c0101231:	0f b6 c0             	movzbl %al,%eax
c0101234:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101238:	83 c2 05             	add    $0x5,%edx
c010123b:	0f b7 d2             	movzwl %dx,%edx
c010123e:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101242:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101245:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101249:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010124d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010124e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101252:	c1 e0 04             	shl    $0x4,%eax
c0101255:	83 e0 10             	and    $0x10,%eax
c0101258:	89 c2                	mov    %eax,%edx
c010125a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010125d:	c1 e8 18             	shr    $0x18,%eax
c0101260:	83 e0 0f             	and    $0xf,%eax
c0101263:	09 d0                	or     %edx,%eax
c0101265:	83 c8 e0             	or     $0xffffffe0,%eax
c0101268:	0f b6 c0             	movzbl %al,%eax
c010126b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010126f:	83 c2 06             	add    $0x6,%edx
c0101272:	0f b7 d2             	movzwl %dx,%edx
c0101275:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101279:	88 45 e9             	mov    %al,-0x17(%ebp)
c010127c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101280:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101284:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101285:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101289:	83 c0 07             	add    $0x7,%eax
c010128c:	0f b7 c0             	movzwl %ax,%eax
c010128f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101293:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
c0101297:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010129b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010129f:	ee                   	out    %al,(%dx)

    int ret = 0;
c01012a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01012a7:	eb 56                	jmp    c01012ff <ide_read_secs+0x20c>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01012a9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01012ad:	83 ec 08             	sub    $0x8,%esp
c01012b0:	6a 01                	push   $0x1
c01012b2:	50                   	push   %eax
c01012b3:	e8 cc fa ff ff       	call   c0100d84 <ide_wait_ready>
c01012b8:	83 c4 10             	add    $0x10,%esp
c01012bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01012be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01012c2:	75 43                	jne    c0101307 <ide_read_secs+0x214>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01012c4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01012c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01012cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01012ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01012d1:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01012d8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01012db:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01012de:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01012e1:	89 cb                	mov    %ecx,%ebx
c01012e3:	89 df                	mov    %ebx,%edi
c01012e5:	89 c1                	mov    %eax,%ecx
c01012e7:	fc                   	cld    
c01012e8:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01012ea:	89 c8                	mov    %ecx,%eax
c01012ec:	89 fb                	mov    %edi,%ebx
c01012ee:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01012f1:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01012f4:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01012f8:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01012ff:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101303:	75 a4                	jne    c01012a9 <ide_read_secs+0x1b6>
    }

out:
c0101305:	eb 01                	jmp    c0101308 <ide_read_secs+0x215>
            goto out;
c0101307:	90                   	nop
    return ret;
c0101308:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010130b:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010130e:	5b                   	pop    %ebx
c010130f:	5f                   	pop    %edi
c0101310:	5d                   	pop    %ebp
c0101311:	c3                   	ret    

c0101312 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101312:	55                   	push   %ebp
c0101313:	89 e5                	mov    %esp,%ebp
c0101315:	56                   	push   %esi
c0101316:	53                   	push   %ebx
c0101317:	83 ec 40             	sub    $0x40,%esp
c010131a:	8b 45 08             	mov    0x8(%ebp),%eax
c010131d:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101321:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101328:	77 1a                	ja     c0101344 <ide_write_secs+0x32>
c010132a:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c010132f:	77 13                	ja     c0101344 <ide_write_secs+0x32>
c0101331:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101335:	6b c0 38             	imul   $0x38,%eax,%eax
c0101338:	05 40 34 12 c0       	add    $0xc0123440,%eax
c010133d:	0f b6 00             	movzbl (%eax),%eax
c0101340:	84 c0                	test   %al,%al
c0101342:	75 19                	jne    c010135d <ide_write_secs+0x4b>
c0101344:	68 24 88 10 c0       	push   $0xc0108824
c0101349:	68 df 87 10 c0       	push   $0xc01087df
c010134e:	68 bc 00 00 00       	push   $0xbc
c0101353:	68 f4 87 10 c0       	push   $0xc01087f4
c0101358:	e8 8b f0 ff ff       	call   c01003e8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010135d:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101364:	77 0f                	ja     c0101375 <ide_write_secs+0x63>
c0101366:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101369:	8b 45 14             	mov    0x14(%ebp),%eax
c010136c:	01 d0                	add    %edx,%eax
c010136e:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101373:	76 19                	jbe    c010138e <ide_write_secs+0x7c>
c0101375:	68 4c 88 10 c0       	push   $0xc010884c
c010137a:	68 df 87 10 c0       	push   $0xc01087df
c010137f:	68 bd 00 00 00       	push   $0xbd
c0101384:	68 f4 87 10 c0       	push   $0xc01087f4
c0101389:	e8 5a f0 ff ff       	call   c01003e8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010138e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101392:	66 d1 e8             	shr    %ax
c0101395:	0f b7 c0             	movzwl %ax,%eax
c0101398:	0f b7 04 85 94 87 10 	movzwl -0x3fef786c(,%eax,4),%eax
c010139f:	c0 
c01013a0:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01013a4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013a8:	66 d1 e8             	shr    %ax
c01013ab:	0f b7 c0             	movzwl %ax,%eax
c01013ae:	0f b7 04 85 96 87 10 	movzwl -0x3fef786a(,%eax,4),%eax
c01013b5:	c0 
c01013b6:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01013ba:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013be:	83 ec 08             	sub    $0x8,%esp
c01013c1:	6a 00                	push   $0x0
c01013c3:	50                   	push   %eax
c01013c4:	e8 bb f9 ff ff       	call   c0100d84 <ide_wait_ready>
c01013c9:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01013cc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01013d0:	83 c0 02             	add    $0x2,%eax
c01013d3:	0f b7 c0             	movzwl %ax,%eax
c01013d6:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01013da:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013de:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01013e2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01013e6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01013e7:	8b 45 14             	mov    0x14(%ebp),%eax
c01013ea:	0f b6 c0             	movzbl %al,%eax
c01013ed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013f1:	83 c2 02             	add    $0x2,%edx
c01013f4:	0f b7 d2             	movzwl %dx,%edx
c01013f7:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01013fb:	88 45 d9             	mov    %al,-0x27(%ebp)
c01013fe:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101402:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101406:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010140a:	0f b6 c0             	movzbl %al,%eax
c010140d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101411:	83 c2 03             	add    $0x3,%edx
c0101414:	0f b7 d2             	movzwl %dx,%edx
c0101417:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010141b:	88 45 dd             	mov    %al,-0x23(%ebp)
c010141e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101422:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101426:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101427:	8b 45 0c             	mov    0xc(%ebp),%eax
c010142a:	c1 e8 08             	shr    $0x8,%eax
c010142d:	0f b6 c0             	movzbl %al,%eax
c0101430:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101434:	83 c2 04             	add    $0x4,%edx
c0101437:	0f b7 d2             	movzwl %dx,%edx
c010143a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010143e:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101441:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101445:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101449:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010144a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010144d:	c1 e8 10             	shr    $0x10,%eax
c0101450:	0f b6 c0             	movzbl %al,%eax
c0101453:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101457:	83 c2 05             	add    $0x5,%edx
c010145a:	0f b7 d2             	movzwl %dx,%edx
c010145d:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101461:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101464:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101468:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010146c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010146d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101471:	c1 e0 04             	shl    $0x4,%eax
c0101474:	83 e0 10             	and    $0x10,%eax
c0101477:	89 c2                	mov    %eax,%edx
c0101479:	8b 45 0c             	mov    0xc(%ebp),%eax
c010147c:	c1 e8 18             	shr    $0x18,%eax
c010147f:	83 e0 0f             	and    $0xf,%eax
c0101482:	09 d0                	or     %edx,%eax
c0101484:	83 c8 e0             	or     $0xffffffe0,%eax
c0101487:	0f b6 c0             	movzbl %al,%eax
c010148a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010148e:	83 c2 06             	add    $0x6,%edx
c0101491:	0f b7 d2             	movzwl %dx,%edx
c0101494:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101498:	88 45 e9             	mov    %al,-0x17(%ebp)
c010149b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010149f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01014a3:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c01014a4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014a8:	83 c0 07             	add    $0x7,%eax
c01014ab:	0f b7 c0             	movzwl %ax,%eax
c01014ae:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01014b2:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
c01014b6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01014ba:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01014be:	ee                   	out    %al,(%dx)

    int ret = 0;
c01014bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01014c6:	eb 56                	jmp    c010151e <ide_write_secs+0x20c>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01014c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014cc:	83 ec 08             	sub    $0x8,%esp
c01014cf:	6a 01                	push   $0x1
c01014d1:	50                   	push   %eax
c01014d2:	e8 ad f8 ff ff       	call   c0100d84 <ide_wait_ready>
c01014d7:	83 c4 10             	add    $0x10,%esp
c01014da:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014e1:	75 43                	jne    c0101526 <ide_write_secs+0x214>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01014e3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01014ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01014ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01014f0:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01014f7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01014fa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01014fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101500:	89 cb                	mov    %ecx,%ebx
c0101502:	89 de                	mov    %ebx,%esi
c0101504:	89 c1                	mov    %eax,%ecx
c0101506:	fc                   	cld    
c0101507:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101509:	89 c8                	mov    %ecx,%eax
c010150b:	89 f3                	mov    %esi,%ebx
c010150d:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101510:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101513:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101517:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010151e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101522:	75 a4                	jne    c01014c8 <ide_write_secs+0x1b6>
    }

out:
c0101524:	eb 01                	jmp    c0101527 <ide_write_secs+0x215>
            goto out;
c0101526:	90                   	nop
    return ret;
c0101527:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010152a:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010152d:	5b                   	pop    %ebx
c010152e:	5e                   	pop    %esi
c010152f:	5d                   	pop    %ebp
c0101530:	c3                   	ret    

c0101531 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101531:	55                   	push   %ebp
c0101532:	89 e5                	mov    %esp,%ebp
c0101534:	83 ec 18             	sub    $0x18,%esp
c0101537:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c010153d:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101541:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101545:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101549:	ee                   	out    %al,(%dx)
c010154a:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101550:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101554:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101558:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010155c:	ee                   	out    %al,(%dx)
c010155d:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0101563:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0101567:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010156b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010156f:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101570:	c7 05 0c 40 12 c0 00 	movl   $0x0,0xc012400c
c0101577:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010157a:	83 ec 0c             	sub    $0xc,%esp
c010157d:	68 86 88 10 c0       	push   $0xc0108886
c0101582:	e8 fb ec ff ff       	call   c0100282 <cprintf>
c0101587:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c010158a:	83 ec 0c             	sub    $0xc,%esp
c010158d:	6a 00                	push   $0x0
c010158f:	e8 3f 09 00 00       	call   c0101ed3 <pic_enable>
c0101594:	83 c4 10             	add    $0x10,%esp
}
c0101597:	90                   	nop
c0101598:	c9                   	leave  
c0101599:	c3                   	ret    

c010159a <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010159a:	55                   	push   %ebp
c010159b:	89 e5                	mov    %esp,%ebp
c010159d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01015a0:	9c                   	pushf  
c01015a1:	58                   	pop    %eax
c01015a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01015a8:	25 00 02 00 00       	and    $0x200,%eax
c01015ad:	85 c0                	test   %eax,%eax
c01015af:	74 0c                	je     c01015bd <__intr_save+0x23>
        intr_disable();
c01015b1:	e8 8e 0a 00 00       	call   c0102044 <intr_disable>
        return 1;
c01015b6:	b8 01 00 00 00       	mov    $0x1,%eax
c01015bb:	eb 05                	jmp    c01015c2 <__intr_save+0x28>
    }
    return 0;
c01015bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01015c2:	c9                   	leave  
c01015c3:	c3                   	ret    

c01015c4 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01015c4:	55                   	push   %ebp
c01015c5:	89 e5                	mov    %esp,%ebp
c01015c7:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01015ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01015ce:	74 05                	je     c01015d5 <__intr_restore+0x11>
        intr_enable();
c01015d0:	e8 68 0a 00 00       	call   c010203d <intr_enable>
    }
}
c01015d5:	90                   	nop
c01015d6:	c9                   	leave  
c01015d7:	c3                   	ret    

c01015d8 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01015d8:	55                   	push   %ebp
c01015d9:	89 e5                	mov    %esp,%ebp
c01015db:	83 ec 10             	sub    $0x10,%esp
c01015de:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01015e4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015e8:	89 c2                	mov    %eax,%edx
c01015ea:	ec                   	in     (%dx),%al
c01015eb:	88 45 f1             	mov    %al,-0xf(%ebp)
c01015ee:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01015f4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01015f8:	89 c2                	mov    %eax,%edx
c01015fa:	ec                   	in     (%dx),%al
c01015fb:	88 45 f5             	mov    %al,-0xb(%ebp)
c01015fe:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0101604:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101608:	89 c2                	mov    %eax,%edx
c010160a:	ec                   	in     (%dx),%al
c010160b:	88 45 f9             	mov    %al,-0x7(%ebp)
c010160e:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0101614:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0101618:	89 c2                	mov    %eax,%edx
c010161a:	ec                   	in     (%dx),%al
c010161b:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c010161e:	90                   	nop
c010161f:	c9                   	leave  
c0101620:	c3                   	ret    

c0101621 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0101621:	55                   	push   %ebp
c0101622:	89 e5                	mov    %esp,%ebp
c0101624:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0101627:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c010162e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101631:	0f b7 00             	movzwl (%eax),%eax
c0101634:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101638:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010163b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101640:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101643:	0f b7 00             	movzwl (%eax),%eax
c0101646:	66 3d 5a a5          	cmp    $0xa55a,%ax
c010164a:	74 12                	je     c010165e <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c010164c:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101653:	66 c7 05 26 35 12 c0 	movw   $0x3b4,0xc0123526
c010165a:	b4 03 
c010165c:	eb 13                	jmp    c0101671 <cga_init+0x50>
    } else {
        *cp = was;
c010165e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101661:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101665:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101668:	66 c7 05 26 35 12 c0 	movw   $0x3d4,0xc0123526
c010166f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101671:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101678:	0f b7 c0             	movzwl %ax,%eax
c010167b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010167f:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101683:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101687:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010168b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010168c:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101693:	83 c0 01             	add    $0x1,%eax
c0101696:	0f b7 c0             	movzwl %ax,%eax
c0101699:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010169d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01016a1:	89 c2                	mov    %eax,%edx
c01016a3:	ec                   	in     (%dx),%al
c01016a4:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c01016a7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01016ab:	0f b6 c0             	movzbl %al,%eax
c01016ae:	c1 e0 08             	shl    $0x8,%eax
c01016b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01016b4:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c01016bb:	0f b7 c0             	movzwl %ax,%eax
c01016be:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01016c2:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016c6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01016ca:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01016ce:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01016cf:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c01016d6:	83 c0 01             	add    $0x1,%eax
c01016d9:	0f b7 c0             	movzwl %ax,%eax
c01016dc:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016e0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016e4:	89 c2                	mov    %eax,%edx
c01016e6:	ec                   	in     (%dx),%al
c01016e7:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c01016ea:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01016ee:	0f b6 c0             	movzbl %al,%eax
c01016f1:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01016f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016f7:	a3 20 35 12 c0       	mov    %eax,0xc0123520
    crt_pos = pos;
c01016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016ff:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
}
c0101705:	90                   	nop
c0101706:	c9                   	leave  
c0101707:	c3                   	ret    

c0101708 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101708:	55                   	push   %ebp
c0101709:	89 e5                	mov    %esp,%ebp
c010170b:	83 ec 38             	sub    $0x38,%esp
c010170e:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0101714:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101718:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010171c:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101720:	ee                   	out    %al,(%dx)
c0101721:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0101727:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c010172b:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010172f:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101733:	ee                   	out    %al,(%dx)
c0101734:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c010173a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c010173e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101742:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101746:	ee                   	out    %al,(%dx)
c0101747:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010174d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0101751:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101755:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101759:	ee                   	out    %al,(%dx)
c010175a:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101760:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0101764:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101768:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010176c:	ee                   	out    %al,(%dx)
c010176d:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101773:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0101777:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010177b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010177f:	ee                   	out    %al,(%dx)
c0101780:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101786:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c010178a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010178e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101792:	ee                   	out    %al,(%dx)
c0101793:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101799:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010179d:	89 c2                	mov    %eax,%edx
c010179f:	ec                   	in     (%dx),%al
c01017a0:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01017a3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c01017a7:	3c ff                	cmp    $0xff,%al
c01017a9:	0f 95 c0             	setne  %al
c01017ac:	0f b6 c0             	movzbl %al,%eax
c01017af:	a3 28 35 12 c0       	mov    %eax,0xc0123528
c01017b4:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017ba:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01017be:	89 c2                	mov    %eax,%edx
c01017c0:	ec                   	in     (%dx),%al
c01017c1:	88 45 f1             	mov    %al,-0xf(%ebp)
c01017c4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01017ca:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017ce:	89 c2                	mov    %eax,%edx
c01017d0:	ec                   	in     (%dx),%al
c01017d1:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01017d4:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c01017d9:	85 c0                	test   %eax,%eax
c01017db:	74 0d                	je     c01017ea <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c01017dd:	83 ec 0c             	sub    $0xc,%esp
c01017e0:	6a 04                	push   $0x4
c01017e2:	e8 ec 06 00 00       	call   c0101ed3 <pic_enable>
c01017e7:	83 c4 10             	add    $0x10,%esp
    }
}
c01017ea:	90                   	nop
c01017eb:	c9                   	leave  
c01017ec:	c3                   	ret    

c01017ed <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01017ed:	55                   	push   %ebp
c01017ee:	89 e5                	mov    %esp,%ebp
c01017f0:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01017f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01017fa:	eb 09                	jmp    c0101805 <lpt_putc_sub+0x18>
        delay();
c01017fc:	e8 d7 fd ff ff       	call   c01015d8 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101801:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101805:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010180b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010180f:	89 c2                	mov    %eax,%edx
c0101811:	ec                   	in     (%dx),%al
c0101812:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101815:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101819:	84 c0                	test   %al,%al
c010181b:	78 09                	js     c0101826 <lpt_putc_sub+0x39>
c010181d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101824:	7e d6                	jle    c01017fc <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101826:	8b 45 08             	mov    0x8(%ebp),%eax
c0101829:	0f b6 c0             	movzbl %al,%eax
c010182c:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101832:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101835:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101839:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010183d:	ee                   	out    %al,(%dx)
c010183e:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101844:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101848:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010184c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101850:	ee                   	out    %al,(%dx)
c0101851:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101857:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c010185b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010185f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101863:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101864:	90                   	nop
c0101865:	c9                   	leave  
c0101866:	c3                   	ret    

c0101867 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101867:	55                   	push   %ebp
c0101868:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c010186a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010186e:	74 0d                	je     c010187d <lpt_putc+0x16>
        lpt_putc_sub(c);
c0101870:	ff 75 08             	pushl  0x8(%ebp)
c0101873:	e8 75 ff ff ff       	call   c01017ed <lpt_putc_sub>
c0101878:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010187b:	eb 1e                	jmp    c010189b <lpt_putc+0x34>
        lpt_putc_sub('\b');
c010187d:	6a 08                	push   $0x8
c010187f:	e8 69 ff ff ff       	call   c01017ed <lpt_putc_sub>
c0101884:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c0101887:	6a 20                	push   $0x20
c0101889:	e8 5f ff ff ff       	call   c01017ed <lpt_putc_sub>
c010188e:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c0101891:	6a 08                	push   $0x8
c0101893:	e8 55 ff ff ff       	call   c01017ed <lpt_putc_sub>
c0101898:	83 c4 04             	add    $0x4,%esp
}
c010189b:	90                   	nop
c010189c:	c9                   	leave  
c010189d:	c3                   	ret    

c010189e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010189e:	55                   	push   %ebp
c010189f:	89 e5                	mov    %esp,%ebp
c01018a1:	53                   	push   %ebx
c01018a2:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01018a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01018a8:	b0 00                	mov    $0x0,%al
c01018aa:	85 c0                	test   %eax,%eax
c01018ac:	75 07                	jne    c01018b5 <cga_putc+0x17>
        c |= 0x0700;
c01018ae:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01018b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01018b8:	0f b6 c0             	movzbl %al,%eax
c01018bb:	83 f8 0a             	cmp    $0xa,%eax
c01018be:	74 52                	je     c0101912 <cga_putc+0x74>
c01018c0:	83 f8 0d             	cmp    $0xd,%eax
c01018c3:	74 5d                	je     c0101922 <cga_putc+0x84>
c01018c5:	83 f8 08             	cmp    $0x8,%eax
c01018c8:	0f 85 8e 00 00 00    	jne    c010195c <cga_putc+0xbe>
    case '\b':
        if (crt_pos > 0) {
c01018ce:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01018d5:	66 85 c0             	test   %ax,%ax
c01018d8:	0f 84 a4 00 00 00    	je     c0101982 <cga_putc+0xe4>
            crt_pos --;
c01018de:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01018e5:	83 e8 01             	sub    $0x1,%eax
c01018e8:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01018ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01018f1:	b0 00                	mov    $0x0,%al
c01018f3:	83 c8 20             	or     $0x20,%eax
c01018f6:	89 c1                	mov    %eax,%ecx
c01018f8:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c01018fd:	0f b7 15 24 35 12 c0 	movzwl 0xc0123524,%edx
c0101904:	0f b7 d2             	movzwl %dx,%edx
c0101907:	01 d2                	add    %edx,%edx
c0101909:	01 d0                	add    %edx,%eax
c010190b:	89 ca                	mov    %ecx,%edx
c010190d:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0101910:	eb 70                	jmp    c0101982 <cga_putc+0xe4>
    case '\n':
        crt_pos += CRT_COLS;
c0101912:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101919:	83 c0 50             	add    $0x50,%eax
c010191c:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101922:	0f b7 1d 24 35 12 c0 	movzwl 0xc0123524,%ebx
c0101929:	0f b7 0d 24 35 12 c0 	movzwl 0xc0123524,%ecx
c0101930:	0f b7 c1             	movzwl %cx,%eax
c0101933:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101939:	c1 e8 10             	shr    $0x10,%eax
c010193c:	89 c2                	mov    %eax,%edx
c010193e:	66 c1 ea 06          	shr    $0x6,%dx
c0101942:	89 d0                	mov    %edx,%eax
c0101944:	c1 e0 02             	shl    $0x2,%eax
c0101947:	01 d0                	add    %edx,%eax
c0101949:	c1 e0 04             	shl    $0x4,%eax
c010194c:	29 c1                	sub    %eax,%ecx
c010194e:	89 ca                	mov    %ecx,%edx
c0101950:	89 d8                	mov    %ebx,%eax
c0101952:	29 d0                	sub    %edx,%eax
c0101954:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
        break;
c010195a:	eb 27                	jmp    c0101983 <cga_putc+0xe5>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010195c:	8b 0d 20 35 12 c0    	mov    0xc0123520,%ecx
c0101962:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101969:	8d 50 01             	lea    0x1(%eax),%edx
c010196c:	66 89 15 24 35 12 c0 	mov    %dx,0xc0123524
c0101973:	0f b7 c0             	movzwl %ax,%eax
c0101976:	01 c0                	add    %eax,%eax
c0101978:	01 c8                	add    %ecx,%eax
c010197a:	8b 55 08             	mov    0x8(%ebp),%edx
c010197d:	66 89 10             	mov    %dx,(%eax)
        break;
c0101980:	eb 01                	jmp    c0101983 <cga_putc+0xe5>
        break;
c0101982:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101983:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c010198a:	66 3d cf 07          	cmp    $0x7cf,%ax
c010198e:	76 59                	jbe    c01019e9 <cga_putc+0x14b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101990:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101995:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010199b:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c01019a0:	83 ec 04             	sub    $0x4,%esp
c01019a3:	68 00 0f 00 00       	push   $0xf00
c01019a8:	52                   	push   %edx
c01019a9:	50                   	push   %eax
c01019aa:	e8 91 62 00 00       	call   c0107c40 <memmove>
c01019af:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01019b2:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01019b9:	eb 15                	jmp    c01019d0 <cga_putc+0x132>
            crt_buf[i] = 0x0700 | ' ';
c01019bb:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c01019c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01019c3:	01 d2                	add    %edx,%edx
c01019c5:	01 d0                	add    %edx,%eax
c01019c7:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01019cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01019d0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01019d7:	7e e2                	jle    c01019bb <cga_putc+0x11d>
        }
        crt_pos -= CRT_COLS;
c01019d9:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01019e0:	83 e8 50             	sub    $0x50,%eax
c01019e3:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01019e9:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c01019f0:	0f b7 c0             	movzwl %ax,%eax
c01019f3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01019f7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c01019fb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01019ff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101a03:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101a04:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a0b:	66 c1 e8 08          	shr    $0x8,%ax
c0101a0f:	0f b6 c0             	movzbl %al,%eax
c0101a12:	0f b7 15 26 35 12 c0 	movzwl 0xc0123526,%edx
c0101a19:	83 c2 01             	add    $0x1,%edx
c0101a1c:	0f b7 d2             	movzwl %dx,%edx
c0101a1f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101a23:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101a26:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101a2a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101a2e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101a2f:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101a36:	0f b7 c0             	movzwl %ax,%eax
c0101a39:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101a3d:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c0101a41:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101a45:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101a49:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101a4a:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a51:	0f b6 c0             	movzbl %al,%eax
c0101a54:	0f b7 15 26 35 12 c0 	movzwl 0xc0123526,%edx
c0101a5b:	83 c2 01             	add    $0x1,%edx
c0101a5e:	0f b7 d2             	movzwl %dx,%edx
c0101a61:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101a65:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101a68:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101a6c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101a70:	ee                   	out    %al,(%dx)
}
c0101a71:	90                   	nop
c0101a72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101a75:	c9                   	leave  
c0101a76:	c3                   	ret    

c0101a77 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101a77:	55                   	push   %ebp
c0101a78:	89 e5                	mov    %esp,%ebp
c0101a7a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101a7d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101a84:	eb 09                	jmp    c0101a8f <serial_putc_sub+0x18>
        delay();
c0101a86:	e8 4d fb ff ff       	call   c01015d8 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101a8b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101a8f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101a95:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101a99:	89 c2                	mov    %eax,%edx
c0101a9b:	ec                   	in     (%dx),%al
c0101a9c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101a9f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101aa3:	0f b6 c0             	movzbl %al,%eax
c0101aa6:	83 e0 20             	and    $0x20,%eax
c0101aa9:	85 c0                	test   %eax,%eax
c0101aab:	75 09                	jne    c0101ab6 <serial_putc_sub+0x3f>
c0101aad:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101ab4:	7e d0                	jle    c0101a86 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab9:	0f b6 c0             	movzbl %al,%eax
c0101abc:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101ac2:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ac5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101ac9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101acd:	ee                   	out    %al,(%dx)
}
c0101ace:	90                   	nop
c0101acf:	c9                   	leave  
c0101ad0:	c3                   	ret    

c0101ad1 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101ad1:	55                   	push   %ebp
c0101ad2:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0101ad4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101ad8:	74 0d                	je     c0101ae7 <serial_putc+0x16>
        serial_putc_sub(c);
c0101ada:	ff 75 08             	pushl  0x8(%ebp)
c0101add:	e8 95 ff ff ff       	call   c0101a77 <serial_putc_sub>
c0101ae2:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101ae5:	eb 1e                	jmp    c0101b05 <serial_putc+0x34>
        serial_putc_sub('\b');
c0101ae7:	6a 08                	push   $0x8
c0101ae9:	e8 89 ff ff ff       	call   c0101a77 <serial_putc_sub>
c0101aee:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0101af1:	6a 20                	push   $0x20
c0101af3:	e8 7f ff ff ff       	call   c0101a77 <serial_putc_sub>
c0101af8:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0101afb:	6a 08                	push   $0x8
c0101afd:	e8 75 ff ff ff       	call   c0101a77 <serial_putc_sub>
c0101b02:	83 c4 04             	add    $0x4,%esp
}
c0101b05:	90                   	nop
c0101b06:	c9                   	leave  
c0101b07:	c3                   	ret    

c0101b08 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101b08:	55                   	push   %ebp
c0101b09:	89 e5                	mov    %esp,%ebp
c0101b0b:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101b0e:	eb 33                	jmp    c0101b43 <cons_intr+0x3b>
        if (c != 0) {
c0101b10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101b14:	74 2d                	je     c0101b43 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101b16:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101b1b:	8d 50 01             	lea    0x1(%eax),%edx
c0101b1e:	89 15 44 37 12 c0    	mov    %edx,0xc0123744
c0101b24:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101b27:	88 90 40 35 12 c0    	mov    %dl,-0x3fedcac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101b2d:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101b32:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101b37:	75 0a                	jne    c0101b43 <cons_intr+0x3b>
                cons.wpos = 0;
c0101b39:	c7 05 44 37 12 c0 00 	movl   $0x0,0xc0123744
c0101b40:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101b43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b46:	ff d0                	call   *%eax
c0101b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101b4b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101b4f:	75 bf                	jne    c0101b10 <cons_intr+0x8>
            }
        }
    }
}
c0101b51:	90                   	nop
c0101b52:	c9                   	leave  
c0101b53:	c3                   	ret    

c0101b54 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101b54:	55                   	push   %ebp
c0101b55:	89 e5                	mov    %esp,%ebp
c0101b57:	83 ec 10             	sub    $0x10,%esp
c0101b5a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b60:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b64:	89 c2                	mov    %eax,%edx
c0101b66:	ec                   	in     (%dx),%al
c0101b67:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101b6a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101b6e:	0f b6 c0             	movzbl %al,%eax
c0101b71:	83 e0 01             	and    $0x1,%eax
c0101b74:	85 c0                	test   %eax,%eax
c0101b76:	75 07                	jne    c0101b7f <serial_proc_data+0x2b>
        return -1;
c0101b78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101b7d:	eb 2a                	jmp    c0101ba9 <serial_proc_data+0x55>
c0101b7f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b85:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b89:	89 c2                	mov    %eax,%edx
c0101b8b:	ec                   	in     (%dx),%al
c0101b8c:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101b8f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101b93:	0f b6 c0             	movzbl %al,%eax
c0101b96:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101b99:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101b9d:	75 07                	jne    c0101ba6 <serial_proc_data+0x52>
        c = '\b';
c0101b9f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101ba6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101ba9:	c9                   	leave  
c0101baa:	c3                   	ret    

c0101bab <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101bab:	55                   	push   %ebp
c0101bac:	89 e5                	mov    %esp,%ebp
c0101bae:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c0101bb1:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c0101bb6:	85 c0                	test   %eax,%eax
c0101bb8:	74 10                	je     c0101bca <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101bba:	83 ec 0c             	sub    $0xc,%esp
c0101bbd:	68 54 1b 10 c0       	push   $0xc0101b54
c0101bc2:	e8 41 ff ff ff       	call   c0101b08 <cons_intr>
c0101bc7:	83 c4 10             	add    $0x10,%esp
    }
}
c0101bca:	90                   	nop
c0101bcb:	c9                   	leave  
c0101bcc:	c3                   	ret    

c0101bcd <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101bcd:	55                   	push   %ebp
c0101bce:	89 e5                	mov    %esp,%ebp
c0101bd0:	83 ec 28             	sub    $0x28,%esp
c0101bd3:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101bd9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101bdd:	89 c2                	mov    %eax,%edx
c0101bdf:	ec                   	in     (%dx),%al
c0101be0:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101be3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101be7:	0f b6 c0             	movzbl %al,%eax
c0101bea:	83 e0 01             	and    $0x1,%eax
c0101bed:	85 c0                	test   %eax,%eax
c0101bef:	75 0a                	jne    c0101bfb <kbd_proc_data+0x2e>
        return -1;
c0101bf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101bf6:	e9 5d 01 00 00       	jmp    c0101d58 <kbd_proc_data+0x18b>
c0101bfb:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c01:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101c05:	89 c2                	mov    %eax,%edx
c0101c07:	ec                   	in     (%dx),%al
c0101c08:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101c0b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101c0f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101c12:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101c16:	75 17                	jne    c0101c2f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101c18:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101c1d:	83 c8 40             	or     $0x40,%eax
c0101c20:	a3 48 37 12 c0       	mov    %eax,0xc0123748
        return 0;
c0101c25:	b8 00 00 00 00       	mov    $0x0,%eax
c0101c2a:	e9 29 01 00 00       	jmp    c0101d58 <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0101c2f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c33:	84 c0                	test   %al,%al
c0101c35:	79 47                	jns    c0101c7e <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101c37:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101c3c:	83 e0 40             	and    $0x40,%eax
c0101c3f:	85 c0                	test   %eax,%eax
c0101c41:	75 09                	jne    c0101c4c <kbd_proc_data+0x7f>
c0101c43:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c47:	83 e0 7f             	and    $0x7f,%eax
c0101c4a:	eb 04                	jmp    c0101c50 <kbd_proc_data+0x83>
c0101c4c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c50:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101c53:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c57:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101c5e:	83 c8 40             	or     $0x40,%eax
c0101c61:	0f b6 c0             	movzbl %al,%eax
c0101c64:	f7 d0                	not    %eax
c0101c66:	89 c2                	mov    %eax,%edx
c0101c68:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101c6d:	21 d0                	and    %edx,%eax
c0101c6f:	a3 48 37 12 c0       	mov    %eax,0xc0123748
        return 0;
c0101c74:	b8 00 00 00 00       	mov    $0x0,%eax
c0101c79:	e9 da 00 00 00       	jmp    c0101d58 <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c0101c7e:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101c83:	83 e0 40             	and    $0x40,%eax
c0101c86:	85 c0                	test   %eax,%eax
c0101c88:	74 11                	je     c0101c9b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101c8a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101c8e:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101c93:	83 e0 bf             	and    $0xffffffbf,%eax
c0101c96:	a3 48 37 12 c0       	mov    %eax,0xc0123748
    }

    shift |= shiftcode[data];
c0101c9b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101c9f:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101ca6:	0f b6 d0             	movzbl %al,%edx
c0101ca9:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101cae:	09 d0                	or     %edx,%eax
c0101cb0:	a3 48 37 12 c0       	mov    %eax,0xc0123748
    shift ^= togglecode[data];
c0101cb5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cb9:	0f b6 80 40 01 12 c0 	movzbl -0x3fedfec0(%eax),%eax
c0101cc0:	0f b6 d0             	movzbl %al,%edx
c0101cc3:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101cc8:	31 d0                	xor    %edx,%eax
c0101cca:	a3 48 37 12 c0       	mov    %eax,0xc0123748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101ccf:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101cd4:	83 e0 03             	and    $0x3,%eax
c0101cd7:	8b 14 85 40 05 12 c0 	mov    -0x3fedfac0(,%eax,4),%edx
c0101cde:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ce2:	01 d0                	add    %edx,%eax
c0101ce4:	0f b6 00             	movzbl (%eax),%eax
c0101ce7:	0f b6 c0             	movzbl %al,%eax
c0101cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101ced:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101cf2:	83 e0 08             	and    $0x8,%eax
c0101cf5:	85 c0                	test   %eax,%eax
c0101cf7:	74 22                	je     c0101d1b <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101cf9:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101cfd:	7e 0c                	jle    c0101d0b <kbd_proc_data+0x13e>
c0101cff:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101d03:	7f 06                	jg     c0101d0b <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101d05:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101d09:	eb 10                	jmp    c0101d1b <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101d0b:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101d0f:	7e 0a                	jle    c0101d1b <kbd_proc_data+0x14e>
c0101d11:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101d15:	7f 04                	jg     c0101d1b <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101d17:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101d1b:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d20:	f7 d0                	not    %eax
c0101d22:	83 e0 06             	and    $0x6,%eax
c0101d25:	85 c0                	test   %eax,%eax
c0101d27:	75 2c                	jne    c0101d55 <kbd_proc_data+0x188>
c0101d29:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101d30:	75 23                	jne    c0101d55 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0101d32:	83 ec 0c             	sub    $0xc,%esp
c0101d35:	68 a1 88 10 c0       	push   $0xc01088a1
c0101d3a:	e8 43 e5 ff ff       	call   c0100282 <cprintf>
c0101d3f:	83 c4 10             	add    $0x10,%esp
c0101d42:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101d48:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d4c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101d50:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101d54:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d58:	c9                   	leave  
c0101d59:	c3                   	ret    

c0101d5a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101d5a:	55                   	push   %ebp
c0101d5b:	89 e5                	mov    %esp,%ebp
c0101d5d:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c0101d60:	83 ec 0c             	sub    $0xc,%esp
c0101d63:	68 cd 1b 10 c0       	push   $0xc0101bcd
c0101d68:	e8 9b fd ff ff       	call   c0101b08 <cons_intr>
c0101d6d:	83 c4 10             	add    $0x10,%esp
}
c0101d70:	90                   	nop
c0101d71:	c9                   	leave  
c0101d72:	c3                   	ret    

c0101d73 <kbd_init>:

static void
kbd_init(void) {
c0101d73:	55                   	push   %ebp
c0101d74:	89 e5                	mov    %esp,%ebp
c0101d76:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c0101d79:	e8 dc ff ff ff       	call   c0101d5a <kbd_intr>
    pic_enable(IRQ_KBD);
c0101d7e:	83 ec 0c             	sub    $0xc,%esp
c0101d81:	6a 01                	push   $0x1
c0101d83:	e8 4b 01 00 00       	call   c0101ed3 <pic_enable>
c0101d88:	83 c4 10             	add    $0x10,%esp
}
c0101d8b:	90                   	nop
c0101d8c:	c9                   	leave  
c0101d8d:	c3                   	ret    

c0101d8e <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101d8e:	55                   	push   %ebp
c0101d8f:	89 e5                	mov    %esp,%ebp
c0101d91:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c0101d94:	e8 88 f8 ff ff       	call   c0101621 <cga_init>
    serial_init();
c0101d99:	e8 6a f9 ff ff       	call   c0101708 <serial_init>
    kbd_init();
c0101d9e:	e8 d0 ff ff ff       	call   c0101d73 <kbd_init>
    if (!serial_exists) {
c0101da3:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c0101da8:	85 c0                	test   %eax,%eax
c0101daa:	75 10                	jne    c0101dbc <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0101dac:	83 ec 0c             	sub    $0xc,%esp
c0101daf:	68 ad 88 10 c0       	push   $0xc01088ad
c0101db4:	e8 c9 e4 ff ff       	call   c0100282 <cprintf>
c0101db9:	83 c4 10             	add    $0x10,%esp
    }
}
c0101dbc:	90                   	nop
c0101dbd:	c9                   	leave  
c0101dbe:	c3                   	ret    

c0101dbf <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101dbf:	55                   	push   %ebp
c0101dc0:	89 e5                	mov    %esp,%ebp
c0101dc2:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101dc5:	e8 d0 f7 ff ff       	call   c010159a <__intr_save>
c0101dca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101dcd:	83 ec 0c             	sub    $0xc,%esp
c0101dd0:	ff 75 08             	pushl  0x8(%ebp)
c0101dd3:	e8 8f fa ff ff       	call   c0101867 <lpt_putc>
c0101dd8:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c0101ddb:	83 ec 0c             	sub    $0xc,%esp
c0101dde:	ff 75 08             	pushl  0x8(%ebp)
c0101de1:	e8 b8 fa ff ff       	call   c010189e <cga_putc>
c0101de6:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c0101de9:	83 ec 0c             	sub    $0xc,%esp
c0101dec:	ff 75 08             	pushl  0x8(%ebp)
c0101def:	e8 dd fc ff ff       	call   c0101ad1 <serial_putc>
c0101df4:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0101df7:	83 ec 0c             	sub    $0xc,%esp
c0101dfa:	ff 75 f4             	pushl  -0xc(%ebp)
c0101dfd:	e8 c2 f7 ff ff       	call   c01015c4 <__intr_restore>
c0101e02:	83 c4 10             	add    $0x10,%esp
}
c0101e05:	90                   	nop
c0101e06:	c9                   	leave  
c0101e07:	c3                   	ret    

c0101e08 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101e08:	55                   	push   %ebp
c0101e09:	89 e5                	mov    %esp,%ebp
c0101e0b:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0101e0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e15:	e8 80 f7 ff ff       	call   c010159a <__intr_save>
c0101e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101e1d:	e8 89 fd ff ff       	call   c0101bab <serial_intr>
        kbd_intr();
c0101e22:	e8 33 ff ff ff       	call   c0101d5a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101e27:	8b 15 40 37 12 c0    	mov    0xc0123740,%edx
c0101e2d:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101e32:	39 c2                	cmp    %eax,%edx
c0101e34:	74 31                	je     c0101e67 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101e36:	a1 40 37 12 c0       	mov    0xc0123740,%eax
c0101e3b:	8d 50 01             	lea    0x1(%eax),%edx
c0101e3e:	89 15 40 37 12 c0    	mov    %edx,0xc0123740
c0101e44:	0f b6 80 40 35 12 c0 	movzbl -0x3fedcac0(%eax),%eax
c0101e4b:	0f b6 c0             	movzbl %al,%eax
c0101e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101e51:	a1 40 37 12 c0       	mov    0xc0123740,%eax
c0101e56:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101e5b:	75 0a                	jne    c0101e67 <cons_getc+0x5f>
                cons.rpos = 0;
c0101e5d:	c7 05 40 37 12 c0 00 	movl   $0x0,0xc0123740
c0101e64:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101e67:	83 ec 0c             	sub    $0xc,%esp
c0101e6a:	ff 75 f0             	pushl  -0x10(%ebp)
c0101e6d:	e8 52 f7 ff ff       	call   c01015c4 <__intr_restore>
c0101e72:	83 c4 10             	add    $0x10,%esp
    return c;
c0101e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e78:	c9                   	leave  
c0101e79:	c3                   	ret    

c0101e7a <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101e7a:	55                   	push   %ebp
c0101e7b:	89 e5                	mov    %esp,%ebp
c0101e7d:	83 ec 14             	sub    $0x14,%esp
c0101e80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e83:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101e87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101e8b:	66 a3 50 05 12 c0    	mov    %ax,0xc0120550
    if (did_init) {
c0101e91:	a1 4c 37 12 c0       	mov    0xc012374c,%eax
c0101e96:	85 c0                	test   %eax,%eax
c0101e98:	74 36                	je     c0101ed0 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101e9a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101e9e:	0f b6 c0             	movzbl %al,%eax
c0101ea1:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101ea7:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101eaa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101eae:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101eb2:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101eb3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101eb7:	66 c1 e8 08          	shr    $0x8,%ax
c0101ebb:	0f b6 c0             	movzbl %al,%eax
c0101ebe:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101ec4:	88 45 fd             	mov    %al,-0x3(%ebp)
c0101ec7:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101ecb:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101ecf:	ee                   	out    %al,(%dx)
    }
}
c0101ed0:	90                   	nop
c0101ed1:	c9                   	leave  
c0101ed2:	c3                   	ret    

c0101ed3 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101ed3:	55                   	push   %ebp
c0101ed4:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c0101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed9:	ba 01 00 00 00       	mov    $0x1,%edx
c0101ede:	89 c1                	mov    %eax,%ecx
c0101ee0:	d3 e2                	shl    %cl,%edx
c0101ee2:	89 d0                	mov    %edx,%eax
c0101ee4:	f7 d0                	not    %eax
c0101ee6:	89 c2                	mov    %eax,%edx
c0101ee8:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0101eef:	21 d0                	and    %edx,%eax
c0101ef1:	0f b7 c0             	movzwl %ax,%eax
c0101ef4:	50                   	push   %eax
c0101ef5:	e8 80 ff ff ff       	call   c0101e7a <pic_setmask>
c0101efa:	83 c4 04             	add    $0x4,%esp
}
c0101efd:	90                   	nop
c0101efe:	c9                   	leave  
c0101eff:	c3                   	ret    

c0101f00 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101f00:	55                   	push   %ebp
c0101f01:	89 e5                	mov    %esp,%ebp
c0101f03:	83 ec 40             	sub    $0x40,%esp
    did_init = 1;
c0101f06:	c7 05 4c 37 12 c0 01 	movl   $0x1,0xc012374c
c0101f0d:	00 00 00 
c0101f10:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101f16:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101f1a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101f1e:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101f22:	ee                   	out    %al,(%dx)
c0101f23:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101f29:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c0101f2d:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101f31:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101f35:	ee                   	out    %al,(%dx)
c0101f36:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101f3c:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c0101f40:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101f44:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101f48:	ee                   	out    %al,(%dx)
c0101f49:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101f4f:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101f53:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101f57:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101f5b:	ee                   	out    %al,(%dx)
c0101f5c:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101f62:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c0101f66:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101f6a:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101f6e:	ee                   	out    %al,(%dx)
c0101f6f:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c0101f75:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c0101f79:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f7d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f81:	ee                   	out    %al,(%dx)
c0101f82:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0101f88:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c0101f8c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101f90:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101f94:	ee                   	out    %al,(%dx)
c0101f95:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0101f9b:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c0101f9f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101fa3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101fa7:	ee                   	out    %al,(%dx)
c0101fa8:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0101fae:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c0101fb2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101fb6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101fba:	ee                   	out    %al,(%dx)
c0101fbb:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0101fc1:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c0101fc5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101fc9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101fcd:	ee                   	out    %al,(%dx)
c0101fce:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101fd4:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0101fd8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101fdc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101fe0:	ee                   	out    %al,(%dx)
c0101fe1:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101fe7:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0101feb:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101fef:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101ff3:	ee                   	out    %al,(%dx)
c0101ff4:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101ffa:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c0101ffe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102002:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102006:	ee                   	out    %al,(%dx)
c0102007:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010200d:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c0102011:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102015:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102019:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010201a:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0102021:	66 83 f8 ff          	cmp    $0xffff,%ax
c0102025:	74 13                	je     c010203a <pic_init+0x13a>
        pic_setmask(irq_mask);
c0102027:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c010202e:	0f b7 c0             	movzwl %ax,%eax
c0102031:	50                   	push   %eax
c0102032:	e8 43 fe ff ff       	call   c0101e7a <pic_setmask>
c0102037:	83 c4 04             	add    $0x4,%esp
    }
}
c010203a:	90                   	nop
c010203b:	c9                   	leave  
c010203c:	c3                   	ret    

c010203d <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010203d:	55                   	push   %ebp
c010203e:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0102040:	fb                   	sti    
    sti();
}
c0102041:	90                   	nop
c0102042:	5d                   	pop    %ebp
c0102043:	c3                   	ret    

c0102044 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102044:	55                   	push   %ebp
c0102045:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0102047:	fa                   	cli    
    cli();
}
c0102048:	90                   	nop
c0102049:	5d                   	pop    %ebp
c010204a:	c3                   	ret    

c010204b <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010204b:	55                   	push   %ebp
c010204c:	89 e5                	mov    %esp,%ebp
c010204e:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102051:	83 ec 08             	sub    $0x8,%esp
c0102054:	6a 64                	push   $0x64
c0102056:	68 e0 88 10 c0       	push   $0xc01088e0
c010205b:	e8 22 e2 ff ff       	call   c0100282 <cprintf>
c0102060:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102063:	90                   	nop
c0102064:	c9                   	leave  
c0102065:	c3                   	ret    

c0102066 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102066:	55                   	push   %ebp
c0102067:	89 e5                	mov    %esp,%ebp
c0102069:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010206c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102073:	e9 c3 00 00 00       	jmp    c010213b <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102078:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010207b:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c0102082:	89 c2                	mov    %eax,%edx
c0102084:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102087:	66 89 14 c5 60 37 12 	mov    %dx,-0x3fedc8a0(,%eax,8)
c010208e:	c0 
c010208f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102092:	66 c7 04 c5 62 37 12 	movw   $0x8,-0x3fedc89e(,%eax,8)
c0102099:	c0 08 00 
c010209c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010209f:	0f b6 14 c5 64 37 12 	movzbl -0x3fedc89c(,%eax,8),%edx
c01020a6:	c0 
c01020a7:	83 e2 e0             	and    $0xffffffe0,%edx
c01020aa:	88 14 c5 64 37 12 c0 	mov    %dl,-0x3fedc89c(,%eax,8)
c01020b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020b4:	0f b6 14 c5 64 37 12 	movzbl -0x3fedc89c(,%eax,8),%edx
c01020bb:	c0 
c01020bc:	83 e2 1f             	and    $0x1f,%edx
c01020bf:	88 14 c5 64 37 12 c0 	mov    %dl,-0x3fedc89c(,%eax,8)
c01020c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020c9:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01020d0:	c0 
c01020d1:	83 e2 f0             	and    $0xfffffff0,%edx
c01020d4:	83 ca 0e             	or     $0xe,%edx
c01020d7:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01020de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020e1:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01020e8:	c0 
c01020e9:	83 e2 ef             	and    $0xffffffef,%edx
c01020ec:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01020f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020f6:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01020fd:	c0 
c01020fe:	83 e2 9f             	and    $0xffffff9f,%edx
c0102101:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c0102108:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010210b:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c0102112:	c0 
c0102113:	83 ca 80             	or     $0xffffff80,%edx
c0102116:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c010211d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102120:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c0102127:	c1 e8 10             	shr    $0x10,%eax
c010212a:	89 c2                	mov    %eax,%edx
c010212c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010212f:	66 89 14 c5 66 37 12 	mov    %dx,-0x3fedc89a(,%eax,8)
c0102136:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102137:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010213b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010213e:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102143:	0f 86 2f ff ff ff    	jbe    c0102078 <idt_init+0x12>
c0102149:	c7 45 f8 60 05 12 c0 	movl   $0xc0120560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102150:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102153:	0f 01 18             	lidtl  (%eax)
    }
    lidt(&idt_pd);
}
c0102156:	90                   	nop
c0102157:	c9                   	leave  
c0102158:	c3                   	ret    

c0102159 <trapname>:

static const char *
trapname(int trapno) {
c0102159:	55                   	push   %ebp
c010215a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010215c:	8b 45 08             	mov    0x8(%ebp),%eax
c010215f:	83 f8 13             	cmp    $0x13,%eax
c0102162:	77 0c                	ja     c0102170 <trapname+0x17>
        return excnames[trapno];
c0102164:	8b 45 08             	mov    0x8(%ebp),%eax
c0102167:	8b 04 85 c0 8c 10 c0 	mov    -0x3fef7340(,%eax,4),%eax
c010216e:	eb 18                	jmp    c0102188 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0102170:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102174:	7e 0d                	jle    c0102183 <trapname+0x2a>
c0102176:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010217a:	7f 07                	jg     c0102183 <trapname+0x2a>
        return "Hardware Interrupt";
c010217c:	b8 ea 88 10 c0       	mov    $0xc01088ea,%eax
c0102181:	eb 05                	jmp    c0102188 <trapname+0x2f>
    }
    return "(unknown trap)";
c0102183:	b8 fd 88 10 c0       	mov    $0xc01088fd,%eax
}
c0102188:	5d                   	pop    %ebp
c0102189:	c3                   	ret    

c010218a <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010218a:	55                   	push   %ebp
c010218b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010218d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102190:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102194:	66 83 f8 08          	cmp    $0x8,%ax
c0102198:	0f 94 c0             	sete   %al
c010219b:	0f b6 c0             	movzbl %al,%eax
}
c010219e:	5d                   	pop    %ebp
c010219f:	c3                   	ret    

c01021a0 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01021a0:	55                   	push   %ebp
c01021a1:	89 e5                	mov    %esp,%ebp
c01021a3:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c01021a6:	83 ec 08             	sub    $0x8,%esp
c01021a9:	ff 75 08             	pushl  0x8(%ebp)
c01021ac:	68 3e 89 10 c0       	push   $0xc010893e
c01021b1:	e8 cc e0 ff ff       	call   c0100282 <cprintf>
c01021b6:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c01021b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01021bc:	83 ec 0c             	sub    $0xc,%esp
c01021bf:	50                   	push   %eax
c01021c0:	e8 b6 01 00 00       	call   c010237b <print_regs>
c01021c5:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01021c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01021cb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01021cf:	0f b7 c0             	movzwl %ax,%eax
c01021d2:	83 ec 08             	sub    $0x8,%esp
c01021d5:	50                   	push   %eax
c01021d6:	68 4f 89 10 c0       	push   $0xc010894f
c01021db:	e8 a2 e0 ff ff       	call   c0100282 <cprintf>
c01021e0:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01021e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01021e6:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01021ea:	0f b7 c0             	movzwl %ax,%eax
c01021ed:	83 ec 08             	sub    $0x8,%esp
c01021f0:	50                   	push   %eax
c01021f1:	68 62 89 10 c0       	push   $0xc0108962
c01021f6:	e8 87 e0 ff ff       	call   c0100282 <cprintf>
c01021fb:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01021fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102201:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102205:	0f b7 c0             	movzwl %ax,%eax
c0102208:	83 ec 08             	sub    $0x8,%esp
c010220b:	50                   	push   %eax
c010220c:	68 75 89 10 c0       	push   $0xc0108975
c0102211:	e8 6c e0 ff ff       	call   c0100282 <cprintf>
c0102216:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102219:	8b 45 08             	mov    0x8(%ebp),%eax
c010221c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102220:	0f b7 c0             	movzwl %ax,%eax
c0102223:	83 ec 08             	sub    $0x8,%esp
c0102226:	50                   	push   %eax
c0102227:	68 88 89 10 c0       	push   $0xc0108988
c010222c:	e8 51 e0 ff ff       	call   c0100282 <cprintf>
c0102231:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102234:	8b 45 08             	mov    0x8(%ebp),%eax
c0102237:	8b 40 30             	mov    0x30(%eax),%eax
c010223a:	83 ec 0c             	sub    $0xc,%esp
c010223d:	50                   	push   %eax
c010223e:	e8 16 ff ff ff       	call   c0102159 <trapname>
c0102243:	83 c4 10             	add    $0x10,%esp
c0102246:	89 c2                	mov    %eax,%edx
c0102248:	8b 45 08             	mov    0x8(%ebp),%eax
c010224b:	8b 40 30             	mov    0x30(%eax),%eax
c010224e:	83 ec 04             	sub    $0x4,%esp
c0102251:	52                   	push   %edx
c0102252:	50                   	push   %eax
c0102253:	68 9b 89 10 c0       	push   $0xc010899b
c0102258:	e8 25 e0 ff ff       	call   c0100282 <cprintf>
c010225d:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102260:	8b 45 08             	mov    0x8(%ebp),%eax
c0102263:	8b 40 34             	mov    0x34(%eax),%eax
c0102266:	83 ec 08             	sub    $0x8,%esp
c0102269:	50                   	push   %eax
c010226a:	68 ad 89 10 c0       	push   $0xc01089ad
c010226f:	e8 0e e0 ff ff       	call   c0100282 <cprintf>
c0102274:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102277:	8b 45 08             	mov    0x8(%ebp),%eax
c010227a:	8b 40 38             	mov    0x38(%eax),%eax
c010227d:	83 ec 08             	sub    $0x8,%esp
c0102280:	50                   	push   %eax
c0102281:	68 bc 89 10 c0       	push   $0xc01089bc
c0102286:	e8 f7 df ff ff       	call   c0100282 <cprintf>
c010228b:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010228e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102291:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102295:	0f b7 c0             	movzwl %ax,%eax
c0102298:	83 ec 08             	sub    $0x8,%esp
c010229b:	50                   	push   %eax
c010229c:	68 cb 89 10 c0       	push   $0xc01089cb
c01022a1:	e8 dc df ff ff       	call   c0100282 <cprintf>
c01022a6:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01022a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01022ac:	8b 40 40             	mov    0x40(%eax),%eax
c01022af:	83 ec 08             	sub    $0x8,%esp
c01022b2:	50                   	push   %eax
c01022b3:	68 de 89 10 c0       	push   $0xc01089de
c01022b8:	e8 c5 df ff ff       	call   c0100282 <cprintf>
c01022bd:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01022c7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01022ce:	eb 3f                	jmp    c010230f <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01022d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022d3:	8b 50 40             	mov    0x40(%eax),%edx
c01022d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01022d9:	21 d0                	and    %edx,%eax
c01022db:	85 c0                	test   %eax,%eax
c01022dd:	74 29                	je     c0102308 <print_trapframe+0x168>
c01022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01022e2:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c01022e9:	85 c0                	test   %eax,%eax
c01022eb:	74 1b                	je     c0102308 <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c01022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01022f0:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c01022f7:	83 ec 08             	sub    $0x8,%esp
c01022fa:	50                   	push   %eax
c01022fb:	68 ed 89 10 c0       	push   $0xc01089ed
c0102300:	e8 7d df ff ff       	call   c0100282 <cprintf>
c0102305:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102308:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010230c:	d1 65 f0             	shll   -0x10(%ebp)
c010230f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102312:	83 f8 17             	cmp    $0x17,%eax
c0102315:	76 b9                	jbe    c01022d0 <print_trapframe+0x130>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102317:	8b 45 08             	mov    0x8(%ebp),%eax
c010231a:	8b 40 40             	mov    0x40(%eax),%eax
c010231d:	c1 e8 0c             	shr    $0xc,%eax
c0102320:	83 e0 03             	and    $0x3,%eax
c0102323:	83 ec 08             	sub    $0x8,%esp
c0102326:	50                   	push   %eax
c0102327:	68 f1 89 10 c0       	push   $0xc01089f1
c010232c:	e8 51 df ff ff       	call   c0100282 <cprintf>
c0102331:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c0102334:	83 ec 0c             	sub    $0xc,%esp
c0102337:	ff 75 08             	pushl  0x8(%ebp)
c010233a:	e8 4b fe ff ff       	call   c010218a <trap_in_kernel>
c010233f:	83 c4 10             	add    $0x10,%esp
c0102342:	85 c0                	test   %eax,%eax
c0102344:	75 32                	jne    c0102378 <print_trapframe+0x1d8>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102346:	8b 45 08             	mov    0x8(%ebp),%eax
c0102349:	8b 40 44             	mov    0x44(%eax),%eax
c010234c:	83 ec 08             	sub    $0x8,%esp
c010234f:	50                   	push   %eax
c0102350:	68 fa 89 10 c0       	push   $0xc01089fa
c0102355:	e8 28 df ff ff       	call   c0100282 <cprintf>
c010235a:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010235d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102360:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102364:	0f b7 c0             	movzwl %ax,%eax
c0102367:	83 ec 08             	sub    $0x8,%esp
c010236a:	50                   	push   %eax
c010236b:	68 09 8a 10 c0       	push   $0xc0108a09
c0102370:	e8 0d df ff ff       	call   c0100282 <cprintf>
c0102375:	83 c4 10             	add    $0x10,%esp
    }
}
c0102378:	90                   	nop
c0102379:	c9                   	leave  
c010237a:	c3                   	ret    

c010237b <print_regs>:

void
print_regs(struct pushregs *regs) {
c010237b:	55                   	push   %ebp
c010237c:	89 e5                	mov    %esp,%ebp
c010237e:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102381:	8b 45 08             	mov    0x8(%ebp),%eax
c0102384:	8b 00                	mov    (%eax),%eax
c0102386:	83 ec 08             	sub    $0x8,%esp
c0102389:	50                   	push   %eax
c010238a:	68 1c 8a 10 c0       	push   $0xc0108a1c
c010238f:	e8 ee de ff ff       	call   c0100282 <cprintf>
c0102394:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102397:	8b 45 08             	mov    0x8(%ebp),%eax
c010239a:	8b 40 04             	mov    0x4(%eax),%eax
c010239d:	83 ec 08             	sub    $0x8,%esp
c01023a0:	50                   	push   %eax
c01023a1:	68 2b 8a 10 c0       	push   $0xc0108a2b
c01023a6:	e8 d7 de ff ff       	call   c0100282 <cprintf>
c01023ab:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01023ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b1:	8b 40 08             	mov    0x8(%eax),%eax
c01023b4:	83 ec 08             	sub    $0x8,%esp
c01023b7:	50                   	push   %eax
c01023b8:	68 3a 8a 10 c0       	push   $0xc0108a3a
c01023bd:	e8 c0 de ff ff       	call   c0100282 <cprintf>
c01023c2:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01023c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c8:	8b 40 0c             	mov    0xc(%eax),%eax
c01023cb:	83 ec 08             	sub    $0x8,%esp
c01023ce:	50                   	push   %eax
c01023cf:	68 49 8a 10 c0       	push   $0xc0108a49
c01023d4:	e8 a9 de ff ff       	call   c0100282 <cprintf>
c01023d9:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01023dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01023df:	8b 40 10             	mov    0x10(%eax),%eax
c01023e2:	83 ec 08             	sub    $0x8,%esp
c01023e5:	50                   	push   %eax
c01023e6:	68 58 8a 10 c0       	push   $0xc0108a58
c01023eb:	e8 92 de ff ff       	call   c0100282 <cprintf>
c01023f0:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01023f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f6:	8b 40 14             	mov    0x14(%eax),%eax
c01023f9:	83 ec 08             	sub    $0x8,%esp
c01023fc:	50                   	push   %eax
c01023fd:	68 67 8a 10 c0       	push   $0xc0108a67
c0102402:	e8 7b de ff ff       	call   c0100282 <cprintf>
c0102407:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010240a:	8b 45 08             	mov    0x8(%ebp),%eax
c010240d:	8b 40 18             	mov    0x18(%eax),%eax
c0102410:	83 ec 08             	sub    $0x8,%esp
c0102413:	50                   	push   %eax
c0102414:	68 76 8a 10 c0       	push   $0xc0108a76
c0102419:	e8 64 de ff ff       	call   c0100282 <cprintf>
c010241e:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102421:	8b 45 08             	mov    0x8(%ebp),%eax
c0102424:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102427:	83 ec 08             	sub    $0x8,%esp
c010242a:	50                   	push   %eax
c010242b:	68 85 8a 10 c0       	push   $0xc0108a85
c0102430:	e8 4d de ff ff       	call   c0100282 <cprintf>
c0102435:	83 c4 10             	add    $0x10,%esp
}
c0102438:	90                   	nop
c0102439:	c9                   	leave  
c010243a:	c3                   	ret    

c010243b <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010243b:	55                   	push   %ebp
c010243c:	89 e5                	mov    %esp,%ebp
c010243e:	53                   	push   %ebx
c010243f:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102442:	8b 45 08             	mov    0x8(%ebp),%eax
c0102445:	8b 40 34             	mov    0x34(%eax),%eax
c0102448:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010244b:	85 c0                	test   %eax,%eax
c010244d:	74 07                	je     c0102456 <print_pgfault+0x1b>
c010244f:	bb 94 8a 10 c0       	mov    $0xc0108a94,%ebx
c0102454:	eb 05                	jmp    c010245b <print_pgfault+0x20>
c0102456:	bb a5 8a 10 c0       	mov    $0xc0108aa5,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010245b:	8b 45 08             	mov    0x8(%ebp),%eax
c010245e:	8b 40 34             	mov    0x34(%eax),%eax
c0102461:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102464:	85 c0                	test   %eax,%eax
c0102466:	74 07                	je     c010246f <print_pgfault+0x34>
c0102468:	b9 57 00 00 00       	mov    $0x57,%ecx
c010246d:	eb 05                	jmp    c0102474 <print_pgfault+0x39>
c010246f:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102474:	8b 45 08             	mov    0x8(%ebp),%eax
c0102477:	8b 40 34             	mov    0x34(%eax),%eax
c010247a:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010247d:	85 c0                	test   %eax,%eax
c010247f:	74 07                	je     c0102488 <print_pgfault+0x4d>
c0102481:	ba 55 00 00 00       	mov    $0x55,%edx
c0102486:	eb 05                	jmp    c010248d <print_pgfault+0x52>
c0102488:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010248d:	0f 20 d0             	mov    %cr2,%eax
c0102490:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102493:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102496:	83 ec 0c             	sub    $0xc,%esp
c0102499:	53                   	push   %ebx
c010249a:	51                   	push   %ecx
c010249b:	52                   	push   %edx
c010249c:	50                   	push   %eax
c010249d:	68 b4 8a 10 c0       	push   $0xc0108ab4
c01024a2:	e8 db dd ff ff       	call   c0100282 <cprintf>
c01024a7:	83 c4 20             	add    $0x20,%esp
}
c01024aa:	90                   	nop
c01024ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01024ae:	c9                   	leave  
c01024af:	c3                   	ret    

c01024b0 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01024b0:	55                   	push   %ebp
c01024b1:	89 e5                	mov    %esp,%ebp
c01024b3:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01024b6:	83 ec 0c             	sub    $0xc,%esp
c01024b9:	ff 75 08             	pushl  0x8(%ebp)
c01024bc:	e8 7a ff ff ff       	call   c010243b <print_pgfault>
c01024c1:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c01024c4:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01024c9:	85 c0                	test   %eax,%eax
c01024cb:	74 24                	je     c01024f1 <pgfault_handler+0x41>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01024cd:	0f 20 d0             	mov    %cr2,%eax
c01024d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01024d3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01024d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d9:	8b 50 34             	mov    0x34(%eax),%edx
c01024dc:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01024e1:	83 ec 04             	sub    $0x4,%esp
c01024e4:	51                   	push   %ecx
c01024e5:	52                   	push   %edx
c01024e6:	50                   	push   %eax
c01024e7:	e8 92 16 00 00       	call   c0103b7e <do_pgfault>
c01024ec:	83 c4 10             	add    $0x10,%esp
c01024ef:	eb 17                	jmp    c0102508 <pgfault_handler+0x58>
    }
    panic("unhandled page fault.\n");
c01024f1:	83 ec 04             	sub    $0x4,%esp
c01024f4:	68 d7 8a 10 c0       	push   $0xc0108ad7
c01024f9:	68 a5 00 00 00       	push   $0xa5
c01024fe:	68 ee 8a 10 c0       	push   $0xc0108aee
c0102503:	e8 e0 de ff ff       	call   c01003e8 <__panic>
}
c0102508:	c9                   	leave  
c0102509:	c3                   	ret    

c010250a <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010250a:	55                   	push   %ebp
c010250b:	89 e5                	mov    %esp,%ebp
c010250d:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102510:	8b 45 08             	mov    0x8(%ebp),%eax
c0102513:	8b 40 30             	mov    0x30(%eax),%eax
c0102516:	83 f8 24             	cmp    $0x24,%eax
c0102519:	0f 84 ba 00 00 00    	je     c01025d9 <trap_dispatch+0xcf>
c010251f:	83 f8 24             	cmp    $0x24,%eax
c0102522:	77 18                	ja     c010253c <trap_dispatch+0x32>
c0102524:	83 f8 20             	cmp    $0x20,%eax
c0102527:	74 76                	je     c010259f <trap_dispatch+0x95>
c0102529:	83 f8 21             	cmp    $0x21,%eax
c010252c:	0f 84 cb 00 00 00    	je     c01025fd <trap_dispatch+0xf3>
c0102532:	83 f8 0e             	cmp    $0xe,%eax
c0102535:	74 28                	je     c010255f <trap_dispatch+0x55>
c0102537:	e9 fc 00 00 00       	jmp    c0102638 <trap_dispatch+0x12e>
c010253c:	83 f8 2e             	cmp    $0x2e,%eax
c010253f:	0f 82 f3 00 00 00    	jb     c0102638 <trap_dispatch+0x12e>
c0102545:	83 f8 2f             	cmp    $0x2f,%eax
c0102548:	0f 86 20 01 00 00    	jbe    c010266e <trap_dispatch+0x164>
c010254e:	83 e8 78             	sub    $0x78,%eax
c0102551:	83 f8 01             	cmp    $0x1,%eax
c0102554:	0f 87 de 00 00 00    	ja     c0102638 <trap_dispatch+0x12e>
c010255a:	e9 c2 00 00 00       	jmp    c0102621 <trap_dispatch+0x117>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010255f:	83 ec 0c             	sub    $0xc,%esp
c0102562:	ff 75 08             	pushl  0x8(%ebp)
c0102565:	e8 46 ff ff ff       	call   c01024b0 <pgfault_handler>
c010256a:	83 c4 10             	add    $0x10,%esp
c010256d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102570:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102574:	0f 84 f7 00 00 00    	je     c0102671 <trap_dispatch+0x167>
            print_trapframe(tf);
c010257a:	83 ec 0c             	sub    $0xc,%esp
c010257d:	ff 75 08             	pushl  0x8(%ebp)
c0102580:	e8 1b fc ff ff       	call   c01021a0 <print_trapframe>
c0102585:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c0102588:	ff 75 f0             	pushl  -0x10(%ebp)
c010258b:	68 ff 8a 10 c0       	push   $0xc0108aff
c0102590:	68 b5 00 00 00       	push   $0xb5
c0102595:	68 ee 8a 10 c0       	push   $0xc0108aee
c010259a:	e8 49 de ff ff       	call   c01003e8 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c010259f:	a1 0c 40 12 c0       	mov    0xc012400c,%eax
c01025a4:	83 c0 01             	add    $0x1,%eax
c01025a7:	a3 0c 40 12 c0       	mov    %eax,0xc012400c
        if (ticks % TICK_NUM == 0) {
c01025ac:	8b 0d 0c 40 12 c0    	mov    0xc012400c,%ecx
c01025b2:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01025b7:	89 c8                	mov    %ecx,%eax
c01025b9:	f7 e2                	mul    %edx
c01025bb:	89 d0                	mov    %edx,%eax
c01025bd:	c1 e8 05             	shr    $0x5,%eax
c01025c0:	6b c0 64             	imul   $0x64,%eax,%eax
c01025c3:	29 c1                	sub    %eax,%ecx
c01025c5:	89 c8                	mov    %ecx,%eax
c01025c7:	85 c0                	test   %eax,%eax
c01025c9:	0f 85 a5 00 00 00    	jne    c0102674 <trap_dispatch+0x16a>
            print_ticks();
c01025cf:	e8 77 fa ff ff       	call   c010204b <print_ticks>
        }
        break;
c01025d4:	e9 9b 00 00 00       	jmp    c0102674 <trap_dispatch+0x16a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01025d9:	e8 2a f8 ff ff       	call   c0101e08 <cons_getc>
c01025de:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01025e1:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01025e5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01025e9:	83 ec 04             	sub    $0x4,%esp
c01025ec:	52                   	push   %edx
c01025ed:	50                   	push   %eax
c01025ee:	68 1a 8b 10 c0       	push   $0xc0108b1a
c01025f3:	e8 8a dc ff ff       	call   c0100282 <cprintf>
c01025f8:	83 c4 10             	add    $0x10,%esp
        break;
c01025fb:	eb 78                	jmp    c0102675 <trap_dispatch+0x16b>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01025fd:	e8 06 f8 ff ff       	call   c0101e08 <cons_getc>
c0102602:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102605:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0102609:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010260d:	83 ec 04             	sub    $0x4,%esp
c0102610:	52                   	push   %edx
c0102611:	50                   	push   %eax
c0102612:	68 2c 8b 10 c0       	push   $0xc0108b2c
c0102617:	e8 66 dc ff ff       	call   c0100282 <cprintf>
c010261c:	83 c4 10             	add    $0x10,%esp
        break;
c010261f:	eb 54                	jmp    c0102675 <trap_dispatch+0x16b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102621:	83 ec 04             	sub    $0x4,%esp
c0102624:	68 3b 8b 10 c0       	push   $0xc0108b3b
c0102629:	68 d3 00 00 00       	push   $0xd3
c010262e:	68 ee 8a 10 c0       	push   $0xc0108aee
c0102633:	e8 b0 dd ff ff       	call   c01003e8 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102638:	8b 45 08             	mov    0x8(%ebp),%eax
c010263b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010263f:	0f b7 c0             	movzwl %ax,%eax
c0102642:	83 e0 03             	and    $0x3,%eax
c0102645:	85 c0                	test   %eax,%eax
c0102647:	75 2c                	jne    c0102675 <trap_dispatch+0x16b>
            print_trapframe(tf);
c0102649:	83 ec 0c             	sub    $0xc,%esp
c010264c:	ff 75 08             	pushl  0x8(%ebp)
c010264f:	e8 4c fb ff ff       	call   c01021a0 <print_trapframe>
c0102654:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0102657:	83 ec 04             	sub    $0x4,%esp
c010265a:	68 4b 8b 10 c0       	push   $0xc0108b4b
c010265f:	68 dd 00 00 00       	push   $0xdd
c0102664:	68 ee 8a 10 c0       	push   $0xc0108aee
c0102669:	e8 7a dd ff ff       	call   c01003e8 <__panic>
        break;
c010266e:	90                   	nop
c010266f:	eb 04                	jmp    c0102675 <trap_dispatch+0x16b>
        break;
c0102671:	90                   	nop
c0102672:	eb 01                	jmp    c0102675 <trap_dispatch+0x16b>
        break;
c0102674:	90                   	nop
        }
    }
}
c0102675:	90                   	nop
c0102676:	c9                   	leave  
c0102677:	c3                   	ret    

c0102678 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102678:	55                   	push   %ebp
c0102679:	89 e5                	mov    %esp,%ebp
c010267b:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010267e:	83 ec 0c             	sub    $0xc,%esp
c0102681:	ff 75 08             	pushl  0x8(%ebp)
c0102684:	e8 81 fe ff ff       	call   c010250a <trap_dispatch>
c0102689:	83 c4 10             	add    $0x10,%esp
}
c010268c:	90                   	nop
c010268d:	c9                   	leave  
c010268e:	c3                   	ret    

c010268f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010268f:	6a 00                	push   $0x0
  pushl $0
c0102691:	6a 00                	push   $0x0
  jmp __alltraps
c0102693:	e9 67 0a 00 00       	jmp    c01030ff <__alltraps>

c0102698 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102698:	6a 00                	push   $0x0
  pushl $1
c010269a:	6a 01                	push   $0x1
  jmp __alltraps
c010269c:	e9 5e 0a 00 00       	jmp    c01030ff <__alltraps>

c01026a1 <vector2>:
.globl vector2
vector2:
  pushl $0
c01026a1:	6a 00                	push   $0x0
  pushl $2
c01026a3:	6a 02                	push   $0x2
  jmp __alltraps
c01026a5:	e9 55 0a 00 00       	jmp    c01030ff <__alltraps>

c01026aa <vector3>:
.globl vector3
vector3:
  pushl $0
c01026aa:	6a 00                	push   $0x0
  pushl $3
c01026ac:	6a 03                	push   $0x3
  jmp __alltraps
c01026ae:	e9 4c 0a 00 00       	jmp    c01030ff <__alltraps>

c01026b3 <vector4>:
.globl vector4
vector4:
  pushl $0
c01026b3:	6a 00                	push   $0x0
  pushl $4
c01026b5:	6a 04                	push   $0x4
  jmp __alltraps
c01026b7:	e9 43 0a 00 00       	jmp    c01030ff <__alltraps>

c01026bc <vector5>:
.globl vector5
vector5:
  pushl $0
c01026bc:	6a 00                	push   $0x0
  pushl $5
c01026be:	6a 05                	push   $0x5
  jmp __alltraps
c01026c0:	e9 3a 0a 00 00       	jmp    c01030ff <__alltraps>

c01026c5 <vector6>:
.globl vector6
vector6:
  pushl $0
c01026c5:	6a 00                	push   $0x0
  pushl $6
c01026c7:	6a 06                	push   $0x6
  jmp __alltraps
c01026c9:	e9 31 0a 00 00       	jmp    c01030ff <__alltraps>

c01026ce <vector7>:
.globl vector7
vector7:
  pushl $0
c01026ce:	6a 00                	push   $0x0
  pushl $7
c01026d0:	6a 07                	push   $0x7
  jmp __alltraps
c01026d2:	e9 28 0a 00 00       	jmp    c01030ff <__alltraps>

c01026d7 <vector8>:
.globl vector8
vector8:
  pushl $8
c01026d7:	6a 08                	push   $0x8
  jmp __alltraps
c01026d9:	e9 21 0a 00 00       	jmp    c01030ff <__alltraps>

c01026de <vector9>:
.globl vector9
vector9:
  pushl $9
c01026de:	6a 09                	push   $0x9
  jmp __alltraps
c01026e0:	e9 1a 0a 00 00       	jmp    c01030ff <__alltraps>

c01026e5 <vector10>:
.globl vector10
vector10:
  pushl $10
c01026e5:	6a 0a                	push   $0xa
  jmp __alltraps
c01026e7:	e9 13 0a 00 00       	jmp    c01030ff <__alltraps>

c01026ec <vector11>:
.globl vector11
vector11:
  pushl $11
c01026ec:	6a 0b                	push   $0xb
  jmp __alltraps
c01026ee:	e9 0c 0a 00 00       	jmp    c01030ff <__alltraps>

c01026f3 <vector12>:
.globl vector12
vector12:
  pushl $12
c01026f3:	6a 0c                	push   $0xc
  jmp __alltraps
c01026f5:	e9 05 0a 00 00       	jmp    c01030ff <__alltraps>

c01026fa <vector13>:
.globl vector13
vector13:
  pushl $13
c01026fa:	6a 0d                	push   $0xd
  jmp __alltraps
c01026fc:	e9 fe 09 00 00       	jmp    c01030ff <__alltraps>

c0102701 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102701:	6a 0e                	push   $0xe
  jmp __alltraps
c0102703:	e9 f7 09 00 00       	jmp    c01030ff <__alltraps>

c0102708 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102708:	6a 00                	push   $0x0
  pushl $15
c010270a:	6a 0f                	push   $0xf
  jmp __alltraps
c010270c:	e9 ee 09 00 00       	jmp    c01030ff <__alltraps>

c0102711 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102711:	6a 00                	push   $0x0
  pushl $16
c0102713:	6a 10                	push   $0x10
  jmp __alltraps
c0102715:	e9 e5 09 00 00       	jmp    c01030ff <__alltraps>

c010271a <vector17>:
.globl vector17
vector17:
  pushl $17
c010271a:	6a 11                	push   $0x11
  jmp __alltraps
c010271c:	e9 de 09 00 00       	jmp    c01030ff <__alltraps>

c0102721 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102721:	6a 00                	push   $0x0
  pushl $18
c0102723:	6a 12                	push   $0x12
  jmp __alltraps
c0102725:	e9 d5 09 00 00       	jmp    c01030ff <__alltraps>

c010272a <vector19>:
.globl vector19
vector19:
  pushl $0
c010272a:	6a 00                	push   $0x0
  pushl $19
c010272c:	6a 13                	push   $0x13
  jmp __alltraps
c010272e:	e9 cc 09 00 00       	jmp    c01030ff <__alltraps>

c0102733 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102733:	6a 00                	push   $0x0
  pushl $20
c0102735:	6a 14                	push   $0x14
  jmp __alltraps
c0102737:	e9 c3 09 00 00       	jmp    c01030ff <__alltraps>

c010273c <vector21>:
.globl vector21
vector21:
  pushl $0
c010273c:	6a 00                	push   $0x0
  pushl $21
c010273e:	6a 15                	push   $0x15
  jmp __alltraps
c0102740:	e9 ba 09 00 00       	jmp    c01030ff <__alltraps>

c0102745 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102745:	6a 00                	push   $0x0
  pushl $22
c0102747:	6a 16                	push   $0x16
  jmp __alltraps
c0102749:	e9 b1 09 00 00       	jmp    c01030ff <__alltraps>

c010274e <vector23>:
.globl vector23
vector23:
  pushl $0
c010274e:	6a 00                	push   $0x0
  pushl $23
c0102750:	6a 17                	push   $0x17
  jmp __alltraps
c0102752:	e9 a8 09 00 00       	jmp    c01030ff <__alltraps>

c0102757 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102757:	6a 00                	push   $0x0
  pushl $24
c0102759:	6a 18                	push   $0x18
  jmp __alltraps
c010275b:	e9 9f 09 00 00       	jmp    c01030ff <__alltraps>

c0102760 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102760:	6a 00                	push   $0x0
  pushl $25
c0102762:	6a 19                	push   $0x19
  jmp __alltraps
c0102764:	e9 96 09 00 00       	jmp    c01030ff <__alltraps>

c0102769 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102769:	6a 00                	push   $0x0
  pushl $26
c010276b:	6a 1a                	push   $0x1a
  jmp __alltraps
c010276d:	e9 8d 09 00 00       	jmp    c01030ff <__alltraps>

c0102772 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102772:	6a 00                	push   $0x0
  pushl $27
c0102774:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102776:	e9 84 09 00 00       	jmp    c01030ff <__alltraps>

c010277b <vector28>:
.globl vector28
vector28:
  pushl $0
c010277b:	6a 00                	push   $0x0
  pushl $28
c010277d:	6a 1c                	push   $0x1c
  jmp __alltraps
c010277f:	e9 7b 09 00 00       	jmp    c01030ff <__alltraps>

c0102784 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102784:	6a 00                	push   $0x0
  pushl $29
c0102786:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102788:	e9 72 09 00 00       	jmp    c01030ff <__alltraps>

c010278d <vector30>:
.globl vector30
vector30:
  pushl $0
c010278d:	6a 00                	push   $0x0
  pushl $30
c010278f:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102791:	e9 69 09 00 00       	jmp    c01030ff <__alltraps>

c0102796 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102796:	6a 00                	push   $0x0
  pushl $31
c0102798:	6a 1f                	push   $0x1f
  jmp __alltraps
c010279a:	e9 60 09 00 00       	jmp    c01030ff <__alltraps>

c010279f <vector32>:
.globl vector32
vector32:
  pushl $0
c010279f:	6a 00                	push   $0x0
  pushl $32
c01027a1:	6a 20                	push   $0x20
  jmp __alltraps
c01027a3:	e9 57 09 00 00       	jmp    c01030ff <__alltraps>

c01027a8 <vector33>:
.globl vector33
vector33:
  pushl $0
c01027a8:	6a 00                	push   $0x0
  pushl $33
c01027aa:	6a 21                	push   $0x21
  jmp __alltraps
c01027ac:	e9 4e 09 00 00       	jmp    c01030ff <__alltraps>

c01027b1 <vector34>:
.globl vector34
vector34:
  pushl $0
c01027b1:	6a 00                	push   $0x0
  pushl $34
c01027b3:	6a 22                	push   $0x22
  jmp __alltraps
c01027b5:	e9 45 09 00 00       	jmp    c01030ff <__alltraps>

c01027ba <vector35>:
.globl vector35
vector35:
  pushl $0
c01027ba:	6a 00                	push   $0x0
  pushl $35
c01027bc:	6a 23                	push   $0x23
  jmp __alltraps
c01027be:	e9 3c 09 00 00       	jmp    c01030ff <__alltraps>

c01027c3 <vector36>:
.globl vector36
vector36:
  pushl $0
c01027c3:	6a 00                	push   $0x0
  pushl $36
c01027c5:	6a 24                	push   $0x24
  jmp __alltraps
c01027c7:	e9 33 09 00 00       	jmp    c01030ff <__alltraps>

c01027cc <vector37>:
.globl vector37
vector37:
  pushl $0
c01027cc:	6a 00                	push   $0x0
  pushl $37
c01027ce:	6a 25                	push   $0x25
  jmp __alltraps
c01027d0:	e9 2a 09 00 00       	jmp    c01030ff <__alltraps>

c01027d5 <vector38>:
.globl vector38
vector38:
  pushl $0
c01027d5:	6a 00                	push   $0x0
  pushl $38
c01027d7:	6a 26                	push   $0x26
  jmp __alltraps
c01027d9:	e9 21 09 00 00       	jmp    c01030ff <__alltraps>

c01027de <vector39>:
.globl vector39
vector39:
  pushl $0
c01027de:	6a 00                	push   $0x0
  pushl $39
c01027e0:	6a 27                	push   $0x27
  jmp __alltraps
c01027e2:	e9 18 09 00 00       	jmp    c01030ff <__alltraps>

c01027e7 <vector40>:
.globl vector40
vector40:
  pushl $0
c01027e7:	6a 00                	push   $0x0
  pushl $40
c01027e9:	6a 28                	push   $0x28
  jmp __alltraps
c01027eb:	e9 0f 09 00 00       	jmp    c01030ff <__alltraps>

c01027f0 <vector41>:
.globl vector41
vector41:
  pushl $0
c01027f0:	6a 00                	push   $0x0
  pushl $41
c01027f2:	6a 29                	push   $0x29
  jmp __alltraps
c01027f4:	e9 06 09 00 00       	jmp    c01030ff <__alltraps>

c01027f9 <vector42>:
.globl vector42
vector42:
  pushl $0
c01027f9:	6a 00                	push   $0x0
  pushl $42
c01027fb:	6a 2a                	push   $0x2a
  jmp __alltraps
c01027fd:	e9 fd 08 00 00       	jmp    c01030ff <__alltraps>

c0102802 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102802:	6a 00                	push   $0x0
  pushl $43
c0102804:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102806:	e9 f4 08 00 00       	jmp    c01030ff <__alltraps>

c010280b <vector44>:
.globl vector44
vector44:
  pushl $0
c010280b:	6a 00                	push   $0x0
  pushl $44
c010280d:	6a 2c                	push   $0x2c
  jmp __alltraps
c010280f:	e9 eb 08 00 00       	jmp    c01030ff <__alltraps>

c0102814 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102814:	6a 00                	push   $0x0
  pushl $45
c0102816:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102818:	e9 e2 08 00 00       	jmp    c01030ff <__alltraps>

c010281d <vector46>:
.globl vector46
vector46:
  pushl $0
c010281d:	6a 00                	push   $0x0
  pushl $46
c010281f:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102821:	e9 d9 08 00 00       	jmp    c01030ff <__alltraps>

c0102826 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102826:	6a 00                	push   $0x0
  pushl $47
c0102828:	6a 2f                	push   $0x2f
  jmp __alltraps
c010282a:	e9 d0 08 00 00       	jmp    c01030ff <__alltraps>

c010282f <vector48>:
.globl vector48
vector48:
  pushl $0
c010282f:	6a 00                	push   $0x0
  pushl $48
c0102831:	6a 30                	push   $0x30
  jmp __alltraps
c0102833:	e9 c7 08 00 00       	jmp    c01030ff <__alltraps>

c0102838 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102838:	6a 00                	push   $0x0
  pushl $49
c010283a:	6a 31                	push   $0x31
  jmp __alltraps
c010283c:	e9 be 08 00 00       	jmp    c01030ff <__alltraps>

c0102841 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102841:	6a 00                	push   $0x0
  pushl $50
c0102843:	6a 32                	push   $0x32
  jmp __alltraps
c0102845:	e9 b5 08 00 00       	jmp    c01030ff <__alltraps>

c010284a <vector51>:
.globl vector51
vector51:
  pushl $0
c010284a:	6a 00                	push   $0x0
  pushl $51
c010284c:	6a 33                	push   $0x33
  jmp __alltraps
c010284e:	e9 ac 08 00 00       	jmp    c01030ff <__alltraps>

c0102853 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102853:	6a 00                	push   $0x0
  pushl $52
c0102855:	6a 34                	push   $0x34
  jmp __alltraps
c0102857:	e9 a3 08 00 00       	jmp    c01030ff <__alltraps>

c010285c <vector53>:
.globl vector53
vector53:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $53
c010285e:	6a 35                	push   $0x35
  jmp __alltraps
c0102860:	e9 9a 08 00 00       	jmp    c01030ff <__alltraps>

c0102865 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $54
c0102867:	6a 36                	push   $0x36
  jmp __alltraps
c0102869:	e9 91 08 00 00       	jmp    c01030ff <__alltraps>

c010286e <vector55>:
.globl vector55
vector55:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $55
c0102870:	6a 37                	push   $0x37
  jmp __alltraps
c0102872:	e9 88 08 00 00       	jmp    c01030ff <__alltraps>

c0102877 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102877:	6a 00                	push   $0x0
  pushl $56
c0102879:	6a 38                	push   $0x38
  jmp __alltraps
c010287b:	e9 7f 08 00 00       	jmp    c01030ff <__alltraps>

c0102880 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $57
c0102882:	6a 39                	push   $0x39
  jmp __alltraps
c0102884:	e9 76 08 00 00       	jmp    c01030ff <__alltraps>

c0102889 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $58
c010288b:	6a 3a                	push   $0x3a
  jmp __alltraps
c010288d:	e9 6d 08 00 00       	jmp    c01030ff <__alltraps>

c0102892 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $59
c0102894:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102896:	e9 64 08 00 00       	jmp    c01030ff <__alltraps>

c010289b <vector60>:
.globl vector60
vector60:
  pushl $0
c010289b:	6a 00                	push   $0x0
  pushl $60
c010289d:	6a 3c                	push   $0x3c
  jmp __alltraps
c010289f:	e9 5b 08 00 00       	jmp    c01030ff <__alltraps>

c01028a4 <vector61>:
.globl vector61
vector61:
  pushl $0
c01028a4:	6a 00                	push   $0x0
  pushl $61
c01028a6:	6a 3d                	push   $0x3d
  jmp __alltraps
c01028a8:	e9 52 08 00 00       	jmp    c01030ff <__alltraps>

c01028ad <vector62>:
.globl vector62
vector62:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $62
c01028af:	6a 3e                	push   $0x3e
  jmp __alltraps
c01028b1:	e9 49 08 00 00       	jmp    c01030ff <__alltraps>

c01028b6 <vector63>:
.globl vector63
vector63:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $63
c01028b8:	6a 3f                	push   $0x3f
  jmp __alltraps
c01028ba:	e9 40 08 00 00       	jmp    c01030ff <__alltraps>

c01028bf <vector64>:
.globl vector64
vector64:
  pushl $0
c01028bf:	6a 00                	push   $0x0
  pushl $64
c01028c1:	6a 40                	push   $0x40
  jmp __alltraps
c01028c3:	e9 37 08 00 00       	jmp    c01030ff <__alltraps>

c01028c8 <vector65>:
.globl vector65
vector65:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $65
c01028ca:	6a 41                	push   $0x41
  jmp __alltraps
c01028cc:	e9 2e 08 00 00       	jmp    c01030ff <__alltraps>

c01028d1 <vector66>:
.globl vector66
vector66:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $66
c01028d3:	6a 42                	push   $0x42
  jmp __alltraps
c01028d5:	e9 25 08 00 00       	jmp    c01030ff <__alltraps>

c01028da <vector67>:
.globl vector67
vector67:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $67
c01028dc:	6a 43                	push   $0x43
  jmp __alltraps
c01028de:	e9 1c 08 00 00       	jmp    c01030ff <__alltraps>

c01028e3 <vector68>:
.globl vector68
vector68:
  pushl $0
c01028e3:	6a 00                	push   $0x0
  pushl $68
c01028e5:	6a 44                	push   $0x44
  jmp __alltraps
c01028e7:	e9 13 08 00 00       	jmp    c01030ff <__alltraps>

c01028ec <vector69>:
.globl vector69
vector69:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $69
c01028ee:	6a 45                	push   $0x45
  jmp __alltraps
c01028f0:	e9 0a 08 00 00       	jmp    c01030ff <__alltraps>

c01028f5 <vector70>:
.globl vector70
vector70:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $70
c01028f7:	6a 46                	push   $0x46
  jmp __alltraps
c01028f9:	e9 01 08 00 00       	jmp    c01030ff <__alltraps>

c01028fe <vector71>:
.globl vector71
vector71:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $71
c0102900:	6a 47                	push   $0x47
  jmp __alltraps
c0102902:	e9 f8 07 00 00       	jmp    c01030ff <__alltraps>

c0102907 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102907:	6a 00                	push   $0x0
  pushl $72
c0102909:	6a 48                	push   $0x48
  jmp __alltraps
c010290b:	e9 ef 07 00 00       	jmp    c01030ff <__alltraps>

c0102910 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $73
c0102912:	6a 49                	push   $0x49
  jmp __alltraps
c0102914:	e9 e6 07 00 00       	jmp    c01030ff <__alltraps>

c0102919 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $74
c010291b:	6a 4a                	push   $0x4a
  jmp __alltraps
c010291d:	e9 dd 07 00 00       	jmp    c01030ff <__alltraps>

c0102922 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $75
c0102924:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102926:	e9 d4 07 00 00       	jmp    c01030ff <__alltraps>

c010292b <vector76>:
.globl vector76
vector76:
  pushl $0
c010292b:	6a 00                	push   $0x0
  pushl $76
c010292d:	6a 4c                	push   $0x4c
  jmp __alltraps
c010292f:	e9 cb 07 00 00       	jmp    c01030ff <__alltraps>

c0102934 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $77
c0102936:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102938:	e9 c2 07 00 00       	jmp    c01030ff <__alltraps>

c010293d <vector78>:
.globl vector78
vector78:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $78
c010293f:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102941:	e9 b9 07 00 00       	jmp    c01030ff <__alltraps>

c0102946 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $79
c0102948:	6a 4f                	push   $0x4f
  jmp __alltraps
c010294a:	e9 b0 07 00 00       	jmp    c01030ff <__alltraps>

c010294f <vector80>:
.globl vector80
vector80:
  pushl $0
c010294f:	6a 00                	push   $0x0
  pushl $80
c0102951:	6a 50                	push   $0x50
  jmp __alltraps
c0102953:	e9 a7 07 00 00       	jmp    c01030ff <__alltraps>

c0102958 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $81
c010295a:	6a 51                	push   $0x51
  jmp __alltraps
c010295c:	e9 9e 07 00 00       	jmp    c01030ff <__alltraps>

c0102961 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $82
c0102963:	6a 52                	push   $0x52
  jmp __alltraps
c0102965:	e9 95 07 00 00       	jmp    c01030ff <__alltraps>

c010296a <vector83>:
.globl vector83
vector83:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $83
c010296c:	6a 53                	push   $0x53
  jmp __alltraps
c010296e:	e9 8c 07 00 00       	jmp    c01030ff <__alltraps>

c0102973 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102973:	6a 00                	push   $0x0
  pushl $84
c0102975:	6a 54                	push   $0x54
  jmp __alltraps
c0102977:	e9 83 07 00 00       	jmp    c01030ff <__alltraps>

c010297c <vector85>:
.globl vector85
vector85:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $85
c010297e:	6a 55                	push   $0x55
  jmp __alltraps
c0102980:	e9 7a 07 00 00       	jmp    c01030ff <__alltraps>

c0102985 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $86
c0102987:	6a 56                	push   $0x56
  jmp __alltraps
c0102989:	e9 71 07 00 00       	jmp    c01030ff <__alltraps>

c010298e <vector87>:
.globl vector87
vector87:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $87
c0102990:	6a 57                	push   $0x57
  jmp __alltraps
c0102992:	e9 68 07 00 00       	jmp    c01030ff <__alltraps>

c0102997 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102997:	6a 00                	push   $0x0
  pushl $88
c0102999:	6a 58                	push   $0x58
  jmp __alltraps
c010299b:	e9 5f 07 00 00       	jmp    c01030ff <__alltraps>

c01029a0 <vector89>:
.globl vector89
vector89:
  pushl $0
c01029a0:	6a 00                	push   $0x0
  pushl $89
c01029a2:	6a 59                	push   $0x59
  jmp __alltraps
c01029a4:	e9 56 07 00 00       	jmp    c01030ff <__alltraps>

c01029a9 <vector90>:
.globl vector90
vector90:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $90
c01029ab:	6a 5a                	push   $0x5a
  jmp __alltraps
c01029ad:	e9 4d 07 00 00       	jmp    c01030ff <__alltraps>

c01029b2 <vector91>:
.globl vector91
vector91:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $91
c01029b4:	6a 5b                	push   $0x5b
  jmp __alltraps
c01029b6:	e9 44 07 00 00       	jmp    c01030ff <__alltraps>

c01029bb <vector92>:
.globl vector92
vector92:
  pushl $0
c01029bb:	6a 00                	push   $0x0
  pushl $92
c01029bd:	6a 5c                	push   $0x5c
  jmp __alltraps
c01029bf:	e9 3b 07 00 00       	jmp    c01030ff <__alltraps>

c01029c4 <vector93>:
.globl vector93
vector93:
  pushl $0
c01029c4:	6a 00                	push   $0x0
  pushl $93
c01029c6:	6a 5d                	push   $0x5d
  jmp __alltraps
c01029c8:	e9 32 07 00 00       	jmp    c01030ff <__alltraps>

c01029cd <vector94>:
.globl vector94
vector94:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $94
c01029cf:	6a 5e                	push   $0x5e
  jmp __alltraps
c01029d1:	e9 29 07 00 00       	jmp    c01030ff <__alltraps>

c01029d6 <vector95>:
.globl vector95
vector95:
  pushl $0
c01029d6:	6a 00                	push   $0x0
  pushl $95
c01029d8:	6a 5f                	push   $0x5f
  jmp __alltraps
c01029da:	e9 20 07 00 00       	jmp    c01030ff <__alltraps>

c01029df <vector96>:
.globl vector96
vector96:
  pushl $0
c01029df:	6a 00                	push   $0x0
  pushl $96
c01029e1:	6a 60                	push   $0x60
  jmp __alltraps
c01029e3:	e9 17 07 00 00       	jmp    c01030ff <__alltraps>

c01029e8 <vector97>:
.globl vector97
vector97:
  pushl $0
c01029e8:	6a 00                	push   $0x0
  pushl $97
c01029ea:	6a 61                	push   $0x61
  jmp __alltraps
c01029ec:	e9 0e 07 00 00       	jmp    c01030ff <__alltraps>

c01029f1 <vector98>:
.globl vector98
vector98:
  pushl $0
c01029f1:	6a 00                	push   $0x0
  pushl $98
c01029f3:	6a 62                	push   $0x62
  jmp __alltraps
c01029f5:	e9 05 07 00 00       	jmp    c01030ff <__alltraps>

c01029fa <vector99>:
.globl vector99
vector99:
  pushl $0
c01029fa:	6a 00                	push   $0x0
  pushl $99
c01029fc:	6a 63                	push   $0x63
  jmp __alltraps
c01029fe:	e9 fc 06 00 00       	jmp    c01030ff <__alltraps>

c0102a03 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102a03:	6a 00                	push   $0x0
  pushl $100
c0102a05:	6a 64                	push   $0x64
  jmp __alltraps
c0102a07:	e9 f3 06 00 00       	jmp    c01030ff <__alltraps>

c0102a0c <vector101>:
.globl vector101
vector101:
  pushl $0
c0102a0c:	6a 00                	push   $0x0
  pushl $101
c0102a0e:	6a 65                	push   $0x65
  jmp __alltraps
c0102a10:	e9 ea 06 00 00       	jmp    c01030ff <__alltraps>

c0102a15 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102a15:	6a 00                	push   $0x0
  pushl $102
c0102a17:	6a 66                	push   $0x66
  jmp __alltraps
c0102a19:	e9 e1 06 00 00       	jmp    c01030ff <__alltraps>

c0102a1e <vector103>:
.globl vector103
vector103:
  pushl $0
c0102a1e:	6a 00                	push   $0x0
  pushl $103
c0102a20:	6a 67                	push   $0x67
  jmp __alltraps
c0102a22:	e9 d8 06 00 00       	jmp    c01030ff <__alltraps>

c0102a27 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102a27:	6a 00                	push   $0x0
  pushl $104
c0102a29:	6a 68                	push   $0x68
  jmp __alltraps
c0102a2b:	e9 cf 06 00 00       	jmp    c01030ff <__alltraps>

c0102a30 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102a30:	6a 00                	push   $0x0
  pushl $105
c0102a32:	6a 69                	push   $0x69
  jmp __alltraps
c0102a34:	e9 c6 06 00 00       	jmp    c01030ff <__alltraps>

c0102a39 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $106
c0102a3b:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102a3d:	e9 bd 06 00 00       	jmp    c01030ff <__alltraps>

c0102a42 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $107
c0102a44:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102a46:	e9 b4 06 00 00       	jmp    c01030ff <__alltraps>

c0102a4b <vector108>:
.globl vector108
vector108:
  pushl $0
c0102a4b:	6a 00                	push   $0x0
  pushl $108
c0102a4d:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102a4f:	e9 ab 06 00 00       	jmp    c01030ff <__alltraps>

c0102a54 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $109
c0102a56:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102a58:	e9 a2 06 00 00       	jmp    c01030ff <__alltraps>

c0102a5d <vector110>:
.globl vector110
vector110:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $110
c0102a5f:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102a61:	e9 99 06 00 00       	jmp    c01030ff <__alltraps>

c0102a66 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $111
c0102a68:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102a6a:	e9 90 06 00 00       	jmp    c01030ff <__alltraps>

c0102a6f <vector112>:
.globl vector112
vector112:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $112
c0102a71:	6a 70                	push   $0x70
  jmp __alltraps
c0102a73:	e9 87 06 00 00       	jmp    c01030ff <__alltraps>

c0102a78 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $113
c0102a7a:	6a 71                	push   $0x71
  jmp __alltraps
c0102a7c:	e9 7e 06 00 00       	jmp    c01030ff <__alltraps>

c0102a81 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $114
c0102a83:	6a 72                	push   $0x72
  jmp __alltraps
c0102a85:	e9 75 06 00 00       	jmp    c01030ff <__alltraps>

c0102a8a <vector115>:
.globl vector115
vector115:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $115
c0102a8c:	6a 73                	push   $0x73
  jmp __alltraps
c0102a8e:	e9 6c 06 00 00       	jmp    c01030ff <__alltraps>

c0102a93 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102a93:	6a 00                	push   $0x0
  pushl $116
c0102a95:	6a 74                	push   $0x74
  jmp __alltraps
c0102a97:	e9 63 06 00 00       	jmp    c01030ff <__alltraps>

c0102a9c <vector117>:
.globl vector117
vector117:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $117
c0102a9e:	6a 75                	push   $0x75
  jmp __alltraps
c0102aa0:	e9 5a 06 00 00       	jmp    c01030ff <__alltraps>

c0102aa5 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102aa5:	6a 00                	push   $0x0
  pushl $118
c0102aa7:	6a 76                	push   $0x76
  jmp __alltraps
c0102aa9:	e9 51 06 00 00       	jmp    c01030ff <__alltraps>

c0102aae <vector119>:
.globl vector119
vector119:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $119
c0102ab0:	6a 77                	push   $0x77
  jmp __alltraps
c0102ab2:	e9 48 06 00 00       	jmp    c01030ff <__alltraps>

c0102ab7 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ab7:	6a 00                	push   $0x0
  pushl $120
c0102ab9:	6a 78                	push   $0x78
  jmp __alltraps
c0102abb:	e9 3f 06 00 00       	jmp    c01030ff <__alltraps>

c0102ac0 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $121
c0102ac2:	6a 79                	push   $0x79
  jmp __alltraps
c0102ac4:	e9 36 06 00 00       	jmp    c01030ff <__alltraps>

c0102ac9 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ac9:	6a 00                	push   $0x0
  pushl $122
c0102acb:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102acd:	e9 2d 06 00 00       	jmp    c01030ff <__alltraps>

c0102ad2 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $123
c0102ad4:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ad6:	e9 24 06 00 00       	jmp    c01030ff <__alltraps>

c0102adb <vector124>:
.globl vector124
vector124:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $124
c0102add:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102adf:	e9 1b 06 00 00       	jmp    c01030ff <__alltraps>

c0102ae4 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $125
c0102ae6:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ae8:	e9 12 06 00 00       	jmp    c01030ff <__alltraps>

c0102aed <vector126>:
.globl vector126
vector126:
  pushl $0
c0102aed:	6a 00                	push   $0x0
  pushl $126
c0102aef:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102af1:	e9 09 06 00 00       	jmp    c01030ff <__alltraps>

c0102af6 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $127
c0102af8:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102afa:	e9 00 06 00 00       	jmp    c01030ff <__alltraps>

c0102aff <vector128>:
.globl vector128
vector128:
  pushl $0
c0102aff:	6a 00                	push   $0x0
  pushl $128
c0102b01:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102b06:	e9 f4 05 00 00       	jmp    c01030ff <__alltraps>

c0102b0b <vector129>:
.globl vector129
vector129:
  pushl $0
c0102b0b:	6a 00                	push   $0x0
  pushl $129
c0102b0d:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102b12:	e9 e8 05 00 00       	jmp    c01030ff <__alltraps>

c0102b17 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102b17:	6a 00                	push   $0x0
  pushl $130
c0102b19:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102b1e:	e9 dc 05 00 00       	jmp    c01030ff <__alltraps>

c0102b23 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102b23:	6a 00                	push   $0x0
  pushl $131
c0102b25:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102b2a:	e9 d0 05 00 00       	jmp    c01030ff <__alltraps>

c0102b2f <vector132>:
.globl vector132
vector132:
  pushl $0
c0102b2f:	6a 00                	push   $0x0
  pushl $132
c0102b31:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102b36:	e9 c4 05 00 00       	jmp    c01030ff <__alltraps>

c0102b3b <vector133>:
.globl vector133
vector133:
  pushl $0
c0102b3b:	6a 00                	push   $0x0
  pushl $133
c0102b3d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102b42:	e9 b8 05 00 00       	jmp    c01030ff <__alltraps>

c0102b47 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102b47:	6a 00                	push   $0x0
  pushl $134
c0102b49:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102b4e:	e9 ac 05 00 00       	jmp    c01030ff <__alltraps>

c0102b53 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102b53:	6a 00                	push   $0x0
  pushl $135
c0102b55:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102b5a:	e9 a0 05 00 00       	jmp    c01030ff <__alltraps>

c0102b5f <vector136>:
.globl vector136
vector136:
  pushl $0
c0102b5f:	6a 00                	push   $0x0
  pushl $136
c0102b61:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102b66:	e9 94 05 00 00       	jmp    c01030ff <__alltraps>

c0102b6b <vector137>:
.globl vector137
vector137:
  pushl $0
c0102b6b:	6a 00                	push   $0x0
  pushl $137
c0102b6d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102b72:	e9 88 05 00 00       	jmp    c01030ff <__alltraps>

c0102b77 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102b77:	6a 00                	push   $0x0
  pushl $138
c0102b79:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102b7e:	e9 7c 05 00 00       	jmp    c01030ff <__alltraps>

c0102b83 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102b83:	6a 00                	push   $0x0
  pushl $139
c0102b85:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102b8a:	e9 70 05 00 00       	jmp    c01030ff <__alltraps>

c0102b8f <vector140>:
.globl vector140
vector140:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $140
c0102b91:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102b96:	e9 64 05 00 00       	jmp    c01030ff <__alltraps>

c0102b9b <vector141>:
.globl vector141
vector141:
  pushl $0
c0102b9b:	6a 00                	push   $0x0
  pushl $141
c0102b9d:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102ba2:	e9 58 05 00 00       	jmp    c01030ff <__alltraps>

c0102ba7 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102ba7:	6a 00                	push   $0x0
  pushl $142
c0102ba9:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102bae:	e9 4c 05 00 00       	jmp    c01030ff <__alltraps>

c0102bb3 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $143
c0102bb5:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102bba:	e9 40 05 00 00       	jmp    c01030ff <__alltraps>

c0102bbf <vector144>:
.globl vector144
vector144:
  pushl $0
c0102bbf:	6a 00                	push   $0x0
  pushl $144
c0102bc1:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102bc6:	e9 34 05 00 00       	jmp    c01030ff <__alltraps>

c0102bcb <vector145>:
.globl vector145
vector145:
  pushl $0
c0102bcb:	6a 00                	push   $0x0
  pushl $145
c0102bcd:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102bd2:	e9 28 05 00 00       	jmp    c01030ff <__alltraps>

c0102bd7 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102bd7:	6a 00                	push   $0x0
  pushl $146
c0102bd9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102bde:	e9 1c 05 00 00       	jmp    c01030ff <__alltraps>

c0102be3 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102be3:	6a 00                	push   $0x0
  pushl $147
c0102be5:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102bea:	e9 10 05 00 00       	jmp    c01030ff <__alltraps>

c0102bef <vector148>:
.globl vector148
vector148:
  pushl $0
c0102bef:	6a 00                	push   $0x0
  pushl $148
c0102bf1:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102bf6:	e9 04 05 00 00       	jmp    c01030ff <__alltraps>

c0102bfb <vector149>:
.globl vector149
vector149:
  pushl $0
c0102bfb:	6a 00                	push   $0x0
  pushl $149
c0102bfd:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102c02:	e9 f8 04 00 00       	jmp    c01030ff <__alltraps>

c0102c07 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102c07:	6a 00                	push   $0x0
  pushl $150
c0102c09:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102c0e:	e9 ec 04 00 00       	jmp    c01030ff <__alltraps>

c0102c13 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102c13:	6a 00                	push   $0x0
  pushl $151
c0102c15:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102c1a:	e9 e0 04 00 00       	jmp    c01030ff <__alltraps>

c0102c1f <vector152>:
.globl vector152
vector152:
  pushl $0
c0102c1f:	6a 00                	push   $0x0
  pushl $152
c0102c21:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102c26:	e9 d4 04 00 00       	jmp    c01030ff <__alltraps>

c0102c2b <vector153>:
.globl vector153
vector153:
  pushl $0
c0102c2b:	6a 00                	push   $0x0
  pushl $153
c0102c2d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102c32:	e9 c8 04 00 00       	jmp    c01030ff <__alltraps>

c0102c37 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102c37:	6a 00                	push   $0x0
  pushl $154
c0102c39:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102c3e:	e9 bc 04 00 00       	jmp    c01030ff <__alltraps>

c0102c43 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102c43:	6a 00                	push   $0x0
  pushl $155
c0102c45:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102c4a:	e9 b0 04 00 00       	jmp    c01030ff <__alltraps>

c0102c4f <vector156>:
.globl vector156
vector156:
  pushl $0
c0102c4f:	6a 00                	push   $0x0
  pushl $156
c0102c51:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102c56:	e9 a4 04 00 00       	jmp    c01030ff <__alltraps>

c0102c5b <vector157>:
.globl vector157
vector157:
  pushl $0
c0102c5b:	6a 00                	push   $0x0
  pushl $157
c0102c5d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102c62:	e9 98 04 00 00       	jmp    c01030ff <__alltraps>

c0102c67 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102c67:	6a 00                	push   $0x0
  pushl $158
c0102c69:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102c6e:	e9 8c 04 00 00       	jmp    c01030ff <__alltraps>

c0102c73 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102c73:	6a 00                	push   $0x0
  pushl $159
c0102c75:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102c7a:	e9 80 04 00 00       	jmp    c01030ff <__alltraps>

c0102c7f <vector160>:
.globl vector160
vector160:
  pushl $0
c0102c7f:	6a 00                	push   $0x0
  pushl $160
c0102c81:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102c86:	e9 74 04 00 00       	jmp    c01030ff <__alltraps>

c0102c8b <vector161>:
.globl vector161
vector161:
  pushl $0
c0102c8b:	6a 00                	push   $0x0
  pushl $161
c0102c8d:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102c92:	e9 68 04 00 00       	jmp    c01030ff <__alltraps>

c0102c97 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102c97:	6a 00                	push   $0x0
  pushl $162
c0102c99:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102c9e:	e9 5c 04 00 00       	jmp    c01030ff <__alltraps>

c0102ca3 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102ca3:	6a 00                	push   $0x0
  pushl $163
c0102ca5:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102caa:	e9 50 04 00 00       	jmp    c01030ff <__alltraps>

c0102caf <vector164>:
.globl vector164
vector164:
  pushl $0
c0102caf:	6a 00                	push   $0x0
  pushl $164
c0102cb1:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102cb6:	e9 44 04 00 00       	jmp    c01030ff <__alltraps>

c0102cbb <vector165>:
.globl vector165
vector165:
  pushl $0
c0102cbb:	6a 00                	push   $0x0
  pushl $165
c0102cbd:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102cc2:	e9 38 04 00 00       	jmp    c01030ff <__alltraps>

c0102cc7 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102cc7:	6a 00                	push   $0x0
  pushl $166
c0102cc9:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102cce:	e9 2c 04 00 00       	jmp    c01030ff <__alltraps>

c0102cd3 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102cd3:	6a 00                	push   $0x0
  pushl $167
c0102cd5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102cda:	e9 20 04 00 00       	jmp    c01030ff <__alltraps>

c0102cdf <vector168>:
.globl vector168
vector168:
  pushl $0
c0102cdf:	6a 00                	push   $0x0
  pushl $168
c0102ce1:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102ce6:	e9 14 04 00 00       	jmp    c01030ff <__alltraps>

c0102ceb <vector169>:
.globl vector169
vector169:
  pushl $0
c0102ceb:	6a 00                	push   $0x0
  pushl $169
c0102ced:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102cf2:	e9 08 04 00 00       	jmp    c01030ff <__alltraps>

c0102cf7 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102cf7:	6a 00                	push   $0x0
  pushl $170
c0102cf9:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102cfe:	e9 fc 03 00 00       	jmp    c01030ff <__alltraps>

c0102d03 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102d03:	6a 00                	push   $0x0
  pushl $171
c0102d05:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102d0a:	e9 f0 03 00 00       	jmp    c01030ff <__alltraps>

c0102d0f <vector172>:
.globl vector172
vector172:
  pushl $0
c0102d0f:	6a 00                	push   $0x0
  pushl $172
c0102d11:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102d16:	e9 e4 03 00 00       	jmp    c01030ff <__alltraps>

c0102d1b <vector173>:
.globl vector173
vector173:
  pushl $0
c0102d1b:	6a 00                	push   $0x0
  pushl $173
c0102d1d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102d22:	e9 d8 03 00 00       	jmp    c01030ff <__alltraps>

c0102d27 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102d27:	6a 00                	push   $0x0
  pushl $174
c0102d29:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102d2e:	e9 cc 03 00 00       	jmp    c01030ff <__alltraps>

c0102d33 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102d33:	6a 00                	push   $0x0
  pushl $175
c0102d35:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102d3a:	e9 c0 03 00 00       	jmp    c01030ff <__alltraps>

c0102d3f <vector176>:
.globl vector176
vector176:
  pushl $0
c0102d3f:	6a 00                	push   $0x0
  pushl $176
c0102d41:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102d46:	e9 b4 03 00 00       	jmp    c01030ff <__alltraps>

c0102d4b <vector177>:
.globl vector177
vector177:
  pushl $0
c0102d4b:	6a 00                	push   $0x0
  pushl $177
c0102d4d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102d52:	e9 a8 03 00 00       	jmp    c01030ff <__alltraps>

c0102d57 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102d57:	6a 00                	push   $0x0
  pushl $178
c0102d59:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102d5e:	e9 9c 03 00 00       	jmp    c01030ff <__alltraps>

c0102d63 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102d63:	6a 00                	push   $0x0
  pushl $179
c0102d65:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102d6a:	e9 90 03 00 00       	jmp    c01030ff <__alltraps>

c0102d6f <vector180>:
.globl vector180
vector180:
  pushl $0
c0102d6f:	6a 00                	push   $0x0
  pushl $180
c0102d71:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102d76:	e9 84 03 00 00       	jmp    c01030ff <__alltraps>

c0102d7b <vector181>:
.globl vector181
vector181:
  pushl $0
c0102d7b:	6a 00                	push   $0x0
  pushl $181
c0102d7d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102d82:	e9 78 03 00 00       	jmp    c01030ff <__alltraps>

c0102d87 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102d87:	6a 00                	push   $0x0
  pushl $182
c0102d89:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102d8e:	e9 6c 03 00 00       	jmp    c01030ff <__alltraps>

c0102d93 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102d93:	6a 00                	push   $0x0
  pushl $183
c0102d95:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102d9a:	e9 60 03 00 00       	jmp    c01030ff <__alltraps>

c0102d9f <vector184>:
.globl vector184
vector184:
  pushl $0
c0102d9f:	6a 00                	push   $0x0
  pushl $184
c0102da1:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102da6:	e9 54 03 00 00       	jmp    c01030ff <__alltraps>

c0102dab <vector185>:
.globl vector185
vector185:
  pushl $0
c0102dab:	6a 00                	push   $0x0
  pushl $185
c0102dad:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102db2:	e9 48 03 00 00       	jmp    c01030ff <__alltraps>

c0102db7 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102db7:	6a 00                	push   $0x0
  pushl $186
c0102db9:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102dbe:	e9 3c 03 00 00       	jmp    c01030ff <__alltraps>

c0102dc3 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102dc3:	6a 00                	push   $0x0
  pushl $187
c0102dc5:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102dca:	e9 30 03 00 00       	jmp    c01030ff <__alltraps>

c0102dcf <vector188>:
.globl vector188
vector188:
  pushl $0
c0102dcf:	6a 00                	push   $0x0
  pushl $188
c0102dd1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102dd6:	e9 24 03 00 00       	jmp    c01030ff <__alltraps>

c0102ddb <vector189>:
.globl vector189
vector189:
  pushl $0
c0102ddb:	6a 00                	push   $0x0
  pushl $189
c0102ddd:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102de2:	e9 18 03 00 00       	jmp    c01030ff <__alltraps>

c0102de7 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102de7:	6a 00                	push   $0x0
  pushl $190
c0102de9:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102dee:	e9 0c 03 00 00       	jmp    c01030ff <__alltraps>

c0102df3 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102df3:	6a 00                	push   $0x0
  pushl $191
c0102df5:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102dfa:	e9 00 03 00 00       	jmp    c01030ff <__alltraps>

c0102dff <vector192>:
.globl vector192
vector192:
  pushl $0
c0102dff:	6a 00                	push   $0x0
  pushl $192
c0102e01:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102e06:	e9 f4 02 00 00       	jmp    c01030ff <__alltraps>

c0102e0b <vector193>:
.globl vector193
vector193:
  pushl $0
c0102e0b:	6a 00                	push   $0x0
  pushl $193
c0102e0d:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102e12:	e9 e8 02 00 00       	jmp    c01030ff <__alltraps>

c0102e17 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102e17:	6a 00                	push   $0x0
  pushl $194
c0102e19:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102e1e:	e9 dc 02 00 00       	jmp    c01030ff <__alltraps>

c0102e23 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102e23:	6a 00                	push   $0x0
  pushl $195
c0102e25:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102e2a:	e9 d0 02 00 00       	jmp    c01030ff <__alltraps>

c0102e2f <vector196>:
.globl vector196
vector196:
  pushl $0
c0102e2f:	6a 00                	push   $0x0
  pushl $196
c0102e31:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102e36:	e9 c4 02 00 00       	jmp    c01030ff <__alltraps>

c0102e3b <vector197>:
.globl vector197
vector197:
  pushl $0
c0102e3b:	6a 00                	push   $0x0
  pushl $197
c0102e3d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102e42:	e9 b8 02 00 00       	jmp    c01030ff <__alltraps>

c0102e47 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102e47:	6a 00                	push   $0x0
  pushl $198
c0102e49:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102e4e:	e9 ac 02 00 00       	jmp    c01030ff <__alltraps>

c0102e53 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102e53:	6a 00                	push   $0x0
  pushl $199
c0102e55:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102e5a:	e9 a0 02 00 00       	jmp    c01030ff <__alltraps>

c0102e5f <vector200>:
.globl vector200
vector200:
  pushl $0
c0102e5f:	6a 00                	push   $0x0
  pushl $200
c0102e61:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102e66:	e9 94 02 00 00       	jmp    c01030ff <__alltraps>

c0102e6b <vector201>:
.globl vector201
vector201:
  pushl $0
c0102e6b:	6a 00                	push   $0x0
  pushl $201
c0102e6d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102e72:	e9 88 02 00 00       	jmp    c01030ff <__alltraps>

c0102e77 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102e77:	6a 00                	push   $0x0
  pushl $202
c0102e79:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102e7e:	e9 7c 02 00 00       	jmp    c01030ff <__alltraps>

c0102e83 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102e83:	6a 00                	push   $0x0
  pushl $203
c0102e85:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102e8a:	e9 70 02 00 00       	jmp    c01030ff <__alltraps>

c0102e8f <vector204>:
.globl vector204
vector204:
  pushl $0
c0102e8f:	6a 00                	push   $0x0
  pushl $204
c0102e91:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102e96:	e9 64 02 00 00       	jmp    c01030ff <__alltraps>

c0102e9b <vector205>:
.globl vector205
vector205:
  pushl $0
c0102e9b:	6a 00                	push   $0x0
  pushl $205
c0102e9d:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102ea2:	e9 58 02 00 00       	jmp    c01030ff <__alltraps>

c0102ea7 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102ea7:	6a 00                	push   $0x0
  pushl $206
c0102ea9:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102eae:	e9 4c 02 00 00       	jmp    c01030ff <__alltraps>

c0102eb3 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102eb3:	6a 00                	push   $0x0
  pushl $207
c0102eb5:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102eba:	e9 40 02 00 00       	jmp    c01030ff <__alltraps>

c0102ebf <vector208>:
.globl vector208
vector208:
  pushl $0
c0102ebf:	6a 00                	push   $0x0
  pushl $208
c0102ec1:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102ec6:	e9 34 02 00 00       	jmp    c01030ff <__alltraps>

c0102ecb <vector209>:
.globl vector209
vector209:
  pushl $0
c0102ecb:	6a 00                	push   $0x0
  pushl $209
c0102ecd:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102ed2:	e9 28 02 00 00       	jmp    c01030ff <__alltraps>

c0102ed7 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102ed7:	6a 00                	push   $0x0
  pushl $210
c0102ed9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102ede:	e9 1c 02 00 00       	jmp    c01030ff <__alltraps>

c0102ee3 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102ee3:	6a 00                	push   $0x0
  pushl $211
c0102ee5:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102eea:	e9 10 02 00 00       	jmp    c01030ff <__alltraps>

c0102eef <vector212>:
.globl vector212
vector212:
  pushl $0
c0102eef:	6a 00                	push   $0x0
  pushl $212
c0102ef1:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102ef6:	e9 04 02 00 00       	jmp    c01030ff <__alltraps>

c0102efb <vector213>:
.globl vector213
vector213:
  pushl $0
c0102efb:	6a 00                	push   $0x0
  pushl $213
c0102efd:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102f02:	e9 f8 01 00 00       	jmp    c01030ff <__alltraps>

c0102f07 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102f07:	6a 00                	push   $0x0
  pushl $214
c0102f09:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102f0e:	e9 ec 01 00 00       	jmp    c01030ff <__alltraps>

c0102f13 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102f13:	6a 00                	push   $0x0
  pushl $215
c0102f15:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102f1a:	e9 e0 01 00 00       	jmp    c01030ff <__alltraps>

c0102f1f <vector216>:
.globl vector216
vector216:
  pushl $0
c0102f1f:	6a 00                	push   $0x0
  pushl $216
c0102f21:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102f26:	e9 d4 01 00 00       	jmp    c01030ff <__alltraps>

c0102f2b <vector217>:
.globl vector217
vector217:
  pushl $0
c0102f2b:	6a 00                	push   $0x0
  pushl $217
c0102f2d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102f32:	e9 c8 01 00 00       	jmp    c01030ff <__alltraps>

c0102f37 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102f37:	6a 00                	push   $0x0
  pushl $218
c0102f39:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102f3e:	e9 bc 01 00 00       	jmp    c01030ff <__alltraps>

c0102f43 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102f43:	6a 00                	push   $0x0
  pushl $219
c0102f45:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102f4a:	e9 b0 01 00 00       	jmp    c01030ff <__alltraps>

c0102f4f <vector220>:
.globl vector220
vector220:
  pushl $0
c0102f4f:	6a 00                	push   $0x0
  pushl $220
c0102f51:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102f56:	e9 a4 01 00 00       	jmp    c01030ff <__alltraps>

c0102f5b <vector221>:
.globl vector221
vector221:
  pushl $0
c0102f5b:	6a 00                	push   $0x0
  pushl $221
c0102f5d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102f62:	e9 98 01 00 00       	jmp    c01030ff <__alltraps>

c0102f67 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102f67:	6a 00                	push   $0x0
  pushl $222
c0102f69:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102f6e:	e9 8c 01 00 00       	jmp    c01030ff <__alltraps>

c0102f73 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102f73:	6a 00                	push   $0x0
  pushl $223
c0102f75:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102f7a:	e9 80 01 00 00       	jmp    c01030ff <__alltraps>

c0102f7f <vector224>:
.globl vector224
vector224:
  pushl $0
c0102f7f:	6a 00                	push   $0x0
  pushl $224
c0102f81:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102f86:	e9 74 01 00 00       	jmp    c01030ff <__alltraps>

c0102f8b <vector225>:
.globl vector225
vector225:
  pushl $0
c0102f8b:	6a 00                	push   $0x0
  pushl $225
c0102f8d:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102f92:	e9 68 01 00 00       	jmp    c01030ff <__alltraps>

c0102f97 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102f97:	6a 00                	push   $0x0
  pushl $226
c0102f99:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102f9e:	e9 5c 01 00 00       	jmp    c01030ff <__alltraps>

c0102fa3 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102fa3:	6a 00                	push   $0x0
  pushl $227
c0102fa5:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102faa:	e9 50 01 00 00       	jmp    c01030ff <__alltraps>

c0102faf <vector228>:
.globl vector228
vector228:
  pushl $0
c0102faf:	6a 00                	push   $0x0
  pushl $228
c0102fb1:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102fb6:	e9 44 01 00 00       	jmp    c01030ff <__alltraps>

c0102fbb <vector229>:
.globl vector229
vector229:
  pushl $0
c0102fbb:	6a 00                	push   $0x0
  pushl $229
c0102fbd:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102fc2:	e9 38 01 00 00       	jmp    c01030ff <__alltraps>

c0102fc7 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102fc7:	6a 00                	push   $0x0
  pushl $230
c0102fc9:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102fce:	e9 2c 01 00 00       	jmp    c01030ff <__alltraps>

c0102fd3 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102fd3:	6a 00                	push   $0x0
  pushl $231
c0102fd5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102fda:	e9 20 01 00 00       	jmp    c01030ff <__alltraps>

c0102fdf <vector232>:
.globl vector232
vector232:
  pushl $0
c0102fdf:	6a 00                	push   $0x0
  pushl $232
c0102fe1:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102fe6:	e9 14 01 00 00       	jmp    c01030ff <__alltraps>

c0102feb <vector233>:
.globl vector233
vector233:
  pushl $0
c0102feb:	6a 00                	push   $0x0
  pushl $233
c0102fed:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102ff2:	e9 08 01 00 00       	jmp    c01030ff <__alltraps>

c0102ff7 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102ff7:	6a 00                	push   $0x0
  pushl $234
c0102ff9:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102ffe:	e9 fc 00 00 00       	jmp    c01030ff <__alltraps>

c0103003 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103003:	6a 00                	push   $0x0
  pushl $235
c0103005:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010300a:	e9 f0 00 00 00       	jmp    c01030ff <__alltraps>

c010300f <vector236>:
.globl vector236
vector236:
  pushl $0
c010300f:	6a 00                	push   $0x0
  pushl $236
c0103011:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103016:	e9 e4 00 00 00       	jmp    c01030ff <__alltraps>

c010301b <vector237>:
.globl vector237
vector237:
  pushl $0
c010301b:	6a 00                	push   $0x0
  pushl $237
c010301d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103022:	e9 d8 00 00 00       	jmp    c01030ff <__alltraps>

c0103027 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103027:	6a 00                	push   $0x0
  pushl $238
c0103029:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010302e:	e9 cc 00 00 00       	jmp    c01030ff <__alltraps>

c0103033 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103033:	6a 00                	push   $0x0
  pushl $239
c0103035:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010303a:	e9 c0 00 00 00       	jmp    c01030ff <__alltraps>

c010303f <vector240>:
.globl vector240
vector240:
  pushl $0
c010303f:	6a 00                	push   $0x0
  pushl $240
c0103041:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103046:	e9 b4 00 00 00       	jmp    c01030ff <__alltraps>

c010304b <vector241>:
.globl vector241
vector241:
  pushl $0
c010304b:	6a 00                	push   $0x0
  pushl $241
c010304d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103052:	e9 a8 00 00 00       	jmp    c01030ff <__alltraps>

c0103057 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103057:	6a 00                	push   $0x0
  pushl $242
c0103059:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010305e:	e9 9c 00 00 00       	jmp    c01030ff <__alltraps>

c0103063 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103063:	6a 00                	push   $0x0
  pushl $243
c0103065:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010306a:	e9 90 00 00 00       	jmp    c01030ff <__alltraps>

c010306f <vector244>:
.globl vector244
vector244:
  pushl $0
c010306f:	6a 00                	push   $0x0
  pushl $244
c0103071:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103076:	e9 84 00 00 00       	jmp    c01030ff <__alltraps>

c010307b <vector245>:
.globl vector245
vector245:
  pushl $0
c010307b:	6a 00                	push   $0x0
  pushl $245
c010307d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103082:	e9 78 00 00 00       	jmp    c01030ff <__alltraps>

c0103087 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103087:	6a 00                	push   $0x0
  pushl $246
c0103089:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010308e:	e9 6c 00 00 00       	jmp    c01030ff <__alltraps>

c0103093 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103093:	6a 00                	push   $0x0
  pushl $247
c0103095:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010309a:	e9 60 00 00 00       	jmp    c01030ff <__alltraps>

c010309f <vector248>:
.globl vector248
vector248:
  pushl $0
c010309f:	6a 00                	push   $0x0
  pushl $248
c01030a1:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01030a6:	e9 54 00 00 00       	jmp    c01030ff <__alltraps>

c01030ab <vector249>:
.globl vector249
vector249:
  pushl $0
c01030ab:	6a 00                	push   $0x0
  pushl $249
c01030ad:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01030b2:	e9 48 00 00 00       	jmp    c01030ff <__alltraps>

c01030b7 <vector250>:
.globl vector250
vector250:
  pushl $0
c01030b7:	6a 00                	push   $0x0
  pushl $250
c01030b9:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01030be:	e9 3c 00 00 00       	jmp    c01030ff <__alltraps>

c01030c3 <vector251>:
.globl vector251
vector251:
  pushl $0
c01030c3:	6a 00                	push   $0x0
  pushl $251
c01030c5:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01030ca:	e9 30 00 00 00       	jmp    c01030ff <__alltraps>

c01030cf <vector252>:
.globl vector252
vector252:
  pushl $0
c01030cf:	6a 00                	push   $0x0
  pushl $252
c01030d1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01030d6:	e9 24 00 00 00       	jmp    c01030ff <__alltraps>

c01030db <vector253>:
.globl vector253
vector253:
  pushl $0
c01030db:	6a 00                	push   $0x0
  pushl $253
c01030dd:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01030e2:	e9 18 00 00 00       	jmp    c01030ff <__alltraps>

c01030e7 <vector254>:
.globl vector254
vector254:
  pushl $0
c01030e7:	6a 00                	push   $0x0
  pushl $254
c01030e9:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01030ee:	e9 0c 00 00 00       	jmp    c01030ff <__alltraps>

c01030f3 <vector255>:
.globl vector255
vector255:
  pushl $0
c01030f3:	6a 00                	push   $0x0
  pushl $255
c01030f5:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01030fa:	e9 00 00 00 00       	jmp    c01030ff <__alltraps>

c01030ff <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01030ff:	1e                   	push   %ds
    pushl %es
c0103100:	06                   	push   %es
    pushl %fs
c0103101:	0f a0                	push   %fs
    pushl %gs
c0103103:	0f a8                	push   %gs
    pushal
c0103105:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103106:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010310b:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010310d:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010310f:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103110:	e8 63 f5 ff ff       	call   c0102678 <trap>

    # pop the pushed stack pointer
    popl %esp
c0103115:	5c                   	pop    %esp

c0103116 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103116:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103117:	0f a9                	pop    %gs
    popl %fs
c0103119:	0f a1                	pop    %fs
    popl %es
c010311b:	07                   	pop    %es
    popl %ds
c010311c:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010311d:	83 c4 08             	add    $0x8,%esp
    iret
c0103120:	cf                   	iret   

c0103121 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103121:	55                   	push   %ebp
c0103122:	89 e5                	mov    %esp,%ebp
c0103124:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0103127:	8b 45 08             	mov    0x8(%ebp),%eax
c010312a:	c1 e8 0c             	shr    $0xc,%eax
c010312d:	89 c2                	mov    %eax,%edx
c010312f:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0103134:	39 c2                	cmp    %eax,%edx
c0103136:	72 14                	jb     c010314c <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0103138:	83 ec 04             	sub    $0x4,%esp
c010313b:	68 10 8d 10 c0       	push   $0xc0108d10
c0103140:	6a 5b                	push   $0x5b
c0103142:	68 2f 8d 10 c0       	push   $0xc0108d2f
c0103147:	e8 9c d2 ff ff       	call   c01003e8 <__panic>
    }
    return &pages[PPN(pa)];
c010314c:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0103151:	8b 55 08             	mov    0x8(%ebp),%edx
c0103154:	c1 ea 0c             	shr    $0xc,%edx
c0103157:	c1 e2 05             	shl    $0x5,%edx
c010315a:	01 d0                	add    %edx,%eax
}
c010315c:	c9                   	leave  
c010315d:	c3                   	ret    

c010315e <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c010315e:	55                   	push   %ebp
c010315f:	89 e5                	mov    %esp,%ebp
c0103161:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0103164:	8b 45 08             	mov    0x8(%ebp),%eax
c0103167:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010316c:	83 ec 0c             	sub    $0xc,%esp
c010316f:	50                   	push   %eax
c0103170:	e8 ac ff ff ff       	call   c0103121 <pa2page>
c0103175:	83 c4 10             	add    $0x10,%esp
}
c0103178:	c9                   	leave  
c0103179:	c3                   	ret    

c010317a <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010317a:	55                   	push   %ebp
c010317b:	89 e5                	mov    %esp,%ebp
c010317d:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103180:	83 ec 0c             	sub    $0xc,%esp
c0103183:	6a 18                	push   $0x18
c0103185:	e8 cc 44 00 00       	call   c0107656 <kmalloc>
c010318a:	83 c4 10             	add    $0x10,%esp
c010318d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103190:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103194:	74 5b                	je     c01031f1 <mm_create+0x77>
        list_init(&(mm->mmap_list));
c0103196:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103199:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010319c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010319f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01031a2:	89 50 04             	mov    %edx,0x4(%eax)
c01031a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031a8:	8b 50 04             	mov    0x4(%eax),%edx
c01031ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031ae:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01031b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01031ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031bd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01031c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031c7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01031ce:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c01031d3:	85 c0                	test   %eax,%eax
c01031d5:	74 10                	je     c01031e7 <mm_create+0x6d>
c01031d7:	83 ec 0c             	sub    $0xc,%esp
c01031da:	ff 75 f4             	pushl  -0xc(%ebp)
c01031dd:	e8 a5 12 00 00       	call   c0104487 <swap_init_mm>
c01031e2:	83 c4 10             	add    $0x10,%esp
c01031e5:	eb 0a                	jmp    c01031f1 <mm_create+0x77>
        else mm->sm_priv = NULL;
c01031e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031ea:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01031f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01031f4:	c9                   	leave  
c01031f5:	c3                   	ret    

c01031f6 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01031f6:	55                   	push   %ebp
c01031f7:	89 e5                	mov    %esp,%ebp
c01031f9:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01031fc:	83 ec 0c             	sub    $0xc,%esp
c01031ff:	6a 18                	push   $0x18
c0103201:	e8 50 44 00 00       	call   c0107656 <kmalloc>
c0103206:	83 c4 10             	add    $0x10,%esp
c0103209:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c010320c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103210:	74 1b                	je     c010322d <vma_create+0x37>
        vma->vm_start = vm_start;
c0103212:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103215:	8b 55 08             	mov    0x8(%ebp),%edx
c0103218:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010321b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010321e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103221:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0103224:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103227:	8b 55 10             	mov    0x10(%ebp),%edx
c010322a:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010322d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103230:	c9                   	leave  
c0103231:	c3                   	ret    

c0103232 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0103232:	55                   	push   %ebp
c0103233:	89 e5                	mov    %esp,%ebp
c0103235:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0103238:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010323f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103243:	0f 84 95 00 00 00    	je     c01032de <find_vma+0xac>
        vma = mm->mmap_cache;
c0103249:	8b 45 08             	mov    0x8(%ebp),%eax
c010324c:	8b 40 08             	mov    0x8(%eax),%eax
c010324f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0103252:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103256:	74 16                	je     c010326e <find_vma+0x3c>
c0103258:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010325b:	8b 40 04             	mov    0x4(%eax),%eax
c010325e:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0103261:	72 0b                	jb     c010326e <find_vma+0x3c>
c0103263:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103266:	8b 40 08             	mov    0x8(%eax),%eax
c0103269:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010326c:	72 61                	jb     c01032cf <find_vma+0x9d>
                bool found = 0;
c010326e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0103275:	8b 45 08             	mov    0x8(%ebp),%eax
c0103278:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010327b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010327e:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0103281:	eb 28                	jmp    c01032ab <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0103283:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103286:	83 e8 10             	sub    $0x10,%eax
c0103289:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010328c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010328f:	8b 40 04             	mov    0x4(%eax),%eax
c0103292:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0103295:	72 14                	jb     c01032ab <find_vma+0x79>
c0103297:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010329a:	8b 40 08             	mov    0x8(%eax),%eax
c010329d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01032a0:	73 09                	jae    c01032ab <find_vma+0x79>
                        found = 1;
c01032a2:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01032a9:	eb 17                	jmp    c01032c2 <find_vma+0x90>
c01032ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01032b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032b4:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c01032b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01032ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032bd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01032c0:	75 c1                	jne    c0103283 <find_vma+0x51>
                    }
                }
                if (!found) {
c01032c2:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01032c6:	75 07                	jne    c01032cf <find_vma+0x9d>
                    vma = NULL;
c01032c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01032cf:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01032d3:	74 09                	je     c01032de <find_vma+0xac>
            mm->mmap_cache = vma;
c01032d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01032d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01032db:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01032de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01032e1:	c9                   	leave  
c01032e2:	c3                   	ret    

c01032e3 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01032e3:	55                   	push   %ebp
c01032e4:	89 e5                	mov    %esp,%ebp
c01032e6:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c01032e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ec:	8b 50 04             	mov    0x4(%eax),%edx
c01032ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01032f2:	8b 40 08             	mov    0x8(%eax),%eax
c01032f5:	39 c2                	cmp    %eax,%edx
c01032f7:	72 16                	jb     c010330f <check_vma_overlap+0x2c>
c01032f9:	68 3d 8d 10 c0       	push   $0xc0108d3d
c01032fe:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103303:	6a 67                	push   $0x67
c0103305:	68 70 8d 10 c0       	push   $0xc0108d70
c010330a:	e8 d9 d0 ff ff       	call   c01003e8 <__panic>
    assert(prev->vm_end <= next->vm_start);
c010330f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103312:	8b 50 08             	mov    0x8(%eax),%edx
c0103315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103318:	8b 40 04             	mov    0x4(%eax),%eax
c010331b:	39 c2                	cmp    %eax,%edx
c010331d:	76 16                	jbe    c0103335 <check_vma_overlap+0x52>
c010331f:	68 80 8d 10 c0       	push   $0xc0108d80
c0103324:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103329:	6a 68                	push   $0x68
c010332b:	68 70 8d 10 c0       	push   $0xc0108d70
c0103330:	e8 b3 d0 ff ff       	call   c01003e8 <__panic>
    assert(next->vm_start < next->vm_end);
c0103335:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103338:	8b 50 04             	mov    0x4(%eax),%edx
c010333b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010333e:	8b 40 08             	mov    0x8(%eax),%eax
c0103341:	39 c2                	cmp    %eax,%edx
c0103343:	72 16                	jb     c010335b <check_vma_overlap+0x78>
c0103345:	68 9f 8d 10 c0       	push   $0xc0108d9f
c010334a:	68 5b 8d 10 c0       	push   $0xc0108d5b
c010334f:	6a 69                	push   $0x69
c0103351:	68 70 8d 10 c0       	push   $0xc0108d70
c0103356:	e8 8d d0 ff ff       	call   c01003e8 <__panic>
}
c010335b:	90                   	nop
c010335c:	c9                   	leave  
c010335d:	c3                   	ret    

c010335e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010335e:	55                   	push   %ebp
c010335f:	89 e5                	mov    %esp,%ebp
c0103361:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c0103364:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103367:	8b 50 04             	mov    0x4(%eax),%edx
c010336a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010336d:	8b 40 08             	mov    0x8(%eax),%eax
c0103370:	39 c2                	cmp    %eax,%edx
c0103372:	72 16                	jb     c010338a <insert_vma_struct+0x2c>
c0103374:	68 bd 8d 10 c0       	push   $0xc0108dbd
c0103379:	68 5b 8d 10 c0       	push   $0xc0108d5b
c010337e:	6a 70                	push   $0x70
c0103380:	68 70 8d 10 c0       	push   $0xc0108d70
c0103385:	e8 5e d0 ff ff       	call   c01003e8 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c010338a:	8b 45 08             	mov    0x8(%ebp),%eax
c010338d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0103390:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103393:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0103396:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103399:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010339c:	eb 1f                	jmp    c01033bd <insert_vma_struct+0x5f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010339e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033a1:	83 e8 10             	sub    $0x10,%eax
c01033a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01033a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033aa:	8b 50 04             	mov    0x4(%eax),%edx
c01033ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033b0:	8b 40 04             	mov    0x4(%eax),%eax
c01033b3:	39 c2                	cmp    %eax,%edx
c01033b5:	77 1f                	ja     c01033d6 <insert_vma_struct+0x78>
                break;
            }
            le_prev = le;
c01033b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01033c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033c6:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01033c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033d2:	75 ca                	jne    c010339e <insert_vma_struct+0x40>
c01033d4:	eb 01                	jmp    c01033d7 <insert_vma_struct+0x79>
                break;
c01033d6:	90                   	nop
c01033d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033da:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01033dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01033e0:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c01033e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01033e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01033ec:	74 15                	je     c0103403 <insert_vma_struct+0xa5>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01033ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f1:	83 e8 10             	sub    $0x10,%eax
c01033f4:	83 ec 08             	sub    $0x8,%esp
c01033f7:	ff 75 0c             	pushl  0xc(%ebp)
c01033fa:	50                   	push   %eax
c01033fb:	e8 e3 fe ff ff       	call   c01032e3 <check_vma_overlap>
c0103400:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c0103403:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103406:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103409:	74 15                	je     c0103420 <insert_vma_struct+0xc2>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010340b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010340e:	83 e8 10             	sub    $0x10,%eax
c0103411:	83 ec 08             	sub    $0x8,%esp
c0103414:	50                   	push   %eax
c0103415:	ff 75 0c             	pushl  0xc(%ebp)
c0103418:	e8 c6 fe ff ff       	call   c01032e3 <check_vma_overlap>
c010341d:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c0103420:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103423:	8b 55 08             	mov    0x8(%ebp),%edx
c0103426:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0103428:	8b 45 0c             	mov    0xc(%ebp),%eax
c010342b:	8d 50 10             	lea    0x10(%eax),%edx
c010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103431:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103434:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103437:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010343a:	8b 40 04             	mov    0x4(%eax),%eax
c010343d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103440:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0103443:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103446:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103449:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010344c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010344f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103452:	89 10                	mov    %edx,(%eax)
c0103454:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103457:	8b 10                	mov    (%eax),%edx
c0103459:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010345c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010345f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103462:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103465:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103468:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010346b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010346e:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0103470:	8b 45 08             	mov    0x8(%ebp),%eax
c0103473:	8b 40 10             	mov    0x10(%eax),%eax
c0103476:	8d 50 01             	lea    0x1(%eax),%edx
c0103479:	8b 45 08             	mov    0x8(%ebp),%eax
c010347c:	89 50 10             	mov    %edx,0x10(%eax)
}
c010347f:	90                   	nop
c0103480:	c9                   	leave  
c0103481:	c3                   	ret    

c0103482 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0103482:	55                   	push   %ebp
c0103483:	89 e5                	mov    %esp,%ebp
c0103485:	83 ec 28             	sub    $0x28,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0103488:	8b 45 08             	mov    0x8(%ebp),%eax
c010348b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010348e:	eb 3c                	jmp    c01034cc <mm_destroy+0x4a>
c0103490:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103493:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103496:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103499:	8b 40 04             	mov    0x4(%eax),%eax
c010349c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010349f:	8b 12                	mov    (%edx),%edx
c01034a1:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01034a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01034a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01034ad:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01034b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034b3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01034b6:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01034b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034bb:	83 e8 10             	sub    $0x10,%eax
c01034be:	83 ec 08             	sub    $0x8,%esp
c01034c1:	6a 18                	push   $0x18
c01034c3:	50                   	push   %eax
c01034c4:	e8 1e 42 00 00       	call   c01076e7 <kfree>
c01034c9:	83 c4 10             	add    $0x10,%esp
c01034cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01034d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034d5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c01034d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034de:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01034e1:	75 ad                	jne    c0103490 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c01034e3:	83 ec 08             	sub    $0x8,%esp
c01034e6:	6a 18                	push   $0x18
c01034e8:	ff 75 08             	pushl  0x8(%ebp)
c01034eb:	e8 f7 41 00 00       	call   c01076e7 <kfree>
c01034f0:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c01034f3:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01034fa:	90                   	nop
c01034fb:	c9                   	leave  
c01034fc:	c3                   	ret    

c01034fd <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01034fd:	55                   	push   %ebp
c01034fe:	89 e5                	mov    %esp,%ebp
c0103500:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103503:	e8 03 00 00 00       	call   c010350b <check_vmm>
}
c0103508:	90                   	nop
c0103509:	c9                   	leave  
c010350a:	c3                   	ret    

c010350b <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010350b:	55                   	push   %ebp
c010350c:	89 e5                	mov    %esp,%ebp
c010350e:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103511:	e8 d2 2c 00 00       	call   c01061e8 <nr_free_pages>
c0103516:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0103519:	e8 3b 00 00 00       	call   c0103559 <check_vma_struct>
    check_pgfault();
c010351e:	e8 56 04 00 00       	call   c0103979 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0103523:	e8 c0 2c 00 00       	call   c01061e8 <nr_free_pages>
c0103528:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010352b:	74 19                	je     c0103546 <check_vmm+0x3b>
c010352d:	68 dc 8d 10 c0       	push   $0xc0108ddc
c0103532:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103537:	68 a9 00 00 00       	push   $0xa9
c010353c:	68 70 8d 10 c0       	push   $0xc0108d70
c0103541:	e8 a2 ce ff ff       	call   c01003e8 <__panic>

    cprintf("check_vmm() succeeded.\n");
c0103546:	83 ec 0c             	sub    $0xc,%esp
c0103549:	68 03 8e 10 c0       	push   $0xc0108e03
c010354e:	e8 2f cd ff ff       	call   c0100282 <cprintf>
c0103553:	83 c4 10             	add    $0x10,%esp
}
c0103556:	90                   	nop
c0103557:	c9                   	leave  
c0103558:	c3                   	ret    

c0103559 <check_vma_struct>:

static void
check_vma_struct(void) {
c0103559:	55                   	push   %ebp
c010355a:	89 e5                	mov    %esp,%ebp
c010355c:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010355f:	e8 84 2c 00 00       	call   c01061e8 <nr_free_pages>
c0103564:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103567:	e8 0e fc ff ff       	call   c010317a <mm_create>
c010356c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c010356f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103573:	75 19                	jne    c010358e <check_vma_struct+0x35>
c0103575:	68 1b 8e 10 c0       	push   $0xc0108e1b
c010357a:	68 5b 8d 10 c0       	push   $0xc0108d5b
c010357f:	68 b3 00 00 00       	push   $0xb3
c0103584:	68 70 8d 10 c0       	push   $0xc0108d70
c0103589:	e8 5a ce ff ff       	call   c01003e8 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010358e:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103595:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103598:	89 d0                	mov    %edx,%eax
c010359a:	c1 e0 02             	shl    $0x2,%eax
c010359d:	01 d0                	add    %edx,%eax
c010359f:	01 c0                	add    %eax,%eax
c01035a1:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01035a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01035aa:	eb 5f                	jmp    c010360b <check_vma_struct+0xb2>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01035ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035af:	89 d0                	mov    %edx,%eax
c01035b1:	c1 e0 02             	shl    $0x2,%eax
c01035b4:	01 d0                	add    %edx,%eax
c01035b6:	83 c0 02             	add    $0x2,%eax
c01035b9:	89 c1                	mov    %eax,%ecx
c01035bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035be:	89 d0                	mov    %edx,%eax
c01035c0:	c1 e0 02             	shl    $0x2,%eax
c01035c3:	01 d0                	add    %edx,%eax
c01035c5:	83 ec 04             	sub    $0x4,%esp
c01035c8:	6a 00                	push   $0x0
c01035ca:	51                   	push   %ecx
c01035cb:	50                   	push   %eax
c01035cc:	e8 25 fc ff ff       	call   c01031f6 <vma_create>
c01035d1:	83 c4 10             	add    $0x10,%esp
c01035d4:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c01035d7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01035db:	75 19                	jne    c01035f6 <check_vma_struct+0x9d>
c01035dd:	68 26 8e 10 c0       	push   $0xc0108e26
c01035e2:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01035e7:	68 ba 00 00 00       	push   $0xba
c01035ec:	68 70 8d 10 c0       	push   $0xc0108d70
c01035f1:	e8 f2 cd ff ff       	call   c01003e8 <__panic>
        insert_vma_struct(mm, vma);
c01035f6:	83 ec 08             	sub    $0x8,%esp
c01035f9:	ff 75 bc             	pushl  -0x44(%ebp)
c01035fc:	ff 75 e8             	pushl  -0x18(%ebp)
c01035ff:	e8 5a fd ff ff       	call   c010335e <insert_vma_struct>
c0103604:	83 c4 10             	add    $0x10,%esp
    for (i = step1; i >= 1; i --) {
c0103607:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010360b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010360f:	7f 9b                	jg     c01035ac <check_vma_struct+0x53>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103614:	83 c0 01             	add    $0x1,%eax
c0103617:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010361a:	eb 5f                	jmp    c010367b <check_vma_struct+0x122>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010361c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010361f:	89 d0                	mov    %edx,%eax
c0103621:	c1 e0 02             	shl    $0x2,%eax
c0103624:	01 d0                	add    %edx,%eax
c0103626:	83 c0 02             	add    $0x2,%eax
c0103629:	89 c1                	mov    %eax,%ecx
c010362b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010362e:	89 d0                	mov    %edx,%eax
c0103630:	c1 e0 02             	shl    $0x2,%eax
c0103633:	01 d0                	add    %edx,%eax
c0103635:	83 ec 04             	sub    $0x4,%esp
c0103638:	6a 00                	push   $0x0
c010363a:	51                   	push   %ecx
c010363b:	50                   	push   %eax
c010363c:	e8 b5 fb ff ff       	call   c01031f6 <vma_create>
c0103641:	83 c4 10             	add    $0x10,%esp
c0103644:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0103647:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010364b:	75 19                	jne    c0103666 <check_vma_struct+0x10d>
c010364d:	68 26 8e 10 c0       	push   $0xc0108e26
c0103652:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103657:	68 c0 00 00 00       	push   $0xc0
c010365c:	68 70 8d 10 c0       	push   $0xc0108d70
c0103661:	e8 82 cd ff ff       	call   c01003e8 <__panic>
        insert_vma_struct(mm, vma);
c0103666:	83 ec 08             	sub    $0x8,%esp
c0103669:	ff 75 c0             	pushl  -0x40(%ebp)
c010366c:	ff 75 e8             	pushl  -0x18(%ebp)
c010366f:	e8 ea fc ff ff       	call   c010335e <insert_vma_struct>
c0103674:	83 c4 10             	add    $0x10,%esp
    for (i = step1 + 1; i <= step2; i ++) {
c0103677:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010367b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010367e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103681:	7e 99                	jle    c010361c <check_vma_struct+0xc3>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103683:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103686:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103689:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010368c:	8b 40 04             	mov    0x4(%eax),%eax
c010368f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103692:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103699:	e9 81 00 00 00       	jmp    c010371f <check_vma_struct+0x1c6>
        assert(le != &(mm->mmap_list));
c010369e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036a1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01036a4:	75 19                	jne    c01036bf <check_vma_struct+0x166>
c01036a6:	68 32 8e 10 c0       	push   $0xc0108e32
c01036ab:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01036b0:	68 c7 00 00 00       	push   $0xc7
c01036b5:	68 70 8d 10 c0       	push   $0xc0108d70
c01036ba:	e8 29 cd ff ff       	call   c01003e8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01036bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036c2:	83 e8 10             	sub    $0x10,%eax
c01036c5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01036c8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036cb:	8b 48 04             	mov    0x4(%eax),%ecx
c01036ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036d1:	89 d0                	mov    %edx,%eax
c01036d3:	c1 e0 02             	shl    $0x2,%eax
c01036d6:	01 d0                	add    %edx,%eax
c01036d8:	39 c1                	cmp    %eax,%ecx
c01036da:	75 17                	jne    c01036f3 <check_vma_struct+0x19a>
c01036dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036df:	8b 48 08             	mov    0x8(%eax),%ecx
c01036e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036e5:	89 d0                	mov    %edx,%eax
c01036e7:	c1 e0 02             	shl    $0x2,%eax
c01036ea:	01 d0                	add    %edx,%eax
c01036ec:	83 c0 02             	add    $0x2,%eax
c01036ef:	39 c1                	cmp    %eax,%ecx
c01036f1:	74 19                	je     c010370c <check_vma_struct+0x1b3>
c01036f3:	68 4c 8e 10 c0       	push   $0xc0108e4c
c01036f8:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01036fd:	68 c9 00 00 00       	push   $0xc9
c0103702:	68 70 8d 10 c0       	push   $0xc0108d70
c0103707:	e8 dc cc ff ff       	call   c01003e8 <__panic>
c010370c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010370f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103712:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103715:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103718:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c010371b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010371f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103722:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103725:	0f 8e 73 ff ff ff    	jle    c010369e <check_vma_struct+0x145>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010372b:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103732:	e9 80 01 00 00       	jmp    c01038b7 <check_vma_struct+0x35e>
        struct vma_struct *vma1 = find_vma(mm, i);
c0103737:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010373a:	83 ec 08             	sub    $0x8,%esp
c010373d:	50                   	push   %eax
c010373e:	ff 75 e8             	pushl  -0x18(%ebp)
c0103741:	e8 ec fa ff ff       	call   c0103232 <find_vma>
c0103746:	83 c4 10             	add    $0x10,%esp
c0103749:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c010374c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103750:	75 19                	jne    c010376b <check_vma_struct+0x212>
c0103752:	68 81 8e 10 c0       	push   $0xc0108e81
c0103757:	68 5b 8d 10 c0       	push   $0xc0108d5b
c010375c:	68 cf 00 00 00       	push   $0xcf
c0103761:	68 70 8d 10 c0       	push   $0xc0108d70
c0103766:	e8 7d cc ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c010376b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010376e:	83 c0 01             	add    $0x1,%eax
c0103771:	83 ec 08             	sub    $0x8,%esp
c0103774:	50                   	push   %eax
c0103775:	ff 75 e8             	pushl  -0x18(%ebp)
c0103778:	e8 b5 fa ff ff       	call   c0103232 <find_vma>
c010377d:	83 c4 10             	add    $0x10,%esp
c0103780:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0103783:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0103787:	75 19                	jne    c01037a2 <check_vma_struct+0x249>
c0103789:	68 8e 8e 10 c0       	push   $0xc0108e8e
c010378e:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103793:	68 d1 00 00 00       	push   $0xd1
c0103798:	68 70 8d 10 c0       	push   $0xc0108d70
c010379d:	e8 46 cc ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c01037a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037a5:	83 c0 02             	add    $0x2,%eax
c01037a8:	83 ec 08             	sub    $0x8,%esp
c01037ab:	50                   	push   %eax
c01037ac:	ff 75 e8             	pushl  -0x18(%ebp)
c01037af:	e8 7e fa ff ff       	call   c0103232 <find_vma>
c01037b4:	83 c4 10             	add    $0x10,%esp
c01037b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c01037ba:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01037be:	74 19                	je     c01037d9 <check_vma_struct+0x280>
c01037c0:	68 9b 8e 10 c0       	push   $0xc0108e9b
c01037c5:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01037ca:	68 d3 00 00 00       	push   $0xd3
c01037cf:	68 70 8d 10 c0       	push   $0xc0108d70
c01037d4:	e8 0f cc ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01037d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037dc:	83 c0 03             	add    $0x3,%eax
c01037df:	83 ec 08             	sub    $0x8,%esp
c01037e2:	50                   	push   %eax
c01037e3:	ff 75 e8             	pushl  -0x18(%ebp)
c01037e6:	e8 47 fa ff ff       	call   c0103232 <find_vma>
c01037eb:	83 c4 10             	add    $0x10,%esp
c01037ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c01037f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01037f5:	74 19                	je     c0103810 <check_vma_struct+0x2b7>
c01037f7:	68 a8 8e 10 c0       	push   $0xc0108ea8
c01037fc:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103801:	68 d5 00 00 00       	push   $0xd5
c0103806:	68 70 8d 10 c0       	push   $0xc0108d70
c010380b:	e8 d8 cb ff ff       	call   c01003e8 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0103810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103813:	83 c0 04             	add    $0x4,%eax
c0103816:	83 ec 08             	sub    $0x8,%esp
c0103819:	50                   	push   %eax
c010381a:	ff 75 e8             	pushl  -0x18(%ebp)
c010381d:	e8 10 fa ff ff       	call   c0103232 <find_vma>
c0103822:	83 c4 10             	add    $0x10,%esp
c0103825:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0103828:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010382c:	74 19                	je     c0103847 <check_vma_struct+0x2ee>
c010382e:	68 b5 8e 10 c0       	push   $0xc0108eb5
c0103833:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103838:	68 d7 00 00 00       	push   $0xd7
c010383d:	68 70 8d 10 c0       	push   $0xc0108d70
c0103842:	e8 a1 cb ff ff       	call   c01003e8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0103847:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010384a:	8b 50 04             	mov    0x4(%eax),%edx
c010384d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103850:	39 c2                	cmp    %eax,%edx
c0103852:	75 10                	jne    c0103864 <check_vma_struct+0x30b>
c0103854:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103857:	8b 40 08             	mov    0x8(%eax),%eax
c010385a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010385d:	83 c2 02             	add    $0x2,%edx
c0103860:	39 d0                	cmp    %edx,%eax
c0103862:	74 19                	je     c010387d <check_vma_struct+0x324>
c0103864:	68 c4 8e 10 c0       	push   $0xc0108ec4
c0103869:	68 5b 8d 10 c0       	push   $0xc0108d5b
c010386e:	68 d9 00 00 00       	push   $0xd9
c0103873:	68 70 8d 10 c0       	push   $0xc0108d70
c0103878:	e8 6b cb ff ff       	call   c01003e8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c010387d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103880:	8b 50 04             	mov    0x4(%eax),%edx
c0103883:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103886:	39 c2                	cmp    %eax,%edx
c0103888:	75 10                	jne    c010389a <check_vma_struct+0x341>
c010388a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010388d:	8b 40 08             	mov    0x8(%eax),%eax
c0103890:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103893:	83 c2 02             	add    $0x2,%edx
c0103896:	39 d0                	cmp    %edx,%eax
c0103898:	74 19                	je     c01038b3 <check_vma_struct+0x35a>
c010389a:	68 f4 8e 10 c0       	push   $0xc0108ef4
c010389f:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01038a4:	68 da 00 00 00       	push   $0xda
c01038a9:	68 70 8d 10 c0       	push   $0xc0108d70
c01038ae:	e8 35 cb ff ff       	call   c01003e8 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c01038b3:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01038b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038ba:	89 d0                	mov    %edx,%eax
c01038bc:	c1 e0 02             	shl    $0x2,%eax
c01038bf:	01 d0                	add    %edx,%eax
c01038c1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01038c4:	0f 8e 6d fe ff ff    	jle    c0103737 <check_vma_struct+0x1de>
    }

    for (i =4; i>=0; i--) {
c01038ca:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c01038d1:	eb 5c                	jmp    c010392f <check_vma_struct+0x3d6>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c01038d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d6:	83 ec 08             	sub    $0x8,%esp
c01038d9:	50                   	push   %eax
c01038da:	ff 75 e8             	pushl  -0x18(%ebp)
c01038dd:	e8 50 f9 ff ff       	call   c0103232 <find_vma>
c01038e2:	83 c4 10             	add    $0x10,%esp
c01038e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c01038e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01038ec:	74 1e                	je     c010390c <check_vma_struct+0x3b3>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01038ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038f1:	8b 50 08             	mov    0x8(%eax),%edx
c01038f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038f7:	8b 40 04             	mov    0x4(%eax),%eax
c01038fa:	52                   	push   %edx
c01038fb:	50                   	push   %eax
c01038fc:	ff 75 f4             	pushl  -0xc(%ebp)
c01038ff:	68 24 8f 10 c0       	push   $0xc0108f24
c0103904:	e8 79 c9 ff ff       	call   c0100282 <cprintf>
c0103909:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c010390c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103910:	74 19                	je     c010392b <check_vma_struct+0x3d2>
c0103912:	68 49 8f 10 c0       	push   $0xc0108f49
c0103917:	68 5b 8d 10 c0       	push   $0xc0108d5b
c010391c:	68 e2 00 00 00       	push   $0xe2
c0103921:	68 70 8d 10 c0       	push   $0xc0108d70
c0103926:	e8 bd ca ff ff       	call   c01003e8 <__panic>
    for (i =4; i>=0; i--) {
c010392b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010392f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103933:	79 9e                	jns    c01038d3 <check_vma_struct+0x37a>
    }

    mm_destroy(mm);
c0103935:	83 ec 0c             	sub    $0xc,%esp
c0103938:	ff 75 e8             	pushl  -0x18(%ebp)
c010393b:	e8 42 fb ff ff       	call   c0103482 <mm_destroy>
c0103940:	83 c4 10             	add    $0x10,%esp

    assert(nr_free_pages_store == nr_free_pages());
c0103943:	e8 a0 28 00 00       	call   c01061e8 <nr_free_pages>
c0103948:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010394b:	74 19                	je     c0103966 <check_vma_struct+0x40d>
c010394d:	68 dc 8d 10 c0       	push   $0xc0108ddc
c0103952:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103957:	68 e7 00 00 00       	push   $0xe7
c010395c:	68 70 8d 10 c0       	push   $0xc0108d70
c0103961:	e8 82 ca ff ff       	call   c01003e8 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0103966:	83 ec 0c             	sub    $0xc,%esp
c0103969:	68 60 8f 10 c0       	push   $0xc0108f60
c010396e:	e8 0f c9 ff ff       	call   c0100282 <cprintf>
c0103973:	83 c4 10             	add    $0x10,%esp
}
c0103976:	90                   	nop
c0103977:	c9                   	leave  
c0103978:	c3                   	ret    

c0103979 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0103979:	55                   	push   %ebp
c010397a:	89 e5                	mov    %esp,%ebp
c010397c:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010397f:	e8 64 28 00 00       	call   c01061e8 <nr_free_pages>
c0103984:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0103987:	e8 ee f7 ff ff       	call   c010317a <mm_create>
c010398c:	a3 10 40 12 c0       	mov    %eax,0xc0124010
    assert(check_mm_struct != NULL);
c0103991:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0103996:	85 c0                	test   %eax,%eax
c0103998:	75 19                	jne    c01039b3 <check_pgfault+0x3a>
c010399a:	68 7f 8f 10 c0       	push   $0xc0108f7f
c010399f:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01039a4:	68 f4 00 00 00       	push   $0xf4
c01039a9:	68 70 8d 10 c0       	push   $0xc0108d70
c01039ae:	e8 35 ca ff ff       	call   c01003e8 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01039b3:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c01039b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c01039bb:	8b 15 00 0a 12 c0    	mov    0xc0120a00,%edx
c01039c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039c4:	89 50 0c             	mov    %edx,0xc(%eax)
c01039c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039ca:	8b 40 0c             	mov    0xc(%eax),%eax
c01039cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01039d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039d3:	8b 00                	mov    (%eax),%eax
c01039d5:	85 c0                	test   %eax,%eax
c01039d7:	74 19                	je     c01039f2 <check_pgfault+0x79>
c01039d9:	68 97 8f 10 c0       	push   $0xc0108f97
c01039de:	68 5b 8d 10 c0       	push   $0xc0108d5b
c01039e3:	68 f8 00 00 00       	push   $0xf8
c01039e8:	68 70 8d 10 c0       	push   $0xc0108d70
c01039ed:	e8 f6 c9 ff ff       	call   c01003e8 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01039f2:	83 ec 04             	sub    $0x4,%esp
c01039f5:	6a 02                	push   $0x2
c01039f7:	68 00 00 40 00       	push   $0x400000
c01039fc:	6a 00                	push   $0x0
c01039fe:	e8 f3 f7 ff ff       	call   c01031f6 <vma_create>
c0103a03:	83 c4 10             	add    $0x10,%esp
c0103a06:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103a09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103a0d:	75 19                	jne    c0103a28 <check_pgfault+0xaf>
c0103a0f:	68 26 8e 10 c0       	push   $0xc0108e26
c0103a14:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103a19:	68 fb 00 00 00       	push   $0xfb
c0103a1e:	68 70 8d 10 c0       	push   $0xc0108d70
c0103a23:	e8 c0 c9 ff ff       	call   c01003e8 <__panic>

    insert_vma_struct(mm, vma);
c0103a28:	83 ec 08             	sub    $0x8,%esp
c0103a2b:	ff 75 e0             	pushl  -0x20(%ebp)
c0103a2e:	ff 75 e8             	pushl  -0x18(%ebp)
c0103a31:	e8 28 f9 ff ff       	call   c010335e <insert_vma_struct>
c0103a36:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c0103a39:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103a40:	83 ec 08             	sub    $0x8,%esp
c0103a43:	ff 75 dc             	pushl  -0x24(%ebp)
c0103a46:	ff 75 e8             	pushl  -0x18(%ebp)
c0103a49:	e8 e4 f7 ff ff       	call   c0103232 <find_vma>
c0103a4e:	83 c4 10             	add    $0x10,%esp
c0103a51:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103a54:	74 19                	je     c0103a6f <check_pgfault+0xf6>
c0103a56:	68 a5 8f 10 c0       	push   $0xc0108fa5
c0103a5b:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103a60:	68 00 01 00 00       	push   $0x100
c0103a65:	68 70 8d 10 c0       	push   $0xc0108d70
c0103a6a:	e8 79 c9 ff ff       	call   c01003e8 <__panic>

    int i, sum = 0;
c0103a6f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103a76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a7d:	eb 19                	jmp    c0103a98 <check_pgfault+0x11f>
        *(char *)(addr + i) = i;
c0103a7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a82:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a85:	01 d0                	add    %edx,%eax
c0103a87:	89 c2                	mov    %eax,%edx
c0103a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a8c:	88 02                	mov    %al,(%edx)
        sum += i;
c0103a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a91:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103a94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103a98:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103a9c:	7e e1                	jle    c0103a7f <check_pgfault+0x106>
    }
    for (i = 0; i < 100; i ++) {
c0103a9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103aa5:	eb 15                	jmp    c0103abc <check_pgfault+0x143>
        sum -= *(char *)(addr + i);
c0103aa7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103aaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103aad:	01 d0                	add    %edx,%eax
c0103aaf:	0f b6 00             	movzbl (%eax),%eax
c0103ab2:	0f be c0             	movsbl %al,%eax
c0103ab5:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103ab8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103abc:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103ac0:	7e e5                	jle    c0103aa7 <check_pgfault+0x12e>
    }
    assert(sum == 0);
c0103ac2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ac6:	74 19                	je     c0103ae1 <check_pgfault+0x168>
c0103ac8:	68 bf 8f 10 c0       	push   $0xc0108fbf
c0103acd:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103ad2:	68 0a 01 00 00       	push   $0x10a
c0103ad7:	68 70 8d 10 c0       	push   $0xc0108d70
c0103adc:	e8 07 c9 ff ff       	call   c01003e8 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103ae1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ae4:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103ae7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103aea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103aef:	83 ec 08             	sub    $0x8,%esp
c0103af2:	50                   	push   %eax
c0103af3:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103af6:	e8 99 2e 00 00       	call   c0106994 <page_remove>
c0103afb:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c0103afe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b01:	8b 00                	mov    (%eax),%eax
c0103b03:	83 ec 0c             	sub    $0xc,%esp
c0103b06:	50                   	push   %eax
c0103b07:	e8 52 f6 ff ff       	call   c010315e <pde2page>
c0103b0c:	83 c4 10             	add    $0x10,%esp
c0103b0f:	83 ec 08             	sub    $0x8,%esp
c0103b12:	6a 01                	push   $0x1
c0103b14:	50                   	push   %eax
c0103b15:	e8 99 26 00 00       	call   c01061b3 <free_pages>
c0103b1a:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c0103b1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103b26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b29:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103b30:	83 ec 0c             	sub    $0xc,%esp
c0103b33:	ff 75 e8             	pushl  -0x18(%ebp)
c0103b36:	e8 47 f9 ff ff       	call   c0103482 <mm_destroy>
c0103b3b:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c0103b3e:	c7 05 10 40 12 c0 00 	movl   $0x0,0xc0124010
c0103b45:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103b48:	e8 9b 26 00 00       	call   c01061e8 <nr_free_pages>
c0103b4d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103b50:	74 19                	je     c0103b6b <check_pgfault+0x1f2>
c0103b52:	68 dc 8d 10 c0       	push   $0xc0108ddc
c0103b57:	68 5b 8d 10 c0       	push   $0xc0108d5b
c0103b5c:	68 14 01 00 00       	push   $0x114
c0103b61:	68 70 8d 10 c0       	push   $0xc0108d70
c0103b66:	e8 7d c8 ff ff       	call   c01003e8 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103b6b:	83 ec 0c             	sub    $0xc,%esp
c0103b6e:	68 c8 8f 10 c0       	push   $0xc0108fc8
c0103b73:	e8 0a c7 ff ff       	call   c0100282 <cprintf>
c0103b78:	83 c4 10             	add    $0x10,%esp
}
c0103b7b:	90                   	nop
c0103b7c:	c9                   	leave  
c0103b7d:	c3                   	ret    

c0103b7e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103b7e:	55                   	push   %ebp
c0103b7f:	89 e5                	mov    %esp,%ebp
c0103b81:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0103b84:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103b8b:	ff 75 10             	pushl  0x10(%ebp)
c0103b8e:	ff 75 08             	pushl  0x8(%ebp)
c0103b91:	e8 9c f6 ff ff       	call   c0103232 <find_vma>
c0103b96:	83 c4 08             	add    $0x8,%esp
c0103b99:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103b9c:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0103ba1:	83 c0 01             	add    $0x1,%eax
c0103ba4:	a3 64 3f 12 c0       	mov    %eax,0xc0123f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103ba9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103bad:	74 0b                	je     c0103bba <do_pgfault+0x3c>
c0103baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bb2:	8b 40 04             	mov    0x4(%eax),%eax
c0103bb5:	39 45 10             	cmp    %eax,0x10(%ebp)
c0103bb8:	73 18                	jae    c0103bd2 <do_pgfault+0x54>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103bba:	83 ec 08             	sub    $0x8,%esp
c0103bbd:	ff 75 10             	pushl  0x10(%ebp)
c0103bc0:	68 e4 8f 10 c0       	push   $0xc0108fe4
c0103bc5:	e8 b8 c6 ff ff       	call   c0100282 <cprintf>
c0103bca:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103bcd:	e9 aa 01 00 00       	jmp    c0103d7c <do_pgfault+0x1fe>
    }
    //check the error_code
    switch (error_code & 3) {
c0103bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103bd5:	83 e0 03             	and    $0x3,%eax
c0103bd8:	85 c0                	test   %eax,%eax
c0103bda:	74 3c                	je     c0103c18 <do_pgfault+0x9a>
c0103bdc:	83 f8 01             	cmp    $0x1,%eax
c0103bdf:	74 22                	je     c0103c03 <do_pgfault+0x85>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103be4:	8b 40 0c             	mov    0xc(%eax),%eax
c0103be7:	83 e0 02             	and    $0x2,%eax
c0103bea:	85 c0                	test   %eax,%eax
c0103bec:	75 4c                	jne    c0103c3a <do_pgfault+0xbc>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103bee:	83 ec 0c             	sub    $0xc,%esp
c0103bf1:	68 14 90 10 c0       	push   $0xc0109014
c0103bf6:	e8 87 c6 ff ff       	call   c0100282 <cprintf>
c0103bfb:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103bfe:	e9 79 01 00 00       	jmp    c0103d7c <do_pgfault+0x1fe>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103c03:	83 ec 0c             	sub    $0xc,%esp
c0103c06:	68 74 90 10 c0       	push   $0xc0109074
c0103c0b:	e8 72 c6 ff ff       	call   c0100282 <cprintf>
c0103c10:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103c13:	e9 64 01 00 00       	jmp    c0103d7c <do_pgfault+0x1fe>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c1b:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c1e:	83 e0 05             	and    $0x5,%eax
c0103c21:	85 c0                	test   %eax,%eax
c0103c23:	75 16                	jne    c0103c3b <do_pgfault+0xbd>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103c25:	83 ec 0c             	sub    $0xc,%esp
c0103c28:	68 ac 90 10 c0       	push   $0xc01090ac
c0103c2d:	e8 50 c6 ff ff       	call   c0100282 <cprintf>
c0103c32:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103c35:	e9 42 01 00 00       	jmp    c0103d7c <do_pgfault+0x1fe>
        break;
c0103c3a:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103c3b:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c45:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c48:	83 e0 02             	and    $0x2,%eax
c0103c4b:	85 c0                	test   %eax,%eax
c0103c4d:	74 04                	je     c0103c53 <do_pgfault+0xd5>
        perm |= PTE_W;
c0103c4f:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103c53:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c56:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103c59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c61:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103c64:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103c6b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0103c72:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c75:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c78:	83 ec 04             	sub    $0x4,%esp
c0103c7b:	6a 01                	push   $0x1
c0103c7d:	ff 75 10             	pushl  0x10(%ebp)
c0103c80:	50                   	push   %eax
c0103c81:	e8 36 2b 00 00       	call   c01067bc <get_pte>
c0103c86:	83 c4 10             	add    $0x10,%esp
c0103c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103c90:	75 15                	jne    c0103ca7 <do_pgfault+0x129>
        cprintf("get_pte in do_pgfault failed\n");
c0103c92:	83 ec 0c             	sub    $0xc,%esp
c0103c95:	68 0f 91 10 c0       	push   $0xc010910f
c0103c9a:	e8 e3 c5 ff ff       	call   c0100282 <cprintf>
c0103c9f:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0103ca2:	e9 d5 00 00 00       	jmp    c0103d7c <do_pgfault+0x1fe>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0103ca7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103caa:	8b 00                	mov    (%eax),%eax
c0103cac:	85 c0                	test   %eax,%eax
c0103cae:	75 35                	jne    c0103ce5 <do_pgfault+0x167>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0103cb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb3:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cb6:	83 ec 04             	sub    $0x4,%esp
c0103cb9:	ff 75 f0             	pushl  -0x10(%ebp)
c0103cbc:	ff 75 10             	pushl  0x10(%ebp)
c0103cbf:	50                   	push   %eax
c0103cc0:	e8 11 2e 00 00       	call   c0106ad6 <pgdir_alloc_page>
c0103cc5:	83 c4 10             	add    $0x10,%esp
c0103cc8:	85 c0                	test   %eax,%eax
c0103cca:	0f 85 a5 00 00 00    	jne    c0103d75 <do_pgfault+0x1f7>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0103cd0:	83 ec 0c             	sub    $0xc,%esp
c0103cd3:	68 30 91 10 c0       	push   $0xc0109130
c0103cd8:	e8 a5 c5 ff ff       	call   c0100282 <cprintf>
c0103cdd:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103ce0:	e9 97 00 00 00       	jmp    c0103d7c <do_pgfault+0x1fe>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0103ce5:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0103cea:	85 c0                	test   %eax,%eax
c0103cec:	74 6f                	je     c0103d5d <do_pgfault+0x1df>
            struct Page *page=NULL;
c0103cee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103cf5:	83 ec 04             	sub    $0x4,%esp
c0103cf8:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103cfb:	50                   	push   %eax
c0103cfc:	ff 75 10             	pushl  0x10(%ebp)
c0103cff:	ff 75 08             	pushl  0x8(%ebp)
c0103d02:	e8 46 09 00 00       	call   c010464d <swap_in>
c0103d07:	83 c4 10             	add    $0x10,%esp
c0103d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d11:	74 12                	je     c0103d25 <do_pgfault+0x1a7>
                cprintf("swap_in in do_pgfault failed\n");
c0103d13:	83 ec 0c             	sub    $0xc,%esp
c0103d16:	68 57 91 10 c0       	push   $0xc0109157
c0103d1b:	e8 62 c5 ff ff       	call   c0100282 <cprintf>
c0103d20:	83 c4 10             	add    $0x10,%esp
c0103d23:	eb 57                	jmp    c0103d7c <do_pgfault+0x1fe>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0103d25:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103d28:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d2b:	8b 40 0c             	mov    0xc(%eax),%eax
c0103d2e:	ff 75 f0             	pushl  -0x10(%ebp)
c0103d31:	ff 75 10             	pushl  0x10(%ebp)
c0103d34:	52                   	push   %edx
c0103d35:	50                   	push   %eax
c0103d36:	e8 92 2c 00 00       	call   c01069cd <page_insert>
c0103d3b:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c0103d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d41:	6a 01                	push   $0x1
c0103d43:	50                   	push   %eax
c0103d44:	ff 75 10             	pushl  0x10(%ebp)
c0103d47:	ff 75 08             	pushl  0x8(%ebp)
c0103d4a:	e8 6e 07 00 00       	call   c01044bd <swap_map_swappable>
c0103d4f:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c0103d52:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d55:	8b 55 10             	mov    0x10(%ebp),%edx
c0103d58:	89 50 1c             	mov    %edx,0x1c(%eax)
c0103d5b:	eb 18                	jmp    c0103d75 <do_pgfault+0x1f7>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0103d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d60:	8b 00                	mov    (%eax),%eax
c0103d62:	83 ec 08             	sub    $0x8,%esp
c0103d65:	50                   	push   %eax
c0103d66:	68 78 91 10 c0       	push   $0xc0109178
c0103d6b:	e8 12 c5 ff ff       	call   c0100282 <cprintf>
c0103d70:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0103d73:	eb 07                	jmp    c0103d7c <do_pgfault+0x1fe>
        }
   }
   ret = 0;
c0103d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0103d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103d7f:	c9                   	leave  
c0103d80:	c3                   	ret    

c0103d81 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0103d81:	55                   	push   %ebp
c0103d82:	89 e5                	mov    %esp,%ebp
c0103d84:	83 ec 10             	sub    $0x10,%esp
c0103d87:	c7 45 fc 14 40 12 c0 	movl   $0xc0124014,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0103d8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d91:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103d94:	89 50 04             	mov    %edx,0x4(%eax)
c0103d97:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103d9a:	8b 50 04             	mov    0x4(%eax),%edx
c0103d9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103da0:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0103da2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103da5:	c7 40 14 14 40 12 c0 	movl   $0xc0124014,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0103dac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103db1:	c9                   	leave  
c0103db2:	c3                   	ret    

c0103db3 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0103db3:	55                   	push   %ebp
c0103db4:	89 e5                	mov    %esp,%ebp
c0103db6:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103db9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dbc:	8b 40 14             	mov    0x14(%eax),%eax
c0103dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0103dc2:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dc5:	83 c0 14             	add    $0x14,%eax
c0103dc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0103dcb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103dcf:	74 06                	je     c0103dd7 <_fifo_map_swappable+0x24>
c0103dd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103dd5:	75 16                	jne    c0103ded <_fifo_map_swappable+0x3a>
c0103dd7:	68 a0 91 10 c0       	push   $0xc01091a0
c0103ddc:	68 be 91 10 c0       	push   $0xc01091be
c0103de1:	6a 32                	push   $0x32
c0103de3:	68 d3 91 10 c0       	push   $0xc01091d3
c0103de8:	e8 fb c5 ff ff       	call   c01003e8 <__panic>
c0103ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103df0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103df6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103df9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103dff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e02:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e08:	8b 40 04             	mov    0x4(%eax),%eax
c0103e0b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e0e:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103e11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103e14:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0103e17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0103e1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103e1d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e20:	89 10                	mov    %edx,(%eax)
c0103e22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103e25:	8b 10                	mov    (%eax),%edx
c0103e27:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e2a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103e2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e30:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103e33:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103e36:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e39:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103e3c:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0103e3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103e43:	c9                   	leave  
c0103e44:	c3                   	ret    

c0103e45 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0103e45:	55                   	push   %ebp
c0103e46:	89 e5                	mov    %esp,%ebp
c0103e48:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103e4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e4e:	8b 40 14             	mov    0x14(%eax),%eax
c0103e51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0103e54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e58:	75 16                	jne    c0103e70 <_fifo_swap_out_victim+0x2b>
c0103e5a:	68 e7 91 10 c0       	push   $0xc01091e7
c0103e5f:	68 be 91 10 c0       	push   $0xc01091be
c0103e64:	6a 41                	push   $0x41
c0103e66:	68 d3 91 10 c0       	push   $0xc01091d3
c0103e6b:	e8 78 c5 ff ff       	call   c01003e8 <__panic>
    assert(in_tick==0);
c0103e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103e74:	74 16                	je     c0103e8c <_fifo_swap_out_victim+0x47>
c0103e76:	68 f4 91 10 c0       	push   $0xc01091f4
c0103e7b:	68 be 91 10 c0       	push   $0xc01091be
c0103e80:	6a 42                	push   $0x42
c0103e82:	68 d3 91 10 c0       	push   $0xc01091d3
c0103e87:	e8 5c c5 ff ff       	call   c01003e8 <__panic>
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    /* Select the tail */
    list_entry_t *le = head->prev;
c0103e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e8f:	8b 00                	mov    (%eax),%eax
c0103e91:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head!=le);
c0103e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e97:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103e9a:	75 16                	jne    c0103eb2 <_fifo_swap_out_victim+0x6d>
c0103e9c:	68 ff 91 10 c0       	push   $0xc01091ff
c0103ea1:	68 be 91 10 c0       	push   $0xc01091be
c0103ea6:	6a 49                	push   $0x49
c0103ea8:	68 d3 91 10 c0       	push   $0xc01091d3
c0103ead:	e8 36 c5 ff ff       	call   c01003e8 <__panic>
    struct Page *p = le2page(le, pra_page_link);
c0103eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103eb5:	83 e8 14             	sub    $0x14,%eax
c0103eb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ebe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103ec1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ec4:	8b 40 04             	mov    0x4(%eax),%eax
c0103ec7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103eca:	8b 12                	mov    (%edx),%edx
c0103ecc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103ecf:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0103ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103ed8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ede:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103ee1:	89 10                	mov    %edx,(%eax)
    list_del(le);
    assert(p !=NULL);
c0103ee3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103ee7:	75 16                	jne    c0103eff <_fifo_swap_out_victim+0xba>
c0103ee9:	68 08 92 10 c0       	push   $0xc0109208
c0103eee:	68 be 91 10 c0       	push   $0xc01091be
c0103ef3:	6a 4c                	push   $0x4c
c0103ef5:	68 d3 91 10 c0       	push   $0xc01091d3
c0103efa:	e8 e9 c4 ff ff       	call   c01003e8 <__panic>
    *ptr_page = p;
c0103eff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103f02:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103f05:	89 10                	mov    %edx,(%eax)
    return 0;
c0103f07:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103f0c:	c9                   	leave  
c0103f0d:	c3                   	ret    

c0103f0e <_extended_clock_swap_out_victim>:

static int
_extended_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick) {
c0103f0e:	55                   	push   %ebp
c0103f0f:	89 e5                	mov    %esp,%ebp
c0103f11:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0103f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f17:	8b 40 14             	mov    0x14(%eax),%eax
c0103f1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(head!=NULL);
c0103f1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103f21:	75 16                	jne    c0103f39 <_extended_clock_swap_out_victim+0x2b>
c0103f23:	68 11 92 10 c0       	push   $0xc0109211
c0103f28:	68 be 91 10 c0       	push   $0xc01091be
c0103f2d:	6a 54                	push   $0x54
c0103f2f:	68 d3 91 10 c0       	push   $0xc01091d3
c0103f34:	e8 af c4 ff ff       	call   c01003e8 <__panic>
    assert(in_tick==0);
c0103f39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103f3d:	74 16                	je     c0103f55 <_extended_clock_swap_out_victim+0x47>
c0103f3f:	68 f4 91 10 c0       	push   $0xc01091f4
c0103f44:	68 be 91 10 c0       	push   $0xc01091be
c0103f49:	6a 55                	push   $0x55
c0103f4b:	68 d3 91 10 c0       	push   $0xc01091d3
c0103f50:	e8 93 c4 ff ff       	call   c01003e8 <__panic>
    for (int i = 0; i < 3; i++) {
c0103f55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f5c:	e9 16 01 00 00       	jmp    c0104077 <_extended_clock_swap_out_victim+0x169>
        list_entry_t *le = head->prev;
c0103f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f64:	8b 00                	mov    (%eax),%eax
c0103f66:	89 45 f0             	mov    %eax,-0x10(%ebp)
        assert(head!=le);
c0103f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f6c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103f6f:	0f 85 f2 00 00 00    	jne    c0104067 <_extended_clock_swap_out_victim+0x159>
c0103f75:	68 ff 91 10 c0       	push   $0xc01091ff
c0103f7a:	68 be 91 10 c0       	push   $0xc01091be
c0103f7f:	6a 58                	push   $0x58
c0103f81:	68 d3 91 10 c0       	push   $0xc01091d3
c0103f86:	e8 5d c4 ff ff       	call   c01003e8 <__panic>
        while (le != head) {
            struct Page *p = le2page(le, pra_page_link);
c0103f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f8e:	83 e8 14             	sub    $0x14,%eax
c0103f91:	89 45 e8             	mov    %eax,-0x18(%ebp)
            pte_t* ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);
c0103f94:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f97:	8b 50 1c             	mov    0x1c(%eax),%edx
c0103f9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f9d:	8b 40 0c             	mov    0xc(%eax),%eax
c0103fa0:	83 ec 04             	sub    $0x4,%esp
c0103fa3:	6a 00                	push   $0x0
c0103fa5:	52                   	push   %edx
c0103fa6:	50                   	push   %eax
c0103fa7:	e8 10 28 00 00       	call   c01067bc <get_pte>
c0103fac:	83 c4 10             	add    $0x10,%esp
c0103faf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
c0103fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fb5:	8b 00                	mov    (%eax),%eax
c0103fb7:	83 e0 20             	and    $0x20,%eax
c0103fba:	85 c0                	test   %eax,%eax
c0103fbc:	75 5f                	jne    c010401d <_extended_clock_swap_out_victim+0x10f>
c0103fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fc1:	8b 00                	mov    (%eax),%eax
c0103fc3:	83 e0 40             	and    $0x40,%eax
c0103fc6:	85 c0                	test   %eax,%eax
c0103fc8:	75 53                	jne    c010401d <_extended_clock_swap_out_victim+0x10f>
c0103fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fcd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fd3:	8b 40 04             	mov    0x4(%eax),%eax
c0103fd6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fd9:	8b 12                	mov    (%edx),%edx
c0103fdb:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103fde:	89 45 d8             	mov    %eax,-0x28(%ebp)
    prev->next = next;
c0103fe1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103fe4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103fe7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103fea:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103fed:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ff0:	89 10                	mov    %edx,(%eax)
                list_del(le);
                assert(p != NULL);
c0103ff2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103ff6:	75 16                	jne    c010400e <_extended_clock_swap_out_victim+0x100>
c0103ff8:	68 1c 92 10 c0       	push   $0xc010921c
c0103ffd:	68 be 91 10 c0       	push   $0xc01091be
c0104002:	6a 5e                	push   $0x5e
c0104004:	68 d3 91 10 c0       	push   $0xc01091d3
c0104009:	e8 da c3 ff ff       	call   c01003e8 <__panic>
                *ptr_page = p;
c010400e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104011:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104014:	89 10                	mov    %edx,(%eax)
                return 0;
c0104016:	b8 00 00 00 00       	mov    $0x0,%eax
c010401b:	eb 69                	jmp    c0104086 <_extended_clock_swap_out_victim+0x178>
            }
            if (!i) {
c010401d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104021:	75 11                	jne    c0104034 <_extended_clock_swap_out_victim+0x126>
                *ptep &= ~PTE_A;
c0104023:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104026:	8b 00                	mov    (%eax),%eax
c0104028:	83 e0 df             	and    $0xffffffdf,%eax
c010402b:	89 c2                	mov    %eax,%edx
c010402d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104030:	89 10                	mov    %edx,(%eax)
c0104032:	eb 15                	jmp    c0104049 <_extended_clock_swap_out_victim+0x13b>
            }
            else if (i == 1) {
c0104034:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
c0104038:	75 0f                	jne    c0104049 <_extended_clock_swap_out_victim+0x13b>
                *ptep &= ~PTE_D;
c010403a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010403d:	8b 00                	mov    (%eax),%eax
c010403f:	83 e0 bf             	and    $0xffffffbf,%eax
c0104042:	89 c2                	mov    %eax,%edx
c0104044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104047:	89 10                	mov    %edx,(%eax)
            }
            le = le->prev;
c0104049:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010404c:	8b 00                	mov    (%eax),%eax
c010404e:	89 45 f0             	mov    %eax,-0x10(%ebp)
            tlb_invalidate(mm->pgdir, le);
c0104051:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104054:	8b 45 08             	mov    0x8(%ebp),%eax
c0104057:	8b 40 0c             	mov    0xc(%eax),%eax
c010405a:	83 ec 08             	sub    $0x8,%esp
c010405d:	52                   	push   %edx
c010405e:	50                   	push   %eax
c010405f:	e8 22 2a 00 00       	call   c0106a86 <tlb_invalidate>
c0104064:	83 c4 10             	add    $0x10,%esp
        while (le != head) {
c0104067:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010406a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010406d:	0f 85 18 ff ff ff    	jne    c0103f8b <_extended_clock_swap_out_victim+0x7d>
    for (int i = 0; i < 3; i++) {
c0104073:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104077:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
c010407b:	0f 8e e0 fe ff ff    	jle    c0103f61 <_extended_clock_swap_out_victim+0x53>
        }
    }
    return -1;
c0104081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c0104086:	c9                   	leave  
c0104087:	c3                   	ret    

c0104088 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0104088:	55                   	push   %ebp
c0104089:	89 e5                	mov    %esp,%ebp
c010408b:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c010408e:	83 ec 0c             	sub    $0xc,%esp
c0104091:	68 28 92 10 c0       	push   $0xc0109228
c0104096:	e8 e7 c1 ff ff       	call   c0100282 <cprintf>
c010409b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c010409e:	b8 00 30 00 00       	mov    $0x3000,%eax
c01040a3:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01040a6:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01040ab:	83 f8 04             	cmp    $0x4,%eax
c01040ae:	74 16                	je     c01040c6 <_fifo_check_swap+0x3e>
c01040b0:	68 4e 92 10 c0       	push   $0xc010924e
c01040b5:	68 be 91 10 c0       	push   $0xc01091be
c01040ba:	6a 73                	push   $0x73
c01040bc:	68 d3 91 10 c0       	push   $0xc01091d3
c01040c1:	e8 22 c3 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01040c6:	83 ec 0c             	sub    $0xc,%esp
c01040c9:	68 60 92 10 c0       	push   $0xc0109260
c01040ce:	e8 af c1 ff ff       	call   c0100282 <cprintf>
c01040d3:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c01040d6:	b8 00 10 00 00       	mov    $0x1000,%eax
c01040db:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01040de:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01040e3:	83 f8 04             	cmp    $0x4,%eax
c01040e6:	74 16                	je     c01040fe <_fifo_check_swap+0x76>
c01040e8:	68 4e 92 10 c0       	push   $0xc010924e
c01040ed:	68 be 91 10 c0       	push   $0xc01091be
c01040f2:	6a 76                	push   $0x76
c01040f4:	68 d3 91 10 c0       	push   $0xc01091d3
c01040f9:	e8 ea c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01040fe:	83 ec 0c             	sub    $0xc,%esp
c0104101:	68 88 92 10 c0       	push   $0xc0109288
c0104106:	e8 77 c1 ff ff       	call   c0100282 <cprintf>
c010410b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c010410e:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104113:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104116:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010411b:	83 f8 04             	cmp    $0x4,%eax
c010411e:	74 16                	je     c0104136 <_fifo_check_swap+0xae>
c0104120:	68 4e 92 10 c0       	push   $0xc010924e
c0104125:	68 be 91 10 c0       	push   $0xc01091be
c010412a:	6a 79                	push   $0x79
c010412c:	68 d3 91 10 c0       	push   $0xc01091d3
c0104131:	e8 b2 c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104136:	83 ec 0c             	sub    $0xc,%esp
c0104139:	68 b0 92 10 c0       	push   $0xc01092b0
c010413e:	e8 3f c1 ff ff       	call   c0100282 <cprintf>
c0104143:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0104146:	b8 00 20 00 00       	mov    $0x2000,%eax
c010414b:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010414e:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104153:	83 f8 04             	cmp    $0x4,%eax
c0104156:	74 16                	je     c010416e <_fifo_check_swap+0xe6>
c0104158:	68 4e 92 10 c0       	push   $0xc010924e
c010415d:	68 be 91 10 c0       	push   $0xc01091be
c0104162:	6a 7c                	push   $0x7c
c0104164:	68 d3 91 10 c0       	push   $0xc01091d3
c0104169:	e8 7a c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010416e:	83 ec 0c             	sub    $0xc,%esp
c0104171:	68 d8 92 10 c0       	push   $0xc01092d8
c0104176:	e8 07 c1 ff ff       	call   c0100282 <cprintf>
c010417b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c010417e:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104183:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104186:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010418b:	83 f8 05             	cmp    $0x5,%eax
c010418e:	74 16                	je     c01041a6 <_fifo_check_swap+0x11e>
c0104190:	68 fe 92 10 c0       	push   $0xc01092fe
c0104195:	68 be 91 10 c0       	push   $0xc01091be
c010419a:	6a 7f                	push   $0x7f
c010419c:	68 d3 91 10 c0       	push   $0xc01091d3
c01041a1:	e8 42 c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01041a6:	83 ec 0c             	sub    $0xc,%esp
c01041a9:	68 b0 92 10 c0       	push   $0xc01092b0
c01041ae:	e8 cf c0 ff ff       	call   c0100282 <cprintf>
c01041b3:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c01041b6:	b8 00 20 00 00       	mov    $0x2000,%eax
c01041bb:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01041be:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01041c3:	83 f8 05             	cmp    $0x5,%eax
c01041c6:	74 19                	je     c01041e1 <_fifo_check_swap+0x159>
c01041c8:	68 fe 92 10 c0       	push   $0xc01092fe
c01041cd:	68 be 91 10 c0       	push   $0xc01091be
c01041d2:	68 82 00 00 00       	push   $0x82
c01041d7:	68 d3 91 10 c0       	push   $0xc01091d3
c01041dc:	e8 07 c2 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01041e1:	83 ec 0c             	sub    $0xc,%esp
c01041e4:	68 60 92 10 c0       	push   $0xc0109260
c01041e9:	e8 94 c0 ff ff       	call   c0100282 <cprintf>
c01041ee:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c01041f1:	b8 00 10 00 00       	mov    $0x1000,%eax
c01041f6:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c01041f9:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01041fe:	83 f8 06             	cmp    $0x6,%eax
c0104201:	74 19                	je     c010421c <_fifo_check_swap+0x194>
c0104203:	68 0d 93 10 c0       	push   $0xc010930d
c0104208:	68 be 91 10 c0       	push   $0xc01091be
c010420d:	68 85 00 00 00       	push   $0x85
c0104212:	68 d3 91 10 c0       	push   $0xc01091d3
c0104217:	e8 cc c1 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010421c:	83 ec 0c             	sub    $0xc,%esp
c010421f:	68 b0 92 10 c0       	push   $0xc01092b0
c0104224:	e8 59 c0 ff ff       	call   c0100282 <cprintf>
c0104229:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010422c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104231:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0104234:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104239:	83 f8 07             	cmp    $0x7,%eax
c010423c:	74 19                	je     c0104257 <_fifo_check_swap+0x1cf>
c010423e:	68 1c 93 10 c0       	push   $0xc010931c
c0104243:	68 be 91 10 c0       	push   $0xc01091be
c0104248:	68 88 00 00 00       	push   $0x88
c010424d:	68 d3 91 10 c0       	push   $0xc01091d3
c0104252:	e8 91 c1 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104257:	83 ec 0c             	sub    $0xc,%esp
c010425a:	68 28 92 10 c0       	push   $0xc0109228
c010425f:	e8 1e c0 ff ff       	call   c0100282 <cprintf>
c0104264:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0104267:	b8 00 30 00 00       	mov    $0x3000,%eax
c010426c:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c010426f:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104274:	83 f8 08             	cmp    $0x8,%eax
c0104277:	74 19                	je     c0104292 <_fifo_check_swap+0x20a>
c0104279:	68 2b 93 10 c0       	push   $0xc010932b
c010427e:	68 be 91 10 c0       	push   $0xc01091be
c0104283:	68 8b 00 00 00       	push   $0x8b
c0104288:	68 d3 91 10 c0       	push   $0xc01091d3
c010428d:	e8 56 c1 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104292:	83 ec 0c             	sub    $0xc,%esp
c0104295:	68 88 92 10 c0       	push   $0xc0109288
c010429a:	e8 e3 bf ff ff       	call   c0100282 <cprintf>
c010429f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c01042a2:	b8 00 40 00 00       	mov    $0x4000,%eax
c01042a7:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01042aa:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01042af:	83 f8 09             	cmp    $0x9,%eax
c01042b2:	74 19                	je     c01042cd <_fifo_check_swap+0x245>
c01042b4:	68 3a 93 10 c0       	push   $0xc010933a
c01042b9:	68 be 91 10 c0       	push   $0xc01091be
c01042be:	68 8e 00 00 00       	push   $0x8e
c01042c3:	68 d3 91 10 c0       	push   $0xc01091d3
c01042c8:	e8 1b c1 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01042cd:	83 ec 0c             	sub    $0xc,%esp
c01042d0:	68 d8 92 10 c0       	push   $0xc01092d8
c01042d5:	e8 a8 bf ff ff       	call   c0100282 <cprintf>
c01042da:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c01042dd:	b8 00 50 00 00       	mov    $0x5000,%eax
c01042e2:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01042e5:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01042ea:	83 f8 0a             	cmp    $0xa,%eax
c01042ed:	74 19                	je     c0104308 <_fifo_check_swap+0x280>
c01042ef:	68 49 93 10 c0       	push   $0xc0109349
c01042f4:	68 be 91 10 c0       	push   $0xc01091be
c01042f9:	68 91 00 00 00       	push   $0x91
c01042fe:	68 d3 91 10 c0       	push   $0xc01091d3
c0104303:	e8 e0 c0 ff ff       	call   c01003e8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104308:	83 ec 0c             	sub    $0xc,%esp
c010430b:	68 60 92 10 c0       	push   $0xc0109260
c0104310:	e8 6d bf ff ff       	call   c0100282 <cprintf>
c0104315:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c0104318:	b8 00 10 00 00       	mov    $0x1000,%eax
c010431d:	0f b6 00             	movzbl (%eax),%eax
c0104320:	3c 0a                	cmp    $0xa,%al
c0104322:	74 19                	je     c010433d <_fifo_check_swap+0x2b5>
c0104324:	68 5c 93 10 c0       	push   $0xc010935c
c0104329:	68 be 91 10 c0       	push   $0xc01091be
c010432e:	68 93 00 00 00       	push   $0x93
c0104333:	68 d3 91 10 c0       	push   $0xc01091d3
c0104338:	e8 ab c0 ff ff       	call   c01003e8 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c010433d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104342:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0104345:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010434a:	83 f8 0b             	cmp    $0xb,%eax
c010434d:	74 19                	je     c0104368 <_fifo_check_swap+0x2e0>
c010434f:	68 7d 93 10 c0       	push   $0xc010937d
c0104354:	68 be 91 10 c0       	push   $0xc01091be
c0104359:	68 95 00 00 00       	push   $0x95
c010435e:	68 d3 91 10 c0       	push   $0xc01091d3
c0104363:	e8 80 c0 ff ff       	call   c01003e8 <__panic>
    return 0;
c0104368:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010436d:	c9                   	leave  
c010436e:	c3                   	ret    

c010436f <_fifo_init>:


static int
_fifo_init(void)
{
c010436f:	55                   	push   %ebp
c0104370:	89 e5                	mov    %esp,%ebp
    return 0;
c0104372:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104377:	5d                   	pop    %ebp
c0104378:	c3                   	ret    

c0104379 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104379:	55                   	push   %ebp
c010437a:	89 e5                	mov    %esp,%ebp
    return 0;
c010437c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104381:	5d                   	pop    %ebp
c0104382:	c3                   	ret    

c0104383 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104383:	55                   	push   %ebp
c0104384:	89 e5                	mov    %esp,%ebp
c0104386:	b8 00 00 00 00       	mov    $0x0,%eax
c010438b:	5d                   	pop    %ebp
c010438c:	c3                   	ret    

c010438d <pa2page>:
pa2page(uintptr_t pa) {
c010438d:	55                   	push   %ebp
c010438e:	89 e5                	mov    %esp,%ebp
c0104390:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104393:	8b 45 08             	mov    0x8(%ebp),%eax
c0104396:	c1 e8 0c             	shr    $0xc,%eax
c0104399:	89 c2                	mov    %eax,%edx
c010439b:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01043a0:	39 c2                	cmp    %eax,%edx
c01043a2:	72 14                	jb     c01043b8 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c01043a4:	83 ec 04             	sub    $0x4,%esp
c01043a7:	68 ac 93 10 c0       	push   $0xc01093ac
c01043ac:	6a 5b                	push   $0x5b
c01043ae:	68 cb 93 10 c0       	push   $0xc01093cb
c01043b3:	e8 30 c0 ff ff       	call   c01003e8 <__panic>
    return &pages[PPN(pa)];
c01043b8:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01043bd:	8b 55 08             	mov    0x8(%ebp),%edx
c01043c0:	c1 ea 0c             	shr    $0xc,%edx
c01043c3:	c1 e2 05             	shl    $0x5,%edx
c01043c6:	01 d0                	add    %edx,%eax
}
c01043c8:	c9                   	leave  
c01043c9:	c3                   	ret    

c01043ca <pte2page>:
pte2page(pte_t pte) {
c01043ca:	55                   	push   %ebp
c01043cb:	89 e5                	mov    %esp,%ebp
c01043cd:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c01043d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01043d3:	83 e0 01             	and    $0x1,%eax
c01043d6:	85 c0                	test   %eax,%eax
c01043d8:	75 14                	jne    c01043ee <pte2page+0x24>
        panic("pte2page called with invalid pte");
c01043da:	83 ec 04             	sub    $0x4,%esp
c01043dd:	68 dc 93 10 c0       	push   $0xc01093dc
c01043e2:	6a 6d                	push   $0x6d
c01043e4:	68 cb 93 10 c0       	push   $0xc01093cb
c01043e9:	e8 fa bf ff ff       	call   c01003e8 <__panic>
    return pa2page(PTE_ADDR(pte));
c01043ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01043f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01043f6:	83 ec 0c             	sub    $0xc,%esp
c01043f9:	50                   	push   %eax
c01043fa:	e8 8e ff ff ff       	call   c010438d <pa2page>
c01043ff:	83 c4 10             	add    $0x10,%esp
}
c0104402:	c9                   	leave  
c0104403:	c3                   	ret    

c0104404 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0104404:	55                   	push   %ebp
c0104405:	89 e5                	mov    %esp,%ebp
c0104407:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c010440a:	e8 cb 33 00 00       	call   c01077da <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010440f:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c0104414:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0104419:	76 0c                	jbe    c0104427 <swap_init+0x23>
c010441b:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c0104420:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0104425:	76 17                	jbe    c010443e <swap_init+0x3a>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0104427:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c010442c:	50                   	push   %eax
c010442d:	68 fd 93 10 c0       	push   $0xc01093fd
c0104432:	6a 25                	push   $0x25
c0104434:	68 18 94 10 c0       	push   $0xc0109418
c0104439:	e8 aa bf ff ff       	call   c01003e8 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010443e:	c7 05 70 3f 12 c0 e0 	movl   $0xc01209e0,0xc0123f70
c0104445:	09 12 c0 
     int r = sm->init();
c0104448:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010444d:	8b 40 04             	mov    0x4(%eax),%eax
c0104450:	ff d0                	call   *%eax
c0104452:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0104455:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104459:	75 27                	jne    c0104482 <swap_init+0x7e>
     {
          swap_init_ok = 1;
c010445b:	c7 05 68 3f 12 c0 01 	movl   $0x1,0xc0123f68
c0104462:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0104465:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010446a:	8b 00                	mov    (%eax),%eax
c010446c:	83 ec 08             	sub    $0x8,%esp
c010446f:	50                   	push   %eax
c0104470:	68 27 94 10 c0       	push   $0xc0109427
c0104475:	e8 08 be ff ff       	call   c0100282 <cprintf>
c010447a:	83 c4 10             	add    $0x10,%esp
          check_swap();
c010447d:	e8 f7 03 00 00       	call   c0104879 <check_swap>
     }

     return r;
c0104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104485:	c9                   	leave  
c0104486:	c3                   	ret    

c0104487 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0104487:	55                   	push   %ebp
c0104488:	89 e5                	mov    %esp,%ebp
c010448a:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c010448d:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104492:	8b 40 08             	mov    0x8(%eax),%eax
c0104495:	83 ec 0c             	sub    $0xc,%esp
c0104498:	ff 75 08             	pushl  0x8(%ebp)
c010449b:	ff d0                	call   *%eax
c010449d:	83 c4 10             	add    $0x10,%esp
}
c01044a0:	c9                   	leave  
c01044a1:	c3                   	ret    

c01044a2 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01044a2:	55                   	push   %ebp
c01044a3:	89 e5                	mov    %esp,%ebp
c01044a5:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c01044a8:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01044ad:	8b 40 0c             	mov    0xc(%eax),%eax
c01044b0:	83 ec 0c             	sub    $0xc,%esp
c01044b3:	ff 75 08             	pushl  0x8(%ebp)
c01044b6:	ff d0                	call   *%eax
c01044b8:	83 c4 10             	add    $0x10,%esp
}
c01044bb:	c9                   	leave  
c01044bc:	c3                   	ret    

c01044bd <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01044bd:	55                   	push   %ebp
c01044be:	89 e5                	mov    %esp,%ebp
c01044c0:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01044c3:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01044c8:	8b 40 10             	mov    0x10(%eax),%eax
c01044cb:	ff 75 14             	pushl  0x14(%ebp)
c01044ce:	ff 75 10             	pushl  0x10(%ebp)
c01044d1:	ff 75 0c             	pushl  0xc(%ebp)
c01044d4:	ff 75 08             	pushl  0x8(%ebp)
c01044d7:	ff d0                	call   *%eax
c01044d9:	83 c4 10             	add    $0x10,%esp
}
c01044dc:	c9                   	leave  
c01044dd:	c3                   	ret    

c01044de <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01044de:	55                   	push   %ebp
c01044df:	89 e5                	mov    %esp,%ebp
c01044e1:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c01044e4:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01044e9:	8b 40 14             	mov    0x14(%eax),%eax
c01044ec:	83 ec 08             	sub    $0x8,%esp
c01044ef:	ff 75 0c             	pushl  0xc(%ebp)
c01044f2:	ff 75 08             	pushl  0x8(%ebp)
c01044f5:	ff d0                	call   *%eax
c01044f7:	83 c4 10             	add    $0x10,%esp
}
c01044fa:	c9                   	leave  
c01044fb:	c3                   	ret    

c01044fc <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01044fc:	55                   	push   %ebp
c01044fd:	89 e5                	mov    %esp,%ebp
c01044ff:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104502:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104509:	e9 2e 01 00 00       	jmp    c010463c <swap_out+0x140>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c010450e:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104513:	8b 40 18             	mov    0x18(%eax),%eax
c0104516:	83 ec 04             	sub    $0x4,%esp
c0104519:	ff 75 10             	pushl  0x10(%ebp)
c010451c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c010451f:	52                   	push   %edx
c0104520:	ff 75 08             	pushl  0x8(%ebp)
c0104523:	ff d0                	call   *%eax
c0104525:	83 c4 10             	add    $0x10,%esp
c0104528:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c010452b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010452f:	74 18                	je     c0104549 <swap_out+0x4d>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104531:	83 ec 08             	sub    $0x8,%esp
c0104534:	ff 75 f4             	pushl  -0xc(%ebp)
c0104537:	68 3c 94 10 c0       	push   $0xc010943c
c010453c:	e8 41 bd ff ff       	call   c0100282 <cprintf>
c0104541:	83 c4 10             	add    $0x10,%esp
c0104544:	e9 ff 00 00 00       	jmp    c0104648 <swap_out+0x14c>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0104549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010454c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010454f:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0104552:	8b 45 08             	mov    0x8(%ebp),%eax
c0104555:	8b 40 0c             	mov    0xc(%eax),%eax
c0104558:	83 ec 04             	sub    $0x4,%esp
c010455b:	6a 00                	push   $0x0
c010455d:	ff 75 ec             	pushl  -0x14(%ebp)
c0104560:	50                   	push   %eax
c0104561:	e8 56 22 00 00       	call   c01067bc <get_pte>
c0104566:	83 c4 10             	add    $0x10,%esp
c0104569:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010456c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010456f:	8b 00                	mov    (%eax),%eax
c0104571:	83 e0 01             	and    $0x1,%eax
c0104574:	85 c0                	test   %eax,%eax
c0104576:	75 16                	jne    c010458e <swap_out+0x92>
c0104578:	68 69 94 10 c0       	push   $0xc0109469
c010457d:	68 7e 94 10 c0       	push   $0xc010947e
c0104582:	6a 65                	push   $0x65
c0104584:	68 18 94 10 c0       	push   $0xc0109418
c0104589:	e8 5a be ff ff       	call   c01003e8 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c010458e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104591:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104594:	8b 52 1c             	mov    0x1c(%edx),%edx
c0104597:	c1 ea 0c             	shr    $0xc,%edx
c010459a:	83 c2 01             	add    $0x1,%edx
c010459d:	c1 e2 08             	shl    $0x8,%edx
c01045a0:	83 ec 08             	sub    $0x8,%esp
c01045a3:	50                   	push   %eax
c01045a4:	52                   	push   %edx
c01045a5:	e8 cc 32 00 00       	call   c0107876 <swapfs_write>
c01045aa:	83 c4 10             	add    $0x10,%esp
c01045ad:	85 c0                	test   %eax,%eax
c01045af:	74 2b                	je     c01045dc <swap_out+0xe0>
                    cprintf("SWAP: failed to save\n");
c01045b1:	83 ec 0c             	sub    $0xc,%esp
c01045b4:	68 93 94 10 c0       	push   $0xc0109493
c01045b9:	e8 c4 bc ff ff       	call   c0100282 <cprintf>
c01045be:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c01045c1:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01045c6:	8b 40 10             	mov    0x10(%eax),%eax
c01045c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01045cc:	6a 00                	push   $0x0
c01045ce:	52                   	push   %edx
c01045cf:	ff 75 ec             	pushl  -0x14(%ebp)
c01045d2:	ff 75 08             	pushl  0x8(%ebp)
c01045d5:	ff d0                	call   *%eax
c01045d7:	83 c4 10             	add    $0x10,%esp
c01045da:	eb 5c                	jmp    c0104638 <swap_out+0x13c>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01045dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045df:	8b 40 1c             	mov    0x1c(%eax),%eax
c01045e2:	c1 e8 0c             	shr    $0xc,%eax
c01045e5:	83 c0 01             	add    $0x1,%eax
c01045e8:	50                   	push   %eax
c01045e9:	ff 75 ec             	pushl  -0x14(%ebp)
c01045ec:	ff 75 f4             	pushl  -0xc(%ebp)
c01045ef:	68 ac 94 10 c0       	push   $0xc01094ac
c01045f4:	e8 89 bc ff ff       	call   c0100282 <cprintf>
c01045f9:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01045fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045ff:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104602:	c1 e8 0c             	shr    $0xc,%eax
c0104605:	83 c0 01             	add    $0x1,%eax
c0104608:	c1 e0 08             	shl    $0x8,%eax
c010460b:	89 c2                	mov    %eax,%edx
c010460d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104610:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104615:	83 ec 08             	sub    $0x8,%esp
c0104618:	6a 01                	push   $0x1
c010461a:	50                   	push   %eax
c010461b:	e8 93 1b 00 00       	call   c01061b3 <free_pages>
c0104620:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104623:	8b 45 08             	mov    0x8(%ebp),%eax
c0104626:	8b 40 0c             	mov    0xc(%eax),%eax
c0104629:	83 ec 08             	sub    $0x8,%esp
c010462c:	ff 75 ec             	pushl  -0x14(%ebp)
c010462f:	50                   	push   %eax
c0104630:	e8 51 24 00 00       	call   c0106a86 <tlb_invalidate>
c0104635:	83 c4 10             	add    $0x10,%esp
     for (i = 0; i != n; ++ i)
c0104638:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010463c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010463f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104642:	0f 85 c6 fe ff ff    	jne    c010450e <swap_out+0x12>
     }
     return i;
c0104648:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010464b:	c9                   	leave  
c010464c:	c3                   	ret    

c010464d <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010464d:	55                   	push   %ebp
c010464e:	89 e5                	mov    %esp,%ebp
c0104650:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c0104653:	83 ec 0c             	sub    $0xc,%esp
c0104656:	6a 01                	push   $0x1
c0104658:	e8 ea 1a 00 00       	call   c0106147 <alloc_pages>
c010465d:	83 c4 10             	add    $0x10,%esp
c0104660:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104663:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104667:	75 16                	jne    c010467f <swap_in+0x32>
c0104669:	68 ec 94 10 c0       	push   $0xc01094ec
c010466e:	68 7e 94 10 c0       	push   $0xc010947e
c0104673:	6a 7b                	push   $0x7b
c0104675:	68 18 94 10 c0       	push   $0xc0109418
c010467a:	e8 69 bd ff ff       	call   c01003e8 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c010467f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104682:	8b 40 0c             	mov    0xc(%eax),%eax
c0104685:	83 ec 04             	sub    $0x4,%esp
c0104688:	6a 00                	push   $0x0
c010468a:	ff 75 0c             	pushl  0xc(%ebp)
c010468d:	50                   	push   %eax
c010468e:	e8 29 21 00 00       	call   c01067bc <get_pte>
c0104693:	83 c4 10             	add    $0x10,%esp
c0104696:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0104699:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010469c:	8b 00                	mov    (%eax),%eax
c010469e:	83 ec 08             	sub    $0x8,%esp
c01046a1:	ff 75 f4             	pushl  -0xc(%ebp)
c01046a4:	50                   	push   %eax
c01046a5:	e8 73 31 00 00       	call   c010781d <swapfs_read>
c01046aa:	83 c4 10             	add    $0x10,%esp
c01046ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01046b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01046b4:	74 1f                	je     c01046d5 <swap_in+0x88>
     {
        assert(r!=0);
c01046b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01046ba:	75 19                	jne    c01046d5 <swap_in+0x88>
c01046bc:	68 f9 94 10 c0       	push   $0xc01094f9
c01046c1:	68 7e 94 10 c0       	push   $0xc010947e
c01046c6:	68 83 00 00 00       	push   $0x83
c01046cb:	68 18 94 10 c0       	push   $0xc0109418
c01046d0:	e8 13 bd ff ff       	call   c01003e8 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01046d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046d8:	8b 00                	mov    (%eax),%eax
c01046da:	c1 e8 08             	shr    $0x8,%eax
c01046dd:	83 ec 04             	sub    $0x4,%esp
c01046e0:	ff 75 0c             	pushl  0xc(%ebp)
c01046e3:	50                   	push   %eax
c01046e4:	68 00 95 10 c0       	push   $0xc0109500
c01046e9:	e8 94 bb ff ff       	call   c0100282 <cprintf>
c01046ee:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c01046f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01046f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01046f7:	89 10                	mov    %edx,(%eax)
     return 0;
c01046f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01046fe:	c9                   	leave  
c01046ff:	c3                   	ret    

c0104700 <check_content_set>:



static inline void
check_content_set(void)
{
c0104700:	55                   	push   %ebp
c0104701:	89 e5                	mov    %esp,%ebp
c0104703:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0104706:	b8 00 10 00 00       	mov    $0x1000,%eax
c010470b:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010470e:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104713:	83 f8 01             	cmp    $0x1,%eax
c0104716:	74 19                	je     c0104731 <check_content_set+0x31>
c0104718:	68 3e 95 10 c0       	push   $0xc010953e
c010471d:	68 7e 94 10 c0       	push   $0xc010947e
c0104722:	68 90 00 00 00       	push   $0x90
c0104727:	68 18 94 10 c0       	push   $0xc0109418
c010472c:	e8 b7 bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104731:	b8 10 10 00 00       	mov    $0x1010,%eax
c0104736:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104739:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010473e:	83 f8 01             	cmp    $0x1,%eax
c0104741:	74 19                	je     c010475c <check_content_set+0x5c>
c0104743:	68 3e 95 10 c0       	push   $0xc010953e
c0104748:	68 7e 94 10 c0       	push   $0xc010947e
c010474d:	68 92 00 00 00       	push   $0x92
c0104752:	68 18 94 10 c0       	push   $0xc0109418
c0104757:	e8 8c bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c010475c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104761:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104764:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104769:	83 f8 02             	cmp    $0x2,%eax
c010476c:	74 19                	je     c0104787 <check_content_set+0x87>
c010476e:	68 4d 95 10 c0       	push   $0xc010954d
c0104773:	68 7e 94 10 c0       	push   $0xc010947e
c0104778:	68 94 00 00 00       	push   $0x94
c010477d:	68 18 94 10 c0       	push   $0xc0109418
c0104782:	e8 61 bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0104787:	b8 10 20 00 00       	mov    $0x2010,%eax
c010478c:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010478f:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104794:	83 f8 02             	cmp    $0x2,%eax
c0104797:	74 19                	je     c01047b2 <check_content_set+0xb2>
c0104799:	68 4d 95 10 c0       	push   $0xc010954d
c010479e:	68 7e 94 10 c0       	push   $0xc010947e
c01047a3:	68 96 00 00 00       	push   $0x96
c01047a8:	68 18 94 10 c0       	push   $0xc0109418
c01047ad:	e8 36 bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01047b2:	b8 00 30 00 00       	mov    $0x3000,%eax
c01047b7:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01047ba:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01047bf:	83 f8 03             	cmp    $0x3,%eax
c01047c2:	74 19                	je     c01047dd <check_content_set+0xdd>
c01047c4:	68 5c 95 10 c0       	push   $0xc010955c
c01047c9:	68 7e 94 10 c0       	push   $0xc010947e
c01047ce:	68 98 00 00 00       	push   $0x98
c01047d3:	68 18 94 10 c0       	push   $0xc0109418
c01047d8:	e8 0b bc ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01047dd:	b8 10 30 00 00       	mov    $0x3010,%eax
c01047e2:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01047e5:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01047ea:	83 f8 03             	cmp    $0x3,%eax
c01047ed:	74 19                	je     c0104808 <check_content_set+0x108>
c01047ef:	68 5c 95 10 c0       	push   $0xc010955c
c01047f4:	68 7e 94 10 c0       	push   $0xc010947e
c01047f9:	68 9a 00 00 00       	push   $0x9a
c01047fe:	68 18 94 10 c0       	push   $0xc0109418
c0104803:	e8 e0 bb ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0104808:	b8 00 40 00 00       	mov    $0x4000,%eax
c010480d:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104810:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104815:	83 f8 04             	cmp    $0x4,%eax
c0104818:	74 19                	je     c0104833 <check_content_set+0x133>
c010481a:	68 6b 95 10 c0       	push   $0xc010956b
c010481f:	68 7e 94 10 c0       	push   $0xc010947e
c0104824:	68 9c 00 00 00       	push   $0x9c
c0104829:	68 18 94 10 c0       	push   $0xc0109418
c010482e:	e8 b5 bb ff ff       	call   c01003e8 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0104833:	b8 10 40 00 00       	mov    $0x4010,%eax
c0104838:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010483b:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104840:	83 f8 04             	cmp    $0x4,%eax
c0104843:	74 19                	je     c010485e <check_content_set+0x15e>
c0104845:	68 6b 95 10 c0       	push   $0xc010956b
c010484a:	68 7e 94 10 c0       	push   $0xc010947e
c010484f:	68 9e 00 00 00       	push   $0x9e
c0104854:	68 18 94 10 c0       	push   $0xc0109418
c0104859:	e8 8a bb ff ff       	call   c01003e8 <__panic>
}
c010485e:	90                   	nop
c010485f:	c9                   	leave  
c0104860:	c3                   	ret    

c0104861 <check_content_access>:

static inline int
check_content_access(void)
{
c0104861:	55                   	push   %ebp
c0104862:	89 e5                	mov    %esp,%ebp
c0104864:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0104867:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010486c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010486f:	ff d0                	call   *%eax
c0104871:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104874:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104877:	c9                   	leave  
c0104878:	c3                   	ret    

c0104879 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0104879:	55                   	push   %ebp
c010487a:	89 e5                	mov    %esp,%ebp
c010487c:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010487f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104886:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010488d:	c7 45 e8 e4 40 12 c0 	movl   $0xc01240e4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104894:	eb 60                	jmp    c01048f6 <check_swap+0x7d>
        struct Page *p = le2page(le, page_link);
c0104896:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104899:	83 e8 0c             	sub    $0xc,%eax
c010489c:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c010489f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01048a2:	83 c0 04             	add    $0x4,%eax
c01048a5:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01048ac:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01048af:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01048b2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01048b5:	0f a3 10             	bt     %edx,(%eax)
c01048b8:	19 c0                	sbb    %eax,%eax
c01048ba:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01048bd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01048c1:	0f 95 c0             	setne  %al
c01048c4:	0f b6 c0             	movzbl %al,%eax
c01048c7:	85 c0                	test   %eax,%eax
c01048c9:	75 19                	jne    c01048e4 <check_swap+0x6b>
c01048cb:	68 7a 95 10 c0       	push   $0xc010957a
c01048d0:	68 7e 94 10 c0       	push   $0xc010947e
c01048d5:	68 b9 00 00 00       	push   $0xb9
c01048da:	68 18 94 10 c0       	push   $0xc0109418
c01048df:	e8 04 bb ff ff       	call   c01003e8 <__panic>
        count ++, total += p->property;
c01048e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01048e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01048eb:	8b 50 08             	mov    0x8(%eax),%edx
c01048ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048f1:	01 d0                	add    %edx,%eax
c01048f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01048f9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c01048fc:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01048ff:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0104902:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104905:	81 7d e8 e4 40 12 c0 	cmpl   $0xc01240e4,-0x18(%ebp)
c010490c:	75 88                	jne    c0104896 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c010490e:	e8 d5 18 00 00       	call   c01061e8 <nr_free_pages>
c0104913:	89 c2                	mov    %eax,%edx
c0104915:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104918:	39 c2                	cmp    %eax,%edx
c010491a:	74 19                	je     c0104935 <check_swap+0xbc>
c010491c:	68 8a 95 10 c0       	push   $0xc010958a
c0104921:	68 7e 94 10 c0       	push   $0xc010947e
c0104926:	68 bc 00 00 00       	push   $0xbc
c010492b:	68 18 94 10 c0       	push   $0xc0109418
c0104930:	e8 b3 ba ff ff       	call   c01003e8 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104935:	83 ec 04             	sub    $0x4,%esp
c0104938:	ff 75 f0             	pushl  -0x10(%ebp)
c010493b:	ff 75 f4             	pushl  -0xc(%ebp)
c010493e:	68 a4 95 10 c0       	push   $0xc01095a4
c0104943:	e8 3a b9 ff ff       	call   c0100282 <cprintf>
c0104948:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c010494b:	e8 2a e8 ff ff       	call   c010317a <mm_create>
c0104950:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0104953:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104957:	75 19                	jne    c0104972 <check_swap+0xf9>
c0104959:	68 ca 95 10 c0       	push   $0xc01095ca
c010495e:	68 7e 94 10 c0       	push   $0xc010947e
c0104963:	68 c1 00 00 00       	push   $0xc1
c0104968:	68 18 94 10 c0       	push   $0xc0109418
c010496d:	e8 76 ba ff ff       	call   c01003e8 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0104972:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0104977:	85 c0                	test   %eax,%eax
c0104979:	74 19                	je     c0104994 <check_swap+0x11b>
c010497b:	68 d5 95 10 c0       	push   $0xc01095d5
c0104980:	68 7e 94 10 c0       	push   $0xc010947e
c0104985:	68 c4 00 00 00       	push   $0xc4
c010498a:	68 18 94 10 c0       	push   $0xc0109418
c010498f:	e8 54 ba ff ff       	call   c01003e8 <__panic>

     check_mm_struct = mm;
c0104994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104997:	a3 10 40 12 c0       	mov    %eax,0xc0124010

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c010499c:	8b 15 00 0a 12 c0    	mov    0xc0120a00,%edx
c01049a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049a5:	89 50 0c             	mov    %edx,0xc(%eax)
c01049a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049ab:	8b 40 0c             	mov    0xc(%eax),%eax
c01049ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c01049b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049b4:	8b 00                	mov    (%eax),%eax
c01049b6:	85 c0                	test   %eax,%eax
c01049b8:	74 19                	je     c01049d3 <check_swap+0x15a>
c01049ba:	68 ed 95 10 c0       	push   $0xc01095ed
c01049bf:	68 7e 94 10 c0       	push   $0xc010947e
c01049c4:	68 c9 00 00 00       	push   $0xc9
c01049c9:	68 18 94 10 c0       	push   $0xc0109418
c01049ce:	e8 15 ba ff ff       	call   c01003e8 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01049d3:	83 ec 04             	sub    $0x4,%esp
c01049d6:	6a 03                	push   $0x3
c01049d8:	68 00 60 00 00       	push   $0x6000
c01049dd:	68 00 10 00 00       	push   $0x1000
c01049e2:	e8 0f e8 ff ff       	call   c01031f6 <vma_create>
c01049e7:	83 c4 10             	add    $0x10,%esp
c01049ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c01049ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01049f1:	75 19                	jne    c0104a0c <check_swap+0x193>
c01049f3:	68 fb 95 10 c0       	push   $0xc01095fb
c01049f8:	68 7e 94 10 c0       	push   $0xc010947e
c01049fd:	68 cc 00 00 00       	push   $0xcc
c0104a02:	68 18 94 10 c0       	push   $0xc0109418
c0104a07:	e8 dc b9 ff ff       	call   c01003e8 <__panic>

     insert_vma_struct(mm, vma);
c0104a0c:	83 ec 08             	sub    $0x8,%esp
c0104a0f:	ff 75 dc             	pushl  -0x24(%ebp)
c0104a12:	ff 75 e4             	pushl  -0x1c(%ebp)
c0104a15:	e8 44 e9 ff ff       	call   c010335e <insert_vma_struct>
c0104a1a:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0104a1d:	83 ec 0c             	sub    $0xc,%esp
c0104a20:	68 08 96 10 c0       	push   $0xc0109608
c0104a25:	e8 58 b8 ff ff       	call   c0100282 <cprintf>
c0104a2a:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c0104a2d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a37:	8b 40 0c             	mov    0xc(%eax),%eax
c0104a3a:	83 ec 04             	sub    $0x4,%esp
c0104a3d:	6a 01                	push   $0x1
c0104a3f:	68 00 10 00 00       	push   $0x1000
c0104a44:	50                   	push   %eax
c0104a45:	e8 72 1d 00 00       	call   c01067bc <get_pte>
c0104a4a:	83 c4 10             	add    $0x10,%esp
c0104a4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0104a50:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104a54:	75 19                	jne    c0104a6f <check_swap+0x1f6>
c0104a56:	68 3c 96 10 c0       	push   $0xc010963c
c0104a5b:	68 7e 94 10 c0       	push   $0xc010947e
c0104a60:	68 d4 00 00 00       	push   $0xd4
c0104a65:	68 18 94 10 c0       	push   $0xc0109418
c0104a6a:	e8 79 b9 ff ff       	call   c01003e8 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0104a6f:	83 ec 0c             	sub    $0xc,%esp
c0104a72:	68 50 96 10 c0       	push   $0xc0109650
c0104a77:	e8 06 b8 ff ff       	call   c0100282 <cprintf>
c0104a7c:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104a7f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104a86:	e9 90 00 00 00       	jmp    c0104b1b <check_swap+0x2a2>
          check_rp[i] = alloc_page();
c0104a8b:	83 ec 0c             	sub    $0xc,%esp
c0104a8e:	6a 01                	push   $0x1
c0104a90:	e8 b2 16 00 00       	call   c0106147 <alloc_pages>
c0104a95:	83 c4 10             	add    $0x10,%esp
c0104a98:	89 c2                	mov    %eax,%edx
c0104a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a9d:	89 14 85 20 40 12 c0 	mov    %edx,-0x3fedbfe0(,%eax,4)
          assert(check_rp[i] != NULL );
c0104aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104aa7:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104aae:	85 c0                	test   %eax,%eax
c0104ab0:	75 19                	jne    c0104acb <check_swap+0x252>
c0104ab2:	68 74 96 10 c0       	push   $0xc0109674
c0104ab7:	68 7e 94 10 c0       	push   $0xc010947e
c0104abc:	68 d9 00 00 00       	push   $0xd9
c0104ac1:	68 18 94 10 c0       	push   $0xc0109418
c0104ac6:	e8 1d b9 ff ff       	call   c01003e8 <__panic>
          assert(!PageProperty(check_rp[i]));
c0104acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ace:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104ad5:	83 c0 04             	add    $0x4,%eax
c0104ad8:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0104adf:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ae2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104ae5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104ae8:	0f a3 10             	bt     %edx,(%eax)
c0104aeb:	19 c0                	sbb    %eax,%eax
c0104aed:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0104af0:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0104af4:	0f 95 c0             	setne  %al
c0104af7:	0f b6 c0             	movzbl %al,%eax
c0104afa:	85 c0                	test   %eax,%eax
c0104afc:	74 19                	je     c0104b17 <check_swap+0x29e>
c0104afe:	68 88 96 10 c0       	push   $0xc0109688
c0104b03:	68 7e 94 10 c0       	push   $0xc010947e
c0104b08:	68 da 00 00 00       	push   $0xda
c0104b0d:	68 18 94 10 c0       	push   $0xc0109418
c0104b12:	e8 d1 b8 ff ff       	call   c01003e8 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104b17:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104b1b:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104b1f:	0f 8e 66 ff ff ff    	jle    c0104a8b <check_swap+0x212>
     }
     list_entry_t free_list_store = free_list;
c0104b25:	a1 e4 40 12 c0       	mov    0xc01240e4,%eax
c0104b2a:	8b 15 e8 40 12 c0    	mov    0xc01240e8,%edx
c0104b30:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104b33:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0104b36:	c7 45 a4 e4 40 12 c0 	movl   $0xc01240e4,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0104b3d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104b40:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104b43:	89 50 04             	mov    %edx,0x4(%eax)
c0104b46:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104b49:	8b 50 04             	mov    0x4(%eax),%edx
c0104b4c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104b4f:	89 10                	mov    %edx,(%eax)
c0104b51:	c7 45 a8 e4 40 12 c0 	movl   $0xc01240e4,-0x58(%ebp)
    return list->next == list;
c0104b58:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104b5b:	8b 40 04             	mov    0x4(%eax),%eax
c0104b5e:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0104b61:	0f 94 c0             	sete   %al
c0104b64:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0104b67:	85 c0                	test   %eax,%eax
c0104b69:	75 19                	jne    c0104b84 <check_swap+0x30b>
c0104b6b:	68 a3 96 10 c0       	push   $0xc01096a3
c0104b70:	68 7e 94 10 c0       	push   $0xc010947e
c0104b75:	68 de 00 00 00       	push   $0xde
c0104b7a:	68 18 94 10 c0       	push   $0xc0109418
c0104b7f:	e8 64 b8 ff ff       	call   c01003e8 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0104b84:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104b89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0104b8c:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c0104b93:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104b96:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104b9d:	eb 1c                	jmp    c0104bbb <check_swap+0x342>
        free_pages(check_rp[i],1);
c0104b9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ba2:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104ba9:	83 ec 08             	sub    $0x8,%esp
c0104bac:	6a 01                	push   $0x1
c0104bae:	50                   	push   %eax
c0104baf:	e8 ff 15 00 00       	call   c01061b3 <free_pages>
c0104bb4:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104bb7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104bbb:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104bbf:	7e de                	jle    c0104b9f <check_swap+0x326>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0104bc1:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104bc6:	83 f8 04             	cmp    $0x4,%eax
c0104bc9:	74 19                	je     c0104be4 <check_swap+0x36b>
c0104bcb:	68 bc 96 10 c0       	push   $0xc01096bc
c0104bd0:	68 7e 94 10 c0       	push   $0xc010947e
c0104bd5:	68 e7 00 00 00       	push   $0xe7
c0104bda:	68 18 94 10 c0       	push   $0xc0109418
c0104bdf:	e8 04 b8 ff ff       	call   c01003e8 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0104be4:	83 ec 0c             	sub    $0xc,%esp
c0104be7:	68 e0 96 10 c0       	push   $0xc01096e0
c0104bec:	e8 91 b6 ff ff       	call   c0100282 <cprintf>
c0104bf1:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0104bf4:	c7 05 64 3f 12 c0 00 	movl   $0x0,0xc0123f64
c0104bfb:	00 00 00 
     
     check_content_set();
c0104bfe:	e8 fd fa ff ff       	call   c0104700 <check_content_set>
     assert( nr_free == 0);         
c0104c03:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104c08:	85 c0                	test   %eax,%eax
c0104c0a:	74 19                	je     c0104c25 <check_swap+0x3ac>
c0104c0c:	68 07 97 10 c0       	push   $0xc0109707
c0104c11:	68 7e 94 10 c0       	push   $0xc010947e
c0104c16:	68 f0 00 00 00       	push   $0xf0
c0104c1b:	68 18 94 10 c0       	push   $0xc0109418
c0104c20:	e8 c3 b7 ff ff       	call   c01003e8 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104c25:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104c2c:	eb 26                	jmp    c0104c54 <check_swap+0x3db>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0104c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c31:	c7 04 85 40 40 12 c0 	movl   $0xffffffff,-0x3fedbfc0(,%eax,4)
c0104c38:	ff ff ff ff 
c0104c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c3f:	8b 14 85 40 40 12 c0 	mov    -0x3fedbfc0(,%eax,4),%edx
c0104c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c49:	89 14 85 80 40 12 c0 	mov    %edx,-0x3fedbf80(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104c50:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104c54:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0104c58:	7e d4                	jle    c0104c2e <check_swap+0x3b5>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104c5a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104c61:	e9 cc 00 00 00       	jmp    c0104d32 <check_swap+0x4b9>
         check_ptep[i]=0;
c0104c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c69:	c7 04 85 d4 40 12 c0 	movl   $0x0,-0x3fedbf2c(,%eax,4)
c0104c70:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0104c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c77:	83 c0 01             	add    $0x1,%eax
c0104c7a:	c1 e0 0c             	shl    $0xc,%eax
c0104c7d:	83 ec 04             	sub    $0x4,%esp
c0104c80:	6a 00                	push   $0x0
c0104c82:	50                   	push   %eax
c0104c83:	ff 75 e0             	pushl  -0x20(%ebp)
c0104c86:	e8 31 1b 00 00       	call   c01067bc <get_pte>
c0104c8b:	83 c4 10             	add    $0x10,%esp
c0104c8e:	89 c2                	mov    %eax,%edx
c0104c90:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c93:	89 14 85 d4 40 12 c0 	mov    %edx,-0x3fedbf2c(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0104c9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c9d:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104ca4:	85 c0                	test   %eax,%eax
c0104ca6:	75 19                	jne    c0104cc1 <check_swap+0x448>
c0104ca8:	68 14 97 10 c0       	push   $0xc0109714
c0104cad:	68 7e 94 10 c0       	push   $0xc010947e
c0104cb2:	68 f8 00 00 00       	push   $0xf8
c0104cb7:	68 18 94 10 c0       	push   $0xc0109418
c0104cbc:	e8 27 b7 ff ff       	call   c01003e8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0104cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cc4:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104ccb:	8b 00                	mov    (%eax),%eax
c0104ccd:	83 ec 0c             	sub    $0xc,%esp
c0104cd0:	50                   	push   %eax
c0104cd1:	e8 f4 f6 ff ff       	call   c01043ca <pte2page>
c0104cd6:	83 c4 10             	add    $0x10,%esp
c0104cd9:	89 c2                	mov    %eax,%edx
c0104cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cde:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104ce5:	39 c2                	cmp    %eax,%edx
c0104ce7:	74 19                	je     c0104d02 <check_swap+0x489>
c0104ce9:	68 2c 97 10 c0       	push   $0xc010972c
c0104cee:	68 7e 94 10 c0       	push   $0xc010947e
c0104cf3:	68 f9 00 00 00       	push   $0xf9
c0104cf8:	68 18 94 10 c0       	push   $0xc0109418
c0104cfd:	e8 e6 b6 ff ff       	call   c01003e8 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0104d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d05:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104d0c:	8b 00                	mov    (%eax),%eax
c0104d0e:	83 e0 01             	and    $0x1,%eax
c0104d11:	85 c0                	test   %eax,%eax
c0104d13:	75 19                	jne    c0104d2e <check_swap+0x4b5>
c0104d15:	68 54 97 10 c0       	push   $0xc0109754
c0104d1a:	68 7e 94 10 c0       	push   $0xc010947e
c0104d1f:	68 fa 00 00 00       	push   $0xfa
c0104d24:	68 18 94 10 c0       	push   $0xc0109418
c0104d29:	e8 ba b6 ff ff       	call   c01003e8 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104d2e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104d32:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104d36:	0f 8e 2a ff ff ff    	jle    c0104c66 <check_swap+0x3ed>
     }
     cprintf("set up init env for check_swap over!\n");
c0104d3c:	83 ec 0c             	sub    $0xc,%esp
c0104d3f:	68 70 97 10 c0       	push   $0xc0109770
c0104d44:	e8 39 b5 ff ff       	call   c0100282 <cprintf>
c0104d49:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0104d4c:	e8 10 fb ff ff       	call   c0104861 <check_content_access>
c0104d51:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0104d54:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0104d58:	74 19                	je     c0104d73 <check_swap+0x4fa>
c0104d5a:	68 96 97 10 c0       	push   $0xc0109796
c0104d5f:	68 7e 94 10 c0       	push   $0xc010947e
c0104d64:	68 ff 00 00 00       	push   $0xff
c0104d69:	68 18 94 10 c0       	push   $0xc0109418
c0104d6e:	e8 75 b6 ff ff       	call   c01003e8 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104d73:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104d7a:	eb 1c                	jmp    c0104d98 <check_swap+0x51f>
         free_pages(check_rp[i],1);
c0104d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d7f:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104d86:	83 ec 08             	sub    $0x8,%esp
c0104d89:	6a 01                	push   $0x1
c0104d8b:	50                   	push   %eax
c0104d8c:	e8 22 14 00 00       	call   c01061b3 <free_pages>
c0104d91:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104d94:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104d98:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104d9c:	7e de                	jle    c0104d7c <check_swap+0x503>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0104d9e:	83 ec 0c             	sub    $0xc,%esp
c0104da1:	ff 75 e4             	pushl  -0x1c(%ebp)
c0104da4:	e8 d9 e6 ff ff       	call   c0103482 <mm_destroy>
c0104da9:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0104dac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104daf:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
     free_list = free_list_store;
c0104db4:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104db7:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104dba:	a3 e4 40 12 c0       	mov    %eax,0xc01240e4
c0104dbf:	89 15 e8 40 12 c0    	mov    %edx,0xc01240e8

     
     le = &free_list;
c0104dc5:	c7 45 e8 e4 40 12 c0 	movl   $0xc01240e4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104dcc:	eb 1d                	jmp    c0104deb <check_swap+0x572>
         struct Page *p = le2page(le, page_link);
c0104dce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dd1:	83 e8 0c             	sub    $0xc,%eax
c0104dd4:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0104dd7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104ddb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104dde:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104de1:	8b 40 08             	mov    0x8(%eax),%eax
c0104de4:	29 c2                	sub    %eax,%edx
c0104de6:	89 d0                	mov    %edx,%eax
c0104de8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104deb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dee:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0104df1:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104df4:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0104df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104dfa:	81 7d e8 e4 40 12 c0 	cmpl   $0xc01240e4,-0x18(%ebp)
c0104e01:	75 cb                	jne    c0104dce <check_swap+0x555>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0104e03:	83 ec 04             	sub    $0x4,%esp
c0104e06:	ff 75 f0             	pushl  -0x10(%ebp)
c0104e09:	ff 75 f4             	pushl  -0xc(%ebp)
c0104e0c:	68 9d 97 10 c0       	push   $0xc010979d
c0104e11:	e8 6c b4 ff ff       	call   c0100282 <cprintf>
c0104e16:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0104e19:	83 ec 0c             	sub    $0xc,%esp
c0104e1c:	68 b7 97 10 c0       	push   $0xc01097b7
c0104e21:	e8 5c b4 ff ff       	call   c0100282 <cprintf>
c0104e26:	83 c4 10             	add    $0x10,%esp
}
c0104e29:	90                   	nop
c0104e2a:	c9                   	leave  
c0104e2b:	c3                   	ret    

c0104e2c <page2ppn>:
page2ppn(struct Page *page) {
c0104e2c:	55                   	push   %ebp
c0104e2d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104e2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e32:	8b 15 f8 40 12 c0    	mov    0xc01240f8,%edx
c0104e38:	29 d0                	sub    %edx,%eax
c0104e3a:	c1 f8 05             	sar    $0x5,%eax
}
c0104e3d:	5d                   	pop    %ebp
c0104e3e:	c3                   	ret    

c0104e3f <page2pa>:
page2pa(struct Page *page) {
c0104e3f:	55                   	push   %ebp
c0104e40:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0104e42:	ff 75 08             	pushl  0x8(%ebp)
c0104e45:	e8 e2 ff ff ff       	call   c0104e2c <page2ppn>
c0104e4a:	83 c4 04             	add    $0x4,%esp
c0104e4d:	c1 e0 0c             	shl    $0xc,%eax
}
c0104e50:	c9                   	leave  
c0104e51:	c3                   	ret    

c0104e52 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104e52:	55                   	push   %ebp
c0104e53:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e58:	8b 00                	mov    (%eax),%eax
}
c0104e5a:	5d                   	pop    %ebp
c0104e5b:	c3                   	ret    

c0104e5c <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104e5c:	55                   	push   %ebp
c0104e5d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e62:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e65:	89 10                	mov    %edx,(%eax)
}
c0104e67:	90                   	nop
c0104e68:	5d                   	pop    %ebp
c0104e69:	c3                   	ret    

c0104e6a <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104e6a:	55                   	push   %ebp
c0104e6b:	89 e5                	mov    %esp,%ebp
c0104e6d:	83 ec 10             	sub    $0x10,%esp
c0104e70:	c7 45 fc e4 40 12 c0 	movl   $0xc01240e4,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0104e77:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e7a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104e7d:	89 50 04             	mov    %edx,0x4(%eax)
c0104e80:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e83:	8b 50 04             	mov    0x4(%eax),%edx
c0104e86:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e89:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104e8b:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c0104e92:	00 00 00 
}
c0104e95:	90                   	nop
c0104e96:	c9                   	leave  
c0104e97:	c3                   	ret    

c0104e98 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104e98:	55                   	push   %ebp
c0104e99:	89 e5                	mov    %esp,%ebp
c0104e9b:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c0104e9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104ea2:	75 16                	jne    c0104eba <default_init_memmap+0x22>
c0104ea4:	68 d0 97 10 c0       	push   $0xc01097d0
c0104ea9:	68 d6 97 10 c0       	push   $0xc01097d6
c0104eae:	6a 6d                	push   $0x6d
c0104eb0:	68 eb 97 10 c0       	push   $0xc01097eb
c0104eb5:	e8 2e b5 ff ff       	call   c01003e8 <__panic>
    struct Page *p = base;
c0104eba:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104ec0:	eb 6c                	jmp    c0104f2e <default_init_memmap+0x96>
        assert(PageReserved(p));
c0104ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ec5:	83 c0 04             	add    $0x4,%eax
c0104ec8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104ecf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ed2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ed5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ed8:	0f a3 10             	bt     %edx,(%eax)
c0104edb:	19 c0                	sbb    %eax,%eax
c0104edd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104ee0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104ee4:	0f 95 c0             	setne  %al
c0104ee7:	0f b6 c0             	movzbl %al,%eax
c0104eea:	85 c0                	test   %eax,%eax
c0104eec:	75 16                	jne    c0104f04 <default_init_memmap+0x6c>
c0104eee:	68 01 98 10 c0       	push   $0xc0109801
c0104ef3:	68 d6 97 10 c0       	push   $0xc01097d6
c0104ef8:	6a 70                	push   $0x70
c0104efa:	68 eb 97 10 c0       	push   $0xc01097eb
c0104eff:	e8 e4 b4 ff ff       	call   c01003e8 <__panic>
        p->flags = p->property = 0;
c0104f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f11:	8b 50 08             	mov    0x8(%eax),%edx
c0104f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f17:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0104f1a:	83 ec 08             	sub    $0x8,%esp
c0104f1d:	6a 00                	push   $0x0
c0104f1f:	ff 75 f4             	pushl  -0xc(%ebp)
c0104f22:	e8 35 ff ff ff       	call   c0104e5c <set_page_ref>
c0104f27:	83 c4 10             	add    $0x10,%esp
    for (; p != base + n; p ++) {
c0104f2a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0104f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f31:	c1 e0 05             	shl    $0x5,%eax
c0104f34:	89 c2                	mov    %eax,%edx
c0104f36:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f39:	01 d0                	add    %edx,%eax
c0104f3b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104f3e:	75 82                	jne    c0104ec2 <default_init_memmap+0x2a>
    }
    base->property = n;
c0104f40:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f43:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104f46:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104f49:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f4c:	83 c0 04             	add    $0x4,%eax
c0104f4f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104f59:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104f5c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104f5f:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104f62:	8b 15 ec 40 12 c0    	mov    0xc01240ec,%edx
c0104f68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f6b:	01 d0                	add    %edx,%eax
c0104f6d:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
    list_add_before(&free_list, &(base->page_link));
c0104f72:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f75:	83 c0 0c             	add    $0xc,%eax
c0104f78:	c7 45 e4 e4 40 12 c0 	movl   $0xc01240e4,-0x1c(%ebp)
c0104f7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f85:	8b 00                	mov    (%eax),%eax
c0104f87:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f8a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104f8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104f90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0104f96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104f99:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f9c:	89 10                	mov    %edx,(%eax)
c0104f9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104fa1:	8b 10                	mov    (%eax),%edx
c0104fa3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104fa6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104fa9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104fac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104faf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104fb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104fb5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104fb8:	89 10                	mov    %edx,(%eax)
}
c0104fba:	90                   	nop
c0104fbb:	c9                   	leave  
c0104fbc:	c3                   	ret    

c0104fbd <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104fbd:	55                   	push   %ebp
c0104fbe:	89 e5                	mov    %esp,%ebp
c0104fc0:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0104fc3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104fc7:	75 16                	jne    c0104fdf <default_alloc_pages+0x22>
c0104fc9:	68 d0 97 10 c0       	push   $0xc01097d0
c0104fce:	68 d6 97 10 c0       	push   $0xc01097d6
c0104fd3:	6a 7c                	push   $0x7c
c0104fd5:	68 eb 97 10 c0       	push   $0xc01097eb
c0104fda:	e8 09 b4 ff ff       	call   c01003e8 <__panic>
    if (n > nr_free) {
c0104fdf:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104fe4:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104fe7:	76 0a                	jbe    c0104ff3 <default_alloc_pages+0x36>
        return NULL;
c0104fe9:	b8 00 00 00 00       	mov    $0x0,%eax
c0104fee:	e9 36 01 00 00       	jmp    c0105129 <default_alloc_pages+0x16c>
    }
    struct Page *page = NULL;
c0104ff3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104ffa:	c7 45 f0 e4 40 12 c0 	movl   $0xc01240e4,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0105001:	eb 1c                	jmp    c010501f <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
c0105003:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105006:	83 e8 0c             	sub    $0xc,%eax
c0105009:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010500c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010500f:	8b 40 08             	mov    0x8(%eax),%eax
c0105012:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105015:	77 08                	ja     c010501f <default_alloc_pages+0x62>
            page = p;
c0105017:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010501a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010501d:	eb 18                	jmp    c0105037 <default_alloc_pages+0x7a>
c010501f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105022:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0105025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105028:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010502b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010502e:	81 7d f0 e4 40 12 c0 	cmpl   $0xc01240e4,-0x10(%ebp)
c0105035:	75 cc                	jne    c0105003 <default_alloc_pages+0x46>
        }
    }
    if (page != NULL) {
c0105037:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010503b:	0f 84 e5 00 00 00    	je     c0105126 <default_alloc_pages+0x169>
        if (page->property > n) {
c0105041:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105044:	8b 40 08             	mov    0x8(%eax),%eax
c0105047:	39 45 08             	cmp    %eax,0x8(%ebp)
c010504a:	0f 83 85 00 00 00    	jae    c01050d5 <default_alloc_pages+0x118>
            struct Page *p = page + n;
c0105050:	8b 45 08             	mov    0x8(%ebp),%eax
c0105053:	c1 e0 05             	shl    $0x5,%eax
c0105056:	89 c2                	mov    %eax,%edx
c0105058:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010505b:	01 d0                	add    %edx,%eax
c010505d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0105060:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105063:	8b 40 08             	mov    0x8(%eax),%eax
c0105066:	2b 45 08             	sub    0x8(%ebp),%eax
c0105069:	89 c2                	mov    %eax,%edx
c010506b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010506e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0105071:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105074:	83 c0 04             	add    $0x4,%eax
c0105077:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c010507e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105081:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105084:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105087:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c010508a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010508d:	83 c0 0c             	add    $0xc,%eax
c0105090:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105093:	83 c2 0c             	add    $0xc,%edx
c0105096:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0105099:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c010509c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010509f:	8b 40 04             	mov    0x4(%eax),%eax
c01050a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050a5:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01050a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01050ab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01050ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c01050b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01050b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01050b7:	89 10                	mov    %edx,(%eax)
c01050b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01050bc:	8b 10                	mov    (%eax),%edx
c01050be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01050c1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01050c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01050c7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01050ca:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01050cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01050d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01050d3:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01050d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050d8:	83 c0 0c             	add    $0xc,%eax
c01050db:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01050de:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01050e1:	8b 40 04             	mov    0x4(%eax),%eax
c01050e4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01050e7:	8b 12                	mov    (%edx),%edx
c01050e9:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01050ec:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next;
c01050ef:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01050f2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01050f5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01050f8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01050fb:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01050fe:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0105100:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105105:	2b 45 08             	sub    0x8(%ebp),%eax
c0105108:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
        ClearPageProperty(page);
c010510d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105110:	83 c0 04             	add    $0x4,%eax
c0105113:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010511a:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010511d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105120:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105123:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0105126:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105129:	c9                   	leave  
c010512a:	c3                   	ret    

c010512b <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010512b:	55                   	push   %ebp
c010512c:	89 e5                	mov    %esp,%ebp
c010512e:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c0105134:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105138:	75 19                	jne    c0105153 <default_free_pages+0x28>
c010513a:	68 d0 97 10 c0       	push   $0xc01097d0
c010513f:	68 d6 97 10 c0       	push   $0xc01097d6
c0105144:	68 9a 00 00 00       	push   $0x9a
c0105149:	68 eb 97 10 c0       	push   $0xc01097eb
c010514e:	e8 95 b2 ff ff       	call   c01003e8 <__panic>
    struct Page *p = base;
c0105153:	8b 45 08             	mov    0x8(%ebp),%eax
c0105156:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0105159:	e9 8f 00 00 00       	jmp    c01051ed <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c010515e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105161:	83 c0 04             	add    $0x4,%eax
c0105164:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010516b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010516e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105171:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105174:	0f a3 10             	bt     %edx,(%eax)
c0105177:	19 c0                	sbb    %eax,%eax
c0105179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010517c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105180:	0f 95 c0             	setne  %al
c0105183:	0f b6 c0             	movzbl %al,%eax
c0105186:	85 c0                	test   %eax,%eax
c0105188:	75 2c                	jne    c01051b6 <default_free_pages+0x8b>
c010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010518d:	83 c0 04             	add    $0x4,%eax
c0105190:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0105197:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010519a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010519d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01051a0:	0f a3 10             	bt     %edx,(%eax)
c01051a3:	19 c0                	sbb    %eax,%eax
c01051a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01051a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01051ac:	0f 95 c0             	setne  %al
c01051af:	0f b6 c0             	movzbl %al,%eax
c01051b2:	85 c0                	test   %eax,%eax
c01051b4:	74 19                	je     c01051cf <default_free_pages+0xa4>
c01051b6:	68 14 98 10 c0       	push   $0xc0109814
c01051bb:	68 d6 97 10 c0       	push   $0xc01097d6
c01051c0:	68 9d 00 00 00       	push   $0x9d
c01051c5:	68 eb 97 10 c0       	push   $0xc01097eb
c01051ca:	e8 19 b2 ff ff       	call   c01003e8 <__panic>
        p->flags = 0;
c01051cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051d2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01051d9:	83 ec 08             	sub    $0x8,%esp
c01051dc:	6a 00                	push   $0x0
c01051de:	ff 75 f4             	pushl  -0xc(%ebp)
c01051e1:	e8 76 fc ff ff       	call   c0104e5c <set_page_ref>
c01051e6:	83 c4 10             	add    $0x10,%esp
    for (; p != base + n; p ++) {
c01051e9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01051ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051f0:	c1 e0 05             	shl    $0x5,%eax
c01051f3:	89 c2                	mov    %eax,%edx
c01051f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01051f8:	01 d0                	add    %edx,%eax
c01051fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01051fd:	0f 85 5b ff ff ff    	jne    c010515e <default_free_pages+0x33>
    }
    base->property = n;
c0105203:	8b 45 08             	mov    0x8(%ebp),%eax
c0105206:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105209:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010520c:	8b 45 08             	mov    0x8(%ebp),%eax
c010520f:	83 c0 04             	add    $0x4,%eax
c0105212:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105219:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010521c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010521f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105222:	0f ab 10             	bts    %edx,(%eax)
c0105225:	c7 45 d4 e4 40 12 c0 	movl   $0xc01240e4,-0x2c(%ebp)
    return listelm->next;
c010522c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010522f:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0105232:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0105235:	e9 fa 00 00 00       	jmp    c0105334 <default_free_pages+0x209>
        p = le2page(le, page_link);
c010523a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010523d:	83 e8 0c             	sub    $0xc,%eax
c0105240:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105243:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105246:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105249:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010524c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010524f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0105252:	8b 45 08             	mov    0x8(%ebp),%eax
c0105255:	8b 40 08             	mov    0x8(%eax),%eax
c0105258:	c1 e0 05             	shl    $0x5,%eax
c010525b:	89 c2                	mov    %eax,%edx
c010525d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105260:	01 d0                	add    %edx,%eax
c0105262:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105265:	75 5a                	jne    c01052c1 <default_free_pages+0x196>
            base->property += p->property;
c0105267:	8b 45 08             	mov    0x8(%ebp),%eax
c010526a:	8b 50 08             	mov    0x8(%eax),%edx
c010526d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105270:	8b 40 08             	mov    0x8(%eax),%eax
c0105273:	01 c2                	add    %eax,%edx
c0105275:	8b 45 08             	mov    0x8(%ebp),%eax
c0105278:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010527b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010527e:	83 c0 04             	add    $0x4,%eax
c0105281:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0105288:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010528b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010528e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105291:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0105294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105297:	83 c0 0c             	add    $0xc,%eax
c010529a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010529d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052a0:	8b 40 04             	mov    0x4(%eax),%eax
c01052a3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01052a6:	8b 12                	mov    (%edx),%edx
c01052a8:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01052ab:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01052ae:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01052b1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01052b4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01052b7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01052ba:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01052bd:	89 10                	mov    %edx,(%eax)
c01052bf:	eb 73                	jmp    c0105334 <default_free_pages+0x209>
        }
        else if (p + p->property == base) {
c01052c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c4:	8b 40 08             	mov    0x8(%eax),%eax
c01052c7:	c1 e0 05             	shl    $0x5,%eax
c01052ca:	89 c2                	mov    %eax,%edx
c01052cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052cf:	01 d0                	add    %edx,%eax
c01052d1:	39 45 08             	cmp    %eax,0x8(%ebp)
c01052d4:	75 5e                	jne    c0105334 <default_free_pages+0x209>
            p->property += base->property;
c01052d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052d9:	8b 50 08             	mov    0x8(%eax),%edx
c01052dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01052df:	8b 40 08             	mov    0x8(%eax),%eax
c01052e2:	01 c2                	add    %eax,%edx
c01052e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052e7:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01052ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01052ed:	83 c0 04             	add    $0x4,%eax
c01052f0:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c01052f7:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01052fa:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01052fd:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0105300:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0105303:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105306:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0105309:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010530c:	83 c0 0c             	add    $0xc,%eax
c010530f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105312:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105315:	8b 40 04             	mov    0x4(%eax),%eax
c0105318:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010531b:	8b 12                	mov    (%edx),%edx
c010531d:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0105320:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0105323:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105326:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105329:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010532c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010532f:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105332:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c0105334:	81 7d f0 e4 40 12 c0 	cmpl   $0xc01240e4,-0x10(%ebp)
c010533b:	0f 85 f9 fe ff ff    	jne    c010523a <default_free_pages+0x10f>
        }
    }
    nr_free += n;
c0105341:	8b 15 ec 40 12 c0    	mov    0xc01240ec,%edx
c0105347:	8b 45 0c             	mov    0xc(%ebp),%eax
c010534a:	01 d0                	add    %edx,%eax
c010534c:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
c0105351:	c7 45 9c e4 40 12 c0 	movl   $0xc01240e4,-0x64(%ebp)
    return listelm->next;
c0105358:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010535b:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c010535e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0105361:	eb 5b                	jmp    c01053be <default_free_pages+0x293>
        p = le2page(le, page_link);
c0105363:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105366:	83 e8 0c             	sub    $0xc,%eax
c0105369:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c010536c:	8b 45 08             	mov    0x8(%ebp),%eax
c010536f:	8b 40 08             	mov    0x8(%eax),%eax
c0105372:	c1 e0 05             	shl    $0x5,%eax
c0105375:	89 c2                	mov    %eax,%edx
c0105377:	8b 45 08             	mov    0x8(%ebp),%eax
c010537a:	01 d0                	add    %edx,%eax
c010537c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010537f:	72 2e                	jb     c01053af <default_free_pages+0x284>
            assert(base + base->property != p);
c0105381:	8b 45 08             	mov    0x8(%ebp),%eax
c0105384:	8b 40 08             	mov    0x8(%eax),%eax
c0105387:	c1 e0 05             	shl    $0x5,%eax
c010538a:	89 c2                	mov    %eax,%edx
c010538c:	8b 45 08             	mov    0x8(%ebp),%eax
c010538f:	01 d0                	add    %edx,%eax
c0105391:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105394:	75 33                	jne    c01053c9 <default_free_pages+0x29e>
c0105396:	68 39 98 10 c0       	push   $0xc0109839
c010539b:	68 d6 97 10 c0       	push   $0xc01097d6
c01053a0:	68 b9 00 00 00       	push   $0xb9
c01053a5:	68 eb 97 10 c0       	push   $0xc01097eb
c01053aa:	e8 39 b0 ff ff       	call   c01003e8 <__panic>
c01053af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053b2:	89 45 98             	mov    %eax,-0x68(%ebp)
c01053b5:	8b 45 98             	mov    -0x68(%ebp),%eax
c01053b8:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01053bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01053be:	81 7d f0 e4 40 12 c0 	cmpl   $0xc01240e4,-0x10(%ebp)
c01053c5:	75 9c                	jne    c0105363 <default_free_pages+0x238>
c01053c7:	eb 01                	jmp    c01053ca <default_free_pages+0x29f>
            break;
c01053c9:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c01053ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01053cd:	8d 50 0c             	lea    0xc(%eax),%edx
c01053d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053d3:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01053d6:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01053d9:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01053dc:	8b 00                	mov    (%eax),%eax
c01053de:	8b 55 90             	mov    -0x70(%ebp),%edx
c01053e1:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01053e4:	89 45 88             	mov    %eax,-0x78(%ebp)
c01053e7:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01053ea:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c01053ed:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01053f0:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01053f3:	89 10                	mov    %edx,(%eax)
c01053f5:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01053f8:	8b 10                	mov    (%eax),%edx
c01053fa:	8b 45 88             	mov    -0x78(%ebp),%eax
c01053fd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105400:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105403:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105406:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105409:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010540c:	8b 55 88             	mov    -0x78(%ebp),%edx
c010540f:	89 10                	mov    %edx,(%eax)
}
c0105411:	90                   	nop
c0105412:	c9                   	leave  
c0105413:	c3                   	ret    

c0105414 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105414:	55                   	push   %ebp
c0105415:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105417:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
}
c010541c:	5d                   	pop    %ebp
c010541d:	c3                   	ret    

c010541e <basic_check>:

static void
basic_check(void) {
c010541e:	55                   	push   %ebp
c010541f:	89 e5                	mov    %esp,%ebp
c0105421:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010542b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010542e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105431:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105434:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105437:	83 ec 0c             	sub    $0xc,%esp
c010543a:	6a 01                	push   $0x1
c010543c:	e8 06 0d 00 00       	call   c0106147 <alloc_pages>
c0105441:	83 c4 10             	add    $0x10,%esp
c0105444:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105447:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010544b:	75 19                	jne    c0105466 <basic_check+0x48>
c010544d:	68 54 98 10 c0       	push   $0xc0109854
c0105452:	68 d6 97 10 c0       	push   $0xc01097d6
c0105457:	68 ca 00 00 00       	push   $0xca
c010545c:	68 eb 97 10 c0       	push   $0xc01097eb
c0105461:	e8 82 af ff ff       	call   c01003e8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105466:	83 ec 0c             	sub    $0xc,%esp
c0105469:	6a 01                	push   $0x1
c010546b:	e8 d7 0c 00 00       	call   c0106147 <alloc_pages>
c0105470:	83 c4 10             	add    $0x10,%esp
c0105473:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010547a:	75 19                	jne    c0105495 <basic_check+0x77>
c010547c:	68 70 98 10 c0       	push   $0xc0109870
c0105481:	68 d6 97 10 c0       	push   $0xc01097d6
c0105486:	68 cb 00 00 00       	push   $0xcb
c010548b:	68 eb 97 10 c0       	push   $0xc01097eb
c0105490:	e8 53 af ff ff       	call   c01003e8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105495:	83 ec 0c             	sub    $0xc,%esp
c0105498:	6a 01                	push   $0x1
c010549a:	e8 a8 0c 00 00       	call   c0106147 <alloc_pages>
c010549f:	83 c4 10             	add    $0x10,%esp
c01054a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01054a9:	75 19                	jne    c01054c4 <basic_check+0xa6>
c01054ab:	68 8c 98 10 c0       	push   $0xc010988c
c01054b0:	68 d6 97 10 c0       	push   $0xc01097d6
c01054b5:	68 cc 00 00 00       	push   $0xcc
c01054ba:	68 eb 97 10 c0       	push   $0xc01097eb
c01054bf:	e8 24 af ff ff       	call   c01003e8 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01054c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054c7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01054ca:	74 10                	je     c01054dc <basic_check+0xbe>
c01054cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01054d2:	74 08                	je     c01054dc <basic_check+0xbe>
c01054d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054d7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01054da:	75 19                	jne    c01054f5 <basic_check+0xd7>
c01054dc:	68 a8 98 10 c0       	push   $0xc01098a8
c01054e1:	68 d6 97 10 c0       	push   $0xc01097d6
c01054e6:	68 ce 00 00 00       	push   $0xce
c01054eb:	68 eb 97 10 c0       	push   $0xc01097eb
c01054f0:	e8 f3 ae ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01054f5:	83 ec 0c             	sub    $0xc,%esp
c01054f8:	ff 75 ec             	pushl  -0x14(%ebp)
c01054fb:	e8 52 f9 ff ff       	call   c0104e52 <page_ref>
c0105500:	83 c4 10             	add    $0x10,%esp
c0105503:	85 c0                	test   %eax,%eax
c0105505:	75 24                	jne    c010552b <basic_check+0x10d>
c0105507:	83 ec 0c             	sub    $0xc,%esp
c010550a:	ff 75 f0             	pushl  -0x10(%ebp)
c010550d:	e8 40 f9 ff ff       	call   c0104e52 <page_ref>
c0105512:	83 c4 10             	add    $0x10,%esp
c0105515:	85 c0                	test   %eax,%eax
c0105517:	75 12                	jne    c010552b <basic_check+0x10d>
c0105519:	83 ec 0c             	sub    $0xc,%esp
c010551c:	ff 75 f4             	pushl  -0xc(%ebp)
c010551f:	e8 2e f9 ff ff       	call   c0104e52 <page_ref>
c0105524:	83 c4 10             	add    $0x10,%esp
c0105527:	85 c0                	test   %eax,%eax
c0105529:	74 19                	je     c0105544 <basic_check+0x126>
c010552b:	68 cc 98 10 c0       	push   $0xc01098cc
c0105530:	68 d6 97 10 c0       	push   $0xc01097d6
c0105535:	68 cf 00 00 00       	push   $0xcf
c010553a:	68 eb 97 10 c0       	push   $0xc01097eb
c010553f:	e8 a4 ae ff ff       	call   c01003e8 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105544:	83 ec 0c             	sub    $0xc,%esp
c0105547:	ff 75 ec             	pushl  -0x14(%ebp)
c010554a:	e8 f0 f8 ff ff       	call   c0104e3f <page2pa>
c010554f:	83 c4 10             	add    $0x10,%esp
c0105552:	89 c2                	mov    %eax,%edx
c0105554:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0105559:	c1 e0 0c             	shl    $0xc,%eax
c010555c:	39 c2                	cmp    %eax,%edx
c010555e:	72 19                	jb     c0105579 <basic_check+0x15b>
c0105560:	68 08 99 10 c0       	push   $0xc0109908
c0105565:	68 d6 97 10 c0       	push   $0xc01097d6
c010556a:	68 d1 00 00 00       	push   $0xd1
c010556f:	68 eb 97 10 c0       	push   $0xc01097eb
c0105574:	e8 6f ae ff ff       	call   c01003e8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105579:	83 ec 0c             	sub    $0xc,%esp
c010557c:	ff 75 f0             	pushl  -0x10(%ebp)
c010557f:	e8 bb f8 ff ff       	call   c0104e3f <page2pa>
c0105584:	83 c4 10             	add    $0x10,%esp
c0105587:	89 c2                	mov    %eax,%edx
c0105589:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010558e:	c1 e0 0c             	shl    $0xc,%eax
c0105591:	39 c2                	cmp    %eax,%edx
c0105593:	72 19                	jb     c01055ae <basic_check+0x190>
c0105595:	68 25 99 10 c0       	push   $0xc0109925
c010559a:	68 d6 97 10 c0       	push   $0xc01097d6
c010559f:	68 d2 00 00 00       	push   $0xd2
c01055a4:	68 eb 97 10 c0       	push   $0xc01097eb
c01055a9:	e8 3a ae ff ff       	call   c01003e8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01055ae:	83 ec 0c             	sub    $0xc,%esp
c01055b1:	ff 75 f4             	pushl  -0xc(%ebp)
c01055b4:	e8 86 f8 ff ff       	call   c0104e3f <page2pa>
c01055b9:	83 c4 10             	add    $0x10,%esp
c01055bc:	89 c2                	mov    %eax,%edx
c01055be:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01055c3:	c1 e0 0c             	shl    $0xc,%eax
c01055c6:	39 c2                	cmp    %eax,%edx
c01055c8:	72 19                	jb     c01055e3 <basic_check+0x1c5>
c01055ca:	68 42 99 10 c0       	push   $0xc0109942
c01055cf:	68 d6 97 10 c0       	push   $0xc01097d6
c01055d4:	68 d3 00 00 00       	push   $0xd3
c01055d9:	68 eb 97 10 c0       	push   $0xc01097eb
c01055de:	e8 05 ae ff ff       	call   c01003e8 <__panic>

    list_entry_t free_list_store = free_list;
c01055e3:	a1 e4 40 12 c0       	mov    0xc01240e4,%eax
c01055e8:	8b 15 e8 40 12 c0    	mov    0xc01240e8,%edx
c01055ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01055f1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01055f4:	c7 45 dc e4 40 12 c0 	movl   $0xc01240e4,-0x24(%ebp)
    elm->prev = elm->next = elm;
c01055fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105601:	89 50 04             	mov    %edx,0x4(%eax)
c0105604:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105607:	8b 50 04             	mov    0x4(%eax),%edx
c010560a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010560d:	89 10                	mov    %edx,(%eax)
c010560f:	c7 45 e0 e4 40 12 c0 	movl   $0xc01240e4,-0x20(%ebp)
    return list->next == list;
c0105616:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105619:	8b 40 04             	mov    0x4(%eax),%eax
c010561c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010561f:	0f 94 c0             	sete   %al
c0105622:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105625:	85 c0                	test   %eax,%eax
c0105627:	75 19                	jne    c0105642 <basic_check+0x224>
c0105629:	68 5f 99 10 c0       	push   $0xc010995f
c010562e:	68 d6 97 10 c0       	push   $0xc01097d6
c0105633:	68 d7 00 00 00       	push   $0xd7
c0105638:	68 eb 97 10 c0       	push   $0xc01097eb
c010563d:	e8 a6 ad ff ff       	call   c01003e8 <__panic>

    unsigned int nr_free_store = nr_free;
c0105642:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105647:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010564a:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c0105651:	00 00 00 

    assert(alloc_page() == NULL);
c0105654:	83 ec 0c             	sub    $0xc,%esp
c0105657:	6a 01                	push   $0x1
c0105659:	e8 e9 0a 00 00       	call   c0106147 <alloc_pages>
c010565e:	83 c4 10             	add    $0x10,%esp
c0105661:	85 c0                	test   %eax,%eax
c0105663:	74 19                	je     c010567e <basic_check+0x260>
c0105665:	68 76 99 10 c0       	push   $0xc0109976
c010566a:	68 d6 97 10 c0       	push   $0xc01097d6
c010566f:	68 dc 00 00 00       	push   $0xdc
c0105674:	68 eb 97 10 c0       	push   $0xc01097eb
c0105679:	e8 6a ad ff ff       	call   c01003e8 <__panic>

    free_page(p0);
c010567e:	83 ec 08             	sub    $0x8,%esp
c0105681:	6a 01                	push   $0x1
c0105683:	ff 75 ec             	pushl  -0x14(%ebp)
c0105686:	e8 28 0b 00 00       	call   c01061b3 <free_pages>
c010568b:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c010568e:	83 ec 08             	sub    $0x8,%esp
c0105691:	6a 01                	push   $0x1
c0105693:	ff 75 f0             	pushl  -0x10(%ebp)
c0105696:	e8 18 0b 00 00       	call   c01061b3 <free_pages>
c010569b:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010569e:	83 ec 08             	sub    $0x8,%esp
c01056a1:	6a 01                	push   $0x1
c01056a3:	ff 75 f4             	pushl  -0xc(%ebp)
c01056a6:	e8 08 0b 00 00       	call   c01061b3 <free_pages>
c01056ab:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c01056ae:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c01056b3:	83 f8 03             	cmp    $0x3,%eax
c01056b6:	74 19                	je     c01056d1 <basic_check+0x2b3>
c01056b8:	68 8b 99 10 c0       	push   $0xc010998b
c01056bd:	68 d6 97 10 c0       	push   $0xc01097d6
c01056c2:	68 e1 00 00 00       	push   $0xe1
c01056c7:	68 eb 97 10 c0       	push   $0xc01097eb
c01056cc:	e8 17 ad ff ff       	call   c01003e8 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01056d1:	83 ec 0c             	sub    $0xc,%esp
c01056d4:	6a 01                	push   $0x1
c01056d6:	e8 6c 0a 00 00       	call   c0106147 <alloc_pages>
c01056db:	83 c4 10             	add    $0x10,%esp
c01056de:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01056e5:	75 19                	jne    c0105700 <basic_check+0x2e2>
c01056e7:	68 54 98 10 c0       	push   $0xc0109854
c01056ec:	68 d6 97 10 c0       	push   $0xc01097d6
c01056f1:	68 e3 00 00 00       	push   $0xe3
c01056f6:	68 eb 97 10 c0       	push   $0xc01097eb
c01056fb:	e8 e8 ac ff ff       	call   c01003e8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105700:	83 ec 0c             	sub    $0xc,%esp
c0105703:	6a 01                	push   $0x1
c0105705:	e8 3d 0a 00 00       	call   c0106147 <alloc_pages>
c010570a:	83 c4 10             	add    $0x10,%esp
c010570d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105714:	75 19                	jne    c010572f <basic_check+0x311>
c0105716:	68 70 98 10 c0       	push   $0xc0109870
c010571b:	68 d6 97 10 c0       	push   $0xc01097d6
c0105720:	68 e4 00 00 00       	push   $0xe4
c0105725:	68 eb 97 10 c0       	push   $0xc01097eb
c010572a:	e8 b9 ac ff ff       	call   c01003e8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010572f:	83 ec 0c             	sub    $0xc,%esp
c0105732:	6a 01                	push   $0x1
c0105734:	e8 0e 0a 00 00       	call   c0106147 <alloc_pages>
c0105739:	83 c4 10             	add    $0x10,%esp
c010573c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010573f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105743:	75 19                	jne    c010575e <basic_check+0x340>
c0105745:	68 8c 98 10 c0       	push   $0xc010988c
c010574a:	68 d6 97 10 c0       	push   $0xc01097d6
c010574f:	68 e5 00 00 00       	push   $0xe5
c0105754:	68 eb 97 10 c0       	push   $0xc01097eb
c0105759:	e8 8a ac ff ff       	call   c01003e8 <__panic>

    assert(alloc_page() == NULL);
c010575e:	83 ec 0c             	sub    $0xc,%esp
c0105761:	6a 01                	push   $0x1
c0105763:	e8 df 09 00 00       	call   c0106147 <alloc_pages>
c0105768:	83 c4 10             	add    $0x10,%esp
c010576b:	85 c0                	test   %eax,%eax
c010576d:	74 19                	je     c0105788 <basic_check+0x36a>
c010576f:	68 76 99 10 c0       	push   $0xc0109976
c0105774:	68 d6 97 10 c0       	push   $0xc01097d6
c0105779:	68 e7 00 00 00       	push   $0xe7
c010577e:	68 eb 97 10 c0       	push   $0xc01097eb
c0105783:	e8 60 ac ff ff       	call   c01003e8 <__panic>

    free_page(p0);
c0105788:	83 ec 08             	sub    $0x8,%esp
c010578b:	6a 01                	push   $0x1
c010578d:	ff 75 ec             	pushl  -0x14(%ebp)
c0105790:	e8 1e 0a 00 00       	call   c01061b3 <free_pages>
c0105795:	83 c4 10             	add    $0x10,%esp
c0105798:	c7 45 d8 e4 40 12 c0 	movl   $0xc01240e4,-0x28(%ebp)
c010579f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01057a2:	8b 40 04             	mov    0x4(%eax),%eax
c01057a5:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01057a8:	0f 94 c0             	sete   %al
c01057ab:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01057ae:	85 c0                	test   %eax,%eax
c01057b0:	74 19                	je     c01057cb <basic_check+0x3ad>
c01057b2:	68 98 99 10 c0       	push   $0xc0109998
c01057b7:	68 d6 97 10 c0       	push   $0xc01097d6
c01057bc:	68 ea 00 00 00       	push   $0xea
c01057c1:	68 eb 97 10 c0       	push   $0xc01097eb
c01057c6:	e8 1d ac ff ff       	call   c01003e8 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01057cb:	83 ec 0c             	sub    $0xc,%esp
c01057ce:	6a 01                	push   $0x1
c01057d0:	e8 72 09 00 00       	call   c0106147 <alloc_pages>
c01057d5:	83 c4 10             	add    $0x10,%esp
c01057d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01057db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057de:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01057e1:	74 19                	je     c01057fc <basic_check+0x3de>
c01057e3:	68 b0 99 10 c0       	push   $0xc01099b0
c01057e8:	68 d6 97 10 c0       	push   $0xc01097d6
c01057ed:	68 ed 00 00 00       	push   $0xed
c01057f2:	68 eb 97 10 c0       	push   $0xc01097eb
c01057f7:	e8 ec ab ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c01057fc:	83 ec 0c             	sub    $0xc,%esp
c01057ff:	6a 01                	push   $0x1
c0105801:	e8 41 09 00 00       	call   c0106147 <alloc_pages>
c0105806:	83 c4 10             	add    $0x10,%esp
c0105809:	85 c0                	test   %eax,%eax
c010580b:	74 19                	je     c0105826 <basic_check+0x408>
c010580d:	68 76 99 10 c0       	push   $0xc0109976
c0105812:	68 d6 97 10 c0       	push   $0xc01097d6
c0105817:	68 ee 00 00 00       	push   $0xee
c010581c:	68 eb 97 10 c0       	push   $0xc01097eb
c0105821:	e8 c2 ab ff ff       	call   c01003e8 <__panic>

    assert(nr_free == 0);
c0105826:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c010582b:	85 c0                	test   %eax,%eax
c010582d:	74 19                	je     c0105848 <basic_check+0x42a>
c010582f:	68 c9 99 10 c0       	push   $0xc01099c9
c0105834:	68 d6 97 10 c0       	push   $0xc01097d6
c0105839:	68 f0 00 00 00       	push   $0xf0
c010583e:	68 eb 97 10 c0       	push   $0xc01097eb
c0105843:	e8 a0 ab ff ff       	call   c01003e8 <__panic>
    free_list = free_list_store;
c0105848:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010584b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010584e:	a3 e4 40 12 c0       	mov    %eax,0xc01240e4
c0105853:	89 15 e8 40 12 c0    	mov    %edx,0xc01240e8
    nr_free = nr_free_store;
c0105859:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010585c:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec

    free_page(p);
c0105861:	83 ec 08             	sub    $0x8,%esp
c0105864:	6a 01                	push   $0x1
c0105866:	ff 75 e4             	pushl  -0x1c(%ebp)
c0105869:	e8 45 09 00 00       	call   c01061b3 <free_pages>
c010586e:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0105871:	83 ec 08             	sub    $0x8,%esp
c0105874:	6a 01                	push   $0x1
c0105876:	ff 75 f0             	pushl  -0x10(%ebp)
c0105879:	e8 35 09 00 00       	call   c01061b3 <free_pages>
c010587e:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105881:	83 ec 08             	sub    $0x8,%esp
c0105884:	6a 01                	push   $0x1
c0105886:	ff 75 f4             	pushl  -0xc(%ebp)
c0105889:	e8 25 09 00 00       	call   c01061b3 <free_pages>
c010588e:	83 c4 10             	add    $0x10,%esp
}
c0105891:	90                   	nop
c0105892:	c9                   	leave  
c0105893:	c3                   	ret    

c0105894 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105894:	55                   	push   %ebp
c0105895:	89 e5                	mov    %esp,%ebp
c0105897:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c010589d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01058a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01058ab:	c7 45 ec e4 40 12 c0 	movl   $0xc01240e4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01058b2:	eb 60                	jmp    c0105914 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c01058b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058b7:	83 e8 0c             	sub    $0xc,%eax
c01058ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01058bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01058c0:	83 c0 04             	add    $0x4,%eax
c01058c3:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01058ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01058cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01058d0:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01058d3:	0f a3 10             	bt     %edx,(%eax)
c01058d6:	19 c0                	sbb    %eax,%eax
c01058d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01058db:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01058df:	0f 95 c0             	setne  %al
c01058e2:	0f b6 c0             	movzbl %al,%eax
c01058e5:	85 c0                	test   %eax,%eax
c01058e7:	75 19                	jne    c0105902 <default_check+0x6e>
c01058e9:	68 d6 99 10 c0       	push   $0xc01099d6
c01058ee:	68 d6 97 10 c0       	push   $0xc01097d6
c01058f3:	68 01 01 00 00       	push   $0x101
c01058f8:	68 eb 97 10 c0       	push   $0xc01097eb
c01058fd:	e8 e6 aa ff ff       	call   c01003e8 <__panic>
        count ++, total += p->property;
c0105902:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105906:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105909:	8b 50 08             	mov    0x8(%eax),%edx
c010590c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010590f:	01 d0                	add    %edx,%eax
c0105911:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105914:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105917:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c010591a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010591d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105920:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105923:	81 7d ec e4 40 12 c0 	cmpl   $0xc01240e4,-0x14(%ebp)
c010592a:	75 88                	jne    c01058b4 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c010592c:	e8 b7 08 00 00       	call   c01061e8 <nr_free_pages>
c0105931:	89 c2                	mov    %eax,%edx
c0105933:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105936:	39 c2                	cmp    %eax,%edx
c0105938:	74 19                	je     c0105953 <default_check+0xbf>
c010593a:	68 e6 99 10 c0       	push   $0xc01099e6
c010593f:	68 d6 97 10 c0       	push   $0xc01097d6
c0105944:	68 04 01 00 00       	push   $0x104
c0105949:	68 eb 97 10 c0       	push   $0xc01097eb
c010594e:	e8 95 aa ff ff       	call   c01003e8 <__panic>

    basic_check();
c0105953:	e8 c6 fa ff ff       	call   c010541e <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105958:	83 ec 0c             	sub    $0xc,%esp
c010595b:	6a 05                	push   $0x5
c010595d:	e8 e5 07 00 00       	call   c0106147 <alloc_pages>
c0105962:	83 c4 10             	add    $0x10,%esp
c0105965:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0105968:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010596c:	75 19                	jne    c0105987 <default_check+0xf3>
c010596e:	68 ff 99 10 c0       	push   $0xc01099ff
c0105973:	68 d6 97 10 c0       	push   $0xc01097d6
c0105978:	68 09 01 00 00       	push   $0x109
c010597d:	68 eb 97 10 c0       	push   $0xc01097eb
c0105982:	e8 61 aa ff ff       	call   c01003e8 <__panic>
    assert(!PageProperty(p0));
c0105987:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010598a:	83 c0 04             	add    $0x4,%eax
c010598d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105994:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105997:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010599a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010599d:	0f a3 10             	bt     %edx,(%eax)
c01059a0:	19 c0                	sbb    %eax,%eax
c01059a2:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01059a5:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01059a9:	0f 95 c0             	setne  %al
c01059ac:	0f b6 c0             	movzbl %al,%eax
c01059af:	85 c0                	test   %eax,%eax
c01059b1:	74 19                	je     c01059cc <default_check+0x138>
c01059b3:	68 0a 9a 10 c0       	push   $0xc0109a0a
c01059b8:	68 d6 97 10 c0       	push   $0xc01097d6
c01059bd:	68 0a 01 00 00       	push   $0x10a
c01059c2:	68 eb 97 10 c0       	push   $0xc01097eb
c01059c7:	e8 1c aa ff ff       	call   c01003e8 <__panic>

    list_entry_t free_list_store = free_list;
c01059cc:	a1 e4 40 12 c0       	mov    0xc01240e4,%eax
c01059d1:	8b 15 e8 40 12 c0    	mov    0xc01240e8,%edx
c01059d7:	89 45 80             	mov    %eax,-0x80(%ebp)
c01059da:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01059dd:	c7 45 b0 e4 40 12 c0 	movl   $0xc01240e4,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01059e4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01059e7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01059ea:	89 50 04             	mov    %edx,0x4(%eax)
c01059ed:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01059f0:	8b 50 04             	mov    0x4(%eax),%edx
c01059f3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01059f6:	89 10                	mov    %edx,(%eax)
c01059f8:	c7 45 b4 e4 40 12 c0 	movl   $0xc01240e4,-0x4c(%ebp)
    return list->next == list;
c01059ff:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105a02:	8b 40 04             	mov    0x4(%eax),%eax
c0105a05:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0105a08:	0f 94 c0             	sete   %al
c0105a0b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105a0e:	85 c0                	test   %eax,%eax
c0105a10:	75 19                	jne    c0105a2b <default_check+0x197>
c0105a12:	68 5f 99 10 c0       	push   $0xc010995f
c0105a17:	68 d6 97 10 c0       	push   $0xc01097d6
c0105a1c:	68 0e 01 00 00       	push   $0x10e
c0105a21:	68 eb 97 10 c0       	push   $0xc01097eb
c0105a26:	e8 bd a9 ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c0105a2b:	83 ec 0c             	sub    $0xc,%esp
c0105a2e:	6a 01                	push   $0x1
c0105a30:	e8 12 07 00 00       	call   c0106147 <alloc_pages>
c0105a35:	83 c4 10             	add    $0x10,%esp
c0105a38:	85 c0                	test   %eax,%eax
c0105a3a:	74 19                	je     c0105a55 <default_check+0x1c1>
c0105a3c:	68 76 99 10 c0       	push   $0xc0109976
c0105a41:	68 d6 97 10 c0       	push   $0xc01097d6
c0105a46:	68 0f 01 00 00       	push   $0x10f
c0105a4b:	68 eb 97 10 c0       	push   $0xc01097eb
c0105a50:	e8 93 a9 ff ff       	call   c01003e8 <__panic>

    unsigned int nr_free_store = nr_free;
c0105a55:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105a5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0105a5d:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c0105a64:	00 00 00 

    free_pages(p0 + 2, 3);
c0105a67:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a6a:	83 c0 40             	add    $0x40,%eax
c0105a6d:	83 ec 08             	sub    $0x8,%esp
c0105a70:	6a 03                	push   $0x3
c0105a72:	50                   	push   %eax
c0105a73:	e8 3b 07 00 00       	call   c01061b3 <free_pages>
c0105a78:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0105a7b:	83 ec 0c             	sub    $0xc,%esp
c0105a7e:	6a 04                	push   $0x4
c0105a80:	e8 c2 06 00 00       	call   c0106147 <alloc_pages>
c0105a85:	83 c4 10             	add    $0x10,%esp
c0105a88:	85 c0                	test   %eax,%eax
c0105a8a:	74 19                	je     c0105aa5 <default_check+0x211>
c0105a8c:	68 1c 9a 10 c0       	push   $0xc0109a1c
c0105a91:	68 d6 97 10 c0       	push   $0xc01097d6
c0105a96:	68 15 01 00 00       	push   $0x115
c0105a9b:	68 eb 97 10 c0       	push   $0xc01097eb
c0105aa0:	e8 43 a9 ff ff       	call   c01003e8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105aa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105aa8:	83 c0 40             	add    $0x40,%eax
c0105aab:	83 c0 04             	add    $0x4,%eax
c0105aae:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105ab5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105ab8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105abb:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105abe:	0f a3 10             	bt     %edx,(%eax)
c0105ac1:	19 c0                	sbb    %eax,%eax
c0105ac3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105ac6:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0105aca:	0f 95 c0             	setne  %al
c0105acd:	0f b6 c0             	movzbl %al,%eax
c0105ad0:	85 c0                	test   %eax,%eax
c0105ad2:	74 0e                	je     c0105ae2 <default_check+0x24e>
c0105ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ad7:	83 c0 40             	add    $0x40,%eax
c0105ada:	8b 40 08             	mov    0x8(%eax),%eax
c0105add:	83 f8 03             	cmp    $0x3,%eax
c0105ae0:	74 19                	je     c0105afb <default_check+0x267>
c0105ae2:	68 34 9a 10 c0       	push   $0xc0109a34
c0105ae7:	68 d6 97 10 c0       	push   $0xc01097d6
c0105aec:	68 16 01 00 00       	push   $0x116
c0105af1:	68 eb 97 10 c0       	push   $0xc01097eb
c0105af6:	e8 ed a8 ff ff       	call   c01003e8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105afb:	83 ec 0c             	sub    $0xc,%esp
c0105afe:	6a 03                	push   $0x3
c0105b00:	e8 42 06 00 00       	call   c0106147 <alloc_pages>
c0105b05:	83 c4 10             	add    $0x10,%esp
c0105b08:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105b0b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105b0f:	75 19                	jne    c0105b2a <default_check+0x296>
c0105b11:	68 60 9a 10 c0       	push   $0xc0109a60
c0105b16:	68 d6 97 10 c0       	push   $0xc01097d6
c0105b1b:	68 17 01 00 00       	push   $0x117
c0105b20:	68 eb 97 10 c0       	push   $0xc01097eb
c0105b25:	e8 be a8 ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c0105b2a:	83 ec 0c             	sub    $0xc,%esp
c0105b2d:	6a 01                	push   $0x1
c0105b2f:	e8 13 06 00 00       	call   c0106147 <alloc_pages>
c0105b34:	83 c4 10             	add    $0x10,%esp
c0105b37:	85 c0                	test   %eax,%eax
c0105b39:	74 19                	je     c0105b54 <default_check+0x2c0>
c0105b3b:	68 76 99 10 c0       	push   $0xc0109976
c0105b40:	68 d6 97 10 c0       	push   $0xc01097d6
c0105b45:	68 18 01 00 00       	push   $0x118
c0105b4a:	68 eb 97 10 c0       	push   $0xc01097eb
c0105b4f:	e8 94 a8 ff ff       	call   c01003e8 <__panic>
    assert(p0 + 2 == p1);
c0105b54:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b57:	83 c0 40             	add    $0x40,%eax
c0105b5a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105b5d:	74 19                	je     c0105b78 <default_check+0x2e4>
c0105b5f:	68 7e 9a 10 c0       	push   $0xc0109a7e
c0105b64:	68 d6 97 10 c0       	push   $0xc01097d6
c0105b69:	68 19 01 00 00       	push   $0x119
c0105b6e:	68 eb 97 10 c0       	push   $0xc01097eb
c0105b73:	e8 70 a8 ff ff       	call   c01003e8 <__panic>

    p2 = p0 + 1;
c0105b78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b7b:	83 c0 20             	add    $0x20,%eax
c0105b7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0105b81:	83 ec 08             	sub    $0x8,%esp
c0105b84:	6a 01                	push   $0x1
c0105b86:	ff 75 e8             	pushl  -0x18(%ebp)
c0105b89:	e8 25 06 00 00       	call   c01061b3 <free_pages>
c0105b8e:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0105b91:	83 ec 08             	sub    $0x8,%esp
c0105b94:	6a 03                	push   $0x3
c0105b96:	ff 75 e0             	pushl  -0x20(%ebp)
c0105b99:	e8 15 06 00 00       	call   c01061b3 <free_pages>
c0105b9e:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0105ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ba4:	83 c0 04             	add    $0x4,%eax
c0105ba7:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105bae:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105bb1:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105bb4:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0105bb7:	0f a3 10             	bt     %edx,(%eax)
c0105bba:	19 c0                	sbb    %eax,%eax
c0105bbc:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105bbf:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105bc3:	0f 95 c0             	setne  %al
c0105bc6:	0f b6 c0             	movzbl %al,%eax
c0105bc9:	85 c0                	test   %eax,%eax
c0105bcb:	74 0b                	je     c0105bd8 <default_check+0x344>
c0105bcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bd0:	8b 40 08             	mov    0x8(%eax),%eax
c0105bd3:	83 f8 01             	cmp    $0x1,%eax
c0105bd6:	74 19                	je     c0105bf1 <default_check+0x35d>
c0105bd8:	68 8c 9a 10 c0       	push   $0xc0109a8c
c0105bdd:	68 d6 97 10 c0       	push   $0xc01097d6
c0105be2:	68 1e 01 00 00       	push   $0x11e
c0105be7:	68 eb 97 10 c0       	push   $0xc01097eb
c0105bec:	e8 f7 a7 ff ff       	call   c01003e8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105bf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bf4:	83 c0 04             	add    $0x4,%eax
c0105bf7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105bfe:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105c01:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105c04:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105c07:	0f a3 10             	bt     %edx,(%eax)
c0105c0a:	19 c0                	sbb    %eax,%eax
c0105c0c:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0105c0f:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105c13:	0f 95 c0             	setne  %al
c0105c16:	0f b6 c0             	movzbl %al,%eax
c0105c19:	85 c0                	test   %eax,%eax
c0105c1b:	74 0b                	je     c0105c28 <default_check+0x394>
c0105c1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c20:	8b 40 08             	mov    0x8(%eax),%eax
c0105c23:	83 f8 03             	cmp    $0x3,%eax
c0105c26:	74 19                	je     c0105c41 <default_check+0x3ad>
c0105c28:	68 b4 9a 10 c0       	push   $0xc0109ab4
c0105c2d:	68 d6 97 10 c0       	push   $0xc01097d6
c0105c32:	68 1f 01 00 00       	push   $0x11f
c0105c37:	68 eb 97 10 c0       	push   $0xc01097eb
c0105c3c:	e8 a7 a7 ff ff       	call   c01003e8 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105c41:	83 ec 0c             	sub    $0xc,%esp
c0105c44:	6a 01                	push   $0x1
c0105c46:	e8 fc 04 00 00       	call   c0106147 <alloc_pages>
c0105c4b:	83 c4 10             	add    $0x10,%esp
c0105c4e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c51:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c54:	83 e8 20             	sub    $0x20,%eax
c0105c57:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105c5a:	74 19                	je     c0105c75 <default_check+0x3e1>
c0105c5c:	68 da 9a 10 c0       	push   $0xc0109ada
c0105c61:	68 d6 97 10 c0       	push   $0xc01097d6
c0105c66:	68 21 01 00 00       	push   $0x121
c0105c6b:	68 eb 97 10 c0       	push   $0xc01097eb
c0105c70:	e8 73 a7 ff ff       	call   c01003e8 <__panic>
    free_page(p0);
c0105c75:	83 ec 08             	sub    $0x8,%esp
c0105c78:	6a 01                	push   $0x1
c0105c7a:	ff 75 e8             	pushl  -0x18(%ebp)
c0105c7d:	e8 31 05 00 00       	call   c01061b3 <free_pages>
c0105c82:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105c85:	83 ec 0c             	sub    $0xc,%esp
c0105c88:	6a 02                	push   $0x2
c0105c8a:	e8 b8 04 00 00       	call   c0106147 <alloc_pages>
c0105c8f:	83 c4 10             	add    $0x10,%esp
c0105c92:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c95:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c98:	83 c0 20             	add    $0x20,%eax
c0105c9b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105c9e:	74 19                	je     c0105cb9 <default_check+0x425>
c0105ca0:	68 f8 9a 10 c0       	push   $0xc0109af8
c0105ca5:	68 d6 97 10 c0       	push   $0xc01097d6
c0105caa:	68 23 01 00 00       	push   $0x123
c0105caf:	68 eb 97 10 c0       	push   $0xc01097eb
c0105cb4:	e8 2f a7 ff ff       	call   c01003e8 <__panic>

    free_pages(p0, 2);
c0105cb9:	83 ec 08             	sub    $0x8,%esp
c0105cbc:	6a 02                	push   $0x2
c0105cbe:	ff 75 e8             	pushl  -0x18(%ebp)
c0105cc1:	e8 ed 04 00 00       	call   c01061b3 <free_pages>
c0105cc6:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0105cc9:	83 ec 08             	sub    $0x8,%esp
c0105ccc:	6a 01                	push   $0x1
c0105cce:	ff 75 dc             	pushl  -0x24(%ebp)
c0105cd1:	e8 dd 04 00 00       	call   c01061b3 <free_pages>
c0105cd6:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c0105cd9:	83 ec 0c             	sub    $0xc,%esp
c0105cdc:	6a 05                	push   $0x5
c0105cde:	e8 64 04 00 00       	call   c0106147 <alloc_pages>
c0105ce3:	83 c4 10             	add    $0x10,%esp
c0105ce6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ce9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ced:	75 19                	jne    c0105d08 <default_check+0x474>
c0105cef:	68 18 9b 10 c0       	push   $0xc0109b18
c0105cf4:	68 d6 97 10 c0       	push   $0xc01097d6
c0105cf9:	68 28 01 00 00       	push   $0x128
c0105cfe:	68 eb 97 10 c0       	push   $0xc01097eb
c0105d03:	e8 e0 a6 ff ff       	call   c01003e8 <__panic>
    assert(alloc_page() == NULL);
c0105d08:	83 ec 0c             	sub    $0xc,%esp
c0105d0b:	6a 01                	push   $0x1
c0105d0d:	e8 35 04 00 00       	call   c0106147 <alloc_pages>
c0105d12:	83 c4 10             	add    $0x10,%esp
c0105d15:	85 c0                	test   %eax,%eax
c0105d17:	74 19                	je     c0105d32 <default_check+0x49e>
c0105d19:	68 76 99 10 c0       	push   $0xc0109976
c0105d1e:	68 d6 97 10 c0       	push   $0xc01097d6
c0105d23:	68 29 01 00 00       	push   $0x129
c0105d28:	68 eb 97 10 c0       	push   $0xc01097eb
c0105d2d:	e8 b6 a6 ff ff       	call   c01003e8 <__panic>

    assert(nr_free == 0);
c0105d32:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105d37:	85 c0                	test   %eax,%eax
c0105d39:	74 19                	je     c0105d54 <default_check+0x4c0>
c0105d3b:	68 c9 99 10 c0       	push   $0xc01099c9
c0105d40:	68 d6 97 10 c0       	push   $0xc01097d6
c0105d45:	68 2b 01 00 00       	push   $0x12b
c0105d4a:	68 eb 97 10 c0       	push   $0xc01097eb
c0105d4f:	e8 94 a6 ff ff       	call   c01003e8 <__panic>
    nr_free = nr_free_store;
c0105d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d57:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec

    free_list = free_list_store;
c0105d5c:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105d5f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105d62:	a3 e4 40 12 c0       	mov    %eax,0xc01240e4
c0105d67:	89 15 e8 40 12 c0    	mov    %edx,0xc01240e8
    free_pages(p0, 5);
c0105d6d:	83 ec 08             	sub    $0x8,%esp
c0105d70:	6a 05                	push   $0x5
c0105d72:	ff 75 e8             	pushl  -0x18(%ebp)
c0105d75:	e8 39 04 00 00       	call   c01061b3 <free_pages>
c0105d7a:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0105d7d:	c7 45 ec e4 40 12 c0 	movl   $0xc01240e4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105d84:	eb 1d                	jmp    c0105da3 <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c0105d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d89:	83 e8 0c             	sub    $0xc,%eax
c0105d8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105d8f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105d93:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105d96:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105d99:	8b 40 08             	mov    0x8(%eax),%eax
c0105d9c:	29 c2                	sub    %eax,%edx
c0105d9e:	89 d0                	mov    %edx,%eax
c0105da0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105da3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105da6:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105da9:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105dac:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105daf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105db2:	81 7d ec e4 40 12 c0 	cmpl   $0xc01240e4,-0x14(%ebp)
c0105db9:	75 cb                	jne    c0105d86 <default_check+0x4f2>
    }
    assert(count == 0);
c0105dbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105dbf:	74 19                	je     c0105dda <default_check+0x546>
c0105dc1:	68 36 9b 10 c0       	push   $0xc0109b36
c0105dc6:	68 d6 97 10 c0       	push   $0xc01097d6
c0105dcb:	68 36 01 00 00       	push   $0x136
c0105dd0:	68 eb 97 10 c0       	push   $0xc01097eb
c0105dd5:	e8 0e a6 ff ff       	call   c01003e8 <__panic>
    assert(total == 0);
c0105dda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105dde:	74 19                	je     c0105df9 <default_check+0x565>
c0105de0:	68 41 9b 10 c0       	push   $0xc0109b41
c0105de5:	68 d6 97 10 c0       	push   $0xc01097d6
c0105dea:	68 37 01 00 00       	push   $0x137
c0105def:	68 eb 97 10 c0       	push   $0xc01097eb
c0105df4:	e8 ef a5 ff ff       	call   c01003e8 <__panic>
}
c0105df9:	90                   	nop
c0105dfa:	c9                   	leave  
c0105dfb:	c3                   	ret    

c0105dfc <page2ppn>:
page2ppn(struct Page *page) {
c0105dfc:	55                   	push   %ebp
c0105dfd:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105dff:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e02:	8b 15 f8 40 12 c0    	mov    0xc01240f8,%edx
c0105e08:	29 d0                	sub    %edx,%eax
c0105e0a:	c1 f8 05             	sar    $0x5,%eax
}
c0105e0d:	5d                   	pop    %ebp
c0105e0e:	c3                   	ret    

c0105e0f <page2pa>:
page2pa(struct Page *page) {
c0105e0f:	55                   	push   %ebp
c0105e10:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0105e12:	ff 75 08             	pushl  0x8(%ebp)
c0105e15:	e8 e2 ff ff ff       	call   c0105dfc <page2ppn>
c0105e1a:	83 c4 04             	add    $0x4,%esp
c0105e1d:	c1 e0 0c             	shl    $0xc,%eax
}
c0105e20:	c9                   	leave  
c0105e21:	c3                   	ret    

c0105e22 <pa2page>:
pa2page(uintptr_t pa) {
c0105e22:	55                   	push   %ebp
c0105e23:	89 e5                	mov    %esp,%ebp
c0105e25:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105e28:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e2b:	c1 e8 0c             	shr    $0xc,%eax
c0105e2e:	89 c2                	mov    %eax,%edx
c0105e30:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0105e35:	39 c2                	cmp    %eax,%edx
c0105e37:	72 14                	jb     c0105e4d <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105e39:	83 ec 04             	sub    $0x4,%esp
c0105e3c:	68 7c 9b 10 c0       	push   $0xc0109b7c
c0105e41:	6a 5b                	push   $0x5b
c0105e43:	68 9b 9b 10 c0       	push   $0xc0109b9b
c0105e48:	e8 9b a5 ff ff       	call   c01003e8 <__panic>
    return &pages[PPN(pa)];
c0105e4d:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0105e52:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e55:	c1 ea 0c             	shr    $0xc,%edx
c0105e58:	c1 e2 05             	shl    $0x5,%edx
c0105e5b:	01 d0                	add    %edx,%eax
}
c0105e5d:	c9                   	leave  
c0105e5e:	c3                   	ret    

c0105e5f <page2kva>:
page2kva(struct Page *page) {
c0105e5f:	55                   	push   %ebp
c0105e60:	89 e5                	mov    %esp,%ebp
c0105e62:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0105e65:	ff 75 08             	pushl  0x8(%ebp)
c0105e68:	e8 a2 ff ff ff       	call   c0105e0f <page2pa>
c0105e6d:	83 c4 04             	add    $0x4,%esp
c0105e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e76:	c1 e8 0c             	shr    $0xc,%eax
c0105e79:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e7c:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0105e81:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105e84:	72 14                	jb     c0105e9a <page2kva+0x3b>
c0105e86:	ff 75 f4             	pushl  -0xc(%ebp)
c0105e89:	68 ac 9b 10 c0       	push   $0xc0109bac
c0105e8e:	6a 62                	push   $0x62
c0105e90:	68 9b 9b 10 c0       	push   $0xc0109b9b
c0105e95:	e8 4e a5 ff ff       	call   c01003e8 <__panic>
c0105e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e9d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105ea2:	c9                   	leave  
c0105ea3:	c3                   	ret    

c0105ea4 <kva2page>:
kva2page(void *kva) {
c0105ea4:	55                   	push   %ebp
c0105ea5:	89 e5                	mov    %esp,%ebp
c0105ea7:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c0105eaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ead:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105eb0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105eb7:	77 14                	ja     c0105ecd <kva2page+0x29>
c0105eb9:	ff 75 f4             	pushl  -0xc(%ebp)
c0105ebc:	68 d0 9b 10 c0       	push   $0xc0109bd0
c0105ec1:	6a 67                	push   $0x67
c0105ec3:	68 9b 9b 10 c0       	push   $0xc0109b9b
c0105ec8:	e8 1b a5 ff ff       	call   c01003e8 <__panic>
c0105ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ed0:	05 00 00 00 40       	add    $0x40000000,%eax
c0105ed5:	83 ec 0c             	sub    $0xc,%esp
c0105ed8:	50                   	push   %eax
c0105ed9:	e8 44 ff ff ff       	call   c0105e22 <pa2page>
c0105ede:	83 c4 10             	add    $0x10,%esp
}
c0105ee1:	c9                   	leave  
c0105ee2:	c3                   	ret    

c0105ee3 <pte2page>:
pte2page(pte_t pte) {
c0105ee3:	55                   	push   %ebp
c0105ee4:	89 e5                	mov    %esp,%ebp
c0105ee6:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0105ee9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eec:	83 e0 01             	and    $0x1,%eax
c0105eef:	85 c0                	test   %eax,%eax
c0105ef1:	75 14                	jne    c0105f07 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0105ef3:	83 ec 04             	sub    $0x4,%esp
c0105ef6:	68 f4 9b 10 c0       	push   $0xc0109bf4
c0105efb:	6a 6d                	push   $0x6d
c0105efd:	68 9b 9b 10 c0       	push   $0xc0109b9b
c0105f02:	e8 e1 a4 ff ff       	call   c01003e8 <__panic>
    return pa2page(PTE_ADDR(pte));
c0105f07:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105f0f:	83 ec 0c             	sub    $0xc,%esp
c0105f12:	50                   	push   %eax
c0105f13:	e8 0a ff ff ff       	call   c0105e22 <pa2page>
c0105f18:	83 c4 10             	add    $0x10,%esp
}
c0105f1b:	c9                   	leave  
c0105f1c:	c3                   	ret    

c0105f1d <pde2page>:
pde2page(pde_t pde) {
c0105f1d:	55                   	push   %ebp
c0105f1e:	89 e5                	mov    %esp,%ebp
c0105f20:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0105f23:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105f2b:	83 ec 0c             	sub    $0xc,%esp
c0105f2e:	50                   	push   %eax
c0105f2f:	e8 ee fe ff ff       	call   c0105e22 <pa2page>
c0105f34:	83 c4 10             	add    $0x10,%esp
}
c0105f37:	c9                   	leave  
c0105f38:	c3                   	ret    

c0105f39 <page_ref>:
page_ref(struct Page *page) {
c0105f39:	55                   	push   %ebp
c0105f3a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105f3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3f:	8b 00                	mov    (%eax),%eax
}
c0105f41:	5d                   	pop    %ebp
c0105f42:	c3                   	ret    

c0105f43 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0105f43:	55                   	push   %ebp
c0105f44:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105f46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f49:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105f4c:	89 10                	mov    %edx,(%eax)
}
c0105f4e:	90                   	nop
c0105f4f:	5d                   	pop    %ebp
c0105f50:	c3                   	ret    

c0105f51 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0105f51:	55                   	push   %ebp
c0105f52:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0105f54:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f57:	8b 00                	mov    (%eax),%eax
c0105f59:	8d 50 01             	lea    0x1(%eax),%edx
c0105f5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f5f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105f61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f64:	8b 00                	mov    (%eax),%eax
}
c0105f66:	5d                   	pop    %ebp
c0105f67:	c3                   	ret    

c0105f68 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0105f68:	55                   	push   %ebp
c0105f69:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0105f6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f6e:	8b 00                	mov    (%eax),%eax
c0105f70:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f73:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f76:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105f78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f7b:	8b 00                	mov    (%eax),%eax
}
c0105f7d:	5d                   	pop    %ebp
c0105f7e:	c3                   	ret    

c0105f7f <__intr_save>:
__intr_save(void) {
c0105f7f:	55                   	push   %ebp
c0105f80:	89 e5                	mov    %esp,%ebp
c0105f82:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0105f85:	9c                   	pushf  
c0105f86:	58                   	pop    %eax
c0105f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0105f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0105f8d:	25 00 02 00 00       	and    $0x200,%eax
c0105f92:	85 c0                	test   %eax,%eax
c0105f94:	74 0c                	je     c0105fa2 <__intr_save+0x23>
        intr_disable();
c0105f96:	e8 a9 c0 ff ff       	call   c0102044 <intr_disable>
        return 1;
c0105f9b:	b8 01 00 00 00       	mov    $0x1,%eax
c0105fa0:	eb 05                	jmp    c0105fa7 <__intr_save+0x28>
    return 0;
c0105fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fa7:	c9                   	leave  
c0105fa8:	c3                   	ret    

c0105fa9 <__intr_restore>:
__intr_restore(bool flag) {
c0105fa9:	55                   	push   %ebp
c0105faa:	89 e5                	mov    %esp,%ebp
c0105fac:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0105faf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105fb3:	74 05                	je     c0105fba <__intr_restore+0x11>
        intr_enable();
c0105fb5:	e8 83 c0 ff ff       	call   c010203d <intr_enable>
}
c0105fba:	90                   	nop
c0105fbb:	c9                   	leave  
c0105fbc:	c3                   	ret    

c0105fbd <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0105fbd:	55                   	push   %ebp
c0105fbe:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0105fc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc3:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0105fc6:	b8 23 00 00 00       	mov    $0x23,%eax
c0105fcb:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0105fcd:	b8 23 00 00 00       	mov    $0x23,%eax
c0105fd2:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0105fd4:	b8 10 00 00 00       	mov    $0x10,%eax
c0105fd9:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0105fdb:	b8 10 00 00 00       	mov    $0x10,%eax
c0105fe0:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0105fe2:	b8 10 00 00 00       	mov    $0x10,%eax
c0105fe7:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0105fe9:	ea f0 5f 10 c0 08 00 	ljmp   $0x8,$0xc0105ff0
}
c0105ff0:	90                   	nop
c0105ff1:	5d                   	pop    %ebp
c0105ff2:	c3                   	ret    

c0105ff3 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0105ff3:	55                   	push   %ebp
c0105ff4:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0105ff6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ff9:	a3 a4 3f 12 c0       	mov    %eax,0xc0123fa4
}
c0105ffe:	90                   	nop
c0105fff:	5d                   	pop    %ebp
c0106000:	c3                   	ret    

c0106001 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0106001:	55                   	push   %ebp
c0106002:	89 e5                	mov    %esp,%ebp
c0106004:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0106007:	b8 00 00 12 c0       	mov    $0xc0120000,%eax
c010600c:	50                   	push   %eax
c010600d:	e8 e1 ff ff ff       	call   c0105ff3 <load_esp0>
c0106012:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0106015:	66 c7 05 a8 3f 12 c0 	movw   $0x10,0xc0123fa8
c010601c:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010601e:	66 c7 05 48 0a 12 c0 	movw   $0x68,0xc0120a48
c0106025:	68 00 
c0106027:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c010602c:	66 a3 4a 0a 12 c0    	mov    %ax,0xc0120a4a
c0106032:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c0106037:	c1 e8 10             	shr    $0x10,%eax
c010603a:	a2 4c 0a 12 c0       	mov    %al,0xc0120a4c
c010603f:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c0106046:	83 e0 f0             	and    $0xfffffff0,%eax
c0106049:	83 c8 09             	or     $0x9,%eax
c010604c:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106051:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c0106058:	83 e0 ef             	and    $0xffffffef,%eax
c010605b:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106060:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c0106067:	83 e0 9f             	and    $0xffffff9f,%eax
c010606a:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c010606f:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c0106076:	83 c8 80             	or     $0xffffff80,%eax
c0106079:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c010607e:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c0106085:	83 e0 f0             	and    $0xfffffff0,%eax
c0106088:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c010608d:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c0106094:	83 e0 ef             	and    $0xffffffef,%eax
c0106097:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c010609c:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01060a3:	83 e0 df             	and    $0xffffffdf,%eax
c01060a6:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01060ab:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01060b2:	83 c8 40             	or     $0x40,%eax
c01060b5:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01060ba:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c01060c1:	83 e0 7f             	and    $0x7f,%eax
c01060c4:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c01060c9:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c01060ce:	c1 e8 18             	shr    $0x18,%eax
c01060d1:	a2 4f 0a 12 c0       	mov    %al,0xc0120a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01060d6:	68 50 0a 12 c0       	push   $0xc0120a50
c01060db:	e8 dd fe ff ff       	call   c0105fbd <lgdt>
c01060e0:	83 c4 04             	add    $0x4,%esp
c01060e3:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01060e9:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01060ed:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01060f0:	90                   	nop
c01060f1:	c9                   	leave  
c01060f2:	c3                   	ret    

c01060f3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01060f3:	55                   	push   %ebp
c01060f4:	89 e5                	mov    %esp,%ebp
c01060f6:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c01060f9:	c7 05 f0 40 12 c0 60 	movl   $0xc0109b60,0xc01240f0
c0106100:	9b 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0106103:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106108:	8b 00                	mov    (%eax),%eax
c010610a:	83 ec 08             	sub    $0x8,%esp
c010610d:	50                   	push   %eax
c010610e:	68 20 9c 10 c0       	push   $0xc0109c20
c0106113:	e8 6a a1 ff ff       	call   c0100282 <cprintf>
c0106118:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c010611b:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106120:	8b 40 04             	mov    0x4(%eax),%eax
c0106123:	ff d0                	call   *%eax
}
c0106125:	90                   	nop
c0106126:	c9                   	leave  
c0106127:	c3                   	ret    

c0106128 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0106128:	55                   	push   %ebp
c0106129:	89 e5                	mov    %esp,%ebp
c010612b:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c010612e:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106133:	8b 40 08             	mov    0x8(%eax),%eax
c0106136:	83 ec 08             	sub    $0x8,%esp
c0106139:	ff 75 0c             	pushl  0xc(%ebp)
c010613c:	ff 75 08             	pushl  0x8(%ebp)
c010613f:	ff d0                	call   *%eax
c0106141:	83 c4 10             	add    $0x10,%esp
}
c0106144:	90                   	nop
c0106145:	c9                   	leave  
c0106146:	c3                   	ret    

c0106147 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0106147:	55                   	push   %ebp
c0106148:	89 e5                	mov    %esp,%ebp
c010614a:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c010614d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0106154:	e8 26 fe ff ff       	call   c0105f7f <__intr_save>
c0106159:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c010615c:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106161:	8b 40 0c             	mov    0xc(%eax),%eax
c0106164:	83 ec 0c             	sub    $0xc,%esp
c0106167:	ff 75 08             	pushl  0x8(%ebp)
c010616a:	ff d0                	call   *%eax
c010616c:	83 c4 10             	add    $0x10,%esp
c010616f:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106172:	83 ec 0c             	sub    $0xc,%esp
c0106175:	ff 75 f0             	pushl  -0x10(%ebp)
c0106178:	e8 2c fe ff ff       	call   c0105fa9 <__intr_restore>
c010617d:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0106180:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106184:	75 28                	jne    c01061ae <alloc_pages+0x67>
c0106186:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010618a:	77 22                	ja     c01061ae <alloc_pages+0x67>
c010618c:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0106191:	85 c0                	test   %eax,%eax
c0106193:	74 19                	je     c01061ae <alloc_pages+0x67>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0106195:	8b 55 08             	mov    0x8(%ebp),%edx
c0106198:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c010619d:	83 ec 04             	sub    $0x4,%esp
c01061a0:	6a 00                	push   $0x0
c01061a2:	52                   	push   %edx
c01061a3:	50                   	push   %eax
c01061a4:	e8 53 e3 ff ff       	call   c01044fc <swap_out>
c01061a9:	83 c4 10             	add    $0x10,%esp
    {
c01061ac:	eb a6                	jmp    c0106154 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01061ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01061b1:	c9                   	leave  
c01061b2:	c3                   	ret    

c01061b3 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01061b3:	55                   	push   %ebp
c01061b4:	89 e5                	mov    %esp,%ebp
c01061b6:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01061b9:	e8 c1 fd ff ff       	call   c0105f7f <__intr_save>
c01061be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01061c1:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c01061c6:	8b 40 10             	mov    0x10(%eax),%eax
c01061c9:	83 ec 08             	sub    $0x8,%esp
c01061cc:	ff 75 0c             	pushl  0xc(%ebp)
c01061cf:	ff 75 08             	pushl  0x8(%ebp)
c01061d2:	ff d0                	call   *%eax
c01061d4:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01061d7:	83 ec 0c             	sub    $0xc,%esp
c01061da:	ff 75 f4             	pushl  -0xc(%ebp)
c01061dd:	e8 c7 fd ff ff       	call   c0105fa9 <__intr_restore>
c01061e2:	83 c4 10             	add    $0x10,%esp
}
c01061e5:	90                   	nop
c01061e6:	c9                   	leave  
c01061e7:	c3                   	ret    

c01061e8 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01061e8:	55                   	push   %ebp
c01061e9:	89 e5                	mov    %esp,%ebp
c01061eb:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01061ee:	e8 8c fd ff ff       	call   c0105f7f <__intr_save>
c01061f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01061f6:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c01061fb:	8b 40 14             	mov    0x14(%eax),%eax
c01061fe:	ff d0                	call   *%eax
c0106200:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0106203:	83 ec 0c             	sub    $0xc,%esp
c0106206:	ff 75 f4             	pushl  -0xc(%ebp)
c0106209:	e8 9b fd ff ff       	call   c0105fa9 <__intr_restore>
c010620e:	83 c4 10             	add    $0x10,%esp
    return ret;
c0106211:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0106214:	c9                   	leave  
c0106215:	c3                   	ret    

c0106216 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0106216:	55                   	push   %ebp
c0106217:	89 e5                	mov    %esp,%ebp
c0106219:	57                   	push   %edi
c010621a:	56                   	push   %esi
c010621b:	53                   	push   %ebx
c010621c:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010621f:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0106226:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010622d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106234:	83 ec 0c             	sub    $0xc,%esp
c0106237:	68 37 9c 10 c0       	push   $0xc0109c37
c010623c:	e8 41 a0 ff ff       	call   c0100282 <cprintf>
c0106241:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106244:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010624b:	e9 fc 00 00 00       	jmp    c010634c <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106250:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106253:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106256:	89 d0                	mov    %edx,%eax
c0106258:	c1 e0 02             	shl    $0x2,%eax
c010625b:	01 d0                	add    %edx,%eax
c010625d:	c1 e0 02             	shl    $0x2,%eax
c0106260:	01 c8                	add    %ecx,%eax
c0106262:	8b 50 08             	mov    0x8(%eax),%edx
c0106265:	8b 40 04             	mov    0x4(%eax),%eax
c0106268:	89 45 a0             	mov    %eax,-0x60(%ebp)
c010626b:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010626e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106271:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106274:	89 d0                	mov    %edx,%eax
c0106276:	c1 e0 02             	shl    $0x2,%eax
c0106279:	01 d0                	add    %edx,%eax
c010627b:	c1 e0 02             	shl    $0x2,%eax
c010627e:	01 c8                	add    %ecx,%eax
c0106280:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106283:	8b 58 10             	mov    0x10(%eax),%ebx
c0106286:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106289:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010628c:	01 c8                	add    %ecx,%eax
c010628e:	11 da                	adc    %ebx,%edx
c0106290:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106293:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106296:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106299:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010629c:	89 d0                	mov    %edx,%eax
c010629e:	c1 e0 02             	shl    $0x2,%eax
c01062a1:	01 d0                	add    %edx,%eax
c01062a3:	c1 e0 02             	shl    $0x2,%eax
c01062a6:	01 c8                	add    %ecx,%eax
c01062a8:	83 c0 14             	add    $0x14,%eax
c01062ab:	8b 00                	mov    (%eax),%eax
c01062ad:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01062b0:	8b 45 98             	mov    -0x68(%ebp),%eax
c01062b3:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01062b6:	83 c0 ff             	add    $0xffffffff,%eax
c01062b9:	83 d2 ff             	adc    $0xffffffff,%edx
c01062bc:	89 c1                	mov    %eax,%ecx
c01062be:	89 d3                	mov    %edx,%ebx
c01062c0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01062c3:	89 55 80             	mov    %edx,-0x80(%ebp)
c01062c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062c9:	89 d0                	mov    %edx,%eax
c01062cb:	c1 e0 02             	shl    $0x2,%eax
c01062ce:	01 d0                	add    %edx,%eax
c01062d0:	c1 e0 02             	shl    $0x2,%eax
c01062d3:	03 45 80             	add    -0x80(%ebp),%eax
c01062d6:	8b 50 10             	mov    0x10(%eax),%edx
c01062d9:	8b 40 0c             	mov    0xc(%eax),%eax
c01062dc:	ff 75 84             	pushl  -0x7c(%ebp)
c01062df:	53                   	push   %ebx
c01062e0:	51                   	push   %ecx
c01062e1:	ff 75 a4             	pushl  -0x5c(%ebp)
c01062e4:	ff 75 a0             	pushl  -0x60(%ebp)
c01062e7:	52                   	push   %edx
c01062e8:	50                   	push   %eax
c01062e9:	68 44 9c 10 c0       	push   $0xc0109c44
c01062ee:	e8 8f 9f ff ff       	call   c0100282 <cprintf>
c01062f3:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01062f6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01062f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062fc:	89 d0                	mov    %edx,%eax
c01062fe:	c1 e0 02             	shl    $0x2,%eax
c0106301:	01 d0                	add    %edx,%eax
c0106303:	c1 e0 02             	shl    $0x2,%eax
c0106306:	01 c8                	add    %ecx,%eax
c0106308:	83 c0 14             	add    $0x14,%eax
c010630b:	8b 00                	mov    (%eax),%eax
c010630d:	83 f8 01             	cmp    $0x1,%eax
c0106310:	75 36                	jne    c0106348 <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c0106312:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106315:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106318:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c010631b:	77 2b                	ja     c0106348 <page_init+0x132>
c010631d:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0106320:	72 05                	jb     c0106327 <page_init+0x111>
c0106322:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0106325:	73 21                	jae    c0106348 <page_init+0x132>
c0106327:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010632b:	77 1b                	ja     c0106348 <page_init+0x132>
c010632d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0106331:	72 09                	jb     c010633c <page_init+0x126>
c0106333:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c010633a:	77 0c                	ja     c0106348 <page_init+0x132>
                maxpa = end;
c010633c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010633f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106342:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106345:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0106348:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010634c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010634f:	8b 00                	mov    (%eax),%eax
c0106351:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106354:	0f 8c f6 fe ff ff    	jl     c0106250 <page_init+0x3a>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010635a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010635e:	72 1d                	jb     c010637d <page_init+0x167>
c0106360:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106364:	77 09                	ja     c010636f <page_init+0x159>
c0106366:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c010636d:	76 0e                	jbe    c010637d <page_init+0x167>
        maxpa = KMEMSIZE;
c010636f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0106376:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010637d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106380:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106383:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106387:	c1 ea 0c             	shr    $0xc,%edx
c010638a:	89 c1                	mov    %eax,%ecx
c010638c:	89 d3                	mov    %edx,%ebx
c010638e:	89 c8                	mov    %ecx,%eax
c0106390:	a3 80 3f 12 c0       	mov    %eax,0xc0123f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106395:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c010639c:	b8 fc 40 12 c0       	mov    $0xc01240fc,%eax
c01063a1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01063a4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01063a7:	01 d0                	add    %edx,%eax
c01063a9:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01063ac:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01063af:	ba 00 00 00 00       	mov    $0x0,%edx
c01063b4:	f7 75 c0             	divl   -0x40(%ebp)
c01063b7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01063ba:	29 d0                	sub    %edx,%eax
c01063bc:	a3 f8 40 12 c0       	mov    %eax,0xc01240f8

    for (i = 0; i < npage; i ++) {
c01063c1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01063c8:	eb 27                	jmp    c01063f1 <page_init+0x1db>
        SetPageReserved(pages + i);
c01063ca:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01063cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063d2:	c1 e2 05             	shl    $0x5,%edx
c01063d5:	01 d0                	add    %edx,%eax
c01063d7:	83 c0 04             	add    $0x4,%eax
c01063da:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01063e1:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01063e4:	8b 45 90             	mov    -0x70(%ebp),%eax
c01063e7:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01063ea:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c01063ed:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01063f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063f4:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01063f9:	39 c2                	cmp    %eax,%edx
c01063fb:	72 cd                	jb     c01063ca <page_init+0x1b4>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01063fd:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106402:	c1 e0 05             	shl    $0x5,%eax
c0106405:	89 c2                	mov    %eax,%edx
c0106407:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c010640c:	01 d0                	add    %edx,%eax
c010640e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106411:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0106418:	77 17                	ja     c0106431 <page_init+0x21b>
c010641a:	ff 75 b8             	pushl  -0x48(%ebp)
c010641d:	68 d0 9b 10 c0       	push   $0xc0109bd0
c0106422:	68 e9 00 00 00       	push   $0xe9
c0106427:	68 74 9c 10 c0       	push   $0xc0109c74
c010642c:	e8 b7 9f ff ff       	call   c01003e8 <__panic>
c0106431:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106434:	05 00 00 00 40       	add    $0x40000000,%eax
c0106439:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010643c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106443:	e9 71 01 00 00       	jmp    c01065b9 <page_init+0x3a3>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106448:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010644b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010644e:	89 d0                	mov    %edx,%eax
c0106450:	c1 e0 02             	shl    $0x2,%eax
c0106453:	01 d0                	add    %edx,%eax
c0106455:	c1 e0 02             	shl    $0x2,%eax
c0106458:	01 c8                	add    %ecx,%eax
c010645a:	8b 50 08             	mov    0x8(%eax),%edx
c010645d:	8b 40 04             	mov    0x4(%eax),%eax
c0106460:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106463:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106466:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106469:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010646c:	89 d0                	mov    %edx,%eax
c010646e:	c1 e0 02             	shl    $0x2,%eax
c0106471:	01 d0                	add    %edx,%eax
c0106473:	c1 e0 02             	shl    $0x2,%eax
c0106476:	01 c8                	add    %ecx,%eax
c0106478:	8b 48 0c             	mov    0xc(%eax),%ecx
c010647b:	8b 58 10             	mov    0x10(%eax),%ebx
c010647e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106481:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106484:	01 c8                	add    %ecx,%eax
c0106486:	11 da                	adc    %ebx,%edx
c0106488:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010648b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010648e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106491:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106494:	89 d0                	mov    %edx,%eax
c0106496:	c1 e0 02             	shl    $0x2,%eax
c0106499:	01 d0                	add    %edx,%eax
c010649b:	c1 e0 02             	shl    $0x2,%eax
c010649e:	01 c8                	add    %ecx,%eax
c01064a0:	83 c0 14             	add    $0x14,%eax
c01064a3:	8b 00                	mov    (%eax),%eax
c01064a5:	83 f8 01             	cmp    $0x1,%eax
c01064a8:	0f 85 07 01 00 00    	jne    c01065b5 <page_init+0x39f>
            if (begin < freemem) {
c01064ae:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01064b1:	ba 00 00 00 00       	mov    $0x0,%edx
c01064b6:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01064b9:	77 17                	ja     c01064d2 <page_init+0x2bc>
c01064bb:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01064be:	72 05                	jb     c01064c5 <page_init+0x2af>
c01064c0:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01064c3:	73 0d                	jae    c01064d2 <page_init+0x2bc>
                begin = freemem;
c01064c5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01064c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01064cb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01064d2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01064d6:	72 1d                	jb     c01064f5 <page_init+0x2df>
c01064d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01064dc:	77 09                	ja     c01064e7 <page_init+0x2d1>
c01064de:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01064e5:	76 0e                	jbe    c01064f5 <page_init+0x2df>
                end = KMEMSIZE;
c01064e7:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01064ee:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01064f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01064f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01064fb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01064fe:	0f 87 b1 00 00 00    	ja     c01065b5 <page_init+0x39f>
c0106504:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106507:	72 09                	jb     c0106512 <page_init+0x2fc>
c0106509:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010650c:	0f 83 a3 00 00 00    	jae    c01065b5 <page_init+0x39f>
                begin = ROUNDUP(begin, PGSIZE);
c0106512:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0106519:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010651c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010651f:	01 d0                	add    %edx,%eax
c0106521:	83 e8 01             	sub    $0x1,%eax
c0106524:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0106527:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010652a:	ba 00 00 00 00       	mov    $0x0,%edx
c010652f:	f7 75 b0             	divl   -0x50(%ebp)
c0106532:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106535:	29 d0                	sub    %edx,%eax
c0106537:	ba 00 00 00 00       	mov    $0x0,%edx
c010653c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010653f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106542:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106545:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0106548:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010654b:	ba 00 00 00 00       	mov    $0x0,%edx
c0106550:	89 c3                	mov    %eax,%ebx
c0106552:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0106558:	89 de                	mov    %ebx,%esi
c010655a:	89 d0                	mov    %edx,%eax
c010655c:	83 e0 00             	and    $0x0,%eax
c010655f:	89 c7                	mov    %eax,%edi
c0106561:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0106564:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0106567:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010656a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010656d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106570:	77 43                	ja     c01065b5 <page_init+0x39f>
c0106572:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106575:	72 05                	jb     c010657c <page_init+0x366>
c0106577:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010657a:	73 39                	jae    c01065b5 <page_init+0x39f>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010657c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010657f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106582:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0106585:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0106588:	89 c1                	mov    %eax,%ecx
c010658a:	89 d3                	mov    %edx,%ebx
c010658c:	89 c8                	mov    %ecx,%eax
c010658e:	89 da                	mov    %ebx,%edx
c0106590:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106594:	c1 ea 0c             	shr    $0xc,%edx
c0106597:	89 c3                	mov    %eax,%ebx
c0106599:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010659c:	83 ec 0c             	sub    $0xc,%esp
c010659f:	50                   	push   %eax
c01065a0:	e8 7d f8 ff ff       	call   c0105e22 <pa2page>
c01065a5:	83 c4 10             	add    $0x10,%esp
c01065a8:	83 ec 08             	sub    $0x8,%esp
c01065ab:	53                   	push   %ebx
c01065ac:	50                   	push   %eax
c01065ad:	e8 76 fb ff ff       	call   c0106128 <init_memmap>
c01065b2:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < memmap->nr_map; i ++) {
c01065b5:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01065b9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01065bc:	8b 00                	mov    (%eax),%eax
c01065be:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01065c1:	0f 8c 81 fe ff ff    	jl     c0106448 <page_init+0x232>
                }
            }
        }
    }
}
c01065c7:	90                   	nop
c01065c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01065cb:	5b                   	pop    %ebx
c01065cc:	5e                   	pop    %esi
c01065cd:	5f                   	pop    %edi
c01065ce:	5d                   	pop    %ebp
c01065cf:	c3                   	ret    

c01065d0 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01065d0:	55                   	push   %ebp
c01065d1:	89 e5                	mov    %esp,%ebp
c01065d3:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01065d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065d9:	33 45 14             	xor    0x14(%ebp),%eax
c01065dc:	25 ff 0f 00 00       	and    $0xfff,%eax
c01065e1:	85 c0                	test   %eax,%eax
c01065e3:	74 19                	je     c01065fe <boot_map_segment+0x2e>
c01065e5:	68 82 9c 10 c0       	push   $0xc0109c82
c01065ea:	68 99 9c 10 c0       	push   $0xc0109c99
c01065ef:	68 07 01 00 00       	push   $0x107
c01065f4:	68 74 9c 10 c0       	push   $0xc0109c74
c01065f9:	e8 ea 9d ff ff       	call   c01003e8 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01065fe:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0106605:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106608:	25 ff 0f 00 00       	and    $0xfff,%eax
c010660d:	89 c2                	mov    %eax,%edx
c010660f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106612:	01 c2                	add    %eax,%edx
c0106614:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106617:	01 d0                	add    %edx,%eax
c0106619:	83 e8 01             	sub    $0x1,%eax
c010661c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010661f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106622:	ba 00 00 00 00       	mov    $0x0,%edx
c0106627:	f7 75 f0             	divl   -0x10(%ebp)
c010662a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010662d:	29 d0                	sub    %edx,%eax
c010662f:	c1 e8 0c             	shr    $0xc,%eax
c0106632:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0106635:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106638:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010663b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010663e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106643:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0106646:	8b 45 14             	mov    0x14(%ebp),%eax
c0106649:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010664c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010664f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106654:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106657:	eb 57                	jmp    c01066b0 <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0106659:	83 ec 04             	sub    $0x4,%esp
c010665c:	6a 01                	push   $0x1
c010665e:	ff 75 0c             	pushl  0xc(%ebp)
c0106661:	ff 75 08             	pushl  0x8(%ebp)
c0106664:	e8 53 01 00 00       	call   c01067bc <get_pte>
c0106669:	83 c4 10             	add    $0x10,%esp
c010666c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010666f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106673:	75 19                	jne    c010668e <boot_map_segment+0xbe>
c0106675:	68 ae 9c 10 c0       	push   $0xc0109cae
c010667a:	68 99 9c 10 c0       	push   $0xc0109c99
c010667f:	68 0d 01 00 00       	push   $0x10d
c0106684:	68 74 9c 10 c0       	push   $0xc0109c74
c0106689:	e8 5a 9d ff ff       	call   c01003e8 <__panic>
        *ptep = pa | PTE_P | perm;
c010668e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106691:	0b 45 18             	or     0x18(%ebp),%eax
c0106694:	83 c8 01             	or     $0x1,%eax
c0106697:	89 c2                	mov    %eax,%edx
c0106699:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010669c:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010669e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01066a2:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01066a9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01066b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066b4:	75 a3                	jne    c0106659 <boot_map_segment+0x89>
    }
}
c01066b6:	90                   	nop
c01066b7:	c9                   	leave  
c01066b8:	c3                   	ret    

c01066b9 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01066b9:	55                   	push   %ebp
c01066ba:	89 e5                	mov    %esp,%ebp
c01066bc:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c01066bf:	83 ec 0c             	sub    $0xc,%esp
c01066c2:	6a 01                	push   $0x1
c01066c4:	e8 7e fa ff ff       	call   c0106147 <alloc_pages>
c01066c9:	83 c4 10             	add    $0x10,%esp
c01066cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01066cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066d3:	75 17                	jne    c01066ec <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c01066d5:	83 ec 04             	sub    $0x4,%esp
c01066d8:	68 bb 9c 10 c0       	push   $0xc0109cbb
c01066dd:	68 19 01 00 00       	push   $0x119
c01066e2:	68 74 9c 10 c0       	push   $0xc0109c74
c01066e7:	e8 fc 9c ff ff       	call   c01003e8 <__panic>
    }
    return page2kva(p);
c01066ec:	83 ec 0c             	sub    $0xc,%esp
c01066ef:	ff 75 f4             	pushl  -0xc(%ebp)
c01066f2:	e8 68 f7 ff ff       	call   c0105e5f <page2kva>
c01066f7:	83 c4 10             	add    $0x10,%esp
}
c01066fa:	c9                   	leave  
c01066fb:	c3                   	ret    

c01066fc <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01066fc:	55                   	push   %ebp
c01066fd:	89 e5                	mov    %esp,%ebp
c01066ff:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0106702:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106707:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010670a:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106711:	77 17                	ja     c010672a <pmm_init+0x2e>
c0106713:	ff 75 f4             	pushl  -0xc(%ebp)
c0106716:	68 d0 9b 10 c0       	push   $0xc0109bd0
c010671b:	68 23 01 00 00       	push   $0x123
c0106720:	68 74 9c 10 c0       	push   $0xc0109c74
c0106725:	e8 be 9c ff ff       	call   c01003e8 <__panic>
c010672a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010672d:	05 00 00 00 40       	add    $0x40000000,%eax
c0106732:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0106737:	e8 b7 f9 ff ff       	call   c01060f3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010673c:	e8 d5 fa ff ff       	call   c0106216 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0106741:	e8 38 04 00 00       	call   c0106b7e <check_alloc_page>

    check_pgdir();
c0106746:	e8 56 04 00 00       	call   c0106ba1 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010674b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106750:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106753:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010675a:	77 17                	ja     c0106773 <pmm_init+0x77>
c010675c:	ff 75 f0             	pushl  -0x10(%ebp)
c010675f:	68 d0 9b 10 c0       	push   $0xc0109bd0
c0106764:	68 39 01 00 00       	push   $0x139
c0106769:	68 74 9c 10 c0       	push   $0xc0109c74
c010676e:	e8 75 9c ff ff       	call   c01003e8 <__panic>
c0106773:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106776:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010677c:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106781:	05 ac 0f 00 00       	add    $0xfac,%eax
c0106786:	83 ca 03             	or     $0x3,%edx
c0106789:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010678b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106790:	83 ec 0c             	sub    $0xc,%esp
c0106793:	6a 02                	push   $0x2
c0106795:	6a 00                	push   $0x0
c0106797:	68 00 00 00 38       	push   $0x38000000
c010679c:	68 00 00 00 c0       	push   $0xc0000000
c01067a1:	50                   	push   %eax
c01067a2:	e8 29 fe ff ff       	call   c01065d0 <boot_map_segment>
c01067a7:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01067aa:	e8 52 f8 ff ff       	call   c0106001 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01067af:	e8 53 09 00 00       	call   c0107107 <check_boot_pgdir>

    print_pgdir();
c01067b4:	e8 49 0d 00 00       	call   c0107502 <print_pgdir>

}
c01067b9:	90                   	nop
c01067ba:	c9                   	leave  
c01067bb:	c3                   	ret    

c01067bc <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01067bc:	55                   	push   %ebp
c01067bd:	89 e5                	mov    %esp,%ebp
c01067bf:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01067c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067c5:	c1 e8 16             	shr    $0x16,%eax
c01067c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01067cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d2:	01 d0                	add    %edx,%eax
c01067d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01067d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067da:	8b 00                	mov    (%eax),%eax
c01067dc:	83 e0 01             	and    $0x1,%eax
c01067df:	85 c0                	test   %eax,%eax
c01067e1:	0f 85 9f 00 00 00    	jne    c0106886 <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01067e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01067eb:	74 16                	je     c0106803 <get_pte+0x47>
c01067ed:	83 ec 0c             	sub    $0xc,%esp
c01067f0:	6a 01                	push   $0x1
c01067f2:	e8 50 f9 ff ff       	call   c0106147 <alloc_pages>
c01067f7:	83 c4 10             	add    $0x10,%esp
c01067fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01067fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106801:	75 0a                	jne    c010680d <get_pte+0x51>
            return NULL;
c0106803:	b8 00 00 00 00       	mov    $0x0,%eax
c0106808:	e9 ca 00 00 00       	jmp    c01068d7 <get_pte+0x11b>
        }
        set_page_ref(page, 1);
c010680d:	83 ec 08             	sub    $0x8,%esp
c0106810:	6a 01                	push   $0x1
c0106812:	ff 75 f0             	pushl  -0x10(%ebp)
c0106815:	e8 29 f7 ff ff       	call   c0105f43 <set_page_ref>
c010681a:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c010681d:	83 ec 0c             	sub    $0xc,%esp
c0106820:	ff 75 f0             	pushl  -0x10(%ebp)
c0106823:	e8 e7 f5 ff ff       	call   c0105e0f <page2pa>
c0106828:	83 c4 10             	add    $0x10,%esp
c010682b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c010682e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106831:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106834:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106837:	c1 e8 0c             	shr    $0xc,%eax
c010683a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010683d:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106842:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106845:	72 17                	jb     c010685e <get_pte+0xa2>
c0106847:	ff 75 e8             	pushl  -0x18(%ebp)
c010684a:	68 ac 9b 10 c0       	push   $0xc0109bac
c010684f:	68 7f 01 00 00       	push   $0x17f
c0106854:	68 74 9c 10 c0       	push   $0xc0109c74
c0106859:	e8 8a 9b ff ff       	call   c01003e8 <__panic>
c010685e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106861:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106866:	83 ec 04             	sub    $0x4,%esp
c0106869:	68 00 10 00 00       	push   $0x1000
c010686e:	6a 00                	push   $0x0
c0106870:	50                   	push   %eax
c0106871:	e8 8a 13 00 00       	call   c0107c00 <memset>
c0106876:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0106879:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010687c:	83 c8 07             	or     $0x7,%eax
c010687f:	89 c2                	mov    %eax,%edx
c0106881:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106884:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0106886:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106889:	8b 00                	mov    (%eax),%eax
c010688b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106890:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106893:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106896:	c1 e8 0c             	shr    $0xc,%eax
c0106899:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010689c:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01068a1:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01068a4:	72 17                	jb     c01068bd <get_pte+0x101>
c01068a6:	ff 75 e0             	pushl  -0x20(%ebp)
c01068a9:	68 ac 9b 10 c0       	push   $0xc0109bac
c01068ae:	68 82 01 00 00       	push   $0x182
c01068b3:	68 74 9c 10 c0       	push   $0xc0109c74
c01068b8:	e8 2b 9b ff ff       	call   c01003e8 <__panic>
c01068bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01068c5:	89 c2                	mov    %eax,%edx
c01068c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068ca:	c1 e8 0c             	shr    $0xc,%eax
c01068cd:	25 ff 03 00 00       	and    $0x3ff,%eax
c01068d2:	c1 e0 02             	shl    $0x2,%eax
c01068d5:	01 d0                	add    %edx,%eax
}
c01068d7:	c9                   	leave  
c01068d8:	c3                   	ret    

c01068d9 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01068d9:	55                   	push   %ebp
c01068da:	89 e5                	mov    %esp,%ebp
c01068dc:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01068df:	83 ec 04             	sub    $0x4,%esp
c01068e2:	6a 00                	push   $0x0
c01068e4:	ff 75 0c             	pushl  0xc(%ebp)
c01068e7:	ff 75 08             	pushl  0x8(%ebp)
c01068ea:	e8 cd fe ff ff       	call   c01067bc <get_pte>
c01068ef:	83 c4 10             	add    $0x10,%esp
c01068f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01068f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01068f9:	74 08                	je     c0106903 <get_page+0x2a>
        *ptep_store = ptep;
c01068fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01068fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106901:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0106903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106907:	74 1f                	je     c0106928 <get_page+0x4f>
c0106909:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010690c:	8b 00                	mov    (%eax),%eax
c010690e:	83 e0 01             	and    $0x1,%eax
c0106911:	85 c0                	test   %eax,%eax
c0106913:	74 13                	je     c0106928 <get_page+0x4f>
        return pte2page(*ptep);
c0106915:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106918:	8b 00                	mov    (%eax),%eax
c010691a:	83 ec 0c             	sub    $0xc,%esp
c010691d:	50                   	push   %eax
c010691e:	e8 c0 f5 ff ff       	call   c0105ee3 <pte2page>
c0106923:	83 c4 10             	add    $0x10,%esp
c0106926:	eb 05                	jmp    c010692d <get_page+0x54>
    }
    return NULL;
c0106928:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010692d:	c9                   	leave  
c010692e:	c3                   	ret    

c010692f <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010692f:	55                   	push   %ebp
c0106930:	89 e5                	mov    %esp,%ebp
c0106932:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0106935:	8b 45 10             	mov    0x10(%ebp),%eax
c0106938:	8b 00                	mov    (%eax),%eax
c010693a:	83 e0 01             	and    $0x1,%eax
c010693d:	85 c0                	test   %eax,%eax
c010693f:	74 50                	je     c0106991 <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c0106941:	8b 45 10             	mov    0x10(%ebp),%eax
c0106944:	8b 00                	mov    (%eax),%eax
c0106946:	83 ec 0c             	sub    $0xc,%esp
c0106949:	50                   	push   %eax
c010694a:	e8 94 f5 ff ff       	call   c0105ee3 <pte2page>
c010694f:	83 c4 10             	add    $0x10,%esp
c0106952:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0106955:	83 ec 0c             	sub    $0xc,%esp
c0106958:	ff 75 f4             	pushl  -0xc(%ebp)
c010695b:	e8 08 f6 ff ff       	call   c0105f68 <page_ref_dec>
c0106960:	83 c4 10             	add    $0x10,%esp
c0106963:	85 c0                	test   %eax,%eax
c0106965:	75 10                	jne    c0106977 <page_remove_pte+0x48>
            free_page(page);
c0106967:	83 ec 08             	sub    $0x8,%esp
c010696a:	6a 01                	push   $0x1
c010696c:	ff 75 f4             	pushl  -0xc(%ebp)
c010696f:	e8 3f f8 ff ff       	call   c01061b3 <free_pages>
c0106974:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c0106977:	8b 45 10             	mov    0x10(%ebp),%eax
c010697a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0106980:	83 ec 08             	sub    $0x8,%esp
c0106983:	ff 75 0c             	pushl  0xc(%ebp)
c0106986:	ff 75 08             	pushl  0x8(%ebp)
c0106989:	e8 f8 00 00 00       	call   c0106a86 <tlb_invalidate>
c010698e:	83 c4 10             	add    $0x10,%esp
    }
}
c0106991:	90                   	nop
c0106992:	c9                   	leave  
c0106993:	c3                   	ret    

c0106994 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106994:	55                   	push   %ebp
c0106995:	89 e5                	mov    %esp,%ebp
c0106997:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010699a:	83 ec 04             	sub    $0x4,%esp
c010699d:	6a 00                	push   $0x0
c010699f:	ff 75 0c             	pushl  0xc(%ebp)
c01069a2:	ff 75 08             	pushl  0x8(%ebp)
c01069a5:	e8 12 fe ff ff       	call   c01067bc <get_pte>
c01069aa:	83 c4 10             	add    $0x10,%esp
c01069ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01069b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069b4:	74 14                	je     c01069ca <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c01069b6:	83 ec 04             	sub    $0x4,%esp
c01069b9:	ff 75 f4             	pushl  -0xc(%ebp)
c01069bc:	ff 75 0c             	pushl  0xc(%ebp)
c01069bf:	ff 75 08             	pushl  0x8(%ebp)
c01069c2:	e8 68 ff ff ff       	call   c010692f <page_remove_pte>
c01069c7:	83 c4 10             	add    $0x10,%esp
    }
}
c01069ca:	90                   	nop
c01069cb:	c9                   	leave  
c01069cc:	c3                   	ret    

c01069cd <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01069cd:	55                   	push   %ebp
c01069ce:	89 e5                	mov    %esp,%ebp
c01069d0:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01069d3:	83 ec 04             	sub    $0x4,%esp
c01069d6:	6a 01                	push   $0x1
c01069d8:	ff 75 10             	pushl  0x10(%ebp)
c01069db:	ff 75 08             	pushl  0x8(%ebp)
c01069de:	e8 d9 fd ff ff       	call   c01067bc <get_pte>
c01069e3:	83 c4 10             	add    $0x10,%esp
c01069e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01069e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069ed:	75 0a                	jne    c01069f9 <page_insert+0x2c>
        return -E_NO_MEM;
c01069ef:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01069f4:	e9 8b 00 00 00       	jmp    c0106a84 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01069f9:	83 ec 0c             	sub    $0xc,%esp
c01069fc:	ff 75 0c             	pushl  0xc(%ebp)
c01069ff:	e8 4d f5 ff ff       	call   c0105f51 <page_ref_inc>
c0106a04:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c0106a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a0a:	8b 00                	mov    (%eax),%eax
c0106a0c:	83 e0 01             	and    $0x1,%eax
c0106a0f:	85 c0                	test   %eax,%eax
c0106a11:	74 40                	je     c0106a53 <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c0106a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a16:	8b 00                	mov    (%eax),%eax
c0106a18:	83 ec 0c             	sub    $0xc,%esp
c0106a1b:	50                   	push   %eax
c0106a1c:	e8 c2 f4 ff ff       	call   c0105ee3 <pte2page>
c0106a21:	83 c4 10             	add    $0x10,%esp
c0106a24:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a2a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106a2d:	75 10                	jne    c0106a3f <page_insert+0x72>
            page_ref_dec(page);
c0106a2f:	83 ec 0c             	sub    $0xc,%esp
c0106a32:	ff 75 0c             	pushl  0xc(%ebp)
c0106a35:	e8 2e f5 ff ff       	call   c0105f68 <page_ref_dec>
c0106a3a:	83 c4 10             	add    $0x10,%esp
c0106a3d:	eb 14                	jmp    c0106a53 <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106a3f:	83 ec 04             	sub    $0x4,%esp
c0106a42:	ff 75 f4             	pushl  -0xc(%ebp)
c0106a45:	ff 75 10             	pushl  0x10(%ebp)
c0106a48:	ff 75 08             	pushl  0x8(%ebp)
c0106a4b:	e8 df fe ff ff       	call   c010692f <page_remove_pte>
c0106a50:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106a53:	83 ec 0c             	sub    $0xc,%esp
c0106a56:	ff 75 0c             	pushl  0xc(%ebp)
c0106a59:	e8 b1 f3 ff ff       	call   c0105e0f <page2pa>
c0106a5e:	83 c4 10             	add    $0x10,%esp
c0106a61:	0b 45 14             	or     0x14(%ebp),%eax
c0106a64:	83 c8 01             	or     $0x1,%eax
c0106a67:	89 c2                	mov    %eax,%edx
c0106a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a6c:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106a6e:	83 ec 08             	sub    $0x8,%esp
c0106a71:	ff 75 10             	pushl  0x10(%ebp)
c0106a74:	ff 75 08             	pushl  0x8(%ebp)
c0106a77:	e8 0a 00 00 00       	call   c0106a86 <tlb_invalidate>
c0106a7c:	83 c4 10             	add    $0x10,%esp
    return 0;
c0106a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106a84:	c9                   	leave  
c0106a85:	c3                   	ret    

c0106a86 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106a86:	55                   	push   %ebp
c0106a87:	89 e5                	mov    %esp,%ebp
c0106a89:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106a8c:	0f 20 d8             	mov    %cr3,%eax
c0106a8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0106a92:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0106a95:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a9b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106aa2:	77 17                	ja     c0106abb <tlb_invalidate+0x35>
c0106aa4:	ff 75 f4             	pushl  -0xc(%ebp)
c0106aa7:	68 d0 9b 10 c0       	push   $0xc0109bd0
c0106aac:	68 e4 01 00 00       	push   $0x1e4
c0106ab1:	68 74 9c 10 c0       	push   $0xc0109c74
c0106ab6:	e8 2d 99 ff ff       	call   c01003e8 <__panic>
c0106abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106abe:	05 00 00 00 40       	add    $0x40000000,%eax
c0106ac3:	39 d0                	cmp    %edx,%eax
c0106ac5:	75 0c                	jne    c0106ad3 <tlb_invalidate+0x4d>
        invlpg((void *)la);
c0106ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aca:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0106acd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ad0:	0f 01 38             	invlpg (%eax)
    }
}
c0106ad3:	90                   	nop
c0106ad4:	c9                   	leave  
c0106ad5:	c3                   	ret    

c0106ad6 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0106ad6:	55                   	push   %ebp
c0106ad7:	89 e5                	mov    %esp,%ebp
c0106ad9:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c0106adc:	83 ec 0c             	sub    $0xc,%esp
c0106adf:	6a 01                	push   $0x1
c0106ae1:	e8 61 f6 ff ff       	call   c0106147 <alloc_pages>
c0106ae6:	83 c4 10             	add    $0x10,%esp
c0106ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0106aec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106af0:	0f 84 83 00 00 00    	je     c0106b79 <pgdir_alloc_page+0xa3>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106af6:	ff 75 10             	pushl  0x10(%ebp)
c0106af9:	ff 75 0c             	pushl  0xc(%ebp)
c0106afc:	ff 75 f4             	pushl  -0xc(%ebp)
c0106aff:	ff 75 08             	pushl  0x8(%ebp)
c0106b02:	e8 c6 fe ff ff       	call   c01069cd <page_insert>
c0106b07:	83 c4 10             	add    $0x10,%esp
c0106b0a:	85 c0                	test   %eax,%eax
c0106b0c:	74 17                	je     c0106b25 <pgdir_alloc_page+0x4f>
            free_page(page);
c0106b0e:	83 ec 08             	sub    $0x8,%esp
c0106b11:	6a 01                	push   $0x1
c0106b13:	ff 75 f4             	pushl  -0xc(%ebp)
c0106b16:	e8 98 f6 ff ff       	call   c01061b3 <free_pages>
c0106b1b:	83 c4 10             	add    $0x10,%esp
            return NULL;
c0106b1e:	b8 00 00 00 00       	mov    $0x0,%eax
c0106b23:	eb 57                	jmp    c0106b7c <pgdir_alloc_page+0xa6>
        }
        if (swap_init_ok){
c0106b25:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0106b2a:	85 c0                	test   %eax,%eax
c0106b2c:	74 4b                	je     c0106b79 <pgdir_alloc_page+0xa3>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0106b2e:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0106b33:	6a 00                	push   $0x0
c0106b35:	ff 75 f4             	pushl  -0xc(%ebp)
c0106b38:	ff 75 0c             	pushl  0xc(%ebp)
c0106b3b:	50                   	push   %eax
c0106b3c:	e8 7c d9 ff ff       	call   c01044bd <swap_map_swappable>
c0106b41:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c0106b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b47:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106b4a:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0106b4d:	83 ec 0c             	sub    $0xc,%esp
c0106b50:	ff 75 f4             	pushl  -0xc(%ebp)
c0106b53:	e8 e1 f3 ff ff       	call   c0105f39 <page_ref>
c0106b58:	83 c4 10             	add    $0x10,%esp
c0106b5b:	83 f8 01             	cmp    $0x1,%eax
c0106b5e:	74 19                	je     c0106b79 <pgdir_alloc_page+0xa3>
c0106b60:	68 d4 9c 10 c0       	push   $0xc0109cd4
c0106b65:	68 99 9c 10 c0       	push   $0xc0109c99
c0106b6a:	68 f7 01 00 00       	push   $0x1f7
c0106b6f:	68 74 9c 10 c0       	push   $0xc0109c74
c0106b74:	e8 6f 98 ff ff       	call   c01003e8 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0106b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106b7c:	c9                   	leave  
c0106b7d:	c3                   	ret    

c0106b7e <check_alloc_page>:

static void
check_alloc_page(void) {
c0106b7e:	55                   	push   %ebp
c0106b7f:	89 e5                	mov    %esp,%ebp
c0106b81:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0106b84:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106b89:	8b 40 18             	mov    0x18(%eax),%eax
c0106b8c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0106b8e:	83 ec 0c             	sub    $0xc,%esp
c0106b91:	68 e8 9c 10 c0       	push   $0xc0109ce8
c0106b96:	e8 e7 96 ff ff       	call   c0100282 <cprintf>
c0106b9b:	83 c4 10             	add    $0x10,%esp
}
c0106b9e:	90                   	nop
c0106b9f:	c9                   	leave  
c0106ba0:	c3                   	ret    

c0106ba1 <check_pgdir>:

static void
check_pgdir(void) {
c0106ba1:	55                   	push   %ebp
c0106ba2:	89 e5                	mov    %esp,%ebp
c0106ba4:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106ba7:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106bac:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106bb1:	76 19                	jbe    c0106bcc <check_pgdir+0x2b>
c0106bb3:	68 07 9d 10 c0       	push   $0xc0109d07
c0106bb8:	68 99 9c 10 c0       	push   $0xc0109c99
c0106bbd:	68 08 02 00 00       	push   $0x208
c0106bc2:	68 74 9c 10 c0       	push   $0xc0109c74
c0106bc7:	e8 1c 98 ff ff       	call   c01003e8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0106bcc:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106bd1:	85 c0                	test   %eax,%eax
c0106bd3:	74 0e                	je     c0106be3 <check_pgdir+0x42>
c0106bd5:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106bda:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106bdf:	85 c0                	test   %eax,%eax
c0106be1:	74 19                	je     c0106bfc <check_pgdir+0x5b>
c0106be3:	68 24 9d 10 c0       	push   $0xc0109d24
c0106be8:	68 99 9c 10 c0       	push   $0xc0109c99
c0106bed:	68 09 02 00 00       	push   $0x209
c0106bf2:	68 74 9c 10 c0       	push   $0xc0109c74
c0106bf7:	e8 ec 97 ff ff       	call   c01003e8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0106bfc:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106c01:	83 ec 04             	sub    $0x4,%esp
c0106c04:	6a 00                	push   $0x0
c0106c06:	6a 00                	push   $0x0
c0106c08:	50                   	push   %eax
c0106c09:	e8 cb fc ff ff       	call   c01068d9 <get_page>
c0106c0e:	83 c4 10             	add    $0x10,%esp
c0106c11:	85 c0                	test   %eax,%eax
c0106c13:	74 19                	je     c0106c2e <check_pgdir+0x8d>
c0106c15:	68 5c 9d 10 c0       	push   $0xc0109d5c
c0106c1a:	68 99 9c 10 c0       	push   $0xc0109c99
c0106c1f:	68 0a 02 00 00       	push   $0x20a
c0106c24:	68 74 9c 10 c0       	push   $0xc0109c74
c0106c29:	e8 ba 97 ff ff       	call   c01003e8 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106c2e:	83 ec 0c             	sub    $0xc,%esp
c0106c31:	6a 01                	push   $0x1
c0106c33:	e8 0f f5 ff ff       	call   c0106147 <alloc_pages>
c0106c38:	83 c4 10             	add    $0x10,%esp
c0106c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106c3e:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106c43:	6a 00                	push   $0x0
c0106c45:	6a 00                	push   $0x0
c0106c47:	ff 75 f4             	pushl  -0xc(%ebp)
c0106c4a:	50                   	push   %eax
c0106c4b:	e8 7d fd ff ff       	call   c01069cd <page_insert>
c0106c50:	83 c4 10             	add    $0x10,%esp
c0106c53:	85 c0                	test   %eax,%eax
c0106c55:	74 19                	je     c0106c70 <check_pgdir+0xcf>
c0106c57:	68 84 9d 10 c0       	push   $0xc0109d84
c0106c5c:	68 99 9c 10 c0       	push   $0xc0109c99
c0106c61:	68 0e 02 00 00       	push   $0x20e
c0106c66:	68 74 9c 10 c0       	push   $0xc0109c74
c0106c6b:	e8 78 97 ff ff       	call   c01003e8 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106c70:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106c75:	83 ec 04             	sub    $0x4,%esp
c0106c78:	6a 00                	push   $0x0
c0106c7a:	6a 00                	push   $0x0
c0106c7c:	50                   	push   %eax
c0106c7d:	e8 3a fb ff ff       	call   c01067bc <get_pte>
c0106c82:	83 c4 10             	add    $0x10,%esp
c0106c85:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106c8c:	75 19                	jne    c0106ca7 <check_pgdir+0x106>
c0106c8e:	68 b0 9d 10 c0       	push   $0xc0109db0
c0106c93:	68 99 9c 10 c0       	push   $0xc0109c99
c0106c98:	68 11 02 00 00       	push   $0x211
c0106c9d:	68 74 9c 10 c0       	push   $0xc0109c74
c0106ca2:	e8 41 97 ff ff       	call   c01003e8 <__panic>
    assert(pte2page(*ptep) == p1);
c0106ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106caa:	8b 00                	mov    (%eax),%eax
c0106cac:	83 ec 0c             	sub    $0xc,%esp
c0106caf:	50                   	push   %eax
c0106cb0:	e8 2e f2 ff ff       	call   c0105ee3 <pte2page>
c0106cb5:	83 c4 10             	add    $0x10,%esp
c0106cb8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106cbb:	74 19                	je     c0106cd6 <check_pgdir+0x135>
c0106cbd:	68 dd 9d 10 c0       	push   $0xc0109ddd
c0106cc2:	68 99 9c 10 c0       	push   $0xc0109c99
c0106cc7:	68 12 02 00 00       	push   $0x212
c0106ccc:	68 74 9c 10 c0       	push   $0xc0109c74
c0106cd1:	e8 12 97 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p1) == 1);
c0106cd6:	83 ec 0c             	sub    $0xc,%esp
c0106cd9:	ff 75 f4             	pushl  -0xc(%ebp)
c0106cdc:	e8 58 f2 ff ff       	call   c0105f39 <page_ref>
c0106ce1:	83 c4 10             	add    $0x10,%esp
c0106ce4:	83 f8 01             	cmp    $0x1,%eax
c0106ce7:	74 19                	je     c0106d02 <check_pgdir+0x161>
c0106ce9:	68 f3 9d 10 c0       	push   $0xc0109df3
c0106cee:	68 99 9c 10 c0       	push   $0xc0109c99
c0106cf3:	68 13 02 00 00       	push   $0x213
c0106cf8:	68 74 9c 10 c0       	push   $0xc0109c74
c0106cfd:	e8 e6 96 ff ff       	call   c01003e8 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106d02:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106d07:	8b 00                	mov    (%eax),%eax
c0106d09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106d0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d14:	c1 e8 0c             	shr    $0xc,%eax
c0106d17:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106d1a:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106d1f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106d22:	72 17                	jb     c0106d3b <check_pgdir+0x19a>
c0106d24:	ff 75 ec             	pushl  -0x14(%ebp)
c0106d27:	68 ac 9b 10 c0       	push   $0xc0109bac
c0106d2c:	68 15 02 00 00       	push   $0x215
c0106d31:	68 74 9c 10 c0       	push   $0xc0109c74
c0106d36:	e8 ad 96 ff ff       	call   c01003e8 <__panic>
c0106d3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d3e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106d43:	83 c0 04             	add    $0x4,%eax
c0106d46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106d49:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106d4e:	83 ec 04             	sub    $0x4,%esp
c0106d51:	6a 00                	push   $0x0
c0106d53:	68 00 10 00 00       	push   $0x1000
c0106d58:	50                   	push   %eax
c0106d59:	e8 5e fa ff ff       	call   c01067bc <get_pte>
c0106d5e:	83 c4 10             	add    $0x10,%esp
c0106d61:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106d64:	74 19                	je     c0106d7f <check_pgdir+0x1de>
c0106d66:	68 08 9e 10 c0       	push   $0xc0109e08
c0106d6b:	68 99 9c 10 c0       	push   $0xc0109c99
c0106d70:	68 16 02 00 00       	push   $0x216
c0106d75:	68 74 9c 10 c0       	push   $0xc0109c74
c0106d7a:	e8 69 96 ff ff       	call   c01003e8 <__panic>

    p2 = alloc_page();
c0106d7f:	83 ec 0c             	sub    $0xc,%esp
c0106d82:	6a 01                	push   $0x1
c0106d84:	e8 be f3 ff ff       	call   c0106147 <alloc_pages>
c0106d89:	83 c4 10             	add    $0x10,%esp
c0106d8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0106d8f:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106d94:	6a 06                	push   $0x6
c0106d96:	68 00 10 00 00       	push   $0x1000
c0106d9b:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106d9e:	50                   	push   %eax
c0106d9f:	e8 29 fc ff ff       	call   c01069cd <page_insert>
c0106da4:	83 c4 10             	add    $0x10,%esp
c0106da7:	85 c0                	test   %eax,%eax
c0106da9:	74 19                	je     c0106dc4 <check_pgdir+0x223>
c0106dab:	68 30 9e 10 c0       	push   $0xc0109e30
c0106db0:	68 99 9c 10 c0       	push   $0xc0109c99
c0106db5:	68 19 02 00 00       	push   $0x219
c0106dba:	68 74 9c 10 c0       	push   $0xc0109c74
c0106dbf:	e8 24 96 ff ff       	call   c01003e8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106dc4:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106dc9:	83 ec 04             	sub    $0x4,%esp
c0106dcc:	6a 00                	push   $0x0
c0106dce:	68 00 10 00 00       	push   $0x1000
c0106dd3:	50                   	push   %eax
c0106dd4:	e8 e3 f9 ff ff       	call   c01067bc <get_pte>
c0106dd9:	83 c4 10             	add    $0x10,%esp
c0106ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ddf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106de3:	75 19                	jne    c0106dfe <check_pgdir+0x25d>
c0106de5:	68 68 9e 10 c0       	push   $0xc0109e68
c0106dea:	68 99 9c 10 c0       	push   $0xc0109c99
c0106def:	68 1a 02 00 00       	push   $0x21a
c0106df4:	68 74 9c 10 c0       	push   $0xc0109c74
c0106df9:	e8 ea 95 ff ff       	call   c01003e8 <__panic>
    assert(*ptep & PTE_U);
c0106dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e01:	8b 00                	mov    (%eax),%eax
c0106e03:	83 e0 04             	and    $0x4,%eax
c0106e06:	85 c0                	test   %eax,%eax
c0106e08:	75 19                	jne    c0106e23 <check_pgdir+0x282>
c0106e0a:	68 98 9e 10 c0       	push   $0xc0109e98
c0106e0f:	68 99 9c 10 c0       	push   $0xc0109c99
c0106e14:	68 1b 02 00 00       	push   $0x21b
c0106e19:	68 74 9c 10 c0       	push   $0xc0109c74
c0106e1e:	e8 c5 95 ff ff       	call   c01003e8 <__panic>
    assert(*ptep & PTE_W);
c0106e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e26:	8b 00                	mov    (%eax),%eax
c0106e28:	83 e0 02             	and    $0x2,%eax
c0106e2b:	85 c0                	test   %eax,%eax
c0106e2d:	75 19                	jne    c0106e48 <check_pgdir+0x2a7>
c0106e2f:	68 a6 9e 10 c0       	push   $0xc0109ea6
c0106e34:	68 99 9c 10 c0       	push   $0xc0109c99
c0106e39:	68 1c 02 00 00       	push   $0x21c
c0106e3e:	68 74 9c 10 c0       	push   $0xc0109c74
c0106e43:	e8 a0 95 ff ff       	call   c01003e8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0106e48:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106e4d:	8b 00                	mov    (%eax),%eax
c0106e4f:	83 e0 04             	and    $0x4,%eax
c0106e52:	85 c0                	test   %eax,%eax
c0106e54:	75 19                	jne    c0106e6f <check_pgdir+0x2ce>
c0106e56:	68 b4 9e 10 c0       	push   $0xc0109eb4
c0106e5b:	68 99 9c 10 c0       	push   $0xc0109c99
c0106e60:	68 1d 02 00 00       	push   $0x21d
c0106e65:	68 74 9c 10 c0       	push   $0xc0109c74
c0106e6a:	e8 79 95 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 1);
c0106e6f:	83 ec 0c             	sub    $0xc,%esp
c0106e72:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106e75:	e8 bf f0 ff ff       	call   c0105f39 <page_ref>
c0106e7a:	83 c4 10             	add    $0x10,%esp
c0106e7d:	83 f8 01             	cmp    $0x1,%eax
c0106e80:	74 19                	je     c0106e9b <check_pgdir+0x2fa>
c0106e82:	68 ca 9e 10 c0       	push   $0xc0109eca
c0106e87:	68 99 9c 10 c0       	push   $0xc0109c99
c0106e8c:	68 1e 02 00 00       	push   $0x21e
c0106e91:	68 74 9c 10 c0       	push   $0xc0109c74
c0106e96:	e8 4d 95 ff ff       	call   c01003e8 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0106e9b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106ea0:	6a 00                	push   $0x0
c0106ea2:	68 00 10 00 00       	push   $0x1000
c0106ea7:	ff 75 f4             	pushl  -0xc(%ebp)
c0106eaa:	50                   	push   %eax
c0106eab:	e8 1d fb ff ff       	call   c01069cd <page_insert>
c0106eb0:	83 c4 10             	add    $0x10,%esp
c0106eb3:	85 c0                	test   %eax,%eax
c0106eb5:	74 19                	je     c0106ed0 <check_pgdir+0x32f>
c0106eb7:	68 dc 9e 10 c0       	push   $0xc0109edc
c0106ebc:	68 99 9c 10 c0       	push   $0xc0109c99
c0106ec1:	68 20 02 00 00       	push   $0x220
c0106ec6:	68 74 9c 10 c0       	push   $0xc0109c74
c0106ecb:	e8 18 95 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p1) == 2);
c0106ed0:	83 ec 0c             	sub    $0xc,%esp
c0106ed3:	ff 75 f4             	pushl  -0xc(%ebp)
c0106ed6:	e8 5e f0 ff ff       	call   c0105f39 <page_ref>
c0106edb:	83 c4 10             	add    $0x10,%esp
c0106ede:	83 f8 02             	cmp    $0x2,%eax
c0106ee1:	74 19                	je     c0106efc <check_pgdir+0x35b>
c0106ee3:	68 08 9f 10 c0       	push   $0xc0109f08
c0106ee8:	68 99 9c 10 c0       	push   $0xc0109c99
c0106eed:	68 21 02 00 00       	push   $0x221
c0106ef2:	68 74 9c 10 c0       	push   $0xc0109c74
c0106ef7:	e8 ec 94 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 0);
c0106efc:	83 ec 0c             	sub    $0xc,%esp
c0106eff:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106f02:	e8 32 f0 ff ff       	call   c0105f39 <page_ref>
c0106f07:	83 c4 10             	add    $0x10,%esp
c0106f0a:	85 c0                	test   %eax,%eax
c0106f0c:	74 19                	je     c0106f27 <check_pgdir+0x386>
c0106f0e:	68 1a 9f 10 c0       	push   $0xc0109f1a
c0106f13:	68 99 9c 10 c0       	push   $0xc0109c99
c0106f18:	68 22 02 00 00       	push   $0x222
c0106f1d:	68 74 9c 10 c0       	push   $0xc0109c74
c0106f22:	e8 c1 94 ff ff       	call   c01003e8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106f27:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106f2c:	83 ec 04             	sub    $0x4,%esp
c0106f2f:	6a 00                	push   $0x0
c0106f31:	68 00 10 00 00       	push   $0x1000
c0106f36:	50                   	push   %eax
c0106f37:	e8 80 f8 ff ff       	call   c01067bc <get_pte>
c0106f3c:	83 c4 10             	add    $0x10,%esp
c0106f3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106f46:	75 19                	jne    c0106f61 <check_pgdir+0x3c0>
c0106f48:	68 68 9e 10 c0       	push   $0xc0109e68
c0106f4d:	68 99 9c 10 c0       	push   $0xc0109c99
c0106f52:	68 23 02 00 00       	push   $0x223
c0106f57:	68 74 9c 10 c0       	push   $0xc0109c74
c0106f5c:	e8 87 94 ff ff       	call   c01003e8 <__panic>
    assert(pte2page(*ptep) == p1);
c0106f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f64:	8b 00                	mov    (%eax),%eax
c0106f66:	83 ec 0c             	sub    $0xc,%esp
c0106f69:	50                   	push   %eax
c0106f6a:	e8 74 ef ff ff       	call   c0105ee3 <pte2page>
c0106f6f:	83 c4 10             	add    $0x10,%esp
c0106f72:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106f75:	74 19                	je     c0106f90 <check_pgdir+0x3ef>
c0106f77:	68 dd 9d 10 c0       	push   $0xc0109ddd
c0106f7c:	68 99 9c 10 c0       	push   $0xc0109c99
c0106f81:	68 24 02 00 00       	push   $0x224
c0106f86:	68 74 9c 10 c0       	push   $0xc0109c74
c0106f8b:	e8 58 94 ff ff       	call   c01003e8 <__panic>
    assert((*ptep & PTE_U) == 0);
c0106f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f93:	8b 00                	mov    (%eax),%eax
c0106f95:	83 e0 04             	and    $0x4,%eax
c0106f98:	85 c0                	test   %eax,%eax
c0106f9a:	74 19                	je     c0106fb5 <check_pgdir+0x414>
c0106f9c:	68 2c 9f 10 c0       	push   $0xc0109f2c
c0106fa1:	68 99 9c 10 c0       	push   $0xc0109c99
c0106fa6:	68 25 02 00 00       	push   $0x225
c0106fab:	68 74 9c 10 c0       	push   $0xc0109c74
c0106fb0:	e8 33 94 ff ff       	call   c01003e8 <__panic>

    page_remove(boot_pgdir, 0x0);
c0106fb5:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106fba:	83 ec 08             	sub    $0x8,%esp
c0106fbd:	6a 00                	push   $0x0
c0106fbf:	50                   	push   %eax
c0106fc0:	e8 cf f9 ff ff       	call   c0106994 <page_remove>
c0106fc5:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c0106fc8:	83 ec 0c             	sub    $0xc,%esp
c0106fcb:	ff 75 f4             	pushl  -0xc(%ebp)
c0106fce:	e8 66 ef ff ff       	call   c0105f39 <page_ref>
c0106fd3:	83 c4 10             	add    $0x10,%esp
c0106fd6:	83 f8 01             	cmp    $0x1,%eax
c0106fd9:	74 19                	je     c0106ff4 <check_pgdir+0x453>
c0106fdb:	68 f3 9d 10 c0       	push   $0xc0109df3
c0106fe0:	68 99 9c 10 c0       	push   $0xc0109c99
c0106fe5:	68 28 02 00 00       	push   $0x228
c0106fea:	68 74 9c 10 c0       	push   $0xc0109c74
c0106fef:	e8 f4 93 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 0);
c0106ff4:	83 ec 0c             	sub    $0xc,%esp
c0106ff7:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106ffa:	e8 3a ef ff ff       	call   c0105f39 <page_ref>
c0106fff:	83 c4 10             	add    $0x10,%esp
c0107002:	85 c0                	test   %eax,%eax
c0107004:	74 19                	je     c010701f <check_pgdir+0x47e>
c0107006:	68 1a 9f 10 c0       	push   $0xc0109f1a
c010700b:	68 99 9c 10 c0       	push   $0xc0109c99
c0107010:	68 29 02 00 00       	push   $0x229
c0107015:	68 74 9c 10 c0       	push   $0xc0109c74
c010701a:	e8 c9 93 ff ff       	call   c01003e8 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c010701f:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107024:	83 ec 08             	sub    $0x8,%esp
c0107027:	68 00 10 00 00       	push   $0x1000
c010702c:	50                   	push   %eax
c010702d:	e8 62 f9 ff ff       	call   c0106994 <page_remove>
c0107032:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0107035:	83 ec 0c             	sub    $0xc,%esp
c0107038:	ff 75 f4             	pushl  -0xc(%ebp)
c010703b:	e8 f9 ee ff ff       	call   c0105f39 <page_ref>
c0107040:	83 c4 10             	add    $0x10,%esp
c0107043:	85 c0                	test   %eax,%eax
c0107045:	74 19                	je     c0107060 <check_pgdir+0x4bf>
c0107047:	68 41 9f 10 c0       	push   $0xc0109f41
c010704c:	68 99 9c 10 c0       	push   $0xc0109c99
c0107051:	68 2c 02 00 00       	push   $0x22c
c0107056:	68 74 9c 10 c0       	push   $0xc0109c74
c010705b:	e8 88 93 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p2) == 0);
c0107060:	83 ec 0c             	sub    $0xc,%esp
c0107063:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107066:	e8 ce ee ff ff       	call   c0105f39 <page_ref>
c010706b:	83 c4 10             	add    $0x10,%esp
c010706e:	85 c0                	test   %eax,%eax
c0107070:	74 19                	je     c010708b <check_pgdir+0x4ea>
c0107072:	68 1a 9f 10 c0       	push   $0xc0109f1a
c0107077:	68 99 9c 10 c0       	push   $0xc0109c99
c010707c:	68 2d 02 00 00       	push   $0x22d
c0107081:	68 74 9c 10 c0       	push   $0xc0109c74
c0107086:	e8 5d 93 ff ff       	call   c01003e8 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010708b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107090:	8b 00                	mov    (%eax),%eax
c0107092:	83 ec 0c             	sub    $0xc,%esp
c0107095:	50                   	push   %eax
c0107096:	e8 82 ee ff ff       	call   c0105f1d <pde2page>
c010709b:	83 c4 10             	add    $0x10,%esp
c010709e:	83 ec 0c             	sub    $0xc,%esp
c01070a1:	50                   	push   %eax
c01070a2:	e8 92 ee ff ff       	call   c0105f39 <page_ref>
c01070a7:	83 c4 10             	add    $0x10,%esp
c01070aa:	83 f8 01             	cmp    $0x1,%eax
c01070ad:	74 19                	je     c01070c8 <check_pgdir+0x527>
c01070af:	68 54 9f 10 c0       	push   $0xc0109f54
c01070b4:	68 99 9c 10 c0       	push   $0xc0109c99
c01070b9:	68 2f 02 00 00       	push   $0x22f
c01070be:	68 74 9c 10 c0       	push   $0xc0109c74
c01070c3:	e8 20 93 ff ff       	call   c01003e8 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01070c8:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01070cd:	8b 00                	mov    (%eax),%eax
c01070cf:	83 ec 0c             	sub    $0xc,%esp
c01070d2:	50                   	push   %eax
c01070d3:	e8 45 ee ff ff       	call   c0105f1d <pde2page>
c01070d8:	83 c4 10             	add    $0x10,%esp
c01070db:	83 ec 08             	sub    $0x8,%esp
c01070de:	6a 01                	push   $0x1
c01070e0:	50                   	push   %eax
c01070e1:	e8 cd f0 ff ff       	call   c01061b3 <free_pages>
c01070e6:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c01070e9:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01070ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01070f4:	83 ec 0c             	sub    $0xc,%esp
c01070f7:	68 7b 9f 10 c0       	push   $0xc0109f7b
c01070fc:	e8 81 91 ff ff       	call   c0100282 <cprintf>
c0107101:	83 c4 10             	add    $0x10,%esp
}
c0107104:	90                   	nop
c0107105:	c9                   	leave  
c0107106:	c3                   	ret    

c0107107 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107107:	55                   	push   %ebp
c0107108:	89 e5                	mov    %esp,%ebp
c010710a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010710d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107114:	e9 a3 00 00 00       	jmp    c01071bc <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107119:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010711c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010711f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107122:	c1 e8 0c             	shr    $0xc,%eax
c0107125:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107128:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010712d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107130:	72 17                	jb     c0107149 <check_boot_pgdir+0x42>
c0107132:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107135:	68 ac 9b 10 c0       	push   $0xc0109bac
c010713a:	68 3b 02 00 00       	push   $0x23b
c010713f:	68 74 9c 10 c0       	push   $0xc0109c74
c0107144:	e8 9f 92 ff ff       	call   c01003e8 <__panic>
c0107149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010714c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107151:	89 c2                	mov    %eax,%edx
c0107153:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107158:	83 ec 04             	sub    $0x4,%esp
c010715b:	6a 00                	push   $0x0
c010715d:	52                   	push   %edx
c010715e:	50                   	push   %eax
c010715f:	e8 58 f6 ff ff       	call   c01067bc <get_pte>
c0107164:	83 c4 10             	add    $0x10,%esp
c0107167:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010716a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010716e:	75 19                	jne    c0107189 <check_boot_pgdir+0x82>
c0107170:	68 98 9f 10 c0       	push   $0xc0109f98
c0107175:	68 99 9c 10 c0       	push   $0xc0109c99
c010717a:	68 3b 02 00 00       	push   $0x23b
c010717f:	68 74 9c 10 c0       	push   $0xc0109c74
c0107184:	e8 5f 92 ff ff       	call   c01003e8 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107189:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010718c:	8b 00                	mov    (%eax),%eax
c010718e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107193:	89 c2                	mov    %eax,%edx
c0107195:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107198:	39 c2                	cmp    %eax,%edx
c010719a:	74 19                	je     c01071b5 <check_boot_pgdir+0xae>
c010719c:	68 d5 9f 10 c0       	push   $0xc0109fd5
c01071a1:	68 99 9c 10 c0       	push   $0xc0109c99
c01071a6:	68 3c 02 00 00       	push   $0x23c
c01071ab:	68 74 9c 10 c0       	push   $0xc0109c74
c01071b0:	e8 33 92 ff ff       	call   c01003e8 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01071b5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01071bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01071bf:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01071c4:	39 c2                	cmp    %eax,%edx
c01071c6:	0f 82 4d ff ff ff    	jb     c0107119 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01071cc:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01071d1:	05 ac 0f 00 00       	add    $0xfac,%eax
c01071d6:	8b 00                	mov    (%eax),%eax
c01071d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01071dd:	89 c2                	mov    %eax,%edx
c01071df:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01071e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01071e7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01071ee:	77 17                	ja     c0107207 <check_boot_pgdir+0x100>
c01071f0:	ff 75 f0             	pushl  -0x10(%ebp)
c01071f3:	68 d0 9b 10 c0       	push   $0xc0109bd0
c01071f8:	68 3f 02 00 00       	push   $0x23f
c01071fd:	68 74 9c 10 c0       	push   $0xc0109c74
c0107202:	e8 e1 91 ff ff       	call   c01003e8 <__panic>
c0107207:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010720a:	05 00 00 00 40       	add    $0x40000000,%eax
c010720f:	39 d0                	cmp    %edx,%eax
c0107211:	74 19                	je     c010722c <check_boot_pgdir+0x125>
c0107213:	68 ec 9f 10 c0       	push   $0xc0109fec
c0107218:	68 99 9c 10 c0       	push   $0xc0109c99
c010721d:	68 3f 02 00 00       	push   $0x23f
c0107222:	68 74 9c 10 c0       	push   $0xc0109c74
c0107227:	e8 bc 91 ff ff       	call   c01003e8 <__panic>

    assert(boot_pgdir[0] == 0);
c010722c:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107231:	8b 00                	mov    (%eax),%eax
c0107233:	85 c0                	test   %eax,%eax
c0107235:	74 19                	je     c0107250 <check_boot_pgdir+0x149>
c0107237:	68 20 a0 10 c0       	push   $0xc010a020
c010723c:	68 99 9c 10 c0       	push   $0xc0109c99
c0107241:	68 41 02 00 00       	push   $0x241
c0107246:	68 74 9c 10 c0       	push   $0xc0109c74
c010724b:	e8 98 91 ff ff       	call   c01003e8 <__panic>

    struct Page *p;
    p = alloc_page();
c0107250:	83 ec 0c             	sub    $0xc,%esp
c0107253:	6a 01                	push   $0x1
c0107255:	e8 ed ee ff ff       	call   c0106147 <alloc_pages>
c010725a:	83 c4 10             	add    $0x10,%esp
c010725d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107260:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107265:	6a 02                	push   $0x2
c0107267:	68 00 01 00 00       	push   $0x100
c010726c:	ff 75 ec             	pushl  -0x14(%ebp)
c010726f:	50                   	push   %eax
c0107270:	e8 58 f7 ff ff       	call   c01069cd <page_insert>
c0107275:	83 c4 10             	add    $0x10,%esp
c0107278:	85 c0                	test   %eax,%eax
c010727a:	74 19                	je     c0107295 <check_boot_pgdir+0x18e>
c010727c:	68 34 a0 10 c0       	push   $0xc010a034
c0107281:	68 99 9c 10 c0       	push   $0xc0109c99
c0107286:	68 45 02 00 00       	push   $0x245
c010728b:	68 74 9c 10 c0       	push   $0xc0109c74
c0107290:	e8 53 91 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p) == 1);
c0107295:	83 ec 0c             	sub    $0xc,%esp
c0107298:	ff 75 ec             	pushl  -0x14(%ebp)
c010729b:	e8 99 ec ff ff       	call   c0105f39 <page_ref>
c01072a0:	83 c4 10             	add    $0x10,%esp
c01072a3:	83 f8 01             	cmp    $0x1,%eax
c01072a6:	74 19                	je     c01072c1 <check_boot_pgdir+0x1ba>
c01072a8:	68 62 a0 10 c0       	push   $0xc010a062
c01072ad:	68 99 9c 10 c0       	push   $0xc0109c99
c01072b2:	68 46 02 00 00       	push   $0x246
c01072b7:	68 74 9c 10 c0       	push   $0xc0109c74
c01072bc:	e8 27 91 ff ff       	call   c01003e8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01072c1:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01072c6:	6a 02                	push   $0x2
c01072c8:	68 00 11 00 00       	push   $0x1100
c01072cd:	ff 75 ec             	pushl  -0x14(%ebp)
c01072d0:	50                   	push   %eax
c01072d1:	e8 f7 f6 ff ff       	call   c01069cd <page_insert>
c01072d6:	83 c4 10             	add    $0x10,%esp
c01072d9:	85 c0                	test   %eax,%eax
c01072db:	74 19                	je     c01072f6 <check_boot_pgdir+0x1ef>
c01072dd:	68 74 a0 10 c0       	push   $0xc010a074
c01072e2:	68 99 9c 10 c0       	push   $0xc0109c99
c01072e7:	68 47 02 00 00       	push   $0x247
c01072ec:	68 74 9c 10 c0       	push   $0xc0109c74
c01072f1:	e8 f2 90 ff ff       	call   c01003e8 <__panic>
    assert(page_ref(p) == 2);
c01072f6:	83 ec 0c             	sub    $0xc,%esp
c01072f9:	ff 75 ec             	pushl  -0x14(%ebp)
c01072fc:	e8 38 ec ff ff       	call   c0105f39 <page_ref>
c0107301:	83 c4 10             	add    $0x10,%esp
c0107304:	83 f8 02             	cmp    $0x2,%eax
c0107307:	74 19                	je     c0107322 <check_boot_pgdir+0x21b>
c0107309:	68 ab a0 10 c0       	push   $0xc010a0ab
c010730e:	68 99 9c 10 c0       	push   $0xc0109c99
c0107313:	68 48 02 00 00       	push   $0x248
c0107318:	68 74 9c 10 c0       	push   $0xc0109c74
c010731d:	e8 c6 90 ff ff       	call   c01003e8 <__panic>

    const char *str = "ucore: Hello world!!";
c0107322:	c7 45 e8 bc a0 10 c0 	movl   $0xc010a0bc,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0107329:	83 ec 08             	sub    $0x8,%esp
c010732c:	ff 75 e8             	pushl  -0x18(%ebp)
c010732f:	68 00 01 00 00       	push   $0x100
c0107334:	e8 ee 05 00 00       	call   c0107927 <strcpy>
c0107339:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010733c:	83 ec 08             	sub    $0x8,%esp
c010733f:	68 00 11 00 00       	push   $0x1100
c0107344:	68 00 01 00 00       	push   $0x100
c0107349:	e8 53 06 00 00       	call   c01079a1 <strcmp>
c010734e:	83 c4 10             	add    $0x10,%esp
c0107351:	85 c0                	test   %eax,%eax
c0107353:	74 19                	je     c010736e <check_boot_pgdir+0x267>
c0107355:	68 d4 a0 10 c0       	push   $0xc010a0d4
c010735a:	68 99 9c 10 c0       	push   $0xc0109c99
c010735f:	68 4c 02 00 00       	push   $0x24c
c0107364:	68 74 9c 10 c0       	push   $0xc0109c74
c0107369:	e8 7a 90 ff ff       	call   c01003e8 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010736e:	83 ec 0c             	sub    $0xc,%esp
c0107371:	ff 75 ec             	pushl  -0x14(%ebp)
c0107374:	e8 e6 ea ff ff       	call   c0105e5f <page2kva>
c0107379:	83 c4 10             	add    $0x10,%esp
c010737c:	05 00 01 00 00       	add    $0x100,%eax
c0107381:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0107384:	83 ec 0c             	sub    $0xc,%esp
c0107387:	68 00 01 00 00       	push   $0x100
c010738c:	e8 3e 05 00 00       	call   c01078cf <strlen>
c0107391:	83 c4 10             	add    $0x10,%esp
c0107394:	85 c0                	test   %eax,%eax
c0107396:	74 19                	je     c01073b1 <check_boot_pgdir+0x2aa>
c0107398:	68 0c a1 10 c0       	push   $0xc010a10c
c010739d:	68 99 9c 10 c0       	push   $0xc0109c99
c01073a2:	68 4f 02 00 00       	push   $0x24f
c01073a7:	68 74 9c 10 c0       	push   $0xc0109c74
c01073ac:	e8 37 90 ff ff       	call   c01003e8 <__panic>

    free_page(p);
c01073b1:	83 ec 08             	sub    $0x8,%esp
c01073b4:	6a 01                	push   $0x1
c01073b6:	ff 75 ec             	pushl  -0x14(%ebp)
c01073b9:	e8 f5 ed ff ff       	call   c01061b3 <free_pages>
c01073be:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c01073c1:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01073c6:	8b 00                	mov    (%eax),%eax
c01073c8:	83 ec 0c             	sub    $0xc,%esp
c01073cb:	50                   	push   %eax
c01073cc:	e8 4c eb ff ff       	call   c0105f1d <pde2page>
c01073d1:	83 c4 10             	add    $0x10,%esp
c01073d4:	83 ec 08             	sub    $0x8,%esp
c01073d7:	6a 01                	push   $0x1
c01073d9:	50                   	push   %eax
c01073da:	e8 d4 ed ff ff       	call   c01061b3 <free_pages>
c01073df:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c01073e2:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01073e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01073ed:	83 ec 0c             	sub    $0xc,%esp
c01073f0:	68 30 a1 10 c0       	push   $0xc010a130
c01073f5:	e8 88 8e ff ff       	call   c0100282 <cprintf>
c01073fa:	83 c4 10             	add    $0x10,%esp
}
c01073fd:	90                   	nop
c01073fe:	c9                   	leave  
c01073ff:	c3                   	ret    

c0107400 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0107400:	55                   	push   %ebp
c0107401:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0107403:	8b 45 08             	mov    0x8(%ebp),%eax
c0107406:	83 e0 04             	and    $0x4,%eax
c0107409:	85 c0                	test   %eax,%eax
c010740b:	74 07                	je     c0107414 <perm2str+0x14>
c010740d:	b8 75 00 00 00       	mov    $0x75,%eax
c0107412:	eb 05                	jmp    c0107419 <perm2str+0x19>
c0107414:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0107419:	a2 08 40 12 c0       	mov    %al,0xc0124008
    str[1] = 'r';
c010741e:	c6 05 09 40 12 c0 72 	movb   $0x72,0xc0124009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0107425:	8b 45 08             	mov    0x8(%ebp),%eax
c0107428:	83 e0 02             	and    $0x2,%eax
c010742b:	85 c0                	test   %eax,%eax
c010742d:	74 07                	je     c0107436 <perm2str+0x36>
c010742f:	b8 77 00 00 00       	mov    $0x77,%eax
c0107434:	eb 05                	jmp    c010743b <perm2str+0x3b>
c0107436:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010743b:	a2 0a 40 12 c0       	mov    %al,0xc012400a
    str[3] = '\0';
c0107440:	c6 05 0b 40 12 c0 00 	movb   $0x0,0xc012400b
    return str;
c0107447:	b8 08 40 12 c0       	mov    $0xc0124008,%eax
}
c010744c:	5d                   	pop    %ebp
c010744d:	c3                   	ret    

c010744e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010744e:	55                   	push   %ebp
c010744f:	89 e5                	mov    %esp,%ebp
c0107451:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0107454:	8b 45 10             	mov    0x10(%ebp),%eax
c0107457:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010745a:	72 0e                	jb     c010746a <get_pgtable_items+0x1c>
        return 0;
c010745c:	b8 00 00 00 00       	mov    $0x0,%eax
c0107461:	e9 9a 00 00 00       	jmp    c0107500 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0107466:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c010746a:	8b 45 10             	mov    0x10(%ebp),%eax
c010746d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107470:	73 18                	jae    c010748a <get_pgtable_items+0x3c>
c0107472:	8b 45 10             	mov    0x10(%ebp),%eax
c0107475:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010747c:	8b 45 14             	mov    0x14(%ebp),%eax
c010747f:	01 d0                	add    %edx,%eax
c0107481:	8b 00                	mov    (%eax),%eax
c0107483:	83 e0 01             	and    $0x1,%eax
c0107486:	85 c0                	test   %eax,%eax
c0107488:	74 dc                	je     c0107466 <get_pgtable_items+0x18>
    }
    if (start < right) {
c010748a:	8b 45 10             	mov    0x10(%ebp),%eax
c010748d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107490:	73 69                	jae    c01074fb <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0107492:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107496:	74 08                	je     c01074a0 <get_pgtable_items+0x52>
            *left_store = start;
c0107498:	8b 45 18             	mov    0x18(%ebp),%eax
c010749b:	8b 55 10             	mov    0x10(%ebp),%edx
c010749e:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01074a0:	8b 45 10             	mov    0x10(%ebp),%eax
c01074a3:	8d 50 01             	lea    0x1(%eax),%edx
c01074a6:	89 55 10             	mov    %edx,0x10(%ebp)
c01074a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01074b0:	8b 45 14             	mov    0x14(%ebp),%eax
c01074b3:	01 d0                	add    %edx,%eax
c01074b5:	8b 00                	mov    (%eax),%eax
c01074b7:	83 e0 07             	and    $0x7,%eax
c01074ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01074bd:	eb 04                	jmp    c01074c3 <get_pgtable_items+0x75>
            start ++;
c01074bf:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01074c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01074c6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01074c9:	73 1d                	jae    c01074e8 <get_pgtable_items+0x9a>
c01074cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01074ce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01074d5:	8b 45 14             	mov    0x14(%ebp),%eax
c01074d8:	01 d0                	add    %edx,%eax
c01074da:	8b 00                	mov    (%eax),%eax
c01074dc:	83 e0 07             	and    $0x7,%eax
c01074df:	89 c2                	mov    %eax,%edx
c01074e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01074e4:	39 c2                	cmp    %eax,%edx
c01074e6:	74 d7                	je     c01074bf <get_pgtable_items+0x71>
        }
        if (right_store != NULL) {
c01074e8:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01074ec:	74 08                	je     c01074f6 <get_pgtable_items+0xa8>
            *right_store = start;
c01074ee:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01074f1:	8b 55 10             	mov    0x10(%ebp),%edx
c01074f4:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01074f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01074f9:	eb 05                	jmp    c0107500 <get_pgtable_items+0xb2>
    }
    return 0;
c01074fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107500:	c9                   	leave  
c0107501:	c3                   	ret    

c0107502 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0107502:	55                   	push   %ebp
c0107503:	89 e5                	mov    %esp,%ebp
c0107505:	57                   	push   %edi
c0107506:	56                   	push   %esi
c0107507:	53                   	push   %ebx
c0107508:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010750b:	83 ec 0c             	sub    $0xc,%esp
c010750e:	68 50 a1 10 c0       	push   $0xc010a150
c0107513:	e8 6a 8d ff ff       	call   c0100282 <cprintf>
c0107518:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c010751b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107522:	e9 e5 00 00 00       	jmp    c010760c <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010752a:	83 ec 0c             	sub    $0xc,%esp
c010752d:	50                   	push   %eax
c010752e:	e8 cd fe ff ff       	call   c0107400 <perm2str>
c0107533:	83 c4 10             	add    $0x10,%esp
c0107536:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0107538:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010753b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010753e:	29 c2                	sub    %eax,%edx
c0107540:	89 d0                	mov    %edx,%eax
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107542:	c1 e0 16             	shl    $0x16,%eax
c0107545:	89 c3                	mov    %eax,%ebx
c0107547:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010754a:	c1 e0 16             	shl    $0x16,%eax
c010754d:	89 c1                	mov    %eax,%ecx
c010754f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107552:	c1 e0 16             	shl    $0x16,%eax
c0107555:	89 c2                	mov    %eax,%edx
c0107557:	8b 75 dc             	mov    -0x24(%ebp),%esi
c010755a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010755d:	29 c6                	sub    %eax,%esi
c010755f:	89 f0                	mov    %esi,%eax
c0107561:	83 ec 08             	sub    $0x8,%esp
c0107564:	57                   	push   %edi
c0107565:	53                   	push   %ebx
c0107566:	51                   	push   %ecx
c0107567:	52                   	push   %edx
c0107568:	50                   	push   %eax
c0107569:	68 81 a1 10 c0       	push   $0xc010a181
c010756e:	e8 0f 8d ff ff       	call   c0100282 <cprintf>
c0107573:	83 c4 20             	add    $0x20,%esp
        size_t l, r = left * NPTEENTRY;
c0107576:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107579:	c1 e0 0a             	shl    $0xa,%eax
c010757c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010757f:	eb 4f                	jmp    c01075d0 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107581:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107584:	83 ec 0c             	sub    $0xc,%esp
c0107587:	50                   	push   %eax
c0107588:	e8 73 fe ff ff       	call   c0107400 <perm2str>
c010758d:	83 c4 10             	add    $0x10,%esp
c0107590:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107592:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107595:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107598:	29 c2                	sub    %eax,%edx
c010759a:	89 d0                	mov    %edx,%eax
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010759c:	c1 e0 0c             	shl    $0xc,%eax
c010759f:	89 c3                	mov    %eax,%ebx
c01075a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01075a4:	c1 e0 0c             	shl    $0xc,%eax
c01075a7:	89 c1                	mov    %eax,%ecx
c01075a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01075ac:	c1 e0 0c             	shl    $0xc,%eax
c01075af:	89 c2                	mov    %eax,%edx
c01075b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c01075b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01075b7:	29 c6                	sub    %eax,%esi
c01075b9:	89 f0                	mov    %esi,%eax
c01075bb:	83 ec 08             	sub    $0x8,%esp
c01075be:	57                   	push   %edi
c01075bf:	53                   	push   %ebx
c01075c0:	51                   	push   %ecx
c01075c1:	52                   	push   %edx
c01075c2:	50                   	push   %eax
c01075c3:	68 a0 a1 10 c0       	push   $0xc010a1a0
c01075c8:	e8 b5 8c ff ff       	call   c0100282 <cprintf>
c01075cd:	83 c4 20             	add    $0x20,%esp
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01075d0:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01075d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01075d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075db:	89 d3                	mov    %edx,%ebx
c01075dd:	c1 e3 0a             	shl    $0xa,%ebx
c01075e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01075e3:	89 d1                	mov    %edx,%ecx
c01075e5:	c1 e1 0a             	shl    $0xa,%ecx
c01075e8:	83 ec 08             	sub    $0x8,%esp
c01075eb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01075ee:	52                   	push   %edx
c01075ef:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01075f2:	52                   	push   %edx
c01075f3:	56                   	push   %esi
c01075f4:	50                   	push   %eax
c01075f5:	53                   	push   %ebx
c01075f6:	51                   	push   %ecx
c01075f7:	e8 52 fe ff ff       	call   c010744e <get_pgtable_items>
c01075fc:	83 c4 20             	add    $0x20,%esp
c01075ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107602:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107606:	0f 85 75 ff ff ff    	jne    c0107581 <print_pgdir+0x7f>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010760c:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0107611:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107614:	83 ec 08             	sub    $0x8,%esp
c0107617:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010761a:	52                   	push   %edx
c010761b:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010761e:	52                   	push   %edx
c010761f:	51                   	push   %ecx
c0107620:	50                   	push   %eax
c0107621:	68 00 04 00 00       	push   $0x400
c0107626:	6a 00                	push   $0x0
c0107628:	e8 21 fe ff ff       	call   c010744e <get_pgtable_items>
c010762d:	83 c4 20             	add    $0x20,%esp
c0107630:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107633:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107637:	0f 85 ea fe ff ff    	jne    c0107527 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010763d:	83 ec 0c             	sub    $0xc,%esp
c0107640:	68 c4 a1 10 c0       	push   $0xc010a1c4
c0107645:	e8 38 8c ff ff       	call   c0100282 <cprintf>
c010764a:	83 c4 10             	add    $0x10,%esp
}
c010764d:	90                   	nop
c010764e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0107651:	5b                   	pop    %ebx
c0107652:	5e                   	pop    %esi
c0107653:	5f                   	pop    %edi
c0107654:	5d                   	pop    %ebp
c0107655:	c3                   	ret    

c0107656 <kmalloc>:

void *
kmalloc(size_t n) {
c0107656:	55                   	push   %ebp
c0107657:	89 e5                	mov    %esp,%ebp
c0107659:	83 ec 18             	sub    $0x18,%esp
    void * ptr=NULL;
c010765c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0107663:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c010766a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010766e:	74 09                	je     c0107679 <kmalloc+0x23>
c0107670:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0107677:	76 19                	jbe    c0107692 <kmalloc+0x3c>
c0107679:	68 f5 a1 10 c0       	push   $0xc010a1f5
c010767e:	68 99 9c 10 c0       	push   $0xc0109c99
c0107683:	68 9b 02 00 00       	push   $0x29b
c0107688:	68 74 9c 10 c0       	push   $0xc0109c74
c010768d:	e8 56 8d ff ff       	call   c01003e8 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107692:	8b 45 08             	mov    0x8(%ebp),%eax
c0107695:	05 ff 0f 00 00       	add    $0xfff,%eax
c010769a:	c1 e8 0c             	shr    $0xc,%eax
c010769d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c01076a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076a3:	83 ec 0c             	sub    $0xc,%esp
c01076a6:	50                   	push   %eax
c01076a7:	e8 9b ea ff ff       	call   c0106147 <alloc_pages>
c01076ac:	83 c4 10             	add    $0x10,%esp
c01076af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c01076b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01076b6:	75 19                	jne    c01076d1 <kmalloc+0x7b>
c01076b8:	68 0c a2 10 c0       	push   $0xc010a20c
c01076bd:	68 99 9c 10 c0       	push   $0xc0109c99
c01076c2:	68 9e 02 00 00       	push   $0x29e
c01076c7:	68 74 9c 10 c0       	push   $0xc0109c74
c01076cc:	e8 17 8d ff ff       	call   c01003e8 <__panic>
    ptr=page2kva(base);
c01076d1:	83 ec 0c             	sub    $0xc,%esp
c01076d4:	ff 75 f0             	pushl  -0x10(%ebp)
c01076d7:	e8 83 e7 ff ff       	call   c0105e5f <page2kva>
c01076dc:	83 c4 10             	add    $0x10,%esp
c01076df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c01076e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01076e5:	c9                   	leave  
c01076e6:	c3                   	ret    

c01076e7 <kfree>:

void 
kfree(void *ptr, size_t n) {
c01076e7:	55                   	push   %ebp
c01076e8:	89 e5                	mov    %esp,%ebp
c01076ea:	83 ec 18             	sub    $0x18,%esp
    assert(n > 0 && n < 1024*0124);
c01076ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01076f1:	74 09                	je     c01076fc <kfree+0x15>
c01076f3:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c01076fa:	76 19                	jbe    c0107715 <kfree+0x2e>
c01076fc:	68 f5 a1 10 c0       	push   $0xc010a1f5
c0107701:	68 99 9c 10 c0       	push   $0xc0109c99
c0107706:	68 a5 02 00 00       	push   $0x2a5
c010770b:	68 74 9c 10 c0       	push   $0xc0109c74
c0107710:	e8 d3 8c ff ff       	call   c01003e8 <__panic>
    assert(ptr != NULL);
c0107715:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107719:	75 19                	jne    c0107734 <kfree+0x4d>
c010771b:	68 19 a2 10 c0       	push   $0xc010a219
c0107720:	68 99 9c 10 c0       	push   $0xc0109c99
c0107725:	68 a6 02 00 00       	push   $0x2a6
c010772a:	68 74 9c 10 c0       	push   $0xc0109c74
c010772f:	e8 b4 8c ff ff       	call   c01003e8 <__panic>
    struct Page *base=NULL;
c0107734:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c010773b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010773e:	05 ff 0f 00 00       	add    $0xfff,%eax
c0107743:	c1 e8 0c             	shr    $0xc,%eax
c0107746:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0107749:	83 ec 0c             	sub    $0xc,%esp
c010774c:	ff 75 08             	pushl  0x8(%ebp)
c010774f:	e8 50 e7 ff ff       	call   c0105ea4 <kva2page>
c0107754:	83 c4 10             	add    $0x10,%esp
c0107757:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c010775a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010775d:	83 ec 08             	sub    $0x8,%esp
c0107760:	50                   	push   %eax
c0107761:	ff 75 f4             	pushl  -0xc(%ebp)
c0107764:	e8 4a ea ff ff       	call   c01061b3 <free_pages>
c0107769:	83 c4 10             	add    $0x10,%esp
}
c010776c:	90                   	nop
c010776d:	c9                   	leave  
c010776e:	c3                   	ret    

c010776f <page2ppn>:
page2ppn(struct Page *page) {
c010776f:	55                   	push   %ebp
c0107770:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107772:	8b 45 08             	mov    0x8(%ebp),%eax
c0107775:	8b 15 f8 40 12 c0    	mov    0xc01240f8,%edx
c010777b:	29 d0                	sub    %edx,%eax
c010777d:	c1 f8 05             	sar    $0x5,%eax
}
c0107780:	5d                   	pop    %ebp
c0107781:	c3                   	ret    

c0107782 <page2pa>:
page2pa(struct Page *page) {
c0107782:	55                   	push   %ebp
c0107783:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0107785:	ff 75 08             	pushl  0x8(%ebp)
c0107788:	e8 e2 ff ff ff       	call   c010776f <page2ppn>
c010778d:	83 c4 04             	add    $0x4,%esp
c0107790:	c1 e0 0c             	shl    $0xc,%eax
}
c0107793:	c9                   	leave  
c0107794:	c3                   	ret    

c0107795 <page2kva>:
page2kva(struct Page *page) {
c0107795:	55                   	push   %ebp
c0107796:	89 e5                	mov    %esp,%ebp
c0107798:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c010779b:	ff 75 08             	pushl  0x8(%ebp)
c010779e:	e8 df ff ff ff       	call   c0107782 <page2pa>
c01077a3:	83 c4 04             	add    $0x4,%esp
c01077a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077ac:	c1 e8 0c             	shr    $0xc,%eax
c01077af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01077b2:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01077b7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01077ba:	72 14                	jb     c01077d0 <page2kva+0x3b>
c01077bc:	ff 75 f4             	pushl  -0xc(%ebp)
c01077bf:	68 28 a2 10 c0       	push   $0xc010a228
c01077c4:	6a 62                	push   $0x62
c01077c6:	68 4b a2 10 c0       	push   $0xc010a24b
c01077cb:	e8 18 8c ff ff       	call   c01003e8 <__panic>
c01077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077d3:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01077d8:	c9                   	leave  
c01077d9:	c3                   	ret    

c01077da <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01077da:	55                   	push   %ebp
c01077db:	89 e5                	mov    %esp,%ebp
c01077dd:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01077e0:	83 ec 0c             	sub    $0xc,%esp
c01077e3:	6a 01                	push   $0x1
c01077e5:	e8 9f 98 ff ff       	call   c0101089 <ide_device_valid>
c01077ea:	83 c4 10             	add    $0x10,%esp
c01077ed:	85 c0                	test   %eax,%eax
c01077ef:	75 14                	jne    c0107805 <swapfs_init+0x2b>
        panic("swap fs isn't available.\n");
c01077f1:	83 ec 04             	sub    $0x4,%esp
c01077f4:	68 59 a2 10 c0       	push   $0xc010a259
c01077f9:	6a 0d                	push   $0xd
c01077fb:	68 73 a2 10 c0       	push   $0xc010a273
c0107800:	e8 e3 8b ff ff       	call   c01003e8 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107805:	83 ec 0c             	sub    $0xc,%esp
c0107808:	6a 01                	push   $0x1
c010780a:	e8 af 98 ff ff       	call   c01010be <ide_device_size>
c010780f:	83 c4 10             	add    $0x10,%esp
c0107812:	c1 e8 03             	shr    $0x3,%eax
c0107815:	a3 bc 40 12 c0       	mov    %eax,0xc01240bc
}
c010781a:	90                   	nop
c010781b:	c9                   	leave  
c010781c:	c3                   	ret    

c010781d <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010781d:	55                   	push   %ebp
c010781e:	89 e5                	mov    %esp,%ebp
c0107820:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107823:	83 ec 0c             	sub    $0xc,%esp
c0107826:	ff 75 0c             	pushl  0xc(%ebp)
c0107829:	e8 67 ff ff ff       	call   c0107795 <page2kva>
c010782e:	83 c4 10             	add    $0x10,%esp
c0107831:	89 c2                	mov    %eax,%edx
c0107833:	8b 45 08             	mov    0x8(%ebp),%eax
c0107836:	c1 e8 08             	shr    $0x8,%eax
c0107839:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010783c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107840:	74 0a                	je     c010784c <swapfs_read+0x2f>
c0107842:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c0107847:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010784a:	72 14                	jb     c0107860 <swapfs_read+0x43>
c010784c:	ff 75 08             	pushl  0x8(%ebp)
c010784f:	68 84 a2 10 c0       	push   $0xc010a284
c0107854:	6a 14                	push   $0x14
c0107856:	68 73 a2 10 c0       	push   $0xc010a273
c010785b:	e8 88 8b ff ff       	call   c01003e8 <__panic>
c0107860:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107863:	c1 e0 03             	shl    $0x3,%eax
c0107866:	6a 08                	push   $0x8
c0107868:	52                   	push   %edx
c0107869:	50                   	push   %eax
c010786a:	6a 01                	push   $0x1
c010786c:	e8 82 98 ff ff       	call   c01010f3 <ide_read_secs>
c0107871:	83 c4 10             	add    $0x10,%esp
}
c0107874:	c9                   	leave  
c0107875:	c3                   	ret    

c0107876 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0107876:	55                   	push   %ebp
c0107877:	89 e5                	mov    %esp,%ebp
c0107879:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010787c:	83 ec 0c             	sub    $0xc,%esp
c010787f:	ff 75 0c             	pushl  0xc(%ebp)
c0107882:	e8 0e ff ff ff       	call   c0107795 <page2kva>
c0107887:	83 c4 10             	add    $0x10,%esp
c010788a:	89 c2                	mov    %eax,%edx
c010788c:	8b 45 08             	mov    0x8(%ebp),%eax
c010788f:	c1 e8 08             	shr    $0x8,%eax
c0107892:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107899:	74 0a                	je     c01078a5 <swapfs_write+0x2f>
c010789b:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c01078a0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01078a3:	72 14                	jb     c01078b9 <swapfs_write+0x43>
c01078a5:	ff 75 08             	pushl  0x8(%ebp)
c01078a8:	68 84 a2 10 c0       	push   $0xc010a284
c01078ad:	6a 19                	push   $0x19
c01078af:	68 73 a2 10 c0       	push   $0xc010a273
c01078b4:	e8 2f 8b ff ff       	call   c01003e8 <__panic>
c01078b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078bc:	c1 e0 03             	shl    $0x3,%eax
c01078bf:	6a 08                	push   $0x8
c01078c1:	52                   	push   %edx
c01078c2:	50                   	push   %eax
c01078c3:	6a 01                	push   $0x1
c01078c5:	e8 48 9a ff ff       	call   c0101312 <ide_write_secs>
c01078ca:	83 c4 10             	add    $0x10,%esp
}
c01078cd:	c9                   	leave  
c01078ce:	c3                   	ret    

c01078cf <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01078cf:	55                   	push   %ebp
c01078d0:	89 e5                	mov    %esp,%ebp
c01078d2:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01078d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01078dc:	eb 04                	jmp    c01078e2 <strlen+0x13>
        cnt ++;
c01078de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c01078e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01078e5:	8d 50 01             	lea    0x1(%eax),%edx
c01078e8:	89 55 08             	mov    %edx,0x8(%ebp)
c01078eb:	0f b6 00             	movzbl (%eax),%eax
c01078ee:	84 c0                	test   %al,%al
c01078f0:	75 ec                	jne    c01078de <strlen+0xf>
    }
    return cnt;
c01078f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01078f5:	c9                   	leave  
c01078f6:	c3                   	ret    

c01078f7 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01078f7:	55                   	push   %ebp
c01078f8:	89 e5                	mov    %esp,%ebp
c01078fa:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01078fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0107904:	eb 04                	jmp    c010790a <strnlen+0x13>
        cnt ++;
c0107906:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010790a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010790d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107910:	73 10                	jae    c0107922 <strnlen+0x2b>
c0107912:	8b 45 08             	mov    0x8(%ebp),%eax
c0107915:	8d 50 01             	lea    0x1(%eax),%edx
c0107918:	89 55 08             	mov    %edx,0x8(%ebp)
c010791b:	0f b6 00             	movzbl (%eax),%eax
c010791e:	84 c0                	test   %al,%al
c0107920:	75 e4                	jne    c0107906 <strnlen+0xf>
    }
    return cnt;
c0107922:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107925:	c9                   	leave  
c0107926:	c3                   	ret    

c0107927 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0107927:	55                   	push   %ebp
c0107928:	89 e5                	mov    %esp,%ebp
c010792a:	57                   	push   %edi
c010792b:	56                   	push   %esi
c010792c:	83 ec 20             	sub    $0x20,%esp
c010792f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107932:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107935:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107938:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010793b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010793e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107941:	89 d1                	mov    %edx,%ecx
c0107943:	89 c2                	mov    %eax,%edx
c0107945:	89 ce                	mov    %ecx,%esi
c0107947:	89 d7                	mov    %edx,%edi
c0107949:	ac                   	lods   %ds:(%esi),%al
c010794a:	aa                   	stos   %al,%es:(%edi)
c010794b:	84 c0                	test   %al,%al
c010794d:	75 fa                	jne    c0107949 <strcpy+0x22>
c010794f:	89 fa                	mov    %edi,%edx
c0107951:	89 f1                	mov    %esi,%ecx
c0107953:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0107956:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107959:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010795c:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c010795f:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0107960:	83 c4 20             	add    $0x20,%esp
c0107963:	5e                   	pop    %esi
c0107964:	5f                   	pop    %edi
c0107965:	5d                   	pop    %ebp
c0107966:	c3                   	ret    

c0107967 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0107967:	55                   	push   %ebp
c0107968:	89 e5                	mov    %esp,%ebp
c010796a:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010796d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107970:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0107973:	eb 21                	jmp    c0107996 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0107975:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107978:	0f b6 10             	movzbl (%eax),%edx
c010797b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010797e:	88 10                	mov    %dl,(%eax)
c0107980:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107983:	0f b6 00             	movzbl (%eax),%eax
c0107986:	84 c0                	test   %al,%al
c0107988:	74 04                	je     c010798e <strncpy+0x27>
            src ++;
c010798a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010798e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0107992:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c0107996:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010799a:	75 d9                	jne    c0107975 <strncpy+0xe>
    }
    return dst;
c010799c:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010799f:	c9                   	leave  
c01079a0:	c3                   	ret    

c01079a1 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01079a1:	55                   	push   %ebp
c01079a2:	89 e5                	mov    %esp,%ebp
c01079a4:	57                   	push   %edi
c01079a5:	56                   	push   %esi
c01079a6:	83 ec 20             	sub    $0x20,%esp
c01079a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01079ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01079af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01079b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01079b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01079b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079bb:	89 d1                	mov    %edx,%ecx
c01079bd:	89 c2                	mov    %eax,%edx
c01079bf:	89 ce                	mov    %ecx,%esi
c01079c1:	89 d7                	mov    %edx,%edi
c01079c3:	ac                   	lods   %ds:(%esi),%al
c01079c4:	ae                   	scas   %es:(%edi),%al
c01079c5:	75 08                	jne    c01079cf <strcmp+0x2e>
c01079c7:	84 c0                	test   %al,%al
c01079c9:	75 f8                	jne    c01079c3 <strcmp+0x22>
c01079cb:	31 c0                	xor    %eax,%eax
c01079cd:	eb 04                	jmp    c01079d3 <strcmp+0x32>
c01079cf:	19 c0                	sbb    %eax,%eax
c01079d1:	0c 01                	or     $0x1,%al
c01079d3:	89 fa                	mov    %edi,%edx
c01079d5:	89 f1                	mov    %esi,%ecx
c01079d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01079da:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01079dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01079e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01079e3:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01079e4:	83 c4 20             	add    $0x20,%esp
c01079e7:	5e                   	pop    %esi
c01079e8:	5f                   	pop    %edi
c01079e9:	5d                   	pop    %ebp
c01079ea:	c3                   	ret    

c01079eb <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01079eb:	55                   	push   %ebp
c01079ec:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01079ee:	eb 0c                	jmp    c01079fc <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01079f0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01079f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01079f8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01079fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107a00:	74 1a                	je     c0107a1c <strncmp+0x31>
c0107a02:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a05:	0f b6 00             	movzbl (%eax),%eax
c0107a08:	84 c0                	test   %al,%al
c0107a0a:	74 10                	je     c0107a1c <strncmp+0x31>
c0107a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a0f:	0f b6 10             	movzbl (%eax),%edx
c0107a12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a15:	0f b6 00             	movzbl (%eax),%eax
c0107a18:	38 c2                	cmp    %al,%dl
c0107a1a:	74 d4                	je     c01079f0 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0107a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107a20:	74 18                	je     c0107a3a <strncmp+0x4f>
c0107a22:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a25:	0f b6 00             	movzbl (%eax),%eax
c0107a28:	0f b6 d0             	movzbl %al,%edx
c0107a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a2e:	0f b6 00             	movzbl (%eax),%eax
c0107a31:	0f b6 c0             	movzbl %al,%eax
c0107a34:	29 c2                	sub    %eax,%edx
c0107a36:	89 d0                	mov    %edx,%eax
c0107a38:	eb 05                	jmp    c0107a3f <strncmp+0x54>
c0107a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a3f:	5d                   	pop    %ebp
c0107a40:	c3                   	ret    

c0107a41 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0107a41:	55                   	push   %ebp
c0107a42:	89 e5                	mov    %esp,%ebp
c0107a44:	83 ec 04             	sub    $0x4,%esp
c0107a47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a4a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0107a4d:	eb 14                	jmp    c0107a63 <strchr+0x22>
        if (*s == c) {
c0107a4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a52:	0f b6 00             	movzbl (%eax),%eax
c0107a55:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0107a58:	75 05                	jne    c0107a5f <strchr+0x1e>
            return (char *)s;
c0107a5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a5d:	eb 13                	jmp    c0107a72 <strchr+0x31>
        }
        s ++;
c0107a5f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c0107a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a66:	0f b6 00             	movzbl (%eax),%eax
c0107a69:	84 c0                	test   %al,%al
c0107a6b:	75 e2                	jne    c0107a4f <strchr+0xe>
    }
    return NULL;
c0107a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a72:	c9                   	leave  
c0107a73:	c3                   	ret    

c0107a74 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0107a74:	55                   	push   %ebp
c0107a75:	89 e5                	mov    %esp,%ebp
c0107a77:	83 ec 04             	sub    $0x4,%esp
c0107a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a7d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0107a80:	eb 0f                	jmp    c0107a91 <strfind+0x1d>
        if (*s == c) {
c0107a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a85:	0f b6 00             	movzbl (%eax),%eax
c0107a88:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0107a8b:	74 10                	je     c0107a9d <strfind+0x29>
            break;
        }
        s ++;
c0107a8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c0107a91:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a94:	0f b6 00             	movzbl (%eax),%eax
c0107a97:	84 c0                	test   %al,%al
c0107a99:	75 e7                	jne    c0107a82 <strfind+0xe>
c0107a9b:	eb 01                	jmp    c0107a9e <strfind+0x2a>
            break;
c0107a9d:	90                   	nop
    }
    return (char *)s;
c0107a9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0107aa1:	c9                   	leave  
c0107aa2:	c3                   	ret    

c0107aa3 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0107aa3:	55                   	push   %ebp
c0107aa4:	89 e5                	mov    %esp,%ebp
c0107aa6:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0107aa9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0107ab0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0107ab7:	eb 04                	jmp    c0107abd <strtol+0x1a>
        s ++;
c0107ab9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0107abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ac0:	0f b6 00             	movzbl (%eax),%eax
c0107ac3:	3c 20                	cmp    $0x20,%al
c0107ac5:	74 f2                	je     c0107ab9 <strtol+0x16>
c0107ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107aca:	0f b6 00             	movzbl (%eax),%eax
c0107acd:	3c 09                	cmp    $0x9,%al
c0107acf:	74 e8                	je     c0107ab9 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0107ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ad4:	0f b6 00             	movzbl (%eax),%eax
c0107ad7:	3c 2b                	cmp    $0x2b,%al
c0107ad9:	75 06                	jne    c0107ae1 <strtol+0x3e>
        s ++;
c0107adb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107adf:	eb 15                	jmp    c0107af6 <strtol+0x53>
    }
    else if (*s == '-') {
c0107ae1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ae4:	0f b6 00             	movzbl (%eax),%eax
c0107ae7:	3c 2d                	cmp    $0x2d,%al
c0107ae9:	75 0b                	jne    c0107af6 <strtol+0x53>
        s ++, neg = 1;
c0107aeb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107aef:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0107af6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107afa:	74 06                	je     c0107b02 <strtol+0x5f>
c0107afc:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0107b00:	75 24                	jne    c0107b26 <strtol+0x83>
c0107b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b05:	0f b6 00             	movzbl (%eax),%eax
c0107b08:	3c 30                	cmp    $0x30,%al
c0107b0a:	75 1a                	jne    c0107b26 <strtol+0x83>
c0107b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b0f:	83 c0 01             	add    $0x1,%eax
c0107b12:	0f b6 00             	movzbl (%eax),%eax
c0107b15:	3c 78                	cmp    $0x78,%al
c0107b17:	75 0d                	jne    c0107b26 <strtol+0x83>
        s += 2, base = 16;
c0107b19:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0107b1d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0107b24:	eb 2a                	jmp    c0107b50 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0107b26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107b2a:	75 17                	jne    c0107b43 <strtol+0xa0>
c0107b2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b2f:	0f b6 00             	movzbl (%eax),%eax
c0107b32:	3c 30                	cmp    $0x30,%al
c0107b34:	75 0d                	jne    c0107b43 <strtol+0xa0>
        s ++, base = 8;
c0107b36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107b3a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0107b41:	eb 0d                	jmp    c0107b50 <strtol+0xad>
    }
    else if (base == 0) {
c0107b43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107b47:	75 07                	jne    c0107b50 <strtol+0xad>
        base = 10;
c0107b49:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0107b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b53:	0f b6 00             	movzbl (%eax),%eax
c0107b56:	3c 2f                	cmp    $0x2f,%al
c0107b58:	7e 1b                	jle    c0107b75 <strtol+0xd2>
c0107b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b5d:	0f b6 00             	movzbl (%eax),%eax
c0107b60:	3c 39                	cmp    $0x39,%al
c0107b62:	7f 11                	jg     c0107b75 <strtol+0xd2>
            dig = *s - '0';
c0107b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b67:	0f b6 00             	movzbl (%eax),%eax
c0107b6a:	0f be c0             	movsbl %al,%eax
c0107b6d:	83 e8 30             	sub    $0x30,%eax
c0107b70:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b73:	eb 48                	jmp    c0107bbd <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0107b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b78:	0f b6 00             	movzbl (%eax),%eax
c0107b7b:	3c 60                	cmp    $0x60,%al
c0107b7d:	7e 1b                	jle    c0107b9a <strtol+0xf7>
c0107b7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b82:	0f b6 00             	movzbl (%eax),%eax
c0107b85:	3c 7a                	cmp    $0x7a,%al
c0107b87:	7f 11                	jg     c0107b9a <strtol+0xf7>
            dig = *s - 'a' + 10;
c0107b89:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b8c:	0f b6 00             	movzbl (%eax),%eax
c0107b8f:	0f be c0             	movsbl %al,%eax
c0107b92:	83 e8 57             	sub    $0x57,%eax
c0107b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b98:	eb 23                	jmp    c0107bbd <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0107b9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b9d:	0f b6 00             	movzbl (%eax),%eax
c0107ba0:	3c 40                	cmp    $0x40,%al
c0107ba2:	7e 3c                	jle    c0107be0 <strtol+0x13d>
c0107ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ba7:	0f b6 00             	movzbl (%eax),%eax
c0107baa:	3c 5a                	cmp    $0x5a,%al
c0107bac:	7f 32                	jg     c0107be0 <strtol+0x13d>
            dig = *s - 'A' + 10;
c0107bae:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bb1:	0f b6 00             	movzbl (%eax),%eax
c0107bb4:	0f be c0             	movsbl %al,%eax
c0107bb7:	83 e8 37             	sub    $0x37,%eax
c0107bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bc0:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107bc3:	7d 1a                	jge    c0107bdf <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c0107bc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107bc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107bcc:	0f af 45 10          	imul   0x10(%ebp),%eax
c0107bd0:	89 c2                	mov    %eax,%edx
c0107bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bd5:	01 d0                	add    %edx,%eax
c0107bd7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0107bda:	e9 71 ff ff ff       	jmp    c0107b50 <strtol+0xad>
            break;
c0107bdf:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0107be0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107be4:	74 08                	je     c0107bee <strtol+0x14b>
        *endptr = (char *) s;
c0107be6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107be9:	8b 55 08             	mov    0x8(%ebp),%edx
c0107bec:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0107bee:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107bf2:	74 07                	je     c0107bfb <strtol+0x158>
c0107bf4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107bf7:	f7 d8                	neg    %eax
c0107bf9:	eb 03                	jmp    c0107bfe <strtol+0x15b>
c0107bfb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0107bfe:	c9                   	leave  
c0107bff:	c3                   	ret    

c0107c00 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0107c00:	55                   	push   %ebp
c0107c01:	89 e5                	mov    %esp,%ebp
c0107c03:	57                   	push   %edi
c0107c04:	83 ec 24             	sub    $0x24,%esp
c0107c07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c0a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0107c0d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0107c11:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c14:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0107c17:	88 45 f7             	mov    %al,-0x9(%ebp)
c0107c1a:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0107c20:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0107c23:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0107c27:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0107c2a:	89 d7                	mov    %edx,%edi
c0107c2c:	f3 aa                	rep stos %al,%es:(%edi)
c0107c2e:	89 fa                	mov    %edi,%edx
c0107c30:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0107c33:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0107c36:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107c39:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0107c3a:	83 c4 24             	add    $0x24,%esp
c0107c3d:	5f                   	pop    %edi
c0107c3e:	5d                   	pop    %ebp
c0107c3f:	c3                   	ret    

c0107c40 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0107c40:	55                   	push   %ebp
c0107c41:	89 e5                	mov    %esp,%ebp
c0107c43:	57                   	push   %edi
c0107c44:	56                   	push   %esi
c0107c45:	53                   	push   %ebx
c0107c46:	83 ec 30             	sub    $0x30,%esp
c0107c49:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c52:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107c55:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c58:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0107c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107c61:	73 42                	jae    c0107ca5 <memmove+0x65>
c0107c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107c6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c72:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0107c75:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c78:	c1 e8 02             	shr    $0x2,%eax
c0107c7b:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0107c7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107c80:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c83:	89 d7                	mov    %edx,%edi
c0107c85:	89 c6                	mov    %eax,%esi
c0107c87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0107c89:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107c8c:	83 e1 03             	and    $0x3,%ecx
c0107c8f:	74 02                	je     c0107c93 <memmove+0x53>
c0107c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107c93:	89 f0                	mov    %esi,%eax
c0107c95:	89 fa                	mov    %edi,%edx
c0107c97:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0107c9a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107c9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0107ca0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0107ca3:	eb 36                	jmp    c0107cdb <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0107ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ca8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cae:	01 c2                	add    %eax,%edx
c0107cb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cb3:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0107cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cb9:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0107cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cbf:	89 c1                	mov    %eax,%ecx
c0107cc1:	89 d8                	mov    %ebx,%eax
c0107cc3:	89 d6                	mov    %edx,%esi
c0107cc5:	89 c7                	mov    %eax,%edi
c0107cc7:	fd                   	std    
c0107cc8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107cca:	fc                   	cld    
c0107ccb:	89 f8                	mov    %edi,%eax
c0107ccd:	89 f2                	mov    %esi,%edx
c0107ccf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0107cd2:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0107cd5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0107cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0107cdb:	83 c4 30             	add    $0x30,%esp
c0107cde:	5b                   	pop    %ebx
c0107cdf:	5e                   	pop    %esi
c0107ce0:	5f                   	pop    %edi
c0107ce1:	5d                   	pop    %ebp
c0107ce2:	c3                   	ret    

c0107ce3 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0107ce3:	55                   	push   %ebp
c0107ce4:	89 e5                	mov    %esp,%ebp
c0107ce6:	57                   	push   %edi
c0107ce7:	56                   	push   %esi
c0107ce8:	83 ec 20             	sub    $0x20,%esp
c0107ceb:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107cf4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107cf7:	8b 45 10             	mov    0x10(%ebp),%eax
c0107cfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0107cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d00:	c1 e8 02             	shr    $0x2,%eax
c0107d03:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0107d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d0b:	89 d7                	mov    %edx,%edi
c0107d0d:	89 c6                	mov    %eax,%esi
c0107d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0107d11:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0107d14:	83 e1 03             	and    $0x3,%ecx
c0107d17:	74 02                	je     c0107d1b <memcpy+0x38>
c0107d19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107d1b:	89 f0                	mov    %esi,%eax
c0107d1d:	89 fa                	mov    %edi,%edx
c0107d1f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0107d22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107d25:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0107d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0107d2b:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0107d2c:	83 c4 20             	add    $0x20,%esp
c0107d2f:	5e                   	pop    %esi
c0107d30:	5f                   	pop    %edi
c0107d31:	5d                   	pop    %ebp
c0107d32:	c3                   	ret    

c0107d33 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0107d33:	55                   	push   %ebp
c0107d34:	89 e5                	mov    %esp,%ebp
c0107d36:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0107d39:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0107d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d42:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0107d45:	eb 30                	jmp    c0107d77 <memcmp+0x44>
        if (*s1 != *s2) {
c0107d47:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d4a:	0f b6 10             	movzbl (%eax),%edx
c0107d4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107d50:	0f b6 00             	movzbl (%eax),%eax
c0107d53:	38 c2                	cmp    %al,%dl
c0107d55:	74 18                	je     c0107d6f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0107d57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d5a:	0f b6 00             	movzbl (%eax),%eax
c0107d5d:	0f b6 d0             	movzbl %al,%edx
c0107d60:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107d63:	0f b6 00             	movzbl (%eax),%eax
c0107d66:	0f b6 c0             	movzbl %al,%eax
c0107d69:	29 c2                	sub    %eax,%edx
c0107d6b:	89 d0                	mov    %edx,%eax
c0107d6d:	eb 1a                	jmp    c0107d89 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0107d6f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0107d73:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c0107d77:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d7a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107d7d:	89 55 10             	mov    %edx,0x10(%ebp)
c0107d80:	85 c0                	test   %eax,%eax
c0107d82:	75 c3                	jne    c0107d47 <memcmp+0x14>
    }
    return 0;
c0107d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107d89:	c9                   	leave  
c0107d8a:	c3                   	ret    

c0107d8b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0107d8b:	55                   	push   %ebp
c0107d8c:	89 e5                	mov    %esp,%ebp
c0107d8e:	83 ec 38             	sub    $0x38,%esp
c0107d91:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d94:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107d97:	8b 45 14             	mov    0x14(%ebp),%eax
c0107d9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0107d9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107da0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107da3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107da6:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0107da9:	8b 45 18             	mov    0x18(%ebp),%eax
c0107dac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107daf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107db2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107db5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107db8:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0107dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107dc1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107dc5:	74 1c                	je     c0107de3 <printnum+0x58>
c0107dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107dca:	ba 00 00 00 00       	mov    $0x0,%edx
c0107dcf:	f7 75 e4             	divl   -0x1c(%ebp)
c0107dd2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107dd8:	ba 00 00 00 00       	mov    $0x0,%edx
c0107ddd:	f7 75 e4             	divl   -0x1c(%ebp)
c0107de0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107de3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107de9:	f7 75 e4             	divl   -0x1c(%ebp)
c0107dec:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107def:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107df5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107df8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107dfb:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0107dfe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e01:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0107e04:	8b 45 18             	mov    0x18(%ebp),%eax
c0107e07:	ba 00 00 00 00       	mov    $0x0,%edx
c0107e0c:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0107e0f:	72 41                	jb     c0107e52 <printnum+0xc7>
c0107e11:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0107e14:	77 05                	ja     c0107e1b <printnum+0x90>
c0107e16:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0107e19:	72 37                	jb     c0107e52 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0107e1b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0107e1e:	83 e8 01             	sub    $0x1,%eax
c0107e21:	83 ec 04             	sub    $0x4,%esp
c0107e24:	ff 75 20             	pushl  0x20(%ebp)
c0107e27:	50                   	push   %eax
c0107e28:	ff 75 18             	pushl  0x18(%ebp)
c0107e2b:	ff 75 ec             	pushl  -0x14(%ebp)
c0107e2e:	ff 75 e8             	pushl  -0x18(%ebp)
c0107e31:	ff 75 0c             	pushl  0xc(%ebp)
c0107e34:	ff 75 08             	pushl  0x8(%ebp)
c0107e37:	e8 4f ff ff ff       	call   c0107d8b <printnum>
c0107e3c:	83 c4 20             	add    $0x20,%esp
c0107e3f:	eb 1b                	jmp    c0107e5c <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0107e41:	83 ec 08             	sub    $0x8,%esp
c0107e44:	ff 75 0c             	pushl  0xc(%ebp)
c0107e47:	ff 75 20             	pushl  0x20(%ebp)
c0107e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e4d:	ff d0                	call   *%eax
c0107e4f:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
c0107e52:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0107e56:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0107e5a:	7f e5                	jg     c0107e41 <printnum+0xb6>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0107e5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e5f:	05 24 a3 10 c0       	add    $0xc010a324,%eax
c0107e64:	0f b6 00             	movzbl (%eax),%eax
c0107e67:	0f be c0             	movsbl %al,%eax
c0107e6a:	83 ec 08             	sub    $0x8,%esp
c0107e6d:	ff 75 0c             	pushl  0xc(%ebp)
c0107e70:	50                   	push   %eax
c0107e71:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e74:	ff d0                	call   *%eax
c0107e76:	83 c4 10             	add    $0x10,%esp
}
c0107e79:	90                   	nop
c0107e7a:	c9                   	leave  
c0107e7b:	c3                   	ret    

c0107e7c <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0107e7c:	55                   	push   %ebp
c0107e7d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0107e7f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0107e83:	7e 14                	jle    c0107e99 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0107e85:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e88:	8b 00                	mov    (%eax),%eax
c0107e8a:	8d 48 08             	lea    0x8(%eax),%ecx
c0107e8d:	8b 55 08             	mov    0x8(%ebp),%edx
c0107e90:	89 0a                	mov    %ecx,(%edx)
c0107e92:	8b 50 04             	mov    0x4(%eax),%edx
c0107e95:	8b 00                	mov    (%eax),%eax
c0107e97:	eb 30                	jmp    c0107ec9 <getuint+0x4d>
    }
    else if (lflag) {
c0107e99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107e9d:	74 16                	je     c0107eb5 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0107e9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ea2:	8b 00                	mov    (%eax),%eax
c0107ea4:	8d 48 04             	lea    0x4(%eax),%ecx
c0107ea7:	8b 55 08             	mov    0x8(%ebp),%edx
c0107eaa:	89 0a                	mov    %ecx,(%edx)
c0107eac:	8b 00                	mov    (%eax),%eax
c0107eae:	ba 00 00 00 00       	mov    $0x0,%edx
c0107eb3:	eb 14                	jmp    c0107ec9 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0107eb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eb8:	8b 00                	mov    (%eax),%eax
c0107eba:	8d 48 04             	lea    0x4(%eax),%ecx
c0107ebd:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ec0:	89 0a                	mov    %ecx,(%edx)
c0107ec2:	8b 00                	mov    (%eax),%eax
c0107ec4:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0107ec9:	5d                   	pop    %ebp
c0107eca:	c3                   	ret    

c0107ecb <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0107ecb:	55                   	push   %ebp
c0107ecc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0107ece:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0107ed2:	7e 14                	jle    c0107ee8 <getint+0x1d>
        return va_arg(*ap, long long);
c0107ed4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ed7:	8b 00                	mov    (%eax),%eax
c0107ed9:	8d 48 08             	lea    0x8(%eax),%ecx
c0107edc:	8b 55 08             	mov    0x8(%ebp),%edx
c0107edf:	89 0a                	mov    %ecx,(%edx)
c0107ee1:	8b 50 04             	mov    0x4(%eax),%edx
c0107ee4:	8b 00                	mov    (%eax),%eax
c0107ee6:	eb 28                	jmp    c0107f10 <getint+0x45>
    }
    else if (lflag) {
c0107ee8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107eec:	74 12                	je     c0107f00 <getint+0x35>
        return va_arg(*ap, long);
c0107eee:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ef1:	8b 00                	mov    (%eax),%eax
c0107ef3:	8d 48 04             	lea    0x4(%eax),%ecx
c0107ef6:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ef9:	89 0a                	mov    %ecx,(%edx)
c0107efb:	8b 00                	mov    (%eax),%eax
c0107efd:	99                   	cltd   
c0107efe:	eb 10                	jmp    c0107f10 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0107f00:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f03:	8b 00                	mov    (%eax),%eax
c0107f05:	8d 48 04             	lea    0x4(%eax),%ecx
c0107f08:	8b 55 08             	mov    0x8(%ebp),%edx
c0107f0b:	89 0a                	mov    %ecx,(%edx)
c0107f0d:	8b 00                	mov    (%eax),%eax
c0107f0f:	99                   	cltd   
    }
}
c0107f10:	5d                   	pop    %ebp
c0107f11:	c3                   	ret    

c0107f12 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0107f12:	55                   	push   %ebp
c0107f13:	89 e5                	mov    %esp,%ebp
c0107f15:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c0107f18:	8d 45 14             	lea    0x14(%ebp),%eax
c0107f1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f21:	50                   	push   %eax
c0107f22:	ff 75 10             	pushl  0x10(%ebp)
c0107f25:	ff 75 0c             	pushl  0xc(%ebp)
c0107f28:	ff 75 08             	pushl  0x8(%ebp)
c0107f2b:	e8 06 00 00 00       	call   c0107f36 <vprintfmt>
c0107f30:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0107f33:	90                   	nop
c0107f34:	c9                   	leave  
c0107f35:	c3                   	ret    

c0107f36 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0107f36:	55                   	push   %ebp
c0107f37:	89 e5                	mov    %esp,%ebp
c0107f39:	56                   	push   %esi
c0107f3a:	53                   	push   %ebx
c0107f3b:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0107f3e:	eb 17                	jmp    c0107f57 <vprintfmt+0x21>
            if (ch == '\0') {
c0107f40:	85 db                	test   %ebx,%ebx
c0107f42:	0f 84 8e 03 00 00    	je     c01082d6 <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c0107f48:	83 ec 08             	sub    $0x8,%esp
c0107f4b:	ff 75 0c             	pushl  0xc(%ebp)
c0107f4e:	53                   	push   %ebx
c0107f4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f52:	ff d0                	call   *%eax
c0107f54:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0107f57:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f5a:	8d 50 01             	lea    0x1(%eax),%edx
c0107f5d:	89 55 10             	mov    %edx,0x10(%ebp)
c0107f60:	0f b6 00             	movzbl (%eax),%eax
c0107f63:	0f b6 d8             	movzbl %al,%ebx
c0107f66:	83 fb 25             	cmp    $0x25,%ebx
c0107f69:	75 d5                	jne    c0107f40 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0107f6b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0107f6f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0107f76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f79:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0107f7c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107f83:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107f86:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0107f89:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f8c:	8d 50 01             	lea    0x1(%eax),%edx
c0107f8f:	89 55 10             	mov    %edx,0x10(%ebp)
c0107f92:	0f b6 00             	movzbl (%eax),%eax
c0107f95:	0f b6 d8             	movzbl %al,%ebx
c0107f98:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0107f9b:	83 f8 55             	cmp    $0x55,%eax
c0107f9e:	0f 87 05 03 00 00    	ja     c01082a9 <vprintfmt+0x373>
c0107fa4:	8b 04 85 48 a3 10 c0 	mov    -0x3fef5cb8(,%eax,4),%eax
c0107fab:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0107fad:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0107fb1:	eb d6                	jmp    c0107f89 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0107fb3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0107fb7:	eb d0                	jmp    c0107f89 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0107fb9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0107fc0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107fc3:	89 d0                	mov    %edx,%eax
c0107fc5:	c1 e0 02             	shl    $0x2,%eax
c0107fc8:	01 d0                	add    %edx,%eax
c0107fca:	01 c0                	add    %eax,%eax
c0107fcc:	01 d8                	add    %ebx,%eax
c0107fce:	83 e8 30             	sub    $0x30,%eax
c0107fd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0107fd4:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fd7:	0f b6 00             	movzbl (%eax),%eax
c0107fda:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0107fdd:	83 fb 2f             	cmp    $0x2f,%ebx
c0107fe0:	7e 39                	jle    c010801b <vprintfmt+0xe5>
c0107fe2:	83 fb 39             	cmp    $0x39,%ebx
c0107fe5:	7f 34                	jg     c010801b <vprintfmt+0xe5>
            for (precision = 0; ; ++ fmt) {
c0107fe7:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0107feb:	eb d3                	jmp    c0107fc0 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0107fed:	8b 45 14             	mov    0x14(%ebp),%eax
c0107ff0:	8d 50 04             	lea    0x4(%eax),%edx
c0107ff3:	89 55 14             	mov    %edx,0x14(%ebp)
c0107ff6:	8b 00                	mov    (%eax),%eax
c0107ff8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0107ffb:	eb 1f                	jmp    c010801c <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c0107ffd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108001:	79 86                	jns    c0107f89 <vprintfmt+0x53>
                width = 0;
c0108003:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010800a:	e9 7a ff ff ff       	jmp    c0107f89 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010800f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108016:	e9 6e ff ff ff       	jmp    c0107f89 <vprintfmt+0x53>
            goto process_precision;
c010801b:	90                   	nop

        process_precision:
            if (width < 0)
c010801c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108020:	0f 89 63 ff ff ff    	jns    c0107f89 <vprintfmt+0x53>
                width = precision, precision = -1;
c0108026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108029:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010802c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108033:	e9 51 ff ff ff       	jmp    c0107f89 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108038:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010803c:	e9 48 ff ff ff       	jmp    c0107f89 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108041:	8b 45 14             	mov    0x14(%ebp),%eax
c0108044:	8d 50 04             	lea    0x4(%eax),%edx
c0108047:	89 55 14             	mov    %edx,0x14(%ebp)
c010804a:	8b 00                	mov    (%eax),%eax
c010804c:	83 ec 08             	sub    $0x8,%esp
c010804f:	ff 75 0c             	pushl  0xc(%ebp)
c0108052:	50                   	push   %eax
c0108053:	8b 45 08             	mov    0x8(%ebp),%eax
c0108056:	ff d0                	call   *%eax
c0108058:	83 c4 10             	add    $0x10,%esp
            break;
c010805b:	e9 71 02 00 00       	jmp    c01082d1 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108060:	8b 45 14             	mov    0x14(%ebp),%eax
c0108063:	8d 50 04             	lea    0x4(%eax),%edx
c0108066:	89 55 14             	mov    %edx,0x14(%ebp)
c0108069:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010806b:	85 db                	test   %ebx,%ebx
c010806d:	79 02                	jns    c0108071 <vprintfmt+0x13b>
                err = -err;
c010806f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108071:	83 fb 06             	cmp    $0x6,%ebx
c0108074:	7f 0b                	jg     c0108081 <vprintfmt+0x14b>
c0108076:	8b 34 9d 08 a3 10 c0 	mov    -0x3fef5cf8(,%ebx,4),%esi
c010807d:	85 f6                	test   %esi,%esi
c010807f:	75 19                	jne    c010809a <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c0108081:	53                   	push   %ebx
c0108082:	68 35 a3 10 c0       	push   $0xc010a335
c0108087:	ff 75 0c             	pushl  0xc(%ebp)
c010808a:	ff 75 08             	pushl  0x8(%ebp)
c010808d:	e8 80 fe ff ff       	call   c0107f12 <printfmt>
c0108092:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108095:	e9 37 02 00 00       	jmp    c01082d1 <vprintfmt+0x39b>
                printfmt(putch, putdat, "%s", p);
c010809a:	56                   	push   %esi
c010809b:	68 3e a3 10 c0       	push   $0xc010a33e
c01080a0:	ff 75 0c             	pushl  0xc(%ebp)
c01080a3:	ff 75 08             	pushl  0x8(%ebp)
c01080a6:	e8 67 fe ff ff       	call   c0107f12 <printfmt>
c01080ab:	83 c4 10             	add    $0x10,%esp
            break;
c01080ae:	e9 1e 02 00 00       	jmp    c01082d1 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01080b3:	8b 45 14             	mov    0x14(%ebp),%eax
c01080b6:	8d 50 04             	lea    0x4(%eax),%edx
c01080b9:	89 55 14             	mov    %edx,0x14(%ebp)
c01080bc:	8b 30                	mov    (%eax),%esi
c01080be:	85 f6                	test   %esi,%esi
c01080c0:	75 05                	jne    c01080c7 <vprintfmt+0x191>
                p = "(null)";
c01080c2:	be 41 a3 10 c0       	mov    $0xc010a341,%esi
            }
            if (width > 0 && padc != '-') {
c01080c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01080cb:	7e 76                	jle    c0108143 <vprintfmt+0x20d>
c01080cd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01080d1:	74 70                	je     c0108143 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01080d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080d6:	83 ec 08             	sub    $0x8,%esp
c01080d9:	50                   	push   %eax
c01080da:	56                   	push   %esi
c01080db:	e8 17 f8 ff ff       	call   c01078f7 <strnlen>
c01080e0:	83 c4 10             	add    $0x10,%esp
c01080e3:	89 c2                	mov    %eax,%edx
c01080e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080e8:	29 d0                	sub    %edx,%eax
c01080ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01080ed:	eb 17                	jmp    c0108106 <vprintfmt+0x1d0>
                    putch(padc, putdat);
c01080ef:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01080f3:	83 ec 08             	sub    $0x8,%esp
c01080f6:	ff 75 0c             	pushl  0xc(%ebp)
c01080f9:	50                   	push   %eax
c01080fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01080fd:	ff d0                	call   *%eax
c01080ff:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108102:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108106:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010810a:	7f e3                	jg     c01080ef <vprintfmt+0x1b9>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010810c:	eb 35                	jmp    c0108143 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c010810e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108112:	74 1c                	je     c0108130 <vprintfmt+0x1fa>
c0108114:	83 fb 1f             	cmp    $0x1f,%ebx
c0108117:	7e 05                	jle    c010811e <vprintfmt+0x1e8>
c0108119:	83 fb 7e             	cmp    $0x7e,%ebx
c010811c:	7e 12                	jle    c0108130 <vprintfmt+0x1fa>
                    putch('?', putdat);
c010811e:	83 ec 08             	sub    $0x8,%esp
c0108121:	ff 75 0c             	pushl  0xc(%ebp)
c0108124:	6a 3f                	push   $0x3f
c0108126:	8b 45 08             	mov    0x8(%ebp),%eax
c0108129:	ff d0                	call   *%eax
c010812b:	83 c4 10             	add    $0x10,%esp
c010812e:	eb 0f                	jmp    c010813f <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c0108130:	83 ec 08             	sub    $0x8,%esp
c0108133:	ff 75 0c             	pushl  0xc(%ebp)
c0108136:	53                   	push   %ebx
c0108137:	8b 45 08             	mov    0x8(%ebp),%eax
c010813a:	ff d0                	call   *%eax
c010813c:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010813f:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108143:	89 f0                	mov    %esi,%eax
c0108145:	8d 70 01             	lea    0x1(%eax),%esi
c0108148:	0f b6 00             	movzbl (%eax),%eax
c010814b:	0f be d8             	movsbl %al,%ebx
c010814e:	85 db                	test   %ebx,%ebx
c0108150:	74 26                	je     c0108178 <vprintfmt+0x242>
c0108152:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108156:	78 b6                	js     c010810e <vprintfmt+0x1d8>
c0108158:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010815c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108160:	79 ac                	jns    c010810e <vprintfmt+0x1d8>
                }
            }
            for (; width > 0; width --) {
c0108162:	eb 14                	jmp    c0108178 <vprintfmt+0x242>
                putch(' ', putdat);
c0108164:	83 ec 08             	sub    $0x8,%esp
c0108167:	ff 75 0c             	pushl  0xc(%ebp)
c010816a:	6a 20                	push   $0x20
c010816c:	8b 45 08             	mov    0x8(%ebp),%eax
c010816f:	ff d0                	call   *%eax
c0108171:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
c0108174:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108178:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010817c:	7f e6                	jg     c0108164 <vprintfmt+0x22e>
            }
            break;
c010817e:	e9 4e 01 00 00       	jmp    c01082d1 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108183:	83 ec 08             	sub    $0x8,%esp
c0108186:	ff 75 e0             	pushl  -0x20(%ebp)
c0108189:	8d 45 14             	lea    0x14(%ebp),%eax
c010818c:	50                   	push   %eax
c010818d:	e8 39 fd ff ff       	call   c0107ecb <getint>
c0108192:	83 c4 10             	add    $0x10,%esp
c0108195:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108198:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010819b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010819e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01081a1:	85 d2                	test   %edx,%edx
c01081a3:	79 23                	jns    c01081c8 <vprintfmt+0x292>
                putch('-', putdat);
c01081a5:	83 ec 08             	sub    $0x8,%esp
c01081a8:	ff 75 0c             	pushl  0xc(%ebp)
c01081ab:	6a 2d                	push   $0x2d
c01081ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01081b0:	ff d0                	call   *%eax
c01081b2:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c01081b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01081bb:	f7 d8                	neg    %eax
c01081bd:	83 d2 00             	adc    $0x0,%edx
c01081c0:	f7 da                	neg    %edx
c01081c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01081c8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01081cf:	e9 9f 00 00 00       	jmp    c0108273 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01081d4:	83 ec 08             	sub    $0x8,%esp
c01081d7:	ff 75 e0             	pushl  -0x20(%ebp)
c01081da:	8d 45 14             	lea    0x14(%ebp),%eax
c01081dd:	50                   	push   %eax
c01081de:	e8 99 fc ff ff       	call   c0107e7c <getuint>
c01081e3:	83 c4 10             	add    $0x10,%esp
c01081e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01081ec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01081f3:	eb 7e                	jmp    c0108273 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01081f5:	83 ec 08             	sub    $0x8,%esp
c01081f8:	ff 75 e0             	pushl  -0x20(%ebp)
c01081fb:	8d 45 14             	lea    0x14(%ebp),%eax
c01081fe:	50                   	push   %eax
c01081ff:	e8 78 fc ff ff       	call   c0107e7c <getuint>
c0108204:	83 c4 10             	add    $0x10,%esp
c0108207:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010820a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010820d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108214:	eb 5d                	jmp    c0108273 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c0108216:	83 ec 08             	sub    $0x8,%esp
c0108219:	ff 75 0c             	pushl  0xc(%ebp)
c010821c:	6a 30                	push   $0x30
c010821e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108221:	ff d0                	call   *%eax
c0108223:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c0108226:	83 ec 08             	sub    $0x8,%esp
c0108229:	ff 75 0c             	pushl  0xc(%ebp)
c010822c:	6a 78                	push   $0x78
c010822e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108231:	ff d0                	call   *%eax
c0108233:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108236:	8b 45 14             	mov    0x14(%ebp),%eax
c0108239:	8d 50 04             	lea    0x4(%eax),%edx
c010823c:	89 55 14             	mov    %edx,0x14(%ebp)
c010823f:	8b 00                	mov    (%eax),%eax
c0108241:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108244:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010824b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108252:	eb 1f                	jmp    c0108273 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108254:	83 ec 08             	sub    $0x8,%esp
c0108257:	ff 75 e0             	pushl  -0x20(%ebp)
c010825a:	8d 45 14             	lea    0x14(%ebp),%eax
c010825d:	50                   	push   %eax
c010825e:	e8 19 fc ff ff       	call   c0107e7c <getuint>
c0108263:	83 c4 10             	add    $0x10,%esp
c0108266:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108269:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010826c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108273:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108277:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010827a:	83 ec 04             	sub    $0x4,%esp
c010827d:	52                   	push   %edx
c010827e:	ff 75 e8             	pushl  -0x18(%ebp)
c0108281:	50                   	push   %eax
c0108282:	ff 75 f4             	pushl  -0xc(%ebp)
c0108285:	ff 75 f0             	pushl  -0x10(%ebp)
c0108288:	ff 75 0c             	pushl  0xc(%ebp)
c010828b:	ff 75 08             	pushl  0x8(%ebp)
c010828e:	e8 f8 fa ff ff       	call   c0107d8b <printnum>
c0108293:	83 c4 20             	add    $0x20,%esp
            break;
c0108296:	eb 39                	jmp    c01082d1 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108298:	83 ec 08             	sub    $0x8,%esp
c010829b:	ff 75 0c             	pushl  0xc(%ebp)
c010829e:	53                   	push   %ebx
c010829f:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a2:	ff d0                	call   *%eax
c01082a4:	83 c4 10             	add    $0x10,%esp
            break;
c01082a7:	eb 28                	jmp    c01082d1 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01082a9:	83 ec 08             	sub    $0x8,%esp
c01082ac:	ff 75 0c             	pushl  0xc(%ebp)
c01082af:	6a 25                	push   $0x25
c01082b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b4:	ff d0                	call   *%eax
c01082b6:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c01082b9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01082bd:	eb 04                	jmp    c01082c3 <vprintfmt+0x38d>
c01082bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01082c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01082c6:	83 e8 01             	sub    $0x1,%eax
c01082c9:	0f b6 00             	movzbl (%eax),%eax
c01082cc:	3c 25                	cmp    $0x25,%al
c01082ce:	75 ef                	jne    c01082bf <vprintfmt+0x389>
                /* do nothing */;
            break;
c01082d0:	90                   	nop
    while (1) {
c01082d1:	e9 68 fc ff ff       	jmp    c0107f3e <vprintfmt+0x8>
                return;
c01082d6:	90                   	nop
        }
    }
}
c01082d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01082da:	5b                   	pop    %ebx
c01082db:	5e                   	pop    %esi
c01082dc:	5d                   	pop    %ebp
c01082dd:	c3                   	ret    

c01082de <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01082de:	55                   	push   %ebp
c01082df:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01082e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082e4:	8b 40 08             	mov    0x8(%eax),%eax
c01082e7:	8d 50 01             	lea    0x1(%eax),%edx
c01082ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082ed:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01082f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082f3:	8b 10                	mov    (%eax),%edx
c01082f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082f8:	8b 40 04             	mov    0x4(%eax),%eax
c01082fb:	39 c2                	cmp    %eax,%edx
c01082fd:	73 12                	jae    c0108311 <sprintputch+0x33>
        *b->buf ++ = ch;
c01082ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108302:	8b 00                	mov    (%eax),%eax
c0108304:	8d 48 01             	lea    0x1(%eax),%ecx
c0108307:	8b 55 0c             	mov    0xc(%ebp),%edx
c010830a:	89 0a                	mov    %ecx,(%edx)
c010830c:	8b 55 08             	mov    0x8(%ebp),%edx
c010830f:	88 10                	mov    %dl,(%eax)
    }
}
c0108311:	90                   	nop
c0108312:	5d                   	pop    %ebp
c0108313:	c3                   	ret    

c0108314 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108314:	55                   	push   %ebp
c0108315:	89 e5                	mov    %esp,%ebp
c0108317:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010831a:	8d 45 14             	lea    0x14(%ebp),%eax
c010831d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108320:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108323:	50                   	push   %eax
c0108324:	ff 75 10             	pushl  0x10(%ebp)
c0108327:	ff 75 0c             	pushl  0xc(%ebp)
c010832a:	ff 75 08             	pushl  0x8(%ebp)
c010832d:	e8 0b 00 00 00       	call   c010833d <vsnprintf>
c0108332:	83 c4 10             	add    $0x10,%esp
c0108335:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108338:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010833b:	c9                   	leave  
c010833c:	c3                   	ret    

c010833d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010833d:	55                   	push   %ebp
c010833e:	89 e5                	mov    %esp,%ebp
c0108340:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108343:	8b 45 08             	mov    0x8(%ebp),%eax
c0108346:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108349:	8b 45 0c             	mov    0xc(%ebp),%eax
c010834c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010834f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108352:	01 d0                	add    %edx,%eax
c0108354:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108357:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010835e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108362:	74 0a                	je     c010836e <vsnprintf+0x31>
c0108364:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108367:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010836a:	39 c2                	cmp    %eax,%edx
c010836c:	76 07                	jbe    c0108375 <vsnprintf+0x38>
        return -E_INVAL;
c010836e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108373:	eb 20                	jmp    c0108395 <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0108375:	ff 75 14             	pushl  0x14(%ebp)
c0108378:	ff 75 10             	pushl  0x10(%ebp)
c010837b:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010837e:	50                   	push   %eax
c010837f:	68 de 82 10 c0       	push   $0xc01082de
c0108384:	e8 ad fb ff ff       	call   c0107f36 <vprintfmt>
c0108389:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c010838c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010838f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108392:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108395:	c9                   	leave  
c0108396:	c3                   	ret    

c0108397 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108397:	55                   	push   %ebp
c0108398:	89 e5                	mov    %esp,%ebp
c010839a:	57                   	push   %edi
c010839b:	56                   	push   %esi
c010839c:	53                   	push   %ebx
c010839d:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01083a0:	a1 58 0a 12 c0       	mov    0xc0120a58,%eax
c01083a5:	8b 15 5c 0a 12 c0    	mov    0xc0120a5c,%edx
c01083ab:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c01083b1:	6b f0 05             	imul   $0x5,%eax,%esi
c01083b4:	01 fe                	add    %edi,%esi
c01083b6:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c01083bb:	f7 e7                	mul    %edi
c01083bd:	01 d6                	add    %edx,%esi
c01083bf:	89 f2                	mov    %esi,%edx
c01083c1:	83 c0 0b             	add    $0xb,%eax
c01083c4:	83 d2 00             	adc    $0x0,%edx
c01083c7:	89 c7                	mov    %eax,%edi
c01083c9:	83 e7 ff             	and    $0xffffffff,%edi
c01083cc:	89 f9                	mov    %edi,%ecx
c01083ce:	0f b7 da             	movzwl %dx,%ebx
c01083d1:	89 0d 58 0a 12 c0    	mov    %ecx,0xc0120a58
c01083d7:	89 1d 5c 0a 12 c0    	mov    %ebx,0xc0120a5c
    unsigned long long result = (next >> 12);
c01083dd:	8b 1d 58 0a 12 c0    	mov    0xc0120a58,%ebx
c01083e3:	8b 35 5c 0a 12 c0    	mov    0xc0120a5c,%esi
c01083e9:	89 d8                	mov    %ebx,%eax
c01083eb:	89 f2                	mov    %esi,%edx
c01083ed:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01083f1:	c1 ea 0c             	shr    $0xc,%edx
c01083f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01083f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c01083fa:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108401:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108404:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108407:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010840a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010840d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108410:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108413:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108417:	74 1c                	je     c0108435 <rand+0x9e>
c0108419:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010841c:	ba 00 00 00 00       	mov    $0x0,%edx
c0108421:	f7 75 dc             	divl   -0x24(%ebp)
c0108424:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108427:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010842a:	ba 00 00 00 00       	mov    $0x0,%edx
c010842f:	f7 75 dc             	divl   -0x24(%ebp)
c0108432:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108435:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108438:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010843b:	f7 75 dc             	divl   -0x24(%ebp)
c010843e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108441:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108444:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108447:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010844a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010844d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108450:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108453:	83 c4 24             	add    $0x24,%esp
c0108456:	5b                   	pop    %ebx
c0108457:	5e                   	pop    %esi
c0108458:	5f                   	pop    %edi
c0108459:	5d                   	pop    %ebp
c010845a:	c3                   	ret    

c010845b <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010845b:	55                   	push   %ebp
c010845c:	89 e5                	mov    %esp,%ebp
    next = seed;
c010845e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108461:	ba 00 00 00 00       	mov    $0x0,%edx
c0108466:	a3 58 0a 12 c0       	mov    %eax,0xc0120a58
c010846b:	89 15 5c 0a 12 c0    	mov    %edx,0xc0120a5c
}
c0108471:	90                   	nop
c0108472:	5d                   	pop    %ebp
c0108473:	c3                   	ret    
