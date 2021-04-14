
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 90 12 00 	lgdtl  0x129018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 90 12 c0       	mov    $0xc0129000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));

static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	53                   	push   %ebx
c010002e:	83 ec 14             	sub    $0x14,%esp
c0100031:	e8 8b 02 00 00       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100036:	81 c3 4a 99 02 00    	add    $0x2994a,%ebx
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	c7 c0 a4 cc 12 c0    	mov    $0xc012cca4,%eax
c0100042:	89 c2                	mov    %eax,%edx
c0100044:	c7 c0 80 99 12 c0    	mov    $0xc0129980,%eax
c010004a:	29 c2                	sub    %eax,%edx
c010004c:	89 d0                	mov    %edx,%eax
c010004e:	83 ec 04             	sub    $0x4,%esp
c0100051:	50                   	push   %eax
c0100052:	6a 00                	push   $0x0
c0100054:	c7 c0 80 99 12 c0    	mov    $0xc0129980,%eax
c010005a:	50                   	push   %eax
c010005b:	e8 4c b3 00 00       	call   c010b3ac <memset>
c0100060:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c0100063:	e8 fe 35 00 00       	call   c0103666 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100068:	8d 83 84 23 fe ff    	lea    -0x1dc7c(%ebx),%eax
c010006e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100071:	83 ec 08             	sub    $0x8,%esp
c0100074:	ff 75 f4             	pushl  -0xc(%ebp)
c0100077:	8d 83 a0 23 fe ff    	lea    -0x1dc60(%ebx),%eax
c010007d:	50                   	push   %eax
c010007e:	e8 b1 02 00 00       	call   c0100334 <cprintf>
c0100083:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c0100086:	e8 ff 1e 00 00       	call   c0101f8a <print_kerninfo>

    grade_backtrace();
c010008b:	e8 af 00 00 00       	call   c010013f <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100090:	e8 24 8e 00 00       	call   c0108eb9 <pmm_init>

    pic_init();                 // init interrupt controller
c0100095:	e8 89 37 00 00       	call   c0103823 <pic_init>
    idt_init();                 // init interrupt descriptor table
c010009a:	e8 1b 39 00 00       	call   c01039ba <idt_init>

    vmm_init();                 // init virtual memory management
c010009f:	e8 fe 4e 00 00       	call   c0104fa2 <vmm_init>
    proc_init();                // init process table
c01000a4:	e8 c8 ab 00 00       	call   c010ac71 <proc_init>
    
    ide_init();                 // init ide devices
c01000a9:	e8 7d 24 00 00       	call   c010252b <ide_init>
    swap_init();                // init swap
c01000ae:	e8 5a 66 00 00       	call   c010670d <swap_init>

    clock_init();               // init clock interrupt
c01000b3:	e8 49 2c 00 00       	call   c0102d01 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b8:	e8 ae 38 00 00       	call   c010396b <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000bd:	e8 95 ad 00 00       	call   c010ae57 <cpu_idle>

c01000c2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000c2:	55                   	push   %ebp
c01000c3:	89 e5                	mov    %esp,%ebp
c01000c5:	53                   	push   %ebx
c01000c6:	83 ec 04             	sub    $0x4,%esp
c01000c9:	e8 ef 01 00 00       	call   c01002bd <__x86.get_pc_thunk.ax>
c01000ce:	05 b2 98 02 00       	add    $0x298b2,%eax
    mon_backtrace(0, NULL, NULL);
c01000d3:	83 ec 04             	sub    $0x4,%esp
c01000d6:	6a 00                	push   $0x0
c01000d8:	6a 00                	push   $0x0
c01000da:	6a 00                	push   $0x0
c01000dc:	89 c3                	mov    %eax,%ebx
c01000de:	e8 c1 23 00 00       	call   c01024a4 <mon_backtrace>
c01000e3:	83 c4 10             	add    $0x10,%esp
}
c01000e6:	90                   	nop
c01000e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000ea:	c9                   	leave  
c01000eb:	c3                   	ret    

c01000ec <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ec:	55                   	push   %ebp
c01000ed:	89 e5                	mov    %esp,%ebp
c01000ef:	53                   	push   %ebx
c01000f0:	83 ec 04             	sub    $0x4,%esp
c01000f3:	e8 c5 01 00 00       	call   c01002bd <__x86.get_pc_thunk.ax>
c01000f8:	05 88 98 02 00       	add    $0x29888,%eax
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000fd:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c0100100:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100103:	8d 5d 08             	lea    0x8(%ebp),%ebx
c0100106:	8b 45 08             	mov    0x8(%ebp),%eax
c0100109:	51                   	push   %ecx
c010010a:	52                   	push   %edx
c010010b:	53                   	push   %ebx
c010010c:	50                   	push   %eax
c010010d:	e8 b0 ff ff ff       	call   c01000c2 <grade_backtrace2>
c0100112:	83 c4 10             	add    $0x10,%esp
}
c0100115:	90                   	nop
c0100116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100119:	c9                   	leave  
c010011a:	c3                   	ret    

c010011b <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c010011b:	55                   	push   %ebp
c010011c:	89 e5                	mov    %esp,%ebp
c010011e:	83 ec 08             	sub    $0x8,%esp
c0100121:	e8 97 01 00 00       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100126:	05 5a 98 02 00       	add    $0x2985a,%eax
    grade_backtrace1(arg0, arg2);
c010012b:	83 ec 08             	sub    $0x8,%esp
c010012e:	ff 75 10             	pushl  0x10(%ebp)
c0100131:	ff 75 08             	pushl  0x8(%ebp)
c0100134:	e8 b3 ff ff ff       	call   c01000ec <grade_backtrace1>
c0100139:	83 c4 10             	add    $0x10,%esp
}
c010013c:	90                   	nop
c010013d:	c9                   	leave  
c010013e:	c3                   	ret    

c010013f <grade_backtrace>:

void
grade_backtrace(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 08             	sub    $0x8,%esp
c0100145:	e8 73 01 00 00       	call   c01002bd <__x86.get_pc_thunk.ax>
c010014a:	05 36 98 02 00       	add    $0x29836,%eax
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010014f:	8d 80 aa 66 fd ff    	lea    -0x29956(%eax),%eax
c0100155:	83 ec 04             	sub    $0x4,%esp
c0100158:	68 00 00 ff ff       	push   $0xffff0000
c010015d:	50                   	push   %eax
c010015e:	6a 00                	push   $0x0
c0100160:	e8 b6 ff ff ff       	call   c010011b <grade_backtrace0>
c0100165:	83 c4 10             	add    $0x10,%esp
}
c0100168:	90                   	nop
c0100169:	c9                   	leave  
c010016a:	c3                   	ret    

c010016b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010016b:	55                   	push   %ebp
c010016c:	89 e5                	mov    %esp,%ebp
c010016e:	53                   	push   %ebx
c010016f:	83 ec 14             	sub    $0x14,%esp
c0100172:	e8 4a 01 00 00       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100177:	81 c3 09 98 02 00    	add    $0x29809,%ebx
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010017d:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100180:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100183:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100186:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100189:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018d:	0f b7 c0             	movzwl %ax,%eax
c0100190:	83 e0 03             	and    $0x3,%eax
c0100193:	89 c2                	mov    %eax,%edx
c0100195:	8b 83 c0 01 00 00    	mov    0x1c0(%ebx),%eax
c010019b:	83 ec 04             	sub    $0x4,%esp
c010019e:	52                   	push   %edx
c010019f:	50                   	push   %eax
c01001a0:	8d 83 a5 23 fe ff    	lea    -0x1dc5b(%ebx),%eax
c01001a6:	50                   	push   %eax
c01001a7:	e8 88 01 00 00       	call   c0100334 <cprintf>
c01001ac:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c01001af:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01001b3:	0f b7 d0             	movzwl %ax,%edx
c01001b6:	8b 83 c0 01 00 00    	mov    0x1c0(%ebx),%eax
c01001bc:	83 ec 04             	sub    $0x4,%esp
c01001bf:	52                   	push   %edx
c01001c0:	50                   	push   %eax
c01001c1:	8d 83 b3 23 fe ff    	lea    -0x1dc4d(%ebx),%eax
c01001c7:	50                   	push   %eax
c01001c8:	e8 67 01 00 00       	call   c0100334 <cprintf>
c01001cd:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c01001d0:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001d4:	0f b7 d0             	movzwl %ax,%edx
c01001d7:	8b 83 c0 01 00 00    	mov    0x1c0(%ebx),%eax
c01001dd:	83 ec 04             	sub    $0x4,%esp
c01001e0:	52                   	push   %edx
c01001e1:	50                   	push   %eax
c01001e2:	8d 83 c1 23 fe ff    	lea    -0x1dc3f(%ebx),%eax
c01001e8:	50                   	push   %eax
c01001e9:	e8 46 01 00 00       	call   c0100334 <cprintf>
c01001ee:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c01001f1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001f5:	0f b7 d0             	movzwl %ax,%edx
c01001f8:	8b 83 c0 01 00 00    	mov    0x1c0(%ebx),%eax
c01001fe:	83 ec 04             	sub    $0x4,%esp
c0100201:	52                   	push   %edx
c0100202:	50                   	push   %eax
c0100203:	8d 83 cf 23 fe ff    	lea    -0x1dc31(%ebx),%eax
c0100209:	50                   	push   %eax
c010020a:	e8 25 01 00 00       	call   c0100334 <cprintf>
c010020f:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c0100212:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0100216:	0f b7 d0             	movzwl %ax,%edx
c0100219:	8b 83 c0 01 00 00    	mov    0x1c0(%ebx),%eax
c010021f:	83 ec 04             	sub    $0x4,%esp
c0100222:	52                   	push   %edx
c0100223:	50                   	push   %eax
c0100224:	8d 83 dd 23 fe ff    	lea    -0x1dc23(%ebx),%eax
c010022a:	50                   	push   %eax
c010022b:	e8 04 01 00 00       	call   c0100334 <cprintf>
c0100230:	83 c4 10             	add    $0x10,%esp
    round ++;
c0100233:	8b 83 c0 01 00 00    	mov    0x1c0(%ebx),%eax
c0100239:	83 c0 01             	add    $0x1,%eax
c010023c:	89 83 c0 01 00 00    	mov    %eax,0x1c0(%ebx)
}
c0100242:	90                   	nop
c0100243:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100246:	c9                   	leave  
c0100247:	c3                   	ret    

c0100248 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100248:	55                   	push   %ebp
c0100249:	89 e5                	mov    %esp,%ebp
c010024b:	e8 6d 00 00 00       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100250:	05 30 97 02 00       	add    $0x29730,%eax
    //LAB1 CHALLENGE 1 : TODO
}
c0100255:	90                   	nop
c0100256:	5d                   	pop    %ebp
c0100257:	c3                   	ret    

c0100258 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100258:	55                   	push   %ebp
c0100259:	89 e5                	mov    %esp,%ebp
c010025b:	e8 5d 00 00 00       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100260:	05 20 97 02 00       	add    $0x29720,%eax
    //LAB1 CHALLENGE 1 :  TODO
}
c0100265:	90                   	nop
c0100266:	5d                   	pop    %ebp
c0100267:	c3                   	ret    

c0100268 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100268:	55                   	push   %ebp
c0100269:	89 e5                	mov    %esp,%ebp
c010026b:	53                   	push   %ebx
c010026c:	83 ec 04             	sub    $0x4,%esp
c010026f:	e8 4d 00 00 00       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100274:	81 c3 0c 97 02 00    	add    $0x2970c,%ebx
    lab1_print_cur_status();
c010027a:	e8 ec fe ff ff       	call   c010016b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010027f:	83 ec 0c             	sub    $0xc,%esp
c0100282:	8d 83 ec 23 fe ff    	lea    -0x1dc14(%ebx),%eax
c0100288:	50                   	push   %eax
c0100289:	e8 a6 00 00 00       	call   c0100334 <cprintf>
c010028e:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c0100291:	e8 b2 ff ff ff       	call   c0100248 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100296:	e8 d0 fe ff ff       	call   c010016b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010029b:	83 ec 0c             	sub    $0xc,%esp
c010029e:	8d 83 0c 24 fe ff    	lea    -0x1dbf4(%ebx),%eax
c01002a4:	50                   	push   %eax
c01002a5:	e8 8a 00 00 00       	call   c0100334 <cprintf>
c01002aa:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c01002ad:	e8 a6 ff ff ff       	call   c0100258 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c01002b2:	e8 b4 fe ff ff       	call   c010016b <lab1_print_cur_status>
}
c01002b7:	90                   	nop
c01002b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01002bb:	c9                   	leave  
c01002bc:	c3                   	ret    

c01002bd <__x86.get_pc_thunk.ax>:
c01002bd:	8b 04 24             	mov    (%esp),%eax
c01002c0:	c3                   	ret    

c01002c1 <__x86.get_pc_thunk.bx>:
c01002c1:	8b 1c 24             	mov    (%esp),%ebx
c01002c4:	c3                   	ret    

c01002c5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002c5:	55                   	push   %ebp
c01002c6:	89 e5                	mov    %esp,%ebp
c01002c8:	53                   	push   %ebx
c01002c9:	83 ec 04             	sub    $0x4,%esp
c01002cc:	e8 ec ff ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01002d1:	05 af 96 02 00       	add    $0x296af,%eax
    cons_putc(c);
c01002d6:	83 ec 0c             	sub    $0xc,%esp
c01002d9:	ff 75 08             	pushl  0x8(%ebp)
c01002dc:	89 c3                	mov    %eax,%ebx
c01002de:	e8 c6 33 00 00       	call   c01036a9 <cons_putc>
c01002e3:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c01002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002e9:	8b 00                	mov    (%eax),%eax
c01002eb:	8d 50 01             	lea    0x1(%eax),%edx
c01002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002f1:	89 10                	mov    %edx,(%eax)
}
c01002f3:	90                   	nop
c01002f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01002f7:	c9                   	leave  
c01002f8:	c3                   	ret    

c01002f9 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c01002f9:	55                   	push   %ebp
c01002fa:	89 e5                	mov    %esp,%ebp
c01002fc:	53                   	push   %ebx
c01002fd:	83 ec 14             	sub    $0x14,%esp
c0100300:	e8 b8 ff ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100305:	05 7b 96 02 00       	add    $0x2967b,%eax
    int cnt = 0;
c010030a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100311:	ff 75 0c             	pushl  0xc(%ebp)
c0100314:	ff 75 08             	pushl  0x8(%ebp)
c0100317:	8d 55 f4             	lea    -0xc(%ebp),%edx
c010031a:	52                   	push   %edx
c010031b:	8d 90 45 69 fd ff    	lea    -0x296bb(%eax),%edx
c0100321:	52                   	push   %edx
c0100322:	89 c3                	mov    %eax,%ebx
c0100324:	e8 11 b4 00 00       	call   c010b73a <vprintfmt>
c0100329:	83 c4 10             	add    $0x10,%esp
    return cnt;
c010032c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010032f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100332:	c9                   	leave  
c0100333:	c3                   	ret    

c0100334 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100334:	55                   	push   %ebp
c0100335:	89 e5                	mov    %esp,%ebp
c0100337:	83 ec 18             	sub    $0x18,%esp
c010033a:	e8 7e ff ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010033f:	05 41 96 02 00       	add    $0x29641,%eax
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100344:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100347:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010034a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010034d:	83 ec 08             	sub    $0x8,%esp
c0100350:	50                   	push   %eax
c0100351:	ff 75 08             	pushl  0x8(%ebp)
c0100354:	e8 a0 ff ff ff       	call   c01002f9 <vcprintf>
c0100359:	83 c4 10             	add    $0x10,%esp
c010035c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010035f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100362:	c9                   	leave  
c0100363:	c3                   	ret    

c0100364 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100364:	55                   	push   %ebp
c0100365:	89 e5                	mov    %esp,%ebp
c0100367:	53                   	push   %ebx
c0100368:	83 ec 04             	sub    $0x4,%esp
c010036b:	e8 4d ff ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100370:	05 10 96 02 00       	add    $0x29610,%eax
    cons_putc(c);
c0100375:	83 ec 0c             	sub    $0xc,%esp
c0100378:	ff 75 08             	pushl  0x8(%ebp)
c010037b:	89 c3                	mov    %eax,%ebx
c010037d:	e8 27 33 00 00       	call   c01036a9 <cons_putc>
c0100382:	83 c4 10             	add    $0x10,%esp
}
c0100385:	90                   	nop
c0100386:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100389:	c9                   	leave  
c010038a:	c3                   	ret    

c010038b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010038b:	55                   	push   %ebp
c010038c:	89 e5                	mov    %esp,%ebp
c010038e:	83 ec 18             	sub    $0x18,%esp
c0100391:	e8 27 ff ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100396:	05 ea 95 02 00       	add    $0x295ea,%eax
    int cnt = 0;
c010039b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a2:	eb 14                	jmp    c01003b8 <cputs+0x2d>
        cputch(c, &cnt);
c01003a4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a8:	83 ec 08             	sub    $0x8,%esp
c01003ab:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003ae:	52                   	push   %edx
c01003af:	50                   	push   %eax
c01003b0:	e8 10 ff ff ff       	call   c01002c5 <cputch>
c01003b5:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
c01003b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01003bb:	8d 50 01             	lea    0x1(%eax),%edx
c01003be:	89 55 08             	mov    %edx,0x8(%ebp)
c01003c1:	0f b6 00             	movzbl (%eax),%eax
c01003c4:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c7:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003cb:	75 d7                	jne    c01003a4 <cputs+0x19>
    }
    cputch('\n', &cnt);
c01003cd:	83 ec 08             	sub    $0x8,%esp
c01003d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003d3:	50                   	push   %eax
c01003d4:	6a 0a                	push   $0xa
c01003d6:	e8 ea fe ff ff       	call   c01002c5 <cputch>
c01003db:	83 c4 10             	add    $0x10,%esp
    return cnt;
c01003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e1:	c9                   	leave  
c01003e2:	c3                   	ret    

c01003e3 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e3:	55                   	push   %ebp
c01003e4:	89 e5                	mov    %esp,%ebp
c01003e6:	53                   	push   %ebx
c01003e7:	83 ec 14             	sub    $0x14,%esp
c01003ea:	e8 d2 fe ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01003ef:	81 c3 91 95 02 00    	add    $0x29591,%ebx
    int c;
    while ((c = cons_getc()) == 0)
c01003f5:	e8 02 33 00 00       	call   c01036fc <cons_getc>
c01003fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100401:	74 f2                	je     c01003f5 <getchar+0x12>
        /* do nothing */;
    return c;
c0100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100406:	83 c4 14             	add    $0x14,%esp
c0100409:	5b                   	pop    %ebx
c010040a:	5d                   	pop    %ebp
c010040b:	c3                   	ret    

c010040c <rb_node_create>:
#include <rb_tree.h>
#include <assert.h>

/* rb_node_create - create a new rb_node */
static inline rb_node *
rb_node_create(void) {
c010040c:	55                   	push   %ebp
c010040d:	89 e5                	mov    %esp,%ebp
c010040f:	53                   	push   %ebx
c0100410:	83 ec 04             	sub    $0x4,%esp
c0100413:	e8 a5 fe ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100418:	05 68 95 02 00       	add    $0x29568,%eax
    return kmalloc(sizeof(rb_node));
c010041d:	83 ec 0c             	sub    $0xc,%esp
c0100420:	6a 10                	push   $0x10
c0100422:	89 c3                	mov    %eax,%ebx
c0100424:	e8 a4 60 00 00       	call   c01064cd <kmalloc>
c0100429:	83 c4 10             	add    $0x10,%esp
}
c010042c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010042f:	c9                   	leave  
c0100430:	c3                   	ret    

c0100431 <rb_tree_empty>:

/* rb_tree_empty - tests if tree is empty */
static inline bool
rb_tree_empty(rb_tree *tree) {
c0100431:	55                   	push   %ebp
c0100432:	89 e5                	mov    %esp,%ebp
c0100434:	83 ec 10             	sub    $0x10,%esp
c0100437:	e8 81 fe ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010043c:	05 44 95 02 00       	add    $0x29544,%eax
    rb_node *nil = tree->nil, *root = tree->root;
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	8b 40 04             	mov    0x4(%eax),%eax
c0100447:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010044a:	8b 45 08             	mov    0x8(%ebp),%eax
c010044d:	8b 40 08             	mov    0x8(%eax),%eax
c0100450:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return root->left == nil;
c0100453:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100456:	8b 40 08             	mov    0x8(%eax),%eax
c0100459:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010045c:	0f 94 c0             	sete   %al
c010045f:	0f b6 c0             	movzbl %al,%eax
}
c0100462:	c9                   	leave  
c0100463:	c3                   	ret    

c0100464 <rb_tree_create>:
 * Note that, root->left should always point to the node that is the root
 * of the tree. And nil points to a 'NULL' node which should always be
 * black and may have arbitrary children and parent node.
 * */
rb_tree *
rb_tree_create(int (*compare)(rb_node *node1, rb_node *node2)) {
c0100464:	55                   	push   %ebp
c0100465:	89 e5                	mov    %esp,%ebp
c0100467:	53                   	push   %ebx
c0100468:	83 ec 14             	sub    $0x14,%esp
c010046b:	e8 51 fe ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100470:	81 c3 10 95 02 00    	add    $0x29510,%ebx
    assert(compare != NULL);
c0100476:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010047a:	75 1c                	jne    c0100498 <rb_tree_create+0x34>
c010047c:	8d 83 2c 24 fe ff    	lea    -0x1dbd4(%ebx),%eax
c0100482:	50                   	push   %eax
c0100483:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0100489:	50                   	push   %eax
c010048a:	6a 1f                	push   $0x1f
c010048c:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0100492:	50                   	push   %eax
c0100493:	e8 7a 15 00 00       	call   c0101a12 <__panic>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
c0100498:	83 ec 0c             	sub    $0xc,%esp
c010049b:	6a 0c                	push   $0xc
c010049d:	e8 2b 60 00 00       	call   c01064cd <kmalloc>
c01004a2:	83 c4 10             	add    $0x10,%esp
c01004a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01004a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ac:	0f 84 b5 00 00 00    	je     c0100567 <rb_tree_create+0x103>
        goto bad_tree;
    }

    tree->compare = compare;
c01004b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01004b8:	89 10                	mov    %edx,(%eax)

    if ((nil = rb_node_create()) == NULL) {
c01004ba:	e8 4d ff ff ff       	call   c010040c <rb_node_create>
c01004bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01004c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01004c6:	0f 84 8a 00 00 00    	je     c0100556 <rb_tree_create+0xf2>
        goto bad_node_cleanup_tree;
    }

    nil->parent = nil->left = nil->right = nil;
c01004cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d2:	89 50 0c             	mov    %edx,0xc(%eax)
c01004d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d8:	8b 50 0c             	mov    0xc(%eax),%edx
c01004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004de:	89 50 08             	mov    %edx,0x8(%eax)
c01004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e4:	8b 50 08             	mov    0x8(%eax),%edx
c01004e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ea:	89 50 04             	mov    %edx,0x4(%eax)
    nil->red = 0;
c01004ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->nil = nil;
c01004f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004fc:	89 50 04             	mov    %edx,0x4(%eax)

    if ((root = rb_node_create()) == NULL) {
c01004ff:	e8 08 ff ff ff       	call   c010040c <rb_node_create>
c0100504:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100507:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010050b:	74 38                	je     c0100545 <rb_tree_create+0xe1>
        goto bad_node_cleanup_nil;
    }

    root->parent = root->left = root->right = nil;
c010050d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100510:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100513:	89 50 0c             	mov    %edx,0xc(%eax)
c0100516:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100519:	8b 50 0c             	mov    0xc(%eax),%edx
c010051c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010051f:	89 50 08             	mov    %edx,0x8(%eax)
c0100522:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100525:	8b 50 08             	mov    0x8(%eax),%edx
c0100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010052b:	89 50 04             	mov    %edx,0x4(%eax)
    root->red = 0;
c010052e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100531:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->root = root;
c0100537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010053a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010053d:	89 50 08             	mov    %edx,0x8(%eax)
    return tree;
c0100540:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100543:	eb 28                	jmp    c010056d <rb_tree_create+0x109>
        goto bad_node_cleanup_nil;
c0100545:	90                   	nop

bad_node_cleanup_nil:
    kfree(nil);
c0100546:	83 ec 0c             	sub    $0xc,%esp
c0100549:	ff 75 f0             	pushl  -0x10(%ebp)
c010054c:	e8 9e 5f 00 00       	call   c01064ef <kfree>
c0100551:	83 c4 10             	add    $0x10,%esp
c0100554:	eb 01                	jmp    c0100557 <rb_tree_create+0xf3>
        goto bad_node_cleanup_tree;
c0100556:	90                   	nop
bad_node_cleanup_tree:
    kfree(tree);
c0100557:	83 ec 0c             	sub    $0xc,%esp
c010055a:	ff 75 f4             	pushl  -0xc(%ebp)
c010055d:	e8 8d 5f 00 00       	call   c01064ef <kfree>
c0100562:	83 c4 10             	add    $0x10,%esp
c0100565:	eb 01                	jmp    c0100568 <rb_tree_create+0x104>
        goto bad_tree;
c0100567:	90                   	nop
bad_tree:
    return NULL;
c0100568:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010056d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100570:	c9                   	leave  
c0100571:	c3                   	ret    

c0100572 <rb_left_rotate>:
    y->_left = x;                                               \
    x->parent = y;                                              \
    assert(!(nil->red));                                        \
}

FUNC_ROTATE(rb_left_rotate, left, right);
c0100572:	55                   	push   %ebp
c0100573:	89 e5                	mov    %esp,%ebp
c0100575:	53                   	push   %ebx
c0100576:	83 ec 14             	sub    $0x14,%esp
c0100579:	e8 3f fd ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010057e:	05 02 94 02 00       	add    $0x29402,%eax
c0100583:	8b 55 08             	mov    0x8(%ebp),%edx
c0100586:	8b 52 04             	mov    0x4(%edx),%edx
c0100589:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010058c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010058f:	8b 52 0c             	mov    0xc(%edx),%edx
c0100592:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0100595:	8b 55 08             	mov    0x8(%ebp),%edx
c0100598:	8b 52 08             	mov    0x8(%edx),%edx
c010059b:	39 55 0c             	cmp    %edx,0xc(%ebp)
c010059e:	74 10                	je     c01005b0 <rb_left_rotate+0x3e>
c01005a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005a3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
c01005a6:	74 08                	je     c01005b0 <rb_left_rotate+0x3e>
c01005a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005ab:	3b 55 f4             	cmp    -0xc(%ebp),%edx
c01005ae:	75 1e                	jne    c01005ce <rb_left_rotate+0x5c>
c01005b0:	8d 90 68 24 fe ff    	lea    -0x1db98(%eax),%edx
c01005b6:	52                   	push   %edx
c01005b7:	8d 90 3c 24 fe ff    	lea    -0x1dbc4(%eax),%edx
c01005bd:	52                   	push   %edx
c01005be:	6a 64                	push   $0x64
c01005c0:	8d 90 51 24 fe ff    	lea    -0x1dbaf(%eax),%edx
c01005c6:	52                   	push   %edx
c01005c7:	89 c3                	mov    %eax,%ebx
c01005c9:	e8 44 14 00 00       	call   c0101a12 <__panic>
c01005ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005d1:	8b 4a 08             	mov    0x8(%edx),%ecx
c01005d4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005d7:	89 4a 0c             	mov    %ecx,0xc(%edx)
c01005da:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005dd:	8b 52 08             	mov    0x8(%edx),%edx
c01005e0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01005e3:	74 0c                	je     c01005f1 <rb_left_rotate+0x7f>
c01005e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005e8:	8b 52 08             	mov    0x8(%edx),%edx
c01005eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01005ee:	89 4a 04             	mov    %ecx,0x4(%edx)
c01005f1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005f4:	8b 4a 04             	mov    0x4(%edx),%ecx
c01005f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005fa:	89 4a 04             	mov    %ecx,0x4(%edx)
c01005fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100600:	8b 52 04             	mov    0x4(%edx),%edx
c0100603:	8b 52 08             	mov    0x8(%edx),%edx
c0100606:	39 55 0c             	cmp    %edx,0xc(%ebp)
c0100609:	75 0e                	jne    c0100619 <rb_left_rotate+0xa7>
c010060b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010060e:	8b 52 04             	mov    0x4(%edx),%edx
c0100611:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100614:	89 4a 08             	mov    %ecx,0x8(%edx)
c0100617:	eb 0c                	jmp    c0100625 <rb_left_rotate+0xb3>
c0100619:	8b 55 0c             	mov    0xc(%ebp),%edx
c010061c:	8b 52 04             	mov    0x4(%edx),%edx
c010061f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100622:	89 4a 0c             	mov    %ecx,0xc(%edx)
c0100625:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100628:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c010062b:	89 4a 08             	mov    %ecx,0x8(%edx)
c010062e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100631:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100634:	89 4a 04             	mov    %ecx,0x4(%edx)
c0100637:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010063a:	8b 12                	mov    (%edx),%edx
c010063c:	85 d2                	test   %edx,%edx
c010063e:	74 1e                	je     c010065e <rb_left_rotate+0xec>
c0100640:	8d 90 90 24 fe ff    	lea    -0x1db70(%eax),%edx
c0100646:	52                   	push   %edx
c0100647:	8d 90 3c 24 fe ff    	lea    -0x1dbc4(%eax),%edx
c010064d:	52                   	push   %edx
c010064e:	6a 64                	push   $0x64
c0100650:	8d 90 51 24 fe ff    	lea    -0x1dbaf(%eax),%edx
c0100656:	52                   	push   %edx
c0100657:	89 c3                	mov    %eax,%ebx
c0100659:	e8 b4 13 00 00       	call   c0101a12 <__panic>
c010065e:	90                   	nop
c010065f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100662:	c9                   	leave  
c0100663:	c3                   	ret    

c0100664 <rb_right_rotate>:
FUNC_ROTATE(rb_right_rotate, right, left);
c0100664:	55                   	push   %ebp
c0100665:	89 e5                	mov    %esp,%ebp
c0100667:	53                   	push   %ebx
c0100668:	83 ec 14             	sub    $0x14,%esp
c010066b:	e8 4d fc ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100670:	05 10 93 02 00       	add    $0x29310,%eax
c0100675:	8b 55 08             	mov    0x8(%ebp),%edx
c0100678:	8b 52 04             	mov    0x4(%edx),%edx
c010067b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010067e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100681:	8b 52 08             	mov    0x8(%edx),%edx
c0100684:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0100687:	8b 55 08             	mov    0x8(%ebp),%edx
c010068a:	8b 52 08             	mov    0x8(%edx),%edx
c010068d:	39 55 0c             	cmp    %edx,0xc(%ebp)
c0100690:	74 10                	je     c01006a2 <rb_right_rotate+0x3e>
c0100692:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100695:	3b 55 f4             	cmp    -0xc(%ebp),%edx
c0100698:	74 08                	je     c01006a2 <rb_right_rotate+0x3e>
c010069a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010069d:	3b 55 f4             	cmp    -0xc(%ebp),%edx
c01006a0:	75 1e                	jne    c01006c0 <rb_right_rotate+0x5c>
c01006a2:	8d 90 68 24 fe ff    	lea    -0x1db98(%eax),%edx
c01006a8:	52                   	push   %edx
c01006a9:	8d 90 3c 24 fe ff    	lea    -0x1dbc4(%eax),%edx
c01006af:	52                   	push   %edx
c01006b0:	6a 65                	push   $0x65
c01006b2:	8d 90 51 24 fe ff    	lea    -0x1dbaf(%eax),%edx
c01006b8:	52                   	push   %edx
c01006b9:	89 c3                	mov    %eax,%ebx
c01006bb:	e8 52 13 00 00       	call   c0101a12 <__panic>
c01006c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006c3:	8b 4a 0c             	mov    0xc(%edx),%ecx
c01006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01006c9:	89 4a 08             	mov    %ecx,0x8(%edx)
c01006cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006cf:	8b 52 0c             	mov    0xc(%edx),%edx
c01006d2:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01006d5:	74 0c                	je     c01006e3 <rb_right_rotate+0x7f>
c01006d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006da:	8b 52 0c             	mov    0xc(%edx),%edx
c01006dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01006e0:	89 4a 04             	mov    %ecx,0x4(%edx)
c01006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01006e6:	8b 4a 04             	mov    0x4(%edx),%ecx
c01006e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006ec:	89 4a 04             	mov    %ecx,0x4(%edx)
c01006ef:	8b 55 0c             	mov    0xc(%ebp),%edx
c01006f2:	8b 52 04             	mov    0x4(%edx),%edx
c01006f5:	8b 52 0c             	mov    0xc(%edx),%edx
c01006f8:	39 55 0c             	cmp    %edx,0xc(%ebp)
c01006fb:	75 0e                	jne    c010070b <rb_right_rotate+0xa7>
c01006fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100700:	8b 52 04             	mov    0x4(%edx),%edx
c0100703:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100706:	89 4a 0c             	mov    %ecx,0xc(%edx)
c0100709:	eb 0c                	jmp    c0100717 <rb_right_rotate+0xb3>
c010070b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010070e:	8b 52 04             	mov    0x4(%edx),%edx
c0100711:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100714:	89 4a 08             	mov    %ecx,0x8(%edx)
c0100717:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010071a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c010071d:	89 4a 0c             	mov    %ecx,0xc(%edx)
c0100720:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100723:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100726:	89 4a 04             	mov    %ecx,0x4(%edx)
c0100729:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010072c:	8b 12                	mov    (%edx),%edx
c010072e:	85 d2                	test   %edx,%edx
c0100730:	74 1e                	je     c0100750 <rb_right_rotate+0xec>
c0100732:	8d 90 90 24 fe ff    	lea    -0x1db70(%eax),%edx
c0100738:	52                   	push   %edx
c0100739:	8d 90 3c 24 fe ff    	lea    -0x1dbc4(%eax),%edx
c010073f:	52                   	push   %edx
c0100740:	6a 65                	push   $0x65
c0100742:	8d 90 51 24 fe ff    	lea    -0x1dbaf(%eax),%edx
c0100748:	52                   	push   %edx
c0100749:	89 c3                	mov    %eax,%ebx
c010074b:	e8 c2 12 00 00       	call   c0101a12 <__panic>
c0100750:	90                   	nop
c0100751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100754:	c9                   	leave  
c0100755:	c3                   	ret    

c0100756 <rb_insert_binary>:
 * rb_insert_binary - insert @node to red-black @tree as if it were
 * a regular binary tree. This function is only intended to be called
 * by function rb_insert.
 * */
static inline void
rb_insert_binary(rb_tree *tree, rb_node *node) {
c0100756:	55                   	push   %ebp
c0100757:	89 e5                	mov    %esp,%ebp
c0100759:	83 ec 28             	sub    $0x28,%esp
c010075c:	e8 5c fb ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100761:	05 1f 92 02 00       	add    $0x2921f,%eax
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;
c0100766:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100769:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010076c:	8b 45 08             	mov    0x8(%ebp),%eax
c010076f:	8b 40 04             	mov    0x4(%eax),%eax
c0100772:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0100775:	8b 45 08             	mov    0x8(%ebp),%eax
c0100778:	8b 40 08             	mov    0x8(%eax),%eax
c010077b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    z->left = z->right = nil;
c010077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100781:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100784:	89 50 0c             	mov    %edx,0xc(%eax)
c0100787:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010078a:	8b 50 0c             	mov    0xc(%eax),%edx
c010078d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100790:	89 50 08             	mov    %edx,0x8(%eax)
    y = root, x = y->left;
c0100793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100796:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100799:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010079c:	8b 40 08             	mov    0x8(%eax),%eax
c010079f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c01007a2:	eb 2e                	jmp    c01007d2 <rb_insert_binary+0x7c>
        y = x;
c01007a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
c01007aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ad:	8b 00                	mov    (%eax),%eax
c01007af:	83 ec 08             	sub    $0x8,%esp
c01007b2:	ff 75 0c             	pushl  0xc(%ebp)
c01007b5:	ff 75 f4             	pushl  -0xc(%ebp)
c01007b8:	ff d0                	call   *%eax
c01007ba:	83 c4 10             	add    $0x10,%esp
c01007bd:	85 c0                	test   %eax,%eax
c01007bf:	7e 08                	jle    c01007c9 <rb_insert_binary+0x73>
c01007c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c4:	8b 40 08             	mov    0x8(%eax),%eax
c01007c7:	eb 06                	jmp    c01007cf <rb_insert_binary+0x79>
c01007c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cc:	8b 40 0c             	mov    0xc(%eax),%eax
c01007cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c01007d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01007d8:	75 ca                	jne    c01007a4 <rb_insert_binary+0x4e>
    }
    z->parent = y;
c01007da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01007e0:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == root || COMPARE(tree, y, z) > 0) {
c01007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01007e6:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01007e9:	74 17                	je     c0100802 <rb_insert_binary+0xac>
c01007eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ee:	8b 00                	mov    (%eax),%eax
c01007f0:	83 ec 08             	sub    $0x8,%esp
c01007f3:	ff 75 ec             	pushl  -0x14(%ebp)
c01007f6:	ff 75 f0             	pushl  -0x10(%ebp)
c01007f9:	ff d0                	call   *%eax
c01007fb:	83 c4 10             	add    $0x10,%esp
c01007fe:	85 c0                	test   %eax,%eax
c0100800:	7e 0b                	jle    c010080d <rb_insert_binary+0xb7>
        y->left = z;
c0100802:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100805:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100808:	89 50 08             	mov    %edx,0x8(%eax)
c010080b:	eb 09                	jmp    c0100816 <rb_insert_binary+0xc0>
    }
    else {
        y->right = z;
c010080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100810:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100813:	89 50 0c             	mov    %edx,0xc(%eax)
    }
}
c0100816:	90                   	nop
c0100817:	c9                   	leave  
c0100818:	c3                   	ret    

c0100819 <rb_insert>:

/* rb_insert - insert a node to red-black tree */
void
rb_insert(rb_tree *tree, rb_node *node) {
c0100819:	55                   	push   %ebp
c010081a:	89 e5                	mov    %esp,%ebp
c010081c:	53                   	push   %ebx
c010081d:	83 ec 14             	sub    $0x14,%esp
c0100820:	e8 9c fa ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100825:	81 c3 5b 91 02 00    	add    $0x2915b,%ebx
    rb_insert_binary(tree, node);
c010082b:	83 ec 08             	sub    $0x8,%esp
c010082e:	ff 75 0c             	pushl  0xc(%ebp)
c0100831:	ff 75 08             	pushl  0x8(%ebp)
c0100834:	e8 1d ff ff ff       	call   c0100756 <rb_insert_binary>
c0100839:	83 c4 10             	add    $0x10,%esp
    node->red = 1;
c010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    rb_node *x = node, *y;
c0100845:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100848:	89 45 f4             	mov    %eax,-0xc(%ebp)
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c010084b:	e9 6c 01 00 00       	jmp    c01009bc <rb_insert+0x1a3>
        if (x->parent == x->parent->parent->left) {
c0100850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100853:	8b 50 04             	mov    0x4(%eax),%edx
c0100856:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100859:	8b 40 04             	mov    0x4(%eax),%eax
c010085c:	8b 40 04             	mov    0x4(%eax),%eax
c010085f:	8b 40 08             	mov    0x8(%eax),%eax
c0100862:	39 c2                	cmp    %eax,%edx
c0100864:	0f 85 ad 00 00 00    	jne    c0100917 <rb_insert+0xfe>
            RB_INSERT_SUB(left, right);
c010086a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086d:	8b 40 04             	mov    0x4(%eax),%eax
c0100870:	8b 40 04             	mov    0x4(%eax),%eax
c0100873:	8b 40 0c             	mov    0xc(%eax),%eax
c0100876:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100879:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010087c:	8b 00                	mov    (%eax),%eax
c010087e:	85 c0                	test   %eax,%eax
c0100880:	74 35                	je     c01008b7 <rb_insert+0x9e>
c0100882:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100885:	8b 40 04             	mov    0x4(%eax),%eax
c0100888:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010088e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100891:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100897:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089a:	8b 40 04             	mov    0x4(%eax),%eax
c010089d:	8b 40 04             	mov    0x4(%eax),%eax
c01008a0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01008a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a9:	8b 40 04             	mov    0x4(%eax),%eax
c01008ac:	8b 40 04             	mov    0x4(%eax),%eax
c01008af:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01008b2:	e9 05 01 00 00       	jmp    c01009bc <rb_insert+0x1a3>
c01008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ba:	8b 40 04             	mov    0x4(%eax),%eax
c01008bd:	8b 40 0c             	mov    0xc(%eax),%eax
c01008c0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01008c3:	75 1a                	jne    c01008df <rb_insert+0xc6>
c01008c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c8:	8b 40 04             	mov    0x4(%eax),%eax
c01008cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01008ce:	83 ec 08             	sub    $0x8,%esp
c01008d1:	ff 75 f4             	pushl  -0xc(%ebp)
c01008d4:	ff 75 08             	pushl  0x8(%ebp)
c01008d7:	e8 96 fc ff ff       	call   c0100572 <rb_left_rotate>
c01008dc:	83 c4 10             	add    $0x10,%esp
c01008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e2:	8b 40 04             	mov    0x4(%eax),%eax
c01008e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01008eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ee:	8b 40 04             	mov    0x4(%eax),%eax
c01008f1:	8b 40 04             	mov    0x4(%eax),%eax
c01008f4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01008fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008fd:	8b 40 04             	mov    0x4(%eax),%eax
c0100900:	8b 40 04             	mov    0x4(%eax),%eax
c0100903:	83 ec 08             	sub    $0x8,%esp
c0100906:	50                   	push   %eax
c0100907:	ff 75 08             	pushl  0x8(%ebp)
c010090a:	e8 55 fd ff ff       	call   c0100664 <rb_right_rotate>
c010090f:	83 c4 10             	add    $0x10,%esp
c0100912:	e9 a5 00 00 00       	jmp    c01009bc <rb_insert+0x1a3>
        }
        else {
            RB_INSERT_SUB(right, left);
c0100917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010091a:	8b 40 04             	mov    0x4(%eax),%eax
c010091d:	8b 40 04             	mov    0x4(%eax),%eax
c0100920:	8b 40 08             	mov    0x8(%eax),%eax
c0100923:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100926:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100929:	8b 00                	mov    (%eax),%eax
c010092b:	85 c0                	test   %eax,%eax
c010092d:	74 32                	je     c0100961 <rb_insert+0x148>
c010092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100932:	8b 40 04             	mov    0x4(%eax),%eax
c0100935:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010093b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010093e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100944:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100947:	8b 40 04             	mov    0x4(%eax),%eax
c010094a:	8b 40 04             	mov    0x4(%eax),%eax
c010094d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100953:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100956:	8b 40 04             	mov    0x4(%eax),%eax
c0100959:	8b 40 04             	mov    0x4(%eax),%eax
c010095c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010095f:	eb 5b                	jmp    c01009bc <rb_insert+0x1a3>
c0100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100964:	8b 40 04             	mov    0x4(%eax),%eax
c0100967:	8b 40 08             	mov    0x8(%eax),%eax
c010096a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010096d:	75 1a                	jne    c0100989 <rb_insert+0x170>
c010096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100972:	8b 40 04             	mov    0x4(%eax),%eax
c0100975:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100978:	83 ec 08             	sub    $0x8,%esp
c010097b:	ff 75 f4             	pushl  -0xc(%ebp)
c010097e:	ff 75 08             	pushl  0x8(%ebp)
c0100981:	e8 de fc ff ff       	call   c0100664 <rb_right_rotate>
c0100986:	83 c4 10             	add    $0x10,%esp
c0100989:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098c:	8b 40 04             	mov    0x4(%eax),%eax
c010098f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100995:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100998:	8b 40 04             	mov    0x4(%eax),%eax
c010099b:	8b 40 04             	mov    0x4(%eax),%eax
c010099e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01009a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a7:	8b 40 04             	mov    0x4(%eax),%eax
c01009aa:	8b 40 04             	mov    0x4(%eax),%eax
c01009ad:	83 ec 08             	sub    $0x8,%esp
c01009b0:	50                   	push   %eax
c01009b1:	ff 75 08             	pushl  0x8(%ebp)
c01009b4:	e8 b9 fb ff ff       	call   c0100572 <rb_left_rotate>
c01009b9:	83 c4 10             	add    $0x10,%esp
    while (x->parent->red) {
c01009bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009bf:	8b 40 04             	mov    0x4(%eax),%eax
c01009c2:	8b 00                	mov    (%eax),%eax
c01009c4:	85 c0                	test   %eax,%eax
c01009c6:	0f 85 84 fe ff ff    	jne    c0100850 <rb_insert+0x37>
        }
    }
    tree->root->left->red = 0;
c01009cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01009cf:	8b 40 08             	mov    0x8(%eax),%eax
c01009d2:	8b 40 08             	mov    0x8(%eax),%eax
c01009d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(!(tree->nil->red) && !(tree->root->red));
c01009db:	8b 45 08             	mov    0x8(%ebp),%eax
c01009de:	8b 40 04             	mov    0x4(%eax),%eax
c01009e1:	8b 00                	mov    (%eax),%eax
c01009e3:	85 c0                	test   %eax,%eax
c01009e5:	75 0c                	jne    c01009f3 <rb_insert+0x1da>
c01009e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01009ea:	8b 40 08             	mov    0x8(%eax),%eax
c01009ed:	8b 00                	mov    (%eax),%eax
c01009ef:	85 c0                	test   %eax,%eax
c01009f1:	74 1f                	je     c0100a12 <rb_insert+0x1f9>
c01009f3:	8d 83 9c 24 fe ff    	lea    -0x1db64(%ebx),%eax
c01009f9:	50                   	push   %eax
c01009fa:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0100a00:	50                   	push   %eax
c0100a01:	68 a9 00 00 00       	push   $0xa9
c0100a06:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0100a0c:	50                   	push   %eax
c0100a0d:	e8 00 10 00 00       	call   c0101a12 <__panic>

#undef RB_INSERT_SUB
}
c0100a12:	90                   	nop
c0100a13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100a16:	c9                   	leave  
c0100a17:	c3                   	ret    

c0100a18 <rb_tree_successor>:
 * rb_tree_successor - returns the successor of @node, or nil
 * if no successor exists. Make sure that @node must belong to @tree,
 * and this function should only be called by rb_node_prev.
 * */
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
c0100a18:	55                   	push   %ebp
c0100a19:	89 e5                	mov    %esp,%ebp
c0100a1b:	83 ec 10             	sub    $0x10,%esp
c0100a1e:	e8 9a f8 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100a23:	05 5d 8f 02 00       	add    $0x28f5d,%eax
    rb_node *x = node, *y, *nil = tree->nil;
c0100a28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100a2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a31:	8b 40 04             	mov    0x4(%eax),%eax
c0100a34:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->right) != nil) {
c0100a37:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100a3a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a3d:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100a40:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a43:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a46:	74 1b                	je     c0100a63 <rb_tree_successor+0x4b>
        while (y->left != nil) {
c0100a48:	eb 09                	jmp    c0100a53 <rb_tree_successor+0x3b>
            y = y->left;
c0100a4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a4d:	8b 40 08             	mov    0x8(%eax),%eax
c0100a50:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (y->left != nil) {
c0100a53:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a56:	8b 40 08             	mov    0x8(%eax),%eax
c0100a59:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a5c:	75 ec                	jne    c0100a4a <rb_tree_successor+0x32>
        }
        return y;
c0100a5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a61:	eb 38                	jmp    c0100a9b <rb_tree_successor+0x83>
    }
    else {
        y = x->parent;
c0100a63:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100a66:	8b 40 04             	mov    0x4(%eax),%eax
c0100a69:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c0100a6c:	eb 0f                	jmp    c0100a7d <rb_tree_successor+0x65>
            x = y, y = y->parent;
c0100a6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a71:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100a74:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a77:	8b 40 04             	mov    0x4(%eax),%eax
c0100a7a:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c0100a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100a80:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a83:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100a86:	74 e6                	je     c0100a6e <rb_tree_successor+0x56>
        }
        if (y == tree->root) {
c0100a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8b:	8b 40 08             	mov    0x8(%eax),%eax
c0100a8e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c0100a91:	75 05                	jne    c0100a98 <rb_tree_successor+0x80>
            return nil;
c0100a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a96:	eb 03                	jmp    c0100a9b <rb_tree_successor+0x83>
        }
        return y;
c0100a98:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100a9b:	c9                   	leave  
c0100a9c:	c3                   	ret    

c0100a9d <rb_tree_predecessor>:
/* *
 * rb_tree_predecessor - returns the predecessor of @node, or nil
 * if no predecessor exists, likes rb_tree_successor.
 * */
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
c0100a9d:	55                   	push   %ebp
c0100a9e:	89 e5                	mov    %esp,%ebp
c0100aa0:	83 ec 10             	sub    $0x10,%esp
c0100aa3:	e8 15 f8 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100aa8:	05 d8 8e 02 00       	add    $0x28ed8,%eax
    rb_node *x = node, *y, *nil = tree->nil;
c0100aad:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ab0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100ab3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab6:	8b 40 04             	mov    0x4(%eax),%eax
c0100ab9:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->left) != nil) {
c0100abc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100abf:	8b 40 08             	mov    0x8(%eax),%eax
c0100ac2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100ac5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100ac8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100acb:	74 1b                	je     c0100ae8 <rb_tree_predecessor+0x4b>
        while (y->right != nil) {
c0100acd:	eb 09                	jmp    c0100ad8 <rb_tree_predecessor+0x3b>
            y = y->right;
c0100acf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100ad2:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ad5:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (y->right != nil) {
c0100ad8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100adb:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ade:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100ae1:	75 ec                	jne    c0100acf <rb_tree_predecessor+0x32>
        }
        return y;
c0100ae3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100ae6:	eb 38                	jmp    c0100b20 <rb_tree_predecessor+0x83>
    }
    else {
        y = x->parent;
c0100ae8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100aeb:	8b 40 04             	mov    0x4(%eax),%eax
c0100aee:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c0100af1:	eb 1f                	jmp    c0100b12 <rb_tree_predecessor+0x75>
            if (y == tree->root) {
c0100af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af6:	8b 40 08             	mov    0x8(%eax),%eax
c0100af9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c0100afc:	75 05                	jne    c0100b03 <rb_tree_predecessor+0x66>
                return nil;
c0100afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b01:	eb 1d                	jmp    c0100b20 <rb_tree_predecessor+0x83>
            }
            x = y, y = y->parent;
c0100b03:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100b06:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100b09:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100b0c:	8b 40 04             	mov    0x4(%eax),%eax
c0100b0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c0100b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100b15:	8b 40 08             	mov    0x8(%eax),%eax
c0100b18:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100b1b:	74 d6                	je     c0100af3 <rb_tree_predecessor+0x56>
        }
        return y;
c0100b1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100b20:	c9                   	leave  
c0100b21:	c3                   	ret    

c0100b22 <rb_search>:
 * rb_search - returns a node with value 'equal' to @key (according to
 * function @compare). If there're multiple nodes with value 'equal' to @key,
 * the functions returns the one highest in the tree.
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
c0100b22:	55                   	push   %ebp
c0100b23:	89 e5                	mov    %esp,%ebp
c0100b25:	83 ec 18             	sub    $0x18,%esp
c0100b28:	e8 90 f7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100b2d:	05 53 8e 02 00       	add    $0x28e53,%eax
    rb_node *nil = tree->nil, *node = tree->root->left;
c0100b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b35:	8b 40 04             	mov    0x4(%eax),%eax
c0100b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b3e:	8b 40 08             	mov    0x8(%eax),%eax
c0100b41:	8b 40 08             	mov    0x8(%eax),%eax
c0100b44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c0100b47:	eb 17                	jmp    c0100b60 <rb_search+0x3e>
        node = (r > 0) ? node->left : node->right;
c0100b49:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100b4d:	7e 08                	jle    c0100b57 <rb_search+0x35>
c0100b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b52:	8b 40 08             	mov    0x8(%eax),%eax
c0100b55:	eb 06                	jmp    c0100b5d <rb_search+0x3b>
c0100b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (node != nil && (r = compare(node, key)) != 0) {
c0100b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b63:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100b66:	74 1a                	je     c0100b82 <rb_search+0x60>
c0100b68:	83 ec 08             	sub    $0x8,%esp
c0100b6b:	ff 75 10             	pushl  0x10(%ebp)
c0100b6e:	ff 75 f4             	pushl  -0xc(%ebp)
c0100b71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b74:	ff d0                	call   *%eax
c0100b76:	83 c4 10             	add    $0x10,%esp
c0100b79:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100b7c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100b80:	75 c7                	jne    c0100b49 <rb_search+0x27>
    }
    return (node != nil) ? node : NULL;
c0100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b85:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100b88:	74 05                	je     c0100b8f <rb_search+0x6d>
c0100b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b8d:	eb 05                	jmp    c0100b94 <rb_search+0x72>
c0100b8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b94:	c9                   	leave  
c0100b95:	c3                   	ret    

c0100b96 <rb_delete_fixup>:
/* *
 * rb_delete_fixup - performs rotations and changes colors to restore
 * red-black properties after a node is deleted.
 * */
static void
rb_delete_fixup(rb_tree *tree, rb_node *node) {
c0100b96:	55                   	push   %ebp
c0100b97:	89 e5                	mov    %esp,%ebp
c0100b99:	83 ec 18             	sub    $0x18,%esp
c0100b9c:	e8 1c f7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100ba1:	05 df 8d 02 00       	add    $0x28ddf,%eax
    rb_node *x = node, *w, *root = tree->root->left;
c0100ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0100baf:	8b 40 08             	mov    0x8(%eax),%eax
c0100bb2:	8b 40 08             	mov    0x8(%eax),%eax
c0100bb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100bb8:	e9 04 02 00 00       	jmp    c0100dc1 <rb_delete_fixup+0x22b>
        if (x == x->parent->left) {
c0100bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc0:	8b 40 04             	mov    0x4(%eax),%eax
c0100bc3:	8b 40 08             	mov    0x8(%eax),%eax
c0100bc6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100bc9:	0f 85 fd 00 00 00    	jne    c0100ccc <rb_delete_fixup+0x136>
            RB_DELETE_FIXUP_SUB(left, right);
c0100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd2:	8b 40 04             	mov    0x4(%eax),%eax
c0100bd5:	8b 40 0c             	mov    0xc(%eax),%eax
c0100bd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bde:	8b 00                	mov    (%eax),%eax
c0100be0:	85 c0                	test   %eax,%eax
c0100be2:	74 36                	je     c0100c1a <rb_delete_fixup+0x84>
c0100be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100be7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf0:	8b 40 04             	mov    0x4(%eax),%eax
c0100bf3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bfc:	8b 40 04             	mov    0x4(%eax),%eax
c0100bff:	83 ec 08             	sub    $0x8,%esp
c0100c02:	50                   	push   %eax
c0100c03:	ff 75 08             	pushl  0x8(%ebp)
c0100c06:	e8 67 f9 ff ff       	call   c0100572 <rb_left_rotate>
c0100c0b:	83 c4 10             	add    $0x10,%esp
c0100c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c11:	8b 40 04             	mov    0x4(%eax),%eax
c0100c14:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c1d:	8b 40 08             	mov    0x8(%eax),%eax
c0100c20:	8b 00                	mov    (%eax),%eax
c0100c22:	85 c0                	test   %eax,%eax
c0100c24:	75 23                	jne    c0100c49 <rb_delete_fixup+0xb3>
c0100c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c29:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c2c:	8b 00                	mov    (%eax),%eax
c0100c2e:	85 c0                	test   %eax,%eax
c0100c30:	75 17                	jne    c0100c49 <rb_delete_fixup+0xb3>
c0100c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c35:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3e:	8b 40 04             	mov    0x4(%eax),%eax
c0100c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c44:	e9 78 01 00 00       	jmp    c0100dc1 <rb_delete_fixup+0x22b>
c0100c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c4c:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c4f:	8b 00                	mov    (%eax),%eax
c0100c51:	85 c0                	test   %eax,%eax
c0100c53:	75 32                	jne    c0100c87 <rb_delete_fixup+0xf1>
c0100c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c58:	8b 40 08             	mov    0x8(%eax),%eax
c0100c5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c64:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100c6a:	83 ec 08             	sub    $0x8,%esp
c0100c6d:	ff 75 f0             	pushl  -0x10(%ebp)
c0100c70:	ff 75 08             	pushl  0x8(%ebp)
c0100c73:	e8 ec f9 ff ff       	call   c0100664 <rb_right_rotate>
c0100c78:	83 c4 10             	add    $0x10,%esp
c0100c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c7e:	8b 40 04             	mov    0x4(%eax),%eax
c0100c81:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c84:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8a:	8b 40 04             	mov    0x4(%eax),%eax
c0100c8d:	8b 10                	mov    (%eax),%edx
c0100c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c92:	89 10                	mov    %edx,(%eax)
c0100c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c97:	8b 40 04             	mov    0x4(%eax),%eax
c0100c9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ca3:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ca6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100caf:	8b 40 04             	mov    0x4(%eax),%eax
c0100cb2:	83 ec 08             	sub    $0x8,%esp
c0100cb5:	50                   	push   %eax
c0100cb6:	ff 75 08             	pushl  0x8(%ebp)
c0100cb9:	e8 b4 f8 ff ff       	call   c0100572 <rb_left_rotate>
c0100cbe:	83 c4 10             	add    $0x10,%esp
c0100cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100cc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cc7:	e9 f5 00 00 00       	jmp    c0100dc1 <rb_delete_fixup+0x22b>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
c0100ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ccf:	8b 40 04             	mov    0x4(%eax),%eax
c0100cd2:	8b 40 08             	mov    0x8(%eax),%eax
c0100cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100cdb:	8b 00                	mov    (%eax),%eax
c0100cdd:	85 c0                	test   %eax,%eax
c0100cdf:	74 36                	je     c0100d17 <rb_delete_fixup+0x181>
c0100ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ce4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ced:	8b 40 04             	mov    0x4(%eax),%eax
c0100cf0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf9:	8b 40 04             	mov    0x4(%eax),%eax
c0100cfc:	83 ec 08             	sub    $0x8,%esp
c0100cff:	50                   	push   %eax
c0100d00:	ff 75 08             	pushl  0x8(%ebp)
c0100d03:	e8 5c f9 ff ff       	call   c0100664 <rb_right_rotate>
c0100d08:	83 c4 10             	add    $0x10,%esp
c0100d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d0e:	8b 40 04             	mov    0x4(%eax),%eax
c0100d11:	8b 40 08             	mov    0x8(%eax),%eax
c0100d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d1a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100d1d:	8b 00                	mov    (%eax),%eax
c0100d1f:	85 c0                	test   %eax,%eax
c0100d21:	75 20                	jne    c0100d43 <rb_delete_fixup+0x1ad>
c0100d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d26:	8b 40 08             	mov    0x8(%eax),%eax
c0100d29:	8b 00                	mov    (%eax),%eax
c0100d2b:	85 c0                	test   %eax,%eax
c0100d2d:	75 14                	jne    c0100d43 <rb_delete_fixup+0x1ad>
c0100d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d32:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d3b:	8b 40 04             	mov    0x4(%eax),%eax
c0100d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d41:	eb 7e                	jmp    c0100dc1 <rb_delete_fixup+0x22b>
c0100d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d46:	8b 40 08             	mov    0x8(%eax),%eax
c0100d49:	8b 00                	mov    (%eax),%eax
c0100d4b:	85 c0                	test   %eax,%eax
c0100d4d:	75 32                	jne    c0100d81 <rb_delete_fixup+0x1eb>
c0100d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d52:	8b 40 0c             	mov    0xc(%eax),%eax
c0100d55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d5e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100d64:	83 ec 08             	sub    $0x8,%esp
c0100d67:	ff 75 f0             	pushl  -0x10(%ebp)
c0100d6a:	ff 75 08             	pushl  0x8(%ebp)
c0100d6d:	e8 00 f8 ff ff       	call   c0100572 <rb_left_rotate>
c0100d72:	83 c4 10             	add    $0x10,%esp
c0100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d78:	8b 40 04             	mov    0x4(%eax),%eax
c0100d7b:	8b 40 08             	mov    0x8(%eax),%eax
c0100d7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d84:	8b 40 04             	mov    0x4(%eax),%eax
c0100d87:	8b 10                	mov    (%eax),%edx
c0100d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d8c:	89 10                	mov    %edx,(%eax)
c0100d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d91:	8b 40 04             	mov    0x4(%eax),%eax
c0100d94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100d9d:	8b 40 08             	mov    0x8(%eax),%eax
c0100da0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100da9:	8b 40 04             	mov    0x4(%eax),%eax
c0100dac:	83 ec 08             	sub    $0x8,%esp
c0100daf:	50                   	push   %eax
c0100db0:	ff 75 08             	pushl  0x8(%ebp)
c0100db3:	e8 ac f8 ff ff       	call   c0100664 <rb_right_rotate>
c0100db8:	83 c4 10             	add    $0x10,%esp
c0100dbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != root && !x->red) {
c0100dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dc4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100dc7:	74 0d                	je     c0100dd6 <rb_delete_fixup+0x240>
c0100dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dcc:	8b 00                	mov    (%eax),%eax
c0100dce:	85 c0                	test   %eax,%eax
c0100dd0:	0f 84 e7 fd ff ff    	je     c0100bbd <rb_delete_fixup+0x27>
        }
    }
    x->red = 0;
c0100dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

#undef RB_DELETE_FIXUP_SUB
}
c0100ddf:	90                   	nop
c0100de0:	c9                   	leave  
c0100de1:	c3                   	ret    

c0100de2 <rb_delete>:
/* *
 * rb_delete - deletes @node from @tree, and calls rb_delete_fixup to
 * restore red-black properties.
 * */
void
rb_delete(rb_tree *tree, rb_node *node) {
c0100de2:	55                   	push   %ebp
c0100de3:	89 e5                	mov    %esp,%ebp
c0100de5:	53                   	push   %ebx
c0100de6:	83 ec 24             	sub    $0x24,%esp
c0100de9:	e8 d3 f4 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100dee:	81 c3 92 8b 02 00    	add    $0x28b92,%ebx
    rb_node *x, *y, *z = node;
c0100df4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    rb_node *nil = tree->nil, *root = tree->root;
c0100dfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dfd:	8b 40 04             	mov    0x4(%eax),%eax
c0100e00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100e03:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e06:	8b 40 08             	mov    0x8(%eax),%eax
c0100e09:	89 45 ec             	mov    %eax,-0x14(%ebp)

    y = (z->left == nil || z->right == nil) ? z : rb_tree_successor(tree, z);
c0100e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e0f:	8b 40 08             	mov    0x8(%eax),%eax
c0100e12:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100e15:	74 1b                	je     c0100e32 <rb_delete+0x50>
c0100e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e1a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100e1d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100e20:	74 10                	je     c0100e32 <rb_delete+0x50>
c0100e22:	ff 75 f4             	pushl  -0xc(%ebp)
c0100e25:	ff 75 08             	pushl  0x8(%ebp)
c0100e28:	e8 eb fb ff ff       	call   c0100a18 <rb_tree_successor>
c0100e2d:	83 c4 08             	add    $0x8,%esp
c0100e30:	eb 03                	jmp    c0100e35 <rb_delete+0x53>
c0100e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e35:	89 45 e8             	mov    %eax,-0x18(%ebp)
    x = (y->left != nil) ? y->left : y->right;
c0100e38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e3b:	8b 40 08             	mov    0x8(%eax),%eax
c0100e3e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100e41:	74 08                	je     c0100e4b <rb_delete+0x69>
c0100e43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e46:	8b 40 08             	mov    0x8(%eax),%eax
c0100e49:	eb 06                	jmp    c0100e51 <rb_delete+0x6f>
c0100e4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e4e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100e51:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert(y != root && y != nil);
c0100e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e57:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100e5a:	74 08                	je     c0100e64 <rb_delete+0x82>
c0100e5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e5f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100e62:	75 1f                	jne    c0100e83 <rb_delete+0xa1>
c0100e64:	8d 83 c4 24 fe ff    	lea    -0x1db3c(%ebx),%eax
c0100e6a:	50                   	push   %eax
c0100e6b:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0100e71:	50                   	push   %eax
c0100e72:	68 2f 01 00 00       	push   $0x12f
c0100e77:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0100e7d:	50                   	push   %eax
c0100e7e:	e8 8f 0b 00 00       	call   c0101a12 <__panic>

    x->parent = y->parent;
c0100e83:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e86:	8b 50 04             	mov    0x4(%eax),%edx
c0100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100e8c:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == y->parent->left) {
c0100e8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100e92:	8b 40 04             	mov    0x4(%eax),%eax
c0100e95:	8b 40 08             	mov    0x8(%eax),%eax
c0100e98:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0100e9b:	75 0e                	jne    c0100eab <rb_delete+0xc9>
        y->parent->left = x;
c0100e9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ea0:	8b 40 04             	mov    0x4(%eax),%eax
c0100ea3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100ea6:	89 50 08             	mov    %edx,0x8(%eax)
c0100ea9:	eb 0c                	jmp    c0100eb7 <rb_delete+0xd5>
    }
    else {
        y->parent->right = x;
c0100eab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100eae:	8b 40 04             	mov    0x4(%eax),%eax
c0100eb1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100eb4:	89 50 0c             	mov    %edx,0xc(%eax)
    }

    bool need_fixup = !(y->red);
c0100eb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100eba:	8b 00                	mov    (%eax),%eax
c0100ebc:	85 c0                	test   %eax,%eax
c0100ebe:	0f 94 c0             	sete   %al
c0100ec1:	0f b6 c0             	movzbl %al,%eax
c0100ec4:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (y != z) {
c0100ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100eca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100ecd:	74 5c                	je     c0100f2b <rb_delete+0x149>
        if (z == z->parent->left) {
c0100ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ed2:	8b 40 04             	mov    0x4(%eax),%eax
c0100ed5:	8b 40 08             	mov    0x8(%eax),%eax
c0100ed8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100edb:	75 0e                	jne    c0100eeb <rb_delete+0x109>
            z->parent->left = y;
c0100edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ee0:	8b 40 04             	mov    0x4(%eax),%eax
c0100ee3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100ee6:	89 50 08             	mov    %edx,0x8(%eax)
c0100ee9:	eb 0c                	jmp    c0100ef7 <rb_delete+0x115>
        }
        else {
            z->parent->right = y;
c0100eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100eee:	8b 40 04             	mov    0x4(%eax),%eax
c0100ef1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100ef4:	89 50 0c             	mov    %edx,0xc(%eax)
        }
        z->left->parent = z->right->parent = y;
c0100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100efa:	8b 40 0c             	mov    0xc(%eax),%eax
c0100efd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100f00:	89 50 04             	mov    %edx,0x4(%eax)
c0100f03:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100f06:	8b 52 08             	mov    0x8(%edx),%edx
c0100f09:	8b 40 04             	mov    0x4(%eax),%eax
c0100f0c:	89 42 04             	mov    %eax,0x4(%edx)
        *y = *z;
c0100f0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100f12:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100f15:	8b 0a                	mov    (%edx),%ecx
c0100f17:	89 08                	mov    %ecx,(%eax)
c0100f19:	8b 4a 04             	mov    0x4(%edx),%ecx
c0100f1c:	89 48 04             	mov    %ecx,0x4(%eax)
c0100f1f:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100f22:	89 48 08             	mov    %ecx,0x8(%eax)
c0100f25:	8b 52 0c             	mov    0xc(%edx),%edx
c0100f28:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    if (need_fixup) {
c0100f2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0100f2f:	74 11                	je     c0100f42 <rb_delete+0x160>
        rb_delete_fixup(tree, x);
c0100f31:	83 ec 08             	sub    $0x8,%esp
c0100f34:	ff 75 e4             	pushl  -0x1c(%ebp)
c0100f37:	ff 75 08             	pushl  0x8(%ebp)
c0100f3a:	e8 57 fc ff ff       	call   c0100b96 <rb_delete_fixup>
c0100f3f:	83 c4 10             	add    $0x10,%esp
    }
}
c0100f42:	90                   	nop
c0100f43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100f46:	c9                   	leave  
c0100f47:	c3                   	ret    

c0100f48 <rb_tree_destroy>:

/* rb_tree_destroy - destroy a tree and free memory */
void
rb_tree_destroy(rb_tree *tree) {
c0100f48:	55                   	push   %ebp
c0100f49:	89 e5                	mov    %esp,%ebp
c0100f4b:	53                   	push   %ebx
c0100f4c:	83 ec 04             	sub    $0x4,%esp
c0100f4f:	e8 6d f3 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0100f54:	81 c3 2c 8a 02 00    	add    $0x28a2c,%ebx
    kfree(tree->root);
c0100f5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f5d:	8b 40 08             	mov    0x8(%eax),%eax
c0100f60:	83 ec 0c             	sub    $0xc,%esp
c0100f63:	50                   	push   %eax
c0100f64:	e8 86 55 00 00       	call   c01064ef <kfree>
c0100f69:	83 c4 10             	add    $0x10,%esp
    kfree(tree->nil);
c0100f6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f6f:	8b 40 04             	mov    0x4(%eax),%eax
c0100f72:	83 ec 0c             	sub    $0xc,%esp
c0100f75:	50                   	push   %eax
c0100f76:	e8 74 55 00 00       	call   c01064ef <kfree>
c0100f7b:	83 c4 10             	add    $0x10,%esp
    kfree(tree);
c0100f7e:	83 ec 0c             	sub    $0xc,%esp
c0100f81:	ff 75 08             	pushl  0x8(%ebp)
c0100f84:	e8 66 55 00 00       	call   c01064ef <kfree>
c0100f89:	83 c4 10             	add    $0x10,%esp
}
c0100f8c:	90                   	nop
c0100f8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100f90:	c9                   	leave  
c0100f91:	c3                   	ret    

c0100f92 <rb_node_prev>:
/* *
 * rb_node_prev - returns the predecessor node of @node in @tree,
 * or 'NULL' if no predecessor exists.
 * */
rb_node *
rb_node_prev(rb_tree *tree, rb_node *node) {
c0100f92:	55                   	push   %ebp
c0100f93:	89 e5                	mov    %esp,%ebp
c0100f95:	83 ec 10             	sub    $0x10,%esp
c0100f98:	e8 20 f3 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100f9d:	05 e3 89 02 00       	add    $0x289e3,%eax
    rb_node *prev = rb_tree_predecessor(tree, node);
c0100fa2:	ff 75 0c             	pushl  0xc(%ebp)
c0100fa5:	ff 75 08             	pushl  0x8(%ebp)
c0100fa8:	e8 f0 fa ff ff       	call   c0100a9d <rb_tree_predecessor>
c0100fad:	83 c4 08             	add    $0x8,%esp
c0100fb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (prev != tree->nil) ? prev : NULL;
c0100fb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fb6:	8b 40 04             	mov    0x4(%eax),%eax
c0100fb9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100fbc:	74 05                	je     c0100fc3 <rb_node_prev+0x31>
c0100fbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc1:	eb 05                	jmp    c0100fc8 <rb_node_prev+0x36>
c0100fc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100fc8:	c9                   	leave  
c0100fc9:	c3                   	ret    

c0100fca <rb_node_next>:
/* *
 * rb_node_next - returns the successor node of @node in @tree,
 * or 'NULL' if no successor exists.
 * */
rb_node *
rb_node_next(rb_tree *tree, rb_node *node) {
c0100fca:	55                   	push   %ebp
c0100fcb:	89 e5                	mov    %esp,%ebp
c0100fcd:	83 ec 10             	sub    $0x10,%esp
c0100fd0:	e8 e8 f2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0100fd5:	05 ab 89 02 00       	add    $0x289ab,%eax
    rb_node *next = rb_tree_successor(tree, node);
c0100fda:	ff 75 0c             	pushl  0xc(%ebp)
c0100fdd:	ff 75 08             	pushl  0x8(%ebp)
c0100fe0:	e8 33 fa ff ff       	call   c0100a18 <rb_tree_successor>
c0100fe5:	83 c4 08             	add    $0x8,%esp
c0100fe8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (next != tree->nil) ? next : NULL;
c0100feb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fee:	8b 40 04             	mov    0x4(%eax),%eax
c0100ff1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100ff4:	74 05                	je     c0100ffb <rb_node_next+0x31>
c0100ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ff9:	eb 05                	jmp    c0101000 <rb_node_next+0x36>
c0100ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101000:	c9                   	leave  
c0101001:	c3                   	ret    

c0101002 <rb_node_root>:

/* rb_node_root - returns the root node of a @tree, or 'NULL' if tree is empty */
rb_node *
rb_node_root(rb_tree *tree) {
c0101002:	55                   	push   %ebp
c0101003:	89 e5                	mov    %esp,%ebp
c0101005:	83 ec 10             	sub    $0x10,%esp
c0101008:	e8 b0 f2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010100d:	05 73 89 02 00       	add    $0x28973,%eax
    rb_node *node = tree->root->left;
c0101012:	8b 45 08             	mov    0x8(%ebp),%eax
c0101015:	8b 40 08             	mov    0x8(%eax),%eax
c0101018:	8b 40 08             	mov    0x8(%eax),%eax
c010101b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (node != tree->nil) ? node : NULL;
c010101e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101021:	8b 40 04             	mov    0x4(%eax),%eax
c0101024:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0101027:	74 05                	je     c010102e <rb_node_root+0x2c>
c0101029:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010102c:	eb 05                	jmp    c0101033 <rb_node_root+0x31>
c010102e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101033:	c9                   	leave  
c0101034:	c3                   	ret    

c0101035 <rb_node_left>:

/* rb_node_left - gets the left child of @node, or 'NULL' if no such node */
rb_node *
rb_node_left(rb_tree *tree, rb_node *node) {
c0101035:	55                   	push   %ebp
c0101036:	89 e5                	mov    %esp,%ebp
c0101038:	83 ec 10             	sub    $0x10,%esp
c010103b:	e8 7d f2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0101040:	05 40 89 02 00       	add    $0x28940,%eax
    rb_node *left = node->left;
c0101045:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101048:	8b 40 08             	mov    0x8(%eax),%eax
c010104b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (left != tree->nil) ? left : NULL;
c010104e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101051:	8b 40 04             	mov    0x4(%eax),%eax
c0101054:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0101057:	74 05                	je     c010105e <rb_node_left+0x29>
c0101059:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010105c:	eb 05                	jmp    c0101063 <rb_node_left+0x2e>
c010105e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101063:	c9                   	leave  
c0101064:	c3                   	ret    

c0101065 <rb_node_right>:

/* rb_node_right - gets the right child of @node, or 'NULL' if no such node */
rb_node *
rb_node_right(rb_tree *tree, rb_node *node) {
c0101065:	55                   	push   %ebp
c0101066:	89 e5                	mov    %esp,%ebp
c0101068:	83 ec 10             	sub    $0x10,%esp
c010106b:	e8 4d f2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0101070:	05 10 89 02 00       	add    $0x28910,%eax
    rb_node *right = node->right;
c0101075:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101078:	8b 40 0c             	mov    0xc(%eax),%eax
c010107b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (right != tree->nil) ? right : NULL;
c010107e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101081:	8b 40 04             	mov    0x4(%eax),%eax
c0101084:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0101087:	74 05                	je     c010108e <rb_node_right+0x29>
c0101089:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010108c:	eb 05                	jmp    c0101093 <rb_node_right+0x2e>
c010108e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101093:	c9                   	leave  
c0101094:	c3                   	ret    

c0101095 <check_tree>:

int
check_tree(rb_tree *tree, rb_node *node) {
c0101095:	55                   	push   %ebp
c0101096:	89 e5                	mov    %esp,%ebp
c0101098:	53                   	push   %ebx
c0101099:	83 ec 14             	sub    $0x14,%esp
c010109c:	e8 20 f2 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01010a1:	81 c3 df 88 02 00    	add    $0x288df,%ebx
    rb_node *nil = tree->nil;
c01010a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01010aa:	8b 40 04             	mov    0x4(%eax),%eax
c01010ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (node == nil) {
c01010b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010b3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01010b6:	75 32                	jne    c01010ea <check_tree+0x55>
        assert(!node->red);
c01010b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010bb:	8b 00                	mov    (%eax),%eax
c01010bd:	85 c0                	test   %eax,%eax
c01010bf:	74 1f                	je     c01010e0 <check_tree+0x4b>
c01010c1:	8d 83 da 24 fe ff    	lea    -0x1db26(%ebx),%eax
c01010c7:	50                   	push   %eax
c01010c8:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c01010ce:	50                   	push   %eax
c01010cf:	68 7f 01 00 00       	push   $0x17f
c01010d4:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c01010da:	50                   	push   %eax
c01010db:	e8 32 09 00 00       	call   c0101a12 <__panic>
        return 1;
c01010e0:	b8 01 00 00 00       	mov    $0x1,%eax
c01010e5:	e9 91 01 00 00       	jmp    c010127b <check_tree+0x1e6>
    }
    if (node->left != nil) {
c01010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010ed:	8b 40 08             	mov    0x8(%eax),%eax
c01010f0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01010f3:	74 67                	je     c010115c <check_tree+0xc7>
        assert(COMPARE(tree, node, node->left) >= 0);
c01010f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f8:	8b 00                	mov    (%eax),%eax
c01010fa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01010fd:	8b 52 08             	mov    0x8(%edx),%edx
c0101100:	83 ec 08             	sub    $0x8,%esp
c0101103:	52                   	push   %edx
c0101104:	ff 75 0c             	pushl  0xc(%ebp)
c0101107:	ff d0                	call   *%eax
c0101109:	83 c4 10             	add    $0x10,%esp
c010110c:	85 c0                	test   %eax,%eax
c010110e:	79 1f                	jns    c010112f <check_tree+0x9a>
c0101110:	8d 83 e8 24 fe ff    	lea    -0x1db18(%ebx),%eax
c0101116:	50                   	push   %eax
c0101117:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c010111d:	50                   	push   %eax
c010111e:	68 83 01 00 00       	push   $0x183
c0101123:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101129:	50                   	push   %eax
c010112a:	e8 e3 08 00 00       	call   c0101a12 <__panic>
        assert(node->left->parent == node);
c010112f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101132:	8b 40 08             	mov    0x8(%eax),%eax
c0101135:	8b 40 04             	mov    0x4(%eax),%eax
c0101138:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010113b:	74 1f                	je     c010115c <check_tree+0xc7>
c010113d:	8d 83 0d 25 fe ff    	lea    -0x1daf3(%ebx),%eax
c0101143:	50                   	push   %eax
c0101144:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c010114a:	50                   	push   %eax
c010114b:	68 84 01 00 00       	push   $0x184
c0101150:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101156:	50                   	push   %eax
c0101157:	e8 b6 08 00 00       	call   c0101a12 <__panic>
    }
    if (node->right != nil) {
c010115c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010115f:	8b 40 0c             	mov    0xc(%eax),%eax
c0101162:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0101165:	74 67                	je     c01011ce <check_tree+0x139>
        assert(COMPARE(tree, node, node->right) <= 0);
c0101167:	8b 45 08             	mov    0x8(%ebp),%eax
c010116a:	8b 00                	mov    (%eax),%eax
c010116c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010116f:	8b 52 0c             	mov    0xc(%edx),%edx
c0101172:	83 ec 08             	sub    $0x8,%esp
c0101175:	52                   	push   %edx
c0101176:	ff 75 0c             	pushl  0xc(%ebp)
c0101179:	ff d0                	call   *%eax
c010117b:	83 c4 10             	add    $0x10,%esp
c010117e:	85 c0                	test   %eax,%eax
c0101180:	7e 1f                	jle    c01011a1 <check_tree+0x10c>
c0101182:	8d 83 28 25 fe ff    	lea    -0x1dad8(%ebx),%eax
c0101188:	50                   	push   %eax
c0101189:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c010118f:	50                   	push   %eax
c0101190:	68 87 01 00 00       	push   $0x187
c0101195:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c010119b:	50                   	push   %eax
c010119c:	e8 71 08 00 00       	call   c0101a12 <__panic>
        assert(node->right->parent == node);
c01011a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011a4:	8b 40 0c             	mov    0xc(%eax),%eax
c01011a7:	8b 40 04             	mov    0x4(%eax),%eax
c01011aa:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01011ad:	74 1f                	je     c01011ce <check_tree+0x139>
c01011af:	8d 83 4e 25 fe ff    	lea    -0x1dab2(%ebx),%eax
c01011b5:	50                   	push   %eax
c01011b6:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c01011bc:	50                   	push   %eax
c01011bd:	68 88 01 00 00       	push   $0x188
c01011c2:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c01011c8:	50                   	push   %eax
c01011c9:	e8 44 08 00 00       	call   c0101a12 <__panic>
    }
    if (node->red) {
c01011ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011d1:	8b 00                	mov    (%eax),%eax
c01011d3:	85 c0                	test   %eax,%eax
c01011d5:	74 37                	je     c010120e <check_tree+0x179>
        assert(!node->left->red && !node->right->red);
c01011d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011da:	8b 40 08             	mov    0x8(%eax),%eax
c01011dd:	8b 00                	mov    (%eax),%eax
c01011df:	85 c0                	test   %eax,%eax
c01011e1:	75 0c                	jne    c01011ef <check_tree+0x15a>
c01011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01011e6:	8b 40 0c             	mov    0xc(%eax),%eax
c01011e9:	8b 00                	mov    (%eax),%eax
c01011eb:	85 c0                	test   %eax,%eax
c01011ed:	74 1f                	je     c010120e <check_tree+0x179>
c01011ef:	8d 83 6c 25 fe ff    	lea    -0x1da94(%ebx),%eax
c01011f5:	50                   	push   %eax
c01011f6:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c01011fc:	50                   	push   %eax
c01011fd:	68 8b 01 00 00       	push   $0x18b
c0101202:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101208:	50                   	push   %eax
c0101209:	e8 04 08 00 00       	call   c0101a12 <__panic>
    }
    int hb_left = check_tree(tree, node->left);
c010120e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101211:	8b 40 08             	mov    0x8(%eax),%eax
c0101214:	83 ec 08             	sub    $0x8,%esp
c0101217:	50                   	push   %eax
c0101218:	ff 75 08             	pushl  0x8(%ebp)
c010121b:	e8 75 fe ff ff       	call   c0101095 <check_tree>
c0101220:	83 c4 10             	add    $0x10,%esp
c0101223:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int hb_right = check_tree(tree, node->right);
c0101226:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101229:	8b 40 0c             	mov    0xc(%eax),%eax
c010122c:	83 ec 08             	sub    $0x8,%esp
c010122f:	50                   	push   %eax
c0101230:	ff 75 08             	pushl  0x8(%ebp)
c0101233:	e8 5d fe ff ff       	call   c0101095 <check_tree>
c0101238:	83 c4 10             	add    $0x10,%esp
c010123b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(hb_left == hb_right);
c010123e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101241:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0101244:	74 1f                	je     c0101265 <check_tree+0x1d0>
c0101246:	8d 83 92 25 fe ff    	lea    -0x1da6e(%ebx),%eax
c010124c:	50                   	push   %eax
c010124d:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0101253:	50                   	push   %eax
c0101254:	68 8f 01 00 00       	push   $0x18f
c0101259:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c010125f:	50                   	push   %eax
c0101260:	e8 ad 07 00 00       	call   c0101a12 <__panic>
    int hb = hb_left;
c0101265:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101268:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!node->red) {
c010126b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010126e:	8b 00                	mov    (%eax),%eax
c0101270:	85 c0                	test   %eax,%eax
c0101272:	75 04                	jne    c0101278 <check_tree+0x1e3>
        hb ++;
c0101274:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    return hb;
c0101278:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010127b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010127e:	c9                   	leave  
c010127f:	c3                   	ret    

c0101280 <check_safe_kmalloc>:

static void *
check_safe_kmalloc(size_t size) {
c0101280:	55                   	push   %ebp
c0101281:	89 e5                	mov    %esp,%ebp
c0101283:	53                   	push   %ebx
c0101284:	83 ec 14             	sub    $0x14,%esp
c0101287:	e8 35 f0 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010128c:	81 c3 f4 86 02 00    	add    $0x286f4,%ebx
    void *ret = kmalloc(size);
c0101292:	83 ec 0c             	sub    $0xc,%esp
c0101295:	ff 75 08             	pushl  0x8(%ebp)
c0101298:	e8 30 52 00 00       	call   c01064cd <kmalloc>
c010129d:	83 c4 10             	add    $0x10,%esp
c01012a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(ret != NULL);
c01012a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01012a7:	75 1f                	jne    c01012c8 <check_safe_kmalloc+0x48>
c01012a9:	8d 83 a6 25 fe ff    	lea    -0x1da5a(%ebx),%eax
c01012af:	50                   	push   %eax
c01012b0:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c01012b6:	50                   	push   %eax
c01012b7:	68 9a 01 00 00       	push   $0x19a
c01012bc:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c01012c2:	50                   	push   %eax
c01012c3:	e8 4a 07 00 00       	call   c0101a12 <__panic>
    return ret;
c01012c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01012cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01012ce:	c9                   	leave  
c01012cf:	c3                   	ret    

c01012d0 <check_compare1>:

#define rbn2data(node)              \
    (to_struct(node, struct check_data, rb_link))

static inline int
check_compare1(rb_node *node1, rb_node *node2) {
c01012d0:	55                   	push   %ebp
c01012d1:	89 e5                	mov    %esp,%ebp
c01012d3:	e8 e5 ef ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01012d8:	05 a8 86 02 00       	add    $0x286a8,%eax
    return rbn2data(node1)->data - rbn2data(node2)->data;
c01012dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01012e0:	83 e8 04             	sub    $0x4,%eax
c01012e3:	8b 10                	mov    (%eax),%edx
c01012e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012e8:	83 e8 04             	sub    $0x4,%eax
c01012eb:	8b 00                	mov    (%eax),%eax
c01012ed:	29 c2                	sub    %eax,%edx
c01012ef:	89 d0                	mov    %edx,%eax
}
c01012f1:	5d                   	pop    %ebp
c01012f2:	c3                   	ret    

c01012f3 <check_compare2>:

static inline int
check_compare2(rb_node *node, void *key) {
c01012f3:	55                   	push   %ebp
c01012f4:	89 e5                	mov    %esp,%ebp
c01012f6:	e8 c2 ef ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01012fb:	05 85 86 02 00       	add    $0x28685,%eax
    return rbn2data(node)->data - (long)key;
c0101300:	8b 45 08             	mov    0x8(%ebp),%eax
c0101303:	83 e8 04             	sub    $0x4,%eax
c0101306:	8b 10                	mov    (%eax),%edx
c0101308:	8b 45 0c             	mov    0xc(%ebp),%eax
c010130b:	29 c2                	sub    %eax,%edx
c010130d:	89 d0                	mov    %edx,%eax
}
c010130f:	5d                   	pop    %ebp
c0101310:	c3                   	ret    

c0101311 <check_rb_tree>:

void
check_rb_tree(void) {
c0101311:	55                   	push   %ebp
c0101312:	89 e5                	mov    %esp,%ebp
c0101314:	56                   	push   %esi
c0101315:	53                   	push   %ebx
c0101316:	83 ec 30             	sub    $0x30,%esp
c0101319:	e8 a3 ef ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010131e:	81 c3 62 86 02 00    	add    $0x28662,%ebx
    rb_tree *tree = rb_tree_create(check_compare1);
c0101324:	83 ec 0c             	sub    $0xc,%esp
c0101327:	8d 83 50 79 fd ff    	lea    -0x286b0(%ebx),%eax
c010132d:	50                   	push   %eax
c010132e:	e8 31 f1 ff ff       	call   c0100464 <rb_tree_create>
c0101333:	83 c4 10             	add    $0x10,%esp
c0101336:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(tree != NULL);
c0101339:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010133d:	75 1f                	jne    c010135e <check_rb_tree+0x4d>
c010133f:	8d 83 b2 25 fe ff    	lea    -0x1da4e(%ebx),%eax
c0101345:	50                   	push   %eax
c0101346:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c010134c:	50                   	push   %eax
c010134d:	68 b3 01 00 00       	push   $0x1b3
c0101352:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101358:	50                   	push   %eax
c0101359:	e8 b4 06 00 00       	call   c0101a12 <__panic>

    rb_node *nil = tree->nil, *root = tree->root;
c010135e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101361:	8b 40 04             	mov    0x4(%eax),%eax
c0101364:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0101367:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010136a:	8b 40 08             	mov    0x8(%eax),%eax
c010136d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(!nil->red && root->left == nil);
c0101370:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101373:	8b 00                	mov    (%eax),%eax
c0101375:	85 c0                	test   %eax,%eax
c0101377:	75 0b                	jne    c0101384 <check_rb_tree+0x73>
c0101379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010137c:	8b 40 08             	mov    0x8(%eax),%eax
c010137f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0101382:	74 1f                	je     c01013a3 <check_rb_tree+0x92>
c0101384:	8d 83 c0 25 fe ff    	lea    -0x1da40(%ebx),%eax
c010138a:	50                   	push   %eax
c010138b:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0101391:	50                   	push   %eax
c0101392:	68 b6 01 00 00       	push   $0x1b6
c0101397:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c010139d:	50                   	push   %eax
c010139e:	e8 6f 06 00 00       	call   c0101a12 <__panic>

    int total = 1000;
c01013a3:	c7 45 e0 e8 03 00 00 	movl   $0x3e8,-0x20(%ebp)
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);
c01013aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01013ad:	c1 e0 02             	shl    $0x2,%eax
c01013b0:	83 ec 0c             	sub    $0xc,%esp
c01013b3:	50                   	push   %eax
c01013b4:	e8 c7 fe ff ff       	call   c0101280 <check_safe_kmalloc>
c01013b9:	83 c4 10             	add    $0x10,%esp
c01013bc:	89 45 dc             	mov    %eax,-0x24(%ebp)

    long i;
    for (i = 0; i < total; i ++) {
c01013bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013c6:	eb 39                	jmp    c0101401 <check_rb_tree+0xf0>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
c01013c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013d5:	8d 34 02             	lea    (%edx,%eax,1),%esi
c01013d8:	83 ec 0c             	sub    $0xc,%esp
c01013db:	6a 14                	push   $0x14
c01013dd:	e8 9e fe ff ff       	call   c0101280 <check_safe_kmalloc>
c01013e2:	83 c4 10             	add    $0x10,%esp
c01013e5:	89 06                	mov    %eax,(%esi)
        all[i]->data = i;
c01013e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013f4:	01 d0                	add    %edx,%eax
c01013f6:	8b 00                	mov    (%eax),%eax
c01013f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013fb:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < total; i ++) {
c01013fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101401:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101404:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101407:	7c bf                	jl     c01013c8 <check_rb_tree+0xb7>
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
c0101409:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010140c:	c1 e0 02             	shl    $0x2,%eax
c010140f:	83 ec 0c             	sub    $0xc,%esp
c0101412:	50                   	push   %eax
c0101413:	e8 68 fe ff ff       	call   c0101280 <check_safe_kmalloc>
c0101418:	83 c4 10             	add    $0x10,%esp
c010141b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mark, 0, sizeof(int) * total);
c010141e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101421:	c1 e0 02             	shl    $0x2,%eax
c0101424:	83 ec 04             	sub    $0x4,%esp
c0101427:	50                   	push   %eax
c0101428:	6a 00                	push   $0x0
c010142a:	ff 75 d8             	pushl  -0x28(%ebp)
c010142d:	e8 7a 9f 00 00       	call   c010b3ac <memset>
c0101432:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c0101435:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010143c:	eb 29                	jmp    c0101467 <check_rb_tree+0x156>
        mark[all[i]->data] = 1;
c010143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101441:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101448:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010144b:	01 d0                	add    %edx,%eax
c010144d:	8b 00                	mov    (%eax),%eax
c010144f:	8b 00                	mov    (%eax),%eax
c0101451:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101458:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010145b:	01 d0                	add    %edx,%eax
c010145d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    for (i = 0; i < total; i ++) {
c0101463:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101467:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010146a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010146d:	7c cf                	jl     c010143e <check_rb_tree+0x12d>
    }
    for (i = 0; i < total; i ++) {
c010146f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101476:	eb 39                	jmp    c01014b1 <check_rb_tree+0x1a0>
        assert(mark[i] == 1);
c0101478:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010147b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101482:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101485:	01 d0                	add    %edx,%eax
c0101487:	8b 00                	mov    (%eax),%eax
c0101489:	83 f8 01             	cmp    $0x1,%eax
c010148c:	74 1f                	je     c01014ad <check_rb_tree+0x19c>
c010148e:	8d 83 df 25 fe ff    	lea    -0x1da21(%ebx),%eax
c0101494:	50                   	push   %eax
c0101495:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c010149b:	50                   	push   %eax
c010149c:	68 c8 01 00 00       	push   $0x1c8
c01014a1:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c01014a7:	50                   	push   %eax
c01014a8:	e8 65 05 00 00       	call   c0101a12 <__panic>
    for (i = 0; i < total; i ++) {
c01014ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01014b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014b4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014b7:	7c bf                	jl     c0101478 <check_rb_tree+0x167>
    }

    for (i = 0; i < total; i ++) {
c01014b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01014c0:	eb 6a                	jmp    c010152c <check_rb_tree+0x21b>
        int j = (rand() % (total - i)) + i;
c01014c2:	e8 40 a7 00 00       	call   c010bc07 <rand>
c01014c7:	89 c2                	mov    %eax,%edx
c01014c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01014cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01014cf:	89 c1                	mov    %eax,%ecx
c01014d1:	89 d0                	mov    %edx,%eax
c01014d3:	99                   	cltd   
c01014d4:	f7 f9                	idiv   %ecx
c01014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014d9:	01 d0                	add    %edx,%eax
c01014db:	89 45 d0             	mov    %eax,-0x30(%ebp)
        struct check_data *z = all[i];
c01014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01014e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01014eb:	01 d0                	add    %edx,%eax
c01014ed:	8b 00                	mov    (%eax),%eax
c01014ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
        all[i] = all[j];
c01014f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01014f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01014fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01014ff:	01 d0                	add    %edx,%eax
c0101501:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101504:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
c010150b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010150e:	01 ca                	add    %ecx,%edx
c0101510:	8b 00                	mov    (%eax),%eax
c0101512:	89 02                	mov    %eax,(%edx)
        all[j] = z;
c0101514:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101517:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010151e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101521:	01 c2                	add    %eax,%edx
c0101523:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101526:	89 02                	mov    %eax,(%edx)
    for (i = 0; i < total; i ++) {
c0101528:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010152f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101532:	7c 8e                	jl     c01014c2 <check_rb_tree+0x1b1>
    }

    memset(mark, 0, sizeof(int) * total);
c0101534:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101537:	c1 e0 02             	shl    $0x2,%eax
c010153a:	83 ec 04             	sub    $0x4,%esp
c010153d:	50                   	push   %eax
c010153e:	6a 00                	push   $0x0
c0101540:	ff 75 d8             	pushl  -0x28(%ebp)
c0101543:	e8 64 9e 00 00       	call   c010b3ac <memset>
c0101548:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c010154b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101552:	eb 29                	jmp    c010157d <check_rb_tree+0x26c>
        mark[all[i]->data] = 1;
c0101554:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101557:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010155e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101561:	01 d0                	add    %edx,%eax
c0101563:	8b 00                	mov    (%eax),%eax
c0101565:	8b 00                	mov    (%eax),%eax
c0101567:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010156e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101571:	01 d0                	add    %edx,%eax
c0101573:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    for (i = 0; i < total; i ++) {
c0101579:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010157d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101580:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101583:	7c cf                	jl     c0101554 <check_rb_tree+0x243>
    }
    for (i = 0; i < total; i ++) {
c0101585:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010158c:	eb 39                	jmp    c01015c7 <check_rb_tree+0x2b6>
        assert(mark[i] == 1);
c010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101591:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101598:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010159b:	01 d0                	add    %edx,%eax
c010159d:	8b 00                	mov    (%eax),%eax
c010159f:	83 f8 01             	cmp    $0x1,%eax
c01015a2:	74 1f                	je     c01015c3 <check_rb_tree+0x2b2>
c01015a4:	8d 83 df 25 fe ff    	lea    -0x1da21(%ebx),%eax
c01015aa:	50                   	push   %eax
c01015ab:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c01015b1:	50                   	push   %eax
c01015b2:	68 d7 01 00 00       	push   $0x1d7
c01015b7:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c01015bd:	50                   	push   %eax
c01015be:	e8 4f 04 00 00       	call   c0101a12 <__panic>
    for (i = 0; i < total; i ++) {
c01015c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01015c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015ca:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01015cd:	7c bf                	jl     c010158e <check_rb_tree+0x27d>
    }

    for (i = 0; i < total; i ++) {
c01015cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01015d6:	eb 3c                	jmp    c0101614 <check_rb_tree+0x303>
        rb_insert(tree, &(all[i]->rb_link));
c01015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01015e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01015e5:	01 d0                	add    %edx,%eax
c01015e7:	8b 00                	mov    (%eax),%eax
c01015e9:	83 c0 04             	add    $0x4,%eax
c01015ec:	83 ec 08             	sub    $0x8,%esp
c01015ef:	50                   	push   %eax
c01015f0:	ff 75 ec             	pushl  -0x14(%ebp)
c01015f3:	e8 21 f2 ff ff       	call   c0100819 <rb_insert>
c01015f8:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c01015fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01015fe:	8b 40 08             	mov    0x8(%eax),%eax
c0101601:	83 ec 08             	sub    $0x8,%esp
c0101604:	50                   	push   %eax
c0101605:	ff 75 ec             	pushl  -0x14(%ebp)
c0101608:	e8 88 fa ff ff       	call   c0101095 <check_tree>
c010160d:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c0101610:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101614:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101617:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010161a:	7c bc                	jl     c01015d8 <check_rb_tree+0x2c7>
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c010161c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101623:	eb 6e                	jmp    c0101693 <check_rb_tree+0x382>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
c0101625:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101628:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010162f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101632:	01 d0                	add    %edx,%eax
c0101634:	8b 00                	mov    (%eax),%eax
c0101636:	8b 00                	mov    (%eax),%eax
c0101638:	83 ec 04             	sub    $0x4,%esp
c010163b:	50                   	push   %eax
c010163c:	8d 83 73 79 fd ff    	lea    -0x2868d(%ebx),%eax
c0101642:	50                   	push   %eax
c0101643:	ff 75 ec             	pushl  -0x14(%ebp)
c0101646:	e8 d7 f4 ff ff       	call   c0100b22 <rb_search>
c010164b:	83 c4 10             	add    $0x10,%esp
c010164e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(node != NULL && node == &(all[i]->rb_link));
c0101651:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0101655:	74 19                	je     c0101670 <check_rb_tree+0x35f>
c0101657:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010165a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101661:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101664:	01 d0                	add    %edx,%eax
c0101666:	8b 00                	mov    (%eax),%eax
c0101668:	83 c0 04             	add    $0x4,%eax
c010166b:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
c010166e:	74 1f                	je     c010168f <check_rb_tree+0x37e>
c0101670:	8d 83 ec 25 fe ff    	lea    -0x1da14(%ebx),%eax
c0101676:	50                   	push   %eax
c0101677:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c010167d:	50                   	push   %eax
c010167e:	68 e2 01 00 00       	push   $0x1e2
c0101683:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101689:	50                   	push   %eax
c010168a:	e8 83 03 00 00       	call   c0101a12 <__panic>
    for (i = 0; i < total; i ++) {
c010168f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101693:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101696:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101699:	7c 8a                	jl     c0101625 <check_rb_tree+0x314>
    }

    for (i = 0; i < total; i ++) {
c010169b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01016a2:	eb 78                	jmp    c010171c <check_rb_tree+0x40b>
        node = rb_search(tree, check_compare2, (void *)i);
c01016a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016a7:	83 ec 04             	sub    $0x4,%esp
c01016aa:	50                   	push   %eax
c01016ab:	8d 83 73 79 fd ff    	lea    -0x2868d(%ebx),%eax
c01016b1:	50                   	push   %eax
c01016b2:	ff 75 ec             	pushl  -0x14(%ebp)
c01016b5:	e8 68 f4 ff ff       	call   c0100b22 <rb_search>
c01016ba:	83 c4 10             	add    $0x10,%esp
c01016bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(node != NULL && rbn2data(node)->data == i);
c01016c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01016c4:	74 0d                	je     c01016d3 <check_rb_tree+0x3c2>
c01016c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01016c9:	83 e8 04             	sub    $0x4,%eax
c01016cc:	8b 00                	mov    (%eax),%eax
c01016ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01016d1:	74 1f                	je     c01016f2 <check_rb_tree+0x3e1>
c01016d3:	8d 83 18 26 fe ff    	lea    -0x1d9e8(%ebx),%eax
c01016d9:	50                   	push   %eax
c01016da:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c01016e0:	50                   	push   %eax
c01016e1:	68 e7 01 00 00       	push   $0x1e7
c01016e6:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c01016ec:	50                   	push   %eax
c01016ed:	e8 20 03 00 00       	call   c0101a12 <__panic>
        rb_delete(tree, node);
c01016f2:	83 ec 08             	sub    $0x8,%esp
c01016f5:	ff 75 d4             	pushl  -0x2c(%ebp)
c01016f8:	ff 75 ec             	pushl  -0x14(%ebp)
c01016fb:	e8 e2 f6 ff ff       	call   c0100de2 <rb_delete>
c0101700:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101706:	8b 40 08             	mov    0x8(%eax),%eax
c0101709:	83 ec 08             	sub    $0x8,%esp
c010170c:	50                   	push   %eax
c010170d:	ff 75 ec             	pushl  -0x14(%ebp)
c0101710:	e8 80 f9 ff ff       	call   c0101095 <check_tree>
c0101715:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c0101718:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010171c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010171f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101722:	7c 80                	jl     c01016a4 <check_rb_tree+0x393>
    }

    assert(!nil->red && root->left == nil);
c0101724:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101727:	8b 00                	mov    (%eax),%eax
c0101729:	85 c0                	test   %eax,%eax
c010172b:	75 0b                	jne    c0101738 <check_rb_tree+0x427>
c010172d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101730:	8b 40 08             	mov    0x8(%eax),%eax
c0101733:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0101736:	74 1f                	je     c0101757 <check_rb_tree+0x446>
c0101738:	8d 83 c0 25 fe ff    	lea    -0x1da40(%ebx),%eax
c010173e:	50                   	push   %eax
c010173f:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0101745:	50                   	push   %eax
c0101746:	68 ec 01 00 00       	push   $0x1ec
c010174b:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101751:	50                   	push   %eax
c0101752:	e8 bb 02 00 00       	call   c0101a12 <__panic>

    long max = 32;
c0101757:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
    if (max > total) {
c010175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101761:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101764:	7e 06                	jle    c010176c <check_rb_tree+0x45b>
        max = total;
c0101766:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101769:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    for (i = 0; i < max; i ++) {
c010176c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101773:	eb 52                	jmp    c01017c7 <check_rb_tree+0x4b6>
        all[i]->data = max;
c0101775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101778:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010177f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101782:	01 d0                	add    %edx,%eax
c0101784:	8b 00                	mov    (%eax),%eax
c0101786:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101789:	89 10                	mov    %edx,(%eax)
        rb_insert(tree, &(all[i]->rb_link));
c010178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010178e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101795:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101798:	01 d0                	add    %edx,%eax
c010179a:	8b 00                	mov    (%eax),%eax
c010179c:	83 c0 04             	add    $0x4,%eax
c010179f:	83 ec 08             	sub    $0x8,%esp
c01017a2:	50                   	push   %eax
c01017a3:	ff 75 ec             	pushl  -0x14(%ebp)
c01017a6:	e8 6e f0 ff ff       	call   c0100819 <rb_insert>
c01017ab:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c01017ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01017b1:	8b 40 08             	mov    0x8(%eax),%eax
c01017b4:	83 ec 08             	sub    $0x8,%esp
c01017b7:	50                   	push   %eax
c01017b8:	ff 75 ec             	pushl  -0x14(%ebp)
c01017bb:	e8 d5 f8 ff ff       	call   c0101095 <check_tree>
c01017c0:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < max; i ++) {
c01017c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017ca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01017cd:	7c a6                	jl     c0101775 <check_rb_tree+0x464>
    }

    for (i = 0; i < max; i ++) {
c01017cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01017d6:	eb 78                	jmp    c0101850 <check_rb_tree+0x53f>
        node = rb_search(tree, check_compare2, (void *)max);
c01017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017db:	83 ec 04             	sub    $0x4,%esp
c01017de:	50                   	push   %eax
c01017df:	8d 83 73 79 fd ff    	lea    -0x2868d(%ebx),%eax
c01017e5:	50                   	push   %eax
c01017e6:	ff 75 ec             	pushl  -0x14(%ebp)
c01017e9:	e8 34 f3 ff ff       	call   c0100b22 <rb_search>
c01017ee:	83 c4 10             	add    $0x10,%esp
c01017f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(node != NULL && rbn2data(node)->data == max);
c01017f4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01017f8:	74 0d                	je     c0101807 <check_rb_tree+0x4f6>
c01017fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01017fd:	83 e8 04             	sub    $0x4,%eax
c0101800:	8b 00                	mov    (%eax),%eax
c0101802:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0101805:	74 1f                	je     c0101826 <check_rb_tree+0x515>
c0101807:	8d 83 44 26 fe ff    	lea    -0x1d9bc(%ebx),%eax
c010180d:	50                   	push   %eax
c010180e:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0101814:	50                   	push   %eax
c0101815:	68 fb 01 00 00       	push   $0x1fb
c010181a:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101820:	50                   	push   %eax
c0101821:	e8 ec 01 00 00       	call   c0101a12 <__panic>
        rb_delete(tree, node);
c0101826:	83 ec 08             	sub    $0x8,%esp
c0101829:	ff 75 d4             	pushl  -0x2c(%ebp)
c010182c:	ff 75 ec             	pushl  -0x14(%ebp)
c010182f:	e8 ae f5 ff ff       	call   c0100de2 <rb_delete>
c0101834:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101837:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010183a:	8b 40 08             	mov    0x8(%eax),%eax
c010183d:	83 ec 08             	sub    $0x8,%esp
c0101840:	50                   	push   %eax
c0101841:	ff 75 ec             	pushl  -0x14(%ebp)
c0101844:	e8 4c f8 ff ff       	call   c0101095 <check_tree>
c0101849:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < max; i ++) {
c010184c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101853:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0101856:	7c 80                	jl     c01017d8 <check_rb_tree+0x4c7>
    }

    assert(rb_tree_empty(tree));
c0101858:	83 ec 0c             	sub    $0xc,%esp
c010185b:	ff 75 ec             	pushl  -0x14(%ebp)
c010185e:	e8 ce eb ff ff       	call   c0100431 <rb_tree_empty>
c0101863:	83 c4 10             	add    $0x10,%esp
c0101866:	85 c0                	test   %eax,%eax
c0101868:	75 1f                	jne    c0101889 <check_rb_tree+0x578>
c010186a:	8d 83 70 26 fe ff    	lea    -0x1d990(%ebx),%eax
c0101870:	50                   	push   %eax
c0101871:	8d 83 3c 24 fe ff    	lea    -0x1dbc4(%ebx),%eax
c0101877:	50                   	push   %eax
c0101878:	68 00 02 00 00       	push   $0x200
c010187d:	8d 83 51 24 fe ff    	lea    -0x1dbaf(%ebx),%eax
c0101883:	50                   	push   %eax
c0101884:	e8 89 01 00 00       	call   c0101a12 <__panic>

    for (i = 0; i < total; i ++) {
c0101889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101890:	eb 3c                	jmp    c01018ce <check_rb_tree+0x5bd>
        rb_insert(tree, &(all[i]->rb_link));
c0101892:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101895:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010189c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010189f:	01 d0                	add    %edx,%eax
c01018a1:	8b 00                	mov    (%eax),%eax
c01018a3:	83 c0 04             	add    $0x4,%eax
c01018a6:	83 ec 08             	sub    $0x8,%esp
c01018a9:	50                   	push   %eax
c01018aa:	ff 75 ec             	pushl  -0x14(%ebp)
c01018ad:	e8 67 ef ff ff       	call   c0100819 <rb_insert>
c01018b2:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c01018b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018b8:	8b 40 08             	mov    0x8(%eax),%eax
c01018bb:	83 ec 08             	sub    $0x8,%esp
c01018be:	50                   	push   %eax
c01018bf:	ff 75 ec             	pushl  -0x14(%ebp)
c01018c2:	e8 ce f7 ff ff       	call   c0101095 <check_tree>
c01018c7:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c01018ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01018d4:	7c bc                	jl     c0101892 <check_rb_tree+0x581>
    }

    rb_tree_destroy(tree);
c01018d6:	83 ec 0c             	sub    $0xc,%esp
c01018d9:	ff 75 ec             	pushl  -0x14(%ebp)
c01018dc:	e8 67 f6 ff ff       	call   c0100f48 <rb_tree_destroy>
c01018e1:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c01018e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01018eb:	eb 21                	jmp    c010190e <check_rb_tree+0x5fd>
        kfree(all[i]);
c01018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01018f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01018fa:	01 d0                	add    %edx,%eax
c01018fc:	8b 00                	mov    (%eax),%eax
c01018fe:	83 ec 0c             	sub    $0xc,%esp
c0101901:	50                   	push   %eax
c0101902:	e8 e8 4b 00 00       	call   c01064ef <kfree>
c0101907:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c010190a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101911:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101914:	7c d7                	jl     c01018ed <check_rb_tree+0x5dc>
    }

    kfree(mark);
c0101916:	83 ec 0c             	sub    $0xc,%esp
c0101919:	ff 75 d8             	pushl  -0x28(%ebp)
c010191c:	e8 ce 4b 00 00       	call   c01064ef <kfree>
c0101921:	83 c4 10             	add    $0x10,%esp
    kfree(all);
c0101924:	83 ec 0c             	sub    $0xc,%esp
c0101927:	ff 75 dc             	pushl  -0x24(%ebp)
c010192a:	e8 c0 4b 00 00       	call   c01064ef <kfree>
c010192f:	83 c4 10             	add    $0x10,%esp
}
c0101932:	90                   	nop
c0101933:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101936:	5b                   	pop    %ebx
c0101937:	5e                   	pop    %esi
c0101938:	5d                   	pop    %ebp
c0101939:	c3                   	ret    

c010193a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010193a:	55                   	push   %ebp
c010193b:	89 e5                	mov    %esp,%ebp
c010193d:	53                   	push   %ebx
c010193e:	83 ec 14             	sub    $0x14,%esp
c0101941:	e8 7b e9 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0101946:	81 c3 3a 80 02 00    	add    $0x2803a,%ebx
    if (prompt != NULL) {
c010194c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101950:	74 15                	je     c0101967 <readline+0x2d>
        cprintf("%s", prompt);
c0101952:	83 ec 08             	sub    $0x8,%esp
c0101955:	ff 75 08             	pushl  0x8(%ebp)
c0101958:	8d 83 84 26 fe ff    	lea    -0x1d97c(%ebx),%eax
c010195e:	50                   	push   %eax
c010195f:	e8 d0 e9 ff ff       	call   c0100334 <cprintf>
c0101964:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c0101967:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010196e:	e8 70 ea ff ff       	call   c01003e3 <getchar>
c0101973:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0101976:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010197a:	79 0a                	jns    c0101986 <readline+0x4c>
            return NULL;
c010197c:	b8 00 00 00 00       	mov    $0x0,%eax
c0101981:	e9 87 00 00 00       	jmp    c0101a0d <readline+0xd3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0101986:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010198a:	7e 2c                	jle    c01019b8 <readline+0x7e>
c010198c:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0101993:	7f 23                	jg     c01019b8 <readline+0x7e>
            cputchar(c);
c0101995:	83 ec 0c             	sub    $0xc,%esp
c0101998:	ff 75 f0             	pushl  -0x10(%ebp)
c010199b:	e8 c4 e9 ff ff       	call   c0100364 <cputchar>
c01019a0:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c01019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01019a6:	8d 50 01             	lea    0x1(%eax),%edx
c01019a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01019ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01019af:	88 94 03 e0 01 00 00 	mov    %dl,0x1e0(%ebx,%eax,1)
c01019b6:	eb 50                	jmp    c0101a08 <readline+0xce>
        }
        else if (c == '\b' && i > 0) {
c01019b8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01019bc:	75 1a                	jne    c01019d8 <readline+0x9e>
c01019be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01019c2:	7e 14                	jle    c01019d8 <readline+0x9e>
            cputchar(c);
c01019c4:	83 ec 0c             	sub    $0xc,%esp
c01019c7:	ff 75 f0             	pushl  -0x10(%ebp)
c01019ca:	e8 95 e9 ff ff       	call   c0100364 <cputchar>
c01019cf:	83 c4 10             	add    $0x10,%esp
            i --;
c01019d2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01019d6:	eb 30                	jmp    c0101a08 <readline+0xce>
        }
        else if (c == '\n' || c == '\r') {
c01019d8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01019dc:	74 06                	je     c01019e4 <readline+0xaa>
c01019de:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01019e2:	75 8a                	jne    c010196e <readline+0x34>
            cputchar(c);
c01019e4:	83 ec 0c             	sub    $0xc,%esp
c01019e7:	ff 75 f0             	pushl  -0x10(%ebp)
c01019ea:	e8 75 e9 ff ff       	call   c0100364 <cputchar>
c01019ef:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01019f2:	8d 93 e0 01 00 00    	lea    0x1e0(%ebx),%edx
c01019f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01019fb:	01 d0                	add    %edx,%eax
c01019fd:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0101a00:	8d 83 e0 01 00 00    	lea    0x1e0(%ebx),%eax
c0101a06:	eb 05                	jmp    c0101a0d <readline+0xd3>
        c = getchar();
c0101a08:	e9 61 ff ff ff       	jmp    c010196e <readline+0x34>
        }
    }
}
c0101a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101a10:	c9                   	leave  
c0101a11:	c3                   	ret    

c0101a12 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0101a12:	55                   	push   %ebp
c0101a13:	89 e5                	mov    %esp,%ebp
c0101a15:	53                   	push   %ebx
c0101a16:	83 ec 14             	sub    $0x14,%esp
c0101a19:	e8 a3 e8 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0101a1e:	81 c3 62 7f 02 00    	add    $0x27f62,%ebx
    if (is_panic) {
c0101a24:	8b 83 e0 05 00 00    	mov    0x5e0(%ebx),%eax
c0101a2a:	85 c0                	test   %eax,%eax
c0101a2c:	75 4e                	jne    c0101a7c <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0101a2e:	c7 83 e0 05 00 00 01 	movl   $0x1,0x5e0(%ebx)
c0101a35:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0101a38:	8d 45 14             	lea    0x14(%ebp),%eax
c0101a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0101a3e:	83 ec 04             	sub    $0x4,%esp
c0101a41:	ff 75 0c             	pushl  0xc(%ebp)
c0101a44:	ff 75 08             	pushl  0x8(%ebp)
c0101a47:	8d 83 87 26 fe ff    	lea    -0x1d979(%ebx),%eax
c0101a4d:	50                   	push   %eax
c0101a4e:	e8 e1 e8 ff ff       	call   c0100334 <cprintf>
c0101a53:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0101a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a59:	83 ec 08             	sub    $0x8,%esp
c0101a5c:	50                   	push   %eax
c0101a5d:	ff 75 10             	pushl  0x10(%ebp)
c0101a60:	e8 94 e8 ff ff       	call   c01002f9 <vcprintf>
c0101a65:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0101a68:	83 ec 0c             	sub    $0xc,%esp
c0101a6b:	8d 83 a3 26 fe ff    	lea    -0x1d95d(%ebx),%eax
c0101a71:	50                   	push   %eax
c0101a72:	e8 bd e8 ff ff       	call   c0100334 <cprintf>
c0101a77:	83 c4 10             	add    $0x10,%esp
c0101a7a:	eb 01                	jmp    c0101a7d <__panic+0x6b>
        goto panic_dead;
c0101a7c:	90                   	nop
    va_end(ap);

panic_dead:
    intr_disable();
c0101a7d:	e8 fa 1e 00 00       	call   c010397c <intr_disable>
    while (1) {
        kmonitor(NULL);
c0101a82:	83 ec 0c             	sub    $0xc,%esp
c0101a85:	6a 00                	push   $0x0
c0101a87:	e8 fe 08 00 00       	call   c010238a <kmonitor>
c0101a8c:	83 c4 10             	add    $0x10,%esp
c0101a8f:	eb f1                	jmp    c0101a82 <__panic+0x70>

c0101a91 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0101a91:	55                   	push   %ebp
c0101a92:	89 e5                	mov    %esp,%ebp
c0101a94:	53                   	push   %ebx
c0101a95:	83 ec 14             	sub    $0x14,%esp
c0101a98:	e8 24 e8 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0101a9d:	81 c3 e3 7e 02 00    	add    $0x27ee3,%ebx
    va_list ap;
    va_start(ap, fmt);
c0101aa3:	8d 45 14             	lea    0x14(%ebp),%eax
c0101aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0101aa9:	83 ec 04             	sub    $0x4,%esp
c0101aac:	ff 75 0c             	pushl  0xc(%ebp)
c0101aaf:	ff 75 08             	pushl  0x8(%ebp)
c0101ab2:	8d 83 a5 26 fe ff    	lea    -0x1d95b(%ebx),%eax
c0101ab8:	50                   	push   %eax
c0101ab9:	e8 76 e8 ff ff       	call   c0100334 <cprintf>
c0101abe:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0101ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ac4:	83 ec 08             	sub    $0x8,%esp
c0101ac7:	50                   	push   %eax
c0101ac8:	ff 75 10             	pushl  0x10(%ebp)
c0101acb:	e8 29 e8 ff ff       	call   c01002f9 <vcprintf>
c0101ad0:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0101ad3:	83 ec 0c             	sub    $0xc,%esp
c0101ad6:	8d 83 a3 26 fe ff    	lea    -0x1d95d(%ebx),%eax
c0101adc:	50                   	push   %eax
c0101add:	e8 52 e8 ff ff       	call   c0100334 <cprintf>
c0101ae2:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0101ae5:	90                   	nop
c0101ae6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101ae9:	c9                   	leave  
c0101aea:	c3                   	ret    

c0101aeb <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0101aeb:	55                   	push   %ebp
c0101aec:	89 e5                	mov    %esp,%ebp
c0101aee:	e8 ca e7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0101af3:	05 8d 7e 02 00       	add    $0x27e8d,%eax
    return is_panic;
c0101af8:	8b 80 e0 05 00 00    	mov    0x5e0(%eax),%eax
}
c0101afe:	5d                   	pop    %ebp
c0101aff:	c3                   	ret    

c0101b00 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0101b00:	55                   	push   %ebp
c0101b01:	89 e5                	mov    %esp,%ebp
c0101b03:	83 ec 20             	sub    $0x20,%esp
c0101b06:	e8 b2 e7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0101b0b:	05 75 7e 02 00       	add    $0x27e75,%eax
    int l = *region_left, r = *region_right, any_matches = 0;
c0101b10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b13:	8b 00                	mov    (%eax),%eax
c0101b15:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101b18:	8b 45 10             	mov    0x10(%ebp),%eax
c0101b1b:	8b 00                	mov    (%eax),%eax
c0101b1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101b20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0101b27:	e9 d2 00 00 00       	jmp    c0101bfe <stab_binsearch+0xfe>
        int true_m = (l + r) / 2, m = true_m;
c0101b2c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101b2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b32:	01 d0                	add    %edx,%eax
c0101b34:	89 c2                	mov    %eax,%edx
c0101b36:	c1 ea 1f             	shr    $0x1f,%edx
c0101b39:	01 d0                	add    %edx,%eax
c0101b3b:	d1 f8                	sar    %eax
c0101b3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b43:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0101b46:	eb 04                	jmp    c0101b4c <stab_binsearch+0x4c>
            m --;
c0101b48:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0101b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b4f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101b52:	7c 1f                	jl     c0101b73 <stab_binsearch+0x73>
c0101b54:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101b57:	89 d0                	mov    %edx,%eax
c0101b59:	01 c0                	add    %eax,%eax
c0101b5b:	01 d0                	add    %edx,%eax
c0101b5d:	c1 e0 02             	shl    $0x2,%eax
c0101b60:	89 c2                	mov    %eax,%edx
c0101b62:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b65:	01 d0                	add    %edx,%eax
c0101b67:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101b6b:	0f b6 c0             	movzbl %al,%eax
c0101b6e:	39 45 14             	cmp    %eax,0x14(%ebp)
c0101b71:	75 d5                	jne    c0101b48 <stab_binsearch+0x48>
        }
        if (m < l) {    // no match in [l, m]
c0101b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b76:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101b79:	7d 0b                	jge    c0101b86 <stab_binsearch+0x86>
            l = true_m + 1;
c0101b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b7e:	83 c0 01             	add    $0x1,%eax
c0101b81:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0101b84:	eb 78                	jmp    c0101bfe <stab_binsearch+0xfe>
        }

        // actual binary search
        any_matches = 1;
c0101b86:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0101b8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101b90:	89 d0                	mov    %edx,%eax
c0101b92:	01 c0                	add    %eax,%eax
c0101b94:	01 d0                	add    %edx,%eax
c0101b96:	c1 e0 02             	shl    $0x2,%eax
c0101b99:	89 c2                	mov    %eax,%edx
c0101b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9e:	01 d0                	add    %edx,%eax
c0101ba0:	8b 40 08             	mov    0x8(%eax),%eax
c0101ba3:	39 45 18             	cmp    %eax,0x18(%ebp)
c0101ba6:	76 13                	jbe    c0101bbb <stab_binsearch+0xbb>
            *region_left = m;
c0101ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bab:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101bae:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0101bb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101bb3:	83 c0 01             	add    $0x1,%eax
c0101bb6:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101bb9:	eb 43                	jmp    c0101bfe <stab_binsearch+0xfe>
        } else if (stabs[m].n_value > addr) {
c0101bbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101bbe:	89 d0                	mov    %edx,%eax
c0101bc0:	01 c0                	add    %eax,%eax
c0101bc2:	01 d0                	add    %edx,%eax
c0101bc4:	c1 e0 02             	shl    $0x2,%eax
c0101bc7:	89 c2                	mov    %eax,%edx
c0101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcc:	01 d0                	add    %edx,%eax
c0101bce:	8b 40 08             	mov    0x8(%eax),%eax
c0101bd1:	39 45 18             	cmp    %eax,0x18(%ebp)
c0101bd4:	73 16                	jae    c0101bec <stab_binsearch+0xec>
            *region_right = m - 1;
c0101bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bd9:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101bdc:	8b 45 10             	mov    0x10(%ebp),%eax
c0101bdf:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0101be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101be4:	83 e8 01             	sub    $0x1,%eax
c0101be7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101bea:	eb 12                	jmp    c0101bfe <stab_binsearch+0xfe>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0101bec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bef:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101bf2:	89 10                	mov    %edx,(%eax)
            l = m;
c0101bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bf7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0101bfa:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c0101bfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101c01:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0101c04:	0f 8e 22 ff ff ff    	jle    c0101b2c <stab_binsearch+0x2c>
        }
    }

    if (!any_matches) {
c0101c0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101c0e:	75 0f                	jne    c0101c1f <stab_binsearch+0x11f>
        *region_right = *region_left - 1;
c0101c10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c13:	8b 00                	mov    (%eax),%eax
c0101c15:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101c18:	8b 45 10             	mov    0x10(%ebp),%eax
c0101c1b:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0101c1d:	eb 3f                	jmp    c0101c5e <stab_binsearch+0x15e>
        l = *region_right;
c0101c1f:	8b 45 10             	mov    0x10(%ebp),%eax
c0101c22:	8b 00                	mov    (%eax),%eax
c0101c24:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0101c27:	eb 04                	jmp    c0101c2d <stab_binsearch+0x12d>
c0101c29:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0101c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c30:	8b 00                	mov    (%eax),%eax
c0101c32:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0101c35:	7e 1f                	jle    c0101c56 <stab_binsearch+0x156>
c0101c37:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101c3a:	89 d0                	mov    %edx,%eax
c0101c3c:	01 c0                	add    %eax,%eax
c0101c3e:	01 d0                	add    %edx,%eax
c0101c40:	c1 e0 02             	shl    $0x2,%eax
c0101c43:	89 c2                	mov    %eax,%edx
c0101c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c48:	01 d0                	add    %edx,%eax
c0101c4a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c4e:	0f b6 c0             	movzbl %al,%eax
c0101c51:	39 45 14             	cmp    %eax,0x14(%ebp)
c0101c54:	75 d3                	jne    c0101c29 <stab_binsearch+0x129>
        *region_left = l;
c0101c56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c59:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101c5c:	89 10                	mov    %edx,(%eax)
}
c0101c5e:	90                   	nop
c0101c5f:	c9                   	leave  
c0101c60:	c3                   	ret    

c0101c61 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0101c61:	55                   	push   %ebp
c0101c62:	89 e5                	mov    %esp,%ebp
c0101c64:	53                   	push   %ebx
c0101c65:	83 ec 34             	sub    $0x34,%esp
c0101c68:	e8 54 e6 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0101c6d:	81 c3 13 7d 02 00    	add    $0x27d13,%ebx
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0101c73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c76:	8d 93 c4 26 fe ff    	lea    -0x1d93c(%ebx),%edx
c0101c7c:	89 10                	mov    %edx,(%eax)
    info->eip_line = 0;
c0101c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c81:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0101c88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c8b:	8d 93 c4 26 fe ff    	lea    -0x1d93c(%ebx),%edx
c0101c91:	89 50 08             	mov    %edx,0x8(%eax)
    info->eip_fn_namelen = 9;
c0101c94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c97:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0101c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ca1:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ca4:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0101ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101caa:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0101cb1:	c7 c0 0c e1 10 c0    	mov    $0xc010e10c,%eax
c0101cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    stab_end = __STAB_END__;
c0101cba:	c7 c0 58 18 12 c0    	mov    $0xc0121858,%eax
c0101cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0101cc3:	c7 c0 59 18 12 c0    	mov    $0xc0121859,%eax
c0101cc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0101ccc:	c7 c0 58 66 12 c0    	mov    $0xc0126658,%eax
c0101cd2:	89 45 e8             	mov    %eax,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0101cd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101cd8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0101cdb:	76 0d                	jbe    c0101cea <debuginfo_eip+0x89>
c0101cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101ce0:	83 e8 01             	sub    $0x1,%eax
c0101ce3:	0f b6 00             	movzbl (%eax),%eax
c0101ce6:	84 c0                	test   %al,%al
c0101ce8:	74 0a                	je     c0101cf4 <debuginfo_eip+0x93>
        return -1;
c0101cea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cef:	e9 91 02 00 00       	jmp    c0101f85 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0101cf4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0101cfb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d01:	29 c2                	sub    %eax,%edx
c0101d03:	89 d0                	mov    %edx,%eax
c0101d05:	c1 f8 02             	sar    $0x2,%eax
c0101d08:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0101d0e:	83 e8 01             	sub    $0x1,%eax
c0101d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0101d14:	ff 75 08             	pushl  0x8(%ebp)
c0101d17:	6a 64                	push   $0x64
c0101d19:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0101d1c:	50                   	push   %eax
c0101d1d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0101d20:	50                   	push   %eax
c0101d21:	ff 75 f4             	pushl  -0xc(%ebp)
c0101d24:	e8 d7 fd ff ff       	call   c0101b00 <stab_binsearch>
c0101d29:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c0101d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101d2f:	85 c0                	test   %eax,%eax
c0101d31:	75 0a                	jne    c0101d3d <debuginfo_eip+0xdc>
        return -1;
c0101d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d38:	e9 48 02 00 00       	jmp    c0101f85 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0101d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101d40:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101d43:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101d46:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0101d49:	ff 75 08             	pushl  0x8(%ebp)
c0101d4c:	6a 24                	push   $0x24
c0101d4e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0101d51:	50                   	push   %eax
c0101d52:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101d55:	50                   	push   %eax
c0101d56:	ff 75 f4             	pushl  -0xc(%ebp)
c0101d59:	e8 a2 fd ff ff       	call   c0101b00 <stab_binsearch>
c0101d5e:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c0101d61:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101d64:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101d67:	39 c2                	cmp    %eax,%edx
c0101d69:	7f 7c                	jg     c0101de7 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0101d6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101d6e:	89 c2                	mov    %eax,%edx
c0101d70:	89 d0                	mov    %edx,%eax
c0101d72:	01 c0                	add    %eax,%eax
c0101d74:	01 d0                	add    %edx,%eax
c0101d76:	c1 e0 02             	shl    $0x2,%eax
c0101d79:	89 c2                	mov    %eax,%edx
c0101d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d7e:	01 d0                	add    %edx,%eax
c0101d80:	8b 00                	mov    (%eax),%eax
c0101d82:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101d85:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101d88:	29 d1                	sub    %edx,%ecx
c0101d8a:	89 ca                	mov    %ecx,%edx
c0101d8c:	39 d0                	cmp    %edx,%eax
c0101d8e:	73 22                	jae    c0101db2 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0101d90:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101d93:	89 c2                	mov    %eax,%edx
c0101d95:	89 d0                	mov    %edx,%eax
c0101d97:	01 c0                	add    %eax,%eax
c0101d99:	01 d0                	add    %edx,%eax
c0101d9b:	c1 e0 02             	shl    $0x2,%eax
c0101d9e:	89 c2                	mov    %eax,%edx
c0101da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101da3:	01 d0                	add    %edx,%eax
c0101da5:	8b 10                	mov    (%eax),%edx
c0101da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101daa:	01 c2                	add    %eax,%edx
c0101dac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101daf:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0101db2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101db5:	89 c2                	mov    %eax,%edx
c0101db7:	89 d0                	mov    %edx,%eax
c0101db9:	01 c0                	add    %eax,%eax
c0101dbb:	01 d0                	add    %edx,%eax
c0101dbd:	c1 e0 02             	shl    $0x2,%eax
c0101dc0:	89 c2                	mov    %eax,%edx
c0101dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101dc5:	01 d0                	add    %edx,%eax
c0101dc7:	8b 50 08             	mov    0x8(%eax),%edx
c0101dca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101dcd:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0101dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101dd3:	8b 40 10             	mov    0x10(%eax),%eax
c0101dd6:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0101dd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101ddc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0101ddf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101de2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101de5:	eb 15                	jmp    c0101dfc <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0101de7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101dea:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ded:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0101df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101df3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0101df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101df9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0101dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101dff:	8b 40 08             	mov    0x8(%eax),%eax
c0101e02:	83 ec 08             	sub    $0x8,%esp
c0101e05:	6a 3a                	push   $0x3a
c0101e07:	50                   	push   %eax
c0101e08:	e8 ff 93 00 00       	call   c010b20c <strfind>
c0101e0d:	83 c4 10             	add    $0x10,%esp
c0101e10:	89 c2                	mov    %eax,%edx
c0101e12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e15:	8b 40 08             	mov    0x8(%eax),%eax
c0101e18:	29 c2                	sub    %eax,%edx
c0101e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e1d:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0101e20:	83 ec 0c             	sub    $0xc,%esp
c0101e23:	ff 75 08             	pushl  0x8(%ebp)
c0101e26:	6a 44                	push   $0x44
c0101e28:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0101e2b:	50                   	push   %eax
c0101e2c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0101e2f:	50                   	push   %eax
c0101e30:	ff 75 f4             	pushl  -0xc(%ebp)
c0101e33:	e8 c8 fc ff ff       	call   c0101b00 <stab_binsearch>
c0101e38:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c0101e3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101e3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101e41:	39 c2                	cmp    %eax,%edx
c0101e43:	7f 24                	jg     c0101e69 <debuginfo_eip+0x208>
        info->eip_line = stabs[rline].n_desc;
c0101e45:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101e48:	89 c2                	mov    %eax,%edx
c0101e4a:	89 d0                	mov    %edx,%eax
c0101e4c:	01 c0                	add    %eax,%eax
c0101e4e:	01 d0                	add    %edx,%eax
c0101e50:	c1 e0 02             	shl    $0x2,%eax
c0101e53:	89 c2                	mov    %eax,%edx
c0101e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e58:	01 d0                	add    %edx,%eax
c0101e5a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101e5e:	0f b7 d0             	movzwl %ax,%edx
c0101e61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e64:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101e67:	eb 13                	jmp    c0101e7c <debuginfo_eip+0x21b>
        return -1;
c0101e69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101e6e:	e9 12 01 00 00       	jmp    c0101f85 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0101e73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101e76:	83 e8 01             	sub    $0x1,%eax
c0101e79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0101e7c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101e7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101e82:	39 c2                	cmp    %eax,%edx
c0101e84:	7c 56                	jl     c0101edc <debuginfo_eip+0x27b>
           && stabs[lline].n_type != N_SOL
c0101e86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101e89:	89 c2                	mov    %eax,%edx
c0101e8b:	89 d0                	mov    %edx,%eax
c0101e8d:	01 c0                	add    %eax,%eax
c0101e8f:	01 d0                	add    %edx,%eax
c0101e91:	c1 e0 02             	shl    $0x2,%eax
c0101e94:	89 c2                	mov    %eax,%edx
c0101e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e99:	01 d0                	add    %edx,%eax
c0101e9b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101e9f:	3c 84                	cmp    $0x84,%al
c0101ea1:	74 39                	je     c0101edc <debuginfo_eip+0x27b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0101ea3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101ea6:	89 c2                	mov    %eax,%edx
c0101ea8:	89 d0                	mov    %edx,%eax
c0101eaa:	01 c0                	add    %eax,%eax
c0101eac:	01 d0                	add    %edx,%eax
c0101eae:	c1 e0 02             	shl    $0x2,%eax
c0101eb1:	89 c2                	mov    %eax,%edx
c0101eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101eb6:	01 d0                	add    %edx,%eax
c0101eb8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101ebc:	3c 64                	cmp    $0x64,%al
c0101ebe:	75 b3                	jne    c0101e73 <debuginfo_eip+0x212>
c0101ec0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101ec3:	89 c2                	mov    %eax,%edx
c0101ec5:	89 d0                	mov    %edx,%eax
c0101ec7:	01 c0                	add    %eax,%eax
c0101ec9:	01 d0                	add    %edx,%eax
c0101ecb:	c1 e0 02             	shl    $0x2,%eax
c0101ece:	89 c2                	mov    %eax,%edx
c0101ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ed3:	01 d0                	add    %edx,%eax
c0101ed5:	8b 40 08             	mov    0x8(%eax),%eax
c0101ed8:	85 c0                	test   %eax,%eax
c0101eda:	74 97                	je     c0101e73 <debuginfo_eip+0x212>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0101edc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101ee2:	39 c2                	cmp    %eax,%edx
c0101ee4:	7c 46                	jl     c0101f2c <debuginfo_eip+0x2cb>
c0101ee6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101ee9:	89 c2                	mov    %eax,%edx
c0101eeb:	89 d0                	mov    %edx,%eax
c0101eed:	01 c0                	add    %eax,%eax
c0101eef:	01 d0                	add    %edx,%eax
c0101ef1:	c1 e0 02             	shl    $0x2,%eax
c0101ef4:	89 c2                	mov    %eax,%edx
c0101ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ef9:	01 d0                	add    %edx,%eax
c0101efb:	8b 00                	mov    (%eax),%eax
c0101efd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101f00:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101f03:	29 d1                	sub    %edx,%ecx
c0101f05:	89 ca                	mov    %ecx,%edx
c0101f07:	39 d0                	cmp    %edx,%eax
c0101f09:	73 21                	jae    c0101f2c <debuginfo_eip+0x2cb>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0101f0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101f0e:	89 c2                	mov    %eax,%edx
c0101f10:	89 d0                	mov    %edx,%eax
c0101f12:	01 c0                	add    %eax,%eax
c0101f14:	01 d0                	add    %edx,%eax
c0101f16:	c1 e0 02             	shl    $0x2,%eax
c0101f19:	89 c2                	mov    %eax,%edx
c0101f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f1e:	01 d0                	add    %edx,%eax
c0101f20:	8b 10                	mov    (%eax),%edx
c0101f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f25:	01 c2                	add    %eax,%edx
c0101f27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f2a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0101f2c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101f2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101f32:	39 c2                	cmp    %eax,%edx
c0101f34:	7d 4a                	jge    c0101f80 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c0101f36:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101f39:	83 c0 01             	add    $0x1,%eax
c0101f3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101f3f:	eb 18                	jmp    c0101f59 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0101f41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f44:	8b 40 14             	mov    0x14(%eax),%eax
c0101f47:	8d 50 01             	lea    0x1(%eax),%edx
c0101f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f4d:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0101f50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101f53:	83 c0 01             	add    $0x1,%eax
c0101f56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101f59:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101f5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0101f5f:	39 c2                	cmp    %eax,%edx
c0101f61:	7d 1d                	jge    c0101f80 <debuginfo_eip+0x31f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101f63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101f66:	89 c2                	mov    %eax,%edx
c0101f68:	89 d0                	mov    %edx,%eax
c0101f6a:	01 c0                	add    %eax,%eax
c0101f6c:	01 d0                	add    %edx,%eax
c0101f6e:	c1 e0 02             	shl    $0x2,%eax
c0101f71:	89 c2                	mov    %eax,%edx
c0101f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f76:	01 d0                	add    %edx,%eax
c0101f78:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101f7c:	3c a0                	cmp    $0xa0,%al
c0101f7e:	74 c1                	je     c0101f41 <debuginfo_eip+0x2e0>
        }
    }
    return 0;
c0101f80:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101f85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101f88:	c9                   	leave  
c0101f89:	c3                   	ret    

c0101f8a <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0101f8a:	55                   	push   %ebp
c0101f8b:	89 e5                	mov    %esp,%ebp
c0101f8d:	53                   	push   %ebx
c0101f8e:	83 ec 04             	sub    $0x4,%esp
c0101f91:	e8 2b e3 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0101f96:	81 c3 ea 79 02 00    	add    $0x279ea,%ebx
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0101f9c:	83 ec 0c             	sub    $0xc,%esp
c0101f9f:	8d 83 ce 26 fe ff    	lea    -0x1d932(%ebx),%eax
c0101fa5:	50                   	push   %eax
c0101fa6:	e8 89 e3 ff ff       	call   c0100334 <cprintf>
c0101fab:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0101fae:	83 ec 08             	sub    $0x8,%esp
c0101fb1:	c7 c0 2a 00 10 c0    	mov    $0xc010002a,%eax
c0101fb7:	50                   	push   %eax
c0101fb8:	8d 83 e7 26 fe ff    	lea    -0x1d919(%ebx),%eax
c0101fbe:	50                   	push   %eax
c0101fbf:	e8 70 e3 ff ff       	call   c0100334 <cprintf>
c0101fc4:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0101fc7:	83 ec 08             	sub    $0x8,%esp
c0101fca:	c7 c0 03 bd 10 c0    	mov    $0xc010bd03,%eax
c0101fd0:	50                   	push   %eax
c0101fd1:	8d 83 ff 26 fe ff    	lea    -0x1d901(%ebx),%eax
c0101fd7:	50                   	push   %eax
c0101fd8:	e8 57 e3 ff ff       	call   c0100334 <cprintf>
c0101fdd:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0101fe0:	83 ec 08             	sub    $0x8,%esp
c0101fe3:	c7 c0 80 99 12 c0    	mov    $0xc0129980,%eax
c0101fe9:	50                   	push   %eax
c0101fea:	8d 83 17 27 fe ff    	lea    -0x1d8e9(%ebx),%eax
c0101ff0:	50                   	push   %eax
c0101ff1:	e8 3e e3 ff ff       	call   c0100334 <cprintf>
c0101ff6:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0101ff9:	83 ec 08             	sub    $0x8,%esp
c0101ffc:	c7 c0 a4 cc 12 c0    	mov    $0xc012cca4,%eax
c0102002:	50                   	push   %eax
c0102003:	8d 83 2f 27 fe ff    	lea    -0x1d8d1(%ebx),%eax
c0102009:	50                   	push   %eax
c010200a:	e8 25 e3 ff ff       	call   c0100334 <cprintf>
c010200f:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0102012:	c7 c0 a4 cc 12 c0    	mov    $0xc012cca4,%eax
c0102018:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c010201e:	c7 c0 2a 00 10 c0    	mov    $0xc010002a,%eax
c0102024:	29 c2                	sub    %eax,%edx
c0102026:	89 d0                	mov    %edx,%eax
c0102028:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c010202e:	85 c0                	test   %eax,%eax
c0102030:	0f 48 c2             	cmovs  %edx,%eax
c0102033:	c1 f8 0a             	sar    $0xa,%eax
c0102036:	83 ec 08             	sub    $0x8,%esp
c0102039:	50                   	push   %eax
c010203a:	8d 83 48 27 fe ff    	lea    -0x1d8b8(%ebx),%eax
c0102040:	50                   	push   %eax
c0102041:	e8 ee e2 ff ff       	call   c0100334 <cprintf>
c0102046:	83 c4 10             	add    $0x10,%esp
}
c0102049:	90                   	nop
c010204a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010204d:	c9                   	leave  
c010204e:	c3                   	ret    

c010204f <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010204f:	55                   	push   %ebp
c0102050:	89 e5                	mov    %esp,%ebp
c0102052:	53                   	push   %ebx
c0102053:	81 ec 24 01 00 00    	sub    $0x124,%esp
c0102059:	e8 63 e2 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010205e:	81 c3 22 79 02 00    	add    $0x27922,%ebx
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0102064:	83 ec 08             	sub    $0x8,%esp
c0102067:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010206a:	50                   	push   %eax
c010206b:	ff 75 08             	pushl  0x8(%ebp)
c010206e:	e8 ee fb ff ff       	call   c0101c61 <debuginfo_eip>
c0102073:	83 c4 10             	add    $0x10,%esp
c0102076:	85 c0                	test   %eax,%eax
c0102078:	74 17                	je     c0102091 <print_debuginfo+0x42>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010207a:	83 ec 08             	sub    $0x8,%esp
c010207d:	ff 75 08             	pushl  0x8(%ebp)
c0102080:	8d 83 72 27 fe ff    	lea    -0x1d88e(%ebx),%eax
c0102086:	50                   	push   %eax
c0102087:	e8 a8 e2 ff ff       	call   c0100334 <cprintf>
c010208c:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010208f:	eb 67                	jmp    c01020f8 <print_debuginfo+0xa9>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0102091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102098:	eb 1c                	jmp    c01020b6 <print_debuginfo+0x67>
            fnname[j] = info.eip_fn_name[j];
c010209a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010209d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01020a0:	01 d0                	add    %edx,%eax
c01020a2:	0f b6 00             	movzbl (%eax),%eax
c01020a5:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01020ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01020ae:	01 ca                	add    %ecx,%edx
c01020b0:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01020b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01020b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01020b9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01020bc:	7c dc                	jl     c010209a <print_debuginfo+0x4b>
        fnname[j] = '\0';
c01020be:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c01020c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01020c7:	01 d0                	add    %edx,%eax
c01020c9:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c01020cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c01020cf:	8b 55 08             	mov    0x8(%ebp),%edx
c01020d2:	89 d1                	mov    %edx,%ecx
c01020d4:	29 c1                	sub    %eax,%ecx
c01020d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01020d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01020dc:	83 ec 0c             	sub    $0xc,%esp
c01020df:	51                   	push   %ecx
c01020e0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01020e6:	51                   	push   %ecx
c01020e7:	52                   	push   %edx
c01020e8:	50                   	push   %eax
c01020e9:	8d 83 8e 27 fe ff    	lea    -0x1d872(%ebx),%eax
c01020ef:	50                   	push   %eax
c01020f0:	e8 3f e2 ff ff       	call   c0100334 <cprintf>
c01020f5:	83 c4 20             	add    $0x20,%esp
}
c01020f8:	90                   	nop
c01020f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01020fc:	c9                   	leave  
c01020fd:	c3                   	ret    

c01020fe <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01020fe:	55                   	push   %ebp
c01020ff:	89 e5                	mov    %esp,%ebp
c0102101:	83 ec 10             	sub    $0x10,%esp
c0102104:	e8 b4 e1 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102109:	05 77 78 02 00       	add    $0x27877,%eax
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c010210e:	8b 45 04             	mov    0x4(%ebp),%eax
c0102111:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0102114:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0102117:	c9                   	leave  
c0102118:	c3                   	ret    

c0102119 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0102119:	55                   	push   %ebp
c010211a:	89 e5                	mov    %esp,%ebp
c010211c:	53                   	push   %ebx
c010211d:	83 ec 24             	sub    $0x24,%esp
c0102120:	e8 9c e1 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0102125:	81 c3 5b 78 02 00    	add    $0x2785b,%ebx
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c010212b:	89 e8                	mov    %ebp,%eax
c010212d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0102130:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0102133:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102136:	e8 c3 ff ff ff       	call   c01020fe <read_eip>
c010213b:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c010213e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102145:	e9 93 00 00 00       	jmp    c01021dd <print_stackframe+0xc4>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c010214a:	83 ec 04             	sub    $0x4,%esp
c010214d:	ff 75 f0             	pushl  -0x10(%ebp)
c0102150:	ff 75 f4             	pushl  -0xc(%ebp)
c0102153:	8d 83 a0 27 fe ff    	lea    -0x1d860(%ebx),%eax
c0102159:	50                   	push   %eax
c010215a:	e8 d5 e1 ff ff       	call   c0100334 <cprintf>
c010215f:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0102162:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102165:	83 c0 08             	add    $0x8,%eax
c0102168:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c010216b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0102172:	eb 28                	jmp    c010219c <print_stackframe+0x83>
            cprintf("0x%08x ", args[j]);
c0102174:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102177:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010217e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102181:	01 d0                	add    %edx,%eax
c0102183:	8b 00                	mov    (%eax),%eax
c0102185:	83 ec 08             	sub    $0x8,%esp
c0102188:	50                   	push   %eax
c0102189:	8d 83 bc 27 fe ff    	lea    -0x1d844(%ebx),%eax
c010218f:	50                   	push   %eax
c0102190:	e8 9f e1 ff ff       	call   c0100334 <cprintf>
c0102195:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j ++) {
c0102198:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c010219c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c01021a0:	7e d2                	jle    c0102174 <print_stackframe+0x5b>
        }
        cprintf("\n");
c01021a2:	83 ec 0c             	sub    $0xc,%esp
c01021a5:	8d 83 c4 27 fe ff    	lea    -0x1d83c(%ebx),%eax
c01021ab:	50                   	push   %eax
c01021ac:	e8 83 e1 ff ff       	call   c0100334 <cprintf>
c01021b1:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c01021b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01021b7:	83 e8 01             	sub    $0x1,%eax
c01021ba:	83 ec 0c             	sub    $0xc,%esp
c01021bd:	50                   	push   %eax
c01021be:	e8 8c fe ff ff       	call   c010204f <print_debuginfo>
c01021c3:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c01021c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01021c9:	83 c0 04             	add    $0x4,%eax
c01021cc:	8b 00                	mov    (%eax),%eax
c01021ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c01021d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01021d4:	8b 00                	mov    (%eax),%eax
c01021d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01021d9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01021dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01021e1:	74 0a                	je     c01021ed <print_stackframe+0xd4>
c01021e3:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c01021e7:	0f 8e 5d ff ff ff    	jle    c010214a <print_stackframe+0x31>
    }
}
c01021ed:	90                   	nop
c01021ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01021f1:	c9                   	leave  
c01021f2:	c3                   	ret    

c01021f3 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c01021f3:	55                   	push   %ebp
c01021f4:	89 e5                	mov    %esp,%ebp
c01021f6:	53                   	push   %ebx
c01021f7:	83 ec 14             	sub    $0x14,%esp
c01021fa:	e8 c2 e0 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01021ff:	81 c3 81 77 02 00    	add    $0x27781,%ebx
    int argc = 0;
c0102205:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c010220c:	eb 0c                	jmp    c010221a <parse+0x27>
            *buf ++ = '\0';
c010220e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102211:	8d 50 01             	lea    0x1(%eax),%edx
c0102214:	89 55 08             	mov    %edx,0x8(%ebp)
c0102217:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c010221a:	8b 45 08             	mov    0x8(%ebp),%eax
c010221d:	0f b6 00             	movzbl (%eax),%eax
c0102220:	84 c0                	test   %al,%al
c0102222:	74 20                	je     c0102244 <parse+0x51>
c0102224:	8b 45 08             	mov    0x8(%ebp),%eax
c0102227:	0f b6 00             	movzbl (%eax),%eax
c010222a:	0f be c0             	movsbl %al,%eax
c010222d:	83 ec 08             	sub    $0x8,%esp
c0102230:	50                   	push   %eax
c0102231:	8d 83 48 28 fe ff    	lea    -0x1d7b8(%ebx),%eax
c0102237:	50                   	push   %eax
c0102238:	e8 92 8f 00 00       	call   c010b1cf <strchr>
c010223d:	83 c4 10             	add    $0x10,%esp
c0102240:	85 c0                	test   %eax,%eax
c0102242:	75 ca                	jne    c010220e <parse+0x1b>
        }
        if (*buf == '\0') {
c0102244:	8b 45 08             	mov    0x8(%ebp),%eax
c0102247:	0f b6 00             	movzbl (%eax),%eax
c010224a:	84 c0                	test   %al,%al
c010224c:	74 69                	je     c01022b7 <parse+0xc4>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c010224e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0102252:	75 14                	jne    c0102268 <parse+0x75>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0102254:	83 ec 08             	sub    $0x8,%esp
c0102257:	6a 10                	push   $0x10
c0102259:	8d 83 4d 28 fe ff    	lea    -0x1d7b3(%ebx),%eax
c010225f:	50                   	push   %eax
c0102260:	e8 cf e0 ff ff       	call   c0100334 <cprintf>
c0102265:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0102268:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010226b:	8d 50 01             	lea    0x1(%eax),%edx
c010226e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0102271:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0102278:	8b 45 0c             	mov    0xc(%ebp),%eax
c010227b:	01 c2                	add    %eax,%edx
c010227d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102280:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0102282:	eb 04                	jmp    c0102288 <parse+0x95>
            buf ++;
c0102284:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0102288:	8b 45 08             	mov    0x8(%ebp),%eax
c010228b:	0f b6 00             	movzbl (%eax),%eax
c010228e:	84 c0                	test   %al,%al
c0102290:	74 88                	je     c010221a <parse+0x27>
c0102292:	8b 45 08             	mov    0x8(%ebp),%eax
c0102295:	0f b6 00             	movzbl (%eax),%eax
c0102298:	0f be c0             	movsbl %al,%eax
c010229b:	83 ec 08             	sub    $0x8,%esp
c010229e:	50                   	push   %eax
c010229f:	8d 83 48 28 fe ff    	lea    -0x1d7b8(%ebx),%eax
c01022a5:	50                   	push   %eax
c01022a6:	e8 24 8f 00 00       	call   c010b1cf <strchr>
c01022ab:	83 c4 10             	add    $0x10,%esp
c01022ae:	85 c0                	test   %eax,%eax
c01022b0:	74 d2                	je     c0102284 <parse+0x91>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01022b2:	e9 63 ff ff ff       	jmp    c010221a <parse+0x27>
            break;
c01022b7:	90                   	nop
        }
    }
    return argc;
c01022b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01022bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01022be:	c9                   	leave  
c01022bf:	c3                   	ret    

c01022c0 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c01022c0:	55                   	push   %ebp
c01022c1:	89 e5                	mov    %esp,%ebp
c01022c3:	56                   	push   %esi
c01022c4:	53                   	push   %ebx
c01022c5:	83 ec 50             	sub    $0x50,%esp
c01022c8:	e8 f4 df ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01022cd:	81 c3 b3 76 02 00    	add    $0x276b3,%ebx
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c01022d3:	83 ec 08             	sub    $0x8,%esp
c01022d6:	8d 45 b0             	lea    -0x50(%ebp),%eax
c01022d9:	50                   	push   %eax
c01022da:	ff 75 08             	pushl  0x8(%ebp)
c01022dd:	e8 11 ff ff ff       	call   c01021f3 <parse>
c01022e2:	83 c4 10             	add    $0x10,%esp
c01022e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c01022e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01022ec:	75 0a                	jne    c01022f8 <runcmd+0x38>
        return 0;
c01022ee:	b8 00 00 00 00       	mov    $0x0,%eax
c01022f3:	e9 8b 00 00 00       	jmp    c0102383 <runcmd+0xc3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c01022f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01022ff:	eb 5f                	jmp    c0102360 <runcmd+0xa0>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0102301:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0102304:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102307:	8d b3 20 00 00 00    	lea    0x20(%ebx),%esi
c010230d:	89 d0                	mov    %edx,%eax
c010230f:	01 c0                	add    %eax,%eax
c0102311:	01 d0                	add    %edx,%eax
c0102313:	c1 e0 02             	shl    $0x2,%eax
c0102316:	01 f0                	add    %esi,%eax
c0102318:	8b 00                	mov    (%eax),%eax
c010231a:	83 ec 08             	sub    $0x8,%esp
c010231d:	51                   	push   %ecx
c010231e:	50                   	push   %eax
c010231f:	e8 f7 8d 00 00       	call   c010b11b <strcmp>
c0102324:	83 c4 10             	add    $0x10,%esp
c0102327:	85 c0                	test   %eax,%eax
c0102329:	75 31                	jne    c010235c <runcmd+0x9c>
            return commands[i].func(argc - 1, argv + 1, tf);
c010232b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010232e:	8d 8b 28 00 00 00    	lea    0x28(%ebx),%ecx
c0102334:	89 d0                	mov    %edx,%eax
c0102336:	01 c0                	add    %eax,%eax
c0102338:	01 d0                	add    %edx,%eax
c010233a:	c1 e0 02             	shl    $0x2,%eax
c010233d:	01 c8                	add    %ecx,%eax
c010233f:	8b 10                	mov    (%eax),%edx
c0102341:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0102344:	83 c0 04             	add    $0x4,%eax
c0102347:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010234a:	83 e9 01             	sub    $0x1,%ecx
c010234d:	83 ec 04             	sub    $0x4,%esp
c0102350:	ff 75 0c             	pushl  0xc(%ebp)
c0102353:	50                   	push   %eax
c0102354:	51                   	push   %ecx
c0102355:	ff d2                	call   *%edx
c0102357:	83 c4 10             	add    $0x10,%esp
c010235a:	eb 27                	jmp    c0102383 <runcmd+0xc3>
    for (i = 0; i < NCOMMANDS; i ++) {
c010235c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102360:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102363:	83 f8 02             	cmp    $0x2,%eax
c0102366:	76 99                	jbe    c0102301 <runcmd+0x41>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0102368:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010236b:	83 ec 08             	sub    $0x8,%esp
c010236e:	50                   	push   %eax
c010236f:	8d 83 6b 28 fe ff    	lea    -0x1d795(%ebx),%eax
c0102375:	50                   	push   %eax
c0102376:	e8 b9 df ff ff       	call   c0100334 <cprintf>
c010237b:	83 c4 10             	add    $0x10,%esp
    return 0;
c010237e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102383:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102386:	5b                   	pop    %ebx
c0102387:	5e                   	pop    %esi
c0102388:	5d                   	pop    %ebp
c0102389:	c3                   	ret    

c010238a <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c010238a:	55                   	push   %ebp
c010238b:	89 e5                	mov    %esp,%ebp
c010238d:	53                   	push   %ebx
c010238e:	83 ec 14             	sub    $0x14,%esp
c0102391:	e8 2b df ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0102396:	81 c3 ea 75 02 00    	add    $0x275ea,%ebx
    cprintf("Welcome to the kernel debug monitor!!\n");
c010239c:	83 ec 0c             	sub    $0xc,%esp
c010239f:	8d 83 84 28 fe ff    	lea    -0x1d77c(%ebx),%eax
c01023a5:	50                   	push   %eax
c01023a6:	e8 89 df ff ff       	call   c0100334 <cprintf>
c01023ab:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c01023ae:	83 ec 0c             	sub    $0xc,%esp
c01023b1:	8d 83 ac 28 fe ff    	lea    -0x1d754(%ebx),%eax
c01023b7:	50                   	push   %eax
c01023b8:	e8 77 df ff ff       	call   c0100334 <cprintf>
c01023bd:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c01023c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01023c4:	74 0e                	je     c01023d4 <kmonitor+0x4a>
        print_trapframe(tf);
c01023c6:	83 ec 0c             	sub    $0xc,%esp
c01023c9:	ff 75 08             	pushl  0x8(%ebp)
c01023cc:	e8 4a 17 00 00       	call   c0103b1b <print_trapframe>
c01023d1:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c01023d4:	83 ec 0c             	sub    $0xc,%esp
c01023d7:	8d 83 d1 28 fe ff    	lea    -0x1d72f(%ebx),%eax
c01023dd:	50                   	push   %eax
c01023de:	e8 57 f5 ff ff       	call   c010193a <readline>
c01023e3:	83 c4 10             	add    $0x10,%esp
c01023e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01023e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01023ed:	74 e5                	je     c01023d4 <kmonitor+0x4a>
            if (runcmd(buf, tf) < 0) {
c01023ef:	83 ec 08             	sub    $0x8,%esp
c01023f2:	ff 75 08             	pushl  0x8(%ebp)
c01023f5:	ff 75 f4             	pushl  -0xc(%ebp)
c01023f8:	e8 c3 fe ff ff       	call   c01022c0 <runcmd>
c01023fd:	83 c4 10             	add    $0x10,%esp
c0102400:	85 c0                	test   %eax,%eax
c0102402:	78 02                	js     c0102406 <kmonitor+0x7c>
        if ((buf = readline("K> ")) != NULL) {
c0102404:	eb ce                	jmp    c01023d4 <kmonitor+0x4a>
                break;
c0102406:	90                   	nop
            }
        }
    }
}
c0102407:	90                   	nop
c0102408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010240b:	c9                   	leave  
c010240c:	c3                   	ret    

c010240d <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c010240d:	55                   	push   %ebp
c010240e:	89 e5                	mov    %esp,%ebp
c0102410:	56                   	push   %esi
c0102411:	53                   	push   %ebx
c0102412:	83 ec 10             	sub    $0x10,%esp
c0102415:	e8 a7 de ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010241a:	81 c3 66 75 02 00    	add    $0x27566,%ebx
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102420:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102427:	eb 44                	jmp    c010246d <mon_help+0x60>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0102429:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010242c:	8d 8b 24 00 00 00    	lea    0x24(%ebx),%ecx
c0102432:	89 d0                	mov    %edx,%eax
c0102434:	01 c0                	add    %eax,%eax
c0102436:	01 d0                	add    %edx,%eax
c0102438:	c1 e0 02             	shl    $0x2,%eax
c010243b:	01 c8                	add    %ecx,%eax
c010243d:	8b 08                	mov    (%eax),%ecx
c010243f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102442:	8d b3 20 00 00 00    	lea    0x20(%ebx),%esi
c0102448:	89 d0                	mov    %edx,%eax
c010244a:	01 c0                	add    %eax,%eax
c010244c:	01 d0                	add    %edx,%eax
c010244e:	c1 e0 02             	shl    $0x2,%eax
c0102451:	01 f0                	add    %esi,%eax
c0102453:	8b 00                	mov    (%eax),%eax
c0102455:	83 ec 04             	sub    $0x4,%esp
c0102458:	51                   	push   %ecx
c0102459:	50                   	push   %eax
c010245a:	8d 83 d5 28 fe ff    	lea    -0x1d72b(%ebx),%eax
c0102460:	50                   	push   %eax
c0102461:	e8 ce de ff ff       	call   c0100334 <cprintf>
c0102466:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
c0102469:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102470:	83 f8 02             	cmp    $0x2,%eax
c0102473:	76 b4                	jbe    c0102429 <mon_help+0x1c>
    }
    return 0;
c0102475:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010247a:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010247d:	5b                   	pop    %ebx
c010247e:	5e                   	pop    %esi
c010247f:	5d                   	pop    %ebp
c0102480:	c3                   	ret    

c0102481 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0102481:	55                   	push   %ebp
c0102482:	89 e5                	mov    %esp,%ebp
c0102484:	53                   	push   %ebx
c0102485:	83 ec 04             	sub    $0x4,%esp
c0102488:	e8 30 de ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010248d:	05 f3 74 02 00       	add    $0x274f3,%eax
    print_kerninfo();
c0102492:	89 c3                	mov    %eax,%ebx
c0102494:	e8 f1 fa ff ff       	call   c0101f8a <print_kerninfo>
    return 0;
c0102499:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010249e:	83 c4 04             	add    $0x4,%esp
c01024a1:	5b                   	pop    %ebx
c01024a2:	5d                   	pop    %ebp
c01024a3:	c3                   	ret    

c01024a4 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c01024a4:	55                   	push   %ebp
c01024a5:	89 e5                	mov    %esp,%ebp
c01024a7:	53                   	push   %ebx
c01024a8:	83 ec 04             	sub    $0x4,%esp
c01024ab:	e8 0d de ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01024b0:	05 d0 74 02 00       	add    $0x274d0,%eax
    print_stackframe();
c01024b5:	89 c3                	mov    %eax,%ebx
c01024b7:	e8 5d fc ff ff       	call   c0102119 <print_stackframe>
    return 0;
c01024bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01024c1:	83 c4 04             	add    $0x4,%esp
c01024c4:	5b                   	pop    %ebx
c01024c5:	5d                   	pop    %ebp
c01024c6:	c3                   	ret    

c01024c7 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01024c7:	55                   	push   %ebp
c01024c8:	89 e5                	mov    %esp,%ebp
c01024ca:	83 ec 14             	sub    $0x14,%esp
c01024cd:	e8 eb dd ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01024d2:	05 ae 74 02 00       	add    $0x274ae,%eax
c01024d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024da:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01024de:	90                   	nop
c01024df:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01024e3:	83 c0 07             	add    $0x7,%eax
c01024e6:	0f b7 c0             	movzwl %ax,%eax
c01024e9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01024ed:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01024f1:	89 c2                	mov    %eax,%edx
c01024f3:	ec                   	in     (%dx),%al
c01024f4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01024f7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01024fb:	0f b6 c0             	movzbl %al,%eax
c01024fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0102501:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102504:	25 80 00 00 00       	and    $0x80,%eax
c0102509:	85 c0                	test   %eax,%eax
c010250b:	75 d2                	jne    c01024df <ide_wait_ready+0x18>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010250d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102511:	74 11                	je     c0102524 <ide_wait_ready+0x5d>
c0102513:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102516:	83 e0 21             	and    $0x21,%eax
c0102519:	85 c0                	test   %eax,%eax
c010251b:	74 07                	je     c0102524 <ide_wait_ready+0x5d>
        return -1;
c010251d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102522:	eb 05                	jmp    c0102529 <ide_wait_ready+0x62>
    }
    return 0;
c0102524:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102529:	c9                   	leave  
c010252a:	c3                   	ret    

c010252b <ide_init>:

void
ide_init(void) {
c010252b:	55                   	push   %ebp
c010252c:	89 e5                	mov    %esp,%ebp
c010252e:	57                   	push   %edi
c010252f:	56                   	push   %esi
c0102530:	53                   	push   %ebx
c0102531:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
c0102537:	e8 85 dd ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010253c:	81 c3 44 74 02 00    	add    $0x27444,%ebx
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102542:	66 c7 45 e6 00 00    	movw   $0x0,-0x1a(%ebp)
c0102548:	e9 83 02 00 00       	jmp    c01027d0 <ide_init+0x2a5>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c010254d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102551:	8d 83 00 06 00 00    	lea    0x600(%ebx),%eax
c0102557:	6b d2 38             	imul   $0x38,%edx,%edx
c010255a:	01 d0                	add    %edx,%eax
c010255c:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c010255f:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0102563:	66 d1 e8             	shr    %ax
c0102566:	0f b7 c0             	movzwl %ax,%eax
c0102569:	0f b7 84 83 e0 28 fe 	movzwl -0x1d720(%ebx,%eax,4),%eax
c0102570:	ff 
c0102571:	66 89 45 da          	mov    %ax,-0x26(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0102575:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0102579:	6a 00                	push   $0x0
c010257b:	50                   	push   %eax
c010257c:	e8 46 ff ff ff       	call   c01024c7 <ide_wait_ready>
c0102581:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0102584:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0102588:	c1 e0 04             	shl    $0x4,%eax
c010258b:	83 e0 10             	and    $0x10,%eax
c010258e:	83 c8 e0             	or     $0xffffffe0,%eax
c0102591:	0f b6 c0             	movzbl %al,%eax
c0102594:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102598:	83 c2 06             	add    $0x6,%edx
c010259b:	0f b7 d2             	movzwl %dx,%edx
c010259e:	66 89 55 ba          	mov    %dx,-0x46(%ebp)
c01025a2:	88 45 b9             	mov    %al,-0x47(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01025a5:	0f b6 45 b9          	movzbl -0x47(%ebp),%eax
c01025a9:	0f b7 55 ba          	movzwl -0x46(%ebp),%edx
c01025ad:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01025ae:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c01025b2:	6a 00                	push   $0x0
c01025b4:	50                   	push   %eax
c01025b5:	e8 0d ff ff ff       	call   c01024c7 <ide_wait_ready>
c01025ba:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01025bd:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c01025c1:	83 c0 07             	add    $0x7,%eax
c01025c4:	0f b7 c0             	movzwl %ax,%eax
c01025c7:	66 89 45 be          	mov    %ax,-0x42(%ebp)
c01025cb:	c6 45 bd ec          	movb   $0xec,-0x43(%ebp)
c01025cf:	0f b6 45 bd          	movzbl -0x43(%ebp),%eax
c01025d3:	0f b7 55 be          	movzwl -0x42(%ebp),%edx
c01025d7:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01025d8:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c01025dc:	6a 00                	push   $0x0
c01025de:	50                   	push   %eax
c01025df:	e8 e3 fe ff ff       	call   c01024c7 <ide_wait_ready>
c01025e4:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01025e7:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c01025eb:	83 c0 07             	add    $0x7,%eax
c01025ee:	0f b7 c0             	movzwl %ax,%eax
c01025f1:	66 89 45 c2          	mov    %ax,-0x3e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01025f5:	0f b7 45 c2          	movzwl -0x3e(%ebp),%eax
c01025f9:	89 c2                	mov    %eax,%edx
c01025fb:	ec                   	in     (%dx),%al
c01025fc:	88 45 c1             	mov    %al,-0x3f(%ebp)
    return data;
c01025ff:	0f b6 45 c1          	movzbl -0x3f(%ebp),%eax
c0102603:	84 c0                	test   %al,%al
c0102605:	0f 84 b9 01 00 00    	je     c01027c4 <ide_init+0x299>
c010260b:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010260f:	6a 01                	push   $0x1
c0102611:	50                   	push   %eax
c0102612:	e8 b0 fe ff ff       	call   c01024c7 <ide_wait_ready>
c0102617:	83 c4 08             	add    $0x8,%esp
c010261a:	85 c0                	test   %eax,%eax
c010261c:	0f 85 a2 01 00 00    	jne    c01027c4 <ide_init+0x299>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0102622:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102626:	8d 83 00 06 00 00    	lea    0x600(%ebx),%eax
c010262c:	6b d2 38             	imul   $0x38,%edx,%edx
c010262f:	01 d0                	add    %edx,%eax
c0102631:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0102634:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0102638:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010263b:	8d 85 ac fd ff ff    	lea    -0x254(%ebp),%eax
c0102641:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102644:	c7 45 ac 80 00 00 00 	movl   $0x80,-0x54(%ebp)
    asm volatile (
c010264b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010264e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0102651:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102654:	89 ce                	mov    %ecx,%esi
c0102656:	89 f7                	mov    %esi,%edi
c0102658:	89 c1                	mov    %eax,%ecx
c010265a:	fc                   	cld    
c010265b:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010265d:	89 c8                	mov    %ecx,%eax
c010265f:	89 fe                	mov    %edi,%esi
c0102661:	89 75 b0             	mov    %esi,-0x50(%ebp)
c0102664:	89 45 ac             	mov    %eax,-0x54(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0102667:	8d 85 ac fd ff ff    	lea    -0x254(%ebp),%eax
c010266d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0102670:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102673:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0102679:	89 45 d0             	mov    %eax,-0x30(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010267c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010267f:	25 00 00 00 04       	and    $0x4000000,%eax
c0102684:	85 c0                	test   %eax,%eax
c0102686:	74 0e                	je     c0102696 <ide_init+0x16b>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0102688:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010268b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0102691:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102694:	eb 09                	jmp    c010269f <ide_init+0x174>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0102696:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102699:	8b 40 78             	mov    0x78(%eax),%eax
c010269c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c010269f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01026a3:	8d 83 04 06 00 00    	lea    0x604(%ebx),%eax
c01026a9:	6b d2 38             	imul   $0x38,%edx,%edx
c01026ac:	01 c2                	add    %eax,%edx
c01026ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01026b1:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c01026b3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01026b7:	8d 83 08 06 00 00    	lea    0x608(%ebx),%eax
c01026bd:	6b d2 38             	imul   $0x38,%edx,%edx
c01026c0:	01 c2                	add    %eax,%edx
c01026c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01026c5:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01026c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01026ca:	83 c0 62             	add    $0x62,%eax
c01026cd:	0f b7 00             	movzwl (%eax),%eax
c01026d0:	0f b7 c0             	movzwl %ax,%eax
c01026d3:	25 00 02 00 00       	and    $0x200,%eax
c01026d8:	85 c0                	test   %eax,%eax
c01026da:	75 1c                	jne    c01026f8 <ide_init+0x1cd>
c01026dc:	8d 83 e8 28 fe ff    	lea    -0x1d718(%ebx),%eax
c01026e2:	50                   	push   %eax
c01026e3:	8d 83 2b 29 fe ff    	lea    -0x1d6d5(%ebx),%eax
c01026e9:	50                   	push   %eax
c01026ea:	6a 7d                	push   $0x7d
c01026ec:	8d 83 40 29 fe ff    	lea    -0x1d6c0(%ebx),%eax
c01026f2:	50                   	push   %eax
c01026f3:	e8 1a f3 ff ff       	call   c0101a12 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01026f8:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01026fc:	6b d0 38             	imul   $0x38,%eax,%edx
c01026ff:	8d 83 00 06 00 00    	lea    0x600(%ebx),%eax
c0102705:	01 d0                	add    %edx,%eax
c0102707:	83 c0 0c             	add    $0xc,%eax
c010270a:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010270d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102710:	83 c0 36             	add    $0x36,%eax
c0102713:	89 45 c8             	mov    %eax,-0x38(%ebp)
        unsigned int i, length = 40;
c0102716:	c7 45 c4 28 00 00 00 	movl   $0x28,-0x3c(%ebp)
        for (i = 0; i < length; i += 2) {
c010271d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102724:	eb 34                	jmp    c010275a <ide_init+0x22f>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0102726:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102729:	8d 50 01             	lea    0x1(%eax),%edx
c010272c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010272f:	01 d0                	add    %edx,%eax
c0102731:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102734:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102737:	01 ca                	add    %ecx,%edx
c0102739:	0f b6 00             	movzbl (%eax),%eax
c010273c:	88 02                	mov    %al,(%edx)
c010273e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102741:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102744:	01 d0                	add    %edx,%eax
c0102746:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102749:	8d 4a 01             	lea    0x1(%edx),%ecx
c010274c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010274f:	01 ca                	add    %ecx,%edx
c0102751:	0f b6 00             	movzbl (%eax),%eax
c0102754:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0102756:	83 45 dc 02          	addl   $0x2,-0x24(%ebp)
c010275a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010275d:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0102760:	72 c4                	jb     c0102726 <ide_init+0x1fb>
        }
        do {
            model[i] = '\0';
c0102762:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102765:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102768:	01 d0                	add    %edx,%eax
c010276a:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010276d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102770:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102773:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0102776:	85 c0                	test   %eax,%eax
c0102778:	74 0f                	je     c0102789 <ide_init+0x25e>
c010277a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010277d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102780:	01 d0                	add    %edx,%eax
c0102782:	0f b6 00             	movzbl (%eax),%eax
c0102785:	3c 20                	cmp    $0x20,%al
c0102787:	74 d9                	je     c0102762 <ide_init+0x237>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0102789:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010278d:	6b d0 38             	imul   $0x38,%eax,%edx
c0102790:	8d 83 00 06 00 00    	lea    0x600(%ebx),%eax
c0102796:	01 d0                	add    %edx,%eax
c0102798:	8d 48 0c             	lea    0xc(%eax),%ecx
c010279b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010279f:	8d 83 08 06 00 00    	lea    0x608(%ebx),%eax
c01027a5:	6b d2 38             	imul   $0x38,%edx,%edx
c01027a8:	01 d0                	add    %edx,%eax
c01027aa:	8b 10                	mov    (%eax),%edx
c01027ac:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01027b0:	51                   	push   %ecx
c01027b1:	52                   	push   %edx
c01027b2:	50                   	push   %eax
c01027b3:	8d 83 52 29 fe ff    	lea    -0x1d6ae(%ebx),%eax
c01027b9:	50                   	push   %eax
c01027ba:	e8 75 db ff ff       	call   c0100334 <cprintf>
c01027bf:	83 c4 10             	add    $0x10,%esp
c01027c2:	eb 01                	jmp    c01027c5 <ide_init+0x29a>
            continue ;
c01027c4:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01027c5:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01027c9:	83 c0 01             	add    $0x1,%eax
c01027cc:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01027d0:	66 83 7d e6 03       	cmpw   $0x3,-0x1a(%ebp)
c01027d5:	0f 86 72 fd ff ff    	jbe    c010254d <ide_init+0x22>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01027db:	83 ec 0c             	sub    $0xc,%esp
c01027de:	6a 0e                	push   $0xe
c01027e0:	e8 05 10 00 00       	call   c01037ea <pic_enable>
c01027e5:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c01027e8:	83 ec 0c             	sub    $0xc,%esp
c01027eb:	6a 0f                	push   $0xf
c01027ed:	e8 f8 0f 00 00       	call   c01037ea <pic_enable>
c01027f2:	83 c4 10             	add    $0x10,%esp
}
c01027f5:	90                   	nop
c01027f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01027f9:	5b                   	pop    %ebx
c01027fa:	5e                   	pop    %esi
c01027fb:	5f                   	pop    %edi
c01027fc:	5d                   	pop    %ebp
c01027fd:	c3                   	ret    

c01027fe <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01027fe:	55                   	push   %ebp
c01027ff:	89 e5                	mov    %esp,%ebp
c0102801:	83 ec 04             	sub    $0x4,%esp
c0102804:	e8 b4 da ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102809:	05 77 71 02 00       	add    $0x27177,%eax
c010280e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102811:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
    return VALID_IDE(ideno);
c0102815:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c010281a:	77 1d                	ja     c0102839 <ide_device_valid+0x3b>
c010281c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0102820:	8d 80 00 06 00 00    	lea    0x600(%eax),%eax
c0102826:	6b d2 38             	imul   $0x38,%edx,%edx
c0102829:	01 d0                	add    %edx,%eax
c010282b:	0f b6 00             	movzbl (%eax),%eax
c010282e:	84 c0                	test   %al,%al
c0102830:	74 07                	je     c0102839 <ide_device_valid+0x3b>
c0102832:	b8 01 00 00 00       	mov    $0x1,%eax
c0102837:	eb 05                	jmp    c010283e <ide_device_valid+0x40>
c0102839:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010283e:	c9                   	leave  
c010283f:	c3                   	ret    

c0102840 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0102840:	55                   	push   %ebp
c0102841:	89 e5                	mov    %esp,%ebp
c0102843:	53                   	push   %ebx
c0102844:	83 ec 04             	sub    $0x4,%esp
c0102847:	e8 75 da ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010284c:	81 c3 34 71 02 00    	add    $0x27134,%ebx
c0102852:	8b 45 08             	mov    0x8(%ebp),%eax
c0102855:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
    if (ide_device_valid(ideno)) {
c0102859:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c010285d:	50                   	push   %eax
c010285e:	e8 9b ff ff ff       	call   c01027fe <ide_device_valid>
c0102863:	83 c4 04             	add    $0x4,%esp
c0102866:	85 c0                	test   %eax,%eax
c0102868:	74 13                	je     c010287d <ide_device_size+0x3d>
        return ide_devices[ideno].size;
c010286a:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010286e:	8d 83 08 06 00 00    	lea    0x608(%ebx),%eax
c0102874:	6b d2 38             	imul   $0x38,%edx,%edx
c0102877:	01 d0                	add    %edx,%eax
c0102879:	8b 00                	mov    (%eax),%eax
c010287b:	eb 05                	jmp    c0102882 <ide_device_size+0x42>
    }
    return 0;
c010287d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102885:	c9                   	leave  
c0102886:	c3                   	ret    

c0102887 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0102887:	55                   	push   %ebp
c0102888:	89 e5                	mov    %esp,%ebp
c010288a:	57                   	push   %edi
c010288b:	53                   	push   %ebx
c010288c:	83 ec 40             	sub    $0x40,%esp
c010288f:	e8 29 da ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102894:	05 ec 70 02 00       	add    $0x270ec,%eax
c0102899:	8b 55 08             	mov    0x8(%ebp),%edx
c010289c:	66 89 55 c4          	mov    %dx,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01028a0:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01028a7:	77 1d                	ja     c01028c6 <ide_read_secs+0x3f>
c01028a9:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01028ae:	77 16                	ja     c01028c6 <ide_read_secs+0x3f>
c01028b0:	0f b7 4d c4          	movzwl -0x3c(%ebp),%ecx
c01028b4:	8d 90 00 06 00 00    	lea    0x600(%eax),%edx
c01028ba:	6b c9 38             	imul   $0x38,%ecx,%ecx
c01028bd:	01 ca                	add    %ecx,%edx
c01028bf:	0f b6 12             	movzbl (%edx),%edx
c01028c2:	84 d2                	test   %dl,%dl
c01028c4:	75 21                	jne    c01028e7 <ide_read_secs+0x60>
c01028c6:	8d 90 70 29 fe ff    	lea    -0x1d690(%eax),%edx
c01028cc:	52                   	push   %edx
c01028cd:	8d 90 2b 29 fe ff    	lea    -0x1d6d5(%eax),%edx
c01028d3:	52                   	push   %edx
c01028d4:	68 9f 00 00 00       	push   $0x9f
c01028d9:	8d 90 40 29 fe ff    	lea    -0x1d6c0(%eax),%edx
c01028df:	52                   	push   %edx
c01028e0:	89 c3                	mov    %eax,%ebx
c01028e2:	e8 2b f1 ff ff       	call   c0101a12 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01028e7:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01028ee:	77 10                	ja     c0102900 <ide_read_secs+0x79>
c01028f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01028f3:	8b 55 14             	mov    0x14(%ebp),%edx
c01028f6:	01 ca                	add    %ecx,%edx
c01028f8:	81 fa 00 00 00 10    	cmp    $0x10000000,%edx
c01028fe:	76 21                	jbe    c0102921 <ide_read_secs+0x9a>
c0102900:	8d 90 98 29 fe ff    	lea    -0x1d668(%eax),%edx
c0102906:	52                   	push   %edx
c0102907:	8d 90 2b 29 fe ff    	lea    -0x1d6d5(%eax),%edx
c010290d:	52                   	push   %edx
c010290e:	68 a0 00 00 00       	push   $0xa0
c0102913:	8d 90 40 29 fe ff    	lea    -0x1d6c0(%eax),%edx
c0102919:	52                   	push   %edx
c010291a:	89 c3                	mov    %eax,%ebx
c010291c:	e8 f1 f0 ff ff       	call   c0101a12 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0102921:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0102925:	66 d1 ea             	shr    %dx
c0102928:	0f b7 d2             	movzwl %dx,%edx
c010292b:	0f b7 94 90 e0 28 fe 	movzwl -0x1d720(%eax,%edx,4),%edx
c0102932:	ff 
c0102933:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0102937:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c010293b:	66 d1 ea             	shr    %dx
c010293e:	0f b7 d2             	movzwl %dx,%edx
c0102941:	0f b7 84 90 e2 28 fe 	movzwl -0x1d71e(%eax,%edx,4),%eax
c0102948:	ff 
c0102949:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010294d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102951:	83 ec 08             	sub    $0x8,%esp
c0102954:	6a 00                	push   $0x0
c0102956:	50                   	push   %eax
c0102957:	e8 6b fb ff ff       	call   c01024c7 <ide_wait_ready>
c010295c:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010295f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0102963:	83 c0 02             	add    $0x2,%eax
c0102966:	0f b7 c0             	movzwl %ax,%eax
c0102969:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010296d:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102971:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102975:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102979:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c010297a:	8b 45 14             	mov    0x14(%ebp),%eax
c010297d:	0f b6 c0             	movzbl %al,%eax
c0102980:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102984:	83 c2 02             	add    $0x2,%edx
c0102987:	0f b7 d2             	movzwl %dx,%edx
c010298a:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c010298e:	88 45 d9             	mov    %al,-0x27(%ebp)
c0102991:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102995:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102999:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c010299a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010299d:	0f b6 c0             	movzbl %al,%eax
c01029a0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01029a4:	83 c2 03             	add    $0x3,%edx
c01029a7:	0f b7 d2             	movzwl %dx,%edx
c01029aa:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01029ae:	88 45 dd             	mov    %al,-0x23(%ebp)
c01029b1:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01029b5:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01029b9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01029ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029bd:	c1 e8 08             	shr    $0x8,%eax
c01029c0:	0f b6 c0             	movzbl %al,%eax
c01029c3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01029c7:	83 c2 04             	add    $0x4,%edx
c01029ca:	0f b7 d2             	movzwl %dx,%edx
c01029cd:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01029d1:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01029d4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01029d8:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01029dc:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01029dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029e0:	c1 e8 10             	shr    $0x10,%eax
c01029e3:	0f b6 c0             	movzbl %al,%eax
c01029e6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01029ea:	83 c2 05             	add    $0x5,%edx
c01029ed:	0f b7 d2             	movzwl %dx,%edx
c01029f0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01029f4:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01029f7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01029fb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01029ff:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0102a00:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102a04:	c1 e0 04             	shl    $0x4,%eax
c0102a07:	83 e0 10             	and    $0x10,%eax
c0102a0a:	89 c2                	mov    %eax,%edx
c0102a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a0f:	c1 e8 18             	shr    $0x18,%eax
c0102a12:	83 e0 0f             	and    $0xf,%eax
c0102a15:	09 d0                	or     %edx,%eax
c0102a17:	83 c8 e0             	or     $0xffffffe0,%eax
c0102a1a:	0f b6 c0             	movzbl %al,%eax
c0102a1d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102a21:	83 c2 06             	add    $0x6,%edx
c0102a24:	0f b7 d2             	movzwl %dx,%edx
c0102a27:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0102a2b:	88 45 e9             	mov    %al,-0x17(%ebp)
c0102a2e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102a32:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102a36:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0102a37:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102a3b:	83 c0 07             	add    $0x7,%eax
c0102a3e:	0f b7 c0             	movzwl %ax,%eax
c0102a41:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102a45:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
c0102a49:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102a4d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102a51:	ee                   	out    %al,(%dx)

    int ret = 0;
c0102a52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0102a59:	eb 56                	jmp    c0102ab1 <ide_read_secs+0x22a>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0102a5b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102a5f:	83 ec 08             	sub    $0x8,%esp
c0102a62:	6a 01                	push   $0x1
c0102a64:	50                   	push   %eax
c0102a65:	e8 5d fa ff ff       	call   c01024c7 <ide_wait_ready>
c0102a6a:	83 c4 10             	add    $0x10,%esp
c0102a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102a70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102a74:	75 43                	jne    c0102ab9 <ide_read_secs+0x232>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0102a76:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102a7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102a7d:	8b 45 10             	mov    0x10(%ebp),%eax
c0102a80:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102a83:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0102a8a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102a8d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102a90:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102a93:	89 cb                	mov    %ecx,%ebx
c0102a95:	89 df                	mov    %ebx,%edi
c0102a97:	89 c1                	mov    %eax,%ecx
c0102a99:	fc                   	cld    
c0102a9a:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0102a9c:	89 c8                	mov    %ecx,%eax
c0102a9e:	89 fb                	mov    %edi,%ebx
c0102aa0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102aa3:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0102aa6:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102aaa:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102ab1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102ab5:	75 a4                	jne    c0102a5b <ide_read_secs+0x1d4>
    }

out:
c0102ab7:	eb 01                	jmp    c0102aba <ide_read_secs+0x233>
            goto out;
c0102ab9:	90                   	nop
    return ret;
c0102aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102abd:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102ac0:	5b                   	pop    %ebx
c0102ac1:	5f                   	pop    %edi
c0102ac2:	5d                   	pop    %ebp
c0102ac3:	c3                   	ret    

c0102ac4 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0102ac4:	55                   	push   %ebp
c0102ac5:	89 e5                	mov    %esp,%ebp
c0102ac7:	56                   	push   %esi
c0102ac8:	53                   	push   %ebx
c0102ac9:	83 ec 40             	sub    $0x40,%esp
c0102acc:	e8 ec d7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102ad1:	05 af 6e 02 00       	add    $0x26eaf,%eax
c0102ad6:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ad9:	66 89 55 c4          	mov    %dx,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0102add:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0102ae4:	77 1d                	ja     c0102b03 <ide_write_secs+0x3f>
c0102ae6:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0102aeb:	77 16                	ja     c0102b03 <ide_write_secs+0x3f>
c0102aed:	0f b7 4d c4          	movzwl -0x3c(%ebp),%ecx
c0102af1:	8d 90 00 06 00 00    	lea    0x600(%eax),%edx
c0102af7:	6b c9 38             	imul   $0x38,%ecx,%ecx
c0102afa:	01 ca                	add    %ecx,%edx
c0102afc:	0f b6 12             	movzbl (%edx),%edx
c0102aff:	84 d2                	test   %dl,%dl
c0102b01:	75 21                	jne    c0102b24 <ide_write_secs+0x60>
c0102b03:	8d 90 70 29 fe ff    	lea    -0x1d690(%eax),%edx
c0102b09:	52                   	push   %edx
c0102b0a:	8d 90 2b 29 fe ff    	lea    -0x1d6d5(%eax),%edx
c0102b10:	52                   	push   %edx
c0102b11:	68 bc 00 00 00       	push   $0xbc
c0102b16:	8d 90 40 29 fe ff    	lea    -0x1d6c0(%eax),%edx
c0102b1c:	52                   	push   %edx
c0102b1d:	89 c3                	mov    %eax,%ebx
c0102b1f:	e8 ee ee ff ff       	call   c0101a12 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0102b24:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0102b2b:	77 10                	ja     c0102b3d <ide_write_secs+0x79>
c0102b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0102b30:	8b 55 14             	mov    0x14(%ebp),%edx
c0102b33:	01 ca                	add    %ecx,%edx
c0102b35:	81 fa 00 00 00 10    	cmp    $0x10000000,%edx
c0102b3b:	76 21                	jbe    c0102b5e <ide_write_secs+0x9a>
c0102b3d:	8d 90 98 29 fe ff    	lea    -0x1d668(%eax),%edx
c0102b43:	52                   	push   %edx
c0102b44:	8d 90 2b 29 fe ff    	lea    -0x1d6d5(%eax),%edx
c0102b4a:	52                   	push   %edx
c0102b4b:	68 bd 00 00 00       	push   $0xbd
c0102b50:	8d 90 40 29 fe ff    	lea    -0x1d6c0(%eax),%edx
c0102b56:	52                   	push   %edx
c0102b57:	89 c3                	mov    %eax,%ebx
c0102b59:	e8 b4 ee ff ff       	call   c0101a12 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0102b5e:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0102b62:	66 d1 ea             	shr    %dx
c0102b65:	0f b7 d2             	movzwl %dx,%edx
c0102b68:	0f b7 94 90 e0 28 fe 	movzwl -0x1d720(%eax,%edx,4),%edx
c0102b6f:	ff 
c0102b70:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0102b74:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0102b78:	66 d1 ea             	shr    %dx
c0102b7b:	0f b7 d2             	movzwl %dx,%edx
c0102b7e:	0f b7 84 90 e2 28 fe 	movzwl -0x1d71e(%eax,%edx,4),%eax
c0102b85:	ff 
c0102b86:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0102b8a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102b8e:	83 ec 08             	sub    $0x8,%esp
c0102b91:	6a 00                	push   $0x0
c0102b93:	50                   	push   %eax
c0102b94:	e8 2e f9 ff ff       	call   c01024c7 <ide_wait_ready>
c0102b99:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0102b9c:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0102ba0:	83 c0 02             	add    $0x2,%eax
c0102ba3:	0f b7 c0             	movzwl %ax,%eax
c0102ba6:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0102baa:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102bae:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102bb2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102bb6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0102bb7:	8b 45 14             	mov    0x14(%ebp),%eax
c0102bba:	0f b6 c0             	movzbl %al,%eax
c0102bbd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102bc1:	83 c2 02             	add    $0x2,%edx
c0102bc4:	0f b7 d2             	movzwl %dx,%edx
c0102bc7:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0102bcb:	88 45 d9             	mov    %al,-0x27(%ebp)
c0102bce:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102bd2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102bd6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0102bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102bda:	0f b6 c0             	movzbl %al,%eax
c0102bdd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102be1:	83 c2 03             	add    $0x3,%edx
c0102be4:	0f b7 d2             	movzwl %dx,%edx
c0102be7:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0102beb:	88 45 dd             	mov    %al,-0x23(%ebp)
c0102bee:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102bf2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102bf6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0102bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102bfa:	c1 e8 08             	shr    $0x8,%eax
c0102bfd:	0f b6 c0             	movzbl %al,%eax
c0102c00:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102c04:	83 c2 04             	add    $0x4,%edx
c0102c07:	0f b7 d2             	movzwl %dx,%edx
c0102c0a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0102c0e:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0102c11:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102c15:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102c19:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0102c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102c1d:	c1 e8 10             	shr    $0x10,%eax
c0102c20:	0f b6 c0             	movzbl %al,%eax
c0102c23:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102c27:	83 c2 05             	add    $0x5,%edx
c0102c2a:	0f b7 d2             	movzwl %dx,%edx
c0102c2d:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0102c31:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0102c34:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102c38:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102c3c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0102c3d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102c41:	c1 e0 04             	shl    $0x4,%eax
c0102c44:	83 e0 10             	and    $0x10,%eax
c0102c47:	89 c2                	mov    %eax,%edx
c0102c49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102c4c:	c1 e8 18             	shr    $0x18,%eax
c0102c4f:	83 e0 0f             	and    $0xf,%eax
c0102c52:	09 d0                	or     %edx,%eax
c0102c54:	83 c8 e0             	or     $0xffffffe0,%eax
c0102c57:	0f b6 c0             	movzbl %al,%eax
c0102c5a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102c5e:	83 c2 06             	add    $0x6,%edx
c0102c61:	0f b7 d2             	movzwl %dx,%edx
c0102c64:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0102c68:	88 45 e9             	mov    %al,-0x17(%ebp)
c0102c6b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102c6f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102c73:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0102c74:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102c78:	83 c0 07             	add    $0x7,%eax
c0102c7b:	0f b7 c0             	movzwl %ax,%eax
c0102c7e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102c82:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
c0102c86:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102c8a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102c8e:	ee                   	out    %al,(%dx)

    int ret = 0;
c0102c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102c96:	eb 56                	jmp    c0102cee <ide_write_secs+0x22a>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0102c98:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102c9c:	83 ec 08             	sub    $0x8,%esp
c0102c9f:	6a 01                	push   $0x1
c0102ca1:	50                   	push   %eax
c0102ca2:	e8 20 f8 ff ff       	call   c01024c7 <ide_wait_ready>
c0102ca7:	83 c4 10             	add    $0x10,%esp
c0102caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102cad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102cb1:	75 43                	jne    c0102cf6 <ide_write_secs+0x232>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0102cb3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102cb7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102cba:	8b 45 10             	mov    0x10(%ebp),%eax
c0102cbd:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102cc0:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0102cc7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102cca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102ccd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102cd0:	89 cb                	mov    %ecx,%ebx
c0102cd2:	89 de                	mov    %ebx,%esi
c0102cd4:	89 c1                	mov    %eax,%ecx
c0102cd6:	fc                   	cld    
c0102cd7:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102cd9:	89 c8                	mov    %ecx,%eax
c0102cdb:	89 f3                	mov    %esi,%ebx
c0102cdd:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102ce0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102ce3:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102ce7:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102cee:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102cf2:	75 a4                	jne    c0102c98 <ide_write_secs+0x1d4>
    }

out:
c0102cf4:	eb 01                	jmp    c0102cf7 <ide_write_secs+0x233>
            goto out;
c0102cf6:	90                   	nop
    return ret;
c0102cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102cfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102cfd:	5b                   	pop    %ebx
c0102cfe:	5e                   	pop    %esi
c0102cff:	5d                   	pop    %ebp
c0102d00:	c3                   	ret    

c0102d01 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0102d01:	55                   	push   %ebp
c0102d02:	89 e5                	mov    %esp,%ebp
c0102d04:	53                   	push   %ebx
c0102d05:	83 ec 14             	sub    $0x14,%esp
c0102d08:	e8 b4 d5 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0102d0d:	81 c3 73 6c 02 00    	add    $0x26c73,%ebx
c0102d13:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0102d19:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102d1d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102d21:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102d25:	ee                   	out    %al,(%dx)
c0102d26:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0102d2c:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0102d30:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102d34:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102d38:	ee                   	out    %al,(%dx)
c0102d39:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0102d3f:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0102d43:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102d47:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102d4b:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0102d4c:	c7 c0 94 cb 12 c0    	mov    $0xc012cb94,%eax
c0102d52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("++ setup timer interrupts\n");
c0102d58:	83 ec 0c             	sub    $0xc,%esp
c0102d5b:	8d 83 d2 29 fe ff    	lea    -0x1d62e(%ebx),%eax
c0102d61:	50                   	push   %eax
c0102d62:	e8 cd d5 ff ff       	call   c0100334 <cprintf>
c0102d67:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0102d6a:	83 ec 0c             	sub    $0xc,%esp
c0102d6d:	6a 00                	push   $0x0
c0102d6f:	e8 76 0a 00 00       	call   c01037ea <pic_enable>
c0102d74:	83 c4 10             	add    $0x10,%esp
}
c0102d77:	90                   	nop
c0102d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102d7b:	c9                   	leave  
c0102d7c:	c3                   	ret    

c0102d7d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102d7d:	55                   	push   %ebp
c0102d7e:	89 e5                	mov    %esp,%ebp
c0102d80:	53                   	push   %ebx
c0102d81:	83 ec 14             	sub    $0x14,%esp
c0102d84:	e8 34 d5 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102d89:	05 f7 6b 02 00       	add    $0x26bf7,%eax
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102d8e:	9c                   	pushf  
c0102d8f:	5a                   	pop    %edx
c0102d90:	89 55 f4             	mov    %edx,-0xc(%ebp)
    return eflags;
c0102d93:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if (read_eflags() & FL_IF) {
c0102d96:	81 e2 00 02 00 00    	and    $0x200,%edx
c0102d9c:	85 d2                	test   %edx,%edx
c0102d9e:	74 0e                	je     c0102dae <__intr_save+0x31>
        intr_disable();
c0102da0:	89 c3                	mov    %eax,%ebx
c0102da2:	e8 d5 0b 00 00       	call   c010397c <intr_disable>
        return 1;
c0102da7:	b8 01 00 00 00       	mov    $0x1,%eax
c0102dac:	eb 05                	jmp    c0102db3 <__intr_save+0x36>
    }
    return 0;
c0102dae:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102db3:	83 c4 14             	add    $0x14,%esp
c0102db6:	5b                   	pop    %ebx
c0102db7:	5d                   	pop    %ebp
c0102db8:	c3                   	ret    

c0102db9 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0102db9:	55                   	push   %ebp
c0102dba:	89 e5                	mov    %esp,%ebp
c0102dbc:	53                   	push   %ebx
c0102dbd:	83 ec 04             	sub    $0x4,%esp
c0102dc0:	e8 f8 d4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102dc5:	05 bb 6b 02 00       	add    $0x26bbb,%eax
    if (flag) {
c0102dca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102dce:	74 07                	je     c0102dd7 <__intr_restore+0x1e>
        intr_enable();
c0102dd0:	89 c3                	mov    %eax,%ebx
c0102dd2:	e8 94 0b 00 00       	call   c010396b <intr_enable>
    }
}
c0102dd7:	90                   	nop
c0102dd8:	83 c4 04             	add    $0x4,%esp
c0102ddb:	5b                   	pop    %ebx
c0102ddc:	5d                   	pop    %ebp
c0102ddd:	c3                   	ret    

c0102dde <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0102dde:	55                   	push   %ebp
c0102ddf:	89 e5                	mov    %esp,%ebp
c0102de1:	83 ec 10             	sub    $0x10,%esp
c0102de4:	e8 d4 d4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0102de9:	05 97 6b 02 00       	add    $0x26b97,%eax
c0102dee:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102df4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102df8:	89 c2                	mov    %eax,%edx
c0102dfa:	ec                   	in     (%dx),%al
c0102dfb:	88 45 f1             	mov    %al,-0xf(%ebp)
c0102dfe:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0102e04:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e08:	89 c2                	mov    %eax,%edx
c0102e0a:	ec                   	in     (%dx),%al
c0102e0b:	88 45 f5             	mov    %al,-0xb(%ebp)
c0102e0e:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0102e14:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102e18:	89 c2                	mov    %eax,%edx
c0102e1a:	ec                   	in     (%dx),%al
c0102e1b:	88 45 f9             	mov    %al,-0x7(%ebp)
c0102e1e:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0102e24:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102e28:	89 c2                	mov    %eax,%edx
c0102e2a:	ec                   	in     (%dx),%al
c0102e2b:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0102e2e:	90                   	nop
c0102e2f:	c9                   	leave  
c0102e30:	c3                   	ret    

c0102e31 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0102e31:	55                   	push   %ebp
c0102e32:	89 e5                	mov    %esp,%ebp
c0102e34:	83 ec 20             	sub    $0x20,%esp
c0102e37:	e8 45 09 00 00       	call   c0103781 <__x86.get_pc_thunk.cx>
c0102e3c:	81 c1 44 6b 02 00    	add    $0x26b44,%ecx
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0102e42:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0102e49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102e4c:	0f b7 00             	movzwl (%eax),%eax
c0102e4f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0102e53:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102e56:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0102e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102e5e:	0f b7 00             	movzwl (%eax),%eax
c0102e61:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0102e65:	74 12                	je     c0102e79 <cga_init+0x48>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0102e67:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0102e6e:	66 c7 81 e6 06 00 00 	movw   $0x3b4,0x6e6(%ecx)
c0102e75:	b4 03 
c0102e77:	eb 13                	jmp    c0102e8c <cga_init+0x5b>
    } else {
        *cp = was;
c0102e79:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102e7c:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102e80:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0102e83:	66 c7 81 e6 06 00 00 	movw   $0x3d4,0x6e6(%ecx)
c0102e8a:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0102e8c:	0f b7 81 e6 06 00 00 	movzwl 0x6e6(%ecx),%eax
c0102e93:	0f b7 c0             	movzwl %ax,%eax
c0102e96:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0102e9a:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102e9e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102ea2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102ea6:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0102ea7:	0f b7 81 e6 06 00 00 	movzwl 0x6e6(%ecx),%eax
c0102eae:	83 c0 01             	add    $0x1,%eax
c0102eb1:	0f b7 c0             	movzwl %ax,%eax
c0102eb4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102eb8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102ebc:	89 c2                	mov    %eax,%edx
c0102ebe:	ec                   	in     (%dx),%al
c0102ebf:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0102ec2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102ec6:	0f b6 c0             	movzbl %al,%eax
c0102ec9:	c1 e0 08             	shl    $0x8,%eax
c0102ecc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0102ecf:	0f b7 81 e6 06 00 00 	movzwl 0x6e6(%ecx),%eax
c0102ed6:	0f b7 c0             	movzwl %ax,%eax
c0102ed9:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102edd:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102ee1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102ee5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102ee9:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0102eea:	0f b7 81 e6 06 00 00 	movzwl 0x6e6(%ecx),%eax
c0102ef1:	83 c0 01             	add    $0x1,%eax
c0102ef4:	0f b7 c0             	movzwl %ax,%eax
c0102ef7:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102efb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102eff:	89 c2                	mov    %eax,%edx
c0102f01:	ec                   	in     (%dx),%al
c0102f02:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0102f05:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102f09:	0f b6 c0             	movzbl %al,%eax
c0102f0c:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0102f0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102f12:	89 81 e0 06 00 00    	mov    %eax,0x6e0(%ecx)
    crt_pos = pos;
c0102f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f1b:	66 89 81 e4 06 00 00 	mov    %ax,0x6e4(%ecx)
}
c0102f22:	90                   	nop
c0102f23:	c9                   	leave  
c0102f24:	c3                   	ret    

c0102f25 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0102f25:	55                   	push   %ebp
c0102f26:	89 e5                	mov    %esp,%ebp
c0102f28:	53                   	push   %ebx
c0102f29:	83 ec 34             	sub    $0x34,%esp
c0102f2c:	e8 50 08 00 00       	call   c0103781 <__x86.get_pc_thunk.cx>
c0102f31:	81 c1 4f 6a 02 00    	add    $0x26a4f,%ecx
c0102f37:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0102f3d:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102f41:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102f45:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102f49:	ee                   	out    %al,(%dx)
c0102f4a:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0102f50:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c0102f54:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102f58:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102f5c:	ee                   	out    %al,(%dx)
c0102f5d:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0102f63:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c0102f67:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102f6b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102f6f:	ee                   	out    %al,(%dx)
c0102f70:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0102f76:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0102f7a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102f7e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102f82:	ee                   	out    %al,(%dx)
c0102f83:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0102f89:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0102f8d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102f91:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102f95:	ee                   	out    %al,(%dx)
c0102f96:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0102f9c:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0102fa0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102fa4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102fa8:	ee                   	out    %al,(%dx)
c0102fa9:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0102faf:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0102fb3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102fb7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102fbb:	ee                   	out    %al,(%dx)
c0102fbc:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102fc2:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0102fc6:	89 c2                	mov    %eax,%edx
c0102fc8:	ec                   	in     (%dx),%al
c0102fc9:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0102fcc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0102fd0:	3c ff                	cmp    $0xff,%al
c0102fd2:	0f 95 c0             	setne  %al
c0102fd5:	0f b6 c0             	movzbl %al,%eax
c0102fd8:	89 81 e8 06 00 00    	mov    %eax,0x6e8(%ecx)
c0102fde:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102fe4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102fe8:	89 c2                	mov    %eax,%edx
c0102fea:	ec                   	in     (%dx),%al
c0102feb:	88 45 f1             	mov    %al,-0xf(%ebp)
c0102fee:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0102ff4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102ff8:	89 c2                	mov    %eax,%edx
c0102ffa:	ec                   	in     (%dx),%al
c0102ffb:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0102ffe:	8b 81 e8 06 00 00    	mov    0x6e8(%ecx),%eax
c0103004:	85 c0                	test   %eax,%eax
c0103006:	74 0f                	je     c0103017 <serial_init+0xf2>
        pic_enable(IRQ_COM1);
c0103008:	83 ec 0c             	sub    $0xc,%esp
c010300b:	6a 04                	push   $0x4
c010300d:	89 cb                	mov    %ecx,%ebx
c010300f:	e8 d6 07 00 00       	call   c01037ea <pic_enable>
c0103014:	83 c4 10             	add    $0x10,%esp
    }
}
c0103017:	90                   	nop
c0103018:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010301b:	c9                   	leave  
c010301c:	c3                   	ret    

c010301d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010301d:	55                   	push   %ebp
c010301e:	89 e5                	mov    %esp,%ebp
c0103020:	83 ec 20             	sub    $0x20,%esp
c0103023:	e8 95 d2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103028:	05 58 69 02 00       	add    $0x26958,%eax
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010302d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0103034:	eb 09                	jmp    c010303f <lpt_putc_sub+0x22>
        delay();
c0103036:	e8 a3 fd ff ff       	call   c0102dde <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010303b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010303f:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0103045:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0103049:	89 c2                	mov    %eax,%edx
c010304b:	ec                   	in     (%dx),%al
c010304c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010304f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0103053:	84 c0                	test   %al,%al
c0103055:	78 09                	js     c0103060 <lpt_putc_sub+0x43>
c0103057:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010305e:	7e d6                	jle    c0103036 <lpt_putc_sub+0x19>
    }
    outb(LPTPORT + 0, c);
c0103060:	8b 45 08             	mov    0x8(%ebp),%eax
c0103063:	0f b6 c0             	movzbl %al,%eax
c0103066:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c010306c:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010306f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0103073:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103077:	ee                   	out    %al,(%dx)
c0103078:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010307e:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0103082:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0103086:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010308a:	ee                   	out    %al,(%dx)
c010308b:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0103091:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c0103095:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0103099:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010309d:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010309e:	90                   	nop
c010309f:	c9                   	leave  
c01030a0:	c3                   	ret    

c01030a1 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01030a1:	55                   	push   %ebp
c01030a2:	89 e5                	mov    %esp,%ebp
c01030a4:	e8 14 d2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01030a9:	05 d7 68 02 00       	add    $0x268d7,%eax
    if (c != '\b') {
c01030ae:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01030b2:	74 0d                	je     c01030c1 <lpt_putc+0x20>
        lpt_putc_sub(c);
c01030b4:	ff 75 08             	pushl  0x8(%ebp)
c01030b7:	e8 61 ff ff ff       	call   c010301d <lpt_putc_sub>
c01030bc:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01030bf:	eb 1e                	jmp    c01030df <lpt_putc+0x3e>
        lpt_putc_sub('\b');
c01030c1:	6a 08                	push   $0x8
c01030c3:	e8 55 ff ff ff       	call   c010301d <lpt_putc_sub>
c01030c8:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c01030cb:	6a 20                	push   $0x20
c01030cd:	e8 4b ff ff ff       	call   c010301d <lpt_putc_sub>
c01030d2:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c01030d5:	6a 08                	push   $0x8
c01030d7:	e8 41 ff ff ff       	call   c010301d <lpt_putc_sub>
c01030dc:	83 c4 04             	add    $0x4,%esp
}
c01030df:	90                   	nop
c01030e0:	c9                   	leave  
c01030e1:	c3                   	ret    

c01030e2 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01030e2:	55                   	push   %ebp
c01030e3:	89 e5                	mov    %esp,%ebp
c01030e5:	56                   	push   %esi
c01030e6:	53                   	push   %ebx
c01030e7:	83 ec 20             	sub    $0x20,%esp
c01030ea:	e8 d2 d1 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01030ef:	81 c3 91 68 02 00    	add    $0x26891,%ebx
    // set black on white
    if (!(c & ~0xFF)) {
c01030f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01030f8:	b0 00                	mov    $0x0,%al
c01030fa:	85 c0                	test   %eax,%eax
c01030fc:	75 07                	jne    c0103105 <cga_putc+0x23>
        c |= 0x0700;
c01030fe:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0103105:	8b 45 08             	mov    0x8(%ebp),%eax
c0103108:	0f b6 c0             	movzbl %al,%eax
c010310b:	83 f8 0a             	cmp    $0xa,%eax
c010310e:	74 54                	je     c0103164 <cga_putc+0x82>
c0103110:	83 f8 0d             	cmp    $0xd,%eax
c0103113:	74 60                	je     c0103175 <cga_putc+0x93>
c0103115:	83 f8 08             	cmp    $0x8,%eax
c0103118:	0f 85 92 00 00 00    	jne    c01031b0 <cga_putc+0xce>
    case '\b':
        if (crt_pos > 0) {
c010311e:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c0103125:	66 85 c0             	test   %ax,%ax
c0103128:	0f 84 a8 00 00 00    	je     c01031d6 <cga_putc+0xf4>
            crt_pos --;
c010312e:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c0103135:	83 e8 01             	sub    $0x1,%eax
c0103138:	66 89 83 e4 06 00 00 	mov    %ax,0x6e4(%ebx)
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010313f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103142:	b0 00                	mov    $0x0,%al
c0103144:	83 c8 20             	or     $0x20,%eax
c0103147:	89 c1                	mov    %eax,%ecx
c0103149:	8b 83 e0 06 00 00    	mov    0x6e0(%ebx),%eax
c010314f:	0f b7 93 e4 06 00 00 	movzwl 0x6e4(%ebx),%edx
c0103156:	0f b7 d2             	movzwl %dx,%edx
c0103159:	01 d2                	add    %edx,%edx
c010315b:	01 d0                	add    %edx,%eax
c010315d:	89 ca                	mov    %ecx,%edx
c010315f:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0103162:	eb 72                	jmp    c01031d6 <cga_putc+0xf4>
    case '\n':
        crt_pos += CRT_COLS;
c0103164:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c010316b:	83 c0 50             	add    $0x50,%eax
c010316e:	66 89 83 e4 06 00 00 	mov    %ax,0x6e4(%ebx)
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0103175:	0f b7 b3 e4 06 00 00 	movzwl 0x6e4(%ebx),%esi
c010317c:	0f b7 8b e4 06 00 00 	movzwl 0x6e4(%ebx),%ecx
c0103183:	0f b7 c1             	movzwl %cx,%eax
c0103186:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010318c:	c1 e8 10             	shr    $0x10,%eax
c010318f:	89 c2                	mov    %eax,%edx
c0103191:	66 c1 ea 06          	shr    $0x6,%dx
c0103195:	89 d0                	mov    %edx,%eax
c0103197:	c1 e0 02             	shl    $0x2,%eax
c010319a:	01 d0                	add    %edx,%eax
c010319c:	c1 e0 04             	shl    $0x4,%eax
c010319f:	29 c1                	sub    %eax,%ecx
c01031a1:	89 ca                	mov    %ecx,%edx
c01031a3:	89 f0                	mov    %esi,%eax
c01031a5:	29 d0                	sub    %edx,%eax
c01031a7:	66 89 83 e4 06 00 00 	mov    %ax,0x6e4(%ebx)
        break;
c01031ae:	eb 27                	jmp    c01031d7 <cga_putc+0xf5>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01031b0:	8b 8b e0 06 00 00    	mov    0x6e0(%ebx),%ecx
c01031b6:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c01031bd:	8d 50 01             	lea    0x1(%eax),%edx
c01031c0:	66 89 93 e4 06 00 00 	mov    %dx,0x6e4(%ebx)
c01031c7:	0f b7 c0             	movzwl %ax,%eax
c01031ca:	01 c0                	add    %eax,%eax
c01031cc:	01 c8                	add    %ecx,%eax
c01031ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01031d1:	66 89 10             	mov    %dx,(%eax)
        break;
c01031d4:	eb 01                	jmp    c01031d7 <cga_putc+0xf5>
        break;
c01031d6:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01031d7:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c01031de:	66 3d cf 07          	cmp    $0x7cf,%ax
c01031e2:	76 5d                	jbe    c0103241 <cga_putc+0x15f>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01031e4:	8b 83 e0 06 00 00    	mov    0x6e0(%ebx),%eax
c01031ea:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01031f0:	8b 83 e0 06 00 00    	mov    0x6e0(%ebx),%eax
c01031f6:	83 ec 04             	sub    $0x4,%esp
c01031f9:	68 00 0f 00 00       	push   $0xf00
c01031fe:	52                   	push   %edx
c01031ff:	50                   	push   %eax
c0103200:	e8 f1 81 00 00       	call   c010b3f6 <memmove>
c0103205:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0103208:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010320f:	eb 16                	jmp    c0103227 <cga_putc+0x145>
            crt_buf[i] = 0x0700 | ' ';
c0103211:	8b 83 e0 06 00 00    	mov    0x6e0(%ebx),%eax
c0103217:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010321a:	01 d2                	add    %edx,%edx
c010321c:	01 d0                	add    %edx,%eax
c010321e:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0103223:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103227:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010322e:	7e e1                	jle    c0103211 <cga_putc+0x12f>
        }
        crt_pos -= CRT_COLS;
c0103230:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c0103237:	83 e8 50             	sub    $0x50,%eax
c010323a:	66 89 83 e4 06 00 00 	mov    %ax,0x6e4(%ebx)
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0103241:	0f b7 83 e6 06 00 00 	movzwl 0x6e6(%ebx),%eax
c0103248:	0f b7 c0             	movzwl %ax,%eax
c010324b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010324f:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0103253:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0103257:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010325b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010325c:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c0103263:	66 c1 e8 08          	shr    $0x8,%ax
c0103267:	0f b6 c0             	movzbl %al,%eax
c010326a:	0f b7 93 e6 06 00 00 	movzwl 0x6e6(%ebx),%edx
c0103271:	83 c2 01             	add    $0x1,%edx
c0103274:	0f b7 d2             	movzwl %dx,%edx
c0103277:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010327b:	88 45 e9             	mov    %al,-0x17(%ebp)
c010327e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0103282:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0103286:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0103287:	0f b7 83 e6 06 00 00 	movzwl 0x6e6(%ebx),%eax
c010328e:	0f b7 c0             	movzwl %ax,%eax
c0103291:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0103295:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c0103299:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010329d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01032a1:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01032a2:	0f b7 83 e4 06 00 00 	movzwl 0x6e4(%ebx),%eax
c01032a9:	0f b6 c0             	movzbl %al,%eax
c01032ac:	0f b7 93 e6 06 00 00 	movzwl 0x6e6(%ebx),%edx
c01032b3:	83 c2 01             	add    $0x1,%edx
c01032b6:	0f b7 d2             	movzwl %dx,%edx
c01032b9:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c01032bd:	88 45 f1             	mov    %al,-0xf(%ebp)
c01032c0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01032c4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01032c8:	ee                   	out    %al,(%dx)
}
c01032c9:	90                   	nop
c01032ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01032cd:	5b                   	pop    %ebx
c01032ce:	5e                   	pop    %esi
c01032cf:	5d                   	pop    %ebp
c01032d0:	c3                   	ret    

c01032d1 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01032d1:	55                   	push   %ebp
c01032d2:	89 e5                	mov    %esp,%ebp
c01032d4:	83 ec 10             	sub    $0x10,%esp
c01032d7:	e8 e1 cf ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01032dc:	05 a4 66 02 00       	add    $0x266a4,%eax
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01032e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01032e8:	eb 09                	jmp    c01032f3 <serial_putc_sub+0x22>
        delay();
c01032ea:	e8 ef fa ff ff       	call   c0102dde <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01032ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01032f3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01032f9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01032fd:	89 c2                	mov    %eax,%edx
c01032ff:	ec                   	in     (%dx),%al
c0103300:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0103303:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0103307:	0f b6 c0             	movzbl %al,%eax
c010330a:	83 e0 20             	and    $0x20,%eax
c010330d:	85 c0                	test   %eax,%eax
c010330f:	75 09                	jne    c010331a <serial_putc_sub+0x49>
c0103311:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0103318:	7e d0                	jle    c01032ea <serial_putc_sub+0x19>
    }
    outb(COM1 + COM_TX, c);
c010331a:	8b 45 08             	mov    0x8(%ebp),%eax
c010331d:	0f b6 c0             	movzbl %al,%eax
c0103320:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0103326:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103329:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010332d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0103331:	ee                   	out    %al,(%dx)
}
c0103332:	90                   	nop
c0103333:	c9                   	leave  
c0103334:	c3                   	ret    

c0103335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0103335:	55                   	push   %ebp
c0103336:	89 e5                	mov    %esp,%ebp
c0103338:	e8 80 cf ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010333d:	05 43 66 02 00       	add    $0x26643,%eax
    if (c != '\b') {
c0103342:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0103346:	74 0d                	je     c0103355 <serial_putc+0x20>
        serial_putc_sub(c);
c0103348:	ff 75 08             	pushl  0x8(%ebp)
c010334b:	e8 81 ff ff ff       	call   c01032d1 <serial_putc_sub>
c0103350:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0103353:	eb 1e                	jmp    c0103373 <serial_putc+0x3e>
        serial_putc_sub('\b');
c0103355:	6a 08                	push   $0x8
c0103357:	e8 75 ff ff ff       	call   c01032d1 <serial_putc_sub>
c010335c:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c010335f:	6a 20                	push   $0x20
c0103361:	e8 6b ff ff ff       	call   c01032d1 <serial_putc_sub>
c0103366:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0103369:	6a 08                	push   $0x8
c010336b:	e8 61 ff ff ff       	call   c01032d1 <serial_putc_sub>
c0103370:	83 c4 04             	add    $0x4,%esp
}
c0103373:	90                   	nop
c0103374:	c9                   	leave  
c0103375:	c3                   	ret    

c0103376 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0103376:	55                   	push   %ebp
c0103377:	89 e5                	mov    %esp,%ebp
c0103379:	53                   	push   %ebx
c010337a:	83 ec 14             	sub    $0x14,%esp
c010337d:	e8 3f cf ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103382:	81 c3 fe 65 02 00    	add    $0x265fe,%ebx
    int c;
    while ((c = (*proc)()) != -1) {
c0103388:	eb 36                	jmp    c01033c0 <cons_intr+0x4a>
        if (c != 0) {
c010338a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010338e:	74 30                	je     c01033c0 <cons_intr+0x4a>
            cons.buf[cons.wpos ++] = c;
c0103390:	8b 83 04 09 00 00    	mov    0x904(%ebx),%eax
c0103396:	8d 50 01             	lea    0x1(%eax),%edx
c0103399:	89 93 04 09 00 00    	mov    %edx,0x904(%ebx)
c010339f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01033a2:	88 94 03 00 07 00 00 	mov    %dl,0x700(%ebx,%eax,1)
            if (cons.wpos == CONSBUFSIZE) {
c01033a9:	8b 83 04 09 00 00    	mov    0x904(%ebx),%eax
c01033af:	3d 00 02 00 00       	cmp    $0x200,%eax
c01033b4:	75 0a                	jne    c01033c0 <cons_intr+0x4a>
                cons.wpos = 0;
c01033b6:	c7 83 04 09 00 00 00 	movl   $0x0,0x904(%ebx)
c01033bd:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01033c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01033c3:	ff d0                	call   *%eax
c01033c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033c8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01033cc:	75 bc                	jne    c010338a <cons_intr+0x14>
            }
        }
    }
}
c01033ce:	90                   	nop
c01033cf:	83 c4 14             	add    $0x14,%esp
c01033d2:	5b                   	pop    %ebx
c01033d3:	5d                   	pop    %ebp
c01033d4:	c3                   	ret    

c01033d5 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01033d5:	55                   	push   %ebp
c01033d6:	89 e5                	mov    %esp,%ebp
c01033d8:	83 ec 10             	sub    $0x10,%esp
c01033db:	e8 dd ce ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01033e0:	05 a0 65 02 00       	add    $0x265a0,%eax
c01033e5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01033eb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01033ef:	89 c2                	mov    %eax,%edx
c01033f1:	ec                   	in     (%dx),%al
c01033f2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01033f5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01033f9:	0f b6 c0             	movzbl %al,%eax
c01033fc:	83 e0 01             	and    $0x1,%eax
c01033ff:	85 c0                	test   %eax,%eax
c0103401:	75 07                	jne    c010340a <serial_proc_data+0x35>
        return -1;
c0103403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0103408:	eb 2a                	jmp    c0103434 <serial_proc_data+0x5f>
c010340a:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0103410:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0103414:	89 c2                	mov    %eax,%edx
c0103416:	ec                   	in     (%dx),%al
c0103417:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010341a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010341e:	0f b6 c0             	movzbl %al,%eax
c0103421:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0103424:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0103428:	75 07                	jne    c0103431 <serial_proc_data+0x5c>
        c = '\b';
c010342a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0103431:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103434:	c9                   	leave  
c0103435:	c3                   	ret    

c0103436 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0103436:	55                   	push   %ebp
c0103437:	89 e5                	mov    %esp,%ebp
c0103439:	83 ec 08             	sub    $0x8,%esp
c010343c:	e8 7c ce ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103441:	05 3f 65 02 00       	add    $0x2653f,%eax
    if (serial_exists) {
c0103446:	8b 90 e8 06 00 00    	mov    0x6e8(%eax),%edx
c010344c:	85 d2                	test   %edx,%edx
c010344e:	74 12                	je     c0103462 <serial_intr+0x2c>
        cons_intr(serial_proc_data);
c0103450:	83 ec 0c             	sub    $0xc,%esp
c0103453:	8d 80 55 9a fd ff    	lea    -0x265ab(%eax),%eax
c0103459:	50                   	push   %eax
c010345a:	e8 17 ff ff ff       	call   c0103376 <cons_intr>
c010345f:	83 c4 10             	add    $0x10,%esp
    }
}
c0103462:	90                   	nop
c0103463:	c9                   	leave  
c0103464:	c3                   	ret    

c0103465 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0103465:	55                   	push   %ebp
c0103466:	89 e5                	mov    %esp,%ebp
c0103468:	53                   	push   %ebx
c0103469:	83 ec 24             	sub    $0x24,%esp
c010346c:	e8 10 03 00 00       	call   c0103781 <__x86.get_pc_thunk.cx>
c0103471:	81 c1 0f 65 02 00    	add    $0x2650f,%ecx
c0103477:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010347d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0103481:	89 c2                	mov    %eax,%edx
c0103483:	ec                   	in     (%dx),%al
c0103484:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0103487:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010348b:	0f b6 c0             	movzbl %al,%eax
c010348e:	83 e0 01             	and    $0x1,%eax
c0103491:	85 c0                	test   %eax,%eax
c0103493:	75 0a                	jne    c010349f <kbd_proc_data+0x3a>
        return -1;
c0103495:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010349a:	e9 73 01 00 00       	jmp    c0103612 <kbd_proc_data+0x1ad>
c010349f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01034a5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01034a9:	89 c2                	mov    %eax,%edx
c01034ab:	ec                   	in     (%dx),%al
c01034ac:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01034af:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01034b3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01034b6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01034ba:	75 19                	jne    c01034d5 <kbd_proc_data+0x70>
        // E0 escape character
        shift |= E0ESC;
c01034bc:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c01034c2:	83 c8 40             	or     $0x40,%eax
c01034c5:	89 81 08 09 00 00    	mov    %eax,0x908(%ecx)
        return 0;
c01034cb:	b8 00 00 00 00       	mov    $0x0,%eax
c01034d0:	e9 3d 01 00 00       	jmp    c0103612 <kbd_proc_data+0x1ad>
    } else if (data & 0x80) {
c01034d5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01034d9:	84 c0                	test   %al,%al
c01034db:	79 4b                	jns    c0103528 <kbd_proc_data+0xc3>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01034dd:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c01034e3:	83 e0 40             	and    $0x40,%eax
c01034e6:	85 c0                	test   %eax,%eax
c01034e8:	75 09                	jne    c01034f3 <kbd_proc_data+0x8e>
c01034ea:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01034ee:	83 e0 7f             	and    $0x7f,%eax
c01034f1:	eb 04                	jmp    c01034f7 <kbd_proc_data+0x92>
c01034f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01034f7:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01034fa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01034fe:	0f b6 84 01 a0 f6 ff 	movzbl -0x960(%ecx,%eax,1),%eax
c0103505:	ff 
c0103506:	83 c8 40             	or     $0x40,%eax
c0103509:	0f b6 c0             	movzbl %al,%eax
c010350c:	f7 d0                	not    %eax
c010350e:	89 c2                	mov    %eax,%edx
c0103510:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c0103516:	21 d0                	and    %edx,%eax
c0103518:	89 81 08 09 00 00    	mov    %eax,0x908(%ecx)
        return 0;
c010351e:	b8 00 00 00 00       	mov    $0x0,%eax
c0103523:	e9 ea 00 00 00       	jmp    c0103612 <kbd_proc_data+0x1ad>
    } else if (shift & E0ESC) {
c0103528:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c010352e:	83 e0 40             	and    $0x40,%eax
c0103531:	85 c0                	test   %eax,%eax
c0103533:	74 13                	je     c0103548 <kbd_proc_data+0xe3>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0103535:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0103539:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c010353f:	83 e0 bf             	and    $0xffffffbf,%eax
c0103542:	89 81 08 09 00 00    	mov    %eax,0x908(%ecx)
    }

    shift |= shiftcode[data];
c0103548:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010354c:	0f b6 84 01 a0 f6 ff 	movzbl -0x960(%ecx,%eax,1),%eax
c0103553:	ff 
c0103554:	0f b6 d0             	movzbl %al,%edx
c0103557:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c010355d:	09 d0                	or     %edx,%eax
c010355f:	89 81 08 09 00 00    	mov    %eax,0x908(%ecx)
    shift ^= togglecode[data];
c0103565:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103569:	0f b6 84 01 a0 f7 ff 	movzbl -0x860(%ecx,%eax,1),%eax
c0103570:	ff 
c0103571:	0f b6 d0             	movzbl %al,%edx
c0103574:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c010357a:	31 d0                	xor    %edx,%eax
c010357c:	89 81 08 09 00 00    	mov    %eax,0x908(%ecx)

    c = charcode[shift & (CTL | SHIFT)][data];
c0103582:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c0103588:	83 e0 03             	and    $0x3,%eax
c010358b:	8b 94 81 44 00 00 00 	mov    0x44(%ecx,%eax,4),%edx
c0103592:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103596:	01 d0                	add    %edx,%eax
c0103598:	0f b6 00             	movzbl (%eax),%eax
c010359b:	0f b6 c0             	movzbl %al,%eax
c010359e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01035a1:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c01035a7:	83 e0 08             	and    $0x8,%eax
c01035aa:	85 c0                	test   %eax,%eax
c01035ac:	74 22                	je     c01035d0 <kbd_proc_data+0x16b>
        if ('a' <= c && c <= 'z')
c01035ae:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01035b2:	7e 0c                	jle    c01035c0 <kbd_proc_data+0x15b>
c01035b4:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01035b8:	7f 06                	jg     c01035c0 <kbd_proc_data+0x15b>
            c += 'A' - 'a';
c01035ba:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01035be:	eb 10                	jmp    c01035d0 <kbd_proc_data+0x16b>
        else if ('A' <= c && c <= 'Z')
c01035c0:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01035c4:	7e 0a                	jle    c01035d0 <kbd_proc_data+0x16b>
c01035c6:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01035ca:	7f 04                	jg     c01035d0 <kbd_proc_data+0x16b>
            c += 'a' - 'A';
c01035cc:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01035d0:	8b 81 08 09 00 00    	mov    0x908(%ecx),%eax
c01035d6:	f7 d0                	not    %eax
c01035d8:	83 e0 06             	and    $0x6,%eax
c01035db:	85 c0                	test   %eax,%eax
c01035dd:	75 30                	jne    c010360f <kbd_proc_data+0x1aa>
c01035df:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01035e6:	75 27                	jne    c010360f <kbd_proc_data+0x1aa>
        cprintf("Rebooting!\n");
c01035e8:	83 ec 0c             	sub    $0xc,%esp
c01035eb:	8d 81 ed 29 fe ff    	lea    -0x1d613(%ecx),%eax
c01035f1:	50                   	push   %eax
c01035f2:	89 cb                	mov    %ecx,%ebx
c01035f4:	e8 3b cd ff ff       	call   c0100334 <cprintf>
c01035f9:	83 c4 10             	add    $0x10,%esp
c01035fc:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0103602:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103606:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010360a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c010360e:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010360f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103612:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103615:	c9                   	leave  
c0103616:	c3                   	ret    

c0103617 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0103617:	55                   	push   %ebp
c0103618:	89 e5                	mov    %esp,%ebp
c010361a:	83 ec 08             	sub    $0x8,%esp
c010361d:	e8 9b cc ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103622:	05 5e 63 02 00       	add    $0x2635e,%eax
    cons_intr(kbd_proc_data);
c0103627:	83 ec 0c             	sub    $0xc,%esp
c010362a:	8d 80 e5 9a fd ff    	lea    -0x2651b(%eax),%eax
c0103630:	50                   	push   %eax
c0103631:	e8 40 fd ff ff       	call   c0103376 <cons_intr>
c0103636:	83 c4 10             	add    $0x10,%esp
}
c0103639:	90                   	nop
c010363a:	c9                   	leave  
c010363b:	c3                   	ret    

c010363c <kbd_init>:

static void
kbd_init(void) {
c010363c:	55                   	push   %ebp
c010363d:	89 e5                	mov    %esp,%ebp
c010363f:	53                   	push   %ebx
c0103640:	83 ec 04             	sub    $0x4,%esp
c0103643:	e8 79 cc ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103648:	81 c3 38 63 02 00    	add    $0x26338,%ebx
    // drain the kbd buffer
    kbd_intr();
c010364e:	e8 c4 ff ff ff       	call   c0103617 <kbd_intr>
    pic_enable(IRQ_KBD);
c0103653:	83 ec 0c             	sub    $0xc,%esp
c0103656:	6a 01                	push   $0x1
c0103658:	e8 8d 01 00 00       	call   c01037ea <pic_enable>
c010365d:	83 c4 10             	add    $0x10,%esp
}
c0103660:	90                   	nop
c0103661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103664:	c9                   	leave  
c0103665:	c3                   	ret    

c0103666 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0103666:	55                   	push   %ebp
c0103667:	89 e5                	mov    %esp,%ebp
c0103669:	53                   	push   %ebx
c010366a:	83 ec 04             	sub    $0x4,%esp
c010366d:	e8 4f cc ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103672:	81 c3 0e 63 02 00    	add    $0x2630e,%ebx
    cga_init();
c0103678:	e8 b4 f7 ff ff       	call   c0102e31 <cga_init>
    serial_init();
c010367d:	e8 a3 f8 ff ff       	call   c0102f25 <serial_init>
    kbd_init();
c0103682:	e8 b5 ff ff ff       	call   c010363c <kbd_init>
    if (!serial_exists) {
c0103687:	8b 83 e8 06 00 00    	mov    0x6e8(%ebx),%eax
c010368d:	85 c0                	test   %eax,%eax
c010368f:	75 12                	jne    c01036a3 <cons_init+0x3d>
        cprintf("serial port does not exist!!\n");
c0103691:	83 ec 0c             	sub    $0xc,%esp
c0103694:	8d 83 f9 29 fe ff    	lea    -0x1d607(%ebx),%eax
c010369a:	50                   	push   %eax
c010369b:	e8 94 cc ff ff       	call   c0100334 <cprintf>
c01036a0:	83 c4 10             	add    $0x10,%esp
    }
}
c01036a3:	90                   	nop
c01036a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01036a7:	c9                   	leave  
c01036a8:	c3                   	ret    

c01036a9 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01036a9:	55                   	push   %ebp
c01036aa:	89 e5                	mov    %esp,%ebp
c01036ac:	83 ec 18             	sub    $0x18,%esp
c01036af:	e8 09 cc ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01036b4:	05 cc 62 02 00       	add    $0x262cc,%eax
    bool intr_flag;
    local_intr_save(intr_flag);
c01036b9:	e8 bf f6 ff ff       	call   c0102d7d <__intr_save>
c01036be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01036c1:	83 ec 0c             	sub    $0xc,%esp
c01036c4:	ff 75 08             	pushl  0x8(%ebp)
c01036c7:	e8 d5 f9 ff ff       	call   c01030a1 <lpt_putc>
c01036cc:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c01036cf:	83 ec 0c             	sub    $0xc,%esp
c01036d2:	ff 75 08             	pushl  0x8(%ebp)
c01036d5:	e8 08 fa ff ff       	call   c01030e2 <cga_putc>
c01036da:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c01036dd:	83 ec 0c             	sub    $0xc,%esp
c01036e0:	ff 75 08             	pushl  0x8(%ebp)
c01036e3:	e8 4d fc ff ff       	call   c0103335 <serial_putc>
c01036e8:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01036eb:	83 ec 0c             	sub    $0xc,%esp
c01036ee:	ff 75 f4             	pushl  -0xc(%ebp)
c01036f1:	e8 c3 f6 ff ff       	call   c0102db9 <__intr_restore>
c01036f6:	83 c4 10             	add    $0x10,%esp
}
c01036f9:	90                   	nop
c01036fa:	c9                   	leave  
c01036fb:	c3                   	ret    

c01036fc <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01036fc:	55                   	push   %ebp
c01036fd:	89 e5                	mov    %esp,%ebp
c01036ff:	53                   	push   %ebx
c0103700:	83 ec 14             	sub    $0x14,%esp
c0103703:	e8 b9 cb ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103708:	81 c3 78 62 02 00    	add    $0x26278,%ebx
    int c = 0;
c010370e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103715:	e8 63 f6 ff ff       	call   c0102d7d <__intr_save>
c010371a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010371d:	e8 14 fd ff ff       	call   c0103436 <serial_intr>
        kbd_intr();
c0103722:	e8 f0 fe ff ff       	call   c0103617 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0103727:	8b 93 00 09 00 00    	mov    0x900(%ebx),%edx
c010372d:	8b 83 04 09 00 00    	mov    0x904(%ebx),%eax
c0103733:	39 c2                	cmp    %eax,%edx
c0103735:	74 34                	je     c010376b <cons_getc+0x6f>
            c = cons.buf[cons.rpos ++];
c0103737:	8b 83 00 09 00 00    	mov    0x900(%ebx),%eax
c010373d:	8d 50 01             	lea    0x1(%eax),%edx
c0103740:	89 93 00 09 00 00    	mov    %edx,0x900(%ebx)
c0103746:	0f b6 84 03 00 07 00 	movzbl 0x700(%ebx,%eax,1),%eax
c010374d:	00 
c010374e:	0f b6 c0             	movzbl %al,%eax
c0103751:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0103754:	8b 83 00 09 00 00    	mov    0x900(%ebx),%eax
c010375a:	3d 00 02 00 00       	cmp    $0x200,%eax
c010375f:	75 0a                	jne    c010376b <cons_getc+0x6f>
                cons.rpos = 0;
c0103761:	c7 83 00 09 00 00 00 	movl   $0x0,0x900(%ebx)
c0103768:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010376b:	83 ec 0c             	sub    $0xc,%esp
c010376e:	ff 75 f0             	pushl  -0x10(%ebp)
c0103771:	e8 43 f6 ff ff       	call   c0102db9 <__intr_restore>
c0103776:	83 c4 10             	add    $0x10,%esp
    return c;
c0103779:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010377c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010377f:	c9                   	leave  
c0103780:	c3                   	ret    

c0103781 <__x86.get_pc_thunk.cx>:
c0103781:	8b 0c 24             	mov    (%esp),%ecx
c0103784:	c3                   	ret    

c0103785 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0103785:	55                   	push   %ebp
c0103786:	89 e5                	mov    %esp,%ebp
c0103788:	83 ec 14             	sub    $0x14,%esp
c010378b:	e8 2d cb ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103790:	05 f0 61 02 00       	add    $0x261f0,%eax
c0103795:	8b 55 08             	mov    0x8(%ebp),%edx
c0103798:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
    irq_mask = mask;
c010379c:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c01037a0:	66 89 90 a0 fb ff ff 	mov    %dx,-0x460(%eax)
    if (did_init) {
c01037a7:	8b 80 0c 09 00 00    	mov    0x90c(%eax),%eax
c01037ad:	85 c0                	test   %eax,%eax
c01037af:	74 36                	je     c01037e7 <pic_setmask+0x62>
        outb(IO_PIC1 + 1, mask);
c01037b1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01037b5:	0f b6 c0             	movzbl %al,%eax
c01037b8:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01037be:	88 45 f9             	mov    %al,-0x7(%ebp)
c01037c1:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01037c5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01037c9:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01037ca:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01037ce:	66 c1 e8 08          	shr    $0x8,%ax
c01037d2:	0f b6 c0             	movzbl %al,%eax
c01037d5:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01037db:	88 45 fd             	mov    %al,-0x3(%ebp)
c01037de:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01037e2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01037e6:	ee                   	out    %al,(%dx)
    }
}
c01037e7:	90                   	nop
c01037e8:	c9                   	leave  
c01037e9:	c3                   	ret    

c01037ea <pic_enable>:

void
pic_enable(unsigned int irq) {
c01037ea:	55                   	push   %ebp
c01037eb:	89 e5                	mov    %esp,%ebp
c01037ed:	53                   	push   %ebx
c01037ee:	e8 ca ca ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01037f3:	05 8d 61 02 00       	add    $0x2618d,%eax
    pic_setmask(irq_mask & ~(1 << irq));
c01037f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01037fb:	bb 01 00 00 00       	mov    $0x1,%ebx
c0103800:	89 d1                	mov    %edx,%ecx
c0103802:	d3 e3                	shl    %cl,%ebx
c0103804:	89 da                	mov    %ebx,%edx
c0103806:	f7 d2                	not    %edx
c0103808:	0f b7 80 a0 fb ff ff 	movzwl -0x460(%eax),%eax
c010380f:	21 d0                	and    %edx,%eax
c0103811:	0f b7 c0             	movzwl %ax,%eax
c0103814:	50                   	push   %eax
c0103815:	e8 6b ff ff ff       	call   c0103785 <pic_setmask>
c010381a:	83 c4 04             	add    $0x4,%esp
}
c010381d:	90                   	nop
c010381e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103821:	c9                   	leave  
c0103822:	c3                   	ret    

c0103823 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0103823:	55                   	push   %ebp
c0103824:	89 e5                	mov    %esp,%ebp
c0103826:	83 ec 40             	sub    $0x40,%esp
c0103829:	e8 53 ff ff ff       	call   c0103781 <__x86.get_pc_thunk.cx>
c010382e:	81 c1 52 61 02 00    	add    $0x26152,%ecx
    did_init = 1;
c0103834:	c7 81 0c 09 00 00 01 	movl   $0x1,0x90c(%ecx)
c010383b:	00 00 00 
c010383e:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0103844:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0103848:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010384c:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0103850:	ee                   	out    %al,(%dx)
c0103851:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0103857:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c010385b:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010385f:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0103863:	ee                   	out    %al,(%dx)
c0103864:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010386a:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c010386e:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0103872:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0103876:	ee                   	out    %al,(%dx)
c0103877:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010387d:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0103881:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0103885:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0103889:	ee                   	out    %al,(%dx)
c010388a:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0103890:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c0103894:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0103898:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010389c:	ee                   	out    %al,(%dx)
c010389d:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01038a3:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c01038a7:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01038ab:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01038af:	ee                   	out    %al,(%dx)
c01038b0:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01038b6:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c01038ba:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01038be:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01038c2:	ee                   	out    %al,(%dx)
c01038c3:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01038c9:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c01038cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01038d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01038d5:	ee                   	out    %al,(%dx)
c01038d6:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01038dc:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c01038e0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01038e4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01038e8:	ee                   	out    %al,(%dx)
c01038e9:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01038ef:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c01038f3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01038f7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01038fb:	ee                   	out    %al,(%dx)
c01038fc:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0103902:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0103906:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010390a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010390e:	ee                   	out    %al,(%dx)
c010390f:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0103915:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0103919:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010391d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0103921:	ee                   	out    %al,(%dx)
c0103922:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0103928:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c010392c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0103930:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0103934:	ee                   	out    %al,(%dx)
c0103935:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010393b:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c010393f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0103943:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103947:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0103948:	0f b7 81 a0 fb ff ff 	movzwl -0x460(%ecx),%eax
c010394f:	66 83 f8 ff          	cmp    $0xffff,%ax
c0103953:	74 13                	je     c0103968 <pic_init+0x145>
        pic_setmask(irq_mask);
c0103955:	0f b7 81 a0 fb ff ff 	movzwl -0x460(%ecx),%eax
c010395c:	0f b7 c0             	movzwl %ax,%eax
c010395f:	50                   	push   %eax
c0103960:	e8 20 fe ff ff       	call   c0103785 <pic_setmask>
c0103965:	83 c4 04             	add    $0x4,%esp
    }
}
c0103968:	90                   	nop
c0103969:	c9                   	leave  
c010396a:	c3                   	ret    

c010396b <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010396b:	55                   	push   %ebp
c010396c:	89 e5                	mov    %esp,%ebp
c010396e:	e8 4a c9 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103973:	05 0d 60 02 00       	add    $0x2600d,%eax
    asm volatile ("sti");
c0103978:	fb                   	sti    
    sti();
}
c0103979:	90                   	nop
c010397a:	5d                   	pop    %ebp
c010397b:	c3                   	ret    

c010397c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010397c:	55                   	push   %ebp
c010397d:	89 e5                	mov    %esp,%ebp
c010397f:	e8 39 c9 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103984:	05 fc 5f 02 00       	add    $0x25ffc,%eax
    asm volatile ("cli" ::: "memory");
c0103989:	fa                   	cli    
    cli();
}
c010398a:	90                   	nop
c010398b:	5d                   	pop    %ebp
c010398c:	c3                   	ret    

c010398d <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010398d:	55                   	push   %ebp
c010398e:	89 e5                	mov    %esp,%ebp
c0103990:	53                   	push   %ebx
c0103991:	83 ec 04             	sub    $0x4,%esp
c0103994:	e8 24 c9 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103999:	05 e7 5f 02 00       	add    $0x25fe7,%eax
    cprintf("%d ticks\n",TICK_NUM);
c010399e:	83 ec 08             	sub    $0x8,%esp
c01039a1:	6a 64                	push   $0x64
c01039a3:	8d 90 18 2a fe ff    	lea    -0x1d5e8(%eax),%edx
c01039a9:	52                   	push   %edx
c01039aa:	89 c3                	mov    %eax,%ebx
c01039ac:	e8 83 c9 ff ff       	call   c0100334 <cprintf>
c01039b1:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01039b4:	90                   	nop
c01039b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01039b8:	c9                   	leave  
c01039b9:	c3                   	ret    

c01039ba <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01039ba:	55                   	push   %ebp
c01039bb:	89 e5                	mov    %esp,%ebp
c01039bd:	83 ec 10             	sub    $0x10,%esp
c01039c0:	e8 f8 c8 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01039c5:	05 bb 5f 02 00       	add    $0x25fbb,%eax
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01039ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01039d1:	e9 c7 00 00 00       	jmp    c0103a9d <idt_init+0xe3>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01039d6:	c7 c2 22 95 12 c0    	mov    $0xc0129522,%edx
c01039dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
c01039df:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
c01039e2:	89 d1                	mov    %edx,%ecx
c01039e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01039e7:	66 89 8c d0 20 09 00 	mov    %cx,0x920(%eax,%edx,8)
c01039ee:	00 
c01039ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01039f2:	66 c7 84 d0 22 09 00 	movw   $0x8,0x922(%eax,%edx,8)
c01039f9:	00 08 00 
c01039fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01039ff:	0f b6 8c d0 24 09 00 	movzbl 0x924(%eax,%edx,8),%ecx
c0103a06:	00 
c0103a07:	83 e1 e0             	and    $0xffffffe0,%ecx
c0103a0a:	88 8c d0 24 09 00 00 	mov    %cl,0x924(%eax,%edx,8)
c0103a11:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103a14:	0f b6 8c d0 24 09 00 	movzbl 0x924(%eax,%edx,8),%ecx
c0103a1b:	00 
c0103a1c:	83 e1 1f             	and    $0x1f,%ecx
c0103a1f:	88 8c d0 24 09 00 00 	mov    %cl,0x924(%eax,%edx,8)
c0103a26:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103a29:	0f b6 8c d0 25 09 00 	movzbl 0x925(%eax,%edx,8),%ecx
c0103a30:	00 
c0103a31:	83 e1 f0             	and    $0xfffffff0,%ecx
c0103a34:	83 c9 0e             	or     $0xe,%ecx
c0103a37:	88 8c d0 25 09 00 00 	mov    %cl,0x925(%eax,%edx,8)
c0103a3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103a41:	0f b6 8c d0 25 09 00 	movzbl 0x925(%eax,%edx,8),%ecx
c0103a48:	00 
c0103a49:	83 e1 ef             	and    $0xffffffef,%ecx
c0103a4c:	88 8c d0 25 09 00 00 	mov    %cl,0x925(%eax,%edx,8)
c0103a53:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103a56:	0f b6 8c d0 25 09 00 	movzbl 0x925(%eax,%edx,8),%ecx
c0103a5d:	00 
c0103a5e:	83 e1 9f             	and    $0xffffff9f,%ecx
c0103a61:	88 8c d0 25 09 00 00 	mov    %cl,0x925(%eax,%edx,8)
c0103a68:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103a6b:	0f b6 8c d0 25 09 00 	movzbl 0x925(%eax,%edx,8),%ecx
c0103a72:	00 
c0103a73:	83 c9 80             	or     $0xffffff80,%ecx
c0103a76:	88 8c d0 25 09 00 00 	mov    %cl,0x925(%eax,%edx,8)
c0103a7d:	c7 c2 22 95 12 c0    	mov    $0xc0129522,%edx
c0103a83:	8b 4d fc             	mov    -0x4(%ebp),%ecx
c0103a86:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
c0103a89:	c1 ea 10             	shr    $0x10,%edx
c0103a8c:	89 d1                	mov    %edx,%ecx
c0103a8e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103a91:	66 89 8c d0 26 09 00 	mov    %cx,0x926(%eax,%edx,8)
c0103a98:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0103a99:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0103a9d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103aa0:	81 fa ff 00 00 00    	cmp    $0xff,%edx
c0103aa6:	0f 86 2a ff ff ff    	jbe    c01039d6 <idt_init+0x1c>
c0103aac:	8d 80 60 00 00 00    	lea    0x60(%eax),%eax
c0103ab2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0103ab5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103ab8:	0f 01 18             	lidtl  (%eax)
    }
    lidt(&idt_pd);
}
c0103abb:	90                   	nop
c0103abc:	c9                   	leave  
c0103abd:	c3                   	ret    

c0103abe <trapname>:

static const char *
trapname(int trapno) {
c0103abe:	55                   	push   %ebp
c0103abf:	89 e5                	mov    %esp,%ebp
c0103ac1:	e8 f7 c7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103ac6:	05 ba 5e 02 00       	add    $0x25eba,%eax
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0103acb:	8b 55 08             	mov    0x8(%ebp),%edx
c0103ace:	83 fa 13             	cmp    $0x13,%edx
c0103ad1:	77 0c                	ja     c0103adf <trapname+0x21>
        return excnames[trapno];
c0103ad3:	8b 55 08             	mov    0x8(%ebp),%edx
c0103ad6:	8b 84 90 20 01 00 00 	mov    0x120(%eax,%edx,4),%eax
c0103add:	eb 1a                	jmp    c0103af9 <trapname+0x3b>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0103adf:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0103ae3:	7e 0e                	jle    c0103af3 <trapname+0x35>
c0103ae5:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0103ae9:	7f 08                	jg     c0103af3 <trapname+0x35>
        return "Hardware Interrupt";
c0103aeb:	8d 80 22 2a fe ff    	lea    -0x1d5de(%eax),%eax
c0103af1:	eb 06                	jmp    c0103af9 <trapname+0x3b>
    }
    return "(unknown trap)";
c0103af3:	8d 80 35 2a fe ff    	lea    -0x1d5cb(%eax),%eax
}
c0103af9:	5d                   	pop    %ebp
c0103afa:	c3                   	ret    

c0103afb <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0103afb:	55                   	push   %ebp
c0103afc:	89 e5                	mov    %esp,%ebp
c0103afe:	e8 ba c7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103b03:	05 7d 5e 02 00       	add    $0x25e7d,%eax
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0103b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b0b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103b0f:	66 83 f8 08          	cmp    $0x8,%ax
c0103b13:	0f 94 c0             	sete   %al
c0103b16:	0f b6 c0             	movzbl %al,%eax
}
c0103b19:	5d                   	pop    %ebp
c0103b1a:	c3                   	ret    

c0103b1b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0103b1b:	55                   	push   %ebp
c0103b1c:	89 e5                	mov    %esp,%ebp
c0103b1e:	53                   	push   %ebx
c0103b1f:	83 ec 14             	sub    $0x14,%esp
c0103b22:	e8 9a c7 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103b27:	81 c3 59 5e 02 00    	add    $0x25e59,%ebx
    cprintf("trapframe at %p\n", tf);
c0103b2d:	83 ec 08             	sub    $0x8,%esp
c0103b30:	ff 75 08             	pushl  0x8(%ebp)
c0103b33:	8d 83 76 2a fe ff    	lea    -0x1d58a(%ebx),%eax
c0103b39:	50                   	push   %eax
c0103b3a:	e8 f5 c7 ff ff       	call   c0100334 <cprintf>
c0103b3f:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c0103b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b45:	83 ec 0c             	sub    $0xc,%esp
c0103b48:	50                   	push   %eax
c0103b49:	e8 d3 01 00 00       	call   c0103d21 <print_regs>
c0103b4e:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0103b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b54:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0103b58:	0f b7 c0             	movzwl %ax,%eax
c0103b5b:	83 ec 08             	sub    $0x8,%esp
c0103b5e:	50                   	push   %eax
c0103b5f:	8d 83 87 2a fe ff    	lea    -0x1d579(%ebx),%eax
c0103b65:	50                   	push   %eax
c0103b66:	e8 c9 c7 ff ff       	call   c0100334 <cprintf>
c0103b6b:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0103b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b71:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0103b75:	0f b7 c0             	movzwl %ax,%eax
c0103b78:	83 ec 08             	sub    $0x8,%esp
c0103b7b:	50                   	push   %eax
c0103b7c:	8d 83 9a 2a fe ff    	lea    -0x1d566(%ebx),%eax
c0103b82:	50                   	push   %eax
c0103b83:	e8 ac c7 ff ff       	call   c0100334 <cprintf>
c0103b88:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0103b8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b8e:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0103b92:	0f b7 c0             	movzwl %ax,%eax
c0103b95:	83 ec 08             	sub    $0x8,%esp
c0103b98:	50                   	push   %eax
c0103b99:	8d 83 ad 2a fe ff    	lea    -0x1d553(%ebx),%eax
c0103b9f:	50                   	push   %eax
c0103ba0:	e8 8f c7 ff ff       	call   c0100334 <cprintf>
c0103ba5:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0103ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bab:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0103baf:	0f b7 c0             	movzwl %ax,%eax
c0103bb2:	83 ec 08             	sub    $0x8,%esp
c0103bb5:	50                   	push   %eax
c0103bb6:	8d 83 c0 2a fe ff    	lea    -0x1d540(%ebx),%eax
c0103bbc:	50                   	push   %eax
c0103bbd:	e8 72 c7 ff ff       	call   c0100334 <cprintf>
c0103bc2:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0103bc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bc8:	8b 40 30             	mov    0x30(%eax),%eax
c0103bcb:	83 ec 0c             	sub    $0xc,%esp
c0103bce:	50                   	push   %eax
c0103bcf:	e8 ea fe ff ff       	call   c0103abe <trapname>
c0103bd4:	83 c4 10             	add    $0x10,%esp
c0103bd7:	89 c2                	mov    %eax,%edx
c0103bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bdc:	8b 40 30             	mov    0x30(%eax),%eax
c0103bdf:	83 ec 04             	sub    $0x4,%esp
c0103be2:	52                   	push   %edx
c0103be3:	50                   	push   %eax
c0103be4:	8d 83 d3 2a fe ff    	lea    -0x1d52d(%ebx),%eax
c0103bea:	50                   	push   %eax
c0103beb:	e8 44 c7 ff ff       	call   c0100334 <cprintf>
c0103bf0:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0103bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf6:	8b 40 34             	mov    0x34(%eax),%eax
c0103bf9:	83 ec 08             	sub    $0x8,%esp
c0103bfc:	50                   	push   %eax
c0103bfd:	8d 83 e5 2a fe ff    	lea    -0x1d51b(%ebx),%eax
c0103c03:	50                   	push   %eax
c0103c04:	e8 2b c7 ff ff       	call   c0100334 <cprintf>
c0103c09:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0103c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c0f:	8b 40 38             	mov    0x38(%eax),%eax
c0103c12:	83 ec 08             	sub    $0x8,%esp
c0103c15:	50                   	push   %eax
c0103c16:	8d 83 f4 2a fe ff    	lea    -0x1d50c(%ebx),%eax
c0103c1c:	50                   	push   %eax
c0103c1d:	e8 12 c7 ff ff       	call   c0100334 <cprintf>
c0103c22:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0103c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c28:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103c2c:	0f b7 c0             	movzwl %ax,%eax
c0103c2f:	83 ec 08             	sub    $0x8,%esp
c0103c32:	50                   	push   %eax
c0103c33:	8d 83 03 2b fe ff    	lea    -0x1d4fd(%ebx),%eax
c0103c39:	50                   	push   %eax
c0103c3a:	e8 f5 c6 ff ff       	call   c0100334 <cprintf>
c0103c3f:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0103c42:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c45:	8b 40 40             	mov    0x40(%eax),%eax
c0103c48:	83 ec 08             	sub    $0x8,%esp
c0103c4b:	50                   	push   %eax
c0103c4c:	8d 83 16 2b fe ff    	lea    -0x1d4ea(%ebx),%eax
c0103c52:	50                   	push   %eax
c0103c53:	e8 dc c6 ff ff       	call   c0100334 <cprintf>
c0103c58:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0103c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c62:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0103c69:	eb 41                	jmp    c0103cac <print_trapframe+0x191>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0103c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c6e:	8b 50 40             	mov    0x40(%eax),%edx
c0103c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c74:	21 d0                	and    %edx,%eax
c0103c76:	85 c0                	test   %eax,%eax
c0103c78:	74 2b                	je     c0103ca5 <print_trapframe+0x18a>
c0103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c7d:	8b 84 83 80 00 00 00 	mov    0x80(%ebx,%eax,4),%eax
c0103c84:	85 c0                	test   %eax,%eax
c0103c86:	74 1d                	je     c0103ca5 <print_trapframe+0x18a>
            cprintf("%s,", IA32flags[i]);
c0103c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c8b:	8b 84 83 80 00 00 00 	mov    0x80(%ebx,%eax,4),%eax
c0103c92:	83 ec 08             	sub    $0x8,%esp
c0103c95:	50                   	push   %eax
c0103c96:	8d 83 25 2b fe ff    	lea    -0x1d4db(%ebx),%eax
c0103c9c:	50                   	push   %eax
c0103c9d:	e8 92 c6 ff ff       	call   c0100334 <cprintf>
c0103ca2:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0103ca5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103ca9:	d1 65 f0             	shll   -0x10(%ebp)
c0103cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103caf:	83 f8 17             	cmp    $0x17,%eax
c0103cb2:	76 b7                	jbe    c0103c6b <print_trapframe+0x150>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0103cb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb7:	8b 40 40             	mov    0x40(%eax),%eax
c0103cba:	c1 e8 0c             	shr    $0xc,%eax
c0103cbd:	83 e0 03             	and    $0x3,%eax
c0103cc0:	83 ec 08             	sub    $0x8,%esp
c0103cc3:	50                   	push   %eax
c0103cc4:	8d 83 29 2b fe ff    	lea    -0x1d4d7(%ebx),%eax
c0103cca:	50                   	push   %eax
c0103ccb:	e8 64 c6 ff ff       	call   c0100334 <cprintf>
c0103cd0:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c0103cd3:	83 ec 0c             	sub    $0xc,%esp
c0103cd6:	ff 75 08             	pushl  0x8(%ebp)
c0103cd9:	e8 1d fe ff ff       	call   c0103afb <trap_in_kernel>
c0103cde:	83 c4 10             	add    $0x10,%esp
c0103ce1:	85 c0                	test   %eax,%eax
c0103ce3:	75 36                	jne    c0103d1b <print_trapframe+0x200>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0103ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ce8:	8b 40 44             	mov    0x44(%eax),%eax
c0103ceb:	83 ec 08             	sub    $0x8,%esp
c0103cee:	50                   	push   %eax
c0103cef:	8d 83 32 2b fe ff    	lea    -0x1d4ce(%ebx),%eax
c0103cf5:	50                   	push   %eax
c0103cf6:	e8 39 c6 ff ff       	call   c0100334 <cprintf>
c0103cfb:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d01:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0103d05:	0f b7 c0             	movzwl %ax,%eax
c0103d08:	83 ec 08             	sub    $0x8,%esp
c0103d0b:	50                   	push   %eax
c0103d0c:	8d 83 41 2b fe ff    	lea    -0x1d4bf(%ebx),%eax
c0103d12:	50                   	push   %eax
c0103d13:	e8 1c c6 ff ff       	call   c0100334 <cprintf>
c0103d18:	83 c4 10             	add    $0x10,%esp
    }
}
c0103d1b:	90                   	nop
c0103d1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103d1f:	c9                   	leave  
c0103d20:	c3                   	ret    

c0103d21 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0103d21:	55                   	push   %ebp
c0103d22:	89 e5                	mov    %esp,%ebp
c0103d24:	53                   	push   %ebx
c0103d25:	83 ec 04             	sub    $0x4,%esp
c0103d28:	e8 94 c5 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103d2d:	81 c3 53 5c 02 00    	add    $0x25c53,%ebx
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0103d33:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d36:	8b 00                	mov    (%eax),%eax
c0103d38:	83 ec 08             	sub    $0x8,%esp
c0103d3b:	50                   	push   %eax
c0103d3c:	8d 83 54 2b fe ff    	lea    -0x1d4ac(%ebx),%eax
c0103d42:	50                   	push   %eax
c0103d43:	e8 ec c5 ff ff       	call   c0100334 <cprintf>
c0103d48:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0103d4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d4e:	8b 40 04             	mov    0x4(%eax),%eax
c0103d51:	83 ec 08             	sub    $0x8,%esp
c0103d54:	50                   	push   %eax
c0103d55:	8d 83 63 2b fe ff    	lea    -0x1d49d(%ebx),%eax
c0103d5b:	50                   	push   %eax
c0103d5c:	e8 d3 c5 ff ff       	call   c0100334 <cprintf>
c0103d61:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0103d64:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d67:	8b 40 08             	mov    0x8(%eax),%eax
c0103d6a:	83 ec 08             	sub    $0x8,%esp
c0103d6d:	50                   	push   %eax
c0103d6e:	8d 83 72 2b fe ff    	lea    -0x1d48e(%ebx),%eax
c0103d74:	50                   	push   %eax
c0103d75:	e8 ba c5 ff ff       	call   c0100334 <cprintf>
c0103d7a:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0103d7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d80:	8b 40 0c             	mov    0xc(%eax),%eax
c0103d83:	83 ec 08             	sub    $0x8,%esp
c0103d86:	50                   	push   %eax
c0103d87:	8d 83 81 2b fe ff    	lea    -0x1d47f(%ebx),%eax
c0103d8d:	50                   	push   %eax
c0103d8e:	e8 a1 c5 ff ff       	call   c0100334 <cprintf>
c0103d93:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0103d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d99:	8b 40 10             	mov    0x10(%eax),%eax
c0103d9c:	83 ec 08             	sub    $0x8,%esp
c0103d9f:	50                   	push   %eax
c0103da0:	8d 83 90 2b fe ff    	lea    -0x1d470(%ebx),%eax
c0103da6:	50                   	push   %eax
c0103da7:	e8 88 c5 ff ff       	call   c0100334 <cprintf>
c0103dac:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0103daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103db2:	8b 40 14             	mov    0x14(%eax),%eax
c0103db5:	83 ec 08             	sub    $0x8,%esp
c0103db8:	50                   	push   %eax
c0103db9:	8d 83 9f 2b fe ff    	lea    -0x1d461(%ebx),%eax
c0103dbf:	50                   	push   %eax
c0103dc0:	e8 6f c5 ff ff       	call   c0100334 <cprintf>
c0103dc5:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0103dc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dcb:	8b 40 18             	mov    0x18(%eax),%eax
c0103dce:	83 ec 08             	sub    $0x8,%esp
c0103dd1:	50                   	push   %eax
c0103dd2:	8d 83 ae 2b fe ff    	lea    -0x1d452(%ebx),%eax
c0103dd8:	50                   	push   %eax
c0103dd9:	e8 56 c5 ff ff       	call   c0100334 <cprintf>
c0103dde:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0103de1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103de4:	8b 40 1c             	mov    0x1c(%eax),%eax
c0103de7:	83 ec 08             	sub    $0x8,%esp
c0103dea:	50                   	push   %eax
c0103deb:	8d 83 bd 2b fe ff    	lea    -0x1d443(%ebx),%eax
c0103df1:	50                   	push   %eax
c0103df2:	e8 3d c5 ff ff       	call   c0100334 <cprintf>
c0103df7:	83 c4 10             	add    $0x10,%esp
}
c0103dfa:	90                   	nop
c0103dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103dfe:	c9                   	leave  
c0103dff:	c3                   	ret    

c0103e00 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0103e00:	55                   	push   %ebp
c0103e01:	89 e5                	mov    %esp,%ebp
c0103e03:	56                   	push   %esi
c0103e04:	53                   	push   %ebx
c0103e05:	83 ec 10             	sub    $0x10,%esp
c0103e08:	e8 b0 c4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0103e0d:	05 73 5b 02 00       	add    $0x25b73,%eax
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0103e12:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e15:	8b 52 34             	mov    0x34(%edx),%edx
c0103e18:	83 e2 01             	and    $0x1,%edx
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103e1b:	85 d2                	test   %edx,%edx
c0103e1d:	74 08                	je     c0103e27 <print_pgfault+0x27>
c0103e1f:	8d 90 cc 2b fe ff    	lea    -0x1d434(%eax),%edx
c0103e25:	eb 06                	jmp    c0103e2d <print_pgfault+0x2d>
c0103e27:	8d 90 dd 2b fe ff    	lea    -0x1d423(%eax),%edx
            (tf->tf_err & 2) ? 'W' : 'R',
c0103e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0103e30:	8b 49 34             	mov    0x34(%ecx),%ecx
c0103e33:	83 e1 02             	and    $0x2,%ecx
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103e36:	85 c9                	test   %ecx,%ecx
c0103e38:	74 07                	je     c0103e41 <print_pgfault+0x41>
c0103e3a:	be 57 00 00 00       	mov    $0x57,%esi
c0103e3f:	eb 05                	jmp    c0103e46 <print_pgfault+0x46>
c0103e41:	be 52 00 00 00       	mov    $0x52,%esi
            (tf->tf_err & 4) ? 'U' : 'K',
c0103e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0103e49:	8b 49 34             	mov    0x34(%ecx),%ecx
c0103e4c:	83 e1 04             	and    $0x4,%ecx
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103e4f:	85 c9                	test   %ecx,%ecx
c0103e51:	74 07                	je     c0103e5a <print_pgfault+0x5a>
c0103e53:	bb 55 00 00 00       	mov    $0x55,%ebx
c0103e58:	eb 05                	jmp    c0103e5f <print_pgfault+0x5f>
c0103e5a:	bb 4b 00 00 00       	mov    $0x4b,%ebx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0103e5f:	0f 20 d1             	mov    %cr2,%ecx
c0103e62:	89 4d f4             	mov    %ecx,-0xc(%ebp)
    return cr2;
c0103e65:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0103e68:	83 ec 0c             	sub    $0xc,%esp
c0103e6b:	52                   	push   %edx
c0103e6c:	56                   	push   %esi
c0103e6d:	53                   	push   %ebx
c0103e6e:	51                   	push   %ecx
c0103e6f:	8d 90 ec 2b fe ff    	lea    -0x1d414(%eax),%edx
c0103e75:	52                   	push   %edx
c0103e76:	89 c3                	mov    %eax,%ebx
c0103e78:	e8 b7 c4 ff ff       	call   c0100334 <cprintf>
c0103e7d:	83 c4 20             	add    $0x20,%esp
}
c0103e80:	90                   	nop
c0103e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0103e84:	5b                   	pop    %ebx
c0103e85:	5e                   	pop    %esi
c0103e86:	5d                   	pop    %ebp
c0103e87:	c3                   	ret    

c0103e88 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0103e88:	55                   	push   %ebp
c0103e89:	89 e5                	mov    %esp,%ebp
c0103e8b:	53                   	push   %ebx
c0103e8c:	83 ec 14             	sub    $0x14,%esp
c0103e8f:	e8 2d c4 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103e94:	81 c3 ec 5a 02 00    	add    $0x25aec,%ebx
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0103e9a:	83 ec 0c             	sub    $0xc,%esp
c0103e9d:	ff 75 08             	pushl  0x8(%ebp)
c0103ea0:	e8 5b ff ff ff       	call   c0103e00 <print_pgfault>
c0103ea5:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c0103ea8:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c0103eae:	8b 00                	mov    (%eax),%eax
c0103eb0:	85 c0                	test   %eax,%eax
c0103eb2:	74 27                	je     c0103edb <pgfault_handler+0x53>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0103eb4:	0f 20 d0             	mov    %cr2,%eax
c0103eb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0103eba:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0103ebd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ec0:	8b 50 34             	mov    0x34(%eax),%edx
c0103ec3:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c0103ec9:	8b 00                	mov    (%eax),%eax
c0103ecb:	83 ec 04             	sub    $0x4,%esp
c0103ece:	51                   	push   %ecx
c0103ecf:	52                   	push   %edx
c0103ed0:	50                   	push   %eax
c0103ed1:	e8 c7 17 00 00       	call   c010569d <do_pgfault>
c0103ed6:	83 c4 10             	add    $0x10,%esp
c0103ed9:	eb 1b                	jmp    c0103ef6 <pgfault_handler+0x6e>
    }
    panic("unhandled page fault.\n");
c0103edb:	83 ec 04             	sub    $0x4,%esp
c0103ede:	8d 83 0f 2c fe ff    	lea    -0x1d3f1(%ebx),%eax
c0103ee4:	50                   	push   %eax
c0103ee5:	68 a5 00 00 00       	push   $0xa5
c0103eea:	8d 83 26 2c fe ff    	lea    -0x1d3da(%ebx),%eax
c0103ef0:	50                   	push   %eax
c0103ef1:	e8 1c db ff ff       	call   c0101a12 <__panic>
}
c0103ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103ef9:	c9                   	leave  
c0103efa:	c3                   	ret    

c0103efb <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0103efb:	55                   	push   %ebp
c0103efc:	89 e5                	mov    %esp,%ebp
c0103efe:	53                   	push   %ebx
c0103eff:	83 ec 14             	sub    $0x14,%esp
c0103f02:	e8 ba c3 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0103f07:	81 c3 79 5a 02 00    	add    $0x25a79,%ebx
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0103f0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f10:	8b 40 30             	mov    0x30(%eax),%eax
c0103f13:	83 f8 24             	cmp    $0x24,%eax
c0103f16:	0f 84 c6 00 00 00    	je     c0103fe2 <trap_dispatch+0xe7>
c0103f1c:	83 f8 24             	cmp    $0x24,%eax
c0103f1f:	77 18                	ja     c0103f39 <trap_dispatch+0x3e>
c0103f21:	83 f8 20             	cmp    $0x20,%eax
c0103f24:	74 7a                	je     c0103fa0 <trap_dispatch+0xa5>
c0103f26:	83 f8 21             	cmp    $0x21,%eax
c0103f29:	0f 84 dc 00 00 00    	je     c010400b <trap_dispatch+0x110>
c0103f2f:	83 f8 0e             	cmp    $0xe,%eax
c0103f32:	74 28                	je     c0103f5c <trap_dispatch+0x61>
c0103f34:	e9 13 01 00 00       	jmp    c010404c <trap_dispatch+0x151>
c0103f39:	83 f8 2e             	cmp    $0x2e,%eax
c0103f3c:	0f 82 0a 01 00 00    	jb     c010404c <trap_dispatch+0x151>
c0103f42:	83 f8 2f             	cmp    $0x2f,%eax
c0103f45:	0f 86 3b 01 00 00    	jbe    c0104086 <trap_dispatch+0x18b>
c0103f4b:	83 e8 78             	sub    $0x78,%eax
c0103f4e:	83 f8 01             	cmp    $0x1,%eax
c0103f51:	0f 87 f5 00 00 00    	ja     c010404c <trap_dispatch+0x151>
c0103f57:	e9 d5 00 00 00       	jmp    c0104031 <trap_dispatch+0x136>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0103f5c:	83 ec 0c             	sub    $0xc,%esp
c0103f5f:	ff 75 08             	pushl  0x8(%ebp)
c0103f62:	e8 21 ff ff ff       	call   c0103e88 <pgfault_handler>
c0103f67:	83 c4 10             	add    $0x10,%esp
c0103f6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103f71:	0f 84 12 01 00 00    	je     c0104089 <trap_dispatch+0x18e>
            print_trapframe(tf);
c0103f77:	83 ec 0c             	sub    $0xc,%esp
c0103f7a:	ff 75 08             	pushl  0x8(%ebp)
c0103f7d:	e8 99 fb ff ff       	call   c0103b1b <print_trapframe>
c0103f82:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c0103f85:	ff 75 f0             	pushl  -0x10(%ebp)
c0103f88:	8d 83 37 2c fe ff    	lea    -0x1d3c9(%ebx),%eax
c0103f8e:	50                   	push   %eax
c0103f8f:	68 b5 00 00 00       	push   $0xb5
c0103f94:	8d 83 26 2c fe ff    	lea    -0x1d3da(%ebx),%eax
c0103f9a:	50                   	push   %eax
c0103f9b:	e8 72 da ff ff       	call   c0101a12 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0103fa0:	c7 c0 94 cb 12 c0    	mov    $0xc012cb94,%eax
c0103fa6:	8b 00                	mov    (%eax),%eax
c0103fa8:	8d 50 01             	lea    0x1(%eax),%edx
c0103fab:	c7 c0 94 cb 12 c0    	mov    $0xc012cb94,%eax
c0103fb1:	89 10                	mov    %edx,(%eax)
        if (ticks % TICK_NUM == 0) {
c0103fb3:	c7 c0 94 cb 12 c0    	mov    $0xc012cb94,%eax
c0103fb9:	8b 08                	mov    (%eax),%ecx
c0103fbb:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0103fc0:	89 c8                	mov    %ecx,%eax
c0103fc2:	f7 e2                	mul    %edx
c0103fc4:	89 d0                	mov    %edx,%eax
c0103fc6:	c1 e8 05             	shr    $0x5,%eax
c0103fc9:	6b c0 64             	imul   $0x64,%eax,%eax
c0103fcc:	29 c1                	sub    %eax,%ecx
c0103fce:	89 c8                	mov    %ecx,%eax
c0103fd0:	85 c0                	test   %eax,%eax
c0103fd2:	0f 85 b4 00 00 00    	jne    c010408c <trap_dispatch+0x191>
            print_ticks();
c0103fd8:	e8 b0 f9 ff ff       	call   c010398d <print_ticks>
        }
        break;
c0103fdd:	e9 aa 00 00 00       	jmp    c010408c <trap_dispatch+0x191>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0103fe2:	e8 15 f7 ff ff       	call   c01036fc <cons_getc>
c0103fe7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0103fea:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0103fee:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0103ff2:	83 ec 04             	sub    $0x4,%esp
c0103ff5:	52                   	push   %edx
c0103ff6:	50                   	push   %eax
c0103ff7:	8d 83 52 2c fe ff    	lea    -0x1d3ae(%ebx),%eax
c0103ffd:	50                   	push   %eax
c0103ffe:	e8 31 c3 ff ff       	call   c0100334 <cprintf>
c0104003:	83 c4 10             	add    $0x10,%esp
        break;
c0104006:	e9 82 00 00 00       	jmp    c010408d <trap_dispatch+0x192>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010400b:	e8 ec f6 ff ff       	call   c01036fc <cons_getc>
c0104010:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0104013:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0104017:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010401b:	83 ec 04             	sub    $0x4,%esp
c010401e:	52                   	push   %edx
c010401f:	50                   	push   %eax
c0104020:	8d 83 64 2c fe ff    	lea    -0x1d39c(%ebx),%eax
c0104026:	50                   	push   %eax
c0104027:	e8 08 c3 ff ff       	call   c0100334 <cprintf>
c010402c:	83 c4 10             	add    $0x10,%esp
        break;
c010402f:	eb 5c                	jmp    c010408d <trap_dispatch+0x192>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0104031:	83 ec 04             	sub    $0x4,%esp
c0104034:	8d 83 73 2c fe ff    	lea    -0x1d38d(%ebx),%eax
c010403a:	50                   	push   %eax
c010403b:	68 d3 00 00 00       	push   $0xd3
c0104040:	8d 83 26 2c fe ff    	lea    -0x1d3da(%ebx),%eax
c0104046:	50                   	push   %eax
c0104047:	e8 c6 d9 ff ff       	call   c0101a12 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c010404c:	8b 45 08             	mov    0x8(%ebp),%eax
c010404f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0104053:	0f b7 c0             	movzwl %ax,%eax
c0104056:	83 e0 03             	and    $0x3,%eax
c0104059:	85 c0                	test   %eax,%eax
c010405b:	75 30                	jne    c010408d <trap_dispatch+0x192>
            print_trapframe(tf);
c010405d:	83 ec 0c             	sub    $0xc,%esp
c0104060:	ff 75 08             	pushl  0x8(%ebp)
c0104063:	e8 b3 fa ff ff       	call   c0103b1b <print_trapframe>
c0104068:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c010406b:	83 ec 04             	sub    $0x4,%esp
c010406e:	8d 83 83 2c fe ff    	lea    -0x1d37d(%ebx),%eax
c0104074:	50                   	push   %eax
c0104075:	68 dd 00 00 00       	push   $0xdd
c010407a:	8d 83 26 2c fe ff    	lea    -0x1d3da(%ebx),%eax
c0104080:	50                   	push   %eax
c0104081:	e8 8c d9 ff ff       	call   c0101a12 <__panic>
        break;
c0104086:	90                   	nop
c0104087:	eb 04                	jmp    c010408d <trap_dispatch+0x192>
        break;
c0104089:	90                   	nop
c010408a:	eb 01                	jmp    c010408d <trap_dispatch+0x192>
        break;
c010408c:	90                   	nop
        }
    }
}
c010408d:	90                   	nop
c010408e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104091:	c9                   	leave  
c0104092:	c3                   	ret    

c0104093 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0104093:	55                   	push   %ebp
c0104094:	89 e5                	mov    %esp,%ebp
c0104096:	83 ec 08             	sub    $0x8,%esp
c0104099:	e8 1f c2 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010409e:	05 e2 58 02 00       	add    $0x258e2,%eax
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01040a3:	83 ec 0c             	sub    $0xc,%esp
c01040a6:	ff 75 08             	pushl  0x8(%ebp)
c01040a9:	e8 4d fe ff ff       	call   c0103efb <trap_dispatch>
c01040ae:	83 c4 10             	add    $0x10,%esp
}
c01040b1:	90                   	nop
c01040b2:	c9                   	leave  
c01040b3:	c3                   	ret    

c01040b4 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01040b4:	6a 00                	push   $0x0
  pushl $0
c01040b6:	6a 00                	push   $0x0
  jmp __alltraps
c01040b8:	e9 67 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040bd <vector1>:
.globl vector1
vector1:
  pushl $0
c01040bd:	6a 00                	push   $0x0
  pushl $1
c01040bf:	6a 01                	push   $0x1
  jmp __alltraps
c01040c1:	e9 5e 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040c6 <vector2>:
.globl vector2
vector2:
  pushl $0
c01040c6:	6a 00                	push   $0x0
  pushl $2
c01040c8:	6a 02                	push   $0x2
  jmp __alltraps
c01040ca:	e9 55 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040cf <vector3>:
.globl vector3
vector3:
  pushl $0
c01040cf:	6a 00                	push   $0x0
  pushl $3
c01040d1:	6a 03                	push   $0x3
  jmp __alltraps
c01040d3:	e9 4c 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040d8 <vector4>:
.globl vector4
vector4:
  pushl $0
c01040d8:	6a 00                	push   $0x0
  pushl $4
c01040da:	6a 04                	push   $0x4
  jmp __alltraps
c01040dc:	e9 43 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040e1 <vector5>:
.globl vector5
vector5:
  pushl $0
c01040e1:	6a 00                	push   $0x0
  pushl $5
c01040e3:	6a 05                	push   $0x5
  jmp __alltraps
c01040e5:	e9 3a 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040ea <vector6>:
.globl vector6
vector6:
  pushl $0
c01040ea:	6a 00                	push   $0x0
  pushl $6
c01040ec:	6a 06                	push   $0x6
  jmp __alltraps
c01040ee:	e9 31 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040f3 <vector7>:
.globl vector7
vector7:
  pushl $0
c01040f3:	6a 00                	push   $0x0
  pushl $7
c01040f5:	6a 07                	push   $0x7
  jmp __alltraps
c01040f7:	e9 28 0a 00 00       	jmp    c0104b24 <__alltraps>

c01040fc <vector8>:
.globl vector8
vector8:
  pushl $8
c01040fc:	6a 08                	push   $0x8
  jmp __alltraps
c01040fe:	e9 21 0a 00 00       	jmp    c0104b24 <__alltraps>

c0104103 <vector9>:
.globl vector9
vector9:
  pushl $9
c0104103:	6a 09                	push   $0x9
  jmp __alltraps
c0104105:	e9 1a 0a 00 00       	jmp    c0104b24 <__alltraps>

c010410a <vector10>:
.globl vector10
vector10:
  pushl $10
c010410a:	6a 0a                	push   $0xa
  jmp __alltraps
c010410c:	e9 13 0a 00 00       	jmp    c0104b24 <__alltraps>

c0104111 <vector11>:
.globl vector11
vector11:
  pushl $11
c0104111:	6a 0b                	push   $0xb
  jmp __alltraps
c0104113:	e9 0c 0a 00 00       	jmp    c0104b24 <__alltraps>

c0104118 <vector12>:
.globl vector12
vector12:
  pushl $12
c0104118:	6a 0c                	push   $0xc
  jmp __alltraps
c010411a:	e9 05 0a 00 00       	jmp    c0104b24 <__alltraps>

c010411f <vector13>:
.globl vector13
vector13:
  pushl $13
c010411f:	6a 0d                	push   $0xd
  jmp __alltraps
c0104121:	e9 fe 09 00 00       	jmp    c0104b24 <__alltraps>

c0104126 <vector14>:
.globl vector14
vector14:
  pushl $14
c0104126:	6a 0e                	push   $0xe
  jmp __alltraps
c0104128:	e9 f7 09 00 00       	jmp    c0104b24 <__alltraps>

c010412d <vector15>:
.globl vector15
vector15:
  pushl $0
c010412d:	6a 00                	push   $0x0
  pushl $15
c010412f:	6a 0f                	push   $0xf
  jmp __alltraps
c0104131:	e9 ee 09 00 00       	jmp    c0104b24 <__alltraps>

c0104136 <vector16>:
.globl vector16
vector16:
  pushl $0
c0104136:	6a 00                	push   $0x0
  pushl $16
c0104138:	6a 10                	push   $0x10
  jmp __alltraps
c010413a:	e9 e5 09 00 00       	jmp    c0104b24 <__alltraps>

c010413f <vector17>:
.globl vector17
vector17:
  pushl $17
c010413f:	6a 11                	push   $0x11
  jmp __alltraps
c0104141:	e9 de 09 00 00       	jmp    c0104b24 <__alltraps>

c0104146 <vector18>:
.globl vector18
vector18:
  pushl $0
c0104146:	6a 00                	push   $0x0
  pushl $18
c0104148:	6a 12                	push   $0x12
  jmp __alltraps
c010414a:	e9 d5 09 00 00       	jmp    c0104b24 <__alltraps>

c010414f <vector19>:
.globl vector19
vector19:
  pushl $0
c010414f:	6a 00                	push   $0x0
  pushl $19
c0104151:	6a 13                	push   $0x13
  jmp __alltraps
c0104153:	e9 cc 09 00 00       	jmp    c0104b24 <__alltraps>

c0104158 <vector20>:
.globl vector20
vector20:
  pushl $0
c0104158:	6a 00                	push   $0x0
  pushl $20
c010415a:	6a 14                	push   $0x14
  jmp __alltraps
c010415c:	e9 c3 09 00 00       	jmp    c0104b24 <__alltraps>

c0104161 <vector21>:
.globl vector21
vector21:
  pushl $0
c0104161:	6a 00                	push   $0x0
  pushl $21
c0104163:	6a 15                	push   $0x15
  jmp __alltraps
c0104165:	e9 ba 09 00 00       	jmp    c0104b24 <__alltraps>

c010416a <vector22>:
.globl vector22
vector22:
  pushl $0
c010416a:	6a 00                	push   $0x0
  pushl $22
c010416c:	6a 16                	push   $0x16
  jmp __alltraps
c010416e:	e9 b1 09 00 00       	jmp    c0104b24 <__alltraps>

c0104173 <vector23>:
.globl vector23
vector23:
  pushl $0
c0104173:	6a 00                	push   $0x0
  pushl $23
c0104175:	6a 17                	push   $0x17
  jmp __alltraps
c0104177:	e9 a8 09 00 00       	jmp    c0104b24 <__alltraps>

c010417c <vector24>:
.globl vector24
vector24:
  pushl $0
c010417c:	6a 00                	push   $0x0
  pushl $24
c010417e:	6a 18                	push   $0x18
  jmp __alltraps
c0104180:	e9 9f 09 00 00       	jmp    c0104b24 <__alltraps>

c0104185 <vector25>:
.globl vector25
vector25:
  pushl $0
c0104185:	6a 00                	push   $0x0
  pushl $25
c0104187:	6a 19                	push   $0x19
  jmp __alltraps
c0104189:	e9 96 09 00 00       	jmp    c0104b24 <__alltraps>

c010418e <vector26>:
.globl vector26
vector26:
  pushl $0
c010418e:	6a 00                	push   $0x0
  pushl $26
c0104190:	6a 1a                	push   $0x1a
  jmp __alltraps
c0104192:	e9 8d 09 00 00       	jmp    c0104b24 <__alltraps>

c0104197 <vector27>:
.globl vector27
vector27:
  pushl $0
c0104197:	6a 00                	push   $0x0
  pushl $27
c0104199:	6a 1b                	push   $0x1b
  jmp __alltraps
c010419b:	e9 84 09 00 00       	jmp    c0104b24 <__alltraps>

c01041a0 <vector28>:
.globl vector28
vector28:
  pushl $0
c01041a0:	6a 00                	push   $0x0
  pushl $28
c01041a2:	6a 1c                	push   $0x1c
  jmp __alltraps
c01041a4:	e9 7b 09 00 00       	jmp    c0104b24 <__alltraps>

c01041a9 <vector29>:
.globl vector29
vector29:
  pushl $0
c01041a9:	6a 00                	push   $0x0
  pushl $29
c01041ab:	6a 1d                	push   $0x1d
  jmp __alltraps
c01041ad:	e9 72 09 00 00       	jmp    c0104b24 <__alltraps>

c01041b2 <vector30>:
.globl vector30
vector30:
  pushl $0
c01041b2:	6a 00                	push   $0x0
  pushl $30
c01041b4:	6a 1e                	push   $0x1e
  jmp __alltraps
c01041b6:	e9 69 09 00 00       	jmp    c0104b24 <__alltraps>

c01041bb <vector31>:
.globl vector31
vector31:
  pushl $0
c01041bb:	6a 00                	push   $0x0
  pushl $31
c01041bd:	6a 1f                	push   $0x1f
  jmp __alltraps
c01041bf:	e9 60 09 00 00       	jmp    c0104b24 <__alltraps>

c01041c4 <vector32>:
.globl vector32
vector32:
  pushl $0
c01041c4:	6a 00                	push   $0x0
  pushl $32
c01041c6:	6a 20                	push   $0x20
  jmp __alltraps
c01041c8:	e9 57 09 00 00       	jmp    c0104b24 <__alltraps>

c01041cd <vector33>:
.globl vector33
vector33:
  pushl $0
c01041cd:	6a 00                	push   $0x0
  pushl $33
c01041cf:	6a 21                	push   $0x21
  jmp __alltraps
c01041d1:	e9 4e 09 00 00       	jmp    c0104b24 <__alltraps>

c01041d6 <vector34>:
.globl vector34
vector34:
  pushl $0
c01041d6:	6a 00                	push   $0x0
  pushl $34
c01041d8:	6a 22                	push   $0x22
  jmp __alltraps
c01041da:	e9 45 09 00 00       	jmp    c0104b24 <__alltraps>

c01041df <vector35>:
.globl vector35
vector35:
  pushl $0
c01041df:	6a 00                	push   $0x0
  pushl $35
c01041e1:	6a 23                	push   $0x23
  jmp __alltraps
c01041e3:	e9 3c 09 00 00       	jmp    c0104b24 <__alltraps>

c01041e8 <vector36>:
.globl vector36
vector36:
  pushl $0
c01041e8:	6a 00                	push   $0x0
  pushl $36
c01041ea:	6a 24                	push   $0x24
  jmp __alltraps
c01041ec:	e9 33 09 00 00       	jmp    c0104b24 <__alltraps>

c01041f1 <vector37>:
.globl vector37
vector37:
  pushl $0
c01041f1:	6a 00                	push   $0x0
  pushl $37
c01041f3:	6a 25                	push   $0x25
  jmp __alltraps
c01041f5:	e9 2a 09 00 00       	jmp    c0104b24 <__alltraps>

c01041fa <vector38>:
.globl vector38
vector38:
  pushl $0
c01041fa:	6a 00                	push   $0x0
  pushl $38
c01041fc:	6a 26                	push   $0x26
  jmp __alltraps
c01041fe:	e9 21 09 00 00       	jmp    c0104b24 <__alltraps>

c0104203 <vector39>:
.globl vector39
vector39:
  pushl $0
c0104203:	6a 00                	push   $0x0
  pushl $39
c0104205:	6a 27                	push   $0x27
  jmp __alltraps
c0104207:	e9 18 09 00 00       	jmp    c0104b24 <__alltraps>

c010420c <vector40>:
.globl vector40
vector40:
  pushl $0
c010420c:	6a 00                	push   $0x0
  pushl $40
c010420e:	6a 28                	push   $0x28
  jmp __alltraps
c0104210:	e9 0f 09 00 00       	jmp    c0104b24 <__alltraps>

c0104215 <vector41>:
.globl vector41
vector41:
  pushl $0
c0104215:	6a 00                	push   $0x0
  pushl $41
c0104217:	6a 29                	push   $0x29
  jmp __alltraps
c0104219:	e9 06 09 00 00       	jmp    c0104b24 <__alltraps>

c010421e <vector42>:
.globl vector42
vector42:
  pushl $0
c010421e:	6a 00                	push   $0x0
  pushl $42
c0104220:	6a 2a                	push   $0x2a
  jmp __alltraps
c0104222:	e9 fd 08 00 00       	jmp    c0104b24 <__alltraps>

c0104227 <vector43>:
.globl vector43
vector43:
  pushl $0
c0104227:	6a 00                	push   $0x0
  pushl $43
c0104229:	6a 2b                	push   $0x2b
  jmp __alltraps
c010422b:	e9 f4 08 00 00       	jmp    c0104b24 <__alltraps>

c0104230 <vector44>:
.globl vector44
vector44:
  pushl $0
c0104230:	6a 00                	push   $0x0
  pushl $44
c0104232:	6a 2c                	push   $0x2c
  jmp __alltraps
c0104234:	e9 eb 08 00 00       	jmp    c0104b24 <__alltraps>

c0104239 <vector45>:
.globl vector45
vector45:
  pushl $0
c0104239:	6a 00                	push   $0x0
  pushl $45
c010423b:	6a 2d                	push   $0x2d
  jmp __alltraps
c010423d:	e9 e2 08 00 00       	jmp    c0104b24 <__alltraps>

c0104242 <vector46>:
.globl vector46
vector46:
  pushl $0
c0104242:	6a 00                	push   $0x0
  pushl $46
c0104244:	6a 2e                	push   $0x2e
  jmp __alltraps
c0104246:	e9 d9 08 00 00       	jmp    c0104b24 <__alltraps>

c010424b <vector47>:
.globl vector47
vector47:
  pushl $0
c010424b:	6a 00                	push   $0x0
  pushl $47
c010424d:	6a 2f                	push   $0x2f
  jmp __alltraps
c010424f:	e9 d0 08 00 00       	jmp    c0104b24 <__alltraps>

c0104254 <vector48>:
.globl vector48
vector48:
  pushl $0
c0104254:	6a 00                	push   $0x0
  pushl $48
c0104256:	6a 30                	push   $0x30
  jmp __alltraps
c0104258:	e9 c7 08 00 00       	jmp    c0104b24 <__alltraps>

c010425d <vector49>:
.globl vector49
vector49:
  pushl $0
c010425d:	6a 00                	push   $0x0
  pushl $49
c010425f:	6a 31                	push   $0x31
  jmp __alltraps
c0104261:	e9 be 08 00 00       	jmp    c0104b24 <__alltraps>

c0104266 <vector50>:
.globl vector50
vector50:
  pushl $0
c0104266:	6a 00                	push   $0x0
  pushl $50
c0104268:	6a 32                	push   $0x32
  jmp __alltraps
c010426a:	e9 b5 08 00 00       	jmp    c0104b24 <__alltraps>

c010426f <vector51>:
.globl vector51
vector51:
  pushl $0
c010426f:	6a 00                	push   $0x0
  pushl $51
c0104271:	6a 33                	push   $0x33
  jmp __alltraps
c0104273:	e9 ac 08 00 00       	jmp    c0104b24 <__alltraps>

c0104278 <vector52>:
.globl vector52
vector52:
  pushl $0
c0104278:	6a 00                	push   $0x0
  pushl $52
c010427a:	6a 34                	push   $0x34
  jmp __alltraps
c010427c:	e9 a3 08 00 00       	jmp    c0104b24 <__alltraps>

c0104281 <vector53>:
.globl vector53
vector53:
  pushl $0
c0104281:	6a 00                	push   $0x0
  pushl $53
c0104283:	6a 35                	push   $0x35
  jmp __alltraps
c0104285:	e9 9a 08 00 00       	jmp    c0104b24 <__alltraps>

c010428a <vector54>:
.globl vector54
vector54:
  pushl $0
c010428a:	6a 00                	push   $0x0
  pushl $54
c010428c:	6a 36                	push   $0x36
  jmp __alltraps
c010428e:	e9 91 08 00 00       	jmp    c0104b24 <__alltraps>

c0104293 <vector55>:
.globl vector55
vector55:
  pushl $0
c0104293:	6a 00                	push   $0x0
  pushl $55
c0104295:	6a 37                	push   $0x37
  jmp __alltraps
c0104297:	e9 88 08 00 00       	jmp    c0104b24 <__alltraps>

c010429c <vector56>:
.globl vector56
vector56:
  pushl $0
c010429c:	6a 00                	push   $0x0
  pushl $56
c010429e:	6a 38                	push   $0x38
  jmp __alltraps
c01042a0:	e9 7f 08 00 00       	jmp    c0104b24 <__alltraps>

c01042a5 <vector57>:
.globl vector57
vector57:
  pushl $0
c01042a5:	6a 00                	push   $0x0
  pushl $57
c01042a7:	6a 39                	push   $0x39
  jmp __alltraps
c01042a9:	e9 76 08 00 00       	jmp    c0104b24 <__alltraps>

c01042ae <vector58>:
.globl vector58
vector58:
  pushl $0
c01042ae:	6a 00                	push   $0x0
  pushl $58
c01042b0:	6a 3a                	push   $0x3a
  jmp __alltraps
c01042b2:	e9 6d 08 00 00       	jmp    c0104b24 <__alltraps>

c01042b7 <vector59>:
.globl vector59
vector59:
  pushl $0
c01042b7:	6a 00                	push   $0x0
  pushl $59
c01042b9:	6a 3b                	push   $0x3b
  jmp __alltraps
c01042bb:	e9 64 08 00 00       	jmp    c0104b24 <__alltraps>

c01042c0 <vector60>:
.globl vector60
vector60:
  pushl $0
c01042c0:	6a 00                	push   $0x0
  pushl $60
c01042c2:	6a 3c                	push   $0x3c
  jmp __alltraps
c01042c4:	e9 5b 08 00 00       	jmp    c0104b24 <__alltraps>

c01042c9 <vector61>:
.globl vector61
vector61:
  pushl $0
c01042c9:	6a 00                	push   $0x0
  pushl $61
c01042cb:	6a 3d                	push   $0x3d
  jmp __alltraps
c01042cd:	e9 52 08 00 00       	jmp    c0104b24 <__alltraps>

c01042d2 <vector62>:
.globl vector62
vector62:
  pushl $0
c01042d2:	6a 00                	push   $0x0
  pushl $62
c01042d4:	6a 3e                	push   $0x3e
  jmp __alltraps
c01042d6:	e9 49 08 00 00       	jmp    c0104b24 <__alltraps>

c01042db <vector63>:
.globl vector63
vector63:
  pushl $0
c01042db:	6a 00                	push   $0x0
  pushl $63
c01042dd:	6a 3f                	push   $0x3f
  jmp __alltraps
c01042df:	e9 40 08 00 00       	jmp    c0104b24 <__alltraps>

c01042e4 <vector64>:
.globl vector64
vector64:
  pushl $0
c01042e4:	6a 00                	push   $0x0
  pushl $64
c01042e6:	6a 40                	push   $0x40
  jmp __alltraps
c01042e8:	e9 37 08 00 00       	jmp    c0104b24 <__alltraps>

c01042ed <vector65>:
.globl vector65
vector65:
  pushl $0
c01042ed:	6a 00                	push   $0x0
  pushl $65
c01042ef:	6a 41                	push   $0x41
  jmp __alltraps
c01042f1:	e9 2e 08 00 00       	jmp    c0104b24 <__alltraps>

c01042f6 <vector66>:
.globl vector66
vector66:
  pushl $0
c01042f6:	6a 00                	push   $0x0
  pushl $66
c01042f8:	6a 42                	push   $0x42
  jmp __alltraps
c01042fa:	e9 25 08 00 00       	jmp    c0104b24 <__alltraps>

c01042ff <vector67>:
.globl vector67
vector67:
  pushl $0
c01042ff:	6a 00                	push   $0x0
  pushl $67
c0104301:	6a 43                	push   $0x43
  jmp __alltraps
c0104303:	e9 1c 08 00 00       	jmp    c0104b24 <__alltraps>

c0104308 <vector68>:
.globl vector68
vector68:
  pushl $0
c0104308:	6a 00                	push   $0x0
  pushl $68
c010430a:	6a 44                	push   $0x44
  jmp __alltraps
c010430c:	e9 13 08 00 00       	jmp    c0104b24 <__alltraps>

c0104311 <vector69>:
.globl vector69
vector69:
  pushl $0
c0104311:	6a 00                	push   $0x0
  pushl $69
c0104313:	6a 45                	push   $0x45
  jmp __alltraps
c0104315:	e9 0a 08 00 00       	jmp    c0104b24 <__alltraps>

c010431a <vector70>:
.globl vector70
vector70:
  pushl $0
c010431a:	6a 00                	push   $0x0
  pushl $70
c010431c:	6a 46                	push   $0x46
  jmp __alltraps
c010431e:	e9 01 08 00 00       	jmp    c0104b24 <__alltraps>

c0104323 <vector71>:
.globl vector71
vector71:
  pushl $0
c0104323:	6a 00                	push   $0x0
  pushl $71
c0104325:	6a 47                	push   $0x47
  jmp __alltraps
c0104327:	e9 f8 07 00 00       	jmp    c0104b24 <__alltraps>

c010432c <vector72>:
.globl vector72
vector72:
  pushl $0
c010432c:	6a 00                	push   $0x0
  pushl $72
c010432e:	6a 48                	push   $0x48
  jmp __alltraps
c0104330:	e9 ef 07 00 00       	jmp    c0104b24 <__alltraps>

c0104335 <vector73>:
.globl vector73
vector73:
  pushl $0
c0104335:	6a 00                	push   $0x0
  pushl $73
c0104337:	6a 49                	push   $0x49
  jmp __alltraps
c0104339:	e9 e6 07 00 00       	jmp    c0104b24 <__alltraps>

c010433e <vector74>:
.globl vector74
vector74:
  pushl $0
c010433e:	6a 00                	push   $0x0
  pushl $74
c0104340:	6a 4a                	push   $0x4a
  jmp __alltraps
c0104342:	e9 dd 07 00 00       	jmp    c0104b24 <__alltraps>

c0104347 <vector75>:
.globl vector75
vector75:
  pushl $0
c0104347:	6a 00                	push   $0x0
  pushl $75
c0104349:	6a 4b                	push   $0x4b
  jmp __alltraps
c010434b:	e9 d4 07 00 00       	jmp    c0104b24 <__alltraps>

c0104350 <vector76>:
.globl vector76
vector76:
  pushl $0
c0104350:	6a 00                	push   $0x0
  pushl $76
c0104352:	6a 4c                	push   $0x4c
  jmp __alltraps
c0104354:	e9 cb 07 00 00       	jmp    c0104b24 <__alltraps>

c0104359 <vector77>:
.globl vector77
vector77:
  pushl $0
c0104359:	6a 00                	push   $0x0
  pushl $77
c010435b:	6a 4d                	push   $0x4d
  jmp __alltraps
c010435d:	e9 c2 07 00 00       	jmp    c0104b24 <__alltraps>

c0104362 <vector78>:
.globl vector78
vector78:
  pushl $0
c0104362:	6a 00                	push   $0x0
  pushl $78
c0104364:	6a 4e                	push   $0x4e
  jmp __alltraps
c0104366:	e9 b9 07 00 00       	jmp    c0104b24 <__alltraps>

c010436b <vector79>:
.globl vector79
vector79:
  pushl $0
c010436b:	6a 00                	push   $0x0
  pushl $79
c010436d:	6a 4f                	push   $0x4f
  jmp __alltraps
c010436f:	e9 b0 07 00 00       	jmp    c0104b24 <__alltraps>

c0104374 <vector80>:
.globl vector80
vector80:
  pushl $0
c0104374:	6a 00                	push   $0x0
  pushl $80
c0104376:	6a 50                	push   $0x50
  jmp __alltraps
c0104378:	e9 a7 07 00 00       	jmp    c0104b24 <__alltraps>

c010437d <vector81>:
.globl vector81
vector81:
  pushl $0
c010437d:	6a 00                	push   $0x0
  pushl $81
c010437f:	6a 51                	push   $0x51
  jmp __alltraps
c0104381:	e9 9e 07 00 00       	jmp    c0104b24 <__alltraps>

c0104386 <vector82>:
.globl vector82
vector82:
  pushl $0
c0104386:	6a 00                	push   $0x0
  pushl $82
c0104388:	6a 52                	push   $0x52
  jmp __alltraps
c010438a:	e9 95 07 00 00       	jmp    c0104b24 <__alltraps>

c010438f <vector83>:
.globl vector83
vector83:
  pushl $0
c010438f:	6a 00                	push   $0x0
  pushl $83
c0104391:	6a 53                	push   $0x53
  jmp __alltraps
c0104393:	e9 8c 07 00 00       	jmp    c0104b24 <__alltraps>

c0104398 <vector84>:
.globl vector84
vector84:
  pushl $0
c0104398:	6a 00                	push   $0x0
  pushl $84
c010439a:	6a 54                	push   $0x54
  jmp __alltraps
c010439c:	e9 83 07 00 00       	jmp    c0104b24 <__alltraps>

c01043a1 <vector85>:
.globl vector85
vector85:
  pushl $0
c01043a1:	6a 00                	push   $0x0
  pushl $85
c01043a3:	6a 55                	push   $0x55
  jmp __alltraps
c01043a5:	e9 7a 07 00 00       	jmp    c0104b24 <__alltraps>

c01043aa <vector86>:
.globl vector86
vector86:
  pushl $0
c01043aa:	6a 00                	push   $0x0
  pushl $86
c01043ac:	6a 56                	push   $0x56
  jmp __alltraps
c01043ae:	e9 71 07 00 00       	jmp    c0104b24 <__alltraps>

c01043b3 <vector87>:
.globl vector87
vector87:
  pushl $0
c01043b3:	6a 00                	push   $0x0
  pushl $87
c01043b5:	6a 57                	push   $0x57
  jmp __alltraps
c01043b7:	e9 68 07 00 00       	jmp    c0104b24 <__alltraps>

c01043bc <vector88>:
.globl vector88
vector88:
  pushl $0
c01043bc:	6a 00                	push   $0x0
  pushl $88
c01043be:	6a 58                	push   $0x58
  jmp __alltraps
c01043c0:	e9 5f 07 00 00       	jmp    c0104b24 <__alltraps>

c01043c5 <vector89>:
.globl vector89
vector89:
  pushl $0
c01043c5:	6a 00                	push   $0x0
  pushl $89
c01043c7:	6a 59                	push   $0x59
  jmp __alltraps
c01043c9:	e9 56 07 00 00       	jmp    c0104b24 <__alltraps>

c01043ce <vector90>:
.globl vector90
vector90:
  pushl $0
c01043ce:	6a 00                	push   $0x0
  pushl $90
c01043d0:	6a 5a                	push   $0x5a
  jmp __alltraps
c01043d2:	e9 4d 07 00 00       	jmp    c0104b24 <__alltraps>

c01043d7 <vector91>:
.globl vector91
vector91:
  pushl $0
c01043d7:	6a 00                	push   $0x0
  pushl $91
c01043d9:	6a 5b                	push   $0x5b
  jmp __alltraps
c01043db:	e9 44 07 00 00       	jmp    c0104b24 <__alltraps>

c01043e0 <vector92>:
.globl vector92
vector92:
  pushl $0
c01043e0:	6a 00                	push   $0x0
  pushl $92
c01043e2:	6a 5c                	push   $0x5c
  jmp __alltraps
c01043e4:	e9 3b 07 00 00       	jmp    c0104b24 <__alltraps>

c01043e9 <vector93>:
.globl vector93
vector93:
  pushl $0
c01043e9:	6a 00                	push   $0x0
  pushl $93
c01043eb:	6a 5d                	push   $0x5d
  jmp __alltraps
c01043ed:	e9 32 07 00 00       	jmp    c0104b24 <__alltraps>

c01043f2 <vector94>:
.globl vector94
vector94:
  pushl $0
c01043f2:	6a 00                	push   $0x0
  pushl $94
c01043f4:	6a 5e                	push   $0x5e
  jmp __alltraps
c01043f6:	e9 29 07 00 00       	jmp    c0104b24 <__alltraps>

c01043fb <vector95>:
.globl vector95
vector95:
  pushl $0
c01043fb:	6a 00                	push   $0x0
  pushl $95
c01043fd:	6a 5f                	push   $0x5f
  jmp __alltraps
c01043ff:	e9 20 07 00 00       	jmp    c0104b24 <__alltraps>

c0104404 <vector96>:
.globl vector96
vector96:
  pushl $0
c0104404:	6a 00                	push   $0x0
  pushl $96
c0104406:	6a 60                	push   $0x60
  jmp __alltraps
c0104408:	e9 17 07 00 00       	jmp    c0104b24 <__alltraps>

c010440d <vector97>:
.globl vector97
vector97:
  pushl $0
c010440d:	6a 00                	push   $0x0
  pushl $97
c010440f:	6a 61                	push   $0x61
  jmp __alltraps
c0104411:	e9 0e 07 00 00       	jmp    c0104b24 <__alltraps>

c0104416 <vector98>:
.globl vector98
vector98:
  pushl $0
c0104416:	6a 00                	push   $0x0
  pushl $98
c0104418:	6a 62                	push   $0x62
  jmp __alltraps
c010441a:	e9 05 07 00 00       	jmp    c0104b24 <__alltraps>

c010441f <vector99>:
.globl vector99
vector99:
  pushl $0
c010441f:	6a 00                	push   $0x0
  pushl $99
c0104421:	6a 63                	push   $0x63
  jmp __alltraps
c0104423:	e9 fc 06 00 00       	jmp    c0104b24 <__alltraps>

c0104428 <vector100>:
.globl vector100
vector100:
  pushl $0
c0104428:	6a 00                	push   $0x0
  pushl $100
c010442a:	6a 64                	push   $0x64
  jmp __alltraps
c010442c:	e9 f3 06 00 00       	jmp    c0104b24 <__alltraps>

c0104431 <vector101>:
.globl vector101
vector101:
  pushl $0
c0104431:	6a 00                	push   $0x0
  pushl $101
c0104433:	6a 65                	push   $0x65
  jmp __alltraps
c0104435:	e9 ea 06 00 00       	jmp    c0104b24 <__alltraps>

c010443a <vector102>:
.globl vector102
vector102:
  pushl $0
c010443a:	6a 00                	push   $0x0
  pushl $102
c010443c:	6a 66                	push   $0x66
  jmp __alltraps
c010443e:	e9 e1 06 00 00       	jmp    c0104b24 <__alltraps>

c0104443 <vector103>:
.globl vector103
vector103:
  pushl $0
c0104443:	6a 00                	push   $0x0
  pushl $103
c0104445:	6a 67                	push   $0x67
  jmp __alltraps
c0104447:	e9 d8 06 00 00       	jmp    c0104b24 <__alltraps>

c010444c <vector104>:
.globl vector104
vector104:
  pushl $0
c010444c:	6a 00                	push   $0x0
  pushl $104
c010444e:	6a 68                	push   $0x68
  jmp __alltraps
c0104450:	e9 cf 06 00 00       	jmp    c0104b24 <__alltraps>

c0104455 <vector105>:
.globl vector105
vector105:
  pushl $0
c0104455:	6a 00                	push   $0x0
  pushl $105
c0104457:	6a 69                	push   $0x69
  jmp __alltraps
c0104459:	e9 c6 06 00 00       	jmp    c0104b24 <__alltraps>

c010445e <vector106>:
.globl vector106
vector106:
  pushl $0
c010445e:	6a 00                	push   $0x0
  pushl $106
c0104460:	6a 6a                	push   $0x6a
  jmp __alltraps
c0104462:	e9 bd 06 00 00       	jmp    c0104b24 <__alltraps>

c0104467 <vector107>:
.globl vector107
vector107:
  pushl $0
c0104467:	6a 00                	push   $0x0
  pushl $107
c0104469:	6a 6b                	push   $0x6b
  jmp __alltraps
c010446b:	e9 b4 06 00 00       	jmp    c0104b24 <__alltraps>

c0104470 <vector108>:
.globl vector108
vector108:
  pushl $0
c0104470:	6a 00                	push   $0x0
  pushl $108
c0104472:	6a 6c                	push   $0x6c
  jmp __alltraps
c0104474:	e9 ab 06 00 00       	jmp    c0104b24 <__alltraps>

c0104479 <vector109>:
.globl vector109
vector109:
  pushl $0
c0104479:	6a 00                	push   $0x0
  pushl $109
c010447b:	6a 6d                	push   $0x6d
  jmp __alltraps
c010447d:	e9 a2 06 00 00       	jmp    c0104b24 <__alltraps>

c0104482 <vector110>:
.globl vector110
vector110:
  pushl $0
c0104482:	6a 00                	push   $0x0
  pushl $110
c0104484:	6a 6e                	push   $0x6e
  jmp __alltraps
c0104486:	e9 99 06 00 00       	jmp    c0104b24 <__alltraps>

c010448b <vector111>:
.globl vector111
vector111:
  pushl $0
c010448b:	6a 00                	push   $0x0
  pushl $111
c010448d:	6a 6f                	push   $0x6f
  jmp __alltraps
c010448f:	e9 90 06 00 00       	jmp    c0104b24 <__alltraps>

c0104494 <vector112>:
.globl vector112
vector112:
  pushl $0
c0104494:	6a 00                	push   $0x0
  pushl $112
c0104496:	6a 70                	push   $0x70
  jmp __alltraps
c0104498:	e9 87 06 00 00       	jmp    c0104b24 <__alltraps>

c010449d <vector113>:
.globl vector113
vector113:
  pushl $0
c010449d:	6a 00                	push   $0x0
  pushl $113
c010449f:	6a 71                	push   $0x71
  jmp __alltraps
c01044a1:	e9 7e 06 00 00       	jmp    c0104b24 <__alltraps>

c01044a6 <vector114>:
.globl vector114
vector114:
  pushl $0
c01044a6:	6a 00                	push   $0x0
  pushl $114
c01044a8:	6a 72                	push   $0x72
  jmp __alltraps
c01044aa:	e9 75 06 00 00       	jmp    c0104b24 <__alltraps>

c01044af <vector115>:
.globl vector115
vector115:
  pushl $0
c01044af:	6a 00                	push   $0x0
  pushl $115
c01044b1:	6a 73                	push   $0x73
  jmp __alltraps
c01044b3:	e9 6c 06 00 00       	jmp    c0104b24 <__alltraps>

c01044b8 <vector116>:
.globl vector116
vector116:
  pushl $0
c01044b8:	6a 00                	push   $0x0
  pushl $116
c01044ba:	6a 74                	push   $0x74
  jmp __alltraps
c01044bc:	e9 63 06 00 00       	jmp    c0104b24 <__alltraps>

c01044c1 <vector117>:
.globl vector117
vector117:
  pushl $0
c01044c1:	6a 00                	push   $0x0
  pushl $117
c01044c3:	6a 75                	push   $0x75
  jmp __alltraps
c01044c5:	e9 5a 06 00 00       	jmp    c0104b24 <__alltraps>

c01044ca <vector118>:
.globl vector118
vector118:
  pushl $0
c01044ca:	6a 00                	push   $0x0
  pushl $118
c01044cc:	6a 76                	push   $0x76
  jmp __alltraps
c01044ce:	e9 51 06 00 00       	jmp    c0104b24 <__alltraps>

c01044d3 <vector119>:
.globl vector119
vector119:
  pushl $0
c01044d3:	6a 00                	push   $0x0
  pushl $119
c01044d5:	6a 77                	push   $0x77
  jmp __alltraps
c01044d7:	e9 48 06 00 00       	jmp    c0104b24 <__alltraps>

c01044dc <vector120>:
.globl vector120
vector120:
  pushl $0
c01044dc:	6a 00                	push   $0x0
  pushl $120
c01044de:	6a 78                	push   $0x78
  jmp __alltraps
c01044e0:	e9 3f 06 00 00       	jmp    c0104b24 <__alltraps>

c01044e5 <vector121>:
.globl vector121
vector121:
  pushl $0
c01044e5:	6a 00                	push   $0x0
  pushl $121
c01044e7:	6a 79                	push   $0x79
  jmp __alltraps
c01044e9:	e9 36 06 00 00       	jmp    c0104b24 <__alltraps>

c01044ee <vector122>:
.globl vector122
vector122:
  pushl $0
c01044ee:	6a 00                	push   $0x0
  pushl $122
c01044f0:	6a 7a                	push   $0x7a
  jmp __alltraps
c01044f2:	e9 2d 06 00 00       	jmp    c0104b24 <__alltraps>

c01044f7 <vector123>:
.globl vector123
vector123:
  pushl $0
c01044f7:	6a 00                	push   $0x0
  pushl $123
c01044f9:	6a 7b                	push   $0x7b
  jmp __alltraps
c01044fb:	e9 24 06 00 00       	jmp    c0104b24 <__alltraps>

c0104500 <vector124>:
.globl vector124
vector124:
  pushl $0
c0104500:	6a 00                	push   $0x0
  pushl $124
c0104502:	6a 7c                	push   $0x7c
  jmp __alltraps
c0104504:	e9 1b 06 00 00       	jmp    c0104b24 <__alltraps>

c0104509 <vector125>:
.globl vector125
vector125:
  pushl $0
c0104509:	6a 00                	push   $0x0
  pushl $125
c010450b:	6a 7d                	push   $0x7d
  jmp __alltraps
c010450d:	e9 12 06 00 00       	jmp    c0104b24 <__alltraps>

c0104512 <vector126>:
.globl vector126
vector126:
  pushl $0
c0104512:	6a 00                	push   $0x0
  pushl $126
c0104514:	6a 7e                	push   $0x7e
  jmp __alltraps
c0104516:	e9 09 06 00 00       	jmp    c0104b24 <__alltraps>

c010451b <vector127>:
.globl vector127
vector127:
  pushl $0
c010451b:	6a 00                	push   $0x0
  pushl $127
c010451d:	6a 7f                	push   $0x7f
  jmp __alltraps
c010451f:	e9 00 06 00 00       	jmp    c0104b24 <__alltraps>

c0104524 <vector128>:
.globl vector128
vector128:
  pushl $0
c0104524:	6a 00                	push   $0x0
  pushl $128
c0104526:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010452b:	e9 f4 05 00 00       	jmp    c0104b24 <__alltraps>

c0104530 <vector129>:
.globl vector129
vector129:
  pushl $0
c0104530:	6a 00                	push   $0x0
  pushl $129
c0104532:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0104537:	e9 e8 05 00 00       	jmp    c0104b24 <__alltraps>

c010453c <vector130>:
.globl vector130
vector130:
  pushl $0
c010453c:	6a 00                	push   $0x0
  pushl $130
c010453e:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0104543:	e9 dc 05 00 00       	jmp    c0104b24 <__alltraps>

c0104548 <vector131>:
.globl vector131
vector131:
  pushl $0
c0104548:	6a 00                	push   $0x0
  pushl $131
c010454a:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010454f:	e9 d0 05 00 00       	jmp    c0104b24 <__alltraps>

c0104554 <vector132>:
.globl vector132
vector132:
  pushl $0
c0104554:	6a 00                	push   $0x0
  pushl $132
c0104556:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010455b:	e9 c4 05 00 00       	jmp    c0104b24 <__alltraps>

c0104560 <vector133>:
.globl vector133
vector133:
  pushl $0
c0104560:	6a 00                	push   $0x0
  pushl $133
c0104562:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0104567:	e9 b8 05 00 00       	jmp    c0104b24 <__alltraps>

c010456c <vector134>:
.globl vector134
vector134:
  pushl $0
c010456c:	6a 00                	push   $0x0
  pushl $134
c010456e:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0104573:	e9 ac 05 00 00       	jmp    c0104b24 <__alltraps>

c0104578 <vector135>:
.globl vector135
vector135:
  pushl $0
c0104578:	6a 00                	push   $0x0
  pushl $135
c010457a:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010457f:	e9 a0 05 00 00       	jmp    c0104b24 <__alltraps>

c0104584 <vector136>:
.globl vector136
vector136:
  pushl $0
c0104584:	6a 00                	push   $0x0
  pushl $136
c0104586:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010458b:	e9 94 05 00 00       	jmp    c0104b24 <__alltraps>

c0104590 <vector137>:
.globl vector137
vector137:
  pushl $0
c0104590:	6a 00                	push   $0x0
  pushl $137
c0104592:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0104597:	e9 88 05 00 00       	jmp    c0104b24 <__alltraps>

c010459c <vector138>:
.globl vector138
vector138:
  pushl $0
c010459c:	6a 00                	push   $0x0
  pushl $138
c010459e:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01045a3:	e9 7c 05 00 00       	jmp    c0104b24 <__alltraps>

c01045a8 <vector139>:
.globl vector139
vector139:
  pushl $0
c01045a8:	6a 00                	push   $0x0
  pushl $139
c01045aa:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01045af:	e9 70 05 00 00       	jmp    c0104b24 <__alltraps>

c01045b4 <vector140>:
.globl vector140
vector140:
  pushl $0
c01045b4:	6a 00                	push   $0x0
  pushl $140
c01045b6:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01045bb:	e9 64 05 00 00       	jmp    c0104b24 <__alltraps>

c01045c0 <vector141>:
.globl vector141
vector141:
  pushl $0
c01045c0:	6a 00                	push   $0x0
  pushl $141
c01045c2:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01045c7:	e9 58 05 00 00       	jmp    c0104b24 <__alltraps>

c01045cc <vector142>:
.globl vector142
vector142:
  pushl $0
c01045cc:	6a 00                	push   $0x0
  pushl $142
c01045ce:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01045d3:	e9 4c 05 00 00       	jmp    c0104b24 <__alltraps>

c01045d8 <vector143>:
.globl vector143
vector143:
  pushl $0
c01045d8:	6a 00                	push   $0x0
  pushl $143
c01045da:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01045df:	e9 40 05 00 00       	jmp    c0104b24 <__alltraps>

c01045e4 <vector144>:
.globl vector144
vector144:
  pushl $0
c01045e4:	6a 00                	push   $0x0
  pushl $144
c01045e6:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01045eb:	e9 34 05 00 00       	jmp    c0104b24 <__alltraps>

c01045f0 <vector145>:
.globl vector145
vector145:
  pushl $0
c01045f0:	6a 00                	push   $0x0
  pushl $145
c01045f2:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01045f7:	e9 28 05 00 00       	jmp    c0104b24 <__alltraps>

c01045fc <vector146>:
.globl vector146
vector146:
  pushl $0
c01045fc:	6a 00                	push   $0x0
  pushl $146
c01045fe:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0104603:	e9 1c 05 00 00       	jmp    c0104b24 <__alltraps>

c0104608 <vector147>:
.globl vector147
vector147:
  pushl $0
c0104608:	6a 00                	push   $0x0
  pushl $147
c010460a:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010460f:	e9 10 05 00 00       	jmp    c0104b24 <__alltraps>

c0104614 <vector148>:
.globl vector148
vector148:
  pushl $0
c0104614:	6a 00                	push   $0x0
  pushl $148
c0104616:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010461b:	e9 04 05 00 00       	jmp    c0104b24 <__alltraps>

c0104620 <vector149>:
.globl vector149
vector149:
  pushl $0
c0104620:	6a 00                	push   $0x0
  pushl $149
c0104622:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0104627:	e9 f8 04 00 00       	jmp    c0104b24 <__alltraps>

c010462c <vector150>:
.globl vector150
vector150:
  pushl $0
c010462c:	6a 00                	push   $0x0
  pushl $150
c010462e:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0104633:	e9 ec 04 00 00       	jmp    c0104b24 <__alltraps>

c0104638 <vector151>:
.globl vector151
vector151:
  pushl $0
c0104638:	6a 00                	push   $0x0
  pushl $151
c010463a:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010463f:	e9 e0 04 00 00       	jmp    c0104b24 <__alltraps>

c0104644 <vector152>:
.globl vector152
vector152:
  pushl $0
c0104644:	6a 00                	push   $0x0
  pushl $152
c0104646:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010464b:	e9 d4 04 00 00       	jmp    c0104b24 <__alltraps>

c0104650 <vector153>:
.globl vector153
vector153:
  pushl $0
c0104650:	6a 00                	push   $0x0
  pushl $153
c0104652:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0104657:	e9 c8 04 00 00       	jmp    c0104b24 <__alltraps>

c010465c <vector154>:
.globl vector154
vector154:
  pushl $0
c010465c:	6a 00                	push   $0x0
  pushl $154
c010465e:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0104663:	e9 bc 04 00 00       	jmp    c0104b24 <__alltraps>

c0104668 <vector155>:
.globl vector155
vector155:
  pushl $0
c0104668:	6a 00                	push   $0x0
  pushl $155
c010466a:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010466f:	e9 b0 04 00 00       	jmp    c0104b24 <__alltraps>

c0104674 <vector156>:
.globl vector156
vector156:
  pushl $0
c0104674:	6a 00                	push   $0x0
  pushl $156
c0104676:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010467b:	e9 a4 04 00 00       	jmp    c0104b24 <__alltraps>

c0104680 <vector157>:
.globl vector157
vector157:
  pushl $0
c0104680:	6a 00                	push   $0x0
  pushl $157
c0104682:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0104687:	e9 98 04 00 00       	jmp    c0104b24 <__alltraps>

c010468c <vector158>:
.globl vector158
vector158:
  pushl $0
c010468c:	6a 00                	push   $0x0
  pushl $158
c010468e:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0104693:	e9 8c 04 00 00       	jmp    c0104b24 <__alltraps>

c0104698 <vector159>:
.globl vector159
vector159:
  pushl $0
c0104698:	6a 00                	push   $0x0
  pushl $159
c010469a:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010469f:	e9 80 04 00 00       	jmp    c0104b24 <__alltraps>

c01046a4 <vector160>:
.globl vector160
vector160:
  pushl $0
c01046a4:	6a 00                	push   $0x0
  pushl $160
c01046a6:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01046ab:	e9 74 04 00 00       	jmp    c0104b24 <__alltraps>

c01046b0 <vector161>:
.globl vector161
vector161:
  pushl $0
c01046b0:	6a 00                	push   $0x0
  pushl $161
c01046b2:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01046b7:	e9 68 04 00 00       	jmp    c0104b24 <__alltraps>

c01046bc <vector162>:
.globl vector162
vector162:
  pushl $0
c01046bc:	6a 00                	push   $0x0
  pushl $162
c01046be:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01046c3:	e9 5c 04 00 00       	jmp    c0104b24 <__alltraps>

c01046c8 <vector163>:
.globl vector163
vector163:
  pushl $0
c01046c8:	6a 00                	push   $0x0
  pushl $163
c01046ca:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01046cf:	e9 50 04 00 00       	jmp    c0104b24 <__alltraps>

c01046d4 <vector164>:
.globl vector164
vector164:
  pushl $0
c01046d4:	6a 00                	push   $0x0
  pushl $164
c01046d6:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01046db:	e9 44 04 00 00       	jmp    c0104b24 <__alltraps>

c01046e0 <vector165>:
.globl vector165
vector165:
  pushl $0
c01046e0:	6a 00                	push   $0x0
  pushl $165
c01046e2:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01046e7:	e9 38 04 00 00       	jmp    c0104b24 <__alltraps>

c01046ec <vector166>:
.globl vector166
vector166:
  pushl $0
c01046ec:	6a 00                	push   $0x0
  pushl $166
c01046ee:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01046f3:	e9 2c 04 00 00       	jmp    c0104b24 <__alltraps>

c01046f8 <vector167>:
.globl vector167
vector167:
  pushl $0
c01046f8:	6a 00                	push   $0x0
  pushl $167
c01046fa:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01046ff:	e9 20 04 00 00       	jmp    c0104b24 <__alltraps>

c0104704 <vector168>:
.globl vector168
vector168:
  pushl $0
c0104704:	6a 00                	push   $0x0
  pushl $168
c0104706:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010470b:	e9 14 04 00 00       	jmp    c0104b24 <__alltraps>

c0104710 <vector169>:
.globl vector169
vector169:
  pushl $0
c0104710:	6a 00                	push   $0x0
  pushl $169
c0104712:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0104717:	e9 08 04 00 00       	jmp    c0104b24 <__alltraps>

c010471c <vector170>:
.globl vector170
vector170:
  pushl $0
c010471c:	6a 00                	push   $0x0
  pushl $170
c010471e:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0104723:	e9 fc 03 00 00       	jmp    c0104b24 <__alltraps>

c0104728 <vector171>:
.globl vector171
vector171:
  pushl $0
c0104728:	6a 00                	push   $0x0
  pushl $171
c010472a:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010472f:	e9 f0 03 00 00       	jmp    c0104b24 <__alltraps>

c0104734 <vector172>:
.globl vector172
vector172:
  pushl $0
c0104734:	6a 00                	push   $0x0
  pushl $172
c0104736:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010473b:	e9 e4 03 00 00       	jmp    c0104b24 <__alltraps>

c0104740 <vector173>:
.globl vector173
vector173:
  pushl $0
c0104740:	6a 00                	push   $0x0
  pushl $173
c0104742:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0104747:	e9 d8 03 00 00       	jmp    c0104b24 <__alltraps>

c010474c <vector174>:
.globl vector174
vector174:
  pushl $0
c010474c:	6a 00                	push   $0x0
  pushl $174
c010474e:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0104753:	e9 cc 03 00 00       	jmp    c0104b24 <__alltraps>

c0104758 <vector175>:
.globl vector175
vector175:
  pushl $0
c0104758:	6a 00                	push   $0x0
  pushl $175
c010475a:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010475f:	e9 c0 03 00 00       	jmp    c0104b24 <__alltraps>

c0104764 <vector176>:
.globl vector176
vector176:
  pushl $0
c0104764:	6a 00                	push   $0x0
  pushl $176
c0104766:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010476b:	e9 b4 03 00 00       	jmp    c0104b24 <__alltraps>

c0104770 <vector177>:
.globl vector177
vector177:
  pushl $0
c0104770:	6a 00                	push   $0x0
  pushl $177
c0104772:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0104777:	e9 a8 03 00 00       	jmp    c0104b24 <__alltraps>

c010477c <vector178>:
.globl vector178
vector178:
  pushl $0
c010477c:	6a 00                	push   $0x0
  pushl $178
c010477e:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0104783:	e9 9c 03 00 00       	jmp    c0104b24 <__alltraps>

c0104788 <vector179>:
.globl vector179
vector179:
  pushl $0
c0104788:	6a 00                	push   $0x0
  pushl $179
c010478a:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010478f:	e9 90 03 00 00       	jmp    c0104b24 <__alltraps>

c0104794 <vector180>:
.globl vector180
vector180:
  pushl $0
c0104794:	6a 00                	push   $0x0
  pushl $180
c0104796:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010479b:	e9 84 03 00 00       	jmp    c0104b24 <__alltraps>

c01047a0 <vector181>:
.globl vector181
vector181:
  pushl $0
c01047a0:	6a 00                	push   $0x0
  pushl $181
c01047a2:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01047a7:	e9 78 03 00 00       	jmp    c0104b24 <__alltraps>

c01047ac <vector182>:
.globl vector182
vector182:
  pushl $0
c01047ac:	6a 00                	push   $0x0
  pushl $182
c01047ae:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01047b3:	e9 6c 03 00 00       	jmp    c0104b24 <__alltraps>

c01047b8 <vector183>:
.globl vector183
vector183:
  pushl $0
c01047b8:	6a 00                	push   $0x0
  pushl $183
c01047ba:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01047bf:	e9 60 03 00 00       	jmp    c0104b24 <__alltraps>

c01047c4 <vector184>:
.globl vector184
vector184:
  pushl $0
c01047c4:	6a 00                	push   $0x0
  pushl $184
c01047c6:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01047cb:	e9 54 03 00 00       	jmp    c0104b24 <__alltraps>

c01047d0 <vector185>:
.globl vector185
vector185:
  pushl $0
c01047d0:	6a 00                	push   $0x0
  pushl $185
c01047d2:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01047d7:	e9 48 03 00 00       	jmp    c0104b24 <__alltraps>

c01047dc <vector186>:
.globl vector186
vector186:
  pushl $0
c01047dc:	6a 00                	push   $0x0
  pushl $186
c01047de:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01047e3:	e9 3c 03 00 00       	jmp    c0104b24 <__alltraps>

c01047e8 <vector187>:
.globl vector187
vector187:
  pushl $0
c01047e8:	6a 00                	push   $0x0
  pushl $187
c01047ea:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01047ef:	e9 30 03 00 00       	jmp    c0104b24 <__alltraps>

c01047f4 <vector188>:
.globl vector188
vector188:
  pushl $0
c01047f4:	6a 00                	push   $0x0
  pushl $188
c01047f6:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01047fb:	e9 24 03 00 00       	jmp    c0104b24 <__alltraps>

c0104800 <vector189>:
.globl vector189
vector189:
  pushl $0
c0104800:	6a 00                	push   $0x0
  pushl $189
c0104802:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0104807:	e9 18 03 00 00       	jmp    c0104b24 <__alltraps>

c010480c <vector190>:
.globl vector190
vector190:
  pushl $0
c010480c:	6a 00                	push   $0x0
  pushl $190
c010480e:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0104813:	e9 0c 03 00 00       	jmp    c0104b24 <__alltraps>

c0104818 <vector191>:
.globl vector191
vector191:
  pushl $0
c0104818:	6a 00                	push   $0x0
  pushl $191
c010481a:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010481f:	e9 00 03 00 00       	jmp    c0104b24 <__alltraps>

c0104824 <vector192>:
.globl vector192
vector192:
  pushl $0
c0104824:	6a 00                	push   $0x0
  pushl $192
c0104826:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010482b:	e9 f4 02 00 00       	jmp    c0104b24 <__alltraps>

c0104830 <vector193>:
.globl vector193
vector193:
  pushl $0
c0104830:	6a 00                	push   $0x0
  pushl $193
c0104832:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0104837:	e9 e8 02 00 00       	jmp    c0104b24 <__alltraps>

c010483c <vector194>:
.globl vector194
vector194:
  pushl $0
c010483c:	6a 00                	push   $0x0
  pushl $194
c010483e:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0104843:	e9 dc 02 00 00       	jmp    c0104b24 <__alltraps>

c0104848 <vector195>:
.globl vector195
vector195:
  pushl $0
c0104848:	6a 00                	push   $0x0
  pushl $195
c010484a:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010484f:	e9 d0 02 00 00       	jmp    c0104b24 <__alltraps>

c0104854 <vector196>:
.globl vector196
vector196:
  pushl $0
c0104854:	6a 00                	push   $0x0
  pushl $196
c0104856:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010485b:	e9 c4 02 00 00       	jmp    c0104b24 <__alltraps>

c0104860 <vector197>:
.globl vector197
vector197:
  pushl $0
c0104860:	6a 00                	push   $0x0
  pushl $197
c0104862:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0104867:	e9 b8 02 00 00       	jmp    c0104b24 <__alltraps>

c010486c <vector198>:
.globl vector198
vector198:
  pushl $0
c010486c:	6a 00                	push   $0x0
  pushl $198
c010486e:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0104873:	e9 ac 02 00 00       	jmp    c0104b24 <__alltraps>

c0104878 <vector199>:
.globl vector199
vector199:
  pushl $0
c0104878:	6a 00                	push   $0x0
  pushl $199
c010487a:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010487f:	e9 a0 02 00 00       	jmp    c0104b24 <__alltraps>

c0104884 <vector200>:
.globl vector200
vector200:
  pushl $0
c0104884:	6a 00                	push   $0x0
  pushl $200
c0104886:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010488b:	e9 94 02 00 00       	jmp    c0104b24 <__alltraps>

c0104890 <vector201>:
.globl vector201
vector201:
  pushl $0
c0104890:	6a 00                	push   $0x0
  pushl $201
c0104892:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0104897:	e9 88 02 00 00       	jmp    c0104b24 <__alltraps>

c010489c <vector202>:
.globl vector202
vector202:
  pushl $0
c010489c:	6a 00                	push   $0x0
  pushl $202
c010489e:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01048a3:	e9 7c 02 00 00       	jmp    c0104b24 <__alltraps>

c01048a8 <vector203>:
.globl vector203
vector203:
  pushl $0
c01048a8:	6a 00                	push   $0x0
  pushl $203
c01048aa:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01048af:	e9 70 02 00 00       	jmp    c0104b24 <__alltraps>

c01048b4 <vector204>:
.globl vector204
vector204:
  pushl $0
c01048b4:	6a 00                	push   $0x0
  pushl $204
c01048b6:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01048bb:	e9 64 02 00 00       	jmp    c0104b24 <__alltraps>

c01048c0 <vector205>:
.globl vector205
vector205:
  pushl $0
c01048c0:	6a 00                	push   $0x0
  pushl $205
c01048c2:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01048c7:	e9 58 02 00 00       	jmp    c0104b24 <__alltraps>

c01048cc <vector206>:
.globl vector206
vector206:
  pushl $0
c01048cc:	6a 00                	push   $0x0
  pushl $206
c01048ce:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01048d3:	e9 4c 02 00 00       	jmp    c0104b24 <__alltraps>

c01048d8 <vector207>:
.globl vector207
vector207:
  pushl $0
c01048d8:	6a 00                	push   $0x0
  pushl $207
c01048da:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01048df:	e9 40 02 00 00       	jmp    c0104b24 <__alltraps>

c01048e4 <vector208>:
.globl vector208
vector208:
  pushl $0
c01048e4:	6a 00                	push   $0x0
  pushl $208
c01048e6:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01048eb:	e9 34 02 00 00       	jmp    c0104b24 <__alltraps>

c01048f0 <vector209>:
.globl vector209
vector209:
  pushl $0
c01048f0:	6a 00                	push   $0x0
  pushl $209
c01048f2:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01048f7:	e9 28 02 00 00       	jmp    c0104b24 <__alltraps>

c01048fc <vector210>:
.globl vector210
vector210:
  pushl $0
c01048fc:	6a 00                	push   $0x0
  pushl $210
c01048fe:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0104903:	e9 1c 02 00 00       	jmp    c0104b24 <__alltraps>

c0104908 <vector211>:
.globl vector211
vector211:
  pushl $0
c0104908:	6a 00                	push   $0x0
  pushl $211
c010490a:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010490f:	e9 10 02 00 00       	jmp    c0104b24 <__alltraps>

c0104914 <vector212>:
.globl vector212
vector212:
  pushl $0
c0104914:	6a 00                	push   $0x0
  pushl $212
c0104916:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010491b:	e9 04 02 00 00       	jmp    c0104b24 <__alltraps>

c0104920 <vector213>:
.globl vector213
vector213:
  pushl $0
c0104920:	6a 00                	push   $0x0
  pushl $213
c0104922:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0104927:	e9 f8 01 00 00       	jmp    c0104b24 <__alltraps>

c010492c <vector214>:
.globl vector214
vector214:
  pushl $0
c010492c:	6a 00                	push   $0x0
  pushl $214
c010492e:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0104933:	e9 ec 01 00 00       	jmp    c0104b24 <__alltraps>

c0104938 <vector215>:
.globl vector215
vector215:
  pushl $0
c0104938:	6a 00                	push   $0x0
  pushl $215
c010493a:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010493f:	e9 e0 01 00 00       	jmp    c0104b24 <__alltraps>

c0104944 <vector216>:
.globl vector216
vector216:
  pushl $0
c0104944:	6a 00                	push   $0x0
  pushl $216
c0104946:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010494b:	e9 d4 01 00 00       	jmp    c0104b24 <__alltraps>

c0104950 <vector217>:
.globl vector217
vector217:
  pushl $0
c0104950:	6a 00                	push   $0x0
  pushl $217
c0104952:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0104957:	e9 c8 01 00 00       	jmp    c0104b24 <__alltraps>

c010495c <vector218>:
.globl vector218
vector218:
  pushl $0
c010495c:	6a 00                	push   $0x0
  pushl $218
c010495e:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0104963:	e9 bc 01 00 00       	jmp    c0104b24 <__alltraps>

c0104968 <vector219>:
.globl vector219
vector219:
  pushl $0
c0104968:	6a 00                	push   $0x0
  pushl $219
c010496a:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010496f:	e9 b0 01 00 00       	jmp    c0104b24 <__alltraps>

c0104974 <vector220>:
.globl vector220
vector220:
  pushl $0
c0104974:	6a 00                	push   $0x0
  pushl $220
c0104976:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010497b:	e9 a4 01 00 00       	jmp    c0104b24 <__alltraps>

c0104980 <vector221>:
.globl vector221
vector221:
  pushl $0
c0104980:	6a 00                	push   $0x0
  pushl $221
c0104982:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0104987:	e9 98 01 00 00       	jmp    c0104b24 <__alltraps>

c010498c <vector222>:
.globl vector222
vector222:
  pushl $0
c010498c:	6a 00                	push   $0x0
  pushl $222
c010498e:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0104993:	e9 8c 01 00 00       	jmp    c0104b24 <__alltraps>

c0104998 <vector223>:
.globl vector223
vector223:
  pushl $0
c0104998:	6a 00                	push   $0x0
  pushl $223
c010499a:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010499f:	e9 80 01 00 00       	jmp    c0104b24 <__alltraps>

c01049a4 <vector224>:
.globl vector224
vector224:
  pushl $0
c01049a4:	6a 00                	push   $0x0
  pushl $224
c01049a6:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01049ab:	e9 74 01 00 00       	jmp    c0104b24 <__alltraps>

c01049b0 <vector225>:
.globl vector225
vector225:
  pushl $0
c01049b0:	6a 00                	push   $0x0
  pushl $225
c01049b2:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01049b7:	e9 68 01 00 00       	jmp    c0104b24 <__alltraps>

c01049bc <vector226>:
.globl vector226
vector226:
  pushl $0
c01049bc:	6a 00                	push   $0x0
  pushl $226
c01049be:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01049c3:	e9 5c 01 00 00       	jmp    c0104b24 <__alltraps>

c01049c8 <vector227>:
.globl vector227
vector227:
  pushl $0
c01049c8:	6a 00                	push   $0x0
  pushl $227
c01049ca:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01049cf:	e9 50 01 00 00       	jmp    c0104b24 <__alltraps>

c01049d4 <vector228>:
.globl vector228
vector228:
  pushl $0
c01049d4:	6a 00                	push   $0x0
  pushl $228
c01049d6:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01049db:	e9 44 01 00 00       	jmp    c0104b24 <__alltraps>

c01049e0 <vector229>:
.globl vector229
vector229:
  pushl $0
c01049e0:	6a 00                	push   $0x0
  pushl $229
c01049e2:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01049e7:	e9 38 01 00 00       	jmp    c0104b24 <__alltraps>

c01049ec <vector230>:
.globl vector230
vector230:
  pushl $0
c01049ec:	6a 00                	push   $0x0
  pushl $230
c01049ee:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01049f3:	e9 2c 01 00 00       	jmp    c0104b24 <__alltraps>

c01049f8 <vector231>:
.globl vector231
vector231:
  pushl $0
c01049f8:	6a 00                	push   $0x0
  pushl $231
c01049fa:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01049ff:	e9 20 01 00 00       	jmp    c0104b24 <__alltraps>

c0104a04 <vector232>:
.globl vector232
vector232:
  pushl $0
c0104a04:	6a 00                	push   $0x0
  pushl $232
c0104a06:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0104a0b:	e9 14 01 00 00       	jmp    c0104b24 <__alltraps>

c0104a10 <vector233>:
.globl vector233
vector233:
  pushl $0
c0104a10:	6a 00                	push   $0x0
  pushl $233
c0104a12:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0104a17:	e9 08 01 00 00       	jmp    c0104b24 <__alltraps>

c0104a1c <vector234>:
.globl vector234
vector234:
  pushl $0
c0104a1c:	6a 00                	push   $0x0
  pushl $234
c0104a1e:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0104a23:	e9 fc 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a28 <vector235>:
.globl vector235
vector235:
  pushl $0
c0104a28:	6a 00                	push   $0x0
  pushl $235
c0104a2a:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0104a2f:	e9 f0 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a34 <vector236>:
.globl vector236
vector236:
  pushl $0
c0104a34:	6a 00                	push   $0x0
  pushl $236
c0104a36:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0104a3b:	e9 e4 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a40 <vector237>:
.globl vector237
vector237:
  pushl $0
c0104a40:	6a 00                	push   $0x0
  pushl $237
c0104a42:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0104a47:	e9 d8 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a4c <vector238>:
.globl vector238
vector238:
  pushl $0
c0104a4c:	6a 00                	push   $0x0
  pushl $238
c0104a4e:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0104a53:	e9 cc 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a58 <vector239>:
.globl vector239
vector239:
  pushl $0
c0104a58:	6a 00                	push   $0x0
  pushl $239
c0104a5a:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0104a5f:	e9 c0 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a64 <vector240>:
.globl vector240
vector240:
  pushl $0
c0104a64:	6a 00                	push   $0x0
  pushl $240
c0104a66:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0104a6b:	e9 b4 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a70 <vector241>:
.globl vector241
vector241:
  pushl $0
c0104a70:	6a 00                	push   $0x0
  pushl $241
c0104a72:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0104a77:	e9 a8 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a7c <vector242>:
.globl vector242
vector242:
  pushl $0
c0104a7c:	6a 00                	push   $0x0
  pushl $242
c0104a7e:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0104a83:	e9 9c 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a88 <vector243>:
.globl vector243
vector243:
  pushl $0
c0104a88:	6a 00                	push   $0x0
  pushl $243
c0104a8a:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0104a8f:	e9 90 00 00 00       	jmp    c0104b24 <__alltraps>

c0104a94 <vector244>:
.globl vector244
vector244:
  pushl $0
c0104a94:	6a 00                	push   $0x0
  pushl $244
c0104a96:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0104a9b:	e9 84 00 00 00       	jmp    c0104b24 <__alltraps>

c0104aa0 <vector245>:
.globl vector245
vector245:
  pushl $0
c0104aa0:	6a 00                	push   $0x0
  pushl $245
c0104aa2:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0104aa7:	e9 78 00 00 00       	jmp    c0104b24 <__alltraps>

c0104aac <vector246>:
.globl vector246
vector246:
  pushl $0
c0104aac:	6a 00                	push   $0x0
  pushl $246
c0104aae:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0104ab3:	e9 6c 00 00 00       	jmp    c0104b24 <__alltraps>

c0104ab8 <vector247>:
.globl vector247
vector247:
  pushl $0
c0104ab8:	6a 00                	push   $0x0
  pushl $247
c0104aba:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0104abf:	e9 60 00 00 00       	jmp    c0104b24 <__alltraps>

c0104ac4 <vector248>:
.globl vector248
vector248:
  pushl $0
c0104ac4:	6a 00                	push   $0x0
  pushl $248
c0104ac6:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0104acb:	e9 54 00 00 00       	jmp    c0104b24 <__alltraps>

c0104ad0 <vector249>:
.globl vector249
vector249:
  pushl $0
c0104ad0:	6a 00                	push   $0x0
  pushl $249
c0104ad2:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0104ad7:	e9 48 00 00 00       	jmp    c0104b24 <__alltraps>

c0104adc <vector250>:
.globl vector250
vector250:
  pushl $0
c0104adc:	6a 00                	push   $0x0
  pushl $250
c0104ade:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0104ae3:	e9 3c 00 00 00       	jmp    c0104b24 <__alltraps>

c0104ae8 <vector251>:
.globl vector251
vector251:
  pushl $0
c0104ae8:	6a 00                	push   $0x0
  pushl $251
c0104aea:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0104aef:	e9 30 00 00 00       	jmp    c0104b24 <__alltraps>

c0104af4 <vector252>:
.globl vector252
vector252:
  pushl $0
c0104af4:	6a 00                	push   $0x0
  pushl $252
c0104af6:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0104afb:	e9 24 00 00 00       	jmp    c0104b24 <__alltraps>

c0104b00 <vector253>:
.globl vector253
vector253:
  pushl $0
c0104b00:	6a 00                	push   $0x0
  pushl $253
c0104b02:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0104b07:	e9 18 00 00 00       	jmp    c0104b24 <__alltraps>

c0104b0c <vector254>:
.globl vector254
vector254:
  pushl $0
c0104b0c:	6a 00                	push   $0x0
  pushl $254
c0104b0e:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0104b13:	e9 0c 00 00 00       	jmp    c0104b24 <__alltraps>

c0104b18 <vector255>:
.globl vector255
vector255:
  pushl $0
c0104b18:	6a 00                	push   $0x0
  pushl $255
c0104b1a:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0104b1f:	e9 00 00 00 00       	jmp    c0104b24 <__alltraps>

c0104b24 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0104b24:	1e                   	push   %ds
    pushl %es
c0104b25:	06                   	push   %es
    pushl %fs
c0104b26:	0f a0                	push   %fs
    pushl %gs
c0104b28:	0f a8                	push   %gs
    pushal
c0104b2a:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0104b2b:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0104b30:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0104b32:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0104b34:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0104b35:	e8 59 f5 ff ff       	call   c0104093 <trap>

    # pop the pushed stack pointer
    popl %esp
c0104b3a:	5c                   	pop    %esp

c0104b3b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0104b3b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0104b3c:	0f a9                	pop    %gs
    popl %fs
c0104b3e:	0f a1                	pop    %fs
    popl %es
c0104b40:	07                   	pop    %es
    popl %ds
c0104b41:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0104b42:	83 c4 08             	add    $0x8,%esp
    iret
c0104b45:	cf                   	iret   

c0104b46 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0104b46:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0104b4a:	eb ef                	jmp    c0104b3b <__trapret>

c0104b4c <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0104b4c:	55                   	push   %ebp
c0104b4d:	89 e5                	mov    %esp,%ebp
c0104b4f:	53                   	push   %ebx
c0104b50:	83 ec 04             	sub    $0x4,%esp
c0104b53:	e8 65 b7 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0104b58:	05 28 4e 02 00       	add    $0x24e28,%eax
    if (PPN(pa) >= npage) {
c0104b5d:	8b 55 08             	mov    0x8(%ebp),%edx
c0104b60:	89 d1                	mov    %edx,%ecx
c0104b62:	c1 e9 0c             	shr    $0xc,%ecx
c0104b65:	c7 c2 c0 aa 12 c0    	mov    $0xc012aac0,%edx
c0104b6b:	8b 12                	mov    (%edx),%edx
c0104b6d:	39 d1                	cmp    %edx,%ecx
c0104b6f:	72 1a                	jb     c0104b8b <pa2page+0x3f>
        panic("pa2page called with invalid pa");
c0104b71:	83 ec 04             	sub    $0x4,%esp
c0104b74:	8d 90 e4 2d fe ff    	lea    -0x1d21c(%eax),%edx
c0104b7a:	52                   	push   %edx
c0104b7b:	6a 5f                	push   $0x5f
c0104b7d:	8d 90 03 2e fe ff    	lea    -0x1d1fd(%eax),%edx
c0104b83:	52                   	push   %edx
c0104b84:	89 c3                	mov    %eax,%ebx
c0104b86:	e8 87 ce ff ff       	call   c0101a12 <__panic>
    }
    return &pages[PPN(pa)];
c0104b8b:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0104b91:	8b 08                	mov    (%eax),%ecx
c0104b93:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b96:	c1 e8 0c             	shr    $0xc,%eax
c0104b99:	89 c2                	mov    %eax,%edx
c0104b9b:	89 d0                	mov    %edx,%eax
c0104b9d:	c1 e0 03             	shl    $0x3,%eax
c0104ba0:	01 d0                	add    %edx,%eax
c0104ba2:	c1 e0 02             	shl    $0x2,%eax
c0104ba5:	01 c8                	add    %ecx,%eax
}
c0104ba7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104baa:	c9                   	leave  
c0104bab:	c3                   	ret    

c0104bac <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0104bac:	55                   	push   %ebp
c0104bad:	89 e5                	mov    %esp,%ebp
c0104baf:	53                   	push   %ebx
c0104bb0:	83 ec 14             	sub    $0x14,%esp
c0104bb3:	e8 09 b7 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0104bb8:	81 c3 c8 4d 02 00    	add    $0x24dc8,%ebx
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0104bbe:	83 ec 0c             	sub    $0xc,%esp
c0104bc1:	6a 18                	push   $0x18
c0104bc3:	e8 05 19 00 00       	call   c01064cd <kmalloc>
c0104bc8:	83 c4 10             	add    $0x10,%esp
c0104bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0104bce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bd2:	74 5e                	je     c0104c32 <mm_create+0x86>
        list_init(&(mm->mmap_list));
c0104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bdd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104be0:	89 50 04             	mov    %edx,0x4(%eax)
c0104be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be6:	8b 50 04             	mov    0x4(%eax),%edx
c0104be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bec:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0104bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0104bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bfb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0104c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c05:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0104c0c:	c7 c0 ac aa 12 c0    	mov    $0xc012aaac,%eax
c0104c12:	8b 00                	mov    (%eax),%eax
c0104c14:	85 c0                	test   %eax,%eax
c0104c16:	74 10                	je     c0104c28 <mm_create+0x7c>
c0104c18:	83 ec 0c             	sub    $0xc,%esp
c0104c1b:	ff 75 f4             	pushl  -0xc(%ebp)
c0104c1e:	e8 8f 1b 00 00       	call   c01067b2 <swap_init_mm>
c0104c23:	83 c4 10             	add    $0x10,%esp
c0104c26:	eb 0a                	jmp    c0104c32 <mm_create+0x86>
        else mm->sm_priv = NULL;
c0104c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0104c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104c38:	c9                   	leave  
c0104c39:	c3                   	ret    

c0104c3a <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0104c3a:	55                   	push   %ebp
c0104c3b:	89 e5                	mov    %esp,%ebp
c0104c3d:	53                   	push   %ebx
c0104c3e:	83 ec 14             	sub    $0x14,%esp
c0104c41:	e8 77 b6 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0104c46:	05 3a 4d 02 00       	add    $0x24d3a,%eax
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0104c4b:	83 ec 0c             	sub    $0xc,%esp
c0104c4e:	6a 18                	push   $0x18
c0104c50:	89 c3                	mov    %eax,%ebx
c0104c52:	e8 76 18 00 00       	call   c01064cd <kmalloc>
c0104c57:	83 c4 10             	add    $0x10,%esp
c0104c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0104c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c61:	74 1b                	je     c0104c7e <vma_create+0x44>
        vma->vm_start = vm_start;
c0104c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c66:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c69:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0104c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104c72:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0104c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c78:	8b 55 10             	mov    0x10(%ebp),%edx
c0104c7b:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0104c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104c81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104c84:	c9                   	leave  
c0104c85:	c3                   	ret    

c0104c86 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0104c86:	55                   	push   %ebp
c0104c87:	89 e5                	mov    %esp,%ebp
c0104c89:	83 ec 20             	sub    $0x20,%esp
c0104c8c:	e8 2c b6 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0104c91:	05 ef 4c 02 00       	add    $0x24cef,%eax
    struct vma_struct *vma = NULL;
c0104c96:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0104c9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ca1:	0f 84 95 00 00 00    	je     c0104d3c <find_vma+0xb6>
        vma = mm->mmap_cache;
c0104ca7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104caa:	8b 40 08             	mov    0x8(%eax),%eax
c0104cad:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0104cb0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104cb4:	74 16                	je     c0104ccc <find_vma+0x46>
c0104cb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104cb9:	8b 40 04             	mov    0x4(%eax),%eax
c0104cbc:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104cbf:	72 0b                	jb     c0104ccc <find_vma+0x46>
c0104cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104cc4:	8b 40 08             	mov    0x8(%eax),%eax
c0104cc7:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104cca:	72 61                	jb     c0104d2d <find_vma+0xa7>
                bool found = 0;
c0104ccc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0104cd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0104cdf:	eb 28                	jmp    c0104d09 <find_vma+0x83>
                    vma = le2vma(le, list_link);
c0104ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ce4:	83 e8 10             	sub    $0x10,%eax
c0104ce7:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0104cea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104ced:	8b 40 04             	mov    0x4(%eax),%eax
c0104cf0:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104cf3:	72 14                	jb     c0104d09 <find_vma+0x83>
c0104cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104cf8:	8b 40 08             	mov    0x8(%eax),%eax
c0104cfb:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104cfe:	73 09                	jae    c0104d09 <find_vma+0x83>
                        found = 1;
c0104d00:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0104d07:	eb 17                	jmp    c0104d20 <find_vma+0x9a>
c0104d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d12:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0104d15:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104d1e:	75 c1                	jne    c0104ce1 <find_vma+0x5b>
                    }
                }
                if (!found) {
c0104d20:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0104d24:	75 07                	jne    c0104d2d <find_vma+0xa7>
                    vma = NULL;
c0104d26:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0104d2d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104d31:	74 09                	je     c0104d3c <find_vma+0xb6>
            mm->mmap_cache = vma;
c0104d33:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d36:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104d39:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0104d3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104d3f:	c9                   	leave  
c0104d40:	c3                   	ret    

c0104d41 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0104d41:	55                   	push   %ebp
c0104d42:	89 e5                	mov    %esp,%ebp
c0104d44:	53                   	push   %ebx
c0104d45:	83 ec 04             	sub    $0x4,%esp
c0104d48:	e8 70 b5 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0104d4d:	05 33 4c 02 00       	add    $0x24c33,%eax
    assert(prev->vm_start < prev->vm_end);
c0104d52:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d55:	8b 4a 04             	mov    0x4(%edx),%ecx
c0104d58:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d5b:	8b 52 08             	mov    0x8(%edx),%edx
c0104d5e:	39 d1                	cmp    %edx,%ecx
c0104d60:	72 1e                	jb     c0104d80 <check_vma_overlap+0x3f>
c0104d62:	8d 90 11 2e fe ff    	lea    -0x1d1ef(%eax),%edx
c0104d68:	52                   	push   %edx
c0104d69:	8d 90 2f 2e fe ff    	lea    -0x1d1d1(%eax),%edx
c0104d6f:	52                   	push   %edx
c0104d70:	6a 68                	push   $0x68
c0104d72:	8d 90 44 2e fe ff    	lea    -0x1d1bc(%eax),%edx
c0104d78:	52                   	push   %edx
c0104d79:	89 c3                	mov    %eax,%ebx
c0104d7b:	e8 92 cc ff ff       	call   c0101a12 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0104d80:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d83:	8b 4a 08             	mov    0x8(%edx),%ecx
c0104d86:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104d89:	8b 52 04             	mov    0x4(%edx),%edx
c0104d8c:	39 d1                	cmp    %edx,%ecx
c0104d8e:	76 1e                	jbe    c0104dae <check_vma_overlap+0x6d>
c0104d90:	8d 90 54 2e fe ff    	lea    -0x1d1ac(%eax),%edx
c0104d96:	52                   	push   %edx
c0104d97:	8d 90 2f 2e fe ff    	lea    -0x1d1d1(%eax),%edx
c0104d9d:	52                   	push   %edx
c0104d9e:	6a 69                	push   $0x69
c0104da0:	8d 90 44 2e fe ff    	lea    -0x1d1bc(%eax),%edx
c0104da6:	52                   	push   %edx
c0104da7:	89 c3                	mov    %eax,%ebx
c0104da9:	e8 64 cc ff ff       	call   c0101a12 <__panic>
    assert(next->vm_start < next->vm_end);
c0104dae:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104db1:	8b 4a 04             	mov    0x4(%edx),%ecx
c0104db4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104db7:	8b 52 08             	mov    0x8(%edx),%edx
c0104dba:	39 d1                	cmp    %edx,%ecx
c0104dbc:	72 1e                	jb     c0104ddc <check_vma_overlap+0x9b>
c0104dbe:	8d 90 73 2e fe ff    	lea    -0x1d18d(%eax),%edx
c0104dc4:	52                   	push   %edx
c0104dc5:	8d 90 2f 2e fe ff    	lea    -0x1d1d1(%eax),%edx
c0104dcb:	52                   	push   %edx
c0104dcc:	6a 6a                	push   $0x6a
c0104dce:	8d 90 44 2e fe ff    	lea    -0x1d1bc(%eax),%edx
c0104dd4:	52                   	push   %edx
c0104dd5:	89 c3                	mov    %eax,%ebx
c0104dd7:	e8 36 cc ff ff       	call   c0101a12 <__panic>
}
c0104ddc:	90                   	nop
c0104ddd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104de0:	c9                   	leave  
c0104de1:	c3                   	ret    

c0104de2 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0104de2:	55                   	push   %ebp
c0104de3:	89 e5                	mov    %esp,%ebp
c0104de5:	53                   	push   %ebx
c0104de6:	83 ec 34             	sub    $0x34,%esp
c0104de9:	e8 cf b4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0104dee:	05 92 4b 02 00       	add    $0x24b92,%eax
    assert(vma->vm_start < vma->vm_end);
c0104df3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104df6:	8b 4a 04             	mov    0x4(%edx),%ecx
c0104df9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104dfc:	8b 52 08             	mov    0x8(%edx),%edx
c0104dff:	39 d1                	cmp    %edx,%ecx
c0104e01:	72 1e                	jb     c0104e21 <insert_vma_struct+0x3f>
c0104e03:	8d 90 91 2e fe ff    	lea    -0x1d16f(%eax),%edx
c0104e09:	52                   	push   %edx
c0104e0a:	8d 90 2f 2e fe ff    	lea    -0x1d1d1(%eax),%edx
c0104e10:	52                   	push   %edx
c0104e11:	6a 71                	push   $0x71
c0104e13:	8d 90 44 2e fe ff    	lea    -0x1d1bc(%eax),%edx
c0104e19:	52                   	push   %edx
c0104e1a:	89 c3                	mov    %eax,%ebx
c0104e1c:	e8 f1 cb ff ff       	call   c0101a12 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0104e21:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e24:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0104e27:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0104e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e30:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0104e33:	eb 1f                	jmp    c0104e54 <insert_vma_struct+0x72>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0104e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e38:	83 e8 10             	sub    $0x10,%eax
c0104e3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0104e3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e41:	8b 50 04             	mov    0x4(%eax),%edx
c0104e44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e47:	8b 40 04             	mov    0x4(%eax),%eax
c0104e4a:	39 c2                	cmp    %eax,%edx
c0104e4c:	77 1f                	ja     c0104e6d <insert_vma_struct+0x8b>
                break;
            }
            le_prev = le;
c0104e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e51:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e57:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e5d:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0104e60:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e66:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104e69:	75 ca                	jne    c0104e35 <insert_vma_struct+0x53>
c0104e6b:	eb 01                	jmp    c0104e6e <insert_vma_struct+0x8c>
                break;
c0104e6d:	90                   	nop
c0104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e71:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e77:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0104e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0104e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e80:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104e83:	74 15                	je     c0104e9a <insert_vma_struct+0xb8>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0104e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e88:	83 e8 10             	sub    $0x10,%eax
c0104e8b:	83 ec 08             	sub    $0x8,%esp
c0104e8e:	ff 75 0c             	pushl  0xc(%ebp)
c0104e91:	50                   	push   %eax
c0104e92:	e8 aa fe ff ff       	call   c0104d41 <check_vma_overlap>
c0104e97:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c0104e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104ea0:	74 15                	je     c0104eb7 <insert_vma_struct+0xd5>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0104ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ea5:	83 e8 10             	sub    $0x10,%eax
c0104ea8:	83 ec 08             	sub    $0x8,%esp
c0104eab:	50                   	push   %eax
c0104eac:	ff 75 0c             	pushl  0xc(%ebp)
c0104eaf:	e8 8d fe ff ff       	call   c0104d41 <check_vma_overlap>
c0104eb4:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c0104eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104eba:	8b 55 08             	mov    0x8(%ebp),%edx
c0104ebd:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0104ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ec2:	8d 50 10             	lea    0x10(%eax),%edx
c0104ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ec8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104ecb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104ece:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ed1:	8b 40 04             	mov    0x4(%eax),%eax
c0104ed4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104ed7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0104eda:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104edd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104ee0:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104ee3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104ee6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104ee9:	89 10                	mov    %edx,(%eax)
c0104eeb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104eee:	8b 10                	mov    (%eax),%edx
c0104ef0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104ef3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104ef6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104ef9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104efc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104eff:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f02:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104f05:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0104f07:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f0a:	8b 40 10             	mov    0x10(%eax),%eax
c0104f0d:	8d 50 01             	lea    0x1(%eax),%edx
c0104f10:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f13:	89 50 10             	mov    %edx,0x10(%eax)
}
c0104f16:	90                   	nop
c0104f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104f1a:	c9                   	leave  
c0104f1b:	c3                   	ret    

c0104f1c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0104f1c:	55                   	push   %ebp
c0104f1d:	89 e5                	mov    %esp,%ebp
c0104f1f:	53                   	push   %ebx
c0104f20:	83 ec 24             	sub    $0x24,%esp
c0104f23:	e8 99 b3 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0104f28:	81 c3 58 4a 02 00    	add    $0x24a58,%ebx

    list_entry_t *list = &(mm->mmap_list), *le;
c0104f2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0104f34:	eb 3a                	jmp    c0104f70 <mm_destroy+0x54>
c0104f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f39:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104f3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f3f:	8b 40 04             	mov    0x4(%eax),%eax
c0104f42:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f45:	8b 12                	mov    (%edx),%edx
c0104f47:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0104f4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104f4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104f53:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f59:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104f5c:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0104f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f61:	83 e8 10             	sub    $0x10,%eax
c0104f64:	83 ec 0c             	sub    $0xc,%esp
c0104f67:	50                   	push   %eax
c0104f68:	e8 82 15 00 00       	call   c01064ef <kfree>
c0104f6d:	83 c4 10             	add    $0x10,%esp
c0104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f73:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0104f76:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f79:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0104f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f82:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f85:	75 af                	jne    c0104f36 <mm_destroy+0x1a>
    }
    kfree(mm); //kfree mm
c0104f87:	83 ec 0c             	sub    $0xc,%esp
c0104f8a:	ff 75 08             	pushl  0x8(%ebp)
c0104f8d:	e8 5d 15 00 00       	call   c01064ef <kfree>
c0104f92:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c0104f95:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0104f9c:	90                   	nop
c0104f9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104fa0:	c9                   	leave  
c0104fa1:	c3                   	ret    

c0104fa2 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0104fa2:	55                   	push   %ebp
c0104fa3:	89 e5                	mov    %esp,%ebp
c0104fa5:	83 ec 08             	sub    $0x8,%esp
c0104fa8:	e8 10 b3 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0104fad:	05 d3 49 02 00       	add    $0x249d3,%eax
    check_vmm();
c0104fb2:	e8 03 00 00 00       	call   c0104fba <check_vmm>
}
c0104fb7:	90                   	nop
c0104fb8:	c9                   	leave  
c0104fb9:	c3                   	ret    

c0104fba <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0104fba:	55                   	push   %ebp
c0104fbb:	89 e5                	mov    %esp,%ebp
c0104fbd:	53                   	push   %ebx
c0104fbe:	83 ec 14             	sub    $0x14,%esp
c0104fc1:	e8 fb b2 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0104fc6:	81 c3 ba 49 02 00    	add    $0x249ba,%ebx
    size_t nr_free_pages_store = nr_free_pages();
c0104fcc:	e8 0d 39 00 00       	call   c01088de <nr_free_pages>
c0104fd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0104fd4:	e8 1d 00 00 00       	call   c0104ff6 <check_vma_struct>
    check_pgfault();
c0104fd9:	e8 76 04 00 00       	call   c0105454 <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c0104fde:	83 ec 0c             	sub    $0xc,%esp
c0104fe1:	8d 83 ad 2e fe ff    	lea    -0x1d153(%ebx),%eax
c0104fe7:	50                   	push   %eax
c0104fe8:	e8 47 b3 ff ff       	call   c0100334 <cprintf>
c0104fed:	83 c4 10             	add    $0x10,%esp
}
c0104ff0:	90                   	nop
c0104ff1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104ff4:	c9                   	leave  
c0104ff5:	c3                   	ret    

c0104ff6 <check_vma_struct>:

static void
check_vma_struct(void) {
c0104ff6:	55                   	push   %ebp
c0104ff7:	89 e5                	mov    %esp,%ebp
c0104ff9:	53                   	push   %ebx
c0104ffa:	83 ec 54             	sub    $0x54,%esp
c0104ffd:	e8 bf b2 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0105002:	81 c3 7e 49 02 00    	add    $0x2497e,%ebx
    size_t nr_free_pages_store = nr_free_pages();
c0105008:	e8 d1 38 00 00       	call   c01088de <nr_free_pages>
c010500d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0105010:	e8 97 fb ff ff       	call   c0104bac <mm_create>
c0105015:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0105018:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010501c:	75 1f                	jne    c010503d <check_vma_struct+0x47>
c010501e:	8d 83 c5 2e fe ff    	lea    -0x1d13b(%ebx),%eax
c0105024:	50                   	push   %eax
c0105025:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c010502b:	50                   	push   %eax
c010502c:	68 b4 00 00 00       	push   $0xb4
c0105031:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c0105037:	50                   	push   %eax
c0105038:	e8 d5 c9 ff ff       	call   c0101a12 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010503d:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0105044:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105047:	89 d0                	mov    %edx,%eax
c0105049:	c1 e0 02             	shl    $0x2,%eax
c010504c:	01 d0                	add    %edx,%eax
c010504e:	01 c0                	add    %eax,%eax
c0105050:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0105053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105056:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105059:	eb 65                	jmp    c01050c0 <check_vma_struct+0xca>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010505b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010505e:	89 d0                	mov    %edx,%eax
c0105060:	c1 e0 02             	shl    $0x2,%eax
c0105063:	01 d0                	add    %edx,%eax
c0105065:	83 c0 02             	add    $0x2,%eax
c0105068:	89 c1                	mov    %eax,%ecx
c010506a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010506d:	89 d0                	mov    %edx,%eax
c010506f:	c1 e0 02             	shl    $0x2,%eax
c0105072:	01 d0                	add    %edx,%eax
c0105074:	83 ec 04             	sub    $0x4,%esp
c0105077:	6a 00                	push   $0x0
c0105079:	51                   	push   %ecx
c010507a:	50                   	push   %eax
c010507b:	e8 ba fb ff ff       	call   c0104c3a <vma_create>
c0105080:	83 c4 10             	add    $0x10,%esp
c0105083:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0105086:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010508a:	75 1f                	jne    c01050ab <check_vma_struct+0xb5>
c010508c:	8d 83 d0 2e fe ff    	lea    -0x1d130(%ebx),%eax
c0105092:	50                   	push   %eax
c0105093:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105099:	50                   	push   %eax
c010509a:	68 bb 00 00 00       	push   $0xbb
c010509f:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01050a5:	50                   	push   %eax
c01050a6:	e8 67 c9 ff ff       	call   c0101a12 <__panic>
        insert_vma_struct(mm, vma);
c01050ab:	83 ec 08             	sub    $0x8,%esp
c01050ae:	ff 75 bc             	pushl  -0x44(%ebp)
c01050b1:	ff 75 e8             	pushl  -0x18(%ebp)
c01050b4:	e8 29 fd ff ff       	call   c0104de2 <insert_vma_struct>
c01050b9:	83 c4 10             	add    $0x10,%esp
    for (i = step1; i >= 1; i --) {
c01050bc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01050c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050c4:	7f 95                	jg     c010505b <check_vma_struct+0x65>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01050c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050c9:	83 c0 01             	add    $0x1,%eax
c01050cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050cf:	eb 65                	jmp    c0105136 <check_vma_struct+0x140>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01050d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01050d4:	89 d0                	mov    %edx,%eax
c01050d6:	c1 e0 02             	shl    $0x2,%eax
c01050d9:	01 d0                	add    %edx,%eax
c01050db:	83 c0 02             	add    $0x2,%eax
c01050de:	89 c1                	mov    %eax,%ecx
c01050e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01050e3:	89 d0                	mov    %edx,%eax
c01050e5:	c1 e0 02             	shl    $0x2,%eax
c01050e8:	01 d0                	add    %edx,%eax
c01050ea:	83 ec 04             	sub    $0x4,%esp
c01050ed:	6a 00                	push   $0x0
c01050ef:	51                   	push   %ecx
c01050f0:	50                   	push   %eax
c01050f1:	e8 44 fb ff ff       	call   c0104c3a <vma_create>
c01050f6:	83 c4 10             	add    $0x10,%esp
c01050f9:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c01050fc:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105100:	75 1f                	jne    c0105121 <check_vma_struct+0x12b>
c0105102:	8d 83 d0 2e fe ff    	lea    -0x1d130(%ebx),%eax
c0105108:	50                   	push   %eax
c0105109:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c010510f:	50                   	push   %eax
c0105110:	68 c1 00 00 00       	push   $0xc1
c0105115:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c010511b:	50                   	push   %eax
c010511c:	e8 f1 c8 ff ff       	call   c0101a12 <__panic>
        insert_vma_struct(mm, vma);
c0105121:	83 ec 08             	sub    $0x8,%esp
c0105124:	ff 75 c0             	pushl  -0x40(%ebp)
c0105127:	ff 75 e8             	pushl  -0x18(%ebp)
c010512a:	e8 b3 fc ff ff       	call   c0104de2 <insert_vma_struct>
c010512f:	83 c4 10             	add    $0x10,%esp
    for (i = step1 + 1; i <= step2; i ++) {
c0105132:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105136:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105139:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010513c:	7e 93                	jle    c01050d1 <check_vma_struct+0xdb>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c010513e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105141:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105144:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105147:	8b 40 04             	mov    0x4(%eax),%eax
c010514a:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c010514d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0105154:	e9 8d 00 00 00       	jmp    c01051e6 <check_vma_struct+0x1f0>
        assert(le != &(mm->mmap_list));
c0105159:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010515c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010515f:	75 1f                	jne    c0105180 <check_vma_struct+0x18a>
c0105161:	8d 83 dc 2e fe ff    	lea    -0x1d124(%ebx),%eax
c0105167:	50                   	push   %eax
c0105168:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c010516e:	50                   	push   %eax
c010516f:	68 c8 00 00 00       	push   $0xc8
c0105174:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c010517a:	50                   	push   %eax
c010517b:	e8 92 c8 ff ff       	call   c0101a12 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0105180:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105183:	83 e8 10             	sub    $0x10,%eax
c0105186:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0105189:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010518c:	8b 48 04             	mov    0x4(%eax),%ecx
c010518f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105192:	89 d0                	mov    %edx,%eax
c0105194:	c1 e0 02             	shl    $0x2,%eax
c0105197:	01 d0                	add    %edx,%eax
c0105199:	39 c1                	cmp    %eax,%ecx
c010519b:	75 17                	jne    c01051b4 <check_vma_struct+0x1be>
c010519d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01051a0:	8b 48 08             	mov    0x8(%eax),%ecx
c01051a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01051a6:	89 d0                	mov    %edx,%eax
c01051a8:	c1 e0 02             	shl    $0x2,%eax
c01051ab:	01 d0                	add    %edx,%eax
c01051ad:	83 c0 02             	add    $0x2,%eax
c01051b0:	39 c1                	cmp    %eax,%ecx
c01051b2:	74 1f                	je     c01051d3 <check_vma_struct+0x1dd>
c01051b4:	8d 83 f4 2e fe ff    	lea    -0x1d10c(%ebx),%eax
c01051ba:	50                   	push   %eax
c01051bb:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c01051c1:	50                   	push   %eax
c01051c2:	68 ca 00 00 00       	push   $0xca
c01051c7:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01051cd:	50                   	push   %eax
c01051ce:	e8 3f c8 ff ff       	call   c0101a12 <__panic>
c01051d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051d6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01051d9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01051dc:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01051df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c01051e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01051e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051e9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01051ec:	0f 8e 67 ff ff ff    	jle    c0105159 <check_vma_struct+0x163>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01051f2:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01051f9:	e9 aa 01 00 00       	jmp    c01053a8 <check_vma_struct+0x3b2>
        struct vma_struct *vma1 = find_vma(mm, i);
c01051fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105201:	83 ec 08             	sub    $0x8,%esp
c0105204:	50                   	push   %eax
c0105205:	ff 75 e8             	pushl  -0x18(%ebp)
c0105208:	e8 79 fa ff ff       	call   c0104c86 <find_vma>
c010520d:	83 c4 10             	add    $0x10,%esp
c0105210:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0105213:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105217:	75 1f                	jne    c0105238 <check_vma_struct+0x242>
c0105219:	8d 83 29 2f fe ff    	lea    -0x1d0d7(%ebx),%eax
c010521f:	50                   	push   %eax
c0105220:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105226:	50                   	push   %eax
c0105227:	68 d0 00 00 00       	push   $0xd0
c010522c:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c0105232:	50                   	push   %eax
c0105233:	e8 da c7 ff ff       	call   c0101a12 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0105238:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010523b:	83 c0 01             	add    $0x1,%eax
c010523e:	83 ec 08             	sub    $0x8,%esp
c0105241:	50                   	push   %eax
c0105242:	ff 75 e8             	pushl  -0x18(%ebp)
c0105245:	e8 3c fa ff ff       	call   c0104c86 <find_vma>
c010524a:	83 c4 10             	add    $0x10,%esp
c010524d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0105250:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105254:	75 1f                	jne    c0105275 <check_vma_struct+0x27f>
c0105256:	8d 83 36 2f fe ff    	lea    -0x1d0ca(%ebx),%eax
c010525c:	50                   	push   %eax
c010525d:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105263:	50                   	push   %eax
c0105264:	68 d2 00 00 00       	push   $0xd2
c0105269:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c010526f:	50                   	push   %eax
c0105270:	e8 9d c7 ff ff       	call   c0101a12 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0105275:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105278:	83 c0 02             	add    $0x2,%eax
c010527b:	83 ec 08             	sub    $0x8,%esp
c010527e:	50                   	push   %eax
c010527f:	ff 75 e8             	pushl  -0x18(%ebp)
c0105282:	e8 ff f9 ff ff       	call   c0104c86 <find_vma>
c0105287:	83 c4 10             	add    $0x10,%esp
c010528a:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c010528d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0105291:	74 1f                	je     c01052b2 <check_vma_struct+0x2bc>
c0105293:	8d 83 43 2f fe ff    	lea    -0x1d0bd(%ebx),%eax
c0105299:	50                   	push   %eax
c010529a:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c01052a0:	50                   	push   %eax
c01052a1:	68 d4 00 00 00       	push   $0xd4
c01052a6:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01052ac:	50                   	push   %eax
c01052ad:	e8 60 c7 ff ff       	call   c0101a12 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01052b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b5:	83 c0 03             	add    $0x3,%eax
c01052b8:	83 ec 08             	sub    $0x8,%esp
c01052bb:	50                   	push   %eax
c01052bc:	ff 75 e8             	pushl  -0x18(%ebp)
c01052bf:	e8 c2 f9 ff ff       	call   c0104c86 <find_vma>
c01052c4:	83 c4 10             	add    $0x10,%esp
c01052c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c01052ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01052ce:	74 1f                	je     c01052ef <check_vma_struct+0x2f9>
c01052d0:	8d 83 50 2f fe ff    	lea    -0x1d0b0(%ebx),%eax
c01052d6:	50                   	push   %eax
c01052d7:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c01052dd:	50                   	push   %eax
c01052de:	68 d6 00 00 00       	push   $0xd6
c01052e3:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01052e9:	50                   	push   %eax
c01052ea:	e8 23 c7 ff ff       	call   c0101a12 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01052ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052f2:	83 c0 04             	add    $0x4,%eax
c01052f5:	83 ec 08             	sub    $0x8,%esp
c01052f8:	50                   	push   %eax
c01052f9:	ff 75 e8             	pushl  -0x18(%ebp)
c01052fc:	e8 85 f9 ff ff       	call   c0104c86 <find_vma>
c0105301:	83 c4 10             	add    $0x10,%esp
c0105304:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0105307:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010530b:	74 1f                	je     c010532c <check_vma_struct+0x336>
c010530d:	8d 83 5d 2f fe ff    	lea    -0x1d0a3(%ebx),%eax
c0105313:	50                   	push   %eax
c0105314:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c010531a:	50                   	push   %eax
c010531b:	68 d8 00 00 00       	push   $0xd8
c0105320:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c0105326:	50                   	push   %eax
c0105327:	e8 e6 c6 ff ff       	call   c0101a12 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c010532c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010532f:	8b 50 04             	mov    0x4(%eax),%edx
c0105332:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105335:	39 c2                	cmp    %eax,%edx
c0105337:	75 10                	jne    c0105349 <check_vma_struct+0x353>
c0105339:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010533c:	8b 40 08             	mov    0x8(%eax),%eax
c010533f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105342:	83 c2 02             	add    $0x2,%edx
c0105345:	39 d0                	cmp    %edx,%eax
c0105347:	74 1f                	je     c0105368 <check_vma_struct+0x372>
c0105349:	8d 83 6c 2f fe ff    	lea    -0x1d094(%ebx),%eax
c010534f:	50                   	push   %eax
c0105350:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105356:	50                   	push   %eax
c0105357:	68 da 00 00 00       	push   $0xda
c010535c:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c0105362:	50                   	push   %eax
c0105363:	e8 aa c6 ff ff       	call   c0101a12 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0105368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010536b:	8b 50 04             	mov    0x4(%eax),%edx
c010536e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105371:	39 c2                	cmp    %eax,%edx
c0105373:	75 10                	jne    c0105385 <check_vma_struct+0x38f>
c0105375:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105378:	8b 40 08             	mov    0x8(%eax),%eax
c010537b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010537e:	83 c2 02             	add    $0x2,%edx
c0105381:	39 d0                	cmp    %edx,%eax
c0105383:	74 1f                	je     c01053a4 <check_vma_struct+0x3ae>
c0105385:	8d 83 9c 2f fe ff    	lea    -0x1d064(%ebx),%eax
c010538b:	50                   	push   %eax
c010538c:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105392:	50                   	push   %eax
c0105393:	68 db 00 00 00       	push   $0xdb
c0105398:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c010539e:	50                   	push   %eax
c010539f:	e8 6e c6 ff ff       	call   c0101a12 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c01053a4:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01053a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01053ab:	89 d0                	mov    %edx,%eax
c01053ad:	c1 e0 02             	shl    $0x2,%eax
c01053b0:	01 d0                	add    %edx,%eax
c01053b2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01053b5:	0f 8e 43 fe ff ff    	jle    c01051fe <check_vma_struct+0x208>
    }

    for (i =4; i>=0; i--) {
c01053bb:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c01053c2:	eb 64                	jmp    c0105428 <check_vma_struct+0x432>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c01053c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053c7:	83 ec 08             	sub    $0x8,%esp
c01053ca:	50                   	push   %eax
c01053cb:	ff 75 e8             	pushl  -0x18(%ebp)
c01053ce:	e8 b3 f8 ff ff       	call   c0104c86 <find_vma>
c01053d3:	83 c4 10             	add    $0x10,%esp
c01053d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c01053d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01053dd:	74 20                	je     c01053ff <check_vma_struct+0x409>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01053df:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053e2:	8b 50 08             	mov    0x8(%eax),%edx
c01053e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053e8:	8b 40 04             	mov    0x4(%eax),%eax
c01053eb:	52                   	push   %edx
c01053ec:	50                   	push   %eax
c01053ed:	ff 75 f4             	pushl  -0xc(%ebp)
c01053f0:	8d 83 cc 2f fe ff    	lea    -0x1d034(%ebx),%eax
c01053f6:	50                   	push   %eax
c01053f7:	e8 38 af ff ff       	call   c0100334 <cprintf>
c01053fc:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c01053ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105403:	74 1f                	je     c0105424 <check_vma_struct+0x42e>
c0105405:	8d 83 f1 2f fe ff    	lea    -0x1d00f(%ebx),%eax
c010540b:	50                   	push   %eax
c010540c:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105412:	50                   	push   %eax
c0105413:	68 e3 00 00 00       	push   $0xe3
c0105418:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c010541e:	50                   	push   %eax
c010541f:	e8 ee c5 ff ff       	call   c0101a12 <__panic>
    for (i =4; i>=0; i--) {
c0105424:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105428:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010542c:	79 96                	jns    c01053c4 <check_vma_struct+0x3ce>
    }

    mm_destroy(mm);
c010542e:	83 ec 0c             	sub    $0xc,%esp
c0105431:	ff 75 e8             	pushl  -0x18(%ebp)
c0105434:	e8 e3 fa ff ff       	call   c0104f1c <mm_destroy>
c0105439:	83 c4 10             	add    $0x10,%esp

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c010543c:	83 ec 0c             	sub    $0xc,%esp
c010543f:	8d 83 08 30 fe ff    	lea    -0x1cff8(%ebx),%eax
c0105445:	50                   	push   %eax
c0105446:	e8 e9 ae ff ff       	call   c0100334 <cprintf>
c010544b:	83 c4 10             	add    $0x10,%esp
}
c010544e:	90                   	nop
c010544f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105452:	c9                   	leave  
c0105453:	c3                   	ret    

c0105454 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0105454:	55                   	push   %ebp
c0105455:	89 e5                	mov    %esp,%ebp
c0105457:	53                   	push   %ebx
c0105458:	83 ec 24             	sub    $0x24,%esp
c010545b:	e8 61 ae ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0105460:	81 c3 20 45 02 00    	add    $0x24520,%ebx
    size_t nr_free_pages_store = nr_free_pages();
c0105466:	e8 73 34 00 00       	call   c01088de <nr_free_pages>
c010546b:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c010546e:	e8 39 f7 ff ff       	call   c0104bac <mm_create>
c0105473:	89 c2                	mov    %eax,%edx
c0105475:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c010547b:	89 10                	mov    %edx,(%eax)
    assert(check_mm_struct != NULL);
c010547d:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c0105483:	8b 00                	mov    (%eax),%eax
c0105485:	85 c0                	test   %eax,%eax
c0105487:	75 1f                	jne    c01054a8 <check_pgfault+0x54>
c0105489:	8d 83 27 30 fe ff    	lea    -0x1cfd9(%ebx),%eax
c010548f:	50                   	push   %eax
c0105490:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105496:	50                   	push   %eax
c0105497:	68 f5 00 00 00       	push   $0xf5
c010549c:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01054a2:	50                   	push   %eax
c01054a3:	e8 6a c5 ff ff       	call   c0101a12 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01054a8:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c01054ae:	8b 00                	mov    (%eax),%eax
c01054b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c01054b3:	c7 c0 c4 aa 12 c0    	mov    $0xc012aac4,%eax
c01054b9:	8b 10                	mov    (%eax),%edx
c01054bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054be:	89 50 0c             	mov    %edx,0xc(%eax)
c01054c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054c4:	8b 40 0c             	mov    0xc(%eax),%eax
c01054c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01054ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054cd:	8b 00                	mov    (%eax),%eax
c01054cf:	85 c0                	test   %eax,%eax
c01054d1:	74 1f                	je     c01054f2 <check_pgfault+0x9e>
c01054d3:	8d 83 3f 30 fe ff    	lea    -0x1cfc1(%ebx),%eax
c01054d9:	50                   	push   %eax
c01054da:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c01054e0:	50                   	push   %eax
c01054e1:	68 f9 00 00 00       	push   $0xf9
c01054e6:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01054ec:	50                   	push   %eax
c01054ed:	e8 20 c5 ff ff       	call   c0101a12 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01054f2:	83 ec 04             	sub    $0x4,%esp
c01054f5:	6a 02                	push   $0x2
c01054f7:	68 00 00 40 00       	push   $0x400000
c01054fc:	6a 00                	push   $0x0
c01054fe:	e8 37 f7 ff ff       	call   c0104c3a <vma_create>
c0105503:	83 c4 10             	add    $0x10,%esp
c0105506:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0105509:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010550d:	75 1f                	jne    c010552e <check_pgfault+0xda>
c010550f:	8d 83 d0 2e fe ff    	lea    -0x1d130(%ebx),%eax
c0105515:	50                   	push   %eax
c0105516:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c010551c:	50                   	push   %eax
c010551d:	68 fc 00 00 00       	push   $0xfc
c0105522:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c0105528:	50                   	push   %eax
c0105529:	e8 e4 c4 ff ff       	call   c0101a12 <__panic>

    insert_vma_struct(mm, vma);
c010552e:	83 ec 08             	sub    $0x8,%esp
c0105531:	ff 75 e0             	pushl  -0x20(%ebp)
c0105534:	ff 75 e8             	pushl  -0x18(%ebp)
c0105537:	e8 a6 f8 ff ff       	call   c0104de2 <insert_vma_struct>
c010553c:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c010553f:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0105546:	83 ec 08             	sub    $0x8,%esp
c0105549:	ff 75 dc             	pushl  -0x24(%ebp)
c010554c:	ff 75 e8             	pushl  -0x18(%ebp)
c010554f:	e8 32 f7 ff ff       	call   c0104c86 <find_vma>
c0105554:	83 c4 10             	add    $0x10,%esp
c0105557:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010555a:	74 1f                	je     c010557b <check_pgfault+0x127>
c010555c:	8d 83 4d 30 fe ff    	lea    -0x1cfb3(%ebx),%eax
c0105562:	50                   	push   %eax
c0105563:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105569:	50                   	push   %eax
c010556a:	68 01 01 00 00       	push   $0x101
c010556f:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c0105575:	50                   	push   %eax
c0105576:	e8 97 c4 ff ff       	call   c0101a12 <__panic>

    int i, sum = 0;
c010557b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0105582:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105589:	eb 19                	jmp    c01055a4 <check_pgfault+0x150>
        *(char *)(addr + i) = i;
c010558b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010558e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105591:	01 d0                	add    %edx,%eax
c0105593:	89 c2                	mov    %eax,%edx
c0105595:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105598:	88 02                	mov    %al,(%edx)
        sum += i;
c010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010559d:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01055a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01055a4:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01055a8:	7e e1                	jle    c010558b <check_pgfault+0x137>
    }
    for (i = 0; i < 100; i ++) {
c01055aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01055b1:	eb 15                	jmp    c01055c8 <check_pgfault+0x174>
        sum -= *(char *)(addr + i);
c01055b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01055b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055b9:	01 d0                	add    %edx,%eax
c01055bb:	0f b6 00             	movzbl (%eax),%eax
c01055be:	0f be c0             	movsbl %al,%eax
c01055c1:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01055c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01055c8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01055cc:	7e e5                	jle    c01055b3 <check_pgfault+0x15f>
    }
    assert(sum == 0);
c01055ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01055d2:	74 1f                	je     c01055f3 <check_pgfault+0x19f>
c01055d4:	8d 83 67 30 fe ff    	lea    -0x1cf99(%ebx),%eax
c01055da:	50                   	push   %eax
c01055db:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c01055e1:	50                   	push   %eax
c01055e2:	68 0b 01 00 00       	push   $0x10b
c01055e7:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c01055ed:	50                   	push   %eax
c01055ee:	e8 1f c4 ff ff       	call   c0101a12 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01055f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01055f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01055fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105601:	83 ec 08             	sub    $0x8,%esp
c0105604:	50                   	push   %eax
c0105605:	ff 75 e4             	pushl  -0x1c(%ebp)
c0105608:	e8 de 3b 00 00       	call   c01091eb <page_remove>
c010560d:	83 c4 10             	add    $0x10,%esp
    free_page(pa2page(pgdir[0]));
c0105610:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105613:	8b 00                	mov    (%eax),%eax
c0105615:	83 ec 0c             	sub    $0xc,%esp
c0105618:	50                   	push   %eax
c0105619:	e8 2e f5 ff ff       	call   c0104b4c <pa2page>
c010561e:	83 c4 10             	add    $0x10,%esp
c0105621:	83 ec 08             	sub    $0x8,%esp
c0105624:	6a 01                	push   $0x1
c0105626:	50                   	push   %eax
c0105627:	e8 6b 32 00 00       	call   c0108897 <free_pages>
c010562c:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c010562f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105632:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0105638:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010563b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0105642:	83 ec 0c             	sub    $0xc,%esp
c0105645:	ff 75 e8             	pushl  -0x18(%ebp)
c0105648:	e8 cf f8 ff ff       	call   c0104f1c <mm_destroy>
c010564d:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c0105650:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c0105656:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    assert(nr_free_pages_store == nr_free_pages());
c010565c:	e8 7d 32 00 00       	call   c01088de <nr_free_pages>
c0105661:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105664:	74 1f                	je     c0105685 <check_pgfault+0x231>
c0105666:	8d 83 70 30 fe ff    	lea    -0x1cf90(%ebx),%eax
c010566c:	50                   	push   %eax
c010566d:	8d 83 2f 2e fe ff    	lea    -0x1d1d1(%ebx),%eax
c0105673:	50                   	push   %eax
c0105674:	68 15 01 00 00       	push   $0x115
c0105679:	8d 83 44 2e fe ff    	lea    -0x1d1bc(%ebx),%eax
c010567f:	50                   	push   %eax
c0105680:	e8 8d c3 ff ff       	call   c0101a12 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0105685:	83 ec 0c             	sub    $0xc,%esp
c0105688:	8d 83 97 30 fe ff    	lea    -0x1cf69(%ebx),%eax
c010568e:	50                   	push   %eax
c010568f:	e8 a0 ac ff ff       	call   c0100334 <cprintf>
c0105694:	83 c4 10             	add    $0x10,%esp
}
c0105697:	90                   	nop
c0105698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010569b:	c9                   	leave  
c010569c:	c3                   	ret    

c010569d <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010569d:	55                   	push   %ebp
c010569e:	89 e5                	mov    %esp,%ebp
c01056a0:	53                   	push   %ebx
c01056a1:	83 ec 24             	sub    $0x24,%esp
c01056a4:	e8 18 ac ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01056a9:	81 c3 d7 42 02 00    	add    $0x242d7,%ebx
    int ret = -E_INVAL;
c01056af:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01056b6:	ff 75 10             	pushl  0x10(%ebp)
c01056b9:	ff 75 08             	pushl  0x8(%ebp)
c01056bc:	e8 c5 f5 ff ff       	call   c0104c86 <find_vma>
c01056c1:	83 c4 08             	add    $0x8,%esp
c01056c4:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01056c7:	8b 83 24 11 00 00    	mov    0x1124(%ebx),%eax
c01056cd:	83 c0 01             	add    $0x1,%eax
c01056d0:	89 83 24 11 00 00    	mov    %eax,0x1124(%ebx)
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01056d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01056da:	74 0b                	je     c01056e7 <do_pgfault+0x4a>
c01056dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056df:	8b 40 04             	mov    0x4(%eax),%eax
c01056e2:	39 45 10             	cmp    %eax,0x10(%ebp)
c01056e5:	73 1a                	jae    c0105701 <do_pgfault+0x64>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01056e7:	83 ec 08             	sub    $0x8,%esp
c01056ea:	ff 75 10             	pushl  0x10(%ebp)
c01056ed:	8d 83 b4 30 fe ff    	lea    -0x1cf4c(%ebx),%eax
c01056f3:	50                   	push   %eax
c01056f4:	e8 3b ac ff ff       	call   c0100334 <cprintf>
c01056f9:	83 c4 10             	add    $0x10,%esp
        goto failed;
c01056fc:	e9 b2 01 00 00       	jmp    c01058b3 <do_pgfault+0x216>
    }
    //check the error_code
    switch (error_code & 3) {
c0105701:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105704:	83 e0 03             	and    $0x3,%eax
c0105707:	85 c0                	test   %eax,%eax
c0105709:	74 40                	je     c010574b <do_pgfault+0xae>
c010570b:	83 f8 01             	cmp    $0x1,%eax
c010570e:	74 24                	je     c0105734 <do_pgfault+0x97>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0105710:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105713:	8b 40 0c             	mov    0xc(%eax),%eax
c0105716:	83 e0 02             	and    $0x2,%eax
c0105719:	85 c0                	test   %eax,%eax
c010571b:	75 52                	jne    c010576f <do_pgfault+0xd2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010571d:	83 ec 0c             	sub    $0xc,%esp
c0105720:	8d 83 e4 30 fe ff    	lea    -0x1cf1c(%ebx),%eax
c0105726:	50                   	push   %eax
c0105727:	e8 08 ac ff ff       	call   c0100334 <cprintf>
c010572c:	83 c4 10             	add    $0x10,%esp
            goto failed;
c010572f:	e9 7f 01 00 00       	jmp    c01058b3 <do_pgfault+0x216>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0105734:	83 ec 0c             	sub    $0xc,%esp
c0105737:	8d 83 44 31 fe ff    	lea    -0x1cebc(%ebx),%eax
c010573d:	50                   	push   %eax
c010573e:	e8 f1 ab ff ff       	call   c0100334 <cprintf>
c0105743:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0105746:	e9 68 01 00 00       	jmp    c01058b3 <do_pgfault+0x216>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c010574b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010574e:	8b 40 0c             	mov    0xc(%eax),%eax
c0105751:	83 e0 05             	and    $0x5,%eax
c0105754:	85 c0                	test   %eax,%eax
c0105756:	75 18                	jne    c0105770 <do_pgfault+0xd3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0105758:	83 ec 0c             	sub    $0xc,%esp
c010575b:	8d 83 7c 31 fe ff    	lea    -0x1ce84(%ebx),%eax
c0105761:	50                   	push   %eax
c0105762:	e8 cd ab ff ff       	call   c0100334 <cprintf>
c0105767:	83 c4 10             	add    $0x10,%esp
            goto failed;
c010576a:	e9 44 01 00 00       	jmp    c01058b3 <do_pgfault+0x216>
        break;
c010576f:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0105770:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0105777:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010577a:	8b 40 0c             	mov    0xc(%eax),%eax
c010577d:	83 e0 02             	and    $0x2,%eax
c0105780:	85 c0                	test   %eax,%eax
c0105782:	74 04                	je     c0105788 <do_pgfault+0xeb>
        perm |= PTE_W;
c0105784:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0105788:	8b 45 10             	mov    0x10(%ebp),%eax
c010578b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010578e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105791:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105796:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0105799:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01057a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c01057a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057aa:	8b 40 0c             	mov    0xc(%eax),%eax
c01057ad:	83 ec 04             	sub    $0x4,%esp
c01057b0:	6a 01                	push   $0x1
c01057b2:	ff 75 10             	pushl  0x10(%ebp)
c01057b5:	50                   	push   %eax
c01057b6:	e8 2b 38 00 00       	call   c0108fe6 <get_pte>
c01057bb:	83 c4 10             	add    $0x10,%esp
c01057be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01057c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01057c5:	75 17                	jne    c01057de <do_pgfault+0x141>
        cprintf("get_pte in do_pgfault failed\n");
c01057c7:	83 ec 0c             	sub    $0xc,%esp
c01057ca:	8d 83 df 31 fe ff    	lea    -0x1ce21(%ebx),%eax
c01057d0:	50                   	push   %eax
c01057d1:	e8 5e ab ff ff       	call   c0100334 <cprintf>
c01057d6:	83 c4 10             	add    $0x10,%esp
        goto failed;
c01057d9:	e9 d5 00 00 00       	jmp    c01058b3 <do_pgfault+0x216>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c01057de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057e1:	8b 00                	mov    (%eax),%eax
c01057e3:	85 c0                	test   %eax,%eax
c01057e5:	75 37                	jne    c010581e <do_pgfault+0x181>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01057e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ea:	8b 40 0c             	mov    0xc(%eax),%eax
c01057ed:	83 ec 04             	sub    $0x4,%esp
c01057f0:	ff 75 f0             	pushl  -0x10(%ebp)
c01057f3:	ff 75 10             	pushl  0x10(%ebp)
c01057f6:	50                   	push   %eax
c01057f7:	e8 59 3b 00 00       	call   c0109355 <pgdir_alloc_page>
c01057fc:	83 c4 10             	add    $0x10,%esp
c01057ff:	85 c0                	test   %eax,%eax
c0105801:	0f 85 a5 00 00 00    	jne    c01058ac <do_pgfault+0x20f>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0105807:	83 ec 0c             	sub    $0xc,%esp
c010580a:	8d 83 00 32 fe ff    	lea    -0x1ce00(%ebx),%eax
c0105810:	50                   	push   %eax
c0105811:	e8 1e ab ff ff       	call   c0100334 <cprintf>
c0105816:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0105819:	e9 95 00 00 00       	jmp    c01058b3 <do_pgfault+0x216>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c010581e:	c7 c0 ac aa 12 c0    	mov    $0xc012aaac,%eax
c0105824:	8b 00                	mov    (%eax),%eax
c0105826:	85 c0                	test   %eax,%eax
c0105828:	74 68                	je     c0105892 <do_pgfault+0x1f5>
            struct Page *page=NULL;
c010582a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0105831:	83 ec 04             	sub    $0x4,%esp
c0105834:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0105837:	50                   	push   %eax
c0105838:	ff 75 10             	pushl  0x10(%ebp)
c010583b:	ff 75 08             	pushl  0x8(%ebp)
c010583e:	e8 7e 11 00 00       	call   c01069c1 <swap_in>
c0105843:	83 c4 10             	add    $0x10,%esp
c0105846:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105849:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010584d:	74 14                	je     c0105863 <do_pgfault+0x1c6>
                cprintf("swap_in in do_pgfault failed\n");
c010584f:	83 ec 0c             	sub    $0xc,%esp
c0105852:	8d 83 27 32 fe ff    	lea    -0x1cdd9(%ebx),%eax
c0105858:	50                   	push   %eax
c0105859:	e8 d6 aa ff ff       	call   c0100334 <cprintf>
c010585e:	83 c4 10             	add    $0x10,%esp
c0105861:	eb 50                	jmp    c01058b3 <do_pgfault+0x216>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0105863:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105866:	8b 45 08             	mov    0x8(%ebp),%eax
c0105869:	8b 40 0c             	mov    0xc(%eax),%eax
c010586c:	ff 75 f0             	pushl  -0x10(%ebp)
c010586f:	ff 75 10             	pushl  0x10(%ebp)
c0105872:	52                   	push   %edx
c0105873:	50                   	push   %eax
c0105874:	e8 b5 39 00 00       	call   c010922e <page_insert>
c0105879:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c010587c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010587f:	6a 01                	push   $0x1
c0105881:	50                   	push   %eax
c0105882:	ff 75 10             	pushl  0x10(%ebp)
c0105885:	ff 75 08             	pushl  0x8(%ebp)
c0105888:	e8 71 0f 00 00       	call   c01067fe <swap_map_swappable>
c010588d:	83 c4 10             	add    $0x10,%esp
c0105890:	eb 1a                	jmp    c01058ac <do_pgfault+0x20f>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0105892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105895:	8b 00                	mov    (%eax),%eax
c0105897:	83 ec 08             	sub    $0x8,%esp
c010589a:	50                   	push   %eax
c010589b:	8d 83 48 32 fe ff    	lea    -0x1cdb8(%ebx),%eax
c01058a1:	50                   	push   %eax
c01058a2:	e8 8d aa ff ff       	call   c0100334 <cprintf>
c01058a7:	83 c4 10             	add    $0x10,%esp
            goto failed;
c01058aa:	eb 07                	jmp    c01058b3 <do_pgfault+0x216>
        }
   }
   ret = 0;
c01058ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01058b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01058b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01058b9:	c9                   	leave  
c01058ba:	c3                   	ret    

c01058bb <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c01058bb:	55                   	push   %ebp
c01058bc:	89 e5                	mov    %esp,%ebp
c01058be:	83 ec 10             	sub    $0x10,%esp
c01058c1:	e8 f7 a9 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01058c6:	05 ba 40 02 00       	add    $0x240ba,%eax
c01058cb:	c7 c2 9c cb 12 c0    	mov    $0xc012cb9c,%edx
c01058d1:	89 55 fc             	mov    %edx,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01058d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01058d7:	8b 4d fc             	mov    -0x4(%ebp),%ecx
c01058da:	89 4a 04             	mov    %ecx,0x4(%edx)
c01058dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01058e0:	8b 4a 04             	mov    0x4(%edx),%ecx
c01058e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01058e6:	89 0a                	mov    %ecx,(%edx)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01058e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01058eb:	c7 c0 9c cb 12 c0    	mov    $0xc012cb9c,%eax
c01058f1:	89 42 14             	mov    %eax,0x14(%edx)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01058f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01058f9:	c9                   	leave  
c01058fa:	c3                   	ret    

c01058fb <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01058fb:	55                   	push   %ebp
c01058fc:	89 e5                	mov    %esp,%ebp
c01058fe:	53                   	push   %ebx
c01058ff:	83 ec 34             	sub    $0x34,%esp
c0105902:	e8 b6 a9 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105907:	05 79 40 02 00       	add    $0x24079,%eax
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010590c:	8b 55 08             	mov    0x8(%ebp),%edx
c010590f:	8b 52 14             	mov    0x14(%edx),%edx
c0105912:	89 55 f4             	mov    %edx,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0105915:	8b 55 10             	mov    0x10(%ebp),%edx
c0105918:	83 c2 18             	add    $0x18,%edx
c010591b:	89 55 f0             	mov    %edx,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c010591e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105922:	74 06                	je     c010592a <_fifo_map_swappable+0x2f>
c0105924:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105928:	75 1e                	jne    c0105948 <_fifo_map_swappable+0x4d>
c010592a:	8d 90 70 32 fe ff    	lea    -0x1cd90(%eax),%edx
c0105930:	52                   	push   %edx
c0105931:	8d 90 8e 32 fe ff    	lea    -0x1cd72(%eax),%edx
c0105937:	52                   	push   %edx
c0105938:	6a 32                	push   $0x32
c010593a:	8d 90 a3 32 fe ff    	lea    -0x1cd5d(%eax),%edx
c0105940:	52                   	push   %edx
c0105941:	89 c3                	mov    %eax,%ebx
c0105943:	e8 ca c0 ff ff       	call   c0101a12 <__panic>
c0105948:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010594b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010594e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105951:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105954:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105957:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010595a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010595d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105960:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105963:	8b 40 04             	mov    0x4(%eax),%eax
c0105966:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105969:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010596c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010596f:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105972:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0105975:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105978:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010597b:	89 10                	mov    %edx,(%eax)
c010597d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105980:	8b 10                	mov    (%eax),%edx
c0105982:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105985:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010598b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010598e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105991:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105994:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105997:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0105999:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010599e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01059a1:	c9                   	leave  
c01059a2:	c3                   	ret    

c01059a3 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c01059a3:	55                   	push   %ebp
c01059a4:	89 e5                	mov    %esp,%ebp
c01059a6:	53                   	push   %ebx
c01059a7:	83 ec 24             	sub    $0x24,%esp
c01059aa:	e8 0e a9 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01059af:	05 d1 3f 02 00       	add    $0x23fd1,%eax
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01059b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01059b7:	8b 52 14             	mov    0x14(%edx),%edx
c01059ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
         assert(head != NULL);
c01059bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01059c1:	75 1e                	jne    c01059e1 <_fifo_swap_out_victim+0x3e>
c01059c3:	8d 90 b7 32 fe ff    	lea    -0x1cd49(%eax),%edx
c01059c9:	52                   	push   %edx
c01059ca:	8d 90 8e 32 fe ff    	lea    -0x1cd72(%eax),%edx
c01059d0:	52                   	push   %edx
c01059d1:	6a 41                	push   $0x41
c01059d3:	8d 90 a3 32 fe ff    	lea    -0x1cd5d(%eax),%edx
c01059d9:	52                   	push   %edx
c01059da:	89 c3                	mov    %eax,%ebx
c01059dc:	e8 31 c0 ff ff       	call   c0101a12 <__panic>
     assert(in_tick==0);
c01059e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01059e5:	74 1e                	je     c0105a05 <_fifo_swap_out_victim+0x62>
c01059e7:	8d 90 c4 32 fe ff    	lea    -0x1cd3c(%eax),%edx
c01059ed:	52                   	push   %edx
c01059ee:	8d 90 8e 32 fe ff    	lea    -0x1cd72(%eax),%edx
c01059f4:	52                   	push   %edx
c01059f5:	6a 42                	push   $0x42
c01059f7:	8d 90 a3 32 fe ff    	lea    -0x1cd5d(%eax),%edx
c01059fd:	52                   	push   %edx
c01059fe:	89 c3                	mov    %eax,%ebx
c0105a00:	e8 0d c0 ff ff       	call   c0101a12 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0105a05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a08:	8b 12                	mov    (%edx),%edx
c0105a0a:	89 55 f0             	mov    %edx,-0x10(%ebp)
     assert(head!=le);
c0105a0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a10:	3b 55 f0             	cmp    -0x10(%ebp),%edx
c0105a13:	75 1e                	jne    c0105a33 <_fifo_swap_out_victim+0x90>
c0105a15:	8d 90 cf 32 fe ff    	lea    -0x1cd31(%eax),%edx
c0105a1b:	52                   	push   %edx
c0105a1c:	8d 90 8e 32 fe ff    	lea    -0x1cd72(%eax),%edx
c0105a22:	52                   	push   %edx
c0105a23:	6a 49                	push   $0x49
c0105a25:	8d 90 a3 32 fe ff    	lea    -0x1cd5d(%eax),%edx
c0105a2b:	52                   	push   %edx
c0105a2c:	89 c3                	mov    %eax,%ebx
c0105a2e:	e8 df bf ff ff       	call   c0101a12 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0105a33:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a36:	83 ea 18             	sub    $0x18,%edx
c0105a39:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105a3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a3f:	89 55 e8             	mov    %edx,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105a42:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105a45:	8b 52 04             	mov    0x4(%edx),%edx
c0105a48:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0105a4b:	8b 09                	mov    (%ecx),%ecx
c0105a4d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
c0105a50:	89 55 e0             	mov    %edx,-0x20(%ebp)
    prev->next = next;
c0105a53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105a56:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105a59:	89 4a 04             	mov    %ecx,0x4(%edx)
    next->prev = prev;
c0105a5c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105a5f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c0105a62:	89 0a                	mov    %ecx,(%edx)
     list_del(le);
     assert(p !=NULL);
c0105a64:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105a68:	75 1e                	jne    c0105a88 <_fifo_swap_out_victim+0xe5>
c0105a6a:	8d 90 d8 32 fe ff    	lea    -0x1cd28(%eax),%edx
c0105a70:	52                   	push   %edx
c0105a71:	8d 90 8e 32 fe ff    	lea    -0x1cd72(%eax),%edx
c0105a77:	52                   	push   %edx
c0105a78:	6a 4c                	push   $0x4c
c0105a7a:	8d 90 a3 32 fe ff    	lea    -0x1cd5d(%eax),%edx
c0105a80:	52                   	push   %edx
c0105a81:	89 c3                	mov    %eax,%ebx
c0105a83:	e8 8a bf ff ff       	call   c0101a12 <__panic>
     *ptr_page = p;
c0105a88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a8e:	89 10                	mov    %edx,(%eax)
     return 0;
c0105a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105a98:	c9                   	leave  
c0105a99:	c3                   	ret    

c0105a9a <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0105a9a:	55                   	push   %ebp
c0105a9b:	89 e5                	mov    %esp,%ebp
c0105a9d:	53                   	push   %ebx
c0105a9e:	83 ec 04             	sub    $0x4,%esp
c0105aa1:	e8 1b a8 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0105aa6:	81 c3 da 3e 02 00    	add    $0x23eda,%ebx
    cprintf("write Virt Page c in fifo_check_swap\n");
c0105aac:	83 ec 0c             	sub    $0xc,%esp
c0105aaf:	8d 83 e4 32 fe ff    	lea    -0x1cd1c(%ebx),%eax
c0105ab5:	50                   	push   %eax
c0105ab6:	e8 79 a8 ff ff       	call   c0100334 <cprintf>
c0105abb:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0105abe:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105ac3:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0105ac6:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105acc:	8b 00                	mov    (%eax),%eax
c0105ace:	83 f8 04             	cmp    $0x4,%eax
c0105ad1:	74 1c                	je     c0105aef <_fifo_check_swap+0x55>
c0105ad3:	8d 83 0a 33 fe ff    	lea    -0x1ccf6(%ebx),%eax
c0105ad9:	50                   	push   %eax
c0105ada:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105ae0:	50                   	push   %eax
c0105ae1:	6a 55                	push   $0x55
c0105ae3:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105ae9:	50                   	push   %eax
c0105aea:	e8 23 bf ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105aef:	83 ec 0c             	sub    $0xc,%esp
c0105af2:	8d 83 1c 33 fe ff    	lea    -0x1cce4(%ebx),%eax
c0105af8:	50                   	push   %eax
c0105af9:	e8 36 a8 ff ff       	call   c0100334 <cprintf>
c0105afe:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0105b01:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105b06:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0105b09:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105b0f:	8b 00                	mov    (%eax),%eax
c0105b11:	83 f8 04             	cmp    $0x4,%eax
c0105b14:	74 1c                	je     c0105b32 <_fifo_check_swap+0x98>
c0105b16:	8d 83 0a 33 fe ff    	lea    -0x1ccf6(%ebx),%eax
c0105b1c:	50                   	push   %eax
c0105b1d:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105b23:	50                   	push   %eax
c0105b24:	6a 58                	push   $0x58
c0105b26:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105b2c:	50                   	push   %eax
c0105b2d:	e8 e0 be ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105b32:	83 ec 0c             	sub    $0xc,%esp
c0105b35:	8d 83 44 33 fe ff    	lea    -0x1ccbc(%ebx),%eax
c0105b3b:	50                   	push   %eax
c0105b3c:	e8 f3 a7 ff ff       	call   c0100334 <cprintf>
c0105b41:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0105b44:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105b49:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0105b4c:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105b52:	8b 00                	mov    (%eax),%eax
c0105b54:	83 f8 04             	cmp    $0x4,%eax
c0105b57:	74 1c                	je     c0105b75 <_fifo_check_swap+0xdb>
c0105b59:	8d 83 0a 33 fe ff    	lea    -0x1ccf6(%ebx),%eax
c0105b5f:	50                   	push   %eax
c0105b60:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105b66:	50                   	push   %eax
c0105b67:	6a 5b                	push   $0x5b
c0105b69:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105b6f:	50                   	push   %eax
c0105b70:	e8 9d be ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105b75:	83 ec 0c             	sub    $0xc,%esp
c0105b78:	8d 83 6c 33 fe ff    	lea    -0x1cc94(%ebx),%eax
c0105b7e:	50                   	push   %eax
c0105b7f:	e8 b0 a7 ff ff       	call   c0100334 <cprintf>
c0105b84:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0105b87:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105b8c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0105b8f:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105b95:	8b 00                	mov    (%eax),%eax
c0105b97:	83 f8 04             	cmp    $0x4,%eax
c0105b9a:	74 1c                	je     c0105bb8 <_fifo_check_swap+0x11e>
c0105b9c:	8d 83 0a 33 fe ff    	lea    -0x1ccf6(%ebx),%eax
c0105ba2:	50                   	push   %eax
c0105ba3:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105ba9:	50                   	push   %eax
c0105baa:	6a 5e                	push   $0x5e
c0105bac:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105bb2:	50                   	push   %eax
c0105bb3:	e8 5a be ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0105bb8:	83 ec 0c             	sub    $0xc,%esp
c0105bbb:	8d 83 94 33 fe ff    	lea    -0x1cc6c(%ebx),%eax
c0105bc1:	50                   	push   %eax
c0105bc2:	e8 6d a7 ff ff       	call   c0100334 <cprintf>
c0105bc7:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0105bca:	b8 00 50 00 00       	mov    $0x5000,%eax
c0105bcf:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0105bd2:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105bd8:	8b 00                	mov    (%eax),%eax
c0105bda:	83 f8 05             	cmp    $0x5,%eax
c0105bdd:	74 1c                	je     c0105bfb <_fifo_check_swap+0x161>
c0105bdf:	8d 83 ba 33 fe ff    	lea    -0x1cc46(%ebx),%eax
c0105be5:	50                   	push   %eax
c0105be6:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105bec:	50                   	push   %eax
c0105bed:	6a 61                	push   $0x61
c0105bef:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105bf5:	50                   	push   %eax
c0105bf6:	e8 17 be ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105bfb:	83 ec 0c             	sub    $0xc,%esp
c0105bfe:	8d 83 6c 33 fe ff    	lea    -0x1cc94(%ebx),%eax
c0105c04:	50                   	push   %eax
c0105c05:	e8 2a a7 ff ff       	call   c0100334 <cprintf>
c0105c0a:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0105c0d:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105c12:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0105c15:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105c1b:	8b 00                	mov    (%eax),%eax
c0105c1d:	83 f8 05             	cmp    $0x5,%eax
c0105c20:	74 1c                	je     c0105c3e <_fifo_check_swap+0x1a4>
c0105c22:	8d 83 ba 33 fe ff    	lea    -0x1cc46(%ebx),%eax
c0105c28:	50                   	push   %eax
c0105c29:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105c2f:	50                   	push   %eax
c0105c30:	6a 64                	push   $0x64
c0105c32:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105c38:	50                   	push   %eax
c0105c39:	e8 d4 bd ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105c3e:	83 ec 0c             	sub    $0xc,%esp
c0105c41:	8d 83 1c 33 fe ff    	lea    -0x1cce4(%ebx),%eax
c0105c47:	50                   	push   %eax
c0105c48:	e8 e7 a6 ff ff       	call   c0100334 <cprintf>
c0105c4d:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0105c50:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105c55:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0105c58:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105c5e:	8b 00                	mov    (%eax),%eax
c0105c60:	83 f8 06             	cmp    $0x6,%eax
c0105c63:	74 1c                	je     c0105c81 <_fifo_check_swap+0x1e7>
c0105c65:	8d 83 c9 33 fe ff    	lea    -0x1cc37(%ebx),%eax
c0105c6b:	50                   	push   %eax
c0105c6c:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105c72:	50                   	push   %eax
c0105c73:	6a 67                	push   $0x67
c0105c75:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105c7b:	50                   	push   %eax
c0105c7c:	e8 91 bd ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105c81:	83 ec 0c             	sub    $0xc,%esp
c0105c84:	8d 83 6c 33 fe ff    	lea    -0x1cc94(%ebx),%eax
c0105c8a:	50                   	push   %eax
c0105c8b:	e8 a4 a6 ff ff       	call   c0100334 <cprintf>
c0105c90:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0105c93:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105c98:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0105c9b:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105ca1:	8b 00                	mov    (%eax),%eax
c0105ca3:	83 f8 07             	cmp    $0x7,%eax
c0105ca6:	74 1c                	je     c0105cc4 <_fifo_check_swap+0x22a>
c0105ca8:	8d 83 d8 33 fe ff    	lea    -0x1cc28(%ebx),%eax
c0105cae:	50                   	push   %eax
c0105caf:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105cb5:	50                   	push   %eax
c0105cb6:	6a 6a                	push   $0x6a
c0105cb8:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105cbe:	50                   	push   %eax
c0105cbf:	e8 4e bd ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0105cc4:	83 ec 0c             	sub    $0xc,%esp
c0105cc7:	8d 83 e4 32 fe ff    	lea    -0x1cd1c(%ebx),%eax
c0105ccd:	50                   	push   %eax
c0105cce:	e8 61 a6 ff ff       	call   c0100334 <cprintf>
c0105cd3:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0105cd6:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105cdb:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0105cde:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105ce4:	8b 00                	mov    (%eax),%eax
c0105ce6:	83 f8 08             	cmp    $0x8,%eax
c0105ce9:	74 1c                	je     c0105d07 <_fifo_check_swap+0x26d>
c0105ceb:	8d 83 e7 33 fe ff    	lea    -0x1cc19(%ebx),%eax
c0105cf1:	50                   	push   %eax
c0105cf2:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105cf8:	50                   	push   %eax
c0105cf9:	6a 6d                	push   $0x6d
c0105cfb:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105d01:	50                   	push   %eax
c0105d02:	e8 0b bd ff ff       	call   c0101a12 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105d07:	83 ec 0c             	sub    $0xc,%esp
c0105d0a:	8d 83 44 33 fe ff    	lea    -0x1ccbc(%ebx),%eax
c0105d10:	50                   	push   %eax
c0105d11:	e8 1e a6 ff ff       	call   c0100334 <cprintf>
c0105d16:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0105d19:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105d1e:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0105d21:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0105d27:	8b 00                	mov    (%eax),%eax
c0105d29:	83 f8 09             	cmp    $0x9,%eax
c0105d2c:	74 1c                	je     c0105d4a <_fifo_check_swap+0x2b0>
c0105d2e:	8d 83 f6 33 fe ff    	lea    -0x1cc0a(%ebx),%eax
c0105d34:	50                   	push   %eax
c0105d35:	8d 83 8e 32 fe ff    	lea    -0x1cd72(%ebx),%eax
c0105d3b:	50                   	push   %eax
c0105d3c:	6a 70                	push   $0x70
c0105d3e:	8d 83 a3 32 fe ff    	lea    -0x1cd5d(%ebx),%eax
c0105d44:	50                   	push   %eax
c0105d45:	e8 c8 bc ff ff       	call   c0101a12 <__panic>
    return 0;
c0105d4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105d52:	c9                   	leave  
c0105d53:	c3                   	ret    

c0105d54 <_fifo_init>:


static int
_fifo_init(void)
{
c0105d54:	55                   	push   %ebp
c0105d55:	89 e5                	mov    %esp,%ebp
c0105d57:	e8 61 a5 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105d5c:	05 24 3c 02 00       	add    $0x23c24,%eax
    return 0;
c0105d61:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105d66:	5d                   	pop    %ebp
c0105d67:	c3                   	ret    

c0105d68 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0105d68:	55                   	push   %ebp
c0105d69:	89 e5                	mov    %esp,%ebp
c0105d6b:	e8 4d a5 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105d70:	05 10 3c 02 00       	add    $0x23c10,%eax
    return 0;
c0105d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105d7a:	5d                   	pop    %ebp
c0105d7b:	c3                   	ret    

c0105d7c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0105d7c:	55                   	push   %ebp
c0105d7d:	89 e5                	mov    %esp,%ebp
c0105d7f:	e8 39 a5 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105d84:	05 fc 3b 02 00       	add    $0x23bfc,%eax
c0105d89:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d8e:	5d                   	pop    %ebp
c0105d8f:	c3                   	ret    

c0105d90 <__intr_save>:
__intr_save(void) {
c0105d90:	55                   	push   %ebp
c0105d91:	89 e5                	mov    %esp,%ebp
c0105d93:	53                   	push   %ebx
c0105d94:	83 ec 14             	sub    $0x14,%esp
c0105d97:	e8 21 a5 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105d9c:	05 e4 3b 02 00       	add    $0x23be4,%eax
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0105da1:	9c                   	pushf  
c0105da2:	5a                   	pop    %edx
c0105da3:	89 55 f4             	mov    %edx,-0xc(%ebp)
    return eflags;
c0105da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if (read_eflags() & FL_IF) {
c0105da9:	81 e2 00 02 00 00    	and    $0x200,%edx
c0105daf:	85 d2                	test   %edx,%edx
c0105db1:	74 0e                	je     c0105dc1 <__intr_save+0x31>
        intr_disable();
c0105db3:	89 c3                	mov    %eax,%ebx
c0105db5:	e8 c2 db ff ff       	call   c010397c <intr_disable>
        return 1;
c0105dba:	b8 01 00 00 00       	mov    $0x1,%eax
c0105dbf:	eb 05                	jmp    c0105dc6 <__intr_save+0x36>
    return 0;
c0105dc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105dc6:	83 c4 14             	add    $0x14,%esp
c0105dc9:	5b                   	pop    %ebx
c0105dca:	5d                   	pop    %ebp
c0105dcb:	c3                   	ret    

c0105dcc <__intr_restore>:
__intr_restore(bool flag) {
c0105dcc:	55                   	push   %ebp
c0105dcd:	89 e5                	mov    %esp,%ebp
c0105dcf:	53                   	push   %ebx
c0105dd0:	83 ec 04             	sub    $0x4,%esp
c0105dd3:	e8 e5 a4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105dd8:	05 a8 3b 02 00       	add    $0x23ba8,%eax
    if (flag) {
c0105ddd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105de1:	74 07                	je     c0105dea <__intr_restore+0x1e>
        intr_enable();
c0105de3:	89 c3                	mov    %eax,%ebx
c0105de5:	e8 81 db ff ff       	call   c010396b <intr_enable>
}
c0105dea:	90                   	nop
c0105deb:	83 c4 04             	add    $0x4,%esp
c0105dee:	5b                   	pop    %ebx
c0105def:	5d                   	pop    %ebp
c0105df0:	c3                   	ret    

c0105df1 <page2ppn>:
page2ppn(struct Page *page) {
c0105df1:	55                   	push   %ebp
c0105df2:	89 e5                	mov    %esp,%ebp
c0105df4:	e8 c4 a4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105df9:	05 87 3b 02 00       	add    $0x23b87,%eax
    return page - pages;
c0105dfe:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e01:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0105e07:	8b 00                	mov    (%eax),%eax
c0105e09:	29 c2                	sub    %eax,%edx
c0105e0b:	89 d0                	mov    %edx,%eax
c0105e0d:	c1 f8 02             	sar    $0x2,%eax
c0105e10:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0105e16:	5d                   	pop    %ebp
c0105e17:	c3                   	ret    

c0105e18 <page2pa>:
page2pa(struct Page *page) {
c0105e18:	55                   	push   %ebp
c0105e19:	89 e5                	mov    %esp,%ebp
c0105e1b:	e8 9d a4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105e20:	05 60 3b 02 00       	add    $0x23b60,%eax
    return page2ppn(page) << PGSHIFT;
c0105e25:	ff 75 08             	pushl  0x8(%ebp)
c0105e28:	e8 c4 ff ff ff       	call   c0105df1 <page2ppn>
c0105e2d:	83 c4 04             	add    $0x4,%esp
c0105e30:	c1 e0 0c             	shl    $0xc,%eax
}
c0105e33:	c9                   	leave  
c0105e34:	c3                   	ret    

c0105e35 <pa2page>:
pa2page(uintptr_t pa) {
c0105e35:	55                   	push   %ebp
c0105e36:	89 e5                	mov    %esp,%ebp
c0105e38:	53                   	push   %ebx
c0105e39:	83 ec 04             	sub    $0x4,%esp
c0105e3c:	e8 7c a4 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105e41:	05 3f 3b 02 00       	add    $0x23b3f,%eax
    if (PPN(pa) >= npage) {
c0105e46:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e49:	89 d1                	mov    %edx,%ecx
c0105e4b:	c1 e9 0c             	shr    $0xc,%ecx
c0105e4e:	c7 c2 c0 aa 12 c0    	mov    $0xc012aac0,%edx
c0105e54:	8b 12                	mov    (%edx),%edx
c0105e56:	39 d1                	cmp    %edx,%ecx
c0105e58:	72 1a                	jb     c0105e74 <pa2page+0x3f>
        panic("pa2page called with invalid pa");
c0105e5a:	83 ec 04             	sub    $0x4,%esp
c0105e5d:	8d 90 18 34 fe ff    	lea    -0x1cbe8(%eax),%edx
c0105e63:	52                   	push   %edx
c0105e64:	6a 5f                	push   $0x5f
c0105e66:	8d 90 37 34 fe ff    	lea    -0x1cbc9(%eax),%edx
c0105e6c:	52                   	push   %edx
c0105e6d:	89 c3                	mov    %eax,%ebx
c0105e6f:	e8 9e bb ff ff       	call   c0101a12 <__panic>
    return &pages[PPN(pa)];
c0105e74:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0105e7a:	8b 08                	mov    (%eax),%ecx
c0105e7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e7f:	c1 e8 0c             	shr    $0xc,%eax
c0105e82:	89 c2                	mov    %eax,%edx
c0105e84:	89 d0                	mov    %edx,%eax
c0105e86:	c1 e0 03             	shl    $0x3,%eax
c0105e89:	01 d0                	add    %edx,%eax
c0105e8b:	c1 e0 02             	shl    $0x2,%eax
c0105e8e:	01 c8                	add    %ecx,%eax
}
c0105e90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105e93:	c9                   	leave  
c0105e94:	c3                   	ret    

c0105e95 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105e95:	55                   	push   %ebp
c0105e96:	89 e5                	mov    %esp,%ebp
c0105e98:	53                   	push   %ebx
c0105e99:	83 ec 14             	sub    $0x14,%esp
c0105e9c:	e8 20 a4 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0105ea1:	81 c3 df 3a 02 00    	add    $0x23adf,%ebx
    return KADDR(page2pa(page));
c0105ea7:	ff 75 08             	pushl  0x8(%ebp)
c0105eaa:	e8 69 ff ff ff       	call   c0105e18 <page2pa>
c0105eaf:	83 c4 04             	add    $0x4,%esp
c0105eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eb8:	c1 e8 0c             	shr    $0xc,%eax
c0105ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ebe:	c7 c0 c0 aa 12 c0    	mov    $0xc012aac0,%eax
c0105ec4:	8b 00                	mov    (%eax),%eax
c0105ec6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105ec9:	72 18                	jb     c0105ee3 <page2kva+0x4e>
c0105ecb:	ff 75 f4             	pushl  -0xc(%ebp)
c0105ece:	8d 83 48 34 fe ff    	lea    -0x1cbb8(%ebx),%eax
c0105ed4:	50                   	push   %eax
c0105ed5:	6a 66                	push   $0x66
c0105ed7:	8d 83 37 34 fe ff    	lea    -0x1cbc9(%ebx),%eax
c0105edd:	50                   	push   %eax
c0105ede:	e8 2f bb ff ff       	call   c0101a12 <__panic>
c0105ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ee6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105eeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105eee:	c9                   	leave  
c0105eef:	c3                   	ret    

c0105ef0 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0105ef0:	55                   	push   %ebp
c0105ef1:	89 e5                	mov    %esp,%ebp
c0105ef3:	53                   	push   %ebx
c0105ef4:	83 ec 14             	sub    $0x14,%esp
c0105ef7:	e8 c1 a3 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105efc:	05 84 3a 02 00       	add    $0x23a84,%eax
    return pa2page(PADDR(kva));
c0105f01:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f04:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105f07:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105f0e:	77 1a                	ja     c0105f2a <kva2page+0x3a>
c0105f10:	ff 75 f4             	pushl  -0xc(%ebp)
c0105f13:	8d 90 6c 34 fe ff    	lea    -0x1cb94(%eax),%edx
c0105f19:	52                   	push   %edx
c0105f1a:	6a 6b                	push   $0x6b
c0105f1c:	8d 90 37 34 fe ff    	lea    -0x1cbc9(%eax),%edx
c0105f22:	52                   	push   %edx
c0105f23:	89 c3                	mov    %eax,%ebx
c0105f25:	e8 e8 ba ff ff       	call   c0101a12 <__panic>
c0105f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f2d:	05 00 00 00 40       	add    $0x40000000,%eax
c0105f32:	83 ec 0c             	sub    $0xc,%esp
c0105f35:	50                   	push   %eax
c0105f36:	e8 fa fe ff ff       	call   c0105e35 <pa2page>
c0105f3b:	83 c4 10             	add    $0x10,%esp
}
c0105f3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105f41:	c9                   	leave  
c0105f42:	c3                   	ret    

c0105f43 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0105f43:	55                   	push   %ebp
c0105f44:	89 e5                	mov    %esp,%ebp
c0105f46:	53                   	push   %ebx
c0105f47:	83 ec 14             	sub    $0x14,%esp
c0105f4a:	e8 6e a3 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0105f4f:	05 31 3a 02 00       	add    $0x23a31,%eax
  struct Page * page = alloc_pages(1 << order);
c0105f54:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105f57:	bb 01 00 00 00       	mov    $0x1,%ebx
c0105f5c:	89 d1                	mov    %edx,%ecx
c0105f5e:	d3 e3                	shl    %cl,%ebx
c0105f60:	89 da                	mov    %ebx,%edx
c0105f62:	83 ec 0c             	sub    $0xc,%esp
c0105f65:	52                   	push   %edx
c0105f66:	89 c3                	mov    %eax,%ebx
c0105f68:	e8 a6 28 00 00       	call   c0108813 <alloc_pages>
c0105f6d:	83 c4 10             	add    $0x10,%esp
c0105f70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0105f73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f77:	75 07                	jne    c0105f80 <__slob_get_free_pages+0x3d>
    return NULL;
c0105f79:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f7e:	eb 0e                	jmp    c0105f8e <__slob_get_free_pages+0x4b>
  return page2kva(page);
c0105f80:	83 ec 0c             	sub    $0xc,%esp
c0105f83:	ff 75 f4             	pushl  -0xc(%ebp)
c0105f86:	e8 0a ff ff ff       	call   c0105e95 <page2kva>
c0105f8b:	83 c4 10             	add    $0x10,%esp
}
c0105f8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105f91:	c9                   	leave  
c0105f92:	c3                   	ret    

c0105f93 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0105f93:	55                   	push   %ebp
c0105f94:	89 e5                	mov    %esp,%ebp
c0105f96:	56                   	push   %esi
c0105f97:	53                   	push   %ebx
c0105f98:	e8 24 a3 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0105f9d:	81 c3 e3 39 02 00    	add    $0x239e3,%ebx
  free_pages(kva2page(kva), 1 << order);
c0105fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fa6:	ba 01 00 00 00       	mov    $0x1,%edx
c0105fab:	89 c1                	mov    %eax,%ecx
c0105fad:	d3 e2                	shl    %cl,%edx
c0105faf:	89 d0                	mov    %edx,%eax
c0105fb1:	89 c6                	mov    %eax,%esi
c0105fb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fb6:	83 ec 0c             	sub    $0xc,%esp
c0105fb9:	50                   	push   %eax
c0105fba:	e8 31 ff ff ff       	call   c0105ef0 <kva2page>
c0105fbf:	83 c4 10             	add    $0x10,%esp
c0105fc2:	83 ec 08             	sub    $0x8,%esp
c0105fc5:	56                   	push   %esi
c0105fc6:	50                   	push   %eax
c0105fc7:	e8 cb 28 00 00       	call   c0108897 <free_pages>
c0105fcc:	83 c4 10             	add    $0x10,%esp
}
c0105fcf:	90                   	nop
c0105fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0105fd3:	5b                   	pop    %ebx
c0105fd4:	5e                   	pop    %esi
c0105fd5:	5d                   	pop    %ebp
c0105fd6:	c3                   	ret    

c0105fd7 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0105fd7:	55                   	push   %ebp
c0105fd8:	89 e5                	mov    %esp,%ebp
c0105fda:	53                   	push   %ebx
c0105fdb:	83 ec 24             	sub    $0x24,%esp
c0105fde:	e8 de a2 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0105fe3:	81 c3 9d 39 02 00    	add    $0x2399d,%ebx
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0105fe9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fec:	83 c0 08             	add    $0x8,%eax
c0105fef:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105ff4:	76 1c                	jbe    c0106012 <slob_alloc+0x3b>
c0105ff6:	8d 83 90 34 fe ff    	lea    -0x1cb70(%ebx),%eax
c0105ffc:	50                   	push   %eax
c0105ffd:	8d 83 af 34 fe ff    	lea    -0x1cb51(%ebx),%eax
c0106003:	50                   	push   %eax
c0106004:	6a 64                	push   $0x64
c0106006:	8d 83 c4 34 fe ff    	lea    -0x1cb3c(%ebx),%eax
c010600c:	50                   	push   %eax
c010600d:	e8 00 ba ff ff       	call   c0101a12 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0106012:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0106019:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0106020:	8b 45 08             	mov    0x8(%ebp),%eax
c0106023:	83 c0 07             	add    $0x7,%eax
c0106026:	c1 e8 03             	shr    $0x3,%eax
c0106029:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c010602c:	e8 5f fd ff ff       	call   c0105d90 <__intr_save>
c0106031:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0106034:	8b 83 08 01 00 00    	mov    0x108(%ebx),%eax
c010603a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010603d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106040:	8b 40 04             	mov    0x4(%eax),%eax
c0106043:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0106046:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010604a:	74 25                	je     c0106071 <slob_alloc+0x9a>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010604c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010604f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106052:	01 d0                	add    %edx,%eax
c0106054:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106057:	8b 45 10             	mov    0x10(%ebp),%eax
c010605a:	f7 d8                	neg    %eax
c010605c:	21 d0                	and    %edx,%eax
c010605e:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0106061:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106064:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106067:	29 c2                	sub    %eax,%edx
c0106069:	89 d0                	mov    %edx,%eax
c010606b:	c1 f8 03             	sar    $0x3,%eax
c010606e:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0106071:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106074:	8b 00                	mov    (%eax),%eax
c0106076:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106079:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010607c:	01 ca                	add    %ecx,%edx
c010607e:	39 d0                	cmp    %edx,%eax
c0106080:	0f 8c b2 00 00 00    	jl     c0106138 <slob_alloc+0x161>
			if (delta) { /* need to fragment head to align? */
c0106086:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010608a:	74 38                	je     c01060c4 <slob_alloc+0xed>
				aligned->units = cur->units - delta;
c010608c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010608f:	8b 00                	mov    (%eax),%eax
c0106091:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0106094:	89 c2                	mov    %eax,%edx
c0106096:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106099:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c010609b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010609e:	8b 50 04             	mov    0x4(%eax),%edx
c01060a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060a4:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01060a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01060ad:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01060b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060b3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01060b6:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01060b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01060be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01060c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060c7:	8b 00                	mov    (%eax),%eax
c01060c9:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01060cc:	75 0e                	jne    c01060dc <slob_alloc+0x105>
				prev->next = cur->next; /* unlink */
c01060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060d1:	8b 50 04             	mov    0x4(%eax),%edx
c01060d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060d7:	89 50 04             	mov    %edx,0x4(%eax)
c01060da:	eb 3c                	jmp    c0106118 <slob_alloc+0x141>
			else { /* fragment */
				prev->next = cur + units;
c01060dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01060df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01060e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060e9:	01 c2                	add    %eax,%edx
c01060eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ee:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01060f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060f4:	8b 10                	mov    (%eax),%edx
c01060f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060f9:	8b 40 04             	mov    0x4(%eax),%eax
c01060fc:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01060ff:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0106101:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106104:	8b 40 04             	mov    0x4(%eax),%eax
c0106107:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010610a:	8b 52 04             	mov    0x4(%edx),%edx
c010610d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0106110:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106113:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106116:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0106118:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010611b:	89 83 08 01 00 00    	mov    %eax,0x108(%ebx)
			spin_unlock_irqrestore(&slob_lock, flags);
c0106121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106124:	83 ec 0c             	sub    $0xc,%esp
c0106127:	50                   	push   %eax
c0106128:	e8 9f fc ff ff       	call   c0105dcc <__intr_restore>
c010612d:	83 c4 10             	add    $0x10,%esp
			return cur;
c0106130:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106133:	e9 82 00 00 00       	jmp    c01061ba <slob_alloc+0x1e3>
		}
		if (cur == slobfree) {
c0106138:	8b 83 08 01 00 00    	mov    0x108(%ebx),%eax
c010613e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106141:	75 63                	jne    c01061a6 <slob_alloc+0x1cf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0106143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106146:	83 ec 0c             	sub    $0xc,%esp
c0106149:	50                   	push   %eax
c010614a:	e8 7d fc ff ff       	call   c0105dcc <__intr_restore>
c010614f:	83 c4 10             	add    $0x10,%esp

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0106152:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0106159:	75 07                	jne    c0106162 <slob_alloc+0x18b>
				return 0;
c010615b:	b8 00 00 00 00       	mov    $0x0,%eax
c0106160:	eb 58                	jmp    c01061ba <slob_alloc+0x1e3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0106162:	83 ec 08             	sub    $0x8,%esp
c0106165:	6a 00                	push   $0x0
c0106167:	ff 75 0c             	pushl  0xc(%ebp)
c010616a:	e8 d4 fd ff ff       	call   c0105f43 <__slob_get_free_pages>
c010616f:	83 c4 10             	add    $0x10,%esp
c0106172:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0106175:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106179:	75 07                	jne    c0106182 <slob_alloc+0x1ab>
				return 0;
c010617b:	b8 00 00 00 00       	mov    $0x0,%eax
c0106180:	eb 38                	jmp    c01061ba <slob_alloc+0x1e3>

			slob_free(cur, PAGE_SIZE);
c0106182:	83 ec 08             	sub    $0x8,%esp
c0106185:	68 00 10 00 00       	push   $0x1000
c010618a:	ff 75 f0             	pushl  -0x10(%ebp)
c010618d:	e8 2d 00 00 00       	call   c01061bf <slob_free>
c0106192:	83 c4 10             	add    $0x10,%esp
			spin_lock_irqsave(&slob_lock, flags);
c0106195:	e8 f6 fb ff ff       	call   c0105d90 <__intr_save>
c010619a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c010619d:	8b 83 08 01 00 00    	mov    0x108(%ebx),%eax
c01061a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01061a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01061ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061af:	8b 40 04             	mov    0x4(%eax),%eax
c01061b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01061b5:	e9 8c fe ff ff       	jmp    c0106046 <slob_alloc+0x6f>
		}
	}
}
c01061ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01061bd:	c9                   	leave  
c01061be:	c3                   	ret    

c01061bf <slob_free>:

static void slob_free(void *block, int size)
{
c01061bf:	55                   	push   %ebp
c01061c0:	89 e5                	mov    %esp,%ebp
c01061c2:	53                   	push   %ebx
c01061c3:	83 ec 14             	sub    $0x14,%esp
c01061c6:	e8 f6 a0 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01061cb:	81 c3 b5 37 02 00    	add    $0x237b5,%ebx
	slob_t *cur, *b = (slob_t *)block;
c01061d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01061d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01061d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01061db:	0f 84 07 01 00 00    	je     c01062e8 <slob_free+0x129>
		return;

	if (size)
c01061e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01061e5:	74 10                	je     c01061f7 <slob_free+0x38>
		b->units = SLOB_UNITS(size);
c01061e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061ea:	83 c0 07             	add    $0x7,%eax
c01061ed:	c1 e8 03             	shr    $0x3,%eax
c01061f0:	89 c2                	mov    %eax,%edx
c01061f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061f5:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01061f7:	e8 94 fb ff ff       	call   c0105d90 <__intr_save>
c01061fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01061ff:	8b 83 08 01 00 00    	mov    0x108(%ebx),%eax
c0106205:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106208:	eb 27                	jmp    c0106231 <slob_free+0x72>
		if (cur >= cur->next && (b > cur || b < cur->next))
c010620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010620d:	8b 40 04             	mov    0x4(%eax),%eax
c0106210:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106213:	72 13                	jb     c0106228 <slob_free+0x69>
c0106215:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106218:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010621b:	77 27                	ja     c0106244 <slob_free+0x85>
c010621d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106220:	8b 40 04             	mov    0x4(%eax),%eax
c0106223:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106226:	72 1c                	jb     c0106244 <slob_free+0x85>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010622b:	8b 40 04             	mov    0x4(%eax),%eax
c010622e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106231:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106234:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106237:	76 d1                	jbe    c010620a <slob_free+0x4b>
c0106239:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010623c:	8b 40 04             	mov    0x4(%eax),%eax
c010623f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106242:	73 c6                	jae    c010620a <slob_free+0x4b>
			break;

	if (b + b->units == cur->next) {
c0106244:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106247:	8b 00                	mov    (%eax),%eax
c0106249:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0106250:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106253:	01 c2                	add    %eax,%edx
c0106255:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106258:	8b 40 04             	mov    0x4(%eax),%eax
c010625b:	39 c2                	cmp    %eax,%edx
c010625d:	75 25                	jne    c0106284 <slob_free+0xc5>
		b->units += cur->next->units;
c010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106262:	8b 10                	mov    (%eax),%edx
c0106264:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106267:	8b 40 04             	mov    0x4(%eax),%eax
c010626a:	8b 00                	mov    (%eax),%eax
c010626c:	01 c2                	add    %eax,%edx
c010626e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106271:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0106273:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106276:	8b 40 04             	mov    0x4(%eax),%eax
c0106279:	8b 50 04             	mov    0x4(%eax),%edx
c010627c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010627f:	89 50 04             	mov    %edx,0x4(%eax)
c0106282:	eb 0c                	jmp    c0106290 <slob_free+0xd1>
	} else
		b->next = cur->next;
c0106284:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106287:	8b 50 04             	mov    0x4(%eax),%edx
c010628a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010628d:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0106290:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106293:	8b 00                	mov    (%eax),%eax
c0106295:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010629c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010629f:	01 d0                	add    %edx,%eax
c01062a1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01062a4:	75 1f                	jne    c01062c5 <slob_free+0x106>
		cur->units += b->units;
c01062a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062a9:	8b 10                	mov    (%eax),%edx
c01062ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062ae:	8b 00                	mov    (%eax),%eax
c01062b0:	01 c2                	add    %eax,%edx
c01062b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062b5:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c01062b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062ba:	8b 50 04             	mov    0x4(%eax),%edx
c01062bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062c0:	89 50 04             	mov    %edx,0x4(%eax)
c01062c3:	eb 09                	jmp    c01062ce <slob_free+0x10f>
	} else
		cur->next = b;
c01062c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01062cb:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c01062ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062d1:	89 83 08 01 00 00    	mov    %eax,0x108(%ebx)

	spin_unlock_irqrestore(&slob_lock, flags);
c01062d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062da:	83 ec 0c             	sub    $0xc,%esp
c01062dd:	50                   	push   %eax
c01062de:	e8 e9 fa ff ff       	call   c0105dcc <__intr_restore>
c01062e3:	83 c4 10             	add    $0x10,%esp
c01062e6:	eb 01                	jmp    c01062e9 <slob_free+0x12a>
		return;
c01062e8:	90                   	nop
}
c01062e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01062ec:	c9                   	leave  
c01062ed:	c3                   	ret    

c01062ee <check_slab>:



void check_slab(void) {
c01062ee:	55                   	push   %ebp
c01062ef:	89 e5                	mov    %esp,%ebp
c01062f1:	53                   	push   %ebx
c01062f2:	83 ec 04             	sub    $0x4,%esp
c01062f5:	e8 c3 9f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01062fa:	05 86 36 02 00       	add    $0x23686,%eax
  cprintf("check_slab() success\n");
c01062ff:	83 ec 0c             	sub    $0xc,%esp
c0106302:	8d 90 d6 34 fe ff    	lea    -0x1cb2a(%eax),%edx
c0106308:	52                   	push   %edx
c0106309:	89 c3                	mov    %eax,%ebx
c010630b:	e8 24 a0 ff ff       	call   c0100334 <cprintf>
c0106310:	83 c4 10             	add    $0x10,%esp
}
c0106313:	90                   	nop
c0106314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0106317:	c9                   	leave  
c0106318:	c3                   	ret    

c0106319 <slab_init>:

void
slab_init(void) {
c0106319:	55                   	push   %ebp
c010631a:	89 e5                	mov    %esp,%ebp
c010631c:	53                   	push   %ebx
c010631d:	83 ec 04             	sub    $0x4,%esp
c0106320:	e8 98 9f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106325:	05 5b 36 02 00       	add    $0x2365b,%eax
  cprintf("use SLOB allocator\n");
c010632a:	83 ec 0c             	sub    $0xc,%esp
c010632d:	8d 90 ec 34 fe ff    	lea    -0x1cb14(%eax),%edx
c0106333:	52                   	push   %edx
c0106334:	89 c3                	mov    %eax,%ebx
c0106336:	e8 f9 9f ff ff       	call   c0100334 <cprintf>
c010633b:	83 c4 10             	add    $0x10,%esp
  check_slab();
c010633e:	e8 ab ff ff ff       	call   c01062ee <check_slab>
}
c0106343:	90                   	nop
c0106344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0106347:	c9                   	leave  
c0106348:	c3                   	ret    

c0106349 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0106349:	55                   	push   %ebp
c010634a:	89 e5                	mov    %esp,%ebp
c010634c:	53                   	push   %ebx
c010634d:	83 ec 04             	sub    $0x4,%esp
c0106350:	e8 6c 9f ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0106355:	81 c3 2b 36 02 00    	add    $0x2362b,%ebx
    slab_init();
c010635b:	e8 b9 ff ff ff       	call   c0106319 <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c0106360:	83 ec 0c             	sub    $0xc,%esp
c0106363:	8d 83 00 35 fe ff    	lea    -0x1cb00(%ebx),%eax
c0106369:	50                   	push   %eax
c010636a:	e8 c5 9f ff ff       	call   c0100334 <cprintf>
c010636f:	83 c4 10             	add    $0x10,%esp
}
c0106372:	90                   	nop
c0106373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0106376:	c9                   	leave  
c0106377:	c3                   	ret    

c0106378 <slab_allocated>:

size_t
slab_allocated(void) {
c0106378:	55                   	push   %ebp
c0106379:	89 e5                	mov    %esp,%ebp
c010637b:	e8 3d 9f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106380:	05 00 36 02 00       	add    $0x23600,%eax
  return 0;
c0106385:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010638a:	5d                   	pop    %ebp
c010638b:	c3                   	ret    

c010638c <kallocated>:

size_t
kallocated(void) {
c010638c:	55                   	push   %ebp
c010638d:	89 e5                	mov    %esp,%ebp
c010638f:	e8 29 9f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106394:	05 ec 35 02 00       	add    $0x235ec,%eax
   return slab_allocated();
c0106399:	e8 da ff ff ff       	call   c0106378 <slab_allocated>
}
c010639e:	5d                   	pop    %ebp
c010639f:	c3                   	ret    

c01063a0 <find_order>:

static int find_order(int size)
{
c01063a0:	55                   	push   %ebp
c01063a1:	89 e5                	mov    %esp,%ebp
c01063a3:	83 ec 10             	sub    $0x10,%esp
c01063a6:	e8 12 9f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01063ab:	05 d5 35 02 00       	add    $0x235d5,%eax
	int order = 0;
c01063b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01063b7:	eb 07                	jmp    c01063c0 <find_order+0x20>
		order++;
c01063b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01063bd:	d1 7d 08             	sarl   0x8(%ebp)
c01063c0:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01063c7:	7f f0                	jg     c01063b9 <find_order+0x19>
	return order;
c01063c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01063cc:	c9                   	leave  
c01063cd:	c3                   	ret    

c01063ce <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c01063ce:	55                   	push   %ebp
c01063cf:	89 e5                	mov    %esp,%ebp
c01063d1:	53                   	push   %ebx
c01063d2:	83 ec 14             	sub    $0x14,%esp
c01063d5:	e8 e7 9e ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01063da:	81 c3 a6 35 02 00    	add    $0x235a6,%ebx
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c01063e0:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c01063e7:	77 35                	ja     c010641e <__kmalloc+0x50>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c01063e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01063ec:	83 c0 08             	add    $0x8,%eax
c01063ef:	83 ec 04             	sub    $0x4,%esp
c01063f2:	6a 00                	push   $0x0
c01063f4:	ff 75 0c             	pushl  0xc(%ebp)
c01063f7:	50                   	push   %eax
c01063f8:	e8 da fb ff ff       	call   c0105fd7 <slob_alloc>
c01063fd:	83 c4 10             	add    $0x10,%esp
c0106400:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0106403:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106407:	74 0b                	je     c0106414 <__kmalloc+0x46>
c0106409:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010640c:	83 c0 08             	add    $0x8,%eax
c010640f:	e9 b4 00 00 00       	jmp    c01064c8 <__kmalloc+0xfa>
c0106414:	b8 00 00 00 00       	mov    $0x0,%eax
c0106419:	e9 aa 00 00 00       	jmp    c01064c8 <__kmalloc+0xfa>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c010641e:	83 ec 04             	sub    $0x4,%esp
c0106421:	6a 00                	push   $0x0
c0106423:	ff 75 0c             	pushl  0xc(%ebp)
c0106426:	6a 0c                	push   $0xc
c0106428:	e8 aa fb ff ff       	call   c0105fd7 <slob_alloc>
c010642d:	83 c4 10             	add    $0x10,%esp
c0106430:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0106433:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106437:	75 0a                	jne    c0106443 <__kmalloc+0x75>
		return 0;
c0106439:	b8 00 00 00 00       	mov    $0x0,%eax
c010643e:	e9 85 00 00 00       	jmp    c01064c8 <__kmalloc+0xfa>

	bb->order = find_order(size);
c0106443:	8b 45 08             	mov    0x8(%ebp),%eax
c0106446:	83 ec 0c             	sub    $0xc,%esp
c0106449:	50                   	push   %eax
c010644a:	e8 51 ff ff ff       	call   c01063a0 <find_order>
c010644f:	83 c4 10             	add    $0x10,%esp
c0106452:	89 c2                	mov    %eax,%edx
c0106454:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106457:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0106459:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010645c:	8b 00                	mov    (%eax),%eax
c010645e:	83 ec 08             	sub    $0x8,%esp
c0106461:	50                   	push   %eax
c0106462:	ff 75 0c             	pushl  0xc(%ebp)
c0106465:	e8 d9 fa ff ff       	call   c0105f43 <__slob_get_free_pages>
c010646a:	83 c4 10             	add    $0x10,%esp
c010646d:	89 c2                	mov    %eax,%edx
c010646f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106472:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c0106475:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106478:	8b 40 04             	mov    0x4(%eax),%eax
c010647b:	85 c0                	test   %eax,%eax
c010647d:	74 34                	je     c01064b3 <__kmalloc+0xe5>
		spin_lock_irqsave(&block_lock, flags);
c010647f:	e8 0c f9 ff ff       	call   c0105d90 <__intr_save>
c0106484:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0106487:	8b 93 28 11 00 00    	mov    0x1128(%ebx),%edx
c010648d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106490:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0106493:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106496:	89 83 28 11 00 00    	mov    %eax,0x1128(%ebx)
		spin_unlock_irqrestore(&block_lock, flags);
c010649c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010649f:	83 ec 0c             	sub    $0xc,%esp
c01064a2:	50                   	push   %eax
c01064a3:	e8 24 f9 ff ff       	call   c0105dcc <__intr_restore>
c01064a8:	83 c4 10             	add    $0x10,%esp
		return bb->pages;
c01064ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064ae:	8b 40 04             	mov    0x4(%eax),%eax
c01064b1:	eb 15                	jmp    c01064c8 <__kmalloc+0xfa>
	}

	slob_free(bb, sizeof(bigblock_t));
c01064b3:	83 ec 08             	sub    $0x8,%esp
c01064b6:	6a 0c                	push   $0xc
c01064b8:	ff 75 f4             	pushl  -0xc(%ebp)
c01064bb:	e8 ff fc ff ff       	call   c01061bf <slob_free>
c01064c0:	83 c4 10             	add    $0x10,%esp
	return 0;
c01064c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01064cb:	c9                   	leave  
c01064cc:	c3                   	ret    

c01064cd <kmalloc>:

void *
kmalloc(size_t size)
{
c01064cd:	55                   	push   %ebp
c01064ce:	89 e5                	mov    %esp,%ebp
c01064d0:	83 ec 08             	sub    $0x8,%esp
c01064d3:	e8 e5 9d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01064d8:	05 a8 34 02 00       	add    $0x234a8,%eax
  return __kmalloc(size, 0);
c01064dd:	83 ec 08             	sub    $0x8,%esp
c01064e0:	6a 00                	push   $0x0
c01064e2:	ff 75 08             	pushl  0x8(%ebp)
c01064e5:	e8 e4 fe ff ff       	call   c01063ce <__kmalloc>
c01064ea:	83 c4 10             	add    $0x10,%esp
}
c01064ed:	c9                   	leave  
c01064ee:	c3                   	ret    

c01064ef <kfree>:


void kfree(void *block)
{
c01064ef:	55                   	push   %ebp
c01064f0:	89 e5                	mov    %esp,%ebp
c01064f2:	53                   	push   %ebx
c01064f3:	83 ec 14             	sub    $0x14,%esp
c01064f6:	e8 c6 9d ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01064fb:	81 c3 85 34 02 00    	add    $0x23485,%ebx
	bigblock_t *bb, **last = &bigblocks;
c0106501:	8d 83 28 11 00 00    	lea    0x1128(%ebx),%eax
c0106507:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010650a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010650e:	0f 84 ad 00 00 00    	je     c01065c1 <kfree+0xd2>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0106514:	8b 45 08             	mov    0x8(%ebp),%eax
c0106517:	25 ff 0f 00 00       	and    $0xfff,%eax
c010651c:	85 c0                	test   %eax,%eax
c010651e:	0f 85 86 00 00 00    	jne    c01065aa <kfree+0xbb>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0106524:	e8 67 f8 ff ff       	call   c0105d90 <__intr_save>
c0106529:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c010652c:	8b 83 28 11 00 00    	mov    0x1128(%ebx),%eax
c0106532:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106535:	eb 5e                	jmp    c0106595 <kfree+0xa6>
			if (bb->pages == block) {
c0106537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010653a:	8b 40 04             	mov    0x4(%eax),%eax
c010653d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106540:	75 41                	jne    c0106583 <kfree+0x94>
				*last = bb->next;
c0106542:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106545:	8b 50 08             	mov    0x8(%eax),%edx
c0106548:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010654b:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c010654d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106550:	83 ec 0c             	sub    $0xc,%esp
c0106553:	50                   	push   %eax
c0106554:	e8 73 f8 ff ff       	call   c0105dcc <__intr_restore>
c0106559:	83 c4 10             	add    $0x10,%esp
				__slob_free_pages((unsigned long)block, bb->order);
c010655c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010655f:	8b 10                	mov    (%eax),%edx
c0106561:	8b 45 08             	mov    0x8(%ebp),%eax
c0106564:	83 ec 08             	sub    $0x8,%esp
c0106567:	52                   	push   %edx
c0106568:	50                   	push   %eax
c0106569:	e8 25 fa ff ff       	call   c0105f93 <__slob_free_pages>
c010656e:	83 c4 10             	add    $0x10,%esp
				slob_free(bb, sizeof(bigblock_t));
c0106571:	83 ec 08             	sub    $0x8,%esp
c0106574:	6a 0c                	push   $0xc
c0106576:	ff 75 f4             	pushl  -0xc(%ebp)
c0106579:	e8 41 fc ff ff       	call   c01061bf <slob_free>
c010657e:	83 c4 10             	add    $0x10,%esp
				return;
c0106581:	eb 3f                	jmp    c01065c2 <kfree+0xd3>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0106583:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106586:	83 c0 08             	add    $0x8,%eax
c0106589:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010658c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010658f:	8b 40 08             	mov    0x8(%eax),%eax
c0106592:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106595:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106599:	75 9c                	jne    c0106537 <kfree+0x48>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c010659b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010659e:	83 ec 0c             	sub    $0xc,%esp
c01065a1:	50                   	push   %eax
c01065a2:	e8 25 f8 ff ff       	call   c0105dcc <__intr_restore>
c01065a7:	83 c4 10             	add    $0x10,%esp
	}

	slob_free((slob_t *)block - 1, 0);
c01065aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01065ad:	83 e8 08             	sub    $0x8,%eax
c01065b0:	83 ec 08             	sub    $0x8,%esp
c01065b3:	6a 00                	push   $0x0
c01065b5:	50                   	push   %eax
c01065b6:	e8 04 fc ff ff       	call   c01061bf <slob_free>
c01065bb:	83 c4 10             	add    $0x10,%esp
	return;
c01065be:	90                   	nop
c01065bf:	eb 01                	jmp    c01065c2 <kfree+0xd3>
		return;
c01065c1:	90                   	nop
}
c01065c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01065c5:	c9                   	leave  
c01065c6:	c3                   	ret    

c01065c7 <ksize>:


unsigned int ksize(const void *block)
{
c01065c7:	55                   	push   %ebp
c01065c8:	89 e5                	mov    %esp,%ebp
c01065ca:	53                   	push   %ebx
c01065cb:	83 ec 14             	sub    $0x14,%esp
c01065ce:	e8 ee 9c ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01065d3:	81 c3 ad 33 02 00    	add    $0x233ad,%ebx
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c01065d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01065dd:	75 07                	jne    c01065e6 <ksize+0x1f>
		return 0;
c01065df:	b8 00 00 00 00       	mov    $0x0,%eax
c01065e4:	eb 74                	jmp    c010665a <ksize+0x93>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01065e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01065e9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01065ee:	85 c0                	test   %eax,%eax
c01065f0:	75 5d                	jne    c010664f <ksize+0x88>
		spin_lock_irqsave(&block_lock, flags);
c01065f2:	e8 99 f7 ff ff       	call   c0105d90 <__intr_save>
c01065f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c01065fa:	8b 83 28 11 00 00    	mov    0x1128(%ebx),%eax
c0106600:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106603:	eb 35                	jmp    c010663a <ksize+0x73>
			if (bb->pages == block) {
c0106605:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106608:	8b 40 04             	mov    0x4(%eax),%eax
c010660b:	39 45 08             	cmp    %eax,0x8(%ebp)
c010660e:	75 21                	jne    c0106631 <ksize+0x6a>
				spin_unlock_irqrestore(&slob_lock, flags);
c0106610:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106613:	83 ec 0c             	sub    $0xc,%esp
c0106616:	50                   	push   %eax
c0106617:	e8 b0 f7 ff ff       	call   c0105dcc <__intr_restore>
c010661c:	83 c4 10             	add    $0x10,%esp
				return PAGE_SIZE << bb->order;
c010661f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106622:	8b 00                	mov    (%eax),%eax
c0106624:	ba 00 10 00 00       	mov    $0x1000,%edx
c0106629:	89 c1                	mov    %eax,%ecx
c010662b:	d3 e2                	shl    %cl,%edx
c010662d:	89 d0                	mov    %edx,%eax
c010662f:	eb 29                	jmp    c010665a <ksize+0x93>
		for (bb = bigblocks; bb; bb = bb->next)
c0106631:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106634:	8b 40 08             	mov    0x8(%eax),%eax
c0106637:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010663a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010663e:	75 c5                	jne    c0106605 <ksize+0x3e>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0106640:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106643:	83 ec 0c             	sub    $0xc,%esp
c0106646:	50                   	push   %eax
c0106647:	e8 80 f7 ff ff       	call   c0105dcc <__intr_restore>
c010664c:	83 c4 10             	add    $0x10,%esp
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c010664f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106652:	83 e8 08             	sub    $0x8,%eax
c0106655:	8b 00                	mov    (%eax),%eax
c0106657:	c1 e0 03             	shl    $0x3,%eax
}
c010665a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010665d:	c9                   	leave  
c010665e:	c3                   	ret    

c010665f <pa2page>:
pa2page(uintptr_t pa) {
c010665f:	55                   	push   %ebp
c0106660:	89 e5                	mov    %esp,%ebp
c0106662:	53                   	push   %ebx
c0106663:	83 ec 04             	sub    $0x4,%esp
c0106666:	e8 52 9c ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010666b:	05 15 33 02 00       	add    $0x23315,%eax
    if (PPN(pa) >= npage) {
c0106670:	8b 55 08             	mov    0x8(%ebp),%edx
c0106673:	89 d1                	mov    %edx,%ecx
c0106675:	c1 e9 0c             	shr    $0xc,%ecx
c0106678:	c7 c2 c0 aa 12 c0    	mov    $0xc012aac0,%edx
c010667e:	8b 12                	mov    (%edx),%edx
c0106680:	39 d1                	cmp    %edx,%ecx
c0106682:	72 1a                	jb     c010669e <pa2page+0x3f>
        panic("pa2page called with invalid pa");
c0106684:	83 ec 04             	sub    $0x4,%esp
c0106687:	8d 90 1c 35 fe ff    	lea    -0x1cae4(%eax),%edx
c010668d:	52                   	push   %edx
c010668e:	6a 5f                	push   $0x5f
c0106690:	8d 90 3b 35 fe ff    	lea    -0x1cac5(%eax),%edx
c0106696:	52                   	push   %edx
c0106697:	89 c3                	mov    %eax,%ebx
c0106699:	e8 74 b3 ff ff       	call   c0101a12 <__panic>
    return &pages[PPN(pa)];
c010669e:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c01066a4:	8b 08                	mov    (%eax),%ecx
c01066a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a9:	c1 e8 0c             	shr    $0xc,%eax
c01066ac:	89 c2                	mov    %eax,%edx
c01066ae:	89 d0                	mov    %edx,%eax
c01066b0:	c1 e0 03             	shl    $0x3,%eax
c01066b3:	01 d0                	add    %edx,%eax
c01066b5:	c1 e0 02             	shl    $0x2,%eax
c01066b8:	01 c8                	add    %ecx,%eax
}
c01066ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01066bd:	c9                   	leave  
c01066be:	c3                   	ret    

c01066bf <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c01066bf:	55                   	push   %ebp
c01066c0:	89 e5                	mov    %esp,%ebp
c01066c2:	53                   	push   %ebx
c01066c3:	83 ec 04             	sub    $0x4,%esp
c01066c6:	e8 f2 9b ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01066cb:	05 b5 32 02 00       	add    $0x232b5,%eax
    if (!(pte & PTE_P)) {
c01066d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01066d3:	83 e2 01             	and    $0x1,%edx
c01066d6:	85 d2                	test   %edx,%edx
c01066d8:	75 1a                	jne    c01066f4 <pte2page+0x35>
        panic("pte2page called with invalid pte");
c01066da:	83 ec 04             	sub    $0x4,%esp
c01066dd:	8d 90 4c 35 fe ff    	lea    -0x1cab4(%eax),%edx
c01066e3:	52                   	push   %edx
c01066e4:	6a 71                	push   $0x71
c01066e6:	8d 90 3b 35 fe ff    	lea    -0x1cac5(%eax),%edx
c01066ec:	52                   	push   %edx
c01066ed:	89 c3                	mov    %eax,%ebx
c01066ef:	e8 1e b3 ff ff       	call   c0101a12 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01066f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01066f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01066fc:	83 ec 0c             	sub    $0xc,%esp
c01066ff:	50                   	push   %eax
c0106700:	e8 5a ff ff ff       	call   c010665f <pa2page>
c0106705:	83 c4 10             	add    $0x10,%esp
}
c0106708:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010670b:	c9                   	leave  
c010670c:	c3                   	ret    

c010670d <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c010670d:	55                   	push   %ebp
c010670e:	89 e5                	mov    %esp,%ebp
c0106710:	53                   	push   %ebx
c0106711:	83 ec 14             	sub    $0x14,%esp
c0106714:	e8 a8 9b ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0106719:	81 c3 67 32 02 00    	add    $0x23267,%ebx
     swapfs_init();
c010671f:	e8 d7 39 00 00       	call   c010a0fb <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106724:	c7 c0 5c cc 12 c0    	mov    $0xc012cc5c,%eax
c010672a:	8b 00                	mov    (%eax),%eax
c010672c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106731:	76 0f                	jbe    c0106742 <swap_init+0x35>
c0106733:	c7 c0 5c cc 12 c0    	mov    $0xc012cc5c,%eax
c0106739:	8b 00                	mov    (%eax),%eax
c010673b:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106740:	76 1e                	jbe    c0106760 <swap_init+0x53>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106742:	c7 c0 5c cc 12 c0    	mov    $0xc012cc5c,%eax
c0106748:	8b 00                	mov    (%eax),%eax
c010674a:	50                   	push   %eax
c010674b:	8d 83 6d 35 fe ff    	lea    -0x1ca93(%ebx),%eax
c0106751:	50                   	push   %eax
c0106752:	6a 25                	push   $0x25
c0106754:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c010675a:	50                   	push   %eax
c010675b:	e8 b2 b2 ff ff       	call   c0101a12 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106760:	c7 c0 60 9a 12 c0    	mov    $0xc0129a60,%eax
c0106766:	89 83 34 11 00 00    	mov    %eax,0x1134(%ebx)
     int r = sm->init();
c010676c:	8b 83 34 11 00 00    	mov    0x1134(%ebx),%eax
c0106772:	8b 40 04             	mov    0x4(%eax),%eax
c0106775:	ff d0                	call   *%eax
c0106777:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c010677a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010677e:	75 2a                	jne    c01067aa <swap_init+0x9d>
     {
          swap_init_ok = 1;
c0106780:	c7 83 2c 11 00 00 01 	movl   $0x1,0x112c(%ebx)
c0106787:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010678a:	8b 83 34 11 00 00    	mov    0x1134(%ebx),%eax
c0106790:	8b 00                	mov    (%eax),%eax
c0106792:	83 ec 08             	sub    $0x8,%esp
c0106795:	50                   	push   %eax
c0106796:	8d 83 97 35 fe ff    	lea    -0x1ca69(%ebx),%eax
c010679c:	50                   	push   %eax
c010679d:	e8 92 9b ff ff       	call   c0100334 <cprintf>
c01067a2:	83 c4 10             	add    $0x10,%esp
          check_swap();
c01067a5:	e8 d1 04 00 00       	call   c0106c7b <check_swap>
     }

     return r;
c01067aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01067ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01067b0:	c9                   	leave  
c01067b1:	c3                   	ret    

c01067b2 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01067b2:	55                   	push   %ebp
c01067b3:	89 e5                	mov    %esp,%ebp
c01067b5:	83 ec 08             	sub    $0x8,%esp
c01067b8:	e8 00 9b ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01067bd:	05 c3 31 02 00       	add    $0x231c3,%eax
     return sm->init_mm(mm);
c01067c2:	8b 80 34 11 00 00    	mov    0x1134(%eax),%eax
c01067c8:	8b 40 08             	mov    0x8(%eax),%eax
c01067cb:	83 ec 0c             	sub    $0xc,%esp
c01067ce:	ff 75 08             	pushl  0x8(%ebp)
c01067d1:	ff d0                	call   *%eax
c01067d3:	83 c4 10             	add    $0x10,%esp
}
c01067d6:	c9                   	leave  
c01067d7:	c3                   	ret    

c01067d8 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01067d8:	55                   	push   %ebp
c01067d9:	89 e5                	mov    %esp,%ebp
c01067db:	83 ec 08             	sub    $0x8,%esp
c01067de:	e8 da 9a ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01067e3:	05 9d 31 02 00       	add    $0x2319d,%eax
     return sm->tick_event(mm);
c01067e8:	8b 80 34 11 00 00    	mov    0x1134(%eax),%eax
c01067ee:	8b 40 0c             	mov    0xc(%eax),%eax
c01067f1:	83 ec 0c             	sub    $0xc,%esp
c01067f4:	ff 75 08             	pushl  0x8(%ebp)
c01067f7:	ff d0                	call   *%eax
c01067f9:	83 c4 10             	add    $0x10,%esp
}
c01067fc:	c9                   	leave  
c01067fd:	c3                   	ret    

c01067fe <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01067fe:	55                   	push   %ebp
c01067ff:	89 e5                	mov    %esp,%ebp
c0106801:	83 ec 08             	sub    $0x8,%esp
c0106804:	e8 b4 9a ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106809:	05 77 31 02 00       	add    $0x23177,%eax
     return sm->map_swappable(mm, addr, page, swap_in);
c010680e:	8b 80 34 11 00 00    	mov    0x1134(%eax),%eax
c0106814:	8b 40 10             	mov    0x10(%eax),%eax
c0106817:	ff 75 14             	pushl  0x14(%ebp)
c010681a:	ff 75 10             	pushl  0x10(%ebp)
c010681d:	ff 75 0c             	pushl  0xc(%ebp)
c0106820:	ff 75 08             	pushl  0x8(%ebp)
c0106823:	ff d0                	call   *%eax
c0106825:	83 c4 10             	add    $0x10,%esp
}
c0106828:	c9                   	leave  
c0106829:	c3                   	ret    

c010682a <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010682a:	55                   	push   %ebp
c010682b:	89 e5                	mov    %esp,%ebp
c010682d:	83 ec 08             	sub    $0x8,%esp
c0106830:	e8 88 9a ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106835:	05 4b 31 02 00       	add    $0x2314b,%eax
     return sm->set_unswappable(mm, addr);
c010683a:	8b 80 34 11 00 00    	mov    0x1134(%eax),%eax
c0106840:	8b 40 14             	mov    0x14(%eax),%eax
c0106843:	83 ec 08             	sub    $0x8,%esp
c0106846:	ff 75 0c             	pushl  0xc(%ebp)
c0106849:	ff 75 08             	pushl  0x8(%ebp)
c010684c:	ff d0                	call   *%eax
c010684e:	83 c4 10             	add    $0x10,%esp
}
c0106851:	c9                   	leave  
c0106852:	c3                   	ret    

c0106853 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106853:	55                   	push   %ebp
c0106854:	89 e5                	mov    %esp,%ebp
c0106856:	53                   	push   %ebx
c0106857:	83 ec 24             	sub    $0x24,%esp
c010685a:	e8 62 9a ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010685f:	81 c3 21 31 02 00    	add    $0x23121,%ebx
     int i;
     for (i = 0; i != n; ++ i)
c0106865:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010686c:	e9 3c 01 00 00       	jmp    c01069ad <swap_out+0x15a>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106871:	8b 83 34 11 00 00    	mov    0x1134(%ebx),%eax
c0106877:	8b 40 18             	mov    0x18(%eax),%eax
c010687a:	83 ec 04             	sub    $0x4,%esp
c010687d:	ff 75 10             	pushl  0x10(%ebp)
c0106880:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106883:	52                   	push   %edx
c0106884:	ff 75 08             	pushl  0x8(%ebp)
c0106887:	ff d0                	call   *%eax
c0106889:	83 c4 10             	add    $0x10,%esp
c010688c:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c010688f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106893:	74 1a                	je     c01068af <swap_out+0x5c>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106895:	83 ec 08             	sub    $0x8,%esp
c0106898:	ff 75 f4             	pushl  -0xc(%ebp)
c010689b:	8d 83 ac 35 fe ff    	lea    -0x1ca54(%ebx),%eax
c01068a1:	50                   	push   %eax
c01068a2:	e8 8d 9a ff ff       	call   c0100334 <cprintf>
c01068a7:	83 c4 10             	add    $0x10,%esp
c01068aa:	e9 0a 01 00 00       	jmp    c01069b9 <swap_out+0x166>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01068af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068b2:	8b 40 20             	mov    0x20(%eax),%eax
c01068b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01068b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01068bb:	8b 40 0c             	mov    0xc(%eax),%eax
c01068be:	83 ec 04             	sub    $0x4,%esp
c01068c1:	6a 00                	push   $0x0
c01068c3:	ff 75 ec             	pushl  -0x14(%ebp)
c01068c6:	50                   	push   %eax
c01068c7:	e8 1a 27 00 00       	call   c0108fe6 <get_pte>
c01068cc:	83 c4 10             	add    $0x10,%esp
c01068cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01068d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01068d5:	8b 00                	mov    (%eax),%eax
c01068d7:	83 e0 01             	and    $0x1,%eax
c01068da:	85 c0                	test   %eax,%eax
c01068dc:	75 1c                	jne    c01068fa <swap_out+0xa7>
c01068de:	8d 83 d9 35 fe ff    	lea    -0x1ca27(%ebx),%eax
c01068e4:	50                   	push   %eax
c01068e5:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c01068eb:	50                   	push   %eax
c01068ec:	6a 65                	push   $0x65
c01068ee:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c01068f4:	50                   	push   %eax
c01068f5:	e8 18 b1 ff ff       	call   c0101a12 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01068fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106900:	8b 52 20             	mov    0x20(%edx),%edx
c0106903:	c1 ea 0c             	shr    $0xc,%edx
c0106906:	83 c2 01             	add    $0x1,%edx
c0106909:	c1 e2 08             	shl    $0x8,%edx
c010690c:	83 ec 08             	sub    $0x8,%esp
c010690f:	50                   	push   %eax
c0106910:	52                   	push   %edx
c0106911:	e8 af 38 00 00       	call   c010a1c5 <swapfs_write>
c0106916:	83 c4 10             	add    $0x10,%esp
c0106919:	85 c0                	test   %eax,%eax
c010691b:	74 2e                	je     c010694b <swap_out+0xf8>
                    cprintf("SWAP: failed to save\n");
c010691d:	83 ec 0c             	sub    $0xc,%esp
c0106920:	8d 83 03 36 fe ff    	lea    -0x1c9fd(%ebx),%eax
c0106926:	50                   	push   %eax
c0106927:	e8 08 9a ff ff       	call   c0100334 <cprintf>
c010692c:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c010692f:	8b 83 34 11 00 00    	mov    0x1134(%ebx),%eax
c0106935:	8b 40 10             	mov    0x10(%eax),%eax
c0106938:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010693b:	6a 00                	push   $0x0
c010693d:	52                   	push   %edx
c010693e:	ff 75 ec             	pushl  -0x14(%ebp)
c0106941:	ff 75 08             	pushl  0x8(%ebp)
c0106944:	ff d0                	call   *%eax
c0106946:	83 c4 10             	add    $0x10,%esp
c0106949:	eb 5e                	jmp    c01069a9 <swap_out+0x156>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c010694b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010694e:	8b 40 20             	mov    0x20(%eax),%eax
c0106951:	c1 e8 0c             	shr    $0xc,%eax
c0106954:	83 c0 01             	add    $0x1,%eax
c0106957:	50                   	push   %eax
c0106958:	ff 75 ec             	pushl  -0x14(%ebp)
c010695b:	ff 75 f4             	pushl  -0xc(%ebp)
c010695e:	8d 83 1c 36 fe ff    	lea    -0x1c9e4(%ebx),%eax
c0106964:	50                   	push   %eax
c0106965:	e8 ca 99 ff ff       	call   c0100334 <cprintf>
c010696a:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010696d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106970:	8b 40 20             	mov    0x20(%eax),%eax
c0106973:	c1 e8 0c             	shr    $0xc,%eax
c0106976:	83 c0 01             	add    $0x1,%eax
c0106979:	c1 e0 08             	shl    $0x8,%eax
c010697c:	89 c2                	mov    %eax,%edx
c010697e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106981:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106986:	83 ec 08             	sub    $0x8,%esp
c0106989:	6a 01                	push   $0x1
c010698b:	50                   	push   %eax
c010698c:	e8 06 1f 00 00       	call   c0108897 <free_pages>
c0106991:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106994:	8b 45 08             	mov    0x8(%ebp),%eax
c0106997:	8b 40 0c             	mov    0xc(%eax),%eax
c010699a:	83 ec 08             	sub    $0x8,%esp
c010699d:	ff 75 ec             	pushl  -0x14(%ebp)
c01069a0:	50                   	push   %eax
c01069a1:	e8 4b 29 00 00       	call   c01092f1 <tlb_invalidate>
c01069a6:	83 c4 10             	add    $0x10,%esp
     for (i = 0; i != n; ++ i)
c01069a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01069ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01069b3:	0f 85 b8 fe ff ff    	jne    c0106871 <swap_out+0x1e>
     }
     return i;
c01069b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01069bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01069bf:	c9                   	leave  
c01069c0:	c3                   	ret    

c01069c1 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01069c1:	55                   	push   %ebp
c01069c2:	89 e5                	mov    %esp,%ebp
c01069c4:	53                   	push   %ebx
c01069c5:	83 ec 14             	sub    $0x14,%esp
c01069c8:	e8 f4 98 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01069cd:	81 c3 b3 2f 02 00    	add    $0x22fb3,%ebx
     struct Page *result = alloc_page();
c01069d3:	83 ec 0c             	sub    $0xc,%esp
c01069d6:	6a 01                	push   $0x1
c01069d8:	e8 36 1e 00 00       	call   c0108813 <alloc_pages>
c01069dd:	83 c4 10             	add    $0x10,%esp
c01069e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01069e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069e7:	75 1c                	jne    c0106a05 <swap_in+0x44>
c01069e9:	8d 83 5c 36 fe ff    	lea    -0x1c9a4(%ebx),%eax
c01069ef:	50                   	push   %eax
c01069f0:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c01069f6:	50                   	push   %eax
c01069f7:	6a 7b                	push   $0x7b
c01069f9:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c01069ff:	50                   	push   %eax
c0106a00:	e8 0d b0 ff ff       	call   c0101a12 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a08:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a0b:	83 ec 04             	sub    $0x4,%esp
c0106a0e:	6a 00                	push   $0x0
c0106a10:	ff 75 0c             	pushl  0xc(%ebp)
c0106a13:	50                   	push   %eax
c0106a14:	e8 cd 25 00 00       	call   c0108fe6 <get_pte>
c0106a19:	83 c4 10             	add    $0x10,%esp
c0106a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a22:	8b 00                	mov    (%eax),%eax
c0106a24:	83 ec 08             	sub    $0x8,%esp
c0106a27:	ff 75 f4             	pushl  -0xc(%ebp)
c0106a2a:	50                   	push   %eax
c0106a2b:	e8 26 37 00 00       	call   c010a156 <swapfs_read>
c0106a30:	83 c4 10             	add    $0x10,%esp
c0106a33:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106a36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106a3a:	74 25                	je     c0106a61 <swap_in+0xa0>
     {
        assert(r!=0);
c0106a3c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106a40:	75 1f                	jne    c0106a61 <swap_in+0xa0>
c0106a42:	8d 83 69 36 fe ff    	lea    -0x1c997(%ebx),%eax
c0106a48:	50                   	push   %eax
c0106a49:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106a4f:	50                   	push   %eax
c0106a50:	68 83 00 00 00       	push   $0x83
c0106a55:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106a5b:	50                   	push   %eax
c0106a5c:	e8 b1 af ff ff       	call   c0101a12 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a64:	8b 00                	mov    (%eax),%eax
c0106a66:	c1 e8 08             	shr    $0x8,%eax
c0106a69:	83 ec 04             	sub    $0x4,%esp
c0106a6c:	ff 75 0c             	pushl  0xc(%ebp)
c0106a6f:	50                   	push   %eax
c0106a70:	8d 83 70 36 fe ff    	lea    -0x1c990(%ebx),%eax
c0106a76:	50                   	push   %eax
c0106a77:	e8 b8 98 ff ff       	call   c0100334 <cprintf>
c0106a7c:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c0106a7f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106a85:	89 10                	mov    %edx,(%eax)
     return 0;
c0106a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106a8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0106a8f:	c9                   	leave  
c0106a90:	c3                   	ret    

c0106a91 <check_content_set>:



static inline void
check_content_set(void)
{
c0106a91:	55                   	push   %ebp
c0106a92:	89 e5                	mov    %esp,%ebp
c0106a94:	53                   	push   %ebx
c0106a95:	83 ec 04             	sub    $0x4,%esp
c0106a98:	e8 20 98 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106a9d:	05 e3 2e 02 00       	add    $0x22ee3,%eax
     *(unsigned char *)0x1000 = 0x0a;
c0106aa2:	ba 00 10 00 00       	mov    $0x1000,%edx
c0106aa7:	c6 02 0a             	movb   $0xa,(%edx)
     assert(pgfault_num==1);
c0106aaa:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106ab0:	8b 12                	mov    (%edx),%edx
c0106ab2:	83 fa 01             	cmp    $0x1,%edx
c0106ab5:	74 21                	je     c0106ad8 <check_content_set+0x47>
c0106ab7:	8d 90 ae 36 fe ff    	lea    -0x1c952(%eax),%edx
c0106abd:	52                   	push   %edx
c0106abe:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106ac4:	52                   	push   %edx
c0106ac5:	68 90 00 00 00       	push   $0x90
c0106aca:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106ad0:	52                   	push   %edx
c0106ad1:	89 c3                	mov    %eax,%ebx
c0106ad3:	e8 3a af ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106ad8:	ba 10 10 00 00       	mov    $0x1010,%edx
c0106add:	c6 02 0a             	movb   $0xa,(%edx)
     assert(pgfault_num==1);
c0106ae0:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106ae6:	8b 12                	mov    (%edx),%edx
c0106ae8:	83 fa 01             	cmp    $0x1,%edx
c0106aeb:	74 21                	je     c0106b0e <check_content_set+0x7d>
c0106aed:	8d 90 ae 36 fe ff    	lea    -0x1c952(%eax),%edx
c0106af3:	52                   	push   %edx
c0106af4:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106afa:	52                   	push   %edx
c0106afb:	68 92 00 00 00       	push   $0x92
c0106b00:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106b06:	52                   	push   %edx
c0106b07:	89 c3                	mov    %eax,%ebx
c0106b09:	e8 04 af ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106b0e:	ba 00 20 00 00       	mov    $0x2000,%edx
c0106b13:	c6 02 0b             	movb   $0xb,(%edx)
     assert(pgfault_num==2);
c0106b16:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106b1c:	8b 12                	mov    (%edx),%edx
c0106b1e:	83 fa 02             	cmp    $0x2,%edx
c0106b21:	74 21                	je     c0106b44 <check_content_set+0xb3>
c0106b23:	8d 90 bd 36 fe ff    	lea    -0x1c943(%eax),%edx
c0106b29:	52                   	push   %edx
c0106b2a:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106b30:	52                   	push   %edx
c0106b31:	68 94 00 00 00       	push   $0x94
c0106b36:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106b3c:	52                   	push   %edx
c0106b3d:	89 c3                	mov    %eax,%ebx
c0106b3f:	e8 ce ae ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106b44:	ba 10 20 00 00       	mov    $0x2010,%edx
c0106b49:	c6 02 0b             	movb   $0xb,(%edx)
     assert(pgfault_num==2);
c0106b4c:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106b52:	8b 12                	mov    (%edx),%edx
c0106b54:	83 fa 02             	cmp    $0x2,%edx
c0106b57:	74 21                	je     c0106b7a <check_content_set+0xe9>
c0106b59:	8d 90 bd 36 fe ff    	lea    -0x1c943(%eax),%edx
c0106b5f:	52                   	push   %edx
c0106b60:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106b66:	52                   	push   %edx
c0106b67:	68 96 00 00 00       	push   $0x96
c0106b6c:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106b72:	52                   	push   %edx
c0106b73:	89 c3                	mov    %eax,%ebx
c0106b75:	e8 98 ae ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106b7a:	ba 00 30 00 00       	mov    $0x3000,%edx
c0106b7f:	c6 02 0c             	movb   $0xc,(%edx)
     assert(pgfault_num==3);
c0106b82:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106b88:	8b 12                	mov    (%edx),%edx
c0106b8a:	83 fa 03             	cmp    $0x3,%edx
c0106b8d:	74 21                	je     c0106bb0 <check_content_set+0x11f>
c0106b8f:	8d 90 cc 36 fe ff    	lea    -0x1c934(%eax),%edx
c0106b95:	52                   	push   %edx
c0106b96:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106b9c:	52                   	push   %edx
c0106b9d:	68 98 00 00 00       	push   $0x98
c0106ba2:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106ba8:	52                   	push   %edx
c0106ba9:	89 c3                	mov    %eax,%ebx
c0106bab:	e8 62 ae ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106bb0:	ba 10 30 00 00       	mov    $0x3010,%edx
c0106bb5:	c6 02 0c             	movb   $0xc,(%edx)
     assert(pgfault_num==3);
c0106bb8:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106bbe:	8b 12                	mov    (%edx),%edx
c0106bc0:	83 fa 03             	cmp    $0x3,%edx
c0106bc3:	74 21                	je     c0106be6 <check_content_set+0x155>
c0106bc5:	8d 90 cc 36 fe ff    	lea    -0x1c934(%eax),%edx
c0106bcb:	52                   	push   %edx
c0106bcc:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106bd2:	52                   	push   %edx
c0106bd3:	68 9a 00 00 00       	push   $0x9a
c0106bd8:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106bde:	52                   	push   %edx
c0106bdf:	89 c3                	mov    %eax,%ebx
c0106be1:	e8 2c ae ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106be6:	ba 00 40 00 00       	mov    $0x4000,%edx
c0106beb:	c6 02 0d             	movb   $0xd,(%edx)
     assert(pgfault_num==4);
c0106bee:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106bf4:	8b 12                	mov    (%edx),%edx
c0106bf6:	83 fa 04             	cmp    $0x4,%edx
c0106bf9:	74 21                	je     c0106c1c <check_content_set+0x18b>
c0106bfb:	8d 90 db 36 fe ff    	lea    -0x1c925(%eax),%edx
c0106c01:	52                   	push   %edx
c0106c02:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106c08:	52                   	push   %edx
c0106c09:	68 9c 00 00 00       	push   $0x9c
c0106c0e:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106c14:	52                   	push   %edx
c0106c15:	89 c3                	mov    %eax,%ebx
c0106c17:	e8 f6 ad ff ff       	call   c0101a12 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106c1c:	ba 10 40 00 00       	mov    $0x4010,%edx
c0106c21:	c6 02 0d             	movb   $0xd,(%edx)
     assert(pgfault_num==4);
c0106c24:	c7 c2 a4 aa 12 c0    	mov    $0xc012aaa4,%edx
c0106c2a:	8b 12                	mov    (%edx),%edx
c0106c2c:	83 fa 04             	cmp    $0x4,%edx
c0106c2f:	74 21                	je     c0106c52 <check_content_set+0x1c1>
c0106c31:	8d 90 db 36 fe ff    	lea    -0x1c925(%eax),%edx
c0106c37:	52                   	push   %edx
c0106c38:	8d 90 ee 35 fe ff    	lea    -0x1ca12(%eax),%edx
c0106c3e:	52                   	push   %edx
c0106c3f:	68 9e 00 00 00       	push   $0x9e
c0106c44:	8d 90 88 35 fe ff    	lea    -0x1ca78(%eax),%edx
c0106c4a:	52                   	push   %edx
c0106c4b:	89 c3                	mov    %eax,%ebx
c0106c4d:	e8 c0 ad ff ff       	call   c0101a12 <__panic>
}
c0106c52:	90                   	nop
c0106c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0106c56:	c9                   	leave  
c0106c57:	c3                   	ret    

c0106c58 <check_content_access>:

static inline int
check_content_access(void)
{
c0106c58:	55                   	push   %ebp
c0106c59:	89 e5                	mov    %esp,%ebp
c0106c5b:	83 ec 18             	sub    $0x18,%esp
c0106c5e:	e8 5a 96 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0106c63:	05 1d 2d 02 00       	add    $0x22d1d,%eax
    int ret = sm->check_swap();
c0106c68:	8b 80 34 11 00 00    	mov    0x1134(%eax),%eax
c0106c6e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106c71:	ff d0                	call   *%eax
c0106c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106c79:	c9                   	leave  
c0106c7a:	c3                   	ret    

c0106c7b <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106c7b:	55                   	push   %ebp
c0106c7c:	89 e5                	mov    %esp,%ebp
c0106c7e:	53                   	push   %ebx
c0106c7f:	83 ec 64             	sub    $0x64,%esp
c0106c82:	e8 3a 96 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0106c87:	81 c3 f9 2c 02 00    	add    $0x22cf9,%ebx
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106c8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106c94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106c9b:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106ca1:	89 45 e8             	mov    %eax,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106ca4:	eb 66                	jmp    c0106d0c <check_swap+0x91>
        struct Page *p = le2page(le, page_link);
c0106ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ca9:	83 e8 10             	sub    $0x10,%eax
c0106cac:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106caf:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106cb2:	83 c0 04             	add    $0x4,%eax
c0106cb5:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106cbc:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106cbf:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106cc2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106cc5:	0f a3 10             	bt     %edx,(%eax)
c0106cc8:	19 c0                	sbb    %eax,%eax
c0106cca:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106ccd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106cd1:	0f 95 c0             	setne  %al
c0106cd4:	0f b6 c0             	movzbl %al,%eax
c0106cd7:	85 c0                	test   %eax,%eax
c0106cd9:	75 1f                	jne    c0106cfa <check_swap+0x7f>
c0106cdb:	8d 83 ea 36 fe ff    	lea    -0x1c916(%ebx),%eax
c0106ce1:	50                   	push   %eax
c0106ce2:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106ce8:	50                   	push   %eax
c0106ce9:	68 b9 00 00 00       	push   $0xb9
c0106cee:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106cf4:	50                   	push   %eax
c0106cf5:	e8 18 ad ff ff       	call   c0101a12 <__panic>
        count ++, total += p->property;
c0106cfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106cfe:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106d01:	8b 50 08             	mov    0x8(%eax),%edx
c0106d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d07:	01 d0                	add    %edx,%eax
c0106d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d0f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c0106d12:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106d15:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106d18:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106d1b:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106d21:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106d24:	75 80                	jne    c0106ca6 <check_swap+0x2b>
     }
     assert(total == nr_free_pages());
c0106d26:	e8 b3 1b 00 00       	call   c01088de <nr_free_pages>
c0106d2b:	89 c2                	mov    %eax,%edx
c0106d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d30:	39 c2                	cmp    %eax,%edx
c0106d32:	74 1f                	je     c0106d53 <check_swap+0xd8>
c0106d34:	8d 83 fa 36 fe ff    	lea    -0x1c906(%ebx),%eax
c0106d3a:	50                   	push   %eax
c0106d3b:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106d41:	50                   	push   %eax
c0106d42:	68 bc 00 00 00       	push   $0xbc
c0106d47:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106d4d:	50                   	push   %eax
c0106d4e:	e8 bf ac ff ff       	call   c0101a12 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106d53:	83 ec 04             	sub    $0x4,%esp
c0106d56:	ff 75 f0             	pushl  -0x10(%ebp)
c0106d59:	ff 75 f4             	pushl  -0xc(%ebp)
c0106d5c:	8d 83 14 37 fe ff    	lea    -0x1c8ec(%ebx),%eax
c0106d62:	50                   	push   %eax
c0106d63:	e8 cc 95 ff ff       	call   c0100334 <cprintf>
c0106d68:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106d6b:	e8 3c de ff ff       	call   c0104bac <mm_create>
c0106d70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106d73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106d77:	75 1f                	jne    c0106d98 <check_swap+0x11d>
c0106d79:	8d 83 3a 37 fe ff    	lea    -0x1c8c6(%ebx),%eax
c0106d7f:	50                   	push   %eax
c0106d80:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106d86:	50                   	push   %eax
c0106d87:	68 c1 00 00 00       	push   $0xc1
c0106d8c:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106d92:	50                   	push   %eax
c0106d93:	e8 7a ac ff ff       	call   c0101a12 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106d98:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c0106d9e:	8b 00                	mov    (%eax),%eax
c0106da0:	85 c0                	test   %eax,%eax
c0106da2:	74 1f                	je     c0106dc3 <check_swap+0x148>
c0106da4:	8d 83 45 37 fe ff    	lea    -0x1c8bb(%ebx),%eax
c0106daa:	50                   	push   %eax
c0106dab:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106db1:	50                   	push   %eax
c0106db2:	68 c4 00 00 00       	push   $0xc4
c0106db7:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106dbd:	50                   	push   %eax
c0106dbe:	e8 4f ac ff ff       	call   c0101a12 <__panic>

     check_mm_struct = mm;
c0106dc3:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c0106dc9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106dcc:	89 10                	mov    %edx,(%eax)

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106dce:	c7 c0 c4 aa 12 c0    	mov    $0xc012aac4,%eax
c0106dd4:	8b 10                	mov    (%eax),%edx
c0106dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106dd9:	89 50 0c             	mov    %edx,0xc(%eax)
c0106ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ddf:	8b 40 0c             	mov    0xc(%eax),%eax
c0106de2:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106de5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106de8:	8b 00                	mov    (%eax),%eax
c0106dea:	85 c0                	test   %eax,%eax
c0106dec:	74 1f                	je     c0106e0d <check_swap+0x192>
c0106dee:	8d 83 5d 37 fe ff    	lea    -0x1c8a3(%ebx),%eax
c0106df4:	50                   	push   %eax
c0106df5:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106dfb:	50                   	push   %eax
c0106dfc:	68 c9 00 00 00       	push   $0xc9
c0106e01:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106e07:	50                   	push   %eax
c0106e08:	e8 05 ac ff ff       	call   c0101a12 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106e0d:	83 ec 04             	sub    $0x4,%esp
c0106e10:	6a 03                	push   $0x3
c0106e12:	68 00 60 00 00       	push   $0x6000
c0106e17:	68 00 10 00 00       	push   $0x1000
c0106e1c:	e8 19 de ff ff       	call   c0104c3a <vma_create>
c0106e21:	83 c4 10             	add    $0x10,%esp
c0106e24:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106e27:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106e2b:	75 1f                	jne    c0106e4c <check_swap+0x1d1>
c0106e2d:	8d 83 6b 37 fe ff    	lea    -0x1c895(%ebx),%eax
c0106e33:	50                   	push   %eax
c0106e34:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106e3a:	50                   	push   %eax
c0106e3b:	68 cc 00 00 00       	push   $0xcc
c0106e40:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106e46:	50                   	push   %eax
c0106e47:	e8 c6 ab ff ff       	call   c0101a12 <__panic>

     insert_vma_struct(mm, vma);
c0106e4c:	83 ec 08             	sub    $0x8,%esp
c0106e4f:	ff 75 dc             	pushl  -0x24(%ebp)
c0106e52:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106e55:	e8 88 df ff ff       	call   c0104de2 <insert_vma_struct>
c0106e5a:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106e5d:	83 ec 0c             	sub    $0xc,%esp
c0106e60:	8d 83 78 37 fe ff    	lea    -0x1c888(%ebx),%eax
c0106e66:	50                   	push   %eax
c0106e67:	e8 c8 94 ff ff       	call   c0100334 <cprintf>
c0106e6c:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c0106e6f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e79:	8b 40 0c             	mov    0xc(%eax),%eax
c0106e7c:	83 ec 04             	sub    $0x4,%esp
c0106e7f:	6a 01                	push   $0x1
c0106e81:	68 00 10 00 00       	push   $0x1000
c0106e86:	50                   	push   %eax
c0106e87:	e8 5a 21 00 00       	call   c0108fe6 <get_pte>
c0106e8c:	83 c4 10             	add    $0x10,%esp
c0106e8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106e92:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106e96:	75 1f                	jne    c0106eb7 <check_swap+0x23c>
c0106e98:	8d 83 ac 37 fe ff    	lea    -0x1c854(%ebx),%eax
c0106e9e:	50                   	push   %eax
c0106e9f:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106ea5:	50                   	push   %eax
c0106ea6:	68 d4 00 00 00       	push   $0xd4
c0106eab:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106eb1:	50                   	push   %eax
c0106eb2:	e8 5b ab ff ff       	call   c0101a12 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106eb7:	83 ec 0c             	sub    $0xc,%esp
c0106eba:	8d 83 c0 37 fe ff    	lea    -0x1c840(%ebx),%eax
c0106ec0:	50                   	push   %eax
c0106ec1:	e8 6e 94 ff ff       	call   c0100334 <cprintf>
c0106ec6:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ec9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ed0:	e9 a2 00 00 00       	jmp    c0106f77 <check_swap+0x2fc>
          check_rp[i] = alloc_page();
c0106ed5:	83 ec 0c             	sub    $0xc,%esp
c0106ed8:	6a 01                	push   $0x1
c0106eda:	e8 34 19 00 00       	call   c0108813 <alloc_pages>
c0106edf:	83 c4 10             	add    $0x10,%esp
c0106ee2:	89 c1                	mov    %eax,%ecx
c0106ee4:	c7 c0 c0 cb 12 c0    	mov    $0xc012cbc0,%eax
c0106eea:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106eed:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
          assert(check_rp[i] != NULL );
c0106ef0:	c7 c0 c0 cb 12 c0    	mov    $0xc012cbc0,%eax
c0106ef6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ef9:	8b 04 90             	mov    (%eax,%edx,4),%eax
c0106efc:	85 c0                	test   %eax,%eax
c0106efe:	75 1f                	jne    c0106f1f <check_swap+0x2a4>
c0106f00:	8d 83 e4 37 fe ff    	lea    -0x1c81c(%ebx),%eax
c0106f06:	50                   	push   %eax
c0106f07:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106f0d:	50                   	push   %eax
c0106f0e:	68 d9 00 00 00       	push   $0xd9
c0106f13:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106f19:	50                   	push   %eax
c0106f1a:	e8 f3 aa ff ff       	call   c0101a12 <__panic>
          assert(!PageProperty(check_rp[i]));
c0106f1f:	c7 c0 c0 cb 12 c0    	mov    $0xc012cbc0,%eax
c0106f25:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f28:	8b 04 90             	mov    (%eax,%edx,4),%eax
c0106f2b:	83 c0 04             	add    $0x4,%eax
c0106f2e:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106f35:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106f38:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106f3b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106f3e:	0f a3 10             	bt     %edx,(%eax)
c0106f41:	19 c0                	sbb    %eax,%eax
c0106f43:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106f46:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106f4a:	0f 95 c0             	setne  %al
c0106f4d:	0f b6 c0             	movzbl %al,%eax
c0106f50:	85 c0                	test   %eax,%eax
c0106f52:	74 1f                	je     c0106f73 <check_swap+0x2f8>
c0106f54:	8d 83 f8 37 fe ff    	lea    -0x1c808(%ebx),%eax
c0106f5a:	50                   	push   %eax
c0106f5b:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106f61:	50                   	push   %eax
c0106f62:	68 da 00 00 00       	push   $0xda
c0106f67:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106f6d:	50                   	push   %eax
c0106f6e:	e8 9f aa ff ff       	call   c0101a12 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106f73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106f77:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106f7b:	0f 8e 54 ff ff ff    	jle    c0106ed5 <check_swap+0x25a>
     }
     list_entry_t free_list_store = free_list;
c0106f81:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106f87:	8b 50 04             	mov    0x4(%eax),%edx
c0106f8a:	8b 00                	mov    (%eax),%eax
c0106f8c:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106f8f:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106f92:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106f98:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106f9b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106f9e:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106fa1:	89 50 04             	mov    %edx,0x4(%eax)
c0106fa4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106fa7:	8b 50 04             	mov    0x4(%eax),%edx
c0106faa:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106fad:	89 10                	mov    %edx,(%eax)
c0106faf:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106fb5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return list->next == list;
c0106fb8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106fbb:	8b 40 04             	mov    0x4(%eax),%eax
c0106fbe:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106fc1:	0f 94 c0             	sete   %al
c0106fc4:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106fc7:	85 c0                	test   %eax,%eax
c0106fc9:	75 1f                	jne    c0106fea <check_swap+0x36f>
c0106fcb:	8d 83 13 38 fe ff    	lea    -0x1c7ed(%ebx),%eax
c0106fd1:	50                   	push   %eax
c0106fd2:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0106fd8:	50                   	push   %eax
c0106fd9:	68 de 00 00 00       	push   $0xde
c0106fde:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0106fe4:	50                   	push   %eax
c0106fe5:	e8 28 aa ff ff       	call   c0101a12 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106fea:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106ff0:	8b 40 08             	mov    0x8(%eax),%eax
c0106ff3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106ff6:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0106ffc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107003:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010700a:	eb 1e                	jmp    c010702a <check_swap+0x3af>
        free_pages(check_rp[i],1);
c010700c:	c7 c0 c0 cb 12 c0    	mov    $0xc012cbc0,%eax
c0107012:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107015:	8b 04 90             	mov    (%eax,%edx,4),%eax
c0107018:	83 ec 08             	sub    $0x8,%esp
c010701b:	6a 01                	push   $0x1
c010701d:	50                   	push   %eax
c010701e:	e8 74 18 00 00       	call   c0108897 <free_pages>
c0107023:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107026:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010702a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010702e:	7e dc                	jle    c010700c <check_swap+0x391>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107030:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107036:	8b 40 08             	mov    0x8(%eax),%eax
c0107039:	83 f8 04             	cmp    $0x4,%eax
c010703c:	74 1f                	je     c010705d <check_swap+0x3e2>
c010703e:	8d 83 2c 38 fe ff    	lea    -0x1c7d4(%ebx),%eax
c0107044:	50                   	push   %eax
c0107045:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c010704b:	50                   	push   %eax
c010704c:	68 e7 00 00 00       	push   $0xe7
c0107051:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0107057:	50                   	push   %eax
c0107058:	e8 b5 a9 ff ff       	call   c0101a12 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010705d:	83 ec 0c             	sub    $0xc,%esp
c0107060:	8d 83 50 38 fe ff    	lea    -0x1c7b0(%ebx),%eax
c0107066:	50                   	push   %eax
c0107067:	e8 c8 92 ff ff       	call   c0100334 <cprintf>
c010706c:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010706f:	c7 c0 a4 aa 12 c0    	mov    $0xc012aaa4,%eax
c0107075:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     
     check_content_set();
c010707b:	e8 11 fa ff ff       	call   c0106a91 <check_content_set>
     assert( nr_free == 0);         
c0107080:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107086:	8b 40 08             	mov    0x8(%eax),%eax
c0107089:	85 c0                	test   %eax,%eax
c010708b:	74 1f                	je     c01070ac <check_swap+0x431>
c010708d:	8d 83 77 38 fe ff    	lea    -0x1c789(%ebx),%eax
c0107093:	50                   	push   %eax
c0107094:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c010709a:	50                   	push   %eax
c010709b:	68 f0 00 00 00       	push   $0xf0
c01070a0:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c01070a6:	50                   	push   %eax
c01070a7:	e8 66 a9 ff ff       	call   c0101a12 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01070ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01070b3:	eb 2c                	jmp    c01070e1 <check_swap+0x466>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01070b5:	c7 c0 e0 cb 12 c0    	mov    $0xc012cbe0,%eax
c01070bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070be:	c7 04 90 ff ff ff ff 	movl   $0xffffffff,(%eax,%edx,4)
c01070c5:	c7 c0 e0 cb 12 c0    	mov    $0xc012cbe0,%eax
c01070cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070ce:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
c01070d1:	c7 c0 20 cc 12 c0    	mov    $0xc012cc20,%eax
c01070d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070da:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01070dd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01070e1:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01070e5:	7e ce                	jle    c01070b5 <check_swap+0x43a>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01070e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01070ee:	e9 ea 00 00 00       	jmp    c01071dd <check_swap+0x562>
         check_ptep[i]=0;
c01070f3:	c7 c0 74 cc 12 c0    	mov    $0xc012cc74,%eax
c01070f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070fc:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107103:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107106:	83 c0 01             	add    $0x1,%eax
c0107109:	c1 e0 0c             	shl    $0xc,%eax
c010710c:	83 ec 04             	sub    $0x4,%esp
c010710f:	6a 00                	push   $0x0
c0107111:	50                   	push   %eax
c0107112:	ff 75 e0             	pushl  -0x20(%ebp)
c0107115:	e8 cc 1e 00 00       	call   c0108fe6 <get_pte>
c010711a:	83 c4 10             	add    $0x10,%esp
c010711d:	89 c1                	mov    %eax,%ecx
c010711f:	c7 c0 74 cc 12 c0    	mov    $0xc012cc74,%eax
c0107125:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107128:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010712b:	c7 c0 74 cc 12 c0    	mov    $0xc012cc74,%eax
c0107131:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107134:	8b 04 90             	mov    (%eax,%edx,4),%eax
c0107137:	85 c0                	test   %eax,%eax
c0107139:	75 1f                	jne    c010715a <check_swap+0x4df>
c010713b:	8d 83 84 38 fe ff    	lea    -0x1c77c(%ebx),%eax
c0107141:	50                   	push   %eax
c0107142:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0107148:	50                   	push   %eax
c0107149:	68 f8 00 00 00       	push   $0xf8
c010714e:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0107154:	50                   	push   %eax
c0107155:	e8 b8 a8 ff ff       	call   c0101a12 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010715a:	c7 c0 74 cc 12 c0    	mov    $0xc012cc74,%eax
c0107160:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107163:	8b 04 90             	mov    (%eax,%edx,4),%eax
c0107166:	8b 00                	mov    (%eax),%eax
c0107168:	83 ec 0c             	sub    $0xc,%esp
c010716b:	50                   	push   %eax
c010716c:	e8 4e f5 ff ff       	call   c01066bf <pte2page>
c0107171:	83 c4 10             	add    $0x10,%esp
c0107174:	89 c1                	mov    %eax,%ecx
c0107176:	c7 c0 c0 cb 12 c0    	mov    $0xc012cbc0,%eax
c010717c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010717f:	8b 04 90             	mov    (%eax,%edx,4),%eax
c0107182:	39 c1                	cmp    %eax,%ecx
c0107184:	74 1f                	je     c01071a5 <check_swap+0x52a>
c0107186:	8d 83 9c 38 fe ff    	lea    -0x1c764(%ebx),%eax
c010718c:	50                   	push   %eax
c010718d:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0107193:	50                   	push   %eax
c0107194:	68 f9 00 00 00       	push   $0xf9
c0107199:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c010719f:	50                   	push   %eax
c01071a0:	e8 6d a8 ff ff       	call   c0101a12 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01071a5:	c7 c0 74 cc 12 c0    	mov    $0xc012cc74,%eax
c01071ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01071ae:	8b 04 90             	mov    (%eax,%edx,4),%eax
c01071b1:	8b 00                	mov    (%eax),%eax
c01071b3:	83 e0 01             	and    $0x1,%eax
c01071b6:	85 c0                	test   %eax,%eax
c01071b8:	75 1f                	jne    c01071d9 <check_swap+0x55e>
c01071ba:	8d 83 c4 38 fe ff    	lea    -0x1c73c(%ebx),%eax
c01071c0:	50                   	push   %eax
c01071c1:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c01071c7:	50                   	push   %eax
c01071c8:	68 fa 00 00 00       	push   $0xfa
c01071cd:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c01071d3:	50                   	push   %eax
c01071d4:	e8 39 a8 ff ff       	call   c0101a12 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01071d9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01071dd:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01071e1:	0f 8e 0c ff ff ff    	jle    c01070f3 <check_swap+0x478>
     }
     cprintf("set up init env for check_swap over!\n");
c01071e7:	83 ec 0c             	sub    $0xc,%esp
c01071ea:	8d 83 e0 38 fe ff    	lea    -0x1c720(%ebx),%eax
c01071f0:	50                   	push   %eax
c01071f1:	e8 3e 91 ff ff       	call   c0100334 <cprintf>
c01071f6:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01071f9:	e8 5a fa ff ff       	call   c0106c58 <check_content_access>
c01071fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0107201:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107205:	74 1f                	je     c0107226 <check_swap+0x5ab>
c0107207:	8d 83 06 39 fe ff    	lea    -0x1c6fa(%ebx),%eax
c010720d:	50                   	push   %eax
c010720e:	8d 83 ee 35 fe ff    	lea    -0x1ca12(%ebx),%eax
c0107214:	50                   	push   %eax
c0107215:	68 ff 00 00 00       	push   $0xff
c010721a:	8d 83 88 35 fe ff    	lea    -0x1ca78(%ebx),%eax
c0107220:	50                   	push   %eax
c0107221:	e8 ec a7 ff ff       	call   c0101a12 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107226:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010722d:	eb 1e                	jmp    c010724d <check_swap+0x5d2>
         free_pages(check_rp[i],1);
c010722f:	c7 c0 c0 cb 12 c0    	mov    $0xc012cbc0,%eax
c0107235:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107238:	8b 04 90             	mov    (%eax,%edx,4),%eax
c010723b:	83 ec 08             	sub    $0x8,%esp
c010723e:	6a 01                	push   $0x1
c0107240:	50                   	push   %eax
c0107241:	e8 51 16 00 00       	call   c0108897 <free_pages>
c0107246:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107249:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010724d:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107251:	7e dc                	jle    c010722f <check_swap+0x5b4>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0107253:	83 ec 0c             	sub    $0xc,%esp
c0107256:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107259:	e8 be dc ff ff       	call   c0104f1c <mm_destroy>
c010725e:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0107261:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107267:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010726a:	89 50 08             	mov    %edx,0x8(%eax)
     free_list = free_list_store;
c010726d:	c7 c1 84 cc 12 c0    	mov    $0xc012cc84,%ecx
c0107273:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107276:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107279:	89 01                	mov    %eax,(%ecx)
c010727b:	89 51 04             	mov    %edx,0x4(%ecx)

     
     le = &free_list;
c010727e:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107284:	89 45 e8             	mov    %eax,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107287:	eb 1d                	jmp    c01072a6 <check_swap+0x62b>
         struct Page *p = le2page(le, page_link);
c0107289:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010728c:	83 e8 10             	sub    $0x10,%eax
c010728f:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0107292:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107296:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107299:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010729c:	8b 40 08             	mov    0x8(%eax),%eax
c010729f:	29 c2                	sub    %eax,%edx
c01072a1:	89 d0                	mov    %edx,%eax
c01072a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01072a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01072a9:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c01072ac:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01072af:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01072b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01072b5:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01072bb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01072be:	75 c9                	jne    c0107289 <check_swap+0x60e>
     }
     cprintf("count is %d, total is %d\n",count,total);
c01072c0:	83 ec 04             	sub    $0x4,%esp
c01072c3:	ff 75 f0             	pushl  -0x10(%ebp)
c01072c6:	ff 75 f4             	pushl  -0xc(%ebp)
c01072c9:	8d 83 0d 39 fe ff    	lea    -0x1c6f3(%ebx),%eax
c01072cf:	50                   	push   %eax
c01072d0:	e8 5f 90 ff ff       	call   c0100334 <cprintf>
c01072d5:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01072d8:	83 ec 0c             	sub    $0xc,%esp
c01072db:	8d 83 27 39 fe ff    	lea    -0x1c6d9(%ebx),%eax
c01072e1:	50                   	push   %eax
c01072e2:	e8 4d 90 ff ff       	call   c0100334 <cprintf>
c01072e7:	83 c4 10             	add    $0x10,%esp
}
c01072ea:	90                   	nop
c01072eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01072ee:	c9                   	leave  
c01072ef:	c3                   	ret    

c01072f0 <page2ppn>:
page2ppn(struct Page *page) {
c01072f0:	55                   	push   %ebp
c01072f1:	89 e5                	mov    %esp,%ebp
c01072f3:	e8 c5 8f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01072f8:	05 88 26 02 00       	add    $0x22688,%eax
    return page - pages;
c01072fd:	8b 55 08             	mov    0x8(%ebp),%edx
c0107300:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0107306:	8b 00                	mov    (%eax),%eax
c0107308:	29 c2                	sub    %eax,%edx
c010730a:	89 d0                	mov    %edx,%eax
c010730c:	c1 f8 02             	sar    $0x2,%eax
c010730f:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0107315:	5d                   	pop    %ebp
c0107316:	c3                   	ret    

c0107317 <page2pa>:
page2pa(struct Page *page) {
c0107317:	55                   	push   %ebp
c0107318:	89 e5                	mov    %esp,%ebp
c010731a:	e8 9e 8f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010731f:	05 61 26 02 00       	add    $0x22661,%eax
    return page2ppn(page) << PGSHIFT;
c0107324:	ff 75 08             	pushl  0x8(%ebp)
c0107327:	e8 c4 ff ff ff       	call   c01072f0 <page2ppn>
c010732c:	83 c4 04             	add    $0x4,%esp
c010732f:	c1 e0 0c             	shl    $0xc,%eax
}
c0107332:	c9                   	leave  
c0107333:	c3                   	ret    

c0107334 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0107334:	55                   	push   %ebp
c0107335:	89 e5                	mov    %esp,%ebp
c0107337:	e8 81 8f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010733c:	05 44 26 02 00       	add    $0x22644,%eax
    return page->ref;
c0107341:	8b 45 08             	mov    0x8(%ebp),%eax
c0107344:	8b 00                	mov    (%eax),%eax
}
c0107346:	5d                   	pop    %ebp
c0107347:	c3                   	ret    

c0107348 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0107348:	55                   	push   %ebp
c0107349:	89 e5                	mov    %esp,%ebp
c010734b:	e8 6d 8f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0107350:	05 30 26 02 00       	add    $0x22630,%eax
    page->ref = val;
c0107355:	8b 45 08             	mov    0x8(%ebp),%eax
c0107358:	8b 55 0c             	mov    0xc(%ebp),%edx
c010735b:	89 10                	mov    %edx,(%eax)
}
c010735d:	90                   	nop
c010735e:	5d                   	pop    %ebp
c010735f:	c3                   	ret    

c0107360 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0107360:	55                   	push   %ebp
c0107361:	89 e5                	mov    %esp,%ebp
c0107363:	83 ec 10             	sub    $0x10,%esp
c0107366:	e8 52 8f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010736b:	05 15 26 02 00       	add    $0x22615,%eax
c0107370:	c7 c2 84 cc 12 c0    	mov    $0xc012cc84,%edx
c0107376:	89 55 fc             	mov    %edx,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107379:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010737c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
c010737f:	89 4a 04             	mov    %ecx,0x4(%edx)
c0107382:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107385:	8b 4a 04             	mov    0x4(%edx),%ecx
c0107388:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010738b:	89 0a                	mov    %ecx,(%edx)
    list_init(&free_list);
    nr_free = 0;
c010738d:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107393:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
c010739a:	90                   	nop
c010739b:	c9                   	leave  
c010739c:	c3                   	ret    

c010739d <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010739d:	55                   	push   %ebp
c010739e:	89 e5                	mov    %esp,%ebp
c01073a0:	53                   	push   %ebx
c01073a1:	83 ec 34             	sub    $0x34,%esp
c01073a4:	e8 18 8f ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01073a9:	81 c3 d7 25 02 00    	add    $0x225d7,%ebx
    assert(n > 0);
c01073af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01073b3:	75 1c                	jne    c01073d1 <default_init_memmap+0x34>
c01073b5:	8d 83 40 39 fe ff    	lea    -0x1c6c0(%ebx),%eax
c01073bb:	50                   	push   %eax
c01073bc:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01073c2:	50                   	push   %eax
c01073c3:	6a 46                	push   $0x46
c01073c5:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01073cb:	50                   	push   %eax
c01073cc:	e8 41 a6 ff ff       	call   c0101a12 <__panic>
    struct Page *p = base;
c01073d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01073d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01073d7:	e9 d3 00 00 00       	jmp    c01074af <default_init_memmap+0x112>
        assert(PageReserved(p));
c01073dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073df:	83 c0 04             	add    $0x4,%eax
c01073e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01073e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01073ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01073f2:	0f a3 10             	bt     %edx,(%eax)
c01073f5:	19 c0                	sbb    %eax,%eax
c01073f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01073fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01073fe:	0f 95 c0             	setne  %al
c0107401:	0f b6 c0             	movzbl %al,%eax
c0107404:	85 c0                	test   %eax,%eax
c0107406:	75 1c                	jne    c0107424 <default_init_memmap+0x87>
c0107408:	8d 83 71 39 fe ff    	lea    -0x1c68f(%ebx),%eax
c010740e:	50                   	push   %eax
c010740f:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107415:	50                   	push   %eax
c0107416:	6a 49                	push   $0x49
c0107418:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c010741e:	50                   	push   %eax
c010741f:	e8 ee a5 ff ff       	call   c0101a12 <__panic>
        p->flags = 0;
c0107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107427:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c010742e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107431:	83 c0 04             	add    $0x4,%eax
c0107434:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010743b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010743e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107441:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107444:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c0107447:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010744a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c0107451:	83 ec 08             	sub    $0x8,%esp
c0107454:	6a 00                	push   $0x0
c0107456:	ff 75 f4             	pushl  -0xc(%ebp)
c0107459:	e8 ea fe ff ff       	call   c0107348 <set_page_ref>
c010745e:	83 c4 10             	add    $0x10,%esp
        list_add_before(&free_list, &(p->page_link));
c0107461:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107464:	83 c0 10             	add    $0x10,%eax
c0107467:	c7 c2 84 cc 12 c0    	mov    $0xc012cc84,%edx
c010746d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107470:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0107473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107476:	8b 00                	mov    (%eax),%eax
c0107478:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010747b:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010747e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107484:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0107487:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010748a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010748d:	89 10                	mov    %edx,(%eax)
c010748f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107492:	8b 10                	mov    (%eax),%edx
c0107494:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107497:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010749a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010749d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01074a0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01074a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01074a9:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c01074ab:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c01074af:	8b 55 0c             	mov    0xc(%ebp),%edx
c01074b2:	89 d0                	mov    %edx,%eax
c01074b4:	c1 e0 03             	shl    $0x3,%eax
c01074b7:	01 d0                	add    %edx,%eax
c01074b9:	c1 e0 02             	shl    $0x2,%eax
c01074bc:	89 c2                	mov    %eax,%edx
c01074be:	8b 45 08             	mov    0x8(%ebp),%eax
c01074c1:	01 d0                	add    %edx,%eax
c01074c3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01074c6:	0f 85 10 ff ff ff    	jne    c01073dc <default_init_memmap+0x3f>
    }
    nr_free += n;
c01074cc:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01074d2:	8b 50 08             	mov    0x8(%eax),%edx
c01074d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074d8:	01 c2                	add    %eax,%edx
c01074da:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01074e0:	89 50 08             	mov    %edx,0x8(%eax)
    //first block
    base->property = n;
c01074e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01074e6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01074e9:	89 50 08             	mov    %edx,0x8(%eax)
}
c01074ec:	90                   	nop
c01074ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01074f0:	c9                   	leave  
c01074f1:	c3                   	ret    

c01074f2 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01074f2:	55                   	push   %ebp
c01074f3:	89 e5                	mov    %esp,%ebp
c01074f5:	53                   	push   %ebx
c01074f6:	83 ec 54             	sub    $0x54,%esp
c01074f9:	e8 bf 8d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01074fe:	05 82 24 02 00       	add    $0x22482,%eax
    assert(n > 0);
c0107503:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107507:	75 1e                	jne    c0107527 <default_alloc_pages+0x35>
c0107509:	8d 90 40 39 fe ff    	lea    -0x1c6c0(%eax),%edx
c010750f:	52                   	push   %edx
c0107510:	8d 90 46 39 fe ff    	lea    -0x1c6ba(%eax),%edx
c0107516:	52                   	push   %edx
c0107517:	6a 57                	push   $0x57
c0107519:	8d 90 5b 39 fe ff    	lea    -0x1c6a5(%eax),%edx
c010751f:	52                   	push   %edx
c0107520:	89 c3                	mov    %eax,%ebx
c0107522:	e8 eb a4 ff ff       	call   c0101a12 <__panic>
    if (n > nr_free) {
c0107527:	c7 c2 84 cc 12 c0    	mov    $0xc012cc84,%edx
c010752d:	8b 52 08             	mov    0x8(%edx),%edx
c0107530:	39 55 08             	cmp    %edx,0x8(%ebp)
c0107533:	76 0a                	jbe    c010753f <default_alloc_pages+0x4d>
        return NULL;
c0107535:	b8 00 00 00 00       	mov    $0x0,%eax
c010753a:	e9 43 01 00 00       	jmp    c0107682 <default_alloc_pages+0x190>
    }
    list_entry_t *le, *len;
    le = &free_list;
c010753f:	c7 c2 84 cc 12 c0    	mov    $0xc012cc84,%edx
c0107545:	89 55 f4             	mov    %edx,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
c0107548:	e9 12 01 00 00       	jmp    c010765f <default_alloc_pages+0x16d>
      struct Page *p = le2page(le, page_link);
c010754d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107550:	83 ea 10             	sub    $0x10,%edx
c0107553:	89 55 ec             	mov    %edx,-0x14(%ebp)
      if(p->property >= n){
c0107556:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107559:	8b 52 08             	mov    0x8(%edx),%edx
c010755c:	39 55 08             	cmp    %edx,0x8(%ebp)
c010755f:	0f 87 fa 00 00 00    	ja     c010765f <default_alloc_pages+0x16d>
        int i;
        for(i=0;i<n;i++){
c0107565:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010756c:	eb 7c                	jmp    c01075ea <default_alloc_pages+0xf8>
c010756e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107571:	89 55 c4             	mov    %edx,-0x3c(%ebp)
    return listelm->next;
c0107574:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107577:	8b 52 04             	mov    0x4(%edx),%edx
          len = list_next(le);
c010757a:	89 55 e8             	mov    %edx,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
c010757d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107580:	83 ea 10             	sub    $0x10,%edx
c0107583:	89 55 e4             	mov    %edx,-0x1c(%ebp)
          SetPageReserved(pp);
c0107586:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107589:	83 c2 04             	add    $0x4,%edx
c010758c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c0107593:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0107596:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010759c:	0f ab 0a             	bts    %ecx,(%edx)
          ClearPageProperty(pp);
c010759f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01075a2:	83 c2 04             	add    $0x4,%edx
c01075a5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01075ac:	89 55 d0             	mov    %edx,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01075af:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01075b2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01075b5:	0f b3 0a             	btr    %ecx,(%edx)
c01075b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01075bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c01075be:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01075c1:	8b 52 04             	mov    0x4(%edx),%edx
c01075c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01075c7:	8b 09                	mov    (%ecx),%ecx
c01075c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
c01075cc:	89 55 d8             	mov    %edx,-0x28(%ebp)
    prev->next = next;
c01075cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075d2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01075d5:	89 4a 04             	mov    %ecx,0x4(%edx)
    next->prev = prev;
c01075d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01075db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01075de:	89 0a                	mov    %ecx,(%edx)
          list_del(le);
          le = len;
c01075e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01075e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
        for(i=0;i<n;i++){
c01075e6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c01075ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01075ed:	39 55 08             	cmp    %edx,0x8(%ebp)
c01075f0:	0f 87 78 ff ff ff    	ja     c010756e <default_alloc_pages+0x7c>
        }
        if(p->property>n){
c01075f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01075f9:	8b 52 08             	mov    0x8(%edx),%edx
c01075fc:	39 55 08             	cmp    %edx,0x8(%ebp)
c01075ff:	73 12                	jae    c0107613 <default_alloc_pages+0x121>
          (le2page(le,page_link))->property = p->property - n;
c0107601:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107604:	8b 52 08             	mov    0x8(%edx),%edx
c0107607:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c010760a:	83 e9 10             	sub    $0x10,%ecx
c010760d:	2b 55 08             	sub    0x8(%ebp),%edx
c0107610:	89 51 08             	mov    %edx,0x8(%ecx)
        }
        ClearPageProperty(p);
c0107613:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107616:	83 c2 04             	add    $0x4,%edx
c0107619:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0107620:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0107623:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107626:	8b 4d b8             	mov    -0x48(%ebp),%ecx
c0107629:	0f b3 0a             	btr    %ecx,(%edx)
        SetPageReserved(p);
c010762c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010762f:	83 c2 04             	add    $0x4,%edx
c0107632:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c0107639:	89 55 bc             	mov    %edx,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010763c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010763f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0107642:	0f ab 0a             	bts    %ecx,(%edx)
        nr_free -= n;
c0107645:	c7 c2 84 cc 12 c0    	mov    $0xc012cc84,%edx
c010764b:	8b 52 08             	mov    0x8(%edx),%edx
c010764e:	2b 55 08             	sub    0x8(%ebp),%edx
c0107651:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107657:	89 50 08             	mov    %edx,0x8(%eax)
        return p;
c010765a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010765d:	eb 23                	jmp    c0107682 <default_alloc_pages+0x190>
c010765f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107662:	89 55 b0             	mov    %edx,-0x50(%ebp)
    return listelm->next;
c0107665:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0107668:	8b 52 04             	mov    0x4(%edx),%edx
    while((le=list_next(le)) != &free_list) {
c010766b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010766e:	c7 c2 84 cc 12 c0    	mov    $0xc012cc84,%edx
c0107674:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107677:	0f 85 d0 fe ff ff    	jne    c010754d <default_alloc_pages+0x5b>
      }
    }
    return NULL;
c010767d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0107685:	c9                   	leave  
c0107686:	c3                   	ret    

c0107687 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0107687:	55                   	push   %ebp
c0107688:	89 e5                	mov    %esp,%ebp
c010768a:	53                   	push   %ebx
c010768b:	83 ec 54             	sub    $0x54,%esp
c010768e:	e8 2e 8c ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0107693:	81 c3 ed 22 02 00    	add    $0x222ed,%ebx
    assert(n > 0);
c0107699:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010769d:	75 1c                	jne    c01076bb <default_free_pages+0x34>
c010769f:	8d 83 40 39 fe ff    	lea    -0x1c6c0(%ebx),%eax
c01076a5:	50                   	push   %eax
c01076a6:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01076ac:	50                   	push   %eax
c01076ad:	6a 78                	push   $0x78
c01076af:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01076b5:	50                   	push   %eax
c01076b6:	e8 57 a3 ff ff       	call   c0101a12 <__panic>
    assert(PageReserved(base));
c01076bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01076be:	83 c0 04             	add    $0x4,%eax
c01076c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01076c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01076cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01076d1:	0f a3 10             	bt     %edx,(%eax)
c01076d4:	19 c0                	sbb    %eax,%eax
c01076d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01076d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01076dd:	0f 95 c0             	setne  %al
c01076e0:	0f b6 c0             	movzbl %al,%eax
c01076e3:	85 c0                	test   %eax,%eax
c01076e5:	75 1c                	jne    c0107703 <default_free_pages+0x7c>
c01076e7:	8d 83 81 39 fe ff    	lea    -0x1c67f(%ebx),%eax
c01076ed:	50                   	push   %eax
c01076ee:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01076f4:	50                   	push   %eax
c01076f5:	6a 79                	push   $0x79
c01076f7:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01076fd:	50                   	push   %eax
c01076fe:	e8 0f a3 ff ff       	call   c0101a12 <__panic>

    list_entry_t *le = &free_list;
c0107703:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107709:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c010770c:	eb 11                	jmp    c010771f <default_free_pages+0x98>
      p = le2page(le, page_link);
c010770e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107711:	83 e8 10             	sub    $0x10,%eax
c0107714:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
c0107717:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010771a:	3b 45 08             	cmp    0x8(%ebp),%eax
c010771d:	77 1c                	ja     c010773b <default_free_pages+0xb4>
c010771f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107722:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107725:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107728:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c010772b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010772e:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107734:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107737:	75 d5                	jne    c010770e <default_free_pages+0x87>
c0107739:	eb 01                	jmp    c010773c <default_free_pages+0xb5>
        break;
c010773b:	90                   	nop
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c010773c:	8b 45 08             	mov    0x8(%ebp),%eax
c010773f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107742:	eb 4b                	jmp    c010778f <default_free_pages+0x108>
      list_add_before(le, &(p->page_link));
c0107744:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107747:	8d 50 10             	lea    0x10(%eax),%edx
c010774a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010774d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107750:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0107753:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107756:	8b 00                	mov    (%eax),%eax
c0107758:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010775b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010775e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107761:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107764:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c0107767:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010776a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010776d:	89 10                	mov    %edx,(%eax)
c010776f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107772:	8b 10                	mov    (%eax),%edx
c0107774:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107777:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010777a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010777d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107780:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107783:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107786:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107789:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
c010778b:	83 45 f0 24          	addl   $0x24,-0x10(%ebp)
c010778f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107792:	89 d0                	mov    %edx,%eax
c0107794:	c1 e0 03             	shl    $0x3,%eax
c0107797:	01 d0                	add    %edx,%eax
c0107799:	c1 e0 02             	shl    $0x2,%eax
c010779c:	89 c2                	mov    %eax,%edx
c010779e:	8b 45 08             	mov    0x8(%ebp),%eax
c01077a1:	01 d0                	add    %edx,%eax
c01077a3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01077a6:	72 9c                	jb     c0107744 <default_free_pages+0xbd>
    }
    base->flags = 0;
c01077a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01077ab:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c01077b2:	83 ec 08             	sub    $0x8,%esp
c01077b5:	6a 00                	push   $0x0
c01077b7:	ff 75 08             	pushl  0x8(%ebp)
c01077ba:	e8 89 fb ff ff       	call   c0107348 <set_page_ref>
c01077bf:	83 c4 10             	add    $0x10,%esp
    ClearPageProperty(base);
c01077c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01077c5:	83 c0 04             	add    $0x4,%eax
c01077c8:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01077cf:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01077d2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01077d5:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01077d8:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c01077db:	8b 45 08             	mov    0x8(%ebp),%eax
c01077de:	83 c0 04             	add    $0x4,%eax
c01077e1:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01077e8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01077eb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01077ee:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01077f1:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
c01077f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01077f7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01077fa:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
c01077fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107800:	83 e8 10             	sub    $0x10,%eax
c0107803:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
c0107806:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107809:	89 d0                	mov    %edx,%eax
c010780b:	c1 e0 03             	shl    $0x3,%eax
c010780e:	01 d0                	add    %edx,%eax
c0107810:	c1 e0 02             	shl    $0x2,%eax
c0107813:	89 c2                	mov    %eax,%edx
c0107815:	8b 45 08             	mov    0x8(%ebp),%eax
c0107818:	01 d0                	add    %edx,%eax
c010781a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010781d:	75 1e                	jne    c010783d <default_free_pages+0x1b6>
      base->property += p->property;
c010781f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107822:	8b 50 08             	mov    0x8(%eax),%edx
c0107825:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107828:	8b 40 08             	mov    0x8(%eax),%eax
c010782b:	01 c2                	add    %eax,%edx
c010782d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107830:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0107833:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107836:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
c010783d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107840:	83 c0 10             	add    $0x10,%eax
c0107843:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c0107846:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107849:	8b 00                	mov    (%eax),%eax
c010784b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c010784e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107851:	83 e8 10             	sub    $0x10,%eax
c0107854:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c0107857:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c010785d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107860:	74 59                	je     c01078bb <default_free_pages+0x234>
c0107862:	8b 45 08             	mov    0x8(%ebp),%eax
c0107865:	83 e8 24             	sub    $0x24,%eax
c0107868:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010786b:	75 4e                	jne    c01078bb <default_free_pages+0x234>
      while(le!=&free_list){
c010786d:	eb 41                	jmp    c01078b0 <default_free_pages+0x229>
        if(p->property){
c010786f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107872:	8b 40 08             	mov    0x8(%eax),%eax
c0107875:	85 c0                	test   %eax,%eax
c0107877:	74 20                	je     c0107899 <default_free_pages+0x212>
          p->property += base->property;
c0107879:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010787c:	8b 50 08             	mov    0x8(%eax),%edx
c010787f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107882:	8b 40 08             	mov    0x8(%eax),%eax
c0107885:	01 c2                	add    %eax,%edx
c0107887:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010788a:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c010788d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107890:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0107897:	eb 22                	jmp    c01078bb <default_free_pages+0x234>
c0107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010789c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010789f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01078a2:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c01078a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c01078a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078aa:	83 e8 10             	sub    $0x10,%eax
c01078ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c01078b0:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01078b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01078b9:	75 b4                	jne    c010786f <default_free_pages+0x1e8>
      }
    }

    nr_free += n;
c01078bb:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01078c1:	8b 50 08             	mov    0x8(%eax),%edx
c01078c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078c7:	01 c2                	add    %eax,%edx
c01078c9:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01078cf:	89 50 08             	mov    %edx,0x8(%eax)
    return ;
c01078d2:	90                   	nop
}
c01078d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01078d6:	c9                   	leave  
c01078d7:	c3                   	ret    

c01078d8 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01078d8:	55                   	push   %ebp
c01078d9:	89 e5                	mov    %esp,%ebp
c01078db:	e8 dd 89 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01078e0:	05 a0 20 02 00       	add    $0x220a0,%eax
    return nr_free;
c01078e5:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01078eb:	8b 40 08             	mov    0x8(%eax),%eax
}
c01078ee:	5d                   	pop    %ebp
c01078ef:	c3                   	ret    

c01078f0 <basic_check>:

static void
basic_check(void) {
c01078f0:	55                   	push   %ebp
c01078f1:	89 e5                	mov    %esp,%ebp
c01078f3:	53                   	push   %ebx
c01078f4:	83 ec 34             	sub    $0x34,%esp
c01078f7:	e8 c5 89 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01078fc:	81 c3 84 20 02 00    	add    $0x22084,%ebx
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0107902:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107909:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010790c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010790f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107912:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0107915:	83 ec 0c             	sub    $0xc,%esp
c0107918:	6a 01                	push   $0x1
c010791a:	e8 f4 0e 00 00       	call   c0108813 <alloc_pages>
c010791f:	83 c4 10             	add    $0x10,%esp
c0107922:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107925:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107929:	75 1f                	jne    c010794a <basic_check+0x5a>
c010792b:	8d 83 94 39 fe ff    	lea    -0x1c66c(%ebx),%eax
c0107931:	50                   	push   %eax
c0107932:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107938:	50                   	push   %eax
c0107939:	68 ad 00 00 00       	push   $0xad
c010793e:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107944:	50                   	push   %eax
c0107945:	e8 c8 a0 ff ff       	call   c0101a12 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010794a:	83 ec 0c             	sub    $0xc,%esp
c010794d:	6a 01                	push   $0x1
c010794f:	e8 bf 0e 00 00       	call   c0108813 <alloc_pages>
c0107954:	83 c4 10             	add    $0x10,%esp
c0107957:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010795a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010795e:	75 1f                	jne    c010797f <basic_check+0x8f>
c0107960:	8d 83 b0 39 fe ff    	lea    -0x1c650(%ebx),%eax
c0107966:	50                   	push   %eax
c0107967:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c010796d:	50                   	push   %eax
c010796e:	68 ae 00 00 00       	push   $0xae
c0107973:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107979:	50                   	push   %eax
c010797a:	e8 93 a0 ff ff       	call   c0101a12 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010797f:	83 ec 0c             	sub    $0xc,%esp
c0107982:	6a 01                	push   $0x1
c0107984:	e8 8a 0e 00 00       	call   c0108813 <alloc_pages>
c0107989:	83 c4 10             	add    $0x10,%esp
c010798c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010798f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107993:	75 1f                	jne    c01079b4 <basic_check+0xc4>
c0107995:	8d 83 cc 39 fe ff    	lea    -0x1c634(%ebx),%eax
c010799b:	50                   	push   %eax
c010799c:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01079a2:	50                   	push   %eax
c01079a3:	68 af 00 00 00       	push   $0xaf
c01079a8:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01079ae:	50                   	push   %eax
c01079af:	e8 5e a0 ff ff       	call   c0101a12 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01079b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079b7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01079ba:	74 10                	je     c01079cc <basic_check+0xdc>
c01079bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079bf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01079c2:	74 08                	je     c01079cc <basic_check+0xdc>
c01079c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079c7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01079ca:	75 1f                	jne    c01079eb <basic_check+0xfb>
c01079cc:	8d 83 e8 39 fe ff    	lea    -0x1c618(%ebx),%eax
c01079d2:	50                   	push   %eax
c01079d3:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01079d9:	50                   	push   %eax
c01079da:	68 b1 00 00 00       	push   $0xb1
c01079df:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01079e5:	50                   	push   %eax
c01079e6:	e8 27 a0 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01079eb:	83 ec 0c             	sub    $0xc,%esp
c01079ee:	ff 75 ec             	pushl  -0x14(%ebp)
c01079f1:	e8 3e f9 ff ff       	call   c0107334 <page_ref>
c01079f6:	83 c4 10             	add    $0x10,%esp
c01079f9:	85 c0                	test   %eax,%eax
c01079fb:	75 24                	jne    c0107a21 <basic_check+0x131>
c01079fd:	83 ec 0c             	sub    $0xc,%esp
c0107a00:	ff 75 f0             	pushl  -0x10(%ebp)
c0107a03:	e8 2c f9 ff ff       	call   c0107334 <page_ref>
c0107a08:	83 c4 10             	add    $0x10,%esp
c0107a0b:	85 c0                	test   %eax,%eax
c0107a0d:	75 12                	jne    c0107a21 <basic_check+0x131>
c0107a0f:	83 ec 0c             	sub    $0xc,%esp
c0107a12:	ff 75 f4             	pushl  -0xc(%ebp)
c0107a15:	e8 1a f9 ff ff       	call   c0107334 <page_ref>
c0107a1a:	83 c4 10             	add    $0x10,%esp
c0107a1d:	85 c0                	test   %eax,%eax
c0107a1f:	74 1f                	je     c0107a40 <basic_check+0x150>
c0107a21:	8d 83 0c 3a fe ff    	lea    -0x1c5f4(%ebx),%eax
c0107a27:	50                   	push   %eax
c0107a28:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107a2e:	50                   	push   %eax
c0107a2f:	68 b2 00 00 00       	push   $0xb2
c0107a34:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107a3a:	50                   	push   %eax
c0107a3b:	e8 d2 9f ff ff       	call   c0101a12 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0107a40:	83 ec 0c             	sub    $0xc,%esp
c0107a43:	ff 75 ec             	pushl  -0x14(%ebp)
c0107a46:	e8 cc f8 ff ff       	call   c0107317 <page2pa>
c0107a4b:	83 c4 10             	add    $0x10,%esp
c0107a4e:	89 c2                	mov    %eax,%edx
c0107a50:	c7 c0 c0 aa 12 c0    	mov    $0xc012aac0,%eax
c0107a56:	8b 00                	mov    (%eax),%eax
c0107a58:	c1 e0 0c             	shl    $0xc,%eax
c0107a5b:	39 c2                	cmp    %eax,%edx
c0107a5d:	72 1f                	jb     c0107a7e <basic_check+0x18e>
c0107a5f:	8d 83 48 3a fe ff    	lea    -0x1c5b8(%ebx),%eax
c0107a65:	50                   	push   %eax
c0107a66:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107a6c:	50                   	push   %eax
c0107a6d:	68 b4 00 00 00       	push   $0xb4
c0107a72:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107a78:	50                   	push   %eax
c0107a79:	e8 94 9f ff ff       	call   c0101a12 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0107a7e:	83 ec 0c             	sub    $0xc,%esp
c0107a81:	ff 75 f0             	pushl  -0x10(%ebp)
c0107a84:	e8 8e f8 ff ff       	call   c0107317 <page2pa>
c0107a89:	83 c4 10             	add    $0x10,%esp
c0107a8c:	89 c2                	mov    %eax,%edx
c0107a8e:	c7 c0 c0 aa 12 c0    	mov    $0xc012aac0,%eax
c0107a94:	8b 00                	mov    (%eax),%eax
c0107a96:	c1 e0 0c             	shl    $0xc,%eax
c0107a99:	39 c2                	cmp    %eax,%edx
c0107a9b:	72 1f                	jb     c0107abc <basic_check+0x1cc>
c0107a9d:	8d 83 65 3a fe ff    	lea    -0x1c59b(%ebx),%eax
c0107aa3:	50                   	push   %eax
c0107aa4:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107aaa:	50                   	push   %eax
c0107aab:	68 b5 00 00 00       	push   $0xb5
c0107ab0:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107ab6:	50                   	push   %eax
c0107ab7:	e8 56 9f ff ff       	call   c0101a12 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0107abc:	83 ec 0c             	sub    $0xc,%esp
c0107abf:	ff 75 f4             	pushl  -0xc(%ebp)
c0107ac2:	e8 50 f8 ff ff       	call   c0107317 <page2pa>
c0107ac7:	83 c4 10             	add    $0x10,%esp
c0107aca:	89 c2                	mov    %eax,%edx
c0107acc:	c7 c0 c0 aa 12 c0    	mov    $0xc012aac0,%eax
c0107ad2:	8b 00                	mov    (%eax),%eax
c0107ad4:	c1 e0 0c             	shl    $0xc,%eax
c0107ad7:	39 c2                	cmp    %eax,%edx
c0107ad9:	72 1f                	jb     c0107afa <basic_check+0x20a>
c0107adb:	8d 83 82 3a fe ff    	lea    -0x1c57e(%ebx),%eax
c0107ae1:	50                   	push   %eax
c0107ae2:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107ae8:	50                   	push   %eax
c0107ae9:	68 b6 00 00 00       	push   $0xb6
c0107aee:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107af4:	50                   	push   %eax
c0107af5:	e8 18 9f ff ff       	call   c0101a12 <__panic>

    list_entry_t free_list_store = free_list;
c0107afa:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107b00:	8b 50 04             	mov    0x4(%eax),%edx
c0107b03:	8b 00                	mov    (%eax),%eax
c0107b05:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107b08:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107b0b:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107b11:	89 45 dc             	mov    %eax,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0107b14:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b17:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107b1a:	89 50 04             	mov    %edx,0x4(%eax)
c0107b1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b20:	8b 50 04             	mov    0x4(%eax),%edx
c0107b23:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b26:	89 10                	mov    %edx,(%eax)
c0107b28:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107b2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return list->next == list;
c0107b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107b34:	8b 40 04             	mov    0x4(%eax),%eax
c0107b37:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107b3a:	0f 94 c0             	sete   %al
c0107b3d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107b40:	85 c0                	test   %eax,%eax
c0107b42:	75 1f                	jne    c0107b63 <basic_check+0x273>
c0107b44:	8d 83 9f 3a fe ff    	lea    -0x1c561(%ebx),%eax
c0107b4a:	50                   	push   %eax
c0107b4b:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107b51:	50                   	push   %eax
c0107b52:	68 ba 00 00 00       	push   $0xba
c0107b57:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107b5d:	50                   	push   %eax
c0107b5e:	e8 af 9e ff ff       	call   c0101a12 <__panic>

    unsigned int nr_free_store = nr_free;
c0107b63:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107b69:	8b 40 08             	mov    0x8(%eax),%eax
c0107b6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0107b6f:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107b75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

    assert(alloc_page() == NULL);
c0107b7c:	83 ec 0c             	sub    $0xc,%esp
c0107b7f:	6a 01                	push   $0x1
c0107b81:	e8 8d 0c 00 00       	call   c0108813 <alloc_pages>
c0107b86:	83 c4 10             	add    $0x10,%esp
c0107b89:	85 c0                	test   %eax,%eax
c0107b8b:	74 1f                	je     c0107bac <basic_check+0x2bc>
c0107b8d:	8d 83 b6 3a fe ff    	lea    -0x1c54a(%ebx),%eax
c0107b93:	50                   	push   %eax
c0107b94:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107b9a:	50                   	push   %eax
c0107b9b:	68 bf 00 00 00       	push   $0xbf
c0107ba0:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107ba6:	50                   	push   %eax
c0107ba7:	e8 66 9e ff ff       	call   c0101a12 <__panic>

    free_page(p0);
c0107bac:	83 ec 08             	sub    $0x8,%esp
c0107baf:	6a 01                	push   $0x1
c0107bb1:	ff 75 ec             	pushl  -0x14(%ebp)
c0107bb4:	e8 de 0c 00 00       	call   c0108897 <free_pages>
c0107bb9:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0107bbc:	83 ec 08             	sub    $0x8,%esp
c0107bbf:	6a 01                	push   $0x1
c0107bc1:	ff 75 f0             	pushl  -0x10(%ebp)
c0107bc4:	e8 ce 0c 00 00       	call   c0108897 <free_pages>
c0107bc9:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0107bcc:	83 ec 08             	sub    $0x8,%esp
c0107bcf:	6a 01                	push   $0x1
c0107bd1:	ff 75 f4             	pushl  -0xc(%ebp)
c0107bd4:	e8 be 0c 00 00       	call   c0108897 <free_pages>
c0107bd9:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c0107bdc:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107be2:	8b 40 08             	mov    0x8(%eax),%eax
c0107be5:	83 f8 03             	cmp    $0x3,%eax
c0107be8:	74 1f                	je     c0107c09 <basic_check+0x319>
c0107bea:	8d 83 cb 3a fe ff    	lea    -0x1c535(%ebx),%eax
c0107bf0:	50                   	push   %eax
c0107bf1:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107bf7:	50                   	push   %eax
c0107bf8:	68 c4 00 00 00       	push   $0xc4
c0107bfd:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107c03:	50                   	push   %eax
c0107c04:	e8 09 9e ff ff       	call   c0101a12 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0107c09:	83 ec 0c             	sub    $0xc,%esp
c0107c0c:	6a 01                	push   $0x1
c0107c0e:	e8 00 0c 00 00       	call   c0108813 <alloc_pages>
c0107c13:	83 c4 10             	add    $0x10,%esp
c0107c16:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107c19:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107c1d:	75 1f                	jne    c0107c3e <basic_check+0x34e>
c0107c1f:	8d 83 94 39 fe ff    	lea    -0x1c66c(%ebx),%eax
c0107c25:	50                   	push   %eax
c0107c26:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107c2c:	50                   	push   %eax
c0107c2d:	68 c6 00 00 00       	push   $0xc6
c0107c32:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107c38:	50                   	push   %eax
c0107c39:	e8 d4 9d ff ff       	call   c0101a12 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0107c3e:	83 ec 0c             	sub    $0xc,%esp
c0107c41:	6a 01                	push   $0x1
c0107c43:	e8 cb 0b 00 00       	call   c0108813 <alloc_pages>
c0107c48:	83 c4 10             	add    $0x10,%esp
c0107c4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107c52:	75 1f                	jne    c0107c73 <basic_check+0x383>
c0107c54:	8d 83 b0 39 fe ff    	lea    -0x1c650(%ebx),%eax
c0107c5a:	50                   	push   %eax
c0107c5b:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107c61:	50                   	push   %eax
c0107c62:	68 c7 00 00 00       	push   $0xc7
c0107c67:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107c6d:	50                   	push   %eax
c0107c6e:	e8 9f 9d ff ff       	call   c0101a12 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0107c73:	83 ec 0c             	sub    $0xc,%esp
c0107c76:	6a 01                	push   $0x1
c0107c78:	e8 96 0b 00 00       	call   c0108813 <alloc_pages>
c0107c7d:	83 c4 10             	add    $0x10,%esp
c0107c80:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c83:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107c87:	75 1f                	jne    c0107ca8 <basic_check+0x3b8>
c0107c89:	8d 83 cc 39 fe ff    	lea    -0x1c634(%ebx),%eax
c0107c8f:	50                   	push   %eax
c0107c90:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107c96:	50                   	push   %eax
c0107c97:	68 c8 00 00 00       	push   $0xc8
c0107c9c:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107ca2:	50                   	push   %eax
c0107ca3:	e8 6a 9d ff ff       	call   c0101a12 <__panic>

    assert(alloc_page() == NULL);
c0107ca8:	83 ec 0c             	sub    $0xc,%esp
c0107cab:	6a 01                	push   $0x1
c0107cad:	e8 61 0b 00 00       	call   c0108813 <alloc_pages>
c0107cb2:	83 c4 10             	add    $0x10,%esp
c0107cb5:	85 c0                	test   %eax,%eax
c0107cb7:	74 1f                	je     c0107cd8 <basic_check+0x3e8>
c0107cb9:	8d 83 b6 3a fe ff    	lea    -0x1c54a(%ebx),%eax
c0107cbf:	50                   	push   %eax
c0107cc0:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107cc6:	50                   	push   %eax
c0107cc7:	68 ca 00 00 00       	push   $0xca
c0107ccc:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107cd2:	50                   	push   %eax
c0107cd3:	e8 3a 9d ff ff       	call   c0101a12 <__panic>

    free_page(p0);
c0107cd8:	83 ec 08             	sub    $0x8,%esp
c0107cdb:	6a 01                	push   $0x1
c0107cdd:	ff 75 ec             	pushl  -0x14(%ebp)
c0107ce0:	e8 b2 0b 00 00       	call   c0108897 <free_pages>
c0107ce5:	83 c4 10             	add    $0x10,%esp
c0107ce8:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107cee:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107cf1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107cf4:	8b 40 04             	mov    0x4(%eax),%eax
c0107cf7:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0107cfa:	0f 94 c0             	sete   %al
c0107cfd:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0107d00:	85 c0                	test   %eax,%eax
c0107d02:	74 1f                	je     c0107d23 <basic_check+0x433>
c0107d04:	8d 83 d8 3a fe ff    	lea    -0x1c528(%ebx),%eax
c0107d0a:	50                   	push   %eax
c0107d0b:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107d11:	50                   	push   %eax
c0107d12:	68 cd 00 00 00       	push   $0xcd
c0107d17:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107d1d:	50                   	push   %eax
c0107d1e:	e8 ef 9c ff ff       	call   c0101a12 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0107d23:	83 ec 0c             	sub    $0xc,%esp
c0107d26:	6a 01                	push   $0x1
c0107d28:	e8 e6 0a 00 00       	call   c0108813 <alloc_pages>
c0107d2d:	83 c4 10             	add    $0x10,%esp
c0107d30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d36:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107d39:	74 1f                	je     c0107d5a <basic_check+0x46a>
c0107d3b:	8d 83 f0 3a fe ff    	lea    -0x1c510(%ebx),%eax
c0107d41:	50                   	push   %eax
c0107d42:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107d48:	50                   	push   %eax
c0107d49:	68 d0 00 00 00       	push   $0xd0
c0107d4e:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107d54:	50                   	push   %eax
c0107d55:	e8 b8 9c ff ff       	call   c0101a12 <__panic>
    assert(alloc_page() == NULL);
c0107d5a:	83 ec 0c             	sub    $0xc,%esp
c0107d5d:	6a 01                	push   $0x1
c0107d5f:	e8 af 0a 00 00       	call   c0108813 <alloc_pages>
c0107d64:	83 c4 10             	add    $0x10,%esp
c0107d67:	85 c0                	test   %eax,%eax
c0107d69:	74 1f                	je     c0107d8a <basic_check+0x49a>
c0107d6b:	8d 83 b6 3a fe ff    	lea    -0x1c54a(%ebx),%eax
c0107d71:	50                   	push   %eax
c0107d72:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107d78:	50                   	push   %eax
c0107d79:	68 d1 00 00 00       	push   $0xd1
c0107d7e:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107d84:	50                   	push   %eax
c0107d85:	e8 88 9c ff ff       	call   c0101a12 <__panic>

    assert(nr_free == 0);
c0107d8a:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107d90:	8b 40 08             	mov    0x8(%eax),%eax
c0107d93:	85 c0                	test   %eax,%eax
c0107d95:	74 1f                	je     c0107db6 <basic_check+0x4c6>
c0107d97:	8d 83 09 3b fe ff    	lea    -0x1c4f7(%ebx),%eax
c0107d9d:	50                   	push   %eax
c0107d9e:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107da4:	50                   	push   %eax
c0107da5:	68 d3 00 00 00       	push   $0xd3
c0107daa:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107db0:	50                   	push   %eax
c0107db1:	e8 5c 9c ff ff       	call   c0101a12 <__panic>
    free_list = free_list_store;
c0107db6:	c7 c1 84 cc 12 c0    	mov    $0xc012cc84,%ecx
c0107dbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107dbf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107dc2:	89 01                	mov    %eax,(%ecx)
c0107dc4:	89 51 04             	mov    %edx,0x4(%ecx)
    nr_free = nr_free_store;
c0107dc7:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107dcd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107dd0:	89 50 08             	mov    %edx,0x8(%eax)

    free_page(p);
c0107dd3:	83 ec 08             	sub    $0x8,%esp
c0107dd6:	6a 01                	push   $0x1
c0107dd8:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107ddb:	e8 b7 0a 00 00       	call   c0108897 <free_pages>
c0107de0:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0107de3:	83 ec 08             	sub    $0x8,%esp
c0107de6:	6a 01                	push   $0x1
c0107de8:	ff 75 f0             	pushl  -0x10(%ebp)
c0107deb:	e8 a7 0a 00 00       	call   c0108897 <free_pages>
c0107df0:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0107df3:	83 ec 08             	sub    $0x8,%esp
c0107df6:	6a 01                	push   $0x1
c0107df8:	ff 75 f4             	pushl  -0xc(%ebp)
c0107dfb:	e8 97 0a 00 00       	call   c0108897 <free_pages>
c0107e00:	83 c4 10             	add    $0x10,%esp
}
c0107e03:	90                   	nop
c0107e04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0107e07:	c9                   	leave  
c0107e08:	c3                   	ret    

c0107e09 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0107e09:	55                   	push   %ebp
c0107e0a:	89 e5                	mov    %esp,%ebp
c0107e0c:	53                   	push   %ebx
c0107e0d:	81 ec 84 00 00 00    	sub    $0x84,%esp
c0107e13:	e8 a9 84 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0107e18:	81 c3 68 1b 02 00    	add    $0x21b68,%ebx
    int count = 0, total = 0;
c0107e1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107e25:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0107e2c:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107e32:	89 45 ec             	mov    %eax,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107e35:	eb 66                	jmp    c0107e9d <default_check+0x94>
        struct Page *p = le2page(le, page_link);
c0107e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e3a:	83 e8 10             	sub    $0x10,%eax
c0107e3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0107e40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e43:	83 c0 04             	add    $0x4,%eax
c0107e46:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0107e4d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107e50:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107e53:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107e56:	0f a3 10             	bt     %edx,(%eax)
c0107e59:	19 c0                	sbb    %eax,%eax
c0107e5b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0107e5e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107e62:	0f 95 c0             	setne  %al
c0107e65:	0f b6 c0             	movzbl %al,%eax
c0107e68:	85 c0                	test   %eax,%eax
c0107e6a:	75 1f                	jne    c0107e8b <default_check+0x82>
c0107e6c:	8d 83 16 3b fe ff    	lea    -0x1c4ea(%ebx),%eax
c0107e72:	50                   	push   %eax
c0107e73:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107e79:	50                   	push   %eax
c0107e7a:	68 e4 00 00 00       	push   $0xe4
c0107e7f:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107e85:	50                   	push   %eax
c0107e86:	e8 87 9b ff ff       	call   c0101a12 <__panic>
        count ++, total += p->property;
c0107e8b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107e8f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e92:	8b 50 08             	mov    0x8(%eax),%edx
c0107e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e98:	01 d0                	add    %edx,%eax
c0107e9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ea0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0107ea3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107ea6:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0107ea9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107eac:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107eb2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107eb5:	75 80                	jne    c0107e37 <default_check+0x2e>
    }
    assert(total == nr_free_pages());
c0107eb7:	e8 22 0a 00 00       	call   c01088de <nr_free_pages>
c0107ebc:	89 c2                	mov    %eax,%edx
c0107ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ec1:	39 c2                	cmp    %eax,%edx
c0107ec3:	74 1f                	je     c0107ee4 <default_check+0xdb>
c0107ec5:	8d 83 26 3b fe ff    	lea    -0x1c4da(%ebx),%eax
c0107ecb:	50                   	push   %eax
c0107ecc:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107ed2:	50                   	push   %eax
c0107ed3:	68 e7 00 00 00       	push   $0xe7
c0107ed8:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107ede:	50                   	push   %eax
c0107edf:	e8 2e 9b ff ff       	call   c0101a12 <__panic>

    basic_check();
c0107ee4:	e8 07 fa ff ff       	call   c01078f0 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0107ee9:	83 ec 0c             	sub    $0xc,%esp
c0107eec:	6a 05                	push   $0x5
c0107eee:	e8 20 09 00 00       	call   c0108813 <alloc_pages>
c0107ef3:	83 c4 10             	add    $0x10,%esp
c0107ef6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0107ef9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107efd:	75 1f                	jne    c0107f1e <default_check+0x115>
c0107eff:	8d 83 3f 3b fe ff    	lea    -0x1c4c1(%ebx),%eax
c0107f05:	50                   	push   %eax
c0107f06:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107f0c:	50                   	push   %eax
c0107f0d:	68 ec 00 00 00       	push   $0xec
c0107f12:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107f18:	50                   	push   %eax
c0107f19:	e8 f4 9a ff ff       	call   c0101a12 <__panic>
    assert(!PageProperty(p0));
c0107f1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f21:	83 c0 04             	add    $0x4,%eax
c0107f24:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0107f2b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107f2e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107f31:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107f34:	0f a3 10             	bt     %edx,(%eax)
c0107f37:	19 c0                	sbb    %eax,%eax
c0107f39:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0107f3c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0107f40:	0f 95 c0             	setne  %al
c0107f43:	0f b6 c0             	movzbl %al,%eax
c0107f46:	85 c0                	test   %eax,%eax
c0107f48:	74 1f                	je     c0107f69 <default_check+0x160>
c0107f4a:	8d 83 4a 3b fe ff    	lea    -0x1c4b6(%ebx),%eax
c0107f50:	50                   	push   %eax
c0107f51:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107f57:	50                   	push   %eax
c0107f58:	68 ed 00 00 00       	push   $0xed
c0107f5d:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107f63:	50                   	push   %eax
c0107f64:	e8 a9 9a ff ff       	call   c0101a12 <__panic>

    list_entry_t free_list_store = free_list;
c0107f69:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107f6f:	8b 50 04             	mov    0x4(%eax),%edx
c0107f72:	8b 00                	mov    (%eax),%eax
c0107f74:	89 45 80             	mov    %eax,-0x80(%ebp)
c0107f77:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0107f7a:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107f80:	89 45 b0             	mov    %eax,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0107f83:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107f86:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0107f89:	89 50 04             	mov    %edx,0x4(%eax)
c0107f8c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107f8f:	8b 50 04             	mov    0x4(%eax),%edx
c0107f92:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107f95:	89 10                	mov    %edx,(%eax)
c0107f97:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0107f9d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    return list->next == list;
c0107fa0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107fa3:	8b 40 04             	mov    0x4(%eax),%eax
c0107fa6:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0107fa9:	0f 94 c0             	sete   %al
c0107fac:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107faf:	85 c0                	test   %eax,%eax
c0107fb1:	75 1f                	jne    c0107fd2 <default_check+0x1c9>
c0107fb3:	8d 83 9f 3a fe ff    	lea    -0x1c561(%ebx),%eax
c0107fb9:	50                   	push   %eax
c0107fba:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107fc0:	50                   	push   %eax
c0107fc1:	68 f1 00 00 00       	push   $0xf1
c0107fc6:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107fcc:	50                   	push   %eax
c0107fcd:	e8 40 9a ff ff       	call   c0101a12 <__panic>
    assert(alloc_page() == NULL);
c0107fd2:	83 ec 0c             	sub    $0xc,%esp
c0107fd5:	6a 01                	push   $0x1
c0107fd7:	e8 37 08 00 00       	call   c0108813 <alloc_pages>
c0107fdc:	83 c4 10             	add    $0x10,%esp
c0107fdf:	85 c0                	test   %eax,%eax
c0107fe1:	74 1f                	je     c0108002 <default_check+0x1f9>
c0107fe3:	8d 83 b6 3a fe ff    	lea    -0x1c54a(%ebx),%eax
c0107fe9:	50                   	push   %eax
c0107fea:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0107ff0:	50                   	push   %eax
c0107ff1:	68 f2 00 00 00       	push   $0xf2
c0107ff6:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0107ffc:	50                   	push   %eax
c0107ffd:	e8 10 9a ff ff       	call   c0101a12 <__panic>

    unsigned int nr_free_store = nr_free;
c0108002:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0108008:	8b 40 08             	mov    0x8(%eax),%eax
c010800b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010800e:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0108014:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

    free_pages(p0 + 2, 3);
c010801b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010801e:	83 c0 48             	add    $0x48,%eax
c0108021:	83 ec 08             	sub    $0x8,%esp
c0108024:	6a 03                	push   $0x3
c0108026:	50                   	push   %eax
c0108027:	e8 6b 08 00 00       	call   c0108897 <free_pages>
c010802c:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c010802f:	83 ec 0c             	sub    $0xc,%esp
c0108032:	6a 04                	push   $0x4
c0108034:	e8 da 07 00 00       	call   c0108813 <alloc_pages>
c0108039:	83 c4 10             	add    $0x10,%esp
c010803c:	85 c0                	test   %eax,%eax
c010803e:	74 1f                	je     c010805f <default_check+0x256>
c0108040:	8d 83 5c 3b fe ff    	lea    -0x1c4a4(%ebx),%eax
c0108046:	50                   	push   %eax
c0108047:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c010804d:	50                   	push   %eax
c010804e:	68 f8 00 00 00       	push   $0xf8
c0108053:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0108059:	50                   	push   %eax
c010805a:	e8 b3 99 ff ff       	call   c0101a12 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010805f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108062:	83 c0 48             	add    $0x48,%eax
c0108065:	83 c0 04             	add    $0x4,%eax
c0108068:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010806f:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108072:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108075:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0108078:	0f a3 10             	bt     %edx,(%eax)
c010807b:	19 c0                	sbb    %eax,%eax
c010807d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0108080:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0108084:	0f 95 c0             	setne  %al
c0108087:	0f b6 c0             	movzbl %al,%eax
c010808a:	85 c0                	test   %eax,%eax
c010808c:	74 0e                	je     c010809c <default_check+0x293>
c010808e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108091:	83 c0 48             	add    $0x48,%eax
c0108094:	8b 40 08             	mov    0x8(%eax),%eax
c0108097:	83 f8 03             	cmp    $0x3,%eax
c010809a:	74 1f                	je     c01080bb <default_check+0x2b2>
c010809c:	8d 83 74 3b fe ff    	lea    -0x1c48c(%ebx),%eax
c01080a2:	50                   	push   %eax
c01080a3:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01080a9:	50                   	push   %eax
c01080aa:	68 f9 00 00 00       	push   $0xf9
c01080af:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01080b5:	50                   	push   %eax
c01080b6:	e8 57 99 ff ff       	call   c0101a12 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01080bb:	83 ec 0c             	sub    $0xc,%esp
c01080be:	6a 03                	push   $0x3
c01080c0:	e8 4e 07 00 00       	call   c0108813 <alloc_pages>
c01080c5:	83 c4 10             	add    $0x10,%esp
c01080c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01080cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01080cf:	75 1f                	jne    c01080f0 <default_check+0x2e7>
c01080d1:	8d 83 a0 3b fe ff    	lea    -0x1c460(%ebx),%eax
c01080d7:	50                   	push   %eax
c01080d8:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01080de:	50                   	push   %eax
c01080df:	68 fa 00 00 00       	push   $0xfa
c01080e4:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01080ea:	50                   	push   %eax
c01080eb:	e8 22 99 ff ff       	call   c0101a12 <__panic>
    assert(alloc_page() == NULL);
c01080f0:	83 ec 0c             	sub    $0xc,%esp
c01080f3:	6a 01                	push   $0x1
c01080f5:	e8 19 07 00 00       	call   c0108813 <alloc_pages>
c01080fa:	83 c4 10             	add    $0x10,%esp
c01080fd:	85 c0                	test   %eax,%eax
c01080ff:	74 1f                	je     c0108120 <default_check+0x317>
c0108101:	8d 83 b6 3a fe ff    	lea    -0x1c54a(%ebx),%eax
c0108107:	50                   	push   %eax
c0108108:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c010810e:	50                   	push   %eax
c010810f:	68 fb 00 00 00       	push   $0xfb
c0108114:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c010811a:	50                   	push   %eax
c010811b:	e8 f2 98 ff ff       	call   c0101a12 <__panic>
    assert(p0 + 2 == p1);
c0108120:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108123:	83 c0 48             	add    $0x48,%eax
c0108126:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108129:	74 1f                	je     c010814a <default_check+0x341>
c010812b:	8d 83 be 3b fe ff    	lea    -0x1c442(%ebx),%eax
c0108131:	50                   	push   %eax
c0108132:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0108138:	50                   	push   %eax
c0108139:	68 fc 00 00 00       	push   $0xfc
c010813e:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0108144:	50                   	push   %eax
c0108145:	e8 c8 98 ff ff       	call   c0101a12 <__panic>

    p2 = p0 + 1;
c010814a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010814d:	83 c0 24             	add    $0x24,%eax
c0108150:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0108153:	83 ec 08             	sub    $0x8,%esp
c0108156:	6a 01                	push   $0x1
c0108158:	ff 75 e8             	pushl  -0x18(%ebp)
c010815b:	e8 37 07 00 00       	call   c0108897 <free_pages>
c0108160:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0108163:	83 ec 08             	sub    $0x8,%esp
c0108166:	6a 03                	push   $0x3
c0108168:	ff 75 e0             	pushl  -0x20(%ebp)
c010816b:	e8 27 07 00 00       	call   c0108897 <free_pages>
c0108170:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0108173:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108176:	83 c0 04             	add    $0x4,%eax
c0108179:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0108180:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108183:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0108186:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0108189:	0f a3 10             	bt     %edx,(%eax)
c010818c:	19 c0                	sbb    %eax,%eax
c010818e:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0108191:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0108195:	0f 95 c0             	setne  %al
c0108198:	0f b6 c0             	movzbl %al,%eax
c010819b:	85 c0                	test   %eax,%eax
c010819d:	74 0b                	je     c01081aa <default_check+0x3a1>
c010819f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081a2:	8b 40 08             	mov    0x8(%eax),%eax
c01081a5:	83 f8 01             	cmp    $0x1,%eax
c01081a8:	74 1f                	je     c01081c9 <default_check+0x3c0>
c01081aa:	8d 83 cc 3b fe ff    	lea    -0x1c434(%ebx),%eax
c01081b0:	50                   	push   %eax
c01081b1:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01081b7:	50                   	push   %eax
c01081b8:	68 01 01 00 00       	push   $0x101
c01081bd:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01081c3:	50                   	push   %eax
c01081c4:	e8 49 98 ff ff       	call   c0101a12 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01081c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081cc:	83 c0 04             	add    $0x4,%eax
c01081cf:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01081d6:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01081d9:	8b 45 90             	mov    -0x70(%ebp),%eax
c01081dc:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01081df:	0f a3 10             	bt     %edx,(%eax)
c01081e2:	19 c0                	sbb    %eax,%eax
c01081e4:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01081e7:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01081eb:	0f 95 c0             	setne  %al
c01081ee:	0f b6 c0             	movzbl %al,%eax
c01081f1:	85 c0                	test   %eax,%eax
c01081f3:	74 0b                	je     c0108200 <default_check+0x3f7>
c01081f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081f8:	8b 40 08             	mov    0x8(%eax),%eax
c01081fb:	83 f8 03             	cmp    $0x3,%eax
c01081fe:	74 1f                	je     c010821f <default_check+0x416>
c0108200:	8d 83 f4 3b fe ff    	lea    -0x1c40c(%ebx),%eax
c0108206:	50                   	push   %eax
c0108207:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c010820d:	50                   	push   %eax
c010820e:	68 02 01 00 00       	push   $0x102
c0108213:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0108219:	50                   	push   %eax
c010821a:	e8 f3 97 ff ff       	call   c0101a12 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010821f:	83 ec 0c             	sub    $0xc,%esp
c0108222:	6a 01                	push   $0x1
c0108224:	e8 ea 05 00 00       	call   c0108813 <alloc_pages>
c0108229:	83 c4 10             	add    $0x10,%esp
c010822c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010822f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108232:	83 e8 24             	sub    $0x24,%eax
c0108235:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108238:	74 1f                	je     c0108259 <default_check+0x450>
c010823a:	8d 83 1a 3c fe ff    	lea    -0x1c3e6(%ebx),%eax
c0108240:	50                   	push   %eax
c0108241:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0108247:	50                   	push   %eax
c0108248:	68 04 01 00 00       	push   $0x104
c010824d:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0108253:	50                   	push   %eax
c0108254:	e8 b9 97 ff ff       	call   c0101a12 <__panic>
    free_page(p0);
c0108259:	83 ec 08             	sub    $0x8,%esp
c010825c:	6a 01                	push   $0x1
c010825e:	ff 75 e8             	pushl  -0x18(%ebp)
c0108261:	e8 31 06 00 00       	call   c0108897 <free_pages>
c0108266:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0108269:	83 ec 0c             	sub    $0xc,%esp
c010826c:	6a 02                	push   $0x2
c010826e:	e8 a0 05 00 00       	call   c0108813 <alloc_pages>
c0108273:	83 c4 10             	add    $0x10,%esp
c0108276:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108279:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010827c:	83 c0 24             	add    $0x24,%eax
c010827f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108282:	74 1f                	je     c01082a3 <default_check+0x49a>
c0108284:	8d 83 38 3c fe ff    	lea    -0x1c3c8(%ebx),%eax
c010828a:	50                   	push   %eax
c010828b:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0108291:	50                   	push   %eax
c0108292:	68 06 01 00 00       	push   $0x106
c0108297:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c010829d:	50                   	push   %eax
c010829e:	e8 6f 97 ff ff       	call   c0101a12 <__panic>

    free_pages(p0, 2);
c01082a3:	83 ec 08             	sub    $0x8,%esp
c01082a6:	6a 02                	push   $0x2
c01082a8:	ff 75 e8             	pushl  -0x18(%ebp)
c01082ab:	e8 e7 05 00 00       	call   c0108897 <free_pages>
c01082b0:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c01082b3:	83 ec 08             	sub    $0x8,%esp
c01082b6:	6a 01                	push   $0x1
c01082b8:	ff 75 dc             	pushl  -0x24(%ebp)
c01082bb:	e8 d7 05 00 00       	call   c0108897 <free_pages>
c01082c0:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c01082c3:	83 ec 0c             	sub    $0xc,%esp
c01082c6:	6a 05                	push   $0x5
c01082c8:	e8 46 05 00 00       	call   c0108813 <alloc_pages>
c01082cd:	83 c4 10             	add    $0x10,%esp
c01082d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01082d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082d7:	75 1f                	jne    c01082f8 <default_check+0x4ef>
c01082d9:	8d 83 58 3c fe ff    	lea    -0x1c3a8(%ebx),%eax
c01082df:	50                   	push   %eax
c01082e0:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01082e6:	50                   	push   %eax
c01082e7:	68 0b 01 00 00       	push   $0x10b
c01082ec:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01082f2:	50                   	push   %eax
c01082f3:	e8 1a 97 ff ff       	call   c0101a12 <__panic>
    assert(alloc_page() == NULL);
c01082f8:	83 ec 0c             	sub    $0xc,%esp
c01082fb:	6a 01                	push   $0x1
c01082fd:	e8 11 05 00 00       	call   c0108813 <alloc_pages>
c0108302:	83 c4 10             	add    $0x10,%esp
c0108305:	85 c0                	test   %eax,%eax
c0108307:	74 1f                	je     c0108328 <default_check+0x51f>
c0108309:	8d 83 b6 3a fe ff    	lea    -0x1c54a(%ebx),%eax
c010830f:	50                   	push   %eax
c0108310:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0108316:	50                   	push   %eax
c0108317:	68 0c 01 00 00       	push   $0x10c
c010831c:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0108322:	50                   	push   %eax
c0108323:	e8 ea 96 ff ff       	call   c0101a12 <__panic>

    assert(nr_free == 0);
c0108328:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c010832e:	8b 40 08             	mov    0x8(%eax),%eax
c0108331:	85 c0                	test   %eax,%eax
c0108333:	74 1f                	je     c0108354 <default_check+0x54b>
c0108335:	8d 83 09 3b fe ff    	lea    -0x1c4f7(%ebx),%eax
c010833b:	50                   	push   %eax
c010833c:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c0108342:	50                   	push   %eax
c0108343:	68 0e 01 00 00       	push   $0x10e
c0108348:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c010834e:	50                   	push   %eax
c010834f:	e8 be 96 ff ff       	call   c0101a12 <__panic>
    nr_free = nr_free_store;
c0108354:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c010835a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010835d:	89 50 08             	mov    %edx,0x8(%eax)

    free_list = free_list_store;
c0108360:	c7 c1 84 cc 12 c0    	mov    $0xc012cc84,%ecx
c0108366:	8b 45 80             	mov    -0x80(%ebp),%eax
c0108369:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010836c:	89 01                	mov    %eax,(%ecx)
c010836e:	89 51 04             	mov    %edx,0x4(%ecx)
    free_pages(p0, 5);
c0108371:	83 ec 08             	sub    $0x8,%esp
c0108374:	6a 05                	push   $0x5
c0108376:	ff 75 e8             	pushl  -0x18(%ebp)
c0108379:	e8 19 05 00 00       	call   c0108897 <free_pages>
c010837e:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0108381:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c0108387:	89 45 ec             	mov    %eax,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010838a:	eb 1d                	jmp    c01083a9 <default_check+0x5a0>
        struct Page *p = le2page(le, page_link);
c010838c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010838f:	83 e8 10             	sub    $0x10,%eax
c0108392:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0108395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108399:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010839c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010839f:	8b 40 08             	mov    0x8(%eax),%eax
c01083a2:	29 c2                	sub    %eax,%edx
c01083a4:	89 d0                	mov    %edx,%eax
c01083a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01083a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083ac:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01083af:	8b 45 88             	mov    -0x78(%ebp),%eax
c01083b2:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01083b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01083b8:	c7 c0 84 cc 12 c0    	mov    $0xc012cc84,%eax
c01083be:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01083c1:	75 c9                	jne    c010838c <default_check+0x583>
    }
    assert(count == 0);
c01083c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01083c7:	74 1f                	je     c01083e8 <default_check+0x5df>
c01083c9:	8d 83 76 3c fe ff    	lea    -0x1c38a(%ebx),%eax
c01083cf:	50                   	push   %eax
c01083d0:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01083d6:	50                   	push   %eax
c01083d7:	68 19 01 00 00       	push   $0x119
c01083dc:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c01083e2:	50                   	push   %eax
c01083e3:	e8 2a 96 ff ff       	call   c0101a12 <__panic>
    assert(total == 0);
c01083e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01083ec:	74 1f                	je     c010840d <default_check+0x604>
c01083ee:	8d 83 81 3c fe ff    	lea    -0x1c37f(%ebx),%eax
c01083f4:	50                   	push   %eax
c01083f5:	8d 83 46 39 fe ff    	lea    -0x1c6ba(%ebx),%eax
c01083fb:	50                   	push   %eax
c01083fc:	68 1a 01 00 00       	push   $0x11a
c0108401:	8d 83 5b 39 fe ff    	lea    -0x1c6a5(%ebx),%eax
c0108407:	50                   	push   %eax
c0108408:	e8 05 96 ff ff       	call   c0101a12 <__panic>
}
c010840d:	90                   	nop
c010840e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108411:	c9                   	leave  
c0108412:	c3                   	ret    

c0108413 <page2ppn>:
page2ppn(struct Page *page) {
c0108413:	55                   	push   %ebp
c0108414:	89 e5                	mov    %esp,%ebp
c0108416:	e8 a2 7e ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010841b:	05 65 15 02 00       	add    $0x21565,%eax
    return page - pages;
c0108420:	8b 55 08             	mov    0x8(%ebp),%edx
c0108423:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0108429:	8b 00                	mov    (%eax),%eax
c010842b:	29 c2                	sub    %eax,%edx
c010842d:	89 d0                	mov    %edx,%eax
c010842f:	c1 f8 02             	sar    $0x2,%eax
c0108432:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0108438:	5d                   	pop    %ebp
c0108439:	c3                   	ret    

c010843a <page2pa>:
page2pa(struct Page *page) {
c010843a:	55                   	push   %ebp
c010843b:	89 e5                	mov    %esp,%ebp
c010843d:	e8 7b 7e ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108442:	05 3e 15 02 00       	add    $0x2153e,%eax
    return page2ppn(page) << PGSHIFT;
c0108447:	ff 75 08             	pushl  0x8(%ebp)
c010844a:	e8 c4 ff ff ff       	call   c0108413 <page2ppn>
c010844f:	83 c4 04             	add    $0x4,%esp
c0108452:	c1 e0 0c             	shl    $0xc,%eax
}
c0108455:	c9                   	leave  
c0108456:	c3                   	ret    

c0108457 <pa2page>:
pa2page(uintptr_t pa) {
c0108457:	55                   	push   %ebp
c0108458:	89 e5                	mov    %esp,%ebp
c010845a:	53                   	push   %ebx
c010845b:	83 ec 04             	sub    $0x4,%esp
c010845e:	e8 5a 7e ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108463:	05 1d 15 02 00       	add    $0x2151d,%eax
    if (PPN(pa) >= npage) {
c0108468:	8b 55 08             	mov    0x8(%ebp),%edx
c010846b:	89 d1                	mov    %edx,%ecx
c010846d:	c1 e9 0c             	shr    $0xc,%ecx
c0108470:	8b 90 40 11 00 00    	mov    0x1140(%eax),%edx
c0108476:	39 d1                	cmp    %edx,%ecx
c0108478:	72 1a                	jb     c0108494 <pa2page+0x3d>
        panic("pa2page called with invalid pa");
c010847a:	83 ec 04             	sub    $0x4,%esp
c010847d:	8d 90 a0 3c fe ff    	lea    -0x1c360(%eax),%edx
c0108483:	52                   	push   %edx
c0108484:	6a 5f                	push   $0x5f
c0108486:	8d 90 bf 3c fe ff    	lea    -0x1c341(%eax),%edx
c010848c:	52                   	push   %edx
c010848d:	89 c3                	mov    %eax,%ebx
c010848f:	e8 7e 95 ff ff       	call   c0101a12 <__panic>
    return &pages[PPN(pa)];
c0108494:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c010849a:	8b 08                	mov    (%eax),%ecx
c010849c:	8b 45 08             	mov    0x8(%ebp),%eax
c010849f:	c1 e8 0c             	shr    $0xc,%eax
c01084a2:	89 c2                	mov    %eax,%edx
c01084a4:	89 d0                	mov    %edx,%eax
c01084a6:	c1 e0 03             	shl    $0x3,%eax
c01084a9:	01 d0                	add    %edx,%eax
c01084ab:	c1 e0 02             	shl    $0x2,%eax
c01084ae:	01 c8                	add    %ecx,%eax
}
c01084b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01084b3:	c9                   	leave  
c01084b4:	c3                   	ret    

c01084b5 <page2kva>:
page2kva(struct Page *page) {
c01084b5:	55                   	push   %ebp
c01084b6:	89 e5                	mov    %esp,%ebp
c01084b8:	53                   	push   %ebx
c01084b9:	83 ec 14             	sub    $0x14,%esp
c01084bc:	e8 00 7e ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01084c1:	81 c3 bf 14 02 00    	add    $0x214bf,%ebx
    return KADDR(page2pa(page));
c01084c7:	ff 75 08             	pushl  0x8(%ebp)
c01084ca:	e8 6b ff ff ff       	call   c010843a <page2pa>
c01084cf:	83 c4 04             	add    $0x4,%esp
c01084d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01084d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084d8:	c1 e8 0c             	shr    $0xc,%eax
c01084db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084de:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c01084e4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01084e7:	72 18                	jb     c0108501 <page2kva+0x4c>
c01084e9:	ff 75 f4             	pushl  -0xc(%ebp)
c01084ec:	8d 83 d0 3c fe ff    	lea    -0x1c330(%ebx),%eax
c01084f2:	50                   	push   %eax
c01084f3:	6a 66                	push   $0x66
c01084f5:	8d 83 bf 3c fe ff    	lea    -0x1c341(%ebx),%eax
c01084fb:	50                   	push   %eax
c01084fc:	e8 11 95 ff ff       	call   c0101a12 <__panic>
c0108501:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108504:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010850c:	c9                   	leave  
c010850d:	c3                   	ret    

c010850e <pte2page>:
pte2page(pte_t pte) {
c010850e:	55                   	push   %ebp
c010850f:	89 e5                	mov    %esp,%ebp
c0108511:	53                   	push   %ebx
c0108512:	83 ec 04             	sub    $0x4,%esp
c0108515:	e8 a3 7d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010851a:	05 66 14 02 00       	add    $0x21466,%eax
    if (!(pte & PTE_P)) {
c010851f:	8b 55 08             	mov    0x8(%ebp),%edx
c0108522:	83 e2 01             	and    $0x1,%edx
c0108525:	85 d2                	test   %edx,%edx
c0108527:	75 1a                	jne    c0108543 <pte2page+0x35>
        panic("pte2page called with invalid pte");
c0108529:	83 ec 04             	sub    $0x4,%esp
c010852c:	8d 90 f4 3c fe ff    	lea    -0x1c30c(%eax),%edx
c0108532:	52                   	push   %edx
c0108533:	6a 71                	push   $0x71
c0108535:	8d 90 bf 3c fe ff    	lea    -0x1c341(%eax),%edx
c010853b:	52                   	push   %edx
c010853c:	89 c3                	mov    %eax,%ebx
c010853e:	e8 cf 94 ff ff       	call   c0101a12 <__panic>
    return pa2page(PTE_ADDR(pte));
c0108543:	8b 45 08             	mov    0x8(%ebp),%eax
c0108546:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010854b:	83 ec 0c             	sub    $0xc,%esp
c010854e:	50                   	push   %eax
c010854f:	e8 03 ff ff ff       	call   c0108457 <pa2page>
c0108554:	83 c4 10             	add    $0x10,%esp
}
c0108557:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010855a:	c9                   	leave  
c010855b:	c3                   	ret    

c010855c <page_ref>:
page_ref(struct Page *page) {
c010855c:	55                   	push   %ebp
c010855d:	89 e5                	mov    %esp,%ebp
c010855f:	e8 59 7d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108564:	05 1c 14 02 00       	add    $0x2141c,%eax
    return page->ref;
c0108569:	8b 45 08             	mov    0x8(%ebp),%eax
c010856c:	8b 00                	mov    (%eax),%eax
}
c010856e:	5d                   	pop    %ebp
c010856f:	c3                   	ret    

c0108570 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0108570:	55                   	push   %ebp
c0108571:	89 e5                	mov    %esp,%ebp
c0108573:	e8 45 7d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108578:	05 08 14 02 00       	add    $0x21408,%eax
    page->ref = val;
c010857d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108580:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108583:	89 10                	mov    %edx,(%eax)
}
c0108585:	90                   	nop
c0108586:	5d                   	pop    %ebp
c0108587:	c3                   	ret    

c0108588 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0108588:	55                   	push   %ebp
c0108589:	89 e5                	mov    %esp,%ebp
c010858b:	e8 2d 7d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108590:	05 f0 13 02 00       	add    $0x213f0,%eax
    page->ref += 1;
c0108595:	8b 45 08             	mov    0x8(%ebp),%eax
c0108598:	8b 00                	mov    (%eax),%eax
c010859a:	8d 50 01             	lea    0x1(%eax),%edx
c010859d:	8b 45 08             	mov    0x8(%ebp),%eax
c01085a0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01085a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01085a5:	8b 00                	mov    (%eax),%eax
}
c01085a7:	5d                   	pop    %ebp
c01085a8:	c3                   	ret    

c01085a9 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01085a9:	55                   	push   %ebp
c01085aa:	89 e5                	mov    %esp,%ebp
c01085ac:	e8 0c 7d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01085b1:	05 cf 13 02 00       	add    $0x213cf,%eax
    page->ref -= 1;
c01085b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01085b9:	8b 00                	mov    (%eax),%eax
c01085bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01085be:	8b 45 08             	mov    0x8(%ebp),%eax
c01085c1:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01085c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01085c6:	8b 00                	mov    (%eax),%eax
}
c01085c8:	5d                   	pop    %ebp
c01085c9:	c3                   	ret    

c01085ca <__intr_save>:
__intr_save(void) {
c01085ca:	55                   	push   %ebp
c01085cb:	89 e5                	mov    %esp,%ebp
c01085cd:	53                   	push   %ebx
c01085ce:	83 ec 14             	sub    $0x14,%esp
c01085d1:	e8 e7 7c ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01085d6:	05 aa 13 02 00       	add    $0x213aa,%eax
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01085db:	9c                   	pushf  
c01085dc:	5a                   	pop    %edx
c01085dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
    return eflags;
c01085e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if (read_eflags() & FL_IF) {
c01085e3:	81 e2 00 02 00 00    	and    $0x200,%edx
c01085e9:	85 d2                	test   %edx,%edx
c01085eb:	74 0e                	je     c01085fb <__intr_save+0x31>
        intr_disable();
c01085ed:	89 c3                	mov    %eax,%ebx
c01085ef:	e8 88 b3 ff ff       	call   c010397c <intr_disable>
        return 1;
c01085f4:	b8 01 00 00 00       	mov    $0x1,%eax
c01085f9:	eb 05                	jmp    c0108600 <__intr_save+0x36>
    return 0;
c01085fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108600:	83 c4 14             	add    $0x14,%esp
c0108603:	5b                   	pop    %ebx
c0108604:	5d                   	pop    %ebp
c0108605:	c3                   	ret    

c0108606 <__intr_restore>:
__intr_restore(bool flag) {
c0108606:	55                   	push   %ebp
c0108607:	89 e5                	mov    %esp,%ebp
c0108609:	53                   	push   %ebx
c010860a:	83 ec 04             	sub    $0x4,%esp
c010860d:	e8 ab 7c ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108612:	05 6e 13 02 00       	add    $0x2136e,%eax
    if (flag) {
c0108617:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010861b:	74 07                	je     c0108624 <__intr_restore+0x1e>
        intr_enable();
c010861d:	89 c3                	mov    %eax,%ebx
c010861f:	e8 47 b3 ff ff       	call   c010396b <intr_enable>
}
c0108624:	90                   	nop
c0108625:	83 c4 04             	add    $0x4,%esp
c0108628:	5b                   	pop    %ebx
c0108629:	5d                   	pop    %ebp
c010862a:	c3                   	ret    

c010862b <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c010862b:	55                   	push   %ebp
c010862c:	89 e5                	mov    %esp,%ebp
c010862e:	e8 8a 7c ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108633:	05 4d 13 02 00       	add    $0x2134d,%eax
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0108638:	8b 45 08             	mov    0x8(%ebp),%eax
c010863b:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c010863e:	b8 23 00 00 00       	mov    $0x23,%eax
c0108643:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0108645:	b8 23 00 00 00       	mov    $0x23,%eax
c010864a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010864c:	b8 10 00 00 00       	mov    $0x10,%eax
c0108651:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0108653:	b8 10 00 00 00       	mov    $0x10,%eax
c0108658:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c010865a:	b8 10 00 00 00       	mov    $0x10,%eax
c010865f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0108661:	ea 68 86 10 c0 08 00 	ljmp   $0x8,$0xc0108668
}
c0108668:	90                   	nop
c0108669:	5d                   	pop    %ebp
c010866a:	c3                   	ret    

c010866b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c010866b:	55                   	push   %ebp
c010866c:	89 e5                	mov    %esp,%ebp
c010866e:	e8 4a 7c ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108673:	05 0d 13 02 00       	add    $0x2130d,%eax
    ts.ts_esp0 = esp0;
c0108678:	8b 55 08             	mov    0x8(%ebp),%edx
c010867b:	89 90 64 11 00 00    	mov    %edx,0x1164(%eax)
}
c0108681:	90                   	nop
c0108682:	5d                   	pop    %ebp
c0108683:	c3                   	ret    

c0108684 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0108684:	55                   	push   %ebp
c0108685:	89 e5                	mov    %esp,%ebp
c0108687:	53                   	push   %ebx
c0108688:	83 ec 10             	sub    $0x10,%esp
c010868b:	e8 31 7c ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0108690:	81 c3 f0 12 02 00    	add    $0x212f0,%ebx
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0108696:	c7 c0 00 90 12 c0    	mov    $0xc0129000,%eax
c010869c:	50                   	push   %eax
c010869d:	e8 c9 ff ff ff       	call   c010866b <load_esp0>
c01086a2:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c01086a5:	66 c7 83 68 11 00 00 	movw   $0x10,0x1168(%ebx)
c01086ac:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01086ae:	66 c7 83 e8 ff ff ff 	movw   $0x68,-0x18(%ebx)
c01086b5:	68 00 
c01086b7:	8d 83 60 11 00 00    	lea    0x1160(%ebx),%eax
c01086bd:	66 89 83 ea ff ff ff 	mov    %ax,-0x16(%ebx)
c01086c4:	8d 83 60 11 00 00    	lea    0x1160(%ebx),%eax
c01086ca:	c1 e8 10             	shr    $0x10,%eax
c01086cd:	88 83 ec ff ff ff    	mov    %al,-0x14(%ebx)
c01086d3:	0f b6 83 ed ff ff ff 	movzbl -0x13(%ebx),%eax
c01086da:	83 e0 f0             	and    $0xfffffff0,%eax
c01086dd:	83 c8 09             	or     $0x9,%eax
c01086e0:	88 83 ed ff ff ff    	mov    %al,-0x13(%ebx)
c01086e6:	0f b6 83 ed ff ff ff 	movzbl -0x13(%ebx),%eax
c01086ed:	83 e0 ef             	and    $0xffffffef,%eax
c01086f0:	88 83 ed ff ff ff    	mov    %al,-0x13(%ebx)
c01086f6:	0f b6 83 ed ff ff ff 	movzbl -0x13(%ebx),%eax
c01086fd:	83 e0 9f             	and    $0xffffff9f,%eax
c0108700:	88 83 ed ff ff ff    	mov    %al,-0x13(%ebx)
c0108706:	0f b6 83 ed ff ff ff 	movzbl -0x13(%ebx),%eax
c010870d:	83 c8 80             	or     $0xffffff80,%eax
c0108710:	88 83 ed ff ff ff    	mov    %al,-0x13(%ebx)
c0108716:	0f b6 83 ee ff ff ff 	movzbl -0x12(%ebx),%eax
c010871d:	83 e0 f0             	and    $0xfffffff0,%eax
c0108720:	88 83 ee ff ff ff    	mov    %al,-0x12(%ebx)
c0108726:	0f b6 83 ee ff ff ff 	movzbl -0x12(%ebx),%eax
c010872d:	83 e0 ef             	and    $0xffffffef,%eax
c0108730:	88 83 ee ff ff ff    	mov    %al,-0x12(%ebx)
c0108736:	0f b6 83 ee ff ff ff 	movzbl -0x12(%ebx),%eax
c010873d:	83 e0 df             	and    $0xffffffdf,%eax
c0108740:	88 83 ee ff ff ff    	mov    %al,-0x12(%ebx)
c0108746:	0f b6 83 ee ff ff ff 	movzbl -0x12(%ebx),%eax
c010874d:	83 c8 40             	or     $0x40,%eax
c0108750:	88 83 ee ff ff ff    	mov    %al,-0x12(%ebx)
c0108756:	0f b6 83 ee ff ff ff 	movzbl -0x12(%ebx),%eax
c010875d:	83 e0 7f             	and    $0x7f,%eax
c0108760:	88 83 ee ff ff ff    	mov    %al,-0x12(%ebx)
c0108766:	8d 83 60 11 00 00    	lea    0x1160(%ebx),%eax
c010876c:	c1 e8 18             	shr    $0x18,%eax
c010876f:	88 83 ef ff ff ff    	mov    %al,-0x11(%ebx)

    // reload all segment registers
    lgdt(&gdt_pd);
c0108775:	8d 83 0c 01 00 00    	lea    0x10c(%ebx),%eax
c010877b:	50                   	push   %eax
c010877c:	e8 aa fe ff ff       	call   c010862b <lgdt>
c0108781:	83 c4 04             	add    $0x4,%esp
c0108784:	66 c7 45 fa 28 00    	movw   $0x28,-0x6(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010878a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010878e:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0108791:	90                   	nop
c0108792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108795:	c9                   	leave  
c0108796:	c3                   	ret    

c0108797 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0108797:	55                   	push   %ebp
c0108798:	89 e5                	mov    %esp,%ebp
c010879a:	53                   	push   %ebx
c010879b:	83 ec 04             	sub    $0x4,%esp
c010879e:	e8 1e 7b ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01087a3:	81 c3 dd 11 02 00    	add    $0x211dd,%ebx
    pmm_manager = &default_pmm_manager;
c01087a9:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c01087af:	c7 c2 f0 9a 12 c0    	mov    $0xc0129af0,%edx
c01087b5:	89 10                	mov    %edx,(%eax)
    cprintf("memory management: %s\n", pmm_manager->name);
c01087b7:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c01087bd:	8b 00                	mov    (%eax),%eax
c01087bf:	8b 00                	mov    (%eax),%eax
c01087c1:	83 ec 08             	sub    $0x8,%esp
c01087c4:	50                   	push   %eax
c01087c5:	8d 83 20 3d fe ff    	lea    -0x1c2e0(%ebx),%eax
c01087cb:	50                   	push   %eax
c01087cc:	e8 63 7b ff ff       	call   c0100334 <cprintf>
c01087d1:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c01087d4:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c01087da:	8b 00                	mov    (%eax),%eax
c01087dc:	8b 40 04             	mov    0x4(%eax),%eax
c01087df:	ff d0                	call   *%eax
}
c01087e1:	90                   	nop
c01087e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01087e5:	c9                   	leave  
c01087e6:	c3                   	ret    

c01087e7 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01087e7:	55                   	push   %ebp
c01087e8:	89 e5                	mov    %esp,%ebp
c01087ea:	83 ec 08             	sub    $0x8,%esp
c01087ed:	e8 cb 7a ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01087f2:	05 8e 11 02 00       	add    $0x2118e,%eax
    pmm_manager->init_memmap(base, n);
c01087f7:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c01087fd:	8b 00                	mov    (%eax),%eax
c01087ff:	8b 40 08             	mov    0x8(%eax),%eax
c0108802:	83 ec 08             	sub    $0x8,%esp
c0108805:	ff 75 0c             	pushl  0xc(%ebp)
c0108808:	ff 75 08             	pushl  0x8(%ebp)
c010880b:	ff d0                	call   *%eax
c010880d:	83 c4 10             	add    $0x10,%esp
}
c0108810:	90                   	nop
c0108811:	c9                   	leave  
c0108812:	c3                   	ret    

c0108813 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0108813:	55                   	push   %ebp
c0108814:	89 e5                	mov    %esp,%ebp
c0108816:	53                   	push   %ebx
c0108817:	83 ec 14             	sub    $0x14,%esp
c010881a:	e8 a2 7a ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010881f:	81 c3 61 11 02 00    	add    $0x21161,%ebx
    struct Page *page=NULL;
c0108825:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010882c:	e8 99 fd ff ff       	call   c01085ca <__intr_save>
c0108831:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0108834:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c010883a:	8b 00                	mov    (%eax),%eax
c010883c:	8b 40 0c             	mov    0xc(%eax),%eax
c010883f:	83 ec 0c             	sub    $0xc,%esp
c0108842:	ff 75 08             	pushl  0x8(%ebp)
c0108845:	ff d0                	call   *%eax
c0108847:	83 c4 10             	add    $0x10,%esp
c010884a:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c010884d:	83 ec 0c             	sub    $0xc,%esp
c0108850:	ff 75 f0             	pushl  -0x10(%ebp)
c0108853:	e8 ae fd ff ff       	call   c0108606 <__intr_restore>
c0108858:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010885b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010885f:	75 2e                	jne    c010888f <alloc_pages+0x7c>
c0108861:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0108865:	77 28                	ja     c010888f <alloc_pages+0x7c>
c0108867:	c7 c0 ac aa 12 c0    	mov    $0xc012aaac,%eax
c010886d:	8b 00                	mov    (%eax),%eax
c010886f:	85 c0                	test   %eax,%eax
c0108871:	74 1c                	je     c010888f <alloc_pages+0x7c>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0108873:	8b 55 08             	mov    0x8(%ebp),%edx
c0108876:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c010887c:	8b 00                	mov    (%eax),%eax
c010887e:	83 ec 04             	sub    $0x4,%esp
c0108881:	6a 00                	push   $0x0
c0108883:	52                   	push   %edx
c0108884:	50                   	push   %eax
c0108885:	e8 c9 df ff ff       	call   c0106853 <swap_out>
c010888a:	83 c4 10             	add    $0x10,%esp
    {
c010888d:	eb 9d                	jmp    c010882c <alloc_pages+0x19>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010888f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108895:	c9                   	leave  
c0108896:	c3                   	ret    

c0108897 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0108897:	55                   	push   %ebp
c0108898:	89 e5                	mov    %esp,%ebp
c010889a:	53                   	push   %ebx
c010889b:	83 ec 14             	sub    $0x14,%esp
c010889e:	e8 1e 7a ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01088a3:	81 c3 dd 10 02 00    	add    $0x210dd,%ebx
    bool intr_flag;
    local_intr_save(intr_flag);
c01088a9:	e8 1c fd ff ff       	call   c01085ca <__intr_save>
c01088ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01088b1:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c01088b7:	8b 00                	mov    (%eax),%eax
c01088b9:	8b 40 10             	mov    0x10(%eax),%eax
c01088bc:	83 ec 08             	sub    $0x8,%esp
c01088bf:	ff 75 0c             	pushl  0xc(%ebp)
c01088c2:	ff 75 08             	pushl  0x8(%ebp)
c01088c5:	ff d0                	call   *%eax
c01088c7:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01088ca:	83 ec 0c             	sub    $0xc,%esp
c01088cd:	ff 75 f4             	pushl  -0xc(%ebp)
c01088d0:	e8 31 fd ff ff       	call   c0108606 <__intr_restore>
c01088d5:	83 c4 10             	add    $0x10,%esp
}
c01088d8:	90                   	nop
c01088d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01088dc:	c9                   	leave  
c01088dd:	c3                   	ret    

c01088de <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01088de:	55                   	push   %ebp
c01088df:	89 e5                	mov    %esp,%ebp
c01088e1:	53                   	push   %ebx
c01088e2:	83 ec 14             	sub    $0x14,%esp
c01088e5:	e8 d7 79 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c01088ea:	81 c3 96 10 02 00    	add    $0x21096,%ebx
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01088f0:	e8 d5 fc ff ff       	call   c01085ca <__intr_save>
c01088f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01088f8:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c01088fe:	8b 00                	mov    (%eax),%eax
c0108900:	8b 40 14             	mov    0x14(%eax),%eax
c0108903:	ff d0                	call   *%eax
c0108905:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0108908:	83 ec 0c             	sub    $0xc,%esp
c010890b:	ff 75 f4             	pushl  -0xc(%ebp)
c010890e:	e8 f3 fc ff ff       	call   c0108606 <__intr_restore>
c0108913:	83 c4 10             	add    $0x10,%esp
    return ret;
c0108916:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0108919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010891c:	c9                   	leave  
c010891d:	c3                   	ret    

c010891e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010891e:	55                   	push   %ebp
c010891f:	89 e5                	mov    %esp,%ebp
c0108921:	57                   	push   %edi
c0108922:	56                   	push   %esi
c0108923:	53                   	push   %ebx
c0108924:	83 ec 7c             	sub    $0x7c,%esp
c0108927:	e8 2c 17 00 00       	call   c010a058 <__x86.get_pc_thunk.si>
c010892c:	81 c6 54 10 02 00    	add    $0x21054,%esi
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0108932:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0108939:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0108940:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0108947:	83 ec 0c             	sub    $0xc,%esp
c010894a:	8d 86 37 3d fe ff    	lea    -0x1c2c9(%esi),%eax
c0108950:	50                   	push   %eax
c0108951:	89 f3                	mov    %esi,%ebx
c0108953:	e8 dc 79 ff ff       	call   c0100334 <cprintf>
c0108958:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010895b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108962:	e9 02 01 00 00       	jmp    c0108a69 <page_init+0x14b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0108967:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010896a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010896d:	89 d0                	mov    %edx,%eax
c010896f:	c1 e0 02             	shl    $0x2,%eax
c0108972:	01 d0                	add    %edx,%eax
c0108974:	c1 e0 02             	shl    $0x2,%eax
c0108977:	01 c8                	add    %ecx,%eax
c0108979:	8b 50 08             	mov    0x8(%eax),%edx
c010897c:	8b 40 04             	mov    0x4(%eax),%eax
c010897f:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0108982:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0108985:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0108988:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010898b:	89 d0                	mov    %edx,%eax
c010898d:	c1 e0 02             	shl    $0x2,%eax
c0108990:	01 d0                	add    %edx,%eax
c0108992:	c1 e0 02             	shl    $0x2,%eax
c0108995:	01 c8                	add    %ecx,%eax
c0108997:	8b 48 0c             	mov    0xc(%eax),%ecx
c010899a:	8b 58 10             	mov    0x10(%eax),%ebx
c010899d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01089a0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01089a3:	01 c8                	add    %ecx,%eax
c01089a5:	11 da                	adc    %ebx,%edx
c01089a7:	89 45 98             	mov    %eax,-0x68(%ebp)
c01089aa:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01089ad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01089b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01089b3:	89 d0                	mov    %edx,%eax
c01089b5:	c1 e0 02             	shl    $0x2,%eax
c01089b8:	01 d0                	add    %edx,%eax
c01089ba:	c1 e0 02             	shl    $0x2,%eax
c01089bd:	01 c8                	add    %ecx,%eax
c01089bf:	83 c0 14             	add    $0x14,%eax
c01089c2:	8b 00                	mov    (%eax),%eax
c01089c4:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01089ca:	8b 45 98             	mov    -0x68(%ebp),%eax
c01089cd:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01089d0:	83 c0 ff             	add    $0xffffffff,%eax
c01089d3:	83 d2 ff             	adc    $0xffffffff,%edx
c01089d6:	89 c1                	mov    %eax,%ecx
c01089d8:	89 d3                	mov    %edx,%ebx
c01089da:	8b 7d c4             	mov    -0x3c(%ebp),%edi
c01089dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01089e0:	89 d0                	mov    %edx,%eax
c01089e2:	c1 e0 02             	shl    $0x2,%eax
c01089e5:	01 d0                	add    %edx,%eax
c01089e7:	c1 e0 02             	shl    $0x2,%eax
c01089ea:	01 f8                	add    %edi,%eax
c01089ec:	8b 50 10             	mov    0x10(%eax),%edx
c01089ef:	8b 40 0c             	mov    0xc(%eax),%eax
c01089f2:	ff b5 7c ff ff ff    	pushl  -0x84(%ebp)
c01089f8:	53                   	push   %ebx
c01089f9:	51                   	push   %ecx
c01089fa:	ff 75 a4             	pushl  -0x5c(%ebp)
c01089fd:	ff 75 a0             	pushl  -0x60(%ebp)
c0108a00:	52                   	push   %edx
c0108a01:	50                   	push   %eax
c0108a02:	8d 86 44 3d fe ff    	lea    -0x1c2bc(%esi),%eax
c0108a08:	50                   	push   %eax
c0108a09:	89 f3                	mov    %esi,%ebx
c0108a0b:	e8 24 79 ff ff       	call   c0100334 <cprintf>
c0108a10:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0108a13:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0108a16:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108a19:	89 d0                	mov    %edx,%eax
c0108a1b:	c1 e0 02             	shl    $0x2,%eax
c0108a1e:	01 d0                	add    %edx,%eax
c0108a20:	c1 e0 02             	shl    $0x2,%eax
c0108a23:	01 c8                	add    %ecx,%eax
c0108a25:	83 c0 14             	add    $0x14,%eax
c0108a28:	8b 00                	mov    (%eax),%eax
c0108a2a:	83 f8 01             	cmp    $0x1,%eax
c0108a2d:	75 36                	jne    c0108a65 <page_init+0x147>
            if (maxpa < end && begin < KMEMSIZE) {
c0108a2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108a35:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0108a38:	77 2b                	ja     c0108a65 <page_init+0x147>
c0108a3a:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0108a3d:	72 05                	jb     c0108a44 <page_init+0x126>
c0108a3f:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0108a42:	73 21                	jae    c0108a65 <page_init+0x147>
c0108a44:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0108a48:	77 1b                	ja     c0108a65 <page_init+0x147>
c0108a4a:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0108a4e:	72 09                	jb     c0108a59 <page_init+0x13b>
c0108a50:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0108a57:	77 0c                	ja     c0108a65 <page_init+0x147>
                maxpa = end;
c0108a59:	8b 45 98             	mov    -0x68(%ebp),%eax
c0108a5c:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0108a5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108a62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0108a65:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0108a69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108a6c:	8b 00                	mov    (%eax),%eax
c0108a6e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0108a71:	0f 8c f0 fe ff ff    	jl     c0108967 <page_init+0x49>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0108a77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108a7b:	72 1d                	jb     c0108a9a <page_init+0x17c>
c0108a7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108a81:	77 09                	ja     c0108a8c <page_init+0x16e>
c0108a83:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0108a8a:	76 0e                	jbe    c0108a9a <page_init+0x17c>
        maxpa = KMEMSIZE;
c0108a8c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0108a93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0108a9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108aa0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108aa4:	c1 ea 0c             	shr    $0xc,%edx
c0108aa7:	89 c1                	mov    %eax,%ecx
c0108aa9:	89 d3                	mov    %edx,%ebx
c0108aab:	89 c8                	mov    %ecx,%eax
c0108aad:	89 86 40 11 00 00    	mov    %eax,0x1140(%esi)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0108ab3:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0108aba:	c7 c0 a4 cc 12 c0    	mov    $0xc012cca4,%eax
c0108ac0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108ac3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108ac6:	01 d0                	add    %edx,%eax
c0108ac8:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0108acb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108ace:	ba 00 00 00 00       	mov    $0x0,%edx
c0108ad3:	f7 75 c0             	divl   -0x40(%ebp)
c0108ad6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108ad9:	29 d0                	sub    %edx,%eax
c0108adb:	89 c2                	mov    %eax,%edx
c0108add:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0108ae3:	89 10                	mov    %edx,(%eax)

    for (i = 0; i < npage; i ++) {
c0108ae5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108aec:	eb 31                	jmp    c0108b1f <page_init+0x201>
        SetPageReserved(pages + i);
c0108aee:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0108af4:	8b 08                	mov    (%eax),%ecx
c0108af6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108af9:	89 d0                	mov    %edx,%eax
c0108afb:	c1 e0 03             	shl    $0x3,%eax
c0108afe:	01 d0                	add    %edx,%eax
c0108b00:	c1 e0 02             	shl    $0x2,%eax
c0108b03:	01 c8                	add    %ecx,%eax
c0108b05:	83 c0 04             	add    $0x4,%eax
c0108b08:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0108b0f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108b12:	8b 45 90             	mov    -0x70(%ebp),%eax
c0108b15:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0108b18:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0108b1b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0108b1f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108b22:	8b 86 40 11 00 00    	mov    0x1140(%esi),%eax
c0108b28:	39 c2                	cmp    %eax,%edx
c0108b2a:	72 c2                	jb     c0108aee <page_init+0x1d0>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0108b2c:	8b 96 40 11 00 00    	mov    0x1140(%esi),%edx
c0108b32:	89 d0                	mov    %edx,%eax
c0108b34:	c1 e0 03             	shl    $0x3,%eax
c0108b37:	01 d0                	add    %edx,%eax
c0108b39:	c1 e0 02             	shl    $0x2,%eax
c0108b3c:	89 c2                	mov    %eax,%edx
c0108b3e:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c0108b44:	8b 00                	mov    (%eax),%eax
c0108b46:	01 d0                	add    %edx,%eax
c0108b48:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0108b4b:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0108b52:	77 1d                	ja     c0108b71 <page_init+0x253>
c0108b54:	ff 75 b8             	pushl  -0x48(%ebp)
c0108b57:	8d 86 74 3d fe ff    	lea    -0x1c28c(%esi),%eax
c0108b5d:	50                   	push   %eax
c0108b5e:	68 e9 00 00 00       	push   $0xe9
c0108b63:	8d 86 98 3d fe ff    	lea    -0x1c268(%esi),%eax
c0108b69:	50                   	push   %eax
c0108b6a:	89 f3                	mov    %esi,%ebx
c0108b6c:	e8 a1 8e ff ff       	call   c0101a12 <__panic>
c0108b71:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0108b74:	05 00 00 00 40       	add    $0x40000000,%eax
c0108b79:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0108b7c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108b83:	e9 79 01 00 00       	jmp    c0108d01 <page_init+0x3e3>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0108b88:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0108b8b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108b8e:	89 d0                	mov    %edx,%eax
c0108b90:	c1 e0 02             	shl    $0x2,%eax
c0108b93:	01 d0                	add    %edx,%eax
c0108b95:	c1 e0 02             	shl    $0x2,%eax
c0108b98:	01 c8                	add    %ecx,%eax
c0108b9a:	8b 50 08             	mov    0x8(%eax),%edx
c0108b9d:	8b 40 04             	mov    0x4(%eax),%eax
c0108ba0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108ba3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108ba6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0108ba9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108bac:	89 d0                	mov    %edx,%eax
c0108bae:	c1 e0 02             	shl    $0x2,%eax
c0108bb1:	01 d0                	add    %edx,%eax
c0108bb3:	c1 e0 02             	shl    $0x2,%eax
c0108bb6:	01 c8                	add    %ecx,%eax
c0108bb8:	8b 48 0c             	mov    0xc(%eax),%ecx
c0108bbb:	8b 58 10             	mov    0x10(%eax),%ebx
c0108bbe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108bc1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108bc4:	01 c8                	add    %ecx,%eax
c0108bc6:	11 da                	adc    %ebx,%edx
c0108bc8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0108bcb:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0108bce:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0108bd1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108bd4:	89 d0                	mov    %edx,%eax
c0108bd6:	c1 e0 02             	shl    $0x2,%eax
c0108bd9:	01 d0                	add    %edx,%eax
c0108bdb:	c1 e0 02             	shl    $0x2,%eax
c0108bde:	01 c8                	add    %ecx,%eax
c0108be0:	83 c0 14             	add    $0x14,%eax
c0108be3:	8b 00                	mov    (%eax),%eax
c0108be5:	83 f8 01             	cmp    $0x1,%eax
c0108be8:	0f 85 0f 01 00 00    	jne    c0108cfd <page_init+0x3df>
            if (begin < freemem) {
c0108bee:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108bf1:	ba 00 00 00 00       	mov    $0x0,%edx
c0108bf6:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0108bf9:	77 17                	ja     c0108c12 <page_init+0x2f4>
c0108bfb:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0108bfe:	72 05                	jb     c0108c05 <page_init+0x2e7>
c0108c00:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0108c03:	73 0d                	jae    c0108c12 <page_init+0x2f4>
                begin = freemem;
c0108c05:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108c08:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108c0b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0108c12:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108c16:	72 1d                	jb     c0108c35 <page_init+0x317>
c0108c18:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108c1c:	77 09                	ja     c0108c27 <page_init+0x309>
c0108c1e:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0108c25:	76 0e                	jbe    c0108c35 <page_init+0x317>
                end = KMEMSIZE;
c0108c27:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0108c2e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0108c35:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108c38:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108c3b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0108c3e:	0f 87 b9 00 00 00    	ja     c0108cfd <page_init+0x3df>
c0108c44:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0108c47:	72 09                	jb     c0108c52 <page_init+0x334>
c0108c49:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0108c4c:	0f 83 ab 00 00 00    	jae    c0108cfd <page_init+0x3df>
                begin = ROUNDUP(begin, PGSIZE);
c0108c52:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0108c59:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108c5c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108c5f:	01 d0                	add    %edx,%eax
c0108c61:	83 e8 01             	sub    $0x1,%eax
c0108c64:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0108c67:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0108c6a:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c6f:	f7 75 b0             	divl   -0x50(%ebp)
c0108c72:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0108c75:	29 d0                	sub    %edx,%eax
c0108c77:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c7c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108c7f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0108c82:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108c85:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0108c88:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108c8b:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c90:	89 c7                	mov    %eax,%edi
c0108c92:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0108c98:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0108c9b:	89 d0                	mov    %edx,%eax
c0108c9d:	83 e0 00             	and    $0x0,%eax
c0108ca0:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0108ca3:	8b 45 80             	mov    -0x80(%ebp),%eax
c0108ca6:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0108ca9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0108cac:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0108caf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108cb2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108cb5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0108cb8:	77 43                	ja     c0108cfd <page_init+0x3df>
c0108cba:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0108cbd:	72 05                	jb     c0108cc4 <page_init+0x3a6>
c0108cbf:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0108cc2:	73 39                	jae    c0108cfd <page_init+0x3df>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0108cc4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108cc7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0108cca:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0108ccd:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0108cd0:	89 c3                	mov    %eax,%ebx
c0108cd2:	89 d6                	mov    %edx,%esi
c0108cd4:	89 d8                	mov    %ebx,%eax
c0108cd6:	89 f2                	mov    %esi,%edx
c0108cd8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108cdc:	c1 ea 0c             	shr    $0xc,%edx
c0108cdf:	89 c3                	mov    %eax,%ebx
c0108ce1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108ce4:	83 ec 0c             	sub    $0xc,%esp
c0108ce7:	50                   	push   %eax
c0108ce8:	e8 6a f7 ff ff       	call   c0108457 <pa2page>
c0108ced:	83 c4 10             	add    $0x10,%esp
c0108cf0:	83 ec 08             	sub    $0x8,%esp
c0108cf3:	53                   	push   %ebx
c0108cf4:	50                   	push   %eax
c0108cf5:	e8 ed fa ff ff       	call   c01087e7 <init_memmap>
c0108cfa:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < memmap->nr_map; i ++) {
c0108cfd:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0108d01:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108d04:	8b 00                	mov    (%eax),%eax
c0108d06:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0108d09:	0f 8c 79 fe ff ff    	jl     c0108b88 <page_init+0x26a>
                }
            }
        }
    }
}
c0108d0f:	90                   	nop
c0108d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0108d13:	5b                   	pop    %ebx
c0108d14:	5e                   	pop    %esi
c0108d15:	5f                   	pop    %edi
c0108d16:	5d                   	pop    %ebp
c0108d17:	c3                   	ret    

c0108d18 <enable_paging>:

static void
enable_paging(void) {
c0108d18:	55                   	push   %ebp
c0108d19:	89 e5                	mov    %esp,%ebp
c0108d1b:	83 ec 10             	sub    $0x10,%esp
c0108d1e:	e8 9a 75 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0108d23:	05 5d 0c 02 00       	add    $0x20c5d,%eax
    lcr3(boot_cr3);
c0108d28:	c7 c0 94 cc 12 c0    	mov    $0xc012cc94,%eax
c0108d2e:	8b 00                	mov    (%eax),%eax
c0108d30:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d36:	0f 22 d8             	mov    %eax,%cr3
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c0108d39:	0f 20 c0             	mov    %cr0,%eax
c0108d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c0108d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c0108d42:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c0108d45:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c0108d4c:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c0108d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d53:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c0108d56:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108d59:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c0108d5c:	90                   	nop
c0108d5d:	c9                   	leave  
c0108d5e:	c3                   	ret    

c0108d5f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0108d5f:	55                   	push   %ebp
c0108d60:	89 e5                	mov    %esp,%ebp
c0108d62:	53                   	push   %ebx
c0108d63:	83 ec 24             	sub    $0x24,%esp
c0108d66:	e8 56 75 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0108d6b:	81 c3 15 0c 02 00    	add    $0x20c15,%ebx
    assert(PGOFF(la) == PGOFF(pa));
c0108d71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d74:	33 45 14             	xor    0x14(%ebp),%eax
c0108d77:	25 ff 0f 00 00       	and    $0xfff,%eax
c0108d7c:	85 c0                	test   %eax,%eax
c0108d7e:	74 1f                	je     c0108d9f <boot_map_segment+0x40>
c0108d80:	8d 83 a6 3d fe ff    	lea    -0x1c25a(%ebx),%eax
c0108d86:	50                   	push   %eax
c0108d87:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0108d8d:	50                   	push   %eax
c0108d8e:	68 12 01 00 00       	push   $0x112
c0108d93:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0108d99:	50                   	push   %eax
c0108d9a:	e8 73 8c ff ff       	call   c0101a12 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0108d9f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0108da6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108da9:	25 ff 0f 00 00       	and    $0xfff,%eax
c0108dae:	89 c2                	mov    %eax,%edx
c0108db0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108db3:	01 c2                	add    %eax,%edx
c0108db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108db8:	01 d0                	add    %edx,%eax
c0108dba:	83 e8 01             	sub    $0x1,%eax
c0108dbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108dc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108dc3:	ba 00 00 00 00       	mov    $0x0,%edx
c0108dc8:	f7 75 f0             	divl   -0x10(%ebp)
c0108dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108dce:	29 d0                	sub    %edx,%eax
c0108dd0:	c1 e8 0c             	shr    $0xc,%eax
c0108dd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0108dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108ddc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ddf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108de4:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0108de7:	8b 45 14             	mov    0x14(%ebp),%eax
c0108dea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108ded:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108df0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108df5:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0108df8:	eb 5d                	jmp    c0108e57 <boot_map_segment+0xf8>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0108dfa:	83 ec 04             	sub    $0x4,%esp
c0108dfd:	6a 01                	push   $0x1
c0108dff:	ff 75 0c             	pushl  0xc(%ebp)
c0108e02:	ff 75 08             	pushl  0x8(%ebp)
c0108e05:	e8 dc 01 00 00       	call   c0108fe6 <get_pte>
c0108e0a:	83 c4 10             	add    $0x10,%esp
c0108e0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0108e10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108e14:	75 1f                	jne    c0108e35 <boot_map_segment+0xd6>
c0108e16:	8d 83 d2 3d fe ff    	lea    -0x1c22e(%ebx),%eax
c0108e1c:	50                   	push   %eax
c0108e1d:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0108e23:	50                   	push   %eax
c0108e24:	68 18 01 00 00       	push   $0x118
c0108e29:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0108e2f:	50                   	push   %eax
c0108e30:	e8 dd 8b ff ff       	call   c0101a12 <__panic>
        *ptep = pa | PTE_P | perm;
c0108e35:	8b 45 14             	mov    0x14(%ebp),%eax
c0108e38:	0b 45 18             	or     0x18(%ebp),%eax
c0108e3b:	83 c8 01             	or     $0x1,%eax
c0108e3e:	89 c2                	mov    %eax,%edx
c0108e40:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108e43:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0108e45:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108e49:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0108e50:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0108e57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108e5b:	75 9d                	jne    c0108dfa <boot_map_segment+0x9b>
    }
}
c0108e5d:	90                   	nop
c0108e5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108e61:	c9                   	leave  
c0108e62:	c3                   	ret    

c0108e63 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0108e63:	55                   	push   %ebp
c0108e64:	89 e5                	mov    %esp,%ebp
c0108e66:	53                   	push   %ebx
c0108e67:	83 ec 14             	sub    $0x14,%esp
c0108e6a:	e8 52 74 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0108e6f:	81 c3 11 0b 02 00    	add    $0x20b11,%ebx
    struct Page *p = alloc_page();
c0108e75:	83 ec 0c             	sub    $0xc,%esp
c0108e78:	6a 01                	push   $0x1
c0108e7a:	e8 94 f9 ff ff       	call   c0108813 <alloc_pages>
c0108e7f:	83 c4 10             	add    $0x10,%esp
c0108e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0108e85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108e89:	75 1b                	jne    c0108ea6 <boot_alloc_page+0x43>
        panic("boot_alloc_page failed.\n");
c0108e8b:	83 ec 04             	sub    $0x4,%esp
c0108e8e:	8d 83 df 3d fe ff    	lea    -0x1c221(%ebx),%eax
c0108e94:	50                   	push   %eax
c0108e95:	68 24 01 00 00       	push   $0x124
c0108e9a:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0108ea0:	50                   	push   %eax
c0108ea1:	e8 6c 8b ff ff       	call   c0101a12 <__panic>
    }
    return page2kva(p);
c0108ea6:	83 ec 0c             	sub    $0xc,%esp
c0108ea9:	ff 75 f4             	pushl  -0xc(%ebp)
c0108eac:	e8 04 f6 ff ff       	call   c01084b5 <page2kva>
c0108eb1:	83 c4 10             	add    $0x10,%esp
}
c0108eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108eb7:	c9                   	leave  
c0108eb8:	c3                   	ret    

c0108eb9 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0108eb9:	55                   	push   %ebp
c0108eba:	89 e5                	mov    %esp,%ebp
c0108ebc:	53                   	push   %ebx
c0108ebd:	83 ec 14             	sub    $0x14,%esp
c0108ec0:	e8 fc 73 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0108ec5:	81 c3 bb 0a 02 00    	add    $0x20abb,%ebx
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0108ecb:	e8 c7 f8 ff ff       	call   c0108797 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0108ed0:	e8 49 fa ff ff       	call   c010891e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0108ed5:	e8 3e 05 00 00       	call   c0109418 <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c0108eda:	e8 84 ff ff ff       	call   c0108e63 <boot_alloc_page>
c0108edf:	89 83 44 11 00 00    	mov    %eax,0x1144(%ebx)
    memset(boot_pgdir, 0, PGSIZE);
c0108ee5:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108eeb:	83 ec 04             	sub    $0x4,%esp
c0108eee:	68 00 10 00 00       	push   $0x1000
c0108ef3:	6a 00                	push   $0x0
c0108ef5:	50                   	push   %eax
c0108ef6:	e8 b1 24 00 00       	call   c010b3ac <memset>
c0108efb:	83 c4 10             	add    $0x10,%esp
    boot_cr3 = PADDR(boot_pgdir);
c0108efe:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f07:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0108f0e:	77 1b                	ja     c0108f2b <pmm_init+0x72>
c0108f10:	ff 75 f4             	pushl  -0xc(%ebp)
c0108f13:	8d 83 74 3d fe ff    	lea    -0x1c28c(%ebx),%eax
c0108f19:	50                   	push   %eax
c0108f1a:	68 3e 01 00 00       	push   $0x13e
c0108f1f:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0108f25:	50                   	push   %eax
c0108f26:	e8 e7 8a ff ff       	call   c0101a12 <__panic>
c0108f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f2e:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0108f34:	c7 c0 94 cc 12 c0    	mov    $0xc012cc94,%eax
c0108f3a:	89 10                	mov    %edx,(%eax)

    check_pgdir();
c0108f3c:	e8 0e 05 00 00       	call   c010944f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0108f41:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108f47:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f4a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108f51:	77 1b                	ja     c0108f6e <pmm_init+0xb5>
c0108f53:	ff 75 f0             	pushl  -0x10(%ebp)
c0108f56:	8d 83 74 3d fe ff    	lea    -0x1c28c(%ebx),%eax
c0108f5c:	50                   	push   %eax
c0108f5d:	68 46 01 00 00       	push   $0x146
c0108f62:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0108f68:	50                   	push   %eax
c0108f69:	e8 a4 8a ff ff       	call   c0101a12 <__panic>
c0108f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f71:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0108f77:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108f7d:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108f82:	83 ca 03             	or     $0x3,%edx
c0108f85:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0108f87:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108f8d:	83 ec 0c             	sub    $0xc,%esp
c0108f90:	6a 02                	push   $0x2
c0108f92:	6a 00                	push   $0x0
c0108f94:	68 00 00 00 38       	push   $0x38000000
c0108f99:	68 00 00 00 c0       	push   $0xc0000000
c0108f9e:	50                   	push   %eax
c0108f9f:	e8 bb fd ff ff       	call   c0108d5f <boot_map_segment>
c0108fa4:	83 c4 20             	add    $0x20,%esp

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c0108fa7:	8b 93 44 11 00 00    	mov    0x1144(%ebx),%edx
c0108fad:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108fb3:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c0108fb9:	89 10                	mov    %edx,(%eax)

    enable_paging();
c0108fbb:	e8 58 fd ff ff       	call   c0108d18 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0108fc0:	e8 bf f6 ff ff       	call   c0108684 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c0108fc5:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0108fcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0108fd1:	e8 9d 0a 00 00       	call   c0109a73 <check_boot_pgdir>

    print_pgdir();
c0108fd6:	e8 10 0f 00 00       	call   c0109eeb <print_pgdir>
    
    kmalloc_init();
c0108fdb:	e8 69 d3 ff ff       	call   c0106349 <kmalloc_init>

}
c0108fe0:	90                   	nop
c0108fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108fe4:	c9                   	leave  
c0108fe5:	c3                   	ret    

c0108fe6 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0108fe6:	55                   	push   %ebp
c0108fe7:	89 e5                	mov    %esp,%ebp
c0108fe9:	53                   	push   %ebx
c0108fea:	83 ec 24             	sub    $0x24,%esp
c0108fed:	e8 cf 72 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0108ff2:	81 c3 8e 09 02 00    	add    $0x2098e,%ebx
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0108ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ffb:	c1 e8 16             	shr    $0x16,%eax
c0108ffe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0109005:	8b 45 08             	mov    0x8(%ebp),%eax
c0109008:	01 d0                	add    %edx,%eax
c010900a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c010900d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109010:	8b 00                	mov    (%eax),%eax
c0109012:	83 e0 01             	and    $0x1,%eax
c0109015:	85 c0                	test   %eax,%eax
c0109017:	0f 85 a4 00 00 00    	jne    c01090c1 <get_pte+0xdb>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010901d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109021:	74 16                	je     c0109039 <get_pte+0x53>
c0109023:	83 ec 0c             	sub    $0xc,%esp
c0109026:	6a 01                	push   $0x1
c0109028:	e8 e6 f7 ff ff       	call   c0108813 <alloc_pages>
c010902d:	83 c4 10             	add    $0x10,%esp
c0109030:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109033:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109037:	75 0a                	jne    c0109043 <get_pte+0x5d>
            return NULL;
c0109039:	b8 00 00 00 00       	mov    $0x0,%eax
c010903e:	e9 d4 00 00 00       	jmp    c0109117 <get_pte+0x131>
        }
        set_page_ref(page, 1);
c0109043:	83 ec 08             	sub    $0x8,%esp
c0109046:	6a 01                	push   $0x1
c0109048:	ff 75 f0             	pushl  -0x10(%ebp)
c010904b:	e8 20 f5 ff ff       	call   c0108570 <set_page_ref>
c0109050:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c0109053:	83 ec 0c             	sub    $0xc,%esp
c0109056:	ff 75 f0             	pushl  -0x10(%ebp)
c0109059:	e8 dc f3 ff ff       	call   c010843a <page2pa>
c010905e:	83 c4 10             	add    $0x10,%esp
c0109061:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0109064:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109067:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010906a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010906d:	c1 e8 0c             	shr    $0xc,%eax
c0109070:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109073:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c0109079:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010907c:	72 1b                	jb     c0109099 <get_pte+0xb3>
c010907e:	ff 75 e8             	pushl  -0x18(%ebp)
c0109081:	8d 83 d0 3c fe ff    	lea    -0x1c330(%ebx),%eax
c0109087:	50                   	push   %eax
c0109088:	68 97 01 00 00       	push   $0x197
c010908d:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109093:	50                   	push   %eax
c0109094:	e8 79 89 ff ff       	call   c0101a12 <__panic>
c0109099:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010909c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01090a1:	83 ec 04             	sub    $0x4,%esp
c01090a4:	68 00 10 00 00       	push   $0x1000
c01090a9:	6a 00                	push   $0x0
c01090ab:	50                   	push   %eax
c01090ac:	e8 fb 22 00 00       	call   c010b3ac <memset>
c01090b1:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c01090b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090b7:	83 c8 07             	or     $0x7,%eax
c01090ba:	89 c2                	mov    %eax,%edx
c01090bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090bf:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01090c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090c4:	8b 00                	mov    (%eax),%eax
c01090c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01090cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01090ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01090d1:	c1 e8 0c             	shr    $0xc,%eax
c01090d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01090d7:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c01090dd:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01090e0:	72 1b                	jb     c01090fd <get_pte+0x117>
c01090e2:	ff 75 e0             	pushl  -0x20(%ebp)
c01090e5:	8d 83 d0 3c fe ff    	lea    -0x1c330(%ebx),%eax
c01090eb:	50                   	push   %eax
c01090ec:	68 9a 01 00 00       	push   $0x19a
c01090f1:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01090f7:	50                   	push   %eax
c01090f8:	e8 15 89 ff ff       	call   c0101a12 <__panic>
c01090fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109100:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0109105:	89 c2                	mov    %eax,%edx
c0109107:	8b 45 0c             	mov    0xc(%ebp),%eax
c010910a:	c1 e8 0c             	shr    $0xc,%eax
c010910d:	25 ff 03 00 00       	and    $0x3ff,%eax
c0109112:	c1 e0 02             	shl    $0x2,%eax
c0109115:	01 d0                	add    %edx,%eax
}
c0109117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010911a:	c9                   	leave  
c010911b:	c3                   	ret    

c010911c <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010911c:	55                   	push   %ebp
c010911d:	89 e5                	mov    %esp,%ebp
c010911f:	83 ec 18             	sub    $0x18,%esp
c0109122:	e8 96 71 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0109127:	05 59 08 02 00       	add    $0x20859,%eax
    pte_t *ptep = get_pte(pgdir, la, 0);
c010912c:	83 ec 04             	sub    $0x4,%esp
c010912f:	6a 00                	push   $0x0
c0109131:	ff 75 0c             	pushl  0xc(%ebp)
c0109134:	ff 75 08             	pushl  0x8(%ebp)
c0109137:	e8 aa fe ff ff       	call   c0108fe6 <get_pte>
c010913c:	83 c4 10             	add    $0x10,%esp
c010913f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0109142:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109146:	74 08                	je     c0109150 <get_page+0x34>
        *ptep_store = ptep;
c0109148:	8b 45 10             	mov    0x10(%ebp),%eax
c010914b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010914e:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0109150:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109154:	74 1f                	je     c0109175 <get_page+0x59>
c0109156:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109159:	8b 00                	mov    (%eax),%eax
c010915b:	83 e0 01             	and    $0x1,%eax
c010915e:	85 c0                	test   %eax,%eax
c0109160:	74 13                	je     c0109175 <get_page+0x59>
        return pa2page(*ptep);
c0109162:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109165:	8b 00                	mov    (%eax),%eax
c0109167:	83 ec 0c             	sub    $0xc,%esp
c010916a:	50                   	push   %eax
c010916b:	e8 e7 f2 ff ff       	call   c0108457 <pa2page>
c0109170:	83 c4 10             	add    $0x10,%esp
c0109173:	eb 05                	jmp    c010917a <get_page+0x5e>
    }
    return NULL;
c0109175:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010917a:	c9                   	leave  
c010917b:	c3                   	ret    

c010917c <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010917c:	55                   	push   %ebp
c010917d:	89 e5                	mov    %esp,%ebp
c010917f:	83 ec 18             	sub    $0x18,%esp
c0109182:	e8 36 71 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0109187:	05 f9 07 02 00       	add    $0x207f9,%eax
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010918c:	8b 45 10             	mov    0x10(%ebp),%eax
c010918f:	8b 00                	mov    (%eax),%eax
c0109191:	83 e0 01             	and    $0x1,%eax
c0109194:	85 c0                	test   %eax,%eax
c0109196:	74 50                	je     c01091e8 <page_remove_pte+0x6c>
        struct Page *page = pte2page(*ptep);
c0109198:	8b 45 10             	mov    0x10(%ebp),%eax
c010919b:	8b 00                	mov    (%eax),%eax
c010919d:	83 ec 0c             	sub    $0xc,%esp
c01091a0:	50                   	push   %eax
c01091a1:	e8 68 f3 ff ff       	call   c010850e <pte2page>
c01091a6:	83 c4 10             	add    $0x10,%esp
c01091a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c01091ac:	83 ec 0c             	sub    $0xc,%esp
c01091af:	ff 75 f4             	pushl  -0xc(%ebp)
c01091b2:	e8 f2 f3 ff ff       	call   c01085a9 <page_ref_dec>
c01091b7:	83 c4 10             	add    $0x10,%esp
c01091ba:	85 c0                	test   %eax,%eax
c01091bc:	75 10                	jne    c01091ce <page_remove_pte+0x52>
            free_page(page);
c01091be:	83 ec 08             	sub    $0x8,%esp
c01091c1:	6a 01                	push   $0x1
c01091c3:	ff 75 f4             	pushl  -0xc(%ebp)
c01091c6:	e8 cc f6 ff ff       	call   c0108897 <free_pages>
c01091cb:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c01091ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01091d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01091d7:	83 ec 08             	sub    $0x8,%esp
c01091da:	ff 75 0c             	pushl  0xc(%ebp)
c01091dd:	ff 75 08             	pushl  0x8(%ebp)
c01091e0:	e8 0c 01 00 00       	call   c01092f1 <tlb_invalidate>
c01091e5:	83 c4 10             	add    $0x10,%esp
    }
}
c01091e8:	90                   	nop
c01091e9:	c9                   	leave  
c01091ea:	c3                   	ret    

c01091eb <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01091eb:	55                   	push   %ebp
c01091ec:	89 e5                	mov    %esp,%ebp
c01091ee:	83 ec 18             	sub    $0x18,%esp
c01091f1:	e8 c7 70 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01091f6:	05 8a 07 02 00       	add    $0x2078a,%eax
    pte_t *ptep = get_pte(pgdir, la, 0);
c01091fb:	83 ec 04             	sub    $0x4,%esp
c01091fe:	6a 00                	push   $0x0
c0109200:	ff 75 0c             	pushl  0xc(%ebp)
c0109203:	ff 75 08             	pushl  0x8(%ebp)
c0109206:	e8 db fd ff ff       	call   c0108fe6 <get_pte>
c010920b:	83 c4 10             	add    $0x10,%esp
c010920e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0109211:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109215:	74 14                	je     c010922b <page_remove+0x40>
        page_remove_pte(pgdir, la, ptep);
c0109217:	83 ec 04             	sub    $0x4,%esp
c010921a:	ff 75 f4             	pushl  -0xc(%ebp)
c010921d:	ff 75 0c             	pushl  0xc(%ebp)
c0109220:	ff 75 08             	pushl  0x8(%ebp)
c0109223:	e8 54 ff ff ff       	call   c010917c <page_remove_pte>
c0109228:	83 c4 10             	add    $0x10,%esp
    }
}
c010922b:	90                   	nop
c010922c:	c9                   	leave  
c010922d:	c3                   	ret    

c010922e <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010922e:	55                   	push   %ebp
c010922f:	89 e5                	mov    %esp,%ebp
c0109231:	83 ec 18             	sub    $0x18,%esp
c0109234:	e8 84 70 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0109239:	05 47 07 02 00       	add    $0x20747,%eax
    pte_t *ptep = get_pte(pgdir, la, 1);
c010923e:	83 ec 04             	sub    $0x4,%esp
c0109241:	6a 01                	push   $0x1
c0109243:	ff 75 10             	pushl  0x10(%ebp)
c0109246:	ff 75 08             	pushl  0x8(%ebp)
c0109249:	e8 98 fd ff ff       	call   c0108fe6 <get_pte>
c010924e:	83 c4 10             	add    $0x10,%esp
c0109251:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0109254:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109258:	75 0a                	jne    c0109264 <page_insert+0x36>
        return -E_NO_MEM;
c010925a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010925f:	e9 8b 00 00 00       	jmp    c01092ef <page_insert+0xc1>
    }
    page_ref_inc(page);
c0109264:	83 ec 0c             	sub    $0xc,%esp
c0109267:	ff 75 0c             	pushl  0xc(%ebp)
c010926a:	e8 19 f3 ff ff       	call   c0108588 <page_ref_inc>
c010926f:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c0109272:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109275:	8b 00                	mov    (%eax),%eax
c0109277:	83 e0 01             	and    $0x1,%eax
c010927a:	85 c0                	test   %eax,%eax
c010927c:	74 40                	je     c01092be <page_insert+0x90>
        struct Page *p = pte2page(*ptep);
c010927e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109281:	8b 00                	mov    (%eax),%eax
c0109283:	83 ec 0c             	sub    $0xc,%esp
c0109286:	50                   	push   %eax
c0109287:	e8 82 f2 ff ff       	call   c010850e <pte2page>
c010928c:	83 c4 10             	add    $0x10,%esp
c010928f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0109292:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109295:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109298:	75 10                	jne    c01092aa <page_insert+0x7c>
            page_ref_dec(page);
c010929a:	83 ec 0c             	sub    $0xc,%esp
c010929d:	ff 75 0c             	pushl  0xc(%ebp)
c01092a0:	e8 04 f3 ff ff       	call   c01085a9 <page_ref_dec>
c01092a5:	83 c4 10             	add    $0x10,%esp
c01092a8:	eb 14                	jmp    c01092be <page_insert+0x90>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01092aa:	83 ec 04             	sub    $0x4,%esp
c01092ad:	ff 75 f4             	pushl  -0xc(%ebp)
c01092b0:	ff 75 10             	pushl  0x10(%ebp)
c01092b3:	ff 75 08             	pushl  0x8(%ebp)
c01092b6:	e8 c1 fe ff ff       	call   c010917c <page_remove_pte>
c01092bb:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01092be:	83 ec 0c             	sub    $0xc,%esp
c01092c1:	ff 75 0c             	pushl  0xc(%ebp)
c01092c4:	e8 71 f1 ff ff       	call   c010843a <page2pa>
c01092c9:	83 c4 10             	add    $0x10,%esp
c01092cc:	0b 45 14             	or     0x14(%ebp),%eax
c01092cf:	83 c8 01             	or     $0x1,%eax
c01092d2:	89 c2                	mov    %eax,%edx
c01092d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092d7:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01092d9:	83 ec 08             	sub    $0x8,%esp
c01092dc:	ff 75 10             	pushl  0x10(%ebp)
c01092df:	ff 75 08             	pushl  0x8(%ebp)
c01092e2:	e8 0a 00 00 00       	call   c01092f1 <tlb_invalidate>
c01092e7:	83 c4 10             	add    $0x10,%esp
    return 0;
c01092ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01092ef:	c9                   	leave  
c01092f0:	c3                   	ret    

c01092f1 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01092f1:	55                   	push   %ebp
c01092f2:	89 e5                	mov    %esp,%ebp
c01092f4:	53                   	push   %ebx
c01092f5:	83 ec 14             	sub    $0x14,%esp
c01092f8:	e8 c0 6f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c01092fd:	05 83 06 02 00       	add    $0x20683,%eax
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0109302:	0f 20 da             	mov    %cr3,%edx
c0109305:	89 55 f0             	mov    %edx,-0x10(%ebp)
    return cr3;
c0109308:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    if (rcr3() == PADDR(pgdir)) {
c010930b:	8b 55 08             	mov    0x8(%ebp),%edx
c010930e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109311:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0109318:	77 1d                	ja     c0109337 <tlb_invalidate+0x46>
c010931a:	ff 75 f4             	pushl  -0xc(%ebp)
c010931d:	8d 90 74 3d fe ff    	lea    -0x1c28c(%eax),%edx
c0109323:	52                   	push   %edx
c0109324:	68 fc 01 00 00       	push   $0x1fc
c0109329:	8d 90 98 3d fe ff    	lea    -0x1c268(%eax),%edx
c010932f:	52                   	push   %edx
c0109330:	89 c3                	mov    %eax,%ebx
c0109332:	e8 db 86 ff ff       	call   c0101a12 <__panic>
c0109337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010933a:	05 00 00 00 40       	add    $0x40000000,%eax
c010933f:	39 c8                	cmp    %ecx,%eax
c0109341:	75 0c                	jne    c010934f <tlb_invalidate+0x5e>
        invlpg((void *)la);
c0109343:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109346:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0109349:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010934c:	0f 01 38             	invlpg (%eax)
    }
}
c010934f:	90                   	nop
c0109350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109353:	c9                   	leave  
c0109354:	c3                   	ret    

c0109355 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0109355:	55                   	push   %ebp
c0109356:	89 e5                	mov    %esp,%ebp
c0109358:	53                   	push   %ebx
c0109359:	83 ec 14             	sub    $0x14,%esp
c010935c:	e8 60 6f ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0109361:	81 c3 1f 06 02 00    	add    $0x2061f,%ebx
    struct Page *page = alloc_page();
c0109367:	83 ec 0c             	sub    $0xc,%esp
c010936a:	6a 01                	push   $0x1
c010936c:	e8 a2 f4 ff ff       	call   c0108813 <alloc_pages>
c0109371:	83 c4 10             	add    $0x10,%esp
c0109374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109377:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010937b:	0f 84 8f 00 00 00    	je     c0109410 <pgdir_alloc_page+0xbb>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0109381:	ff 75 10             	pushl  0x10(%ebp)
c0109384:	ff 75 0c             	pushl  0xc(%ebp)
c0109387:	ff 75 f4             	pushl  -0xc(%ebp)
c010938a:	ff 75 08             	pushl  0x8(%ebp)
c010938d:	e8 9c fe ff ff       	call   c010922e <page_insert>
c0109392:	83 c4 10             	add    $0x10,%esp
c0109395:	85 c0                	test   %eax,%eax
c0109397:	74 17                	je     c01093b0 <pgdir_alloc_page+0x5b>
            free_page(page);
c0109399:	83 ec 08             	sub    $0x8,%esp
c010939c:	6a 01                	push   $0x1
c010939e:	ff 75 f4             	pushl  -0xc(%ebp)
c01093a1:	e8 f1 f4 ff ff       	call   c0108897 <free_pages>
c01093a6:	83 c4 10             	add    $0x10,%esp
            return NULL;
c01093a9:	b8 00 00 00 00       	mov    $0x0,%eax
c01093ae:	eb 63                	jmp    c0109413 <pgdir_alloc_page+0xbe>
        }
        if (swap_init_ok){
c01093b0:	c7 c0 ac aa 12 c0    	mov    $0xc012aaac,%eax
c01093b6:	8b 00                	mov    (%eax),%eax
c01093b8:	85 c0                	test   %eax,%eax
c01093ba:	74 54                	je     c0109410 <pgdir_alloc_page+0xbb>
            swap_map_swappable(check_mm_struct, la, page, 0);
c01093bc:	c7 c0 98 cb 12 c0    	mov    $0xc012cb98,%eax
c01093c2:	8b 00                	mov    (%eax),%eax
c01093c4:	6a 00                	push   $0x0
c01093c6:	ff 75 f4             	pushl  -0xc(%ebp)
c01093c9:	ff 75 0c             	pushl  0xc(%ebp)
c01093cc:	50                   	push   %eax
c01093cd:	e8 2c d4 ff ff       	call   c01067fe <swap_map_swappable>
c01093d2:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c01093d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093d8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01093db:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c01093de:	83 ec 0c             	sub    $0xc,%esp
c01093e1:	ff 75 f4             	pushl  -0xc(%ebp)
c01093e4:	e8 73 f1 ff ff       	call   c010855c <page_ref>
c01093e9:	83 c4 10             	add    $0x10,%esp
c01093ec:	83 f8 01             	cmp    $0x1,%eax
c01093ef:	74 1f                	je     c0109410 <pgdir_alloc_page+0xbb>
c01093f1:	8d 83 f8 3d fe ff    	lea    -0x1c208(%ebx),%eax
c01093f7:	50                   	push   %eax
c01093f8:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01093fe:	50                   	push   %eax
c01093ff:	68 0f 02 00 00       	push   $0x20f
c0109404:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c010940a:	50                   	push   %eax
c010940b:	e8 02 86 ff ff       	call   c0101a12 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0109410:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109413:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109416:	c9                   	leave  
c0109417:	c3                   	ret    

c0109418 <check_alloc_page>:

static void
check_alloc_page(void) {
c0109418:	55                   	push   %ebp
c0109419:	89 e5                	mov    %esp,%ebp
c010941b:	53                   	push   %ebx
c010941c:	83 ec 04             	sub    $0x4,%esp
c010941f:	e8 9d 6e ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0109424:	81 c3 5c 05 02 00    	add    $0x2055c,%ebx
    pmm_manager->check();
c010942a:	c7 c0 90 cc 12 c0    	mov    $0xc012cc90,%eax
c0109430:	8b 00                	mov    (%eax),%eax
c0109432:	8b 40 18             	mov    0x18(%eax),%eax
c0109435:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0109437:	83 ec 0c             	sub    $0xc,%esp
c010943a:	8d 83 0c 3e fe ff    	lea    -0x1c1f4(%ebx),%eax
c0109440:	50                   	push   %eax
c0109441:	e8 ee 6e ff ff       	call   c0100334 <cprintf>
c0109446:	83 c4 10             	add    $0x10,%esp
}
c0109449:	90                   	nop
c010944a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010944d:	c9                   	leave  
c010944e:	c3                   	ret    

c010944f <check_pgdir>:

static void
check_pgdir(void) {
c010944f:	55                   	push   %ebp
c0109450:	89 e5                	mov    %esp,%ebp
c0109452:	53                   	push   %ebx
c0109453:	83 ec 24             	sub    $0x24,%esp
c0109456:	e8 66 6e ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010945b:	81 c3 25 05 02 00    	add    $0x20525,%ebx
    assert(npage <= KMEMSIZE / PGSIZE);
c0109461:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c0109467:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010946c:	76 1f                	jbe    c010948d <check_pgdir+0x3e>
c010946e:	8d 83 2b 3e fe ff    	lea    -0x1c1d5(%ebx),%eax
c0109474:	50                   	push   %eax
c0109475:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c010947b:	50                   	push   %eax
c010947c:	68 20 02 00 00       	push   $0x220
c0109481:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109487:	50                   	push   %eax
c0109488:	e8 85 85 ff ff       	call   c0101a12 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010948d:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109493:	85 c0                	test   %eax,%eax
c0109495:	74 0f                	je     c01094a6 <check_pgdir+0x57>
c0109497:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c010949d:	25 ff 0f 00 00       	and    $0xfff,%eax
c01094a2:	85 c0                	test   %eax,%eax
c01094a4:	74 1f                	je     c01094c5 <check_pgdir+0x76>
c01094a6:	8d 83 48 3e fe ff    	lea    -0x1c1b8(%ebx),%eax
c01094ac:	50                   	push   %eax
c01094ad:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01094b3:	50                   	push   %eax
c01094b4:	68 21 02 00 00       	push   $0x221
c01094b9:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01094bf:	50                   	push   %eax
c01094c0:	e8 4d 85 ff ff       	call   c0101a12 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01094c5:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c01094cb:	83 ec 04             	sub    $0x4,%esp
c01094ce:	6a 00                	push   $0x0
c01094d0:	6a 00                	push   $0x0
c01094d2:	50                   	push   %eax
c01094d3:	e8 44 fc ff ff       	call   c010911c <get_page>
c01094d8:	83 c4 10             	add    $0x10,%esp
c01094db:	85 c0                	test   %eax,%eax
c01094dd:	74 1f                	je     c01094fe <check_pgdir+0xaf>
c01094df:	8d 83 80 3e fe ff    	lea    -0x1c180(%ebx),%eax
c01094e5:	50                   	push   %eax
c01094e6:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01094ec:	50                   	push   %eax
c01094ed:	68 22 02 00 00       	push   $0x222
c01094f2:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01094f8:	50                   	push   %eax
c01094f9:	e8 14 85 ff ff       	call   c0101a12 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01094fe:	83 ec 0c             	sub    $0xc,%esp
c0109501:	6a 01                	push   $0x1
c0109503:	e8 0b f3 ff ff       	call   c0108813 <alloc_pages>
c0109508:	83 c4 10             	add    $0x10,%esp
c010950b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010950e:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109514:	6a 00                	push   $0x0
c0109516:	6a 00                	push   $0x0
c0109518:	ff 75 f4             	pushl  -0xc(%ebp)
c010951b:	50                   	push   %eax
c010951c:	e8 0d fd ff ff       	call   c010922e <page_insert>
c0109521:	83 c4 10             	add    $0x10,%esp
c0109524:	85 c0                	test   %eax,%eax
c0109526:	74 1f                	je     c0109547 <check_pgdir+0xf8>
c0109528:	8d 83 a8 3e fe ff    	lea    -0x1c158(%ebx),%eax
c010952e:	50                   	push   %eax
c010952f:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109535:	50                   	push   %eax
c0109536:	68 26 02 00 00       	push   $0x226
c010953b:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109541:	50                   	push   %eax
c0109542:	e8 cb 84 ff ff       	call   c0101a12 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0109547:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c010954d:	83 ec 04             	sub    $0x4,%esp
c0109550:	6a 00                	push   $0x0
c0109552:	6a 00                	push   $0x0
c0109554:	50                   	push   %eax
c0109555:	e8 8c fa ff ff       	call   c0108fe6 <get_pte>
c010955a:	83 c4 10             	add    $0x10,%esp
c010955d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109560:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109564:	75 1f                	jne    c0109585 <check_pgdir+0x136>
c0109566:	8d 83 d4 3e fe ff    	lea    -0x1c12c(%ebx),%eax
c010956c:	50                   	push   %eax
c010956d:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109573:	50                   	push   %eax
c0109574:	68 29 02 00 00       	push   $0x229
c0109579:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c010957f:	50                   	push   %eax
c0109580:	e8 8d 84 ff ff       	call   c0101a12 <__panic>
    assert(pa2page(*ptep) == p1);
c0109585:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109588:	8b 00                	mov    (%eax),%eax
c010958a:	83 ec 0c             	sub    $0xc,%esp
c010958d:	50                   	push   %eax
c010958e:	e8 c4 ee ff ff       	call   c0108457 <pa2page>
c0109593:	83 c4 10             	add    $0x10,%esp
c0109596:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0109599:	74 1f                	je     c01095ba <check_pgdir+0x16b>
c010959b:	8d 83 01 3f fe ff    	lea    -0x1c0ff(%ebx),%eax
c01095a1:	50                   	push   %eax
c01095a2:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01095a8:	50                   	push   %eax
c01095a9:	68 2a 02 00 00       	push   $0x22a
c01095ae:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01095b4:	50                   	push   %eax
c01095b5:	e8 58 84 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p1) == 1);
c01095ba:	83 ec 0c             	sub    $0xc,%esp
c01095bd:	ff 75 f4             	pushl  -0xc(%ebp)
c01095c0:	e8 97 ef ff ff       	call   c010855c <page_ref>
c01095c5:	83 c4 10             	add    $0x10,%esp
c01095c8:	83 f8 01             	cmp    $0x1,%eax
c01095cb:	74 1f                	je     c01095ec <check_pgdir+0x19d>
c01095cd:	8d 83 16 3f fe ff    	lea    -0x1c0ea(%ebx),%eax
c01095d3:	50                   	push   %eax
c01095d4:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01095da:	50                   	push   %eax
c01095db:	68 2b 02 00 00       	push   $0x22b
c01095e0:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01095e6:	50                   	push   %eax
c01095e7:	e8 26 84 ff ff       	call   c0101a12 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01095ec:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c01095f2:	8b 00                	mov    (%eax),%eax
c01095f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01095f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01095fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01095ff:	c1 e8 0c             	shr    $0xc,%eax
c0109602:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109605:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c010960b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010960e:	72 1b                	jb     c010962b <check_pgdir+0x1dc>
c0109610:	ff 75 ec             	pushl  -0x14(%ebp)
c0109613:	8d 83 d0 3c fe ff    	lea    -0x1c330(%ebx),%eax
c0109619:	50                   	push   %eax
c010961a:	68 2d 02 00 00       	push   $0x22d
c010961f:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109625:	50                   	push   %eax
c0109626:	e8 e7 83 ff ff       	call   c0101a12 <__panic>
c010962b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010962e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0109633:	83 c0 04             	add    $0x4,%eax
c0109636:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0109639:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c010963f:	83 ec 04             	sub    $0x4,%esp
c0109642:	6a 00                	push   $0x0
c0109644:	68 00 10 00 00       	push   $0x1000
c0109649:	50                   	push   %eax
c010964a:	e8 97 f9 ff ff       	call   c0108fe6 <get_pte>
c010964f:	83 c4 10             	add    $0x10,%esp
c0109652:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109655:	74 1f                	je     c0109676 <check_pgdir+0x227>
c0109657:	8d 83 28 3f fe ff    	lea    -0x1c0d8(%ebx),%eax
c010965d:	50                   	push   %eax
c010965e:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109664:	50                   	push   %eax
c0109665:	68 2e 02 00 00       	push   $0x22e
c010966a:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109670:	50                   	push   %eax
c0109671:	e8 9c 83 ff ff       	call   c0101a12 <__panic>

    p2 = alloc_page();
c0109676:	83 ec 0c             	sub    $0xc,%esp
c0109679:	6a 01                	push   $0x1
c010967b:	e8 93 f1 ff ff       	call   c0108813 <alloc_pages>
c0109680:	83 c4 10             	add    $0x10,%esp
c0109683:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0109686:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c010968c:	6a 06                	push   $0x6
c010968e:	68 00 10 00 00       	push   $0x1000
c0109693:	ff 75 e4             	pushl  -0x1c(%ebp)
c0109696:	50                   	push   %eax
c0109697:	e8 92 fb ff ff       	call   c010922e <page_insert>
c010969c:	83 c4 10             	add    $0x10,%esp
c010969f:	85 c0                	test   %eax,%eax
c01096a1:	74 1f                	je     c01096c2 <check_pgdir+0x273>
c01096a3:	8d 83 50 3f fe ff    	lea    -0x1c0b0(%ebx),%eax
c01096a9:	50                   	push   %eax
c01096aa:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01096b0:	50                   	push   %eax
c01096b1:	68 31 02 00 00       	push   $0x231
c01096b6:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01096bc:	50                   	push   %eax
c01096bd:	e8 50 83 ff ff       	call   c0101a12 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01096c2:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c01096c8:	83 ec 04             	sub    $0x4,%esp
c01096cb:	6a 00                	push   $0x0
c01096cd:	68 00 10 00 00       	push   $0x1000
c01096d2:	50                   	push   %eax
c01096d3:	e8 0e f9 ff ff       	call   c0108fe6 <get_pte>
c01096d8:	83 c4 10             	add    $0x10,%esp
c01096db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01096de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01096e2:	75 1f                	jne    c0109703 <check_pgdir+0x2b4>
c01096e4:	8d 83 88 3f fe ff    	lea    -0x1c078(%ebx),%eax
c01096ea:	50                   	push   %eax
c01096eb:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01096f1:	50                   	push   %eax
c01096f2:	68 32 02 00 00       	push   $0x232
c01096f7:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01096fd:	50                   	push   %eax
c01096fe:	e8 0f 83 ff ff       	call   c0101a12 <__panic>
    assert(*ptep & PTE_U);
c0109703:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109706:	8b 00                	mov    (%eax),%eax
c0109708:	83 e0 04             	and    $0x4,%eax
c010970b:	85 c0                	test   %eax,%eax
c010970d:	75 1f                	jne    c010972e <check_pgdir+0x2df>
c010970f:	8d 83 b8 3f fe ff    	lea    -0x1c048(%ebx),%eax
c0109715:	50                   	push   %eax
c0109716:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c010971c:	50                   	push   %eax
c010971d:	68 33 02 00 00       	push   $0x233
c0109722:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109728:	50                   	push   %eax
c0109729:	e8 e4 82 ff ff       	call   c0101a12 <__panic>
    assert(*ptep & PTE_W);
c010972e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109731:	8b 00                	mov    (%eax),%eax
c0109733:	83 e0 02             	and    $0x2,%eax
c0109736:	85 c0                	test   %eax,%eax
c0109738:	75 1f                	jne    c0109759 <check_pgdir+0x30a>
c010973a:	8d 83 c6 3f fe ff    	lea    -0x1c03a(%ebx),%eax
c0109740:	50                   	push   %eax
c0109741:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109747:	50                   	push   %eax
c0109748:	68 34 02 00 00       	push   $0x234
c010974d:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109753:	50                   	push   %eax
c0109754:	e8 b9 82 ff ff       	call   c0101a12 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0109759:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c010975f:	8b 00                	mov    (%eax),%eax
c0109761:	83 e0 04             	and    $0x4,%eax
c0109764:	85 c0                	test   %eax,%eax
c0109766:	75 1f                	jne    c0109787 <check_pgdir+0x338>
c0109768:	8d 83 d4 3f fe ff    	lea    -0x1c02c(%ebx),%eax
c010976e:	50                   	push   %eax
c010976f:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109775:	50                   	push   %eax
c0109776:	68 35 02 00 00       	push   $0x235
c010977b:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109781:	50                   	push   %eax
c0109782:	e8 8b 82 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p2) == 1);
c0109787:	83 ec 0c             	sub    $0xc,%esp
c010978a:	ff 75 e4             	pushl  -0x1c(%ebp)
c010978d:	e8 ca ed ff ff       	call   c010855c <page_ref>
c0109792:	83 c4 10             	add    $0x10,%esp
c0109795:	83 f8 01             	cmp    $0x1,%eax
c0109798:	74 1f                	je     c01097b9 <check_pgdir+0x36a>
c010979a:	8d 83 ea 3f fe ff    	lea    -0x1c016(%ebx),%eax
c01097a0:	50                   	push   %eax
c01097a1:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01097a7:	50                   	push   %eax
c01097a8:	68 36 02 00 00       	push   $0x236
c01097ad:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01097b3:	50                   	push   %eax
c01097b4:	e8 59 82 ff ff       	call   c0101a12 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01097b9:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c01097bf:	6a 00                	push   $0x0
c01097c1:	68 00 10 00 00       	push   $0x1000
c01097c6:	ff 75 f4             	pushl  -0xc(%ebp)
c01097c9:	50                   	push   %eax
c01097ca:	e8 5f fa ff ff       	call   c010922e <page_insert>
c01097cf:	83 c4 10             	add    $0x10,%esp
c01097d2:	85 c0                	test   %eax,%eax
c01097d4:	74 1f                	je     c01097f5 <check_pgdir+0x3a6>
c01097d6:	8d 83 fc 3f fe ff    	lea    -0x1c004(%ebx),%eax
c01097dc:	50                   	push   %eax
c01097dd:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01097e3:	50                   	push   %eax
c01097e4:	68 38 02 00 00       	push   $0x238
c01097e9:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01097ef:	50                   	push   %eax
c01097f0:	e8 1d 82 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p1) == 2);
c01097f5:	83 ec 0c             	sub    $0xc,%esp
c01097f8:	ff 75 f4             	pushl  -0xc(%ebp)
c01097fb:	e8 5c ed ff ff       	call   c010855c <page_ref>
c0109800:	83 c4 10             	add    $0x10,%esp
c0109803:	83 f8 02             	cmp    $0x2,%eax
c0109806:	74 1f                	je     c0109827 <check_pgdir+0x3d8>
c0109808:	8d 83 28 40 fe ff    	lea    -0x1bfd8(%ebx),%eax
c010980e:	50                   	push   %eax
c010980f:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109815:	50                   	push   %eax
c0109816:	68 39 02 00 00       	push   $0x239
c010981b:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109821:	50                   	push   %eax
c0109822:	e8 eb 81 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p2) == 0);
c0109827:	83 ec 0c             	sub    $0xc,%esp
c010982a:	ff 75 e4             	pushl  -0x1c(%ebp)
c010982d:	e8 2a ed ff ff       	call   c010855c <page_ref>
c0109832:	83 c4 10             	add    $0x10,%esp
c0109835:	85 c0                	test   %eax,%eax
c0109837:	74 1f                	je     c0109858 <check_pgdir+0x409>
c0109839:	8d 83 3a 40 fe ff    	lea    -0x1bfc6(%ebx),%eax
c010983f:	50                   	push   %eax
c0109840:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109846:	50                   	push   %eax
c0109847:	68 3a 02 00 00       	push   $0x23a
c010984c:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109852:	50                   	push   %eax
c0109853:	e8 ba 81 ff ff       	call   c0101a12 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0109858:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c010985e:	83 ec 04             	sub    $0x4,%esp
c0109861:	6a 00                	push   $0x0
c0109863:	68 00 10 00 00       	push   $0x1000
c0109868:	50                   	push   %eax
c0109869:	e8 78 f7 ff ff       	call   c0108fe6 <get_pte>
c010986e:	83 c4 10             	add    $0x10,%esp
c0109871:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109874:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109878:	75 1f                	jne    c0109899 <check_pgdir+0x44a>
c010987a:	8d 83 88 3f fe ff    	lea    -0x1c078(%ebx),%eax
c0109880:	50                   	push   %eax
c0109881:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109887:	50                   	push   %eax
c0109888:	68 3b 02 00 00       	push   $0x23b
c010988d:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109893:	50                   	push   %eax
c0109894:	e8 79 81 ff ff       	call   c0101a12 <__panic>
    assert(pa2page(*ptep) == p1);
c0109899:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010989c:	8b 00                	mov    (%eax),%eax
c010989e:	83 ec 0c             	sub    $0xc,%esp
c01098a1:	50                   	push   %eax
c01098a2:	e8 b0 eb ff ff       	call   c0108457 <pa2page>
c01098a7:	83 c4 10             	add    $0x10,%esp
c01098aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01098ad:	74 1f                	je     c01098ce <check_pgdir+0x47f>
c01098af:	8d 83 01 3f fe ff    	lea    -0x1c0ff(%ebx),%eax
c01098b5:	50                   	push   %eax
c01098b6:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01098bc:	50                   	push   %eax
c01098bd:	68 3c 02 00 00       	push   $0x23c
c01098c2:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01098c8:	50                   	push   %eax
c01098c9:	e8 44 81 ff ff       	call   c0101a12 <__panic>
    assert((*ptep & PTE_U) == 0);
c01098ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098d1:	8b 00                	mov    (%eax),%eax
c01098d3:	83 e0 04             	and    $0x4,%eax
c01098d6:	85 c0                	test   %eax,%eax
c01098d8:	74 1f                	je     c01098f9 <check_pgdir+0x4aa>
c01098da:	8d 83 4c 40 fe ff    	lea    -0x1bfb4(%ebx),%eax
c01098e0:	50                   	push   %eax
c01098e1:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01098e7:	50                   	push   %eax
c01098e8:	68 3d 02 00 00       	push   $0x23d
c01098ed:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01098f3:	50                   	push   %eax
c01098f4:	e8 19 81 ff ff       	call   c0101a12 <__panic>

    page_remove(boot_pgdir, 0x0);
c01098f9:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c01098ff:	83 ec 08             	sub    $0x8,%esp
c0109902:	6a 00                	push   $0x0
c0109904:	50                   	push   %eax
c0109905:	e8 e1 f8 ff ff       	call   c01091eb <page_remove>
c010990a:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c010990d:	83 ec 0c             	sub    $0xc,%esp
c0109910:	ff 75 f4             	pushl  -0xc(%ebp)
c0109913:	e8 44 ec ff ff       	call   c010855c <page_ref>
c0109918:	83 c4 10             	add    $0x10,%esp
c010991b:	83 f8 01             	cmp    $0x1,%eax
c010991e:	74 1f                	je     c010993f <check_pgdir+0x4f0>
c0109920:	8d 83 16 3f fe ff    	lea    -0x1c0ea(%ebx),%eax
c0109926:	50                   	push   %eax
c0109927:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c010992d:	50                   	push   %eax
c010992e:	68 40 02 00 00       	push   $0x240
c0109933:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109939:	50                   	push   %eax
c010993a:	e8 d3 80 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p2) == 0);
c010993f:	83 ec 0c             	sub    $0xc,%esp
c0109942:	ff 75 e4             	pushl  -0x1c(%ebp)
c0109945:	e8 12 ec ff ff       	call   c010855c <page_ref>
c010994a:	83 c4 10             	add    $0x10,%esp
c010994d:	85 c0                	test   %eax,%eax
c010994f:	74 1f                	je     c0109970 <check_pgdir+0x521>
c0109951:	8d 83 3a 40 fe ff    	lea    -0x1bfc6(%ebx),%eax
c0109957:	50                   	push   %eax
c0109958:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c010995e:	50                   	push   %eax
c010995f:	68 41 02 00 00       	push   $0x241
c0109964:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c010996a:	50                   	push   %eax
c010996b:	e8 a2 80 ff ff       	call   c0101a12 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0109970:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109976:	83 ec 08             	sub    $0x8,%esp
c0109979:	68 00 10 00 00       	push   $0x1000
c010997e:	50                   	push   %eax
c010997f:	e8 67 f8 ff ff       	call   c01091eb <page_remove>
c0109984:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0109987:	83 ec 0c             	sub    $0xc,%esp
c010998a:	ff 75 f4             	pushl  -0xc(%ebp)
c010998d:	e8 ca eb ff ff       	call   c010855c <page_ref>
c0109992:	83 c4 10             	add    $0x10,%esp
c0109995:	85 c0                	test   %eax,%eax
c0109997:	74 1f                	je     c01099b8 <check_pgdir+0x569>
c0109999:	8d 83 61 40 fe ff    	lea    -0x1bf9f(%ebx),%eax
c010999f:	50                   	push   %eax
c01099a0:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01099a6:	50                   	push   %eax
c01099a7:	68 44 02 00 00       	push   $0x244
c01099ac:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01099b2:	50                   	push   %eax
c01099b3:	e8 5a 80 ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p2) == 0);
c01099b8:	83 ec 0c             	sub    $0xc,%esp
c01099bb:	ff 75 e4             	pushl  -0x1c(%ebp)
c01099be:	e8 99 eb ff ff       	call   c010855c <page_ref>
c01099c3:	83 c4 10             	add    $0x10,%esp
c01099c6:	85 c0                	test   %eax,%eax
c01099c8:	74 1f                	je     c01099e9 <check_pgdir+0x59a>
c01099ca:	8d 83 3a 40 fe ff    	lea    -0x1bfc6(%ebx),%eax
c01099d0:	50                   	push   %eax
c01099d1:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c01099d7:	50                   	push   %eax
c01099d8:	68 45 02 00 00       	push   $0x245
c01099dd:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c01099e3:	50                   	push   %eax
c01099e4:	e8 29 80 ff ff       	call   c0101a12 <__panic>

    assert(page_ref(pa2page(boot_pgdir[0])) == 1);
c01099e9:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c01099ef:	8b 00                	mov    (%eax),%eax
c01099f1:	83 ec 0c             	sub    $0xc,%esp
c01099f4:	50                   	push   %eax
c01099f5:	e8 5d ea ff ff       	call   c0108457 <pa2page>
c01099fa:	83 c4 10             	add    $0x10,%esp
c01099fd:	83 ec 0c             	sub    $0xc,%esp
c0109a00:	50                   	push   %eax
c0109a01:	e8 56 eb ff ff       	call   c010855c <page_ref>
c0109a06:	83 c4 10             	add    $0x10,%esp
c0109a09:	83 f8 01             	cmp    $0x1,%eax
c0109a0c:	74 1f                	je     c0109a2d <check_pgdir+0x5de>
c0109a0e:	8d 83 74 40 fe ff    	lea    -0x1bf8c(%ebx),%eax
c0109a14:	50                   	push   %eax
c0109a15:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109a1b:	50                   	push   %eax
c0109a1c:	68 47 02 00 00       	push   $0x247
c0109a21:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109a27:	50                   	push   %eax
c0109a28:	e8 e5 7f ff ff       	call   c0101a12 <__panic>
    free_page(pa2page(boot_pgdir[0]));
c0109a2d:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109a33:	8b 00                	mov    (%eax),%eax
c0109a35:	83 ec 0c             	sub    $0xc,%esp
c0109a38:	50                   	push   %eax
c0109a39:	e8 19 ea ff ff       	call   c0108457 <pa2page>
c0109a3e:	83 c4 10             	add    $0x10,%esp
c0109a41:	83 ec 08             	sub    $0x8,%esp
c0109a44:	6a 01                	push   $0x1
c0109a46:	50                   	push   %eax
c0109a47:	e8 4b ee ff ff       	call   c0108897 <free_pages>
c0109a4c:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0109a4f:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109a55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0109a5b:	83 ec 0c             	sub    $0xc,%esp
c0109a5e:	8d 83 9a 40 fe ff    	lea    -0x1bf66(%ebx),%eax
c0109a64:	50                   	push   %eax
c0109a65:	e8 ca 68 ff ff       	call   c0100334 <cprintf>
c0109a6a:	83 c4 10             	add    $0x10,%esp
}
c0109a6d:	90                   	nop
c0109a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109a71:	c9                   	leave  
c0109a72:	c3                   	ret    

c0109a73 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0109a73:	55                   	push   %ebp
c0109a74:	89 e5                	mov    %esp,%ebp
c0109a76:	53                   	push   %ebx
c0109a77:	83 ec 24             	sub    $0x24,%esp
c0109a7a:	e8 42 68 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0109a7f:	81 c3 01 ff 01 00    	add    $0x1ff01,%ebx
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0109a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109a8c:	e9 b5 00 00 00       	jmp    c0109b46 <check_boot_pgdir+0xd3>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0109a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109a97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a9a:	c1 e8 0c             	shr    $0xc,%eax
c0109a9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109aa0:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c0109aa6:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0109aa9:	72 1b                	jb     c0109ac6 <check_boot_pgdir+0x53>
c0109aab:	ff 75 e4             	pushl  -0x1c(%ebp)
c0109aae:	8d 83 d0 3c fe ff    	lea    -0x1c330(%ebx),%eax
c0109ab4:	50                   	push   %eax
c0109ab5:	68 53 02 00 00       	push   $0x253
c0109aba:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109ac0:	50                   	push   %eax
c0109ac1:	e8 4c 7f ff ff       	call   c0101a12 <__panic>
c0109ac6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109ac9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0109ace:	89 c2                	mov    %eax,%edx
c0109ad0:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109ad6:	83 ec 04             	sub    $0x4,%esp
c0109ad9:	6a 00                	push   $0x0
c0109adb:	52                   	push   %edx
c0109adc:	50                   	push   %eax
c0109add:	e8 04 f5 ff ff       	call   c0108fe6 <get_pte>
c0109ae2:	83 c4 10             	add    $0x10,%esp
c0109ae5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0109ae8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109aec:	75 1f                	jne    c0109b0d <check_boot_pgdir+0x9a>
c0109aee:	8d 83 b4 40 fe ff    	lea    -0x1bf4c(%ebx),%eax
c0109af4:	50                   	push   %eax
c0109af5:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109afb:	50                   	push   %eax
c0109afc:	68 53 02 00 00       	push   $0x253
c0109b01:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109b07:	50                   	push   %eax
c0109b08:	e8 05 7f ff ff       	call   c0101a12 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0109b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b10:	8b 00                	mov    (%eax),%eax
c0109b12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109b17:	89 c2                	mov    %eax,%edx
c0109b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b1c:	39 c2                	cmp    %eax,%edx
c0109b1e:	74 1f                	je     c0109b3f <check_boot_pgdir+0xcc>
c0109b20:	8d 83 f1 40 fe ff    	lea    -0x1bf0f(%ebx),%eax
c0109b26:	50                   	push   %eax
c0109b27:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109b2d:	50                   	push   %eax
c0109b2e:	68 54 02 00 00       	push   $0x254
c0109b33:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109b39:	50                   	push   %eax
c0109b3a:	e8 d3 7e ff ff       	call   c0101a12 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0109b3f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0109b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b49:	8b 83 40 11 00 00    	mov    0x1140(%ebx),%eax
c0109b4f:	39 c2                	cmp    %eax,%edx
c0109b51:	0f 82 3a ff ff ff    	jb     c0109a91 <check_boot_pgdir+0x1e>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0109b57:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109b5d:	05 ac 0f 00 00       	add    $0xfac,%eax
c0109b62:	8b 00                	mov    (%eax),%eax
c0109b64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109b69:	89 c2                	mov    %eax,%edx
c0109b6b:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b74:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0109b7b:	77 1b                	ja     c0109b98 <check_boot_pgdir+0x125>
c0109b7d:	ff 75 f0             	pushl  -0x10(%ebp)
c0109b80:	8d 83 74 3d fe ff    	lea    -0x1c28c(%ebx),%eax
c0109b86:	50                   	push   %eax
c0109b87:	68 57 02 00 00       	push   $0x257
c0109b8c:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109b92:	50                   	push   %eax
c0109b93:	e8 7a 7e ff ff       	call   c0101a12 <__panic>
c0109b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b9b:	05 00 00 00 40       	add    $0x40000000,%eax
c0109ba0:	39 d0                	cmp    %edx,%eax
c0109ba2:	74 1f                	je     c0109bc3 <check_boot_pgdir+0x150>
c0109ba4:	8d 83 08 41 fe ff    	lea    -0x1bef8(%ebx),%eax
c0109baa:	50                   	push   %eax
c0109bab:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109bb1:	50                   	push   %eax
c0109bb2:	68 57 02 00 00       	push   $0x257
c0109bb7:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109bbd:	50                   	push   %eax
c0109bbe:	e8 4f 7e ff ff       	call   c0101a12 <__panic>

    assert(boot_pgdir[0] == 0);
c0109bc3:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109bc9:	8b 00                	mov    (%eax),%eax
c0109bcb:	85 c0                	test   %eax,%eax
c0109bcd:	74 1f                	je     c0109bee <check_boot_pgdir+0x17b>
c0109bcf:	8d 83 3c 41 fe ff    	lea    -0x1bec4(%ebx),%eax
c0109bd5:	50                   	push   %eax
c0109bd6:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109bdc:	50                   	push   %eax
c0109bdd:	68 59 02 00 00       	push   $0x259
c0109be2:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109be8:	50                   	push   %eax
c0109be9:	e8 24 7e ff ff       	call   c0101a12 <__panic>

    struct Page *p;
    p = alloc_page();
c0109bee:	83 ec 0c             	sub    $0xc,%esp
c0109bf1:	6a 01                	push   $0x1
c0109bf3:	e8 1b ec ff ff       	call   c0108813 <alloc_pages>
c0109bf8:	83 c4 10             	add    $0x10,%esp
c0109bfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0109bfe:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109c04:	6a 02                	push   $0x2
c0109c06:	68 00 01 00 00       	push   $0x100
c0109c0b:	ff 75 ec             	pushl  -0x14(%ebp)
c0109c0e:	50                   	push   %eax
c0109c0f:	e8 1a f6 ff ff       	call   c010922e <page_insert>
c0109c14:	83 c4 10             	add    $0x10,%esp
c0109c17:	85 c0                	test   %eax,%eax
c0109c19:	74 1f                	je     c0109c3a <check_boot_pgdir+0x1c7>
c0109c1b:	8d 83 50 41 fe ff    	lea    -0x1beb0(%ebx),%eax
c0109c21:	50                   	push   %eax
c0109c22:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109c28:	50                   	push   %eax
c0109c29:	68 5d 02 00 00       	push   $0x25d
c0109c2e:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109c34:	50                   	push   %eax
c0109c35:	e8 d8 7d ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p) == 1);
c0109c3a:	83 ec 0c             	sub    $0xc,%esp
c0109c3d:	ff 75 ec             	pushl  -0x14(%ebp)
c0109c40:	e8 17 e9 ff ff       	call   c010855c <page_ref>
c0109c45:	83 c4 10             	add    $0x10,%esp
c0109c48:	83 f8 01             	cmp    $0x1,%eax
c0109c4b:	74 1f                	je     c0109c6c <check_boot_pgdir+0x1f9>
c0109c4d:	8d 83 7e 41 fe ff    	lea    -0x1be82(%ebx),%eax
c0109c53:	50                   	push   %eax
c0109c54:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109c5a:	50                   	push   %eax
c0109c5b:	68 5e 02 00 00       	push   $0x25e
c0109c60:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109c66:	50                   	push   %eax
c0109c67:	e8 a6 7d ff ff       	call   c0101a12 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0109c6c:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109c72:	6a 02                	push   $0x2
c0109c74:	68 00 11 00 00       	push   $0x1100
c0109c79:	ff 75 ec             	pushl  -0x14(%ebp)
c0109c7c:	50                   	push   %eax
c0109c7d:	e8 ac f5 ff ff       	call   c010922e <page_insert>
c0109c82:	83 c4 10             	add    $0x10,%esp
c0109c85:	85 c0                	test   %eax,%eax
c0109c87:	74 1f                	je     c0109ca8 <check_boot_pgdir+0x235>
c0109c89:	8d 83 90 41 fe ff    	lea    -0x1be70(%ebx),%eax
c0109c8f:	50                   	push   %eax
c0109c90:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109c96:	50                   	push   %eax
c0109c97:	68 5f 02 00 00       	push   $0x25f
c0109c9c:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109ca2:	50                   	push   %eax
c0109ca3:	e8 6a 7d ff ff       	call   c0101a12 <__panic>
    assert(page_ref(p) == 2);
c0109ca8:	83 ec 0c             	sub    $0xc,%esp
c0109cab:	ff 75 ec             	pushl  -0x14(%ebp)
c0109cae:	e8 a9 e8 ff ff       	call   c010855c <page_ref>
c0109cb3:	83 c4 10             	add    $0x10,%esp
c0109cb6:	83 f8 02             	cmp    $0x2,%eax
c0109cb9:	74 1f                	je     c0109cda <check_boot_pgdir+0x267>
c0109cbb:	8d 83 c7 41 fe ff    	lea    -0x1be39(%ebx),%eax
c0109cc1:	50                   	push   %eax
c0109cc2:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109cc8:	50                   	push   %eax
c0109cc9:	68 60 02 00 00       	push   $0x260
c0109cce:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109cd4:	50                   	push   %eax
c0109cd5:	e8 38 7d ff ff       	call   c0101a12 <__panic>

    const char *str = "ucore: Hello world!!";
c0109cda:	8d 83 d8 41 fe ff    	lea    -0x1be28(%ebx),%eax
c0109ce0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0109ce3:	83 ec 08             	sub    $0x8,%esp
c0109ce6:	ff 75 e8             	pushl  -0x18(%ebp)
c0109ce9:	68 00 01 00 00       	push   $0x100
c0109cee:	e8 9a 13 00 00       	call   c010b08d <strcpy>
c0109cf3:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0109cf6:	83 ec 08             	sub    $0x8,%esp
c0109cf9:	68 00 11 00 00       	push   $0x1100
c0109cfe:	68 00 01 00 00       	push   $0x100
c0109d03:	e8 13 14 00 00       	call   c010b11b <strcmp>
c0109d08:	83 c4 10             	add    $0x10,%esp
c0109d0b:	85 c0                	test   %eax,%eax
c0109d0d:	74 1f                	je     c0109d2e <check_boot_pgdir+0x2bb>
c0109d0f:	8d 83 f0 41 fe ff    	lea    -0x1be10(%ebx),%eax
c0109d15:	50                   	push   %eax
c0109d16:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109d1c:	50                   	push   %eax
c0109d1d:	68 64 02 00 00       	push   $0x264
c0109d22:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109d28:	50                   	push   %eax
c0109d29:	e8 e4 7c ff ff       	call   c0101a12 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0109d2e:	83 ec 0c             	sub    $0xc,%esp
c0109d31:	ff 75 ec             	pushl  -0x14(%ebp)
c0109d34:	e8 7c e7 ff ff       	call   c01084b5 <page2kva>
c0109d39:	83 c4 10             	add    $0x10,%esp
c0109d3c:	05 00 01 00 00       	add    $0x100,%eax
c0109d41:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0109d44:	83 ec 0c             	sub    $0xc,%esp
c0109d47:	68 00 01 00 00       	push   $0x100
c0109d4c:	e8 d0 12 00 00       	call   c010b021 <strlen>
c0109d51:	83 c4 10             	add    $0x10,%esp
c0109d54:	85 c0                	test   %eax,%eax
c0109d56:	74 1f                	je     c0109d77 <check_boot_pgdir+0x304>
c0109d58:	8d 83 28 42 fe ff    	lea    -0x1bdd8(%ebx),%eax
c0109d5e:	50                   	push   %eax
c0109d5f:	8d 83 bd 3d fe ff    	lea    -0x1c243(%ebx),%eax
c0109d65:	50                   	push   %eax
c0109d66:	68 67 02 00 00       	push   $0x267
c0109d6b:	8d 83 98 3d fe ff    	lea    -0x1c268(%ebx),%eax
c0109d71:	50                   	push   %eax
c0109d72:	e8 9b 7c ff ff       	call   c0101a12 <__panic>

    free_page(p);
c0109d77:	83 ec 08             	sub    $0x8,%esp
c0109d7a:	6a 01                	push   $0x1
c0109d7c:	ff 75 ec             	pushl  -0x14(%ebp)
c0109d7f:	e8 13 eb ff ff       	call   c0108897 <free_pages>
c0109d84:	83 c4 10             	add    $0x10,%esp
    free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
c0109d87:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109d8d:	8b 00                	mov    (%eax),%eax
c0109d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109d94:	83 ec 0c             	sub    $0xc,%esp
c0109d97:	50                   	push   %eax
c0109d98:	e8 ba e6 ff ff       	call   c0108457 <pa2page>
c0109d9d:	83 c4 10             	add    $0x10,%esp
c0109da0:	83 ec 08             	sub    $0x8,%esp
c0109da3:	6a 01                	push   $0x1
c0109da5:	50                   	push   %eax
c0109da6:	e8 ec ea ff ff       	call   c0108897 <free_pages>
c0109dab:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0109dae:	8b 83 44 11 00 00    	mov    0x1144(%ebx),%eax
c0109db4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0109dba:	83 ec 0c             	sub    $0xc,%esp
c0109dbd:	8d 83 4c 42 fe ff    	lea    -0x1bdb4(%ebx),%eax
c0109dc3:	50                   	push   %eax
c0109dc4:	e8 6b 65 ff ff       	call   c0100334 <cprintf>
c0109dc9:	83 c4 10             	add    $0x10,%esp
}
c0109dcc:	90                   	nop
c0109dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109dd0:	c9                   	leave  
c0109dd1:	c3                   	ret    

c0109dd2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0109dd2:	55                   	push   %ebp
c0109dd3:	89 e5                	mov    %esp,%ebp
c0109dd5:	e8 e3 64 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0109dda:	05 a6 fb 01 00       	add    $0x1fba6,%eax
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0109ddf:	8b 55 08             	mov    0x8(%ebp),%edx
c0109de2:	83 e2 04             	and    $0x4,%edx
c0109de5:	85 d2                	test   %edx,%edx
c0109de7:	74 07                	je     c0109df0 <perm2str+0x1e>
c0109de9:	ba 75 00 00 00       	mov    $0x75,%edx
c0109dee:	eb 05                	jmp    c0109df5 <perm2str+0x23>
c0109df0:	ba 2d 00 00 00       	mov    $0x2d,%edx
c0109df5:	88 90 c8 11 00 00    	mov    %dl,0x11c8(%eax)
    str[1] = 'r';
c0109dfb:	c6 80 c9 11 00 00 72 	movb   $0x72,0x11c9(%eax)
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0109e02:	8b 55 08             	mov    0x8(%ebp),%edx
c0109e05:	83 e2 02             	and    $0x2,%edx
c0109e08:	85 d2                	test   %edx,%edx
c0109e0a:	74 07                	je     c0109e13 <perm2str+0x41>
c0109e0c:	ba 77 00 00 00       	mov    $0x77,%edx
c0109e11:	eb 05                	jmp    c0109e18 <perm2str+0x46>
c0109e13:	ba 2d 00 00 00       	mov    $0x2d,%edx
c0109e18:	88 90 ca 11 00 00    	mov    %dl,0x11ca(%eax)
    str[3] = '\0';
c0109e1e:	c6 80 cb 11 00 00 00 	movb   $0x0,0x11cb(%eax)
    return str;
c0109e25:	8d 80 c8 11 00 00    	lea    0x11c8(%eax),%eax
}
c0109e2b:	5d                   	pop    %ebp
c0109e2c:	c3                   	ret    

c0109e2d <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0109e2d:	55                   	push   %ebp
c0109e2e:	89 e5                	mov    %esp,%ebp
c0109e30:	83 ec 10             	sub    $0x10,%esp
c0109e33:	e8 85 64 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c0109e38:	05 48 fb 01 00       	add    $0x1fb48,%eax
    if (start >= right) {
c0109e3d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e40:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109e43:	72 0e                	jb     c0109e53 <get_pgtable_items+0x26>
        return 0;
c0109e45:	b8 00 00 00 00       	mov    $0x0,%eax
c0109e4a:	e9 9a 00 00 00       	jmp    c0109ee9 <get_pgtable_items+0xbc>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0109e4f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0109e53:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e56:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109e59:	73 18                	jae    c0109e73 <get_pgtable_items+0x46>
c0109e5b:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0109e65:	8b 45 14             	mov    0x14(%ebp),%eax
c0109e68:	01 d0                	add    %edx,%eax
c0109e6a:	8b 00                	mov    (%eax),%eax
c0109e6c:	83 e0 01             	and    $0x1,%eax
c0109e6f:	85 c0                	test   %eax,%eax
c0109e71:	74 dc                	je     c0109e4f <get_pgtable_items+0x22>
    }
    if (start < right) {
c0109e73:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e76:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109e79:	73 69                	jae    c0109ee4 <get_pgtable_items+0xb7>
        if (left_store != NULL) {
c0109e7b:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0109e7f:	74 08                	je     c0109e89 <get_pgtable_items+0x5c>
            *left_store = start;
c0109e81:	8b 45 18             	mov    0x18(%ebp),%eax
c0109e84:	8b 55 10             	mov    0x10(%ebp),%edx
c0109e87:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0109e89:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e8c:	8d 50 01             	lea    0x1(%eax),%edx
c0109e8f:	89 55 10             	mov    %edx,0x10(%ebp)
c0109e92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0109e99:	8b 45 14             	mov    0x14(%ebp),%eax
c0109e9c:	01 d0                	add    %edx,%eax
c0109e9e:	8b 00                	mov    (%eax),%eax
c0109ea0:	83 e0 07             	and    $0x7,%eax
c0109ea3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0109ea6:	eb 04                	jmp    c0109eac <get_pgtable_items+0x7f>
            start ++;
c0109ea8:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0109eac:	8b 45 10             	mov    0x10(%ebp),%eax
c0109eaf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109eb2:	73 1d                	jae    c0109ed1 <get_pgtable_items+0xa4>
c0109eb4:	8b 45 10             	mov    0x10(%ebp),%eax
c0109eb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0109ebe:	8b 45 14             	mov    0x14(%ebp),%eax
c0109ec1:	01 d0                	add    %edx,%eax
c0109ec3:	8b 00                	mov    (%eax),%eax
c0109ec5:	83 e0 07             	and    $0x7,%eax
c0109ec8:	89 c2                	mov    %eax,%edx
c0109eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109ecd:	39 c2                	cmp    %eax,%edx
c0109ecf:	74 d7                	je     c0109ea8 <get_pgtable_items+0x7b>
        }
        if (right_store != NULL) {
c0109ed1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0109ed5:	74 08                	je     c0109edf <get_pgtable_items+0xb2>
            *right_store = start;
c0109ed7:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0109eda:	8b 55 10             	mov    0x10(%ebp),%edx
c0109edd:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0109edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109ee2:	eb 05                	jmp    c0109ee9 <get_pgtable_items+0xbc>
    }
    return 0;
c0109ee4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109ee9:	c9                   	leave  
c0109eea:	c3                   	ret    

c0109eeb <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0109eeb:	55                   	push   %ebp
c0109eec:	89 e5                	mov    %esp,%ebp
c0109eee:	57                   	push   %edi
c0109eef:	56                   	push   %esi
c0109ef0:	53                   	push   %ebx
c0109ef1:	83 ec 3c             	sub    $0x3c,%esp
c0109ef4:	e8 c8 63 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c0109ef9:	81 c3 87 fa 01 00    	add    $0x1fa87,%ebx
    cprintf("-------------------- BEGIN --------------------\n");
c0109eff:	83 ec 0c             	sub    $0xc,%esp
c0109f02:	8d 83 6c 42 fe ff    	lea    -0x1bd94(%ebx),%eax
c0109f08:	50                   	push   %eax
c0109f09:	e8 26 64 ff ff       	call   c0100334 <cprintf>
c0109f0e:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0109f11:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0109f18:	e9 ef 00 00 00       	jmp    c010a00c <print_pgdir+0x121>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0109f1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109f20:	83 ec 0c             	sub    $0xc,%esp
c0109f23:	50                   	push   %eax
c0109f24:	e8 a9 fe ff ff       	call   c0109dd2 <perm2str>
c0109f29:	83 c4 10             	add    $0x10,%esp
c0109f2c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0109f2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109f32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109f35:	29 c2                	sub    %eax,%edx
c0109f37:	89 d0                	mov    %edx,%eax
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0109f39:	89 c6                	mov    %eax,%esi
c0109f3b:	c1 e6 16             	shl    $0x16,%esi
c0109f3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109f41:	89 c1                	mov    %eax,%ecx
c0109f43:	c1 e1 16             	shl    $0x16,%ecx
c0109f46:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109f49:	89 c2                	mov    %eax,%edx
c0109f4b:	c1 e2 16             	shl    $0x16,%edx
c0109f4e:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0109f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109f54:	29 c7                	sub    %eax,%edi
c0109f56:	89 f8                	mov    %edi,%eax
c0109f58:	83 ec 08             	sub    $0x8,%esp
c0109f5b:	ff 75 c4             	pushl  -0x3c(%ebp)
c0109f5e:	56                   	push   %esi
c0109f5f:	51                   	push   %ecx
c0109f60:	52                   	push   %edx
c0109f61:	50                   	push   %eax
c0109f62:	8d 83 9d 42 fe ff    	lea    -0x1bd63(%ebx),%eax
c0109f68:	50                   	push   %eax
c0109f69:	e8 c6 63 ff ff       	call   c0100334 <cprintf>
c0109f6e:	83 c4 20             	add    $0x20,%esp
        size_t l, r = left * NPTEENTRY;
c0109f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109f74:	c1 e0 0a             	shl    $0xa,%eax
c0109f77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0109f7a:	eb 54                	jmp    c0109fd0 <print_pgdir+0xe5>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0109f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109f7f:	83 ec 0c             	sub    $0xc,%esp
c0109f82:	50                   	push   %eax
c0109f83:	e8 4a fe ff ff       	call   c0109dd2 <perm2str>
c0109f88:	83 c4 10             	add    $0x10,%esp
c0109f8b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0109f8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109f91:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109f94:	29 c2                	sub    %eax,%edx
c0109f96:	89 d0                	mov    %edx,%eax
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0109f98:	89 c6                	mov    %eax,%esi
c0109f9a:	c1 e6 0c             	shl    $0xc,%esi
c0109f9d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109fa0:	89 c1                	mov    %eax,%ecx
c0109fa2:	c1 e1 0c             	shl    $0xc,%ecx
c0109fa5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109fa8:	89 c2                	mov    %eax,%edx
c0109faa:	c1 e2 0c             	shl    $0xc,%edx
c0109fad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0109fb0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109fb3:	29 c7                	sub    %eax,%edi
c0109fb5:	89 f8                	mov    %edi,%eax
c0109fb7:	83 ec 08             	sub    $0x8,%esp
c0109fba:	ff 75 c4             	pushl  -0x3c(%ebp)
c0109fbd:	56                   	push   %esi
c0109fbe:	51                   	push   %ecx
c0109fbf:	52                   	push   %edx
c0109fc0:	50                   	push   %eax
c0109fc1:	8d 83 bc 42 fe ff    	lea    -0x1bd44(%ebx),%eax
c0109fc7:	50                   	push   %eax
c0109fc8:	e8 67 63 ff ff       	call   c0100334 <cprintf>
c0109fcd:	83 c4 20             	add    $0x20,%esp
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0109fd0:	bf 00 00 c0 fa       	mov    $0xfac00000,%edi
c0109fd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109fd8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109fdb:	89 d6                	mov    %edx,%esi
c0109fdd:	c1 e6 0a             	shl    $0xa,%esi
c0109fe0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109fe3:	89 d1                	mov    %edx,%ecx
c0109fe5:	c1 e1 0a             	shl    $0xa,%ecx
c0109fe8:	83 ec 08             	sub    $0x8,%esp
c0109feb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0109fee:	52                   	push   %edx
c0109fef:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0109ff2:	52                   	push   %edx
c0109ff3:	57                   	push   %edi
c0109ff4:	50                   	push   %eax
c0109ff5:	56                   	push   %esi
c0109ff6:	51                   	push   %ecx
c0109ff7:	e8 31 fe ff ff       	call   c0109e2d <get_pgtable_items>
c0109ffc:	83 c4 20             	add    $0x20,%esp
c0109fff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a002:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a006:	0f 85 70 ff ff ff    	jne    c0109f7c <print_pgdir+0x91>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010a00c:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010a011:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a014:	83 ec 08             	sub    $0x8,%esp
c010a017:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a01a:	52                   	push   %edx
c010a01b:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010a01e:	52                   	push   %edx
c010a01f:	51                   	push   %ecx
c010a020:	50                   	push   %eax
c010a021:	68 00 04 00 00       	push   $0x400
c010a026:	6a 00                	push   $0x0
c010a028:	e8 00 fe ff ff       	call   c0109e2d <get_pgtable_items>
c010a02d:	83 c4 20             	add    $0x20,%esp
c010a030:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a033:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a037:	0f 85 e0 fe ff ff    	jne    c0109f1d <print_pgdir+0x32>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010a03d:	83 ec 0c             	sub    $0xc,%esp
c010a040:	8d 83 e0 42 fe ff    	lea    -0x1bd20(%ebx),%eax
c010a046:	50                   	push   %eax
c010a047:	e8 e8 62 ff ff       	call   c0100334 <cprintf>
c010a04c:	83 c4 10             	add    $0x10,%esp
}
c010a04f:	90                   	nop
c010a050:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010a053:	5b                   	pop    %ebx
c010a054:	5e                   	pop    %esi
c010a055:	5f                   	pop    %edi
c010a056:	5d                   	pop    %ebp
c010a057:	c3                   	ret    

c010a058 <__x86.get_pc_thunk.si>:
c010a058:	8b 34 24             	mov    (%esp),%esi
c010a05b:	c3                   	ret    

c010a05c <page2ppn>:
page2ppn(struct Page *page) {
c010a05c:	55                   	push   %ebp
c010a05d:	89 e5                	mov    %esp,%ebp
c010a05f:	e8 59 62 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a064:	05 1c f9 01 00       	add    $0x1f91c,%eax
    return page - pages;
c010a069:	8b 55 08             	mov    0x8(%ebp),%edx
c010a06c:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c010a072:	8b 00                	mov    (%eax),%eax
c010a074:	29 c2                	sub    %eax,%edx
c010a076:	89 d0                	mov    %edx,%eax
c010a078:	c1 f8 02             	sar    $0x2,%eax
c010a07b:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c010a081:	5d                   	pop    %ebp
c010a082:	c3                   	ret    

c010a083 <page2pa>:
page2pa(struct Page *page) {
c010a083:	55                   	push   %ebp
c010a084:	89 e5                	mov    %esp,%ebp
c010a086:	e8 32 62 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a08b:	05 f5 f8 01 00       	add    $0x1f8f5,%eax
    return page2ppn(page) << PGSHIFT;
c010a090:	ff 75 08             	pushl  0x8(%ebp)
c010a093:	e8 c4 ff ff ff       	call   c010a05c <page2ppn>
c010a098:	83 c4 04             	add    $0x4,%esp
c010a09b:	c1 e0 0c             	shl    $0xc,%eax
}
c010a09e:	c9                   	leave  
c010a09f:	c3                   	ret    

c010a0a0 <page2kva>:
page2kva(struct Page *page) {
c010a0a0:	55                   	push   %ebp
c010a0a1:	89 e5                	mov    %esp,%ebp
c010a0a3:	53                   	push   %ebx
c010a0a4:	83 ec 14             	sub    $0x14,%esp
c010a0a7:	e8 15 62 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a0ac:	81 c3 d4 f8 01 00    	add    $0x1f8d4,%ebx
    return KADDR(page2pa(page));
c010a0b2:	ff 75 08             	pushl  0x8(%ebp)
c010a0b5:	e8 c9 ff ff ff       	call   c010a083 <page2pa>
c010a0ba:	83 c4 04             	add    $0x4,%esp
c010a0bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a0c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0c3:	c1 e8 0c             	shr    $0xc,%eax
c010a0c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a0c9:	c7 c0 c0 aa 12 c0    	mov    $0xc012aac0,%eax
c010a0cf:	8b 00                	mov    (%eax),%eax
c010a0d1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010a0d4:	72 18                	jb     c010a0ee <page2kva+0x4e>
c010a0d6:	ff 75 f4             	pushl  -0xc(%ebp)
c010a0d9:	8d 83 14 43 fe ff    	lea    -0x1bcec(%ebx),%eax
c010a0df:	50                   	push   %eax
c010a0e0:	6a 66                	push   $0x66
c010a0e2:	8d 83 37 43 fe ff    	lea    -0x1bcc9(%ebx),%eax
c010a0e8:	50                   	push   %eax
c010a0e9:	e8 24 79 ff ff       	call   c0101a12 <__panic>
c010a0ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0f1:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010a0f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a0f9:	c9                   	leave  
c010a0fa:	c3                   	ret    

c010a0fb <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010a0fb:	55                   	push   %ebp
c010a0fc:	89 e5                	mov    %esp,%ebp
c010a0fe:	53                   	push   %ebx
c010a0ff:	83 ec 04             	sub    $0x4,%esp
c010a102:	e8 ba 61 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a107:	81 c3 79 f8 01 00    	add    $0x1f879,%ebx
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010a10d:	83 ec 0c             	sub    $0xc,%esp
c010a110:	6a 01                	push   $0x1
c010a112:	e8 e7 86 ff ff       	call   c01027fe <ide_device_valid>
c010a117:	83 c4 10             	add    $0x10,%esp
c010a11a:	85 c0                	test   %eax,%eax
c010a11c:	75 18                	jne    c010a136 <swapfs_init+0x3b>
        panic("swap fs isn't available.\n");
c010a11e:	83 ec 04             	sub    $0x4,%esp
c010a121:	8d 83 45 43 fe ff    	lea    -0x1bcbb(%ebx),%eax
c010a127:	50                   	push   %eax
c010a128:	6a 0d                	push   $0xd
c010a12a:	8d 83 5f 43 fe ff    	lea    -0x1bca1(%ebx),%eax
c010a130:	50                   	push   %eax
c010a131:	e8 dc 78 ff ff       	call   c0101a12 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010a136:	83 ec 0c             	sub    $0xc,%esp
c010a139:	6a 01                	push   $0x1
c010a13b:	e8 00 87 ff ff       	call   c0102840 <ide_device_size>
c010a140:	83 c4 10             	add    $0x10,%esp
c010a143:	c1 e8 03             	shr    $0x3,%eax
c010a146:	89 c2                	mov    %eax,%edx
c010a148:	c7 c0 5c cc 12 c0    	mov    $0xc012cc5c,%eax
c010a14e:	89 10                	mov    %edx,(%eax)
}
c010a150:	90                   	nop
c010a151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a154:	c9                   	leave  
c010a155:	c3                   	ret    

c010a156 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010a156:	55                   	push   %ebp
c010a157:	89 e5                	mov    %esp,%ebp
c010a159:	53                   	push   %ebx
c010a15a:	83 ec 14             	sub    $0x14,%esp
c010a15d:	e8 5f 61 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a162:	81 c3 1e f8 01 00    	add    $0x1f81e,%ebx
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010a168:	83 ec 0c             	sub    $0xc,%esp
c010a16b:	ff 75 0c             	pushl  0xc(%ebp)
c010a16e:	e8 2d ff ff ff       	call   c010a0a0 <page2kva>
c010a173:	83 c4 10             	add    $0x10,%esp
c010a176:	89 c2                	mov    %eax,%edx
c010a178:	8b 45 08             	mov    0x8(%ebp),%eax
c010a17b:	c1 e8 08             	shr    $0x8,%eax
c010a17e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a181:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a185:	74 0d                	je     c010a194 <swapfs_read+0x3e>
c010a187:	c7 c0 5c cc 12 c0    	mov    $0xc012cc5c,%eax
c010a18d:	8b 00                	mov    (%eax),%eax
c010a18f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a192:	72 18                	jb     c010a1ac <swapfs_read+0x56>
c010a194:	ff 75 08             	pushl  0x8(%ebp)
c010a197:	8d 83 70 43 fe ff    	lea    -0x1bc90(%ebx),%eax
c010a19d:	50                   	push   %eax
c010a19e:	6a 14                	push   $0x14
c010a1a0:	8d 83 5f 43 fe ff    	lea    -0x1bca1(%ebx),%eax
c010a1a6:	50                   	push   %eax
c010a1a7:	e8 66 78 ff ff       	call   c0101a12 <__panic>
c010a1ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a1af:	c1 e0 03             	shl    $0x3,%eax
c010a1b2:	6a 08                	push   $0x8
c010a1b4:	52                   	push   %edx
c010a1b5:	50                   	push   %eax
c010a1b6:	6a 01                	push   $0x1
c010a1b8:	e8 ca 86 ff ff       	call   c0102887 <ide_read_secs>
c010a1bd:	83 c4 10             	add    $0x10,%esp
}
c010a1c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a1c3:	c9                   	leave  
c010a1c4:	c3                   	ret    

c010a1c5 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010a1c5:	55                   	push   %ebp
c010a1c6:	89 e5                	mov    %esp,%ebp
c010a1c8:	53                   	push   %ebx
c010a1c9:	83 ec 14             	sub    $0x14,%esp
c010a1cc:	e8 f0 60 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a1d1:	81 c3 af f7 01 00    	add    $0x1f7af,%ebx
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010a1d7:	83 ec 0c             	sub    $0xc,%esp
c010a1da:	ff 75 0c             	pushl  0xc(%ebp)
c010a1dd:	e8 be fe ff ff       	call   c010a0a0 <page2kva>
c010a1e2:	83 c4 10             	add    $0x10,%esp
c010a1e5:	89 c2                	mov    %eax,%edx
c010a1e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1ea:	c1 e8 08             	shr    $0x8,%eax
c010a1ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a1f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a1f4:	74 0d                	je     c010a203 <swapfs_write+0x3e>
c010a1f6:	c7 c0 5c cc 12 c0    	mov    $0xc012cc5c,%eax
c010a1fc:	8b 00                	mov    (%eax),%eax
c010a1fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a201:	72 18                	jb     c010a21b <swapfs_write+0x56>
c010a203:	ff 75 08             	pushl  0x8(%ebp)
c010a206:	8d 83 70 43 fe ff    	lea    -0x1bc90(%ebx),%eax
c010a20c:	50                   	push   %eax
c010a20d:	6a 19                	push   $0x19
c010a20f:	8d 83 5f 43 fe ff    	lea    -0x1bca1(%ebx),%eax
c010a215:	50                   	push   %eax
c010a216:	e8 f7 77 ff ff       	call   c0101a12 <__panic>
c010a21b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a21e:	c1 e0 03             	shl    $0x3,%eax
c010a221:	6a 08                	push   $0x8
c010a223:	52                   	push   %edx
c010a224:	50                   	push   %eax
c010a225:	6a 01                	push   $0x1
c010a227:	e8 98 88 ff ff       	call   c0102ac4 <ide_write_secs>
c010a22c:	83 c4 10             	add    $0x10,%esp
}
c010a22f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a232:	c9                   	leave  
c010a233:	c3                   	ret    

c010a234 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010a234:	52                   	push   %edx
    call *%ebx              # call fn
c010a235:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c010a237:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c010a238:	e8 92 09 00 00       	call   c010abcf <do_exit>

c010a23d <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010a23d:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010a241:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010a243:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010a246:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010a249:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010a24c:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010a24f:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010a252:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010a255:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010a258:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010a25c:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010a25f:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010a262:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010a265:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010a268:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010a26b:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010a26e:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010a271:	ff 30                	pushl  (%eax)

    ret
c010a273:	c3                   	ret    

c010a274 <__intr_save>:
__intr_save(void) {
c010a274:	55                   	push   %ebp
c010a275:	89 e5                	mov    %esp,%ebp
c010a277:	53                   	push   %ebx
c010a278:	83 ec 14             	sub    $0x14,%esp
c010a27b:	e8 3d 60 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a280:	05 00 f7 01 00       	add    $0x1f700,%eax
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010a285:	9c                   	pushf  
c010a286:	5a                   	pop    %edx
c010a287:	89 55 f4             	mov    %edx,-0xc(%ebp)
    return eflags;
c010a28a:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if (read_eflags() & FL_IF) {
c010a28d:	81 e2 00 02 00 00    	and    $0x200,%edx
c010a293:	85 d2                	test   %edx,%edx
c010a295:	74 0e                	je     c010a2a5 <__intr_save+0x31>
        intr_disable();
c010a297:	89 c3                	mov    %eax,%ebx
c010a299:	e8 de 96 ff ff       	call   c010397c <intr_disable>
        return 1;
c010a29e:	b8 01 00 00 00       	mov    $0x1,%eax
c010a2a3:	eb 05                	jmp    c010a2aa <__intr_save+0x36>
    return 0;
c010a2a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a2aa:	83 c4 14             	add    $0x14,%esp
c010a2ad:	5b                   	pop    %ebx
c010a2ae:	5d                   	pop    %ebp
c010a2af:	c3                   	ret    

c010a2b0 <__intr_restore>:
__intr_restore(bool flag) {
c010a2b0:	55                   	push   %ebp
c010a2b1:	89 e5                	mov    %esp,%ebp
c010a2b3:	53                   	push   %ebx
c010a2b4:	83 ec 04             	sub    $0x4,%esp
c010a2b7:	e8 01 60 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a2bc:	05 c4 f6 01 00       	add    $0x1f6c4,%eax
    if (flag) {
c010a2c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a2c5:	74 07                	je     c010a2ce <__intr_restore+0x1e>
        intr_enable();
c010a2c7:	89 c3                	mov    %eax,%ebx
c010a2c9:	e8 9d 96 ff ff       	call   c010396b <intr_enable>
}
c010a2ce:	90                   	nop
c010a2cf:	83 c4 04             	add    $0x4,%esp
c010a2d2:	5b                   	pop    %ebx
c010a2d3:	5d                   	pop    %ebp
c010a2d4:	c3                   	ret    

c010a2d5 <page2ppn>:
page2ppn(struct Page *page) {
c010a2d5:	55                   	push   %ebp
c010a2d6:	89 e5                	mov    %esp,%ebp
c010a2d8:	e8 e0 5f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a2dd:	05 a3 f6 01 00       	add    $0x1f6a3,%eax
    return page - pages;
c010a2e2:	8b 55 08             	mov    0x8(%ebp),%edx
c010a2e5:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c010a2eb:	8b 00                	mov    (%eax),%eax
c010a2ed:	29 c2                	sub    %eax,%edx
c010a2ef:	89 d0                	mov    %edx,%eax
c010a2f1:	c1 f8 02             	sar    $0x2,%eax
c010a2f4:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c010a2fa:	5d                   	pop    %ebp
c010a2fb:	c3                   	ret    

c010a2fc <page2pa>:
page2pa(struct Page *page) {
c010a2fc:	55                   	push   %ebp
c010a2fd:	89 e5                	mov    %esp,%ebp
c010a2ff:	e8 b9 5f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a304:	05 7c f6 01 00       	add    $0x1f67c,%eax
    return page2ppn(page) << PGSHIFT;
c010a309:	ff 75 08             	pushl  0x8(%ebp)
c010a30c:	e8 c4 ff ff ff       	call   c010a2d5 <page2ppn>
c010a311:	83 c4 04             	add    $0x4,%esp
c010a314:	c1 e0 0c             	shl    $0xc,%eax
}
c010a317:	c9                   	leave  
c010a318:	c3                   	ret    

c010a319 <pa2page>:
pa2page(uintptr_t pa) {
c010a319:	55                   	push   %ebp
c010a31a:	89 e5                	mov    %esp,%ebp
c010a31c:	53                   	push   %ebx
c010a31d:	83 ec 04             	sub    $0x4,%esp
c010a320:	e8 98 5f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a325:	05 5b f6 01 00       	add    $0x1f65b,%eax
    if (PPN(pa) >= npage) {
c010a32a:	8b 55 08             	mov    0x8(%ebp),%edx
c010a32d:	89 d1                	mov    %edx,%ecx
c010a32f:	c1 e9 0c             	shr    $0xc,%ecx
c010a332:	c7 c2 c0 aa 12 c0    	mov    $0xc012aac0,%edx
c010a338:	8b 12                	mov    (%edx),%edx
c010a33a:	39 d1                	cmp    %edx,%ecx
c010a33c:	72 1a                	jb     c010a358 <pa2page+0x3f>
        panic("pa2page called with invalid pa");
c010a33e:	83 ec 04             	sub    $0x4,%esp
c010a341:	8d 90 90 43 fe ff    	lea    -0x1bc70(%eax),%edx
c010a347:	52                   	push   %edx
c010a348:	6a 5f                	push   $0x5f
c010a34a:	8d 90 af 43 fe ff    	lea    -0x1bc51(%eax),%edx
c010a350:	52                   	push   %edx
c010a351:	89 c3                	mov    %eax,%ebx
c010a353:	e8 ba 76 ff ff       	call   c0101a12 <__panic>
    return &pages[PPN(pa)];
c010a358:	c7 c0 98 cc 12 c0    	mov    $0xc012cc98,%eax
c010a35e:	8b 08                	mov    (%eax),%ecx
c010a360:	8b 45 08             	mov    0x8(%ebp),%eax
c010a363:	c1 e8 0c             	shr    $0xc,%eax
c010a366:	89 c2                	mov    %eax,%edx
c010a368:	89 d0                	mov    %edx,%eax
c010a36a:	c1 e0 03             	shl    $0x3,%eax
c010a36d:	01 d0                	add    %edx,%eax
c010a36f:	c1 e0 02             	shl    $0x2,%eax
c010a372:	01 c8                	add    %ecx,%eax
}
c010a374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a377:	c9                   	leave  
c010a378:	c3                   	ret    

c010a379 <page2kva>:
page2kva(struct Page *page) {
c010a379:	55                   	push   %ebp
c010a37a:	89 e5                	mov    %esp,%ebp
c010a37c:	53                   	push   %ebx
c010a37d:	83 ec 14             	sub    $0x14,%esp
c010a380:	e8 3c 5f ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a385:	81 c3 fb f5 01 00    	add    $0x1f5fb,%ebx
    return KADDR(page2pa(page));
c010a38b:	ff 75 08             	pushl  0x8(%ebp)
c010a38e:	e8 69 ff ff ff       	call   c010a2fc <page2pa>
c010a393:	83 c4 04             	add    $0x4,%esp
c010a396:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a399:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a39c:	c1 e8 0c             	shr    $0xc,%eax
c010a39f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a3a2:	c7 c0 c0 aa 12 c0    	mov    $0xc012aac0,%eax
c010a3a8:	8b 00                	mov    (%eax),%eax
c010a3aa:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010a3ad:	72 18                	jb     c010a3c7 <page2kva+0x4e>
c010a3af:	ff 75 f4             	pushl  -0xc(%ebp)
c010a3b2:	8d 83 c0 43 fe ff    	lea    -0x1bc40(%ebx),%eax
c010a3b8:	50                   	push   %eax
c010a3b9:	6a 66                	push   $0x66
c010a3bb:	8d 83 af 43 fe ff    	lea    -0x1bc51(%ebx),%eax
c010a3c1:	50                   	push   %eax
c010a3c2:	e8 4b 76 ff ff       	call   c0101a12 <__panic>
c010a3c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a3ca:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010a3cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a3d2:	c9                   	leave  
c010a3d3:	c3                   	ret    

c010a3d4 <kva2page>:
kva2page(void *kva) {
c010a3d4:	55                   	push   %ebp
c010a3d5:	89 e5                	mov    %esp,%ebp
c010a3d7:	53                   	push   %ebx
c010a3d8:	83 ec 14             	sub    $0x14,%esp
c010a3db:	e8 dd 5e ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a3e0:	05 a0 f5 01 00       	add    $0x1f5a0,%eax
    return pa2page(PADDR(kva));
c010a3e5:	8b 55 08             	mov    0x8(%ebp),%edx
c010a3e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a3eb:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010a3f2:	77 1a                	ja     c010a40e <kva2page+0x3a>
c010a3f4:	ff 75 f4             	pushl  -0xc(%ebp)
c010a3f7:	8d 90 e4 43 fe ff    	lea    -0x1bc1c(%eax),%edx
c010a3fd:	52                   	push   %edx
c010a3fe:	6a 6b                	push   $0x6b
c010a400:	8d 90 af 43 fe ff    	lea    -0x1bc51(%eax),%edx
c010a406:	52                   	push   %edx
c010a407:	89 c3                	mov    %eax,%ebx
c010a409:	e8 04 76 ff ff       	call   c0101a12 <__panic>
c010a40e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a411:	05 00 00 00 40       	add    $0x40000000,%eax
c010a416:	83 ec 0c             	sub    $0xc,%esp
c010a419:	50                   	push   %eax
c010a41a:	e8 fa fe ff ff       	call   c010a319 <pa2page>
c010a41f:	83 c4 10             	add    $0x10,%esp
}
c010a422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a425:	c9                   	leave  
c010a426:	c3                   	ret    

c010a427 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010a427:	55                   	push   %ebp
c010a428:	89 e5                	mov    %esp,%ebp
c010a42a:	53                   	push   %ebx
c010a42b:	83 ec 14             	sub    $0x14,%esp
c010a42e:	e8 8e 5e ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a433:	81 c3 4d f5 01 00    	add    $0x1f54d,%ebx
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010a439:	83 ec 0c             	sub    $0xc,%esp
c010a43c:	6a 68                	push   $0x68
c010a43e:	e8 8a c0 ff ff       	call   c01064cd <kmalloc>
c010a443:	83 c4 10             	add    $0x10,%esp
c010a446:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010a449:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a44d:	0f 84 93 00 00 00    	je     c010a4e6 <alloc_proc+0xbf>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
     proc->state = PROC_UNINIT;
c010a453:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     proc->pid = -1;
c010a45c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a45f:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
     proc->runs = 0;
c010a466:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a469:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
     proc->kstack = 0;
c010a470:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a473:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     proc->need_resched = 0;
c010a47a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a47d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     proc->parent = NULL;
c010a484:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a487:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
     proc->mm = NULL;
c010a48e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a491:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
     memset(&(proc->context), 0, sizeof(struct context));
c010a498:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a49b:	83 c0 1c             	add    $0x1c,%eax
c010a49e:	83 ec 04             	sub    $0x4,%esp
c010a4a1:	6a 20                	push   $0x20
c010a4a3:	6a 00                	push   $0x0
c010a4a5:	50                   	push   %eax
c010a4a6:	e8 01 0f 00 00       	call   c010b3ac <memset>
c010a4ab:	83 c4 10             	add    $0x10,%esp
     proc->tf = NULL;
c010a4ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a4b1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
     proc->cr3 = boot_cr3;
c010a4b8:	c7 c0 94 cc 12 c0    	mov    $0xc012cc94,%eax
c010a4be:	8b 10                	mov    (%eax),%edx
c010a4c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a4c3:	89 50 40             	mov    %edx,0x40(%eax)
     proc->flags = 0;
c010a4c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a4c9:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
     memset(proc->name, 0, PROC_NAME_LEN);
c010a4d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a4d3:	83 c0 48             	add    $0x48,%eax
c010a4d6:	83 ec 04             	sub    $0x4,%esp
c010a4d9:	6a 0f                	push   $0xf
c010a4db:	6a 00                	push   $0x0
c010a4dd:	50                   	push   %eax
c010a4de:	e8 c9 0e 00 00       	call   c010b3ac <memset>
c010a4e3:	83 c4 10             	add    $0x10,%esp
    }
    return proc;
c010a4e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010a4e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a4ec:	c9                   	leave  
c010a4ed:	c3                   	ret    

c010a4ee <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c010a4ee:	55                   	push   %ebp
c010a4ef:	89 e5                	mov    %esp,%ebp
c010a4f1:	53                   	push   %ebx
c010a4f2:	83 ec 04             	sub    $0x4,%esp
c010a4f5:	e8 c7 5d ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a4fa:	81 c3 86 f4 01 00    	add    $0x1f486,%ebx
    memset(proc->name, 0, sizeof(proc->name));
c010a500:	8b 45 08             	mov    0x8(%ebp),%eax
c010a503:	83 c0 48             	add    $0x48,%eax
c010a506:	83 ec 04             	sub    $0x4,%esp
c010a509:	6a 10                	push   $0x10
c010a50b:	6a 00                	push   $0x0
c010a50d:	50                   	push   %eax
c010a50e:	e8 99 0e 00 00       	call   c010b3ac <memset>
c010a513:	83 c4 10             	add    $0x10,%esp
    return memcpy(proc->name, name, PROC_NAME_LEN);
c010a516:	8b 45 08             	mov    0x8(%ebp),%eax
c010a519:	83 c0 48             	add    $0x48,%eax
c010a51c:	83 ec 04             	sub    $0x4,%esp
c010a51f:	6a 0f                	push   $0xf
c010a521:	ff 75 0c             	pushl  0xc(%ebp)
c010a524:	50                   	push   %eax
c010a525:	e8 79 0f 00 00       	call   c010b4a3 <memcpy>
c010a52a:	83 c4 10             	add    $0x10,%esp
}
c010a52d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a530:	c9                   	leave  
c010a531:	c3                   	ret    

c010a532 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c010a532:	55                   	push   %ebp
c010a533:	89 e5                	mov    %esp,%ebp
c010a535:	53                   	push   %ebx
c010a536:	83 ec 04             	sub    $0x4,%esp
c010a539:	e8 83 5d ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a53e:	81 c3 42 f4 01 00    	add    $0x1f442,%ebx
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c010a544:	83 ec 04             	sub    $0x4,%esp
c010a547:	6a 10                	push   $0x10
c010a549:	6a 00                	push   $0x0
c010a54b:	8d 83 04 32 00 00    	lea    0x3204(%ebx),%eax
c010a551:	50                   	push   %eax
c010a552:	e8 55 0e 00 00       	call   c010b3ac <memset>
c010a557:	83 c4 10             	add    $0x10,%esp
    return memcpy(name, proc->name, PROC_NAME_LEN);
c010a55a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a55d:	83 c0 48             	add    $0x48,%eax
c010a560:	83 ec 04             	sub    $0x4,%esp
c010a563:	6a 0f                	push   $0xf
c010a565:	50                   	push   %eax
c010a566:	8d 83 04 32 00 00    	lea    0x3204(%ebx),%eax
c010a56c:	50                   	push   %eax
c010a56d:	e8 31 0f 00 00       	call   c010b4a3 <memcpy>
c010a572:	83 c4 10             	add    $0x10,%esp
}
c010a575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a578:	c9                   	leave  
c010a579:	c3                   	ret    

c010a57a <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c010a57a:	55                   	push   %ebp
c010a57b:	89 e5                	mov    %esp,%ebp
c010a57d:	83 ec 10             	sub    $0x10,%esp
c010a580:	e8 38 5d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a585:	05 fb f3 01 00       	add    $0x1f3fb,%eax
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010a58a:	c7 c2 9c cc 12 c0    	mov    $0xc012cc9c,%edx
c010a590:	89 55 f8             	mov    %edx,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c010a593:	8b 90 f0 ff ff ff    	mov    -0x10(%eax),%edx
c010a599:	83 c2 01             	add    $0x1,%edx
c010a59c:	89 90 f0 ff ff ff    	mov    %edx,-0x10(%eax)
c010a5a2:	8b 90 f0 ff ff ff    	mov    -0x10(%eax),%edx
c010a5a8:	81 fa ff 1f 00 00    	cmp    $0x1fff,%edx
c010a5ae:	7e 0c                	jle    c010a5bc <get_pid+0x42>
        last_pid = 1;
c010a5b0:	c7 80 f0 ff ff ff 01 	movl   $0x1,-0x10(%eax)
c010a5b7:	00 00 00 
        goto inside;
c010a5ba:	eb 15                	jmp    c010a5d1 <get_pid+0x57>
    }
    if (last_pid >= next_safe) {
c010a5bc:	8b 88 f0 ff ff ff    	mov    -0x10(%eax),%ecx
c010a5c2:	8b 90 f4 ff ff ff    	mov    -0xc(%eax),%edx
c010a5c8:	39 d1                	cmp    %edx,%ecx
c010a5ca:	0f 8c b9 00 00 00    	jl     c010a689 <get_pid+0x10f>
    inside:
c010a5d0:	90                   	nop
        next_safe = MAX_PID;
c010a5d1:	c7 80 f4 ff ff ff 00 	movl   $0x2000,-0xc(%eax)
c010a5d8:	20 00 00 
    repeat:
        le = list;
c010a5db:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010a5de:	89 55 fc             	mov    %edx,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c010a5e1:	e9 88 00 00 00       	jmp    c010a66e <get_pid+0xf4>
            proc = le2proc(le, list_link);
c010a5e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a5e9:	83 ea 58             	sub    $0x58,%edx
c010a5ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if (proc->pid == last_pid) {
c010a5ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a5f2:	8b 4a 04             	mov    0x4(%edx),%ecx
c010a5f5:	8b 90 f0 ff ff ff    	mov    -0x10(%eax),%edx
c010a5fb:	39 d1                	cmp    %edx,%ecx
c010a5fd:	75 43                	jne    c010a642 <get_pid+0xc8>
                if (++ last_pid >= next_safe) {
c010a5ff:	8b 90 f0 ff ff ff    	mov    -0x10(%eax),%edx
c010a605:	83 c2 01             	add    $0x1,%edx
c010a608:	89 90 f0 ff ff ff    	mov    %edx,-0x10(%eax)
c010a60e:	8b 88 f0 ff ff ff    	mov    -0x10(%eax),%ecx
c010a614:	8b 90 f4 ff ff ff    	mov    -0xc(%eax),%edx
c010a61a:	39 d1                	cmp    %edx,%ecx
c010a61c:	7c 50                	jl     c010a66e <get_pid+0xf4>
                    if (last_pid >= MAX_PID) {
c010a61e:	8b 90 f0 ff ff ff    	mov    -0x10(%eax),%edx
c010a624:	81 fa ff 1f 00 00    	cmp    $0x1fff,%edx
c010a62a:	7e 0a                	jle    c010a636 <get_pid+0xbc>
                        last_pid = 1;
c010a62c:	c7 80 f0 ff ff ff 01 	movl   $0x1,-0x10(%eax)
c010a633:	00 00 00 
                    }
                    next_safe = MAX_PID;
c010a636:	c7 80 f4 ff ff ff 00 	movl   $0x2000,-0xc(%eax)
c010a63d:	20 00 00 
                    goto repeat;
c010a640:	eb 99                	jmp    c010a5db <get_pid+0x61>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c010a642:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a645:	8b 4a 04             	mov    0x4(%edx),%ecx
c010a648:	8b 90 f0 ff ff ff    	mov    -0x10(%eax),%edx
c010a64e:	39 d1                	cmp    %edx,%ecx
c010a650:	7e 1c                	jle    c010a66e <get_pid+0xf4>
c010a652:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a655:	8b 4a 04             	mov    0x4(%edx),%ecx
c010a658:	8b 90 f4 ff ff ff    	mov    -0xc(%eax),%edx
c010a65e:	39 d1                	cmp    %edx,%ecx
c010a660:	7d 0c                	jge    c010a66e <get_pid+0xf4>
                next_safe = proc->pid;
c010a662:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a665:	8b 52 04             	mov    0x4(%edx),%edx
c010a668:	89 90 f4 ff ff ff    	mov    %edx,-0xc(%eax)
c010a66e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a671:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a674:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a677:	8b 52 04             	mov    0x4(%edx),%edx
        while ((le = list_next(le)) != list) {
c010a67a:	89 55 fc             	mov    %edx,-0x4(%ebp)
c010a67d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a680:	3b 55 f8             	cmp    -0x8(%ebp),%edx
c010a683:	0f 85 5d ff ff ff    	jne    c010a5e6 <get_pid+0x6c>
            }
        }
    }
    return last_pid;
c010a689:	8b 80 f0 ff ff ff    	mov    -0x10(%eax),%eax
}
c010a68f:	c9                   	leave  
c010a690:	c3                   	ret    

c010a691 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010a691:	55                   	push   %ebp
c010a692:	89 e5                	mov    %esp,%ebp
c010a694:	53                   	push   %ebx
c010a695:	83 ec 14             	sub    $0x14,%esp
c010a698:	e8 24 5c ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a69d:	81 c3 e3 f2 01 00    	add    $0x1f2e3,%ebx
    if (proc != current) {
c010a6a3:	8b 83 e8 11 00 00    	mov    0x11e8(%ebx),%eax
c010a6a9:	39 45 08             	cmp    %eax,0x8(%ebp)
c010a6ac:	74 6d                	je     c010a71b <proc_run+0x8a>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c010a6ae:	8b 83 e8 11 00 00    	mov    0x11e8(%ebx),%eax
c010a6b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a6b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c010a6bd:	e8 b2 fb ff ff       	call   c010a274 <__intr_save>
c010a6c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c010a6c5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6c8:	89 83 e8 11 00 00    	mov    %eax,0x11e8(%ebx)
            load_esp0(next->kstack + KSTACKSIZE);
c010a6ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a6d1:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6d4:	05 00 20 00 00       	add    $0x2000,%eax
c010a6d9:	83 ec 0c             	sub    $0xc,%esp
c010a6dc:	50                   	push   %eax
c010a6dd:	e8 89 df ff ff       	call   c010866b <load_esp0>
c010a6e2:	83 c4 10             	add    $0x10,%esp
            lcr3(next->cr3);
c010a6e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a6e8:	8b 40 40             	mov    0x40(%eax),%eax
c010a6eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010a6ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a6f1:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c010a6f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a6f7:	8d 50 1c             	lea    0x1c(%eax),%edx
c010a6fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a6fd:	83 c0 1c             	add    $0x1c,%eax
c010a700:	83 ec 08             	sub    $0x8,%esp
c010a703:	52                   	push   %edx
c010a704:	50                   	push   %eax
c010a705:	e8 33 fb ff ff       	call   c010a23d <switch_to>
c010a70a:	83 c4 10             	add    $0x10,%esp
        }
        local_intr_restore(intr_flag);
c010a70d:	83 ec 0c             	sub    $0xc,%esp
c010a710:	ff 75 ec             	pushl  -0x14(%ebp)
c010a713:	e8 98 fb ff ff       	call   c010a2b0 <__intr_restore>
c010a718:	83 c4 10             	add    $0x10,%esp
    }
}
c010a71b:	90                   	nop
c010a71c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a71f:	c9                   	leave  
c010a720:	c3                   	ret    

c010a721 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c010a721:	55                   	push   %ebp
c010a722:	89 e5                	mov    %esp,%ebp
c010a724:	53                   	push   %ebx
c010a725:	83 ec 04             	sub    $0x4,%esp
c010a728:	e8 90 5b ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a72d:	05 53 f2 01 00       	add    $0x1f253,%eax
    forkrets(current->tf);
c010a732:	8b 90 e8 11 00 00    	mov    0x11e8(%eax),%edx
c010a738:	8b 52 3c             	mov    0x3c(%edx),%edx
c010a73b:	83 ec 0c             	sub    $0xc,%esp
c010a73e:	52                   	push   %edx
c010a73f:	89 c3                	mov    %eax,%ebx
c010a741:	e8 00 a4 ff ff       	call   c0104b46 <forkrets>
c010a746:	83 c4 10             	add    $0x10,%esp
}
c010a749:	90                   	nop
c010a74a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a74d:	c9                   	leave  
c010a74e:	c3                   	ret    

c010a74f <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c010a74f:	55                   	push   %ebp
c010a750:	89 e5                	mov    %esp,%ebp
c010a752:	56                   	push   %esi
c010a753:	53                   	push   %ebx
c010a754:	83 ec 20             	sub    $0x20,%esp
c010a757:	e8 65 5b ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a75c:	81 c3 24 f2 01 00    	add    $0x1f224,%ebx
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c010a762:	8b 45 08             	mov    0x8(%ebp),%eax
c010a765:	8d 70 60             	lea    0x60(%eax),%esi
c010a768:	8b 45 08             	mov    0x8(%ebp),%eax
c010a76b:	8b 40 04             	mov    0x4(%eax),%eax
c010a76e:	83 ec 08             	sub    $0x8,%esp
c010a771:	6a 0a                	push   $0xa
c010a773:	50                   	push   %eax
c010a774:	e8 5f 14 00 00       	call   c010bbd8 <hash32>
c010a779:	83 c4 10             	add    $0x10,%esp
c010a77c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010a783:	8d 83 00 12 00 00    	lea    0x1200(%ebx),%eax
c010a789:	01 d0                	add    %edx,%eax
c010a78b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a78e:	89 75 f0             	mov    %esi,-0x10(%ebp)
c010a791:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a794:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a797:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a79a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c010a79d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7a0:	8b 40 04             	mov    0x4(%eax),%eax
c010a7a3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a7a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a7a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a7ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010a7af:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c010a7b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a7b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a7b8:	89 10                	mov    %edx,(%eax)
c010a7ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a7bd:	8b 10                	mov    (%eax),%edx
c010a7bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a7c2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010a7c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a7c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010a7cb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010a7ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a7d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010a7d4:	89 10                	mov    %edx,(%eax)
}
c010a7d6:	90                   	nop
c010a7d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010a7da:	5b                   	pop    %ebx
c010a7db:	5e                   	pop    %esi
c010a7dc:	5d                   	pop    %ebp
c010a7dd:	c3                   	ret    

c010a7de <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c010a7de:	55                   	push   %ebp
c010a7df:	89 e5                	mov    %esp,%ebp
c010a7e1:	53                   	push   %ebx
c010a7e2:	83 ec 14             	sub    $0x14,%esp
c010a7e5:	e8 d7 5a ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a7ea:	81 c3 96 f1 01 00    	add    $0x1f196,%ebx
    if (0 < pid && pid < MAX_PID) {
c010a7f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a7f4:	7e 64                	jle    c010a85a <find_proc+0x7c>
c010a7f6:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c010a7fd:	7f 5b                	jg     c010a85a <find_proc+0x7c>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c010a7ff:	8b 45 08             	mov    0x8(%ebp),%eax
c010a802:	83 ec 08             	sub    $0x8,%esp
c010a805:	6a 0a                	push   $0xa
c010a807:	50                   	push   %eax
c010a808:	e8 cb 13 00 00       	call   c010bbd8 <hash32>
c010a80d:	83 c4 10             	add    $0x10,%esp
c010a810:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010a817:	8d 83 00 12 00 00    	lea    0x1200(%ebx),%eax
c010a81d:	01 d0                	add    %edx,%eax
c010a81f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a822:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a825:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c010a828:	eb 19                	jmp    c010a843 <find_proc+0x65>
            struct proc_struct *proc = le2proc(le, hash_link);
c010a82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a82d:	83 e8 60             	sub    $0x60,%eax
c010a830:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c010a833:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a836:	8b 40 04             	mov    0x4(%eax),%eax
c010a839:	39 45 08             	cmp    %eax,0x8(%ebp)
c010a83c:	75 05                	jne    c010a843 <find_proc+0x65>
                return proc;
c010a83e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a841:	eb 1c                	jmp    c010a85f <find_proc+0x81>
c010a843:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a846:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c010a849:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a84c:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c010a84f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a852:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a855:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010a858:	75 d0                	jne    c010a82a <find_proc+0x4c>
            }
        }
    }
    return NULL;
c010a85a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a85f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a862:	c9                   	leave  
c010a863:	c3                   	ret    

c010a864 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c010a864:	55                   	push   %ebp
c010a865:	89 e5                	mov    %esp,%ebp
c010a867:	53                   	push   %ebx
c010a868:	83 ec 54             	sub    $0x54,%esp
c010a86b:	e8 51 5a ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a870:	81 c3 10 f1 01 00    	add    $0x1f110,%ebx
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c010a876:	83 ec 04             	sub    $0x4,%esp
c010a879:	6a 4c                	push   $0x4c
c010a87b:	6a 00                	push   $0x0
c010a87d:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010a880:	50                   	push   %eax
c010a881:	e8 26 0b 00 00       	call   c010b3ac <memset>
c010a886:	83 c4 10             	add    $0x10,%esp
    tf.tf_cs = KERNEL_CS;
c010a889:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c010a88f:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c010a895:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010a899:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c010a89d:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c010a8a1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c010a8a5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8a8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c010a8ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a8ae:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c010a8b1:	c7 c0 34 a2 10 c0    	mov    $0xc010a234,%eax
c010a8b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c010a8ba:	8b 45 10             	mov    0x10(%ebp),%eax
c010a8bd:	80 cc 01             	or     $0x1,%ah
c010a8c0:	89 c2                	mov    %eax,%edx
c010a8c2:	83 ec 04             	sub    $0x4,%esp
c010a8c5:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010a8c8:	50                   	push   %eax
c010a8c9:	6a 00                	push   $0x0
c010a8cb:	52                   	push   %edx
c010a8cc:	e8 8c 01 00 00       	call   c010aa5d <do_fork>
c010a8d1:	83 c4 10             	add    $0x10,%esp
}
c010a8d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a8d7:	c9                   	leave  
c010a8d8:	c3                   	ret    

c010a8d9 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c010a8d9:	55                   	push   %ebp
c010a8da:	89 e5                	mov    %esp,%ebp
c010a8dc:	53                   	push   %ebx
c010a8dd:	83 ec 14             	sub    $0x14,%esp
c010a8e0:	e8 d8 59 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a8e5:	05 9b f0 01 00       	add    $0x1f09b,%eax
    struct Page *page = alloc_pages(KSTACKPAGE);
c010a8ea:	83 ec 0c             	sub    $0xc,%esp
c010a8ed:	6a 02                	push   $0x2
c010a8ef:	89 c3                	mov    %eax,%ebx
c010a8f1:	e8 1d df ff ff       	call   c0108813 <alloc_pages>
c010a8f6:	83 c4 10             	add    $0x10,%esp
c010a8f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010a8fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a900:	74 1d                	je     c010a91f <setup_kstack+0x46>
        proc->kstack = (uintptr_t)page2kva(page);
c010a902:	83 ec 0c             	sub    $0xc,%esp
c010a905:	ff 75 f4             	pushl  -0xc(%ebp)
c010a908:	e8 6c fa ff ff       	call   c010a379 <page2kva>
c010a90d:	83 c4 10             	add    $0x10,%esp
c010a910:	89 c2                	mov    %eax,%edx
c010a912:	8b 45 08             	mov    0x8(%ebp),%eax
c010a915:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c010a918:	b8 00 00 00 00       	mov    $0x0,%eax
c010a91d:	eb 05                	jmp    c010a924 <setup_kstack+0x4b>
    }
    return -E_NO_MEM;
c010a91f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c010a924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a927:	c9                   	leave  
c010a928:	c3                   	ret    

c010a929 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c010a929:	55                   	push   %ebp
c010a92a:	89 e5                	mov    %esp,%ebp
c010a92c:	53                   	push   %ebx
c010a92d:	83 ec 04             	sub    $0x4,%esp
c010a930:	e8 8c 59 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010a935:	81 c3 4b f0 01 00    	add    $0x1f04b,%ebx
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c010a93b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a93e:	8b 40 0c             	mov    0xc(%eax),%eax
c010a941:	83 ec 0c             	sub    $0xc,%esp
c010a944:	50                   	push   %eax
c010a945:	e8 8a fa ff ff       	call   c010a3d4 <kva2page>
c010a94a:	83 c4 10             	add    $0x10,%esp
c010a94d:	83 ec 08             	sub    $0x8,%esp
c010a950:	6a 02                	push   $0x2
c010a952:	50                   	push   %eax
c010a953:	e8 3f df ff ff       	call   c0108897 <free_pages>
c010a958:	83 c4 10             	add    $0x10,%esp
}
c010a95b:	90                   	nop
c010a95c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a95f:	c9                   	leave  
c010a960:	c3                   	ret    

c010a961 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c010a961:	55                   	push   %ebp
c010a962:	89 e5                	mov    %esp,%ebp
c010a964:	53                   	push   %ebx
c010a965:	83 ec 04             	sub    $0x4,%esp
c010a968:	e8 50 59 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a96d:	05 13 f0 01 00       	add    $0x1f013,%eax
    assert(current->mm == NULL);
c010a972:	8b 90 e8 11 00 00    	mov    0x11e8(%eax),%edx
c010a978:	8b 52 18             	mov    0x18(%edx),%edx
c010a97b:	85 d2                	test   %edx,%edx
c010a97d:	74 21                	je     c010a9a0 <copy_mm+0x3f>
c010a97f:	8d 90 08 44 fe ff    	lea    -0x1bbf8(%eax),%edx
c010a985:	52                   	push   %edx
c010a986:	8d 90 1c 44 fe ff    	lea    -0x1bbe4(%eax),%edx
c010a98c:	52                   	push   %edx
c010a98d:	68 fe 00 00 00       	push   $0xfe
c010a992:	8d 90 31 44 fe ff    	lea    -0x1bbcf(%eax),%edx
c010a998:	52                   	push   %edx
c010a999:	89 c3                	mov    %eax,%ebx
c010a99b:	e8 72 70 ff ff       	call   c0101a12 <__panic>
    /* do nothing in this project */
    return 0;
c010a9a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a9a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010a9a8:	c9                   	leave  
c010a9a9:	c3                   	ret    

c010a9aa <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c010a9aa:	55                   	push   %ebp
c010a9ab:	89 e5                	mov    %esp,%ebp
c010a9ad:	57                   	push   %edi
c010a9ae:	56                   	push   %esi
c010a9af:	53                   	push   %ebx
c010a9b0:	83 ec 04             	sub    $0x4,%esp
c010a9b3:	e8 05 59 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010a9b8:	05 c8 ef 01 00       	add    $0x1efc8,%eax
c010a9bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c010a9c0:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9c3:	8b 40 0c             	mov    0xc(%eax),%eax
c010a9c6:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c010a9cb:	89 c2                	mov    %eax,%edx
c010a9cd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9d0:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c010a9d3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9d6:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a9d9:	8b 55 10             	mov    0x10(%ebp),%edx
c010a9dc:	89 d3                	mov    %edx,%ebx
c010a9de:	ba 4c 00 00 00       	mov    $0x4c,%edx
c010a9e3:	8b 0b                	mov    (%ebx),%ecx
c010a9e5:	89 08                	mov    %ecx,(%eax)
c010a9e7:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
c010a9eb:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
c010a9ef:	8d 78 04             	lea    0x4(%eax),%edi
c010a9f2:	83 e7 fc             	and    $0xfffffffc,%edi
c010a9f5:	29 f8                	sub    %edi,%eax
c010a9f7:	29 c3                	sub    %eax,%ebx
c010a9f9:	01 c2                	add    %eax,%edx
c010a9fb:	83 e2 fc             	and    $0xfffffffc,%edx
c010a9fe:	c1 ea 02             	shr    $0x2,%edx
c010aa01:	89 d0                	mov    %edx,%eax
c010aa03:	89 de                	mov    %ebx,%esi
c010aa05:	89 c1                	mov    %eax,%ecx
c010aa07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    proc->tf->tf_regs.reg_eax = 0;
c010aa09:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa0c:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aa0f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010aa16:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa19:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aa1c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010aa1f:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010aa22:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa25:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aa28:	8b 50 40             	mov    0x40(%eax),%edx
c010aa2b:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa2e:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aa31:	80 ce 02             	or     $0x2,%dh
c010aa34:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010aa37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aa3a:	8d 90 a1 0d fe ff    	lea    -0x1f25f(%eax),%edx
c010aa40:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa43:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010aa46:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa49:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aa4c:	89 c2                	mov    %eax,%edx
c010aa4e:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa51:	89 50 20             	mov    %edx,0x20(%eax)
}
c010aa54:	90                   	nop
c010aa55:	83 c4 04             	add    $0x4,%esp
c010aa58:	5b                   	pop    %ebx
c010aa59:	5e                   	pop    %esi
c010aa5a:	5f                   	pop    %edi
c010aa5b:	5d                   	pop    %ebp
c010aa5c:	c3                   	ret    

c010aa5d <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010aa5d:	55                   	push   %ebp
c010aa5e:	89 e5                	mov    %esp,%ebp
c010aa60:	53                   	push   %ebx
c010aa61:	83 ec 34             	sub    $0x34,%esp
c010aa64:	e8 58 58 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010aa69:	81 c3 17 ef 01 00    	add    $0x1ef17,%ebx
    int ret = -E_NO_FREE_PROC;
c010aa6f:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010aa76:	8b 83 00 32 00 00    	mov    0x3200(%ebx),%eax
c010aa7c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010aa81:	0f 8f 18 01 00 00    	jg     c010ab9f <do_fork+0x142>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010aa87:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
if((proc = alloc_proc()) == NULL)
c010aa8e:	e8 94 f9 ff ff       	call   c010a427 <alloc_proc>
c010aa93:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aa96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010aa9a:	0f 84 02 01 00 00    	je     c010aba2 <do_fork+0x145>
    goto fork_out;
proc->parent = current;
c010aaa0:	8b 93 e8 11 00 00    	mov    0x11e8(%ebx),%edx
c010aaa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aaa9:	89 50 14             	mov    %edx,0x14(%eax)
if(setup_kstack(proc) != 0)
c010aaac:	83 ec 0c             	sub    $0xc,%esp
c010aaaf:	ff 75 f0             	pushl  -0x10(%ebp)
c010aab2:	e8 22 fe ff ff       	call   c010a8d9 <setup_kstack>
c010aab7:	83 c4 10             	add    $0x10,%esp
c010aaba:	85 c0                	test   %eax,%eax
c010aabc:	0f 85 f7 00 00 00    	jne    c010abb9 <do_fork+0x15c>
    goto bad_fork_cleanup_proc;
if(copy_mm(clone_flags, proc) != 0)
c010aac2:	83 ec 08             	sub    $0x8,%esp
c010aac5:	ff 75 f0             	pushl  -0x10(%ebp)
c010aac8:	ff 75 08             	pushl  0x8(%ebp)
c010aacb:	e8 91 fe ff ff       	call   c010a961 <copy_mm>
c010aad0:	83 c4 10             	add    $0x10,%esp
c010aad3:	85 c0                	test   %eax,%eax
c010aad5:	0f 85 cd 00 00 00    	jne    c010aba8 <do_fork+0x14b>
    goto bad_fork_cleanup_kstack;
copy_thread(proc, stack, tf);
c010aadb:	83 ec 04             	sub    $0x4,%esp
c010aade:	ff 75 10             	pushl  0x10(%ebp)
c010aae1:	ff 75 0c             	pushl  0xc(%ebp)
c010aae4:	ff 75 f0             	pushl  -0x10(%ebp)
c010aae7:	e8 be fe ff ff       	call   c010a9aa <copy_thread>
c010aaec:	83 c4 10             	add    $0x10,%esp
bool intr_flag;
local_intr_save(intr_flag);
c010aaef:	e8 80 f7 ff ff       	call   c010a274 <__intr_save>
c010aaf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
{
    proc->pid = get_pid();
c010aaf7:	e8 7e fa ff ff       	call   c010a57a <get_pid>
c010aafc:	89 c2                	mov    %eax,%edx
c010aafe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ab01:	89 50 04             	mov    %edx,0x4(%eax)
    hash_proc(proc);
c010ab04:	83 ec 0c             	sub    $0xc,%esp
c010ab07:	ff 75 f0             	pushl  -0x10(%ebp)
c010ab0a:	e8 40 fc ff ff       	call   c010a74f <hash_proc>
c010ab0f:	83 c4 10             	add    $0x10,%esp
    list_add(&proc_list, &(proc->list_link));
c010ab12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ab15:	83 c0 58             	add    $0x58,%eax
c010ab18:	c7 c2 9c cc 12 c0    	mov    $0xc012cc9c,%edx
c010ab1e:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ab21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010ab24:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ab27:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ab2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ab2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c010ab30:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ab33:	8b 40 04             	mov    0x4(%eax),%eax
c010ab36:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010ab39:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010ab3c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010ab3f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010ab42:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c010ab45:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010ab48:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010ab4b:	89 10                	mov    %edx,(%eax)
c010ab4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010ab50:	8b 10                	mov    (%eax),%edx
c010ab52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010ab55:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010ab58:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010ab5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010ab5e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010ab61:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010ab64:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010ab67:	89 10                	mov    %edx,(%eax)
    nr_process++;
c010ab69:	8b 83 00 32 00 00    	mov    0x3200(%ebx),%eax
c010ab6f:	83 c0 01             	add    $0x1,%eax
c010ab72:	89 83 00 32 00 00    	mov    %eax,0x3200(%ebx)
}
local_intr_restore(intr_flag);
c010ab78:	83 ec 0c             	sub    $0xc,%esp
c010ab7b:	ff 75 ec             	pushl  -0x14(%ebp)
c010ab7e:	e8 2d f7 ff ff       	call   c010a2b0 <__intr_restore>
c010ab83:	83 c4 10             	add    $0x10,%esp
wakeup_proc(proc);
c010ab86:	83 ec 0c             	sub    $0xc,%esp
c010ab89:	ff 75 f0             	pushl  -0x10(%ebp)
c010ab8c:	e8 4d 03 00 00       	call   c010aede <wakeup_proc>
c010ab91:	83 c4 10             	add    $0x10,%esp
ret = proc->pid;
c010ab94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ab97:	8b 40 04             	mov    0x4(%eax),%eax
c010ab9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ab9d:	eb 04                	jmp    c010aba3 <do_fork+0x146>
        goto fork_out;
c010ab9f:	90                   	nop
c010aba0:	eb 01                	jmp    c010aba3 <do_fork+0x146>
    goto fork_out;
c010aba2:	90                   	nop

fork_out:
    return ret;
c010aba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aba6:	eb 22                	jmp    c010abca <do_fork+0x16d>
    goto bad_fork_cleanup_kstack;
c010aba8:	90                   	nop

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010aba9:	83 ec 0c             	sub    $0xc,%esp
c010abac:	ff 75 f0             	pushl  -0x10(%ebp)
c010abaf:	e8 75 fd ff ff       	call   c010a929 <put_kstack>
c010abb4:	83 c4 10             	add    $0x10,%esp
c010abb7:	eb 01                	jmp    c010abba <do_fork+0x15d>
    goto bad_fork_cleanup_proc;
c010abb9:	90                   	nop
bad_fork_cleanup_proc:
    kfree(proc);
c010abba:	83 ec 0c             	sub    $0xc,%esp
c010abbd:	ff 75 f0             	pushl  -0x10(%ebp)
c010abc0:	e8 2a b9 ff ff       	call   c01064ef <kfree>
c010abc5:	83 c4 10             	add    $0x10,%esp
    goto fork_out;
c010abc8:	eb d9                	jmp    c010aba3 <do_fork+0x146>
}
c010abca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010abcd:	c9                   	leave  
c010abce:	c3                   	ret    

c010abcf <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010abcf:	55                   	push   %ebp
c010abd0:	89 e5                	mov    %esp,%ebp
c010abd2:	53                   	push   %ebx
c010abd3:	83 ec 04             	sub    $0x4,%esp
c010abd6:	e8 e2 56 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010abdb:	05 a5 ed 01 00       	add    $0x1eda5,%eax
    panic("process exit!!.\n");
c010abe0:	83 ec 04             	sub    $0x4,%esp
c010abe3:	8d 90 45 44 fe ff    	lea    -0x1bbbb(%eax),%edx
c010abe9:	52                   	push   %edx
c010abea:	68 5b 01 00 00       	push   $0x15b
c010abef:	8d 90 31 44 fe ff    	lea    -0x1bbcf(%eax),%edx
c010abf5:	52                   	push   %edx
c010abf6:	89 c3                	mov    %eax,%ebx
c010abf8:	e8 15 6e ff ff       	call   c0101a12 <__panic>

c010abfd <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010abfd:	55                   	push   %ebp
c010abfe:	89 e5                	mov    %esp,%ebp
c010ac00:	53                   	push   %ebx
c010ac01:	83 ec 04             	sub    $0x4,%esp
c010ac04:	e8 b8 56 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010ac09:	81 c3 77 ed 01 00    	add    $0x1ed77,%ebx
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c010ac0f:	8b 83 e8 11 00 00    	mov    0x11e8(%ebx),%eax
c010ac15:	83 ec 0c             	sub    $0xc,%esp
c010ac18:	50                   	push   %eax
c010ac19:	e8 14 f9 ff ff       	call   c010a532 <get_proc_name>
c010ac1e:	83 c4 10             	add    $0x10,%esp
c010ac21:	89 c2                	mov    %eax,%edx
c010ac23:	8b 83 e8 11 00 00    	mov    0x11e8(%ebx),%eax
c010ac29:	8b 40 04             	mov    0x4(%eax),%eax
c010ac2c:	83 ec 04             	sub    $0x4,%esp
c010ac2f:	52                   	push   %edx
c010ac30:	50                   	push   %eax
c010ac31:	8d 83 58 44 fe ff    	lea    -0x1bba8(%ebx),%eax
c010ac37:	50                   	push   %eax
c010ac38:	e8 f7 56 ff ff       	call   c0100334 <cprintf>
c010ac3d:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"%s\".\n", (const char *)arg);
c010ac40:	83 ec 08             	sub    $0x8,%esp
c010ac43:	ff 75 08             	pushl  0x8(%ebp)
c010ac46:	8d 83 7e 44 fe ff    	lea    -0x1bb82(%ebx),%eax
c010ac4c:	50                   	push   %eax
c010ac4d:	e8 e2 56 ff ff       	call   c0100334 <cprintf>
c010ac52:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c010ac55:	83 ec 0c             	sub    $0xc,%esp
c010ac58:	8d 83 8b 44 fe ff    	lea    -0x1bb75(%ebx),%eax
c010ac5e:	50                   	push   %eax
c010ac5f:	e8 d0 56 ff ff       	call   c0100334 <cprintf>
c010ac64:	83 c4 10             	add    $0x10,%esp
    return 0;
c010ac67:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ac6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010ac6f:	c9                   	leave  
c010ac70:	c3                   	ret    

c010ac71 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010ac71:	55                   	push   %ebp
c010ac72:	89 e5                	mov    %esp,%ebp
c010ac74:	53                   	push   %ebx
c010ac75:	83 ec 14             	sub    $0x14,%esp
c010ac78:	e8 44 56 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010ac7d:	81 c3 03 ed 01 00    	add    $0x1ed03,%ebx
c010ac83:	c7 c0 9c cc 12 c0    	mov    $0xc012cc9c,%eax
c010ac89:	89 45 ec             	mov    %eax,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010ac8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ac8f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ac92:	89 50 04             	mov    %edx,0x4(%eax)
c010ac95:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ac98:	8b 50 04             	mov    0x4(%eax),%edx
c010ac9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ac9e:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010aca0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010aca7:	eb 2d                	jmp    c010acd6 <proc_init+0x65>
        list_init(hash_list + i);
c010aca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010acb3:	8d 83 00 12 00 00    	lea    0x1200(%ebx),%eax
c010acb9:	01 d0                	add    %edx,%eax
c010acbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010acbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acc1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010acc4:	89 50 04             	mov    %edx,0x4(%eax)
c010acc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acca:	8b 50 04             	mov    0x4(%eax),%edx
c010accd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acd0:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010acd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010acd6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010acdd:	7e ca                	jle    c010aca9 <proc_init+0x38>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010acdf:	e8 43 f7 ff ff       	call   c010a427 <alloc_proc>
c010ace4:	89 83 e0 11 00 00    	mov    %eax,0x11e0(%ebx)
c010acea:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010acf0:	85 c0                	test   %eax,%eax
c010acf2:	75 1b                	jne    c010ad0f <proc_init+0x9e>
        panic("cannot alloc idleproc.\n");
c010acf4:	83 ec 04             	sub    $0x4,%esp
c010acf7:	8d 83 a7 44 fe ff    	lea    -0x1bb59(%ebx),%eax
c010acfd:	50                   	push   %eax
c010acfe:	68 73 01 00 00       	push   $0x173
c010ad03:	8d 83 31 44 fe ff    	lea    -0x1bbcf(%ebx),%eax
c010ad09:	50                   	push   %eax
c010ad0a:	e8 03 6d ff ff       	call   c0101a12 <__panic>
    }

    idleproc->pid = 0;
c010ad0f:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010ad15:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010ad1c:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010ad22:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ad28:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010ad2e:	c7 c2 00 70 12 c0    	mov    $0xc0127000,%edx
c010ad34:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010ad37:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010ad3d:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010ad44:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010ad4a:	83 ec 08             	sub    $0x8,%esp
c010ad4d:	8d 93 bf 44 fe ff    	lea    -0x1bb41(%ebx),%edx
c010ad53:	52                   	push   %edx
c010ad54:	50                   	push   %eax
c010ad55:	e8 94 f7 ff ff       	call   c010a4ee <set_proc_name>
c010ad5a:	83 c4 10             	add    $0x10,%esp
    nr_process ++;
c010ad5d:	8b 83 00 32 00 00    	mov    0x3200(%ebx),%eax
c010ad63:	83 c0 01             	add    $0x1,%eax
c010ad66:	89 83 00 32 00 00    	mov    %eax,0x3200(%ebx)

    current = idleproc;
c010ad6c:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010ad72:	89 83 e8 11 00 00    	mov    %eax,0x11e8(%ebx)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c010ad78:	83 ec 04             	sub    $0x4,%esp
c010ad7b:	6a 00                	push   $0x0
c010ad7d:	8d 83 c4 44 fe ff    	lea    -0x1bb3c(%ebx),%eax
c010ad83:	50                   	push   %eax
c010ad84:	8d 83 7d 12 fe ff    	lea    -0x1ed83(%ebx),%eax
c010ad8a:	50                   	push   %eax
c010ad8b:	e8 d4 fa ff ff       	call   c010a864 <kernel_thread>
c010ad90:	83 c4 10             	add    $0x10,%esp
c010ad93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010ad96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ad9a:	7f 1b                	jg     c010adb7 <proc_init+0x146>
        panic("create init_main failed.\n");
c010ad9c:	83 ec 04             	sub    $0x4,%esp
c010ad9f:	8d 83 d2 44 fe ff    	lea    -0x1bb2e(%ebx),%eax
c010ada5:	50                   	push   %eax
c010ada6:	68 81 01 00 00       	push   $0x181
c010adab:	8d 83 31 44 fe ff    	lea    -0x1bbcf(%ebx),%eax
c010adb1:	50                   	push   %eax
c010adb2:	e8 5b 6c ff ff       	call   c0101a12 <__panic>
    }

    initproc = find_proc(pid);
c010adb7:	83 ec 0c             	sub    $0xc,%esp
c010adba:	ff 75 f0             	pushl  -0x10(%ebp)
c010adbd:	e8 1c fa ff ff       	call   c010a7de <find_proc>
c010adc2:	83 c4 10             	add    $0x10,%esp
c010adc5:	89 83 e4 11 00 00    	mov    %eax,0x11e4(%ebx)
    set_proc_name(initproc, "init");
c010adcb:	8b 83 e4 11 00 00    	mov    0x11e4(%ebx),%eax
c010add1:	83 ec 08             	sub    $0x8,%esp
c010add4:	8d 93 ec 44 fe ff    	lea    -0x1bb14(%ebx),%edx
c010adda:	52                   	push   %edx
c010addb:	50                   	push   %eax
c010addc:	e8 0d f7 ff ff       	call   c010a4ee <set_proc_name>
c010ade1:	83 c4 10             	add    $0x10,%esp

    assert(idleproc != NULL && idleproc->pid == 0);
c010ade4:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010adea:	85 c0                	test   %eax,%eax
c010adec:	74 0d                	je     c010adfb <proc_init+0x18a>
c010adee:	8b 83 e0 11 00 00    	mov    0x11e0(%ebx),%eax
c010adf4:	8b 40 04             	mov    0x4(%eax),%eax
c010adf7:	85 c0                	test   %eax,%eax
c010adf9:	74 1f                	je     c010ae1a <proc_init+0x1a9>
c010adfb:	8d 83 f4 44 fe ff    	lea    -0x1bb0c(%ebx),%eax
c010ae01:	50                   	push   %eax
c010ae02:	8d 83 1c 44 fe ff    	lea    -0x1bbe4(%ebx),%eax
c010ae08:	50                   	push   %eax
c010ae09:	68 87 01 00 00       	push   $0x187
c010ae0e:	8d 83 31 44 fe ff    	lea    -0x1bbcf(%ebx),%eax
c010ae14:	50                   	push   %eax
c010ae15:	e8 f8 6b ff ff       	call   c0101a12 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010ae1a:	8b 83 e4 11 00 00    	mov    0x11e4(%ebx),%eax
c010ae20:	85 c0                	test   %eax,%eax
c010ae22:	74 0e                	je     c010ae32 <proc_init+0x1c1>
c010ae24:	8b 83 e4 11 00 00    	mov    0x11e4(%ebx),%eax
c010ae2a:	8b 40 04             	mov    0x4(%eax),%eax
c010ae2d:	83 f8 01             	cmp    $0x1,%eax
c010ae30:	74 1f                	je     c010ae51 <proc_init+0x1e0>
c010ae32:	8d 83 1c 45 fe ff    	lea    -0x1bae4(%ebx),%eax
c010ae38:	50                   	push   %eax
c010ae39:	8d 83 1c 44 fe ff    	lea    -0x1bbe4(%ebx),%eax
c010ae3f:	50                   	push   %eax
c010ae40:	68 88 01 00 00       	push   $0x188
c010ae45:	8d 83 31 44 fe ff    	lea    -0x1bbcf(%ebx),%eax
c010ae4b:	50                   	push   %eax
c010ae4c:	e8 c1 6b ff ff       	call   c0101a12 <__panic>
}
c010ae51:	90                   	nop
c010ae52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010ae55:	c9                   	leave  
c010ae56:	c3                   	ret    

c010ae57 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010ae57:	55                   	push   %ebp
c010ae58:	89 e5                	mov    %esp,%ebp
c010ae5a:	53                   	push   %ebx
c010ae5b:	83 ec 04             	sub    $0x4,%esp
c010ae5e:	e8 5e 54 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010ae63:	81 c3 1d eb 01 00    	add    $0x1eb1d,%ebx
    while (1) {
        if (current->need_resched) {
c010ae69:	8b 83 e8 11 00 00    	mov    0x11e8(%ebx),%eax
c010ae6f:	8b 40 10             	mov    0x10(%eax),%eax
c010ae72:	85 c0                	test   %eax,%eax
c010ae74:	74 f3                	je     c010ae69 <cpu_idle+0x12>
            schedule();
c010ae76:	e8 b5 00 00 00       	call   c010af30 <schedule>
        if (current->need_resched) {
c010ae7b:	eb ec                	jmp    c010ae69 <cpu_idle+0x12>

c010ae7d <__intr_save>:
__intr_save(void) {
c010ae7d:	55                   	push   %ebp
c010ae7e:	89 e5                	mov    %esp,%ebp
c010ae80:	53                   	push   %ebx
c010ae81:	83 ec 14             	sub    $0x14,%esp
c010ae84:	e8 34 54 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010ae89:	05 f7 ea 01 00       	add    $0x1eaf7,%eax
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010ae8e:	9c                   	pushf  
c010ae8f:	5a                   	pop    %edx
c010ae90:	89 55 f4             	mov    %edx,-0xc(%ebp)
    return eflags;
c010ae93:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if (read_eflags() & FL_IF) {
c010ae96:	81 e2 00 02 00 00    	and    $0x200,%edx
c010ae9c:	85 d2                	test   %edx,%edx
c010ae9e:	74 0e                	je     c010aeae <__intr_save+0x31>
        intr_disable();
c010aea0:	89 c3                	mov    %eax,%ebx
c010aea2:	e8 d5 8a ff ff       	call   c010397c <intr_disable>
        return 1;
c010aea7:	b8 01 00 00 00       	mov    $0x1,%eax
c010aeac:	eb 05                	jmp    c010aeb3 <__intr_save+0x36>
    return 0;
c010aeae:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aeb3:	83 c4 14             	add    $0x14,%esp
c010aeb6:	5b                   	pop    %ebx
c010aeb7:	5d                   	pop    %ebp
c010aeb8:	c3                   	ret    

c010aeb9 <__intr_restore>:
__intr_restore(bool flag) {
c010aeb9:	55                   	push   %ebp
c010aeba:	89 e5                	mov    %esp,%ebp
c010aebc:	53                   	push   %ebx
c010aebd:	83 ec 04             	sub    $0x4,%esp
c010aec0:	e8 f8 53 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010aec5:	05 bb ea 01 00       	add    $0x1eabb,%eax
    if (flag) {
c010aeca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aece:	74 07                	je     c010aed7 <__intr_restore+0x1e>
        intr_enable();
c010aed0:	89 c3                	mov    %eax,%ebx
c010aed2:	e8 94 8a ff ff       	call   c010396b <intr_enable>
}
c010aed7:	90                   	nop
c010aed8:	83 c4 04             	add    $0x4,%esp
c010aedb:	5b                   	pop    %ebx
c010aedc:	5d                   	pop    %ebp
c010aedd:	c3                   	ret    

c010aede <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010aede:	55                   	push   %ebp
c010aedf:	89 e5                	mov    %esp,%ebp
c010aee1:	53                   	push   %ebx
c010aee2:	83 ec 04             	sub    $0x4,%esp
c010aee5:	e8 d3 53 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010aeea:	05 96 ea 01 00       	add    $0x1ea96,%eax
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c010aeef:	8b 55 08             	mov    0x8(%ebp),%edx
c010aef2:	8b 12                	mov    (%edx),%edx
c010aef4:	83 fa 03             	cmp    $0x3,%edx
c010aef7:	74 0a                	je     c010af03 <wakeup_proc+0x25>
c010aef9:	8b 55 08             	mov    0x8(%ebp),%edx
c010aefc:	8b 12                	mov    (%edx),%edx
c010aefe:	83 fa 02             	cmp    $0x2,%edx
c010af01:	75 1e                	jne    c010af21 <wakeup_proc+0x43>
c010af03:	8d 90 44 45 fe ff    	lea    -0x1babc(%eax),%edx
c010af09:	52                   	push   %edx
c010af0a:	8d 90 7f 45 fe ff    	lea    -0x1ba81(%eax),%edx
c010af10:	52                   	push   %edx
c010af11:	6a 09                	push   $0x9
c010af13:	8d 90 94 45 fe ff    	lea    -0x1ba6c(%eax),%edx
c010af19:	52                   	push   %edx
c010af1a:	89 c3                	mov    %eax,%ebx
c010af1c:	e8 f1 6a ff ff       	call   c0101a12 <__panic>
    proc->state = PROC_RUNNABLE;
c010af21:	8b 45 08             	mov    0x8(%ebp),%eax
c010af24:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c010af2a:	90                   	nop
c010af2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010af2e:	c9                   	leave  
c010af2f:	c3                   	ret    

c010af30 <schedule>:

void
schedule(void) {
c010af30:	55                   	push   %ebp
c010af31:	89 e5                	mov    %esp,%ebp
c010af33:	53                   	push   %ebx
c010af34:	83 ec 24             	sub    $0x24,%esp
c010af37:	e8 85 53 ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010af3c:	81 c3 44 ea 01 00    	add    $0x1ea44,%ebx
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010af42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010af49:	e8 2f ff ff ff       	call   c010ae7d <__intr_save>
c010af4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010af51:	c7 c0 68 ab 12 c0    	mov    $0xc012ab68,%eax
c010af57:	8b 00                	mov    (%eax),%eax
c010af59:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010af60:	c7 c0 68 ab 12 c0    	mov    $0xc012ab68,%eax
c010af66:	8b 10                	mov    (%eax),%edx
c010af68:	c7 c0 60 ab 12 c0    	mov    $0xc012ab60,%eax
c010af6e:	8b 00                	mov    (%eax),%eax
c010af70:	39 c2                	cmp    %eax,%edx
c010af72:	74 0d                	je     c010af81 <schedule+0x51>
c010af74:	c7 c0 68 ab 12 c0    	mov    $0xc012ab68,%eax
c010af7a:	8b 00                	mov    (%eax),%eax
c010af7c:	83 c0 58             	add    $0x58,%eax
c010af7f:	eb 06                	jmp    c010af87 <schedule+0x57>
c010af81:	c7 c0 9c cc 12 c0    	mov    $0xc012cc9c,%eax
c010af87:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010af8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010af90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010af93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010af96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010af99:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010af9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010af9f:	c7 c0 9c cc 12 c0    	mov    $0xc012cc9c,%eax
c010afa5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010afa8:	74 13                	je     c010afbd <schedule+0x8d>
                next = le2proc(le, list_link);
c010afaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afad:	83 e8 58             	sub    $0x58,%eax
c010afb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010afb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afb6:	8b 00                	mov    (%eax),%eax
c010afb8:	83 f8 02             	cmp    $0x2,%eax
c010afbb:	74 0a                	je     c010afc7 <schedule+0x97>
                    break;
                }
            }
        } while (le != last);
c010afbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afc0:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010afc3:	75 cb                	jne    c010af90 <schedule+0x60>
c010afc5:	eb 01                	jmp    c010afc8 <schedule+0x98>
                    break;
c010afc7:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010afc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010afcc:	74 0a                	je     c010afd8 <schedule+0xa8>
c010afce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afd1:	8b 00                	mov    (%eax),%eax
c010afd3:	83 f8 02             	cmp    $0x2,%eax
c010afd6:	74 0b                	je     c010afe3 <schedule+0xb3>
            next = idleproc;
c010afd8:	c7 c0 60 ab 12 c0    	mov    $0xc012ab60,%eax
c010afde:	8b 00                	mov    (%eax),%eax
c010afe0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010afe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afe6:	8b 40 08             	mov    0x8(%eax),%eax
c010afe9:	8d 50 01             	lea    0x1(%eax),%edx
c010afec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afef:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010aff2:	c7 c0 68 ab 12 c0    	mov    $0xc012ab68,%eax
c010aff8:	8b 00                	mov    (%eax),%eax
c010affa:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010affd:	74 0e                	je     c010b00d <schedule+0xdd>
            proc_run(next);
c010afff:	83 ec 0c             	sub    $0xc,%esp
c010b002:	ff 75 f0             	pushl  -0x10(%ebp)
c010b005:	e8 87 f6 ff ff       	call   c010a691 <proc_run>
c010b00a:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c010b00d:	83 ec 0c             	sub    $0xc,%esp
c010b010:	ff 75 ec             	pushl  -0x14(%ebp)
c010b013:	e8 a1 fe ff ff       	call   c010aeb9 <__intr_restore>
c010b018:	83 c4 10             	add    $0x10,%esp
}
c010b01b:	90                   	nop
c010b01c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010b01f:	c9                   	leave  
c010b020:	c3                   	ret    

c010b021 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b021:	55                   	push   %ebp
c010b022:	89 e5                	mov    %esp,%ebp
c010b024:	83 ec 10             	sub    $0x10,%esp
c010b027:	e8 91 52 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b02c:	05 54 e9 01 00       	add    $0x1e954,%eax
    size_t cnt = 0;
c010b031:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b038:	eb 04                	jmp    c010b03e <strlen+0x1d>
        cnt ++;
c010b03a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b03e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b041:	8d 50 01             	lea    0x1(%eax),%edx
c010b044:	89 55 08             	mov    %edx,0x8(%ebp)
c010b047:	0f b6 00             	movzbl (%eax),%eax
c010b04a:	84 c0                	test   %al,%al
c010b04c:	75 ec                	jne    c010b03a <strlen+0x19>
    }
    return cnt;
c010b04e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b051:	c9                   	leave  
c010b052:	c3                   	ret    

c010b053 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b053:	55                   	push   %ebp
c010b054:	89 e5                	mov    %esp,%ebp
c010b056:	83 ec 10             	sub    $0x10,%esp
c010b059:	e8 5f 52 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b05e:	05 22 e9 01 00       	add    $0x1e922,%eax
    size_t cnt = 0;
c010b063:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b06a:	eb 04                	jmp    c010b070 <strnlen+0x1d>
        cnt ++;
c010b06c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b070:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b073:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b076:	73 10                	jae    c010b088 <strnlen+0x35>
c010b078:	8b 45 08             	mov    0x8(%ebp),%eax
c010b07b:	8d 50 01             	lea    0x1(%eax),%edx
c010b07e:	89 55 08             	mov    %edx,0x8(%ebp)
c010b081:	0f b6 00             	movzbl (%eax),%eax
c010b084:	84 c0                	test   %al,%al
c010b086:	75 e4                	jne    c010b06c <strnlen+0x19>
    }
    return cnt;
c010b088:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b08b:	c9                   	leave  
c010b08c:	c3                   	ret    

c010b08d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b08d:	55                   	push   %ebp
c010b08e:	89 e5                	mov    %esp,%ebp
c010b090:	57                   	push   %edi
c010b091:	56                   	push   %esi
c010b092:	83 ec 20             	sub    $0x20,%esp
c010b095:	e8 23 52 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b09a:	05 e6 e8 01 00       	add    $0x1e8e6,%eax
c010b09f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b0a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b0ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b0ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0b1:	89 d1                	mov    %edx,%ecx
c010b0b3:	89 c2                	mov    %eax,%edx
c010b0b5:	89 ce                	mov    %ecx,%esi
c010b0b7:	89 d7                	mov    %edx,%edi
c010b0b9:	ac                   	lods   %ds:(%esi),%al
c010b0ba:	aa                   	stos   %al,%es:(%edi)
c010b0bb:	84 c0                	test   %al,%al
c010b0bd:	75 fa                	jne    c010b0b9 <strcpy+0x2c>
c010b0bf:	89 fa                	mov    %edi,%edx
c010b0c1:	89 f1                	mov    %esi,%ecx
c010b0c3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b0c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b0c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b0cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c010b0cf:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b0d0:	83 c4 20             	add    $0x20,%esp
c010b0d3:	5e                   	pop    %esi
c010b0d4:	5f                   	pop    %edi
c010b0d5:	5d                   	pop    %ebp
c010b0d6:	c3                   	ret    

c010b0d7 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b0d7:	55                   	push   %ebp
c010b0d8:	89 e5                	mov    %esp,%ebp
c010b0da:	83 ec 10             	sub    $0x10,%esp
c010b0dd:	e8 db 51 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b0e2:	05 9e e8 01 00       	add    $0x1e89e,%eax
    char *p = dst;
c010b0e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b0ed:	eb 21                	jmp    c010b110 <strncpy+0x39>
        if ((*p = *src) != '\0') {
c010b0ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0f2:	0f b6 10             	movzbl (%eax),%edx
c010b0f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b0f8:	88 10                	mov    %dl,(%eax)
c010b0fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b0fd:	0f b6 00             	movzbl (%eax),%eax
c010b100:	84 c0                	test   %al,%al
c010b102:	74 04                	je     c010b108 <strncpy+0x31>
            src ++;
c010b104:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010b108:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b10c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c010b110:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b114:	75 d9                	jne    c010b0ef <strncpy+0x18>
    }
    return dst;
c010b116:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b119:	c9                   	leave  
c010b11a:	c3                   	ret    

c010b11b <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b11b:	55                   	push   %ebp
c010b11c:	89 e5                	mov    %esp,%ebp
c010b11e:	57                   	push   %edi
c010b11f:	56                   	push   %esi
c010b120:	83 ec 20             	sub    $0x20,%esp
c010b123:	e8 95 51 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b128:	05 58 e8 01 00       	add    $0x1e858,%eax
c010b12d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b130:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b133:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b136:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010b139:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b13c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b13f:	89 d1                	mov    %edx,%ecx
c010b141:	89 c2                	mov    %eax,%edx
c010b143:	89 ce                	mov    %ecx,%esi
c010b145:	89 d7                	mov    %edx,%edi
c010b147:	ac                   	lods   %ds:(%esi),%al
c010b148:	ae                   	scas   %es:(%edi),%al
c010b149:	75 08                	jne    c010b153 <strcmp+0x38>
c010b14b:	84 c0                	test   %al,%al
c010b14d:	75 f8                	jne    c010b147 <strcmp+0x2c>
c010b14f:	31 c0                	xor    %eax,%eax
c010b151:	eb 04                	jmp    c010b157 <strcmp+0x3c>
c010b153:	19 c0                	sbb    %eax,%eax
c010b155:	0c 01                	or     $0x1,%al
c010b157:	89 fa                	mov    %edi,%edx
c010b159:	89 f1                	mov    %esi,%ecx
c010b15b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b15e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b161:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010b164:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c010b167:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b168:	83 c4 20             	add    $0x20,%esp
c010b16b:	5e                   	pop    %esi
c010b16c:	5f                   	pop    %edi
c010b16d:	5d                   	pop    %ebp
c010b16e:	c3                   	ret    

c010b16f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b16f:	55                   	push   %ebp
c010b170:	89 e5                	mov    %esp,%ebp
c010b172:	e8 46 51 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b177:	05 09 e8 01 00       	add    $0x1e809,%eax
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b17c:	eb 0c                	jmp    c010b18a <strncmp+0x1b>
        n --, s1 ++, s2 ++;
c010b17e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b182:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b186:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b18a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b18e:	74 1a                	je     c010b1aa <strncmp+0x3b>
c010b190:	8b 45 08             	mov    0x8(%ebp),%eax
c010b193:	0f b6 00             	movzbl (%eax),%eax
c010b196:	84 c0                	test   %al,%al
c010b198:	74 10                	je     c010b1aa <strncmp+0x3b>
c010b19a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b19d:	0f b6 10             	movzbl (%eax),%edx
c010b1a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1a3:	0f b6 00             	movzbl (%eax),%eax
c010b1a6:	38 c2                	cmp    %al,%dl
c010b1a8:	74 d4                	je     c010b17e <strncmp+0xf>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b1aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b1ae:	74 18                	je     c010b1c8 <strncmp+0x59>
c010b1b0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1b3:	0f b6 00             	movzbl (%eax),%eax
c010b1b6:	0f b6 d0             	movzbl %al,%edx
c010b1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1bc:	0f b6 00             	movzbl (%eax),%eax
c010b1bf:	0f b6 c0             	movzbl %al,%eax
c010b1c2:	29 c2                	sub    %eax,%edx
c010b1c4:	89 d0                	mov    %edx,%eax
c010b1c6:	eb 05                	jmp    c010b1cd <strncmp+0x5e>
c010b1c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b1cd:	5d                   	pop    %ebp
c010b1ce:	c3                   	ret    

c010b1cf <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b1cf:	55                   	push   %ebp
c010b1d0:	89 e5                	mov    %esp,%ebp
c010b1d2:	83 ec 04             	sub    $0x4,%esp
c010b1d5:	e8 e3 50 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b1da:	05 a6 e7 01 00       	add    $0x1e7a6,%eax
c010b1df:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1e2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b1e5:	eb 14                	jmp    c010b1fb <strchr+0x2c>
        if (*s == c) {
c010b1e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1ea:	0f b6 00             	movzbl (%eax),%eax
c010b1ed:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b1f0:	75 05                	jne    c010b1f7 <strchr+0x28>
            return (char *)s;
c010b1f2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1f5:	eb 13                	jmp    c010b20a <strchr+0x3b>
        }
        s ++;
c010b1f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b1fb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1fe:	0f b6 00             	movzbl (%eax),%eax
c010b201:	84 c0                	test   %al,%al
c010b203:	75 e2                	jne    c010b1e7 <strchr+0x18>
    }
    return NULL;
c010b205:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b20a:	c9                   	leave  
c010b20b:	c3                   	ret    

c010b20c <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b20c:	55                   	push   %ebp
c010b20d:	89 e5                	mov    %esp,%ebp
c010b20f:	83 ec 04             	sub    $0x4,%esp
c010b212:	e8 a6 50 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b217:	05 69 e7 01 00       	add    $0x1e769,%eax
c010b21c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b21f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b222:	eb 0f                	jmp    c010b233 <strfind+0x27>
        if (*s == c) {
c010b224:	8b 45 08             	mov    0x8(%ebp),%eax
c010b227:	0f b6 00             	movzbl (%eax),%eax
c010b22a:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b22d:	74 10                	je     c010b23f <strfind+0x33>
            break;
        }
        s ++;
c010b22f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b233:	8b 45 08             	mov    0x8(%ebp),%eax
c010b236:	0f b6 00             	movzbl (%eax),%eax
c010b239:	84 c0                	test   %al,%al
c010b23b:	75 e7                	jne    c010b224 <strfind+0x18>
c010b23d:	eb 01                	jmp    c010b240 <strfind+0x34>
            break;
c010b23f:	90                   	nop
    }
    return (char *)s;
c010b240:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b243:	c9                   	leave  
c010b244:	c3                   	ret    

c010b245 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b245:	55                   	push   %ebp
c010b246:	89 e5                	mov    %esp,%ebp
c010b248:	83 ec 10             	sub    $0x10,%esp
c010b24b:	e8 6d 50 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b250:	05 30 e7 01 00       	add    $0x1e730,%eax
    int neg = 0;
c010b255:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b25c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b263:	eb 04                	jmp    c010b269 <strtol+0x24>
        s ++;
c010b265:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010b269:	8b 45 08             	mov    0x8(%ebp),%eax
c010b26c:	0f b6 00             	movzbl (%eax),%eax
c010b26f:	3c 20                	cmp    $0x20,%al
c010b271:	74 f2                	je     c010b265 <strtol+0x20>
c010b273:	8b 45 08             	mov    0x8(%ebp),%eax
c010b276:	0f b6 00             	movzbl (%eax),%eax
c010b279:	3c 09                	cmp    $0x9,%al
c010b27b:	74 e8                	je     c010b265 <strtol+0x20>
    }

    // plus/minus sign
    if (*s == '+') {
c010b27d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b280:	0f b6 00             	movzbl (%eax),%eax
c010b283:	3c 2b                	cmp    $0x2b,%al
c010b285:	75 06                	jne    c010b28d <strtol+0x48>
        s ++;
c010b287:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b28b:	eb 15                	jmp    c010b2a2 <strtol+0x5d>
    }
    else if (*s == '-') {
c010b28d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b290:	0f b6 00             	movzbl (%eax),%eax
c010b293:	3c 2d                	cmp    $0x2d,%al
c010b295:	75 0b                	jne    c010b2a2 <strtol+0x5d>
        s ++, neg = 1;
c010b297:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b29b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b2a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b2a6:	74 06                	je     c010b2ae <strtol+0x69>
c010b2a8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b2ac:	75 24                	jne    c010b2d2 <strtol+0x8d>
c010b2ae:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2b1:	0f b6 00             	movzbl (%eax),%eax
c010b2b4:	3c 30                	cmp    $0x30,%al
c010b2b6:	75 1a                	jne    c010b2d2 <strtol+0x8d>
c010b2b8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2bb:	83 c0 01             	add    $0x1,%eax
c010b2be:	0f b6 00             	movzbl (%eax),%eax
c010b2c1:	3c 78                	cmp    $0x78,%al
c010b2c3:	75 0d                	jne    c010b2d2 <strtol+0x8d>
        s += 2, base = 16;
c010b2c5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b2c9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b2d0:	eb 2a                	jmp    c010b2fc <strtol+0xb7>
    }
    else if (base == 0 && s[0] == '0') {
c010b2d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b2d6:	75 17                	jne    c010b2ef <strtol+0xaa>
c010b2d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2db:	0f b6 00             	movzbl (%eax),%eax
c010b2de:	3c 30                	cmp    $0x30,%al
c010b2e0:	75 0d                	jne    c010b2ef <strtol+0xaa>
        s ++, base = 8;
c010b2e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b2e6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b2ed:	eb 0d                	jmp    c010b2fc <strtol+0xb7>
    }
    else if (base == 0) {
c010b2ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b2f3:	75 07                	jne    c010b2fc <strtol+0xb7>
        base = 10;
c010b2f5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b2fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2ff:	0f b6 00             	movzbl (%eax),%eax
c010b302:	3c 2f                	cmp    $0x2f,%al
c010b304:	7e 1b                	jle    c010b321 <strtol+0xdc>
c010b306:	8b 45 08             	mov    0x8(%ebp),%eax
c010b309:	0f b6 00             	movzbl (%eax),%eax
c010b30c:	3c 39                	cmp    $0x39,%al
c010b30e:	7f 11                	jg     c010b321 <strtol+0xdc>
            dig = *s - '0';
c010b310:	8b 45 08             	mov    0x8(%ebp),%eax
c010b313:	0f b6 00             	movzbl (%eax),%eax
c010b316:	0f be c0             	movsbl %al,%eax
c010b319:	83 e8 30             	sub    $0x30,%eax
c010b31c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b31f:	eb 48                	jmp    c010b369 <strtol+0x124>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b321:	8b 45 08             	mov    0x8(%ebp),%eax
c010b324:	0f b6 00             	movzbl (%eax),%eax
c010b327:	3c 60                	cmp    $0x60,%al
c010b329:	7e 1b                	jle    c010b346 <strtol+0x101>
c010b32b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b32e:	0f b6 00             	movzbl (%eax),%eax
c010b331:	3c 7a                	cmp    $0x7a,%al
c010b333:	7f 11                	jg     c010b346 <strtol+0x101>
            dig = *s - 'a' + 10;
c010b335:	8b 45 08             	mov    0x8(%ebp),%eax
c010b338:	0f b6 00             	movzbl (%eax),%eax
c010b33b:	0f be c0             	movsbl %al,%eax
c010b33e:	83 e8 57             	sub    $0x57,%eax
c010b341:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b344:	eb 23                	jmp    c010b369 <strtol+0x124>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b346:	8b 45 08             	mov    0x8(%ebp),%eax
c010b349:	0f b6 00             	movzbl (%eax),%eax
c010b34c:	3c 40                	cmp    $0x40,%al
c010b34e:	7e 3c                	jle    c010b38c <strtol+0x147>
c010b350:	8b 45 08             	mov    0x8(%ebp),%eax
c010b353:	0f b6 00             	movzbl (%eax),%eax
c010b356:	3c 5a                	cmp    $0x5a,%al
c010b358:	7f 32                	jg     c010b38c <strtol+0x147>
            dig = *s - 'A' + 10;
c010b35a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b35d:	0f b6 00             	movzbl (%eax),%eax
c010b360:	0f be c0             	movsbl %al,%eax
c010b363:	83 e8 37             	sub    $0x37,%eax
c010b366:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b369:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b36c:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b36f:	7d 1a                	jge    c010b38b <strtol+0x146>
            break;
        }
        s ++, val = (val * base) + dig;
c010b371:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b375:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b378:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b37c:	89 c2                	mov    %eax,%edx
c010b37e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b381:	01 d0                	add    %edx,%eax
c010b383:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010b386:	e9 71 ff ff ff       	jmp    c010b2fc <strtol+0xb7>
            break;
c010b38b:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010b38c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b390:	74 08                	je     c010b39a <strtol+0x155>
        *endptr = (char *) s;
c010b392:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b395:	8b 55 08             	mov    0x8(%ebp),%edx
c010b398:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b39a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b39e:	74 07                	je     c010b3a7 <strtol+0x162>
c010b3a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b3a3:	f7 d8                	neg    %eax
c010b3a5:	eb 03                	jmp    c010b3aa <strtol+0x165>
c010b3a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b3aa:	c9                   	leave  
c010b3ab:	c3                   	ret    

c010b3ac <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b3ac:	55                   	push   %ebp
c010b3ad:	89 e5                	mov    %esp,%ebp
c010b3af:	57                   	push   %edi
c010b3b0:	83 ec 24             	sub    $0x24,%esp
c010b3b3:	e8 05 4f ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b3b8:	05 c8 e5 01 00       	add    $0x1e5c8,%eax
c010b3bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3c0:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b3c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b3c7:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3ca:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b3cd:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b3d0:	8b 45 10             	mov    0x10(%ebp),%eax
c010b3d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b3d6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b3d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b3dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b3e0:	89 d7                	mov    %edx,%edi
c010b3e2:	f3 aa                	rep stos %al,%es:(%edi)
c010b3e4:	89 fa                	mov    %edi,%edx
c010b3e6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b3e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b3ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b3ef:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b3f0:	83 c4 24             	add    $0x24,%esp
c010b3f3:	5f                   	pop    %edi
c010b3f4:	5d                   	pop    %ebp
c010b3f5:	c3                   	ret    

c010b3f6 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b3f6:	55                   	push   %ebp
c010b3f7:	89 e5                	mov    %esp,%ebp
c010b3f9:	57                   	push   %edi
c010b3fa:	56                   	push   %esi
c010b3fb:	53                   	push   %ebx
c010b3fc:	83 ec 30             	sub    $0x30,%esp
c010b3ff:	e8 b9 4e ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b404:	05 7c e5 01 00       	add    $0x1e57c,%eax
c010b409:	8b 45 08             	mov    0x8(%ebp),%eax
c010b40c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b40f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b412:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b415:	8b 45 10             	mov    0x10(%ebp),%eax
c010b418:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b41b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b41e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b421:	73 42                	jae    c010b465 <memmove+0x6f>
c010b423:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b426:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b429:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b42c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b42f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b432:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b435:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b438:	c1 e8 02             	shr    $0x2,%eax
c010b43b:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b43d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b440:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b443:	89 d7                	mov    %edx,%edi
c010b445:	89 c6                	mov    %eax,%esi
c010b447:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b449:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010b44c:	83 e1 03             	and    $0x3,%ecx
c010b44f:	74 02                	je     c010b453 <memmove+0x5d>
c010b451:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b453:	89 f0                	mov    %esi,%eax
c010b455:	89 fa                	mov    %edi,%edx
c010b457:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010b45a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b45d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010b460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010b463:	eb 36                	jmp    c010b49b <memmove+0xa5>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010b465:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b468:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b46b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b46e:	01 c2                	add    %eax,%edx
c010b470:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b473:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010b476:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b479:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010b47c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b47f:	89 c1                	mov    %eax,%ecx
c010b481:	89 d8                	mov    %ebx,%eax
c010b483:	89 d6                	mov    %edx,%esi
c010b485:	89 c7                	mov    %eax,%edi
c010b487:	fd                   	std    
c010b488:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b48a:	fc                   	cld    
c010b48b:	89 f8                	mov    %edi,%eax
c010b48d:	89 f2                	mov    %esi,%edx
c010b48f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010b492:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010b495:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010b498:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010b49b:	83 c4 30             	add    $0x30,%esp
c010b49e:	5b                   	pop    %ebx
c010b49f:	5e                   	pop    %esi
c010b4a0:	5f                   	pop    %edi
c010b4a1:	5d                   	pop    %ebp
c010b4a2:	c3                   	ret    

c010b4a3 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010b4a3:	55                   	push   %ebp
c010b4a4:	89 e5                	mov    %esp,%ebp
c010b4a6:	57                   	push   %edi
c010b4a7:	56                   	push   %esi
c010b4a8:	83 ec 20             	sub    $0x20,%esp
c010b4ab:	e8 0d 4e ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b4b0:	05 d0 e4 01 00       	add    $0x1e4d0,%eax
c010b4b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b4bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4be:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b4c1:	8b 45 10             	mov    0x10(%ebp),%eax
c010b4c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b4c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b4ca:	c1 e8 02             	shr    $0x2,%eax
c010b4cd:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b4cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b4d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b4d5:	89 d7                	mov    %edx,%edi
c010b4d7:	89 c6                	mov    %eax,%esi
c010b4d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b4db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b4de:	83 e1 03             	and    $0x3,%ecx
c010b4e1:	74 02                	je     c010b4e5 <memcpy+0x42>
c010b4e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b4e5:	89 f0                	mov    %esi,%eax
c010b4e7:	89 fa                	mov    %edi,%edx
c010b4e9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b4ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b4ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010b4f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c010b4f5:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010b4f6:	83 c4 20             	add    $0x20,%esp
c010b4f9:	5e                   	pop    %esi
c010b4fa:	5f                   	pop    %edi
c010b4fb:	5d                   	pop    %ebp
c010b4fc:	c3                   	ret    

c010b4fd <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010b4fd:	55                   	push   %ebp
c010b4fe:	89 e5                	mov    %esp,%ebp
c010b500:	83 ec 10             	sub    $0x10,%esp
c010b503:	e8 b5 4d ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b508:	05 78 e4 01 00       	add    $0x1e478,%eax
    const char *s1 = (const char *)v1;
c010b50d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b510:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010b513:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b516:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010b519:	eb 30                	jmp    c010b54b <memcmp+0x4e>
        if (*s1 != *s2) {
c010b51b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b51e:	0f b6 10             	movzbl (%eax),%edx
c010b521:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b524:	0f b6 00             	movzbl (%eax),%eax
c010b527:	38 c2                	cmp    %al,%dl
c010b529:	74 18                	je     c010b543 <memcmp+0x46>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b52b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b52e:	0f b6 00             	movzbl (%eax),%eax
c010b531:	0f b6 d0             	movzbl %al,%edx
c010b534:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b537:	0f b6 00             	movzbl (%eax),%eax
c010b53a:	0f b6 c0             	movzbl %al,%eax
c010b53d:	29 c2                	sub    %eax,%edx
c010b53f:	89 d0                	mov    %edx,%eax
c010b541:	eb 1a                	jmp    c010b55d <memcmp+0x60>
        }
        s1 ++, s2 ++;
c010b543:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b547:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c010b54b:	8b 45 10             	mov    0x10(%ebp),%eax
c010b54e:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b551:	89 55 10             	mov    %edx,0x10(%ebp)
c010b554:	85 c0                	test   %eax,%eax
c010b556:	75 c3                	jne    c010b51b <memcmp+0x1e>
    }
    return 0;
c010b558:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b55d:	c9                   	leave  
c010b55e:	c3                   	ret    

c010b55f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b55f:	55                   	push   %ebp
c010b560:	89 e5                	mov    %esp,%ebp
c010b562:	53                   	push   %ebx
c010b563:	83 ec 34             	sub    $0x34,%esp
c010b566:	e8 56 4d ff ff       	call   c01002c1 <__x86.get_pc_thunk.bx>
c010b56b:	81 c3 15 e4 01 00    	add    $0x1e415,%ebx
c010b571:	8b 45 10             	mov    0x10(%ebp),%eax
c010b574:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b577:	8b 45 14             	mov    0x14(%ebp),%eax
c010b57a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b57d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b580:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b583:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b586:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b589:	8b 45 18             	mov    0x18(%ebp),%eax
c010b58c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b58f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b592:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b595:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b598:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b59b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b59e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b5a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b5a5:	74 1c                	je     c010b5c3 <printnum+0x64>
c010b5a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5aa:	ba 00 00 00 00       	mov    $0x0,%edx
c010b5af:	f7 75 e4             	divl   -0x1c(%ebp)
c010b5b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b5b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5b8:	ba 00 00 00 00       	mov    $0x0,%edx
c010b5bd:	f7 75 e4             	divl   -0x1c(%ebp)
c010b5c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b5c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b5c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b5c9:	f7 75 e4             	divl   -0x1c(%ebp)
c010b5cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b5cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b5d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b5d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b5d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b5db:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b5de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b5e1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b5e4:	8b 45 18             	mov    0x18(%ebp),%eax
c010b5e7:	ba 00 00 00 00       	mov    $0x0,%edx
c010b5ec:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010b5ef:	72 41                	jb     c010b632 <printnum+0xd3>
c010b5f1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010b5f4:	77 05                	ja     c010b5fb <printnum+0x9c>
c010b5f6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010b5f9:	72 37                	jb     c010b632 <printnum+0xd3>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b5fb:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b5fe:	83 e8 01             	sub    $0x1,%eax
c010b601:	83 ec 04             	sub    $0x4,%esp
c010b604:	ff 75 20             	pushl  0x20(%ebp)
c010b607:	50                   	push   %eax
c010b608:	ff 75 18             	pushl  0x18(%ebp)
c010b60b:	ff 75 ec             	pushl  -0x14(%ebp)
c010b60e:	ff 75 e8             	pushl  -0x18(%ebp)
c010b611:	ff 75 0c             	pushl  0xc(%ebp)
c010b614:	ff 75 08             	pushl  0x8(%ebp)
c010b617:	e8 43 ff ff ff       	call   c010b55f <printnum>
c010b61c:	83 c4 20             	add    $0x20,%esp
c010b61f:	eb 1b                	jmp    c010b63c <printnum+0xdd>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b621:	83 ec 08             	sub    $0x8,%esp
c010b624:	ff 75 0c             	pushl  0xc(%ebp)
c010b627:	ff 75 20             	pushl  0x20(%ebp)
c010b62a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b62d:	ff d0                	call   *%eax
c010b62f:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
c010b632:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b636:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b63a:	7f e5                	jg     c010b621 <printnum+0xc2>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b63c:	8d 93 0e 46 fe ff    	lea    -0x1b9f2(%ebx),%edx
c010b642:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b645:	01 d0                	add    %edx,%eax
c010b647:	0f b6 00             	movzbl (%eax),%eax
c010b64a:	0f be c0             	movsbl %al,%eax
c010b64d:	83 ec 08             	sub    $0x8,%esp
c010b650:	ff 75 0c             	pushl  0xc(%ebp)
c010b653:	50                   	push   %eax
c010b654:	8b 45 08             	mov    0x8(%ebp),%eax
c010b657:	ff d0                	call   *%eax
c010b659:	83 c4 10             	add    $0x10,%esp
}
c010b65c:	90                   	nop
c010b65d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010b660:	c9                   	leave  
c010b661:	c3                   	ret    

c010b662 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b662:	55                   	push   %ebp
c010b663:	89 e5                	mov    %esp,%ebp
c010b665:	e8 53 4c ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b66a:	05 16 e3 01 00       	add    $0x1e316,%eax
    if (lflag >= 2) {
c010b66f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b673:	7e 14                	jle    c010b689 <getuint+0x27>
        return va_arg(*ap, unsigned long long);
c010b675:	8b 45 08             	mov    0x8(%ebp),%eax
c010b678:	8b 00                	mov    (%eax),%eax
c010b67a:	8d 48 08             	lea    0x8(%eax),%ecx
c010b67d:	8b 55 08             	mov    0x8(%ebp),%edx
c010b680:	89 0a                	mov    %ecx,(%edx)
c010b682:	8b 50 04             	mov    0x4(%eax),%edx
c010b685:	8b 00                	mov    (%eax),%eax
c010b687:	eb 30                	jmp    c010b6b9 <getuint+0x57>
    }
    else if (lflag) {
c010b689:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b68d:	74 16                	je     c010b6a5 <getuint+0x43>
        return va_arg(*ap, unsigned long);
c010b68f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b692:	8b 00                	mov    (%eax),%eax
c010b694:	8d 48 04             	lea    0x4(%eax),%ecx
c010b697:	8b 55 08             	mov    0x8(%ebp),%edx
c010b69a:	89 0a                	mov    %ecx,(%edx)
c010b69c:	8b 00                	mov    (%eax),%eax
c010b69e:	ba 00 00 00 00       	mov    $0x0,%edx
c010b6a3:	eb 14                	jmp    c010b6b9 <getuint+0x57>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b6a5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6a8:	8b 00                	mov    (%eax),%eax
c010b6aa:	8d 48 04             	lea    0x4(%eax),%ecx
c010b6ad:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6b0:	89 0a                	mov    %ecx,(%edx)
c010b6b2:	8b 00                	mov    (%eax),%eax
c010b6b4:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b6b9:	5d                   	pop    %ebp
c010b6ba:	c3                   	ret    

c010b6bb <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b6bb:	55                   	push   %ebp
c010b6bc:	89 e5                	mov    %esp,%ebp
c010b6be:	e8 fa 4b ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b6c3:	05 bd e2 01 00       	add    $0x1e2bd,%eax
    if (lflag >= 2) {
c010b6c8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b6cc:	7e 14                	jle    c010b6e2 <getint+0x27>
        return va_arg(*ap, long long);
c010b6ce:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6d1:	8b 00                	mov    (%eax),%eax
c010b6d3:	8d 48 08             	lea    0x8(%eax),%ecx
c010b6d6:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6d9:	89 0a                	mov    %ecx,(%edx)
c010b6db:	8b 50 04             	mov    0x4(%eax),%edx
c010b6de:	8b 00                	mov    (%eax),%eax
c010b6e0:	eb 28                	jmp    c010b70a <getint+0x4f>
    }
    else if (lflag) {
c010b6e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b6e6:	74 12                	je     c010b6fa <getint+0x3f>
        return va_arg(*ap, long);
c010b6e8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6eb:	8b 00                	mov    (%eax),%eax
c010b6ed:	8d 48 04             	lea    0x4(%eax),%ecx
c010b6f0:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6f3:	89 0a                	mov    %ecx,(%edx)
c010b6f5:	8b 00                	mov    (%eax),%eax
c010b6f7:	99                   	cltd   
c010b6f8:	eb 10                	jmp    c010b70a <getint+0x4f>
    }
    else {
        return va_arg(*ap, int);
c010b6fa:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6fd:	8b 00                	mov    (%eax),%eax
c010b6ff:	8d 48 04             	lea    0x4(%eax),%ecx
c010b702:	8b 55 08             	mov    0x8(%ebp),%edx
c010b705:	89 0a                	mov    %ecx,(%edx)
c010b707:	8b 00                	mov    (%eax),%eax
c010b709:	99                   	cltd   
    }
}
c010b70a:	5d                   	pop    %ebp
c010b70b:	c3                   	ret    

c010b70c <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b70c:	55                   	push   %ebp
c010b70d:	89 e5                	mov    %esp,%ebp
c010b70f:	83 ec 18             	sub    $0x18,%esp
c010b712:	e8 a6 4b ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010b717:	05 69 e2 01 00       	add    $0x1e269,%eax
    va_list ap;

    va_start(ap, fmt);
c010b71c:	8d 45 14             	lea    0x14(%ebp),%eax
c010b71f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b725:	50                   	push   %eax
c010b726:	ff 75 10             	pushl  0x10(%ebp)
c010b729:	ff 75 0c             	pushl  0xc(%ebp)
c010b72c:	ff 75 08             	pushl  0x8(%ebp)
c010b72f:	e8 06 00 00 00       	call   c010b73a <vprintfmt>
c010b734:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010b737:	90                   	nop
c010b738:	c9                   	leave  
c010b739:	c3                   	ret    

c010b73a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b73a:	55                   	push   %ebp
c010b73b:	89 e5                	mov    %esp,%ebp
c010b73d:	57                   	push   %edi
c010b73e:	56                   	push   %esi
c010b73f:	53                   	push   %ebx
c010b740:	83 ec 2c             	sub    $0x2c,%esp
c010b743:	e8 8c 04 00 00       	call   c010bbd4 <__x86.get_pc_thunk.di>
c010b748:	81 c7 38 e2 01 00    	add    $0x1e238,%edi
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b74e:	eb 17                	jmp    c010b767 <vprintfmt+0x2d>
            if (ch == '\0') {
c010b750:	85 db                	test   %ebx,%ebx
c010b752:	0f 84 9a 03 00 00    	je     c010baf2 <.L24+0x2d>
                return;
            }
            putch(ch, putdat);
c010b758:	83 ec 08             	sub    $0x8,%esp
c010b75b:	ff 75 0c             	pushl  0xc(%ebp)
c010b75e:	53                   	push   %ebx
c010b75f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b762:	ff d0                	call   *%eax
c010b764:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b767:	8b 45 10             	mov    0x10(%ebp),%eax
c010b76a:	8d 50 01             	lea    0x1(%eax),%edx
c010b76d:	89 55 10             	mov    %edx,0x10(%ebp)
c010b770:	0f b6 00             	movzbl (%eax),%eax
c010b773:	0f b6 d8             	movzbl %al,%ebx
c010b776:	83 fb 25             	cmp    $0x25,%ebx
c010b779:	75 d5                	jne    c010b750 <vprintfmt+0x16>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b77b:	c6 45 cb 20          	movb   $0x20,-0x35(%ebp)
        width = precision = -1;
c010b77f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
c010b786:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010b789:	89 45 d8             	mov    %eax,-0x28(%ebp)
        lflag = altflag = 0;
c010b78c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c010b793:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010b796:	89 45 d0             	mov    %eax,-0x30(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b799:	8b 45 10             	mov    0x10(%ebp),%eax
c010b79c:	8d 50 01             	lea    0x1(%eax),%edx
c010b79f:	89 55 10             	mov    %edx,0x10(%ebp)
c010b7a2:	0f b6 00             	movzbl (%eax),%eax
c010b7a5:	0f b6 d8             	movzbl %al,%ebx
c010b7a8:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b7ab:	83 f8 55             	cmp    $0x55,%eax
c010b7ae:	0f 87 11 03 00 00    	ja     c010bac5 <.L24>
c010b7b4:	c1 e0 02             	shl    $0x2,%eax
c010b7b7:	8b 84 38 34 46 fe ff 	mov    -0x1b9cc(%eax,%edi,1),%eax
c010b7be:	01 f8                	add    %edi,%eax
c010b7c0:	ff e0                	jmp    *%eax

c010b7c2 <.L29>:

        // flag to pad on the right
        case '-':
            padc = '-';
c010b7c2:	c6 45 cb 2d          	movb   $0x2d,-0x35(%ebp)
            goto reswitch;
c010b7c6:	eb d1                	jmp    c010b799 <vprintfmt+0x5f>

c010b7c8 <.L31>:

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b7c8:	c6 45 cb 30          	movb   $0x30,-0x35(%ebp)
            goto reswitch;
c010b7cc:	eb cb                	jmp    c010b799 <vprintfmt+0x5f>

c010b7ce <.L32>:

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b7ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
                precision = precision * 10 + ch - '0';
c010b7d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b7d8:	89 d0                	mov    %edx,%eax
c010b7da:	c1 e0 02             	shl    $0x2,%eax
c010b7dd:	01 d0                	add    %edx,%eax
c010b7df:	01 c0                	add    %eax,%eax
c010b7e1:	01 d8                	add    %ebx,%eax
c010b7e3:	83 e8 30             	sub    $0x30,%eax
c010b7e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
                ch = *fmt;
c010b7e9:	8b 45 10             	mov    0x10(%ebp),%eax
c010b7ec:	0f b6 00             	movzbl (%eax),%eax
c010b7ef:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010b7f2:	83 fb 2f             	cmp    $0x2f,%ebx
c010b7f5:	7e 39                	jle    c010b830 <.L25+0xc>
c010b7f7:	83 fb 39             	cmp    $0x39,%ebx
c010b7fa:	7f 34                	jg     c010b830 <.L25+0xc>
            for (precision = 0; ; ++ fmt) {
c010b7fc:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010b800:	eb d3                	jmp    c010b7d5 <.L32+0x7>

c010b802 <.L28>:
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010b802:	8b 45 14             	mov    0x14(%ebp),%eax
c010b805:	8d 50 04             	lea    0x4(%eax),%edx
c010b808:	89 55 14             	mov    %edx,0x14(%ebp)
c010b80b:	8b 00                	mov    (%eax),%eax
c010b80d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            goto process_precision;
c010b810:	eb 1f                	jmp    c010b831 <.L25+0xd>

c010b812 <.L30>:

        case '.':
            if (width < 0)
c010b812:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010b816:	79 81                	jns    c010b799 <vprintfmt+0x5f>
                width = 0;
c010b818:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            goto reswitch;
c010b81f:	e9 75 ff ff ff       	jmp    c010b799 <vprintfmt+0x5f>

c010b824 <.L25>:

        case '#':
            altflag = 1;
c010b824:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
            goto reswitch;
c010b82b:	e9 69 ff ff ff       	jmp    c010b799 <vprintfmt+0x5f>
            goto process_precision;
c010b830:	90                   	nop

        process_precision:
            if (width < 0)
c010b831:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010b835:	0f 89 5e ff ff ff    	jns    c010b799 <vprintfmt+0x5f>
                width = precision, precision = -1;
c010b83b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010b83e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010b841:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
            goto reswitch;
c010b848:	e9 4c ff ff ff       	jmp    c010b799 <vprintfmt+0x5f>

c010b84d <.L36>:

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010b84d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
            goto reswitch;
c010b851:	e9 43 ff ff ff       	jmp    c010b799 <vprintfmt+0x5f>

c010b856 <.L33>:

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010b856:	8b 45 14             	mov    0x14(%ebp),%eax
c010b859:	8d 50 04             	lea    0x4(%eax),%edx
c010b85c:	89 55 14             	mov    %edx,0x14(%ebp)
c010b85f:	8b 00                	mov    (%eax),%eax
c010b861:	83 ec 08             	sub    $0x8,%esp
c010b864:	ff 75 0c             	pushl  0xc(%ebp)
c010b867:	50                   	push   %eax
c010b868:	8b 45 08             	mov    0x8(%ebp),%eax
c010b86b:	ff d0                	call   *%eax
c010b86d:	83 c4 10             	add    $0x10,%esp
            break;
c010b870:	e9 78 02 00 00       	jmp    c010baed <.L24+0x28>

c010b875 <.L35>:

        // error message
        case 'e':
            err = va_arg(ap, int);
c010b875:	8b 45 14             	mov    0x14(%ebp),%eax
c010b878:	8d 50 04             	lea    0x4(%eax),%edx
c010b87b:	89 55 14             	mov    %edx,0x14(%ebp)
c010b87e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010b880:	85 db                	test   %ebx,%ebx
c010b882:	79 02                	jns    c010b886 <.L35+0x11>
                err = -err;
c010b884:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010b886:	83 fb 06             	cmp    $0x6,%ebx
c010b889:	7f 0b                	jg     c010b896 <.L35+0x21>
c010b88b:	8b b4 9f 8c 01 00 00 	mov    0x18c(%edi,%ebx,4),%esi
c010b892:	85 f6                	test   %esi,%esi
c010b894:	75 1b                	jne    c010b8b1 <.L35+0x3c>
                printfmt(putch, putdat, "error %d", err);
c010b896:	53                   	push   %ebx
c010b897:	8d 87 1f 46 fe ff    	lea    -0x1b9e1(%edi),%eax
c010b89d:	50                   	push   %eax
c010b89e:	ff 75 0c             	pushl  0xc(%ebp)
c010b8a1:	ff 75 08             	pushl  0x8(%ebp)
c010b8a4:	e8 63 fe ff ff       	call   c010b70c <printfmt>
c010b8a9:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010b8ac:	e9 3c 02 00 00       	jmp    c010baed <.L24+0x28>
                printfmt(putch, putdat, "%s", p);
c010b8b1:	56                   	push   %esi
c010b8b2:	8d 87 28 46 fe ff    	lea    -0x1b9d8(%edi),%eax
c010b8b8:	50                   	push   %eax
c010b8b9:	ff 75 0c             	pushl  0xc(%ebp)
c010b8bc:	ff 75 08             	pushl  0x8(%ebp)
c010b8bf:	e8 48 fe ff ff       	call   c010b70c <printfmt>
c010b8c4:	83 c4 10             	add    $0x10,%esp
            break;
c010b8c7:	e9 21 02 00 00       	jmp    c010baed <.L24+0x28>

c010b8cc <.L39>:

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010b8cc:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8cf:	8d 50 04             	lea    0x4(%eax),%edx
c010b8d2:	89 55 14             	mov    %edx,0x14(%ebp)
c010b8d5:	8b 30                	mov    (%eax),%esi
c010b8d7:	85 f6                	test   %esi,%esi
c010b8d9:	75 06                	jne    c010b8e1 <.L39+0x15>
                p = "(null)";
c010b8db:	8d b7 2b 46 fe ff    	lea    -0x1b9d5(%edi),%esi
            }
            if (width > 0 && padc != '-') {
c010b8e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010b8e5:	7e 78                	jle    c010b95f <.L39+0x93>
c010b8e7:	80 7d cb 2d          	cmpb   $0x2d,-0x35(%ebp)
c010b8eb:	74 72                	je     c010b95f <.L39+0x93>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b8ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010b8f0:	83 ec 08             	sub    $0x8,%esp
c010b8f3:	50                   	push   %eax
c010b8f4:	56                   	push   %esi
c010b8f5:	89 fb                	mov    %edi,%ebx
c010b8f7:	e8 57 f7 ff ff       	call   c010b053 <strnlen>
c010b8fc:	83 c4 10             	add    $0x10,%esp
c010b8ff:	89 c2                	mov    %eax,%edx
c010b901:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b904:	29 d0                	sub    %edx,%eax
c010b906:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010b909:	eb 17                	jmp    c010b922 <.L39+0x56>
                    putch(padc, putdat);
c010b90b:	0f be 45 cb          	movsbl -0x35(%ebp),%eax
c010b90f:	83 ec 08             	sub    $0x8,%esp
c010b912:	ff 75 0c             	pushl  0xc(%ebp)
c010b915:	50                   	push   %eax
c010b916:	8b 45 08             	mov    0x8(%ebp),%eax
c010b919:	ff d0                	call   *%eax
c010b91b:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b91e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
c010b922:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010b926:	7f e3                	jg     c010b90b <.L39+0x3f>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b928:	eb 35                	jmp    c010b95f <.L39+0x93>
                if (altflag && (ch < ' ' || ch > '~')) {
c010b92a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010b92e:	74 1c                	je     c010b94c <.L39+0x80>
c010b930:	83 fb 1f             	cmp    $0x1f,%ebx
c010b933:	7e 05                	jle    c010b93a <.L39+0x6e>
c010b935:	83 fb 7e             	cmp    $0x7e,%ebx
c010b938:	7e 12                	jle    c010b94c <.L39+0x80>
                    putch('?', putdat);
c010b93a:	83 ec 08             	sub    $0x8,%esp
c010b93d:	ff 75 0c             	pushl  0xc(%ebp)
c010b940:	6a 3f                	push   $0x3f
c010b942:	8b 45 08             	mov    0x8(%ebp),%eax
c010b945:	ff d0                	call   *%eax
c010b947:	83 c4 10             	add    $0x10,%esp
c010b94a:	eb 0f                	jmp    c010b95b <.L39+0x8f>
                }
                else {
                    putch(ch, putdat);
c010b94c:	83 ec 08             	sub    $0x8,%esp
c010b94f:	ff 75 0c             	pushl  0xc(%ebp)
c010b952:	53                   	push   %ebx
c010b953:	8b 45 08             	mov    0x8(%ebp),%eax
c010b956:	ff d0                	call   *%eax
c010b958:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b95b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
c010b95f:	89 f0                	mov    %esi,%eax
c010b961:	8d 70 01             	lea    0x1(%eax),%esi
c010b964:	0f b6 00             	movzbl (%eax),%eax
c010b967:	0f be d8             	movsbl %al,%ebx
c010b96a:	85 db                	test   %ebx,%ebx
c010b96c:	74 26                	je     c010b994 <.L39+0xc8>
c010b96e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010b972:	78 b6                	js     c010b92a <.L39+0x5e>
c010b974:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
c010b978:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010b97c:	79 ac                	jns    c010b92a <.L39+0x5e>
                }
            }
            for (; width > 0; width --) {
c010b97e:	eb 14                	jmp    c010b994 <.L39+0xc8>
                putch(' ', putdat);
c010b980:	83 ec 08             	sub    $0x8,%esp
c010b983:	ff 75 0c             	pushl  0xc(%ebp)
c010b986:	6a 20                	push   $0x20
c010b988:	8b 45 08             	mov    0x8(%ebp),%eax
c010b98b:	ff d0                	call   *%eax
c010b98d:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
c010b990:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
c010b994:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010b998:	7f e6                	jg     c010b980 <.L39+0xb4>
            }
            break;
c010b99a:	e9 4e 01 00 00       	jmp    c010baed <.L24+0x28>

c010b99f <.L34>:

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010b99f:	83 ec 08             	sub    $0x8,%esp
c010b9a2:	ff 75 d0             	pushl  -0x30(%ebp)
c010b9a5:	8d 45 14             	lea    0x14(%ebp),%eax
c010b9a8:	50                   	push   %eax
c010b9a9:	e8 0d fd ff ff       	call   c010b6bb <getint>
c010b9ae:	83 c4 10             	add    $0x10,%esp
c010b9b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b9b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            if ((long long)num < 0) {
c010b9b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b9ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b9bd:	85 d2                	test   %edx,%edx
c010b9bf:	79 23                	jns    c010b9e4 <.L34+0x45>
                putch('-', putdat);
c010b9c1:	83 ec 08             	sub    $0x8,%esp
c010b9c4:	ff 75 0c             	pushl  0xc(%ebp)
c010b9c7:	6a 2d                	push   $0x2d
c010b9c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9cc:	ff d0                	call   *%eax
c010b9ce:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010b9d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b9d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b9d7:	f7 d8                	neg    %eax
c010b9d9:	83 d2 00             	adc    $0x0,%edx
c010b9dc:	f7 da                	neg    %edx
c010b9de:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b9e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            }
            base = 10;
c010b9e4:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
            goto number;
c010b9eb:	e9 9f 00 00 00       	jmp    c010ba8f <.L41+0x1f>

c010b9f0 <.L40>:

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010b9f0:	83 ec 08             	sub    $0x8,%esp
c010b9f3:	ff 75 d0             	pushl  -0x30(%ebp)
c010b9f6:	8d 45 14             	lea    0x14(%ebp),%eax
c010b9f9:	50                   	push   %eax
c010b9fa:	e8 63 fc ff ff       	call   c010b662 <getuint>
c010b9ff:	83 c4 10             	add    $0x10,%esp
c010ba02:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ba05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            base = 10;
c010ba08:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
            goto number;
c010ba0f:	eb 7e                	jmp    c010ba8f <.L41+0x1f>

c010ba11 <.L37>:

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010ba11:	83 ec 08             	sub    $0x8,%esp
c010ba14:	ff 75 d0             	pushl  -0x30(%ebp)
c010ba17:	8d 45 14             	lea    0x14(%ebp),%eax
c010ba1a:	50                   	push   %eax
c010ba1b:	e8 42 fc ff ff       	call   c010b662 <getuint>
c010ba20:	83 c4 10             	add    $0x10,%esp
c010ba23:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ba26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            base = 8;
c010ba29:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
            goto number;
c010ba30:	eb 5d                	jmp    c010ba8f <.L41+0x1f>

c010ba32 <.L38>:

        // pointer
        case 'p':
            putch('0', putdat);
c010ba32:	83 ec 08             	sub    $0x8,%esp
c010ba35:	ff 75 0c             	pushl  0xc(%ebp)
c010ba38:	6a 30                	push   $0x30
c010ba3a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba3d:	ff d0                	call   *%eax
c010ba3f:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010ba42:	83 ec 08             	sub    $0x8,%esp
c010ba45:	ff 75 0c             	pushl  0xc(%ebp)
c010ba48:	6a 78                	push   $0x78
c010ba4a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba4d:	ff d0                	call   *%eax
c010ba4f:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010ba52:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba55:	8d 50 04             	lea    0x4(%eax),%edx
c010ba58:	89 55 14             	mov    %edx,0x14(%ebp)
c010ba5b:	8b 00                	mov    (%eax),%eax
c010ba5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ba60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            base = 16;
c010ba67:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
            goto number;
c010ba6e:	eb 1f                	jmp    c010ba8f <.L41+0x1f>

c010ba70 <.L41>:

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010ba70:	83 ec 08             	sub    $0x8,%esp
c010ba73:	ff 75 d0             	pushl  -0x30(%ebp)
c010ba76:	8d 45 14             	lea    0x14(%ebp),%eax
c010ba79:	50                   	push   %eax
c010ba7a:	e8 e3 fb ff ff       	call   c010b662 <getuint>
c010ba7f:	83 c4 10             	add    $0x10,%esp
c010ba82:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ba85:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            base = 16;
c010ba88:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010ba8f:	0f be 55 cb          	movsbl -0x35(%ebp),%edx
c010ba93:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010ba96:	83 ec 04             	sub    $0x4,%esp
c010ba99:	52                   	push   %edx
c010ba9a:	ff 75 d8             	pushl  -0x28(%ebp)
c010ba9d:	50                   	push   %eax
c010ba9e:	ff 75 e4             	pushl  -0x1c(%ebp)
c010baa1:	ff 75 e0             	pushl  -0x20(%ebp)
c010baa4:	ff 75 0c             	pushl  0xc(%ebp)
c010baa7:	ff 75 08             	pushl  0x8(%ebp)
c010baaa:	e8 b0 fa ff ff       	call   c010b55f <printnum>
c010baaf:	83 c4 20             	add    $0x20,%esp
            break;
c010bab2:	eb 39                	jmp    c010baed <.L24+0x28>

c010bab4 <.L27>:

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010bab4:	83 ec 08             	sub    $0x8,%esp
c010bab7:	ff 75 0c             	pushl  0xc(%ebp)
c010baba:	53                   	push   %ebx
c010babb:	8b 45 08             	mov    0x8(%ebp),%eax
c010babe:	ff d0                	call   *%eax
c010bac0:	83 c4 10             	add    $0x10,%esp
            break;
c010bac3:	eb 28                	jmp    c010baed <.L24+0x28>

c010bac5 <.L24>:

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010bac5:	83 ec 08             	sub    $0x8,%esp
c010bac8:	ff 75 0c             	pushl  0xc(%ebp)
c010bacb:	6a 25                	push   $0x25
c010bacd:	8b 45 08             	mov    0x8(%ebp),%eax
c010bad0:	ff d0                	call   *%eax
c010bad2:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c010bad5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bad9:	eb 04                	jmp    c010badf <.L24+0x1a>
c010badb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010badf:	8b 45 10             	mov    0x10(%ebp),%eax
c010bae2:	83 e8 01             	sub    $0x1,%eax
c010bae5:	0f b6 00             	movzbl (%eax),%eax
c010bae8:	3c 25                	cmp    $0x25,%al
c010baea:	75 ef                	jne    c010badb <.L24+0x16>
                /* do nothing */;
            break;
c010baec:	90                   	nop
    while (1) {
c010baed:	e9 5c fc ff ff       	jmp    c010b74e <vprintfmt+0x14>
                return;
c010baf2:	90                   	nop
        }
    }
}
c010baf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010baf6:	5b                   	pop    %ebx
c010baf7:	5e                   	pop    %esi
c010baf8:	5f                   	pop    %edi
c010baf9:	5d                   	pop    %ebp
c010bafa:	c3                   	ret    

c010bafb <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010bafb:	55                   	push   %ebp
c010bafc:	89 e5                	mov    %esp,%ebp
c010bafe:	e8 ba 47 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010bb03:	05 7d de 01 00       	add    $0x1de7d,%eax
    b->cnt ++;
c010bb08:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb0b:	8b 40 08             	mov    0x8(%eax),%eax
c010bb0e:	8d 50 01             	lea    0x1(%eax),%edx
c010bb11:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb14:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010bb17:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb1a:	8b 10                	mov    (%eax),%edx
c010bb1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb1f:	8b 40 04             	mov    0x4(%eax),%eax
c010bb22:	39 c2                	cmp    %eax,%edx
c010bb24:	73 12                	jae    c010bb38 <sprintputch+0x3d>
        *b->buf ++ = ch;
c010bb26:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb29:	8b 00                	mov    (%eax),%eax
c010bb2b:	8d 48 01             	lea    0x1(%eax),%ecx
c010bb2e:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bb31:	89 0a                	mov    %ecx,(%edx)
c010bb33:	8b 55 08             	mov    0x8(%ebp),%edx
c010bb36:	88 10                	mov    %dl,(%eax)
    }
}
c010bb38:	90                   	nop
c010bb39:	5d                   	pop    %ebp
c010bb3a:	c3                   	ret    

c010bb3b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010bb3b:	55                   	push   %ebp
c010bb3c:	89 e5                	mov    %esp,%ebp
c010bb3e:	83 ec 18             	sub    $0x18,%esp
c010bb41:	e8 77 47 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010bb46:	05 3a de 01 00       	add    $0x1de3a,%eax
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010bb4b:	8d 45 14             	lea    0x14(%ebp),%eax
c010bb4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010bb51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb54:	50                   	push   %eax
c010bb55:	ff 75 10             	pushl  0x10(%ebp)
c010bb58:	ff 75 0c             	pushl  0xc(%ebp)
c010bb5b:	ff 75 08             	pushl  0x8(%ebp)
c010bb5e:	e8 0b 00 00 00       	call   c010bb6e <vsnprintf>
c010bb63:	83 c4 10             	add    $0x10,%esp
c010bb66:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010bb69:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bb6c:	c9                   	leave  
c010bb6d:	c3                   	ret    

c010bb6e <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010bb6e:	55                   	push   %ebp
c010bb6f:	89 e5                	mov    %esp,%ebp
c010bb71:	83 ec 18             	sub    $0x18,%esp
c010bb74:	e8 44 47 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010bb79:	05 07 de 01 00       	add    $0x1de07,%eax
    struct sprintbuf b = {str, str + size - 1, 0};
c010bb7e:	8b 55 08             	mov    0x8(%ebp),%edx
c010bb81:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bb84:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bb87:	8d 4a ff             	lea    -0x1(%edx),%ecx
c010bb8a:	8b 55 08             	mov    0x8(%ebp),%edx
c010bb8d:	01 ca                	add    %ecx,%edx
c010bb8f:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010bb92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010bb99:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010bb9d:	74 0a                	je     c010bba9 <vsnprintf+0x3b>
c010bb9f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010bba2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bba5:	39 d1                	cmp    %edx,%ecx
c010bba7:	76 07                	jbe    c010bbb0 <vsnprintf+0x42>
        return -E_INVAL;
c010bba9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010bbae:	eb 22                	jmp    c010bbd2 <vsnprintf+0x64>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010bbb0:	ff 75 14             	pushl  0x14(%ebp)
c010bbb3:	ff 75 10             	pushl  0x10(%ebp)
c010bbb6:	8d 55 ec             	lea    -0x14(%ebp),%edx
c010bbb9:	52                   	push   %edx
c010bbba:	8d 80 7b 21 fe ff    	lea    -0x1de85(%eax),%eax
c010bbc0:	50                   	push   %eax
c010bbc1:	e8 74 fb ff ff       	call   c010b73a <vprintfmt>
c010bbc6:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c010bbc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bbcc:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010bbcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bbd2:	c9                   	leave  
c010bbd3:	c3                   	ret    

c010bbd4 <__x86.get_pc_thunk.di>:
c010bbd4:	8b 3c 24             	mov    (%esp),%edi
c010bbd7:	c3                   	ret    

c010bbd8 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010bbd8:	55                   	push   %ebp
c010bbd9:	89 e5                	mov    %esp,%ebp
c010bbdb:	83 ec 10             	sub    $0x10,%esp
c010bbde:	e8 da 46 ff ff       	call   c01002bd <__x86.get_pc_thunk.ax>
c010bbe3:	05 9d dd 01 00       	add    $0x1dd9d,%eax
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010bbe8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbeb:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010bbf1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010bbf4:	b8 20 00 00 00       	mov    $0x20,%eax
c010bbf9:	2b 45 0c             	sub    0xc(%ebp),%eax
c010bbfc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010bbff:	89 c1                	mov    %eax,%ecx
c010bc01:	d3 ea                	shr    %cl,%edx
c010bc03:	89 d0                	mov    %edx,%eax
}
c010bc05:	c9                   	leave  
c010bc06:	c3                   	ret    

c010bc07 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010bc07:	55                   	push   %ebp
c010bc08:	89 e5                	mov    %esp,%ebp
c010bc0a:	57                   	push   %edi
c010bc0b:	56                   	push   %esi
c010bc0c:	53                   	push   %ebx
c010bc0d:	83 ec 2c             	sub    $0x2c,%esp
c010bc10:	e8 43 e4 ff ff       	call   c010a058 <__x86.get_pc_thunk.si>
c010bc15:	81 c6 6b dd 01 00    	add    $0x1dd6b,%esi
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010bc1b:	8b 86 f8 ff ff ff    	mov    -0x8(%esi),%eax
c010bc21:	8b 96 fc ff ff ff    	mov    -0x4(%esi),%edx
c010bc27:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010bc2d:	89 7d cc             	mov    %edi,-0x34(%ebp)
c010bc30:	6b f8 05             	imul   $0x5,%eax,%edi
c010bc33:	03 7d cc             	add    -0x34(%ebp),%edi
c010bc36:	c7 45 cc 6d e6 ec de 	movl   $0xdeece66d,-0x34(%ebp)
c010bc3d:	f7 65 cc             	mull   -0x34(%ebp)
c010bc40:	01 d7                	add    %edx,%edi
c010bc42:	89 fa                	mov    %edi,%edx
c010bc44:	83 c0 0b             	add    $0xb,%eax
c010bc47:	83 d2 00             	adc    $0x0,%edx
c010bc4a:	89 c7                	mov    %eax,%edi
c010bc4c:	83 e7 ff             	and    $0xffffffff,%edi
c010bc4f:	89 f9                	mov    %edi,%ecx
c010bc51:	0f b7 da             	movzwl %dx,%ebx
c010bc54:	89 8e f8 ff ff ff    	mov    %ecx,-0x8(%esi)
c010bc5a:	89 9e fc ff ff ff    	mov    %ebx,-0x4(%esi)
    unsigned long long result = (next >> 12);
c010bc60:	8b 9e f8 ff ff ff    	mov    -0x8(%esi),%ebx
c010bc66:	8b b6 fc ff ff ff    	mov    -0x4(%esi),%esi
c010bc6c:	89 d8                	mov    %ebx,%eax
c010bc6e:	89 f2                	mov    %esi,%edx
c010bc70:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010bc74:	c1 ea 0c             	shr    $0xc,%edx
c010bc77:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bc7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010bc7d:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010bc84:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bc87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bc8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bc8d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bc90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bc93:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bc96:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bc9a:	74 1c                	je     c010bcb8 <rand+0xb1>
c010bc9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bc9f:	ba 00 00 00 00       	mov    $0x0,%edx
c010bca4:	f7 75 dc             	divl   -0x24(%ebp)
c010bca7:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bcaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bcad:	ba 00 00 00 00       	mov    $0x0,%edx
c010bcb2:	f7 75 dc             	divl   -0x24(%ebp)
c010bcb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bcb8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bcbb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bcbe:	f7 75 dc             	divl   -0x24(%ebp)
c010bcc1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bcc4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bcc7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bcca:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bccd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bcd0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bcd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010bcd6:	83 c4 2c             	add    $0x2c,%esp
c010bcd9:	5b                   	pop    %ebx
c010bcda:	5e                   	pop    %esi
c010bcdb:	5f                   	pop    %edi
c010bcdc:	5d                   	pop    %ebp
c010bcdd:	c3                   	ret    

c010bcde <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010bcde:	55                   	push   %ebp
c010bcdf:	89 e5                	mov    %esp,%ebp
c010bce1:	e8 9b 7a ff ff       	call   c0103781 <__x86.get_pc_thunk.cx>
c010bce6:	81 c1 9a dc 01 00    	add    $0x1dc9a,%ecx
    next = seed;
c010bcec:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcef:	ba 00 00 00 00       	mov    $0x0,%edx
c010bcf4:	89 81 f8 ff ff ff    	mov    %eax,-0x8(%ecx)
c010bcfa:	89 91 fc ff ff ff    	mov    %edx,-0x4(%ecx)
}
c010bd00:	90                   	nop
c010bd01:	5d                   	pop    %ebp
c010bd02:	c3                   	ret    
