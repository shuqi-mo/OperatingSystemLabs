
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	53                   	push   %ebx
  100004:	83 ec 14             	sub    $0x14,%esp
  100007:	e8 74 02 00 00       	call   100280 <__x86.get_pc_thunk.bx>
  10000c:	81 c3 44 e9 00 00    	add    $0xe944,%ebx
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100012:	c7 c0 c0 fd 10 00    	mov    $0x10fdc0,%eax
  100018:	89 c2                	mov    %eax,%edx
  10001a:	c7 c0 50 e9 10 00    	mov    $0x10e950,%eax
  100020:	29 c2                	sub    %eax,%edx
  100022:	89 d0                	mov    %edx,%eax
  100024:	83 ec 04             	sub    $0x4,%esp
  100027:	50                   	push   %eax
  100028:	6a 00                	push   $0x0
  10002a:	c7 c0 50 e9 10 00    	mov    $0x10e950,%eax
  100030:	50                   	push   %eax
  100031:	e8 3a 31 00 00       	call   103170 <memset>
  100036:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
  100039:	e8 1e 18 00 00       	call   10185c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10003e:	8d 83 4c 50 ff ff    	lea    -0xafb4(%ebx),%eax
  100044:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100047:	83 ec 08             	sub    $0x8,%esp
  10004a:	ff 75 f4             	pushl  -0xc(%ebp)
  10004d:	8d 83 68 50 ff ff    	lea    -0xaf98(%ebx),%eax
  100053:	50                   	push   %eax
  100054:	e8 9a 02 00 00       	call   1002f3 <cprintf>
  100059:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
  10005c:	e8 ba 09 00 00       	call   100a1b <print_kerninfo>

    grade_backtrace();
  100061:	e8 98 00 00 00       	call   1000fe <grade_backtrace>

    pmm_init();                 // init physical memory management
  100066:	e8 65 2d 00 00       	call   102dd0 <pmm_init>

    pic_init();                 // init interrupt controller
  10006b:	e8 7b 19 00 00       	call   1019eb <pic_init>
    idt_init();                 // init interrupt descriptor table
  100070:	e8 30 1b 00 00       	call   101ba5 <idt_init>

    clock_init();               // init clock interrupt
  100075:	e8 de 0e 00 00       	call   100f58 <clock_init>
    intr_enable();              // enable irq interrupt
  10007a:	e8 b4 1a 00 00       	call   101b33 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  10007f:	eb fe                	jmp    10007f <kern_init+0x7f>

00100081 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100081:	55                   	push   %ebp
  100082:	89 e5                	mov    %esp,%ebp
  100084:	53                   	push   %ebx
  100085:	83 ec 04             	sub    $0x4,%esp
  100088:	e8 ef 01 00 00       	call   10027c <__x86.get_pc_thunk.ax>
  10008d:	05 c3 e8 00 00       	add    $0xe8c3,%eax
    mon_backtrace(0, NULL, NULL);
  100092:	83 ec 04             	sub    $0x4,%esp
  100095:	6a 00                	push   $0x0
  100097:	6a 00                	push   $0x0
  100099:	6a 00                	push   $0x0
  10009b:	89 c3                	mov    %eax,%ebx
  10009d:	e8 93 0e 00 00       	call   100f35 <mon_backtrace>
  1000a2:	83 c4 10             	add    $0x10,%esp
}
  1000a5:	90                   	nop
  1000a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000a9:	c9                   	leave  
  1000aa:	c3                   	ret    

001000ab <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ab:	55                   	push   %ebp
  1000ac:	89 e5                	mov    %esp,%ebp
  1000ae:	53                   	push   %ebx
  1000af:	83 ec 04             	sub    $0x4,%esp
  1000b2:	e8 c5 01 00 00       	call   10027c <__x86.get_pc_thunk.ax>
  1000b7:	05 99 e8 00 00       	add    $0xe899,%eax
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000bc:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000c2:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1000c8:	51                   	push   %ecx
  1000c9:	52                   	push   %edx
  1000ca:	53                   	push   %ebx
  1000cb:	50                   	push   %eax
  1000cc:	e8 b0 ff ff ff       	call   100081 <grade_backtrace2>
  1000d1:	83 c4 10             	add    $0x10,%esp
}
  1000d4:	90                   	nop
  1000d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000d8:	c9                   	leave  
  1000d9:	c3                   	ret    

001000da <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000da:	55                   	push   %ebp
  1000db:	89 e5                	mov    %esp,%ebp
  1000dd:	83 ec 08             	sub    $0x8,%esp
  1000e0:	e8 97 01 00 00       	call   10027c <__x86.get_pc_thunk.ax>
  1000e5:	05 6b e8 00 00       	add    $0xe86b,%eax
    grade_backtrace1(arg0, arg2);
  1000ea:	83 ec 08             	sub    $0x8,%esp
  1000ed:	ff 75 10             	pushl  0x10(%ebp)
  1000f0:	ff 75 08             	pushl  0x8(%ebp)
  1000f3:	e8 b3 ff ff ff       	call   1000ab <grade_backtrace1>
  1000f8:	83 c4 10             	add    $0x10,%esp
}
  1000fb:	90                   	nop
  1000fc:	c9                   	leave  
  1000fd:	c3                   	ret    

001000fe <grade_backtrace>:

void
grade_backtrace(void) {
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 08             	sub    $0x8,%esp
  100104:	e8 73 01 00 00       	call   10027c <__x86.get_pc_thunk.ax>
  100109:	05 47 e8 00 00       	add    $0xe847,%eax
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10010e:	8d 80 b0 16 ff ff    	lea    -0xe950(%eax),%eax
  100114:	83 ec 04             	sub    $0x4,%esp
  100117:	68 00 00 ff ff       	push   $0xffff0000
  10011c:	50                   	push   %eax
  10011d:	6a 00                	push   $0x0
  10011f:	e8 b6 ff ff ff       	call   1000da <grade_backtrace0>
  100124:	83 c4 10             	add    $0x10,%esp
}
  100127:	90                   	nop
  100128:	c9                   	leave  
  100129:	c3                   	ret    

0010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10012a:	55                   	push   %ebp
  10012b:	89 e5                	mov    %esp,%ebp
  10012d:	53                   	push   %ebx
  10012e:	83 ec 14             	sub    $0x14,%esp
  100131:	e8 4a 01 00 00       	call   100280 <__x86.get_pc_thunk.bx>
  100136:	81 c3 1a e8 00 00    	add    $0xe81a,%ebx
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	8b 83 70 01 00 00    	mov    0x170(%ebx),%eax
  10015a:	83 ec 04             	sub    $0x4,%esp
  10015d:	52                   	push   %edx
  10015e:	50                   	push   %eax
  10015f:	8d 83 6d 50 ff ff    	lea    -0xaf93(%ebx),%eax
  100165:	50                   	push   %eax
  100166:	e8 88 01 00 00       	call   1002f3 <cprintf>
  10016b:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	0f b7 d0             	movzwl %ax,%edx
  100175:	8b 83 70 01 00 00    	mov    0x170(%ebx),%eax
  10017b:	83 ec 04             	sub    $0x4,%esp
  10017e:	52                   	push   %edx
  10017f:	50                   	push   %eax
  100180:	8d 83 7b 50 ff ff    	lea    -0xaf85(%ebx),%eax
  100186:	50                   	push   %eax
  100187:	e8 67 01 00 00       	call   1002f3 <cprintf>
  10018c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
  10018f:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100193:	0f b7 d0             	movzwl %ax,%edx
  100196:	8b 83 70 01 00 00    	mov    0x170(%ebx),%eax
  10019c:	83 ec 04             	sub    $0x4,%esp
  10019f:	52                   	push   %edx
  1001a0:	50                   	push   %eax
  1001a1:	8d 83 89 50 ff ff    	lea    -0xaf77(%ebx),%eax
  1001a7:	50                   	push   %eax
  1001a8:	e8 46 01 00 00       	call   1002f3 <cprintf>
  1001ad:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
  1001b0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b4:	0f b7 d0             	movzwl %ax,%edx
  1001b7:	8b 83 70 01 00 00    	mov    0x170(%ebx),%eax
  1001bd:	83 ec 04             	sub    $0x4,%esp
  1001c0:	52                   	push   %edx
  1001c1:	50                   	push   %eax
  1001c2:	8d 83 97 50 ff ff    	lea    -0xaf69(%ebx),%eax
  1001c8:	50                   	push   %eax
  1001c9:	e8 25 01 00 00       	call   1002f3 <cprintf>
  1001ce:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d5:	0f b7 d0             	movzwl %ax,%edx
  1001d8:	8b 83 70 01 00 00    	mov    0x170(%ebx),%eax
  1001de:	83 ec 04             	sub    $0x4,%esp
  1001e1:	52                   	push   %edx
  1001e2:	50                   	push   %eax
  1001e3:	8d 83 a5 50 ff ff    	lea    -0xaf5b(%ebx),%eax
  1001e9:	50                   	push   %eax
  1001ea:	e8 04 01 00 00       	call   1002f3 <cprintf>
  1001ef:	83 c4 10             	add    $0x10,%esp
    round ++;
  1001f2:	8b 83 70 01 00 00    	mov    0x170(%ebx),%eax
  1001f8:	83 c0 01             	add    $0x1,%eax
  1001fb:	89 83 70 01 00 00    	mov    %eax,0x170(%ebx)
}
  100201:	90                   	nop
  100202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100205:	c9                   	leave  
  100206:	c3                   	ret    

00100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  100207:	55                   	push   %ebp
  100208:	89 e5                	mov    %esp,%ebp
  10020a:	e8 6d 00 00 00       	call   10027c <__x86.get_pc_thunk.ax>
  10020f:	05 41 e7 00 00       	add    $0xe741,%eax
    //LAB1 CHALLENGE 1 : TODO
}
  100214:	90                   	nop
  100215:	5d                   	pop    %ebp
  100216:	c3                   	ret    

00100217 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100217:	55                   	push   %ebp
  100218:	89 e5                	mov    %esp,%ebp
  10021a:	e8 5d 00 00 00       	call   10027c <__x86.get_pc_thunk.ax>
  10021f:	05 31 e7 00 00       	add    $0xe731,%eax
    //LAB1 CHALLENGE 1 :  TODO
}
  100224:	90                   	nop
  100225:	5d                   	pop    %ebp
  100226:	c3                   	ret    

00100227 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100227:	55                   	push   %ebp
  100228:	89 e5                	mov    %esp,%ebp
  10022a:	53                   	push   %ebx
  10022b:	83 ec 04             	sub    $0x4,%esp
  10022e:	e8 4d 00 00 00       	call   100280 <__x86.get_pc_thunk.bx>
  100233:	81 c3 1d e7 00 00    	add    $0xe71d,%ebx
    lab1_print_cur_status();
  100239:	e8 ec fe ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10023e:	83 ec 0c             	sub    $0xc,%esp
  100241:	8d 83 b4 50 ff ff    	lea    -0xaf4c(%ebx),%eax
  100247:	50                   	push   %eax
  100248:	e8 a6 00 00 00       	call   1002f3 <cprintf>
  10024d:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
  100250:	e8 b2 ff ff ff       	call   100207 <lab1_switch_to_user>
    lab1_print_cur_status();
  100255:	e8 d0 fe ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10025a:	83 ec 0c             	sub    $0xc,%esp
  10025d:	8d 83 d4 50 ff ff    	lea    -0xaf2c(%ebx),%eax
  100263:	50                   	push   %eax
  100264:	e8 8a 00 00 00       	call   1002f3 <cprintf>
  100269:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
  10026c:	e8 a6 ff ff ff       	call   100217 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100271:	e8 b4 fe ff ff       	call   10012a <lab1_print_cur_status>
}
  100276:	90                   	nop
  100277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10027a:	c9                   	leave  
  10027b:	c3                   	ret    

0010027c <__x86.get_pc_thunk.ax>:
  10027c:	8b 04 24             	mov    (%esp),%eax
  10027f:	c3                   	ret    

00100280 <__x86.get_pc_thunk.bx>:
  100280:	8b 1c 24             	mov    (%esp),%ebx
  100283:	c3                   	ret    

00100284 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100284:	55                   	push   %ebp
  100285:	89 e5                	mov    %esp,%ebp
  100287:	53                   	push   %ebx
  100288:	83 ec 04             	sub    $0x4,%esp
  10028b:	e8 ec ff ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100290:	05 c0 e6 00 00       	add    $0xe6c0,%eax
    cons_putc(c);
  100295:	83 ec 0c             	sub    $0xc,%esp
  100298:	ff 75 08             	pushl  0x8(%ebp)
  10029b:	89 c3                	mov    %eax,%ebx
  10029d:	e8 fd 15 00 00       	call   10189f <cons_putc>
  1002a2:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  1002a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002a8:	8b 00                	mov    (%eax),%eax
  1002aa:	8d 50 01             	lea    0x1(%eax),%edx
  1002ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002b0:	89 10                	mov    %edx,(%eax)
}
  1002b2:	90                   	nop
  1002b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1002b6:	c9                   	leave  
  1002b7:	c3                   	ret    

001002b8 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  1002b8:	55                   	push   %ebp
  1002b9:	89 e5                	mov    %esp,%ebp
  1002bb:	53                   	push   %ebx
  1002bc:	83 ec 14             	sub    $0x14,%esp
  1002bf:	e8 b8 ff ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1002c4:	05 8c e6 00 00       	add    $0xe68c,%eax
    int cnt = 0;
  1002c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002d0:	ff 75 0c             	pushl  0xc(%ebp)
  1002d3:	ff 75 08             	pushl  0x8(%ebp)
  1002d6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  1002d9:	52                   	push   %edx
  1002da:	8d 90 34 19 ff ff    	lea    -0xe6cc(%eax),%edx
  1002e0:	52                   	push   %edx
  1002e1:	89 c3                	mov    %eax,%ebx
  1002e3:	e8 16 32 00 00       	call   1034fe <vprintfmt>
  1002e8:	83 c4 10             	add    $0x10,%esp
    return cnt;
  1002eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1002f1:	c9                   	leave  
  1002f2:	c3                   	ret    

001002f3 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  1002f3:	55                   	push   %ebp
  1002f4:	89 e5                	mov    %esp,%ebp
  1002f6:	83 ec 18             	sub    $0x18,%esp
  1002f9:	e8 7e ff ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1002fe:	05 52 e6 00 00       	add    $0xe652,%eax
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100303:	8d 45 0c             	lea    0xc(%ebp),%eax
  100306:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10030c:	83 ec 08             	sub    $0x8,%esp
  10030f:	50                   	push   %eax
  100310:	ff 75 08             	pushl  0x8(%ebp)
  100313:	e8 a0 ff ff ff       	call   1002b8 <vcprintf>
  100318:	83 c4 10             	add    $0x10,%esp
  10031b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10031e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100321:	c9                   	leave  
  100322:	c3                   	ret    

00100323 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100323:	55                   	push   %ebp
  100324:	89 e5                	mov    %esp,%ebp
  100326:	53                   	push   %ebx
  100327:	83 ec 04             	sub    $0x4,%esp
  10032a:	e8 4d ff ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10032f:	05 21 e6 00 00       	add    $0xe621,%eax
    cons_putc(c);
  100334:	83 ec 0c             	sub    $0xc,%esp
  100337:	ff 75 08             	pushl  0x8(%ebp)
  10033a:	89 c3                	mov    %eax,%ebx
  10033c:	e8 5e 15 00 00       	call   10189f <cons_putc>
  100341:	83 c4 10             	add    $0x10,%esp
}
  100344:	90                   	nop
  100345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100348:	c9                   	leave  
  100349:	c3                   	ret    

0010034a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10034a:	55                   	push   %ebp
  10034b:	89 e5                	mov    %esp,%ebp
  10034d:	83 ec 18             	sub    $0x18,%esp
  100350:	e8 27 ff ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100355:	05 fb e5 00 00       	add    $0xe5fb,%eax
    int cnt = 0;
  10035a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100361:	eb 14                	jmp    100377 <cputs+0x2d>
        cputch(c, &cnt);
  100363:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100367:	83 ec 08             	sub    $0x8,%esp
  10036a:	8d 55 f0             	lea    -0x10(%ebp),%edx
  10036d:	52                   	push   %edx
  10036e:	50                   	push   %eax
  10036f:	e8 10 ff ff ff       	call   100284 <cputch>
  100374:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
  100377:	8b 45 08             	mov    0x8(%ebp),%eax
  10037a:	8d 50 01             	lea    0x1(%eax),%edx
  10037d:	89 55 08             	mov    %edx,0x8(%ebp)
  100380:	0f b6 00             	movzbl (%eax),%eax
  100383:	88 45 f7             	mov    %al,-0x9(%ebp)
  100386:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  10038a:	75 d7                	jne    100363 <cputs+0x19>
    }
    cputch('\n', &cnt);
  10038c:	83 ec 08             	sub    $0x8,%esp
  10038f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100392:	50                   	push   %eax
  100393:	6a 0a                	push   $0xa
  100395:	e8 ea fe ff ff       	call   100284 <cputch>
  10039a:	83 c4 10             	add    $0x10,%esp
    return cnt;
  10039d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003a0:	c9                   	leave  
  1003a1:	c3                   	ret    

001003a2 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003a2:	55                   	push   %ebp
  1003a3:	89 e5                	mov    %esp,%ebp
  1003a5:	53                   	push   %ebx
  1003a6:	83 ec 14             	sub    $0x14,%esp
  1003a9:	e8 d2 fe ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  1003ae:	81 c3 a2 e5 00 00    	add    $0xe5a2,%ebx
    int c;
    while ((c = cons_getc()) == 0)
  1003b4:	e8 20 15 00 00       	call   1018d9 <cons_getc>
  1003b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003c0:	74 f2                	je     1003b4 <getchar+0x12>
        /* do nothing */;
    return c;
  1003c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003c5:	83 c4 14             	add    $0x14,%esp
  1003c8:	5b                   	pop    %ebx
  1003c9:	5d                   	pop    %ebp
  1003ca:	c3                   	ret    

001003cb <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  1003cb:	55                   	push   %ebp
  1003cc:	89 e5                	mov    %esp,%ebp
  1003ce:	53                   	push   %ebx
  1003cf:	83 ec 14             	sub    $0x14,%esp
  1003d2:	e8 a9 fe ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  1003d7:	81 c3 79 e5 00 00    	add    $0xe579,%ebx
    if (prompt != NULL) {
  1003dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1003e1:	74 15                	je     1003f8 <readline+0x2d>
        cprintf("%s", prompt);
  1003e3:	83 ec 08             	sub    $0x8,%esp
  1003e6:	ff 75 08             	pushl  0x8(%ebp)
  1003e9:	8d 83 f3 50 ff ff    	lea    -0xaf0d(%ebx),%eax
  1003ef:	50                   	push   %eax
  1003f0:	e8 fe fe ff ff       	call   1002f3 <cprintf>
  1003f5:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
  1003f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  1003ff:	e8 9e ff ff ff       	call   1003a2 <getchar>
  100404:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10040b:	79 0a                	jns    100417 <readline+0x4c>
            return NULL;
  10040d:	b8 00 00 00 00       	mov    $0x0,%eax
  100412:	e9 87 00 00 00       	jmp    10049e <readline+0xd3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100417:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10041b:	7e 2c                	jle    100449 <readline+0x7e>
  10041d:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100424:	7f 23                	jg     100449 <readline+0x7e>
            cputchar(c);
  100426:	83 ec 0c             	sub    $0xc,%esp
  100429:	ff 75 f0             	pushl  -0x10(%ebp)
  10042c:	e8 f2 fe ff ff       	call   100323 <cputchar>
  100431:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
  100434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100437:	8d 50 01             	lea    0x1(%eax),%edx
  10043a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10043d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100440:	88 94 03 90 01 00 00 	mov    %dl,0x190(%ebx,%eax,1)
  100447:	eb 50                	jmp    100499 <readline+0xce>
        }
        else if (c == '\b' && i > 0) {
  100449:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10044d:	75 1a                	jne    100469 <readline+0x9e>
  10044f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100453:	7e 14                	jle    100469 <readline+0x9e>
            cputchar(c);
  100455:	83 ec 0c             	sub    $0xc,%esp
  100458:	ff 75 f0             	pushl  -0x10(%ebp)
  10045b:	e8 c3 fe ff ff       	call   100323 <cputchar>
  100460:	83 c4 10             	add    $0x10,%esp
            i --;
  100463:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  100467:	eb 30                	jmp    100499 <readline+0xce>
        }
        else if (c == '\n' || c == '\r') {
  100469:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  10046d:	74 06                	je     100475 <readline+0xaa>
  10046f:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  100473:	75 8a                	jne    1003ff <readline+0x34>
            cputchar(c);
  100475:	83 ec 0c             	sub    $0xc,%esp
  100478:	ff 75 f0             	pushl  -0x10(%ebp)
  10047b:	e8 a3 fe ff ff       	call   100323 <cputchar>
  100480:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
  100483:	8d 93 90 01 00 00    	lea    0x190(%ebx),%edx
  100489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10048c:	01 d0                	add    %edx,%eax
  10048e:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  100491:	8d 83 90 01 00 00    	lea    0x190(%ebx),%eax
  100497:	eb 05                	jmp    10049e <readline+0xd3>
        c = getchar();
  100499:	e9 61 ff ff ff       	jmp    1003ff <readline+0x34>
        }
    }
}
  10049e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1004a1:	c9                   	leave  
  1004a2:	c3                   	ret    

001004a3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1004a3:	55                   	push   %ebp
  1004a4:	89 e5                	mov    %esp,%ebp
  1004a6:	53                   	push   %ebx
  1004a7:	83 ec 14             	sub    $0x14,%esp
  1004aa:	e8 d1 fd ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  1004af:	81 c3 a1 e4 00 00    	add    $0xe4a1,%ebx
    if (is_panic) {
  1004b5:	8b 83 90 05 00 00    	mov    0x590(%ebx),%eax
  1004bb:	85 c0                	test   %eax,%eax
  1004bd:	75 4e                	jne    10050d <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1004bf:	c7 83 90 05 00 00 01 	movl   $0x1,0x590(%ebx)
  1004c6:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1004c9:	8d 45 14             	lea    0x14(%ebp),%eax
  1004cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1004cf:	83 ec 04             	sub    $0x4,%esp
  1004d2:	ff 75 0c             	pushl  0xc(%ebp)
  1004d5:	ff 75 08             	pushl  0x8(%ebp)
  1004d8:	8d 83 f6 50 ff ff    	lea    -0xaf0a(%ebx),%eax
  1004de:	50                   	push   %eax
  1004df:	e8 0f fe ff ff       	call   1002f3 <cprintf>
  1004e4:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  1004e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004ea:	83 ec 08             	sub    $0x8,%esp
  1004ed:	50                   	push   %eax
  1004ee:	ff 75 10             	pushl  0x10(%ebp)
  1004f1:	e8 c2 fd ff ff       	call   1002b8 <vcprintf>
  1004f6:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  1004f9:	83 ec 0c             	sub    $0xc,%esp
  1004fc:	8d 83 12 51 ff ff    	lea    -0xaeee(%ebx),%eax
  100502:	50                   	push   %eax
  100503:	e8 eb fd ff ff       	call   1002f3 <cprintf>
  100508:	83 c4 10             	add    $0x10,%esp
  10050b:	eb 01                	jmp    10050e <__panic+0x6b>
        goto panic_dead;
  10050d:	90                   	nop
    va_end(ap);

panic_dead:
    intr_disable();
  10050e:	e8 31 16 00 00       	call   101b44 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100513:	83 ec 0c             	sub    $0xc,%esp
  100516:	6a 00                	push   $0x0
  100518:	e8 fe 08 00 00       	call   100e1b <kmonitor>
  10051d:	83 c4 10             	add    $0x10,%esp
  100520:	eb f1                	jmp    100513 <__panic+0x70>

00100522 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100522:	55                   	push   %ebp
  100523:	89 e5                	mov    %esp,%ebp
  100525:	53                   	push   %ebx
  100526:	83 ec 14             	sub    $0x14,%esp
  100529:	e8 52 fd ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  10052e:	81 c3 22 e4 00 00    	add    $0xe422,%ebx
    va_list ap;
    va_start(ap, fmt);
  100534:	8d 45 14             	lea    0x14(%ebp),%eax
  100537:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  10053a:	83 ec 04             	sub    $0x4,%esp
  10053d:	ff 75 0c             	pushl  0xc(%ebp)
  100540:	ff 75 08             	pushl  0x8(%ebp)
  100543:	8d 83 14 51 ff ff    	lea    -0xaeec(%ebx),%eax
  100549:	50                   	push   %eax
  10054a:	e8 a4 fd ff ff       	call   1002f3 <cprintf>
  10054f:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  100552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100555:	83 ec 08             	sub    $0x8,%esp
  100558:	50                   	push   %eax
  100559:	ff 75 10             	pushl  0x10(%ebp)
  10055c:	e8 57 fd ff ff       	call   1002b8 <vcprintf>
  100561:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  100564:	83 ec 0c             	sub    $0xc,%esp
  100567:	8d 83 12 51 ff ff    	lea    -0xaeee(%ebx),%eax
  10056d:	50                   	push   %eax
  10056e:	e8 80 fd ff ff       	call   1002f3 <cprintf>
  100573:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  100576:	90                   	nop
  100577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10057a:	c9                   	leave  
  10057b:	c3                   	ret    

0010057c <is_kernel_panic>:

bool
is_kernel_panic(void) {
  10057c:	55                   	push   %ebp
  10057d:	89 e5                	mov    %esp,%ebp
  10057f:	e8 f8 fc ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100584:	05 cc e3 00 00       	add    $0xe3cc,%eax
    return is_panic;
  100589:	8b 80 90 05 00 00    	mov    0x590(%eax),%eax
}
  10058f:	5d                   	pop    %ebp
  100590:	c3                   	ret    

00100591 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100591:	55                   	push   %ebp
  100592:	89 e5                	mov    %esp,%ebp
  100594:	83 ec 20             	sub    $0x20,%esp
  100597:	e8 e0 fc ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10059c:	05 b4 e3 00 00       	add    $0xe3b4,%eax
    int l = *region_left, r = *region_right, any_matches = 0;
  1005a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a4:	8b 00                	mov    (%eax),%eax
  1005a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1005a9:	8b 45 10             	mov    0x10(%ebp),%eax
  1005ac:	8b 00                	mov    (%eax),%eax
  1005ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1005b8:	e9 d2 00 00 00       	jmp    10068f <stab_binsearch+0xfe>
        int true_m = (l + r) / 2, m = true_m;
  1005bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1005c3:	01 d0                	add    %edx,%eax
  1005c5:	89 c2                	mov    %eax,%edx
  1005c7:	c1 ea 1f             	shr    $0x1f,%edx
  1005ca:	01 d0                	add    %edx,%eax
  1005cc:	d1 f8                	sar    %eax
  1005ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1005d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1005d4:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1005d7:	eb 04                	jmp    1005dd <stab_binsearch+0x4c>
            m --;
  1005d9:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1005dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005e3:	7c 1f                	jl     100604 <stab_binsearch+0x73>
  1005e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005e8:	89 d0                	mov    %edx,%eax
  1005ea:	01 c0                	add    %eax,%eax
  1005ec:	01 d0                	add    %edx,%eax
  1005ee:	c1 e0 02             	shl    $0x2,%eax
  1005f1:	89 c2                	mov    %eax,%edx
  1005f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1005f6:	01 d0                	add    %edx,%eax
  1005f8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005fc:	0f b6 c0             	movzbl %al,%eax
  1005ff:	39 45 14             	cmp    %eax,0x14(%ebp)
  100602:	75 d5                	jne    1005d9 <stab_binsearch+0x48>
        }
        if (m < l) {    // no match in [l, m]
  100604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100607:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10060a:	7d 0b                	jge    100617 <stab_binsearch+0x86>
            l = true_m + 1;
  10060c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10060f:	83 c0 01             	add    $0x1,%eax
  100612:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100615:	eb 78                	jmp    10068f <stab_binsearch+0xfe>
        }

        // actual binary search
        any_matches = 1;
  100617:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10061e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100621:	89 d0                	mov    %edx,%eax
  100623:	01 c0                	add    %eax,%eax
  100625:	01 d0                	add    %edx,%eax
  100627:	c1 e0 02             	shl    $0x2,%eax
  10062a:	89 c2                	mov    %eax,%edx
  10062c:	8b 45 08             	mov    0x8(%ebp),%eax
  10062f:	01 d0                	add    %edx,%eax
  100631:	8b 40 08             	mov    0x8(%eax),%eax
  100634:	39 45 18             	cmp    %eax,0x18(%ebp)
  100637:	76 13                	jbe    10064c <stab_binsearch+0xbb>
            *region_left = m;
  100639:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10063f:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100641:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100644:	83 c0 01             	add    $0x1,%eax
  100647:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10064a:	eb 43                	jmp    10068f <stab_binsearch+0xfe>
        } else if (stabs[m].n_value > addr) {
  10064c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10064f:	89 d0                	mov    %edx,%eax
  100651:	01 c0                	add    %eax,%eax
  100653:	01 d0                	add    %edx,%eax
  100655:	c1 e0 02             	shl    $0x2,%eax
  100658:	89 c2                	mov    %eax,%edx
  10065a:	8b 45 08             	mov    0x8(%ebp),%eax
  10065d:	01 d0                	add    %edx,%eax
  10065f:	8b 40 08             	mov    0x8(%eax),%eax
  100662:	39 45 18             	cmp    %eax,0x18(%ebp)
  100665:	73 16                	jae    10067d <stab_binsearch+0xec>
            *region_right = m - 1;
  100667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10066a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10066d:	8b 45 10             	mov    0x10(%ebp),%eax
  100670:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100675:	83 e8 01             	sub    $0x1,%eax
  100678:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10067b:	eb 12                	jmp    10068f <stab_binsearch+0xfe>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10067d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100680:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100683:	89 10                	mov    %edx,(%eax)
            l = m;
  100685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100688:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  10068b:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
  10068f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100692:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100695:	0f 8e 22 ff ff ff    	jle    1005bd <stab_binsearch+0x2c>
        }
    }

    if (!any_matches) {
  10069b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10069f:	75 0f                	jne    1006b0 <stab_binsearch+0x11f>
        *region_right = *region_left - 1;
  1006a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006a4:	8b 00                	mov    (%eax),%eax
  1006a6:	8d 50 ff             	lea    -0x1(%eax),%edx
  1006a9:	8b 45 10             	mov    0x10(%ebp),%eax
  1006ac:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1006ae:	eb 3f                	jmp    1006ef <stab_binsearch+0x15e>
        l = *region_right;
  1006b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1006b3:	8b 00                	mov    (%eax),%eax
  1006b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1006b8:	eb 04                	jmp    1006be <stab_binsearch+0x12d>
  1006ba:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1006be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c1:	8b 00                	mov    (%eax),%eax
  1006c3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1006c6:	7e 1f                	jle    1006e7 <stab_binsearch+0x156>
  1006c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1006cb:	89 d0                	mov    %edx,%eax
  1006cd:	01 c0                	add    %eax,%eax
  1006cf:	01 d0                	add    %edx,%eax
  1006d1:	c1 e0 02             	shl    $0x2,%eax
  1006d4:	89 c2                	mov    %eax,%edx
  1006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1006d9:	01 d0                	add    %edx,%eax
  1006db:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1006df:	0f b6 c0             	movzbl %al,%eax
  1006e2:	39 45 14             	cmp    %eax,0x14(%ebp)
  1006e5:	75 d3                	jne    1006ba <stab_binsearch+0x129>
        *region_left = l;
  1006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1006ed:	89 10                	mov    %edx,(%eax)
}
  1006ef:	90                   	nop
  1006f0:	c9                   	leave  
  1006f1:	c3                   	ret    

001006f2 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1006f2:	55                   	push   %ebp
  1006f3:	89 e5                	mov    %esp,%ebp
  1006f5:	53                   	push   %ebx
  1006f6:	83 ec 34             	sub    $0x34,%esp
  1006f9:	e8 82 fb ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  1006fe:	81 c3 52 e2 00 00    	add    $0xe252,%ebx
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100704:	8b 45 0c             	mov    0xc(%ebp),%eax
  100707:	8d 93 34 51 ff ff    	lea    -0xaecc(%ebx),%edx
  10070d:	89 10                	mov    %edx,(%eax)
    info->eip_line = 0;
  10070f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100712:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100719:	8b 45 0c             	mov    0xc(%ebp),%eax
  10071c:	8d 93 34 51 ff ff    	lea    -0xaecc(%ebx),%edx
  100722:	89 50 08             	mov    %edx,0x8(%eax)
    info->eip_fn_namelen = 9;
  100725:	8b 45 0c             	mov    0xc(%ebp),%eax
  100728:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100732:	8b 55 08             	mov    0x8(%ebp),%edx
  100735:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100738:	8b 45 0c             	mov    0xc(%ebp),%eax
  10073b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100742:	c7 c0 3c 42 10 00    	mov    $0x10423c,%eax
  100748:	89 45 f4             	mov    %eax,-0xc(%ebp)
    stab_end = __STAB_END__;
  10074b:	c7 c0 1c bf 10 00    	mov    $0x10bf1c,%eax
  100751:	89 45 f0             	mov    %eax,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100754:	c7 c0 1d bf 10 00    	mov    $0x10bf1d,%eax
  10075a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10075d:	c7 c0 fc df 10 00    	mov    $0x10dffc,%eax
  100763:	89 45 e8             	mov    %eax,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100766:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100769:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10076c:	76 0d                	jbe    10077b <debuginfo_eip+0x89>
  10076e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100771:	83 e8 01             	sub    $0x1,%eax
  100774:	0f b6 00             	movzbl (%eax),%eax
  100777:	84 c0                	test   %al,%al
  100779:	74 0a                	je     100785 <debuginfo_eip+0x93>
        return -1;
  10077b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100780:	e9 91 02 00 00       	jmp    100a16 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100785:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10078c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100792:	29 c2                	sub    %eax,%edx
  100794:	89 d0                	mov    %edx,%eax
  100796:	c1 f8 02             	sar    $0x2,%eax
  100799:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  10079f:	83 e8 01             	sub    $0x1,%eax
  1007a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1007a5:	ff 75 08             	pushl  0x8(%ebp)
  1007a8:	6a 64                	push   $0x64
  1007aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1007ad:	50                   	push   %eax
  1007ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1007b1:	50                   	push   %eax
  1007b2:	ff 75 f4             	pushl  -0xc(%ebp)
  1007b5:	e8 d7 fd ff ff       	call   100591 <stab_binsearch>
  1007ba:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
  1007bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007c0:	85 c0                	test   %eax,%eax
  1007c2:	75 0a                	jne    1007ce <debuginfo_eip+0xdc>
        return -1;
  1007c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007c9:	e9 48 02 00 00       	jmp    100a16 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1007ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1007d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1007da:	ff 75 08             	pushl  0x8(%ebp)
  1007dd:	6a 24                	push   $0x24
  1007df:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1007e2:	50                   	push   %eax
  1007e3:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1007e6:	50                   	push   %eax
  1007e7:	ff 75 f4             	pushl  -0xc(%ebp)
  1007ea:	e8 a2 fd ff ff       	call   100591 <stab_binsearch>
  1007ef:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
  1007f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1007f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007f8:	39 c2                	cmp    %eax,%edx
  1007fa:	7f 7c                	jg     100878 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1007fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007ff:	89 c2                	mov    %eax,%edx
  100801:	89 d0                	mov    %edx,%eax
  100803:	01 c0                	add    %eax,%eax
  100805:	01 d0                	add    %edx,%eax
  100807:	c1 e0 02             	shl    $0x2,%eax
  10080a:	89 c2                	mov    %eax,%edx
  10080c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10080f:	01 d0                	add    %edx,%eax
  100811:	8b 00                	mov    (%eax),%eax
  100813:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100816:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100819:	29 d1                	sub    %edx,%ecx
  10081b:	89 ca                	mov    %ecx,%edx
  10081d:	39 d0                	cmp    %edx,%eax
  10081f:	73 22                	jae    100843 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100821:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100824:	89 c2                	mov    %eax,%edx
  100826:	89 d0                	mov    %edx,%eax
  100828:	01 c0                	add    %eax,%eax
  10082a:	01 d0                	add    %edx,%eax
  10082c:	c1 e0 02             	shl    $0x2,%eax
  10082f:	89 c2                	mov    %eax,%edx
  100831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100834:	01 d0                	add    %edx,%eax
  100836:	8b 10                	mov    (%eax),%edx
  100838:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10083b:	01 c2                	add    %eax,%edx
  10083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100840:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100843:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100846:	89 c2                	mov    %eax,%edx
  100848:	89 d0                	mov    %edx,%eax
  10084a:	01 c0                	add    %eax,%eax
  10084c:	01 d0                	add    %edx,%eax
  10084e:	c1 e0 02             	shl    $0x2,%eax
  100851:	89 c2                	mov    %eax,%edx
  100853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100856:	01 d0                	add    %edx,%eax
  100858:	8b 50 08             	mov    0x8(%eax),%edx
  10085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10085e:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100861:	8b 45 0c             	mov    0xc(%ebp),%eax
  100864:	8b 40 10             	mov    0x10(%eax),%eax
  100867:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10086a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10086d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100870:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100873:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100876:	eb 15                	jmp    10088d <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100878:	8b 45 0c             	mov    0xc(%ebp),%eax
  10087b:	8b 55 08             	mov    0x8(%ebp),%edx
  10087e:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100881:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100884:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100887:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10088a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  10088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100890:	8b 40 08             	mov    0x8(%eax),%eax
  100893:	83 ec 08             	sub    $0x8,%esp
  100896:	6a 3a                	push   $0x3a
  100898:	50                   	push   %eax
  100899:	e8 32 27 00 00       	call   102fd0 <strfind>
  10089e:	83 c4 10             	add    $0x10,%esp
  1008a1:	89 c2                	mov    %eax,%edx
  1008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008a6:	8b 40 08             	mov    0x8(%eax),%eax
  1008a9:	29 c2                	sub    %eax,%edx
  1008ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008ae:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1008b1:	83 ec 0c             	sub    $0xc,%esp
  1008b4:	ff 75 08             	pushl  0x8(%ebp)
  1008b7:	6a 44                	push   $0x44
  1008b9:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1008bc:	50                   	push   %eax
  1008bd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1008c0:	50                   	push   %eax
  1008c1:	ff 75 f4             	pushl  -0xc(%ebp)
  1008c4:	e8 c8 fc ff ff       	call   100591 <stab_binsearch>
  1008c9:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
  1008cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1008d2:	39 c2                	cmp    %eax,%edx
  1008d4:	7f 24                	jg     1008fa <debuginfo_eip+0x208>
        info->eip_line = stabs[rline].n_desc;
  1008d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1008d9:	89 c2                	mov    %eax,%edx
  1008db:	89 d0                	mov    %edx,%eax
  1008dd:	01 c0                	add    %eax,%eax
  1008df:	01 d0                	add    %edx,%eax
  1008e1:	c1 e0 02             	shl    $0x2,%eax
  1008e4:	89 c2                	mov    %eax,%edx
  1008e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e9:	01 d0                	add    %edx,%eax
  1008eb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1008ef:	0f b7 d0             	movzwl %ax,%edx
  1008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f5:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1008f8:	eb 13                	jmp    10090d <debuginfo_eip+0x21b>
        return -1;
  1008fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1008ff:	e9 12 01 00 00       	jmp    100a16 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100904:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100907:	83 e8 01             	sub    $0x1,%eax
  10090a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10090d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100910:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100913:	39 c2                	cmp    %eax,%edx
  100915:	7c 56                	jl     10096d <debuginfo_eip+0x27b>
           && stabs[lline].n_type != N_SOL
  100917:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10091a:	89 c2                	mov    %eax,%edx
  10091c:	89 d0                	mov    %edx,%eax
  10091e:	01 c0                	add    %eax,%eax
  100920:	01 d0                	add    %edx,%eax
  100922:	c1 e0 02             	shl    $0x2,%eax
  100925:	89 c2                	mov    %eax,%edx
  100927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10092a:	01 d0                	add    %edx,%eax
  10092c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100930:	3c 84                	cmp    $0x84,%al
  100932:	74 39                	je     10096d <debuginfo_eip+0x27b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100934:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100937:	89 c2                	mov    %eax,%edx
  100939:	89 d0                	mov    %edx,%eax
  10093b:	01 c0                	add    %eax,%eax
  10093d:	01 d0                	add    %edx,%eax
  10093f:	c1 e0 02             	shl    $0x2,%eax
  100942:	89 c2                	mov    %eax,%edx
  100944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100947:	01 d0                	add    %edx,%eax
  100949:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10094d:	3c 64                	cmp    $0x64,%al
  10094f:	75 b3                	jne    100904 <debuginfo_eip+0x212>
  100951:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100954:	89 c2                	mov    %eax,%edx
  100956:	89 d0                	mov    %edx,%eax
  100958:	01 c0                	add    %eax,%eax
  10095a:	01 d0                	add    %edx,%eax
  10095c:	c1 e0 02             	shl    $0x2,%eax
  10095f:	89 c2                	mov    %eax,%edx
  100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100964:	01 d0                	add    %edx,%eax
  100966:	8b 40 08             	mov    0x8(%eax),%eax
  100969:	85 c0                	test   %eax,%eax
  10096b:	74 97                	je     100904 <debuginfo_eip+0x212>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10096d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100973:	39 c2                	cmp    %eax,%edx
  100975:	7c 46                	jl     1009bd <debuginfo_eip+0x2cb>
  100977:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10097a:	89 c2                	mov    %eax,%edx
  10097c:	89 d0                	mov    %edx,%eax
  10097e:	01 c0                	add    %eax,%eax
  100980:	01 d0                	add    %edx,%eax
  100982:	c1 e0 02             	shl    $0x2,%eax
  100985:	89 c2                	mov    %eax,%edx
  100987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10098a:	01 d0                	add    %edx,%eax
  10098c:	8b 00                	mov    (%eax),%eax
  10098e:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100991:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100994:	29 d1                	sub    %edx,%ecx
  100996:	89 ca                	mov    %ecx,%edx
  100998:	39 d0                	cmp    %edx,%eax
  10099a:	73 21                	jae    1009bd <debuginfo_eip+0x2cb>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10099c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10099f:	89 c2                	mov    %eax,%edx
  1009a1:	89 d0                	mov    %edx,%eax
  1009a3:	01 c0                	add    %eax,%eax
  1009a5:	01 d0                	add    %edx,%eax
  1009a7:	c1 e0 02             	shl    $0x2,%eax
  1009aa:	89 c2                	mov    %eax,%edx
  1009ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009af:	01 d0                	add    %edx,%eax
  1009b1:	8b 10                	mov    (%eax),%edx
  1009b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1009b6:	01 c2                	add    %eax,%edx
  1009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1009bb:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1009bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1009c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1009c3:	39 c2                	cmp    %eax,%edx
  1009c5:	7d 4a                	jge    100a11 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  1009c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1009ca:	83 c0 01             	add    $0x1,%eax
  1009cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1009d0:	eb 18                	jmp    1009ea <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1009d5:	8b 40 14             	mov    0x14(%eax),%eax
  1009d8:	8d 50 01             	lea    0x1(%eax),%edx
  1009db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1009de:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  1009e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1009e4:	83 c0 01             	add    $0x1,%eax
  1009e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1009ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1009ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  1009f0:	39 c2                	cmp    %eax,%edx
  1009f2:	7d 1d                	jge    100a11 <debuginfo_eip+0x31f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1009f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1009f7:	89 c2                	mov    %eax,%edx
  1009f9:	89 d0                	mov    %edx,%eax
  1009fb:	01 c0                	add    %eax,%eax
  1009fd:	01 d0                	add    %edx,%eax
  1009ff:	c1 e0 02             	shl    $0x2,%eax
  100a02:	89 c2                	mov    %eax,%edx
  100a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a07:	01 d0                	add    %edx,%eax
  100a09:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100a0d:	3c a0                	cmp    $0xa0,%al
  100a0f:	74 c1                	je     1009d2 <debuginfo_eip+0x2e0>
        }
    }
    return 0;
  100a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100a16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100a19:	c9                   	leave  
  100a1a:	c3                   	ret    

00100a1b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100a1b:	55                   	push   %ebp
  100a1c:	89 e5                	mov    %esp,%ebp
  100a1e:	53                   	push   %ebx
  100a1f:	83 ec 04             	sub    $0x4,%esp
  100a22:	e8 59 f8 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100a27:	81 c3 29 df 00 00    	add    $0xdf29,%ebx
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100a2d:	83 ec 0c             	sub    $0xc,%esp
  100a30:	8d 83 3e 51 ff ff    	lea    -0xaec2(%ebx),%eax
  100a36:	50                   	push   %eax
  100a37:	e8 b7 f8 ff ff       	call   1002f3 <cprintf>
  100a3c:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100a3f:	83 ec 08             	sub    $0x8,%esp
  100a42:	c7 c0 00 00 10 00    	mov    $0x100000,%eax
  100a48:	50                   	push   %eax
  100a49:	8d 83 57 51 ff ff    	lea    -0xaea9(%ebx),%eax
  100a4f:	50                   	push   %eax
  100a50:	e8 9e f8 ff ff       	call   1002f3 <cprintf>
  100a55:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
  100a58:	83 ec 08             	sub    $0x8,%esp
  100a5b:	c7 c0 9c 39 10 00    	mov    $0x10399c,%eax
  100a61:	50                   	push   %eax
  100a62:	8d 83 6f 51 ff ff    	lea    -0xae91(%ebx),%eax
  100a68:	50                   	push   %eax
  100a69:	e8 85 f8 ff ff       	call   1002f3 <cprintf>
  100a6e:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
  100a71:	83 ec 08             	sub    $0x8,%esp
  100a74:	c7 c0 50 e9 10 00    	mov    $0x10e950,%eax
  100a7a:	50                   	push   %eax
  100a7b:	8d 83 87 51 ff ff    	lea    -0xae79(%ebx),%eax
  100a81:	50                   	push   %eax
  100a82:	e8 6c f8 ff ff       	call   1002f3 <cprintf>
  100a87:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
  100a8a:	83 ec 08             	sub    $0x8,%esp
  100a8d:	c7 c0 c0 fd 10 00    	mov    $0x10fdc0,%eax
  100a93:	50                   	push   %eax
  100a94:	8d 83 9f 51 ff ff    	lea    -0xae61(%ebx),%eax
  100a9a:	50                   	push   %eax
  100a9b:	e8 53 f8 ff ff       	call   1002f3 <cprintf>
  100aa0:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100aa3:	c7 c0 c0 fd 10 00    	mov    $0x10fdc0,%eax
  100aa9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100aaf:	c7 c0 00 00 10 00    	mov    $0x100000,%eax
  100ab5:	29 c2                	sub    %eax,%edx
  100ab7:	89 d0                	mov    %edx,%eax
  100ab9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100abf:	85 c0                	test   %eax,%eax
  100ac1:	0f 48 c2             	cmovs  %edx,%eax
  100ac4:	c1 f8 0a             	sar    $0xa,%eax
  100ac7:	83 ec 08             	sub    $0x8,%esp
  100aca:	50                   	push   %eax
  100acb:	8d 83 b8 51 ff ff    	lea    -0xae48(%ebx),%eax
  100ad1:	50                   	push   %eax
  100ad2:	e8 1c f8 ff ff       	call   1002f3 <cprintf>
  100ad7:	83 c4 10             	add    $0x10,%esp
}
  100ada:	90                   	nop
  100adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100ade:	c9                   	leave  
  100adf:	c3                   	ret    

00100ae0 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100ae0:	55                   	push   %ebp
  100ae1:	89 e5                	mov    %esp,%ebp
  100ae3:	53                   	push   %ebx
  100ae4:	81 ec 24 01 00 00    	sub    $0x124,%esp
  100aea:	e8 91 f7 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100aef:	81 c3 61 de 00 00    	add    $0xde61,%ebx
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100af5:	83 ec 08             	sub    $0x8,%esp
  100af8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100afb:	50                   	push   %eax
  100afc:	ff 75 08             	pushl  0x8(%ebp)
  100aff:	e8 ee fb ff ff       	call   1006f2 <debuginfo_eip>
  100b04:	83 c4 10             	add    $0x10,%esp
  100b07:	85 c0                	test   %eax,%eax
  100b09:	74 17                	je     100b22 <print_debuginfo+0x42>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100b0b:	83 ec 08             	sub    $0x8,%esp
  100b0e:	ff 75 08             	pushl  0x8(%ebp)
  100b11:	8d 83 e2 51 ff ff    	lea    -0xae1e(%ebx),%eax
  100b17:	50                   	push   %eax
  100b18:	e8 d6 f7 ff ff       	call   1002f3 <cprintf>
  100b1d:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100b20:	eb 67                	jmp    100b89 <print_debuginfo+0xa9>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100b22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b29:	eb 1c                	jmp    100b47 <print_debuginfo+0x67>
            fnname[j] = info.eip_fn_name[j];
  100b2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b31:	01 d0                	add    %edx,%eax
  100b33:	0f b6 00             	movzbl (%eax),%eax
  100b36:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100b3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b3f:	01 ca                	add    %ecx,%edx
  100b41:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100b43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100b47:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b4a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100b4d:	7c dc                	jl     100b2b <print_debuginfo+0x4b>
        fnname[j] = '\0';
  100b4f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b58:	01 d0                	add    %edx,%eax
  100b5a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100b5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100b60:	8b 55 08             	mov    0x8(%ebp),%edx
  100b63:	89 d1                	mov    %edx,%ecx
  100b65:	29 c1                	sub    %eax,%ecx
  100b67:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100b6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100b6d:	83 ec 0c             	sub    $0xc,%esp
  100b70:	51                   	push   %ecx
  100b71:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100b77:	51                   	push   %ecx
  100b78:	52                   	push   %edx
  100b79:	50                   	push   %eax
  100b7a:	8d 83 fe 51 ff ff    	lea    -0xae02(%ebx),%eax
  100b80:	50                   	push   %eax
  100b81:	e8 6d f7 ff ff       	call   1002f3 <cprintf>
  100b86:	83 c4 20             	add    $0x20,%esp
}
  100b89:	90                   	nop
  100b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100b8d:	c9                   	leave  
  100b8e:	c3                   	ret    

00100b8f <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100b8f:	55                   	push   %ebp
  100b90:	89 e5                	mov    %esp,%ebp
  100b92:	83 ec 10             	sub    $0x10,%esp
  100b95:	e8 e2 f6 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100b9a:	05 b6 dd 00 00       	add    $0xddb6,%eax
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100b9f:	8b 45 04             	mov    0x4(%ebp),%eax
  100ba2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100ba8:	c9                   	leave  
  100ba9:	c3                   	ret    

00100baa <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100baa:	55                   	push   %ebp
  100bab:	89 e5                	mov    %esp,%ebp
  100bad:	53                   	push   %ebx
  100bae:	83 ec 24             	sub    $0x24,%esp
  100bb1:	e8 ca f6 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100bb6:	81 c3 9a dd 00 00    	add    $0xdd9a,%ebx
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100bbc:	89 e8                	mov    %ebp,%eax
  100bbe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100bc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
  100bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
  100bc7:	e8 c3 ff ff ff       	call   100b8f <read_eip>
  100bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for(uint32_t i = 0;  ebp != 0 && i < STACKFRAME_DEPTH; i++) {
  100bcf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100bd6:	e9 93 00 00 00       	jmp    100c6e <print_stackframe+0xc4>
          cprintf("ebp:0x%x%08x eip:0x%08x args:", ebp, eip);
  100bdb:	83 ec 04             	sub    $0x4,%esp
  100bde:	ff 75 f0             	pushl  -0x10(%ebp)
  100be1:	ff 75 f4             	pushl  -0xc(%ebp)
  100be4:	8d 83 10 52 ff ff    	lea    -0xadf0(%ebx),%eax
  100bea:	50                   	push   %eax
  100beb:	e8 03 f7 ff ff       	call   1002f3 <cprintf>
  100bf0:	83 c4 10             	add    $0x10,%esp
          uint32_t* args = (uint32_t*)ebp + 2;
  100bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bf6:	83 c0 08             	add    $0x8,%eax
  100bf9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          for(uint32_t j = 0; j < 4; j++)
  100bfc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100c03:	eb 28                	jmp    100c2d <print_stackframe+0x83>
            cprintf("0x%08x ", args[j]);
  100c05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100c08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100c12:	01 d0                	add    %edx,%eax
  100c14:	8b 00                	mov    (%eax),%eax
  100c16:	83 ec 08             	sub    $0x8,%esp
  100c19:	50                   	push   %eax
  100c1a:	8d 83 2e 52 ff ff    	lea    -0xadd2(%ebx),%eax
  100c20:	50                   	push   %eax
  100c21:	e8 cd f6 ff ff       	call   1002f3 <cprintf>
  100c26:	83 c4 10             	add    $0x10,%esp
          for(uint32_t j = 0; j < 4; j++)
  100c29:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100c2d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100c31:	76 d2                	jbe    100c05 <print_stackframe+0x5b>
           cprintf("\n");
  100c33:	83 ec 0c             	sub    $0xc,%esp
  100c36:	8d 83 36 52 ff ff    	lea    -0xadca(%ebx),%eax
  100c3c:	50                   	push   %eax
  100c3d:	e8 b1 f6 ff ff       	call   1002f3 <cprintf>
  100c42:	83 c4 10             	add    $0x10,%esp
           print_debuginfo(eip-1);
  100c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100c48:	83 e8 01             	sub    $0x1,%eax
  100c4b:	83 ec 0c             	sub    $0xc,%esp
  100c4e:	50                   	push   %eax
  100c4f:	e8 8c fe ff ff       	call   100ae0 <print_debuginfo>
  100c54:	83 c4 10             	add    $0x10,%esp
           eip = *((uint32_t*)ebp + 1);
  100c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c5a:	83 c0 04             	add    $0x4,%eax
  100c5d:	8b 00                	mov    (%eax),%eax
  100c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
           ebp = *(uint32_t*)ebp; 
  100c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c65:	8b 00                	mov    (%eax),%eax
  100c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(uint32_t i = 0;  ebp != 0 && i < STACKFRAME_DEPTH; i++) {
  100c6a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100c6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c72:	74 0a                	je     100c7e <print_stackframe+0xd4>
  100c74:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100c78:	0f 86 5d ff ff ff    	jbe    100bdb <print_stackframe+0x31>
      }
}
  100c7e:	90                   	nop
  100c7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100c82:	c9                   	leave  
  100c83:	c3                   	ret    

00100c84 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100c84:	55                   	push   %ebp
  100c85:	89 e5                	mov    %esp,%ebp
  100c87:	53                   	push   %ebx
  100c88:	83 ec 14             	sub    $0x14,%esp
  100c8b:	e8 f0 f5 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100c90:	81 c3 c0 dc 00 00    	add    $0xdcc0,%ebx
    int argc = 0;
  100c96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c9d:	eb 0c                	jmp    100cab <parse+0x27>
            *buf ++ = '\0';
  100c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  100ca2:	8d 50 01             	lea    0x1(%eax),%edx
  100ca5:	89 55 08             	mov    %edx,0x8(%ebp)
  100ca8:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100cab:	8b 45 08             	mov    0x8(%ebp),%eax
  100cae:	0f b6 00             	movzbl (%eax),%eax
  100cb1:	84 c0                	test   %al,%al
  100cb3:	74 20                	je     100cd5 <parse+0x51>
  100cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  100cb8:	0f b6 00             	movzbl (%eax),%eax
  100cbb:	0f be c0             	movsbl %al,%eax
  100cbe:	83 ec 08             	sub    $0x8,%esp
  100cc1:	50                   	push   %eax
  100cc2:	8d 83 b8 52 ff ff    	lea    -0xad48(%ebx),%eax
  100cc8:	50                   	push   %eax
  100cc9:	e8 c5 22 00 00       	call   102f93 <strchr>
  100cce:	83 c4 10             	add    $0x10,%esp
  100cd1:	85 c0                	test   %eax,%eax
  100cd3:	75 ca                	jne    100c9f <parse+0x1b>
        }
        if (*buf == '\0') {
  100cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd8:	0f b6 00             	movzbl (%eax),%eax
  100cdb:	84 c0                	test   %al,%al
  100cdd:	74 69                	je     100d48 <parse+0xc4>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100cdf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ce3:	75 14                	jne    100cf9 <parse+0x75>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ce5:	83 ec 08             	sub    $0x8,%esp
  100ce8:	6a 10                	push   $0x10
  100cea:	8d 83 bd 52 ff ff    	lea    -0xad43(%ebx),%eax
  100cf0:	50                   	push   %eax
  100cf1:	e8 fd f5 ff ff       	call   1002f3 <cprintf>
  100cf6:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
  100cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cfc:	8d 50 01             	lea    0x1(%eax),%edx
  100cff:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100d02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d0c:	01 c2                	add    %eax,%edx
  100d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  100d11:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100d13:	eb 04                	jmp    100d19 <parse+0x95>
            buf ++;
  100d15:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100d19:	8b 45 08             	mov    0x8(%ebp),%eax
  100d1c:	0f b6 00             	movzbl (%eax),%eax
  100d1f:	84 c0                	test   %al,%al
  100d21:	74 88                	je     100cab <parse+0x27>
  100d23:	8b 45 08             	mov    0x8(%ebp),%eax
  100d26:	0f b6 00             	movzbl (%eax),%eax
  100d29:	0f be c0             	movsbl %al,%eax
  100d2c:	83 ec 08             	sub    $0x8,%esp
  100d2f:	50                   	push   %eax
  100d30:	8d 83 b8 52 ff ff    	lea    -0xad48(%ebx),%eax
  100d36:	50                   	push   %eax
  100d37:	e8 57 22 00 00       	call   102f93 <strchr>
  100d3c:	83 c4 10             	add    $0x10,%esp
  100d3f:	85 c0                	test   %eax,%eax
  100d41:	74 d2                	je     100d15 <parse+0x91>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100d43:	e9 63 ff ff ff       	jmp    100cab <parse+0x27>
            break;
  100d48:	90                   	nop
        }
    }
    return argc;
  100d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100d4f:	c9                   	leave  
  100d50:	c3                   	ret    

00100d51 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100d51:	55                   	push   %ebp
  100d52:	89 e5                	mov    %esp,%ebp
  100d54:	56                   	push   %esi
  100d55:	53                   	push   %ebx
  100d56:	83 ec 50             	sub    $0x50,%esp
  100d59:	e8 22 f5 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100d5e:	81 c3 f2 db 00 00    	add    $0xdbf2,%ebx
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100d64:	83 ec 08             	sub    $0x8,%esp
  100d67:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100d6a:	50                   	push   %eax
  100d6b:	ff 75 08             	pushl  0x8(%ebp)
  100d6e:	e8 11 ff ff ff       	call   100c84 <parse>
  100d73:	83 c4 10             	add    $0x10,%esp
  100d76:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100d79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100d7d:	75 0a                	jne    100d89 <runcmd+0x38>
        return 0;
  100d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  100d84:	e9 8b 00 00 00       	jmp    100e14 <runcmd+0xc3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d90:	eb 5f                	jmp    100df1 <runcmd+0xa0>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100d92:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100d95:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d98:	8d b3 10 00 00 00    	lea    0x10(%ebx),%esi
  100d9e:	89 d0                	mov    %edx,%eax
  100da0:	01 c0                	add    %eax,%eax
  100da2:	01 d0                	add    %edx,%eax
  100da4:	c1 e0 02             	shl    $0x2,%eax
  100da7:	01 f0                	add    %esi,%eax
  100da9:	8b 00                	mov    (%eax),%eax
  100dab:	83 ec 08             	sub    $0x8,%esp
  100dae:	51                   	push   %ecx
  100daf:	50                   	push   %eax
  100db0:	e8 2a 21 00 00       	call   102edf <strcmp>
  100db5:	83 c4 10             	add    $0x10,%esp
  100db8:	85 c0                	test   %eax,%eax
  100dba:	75 31                	jne    100ded <runcmd+0x9c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100dbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100dbf:	8d 8b 18 00 00 00    	lea    0x18(%ebx),%ecx
  100dc5:	89 d0                	mov    %edx,%eax
  100dc7:	01 c0                	add    %eax,%eax
  100dc9:	01 d0                	add    %edx,%eax
  100dcb:	c1 e0 02             	shl    $0x2,%eax
  100dce:	01 c8                	add    %ecx,%eax
  100dd0:	8b 10                	mov    (%eax),%edx
  100dd2:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100dd5:	83 c0 04             	add    $0x4,%eax
  100dd8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100ddb:	83 e9 01             	sub    $0x1,%ecx
  100dde:	83 ec 04             	sub    $0x4,%esp
  100de1:	ff 75 0c             	pushl  0xc(%ebp)
  100de4:	50                   	push   %eax
  100de5:	51                   	push   %ecx
  100de6:	ff d2                	call   *%edx
  100de8:	83 c4 10             	add    $0x10,%esp
  100deb:	eb 27                	jmp    100e14 <runcmd+0xc3>
    for (i = 0; i < NCOMMANDS; i ++) {
  100ded:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100df4:	83 f8 02             	cmp    $0x2,%eax
  100df7:	76 99                	jbe    100d92 <runcmd+0x41>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100df9:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100dfc:	83 ec 08             	sub    $0x8,%esp
  100dff:	50                   	push   %eax
  100e00:	8d 83 db 52 ff ff    	lea    -0xad25(%ebx),%eax
  100e06:	50                   	push   %eax
  100e07:	e8 e7 f4 ff ff       	call   1002f3 <cprintf>
  100e0c:	83 c4 10             	add    $0x10,%esp
    return 0;
  100e0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  100e17:	5b                   	pop    %ebx
  100e18:	5e                   	pop    %esi
  100e19:	5d                   	pop    %ebp
  100e1a:	c3                   	ret    

00100e1b <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100e1b:	55                   	push   %ebp
  100e1c:	89 e5                	mov    %esp,%ebp
  100e1e:	53                   	push   %ebx
  100e1f:	83 ec 14             	sub    $0x14,%esp
  100e22:	e8 59 f4 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100e27:	81 c3 29 db 00 00    	add    $0xdb29,%ebx
    cprintf("Welcome to the kernel debug monitor!!\n");
  100e2d:	83 ec 0c             	sub    $0xc,%esp
  100e30:	8d 83 f4 52 ff ff    	lea    -0xad0c(%ebx),%eax
  100e36:	50                   	push   %eax
  100e37:	e8 b7 f4 ff ff       	call   1002f3 <cprintf>
  100e3c:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
  100e3f:	83 ec 0c             	sub    $0xc,%esp
  100e42:	8d 83 1c 53 ff ff    	lea    -0xace4(%ebx),%eax
  100e48:	50                   	push   %eax
  100e49:	e8 a5 f4 ff ff       	call   1002f3 <cprintf>
  100e4e:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
  100e51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e55:	74 0e                	je     100e65 <kmonitor+0x4a>
        print_trapframe(tf);
  100e57:	83 ec 0c             	sub    $0xc,%esp
  100e5a:	ff 75 08             	pushl  0x8(%ebp)
  100e5d:	e8 39 0f 00 00       	call   101d9b <print_trapframe>
  100e62:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100e65:	83 ec 0c             	sub    $0xc,%esp
  100e68:	8d 83 41 53 ff ff    	lea    -0xacbf(%ebx),%eax
  100e6e:	50                   	push   %eax
  100e6f:	e8 57 f5 ff ff       	call   1003cb <readline>
  100e74:	83 c4 10             	add    $0x10,%esp
  100e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100e7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100e7e:	74 e5                	je     100e65 <kmonitor+0x4a>
            if (runcmd(buf, tf) < 0) {
  100e80:	83 ec 08             	sub    $0x8,%esp
  100e83:	ff 75 08             	pushl  0x8(%ebp)
  100e86:	ff 75 f4             	pushl  -0xc(%ebp)
  100e89:	e8 c3 fe ff ff       	call   100d51 <runcmd>
  100e8e:	83 c4 10             	add    $0x10,%esp
  100e91:	85 c0                	test   %eax,%eax
  100e93:	78 02                	js     100e97 <kmonitor+0x7c>
        if ((buf = readline("K> ")) != NULL) {
  100e95:	eb ce                	jmp    100e65 <kmonitor+0x4a>
                break;
  100e97:	90                   	nop
            }
        }
    }
}
  100e98:	90                   	nop
  100e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100e9c:	c9                   	leave  
  100e9d:	c3                   	ret    

00100e9e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100e9e:	55                   	push   %ebp
  100e9f:	89 e5                	mov    %esp,%ebp
  100ea1:	56                   	push   %esi
  100ea2:	53                   	push   %ebx
  100ea3:	83 ec 10             	sub    $0x10,%esp
  100ea6:	e8 d5 f3 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100eab:	81 c3 a5 da 00 00    	add    $0xdaa5,%ebx
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100eb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100eb8:	eb 44                	jmp    100efe <mon_help+0x60>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ebd:	8d 8b 14 00 00 00    	lea    0x14(%ebx),%ecx
  100ec3:	89 d0                	mov    %edx,%eax
  100ec5:	01 c0                	add    %eax,%eax
  100ec7:	01 d0                	add    %edx,%eax
  100ec9:	c1 e0 02             	shl    $0x2,%eax
  100ecc:	01 c8                	add    %ecx,%eax
  100ece:	8b 08                	mov    (%eax),%ecx
  100ed0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ed3:	8d b3 10 00 00 00    	lea    0x10(%ebx),%esi
  100ed9:	89 d0                	mov    %edx,%eax
  100edb:	01 c0                	add    %eax,%eax
  100edd:	01 d0                	add    %edx,%eax
  100edf:	c1 e0 02             	shl    $0x2,%eax
  100ee2:	01 f0                	add    %esi,%eax
  100ee4:	8b 00                	mov    (%eax),%eax
  100ee6:	83 ec 04             	sub    $0x4,%esp
  100ee9:	51                   	push   %ecx
  100eea:	50                   	push   %eax
  100eeb:	8d 83 45 53 ff ff    	lea    -0xacbb(%ebx),%eax
  100ef1:	50                   	push   %eax
  100ef2:	e8 fc f3 ff ff       	call   1002f3 <cprintf>
  100ef7:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
  100efa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f01:	83 f8 02             	cmp    $0x2,%eax
  100f04:	76 b4                	jbe    100eba <mon_help+0x1c>
    }
    return 0;
  100f06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  100f0e:	5b                   	pop    %ebx
  100f0f:	5e                   	pop    %esi
  100f10:	5d                   	pop    %ebp
  100f11:	c3                   	ret    

00100f12 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100f12:	55                   	push   %ebp
  100f13:	89 e5                	mov    %esp,%ebp
  100f15:	53                   	push   %ebx
  100f16:	83 ec 04             	sub    $0x4,%esp
  100f19:	e8 5e f3 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100f1e:	05 32 da 00 00       	add    $0xda32,%eax
    print_kerninfo();
  100f23:	89 c3                	mov    %eax,%ebx
  100f25:	e8 f1 fa ff ff       	call   100a1b <print_kerninfo>
    return 0;
  100f2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100f2f:	83 c4 04             	add    $0x4,%esp
  100f32:	5b                   	pop    %ebx
  100f33:	5d                   	pop    %ebp
  100f34:	c3                   	ret    

00100f35 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100f35:	55                   	push   %ebp
  100f36:	89 e5                	mov    %esp,%ebp
  100f38:	53                   	push   %ebx
  100f39:	83 ec 04             	sub    $0x4,%esp
  100f3c:	e8 3b f3 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100f41:	05 0f da 00 00       	add    $0xda0f,%eax
    print_stackframe();
  100f46:	89 c3                	mov    %eax,%ebx
  100f48:	e8 5d fc ff ff       	call   100baa <print_stackframe>
    return 0;
  100f4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100f52:	83 c4 04             	add    $0x4,%esp
  100f55:	5b                   	pop    %ebx
  100f56:	5d                   	pop    %ebp
  100f57:	c3                   	ret    

00100f58 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100f58:	55                   	push   %ebp
  100f59:	89 e5                	mov    %esp,%ebp
  100f5b:	53                   	push   %ebx
  100f5c:	83 ec 14             	sub    $0x14,%esp
  100f5f:	e8 1c f3 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  100f64:	81 c3 ec d9 00 00    	add    $0xd9ec,%ebx
  100f6a:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100f70:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f74:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f78:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f7c:	ee                   	out    %al,(%dx)
  100f7d:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100f83:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100f87:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f8b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f8f:	ee                   	out    %al,(%dx)
  100f90:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100f96:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100f9a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f9e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100fa2:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100fa3:	c7 c0 a8 f9 10 00    	mov    $0x10f9a8,%eax
  100fa9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("++ setup timer interrupts\n");
  100faf:	83 ec 0c             	sub    $0xc,%esp
  100fb2:	8d 83 4e 53 ff ff    	lea    -0xacb2(%ebx),%eax
  100fb8:	50                   	push   %eax
  100fb9:	e8 35 f3 ff ff       	call   1002f3 <cprintf>
  100fbe:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
  100fc1:	83 ec 0c             	sub    $0xc,%esp
  100fc4:	6a 00                	push   $0x0
  100fc6:	e8 e7 09 00 00       	call   1019b2 <pic_enable>
  100fcb:	83 c4 10             	add    $0x10,%esp
}
  100fce:	90                   	nop
  100fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100fd2:	c9                   	leave  
  100fd3:	c3                   	ret    

00100fd4 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100fd4:	55                   	push   %ebp
  100fd5:	89 e5                	mov    %esp,%ebp
  100fd7:	83 ec 10             	sub    $0x10,%esp
  100fda:	e8 9d f2 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  100fdf:	05 71 d9 00 00       	add    $0xd971,%eax
  100fe4:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fea:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100fee:	89 c2                	mov    %eax,%edx
  100ff0:	ec                   	in     (%dx),%al
  100ff1:	88 45 f1             	mov    %al,-0xf(%ebp)
  100ff4:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100ffa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100ffe:	89 c2                	mov    %eax,%edx
  101000:	ec                   	in     (%dx),%al
  101001:	88 45 f5             	mov    %al,-0xb(%ebp)
  101004:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  10100a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10100e:	89 c2                	mov    %eax,%edx
  101010:	ec                   	in     (%dx),%al
  101011:	88 45 f9             	mov    %al,-0x7(%ebp)
  101014:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  10101a:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  10101e:	89 c2                	mov    %eax,%edx
  101020:	ec                   	in     (%dx),%al
  101021:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  101024:	90                   	nop
  101025:	c9                   	leave  
  101026:	c3                   	ret    

00101027 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  101027:	55                   	push   %ebp
  101028:	89 e5                	mov    %esp,%ebp
  10102a:	83 ec 20             	sub    $0x20,%esp
  10102d:	e8 17 09 00 00       	call   101949 <__x86.get_pc_thunk.cx>
  101032:	81 c1 1e d9 00 00    	add    $0xd91e,%ecx
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  101038:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  10103f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101042:	0f b7 00             	movzwl (%eax),%eax
  101045:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  101049:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10104c:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  101051:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101054:	0f b7 00             	movzwl (%eax),%eax
  101057:	66 3d 5a a5          	cmp    $0xa55a,%ax
  10105b:	74 12                	je     10106f <cga_init+0x48>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  10105d:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  101064:	66 c7 81 b6 05 00 00 	movw   $0x3b4,0x5b6(%ecx)
  10106b:	b4 03 
  10106d:	eb 13                	jmp    101082 <cga_init+0x5b>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  10106f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101072:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101076:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  101079:	66 c7 81 b6 05 00 00 	movw   $0x3d4,0x5b6(%ecx)
  101080:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  101082:	0f b7 81 b6 05 00 00 	movzwl 0x5b6(%ecx),%eax
  101089:	0f b7 c0             	movzwl %ax,%eax
  10108c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101090:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101094:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101098:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10109c:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  10109d:	0f b7 81 b6 05 00 00 	movzwl 0x5b6(%ecx),%eax
  1010a4:	83 c0 01             	add    $0x1,%eax
  1010a7:	0f b7 c0             	movzwl %ax,%eax
  1010aa:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1010ae:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  1010b2:	89 c2                	mov    %eax,%edx
  1010b4:	ec                   	in     (%dx),%al
  1010b5:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  1010b8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1010bc:	0f b6 c0             	movzbl %al,%eax
  1010bf:	c1 e0 08             	shl    $0x8,%eax
  1010c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  1010c5:	0f b7 81 b6 05 00 00 	movzwl 0x5b6(%ecx),%eax
  1010cc:	0f b7 c0             	movzwl %ax,%eax
  1010cf:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1010d3:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010d7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010db:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010df:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  1010e0:	0f b7 81 b6 05 00 00 	movzwl 0x5b6(%ecx),%eax
  1010e7:	83 c0 01             	add    $0x1,%eax
  1010ea:	0f b7 c0             	movzwl %ax,%eax
  1010ed:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1010f1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1010f5:	89 c2                	mov    %eax,%edx
  1010f7:	ec                   	in     (%dx),%al
  1010f8:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  1010fb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010ff:	0f b6 c0             	movzbl %al,%eax
  101102:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  101105:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101108:	89 81 b0 05 00 00    	mov    %eax,0x5b0(%ecx)
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  10110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101111:	66 89 81 b4 05 00 00 	mov    %ax,0x5b4(%ecx)
}
  101118:	90                   	nop
  101119:	c9                   	leave  
  10111a:	c3                   	ret    

0010111b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  10111b:	55                   	push   %ebp
  10111c:	89 e5                	mov    %esp,%ebp
  10111e:	53                   	push   %ebx
  10111f:	83 ec 34             	sub    $0x34,%esp
  101122:	e8 22 08 00 00       	call   101949 <__x86.get_pc_thunk.cx>
  101127:	81 c1 29 d8 00 00    	add    $0xd829,%ecx
  10112d:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  101133:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101137:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10113b:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10113f:	ee                   	out    %al,(%dx)
  101140:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  101146:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  10114a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10114e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101152:	ee                   	out    %al,(%dx)
  101153:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  101159:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  10115d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101161:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101165:	ee                   	out    %al,(%dx)
  101166:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  10116c:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  101170:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101174:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101178:	ee                   	out    %al,(%dx)
  101179:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  10117f:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  101183:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101187:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10118b:	ee                   	out    %al,(%dx)
  10118c:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  101192:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  101196:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10119a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10119e:	ee                   	out    %al,(%dx)
  10119f:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  1011a5:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  1011a9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1011ad:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1011b1:	ee                   	out    %al,(%dx)
  1011b2:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1011b8:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  1011bc:	89 c2                	mov    %eax,%edx
  1011be:	ec                   	in     (%dx),%al
  1011bf:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  1011c2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  1011c6:	3c ff                	cmp    $0xff,%al
  1011c8:	0f 95 c0             	setne  %al
  1011cb:	0f b6 c0             	movzbl %al,%eax
  1011ce:	89 81 b8 05 00 00    	mov    %eax,0x5b8(%ecx)
  1011d4:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1011da:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1011de:	89 c2                	mov    %eax,%edx
  1011e0:	ec                   	in     (%dx),%al
  1011e1:	88 45 f1             	mov    %al,-0xf(%ebp)
  1011e4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1011ea:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1011ee:	89 c2                	mov    %eax,%edx
  1011f0:	ec                   	in     (%dx),%al
  1011f1:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  1011f4:	8b 81 b8 05 00 00    	mov    0x5b8(%ecx),%eax
  1011fa:	85 c0                	test   %eax,%eax
  1011fc:	74 0f                	je     10120d <serial_init+0xf2>
        pic_enable(IRQ_COM1);
  1011fe:	83 ec 0c             	sub    $0xc,%esp
  101201:	6a 04                	push   $0x4
  101203:	89 cb                	mov    %ecx,%ebx
  101205:	e8 a8 07 00 00       	call   1019b2 <pic_enable>
  10120a:	83 c4 10             	add    $0x10,%esp
    }
}
  10120d:	90                   	nop
  10120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101211:	c9                   	leave  
  101212:	c3                   	ret    

00101213 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101213:	55                   	push   %ebp
  101214:	89 e5                	mov    %esp,%ebp
  101216:	83 ec 20             	sub    $0x20,%esp
  101219:	e8 5e f0 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10121e:	05 32 d7 00 00       	add    $0xd732,%eax
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101223:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10122a:	eb 09                	jmp    101235 <lpt_putc_sub+0x22>
        delay();
  10122c:	e8 a3 fd ff ff       	call   100fd4 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101231:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101235:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10123b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10123f:	89 c2                	mov    %eax,%edx
  101241:	ec                   	in     (%dx),%al
  101242:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101245:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101249:	84 c0                	test   %al,%al
  10124b:	78 09                	js     101256 <lpt_putc_sub+0x43>
  10124d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101254:	7e d6                	jle    10122c <lpt_putc_sub+0x19>
    }
    outb(LPTPORT + 0, c);
  101256:	8b 45 08             	mov    0x8(%ebp),%eax
  101259:	0f b6 c0             	movzbl %al,%eax
  10125c:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101262:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101265:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101269:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10126d:	ee                   	out    %al,(%dx)
  10126e:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101274:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101278:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10127c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101280:	ee                   	out    %al,(%dx)
  101281:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101287:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  10128b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10128f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101293:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101294:	90                   	nop
  101295:	c9                   	leave  
  101296:	c3                   	ret    

00101297 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101297:	55                   	push   %ebp
  101298:	89 e5                	mov    %esp,%ebp
  10129a:	e8 dd ef ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10129f:	05 b1 d6 00 00       	add    $0xd6b1,%eax
    if (c != '\b') {
  1012a4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012a8:	74 0d                	je     1012b7 <lpt_putc+0x20>
        lpt_putc_sub(c);
  1012aa:	ff 75 08             	pushl  0x8(%ebp)
  1012ad:	e8 61 ff ff ff       	call   101213 <lpt_putc_sub>
  1012b2:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1012b5:	eb 1e                	jmp    1012d5 <lpt_putc+0x3e>
        lpt_putc_sub('\b');
  1012b7:	6a 08                	push   $0x8
  1012b9:	e8 55 ff ff ff       	call   101213 <lpt_putc_sub>
  1012be:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
  1012c1:	6a 20                	push   $0x20
  1012c3:	e8 4b ff ff ff       	call   101213 <lpt_putc_sub>
  1012c8:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
  1012cb:	6a 08                	push   $0x8
  1012cd:	e8 41 ff ff ff       	call   101213 <lpt_putc_sub>
  1012d2:	83 c4 04             	add    $0x4,%esp
}
  1012d5:	90                   	nop
  1012d6:	c9                   	leave  
  1012d7:	c3                   	ret    

001012d8 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1012d8:	55                   	push   %ebp
  1012d9:	89 e5                	mov    %esp,%ebp
  1012db:	56                   	push   %esi
  1012dc:	53                   	push   %ebx
  1012dd:	83 ec 20             	sub    $0x20,%esp
  1012e0:	e8 9b ef ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  1012e5:	81 c3 6b d6 00 00    	add    $0xd66b,%ebx
    // set black on white
    if (!(c & ~0xFF)) {
  1012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1012ee:	b0 00                	mov    $0x0,%al
  1012f0:	85 c0                	test   %eax,%eax
  1012f2:	75 07                	jne    1012fb <cga_putc+0x23>
        c |= 0x0700;
  1012f4:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1012fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1012fe:	0f b6 c0             	movzbl %al,%eax
  101301:	83 f8 0a             	cmp    $0xa,%eax
  101304:	74 54                	je     10135a <cga_putc+0x82>
  101306:	83 f8 0d             	cmp    $0xd,%eax
  101309:	74 60                	je     10136b <cga_putc+0x93>
  10130b:	83 f8 08             	cmp    $0x8,%eax
  10130e:	0f 85 92 00 00 00    	jne    1013a6 <cga_putc+0xce>
    case '\b':
        if (crt_pos > 0) {
  101314:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  10131b:	66 85 c0             	test   %ax,%ax
  10131e:	0f 84 a8 00 00 00    	je     1013cc <cga_putc+0xf4>
            crt_pos --;
  101324:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  10132b:	83 e8 01             	sub    $0x1,%eax
  10132e:	66 89 83 b4 05 00 00 	mov    %ax,0x5b4(%ebx)
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101335:	8b 45 08             	mov    0x8(%ebp),%eax
  101338:	b0 00                	mov    $0x0,%al
  10133a:	83 c8 20             	or     $0x20,%eax
  10133d:	89 c1                	mov    %eax,%ecx
  10133f:	8b 83 b0 05 00 00    	mov    0x5b0(%ebx),%eax
  101345:	0f b7 93 b4 05 00 00 	movzwl 0x5b4(%ebx),%edx
  10134c:	0f b7 d2             	movzwl %dx,%edx
  10134f:	01 d2                	add    %edx,%edx
  101351:	01 d0                	add    %edx,%eax
  101353:	89 ca                	mov    %ecx,%edx
  101355:	66 89 10             	mov    %dx,(%eax)
        }
        break;
  101358:	eb 72                	jmp    1013cc <cga_putc+0xf4>
    case '\n':
        crt_pos += CRT_COLS;
  10135a:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  101361:	83 c0 50             	add    $0x50,%eax
  101364:	66 89 83 b4 05 00 00 	mov    %ax,0x5b4(%ebx)
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10136b:	0f b7 b3 b4 05 00 00 	movzwl 0x5b4(%ebx),%esi
  101372:	0f b7 8b b4 05 00 00 	movzwl 0x5b4(%ebx),%ecx
  101379:	0f b7 c1             	movzwl %cx,%eax
  10137c:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101382:	c1 e8 10             	shr    $0x10,%eax
  101385:	89 c2                	mov    %eax,%edx
  101387:	66 c1 ea 06          	shr    $0x6,%dx
  10138b:	89 d0                	mov    %edx,%eax
  10138d:	c1 e0 02             	shl    $0x2,%eax
  101390:	01 d0                	add    %edx,%eax
  101392:	c1 e0 04             	shl    $0x4,%eax
  101395:	29 c1                	sub    %eax,%ecx
  101397:	89 ca                	mov    %ecx,%edx
  101399:	89 f0                	mov    %esi,%eax
  10139b:	29 d0                	sub    %edx,%eax
  10139d:	66 89 83 b4 05 00 00 	mov    %ax,0x5b4(%ebx)
        break;
  1013a4:	eb 27                	jmp    1013cd <cga_putc+0xf5>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1013a6:	8b 8b b0 05 00 00    	mov    0x5b0(%ebx),%ecx
  1013ac:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  1013b3:	8d 50 01             	lea    0x1(%eax),%edx
  1013b6:	66 89 93 b4 05 00 00 	mov    %dx,0x5b4(%ebx)
  1013bd:	0f b7 c0             	movzwl %ax,%eax
  1013c0:	01 c0                	add    %eax,%eax
  1013c2:	01 c8                	add    %ecx,%eax
  1013c4:	8b 55 08             	mov    0x8(%ebp),%edx
  1013c7:	66 89 10             	mov    %dx,(%eax)
        break;
  1013ca:	eb 01                	jmp    1013cd <cga_putc+0xf5>
        break;
  1013cc:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1013cd:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  1013d4:	66 3d cf 07          	cmp    $0x7cf,%ax
  1013d8:	76 5d                	jbe    101437 <cga_putc+0x15f>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1013da:	8b 83 b0 05 00 00    	mov    0x5b0(%ebx),%eax
  1013e0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1013e6:	8b 83 b0 05 00 00    	mov    0x5b0(%ebx),%eax
  1013ec:	83 ec 04             	sub    $0x4,%esp
  1013ef:	68 00 0f 00 00       	push   $0xf00
  1013f4:	52                   	push   %edx
  1013f5:	50                   	push   %eax
  1013f6:	e8 bf 1d 00 00       	call   1031ba <memmove>
  1013fb:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1013fe:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101405:	eb 16                	jmp    10141d <cga_putc+0x145>
            crt_buf[i] = 0x0700 | ' ';
  101407:	8b 83 b0 05 00 00    	mov    0x5b0(%ebx),%eax
  10140d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101410:	01 d2                	add    %edx,%edx
  101412:	01 d0                	add    %edx,%eax
  101414:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101419:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10141d:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101424:	7e e1                	jle    101407 <cga_putc+0x12f>
        }
        crt_pos -= CRT_COLS;
  101426:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  10142d:	83 e8 50             	sub    $0x50,%eax
  101430:	66 89 83 b4 05 00 00 	mov    %ax,0x5b4(%ebx)
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101437:	0f b7 83 b6 05 00 00 	movzwl 0x5b6(%ebx),%eax
  10143e:	0f b7 c0             	movzwl %ax,%eax
  101441:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101445:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101449:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10144d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101451:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101452:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  101459:	66 c1 e8 08          	shr    $0x8,%ax
  10145d:	0f b6 c0             	movzbl %al,%eax
  101460:	0f b7 93 b6 05 00 00 	movzwl 0x5b6(%ebx),%edx
  101467:	83 c2 01             	add    $0x1,%edx
  10146a:	0f b7 d2             	movzwl %dx,%edx
  10146d:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101471:	88 45 e9             	mov    %al,-0x17(%ebp)
  101474:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101478:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10147c:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10147d:	0f b7 83 b6 05 00 00 	movzwl 0x5b6(%ebx),%eax
  101484:	0f b7 c0             	movzwl %ax,%eax
  101487:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10148b:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  10148f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101493:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101497:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  101498:	0f b7 83 b4 05 00 00 	movzwl 0x5b4(%ebx),%eax
  10149f:	0f b6 c0             	movzbl %al,%eax
  1014a2:	0f b7 93 b6 05 00 00 	movzwl 0x5b6(%ebx),%edx
  1014a9:	83 c2 01             	add    $0x1,%edx
  1014ac:	0f b7 d2             	movzwl %dx,%edx
  1014af:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1014b3:	88 45 f1             	mov    %al,-0xf(%ebp)
  1014b6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1014ba:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1014be:	ee                   	out    %al,(%dx)
}
  1014bf:	90                   	nop
  1014c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  1014c3:	5b                   	pop    %ebx
  1014c4:	5e                   	pop    %esi
  1014c5:	5d                   	pop    %ebp
  1014c6:	c3                   	ret    

001014c7 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1014c7:	55                   	push   %ebp
  1014c8:	89 e5                	mov    %esp,%ebp
  1014ca:	83 ec 10             	sub    $0x10,%esp
  1014cd:	e8 aa ed ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1014d2:	05 7e d4 00 00       	add    $0xd47e,%eax
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1014d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1014de:	eb 09                	jmp    1014e9 <serial_putc_sub+0x22>
        delay();
  1014e0:	e8 ef fa ff ff       	call   100fd4 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1014e5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1014e9:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1014ef:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1014f3:	89 c2                	mov    %eax,%edx
  1014f5:	ec                   	in     (%dx),%al
  1014f6:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1014f9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1014fd:	0f b6 c0             	movzbl %al,%eax
  101500:	83 e0 20             	and    $0x20,%eax
  101503:	85 c0                	test   %eax,%eax
  101505:	75 09                	jne    101510 <serial_putc_sub+0x49>
  101507:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10150e:	7e d0                	jle    1014e0 <serial_putc_sub+0x19>
    }
    outb(COM1 + COM_TX, c);
  101510:	8b 45 08             	mov    0x8(%ebp),%eax
  101513:	0f b6 c0             	movzbl %al,%eax
  101516:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10151c:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10151f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101523:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101527:	ee                   	out    %al,(%dx)
}
  101528:	90                   	nop
  101529:	c9                   	leave  
  10152a:	c3                   	ret    

0010152b <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10152b:	55                   	push   %ebp
  10152c:	89 e5                	mov    %esp,%ebp
  10152e:	e8 49 ed ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101533:	05 1d d4 00 00       	add    $0xd41d,%eax
    if (c != '\b') {
  101538:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10153c:	74 0d                	je     10154b <serial_putc+0x20>
        serial_putc_sub(c);
  10153e:	ff 75 08             	pushl  0x8(%ebp)
  101541:	e8 81 ff ff ff       	call   1014c7 <serial_putc_sub>
  101546:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101549:	eb 1e                	jmp    101569 <serial_putc+0x3e>
        serial_putc_sub('\b');
  10154b:	6a 08                	push   $0x8
  10154d:	e8 75 ff ff ff       	call   1014c7 <serial_putc_sub>
  101552:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
  101555:	6a 20                	push   $0x20
  101557:	e8 6b ff ff ff       	call   1014c7 <serial_putc_sub>
  10155c:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
  10155f:	6a 08                	push   $0x8
  101561:	e8 61 ff ff ff       	call   1014c7 <serial_putc_sub>
  101566:	83 c4 04             	add    $0x4,%esp
}
  101569:	90                   	nop
  10156a:	c9                   	leave  
  10156b:	c3                   	ret    

0010156c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10156c:	55                   	push   %ebp
  10156d:	89 e5                	mov    %esp,%ebp
  10156f:	53                   	push   %ebx
  101570:	83 ec 14             	sub    $0x14,%esp
  101573:	e8 08 ed ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  101578:	81 c3 d8 d3 00 00    	add    $0xd3d8,%ebx
    int c;
    while ((c = (*proc)()) != -1) {
  10157e:	eb 36                	jmp    1015b6 <cons_intr+0x4a>
        if (c != 0) {
  101580:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101584:	74 30                	je     1015b6 <cons_intr+0x4a>
            cons.buf[cons.wpos ++] = c;
  101586:	8b 83 d4 07 00 00    	mov    0x7d4(%ebx),%eax
  10158c:	8d 50 01             	lea    0x1(%eax),%edx
  10158f:	89 93 d4 07 00 00    	mov    %edx,0x7d4(%ebx)
  101595:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101598:	88 94 03 d0 05 00 00 	mov    %dl,0x5d0(%ebx,%eax,1)
            if (cons.wpos == CONSBUFSIZE) {
  10159f:	8b 83 d4 07 00 00    	mov    0x7d4(%ebx),%eax
  1015a5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1015aa:	75 0a                	jne    1015b6 <cons_intr+0x4a>
                cons.wpos = 0;
  1015ac:	c7 83 d4 07 00 00 00 	movl   $0x0,0x7d4(%ebx)
  1015b3:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1015b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1015b9:	ff d0                	call   *%eax
  1015bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1015be:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1015c2:	75 bc                	jne    101580 <cons_intr+0x14>
            }
        }
    }
}
  1015c4:	90                   	nop
  1015c5:	83 c4 14             	add    $0x14,%esp
  1015c8:	5b                   	pop    %ebx
  1015c9:	5d                   	pop    %ebp
  1015ca:	c3                   	ret    

001015cb <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1015cb:	55                   	push   %ebp
  1015cc:	89 e5                	mov    %esp,%ebp
  1015ce:	83 ec 10             	sub    $0x10,%esp
  1015d1:	e8 a6 ec ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1015d6:	05 7a d3 00 00       	add    $0xd37a,%eax
  1015db:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1015e1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1015e5:	89 c2                	mov    %eax,%edx
  1015e7:	ec                   	in     (%dx),%al
  1015e8:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1015eb:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1015ef:	0f b6 c0             	movzbl %al,%eax
  1015f2:	83 e0 01             	and    $0x1,%eax
  1015f5:	85 c0                	test   %eax,%eax
  1015f7:	75 07                	jne    101600 <serial_proc_data+0x35>
        return -1;
  1015f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1015fe:	eb 2a                	jmp    10162a <serial_proc_data+0x5f>
  101600:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101606:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10160a:	89 c2                	mov    %eax,%edx
  10160c:	ec                   	in     (%dx),%al
  10160d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101610:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101614:	0f b6 c0             	movzbl %al,%eax
  101617:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10161a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10161e:	75 07                	jne    101627 <serial_proc_data+0x5c>
        c = '\b';
  101620:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101627:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10162a:	c9                   	leave  
  10162b:	c3                   	ret    

0010162c <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10162c:	55                   	push   %ebp
  10162d:	89 e5                	mov    %esp,%ebp
  10162f:	83 ec 08             	sub    $0x8,%esp
  101632:	e8 45 ec ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101637:	05 19 d3 00 00       	add    $0xd319,%eax
    if (serial_exists) {
  10163c:	8b 90 b8 05 00 00    	mov    0x5b8(%eax),%edx
  101642:	85 d2                	test   %edx,%edx
  101644:	74 12                	je     101658 <serial_intr+0x2c>
        cons_intr(serial_proc_data);
  101646:	83 ec 0c             	sub    $0xc,%esp
  101649:	8d 80 7b 2c ff ff    	lea    -0xd385(%eax),%eax
  10164f:	50                   	push   %eax
  101650:	e8 17 ff ff ff       	call   10156c <cons_intr>
  101655:	83 c4 10             	add    $0x10,%esp
    }
}
  101658:	90                   	nop
  101659:	c9                   	leave  
  10165a:	c3                   	ret    

0010165b <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10165b:	55                   	push   %ebp
  10165c:	89 e5                	mov    %esp,%ebp
  10165e:	53                   	push   %ebx
  10165f:	83 ec 24             	sub    $0x24,%esp
  101662:	e8 e2 02 00 00       	call   101949 <__x86.get_pc_thunk.cx>
  101667:	81 c1 e9 d2 00 00    	add    $0xd2e9,%ecx
  10166d:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101673:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101677:	89 c2                	mov    %eax,%edx
  101679:	ec                   	in     (%dx),%al
  10167a:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10167d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101681:	0f b6 c0             	movzbl %al,%eax
  101684:	83 e0 01             	and    $0x1,%eax
  101687:	85 c0                	test   %eax,%eax
  101689:	75 0a                	jne    101695 <kbd_proc_data+0x3a>
        return -1;
  10168b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101690:	e9 73 01 00 00       	jmp    101808 <kbd_proc_data+0x1ad>
  101695:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10169b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10169f:	89 c2                	mov    %eax,%edx
  1016a1:	ec                   	in     (%dx),%al
  1016a2:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1016a5:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1016a9:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1016ac:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1016b0:	75 19                	jne    1016cb <kbd_proc_data+0x70>
        // E0 escape character
        shift |= E0ESC;
  1016b2:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  1016b8:	83 c8 40             	or     $0x40,%eax
  1016bb:	89 81 d8 07 00 00    	mov    %eax,0x7d8(%ecx)
        return 0;
  1016c1:	b8 00 00 00 00       	mov    $0x0,%eax
  1016c6:	e9 3d 01 00 00       	jmp    101808 <kbd_proc_data+0x1ad>
    } else if (data & 0x80) {
  1016cb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1016cf:	84 c0                	test   %al,%al
  1016d1:	79 4b                	jns    10171e <kbd_proc_data+0xc3>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1016d3:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  1016d9:	83 e0 40             	and    $0x40,%eax
  1016dc:	85 c0                	test   %eax,%eax
  1016de:	75 09                	jne    1016e9 <kbd_proc_data+0x8e>
  1016e0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1016e4:	83 e0 7f             	and    $0x7f,%eax
  1016e7:	eb 04                	jmp    1016ed <kbd_proc_data+0x92>
  1016e9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1016ed:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1016f0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1016f4:	0f b6 84 01 b0 f6 ff 	movzbl -0x950(%ecx,%eax,1),%eax
  1016fb:	ff 
  1016fc:	83 c8 40             	or     $0x40,%eax
  1016ff:	0f b6 c0             	movzbl %al,%eax
  101702:	f7 d0                	not    %eax
  101704:	89 c2                	mov    %eax,%edx
  101706:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  10170c:	21 d0                	and    %edx,%eax
  10170e:	89 81 d8 07 00 00    	mov    %eax,0x7d8(%ecx)
        return 0;
  101714:	b8 00 00 00 00       	mov    $0x0,%eax
  101719:	e9 ea 00 00 00       	jmp    101808 <kbd_proc_data+0x1ad>
    } else if (shift & E0ESC) {
  10171e:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  101724:	83 e0 40             	and    $0x40,%eax
  101727:	85 c0                	test   %eax,%eax
  101729:	74 13                	je     10173e <kbd_proc_data+0xe3>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10172b:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10172f:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  101735:	83 e0 bf             	and    $0xffffffbf,%eax
  101738:	89 81 d8 07 00 00    	mov    %eax,0x7d8(%ecx)
    }

    shift |= shiftcode[data];
  10173e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101742:	0f b6 84 01 b0 f6 ff 	movzbl -0x950(%ecx,%eax,1),%eax
  101749:	ff 
  10174a:	0f b6 d0             	movzbl %al,%edx
  10174d:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  101753:	09 d0                	or     %edx,%eax
  101755:	89 81 d8 07 00 00    	mov    %eax,0x7d8(%ecx)
    shift ^= togglecode[data];
  10175b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10175f:	0f b6 84 01 b0 f7 ff 	movzbl -0x850(%ecx,%eax,1),%eax
  101766:	ff 
  101767:	0f b6 d0             	movzbl %al,%edx
  10176a:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  101770:	31 d0                	xor    %edx,%eax
  101772:	89 81 d8 07 00 00    	mov    %eax,0x7d8(%ecx)

    c = charcode[shift & (CTL | SHIFT)][data];
  101778:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  10177e:	83 e0 03             	and    $0x3,%eax
  101781:	8b 94 81 34 00 00 00 	mov    0x34(%ecx,%eax,4),%edx
  101788:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10178c:	01 d0                	add    %edx,%eax
  10178e:	0f b6 00             	movzbl (%eax),%eax
  101791:	0f b6 c0             	movzbl %al,%eax
  101794:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101797:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  10179d:	83 e0 08             	and    $0x8,%eax
  1017a0:	85 c0                	test   %eax,%eax
  1017a2:	74 22                	je     1017c6 <kbd_proc_data+0x16b>
        if ('a' <= c && c <= 'z')
  1017a4:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1017a8:	7e 0c                	jle    1017b6 <kbd_proc_data+0x15b>
  1017aa:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1017ae:	7f 06                	jg     1017b6 <kbd_proc_data+0x15b>
            c += 'A' - 'a';
  1017b0:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1017b4:	eb 10                	jmp    1017c6 <kbd_proc_data+0x16b>
        else if ('A' <= c && c <= 'Z')
  1017b6:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1017ba:	7e 0a                	jle    1017c6 <kbd_proc_data+0x16b>
  1017bc:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1017c0:	7f 04                	jg     1017c6 <kbd_proc_data+0x16b>
            c += 'a' - 'A';
  1017c2:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1017c6:	8b 81 d8 07 00 00    	mov    0x7d8(%ecx),%eax
  1017cc:	f7 d0                	not    %eax
  1017ce:	83 e0 06             	and    $0x6,%eax
  1017d1:	85 c0                	test   %eax,%eax
  1017d3:	75 30                	jne    101805 <kbd_proc_data+0x1aa>
  1017d5:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1017dc:	75 27                	jne    101805 <kbd_proc_data+0x1aa>
        cprintf("Rebooting!\n");
  1017de:	83 ec 0c             	sub    $0xc,%esp
  1017e1:	8d 81 69 53 ff ff    	lea    -0xac97(%ecx),%eax
  1017e7:	50                   	push   %eax
  1017e8:	89 cb                	mov    %ecx,%ebx
  1017ea:	e8 04 eb ff ff       	call   1002f3 <cprintf>
  1017ef:	83 c4 10             	add    $0x10,%esp
  1017f2:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1017f8:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017fc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101800:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101804:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101805:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10180b:	c9                   	leave  
  10180c:	c3                   	ret    

0010180d <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10180d:	55                   	push   %ebp
  10180e:	89 e5                	mov    %esp,%ebp
  101810:	83 ec 08             	sub    $0x8,%esp
  101813:	e8 64 ea ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101818:	05 38 d1 00 00       	add    $0xd138,%eax
    cons_intr(kbd_proc_data);
  10181d:	83 ec 0c             	sub    $0xc,%esp
  101820:	8d 80 0b 2d ff ff    	lea    -0xd2f5(%eax),%eax
  101826:	50                   	push   %eax
  101827:	e8 40 fd ff ff       	call   10156c <cons_intr>
  10182c:	83 c4 10             	add    $0x10,%esp
}
  10182f:	90                   	nop
  101830:	c9                   	leave  
  101831:	c3                   	ret    

00101832 <kbd_init>:

static void
kbd_init(void) {
  101832:	55                   	push   %ebp
  101833:	89 e5                	mov    %esp,%ebp
  101835:	53                   	push   %ebx
  101836:	83 ec 04             	sub    $0x4,%esp
  101839:	e8 42 ea ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  10183e:	81 c3 12 d1 00 00    	add    $0xd112,%ebx
    // drain the kbd buffer
    kbd_intr();
  101844:	e8 c4 ff ff ff       	call   10180d <kbd_intr>
    pic_enable(IRQ_KBD);
  101849:	83 ec 0c             	sub    $0xc,%esp
  10184c:	6a 01                	push   $0x1
  10184e:	e8 5f 01 00 00       	call   1019b2 <pic_enable>
  101853:	83 c4 10             	add    $0x10,%esp
}
  101856:	90                   	nop
  101857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10185a:	c9                   	leave  
  10185b:	c3                   	ret    

0010185c <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10185c:	55                   	push   %ebp
  10185d:	89 e5                	mov    %esp,%ebp
  10185f:	53                   	push   %ebx
  101860:	83 ec 04             	sub    $0x4,%esp
  101863:	e8 18 ea ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  101868:	81 c3 e8 d0 00 00    	add    $0xd0e8,%ebx
    cga_init();
  10186e:	e8 b4 f7 ff ff       	call   101027 <cga_init>
    serial_init();
  101873:	e8 a3 f8 ff ff       	call   10111b <serial_init>
    kbd_init();
  101878:	e8 b5 ff ff ff       	call   101832 <kbd_init>
    if (!serial_exists) {
  10187d:	8b 83 b8 05 00 00    	mov    0x5b8(%ebx),%eax
  101883:	85 c0                	test   %eax,%eax
  101885:	75 12                	jne    101899 <cons_init+0x3d>
        cprintf("serial port does not exist!!\n");
  101887:	83 ec 0c             	sub    $0xc,%esp
  10188a:	8d 83 75 53 ff ff    	lea    -0xac8b(%ebx),%eax
  101890:	50                   	push   %eax
  101891:	e8 5d ea ff ff       	call   1002f3 <cprintf>
  101896:	83 c4 10             	add    $0x10,%esp
    }
}
  101899:	90                   	nop
  10189a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10189d:	c9                   	leave  
  10189e:	c3                   	ret    

0010189f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10189f:	55                   	push   %ebp
  1018a0:	89 e5                	mov    %esp,%ebp
  1018a2:	83 ec 08             	sub    $0x8,%esp
  1018a5:	e8 d2 e9 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1018aa:	05 a6 d0 00 00       	add    $0xd0a6,%eax
    lpt_putc(c);
  1018af:	ff 75 08             	pushl  0x8(%ebp)
  1018b2:	e8 e0 f9 ff ff       	call   101297 <lpt_putc>
  1018b7:	83 c4 04             	add    $0x4,%esp
    cga_putc(c);
  1018ba:	83 ec 0c             	sub    $0xc,%esp
  1018bd:	ff 75 08             	pushl  0x8(%ebp)
  1018c0:	e8 13 fa ff ff       	call   1012d8 <cga_putc>
  1018c5:	83 c4 10             	add    $0x10,%esp
    serial_putc(c);
  1018c8:	83 ec 0c             	sub    $0xc,%esp
  1018cb:	ff 75 08             	pushl  0x8(%ebp)
  1018ce:	e8 58 fc ff ff       	call   10152b <serial_putc>
  1018d3:	83 c4 10             	add    $0x10,%esp
}
  1018d6:	90                   	nop
  1018d7:	c9                   	leave  
  1018d8:	c3                   	ret    

001018d9 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1018d9:	55                   	push   %ebp
  1018da:	89 e5                	mov    %esp,%ebp
  1018dc:	53                   	push   %ebx
  1018dd:	83 ec 14             	sub    $0x14,%esp
  1018e0:	e8 9b e9 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  1018e5:	81 c3 6b d0 00 00    	add    $0xd06b,%ebx
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1018eb:	e8 3c fd ff ff       	call   10162c <serial_intr>
    kbd_intr();
  1018f0:	e8 18 ff ff ff       	call   10180d <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1018f5:	8b 93 d0 07 00 00    	mov    0x7d0(%ebx),%edx
  1018fb:	8b 83 d4 07 00 00    	mov    0x7d4(%ebx),%eax
  101901:	39 c2                	cmp    %eax,%edx
  101903:	74 39                	je     10193e <cons_getc+0x65>
        c = cons.buf[cons.rpos ++];
  101905:	8b 83 d0 07 00 00    	mov    0x7d0(%ebx),%eax
  10190b:	8d 50 01             	lea    0x1(%eax),%edx
  10190e:	89 93 d0 07 00 00    	mov    %edx,0x7d0(%ebx)
  101914:	0f b6 84 03 d0 05 00 	movzbl 0x5d0(%ebx,%eax,1),%eax
  10191b:	00 
  10191c:	0f b6 c0             	movzbl %al,%eax
  10191f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101922:	8b 83 d0 07 00 00    	mov    0x7d0(%ebx),%eax
  101928:	3d 00 02 00 00       	cmp    $0x200,%eax
  10192d:	75 0a                	jne    101939 <cons_getc+0x60>
            cons.rpos = 0;
  10192f:	c7 83 d0 07 00 00 00 	movl   $0x0,0x7d0(%ebx)
  101936:	00 00 00 
        }
        return c;
  101939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10193c:	eb 05                	jmp    101943 <cons_getc+0x6a>
    }
    return 0;
  10193e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101943:	83 c4 14             	add    $0x14,%esp
  101946:	5b                   	pop    %ebx
  101947:	5d                   	pop    %ebp
  101948:	c3                   	ret    

00101949 <__x86.get_pc_thunk.cx>:
  101949:	8b 0c 24             	mov    (%esp),%ecx
  10194c:	c3                   	ret    

0010194d <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10194d:	55                   	push   %ebp
  10194e:	89 e5                	mov    %esp,%ebp
  101950:	83 ec 14             	sub    $0x14,%esp
  101953:	e8 24 e9 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101958:	05 f8 cf 00 00       	add    $0xcff8,%eax
  10195d:	8b 55 08             	mov    0x8(%ebp),%edx
  101960:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
    irq_mask = mask;
  101964:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  101968:	66 89 90 b0 fb ff ff 	mov    %dx,-0x450(%eax)
    if (did_init) {
  10196f:	8b 80 dc 07 00 00    	mov    0x7dc(%eax),%eax
  101975:	85 c0                	test   %eax,%eax
  101977:	74 36                	je     1019af <pic_setmask+0x62>
        outb(IO_PIC1 + 1, mask);
  101979:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10197d:	0f b6 c0             	movzbl %al,%eax
  101980:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101986:	88 45 f9             	mov    %al,-0x7(%ebp)
  101989:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10198d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101991:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101992:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101996:	66 c1 e8 08          	shr    $0x8,%ax
  10199a:	0f b6 c0             	movzbl %al,%eax
  10199d:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  1019a3:	88 45 fd             	mov    %al,-0x3(%ebp)
  1019a6:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1019aa:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1019ae:	ee                   	out    %al,(%dx)
    }
}
  1019af:	90                   	nop
  1019b0:	c9                   	leave  
  1019b1:	c3                   	ret    

001019b2 <pic_enable>:

void
pic_enable(unsigned int irq) {
  1019b2:	55                   	push   %ebp
  1019b3:	89 e5                	mov    %esp,%ebp
  1019b5:	53                   	push   %ebx
  1019b6:	e8 c1 e8 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1019bb:	05 95 cf 00 00       	add    $0xcf95,%eax
    pic_setmask(irq_mask & ~(1 << irq));
  1019c0:	8b 55 08             	mov    0x8(%ebp),%edx
  1019c3:	bb 01 00 00 00       	mov    $0x1,%ebx
  1019c8:	89 d1                	mov    %edx,%ecx
  1019ca:	d3 e3                	shl    %cl,%ebx
  1019cc:	89 da                	mov    %ebx,%edx
  1019ce:	f7 d2                	not    %edx
  1019d0:	0f b7 80 b0 fb ff ff 	movzwl -0x450(%eax),%eax
  1019d7:	21 d0                	and    %edx,%eax
  1019d9:	0f b7 c0             	movzwl %ax,%eax
  1019dc:	50                   	push   %eax
  1019dd:	e8 6b ff ff ff       	call   10194d <pic_setmask>
  1019e2:	83 c4 04             	add    $0x4,%esp
}
  1019e5:	90                   	nop
  1019e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1019e9:	c9                   	leave  
  1019ea:	c3                   	ret    

001019eb <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1019eb:	55                   	push   %ebp
  1019ec:	89 e5                	mov    %esp,%ebp
  1019ee:	83 ec 40             	sub    $0x40,%esp
  1019f1:	e8 53 ff ff ff       	call   101949 <__x86.get_pc_thunk.cx>
  1019f6:	81 c1 5a cf 00 00    	add    $0xcf5a,%ecx
    did_init = 1;
  1019fc:	c7 81 dc 07 00 00 01 	movl   $0x1,0x7dc(%ecx)
  101a03:	00 00 00 
  101a06:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101a0c:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  101a10:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101a14:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101a18:	ee                   	out    %al,(%dx)
  101a19:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101a1f:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  101a23:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101a27:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101a2b:	ee                   	out    %al,(%dx)
  101a2c:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101a32:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  101a36:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101a3a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101a3e:	ee                   	out    %al,(%dx)
  101a3f:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101a45:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  101a49:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101a4d:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101a51:	ee                   	out    %al,(%dx)
  101a52:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101a58:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  101a5c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101a60:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101a64:	ee                   	out    %al,(%dx)
  101a65:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101a6b:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  101a6f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101a73:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101a77:	ee                   	out    %al,(%dx)
  101a78:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101a7e:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  101a82:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101a86:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101a8a:	ee                   	out    %al,(%dx)
  101a8b:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101a91:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  101a95:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101a99:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101a9d:	ee                   	out    %al,(%dx)
  101a9e:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101aa4:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  101aa8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101aac:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101ab0:	ee                   	out    %al,(%dx)
  101ab1:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101ab7:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101abb:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101abf:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101ac3:	ee                   	out    %al,(%dx)
  101ac4:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101aca:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  101ace:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101ad2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101ad6:	ee                   	out    %al,(%dx)
  101ad7:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101add:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  101ae1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101ae5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101ae9:	ee                   	out    %al,(%dx)
  101aea:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101af0:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  101af4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101af8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101afc:	ee                   	out    %al,(%dx)
  101afd:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  101b03:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  101b07:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101b0b:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101b0f:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101b10:	0f b7 81 b0 fb ff ff 	movzwl -0x450(%ecx),%eax
  101b17:	66 83 f8 ff          	cmp    $0xffff,%ax
  101b1b:	74 13                	je     101b30 <pic_init+0x145>
        pic_setmask(irq_mask);
  101b1d:	0f b7 81 b0 fb ff ff 	movzwl -0x450(%ecx),%eax
  101b24:	0f b7 c0             	movzwl %ax,%eax
  101b27:	50                   	push   %eax
  101b28:	e8 20 fe ff ff       	call   10194d <pic_setmask>
  101b2d:	83 c4 04             	add    $0x4,%esp
    }
}
  101b30:	90                   	nop
  101b31:	c9                   	leave  
  101b32:	c3                   	ret    

00101b33 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101b33:	55                   	push   %ebp
  101b34:	89 e5                	mov    %esp,%ebp
  101b36:	e8 41 e7 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101b3b:	05 15 ce 00 00       	add    $0xce15,%eax
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101b40:	fb                   	sti    
    sti();
}
  101b41:	90                   	nop
  101b42:	5d                   	pop    %ebp
  101b43:	c3                   	ret    

00101b44 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101b44:	55                   	push   %ebp
  101b45:	89 e5                	mov    %esp,%ebp
  101b47:	e8 30 e7 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101b4c:	05 04 ce 00 00       	add    $0xce04,%eax
}

static inline void
cli(void) {
    asm volatile ("cli");
  101b51:	fa                   	cli    
    cli();
}
  101b52:	90                   	nop
  101b53:	5d                   	pop    %ebp
  101b54:	c3                   	ret    

00101b55 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101b55:	55                   	push   %ebp
  101b56:	89 e5                	mov    %esp,%ebp
  101b58:	53                   	push   %ebx
  101b59:	83 ec 04             	sub    $0x4,%esp
  101b5c:	e8 1f e7 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  101b61:	81 c3 ef cd 00 00    	add    $0xcdef,%ebx
    cprintf("%d ticks\n",TICK_NUM);
  101b67:	83 ec 08             	sub    $0x8,%esp
  101b6a:	6a 64                	push   $0x64
  101b6c:	8d 83 93 53 ff ff    	lea    -0xac6d(%ebx),%eax
  101b72:	50                   	push   %eax
  101b73:	e8 7b e7 ff ff       	call   1002f3 <cprintf>
  101b78:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101b7b:	83 ec 0c             	sub    $0xc,%esp
  101b7e:	8d 83 9d 53 ff ff    	lea    -0xac63(%ebx),%eax
  101b84:	50                   	push   %eax
  101b85:	e8 69 e7 ff ff       	call   1002f3 <cprintf>
  101b8a:	83 c4 10             	add    $0x10,%esp
    panic("EOT: kernel seems ok.");
  101b8d:	83 ec 04             	sub    $0x4,%esp
  101b90:	8d 83 ab 53 ff ff    	lea    -0xac55(%ebx),%eax
  101b96:	50                   	push   %eax
  101b97:	6a 12                	push   $0x12
  101b99:	8d 83 c1 53 ff ff    	lea    -0xac3f(%ebx),%eax
  101b9f:	50                   	push   %eax
  101ba0:	e8 fe e8 ff ff       	call   1004a3 <__panic>

00101ba5 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101ba5:	55                   	push   %ebp
  101ba6:	89 e5                	mov    %esp,%ebp
  101ba8:	83 ec 10             	sub    $0x10,%esp
  101bab:	e8 cc e6 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101bb0:	05 a0 cd 00 00       	add    $0xcda0,%eax
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t  __vectors[];
      for(int i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
  101bb5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101bbc:	e9 c7 00 00 00       	jmp    101c88 <idt_init+0xe3>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101bc1:	c7 c2 02 e5 10 00    	mov    $0x10e502,%edx
  101bc7:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  101bca:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
  101bcd:	89 d1                	mov    %edx,%ecx
  101bcf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101bd2:	66 89 8c d0 f0 07 00 	mov    %cx,0x7f0(%eax,%edx,8)
  101bd9:	00 
  101bda:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101bdd:	66 c7 84 d0 f2 07 00 	movw   $0x8,0x7f2(%eax,%edx,8)
  101be4:	00 08 00 
  101be7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101bea:	0f b6 8c d0 f4 07 00 	movzbl 0x7f4(%eax,%edx,8),%ecx
  101bf1:	00 
  101bf2:	83 e1 e0             	and    $0xffffffe0,%ecx
  101bf5:	88 8c d0 f4 07 00 00 	mov    %cl,0x7f4(%eax,%edx,8)
  101bfc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101bff:	0f b6 8c d0 f4 07 00 	movzbl 0x7f4(%eax,%edx,8),%ecx
  101c06:	00 
  101c07:	83 e1 1f             	and    $0x1f,%ecx
  101c0a:	88 8c d0 f4 07 00 00 	mov    %cl,0x7f4(%eax,%edx,8)
  101c11:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c14:	0f b6 8c d0 f5 07 00 	movzbl 0x7f5(%eax,%edx,8),%ecx
  101c1b:	00 
  101c1c:	83 e1 f0             	and    $0xfffffff0,%ecx
  101c1f:	83 c9 0e             	or     $0xe,%ecx
  101c22:	88 8c d0 f5 07 00 00 	mov    %cl,0x7f5(%eax,%edx,8)
  101c29:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c2c:	0f b6 8c d0 f5 07 00 	movzbl 0x7f5(%eax,%edx,8),%ecx
  101c33:	00 
  101c34:	83 e1 ef             	and    $0xffffffef,%ecx
  101c37:	88 8c d0 f5 07 00 00 	mov    %cl,0x7f5(%eax,%edx,8)
  101c3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c41:	0f b6 8c d0 f5 07 00 	movzbl 0x7f5(%eax,%edx,8),%ecx
  101c48:	00 
  101c49:	83 e1 9f             	and    $0xffffff9f,%ecx
  101c4c:	88 8c d0 f5 07 00 00 	mov    %cl,0x7f5(%eax,%edx,8)
  101c53:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c56:	0f b6 8c d0 f5 07 00 	movzbl 0x7f5(%eax,%edx,8),%ecx
  101c5d:	00 
  101c5e:	83 c9 80             	or     $0xffffff80,%ecx
  101c61:	88 8c d0 f5 07 00 00 	mov    %cl,0x7f5(%eax,%edx,8)
  101c68:	c7 c2 02 e5 10 00    	mov    $0x10e502,%edx
  101c6e:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  101c71:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
  101c74:	c1 ea 10             	shr    $0x10,%edx
  101c77:	89 d1                	mov    %edx,%ecx
  101c79:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c7c:	66 89 8c d0 f6 07 00 	mov    %cx,0x7f6(%eax,%edx,8)
  101c83:	00 
      for(int i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
  101c84:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101c88:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c8b:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  101c91:	0f 86 2a ff ff ff    	jbe    101bc1 <idt_init+0x1c>
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101c97:	c7 c2 02 e5 10 00    	mov    $0x10e502,%edx
  101c9d:	8b 92 e4 01 00 00    	mov    0x1e4(%edx),%edx
  101ca3:	66 89 90 b8 0b 00 00 	mov    %dx,0xbb8(%eax)
  101caa:	66 c7 80 ba 0b 00 00 	movw   $0x8,0xbba(%eax)
  101cb1:	08 00 
  101cb3:	0f b6 90 bc 0b 00 00 	movzbl 0xbbc(%eax),%edx
  101cba:	83 e2 e0             	and    $0xffffffe0,%edx
  101cbd:	88 90 bc 0b 00 00    	mov    %dl,0xbbc(%eax)
  101cc3:	0f b6 90 bc 0b 00 00 	movzbl 0xbbc(%eax),%edx
  101cca:	83 e2 1f             	and    $0x1f,%edx
  101ccd:	88 90 bc 0b 00 00    	mov    %dl,0xbbc(%eax)
  101cd3:	0f b6 90 bd 0b 00 00 	movzbl 0xbbd(%eax),%edx
  101cda:	83 e2 f0             	and    $0xfffffff0,%edx
  101cdd:	83 ca 0e             	or     $0xe,%edx
  101ce0:	88 90 bd 0b 00 00    	mov    %dl,0xbbd(%eax)
  101ce6:	0f b6 90 bd 0b 00 00 	movzbl 0xbbd(%eax),%edx
  101ced:	83 e2 ef             	and    $0xffffffef,%edx
  101cf0:	88 90 bd 0b 00 00    	mov    %dl,0xbbd(%eax)
  101cf6:	0f b6 90 bd 0b 00 00 	movzbl 0xbbd(%eax),%edx
  101cfd:	83 ca 60             	or     $0x60,%edx
  101d00:	88 90 bd 0b 00 00    	mov    %dl,0xbbd(%eax)
  101d06:	0f b6 90 bd 0b 00 00 	movzbl 0xbbd(%eax),%edx
  101d0d:	83 ca 80             	or     $0xffffff80,%edx
  101d10:	88 90 bd 0b 00 00    	mov    %dl,0xbbd(%eax)
  101d16:	c7 c2 02 e5 10 00    	mov    $0x10e502,%edx
  101d1c:	8b 92 e4 01 00 00    	mov    0x1e4(%edx),%edx
  101d22:	c1 ea 10             	shr    $0x10,%edx
  101d25:	66 89 90 be 0b 00 00 	mov    %dx,0xbbe(%eax)
  101d2c:	8d 80 50 00 00 00    	lea    0x50(%eax),%eax
  101d32:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101d35:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101d38:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101d3b:	90                   	nop
  101d3c:	c9                   	leave  
  101d3d:	c3                   	ret    

00101d3e <trapname>:

static const char *
trapname(int trapno) {
  101d3e:	55                   	push   %ebp
  101d3f:	89 e5                	mov    %esp,%ebp
  101d41:	e8 36 e5 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101d46:	05 0a cc 00 00       	add    $0xcc0a,%eax
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  101d4e:	83 fa 13             	cmp    $0x13,%edx
  101d51:	77 0c                	ja     101d5f <trapname+0x21>
        return excnames[trapno];
  101d53:	8b 55 08             	mov    0x8(%ebp),%edx
  101d56:	8b 84 90 f0 00 00 00 	mov    0xf0(%eax,%edx,4),%eax
  101d5d:	eb 1a                	jmp    101d79 <trapname+0x3b>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101d5f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101d63:	7e 0e                	jle    101d73 <trapname+0x35>
  101d65:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101d69:	7f 08                	jg     101d73 <trapname+0x35>
        return "Hardware Interrupt";
  101d6b:	8d 80 d2 53 ff ff    	lea    -0xac2e(%eax),%eax
  101d71:	eb 06                	jmp    101d79 <trapname+0x3b>
    }
    return "(unknown trap)";
  101d73:	8d 80 e5 53 ff ff    	lea    -0xac1b(%eax),%eax
}
  101d79:	5d                   	pop    %ebp
  101d7a:	c3                   	ret    

00101d7b <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101d7b:	55                   	push   %ebp
  101d7c:	89 e5                	mov    %esp,%ebp
  101d7e:	e8 f9 e4 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  101d83:	05 cd cb 00 00       	add    $0xcbcd,%eax
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101d88:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d8f:	66 83 f8 08          	cmp    $0x8,%ax
  101d93:	0f 94 c0             	sete   %al
  101d96:	0f b6 c0             	movzbl %al,%eax
}
  101d99:	5d                   	pop    %ebp
  101d9a:	c3                   	ret    

00101d9b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101d9b:	55                   	push   %ebp
  101d9c:	89 e5                	mov    %esp,%ebp
  101d9e:	53                   	push   %ebx
  101d9f:	83 ec 14             	sub    $0x14,%esp
  101da2:	e8 d9 e4 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  101da7:	81 c3 a9 cb 00 00    	add    $0xcba9,%ebx
    cprintf("trapframe at %p\n", tf);
  101dad:	83 ec 08             	sub    $0x8,%esp
  101db0:	ff 75 08             	pushl  0x8(%ebp)
  101db3:	8d 83 26 54 ff ff    	lea    -0xabda(%ebx),%eax
  101db9:	50                   	push   %eax
  101dba:	e8 34 e5 ff ff       	call   1002f3 <cprintf>
  101dbf:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
  101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc5:	83 ec 0c             	sub    $0xc,%esp
  101dc8:	50                   	push   %eax
  101dc9:	e8 d3 01 00 00       	call   101fa1 <print_regs>
  101dce:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd4:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101dd8:	0f b7 c0             	movzwl %ax,%eax
  101ddb:	83 ec 08             	sub    $0x8,%esp
  101dde:	50                   	push   %eax
  101ddf:	8d 83 37 54 ff ff    	lea    -0xabc9(%ebx),%eax
  101de5:	50                   	push   %eax
  101de6:	e8 08 e5 ff ff       	call   1002f3 <cprintf>
  101deb:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101dee:	8b 45 08             	mov    0x8(%ebp),%eax
  101df1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101df5:	0f b7 c0             	movzwl %ax,%eax
  101df8:	83 ec 08             	sub    $0x8,%esp
  101dfb:	50                   	push   %eax
  101dfc:	8d 83 4a 54 ff ff    	lea    -0xabb6(%ebx),%eax
  101e02:	50                   	push   %eax
  101e03:	e8 eb e4 ff ff       	call   1002f3 <cprintf>
  101e08:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0e:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101e12:	0f b7 c0             	movzwl %ax,%eax
  101e15:	83 ec 08             	sub    $0x8,%esp
  101e18:	50                   	push   %eax
  101e19:	8d 83 5d 54 ff ff    	lea    -0xaba3(%ebx),%eax
  101e1f:	50                   	push   %eax
  101e20:	e8 ce e4 ff ff       	call   1002f3 <cprintf>
  101e25:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101e28:	8b 45 08             	mov    0x8(%ebp),%eax
  101e2b:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101e2f:	0f b7 c0             	movzwl %ax,%eax
  101e32:	83 ec 08             	sub    $0x8,%esp
  101e35:	50                   	push   %eax
  101e36:	8d 83 70 54 ff ff    	lea    -0xab90(%ebx),%eax
  101e3c:	50                   	push   %eax
  101e3d:	e8 b1 e4 ff ff       	call   1002f3 <cprintf>
  101e42:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101e45:	8b 45 08             	mov    0x8(%ebp),%eax
  101e48:	8b 40 30             	mov    0x30(%eax),%eax
  101e4b:	83 ec 0c             	sub    $0xc,%esp
  101e4e:	50                   	push   %eax
  101e4f:	e8 ea fe ff ff       	call   101d3e <trapname>
  101e54:	83 c4 10             	add    $0x10,%esp
  101e57:	89 c2                	mov    %eax,%edx
  101e59:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5c:	8b 40 30             	mov    0x30(%eax),%eax
  101e5f:	83 ec 04             	sub    $0x4,%esp
  101e62:	52                   	push   %edx
  101e63:	50                   	push   %eax
  101e64:	8d 83 83 54 ff ff    	lea    -0xab7d(%ebx),%eax
  101e6a:	50                   	push   %eax
  101e6b:	e8 83 e4 ff ff       	call   1002f3 <cprintf>
  101e70:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
  101e73:	8b 45 08             	mov    0x8(%ebp),%eax
  101e76:	8b 40 34             	mov    0x34(%eax),%eax
  101e79:	83 ec 08             	sub    $0x8,%esp
  101e7c:	50                   	push   %eax
  101e7d:	8d 83 95 54 ff ff    	lea    -0xab6b(%ebx),%eax
  101e83:	50                   	push   %eax
  101e84:	e8 6a e4 ff ff       	call   1002f3 <cprintf>
  101e89:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8f:	8b 40 38             	mov    0x38(%eax),%eax
  101e92:	83 ec 08             	sub    $0x8,%esp
  101e95:	50                   	push   %eax
  101e96:	8d 83 a4 54 ff ff    	lea    -0xab5c(%ebx),%eax
  101e9c:	50                   	push   %eax
  101e9d:	e8 51 e4 ff ff       	call   1002f3 <cprintf>
  101ea2:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101eac:	0f b7 c0             	movzwl %ax,%eax
  101eaf:	83 ec 08             	sub    $0x8,%esp
  101eb2:	50                   	push   %eax
  101eb3:	8d 83 b3 54 ff ff    	lea    -0xab4d(%ebx),%eax
  101eb9:	50                   	push   %eax
  101eba:	e8 34 e4 ff ff       	call   1002f3 <cprintf>
  101ebf:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec5:	8b 40 40             	mov    0x40(%eax),%eax
  101ec8:	83 ec 08             	sub    $0x8,%esp
  101ecb:	50                   	push   %eax
  101ecc:	8d 83 c6 54 ff ff    	lea    -0xab3a(%ebx),%eax
  101ed2:	50                   	push   %eax
  101ed3:	e8 1b e4 ff ff       	call   1002f3 <cprintf>
  101ed8:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101edb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ee2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ee9:	eb 41                	jmp    101f2c <print_trapframe+0x191>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  101eee:	8b 50 40             	mov    0x40(%eax),%edx
  101ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ef4:	21 d0                	and    %edx,%eax
  101ef6:	85 c0                	test   %eax,%eax
  101ef8:	74 2b                	je     101f25 <print_trapframe+0x18a>
  101efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101efd:	8b 84 83 70 00 00 00 	mov    0x70(%ebx,%eax,4),%eax
  101f04:	85 c0                	test   %eax,%eax
  101f06:	74 1d                	je     101f25 <print_trapframe+0x18a>
            cprintf("%s,", IA32flags[i]);
  101f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101f0b:	8b 84 83 70 00 00 00 	mov    0x70(%ebx,%eax,4),%eax
  101f12:	83 ec 08             	sub    $0x8,%esp
  101f15:	50                   	push   %eax
  101f16:	8d 83 d5 54 ff ff    	lea    -0xab2b(%ebx),%eax
  101f1c:	50                   	push   %eax
  101f1d:	e8 d1 e3 ff ff       	call   1002f3 <cprintf>
  101f22:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101f25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101f29:	d1 65 f0             	shll   -0x10(%ebp)
  101f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101f2f:	83 f8 17             	cmp    $0x17,%eax
  101f32:	76 b7                	jbe    101eeb <print_trapframe+0x150>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101f34:	8b 45 08             	mov    0x8(%ebp),%eax
  101f37:	8b 40 40             	mov    0x40(%eax),%eax
  101f3a:	c1 e8 0c             	shr    $0xc,%eax
  101f3d:	83 e0 03             	and    $0x3,%eax
  101f40:	83 ec 08             	sub    $0x8,%esp
  101f43:	50                   	push   %eax
  101f44:	8d 83 d9 54 ff ff    	lea    -0xab27(%ebx),%eax
  101f4a:	50                   	push   %eax
  101f4b:	e8 a3 e3 ff ff       	call   1002f3 <cprintf>
  101f50:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
  101f53:	83 ec 0c             	sub    $0xc,%esp
  101f56:	ff 75 08             	pushl  0x8(%ebp)
  101f59:	e8 1d fe ff ff       	call   101d7b <trap_in_kernel>
  101f5e:	83 c4 10             	add    $0x10,%esp
  101f61:	85 c0                	test   %eax,%eax
  101f63:	75 36                	jne    101f9b <print_trapframe+0x200>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101f65:	8b 45 08             	mov    0x8(%ebp),%eax
  101f68:	8b 40 44             	mov    0x44(%eax),%eax
  101f6b:	83 ec 08             	sub    $0x8,%esp
  101f6e:	50                   	push   %eax
  101f6f:	8d 83 e2 54 ff ff    	lea    -0xab1e(%ebx),%eax
  101f75:	50                   	push   %eax
  101f76:	e8 78 e3 ff ff       	call   1002f3 <cprintf>
  101f7b:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f81:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101f85:	0f b7 c0             	movzwl %ax,%eax
  101f88:	83 ec 08             	sub    $0x8,%esp
  101f8b:	50                   	push   %eax
  101f8c:	8d 83 f1 54 ff ff    	lea    -0xab0f(%ebx),%eax
  101f92:	50                   	push   %eax
  101f93:	e8 5b e3 ff ff       	call   1002f3 <cprintf>
  101f98:	83 c4 10             	add    $0x10,%esp
    }
}
  101f9b:	90                   	nop
  101f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101f9f:	c9                   	leave  
  101fa0:	c3                   	ret    

00101fa1 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101fa1:	55                   	push   %ebp
  101fa2:	89 e5                	mov    %esp,%ebp
  101fa4:	53                   	push   %ebx
  101fa5:	83 ec 04             	sub    $0x4,%esp
  101fa8:	e8 d3 e2 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  101fad:	81 c3 a3 c9 00 00    	add    $0xc9a3,%ebx
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  101fb6:	8b 00                	mov    (%eax),%eax
  101fb8:	83 ec 08             	sub    $0x8,%esp
  101fbb:	50                   	push   %eax
  101fbc:	8d 83 04 55 ff ff    	lea    -0xaafc(%ebx),%eax
  101fc2:	50                   	push   %eax
  101fc3:	e8 2b e3 ff ff       	call   1002f3 <cprintf>
  101fc8:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  101fce:	8b 40 04             	mov    0x4(%eax),%eax
  101fd1:	83 ec 08             	sub    $0x8,%esp
  101fd4:	50                   	push   %eax
  101fd5:	8d 83 13 55 ff ff    	lea    -0xaaed(%ebx),%eax
  101fdb:	50                   	push   %eax
  101fdc:	e8 12 e3 ff ff       	call   1002f3 <cprintf>
  101fe1:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  101fe7:	8b 40 08             	mov    0x8(%eax),%eax
  101fea:	83 ec 08             	sub    $0x8,%esp
  101fed:	50                   	push   %eax
  101fee:	8d 83 22 55 ff ff    	lea    -0xaade(%ebx),%eax
  101ff4:	50                   	push   %eax
  101ff5:	e8 f9 e2 ff ff       	call   1002f3 <cprintf>
  101ffa:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  102000:	8b 40 0c             	mov    0xc(%eax),%eax
  102003:	83 ec 08             	sub    $0x8,%esp
  102006:	50                   	push   %eax
  102007:	8d 83 31 55 ff ff    	lea    -0xaacf(%ebx),%eax
  10200d:	50                   	push   %eax
  10200e:	e8 e0 e2 ff ff       	call   1002f3 <cprintf>
  102013:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  102016:	8b 45 08             	mov    0x8(%ebp),%eax
  102019:	8b 40 10             	mov    0x10(%eax),%eax
  10201c:	83 ec 08             	sub    $0x8,%esp
  10201f:	50                   	push   %eax
  102020:	8d 83 40 55 ff ff    	lea    -0xaac0(%ebx),%eax
  102026:	50                   	push   %eax
  102027:	e8 c7 e2 ff ff       	call   1002f3 <cprintf>
  10202c:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  10202f:	8b 45 08             	mov    0x8(%ebp),%eax
  102032:	8b 40 14             	mov    0x14(%eax),%eax
  102035:	83 ec 08             	sub    $0x8,%esp
  102038:	50                   	push   %eax
  102039:	8d 83 4f 55 ff ff    	lea    -0xaab1(%ebx),%eax
  10203f:	50                   	push   %eax
  102040:	e8 ae e2 ff ff       	call   1002f3 <cprintf>
  102045:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  102048:	8b 45 08             	mov    0x8(%ebp),%eax
  10204b:	8b 40 18             	mov    0x18(%eax),%eax
  10204e:	83 ec 08             	sub    $0x8,%esp
  102051:	50                   	push   %eax
  102052:	8d 83 5e 55 ff ff    	lea    -0xaaa2(%ebx),%eax
  102058:	50                   	push   %eax
  102059:	e8 95 e2 ff ff       	call   1002f3 <cprintf>
  10205e:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  102061:	8b 45 08             	mov    0x8(%ebp),%eax
  102064:	8b 40 1c             	mov    0x1c(%eax),%eax
  102067:	83 ec 08             	sub    $0x8,%esp
  10206a:	50                   	push   %eax
  10206b:	8d 83 6d 55 ff ff    	lea    -0xaa93(%ebx),%eax
  102071:	50                   	push   %eax
  102072:	e8 7c e2 ff ff       	call   1002f3 <cprintf>
  102077:	83 c4 10             	add    $0x10,%esp
}
  10207a:	90                   	nop
  10207b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10207e:	c9                   	leave  
  10207f:	c3                   	ret    

00102080 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  102080:	55                   	push   %ebp
  102081:	89 e5                	mov    %esp,%ebp
  102083:	53                   	push   %ebx
  102084:	83 ec 14             	sub    $0x14,%esp
  102087:	e8 f4 e1 ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  10208c:	81 c3 c4 c8 00 00    	add    $0xc8c4,%ebx
    char c;

    switch (tf->tf_trapno) {
  102092:	8b 45 08             	mov    0x8(%ebp),%eax
  102095:	8b 40 30             	mov    0x30(%eax),%eax
  102098:	83 f8 2f             	cmp    $0x2f,%eax
  10209b:	77 21                	ja     1020be <trap_dispatch+0x3e>
  10209d:	83 f8 2e             	cmp    $0x2e,%eax
  1020a0:	0f 83 0c 01 00 00    	jae    1021b2 <trap_dispatch+0x132>
  1020a6:	83 f8 21             	cmp    $0x21,%eax
  1020a9:	0f 84 88 00 00 00    	je     102137 <trap_dispatch+0xb7>
  1020af:	83 f8 24             	cmp    $0x24,%eax
  1020b2:	74 5d                	je     102111 <trap_dispatch+0x91>
  1020b4:	83 f8 20             	cmp    $0x20,%eax
  1020b7:	74 16                	je     1020cf <trap_dispatch+0x4f>
  1020b9:	e9 ba 00 00 00       	jmp    102178 <trap_dispatch+0xf8>
  1020be:	83 e8 78             	sub    $0x78,%eax
  1020c1:	83 f8 01             	cmp    $0x1,%eax
  1020c4:	0f 87 ae 00 00 00    	ja     102178 <trap_dispatch+0xf8>
  1020ca:	e9 8e 00 00 00       	jmp    10215d <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
         ticks++;
  1020cf:	c7 c0 a8 f9 10 00    	mov    $0x10f9a8,%eax
  1020d5:	8b 00                	mov    (%eax),%eax
  1020d7:	8d 50 01             	lea    0x1(%eax),%edx
  1020da:	c7 c0 a8 f9 10 00    	mov    $0x10f9a8,%eax
  1020e0:	89 10                	mov    %edx,(%eax)
         if(ticks % TICK_NUM == 0)
  1020e2:	c7 c0 a8 f9 10 00    	mov    $0x10f9a8,%eax
  1020e8:	8b 08                	mov    (%eax),%ecx
  1020ea:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  1020ef:	89 c8                	mov    %ecx,%eax
  1020f1:	f7 e2                	mul    %edx
  1020f3:	89 d0                	mov    %edx,%eax
  1020f5:	c1 e8 05             	shr    $0x5,%eax
  1020f8:	6b c0 64             	imul   $0x64,%eax,%eax
  1020fb:	29 c1                	sub    %eax,%ecx
  1020fd:	89 c8                	mov    %ecx,%eax
  1020ff:	85 c0                	test   %eax,%eax
  102101:	0f 85 ae 00 00 00    	jne    1021b5 <trap_dispatch+0x135>
            print_ticks();
  102107:	e8 49 fa ff ff       	call   101b55 <print_ticks>
        break;
  10210c:	e9 a4 00 00 00       	jmp    1021b5 <trap_dispatch+0x135>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  102111:	e8 c3 f7 ff ff       	call   1018d9 <cons_getc>
  102116:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  102119:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  10211d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  102121:	83 ec 04             	sub    $0x4,%esp
  102124:	52                   	push   %edx
  102125:	50                   	push   %eax
  102126:	8d 83 7c 55 ff ff    	lea    -0xaa84(%ebx),%eax
  10212c:	50                   	push   %eax
  10212d:	e8 c1 e1 ff ff       	call   1002f3 <cprintf>
  102132:	83 c4 10             	add    $0x10,%esp
        break;
  102135:	eb 7f                	jmp    1021b6 <trap_dispatch+0x136>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  102137:	e8 9d f7 ff ff       	call   1018d9 <cons_getc>
  10213c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  10213f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  102143:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  102147:	83 ec 04             	sub    $0x4,%esp
  10214a:	52                   	push   %edx
  10214b:	50                   	push   %eax
  10214c:	8d 83 8e 55 ff ff    	lea    -0xaa72(%ebx),%eax
  102152:	50                   	push   %eax
  102153:	e8 9b e1 ff ff       	call   1002f3 <cprintf>
  102158:	83 c4 10             	add    $0x10,%esp
        break;
  10215b:	eb 59                	jmp    1021b6 <trap_dispatch+0x136>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  10215d:	83 ec 04             	sub    $0x4,%esp
  102160:	8d 83 9d 55 ff ff    	lea    -0xaa63(%ebx),%eax
  102166:	50                   	push   %eax
  102167:	68 aa 00 00 00       	push   $0xaa
  10216c:	8d 83 c1 53 ff ff    	lea    -0xac3f(%ebx),%eax
  102172:	50                   	push   %eax
  102173:	e8 2b e3 ff ff       	call   1004a3 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  102178:	8b 45 08             	mov    0x8(%ebp),%eax
  10217b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10217f:	0f b7 c0             	movzwl %ax,%eax
  102182:	83 e0 03             	and    $0x3,%eax
  102185:	85 c0                	test   %eax,%eax
  102187:	75 2d                	jne    1021b6 <trap_dispatch+0x136>
            print_trapframe(tf);
  102189:	83 ec 0c             	sub    $0xc,%esp
  10218c:	ff 75 08             	pushl  0x8(%ebp)
  10218f:	e8 07 fc ff ff       	call   101d9b <print_trapframe>
  102194:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
  102197:	83 ec 04             	sub    $0x4,%esp
  10219a:	8d 83 ad 55 ff ff    	lea    -0xaa53(%ebx),%eax
  1021a0:	50                   	push   %eax
  1021a1:	68 b4 00 00 00       	push   $0xb4
  1021a6:	8d 83 c1 53 ff ff    	lea    -0xac3f(%ebx),%eax
  1021ac:	50                   	push   %eax
  1021ad:	e8 f1 e2 ff ff       	call   1004a3 <__panic>
        break;
  1021b2:	90                   	nop
  1021b3:	eb 01                	jmp    1021b6 <trap_dispatch+0x136>
        break;
  1021b5:	90                   	nop
        }
    }
}
  1021b6:	90                   	nop
  1021b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1021ba:	c9                   	leave  
  1021bb:	c3                   	ret    

001021bc <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  1021bc:	55                   	push   %ebp
  1021bd:	89 e5                	mov    %esp,%ebp
  1021bf:	83 ec 08             	sub    $0x8,%esp
  1021c2:	e8 b5 e0 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1021c7:	05 89 c7 00 00       	add    $0xc789,%eax
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  1021cc:	83 ec 0c             	sub    $0xc,%esp
  1021cf:	ff 75 08             	pushl  0x8(%ebp)
  1021d2:	e8 a9 fe ff ff       	call   102080 <trap_dispatch>
  1021d7:	83 c4 10             	add    $0x10,%esp
}
  1021da:	90                   	nop
  1021db:	c9                   	leave  
  1021dc:	c3                   	ret    

001021dd <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $0
  1021df:	6a 00                	push   $0x0
  jmp __alltraps
  1021e1:	e9 67 0a 00 00       	jmp    102c4d <__alltraps>

001021e6 <vector1>:
.globl vector1
vector1:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $1
  1021e8:	6a 01                	push   $0x1
  jmp __alltraps
  1021ea:	e9 5e 0a 00 00       	jmp    102c4d <__alltraps>

001021ef <vector2>:
.globl vector2
vector2:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $2
  1021f1:	6a 02                	push   $0x2
  jmp __alltraps
  1021f3:	e9 55 0a 00 00       	jmp    102c4d <__alltraps>

001021f8 <vector3>:
.globl vector3
vector3:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $3
  1021fa:	6a 03                	push   $0x3
  jmp __alltraps
  1021fc:	e9 4c 0a 00 00       	jmp    102c4d <__alltraps>

00102201 <vector4>:
.globl vector4
vector4:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $4
  102203:	6a 04                	push   $0x4
  jmp __alltraps
  102205:	e9 43 0a 00 00       	jmp    102c4d <__alltraps>

0010220a <vector5>:
.globl vector5
vector5:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $5
  10220c:	6a 05                	push   $0x5
  jmp __alltraps
  10220e:	e9 3a 0a 00 00       	jmp    102c4d <__alltraps>

00102213 <vector6>:
.globl vector6
vector6:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $6
  102215:	6a 06                	push   $0x6
  jmp __alltraps
  102217:	e9 31 0a 00 00       	jmp    102c4d <__alltraps>

0010221c <vector7>:
.globl vector7
vector7:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $7
  10221e:	6a 07                	push   $0x7
  jmp __alltraps
  102220:	e9 28 0a 00 00       	jmp    102c4d <__alltraps>

00102225 <vector8>:
.globl vector8
vector8:
  pushl $8
  102225:	6a 08                	push   $0x8
  jmp __alltraps
  102227:	e9 21 0a 00 00       	jmp    102c4d <__alltraps>

0010222c <vector9>:
.globl vector9
vector9:
  pushl $9
  10222c:	6a 09                	push   $0x9
  jmp __alltraps
  10222e:	e9 1a 0a 00 00       	jmp    102c4d <__alltraps>

00102233 <vector10>:
.globl vector10
vector10:
  pushl $10
  102233:	6a 0a                	push   $0xa
  jmp __alltraps
  102235:	e9 13 0a 00 00       	jmp    102c4d <__alltraps>

0010223a <vector11>:
.globl vector11
vector11:
  pushl $11
  10223a:	6a 0b                	push   $0xb
  jmp __alltraps
  10223c:	e9 0c 0a 00 00       	jmp    102c4d <__alltraps>

00102241 <vector12>:
.globl vector12
vector12:
  pushl $12
  102241:	6a 0c                	push   $0xc
  jmp __alltraps
  102243:	e9 05 0a 00 00       	jmp    102c4d <__alltraps>

00102248 <vector13>:
.globl vector13
vector13:
  pushl $13
  102248:	6a 0d                	push   $0xd
  jmp __alltraps
  10224a:	e9 fe 09 00 00       	jmp    102c4d <__alltraps>

0010224f <vector14>:
.globl vector14
vector14:
  pushl $14
  10224f:	6a 0e                	push   $0xe
  jmp __alltraps
  102251:	e9 f7 09 00 00       	jmp    102c4d <__alltraps>

00102256 <vector15>:
.globl vector15
vector15:
  pushl $0
  102256:	6a 00                	push   $0x0
  pushl $15
  102258:	6a 0f                	push   $0xf
  jmp __alltraps
  10225a:	e9 ee 09 00 00       	jmp    102c4d <__alltraps>

0010225f <vector16>:
.globl vector16
vector16:
  pushl $0
  10225f:	6a 00                	push   $0x0
  pushl $16
  102261:	6a 10                	push   $0x10
  jmp __alltraps
  102263:	e9 e5 09 00 00       	jmp    102c4d <__alltraps>

00102268 <vector17>:
.globl vector17
vector17:
  pushl $17
  102268:	6a 11                	push   $0x11
  jmp __alltraps
  10226a:	e9 de 09 00 00       	jmp    102c4d <__alltraps>

0010226f <vector18>:
.globl vector18
vector18:
  pushl $0
  10226f:	6a 00                	push   $0x0
  pushl $18
  102271:	6a 12                	push   $0x12
  jmp __alltraps
  102273:	e9 d5 09 00 00       	jmp    102c4d <__alltraps>

00102278 <vector19>:
.globl vector19
vector19:
  pushl $0
  102278:	6a 00                	push   $0x0
  pushl $19
  10227a:	6a 13                	push   $0x13
  jmp __alltraps
  10227c:	e9 cc 09 00 00       	jmp    102c4d <__alltraps>

00102281 <vector20>:
.globl vector20
vector20:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $20
  102283:	6a 14                	push   $0x14
  jmp __alltraps
  102285:	e9 c3 09 00 00       	jmp    102c4d <__alltraps>

0010228a <vector21>:
.globl vector21
vector21:
  pushl $0
  10228a:	6a 00                	push   $0x0
  pushl $21
  10228c:	6a 15                	push   $0x15
  jmp __alltraps
  10228e:	e9 ba 09 00 00       	jmp    102c4d <__alltraps>

00102293 <vector22>:
.globl vector22
vector22:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $22
  102295:	6a 16                	push   $0x16
  jmp __alltraps
  102297:	e9 b1 09 00 00       	jmp    102c4d <__alltraps>

0010229c <vector23>:
.globl vector23
vector23:
  pushl $0
  10229c:	6a 00                	push   $0x0
  pushl $23
  10229e:	6a 17                	push   $0x17
  jmp __alltraps
  1022a0:	e9 a8 09 00 00       	jmp    102c4d <__alltraps>

001022a5 <vector24>:
.globl vector24
vector24:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $24
  1022a7:	6a 18                	push   $0x18
  jmp __alltraps
  1022a9:	e9 9f 09 00 00       	jmp    102c4d <__alltraps>

001022ae <vector25>:
.globl vector25
vector25:
  pushl $0
  1022ae:	6a 00                	push   $0x0
  pushl $25
  1022b0:	6a 19                	push   $0x19
  jmp __alltraps
  1022b2:	e9 96 09 00 00       	jmp    102c4d <__alltraps>

001022b7 <vector26>:
.globl vector26
vector26:
  pushl $0
  1022b7:	6a 00                	push   $0x0
  pushl $26
  1022b9:	6a 1a                	push   $0x1a
  jmp __alltraps
  1022bb:	e9 8d 09 00 00       	jmp    102c4d <__alltraps>

001022c0 <vector27>:
.globl vector27
vector27:
  pushl $0
  1022c0:	6a 00                	push   $0x0
  pushl $27
  1022c2:	6a 1b                	push   $0x1b
  jmp __alltraps
  1022c4:	e9 84 09 00 00       	jmp    102c4d <__alltraps>

001022c9 <vector28>:
.globl vector28
vector28:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $28
  1022cb:	6a 1c                	push   $0x1c
  jmp __alltraps
  1022cd:	e9 7b 09 00 00       	jmp    102c4d <__alltraps>

001022d2 <vector29>:
.globl vector29
vector29:
  pushl $0
  1022d2:	6a 00                	push   $0x0
  pushl $29
  1022d4:	6a 1d                	push   $0x1d
  jmp __alltraps
  1022d6:	e9 72 09 00 00       	jmp    102c4d <__alltraps>

001022db <vector30>:
.globl vector30
vector30:
  pushl $0
  1022db:	6a 00                	push   $0x0
  pushl $30
  1022dd:	6a 1e                	push   $0x1e
  jmp __alltraps
  1022df:	e9 69 09 00 00       	jmp    102c4d <__alltraps>

001022e4 <vector31>:
.globl vector31
vector31:
  pushl $0
  1022e4:	6a 00                	push   $0x0
  pushl $31
  1022e6:	6a 1f                	push   $0x1f
  jmp __alltraps
  1022e8:	e9 60 09 00 00       	jmp    102c4d <__alltraps>

001022ed <vector32>:
.globl vector32
vector32:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $32
  1022ef:	6a 20                	push   $0x20
  jmp __alltraps
  1022f1:	e9 57 09 00 00       	jmp    102c4d <__alltraps>

001022f6 <vector33>:
.globl vector33
vector33:
  pushl $0
  1022f6:	6a 00                	push   $0x0
  pushl $33
  1022f8:	6a 21                	push   $0x21
  jmp __alltraps
  1022fa:	e9 4e 09 00 00       	jmp    102c4d <__alltraps>

001022ff <vector34>:
.globl vector34
vector34:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $34
  102301:	6a 22                	push   $0x22
  jmp __alltraps
  102303:	e9 45 09 00 00       	jmp    102c4d <__alltraps>

00102308 <vector35>:
.globl vector35
vector35:
  pushl $0
  102308:	6a 00                	push   $0x0
  pushl $35
  10230a:	6a 23                	push   $0x23
  jmp __alltraps
  10230c:	e9 3c 09 00 00       	jmp    102c4d <__alltraps>

00102311 <vector36>:
.globl vector36
vector36:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $36
  102313:	6a 24                	push   $0x24
  jmp __alltraps
  102315:	e9 33 09 00 00       	jmp    102c4d <__alltraps>

0010231a <vector37>:
.globl vector37
vector37:
  pushl $0
  10231a:	6a 00                	push   $0x0
  pushl $37
  10231c:	6a 25                	push   $0x25
  jmp __alltraps
  10231e:	e9 2a 09 00 00       	jmp    102c4d <__alltraps>

00102323 <vector38>:
.globl vector38
vector38:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $38
  102325:	6a 26                	push   $0x26
  jmp __alltraps
  102327:	e9 21 09 00 00       	jmp    102c4d <__alltraps>

0010232c <vector39>:
.globl vector39
vector39:
  pushl $0
  10232c:	6a 00                	push   $0x0
  pushl $39
  10232e:	6a 27                	push   $0x27
  jmp __alltraps
  102330:	e9 18 09 00 00       	jmp    102c4d <__alltraps>

00102335 <vector40>:
.globl vector40
vector40:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $40
  102337:	6a 28                	push   $0x28
  jmp __alltraps
  102339:	e9 0f 09 00 00       	jmp    102c4d <__alltraps>

0010233e <vector41>:
.globl vector41
vector41:
  pushl $0
  10233e:	6a 00                	push   $0x0
  pushl $41
  102340:	6a 29                	push   $0x29
  jmp __alltraps
  102342:	e9 06 09 00 00       	jmp    102c4d <__alltraps>

00102347 <vector42>:
.globl vector42
vector42:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $42
  102349:	6a 2a                	push   $0x2a
  jmp __alltraps
  10234b:	e9 fd 08 00 00       	jmp    102c4d <__alltraps>

00102350 <vector43>:
.globl vector43
vector43:
  pushl $0
  102350:	6a 00                	push   $0x0
  pushl $43
  102352:	6a 2b                	push   $0x2b
  jmp __alltraps
  102354:	e9 f4 08 00 00       	jmp    102c4d <__alltraps>

00102359 <vector44>:
.globl vector44
vector44:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $44
  10235b:	6a 2c                	push   $0x2c
  jmp __alltraps
  10235d:	e9 eb 08 00 00       	jmp    102c4d <__alltraps>

00102362 <vector45>:
.globl vector45
vector45:
  pushl $0
  102362:	6a 00                	push   $0x0
  pushl $45
  102364:	6a 2d                	push   $0x2d
  jmp __alltraps
  102366:	e9 e2 08 00 00       	jmp    102c4d <__alltraps>

0010236b <vector46>:
.globl vector46
vector46:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $46
  10236d:	6a 2e                	push   $0x2e
  jmp __alltraps
  10236f:	e9 d9 08 00 00       	jmp    102c4d <__alltraps>

00102374 <vector47>:
.globl vector47
vector47:
  pushl $0
  102374:	6a 00                	push   $0x0
  pushl $47
  102376:	6a 2f                	push   $0x2f
  jmp __alltraps
  102378:	e9 d0 08 00 00       	jmp    102c4d <__alltraps>

0010237d <vector48>:
.globl vector48
vector48:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $48
  10237f:	6a 30                	push   $0x30
  jmp __alltraps
  102381:	e9 c7 08 00 00       	jmp    102c4d <__alltraps>

00102386 <vector49>:
.globl vector49
vector49:
  pushl $0
  102386:	6a 00                	push   $0x0
  pushl $49
  102388:	6a 31                	push   $0x31
  jmp __alltraps
  10238a:	e9 be 08 00 00       	jmp    102c4d <__alltraps>

0010238f <vector50>:
.globl vector50
vector50:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $50
  102391:	6a 32                	push   $0x32
  jmp __alltraps
  102393:	e9 b5 08 00 00       	jmp    102c4d <__alltraps>

00102398 <vector51>:
.globl vector51
vector51:
  pushl $0
  102398:	6a 00                	push   $0x0
  pushl $51
  10239a:	6a 33                	push   $0x33
  jmp __alltraps
  10239c:	e9 ac 08 00 00       	jmp    102c4d <__alltraps>

001023a1 <vector52>:
.globl vector52
vector52:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $52
  1023a3:	6a 34                	push   $0x34
  jmp __alltraps
  1023a5:	e9 a3 08 00 00       	jmp    102c4d <__alltraps>

001023aa <vector53>:
.globl vector53
vector53:
  pushl $0
  1023aa:	6a 00                	push   $0x0
  pushl $53
  1023ac:	6a 35                	push   $0x35
  jmp __alltraps
  1023ae:	e9 9a 08 00 00       	jmp    102c4d <__alltraps>

001023b3 <vector54>:
.globl vector54
vector54:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $54
  1023b5:	6a 36                	push   $0x36
  jmp __alltraps
  1023b7:	e9 91 08 00 00       	jmp    102c4d <__alltraps>

001023bc <vector55>:
.globl vector55
vector55:
  pushl $0
  1023bc:	6a 00                	push   $0x0
  pushl $55
  1023be:	6a 37                	push   $0x37
  jmp __alltraps
  1023c0:	e9 88 08 00 00       	jmp    102c4d <__alltraps>

001023c5 <vector56>:
.globl vector56
vector56:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $56
  1023c7:	6a 38                	push   $0x38
  jmp __alltraps
  1023c9:	e9 7f 08 00 00       	jmp    102c4d <__alltraps>

001023ce <vector57>:
.globl vector57
vector57:
  pushl $0
  1023ce:	6a 00                	push   $0x0
  pushl $57
  1023d0:	6a 39                	push   $0x39
  jmp __alltraps
  1023d2:	e9 76 08 00 00       	jmp    102c4d <__alltraps>

001023d7 <vector58>:
.globl vector58
vector58:
  pushl $0
  1023d7:	6a 00                	push   $0x0
  pushl $58
  1023d9:	6a 3a                	push   $0x3a
  jmp __alltraps
  1023db:	e9 6d 08 00 00       	jmp    102c4d <__alltraps>

001023e0 <vector59>:
.globl vector59
vector59:
  pushl $0
  1023e0:	6a 00                	push   $0x0
  pushl $59
  1023e2:	6a 3b                	push   $0x3b
  jmp __alltraps
  1023e4:	e9 64 08 00 00       	jmp    102c4d <__alltraps>

001023e9 <vector60>:
.globl vector60
vector60:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $60
  1023eb:	6a 3c                	push   $0x3c
  jmp __alltraps
  1023ed:	e9 5b 08 00 00       	jmp    102c4d <__alltraps>

001023f2 <vector61>:
.globl vector61
vector61:
  pushl $0
  1023f2:	6a 00                	push   $0x0
  pushl $61
  1023f4:	6a 3d                	push   $0x3d
  jmp __alltraps
  1023f6:	e9 52 08 00 00       	jmp    102c4d <__alltraps>

001023fb <vector62>:
.globl vector62
vector62:
  pushl $0
  1023fb:	6a 00                	push   $0x0
  pushl $62
  1023fd:	6a 3e                	push   $0x3e
  jmp __alltraps
  1023ff:	e9 49 08 00 00       	jmp    102c4d <__alltraps>

00102404 <vector63>:
.globl vector63
vector63:
  pushl $0
  102404:	6a 00                	push   $0x0
  pushl $63
  102406:	6a 3f                	push   $0x3f
  jmp __alltraps
  102408:	e9 40 08 00 00       	jmp    102c4d <__alltraps>

0010240d <vector64>:
.globl vector64
vector64:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $64
  10240f:	6a 40                	push   $0x40
  jmp __alltraps
  102411:	e9 37 08 00 00       	jmp    102c4d <__alltraps>

00102416 <vector65>:
.globl vector65
vector65:
  pushl $0
  102416:	6a 00                	push   $0x0
  pushl $65
  102418:	6a 41                	push   $0x41
  jmp __alltraps
  10241a:	e9 2e 08 00 00       	jmp    102c4d <__alltraps>

0010241f <vector66>:
.globl vector66
vector66:
  pushl $0
  10241f:	6a 00                	push   $0x0
  pushl $66
  102421:	6a 42                	push   $0x42
  jmp __alltraps
  102423:	e9 25 08 00 00       	jmp    102c4d <__alltraps>

00102428 <vector67>:
.globl vector67
vector67:
  pushl $0
  102428:	6a 00                	push   $0x0
  pushl $67
  10242a:	6a 43                	push   $0x43
  jmp __alltraps
  10242c:	e9 1c 08 00 00       	jmp    102c4d <__alltraps>

00102431 <vector68>:
.globl vector68
vector68:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $68
  102433:	6a 44                	push   $0x44
  jmp __alltraps
  102435:	e9 13 08 00 00       	jmp    102c4d <__alltraps>

0010243a <vector69>:
.globl vector69
vector69:
  pushl $0
  10243a:	6a 00                	push   $0x0
  pushl $69
  10243c:	6a 45                	push   $0x45
  jmp __alltraps
  10243e:	e9 0a 08 00 00       	jmp    102c4d <__alltraps>

00102443 <vector70>:
.globl vector70
vector70:
  pushl $0
  102443:	6a 00                	push   $0x0
  pushl $70
  102445:	6a 46                	push   $0x46
  jmp __alltraps
  102447:	e9 01 08 00 00       	jmp    102c4d <__alltraps>

0010244c <vector71>:
.globl vector71
vector71:
  pushl $0
  10244c:	6a 00                	push   $0x0
  pushl $71
  10244e:	6a 47                	push   $0x47
  jmp __alltraps
  102450:	e9 f8 07 00 00       	jmp    102c4d <__alltraps>

00102455 <vector72>:
.globl vector72
vector72:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $72
  102457:	6a 48                	push   $0x48
  jmp __alltraps
  102459:	e9 ef 07 00 00       	jmp    102c4d <__alltraps>

0010245e <vector73>:
.globl vector73
vector73:
  pushl $0
  10245e:	6a 00                	push   $0x0
  pushl $73
  102460:	6a 49                	push   $0x49
  jmp __alltraps
  102462:	e9 e6 07 00 00       	jmp    102c4d <__alltraps>

00102467 <vector74>:
.globl vector74
vector74:
  pushl $0
  102467:	6a 00                	push   $0x0
  pushl $74
  102469:	6a 4a                	push   $0x4a
  jmp __alltraps
  10246b:	e9 dd 07 00 00       	jmp    102c4d <__alltraps>

00102470 <vector75>:
.globl vector75
vector75:
  pushl $0
  102470:	6a 00                	push   $0x0
  pushl $75
  102472:	6a 4b                	push   $0x4b
  jmp __alltraps
  102474:	e9 d4 07 00 00       	jmp    102c4d <__alltraps>

00102479 <vector76>:
.globl vector76
vector76:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $76
  10247b:	6a 4c                	push   $0x4c
  jmp __alltraps
  10247d:	e9 cb 07 00 00       	jmp    102c4d <__alltraps>

00102482 <vector77>:
.globl vector77
vector77:
  pushl $0
  102482:	6a 00                	push   $0x0
  pushl $77
  102484:	6a 4d                	push   $0x4d
  jmp __alltraps
  102486:	e9 c2 07 00 00       	jmp    102c4d <__alltraps>

0010248b <vector78>:
.globl vector78
vector78:
  pushl $0
  10248b:	6a 00                	push   $0x0
  pushl $78
  10248d:	6a 4e                	push   $0x4e
  jmp __alltraps
  10248f:	e9 b9 07 00 00       	jmp    102c4d <__alltraps>

00102494 <vector79>:
.globl vector79
vector79:
  pushl $0
  102494:	6a 00                	push   $0x0
  pushl $79
  102496:	6a 4f                	push   $0x4f
  jmp __alltraps
  102498:	e9 b0 07 00 00       	jmp    102c4d <__alltraps>

0010249d <vector80>:
.globl vector80
vector80:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $80
  10249f:	6a 50                	push   $0x50
  jmp __alltraps
  1024a1:	e9 a7 07 00 00       	jmp    102c4d <__alltraps>

001024a6 <vector81>:
.globl vector81
vector81:
  pushl $0
  1024a6:	6a 00                	push   $0x0
  pushl $81
  1024a8:	6a 51                	push   $0x51
  jmp __alltraps
  1024aa:	e9 9e 07 00 00       	jmp    102c4d <__alltraps>

001024af <vector82>:
.globl vector82
vector82:
  pushl $0
  1024af:	6a 00                	push   $0x0
  pushl $82
  1024b1:	6a 52                	push   $0x52
  jmp __alltraps
  1024b3:	e9 95 07 00 00       	jmp    102c4d <__alltraps>

001024b8 <vector83>:
.globl vector83
vector83:
  pushl $0
  1024b8:	6a 00                	push   $0x0
  pushl $83
  1024ba:	6a 53                	push   $0x53
  jmp __alltraps
  1024bc:	e9 8c 07 00 00       	jmp    102c4d <__alltraps>

001024c1 <vector84>:
.globl vector84
vector84:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $84
  1024c3:	6a 54                	push   $0x54
  jmp __alltraps
  1024c5:	e9 83 07 00 00       	jmp    102c4d <__alltraps>

001024ca <vector85>:
.globl vector85
vector85:
  pushl $0
  1024ca:	6a 00                	push   $0x0
  pushl $85
  1024cc:	6a 55                	push   $0x55
  jmp __alltraps
  1024ce:	e9 7a 07 00 00       	jmp    102c4d <__alltraps>

001024d3 <vector86>:
.globl vector86
vector86:
  pushl $0
  1024d3:	6a 00                	push   $0x0
  pushl $86
  1024d5:	6a 56                	push   $0x56
  jmp __alltraps
  1024d7:	e9 71 07 00 00       	jmp    102c4d <__alltraps>

001024dc <vector87>:
.globl vector87
vector87:
  pushl $0
  1024dc:	6a 00                	push   $0x0
  pushl $87
  1024de:	6a 57                	push   $0x57
  jmp __alltraps
  1024e0:	e9 68 07 00 00       	jmp    102c4d <__alltraps>

001024e5 <vector88>:
.globl vector88
vector88:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $88
  1024e7:	6a 58                	push   $0x58
  jmp __alltraps
  1024e9:	e9 5f 07 00 00       	jmp    102c4d <__alltraps>

001024ee <vector89>:
.globl vector89
vector89:
  pushl $0
  1024ee:	6a 00                	push   $0x0
  pushl $89
  1024f0:	6a 59                	push   $0x59
  jmp __alltraps
  1024f2:	e9 56 07 00 00       	jmp    102c4d <__alltraps>

001024f7 <vector90>:
.globl vector90
vector90:
  pushl $0
  1024f7:	6a 00                	push   $0x0
  pushl $90
  1024f9:	6a 5a                	push   $0x5a
  jmp __alltraps
  1024fb:	e9 4d 07 00 00       	jmp    102c4d <__alltraps>

00102500 <vector91>:
.globl vector91
vector91:
  pushl $0
  102500:	6a 00                	push   $0x0
  pushl $91
  102502:	6a 5b                	push   $0x5b
  jmp __alltraps
  102504:	e9 44 07 00 00       	jmp    102c4d <__alltraps>

00102509 <vector92>:
.globl vector92
vector92:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $92
  10250b:	6a 5c                	push   $0x5c
  jmp __alltraps
  10250d:	e9 3b 07 00 00       	jmp    102c4d <__alltraps>

00102512 <vector93>:
.globl vector93
vector93:
  pushl $0
  102512:	6a 00                	push   $0x0
  pushl $93
  102514:	6a 5d                	push   $0x5d
  jmp __alltraps
  102516:	e9 32 07 00 00       	jmp    102c4d <__alltraps>

0010251b <vector94>:
.globl vector94
vector94:
  pushl $0
  10251b:	6a 00                	push   $0x0
  pushl $94
  10251d:	6a 5e                	push   $0x5e
  jmp __alltraps
  10251f:	e9 29 07 00 00       	jmp    102c4d <__alltraps>

00102524 <vector95>:
.globl vector95
vector95:
  pushl $0
  102524:	6a 00                	push   $0x0
  pushl $95
  102526:	6a 5f                	push   $0x5f
  jmp __alltraps
  102528:	e9 20 07 00 00       	jmp    102c4d <__alltraps>

0010252d <vector96>:
.globl vector96
vector96:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $96
  10252f:	6a 60                	push   $0x60
  jmp __alltraps
  102531:	e9 17 07 00 00       	jmp    102c4d <__alltraps>

00102536 <vector97>:
.globl vector97
vector97:
  pushl $0
  102536:	6a 00                	push   $0x0
  pushl $97
  102538:	6a 61                	push   $0x61
  jmp __alltraps
  10253a:	e9 0e 07 00 00       	jmp    102c4d <__alltraps>

0010253f <vector98>:
.globl vector98
vector98:
  pushl $0
  10253f:	6a 00                	push   $0x0
  pushl $98
  102541:	6a 62                	push   $0x62
  jmp __alltraps
  102543:	e9 05 07 00 00       	jmp    102c4d <__alltraps>

00102548 <vector99>:
.globl vector99
vector99:
  pushl $0
  102548:	6a 00                	push   $0x0
  pushl $99
  10254a:	6a 63                	push   $0x63
  jmp __alltraps
  10254c:	e9 fc 06 00 00       	jmp    102c4d <__alltraps>

00102551 <vector100>:
.globl vector100
vector100:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $100
  102553:	6a 64                	push   $0x64
  jmp __alltraps
  102555:	e9 f3 06 00 00       	jmp    102c4d <__alltraps>

0010255a <vector101>:
.globl vector101
vector101:
  pushl $0
  10255a:	6a 00                	push   $0x0
  pushl $101
  10255c:	6a 65                	push   $0x65
  jmp __alltraps
  10255e:	e9 ea 06 00 00       	jmp    102c4d <__alltraps>

00102563 <vector102>:
.globl vector102
vector102:
  pushl $0
  102563:	6a 00                	push   $0x0
  pushl $102
  102565:	6a 66                	push   $0x66
  jmp __alltraps
  102567:	e9 e1 06 00 00       	jmp    102c4d <__alltraps>

0010256c <vector103>:
.globl vector103
vector103:
  pushl $0
  10256c:	6a 00                	push   $0x0
  pushl $103
  10256e:	6a 67                	push   $0x67
  jmp __alltraps
  102570:	e9 d8 06 00 00       	jmp    102c4d <__alltraps>

00102575 <vector104>:
.globl vector104
vector104:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $104
  102577:	6a 68                	push   $0x68
  jmp __alltraps
  102579:	e9 cf 06 00 00       	jmp    102c4d <__alltraps>

0010257e <vector105>:
.globl vector105
vector105:
  pushl $0
  10257e:	6a 00                	push   $0x0
  pushl $105
  102580:	6a 69                	push   $0x69
  jmp __alltraps
  102582:	e9 c6 06 00 00       	jmp    102c4d <__alltraps>

00102587 <vector106>:
.globl vector106
vector106:
  pushl $0
  102587:	6a 00                	push   $0x0
  pushl $106
  102589:	6a 6a                	push   $0x6a
  jmp __alltraps
  10258b:	e9 bd 06 00 00       	jmp    102c4d <__alltraps>

00102590 <vector107>:
.globl vector107
vector107:
  pushl $0
  102590:	6a 00                	push   $0x0
  pushl $107
  102592:	6a 6b                	push   $0x6b
  jmp __alltraps
  102594:	e9 b4 06 00 00       	jmp    102c4d <__alltraps>

00102599 <vector108>:
.globl vector108
vector108:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $108
  10259b:	6a 6c                	push   $0x6c
  jmp __alltraps
  10259d:	e9 ab 06 00 00       	jmp    102c4d <__alltraps>

001025a2 <vector109>:
.globl vector109
vector109:
  pushl $0
  1025a2:	6a 00                	push   $0x0
  pushl $109
  1025a4:	6a 6d                	push   $0x6d
  jmp __alltraps
  1025a6:	e9 a2 06 00 00       	jmp    102c4d <__alltraps>

001025ab <vector110>:
.globl vector110
vector110:
  pushl $0
  1025ab:	6a 00                	push   $0x0
  pushl $110
  1025ad:	6a 6e                	push   $0x6e
  jmp __alltraps
  1025af:	e9 99 06 00 00       	jmp    102c4d <__alltraps>

001025b4 <vector111>:
.globl vector111
vector111:
  pushl $0
  1025b4:	6a 00                	push   $0x0
  pushl $111
  1025b6:	6a 6f                	push   $0x6f
  jmp __alltraps
  1025b8:	e9 90 06 00 00       	jmp    102c4d <__alltraps>

001025bd <vector112>:
.globl vector112
vector112:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $112
  1025bf:	6a 70                	push   $0x70
  jmp __alltraps
  1025c1:	e9 87 06 00 00       	jmp    102c4d <__alltraps>

001025c6 <vector113>:
.globl vector113
vector113:
  pushl $0
  1025c6:	6a 00                	push   $0x0
  pushl $113
  1025c8:	6a 71                	push   $0x71
  jmp __alltraps
  1025ca:	e9 7e 06 00 00       	jmp    102c4d <__alltraps>

001025cf <vector114>:
.globl vector114
vector114:
  pushl $0
  1025cf:	6a 00                	push   $0x0
  pushl $114
  1025d1:	6a 72                	push   $0x72
  jmp __alltraps
  1025d3:	e9 75 06 00 00       	jmp    102c4d <__alltraps>

001025d8 <vector115>:
.globl vector115
vector115:
  pushl $0
  1025d8:	6a 00                	push   $0x0
  pushl $115
  1025da:	6a 73                	push   $0x73
  jmp __alltraps
  1025dc:	e9 6c 06 00 00       	jmp    102c4d <__alltraps>

001025e1 <vector116>:
.globl vector116
vector116:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $116
  1025e3:	6a 74                	push   $0x74
  jmp __alltraps
  1025e5:	e9 63 06 00 00       	jmp    102c4d <__alltraps>

001025ea <vector117>:
.globl vector117
vector117:
  pushl $0
  1025ea:	6a 00                	push   $0x0
  pushl $117
  1025ec:	6a 75                	push   $0x75
  jmp __alltraps
  1025ee:	e9 5a 06 00 00       	jmp    102c4d <__alltraps>

001025f3 <vector118>:
.globl vector118
vector118:
  pushl $0
  1025f3:	6a 00                	push   $0x0
  pushl $118
  1025f5:	6a 76                	push   $0x76
  jmp __alltraps
  1025f7:	e9 51 06 00 00       	jmp    102c4d <__alltraps>

001025fc <vector119>:
.globl vector119
vector119:
  pushl $0
  1025fc:	6a 00                	push   $0x0
  pushl $119
  1025fe:	6a 77                	push   $0x77
  jmp __alltraps
  102600:	e9 48 06 00 00       	jmp    102c4d <__alltraps>

00102605 <vector120>:
.globl vector120
vector120:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $120
  102607:	6a 78                	push   $0x78
  jmp __alltraps
  102609:	e9 3f 06 00 00       	jmp    102c4d <__alltraps>

0010260e <vector121>:
.globl vector121
vector121:
  pushl $0
  10260e:	6a 00                	push   $0x0
  pushl $121
  102610:	6a 79                	push   $0x79
  jmp __alltraps
  102612:	e9 36 06 00 00       	jmp    102c4d <__alltraps>

00102617 <vector122>:
.globl vector122
vector122:
  pushl $0
  102617:	6a 00                	push   $0x0
  pushl $122
  102619:	6a 7a                	push   $0x7a
  jmp __alltraps
  10261b:	e9 2d 06 00 00       	jmp    102c4d <__alltraps>

00102620 <vector123>:
.globl vector123
vector123:
  pushl $0
  102620:	6a 00                	push   $0x0
  pushl $123
  102622:	6a 7b                	push   $0x7b
  jmp __alltraps
  102624:	e9 24 06 00 00       	jmp    102c4d <__alltraps>

00102629 <vector124>:
.globl vector124
vector124:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $124
  10262b:	6a 7c                	push   $0x7c
  jmp __alltraps
  10262d:	e9 1b 06 00 00       	jmp    102c4d <__alltraps>

00102632 <vector125>:
.globl vector125
vector125:
  pushl $0
  102632:	6a 00                	push   $0x0
  pushl $125
  102634:	6a 7d                	push   $0x7d
  jmp __alltraps
  102636:	e9 12 06 00 00       	jmp    102c4d <__alltraps>

0010263b <vector126>:
.globl vector126
vector126:
  pushl $0
  10263b:	6a 00                	push   $0x0
  pushl $126
  10263d:	6a 7e                	push   $0x7e
  jmp __alltraps
  10263f:	e9 09 06 00 00       	jmp    102c4d <__alltraps>

00102644 <vector127>:
.globl vector127
vector127:
  pushl $0
  102644:	6a 00                	push   $0x0
  pushl $127
  102646:	6a 7f                	push   $0x7f
  jmp __alltraps
  102648:	e9 00 06 00 00       	jmp    102c4d <__alltraps>

0010264d <vector128>:
.globl vector128
vector128:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $128
  10264f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102654:	e9 f4 05 00 00       	jmp    102c4d <__alltraps>

00102659 <vector129>:
.globl vector129
vector129:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $129
  10265b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102660:	e9 e8 05 00 00       	jmp    102c4d <__alltraps>

00102665 <vector130>:
.globl vector130
vector130:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $130
  102667:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10266c:	e9 dc 05 00 00       	jmp    102c4d <__alltraps>

00102671 <vector131>:
.globl vector131
vector131:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $131
  102673:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102678:	e9 d0 05 00 00       	jmp    102c4d <__alltraps>

0010267d <vector132>:
.globl vector132
vector132:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $132
  10267f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102684:	e9 c4 05 00 00       	jmp    102c4d <__alltraps>

00102689 <vector133>:
.globl vector133
vector133:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $133
  10268b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102690:	e9 b8 05 00 00       	jmp    102c4d <__alltraps>

00102695 <vector134>:
.globl vector134
vector134:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $134
  102697:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10269c:	e9 ac 05 00 00       	jmp    102c4d <__alltraps>

001026a1 <vector135>:
.globl vector135
vector135:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $135
  1026a3:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1026a8:	e9 a0 05 00 00       	jmp    102c4d <__alltraps>

001026ad <vector136>:
.globl vector136
vector136:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $136
  1026af:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1026b4:	e9 94 05 00 00       	jmp    102c4d <__alltraps>

001026b9 <vector137>:
.globl vector137
vector137:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $137
  1026bb:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1026c0:	e9 88 05 00 00       	jmp    102c4d <__alltraps>

001026c5 <vector138>:
.globl vector138
vector138:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $138
  1026c7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1026cc:	e9 7c 05 00 00       	jmp    102c4d <__alltraps>

001026d1 <vector139>:
.globl vector139
vector139:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $139
  1026d3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1026d8:	e9 70 05 00 00       	jmp    102c4d <__alltraps>

001026dd <vector140>:
.globl vector140
vector140:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $140
  1026df:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1026e4:	e9 64 05 00 00       	jmp    102c4d <__alltraps>

001026e9 <vector141>:
.globl vector141
vector141:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $141
  1026eb:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1026f0:	e9 58 05 00 00       	jmp    102c4d <__alltraps>

001026f5 <vector142>:
.globl vector142
vector142:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $142
  1026f7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1026fc:	e9 4c 05 00 00       	jmp    102c4d <__alltraps>

00102701 <vector143>:
.globl vector143
vector143:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $143
  102703:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102708:	e9 40 05 00 00       	jmp    102c4d <__alltraps>

0010270d <vector144>:
.globl vector144
vector144:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $144
  10270f:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102714:	e9 34 05 00 00       	jmp    102c4d <__alltraps>

00102719 <vector145>:
.globl vector145
vector145:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $145
  10271b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102720:	e9 28 05 00 00       	jmp    102c4d <__alltraps>

00102725 <vector146>:
.globl vector146
vector146:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $146
  102727:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10272c:	e9 1c 05 00 00       	jmp    102c4d <__alltraps>

00102731 <vector147>:
.globl vector147
vector147:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $147
  102733:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102738:	e9 10 05 00 00       	jmp    102c4d <__alltraps>

0010273d <vector148>:
.globl vector148
vector148:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $148
  10273f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102744:	e9 04 05 00 00       	jmp    102c4d <__alltraps>

00102749 <vector149>:
.globl vector149
vector149:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $149
  10274b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102750:	e9 f8 04 00 00       	jmp    102c4d <__alltraps>

00102755 <vector150>:
.globl vector150
vector150:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $150
  102757:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10275c:	e9 ec 04 00 00       	jmp    102c4d <__alltraps>

00102761 <vector151>:
.globl vector151
vector151:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $151
  102763:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102768:	e9 e0 04 00 00       	jmp    102c4d <__alltraps>

0010276d <vector152>:
.globl vector152
vector152:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $152
  10276f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102774:	e9 d4 04 00 00       	jmp    102c4d <__alltraps>

00102779 <vector153>:
.globl vector153
vector153:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $153
  10277b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102780:	e9 c8 04 00 00       	jmp    102c4d <__alltraps>

00102785 <vector154>:
.globl vector154
vector154:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $154
  102787:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10278c:	e9 bc 04 00 00       	jmp    102c4d <__alltraps>

00102791 <vector155>:
.globl vector155
vector155:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $155
  102793:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102798:	e9 b0 04 00 00       	jmp    102c4d <__alltraps>

0010279d <vector156>:
.globl vector156
vector156:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $156
  10279f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1027a4:	e9 a4 04 00 00       	jmp    102c4d <__alltraps>

001027a9 <vector157>:
.globl vector157
vector157:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $157
  1027ab:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1027b0:	e9 98 04 00 00       	jmp    102c4d <__alltraps>

001027b5 <vector158>:
.globl vector158
vector158:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $158
  1027b7:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1027bc:	e9 8c 04 00 00       	jmp    102c4d <__alltraps>

001027c1 <vector159>:
.globl vector159
vector159:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $159
  1027c3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1027c8:	e9 80 04 00 00       	jmp    102c4d <__alltraps>

001027cd <vector160>:
.globl vector160
vector160:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $160
  1027cf:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1027d4:	e9 74 04 00 00       	jmp    102c4d <__alltraps>

001027d9 <vector161>:
.globl vector161
vector161:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $161
  1027db:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1027e0:	e9 68 04 00 00       	jmp    102c4d <__alltraps>

001027e5 <vector162>:
.globl vector162
vector162:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $162
  1027e7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1027ec:	e9 5c 04 00 00       	jmp    102c4d <__alltraps>

001027f1 <vector163>:
.globl vector163
vector163:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $163
  1027f3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1027f8:	e9 50 04 00 00       	jmp    102c4d <__alltraps>

001027fd <vector164>:
.globl vector164
vector164:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $164
  1027ff:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102804:	e9 44 04 00 00       	jmp    102c4d <__alltraps>

00102809 <vector165>:
.globl vector165
vector165:
  pushl $0
  102809:	6a 00                	push   $0x0
  pushl $165
  10280b:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102810:	e9 38 04 00 00       	jmp    102c4d <__alltraps>

00102815 <vector166>:
.globl vector166
vector166:
  pushl $0
  102815:	6a 00                	push   $0x0
  pushl $166
  102817:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10281c:	e9 2c 04 00 00       	jmp    102c4d <__alltraps>

00102821 <vector167>:
.globl vector167
vector167:
  pushl $0
  102821:	6a 00                	push   $0x0
  pushl $167
  102823:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102828:	e9 20 04 00 00       	jmp    102c4d <__alltraps>

0010282d <vector168>:
.globl vector168
vector168:
  pushl $0
  10282d:	6a 00                	push   $0x0
  pushl $168
  10282f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102834:	e9 14 04 00 00       	jmp    102c4d <__alltraps>

00102839 <vector169>:
.globl vector169
vector169:
  pushl $0
  102839:	6a 00                	push   $0x0
  pushl $169
  10283b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102840:	e9 08 04 00 00       	jmp    102c4d <__alltraps>

00102845 <vector170>:
.globl vector170
vector170:
  pushl $0
  102845:	6a 00                	push   $0x0
  pushl $170
  102847:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10284c:	e9 fc 03 00 00       	jmp    102c4d <__alltraps>

00102851 <vector171>:
.globl vector171
vector171:
  pushl $0
  102851:	6a 00                	push   $0x0
  pushl $171
  102853:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102858:	e9 f0 03 00 00       	jmp    102c4d <__alltraps>

0010285d <vector172>:
.globl vector172
vector172:
  pushl $0
  10285d:	6a 00                	push   $0x0
  pushl $172
  10285f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102864:	e9 e4 03 00 00       	jmp    102c4d <__alltraps>

00102869 <vector173>:
.globl vector173
vector173:
  pushl $0
  102869:	6a 00                	push   $0x0
  pushl $173
  10286b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102870:	e9 d8 03 00 00       	jmp    102c4d <__alltraps>

00102875 <vector174>:
.globl vector174
vector174:
  pushl $0
  102875:	6a 00                	push   $0x0
  pushl $174
  102877:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10287c:	e9 cc 03 00 00       	jmp    102c4d <__alltraps>

00102881 <vector175>:
.globl vector175
vector175:
  pushl $0
  102881:	6a 00                	push   $0x0
  pushl $175
  102883:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102888:	e9 c0 03 00 00       	jmp    102c4d <__alltraps>

0010288d <vector176>:
.globl vector176
vector176:
  pushl $0
  10288d:	6a 00                	push   $0x0
  pushl $176
  10288f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102894:	e9 b4 03 00 00       	jmp    102c4d <__alltraps>

00102899 <vector177>:
.globl vector177
vector177:
  pushl $0
  102899:	6a 00                	push   $0x0
  pushl $177
  10289b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1028a0:	e9 a8 03 00 00       	jmp    102c4d <__alltraps>

001028a5 <vector178>:
.globl vector178
vector178:
  pushl $0
  1028a5:	6a 00                	push   $0x0
  pushl $178
  1028a7:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1028ac:	e9 9c 03 00 00       	jmp    102c4d <__alltraps>

001028b1 <vector179>:
.globl vector179
vector179:
  pushl $0
  1028b1:	6a 00                	push   $0x0
  pushl $179
  1028b3:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1028b8:	e9 90 03 00 00       	jmp    102c4d <__alltraps>

001028bd <vector180>:
.globl vector180
vector180:
  pushl $0
  1028bd:	6a 00                	push   $0x0
  pushl $180
  1028bf:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1028c4:	e9 84 03 00 00       	jmp    102c4d <__alltraps>

001028c9 <vector181>:
.globl vector181
vector181:
  pushl $0
  1028c9:	6a 00                	push   $0x0
  pushl $181
  1028cb:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1028d0:	e9 78 03 00 00       	jmp    102c4d <__alltraps>

001028d5 <vector182>:
.globl vector182
vector182:
  pushl $0
  1028d5:	6a 00                	push   $0x0
  pushl $182
  1028d7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1028dc:	e9 6c 03 00 00       	jmp    102c4d <__alltraps>

001028e1 <vector183>:
.globl vector183
vector183:
  pushl $0
  1028e1:	6a 00                	push   $0x0
  pushl $183
  1028e3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1028e8:	e9 60 03 00 00       	jmp    102c4d <__alltraps>

001028ed <vector184>:
.globl vector184
vector184:
  pushl $0
  1028ed:	6a 00                	push   $0x0
  pushl $184
  1028ef:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1028f4:	e9 54 03 00 00       	jmp    102c4d <__alltraps>

001028f9 <vector185>:
.globl vector185
vector185:
  pushl $0
  1028f9:	6a 00                	push   $0x0
  pushl $185
  1028fb:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102900:	e9 48 03 00 00       	jmp    102c4d <__alltraps>

00102905 <vector186>:
.globl vector186
vector186:
  pushl $0
  102905:	6a 00                	push   $0x0
  pushl $186
  102907:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10290c:	e9 3c 03 00 00       	jmp    102c4d <__alltraps>

00102911 <vector187>:
.globl vector187
vector187:
  pushl $0
  102911:	6a 00                	push   $0x0
  pushl $187
  102913:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102918:	e9 30 03 00 00       	jmp    102c4d <__alltraps>

0010291d <vector188>:
.globl vector188
vector188:
  pushl $0
  10291d:	6a 00                	push   $0x0
  pushl $188
  10291f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102924:	e9 24 03 00 00       	jmp    102c4d <__alltraps>

00102929 <vector189>:
.globl vector189
vector189:
  pushl $0
  102929:	6a 00                	push   $0x0
  pushl $189
  10292b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102930:	e9 18 03 00 00       	jmp    102c4d <__alltraps>

00102935 <vector190>:
.globl vector190
vector190:
  pushl $0
  102935:	6a 00                	push   $0x0
  pushl $190
  102937:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10293c:	e9 0c 03 00 00       	jmp    102c4d <__alltraps>

00102941 <vector191>:
.globl vector191
vector191:
  pushl $0
  102941:	6a 00                	push   $0x0
  pushl $191
  102943:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102948:	e9 00 03 00 00       	jmp    102c4d <__alltraps>

0010294d <vector192>:
.globl vector192
vector192:
  pushl $0
  10294d:	6a 00                	push   $0x0
  pushl $192
  10294f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102954:	e9 f4 02 00 00       	jmp    102c4d <__alltraps>

00102959 <vector193>:
.globl vector193
vector193:
  pushl $0
  102959:	6a 00                	push   $0x0
  pushl $193
  10295b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102960:	e9 e8 02 00 00       	jmp    102c4d <__alltraps>

00102965 <vector194>:
.globl vector194
vector194:
  pushl $0
  102965:	6a 00                	push   $0x0
  pushl $194
  102967:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10296c:	e9 dc 02 00 00       	jmp    102c4d <__alltraps>

00102971 <vector195>:
.globl vector195
vector195:
  pushl $0
  102971:	6a 00                	push   $0x0
  pushl $195
  102973:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102978:	e9 d0 02 00 00       	jmp    102c4d <__alltraps>

0010297d <vector196>:
.globl vector196
vector196:
  pushl $0
  10297d:	6a 00                	push   $0x0
  pushl $196
  10297f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102984:	e9 c4 02 00 00       	jmp    102c4d <__alltraps>

00102989 <vector197>:
.globl vector197
vector197:
  pushl $0
  102989:	6a 00                	push   $0x0
  pushl $197
  10298b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102990:	e9 b8 02 00 00       	jmp    102c4d <__alltraps>

00102995 <vector198>:
.globl vector198
vector198:
  pushl $0
  102995:	6a 00                	push   $0x0
  pushl $198
  102997:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10299c:	e9 ac 02 00 00       	jmp    102c4d <__alltraps>

001029a1 <vector199>:
.globl vector199
vector199:
  pushl $0
  1029a1:	6a 00                	push   $0x0
  pushl $199
  1029a3:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1029a8:	e9 a0 02 00 00       	jmp    102c4d <__alltraps>

001029ad <vector200>:
.globl vector200
vector200:
  pushl $0
  1029ad:	6a 00                	push   $0x0
  pushl $200
  1029af:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1029b4:	e9 94 02 00 00       	jmp    102c4d <__alltraps>

001029b9 <vector201>:
.globl vector201
vector201:
  pushl $0
  1029b9:	6a 00                	push   $0x0
  pushl $201
  1029bb:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1029c0:	e9 88 02 00 00       	jmp    102c4d <__alltraps>

001029c5 <vector202>:
.globl vector202
vector202:
  pushl $0
  1029c5:	6a 00                	push   $0x0
  pushl $202
  1029c7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1029cc:	e9 7c 02 00 00       	jmp    102c4d <__alltraps>

001029d1 <vector203>:
.globl vector203
vector203:
  pushl $0
  1029d1:	6a 00                	push   $0x0
  pushl $203
  1029d3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1029d8:	e9 70 02 00 00       	jmp    102c4d <__alltraps>

001029dd <vector204>:
.globl vector204
vector204:
  pushl $0
  1029dd:	6a 00                	push   $0x0
  pushl $204
  1029df:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1029e4:	e9 64 02 00 00       	jmp    102c4d <__alltraps>

001029e9 <vector205>:
.globl vector205
vector205:
  pushl $0
  1029e9:	6a 00                	push   $0x0
  pushl $205
  1029eb:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1029f0:	e9 58 02 00 00       	jmp    102c4d <__alltraps>

001029f5 <vector206>:
.globl vector206
vector206:
  pushl $0
  1029f5:	6a 00                	push   $0x0
  pushl $206
  1029f7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1029fc:	e9 4c 02 00 00       	jmp    102c4d <__alltraps>

00102a01 <vector207>:
.globl vector207
vector207:
  pushl $0
  102a01:	6a 00                	push   $0x0
  pushl $207
  102a03:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102a08:	e9 40 02 00 00       	jmp    102c4d <__alltraps>

00102a0d <vector208>:
.globl vector208
vector208:
  pushl $0
  102a0d:	6a 00                	push   $0x0
  pushl $208
  102a0f:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102a14:	e9 34 02 00 00       	jmp    102c4d <__alltraps>

00102a19 <vector209>:
.globl vector209
vector209:
  pushl $0
  102a19:	6a 00                	push   $0x0
  pushl $209
  102a1b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102a20:	e9 28 02 00 00       	jmp    102c4d <__alltraps>

00102a25 <vector210>:
.globl vector210
vector210:
  pushl $0
  102a25:	6a 00                	push   $0x0
  pushl $210
  102a27:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102a2c:	e9 1c 02 00 00       	jmp    102c4d <__alltraps>

00102a31 <vector211>:
.globl vector211
vector211:
  pushl $0
  102a31:	6a 00                	push   $0x0
  pushl $211
  102a33:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102a38:	e9 10 02 00 00       	jmp    102c4d <__alltraps>

00102a3d <vector212>:
.globl vector212
vector212:
  pushl $0
  102a3d:	6a 00                	push   $0x0
  pushl $212
  102a3f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102a44:	e9 04 02 00 00       	jmp    102c4d <__alltraps>

00102a49 <vector213>:
.globl vector213
vector213:
  pushl $0
  102a49:	6a 00                	push   $0x0
  pushl $213
  102a4b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102a50:	e9 f8 01 00 00       	jmp    102c4d <__alltraps>

00102a55 <vector214>:
.globl vector214
vector214:
  pushl $0
  102a55:	6a 00                	push   $0x0
  pushl $214
  102a57:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102a5c:	e9 ec 01 00 00       	jmp    102c4d <__alltraps>

00102a61 <vector215>:
.globl vector215
vector215:
  pushl $0
  102a61:	6a 00                	push   $0x0
  pushl $215
  102a63:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102a68:	e9 e0 01 00 00       	jmp    102c4d <__alltraps>

00102a6d <vector216>:
.globl vector216
vector216:
  pushl $0
  102a6d:	6a 00                	push   $0x0
  pushl $216
  102a6f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102a74:	e9 d4 01 00 00       	jmp    102c4d <__alltraps>

00102a79 <vector217>:
.globl vector217
vector217:
  pushl $0
  102a79:	6a 00                	push   $0x0
  pushl $217
  102a7b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102a80:	e9 c8 01 00 00       	jmp    102c4d <__alltraps>

00102a85 <vector218>:
.globl vector218
vector218:
  pushl $0
  102a85:	6a 00                	push   $0x0
  pushl $218
  102a87:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102a8c:	e9 bc 01 00 00       	jmp    102c4d <__alltraps>

00102a91 <vector219>:
.globl vector219
vector219:
  pushl $0
  102a91:	6a 00                	push   $0x0
  pushl $219
  102a93:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102a98:	e9 b0 01 00 00       	jmp    102c4d <__alltraps>

00102a9d <vector220>:
.globl vector220
vector220:
  pushl $0
  102a9d:	6a 00                	push   $0x0
  pushl $220
  102a9f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102aa4:	e9 a4 01 00 00       	jmp    102c4d <__alltraps>

00102aa9 <vector221>:
.globl vector221
vector221:
  pushl $0
  102aa9:	6a 00                	push   $0x0
  pushl $221
  102aab:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102ab0:	e9 98 01 00 00       	jmp    102c4d <__alltraps>

00102ab5 <vector222>:
.globl vector222
vector222:
  pushl $0
  102ab5:	6a 00                	push   $0x0
  pushl $222
  102ab7:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102abc:	e9 8c 01 00 00       	jmp    102c4d <__alltraps>

00102ac1 <vector223>:
.globl vector223
vector223:
  pushl $0
  102ac1:	6a 00                	push   $0x0
  pushl $223
  102ac3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102ac8:	e9 80 01 00 00       	jmp    102c4d <__alltraps>

00102acd <vector224>:
.globl vector224
vector224:
  pushl $0
  102acd:	6a 00                	push   $0x0
  pushl $224
  102acf:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102ad4:	e9 74 01 00 00       	jmp    102c4d <__alltraps>

00102ad9 <vector225>:
.globl vector225
vector225:
  pushl $0
  102ad9:	6a 00                	push   $0x0
  pushl $225
  102adb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102ae0:	e9 68 01 00 00       	jmp    102c4d <__alltraps>

00102ae5 <vector226>:
.globl vector226
vector226:
  pushl $0
  102ae5:	6a 00                	push   $0x0
  pushl $226
  102ae7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102aec:	e9 5c 01 00 00       	jmp    102c4d <__alltraps>

00102af1 <vector227>:
.globl vector227
vector227:
  pushl $0
  102af1:	6a 00                	push   $0x0
  pushl $227
  102af3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102af8:	e9 50 01 00 00       	jmp    102c4d <__alltraps>

00102afd <vector228>:
.globl vector228
vector228:
  pushl $0
  102afd:	6a 00                	push   $0x0
  pushl $228
  102aff:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102b04:	e9 44 01 00 00       	jmp    102c4d <__alltraps>

00102b09 <vector229>:
.globl vector229
vector229:
  pushl $0
  102b09:	6a 00                	push   $0x0
  pushl $229
  102b0b:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102b10:	e9 38 01 00 00       	jmp    102c4d <__alltraps>

00102b15 <vector230>:
.globl vector230
vector230:
  pushl $0
  102b15:	6a 00                	push   $0x0
  pushl $230
  102b17:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102b1c:	e9 2c 01 00 00       	jmp    102c4d <__alltraps>

00102b21 <vector231>:
.globl vector231
vector231:
  pushl $0
  102b21:	6a 00                	push   $0x0
  pushl $231
  102b23:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102b28:	e9 20 01 00 00       	jmp    102c4d <__alltraps>

00102b2d <vector232>:
.globl vector232
vector232:
  pushl $0
  102b2d:	6a 00                	push   $0x0
  pushl $232
  102b2f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102b34:	e9 14 01 00 00       	jmp    102c4d <__alltraps>

00102b39 <vector233>:
.globl vector233
vector233:
  pushl $0
  102b39:	6a 00                	push   $0x0
  pushl $233
  102b3b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102b40:	e9 08 01 00 00       	jmp    102c4d <__alltraps>

00102b45 <vector234>:
.globl vector234
vector234:
  pushl $0
  102b45:	6a 00                	push   $0x0
  pushl $234
  102b47:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102b4c:	e9 fc 00 00 00       	jmp    102c4d <__alltraps>

00102b51 <vector235>:
.globl vector235
vector235:
  pushl $0
  102b51:	6a 00                	push   $0x0
  pushl $235
  102b53:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102b58:	e9 f0 00 00 00       	jmp    102c4d <__alltraps>

00102b5d <vector236>:
.globl vector236
vector236:
  pushl $0
  102b5d:	6a 00                	push   $0x0
  pushl $236
  102b5f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102b64:	e9 e4 00 00 00       	jmp    102c4d <__alltraps>

00102b69 <vector237>:
.globl vector237
vector237:
  pushl $0
  102b69:	6a 00                	push   $0x0
  pushl $237
  102b6b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102b70:	e9 d8 00 00 00       	jmp    102c4d <__alltraps>

00102b75 <vector238>:
.globl vector238
vector238:
  pushl $0
  102b75:	6a 00                	push   $0x0
  pushl $238
  102b77:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102b7c:	e9 cc 00 00 00       	jmp    102c4d <__alltraps>

00102b81 <vector239>:
.globl vector239
vector239:
  pushl $0
  102b81:	6a 00                	push   $0x0
  pushl $239
  102b83:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102b88:	e9 c0 00 00 00       	jmp    102c4d <__alltraps>

00102b8d <vector240>:
.globl vector240
vector240:
  pushl $0
  102b8d:	6a 00                	push   $0x0
  pushl $240
  102b8f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102b94:	e9 b4 00 00 00       	jmp    102c4d <__alltraps>

00102b99 <vector241>:
.globl vector241
vector241:
  pushl $0
  102b99:	6a 00                	push   $0x0
  pushl $241
  102b9b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102ba0:	e9 a8 00 00 00       	jmp    102c4d <__alltraps>

00102ba5 <vector242>:
.globl vector242
vector242:
  pushl $0
  102ba5:	6a 00                	push   $0x0
  pushl $242
  102ba7:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102bac:	e9 9c 00 00 00       	jmp    102c4d <__alltraps>

00102bb1 <vector243>:
.globl vector243
vector243:
  pushl $0
  102bb1:	6a 00                	push   $0x0
  pushl $243
  102bb3:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102bb8:	e9 90 00 00 00       	jmp    102c4d <__alltraps>

00102bbd <vector244>:
.globl vector244
vector244:
  pushl $0
  102bbd:	6a 00                	push   $0x0
  pushl $244
  102bbf:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102bc4:	e9 84 00 00 00       	jmp    102c4d <__alltraps>

00102bc9 <vector245>:
.globl vector245
vector245:
  pushl $0
  102bc9:	6a 00                	push   $0x0
  pushl $245
  102bcb:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102bd0:	e9 78 00 00 00       	jmp    102c4d <__alltraps>

00102bd5 <vector246>:
.globl vector246
vector246:
  pushl $0
  102bd5:	6a 00                	push   $0x0
  pushl $246
  102bd7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102bdc:	e9 6c 00 00 00       	jmp    102c4d <__alltraps>

00102be1 <vector247>:
.globl vector247
vector247:
  pushl $0
  102be1:	6a 00                	push   $0x0
  pushl $247
  102be3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102be8:	e9 60 00 00 00       	jmp    102c4d <__alltraps>

00102bed <vector248>:
.globl vector248
vector248:
  pushl $0
  102bed:	6a 00                	push   $0x0
  pushl $248
  102bef:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102bf4:	e9 54 00 00 00       	jmp    102c4d <__alltraps>

00102bf9 <vector249>:
.globl vector249
vector249:
  pushl $0
  102bf9:	6a 00                	push   $0x0
  pushl $249
  102bfb:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102c00:	e9 48 00 00 00       	jmp    102c4d <__alltraps>

00102c05 <vector250>:
.globl vector250
vector250:
  pushl $0
  102c05:	6a 00                	push   $0x0
  pushl $250
  102c07:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102c0c:	e9 3c 00 00 00       	jmp    102c4d <__alltraps>

00102c11 <vector251>:
.globl vector251
vector251:
  pushl $0
  102c11:	6a 00                	push   $0x0
  pushl $251
  102c13:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102c18:	e9 30 00 00 00       	jmp    102c4d <__alltraps>

00102c1d <vector252>:
.globl vector252
vector252:
  pushl $0
  102c1d:	6a 00                	push   $0x0
  pushl $252
  102c1f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102c24:	e9 24 00 00 00       	jmp    102c4d <__alltraps>

00102c29 <vector253>:
.globl vector253
vector253:
  pushl $0
  102c29:	6a 00                	push   $0x0
  pushl $253
  102c2b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102c30:	e9 18 00 00 00       	jmp    102c4d <__alltraps>

00102c35 <vector254>:
.globl vector254
vector254:
  pushl $0
  102c35:	6a 00                	push   $0x0
  pushl $254
  102c37:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102c3c:	e9 0c 00 00 00       	jmp    102c4d <__alltraps>

00102c41 <vector255>:
.globl vector255
vector255:
  pushl $0
  102c41:	6a 00                	push   $0x0
  pushl $255
  102c43:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102c48:	e9 00 00 00 00       	jmp    102c4d <__alltraps>

00102c4d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102c4d:	1e                   	push   %ds
    pushl %es
  102c4e:	06                   	push   %es
    pushl %fs
  102c4f:	0f a0                	push   %fs
    pushl %gs
  102c51:	0f a8                	push   %gs
    pushal
  102c53:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102c54:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102c59:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102c5b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102c5d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102c5e:	e8 59 f5 ff ff       	call   1021bc <trap>

    # pop the pushed stack pointer
    popl %esp
  102c63:	5c                   	pop    %esp

00102c64 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102c64:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102c65:	0f a9                	pop    %gs
    popl %fs
  102c67:	0f a1                	pop    %fs
    popl %es
  102c69:	07                   	pop    %es
    popl %ds
  102c6a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102c6b:	83 c4 08             	add    $0x8,%esp
    iret
  102c6e:	cf                   	iret   

00102c6f <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102c6f:	55                   	push   %ebp
  102c70:	89 e5                	mov    %esp,%ebp
  102c72:	e8 05 d6 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102c77:	05 d9 bc 00 00       	add    $0xbcd9,%eax
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  102c7f:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102c82:	b8 23 00 00 00       	mov    $0x23,%eax
  102c87:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102c89:	b8 23 00 00 00       	mov    $0x23,%eax
  102c8e:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102c90:	b8 10 00 00 00       	mov    $0x10,%eax
  102c95:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102c97:	b8 10 00 00 00       	mov    $0x10,%eax
  102c9c:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102c9e:	b8 10 00 00 00       	mov    $0x10,%eax
  102ca3:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102ca5:	ea ac 2c 10 00 08 00 	ljmp   $0x8,$0x102cac
}
  102cac:	90                   	nop
  102cad:	5d                   	pop    %ebp
  102cae:	c3                   	ret    

00102caf <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102caf:	55                   	push   %ebp
  102cb0:	89 e5                	mov    %esp,%ebp
  102cb2:	83 ec 10             	sub    $0x10,%esp
  102cb5:	e8 c2 d5 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102cba:	05 96 bc 00 00       	add    $0xbc96,%eax
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102cbf:	c7 c2 c0 f9 10 00    	mov    $0x10f9c0,%edx
  102cc5:	81 c2 00 04 00 00    	add    $0x400,%edx
  102ccb:	89 90 f4 0f 00 00    	mov    %edx,0xff4(%eax)
    ts.ts_ss0 = KERNEL_DS;
  102cd1:	66 c7 80 f8 0f 00 00 	movw   $0x10,0xff8(%eax)
  102cd8:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102cda:	66 c7 80 f8 ff ff ff 	movw   $0x68,-0x8(%eax)
  102ce1:	68 00 
  102ce3:	8d 90 f0 0f 00 00    	lea    0xff0(%eax),%edx
  102ce9:	66 89 90 fa ff ff ff 	mov    %dx,-0x6(%eax)
  102cf0:	8d 90 f0 0f 00 00    	lea    0xff0(%eax),%edx
  102cf6:	c1 ea 10             	shr    $0x10,%edx
  102cf9:	88 90 fc ff ff ff    	mov    %dl,-0x4(%eax)
  102cff:	0f b6 90 fd ff ff ff 	movzbl -0x3(%eax),%edx
  102d06:	83 e2 f0             	and    $0xfffffff0,%edx
  102d09:	83 ca 09             	or     $0x9,%edx
  102d0c:	88 90 fd ff ff ff    	mov    %dl,-0x3(%eax)
  102d12:	0f b6 90 fd ff ff ff 	movzbl -0x3(%eax),%edx
  102d19:	83 ca 10             	or     $0x10,%edx
  102d1c:	88 90 fd ff ff ff    	mov    %dl,-0x3(%eax)
  102d22:	0f b6 90 fd ff ff ff 	movzbl -0x3(%eax),%edx
  102d29:	83 e2 9f             	and    $0xffffff9f,%edx
  102d2c:	88 90 fd ff ff ff    	mov    %dl,-0x3(%eax)
  102d32:	0f b6 90 fd ff ff ff 	movzbl -0x3(%eax),%edx
  102d39:	83 ca 80             	or     $0xffffff80,%edx
  102d3c:	88 90 fd ff ff ff    	mov    %dl,-0x3(%eax)
  102d42:	0f b6 90 fe ff ff ff 	movzbl -0x2(%eax),%edx
  102d49:	83 e2 f0             	and    $0xfffffff0,%edx
  102d4c:	88 90 fe ff ff ff    	mov    %dl,-0x2(%eax)
  102d52:	0f b6 90 fe ff ff ff 	movzbl -0x2(%eax),%edx
  102d59:	83 e2 ef             	and    $0xffffffef,%edx
  102d5c:	88 90 fe ff ff ff    	mov    %dl,-0x2(%eax)
  102d62:	0f b6 90 fe ff ff ff 	movzbl -0x2(%eax),%edx
  102d69:	83 e2 df             	and    $0xffffffdf,%edx
  102d6c:	88 90 fe ff ff ff    	mov    %dl,-0x2(%eax)
  102d72:	0f b6 90 fe ff ff ff 	movzbl -0x2(%eax),%edx
  102d79:	83 ca 40             	or     $0x40,%edx
  102d7c:	88 90 fe ff ff ff    	mov    %dl,-0x2(%eax)
  102d82:	0f b6 90 fe ff ff ff 	movzbl -0x2(%eax),%edx
  102d89:	83 e2 7f             	and    $0x7f,%edx
  102d8c:	88 90 fe ff ff ff    	mov    %dl,-0x2(%eax)
  102d92:	8d 90 f0 0f 00 00    	lea    0xff0(%eax),%edx
  102d98:	c1 ea 18             	shr    $0x18,%edx
  102d9b:	88 90 ff ff ff ff    	mov    %dl,-0x1(%eax)
    gdt[SEG_TSS].sd_s = 0;
  102da1:	0f b6 90 fd ff ff ff 	movzbl -0x3(%eax),%edx
  102da8:	83 e2 ef             	and    $0xffffffef,%edx
  102dab:	88 90 fd ff ff ff    	mov    %dl,-0x3(%eax)

    // reload all segment registers
    lgdt(&gdt_pd);
  102db1:	8d 80 d0 00 00 00    	lea    0xd0(%eax),%eax
  102db7:	50                   	push   %eax
  102db8:	e8 b2 fe ff ff       	call   102c6f <lgdt>
  102dbd:	83 c4 04             	add    $0x4,%esp
  102dc0:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102dc6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102dca:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102dcd:	90                   	nop
  102dce:	c9                   	leave  
  102dcf:	c3                   	ret    

00102dd0 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102dd0:	55                   	push   %ebp
  102dd1:	89 e5                	mov    %esp,%ebp
  102dd3:	e8 a4 d4 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102dd8:	05 78 bb 00 00       	add    $0xbb78,%eax
    gdt_init();
  102ddd:	e8 cd fe ff ff       	call   102caf <gdt_init>
}
  102de2:	90                   	nop
  102de3:	5d                   	pop    %ebp
  102de4:	c3                   	ret    

00102de5 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102de5:	55                   	push   %ebp
  102de6:	89 e5                	mov    %esp,%ebp
  102de8:	83 ec 10             	sub    $0x10,%esp
  102deb:	e8 8c d4 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102df0:	05 60 bb 00 00       	add    $0xbb60,%eax
    size_t cnt = 0;
  102df5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102dfc:	eb 04                	jmp    102e02 <strlen+0x1d>
        cnt ++;
  102dfe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  102e02:	8b 45 08             	mov    0x8(%ebp),%eax
  102e05:	8d 50 01             	lea    0x1(%eax),%edx
  102e08:	89 55 08             	mov    %edx,0x8(%ebp)
  102e0b:	0f b6 00             	movzbl (%eax),%eax
  102e0e:	84 c0                	test   %al,%al
  102e10:	75 ec                	jne    102dfe <strlen+0x19>
    }
    return cnt;
  102e12:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102e15:	c9                   	leave  
  102e16:	c3                   	ret    

00102e17 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102e17:	55                   	push   %ebp
  102e18:	89 e5                	mov    %esp,%ebp
  102e1a:	83 ec 10             	sub    $0x10,%esp
  102e1d:	e8 5a d4 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102e22:	05 2e bb 00 00       	add    $0xbb2e,%eax
    size_t cnt = 0;
  102e27:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102e2e:	eb 04                	jmp    102e34 <strnlen+0x1d>
        cnt ++;
  102e30:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102e34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102e37:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102e3a:	73 10                	jae    102e4c <strnlen+0x35>
  102e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3f:	8d 50 01             	lea    0x1(%eax),%edx
  102e42:	89 55 08             	mov    %edx,0x8(%ebp)
  102e45:	0f b6 00             	movzbl (%eax),%eax
  102e48:	84 c0                	test   %al,%al
  102e4a:	75 e4                	jne    102e30 <strnlen+0x19>
    }
    return cnt;
  102e4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102e4f:	c9                   	leave  
  102e50:	c3                   	ret    

00102e51 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102e51:	55                   	push   %ebp
  102e52:	89 e5                	mov    %esp,%ebp
  102e54:	57                   	push   %edi
  102e55:	56                   	push   %esi
  102e56:	83 ec 20             	sub    $0x20,%esp
  102e59:	e8 1e d4 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102e5e:	05 f2 ba 00 00       	add    $0xbaf2,%eax
  102e63:	8b 45 08             	mov    0x8(%ebp),%eax
  102e66:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102e6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e75:	89 d1                	mov    %edx,%ecx
  102e77:	89 c2                	mov    %eax,%edx
  102e79:	89 ce                	mov    %ecx,%esi
  102e7b:	89 d7                	mov    %edx,%edi
  102e7d:	ac                   	lods   %ds:(%esi),%al
  102e7e:	aa                   	stos   %al,%es:(%edi)
  102e7f:	84 c0                	test   %al,%al
  102e81:	75 fa                	jne    102e7d <strcpy+0x2c>
  102e83:	89 fa                	mov    %edi,%edx
  102e85:	89 f1                	mov    %esi,%ecx
  102e87:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102e8a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102e8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  102e93:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102e94:	83 c4 20             	add    $0x20,%esp
  102e97:	5e                   	pop    %esi
  102e98:	5f                   	pop    %edi
  102e99:	5d                   	pop    %ebp
  102e9a:	c3                   	ret    

00102e9b <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102e9b:	55                   	push   %ebp
  102e9c:	89 e5                	mov    %esp,%ebp
  102e9e:	83 ec 10             	sub    $0x10,%esp
  102ea1:	e8 d6 d3 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102ea6:	05 aa ba 00 00       	add    $0xbaaa,%eax
    char *p = dst;
  102eab:	8b 45 08             	mov    0x8(%ebp),%eax
  102eae:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102eb1:	eb 21                	jmp    102ed4 <strncpy+0x39>
        if ((*p = *src) != '\0') {
  102eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb6:	0f b6 10             	movzbl (%eax),%edx
  102eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ebc:	88 10                	mov    %dl,(%eax)
  102ebe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ec1:	0f b6 00             	movzbl (%eax),%eax
  102ec4:	84 c0                	test   %al,%al
  102ec6:	74 04                	je     102ecc <strncpy+0x31>
            src ++;
  102ec8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  102ecc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102ed0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  102ed4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102ed8:	75 d9                	jne    102eb3 <strncpy+0x18>
    }
    return dst;
  102eda:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102edd:	c9                   	leave  
  102ede:	c3                   	ret    

00102edf <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102edf:	55                   	push   %ebp
  102ee0:	89 e5                	mov    %esp,%ebp
  102ee2:	57                   	push   %edi
  102ee3:	56                   	push   %esi
  102ee4:	83 ec 20             	sub    $0x20,%esp
  102ee7:	e8 90 d3 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102eec:	05 64 ba 00 00       	add    $0xba64,%eax
  102ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102efa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102efd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f03:	89 d1                	mov    %edx,%ecx
  102f05:	89 c2                	mov    %eax,%edx
  102f07:	89 ce                	mov    %ecx,%esi
  102f09:	89 d7                	mov    %edx,%edi
  102f0b:	ac                   	lods   %ds:(%esi),%al
  102f0c:	ae                   	scas   %es:(%edi),%al
  102f0d:	75 08                	jne    102f17 <strcmp+0x38>
  102f0f:	84 c0                	test   %al,%al
  102f11:	75 f8                	jne    102f0b <strcmp+0x2c>
  102f13:	31 c0                	xor    %eax,%eax
  102f15:	eb 04                	jmp    102f1b <strcmp+0x3c>
  102f17:	19 c0                	sbb    %eax,%eax
  102f19:	0c 01                	or     $0x1,%al
  102f1b:	89 fa                	mov    %edi,%edx
  102f1d:	89 f1                	mov    %esi,%ecx
  102f1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102f22:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102f25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102f2b:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102f2c:	83 c4 20             	add    $0x20,%esp
  102f2f:	5e                   	pop    %esi
  102f30:	5f                   	pop    %edi
  102f31:	5d                   	pop    %ebp
  102f32:	c3                   	ret    

00102f33 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102f33:	55                   	push   %ebp
  102f34:	89 e5                	mov    %esp,%ebp
  102f36:	e8 41 d3 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102f3b:	05 15 ba 00 00       	add    $0xba15,%eax
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102f40:	eb 0c                	jmp    102f4e <strncmp+0x1b>
        n --, s1 ++, s2 ++;
  102f42:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102f46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102f4a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102f4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102f52:	74 1a                	je     102f6e <strncmp+0x3b>
  102f54:	8b 45 08             	mov    0x8(%ebp),%eax
  102f57:	0f b6 00             	movzbl (%eax),%eax
  102f5a:	84 c0                	test   %al,%al
  102f5c:	74 10                	je     102f6e <strncmp+0x3b>
  102f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f61:	0f b6 10             	movzbl (%eax),%edx
  102f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f67:	0f b6 00             	movzbl (%eax),%eax
  102f6a:	38 c2                	cmp    %al,%dl
  102f6c:	74 d4                	je     102f42 <strncmp+0xf>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102f6e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102f72:	74 18                	je     102f8c <strncmp+0x59>
  102f74:	8b 45 08             	mov    0x8(%ebp),%eax
  102f77:	0f b6 00             	movzbl (%eax),%eax
  102f7a:	0f b6 d0             	movzbl %al,%edx
  102f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f80:	0f b6 00             	movzbl (%eax),%eax
  102f83:	0f b6 c0             	movzbl %al,%eax
  102f86:	29 c2                	sub    %eax,%edx
  102f88:	89 d0                	mov    %edx,%eax
  102f8a:	eb 05                	jmp    102f91 <strncmp+0x5e>
  102f8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102f91:	5d                   	pop    %ebp
  102f92:	c3                   	ret    

00102f93 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102f93:	55                   	push   %ebp
  102f94:	89 e5                	mov    %esp,%ebp
  102f96:	83 ec 04             	sub    $0x4,%esp
  102f99:	e8 de d2 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102f9e:	05 b2 b9 00 00       	add    $0xb9b2,%eax
  102fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fa6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102fa9:	eb 14                	jmp    102fbf <strchr+0x2c>
        if (*s == c) {
  102fab:	8b 45 08             	mov    0x8(%ebp),%eax
  102fae:	0f b6 00             	movzbl (%eax),%eax
  102fb1:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102fb4:	75 05                	jne    102fbb <strchr+0x28>
            return (char *)s;
  102fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  102fb9:	eb 13                	jmp    102fce <strchr+0x3b>
        }
        s ++;
  102fbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  102fc2:	0f b6 00             	movzbl (%eax),%eax
  102fc5:	84 c0                	test   %al,%al
  102fc7:	75 e2                	jne    102fab <strchr+0x18>
    }
    return NULL;
  102fc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102fce:	c9                   	leave  
  102fcf:	c3                   	ret    

00102fd0 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102fd0:	55                   	push   %ebp
  102fd1:	89 e5                	mov    %esp,%ebp
  102fd3:	83 ec 04             	sub    $0x4,%esp
  102fd6:	e8 a1 d2 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  102fdb:	05 75 b9 00 00       	add    $0xb975,%eax
  102fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fe3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102fe6:	eb 0f                	jmp    102ff7 <strfind+0x27>
        if (*s == c) {
  102fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  102feb:	0f b6 00             	movzbl (%eax),%eax
  102fee:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102ff1:	74 10                	je     103003 <strfind+0x33>
            break;
        }
        s ++;
  102ff3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  102ffa:	0f b6 00             	movzbl (%eax),%eax
  102ffd:	84 c0                	test   %al,%al
  102fff:	75 e7                	jne    102fe8 <strfind+0x18>
  103001:	eb 01                	jmp    103004 <strfind+0x34>
            break;
  103003:	90                   	nop
    }
    return (char *)s;
  103004:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103007:	c9                   	leave  
  103008:	c3                   	ret    

00103009 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  103009:	55                   	push   %ebp
  10300a:	89 e5                	mov    %esp,%ebp
  10300c:	83 ec 10             	sub    $0x10,%esp
  10300f:	e8 68 d2 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  103014:	05 3c b9 00 00       	add    $0xb93c,%eax
    int neg = 0;
  103019:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  103020:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  103027:	eb 04                	jmp    10302d <strtol+0x24>
        s ++;
  103029:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10302d:	8b 45 08             	mov    0x8(%ebp),%eax
  103030:	0f b6 00             	movzbl (%eax),%eax
  103033:	3c 20                	cmp    $0x20,%al
  103035:	74 f2                	je     103029 <strtol+0x20>
  103037:	8b 45 08             	mov    0x8(%ebp),%eax
  10303a:	0f b6 00             	movzbl (%eax),%eax
  10303d:	3c 09                	cmp    $0x9,%al
  10303f:	74 e8                	je     103029 <strtol+0x20>
    }

    // plus/minus sign
    if (*s == '+') {
  103041:	8b 45 08             	mov    0x8(%ebp),%eax
  103044:	0f b6 00             	movzbl (%eax),%eax
  103047:	3c 2b                	cmp    $0x2b,%al
  103049:	75 06                	jne    103051 <strtol+0x48>
        s ++;
  10304b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10304f:	eb 15                	jmp    103066 <strtol+0x5d>
    }
    else if (*s == '-') {
  103051:	8b 45 08             	mov    0x8(%ebp),%eax
  103054:	0f b6 00             	movzbl (%eax),%eax
  103057:	3c 2d                	cmp    $0x2d,%al
  103059:	75 0b                	jne    103066 <strtol+0x5d>
        s ++, neg = 1;
  10305b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10305f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  103066:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10306a:	74 06                	je     103072 <strtol+0x69>
  10306c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  103070:	75 24                	jne    103096 <strtol+0x8d>
  103072:	8b 45 08             	mov    0x8(%ebp),%eax
  103075:	0f b6 00             	movzbl (%eax),%eax
  103078:	3c 30                	cmp    $0x30,%al
  10307a:	75 1a                	jne    103096 <strtol+0x8d>
  10307c:	8b 45 08             	mov    0x8(%ebp),%eax
  10307f:	83 c0 01             	add    $0x1,%eax
  103082:	0f b6 00             	movzbl (%eax),%eax
  103085:	3c 78                	cmp    $0x78,%al
  103087:	75 0d                	jne    103096 <strtol+0x8d>
        s += 2, base = 16;
  103089:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10308d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  103094:	eb 2a                	jmp    1030c0 <strtol+0xb7>
    }
    else if (base == 0 && s[0] == '0') {
  103096:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10309a:	75 17                	jne    1030b3 <strtol+0xaa>
  10309c:	8b 45 08             	mov    0x8(%ebp),%eax
  10309f:	0f b6 00             	movzbl (%eax),%eax
  1030a2:	3c 30                	cmp    $0x30,%al
  1030a4:	75 0d                	jne    1030b3 <strtol+0xaa>
        s ++, base = 8;
  1030a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1030aa:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1030b1:	eb 0d                	jmp    1030c0 <strtol+0xb7>
    }
    else if (base == 0) {
  1030b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1030b7:	75 07                	jne    1030c0 <strtol+0xb7>
        base = 10;
  1030b9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1030c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1030c3:	0f b6 00             	movzbl (%eax),%eax
  1030c6:	3c 2f                	cmp    $0x2f,%al
  1030c8:	7e 1b                	jle    1030e5 <strtol+0xdc>
  1030ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1030cd:	0f b6 00             	movzbl (%eax),%eax
  1030d0:	3c 39                	cmp    $0x39,%al
  1030d2:	7f 11                	jg     1030e5 <strtol+0xdc>
            dig = *s - '0';
  1030d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1030d7:	0f b6 00             	movzbl (%eax),%eax
  1030da:	0f be c0             	movsbl %al,%eax
  1030dd:	83 e8 30             	sub    $0x30,%eax
  1030e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1030e3:	eb 48                	jmp    10312d <strtol+0x124>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1030e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1030e8:	0f b6 00             	movzbl (%eax),%eax
  1030eb:	3c 60                	cmp    $0x60,%al
  1030ed:	7e 1b                	jle    10310a <strtol+0x101>
  1030ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1030f2:	0f b6 00             	movzbl (%eax),%eax
  1030f5:	3c 7a                	cmp    $0x7a,%al
  1030f7:	7f 11                	jg     10310a <strtol+0x101>
            dig = *s - 'a' + 10;
  1030f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030fc:	0f b6 00             	movzbl (%eax),%eax
  1030ff:	0f be c0             	movsbl %al,%eax
  103102:	83 e8 57             	sub    $0x57,%eax
  103105:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103108:	eb 23                	jmp    10312d <strtol+0x124>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10310a:	8b 45 08             	mov    0x8(%ebp),%eax
  10310d:	0f b6 00             	movzbl (%eax),%eax
  103110:	3c 40                	cmp    $0x40,%al
  103112:	7e 3c                	jle    103150 <strtol+0x147>
  103114:	8b 45 08             	mov    0x8(%ebp),%eax
  103117:	0f b6 00             	movzbl (%eax),%eax
  10311a:	3c 5a                	cmp    $0x5a,%al
  10311c:	7f 32                	jg     103150 <strtol+0x147>
            dig = *s - 'A' + 10;
  10311e:	8b 45 08             	mov    0x8(%ebp),%eax
  103121:	0f b6 00             	movzbl (%eax),%eax
  103124:	0f be c0             	movsbl %al,%eax
  103127:	83 e8 37             	sub    $0x37,%eax
  10312a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10312d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103130:	3b 45 10             	cmp    0x10(%ebp),%eax
  103133:	7d 1a                	jge    10314f <strtol+0x146>
            break;
        }
        s ++, val = (val * base) + dig;
  103135:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103139:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10313c:	0f af 45 10          	imul   0x10(%ebp),%eax
  103140:	89 c2                	mov    %eax,%edx
  103142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103145:	01 d0                	add    %edx,%eax
  103147:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  10314a:	e9 71 ff ff ff       	jmp    1030c0 <strtol+0xb7>
            break;
  10314f:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  103150:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103154:	74 08                	je     10315e <strtol+0x155>
        *endptr = (char *) s;
  103156:	8b 45 0c             	mov    0xc(%ebp),%eax
  103159:	8b 55 08             	mov    0x8(%ebp),%edx
  10315c:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10315e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  103162:	74 07                	je     10316b <strtol+0x162>
  103164:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103167:	f7 d8                	neg    %eax
  103169:	eb 03                	jmp    10316e <strtol+0x165>
  10316b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10316e:	c9                   	leave  
  10316f:	c3                   	ret    

00103170 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  103170:	55                   	push   %ebp
  103171:	89 e5                	mov    %esp,%ebp
  103173:	57                   	push   %edi
  103174:	83 ec 24             	sub    $0x24,%esp
  103177:	e8 00 d1 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10317c:	05 d4 b7 00 00       	add    $0xb7d4,%eax
  103181:	8b 45 0c             	mov    0xc(%ebp),%eax
  103184:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  103187:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10318b:	8b 55 08             	mov    0x8(%ebp),%edx
  10318e:	89 55 f8             	mov    %edx,-0x8(%ebp)
  103191:	88 45 f7             	mov    %al,-0x9(%ebp)
  103194:	8b 45 10             	mov    0x10(%ebp),%eax
  103197:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10319a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10319d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1031a1:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1031a4:	89 d7                	mov    %edx,%edi
  1031a6:	f3 aa                	rep stos %al,%es:(%edi)
  1031a8:	89 fa                	mov    %edi,%edx
  1031aa:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1031ad:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  1031b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1031b3:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1031b4:	83 c4 24             	add    $0x24,%esp
  1031b7:	5f                   	pop    %edi
  1031b8:	5d                   	pop    %ebp
  1031b9:	c3                   	ret    

001031ba <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1031ba:	55                   	push   %ebp
  1031bb:	89 e5                	mov    %esp,%ebp
  1031bd:	57                   	push   %edi
  1031be:	56                   	push   %esi
  1031bf:	53                   	push   %ebx
  1031c0:	83 ec 30             	sub    $0x30,%esp
  1031c3:	e8 b4 d0 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1031c8:	05 88 b7 00 00       	add    $0xb788,%eax
  1031cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1031d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1031dc:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1031df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1031e5:	73 42                	jae    103229 <memmove+0x6f>
  1031e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1031ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1031f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1031f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1031f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1031fc:	c1 e8 02             	shr    $0x2,%eax
  1031ff:	89 c1                	mov    %eax,%ecx
    asm volatile (
  103201:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103204:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103207:	89 d7                	mov    %edx,%edi
  103209:	89 c6                	mov    %eax,%esi
  10320b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10320d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  103210:	83 e1 03             	and    $0x3,%ecx
  103213:	74 02                	je     103217 <memmove+0x5d>
  103215:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103217:	89 f0                	mov    %esi,%eax
  103219:	89 fa                	mov    %edi,%edx
  10321b:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10321e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103221:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  103224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  103227:	eb 36                	jmp    10325f <memmove+0xa5>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  103229:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10322c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10322f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103232:	01 c2                	add    %eax,%edx
  103234:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103237:	8d 48 ff             	lea    -0x1(%eax),%ecx
  10323a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10323d:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  103240:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103243:	89 c1                	mov    %eax,%ecx
  103245:	89 d8                	mov    %ebx,%eax
  103247:	89 d6                	mov    %edx,%esi
  103249:	89 c7                	mov    %eax,%edi
  10324b:	fd                   	std    
  10324c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10324e:	fc                   	cld    
  10324f:	89 f8                	mov    %edi,%eax
  103251:	89 f2                	mov    %esi,%edx
  103253:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  103256:	89 55 c8             	mov    %edx,-0x38(%ebp)
  103259:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10325c:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10325f:	83 c4 30             	add    $0x30,%esp
  103262:	5b                   	pop    %ebx
  103263:	5e                   	pop    %esi
  103264:	5f                   	pop    %edi
  103265:	5d                   	pop    %ebp
  103266:	c3                   	ret    

00103267 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  103267:	55                   	push   %ebp
  103268:	89 e5                	mov    %esp,%ebp
  10326a:	57                   	push   %edi
  10326b:	56                   	push   %esi
  10326c:	83 ec 20             	sub    $0x20,%esp
  10326f:	e8 08 d0 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  103274:	05 dc b6 00 00       	add    $0xb6dc,%eax
  103279:	8b 45 08             	mov    0x8(%ebp),%eax
  10327c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10327f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103282:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103285:	8b 45 10             	mov    0x10(%ebp),%eax
  103288:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10328b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10328e:	c1 e8 02             	shr    $0x2,%eax
  103291:	89 c1                	mov    %eax,%ecx
    asm volatile (
  103293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103296:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103299:	89 d7                	mov    %edx,%edi
  10329b:	89 c6                	mov    %eax,%esi
  10329d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10329f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1032a2:	83 e1 03             	and    $0x3,%ecx
  1032a5:	74 02                	je     1032a9 <memcpy+0x42>
  1032a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1032a9:	89 f0                	mov    %esi,%eax
  1032ab:	89 fa                	mov    %edi,%edx
  1032ad:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1032b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1032b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1032b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  1032b9:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1032ba:	83 c4 20             	add    $0x20,%esp
  1032bd:	5e                   	pop    %esi
  1032be:	5f                   	pop    %edi
  1032bf:	5d                   	pop    %ebp
  1032c0:	c3                   	ret    

001032c1 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1032c1:	55                   	push   %ebp
  1032c2:	89 e5                	mov    %esp,%ebp
  1032c4:	83 ec 10             	sub    $0x10,%esp
  1032c7:	e8 b0 cf ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1032cc:	05 84 b6 00 00       	add    $0xb684,%eax
    const char *s1 = (const char *)v1;
  1032d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1032d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1032d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032da:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1032dd:	eb 30                	jmp    10330f <memcmp+0x4e>
        if (*s1 != *s2) {
  1032df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1032e2:	0f b6 10             	movzbl (%eax),%edx
  1032e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1032e8:	0f b6 00             	movzbl (%eax),%eax
  1032eb:	38 c2                	cmp    %al,%dl
  1032ed:	74 18                	je     103307 <memcmp+0x46>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1032ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1032f2:	0f b6 00             	movzbl (%eax),%eax
  1032f5:	0f b6 d0             	movzbl %al,%edx
  1032f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1032fb:	0f b6 00             	movzbl (%eax),%eax
  1032fe:	0f b6 c0             	movzbl %al,%eax
  103301:	29 c2                	sub    %eax,%edx
  103303:	89 d0                	mov    %edx,%eax
  103305:	eb 1a                	jmp    103321 <memcmp+0x60>
        }
        s1 ++, s2 ++;
  103307:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10330b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  10330f:	8b 45 10             	mov    0x10(%ebp),%eax
  103312:	8d 50 ff             	lea    -0x1(%eax),%edx
  103315:	89 55 10             	mov    %edx,0x10(%ebp)
  103318:	85 c0                	test   %eax,%eax
  10331a:	75 c3                	jne    1032df <memcmp+0x1e>
    }
    return 0;
  10331c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103321:	c9                   	leave  
  103322:	c3                   	ret    

00103323 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  103323:	55                   	push   %ebp
  103324:	89 e5                	mov    %esp,%ebp
  103326:	53                   	push   %ebx
  103327:	83 ec 34             	sub    $0x34,%esp
  10332a:	e8 51 cf ff ff       	call   100280 <__x86.get_pc_thunk.bx>
  10332f:	81 c3 21 b6 00 00    	add    $0xb621,%ebx
  103335:	8b 45 10             	mov    0x10(%ebp),%eax
  103338:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10333b:	8b 45 14             	mov    0x14(%ebp),%eax
  10333e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  103341:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103344:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103347:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10334a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  10334d:	8b 45 18             	mov    0x18(%ebp),%eax
  103350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103353:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103356:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103359:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10335c:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10335f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103365:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103369:	74 1c                	je     103387 <printnum+0x64>
  10336b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10336e:	ba 00 00 00 00       	mov    $0x0,%edx
  103373:	f7 75 e4             	divl   -0x1c(%ebp)
  103376:	89 55 f4             	mov    %edx,-0xc(%ebp)
  103379:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10337c:	ba 00 00 00 00       	mov    $0x0,%edx
  103381:	f7 75 e4             	divl   -0x1c(%ebp)
  103384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103387:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10338a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10338d:	f7 75 e4             	divl   -0x1c(%ebp)
  103390:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103393:	89 55 dc             	mov    %edx,-0x24(%ebp)
  103396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103399:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10339c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10339f:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1033a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1033a5:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1033a8:	8b 45 18             	mov    0x18(%ebp),%eax
  1033ab:	ba 00 00 00 00       	mov    $0x0,%edx
  1033b0:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1033b3:	72 41                	jb     1033f6 <printnum+0xd3>
  1033b5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1033b8:	77 05                	ja     1033bf <printnum+0x9c>
  1033ba:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1033bd:	72 37                	jb     1033f6 <printnum+0xd3>
        printnum(putch, putdat, result, base, width - 1, padc);
  1033bf:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1033c2:	83 e8 01             	sub    $0x1,%eax
  1033c5:	83 ec 04             	sub    $0x4,%esp
  1033c8:	ff 75 20             	pushl  0x20(%ebp)
  1033cb:	50                   	push   %eax
  1033cc:	ff 75 18             	pushl  0x18(%ebp)
  1033cf:	ff 75 ec             	pushl  -0x14(%ebp)
  1033d2:	ff 75 e8             	pushl  -0x18(%ebp)
  1033d5:	ff 75 0c             	pushl  0xc(%ebp)
  1033d8:	ff 75 08             	pushl  0x8(%ebp)
  1033db:	e8 43 ff ff ff       	call   103323 <printnum>
  1033e0:	83 c4 20             	add    $0x20,%esp
  1033e3:	eb 1b                	jmp    103400 <printnum+0xdd>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1033e5:	83 ec 08             	sub    $0x8,%esp
  1033e8:	ff 75 0c             	pushl  0xc(%ebp)
  1033eb:	ff 75 20             	pushl  0x20(%ebp)
  1033ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1033f1:	ff d0                	call   *%eax
  1033f3:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
  1033f6:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  1033fa:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1033fe:	7f e5                	jg     1033e5 <printnum+0xc2>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  103400:	8d 93 6e 57 ff ff    	lea    -0xa892(%ebx),%edx
  103406:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103409:	01 d0                	add    %edx,%eax
  10340b:	0f b6 00             	movzbl (%eax),%eax
  10340e:	0f be c0             	movsbl %al,%eax
  103411:	83 ec 08             	sub    $0x8,%esp
  103414:	ff 75 0c             	pushl  0xc(%ebp)
  103417:	50                   	push   %eax
  103418:	8b 45 08             	mov    0x8(%ebp),%eax
  10341b:	ff d0                	call   *%eax
  10341d:	83 c4 10             	add    $0x10,%esp
}
  103420:	90                   	nop
  103421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  103424:	c9                   	leave  
  103425:	c3                   	ret    

00103426 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  103426:	55                   	push   %ebp
  103427:	89 e5                	mov    %esp,%ebp
  103429:	e8 4e ce ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10342e:	05 22 b5 00 00       	add    $0xb522,%eax
    if (lflag >= 2) {
  103433:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103437:	7e 14                	jle    10344d <getuint+0x27>
        return va_arg(*ap, unsigned long long);
  103439:	8b 45 08             	mov    0x8(%ebp),%eax
  10343c:	8b 00                	mov    (%eax),%eax
  10343e:	8d 48 08             	lea    0x8(%eax),%ecx
  103441:	8b 55 08             	mov    0x8(%ebp),%edx
  103444:	89 0a                	mov    %ecx,(%edx)
  103446:	8b 50 04             	mov    0x4(%eax),%edx
  103449:	8b 00                	mov    (%eax),%eax
  10344b:	eb 30                	jmp    10347d <getuint+0x57>
    }
    else if (lflag) {
  10344d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103451:	74 16                	je     103469 <getuint+0x43>
        return va_arg(*ap, unsigned long);
  103453:	8b 45 08             	mov    0x8(%ebp),%eax
  103456:	8b 00                	mov    (%eax),%eax
  103458:	8d 48 04             	lea    0x4(%eax),%ecx
  10345b:	8b 55 08             	mov    0x8(%ebp),%edx
  10345e:	89 0a                	mov    %ecx,(%edx)
  103460:	8b 00                	mov    (%eax),%eax
  103462:	ba 00 00 00 00       	mov    $0x0,%edx
  103467:	eb 14                	jmp    10347d <getuint+0x57>
    }
    else {
        return va_arg(*ap, unsigned int);
  103469:	8b 45 08             	mov    0x8(%ebp),%eax
  10346c:	8b 00                	mov    (%eax),%eax
  10346e:	8d 48 04             	lea    0x4(%eax),%ecx
  103471:	8b 55 08             	mov    0x8(%ebp),%edx
  103474:	89 0a                	mov    %ecx,(%edx)
  103476:	8b 00                	mov    (%eax),%eax
  103478:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10347d:	5d                   	pop    %ebp
  10347e:	c3                   	ret    

0010347f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10347f:	55                   	push   %ebp
  103480:	89 e5                	mov    %esp,%ebp
  103482:	e8 f5 cd ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  103487:	05 c9 b4 00 00       	add    $0xb4c9,%eax
    if (lflag >= 2) {
  10348c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103490:	7e 14                	jle    1034a6 <getint+0x27>
        return va_arg(*ap, long long);
  103492:	8b 45 08             	mov    0x8(%ebp),%eax
  103495:	8b 00                	mov    (%eax),%eax
  103497:	8d 48 08             	lea    0x8(%eax),%ecx
  10349a:	8b 55 08             	mov    0x8(%ebp),%edx
  10349d:	89 0a                	mov    %ecx,(%edx)
  10349f:	8b 50 04             	mov    0x4(%eax),%edx
  1034a2:	8b 00                	mov    (%eax),%eax
  1034a4:	eb 28                	jmp    1034ce <getint+0x4f>
    }
    else if (lflag) {
  1034a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1034aa:	74 12                	je     1034be <getint+0x3f>
        return va_arg(*ap, long);
  1034ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1034af:	8b 00                	mov    (%eax),%eax
  1034b1:	8d 48 04             	lea    0x4(%eax),%ecx
  1034b4:	8b 55 08             	mov    0x8(%ebp),%edx
  1034b7:	89 0a                	mov    %ecx,(%edx)
  1034b9:	8b 00                	mov    (%eax),%eax
  1034bb:	99                   	cltd   
  1034bc:	eb 10                	jmp    1034ce <getint+0x4f>
    }
    else {
        return va_arg(*ap, int);
  1034be:	8b 45 08             	mov    0x8(%ebp),%eax
  1034c1:	8b 00                	mov    (%eax),%eax
  1034c3:	8d 48 04             	lea    0x4(%eax),%ecx
  1034c6:	8b 55 08             	mov    0x8(%ebp),%edx
  1034c9:	89 0a                	mov    %ecx,(%edx)
  1034cb:	8b 00                	mov    (%eax),%eax
  1034cd:	99                   	cltd   
    }
}
  1034ce:	5d                   	pop    %ebp
  1034cf:	c3                   	ret    

001034d0 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1034d0:	55                   	push   %ebp
  1034d1:	89 e5                	mov    %esp,%ebp
  1034d3:	83 ec 18             	sub    $0x18,%esp
  1034d6:	e8 a1 cd ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1034db:	05 75 b4 00 00       	add    $0xb475,%eax
    va_list ap;

    va_start(ap, fmt);
  1034e0:	8d 45 14             	lea    0x14(%ebp),%eax
  1034e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1034e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034e9:	50                   	push   %eax
  1034ea:	ff 75 10             	pushl  0x10(%ebp)
  1034ed:	ff 75 0c             	pushl  0xc(%ebp)
  1034f0:	ff 75 08             	pushl  0x8(%ebp)
  1034f3:	e8 06 00 00 00       	call   1034fe <vprintfmt>
  1034f8:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  1034fb:	90                   	nop
  1034fc:	c9                   	leave  
  1034fd:	c3                   	ret    

001034fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1034fe:	55                   	push   %ebp
  1034ff:	89 e5                	mov    %esp,%ebp
  103501:	57                   	push   %edi
  103502:	56                   	push   %esi
  103503:	53                   	push   %ebx
  103504:	83 ec 2c             	sub    $0x2c,%esp
  103507:	e8 8c 04 00 00       	call   103998 <__x86.get_pc_thunk.di>
  10350c:	81 c7 44 b4 00 00    	add    $0xb444,%edi
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103512:	eb 17                	jmp    10352b <vprintfmt+0x2d>
            if (ch == '\0') {
  103514:	85 db                	test   %ebx,%ebx
  103516:	0f 84 9a 03 00 00    	je     1038b6 <.L24+0x2d>
                return;
            }
            putch(ch, putdat);
  10351c:	83 ec 08             	sub    $0x8,%esp
  10351f:	ff 75 0c             	pushl  0xc(%ebp)
  103522:	53                   	push   %ebx
  103523:	8b 45 08             	mov    0x8(%ebp),%eax
  103526:	ff d0                	call   *%eax
  103528:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10352b:	8b 45 10             	mov    0x10(%ebp),%eax
  10352e:	8d 50 01             	lea    0x1(%eax),%edx
  103531:	89 55 10             	mov    %edx,0x10(%ebp)
  103534:	0f b6 00             	movzbl (%eax),%eax
  103537:	0f b6 d8             	movzbl %al,%ebx
  10353a:	83 fb 25             	cmp    $0x25,%ebx
  10353d:	75 d5                	jne    103514 <vprintfmt+0x16>
        }

        // Process a %-escape sequence
        char padc = ' ';
  10353f:	c6 45 cb 20          	movb   $0x20,-0x35(%ebp)
        width = precision = -1;
  103543:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  10354a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10354d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        lflag = altflag = 0;
  103550:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  103557:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10355a:	89 45 d0             	mov    %eax,-0x30(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10355d:	8b 45 10             	mov    0x10(%ebp),%eax
  103560:	8d 50 01             	lea    0x1(%eax),%edx
  103563:	89 55 10             	mov    %edx,0x10(%ebp)
  103566:	0f b6 00             	movzbl (%eax),%eax
  103569:	0f b6 d8             	movzbl %al,%ebx
  10356c:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10356f:	83 f8 55             	cmp    $0x55,%eax
  103572:	0f 87 11 03 00 00    	ja     103889 <.L24>
  103578:	c1 e0 02             	shl    $0x2,%eax
  10357b:	8b 84 38 94 57 ff ff 	mov    -0xa86c(%eax,%edi,1),%eax
  103582:	01 f8                	add    %edi,%eax
  103584:	ff e0                	jmp    *%eax

00103586 <.L29>:

        // flag to pad on the right
        case '-':
            padc = '-';
  103586:	c6 45 cb 2d          	movb   $0x2d,-0x35(%ebp)
            goto reswitch;
  10358a:	eb d1                	jmp    10355d <vprintfmt+0x5f>

0010358c <.L31>:

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10358c:	c6 45 cb 30          	movb   $0x30,-0x35(%ebp)
            goto reswitch;
  103590:	eb cb                	jmp    10355d <vprintfmt+0x5f>

00103592 <.L32>:

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103592:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
                precision = precision * 10 + ch - '0';
  103599:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10359c:	89 d0                	mov    %edx,%eax
  10359e:	c1 e0 02             	shl    $0x2,%eax
  1035a1:	01 d0                	add    %edx,%eax
  1035a3:	01 c0                	add    %eax,%eax
  1035a5:	01 d8                	add    %ebx,%eax
  1035a7:	83 e8 30             	sub    $0x30,%eax
  1035aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
                ch = *fmt;
  1035ad:	8b 45 10             	mov    0x10(%ebp),%eax
  1035b0:	0f b6 00             	movzbl (%eax),%eax
  1035b3:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1035b6:	83 fb 2f             	cmp    $0x2f,%ebx
  1035b9:	7e 39                	jle    1035f4 <.L25+0xc>
  1035bb:	83 fb 39             	cmp    $0x39,%ebx
  1035be:	7f 34                	jg     1035f4 <.L25+0xc>
            for (precision = 0; ; ++ fmt) {
  1035c0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1035c4:	eb d3                	jmp    103599 <.L32+0x7>

001035c6 <.L28>:
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1035c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1035c9:	8d 50 04             	lea    0x4(%eax),%edx
  1035cc:	89 55 14             	mov    %edx,0x14(%ebp)
  1035cf:	8b 00                	mov    (%eax),%eax
  1035d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            goto process_precision;
  1035d4:	eb 1f                	jmp    1035f5 <.L25+0xd>

001035d6 <.L30>:

        case '.':
            if (width < 0)
  1035d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1035da:	79 81                	jns    10355d <vprintfmt+0x5f>
                width = 0;
  1035dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            goto reswitch;
  1035e3:	e9 75 ff ff ff       	jmp    10355d <vprintfmt+0x5f>

001035e8 <.L25>:

        case '#':
            altflag = 1;
  1035e8:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
            goto reswitch;
  1035ef:	e9 69 ff ff ff       	jmp    10355d <vprintfmt+0x5f>
            goto process_precision;
  1035f4:	90                   	nop

        process_precision:
            if (width < 0)
  1035f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1035f9:	0f 89 5e ff ff ff    	jns    10355d <vprintfmt+0x5f>
                width = precision, precision = -1;
  1035ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  103605:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
            goto reswitch;
  10360c:	e9 4c ff ff ff       	jmp    10355d <vprintfmt+0x5f>

00103611 <.L36>:

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  103611:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
            goto reswitch;
  103615:	e9 43 ff ff ff       	jmp    10355d <vprintfmt+0x5f>

0010361a <.L33>:

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  10361a:	8b 45 14             	mov    0x14(%ebp),%eax
  10361d:	8d 50 04             	lea    0x4(%eax),%edx
  103620:	89 55 14             	mov    %edx,0x14(%ebp)
  103623:	8b 00                	mov    (%eax),%eax
  103625:	83 ec 08             	sub    $0x8,%esp
  103628:	ff 75 0c             	pushl  0xc(%ebp)
  10362b:	50                   	push   %eax
  10362c:	8b 45 08             	mov    0x8(%ebp),%eax
  10362f:	ff d0                	call   *%eax
  103631:	83 c4 10             	add    $0x10,%esp
            break;
  103634:	e9 78 02 00 00       	jmp    1038b1 <.L24+0x28>

00103639 <.L35>:

        // error message
        case 'e':
            err = va_arg(ap, int);
  103639:	8b 45 14             	mov    0x14(%ebp),%eax
  10363c:	8d 50 04             	lea    0x4(%eax),%edx
  10363f:	89 55 14             	mov    %edx,0x14(%ebp)
  103642:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  103644:	85 db                	test   %ebx,%ebx
  103646:	79 02                	jns    10364a <.L35+0x11>
                err = -err;
  103648:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10364a:	83 fb 06             	cmp    $0x6,%ebx
  10364d:	7f 0b                	jg     10365a <.L35+0x21>
  10364f:	8b b4 9f 40 01 00 00 	mov    0x140(%edi,%ebx,4),%esi
  103656:	85 f6                	test   %esi,%esi
  103658:	75 1b                	jne    103675 <.L35+0x3c>
                printfmt(putch, putdat, "error %d", err);
  10365a:	53                   	push   %ebx
  10365b:	8d 87 7f 57 ff ff    	lea    -0xa881(%edi),%eax
  103661:	50                   	push   %eax
  103662:	ff 75 0c             	pushl  0xc(%ebp)
  103665:	ff 75 08             	pushl  0x8(%ebp)
  103668:	e8 63 fe ff ff       	call   1034d0 <printfmt>
  10366d:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  103670:	e9 3c 02 00 00       	jmp    1038b1 <.L24+0x28>
                printfmt(putch, putdat, "%s", p);
  103675:	56                   	push   %esi
  103676:	8d 87 88 57 ff ff    	lea    -0xa878(%edi),%eax
  10367c:	50                   	push   %eax
  10367d:	ff 75 0c             	pushl  0xc(%ebp)
  103680:	ff 75 08             	pushl  0x8(%ebp)
  103683:	e8 48 fe ff ff       	call   1034d0 <printfmt>
  103688:	83 c4 10             	add    $0x10,%esp
            break;
  10368b:	e9 21 02 00 00       	jmp    1038b1 <.L24+0x28>

00103690 <.L39>:

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103690:	8b 45 14             	mov    0x14(%ebp),%eax
  103693:	8d 50 04             	lea    0x4(%eax),%edx
  103696:	89 55 14             	mov    %edx,0x14(%ebp)
  103699:	8b 30                	mov    (%eax),%esi
  10369b:	85 f6                	test   %esi,%esi
  10369d:	75 06                	jne    1036a5 <.L39+0x15>
                p = "(null)";
  10369f:	8d b7 8b 57 ff ff    	lea    -0xa875(%edi),%esi
            }
            if (width > 0 && padc != '-') {
  1036a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1036a9:	7e 78                	jle    103723 <.L39+0x93>
  1036ab:	80 7d cb 2d          	cmpb   $0x2d,-0x35(%ebp)
  1036af:	74 72                	je     103723 <.L39+0x93>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1036b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1036b4:	83 ec 08             	sub    $0x8,%esp
  1036b7:	50                   	push   %eax
  1036b8:	56                   	push   %esi
  1036b9:	89 fb                	mov    %edi,%ebx
  1036bb:	e8 57 f7 ff ff       	call   102e17 <strnlen>
  1036c0:	83 c4 10             	add    $0x10,%esp
  1036c3:	89 c2                	mov    %eax,%edx
  1036c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1036c8:	29 d0                	sub    %edx,%eax
  1036ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1036cd:	eb 17                	jmp    1036e6 <.L39+0x56>
                    putch(padc, putdat);
  1036cf:	0f be 45 cb          	movsbl -0x35(%ebp),%eax
  1036d3:	83 ec 08             	sub    $0x8,%esp
  1036d6:	ff 75 0c             	pushl  0xc(%ebp)
  1036d9:	50                   	push   %eax
  1036da:	8b 45 08             	mov    0x8(%ebp),%eax
  1036dd:	ff d0                	call   *%eax
  1036df:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
  1036e2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  1036e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1036ea:	7f e3                	jg     1036cf <.L39+0x3f>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1036ec:	eb 35                	jmp    103723 <.L39+0x93>
                if (altflag && (ch < ' ' || ch > '~')) {
  1036ee:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1036f2:	74 1c                	je     103710 <.L39+0x80>
  1036f4:	83 fb 1f             	cmp    $0x1f,%ebx
  1036f7:	7e 05                	jle    1036fe <.L39+0x6e>
  1036f9:	83 fb 7e             	cmp    $0x7e,%ebx
  1036fc:	7e 12                	jle    103710 <.L39+0x80>
                    putch('?', putdat);
  1036fe:	83 ec 08             	sub    $0x8,%esp
  103701:	ff 75 0c             	pushl  0xc(%ebp)
  103704:	6a 3f                	push   $0x3f
  103706:	8b 45 08             	mov    0x8(%ebp),%eax
  103709:	ff d0                	call   *%eax
  10370b:	83 c4 10             	add    $0x10,%esp
  10370e:	eb 0f                	jmp    10371f <.L39+0x8f>
                }
                else {
                    putch(ch, putdat);
  103710:	83 ec 08             	sub    $0x8,%esp
  103713:	ff 75 0c             	pushl  0xc(%ebp)
  103716:	53                   	push   %ebx
  103717:	8b 45 08             	mov    0x8(%ebp),%eax
  10371a:	ff d0                	call   *%eax
  10371c:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10371f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  103723:	89 f0                	mov    %esi,%eax
  103725:	8d 70 01             	lea    0x1(%eax),%esi
  103728:	0f b6 00             	movzbl (%eax),%eax
  10372b:	0f be d8             	movsbl %al,%ebx
  10372e:	85 db                	test   %ebx,%ebx
  103730:	74 26                	je     103758 <.L39+0xc8>
  103732:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  103736:	78 b6                	js     1036ee <.L39+0x5e>
  103738:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
  10373c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  103740:	79 ac                	jns    1036ee <.L39+0x5e>
                }
            }
            for (; width > 0; width --) {
  103742:	eb 14                	jmp    103758 <.L39+0xc8>
                putch(' ', putdat);
  103744:	83 ec 08             	sub    $0x8,%esp
  103747:	ff 75 0c             	pushl  0xc(%ebp)
  10374a:	6a 20                	push   $0x20
  10374c:	8b 45 08             	mov    0x8(%ebp),%eax
  10374f:	ff d0                	call   *%eax
  103751:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
  103754:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  103758:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10375c:	7f e6                	jg     103744 <.L39+0xb4>
            }
            break;
  10375e:	e9 4e 01 00 00       	jmp    1038b1 <.L24+0x28>

00103763 <.L34>:

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  103763:	83 ec 08             	sub    $0x8,%esp
  103766:	ff 75 d0             	pushl  -0x30(%ebp)
  103769:	8d 45 14             	lea    0x14(%ebp),%eax
  10376c:	50                   	push   %eax
  10376d:	e8 0d fd ff ff       	call   10347f <getint>
  103772:	83 c4 10             	add    $0x10,%esp
  103775:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103778:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            if ((long long)num < 0) {
  10377b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10377e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103781:	85 d2                	test   %edx,%edx
  103783:	79 23                	jns    1037a8 <.L34+0x45>
                putch('-', putdat);
  103785:	83 ec 08             	sub    $0x8,%esp
  103788:	ff 75 0c             	pushl  0xc(%ebp)
  10378b:	6a 2d                	push   $0x2d
  10378d:	8b 45 08             	mov    0x8(%ebp),%eax
  103790:	ff d0                	call   *%eax
  103792:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  103795:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103798:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10379b:	f7 d8                	neg    %eax
  10379d:	83 d2 00             	adc    $0x0,%edx
  1037a0:	f7 da                	neg    %edx
  1037a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1037a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            }
            base = 10;
  1037a8:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
            goto number;
  1037af:	e9 9f 00 00 00       	jmp    103853 <.L41+0x1f>

001037b4 <.L40>:

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1037b4:	83 ec 08             	sub    $0x8,%esp
  1037b7:	ff 75 d0             	pushl  -0x30(%ebp)
  1037ba:	8d 45 14             	lea    0x14(%ebp),%eax
  1037bd:	50                   	push   %eax
  1037be:	e8 63 fc ff ff       	call   103426 <getuint>
  1037c3:	83 c4 10             	add    $0x10,%esp
  1037c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1037c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            base = 10;
  1037cc:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
            goto number;
  1037d3:	eb 7e                	jmp    103853 <.L41+0x1f>

001037d5 <.L37>:

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1037d5:	83 ec 08             	sub    $0x8,%esp
  1037d8:	ff 75 d0             	pushl  -0x30(%ebp)
  1037db:	8d 45 14             	lea    0x14(%ebp),%eax
  1037de:	50                   	push   %eax
  1037df:	e8 42 fc ff ff       	call   103426 <getuint>
  1037e4:	83 c4 10             	add    $0x10,%esp
  1037e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1037ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            base = 8;
  1037ed:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
            goto number;
  1037f4:	eb 5d                	jmp    103853 <.L41+0x1f>

001037f6 <.L38>:

        // pointer
        case 'p':
            putch('0', putdat);
  1037f6:	83 ec 08             	sub    $0x8,%esp
  1037f9:	ff 75 0c             	pushl  0xc(%ebp)
  1037fc:	6a 30                	push   $0x30
  1037fe:	8b 45 08             	mov    0x8(%ebp),%eax
  103801:	ff d0                	call   *%eax
  103803:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  103806:	83 ec 08             	sub    $0x8,%esp
  103809:	ff 75 0c             	pushl  0xc(%ebp)
  10380c:	6a 78                	push   $0x78
  10380e:	8b 45 08             	mov    0x8(%ebp),%eax
  103811:	ff d0                	call   *%eax
  103813:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103816:	8b 45 14             	mov    0x14(%ebp),%eax
  103819:	8d 50 04             	lea    0x4(%eax),%edx
  10381c:	89 55 14             	mov    %edx,0x14(%ebp)
  10381f:	8b 00                	mov    (%eax),%eax
  103821:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103824:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            base = 16;
  10382b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
            goto number;
  103832:	eb 1f                	jmp    103853 <.L41+0x1f>

00103834 <.L41>:

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  103834:	83 ec 08             	sub    $0x8,%esp
  103837:	ff 75 d0             	pushl  -0x30(%ebp)
  10383a:	8d 45 14             	lea    0x14(%ebp),%eax
  10383d:	50                   	push   %eax
  10383e:	e8 e3 fb ff ff       	call   103426 <getuint>
  103843:	83 c4 10             	add    $0x10,%esp
  103846:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103849:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            base = 16;
  10384c:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103853:	0f be 55 cb          	movsbl -0x35(%ebp),%edx
  103857:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10385a:	83 ec 04             	sub    $0x4,%esp
  10385d:	52                   	push   %edx
  10385e:	ff 75 d8             	pushl  -0x28(%ebp)
  103861:	50                   	push   %eax
  103862:	ff 75 e4             	pushl  -0x1c(%ebp)
  103865:	ff 75 e0             	pushl  -0x20(%ebp)
  103868:	ff 75 0c             	pushl  0xc(%ebp)
  10386b:	ff 75 08             	pushl  0x8(%ebp)
  10386e:	e8 b0 fa ff ff       	call   103323 <printnum>
  103873:	83 c4 20             	add    $0x20,%esp
            break;
  103876:	eb 39                	jmp    1038b1 <.L24+0x28>

00103878 <.L27>:

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  103878:	83 ec 08             	sub    $0x8,%esp
  10387b:	ff 75 0c             	pushl  0xc(%ebp)
  10387e:	53                   	push   %ebx
  10387f:	8b 45 08             	mov    0x8(%ebp),%eax
  103882:	ff d0                	call   *%eax
  103884:	83 c4 10             	add    $0x10,%esp
            break;
  103887:	eb 28                	jmp    1038b1 <.L24+0x28>

00103889 <.L24>:

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103889:	83 ec 08             	sub    $0x8,%esp
  10388c:	ff 75 0c             	pushl  0xc(%ebp)
  10388f:	6a 25                	push   $0x25
  103891:	8b 45 08             	mov    0x8(%ebp),%eax
  103894:	ff d0                	call   *%eax
  103896:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  103899:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10389d:	eb 04                	jmp    1038a3 <.L24+0x1a>
  10389f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1038a3:	8b 45 10             	mov    0x10(%ebp),%eax
  1038a6:	83 e8 01             	sub    $0x1,%eax
  1038a9:	0f b6 00             	movzbl (%eax),%eax
  1038ac:	3c 25                	cmp    $0x25,%al
  1038ae:	75 ef                	jne    10389f <.L24+0x16>
                /* do nothing */;
            break;
  1038b0:	90                   	nop
    while (1) {
  1038b1:	e9 5c fc ff ff       	jmp    103512 <vprintfmt+0x14>
                return;
  1038b6:	90                   	nop
        }
    }
}
  1038b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  1038ba:	5b                   	pop    %ebx
  1038bb:	5e                   	pop    %esi
  1038bc:	5f                   	pop    %edi
  1038bd:	5d                   	pop    %ebp
  1038be:	c3                   	ret    

001038bf <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1038bf:	55                   	push   %ebp
  1038c0:	89 e5                	mov    %esp,%ebp
  1038c2:	e8 b5 c9 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  1038c7:	05 89 b0 00 00       	add    $0xb089,%eax
    b->cnt ++;
  1038cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1038cf:	8b 40 08             	mov    0x8(%eax),%eax
  1038d2:	8d 50 01             	lea    0x1(%eax),%edx
  1038d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1038d8:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1038db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1038de:	8b 10                	mov    (%eax),%edx
  1038e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1038e3:	8b 40 04             	mov    0x4(%eax),%eax
  1038e6:	39 c2                	cmp    %eax,%edx
  1038e8:	73 12                	jae    1038fc <sprintputch+0x3d>
        *b->buf ++ = ch;
  1038ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1038ed:	8b 00                	mov    (%eax),%eax
  1038ef:	8d 48 01             	lea    0x1(%eax),%ecx
  1038f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1038f5:	89 0a                	mov    %ecx,(%edx)
  1038f7:	8b 55 08             	mov    0x8(%ebp),%edx
  1038fa:	88 10                	mov    %dl,(%eax)
    }
}
  1038fc:	90                   	nop
  1038fd:	5d                   	pop    %ebp
  1038fe:	c3                   	ret    

001038ff <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1038ff:	55                   	push   %ebp
  103900:	89 e5                	mov    %esp,%ebp
  103902:	83 ec 18             	sub    $0x18,%esp
  103905:	e8 72 c9 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10390a:	05 46 b0 00 00       	add    $0xb046,%eax
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10390f:	8d 45 14             	lea    0x14(%ebp),%eax
  103912:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103915:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103918:	50                   	push   %eax
  103919:	ff 75 10             	pushl  0x10(%ebp)
  10391c:	ff 75 0c             	pushl  0xc(%ebp)
  10391f:	ff 75 08             	pushl  0x8(%ebp)
  103922:	e8 0b 00 00 00       	call   103932 <vsnprintf>
  103927:	83 c4 10             	add    $0x10,%esp
  10392a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10392d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103930:	c9                   	leave  
  103931:	c3                   	ret    

00103932 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103932:	55                   	push   %ebp
  103933:	89 e5                	mov    %esp,%ebp
  103935:	83 ec 18             	sub    $0x18,%esp
  103938:	e8 3f c9 ff ff       	call   10027c <__x86.get_pc_thunk.ax>
  10393d:	05 13 b0 00 00       	add    $0xb013,%eax
    struct sprintbuf b = {str, str + size - 1, 0};
  103942:	8b 55 08             	mov    0x8(%ebp),%edx
  103945:	89 55 ec             	mov    %edx,-0x14(%ebp)
  103948:	8b 55 0c             	mov    0xc(%ebp),%edx
  10394b:	8d 4a ff             	lea    -0x1(%edx),%ecx
  10394e:	8b 55 08             	mov    0x8(%ebp),%edx
  103951:	01 ca                	add    %ecx,%edx
  103953:	89 55 f0             	mov    %edx,-0x10(%ebp)
  103956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10395d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103961:	74 0a                	je     10396d <vsnprintf+0x3b>
  103963:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  103966:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103969:	39 d1                	cmp    %edx,%ecx
  10396b:	76 07                	jbe    103974 <vsnprintf+0x42>
        return -E_INVAL;
  10396d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  103972:	eb 22                	jmp    103996 <vsnprintf+0x64>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103974:	ff 75 14             	pushl  0x14(%ebp)
  103977:	ff 75 10             	pushl  0x10(%ebp)
  10397a:	8d 55 ec             	lea    -0x14(%ebp),%edx
  10397d:	52                   	push   %edx
  10397e:	8d 80 6f 4f ff ff    	lea    -0xb091(%eax),%eax
  103984:	50                   	push   %eax
  103985:	e8 74 fb ff ff       	call   1034fe <vprintfmt>
  10398a:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  10398d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103990:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103993:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103996:	c9                   	leave  
  103997:	c3                   	ret    

00103998 <__x86.get_pc_thunk.di>:
  103998:	8b 3c 24             	mov    (%esp),%edi
  10399b:	c3                   	ret    
