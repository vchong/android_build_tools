	 .thumb
         .syntax unified
.section .data
        	.equ STACKINIT,          0x20000300

.section .text
vectors:
        .word STACKINIT
        .word _start + 1
        .word _nmi_handler + 1
        .word _hard_fault  + 1
        .word _memory_fault + 1
        .word _bus_fault + 1
        .word _usage_fault + 1

_start:
shizhong:
	ldr r0, = 0x40021000 @ rcc_cr
	ldr r1, = 0x15683
	str r1, [r0]
gsszbz:
	ldr r2, [r0]
	ldr r1, = 0x20000
	tst r1, r2           @HSE时钟标志位
	bne rccchushihua
	b gsszbz
rccchushihua:
	ldr r0, = 0x40022000   @FLASH访问控制
	movs r1, # 0x32
	str r1, [r0]           @FLASH缓冲 缓冲开启
	ldr r0, = 0x40021004
	ldr r1, = 0x110000    @ HSE-PLL-6倍频
	str r1, [r0]
	ldr r0, = 0x40021000
	ldr r1, = 0x1035683     @ PLL开
	str r1, [r0]
chaxun:
	ldr r2, [r0]
	ldr r1, = 0x2000000     @ PLL锁定标志位
	tst r1, r2
	bne rccgg               @ 等待PLL锁定
	b chaxun
rccgg:
	ldr r0, = 0x40021004
	ldr r1, = 0x11000a      @ PLL作为系统时钟
	str r1, [r0]
shi_zhong_she_zhi:
	ldr r0, = 0x40021014    @ AHB外部时钟
	ldr r1, = 0x60014       @ 开时钟
	str r1, [r0]
	@ DMA（0）SRAM（2）FLITF（4）CRC（6）PA（17）
	@PB（18）PC（19）PD（20）PF（22）TSCEN（24）
	ldr r0, = 0x4002101c
	ldr r1, = 0x132
	str r1, [r0]
tim14chushihua:
	        ldr r0, = 0x40002000
	        ldr r1, = 0
	        str r1, [r0, # 0x28]
	        ldr r1, = 10000
	        str r1, [r0, # 0x2c]
	        ldr r1, = 0x70
	        str r1, [r0, # 0x18]
	        ldr r1, = 0x01
	        str r1, [r0, # 0x20]
		ldr r1, = 10000
	        str r1, [r0, # 0x34]
	        ldr r1, = 0x81
	        str r1, [r0]

io_she_zhi:
	@a(0x48000000)b(0x48000400)c(0x48000800)d(0x48000c00)f(0x48001400)
	ldr r0, = 0x48000000   @ 端口模式
	@ 输入（00）通用输出（01）复用功能（10）模拟（11）
	ldr r1, = 0x28000200  @ PA4
	str r1, [r0]
	@偏移0x4 = 端口输出类型 @ （0 推挽）（ 1 开漏）
	@偏移0x8 = 输出速度  00低速 01中速 11高速
	@偏移0xC = 上拉下拉 00无上下拉  01 上拉 10下拉
	@偏移0x10 = 输入数据寄存器
	@偏移0x14 = 输出数据寄存器
	@偏移0x18 = 端口开  0-15置位
	@偏移0x28 = 端口关
	@0X20 = 复用低
	@0x24 = 复用高
	ldr r1, = 0x40000
	str r1, [r0, # 0x20]
huxideng:
	ldr r0, = 0x40002000
	ldr r1, [r0, # 0x34]
	ldr r5, = 0x1000
huxideng1:
	subs r5, r5, # 1
	bne huxideng1
	ldr r5, = 0x1000
	subs r1, r1, # 1
	str r1, [r0, # 0x34]
	bne huxideng1
huxideng2:
	subs r5, r5, # 1
	bne huxideng2
	ldr r5, = 0x1000
	adds r1, r1, # 1
	str r1, [r0, # 0x34]
	ldr r2, = 10000
	cmp r1, r2
	bls huxideng2
	b huxideng


_nmi_handler:
	bx lr
_hard_fault:
	bx lr
_memory_fault:
	bx lr
_bus_fault:
	bx lr
_usage_fault:
 	bx lr
