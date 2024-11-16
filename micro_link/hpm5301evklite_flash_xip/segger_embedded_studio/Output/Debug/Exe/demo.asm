
Output/Debug/Exe/demo.elf:     file format elf32-littleriscv


Disassembly of section .init._start:

80003000 <_start>:
#define L(label) .L_start_##label

START_FUNC _start
        .option push
        .option norelax
        lui     gp,     %hi(__global_pointer$)
80003000:	000811b7          	lui	gp,0x81
        addi    gp, gp, %lo(__global_pointer$)
80003004:	37018193          	add	gp,gp,880 # 81370 <__global_pointer$>
        lui     tp,     %hi(__thread_pointer$)
80003008:	80011237          	lui	tp,0x80011
        addi    tp, tp, %lo(__thread_pointer$)
8000300c:	2df20213          	add	tp,tp,735 # 800112df <__thread_pointer$>
        .option pop

        csrw    mstatus, zero
80003010:	30001073          	csrw	mstatus,zero
        csrw    mcause, zero
80003014:	34201073          	csrw	mcause,zero
    la t0, _stack_safe
    mv sp, t0
    call _init_ext_ram
#endif

        lui     t0,     %hi(__stack_end__)
80003018:	000a02b7          	lui	t0,0xa0
        addi    sp, t0, %lo(__stack_end__)
8000301c:	00028113          	mv	sp,t0

#ifdef CONFIG_NOT_ENABLE_ICACHE
        call    l1c_ic_disable
#else
        call    l1c_ic_enable
80003020:	039050ef          	jal	80008858 <l1c_ic_enable>
#endif
#ifdef CONFIG_NOT_ENABLE_DCACHE
        call    l1c_dc_invalidate_all
        call    l1c_dc_disable
#else
        call    l1c_dc_enable
80003024:	01b050ef          	jal	8000883e <l1c_dc_enable>
        call    l1c_dc_invalidate_all
80003028:	71b090ef          	jal	8000cf42 <l1c_dc_invalidate_all>

#ifndef __NO_SYSTEM_INIT
        //
        // Call _init
        //
        call    _init
8000302c:	57c050ef          	jal	800085a8 <_init>
        // Call linker init functions which in turn performs the following:
        // * Perform segment init
        // * Perform heap init (if used)
        // * Call constructors of global Objects (if any exist)
        //
        la      s0, __SEGGER_init_table__       // Set table pointer to start of initialization table
80003030:	80011437          	lui	s0,0x80011
80003034:	48c40413          	add	s0,s0,1164 # 8001148c <.L.str+0xb>

80003038 <.L_start_RunInit>:
L(RunInit):
        lw      a0, (s0)                        // Get next initialization function from table
80003038:	4008                	lw	a0,0(s0)
        add     s0, s0, 4                       // Increment table pointer to point to function arguments
8000303a:	0411                	add	s0,s0,4
        jalr    a0                              // Call initialization function
8000303c:	9502                	jalr	a0
        j       L(RunInit)
8000303e:	bfed                	j	80003038 <.L_start_RunInit>

80003040 <__SEGGER_init_done>:
        // Time to call main(), the application entry point.
        //

#ifndef NO_CLEANUP_AT_START
    /* clean up */
    call _clean_up
80003040:	536050ef          	jal	80008576 <_clean_up>
#if defined(CONFIG_FREERTOS) && CONFIG_FREERTOS
    #define HANDLER_TRAP freertos_risc_v_trap_handler
    #define HANDLER_S_TRAP freertos_risc_v_trap_handler

    /* Use mscratch to store isr level */
    csrw mscratch, 0
80003044:	34005073          	csrw	mscratch,0
#endif
    /* Enable vectored external PLIC interrupt */
    csrsi CSR_MMISC_CTL, 2
#else
    /* Initial machine trap-vector Base */
    la t0, HANDLER_TRAP
80003048:	000002b7          	lui	t0,0x0
8000304c:	20028293          	add	t0,t0,512 # 200 <freertos_risc_v_trap_handler>
    csrw mtvec, t0
80003050:	30529073          	csrw	mtvec,t0
    la t0, HANDLER_S_TRAP
    csrw stvec, t0
#endif

    /* Disable vectored external PLIC interrupt */
    csrci CSR_MMISC_CTL, 2
80003054:	7d017073          	csrc	0x7d0,2

80003058 <start>:
        //
        // In a real embedded application ("Free-standing environment"),
        // main() does not get any arguments,
        // which means it is not necessary to init a0 and a1.
        //
        call    APP_ENTRY_POINT
80003058:	58f090ef          	jal	8000cde6 <reset_handler>
        tail    exit
8000305c:	a009                	j	8000305e <exit>

8000305e <exit>:
MARK_FUNC exit
        //
        // In a free-standing environment, if returned from application:
        // Loop forever.
        //
        j       .
8000305e:	a001                	j	8000305e <exit>
        la      a1, args
        call    debug_getargs
        li      a0, ARGSSPACE
        la      a1, args
#else
        li      a0, 0
80003060:	4501                	li	a0,0
        li      a1, 0
80003062:	4581                	li	a1,0
#endif

        call    APP_ENTRY_POINT
80003064:	583090ef          	jal	8000cde6 <reset_handler>
        tail    exit
80003068:	bfdd                	j	8000305e <exit>

Disassembly of section .text.board_init_console:

80005722 <board_init_console>:
#if defined(FLASH_UF2) && FLASH_UF2
ATTR_PLACE_AT(".uf2_signature") const uint32_t uf2_signature = BOARD_UF2_SIGNATURE;
#endif

void board_init_console(void)
{
80005722:	1101                	add	sp,sp,-32
80005724:	ce06                	sw	ra,28(sp)
80005726:	cc22                	sw	s0,24(sp)
80005728:	ca26                	sw	s1,20(sp)

    /* uart needs to configure pin function before enabling clock, otherwise the level change of
     * uart rx pin when configuring pin function will cause a wrong data to be received.
     * And a uart rx dma request will be generated by default uart fifo dma trigger level.
     */
    init_uart_pins((UART_Type *) BOARD_CONSOLE_UART_BASE);
8000572a:	f004c537          	lui	a0,0xf004c
8000572e:	f004c4b7          	lui	s1,0xf004c
80005732:	5ee040ef          	jal	80009d20 <init_uart_pins>
80005736:	011c0437          	lui	s0,0x11c0
8000573a:	0461                	add	s0,s0,24 # 11c0018 <_flash_size+0x10c0018>

    /* Configure the UART clock to 24MHz */
    clock_set_source_divider(BOARD_CONSOLE_UART_CLK_NAME, clk_src_osc24m, 1U);
8000573c:	4605                	li	a2,1
8000573e:	8522                	mv	a0,s0
80005740:	4581                	li	a1,0
80005742:	6be070ef          	jal	8000ce00 <clock_set_source_divider>
    clock_add_to_group(BOARD_CONSOLE_UART_CLK_NAME, 0);
80005746:	8522                	mv	a0,s0
80005748:	4581                	li	a1,0
8000574a:	76c070ef          	jal	8000ceb6 <clock_add_to_group>

    cfg.type = BOARD_CONSOLE_TYPE;
8000574e:	c202                	sw	zero,4(sp)
    cfg.base = (uint32_t)BOARD_CONSOLE_UART_BASE;
80005750:	c426                	sw	s1,8(sp)
    cfg.src_freq_in_hz = clock_get_frequency(BOARD_CONSOLE_UART_CLK_NAME);
80005752:	8522                	mv	a0,s0
80005754:	65d020ef          	jal	800085b0 <clock_get_frequency>
80005758:	c62a                	sw	a0,12(sp)
8000575a:	000e1537          	lui	a0,0xe1
    cfg.baudrate = BOARD_CONSOLE_UART_BAUDRATE;
8000575e:	c82a                	sw	a0,16(sp)

    if (status_success != console_init(&cfg)) {
80005760:	0048                	add	a0,sp,4
80005762:	612040ef          	jal	80009d74 <console_init>
80005766:	c111                	beqz	a0,8000576a <.LBB0_2>

80005768 <.LBB0_1>:
        /* failed to  initialize debug console */
        while (1) {
80005768:	a001                	j	80005768 <.LBB0_1>

8000576a <.LBB0_2>:
8000576a:	40f2                	lw	ra,28(sp)
8000576c:	4462                	lw	s0,24(sp)
8000576e:	44d2                	lw	s1,20(sp)
#else
    while (1)
        ;
#endif
#endif
}
80005770:	6105                	add	sp,sp,32
80005772:	8082                	ret

Disassembly of section .text.board_print_banner:

8000577e <board_print_banner>:

void board_print_banner(void)
{
8000577e:	d8010113          	add	sp,sp,-640
80005782:	26112e23          	sw	ra,636(sp)
    const uint8_t banner[] = "\n"
80005786:	8000f537          	lui	a0,0x8000f
8000578a:	0af50593          	add	a1,a0,175 # 8000f0af <.L__const.board_print_banner.banner>
8000578e:	00d10513          	add	a0,sp,13
80005792:	26f00613          	li	a2,623
80005796:	10c040ef          	jal	800098a2 <memcpy>
"$$ |  $$ |$$ |      $$ |\\$  /$$ |$$ |$$ |      $$ |      $$ |  $$ |\n"
"$$ |  $$ |$$ |      $$ | \\_/ $$ |$$ |\\$$$$$$$\\ $$ |      \\$$$$$$  |\n"
"\\__|  \\__|\\__|      \\__|     \\__|\\__| \\_______|\\__|       \\______/\n"
"----------------------------------------------------------------------\n";
#ifdef SDK_VERSION_STRING
    printf("hpm_sdk: %s\n", SDK_VERSION_STRING);
8000579a:	80011537          	lui	a0,0x80011
8000579e:	97b50513          	add	a0,a0,-1669 # 8001097b <.L.str>
800057a2:	800105b7          	lui	a1,0x80010
800057a6:	0bb58593          	add	a1,a1,187 # 800100bb <.L.str.1>
800057aa:	392040ef          	jal	80009b3c <printf>
#endif
    printf("%s", banner);
800057ae:	8000f537          	lui	a0,0x8000f
800057b2:	31e50513          	add	a0,a0,798 # 8000f31e <.L.str.2>
800057b6:	00d10593          	add	a1,sp,13
800057ba:	382040ef          	jal	80009b3c <printf>
800057be:	27c12083          	lw	ra,636(sp)
}
800057c2:	28010113          	add	sp,sp,640
800057c6:	8082                	ret

Disassembly of section .text.board_print_clock_freq:

8000581e <board_print_clock_freq>:

void board_print_clock_freq(void)
{
8000581e:	1141                	add	sp,sp,-16
80005820:	c606                	sw	ra,12(sp)
80005822:	c422                	sw	s0,8(sp)
    printf("==============================\n");
80005824:	8000f537          	lui	a0,0x8000f
80005828:	36150413          	add	s0,a0,865 # 8000f361 <.Lstr.16>
8000582c:	8522                	mv	a0,s0
8000582e:	0e9070ef          	jal	8000d116 <puts>
    printf(" %s clock summary\n", BOARD_NAME);
80005832:	8000f537          	lui	a0,0x8000f
80005836:	32150513          	add	a0,a0,801 # 8000f321 <.L.str.4>
8000583a:	8000f5b7          	lui	a1,0x8000f
8000583e:	33458593          	add	a1,a1,820 # 8000f334 <.L.str.5>
80005842:	2fa040ef          	jal	80009b3c <printf>
    printf("==============================\n");
80005846:	8522                	mv	a0,s0
80005848:	0cf070ef          	jal	8000d116 <puts>
8000584c:	6505                	lui	a0,0x1
8000584e:	9fc50513          	add	a0,a0,-1540 # 9fc <.LBB2_69>
    printf("cpu0:\t\t %luHz\n", clock_get_frequency(clock_cpu0));
80005852:	55f020ef          	jal	800085b0 <clock_get_frequency>
80005856:	85aa                	mv	a1,a0
80005858:	8000f537          	lui	a0,0x8000f
8000585c:	34350513          	add	a0,a0,835 # 8000f343 <.L.str.6>
80005860:	2dc040ef          	jal	80009b3c <printf>
80005864:	fffd0537          	lui	a0,0xfffd0
80005868:	5fe50513          	add	a0,a0,1534 # fffd05fe <__AHB_SRAM_segment_end__+0xfbc85fe>
    printf("ahb:\t\t %luHz\n", clock_get_frequency(clock_ahb));
8000586c:	545020ef          	jal	800085b0 <clock_get_frequency>
80005870:	85aa                	mv	a1,a0
80005872:	80010537          	lui	a0,0x80010
80005876:	0c150513          	add	a0,a0,193 # 800100c1 <.L.str.7>
8000587a:	2c2040ef          	jal	80009b3c <printf>
    printf("mchtmr0:\t %luHz\n", clock_get_frequency(clock_mchtmr0));
8000587e:	01020537          	lui	a0,0x1020
80005882:	52f020ef          	jal	800085b0 <clock_get_frequency>
80005886:	85aa                	mv	a1,a0
80005888:	80011537          	lui	a0,0x80011
8000588c:	98850513          	add	a0,a0,-1656 # 80010988 <.L.str.8>
80005890:	2ac040ef          	jal	80009b3c <printf>
80005894:	01330537          	lui	a0,0x1330
80005898:	0575                	add	a0,a0,29 # 133001d <_flash_size+0x123001d>
    printf("xpi0:\t\t %luHz\n", clock_get_frequency(clock_xpi0));
8000589a:	517020ef          	jal	800085b0 <clock_get_frequency>
8000589e:	85aa                	mv	a1,a0
800058a0:	8000f537          	lui	a0,0x8000f
800058a4:	35250513          	add	a0,a0,850 # 8000f352 <.L.str.9>
800058a8:	294040ef          	jal	80009b3c <printf>
    printf("==============================\n");
800058ac:	8522                	mv	a0,s0
800058ae:	40b2                	lw	ra,12(sp)
800058b0:	4422                	lw	s0,8(sp)
800058b2:	0141                	add	sp,sp,16
800058b4:	0630706f          	j	8000d116 <puts>

Disassembly of section .text.board_init_usb_dp_dm_pins:

80005b16 <board_init_usb_dp_dm_pins>:
    board_print_banner();
#endif
}

void board_init_usb_dp_dm_pins(void)
{
80005b16:	1101                	add	sp,sp,-32
80005b18:	ce06                	sw	ra,28(sp)
80005b1a:	cc22                	sw	s0,24(sp)
80005b1c:	ca26                	sw	s1,20(sp)
80005b1e:	c84a                	sw	s2,16(sp)
80005b20:	c64e                	sw	s3,12(sp)
80005b22:	f4000537          	lui	a0,0xf4000

80005b26 <.LBB4_1>:
 * @param[in] ptr SYSCTL_Type base address
 * @return true if any resource is busy
 */
static inline bool sysctl_resource_any_is_busy(SYSCTL_Type *ptr)
{
    return ptr->RESOURCE[0] & SYSCTL_RESOURCE_GLB_BUSY_MASK;
80005b26:	410c                	lw	a1,0(a0)
    /* Disconnect usb dp/dm pins pull down 45ohm resistance */

    while (sysctl_resource_any_is_busy(HPM_SYSCTL)) {
80005b28:	fe05cfe3          	bltz	a1,80005b26 <.LBB4_1>
80005b2c:	f40c0537          	lui	a0,0xf40c0
 * @param [in] ptr PLLCTLV2 base address
 * @return true if external crystal is stable
 */
static inline bool pllctlv2_xtal_is_stable(PLLCTLV2_Type *ptr)
{
    return IS_HPM_BITMASK_SET(ptr->XTAL, PLLCTLV2_XTAL_RESPONSE_MASK);
80005b30:	410c                	lw	a1,0(a0)
80005b32:	00100637          	lui	a2,0x100
        ;
    }
    if (pllctlv2_xtal_is_stable(HPM_PLLCTLV2) && pllctlv2_xtal_is_enabled(HPM_PLLCTLV2)) {
80005b36:	058a                	sll	a1,a1,0x2
80005b38:	0e060993          	add	s3,a2,224 # 1000e0 <_flash_size+0xe0>
80005b3c:	0005d663          	bgez	a1,80005b48 <.LBB4_4>
 * @param [in] ptr PLLCTLV2 base address
 * @return true if external crystal is enabled
 */
static inline bool pllctlv2_xtal_is_enabled(PLLCTLV2_Type *ptr)
{
    return IS_HPM_BITMASK_SET(ptr->XTAL, PLLCTLV2_XTAL_ENABLE_MASK);
80005b40:	4108                	lw	a0,0(a0)
80005b42:	050e                	sll	a0,a0,0x3
80005b44:	06054663          	bltz	a0,80005bb0 <.LBB4_8>

80005b48 <.LBB4_4>:
80005b48:	f40004b7          	lui	s1,0xf4000
 * @return target resource mode
 */
static inline uint8_t sysctl_resource_target_get_mode(SYSCTL_Type *ptr,
                                                   sysctl_resource_t resource)
{
    return SYSCTL_RESOURCE_MODE_GET(ptr->RESOURCE[resource]);
80005b4c:	0804a903          	lw	s2,128(s1) # f4000080 <__AHB_SRAM_segment_end__+0x3bf8080>
        (ptr->RESOURCE[resource] & ~SYSCTL_RESOURCE_MODE_MASK) |
80005b50:	0804a503          	lw	a0,128(s1)
80005b54:	00356513          	or	a0,a0,3
    ptr->RESOURCE[resource] =
80005b58:	08a4a023          	sw	a0,128(s1)
80005b5c:	01340537          	lui	a0,0x1340
80005b60:	50d50413          	add	s0,a0,1293 # 134050d <_flash_size+0x124050d>
        }
    } else {
        uint8_t tmp;
        tmp = sysctl_resource_target_get_mode(HPM_SYSCTL, sysctl_resource_xtal);
        sysctl_resource_target_set_mode(HPM_SYSCTL, sysctl_resource_xtal, 0x03);
        clock_add_to_group(clock_usb0, 0);
80005b64:	8522                	mv	a0,s0
80005b66:	4581                	li	a1,0
80005b68:	34e070ef          	jal	8000ceb6 <clock_add_to_group>
80005b6c:	f300c537          	lui	a0,0xf300c
 *
 * @param[in] ptr A USB peripheral base address
 */
static inline void usb_phy_disable_dp_dm_pulldown(USB_Type *ptr)
{
    ptr->PHY_CTRL0 |= 0x001000E0u;
80005b70:	21052583          	lw	a1,528(a0) # f300c210 <__AHB_SRAM_segment_end__+0x2c04210>
80005b74:	0135e5b3          	or	a1,a1,s3
80005b78:	20b52823          	sw	a1,528(a0)
        usb_phy_disable_dp_dm_pulldown(HPM_USB0);
        clock_remove_from_group(clock_usb0, 0);
80005b7c:	8522                	mv	a0,s0
80005b7e:	4581                	li	a1,0
80005b80:	350070ef          	jal	8000ced0 <clock_remove_from_group>

80005b84 <.LBB4_5>:
    return ptr->RESOURCE[resource] & SYSCTL_RESOURCE_LOC_BUSY_MASK;
80005b84:	4d04a503          	lw	a0,1232(s1)
        while (sysctl_resource_target_is_busy(HPM_SYSCTL, sysctl_resource_usb0)) {
80005b88:	0506                	sll	a0,a0,0x1
80005b8a:	fe054de3          	bltz	a0,80005b84 <.LBB4_5>
80005b8e:	f4000537          	lui	a0,0xf4000
        (ptr->RESOURCE[resource] & ~SYSCTL_RESOURCE_MODE_MASK) |
80005b92:	08052583          	lw	a1,128(a0) # f4000080 <__AHB_SRAM_segment_end__+0x3bf8080>
    return SYSCTL_RESOURCE_MODE_GET(ptr->RESOURCE[resource]);
80005b96:	00397613          	and	a2,s2,3
        (ptr->RESOURCE[resource] & ~SYSCTL_RESOURCE_MODE_MASK) |
80005b9a:	99f1                	and	a1,a1,-4
80005b9c:	8dd1                	or	a1,a1,a2
    ptr->RESOURCE[resource] =
80005b9e:	08b52023          	sw	a1,128(a0)

80005ba2 <.LBB4_7>:
80005ba2:	40f2                	lw	ra,28(sp)
80005ba4:	4462                	lw	s0,24(sp)
80005ba6:	44d2                	lw	s1,20(sp)
80005ba8:	4942                	lw	s2,16(sp)
80005baa:	49b2                	lw	s3,12(sp)
            ;
        }
        sysctl_resource_target_set_mode(HPM_SYSCTL, sysctl_resource_xtal, tmp);
    }
}
80005bac:	6105                	add	sp,sp,32
80005bae:	8082                	ret

80005bb0 <.LBB4_8>:
80005bb0:	01340537          	lui	a0,0x1340
80005bb4:	50d50413          	add	s0,a0,1293 # 134050d <_flash_size+0x124050d>
        if (clock_check_in_group(clock_usb0, 0)) {
80005bb8:	8522                	mv	a0,s0
80005bba:	4581                	li	a1,0
80005bbc:	32e070ef          	jal	8000ceea <clock_check_in_group>
80005bc0:	c911                	beqz	a0,80005bd4 <.LBB4_10>
80005bc2:	f300c537          	lui	a0,0xf300c
80005bc6:	21052583          	lw	a1,528(a0) # f300c210 <__AHB_SRAM_segment_end__+0x2c04210>
80005bca:	0135e5b3          	or	a1,a1,s3
80005bce:	20b52823          	sw	a1,528(a0)
80005bd2:	bfc1                	j	80005ba2 <.LBB4_7>

80005bd4 <.LBB4_10>:
            clock_add_to_group(clock_usb0, 0);
80005bd4:	8522                	mv	a0,s0
80005bd6:	4581                	li	a1,0
80005bd8:	2de070ef          	jal	8000ceb6 <clock_add_to_group>
80005bdc:	f300c537          	lui	a0,0xf300c
80005be0:	21052583          	lw	a1,528(a0) # f300c210 <__AHB_SRAM_segment_end__+0x2c04210>
80005be4:	0135e5b3          	or	a1,a1,s3
80005be8:	20b52823          	sw	a1,528(a0)
            clock_remove_from_group(clock_usb0, 0);
80005bec:	8522                	mv	a0,s0
80005bee:	4581                	li	a1,0
80005bf0:	40f2                	lw	ra,28(sp)
80005bf2:	4462                	lw	s0,24(sp)
80005bf4:	44d2                	lw	s1,20(sp)
80005bf6:	4942                	lw	s2,16(sp)
80005bf8:	49b2                	lw	s3,12(sp)
80005bfa:	6105                	add	sp,sp,32
80005bfc:	2d40706f          	j	8000ced0 <clock_remove_from_group>

Disassembly of section .text.board_init_clock:

80005c00 <board_init_clock>:

void board_init_clock(void)
{
80005c00:	1141                	add	sp,sp,-16
80005c02:	c606                	sw	ra,12(sp)
80005c04:	c422                	sw	s0,8(sp)
80005c06:	6505                	lui	a0,0x1
80005c08:	9fc50413          	add	s0,a0,-1540 # 9fc <.LBB2_69>
    uint32_t cpu0_freq = clock_get_frequency(clock_cpu0);
80005c0c:	8522                	mv	a0,s0
80005c0e:	1a3020ef          	jal	800085b0 <clock_get_frequency>
80005c12:	016e35b7          	lui	a1,0x16e3
80005c16:	60058593          	add	a1,a1,1536 # 16e3600 <_flash_size+0x15e3600>

    if (cpu0_freq == PLLCTL_SOC_PLL_REFCLK_FREQ) {
80005c1a:	02b51563          	bne	a0,a1,80005c44 <.LBB5_2>
80005c1e:	f40c0537          	lui	a0,0xf40c0
 * @param [in] ptr PLLCTLV2 base address
 * @param [in] rc24m_cycles Cycles of RC24M clock
 */
static inline void pllctlv2_xtal_set_rampup_time(PLLCTLV2_Type *ptr, uint32_t rc24m_cycles)
{
    ptr->XTAL = (ptr->XTAL & ~PLLCTLV2_XTAL_RAMP_TIME_MASK) | PLLCTLV2_XTAL_RAMP_TIME_SET(rc24m_cycles);
80005c22:	410c                	lw	a1,0(a0)
80005c24:	fff00637          	lui	a2,0xfff00
80005c28:	8df1                	and	a1,a1,a2
80005c2a:	00046637          	lui	a2,0x46
80005c2e:	50060613          	add	a2,a2,1280 # 46500 <__DLM_segment_size__+0x26500>
80005c32:	8dd1                	or	a1,a1,a2
80005c34:	c10c                	sw	a1,0(a0)
80005c36:	f4002537          	lui	a0,0xf4002
 * @param[in] ptr SYSCTL_Type base address
 * @param[in] preset preset
 */
static inline void sysctl_clock_set_preset(SYSCTL_Type *ptr, sysctl_preset_t preset)
{
    ptr->GLOBAL00 = (ptr->GLOBAL00 & ~SYSCTL_GLOBAL00_MUX_MASK) | SYSCTL_GLOBAL00_MUX_SET(preset);
80005c3a:	410c                	lw	a1,0(a0)
80005c3c:	f005f593          	and	a1,a1,-256
80005c40:	0589                	add	a1,a1,2
80005c42:	c10c                	sw	a1,0(a0)

80005c44 <.LBB5_2>:
        /* Select clock setting preset1 */
        sysctl_clock_set_preset(HPM_SYSCTL, 2);
    }

    /* group0[0] */
    clock_add_to_group(clock_cpu0, 0);
80005c44:	8522                	mv	a0,s0
80005c46:	4581                	li	a1,0
80005c48:	26e070ef          	jal	8000ceb6 <clock_add_to_group>
80005c4c:	fffd0537          	lui	a0,0xfffd0
80005c50:	5fe50513          	add	a0,a0,1534 # fffd05fe <__AHB_SRAM_segment_end__+0xfbc85fe>
    clock_add_to_group(clock_ahb, 0);
80005c54:	4581                	li	a1,0
80005c56:	260070ef          	jal	8000ceb6 <clock_add_to_group>
80005c5a:	01011537          	lui	a0,0x1011
80005c5e:	90050513          	add	a0,a0,-1792 # 1010900 <_flash_size+0xf10900>
    clock_add_to_group(clock_lmm0, 0);
80005c62:	4581                	li	a1,0
80005c64:	252070ef          	jal	8000ceb6 <clock_add_to_group>
    clock_add_to_group(clock_mchtmr0, 0);
80005c68:	01020537          	lui	a0,0x1020
80005c6c:	4581                	li	a1,0
80005c6e:	248070ef          	jal	8000ceb6 <clock_add_to_group>
80005c72:	01030537          	lui	a0,0x1030
80005c76:	50b50513          	add	a0,a0,1291 # 103050b <_flash_size+0xf3050b>
    clock_add_to_group(clock_rom, 0);
80005c7a:	4581                	li	a1,0
80005c7c:	23a070ef          	jal	8000ceb6 <clock_add_to_group>
80005c80:	010d0537          	lui	a0,0x10d0
80005c84:	0525                	add	a0,a0,9 # 10d0009 <_flash_size+0xfd0009>
    clock_add_to_group(clock_gptmr0, 0);
80005c86:	4581                	li	a1,0
80005c88:	22e070ef          	jal	8000ceb6 <clock_add_to_group>
80005c8c:	010e0537          	lui	a0,0x10e0
80005c90:	0529                	add	a0,a0,10 # 10e000a <_flash_size+0xfe000a>
    clock_add_to_group(clock_gptmr1, 0);
80005c92:	4581                	li	a1,0
80005c94:	222070ef          	jal	8000ceb6 <clock_add_to_group>
80005c98:	01130537          	lui	a0,0x1130
80005c9c:	053d                	add	a0,a0,15 # 113000f <_flash_size+0x103000f>
    clock_add_to_group(clock_i2c2, 0);
80005c9e:	4581                	li	a1,0
80005ca0:	216070ef          	jal	8000ceb6 <clock_add_to_group>
80005ca4:	01160537          	lui	a0,0x1160
80005ca8:	0549                	add	a0,a0,18 # 1160012 <_flash_size+0x1060012>
    clock_add_to_group(clock_spi1, 0);
80005caa:	4581                	li	a1,0
80005cac:	20a070ef          	jal	8000ceb6 <clock_add_to_group>
80005cb0:	01190537          	lui	a0,0x1190
80005cb4:	0555                	add	a0,a0,21 # 1190015 <_flash_size+0x1090015>
    clock_add_to_group(clock_uart0, 0);
80005cb6:	4581                	li	a1,0
80005cb8:	1fe070ef          	jal	8000ceb6 <clock_add_to_group>
80005cbc:	011c0537          	lui	a0,0x11c0
80005cc0:	0561                	add	a0,a0,24 # 11c0018 <_flash_size+0x10c0018>
    clock_add_to_group(clock_uart3, 0);
80005cc2:	4581                	li	a1,0
80005cc4:	1f2070ef          	jal	8000ceb6 <clock_add_to_group>
80005cc8:	01210537          	lui	a0,0x1210
80005ccc:	30050513          	add	a0,a0,768 # 1210300 <_flash_size+0x1110300>

    clock_add_to_group(clock_watchdog0, 0);
80005cd0:	4581                	li	a1,0
80005cd2:	1e4070ef          	jal	8000ceb6 <clock_add_to_group>
80005cd6:	01220537          	lui	a0,0x1220
80005cda:	30150513          	add	a0,a0,769 # 1220301 <_flash_size+0x1120301>
    clock_add_to_group(clock_watchdog1, 0);
80005cde:	4581                	li	a1,0
80005ce0:	1d6070ef          	jal	8000ceb6 <clock_add_to_group>
80005ce4:	01230537          	lui	a0,0x1230
80005ce8:	50050513          	add	a0,a0,1280 # 1230500 <_flash_size+0x1130500>
    clock_add_to_group(clock_mbx0, 0);
80005cec:	4581                	li	a1,0
80005cee:	1c8070ef          	jal	8000ceb6 <clock_add_to_group>
80005cf2:	01240537          	lui	a0,0x1240
80005cf6:	50c50513          	add	a0,a0,1292 # 124050c <_flash_size+0x114050c>
    clock_add_to_group(clock_tsns, 0);
80005cfa:	4581                	li	a1,0
80005cfc:	1ba070ef          	jal	8000ceb6 <clock_add_to_group>
80005d00:	01250537          	lui	a0,0x1250
80005d04:	50150513          	add	a0,a0,1281 # 1250501 <_flash_size+0x1150501>
    clock_add_to_group(clock_crc0, 0);
80005d08:	4581                	li	a1,0
80005d0a:	1ac070ef          	jal	8000ceb6 <clock_add_to_group>
80005d0e:	01260537          	lui	a0,0x1260
80005d12:	10050513          	add	a0,a0,256 # 1260100 <_flash_size+0x1160100>
    clock_add_to_group(clock_adc0, 0);
80005d16:	4581                	li	a1,0
80005d18:	19e070ef          	jal	8000ceb6 <clock_add_to_group>
80005d1c:	012a0537          	lui	a0,0x12a0
80005d20:	50250513          	add	a0,a0,1282 # 12a0502 <_flash_size+0x11a0502>
    clock_add_to_group(clock_acmp, 0);
80005d24:	4581                	li	a1,0
80005d26:	190070ef          	jal	8000ceb6 <clock_add_to_group>
80005d2a:	01300537          	lui	a0,0x1300
80005d2e:	50850513          	add	a0,a0,1288 # 1300508 <_flash_size+0x1200508>
    clock_add_to_group(clock_kman, 0);
80005d32:	4581                	li	a1,0
80005d34:	182070ef          	jal	8000ceb6 <clock_add_to_group>
80005d38:	01310537          	lui	a0,0x1310
80005d3c:	50950513          	add	a0,a0,1289 # 1310509 <_flash_size+0x1210509>
    clock_add_to_group(clock_gpio, 0);
80005d40:	4581                	li	a1,0
80005d42:	174070ef          	jal	8000ceb6 <clock_add_to_group>
80005d46:	01320537          	lui	a0,0x1320
80005d4a:	50a50513          	add	a0,a0,1290 # 132050a <_flash_size+0x122050a>
    clock_add_to_group(clock_hdma, 0);
80005d4e:	4581                	li	a1,0
80005d50:	166070ef          	jal	8000ceb6 <clock_add_to_group>
80005d54:	01330537          	lui	a0,0x1330
80005d58:	0575                	add	a0,a0,29 # 133001d <_flash_size+0x123001d>
    clock_add_to_group(clock_xpi0, 0);
80005d5a:	4581                	li	a1,0
80005d5c:	15a070ef          	jal	8000ceb6 <clock_add_to_group>
80005d60:	01340537          	lui	a0,0x1340
80005d64:	50d50513          	add	a0,a0,1293 # 134050d <_flash_size+0x124050d>
    clock_add_to_group(clock_usb0, 0);
80005d68:	4581                	li	a1,0
80005d6a:	14c070ef          	jal	8000ceb6 <clock_add_to_group>

    /* Connect Group0 to CPU0 */
    clock_connect_group_to_cpu(0, 0);
80005d6e:	4501                	li	a0,0
80005d70:	4581                	li	a1,0
80005d72:	188070ef          	jal	8000cefa <clock_connect_group_to_cpu>

    /* Bump up DCDC voltage to 1175mv */
    pcfg_dcdc_set_voltage(HPM_PCFG, 1175);
80005d76:	f4104537          	lui	a0,0xf4104
80005d7a:	49700593          	li	a1,1175
80005d7e:	14b000ef          	jal	800066c8 <pcfg_dcdc_set_voltage>

    /* Configure CPU to 360MHz, AXI/AHB to 120MHz */
    sysctl_config_cpu0_domain_clock(HPM_SYSCTL, clock_source_pll0_clk0, 2, 3);
80005d82:	f4000537          	lui	a0,0xf4000
80005d86:	4585                	li	a1,1
80005d88:	4609                	li	a2,2
80005d8a:	468d                	li	a3,3
80005d8c:	305020ef          	jal	80008890 <sysctl_config_cpu0_domain_clock>
    /* Configure PLL0 Post Divider */
    pllctlv2_set_postdiv(HPM_PLLCTLV2, 0, 0, 0);    /* PLL0CLK0: 720MHz */
80005d90:	f40c0537          	lui	a0,0xf40c0
80005d94:	4581                	li	a1,0
80005d96:	4601                	li	a2,0
80005d98:	4681                	li	a3,0
80005d9a:	155000ef          	jal	800066ee <pllctlv2_set_postdiv>
    pllctlv2_set_postdiv(HPM_PLLCTLV2, 0, 1, 3);    /* PLL0CLK1: 450MHz */
80005d9e:	f40c0537          	lui	a0,0xf40c0
80005da2:	4605                	li	a2,1
80005da4:	468d                	li	a3,3
80005da6:	4581                	li	a1,0
80005da8:	147000ef          	jal	800066ee <pllctlv2_set_postdiv>
    pllctlv2_set_postdiv(HPM_PLLCTLV2, 0, 2, 7);    /* PLL0CLK2: 300MHz */
80005dac:	f40c0537          	lui	a0,0xf40c0
80005db0:	4609                	li	a2,2
80005db2:	469d                	li	a3,7
80005db4:	4581                	li	a1,0
80005db6:	139000ef          	jal	800066ee <pllctlv2_set_postdiv>
80005dba:	2aea5537          	lui	a0,0x2aea5
80005dbe:	40050613          	add	a2,a0,1024 # 2aea5400 <_flash_size+0x2ada5400>
    /* Configure PLL0 Frequency to 720MHz */
    pllctlv2_init_pll_with_freq(HPM_PLLCTLV2, 0, 720000000);
80005dc2:	f40c0537          	lui	a0,0xf40c0
80005dc6:	4581                	li	a1,0
80005dc8:	54a040ef          	jal	8000a312 <pllctlv2_init_pll_with_freq>

    clock_update_core_clock();
80005dcc:	142070ef          	jal	8000cf0e <clock_update_core_clock>

    /* Configure mchtmr to 24MHz */
    clock_set_source_divider(clock_mchtmr0, clk_src_osc24m, 1);
80005dd0:	01020537          	lui	a0,0x1020
80005dd4:	4605                	li	a2,1
80005dd6:	4581                	li	a1,0
80005dd8:	40b2                	lw	ra,12(sp)
80005dda:	4422                	lw	s0,8(sp)
80005ddc:	0141                	add	sp,sp,16
80005dde:	0220706f          	j	8000ce00 <clock_set_source_divider>

Disassembly of section .text.board_init_uart_clock:

80005de2 <board_init_uart_clock>:
void board_init_pmp(void)
{
}

uint32_t board_init_uart_clock(UART_Type *ptr)
{
80005de2:	1141                	add	sp,sp,-16
80005de4:	c606                	sw	ra,12(sp)
80005de6:	c422                	sw	s0,8(sp)
80005de8:	f004c5b7          	lui	a1,0xf004c
    uint32_t freq = 0U;
    if (ptr == HPM_UART0) {
80005dec:	00b50d63          	beq	a0,a1,80005e06 <.LBB18_3>
80005df0:	f00405b7          	lui	a1,0xf0040
80005df4:	02b51b63          	bne	a0,a1,80005e2a <.LBB18_5>
80005df8:	01190437          	lui	s0,0x1190
80005dfc:	0455                	add	s0,s0,21 # 1190015 <_flash_size+0x1090015>
        clock_set_source_divider(clock_uart0, clk_src_osc24m, 1);
80005dfe:	4605                	li	a2,1
80005e00:	8522                	mv	a0,s0
80005e02:	4581                	li	a1,0
80005e04:	a039                	j	80005e12 <.LBB18_4>

80005e06 <.LBB18_3>:
80005e06:	011c0437          	lui	s0,0x11c0
80005e0a:	0461                	add	s0,s0,24 # 11c0018 <_flash_size+0x10c0018>
        clock_add_to_group(clock_uart0, 0);
        freq = clock_get_frequency(clock_uart0);
    } else if (ptr == HPM_UART3) {
        clock_set_source_divider(clock_uart3, clk_src_pll0_clk2, 6); /* 50MHz */
80005e0c:	458d                	li	a1,3
80005e0e:	4619                	li	a2,6
80005e10:	8522                	mv	a0,s0

80005e12 <.LBB18_4>:
80005e12:	7ef060ef          	jal	8000ce00 <clock_set_source_divider>
80005e16:	8522                	mv	a0,s0
80005e18:	4581                	li	a1,0
80005e1a:	09c070ef          	jal	8000ceb6 <clock_add_to_group>
80005e1e:	8522                	mv	a0,s0
80005e20:	40b2                	lw	ra,12(sp)
80005e22:	4422                	lw	s0,8(sp)
80005e24:	0141                	add	sp,sp,16
80005e26:	78a0206f          	j	800085b0 <clock_get_frequency>

80005e2a <.LBB18_5>:
        clock_add_to_group(clock_uart3, 0);
        freq = clock_get_frequency(clock_uart3);
    }

    return freq;
80005e2a:	4501                	li	a0,0
80005e2c:	40b2                	lw	ra,12(sp)
80005e2e:	4422                	lw	s0,8(sp)
80005e30:	0141                	add	sp,sp,16
80005e32:	8082                	ret

Disassembly of section .text.init_xtal_pins:

80005e34 <init_xtal_pins>:
    /* Package QFN32 should be set PA30 and PA31 pins as analog type to enable xtal. */
    /*
     * HPM_IOC->PAD[IOC_PAD_PA30].FUNC_CTL = IOC_PAD_FUNC_CTL_ANALOG_MASK;
     * HPM_IOC->PAD[IOC_PAD_PA31].FUNC_CTL = IOC_PAD_FUNC_CTL_ANALOG_MASK;
     */
}
80005e34:	8082                	ret

Disassembly of section .text.init_py_pins_as_pgpio:

80005e36 <init_py_pins_as_pgpio>:

void init_py_pins_as_pgpio(void)
{
80005e36:	f4119537          	lui	a0,0xf4119
    /* Set PY00-PY05 default function to PGPIO */
    HPM_PIOC->PAD[IOC_PAD_PY00].FUNC_CTL = PIOC_PY00_FUNC_CTL_PGPIO_Y_00;
80005e3a:	e0052023          	sw	zero,-512(a0) # f4118e00 <__AHB_SRAM_segment_end__+0x3d10e00>
    HPM_PIOC->PAD[IOC_PAD_PY01].FUNC_CTL = PIOC_PY01_FUNC_CTL_PGPIO_Y_01;
80005e3e:	e0052423          	sw	zero,-504(a0)
    HPM_PIOC->PAD[IOC_PAD_PY02].FUNC_CTL = PIOC_PY02_FUNC_CTL_PGPIO_Y_02;
80005e42:	e0052823          	sw	zero,-496(a0)
    HPM_PIOC->PAD[IOC_PAD_PY03].FUNC_CTL = PIOC_PY03_FUNC_CTL_PGPIO_Y_03;
80005e46:	e0052c23          	sw	zero,-488(a0)
    HPM_PIOC->PAD[IOC_PAD_PY04].FUNC_CTL = PIOC_PY04_FUNC_CTL_PGPIO_Y_04;
80005e4a:	e2052023          	sw	zero,-480(a0)
    HPM_PIOC->PAD[IOC_PAD_PY05].FUNC_CTL = PIOC_PY05_FUNC_CTL_PGPIO_Y_05;
80005e4e:	e2052423          	sw	zero,-472(a0)
}
80005e52:	8082                	ret

Disassembly of section .text.init_usb_pins:

80005e54 <init_usb_pins>:
    HPM_IOC->PAD[IOC_PAD_PB13].FUNC_CTL = IOC_PAD_FUNC_CTL_ANALOG_MASK;         /* ADC_IU:   ADC0.5 /ADC1.5  */
    HPM_IOC->PAD[IOC_PAD_PB14].FUNC_CTL = IOC_PAD_FUNC_CTL_ANALOG_MASK;         /* ADC_IV:   ADC0.6 /ADC1.6  */
}

void init_usb_pins(void)
{
80005e54:	f4040537          	lui	a0,0xf4040
80005e58:	10000593          	li	a1,256
    HPM_IOC->PAD[IOC_PAD_PA24].FUNC_CTL = IOC_PAD_FUNC_CTL_ANALOG_MASK;
80005e5c:	0cb52023          	sw	a1,192(a0) # f40400c0 <__AHB_SRAM_segment_end__+0x3c380c0>
    HPM_IOC->PAD[IOC_PAD_PA25].FUNC_CTL = IOC_PAD_FUNC_CTL_ANALOG_MASK;
80005e60:	0cb52423          	sw	a1,200(a0)
80005e64:	f4041537          	lui	a0,0xf4041
80005e68:	45e5                	li	a1,25

    /* USB0_ID */
    HPM_IOC->PAD[IOC_PAD_PY00].FUNC_CTL = IOC_PY00_FUNC_CTL_USB0_ID;
80005e6a:	e0b52023          	sw	a1,-512(a0) # f4040e00 <__AHB_SRAM_segment_end__+0x3c38e00>
    /* USB0_OC */
    HPM_IOC->PAD[IOC_PAD_PY01].FUNC_CTL = IOC_PY01_FUNC_CTL_USB0_OC;
80005e6e:	e0b52423          	sw	a1,-504(a0)
    /* USB0_PWR */
    HPM_IOC->PAD[IOC_PAD_PY02].FUNC_CTL = IOC_PY02_FUNC_CTL_USB0_PWR;
80005e72:	e0b52823          	sw	a1,-496(a0)
80005e76:	f4119537          	lui	a0,0xf4119
80005e7a:	458d                	li	a1,3

    /* PY port IO needs to configure PIOC as well */
    HPM_PIOC->PAD[IOC_PAD_PY00].FUNC_CTL = PIOC_PY00_FUNC_CTL_SOC_GPIO_Y_00;
80005e7c:	e0b52023          	sw	a1,-512(a0) # f4118e00 <__AHB_SRAM_segment_end__+0x3d10e00>
    HPM_PIOC->PAD[IOC_PAD_PY01].FUNC_CTL = PIOC_PY01_FUNC_CTL_SOC_GPIO_Y_01;
80005e80:	e0b52423          	sw	a1,-504(a0)
    HPM_PIOC->PAD[IOC_PAD_PY02].FUNC_CTL = PIOC_PY02_FUNC_CTL_SOC_GPIO_Y_02;
80005e84:	e0b52823          	sw	a1,-496(a0)
}
80005e88:	8082                	ret

Disassembly of section .text.init_led_pins_as_gpio:

80005e8a <init_led_pins_as_gpio>:

void init_led_pins_as_gpio(void)
{
80005e8a:	f4040537          	lui	a0,0xf4040
    HPM_IOC->PAD[IOC_PAD_PA10].FUNC_CTL = IOC_PA10_FUNC_CTL_GPIO_A_10;
80005e8e:	04052823          	sw	zero,80(a0) # f4040050 <__AHB_SRAM_segment_end__+0x3c38050>
    HPM_IOC->PAD[IOC_PAD_PB10].FUNC_CTL = IOC_PB10_FUNC_CTL_GPIO_B_10;
80005e92:	14052823          	sw	zero,336(a0)
    HPM_IOC->PAD[IOC_PAD_PB11].FUNC_CTL = IOC_PB11_FUNC_CTL_GPIO_B_11;
80005e96:	14052c23          	sw	zero,344(a0)
}
80005e9a:	8082                	ret

Disassembly of section .text.dma_mgr_isr_handler:

80005e9c <dma_mgr_isr_handler>:
 *
 *  Codes
 *
 *****************************************************************************************************************/
void dma_mgr_isr_handler(DMA_Type *ptr, uint32_t instance)
{
80005e9c:	7179                	add	sp,sp,-48
80005e9e:	d606                	sw	ra,44(sp)
80005ea0:	d422                	sw	s0,40(sp)
80005ea2:	d226                	sw	s1,36(sp)
80005ea4:	d04a                	sw	s2,32(sp)
80005ea6:	ce4e                	sw	s3,28(sp)
80005ea8:	cc52                	sw	s4,24(sp)
80005eaa:	ca56                	sw	s5,20(sp)
80005eac:	c85a                	sw	s6,16(sp)
80005eae:	c65e                	sw	s7,12(sp)
80005eb0:	c462                	sw	s8,8(sp)
80005eb2:	c266                	sw	s9,4(sp)
80005eb4:	89aa                	mv	s3,a0
80005eb6:	4c01                	li	s8,0
    uint32_t int_disable_mask;
    uint32_t chn_int_stat;
    dma_chn_context_t *chn_ctx;

    for (uint8_t channel = 0; channel < DMA_SOC_CHANNEL_NUM; channel++) {
80005eb8:	04050913          	add	s2,a0,64
80005ebc:	48000513          	li	a0,1152
80005ec0:	02a58533          	mul	a0,a1,a0
80005ec4:	000805b7          	lui	a1,0x80
80005ec8:	2e858593          	add	a1,a1,744 # 802e8 <s_dma_mngr_ctx>
80005ecc:	952e                	add	a0,a0,a1
80005ece:	01450413          	add	s0,a0,20
80005ed2:	4a05                	li	s4,1
80005ed4:	02000a93          	li	s5,32
80005ed8:	4b41                	li	s6,16
80005eda:	a801                	j	80005eea <.LBB1_2>

80005edc <.LBB1_1>:
80005edc:	0c05                	add	s8,s8,1
80005ede:	02090913          	add	s2,s2,32
80005ee2:	02440413          	add	s0,s0,36
80005ee6:	0b5c0b63          	beq	s8,s5,80005f9c <.LBB1_27>

80005eea <.LBB1_2>:
 * @param[in] ch_index Target channel index to be checked
 * @return uint32_t Interrupt mask
 */
static inline uint32_t dma_check_channel_interrupt_mask(DMAV2_Type *ptr, uint8_t ch_index)
{
    return ptr->CHCTRL[ch_index].CTRL & DMA_INTERRUPT_MASK_ALL;
80005eea:	00092b83          	lw	s7,0(s2)
    if (ptr->INTTCSTS & (1 << ch_index)) {
80005eee:	0289a583          	lw	a1,40(s3)
80005ef2:	018a1533          	sll	a0,s4,s8
80005ef6:	8de9                	and	a1,a1,a0
80005ef8:	c589                	beqz	a1,80005f02 <.LBB1_4>
        ptr->INTTCSTS = (1 << ch_index); /* W1C clear status*/
80005efa:	02a9a423          	sw	a0,40(s3)
80005efe:	44a1                	li	s1,8
80005f00:	a011                	j	80005f04 <.LBB1_5>

80005f02 <.LBB1_4>:
80005f02:	4481                	li	s1,0

80005f04 <.LBB1_5>:
    if (ptr->INTHALFSTS & (1 << ch_index)) {
80005f04:	0249a583          	lw	a1,36(s3)
80005f08:	8de9                	and	a1,a1,a0
80005f0a:	c581                	beqz	a1,80005f12 <.LBB1_7>
        dma_status |= DMA_CHANNEL_STATUS_HALF_TC;
80005f0c:	04c1                	add	s1,s1,16
        ptr->INTHALFSTS = (1 << ch_index); /* W1C clear status*/
80005f0e:	02a9a223          	sw	a0,36(s3)

80005f12 <.LBB1_7>:
    if (ptr->INTERRSTS & (1 << ch_index)) {
80005f12:	0309a583          	lw	a1,48(s3)
80005f16:	8de9                	and	a1,a1,a0
80005f18:	c589                	beqz	a1,80005f22 <.LBB1_9>
        dma_status |= DMA_CHANNEL_STATUS_ERROR;
80005f1a:	0024e493          	or	s1,s1,2
        ptr->INTERRSTS = (1 << ch_index); /* W1C clear status*/
80005f1e:	02a9a823          	sw	a0,48(s3)

80005f22 <.LBB1_9>:
    if (ptr->INTABORTSTS & (1 << ch_index)) {
80005f22:	02c9a583          	lw	a1,44(s3)
80005f26:	8de9                	and	a1,a1,a0
80005f28:	c589                	beqz	a1,80005f32 <.LBB1_11>
        dma_status |= DMA_CHANNEL_STATUS_ABORT;
80005f2a:	0044e493          	or	s1,s1,4
        ptr->INTABORTSTS = (1 << ch_index); /* W1C clear status*/
80005f2e:	02a9a623          	sw	a0,44(s3)

80005f32 <.LBB1_11>:
    if (dma_status == 0) {
80005f32:	0014bc93          	seqz	s9,s1
        int_disable_mask = dma_check_channel_interrupt_mask(ptr, channel);
        chn_int_stat = dma_check_transfer_status(ptr, channel);
        chn_ctx = &HPM_DMA_MGR->channels[instance][channel];

        if (((int_disable_mask & DMA_MGR_INTERRUPT_MASK_TC) == 0) && ((chn_int_stat & DMA_MGR_CHANNEL_STATUS_TC) != 0)) {
80005f36:	002bf513          	and	a0,s7,2
80005f3a:	9ca6                	add	s9,s9,s1
80005f3c:	e919                	bnez	a0,80005f52 <.LBB1_15>
80005f3e:	008cf513          	and	a0,s9,8
80005f42:	c901                	beqz	a0,80005f52 <.LBB1_15>
            if (chn_ctx->tc_cb != NULL) {
80005f44:	4414                	lw	a3,8(s0)
80005f46:	c691                	beqz	a3,80005f52 <.LBB1_15>
                chn_ctx->tc_cb(ptr, channel, chn_ctx->tc_cb_data_ptr);
80005f48:	ff842603          	lw	a2,-8(s0)
80005f4c:	854e                	mv	a0,s3
80005f4e:	85e2                	mv	a1,s8
80005f50:	9682                	jalr	a3

80005f52 <.LBB1_15>:
80005f52:	010bf513          	and	a0,s7,16
            }
        }
        if (((int_disable_mask & DMA_MGR_INTERRUPT_MASK_HALF_TC) == 0) && ((chn_int_stat & DMA_MGR_CHANNEL_STATUS_HALF_TC) != 0)) {
80005f56:	e911                	bnez	a0,80005f6a <.LBB1_19>
80005f58:	0164e963          	bltu	s1,s6,80005f6a <.LBB1_19>
            if (chn_ctx->half_tc_cb != NULL) {
80005f5c:	4454                	lw	a3,12(s0)
80005f5e:	c691                	beqz	a3,80005f6a <.LBB1_19>
                chn_ctx->half_tc_cb(ptr, channel, chn_ctx->half_tc_cb_data_ptr);
80005f60:	ffc42603          	lw	a2,-4(s0)
80005f64:	854e                	mv	a0,s3
80005f66:	85e2                	mv	a1,s8
80005f68:	9682                	jalr	a3

80005f6a <.LBB1_19>:
            }
        }
        if (((int_disable_mask & DMA_MGR_INTERRUPT_MASK_ERROR) == 0) && ((chn_int_stat & DMA_MGR_CHANNEL_STATUS_ERROR) != 0)) {
80005f6a:	004bf513          	and	a0,s7,4
80005f6e:	e911                	bnez	a0,80005f82 <.LBB1_23>
80005f70:	002cf513          	and	a0,s9,2
80005f74:	c519                	beqz	a0,80005f82 <.LBB1_23>
            if (chn_ctx->error_cb != NULL) {
80005f76:	4814                	lw	a3,16(s0)
80005f78:	c689                	beqz	a3,80005f82 <.LBB1_23>
                chn_ctx->error_cb(ptr, channel, chn_ctx->error_cb_data_ptr);
80005f7a:	4010                	lw	a2,0(s0)
80005f7c:	854e                	mv	a0,s3
80005f7e:	85e2                	mv	a1,s8
80005f80:	9682                	jalr	a3

80005f82 <.LBB1_23>:
            }
        }
        if (((int_disable_mask & DMA_MGR_INTERRUPT_MASK_ABORT) == 0) && ((chn_int_stat & DMA_MGR_CHANNEL_STATUS_ABORT) != 0)) {
80005f82:	008bf513          	and	a0,s7,8
80005f86:	f939                	bnez	a0,80005edc <.LBB1_1>
80005f88:	004cf513          	and	a0,s9,4
80005f8c:	d921                	beqz	a0,80005edc <.LBB1_1>
            if (chn_ctx->abort_cb != NULL) {
80005f8e:	4854                	lw	a3,20(s0)
80005f90:	d6b1                	beqz	a3,80005edc <.LBB1_1>
                chn_ctx->abort_cb(ptr, channel, chn_ctx->abort_cb_data_ptr);
80005f92:	4050                	lw	a2,4(s0)
80005f94:	854e                	mv	a0,s3
80005f96:	85e2                	mv	a1,s8
80005f98:	9682                	jalr	a3
80005f9a:	b789                	j	80005edc <.LBB1_1>

80005f9c <.LBB1_27>:
80005f9c:	50b2                	lw	ra,44(sp)
80005f9e:	5422                	lw	s0,40(sp)
80005fa0:	5492                	lw	s1,36(sp)
80005fa2:	5902                	lw	s2,32(sp)
80005fa4:	49f2                	lw	s3,28(sp)
80005fa6:	4a62                	lw	s4,24(sp)
80005fa8:	4ad2                	lw	s5,20(sp)
80005faa:	4b42                	lw	s6,16(sp)
80005fac:	4bb2                	lw	s7,12(sp)
80005fae:	4c22                	lw	s8,8(sp)
80005fb0:	4c92                	lw	s9,4(sp)
            }
        }
    }
}
80005fb2:	6145                	add	sp,sp,48
80005fb4:	8082                	ret

Disassembly of section .text.dma_mgr_init:

80005fb6 <dma_mgr_init>:
{
    restore_global_irq(level);
}

void dma_mgr_init(void)
{
80005fb6:	1141                	add	sp,sp,-16
80005fb8:	c606                	sw	ra,12(sp)
80005fba:	c422                	sw	s0,8(sp)
80005fbc:	c226                	sw	s1,4(sp)
    (void) memset(HPM_DMA_MGR, 0, sizeof(*HPM_DMA_MGR));
80005fbe:	00080437          	lui	s0,0x80
80005fc2:	2e840493          	add	s1,s0,744 # 802e8 <s_dma_mngr_ctx>
80005fc6:	00848513          	add	a0,s1,8
80005fca:	48000613          	li	a2,1152
80005fce:	4581                	li	a1,0
80005fd0:	349070ef          	jal	8000db18 <memset>
80005fd4:	f00c8537          	lui	a0,0xf00c8
    HPM_DMA_MGR->dma_instance[0].base = HPM_HDMA,
80005fd8:	2ea42423          	sw	a0,744(s0)
80005fdc:	02200513          	li	a0,34
    HPM_DMA_MGR->dma_instance[0].irq_num = IRQn_HDMA;
80005fe0:	c0c8                	sw	a0,4(s1)
80005fe2:	40b2                	lw	ra,12(sp)
80005fe4:	4422                	lw	s0,8(sp)
80005fe6:	4492                	lw	s1,4(sp)
 #if defined(DMA_SOC_MAX_COUNT) && (DMA_SOC_MAX_COUNT > 1)
    HPM_DMA_MGR->dma_instance[1].base = HPM_XDMA;
    HPM_DMA_MGR->dma_instance[1].irq_num = IRQn_XDMA;
 #endif
}
80005fe8:	0141                	add	sp,sp,16
80005fea:	8082                	ret

Disassembly of section .text.dma_mgr_request_resource:

80005fec <dma_mgr_request_resource>:

hpm_stat_t dma_mgr_request_resource(dma_resource_t *resource)
{
    hpm_stat_t status;

    if (resource == NULL) {
80005fec:	cd05                	beqz	a0,80006024 <.LBB3_4>
80005fee:	1141                	add	sp,sp,-16
 * @param[in] mask interrupt mask to be disabled
 * @retval current mstatus value before irq mask is disabled
 */
ATTR_ALWAYS_INLINE static inline uint32_t disable_global_irq(uint32_t mask)
{
    return read_clear_csr(CSR_MSTATUS, mask);
80005ff0:	c602                	sw	zero,12(sp)
80005ff2:	45a1                	li	a1,8
80005ff4:	3005b5f3          	csrrc	a1,mstatus,a1
80005ff8:	4681                	li	a3,0
80005ffa:	c62e                	sw	a1,12(sp)
80005ffc:	4832                	lw	a6,12(sp)
80005ffe:	000805b7          	lui	a1,0x80
80006002:	2f058713          	add	a4,a1,752 # 802f0 <s_dma_mngr_ctx+0x8>
80006006:	0007b5b7          	lui	a1,0x7b
8000600a:	8f058593          	add	a1,a1,-1808 # 7a8f0 <__DLM_segment_size__+0x5a8f0>
8000600e:	02000793          	li	a5,32

80006012 <.LBB3_2>:
        uint32_t channel;
        bool has_found = false;
        uint32_t level = dma_mgr_enter_critical();
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
            for (channel = 0; channel < DMA_SOC_CHANNEL_NUM; channel++) {
                if (!HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80006012:	00074603          	lbu	a2,0(a4)
80006016:	ca09                	beqz	a2,80006028 <.LBB3_5>
            for (channel = 0; channel < DMA_SOC_CHANNEL_NUM; channel++) {
80006018:	0685                	add	a3,a3,1
8000601a:	02470713          	add	a4,a4,36
8000601e:	fef69ae3          	bne	a3,a5,80006012 <.LBB3_2>
80006022:	a00d                	j	80006044 <.LBB3_6>

80006024 <.LBB3_4>:
80006024:	4509                	li	a0,2
        }

        dma_mgr_exit_critical(level);
    }

    return status;
80006026:	8082                	ret

80006028 <.LBB3_5>:
80006028:	4581                	li	a1,0
8000602a:	4885                	li	a7,1
            resource->base = HPM_DMA_MGR->dma_instance[instance].base;
8000602c:	000807b7          	lui	a5,0x80
80006030:	2e87a603          	lw	a2,744(a5) # 802e8 <s_dma_mngr_ctx>
80006034:	2e878793          	add	a5,a5,744
            resource->irq_num = HPM_DMA_MGR->dma_instance[instance].irq_num;
80006038:	43dc                	lw	a5,4(a5)
            HPM_DMA_MGR->channels[instance][channel].is_allocated = true;
8000603a:	01170023          	sb	a7,0(a4)
            resource->base = HPM_DMA_MGR->dma_instance[instance].base;
8000603e:	c110                	sw	a2,0(a0)
            resource->channel = channel;
80006040:	c154                	sw	a3,4(a0)
            resource->irq_num = HPM_DMA_MGR->dma_instance[instance].irq_num;
80006042:	c51c                	sw	a5,8(a0)

80006044 <.LBB3_6>:
 *
 * @param[in] mask interrupt mask to be restored
 */
ATTR_ALWAYS_INLINE static inline void restore_global_irq(uint32_t mask)
{
    set_csr(CSR_MSTATUS, mask);
80006044:	30082073          	csrs	mstatus,a6
80006048:	0141                	add	sp,sp,16
    return status;
8000604a:	852e                	mv	a0,a1
8000604c:	8082                	ret

Disassembly of section .text.dma_mgr_install_chn_tc_callback:

8000604e <dma_mgr_install_chn_tc_callback>:
    }
    return status;
}

hpm_stat_t dma_mgr_install_chn_tc_callback(const dma_resource_t *resource, dma_mgr_chn_cb_t callback, void *user_data)
{
8000604e:	82aa                	mv	t0,a0
80006050:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
80006052:	04028a63          	beqz	t0,800060a6 <.LBB7_7>
80006056:	0042a803          	lw	a6,4(t0)
8000605a:	46fd                	li	a3,31
8000605c:	0506e563          	bltu	a3,a6,800060a6 <.LBB7_7>
80006060:	000806b7          	lui	a3,0x80
80006064:	2e86a883          	lw	a7,744(a3) # 802e8 <s_dma_mngr_ctx>
80006068:	4701                	li	a4,0
8000606a:	4685                	li	a3,1

8000606c <.LBB7_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
8000606c:	8a85                	and	a3,a3,1
8000606e:	ce85                	beqz	a3,800060a6 <.LBB7_7>
80006070:	87ba                	mv	a5,a4
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
80006072:	0002a303          	lw	t1,0(t0)
80006076:	4681                	li	a3,0
80006078:	4705                	li	a4,1
8000607a:	ff1319e3          	bne	t1,a7,8000606c <.LBB7_3>
8000607e:	02400693          	li	a3,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80006082:	02d806b3          	mul	a3,a6,a3
80006086:	48000713          	li	a4,1152
8000608a:	02e78733          	mul	a4,a5,a4
8000608e:	000807b7          	lui	a5,0x80
80006092:	2e878793          	add	a5,a5,744 # 802e8 <s_dma_mngr_ctx>
80006096:	973e                	add	a4,a4,a5
80006098:	96ba                	add	a3,a3,a4
8000609a:	0086c703          	lbu	a4,8(a3)
8000609e:	c701                	beqz	a4,800060a6 <.LBB7_7>
800060a0:	4501                	li	a0,0
    dma_chn_context_t *chn_ctx = dma_mgr_search_chn_context(resource);

    if (chn_ctx == NULL) {
        status = status_invalid_argument;
    } else {
        chn_ctx->tc_cb_data_ptr = user_data;
800060a2:	c6d0                	sw	a2,12(a3)
        chn_ctx->tc_cb = callback;
800060a4:	cecc                	sw	a1,28(a3)

800060a6 <.LBB7_7>:
        status = status_success;
    }
    return status;
800060a6:	8082                	ret

Disassembly of section .text.dma_mgr_enable_channel:

800060a8 <dma_mgr_enable_channel>:
    }
    return status;
}

hpm_stat_t dma_mgr_enable_channel(const dma_resource_t *resource)
{
800060a8:	85aa                	mv	a1,a0
800060aa:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
800060ac:	c5b5                	beqz	a1,80006118 <.LBB14_8>
800060ae:	0045a803          	lw	a6,4(a1)
800060b2:	467d                	li	a2,31
800060b4:	07066263          	bltu	a2,a6,80006118 <.LBB14_8>
800060b8:	00080637          	lui	a2,0x80
800060bc:	2e862883          	lw	a7,744(a2) # 802e8 <s_dma_mngr_ctx>
800060c0:	4781                	li	a5,0
800060c2:	4605                	li	a2,1

800060c4 <.LBB14_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
800060c4:	8a05                	and	a2,a2,1
800060c6:	ca29                	beqz	a2,80006118 <.LBB14_8>
800060c8:	873e                	mv	a4,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
800060ca:	4194                	lw	a3,0(a1)
800060cc:	4601                	li	a2,0
800060ce:	4785                	li	a5,1
800060d0:	ff169ae3          	bne	a3,a7,800060c4 <.LBB14_3>
800060d4:	02400593          	li	a1,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
800060d8:	02b805b3          	mul	a1,a6,a1
800060dc:	48000613          	li	a2,1152
800060e0:	02c70633          	mul	a2,a4,a2
800060e4:	000806b7          	lui	a3,0x80
800060e8:	2e868693          	add	a3,a3,744 # 802e8 <s_dma_mngr_ctx>
800060ec:	9636                	add	a2,a2,a3
800060ee:	95b2                	add	a1,a1,a2
800060f0:	0085c583          	lbu	a1,8(a1)
800060f4:	c195                	beqz	a1,80006118 <.LBB14_8>
    ptr->CHCTRL[ch_index].CTRL |= DMAV2_CHCTRL_CTRL_ENABLE_MASK;
800060f6:	00581513          	sll	a0,a6,0x5
800060fa:	9546                	add	a0,a0,a7
800060fc:	412c                	lw	a1,64(a0)
800060fe:	0015e593          	or	a1,a1,1
80006102:	c12c                	sw	a1,64(a0)
    if ((ptr->CHEN == 0) || !(ptr->CHEN & 1 << ch_index)) {
80006104:	0348a503          	lw	a0,52(a7)
80006108:	c909                	beqz	a0,8000611a <.LBB14_9>
8000610a:	0348a503          	lw	a0,52(a7)
8000610e:	fff54513          	not	a0,a0
80006112:	01055533          	srl	a0,a0,a6
80006116:	8905                	and	a0,a0,1

80006118 <.LBB14_8>:
    if (chn_ctx == NULL) {
        status = status_invalid_argument;
    } else {
        status = dma_enable_channel(resource->base, resource->channel);
    }
    return status;
80006118:	8082                	ret

8000611a <.LBB14_9>:
8000611a:	4505                	li	a0,1
8000611c:	8082                	ret

Disassembly of section .text.dma_mgr_set_chn_transize:

8000611e <dma_mgr_set_chn_transize>:
    }
    return status;
}

hpm_stat_t dma_mgr_set_chn_transize(const dma_resource_t *resource, uint32_t size)
{
8000611e:	82aa                	mv	t0,a0
80006120:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
80006122:	04028e63          	beqz	t0,8000617e <.LBB24_7>
80006126:	0042a803          	lw	a6,4(t0)
8000612a:	46fd                	li	a3,31
8000612c:	0506e963          	bltu	a3,a6,8000617e <.LBB24_7>
80006130:	000806b7          	lui	a3,0x80
80006134:	2e86a883          	lw	a7,744(a3) # 802e8 <s_dma_mngr_ctx>
80006138:	4781                	li	a5,0
8000613a:	4705                	li	a4,1

8000613c <.LBB24_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
8000613c:	8b05                	and	a4,a4,1
8000613e:	c321                	beqz	a4,8000617e <.LBB24_7>
80006140:	86be                	mv	a3,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
80006142:	0002a603          	lw	a2,0(t0)
80006146:	4701                	li	a4,0
80006148:	4785                	li	a5,1
8000614a:	ff1619e3          	bne	a2,a7,8000613c <.LBB24_3>
8000614e:	02400613          	li	a2,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80006152:	02c80633          	mul	a2,a6,a2
80006156:	48000713          	li	a4,1152
8000615a:	02e686b3          	mul	a3,a3,a4
8000615e:	00080737          	lui	a4,0x80
80006162:	2e870713          	add	a4,a4,744 # 802e8 <s_dma_mngr_ctx>
80006166:	96ba                	add	a3,a3,a4
80006168:	9636                	add	a2,a2,a3
8000616a:	00864603          	lbu	a2,8(a2)
8000616e:	ca01                	beqz	a2,8000617e <.LBB24_7>
80006170:	4501                	li	a0,0
    ptr->CHCTRL[ch_index].TRANSIZE = DMAV2_CHCTRL_TRANSIZE_TRANSIZE_SET(size_in_width);
80006172:	0592                	sll	a1,a1,0x4
80006174:	8191                	srl	a1,a1,0x4
80006176:	0816                	sll	a6,a6,0x5
80006178:	9846                	add	a6,a6,a7
8000617a:	04b82223          	sw	a1,68(a6)

8000617e <.LBB24_7>:
        status = status_invalid_argument;
    } else {
        dma_set_transfer_size(resource->base, resource->channel, size);
        status = status_success;
    }
    return status;
8000617e:	8082                	ret

Disassembly of section .text.dma_mgr_set_chn_src_addr:

80006180 <dma_mgr_set_chn_src_addr>:
    }
    return status;
}

hpm_stat_t dma_mgr_set_chn_src_addr(const dma_resource_t *resource, uint32_t addr)
{
80006180:	82aa                	mv	t0,a0
80006182:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
80006184:	04028c63          	beqz	t0,800061dc <.LBB27_7>
80006188:	0042a803          	lw	a6,4(t0)
8000618c:	46fd                	li	a3,31
8000618e:	0506e763          	bltu	a3,a6,800061dc <.LBB27_7>
80006192:	000806b7          	lui	a3,0x80
80006196:	2e86a883          	lw	a7,744(a3) # 802e8 <s_dma_mngr_ctx>
8000619a:	4781                	li	a5,0
8000619c:	4705                	li	a4,1

8000619e <.LBB27_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
8000619e:	8b05                	and	a4,a4,1
800061a0:	cf15                	beqz	a4,800061dc <.LBB27_7>
800061a2:	86be                	mv	a3,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
800061a4:	0002a603          	lw	a2,0(t0)
800061a8:	4701                	li	a4,0
800061aa:	4785                	li	a5,1
800061ac:	ff1619e3          	bne	a2,a7,8000619e <.LBB27_3>
800061b0:	02400613          	li	a2,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
800061b4:	02c80633          	mul	a2,a6,a2
800061b8:	48000713          	li	a4,1152
800061bc:	02e686b3          	mul	a3,a3,a4
800061c0:	00080737          	lui	a4,0x80
800061c4:	2e870713          	add	a4,a4,744 # 802e8 <s_dma_mngr_ctx>
800061c8:	96ba                	add	a3,a3,a4
800061ca:	9636                	add	a2,a2,a3
800061cc:	00864603          	lbu	a2,8(a2)
800061d0:	c611                	beqz	a2,800061dc <.LBB27_7>
800061d2:	4501                	li	a0,0
    ptr->CHCTRL[ch_index].SRCADDR = addr;
800061d4:	0816                	sll	a6,a6,0x5
800061d6:	9846                	add	a6,a6,a7
800061d8:	04b82423          	sw	a1,72(a6)

800061dc <.LBB27_7>:
        status = status_invalid_argument;
    } else {
        dma_set_source_address(resource->base, resource->channel, addr);
        status = status_success;
    }
    return status;
800061dc:	8082                	ret

Disassembly of section .text.dma_mgr_set_chn_dst_addr:

800061de <dma_mgr_set_chn_dst_addr>:
}

hpm_stat_t dma_mgr_set_chn_dst_addr(const dma_resource_t *resource, uint32_t addr)
{
800061de:	82aa                	mv	t0,a0
800061e0:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
800061e2:	04028c63          	beqz	t0,8000623a <.LBB28_7>
800061e6:	0042a803          	lw	a6,4(t0)
800061ea:	46fd                	li	a3,31
800061ec:	0506e763          	bltu	a3,a6,8000623a <.LBB28_7>
800061f0:	000806b7          	lui	a3,0x80
800061f4:	2e86a883          	lw	a7,744(a3) # 802e8 <s_dma_mngr_ctx>
800061f8:	4781                	li	a5,0
800061fa:	4705                	li	a4,1

800061fc <.LBB28_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
800061fc:	8b05                	and	a4,a4,1
800061fe:	cf15                	beqz	a4,8000623a <.LBB28_7>
80006200:	86be                	mv	a3,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
80006202:	0002a603          	lw	a2,0(t0)
80006206:	4701                	li	a4,0
80006208:	4785                	li	a5,1
8000620a:	ff1619e3          	bne	a2,a7,800061fc <.LBB28_3>
8000620e:	02400613          	li	a2,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80006212:	02c80633          	mul	a2,a6,a2
80006216:	48000713          	li	a4,1152
8000621a:	02e686b3          	mul	a3,a3,a4
8000621e:	00080737          	lui	a4,0x80
80006222:	2e870713          	add	a4,a4,744 # 802e8 <s_dma_mngr_ctx>
80006226:	96ba                	add	a3,a3,a4
80006228:	9636                	add	a2,a2,a3
8000622a:	00864603          	lbu	a2,8(a2)
8000622e:	c611                	beqz	a2,8000623a <.LBB28_7>
80006230:	4501                	li	a0,0
    ptr->CHCTRL[ch_index].DSTADDR = addr;
80006232:	0816                	sll	a6,a6,0x5
80006234:	9846                	add	a6,a6,a7
80006236:	04b82823          	sw	a1,80(a6)

8000623a <.LBB28_7>:
        status = status_invalid_argument;
    } else {
        dma_set_destination_address(resource->base, resource->channel, addr);
        status = status_success;
    }
    return status;
8000623a:	8082                	ret

Disassembly of section .text.usb_device_qtd_get:

8000623c <usb_device_qtd_get>:
    return &handle->dcd_data->qhd[ep_idx];
}

dcd_qtd_t *usb_device_qtd_get(usb_device_handle_t *handle, uint8_t ep_idx)
{
    return &handle->dcd_data->qtd[ep_idx * USB_SOC_DCD_QTD_COUNT_EACH_ENDPOINT];
8000623c:	4148                	lw	a0,4(a0)
8000623e:	05a2                	sll	a1,a1,0x8
80006240:	952e                	add	a0,a0,a1
80006242:	7ff50513          	add	a0,a0,2047 # f00c87ff <__XPI0_segment_end__+0x6ffc87ff>
80006246:	0505                	add	a0,a0,1
80006248:	8082                	ret

Disassembly of section .text.usb_device_bus_reset:

8000624a <usb_device_bus_reset>:
}

void usb_device_bus_reset(usb_device_handle_t *handle, uint16_t ep0_max_packet_size)
{
8000624a:	1141                	add	sp,sp,-16
8000624c:	c606                	sw	ra,12(sp)
8000624e:	c422                	sw	s0,8(sp)
80006250:	c226                	sw	s1,4(sp)
    dcd_data_t *dcd_data = handle->dcd_data;
80006252:	4140                	lw	s0,4(a0)

    usb_dcd_bus_reset(handle->regs, ep0_max_packet_size);
80006254:	4108                	lw	a0,0(a0)
80006256:	84ae                	mv	s1,a1
80006258:	2725                	jal	80006980 <usb_dcd_bus_reset>
8000625a:	4615                	li	a2,5
8000625c:	062e                	sll	a2,a2,0xb

     /* Queue Head & Queue TD */
    memset(dcd_data, 0, sizeof(dcd_data_t));
8000625e:	8522                	mv	a0,s0
80006260:	4581                	li	a1,0
80006262:	0b7070ef          	jal	8000db18 <memset>

    /* Set up Control Endpoints (0 OUT, 1 IN) */
    dcd_data->qhd[0].zero_length_termination = dcd_data->qhd[1].zero_length_termination = 1;
80006266:	4028                	lw	a0,64(s0)
80006268:	200005b7          	lui	a1,0x20000
8000626c:	8d4d                	or	a0,a0,a1
8000626e:	c028                	sw	a0,64(s0)
80006270:	4008                	lw	a0,0(s0)
80006272:	8d4d                	or	a0,a0,a1
80006274:	c008                	sw	a0,0(s0)
    dcd_data->qhd[0].max_packet_size         = dcd_data->qhd[1].max_packet_size         = ep0_max_packet_size;
80006276:	4028                	lw	a0,64(s0)
80006278:	7ff4f593          	and	a1,s1,2047
8000627c:	05c2                	sll	a1,a1,0x10
8000627e:	f8010637          	lui	a2,0xf8010
80006282:	167d                	add	a2,a2,-1 # f800ffff <__AHB_SRAM_segment_end__+0x7c07fff>
80006284:	8d71                	and	a0,a0,a2
80006286:	8d4d                	or	a0,a0,a1
80006288:	c028                	sw	a0,64(s0)
8000628a:	4008                	lw	a0,0(s0)
8000628c:	8d71                	and	a0,a0,a2
8000628e:	8d4d                	or	a0,a0,a1
80006290:	c008                	sw	a0,0(s0)
80006292:	4505                	li	a0,1
    dcd_data->qhd[0].qtd_overlay.next        = dcd_data->qhd[1].qtd_overlay.next        = USB_SOC_DCD_QTD_NEXT_INVALID;
80006294:	c428                	sw	a0,72(s0)
80006296:	c408                	sw	a0,8(s0)

    /* OUT only */
    dcd_data->qhd[0].int_on_setup = 1;
80006298:	4008                	lw	a0,0(s0)
8000629a:	65a1                	lui	a1,0x8
8000629c:	8d4d                	or	a0,a0,a1
8000629e:	c008                	sw	a0,0(s0)
800062a0:	40b2                	lw	ra,12(sp)
800062a2:	4422                	lw	s0,8(sp)
800062a4:	4492                	lw	s1,4(sp)
}
800062a6:	0141                	add	sp,sp,16
800062a8:	8082                	ret

Disassembly of section .text.usb_device_init:

800062aa <usb_device_init>:

bool usb_device_init(usb_device_handle_t *handle, uint32_t int_mask)
{
800062aa:	1141                	add	sp,sp,-16
800062ac:	c606                	sw	ra,12(sp)
800062ae:	c422                	sw	s0,8(sp)
800062b0:	c226                	sw	s1,4(sp)
800062b2:	c04a                	sw	s2,0(sp)
    /* Clear memroy */
    if (handle->dcd_data == NULL) {
800062b4:	4140                	lw	s0,4(a0)
800062b6:	cc0d                	beqz	s0,800062f0 <.LBB3_2>
800062b8:	84aa                	mv	s1,a0
800062ba:	892e                	mv	s2,a1
800062bc:	4615                	li	a2,5
800062be:	062e                	sll	a2,a2,0xb
        return false;
    }

    memset(handle->dcd_data, 0, sizeof(dcd_data_t));
800062c0:	8522                	mv	a0,s0
800062c2:	4581                	li	a1,0
800062c4:	055070ef          	jal	8000db18 <memset>

    /* Initialize controller in device mode */
    usb_dcd_init(handle->regs);
800062c8:	4088                	lw	a0,0(s1)
800062ca:	2711                	jal	800069ce <usb_dcd_init>

    /* Set endpoint list address */
    usb_dcd_set_edpt_list_addr(handle->regs, core_local_mem_to_sys_address(0,  (uint32_t)handle->dcd_data->qhd));
800062cc:	40c8                	lw	a0,4(s1)
800062ce:	408c                	lw	a1,0(s1)
 * @param[in] ptr A USB peripheral base address
 * @param[in] addr A start address of the endpoint qtd list
 */
static inline void usb_dcd_set_edpt_list_addr(USB_Type *ptr, uint32_t addr)
{
    ptr->ENDPTLISTADDR = addr & USB_ENDPTLISTADDR_EPBASE_MASK;
800062d0:	80057513          	and	a0,a0,-2048
800062d4:	14a5ac23          	sw	a0,344(a1) # 8158 <.LBB14_4+0xe>

    /* Clear status */
    usb_clear_status_flags(handle->regs, usb_get_status_flags(handle->regs));
800062d8:	4088                	lw	a0,0(s1)
    return ptr->USBSTS;
800062da:	14452583          	lw	a1,324(a0)
    ptr->USBSTS = mask;
800062de:	14b52223          	sw	a1,324(a0)
    ptr->USBINTR |= mask;
800062e2:	14852583          	lw	a1,328(a0)
800062e6:	0125e5b3          	or	a1,a1,s2
800062ea:	14b52423          	sw	a1,328(a0)

    /* Enable interrupt mask */
    usb_enable_interrupts(handle->regs, int_mask);

    /* Connect */
    usb_dcd_connect(handle->regs);
800062ee:	27b5                	jal	80006a5a <usb_dcd_connect>

800062f0 <.LBB3_2>:
    if (handle->dcd_data == NULL) {
800062f0:	00803533          	snez	a0,s0
800062f4:	40b2                	lw	ra,12(sp)
800062f6:	4422                	lw	s0,8(sp)
800062f8:	4492                	lw	s1,4(sp)
800062fa:	4902                	lw	s2,0(sp)

    return true;
}
800062fc:	0141                	add	sp,sp,16
800062fe:	8082                	ret

Disassembly of section .text.usb_device_get_address:

80006300 <usb_device_get_address>:
    usb_dcd_set_address(handle->regs, dev_addr);
}

uint8_t usb_device_get_address(usb_device_handle_t *handle)
{
    return usb_dcd_get_device_addr(handle->regs);
80006300:	4108                	lw	a0,0(a0)
 * @param[in] ptr A USB peripheral base address
 * @retval The endpoint address
 */
static inline uint8_t usb_dcd_get_device_addr(USB_Type *ptr)
{
    return USB_DEVICEADDR_USBADR_GET(ptr->DEVICEADDR);
80006302:	15452503          	lw	a0,340(a0)
80006306:	8165                	srl	a0,a0,0x19
80006308:	8082                	ret

Disassembly of section .text.usb_device_get_port_ccs:

8000630a <usb_device_get_port_ccs>:
    usb_dcd_disconnect(handle->regs);
}

bool usb_device_get_port_ccs(usb_device_handle_t *handle)
{
    return usb_get_port_ccs(handle->regs);
8000630a:	4108                	lw	a0,0(a0)
    return USB_PORTSC1_CCS_GET(ptr->PORTSC1);
8000630c:	18452503          	lw	a0,388(a0)
80006310:	8905                	and	a0,a0,1
80006312:	8082                	ret

Disassembly of section .text.usb_device_edpt_open:

80006314 <usb_device_edpt_open>:
/*---------------------------------------------------------------------
 * Endpoint API
 *---------------------------------------------------------------------
 */
bool usb_device_edpt_open(usb_device_handle_t *handle, usb_endpoint_config_t *config)
{
80006314:	1141                	add	sp,sp,-16
80006316:	c606                	sw	ra,12(sp)
80006318:	c422                	sw	s0,8(sp)
8000631a:	c226                	sw	s1,4(sp)
8000631c:	c04a                	sw	s2,0(sp)
8000631e:	842e                	mv	s0,a1
    uint8_t const epnum  = config->ep_addr & 0x0f;
80006320:	0015c583          	lbu	a1,1(a1)
80006324:	892a                	mv	s2,a0
    uint8_t const dir = (config->ep_addr & 0x80) >> 7;
    uint8_t const ep_idx = 2 * epnum + dir;
80006326:	0075d513          	srl	a0,a1,0x7
8000632a:	0586                	sll	a1,a1,0x1
    if (epnum >= USB_SOC_DCD_MAX_ENDPOINT_COUNT) {
        return false;
    }

    /* Prepare Queue Head */
    p_qhd = &handle->dcd_data->qhd[ep_idx];
8000632c:	00492483          	lw	s1,4(s2)
    uint8_t const ep_idx = 2 * epnum + dir;
80006330:	8d4d                	or	a0,a0,a1
80006332:	897d                	and	a0,a0,31
    p_qhd = &handle->dcd_data->qhd[ep_idx];
80006334:	051a                	sll	a0,a0,0x6
80006336:	94aa                	add	s1,s1,a0
    memset(p_qhd, 0, sizeof(dcd_qhd_t));
80006338:	04000613          	li	a2,64
8000633c:	8526                	mv	a0,s1
8000633e:	4581                	li	a1,0
80006340:	7d8070ef          	jal	8000db18 <memset>

    p_qhd->zero_length_termination = 1;
80006344:	4088                	lw	a0,0(s1)
80006346:	200005b7          	lui	a1,0x20000
8000634a:	8d4d                	or	a0,a0,a1
8000634c:	c088                	sw	a0,0(s1)
    p_qhd->max_packet_size         = config->max_packet_size;
8000634e:	00245503          	lhu	a0,2(s0)
80006352:	408c                	lw	a1,0(s1)
80006354:	7ff57513          	and	a0,a0,2047
80006358:	0542                	sll	a0,a0,0x10
8000635a:	f8010637          	lui	a2,0xf8010
8000635e:	167d                	add	a2,a2,-1 # f800ffff <__AHB_SRAM_segment_end__+0x7c07fff>
80006360:	8df1                	and	a1,a1,a2
80006362:	8d4d                	or	a0,a0,a1
80006364:	c088                	sw	a0,0(s1)
80006366:	4505                	li	a0,1
    p_qhd->qtd_overlay.next        = USB_SOC_DCD_QTD_NEXT_INVALID;
80006368:	c488                	sw	a0,8(s1)

    usb_dcd_edpt_open(handle->regs, config);
8000636a:	00092503          	lw	a0,0(s2)
8000636e:	85a2                	mv	a1,s0
80006370:	2de5                	jal	80006a68 <usb_dcd_edpt_open>

    return true;
}
80006372:	4505                	li	a0,1
80006374:	40b2                	lw	ra,12(sp)
80006376:	4422                	lw	s0,8(sp)
80006378:	4492                	lw	s1,4(sp)
8000637a:	4902                	lw	s2,0(sp)
8000637c:	0141                	add	sp,sp,16
8000637e:	8082                	ret

Disassembly of section .text.usb_device_edpt_stall:

80006380 <usb_device_edpt_stall>:
    return true;
}

void usb_device_edpt_stall(usb_device_handle_t *handle, uint8_t ep_addr)
{
    usb_dcd_edpt_stall(handle->regs, ep_addr);
80006380:	4108                	lw	a0,0(a0)
80006382:	a7b1                	j	80006ace <usb_dcd_edpt_stall>

Disassembly of section .text.usb_device_edpt_clear_stall:

80006384 <usb_device_edpt_clear_stall>:
}

void usb_device_edpt_clear_stall(usb_device_handle_t *handle, uint8_t ep_addr)
{
    usb_dcd_edpt_clear_stall(handle->regs, ep_addr);
80006384:	4108                	lw	a0,0(a0)
80006386:	26c0406f          	j	8000a5f2 <usb_dcd_edpt_clear_stall>

Disassembly of section .text.usb_device_edpt_close:

8000638a <usb_device_edpt_close>:
    return usb_dcd_edpt_check_stall(handle->regs, ep_addr);
}

void usb_device_edpt_close(usb_device_handle_t *handle, uint8_t ep_addr)
{
    usb_dcd_edpt_close(handle->regs, ep_addr);
8000638a:	4108                	lw	a0,0(a0)
8000638c:	29a0406f          	j	8000a626 <usb_dcd_edpt_close>

Disassembly of section .text.dma_setup_channel:

80006390 <dma_setup_channel>:

hpm_stat_t dma_setup_channel(DMAV2_Type *ptr, uint8_t ch_num, dma_channel_config_t *ch, bool start_transfer)
{
    uint32_t tmp;

    if ((ch->dst_width > DMA_SOC_TRANSFER_WIDTH_MAX(ptr))
80006390:	00564f03          	lbu	t5,5(a2)
80006394:	4709                	li	a4,2
            || (ch->src_width > DMA_SOC_TRANSFER_WIDTH_MAX(ptr))
80006396:	01e77463          	bgeu	a4,t5,8000639e <.LBB0_2>

8000639a <.LBB0_1>:
        tmp |= DMAV2_CHCTRL_CTRL_ENABLE_MASK;
    }
    ptr->CHCTRL[ch_num].CTRL = tmp;

    return status_success;
}
8000639a:	853a                	mv	a0,a4
8000639c:	8082                	ret

8000639e <.LBB0_2>:
8000639e:	47fd                	li	a5,31
            || (ch_num >= DMA_SOC_CHANNEL_NUM)
800063a0:	feb7ede3          	bltu	a5,a1,8000639a <.LBB0_1>
800063a4:	00464803          	lbu	a6,4(a2)
800063a8:	4789                	li	a5,2
800063aa:	ff07e8e3          	bltu	a5,a6,8000639a <.LBB0_1>
            || (ch->en_infiniteloop && (ch->linked_ptr != 0))) {
800063ae:	01c64883          	lbu	a7,28(a2)
800063b2:	00088563          	beqz	a7,800063bc <.LBB0_6>
800063b6:	4a5c                	lw	a5,20(a2)
800063b8:	4709                	li	a4,2
    if ((ch->dst_width > DMA_SOC_TRANSFER_WIDTH_MAX(ptr))
800063ba:	f3e5                	bnez	a5,8000639a <.LBB0_1>

800063bc <.LBB0_6>:
    if ((ch->size_in_byte & ((1 << ch->dst_width) - 1))
800063bc:	01862303          	lw	t1,24(a2)
800063c0:	577d                	li	a4,-1
800063c2:	01e71e33          	sll	t3,a4,t5
800063c6:	fffe4293          	not	t0,t3
800063ca:	005377b3          	and	a5,t1,t0
800063ce:	6709                	lui	a4,0x2
800063d0:	f4470713          	add	a4,a4,-188 # 1f44 <SWD_Transfer+0x1c>
     || (ch->src_addr & ((1 << ch->src_width) - 1))
800063d4:	f3f9                	bnez	a5,8000639a <.LBB0_1>
800063d6:	00c62383          	lw	t2,12(a2)
800063da:	4785                	li	a5,1
800063dc:	01079eb3          	sll	t4,a5,a6
800063e0:	fffe8793          	add	a5,t4,-1
800063e4:	00f3f7b3          	and	a5,t2,a5
     || (ch->dst_addr & ((1 << ch->dst_width) - 1))
800063e8:	fbcd                	bnez	a5,8000639a <.LBB0_1>
800063ea:	01cef7b3          	and	a5,t4,t3
800063ee:	6709                	lui	a4,0x2
800063f0:	f4470713          	add	a4,a4,-188 # 1f44 <SWD_Transfer+0x1c>
     || ((1 << ch->src_width) & ((1 << ch->dst_width) - 1))
800063f4:	d3dd                	beqz	a5,8000639a <.LBB0_1>
800063f6:	01062e03          	lw	t3,16(a2)
800063fa:	005e77b3          	and	a5,t3,t0
800063fe:	ffd1                	bnez	a5,8000639a <.LBB0_1>
     || ((ch->linked_ptr & 0x7))) {
80006400:	4a58                	lw	a4,20(a2)
80006402:	00777793          	and	a5,a4,7
    if ((ch->size_in_byte & ((1 << ch->dst_width) - 1))
80006406:	c789                	beqz	a5,80006410 <.LBB0_12>
80006408:	6509                	lui	a0,0x2
8000640a:	f4450513          	add	a0,a0,-188 # 1f44 <SWD_Transfer+0x1c>
}
8000640e:	8082                	ret

80006410 <.LBB0_12>:
    ptr->CHCTRL[ch_num].SRCADDR = DMAV2_CHCTRL_SRCADDR_SRCADDRL_SET(ch->src_addr);
80006410:	00559293          	sll	t0,a1,0x5
80006414:	92aa                	add	t0,t0,a0
80006416:	0472a423          	sw	t2,72(t0)
    ptr->CHCTRL[ch_num].DSTADDR = DMAV2_CHCTRL_DSTADDR_DSTADDRL_SET(ch->dst_addr);
8000641a:	05c2a823          	sw	t3,80(t0)
    ptr->CHCTRL[ch_num].TRANSIZE = DMAV2_CHCTRL_TRANSIZE_TRANSIZE_SET(ch->size_in_byte >> ch->src_width);
8000641e:	010357b3          	srl	a5,t1,a6
80006422:	0792                	sll	a5,a5,0x4
80006424:	8391                	srl	a5,a5,0x4
80006426:	04f2a223          	sw	a5,68(t0)
    ptr->CHCTRL[ch_num].LLPOINTER = DMAV2_CHCTRL_LLPOINTER_LLPOINTERL_SET(ch->linked_ptr >> DMAV2_CHCTRL_LLPOINTER_LLPOINTERL_SHIFT);
8000642a:	04e2ac23          	sw	a4,88(t0)
    ptr->CHCTRL[ch_num].CHANREQCTRL = DMAV2_CHCTRL_CHANREQCTRL_SRCREQSEL_SET(ch_num) | DMAV2_CHCTRL_CHANREQCTRL_DSTREQSEL_SET(ch_num);
8000642e:	01859713          	sll	a4,a1,0x18
80006432:	01059793          	sll	a5,a1,0x10
80006436:	8f5d                	or	a4,a4,a5
80006438:	1f1f07b7          	lui	a5,0x1f1f0
8000643c:	8f7d                	and	a4,a4,a5
8000643e:	04e2a623          	sw	a4,76(t0)
80006442:	4705                	li	a4,1
    ptr->INTHALFSTS  = (1 << ch_index);
80006444:	00b715b3          	sll	a1,a4,a1
80006448:	d14c                	sw	a1,36(a0)
    ptr->INTTCSTS    = (1 << ch_index);
8000644a:	d50c                	sw	a1,40(a0)
    ptr->INTABORTSTS = (1 << ch_index);
8000644c:	d54c                	sw	a1,44(a0)
    ptr->INTERRSTS   = (1 << ch_index);
8000644e:	d90c                	sw	a1,48(a0)
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(ch->handshake_opt)
80006450:	01d64503          	lbu	a0,29(a2)
80006454:	4701                	li	a4,0
    tmp = DMAV2_CHCTRL_CTRL_INFINITELOOP_SET(ch->en_infiniteloop)
80006456:	08fe                	sll	a7,a7,0x1f
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(ch->handshake_opt)
80006458:	057e                	sll	a0,a0,0x1f
        | DMAV2_CHCTRL_CTRL_BURSTOPT_SET(ch->burst_opt)
8000645a:	01e64583          	lbu	a1,30(a2)
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(ch->handshake_opt)
8000645e:	8105                	srl	a0,a0,0x1
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(ch->priority)
80006460:	00064783          	lbu	a5,0(a2)
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(ch->handshake_opt)
80006464:	011568b3          	or	a7,a0,a7
        | DMAV2_CHCTRL_CTRL_BURSTOPT_SET(ch->burst_opt)
80006468:	05fe                	sll	a1,a1,0x1f
8000646a:	818d                	srl	a1,a1,0x3
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(ch->priority)
8000646c:	07fe                	sll	a5,a5,0x1f
        | DMAV2_CHCTRL_CTRL_SRCBURSTSIZE_SET(ch->src_burst_size)
8000646e:	00164503          	lbu	a0,1(a2)
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(ch->priority)
80006472:	8389                	srl	a5,a5,0x2
        | DMAV2_CHCTRL_CTRL_BURSTOPT_SET(ch->burst_opt)
80006474:	8ddd                	or	a1,a1,a5
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(ch->priority)
80006476:	00b8e5b3          	or	a1,a7,a1
        | DMAV2_CHCTRL_CTRL_SRCBURSTSIZE_SET(ch->src_burst_size)
8000647a:	0572                	sll	a0,a0,0x1c
8000647c:	8111                	srl	a0,a0,0x4
        | DMAV2_CHCTRL_CTRL_SRCWIDTH_SET(ch->src_width)
8000647e:	0876                	sll	a6,a6,0x1d
80006480:	00885793          	srl	a5,a6,0x8
        | DMAV2_CHCTRL_CTRL_SRCBURSTSIZE_SET(ch->src_burst_size)
80006484:	8d5d                	or	a0,a0,a5
        | DMAV2_CHCTRL_CTRL_SRCMODE_SET(ch->src_mode)
80006486:	00264783          	lbu	a5,2(a2)
        | DMAV2_CHCTRL_CTRL_SRCWIDTH_SET(ch->src_width)
8000648a:	00a5e833          	or	a6,a1,a0
        | DMAV2_CHCTRL_CTRL_DSTWIDTH_SET(ch->dst_width)
8000648e:	0f4a                	sll	t5,t5,0x12
        | DMAV2_CHCTRL_CTRL_DSTMODE_SET(ch->dst_mode)
80006490:	00364583          	lbu	a1,3(a2)
        | DMAV2_CHCTRL_CTRL_SRCMODE_SET(ch->src_mode)
80006494:	07fe                	sll	a5,a5,0x1f
80006496:	00e7d893          	srl	a7,a5,0xe
        | DMAV2_CHCTRL_CTRL_SRCADDRCTRL_SET(ch->src_addr_ctrl)
8000649a:	00664503          	lbu	a0,6(a2)
        | DMAV2_CHCTRL_CTRL_DSTMODE_SET(ch->dst_mode)
8000649e:	05fe                	sll	a1,a1,0x1f
        | DMAV2_CHCTRL_CTRL_DSTADDRCTRL_SET(ch->dst_addr_ctrl)
800064a0:	00764783          	lbu	a5,7(a2)
        | DMAV2_CHCTRL_CTRL_DSTMODE_SET(ch->dst_mode)
800064a4:	81bd                	srl	a1,a1,0xf
        | DMAV2_CHCTRL_CTRL_SRCADDRCTRL_SET(ch->src_addr_ctrl)
800064a6:	057a                	sll	a0,a0,0x1e
800064a8:	8141                	srl	a0,a0,0x10
        | DMAV2_CHCTRL_CTRL_DSTADDRCTRL_SET(ch->dst_addr_ctrl)
800064aa:	07fa                	sll	a5,a5,0x1e
800064ac:	83c9                	srl	a5,a5,0x12
        | ch->interrupt_mask;
800064ae:	00865603          	lhu	a2,8(a2)
        | DMAV2_CHCTRL_CTRL_DSTWIDTH_SET(ch->dst_width)
800064b2:	00df66b3          	or	a3,t5,a3
        | DMAV2_CHCTRL_CTRL_SRCMODE_SET(ch->src_mode)
800064b6:	0116e6b3          	or	a3,a3,a7
        | DMAV2_CHCTRL_CTRL_DSTMODE_SET(ch->dst_mode)
800064ba:	8dd5                	or	a1,a1,a3
        | DMAV2_CHCTRL_CTRL_SRCADDRCTRL_SET(ch->src_addr_ctrl)
800064bc:	8d4d                	or	a0,a0,a1
        | DMAV2_CHCTRL_CTRL_DSTADDRCTRL_SET(ch->dst_addr_ctrl)
800064be:	01056533          	or	a0,a0,a6
        | ch->interrupt_mask;
800064c2:	8e5d                	or	a2,a2,a5
    if (start_transfer) {
800064c4:	8d51                	or	a0,a0,a2
    ptr->CHCTRL[ch_num].CTRL = tmp;
800064c6:	04a2a023          	sw	a0,64(t0)
}
800064ca:	853a                	mv	a0,a4
800064cc:	8082                	ret

Disassembly of section .text.dma_config_linked_descriptor:

800064ce <dma_config_linked_descriptor>:
hpm_stat_t dma_config_linked_descriptor(DMAV2_Type *ptr, dma_linked_descriptor_t *descriptor, uint8_t ch_num, dma_channel_config_t *config)
{
    (void) ptr;
    uint32_t tmp;

    if ((config->dst_width > DMA_SOC_TRANSFER_WIDTH_MAX(ptr))
800064ce:	0056c703          	lbu	a4,5(a3)
800064d2:	4509                	li	a0,2
            || (config->src_width > DMA_SOC_TRANSFER_WIDTH_MAX(ptr))
800064d4:	00e56e63          	bltu	a0,a4,800064f0 <.LBB2_4>
800064d8:	47fd                	li	a5,31
            || (ch_num >= DMA_SOC_CHANNEL_NUM)
800064da:	00c7eb63          	bltu	a5,a2,800064f0 <.LBB2_4>
800064de:	0046ce03          	lbu	t3,4(a3)
800064e2:	4789                	li	a5,2
800064e4:	01c7e663          	bltu	a5,t3,800064f0 <.LBB2_4>
            || (config->en_infiniteloop)) {
800064e8:	01c6c783          	lbu	a5,28(a3)
800064ec:	4509                	li	a0,2
    if ((config->dst_width > DMA_SOC_TRANSFER_WIDTH_MAX(ptr))
800064ee:	c391                	beqz	a5,800064f2 <.LBB2_5>

800064f0 <.LBB2_4>:
        | config->interrupt_mask
        | DMAV2_CHCTRL_CTRL_ENABLE_MASK;
    descriptor->ctrl = tmp;

    return status_success;
}
800064f0:	8082                	ret

800064f2 <.LBB2_5>:
    if ((config->size_in_byte & ((1 << config->dst_width) - 1))
800064f2:	0186a803          	lw	a6,24(a3)
800064f6:	557d                	li	a0,-1
800064f8:	00e512b3          	sll	t0,a0,a4
800064fc:	fff2c313          	not	t1,t0
80006500:	006877b3          	and	a5,a6,t1
80006504:	6509                	lui	a0,0x2
80006506:	f4450513          	add	a0,a0,-188 # 1f44 <SWD_Transfer+0x1c>
     || (config->src_addr & ((1 << config->src_width) - 1))
8000650a:	f3fd                	bnez	a5,800064f0 <.LBB2_4>
8000650c:	00c6a883          	lw	a7,12(a3)
80006510:	4785                	li	a5,1
80006512:	01c793b3          	sll	t2,a5,t3
80006516:	fff38793          	add	a5,t2,-1
8000651a:	00f8f7b3          	and	a5,a7,a5
     || (config->dst_addr & ((1 << config->dst_width) - 1))
8000651e:	fbe9                	bnez	a5,800064f0 <.LBB2_4>
80006520:	0053f7b3          	and	a5,t2,t0
80006524:	6509                	lui	a0,0x2
80006526:	f4450513          	add	a0,a0,-188 # 1f44 <SWD_Transfer+0x1c>
     || ((1 << config->src_width) & ((1 << config->dst_width) - 1))
8000652a:	d3f9                	beqz	a5,800064f0 <.LBB2_4>
8000652c:	0106a283          	lw	t0,16(a3)
80006530:	0062f7b3          	and	a5,t0,t1
80006534:	ffd5                	bnez	a5,800064f0 <.LBB2_4>
     || ((config->linked_ptr & 0x7))) {
80006536:	0146a303          	lw	t1,20(a3)
8000653a:	00737513          	and	a0,t1,7
    if ((config->size_in_byte & ((1 << config->dst_width) - 1))
8000653e:	c509                	beqz	a0,80006548 <.LBB2_11>
80006540:	6509                	lui	a0,0x2
80006542:	f4450513          	add	a0,a0,-188 # 1f44 <SWD_Transfer+0x1c>
}
80006546:	8082                	ret

80006548 <.LBB2_11>:
    descriptor->src_addr = DMAV2_CHCTRL_SRCADDR_SRCADDRL_SET(config->src_addr);
80006548:	0115a423          	sw	a7,8(a1) # 20000008 <_flash_size+0x1ff00008>
    descriptor->dst_addr = DMAV2_CHCTRL_DSTADDR_DSTADDRL_SET(config->dst_addr);
8000654c:	0055a823          	sw	t0,16(a1)
    descriptor->trans_size = DMAV2_CHCTRL_TRANSIZE_TRANSIZE_SET(config->size_in_byte >> config->src_width);
80006550:	01c857b3          	srl	a5,a6,t3
80006554:	0792                	sll	a5,a5,0x4
80006556:	8391                	srl	a5,a5,0x4
80006558:	c1dc                	sw	a5,4(a1)
    descriptor->linked_ptr = DMAV2_CHCTRL_LLPOINTER_LLPOINTERL_SET(config->linked_ptr >> DMAV2_CHCTRL_LLPOINTER_LLPOINTERL_SHIFT);
8000655a:	0065ac23          	sw	t1,24(a1)
    descriptor->req_ctrl = DMAV2_CHCTRL_CHANREQCTRL_SRCREQSEL_SET(ch_num) | DMAV2_CHCTRL_CHANREQCTRL_DSTREQSEL_SET(ch_num);
8000655e:	01861793          	sll	a5,a2,0x18
80006562:	0642                	sll	a2,a2,0x10
80006564:	8e5d                	or	a2,a2,a5
80006566:	1f1f0837          	lui	a6,0x1f1f0
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(config->handshake_opt)
8000656a:	01d6c783          	lbu	a5,29(a3)
    descriptor->req_ctrl = DMAV2_CHCTRL_CHANREQCTRL_SRCREQSEL_SET(ch_num) | DMAV2_CHCTRL_CHANREQCTRL_DSTREQSEL_SET(ch_num);
8000656e:	01067633          	and	a2,a2,a6
80006572:	c5d0                	sw	a2,12(a1)
        | DMAV2_CHCTRL_CTRL_BURSTOPT_SET(config->burst_opt)
80006574:	01e6c603          	lbu	a2,30(a3)
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(config->handshake_opt)
80006578:	07fe                	sll	a5,a5,0x1f
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(config->priority)
8000657a:	0006c803          	lbu	a6,0(a3)
        | DMAV2_CHCTRL_CTRL_HANDSHAKEOPT_SET(config->handshake_opt)
8000657e:	0017d893          	srl	a7,a5,0x1
        | DMAV2_CHCTRL_CTRL_BURSTOPT_SET(config->burst_opt)
80006582:	067e                	sll	a2,a2,0x1f
80006584:	00365293          	srl	t0,a2,0x3
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(config->priority)
80006588:	087e                	sll	a6,a6,0x1f
        | DMAV2_CHCTRL_CTRL_SRCBURSTSIZE_SET(config->src_burst_size)
8000658a:	0016c783          	lbu	a5,1(a3)
        | DMAV2_CHCTRL_CTRL_SRCWIDTH_SET(config->src_width)
8000658e:	0e76                	sll	t3,t3,0x1d
80006590:	008e5613          	srl	a2,t3,0x8
        | DMAV2_CHCTRL_CTRL_DSTWIDTH_SET(config->dst_width)
80006594:	074a                	sll	a4,a4,0x12
        | DMAV2_CHCTRL_CTRL_SRCBURSTSIZE_SET(config->src_burst_size)
80006596:	00e66333          	or	t1,a2,a4
        | DMAV2_CHCTRL_CTRL_SRCMODE_SET(config->src_mode)
8000659a:	0026c703          	lbu	a4,2(a3)
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(config->priority)
8000659e:	00285813          	srl	a6,a6,0x2
        | DMAV2_CHCTRL_CTRL_SRCBURSTSIZE_SET(config->src_burst_size)
800065a2:	07f2                	sll	a5,a5,0x1c
800065a4:	0047d393          	srl	t2,a5,0x4
        | DMAV2_CHCTRL_CTRL_SRCMODE_SET(config->src_mode)
800065a8:	077e                	sll	a4,a4,0x1f
800065aa:	8339                	srl	a4,a4,0xe
        | DMAV2_CHCTRL_CTRL_SRCWIDTH_SET(config->src_width)
800065ac:	0058e633          	or	a2,a7,t0
        | DMAV2_CHCTRL_CTRL_BURSTOPT_SET(config->burst_opt)
800065b0:	00c36633          	or	a2,t1,a2
        | DMAV2_CHCTRL_CTRL_PRIORITY_SET(config->priority)
800065b4:	01066633          	or	a2,a2,a6
        | DMAV2_CHCTRL_CTRL_DSTMODE_SET(config->dst_mode)
800065b8:	0036c783          	lbu	a5,3(a3)
        | DMAV2_CHCTRL_CTRL_DSTWIDTH_SET(config->dst_width)
800065bc:	961e                	add	a2,a2,t2
        | DMAV2_CHCTRL_CTRL_SRCMODE_SET(config->src_mode)
800065be:	00e66833          	or	a6,a2,a4
        | DMAV2_CHCTRL_CTRL_SRCADDRCTRL_SET(config->src_addr_ctrl)
800065c2:	0066c703          	lbu	a4,6(a3)
        | DMAV2_CHCTRL_CTRL_DSTMODE_SET(config->dst_mode)
800065c6:	07fe                	sll	a5,a5,0x1f
800065c8:	83bd                	srl	a5,a5,0xf
        | DMAV2_CHCTRL_CTRL_DSTADDRCTRL_SET(config->dst_addr_ctrl)
800065ca:	0076c603          	lbu	a2,7(a3)
        | DMAV2_CHCTRL_CTRL_SRCADDRCTRL_SET(config->src_addr_ctrl)
800065ce:	077a                	sll	a4,a4,0x1e
800065d0:	8341                	srl	a4,a4,0x10
        | config->interrupt_mask
800065d2:	0086d683          	lhu	a3,8(a3)
        | DMAV2_CHCTRL_CTRL_DSTADDRCTRL_SET(config->dst_addr_ctrl)
800065d6:	067a                	sll	a2,a2,0x1e
800065d8:	8249                	srl	a2,a2,0x12
        | DMAV2_CHCTRL_CTRL_SRCADDRCTRL_SET(config->src_addr_ctrl)
800065da:	8f5d                	or	a4,a4,a5
        | DMAV2_CHCTRL_CTRL_DSTADDRCTRL_SET(config->dst_addr_ctrl)
800065dc:	8ed9                	or	a3,a3,a4
        | config->interrupt_mask
800065de:	8e55                	or	a2,a2,a3
        | DMAV2_CHCTRL_CTRL_ENABLE_MASK;
800065e0:	01066633          	or	a2,a2,a6
800065e4:	00166613          	or	a2,a2,1
    descriptor->ctrl = tmp;
800065e8:	c190                	sw	a2,0(a1)
}
800065ea:	8082                	ret

Disassembly of section .text.gptmr_channel_get_default_config:

800065ec <gptmr_channel_get_default_config>:
 */

#include "hpm_gptmr_drv.h"

void gptmr_channel_get_default_config(GPTMR_Type *ptr, gptmr_channel_config_t *config)
{
800065ec:	6541                	lui	a0,0x10
800065ee:	f0050513          	add	a0,a0,-256 # ff00 <__ILM_segment_used_end__+0x4aba>
    (void) ptr;
    config->mode = gptmr_work_mode_no_capture;
800065f2:	c188                	sw	a0,0(a1)
    config->dma_request_event = gptmr_dma_request_disabled;
    config->synci_edge = gptmr_synci_edge_none;
    for (uint8_t i = 0; i < GPTMR_CH_CMP_COUNT; i++) {
        config->cmp[i] = 0;
800065f4:	0005a423          	sw	zero,8(a1)
800065f8:	0005a223          	sw	zero,4(a1)
800065fc:	557d                	li	a0,-1
    }
    config->reload = 0xFFFFFFFFUL;
800065fe:	c5c8                	sw	a0,12(a1)
80006600:	10100513          	li	a0,257
    config->cmp_initial_polarity_high = true;
80006604:	c988                	sw	a0,16(a1)
80006606:	4505                	li	a0,1
    config->enable_cmp_output = true;
    config->enable_sync_follow_previous_channel = false;
    config->enable_software_sync = false;
    config->debug_mode = true;
80006608:	00a58a23          	sb	a0,20(a1)
}
8000660c:	8082                	ret

Disassembly of section .text.gptmr_channel_config:

8000660e <gptmr_channel_config>:
                         bool enable)
{
    uint32_t v = 0;
    uint32_t tmp_value;

    if (config->enable_sync_follow_previous_channel && !ch_index) {
8000660e:	01264283          	lbu	t0,18(a2)
80006612:	e591                	bnez	a1,8000661e <.LBB1_3>
80006614:	4709                	li	a4,2
80006616:	00028463          	beqz	t0,8000661e <.LBB1_3>
        tmp_value--;
    }
    ptr->CHANNEL[ch_index].RLD = GPTMR_CHANNEL_RLD_RLD_SET(tmp_value);
    ptr->CHANNEL[ch_index].CR = v;
    return status_success;
}
8000661a:	853a                	mv	a0,a4
8000661c:	8082                	ret

8000661e <.LBB1_3>:
    if (config->dma_request_event != gptmr_dma_request_disabled) {
8000661e:	00164703          	lbu	a4,1(a2)
80006622:	f0170793          	add	a5,a4,-255
80006626:	0017b793          	seqz	a5,a5
8000662a:	077a                	sll	a4,a4,0x1e
8000662c:	8361                	srl	a4,a4,0x18
8000662e:	02070813          	add	a6,a4,32
    v |= GPTMR_CHANNEL_CR_CAPMODE_SET(config->mode)
80006632:	00064703          	lbu	a4,0(a2)
    if (config->dma_request_event != gptmr_dma_request_disabled) {
80006636:	17fd                	add	a5,a5,-1 # 1f1effff <_flash_size+0x1f0effff>
        | GPTMR_CHANNEL_CR_DBGPAUSE_SET(config->debug_mode)
80006638:	01464883          	lbu	a7,20(a2)
    if (config->dma_request_event != gptmr_dma_request_disabled) {
8000663c:	0107feb3          	and	t4,a5,a6
    v |= GPTMR_CHANNEL_CR_CAPMODE_SET(config->mode)
80006640:	8b1d                	and	a4,a4,7
        | GPTMR_CHANNEL_CR_SWSYNCIEN_SET(config->enable_software_sync)
80006642:	01364783          	lbu	a5,19(a2)
        | GPTMR_CHANNEL_CR_DBGPAUSE_SET(config->debug_mode)
80006646:	088e                	sll	a7,a7,0x3
80006648:	00e8e733          	or	a4,a7,a4
        | GPTMR_CHANNEL_CR_CMPINIT_SET(config->cmp_initial_polarity_high)
8000664c:	01064883          	lbu	a7,16(a2)
        | GPTMR_CHANNEL_CR_SWSYNCIEN_SET(config->enable_software_sync)
80006650:	0792                	sll	a5,a5,0x4
80006652:	00f76833          	or	a6,a4,a5
        | GPTMR_CHANNEL_CR_CMPEN_SET(config->enable_cmp_output)
80006656:	01164303          	lbu	t1,17(a2)
        | GPTMR_CHANNEL_CR_CMPINIT_SET(config->cmp_initial_polarity_high)
8000665a:	08a6                	sll	a7,a7,0x9
        | config->synci_edge;
8000665c:	00265703          	lhu	a4,2(a2)
        | GPTMR_CHANNEL_CR_SYNCFLW_SET(config->enable_sync_follow_previous_channel)
80006660:	00d29e13          	sll	t3,t0,0xd
        | GPTMR_CHANNEL_CR_CMPEN_SET(config->enable_cmp_output)
80006664:	0322                	sll	t1,t1,0x8
        | GPTMR_CHANNEL_CR_CEN_SET(enable)
80006666:	00a69393          	sll	t2,a3,0xa
        | config->synci_edge;
8000666a:	00eee2b3          	or	t0,t4,a4
    for (uint8_t i = GPTMR_CH_CMP_COUNT; i > 0; i--) {
8000666e:	00659713          	sll	a4,a1,0x6
80006672:	00e50eb3          	add	t4,a0,a4
80006676:	46a1                	li	a3,8

80006678 <.LBB1_4>:
        tmp_value = config->cmp[i - 1];
80006678:	00d607b3          	add	a5,a2,a3
8000667c:	439c                	lw	a5,0(a5)
        if (tmp_value > 0) {
8000667e:	fff78713          	add	a4,a5,-1
80006682:	00e7b7b3          	sltu	a5,a5,a4
80006686:	17fd                	add	a5,a5,-1
80006688:	8f7d                	and	a4,a4,a5
        ptr->CHANNEL[ch_index].CMP[i - 1] = GPTMR_CHANNEL_CMP_CMP_SET(tmp_value);
8000668a:	00de87b3          	add	a5,t4,a3
    for (uint8_t i = GPTMR_CH_CMP_COUNT; i > 0; i--) {
8000668e:	16f1                	add	a3,a3,-4
        ptr->CHANNEL[ch_index].CMP[i - 1] = GPTMR_CHANNEL_CMP_CMP_SET(tmp_value);
80006690:	c398                	sw	a4,0(a5)
    for (uint8_t i = GPTMR_CH_CMP_COUNT; i > 0; i--) {
80006692:	f2fd                	bnez	a3,80006678 <.LBB1_4>
80006694:	4701                	li	a4,0
        | GPTMR_CHANNEL_CR_SWSYNCIEN_SET(config->enable_software_sync)
80006696:	0ff87693          	zext.b	a3,a6
        | GPTMR_CHANNEL_CR_CMPINIT_SET(config->cmp_initial_polarity_high)
8000669a:	00d8e6b3          	or	a3,a7,a3
        | GPTMR_CHANNEL_CR_SYNCFLW_SET(config->enable_sync_follow_previous_channel)
8000669e:	01c6e6b3          	or	a3,a3,t3
    tmp_value = config->reload;
800066a2:	4650                	lw	a2,12(a2)
        | GPTMR_CHANNEL_CR_CMPEN_SET(config->enable_cmp_output)
800066a4:	0066e6b3          	or	a3,a3,t1
        | GPTMR_CHANNEL_CR_CEN_SET(enable)
800066a8:	0076e6b3          	or	a3,a3,t2
    v |= GPTMR_CHANNEL_CR_CAPMODE_SET(config->mode)
800066ac:	00d2e6b3          	or	a3,t0,a3
    if (tmp_value > 0) {
800066b0:	fff60793          	add	a5,a2,-1
800066b4:	00f63633          	sltu	a2,a2,a5
800066b8:	167d                	add	a2,a2,-1
800066ba:	8e7d                	and	a2,a2,a5
    ptr->CHANNEL[ch_index].RLD = GPTMR_CHANNEL_RLD_RLD_SET(tmp_value);
800066bc:	059a                	sll	a1,a1,0x6
800066be:	952e                	add	a0,a0,a1
800066c0:	c550                	sw	a2,12(a0)
    ptr->CHANNEL[ch_index].CR = v;
800066c2:	c114                	sw	a3,0(a0)
}
800066c4:	853a                	mv	a0,a4
800066c6:	8082                	ret

Disassembly of section .text.pcfg_dcdc_set_voltage:

800066c8 <pcfg_dcdc_set_voltage>:
}

hpm_stat_t pcfg_dcdc_set_voltage(PCFG_Type *ptr, uint16_t mv)
{
    hpm_stat_t stat = status_success;
    if ((mv < PCFG_SOC_DCDC_MIN_VOLTAGE_IN_MV) || (mv > PCFG_SOC_DCDC_MAX_VOLTAGE_IN_MV)) {
800066c8:	aa058613          	add	a2,a1,-1376
800066cc:	0642                	sll	a2,a2,0x10
800066ce:	01065693          	srl	a3,a2,0x10
800066d2:	6641                	lui	a2,0x10
800066d4:	cf860713          	add	a4,a2,-776 # fcf8 <__ILM_segment_used_end__+0x48b2>
800066d8:	4609                	li	a2,2
800066da:	00e6e863          	bltu	a3,a4,800066ea <.LBB3_2>
        return status_invalid_argument;
    }
    ptr->DCDC_MODE = (ptr->DCDC_MODE & ~PCFG_DCDC_MODE_VOLT_MASK) | PCFG_DCDC_MODE_VOLT_SET(mv);
800066de:	4914                	lw	a3,16(a0)
800066e0:	4601                	li	a2,0
800066e2:	777d                	lui	a4,0xfffff
800066e4:	8ef9                	and	a3,a3,a4
800066e6:	8dd5                	or	a1,a1,a3
800066e8:	c90c                	sw	a1,16(a0)

800066ea <.LBB3_2>:
    return stat;
}
800066ea:	8532                	mv	a0,a2
800066ec:	8082                	ret

Disassembly of section .text.pllctlv2_set_postdiv:

800066ee <pllctlv2_set_postdiv>:
    }
}

void pllctlv2_set_postdiv(PLLCTLV2_Type *ptr, uint8_t pll, uint8_t div_index, uint8_t div_value)
{
    if ((ptr != NULL) && (pll < PLLCTL_SOC_PLL_MAX_COUNT)) {
800066ee:	c505                	beqz	a0,80006716 <.LBB2_3>
800066f0:	4705                	li	a4,1
800066f2:	02b76263          	bltu	a4,a1,80006716 <.LBB2_3>
        ptr->PLL[pll].DIV[div_index] =
            (ptr->PLL[pll].DIV[div_index] & ~PLLCTLV2_PLL_DIV_DIV_MASK) | PLLCTLV2_PLL_DIV_DIV_SET(div_value) |
800066f6:	059e                	sll	a1,a1,0x7
800066f8:	952e                	add	a0,a0,a1
800066fa:	060a                	sll	a2,a2,0x2
800066fc:	9532                	add	a0,a0,a2
800066fe:	0c052583          	lw	a1,192(a0)
80006702:	fc05f593          	and	a1,a1,-64
80006706:	03f6f613          	and	a2,a3,63
8000670a:	100006b7          	lui	a3,0x10000
8000670e:	8e55                	or	a2,a2,a3
80006710:	8dd1                	or	a1,a1,a2
        ptr->PLL[pll].DIV[div_index] =
80006712:	0cb52023          	sw	a1,192(a0)

80006716 <.LBB2_3>:
                PLLCTLV2_PLL_DIV_ENABLE_MASK;
    }
}
80006716:	8082                	ret

Disassembly of section .text.pllctlv2_get_pll_freq_in_hz:

80006718 <pllctlv2_get_pll_freq_in_hz>:

uint32_t pllctlv2_get_pll_freq_in_hz(PLLCTLV2_Type *ptr, uint8_t pll)
{
80006718:	862a                	mv	a2,a0
8000671a:	4501                	li	a0,0
    uint32_t freq = 0;
    if ((ptr != NULL) && (pll < PLLCTL_SOC_PLL_MAX_COUNT)) {
8000671c:	c251                	beqz	a2,800067a0 <.LBB3_3>
8000671e:	4685                	li	a3,1
80006720:	08b6e063          	bltu	a3,a1,800067a0 <.LBB3_3>
80006724:	1101                	add	sp,sp,-32
80006726:	ce06                	sw	ra,28(sp)
80006728:	cc22                	sw	s0,24(sp)
8000672a:	ca26                	sw	s1,20(sp)
8000672c:	c84a                	sw	s2,16(sp)
8000672e:	c64e                	sw	s3,12(sp)
80006730:	c452                	sw	s4,8(sp)
        uint32_t mfi = PLLCTLV2_PLL_MFI_MFI_GET(ptr->PLL[pll].MFI);
80006732:	059e                	sll	a1,a1,0x7
80006734:	95b2                	add	a1,a1,a2
80006736:	0805a503          	lw	a0,128(a1)
8000673a:	07f57513          	and	a0,a0,127
        uint32_t mfn = PLLCTLV2_PLL_MFN_MFN_GET(ptr->PLL[pll].MFN);
8000673e:	0845a603          	lw	a2,132(a1)
        uint32_t mfd = PLLCTLV2_PLL_MFD_MFD_GET(ptr->PLL[pll].MFD);
80006742:	0885a583          	lw	a1,136(a1)
80006746:	400006b7          	lui	a3,0x40000
8000674a:	16fd                	add	a3,a3,-1 # 3fffffff <_flash_size+0x3fefffff>
        uint32_t mfn = PLLCTLV2_PLL_MFN_MFN_GET(ptr->PLL[pll].MFN);
8000674c:	00d67433          	and	s0,a2,a3
        uint32_t mfd = PLLCTLV2_PLL_MFD_MFD_GET(ptr->PLL[pll].MFD);
80006750:	00d5fa33          	and	s4,a1,a3
        freq = (uint32_t) (PLLCTLV2_PLL_XTAL_FREQ * (mfi + 1.0 * mfn / mfd));
80006754:	1e0070ef          	jal	8000d934 <__floatunsidf>
80006758:	892a                	mv	s2,a0
8000675a:	89ae                	mv	s3,a1
8000675c:	8522                	mv	a0,s0
8000675e:	1d6070ef          	jal	8000d934 <__floatunsidf>
80006762:	842a                	mv	s0,a0
80006764:	84ae                	mv	s1,a1
80006766:	8552                	mv	a0,s4
80006768:	1cc070ef          	jal	8000d934 <__floatunsidf>
8000676c:	862a                	mv	a2,a0
8000676e:	86ae                	mv	a3,a1
80006770:	8522                	mv	a0,s0
80006772:	85a6                	mv	a1,s1
80006774:	775060ef          	jal	8000d6e8 <__divdf3>
80006778:	864a                	mv	a2,s2
8000677a:	86ce                	mv	a3,s3
8000677c:	1d1060ef          	jal	8000d14c <__adddf3>
80006780:	4176e637          	lui	a2,0x4176e
80006784:	36060693          	add	a3,a2,864 # 4176e360 <_flash_size+0x4166e360>
80006788:	4601                	li	a2,0
8000678a:	54b060ef          	jal	8000d4d4 <__muldf3>
8000678e:	51a020ef          	jal	80008ca8 <__fixunsdfsi>
80006792:	40f2                	lw	ra,28(sp)
80006794:	4462                	lw	s0,24(sp)
80006796:	44d2                	lw	s1,20(sp)
80006798:	4942                	lw	s2,16(sp)
8000679a:	49b2                	lw	s3,12(sp)
8000679c:	4a22                	lw	s4,8(sp)
8000679e:	6105                	add	sp,sp,32

800067a0 <.LBB3_3>:
    }
    return freq;
800067a0:	8082                	ret

Disassembly of section .text.uart_calculate_baudrate:

800067a2 <uart_calculate_baudrate>:
    config->rx_enable = true;
#endif
}

static bool uart_calculate_baudrate(uint32_t freq, uint32_t baudrate, uint16_t *div_out, uint8_t *osc_out)
{
800067a2:	00359793          	sll	a5,a1,0x3
800067a6:	872a                	mv	a4,a0
800067a8:	4501                	li	a0,0
    uint16_t div, osc, delta;
    float tmp;
    if ((div_out == NULL) || (!freq) || (!baudrate)
800067aa:	02f76363          	bltu	a4,a5,800067d0 <.LBB2_6>
800067ae:	0c800793          	li	a5,200
800067b2:	00f5ef63          	bltu	a1,a5,800067d0 <.LBB2_6>
800067b6:	cf09                	beqz	a4,800067d0 <.LBB2_6>
800067b8:	ce01                	beqz	a2,800067d0 <.LBB2_6>
800067ba:	80008537          	lui	a0,0x80008
800067be:	0505                	add	a0,a0,1 # 80008001 <.LBB6_2+0x1f>
            || (baudrate < HPM_UART_MINIMUM_BAUDRATE)
            || (freq / HPM_UART_BAUDRATE_DIV_MIN < baudrate * HPM_UART_OSC_MIN)
            || (freq / HPM_UART_BAUDRATE_DIV_MAX > (baudrate * HPM_UART_OSC_MAX))) {
800067c0:	02a73533          	mulhu	a0,a4,a0
800067c4:	813d                	srl	a0,a0,0xf
800067c6:	00559793          	sll	a5,a1,0x5
    if ((div_out == NULL) || (!freq) || (!baudrate)
800067ca:	00a7f463          	bgeu	a5,a0,800067d2 <.LBB2_7>
800067ce:	4501                	li	a0,0

800067d0 <.LBB2_6>:
            *osc_out = (osc == HPM_UART_OSC_MAX) ? 0 : osc; /* osc == 0 in bitfield, oversample rate is 32 */
            return true;
        }
    }
    return false;
}
800067d0:	8082                	ret

800067d2 <.LBB2_7>:
800067d2:	7179                	add	sp,sp,-48
800067d4:	d606                	sw	ra,44(sp)
800067d6:	d422                	sw	s0,40(sp)
800067d8:	d226                	sw	s1,36(sp)
800067da:	d04a                	sw	s2,32(sp)
800067dc:	ce4e                	sw	s3,28(sp)
800067de:	cc52                	sw	s4,24(sp)
800067e0:	ca56                	sw	s5,20(sp)
800067e2:	c85a                	sw	s6,16(sp)
800067e4:	c65e                	sw	s7,12(sp)
800067e6:	8ab2                	mv	s5,a2
800067e8:	8a36                	mv	s4,a3
    tmp = (float) freq / baudrate;
800067ea:	853a                	mv	a0,a4
800067ec:	842e                	mv	s0,a1
800067ee:	552020ef          	jal	80008d40 <__floatunsisf>
800067f2:	84aa                	mv	s1,a0
800067f4:	8522                	mv	a0,s0
800067f6:	54a020ef          	jal	80008d40 <__floatunsisf>
800067fa:	85aa                	mv	a1,a0
800067fc:	8526                	mv	a0,s1
800067fe:	5e7060ef          	jal	8000d5e4 <__divsf3>
80006802:	892a                	mv	s2,a0
80006804:	4521                	li	a0,8
80006806:	4b75                	li	s6,29
80006808:	06400b93          	li	s7,100
8000680c:	a029                	j	80006816 <.LBB2_9>

8000680e <.LBB2_8>:
    for (osc = HPM_UART_OSC_MIN; osc <= UART_SOC_OVERSAMPLE_MAX; osc += 2) {
8000680e:	00248513          	add	a0,s1,2
80006812:	0764fb63          	bgeu	s1,s6,80006888 <.LBB2_17>

80006816 <.LBB2_9>:
80006816:	84aa                	mv	s1,a0
        div = (uint16_t)(tmp / osc);
80006818:	4c2020ef          	jal	80008cda <__floatsisf>
8000681c:	85aa                	mv	a1,a0
8000681e:	854a                	mv	a0,s2
80006820:	5c5060ef          	jal	8000d5e4 <__divsf3>
80006824:	452020ef          	jal	80008c76 <__fixunssfsi>
        if (div < HPM_UART_BAUDRATE_DIV_MIN) {
80006828:	d17d                	beqz	a0,8000680e <.LBB2_8>
8000682a:	89aa                	mv	s3,a0
        if (div * osc > tmp) {
8000682c:	02a48533          	mul	a0,s1,a0
80006830:	4aa020ef          	jal	80008cda <__floatsisf>
80006834:	842a                	mv	s0,a0
80006836:	854a                	mv	a0,s2
80006838:	85a2                	mv	a1,s0
8000683a:	35c020ef          	jal	80008b96 <__ltsf2>
8000683e:	00055563          	bgez	a0,80006848 <.LBB2_12>
            delta = (uint16_t)(div * osc - tmp);
80006842:	8522                	mv	a0,s0
80006844:	85ca                	mv	a1,s2
80006846:	a809                	j	80006858 <.LBB2_14>

80006848 <.LBB2_12>:
        } else if (div * osc < tmp) {
80006848:	854a                	mv	a0,s2
8000684a:	85a2                	mv	a1,s0
8000684c:	3ba020ef          	jal	80008c06 <__gtsf2>
80006850:	02a05663          	blez	a0,8000687c <.LBB2_16>
            delta = (uint16_t)(tmp - div * osc);
80006854:	854a                	mv	a0,s2
80006856:	85a2                	mv	a1,s0

80006858 <.LBB2_14>:
80006858:	188020ef          	jal	800089e0 <__subsf3>
8000685c:	41a020ef          	jal	80008c76 <__fixunssfsi>
        if (delta && ((delta * 100 / tmp) > HPM_UART_BAUDRATE_TOLERANCE)) {
80006860:	cd11                	beqz	a0,8000687c <.LBB2_16>
80006862:	03750533          	mul	a0,a0,s7
80006866:	474020ef          	jal	80008cda <__floatsisf>
8000686a:	85ca                	mv	a1,s2
8000686c:	579060ef          	jal	8000d5e4 <__divsf3>
80006870:	404005b7          	lui	a1,0x40400
80006874:	392020ef          	jal	80008c06 <__gtsf2>
80006878:	f8a04be3          	bgtz	a0,8000680e <.LBB2_8>

8000687c <.LBB2_16>:
            *div_out = div;
8000687c:	013a9023          	sh	s3,0(s5)
            *osc_out = (osc == HPM_UART_OSC_MAX) ? 0 : osc; /* osc == 0 in bitfield, oversample rate is 32 */
80006880:	009a0023          	sb	s1,0(s4)
80006884:	4505                	li	a0,1
80006886:	a011                	j	8000688a <.LBB2_18>

80006888 <.LBB2_17>:
80006888:	4501                	li	a0,0

8000688a <.LBB2_18>:
8000688a:	50b2                	lw	ra,44(sp)
8000688c:	5422                	lw	s0,40(sp)
8000688e:	5492                	lw	s1,36(sp)
80006890:	5902                	lw	s2,32(sp)
80006892:	49f2                	lw	s3,28(sp)
80006894:	4a62                	lw	s4,24(sp)
80006896:	4ad2                	lw	s5,20(sp)
80006898:	4b42                	lw	s6,16(sp)
8000689a:	4bb2                	lw	s7,12(sp)
8000689c:	6145                	add	sp,sp,48
}
8000689e:	8082                	ret

Disassembly of section .text.uart_send_byte:

800068a0 <uart_send_byte>:

    return status_success;
}

hpm_stat_t uart_send_byte(UART_Type *ptr, uint8_t c)
{
800068a0:	4701                	li	a4,0
800068a2:	6605                	lui	a2,0x1
800068a4:	38960613          	add	a2,a2,905 # 1389 <.LBB2_212+0x19>

800068a8 <.LBB6_1>:
    uint32_t retry = 0;

    while (!(ptr->LSR & UART_LSR_THRE_MASK)) {
800068a8:	5954                	lw	a3,52(a0)
800068aa:	0206f793          	and	a5,a3,32
800068ae:	86ba                	mv	a3,a4
800068b0:	e789                	bnez	a5,800068ba <.LBB6_3>
800068b2:	00168713          	add	a4,a3,1
800068b6:	fec6e9e3          	bltu	a3,a2,800068a8 <.LBB6_1>

800068ba <.LBB6_3>:
800068ba:	6605                	lui	a2,0x1
800068bc:	38860713          	add	a4,a2,904 # 1388 <.LBB2_212+0x18>
800068c0:	460d                	li	a2,3
            break;
        }
        retry++;
    }

    if (retry > HPM_UART_DRV_RETRY_COUNT) {
800068c2:	00d76463          	bltu	a4,a3,800068ca <.LBB6_5>
800068c6:	4601                	li	a2,0
        return status_timeout;
    }

    ptr->THR = UART_THR_THR_SET(c);
800068c8:	d10c                	sw	a1,32(a0)

800068ca <.LBB6_5>:
    return status_success;
}
800068ca:	8532                	mv	a0,a2
800068cc:	8082                	ret

Disassembly of section .text.usb_phy_init:

800068ce <usb_phy_init>:
    ptr->PHY_CTRL0 &= ~0x001000E0u;
800068ce:	21052583          	lw	a1,528(a0)
800068d2:	fff00637          	lui	a2,0xfff00
800068d6:	f1f60613          	add	a2,a2,-225 # ffefff1f <__AHB_SRAM_segment_end__+0xfaf7f1f>
800068da:	8df1                	and	a1,a1,a2
800068dc:	20b52823          	sw	a1,528(a0)
void usb_phy_init(USB_Type *ptr)
{
    uint32_t status;

    usb_phy_enable_dp_dm_pulldown(ptr);
    ptr->OTG_CTRL0 |= USB_OTG_CTRL0_OTG_UTMI_RESET_SW_MASK;           /* set otg_utmi_reset_sw for naneng usbphy */
800068e0:	20052683          	lw	a3,512(a0)
800068e4:	4585                	li	a1,1
800068e6:	05ae                	sll	a1,a1,0xb
800068e8:	8ecd                	or	a3,a3,a1
800068ea:	20d52023          	sw	a3,512(a0)
    ptr->OTG_CTRL0 &= ~USB_OTG_CTRL0_OTG_UTMI_SUSPENDM_SW_MASK;       /* clr otg_utmi_suspend_m for naneng usbphy */
800068ee:	20052683          	lw	a3,512(a0)
800068f2:	777d                	lui	a4,0xfffff
800068f4:	177d                	add	a4,a4,-1 # ffffefff <__AHB_SRAM_segment_end__+0xfbf6fff>
800068f6:	8ef9                	and	a3,a3,a4
800068f8:	20d52023          	sw	a3,512(a0)
    ptr->PHY_CTRL1 &= ~USB_PHY_CTRL1_UTMI_CFG_RST_N_MASK;             /* clr cfg_rst_n */
800068fc:	21452683          	lw	a3,532(a0)
80006900:	0e060613          	add	a2,a2,224
80006904:	8e75                	and	a2,a2,a3
80006906:	20c52a23          	sw	a2,532(a0)

8000690a <.LBB0_1>:

    do {
        status = USB_OTG_CTRL0_OTG_UTMI_RESET_SW_GET(ptr->OTG_CTRL0); /* wait for reset status */
8000690a:	20052603          	lw	a2,512(a0)
    } while (status == 0);
8000690e:	8e6d                	and	a2,a2,a1
80006910:	de6d                	beqz	a2,8000690a <.LBB0_1>
80006912:	1141                	add	sp,sp,-16

    ptr->OTG_CTRL0 |= USB_OTG_CTRL0_OTG_UTMI_SUSPENDM_SW_MASK;        /* set otg_utmi_suspend_m for naneng usbphy */
80006914:	20052583          	lw	a1,512(a0)
80006918:	6605                	lui	a2,0x1
8000691a:	8dd1                	or	a1,a1,a2
8000691c:	20b52023          	sw	a1,512(a0)

    for (volatile uint32_t i = 0; i < USB_PHY_INIT_DELAY_COUNT; i++) {
80006920:	c602                	sw	zero,12(sp)
80006922:	45b2                	lw	a1,12(sp)
80006924:	463d                	li	a2,15
80006926:	00b66b63          	bltu	a2,a1,8000693c <.LBB0_5>
8000692a:	45c1                	li	a1,16

8000692c <.LBB0_4>:
        (void)ptr->PHY_CTRL1;                                         /* used for delay */
8000692c:	21452003          	lw	zero,532(a0)
    for (volatile uint32_t i = 0; i < USB_PHY_INIT_DELAY_COUNT; i++) {
80006930:	4632                	lw	a2,12(sp)
80006932:	0605                	add	a2,a2,1 # 1001 <__fw_size__+0x1>
80006934:	c632                	sw	a2,12(sp)
80006936:	4632                	lw	a2,12(sp)
80006938:	feb66ae3          	bltu	a2,a1,8000692c <.LBB0_4>

8000693c <.LBB0_5>:
    }

    ptr->OTG_CTRL0 &= ~USB_OTG_CTRL0_OTG_UTMI_RESET_SW_MASK;          /* clear otg_utmi_reset_sw for naneng usbphy */
8000693c:	20052583          	lw	a1,512(a0)
80006940:	767d                	lui	a2,0xfffff
80006942:	7ff60613          	add	a2,a2,2047 # fffff7ff <__AHB_SRAM_segment_end__+0xfbf77ff>
80006946:	8df1                	and	a1,a1,a2
80006948:	20b52023          	sw	a1,512(a0)

    /* otg utmi clock detection */
    ptr->PHY_STATUS |= USB_PHY_STATUS_UTMI_CLK_VALID_MASK;            /* write 1 to clear valid status */
8000694c:	22452583          	lw	a1,548(a0)
80006950:	80000637          	lui	a2,0x80000
80006954:	8dd1                	or	a1,a1,a2
80006956:	22b52223          	sw	a1,548(a0)
    do {
8000695a:	0141                	add	sp,sp,16

8000695c <.LBB0_6>:
        status = USB_PHY_STATUS_UTMI_CLK_VALID_GET(ptr->PHY_STATUS);  /* get utmi clock status */
8000695c:	22452583          	lw	a1,548(a0)
    } while (status == 0);
80006960:	fe05dee3          	bgez	a1,8000695c <.LBB0_6>

    ptr->PHY_CTRL1 |= USB_PHY_CTRL1_UTMI_CFG_RST_N_MASK;              /* set cfg_rst_n */
80006964:	21452583          	lw	a1,532(a0)
80006968:	00100637          	lui	a2,0x100
8000696c:	8dd1                	or	a1,a1,a2
8000696e:	20b52a23          	sw	a1,532(a0)

    ptr->PHY_CTRL1 |= USB_PHY_CTRL1_UTMI_OTG_SUSPENDM_MASK;           /* set otg_suspendm */
80006972:	21452583          	lw	a1,532(a0)
80006976:	0025e593          	or	a1,a1,2
8000697a:	20b52a23          	sw	a1,532(a0)
}
8000697e:	8082                	ret

Disassembly of section .text.usb_dcd_bus_reset:

80006980 <usb_dcd_bus_reset>:
     * endpoint type of the unused direction must be changed from the control type to any other
     * type (e.g. bulk). Leaving an un-configured endpoint control will cause undefined behavior
     * for the data PID tracking on the active endpoint.
     */

    for (uint32_t i = 1; i < USB_SOC_DCD_MAX_ENDPOINT_COUNT; i++) {
80006980:	1c450593          	add	a1,a0,452
80006984:	20050613          	add	a2,a0,512
80006988:	000806b7          	lui	a3,0x80
8000698c:	06a1                	add	a3,a3,8 # 80008 <target_device+0x8>

8000698e <.LBB1_1>:
        ptr->ENDPTCTRL[i] = USB_ENDPTCTRL_TXT_SET(usb_xfer_bulk) | USB_ENDPTCTRL_RXT_SET(usb_xfer_bulk);
8000698e:	c194                	sw	a3,0(a1)
    for (uint32_t i = 1; i < USB_SOC_DCD_MAX_ENDPOINT_COUNT; i++) {
80006990:	0591                	add	a1,a1,4 # 40400004 <_flash_size+0x40300004>
80006992:	fec59ee3          	bne	a1,a2,8000698e <.LBB1_1>
    }

    /* Clear All Registers */
    ptr->ENDPTNAK       = ptr->ENDPTNAK;
80006996:	17852583          	lw	a1,376(a0)
8000699a:	16b52c23          	sw	a1,376(a0)
    ptr->ENDPTNAKEN     = 0;
8000699e:	16052e23          	sw	zero,380(a0)
    ptr->USBSTS         = ptr->USBSTS;
800069a2:	14452583          	lw	a1,324(a0)
800069a6:	14b52223          	sw	a1,324(a0)
    ptr->ENDPTSETUPSTAT = ptr->ENDPTSETUPSTAT;
800069aa:	1ac52583          	lw	a1,428(a0)
800069ae:	1ab52623          	sw	a1,428(a0)
    ptr->ENDPTCOMPLETE  = ptr->ENDPTCOMPLETE;
800069b2:	1bc52583          	lw	a1,444(a0)
800069b6:	1ab52e23          	sw	a1,444(a0)

800069ba <.LBB1_3>:

    while (ptr->ENDPTPRIME) {
800069ba:	1b052583          	lw	a1,432(a0)
800069be:	fdf5                	bnez	a1,800069ba <.LBB1_3>
800069c0:	55fd                	li	a1,-1
    }
    ptr->ENDPTFLUSH = 0xFFFFFFFF;
800069c2:	1ab52a23          	sw	a1,436(a0)

800069c6 <.LBB1_5>:
    while (ptr->ENDPTFLUSH) {
800069c6:	1b452583          	lw	a1,436(a0)
800069ca:	fdf5                	bnez	a1,800069c6 <.LBB1_5>
    }
}
800069cc:	8082                	ret

Disassembly of section .text.usb_dcd_init:

800069ce <usb_dcd_init>:

void usb_dcd_init(USB_Type *ptr)
{
800069ce:	1141                	add	sp,sp,-16
800069d0:	c606                	sw	ra,12(sp)
800069d2:	c422                	sw	s0,8(sp)
800069d4:	842a                	mv	s0,a0
    /* Initialize USB phy */
    usb_phy_init(ptr);
800069d6:	3de5                	jal	800068ce <usb_phy_init>

    /* Reset controller */
    ptr->USBCMD |= USB_USBCMD_RST_MASK;
800069d8:	14042503          	lw	a0,320(s0)
800069dc:	00256513          	or	a0,a0,2
800069e0:	14a42023          	sw	a0,320(s0)

800069e4 <.LBB2_1>:
    while (USB_USBCMD_RST_GET(ptr->USBCMD)) {
800069e4:	14042503          	lw	a0,320(s0)
800069e8:	8909                	and	a0,a0,2
800069ea:	fd6d                	bnez	a0,800069e4 <.LBB2_1>
    }

    /* Set mode to device, must be set immediately after reset */
    ptr->USBMODE &= ~USB_USBMODE_CM_MASK;
800069ec:	1a842503          	lw	a0,424(s0)
800069f0:	9971                	and	a0,a0,-4
800069f2:	1aa42423          	sw	a0,424(s0)
    ptr->USBMODE |= USB_USBMODE_CM_SET(2);
800069f6:	1a842503          	lw	a0,424(s0)
800069fa:	00256513          	or	a0,a0,2
800069fe:	1aa42423          	sw	a0,424(s0)

    /* Disable setup lockout, please refer to "Control Endpoint Operation" section in RM. */
    ptr->USBMODE &= ~USB_USBMODE_SLOM_MASK;
80006a02:	1a842503          	lw	a0,424(s0)
80006a06:	995d                	and	a0,a0,-9
80006a08:	1aa42423          	sw	a0,424(s0)

    /* Set the endian */
    ptr->USBMODE &= ~USB_USBMODE_ES_MASK;
80006a0c:	1a842503          	lw	a0,424(s0)
80006a10:	996d                	and	a0,a0,-5
80006a12:	1aa42423          	sw	a0,424(s0)

    /* TODO Force fullspeed on non-highspeed port */
    /* ptr->PORTSC1 |= USB_PORTSC1_PFSC_MASK; */

    /* Set parallel interface signal */
    ptr->PORTSC1 &= ~USB_PORTSC1_STS_MASK;
80006a16:	18442503          	lw	a0,388(s0)
80006a1a:	e00005b7          	lui	a1,0xe0000
80006a1e:	15fd                	add	a1,a1,-1 # dfffffff <__XPI0_segment_end__+0x5fefffff>
80006a20:	8d6d                	and	a0,a0,a1
80006a22:	18a42223          	sw	a0,388(s0)

    /* Set parallel transceiver width */
    ptr->PORTSC1 &= ~USB_PORTSC1_PTW_MASK;
80006a26:	18442503          	lw	a0,388(s0)
80006a2a:	f00005b7          	lui	a1,0xf0000
80006a2e:	15fd                	add	a1,a1,-1 # efffffff <__XPI0_segment_end__+0x6fefffff>
80006a30:	8d6d                	and	a0,a0,a1
80006a32:	18a42223          	sw	a0,388(s0)
    /* Set usb forced to full speed mode */
    ptr->PORTSC1 |= USB_PORTSC1_PFSC_MASK;
#endif

    /* Not use interrupt threshold. */
    ptr->USBCMD &= ~USB_USBCMD_ITC_MASK;
80006a36:	14042503          	lw	a0,320(s0)
80006a3a:	ff0105b7          	lui	a1,0xff010
80006a3e:	15fd                	add	a1,a1,-1 # ff00ffff <__AHB_SRAM_segment_end__+0xec07fff>
80006a40:	8d6d                	and	a0,a0,a1
80006a42:	14a42023          	sw	a0,320(s0)

    /* Enable VBUS discharge */
    ptr->OTGSC |= USB_OTGSC_VD_MASK;
80006a46:	1a442503          	lw	a0,420(s0)
80006a4a:	00156513          	or	a0,a0,1
80006a4e:	1aa42223          	sw	a0,420(s0)
80006a52:	40b2                	lw	ra,12(sp)
80006a54:	4422                	lw	s0,8(sp)
}
80006a56:	0141                	add	sp,sp,16
80006a58:	8082                	ret

Disassembly of section .text.usb_dcd_connect:

80006a5a <usb_dcd_connect>:
}

/* Connect by enabling internal pull-up resistor on D+/D- */
void usb_dcd_connect(USB_Type *ptr)
{
    ptr->USBCMD |= USB_USBCMD_RS_MASK;
80006a5a:	14052583          	lw	a1,320(a0)
80006a5e:	0015e593          	or	a1,a1,1
80006a62:	14b52023          	sw	a1,320(a0)
}
80006a66:	8082                	ret

Disassembly of section .text.usb_dcd_edpt_open:

80006a68 <usb_dcd_edpt_open>:
 * Endpoint API
 *---------------------------------------------------------------------
 */
void usb_dcd_edpt_open(USB_Type *ptr, usb_endpoint_config_t *config)
{
    uint8_t const epnum  = config->ep_addr & 0x0f;
80006a68:	0015c603          	lbu	a2,1(a1)
80006a6c:	00f67693          	and	a3,a2,15
    uint8_t const dir = (config->ep_addr & 0x80) >> 7;

    /* Enable EP Control */
    uint32_t temp = ptr->ENDPTCTRL[epnum];
80006a70:	068a                	sll	a3,a3,0x2
80006a72:	9536                	add	a0,a0,a3
80006a74:	1c052683          	lw	a3,448(a0)
    temp &= ~((0x03 << 2) << (dir ? 16 : 0));
80006a78:	820d                	srl	a2,a2,0x3
80006a7a:	8a41                	and	a2,a2,16
80006a7c:	4731                	li	a4,12
    temp |= ((config->xfer << 2) | ENDPTCTRL_ENABLE | ENDPTCTRL_TOGGLE_RESET) << (dir ? 16 : 0);
80006a7e:	0005c583          	lbu	a1,0(a1)
    temp &= ~((0x03 << 2) << (dir ? 16 : 0));
80006a82:	00c71733          	sll	a4,a4,a2
80006a86:	fff74713          	not	a4,a4
80006a8a:	8ef9                	and	a3,a3,a4
    temp |= ((config->xfer << 2) | ENDPTCTRL_ENABLE | ENDPTCTRL_TOGGLE_RESET) << (dir ? 16 : 0);
80006a8c:	058a                	sll	a1,a1,0x2
80006a8e:	0c05e593          	or	a1,a1,192
80006a92:	00c595b3          	sll	a1,a1,a2
80006a96:	8dd5                	or	a1,a1,a3
    ptr->ENDPTCTRL[epnum] = temp;
80006a98:	1cb52023          	sw	a1,448(a0)
}
80006a9c:	8082                	ret

Disassembly of section .text.usb_dcd_edpt_get_type:

80006a9e <usb_dcd_edpt_get_type>:

uint8_t usb_dcd_edpt_get_type(USB_Type *ptr, uint8_t ep_addr)
{
    uint8_t const epnum  = ep_addr & 0x0f;
    uint8_t const dir = (ep_addr & 0x80) >> 7;
    uint32_t temp =  ptr->ENDPTCTRL[epnum];
80006a9e:	00f5f613          	and	a2,a1,15
80006aa2:	060a                	sll	a2,a2,0x2
80006aa4:	9532                	add	a0,a0,a2
80006aa6:	1c052503          	lw	a0,448(a0)

    return dir ?  USB_ENDPTCTRL_TXT_GET(temp) : USB_ENDPTCTRL_RXT_GET(temp);
80006aaa:	818d                	srl	a1,a1,0x3
80006aac:	89c1                	and	a1,a1,16
80006aae:	0589                	add	a1,a1,2
80006ab0:	00b55533          	srl	a0,a0,a1
80006ab4:	890d                	and	a0,a0,3
80006ab6:	8082                	ret

Disassembly of section .text.usb_dcd_edpt_xfer:

80006ab8 <usb_dcd_edpt_xfer>:
}

void usb_dcd_edpt_xfer(USB_Type *ptr, uint8_t ep_idx)
{
80006ab8:	0015d613          	srl	a2,a1,0x1
    uint32_t offset = ep_idx / 2 + ((ep_idx % 2) ? 16 : 0);
80006abc:	0592                	sll	a1,a1,0x4
80006abe:	89c1                	and	a1,a1,16
80006ac0:	95b2                	add	a1,a1,a2
80006ac2:	4605                	li	a2,1

    /* Start transfer */
    ptr->ENDPTPRIME = 1 << offset;
80006ac4:	00b615b3          	sll	a1,a2,a1
80006ac8:	1ab52823          	sw	a1,432(a0)
}
80006acc:	8082                	ret

Disassembly of section .text.usb_dcd_edpt_stall:

80006ace <usb_dcd_edpt_stall>:
void usb_dcd_edpt_stall(USB_Type *ptr, uint8_t ep_addr)
{
    uint8_t const epnum = ep_addr & 0x0f;
    uint8_t const dir   = (ep_addr & 0x80) >> 7;

    ptr->ENDPTCTRL[epnum] |= ENDPTCTRL_STALL << (dir ? 16 : 0);
80006ace:	0035d613          	srl	a2,a1,0x3
80006ad2:	89bd                	and	a1,a1,15
80006ad4:	058a                	sll	a1,a1,0x2
80006ad6:	952e                	add	a0,a0,a1
80006ad8:	1c052583          	lw	a1,448(a0)
80006adc:	8a41                	and	a2,a2,16
80006ade:	4685                	li	a3,1
80006ae0:	00c69633          	sll	a2,a3,a2
80006ae4:	8dd1                	or	a1,a1,a2
80006ae6:	1cb52023          	sw	a1,448(a0)
}
80006aea:	8082                	ret

Disassembly of section .text.usbd_cdc_acm_init_intf:

80006aec <usbd_cdc_acm_init_intf>:

    return 0;
}

struct usbd_interface *usbd_cdc_acm_init_intf(uint8_t busid, struct usbd_interface *intf)
{
80006aec:	852e                	mv	a0,a1
    intf->class_interface_handler = cdc_acm_class_interface_request_handler;
80006aee:	8000a5b7          	lui	a1,0x8000a
80006af2:	67e58593          	add	a1,a1,1662 # 8000a67e <cdc_acm_class_interface_request_handler>
80006af6:	c10c                	sw	a1,0(a0)
    intf->class_endpoint_handler = NULL;
80006af8:	00052223          	sw	zero,4(a0)
    intf->vendor_handler = NULL;
80006afc:	00052423          	sw	zero,8(a0)
    intf->notify_handler = NULL;
80006b00:	00052623          	sw	zero,12(a0)

    return intf;
80006b04:	8082                	ret

Disassembly of section .text.usbd_cdc_acm_set_dtr:

80006b06 <usbd_cdc_acm_set_dtr>:
    line_coding->bCharFormat = 0;
}

__WEAK void usbd_cdc_acm_set_dtr(uint8_t busid, uint8_t intf, bool dtr)
{
}
80006b06:	8082                	ret

Disassembly of section .text.usbd_cdc_acm_set_rts:

80006b08 <usbd_cdc_acm_set_rts>:

__WEAK void usbd_cdc_acm_set_rts(uint8_t busid, uint8_t intf, bool rts)
{
}
80006b08:	8082                	ret

Disassembly of section .text.usbd_cdc_acm_send_break:

80006b0a <usbd_cdc_acm_send_break>:

__WEAK void usbd_cdc_acm_send_break(uint8_t busid, uint8_t intf)
{
}
80006b0a:	8082                	ret

Disassembly of section .text.usbdev_msc_thread:

80006b0c <usbdev_msc_thread>:
    }
}

#ifdef CONFIG_USBDEV_MSC_THREAD
static void usbdev_msc_thread(void *argument)
{
80006b0c:	711d                	add	sp,sp,-96
80006b0e:	ce86                	sw	ra,92(sp)
80006b10:	cca2                	sw	s0,88(sp)
80006b12:	caa6                	sw	s1,84(sp)
80006b14:	c8ca                	sw	s2,80(sp)
80006b16:	c6ce                	sw	s3,76(sp)
80006b18:	c4d2                	sw	s4,72(sp)
80006b1a:	c2d6                	sw	s5,68(sp)
80006b1c:	c0da                	sw	s6,64(sp)
80006b1e:	de5e                	sw	s7,60(sp)
80006b20:	dc62                	sw	s8,56(sp)
80006b22:	da66                	sw	s9,52(sp)
80006b24:	d86a                	sw	s10,48(sp)
80006b26:	d66e                	sw	s11,44(sp)
80006b28:	0ff57a93          	zext.b	s5,a0
80006b2c:	25400513          	li	a0,596
80006b30:	02aa8a33          	mul	s4,s5,a0
80006b34:	00097537          	lui	a0,0x97
80006b38:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
80006b3c:	9a2a                	add	s4,s4,a0
80006b3e:	248a0413          	add	s0,s4,584
80006b42:	03ca0b13          	add	s6,s4,60
80006b46:	011a0b93          	add	s7,s4,17
80006b4a:	038a0c13          	add	s8,s4,56
80006b4e:	048a0913          	add	s2,s4,72
80006b52:	033a0513          	add	a0,s4,51
80006b56:	ce2a                	sw	a0,28(sp)
80006b58:	034a0513          	add	a0,s4,52
80006b5c:	cc2a                	sw	a0,24(sp)
80006b5e:	035a0513          	add	a0,s4,53
80006b62:	ca2a                	sw	a0,20(sp)
80006b64:	024a0993          	add	s3,s4,36
80006b68:	030a0513          	add	a0,s4,48
80006b6c:	d22a                	sw	a0,36(sp)
80006b6e:	5e018513          	add	a0,gp,1504 # 81950 <mass_ep_data>
80006b72:	004a9593          	sll	a1,s5,0x4
80006b76:	952e                	add	a0,a0,a1
80006b78:	c42a                	sw	a0,8(sp)
80006b7a:	00850d13          	add	s10,a0,8
80006b7e:	02ca0513          	add	a0,s4,44
80006b82:	c62a                	sw	a0,12(sp)
80006b84:	250a0513          	add	a0,s4,592
80006b88:	c82a                	sw	a0,16(sp)
80006b8a:	4c91                	li	s9,4
80006b8c:	53425537          	lui	a0,0x53425
80006b90:	35550513          	add	a0,a0,853 # 53425355 <_flash_size+0x53325355>
80006b94:	d02a                	sw	a0,32(sp)
80006b96:	4d85                	li	s11,1
80006b98:	a801                	j	80006ba8 <.LBB1_2>

80006b9a <.LBB1_1>:
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, g_usbd_msc[busid].block_buffer, transfer_len);
80006b9a:	000d4583          	lbu	a1,0(s10)
80006b9e:	8556                	mv	a0,s5
80006ba0:	864a                	mv	a2,s2
80006ba2:	86a6                	mv	a3,s1
80006ba4:	2f0050ef          	jal	8000be94 <usbd_ep_start_write>

80006ba8 <.LBB1_2>:
    uintptr_t event;
    int ret;
    uint8_t busid = (uint8_t)argument;

    while (1) {
        ret = usb_osal_mq_recv(g_usbd_msc[busid].usbd_msc_mq, (uintptr_t *)&event, USB_OSAL_WAITING_FOREVER);
80006ba8:	4008                	lw	a0,0(s0)
80006baa:	102c                	add	a1,sp,40
80006bac:	567d                	li	a2,-1
80006bae:	359000ef          	jal	80007706 <usb_osal_mq_recv>
        if (ret < 0) {
80006bb2:	fe054be3          	bltz	a0,80006ba8 <.LBB1_2>
            continue;
        }
        USB_LOG_DBG("%d\r\n", event);
        if (event == MSC_DATA_OUT) {
80006bb6:	5522                	lw	a0,40(sp)
80006bb8:	4589                	li	a1,2
80006bba:	02b50963          	beq	a0,a1,80006bec <.LBB1_7>
80006bbe:	ffb515e3          	bne	a0,s11,80006ba8 <.LBB1_2>
80006bc2:	4542                	lw	a0,16(sp)
            if (SCSI_processWrite(busid, g_usbd_msc[busid].nbytes) == false) {
80006bc4:	4104                	lw	s1,0(a0)
    if (usbd_msc_sector_write(busid, g_usbd_msc[busid].cbw.bLUN, g_usbd_msc[busid].start_sector, g_usbd_msc[busid].block_buffer, nbytes) != 0) {
80006bc6:	000bc583          	lbu	a1,0(s7)
80006bca:	000c2603          	lw	a2,0(s8)
80006bce:	8556                	mv	a0,s5
80006bd0:	86ca                	mv	a3,s2
80006bd2:	8726                	mv	a4,s1
80006bd4:	80004097          	auipc	ra,0x80004
80006bd8:	584080e7          	jalr	1412(ra) # b158 <usbd_msc_sector_write>
80006bdc:	cd35                	beqz	a0,80006c58 <.LBB1_13>
80006bde:	4572                	lw	a0,28(sp)
80006be0:	4611                	li	a2,4
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80006be2:	00c50023          	sb	a2,0(a0)
80006be6:	4562                	lw	a0,24(sp)
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
80006be8:	458d                	li	a1,3
80006bea:	a089                	j	80006c2c <.LBB1_11>

80006bec <.LBB1_7>:
    transfer_len = MIN(g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN], CONFIG_USBDEV_MSC_MAX_BUFSIZE);
80006bec:	000bc583          	lbu	a1,0(s7)
80006bf0:	000b2503          	lw	a0,0(s6)
80006bf4:	00259613          	sll	a2,a1,0x2
80006bf8:	9652                	add	a2,a2,s4
80006bfa:	4230                	lw	a2,64(a2)
80006bfc:	02a604b3          	mul	s1,a2,a0
80006c00:	20000513          	li	a0,512
80006c04:	00a4e463          	bltu	s1,a0,80006c0c <.LBB1_9>
80006c08:	20000493          	li	s1,512

80006c0c <.LBB1_9>:
    if (usbd_msc_sector_read(busid, g_usbd_msc[busid].cbw.bLUN, g_usbd_msc[busid].start_sector, g_usbd_msc[busid].block_buffer, transfer_len) != 0) {
80006c0c:	000c2603          	lw	a2,0(s8)
80006c10:	8556                	mv	a0,s5
80006c12:	86ca                	mv	a3,s2
80006c14:	8726                	mv	a4,s1
80006c16:	80004097          	auipc	ra,0x80004
80006c1a:	562080e7          	jalr	1378(ra) # b178 <usbd_msc_sector_read>
80006c1e:	c141                	beqz	a0,80006c9e <.LBB1_15>
80006c20:	4572                	lw	a0,28(sp)
80006c22:	4611                	li	a2,4
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80006c24:	00c50023          	sb	a2,0(a0)
80006c28:	4562                	lw	a0,24(sp)
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
80006c2a:	45c5                	li	a1,17

80006c2c <.LBB1_11>:
80006c2c:	00b50023          	sb	a1,0(a0)
80006c30:	4552                	lw	a0,20(sp)
80006c32:	00050023          	sb	zero,0(a0)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
80006c36:	000d4583          	lbu	a1,0(s10)
80006c3a:	5502                	lw	a0,32(sp)
    g_usbd_msc[busid].csw.dSignature = MSC_CSW_Signature;
80006c3c:	00a9a023          	sw	a0,0(s3)
80006c40:	5512                	lw	a0,36(sp)
    g_usbd_msc[busid].csw.bStatus = CSW_Status;
80006c42:	01b50023          	sb	s11,0(a0)
80006c46:	4c91                	li	s9,4
    g_usbd_msc[busid].stage = MSC_WAIT_CSW;
80006c48:	00ca0023          	sb	a2,0(s4)

80006c4c <.LBB1_12>:
80006c4c:	46b5                	li	a3,13
80006c4e:	8556                	mv	a0,s5
80006c50:	864e                	mv	a2,s3
80006c52:	242050ef          	jal	8000be94 <usbd_ep_start_write>
80006c56:	bf89                	j	80006ba8 <.LBB1_2>

80006c58 <.LBB1_13>:
    g_usbd_msc[busid].start_sector += (nbytes / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006c58:	000bc503          	lbu	a0,0(s7)
80006c5c:	050a                	sll	a0,a0,0x2
80006c5e:	9552                	add	a0,a0,s4
80006c60:	4128                	lw	a0,64(a0)
80006c62:	000c2583          	lw	a1,0(s8)
80006c66:	02a4d633          	divu	a2,s1,a0
    g_usbd_msc[busid].nsectors -= (nbytes / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006c6a:	000b2683          	lw	a3,0(s6)
    g_usbd_msc[busid].start_sector += (nbytes / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006c6e:	95b2                	add	a1,a1,a2
80006c70:	47b2                	lw	a5,12(sp)
    g_usbd_msc[busid].csw.dDataResidue -= nbytes;
80006c72:	4398                	lw	a4,0(a5)
    g_usbd_msc[busid].start_sector += (nbytes / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006c74:	00bc2023          	sw	a1,0(s8)
    g_usbd_msc[busid].nsectors -= (nbytes / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006c78:	40c685b3          	sub	a1,a3,a2
80006c7c:	00bb2023          	sw	a1,0(s6)
    g_usbd_msc[busid].csw.dDataResidue -= nbytes;
80006c80:	8f05                	sub	a4,a4,s1
80006c82:	c398                	sw	a4,0(a5)
    if (g_usbd_msc[busid].nsectors == 0) {
80006c84:	04c69963          	bne	a3,a2,80006cd6 <.LBB1_17>
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
80006c88:	000d4583          	lbu	a1,0(s10)
80006c8c:	5502                	lw	a0,32(sp)
    g_usbd_msc[busid].csw.dSignature = MSC_CSW_Signature;
80006c8e:	00a9a023          	sw	a0,0(s3)
80006c92:	5512                	lw	a0,36(sp)
    g_usbd_msc[busid].csw.bStatus = CSW_Status;
80006c94:	00050023          	sb	zero,0(a0)
    g_usbd_msc[busid].stage = MSC_WAIT_CSW;
80006c98:	019a0023          	sb	s9,0(s4)
80006c9c:	bf45                	j	80006c4c <.LBB1_12>

80006c9e <.LBB1_15>:
    g_usbd_msc[busid].start_sector += (transfer_len / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006c9e:	000bc503          	lbu	a0,0(s7)
80006ca2:	050a                	sll	a0,a0,0x2
80006ca4:	9552                	add	a0,a0,s4
80006ca6:	4128                	lw	a0,64(a0)
80006ca8:	000c2583          	lw	a1,0(s8)
80006cac:	02a4d533          	divu	a0,s1,a0
    g_usbd_msc[busid].nsectors -= (transfer_len / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006cb0:	000b2603          	lw	a2,0(s6)
    g_usbd_msc[busid].start_sector += (transfer_len / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006cb4:	95aa                	add	a1,a1,a0
80006cb6:	4732                	lw	a4,12(sp)
    g_usbd_msc[busid].csw.dDataResidue -= transfer_len;
80006cb8:	4314                	lw	a3,0(a4)
    g_usbd_msc[busid].start_sector += (transfer_len / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006cba:	00bc2023          	sw	a1,0(s8)
    g_usbd_msc[busid].nsectors -= (transfer_len / g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN]);
80006cbe:	40a605b3          	sub	a1,a2,a0
80006cc2:	00bb2023          	sw	a1,0(s6)
    g_usbd_msc[busid].csw.dDataResidue -= transfer_len;
80006cc6:	8e85                	sub	a3,a3,s1
80006cc8:	c314                	sw	a3,0(a4)
    if (g_usbd_msc[busid].nsectors == 0) {
80006cca:	eca618e3          	bne	a2,a0,80006b9a <.LBB1_1>
        g_usbd_msc[busid].stage = MSC_SEND_CSW;
80006cce:	450d                	li	a0,3
80006cd0:	00aa0023          	sb	a0,0(s4)
80006cd4:	b5d9                	j	80006b9a <.LBB1_1>

80006cd6 <.LBB1_17>:
        data_len = MIN(g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN], CONFIG_USBDEV_MSC_MAX_BUFSIZE);
80006cd6:	02a586b3          	mul	a3,a1,a0
80006cda:	20000513          	li	a0,512
80006cde:	00a6e463          	bltu	a3,a0,80006ce6 <.LBB1_19>
80006ce2:	20000693          	li	a3,512

80006ce6 <.LBB1_19>:
80006ce6:	4522                	lw	a0,8(sp)
        usbd_ep_start_read(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr, g_usbd_msc[busid].block_buffer, data_len);
80006ce8:	00054583          	lbu	a1,0(a0)
80006cec:	8556                	mv	a0,s5
80006cee:	864a                	mv	a2,s2
80006cf0:	200050ef          	jal	8000bef0 <usbd_ep_start_read>
80006cf4:	bd55                	j	80006ba8 <.LBB1_2>

Disassembly of section .text.mass_storage_bulk_out:

80006cf6 <mass_storage_bulk_out>:
{
80006cf6:	1101                	add	sp,sp,-32
80006cf8:	ce06                	sw	ra,28(sp)
80006cfa:	cc22                	sw	s0,24(sp)
80006cfc:	ca26                	sw	s1,20(sp)
80006cfe:	c84a                	sw	s2,16(sp)
80006d00:	c64e                	sw	s3,12(sp)
80006d02:	c452                	sw	s4,8(sp)
80006d04:	8a2a                	mv	s4,a0
80006d06:	25400513          	li	a0,596
    switch (g_usbd_msc[busid].stage) {
80006d0a:	02aa09b3          	mul	s3,s4,a0
80006d0e:	00097537          	lui	a0,0x97
80006d12:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
80006d16:	99aa                	add	s3,s3,a0
80006d18:	0009c503          	lbu	a0,0(s3)
80006d1c:	4585                	li	a1,1
80006d1e:	08b50263          	beq	a0,a1,80006da2 <.LBB2_6>
80006d22:	2c051563          	bnez	a0,80006fec <.LBB2_38>
80006d26:	25400513          	li	a0,596
    uint8_t *buf2send = g_usbd_msc[busid].block_buffer;
80006d2a:	02aa04b3          	mul	s1,s4,a0
80006d2e:	00097537          	lui	a0,0x97
80006d32:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
80006d36:	94aa                	add	s1,s1,a0
80006d38:	04848513          	add	a0,s1,72
80006d3c:	c22a                	sw	a0,4(sp)
80006d3e:	45fd                	li	a1,31
    uint32_t len2send = 0;
80006d40:	c002                	sw	zero,0(sp)
    if (nbytes != sizeof(struct CBW)) {
80006d42:	0ab61063          	bne	a2,a1,80006de2 <.LBB2_8>
    g_usbd_msc[busid].csw.dTag = g_usbd_msc[busid].cbw.dTag;
80006d46:	4490                	lw	a2,8(s1)
    g_usbd_msc[busid].csw.dDataResidue = g_usbd_msc[busid].cbw.dDataLength;
80006d48:	44cc                	lw	a1,12(s1)
    if ((g_usbd_msc[busid].cbw.dSignature != MSC_CBW_Signature) || (g_usbd_msc[busid].cbw.bCBLength < 1) || (g_usbd_msc[busid].cbw.bCBLength > 16)) {
80006d4a:	40d4                	lw	a3,4(s1)
    g_usbd_msc[busid].csw.dTag = g_usbd_msc[busid].cbw.dTag;
80006d4c:	d490                	sw	a2,40(s1)
80006d4e:	43425637          	lui	a2,0x43425
80006d52:	35560613          	add	a2,a2,853 # 43425355 <_flash_size+0x43325355>
    g_usbd_msc[busid].csw.dDataResidue = g_usbd_msc[busid].cbw.dDataLength;
80006d56:	d4cc                	sw	a1,44(s1)
    if ((g_usbd_msc[busid].cbw.dSignature != MSC_CBW_Signature) || (g_usbd_msc[busid].cbw.bCBLength < 1) || (g_usbd_msc[busid].cbw.bCBLength > 16)) {
80006d58:	02c69463          	bne	a3,a2,80006d80 <.LBB2_5>
80006d5c:	25400613          	li	a2,596
80006d60:	02ca0633          	mul	a2,s4,a2
80006d64:	000976b7          	lui	a3,0x97
80006d68:	a6068693          	add	a3,a3,-1440 # 96a60 <g_usbd_msc>
80006d6c:	9636                	add	a2,a2,a3
80006d6e:	01264683          	lbu	a3,18(a2)
80006d72:	16bd                	add	a3,a3,-17
80006d74:	0ff6f693          	zext.b	a3,a3
80006d78:	0ef00713          	li	a4,239
80006d7c:	10d76d63          	bltu	a4,a3,80006e96 <.LBB2_13>

80006d80 <.LBB2_5>:
80006d80:	25400513          	li	a0,596
80006d84:	02aa0533          	mul	a0,s4,a0
80006d88:	000975b7          	lui	a1,0x97
80006d8c:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
80006d90:	952e                	add	a0,a0,a1
80006d92:	4595                	li	a1,5
80006d94:	02b509a3          	sb	a1,51(a0)
80006d98:	02000593          	li	a1,32
80006d9c:	02b51a23          	sh	a1,52(a0)
80006da0:	a895                	j	80006e14 <.LBB2_9>

80006da2 <.LBB2_6>:
            switch (g_usbd_msc[busid].cbw.CB[0]) {
80006da2:	0139c503          	lbu	a0,19(s3)
80006da6:	08056513          	or	a0,a0,128
80006daa:	0aa00593          	li	a1,170
80006dae:	22b51f63          	bne	a0,a1,80006fec <.LBB2_38>
80006db2:	25400513          	li	a0,596
                    g_usbd_msc[busid].nbytes = nbytes;
80006db6:	02aa0533          	mul	a0,s4,a0
80006dba:	000975b7          	lui	a1,0x97
80006dbe:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
80006dc2:	00a586b3          	add	a3,a1,a0
                    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_OUT);
80006dc6:	2486a503          	lw	a0,584(a3)
80006dca:	4585                	li	a1,1
                    g_usbd_msc[busid].nbytes = nbytes;
80006dcc:	24c6a823          	sw	a2,592(a3)
80006dd0:	40f2                	lw	ra,28(sp)
80006dd2:	4462                	lw	s0,24(sp)
80006dd4:	44d2                	lw	s1,20(sp)
80006dd6:	4942                	lw	s2,16(sp)
80006dd8:	49b2                	lw	s3,12(sp)
80006dda:	4a22                	lw	s4,8(sp)
                    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_OUT);
80006ddc:	6105                	add	sp,sp,32
80006dde:	0f30006f          	j	800076d0 <usb_osal_mq_send>

80006de2 <.LBB2_8>:
        USB_LOG_ERR("size != sizeof(cbw)\r\n");
80006de2:	80010537          	lui	a0,0x80010
80006de6:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
80006dea:	553020ef          	jal	80009b3c <printf>
80006dee:	80011537          	lui	a0,0x80011
80006df2:	9c550513          	add	a0,a0,-1595 # 800109c5 <.Lstr.16>
80006df6:	320060ef          	jal	8000d116 <puts>
80006dfa:	80011537          	lui	a0,0x80011
80006dfe:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
80006e02:	53b020ef          	jal	80009b3c <printf>
80006e06:	4515                	li	a0,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80006e08:	02a489a3          	sb	a0,51(s1)
80006e0c:	02000513          	li	a0,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
80006e10:	02a49a23          	sh	a0,52(s1)

80006e14 <.LBB2_9>:
                USB_LOG_ERR("Command:0x%02x decode err\r\n", g_usbd_msc[busid].cbw.CB[0]);
80006e14:	80010537          	lui	a0,0x80010
80006e18:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
80006e1c:	521020ef          	jal	80009b3c <printf>
80006e20:	25400513          	li	a0,596
80006e24:	02aa04b3          	mul	s1,s4,a0
80006e28:	00097537          	lui	a0,0x97
80006e2c:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
80006e30:	94aa                	add	s1,s1,a0
80006e32:	0134c583          	lbu	a1,19(s1)
80006e36:	11620513          	add	a0,tp,278 # 116 <__BOOT_HEADER_segment_used_size__+0x86>
80006e3a:	503020ef          	jal	80009b3c <printf>
80006e3e:	80011537          	lui	a0,0x80011
80006e42:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
80006e46:	4f7020ef          	jal	80009b3c <printf>
    if ((g_usbd_msc[busid].cbw.bmFlags == 0) && (g_usbd_msc[busid].cbw.dDataLength != 0)) {
80006e4a:	0104c503          	lbu	a0,16(s1)
80006e4e:	004a1413          	sll	s0,s4,0x4
80006e52:	e919                	bnez	a0,80006e68 <.LBB2_12>
80006e54:	44c8                	lw	a0,12(s1)
80006e56:	c909                	beqz	a0,80006e68 <.LBB2_12>
        usbd_ep_set_stall(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr);
80006e58:	5e018513          	add	a0,gp,1504 # 81950 <mass_ep_data>
80006e5c:	9522                	add	a0,a0,s0
80006e5e:	00054583          	lbu	a1,0(a0)
80006e62:	8552                	mv	a0,s4
80006e64:	7f1040ef          	jal	8000be54 <usbd_ep_set_stall>

80006e68 <.LBB2_12>:
    usbd_ep_set_stall(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr);
80006e68:	5e018513          	add	a0,gp,1504 # 81950 <mass_ep_data>
80006e6c:	942a                	add	s0,s0,a0
80006e6e:	00844583          	lbu	a1,8(s0)
    if ((g_usbd_msc[busid].cbw.bmFlags == 0) && (g_usbd_msc[busid].cbw.dDataLength != 0)) {
80006e72:	0491                	add	s1,s1,4
    usbd_ep_set_stall(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr);
80006e74:	8552                	mv	a0,s4
80006e76:	7df040ef          	jal	8000be54 <usbd_ep_set_stall>
    usbd_ep_start_read(busid, mass_ep_data[busid][0].ep_addr, (uint8_t *)&g_usbd_msc[busid].cbw, USB_SIZEOF_MSC_CBW);
80006e7a:	00044583          	lbu	a1,0(s0)
80006e7e:	46fd                	li	a3,31
80006e80:	8552                	mv	a0,s4
80006e82:	8626                	mv	a2,s1
80006e84:	40f2                	lw	ra,28(sp)
80006e86:	4462                	lw	s0,24(sp)
80006e88:	44d2                	lw	s1,20(sp)
80006e8a:	4942                	lw	s2,16(sp)
80006e8c:	49b2                	lw	s3,12(sp)
80006e8e:	4a22                	lw	s4,8(sp)
80006e90:	6105                	add	sp,sp,32
80006e92:	05e0506f          	j	8000bef0 <usbd_ep_start_read>

80006e96 <.LBB2_13>:
        switch (g_usbd_msc[busid].cbw.CB[0]) {
80006e96:	01364683          	lbu	a3,19(a2)
80006e9a:	05a00713          	li	a4,90
80006e9e:	00d76e63          	bltu	a4,a3,80006eba <.LBB2_17>
80006ea2:	068a                	sll	a3,a3,0x2
80006ea4:	80005737          	lui	a4,0x80005
80006ea8:	d6870713          	add	a4,a4,-664 # 80004d68 <.LJTI2_0>
80006eac:	96ba                	add	a3,a3,a4
80006eae:	4294                	lw	a3,0(a3)
80006eb0:	8682                	jr	a3

80006eb2 <.LBB2_15>:
80006eb2:	ec0597e3          	bnez	a1,80006d80 <.LBB2_5>
80006eb6:	c202                	sw	zero,4(sp)
80006eb8:	aa19                	j	80006fce <.LBB2_34>

80006eba <.LBB2_17>:
80006eba:	0a800513          	li	a0,168
80006ebe:	10a68363          	beq	a3,a0,80006fc4 <.LBB2_33>
80006ec2:	0aa00513          	li	a0,170
80006ec6:	00a69663          	bne	a3,a0,80006ed2 <.LBB2_20>
                ret = SCSI_write12(busid, NULL, 0);
80006eca:	8552                	mv	a0,s4
80006ecc:	2ba1                	jal	80007424 <SCSI_write12>
    if (ret) {
80006ece:	d139                	beqz	a0,80006e14 <.LBB2_9>
80006ed0:	a8fd                	j	80006fce <.LBB2_34>

80006ed2 <.LBB2_20>:
80006ed2:	01360413          	add	s0,a2,19
80006ed6:	25400513          	li	a0,596
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80006eda:	02aa0533          	mul	a0,s4,a0
80006ede:	000975b7          	lui	a1,0x97
80006ee2:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
80006ee6:	952e                	add	a0,a0,a1
80006ee8:	4595                	li	a1,5
80006eea:	02b509a3          	sb	a1,51(a0)
80006eee:	02000593          	li	a1,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
80006ef2:	02b51a23          	sh	a1,52(a0)
                USB_LOG_WRN("unsupported cmd:0x%02x\r\n", g_usbd_msc[busid].cbw.CB[0]);
80006ef6:	80010537          	lui	a0,0x80010
80006efa:	11150513          	add	a0,a0,273 # 80010111 <.L.str.8>
80006efe:	43f020ef          	jal	80009b3c <printf>
80006f02:	00044583          	lbu	a1,0(s0)
80006f06:	80011537          	lui	a0,0x80011
80006f0a:	9ac50513          	add	a0,a0,-1620 # 800109ac <.L.str.9>
80006f0e:	42f020ef          	jal	80009b3c <printf>
80006f12:	80011537          	lui	a0,0x80011
80006f16:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
80006f1a:	423020ef          	jal	80009b3c <printf>
80006f1e:	bddd                	j	80006e14 <.LBB2_9>

80006f20 <.LBB2_21>:
                ret = SCSI_read10(busid, NULL, 0);
80006f20:	8552                	mv	a0,s4
80006f22:	2ecd                	jal	80007314 <SCSI_read10>
    if (ret) {
80006f24:	ee0508e3          	beqz	a0,80006e14 <.LBB2_9>
80006f28:	a05d                	j	80006fce <.LBB2_34>

80006f2a <.LBB2_22>:
                ret = SCSI_startStopUnit(busid, &buf2send, &len2send);
80006f2a:	004c                	add	a1,sp,4
80006f2c:	860a                	mv	a2,sp
80006f2e:	8552                	mv	a0,s4
80006f30:	3ef030ef          	jal	8000ab1e <SCSI_startStopUnit>
    if (ret) {
80006f34:	ee0500e3          	beqz	a0,80006e14 <.LBB2_9>
80006f38:	a859                	j	80006fce <.LBB2_34>

80006f3a <.LBB2_23>:
                ret = SCSI_readFormatCapacity(busid, &buf2send, &len2send);
80006f3a:	004c                	add	a1,sp,4
80006f3c:	860a                	mv	a2,sp
80006f3e:	8552                	mv	a0,s4
80006f40:	26b9                	jal	8000728e <SCSI_readFormatCapacity>
    if (ret) {
80006f42:	ec0509e3          	beqz	a0,80006e14 <.LBB2_9>
80006f46:	a061                	j	80006fce <.LBB2_34>

80006f48 <.LBB2_24>:
                ret = SCSI_requestSense(busid, &buf2send, &len2send);
80006f48:	004c                	add	a1,sp,4
80006f4a:	860a                	mv	a2,sp
80006f4c:	8552                	mv	a0,s4
80006f4e:	351030ef          	jal	8000aa9e <SCSI_requestSense>
    if (ret) {
80006f52:	ec0501e3          	beqz	a0,80006e14 <.LBB2_9>
80006f56:	a8a5                	j	80006fce <.LBB2_34>

80006f58 <.LBB2_25>:
                ret = SCSI_inquiry(busid, &buf2send, &len2send);
80006f58:	004c                	add	a1,sp,4
80006f5a:	860a                	mv	a2,sp
80006f5c:	8552                	mv	a0,s4
80006f5e:	2a41                	jal	800070ee <SCSI_inquiry>
    if (ret) {
80006f60:	ea050ae3          	beqz	a0,80006e14 <.LBB2_9>
80006f64:	a0ad                	j	80006fce <.LBB2_34>

80006f66 <.LBB2_26>:
                ret = SCSI_write10(busid, NULL, 0);
80006f66:	8552                	mv	a0,s4
80006f68:	5b7030ef          	jal	8000ad1e <SCSI_write10>
    if (ret) {
80006f6c:	ea0504e3          	beqz	a0,80006e14 <.LBB2_9>
80006f70:	a8b9                	j	80006fce <.LBB2_34>

80006f72 <.LBB2_27>:
                ret = SCSI_readCapacity10(busid, &buf2send, &len2send);
80006f72:	004c                	add	a1,sp,4
80006f74:	860a                	mv	a2,sp
80006f76:	8552                	mv	a0,s4
80006f78:	403030ef          	jal	8000ab7a <SCSI_readCapacity10>
    if (ret) {
80006f7c:	e8050ce3          	beqz	a0,80006e14 <.LBB2_9>
80006f80:	a0b9                	j	80006fce <.LBB2_34>

80006f82 <.LBB2_28>:
                ret = SCSI_modeSense6(busid, &buf2send, &len2send);
80006f82:	004c                	add	a1,sp,4
80006f84:	860a                	mv	a2,sp
80006f86:	8552                	mv	a0,s4
80006f88:	2c61                	jal	80007220 <SCSI_modeSense6>
    if (ret) {
80006f8a:	e80505e3          	beqz	a0,80006e14 <.LBB2_9>
80006f8e:	a081                	j	80006fce <.LBB2_34>

80006f90 <.LBB2_29>:
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
80006f90:	de0588e3          	beqz	a1,80006d80 <.LBB2_5>
80006f94:	25400593          	li	a1,596
    if (g_usbd_msc[busid].cbw.CB[8] < 27) {
80006f98:	02ba05b3          	mul	a1,s4,a1
80006f9c:	00097637          	lui	a2,0x97
80006fa0:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
80006fa4:	95b2                	add	a1,a1,a2
80006fa6:	01b5c903          	lbu	s2,27(a1)
80006faa:	45ed                	li	a1,27
80006fac:	00b96363          	bltu	s2,a1,80006fb2 <.LBB2_32>
80006fb0:	496d                	li	s2,27

80006fb2 <.LBB2_32>:
    memcpy(*data, (uint8_t *)sense10, data_len);
80006fb2:	8000f5b7          	lui	a1,0x8000f
80006fb6:	38058593          	add	a1,a1,896 # 8000f380 <.L__const.SCSI_modeSense10.sense10>
80006fba:	864a                	mv	a2,s2
80006fbc:	0e7020ef          	jal	800098a2 <memcpy>
    *len = data_len;
80006fc0:	c04a                	sw	s2,0(sp)
80006fc2:	a031                	j	80006fce <.LBB2_34>

80006fc4 <.LBB2_33>:
                ret = SCSI_read12(busid, NULL, 0);
80006fc4:	8552                	mv	a0,s4
80006fc6:	431030ef          	jal	8000abf6 <SCSI_read12>
    if (ret) {
80006fca:	e40505e3          	beqz	a0,80006e14 <.LBB2_9>

80006fce <.LBB2_34>:
        if (g_usbd_msc[busid].stage == MSC_READ_CBW) {
80006fce:	0009c503          	lbu	a0,0(s3)
80006fd2:	ed09                	bnez	a0,80006fec <.LBB2_38>
            if (len2send) {
80006fd4:	4502                	lw	a0,0(sp)
80006fd6:	c901                	beqz	a0,80006fe6 <.LBB2_37>
                usbd_msc_send_info(busid, buf2send, len2send);
80006fd8:	4592                	lw	a1,4(sp)
80006fda:	0ff57613          	zext.b	a2,a0
80006fde:	8552                	mv	a0,s4
80006fe0:	64b030ef          	jal	8000ae2a <usbd_msc_send_info>
80006fe4:	a021                	j	80006fec <.LBB2_38>

80006fe6 <.LBB2_37>:
                usbd_msc_send_csw(busid, CSW_STATUS_CMD_PASSED);
80006fe6:	8552                	mv	a0,s4
80006fe8:	4581                	li	a1,0
80006fea:	20c9                	jal	800070ac <usbd_msc_send_csw>

80006fec <.LBB2_38>:
80006fec:	40f2                	lw	ra,28(sp)
80006fee:	4462                	lw	s0,24(sp)
80006ff0:	44d2                	lw	s1,20(sp)
80006ff2:	4942                	lw	s2,16(sp)
80006ff4:	49b2                	lw	s3,12(sp)
80006ff6:	4a22                	lw	s4,8(sp)
}
80006ff8:	6105                	add	sp,sp,32
80006ffa:	8082                	ret

Disassembly of section .text.mass_storage_bulk_in:

80006ffc <mass_storage_bulk_in>:
{
80006ffc:	25400593          	li	a1,596
    switch (g_usbd_msc[busid].stage) {
80007000:	02b50733          	mul	a4,a0,a1
80007004:	000975b7          	lui	a1,0x97
80007008:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
8000700c:	972e                	add	a4,a4,a1
8000700e:	00074583          	lbu	a1,0(a4)
80007012:	4611                	li	a2,4
80007014:	06c58e63          	beq	a1,a2,80007090 <.LBB3_7>
80007018:	460d                	li	a2,3
8000701a:	02c58b63          	beq	a1,a2,80007050 <.LBB3_6>
8000701e:	4609                	li	a2,2
80007020:	02c59763          	bne	a1,a2,8000704e <.LBB3_5>
80007024:	25400593          	li	a1,596
            switch (g_usbd_msc[busid].cbw.CB[0]) {
80007028:	02b50533          	mul	a0,a0,a1
8000702c:	000975b7          	lui	a1,0x97
80007030:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
80007034:	952e                	add	a0,a0,a1
80007036:	01354583          	lbu	a1,19(a0)
8000703a:	0805e593          	or	a1,a1,128
8000703e:	0a800613          	li	a2,168
80007042:	00c59663          	bne	a1,a2,8000704e <.LBB3_5>
                    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_IN);
80007046:	24852503          	lw	a0,584(a0)
8000704a:	4589                	li	a1,2
8000704c:	a551                	j	800076d0 <usb_osal_mq_send>

8000704e <.LBB3_5>:
}
8000704e:	8082                	ret

80007050 <.LBB3_6>:
80007050:	25400593          	li	a1,596
    g_usbd_msc[busid].csw.dSignature = MSC_CSW_Signature;
80007054:	02b505b3          	mul	a1,a0,a1
80007058:	00097637          	lui	a2,0x97
8000705c:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
80007060:	00b607b3          	add	a5,a2,a1
80007064:	02478613          	add	a2,a5,36
80007068:	4591                	li	a1,4
    g_usbd_msc[busid].stage = MSC_WAIT_CSW;
8000706a:	00b70023          	sb	a1,0(a4)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
8000706e:	00451593          	sll	a1,a0,0x4
80007072:	5e018693          	add	a3,gp,1504 # 81950 <mass_ep_data>
80007076:	95b6                	add	a1,a1,a3
80007078:	534256b7          	lui	a3,0x53425
8000707c:	0085c583          	lbu	a1,8(a1)
80007080:	35568693          	add	a3,a3,853 # 53425355 <_flash_size+0x53325355>
    g_usbd_msc[busid].csw.dSignature = MSC_CSW_Signature;
80007084:	d3d4                	sw	a3,36(a5)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
80007086:	46b5                	li	a3,13
    g_usbd_msc[busid].csw.bStatus = CSW_Status;
80007088:	02078823          	sb	zero,48(a5)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
8000708c:	6090406f          	j	8000be94 <usbd_ep_start_write>

80007090 <.LBB3_7>:
            usbd_ep_start_read(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].cbw, USB_SIZEOF_MSC_CBW);
80007090:	00451593          	sll	a1,a0,0x4
80007094:	5e018613          	add	a2,gp,1504 # 81950 <mass_ep_data>
80007098:	95b2                	add	a1,a1,a2
8000709a:	0005c583          	lbu	a1,0(a1)
8000709e:	00470613          	add	a2,a4,4
800070a2:	46fd                	li	a3,31
            g_usbd_msc[busid].stage = MSC_READ_CBW;
800070a4:	00070023          	sb	zero,0(a4)
            usbd_ep_start_read(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].cbw, USB_SIZEOF_MSC_CBW);
800070a8:	6490406f          	j	8000bef0 <usbd_ep_start_read>

Disassembly of section .text.usbd_msc_send_csw:

800070ac <usbd_msc_send_csw>:
{
800070ac:	25400613          	li	a2,596
    g_usbd_msc[busid].csw.dSignature = MSC_CSW_Signature;
800070b0:	02c50633          	mul	a2,a0,a2
800070b4:	000976b7          	lui	a3,0x97
800070b8:	a6068693          	add	a3,a3,-1440 # 96a60 <g_usbd_msc>
800070bc:	00c687b3          	add	a5,a3,a2
800070c0:	02478613          	add	a2,a5,36
800070c4:	534256b7          	lui	a3,0x53425
800070c8:	35568693          	add	a3,a3,853 # 53425355 <_flash_size+0x53325355>
800070cc:	d3d4                	sw	a3,36(a5)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
800070ce:	00451693          	sll	a3,a0,0x4
800070d2:	5e018713          	add	a4,gp,1504 # 81950 <mass_ep_data>
800070d6:	96ba                	add	a3,a3,a4
800070d8:	0086c703          	lbu	a4,8(a3)
    g_usbd_msc[busid].csw.bStatus = CSW_Status;
800070dc:	02b78823          	sb	a1,48(a5)
800070e0:	4591                	li	a1,4
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
800070e2:	46b5                	li	a3,13
    g_usbd_msc[busid].stage = MSC_WAIT_CSW;
800070e4:	00b78023          	sb	a1,0(a5)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].csw, sizeof(struct CSW));
800070e8:	85ba                	mv	a1,a4
800070ea:	5ab0406f          	j	8000be94 <usbd_ep_start_write>

Disassembly of section .text.SCSI_inquiry:

800070ee <SCSI_inquiry>:
{
800070ee:	7179                	add	sp,sp,-48
800070f0:	d606                	sw	ra,44(sp)
800070f2:	d422                	sw	s0,40(sp)
800070f4:	d226                	sw	s1,36(sp)
800070f6:	46fd                	li	a3,31
    uint8_t inquiry[SCSIRESP_INQUIRY_SIZEOF] = {
800070f8:	c236                	sw	a3,4(sp)
800070fa:	020286b7          	lui	a3,0x2028
800070fe:	c036                	sw	a3,0(sp)
80007100:	202026b7          	lui	a3,0x20202
80007104:	02068713          	add	a4,a3,32 # 20202020 <_flash_size+0x20102020>
80007108:	ce3a                	sw	a4,28(sp)
8000710a:	cc3a                	sw	a4,24(sp)
8000710c:	ca3a                	sw	a4,20(sp)
8000710e:	c83a                	sw	a4,16(sp)
80007110:	c63a                	sw	a4,12(sp)
80007112:	25400693          	li	a3,596
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
80007116:	02d506b3          	mul	a3,a0,a3
8000711a:	000977b7          	lui	a5,0x97
8000711e:	a6078793          	add	a5,a5,-1440 # 96a60 <g_usbd_msc>
80007122:	96be                	add	a3,a3,a5
80007124:	46dc                	lw	a5,12(a3)
    uint8_t inquiry[SCSIRESP_INQUIRY_SIZEOF] = {
80007126:	c43a                	sw	a4,8(sp)
80007128:	31303737          	lui	a4,0x31303
8000712c:	e3070713          	add	a4,a4,-464 # 31302e30 <_flash_size+0x31202e30>
    memcpy(&inquiry[32], CONFIG_USBDEV_MSC_VERSION_STRING, strlen(CONFIG_USBDEV_MSC_VERSION_STRING));
80007130:	d03a                	sw	a4,32(sp)
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
80007132:	cf95                	beqz	a5,8000716e <.LBB10_5>
    if ((g_usbd_msc[busid].cbw.CB[1] & 0x01U) != 0U) { /* Evpd is set */
80007134:	0146c683          	lbu	a3,20(a3)
80007138:	8a85                	and	a3,a3,1
8000713a:	e2b9                	bnez	a3,80007180 <.LBB10_6>
8000713c:	84b2                	mv	s1,a2
8000713e:	25400613          	li	a2,596
        if (g_usbd_msc[busid].cbw.CB[4] < SCSIRESP_INQUIRY_SIZEOF) {
80007142:	02c50533          	mul	a0,a0,a2
80007146:	00097637          	lui	a2,0x97
8000714a:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
8000714e:	9532                	add	a0,a0,a2
80007150:	01754403          	lbu	s0,23(a0)
80007154:	02400513          	li	a0,36
80007158:	00a46463          	bltu	s0,a0,80007160 <.LBB10_4>
8000715c:	02400413          	li	s0,36

80007160 <.LBB10_4>:
        memcpy(*data, (uint8_t *)inquiry, data_len);
80007160:	4188                	lw	a0,0(a1)
80007162:	858a                	mv	a1,sp
80007164:	8622                	mv	a2,s0
80007166:	73c020ef          	jal	800098a2 <memcpy>
8000716a:	8626                	mv	a2,s1
8000716c:	a041                	j	800071ec <.LBB10_10>

8000716e <.LBB10_5>:
8000716e:	4501                	li	a0,0
80007170:	4595                	li	a1,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80007172:	02b689a3          	sb	a1,51(a3)
80007176:	02000593          	li	a1,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000717a:	02b69a23          	sh	a1,52(a3)
8000717e:	a88d                	j	800071f0 <.LBB10_11>

80007180 <.LBB10_6>:
80007180:	25400693          	li	a3,596
        if (g_usbd_msc[busid].cbw.CB[2] == 0U) {       /* Request for Supported Vital Product Data Pages*/
80007184:	02d506b3          	mul	a3,a0,a3
80007188:	00097737          	lui	a4,0x97
8000718c:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
80007190:	96ba                	add	a3,a3,a4
80007192:	0156c703          	lbu	a4,21(a3)
80007196:	08000693          	li	a3,128
8000719a:	02d70563          	beq	a4,a3,800071c4 <.LBB10_9>
8000719e:	ef31                	bnez	a4,800071fa <.LBB10_12>
            memcpy(*data, (uint8_t *)inquiry00, data_len);
800071a0:	4188                	lw	a0,0(a1)
800071a2:	08000593          	li	a1,128
800071a6:	00b502a3          	sb	a1,5(a0)
800071aa:	00050223          	sb	zero,4(a0)
800071ae:	4589                	li	a1,2
800071b0:	00b501a3          	sb	a1,3(a0)
800071b4:	00050123          	sb	zero,2(a0)
800071b8:	000500a3          	sb	zero,1(a0)
800071bc:	00050023          	sb	zero,0(a0)
800071c0:	4419                	li	s0,6
800071c2:	a02d                	j	800071ec <.LBB10_10>

800071c4 <.LBB10_9>:
            memcpy(*data, (uint8_t *)inquiry80, data_len);
800071c4:	4188                	lw	a0,0(a1)
800071c6:	02000593          	li	a1,32
800071ca:	00b503a3          	sb	a1,7(a0)
800071ce:	00b50323          	sb	a1,6(a0)
800071d2:	00b502a3          	sb	a1,5(a0)
800071d6:	00b50223          	sb	a1,4(a0)
800071da:	4421                	li	s0,8
800071dc:	008501a3          	sb	s0,3(a0)
800071e0:	00050123          	sb	zero,2(a0)
800071e4:	00d500a3          	sb	a3,1(a0)
800071e8:	00050023          	sb	zero,0(a0)

800071ec <.LBB10_10>:
    *len = data_len;
800071ec:	c200                	sw	s0,0(a2)
800071ee:	4505                	li	a0,1

800071f0 <.LBB10_11>:
800071f0:	50b2                	lw	ra,44(sp)
800071f2:	5422                	lw	s0,40(sp)
800071f4:	5492                	lw	s1,36(sp)
}
800071f6:	6145                	add	sp,sp,48
800071f8:	8082                	ret

800071fa <.LBB10_12>:
800071fa:	4581                	li	a1,0
800071fc:	25400613          	li	a2,596
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80007200:	02c50633          	mul	a2,a0,a2
80007204:	4501                	li	a0,0
80007206:	000975b7          	lui	a1,0x97
8000720a:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
8000720e:	95b2                	add	a1,a1,a2
80007210:	4615                	li	a2,5
80007212:	02c589a3          	sb	a2,51(a1)
80007216:	02400613          	li	a2,36
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000721a:	02c59a23          	sh	a2,52(a1)
8000721e:	bfc9                	j	800071f0 <.LBB10_11>

Disassembly of section .text.SCSI_modeSense6:

80007220 <SCSI_modeSense6>:
{
80007220:	1101                	add	sp,sp,-32
80007222:	ce06                	sw	ra,28(sp)
80007224:	cc22                	sw	s0,24(sp)
80007226:	ca26                	sw	s1,20(sp)
80007228:	c84a                	sw	s2,16(sp)
8000722a:	25400693          	li	a3,596
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000722e:	02d50533          	mul	a0,a0,a3
80007232:	000976b7          	lui	a3,0x97
80007236:	a6068693          	add	a3,a3,-1440 # 96a60 <g_usbd_msc>
8000723a:	9536                	add	a0,a0,a3
8000723c:	4540                	lw	s0,12(a0)
8000723e:	c80d                	beqz	s0,80007270 <.LBB12_6>
80007240:	8932                	mv	s2,a2
    if (g_usbd_msc[busid].cbw.CB[4] < SCSIRESP_MODEPARAMETERHDR6_SIZEOF) {
80007242:	01754483          	lbu	s1,23(a0)
80007246:	4611                	li	a2,4
80007248:	00c4e363          	bltu	s1,a2,8000724e <.LBB12_3>
8000724c:	4491                	li	s1,4

8000724e <.LBB12_3>:
    if (g_usbd_msc[busid].readonly) {
8000724e:	03154503          	lbu	a0,49(a0)
80007252:	460d                	li	a2,3
    uint8_t sense6[SCSIRESP_MODEPARAMETERHDR6_SIZEOF] = { 0x03, 0x00, 0x00, 0x00 };
80007254:	c632                	sw	a2,12(sp)
    if (g_usbd_msc[busid].readonly) {
80007256:	c509                	beqz	a0,80007260 <.LBB12_5>
80007258:	08000513          	li	a0,128
        sense6[2] = 0x80;
8000725c:	00a10723          	sb	a0,14(sp)

80007260 <.LBB12_5>:
    memcpy(*data, (uint8_t *)sense6, data_len);
80007260:	4188                	lw	a0,0(a1)
80007262:	006c                	add	a1,sp,12
80007264:	8626                	mv	a2,s1
80007266:	63c020ef          	jal	800098a2 <memcpy>
    *len = data_len;
8000726a:	00992023          	sw	s1,0(s2)
8000726e:	a801                	j	8000727e <.LBB12_7>

80007270 <.LBB12_6>:
80007270:	4595                	li	a1,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80007272:	02b509a3          	sb	a1,51(a0)
80007276:	02000593          	li	a1,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000727a:	02b51a23          	sh	a1,52(a0)

8000727e <.LBB12_7>:
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000727e:	00803533          	snez	a0,s0
80007282:	40f2                	lw	ra,28(sp)
80007284:	4462                	lw	s0,24(sp)
80007286:	44d2                	lw	s1,20(sp)
80007288:	4942                	lw	s2,16(sp)
}
8000728a:	6105                	add	sp,sp,32
8000728c:	8082                	ret

Disassembly of section .text.SCSI_readFormatCapacity:

8000728e <SCSI_readFormatCapacity>:
{
8000728e:	25400693          	li	a3,596
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
80007292:	02d506b3          	mul	a3,a0,a3
80007296:	00097537          	lui	a0,0x97
8000729a:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
8000729e:	96aa                	add	a3,a3,a0
800072a0:	46c8                	lw	a0,12(a3)
800072a2:	cd39                	beqz	a0,80007300 <.LBB13_2>
        (uint8_t)((g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN] >> 24) & 0xff),
800072a4:	0116c703          	lbu	a4,17(a3)
800072a8:	070a                	sll	a4,a4,0x2
800072aa:	96ba                	add	a3,a3,a4
800072ac:	42f8                	lw	a4,68(a3)
800072ae:	01875813          	srl	a6,a4,0x18
        (uint8_t)((g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN] >> 8) & 0xff),
800072b2:	42b4                	lw	a3,64(a3)
    memcpy(*data, (uint8_t *)format_capacity, SCSIRESP_READFORMATCAPACITIES_SIZEOF);
800072b4:	418c                	lw	a1,0(a1)
        (uint8_t)((g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN] >> 16) & 0xff),
800072b6:	01075313          	srl	t1,a4,0x10
        (uint8_t)((g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN] >> 8) & 0xff),
800072ba:	00875893          	srl	a7,a4,0x8
        (uint8_t)((g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN] >> 8) & 0xff),
800072be:	0086d293          	srl	t0,a3,0x8
    memcpy(*data, (uint8_t *)format_capacity, SCSIRESP_READFORMATCAPACITIES_SIZEOF);
800072c2:	00058023          	sb	zero,0(a1)
800072c6:	000580a3          	sb	zero,1(a1)
800072ca:	00058123          	sb	zero,2(a1)
800072ce:	47a1                	li	a5,8
800072d0:	00f581a3          	sb	a5,3(a1)
800072d4:	01058223          	sb	a6,4(a1)
800072d8:	006582a3          	sb	t1,5(a1)
800072dc:	01158323          	sb	a7,6(a1)
800072e0:	00e583a3          	sb	a4,7(a1)
800072e4:	4709                	li	a4,2
800072e6:	00e58423          	sb	a4,8(a1)
800072ea:	000584a3          	sb	zero,9(a1)
800072ee:	00558523          	sb	t0,10(a1)
800072f2:	00d585a3          	sb	a3,11(a1)
800072f6:	45b1                	li	a1,12
    *len = SCSIRESP_READFORMATCAPACITIES_SIZEOF;
800072f8:	c20c                	sw	a1,0(a2)
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
800072fa:	00a03533          	snez	a0,a0
}
800072fe:	8082                	ret

80007300 <.LBB13_2>:
80007300:	4595                	li	a1,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80007302:	02b689a3          	sb	a1,51(a3)
80007306:	02000593          	li	a1,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000730a:	02b69a23          	sh	a1,52(a3)
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000730e:	00a03533          	snez	a0,a0
}
80007312:	8082                	ret

Disassembly of section .text.SCSI_read10:

80007314 <SCSI_read10>:
{
80007314:	25400593          	li	a1,596
    if (((g_usbd_msc[busid].cbw.bmFlags & 0x80U) != 0x80U) || (g_usbd_msc[busid].cbw.dDataLength == 0U)) {
80007318:	02b505b3          	mul	a1,a0,a1
8000731c:	00097637          	lui	a2,0x97
80007320:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
80007324:	95b2                	add	a1,a1,a2
80007326:	01058603          	lb	a2,16(a1)
8000732a:	00064b63          	bltz	a2,80007340 <.LBB15_2>

8000732e <.LBB15_1>:
8000732e:	4501                	li	a0,0
80007330:	4615                	li	a2,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
80007332:	02c589a3          	sb	a2,51(a1)
80007336:	02000613          	li	a2,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000733a:	02c59a23          	sh	a2,52(a1)
}
8000733e:	8082                	ret

80007340 <.LBB15_2>:
    if (((g_usbd_msc[busid].cbw.bmFlags & 0x80U) != 0x80U) || (g_usbd_msc[busid].cbw.dDataLength == 0U)) {
80007340:	00c5a803          	lw	a6,12(a1)
80007344:	fe0805e3          	beqz	a6,8000732e <.LBB15_1>
80007348:	1141                	add	sp,sp,-16
8000734a:	c606                	sw	ra,12(sp)
8000734c:	25400693          	li	a3,596
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
80007350:	02d506b3          	mul	a3,a0,a3
80007354:	00097737          	lui	a4,0x97
80007358:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
8000735c:	96ba                	add	a3,a3,a4
8000735e:	0156c703          	lbu	a4,21(a3)
80007362:	0166c783          	lbu	a5,22(a3)
80007366:	0762                	sll	a4,a4,0x18
80007368:	0176c603          	lbu	a2,23(a3)
8000736c:	07c2                	sll	a5,a5,0x10
8000736e:	0186c883          	lbu	a7,24(a3)
80007372:	00e7e2b3          	or	t0,a5,a4
80007376:	0622                	sll	a2,a2,0x8
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
80007378:	01a6c783          	lbu	a5,26(a3)
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000737c:	01166633          	or	a2,a2,a7
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
80007380:	0116c703          	lbu	a4,17(a3)
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
80007384:	00c2e633          	or	a2,t0,a2
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
80007388:	00879893          	sll	a7,a5,0x8
8000738c:	01b6c783          	lbu	a5,27(a3)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
80007390:	070a                	sll	a4,a4,0x2
80007392:	9736                	add	a4,a4,a3
80007394:	04472283          	lw	t0,68(a4)
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
80007398:	00f8e7b3          	or	a5,a7,a5
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000739c:	de90                	sw	a2,56(a3)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000739e:	963e                	add	a2,a2,a5
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
800073a0:	dedc                	sw	a5,60(a3)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
800073a2:	02c2f463          	bgeu	t0,a2,800073ca <.LBB15_5>
800073a6:	4515                	li	a0,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
800073a8:	02a689a3          	sb	a0,51(a3)
800073ac:	02100513          	li	a0,33
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
800073b0:	02a69a23          	sh	a0,52(a3)
        USB_LOG_ERR("LBA out of range\r\n");
800073b4:	80010537          	lui	a0,0x80010
800073b8:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
800073bc:	780020ef          	jal	80009b3c <printf>
800073c0:	80010537          	lui	a0,0x80010
800073c4:	1e350513          	add	a0,a0,483 # 800101e3 <.Lstr.23>
800073c8:	a091                	j	8000740c <.LBB15_8>

800073ca <.LBB15_5>:
    if (g_usbd_msc[busid].cbw.dDataLength != (g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN])) {
800073ca:	4330                	lw	a2,64(a4)
800073cc:	02f60633          	mul	a2,a2,a5
800073d0:	02c81463          	bne	a6,a2,800073f8 <.LBB15_7>
800073d4:	25400613          	li	a2,596
    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_IN);
800073d8:	02c50533          	mul	a0,a0,a2
800073dc:	00097637          	lui	a2,0x97
800073e0:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
800073e4:	9532                	add	a0,a0,a2
800073e6:	24852503          	lw	a0,584(a0)
800073ea:	4609                	li	a2,2
    g_usbd_msc[busid].stage = MSC_DATA_IN;
800073ec:	00c58023          	sb	a2,0(a1)
    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_IN);
800073f0:	4589                	li	a1,2
800073f2:	2cf9                	jal	800076d0 <usb_osal_mq_send>
800073f4:	4505                	li	a0,1
800073f6:	a025                	j	8000741e <.LBB15_9>

800073f8 <.LBB15_7>:
        USB_LOG_ERR("scsi_blk_len does not match with dDataLength\r\n");
800073f8:	80010537          	lui	a0,0x80010
800073fc:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
80007400:	73c020ef          	jal	80009b3c <printf>
80007404:	80010537          	lui	a0,0x80010
80007408:	1b550513          	add	a0,a0,437 # 800101b5 <.Lstr.20>

8000740c <.LBB15_8>:
8000740c:	50b050ef          	jal	8000d116 <puts>
80007410:	80011537          	lui	a0,0x80011
80007414:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
80007418:	724020ef          	jal	80009b3c <printf>
8000741c:	4501                	li	a0,0

8000741e <.LBB15_9>:
8000741e:	40b2                	lw	ra,12(sp)
80007420:	0141                	add	sp,sp,16
}
80007422:	8082                	ret

Disassembly of section .text.SCSI_write12:

80007424 <SCSI_write12>:
{
80007424:	1141                	add	sp,sp,-16
80007426:	c606                	sw	ra,12(sp)
80007428:	25400593          	li	a1,596
    if (((g_usbd_msc[busid].cbw.bmFlags & 0x80U) != 0x00U) || (g_usbd_msc[busid].cbw.dDataLength == 0U)) {
8000742c:	02b505b3          	mul	a1,a0,a1
80007430:	00097637          	lui	a2,0x97
80007434:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
80007438:	95b2                	add	a1,a1,a2
8000743a:	01058603          	lb	a2,16(a1)
8000743e:	0a064163          	bltz	a2,800074e0 <.LBB18_4>
80007442:	45d4                	lw	a3,12(a1)
80007444:	ced1                	beqz	a3,800074e0 <.LBB18_4>
80007446:	25400613          	li	a2,596
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000744a:	02c50633          	mul	a2,a0,a2
8000744e:	00097737          	lui	a4,0x97
80007452:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
80007456:	00c707b3          	add	a5,a4,a2
8000745a:	0157c603          	lbu	a2,21(a5)
8000745e:	0167c703          	lbu	a4,22(a5)
80007462:	0662                	sll	a2,a2,0x18
80007464:	0177c803          	lbu	a6,23(a5)
80007468:	0742                	sll	a4,a4,0x10
8000746a:	00c768b3          	or	a7,a4,a2
8000746e:	0187c283          	lbu	t0,24(a5)
80007472:	0822                	sll	a6,a6,0x8
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
80007474:	0197c303          	lbu	t1,25(a5)
80007478:	01a7c703          	lbu	a4,26(a5)
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000747c:	00586633          	or	a2,a6,t0
80007480:	00c8e833          	or	a6,a7,a2
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
80007484:	0362                	sll	t1,t1,0x18
80007486:	01071893          	sll	a7,a4,0x10
8000748a:	01b7c283          	lbu	t0,27(a5)
8000748e:	01c7c703          	lbu	a4,28(a5)
    data_len = g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN];
80007492:	0117c603          	lbu	a2,17(a5)
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
80007496:	0068e8b3          	or	a7,a7,t1
8000749a:	02a2                	sll	t0,t0,0x8
8000749c:	00e2e733          	or	a4,t0,a4
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
800074a0:	060a                	sll	a2,a2,0x2
800074a2:	963e                	add	a2,a2,a5
800074a4:	04462283          	lw	t0,68(a2)
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
800074a8:	00e8e733          	or	a4,a7,a4
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
800074ac:	0307ac23          	sw	a6,56(a5)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
800074b0:	983a                	add	a6,a6,a4
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
800074b2:	dfd8                	sw	a4,60(a5)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
800074b4:	0502f163          	bgeu	t0,a6,800074f6 <.LBB18_6>
        USB_LOG_ERR("LBA out of range\r\n");
800074b8:	80010537          	lui	a0,0x80010
800074bc:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
800074c0:	67c020ef          	jal	80009b3c <printf>
800074c4:	80010537          	lui	a0,0x80010
800074c8:	1e350513          	add	a0,a0,483 # 800101e3 <.Lstr.23>
800074cc:	44b050ef          	jal	8000d116 <puts>
800074d0:	80011537          	lui	a0,0x80011
800074d4:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
800074d8:	664020ef          	jal	80009b3c <printf>
800074dc:	4501                	li	a0,0
800074de:	a809                	j	800074f0 <.LBB18_5>

800074e0 <.LBB18_4>:
800074e0:	4501                	li	a0,0
800074e2:	4615                	li	a2,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
800074e4:	02c589a3          	sb	a2,51(a1)
800074e8:	02000613          	li	a2,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
800074ec:	02c59a23          	sh	a2,52(a1)

800074f0 <.LBB18_5>:
800074f0:	40b2                	lw	ra,12(sp)
}
800074f2:	0141                	add	sp,sp,16
800074f4:	8082                	ret

800074f6 <.LBB18_6>:
    data_len = g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN];
800074f6:	4230                	lw	a2,64(a2)
800074f8:	02c70633          	mul	a2,a4,a2
    if (g_usbd_msc[busid].cbw.dDataLength != data_len) {
800074fc:	04c69163          	bne	a3,a2,8000753e <.LBB18_10>
80007500:	4605                	li	a2,1
80007502:	20000713          	li	a4,512
    g_usbd_msc[busid].stage = MSC_DATA_OUT;
80007506:	00c58023          	sb	a2,0(a1)
    data_len = MIN(data_len, CONFIG_USBDEV_MSC_MAX_BUFSIZE);
8000750a:	00e6e463          	bltu	a3,a4,80007512 <.LBB18_9>
8000750e:	20000693          	li	a3,512

80007512 <.LBB18_9>:
    usbd_ep_start_read(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr, g_usbd_msc[busid].block_buffer, data_len);
80007512:	00451593          	sll	a1,a0,0x4
80007516:	5e018613          	add	a2,gp,1504 # 81950 <mass_ep_data>
8000751a:	95b2                	add	a1,a1,a2
8000751c:	0005c583          	lbu	a1,0(a1)
80007520:	25400613          	li	a2,596
80007524:	02c50633          	mul	a2,a0,a2
80007528:	00097737          	lui	a4,0x97
8000752c:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
80007530:	963a                	add	a2,a2,a4
80007532:	04860613          	add	a2,a2,72
80007536:	1bb040ef          	jal	8000bef0 <usbd_ep_start_read>
8000753a:	4505                	li	a0,1
8000753c:	bf55                	j	800074f0 <.LBB18_5>

8000753e <.LBB18_10>:
8000753e:	4501                	li	a0,0
80007540:	bf45                	j	800074f0 <.LBB18_5>

Disassembly of section .text.usbd_event_connect_handler:

80007542 <usbd_event_connect_handler>:
        }
    }
}

void usbd_event_connect_handler(uint8_t busid)
{
80007542:	3d400593          	li	a1,980
    g_usbd_core[busid].event_handler(busid, USBD_EVENT_CONNECTED);
80007546:	02b505b3          	mul	a1,a0,a1
8000754a:	00089637          	lui	a2,0x89
8000754e:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
80007552:	95b2                	add	a1,a1,a2
80007554:	3d05a783          	lw	a5,976(a1)
80007558:	458d                	li	a1,3
8000755a:	8782                	jr	a5

Disassembly of section .text.usbd_event_disconnect_handler:

8000755c <usbd_event_disconnect_handler>:
}

void usbd_event_disconnect_handler(uint8_t busid)
{
8000755c:	3d400593          	li	a1,980
    g_usbd_core[busid].event_handler(busid, USBD_EVENT_DISCONNECTED);
80007560:	02b505b3          	mul	a1,a0,a1
80007564:	00089637          	lui	a2,0x89
80007568:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
8000756c:	95b2                	add	a1,a1,a2
8000756e:	3d05a783          	lw	a5,976(a1)
80007572:	4591                	li	a1,4
80007574:	8782                	jr	a5

Disassembly of section .text.usbd_event_suspend_handler:

80007576 <usbd_event_suspend_handler>:
{
    g_usbd_core[busid].event_handler(busid, USBD_EVENT_RESUME);
}

void usbd_event_suspend_handler(uint8_t busid)
{
80007576:	3d400593          	li	a1,980
    g_usbd_core[busid].event_handler(busid, USBD_EVENT_SUSPEND);
8000757a:	02b505b3          	mul	a1,a0,a1
8000757e:	00089637          	lui	a2,0x89
80007582:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
80007586:	95b2                	add	a1,a1,a2
80007588:	3d05a783          	lw	a5,976(a1)
8000758c:	4595                	li	a1,5
8000758e:	8782                	jr	a5

Disassembly of section .text.usbd_event_reset_handler:

80007590 <usbd_event_reset_handler>:
}

void usbd_event_reset_handler(uint8_t busid)
{
80007590:	1101                	add	sp,sp,-32
80007592:	ce06                	sw	ra,28(sp)
80007594:	cc22                	sw	s0,24(sp)
80007596:	ca26                	sw	s1,20(sp)
80007598:	c84a                	sw	s2,16(sp)
8000759a:	c64e                	sw	s3,12(sp)
8000759c:	c452                	sw	s4,8(sp)
8000759e:	89aa                	mv	s3,a0
    usbd_set_address(busid, 0);
800075a0:	4581                	li	a1,0
800075a2:	2a69                	jal	8000773c <usbd_set_address>
800075a4:	3d400513          	li	a0,980
    g_usbd_core[busid].configuration = 0;
800075a8:	02a98933          	mul	s2,s3,a0
800075ac:	00089537          	lui	a0,0x89
800075b0:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
800075b4:	992a                	add	s2,s2,a0
800075b6:	22090423          	sb	zero,552(s2)
800075ba:	451d                	li	a0,7
#ifdef CONFIG_USBDEV_TEST_MODE
    g_usbd_core[busid].test_mode = false;
#endif
    struct usb_endpoint_descriptor ep0;

    ep0.bLength = 7;
800075bc:	00a100a3          	sb	a0,1(sp)
800075c0:	4515                	li	a0,5
    ep0.bDescriptorType = USB_DESCRIPTOR_TYPE_ENDPOINT;
800075c2:	00a10123          	sb	a0,2(sp)
    ep0.wMaxPacketSize = USB_CTRL_EP_MPS;
800075c6:	00010323          	sb	zero,6(sp)
800075ca:	04000513          	li	a0,64
800075ce:	00a102a3          	sb	a0,5(sp)
    ep0.bmAttributes = USB_ENDPOINT_TYPE_CONTROL;
800075d2:	00010223          	sb	zero,4(sp)
800075d6:	08000513          	li	a0,128
    ep0.bEndpointAddress = USB_CONTROL_IN_EP0;
800075da:	00a101a3          	sb	a0,3(sp)
    ep0.bInterval = 0;
800075de:	000103a3          	sb	zero,7(sp)
    usbd_ep_open(busid, &ep0);
800075e2:	00110593          	add	a1,sp,1
800075e6:	854e                	mv	a0,s3
800075e8:	784040ef          	jal	8000bd6c <usbd_ep_open>

    ep0.bEndpointAddress = USB_CONTROL_OUT_EP0;
800075ec:	000101a3          	sb	zero,3(sp)
    usbd_ep_open(busid, &ep0);
800075f0:	00110593          	add	a1,sp,1
800075f4:	854e                	mv	a0,s3
800075f6:	776040ef          	jal	8000bd6c <usbd_ep_open>
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
800075fa:	24c94503          	lbu	a0,588(s2)
800075fe:	c905                	beqz	a0,8000762e <.LBB4_6>
80007600:	4481                	li	s1,0
80007602:	24c90a13          	add	s4,s2,588
80007606:	22c90413          	add	s0,s2,556
8000760a:	a039                	j	80007618 <.LBB4_3>

8000760c <.LBB4_2>:
8000760c:	0485                	add	s1,s1,1
8000760e:	0ff57593          	zext.b	a1,a0
80007612:	0411                	add	s0,s0,4
80007614:	00b4fd63          	bgeu	s1,a1,8000762e <.LBB4_6>

80007618 <.LBB4_3>:
        struct usbd_interface *intf = g_usbd_core[busid].intf[i];
80007618:	400c                	lw	a1,0(s0)
            if (intf && intf->notify_handler) {
8000761a:	d9ed                	beqz	a1,8000760c <.LBB4_2>
8000761c:	45d4                	lw	a3,12(a1)
8000761e:	d6fd                	beqz	a3,8000760c <.LBB4_2>
                intf->notify_handler(busid, event, arg);
80007620:	4585                	li	a1,1
80007622:	854e                	mv	a0,s3
80007624:	4601                	li	a2,0
80007626:	9682                	jalr	a3
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
80007628:	000a4503          	lbu	a0,0(s4)
8000762c:	b7c5                	j	8000760c <.LBB4_2>

8000762e <.LBB4_6>:

    usbd_class_event_notify_handler(busid, USBD_EVENT_RESET, NULL);
    g_usbd_core[busid].event_handler(busid, USBD_EVENT_RESET);
8000762e:	3d092603          	lw	a2,976(s2)
80007632:	4585                	li	a1,1
80007634:	854e                	mv	a0,s3
80007636:	9602                	jalr	a2
80007638:	40f2                	lw	ra,28(sp)
8000763a:	4462                	lw	s0,24(sp)
8000763c:	44d2                	lw	s1,20(sp)
8000763e:	4942                	lw	s2,16(sp)
80007640:	49b2                	lw	s3,12(sp)
80007642:	4a22                	lw	s4,8(sp)
}
80007644:	6105                	add	sp,sp,32
80007646:	8082                	ret

Disassembly of section .text.usbd_msosv2_desc_register:

80007648 <usbd_msosv2_desc_register>:
    g_usbd_core[busid].msosv1_desc = desc;
}

/* Register MS OS Descriptors version 2 */
void usbd_msosv2_desc_register(uint8_t busid, struct usb_msosv2_descriptor *desc)
{
80007648:	3d400613          	li	a2,980
    g_usbd_core[busid].msosv2_desc = desc;
8000764c:	02c50533          	mul	a0,a0,a2
80007650:	00089637          	lui	a2,0x89
80007654:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
80007658:	9532                	add	a0,a0,a2
8000765a:	d10c                	sw	a1,32(a0)
}
8000765c:	8082                	ret

Disassembly of section .text.usbd_bos_desc_register:

8000765e <usbd_bos_desc_register>:

void usbd_bos_desc_register(uint8_t busid, struct usb_bos_descriptor *desc)
{
8000765e:	3d400613          	li	a2,980
    g_usbd_core[busid].bos_desc = desc;
80007662:	02c50533          	mul	a0,a0,a2
80007666:	00089637          	lui	a2,0x89
8000766a:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
8000766e:	9532                	add	a0,a0,a2
80007670:	d14c                	sw	a1,36(a0)
}
80007672:	8082                	ret

Disassembly of section .text.usb_osal_thread_create:

80007674 <usb_osal_thread_create>:
#include "semphr.h"
#include "timers.h"
#include "event_groups.h"
#include "DAP_config.h"
usb_osal_thread_t usb_osal_thread_create(const char *name, uint32_t stack_size, uint32_t prio, usb_thread_entry_t entry, void *args)
{
80007674:	1141                	add	sp,sp,-16
80007676:	c606                	sw	ra,12(sp)
80007678:	883a                	mv	a6,a4
8000767a:	88b6                	mv	a7,a3
8000767c:	86aa                	mv	a3,a0
    TaskHandle_t htask = NULL;
8000767e:	c402                	sw	zero,8(sp)
80007680:	477d                	li	a4,31
    stack_size /= sizeof(StackType_t);
    xTaskCreate(entry, name, stack_size, args, configMAX_PRIORITIES - 1 - prio, &htask);
80007682:	8f11                	sub	a4,a4,a2
80007684:	05ba                	sll	a1,a1,0xe
80007686:	0105d613          	srl	a2,a1,0x10
8000768a:	003c                	add	a5,sp,8
8000768c:	8546                	mv	a0,a7
8000768e:	85b6                	mv	a1,a3
80007690:	86c2                	mv	a3,a6
80007692:	2df9                	jal	80007d70 <xTaskCreate>
    return (usb_osal_thread_t)htask;
80007694:	4522                	lw	a0,8(sp)
80007696:	40b2                	lw	ra,12(sp)
80007698:	0141                	add	sp,sp,16
8000769a:	8082                	ret

Disassembly of section .text.usb_osal_sem_take:

8000769c <usb_osal_sem_take>:
{
    vSemaphoreDelete((SemaphoreHandle_t)sem);
}

int usb_osal_sem_take(usb_osal_sem_t sem, uint32_t timeout)
{
8000769c:	567d                	li	a2,-1
    if (timeout == USB_OSAL_WAITING_FOREVER) {
8000769e:	00c58d63          	beq	a1,a2,800076b8 <.LBB4_2>
800076a2:	3e800613          	li	a2,1000
        return (xSemaphoreTake((SemaphoreHandle_t)sem, portMAX_DELAY) == pdPASS) ? 0 : -USB_ERR_TIMEOUT;
    } else {
        return (xSemaphoreTake((SemaphoreHandle_t)sem, pdMS_TO_TICKS(timeout)) == pdPASS) ? 0 : -USB_ERR_TIMEOUT;
800076a6:	02c585b3          	mul	a1,a1,a2
800076aa:	10625637          	lui	a2,0x10625
800076ae:	dd360613          	add	a2,a2,-557 # 10624dd3 <_flash_size+0x10524dd3>
800076b2:	02c5b633          	mulhu	a2,a1,a2
800076b6:	8219                	srl	a2,a2,0x6

800076b8 <.LBB4_2>:
800076b8:	1141                	add	sp,sp,-16
800076ba:	c606                	sw	ra,12(sp)
800076bc:	85b2                	mv	a1,a2
800076be:	2c31                	jal	800078da <xQueueSemaphoreTake>
800076c0:	157d                	add	a0,a0,-1
800076c2:	00153513          	seqz	a0,a0
800076c6:	157d                	add	a0,a0,-1
800076c8:	9949                	and	a0,a0,-14
800076ca:	40b2                	lw	ra,12(sp)
    }
}
800076cc:	0141                	add	sp,sp,16
800076ce:	8082                	ret

Disassembly of section .text.usb_osal_mq_send:

800076d0 <usb_osal_mq_send>:
{
    vQueueDelete((QueueHandle_t)mq);
}

int usb_osal_mq_send(usb_osal_mq_t mq, uintptr_t addr)
{
800076d0:	1141                	add	sp,sp,-16
800076d2:	c606                	sw	ra,12(sp)
800076d4:	c422                	sw	s0,8(sp)
800076d6:	c22e                	sw	a1,4(sp)
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
800076d8:	c002                	sw	zero,0(sp)
    int ret;

    ret = xQueueSendFromISR((usb_osal_mq_t)mq, &addr, &xHigherPriorityTaskWoken);
800076da:	004c                	add	a1,sp,4
800076dc:	860a                	mv	a2,sp
800076de:	4681                	li	a3,0
800076e0:	6b3040ef          	jal	8000c592 <xQueueGenericSendFromISR>
800076e4:	4585                	li	a1,1
800076e6:	842a                	mv	s0,a0
    if (ret == pdPASS) {
800076e8:	00b51663          	bne	a0,a1,800076f4 <.LBB13_3>
800076ec:	4502                	lw	a0,0(sp)
800076ee:	c119                	beqz	a0,800076f4 <.LBB13_3>
        portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
800076f0:	1cf000ef          	jal	800080be <vTaskSwitchContext>

800076f4 <.LBB13_3>:
    if (ret == pdPASS) {
800076f4:	147d                	add	s0,s0,-1
800076f6:	00143513          	seqz	a0,s0
    }

    return (ret == pdPASS) ? 0 : -USB_ERR_TIMEOUT;
800076fa:	157d                	add	a0,a0,-1
800076fc:	9949                	and	a0,a0,-14
800076fe:	40b2                	lw	ra,12(sp)
80007700:	4422                	lw	s0,8(sp)
80007702:	0141                	add	sp,sp,16
80007704:	8082                	ret

Disassembly of section .text.usb_osal_mq_recv:

80007706 <usb_osal_mq_recv>:
}

int usb_osal_mq_recv(usb_osal_mq_t mq, uintptr_t *addr, uint32_t timeout)
{
80007706:	56fd                	li	a3,-1
    if (timeout == USB_OSAL_WAITING_FOREVER) {
80007708:	00d60d63          	beq	a2,a3,80007722 <.LBB14_2>
8000770c:	3e800693          	li	a3,1000
        return (xQueueReceive((usb_osal_mq_t)mq, addr, portMAX_DELAY) == pdPASS) ? 0 : -USB_ERR_TIMEOUT;
    } else {
        return (xQueueReceive((usb_osal_mq_t)mq, addr, pdMS_TO_TICKS(timeout)) == pdPASS) ? 0 : -USB_ERR_TIMEOUT;
80007710:	02d60633          	mul	a2,a2,a3
80007714:	106256b7          	lui	a3,0x10625
80007718:	dd368693          	add	a3,a3,-557 # 10624dd3 <_flash_size+0x10524dd3>
8000771c:	02d636b3          	mulhu	a3,a2,a3
80007720:	8299                	srl	a3,a3,0x6

80007722 <.LBB14_2>:
80007722:	1141                	add	sp,sp,-16
80007724:	c606                	sw	ra,12(sp)
80007726:	8636                	mv	a2,a3
80007728:	2965                	jal	80007be0 <xQueueReceive>
8000772a:	157d                	add	a0,a0,-1
8000772c:	00153513          	seqz	a0,a0
80007730:	157d                	add	a0,a0,-1
80007732:	9949                	and	a0,a0,-14
80007734:	40b2                	lw	ra,12(sp)
    }
}
80007736:	0141                	add	sp,sp,16
80007738:	8082                	ret

Disassembly of section .text.usb_dc_low_level_init:

8000773a <usb_dc_low_level_init>:
}

__WEAK void usb_dc_low_level_init(uint8_t busid)
{
    (void)busid;
}
8000773a:	8082                	ret

Disassembly of section .text.usbd_set_address:

8000773c <usbd_set_address>:

    return 0;
}

int usbd_set_address(uint8_t busid, const uint8_t addr)
{
8000773c:	28400613          	li	a2,644
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
80007740:	02c50533          	mul	a0,a0,a2
80007744:	c0018613          	add	a2,gp,-1024 # 80f70 <g_hpm_udc>
80007748:	9532                	add	a0,a0,a2
8000774a:	4108                	lw	a0,0(a0)
    usb_dcd_set_address(handle->regs, addr);
8000774c:	4108                	lw	a0,0(a0)
    ptr->DEVICEADDR = USB_DEVICEADDR_USBADR_SET(dev_addr) | USB_DEVICEADDR_USBADRA_MASK;
8000774e:	05e6                	sll	a1,a1,0x19
80007750:	01000637          	lui	a2,0x1000
80007754:	8dd1                	or	a1,a1,a2
80007756:	14b52a23          	sw	a1,340(a0)
    return 0;
8000775a:	4501                	li	a0,0
8000775c:	8082                	ret

Disassembly of section .text.xPortStartScheduler:

8000775e <xPortStartScheduler>:

#endif /* ( configMTIME_BASE_ADDRESS != 0 ) && ( configMTIME_BASE_ADDRESS != 0 ) */
/*-----------------------------------------------------------*/

BaseType_t xPortStartScheduler( void )
{
8000775e:	1141                	add	sp,sp,-16
80007760:	c606                	sw	ra,12(sp)
extern void xPortStartFirstTask( void );

	#if( configASSERT_DEFINED == 1 )
	{
		volatile uint32_t mtvec = 0;
80007762:	c402                	sw	zero,8(sp)

		/* Check the least significant two bits of mtvec are 00 - indicating
		single vector mode. */
		__asm volatile( "csrr %0, mtvec" : "=r"( mtvec ) );
80007764:	30502573          	csrr	a0,mtvec
80007768:	c42a                	sw	a0,8(sp)
		configASSERT( ( mtvec & 0x03UL ) == 0 );
8000776a:	4522                	lw	a0,8(sp)
8000776c:	890d                	and	a0,a0,3
8000776e:	c509                	beqz	a0,80007778 <.LBB1_3>
80007770:	30047073          	csrc	mstatus,8
80007774:	9002                	ebreak

80007776 <.LBB1_2>:
80007776:	a001                	j	80007776 <.LBB1_2>

80007778 <.LBB1_3>:

		/* Check alignment of the interrupt stack - which is the same as the
		stack that was being used by main() prior to the scheduler being
		started. */
		configASSERT( ( xISRStackTop & portBYTE_ALIGNMENT_MASK ) == 0 );
80007778:	000a0537          	lui	a0,0xa0
8000777c:	00050513          	mv	a0,a0
80007780:	8911                	and	a0,a0,4
80007782:	ed19                	bnez	a0,800077a0 <.LBB1_5>
	#endif /* configASSERT_DEFINED */

	/* If there is a CLINT then it is ok to use the default implementation
	in this file, otherwise vPortSetupTimerInterrupt() must be implemented to
	configure whichever clock is to be used to generate the tick interrupt. */
	vPortSetupTimerInterrupt();
80007784:	1d1040ef          	jal	8000c154 <vPortSetupTimerInterrupt>
80007788:	4545                	li	a0,17
8000778a:	051e                	sll	a0,a0,0x7
	#if( ( configMTIME_BASE_ADDRESS != 0 ) && ( configMTIMECMP_BASE_ADDRESS != 0 ) )
	{
		/* Enable mtime and external interrupts.  1<<7 for timer interrupt, 1<<11
		for external interrupt.  _RB_ What happens here when mtime is not present as
		with pulpino? */
		__asm volatile( "csrs mie, %0" :: "r"(0x880) );
8000778c:	30452073          	csrs	mie,a0
		/* Enable external interrupts. */
		__asm volatile( "csrs mie, %0" :: "r"(0x800) );
	}
	#endif /* ( configMTIME_BASE_ADDRESS != 0 ) && ( configMTIMECMP_BASE_ADDRESS != 0 ) */

	xPortStartFirstTask();
80007790:	7fff9097          	auipc	ra,0x7fff9
80007794:	c70080e7          	jalr	-912(ra) # 400 <xPortStartFirstTask>

	/* Should not get here as after calling xPortStartFirstTask() only tasks
	should be executing. */
	return pdFAIL;
80007798:	4501                	li	a0,0
8000779a:	40b2                	lw	ra,12(sp)
8000779c:	0141                	add	sp,sp,16
8000779e:	8082                	ret

800077a0 <.LBB1_5>:
		configASSERT( ( xISRStackTop & portBYTE_ALIGNMENT_MASK ) == 0 );
800077a0:	30047073          	csrc	mstatus,8
800077a4:	9002                	ebreak

800077a6 <.LBB1_6>:
800077a6:	a001                	j	800077a6 <.LBB1_6>

Disassembly of section .text.vListInitialiseItem:

800077a8 <vListInitialiseItem>:
/*-----------------------------------------------------------*/

void vListInitialiseItem( ListItem_t * const pxItem )
{
    /* Make sure the list item is not recorded as being on a list. */
    pxItem->pxContainer = NULL;
800077a8:	00052823          	sw	zero,16(a0) # a0010 <__DLM_segment_end__+0x10>

    /* Write known values into the list item if
     * configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES is set to 1. */
    listSET_FIRST_LIST_ITEM_INTEGRITY_CHECK_VALUE( pxItem );
    listSET_SECOND_LIST_ITEM_INTEGRITY_CHECK_VALUE( pxItem );
}
800077ac:	8082                	ret

Disassembly of section .text.vListInsertEnd:

800077ae <vListInsertEnd>:
/*-----------------------------------------------------------*/

void vListInsertEnd( List_t * const pxList,
                     ListItem_t * const pxNewListItem )
{
    ListItem_t * const pxIndex = pxList->pxIndex;
800077ae:	4150                	lw	a2,4(a0)

    /* Insert a new list item into pxList, but rather than sort the list,
     * makes the new list item the last item to be removed by a call to
     * listGET_OWNER_OF_NEXT_ENTRY(). */
    pxNewListItem->pxNext = pxIndex;
    pxNewListItem->pxPrevious = pxIndex->pxPrevious;
800077b0:	4614                	lw	a3,8(a2)
    pxNewListItem->pxNext = pxIndex;
800077b2:	c1d0                	sw	a2,4(a1)
    pxNewListItem->pxPrevious = pxIndex->pxPrevious;
800077b4:	c594                	sw	a3,8(a1)

    /* Only used during decision coverage testing. */
    mtCOVERAGE_TEST_DELAY();

    pxIndex->pxPrevious->pxNext = pxNewListItem;
800077b6:	c2cc                	sw	a1,4(a3)
    pxIndex->pxPrevious = pxNewListItem;
800077b8:	c60c                	sw	a1,8(a2)

    /* Remember which list the item is in. */
    pxNewListItem->pxContainer = pxList;
800077ba:	c988                	sw	a0,16(a1)

    ( pxList->uxNumberOfItems )++;
800077bc:	410c                	lw	a1,0(a0)
800077be:	0585                	add	a1,a1,1
800077c0:	c10c                	sw	a1,0(a0)
}
800077c2:	8082                	ret

Disassembly of section .text.vListInsert:

800077c4 <vListInsert>:

void vListInsert( List_t * const pxList,
                  ListItem_t * const pxNewListItem )
{
    ListItem_t * pxIterator;
    const TickType_t xValueOfInsertion = pxNewListItem->xItemValue;
800077c4:	4198                	lw	a4,0(a1)
800077c6:	567d                	li	a2,-1
     * new list item should be placed after it.  This ensures that TCBs which are
     * stored in ready lists (all of which have the same xItemValue value) get a
     * share of the CPU.  However, if the xItemValue is the same as the back marker
     * the iteration loop below will not end.  Therefore the value is checked
     * first, and the algorithm slightly modified if necessary. */
    if( xValueOfInsertion == portMAX_DELAY )
800077c8:	00c70a63          	beq	a4,a2,800077dc <.LBB3_3>
        *   5) If the FreeRTOS port supports interrupt nesting then ensure that
        *      the priority of the tick interrupt is at or below
        *      configMAX_SYSCALL_INTERRUPT_PRIORITY.
        **********************************************************************/

        for( pxIterator = ( ListItem_t * ) &( pxList->xListEnd ); pxIterator->pxNext->xItemValue <= xValueOfInsertion; pxIterator = pxIterator->pxNext ) /*lint !e826 !e740 !e9087 The mini list structure is used as the list end to save RAM.  This is checked and valid. *//*lint !e440 The iterator moves to a different value, not xValueOfInsertion. */
800077cc:	00850693          	add	a3,a0,8

800077d0 <.LBB3_2>:
800077d0:	8636                	mv	a2,a3
800077d2:	42d4                	lw	a3,4(a3)
800077d4:	429c                	lw	a5,0(a3)
800077d6:	fef77de3          	bgeu	a4,a5,800077d0 <.LBB3_2>
800077da:	a019                	j	800077e0 <.LBB3_4>

800077dc <.LBB3_3>:
        pxIterator = pxList->xListEnd.pxPrevious;
800077dc:	4910                	lw	a2,16(a0)
            /* There is nothing to do here, just iterating to the wanted
             * insertion position. */
        }
    }

    pxNewListItem->pxNext = pxIterator->pxNext;
800077de:	4254                	lw	a3,4(a2)

800077e0 <.LBB3_4>:
800077e0:	c1d4                	sw	a3,4(a1)
    pxNewListItem->pxNext->pxPrevious = pxNewListItem;
800077e2:	c68c                	sw	a1,8(a3)
    pxNewListItem->pxPrevious = pxIterator;
800077e4:	c590                	sw	a2,8(a1)
    pxIterator->pxNext = pxNewListItem;
800077e6:	c24c                	sw	a1,4(a2)

    /* Remember which list the item is in.  This allows fast removal of the
     * item later. */
    pxNewListItem->pxContainer = pxList;
800077e8:	c988                	sw	a0,16(a1)

    ( pxList->uxNumberOfItems )++;
800077ea:	410c                	lw	a1,0(a0)
800077ec:	0585                	add	a1,a1,1
800077ee:	c10c                	sw	a1,0(a0)
}
800077f0:	8082                	ret

Disassembly of section .text.xQueueGenericReset:

800077f2 <xQueueGenericReset>:
                               BaseType_t xNewQueue )
{
    BaseType_t xReturn = pdPASS;
    Queue_t * const pxQueue = xQueue;

    configASSERT( pxQueue );
800077f2:	c919                	beqz	a0,80007808 <.LBB0_5>

    if( ( pxQueue != NULL ) &&
        ( pxQueue->uxLength >= 1U ) &&
800077f4:	5d50                	lw	a2,60(a0)
800077f6:	c609                	beqz	a2,80007800 <.LBB0_3>
        /* Check for multiplication overflow. */
        ( ( SIZE_MAX / pxQueue->uxLength ) >= pxQueue->uxItemSize ) )
800077f8:	4134                	lw	a3,64(a0)
800077fa:	02d63633          	mulhu	a2,a2,a3
    if( ( pxQueue != NULL ) &&
800077fe:	ca09                	beqz	a2,80007810 <.LBB0_7>

80007800 <.LBB0_3>:
    else
    {
        xReturn = pdFAIL;
    }

    configASSERT( xReturn != pdFAIL );
80007800:	30047073          	csrc	mstatus,8
80007804:	9002                	ebreak

80007806 <.LBB0_4>:
80007806:	a001                	j	80007806 <.LBB0_4>

80007808 <.LBB0_5>:
    configASSERT( pxQueue );
80007808:	30047073          	csrc	mstatus,8
8000780c:	9002                	ebreak

8000780e <.LBB0_6>:
8000780e:	a001                	j	8000780e <.LBB0_6>

80007810 <.LBB0_7>:
80007810:	1141                	add	sp,sp,-16
80007812:	c606                	sw	ra,12(sp)
80007814:	c422                	sw	s0,8(sp)
80007816:	c226                	sw	s1,4(sp)
80007818:	842a                	mv	s0,a0
8000781a:	84ae                	mv	s1,a1
        taskENTER_CRITICAL();
8000781c:	2fad                	jal	80007f96 <vTaskEnterCritical>
        pxQueue->u.xQueue.pcTail = pxQueue->pcHead + ( pxQueue->uxLength * pxQueue->uxItemSize ); /*lint !e9016 Pointer arithmetic allowed on char types, especially when it assists conveying intent. */
8000781e:	5c48                	lw	a0,60(s0)
80007820:	4030                	lw	a2,64(s0)
80007822:	4014                	lw	a3,0(s0)
80007824:	02a60733          	mul	a4,a2,a0
80007828:	9736                	add	a4,a4,a3
8000782a:	c418                	sw	a4,8(s0)
        pxQueue->uxMessagesWaiting = ( UBaseType_t ) 0U;
8000782c:	02042c23          	sw	zero,56(s0)
        pxQueue->pcWriteTo = pxQueue->pcHead;
80007830:	c054                	sw	a3,4(s0)
        pxQueue->u.xQueue.pcReadFrom = pxQueue->pcHead + ( ( pxQueue->uxLength - 1U ) * pxQueue->uxItemSize ); /*lint !e9016 Pointer arithmetic allowed on char types, especially when it assists conveying intent. */
80007832:	157d                	add	a0,a0,-1
80007834:	02c50533          	mul	a0,a0,a2
80007838:	9536                	add	a0,a0,a3
8000783a:	c448                	sw	a0,12(s0)
8000783c:	0ff00513          	li	a0,255
        pxQueue->cRxLock = queueUNLOCKED;
80007840:	04a40223          	sb	a0,68(s0)
        pxQueue->cTxLock = queueUNLOCKED;
80007844:	04a402a3          	sb	a0,69(s0)
80007848:	01040513          	add	a0,s0,16
        if( xNewQueue == pdFALSE )
8000784c:	cc99                	beqz	s1,8000786a <.LBB0_10>
            vListInitialise( &( pxQueue->xTasksWaitingToSend ) );
8000784e:	373040ef          	jal	8000c3c0 <vListInitialise>
            vListInitialise( &( pxQueue->xTasksWaitingToReceive ) );
80007852:	02440513          	add	a0,s0,36
80007856:	36b040ef          	jal	8000c3c0 <vListInitialise>

8000785a <.LBB0_9>:
        taskEXIT_CRITICAL();
8000785a:	6eb040ef          	jal	8000c744 <vTaskExitCritical>

    /* A value is returned for calling semantic consistency with previous
     * versions. */
    return xReturn;
8000785e:	4505                	li	a0,1
80007860:	40b2                	lw	ra,12(sp)
80007862:	4422                	lw	s0,8(sp)
80007864:	4492                	lw	s1,4(sp)
80007866:	0141                	add	sp,sp,16
80007868:	8082                	ret

8000786a <.LBB0_10>:
            if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToSend ) ) == pdFALSE )
8000786a:	410c                	lw	a1,0(a0)
8000786c:	d5fd                	beqz	a1,8000785a <.LBB0_9>
                if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToSend ) ) != pdFALSE )
8000786e:	21e050ef          	jal	8000ca8c <xTaskRemoveFromEventList>
80007872:	d565                	beqz	a0,8000785a <.LBB0_9>
                    queueYIELD_IF_USING_PREEMPTION();
80007874:	00000073          	ecall
80007878:	b7cd                	j	8000785a <.LBB0_9>

Disassembly of section .text.xQueueGenericCreate:

8000787a <xQueueGenericCreate>:
    {
        Queue_t * pxNewQueue = NULL;
        size_t xQueueSizeInBytes;
        uint8_t * pucQueueStorage;

        if( ( uxQueueLength > ( UBaseType_t ) 0 ) &&
8000787a:	cd21                	beqz	a0,800078d2 <.LBB1_6>
            /* Check for multiplication overflow. */
            ( ( SIZE_MAX / uxQueueLength ) >= uxItemSize ) &&
8000787c:	02b536b3          	mulhu	a3,a0,a1
80007880:	eaa9                	bnez	a3,800078d2 <.LBB1_6>
            /* Check for addition overflow. */
            ( ( SIZE_MAX - sizeof( Queue_t ) ) >= ( uxQueueLength * uxItemSize ) ) )
80007882:	02a586b3          	mul	a3,a1,a0
80007886:	faf00713          	li	a4,-81
        if( ( uxQueueLength > ( UBaseType_t ) 0 ) &&
8000788a:	04d76463          	bltu	a4,a3,800078d2 <.LBB1_6>
8000788e:	1141                	add	sp,sp,-16
80007890:	c606                	sw	ra,12(sp)
80007892:	c422                	sw	s0,8(sp)
80007894:	c226                	sw	s1,4(sp)
80007896:	c04a                	sw	s2,0(sp)
80007898:	842a                	mv	s0,a0
8000789a:	84ae                	mv	s1,a1
8000789c:	8932                	mv	s2,a2
             * alignment requirements of the Queue_t structure - which in this case
             * is an int8_t *.  Therefore, whenever the stack alignment requirements
             * are greater than or equal to the pointer to char requirements the cast
             * is safe.  In other cases alignment requirements are not strict (one or
             * two bytes). */
            pxNewQueue = ( Queue_t * ) pvPortMalloc( sizeof( Queue_t ) + xQueueSizeInBytes ); /*lint !e9087 !e9079 see comment above. */
8000789e:	05068513          	add	a0,a3,80
800078a2:	0ff040ef          	jal	8000c1a0 <pvPortMalloc>

            if( pxNewQueue != NULL )
800078a6:	c105                	beqz	a0,800078c6 <.LBB1_5>
{
    /* Remove compiler warnings about unused parameters should
     * configUSE_TRACE_FACILITY not be set to 1. */
    ( void ) ucQueueType;

    if( uxItemSize == ( UBaseType_t ) 0 )
800078a8:	0014b593          	seqz	a1,s1
800078ac:	15fd                	add	a1,a1,-1
800078ae:	0505f593          	and	a1,a1,80
800078b2:	95aa                	add	a1,a1,a0
800078b4:	c10c                	sw	a1,0(a0)
        pxNewQueue->pcHead = ( int8_t * ) pucQueueStorage;
    }

    /* Initialise the queue members as described where the queue type is
     * defined. */
    pxNewQueue->uxLength = uxQueueLength;
800078b6:	dd40                	sw	s0,60(a0)
    pxNewQueue->uxItemSize = uxItemSize;
800078b8:	c124                	sw	s1,64(a0)
    ( void ) xQueueGenericReset( pxNewQueue, pdTRUE );
800078ba:	4585                	li	a1,1
800078bc:	842a                	mv	s0,a0
800078be:	3f15                	jal	800077f2 <xQueueGenericReset>
800078c0:	8522                	mv	a0,s0

    #if ( configUSE_TRACE_FACILITY == 1 )
        {
            pxNewQueue->ucQueueType = ucQueueType;
800078c2:	05240623          	sb	s2,76(s0)

800078c6 <.LBB1_5>:
800078c6:	40b2                	lw	ra,12(sp)
800078c8:	4422                	lw	s0,8(sp)
800078ca:	4492                	lw	s1,4(sp)
800078cc:	4902                	lw	s2,0(sp)
        return pxNewQueue;
800078ce:	0141                	add	sp,sp,16
800078d0:	8082                	ret

800078d2 <.LBB1_6>:
            configASSERT( pxNewQueue );
800078d2:	30047073          	csrc	mstatus,8
800078d6:	9002                	ebreak

800078d8 <.LBB1_7>:
800078d8:	a001                	j	800078d8 <.LBB1_7>

Disassembly of section .text.xQueueSemaphoreTake:

800078da <xQueueSemaphoreTake>:
}
/*-----------------------------------------------------------*/

BaseType_t xQueueSemaphoreTake( QueueHandle_t xQueue,
                                TickType_t xTicksToWait )
{
800078da:	7179                	add	sp,sp,-48
800078dc:	d606                	sw	ra,44(sp)
800078de:	d422                	sw	s0,40(sp)
800078e0:	d226                	sw	s1,36(sp)
800078e2:	d04a                	sw	s2,32(sp)
800078e4:	ce4e                	sw	s3,28(sp)
800078e6:	cc52                	sw	s4,24(sp)
800078e8:	ca56                	sw	s5,20(sp)
800078ea:	c82e                	sw	a1,16(sp)
    #if ( configUSE_MUTEXES == 1 )
        BaseType_t xInheritanceOccurred = pdFALSE;
    #endif

    /* Check the queue pointer is not NULL. */
    configASSERT( ( pxQueue ) );
800078ec:	c901                	beqz	a0,800078fc <.LBB8_4>
800078ee:	842a                	mv	s0,a0

    /* Check this really is a semaphore, in which case the item size will be
     * 0. */
    configASSERT( pxQueue->uxItemSize == 0 );
800078f0:	4128                	lw	a0,64(a0)
800078f2:	c909                	beqz	a0,80007904 <.LBB8_6>
800078f4:	30047073          	csrc	mstatus,8
800078f8:	9002                	ebreak

800078fa <.LBB8_3>:
800078fa:	a001                	j	800078fa <.LBB8_3>

800078fc <.LBB8_4>:
    configASSERT( ( pxQueue ) );
800078fc:	30047073          	csrc	mstatus,8
80007900:	9002                	ebreak

80007902 <.LBB8_5>:
80007902:	a001                	j	80007902 <.LBB8_5>

80007904 <.LBB8_6>:
80007904:	84ae                	mv	s1,a1

    /* Cannot block if the scheduler is suspended. */
    #if ( ( INCLUDE_xTaskGetSchedulerState == 1 ) || ( configUSE_TIMERS == 1 ) )
        {
            configASSERT( !( ( xTaskGetSchedulerState() == taskSCHEDULER_SUSPENDED ) && ( xTicksToWait != 0 ) ) );
80007906:	19b000ef          	jal	800082a0 <xTaskGetSchedulerState>
8000790a:	e511                	bnez	a0,80007916 <.LBB8_10>
8000790c:	c489                	beqz	s1,80007916 <.LBB8_10>
8000790e:	30047073          	csrc	mstatus,8
80007912:	9002                	ebreak

80007914 <.LBB8_9>:
80007914:	a001                	j	80007914 <.LBB8_9>

80007916 <.LBB8_10>:
    /*lint -save -e904 This function relaxes the coding standard somewhat to allow return
     * statements within the function itself.  This is done in the interest
     * of execution time efficiency. */
    for( ; ; )
    {
        taskENTER_CRITICAL();
80007916:	2541                	jal	80007f96 <vTaskEnterCritical>
        {
            /* Semaphores are queues with an item size of 0, and where the
             * number of messages in the queue is the semaphore's count value. */
            const UBaseType_t uxSemaphoreCount = pxQueue->uxMessagesWaiting;
80007918:	5c08                	lw	a0,56(s0)

            /* Is there data in the queue now?  To be running the calling task
             * must be the highest priority task wanting to access the queue. */
            if( uxSemaphoreCount > ( UBaseType_t ) 0 )
8000791a:	c50d                	beqz	a0,80007944 <.LBB8_16>

8000791c <.LBB8_11>:
            {
                traceQUEUE_RECEIVE( pxQueue );

                /* Semaphores are queues with a data size of zero and where the
                 * messages waiting is the semaphore's count.  Reduce the count. */
                pxQueue->uxMessagesWaiting = uxSemaphoreCount - ( UBaseType_t ) 1;
8000791c:	157d                	add	a0,a0,-1
8000791e:	dc08                	sw	a0,56(s0)

                #if ( configUSE_MUTEXES == 1 )
                    {
                        if( pxQueue->uxQueueType == queueQUEUE_IS_MUTEX )
80007920:	4008                	lw	a0,0(s0)
80007922:	e501                	bnez	a0,8000792a <.LBB8_13>
                        {
                            /* Record the information required to implement
                             * priority inheritance should it become necessary. */
                            pxQueue->u.xSemaphore.xMutexHolder = pvTaskIncrementMutexHeldCount();
80007924:	251000ef          	jal	80008374 <pvTaskIncrementMutexHeldCount>
80007928:	c408                	sw	a0,8(s0)

8000792a <.LBB8_13>:
                    }
                #endif /* configUSE_MUTEXES */

                /* Check to see if other tasks are blocked waiting to give the
                 * semaphore, and if so, unblock the highest priority such task. */
                if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToSend ) ) == pdFALSE )
8000792a:	4808                	lw	a0,16(s0)
8000792c:	4485                	li	s1,1
8000792e:	0e050a63          	beqz	a0,80007a22 <.LBB8_43>
80007932:	01040513          	add	a0,s0,16
                {
                    if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToSend ) ) != pdFALSE )
80007936:	156050ef          	jal	8000ca8c <xTaskRemoveFromEventList>
8000793a:	0e050463          	beqz	a0,80007a22 <.LBB8_43>
                    {
                        queueYIELD_IF_USING_PREEMPTION();
8000793e:	00000073          	ecall
80007942:	a0c5                	j	80007a22 <.LBB8_43>

80007944 <.LBB8_16>:
80007944:	4a81                	li	s5,0
80007946:	4901                	li	s2,0
80007948:	02440993          	add	s3,s0,36
8000794c:	0ff00a13          	li	s4,255
80007950:	a829                	j	8000796a <.LBB8_19>

80007952 <.LBB8_17>:
            }
        }
        else
        {
            /* Timed out. */
            prvUnlockQueue( pxQueue );
80007952:	8522                	mv	a0,s0
80007954:	2a95                	jal	80007ac8 <prvUnlockQueue>
            ( void ) xTaskResumeAll();
80007956:	623040ef          	jal	8000c778 <xTaskResumeAll>

static BaseType_t prvIsQueueEmpty( const Queue_t * pxQueue )
{
    BaseType_t xReturn;

    taskENTER_CRITICAL();
8000795a:	2d35                	jal	80007f96 <vTaskEnterCritical>
    {
        if( pxQueue->uxMessagesWaiting == ( UBaseType_t ) 0 )
8000795c:	5c04                	lw	s1,56(s0)
        else
        {
            xReturn = pdFALSE;
        }
    }
    taskEXIT_CRITICAL();
8000795e:	5e7040ef          	jal	8000c744 <vTaskExitCritical>
            if( prvIsQueueEmpty( pxQueue ) != pdFALSE )
80007962:	ccc9                	beqz	s1,800079fc <.LBB8_36>

80007964 <.LBB8_18>:
        taskENTER_CRITICAL();
80007964:	2d0d                	jal	80007f96 <vTaskEnterCritical>
            const UBaseType_t uxSemaphoreCount = pxQueue->uxMessagesWaiting;
80007966:	5c08                	lw	a0,56(s0)
            if( uxSemaphoreCount > ( UBaseType_t ) 0 )
80007968:	f955                	bnez	a0,8000791c <.LBB8_11>

8000796a <.LBB8_19>:
                if( xTicksToWait == ( TickType_t ) 0 )
8000796a:	4542                	lw	a0,16(sp)
8000796c:	c151                	beqz	a0,800079f0 <.LBB8_33>
                else if( xEntryTimeSet == pdFALSE )
8000796e:	000a9663          	bnez	s5,8000797a <.LBB8_22>
                    vTaskInternalSetTimeOutState( &xTimeOut );
80007972:	0028                	add	a0,sp,8
80007974:	079000ef          	jal	800081ec <vTaskInternalSetTimeOutState>
80007978:	4a85                	li	s5,1

8000797a <.LBB8_22>:
        taskEXIT_CRITICAL();
8000797a:	5cb040ef          	jal	8000c744 <vTaskExitCritical>
        vTaskSuspendAll();
8000797e:	5ef040ef          	jal	8000c76c <vTaskSuspendAll>
        prvLockQueue( pxQueue );
80007982:	2d11                	jal	80007f96 <vTaskEnterCritical>
80007984:	04444503          	lbu	a0,68(s0)
80007988:	03450763          	beq	a0,s4,800079b6 <.LBB8_27>
8000798c:	04544503          	lbu	a0,69(s0)
80007990:	03450963          	beq	a0,s4,800079c2 <.LBB8_28>

80007994 <.LBB8_24>:
80007994:	5b1040ef          	jal	8000c744 <vTaskExitCritical>
        if( xTaskCheckForTimeOut( &xTimeOut, &xTicksToWait ) == pdFALSE )
80007998:	0028                	add	a0,sp,8
8000799a:	080c                	add	a1,sp,16
8000799c:	05f000ef          	jal	800081fa <xTaskCheckForTimeOut>
800079a0:	f94d                	bnez	a0,80007952 <.LBB8_17>
    taskENTER_CRITICAL();
800079a2:	2bd5                	jal	80007f96 <vTaskEnterCritical>
        if( pxQueue->uxMessagesWaiting == ( UBaseType_t ) 0 )
800079a4:	5c04                	lw	s1,56(s0)
    taskEXIT_CRITICAL();
800079a6:	59f040ef          	jal	8000c744 <vTaskExitCritical>
            if( prvIsQueueEmpty( pxQueue ) != pdFALSE )
800079aa:	cc99                	beqz	s1,800079c8 <.LBB8_29>
                prvUnlockQueue( pxQueue );
800079ac:	8522                	mv	a0,s0
800079ae:	2a29                	jal	80007ac8 <prvUnlockQueue>
                ( void ) xTaskResumeAll();
800079b0:	5c9040ef          	jal	8000c778 <xTaskResumeAll>
800079b4:	bf45                	j	80007964 <.LBB8_18>

800079b6 <.LBB8_27>:
        prvLockQueue( pxQueue );
800079b6:	04040223          	sb	zero,68(s0)
800079ba:	04544503          	lbu	a0,69(s0)
800079be:	fd451be3          	bne	a0,s4,80007994 <.LBB8_24>

800079c2 <.LBB8_28>:
800079c2:	040402a3          	sb	zero,69(s0)
800079c6:	b7f9                	j	80007994 <.LBB8_24>

800079c8 <.LBB8_29>:
                        if( pxQueue->uxQueueType == queueQUEUE_IS_MUTEX )
800079c8:	4008                	lw	a0,0(s0)
800079ca:	e901                	bnez	a0,800079da <.LBB8_31>
                            taskENTER_CRITICAL();
800079cc:	23e9                	jal	80007f96 <vTaskEnterCritical>
                                xInheritanceOccurred = xTaskPriorityInherit( pxQueue->u.xSemaphore.xMutexHolder );
800079ce:	4408                	lw	a0,8(s0)
800079d0:	0e7000ef          	jal	800082b6 <xTaskPriorityInherit>
800079d4:	892a                	mv	s2,a0
                            taskEXIT_CRITICAL();
800079d6:	56f040ef          	jal	8000c744 <vTaskExitCritical>

800079da <.LBB8_31>:
                vTaskPlaceOnEventList( &( pxQueue->xTasksWaitingToReceive ), xTicksToWait );
800079da:	45c2                	lw	a1,16(sp)
800079dc:	854e                	mv	a0,s3
800079de:	274d                	jal	80008180 <vTaskPlaceOnEventList>
                prvUnlockQueue( pxQueue );
800079e0:	8522                	mv	a0,s0
800079e2:	20dd                	jal	80007ac8 <prvUnlockQueue>
                if( xTaskResumeAll() == pdFALSE )
800079e4:	595040ef          	jal	8000c778 <xTaskResumeAll>
800079e8:	fd35                	bnez	a0,80007964 <.LBB8_18>
                    portYIELD_WITHIN_API();
800079ea:	00000073          	ecall
800079ee:	bf9d                	j	80007964 <.LBB8_18>

800079f0 <.LBB8_33>:
800079f0:	02090863          	beqz	s2,80007a20 <.LBB8_42>
                            configASSERT( xInheritanceOccurred == pdFALSE );
800079f4:	30047073          	csrc	mstatus,8
800079f8:	9002                	ebreak

800079fa <.LBB8_35>:
800079fa:	a001                	j	800079fa <.LBB8_35>

800079fc <.LBB8_36>:
                        if( xInheritanceOccurred != pdFALSE )
800079fc:	00090c63          	beqz	s2,80007a14 <.LBB8_39>
                            taskENTER_CRITICAL();
80007a00:	2b59                	jal	80007f96 <vTaskEnterCritical>
        if( listCURRENT_LIST_LENGTH( &( pxQueue->xTasksWaitingToReceive ) ) > 0U )
80007a02:	0009a503          	lw	a0,0(s3)
80007a06:	c909                	beqz	a0,80007a18 <.LBB8_40>
            uxHighestPriorityOfWaitingTasks = ( UBaseType_t ) configMAX_PRIORITIES - ( UBaseType_t ) listGET_ITEM_VALUE_OF_HEAD_ENTRY( &( pxQueue->xTasksWaitingToReceive ) );
80007a08:	5808                	lw	a0,48(s0)
80007a0a:	4108                	lw	a0,0(a0)
80007a0c:	02000593          	li	a1,32
80007a10:	8d89                	sub	a1,a1,a0
80007a12:	a021                	j	80007a1a <.LBB8_41>

80007a14 <.LBB8_39>:
80007a14:	4481                	li	s1,0
80007a16:	a801                	j	80007a26 <.LBB8_44>

80007a18 <.LBB8_40>:
80007a18:	4581                	li	a1,0

80007a1a <.LBB8_41>:
                                vTaskPriorityDisinheritAfterTimeout( pxQueue->u.xSemaphore.xMutexHolder, uxHighestWaitingPriority );
80007a1a:	4408                	lw	a0,8(s0)
80007a1c:	1d6050ef          	jal	8000cbf2 <vTaskPriorityDisinheritAfterTimeout>

80007a20 <.LBB8_42>:
80007a20:	4481                	li	s1,0

80007a22 <.LBB8_43>:
80007a22:	523040ef          	jal	8000c744 <vTaskExitCritical>

80007a26 <.LBB8_44>:
}
80007a26:	8526                	mv	a0,s1
80007a28:	50b2                	lw	ra,44(sp)
80007a2a:	5422                	lw	s0,40(sp)
80007a2c:	5492                	lw	s1,36(sp)
80007a2e:	5902                	lw	s2,32(sp)
80007a30:	49f2                	lw	s3,28(sp)
80007a32:	4a62                	lw	s4,24(sp)
80007a34:	4ad2                	lw	s5,20(sp)
80007a36:	6145                	add	sp,sp,48
80007a38:	8082                	ret

Disassembly of section .text.prvCopyDataToQueue:

80007a3a <prvCopyDataToQueue>:
{
80007a3a:	1141                	add	sp,sp,-16
80007a3c:	c606                	sw	ra,12(sp)
80007a3e:	c422                	sw	s0,8(sp)
80007a40:	c226                	sw	s1,4(sp)
80007a42:	c04a                	sw	s2,0(sp)
80007a44:	842a                	mv	s0,a0
    uxMessagesWaiting = pxQueue->uxMessagesWaiting;
80007a46:	03852903          	lw	s2,56(a0)
    if( pxQueue->uxItemSize == ( UBaseType_t ) 0 )
80007a4a:	4134                	lw	a3,64(a0)
80007a4c:	ce8d                	beqz	a3,80007a86 <.LBB10_5>
80007a4e:	84b2                	mv	s1,a2
    else if( xPosition == queueSEND_TO_BACK )
80007a50:	c239                	beqz	a2,80007a96 <.LBB10_7>
        ( void ) memcpy( ( void * ) pxQueue->u.xQueue.pcReadFrom, pvItemToQueue, ( size_t ) pxQueue->uxItemSize ); /*lint !e961 !e9087 !e418 MISRA exception as the casts are only redundant for some ports.  Cast to void required by function signature and safe as no alignment requirement and copy length specified in bytes.  Assert checks null pointer only used when length is 0. */
80007a52:	4448                	lw	a0,12(s0)
80007a54:	8636                	mv	a2,a3
80007a56:	64d010ef          	jal	800098a2 <memcpy>
        pxQueue->u.xQueue.pcReadFrom -= pxQueue->uxItemSize;
80007a5a:	4028                	lw	a0,64(s0)
80007a5c:	444c                	lw	a1,12(s0)
        if( pxQueue->u.xQueue.pcReadFrom < pxQueue->pcHead ) /*lint !e946 MISRA exception justified as comparison of pointers is the cleanest solution. */
80007a5e:	4010                	lw	a2,0(s0)
        pxQueue->u.xQueue.pcReadFrom -= pxQueue->uxItemSize;
80007a60:	8d89                	sub	a1,a1,a0
80007a62:	c44c                	sw	a1,12(s0)
        if( pxQueue->u.xQueue.pcReadFrom < pxQueue->pcHead ) /*lint !e946 MISRA exception justified as comparison of pointers is the cleanest solution. */
80007a64:	00c5f763          	bgeu	a1,a2,80007a72 <.LBB10_4>
            pxQueue->u.xQueue.pcReadFrom = ( pxQueue->u.xQueue.pcTail - pxQueue->uxItemSize );
80007a68:	440c                	lw	a1,8(s0)
80007a6a:	40a00533          	neg	a0,a0
80007a6e:	952e                	add	a0,a0,a1
80007a70:	c448                	sw	a0,12(s0)

80007a72 <.LBB10_4>:
80007a72:	4501                	li	a0,0
        if( xPosition == queueOVERWRITE )
80007a74:	14f9                	add	s1,s1,-2
80007a76:	0014b593          	seqz	a1,s1
80007a7a:	01203633          	snez	a2,s2
80007a7e:	8df1                	and	a1,a1,a2
80007a80:	40b90933          	sub	s2,s2,a1
80007a84:	a80d                	j	80007ab6 <.LBB10_10>

80007a86 <.LBB10_5>:
                if( pxQueue->uxQueueType == queueQUEUE_IS_MUTEX )
80007a86:	4008                	lw	a0,0(s0)
80007a88:	e115                	bnez	a0,80007aac <.LBB10_8>
                    xReturn = xTaskPriorityDisinherit( pxQueue->u.xSemaphore.xMutexHolder );
80007a8a:	4408                	lw	a0,8(s0)
80007a8c:	0c0050ef          	jal	8000cb4c <xTaskPriorityDisinherit>
                    pxQueue->u.xSemaphore.xMutexHolder = NULL;
80007a90:	00042423          	sw	zero,8(s0)
80007a94:	a00d                	j	80007ab6 <.LBB10_10>

80007a96 <.LBB10_7>:
        ( void ) memcpy( ( void * ) pxQueue->pcWriteTo, pvItemToQueue, ( size_t ) pxQueue->uxItemSize ); /*lint !e961 !e418 !e9087 MISRA exception as the casts are only redundant for some ports, plus previous logic ensures a null pointer can only be passed to memcpy() if the copy size is 0.  Cast to void required by function signature and safe as no alignment requirement and copy length specified in bytes. */
80007a96:	4048                	lw	a0,4(s0)
80007a98:	8636                	mv	a2,a3
80007a9a:	609010ef          	jal	800098a2 <memcpy>
        pxQueue->pcWriteTo += pxQueue->uxItemSize;                                                       /*lint !e9016 Pointer arithmetic on char types ok, especially in this use case where it is the clearest way of conveying intent. */
80007a9e:	4028                	lw	a0,64(s0)
80007aa0:	404c                	lw	a1,4(s0)
        if( pxQueue->pcWriteTo >= pxQueue->u.xQueue.pcTail )                                             /*lint !e946 MISRA exception justified as comparison of pointers is the cleanest solution. */
80007aa2:	4410                	lw	a2,8(s0)
        pxQueue->pcWriteTo += pxQueue->uxItemSize;                                                       /*lint !e9016 Pointer arithmetic on char types ok, especially in this use case where it is the clearest way of conveying intent. */
80007aa4:	952e                	add	a0,a0,a1
80007aa6:	c048                	sw	a0,4(s0)
        if( pxQueue->pcWriteTo >= pxQueue->u.xQueue.pcTail )                                             /*lint !e946 MISRA exception justified as comparison of pointers is the cleanest solution. */
80007aa8:	00c57463          	bgeu	a0,a2,80007ab0 <.LBB10_9>

80007aac <.LBB10_8>:
80007aac:	4501                	li	a0,0
80007aae:	a021                	j	80007ab6 <.LBB10_10>

80007ab0 <.LBB10_9>:
            pxQueue->pcWriteTo = pxQueue->pcHead;
80007ab0:	400c                	lw	a1,0(s0)
80007ab2:	4501                	li	a0,0
80007ab4:	c04c                	sw	a1,4(s0)

80007ab6 <.LBB10_10>:
    pxQueue->uxMessagesWaiting = uxMessagesWaiting + ( UBaseType_t ) 1;
80007ab6:	0905                	add	s2,s2,1
80007ab8:	03242c23          	sw	s2,56(s0)
80007abc:	40b2                	lw	ra,12(sp)
80007abe:	4422                	lw	s0,8(sp)
80007ac0:	4492                	lw	s1,4(sp)
80007ac2:	4902                	lw	s2,0(sp)
    return xReturn;
80007ac4:	0141                	add	sp,sp,16
80007ac6:	8082                	ret

Disassembly of section .text.prvUnlockQueue:

80007ac8 <prvUnlockQueue>:
{
80007ac8:	1101                	add	sp,sp,-32
80007aca:	ce06                	sw	ra,28(sp)
80007acc:	cc22                	sw	s0,24(sp)
80007ace:	ca26                	sw	s1,20(sp)
80007ad0:	c84a                	sw	s2,16(sp)
80007ad2:	c64e                	sw	s3,12(sp)
80007ad4:	c452                	sw	s4,8(sp)
80007ad6:	89aa                	mv	s3,a0
    taskENTER_CRITICAL();
80007ad8:	297d                	jal	80007f96 <vTaskEnterCritical>
        int8_t cTxLock = pxQueue->cTxLock;
80007ada:	04598403          	lb	s0,69(s3)
        while( cTxLock > queueLOCKED_UNMODIFIED )
80007ade:	02805563          	blez	s0,80007b08 <.LBB11_6>
80007ae2:	02498493          	add	s1,s3,36
80007ae6:	4905                	li	s2,1
80007ae8:	a039                	j	80007af6 <.LBB11_3>

80007aea <.LBB11_2>:
            --cTxLock;
80007aea:	01841513          	sll	a0,s0,0x18
80007aee:	147d                	add	s0,s0,-1
80007af0:	8561                	sra	a0,a0,0x18
        while( cTxLock > queueLOCKED_UNMODIFIED )
80007af2:	00a95b63          	bge	s2,a0,80007b08 <.LBB11_6>

80007af6 <.LBB11_3>:
                    if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToReceive ) ) == pdFALSE )
80007af6:	4088                	lw	a0,0(s1)
80007af8:	c901                	beqz	a0,80007b08 <.LBB11_6>
                        if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToReceive ) ) != pdFALSE )
80007afa:	8526                	mv	a0,s1
80007afc:	791040ef          	jal	8000ca8c <xTaskRemoveFromEventList>
80007b00:	d56d                	beqz	a0,80007aea <.LBB11_2>
                            vTaskMissedYield();
80007b02:	042050ef          	jal	8000cb44 <vTaskMissedYield>
80007b06:	b7d5                	j	80007aea <.LBB11_2>

80007b08 <.LBB11_6>:
80007b08:	0ff00913          	li	s2,255
        pxQueue->cTxLock = queueUNLOCKED;
80007b0c:	052982a3          	sb	s2,69(s3)
    taskEXIT_CRITICAL();
80007b10:	435040ef          	jal	8000c744 <vTaskExitCritical>
    taskENTER_CRITICAL();
80007b14:	2149                	jal	80007f96 <vTaskEnterCritical>
        int8_t cRxLock = pxQueue->cRxLock;
80007b16:	04498403          	lb	s0,68(s3)
        while( cRxLock > queueLOCKED_UNMODIFIED )
80007b1a:	02805563          	blez	s0,80007b44 <.LBB11_12>
80007b1e:	01098493          	add	s1,s3,16
80007b22:	4a05                	li	s4,1
80007b24:	a039                	j	80007b32 <.LBB11_9>

80007b26 <.LBB11_8>:
                --cRxLock;
80007b26:	01841513          	sll	a0,s0,0x18
80007b2a:	147d                	add	s0,s0,-1
80007b2c:	8561                	sra	a0,a0,0x18
        while( cRxLock > queueLOCKED_UNMODIFIED )
80007b2e:	00aa5b63          	bge	s4,a0,80007b44 <.LBB11_12>

80007b32 <.LBB11_9>:
            if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToSend ) ) == pdFALSE )
80007b32:	4088                	lw	a0,0(s1)
80007b34:	c901                	beqz	a0,80007b44 <.LBB11_12>
                if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToSend ) ) != pdFALSE )
80007b36:	8526                	mv	a0,s1
80007b38:	755040ef          	jal	8000ca8c <xTaskRemoveFromEventList>
80007b3c:	d56d                	beqz	a0,80007b26 <.LBB11_8>
                    vTaskMissedYield();
80007b3e:	006050ef          	jal	8000cb44 <vTaskMissedYield>
80007b42:	b7d5                	j	80007b26 <.LBB11_8>

80007b44 <.LBB11_12>:
        pxQueue->cRxLock = queueUNLOCKED;
80007b44:	05298223          	sb	s2,68(s3)
80007b48:	40f2                	lw	ra,28(sp)
80007b4a:	4462                	lw	s0,24(sp)
80007b4c:	44d2                	lw	s1,20(sp)
80007b4e:	4942                	lw	s2,16(sp)
80007b50:	49b2                	lw	s3,12(sp)
80007b52:	4a22                	lw	s4,8(sp)
    taskEXIT_CRITICAL();
80007b54:	6105                	add	sp,sp,32
80007b56:	3ef0406f          	j	8000c744 <vTaskExitCritical>

Disassembly of section .text.xQueueGiveFromISR:

80007b5a <xQueueGiveFromISR>:
{
80007b5a:	1141                	add	sp,sp,-16
80007b5c:	c606                	sw	ra,12(sp)
80007b5e:	c422                	sw	s0,8(sp)
    configASSERT( pxQueue );
80007b60:	c519                	beqz	a0,80007b6e <.LBB13_4>
    configASSERT( pxQueue->uxItemSize == 0 );
80007b62:	4130                	lw	a2,64(a0)
80007b64:	ca09                	beqz	a2,80007b76 <.LBB13_6>
80007b66:	30047073          	csrc	mstatus,8
80007b6a:	9002                	ebreak

80007b6c <.LBB13_3>:
80007b6c:	a001                	j	80007b6c <.LBB13_3>

80007b6e <.LBB13_4>:
    configASSERT( pxQueue );
80007b6e:	30047073          	csrc	mstatus,8
80007b72:	9002                	ebreak

80007b74 <.LBB13_5>:
80007b74:	a001                	j	80007b74 <.LBB13_5>

80007b76 <.LBB13_6>:
    configASSERT( !( ( pxQueue->uxQueueType == queueQUEUE_IS_MUTEX ) && ( pxQueue->u.xSemaphore.xMutexHolder != NULL ) ) );
80007b76:	4110                	lw	a2,0(a0)
80007b78:	c231                	beqz	a2,80007bbc <.LBB13_15>

80007b7a <.LBB13_7>:
        const UBaseType_t uxMessagesWaiting = pxQueue->uxMessagesWaiting;
80007b7a:	5d14                	lw	a3,56(a0)
        if( uxMessagesWaiting < pxQueue->uxLength )
80007b7c:	5d50                	lw	a2,60(a0)
80007b7e:	02c6fd63          	bgeu	a3,a2,80007bb8 <.LBB13_14>
            const int8_t cTxLock = pxQueue->cTxLock;
80007b82:	04554603          	lbu	a2,69(a0)
            pxQueue->uxMessagesWaiting = uxMessagesWaiting + ( UBaseType_t ) 1;
80007b86:	0685                	add	a3,a3,1
80007b88:	07f00713          	li	a4,127
80007b8c:	dd14                	sw	a3,56(a0)
            if( cTxLock == queueUNLOCKED )
80007b8e:	02e60d63          	beq	a2,a4,80007bc8 <.LBB13_18>
80007b92:	0ff00693          	li	a3,255
80007b96:	02d61d63          	bne	a2,a3,80007bd0 <.LBB13_20>
                        if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToReceive ) ) == pdFALSE )
80007b9a:	5150                	lw	a2,36(a0)
80007b9c:	ce0d                	beqz	a2,80007bd6 <.LBB13_21>
80007b9e:	02450513          	add	a0,a0,36
80007ba2:	842e                	mv	s0,a1
                            if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToReceive ) ) != pdFALSE )
80007ba4:	6e9040ef          	jal	8000ca8c <xTaskRemoveFromEventList>
80007ba8:	c41d                	beqz	s0,80007bd6 <.LBB13_21>
80007baa:	85aa                	mv	a1,a0
80007bac:	4505                	li	a0,1
80007bae:	c58d                	beqz	a1,80007bd8 <.LBB13_22>
80007bb0:	8622                	mv	a2,s0
80007bb2:	4505                	li	a0,1
                                    *pxHigherPriorityTaskWoken = pdTRUE;
80007bb4:	c008                	sw	a0,0(s0)
80007bb6:	a00d                	j	80007bd8 <.LBB13_22>

80007bb8 <.LBB13_14>:
80007bb8:	4501                	li	a0,0
80007bba:	a839                	j	80007bd8 <.LBB13_22>

80007bbc <.LBB13_15>:
    configASSERT( !( ( pxQueue->uxQueueType == queueQUEUE_IS_MUTEX ) && ( pxQueue->u.xSemaphore.xMutexHolder != NULL ) ) );
80007bbc:	4510                	lw	a2,8(a0)
80007bbe:	de55                	beqz	a2,80007b7a <.LBB13_7>
80007bc0:	30047073          	csrc	mstatus,8
80007bc4:	9002                	ebreak

80007bc6 <.LBB13_17>:
80007bc6:	a001                	j	80007bc6 <.LBB13_17>

80007bc8 <.LBB13_18>:
                configASSERT( cTxLock != queueINT8_MAX );
80007bc8:	30047073          	csrc	mstatus,8
80007bcc:	9002                	ebreak

80007bce <.LBB13_19>:
80007bce:	a001                	j	80007bce <.LBB13_19>

80007bd0 <.LBB13_20>:
                pxQueue->cTxLock = ( int8_t ) ( cTxLock + 1 );
80007bd0:	0605                	add	a2,a2,1 # 1000001 <_flash_size+0xf00001>
80007bd2:	04c502a3          	sb	a2,69(a0)

80007bd6 <.LBB13_21>:
80007bd6:	4505                	li	a0,1

80007bd8 <.LBB13_22>:
80007bd8:	40b2                	lw	ra,12(sp)
80007bda:	4422                	lw	s0,8(sp)
    return xReturn;
80007bdc:	0141                	add	sp,sp,16
80007bde:	8082                	ret

Disassembly of section .text.xQueueReceive:

80007be0 <xQueueReceive>:
{
80007be0:	7179                	add	sp,sp,-48
80007be2:	d606                	sw	ra,44(sp)
80007be4:	d422                	sw	s0,40(sp)
80007be6:	d226                	sw	s1,36(sp)
80007be8:	d04a                	sw	s2,32(sp)
80007bea:	ce4e                	sw	s3,28(sp)
80007bec:	cc52                	sw	s4,24(sp)
80007bee:	ca56                	sw	s5,20(sp)
80007bf0:	c832                	sw	a2,16(sp)
    configASSERT( ( pxQueue ) );
80007bf2:	cd01                	beqz	a0,80007c0a <.LBB14_6>
80007bf4:	84b2                	mv	s1,a2
80007bf6:	842a                	mv	s0,a0
    configASSERT( !( ( ( pvBuffer ) == NULL ) && ( ( pxQueue )->uxItemSize != ( UBaseType_t ) 0U ) ) );
80007bf8:	cda1                	beqz	a1,80007c50 <.LBB14_16>

80007bfa <.LBB14_2>:
80007bfa:	892e                	mv	s2,a1
            configASSERT( !( ( xTaskGetSchedulerState() == taskSCHEDULER_SUSPENDED ) && ( xTicksToWait != 0 ) ) );
80007bfc:	2555                	jal	800082a0 <xTaskGetSchedulerState>
80007bfe:	e911                	bnez	a0,80007c12 <.LBB14_8>
80007c00:	c889                	beqz	s1,80007c12 <.LBB14_8>
80007c02:	30047073          	csrc	mstatus,8
80007c06:	9002                	ebreak

80007c08 <.LBB14_5>:
80007c08:	a001                	j	80007c08 <.LBB14_5>

80007c0a <.LBB14_6>:
    configASSERT( ( pxQueue ) );
80007c0a:	30047073          	csrc	mstatus,8
80007c0e:	9002                	ebreak

80007c10 <.LBB14_7>:
80007c10:	a001                	j	80007c10 <.LBB14_7>

80007c12 <.LBB14_8>:
        taskENTER_CRITICAL();
80007c12:	2651                	jal	80007f96 <vTaskEnterCritical>
            const UBaseType_t uxMessagesWaiting = pxQueue->uxMessagesWaiting;
80007c14:	5c04                	lw	s1,56(s0)
            if( uxMessagesWaiting > ( UBaseType_t ) 0 )
80007c16:	c0b9                	beqz	s1,80007c5c <.LBB14_19>

80007c18 <.LBB14_9>:
    if( pxQueue->uxItemSize != ( UBaseType_t ) 0 )
80007c18:	4030                	lw	a2,64(s0)
80007c1a:	ce01                	beqz	a2,80007c32 <.LBB14_13>
80007c1c:	854a                	mv	a0,s2
        pxQueue->u.xQueue.pcReadFrom += pxQueue->uxItemSize;           /*lint !e9016 Pointer arithmetic on char types ok, especially in this use case where it is the clearest way of conveying intent. */
80007c1e:	444c                	lw	a1,12(s0)
        if( pxQueue->u.xQueue.pcReadFrom >= pxQueue->u.xQueue.pcTail ) /*lint !e946 MISRA exception justified as use of the relational operator is the cleanest solutions. */
80007c20:	4414                	lw	a3,8(s0)
        pxQueue->u.xQueue.pcReadFrom += pxQueue->uxItemSize;           /*lint !e9016 Pointer arithmetic on char types ok, especially in this use case where it is the clearest way of conveying intent. */
80007c22:	95b2                	add	a1,a1,a2
80007c24:	c44c                	sw	a1,12(s0)
        if( pxQueue->u.xQueue.pcReadFrom >= pxQueue->u.xQueue.pcTail ) /*lint !e946 MISRA exception justified as use of the relational operator is the cleanest solutions. */
80007c26:	00d5e463          	bltu	a1,a3,80007c2e <.LBB14_12>
            pxQueue->u.xQueue.pcReadFrom = pxQueue->pcHead;
80007c2a:	400c                	lw	a1,0(s0)
80007c2c:	c44c                	sw	a1,12(s0)

80007c2e <.LBB14_12>:
        ( void ) memcpy( ( void * ) pvBuffer, ( void * ) pxQueue->u.xQueue.pcReadFrom, ( size_t ) pxQueue->uxItemSize ); /*lint !e961 !e418 !e9087 MISRA exception as the casts are only redundant for some ports.  Also previous logic ensures a null pointer can only be passed to memcpy() when the count is 0.  Cast to void required by function signature and safe as no alignment requirement and copy length specified in bytes. */
80007c2e:	475010ef          	jal	800098a2 <memcpy>

80007c32 <.LBB14_13>:
                pxQueue->uxMessagesWaiting = uxMessagesWaiting - ( UBaseType_t ) 1;
80007c32:	14fd                	add	s1,s1,-1
80007c34:	dc04                	sw	s1,56(s0)
                if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToSend ) ) == pdFALSE )
80007c36:	4808                	lw	a0,16(s0)
80007c38:	4485                	li	s1,1
80007c3a:	0a050c63          	beqz	a0,80007cf2 <.LBB14_35>
80007c3e:	01040513          	add	a0,s0,16
                    if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToSend ) ) != pdFALSE )
80007c42:	64b040ef          	jal	8000ca8c <xTaskRemoveFromEventList>
80007c46:	0a050663          	beqz	a0,80007cf2 <.LBB14_35>
                        queueYIELD_IF_USING_PREEMPTION();
80007c4a:	00000073          	ecall
80007c4e:	a055                	j	80007cf2 <.LBB14_35>

80007c50 <.LBB14_16>:
    configASSERT( !( ( ( pvBuffer ) == NULL ) && ( ( pxQueue )->uxItemSize != ( UBaseType_t ) 0U ) ) );
80007c50:	4028                	lw	a0,64(s0)
80007c52:	d545                	beqz	a0,80007bfa <.LBB14_2>
80007c54:	30047073          	csrc	mstatus,8
80007c58:	9002                	ebreak

80007c5a <.LBB14_18>:
80007c5a:	a001                	j	80007c5a <.LBB14_18>

80007c5c <.LBB14_19>:
80007c5c:	4a81                	li	s5,0
80007c5e:	02440993          	add	s3,s0,36
80007c62:	0ff00a13          	li	s4,255
80007c66:	a829                	j	80007c80 <.LBB14_22>

80007c68 <.LBB14_20>:
            prvUnlockQueue( pxQueue );
80007c68:	8522                	mv	a0,s0
80007c6a:	3db9                	jal	80007ac8 <prvUnlockQueue>
            ( void ) xTaskResumeAll();
80007c6c:	30d040ef          	jal	8000c778 <xTaskResumeAll>
    taskENTER_CRITICAL();
80007c70:	261d                	jal	80007f96 <vTaskEnterCritical>
        if( pxQueue->uxMessagesWaiting == ( UBaseType_t ) 0 )
80007c72:	5c04                	lw	s1,56(s0)
    taskEXIT_CRITICAL();
80007c74:	2d1040ef          	jal	8000c744 <vTaskExitCritical>
            if( prvIsQueueEmpty( pxQueue ) != pdFALSE )
80007c78:	ccbd                	beqz	s1,80007cf6 <.LBB14_36>

80007c7a <.LBB14_21>:
        taskENTER_CRITICAL();
80007c7a:	2e31                	jal	80007f96 <vTaskEnterCritical>
            const UBaseType_t uxMessagesWaiting = pxQueue->uxMessagesWaiting;
80007c7c:	5c04                	lw	s1,56(s0)
            if( uxMessagesWaiting > ( UBaseType_t ) 0 )
80007c7e:	fcc9                	bnez	s1,80007c18 <.LBB14_9>

80007c80 <.LBB14_22>:
                if( xTicksToWait == ( TickType_t ) 0 )
80007c80:	4542                	lw	a0,16(sp)
80007c82:	c53d                	beqz	a0,80007cf0 <.LBB14_34>
                else if( xEntryTimeSet == pdFALSE )
80007c84:	000a9563          	bnez	s5,80007c8e <.LBB14_25>
                    vTaskInternalSetTimeOutState( &xTimeOut );
80007c88:	0028                	add	a0,sp,8
80007c8a:	238d                	jal	800081ec <vTaskInternalSetTimeOutState>
80007c8c:	4a85                	li	s5,1

80007c8e <.LBB14_25>:
        taskEXIT_CRITICAL();
80007c8e:	2b7040ef          	jal	8000c744 <vTaskExitCritical>
        vTaskSuspendAll();
80007c92:	2db040ef          	jal	8000c76c <vTaskSuspendAll>
        prvLockQueue( pxQueue );
80007c96:	2601                	jal	80007f96 <vTaskEnterCritical>
80007c98:	04444503          	lbu	a0,68(s0)
80007c9c:	03450663          	beq	a0,s4,80007cc8 <.LBB14_30>
80007ca0:	04544503          	lbu	a0,69(s0)
80007ca4:	03450863          	beq	a0,s4,80007cd4 <.LBB14_31>

80007ca8 <.LBB14_27>:
80007ca8:	29d040ef          	jal	8000c744 <vTaskExitCritical>
        if( xTaskCheckForTimeOut( &xTimeOut, &xTicksToWait ) == pdFALSE )
80007cac:	0028                	add	a0,sp,8
80007cae:	080c                	add	a1,sp,16
80007cb0:	23a9                	jal	800081fa <xTaskCheckForTimeOut>
80007cb2:	f95d                	bnez	a0,80007c68 <.LBB14_20>
    taskENTER_CRITICAL();
80007cb4:	24cd                	jal	80007f96 <vTaskEnterCritical>
        if( pxQueue->uxMessagesWaiting == ( UBaseType_t ) 0 )
80007cb6:	5c04                	lw	s1,56(s0)
    taskEXIT_CRITICAL();
80007cb8:	28d040ef          	jal	8000c744 <vTaskExitCritical>
            if( prvIsQueueEmpty( pxQueue ) != pdFALSE )
80007cbc:	cc99                	beqz	s1,80007cda <.LBB14_32>
                prvUnlockQueue( pxQueue );
80007cbe:	8522                	mv	a0,s0
80007cc0:	3521                	jal	80007ac8 <prvUnlockQueue>
                ( void ) xTaskResumeAll();
80007cc2:	2b7040ef          	jal	8000c778 <xTaskResumeAll>
80007cc6:	bf55                	j	80007c7a <.LBB14_21>

80007cc8 <.LBB14_30>:
        prvLockQueue( pxQueue );
80007cc8:	04040223          	sb	zero,68(s0)
80007ccc:	04544503          	lbu	a0,69(s0)
80007cd0:	fd451ce3          	bne	a0,s4,80007ca8 <.LBB14_27>

80007cd4 <.LBB14_31>:
80007cd4:	040402a3          	sb	zero,69(s0)
80007cd8:	bfc1                	j	80007ca8 <.LBB14_27>

80007cda <.LBB14_32>:
                vTaskPlaceOnEventList( &( pxQueue->xTasksWaitingToReceive ), xTicksToWait );
80007cda:	45c2                	lw	a1,16(sp)
80007cdc:	854e                	mv	a0,s3
80007cde:	214d                	jal	80008180 <vTaskPlaceOnEventList>
                prvUnlockQueue( pxQueue );
80007ce0:	8522                	mv	a0,s0
80007ce2:	33dd                	jal	80007ac8 <prvUnlockQueue>
                if( xTaskResumeAll() == pdFALSE )
80007ce4:	295040ef          	jal	8000c778 <xTaskResumeAll>
80007ce8:	f949                	bnez	a0,80007c7a <.LBB14_21>
                    portYIELD_WITHIN_API();
80007cea:	00000073          	ecall
80007cee:	b771                	j	80007c7a <.LBB14_21>

80007cf0 <.LBB14_34>:
80007cf0:	4481                	li	s1,0

80007cf2 <.LBB14_35>:
80007cf2:	253040ef          	jal	8000c744 <vTaskExitCritical>

80007cf6 <.LBB14_36>:
}
80007cf6:	8526                	mv	a0,s1
80007cf8:	50b2                	lw	ra,44(sp)
80007cfa:	5422                	lw	s0,40(sp)
80007cfc:	5492                	lw	s1,36(sp)
80007cfe:	5902                	lw	s2,32(sp)
80007d00:	49f2                	lw	s3,28(sp)
80007d02:	4a62                	lw	s4,24(sp)
80007d04:	4ad2                	lw	s5,20(sp)
80007d06:	6145                	add	sp,sp,48
80007d08:	8082                	ret

Disassembly of section .text.vQueueDelete:

80007d0a <vQueueDelete>:
    configASSERT( pxQueue );
80007d0a:	c119                	beqz	a0,80007d10 <.LBB21_2>
            vPortFree( pxQueue );
80007d0c:	60c0406f          	j	8000c318 <vPortFree>

80007d10 <.LBB21_2>:
    configASSERT( pxQueue );
80007d10:	30047073          	csrc	mstatus,8
80007d14:	9002                	ebreak

80007d16 <.LBB21_3>:
80007d16:	a001                	j	80007d16 <.LBB21_3>

Disassembly of section .text.vQueueWaitForMessageRestricted:

80007d18 <vQueueWaitForMessageRestricted>:
#if ( configUSE_TIMERS == 1 )

    void vQueueWaitForMessageRestricted( QueueHandle_t xQueue,
                                         TickType_t xTicksToWait,
                                         const BaseType_t xWaitIndefinitely )
    {
80007d18:	1141                	add	sp,sp,-16
80007d1a:	c606                	sw	ra,12(sp)
80007d1c:	c422                	sw	s0,8(sp)
80007d1e:	c226                	sw	s1,4(sp)
80007d20:	c04a                	sw	s2,0(sp)
80007d22:	8932                	mv	s2,a2
80007d24:	84ae                	mv	s1,a1
80007d26:	842a                	mv	s0,a0
         *  will not actually cause the task to block, just place it on a blocked
         *  list.  It will not block until the scheduler is unlocked - at which
         *  time a yield will be performed.  If an item is added to the queue while
         *  the queue is locked, and the calling task blocks on the queue, then the
         *  calling task will be immediately unblocked when the queue is unlocked. */
        prvLockQueue( pxQueue );
80007d28:	24bd                	jal	80007f96 <vTaskEnterCritical>
80007d2a:	04444583          	lbu	a1,68(s0)
80007d2e:	0ff00513          	li	a0,255
80007d32:	02a58663          	beq	a1,a0,80007d5e <.LBB27_5>
80007d36:	04544583          	lbu	a1,69(s0)
80007d3a:	02a58863          	beq	a1,a0,80007d6a <.LBB27_6>

80007d3e <.LBB27_2>:
80007d3e:	207040ef          	jal	8000c744 <vTaskExitCritical>

        if( pxQueue->uxMessagesWaiting == ( UBaseType_t ) 0U )
80007d42:	5c08                	lw	a0,56(s0)
80007d44:	e511                	bnez	a0,80007d50 <.LBB27_4>
        {
            /* There is nothing in the queue, block for the specified period. */
            vTaskPlaceOnEventListRestricted( &( pxQueue->xTasksWaitingToReceive ), xTicksToWait, xWaitIndefinitely );
80007d46:	02440513          	add	a0,s0,36
80007d4a:	85a6                	mv	a1,s1
80007d4c:	864a                	mv	a2,s2
80007d4e:	29a9                	jal	800081a8 <vTaskPlaceOnEventListRestricted>

80007d50 <.LBB27_4>:
        else
        {
            mtCOVERAGE_TEST_MARKER();
        }

        prvUnlockQueue( pxQueue );
80007d50:	8522                	mv	a0,s0
80007d52:	40b2                	lw	ra,12(sp)
80007d54:	4422                	lw	s0,8(sp)
80007d56:	4492                	lw	s1,4(sp)
80007d58:	4902                	lw	s2,0(sp)
80007d5a:	0141                	add	sp,sp,16
80007d5c:	b3b5                	j	80007ac8 <prvUnlockQueue>

80007d5e <.LBB27_5>:
        prvLockQueue( pxQueue );
80007d5e:	04040223          	sb	zero,68(s0)
80007d62:	04544583          	lbu	a1,69(s0)
80007d66:	fca59ce3          	bne	a1,a0,80007d3e <.LBB27_2>

80007d6a <.LBB27_6>:
80007d6a:	040402a3          	sb	zero,69(s0)
80007d6e:	bfc1                	j	80007d3e <.LBB27_2>

Disassembly of section .text.xTaskCreate:

80007d70 <xTaskCreate>:
                            const char * const pcName, /*lint !e971 Unqualified char types are allowed for strings and single characters only. */
                            const configSTACK_DEPTH_TYPE usStackDepth,
                            void * const pvParameters,
                            UBaseType_t uxPriority,
                            TaskHandle_t * const pxCreatedTask )
    {
80007d70:	7179                	add	sp,sp,-48
80007d72:	d606                	sw	ra,44(sp)
80007d74:	d422                	sw	s0,40(sp)
80007d76:	d226                	sw	s1,36(sp)
80007d78:	d04a                	sw	s2,32(sp)
80007d7a:	ce4e                	sw	s3,28(sp)
80007d7c:	cc52                	sw	s4,24(sp)
80007d7e:	ca56                	sw	s5,20(sp)
80007d80:	c85a                	sw	s6,16(sp)
80007d82:	c65e                	sw	s7,12(sp)
80007d84:	c462                	sw	s8,8(sp)
80007d86:	8a3e                	mv	s4,a5
80007d88:	8b3a                	mv	s6,a4
80007d8a:	89b6                	mv	s3,a3
80007d8c:	842e                	mv	s0,a1
80007d8e:	8aaa                	mv	s5,a0
        #else /* portSTACK_GROWTH */
            {
                StackType_t * pxStack;

                /* Allocate space for the stack used by the task being created. */
                pxStack = pvPortMallocStack( ( ( ( size_t ) usStackDepth ) * sizeof( StackType_t ) ) ); /*lint !e9079 All values returned by pvPortMalloc() have at least the alignment required by the MCU's stack and this allocation is the stack. */
80007d90:	00261913          	sll	s2,a2,0x2
80007d94:	854a                	mv	a0,s2
80007d96:	40a040ef          	jal	8000c1a0 <pvPortMalloc>
80007d9a:	5bfd                	li	s7,-1

                if( pxStack != NULL )
80007d9c:	1e050063          	beqz	a0,80007f7c <.LBB0_30>
80007da0:	84aa                	mv	s1,a0
                {
                    /* Allocate space for the TCB. */
                    pxNewTCB = ( TCB_t * ) pvPortMalloc( sizeof( TCB_t ) ); /*lint !e9087 !e9079 All values returned by pvPortMalloc() have at least the alignment required by the MCU's stack, and the first member of TCB_t is always a pointer to the task's stack. */
80007da2:	06000513          	li	a0,96
80007da6:	3fa040ef          	jal	8000c1a0 <pvPortMalloc>

                    if( pxNewTCB != NULL )
80007daa:	c139                	beqz	a0,80007df0 <.LBB0_9>
80007dac:	8c2a                	mv	s8,a0
                    {
                        /* Store the stack location in the TCB. */
                        pxNewTCB->pxStack = pxStack;
80007dae:	d904                	sw	s1,48(a0)

    /* Avoid dependency on memset() if it is not required. */
    #if ( tskSET_NEW_STACKS_TO_KNOWN_VALUE == 1 )
        {
            /* Fill the stack with a known value to assist debugging. */
            ( void ) memset( pxNewTCB->pxStack, ( int ) tskSTACK_FILL_BYTE, ( size_t ) ulStackDepth * sizeof( StackType_t ) );
80007db0:	0a500593          	li	a1,165
80007db4:	8526                	mv	a0,s1
80007db6:	864a                	mv	a2,s2
80007db8:	561050ef          	jal	8000db18 <memset>
     * grows from high memory to low (as per the 80x86) or vice versa.
     * portSTACK_GROWTH is used to make the result positive or negative as required
     * by the port. */
    #if ( portSTACK_GROWTH < 0 )
        {
            pxTopOfStack = &( pxNewTCB->pxStack[ ulStackDepth - ( uint32_t ) 1 ] );
80007dbc:	030c2503          	lw	a0,48(s8)
            pxNewTCB->pxEndOfStack = pxNewTCB->pxStack + ( ulStackDepth - ( uint32_t ) 1 );
        }
    #endif /* portSTACK_GROWTH */

    /* Store the task name in the TCB. */
    if( pcName != NULL )
80007dc0:	cc05                	beqz	s0,80007df8 <.LBB0_10>
    {
        for( x = ( UBaseType_t ) 0; x < ( UBaseType_t ) configMAX_TASK_NAME_LEN; x++ )
80007dc2:	034c0593          	add	a1,s8,52
80007dc6:	463d                	li	a2,15

80007dc8 <.LBB0_4>:
        {
            pxNewTCB->pcTaskName[ x ] = pcName[ x ];
80007dc8:	00044703          	lbu	a4,0(s0)
80007dcc:	00e58023          	sb	a4,0(a1)

            /* Don't copy all configMAX_TASK_NAME_LEN if the string is shorter than
             * configMAX_TASK_NAME_LEN characters just in case the memory after the
             * string is not accessible (extremely unlikely). */
            if( pcName[ x ] == ( char ) 0x00 )
80007dd0:	c711                	beqz	a4,80007ddc <.LBB0_6>
80007dd2:	86b2                	mv	a3,a2
80007dd4:	167d                	add	a2,a2,-1
80007dd6:	0585                	add	a1,a1,1
80007dd8:	0405                	add	s0,s0,1
80007dda:	f6fd                	bnez	a3,80007dc8 <.LBB0_4>

80007ddc <.LBB0_6>:
            }
        }

        /* Ensure the name string is terminated in the case that the string length
         * was greater or equal to configMAX_TASK_NAME_LEN. */
        pxNewTCB->pcTaskName[ configMAX_TASK_NAME_LEN - 1 ] = '\0';
80007ddc:	040c01a3          	sb	zero,67(s8)
80007de0:	02000493          	li	s1,32
         * terminator when it is read out. */
        pxNewTCB->pcTaskName[ 0 ] = 0x00;
    }

    /* This is used as an array index so must ensure it's not too large. */
    configASSERT( uxPriority < configMAX_PRIORITIES );
80007de4:	029b6063          	bltu	s6,s1,80007e04 <.LBB0_11>

80007de8 <.LBB0_7>:
80007de8:	30047073          	csrc	mstatus,8
80007dec:	9002                	ebreak

80007dee <.LBB0_8>:
80007dee:	a001                	j	80007dee <.LBB0_8>

80007df0 <.LBB0_9>:
                        vPortFreeStack( pxStack );
80007df0:	8526                	mv	a0,s1
80007df2:	526040ef          	jal	8000c318 <vPortFree>
80007df6:	a259                	j	80007f7c <.LBB0_30>

80007df8 <.LBB0_10>:
        pxNewTCB->pcTaskName[ 0 ] = 0x00;
80007df8:	020c0a23          	sb	zero,52(s8)
80007dfc:	02000493          	li	s1,32
    configASSERT( uxPriority < configMAX_PRIORITIES );
80007e00:	fe9b74e3          	bgeu	s6,s1,80007de8 <.LBB0_7>

80007e04 <.LBB0_11>:
80007e04:	954a                	add	a0,a0,s2
80007e06:	1571                	add	a0,a0,-4
80007e08:	ff857413          	and	s0,a0,-8
    else
    {
        mtCOVERAGE_TEST_MARKER();
    }

    pxNewTCB->uxPriority = uxPriority;
80007e0c:	036c2623          	sw	s6,44(s8)
    #if ( configUSE_MUTEXES == 1 )
        {
            pxNewTCB->uxBasePriority = uxPriority;
80007e10:	056c2823          	sw	s6,80(s8)
            pxNewTCB->uxMutexesHeld = 0;
80007e14:	040c2a23          	sw	zero,84(s8)
        }
    #endif /* configUSE_MUTEXES */

    vListInitialiseItem( &( pxNewTCB->xStateListItem ) );
80007e18:	004c0913          	add	s2,s8,4
80007e1c:	854a                	mv	a0,s2
80007e1e:	3269                	jal	800077a8 <vListInitialiseItem>
    vListInitialiseItem( &( pxNewTCB->xEventListItem ) );
80007e20:	018c0513          	add	a0,s8,24
80007e24:	3251                	jal	800077a8 <vListInitialiseItem>

    /* Set the pxNewTCB as a link back from the ListItem_t.  This is so we can get
     * back to  the containing TCB from a generic item in a list. */
    listSET_LIST_ITEM_OWNER( &( pxNewTCB->xStateListItem ), pxNewTCB );
80007e26:	018c2823          	sw	s8,16(s8)

    /* Event lists are always in priority order. */
    listSET_LIST_ITEM_VALUE( &( pxNewTCB->xEventListItem ), ( TickType_t ) configMAX_PRIORITIES - ( TickType_t ) uxPriority ); /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
80007e2a:	41648533          	sub	a0,s1,s6
80007e2e:	00ac2c23          	sw	a0,24(s8)
    listSET_LIST_ITEM_OWNER( &( pxNewTCB->xEventListItem ), pxNewTCB );
80007e32:	038c2223          	sw	s8,36(s8)

    #if ( portCRITICAL_NESTING_IN_TCB == 1 )
        {
            pxNewTCB->uxCriticalNesting = ( UBaseType_t ) 0U;
80007e36:	040c2223          	sw	zero,68(s8)
        }
    #endif

    #if ( configUSE_TASK_NOTIFICATIONS == 1 )
        {
            memset( ( void * ) &( pxNewTCB->ulNotifiedValue[ 0 ] ), 0x00, sizeof( pxNewTCB->ulNotifiedValue ) );
80007e3a:	040c2c23          	sw	zero,88(s8)
            memset( ( void * ) &( pxNewTCB->ucNotifyState[ 0 ] ), 0x00, sizeof( pxNewTCB->ucNotifyState ) );
80007e3e:	040c1e23          	sh	zero,92(s8)
                        }
                    #endif /* portSTACK_GROWTH */
                }
            #else /* portHAS_STACK_OVERFLOW_CHECKING */
                {
                    pxNewTCB->pxTopOfStack = pxPortInitialiseStack( pxTopOfStack, pxTaskCode, pvParameters );
80007e42:	8522                	mv	a0,s0
80007e44:	85d6                	mv	a1,s5
80007e46:	864e                	mv	a2,s3
80007e48:	7fff8097          	auipc	ra,0x7fff8
80007e4c:	6b8080e7          	jalr	1720(ra) # 500 <pxPortInitialiseStack>
80007e50:	00ac2023          	sw	a0,0(s8)
                }
            #endif /* portHAS_STACK_OVERFLOW_CHECKING */
        }
    #endif /* portUSING_MPU_WRAPPERS */

    if( pxCreatedTask != NULL )
80007e54:	000a0463          	beqz	s4,80007e5c <.LBB0_13>
    {
        /* Pass the handle out in an anonymous way.  The handle can be used to
         * change the created task's priority, delete the created task, etc.*/
        *pxCreatedTask = ( TaskHandle_t ) pxNewTCB;
80007e58:	018a2023          	sw	s8,0(s4)

80007e5c <.LBB0_13>:

#if ( portCRITICAL_NESTING_IN_TCB == 1 )

    void vTaskEnterCritical( void )
    {
        portDISABLE_INTERRUPTS();
80007e5c:	30047073          	csrc	mstatus,8

        if( xSchedulerRunning != pdFALSE )
80007e60:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
80007e64:	c901                	beqz	a0,80007e74 <.LBB0_15>
        {
            ( pxCurrentTCB->uxCriticalNesting )++;
80007e66:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80007e6a:	41f0                	lw	a2,68(a1)
80007e6c:	0605                	add	a2,a2,1
80007e6e:	c1f0                	sw	a2,68(a1)
             * function so  assert() if it is being called from an interrupt
             * context.  Only API functions that end in "FromISR" can be used in an
             * interrupt.  Only assert if the critical nesting count is 1 to
             * protect against recursive calls if the assert function also uses a
             * critical section. */
            if( pxCurrentTCB->uxCriticalNesting == 1 )
80007e70:	6801a003          	lw	zero,1664(gp) # 819f0 <pxCurrentTCB>

80007e74 <.LBB0_15>:
        uxCurrentNumberOfTasks++;
80007e74:	6541a583          	lw	a1,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
80007e78:	0585                	add	a1,a1,1
80007e7a:	64b1aa23          	sw	a1,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
        if( pxCurrentTCB == NULL )
80007e7e:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
80007e82:	ce11                	beqz	a2,80007e9e <.LBB0_19>
            if( xSchedulerRunning == pdFALSE )
80007e84:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
80007e88:	e535                	bnez	a0,80007ef4 <.LBB0_23>
                if( pxCurrentTCB->uxPriority <= pxNewTCB->uxPriority )
80007e8a:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80007e8e:	55cc                	lw	a1,44(a1)
80007e90:	02cc2603          	lw	a2,44(s8)
80007e94:	06b66063          	bltu	a2,a1,80007ef4 <.LBB0_23>
                    pxCurrentTCB = pxNewTCB;
80007e98:	6981a023          	sw	s8,1664(gp) # 819f0 <pxCurrentTCB>
80007e9c:	a8a1                	j	80007ef4 <.LBB0_23>

80007e9e <.LBB0_19>:
            pxCurrentTCB = pxNewTCB;
80007e9e:	6981a023          	sw	s8,1664(gp) # 819f0 <pxCurrentTCB>
            if( uxCurrentNumberOfTasks == ( UBaseType_t ) 1 )
80007ea2:	6541a503          	lw	a0,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
80007ea6:	4585                	li	a1,1
80007ea8:	04b51663          	bne	a0,a1,80007ef4 <.LBB0_23>
80007eac:	e8418413          	add	s0,gp,-380 # 811f4 <pxReadyTasksLists>
80007eb0:	28040493          	add	s1,s0,640

80007eb4 <.LBB0_21>:
        vListInitialise( &( pxReadyTasksLists[ uxPriority ] ) );
80007eb4:	8522                	mv	a0,s0
80007eb6:	50a040ef          	jal	8000c3c0 <vListInitialise>
    for( uxPriority = ( UBaseType_t ) 0U; uxPriority < ( UBaseType_t ) configMAX_PRIORITIES; uxPriority++ )
80007eba:	0451                	add	s0,s0,20
80007ebc:	fe941ce3          	bne	s0,s1,80007eb4 <.LBB0_21>
    vListInitialise( &xDelayedTaskList1 );
80007ec0:	58418413          	add	s0,gp,1412 # 818f4 <xDelayedTaskList1>
80007ec4:	8522                	mv	a0,s0
80007ec6:	4fa040ef          	jal	8000c3c0 <vListInitialise>
    vListInitialise( &xDelayedTaskList2 );
80007eca:	57018493          	add	s1,gp,1392 # 818e0 <xDelayedTaskList2>
80007ece:	8526                	mv	a0,s1
80007ed0:	4f0040ef          	jal	8000c3c0 <vListInitialise>
    vListInitialise( &xPendingReadyList );
80007ed4:	55c18513          	add	a0,gp,1372 # 818cc <xPendingReadyList>
80007ed8:	4e8040ef          	jal	8000c3c0 <vListInitialise>
            vListInitialise( &xTasksWaitingTermination );
80007edc:	53418513          	add	a0,gp,1332 # 818a4 <xTasksWaitingTermination>
80007ee0:	4e0040ef          	jal	8000c3c0 <vListInitialise>
            vListInitialise( &xSuspendedTaskList );
80007ee4:	54818513          	add	a0,gp,1352 # 818b8 <xSuspendedTaskList>
80007ee8:	4d8040ef          	jal	8000c3c0 <vListInitialise>
    pxDelayedTaskList = &xDelayedTaskList1;
80007eec:	6681ac23          	sw	s0,1656(gp) # 819e8 <pxDelayedTaskList>
    pxOverflowDelayedTaskList = &xDelayedTaskList2;
80007ef0:	6691a823          	sw	s1,1648(gp) # 819e0 <pxOverflowDelayedTaskList>

80007ef4 <.LBB0_23>:
        uxTaskNumber++;
80007ef4:	6481a583          	lw	a1,1608(gp) # 819b8 <uxTaskNumber>
80007ef8:	0585                	add	a1,a1,1
80007efa:	64b1a423          	sw	a1,1608(gp) # 819b8 <uxTaskNumber>
                pxNewTCB->uxTCBNumber = uxTaskNumber;
80007efe:	04bc2423          	sw	a1,72(s8)
        prvAddTaskToReadyList( pxNewTCB );
80007f02:	02cc2503          	lw	a0,44(s8)
80007f06:	6441a603          	lw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
80007f0a:	4b85                	li	s7,1
80007f0c:	00ab96b3          	sll	a3,s7,a0
80007f10:	8e55                	or	a2,a2,a3
80007f12:	64c1a223          	sw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
80007f16:	45d1                	li	a1,20
80007f18:	02b50533          	mul	a0,a0,a1
80007f1c:	e8418593          	add	a1,gp,-380 # 811f4 <pxReadyTasksLists>
80007f20:	952e                	add	a0,a0,a1
80007f22:	414c                	lw	a1,4(a0)
80007f24:	4590                	lw	a2,8(a1)
80007f26:	00bc2423          	sw	a1,8(s8)
80007f2a:	00cc2623          	sw	a2,12(s8)
80007f2e:	01262223          	sw	s2,4(a2)
80007f32:	0125a423          	sw	s2,8(a1)
80007f36:	00ac2a23          	sw	a0,20(s8)
80007f3a:	410c                	lw	a1,0(a0)
80007f3c:	0585                	add	a1,a1,1
80007f3e:	c10c                	sw	a1,0(a0)

#if ( portCRITICAL_NESTING_IN_TCB == 1 )

    void vTaskExitCritical( void )
    {
        if( xSchedulerRunning != pdFALSE )
80007f40:	6181a583          	lw	a1,1560(gp) # 81988 <xSchedulerRunning>
80007f44:	c185                	beqz	a1,80007f64 <.LBB0_27>
        {
            if( pxCurrentTCB->uxCriticalNesting > 0U )
80007f46:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
80007f4a:	4270                	lw	a2,68(a2)
80007f4c:	ce01                	beqz	a2,80007f64 <.LBB0_27>
            {
                ( pxCurrentTCB->uxCriticalNesting )--;
80007f4e:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
80007f52:	4274                	lw	a3,68(a2)
80007f54:	16fd                	add	a3,a3,-1
80007f56:	c274                	sw	a3,68(a2)

                if( pxCurrentTCB->uxCriticalNesting == 0U )
80007f58:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80007f5c:	41ec                	lw	a1,68(a1)
80007f5e:	e199                	bnez	a1,80007f64 <.LBB0_27>
                {
                    portENABLE_INTERRUPTS();
80007f60:	30046073          	csrs	mstatus,8

80007f64 <.LBB0_27>:
    if( xSchedulerRunning != pdFALSE )
80007f64:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
80007f68:	c911                	beqz	a0,80007f7c <.LBB0_30>
        if( pxCurrentTCB->uxPriority < pxNewTCB->uxPriority )
80007f6a:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
80007f6e:	5548                	lw	a0,44(a0)
80007f70:	02cc2583          	lw	a1,44(s8)
80007f74:	00b57463          	bgeu	a0,a1,80007f7c <.LBB0_30>
            taskYIELD_IF_USING_PREEMPTION();
80007f78:	00000073          	ecall

80007f7c <.LBB0_30>:
        return xReturn;
80007f7c:	855e                	mv	a0,s7
80007f7e:	50b2                	lw	ra,44(sp)
80007f80:	5422                	lw	s0,40(sp)
80007f82:	5492                	lw	s1,36(sp)
80007f84:	5902                	lw	s2,32(sp)
80007f86:	49f2                	lw	s3,28(sp)
80007f88:	4a62                	lw	s4,24(sp)
80007f8a:	4ad2                	lw	s5,20(sp)
80007f8c:	4b42                	lw	s6,16(sp)
80007f8e:	4bb2                	lw	s7,12(sp)
80007f90:	4c22                	lw	s8,8(sp)
80007f92:	6145                	add	sp,sp,48
80007f94:	8082                	ret

Disassembly of section .text.vTaskEnterCritical:

80007f96 <vTaskEnterCritical>:
        portDISABLE_INTERRUPTS();
80007f96:	30047073          	csrc	mstatus,8
        if( xSchedulerRunning != pdFALSE )
80007f9a:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
80007f9e:	c901                	beqz	a0,80007fae <.LBB2_2>
            ( pxCurrentTCB->uxCriticalNesting )++;
80007fa0:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80007fa4:	41f0                	lw	a2,68(a1)
80007fa6:	0605                	add	a2,a2,1
80007fa8:	c1f0                	sw	a2,68(a1)
            if( pxCurrentTCB->uxCriticalNesting == 1 )
80007faa:	6801a003          	lw	zero,1664(gp) # 819f0 <pxCurrentTCB>

80007fae <.LBB2_2>:
    }
80007fae:	8082                	ret

Disassembly of section .text.prvAddCurrentTaskToDelayedList:

80007fb0 <prvAddCurrentTaskToDelayedList>:
#endif
/*-----------------------------------------------------------*/

static void prvAddCurrentTaskToDelayedList( TickType_t xTicksToWait,
                                            const BaseType_t xCanBlockIndefinitely )
{
80007fb0:	1101                	add	sp,sp,-32
80007fb2:	ce06                	sw	ra,28(sp)
80007fb4:	cc22                	sw	s0,24(sp)
80007fb6:	ca26                	sw	s1,20(sp)
80007fb8:	c84a                	sw	s2,16(sp)
80007fba:	c64e                	sw	s3,12(sp)
    TickType_t xTimeToWake;
    const TickType_t xConstTickCount = xTickCount;
80007fbc:	6141a903          	lw	s2,1556(gp) # 81984 <xTickCount>
    #if ( INCLUDE_xTaskAbortDelay == 1 )
        {
            /* About to enter a delayed list, so ensure the ucDelayAborted flag is
             * reset to pdFALSE so it can be detected as having been set to pdTRUE
             * when the task leaves the Blocked state. */
            pxCurrentTCB->ucDelayAborted = pdFALSE;
80007fc0:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
80007fc4:	04060ea3          	sb	zero,93(a2)
        }
    #endif

    /* Remove the task from the ready list before adding it to the blocked list
     * as the same list item is used for both lists. */
    if( uxListRemove( &( pxCurrentTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
80007fc8:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
80007fcc:	89ae                	mv	s3,a1
80007fce:	842a                	mv	s0,a0
80007fd0:	00460513          	add	a0,a2,4
80007fd4:	400040ef          	jal	8000c3d4 <uxListRemove>
80007fd8:	c509                	beqz	a0,80007fe2 <.LBB6_2>
80007fda:	557d                	li	a0,-1
        mtCOVERAGE_TEST_MARKER();
    }

    #if ( INCLUDE_vTaskSuspend == 1 )
        {
            if( ( xTicksToWait == portMAX_DELAY ) && ( xCanBlockIndefinitely != pdFALSE ) )
80007fdc:	02a40363          	beq	s0,a0,80008002 <.LBB6_3>
80007fe0:	a0a5                	j	80008048 <.LBB6_6>

80007fe2 <.LBB6_2>:
        portRESET_READY_PRIORITY( pxCurrentTCB->uxPriority, uxTopReadyPriority ); /*lint !e931 pxCurrentTCB cannot change as it is the calling task.  pxCurrentTCB->uxPriority and uxTopReadyPriority cannot change as called with scheduler suspended or in a critical section. */
80007fe2:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
80007fe6:	5548                	lw	a0,44(a0)
80007fe8:	6441a603          	lw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
80007fec:	4685                	li	a3,1
80007fee:	00a69533          	sll	a0,a3,a0
80007ff2:	fff54513          	not	a0,a0
80007ff6:	8d71                	and	a0,a0,a2
80007ff8:	64a1a223          	sw	a0,1604(gp) # 819b4 <uxTopReadyPriority>
80007ffc:	557d                	li	a0,-1
            if( ( xTicksToWait == portMAX_DELAY ) && ( xCanBlockIndefinitely != pdFALSE ) )
80007ffe:	04a41563          	bne	s0,a0,80008048 <.LBB6_6>

80008002 <.LBB6_3>:
80008002:	04098363          	beqz	s3,80008048 <.LBB6_6>
            {
                /* Add the task to the suspended task list instead of a delayed task
                 * list to ensure it is not woken by a timing event.  It will block
                 * indefinitely. */
                listINSERT_END( &xSuspendedTaskList, &( pxCurrentTCB->xStateListItem ) );
80008006:	54818593          	add	a1,gp,1352 # 818b8 <xSuspendedTaskList>
8000800a:	41d0                	lw	a2,4(a1)
8000800c:	6801a703          	lw	a4,1664(gp) # 819f0 <pxCurrentTCB>
80008010:	c710                	sw	a2,8(a4)
80008012:	4618                	lw	a4,8(a2)
80008014:	6801a783          	lw	a5,1664(gp) # 819f0 <pxCurrentTCB>
80008018:	c7d8                	sw	a4,12(a5)
8000801a:	6801a783          	lw	a5,1664(gp) # 819f0 <pxCurrentTCB>
8000801e:	0791                	add	a5,a5,4
80008020:	c35c                	sw	a5,4(a4)
80008022:	6801a703          	lw	a4,1664(gp) # 819f0 <pxCurrentTCB>
80008026:	0711                	add	a4,a4,4
80008028:	c618                	sw	a4,8(a2)
8000802a:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000802e:	ca4c                	sw	a1,20(a2)
80008030:	5481a583          	lw	a1,1352(gp) # 818b8 <xSuspendedTaskList>
80008034:	0585                	add	a1,a1,1
80008036:	54b1a423          	sw	a1,1352(gp) # 818b8 <xSuspendedTaskList>

8000803a <.LBB6_5>:
8000803a:	40f2                	lw	ra,28(sp)
8000803c:	4462                	lw	s0,24(sp)
8000803e:	44d2                	lw	s1,20(sp)
80008040:	4942                	lw	s2,16(sp)
80008042:	49b2                	lw	s3,12(sp)

            /* Avoid compiler warning when INCLUDE_vTaskSuspend is not 1. */
            ( void ) xCanBlockIndefinitely;
        }
    #endif /* INCLUDE_vTaskSuspend */
}
80008044:	6105                	add	sp,sp,32
80008046:	8082                	ret

80008048 <.LBB6_6>:
                listSET_LIST_ITEM_VALUE( &( pxCurrentTCB->xStateListItem ), xTimeToWake );
80008048:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
                xTimeToWake = xConstTickCount + xTicksToWait;
8000804c:	944a                	add	s0,s0,s2
                listSET_LIST_ITEM_VALUE( &( pxCurrentTCB->xStateListItem ), xTimeToWake );
8000804e:	c140                	sw	s0,4(a0)
                if( xTimeToWake < xConstTickCount )
80008050:	01247f63          	bgeu	s0,s2,8000806e <.LBB6_8>
                    vListInsert( pxOverflowDelayedTaskList, &( pxCurrentTCB->xStateListItem ) );
80008054:	6701a503          	lw	a0,1648(gp) # 819e0 <pxOverflowDelayedTaskList>
80008058:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000805c:	0591                	add	a1,a1,4
8000805e:	40f2                	lw	ra,28(sp)
80008060:	4462                	lw	s0,24(sp)
80008062:	44d2                	lw	s1,20(sp)
80008064:	4942                	lw	s2,16(sp)
80008066:	49b2                	lw	s3,12(sp)
80008068:	6105                	add	sp,sp,32
8000806a:	f5aff06f          	j	800077c4 <vListInsert>

8000806e <.LBB6_8>:
                    vListInsert( pxDelayedTaskList, &( pxCurrentTCB->xStateListItem ) );
8000806e:	6781a503          	lw	a0,1656(gp) # 819e8 <pxDelayedTaskList>
80008072:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80008076:	0591                	add	a1,a1,4
80008078:	f4cff0ef          	jal	800077c4 <vListInsert>
                    if( xTimeToWake < xNextTaskUnblockTime )
8000807c:	62c1a583          	lw	a1,1580(gp) # 8199c <xNextTaskUnblockTime>
80008080:	fab47de3          	bgeu	s0,a1,8000803a <.LBB6_5>
                        xNextTaskUnblockTime = xTimeToWake;
80008084:	6281a623          	sw	s0,1580(gp) # 8199c <xNextTaskUnblockTime>
80008088:	bf4d                	j	8000803a <.LBB6_5>

Disassembly of section .text.vTaskDelay:

8000808a <vTaskDelay>:
        if( xTicksToDelay > ( TickType_t ) 0U )
8000808a:	c51d                	beqz	a0,800080b8 <.LBB8_6>
            configASSERT( uxSchedulerSuspended == 0 );
8000808c:	64c1a603          	lw	a2,1612(gp) # 819bc <uxSchedulerSuspended>
80008090:	c609                	beqz	a2,8000809a <.LBB8_4>
80008092:	30047073          	csrc	mstatus,8
80008096:	9002                	ebreak

80008098 <.LBB8_3>:
80008098:	a001                	j	80008098 <.LBB8_3>

8000809a <.LBB8_4>:
8000809a:	1141                	add	sp,sp,-16
8000809c:	c606                	sw	ra,12(sp)
    ++uxSchedulerSuspended;
8000809e:	64c1a603          	lw	a2,1612(gp) # 819bc <uxSchedulerSuspended>
800080a2:	0605                	add	a2,a2,1
800080a4:	64c1a623          	sw	a2,1612(gp) # 819bc <uxSchedulerSuspended>
                prvAddCurrentTaskToDelayedList( xTicksToDelay, pdFALSE );
800080a8:	4581                	li	a1,0
800080aa:	3719                	jal	80007fb0 <prvAddCurrentTaskToDelayedList>
            xAlreadyYielded = xTaskResumeAll();
800080ac:	6cc040ef          	jal	8000c778 <xTaskResumeAll>
800080b0:	40b2                	lw	ra,12(sp)
        if( xAlreadyYielded == pdFALSE )
800080b2:	0141                	add	sp,sp,16
800080b4:	c111                	beqz	a0,800080b8 <.LBB8_6>
    }
800080b6:	8082                	ret

800080b8 <.LBB8_6>:
            portYIELD_WITHIN_API();
800080b8:	00000073          	ecall
    }
800080bc:	8082                	ret

Disassembly of section .text.vTaskSwitchContext:

800080be <vTaskSwitchContext>:
{
800080be:	1141                	add	sp,sp,-16
800080c0:	c606                	sw	ra,12(sp)
    if( uxSchedulerSuspended != ( UBaseType_t ) pdFALSE )
800080c2:	64c1a503          	lw	a0,1612(gp) # 819bc <uxSchedulerSuspended>
800080c6:	c509                	beqz	a0,800080d0 <.LBB14_2>
        xYieldPending = pdTRUE;
800080c8:	4585                	li	a1,1
800080ca:	60b1a423          	sw	a1,1544(gp) # 81978 <xYieldPending>
800080ce:	a835                	j	8000810a <.LBB14_6>

800080d0 <.LBB14_2>:
        xYieldPending = pdFALSE;
800080d0:	6001a423          	sw	zero,1544(gp) # 81978 <xYieldPending>
        taskSELECT_HIGHEST_PRIORITY_TASK(); /*lint !e9079 void * is used as this macro is used with timers and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
800080d4:	6441a503          	lw	a0,1604(gp) # 819b4 <uxTopReadyPriority>
800080d8:	786010ef          	jal	8000985e <__clzsi2>
800080dc:	01f54513          	xor	a0,a0,31
800080e0:	45d1                	li	a1,20
800080e2:	02b505b3          	mul	a1,a0,a1
800080e6:	e8418513          	add	a0,gp,-380 # 811f4 <pxReadyTasksLists>
800080ea:	95aa                	add	a1,a1,a0
800080ec:	4188                	lw	a0,0(a1)
800080ee:	c10d                	beqz	a0,80008110 <.LBB14_7>
800080f0:	41c8                	lw	a0,4(a1)
800080f2:	4148                	lw	a0,4(a0)
800080f4:	00858613          	add	a2,a1,8
800080f8:	c1c8                	sw	a0,4(a1)
800080fa:	00c51563          	bne	a0,a2,80008104 <.LBB14_5>
800080fe:	4148                	lw	a0,4(a0)
80008100:	0591                	add	a1,a1,4
80008102:	c188                	sw	a0,0(a1)

80008104 <.LBB14_5>:
80008104:	4548                	lw	a0,12(a0)
80008106:	68a1a023          	sw	a0,1664(gp) # 819f0 <pxCurrentTCB>

8000810a <.LBB14_6>:
8000810a:	40b2                	lw	ra,12(sp)
}
8000810c:	0141                	add	sp,sp,16
8000810e:	8082                	ret

80008110 <.LBB14_7>:
        taskSELECT_HIGHEST_PRIORITY_TASK(); /*lint !e9079 void * is used as this macro is used with timers and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
80008110:	30047073          	csrc	mstatus,8
80008114:	9002                	ebreak

80008116 <.LBB14_8>:
80008116:	a001                	j	80008116 <.LBB14_8>

Disassembly of section .text.vTaskStartScheduler:

80008118 <vTaskStartScheduler>:
{
80008118:	1141                	add	sp,sp,-16
8000811a:	c606                	sw	ra,12(sp)
            xReturn = xTaskCreate( prvIdleTask,
8000811c:	8000d537          	lui	a0,0x8000d
80008120:	8c650513          	add	a0,a0,-1850 # 8000c8c6 <prvIdleTask>
80008124:	800115b7          	lui	a1,0x80011
80008128:	a8058593          	add	a1,a1,-1408 # 80010a80 <.L.str>
8000812c:	63418793          	add	a5,gp,1588 # 819a4 <xIdleTaskHandle>
80008130:	40000613          	li	a2,1024
80008134:	4681                	li	a3,0
80008136:	4701                	li	a4,0
80008138:	3925                	jal	80007d70 <xTaskCreate>
8000813a:	4585                	li	a1,1
            if( xReturn == pdPASS )
8000813c:	00b51363          	bne	a0,a1,80008142 <.LBB17_2>
                xReturn = xTimerCreateTimerTask();
80008140:	24a9                	jal	8000838a <xTimerCreateTimerTask>

80008142 <.LBB17_2>:
80008142:	55fd                	li	a1,-1
    if( xReturn == pdPASS )
80008144:	02b50763          	beq	a0,a1,80008172 <.LBB17_6>
80008148:	4585                	li	a1,1
8000814a:	00b51d63          	bne	a0,a1,80008164 <.LBB17_5>
        portDISABLE_INTERRUPTS();
8000814e:	30047073          	csrc	mstatus,8
80008152:	567d                	li	a2,-1
        xNextTaskUnblockTime = portMAX_DELAY;
80008154:	62c1a623          	sw	a2,1580(gp) # 8199c <xNextTaskUnblockTime>
        xSchedulerRunning = pdTRUE;
80008158:	60b1ac23          	sw	a1,1560(gp) # 81988 <xSchedulerRunning>
        xTickCount = ( TickType_t ) configINITIAL_TICK_COUNT;
8000815c:	6001aa23          	sw	zero,1556(gp) # 81984 <xTickCount>
        if( xPortStartScheduler() != pdFALSE )
80008160:	dfeff0ef          	jal	8000775e <xPortStartScheduler>

80008164 <.LBB17_5>:
    ( void ) uxTopUsedPriority;
80008164:	80005537          	lui	a0,0x80005
80008168:	f0452003          	lw	zero,-252(a0) # 80004f04 <uxTopUsedPriority>
8000816c:	40b2                	lw	ra,12(sp)
}
8000816e:	0141                	add	sp,sp,16
80008170:	8082                	ret

80008172 <.LBB17_6>:
        configASSERT( xReturn != errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY );
80008172:	30047073          	csrc	mstatus,8
80008176:	9002                	ebreak

80008178 <.LBB17_7>:
80008178:	a001                	j	80008178 <.LBB17_7>

Disassembly of section .text.xTaskGetTickCount:

8000817a <xTaskGetTickCount>:
        xTicks = xTickCount;
8000817a:	6141a503          	lw	a0,1556(gp) # 81984 <xTickCount>
    return xTicks;
8000817e:	8082                	ret

Disassembly of section .text.vTaskPlaceOnEventList:

80008180 <vTaskPlaceOnEventList>:
    configASSERT( pxEventList );
80008180:	c105                	beqz	a0,800081a0 <.LBB31_2>
80008182:	1141                	add	sp,sp,-16
80008184:	c606                	sw	ra,12(sp)
80008186:	c422                	sw	s0,8(sp)
80008188:	842e                	mv	s0,a1
    vListInsert( pxEventList, &( pxCurrentTCB->xEventListItem ) );
8000818a:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000818e:	05e1                	add	a1,a1,24
80008190:	e34ff0ef          	jal	800077c4 <vListInsert>
    prvAddCurrentTaskToDelayedList( xTicksToWait, pdTRUE );
80008194:	4585                	li	a1,1
80008196:	8522                	mv	a0,s0
80008198:	40b2                	lw	ra,12(sp)
8000819a:	4422                	lw	s0,8(sp)
8000819c:	0141                	add	sp,sp,16
8000819e:	bd09                	j	80007fb0 <prvAddCurrentTaskToDelayedList>

800081a0 <.LBB31_2>:
    configASSERT( pxEventList );
800081a0:	30047073          	csrc	mstatus,8
800081a4:	9002                	ebreak

800081a6 <.LBB31_3>:
800081a6:	a001                	j	800081a6 <.LBB31_3>

Disassembly of section .text.vTaskPlaceOnEventListRestricted:

800081a8 <vTaskPlaceOnEventListRestricted>:
        configASSERT( pxEventList );
800081a8:	cd15                	beqz	a0,800081e4 <.LBB33_2>
        listINSERT_END( pxEventList, &( pxCurrentTCB->xEventListItem ) );
800081aa:	4154                	lw	a3,4(a0)
800081ac:	6801a783          	lw	a5,1664(gp) # 819f0 <pxCurrentTCB>
800081b0:	cfd4                	sw	a3,28(a5)
800081b2:	469c                	lw	a5,8(a3)
800081b4:	6801a703          	lw	a4,1664(gp) # 819f0 <pxCurrentTCB>
800081b8:	d31c                	sw	a5,32(a4)
800081ba:	6801a703          	lw	a4,1664(gp) # 819f0 <pxCurrentTCB>
800081be:	0761                	add	a4,a4,24
800081c0:	c3d8                	sw	a4,4(a5)
800081c2:	6801a703          	lw	a4,1664(gp) # 819f0 <pxCurrentTCB>
800081c6:	0761                	add	a4,a4,24
800081c8:	c698                	sw	a4,8(a3)
800081ca:	6801a683          	lw	a3,1664(gp) # 819f0 <pxCurrentTCB>
800081ce:	d688                	sw	a0,40(a3)
800081d0:	4114                	lw	a3,0(a0)
800081d2:	0685                	add	a3,a3,1
        if( xWaitIndefinitely != pdFALSE )
800081d4:	00163713          	seqz	a4,a2
800081d8:	177d                	add	a4,a4,-1
800081da:	8dd9                	or	a1,a1,a4
        listINSERT_END( pxEventList, &( pxCurrentTCB->xEventListItem ) );
800081dc:	c114                	sw	a3,0(a0)
        prvAddCurrentTaskToDelayedList( xTicksToWait, xWaitIndefinitely );
800081de:	852e                	mv	a0,a1
800081e0:	85b2                	mv	a1,a2
800081e2:	b3f9                	j	80007fb0 <prvAddCurrentTaskToDelayedList>

800081e4 <.LBB33_2>:
        configASSERT( pxEventList );
800081e4:	30047073          	csrc	mstatus,8
800081e8:	9002                	ebreak

800081ea <.LBB33_3>:
800081ea:	a001                	j	800081ea <.LBB33_3>

Disassembly of section .text.vTaskInternalSetTimeOutState:

800081ec <vTaskInternalSetTimeOutState>:
    pxTimeOut->xOverflowCount = xNumOfOverflows;
800081ec:	6281a583          	lw	a1,1576(gp) # 81998 <xNumOfOverflows>
800081f0:	c10c                	sw	a1,0(a0)
    pxTimeOut->xTimeOnEntering = xTickCount;
800081f2:	6141a583          	lw	a1,1556(gp) # 81984 <xTickCount>
800081f6:	c14c                	sw	a1,4(a0)
}
800081f8:	8082                	ret

Disassembly of section .text.xTaskCheckForTimeOut:

800081fa <xTaskCheckForTimeOut>:
    configASSERT( pxTimeOut );
800081fa:	c91d                	beqz	a0,80008230 <.LBB38_6>
800081fc:	30047073          	csrc	mstatus,8
    configASSERT( pxTicksToWait );
80008200:	cd85                	beqz	a1,80008238 <.LBB38_8>
        if( xSchedulerRunning != pdFALSE )
80008202:	6181a603          	lw	a2,1560(gp) # 81988 <xSchedulerRunning>
80008206:	ca01                	beqz	a2,80008216 <.LBB38_4>
            ( pxCurrentTCB->uxCriticalNesting )++;
80008208:	6801a683          	lw	a3,1664(gp) # 819f0 <pxCurrentTCB>
8000820c:	42f8                	lw	a4,68(a3)
8000820e:	0705                	add	a4,a4,1
80008210:	c2f8                	sw	a4,68(a3)
            if( pxCurrentTCB->uxCriticalNesting == 1 )
80008212:	6801a003          	lw	zero,1664(gp) # 819f0 <pxCurrentTCB>

80008216 <.LBB38_4>:
        const TickType_t xConstTickCount = xTickCount;
80008216:	6141a603          	lw	a2,1556(gp) # 81984 <xTickCount>
        const TickType_t xElapsedTime = xConstTickCount - pxTimeOut->xTimeOnEntering;
8000821a:	4154                	lw	a3,4(a0)
            if( pxCurrentTCB->ucDelayAborted != ( uint8_t ) pdFALSE )
8000821c:	6801a783          	lw	a5,1664(gp) # 819f0 <pxCurrentTCB>
80008220:	05d7c783          	lbu	a5,93(a5)
80008224:	cf81                	beqz	a5,8000823c <.LBB38_10>
                pxCurrentTCB->ucDelayAborted = pdFALSE;
80008226:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000822a:	04050ea3          	sb	zero,93(a0)
8000822e:	a091                	j	80008272 <.LBB38_16>

80008230 <.LBB38_6>:
    configASSERT( pxTimeOut );
80008230:	30047073          	csrc	mstatus,8
80008234:	9002                	ebreak

80008236 <.LBB38_7>:
80008236:	a001                	j	80008236 <.LBB38_7>

80008238 <.LBB38_8>:
    configASSERT( pxTicksToWait );
80008238:	9002                	ebreak

8000823a <.LBB38_9>:
8000823a:	a001                	j	8000823a <.LBB38_9>

8000823c <.LBB38_10>:
            if( *pxTicksToWait == portMAX_DELAY )
8000823c:	4198                	lw	a4,0(a1)
8000823e:	57fd                	li	a5,-1
80008240:	04f70e63          	beq	a4,a5,8000829c <.LBB38_22>
        if( ( xNumOfOverflows != pxTimeOut->xOverflowCount ) && ( xConstTickCount >= pxTimeOut->xTimeOnEntering ) ) /*lint !e525 Indentation preferred as is to make code within pre-processor directives clearer. */
80008244:	6281a803          	lw	a6,1576(gp) # 81998 <xNumOfOverflows>
80008248:	411c                	lw	a5,0(a0)
8000824a:	00f80463          	beq	a6,a5,80008252 <.LBB38_13>
8000824e:	02d67063          	bgeu	a2,a3,8000826e <.LBB38_15>

80008252 <.LBB38_13>:
80008252:	8e15                	sub	a2,a2,a3
        else if( xElapsedTime < *pxTicksToWait ) /*lint !e961 Explicit casting is only redundant with some compilers, whereas others require it to prevent integer conversion errors. */
80008254:	00e67d63          	bgeu	a2,a4,8000826e <.LBB38_15>
            *pxTicksToWait -= xElapsedTime;
80008258:	8f11                	sub	a4,a4,a2
8000825a:	c198                	sw	a4,0(a1)
    pxTimeOut->xOverflowCount = xNumOfOverflows;
8000825c:	6281a583          	lw	a1,1576(gp) # 81998 <xNumOfOverflows>
80008260:	c10c                	sw	a1,0(a0)
    pxTimeOut->xTimeOnEntering = xTickCount;
80008262:	6141a583          	lw	a1,1556(gp) # 81984 <xTickCount>
80008266:	4601                	li	a2,0
80008268:	c14c                	sw	a1,4(a0)
8000826a:	4501                	li	a0,0
8000826c:	a021                	j	80008274 <.LBB38_17>

8000826e <.LBB38_15>:
8000826e:	0005a023          	sw	zero,0(a1)

80008272 <.LBB38_16>:
80008272:	4505                	li	a0,1

80008274 <.LBB38_17>:
        if( xSchedulerRunning != pdFALSE )
80008274:	6181a583          	lw	a1,1560(gp) # 81988 <xSchedulerRunning>
80008278:	cd91                	beqz	a1,80008294 <.LBB38_20>
            if( pxCurrentTCB->uxCriticalNesting > 0U )
8000827a:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000827e:	4270                	lw	a2,68(a2)
80008280:	ca11                	beqz	a2,80008294 <.LBB38_20>
                ( pxCurrentTCB->uxCriticalNesting )--;
80008282:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
80008286:	4274                	lw	a3,68(a2)
80008288:	16fd                	add	a3,a3,-1
8000828a:	c274                	sw	a3,68(a2)
                if( pxCurrentTCB->uxCriticalNesting == 0U )
8000828c:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80008290:	41ec                	lw	a1,68(a1)
80008292:	c191                	beqz	a1,80008296 <.LBB38_21>

80008294 <.LBB38_20>:
    return xReturn;
80008294:	8082                	ret

80008296 <.LBB38_21>:
                    portENABLE_INTERRUPTS();
80008296:	30046073          	csrs	mstatus,8
    return xReturn;
8000829a:	8082                	ret

8000829c <.LBB38_22>:
8000829c:	4501                	li	a0,0
8000829e:	bfd9                	j	80008274 <.LBB38_17>

Disassembly of section .text.xTaskGetSchedulerState:

800082a0 <xTaskGetSchedulerState>:
        if( xSchedulerRunning == pdFALSE )
800082a0:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
800082a4:	c519                	beqz	a0,800082b2 <.LBB44_2>
            if( uxSchedulerSuspended == ( UBaseType_t ) pdFALSE )
800082a6:	64c1a503          	lw	a0,1612(gp) # 819bc <uxSchedulerSuspended>
800082aa:	00153513          	seqz	a0,a0
800082ae:	0506                	sll	a0,a0,0x1
        return xReturn;
800082b0:	8082                	ret

800082b2 <.LBB44_2>:
800082b2:	4505                	li	a0,1
800082b4:	8082                	ret

Disassembly of section .text.xTaskPriorityInherit:

800082b6 <xTaskPriorityInherit>:
        if( pxMutexHolder != NULL )
800082b6:	c531                	beqz	a0,80008302 <.LBB45_7>
            if( pxMutexHolderTCB->uxPriority < pxCurrentTCB->uxPriority )
800082b8:	554c                	lw	a1,44(a0)
800082ba:	6801a683          	lw	a3,1664(gp) # 819f0 <pxCurrentTCB>
800082be:	56d4                	lw	a3,44(a3)
800082c0:	02d5fb63          	bgeu	a1,a3,800082f6 <.LBB45_6>
                if( ( listGET_LIST_ITEM_VALUE( &( pxMutexHolderTCB->xEventListItem ) ) & taskEVENT_LIST_ITEM_VALUE_IN_USE ) == 0UL )
800082c4:	4d10                	lw	a2,24(a0)
800082c6:	00064963          	bltz	a2,800082d8 <.LBB45_4>
                    listSET_LIST_ITEM_VALUE( &( pxMutexHolderTCB->xEventListItem ), ( TickType_t ) configMAX_PRIORITIES - ( TickType_t ) pxCurrentTCB->uxPriority ); /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
800082ca:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
800082ce:	5650                	lw	a2,44(a2)
800082d0:	02000693          	li	a3,32
800082d4:	8e91                	sub	a3,a3,a2
800082d6:	cd14                	sw	a3,24(a0)

800082d8 <.LBB45_4>:
                if( listIS_CONTAINED_WITHIN( &( pxReadyTasksLists[ pxMutexHolderTCB->uxPriority ] ), &( pxMutexHolderTCB->xStateListItem ) ) != pdFALSE )
800082d8:	4950                	lw	a2,20(a0)
800082da:	46d1                	li	a3,20
800082dc:	02d585b3          	mul	a1,a1,a3
800082e0:	e8418693          	add	a3,gp,-380 # 811f4 <pxReadyTasksLists>
800082e4:	95b6                	add	a1,a1,a3
800082e6:	00b60f63          	beq	a2,a1,80008304 <.LBB45_8>
                    pxMutexHolderTCB->uxPriority = pxCurrentTCB->uxPriority;
800082ea:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
800082ee:	55cc                	lw	a1,44(a1)
800082f0:	d54c                	sw	a1,44(a0)
800082f2:	4505                	li	a0,1
        return xReturn;
800082f4:	8082                	ret

800082f6 <.LBB45_6>:
                if( pxMutexHolderTCB->uxBasePriority < pxCurrentTCB->uxPriority )
800082f6:	4928                	lw	a0,80(a0)
800082f8:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
800082fc:	55cc                	lw	a1,44(a1)
800082fe:	00b53533          	sltu	a0,a0,a1

80008302 <.LBB45_7>:
        return xReturn;
80008302:	8082                	ret

80008304 <.LBB45_8>:
80008304:	1141                	add	sp,sp,-16
80008306:	c606                	sw	ra,12(sp)
80008308:	c422                	sw	s0,8(sp)
8000830a:	c226                	sw	s1,4(sp)
8000830c:	00450413          	add	s0,a0,4
80008310:	84aa                	mv	s1,a0
                    if( uxListRemove( &( pxMutexHolderTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
80008312:	8522                	mv	a0,s0
80008314:	0c0040ef          	jal	8000c3d4 <uxListRemove>
80008318:	85a6                	mv	a1,s1
8000831a:	ed01                	bnez	a0,80008332 <.LBB45_10>
                        portRESET_READY_PRIORITY( pxMutexHolderTCB->uxPriority, uxTopReadyPriority );
8000831c:	55c8                	lw	a0,44(a1)
8000831e:	6441a683          	lw	a3,1604(gp) # 819b4 <uxTopReadyPriority>
80008322:	4705                	li	a4,1
80008324:	00a71533          	sll	a0,a4,a0
80008328:	fff54513          	not	a0,a0
8000832c:	8d75                	and	a0,a0,a3
8000832e:	64a1a223          	sw	a0,1604(gp) # 819b4 <uxTopReadyPriority>

80008332 <.LBB45_10>:
                    pxMutexHolderTCB->uxPriority = pxCurrentTCB->uxPriority;
80008332:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
80008336:	5550                	lw	a2,44(a0)
80008338:	d5d0                	sw	a2,44(a1)
                    prvAddTaskToReadyList( pxMutexHolderTCB );
8000833a:	6441a703          	lw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000833e:	4505                	li	a0,1
80008340:	00c517b3          	sll	a5,a0,a2
80008344:	8f5d                	or	a4,a4,a5
80008346:	64e1a223          	sw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000834a:	46d1                	li	a3,20
8000834c:	02d60633          	mul	a2,a2,a3
80008350:	e8418693          	add	a3,gp,-380 # 811f4 <pxReadyTasksLists>
80008354:	9636                	add	a2,a2,a3
80008356:	4254                	lw	a3,4(a2)
80008358:	4698                	lw	a4,8(a3)
8000835a:	c594                	sw	a3,8(a1)
8000835c:	c5d8                	sw	a4,12(a1)
8000835e:	c340                	sw	s0,4(a4)
80008360:	c680                	sw	s0,8(a3)
80008362:	c9d0                	sw	a2,20(a1)
80008364:	420c                	lw	a1,0(a2)
80008366:	0585                	add	a1,a1,1
80008368:	c20c                	sw	a1,0(a2)
8000836a:	40b2                	lw	ra,12(sp)
8000836c:	4422                	lw	s0,8(sp)
8000836e:	4492                	lw	s1,4(sp)
                }
80008370:	0141                	add	sp,sp,16
        return xReturn;
80008372:	8082                	ret

Disassembly of section .text.pvTaskIncrementMutexHeldCount:

80008374 <pvTaskIncrementMutexHeldCount>:
        if( pxCurrentTCB != NULL )
80008374:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
80008378:	c591                	beqz	a1,80008384 <.LBB49_2>
            ( pxCurrentTCB->uxMutexesHeld )++;
8000837a:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000837e:	49f0                	lw	a2,84(a1)
80008380:	0605                	add	a2,a2,1
80008382:	c9f0                	sw	a2,84(a1)

80008384 <.LBB49_2>:
        return pxCurrentTCB;
80008384:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
80008388:	8082                	ret

Disassembly of section .text.xTimerCreateTimerTask:

8000838a <xTimerCreateTimerTask>:
                                       TimerCallbackFunction_t pxCallbackFunction,
                                       Timer_t * pxNewTimer ) PRIVILEGED_FUNCTION;
/*-----------------------------------------------------------*/

    BaseType_t xTimerCreateTimerTask( void )
    {
8000838a:	1141                	add	sp,sp,-16
8000838c:	c606                	sw	ra,12(sp)

        /* This function is called when the scheduler is started if
         * configUSE_TIMERS is set to 1.  Check that the infrastructure used by the
         * timer service task has been created/initialised.  If timers have already
         * been created then the initialisation will already have been performed. */
        prvCheckForValidListAndQueue();
8000838e:	11d040ef          	jal	8000ccaa <prvCheckForValidListAndQueue>

        if( xTimerQueue != NULL )
80008392:	6101a503          	lw	a0,1552(gp) # 81980 <xTimerQueue>
80008396:	c115                	beqz	a0,800083ba <.LBB0_3>
                        xReturn = pdPASS;
                    }
                }
            #else /* if ( configSUPPORT_STATIC_ALLOCATION == 1 ) */
                {
                    xReturn = xTaskCreate( prvTimerTask,
80008398:	80008537          	lui	a0,0x80008
8000839c:	3c250513          	add	a0,a0,962 # 800083c2 <prvTimerTask>
800083a0:	1a220593          	add	a1,tp,418 # 1a2 <default_isr_51+0x52>
800083a4:	60c18793          	add	a5,gp,1548 # 8197c <xTimerTaskHandle>
800083a8:	40000613          	li	a2,1024
800083ac:	477d                	li	a4,31
800083ae:	4681                	li	a3,0
800083b0:	32c1                	jal	80007d70 <xTaskCreate>
        else
        {
            mtCOVERAGE_TEST_MARKER();
        }

        configASSERT( xReturn );
800083b2:	c501                	beqz	a0,800083ba <.LBB0_3>
800083b4:	40b2                	lw	ra,12(sp)
        return xReturn;
800083b6:	0141                	add	sp,sp,16
800083b8:	8082                	ret

800083ba <.LBB0_3>:
        configASSERT( xReturn );
800083ba:	30047073          	csrc	mstatus,8
800083be:	9002                	ebreak

800083c0 <.LBB0_4>:
800083c0:	a001                	j	800083c0 <.LBB0_4>

Disassembly of section .text.prvTimerTask:

800083c2 <prvTimerTask>:
        pxTimer->pxCallbackFunction( ( TimerHandle_t ) pxTimer );
    }
/*-----------------------------------------------------------*/

    static portTASK_FUNCTION( prvTimerTask, pvParameters )
    {
800083c2:	715d                	add	sp,sp,-80
800083c4:	c686                	sw	ra,76(sp)
800083c6:	c4a2                	sw	s0,72(sp)
800083c8:	c2a6                	sw	s1,68(sp)
800083ca:	c0ca                	sw	s2,64(sp)
800083cc:	de4e                	sw	s3,60(sp)
800083ce:	dc52                	sw	s4,56(sp)
800083d0:	da56                	sw	s5,52(sp)
800083d2:	d85a                	sw	s6,48(sp)
800083d4:	d65e                	sw	s7,44(sp)
800083d6:	d462                	sw	s8,40(sp)
800083d8:	d266                	sw	s9,36(sp)
800083da:	d06a                	sw	s10,32(sp)
800083dc:	4b21                	li	s6,8
800083de:	80005537          	lui	a0,0x80005
800083e2:	f0850b93          	add	s7,a0,-248 # 80004f08 <.LJTI2_0>
800083e6:	67c18c13          	add	s8,gp,1660 # 819ec <pxCurrentTimerList>
800083ea:	66c18c93          	add	s9,gp,1644 # 819dc <pxOverflowTimerList>

800083ee <.LBB2_1>:
         * the timer with the nearest expiry time will expire.  If there are no
         * active timers then just set the next expire time to 0.  That will cause
         * this task to unblock when the tick count overflows, at which point the
         * timer lists will be switched and the next expiry time can be
         * re-assessed.  */
        *pxListWasEmpty = listLIST_IS_EMPTY( pxCurrentTimerList );
800083ee:	67c1a503          	lw	a0,1660(gp) # 819ec <pxCurrentTimerList>
800083f2:	4104                	lw	s1,0(a0)

        if( *pxListWasEmpty == pdFALSE )
800083f4:	c481                	beqz	s1,800083fc <.LBB2_3>
        {
            xNextExpireTime = listGET_ITEM_VALUE_OF_HEAD_ENTRY( pxCurrentTimerList );
800083f6:	4548                	lw	a0,12(a0)
800083f8:	4100                	lw	s0,0(a0)
800083fa:	a011                	j	800083fe <.LBB2_4>

800083fc <.LBB2_3>:
800083fc:	4401                	li	s0,0

800083fe <.LBB2_4>:
        vTaskSuspendAll();
800083fe:	36e040ef          	jal	8000c76c <vTaskSuspendAll>
            xTimeNow = prvSampleTimeNow( &xTimerListsWereSwitched );
80008402:	0808                	add	a0,sp,16
80008404:	0f1040ef          	jal	8000ccf4 <prvSampleTimeNow>
            if( xTimerListsWereSwitched == pdFALSE )
80008408:	45c2                	lw	a1,16(sp)
8000840a:	c581                	beqz	a1,80008412 <.LBB2_6>
                ( void ) xTaskResumeAll();
8000840c:	36c040ef          	jal	8000c778 <xTaskResumeAll>
80008410:	a0a1                	j	80008458 <.LBB2_16>

80008412 <.LBB2_6>:
                if( ( xListWasEmpty == pdFALSE ) && ( xNextExpireTime <= xTimeNow ) )
80008412:	c899                	beqz	s1,80008428 <.LBB2_9>
80008414:	00856a63          	bltu	a0,s0,80008428 <.LBB2_9>
80008418:	84aa                	mv	s1,a0
                    ( void ) xTaskResumeAll();
8000841a:	35e040ef          	jal	8000c778 <xTaskResumeAll>
                    prvProcessExpiredTimer( xNextExpireTime, xTimeNow );
8000841e:	8522                	mv	a0,s0
80008420:	85a6                	mv	a1,s1
80008422:	129040ef          	jal	8000cd4a <prvProcessExpiredTimer>
80008426:	a80d                	j	80008458 <.LBB2_16>

80008428 <.LBB2_9>:
                    if( xListWasEmpty != pdFALSE )
80008428:	c099                	beqz	s1,8000842e <.LBB2_11>
8000842a:	4601                	li	a2,0
8000842c:	a031                	j	80008438 <.LBB2_12>

8000842e <.LBB2_11>:
                        xListWasEmpty = listLIST_IS_EMPTY( pxOverflowTimerList );
8000842e:	66c1a583          	lw	a1,1644(gp) # 819dc <pxOverflowTimerList>
80008432:	418c                	lw	a1,0(a1)
80008434:	0015b613          	seqz	a2,a1

80008438 <.LBB2_12>:
                    vQueueWaitForMessageRestricted( xTimerQueue, ( xNextExpireTime - xTimeNow ), xListWasEmpty );
80008438:	6101a583          	lw	a1,1552(gp) # 81980 <xTimerQueue>
8000843c:	8c09                	sub	s0,s0,a0
8000843e:	852e                	mv	a0,a1
80008440:	85a2                	mv	a1,s0
80008442:	38d9                	jal	80007d18 <vQueueWaitForMessageRestricted>
                    if( xTaskResumeAll() == pdFALSE )
80008444:	334040ef          	jal	8000c778 <xTaskResumeAll>
80008448:	e901                	bnez	a0,80008458 <.LBB2_16>
                        portYIELD_WITHIN_API();
8000844a:	00000073          	ecall
8000844e:	a029                	j	80008458 <.LBB2_16>

80008450 <.LBB2_14>:
80008450:	4308                	lw	a0,0(a4)

80008452 <.LBB2_15>:
80008452:	85ca                	mv	a1,s2
80008454:	b70ff0ef          	jal	800077c4 <vListInsert>

80008458 <.LBB2_16>:
        DaemonTaskMessage_t xMessage;
        Timer_t * pxTimer;
        BaseType_t xTimerListsWereSwitched;
        TickType_t xTimeNow;

        while( xQueueReceive( xTimerQueue, &xMessage, tmrNO_DELAY ) != pdFAIL ) /*lint !e603 xMessage does not have to be initialised as it is passed out, not in, and it is not used unless xQueueReceive() returns pdTRUE. */
80008458:	6101a503          	lw	a0,1552(gp) # 81980 <xTimerQueue>
8000845c:	080c                	add	a1,sp,16
8000845e:	4601                	li	a2,0
80008460:	f80ff0ef          	jal	80007be0 <xQueueReceive>
80008464:	d549                	beqz	a0,800083ee <.LBB2_1>
        {
            #if ( INCLUDE_xTimerPendFunctionCall == 1 )
                {
                    /* Negative commands are pended function calls rather than timer
                     * commands. */
                    if( xMessage.xMessageID < ( BaseType_t ) 0 )
80008466:	4542                	lw	a0,16(sp)
80008468:	00055963          	bgez	a0,8000847a <.LBB2_19>
                        /* The timer uses the xCallbackParameters member to request a
                         * callback be executed.  Check the callback is not NULL. */
                        configASSERT( pxCallback );

                        /* Call the function. */
                        pxCallback->pxCallbackFunction( pxCallback->pvParameter1, pxCallback->ulParameter2 );
8000846c:	4652                	lw	a2,20(sp)
8000846e:	4562                	lw	a0,24(sp)
80008470:	45f2                	lw	a1,28(sp)
80008472:	9602                	jalr	a2
                }
            #endif /* INCLUDE_xTimerPendFunctionCall */

            /* Commands that are positive are timer commands rather than pended
             * function calls. */
            if( xMessage.xMessageID >= ( BaseType_t ) 0 )
80008474:	4542                	lw	a0,16(sp)
80008476:	fe0541e3          	bltz	a0,80008458 <.LBB2_16>

8000847a <.LBB2_19>:
            {
                /* The messages uses the xTimerParameters member to work on a
                 * software timer. */
                pxTimer = xMessage.u.xTimerParameters.pxTimer;
8000847a:	4462                	lw	s0,24(sp)

                if( listIS_CONTAINED_WITHIN( NULL, &( pxTimer->xTimerListItem ) ) == pdFALSE ) /*lint !e961. The cast is only redundant when NULL is passed into the macro. */
8000847c:	4848                	lw	a0,20(s0)
8000847e:	00440913          	add	s2,s0,4
80008482:	c501                	beqz	a0,8000848a <.LBB2_21>
                {
                    /* The timer is in a list, remove it. */
                    ( void ) uxListRemove( &( pxTimer->xTimerListItem ) );
80008484:	854a                	mv	a0,s2
80008486:	74f030ef          	jal	8000c3d4 <uxListRemove>

8000848a <.LBB2_21>:
                 *  it must be present in the function call.  prvSampleTimeNow() must be
                 *  called after the message is received from xTimerQueue so there is no
                 *  possibility of a higher priority task adding a message to the message
                 *  queue with a time that is ahead of the timer daemon task (because it
                 *  pre-empted the timer daemon task after the xTimeNow value was set). */
                xTimeNow = prvSampleTimeNow( &xTimerListsWereSwitched );
8000848a:	0068                	add	a0,sp,12
8000848c:	069040ef          	jal	8000ccf4 <prvSampleTimeNow>

                switch( xMessage.xMessageID )
80008490:	45c2                	lw	a1,16(sp)
80008492:	15fd                	add	a1,a1,-1
80008494:	fcbb62e3          	bltu	s6,a1,80008458 <.LBB2_16>
80008498:	8d2a                	mv	s10,a0
8000849a:	058a                	sll	a1,a1,0x2
8000849c:	95de                	add	a1,a1,s7
8000849e:	4188                	lw	a0,0(a1)
800084a0:	8502                	jr	a0

800084a2 <.LBB2_23>:
                    case tmrCOMMAND_START:
                    case tmrCOMMAND_START_FROM_ISR:
                    case tmrCOMMAND_RESET:
                    case tmrCOMMAND_RESET_FROM_ISR:
                        /* Start or restart a timer. */
                        pxTimer->ucStatus |= tmrSTATUS_IS_ACTIVE;
800084a2:	02844583          	lbu	a1,40(s0)

                        if( prvInsertTimerInActiveList( pxTimer, xMessage.u.xTimerParameters.xMessageValue + pxTimer->xTimerPeriodInTicks, xTimeNow, xMessage.u.xTimerParameters.xMessageValue ) != pdFALSE )
800084a6:	4652                	lw	a2,20(sp)
800084a8:	4c08                	lw	a0,24(s0)
                        pxTimer->ucStatus |= tmrSTATUS_IS_ACTIVE;
800084aa:	0015e693          	or	a3,a1,1
800084ae:	02d40423          	sb	a3,40(s0)
                        if( prvInsertTimerInActiveList( pxTimer, xMessage.u.xTimerParameters.xMessageValue + pxTimer->xTimerPeriodInTicks, xTimeNow, xMessage.u.xTimerParameters.xMessageValue ) != pdFALSE )
800084b2:	00c506b3          	add	a3,a0,a2
        listSET_LIST_ITEM_VALUE( &( pxTimer->xTimerListItem ), xNextExpiryTime );
800084b6:	c054                	sw	a3,4(s0)
        listSET_LIST_ITEM_OWNER( &( pxTimer->xTimerListItem ), pxTimer );
800084b8:	c800                	sw	s0,16(s0)
        if( xNextExpiryTime <= xTimeNow )
800084ba:	00dd7963          	bgeu	s10,a3,800084cc <.LBB2_26>
800084be:	8762                	mv	a4,s8
            if( ( xTimeNow < xCommandTime ) && ( xNextExpiryTime >= xCommandTime ) )
800084c0:	f8cd78e3          	bgeu	s10,a2,80008450 <.LBB2_14>
800084c4:	8762                	mv	a4,s8
800084c6:	00c6f863          	bgeu	a3,a2,800084d6 <.LBB2_27>
800084ca:	b759                	j	80008450 <.LBB2_14>

800084cc <.LBB2_26>:
            if( ( ( TickType_t ) ( xTimeNow - xCommandTime ) ) >= pxTimer->xTimerPeriodInTicks ) /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
800084cc:	40cd0633          	sub	a2,s10,a2
800084d0:	8766                	mv	a4,s9
800084d2:	f6a66fe3          	bltu	a2,a0,80008450 <.LBB2_14>

800084d6 <.LBB2_27>:
                        {
                            /* The timer expired before it was added to the active
                             * timer list.  Process it now. */
                            if( ( pxTimer->ucStatus & tmrSTATUS_IS_AUTORELOAD ) != 0 )
800084d6:	0045f613          	and	a2,a1,4
800084da:	e221                	bnez	a2,8000851a <.LBB2_35>
                            {
                                prvReloadTimer( pxTimer, xMessage.u.xTimerParameters.xMessageValue + pxTimer->xTimerPeriodInTicks, xTimeNow );
                            }
                            else
                            {
                                pxTimer->ucStatus &= ~tmrSTATUS_IS_ACTIVE;
800084dc:	0fa5f513          	and	a0,a1,250
800084e0:	02a40423          	sb	a0,40(s0)
800084e4:	a049                	j	80008566 <.LBB2_46>

800084e6 <.LBB2_29>:
                        pxTimer->ucStatus &= ~tmrSTATUS_IS_ACTIVE;
                        break;

                    case tmrCOMMAND_CHANGE_PERIOD:
                    case tmrCOMMAND_CHANGE_PERIOD_FROM_ISR:
                        pxTimer->ucStatus |= tmrSTATUS_IS_ACTIVE;
800084e6:	02844583          	lbu	a1,40(s0)
                        pxTimer->xTimerPeriodInTicks = xMessage.u.xTimerParameters.xMessageValue;
800084ea:	4552                	lw	a0,20(sp)
                        pxTimer->ucStatus |= tmrSTATUS_IS_ACTIVE;
800084ec:	0015e593          	or	a1,a1,1
800084f0:	02b40423          	sb	a1,40(s0)
                        pxTimer->xTimerPeriodInTicks = xMessage.u.xTimerParameters.xMessageValue;
800084f4:	cc08                	sw	a0,24(s0)
                        configASSERT( ( pxTimer->xTimerPeriodInTicks > 0 ) );
800084f6:	cd25                	beqz	a0,8000856e <.LBB2_47>
                         * be longer or shorter than the old one.  The command time is
                         * therefore set to the current time, and as the period cannot
                         * be zero the next expiry time can only be in the future,
                         * meaning (unlike for the xTimerStart() case above) there is
                         * no fail case that needs to be handled here. */
                        ( void ) prvInsertTimerInActiveList( pxTimer, ( xTimeNow + pxTimer->xTimerPeriodInTicks ), xTimeNow, xTimeNow );
800084f8:	01a505b3          	add	a1,a0,s10
        listSET_LIST_ITEM_VALUE( &( pxTimer->xTimerListItem ), xNextExpiryTime );
800084fc:	c04c                	sw	a1,4(s0)
        listSET_LIST_ITEM_OWNER( &( pxTimer->xTimerListItem ), pxTimer );
800084fe:	c800                	sw	s0,16(s0)
80008500:	8562                	mv	a0,s8
80008502:	00bd6363          	bltu	s10,a1,80008508 <.LBB2_32>
80008506:	8566                	mv	a0,s9

80008508 <.LBB2_32>:
80008508:	4108                	lw	a0,0(a0)
8000850a:	b7a1                	j	80008452 <.LBB2_15>

8000850c <.LBB2_33>:
                        pxTimer->ucStatus &= ~tmrSTATUS_IS_ACTIVE;
8000850c:	02844503          	lbu	a0,40(s0)

80008510 <.LBB2_34>:
80008510:	0fe57513          	and	a0,a0,254
80008514:	02a40423          	sb	a0,40(s0)
80008518:	b781                	j	80008458 <.LBB2_16>

8000851a <.LBB2_35>:
                                prvReloadTimer( pxTimer, xMessage.u.xTimerParameters.xMessageValue + pxTimer->xTimerPeriodInTicks, xTimeNow );
8000851a:	45d2                	lw	a1,20(sp)
8000851c:	95aa                	add	a1,a1,a0
8000851e:	a811                	j	80008532 <.LBB2_38>

80008520 <.LBB2_36>:
            if( ( ( TickType_t ) ( xTimeNow - xCommandTime ) ) >= pxTimer->xTimerPeriodInTicks ) /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
80008520:	40bd05b3          	sub	a1,s10,a1
80008524:	02a5ec63          	bltu	a1,a0,8000855c <.LBB2_44>

80008528 <.LBB2_37>:
            pxTimer->pxCallbackFunction( ( TimerHandle_t ) pxTimer );
80008528:	500c                	lw	a1,32(s0)
8000852a:	8522                	mv	a0,s0
8000852c:	9582                	jalr	a1
        while ( prvInsertTimerInActiveList( pxTimer, ( xExpiredTime + pxTimer->xTimerPeriodInTicks ), xTimeNow, xExpiredTime ) != pdFALSE )
8000852e:	4c08                	lw	a0,24(s0)
80008530:	85a6                	mv	a1,s1

80008532 <.LBB2_38>:
80008532:	00a584b3          	add	s1,a1,a0
        listSET_LIST_ITEM_VALUE( &( pxTimer->xTimerListItem ), xNextExpiryTime );
80008536:	c044                	sw	s1,4(s0)
        listSET_LIST_ITEM_OWNER( &( pxTimer->xTimerListItem ), pxTimer );
80008538:	c800                	sw	s0,16(s0)
8000853a:	fe9d73e3          	bgeu	s10,s1,80008520 <.LBB2_36>
            if( ( xTimeNow < xCommandTime ) && ( xNextExpiryTime >= xCommandTime ) )
8000853e:	00bd7463          	bgeu	s10,a1,80008546 <.LBB2_41>
80008542:	feb4f3e3          	bgeu	s1,a1,80008528 <.LBB2_37>

80008546 <.LBB2_41>:
80008546:	8562                	mv	a0,s8
80008548:	a819                	j	8000855e <.LBB2_45>

8000854a <.LBB2_42>:
                        #if ( configSUPPORT_DYNAMIC_ALLOCATION == 1 )
                            {
                                /* The timer has already been removed from the active list,
                                 * just free up the memory if the memory was dynamically
                                 * allocated. */
                                if( ( pxTimer->ucStatus & tmrSTATUS_IS_STATICALLY_ALLOCATED ) == ( uint8_t ) 0 )
8000854a:	02844503          	lbu	a0,40(s0)
8000854e:	00257593          	and	a1,a0,2
80008552:	fddd                	bnez	a1,80008510 <.LBB2_34>
                                {
                                    vPortFree( pxTimer );
80008554:	8522                	mv	a0,s0
80008556:	5c3030ef          	jal	8000c318 <vPortFree>
8000855a:	bdfd                	j	80008458 <.LBB2_16>

8000855c <.LBB2_44>:
8000855c:	8566                	mv	a0,s9

8000855e <.LBB2_45>:
8000855e:	4108                	lw	a0,0(a0)
80008560:	85ca                	mv	a1,s2
80008562:	a62ff0ef          	jal	800077c4 <vListInsert>

80008566 <.LBB2_46>:
                            pxTimer->pxCallbackFunction( ( TimerHandle_t ) pxTimer );
80008566:	500c                	lw	a1,32(s0)
80008568:	8522                	mv	a0,s0
8000856a:	9582                	jalr	a1
8000856c:	b5f5                	j	80008458 <.LBB2_16>

8000856e <.LBB2_47>:
                        configASSERT( ( pxTimer->xTimerPeriodInTicks > 0 ) );
8000856e:	30047073          	csrc	mstatus,8
80008572:	9002                	ebreak

80008574 <.LBB2_48>:
80008574:	a001                	j	80008574 <.LBB2_48>

Disassembly of section .text._clean_up:

80008576 <_clean_up>:
#define MAIN_ENTRY main
#endif
extern int MAIN_ENTRY(void);

__attribute__((weak)) void _clean_up(void)
{
80008576:	4501                	li	a0,0
80008578:	4585                	li	a1,1
8000857a:	05ae                	sll	a1,a1,0xb
 * @brief   Disable IRQ from interrupt controller
 *
 */
ATTR_ALWAYS_INLINE static inline void disable_irq_from_intc(void)
{
    clear_csr(CSR_MIE, CSR_MIE_MEIE_MASK);
8000857c:	3045b073          	csrc	mie,a1
80008580:	e42005b7          	lui	a1,0xe4200
                                                           uint32_t threshold)
{
    volatile uint32_t *threshold_ptr = (volatile uint32_t *) (base +
                                                              HPM_PLIC_THRESHOLD_OFFSET +
                                                              (target << HPM_PLIC_THRESHOLD_SHIFT_PER_TARGET));
    *threshold_ptr = threshold;
80008584:	0005a023          	sw	zero,0(a1) # e4200000 <__XPI0_segment_end__+0x64100000>
80008588:	08000613          	li	a2,128

8000858c <.LBB0_1>:
                                                          uint32_t irq)
{
    volatile uint32_t *claim_addr = (volatile uint32_t *) (base +
                                                           HPM_PLIC_CLAIM_OFFSET +
                                                           (target << HPM_PLIC_CLAIM_SHIFT_PER_TARGET));
    *claim_addr = irq;
8000858c:	c1c8                	sw	a0,4(a1)
    /* clean up plic, it will help while debugging */
    disable_irq_from_intc();
    intc_m_set_threshold(0);
    for (uint32_t irq = 0; irq < 128; irq++) {
8000858e:	0505                	add	a0,a0,1
80008590:	fec51ee3          	bne	a0,a2,8000858c <.LBB0_1>
80008594:	e4002537          	lui	a0,0xe4002
80008598:	01050593          	add	a1,a0,16 # e4002010 <__XPI0_segment_end__+0x63f02010>

8000859c <.LBB0_3>:
        intc_m_complete_irq(irq);
    }
    /* clear any bits left in plic enable register */
    for (uint32_t i = 0; i < 4; i++) {
        *(volatile uint32_t *)(HPM_PLIC_BASE + HPM_PLIC_ENABLE_OFFSET + (i << 2)) = 0;
8000859c:	00052023          	sw	zero,0(a0)
    for (uint32_t i = 0; i < 4; i++) {
800085a0:	0511                	add	a0,a0,4
800085a2:	feb51de3          	bne	a0,a1,8000859c <.LBB0_3>
    }
}
800085a6:	8082                	ret

Disassembly of section .text._init:

800085a8 <_init>:
void *__dso_handle = (void *) &__dso_handle;
#endif

__attribute__((weak)) void _init(void)
{
}
800085a8:	8082                	ret

Disassembly of section .text.mchtmr_isr:

800085aa <mchtmr_isr>:
#define IRQ_COP                12
#define IRQ_HOST                13

__attribute__((weak)) void mchtmr_isr(void)
{
}
800085aa:	8082                	ret

Disassembly of section .text.swi_isr:

800085ac <swi_isr>:

__attribute__((weak)) void swi_isr(void)
{
}
800085ac:	8082                	ret

Disassembly of section .text.syscall_handler:

800085ae <syscall_handler>:
    (void) n;
    (void) a0;
    (void) a1;
    (void) a2;
    (void) a3;
}
800085ae:	8082                	ret

Disassembly of section .text.clock_get_frequency:

800085b0 <clock_get_frequency>:

/***********************************************************************************************************************
 * Codes
 **********************************************************************************************************************/
uint32_t clock_get_frequency(clock_name_t clock_name)
{
800085b0:	1141                	add	sp,sp,-16
800085b2:	c606                	sw	ra,12(sp)
800085b4:	c422                	sw	s0,8(sp)
800085b6:	c226                	sw	s1,4(sp)
800085b8:	85aa                	mv	a1,a0
    uint32_t clk_freq = 0UL;
    uint32_t clk_src_type = GET_CLK_SRC_GROUP_FROM_NAME(clock_name);
    uint32_t node_or_instance = GET_CLK_NODE_FROM_NAME(clock_name);
    switch (clk_src_type) {
800085ba:	0542                	sll	a0,a0,0x10
800085bc:	8161                	srl	a0,a0,0x18
800085be:	462d                	li	a2,11
800085c0:	0ca66163          	bltu	a2,a0,80008682 <.LBB0_14>
800085c4:	050a                	sll	a0,a0,0x2
800085c6:	80005637          	lui	a2,0x80005
800085ca:	f2c60613          	add	a2,a2,-212 # 80004f2c <.LJTI0_0>
800085ce:	9532                	add	a0,a0,a2
800085d0:	4114                	lw	a3,0(a0)
800085d2:	0ff5f613          	zext.b	a2,a1
800085d6:	016e3537          	lui	a0,0x16e3
800085da:	60050513          	add	a0,a0,1536 # 16e3600 <_flash_size+0x15e3600>
800085de:	8682                	jr	a3

800085e0 <.LBB0_2>:
800085e0:	02700513          	li	a0,39
static uint32_t get_frequency_for_ip_in_common_group(clock_node_t node)
{
    uint32_t clk_freq = 0UL;
    uint32_t node_or_instance = GET_CLK_NODE_FROM_NAME(node);

    if (node_or_instance < clock_node_end) {
800085e4:	08c56f63          	bltu	a0,a2,80008682 <.LBB0_14>
        uint32_t clk_node = (uint32_t) node_or_instance;

        uint32_t clk_div = 1UL + SYSCTL_CLOCK_DIV_GET(HPM_SYSCTL->CLOCK[clk_node]);
800085e8:	060a                	sll	a2,a2,0x2
800085ea:	f4002537          	lui	a0,0xf4002
800085ee:	9532                	add	a0,a0,a2

800085f0 <.LBB0_4>:
800085f0:	80452583          	lw	a1,-2044(a0) # f4001804 <__AHB_SRAM_segment_end__+0x3bf9804>
800085f4:	80452503          	lw	a0,-2044(a0)
800085f8:	0ff5f593          	zext.b	a1,a1
800085fc:	00158413          	add	s0,a1,1
80008600:	0556                	sll	a0,a0,0x15
80008602:	a829                	j	8000861c <.LBB0_6>

80008604 <.LBB0_5>:
80008604:	f4002537          	lui	a0,0xf4002
    return freq_in_hz;
}

static uint32_t get_frequency_for_cpu(void)
{
    uint32_t mux = SYSCTL_CLOCK_CPU_MUX_GET(HPM_SYSCTL->CLOCK_CPU[0]);
80008608:	80052583          	lw	a1,-2048(a0) # f4001800 <__AHB_SRAM_segment_end__+0x3bf9800>
    uint32_t div = SYSCTL_CLOCK_CPU_DIV_GET(HPM_SYSCTL->CLOCK_CPU[0]) + 1U;
8000860c:	80052503          	lw	a0,-2048(a0)
80008610:	0ff57513          	zext.b	a0,a0
80008614:	00150413          	add	s0,a0,1
    return (get_frequency_for_source(mux) / div);
80008618:	01559513          	sll	a0,a1,0x15

8000861c <.LBB0_6>:
8000861c:	8175                	srl	a0,a0,0x1d
8000861e:	20d9                	jal	800086e4 <get_frequency_for_source>
80008620:	02855533          	divu	a0,a0,s0
80008624:	a85d                	j	800086da <.LBB0_19>

80008626 <.LBB0_7>:
        clk_freq = get_frequency_for_source((clock_source_t) node_or_instance);
80008626:	8532                	mv	a0,a2
80008628:	40b2                	lw	ra,12(sp)
8000862a:	4422                	lw	s0,8(sp)
8000862c:	4492                	lw	s1,4(sp)
8000862e:	0141                	add	sp,sp,16
80008630:	a855                	j	800086e4 <get_frequency_for_source>

80008632 <.LBB0_8>:
80008632:	f4128537          	lui	a0,0xf4128
    if (EWDG_CTRL0_CLK_SEL_GET(HPM_PEWDG->CTRL0) == 0) {
80008636:	4108                	lw	a0,0(a0)
80008638:	050a                	sll	a0,a0,0x2
8000863a:	08055c63          	bgez	a0,800086d2 <.LBB0_18>
8000863e:	6521                	lui	a0,0x8
80008640:	a869                	j	800086da <.LBB0_19>

80008642 <.LBB0_10>:
80008642:	4505                	li	a0,1
    if (adc_index < ADC_INSTANCE_NUM) {
80008644:	02c56f63          	bltu	a0,a2,80008682 <.LBB0_14>
        uint32_t mux_in_reg = SYSCTL_ADCCLK_MUX_GET(HPM_SYSCTL->ADCCLK[adc_index]);
80008648:	060a                	sll	a2,a2,0x2
8000864a:	f4002537          	lui	a0,0xf4002
8000864e:	c0050693          	add	a3,a0,-1024 # f4001c00 <__AHB_SRAM_segment_end__+0x3bf9c00>
80008652:	8e55                	or	a2,a2,a3
80008654:	4210                	lw	a2,0(a2)
80008656:	065e                	sll	a2,a2,0x17
80008658:	827d                	srl	a2,a2,0x1f
        if (node != clock_node_ahb) {
8000865a:	c629                	beqz	a2,800086a4 <.LBB0_17>
            node = s_adc_clk_mux_node[mux_in_reg];
8000865c:	80010537          	lui	a0,0x80010
80008660:	2f550513          	add	a0,a0,757 # 800102f5 <s_adc_clk_mux_node>
80008664:	9532                	add	a0,a0,a2
80008666:	00054503          	lbu	a0,0(a0)
            node += instance;
8000866a:	952e                	add	a0,a0,a1
8000866c:	0ff57513          	zext.b	a0,a0
80008670:	02700593          	li	a1,39
    if (node_or_instance < clock_node_end) {
80008674:	00a5e763          	bltu	a1,a0,80008682 <.LBB0_14>
        uint32_t clk_div = 1UL + SYSCTL_CLOCK_DIV_GET(HPM_SYSCTL->CLOCK[clk_node]);
80008678:	050a                	sll	a0,a0,0x2
8000867a:	f40025b7          	lui	a1,0xf4002
8000867e:	952e                	add	a0,a0,a1
80008680:	bf85                	j	800085f0 <.LBB0_4>

80008682 <.LBB0_14>:
80008682:	4501                	li	a0,0
80008684:	a899                	j	800086da <.LBB0_19>

80008686 <.LBB0_15>:
    if (EWDG_CTRL0_CLK_SEL_GET(s_wdgs[instance]->CTRL0) == 0) {
80008686:	060a                	sll	a2,a2,0x2
80008688:	80005537          	lui	a0,0x80005
8000868c:	fac50513          	add	a0,a0,-84 # 80004fac <s_wdgs>
80008690:	9532                	add	a0,a0,a2
80008692:	4108                	lw	a0,0(a0)
80008694:	4108                	lw	a0,0(a0)
80008696:	00251593          	sll	a1,a0,0x2
8000869a:	6521                	lui	a0,0x8
8000869c:	0205cf63          	bltz	a1,800086da <.LBB0_19>

800086a0 <.LBB0_16>:
800086a0:	f4002537          	lui	a0,0xf4002

800086a4 <.LBB0_17>:
800086a4:	80052583          	lw	a1,-2048(a0) # f4001800 <__AHB_SRAM_segment_end__+0x3bf9800>
800086a8:	80052603          	lw	a2,-2048(a0)
800086ac:	80052503          	lw	a0,-2048(a0)
800086b0:	05b2                	sll	a1,a1,0xc
800086b2:	81f1                	srl	a1,a1,0x1c
800086b4:	00158413          	add	s0,a1,1 # f4002001 <__AHB_SRAM_segment_end__+0x3bfa001>
800086b8:	0ff57513          	zext.b	a0,a0
800086bc:	00150493          	add	s1,a0,1
800086c0:	01561513          	sll	a0,a2,0x15
800086c4:	8175                	srl	a0,a0,0x1d
800086c6:	2839                	jal	800086e4 <get_frequency_for_source>
800086c8:	02955533          	divu	a0,a0,s1
800086cc:	02855533          	divu	a0,a0,s0
800086d0:	a029                	j	800086da <.LBB0_19>

800086d2 <.LBB0_18>:
800086d2:	016e3537          	lui	a0,0x16e3
800086d6:	60050513          	add	a0,a0,1536 # 16e3600 <_flash_size+0x15e3600>

800086da <.LBB0_19>:
800086da:	40b2                	lw	ra,12(sp)
800086dc:	4422                	lw	s0,8(sp)
800086de:	4492                	lw	s1,4(sp)
    return clk_freq;
800086e0:	0141                	add	sp,sp,16
800086e2:	8082                	ret

Disassembly of section .text.get_frequency_for_source:

800086e4 <get_frequency_for_source>:
{
800086e4:	459d                	li	a1,7
    switch (source) {
800086e6:	06a5e863          	bltu	a1,a0,80008756 <.LBB1_9>
800086ea:	050a                	sll	a0,a0,0x2
800086ec:	800055b7          	lui	a1,0x80005
800086f0:	f5c58593          	add	a1,a1,-164 # 80004f5c <.LJTI1_0>
800086f4:	952e                	add	a0,a0,a1
800086f6:	410c                	lw	a1,0(a0)
800086f8:	016e3537          	lui	a0,0x16e3
800086fc:	60050513          	add	a0,a0,1536 # 16e3600 <_flash_size+0x15e3600>
80008700:	8582                	jr	a1

80008702 <.LBB1_2>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 0U, 0U);
80008702:	f40c0537          	lui	a0,0xf40c0
80008706:	4581                	li	a1,0
80008708:	4601                	li	a2,0
8000870a:	4750106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

8000870e <.LBB1_3>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 1U, 0U);
8000870e:	f40c0537          	lui	a0,0xf40c0
80008712:	4585                	li	a1,1
80008714:	4601                	li	a2,0
80008716:	4690106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

8000871a <.LBB1_4>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 0U, 1U);
8000871a:	f40c0537          	lui	a0,0xf40c0
8000871e:	4605                	li	a2,1
80008720:	4581                	li	a1,0
80008722:	45d0106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

80008726 <.LBB1_5>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 0U, 2U);
80008726:	f40c0537          	lui	a0,0xf40c0
8000872a:	4609                	li	a2,2
8000872c:	4581                	li	a1,0
8000872e:	4510106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

80008732 <.LBB1_6>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 1U, 3U);
80008732:	f40c0537          	lui	a0,0xf40c0
80008736:	4585                	li	a1,1
80008738:	460d                	li	a2,3
8000873a:	4450106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

8000873e <.LBB1_7>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 1U, 1U);
8000873e:	f40c0537          	lui	a0,0xf40c0
80008742:	4585                	li	a1,1
80008744:	4605                	li	a2,1
80008746:	4390106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

8000874a <.LBB1_8>:
        clk_freq = pllctlv2_get_pll_postdiv_freq_in_hz(HPM_PLLCTLV2, 1U, 2U);
8000874a:	f40c0537          	lui	a0,0xf40c0
8000874e:	4585                	li	a1,1
80008750:	4609                	li	a2,2
80008752:	42d0106f          	j	8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>

80008756 <.LBB1_9>:
80008756:	4501                	li	a0,0

80008758 <.LBB1_10>:
    return clk_freq;
80008758:	8082                	ret

Disassembly of section .text.clock_cpu_delay_us:

8000875a <clock_cpu_delay_us>:
    }
}

void clock_cpu_delay_us(uint32_t us)
{
    uint32_t ticks_per_us = (hpm_core_clock + FREQ_1MHz - 1U) / FREQ_1MHz;
8000875a:	6a81a583          	lw	a1,1704(gp) # 81a18 <hpm_core_clock>
8000875e:	000f4637          	lui	a2,0xf4
80008762:	23f60613          	add	a2,a2,575 # f423f <__DLM_segment_end__+0x5423f>
80008766:	00c586b3          	add	a3,a1,a2
 * @return CSR cycle value in 64-bit
 */
static inline uint64_t hpm_csr_get_core_cycle(void)
{
    uint64_t result;
    uint32_t resultl_first = read_csr(CSR_CYCLE);
8000876a:	c0002673          	rdcycle	a2
    uint32_t resulth = read_csr(CSR_CYCLEH);
8000876e:	c80025f3          	rdcycleh	a1
    uint32_t resultl_second = read_csr(CSR_CYCLE);
80008772:	c0002773          	rdcycle	a4
80008776:	431be7b7          	lui	a5,0x431be
8000877a:	e8378793          	add	a5,a5,-381 # 431bde83 <_flash_size+0x430bde83>
8000877e:	02f6b6b3          	mulhu	a3,a3,a5
80008782:	82c9                	srl	a3,a3,0x12
    if (resultl_first < resultl_second) {
80008784:	00e66563          	bltu	a2,a4,8000878e <.LBB13_2>
        result = ((uint64_t)resulth << 32) | resultl_first; /* if CYCLE didn't roll over, return the value directly */
    } else {
        resulth = read_csr(CSR_CYCLEH);
80008788:	c80025f3          	rdcycleh	a1
8000878c:	863a                	mv	a2,a4

8000878e <.LBB13_2>:
    uint64_t expected_ticks = hpm_csr_get_core_cycle() + ticks_per_us * us;
8000878e:	02a68533          	mul	a0,a3,a0
80008792:	9532                	add	a0,a0,a2
80008794:	00c53633          	sltu	a2,a0,a2
80008798:	95b2                	add	a1,a1,a2
8000879a:	a021                	j	800087a2 <.LBB13_4>

8000879c <.LBB13_3>:
8000879c:	00b63633          	sltu	a2,a2,a1
    while (hpm_csr_get_core_cycle() < expected_ticks) {
800087a0:	c20d                	beqz	a2,800087c2 <.LBB13_8>

800087a2 <.LBB13_4>:
    uint32_t resultl_first = read_csr(CSR_CYCLE);
800087a2:	c00026f3          	rdcycle	a3
    uint32_t resulth = read_csr(CSR_CYCLEH);
800087a6:	c8002673          	rdcycleh	a2
    uint32_t resultl_second = read_csr(CSR_CYCLE);
800087aa:	c0002773          	rdcycle	a4
    if (resultl_first < resultl_second) {
800087ae:	00e6e563          	bltu	a3,a4,800087b8 <.LBB13_6>
        resulth = read_csr(CSR_CYCLEH);
800087b2:	c8002673          	rdcycleh	a2
800087b6:	86ba                	mv	a3,a4

800087b8 <.LBB13_6>:
800087b8:	feb612e3          	bne	a2,a1,8000879c <.LBB13_3>
800087bc:	00a6b633          	sltu	a2,a3,a0
800087c0:	f26d                	bnez	a2,800087a2 <.LBB13_4>

800087c2 <.LBB13_8>:
    }
}
800087c2:	8082                	ret

Disassembly of section .text.clock_cpu_delay_ms:

800087c4 <clock_cpu_delay_ms>:

void clock_cpu_delay_ms(uint32_t ms)
{
    uint32_t ticks_per_us = (hpm_core_clock + FREQ_1MHz - 1U) / FREQ_1MHz;
800087c4:	6a81a583          	lw	a1,1704(gp) # 81a18 <hpm_core_clock>
800087c8:	000f4637          	lui	a2,0xf4
800087cc:	23f60613          	add	a2,a2,575 # f423f <__DLM_segment_end__+0x5423f>
800087d0:	00c586b3          	add	a3,a1,a2
    uint32_t resultl_first = read_csr(CSR_CYCLE);
800087d4:	c0002673          	rdcycle	a2
    uint32_t resulth = read_csr(CSR_CYCLEH);
800087d8:	c80025f3          	rdcycleh	a1
    uint32_t resultl_second = read_csr(CSR_CYCLE);
800087dc:	c0002773          	rdcycle	a4
800087e0:	431be7b7          	lui	a5,0x431be
800087e4:	e8378793          	add	a5,a5,-381 # 431bde83 <_flash_size+0x430bde83>
800087e8:	02f6b6b3          	mulhu	a3,a3,a5
800087ec:	82c9                	srl	a3,a3,0x12
    if (resultl_first < resultl_second) {
800087ee:	00e66563          	bltu	a2,a4,800087f8 <.LBB14_2>
        resulth = read_csr(CSR_CYCLEH);
800087f2:	c80025f3          	rdcycleh	a1
800087f6:	863a                	mv	a2,a4

800087f8 <.LBB14_2>:
800087f8:	3e800713          	li	a4,1000
    uint64_t expected_ticks = hpm_csr_get_core_cycle() + (uint64_t)ticks_per_us * 1000UL * ms;
800087fc:	02e686b3          	mul	a3,a3,a4
80008800:	02a6b733          	mulhu	a4,a3,a0
80008804:	02a686b3          	mul	a3,a3,a0
80008808:	00c68533          	add	a0,a3,a2
8000880c:	00d53633          	sltu	a2,a0,a3
80008810:	95ba                	add	a1,a1,a4
80008812:	95b2                	add	a1,a1,a2
80008814:	a021                	j	8000881c <.LBB14_4>

80008816 <.LBB14_3>:
80008816:	00b63633          	sltu	a2,a2,a1
    while (hpm_csr_get_core_cycle() < expected_ticks) {
8000881a:	c20d                	beqz	a2,8000883c <.LBB14_8>

8000881c <.LBB14_4>:
    uint32_t resultl_first = read_csr(CSR_CYCLE);
8000881c:	c00026f3          	rdcycle	a3
    uint32_t resulth = read_csr(CSR_CYCLEH);
80008820:	c8002673          	rdcycleh	a2
    uint32_t resultl_second = read_csr(CSR_CYCLE);
80008824:	c0002773          	rdcycle	a4
    if (resultl_first < resultl_second) {
80008828:	00e6e563          	bltu	a3,a4,80008832 <.LBB14_6>
        resulth = read_csr(CSR_CYCLEH);
8000882c:	c8002673          	rdcycleh	a2
80008830:	86ba                	mv	a3,a4

80008832 <.LBB14_6>:
80008832:	feb612e3          	bne	a2,a1,80008816 <.LBB14_3>
80008836:	00a6b633          	sltu	a2,a3,a0
8000883a:	f26d                	bnez	a2,8000881c <.LBB14_4>

8000883c <.LBB14_8>:
    }
}
8000883c:	8082                	ret

Disassembly of section .text.l1c_dc_enable:

8000883e <l1c_dc_enable>:
extern "C" {
#endif
/* get cache control register value */
__attribute__((always_inline)) static inline uint32_t l1c_get_control(void)
{
    return read_csr(CSR_MCACHE_CTL);
8000883e:	7ca02573          	csrr	a0,0x7ca
}

__attribute__((always_inline)) static inline bool l1c_dc_is_enabled(void)
{
    return l1c_get_control() & HPM_MCACHE_CTL_DC_EN_MASK;
80008842:	8909                	and	a0,a0,2
    write_csr(CSR_MSTATUS, csr);
}

void l1c_dc_enable(void)
{
    if (!l1c_dc_is_enabled()) {
80008844:	e909                	bnez	a0,80008856 <.LBB0_2>
80008846:	00180537          	lui	a0,0x180
        clear_csr(CSR_MCACHE_CTL, HPM_MCACHE_CTL_DC_WAROUND_MASK);
8000884a:	7ca53073          	csrc	0x7ca,a0
8000884e:	6541                	lui	a0,0x10
80008850:	0509                	add	a0,a0,2 # 10002 <__ILM_segment_used_end__+0x4bbc>
        set_csr(CSR_MCACHE_CTL,
80008852:	7ca52073          	csrs	0x7ca,a0

80008856 <.LBB0_2>:
                HPM_MCACHE_CTL_DC_WAROUND(L1C_DC_WAROUND_VALUE) |
#endif
                                HPM_MCACHE_CTL_DPREF_EN_MASK
                              | HPM_MCACHE_CTL_DC_EN_MASK);
    }
}
80008856:	8082                	ret

Disassembly of section .text.l1c_ic_enable:

80008858 <l1c_ic_enable>:
    return read_csr(CSR_MCACHE_CTL);
80008858:	7ca02573          	csrr	a0,0x7ca
}

__attribute__((always_inline)) static inline bool l1c_ic_is_enabled(void)
{
    return l1c_get_control() & HPM_MCACHE_CTL_IC_EN_MASK;
8000885c:	8905                	and	a0,a0,1
    }
}

void l1c_ic_enable(void)
{
    if (!l1c_ic_is_enabled()) {
8000885e:	e509                	bnez	a0,80008868 <.LBB2_2>
80008860:	30100513          	li	a0,769
        set_csr(CSR_MCACHE_CTL, HPM_MCACHE_CTL_IPREF_EN_MASK
80008864:	7ca52073          	csrs	0x7ca,a0

80008868 <.LBB2_2>:
                              | HPM_MCACHE_CTL_CCTL_SUEN_MASK
                              | HPM_MCACHE_CTL_IC_EN_MASK);
    }
}
80008868:	8082                	ret

Disassembly of section .text.sysctl_check_group_resource_enable:

8000886a <sysctl_check_group_resource_enable>:
    uint32_t index, offset;
    bool enable;

    index = (resource - sysctl_resource_linkable_start) / 32;
    offset = (resource - sysctl_resource_linkable_start) % 32;
    switch (group) {
8000886a:	c199                	beqz	a1,80008870 <.LBB10_2>
8000886c:	4501                	li	a0,0
    default:
        enable =  false;
        break;
    }

    return enable;
8000886e:	8082                	ret

80008870 <.LBB10_2>:
    index = (resource - sysctl_resource_linkable_start) / 32;
80008870:	f0060593          	add	a1,a2,-256
80008874:	01b5d693          	srl	a3,a1,0x1b
80008878:	95b6                	add	a1,a1,a3
8000887a:	8595                	sra	a1,a1,0x5
        enable = ((ptr->GROUP0[index].VALUE & (1UL << offset)) != 0) ? true : false;
8000887c:	0592                	sll	a1,a1,0x4
8000887e:	952e                	add	a0,a0,a1
80008880:	7ff50513          	add	a0,a0,2047
80008884:	00152503          	lw	a0,1(a0)
80008888:	00c55533          	srl	a0,a0,a2
8000888c:	8905                	and	a0,a0,1
    return enable;
8000888e:	8082                	ret

Disassembly of section .text.sysctl_config_cpu0_domain_clock:

80008890 <sysctl_config_cpu0_domain_clock>:

hpm_stat_t sysctl_config_cpu0_domain_clock(SYSCTL_Type *ptr,
                                           clock_source_t source,
                                           uint32_t cpu_div,
                                           uint32_t ahb_sub_div)
{
80008890:	479d                	li	a5,7
80008892:	4709                	li	a4,2
    if (source >= clock_source_general_source_end) {
80008894:	04b7e963          	bltu	a5,a1,800088e6 <.LBB16_8>
80008898:	470d                	li	a4,3
8000889a:	072e                	sll	a4,a4,0xb
        return status_invalid_argument;
    }

    uint32_t origin_cpu_div = SYSCTL_CLOCK_CPU_DIV_GET(ptr->CLOCK_CPU[0]) + 1U;
8000889c:	953a                	add	a0,a0,a4
8000889e:	4118                	lw	a4,0(a0)
800088a0:	0ff77713          	zext.b	a4,a4
800088a4:	0705                	add	a4,a4,1
800088a6:	05a2                	sll	a1,a1,0x8
    if (origin_cpu_div == cpu_div) {
800088a8:	02c71063          	bne	a4,a2,800088c8 <.LBB16_4>
        ptr->CLOCK_CPU[0] = SYSCTL_CLOCK_CPU_MUX_SET(source) | SYSCTL_CLOCK_CPU_DIV_SET(cpu_div) | SYSCTL_CLOCK_CPU_SUB0_DIV_SET(ahb_sub_div - 1);
800088ac:	0ff67713          	zext.b	a4,a2
800088b0:	8f4d                	or	a4,a4,a1
800088b2:	06c2                	sll	a3,a3,0x10
800088b4:	000f07b7          	lui	a5,0xf0
800088b8:	96be                	add	a3,a3,a5
800088ba:	8efd                	and	a3,a3,a5
800088bc:	8f55                	or	a4,a4,a3
800088be:	c118                	sw	a4,0(a0)

800088c0 <.LBB16_3>:
 * @param[in] ptr SYSCTL_Type base address
 * @return true if any clock is busy
 */
static inline bool sysctl_cpu_clock_any_is_busy(SYSCTL_Type *ptr)
{
    return ptr->CLOCK_CPU[0] & SYSCTL_CLOCK_CPU_GLB_BUSY_MASK;
800088c0:	4118                	lw	a4,0(a0)
        while (sysctl_cpu_clock_any_is_busy(ptr)) {
800088c2:	fe074fe3          	bltz	a4,800088c0 <.LBB16_3>
800088c6:	a031                	j	800088d2 <.LBB16_5>

800088c8 <.LBB16_4>:
        }
    }
    ptr->CLOCK_CPU[0] = SYSCTL_CLOCK_CPU_MUX_SET(source) | SYSCTL_CLOCK_CPU_DIV_SET(cpu_div - 1) | SYSCTL_CLOCK_CPU_SUB0_DIV_SET(ahb_sub_div - 1);
800088c8:	06c2                	sll	a3,a3,0x10
800088ca:	000f0737          	lui	a4,0xf0
800088ce:	96ba                	add	a3,a3,a4
800088d0:	8ef9                	and	a3,a3,a4

800088d2 <.LBB16_5>:
800088d2:	167d                	add	a2,a2,-1
800088d4:	0ff67613          	zext.b	a2,a2
800088d8:	8dd5                	or	a1,a1,a3
800088da:	8dd1                	or	a1,a1,a2
800088dc:	c10c                	sw	a1,0(a0)

800088de <.LBB16_6>:
800088de:	410c                	lw	a1,0(a0)

    while (sysctl_cpu_clock_any_is_busy(ptr)) {
800088e0:	fe05cfe3          	bltz	a1,800088de <.LBB16_6>
800088e4:	4701                	li	a4,0

800088e6 <.LBB16_8>:
    }

    return status_success;
}
800088e6:	853a                	mv	a0,a4
800088e8:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_xtoa:

800088ea <__SEGGER_RTL_xltoa>:
800088ea:	882a                	mv	a6,a0
800088ec:	88ae                	mv	a7,a1
800088ee:	852e                	mv	a0,a1
800088f0:	ca89                	beqz	a3,80008902 <.L2>
800088f2:	02d00793          	li	a5,45
800088f6:	00158893          	add	a7,a1,1
800088fa:	00f58023          	sb	a5,0(a1)
800088fe:	41000833          	neg	a6,a6

80008902 <.L2>:
80008902:	8746                	mv	a4,a7
80008904:	4325                	li	t1,9

80008906 <.L5>:
80008906:	02c876b3          	remu	a3,a6,a2
8000890a:	85c2                	mv	a1,a6
8000890c:	0ff6f793          	zext.b	a5,a3
80008910:	02c85833          	divu	a6,a6,a2
80008914:	02d37d63          	bgeu	t1,a3,8000894e <.L3>
80008918:	05778793          	add	a5,a5,87 # f0057 <__DLM_segment_end__+0x50057>

8000891c <.L11>:
8000891c:	0ff7f793          	zext.b	a5,a5
80008920:	00f70023          	sb	a5,0(a4) # f0000 <__DLM_segment_end__+0x50000>
80008924:	00170693          	add	a3,a4,1
80008928:	02c5f163          	bgeu	a1,a2,8000894a <.L8>
8000892c:	000700a3          	sb	zero,1(a4)

80008930 <.L6>:
80008930:	0008c683          	lbu	a3,0(a7)
80008934:	00074783          	lbu	a5,0(a4)
80008938:	0885                	add	a7,a7,1
8000893a:	177d                	add	a4,a4,-1
8000893c:	00d700a3          	sb	a3,1(a4)
80008940:	fef88fa3          	sb	a5,-1(a7)
80008944:	fee8e6e3          	bltu	a7,a4,80008930 <.L6>
80008948:	8082                	ret

8000894a <.L8>:
8000894a:	8736                	mv	a4,a3
8000894c:	bf6d                	j	80008906 <.L5>

8000894e <.L3>:
8000894e:	03078793          	add	a5,a5,48
80008952:	b7e9                	j	8000891c <.L11>

Disassembly of section .text.libc.itoa:

80008954 <itoa>:
80008954:	46a9                	li	a3,10
80008956:	87aa                	mv	a5,a0
80008958:	882e                	mv	a6,a1
8000895a:	8732                	mv	a4,a2
8000895c:	00d61563          	bne	a2,a3,80008966 <.L301>
80008960:	4685                	li	a3,1
80008962:	00054663          	bltz	a0,8000896e <.L302>

80008966 <.L301>:
80008966:	4681                	li	a3,0
80008968:	863a                	mv	a2,a4
8000896a:	85c2                	mv	a1,a6
8000896c:	853e                	mv	a0,a5

8000896e <.L302>:
8000896e:	bfb5                	j	800088ea <__SEGGER_RTL_xltoa>

Disassembly of section .text.libc.__SEGGER_RTL_SIGNAL_SIG_DFL:

80008970 <__SEGGER_RTL_SIGNAL_SIG_DFL>:
80008970:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_SIGNAL_SIG_IGN:

80008972 <__SEGGER_RTL_SIGNAL_SIG_IGN>:
80008972:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_SIGNAL_SIG_ERR:

80008974 <__SEGGER_RTL_SIGNAL_SIG_ERR>:
80008974:	8082                	ret

Disassembly of section .text.libc.fwrite:

80008976 <fwrite>:
80008976:	1101                	add	sp,sp,-32
80008978:	c64e                	sw	s3,12(sp)
8000897a:	89aa                	mv	s3,a0
8000897c:	8536                	mv	a0,a3
8000897e:	cc22                	sw	s0,24(sp)
80008980:	ca26                	sw	s1,20(sp)
80008982:	c84a                	sw	s2,16(sp)
80008984:	ce06                	sw	ra,28(sp)
80008986:	84ae                	mv	s1,a1
80008988:	8432                	mv	s0,a2
8000898a:	8936                	mv	s2,a3
8000898c:	48a010ef          	jal	80009e16 <__SEGGER_RTL_X_file_stat>
80008990:	02054463          	bltz	a0,800089b8 <.L43>
80008994:	02848633          	mul	a2,s1,s0
80008998:	4501                	li	a0,0
8000899a:	00966863          	bltu	a2,s1,800089aa <.L41>
8000899e:	85ce                	mv	a1,s3
800089a0:	854a                	mv	a0,s2
800089a2:	412010ef          	jal	80009db4 <__SEGGER_RTL_X_file_write>
800089a6:	02955533          	divu	a0,a0,s1

800089aa <.L41>:
800089aa:	40f2                	lw	ra,28(sp)
800089ac:	4462                	lw	s0,24(sp)
800089ae:	44d2                	lw	s1,20(sp)
800089b0:	4942                	lw	s2,16(sp)
800089b2:	49b2                	lw	s3,12(sp)
800089b4:	6105                	add	sp,sp,32
800089b6:	8082                	ret

800089b8 <.L43>:
800089b8:	4501                	li	a0,0
800089ba:	bfc5                	j	800089aa <.L41>

Disassembly of section .text.libc.fputc:

800089bc <fputc>:
800089bc:	1101                	add	sp,sp,-32
800089be:	86ae                	mv	a3,a1
800089c0:	00a107a3          	sb	a0,15(sp)
800089c4:	4605                	li	a2,1
800089c6:	4585                	li	a1,1
800089c8:	00f10513          	add	a0,sp,15
800089cc:	ce06                	sw	ra,28(sp)
800089ce:	3765                	jal	80008976 <fwrite>
800089d0:	c511                	beqz	a0,800089dc <.L50>
800089d2:	00f14503          	lbu	a0,15(sp)

800089d6 <.L48>:
800089d6:	40f2                	lw	ra,28(sp)
800089d8:	6105                	add	sp,sp,32
800089da:	8082                	ret

800089dc <.L50>:
800089dc:	557d                	li	a0,-1
800089de:	bfe5                	j	800089d6 <.L48>

Disassembly of section .text.libc.__subsf3:

800089e0 <__subsf3>:
800089e0:	80000637          	lui	a2,0x80000
800089e4:	8db1                	xor	a1,a1,a2
800089e6:	a009                	j	800089e8 <__addsf3>

Disassembly of section .text.libc.__addsf3:

800089e8 <__addsf3>:
800089e8:	80000637          	lui	a2,0x80000
800089ec:	00b546b3          	xor	a3,a0,a1
800089f0:	0806ca63          	bltz	a3,80008a84 <.L__addsf3_subtract>
800089f4:	00b57563          	bgeu	a0,a1,800089fe <.L__addsf3_add_already_ordered>
800089f8:	86aa                	mv	a3,a0
800089fa:	852e                	mv	a0,a1
800089fc:	85b6                	mv	a1,a3

800089fe <.L__addsf3_add_already_ordered>:
800089fe:	00151713          	sll	a4,a0,0x1
80008a02:	8361                	srl	a4,a4,0x18
80008a04:	00159693          	sll	a3,a1,0x1
80008a08:	82e1                	srl	a3,a3,0x18
80008a0a:	0ff00293          	li	t0,255
80008a0e:	06570563          	beq	a4,t0,80008a78 <.L__addsf3_add_inf_or_nan>
80008a12:	c325                	beqz	a4,80008a72 <.L__addsf3_zero>
80008a14:	ceb1                	beqz	a3,80008a70 <.L__addsf3_add_done>
80008a16:	40d706b3          	sub	a3,a4,a3
80008a1a:	42e1                	li	t0,24
80008a1c:	04d2ca63          	blt	t0,a3,80008a70 <.L__addsf3_add_done>
80008a20:	05a2                	sll	a1,a1,0x8
80008a22:	8dd1                	or	a1,a1,a2
80008a24:	01755713          	srl	a4,a0,0x17
80008a28:	0522                	sll	a0,a0,0x8
80008a2a:	8d51                	or	a0,a0,a2
80008a2c:	47e5                	li	a5,25
80008a2e:	8f95                	sub	a5,a5,a3
80008a30:	00f59633          	sll	a2,a1,a5
80008a34:	821d                	srl	a2,a2,0x7
80008a36:	00d5d5b3          	srl	a1,a1,a3
80008a3a:	00b507b3          	add	a5,a0,a1
80008a3e:	00a7f463          	bgeu	a5,a0,80008a46 <.L__addsf3_add_no_normalization>
80008a42:	8385                	srl	a5,a5,0x1
80008a44:	0709                	add	a4,a4,2

80008a46 <.L__addsf3_add_no_normalization>:
80008a46:	177d                	add	a4,a4,-1
80008a48:	0ff77593          	zext.b	a1,a4
80008a4c:	f0158593          	add	a1,a1,-255
80008a50:	cd91                	beqz	a1,80008a6c <.L__addsf3_inf>
80008a52:	075e                	sll	a4,a4,0x17
80008a54:	0087d513          	srl	a0,a5,0x8
80008a58:	07e2                	sll	a5,a5,0x18
80008a5a:	8fd1                	or	a5,a5,a2
80008a5c:	0007d663          	bgez	a5,80008a68 <.L__addsf3_no_tie>
80008a60:	0786                	sll	a5,a5,0x1
80008a62:	0505                	add	a0,a0,1
80008a64:	e391                	bnez	a5,80008a68 <.L__addsf3_no_tie>
80008a66:	9979                	and	a0,a0,-2

80008a68 <.L__addsf3_no_tie>:
80008a68:	953a                	add	a0,a0,a4
80008a6a:	8082                	ret

80008a6c <.L__addsf3_inf>:
80008a6c:	01771513          	sll	a0,a4,0x17

80008a70 <.L__addsf3_add_done>:
80008a70:	8082                	ret

80008a72 <.L__addsf3_zero>:
80008a72:	817d                	srl	a0,a0,0x1f
80008a74:	057e                	sll	a0,a0,0x1f
80008a76:	8082                	ret

80008a78 <.L__addsf3_add_inf_or_nan>:
80008a78:	00951613          	sll	a2,a0,0x9
80008a7c:	da75                	beqz	a2,80008a70 <.L__addsf3_add_done>

80008a7e <.L__addsf3_return_nan>:
80008a7e:	7fc00537          	lui	a0,0x7fc00
80008a82:	8082                	ret

80008a84 <.L__addsf3_subtract>:
80008a84:	8db1                	xor	a1,a1,a2
80008a86:	40b506b3          	sub	a3,a0,a1
80008a8a:	00b57563          	bgeu	a0,a1,80008a94 <.L__addsf3_sub_already_ordered>
80008a8e:	8eb1                	xor	a3,a3,a2
80008a90:	8d15                	sub	a0,a0,a3
80008a92:	95b6                	add	a1,a1,a3

80008a94 <.L__addsf3_sub_already_ordered>:
80008a94:	00159693          	sll	a3,a1,0x1
80008a98:	82e1                	srl	a3,a3,0x18
80008a9a:	00151713          	sll	a4,a0,0x1
80008a9e:	8361                	srl	a4,a4,0x18
80008aa0:	05a2                	sll	a1,a1,0x8
80008aa2:	8dd1                	or	a1,a1,a2
80008aa4:	0ff00293          	li	t0,255
80008aa8:	0c570c63          	beq	a4,t0,80008b80 <.L__addsf3_sub_inf_or_nan>
80008aac:	c2f5                	beqz	a3,80008b90 <.L__addsf3_sub_zero>
80008aae:	40d706b3          	sub	a3,a4,a3
80008ab2:	c695                	beqz	a3,80008ade <.L__addsf3_exponents_equal>
80008ab4:	4285                	li	t0,1
80008ab6:	08569063          	bne	a3,t0,80008b36 <.L__addsf3_exponents_differ_by_more_than_1>
80008aba:	01755693          	srl	a3,a0,0x17
80008abe:	0526                	sll	a0,a0,0x9
80008ac0:	00b532b3          	sltu	t0,a0,a1
80008ac4:	8d0d                	sub	a0,a0,a1
80008ac6:	02029263          	bnez	t0,80008aea <.L__addsf3_normalization_steps>
80008aca:	06de                	sll	a3,a3,0x17
80008acc:	01751593          	sll	a1,a0,0x17
80008ad0:	8125                	srl	a0,a0,0x9
80008ad2:	0005d463          	bgez	a1,80008ada <.L__addsf3_sub_no_tie_single>
80008ad6:	0505                	add	a0,a0,1 # 7fc00001 <_flash_size+0x7fb00001>
80008ad8:	9979                	and	a0,a0,-2

80008ada <.L__addsf3_sub_no_tie_single>:
80008ada:	9536                	add	a0,a0,a3

80008adc <.L__addsf3_sub_done>:
80008adc:	8082                	ret

80008ade <.L__addsf3_exponents_equal>:
80008ade:	01755693          	srl	a3,a0,0x17
80008ae2:	0526                	sll	a0,a0,0x9
80008ae4:	0586                	sll	a1,a1,0x1
80008ae6:	8d0d                	sub	a0,a0,a1
80008ae8:	d975                	beqz	a0,80008adc <.L__addsf3_sub_done>

80008aea <.L__addsf3_normalization_steps>:
80008aea:	4581                	li	a1,0
80008aec:	01055793          	srl	a5,a0,0x10
80008af0:	e399                	bnez	a5,80008af6 <.L1^B1>
80008af2:	0542                	sll	a0,a0,0x10
80008af4:	05c1                	add	a1,a1,16

80008af6 <.L1^B1>:
80008af6:	01855793          	srl	a5,a0,0x18
80008afa:	e399                	bnez	a5,80008b00 <.L2^B1>
80008afc:	0522                	sll	a0,a0,0x8
80008afe:	05a1                	add	a1,a1,8

80008b00 <.L2^B1>:
80008b00:	01c55793          	srl	a5,a0,0x1c
80008b04:	e399                	bnez	a5,80008b0a <.L3^B1>
80008b06:	0512                	sll	a0,a0,0x4
80008b08:	0591                	add	a1,a1,4

80008b0a <.L3^B1>:
80008b0a:	01e55793          	srl	a5,a0,0x1e
80008b0e:	e399                	bnez	a5,80008b14 <.L4^B1>
80008b10:	050a                	sll	a0,a0,0x2
80008b12:	0589                	add	a1,a1,2

80008b14 <.L4^B1>:
80008b14:	00054463          	bltz	a0,80008b1c <.L5^B1>
80008b18:	0506                	sll	a0,a0,0x1
80008b1a:	0585                	add	a1,a1,1

80008b1c <.L5^B1>:
80008b1c:	0585                	add	a1,a1,1
80008b1e:	0506                	sll	a0,a0,0x1
80008b20:	00e5f763          	bgeu	a1,a4,80008b2e <.L__addsf3_underflow>
80008b24:	8e8d                	sub	a3,a3,a1
80008b26:	06de                	sll	a3,a3,0x17
80008b28:	8125                	srl	a0,a0,0x9
80008b2a:	9536                	add	a0,a0,a3
80008b2c:	8082                	ret

80008b2e <.L__addsf3_underflow>:
80008b2e:	0086d513          	srl	a0,a3,0x8
80008b32:	057e                	sll	a0,a0,0x1f
80008b34:	8082                	ret

80008b36 <.L__addsf3_exponents_differ_by_more_than_1>:
80008b36:	42e5                	li	t0,25
80008b38:	fad2e2e3          	bltu	t0,a3,80008adc <.L__addsf3_sub_done>
80008b3c:	0685                	add	a3,a3,1
80008b3e:	40d00733          	neg	a4,a3
80008b42:	00e59733          	sll	a4,a1,a4
80008b46:	00d5d5b3          	srl	a1,a1,a3
80008b4a:	00e03733          	snez	a4,a4
80008b4e:	95ae                	add	a1,a1,a1
80008b50:	95ba                	add	a1,a1,a4
80008b52:	01755693          	srl	a3,a0,0x17
80008b56:	0522                	sll	a0,a0,0x8
80008b58:	8d51                	or	a0,a0,a2
80008b5a:	40b50733          	sub	a4,a0,a1
80008b5e:	00074463          	bltz	a4,80008b66 <.L__addsf3_sub_already_normalized>
80008b62:	070a                	sll	a4,a4,0x2
80008b64:	8305                	srl	a4,a4,0x1

80008b66 <.L__addsf3_sub_already_normalized>:
80008b66:	16fd                	add	a3,a3,-1
80008b68:	06de                	sll	a3,a3,0x17
80008b6a:	00875513          	srl	a0,a4,0x8
80008b6e:	0762                	sll	a4,a4,0x18
80008b70:	00075663          	bgez	a4,80008b7c <.L__addsf3_sub_no_tie>
80008b74:	0706                	sll	a4,a4,0x1
80008b76:	0505                	add	a0,a0,1
80008b78:	e311                	bnez	a4,80008b7c <.L__addsf3_sub_no_tie>
80008b7a:	9979                	and	a0,a0,-2

80008b7c <.L__addsf3_sub_no_tie>:
80008b7c:	9536                	add	a0,a0,a3
80008b7e:	8082                	ret

80008b80 <.L__addsf3_sub_inf_or_nan>:
80008b80:	0ff00293          	li	t0,255
80008b84:	ee568de3          	beq	a3,t0,80008a7e <.L__addsf3_return_nan>
80008b88:	00951593          	sll	a1,a0,0x9
80008b8c:	d9a1                	beqz	a1,80008adc <.L__addsf3_sub_done>
80008b8e:	bdc5                	j	80008a7e <.L__addsf3_return_nan>

80008b90 <.L__addsf3_sub_zero>:
80008b90:	f731                	bnez	a4,80008adc <.L__addsf3_sub_done>
80008b92:	4501                	li	a0,0
80008b94:	8082                	ret

Disassembly of section .text.libc.__ltsf2:

80008b96 <__ltsf2>:
80008b96:	ff000637          	lui	a2,0xff000
80008b9a:	00151693          	sll	a3,a0,0x1
80008b9e:	02d66763          	bltu	a2,a3,80008bcc <.L__ltsf2_zero>
80008ba2:	00159693          	sll	a3,a1,0x1
80008ba6:	02d66363          	bltu	a2,a3,80008bcc <.L__ltsf2_zero>
80008baa:	00b56633          	or	a2,a0,a1
80008bae:	00161693          	sll	a3,a2,0x1
80008bb2:	ce89                	beqz	a3,80008bcc <.L__ltsf2_zero>
80008bb4:	00064763          	bltz	a2,80008bc2 <.L__ltsf2_negative>
80008bb8:	00b53533          	sltu	a0,a0,a1
80008bbc:	40a00533          	neg	a0,a0
80008bc0:	8082                	ret

80008bc2 <.L__ltsf2_negative>:
80008bc2:	00a5b533          	sltu	a0,a1,a0
80008bc6:	40a00533          	neg	a0,a0
80008bca:	8082                	ret

80008bcc <.L__ltsf2_zero>:
80008bcc:	4501                	li	a0,0
80008bce:	8082                	ret

Disassembly of section .text.libc.__lesf2:

80008bd0 <__lesf2>:
80008bd0:	ff000637          	lui	a2,0xff000
80008bd4:	00151693          	sll	a3,a0,0x1
80008bd8:	02d66363          	bltu	a2,a3,80008bfe <.L__lesf2_nan>
80008bdc:	00159693          	sll	a3,a1,0x1
80008be0:	00d66f63          	bltu	a2,a3,80008bfe <.L__lesf2_nan>
80008be4:	00b56633          	or	a2,a0,a1
80008be8:	00161693          	sll	a3,a2,0x1
80008bec:	ca99                	beqz	a3,80008c02 <.L__lesf2_zero>
80008bee:	00064563          	bltz	a2,80008bf8 <.L__lesf2_negative>
80008bf2:	00a5b533          	sltu	a0,a1,a0
80008bf6:	8082                	ret

80008bf8 <.L__lesf2_negative>:
80008bf8:	00b53533          	sltu	a0,a0,a1
80008bfc:	8082                	ret

80008bfe <.L__lesf2_nan>:
80008bfe:	4505                	li	a0,1
80008c00:	8082                	ret

80008c02 <.L__lesf2_zero>:
80008c02:	4501                	li	a0,0
80008c04:	8082                	ret

Disassembly of section .text.libc.__gtsf2:

80008c06 <__gtsf2>:
80008c06:	ff000637          	lui	a2,0xff000
80008c0a:	00151693          	sll	a3,a0,0x1
80008c0e:	02d66363          	bltu	a2,a3,80008c34 <.L__gtsf2_zero>
80008c12:	00159693          	sll	a3,a1,0x1
80008c16:	00d66f63          	bltu	a2,a3,80008c34 <.L__gtsf2_zero>
80008c1a:	00b56633          	or	a2,a0,a1
80008c1e:	00161693          	sll	a3,a2,0x1
80008c22:	ca89                	beqz	a3,80008c34 <.L__gtsf2_zero>
80008c24:	00064563          	bltz	a2,80008c2e <.L__gtsf2_negative>
80008c28:	00a5b533          	sltu	a0,a1,a0
80008c2c:	8082                	ret

80008c2e <.L__gtsf2_negative>:
80008c2e:	00b53533          	sltu	a0,a0,a1
80008c32:	8082                	ret

80008c34 <.L__gtsf2_zero>:
80008c34:	4501                	li	a0,0
80008c36:	8082                	ret

Disassembly of section .text.libc.__gesf2:

80008c38 <__gesf2>:
80008c38:	ff000637          	lui	a2,0xff000
80008c3c:	00151693          	sll	a3,a0,0x1
80008c40:	02d66763          	bltu	a2,a3,80008c6e <.L__gesf2_nan>
80008c44:	00159693          	sll	a3,a1,0x1
80008c48:	02d66363          	bltu	a2,a3,80008c6e <.L__gesf2_nan>
80008c4c:	00b56633          	or	a2,a0,a1
80008c50:	00161693          	sll	a3,a2,0x1
80008c54:	ce99                	beqz	a3,80008c72 <.L__gesf2_zero>
80008c56:	00064763          	bltz	a2,80008c64 <.L__gesf2_negative>
80008c5a:	00b53533          	sltu	a0,a0,a1
80008c5e:	40a00533          	neg	a0,a0
80008c62:	8082                	ret

80008c64 <.L__gesf2_negative>:
80008c64:	00a5b533          	sltu	a0,a1,a0
80008c68:	40a00533          	neg	a0,a0
80008c6c:	8082                	ret

80008c6e <.L__gesf2_nan>:
80008c6e:	557d                	li	a0,-1
80008c70:	8082                	ret

80008c72 <.L__gesf2_zero>:
80008c72:	4501                	li	a0,0
80008c74:	8082                	ret

Disassembly of section .text.libc.__fixunssfsi:

80008c76 <__fixunssfsi>:
80008c76:	02a05763          	blez	a0,80008ca4 <.L__fixunssfsi_zero_result>
80008c7a:	00151593          	sll	a1,a0,0x1
80008c7e:	81e1                	srl	a1,a1,0x18
80008c80:	f8158593          	add	a1,a1,-127
80008c84:	0205c063          	bltz	a1,80008ca4 <.L__fixunssfsi_zero_result>
80008c88:	40b005b3          	neg	a1,a1
80008c8c:	05fd                	add	a1,a1,31
80008c8e:	0005c963          	bltz	a1,80008ca0 <.L__fixunssfsi_max_result>
80008c92:	0522                	sll	a0,a0,0x8
80008c94:	800006b7          	lui	a3,0x80000
80008c98:	8d55                	or	a0,a0,a3
80008c9a:	00b55533          	srl	a0,a0,a1
80008c9e:	8082                	ret

80008ca0 <.L__fixunssfsi_max_result>:
80008ca0:	557d                	li	a0,-1
80008ca2:	8082                	ret

80008ca4 <.L__fixunssfsi_zero_result>:
80008ca4:	4501                	li	a0,0
80008ca6:	8082                	ret

Disassembly of section .text.libc.__fixunsdfsi:

80008ca8 <__fixunsdfsi>:
80008ca8:	0205c563          	bltz	a1,80008cd2 <.L__fixunsdfsi_zero_result>
80008cac:	0145d613          	srl	a2,a1,0x14
80008cb0:	c0160613          	add	a2,a2,-1023 # fefffc01 <__AHB_SRAM_segment_end__+0xebf7c01>
80008cb4:	00064f63          	bltz	a2,80008cd2 <.L__fixunsdfsi_zero_result>
80008cb8:	477d                	li	a4,31
80008cba:	8f11                	sub	a4,a4,a2
80008cbc:	00074d63          	bltz	a4,80008cd6 <.L__fixunsdfsi_overflow_result>
80008cc0:	8155                	srl	a0,a0,0x15
80008cc2:	05ae                	sll	a1,a1,0xb
80008cc4:	8d4d                	or	a0,a0,a1
80008cc6:	800006b7          	lui	a3,0x80000
80008cca:	8d55                	or	a0,a0,a3
80008ccc:	00e55533          	srl	a0,a0,a4
80008cd0:	8082                	ret

80008cd2 <.L__fixunsdfsi_zero_result>:
80008cd2:	4501                	li	a0,0
80008cd4:	8082                	ret

80008cd6 <.L__fixunsdfsi_overflow_result>:
80008cd6:	557d                	li	a0,-1
80008cd8:	8082                	ret

Disassembly of section .text.libc.__floatsisf:

80008cda <__floatsisf>:
80008cda:	01f55613          	srl	a2,a0,0x1f
80008cde:	0622                	sll	a2,a2,0x8
80008ce0:	09d60613          	add	a2,a2,157
80008ce4:	cd29                	beqz	a0,80008d3e <.L__floatsisf_done>
80008ce6:	41f55693          	sra	a3,a0,0x1f
80008cea:	00d545b3          	xor	a1,a0,a3
80008cee:	8d95                	sub	a1,a1,a3
80008cf0:	0105d693          	srl	a3,a1,0x10
80008cf4:	e299                	bnez	a3,80008cfa <.L1^B2>
80008cf6:	05c2                	sll	a1,a1,0x10
80008cf8:	1641                	add	a2,a2,-16

80008cfa <.L1^B2>:
80008cfa:	0185d693          	srl	a3,a1,0x18
80008cfe:	e299                	bnez	a3,80008d04 <.L2^B2>
80008d00:	05a2                	sll	a1,a1,0x8
80008d02:	1661                	add	a2,a2,-8

80008d04 <.L2^B2>:
80008d04:	01c5d693          	srl	a3,a1,0x1c
80008d08:	e299                	bnez	a3,80008d0e <.L3^B2>
80008d0a:	0592                	sll	a1,a1,0x4
80008d0c:	1671                	add	a2,a2,-4

80008d0e <.L3^B2>:
80008d0e:	01e5d693          	srl	a3,a1,0x1e
80008d12:	e299                	bnez	a3,80008d18 <.L4^B2>
80008d14:	058a                	sll	a1,a1,0x2
80008d16:	1679                	add	a2,a2,-2

80008d18 <.L4^B2>:
80008d18:	0005c463          	bltz	a1,80008d20 <.L5^B2>
80008d1c:	0586                	sll	a1,a1,0x1
80008d1e:	167d                	add	a2,a2,-1

80008d20 <.L5^B2>:
80008d20:	065e                	sll	a2,a2,0x17
80008d22:	0085d513          	srl	a0,a1,0x8
80008d26:	05de                	sll	a1,a1,0x17
80008d28:	0005a333          	sltz	t1,a1
80008d2c:	95ae                	add	a1,a1,a1
80008d2e:	959a                	add	a1,a1,t1
80008d30:	0005d663          	bgez	a1,80008d3c <.L__floatsisf_round_down>
80008d34:	95ae                	add	a1,a1,a1
80008d36:	00b035b3          	snez	a1,a1
80008d3a:	952e                	add	a0,a0,a1

80008d3c <.L__floatsisf_round_down>:
80008d3c:	9532                	add	a0,a0,a2

80008d3e <.L__floatsisf_done>:
80008d3e:	8082                	ret

Disassembly of section .text.libc.__floatunsisf:

80008d40 <__floatunsisf>:
80008d40:	c931                	beqz	a0,80008d94 <.L__floatunsisf_done>
80008d42:	09d00613          	li	a2,157
80008d46:	01055693          	srl	a3,a0,0x10
80008d4a:	e299                	bnez	a3,80008d50 <.L1^B8>
80008d4c:	0542                	sll	a0,a0,0x10
80008d4e:	1641                	add	a2,a2,-16

80008d50 <.L1^B8>:
80008d50:	01855693          	srl	a3,a0,0x18
80008d54:	e299                	bnez	a3,80008d5a <.L2^B8>
80008d56:	0522                	sll	a0,a0,0x8
80008d58:	1661                	add	a2,a2,-8

80008d5a <.L2^B8>:
80008d5a:	01c55693          	srl	a3,a0,0x1c
80008d5e:	e299                	bnez	a3,80008d64 <.L3^B6>
80008d60:	0512                	sll	a0,a0,0x4
80008d62:	1671                	add	a2,a2,-4

80008d64 <.L3^B6>:
80008d64:	01e55693          	srl	a3,a0,0x1e
80008d68:	e299                	bnez	a3,80008d6e <.L4^B8>
80008d6a:	050a                	sll	a0,a0,0x2
80008d6c:	1679                	add	a2,a2,-2

80008d6e <.L4^B8>:
80008d6e:	00054463          	bltz	a0,80008d76 <.L5^B6>
80008d72:	0506                	sll	a0,a0,0x1
80008d74:	167d                	add	a2,a2,-1

80008d76 <.L5^B6>:
80008d76:	065e                	sll	a2,a2,0x17
80008d78:	01751593          	sll	a1,a0,0x17
80008d7c:	8121                	srl	a0,a0,0x8
80008d7e:	0005a333          	sltz	t1,a1
80008d82:	95ae                	add	a1,a1,a1
80008d84:	959a                	add	a1,a1,t1
80008d86:	0005d663          	bgez	a1,80008d92 <.L__floatunsisf_round_down>
80008d8a:	95ae                	add	a1,a1,a1
80008d8c:	00b035b3          	snez	a1,a1
80008d90:	952e                	add	a0,a0,a1

80008d92 <.L__floatunsisf_round_down>:
80008d92:	9532                	add	a0,a0,a2

80008d94 <.L__floatunsisf_done>:
80008d94:	8082                	ret

Disassembly of section .text.libc.__floatundisf:

80008d96 <__floatundisf>:
80008d96:	c5bd                	beqz	a1,80008e04 <.L__floatundisf_high_word_zero>
80008d98:	4701                	li	a4,0
80008d9a:	0105d693          	srl	a3,a1,0x10
80008d9e:	e299                	bnez	a3,80008da4 <.L8^B3>
80008da0:	0741                	add	a4,a4,16
80008da2:	05c2                	sll	a1,a1,0x10

80008da4 <.L8^B3>:
80008da4:	0185d693          	srl	a3,a1,0x18
80008da8:	e299                	bnez	a3,80008dae <.L4^B10>
80008daa:	0721                	add	a4,a4,8
80008dac:	05a2                	sll	a1,a1,0x8

80008dae <.L4^B10>:
80008dae:	01c5d693          	srl	a3,a1,0x1c
80008db2:	e299                	bnez	a3,80008db8 <.L2^B10>
80008db4:	0711                	add	a4,a4,4
80008db6:	0592                	sll	a1,a1,0x4

80008db8 <.L2^B10>:
80008db8:	01e5d693          	srl	a3,a1,0x1e
80008dbc:	e299                	bnez	a3,80008dc2 <.L1^B10>
80008dbe:	0709                	add	a4,a4,2
80008dc0:	058a                	sll	a1,a1,0x2

80008dc2 <.L1^B10>:
80008dc2:	0005c463          	bltz	a1,80008dca <.L0^B3>
80008dc6:	0705                	add	a4,a4,1
80008dc8:	0586                	sll	a1,a1,0x1

80008dca <.L0^B3>:
80008dca:	fff74613          	not	a2,a4
80008dce:	00c556b3          	srl	a3,a0,a2
80008dd2:	8285                	srl	a3,a3,0x1
80008dd4:	8dd5                	or	a1,a1,a3
80008dd6:	00e51533          	sll	a0,a0,a4
80008dda:	0be60613          	add	a2,a2,190
80008dde:	00a03533          	snez	a0,a0
80008de2:	8dc9                	or	a1,a1,a0

80008de4 <.L__floatundisf_round_and_pack>:
80008de4:	065e                	sll	a2,a2,0x17
80008de6:	0085d513          	srl	a0,a1,0x8
80008dea:	05de                	sll	a1,a1,0x17
80008dec:	0005a333          	sltz	t1,a1
80008df0:	95ae                	add	a1,a1,a1
80008df2:	959a                	add	a1,a1,t1
80008df4:	0005d663          	bgez	a1,80008e00 <.L__floatundisf_round_down>
80008df8:	95ae                	add	a1,a1,a1
80008dfa:	00b035b3          	snez	a1,a1
80008dfe:	952e                	add	a0,a0,a1

80008e00 <.L__floatundisf_round_down>:
80008e00:	9532                	add	a0,a0,a2

80008e02 <.L__floatundisf_done>:
80008e02:	8082                	ret

80008e04 <.L__floatundisf_high_word_zero>:
80008e04:	dd7d                	beqz	a0,80008e02 <.L__floatundisf_done>
80008e06:	09d00613          	li	a2,157
80008e0a:	01055693          	srl	a3,a0,0x10
80008e0e:	e299                	bnez	a3,80008e14 <.L1^B11>
80008e10:	0542                	sll	a0,a0,0x10
80008e12:	1641                	add	a2,a2,-16

80008e14 <.L1^B11>:
80008e14:	01855693          	srl	a3,a0,0x18
80008e18:	e299                	bnez	a3,80008e1e <.L2^B11>
80008e1a:	0522                	sll	a0,a0,0x8
80008e1c:	1661                	add	a2,a2,-8

80008e1e <.L2^B11>:
80008e1e:	01c55693          	srl	a3,a0,0x1c
80008e22:	e299                	bnez	a3,80008e28 <.L3^B8>
80008e24:	0512                	sll	a0,a0,0x4
80008e26:	1671                	add	a2,a2,-4

80008e28 <.L3^B8>:
80008e28:	01e55693          	srl	a3,a0,0x1e
80008e2c:	e299                	bnez	a3,80008e32 <.L4^B11>
80008e2e:	050a                	sll	a0,a0,0x2
80008e30:	1679                	add	a2,a2,-2

80008e32 <.L4^B11>:
80008e32:	00054463          	bltz	a0,80008e3a <.L5^B8>
80008e36:	0506                	sll	a0,a0,0x1
80008e38:	167d                	add	a2,a2,-1

80008e3a <.L5^B8>:
80008e3a:	85aa                	mv	a1,a0
80008e3c:	4501                	li	a0,0
80008e3e:	b75d                	j	80008de4 <.L__floatundisf_round_and_pack>

Disassembly of section .text.libc.__truncdfsf2:

80008e40 <__truncdfsf2>:
80008e40:	00159693          	sll	a3,a1,0x1
80008e44:	82d5                	srl	a3,a3,0x15
80008e46:	7ff00613          	li	a2,2047
80008e4a:	04c68663          	beq	a3,a2,80008e96 <.L__truncdfsf2_inf_nan>
80008e4e:	c8068693          	add	a3,a3,-896 # 7ffffc80 <_flash_size+0x7feffc80>
80008e52:	02d05e63          	blez	a3,80008e8e <.L__truncdfsf2_underflow>
80008e56:	0ff00613          	li	a2,255
80008e5a:	04c6f263          	bgeu	a3,a2,80008e9e <.L__truncdfsf2_inf>
80008e5e:	06de                	sll	a3,a3,0x17
80008e60:	01f5d613          	srl	a2,a1,0x1f
80008e64:	067e                	sll	a2,a2,0x1f
80008e66:	8ed1                	or	a3,a3,a2
80008e68:	05b2                	sll	a1,a1,0xc
80008e6a:	01455613          	srl	a2,a0,0x14
80008e6e:	8dd1                	or	a1,a1,a2
80008e70:	81a5                	srl	a1,a1,0x9
80008e72:	00251613          	sll	a2,a0,0x2
80008e76:	00062733          	sltz	a4,a2
80008e7a:	9632                	add	a2,a2,a2
80008e7c:	000627b3          	sltz	a5,a2
80008e80:	9632                	add	a2,a2,a2
80008e82:	963a                	add	a2,a2,a4
80008e84:	c211                	beqz	a2,80008e88 <.L__truncdfsf2_no_round_tie>
80008e86:	95be                	add	a1,a1,a5

80008e88 <.L__truncdfsf2_no_round_tie>:
80008e88:	00d58533          	add	a0,a1,a3
80008e8c:	8082                	ret

80008e8e <.L__truncdfsf2_underflow>:
80008e8e:	01f5d513          	srl	a0,a1,0x1f
80008e92:	057e                	sll	a0,a0,0x1f
80008e94:	8082                	ret

80008e96 <.L__truncdfsf2_inf_nan>:
80008e96:	00c59693          	sll	a3,a1,0xc
80008e9a:	8ec9                	or	a3,a3,a0
80008e9c:	ea81                	bnez	a3,80008eac <.L__truncdfsf2_nan>

80008e9e <.L__truncdfsf2_inf>:
80008e9e:	81fd                	srl	a1,a1,0x1f
80008ea0:	05fe                	sll	a1,a1,0x1f
80008ea2:	7f800537          	lui	a0,0x7f800
80008ea6:	8d4d                	or	a0,a0,a1
80008ea8:	4581                	li	a1,0
80008eaa:	8082                	ret

80008eac <.L__truncdfsf2_nan>:
80008eac:	800006b7          	lui	a3,0x80000
80008eb0:	00d5f633          	and	a2,a1,a3
80008eb4:	058e                	sll	a1,a1,0x3
80008eb6:	8175                	srl	a0,a0,0x1d
80008eb8:	8d4d                	or	a0,a0,a1
80008eba:	0506                	sll	a0,a0,0x1
80008ebc:	8105                	srl	a0,a0,0x1
80008ebe:	8d51                	or	a0,a0,a2
80008ec0:	82a5                	srl	a3,a3,0x9
80008ec2:	8d55                	or	a0,a0,a3
80008ec4:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ldouble_to_double:

80008ec6 <__SEGGER_RTL_ldouble_to_double>:
80008ec6:	4158                	lw	a4,4(a0)
80008ec8:	451c                	lw	a5,8(a0)
80008eca:	4554                	lw	a3,12(a0)
80008ecc:	1141                	add	sp,sp,-16
80008ece:	c23a                	sw	a4,4(sp)
80008ed0:	c43e                	sw	a5,8(sp)
80008ed2:	7771                	lui	a4,0xffffc
80008ed4:	00169793          	sll	a5,a3,0x1
80008ed8:	83c5                	srl	a5,a5,0x11
80008eda:	40070713          	add	a4,a4,1024 # ffffc400 <__AHB_SRAM_segment_end__+0xfbf4400>
80008ede:	c636                	sw	a3,12(sp)
80008ee0:	97ba                	add	a5,a5,a4
80008ee2:	00f04a63          	bgtz	a5,80008ef6 <.L27>
80008ee6:	800007b7          	lui	a5,0x80000
80008eea:	4701                	li	a4,0
80008eec:	8ff5                	and	a5,a5,a3

80008eee <.L28>:
80008eee:	853a                	mv	a0,a4
80008ef0:	85be                	mv	a1,a5
80008ef2:	0141                	add	sp,sp,16
80008ef4:	8082                	ret

80008ef6 <.L27>:
80008ef6:	6711                	lui	a4,0x4
80008ef8:	3ff70713          	add	a4,a4,1023 # 43ff <.LBB0_9+0x47>
80008efc:	00e78c63          	beq	a5,a4,80008f14 <.L29>
80008f00:	7ff00713          	li	a4,2047
80008f04:	00f75a63          	bge	a4,a5,80008f18 <.L30>
80008f08:	4781                	li	a5,0
80008f0a:	4801                	li	a6,0
80008f0c:	c43e                	sw	a5,8(sp)
80008f0e:	c642                	sw	a6,12(sp)
80008f10:	c03e                	sw	a5,0(sp)
80008f12:	c242                	sw	a6,4(sp)

80008f14 <.L29>:
80008f14:	7ff00793          	li	a5,2047

80008f18 <.L30>:
80008f18:	45a2                	lw	a1,8(sp)
80008f1a:	4732                	lw	a4,12(sp)
80008f1c:	80000637          	lui	a2,0x80000
80008f20:	01c5d513          	srl	a0,a1,0x1c
80008f24:	8e79                	and	a2,a2,a4
80008f26:	0712                	sll	a4,a4,0x4
80008f28:	4692                	lw	a3,4(sp)
80008f2a:	8f49                	or	a4,a4,a0
80008f2c:	0732                	sll	a4,a4,0xc
80008f2e:	8331                	srl	a4,a4,0xc
80008f30:	8e59                	or	a2,a2,a4
80008f32:	82f1                	srl	a3,a3,0x1c
80008f34:	0592                	sll	a1,a1,0x4
80008f36:	07d2                	sll	a5,a5,0x14
80008f38:	00b6e733          	or	a4,a3,a1
80008f3c:	8fd1                	or	a5,a5,a2
80008f3e:	bf45                	j	80008eee <.L28>

Disassembly of section .text.libc.__SEGGER_RTL_float32_isnan:

80008f40 <__SEGGER_RTL_float32_isnan>:
80008f40:	ff0007b7          	lui	a5,0xff000
80008f44:	0785                	add	a5,a5,1 # ff000001 <__AHB_SRAM_segment_end__+0xebf8001>
80008f46:	0506                	sll	a0,a0,0x1
80008f48:	00f53533          	sltu	a0,a0,a5
80008f4c:	00154513          	xor	a0,a0,1
80008f50:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_float32_isinf:

80008f52 <__SEGGER_RTL_float32_isinf>:
80008f52:	010007b7          	lui	a5,0x1000
80008f56:	0506                	sll	a0,a0,0x1
80008f58:	953e                	add	a0,a0,a5
80008f5a:	00153513          	seqz	a0,a0
80008f5e:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_float32_isnormal:

80008f60 <__SEGGER_RTL_float32_isnormal>:
80008f60:	ff0007b7          	lui	a5,0xff000
80008f64:	0506                	sll	a0,a0,0x1
80008f66:	953e                	add	a0,a0,a5
80008f68:	fe0007b7          	lui	a5,0xfe000
80008f6c:	00f53533          	sltu	a0,a0,a5
80008f70:	8082                	ret

Disassembly of section .text.libc.floorf:

80008f72 <floorf>:
80008f72:	00151693          	sll	a3,a0,0x1
80008f76:	82e1                	srl	a3,a3,0x18
80008f78:	01755793          	srl	a5,a0,0x17
80008f7c:	16fd                	add	a3,a3,-1 # 7fffffff <_flash_size+0x7fefffff>
80008f7e:	0fd00613          	li	a2,253
80008f82:	872a                	mv	a4,a0
80008f84:	0ff7f793          	zext.b	a5,a5
80008f88:	00d67963          	bgeu	a2,a3,80008f9a <.L1240>
80008f8c:	e789                	bnez	a5,80008f96 <.L1241>
80008f8e:	800007b7          	lui	a5,0x80000
80008f92:	00f57733          	and	a4,a0,a5

80008f96 <.L1241>:
80008f96:	853a                	mv	a0,a4
80008f98:	8082                	ret

80008f9a <.L1240>:
80008f9a:	f8178793          	add	a5,a5,-127 # 7fffff81 <_flash_size+0x7fefff81>
80008f9e:	0007db63          	bgez	a5,80008fb4 <.L1243>
80008fa2:	00000513          	li	a0,0
80008fa6:	02075a63          	bgez	a4,80008fda <.L1242>
80008faa:	800057b7          	lui	a5,0x80005
80008fae:	7007a503          	lw	a0,1792(a5) # 80005700 <.Lmerged_single+0x18>
80008fb2:	8082                	ret

80008fb4 <.L1243>:
80008fb4:	46d9                	li	a3,22
80008fb6:	02f6c263          	blt	a3,a5,80008fda <.L1242>
80008fba:	008006b7          	lui	a3,0x800
80008fbe:	fff68613          	add	a2,a3,-1 # 7fffff <_flash_size+0x6fffff>
80008fc2:	00f65633          	srl	a2,a2,a5
80008fc6:	fff64513          	not	a0,a2
80008fca:	8d79                	and	a0,a0,a4
80008fcc:	8f71                	and	a4,a4,a2
80008fce:	c711                	beqz	a4,80008fda <.L1242>
80008fd0:	00055563          	bgez	a0,80008fda <.L1242>
80008fd4:	00f6d6b3          	srl	a3,a3,a5
80008fd8:	9536                	add	a0,a0,a3

80008fda <.L1242>:
80008fda:	8082                	ret

Disassembly of section .text.libc.__ashldi3:

80008fdc <__ashldi3>:
80008fdc:	02067793          	and	a5,a2,32
80008fe0:	ef89                	bnez	a5,80008ffa <.L__ashldi3LongShift>
80008fe2:	00155793          	srl	a5,a0,0x1
80008fe6:	fff64713          	not	a4,a2
80008fea:	00e7d7b3          	srl	a5,a5,a4
80008fee:	00c595b3          	sll	a1,a1,a2
80008ff2:	8ddd                	or	a1,a1,a5
80008ff4:	00c51533          	sll	a0,a0,a2
80008ff8:	8082                	ret

80008ffa <.L__ashldi3LongShift>:
80008ffa:	00c515b3          	sll	a1,a0,a2
80008ffe:	4501                	li	a0,0
80009000:	8082                	ret

Disassembly of section .text.libc.__udivdi3:

80009002 <__udivdi3>:
80009002:	1101                	add	sp,sp,-32
80009004:	cc22                	sw	s0,24(sp)
80009006:	ca26                	sw	s1,20(sp)
80009008:	c84a                	sw	s2,16(sp)
8000900a:	c64e                	sw	s3,12(sp)
8000900c:	ce06                	sw	ra,28(sp)
8000900e:	c452                	sw	s4,8(sp)
80009010:	c256                	sw	s5,4(sp)
80009012:	c05a                	sw	s6,0(sp)
80009014:	842a                	mv	s0,a0
80009016:	892e                	mv	s2,a1
80009018:	89b2                	mv	s3,a2
8000901a:	84b6                	mv	s1,a3
8000901c:	2e069263          	bnez	a3,80009300 <.L47>
80009020:	ed99                	bnez	a1,8000903e <.L48>
80009022:	02c55433          	divu	s0,a0,a2

80009026 <.L49>:
80009026:	40f2                	lw	ra,28(sp)
80009028:	8522                	mv	a0,s0
8000902a:	4462                	lw	s0,24(sp)
8000902c:	44d2                	lw	s1,20(sp)
8000902e:	49b2                	lw	s3,12(sp)
80009030:	4a22                	lw	s4,8(sp)
80009032:	4a92                	lw	s5,4(sp)
80009034:	4b02                	lw	s6,0(sp)
80009036:	85ca                	mv	a1,s2
80009038:	4942                	lw	s2,16(sp)
8000903a:	6105                	add	sp,sp,32
8000903c:	8082                	ret

8000903e <.L48>:
8000903e:	010007b7          	lui	a5,0x1000
80009042:	12f67863          	bgeu	a2,a5,80009172 <.L50>
80009046:	4791                	li	a5,4
80009048:	08c7e763          	bltu	a5,a2,800090d6 <.L52>
8000904c:	470d                	li	a4,3
8000904e:	02e60263          	beq	a2,a4,80009072 <.L54>
80009052:	06f60a63          	beq	a2,a5,800090c6 <.L55>
80009056:	4785                	li	a5,1
80009058:	fcf607e3          	beq	a2,a5,80009026 <.L49>
8000905c:	4789                	li	a5,2
8000905e:	3cf61063          	bne	a2,a5,8000941e <.L88>
80009062:	01f59793          	sll	a5,a1,0x1f
80009066:	00155413          	srl	s0,a0,0x1
8000906a:	8c5d                	or	s0,s0,a5
8000906c:	0015d913          	srl	s2,a1,0x1
80009070:	bf5d                	j	80009026 <.L49>

80009072 <.L54>:
80009072:	555557b7          	lui	a5,0x55555
80009076:	55578793          	add	a5,a5,1365 # 55555555 <_flash_size+0x55455555>
8000907a:	02b7b6b3          	mulhu	a3,a5,a1
8000907e:	02a7b633          	mulhu	a2,a5,a0
80009082:	02a78733          	mul	a4,a5,a0
80009086:	02b787b3          	mul	a5,a5,a1
8000908a:	97b2                	add	a5,a5,a2
8000908c:	00c7b633          	sltu	a2,a5,a2
80009090:	9636                	add	a2,a2,a3
80009092:	00f706b3          	add	a3,a4,a5
80009096:	00e6b733          	sltu	a4,a3,a4
8000909a:	9732                	add	a4,a4,a2
8000909c:	97ba                	add	a5,a5,a4
8000909e:	00e7b5b3          	sltu	a1,a5,a4
800090a2:	9736                	add	a4,a4,a3
800090a4:	00d736b3          	sltu	a3,a4,a3
800090a8:	0705                	add	a4,a4,1
800090aa:	97b6                	add	a5,a5,a3
800090ac:	00173713          	seqz	a4,a4
800090b0:	00d7b6b3          	sltu	a3,a5,a3
800090b4:	962e                	add	a2,a2,a1
800090b6:	97ba                	add	a5,a5,a4
800090b8:	00c68933          	add	s2,a3,a2
800090bc:	00e7b733          	sltu	a4,a5,a4
800090c0:	843e                	mv	s0,a5
800090c2:	993a                	add	s2,s2,a4
800090c4:	b78d                	j	80009026 <.L49>

800090c6 <.L55>:
800090c6:	01e59793          	sll	a5,a1,0x1e
800090ca:	00255413          	srl	s0,a0,0x2
800090ce:	8c5d                	or	s0,s0,a5
800090d0:	0025d913          	srl	s2,a1,0x2
800090d4:	bf89                	j	80009026 <.L49>

800090d6 <.L52>:
800090d6:	67c1                	lui	a5,0x10
800090d8:	02c5d6b3          	divu	a3,a1,a2
800090dc:	01055713          	srl	a4,a0,0x10
800090e0:	02f67a63          	bgeu	a2,a5,80009114 <.L62>
800090e4:	01051413          	sll	s0,a0,0x10
800090e8:	8041                	srl	s0,s0,0x10
800090ea:	02c687b3          	mul	a5,a3,a2
800090ee:	40f587b3          	sub	a5,a1,a5
800090f2:	07c2                	sll	a5,a5,0x10
800090f4:	97ba                	add	a5,a5,a4
800090f6:	02c7d933          	divu	s2,a5,a2
800090fa:	02c90733          	mul	a4,s2,a2
800090fe:	0942                	sll	s2,s2,0x10
80009100:	8f99                	sub	a5,a5,a4
80009102:	07c2                	sll	a5,a5,0x10
80009104:	943e                	add	s0,s0,a5
80009106:	02c45433          	divu	s0,s0,a2
8000910a:	944a                	add	s0,s0,s2
8000910c:	01243933          	sltu	s2,s0,s2
80009110:	9936                	add	s2,s2,a3
80009112:	bf11                	j	80009026 <.L49>

80009114 <.L62>:
80009114:	02c687b3          	mul	a5,a3,a2
80009118:	01855613          	srl	a2,a0,0x18
8000911c:	0ff77713          	zext.b	a4,a4
80009120:	0ff47413          	zext.b	s0,s0
80009124:	8936                	mv	s2,a3
80009126:	40f587b3          	sub	a5,a1,a5
8000912a:	07a2                	sll	a5,a5,0x8
8000912c:	963e                	add	a2,a2,a5
8000912e:	033657b3          	divu	a5,a2,s3
80009132:	033785b3          	mul	a1,a5,s3
80009136:	07a2                	sll	a5,a5,0x8
80009138:	8e0d                	sub	a2,a2,a1
8000913a:	0622                	sll	a2,a2,0x8
8000913c:	9732                	add	a4,a4,a2
8000913e:	033755b3          	divu	a1,a4,s3
80009142:	97ae                	add	a5,a5,a1
80009144:	07a2                	sll	a5,a5,0x8
80009146:	03358633          	mul	a2,a1,s3
8000914a:	8f11                	sub	a4,a4,a2
8000914c:	00855613          	srl	a2,a0,0x8
80009150:	0ff67613          	zext.b	a2,a2
80009154:	0722                	sll	a4,a4,0x8
80009156:	9732                	add	a4,a4,a2
80009158:	03375633          	divu	a2,a4,s3
8000915c:	97b2                	add	a5,a5,a2
8000915e:	07a2                	sll	a5,a5,0x8
80009160:	03360533          	mul	a0,a2,s3
80009164:	8f09                	sub	a4,a4,a0
80009166:	0722                	sll	a4,a4,0x8
80009168:	943a                	add	s0,s0,a4
8000916a:	03345433          	divu	s0,s0,s3
8000916e:	943e                	add	s0,s0,a5
80009170:	bd5d                	j	80009026 <.L49>

80009172 <.L50>:
80009172:	80005ab7          	lui	s5,0x80005
80009176:	0b4a8a93          	add	s5,s5,180 # 800050b4 <__SEGGER_RTL_Moeller_inverse_lut>
8000917a:	0cc5f063          	bgeu	a1,a2,8000923a <.L64>
8000917e:	10000737          	lui	a4,0x10000
80009182:	87b2                	mv	a5,a2
80009184:	00e67563          	bgeu	a2,a4,8000918e <.L65>
80009188:	00461793          	sll	a5,a2,0x4
8000918c:	4491                	li	s1,4

8000918e <.L65>:
8000918e:	40000737          	lui	a4,0x40000
80009192:	00e7f463          	bgeu	a5,a4,8000919a <.L66>
80009196:	0489                	add	s1,s1,2
80009198:	078a                	sll	a5,a5,0x2

8000919a <.L66>:
8000919a:	0007c363          	bltz	a5,800091a0 <.L67>
8000919e:	0485                	add	s1,s1,1

800091a0 <.L67>:
800091a0:	8626                	mv	a2,s1
800091a2:	8522                	mv	a0,s0
800091a4:	85ca                	mv	a1,s2
800091a6:	3d1d                	jal	80008fdc <__ashldi3>
800091a8:	009994b3          	sll	s1,s3,s1
800091ac:	0164d793          	srl	a5,s1,0x16
800091b0:	e0078793          	add	a5,a5,-512 # fe00 <__ILM_segment_used_end__+0x49ba>
800091b4:	0786                	sll	a5,a5,0x1
800091b6:	97d6                	add	a5,a5,s5
800091b8:	0007d783          	lhu	a5,0(a5)
800091bc:	00b4d813          	srl	a6,s1,0xb
800091c0:	0014f713          	and	a4,s1,1
800091c4:	02f78633          	mul	a2,a5,a5
800091c8:	0792                	sll	a5,a5,0x4
800091ca:	0014d693          	srl	a3,s1,0x1
800091ce:	0805                	add	a6,a6,1 # 1f1f0001 <_flash_size+0x1f0f0001>
800091d0:	03063633          	mulhu	a2,a2,a6
800091d4:	8f91                	sub	a5,a5,a2
800091d6:	96ba                	add	a3,a3,a4
800091d8:	17fd                	add	a5,a5,-1
800091da:	c319                	beqz	a4,800091e0 <.L68>
800091dc:	0017d713          	srl	a4,a5,0x1

800091e0 <.L68>:
800091e0:	02f686b3          	mul	a3,a3,a5
800091e4:	8f15                	sub	a4,a4,a3
800091e6:	02e7b733          	mulhu	a4,a5,a4
800091ea:	07be                	sll	a5,a5,0xf
800091ec:	8305                	srl	a4,a4,0x1
800091ee:	97ba                	add	a5,a5,a4
800091f0:	8726                	mv	a4,s1
800091f2:	029786b3          	mul	a3,a5,s1
800091f6:	9736                	add	a4,a4,a3
800091f8:	00d736b3          	sltu	a3,a4,a3
800091fc:	8726                	mv	a4,s1
800091fe:	9736                	add	a4,a4,a3
80009200:	0297b6b3          	mulhu	a3,a5,s1
80009204:	9736                	add	a4,a4,a3
80009206:	8f99                	sub	a5,a5,a4
80009208:	02b7b733          	mulhu	a4,a5,a1
8000920c:	02b787b3          	mul	a5,a5,a1
80009210:	00a786b3          	add	a3,a5,a0
80009214:	00f6b7b3          	sltu	a5,a3,a5
80009218:	95be                	add	a1,a1,a5
8000921a:	00b707b3          	add	a5,a4,a1
8000921e:	00178413          	add	s0,a5,1
80009222:	02848733          	mul	a4,s1,s0
80009226:	8d19                	sub	a0,a0,a4
80009228:	00a6f463          	bgeu	a3,a0,80009230 <.L69>
8000922c:	9526                	add	a0,a0,s1
8000922e:	843e                	mv	s0,a5

80009230 <.L69>:
80009230:	00956363          	bltu	a0,s1,80009236 <.L109>
80009234:	0405                	add	s0,s0,1

80009236 <.L109>:
80009236:	4901                	li	s2,0
80009238:	b3fd                	j	80009026 <.L49>

8000923a <.L64>:
8000923a:	02c5da33          	divu	s4,a1,a2
8000923e:	10000737          	lui	a4,0x10000
80009242:	87b2                	mv	a5,a2
80009244:	02ca05b3          	mul	a1,s4,a2
80009248:	40b905b3          	sub	a1,s2,a1
8000924c:	00e67563          	bgeu	a2,a4,80009256 <.L71>
80009250:	00461793          	sll	a5,a2,0x4
80009254:	4491                	li	s1,4

80009256 <.L71>:
80009256:	40000737          	lui	a4,0x40000
8000925a:	00e7f463          	bgeu	a5,a4,80009262 <.L72>
8000925e:	0489                	add	s1,s1,2
80009260:	078a                	sll	a5,a5,0x2

80009262 <.L72>:
80009262:	0007c363          	bltz	a5,80009268 <.L73>
80009266:	0485                	add	s1,s1,1

80009268 <.L73>:
80009268:	8626                	mv	a2,s1
8000926a:	8522                	mv	a0,s0
8000926c:	3b85                	jal	80008fdc <__ashldi3>
8000926e:	009994b3          	sll	s1,s3,s1
80009272:	0164d793          	srl	a5,s1,0x16
80009276:	e0078793          	add	a5,a5,-512
8000927a:	0786                	sll	a5,a5,0x1
8000927c:	9abe                	add	s5,s5,a5
8000927e:	000ad783          	lhu	a5,0(s5)
80009282:	00b4d813          	srl	a6,s1,0xb
80009286:	0014f713          	and	a4,s1,1
8000928a:	02f78633          	mul	a2,a5,a5
8000928e:	0792                	sll	a5,a5,0x4
80009290:	0014d693          	srl	a3,s1,0x1
80009294:	0805                	add	a6,a6,1
80009296:	03063633          	mulhu	a2,a2,a6
8000929a:	8f91                	sub	a5,a5,a2
8000929c:	96ba                	add	a3,a3,a4
8000929e:	17fd                	add	a5,a5,-1
800092a0:	c319                	beqz	a4,800092a6 <.L74>
800092a2:	0017d713          	srl	a4,a5,0x1

800092a6 <.L74>:
800092a6:	02f686b3          	mul	a3,a3,a5
800092aa:	8f15                	sub	a4,a4,a3
800092ac:	02e7b733          	mulhu	a4,a5,a4
800092b0:	07be                	sll	a5,a5,0xf
800092b2:	8305                	srl	a4,a4,0x1
800092b4:	97ba                	add	a5,a5,a4
800092b6:	8726                	mv	a4,s1
800092b8:	029786b3          	mul	a3,a5,s1
800092bc:	9736                	add	a4,a4,a3
800092be:	00d736b3          	sltu	a3,a4,a3
800092c2:	8726                	mv	a4,s1
800092c4:	9736                	add	a4,a4,a3
800092c6:	0297b6b3          	mulhu	a3,a5,s1
800092ca:	9736                	add	a4,a4,a3
800092cc:	8f99                	sub	a5,a5,a4
800092ce:	02b7b733          	mulhu	a4,a5,a1
800092d2:	02b787b3          	mul	a5,a5,a1
800092d6:	00a786b3          	add	a3,a5,a0
800092da:	00f6b7b3          	sltu	a5,a3,a5
800092de:	95be                	add	a1,a1,a5
800092e0:	00b707b3          	add	a5,a4,a1
800092e4:	00178413          	add	s0,a5,1
800092e8:	02848733          	mul	a4,s1,s0
800092ec:	8d19                	sub	a0,a0,a4
800092ee:	00a6f463          	bgeu	a3,a0,800092f6 <.L75>
800092f2:	9526                	add	a0,a0,s1
800092f4:	843e                	mv	s0,a5

800092f6 <.L75>:
800092f6:	00956363          	bltu	a0,s1,800092fc <.L76>
800092fa:	0405                	add	s0,s0,1

800092fc <.L76>:
800092fc:	8952                	mv	s2,s4
800092fe:	b325                	j	80009026 <.L49>

80009300 <.L47>:
80009300:	67c1                	lui	a5,0x10
80009302:	8ab6                	mv	s5,a3
80009304:	4a01                	li	s4,0
80009306:	00f6f563          	bgeu	a3,a5,80009310 <.L77>
8000930a:	01069493          	sll	s1,a3,0x10
8000930e:	4a41                	li	s4,16

80009310 <.L77>:
80009310:	010007b7          	lui	a5,0x1000
80009314:	00f4f463          	bgeu	s1,a5,8000931c <.L78>
80009318:	0a21                	add	s4,s4,8
8000931a:	04a2                	sll	s1,s1,0x8

8000931c <.L78>:
8000931c:	100007b7          	lui	a5,0x10000
80009320:	00f4f463          	bgeu	s1,a5,80009328 <.L79>
80009324:	0a11                	add	s4,s4,4
80009326:	0492                	sll	s1,s1,0x4

80009328 <.L79>:
80009328:	400007b7          	lui	a5,0x40000
8000932c:	00f4f463          	bgeu	s1,a5,80009334 <.L80>
80009330:	0a09                	add	s4,s4,2
80009332:	048a                	sll	s1,s1,0x2

80009334 <.L80>:
80009334:	0004c363          	bltz	s1,8000933a <.L81>
80009338:	0a05                	add	s4,s4,1

8000933a <.L81>:
8000933a:	01f91793          	sll	a5,s2,0x1f
8000933e:	8652                	mv	a2,s4
80009340:	00145493          	srl	s1,s0,0x1
80009344:	854e                	mv	a0,s3
80009346:	85d6                	mv	a1,s5
80009348:	8cdd                	or	s1,s1,a5
8000934a:	3949                	jal	80008fdc <__ashldi3>
8000934c:	0165d613          	srl	a2,a1,0x16
80009350:	800057b7          	lui	a5,0x80005
80009354:	e0060613          	add	a2,a2,-512 # 7ffffe00 <_flash_size+0x7feffe00>
80009358:	0606                	sll	a2,a2,0x1
8000935a:	0b478793          	add	a5,a5,180 # 800050b4 <__SEGGER_RTL_Moeller_inverse_lut>
8000935e:	97b2                	add	a5,a5,a2
80009360:	0007d783          	lhu	a5,0(a5)
80009364:	00b5d513          	srl	a0,a1,0xb
80009368:	0015f713          	and	a4,a1,1
8000936c:	02f78633          	mul	a2,a5,a5
80009370:	0792                	sll	a5,a5,0x4
80009372:	0015d693          	srl	a3,a1,0x1
80009376:	0505                	add	a0,a0,1 # 7f800001 <_flash_size+0x7f700001>
80009378:	02a63633          	mulhu	a2,a2,a0
8000937c:	8f91                	sub	a5,a5,a2
8000937e:	00195b13          	srl	s6,s2,0x1
80009382:	96ba                	add	a3,a3,a4
80009384:	17fd                	add	a5,a5,-1
80009386:	c319                	beqz	a4,8000938c <.L82>
80009388:	0017d713          	srl	a4,a5,0x1

8000938c <.L82>:
8000938c:	02f686b3          	mul	a3,a3,a5
80009390:	8f15                	sub	a4,a4,a3
80009392:	02e7b733          	mulhu	a4,a5,a4
80009396:	07be                	sll	a5,a5,0xf
80009398:	8305                	srl	a4,a4,0x1
8000939a:	97ba                	add	a5,a5,a4
8000939c:	872e                	mv	a4,a1
8000939e:	02b786b3          	mul	a3,a5,a1
800093a2:	9736                	add	a4,a4,a3
800093a4:	00d736b3          	sltu	a3,a4,a3
800093a8:	872e                	mv	a4,a1
800093aa:	9736                	add	a4,a4,a3
800093ac:	02b7b6b3          	mulhu	a3,a5,a1
800093b0:	9736                	add	a4,a4,a3
800093b2:	8f99                	sub	a5,a5,a4
800093b4:	0367b733          	mulhu	a4,a5,s6
800093b8:	036787b3          	mul	a5,a5,s6
800093bc:	009786b3          	add	a3,a5,s1
800093c0:	00f6b7b3          	sltu	a5,a3,a5
800093c4:	97da                	add	a5,a5,s6
800093c6:	973e                	add	a4,a4,a5
800093c8:	00170793          	add	a5,a4,1 # 40000001 <_flash_size+0x3ff00001>
800093cc:	02f58633          	mul	a2,a1,a5
800093d0:	8c91                	sub	s1,s1,a2
800093d2:	0096f463          	bgeu	a3,s1,800093da <.L83>
800093d6:	94ae                	add	s1,s1,a1
800093d8:	87ba                	mv	a5,a4

800093da <.L83>:
800093da:	00b4e363          	bltu	s1,a1,800093e0 <.L84>
800093de:	0785                	add	a5,a5,1

800093e0 <.L84>:
800093e0:	477d                	li	a4,31
800093e2:	41470733          	sub	a4,a4,s4
800093e6:	00e7d633          	srl	a2,a5,a4
800093ea:	c211                	beqz	a2,800093ee <.L85>
800093ec:	167d                	add	a2,a2,-1

800093ee <.L85>:
800093ee:	02ca87b3          	mul	a5,s5,a2
800093f2:	03360733          	mul	a4,a2,s3
800093f6:	033636b3          	mulhu	a3,a2,s3
800093fa:	40e40733          	sub	a4,s0,a4
800093fe:	00e43433          	sltu	s0,s0,a4
80009402:	97b6                	add	a5,a5,a3
80009404:	40f907b3          	sub	a5,s2,a5
80009408:	40878433          	sub	s0,a5,s0
8000940c:	01546763          	bltu	s0,s5,8000941a <.L86>
80009410:	008a9463          	bne	s5,s0,80009418 <.L95>
80009414:	01376363          	bltu	a4,s3,8000941a <.L86>

80009418 <.L95>:
80009418:	0605                	add	a2,a2,1

8000941a <.L86>:
8000941a:	8432                	mv	s0,a2
8000941c:	bd29                	j	80009236 <.L109>

8000941e <.L88>:
8000941e:	4401                	li	s0,0
80009420:	bd19                	j	80009236 <.L109>

Disassembly of section .text.libc.__umoddi3:

80009422 <__umoddi3>:
80009422:	1101                	add	sp,sp,-32
80009424:	cc22                	sw	s0,24(sp)
80009426:	ca26                	sw	s1,20(sp)
80009428:	c84a                	sw	s2,16(sp)
8000942a:	c64e                	sw	s3,12(sp)
8000942c:	c452                	sw	s4,8(sp)
8000942e:	ce06                	sw	ra,28(sp)
80009430:	c256                	sw	s5,4(sp)
80009432:	c05a                	sw	s6,0(sp)
80009434:	892a                	mv	s2,a0
80009436:	84ae                	mv	s1,a1
80009438:	8432                	mv	s0,a2
8000943a:	89b6                	mv	s3,a3
8000943c:	8a36                	mv	s4,a3
8000943e:	2e069e63          	bnez	a3,8000973a <.L111>
80009442:	e589                	bnez	a1,8000944c <.L112>
80009444:	02c557b3          	divu	a5,a0,a2

80009448 <.L174>:
80009448:	4701                	li	a4,0
8000944a:	a815                	j	8000947e <.L113>

8000944c <.L112>:
8000944c:	010007b7          	lui	a5,0x1000
80009450:	16f67163          	bgeu	a2,a5,800095b2 <.L114>
80009454:	4791                	li	a5,4
80009456:	0cc7e063          	bltu	a5,a2,80009516 <.L116>
8000945a:	470d                	li	a4,3
8000945c:	04e60d63          	beq	a2,a4,800094b6 <.L118>
80009460:	0af60363          	beq	a2,a5,80009506 <.L119>
80009464:	4785                	li	a5,1
80009466:	3ef60763          	beq	a2,a5,80009854 <.L152>
8000946a:	4789                	li	a5,2
8000946c:	3ef61763          	bne	a2,a5,8000985a <.L153>
80009470:	01f59713          	sll	a4,a1,0x1f
80009474:	00155793          	srl	a5,a0,0x1
80009478:	8fd9                	or	a5,a5,a4
8000947a:	0015d713          	srl	a4,a1,0x1

8000947e <.L113>:
8000947e:	02870733          	mul	a4,a4,s0
80009482:	40f2                	lw	ra,28(sp)
80009484:	4a22                	lw	s4,8(sp)
80009486:	4a92                	lw	s5,4(sp)
80009488:	4b02                	lw	s6,0(sp)
8000948a:	02f989b3          	mul	s3,s3,a5
8000948e:	02f40533          	mul	a0,s0,a5
80009492:	99ba                	add	s3,s3,a4
80009494:	02f43433          	mulhu	s0,s0,a5
80009498:	40a90533          	sub	a0,s2,a0
8000949c:	00a935b3          	sltu	a1,s2,a0
800094a0:	4942                	lw	s2,16(sp)
800094a2:	99a2                	add	s3,s3,s0
800094a4:	4462                	lw	s0,24(sp)
800094a6:	413484b3          	sub	s1,s1,s3
800094aa:	40b485b3          	sub	a1,s1,a1
800094ae:	49b2                	lw	s3,12(sp)
800094b0:	44d2                	lw	s1,20(sp)
800094b2:	6105                	add	sp,sp,32
800094b4:	8082                	ret

800094b6 <.L118>:
800094b6:	555557b7          	lui	a5,0x55555
800094ba:	55578793          	add	a5,a5,1365 # 55555555 <_flash_size+0x55455555>
800094be:	02b7b6b3          	mulhu	a3,a5,a1
800094c2:	02a7b633          	mulhu	a2,a5,a0
800094c6:	02a78733          	mul	a4,a5,a0
800094ca:	02b787b3          	mul	a5,a5,a1
800094ce:	97b2                	add	a5,a5,a2
800094d0:	00c7b633          	sltu	a2,a5,a2
800094d4:	9636                	add	a2,a2,a3
800094d6:	00f706b3          	add	a3,a4,a5
800094da:	00e6b733          	sltu	a4,a3,a4
800094de:	9732                	add	a4,a4,a2
800094e0:	97ba                	add	a5,a5,a4
800094e2:	00e7b5b3          	sltu	a1,a5,a4
800094e6:	9736                	add	a4,a4,a3
800094e8:	00d736b3          	sltu	a3,a4,a3
800094ec:	0705                	add	a4,a4,1
800094ee:	97b6                	add	a5,a5,a3
800094f0:	00173713          	seqz	a4,a4
800094f4:	00d7b6b3          	sltu	a3,a5,a3
800094f8:	962e                	add	a2,a2,a1
800094fa:	97ba                	add	a5,a5,a4
800094fc:	96b2                	add	a3,a3,a2
800094fe:	00e7b733          	sltu	a4,a5,a4
80009502:	9736                	add	a4,a4,a3
80009504:	bfad                	j	8000947e <.L113>

80009506 <.L119>:
80009506:	01e59713          	sll	a4,a1,0x1e
8000950a:	00255793          	srl	a5,a0,0x2
8000950e:	8fd9                	or	a5,a5,a4
80009510:	0025d713          	srl	a4,a1,0x2
80009514:	b7ad                	j	8000947e <.L113>

80009516 <.L116>:
80009516:	67c1                	lui	a5,0x10
80009518:	02c5d733          	divu	a4,a1,a2
8000951c:	01055693          	srl	a3,a0,0x10
80009520:	02f67b63          	bgeu	a2,a5,80009556 <.L126>
80009524:	02c707b3          	mul	a5,a4,a2
80009528:	40f587b3          	sub	a5,a1,a5
8000952c:	07c2                	sll	a5,a5,0x10
8000952e:	97b6                	add	a5,a5,a3
80009530:	02c7d633          	divu	a2,a5,a2
80009534:	028606b3          	mul	a3,a2,s0
80009538:	0642                	sll	a2,a2,0x10
8000953a:	8f95                	sub	a5,a5,a3
8000953c:	01079693          	sll	a3,a5,0x10
80009540:	01051793          	sll	a5,a0,0x10
80009544:	83c1                	srl	a5,a5,0x10
80009546:	97b6                	add	a5,a5,a3
80009548:	0287d7b3          	divu	a5,a5,s0
8000954c:	97b2                	add	a5,a5,a2
8000954e:	00c7b633          	sltu	a2,a5,a2
80009552:	9732                	add	a4,a4,a2
80009554:	b72d                	j	8000947e <.L113>

80009556 <.L126>:
80009556:	02c707b3          	mul	a5,a4,a2
8000955a:	01855613          	srl	a2,a0,0x18
8000955e:	0ff6f693          	zext.b	a3,a3
80009562:	40f587b3          	sub	a5,a1,a5
80009566:	07a2                	sll	a5,a5,0x8
80009568:	963e                	add	a2,a2,a5
8000956a:	028657b3          	divu	a5,a2,s0
8000956e:	028785b3          	mul	a1,a5,s0
80009572:	07a2                	sll	a5,a5,0x8
80009574:	8e0d                	sub	a2,a2,a1
80009576:	0622                	sll	a2,a2,0x8
80009578:	96b2                	add	a3,a3,a2
8000957a:	0286d5b3          	divu	a1,a3,s0
8000957e:	97ae                	add	a5,a5,a1
80009580:	07a2                	sll	a5,a5,0x8
80009582:	02858633          	mul	a2,a1,s0
80009586:	8e91                	sub	a3,a3,a2
80009588:	00855613          	srl	a2,a0,0x8
8000958c:	0ff67613          	zext.b	a2,a2
80009590:	06a2                	sll	a3,a3,0x8
80009592:	96b2                	add	a3,a3,a2
80009594:	0286d633          	divu	a2,a3,s0
80009598:	97b2                	add	a5,a5,a2
8000959a:	07a2                	sll	a5,a5,0x8
8000959c:	02860533          	mul	a0,a2,s0
800095a0:	0ff97613          	zext.b	a2,s2
800095a4:	8e89                	sub	a3,a3,a0
800095a6:	06a2                	sll	a3,a3,0x8
800095a8:	96b2                	add	a3,a3,a2
800095aa:	0286d6b3          	divu	a3,a3,s0
800095ae:	97b6                	add	a5,a5,a3
800095b0:	b5f9                	j	8000947e <.L113>

800095b2 <.L114>:
800095b2:	80005b37          	lui	s6,0x80005
800095b6:	0b4b0b13          	add	s6,s6,180 # 800050b4 <__SEGGER_RTL_Moeller_inverse_lut>
800095ba:	0ac5fe63          	bgeu	a1,a2,80009676 <.L128>
800095be:	10000737          	lui	a4,0x10000
800095c2:	87b2                	mv	a5,a2
800095c4:	00e67563          	bgeu	a2,a4,800095ce <.L129>
800095c8:	00461793          	sll	a5,a2,0x4
800095cc:	4a11                	li	s4,4

800095ce <.L129>:
800095ce:	40000737          	lui	a4,0x40000
800095d2:	00e7f463          	bgeu	a5,a4,800095da <.L130>
800095d6:	0a09                	add	s4,s4,2
800095d8:	078a                	sll	a5,a5,0x2

800095da <.L130>:
800095da:	0007c363          	bltz	a5,800095e0 <.L131>
800095de:	0a05                	add	s4,s4,1

800095e0 <.L131>:
800095e0:	8652                	mv	a2,s4
800095e2:	854a                	mv	a0,s2
800095e4:	85a6                	mv	a1,s1
800095e6:	3add                	jal	80008fdc <__ashldi3>
800095e8:	01441a33          	sll	s4,s0,s4
800095ec:	016a5793          	srl	a5,s4,0x16
800095f0:	e0078793          	add	a5,a5,-512 # fe00 <__ILM_segment_used_end__+0x49ba>
800095f4:	0786                	sll	a5,a5,0x1
800095f6:	97da                	add	a5,a5,s6
800095f8:	0007d783          	lhu	a5,0(a5)
800095fc:	00ba5813          	srl	a6,s4,0xb
80009600:	001a7713          	and	a4,s4,1
80009604:	02f78633          	mul	a2,a5,a5
80009608:	0792                	sll	a5,a5,0x4
8000960a:	001a5693          	srl	a3,s4,0x1
8000960e:	0805                	add	a6,a6,1
80009610:	03063633          	mulhu	a2,a2,a6
80009614:	8f91                	sub	a5,a5,a2
80009616:	96ba                	add	a3,a3,a4
80009618:	17fd                	add	a5,a5,-1
8000961a:	c319                	beqz	a4,80009620 <.L132>
8000961c:	0017d713          	srl	a4,a5,0x1

80009620 <.L132>:
80009620:	02f686b3          	mul	a3,a3,a5
80009624:	8f15                	sub	a4,a4,a3
80009626:	02e7b733          	mulhu	a4,a5,a4
8000962a:	07be                	sll	a5,a5,0xf
8000962c:	8305                	srl	a4,a4,0x1
8000962e:	97ba                	add	a5,a5,a4
80009630:	8752                	mv	a4,s4
80009632:	034786b3          	mul	a3,a5,s4
80009636:	9736                	add	a4,a4,a3
80009638:	00d736b3          	sltu	a3,a4,a3
8000963c:	8752                	mv	a4,s4
8000963e:	9736                	add	a4,a4,a3
80009640:	0347b6b3          	mulhu	a3,a5,s4
80009644:	9736                	add	a4,a4,a3
80009646:	8f99                	sub	a5,a5,a4
80009648:	02b7b733          	mulhu	a4,a5,a1
8000964c:	02b787b3          	mul	a5,a5,a1
80009650:	00a786b3          	add	a3,a5,a0
80009654:	00f6b7b3          	sltu	a5,a3,a5
80009658:	95be                	add	a1,a1,a5
8000965a:	972e                	add	a4,a4,a1
8000965c:	00170793          	add	a5,a4,1 # 40000001 <_flash_size+0x3ff00001>
80009660:	02fa0633          	mul	a2,s4,a5
80009664:	8d11                	sub	a0,a0,a2
80009666:	00a6f463          	bgeu	a3,a0,8000966e <.L133>
8000966a:	9552                	add	a0,a0,s4
8000966c:	87ba                	mv	a5,a4

8000966e <.L133>:
8000966e:	dd456de3          	bltu	a0,s4,80009448 <.L174>

80009672 <.L160>:
80009672:	0785                	add	a5,a5,1
80009674:	bbd1                	j	80009448 <.L174>

80009676 <.L128>:
80009676:	02c5dab3          	divu	s5,a1,a2
8000967a:	10000737          	lui	a4,0x10000
8000967e:	87b2                	mv	a5,a2
80009680:	02ca85b3          	mul	a1,s5,a2
80009684:	40b485b3          	sub	a1,s1,a1
80009688:	00e67563          	bgeu	a2,a4,80009692 <.L135>
8000968c:	00461793          	sll	a5,a2,0x4
80009690:	4a11                	li	s4,4

80009692 <.L135>:
80009692:	40000737          	lui	a4,0x40000
80009696:	00e7f463          	bgeu	a5,a4,8000969e <.L136>
8000969a:	0a09                	add	s4,s4,2
8000969c:	078a                	sll	a5,a5,0x2

8000969e <.L136>:
8000969e:	0007c363          	bltz	a5,800096a4 <.L137>
800096a2:	0a05                	add	s4,s4,1

800096a4 <.L137>:
800096a4:	8652                	mv	a2,s4
800096a6:	854a                	mv	a0,s2
800096a8:	3a15                	jal	80008fdc <__ashldi3>
800096aa:	01441a33          	sll	s4,s0,s4
800096ae:	016a5793          	srl	a5,s4,0x16
800096b2:	e0078793          	add	a5,a5,-512
800096b6:	0786                	sll	a5,a5,0x1
800096b8:	9b3e                	add	s6,s6,a5
800096ba:	000b5783          	lhu	a5,0(s6)
800096be:	00ba5813          	srl	a6,s4,0xb
800096c2:	001a7713          	and	a4,s4,1
800096c6:	02f78633          	mul	a2,a5,a5
800096ca:	0792                	sll	a5,a5,0x4
800096cc:	001a5693          	srl	a3,s4,0x1
800096d0:	0805                	add	a6,a6,1
800096d2:	03063633          	mulhu	a2,a2,a6
800096d6:	8f91                	sub	a5,a5,a2
800096d8:	96ba                	add	a3,a3,a4
800096da:	17fd                	add	a5,a5,-1
800096dc:	c319                	beqz	a4,800096e2 <.L138>
800096de:	0017d713          	srl	a4,a5,0x1

800096e2 <.L138>:
800096e2:	02f686b3          	mul	a3,a3,a5
800096e6:	8f15                	sub	a4,a4,a3
800096e8:	02e7b733          	mulhu	a4,a5,a4
800096ec:	07be                	sll	a5,a5,0xf
800096ee:	8305                	srl	a4,a4,0x1
800096f0:	97ba                	add	a5,a5,a4
800096f2:	8752                	mv	a4,s4
800096f4:	034786b3          	mul	a3,a5,s4
800096f8:	9736                	add	a4,a4,a3
800096fa:	00d736b3          	sltu	a3,a4,a3
800096fe:	8752                	mv	a4,s4
80009700:	9736                	add	a4,a4,a3
80009702:	0347b6b3          	mulhu	a3,a5,s4
80009706:	9736                	add	a4,a4,a3
80009708:	8f99                	sub	a5,a5,a4
8000970a:	02b7b733          	mulhu	a4,a5,a1
8000970e:	02b787b3          	mul	a5,a5,a1
80009712:	00a786b3          	add	a3,a5,a0
80009716:	00f6b7b3          	sltu	a5,a3,a5
8000971a:	95be                	add	a1,a1,a5
8000971c:	972e                	add	a4,a4,a1
8000971e:	00170793          	add	a5,a4,1 # 40000001 <_flash_size+0x3ff00001>
80009722:	02fa0633          	mul	a2,s4,a5
80009726:	8d11                	sub	a0,a0,a2
80009728:	00a6f463          	bgeu	a3,a0,80009730 <.L139>
8000972c:	9552                	add	a0,a0,s4
8000972e:	87ba                	mv	a5,a4

80009730 <.L139>:
80009730:	01456363          	bltu	a0,s4,80009736 <.L140>
80009734:	0785                	add	a5,a5,1

80009736 <.L140>:
80009736:	8756                	mv	a4,s5
80009738:	b399                	j	8000947e <.L113>

8000973a <.L111>:
8000973a:	67c1                	lui	a5,0x10
8000973c:	4a81                	li	s5,0
8000973e:	00f6f563          	bgeu	a3,a5,80009748 <.L141>
80009742:	01069a13          	sll	s4,a3,0x10
80009746:	4ac1                	li	s5,16

80009748 <.L141>:
80009748:	010007b7          	lui	a5,0x1000
8000974c:	00fa7463          	bgeu	s4,a5,80009754 <.L142>
80009750:	0aa1                	add	s5,s5,8
80009752:	0a22                	sll	s4,s4,0x8

80009754 <.L142>:
80009754:	100007b7          	lui	a5,0x10000
80009758:	00fa7463          	bgeu	s4,a5,80009760 <.L143>
8000975c:	0a91                	add	s5,s5,4
8000975e:	0a12                	sll	s4,s4,0x4

80009760 <.L143>:
80009760:	400007b7          	lui	a5,0x40000
80009764:	00fa7463          	bgeu	s4,a5,8000976c <.L144>
80009768:	0a89                	add	s5,s5,2
8000976a:	0a0a                	sll	s4,s4,0x2

8000976c <.L144>:
8000976c:	000a4363          	bltz	s4,80009772 <.L145>
80009770:	0a85                	add	s5,s5,1

80009772 <.L145>:
80009772:	01f49793          	sll	a5,s1,0x1f
80009776:	8656                	mv	a2,s5
80009778:	00195a13          	srl	s4,s2,0x1
8000977c:	8522                	mv	a0,s0
8000977e:	85ce                	mv	a1,s3
80009780:	0147ea33          	or	s4,a5,s4
80009784:	38a1                	jal	80008fdc <__ashldi3>
80009786:	0165d613          	srl	a2,a1,0x16
8000978a:	800057b7          	lui	a5,0x80005
8000978e:	e0060613          	add	a2,a2,-512
80009792:	0606                	sll	a2,a2,0x1
80009794:	0b478793          	add	a5,a5,180 # 800050b4 <__SEGGER_RTL_Moeller_inverse_lut>
80009798:	97b2                	add	a5,a5,a2
8000979a:	0007d783          	lhu	a5,0(a5)
8000979e:	00b5d513          	srl	a0,a1,0xb
800097a2:	0015f713          	and	a4,a1,1
800097a6:	02f78633          	mul	a2,a5,a5
800097aa:	0792                	sll	a5,a5,0x4
800097ac:	0015d693          	srl	a3,a1,0x1
800097b0:	0505                	add	a0,a0,1
800097b2:	02a63633          	mulhu	a2,a2,a0
800097b6:	8f91                	sub	a5,a5,a2
800097b8:	0014db13          	srl	s6,s1,0x1
800097bc:	96ba                	add	a3,a3,a4
800097be:	17fd                	add	a5,a5,-1
800097c0:	c319                	beqz	a4,800097c6 <.L146>
800097c2:	0017d713          	srl	a4,a5,0x1

800097c6 <.L146>:
800097c6:	02f686b3          	mul	a3,a3,a5
800097ca:	8f15                	sub	a4,a4,a3
800097cc:	02e7b733          	mulhu	a4,a5,a4
800097d0:	07be                	sll	a5,a5,0xf
800097d2:	8305                	srl	a4,a4,0x1
800097d4:	97ba                	add	a5,a5,a4
800097d6:	872e                	mv	a4,a1
800097d8:	02b786b3          	mul	a3,a5,a1
800097dc:	9736                	add	a4,a4,a3
800097de:	00d736b3          	sltu	a3,a4,a3
800097e2:	872e                	mv	a4,a1
800097e4:	9736                	add	a4,a4,a3
800097e6:	02b7b6b3          	mulhu	a3,a5,a1
800097ea:	9736                	add	a4,a4,a3
800097ec:	8f99                	sub	a5,a5,a4
800097ee:	0367b733          	mulhu	a4,a5,s6
800097f2:	036787b3          	mul	a5,a5,s6
800097f6:	014786b3          	add	a3,a5,s4
800097fa:	00f6b7b3          	sltu	a5,a3,a5
800097fe:	97da                	add	a5,a5,s6
80009800:	973e                	add	a4,a4,a5
80009802:	00170793          	add	a5,a4,1
80009806:	02f58633          	mul	a2,a1,a5
8000980a:	40ca0a33          	sub	s4,s4,a2
8000980e:	0146f463          	bgeu	a3,s4,80009816 <.L147>
80009812:	9a2e                	add	s4,s4,a1
80009814:	87ba                	mv	a5,a4

80009816 <.L147>:
80009816:	00ba6363          	bltu	s4,a1,8000981c <.L148>
8000981a:	0785                	add	a5,a5,1

8000981c <.L148>:
8000981c:	477d                	li	a4,31
8000981e:	41570733          	sub	a4,a4,s5
80009822:	00e7d7b3          	srl	a5,a5,a4
80009826:	c391                	beqz	a5,8000982a <.L149>
80009828:	17fd                	add	a5,a5,-1

8000982a <.L149>:
8000982a:	0287b633          	mulhu	a2,a5,s0
8000982e:	02f98733          	mul	a4,s3,a5
80009832:	028786b3          	mul	a3,a5,s0
80009836:	9732                	add	a4,a4,a2
80009838:	40e48733          	sub	a4,s1,a4
8000983c:	40d906b3          	sub	a3,s2,a3
80009840:	00d93633          	sltu	a2,s2,a3
80009844:	8f11                	sub	a4,a4,a2
80009846:	c13761e3          	bltu	a4,s3,80009448 <.L174>
8000984a:	e2e994e3          	bne	s3,a4,80009672 <.L160>
8000984e:	be86ede3          	bltu	a3,s0,80009448 <.L174>
80009852:	b505                	j	80009672 <.L160>

80009854 <.L152>:
80009854:	87aa                	mv	a5,a0
80009856:	872e                	mv	a4,a1
80009858:	b11d                	j	8000947e <.L113>

8000985a <.L153>:
8000985a:	4781                	li	a5,0
8000985c:	b6f5                	j	80009448 <.L174>

Disassembly of section .text.libc.__clzsi2:

8000985e <__clzsi2>:
8000985e:	87aa                	mv	a5,a0
80009860:	6741                	lui	a4,0x10
80009862:	4501                	li	a0,0
80009864:	00e7f463          	bgeu	a5,a4,8000986c <.L307>
80009868:	07c2                	sll	a5,a5,0x10
8000986a:	4541                	li	a0,16

8000986c <.L307>:
8000986c:	01000737          	lui	a4,0x1000
80009870:	00e7f463          	bgeu	a5,a4,80009878 <.L308>
80009874:	0521                	add	a0,a0,8
80009876:	07a2                	sll	a5,a5,0x8

80009878 <.L308>:
80009878:	10000737          	lui	a4,0x10000
8000987c:	00e7f463          	bgeu	a5,a4,80009884 <.L309>
80009880:	0511                	add	a0,a0,4
80009882:	0792                	sll	a5,a5,0x4

80009884 <.L309>:
80009884:	40000737          	lui	a4,0x40000
80009888:	00e7f463          	bgeu	a5,a4,80009890 <.L310>
8000988c:	0509                	add	a0,a0,2
8000988e:	078a                	sll	a5,a5,0x2

80009890 <.L310>:
80009890:	0007c363          	bltz	a5,80009896 <.L311>
80009894:	0505                	add	a0,a0,1

80009896 <.L311>:
80009896:	8082                	ret

Disassembly of section .text.libc.abs:

80009898 <abs>:
80009898:	41f55793          	sra	a5,a0,0x1f
8000989c:	8d3d                	xor	a0,a0,a5
8000989e:	8d1d                	sub	a0,a0,a5
800098a0:	8082                	ret

Disassembly of section .text.libc.memcpy:

800098a2 <memcpy>:
800098a2:	c251                	beqz	a2,80009926 <.Lmemcpy_done>
800098a4:	87aa                	mv	a5,a0
800098a6:	00b546b3          	xor	a3,a0,a1
800098aa:	06fa                	sll	a3,a3,0x1e
800098ac:	e2bd                	bnez	a3,80009912 <.Lmemcpy_byte_copy>
800098ae:	01e51693          	sll	a3,a0,0x1e
800098b2:	ce81                	beqz	a3,800098ca <.Lmemcpy_aligned>

800098b4 <.Lmemcpy_word_align>:
800098b4:	00058683          	lb	a3,0(a1)
800098b8:	00d50023          	sb	a3,0(a0)
800098bc:	0585                	add	a1,a1,1
800098be:	0505                	add	a0,a0,1
800098c0:	167d                	add	a2,a2,-1
800098c2:	c22d                	beqz	a2,80009924 <.Lmemcpy_memcpy_end>
800098c4:	01e51693          	sll	a3,a0,0x1e
800098c8:	f6f5                	bnez	a3,800098b4 <.Lmemcpy_word_align>

800098ca <.Lmemcpy_aligned>:
800098ca:	02000693          	li	a3,32
800098ce:	02d66763          	bltu	a2,a3,800098fc <.Lmemcpy_word_copy>

800098d2 <.Lmemcpy_aligned_block_copy_loop>:
800098d2:	4198                	lw	a4,0(a1)
800098d4:	c118                	sw	a4,0(a0)
800098d6:	41d8                	lw	a4,4(a1)
800098d8:	c158                	sw	a4,4(a0)
800098da:	4598                	lw	a4,8(a1)
800098dc:	c518                	sw	a4,8(a0)
800098de:	45d8                	lw	a4,12(a1)
800098e0:	c558                	sw	a4,12(a0)
800098e2:	4998                	lw	a4,16(a1)
800098e4:	c918                	sw	a4,16(a0)
800098e6:	49d8                	lw	a4,20(a1)
800098e8:	c958                	sw	a4,20(a0)
800098ea:	4d98                	lw	a4,24(a1)
800098ec:	cd18                	sw	a4,24(a0)
800098ee:	4dd8                	lw	a4,28(a1)
800098f0:	cd58                	sw	a4,28(a0)
800098f2:	9536                	add	a0,a0,a3
800098f4:	95b6                	add	a1,a1,a3
800098f6:	8e15                	sub	a2,a2,a3
800098f8:	fcd67de3          	bgeu	a2,a3,800098d2 <.Lmemcpy_aligned_block_copy_loop>

800098fc <.Lmemcpy_word_copy>:
800098fc:	c605                	beqz	a2,80009924 <.Lmemcpy_memcpy_end>
800098fe:	4691                	li	a3,4
80009900:	00d66963          	bltu	a2,a3,80009912 <.Lmemcpy_byte_copy>

80009904 <.Lmemcpy_word_copy_loop>:
80009904:	4198                	lw	a4,0(a1)
80009906:	c118                	sw	a4,0(a0)
80009908:	9536                	add	a0,a0,a3
8000990a:	95b6                	add	a1,a1,a3
8000990c:	8e15                	sub	a2,a2,a3
8000990e:	fed67be3          	bgeu	a2,a3,80009904 <.Lmemcpy_word_copy_loop>

80009912 <.Lmemcpy_byte_copy>:
80009912:	ca09                	beqz	a2,80009924 <.Lmemcpy_memcpy_end>

80009914 <.Lmemcpy_byte_copy_loop>:
80009914:	00058703          	lb	a4,0(a1)
80009918:	00e50023          	sb	a4,0(a0)
8000991c:	0585                	add	a1,a1,1
8000991e:	0505                	add	a0,a0,1
80009920:	167d                	add	a2,a2,-1
80009922:	fa6d                	bnez	a2,80009914 <.Lmemcpy_byte_copy_loop>

80009924 <.Lmemcpy_memcpy_end>:
80009924:	853e                	mv	a0,a5

80009926 <.Lmemcpy_done>:
80009926:	8082                	ret

Disassembly of section .text.libc.strncmp:

80009928 <strncmp>:
80009928:	872a                	mv	a4,a0
8000992a:	10060c63          	beqz	a2,80009a42 <.L499>
8000992e:	00054683          	lbu	a3,0(a0)
80009932:	0005c783          	lbu	a5,0(a1)
80009936:	00f68563          	beq	a3,a5,80009940 <.L478>
8000993a:	40f68533          	sub	a0,a3,a5
8000993e:	8082                	ret

80009940 <.L478>:
80009940:	4501                	li	a0,0
80009942:	cefd                	beqz	a3,80009a40 <.L476>
80009944:	00b747b3          	xor	a5,a4,a1
80009948:	8b8d                	and	a5,a5,3
8000994a:	c3a5                	beqz	a5,800099aa <.L479>

8000994c <.L480>:
8000994c:	00377793          	and	a5,a4,3
80009950:	e7f9                	bnez	a5,80009a1e <.L487>
80009952:	4501                	li	a0,0
80009954:	c675                	beqz	a2,80009a40 <.L476>
80009956:	feff0837          	lui	a6,0xfeff0
8000995a:	80808537          	lui	a0,0x80808
8000995e:	488d                	li	a7,3
80009960:	eff80813          	add	a6,a6,-257 # fefefeff <__AHB_SRAM_segment_end__+0xebe7eff>
80009964:	08050513          	add	a0,a0,128 # 80808080 <__XPI0_segment_end__+0x708080>

80009968 <.L488>:
80009968:	0cc8fa63          	bgeu	a7,a2,80009a3c <.L489>
8000996c:	0035c783          	lbu	a5,3(a1)
80009970:	0025c303          	lbu	t1,2(a1)
80009974:	4314                	lw	a3,0(a4)
80009976:	07a2                	sll	a5,a5,0x8
80009978:	979a                	add	a5,a5,t1
8000997a:	0015c303          	lbu	t1,1(a1)
8000997e:	07a2                	sll	a5,a5,0x8
80009980:	979a                	add	a5,a5,t1
80009982:	0005c303          	lbu	t1,0(a1)
80009986:	07a2                	sll	a5,a5,0x8
80009988:	979a                	add	a5,a5,t1
8000998a:	02f69b63          	bne	a3,a5,800099c0 <.L482>
8000998e:	010687b3          	add	a5,a3,a6
80009992:	fff6c693          	not	a3,a3
80009996:	8ff5                	and	a5,a5,a3
80009998:	8fe9                	and	a5,a5,a0
8000999a:	e39d                	bnez	a5,800099c0 <.L482>
8000999c:	0711                	add	a4,a4,4 # 40000004 <_flash_size+0x3ff00004>
8000999e:	0591                	add	a1,a1,4
800099a0:	1671                	add	a2,a2,-4
800099a2:	b7d9                	j	80009968 <.L488>

800099a4 <.L483>:
800099a4:	0705                	add	a4,a4,1
800099a6:	0585                	add	a1,a1,1
800099a8:	167d                	add	a2,a2,-1

800099aa <.L479>:
800099aa:	00377793          	and	a5,a4,3
800099ae:	cf85                	beqz	a5,800099e6 <.L481>
800099b0:	ca49                	beqz	a2,80009a42 <.L499>
800099b2:	00074683          	lbu	a3,0(a4)
800099b6:	0005c783          	lbu	a5,0(a1)
800099ba:	00d79363          	bne	a5,a3,800099c0 <.L482>
800099be:	f3fd                	bnez	a5,800099a4 <.L483>

800099c0 <.L482>:
800099c0:	167d                	add	a2,a2,-1
800099c2:	4681                	li	a3,0

800099c4 <.L492>:
800099c4:	00d707b3          	add	a5,a4,a3
800099c8:	00d58533          	add	a0,a1,a3
800099cc:	0007c783          	lbu	a5,0(a5)
800099d0:	00054503          	lbu	a0,0(a0)
800099d4:	00c68663          	beq	a3,a2,800099e0 <.L491>
800099d8:	c781                	beqz	a5,800099e0 <.L491>
800099da:	0685                	add	a3,a3,1
800099dc:	fea784e3          	beq	a5,a0,800099c4 <.L492>

800099e0 <.L491>:
800099e0:	40a78533          	sub	a0,a5,a0
800099e4:	8082                	ret

800099e6 <.L481>:
800099e6:	4501                	li	a0,0
800099e8:	ce21                	beqz	a2,80009a40 <.L476>
800099ea:	feff0537          	lui	a0,0xfeff0
800099ee:	80808837          	lui	a6,0x80808
800099f2:	488d                	li	a7,3
800099f4:	eff50513          	add	a0,a0,-257 # fefefeff <__AHB_SRAM_segment_end__+0xebe7eff>
800099f8:	08080813          	add	a6,a6,128 # 80808080 <__XPI0_segment_end__+0x708080>

800099fc <.L485>:
800099fc:	04c8f063          	bgeu	a7,a2,80009a3c <.L489>
80009a00:	4314                	lw	a3,0(a4)
80009a02:	419c                	lw	a5,0(a1)
80009a04:	faf69ee3          	bne	a3,a5,800099c0 <.L482>
80009a08:	fff6c793          	not	a5,a3
80009a0c:	96aa                	add	a3,a3,a0
80009a0e:	8ff5                	and	a5,a5,a3
80009a10:	0107f7b3          	and	a5,a5,a6
80009a14:	f7d5                	bnez	a5,800099c0 <.L482>
80009a16:	0711                	add	a4,a4,4
80009a18:	0591                	add	a1,a1,4
80009a1a:	1671                	add	a2,a2,-4
80009a1c:	b7c5                	j	800099fc <.L485>

80009a1e <.L487>:
80009a1e:	c215                	beqz	a2,80009a42 <.L499>
80009a20:	00074783          	lbu	a5,0(a4)
80009a24:	0005c683          	lbu	a3,0(a1)
80009a28:	00d78563          	beq	a5,a3,80009a32 <.L486>
80009a2c:	40d78533          	sub	a0,a5,a3
80009a30:	8082                	ret

80009a32 <.L486>:
80009a32:	cb81                	beqz	a5,80009a42 <.L499>
80009a34:	0705                	add	a4,a4,1
80009a36:	0585                	add	a1,a1,1
80009a38:	167d                	add	a2,a2,-1
80009a3a:	bf09                	j	8000994c <.L480>

80009a3c <.L489>:
80009a3c:	4501                	li	a0,0
80009a3e:	f249                	bnez	a2,800099c0 <.L482>

80009a40 <.L476>:
80009a40:	8082                	ret

80009a42 <.L499>:
80009a42:	4501                	li	a0,0
80009a44:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_pow10f:

80009a46 <__SEGGER_RTL_pow10f>:
80009a46:	1101                	add	sp,sp,-32
80009a48:	cc22                	sw	s0,24(sp)
80009a4a:	c64e                	sw	s3,12(sp)
80009a4c:	ce06                	sw	ra,28(sp)
80009a4e:	ca26                	sw	s1,20(sp)
80009a50:	c84a                	sw	s2,16(sp)
80009a52:	842a                	mv	s0,a0
80009a54:	4981                	li	s3,0
80009a56:	00055563          	bgez	a0,80009a60 <.L17>
80009a5a:	40a00433          	neg	s0,a0
80009a5e:	4985                	li	s3,1

80009a60 <.L17>:
80009a60:	80005937          	lui	s2,0x80005
80009a64:	6ec92503          	lw	a0,1772(s2) # 800056ec <.Lmerged_single+0x4>
80009a68:	800054b7          	lui	s1,0x80005
80009a6c:	4b448493          	add	s1,s1,1204 # 800054b4 <__SEGGER_RTL_aPower2f>

80009a70 <.L18>:
80009a70:	ec19                	bnez	s0,80009a8e <.L20>
80009a72:	00098763          	beqz	s3,80009a80 <.L16>
80009a76:	85aa                	mv	a1,a0
80009a78:	6ec92503          	lw	a0,1772(s2)
80009a7c:	369030ef          	jal	8000d5e4 <__divsf3>

80009a80 <.L16>:
80009a80:	40f2                	lw	ra,28(sp)
80009a82:	4462                	lw	s0,24(sp)
80009a84:	44d2                	lw	s1,20(sp)
80009a86:	4942                	lw	s2,16(sp)
80009a88:	49b2                	lw	s3,12(sp)
80009a8a:	6105                	add	sp,sp,32
80009a8c:	8082                	ret

80009a8e <.L20>:
80009a8e:	00147793          	and	a5,s0,1
80009a92:	c781                	beqz	a5,80009a9a <.L19>
80009a94:	408c                	lw	a1,0(s1)
80009a96:	18f030ef          	jal	8000d424 <__mulsf3>

80009a9a <.L19>:
80009a9a:	8405                	sra	s0,s0,0x1
80009a9c:	0491                	add	s1,s1,4
80009a9e:	bfc9                	j	80009a70 <.L18>

Disassembly of section .text.libc.__SEGGER_RTL_prin_flush:

80009aa0 <__SEGGER_RTL_prin_flush>:
80009aa0:	4950                	lw	a2,20(a0)
80009aa2:	ce19                	beqz	a2,80009ac0 <.L20>
80009aa4:	511c                	lw	a5,32(a0)
80009aa6:	1141                	add	sp,sp,-16
80009aa8:	c422                	sw	s0,8(sp)
80009aaa:	c606                	sw	ra,12(sp)
80009aac:	842a                	mv	s0,a0
80009aae:	c399                	beqz	a5,80009ab4 <.L12>
80009ab0:	490c                	lw	a1,16(a0)
80009ab2:	9782                	jalr	a5

80009ab4 <.L12>:
80009ab4:	40b2                	lw	ra,12(sp)
80009ab6:	00042a23          	sw	zero,20(s0)
80009aba:	4422                	lw	s0,8(sp)
80009abc:	0141                	add	sp,sp,16
80009abe:	8082                	ret

80009ac0 <.L20>:
80009ac0:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_pre_padding:

80009ac2 <__SEGGER_RTL_pre_padding>:
80009ac2:	0105f793          	and	a5,a1,16
80009ac6:	eb91                	bnez	a5,80009ada <.L40>
80009ac8:	2005f793          	and	a5,a1,512
80009acc:	02000593          	li	a1,32
80009ad0:	c399                	beqz	a5,80009ad6 <.L42>
80009ad2:	03000593          	li	a1,48

80009ad6 <.L42>:
80009ad6:	56a0406f          	j	8000e040 <__SEGGER_RTL_print_padding>

80009ada <.L40>:
80009ada:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_init_prin_l:

80009adc <__SEGGER_RTL_init_prin_l>:
80009adc:	1141                	add	sp,sp,-16
80009ade:	c226                	sw	s1,4(sp)
80009ae0:	02400613          	li	a2,36
80009ae4:	84ae                	mv	s1,a1
80009ae6:	4581                	li	a1,0
80009ae8:	c422                	sw	s0,8(sp)
80009aea:	c606                	sw	ra,12(sp)
80009aec:	842a                	mv	s0,a0
80009aee:	02a040ef          	jal	8000db18 <memset>
80009af2:	40b2                	lw	ra,12(sp)
80009af4:	cc44                	sw	s1,28(s0)
80009af6:	4422                	lw	s0,8(sp)
80009af8:	4492                	lw	s1,4(sp)
80009afa:	0141                	add	sp,sp,16
80009afc:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_init_prin:

80009afe <__SEGGER_RTL_init_prin>:
80009afe:	1141                	add	sp,sp,-16
80009b00:	c422                	sw	s0,8(sp)
80009b02:	c606                	sw	ra,12(sp)
80009b04:	842a                	mv	s0,a0
80009b06:	34e050ef          	jal	8000ee54 <__SEGGER_RTL_current_locale>
80009b0a:	85aa                	mv	a1,a0
80009b0c:	8522                	mv	a0,s0
80009b0e:	4422                	lw	s0,8(sp)
80009b10:	40b2                	lw	ra,12(sp)
80009b12:	0141                	add	sp,sp,16
80009b14:	b7e1                	j	80009adc <__SEGGER_RTL_init_prin_l>

Disassembly of section .text.libc.vfprintf:

80009b16 <vfprintf>:
80009b16:	1101                	add	sp,sp,-32
80009b18:	cc22                	sw	s0,24(sp)
80009b1a:	ca26                	sw	s1,20(sp)
80009b1c:	ce06                	sw	ra,28(sp)
80009b1e:	84ae                	mv	s1,a1
80009b20:	842a                	mv	s0,a0
80009b22:	c632                	sw	a2,12(sp)
80009b24:	330050ef          	jal	8000ee54 <__SEGGER_RTL_current_locale>
80009b28:	85aa                	mv	a1,a0
80009b2a:	8522                	mv	a0,s0
80009b2c:	4462                	lw	s0,24(sp)
80009b2e:	46b2                	lw	a3,12(sp)
80009b30:	40f2                	lw	ra,28(sp)
80009b32:	8626                	mv	a2,s1
80009b34:	44d2                	lw	s1,20(sp)
80009b36:	6105                	add	sp,sp,32
80009b38:	56c0406f          	j	8000e0a4 <vfprintf_l>

Disassembly of section .text.libc.printf:

80009b3c <printf>:
80009b3c:	7139                	add	sp,sp,-64
80009b3e:	da3e                	sw	a5,52(sp)
80009b40:	000807b7          	lui	a5,0x80
80009b44:	d22e                	sw	a1,36(sp)
80009b46:	85aa                	mv	a1,a0
80009b48:	2687a503          	lw	a0,616(a5) # 80268 <stdout>
80009b4c:	d432                	sw	a2,40(sp)
80009b4e:	1050                	add	a2,sp,36
80009b50:	ce06                	sw	ra,28(sp)
80009b52:	d636                	sw	a3,44(sp)
80009b54:	d83a                	sw	a4,48(sp)
80009b56:	dc42                	sw	a6,56(sp)
80009b58:	de46                	sw	a7,60(sp)
80009b5a:	c632                	sw	a2,12(sp)
80009b5c:	3f6d                	jal	80009b16 <vfprintf>
80009b5e:	40f2                	lw	ra,28(sp)
80009b60:	6121                	add	sp,sp,64
80009b62:	8082                	ret

Disassembly of section .segger.init.__SEGGER_init_heap:

80009b64 <__SEGGER_init_heap>:
80009b64:	00097537          	lui	a0,0x97
80009b68:	cb850513          	add	a0,a0,-840 # 96cb8 <__heap_start__>
80009b6c:	000995b7          	lui	a1,0x99
80009b70:	cb858593          	add	a1,a1,-840 # 98cb8 <__heap_end__>
80009b74:	8d89                	sub	a1,a1,a0
80009b76:	a009                	j	80009b78 <__SEGGER_RTL_init_heap>

Disassembly of section .text.libc.__SEGGER_RTL_init_heap:

80009b78 <__SEGGER_RTL_init_heap>:
80009b78:	479d                	li	a5,7
80009b7a:	00b7f763          	bgeu	a5,a1,80009b88 <.L68>
80009b7e:	68a1ac23          	sw	a0,1688(gp) # 81a08 <__SEGGER_RTL_heap_globals>
80009b82:	00052023          	sw	zero,0(a0)
80009b86:	c14c                	sw	a1,4(a0)

80009b88 <.L68>:
80009b88:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_toupper:

80009b8a <__SEGGER_RTL_ascii_toupper>:
80009b8a:	f9f50713          	add	a4,a0,-97
80009b8e:	47e5                	li	a5,25
80009b90:	00e7e363          	bltu	a5,a4,80009b96 <.L5>
80009b94:	1501                	add	a0,a0,-32

80009b96 <.L5>:
80009b96:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_towupper:

80009b98 <__SEGGER_RTL_ascii_towupper>:
80009b98:	f9f50713          	add	a4,a0,-97
80009b9c:	47e5                	li	a5,25
80009b9e:	00e7e363          	bltu	a5,a4,80009ba4 <.L12>
80009ba2:	1501                	add	a0,a0,-32

80009ba4 <.L12>:
80009ba4:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_mbtowc:

80009ba6 <__SEGGER_RTL_ascii_mbtowc>:
80009ba6:	87aa                	mv	a5,a0
80009ba8:	4501                	li	a0,0
80009baa:	c195                	beqz	a1,80009bce <.L55>
80009bac:	c20d                	beqz	a2,80009bce <.L55>
80009bae:	0005c703          	lbu	a4,0(a1)
80009bb2:	07f00613          	li	a2,127
80009bb6:	5579                	li	a0,-2
80009bb8:	00e66b63          	bltu	a2,a4,80009bce <.L55>
80009bbc:	c391                	beqz	a5,80009bc0 <.L57>
80009bbe:	c398                	sw	a4,0(a5)

80009bc0 <.L57>:
80009bc0:	0006a023          	sw	zero,0(a3)
80009bc4:	0006a223          	sw	zero,4(a3)
80009bc8:	00e03533          	snez	a0,a4
80009bcc:	8082                	ret

80009bce <.L55>:
80009bce:	8082                	ret

Disassembly of section .text.board_init:

80009bd0 <board_init>:
{
80009bd0:	1141                	add	sp,sp,-16
80009bd2:	c606                	sw	ra,12(sp)
    init_xtal_pins();
80009bd4:	a60fc0ef          	jal	80005e34 <init_xtal_pins>
    init_py_pins_as_pgpio();
80009bd8:	a5efc0ef          	jal	80005e36 <init_py_pins_as_pgpio>
    board_init_usb_dp_dm_pins();
80009bdc:	f3bfb0ef          	jal	80005b16 <board_init_usb_dp_dm_pins>
    board_init_clock();
80009be0:	820fc0ef          	jal	80005c00 <board_init_clock>
    board_init_console();
80009be4:	b3ffb0ef          	jal	80005722 <board_init_console>
    board_print_clock_freq();
80009be8:	c37fb0ef          	jal	8000581e <board_print_clock_freq>
80009bec:	40b2                	lw	ra,12(sp)
    board_print_banner();
80009bee:	0141                	add	sp,sp,16
80009bf0:	b8ffb06f          	j	8000577e <board_print_banner>

Disassembly of section .text.board_timer_create:

80009bf4 <board_timer_create>:
{
80009bf4:	7179                	add	sp,sp,-48
80009bf6:	d606                	sw	ra,44(sp)
80009bf8:	d422                	sw	s0,40(sp)
80009bfa:	d226                	sw	s1,36(sp)
80009bfc:	d04a                	sw	s2,32(sp)
80009bfe:	842a                	mv	s0,a0
    timer_cb = cb;
80009c00:	64b1ac23          	sw	a1,1624(gp) # 819c8 <timer_cb>
    gptmr_channel_get_default_config(BOARD_CALLBACK_TIMER, &config);
80009c04:	f0004537          	lui	a0,0xf0004
80009c08:	002c                	add	a1,sp,8
80009c0a:	f0004937          	lui	s2,0xf0004
80009c0e:	9dffc0ef          	jal	800065ec <gptmr_channel_get_default_config>
80009c12:	010e04b7          	lui	s1,0x10e0
80009c16:	04a9                	add	s1,s1,10 # 10e000a <_flash_size+0xfe000a>
    clock_add_to_group(BOARD_CALLBACK_TIMER_CLK_NAME, 0);
80009c18:	8526                	mv	a0,s1
80009c1a:	4581                	li	a1,0
80009c1c:	29a030ef          	jal	8000ceb6 <clock_add_to_group>
    gptmr_freq = clock_get_frequency(BOARD_CALLBACK_TIMER_CLK_NAME);
80009c20:	8526                	mv	a0,s1
80009c22:	98ffe0ef          	jal	800085b0 <clock_get_frequency>
80009c26:	106255b7          	lui	a1,0x10625
80009c2a:	dd358593          	add	a1,a1,-557 # 10624dd3 <_flash_size+0x10524dd3>
    config.reload = gptmr_freq / 1000 * ms;
80009c2e:	02b53533          	mulhu	a0,a0,a1
80009c32:	8119                	srl	a0,a0,0x6
80009c34:	02850533          	mul	a0,a0,s0
80009c38:	ca2a                	sw	a0,20(sp)
    gptmr_channel_config(BOARD_CALLBACK_TIMER, BOARD_CALLBACK_TIMER_CH, &config, false);
80009c3a:	f0004537          	lui	a0,0xf0004
80009c3e:	0030                	add	a2,sp,8
80009c40:	4581                	li	a1,0
80009c42:	4681                	li	a3,0
80009c44:	9cbfc0ef          	jal	8000660e <gptmr_channel_config>
 * @param [in] ptr GPTMR base address
 * @param [in] irq_mask irq mask
 */
static inline void gptmr_enable_irq(GPTMR_Type *ptr, uint32_t irq_mask)
{
    ptr->IRQEN |= irq_mask;
80009c48:	20492503          	lw	a0,516(s2) # f0004204 <__XPI0_segment_end__+0x6ff04204>
80009c4c:	00156513          	or	a0,a0,1
80009c50:	20a92223          	sw	a0,516(s2)
80009c54:	e4000537          	lui	a0,0xe4000
80009c58:	4585                	li	a1,1
    *priority_ptr = priority;
80009c5a:	cd0c                	sw	a1,24(a0)
80009c5c:	e4002537          	lui	a0,0xe4002
    uint32_t current = *current_ptr;
80009c60:	410c                	lw	a1,0(a0)
    current = current | (1 << (irq & 0x1F));
80009c62:	0405e593          	or	a1,a1,64
    *current_ptr = current;
80009c66:	c10c                	sw	a1,0(a0)
 * @param [in] ptr GPTMR base address
 * @param [in] ch_index channel index
 */
static inline void gptmr_start_counter(GPTMR_Type *ptr, uint8_t ch_index)
{
    ptr->CHANNEL[ch_index].CR |= GPTMR_CHANNEL_CR_CEN_MASK;
80009c68:	00092503          	lw	a0,0(s2)
80009c6c:	40056513          	or	a0,a0,1024
80009c70:	00a92023          	sw	a0,0(s2)
80009c74:	50b2                	lw	ra,44(sp)
80009c76:	5422                	lw	s0,40(sp)
80009c78:	5492                	lw	s1,36(sp)
80009c7a:	5902                	lw	s2,32(sp)
}
80009c7c:	6145                	add	sp,sp,48
80009c7e:	8082                	ret

Disassembly of section .text.board_init_gpio_pins:

80009c80 <board_init_gpio_pins>:
{
80009c80:	1141                	add	sp,sp,-16
80009c82:	c606                	sw	ra,12(sp)
    init_gpio_pins();
80009c84:	20c5                	jal	80009d64 <init_gpio_pins>
80009c86:	f00d0537          	lui	a0,0xf00d0
80009c8a:	45a1                	li	a1,8
 * @param port Port index
 * @param pin Pin index
 */
static inline void gpio_set_pin_input(GPIO_Type *ptr, uint32_t port, uint8_t pin)
{
    ptr->OE[port].CLEAR = 1 << pin;
80009c8c:	20b52423          	sw	a1,520(a0) # f00d0208 <__XPI0_segment_end__+0x6ffd0208>
80009c90:	40b2                	lw	ra,12(sp)
}
80009c92:	0141                	add	sp,sp,16
80009c94:	8082                	ret

Disassembly of section .text.board_init_led_pins:

80009c96 <board_init_led_pins>:
{
80009c96:	1141                	add	sp,sp,-16
80009c98:	c606                	sw	ra,12(sp)
    init_led_pins_as_gpio();
80009c9a:	9f0fc0ef          	jal	80005e8a <init_led_pins_as_gpio>
    gpio_set_pin_output_with_initial(BOARD_LED_USB_IN_GPIO_CTRL, BOARD_LED_USB_IN_GPIO_INDEX, BOARD_LED_USB_IN_GPIO_PIN, board_get_led_gpio_off_level());
80009c9e:	f00d0537          	lui	a0,0xf00d0
80009ca2:	4585                	li	a1,1
80009ca4:	4635                	li	a2,13
80009ca6:	4685                	li	a3,1
80009ca8:	25a9                	jal	8000a2f2 <gpio_set_pin_output_with_initial>
    gpio_set_pin_output_with_initial(BOARD_LED_USB_OUT_GPIO_CTRL, BOARD_LED_USB_OUT_GPIO_INDEX, BOARD_LED_USB_OUT_GPIO_PIN, board_get_led_gpio_off_level());
80009caa:	f00d0537          	lui	a0,0xf00d0
80009cae:	4585                	li	a1,1
80009cb0:	4631                	li	a2,12
80009cb2:	4685                	li	a3,1
80009cb4:	2d3d                	jal	8000a2f2 <gpio_set_pin_output_with_initial>
    gpio_set_pin_output_with_initial(BOARD_DE_EN_GPIO_CTRL, BOARD_DE_EN_GPIO_INDEX, BOARD_DE_EN_GPIO_PIN, 0);
80009cb6:	f00d0537          	lui	a0,0xf00d0
80009cba:	4585                	li	a1,1
80009cbc:	462d                	li	a2,11
80009cbe:	4681                	li	a3,0
80009cc0:	2d0d                	jal	8000a2f2 <gpio_set_pin_output_with_initial>
    gpio_set_pin_output_with_initial(BOARD_RE_EN_GPIO_CTRL, BOARD_RE_EN_GPIO_INDEX, BOARD_RE_EN_GPIO_PIN, 0);
80009cc2:	f00d0537          	lui	a0,0xf00d0
80009cc6:	4585                	li	a1,1
80009cc8:	4629                	li	a2,10
80009cca:	4681                	li	a3,0
80009ccc:	40b2                	lw	ra,12(sp)
80009cce:	0141                	add	sp,sp,16
80009cd0:	a50d                	j	8000a2f2 <gpio_set_pin_output_with_initial>

Disassembly of section .text.board_init_usb_pins:

80009cd2 <board_init_usb_pins>:
{
80009cd2:	1141                	add	sp,sp,-16
80009cd4:	c606                	sw	ra,12(sp)
80009cd6:	c422                	sw	s0,8(sp)
    init_usb_pins();
80009cd8:	97cfc0ef          	jal	80005e54 <init_usb_pins>
80009cdc:	f300c437          	lui	s0,0xf300c
 * @param[in] high true - vbus high level enable, false - vbus low level enable
 */
static inline void usb_hcd_set_power_ctrl_polarity(USB_Type *ptr, bool high)
{
    if (high) {
        ptr->OTG_CTRL0 |= USB_OTG_CTRL0_OTG_POWER_MASK_MASK;
80009ce0:	20042503          	lw	a0,512(s0) # f300c200 <__AHB_SRAM_segment_end__+0x2c04200>
80009ce4:	20056513          	or	a0,a0,512
80009ce8:	20a42023          	sw	a0,512(s0)
    clock_cpu_delay_ms(ms);
80009cec:	06400513          	li	a0,100
80009cf0:	ad5fe0ef          	jal	800087c4 <clock_cpu_delay_ms>
    ptr->PHY_CTRL0 |= (USB_PHY_CTRL0_VBUS_VALID_OVERRIDE_MASK | USB_PHY_CTRL0_SESS_VALID_OVERRIDE_MASK)
80009cf4:	21042503          	lw	a0,528(s0)
80009cf8:	658d                	lui	a1,0x3
80009cfa:	058d                	add	a1,a1,3 # 3003 <.LBB4_14+0xb>
80009cfc:	8d4d                	or	a0,a0,a1
80009cfe:	20a42823          	sw	a0,528(s0)
80009d02:	40b2                	lw	ra,12(sp)
80009d04:	4422                	lw	s0,8(sp)
}
80009d06:	0141                	add	sp,sp,16
80009d08:	8082                	ret

Disassembly of section .text.board_init_uart:

80009d0a <board_init_uart>:
{
80009d0a:	1141                	add	sp,sp,-16
80009d0c:	c606                	sw	ra,12(sp)
80009d0e:	c422                	sw	s0,8(sp)
80009d10:	842a                	mv	s0,a0
    init_uart_pins(ptr);
80009d12:	2039                	jal	80009d20 <init_uart_pins>
    board_init_uart_clock(ptr);
80009d14:	8522                	mv	a0,s0
80009d16:	40b2                	lw	ra,12(sp)
80009d18:	4422                	lw	s0,8(sp)
80009d1a:	0141                	add	sp,sp,16
80009d1c:	8c6fc06f          	j	80005de2 <board_init_uart_clock>

Disassembly of section .text.init_uart_pins:

80009d20 <init_uart_pins>:
{
80009d20:	f00405b7          	lui	a1,0xf0040
    if (ptr == HPM_UART0) {
80009d24:	02b50863          	beq	a0,a1,80009d54 <.LBB2_5>
80009d28:	f00485b7          	lui	a1,0xf0048
80009d2c:	00b50d63          	beq	a0,a1,80009d46 <.LBB2_4>
80009d30:	f004c5b7          	lui	a1,0xf004c
80009d34:	02b51763          	bne	a0,a1,80009d62 <.LBB2_7>
80009d38:	f40405b7          	lui	a1,0xf4040
80009d3c:	17058513          	add	a0,a1,368 # f4040170 <__AHB_SRAM_segment_end__+0x3c38170>
80009d40:	17858593          	add	a1,a1,376
80009d44:	a821                	j	80009d5c <.LBB2_6>

80009d46 <.LBB2_4>:
80009d46:	f40405b7          	lui	a1,0xf4040
80009d4a:	14858513          	add	a0,a1,328 # f4040148 <__AHB_SRAM_segment_end__+0x3c38148>
80009d4e:	14058593          	add	a1,a1,320
80009d52:	a029                	j	80009d5c <.LBB2_6>

80009d54 <.LBB2_5>:
80009d54:	f40405b7          	lui	a1,0xf4040
80009d58:	00858513          	add	a0,a1,8 # f4040008 <__AHB_SRAM_segment_end__+0x3c38008>

80009d5c <.LBB2_6>:
80009d5c:	4609                	li	a2,2
80009d5e:	c190                	sw	a2,0(a1)
80009d60:	c110                	sw	a2,0(a0)

80009d62 <.LBB2_7>:
}
80009d62:	8082                	ret

Disassembly of section .text.init_gpio_pins:

80009d64 <init_gpio_pins>:
{
80009d64:	f4040537          	lui	a0,0xf4040
    HPM_IOC->PAD[IOC_PAD_PA03].FUNC_CTL = IOC_PA03_FUNC_CTL_GPIO_A_03;
80009d68:	00052c23          	sw	zero,24(a0) # f4040018 <__AHB_SRAM_segment_end__+0x3c38018>
80009d6c:	010205b7          	lui	a1,0x1020
    HPM_IOC->PAD[IOC_PAD_PA03].PAD_CTL = pad_ctl;
80009d70:	cd4c                	sw	a1,28(a0)
}
80009d72:	8082                	ret

Disassembly of section .text.console_init:

80009d74 <console_init>:
#include "hpm_uart_drv.h"

static UART_Type* g_console_uart = NULL;

hpm_stat_t console_init(console_config_t *cfg)
{
80009d74:	7179                	add	sp,sp,-48
80009d76:	d606                	sw	ra,44(sp)
80009d78:	d422                	sw	s0,40(sp)
80009d7a:	842a                	mv	s0,a0
    hpm_stat_t stat = status_fail;

    if (cfg->type == CONSOLE_TYPE_UART) {
80009d7c:	410c                	lw	a1,0(a0)
80009d7e:	4505                	li	a0,1
80009d80:	e595                	bnez	a1,80009dac <.LBB0_3>
        uart_config_t config = {0};
80009d82:	d202                	sw	zero,36(sp)
80009d84:	d002                	sw	zero,32(sp)
80009d86:	ce02                	sw	zero,28(sp)
80009d88:	cc02                	sw	zero,24(sp)
        uart_default_config((UART_Type *)cfg->base, &config);
80009d8a:	4048                	lw	a0,4(s0)
        uart_config_t config = {0};
80009d8c:	ca02                	sw	zero,20(sp)
80009d8e:	c802                	sw	zero,16(sp)
80009d90:	c602                	sw	zero,12(sp)
        uart_default_config((UART_Type *)cfg->base, &config);
80009d92:	006c                	add	a1,sp,12
80009d94:	2d99                	jal	8000a3ea <uart_default_config>
        config.src_freq_in_hz = cfg->src_freq_in_hz;
80009d96:	440c                	lw	a1,8(s0)
        config.baudrate = cfg->baudrate;
80009d98:	4450                	lw	a2,12(s0)
        stat = uart_init((UART_Type *)cfg->base, &config);
80009d9a:	4048                	lw	a0,4(s0)
        config.src_freq_in_hz = cfg->src_freq_in_hz;
80009d9c:	c62e                	sw	a1,12(sp)
        config.baudrate = cfg->baudrate;
80009d9e:	c832                	sw	a2,16(sp)
        stat = uart_init((UART_Type *)cfg->base, &config);
80009da0:	006c                	add	a1,sp,12
80009da2:	2571                	jal	8000a42e <uart_init>
        if (status_success == stat) {
80009da4:	e501                	bnez	a0,80009dac <.LBB0_3>
            g_console_uart = (UART_Type *)cfg->base;
80009da6:	404c                	lw	a1,4(s0)
80009da8:	6ab1a823          	sw	a1,1712(gp) # 81a20 <g_console_uart>

80009dac <.LBB0_3>:
80009dac:	50b2                	lw	ra,44(sp)
80009dae:	5422                	lw	s0,40(sp)
        }
    }

    return stat;
80009db0:	6145                	add	sp,sp,48
80009db2:	8082                	ret

Disassembly of section .text.__SEGGER_RTL_X_file_write:

80009db4 <__SEGGER_RTL_X_file_write>:
FILE *stdin  = &__SEGGER_RTL_stdin_file;  /* NOTE: Provide implementation of stdin for RTL. */
FILE *stdout = &__SEGGER_RTL_stdout_file; /* NOTE: Provide implementation of stdout for RTL. */
FILE *stderr = &__SEGGER_RTL_stderr_file; /* NOTE: Provide implementation of stderr for RTL. */

int __SEGGER_RTL_X_file_write(__SEGGER_RTL_FILE *file, const char *data, unsigned int size)
{
80009db4:	1101                	add	sp,sp,-32
80009db6:	ce06                	sw	ra,28(sp)
80009db8:	cc22                	sw	s0,24(sp)
80009dba:	ca26                	sw	s1,20(sp)
80009dbc:	c84a                	sw	s2,16(sp)
80009dbe:	c64e                	sw	s3,12(sp)
80009dc0:	c452                	sw	s4,8(sp)
80009dc2:	c256                	sw	s5,4(sp)
80009dc4:	8932                	mv	s2,a2
    unsigned int count;
    (void)file;
    for (count = 0; count < size; count++) {
80009dc6:	ca15                	beqz	a2,80009dfa <.LBB3_6>
80009dc8:	8a2e                	mv	s4,a1
80009dca:	4a81                	li	s5,0
80009dcc:	49a9                	li	s3,10

80009dce <.LBB3_2>:
        if (data[count] == '\n') {
80009dce:	015a0433          	add	s0,s4,s5
80009dd2:	00044503          	lbu	a0,0(s0)
80009dd6:	01351863          	bne	a0,s3,80009de6 <.LBB3_4>

80009dda <.LBB3_3>:
            while (status_success != uart_send_byte(g_console_uart, '\r')) {
80009dda:	6b01a503          	lw	a0,1712(gp) # 81a20 <g_console_uart>
80009dde:	45b5                	li	a1,13
80009de0:	ac1fc0ef          	jal	800068a0 <uart_send_byte>
80009de4:	f97d                	bnez	a0,80009dda <.LBB3_3>

80009de6 <.LBB3_4>:
            }
        }
        while (status_success != uart_send_byte(g_console_uart, data[count])) {
80009de6:	6b01a503          	lw	a0,1712(gp) # 81a20 <g_console_uart>
80009dea:	00044583          	lbu	a1,0(s0)
80009dee:	ab3fc0ef          	jal	800068a0 <uart_send_byte>
80009df2:	f975                	bnez	a0,80009de6 <.LBB3_4>
    for (count = 0; count < size; count++) {
80009df4:	0a85                	add	s5,s5,1
80009df6:	fd2a9ce3          	bne	s5,s2,80009dce <.LBB3_2>

80009dfa <.LBB3_6>:
        }
    }
    while (status_success != uart_flush(g_console_uart)) {
80009dfa:	6b01a503          	lw	a0,1712(gp) # 81a20 <g_console_uart>
80009dfe:	27e1                	jal	8000a5c6 <uart_flush>
80009e00:	fd6d                	bnez	a0,80009dfa <.LBB3_6>
    }
    return count;
80009e02:	854a                	mv	a0,s2
80009e04:	40f2                	lw	ra,28(sp)
80009e06:	4462                	lw	s0,24(sp)
80009e08:	44d2                	lw	s1,20(sp)
80009e0a:	4942                	lw	s2,16(sp)
80009e0c:	49b2                	lw	s3,12(sp)
80009e0e:	4a22                	lw	s4,8(sp)
80009e10:	4a92                	lw	s5,4(sp)
80009e12:	6105                	add	sp,sp,32
80009e14:	8082                	ret

Disassembly of section .text.__SEGGER_RTL_X_file_stat:

80009e16 <__SEGGER_RTL_X_file_stat>:
}

int __SEGGER_RTL_X_file_stat(__SEGGER_RTL_FILE *stream)
{
    (void) stream;
    return 0;
80009e16:	4501                	li	a0,0
80009e18:	8082                	ret

Disassembly of section .text.__SEGGER_RTL_X_file_bufsize:

80009e1a <__SEGGER_RTL_X_file_bufsize>:
}

int __SEGGER_RTL_X_file_bufsize(__SEGGER_RTL_FILE *stream)
{
    (void) stream;
    return 1;
80009e1a:	4505                	li	a0,1
80009e1c:	8082                	ret

Disassembly of section .text.dma_mgr_enable_dma_irq_with_priority:

80009e1e <dma_mgr_enable_dma_irq_with_priority>:
{
80009e1e:	88aa                	mv	a7,a0
80009e20:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
80009e22:	06088d63          	beqz	a7,80009e9c <.LBB5_7>
80009e26:	0048a803          	lw	a6,4(a7)
80009e2a:	467d                	li	a2,31
80009e2c:	07066863          	bltu	a2,a6,80009e9c <.LBB5_7>
80009e30:	00080637          	lui	a2,0x80
80009e34:	2e862283          	lw	t0,744(a2) # 802e8 <s_dma_mngr_ctx>
80009e38:	4781                	li	a5,0
80009e3a:	4605                	li	a2,1

80009e3c <.LBB5_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
80009e3c:	8a05                	and	a2,a2,1
80009e3e:	ce39                	beqz	a2,80009e9c <.LBB5_7>
80009e40:	86be                	mv	a3,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
80009e42:	0008a703          	lw	a4,0(a7)
80009e46:	4601                	li	a2,0
80009e48:	4785                	li	a5,1
80009e4a:	fe5719e3          	bne	a4,t0,80009e3c <.LBB5_3>
80009e4e:	02400613          	li	a2,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80009e52:	02c80633          	mul	a2,a6,a2
80009e56:	48000713          	li	a4,1152
80009e5a:	02e686b3          	mul	a3,a3,a4
80009e5e:	00080737          	lui	a4,0x80
80009e62:	2e870713          	add	a4,a4,744 # 802e8 <s_dma_mngr_ctx>
80009e66:	96ba                	add	a3,a3,a4
80009e68:	9636                	add	a2,a2,a3
80009e6a:	00864603          	lbu	a2,8(a2)
80009e6e:	c61d                	beqz	a2,80009e9c <.LBB5_7>
        intc_m_enable_irq_with_priority(resource->irq_num, priority);
80009e70:	0088a503          	lw	a0,8(a7)
                                                             ((irq - 1) << HPM_PLIC_PRIORITY_SHIFT_PER_SOURCE));
80009e74:	050a                	sll	a0,a0,0x2
                                                             HPM_PLIC_PRIORITY_OFFSET +
80009e76:	e4000637          	lui	a2,0xe4000
80009e7a:	9532                	add	a0,a0,a2
    *priority_ptr = priority;
80009e7c:	c10c                	sw	a1,0(a0)
80009e7e:	0088a583          	lw	a1,8(a7)
                                                            ((irq >> 5) << 2));
80009e82:	0035d513          	srl	a0,a1,0x3
80009e86:	9971                	and	a0,a0,-4
                                                            (target << HPM_PLIC_ENABLE_SHIFT_PER_TARGET) +
80009e88:	e4002637          	lui	a2,0xe4002
80009e8c:	962a                	add	a2,a2,a0
    uint32_t current = *current_ptr;
80009e8e:	4214                	lw	a3,0(a2)
80009e90:	4501                	li	a0,0
80009e92:	4705                	li	a4,1
    current = current | (1 << (irq & 0x1F));
80009e94:	00b715b3          	sll	a1,a4,a1
80009e98:	8dd5                	or	a1,a1,a3
    *current_ptr = current;
80009e9a:	c20c                	sw	a1,0(a2)

80009e9c <.LBB5_7>:
    return status;
80009e9c:	8082                	ret

Disassembly of section .text.dma_mgr_get_default_chn_config:

80009e9e <dma_mgr_get_default_chn_config>:
{
80009e9e:	001e05b7          	lui	a1,0x1e0
    config->dmamux_src = 0;
80009ea2:	c50c                	sw	a1,8(a0)
80009ea4:	00052223          	sw	zero,4(a0)
80009ea8:	00052023          	sw	zero,0(a0)
    config->src_addr = 0;
80009eac:	00052623          	sw	zero,12(a0)
80009eb0:	00052823          	sw	zero,16(a0)
80009eb4:	00052a23          	sw	zero,20(a0)
80009eb8:	00052c23          	sw	zero,24(a0)
    config->en_infiniteloop = false;
80009ebc:	00051e23          	sh	zero,28(a0)
    config->burst_opt = DMA_MGR_SRC_BURST_OPT_STANDAND_SIZE;
80009ec0:	00050f23          	sb	zero,30(a0)
}
80009ec4:	8082                	ret

Disassembly of section .text.dma_mgr_setup_channel:

80009ec6 <dma_mgr_setup_channel>:
{
80009ec6:	4889                	li	a7,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
80009ec8:	c569                	beqz	a0,80009f92 <.LBB12_7>
80009eca:	82aa                	mv	t0,a0
80009ecc:	00452803          	lw	a6,4(a0)
80009ed0:	457d                	li	a0,31
80009ed2:	0d056063          	bltu	a0,a6,80009f92 <.LBB12_7>
80009ed6:	00080537          	lui	a0,0x80
80009eda:	2e852503          	lw	a0,744(a0) # 802e8 <s_dma_mngr_ctx>
80009ede:	4781                	li	a5,0
80009ee0:	4685                	li	a3,1

80009ee2 <.LBB12_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
80009ee2:	8a85                	and	a3,a3,1
80009ee4:	c6dd                	beqz	a3,80009f92 <.LBB12_7>
80009ee6:	873e                	mv	a4,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
80009ee8:	0002a603          	lw	a2,0(t0)
80009eec:	4681                	li	a3,0
80009eee:	4785                	li	a5,1
80009ef0:	fea619e3          	bne	a2,a0,80009ee2 <.LBB12_3>
80009ef4:	02400613          	li	a2,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80009ef8:	02c80633          	mul	a2,a6,a2
80009efc:	48000693          	li	a3,1152
80009f00:	02d706b3          	mul	a3,a4,a3
80009f04:	00080737          	lui	a4,0x80
80009f08:	2e870713          	add	a4,a4,744 # 802e8 <s_dma_mngr_ctx>
80009f0c:	96ba                	add	a3,a3,a4
80009f0e:	9636                	add	a2,a2,a3
80009f10:	00864603          	lbu	a2,8(a2) # e4002008 <__XPI0_segment_end__+0x63f02008>
80009f14:	ce3d                	beqz	a2,80009f92 <.LBB12_7>
80009f16:	7179                	add	sp,sp,-48
80009f18:	d606                	sw	ra,44(sp)
        dmamux_config(HPM_DMAMUX, dmamux_ch, config->dmamux_src, config->en_dmamux);
80009f1a:	0005c603          	lbu	a2,0(a1) # 1e0000 <_flash_size+0xe0000>
80009f1e:	0015c683          	lbu	a3,1(a1)
80009f22:	00c03633          	snez	a2,a2
 * @param[in] src DMAMUX source
 * @param[in] enable Set true to enable the channel
 */
static inline void dmamux_config(DMAMUX_Type *ptr, uint8_t ch_index, uint8_t src,  bool enable)
{
    ptr->MUXCFG[ch_index] = DMAMUX_MUXCFG_SOURCE_SET(src)
80009f26:	07f6f693          	and	a3,a3,127
                       | DMAMUX_MUXCFG_ENABLE_SET(enable);
80009f2a:	067e                	sll	a2,a2,0x1f
80009f2c:	8e55                	or	a2,a2,a3
    ptr->MUXCFG[ch_index] = DMAMUX_MUXCFG_SOURCE_SET(src)
80009f2e:	080a                	sll	a6,a6,0x2
80009f30:	f00c46b7          	lui	a3,0xf00c4
80009f34:	96c2                	add	a3,a3,a6
80009f36:	c290                	sw	a2,0(a3)
        dma_config.priority = config->priority;
80009f38:	00259603          	lh	a2,2(a1)
        dma_config.src_mode = config->src_mode;
80009f3c:	00459683          	lh	a3,4(a1)
        dma_config.src_width = config->src_width;
80009f40:	00659703          	lh	a4,6(a1)
        dma_config.src_addr_ctrl = config->src_addr_ctrl;
80009f44:	00859783          	lh	a5,8(a1)
        dma_config.priority = config->priority;
80009f48:	00c11623          	sh	a2,12(sp)
        dma_config.src_mode = config->src_mode;
80009f4c:	00d11723          	sh	a3,14(sp)
        dma_config.src_width = config->src_width;
80009f50:	00e11823          	sh	a4,16(sp)
        dma_config.src_addr_ctrl = config->src_addr_ctrl;
80009f54:	00f11923          	sh	a5,18(sp)
        dma_config.src_addr = config->src_addr;
80009f58:	45d0                	lw	a2,12(a1)
        dma_config.dst_addr = config->dst_addr;
80009f5a:	4994                	lw	a3,16(a1)
        dma_config.size_in_byte = config->size_in_byte;
80009f5c:	4d98                	lw	a4,24(a1)
        dma_config.linked_ptr = config->linked_ptr;
80009f5e:	49dc                	lw	a5,20(a1)
        dma_config.src_addr = config->src_addr;
80009f60:	cc32                	sw	a2,24(sp)
        dma_config.dst_addr = config->dst_addr;
80009f62:	ce36                	sw	a3,28(sp)
        dma_config.size_in_byte = config->size_in_byte;
80009f64:	d23a                	sw	a4,36(sp)
        dma_config.linked_ptr = config->linked_ptr;
80009f66:	d03e                	sw	a5,32(sp)
        dma_config.interrupt_mask = config->interrupt_mask;
80009f68:	00a59603          	lh	a2,10(a1)
        dma_config.en_infiniteloop = config->en_infiniteloop;
80009f6c:	01c59683          	lh	a3,28(a1)
        dma_config.burst_opt = config->burst_opt;
80009f70:	01e5c703          	lbu	a4,30(a1)
        status = dma_setup_channel(resource->base, resource->channel, &dma_config, false);
80009f74:	0042c583          	lbu	a1,4(t0)
        dma_config.interrupt_mask = config->interrupt_mask;
80009f78:	00c11a23          	sh	a2,20(sp)
        dma_config.en_infiniteloop = config->en_infiniteloop;
80009f7c:	02d11423          	sh	a3,40(sp)
        dma_config.burst_opt = config->burst_opt;
80009f80:	02e10523          	sb	a4,42(sp)
        status = dma_setup_channel(resource->base, resource->channel, &dma_config, false);
80009f84:	0070                	add	a2,sp,12
80009f86:	4681                	li	a3,0
80009f88:	c08fc0ef          	jal	80006390 <dma_setup_channel>
80009f8c:	88aa                	mv	a7,a0
80009f8e:	50b2                	lw	ra,44(sp)
80009f90:	6145                	add	sp,sp,48

80009f92 <.LBB12_7>:
    return status;
80009f92:	8546                	mv	a0,a7
80009f94:	8082                	ret

Disassembly of section .text.dma_mgr_config_linked_descriptor:

80009f96 <dma_mgr_config_linked_descriptor>:
{
80009f96:	4889                	li	a7,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
80009f98:	c55d                	beqz	a0,8000a046 <.LBB13_7>
80009f9a:	82aa                	mv	t0,a0
80009f9c:	00452803          	lw	a6,4(a0)
80009fa0:	457d                	li	a0,31
80009fa2:	0b056263          	bltu	a0,a6,8000a046 <.LBB13_7>
80009fa6:	00080537          	lui	a0,0x80
80009faa:	2e852503          	lw	a0,744(a0) # 802e8 <s_dma_mngr_ctx>
80009fae:	4781                	li	a5,0
80009fb0:	4705                	li	a4,1

80009fb2 <.LBB13_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
80009fb2:	8b05                	and	a4,a4,1
80009fb4:	cb49                	beqz	a4,8000a046 <.LBB13_7>
80009fb6:	86be                	mv	a3,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
80009fb8:	0002a303          	lw	t1,0(t0)
80009fbc:	4701                	li	a4,0
80009fbe:	4785                	li	a5,1
80009fc0:	fea319e3          	bne	t1,a0,80009fb2 <.LBB13_3>
80009fc4:	02400713          	li	a4,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
80009fc8:	02e80733          	mul	a4,a6,a4
80009fcc:	48000793          	li	a5,1152
80009fd0:	02f686b3          	mul	a3,a3,a5
80009fd4:	000807b7          	lui	a5,0x80
80009fd8:	2e878793          	add	a5,a5,744 # 802e8 <s_dma_mngr_ctx>
80009fdc:	96be                	add	a3,a3,a5
80009fde:	96ba                	add	a3,a3,a4
80009fe0:	0086c683          	lbu	a3,8(a3) # f00c4008 <__XPI0_segment_end__+0x6ffc4008>
80009fe4:	c2ad                	beqz	a3,8000a046 <.LBB13_7>
80009fe6:	7179                	add	sp,sp,-48
80009fe8:	d606                	sw	ra,44(sp)
        dma_config.priority = config->priority;
80009fea:	00259683          	lh	a3,2(a1)
        dma_config.src_mode = config->src_mode;
80009fee:	00459703          	lh	a4,4(a1)
        dma_config.src_width = config->src_width;
80009ff2:	00659783          	lh	a5,6(a1)
        dma_config.priority = config->priority;
80009ff6:	00d11623          	sh	a3,12(sp)
        dma_config.src_mode = config->src_mode;
80009ffa:	00e11723          	sh	a4,14(sp)
        dma_config.src_width = config->src_width;
80009ffe:	00f11823          	sh	a5,16(sp)
        dma_config.src_addr_ctrl = config->src_addr_ctrl;
8000a002:	00859883          	lh	a7,8(a1)
        dma_config.src_addr = config->src_addr;
8000a006:	45d8                	lw	a4,12(a1)
        dma_config.dst_addr = config->dst_addr;
8000a008:	499c                	lw	a5,16(a1)
        dma_config.size_in_byte = config->size_in_byte;
8000a00a:	4d94                	lw	a3,24(a1)
        dma_config.src_addr_ctrl = config->src_addr_ctrl;
8000a00c:	01111923          	sh	a7,18(sp)
        dma_config.src_addr = config->src_addr;
8000a010:	cc3a                	sw	a4,24(sp)
        dma_config.dst_addr = config->dst_addr;
8000a012:	ce3e                	sw	a5,28(sp)
        dma_config.size_in_byte = config->size_in_byte;
8000a014:	d236                	sw	a3,36(sp)
        dma_config.linked_ptr = config->linked_ptr;
8000a016:	49d4                	lw	a3,20(a1)
        dma_config.interrupt_mask = config->interrupt_mask;
8000a018:	00a59703          	lh	a4,10(a1)
        dma_config.en_infiniteloop = config->en_infiniteloop;
8000a01c:	01c59783          	lh	a5,28(a1)
        dma_config.burst_opt = config->burst_opt;
8000a020:	01e5c583          	lbu	a1,30(a1)
        dma_config.linked_ptr = config->linked_ptr;
8000a024:	d036                	sw	a3,32(sp)
        dma_config.interrupt_mask = config->interrupt_mask;
8000a026:	00e11a23          	sh	a4,20(sp)
        dma_config.en_infiniteloop = config->en_infiniteloop;
8000a02a:	02f11423          	sh	a5,40(sp)
        dma_config.burst_opt = config->burst_opt;
8000a02e:	02b10523          	sb	a1,42(sp)
        status = dma_config_linked_descriptor(resource->base, (dma_linked_descriptor_t *)descriptor, resource->channel, &dma_config);
8000a032:	0ff87713          	zext.b	a4,a6
8000a036:	0074                	add	a3,sp,12
8000a038:	85b2                	mv	a1,a2
8000a03a:	863a                	mv	a2,a4
8000a03c:	c92fc0ef          	jal	800064ce <dma_config_linked_descriptor>
8000a040:	88aa                	mv	a7,a0
8000a042:	50b2                	lw	ra,44(sp)
8000a044:	6145                	add	sp,sp,48

8000a046 <.LBB13_7>:
    return status;
8000a046:	8546                	mv	a0,a7
8000a048:	8082                	ret

Disassembly of section .text.dma_mgr_disable_channel:

8000a04a <dma_mgr_disable_channel>:
{
8000a04a:	85aa                	mv	a1,a0
8000a04c:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
8000a04e:	cda9                	beqz	a1,8000a0a8 <.LBB15_7>
8000a050:	0045a803          	lw	a6,4(a1)
8000a054:	467d                	li	a2,31
8000a056:	05066963          	bltu	a2,a6,8000a0a8 <.LBB15_7>
8000a05a:	00080637          	lui	a2,0x80
8000a05e:	2e862883          	lw	a7,744(a2) # 802e8 <s_dma_mngr_ctx>
8000a062:	4781                	li	a5,0
8000a064:	4605                	li	a2,1

8000a066 <.LBB15_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
8000a066:	8a05                	and	a2,a2,1
8000a068:	c221                	beqz	a2,8000a0a8 <.LBB15_7>
8000a06a:	873e                	mv	a4,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
8000a06c:	4194                	lw	a3,0(a1)
8000a06e:	4601                	li	a2,0
8000a070:	4785                	li	a5,1
8000a072:	ff169ae3          	bne	a3,a7,8000a066 <.LBB15_3>
8000a076:	02400593          	li	a1,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
8000a07a:	02b805b3          	mul	a1,a6,a1
8000a07e:	48000613          	li	a2,1152
8000a082:	02c70633          	mul	a2,a4,a2
8000a086:	000806b7          	lui	a3,0x80
8000a08a:	2e868693          	add	a3,a3,744 # 802e8 <s_dma_mngr_ctx>
8000a08e:	9636                	add	a2,a2,a3
8000a090:	95b2                	add	a1,a1,a2
8000a092:	0085c583          	lbu	a1,8(a1)
8000a096:	c989                	beqz	a1,8000a0a8 <.LBB15_7>
    ptr->CHCTRL[ch_index].CTRL &= ~DMAV2_CHCTRL_CTRL_ENABLE_MASK;
8000a098:	0816                	sll	a6,a6,0x5
8000a09a:	9846                	add	a6,a6,a7
8000a09c:	04082583          	lw	a1,64(a6)
8000a0a0:	4501                	li	a0,0
8000a0a2:	99f9                	and	a1,a1,-2
8000a0a4:	04b82023          	sw	a1,64(a6)

8000a0a8 <.LBB15_7>:
    return status;
8000a0a8:	8082                	ret

Disassembly of section .text.dma_mgr_enable_chn_irq:

8000a0aa <dma_mgr_enable_chn_irq>:
{
8000a0aa:	82aa                	mv	t0,a0
8000a0ac:	4509                	li	a0,2
    if ((resource != NULL) && (resource->channel < DMA_SOC_CHANNEL_NUM)) {
8000a0ae:	06028363          	beqz	t0,8000a114 <.LBB17_7>
8000a0b2:	0042a803          	lw	a6,4(t0)
8000a0b6:	46fd                	li	a3,31
8000a0b8:	0506ee63          	bltu	a3,a6,8000a114 <.LBB17_7>
8000a0bc:	000806b7          	lui	a3,0x80
8000a0c0:	2e86a883          	lw	a7,744(a3) # 802e8 <s_dma_mngr_ctx>
8000a0c4:	4781                	li	a5,0
8000a0c6:	4705                	li	a4,1

8000a0c8 <.LBB17_3>:
        for (instance = 0; instance < DMA_SOC_MAX_COUNT; instance++) {
8000a0c8:	8b05                	and	a4,a4,1
8000a0ca:	c729                	beqz	a4,8000a114 <.LBB17_7>
8000a0cc:	86be                	mv	a3,a5
            if (resource->base == HPM_DMA_MGR->dma_instance[instance].base) {
8000a0ce:	0002a603          	lw	a2,0(t0)
8000a0d2:	4701                	li	a4,0
8000a0d4:	4785                	li	a5,1
8000a0d6:	ff1619e3          	bne	a2,a7,8000a0c8 <.LBB17_3>
8000a0da:	02400613          	li	a2,36
            if (HPM_DMA_MGR->channels[instance][channel].is_allocated) {
8000a0de:	02c80633          	mul	a2,a6,a2
8000a0e2:	48000713          	li	a4,1152
8000a0e6:	02e686b3          	mul	a3,a3,a4
8000a0ea:	00080737          	lui	a4,0x80
8000a0ee:	2e870713          	add	a4,a4,744 # 802e8 <s_dma_mngr_ctx>
8000a0f2:	96ba                	add	a3,a3,a4
8000a0f4:	9636                	add	a2,a2,a3
8000a0f6:	00864603          	lbu	a2,8(a2)
8000a0fa:	ce09                	beqz	a2,8000a114 <.LBB17_7>
    ptr->CHCTRL[ch_index].CTRL &= ~(interrupt_mask & DMA_INTERRUPT_MASK_ALL);
8000a0fc:	0816                	sll	a6,a6,0x5
8000a0fe:	9846                	add	a6,a6,a7
8000a100:	04082603          	lw	a2,64(a6)
8000a104:	4501                	li	a0,0
8000a106:	fff5c593          	not	a1,a1
8000a10a:	fe15e593          	or	a1,a1,-31
8000a10e:	8df1                	and	a1,a1,a2
8000a110:	04b82023          	sw	a1,64(a6)

8000a114 <.LBB17_7>:
    return status;
8000a114:	8082                	ret

Disassembly of section .text.usb_device_qhd_get:

8000a116 <usb_device_qhd_get>:
    return &handle->dcd_data->qhd[ep_idx];
8000a116:	4148                	lw	a0,4(a0)
8000a118:	059a                	sll	a1,a1,0x6
8000a11a:	952e                	add	a0,a0,a1
8000a11c:	8082                	ret

Disassembly of section .text.usb_device_status_flags:

8000a11e <usb_device_status_flags>:
    return usb_get_status_flags(handle->regs);
8000a11e:	4108                	lw	a0,0(a0)
    return ptr->USBSTS;
8000a120:	14452503          	lw	a0,324(a0)
8000a124:	8082                	ret

Disassembly of section .text.usb_device_clear_status_flags:

8000a126 <usb_device_clear_status_flags>:
    usb_clear_status_flags(handle->regs, mask);
8000a126:	4108                	lw	a0,0(a0)
    ptr->USBSTS = mask;
8000a128:	14b52223          	sw	a1,324(a0)
}
8000a12c:	8082                	ret

Disassembly of section .text.usb_device_interrupts:

8000a12e <usb_device_interrupts>:
    return usb_get_interrupts(handle->regs);
8000a12e:	4108                	lw	a0,0(a0)
    return ptr->USBINTR;
8000a130:	14852503          	lw	a0,328(a0)
8000a134:	8082                	ret

Disassembly of section .text.usb_device_get_suspend_status:

8000a136 <usb_device_get_suspend_status>:
    return usb_get_suspend_status(handle->regs);
8000a136:	4108                	lw	a0,0(a0)
    return USB_PORTSC1_SUSP_GET(ptr->PORTSC1);
8000a138:	18452503          	lw	a0,388(a0)
8000a13c:	0562                	sll	a0,a0,0x18
8000a13e:	817d                	srl	a0,a0,0x1f
8000a140:	8082                	ret

Disassembly of section .text.usb_device_edpt_xfer:

8000a142 <usb_device_edpt_xfer>:
{
8000a142:	7139                	add	sp,sp,-64
8000a144:	de06                	sw	ra,60(sp)
8000a146:	dc22                	sw	s0,56(sp)
8000a148:	da26                	sw	s1,52(sp)
8000a14a:	d84a                	sw	s2,48(sp)
8000a14c:	d64e                	sw	s3,44(sp)
8000a14e:	d452                	sw	s4,40(sp)
8000a150:	d256                	sw	s5,36(sp)
8000a152:	d05a                	sw	s6,32(sp)
8000a154:	ce5e                	sw	s7,28(sp)
8000a156:	cc62                	sw	s8,24(sp)
8000a158:	ca66                	sw	s9,20(sp)
8000a15a:	c86a                	sw	s10,16(sp)
8000a15c:	c66e                	sw	s11,12(sp)
    uint8_t const epnum = ep_addr & 0x0f;
8000a15e:	00f5f793          	and	a5,a1,15
8000a162:	8aaa                	mv	s5,a0
    if (epnum == 0) {
8000a164:	e799                	bnez	a5,8000a172 <.LBB11_3>
8000a166:	000aa503          	lw	a0,0(s5)

8000a16a <.LBB11_2>:
    return ptr->ENDPTSETUPSTAT;
8000a16a:	1ac52703          	lw	a4,428(a0)
        while (usb_dcd_get_edpt_setup_status(handle->regs) & HPM_BITSMASK(1, 0)) {
8000a16e:	8b05                	and	a4,a4,1
8000a170:	ff6d                	bnez	a4,8000a16a <.LBB11_2>

8000a172 <.LBB11_3>:
8000a172:	6e11                	lui	t3,0x4
8000a174:	fffe0513          	add	a0,t3,-1 # 3fff <.LBB0_2+0x39>
    qtd_num = (total_bytes + 0x3fff) / 0x4000;
8000a178:	9536                	add	a0,a0,a3
8000a17a:	003fc737          	lui	a4,0x3fc
    if (qtd_num > USB_SOC_DCD_QTD_COUNT_EACH_ENDPOINT) {
8000a17e:	00e57933          	and	s2,a0,a4
8000a182:	00020537          	lui	a0,0x20
8000a186:	13256463          	bltu	a0,s2,8000a2ae <.LBB11_18>
8000a18a:	4c81                	li	s9,0
8000a18c:	4b01                	li	s6,0
8000a18e:	4b81                	li	s7,0
8000a190:	0075d513          	srl	a0,a1,0x7
8000a194:	0786                	sll	a5,a5,0x1
8000a196:	00a7ea33          	or	s4,a5,a0
    p_qhd = &handle->dcd_data->qhd[ep_idx];
8000a19a:	004aa503          	lw	a0,4(s5)
8000a19e:	c42a                	sw	a0,8(sp)
8000a1a0:	003a1f13          	sll	t5,s4,0x3
    do {
8000a1a4:	008a1513          	sll	a0,s4,0x8
8000a1a8:	7ff50893          	add	a7,a0,2047 # 207ff <__DLM_segment_size__+0x7ff>
8000a1ac:	08b5                	add	a7,a7,13
8000a1ae:	01088293          	add	t0,a7,16
8000a1b2:	7371                	lui	t1,0xffffc
8000a1b4:	4385                	li	t2,1
8000a1b6:	80010fb7          	lui	t6,0x80010
8000a1ba:	1ffd                	add	t6,t6,-1 # 8000ffff <.L.str.8+0xa>
8000a1bc:	6ea1                	lui	t4,0x8
8000a1be:	79fd                	lui	s3,0xfffff
8000a1c0:	6505                	lui	a0,0x1
8000a1c2:	a809                	j	8000a1d4 <.LBB11_6>

8000a1c4 <.LBB11_5>:
8000a1c4:	0c85                	add	s9,s9,1
8000a1c6:	006086b3          	add	a3,ra,t1
8000a1ca:	9662                	add	a2,a2,s8
8000a1cc:	8b3a                	mv	s6,a4
8000a1ce:	8ba2                	mv	s7,s0
    } while (total_bytes > 0);
8000a1d0:	0a1e7563          	bgeu	t3,ra,8000a27a <.LBB11_15>

8000a1d4 <.LBB11_6>:
8000a1d4:	6711                	lui	a4,0x4
8000a1d6:	80b6                	mv	ra,a3
8000a1d8:	8c36                	mv	s8,a3
        if (total_bytes > 0x4000) {
8000a1da:	00e6e363          	bltu	a3,a4,8000a1e0 <.LBB11_8>
8000a1de:	6c11                	lui	s8,0x4

8000a1e0 <.LBB11_8>:
8000a1e0:	004aad83          	lw	s11,4(s5)
8000a1e4:	0ffcfd13          	zext.b	s10,s9
8000a1e8:	01af06b3          	add	a3,t5,s10
8000a1ec:	0696                	sll	a3,a3,0x5
8000a1ee:	96ee                	add	a3,a3,s11
8000a1f0:	7ff68813          	add	a6,a3,2047
8000a1f4:	00180413          	add	s0,a6,1
    memset(p_qtd, 0, sizeof(dcd_qtd_t));
8000a1f8:	00042223          	sw	zero,4(s0)
8000a1fc:	00042e23          	sw	zero,28(s0)
8000a200:	00042c23          	sw	zero,24(s0)
8000a204:	00042a23          	sw	zero,20(s0)
8000a208:	00042823          	sw	zero,16(s0)
8000a20c:	00042623          	sw	zero,12(s0)
8000a210:	00042423          	sw	zero,8(s0)
    p_qtd->next        = USB_SOC_DCD_QTD_NEXT_INVALID;
8000a214:	007820a3          	sw	t2,1(a6)
    p_qtd->active      = 1;
8000a218:	4058                	lw	a4,4(s0)
8000a21a:	08076713          	or	a4,a4,128
8000a21e:	c058                	sw	a4,4(s0)
    p_qtd->total_bytes = p_qtd->expected_bytes = total_bytes;
8000a220:	01841e23          	sh	s8,28(s0)
8000a224:	4058                	lw	a4,4(s0)
8000a226:	010c1793          	sll	a5,s8,0x10
8000a22a:	01f77733          	and	a4,a4,t6
8000a22e:	8f5d                	or	a4,a4,a5
8000a230:	c058                	sw	a4,4(s0)
    if (data_ptr != NULL) {
8000a232:	c60d                	beqz	a2,8000a25c <.LBB11_11>
8000a234:	005d1793          	sll	a5,s10,0x5
        p_qtd->buffer[0]   = (uint32_t)data_ptr;
8000a238:	00c824a3          	sw	a2,9(a6)
        for (uint8_t i = 1; i < USB_SOC_DCD_QHD_BUFFER_COUNT; i++) {
8000a23c:	011d8733          	add	a4,s11,a7
8000a240:	973e                	add	a4,a4,a5
8000a242:	9d96                	add	s11,s11,t0
8000a244:	97ee                	add	a5,a5,s11

8000a246 <.LBB11_10>:
            p_qtd->buffer[i] |= ((p_qtd->buffer[i-1]) & 0xFFFFF000UL) + 4096U;
8000a246:	ffc72683          	lw	a3,-4(a4) # 3ffc <.LBB0_2+0x36>
8000a24a:	4304                	lw	s1,0(a4)
8000a24c:	0136f6b3          	and	a3,a3,s3
8000a250:	96aa                	add	a3,a3,a0
8000a252:	8ec5                	or	a3,a3,s1
8000a254:	c314                	sw	a3,0(a4)
        for (uint8_t i = 1; i < USB_SOC_DCD_QHD_BUFFER_COUNT; i++) {
8000a256:	0711                	add	a4,a4,4
8000a258:	fef717e3          	bne	a4,a5,8000a246 <.LBB11_10>

8000a25c <.LBB11_11>:
        if (total_bytes == 0) {
8000a25c:	001e6863          	bltu	t3,ra,8000a26c <.LBB11_13>
            p_qtd->int_on_complete = true;
8000a260:	00582683          	lw	a3,5(a6)
8000a264:	01d6e6b3          	or	a3,a3,t4
8000a268:	00d822a3          	sw	a3,5(a6)

8000a26c <.LBB11_13>:
8000a26c:	8722                	mv	a4,s0
        if (prev_p_qtd) {
8000a26e:	f40b8be3          	beqz	s7,8000a1c4 <.LBB11_5>
            prev_p_qtd->next = (uint32_t)p_qtd;
8000a272:	008ba023          	sw	s0,0(s7)
8000a276:	875a                	mv	a4,s6
8000a278:	b7b1                	j	8000a1c4 <.LBB11_5>

8000a27a <.LBB11_15>:
    p_qhd->qtd_overlay.next = core_local_mem_to_sys_address(0, (uint32_t) first_p_qtd); /* link qtd to qhd */
8000a27a:	006a1413          	sll	s0,s4,0x6
8000a27e:	4522                	lw	a0,8(sp)
8000a280:	942a                	add	s0,s0,a0
8000a282:	c418                	sw	a4,8(s0)
    if (usb_dcd_edpt_get_type(handle->regs, ep_addr) == usb_xfer_isochronous) {
8000a284:	000aa503          	lw	a0,0(s5)
8000a288:	817fc0ef          	jal	80006a9e <usb_dcd_edpt_get_type>
8000a28c:	4585                	li	a1,1
8000a28e:	00b51963          	bne	a0,a1,8000a2a0 <.LBB11_17>
        p_qhd->iso_mult = 1;
8000a292:	4008                	lw	a0,0(s0)
8000a294:	050a                	sll	a0,a0,0x2
8000a296:	8109                	srl	a0,a0,0x2
8000a298:	400005b7          	lui	a1,0x40000
8000a29c:	8d4d                	or	a0,a0,a1
8000a29e:	c008                	sw	a0,0(s0)

8000a2a0 <.LBB11_17>:
    usb_dcd_edpt_xfer(handle->regs, ep_idx);
8000a2a0:	000aa503          	lw	a0,0(s5)
8000a2a4:	85d2                	mv	a1,s4
8000a2a6:	813fc0ef          	jal	80006ab8 <usb_dcd_edpt_xfer>
8000a2aa:	00020537          	lui	a0,0x20

8000a2ae <.LBB11_18>:
8000a2ae:	0505                	add	a0,a0,1 # 20001 <__DLM_segment_size__+0x1>
    if (qtd_num > USB_SOC_DCD_QTD_COUNT_EACH_ENDPOINT) {
8000a2b0:	00a93533          	sltu	a0,s2,a0
8000a2b4:	50f2                	lw	ra,60(sp)
8000a2b6:	5462                	lw	s0,56(sp)
8000a2b8:	54d2                	lw	s1,52(sp)
8000a2ba:	5942                	lw	s2,48(sp)
8000a2bc:	59b2                	lw	s3,44(sp)
8000a2be:	5a22                	lw	s4,40(sp)
8000a2c0:	5a92                	lw	s5,36(sp)
8000a2c2:	5b02                	lw	s6,32(sp)
8000a2c4:	4bf2                	lw	s7,28(sp)
8000a2c6:	4c62                	lw	s8,24(sp)
8000a2c8:	4cd2                	lw	s9,20(sp)
8000a2ca:	4d42                	lw	s10,16(sp)
8000a2cc:	4db2                	lw	s11,12(sp)
}
8000a2ce:	6121                	add	sp,sp,64
8000a2d0:	8082                	ret

Disassembly of section .text.usb_device_get_edpt_complete_status:

8000a2d2 <usb_device_get_edpt_complete_status>:
    return usb_dcd_get_edpt_complete_status(handle->regs);
8000a2d2:	4108                	lw	a0,0(a0)
    return ptr->ENDPTCOMPLETE;
8000a2d4:	1bc52503          	lw	a0,444(a0)
8000a2d8:	8082                	ret

Disassembly of section .text.usb_device_clear_edpt_complete_status:

8000a2da <usb_device_clear_edpt_complete_status>:
    usb_dcd_clear_edpt_complete_status(handle->regs, mask);
8000a2da:	4108                	lw	a0,0(a0)
    ptr->ENDPTCOMPLETE = mask;
8000a2dc:	1ab52e23          	sw	a1,444(a0)
}
8000a2e0:	8082                	ret

Disassembly of section .text.usb_device_get_setup_status:

8000a2e2 <usb_device_get_setup_status>:
    return usb_dcd_get_edpt_setup_status(handle->regs);
8000a2e2:	4108                	lw	a0,0(a0)
    return ptr->ENDPTSETUPSTAT;
8000a2e4:	1ac52503          	lw	a0,428(a0)
8000a2e8:	8082                	ret

Disassembly of section .text.usb_device_clear_setup_status:

8000a2ea <usb_device_clear_setup_status>:
    usb_dcd_clear_edpt_setup_status(handle->regs, mask);
8000a2ea:	4108                	lw	a0,0(a0)
    ptr->ENDPTSETUPSTAT = mask;
8000a2ec:	1ab52623          	sw	a1,428(a0)
}
8000a2f0:	8082                	ret

Disassembly of section .text.gpio_set_pin_output_with_initial:

8000a2f2 <gpio_set_pin_output_with_initial>:
    }
}

void gpio_set_pin_output_with_initial(GPIO_Type *ptr, uint32_t port, uint8_t pin, uint8_t initial)
{
    if (initial & 1) {
8000a2f2:	0016f713          	and	a4,a3,1
8000a2f6:	4685                	li	a3,1
8000a2f8:	00c69633          	sll	a2,a3,a2
8000a2fc:	0592                	sll	a1,a1,0x4
8000a2fe:	46a1                	li	a3,8
8000a300:	c311                	beqz	a4,8000a304 <.LBB3_2>
8000a302:	4691                	li	a3,4

8000a304 <.LBB3_2>:
8000a304:	952e                	add	a0,a0,a1
8000a306:	96aa                	add	a3,a3,a0
8000a308:	10c6a023          	sw	a2,256(a3)
        ptr->DO[port].SET = 1 << pin;
    } else {
        ptr->DO[port].CLEAR = 1 << pin;
    }
    ptr->OE[port].SET = 1 << pin;
8000a30c:	20c52223          	sw	a2,516(a0)
}
8000a310:	8082                	ret

Disassembly of section .text.pllctlv2_init_pll_with_freq:

8000a312 <pllctlv2_init_pll_with_freq>:
{
8000a312:	4689                	li	a3,2
    if ((ptr == NULL) || (freq_in_hz < PLLCTLV2_PLL_FREQ_MIN) || (freq_in_hz > PLLCTLV2_PLL_FREQ_MAX) ||
8000a314:	06d5f363          	bgeu	a1,a3,8000a37a <.LBB0_6>
8000a318:	c12d                	beqz	a0,8000a37a <.LBB0_6>
8000a31a:	c27cf737          	lui	a4,0xc27cf
8000a31e:	dff70713          	add	a4,a4,-513 # c27cedff <__XPI0_segment_end__+0x426cedff>
8000a322:	9732                	add	a4,a4,a2
8000a324:	d96057b7          	lui	a5,0xd9605
8000a328:	dff78793          	add	a5,a5,-513 # d9604dff <__XPI0_segment_end__+0x59504dff>
8000a32c:	04f76763          	bltu	a4,a5,8000a37a <.LBB0_6>
8000a330:	165ea6b7          	lui	a3,0x165ea
8000a334:	f8168693          	add	a3,a3,-127 # 165e9f81 <_flash_size+0x164e9f81>
        uint32_t mfi = freq_in_hz / PLLCTLV2_PLL_XTAL_FREQ;
8000a338:	02d63733          	mulhu	a4,a2,a3
8000a33c:	8355                	srl	a4,a4,0x15
8000a33e:	016e3837          	lui	a6,0x16e3
        if (PLLCTLV2_PLL_MFI_MFI_GET(ptr->PLL[pll].MFI) == mfi) {
8000a342:	00759793          	sll	a5,a1,0x7
8000a346:	97aa                	add	a5,a5,a0
8000a348:	0807a883          	lw	a7,128(a5)
8000a34c:	60080693          	add	a3,a6,1536 # 16e3600 <_flash_size+0x15e3600>
8000a350:	02d706b3          	mul	a3,a4,a3
8000a354:	8e15                	sub	a2,a2,a3
8000a356:	07f8f693          	and	a3,a7,127
8000a35a:	08078793          	add	a5,a5,128
8000a35e:	00e69563          	bne	a3,a4,8000a368 <.LBB0_5>
            ptr->PLL[pll].MFI = mfi - 1U;
8000a362:	fff70693          	add	a3,a4,-1
8000a366:	c394                	sw	a3,0(a5)

8000a368 <.LBB0_5>:
8000a368:	4681                	li	a3,0
        ptr->PLL[pll].MFI = mfi;
8000a36a:	c398                	sw	a4,0(a5)
8000a36c:	4729                	li	a4,10
        ptr->PLL[pll].MFN = mfn * PLLCTLV2_PLL_MFN_FACTOR;
8000a36e:	02e60633          	mul	a2,a2,a4
8000a372:	059e                	sll	a1,a1,0x7
8000a374:	952e                	add	a0,a0,a1
8000a376:	08c52223          	sw	a2,132(a0)

8000a37a <.LBB0_6>:
    return status;
8000a37a:	8536                	mv	a0,a3
8000a37c:	8082                	ret

Disassembly of section .text.pllctlv2_get_pll_postdiv_freq_in_hz:

8000a37e <pllctlv2_get_pll_postdiv_freq_in_hz>:
}

uint32_t pllctlv2_get_pll_postdiv_freq_in_hz(PLLCTLV2_Type *ptr, uint8_t pll, uint8_t div_index)
{
8000a37e:	4681                	li	a3,0
    uint32_t postdiv_freq = 0;
    if ((ptr != NULL) && (pll < PLLCTL_SOC_PLL_MAX_COUNT)) {
8000a380:	c13d                	beqz	a0,8000a3e6 <.LBB4_3>
8000a382:	4705                	li	a4,1
8000a384:	06b76163          	bltu	a4,a1,8000a3e6 <.LBB4_3>
8000a388:	1141                	add	sp,sp,-16
8000a38a:	c606                	sw	ra,12(sp)
8000a38c:	c422                	sw	s0,8(sp)
8000a38e:	c226                	sw	s1,4(sp)
8000a390:	c04a                	sw	s2,0(sp)
        uint32_t postdiv = PLLCTLV2_PLL_DIV_DIV_GET(ptr->PLL[pll].DIV[div_index]);
8000a392:	00759693          	sll	a3,a1,0x7
8000a396:	96aa                	add	a3,a3,a0
8000a398:	060a                	sll	a2,a2,0x2
8000a39a:	9636                	add	a2,a2,a3
8000a39c:	0c062603          	lw	a2,192(a2)
8000a3a0:	03f67413          	and	s0,a2,63
        uint32_t pll_freq = pllctlv2_get_pll_freq_in_hz(ptr, pll);
8000a3a4:	b74fc0ef          	jal	80006718 <pllctlv2_get_pll_freq_in_hz>
        postdiv_freq = (uint32_t) (pll_freq / (1U + postdiv * 1.0 / 5U));
8000a3a8:	58c030ef          	jal	8000d934 <__floatunsidf>
8000a3ac:	84aa                	mv	s1,a0
8000a3ae:	892e                	mv	s2,a1
8000a3b0:	8522                	mv	a0,s0
8000a3b2:	582030ef          	jal	8000d934 <__floatunsidf>
8000a3b6:	401406b7          	lui	a3,0x40140
8000a3ba:	4601                	li	a2,0
8000a3bc:	32c030ef          	jal	8000d6e8 <__divdf3>
8000a3c0:	3ff006b7          	lui	a3,0x3ff00
8000a3c4:	4601                	li	a2,0
8000a3c6:	587020ef          	jal	8000d14c <__adddf3>
8000a3ca:	862a                	mv	a2,a0
8000a3cc:	86ae                	mv	a3,a1
8000a3ce:	8526                	mv	a0,s1
8000a3d0:	85ca                	mv	a1,s2
8000a3d2:	316030ef          	jal	8000d6e8 <__divdf3>
8000a3d6:	8d3fe0ef          	jal	80008ca8 <__fixunsdfsi>
8000a3da:	86aa                	mv	a3,a0
8000a3dc:	40b2                	lw	ra,12(sp)
8000a3de:	4422                	lw	s0,8(sp)
8000a3e0:	4492                	lw	s1,4(sp)
8000a3e2:	4902                	lw	s2,0(sp)
8000a3e4:	0141                	add	sp,sp,16

8000a3e6 <.LBB4_3>:
    }

    return postdiv_freq;
8000a3e6:	8536                	mv	a0,a3
8000a3e8:	8082                	ret

Disassembly of section .text.uart_default_config:

8000a3ea <uart_default_config>:
{
8000a3ea:	6571                	lui	a0,0x1c
8000a3ec:	20050513          	add	a0,a0,512 # 1c200 <__XPI0_segment_used_size__+0x62b4>
    config->baudrate = 115200;
8000a3f0:	c1c8                	sw	a0,4(a1)
8000a3f2:	0f000537          	lui	a0,0xf000
8000a3f6:	30050513          	add	a0,a0,768 # f000300 <_flash_size+0xef00300>
    config->num_of_stop_bits = stop_bits_1;
8000a3fa:	c588                	sw	a0,8(a1)
8000a3fc:	6541                	lui	a0,0x10
    config->rx_fifo_level = uart_rx_fifo_trg_not_empty;
8000a3fe:	c5c8                	sw	a0,12(a1)
    config->modem_config.auto_flow_ctrl_en = false;
8000a400:	00058823          	sb	zero,16(a1) # 40000010 <_flash_size+0x3ff00010>
8000a404:	000588a3          	sb	zero,17(a1)
8000a408:	00058923          	sb	zero,18(a1)
8000a40c:	000589a3          	sb	zero,19(a1)
8000a410:	00058a23          	sb	zero,20(a1)
8000a414:	4529                	li	a0,10
    config->rxidle_config.threshold = 10; /* 10-bit for typical UART configuration (8-N-1) */
8000a416:	00a58aa3          	sb	a0,21(a1)
    config->txidle_config.detect_enable = false;
8000a41a:	00059b23          	sh	zero,22(a1)
8000a41e:	4515                	li	a0,5
8000a420:	0526                	sll	a0,a0,0x9
    config->txidle_config.idle_cond = uart_rxline_idle_cond_rxline_logic_one;
8000a422:	00a59c23          	sh	a0,24(a1)
8000a426:	4505                	li	a0,1
    config->rx_enable = true;
8000a428:	00a58d23          	sb	a0,26(a1)
}
8000a42c:	8082                	ret

Disassembly of section .text.uart_init:

8000a42e <uart_init>:
{
8000a42e:	1141                	add	sp,sp,-16
8000a430:	c606                	sw	ra,12(sp)
8000a432:	c422                	sw	s0,8(sp)
8000a434:	c226                	sw	s1,4(sp)
8000a436:	842a                	mv	s0,a0
    ptr->IER = 0;
8000a438:	02052223          	sw	zero,36(a0) # 10024 <__ILM_segment_used_end__+0x4bde>
    ptr->LCR |= UART_LCR_DLAB_MASK;
8000a43c:	5548                	lw	a0,44(a0)
8000a43e:	84ae                	mv	s1,a1
8000a440:	08056513          	or	a0,a0,128
8000a444:	d448                	sw	a0,44(s0)
    if (!uart_calculate_baudrate(config->src_freq_in_hz, config->baudrate, &div, &osc)) {
8000a446:	4188                	lw	a0,0(a1)
8000a448:	41cc                	lw	a1,4(a1)
8000a44a:	860a                	mv	a2,sp
8000a44c:	00310693          	add	a3,sp,3
8000a450:	b52fc0ef          	jal	800067a2 <uart_calculate_baudrate>
8000a454:	85aa                	mv	a1,a0
8000a456:	3e900513          	li	a0,1001
8000a45a:	16058163          	beqz	a1,8000a5bc <.LBB1_14>
    ptr->OSCR = (ptr->OSCR & ~UART_OSCR_OSC_MASK)
8000a45e:	4848                	lw	a0,20(s0)
        | UART_OSCR_OSC_SET(osc);
8000a460:	00314583          	lbu	a1,3(sp)
    ptr->OSCR = (ptr->OSCR & ~UART_OSCR_OSC_MASK)
8000a464:	9901                	and	a0,a0,-32
        | UART_OSCR_OSC_SET(osc);
8000a466:	89fd                	and	a1,a1,31
8000a468:	8d4d                	or	a0,a0,a1
    ptr->OSCR = (ptr->OSCR & ~UART_OSCR_OSC_MASK)
8000a46a:	c848                	sw	a0,20(s0)
    ptr->DLL = UART_DLL_DLL_SET(div >> 0);
8000a46c:	00015503          	lhu	a0,0(sp)
8000a470:	0ff57593          	zext.b	a1,a0
8000a474:	d00c                	sw	a1,32(s0)
8000a476:	8121                	srl	a0,a0,0x8
    ptr->DLM = UART_DLM_DLM_SET(div >> 8);
8000a478:	d048                	sw	a0,36(s0)
    tmp = ptr->LCR & (~UART_LCR_DLAB_MASK);
8000a47a:	544c                	lw	a1,44(s0)
    switch (config->parity) {
8000a47c:	00a4c603          	lbu	a2,10(s1)
8000a480:	4691                	li	a3,4
8000a482:	4509                	li	a0,2
8000a484:	12c6ec63          	bltu	a3,a2,8000a5bc <.LBB1_14>
8000a488:	060a                	sll	a2,a2,0x2
8000a48a:	800056b7          	lui	a3,0x80005
8000a48e:	d5468693          	add	a3,a3,-684 # 80004d54 <.LJTI1_0>
8000a492:	9636                	add	a2,a2,a3
8000a494:	4210                	lw	a2,0(a2)
8000a496:	f475f593          	and	a1,a1,-185
8000a49a:	8602                	jr	a2

8000a49c <.LBB1_3>:
        tmp |= UART_LCR_PEN_MASK;
8000a49c:	0085e593          	or	a1,a1,8
8000a4a0:	a809                	j	8000a4b2 <.LBB1_7>

8000a4a2 <.LBB1_4>:
        tmp |= UART_LCR_EPS_MASK | UART_LCR_PEN_MASK
8000a4a2:	0385e593          	or	a1,a1,56
8000a4a6:	a031                	j	8000a4b2 <.LBB1_7>

8000a4a8 <.LBB1_5>:
        tmp |= UART_LCR_PEN_MASK | UART_LCR_EPS_MASK;
8000a4a8:	0185e593          	or	a1,a1,24
8000a4ac:	a019                	j	8000a4b2 <.LBB1_7>

8000a4ae <.LBB1_6>:
        tmp |= UART_LCR_PEN_MASK | UART_LCR_SPS_MASK;
8000a4ae:	0285e593          	or	a1,a1,40

8000a4b2 <.LBB1_7>:
    switch (config->num_of_stop_bits) {
8000a4b2:	0084c603          	lbu	a2,8(s1)
    tmp &= ~(UART_LCR_STB_MASK | UART_LCR_WLS_MASK);
8000a4b6:	99e1                	and	a1,a1,-8
    switch (config->num_of_stop_bits) {
8000a4b8:	ce11                	beqz	a2,8000a4d4 <.LBB1_12>
8000a4ba:	4689                	li	a3,2
8000a4bc:	00d60663          	beq	a2,a3,8000a4c8 <.LBB1_10>
8000a4c0:	4685                	li	a3,1
8000a4c2:	00d60763          	beq	a2,a3,8000a4d0 <.LBB1_11>
8000a4c6:	a8dd                	j	8000a5bc <.LBB1_14>

8000a4c8 <.LBB1_10>:
        if (config->word_length < word_length_6_bits) {
8000a4c8:	0094c603          	lbu	a2,9(s1)
8000a4cc:	4509                	li	a0,2
8000a4ce:	c67d                	beqz	a2,8000a5bc <.LBB1_14>

8000a4d0 <.LBB1_11>:
8000a4d0:	0045e593          	or	a1,a1,4

8000a4d4 <.LBB1_12>:
    ptr->LCR = tmp | UART_LCR_WLS_SET(config->word_length);
8000a4d4:	0094c503          	lbu	a0,9(s1)
8000a4d8:	890d                	and	a0,a0,3
8000a4da:	8d4d                	or	a0,a0,a1
8000a4dc:	d448                	sw	a0,44(s0)
8000a4de:	4519                	li	a0,6
    ptr->FCRR = UART_FCRR_TFIFORST_MASK | UART_FCRR_RFIFORST_MASK;
8000a4e0:	cc08                	sw	a0,24(s0)
        | UART_FCRR_TFIFOT4_SET(config->tx_fifo_level)
8000a4e2:	00b4c503          	lbu	a0,11(s1)
        | UART_FCRR_FIFOE_SET(config->fifo_enable)
8000a4e6:	00e4c583          	lbu	a1,14(s1)
        | UART_FCRR_RFIFOT4_SET(config->rx_fifo_level)
8000a4ea:	00c4c603          	lbu	a2,12(s1)
        | UART_FCRR_TFIFOT4_SET(config->tx_fifo_level)
8000a4ee:	0572                	sll	a0,a0,0x1c
        | UART_FCRR_DMAE_SET(config->dma_enable);
8000a4f0:	00d4c683          	lbu	a3,13(s1)
        | UART_FCRR_TFIFOT4_SET(config->tx_fifo_level)
8000a4f4:	8131                	srl	a0,a0,0xc
        | UART_FCRR_RFIFOT4_SET(config->rx_fifo_level)
8000a4f6:	0672                	sll	a2,a2,0x1c
8000a4f8:	8251                	srl	a2,a2,0x14
        | UART_FCRR_DMAE_SET(config->dma_enable);
8000a4fa:	06ee                	sll	a3,a3,0x1b
8000a4fc:	82e1                	srl	a3,a3,0x18
        | UART_FCRR_RFIFOT4_SET(config->rx_fifo_level)
8000a4fe:	8d4d                	or	a0,a0,a1
        | UART_FCRR_DMAE_SET(config->dma_enable);
8000a500:	8e55                	or	a2,a2,a3
8000a502:	8d51                	or	a0,a0,a2
8000a504:	008005b7          	lui	a1,0x800
8000a508:	8d4d                	or	a0,a0,a1
    ptr->FCRR = UART_FCRR_FIFOT4EN_MASK
8000a50a:	cc08                	sw	a0,24(s0)
 * @param [in] ptr UART base address
 * @param config Pointer to modem config struct
 */
static inline void uart_modem_config(UART_Type *ptr, uart_modem_config_t *config)
{
    ptr->MCR = UART_MCR_AFE_SET(config->auto_flow_ctrl_en)
8000a50c:	00f4c503          	lbu	a0,15(s1)
        | UART_MCR_LOOP_SET(config->loop_back_en)
8000a510:	0104c583          	lbu	a1,16(s1)
        | UART_MCR_RTS_SET(!config->set_rts_high);
8000a514:	0114c603          	lbu	a2,17(s1)
    ptr->MCR = UART_MCR_AFE_SET(config->auto_flow_ctrl_en)
8000a518:	0516                	sll	a0,a0,0x5
        | UART_MCR_LOOP_SET(config->loop_back_en)
8000a51a:	0592                	sll	a1,a1,0x4
8000a51c:	8d4d                	or	a0,a0,a1
        | UART_MCR_RTS_SET(!config->set_rts_high);
8000a51e:	0606                	sll	a2,a2,0x1
8000a520:	8d51                	or	a0,a0,a2
8000a522:	00254513          	xor	a0,a0,2
8000a526:	0fe57513          	and	a0,a0,254
    ptr->MCR = UART_MCR_AFE_SET(config->auto_flow_ctrl_en)
8000a52a:	d808                	sw	a0,48(s0)
    uart_init_rxline_idle_detection(ptr, config->rxidle_config);
8000a52c:	0144d503          	lhu	a0,20(s1)
8000a530:	0124d583          	lhu	a1,18(s1)


#if defined(HPM_IP_FEATURE_UART_RX_IDLE_DETECT) && (HPM_IP_FEATURE_UART_RX_IDLE_DETECT == 1)
hpm_stat_t uart_init_rxline_idle_detection(UART_Type *ptr, uart_rxline_idle_config_t rxidle_config)
{
    ptr->IDLE_CFG &= ~(UART_IDLE_CFG_RX_IDLE_EN_MASK
8000a534:	4050                	lw	a2,4(s0)
    uart_init_rxline_idle_detection(ptr, config->rxidle_config);
8000a536:	01051693          	sll	a3,a0,0x10
    ptr->IDLE_CFG &= ~(UART_IDLE_CFG_RX_IDLE_EN_MASK
8000a53a:	c0067613          	and	a2,a2,-1024
8000a53e:	c050                	sw	a2,4(s0)
                    | UART_IDLE_CFG_RX_IDLE_THR_MASK
                    | UART_IDLE_CFG_RX_IDLE_COND_MASK);
    ptr->IDLE_CFG |= UART_IDLE_CFG_RX_IDLE_EN_SET(rxidle_config.detect_enable)
                    | UART_IDLE_CFG_RX_IDLE_THR_SET(rxidle_config.threshold)
8000a540:	00859613          	sll	a2,a1,0x8
8000a544:	82e1                	srl	a3,a3,0x18
8000a546:	8e55                	or	a2,a2,a3
    ptr->IDLE_CFG |= UART_IDLE_CFG_RX_IDLE_EN_SET(rxidle_config.detect_enable)
8000a548:	4054                	lw	a3,4(s0)
                    | UART_IDLE_CFG_RX_IDLE_THR_SET(rxidle_config.threshold)
8000a54a:	1ff67613          	and	a2,a2,511
                    | UART_IDLE_CFG_RX_IDLE_COND_SET(rxidle_config.idle_cond);
8000a54e:	057e                	sll	a0,a0,0x1f
8000a550:	8159                	srl	a0,a0,0x16
8000a552:	8d55                	or	a0,a0,a3
    ptr->IDLE_CFG |= UART_IDLE_CFG_RX_IDLE_EN_SET(rxidle_config.detect_enable)
8000a554:	8d51                	or	a0,a0,a2
8000a556:	c048                	sw	a0,4(s0)
8000a558:	5048                	lw	a0,36(s0)

    if (rxidle_config.detect_irq_enable) {
8000a55a:	0506                	sll	a0,a0,0x1
8000a55c:	8105                	srl	a0,a0,0x1
8000a55e:	81a1                	srl	a1,a1,0x8
8000a560:	05fe                	sll	a1,a1,0x1f
8000a562:	8d4d                	or	a0,a0,a1
8000a564:	d048                	sw	a0,36(s0)
    uart_init_txline_idle_detection(ptr, config->txidle_config);
8000a566:	0164d503          	lhu	a0,22(s1)
8000a56a:	0184d583          	lhu	a1,24(s1)

/* if have 9bit_mode function, it's has be tx_idle function */
#if defined(HPM_IP_FEATURE_UART_9BIT_MODE) && (HPM_IP_FEATURE_UART_9BIT_MODE == 1)
hpm_stat_t uart_init_txline_idle_detection(UART_Type *ptr, uart_rxline_idle_config_t txidle_config)
{
    ptr->IDLE_CFG &= ~(UART_IDLE_CFG_TX_IDLE_EN_MASK
8000a56e:	4050                	lw	a2,4(s0)
8000a570:	fc0106b7          	lui	a3,0xfc010
8000a574:	16fd                	add	a3,a3,-1 # fc00ffff <__AHB_SRAM_segment_end__+0xbc07fff>
8000a576:	8e75                	and	a2,a2,a3
8000a578:	c050                	sw	a2,4(s0)
                    | UART_IDLE_CFG_TX_IDLE_THR_MASK
                    | UART_IDLE_CFG_TX_IDLE_COND_MASK);
    ptr->IDLE_CFG |= UART_IDLE_CFG_TX_IDLE_EN_SET(txidle_config.detect_enable)
8000a57a:	00859613          	sll	a2,a1,0x8
8000a57e:	01851693          	sll	a3,a0,0x18
8000a582:	8e55                	or	a2,a2,a3
8000a584:	01ff06b7          	lui	a3,0x1ff0
8000a588:	4058                	lw	a4,4(s0)
                    | UART_IDLE_CFG_TX_IDLE_THR_SET(txidle_config.threshold)
8000a58a:	8e75                	and	a2,a2,a3
                    | UART_IDLE_CFG_TX_IDLE_COND_SET(txidle_config.idle_cond);
8000a58c:	05fe                	sll	a1,a1,0x1f
8000a58e:	8199                	srl	a1,a1,0x6
8000a590:	8dd9                	or	a1,a1,a4
    ptr->IDLE_CFG |= UART_IDLE_CFG_TX_IDLE_EN_SET(txidle_config.detect_enable)
8000a592:	8dd1                	or	a1,a1,a2
8000a594:	c04c                	sw	a1,4(s0)
8000a596:	504c                	lw	a1,36(s0)
8000a598:	c0000637          	lui	a2,0xc0000
8000a59c:	167d                	add	a2,a2,-1 # bfffffff <__XPI0_segment_end__+0x3fefffff>

    if (txidle_config.detect_irq_enable) {
8000a59e:	8df1                	and	a1,a1,a2
8000a5a0:	10057513          	and	a0,a0,256
8000a5a4:	055a                	sll	a0,a0,0x16
8000a5a6:	8d4d                	or	a0,a0,a1
8000a5a8:	d048                	sw	a0,36(s0)
    if (config->rx_enable) {
8000a5aa:	01a4c503          	lbu	a0,26(s1)
8000a5ae:	c519                	beqz	a0,8000a5bc <.LBB1_14>
        ptr->IDLE_CFG |= UART_IDLE_CFG_RXEN_MASK;
8000a5b0:	404c                	lw	a1,4(s0)
8000a5b2:	4501                	li	a0,0
8000a5b4:	4605                	li	a2,1
8000a5b6:	062e                	sll	a2,a2,0xb
8000a5b8:	8dd1                	or	a1,a1,a2
8000a5ba:	c04c                	sw	a1,4(s0)

8000a5bc <.LBB1_14>:
8000a5bc:	40b2                	lw	ra,12(sp)
8000a5be:	4422                	lw	s0,8(sp)
8000a5c0:	4492                	lw	s1,4(sp)
}
8000a5c2:	0141                	add	sp,sp,16
8000a5c4:	8082                	ret

Disassembly of section .text.uart_flush:

8000a5c6 <uart_flush>:
{
8000a5c6:	4681                	li	a3,0
8000a5c8:	6585                	lui	a1,0x1
8000a5ca:	38958593          	add	a1,a1,905 # 1389 <.LBB2_212+0x19>

8000a5ce <.LBB7_1>:
    while (!(ptr->LSR & UART_LSR_TEMT_MASK)) {
8000a5ce:	5950                	lw	a2,52(a0)
8000a5d0:	04067713          	and	a4,a2,64
8000a5d4:	8636                	mv	a2,a3
8000a5d6:	e709                	bnez	a4,8000a5e0 <.LBB7_3>
8000a5d8:	00160693          	add	a3,a2,1
8000a5dc:	feb669e3          	bltu	a2,a1,8000a5ce <.LBB7_1>

8000a5e0 <.LBB7_3>:
8000a5e0:	6505                	lui	a0,0x1
8000a5e2:	38850513          	add	a0,a0,904 # 1388 <.LBB2_212+0x18>
8000a5e6:	00c53533          	sltu	a0,a0,a2
8000a5ea:	40a00533          	neg	a0,a0
8000a5ee:	890d                	and	a0,a0,3
}
8000a5f0:	8082                	ret

Disassembly of section .text.usb_dcd_edpt_clear_stall:

8000a5f2 <usb_dcd_edpt_clear_stall>:
{
    uint8_t const epnum = ep_addr & 0x0f;
    uint8_t const dir   = (ep_addr & 0x80) >> 7;

    /* data toggle also need to be reset */
    ptr->ENDPTCTRL[epnum] |= ENDPTCTRL_TOGGLE_RESET << (dir ? 16 : 0);
8000a5f2:	0035d613          	srl	a2,a1,0x3
8000a5f6:	89bd                	and	a1,a1,15
8000a5f8:	058a                	sll	a1,a1,0x2
8000a5fa:	952e                	add	a0,a0,a1
8000a5fc:	1c052583          	lw	a1,448(a0)
8000a600:	8a41                	and	a2,a2,16
8000a602:	04000693          	li	a3,64
8000a606:	00c696b3          	sll	a3,a3,a2
8000a60a:	8dd5                	or	a1,a1,a3
8000a60c:	1cb52023          	sw	a1,448(a0)
    ptr->ENDPTCTRL[epnum] &= ~(ENDPTCTRL_STALL << (dir  ? 16 : 0));
8000a610:	1c052583          	lw	a1,448(a0)
8000a614:	4685                	li	a3,1
8000a616:	00c69633          	sll	a2,a3,a2
8000a61a:	fff64613          	not	a2,a2
8000a61e:	8df1                	and	a1,a1,a2
8000a620:	1cb52023          	sw	a1,448(a0)
}
8000a624:	8082                	ret

Disassembly of section .text.usb_dcd_edpt_close:

8000a626 <usb_dcd_edpt_close>:
void usb_dcd_edpt_close(USB_Type *ptr, uint8_t ep_addr)
{
    uint8_t const epnum = ep_addr & 0x0f;
    uint8_t const dir   = (ep_addr & 0x80) >> 7;

    uint32_t primebit = HPM_BITSMASK(1, epnum) << (dir ? 16 : 0);
8000a626:	00f5f613          	and	a2,a1,15
8000a62a:	4685                	li	a3,1
8000a62c:	00c696b3          	sll	a3,a3,a2
8000a630:	818d                	srl	a1,a1,0x3
8000a632:	89c1                	and	a1,a1,16
8000a634:	00b696b3          	sll	a3,a3,a1

8000a638 <.LBB12_1>:

    /* Flush the endpoint to stop a transfer. */
    do {
        /* Set the corresponding bit(s) in the ENDPTFLUSH register */
        ptr->ENDPTFLUSH |= primebit;
8000a638:	1b452703          	lw	a4,436(a0)
8000a63c:	8f55                	or	a4,a4,a3
8000a63e:	1ae52a23          	sw	a4,436(a0)

8000a642 <.LBB12_2>:

        /* Wait until all bits in the ENDPTFLUSH register are cleared. */
        while (0U != (ptr->ENDPTFLUSH & primebit)) {
8000a642:	1b452703          	lw	a4,436(a0)
8000a646:	8f75                	and	a4,a4,a3
8000a648:	ff6d                	bnez	a4,8000a642 <.LBB12_2>
        /*
         * Read the ENDPTSTAT register to ensure that for all endpoints
         * commanded to be flushed, that the corresponding bits
         * are now cleared.
         */
    } while (0U != (ptr->ENDPTSTAT & primebit));
8000a64a:	1b852703          	lw	a4,440(a0)
8000a64e:	8f75                	and	a4,a4,a3
8000a650:	f765                	bnez	a4,8000a638 <.LBB12_1>

    /* Disable the endpoint */
    ptr->ENDPTCTRL[epnum] &= ~((ENDPTCTRL_TYPE | ENDPTCTRL_ENABLE | ENDPTCTRL_STALL) << (dir ? 16 : 0));
8000a652:	060a                	sll	a2,a2,0x2
8000a654:	9532                	add	a0,a0,a2
8000a656:	1c052603          	lw	a2,448(a0)
8000a65a:	08d00693          	li	a3,141
8000a65e:	00b696b3          	sll	a3,a3,a1
8000a662:	fff6c693          	not	a3,a3
8000a666:	8e75                	and	a2,a2,a3
8000a668:	1cc52023          	sw	a2,448(a0)
    ptr->ENDPTCTRL[epnum] |= (usb_xfer_bulk << 2) << (dir ? 16 : 0);
8000a66c:	1c052603          	lw	a2,448(a0)
8000a670:	46a1                	li	a3,8
8000a672:	00b695b3          	sll	a1,a3,a1
8000a676:	8dd1                	or	a1,a1,a2
8000a678:	1cb52023          	sw	a1,448(a0)
}
8000a67c:	8082                	ret

Disassembly of section .text.cdc_acm_class_interface_request_handler:

8000a67e <cdc_acm_class_interface_request_handler>:
{
8000a67e:	1101                	add	sp,sp,-32
8000a680:	ce06                	sw	ra,28(sp)
8000a682:	cc22                	sw	s0,24(sp)
8000a684:	ca26                	sw	s1,20(sp)
8000a686:	c84a                	sw	s2,16(sp)
    uint8_t intf_num = LO_BYTE(setup->wIndex);
8000a688:	0055c783          	lbu	a5,5(a1)
8000a68c:	0045c483          	lbu	s1,4(a1)
    switch (setup->bRequest) {
8000a690:	0015c703          	lbu	a4,1(a1)
    uint8_t intf_num = LO_BYTE(setup->wIndex);
8000a694:	07a2                	sll	a5,a5,0x8
8000a696:	02100413          	li	s0,33
8000a69a:	8cdd                	or	s1,s1,a5
    switch (setup->bRequest) {
8000a69c:	06e44563          	blt	s0,a4,8000a706 <.LBB1_4>
8000a6a0:	02000793          	li	a5,32
8000a6a4:	0af70563          	beq	a4,a5,8000a74e <.LBB1_8>
8000a6a8:	02100793          	li	a5,33
8000a6ac:	06f71a63          	bne	a4,a5,8000a720 <.LBB1_7>
            usbd_cdc_acm_get_line_coding(busid, intf_num, &line_coding);
8000a6b0:	0ff4f593          	zext.b	a1,s1
8000a6b4:	8432                	mv	s0,a2
8000a6b6:	00910613          	add	a2,sp,9
8000a6ba:	84b6                	mv	s1,a3
8000a6bc:	80000097          	auipc	ra,0x80000
8000a6c0:	794080e7          	jalr	1940(ra) # ae50 <usbd_cdc_acm_get_line_coding>
            memcpy(*data, &line_coding, 7);
8000a6c4:	400c                	lw	a1,0(s0)
8000a6c6:	00f14503          	lbu	a0,15(sp)
8000a6ca:	00a58323          	sb	a0,6(a1)
8000a6ce:	00e14503          	lbu	a0,14(sp)
8000a6d2:	00a582a3          	sb	a0,5(a1)
8000a6d6:	00d14503          	lbu	a0,13(sp)
8000a6da:	00a58223          	sb	a0,4(a1)
8000a6de:	00c14503          	lbu	a0,12(sp)
8000a6e2:	00a581a3          	sb	a0,3(a1)
8000a6e6:	00b14503          	lbu	a0,11(sp)
8000a6ea:	00a58123          	sb	a0,2(a1)
8000a6ee:	00a14503          	lbu	a0,10(sp)
8000a6f2:	00a580a3          	sb	a0,1(a1)
8000a6f6:	00914603          	lbu	a2,9(sp)
8000a6fa:	4501                	li	a0,0
8000a6fc:	00c58023          	sb	a2,0(a1)
8000a700:	459d                	li	a1,7
            *len = 7;
8000a702:	c08c                	sw	a1,0(s1)
8000a704:	a05d                	j	8000a7aa <.LBB1_11>

8000a706 <.LBB1_4>:
8000a706:	02200613          	li	a2,34
    switch (setup->bRequest) {
8000a70a:	06c70963          	beq	a4,a2,8000a77c <.LBB1_9>
8000a70e:	02300613          	li	a2,35
8000a712:	00c71763          	bne	a4,a2,8000a720 <.LBB1_7>
            usbd_cdc_acm_send_break(busid, intf_num);
8000a716:	0ff4f593          	zext.b	a1,s1
8000a71a:	bf0fc0ef          	jal	80006b0a <usbd_cdc_acm_send_break>
8000a71e:	a069                	j	8000a7a8 <.LBB1_10>

8000a720 <.LBB1_7>:
            USB_LOG_WRN("Unhandled CDC Class bRequest 0x%02x\r\n", setup->bRequest);
8000a720:	80010537          	lui	a0,0x80010
8000a724:	0cf50513          	add	a0,a0,207 # 800100cf <.L.str.8>
8000a728:	842e                	mv	s0,a1
8000a72a:	c12ff0ef          	jal	80009b3c <printf>
8000a72e:	00144583          	lbu	a1,1(s0)
8000a732:	80010537          	lui	a0,0x80010
8000a736:	0dd50513          	add	a0,a0,221 # 800100dd <.L.str.9>
8000a73a:	c02ff0ef          	jal	80009b3c <printf>
8000a73e:	80011537          	lui	a0,0x80011
8000a742:	99950513          	add	a0,a0,-1639 # 80010999 <.L.str.10>
8000a746:	bf6ff0ef          	jal	80009b3c <printf>
8000a74a:	557d                	li	a0,-1
8000a74c:	a8b9                	j	8000a7aa <.LBB1_11>

8000a74e <.LBB1_8>:
            memcpy(&line_coding, *data, setup->wLength);
8000a74e:	0075c683          	lbu	a3,7(a1)
8000a752:	0065c703          	lbu	a4,6(a1)
8000a756:	420c                	lw	a1,0(a2)
8000a758:	00869613          	sll	a2,a3,0x8
8000a75c:	8e59                	or	a2,a2,a4
8000a75e:	842a                	mv	s0,a0
8000a760:	00910513          	add	a0,sp,9
8000a764:	93eff0ef          	jal	800098a2 <memcpy>
            usbd_cdc_acm_set_line_coding(busid, intf_num, &line_coding);
8000a768:	0ff4f593          	zext.b	a1,s1
8000a76c:	00910613          	add	a2,sp,9
8000a770:	8522                	mv	a0,s0
8000a772:	80000097          	auipc	ra,0x80000
8000a776:	ca4080e7          	jalr	-860(ra) # a416 <usbd_cdc_acm_set_line_coding>
8000a77a:	a03d                	j	8000a7a8 <.LBB1_10>

8000a77c <.LBB1_9>:
            dtr = (setup->wValue & 0x0001);
8000a77c:	0035c603          	lbu	a2,3(a1)
8000a780:	0025c583          	lbu	a1,2(a1)
8000a784:	0622                	sll	a2,a2,0x8
8000a786:	8dd1                	or	a1,a1,a2
8000a788:	0015f613          	and	a2,a1,1
            rts = (setup->wValue & 0x0002);
8000a78c:	05fa                	sll	a1,a1,0x1e
8000a78e:	01f5d913          	srl	s2,a1,0x1f
            usbd_cdc_acm_set_dtr(busid, intf_num, dtr);
8000a792:	0ff4f493          	zext.b	s1,s1
8000a796:	842a                	mv	s0,a0
8000a798:	85a6                	mv	a1,s1
8000a79a:	b6cfc0ef          	jal	80006b06 <usbd_cdc_acm_set_dtr>
            usbd_cdc_acm_set_rts(busid, intf_num, rts);
8000a79e:	8522                	mv	a0,s0
8000a7a0:	85a6                	mv	a1,s1
8000a7a2:	864a                	mv	a2,s2
8000a7a4:	b64fc0ef          	jal	80006b08 <usbd_cdc_acm_set_rts>

8000a7a8 <.LBB1_10>:
8000a7a8:	4501                	li	a0,0

8000a7aa <.LBB1_11>:
8000a7aa:	40f2                	lw	ra,28(sp)
8000a7ac:	4462                	lw	s0,24(sp)
8000a7ae:	44d2                	lw	s1,20(sp)
8000a7b0:	4942                	lw	s2,16(sp)
}
8000a7b2:	6105                	add	sp,sp,32
8000a7b4:	8082                	ret

Disassembly of section .text.msc_storage_notify_handler:

8000a7b6 <msc_storage_notify_handler>:
{
8000a7b6:	1141                	add	sp,sp,-16
8000a7b8:	c606                	sw	ra,12(sp)
8000a7ba:	c422                	sw	s0,8(sp)
8000a7bc:	c226                	sw	s1,4(sp)
8000a7be:	c04a                	sw	s2,0(sp)
8000a7c0:	4629                	li	a2,10
8000a7c2:	842a                	mv	s0,a0
    switch (event) {
8000a7c4:	04b64363          	blt	a2,a1,8000a80a <.LBB0_4>
8000a7c8:	4505                	li	a0,1
8000a7ca:	0ea58163          	beq	a1,a0,8000a8ac <.LBB0_10>
8000a7ce:	451d                	li	a0,7
8000a7d0:	12a59763          	bne	a1,a0,8000a8fe <.LBB0_15>
            usbd_ep_start_read(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr, (uint8_t *)&g_usbd_msc[busid].cbw, USB_SIZEOF_MSC_CBW);
8000a7d4:	00441513          	sll	a0,s0,0x4
8000a7d8:	5e018593          	add	a1,gp,1504 # 81950 <mass_ep_data>
8000a7dc:	952e                	add	a0,a0,a1
8000a7de:	00054583          	lbu	a1,0(a0)
8000a7e2:	25400513          	li	a0,596
8000a7e6:	02a40533          	mul	a0,s0,a0
8000a7ea:	00097637          	lui	a2,0x97
8000a7ee:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
8000a7f2:	9532                	add	a0,a0,a2
8000a7f4:	00450613          	add	a2,a0,4
8000a7f8:	46fd                	li	a3,31
8000a7fa:	8522                	mv	a0,s0
8000a7fc:	40b2                	lw	ra,12(sp)
8000a7fe:	4422                	lw	s0,8(sp)
8000a800:	4492                	lw	s1,4(sp)
8000a802:	4902                	lw	s2,0(sp)
8000a804:	0141                	add	sp,sp,16
8000a806:	6ea0106f          	j	8000bef0 <usbd_ep_start_read>

8000a80a <.LBB0_4>:
8000a80a:	4531                	li	a0,12
    switch (event) {
8000a80c:	0aa58e63          	beq	a1,a0,8000a8c8 <.LBB0_11>
8000a810:	452d                	li	a0,11
8000a812:	0ea59663          	bne	a1,a0,8000a8fe <.LBB0_15>
            g_usbd_msc[busid].usbd_msc_mq = usb_osal_mq_create(1);
8000a816:	4505                	li	a0,1
8000a818:	498010ef          	jal	8000bcb0 <usb_osal_mq_create>
8000a81c:	25400913          	li	s2,596
8000a820:	032405b3          	mul	a1,s0,s2
8000a824:	00097637          	lui	a2,0x97
8000a828:	a6060493          	add	s1,a2,-1440 # 96a60 <g_usbd_msc>
8000a82c:	95a6                	add	a1,a1,s1
8000a82e:	24a5a423          	sw	a0,584(a1)
            if (g_usbd_msc[busid].usbd_msc_mq == NULL) {
8000a832:	e11d                	bnez	a0,8000a858 <.LBB0_8>
                USB_LOG_ERR("No memory to alloc for g_usbd_msc[busid].usbd_msc_mq\r\n");
8000a834:	80010537          	lui	a0,0x80010
8000a838:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
8000a83c:	b00ff0ef          	jal	80009b3c <printf>
8000a840:	80010537          	lui	a0,0x80010
8000a844:	14550513          	add	a0,a0,325 # 80010145 <.Lstr>
8000a848:	0cf020ef          	jal	8000d116 <puts>
8000a84c:	80011537          	lui	a0,0x80011
8000a850:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
8000a854:	ae8ff0ef          	jal	80009b3c <printf>

8000a858 <.LBB0_8>:
            g_usbd_msc[busid].usbd_msc_thread = usb_osal_thread_create("usbd_msc", CONFIG_USBDEV_MSC_STACKSIZE, CONFIG_USBDEV_MSC_PRIO, usbdev_msc_thread, (void *)busid);
8000a858:	80011537          	lui	a0,0x80011
8000a85c:	9a350513          	add	a0,a0,-1629 # 800109a3 <.L.str.3>
8000a860:	800075b7          	lui	a1,0x80007
8000a864:	b0c58693          	add	a3,a1,-1268 # 80006b0c <usbdev_msc_thread>
8000a868:	6585                	lui	a1,0x1
8000a86a:	4611                	li	a2,4
8000a86c:	8722                	mv	a4,s0
8000a86e:	e07fc0ef          	jal	80007674 <usb_osal_thread_create>
8000a872:	032405b3          	mul	a1,s0,s2
8000a876:	95a6                	add	a1,a1,s1
8000a878:	24a5a623          	sw	a0,588(a1) # 124c <.LBB2_194+0x6>
            if (g_usbd_msc[busid].usbd_msc_thread == NULL) {
8000a87c:	e149                	bnez	a0,8000a8fe <.LBB0_15>
                USB_LOG_ERR("No memory to alloc for g_usbd_msc[busid].usbd_msc_thread\r\n");
8000a87e:	80010537          	lui	a0,0x80010
8000a882:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
8000a886:	ab6ff0ef          	jal	80009b3c <printf>
8000a88a:	80010537          	lui	a0,0x80010
8000a88e:	17b50513          	add	a0,a0,379 # 8001017b <.Lstr.15>
8000a892:	085020ef          	jal	8000d116 <puts>
8000a896:	80011537          	lui	a0,0x80011
8000a89a:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
8000a89e:	40b2                	lw	ra,12(sp)
8000a8a0:	4422                	lw	s0,8(sp)
8000a8a2:	4492                	lw	s1,4(sp)
8000a8a4:	4902                	lw	s2,0(sp)
8000a8a6:	0141                	add	sp,sp,16
8000a8a8:	a94ff06f          	j	80009b3c <printf>

8000a8ac <.LBB0_10>:
8000a8ac:	25400513          	li	a0,596
    g_usbd_msc[busid].stage = MSC_READ_CBW;
8000a8b0:	02a40533          	mul	a0,s0,a0
8000a8b4:	000975b7          	lui	a1,0x97
8000a8b8:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
8000a8bc:	952e                	add	a0,a0,a1
8000a8be:	00050023          	sb	zero,0(a0)
    g_usbd_msc[busid].readonly = false;
8000a8c2:	020508a3          	sb	zero,49(a0)
8000a8c6:	a825                	j	8000a8fe <.LBB0_15>

8000a8c8 <.LBB0_11>:
8000a8c8:	25400913          	li	s2,596
            if (g_usbd_msc[busid].usbd_msc_mq) {
8000a8cc:	03240533          	mul	a0,s0,s2
8000a8d0:	000975b7          	lui	a1,0x97
8000a8d4:	a6058493          	add	s1,a1,-1440 # 96a60 <g_usbd_msc>
8000a8d8:	9526                	add	a0,a0,s1
8000a8da:	24852503          	lw	a0,584(a0)
8000a8de:	c119                	beqz	a0,8000a8e4 <.LBB0_13>
                usb_osal_mq_delete(g_usbd_msc[busid].usbd_msc_mq);
8000a8e0:	3d8010ef          	jal	8000bcb8 <usb_osal_mq_delete>

8000a8e4 <.LBB0_13>:
            if (g_usbd_msc[busid].usbd_msc_thread) {
8000a8e4:	03240533          	mul	a0,s0,s2
8000a8e8:	9526                	add	a0,a0,s1
8000a8ea:	24c52503          	lw	a0,588(a0)
8000a8ee:	c901                	beqz	a0,8000a8fe <.LBB0_15>
8000a8f0:	40b2                	lw	ra,12(sp)
8000a8f2:	4422                	lw	s0,8(sp)
8000a8f4:	4492                	lw	s1,4(sp)
8000a8f6:	4902                	lw	s2,0(sp)
                usb_osal_thread_delete(g_usbd_msc[busid].usbd_msc_thread);
8000a8f8:	0141                	add	sp,sp,16
8000a8fa:	3700106f          	j	8000bc6a <usb_osal_thread_delete>

8000a8fe <.LBB0_15>:
8000a8fe:	40b2                	lw	ra,12(sp)
8000a900:	4422                	lw	s0,8(sp)
8000a902:	4492                	lw	s1,4(sp)
8000a904:	4902                	lw	s2,0(sp)
}
8000a906:	0141                	add	sp,sp,16
8000a908:	8082                	ret

Disassembly of section .text.usbd_msc_init_intf:

8000a90a <usbd_msc_init_intf>:
    }
}
#endif

struct usbd_interface *usbd_msc_init_intf(uint8_t busid, struct usbd_interface *intf, const uint8_t out_ep, const uint8_t in_ep)
{
8000a90a:	1101                	add	sp,sp,-32
8000a90c:	ce06                	sw	ra,28(sp)
8000a90e:	cc22                	sw	s0,24(sp)
8000a910:	ca26                	sw	s1,20(sp)
8000a912:	c84a                	sw	s2,16(sp)
8000a914:	c64e                	sw	s3,12(sp)
8000a916:	c452                	sw	s4,8(sp)
8000a918:	c256                	sw	s5,4(sp)
8000a91a:	c05a                	sw	s6,0(sp)
8000a91c:	892e                	mv	s2,a1
8000a91e:	89aa                	mv	s3,a0
    intf->class_interface_handler = msc_storage_class_interface_request_handler;
8000a920:	8000b537          	lui	a0,0x8000b
8000a924:	a0e50513          	add	a0,a0,-1522 # 8000aa0e <msc_storage_class_interface_request_handler>
8000a928:	c188                	sw	a0,0(a1)
    intf->class_endpoint_handler = NULL;
8000a92a:	0005a223          	sw	zero,4(a1)
    intf->vendor_handler = NULL;
8000a92e:	0005a423          	sw	zero,8(a1)
    intf->notify_handler = msc_storage_notify_handler;
8000a932:	8000a537          	lui	a0,0x8000a
8000a936:	7b650513          	add	a0,a0,1974 # 8000a7b6 <msc_storage_notify_handler>
8000a93a:	c5c8                	sw	a0,12(a1)

    mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr = out_ep;
8000a93c:	00499593          	sll	a1,s3,0x4
8000a940:	5e018513          	add	a0,gp,1504 # 81950 <mass_ep_data>
8000a944:	95aa                	add	a1,a1,a0
8000a946:	00c58023          	sb	a2,0(a1)
    mass_ep_data[busid][MSD_OUT_EP_IDX].ep_cb = mass_storage_bulk_out;
8000a94a:	80007537          	lui	a0,0x80007
8000a94e:	cf650513          	add	a0,a0,-778 # 80006cf6 <mass_storage_bulk_out>
8000a952:	c1c8                	sw	a0,4(a1)
    mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr = in_ep;
8000a954:	00858413          	add	s0,a1,8
8000a958:	00d58423          	sb	a3,8(a1)
    mass_ep_data[busid][MSD_IN_EP_IDX].ep_cb = mass_storage_bulk_in;
8000a95c:	80007537          	lui	a0,0x80007
8000a960:	ffc50513          	add	a0,a0,-4 # 80006ffc <mass_storage_bulk_in>
8000a964:	c5c8                	sw	a0,12(a1)

    usbd_add_endpoint(busid, &mass_ep_data[busid][MSD_OUT_EP_IDX]);
8000a966:	854e                	mv	a0,s3
8000a968:	1a6010ef          	jal	8000bb0e <usbd_add_endpoint>
    usbd_add_endpoint(busid, &mass_ep_data[busid][MSD_IN_EP_IDX]);
8000a96c:	854e                	mv	a0,s3
8000a96e:	85a2                	mv	a1,s0
8000a970:	19e010ef          	jal	8000bb0e <usbd_add_endpoint>
8000a974:	25400513          	li	a0,596

    memset((uint8_t *)&g_usbd_msc[busid], 0, sizeof(struct usbd_msc_priv));
8000a978:	02a98433          	mul	s0,s3,a0
8000a97c:	00097537          	lui	a0,0x97
8000a980:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
8000a984:	00850b33          	add	s6,a0,s0
    g_usbd_msc[busid].max_lun = CONFIG_USBDEV_MSC_MAX_LUN - 1u;
8000a988:	036b0a13          	add	s4,s6,54
8000a98c:	25400613          	li	a2,596
8000a990:	855a                	mv	a0,s6
8000a992:	4581                	li	a1,0
8000a994:	184030ef          	jal	8000db18 <memset>
8000a998:	4481                	li	s1,0
8000a99a:	20100a93          	li	s5,513

8000a99e <.LBB5_1>:

    usdb_msc_set_max_lun(busid);
    for (uint8_t i = 0u; i <= g_usbd_msc[busid].max_lun; i++) {
8000a99e:	0ff4f593          	zext.b	a1,s1
        usbd_msc_get_cap(busid, i, &g_usbd_msc[busid].scsi_blk_nbr[i], &g_usbd_msc[busid].scsi_blk_size[i]);
8000a9a2:	00259513          	sll	a0,a1,0x2
8000a9a6:	00ab0433          	add	s0,s6,a0
8000a9aa:	04440613          	add	a2,s0,68
8000a9ae:	04040693          	add	a3,s0,64
8000a9b2:	854e                	mv	a0,s3
8000a9b4:	80001097          	auipc	ra,0x80001
8000a9b8:	982080e7          	jalr	-1662(ra) # b336 <usbd_msc_get_cap>

        if (g_usbd_msc[busid].scsi_blk_size[i] > CONFIG_USBDEV_MSC_MAX_BUFSIZE) {
8000a9bc:	4028                	lw	a0,64(s0)
8000a9be:	01557a63          	bgeu	a0,s5,8000a9d2 <.LBB5_3>
    for (uint8_t i = 0u; i <= g_usbd_msc[busid].max_lun; i++) {
8000a9c2:	000a4503          	lbu	a0,0(s4)
8000a9c6:	0485                	add	s1,s1,1
8000a9c8:	0ff4f593          	zext.b	a1,s1
8000a9cc:	fcb579e3          	bgeu	a0,a1,8000a99e <.LBB5_1>
8000a9d0:	a025                	j	8000a9f8 <.LBB5_4>

8000a9d2 <.LBB5_3>:
            USB_LOG_ERR("msc block buffer overflow\r\n");
8000a9d2:	80010537          	lui	a0,0x80010
8000a9d6:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
8000a9da:	962ff0ef          	jal	80009b3c <printf>
8000a9de:	8000f537          	lui	a0,0x8000f
8000a9e2:	39b50513          	add	a0,a0,923 # 8000f39b <.Lstr.17>
8000a9e6:	730020ef          	jal	8000d116 <puts>
8000a9ea:	80011537          	lui	a0,0x80011
8000a9ee:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
8000a9f2:	94aff0ef          	jal	80009b3c <printf>
8000a9f6:	4901                	li	s2,0

8000a9f8 <.LBB5_4>:
            return NULL;
        }
    }

    return intf;
}
8000a9f8:	854a                	mv	a0,s2
8000a9fa:	40f2                	lw	ra,28(sp)
8000a9fc:	4462                	lw	s0,24(sp)
8000a9fe:	44d2                	lw	s1,20(sp)
8000aa00:	4942                	lw	s2,16(sp)
8000aa02:	49b2                	lw	s3,12(sp)
8000aa04:	4a22                	lw	s4,8(sp)
8000aa06:	4a92                	lw	s5,4(sp)
8000aa08:	4b02                	lw	s6,0(sp)
8000aa0a:	6105                	add	sp,sp,32
8000aa0c:	8082                	ret

Disassembly of section .text.msc_storage_class_interface_request_handler:

8000aa0e <msc_storage_class_interface_request_handler>:
    switch (setup->bRequest) {
8000aa0e:	0015c703          	lbu	a4,1(a1)
8000aa12:	0fe00793          	li	a5,254
8000aa16:	02f70563          	beq	a4,a5,8000aa40 <.LBB6_3>
8000aa1a:	0ff00613          	li	a2,255
8000aa1e:	04c71363          	bne	a4,a2,8000aa64 <.LBB6_4>
8000aa22:	25400613          	li	a2,596
    g_usbd_msc[busid].stage = MSC_READ_CBW;
8000aa26:	02c50633          	mul	a2,a0,a2
8000aa2a:	4501                	li	a0,0
8000aa2c:	000975b7          	lui	a1,0x97
8000aa30:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
8000aa34:	95b2                	add	a1,a1,a2
8000aa36:	00058023          	sb	zero,0(a1)
    g_usbd_msc[busid].readonly = false;
8000aa3a:	020588a3          	sb	zero,49(a1)
}
8000aa3e:	8082                	ret

8000aa40 <.LBB6_3>:
8000aa40:	25400593          	li	a1,596
            (*data)[0] = g_usbd_msc[busid].max_lun;
8000aa44:	02b50533          	mul	a0,a0,a1
8000aa48:	000975b7          	lui	a1,0x97
8000aa4c:	a6058593          	add	a1,a1,-1440 # 96a60 <g_usbd_msc>
8000aa50:	952e                	add	a0,a0,a1
8000aa52:	03654583          	lbu	a1,54(a0)
8000aa56:	4210                	lw	a2,0(a2)
8000aa58:	4501                	li	a0,0
8000aa5a:	00b60023          	sb	a1,0(a2)
8000aa5e:	4585                	li	a1,1
            *len = 1;
8000aa60:	c28c                	sw	a1,0(a3)
}
8000aa62:	8082                	ret

8000aa64 <.LBB6_4>:
8000aa64:	1141                	add	sp,sp,-16
8000aa66:	c606                	sw	ra,12(sp)
8000aa68:	c422                	sw	s0,8(sp)
            USB_LOG_WRN("Unhandled MSC Class bRequest 0x%02x\r\n", setup->bRequest);
8000aa6a:	80010537          	lui	a0,0x80010
8000aa6e:	11150513          	add	a0,a0,273 # 80010111 <.L.str.8>
8000aa72:	842e                	mv	s0,a1
8000aa74:	8c8ff0ef          	jal	80009b3c <printf>
8000aa78:	00144583          	lbu	a1,1(s0)
8000aa7c:	80010537          	lui	a0,0x80010
8000aa80:	11f50513          	add	a0,a0,287 # 8001011f <.L.str.14>
8000aa84:	8b8ff0ef          	jal	80009b3c <printf>
8000aa88:	80011537          	lui	a0,0x80011
8000aa8c:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
8000aa90:	8acff0ef          	jal	80009b3c <printf>
8000aa94:	557d                	li	a0,-1
8000aa96:	40b2                	lw	ra,12(sp)
8000aa98:	4422                	lw	s0,8(sp)
8000aa9a:	0141                	add	sp,sp,16
}
8000aa9c:	8082                	ret

Disassembly of section .text.SCSI_requestSense:

8000aa9e <SCSI_requestSense>:
{
8000aa9e:	7179                	add	sp,sp,-48
8000aaa0:	d606                	sw	ra,44(sp)
8000aaa2:	d422                	sw	s0,40(sp)
8000aaa4:	d226                	sw	s1,36(sp)
8000aaa6:	d04a                	sw	s2,32(sp)
8000aaa8:	25400693          	li	a3,596
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000aaac:	02d50533          	mul	a0,a0,a3
8000aab0:	000976b7          	lui	a3,0x97
8000aab4:	a6068693          	add	a3,a3,-1440 # 96a60 <g_usbd_msc>
8000aab8:	9536                	add	a0,a0,a3
8000aaba:	4540                	lw	s0,12(a0)
8000aabc:	c031                	beqz	s0,8000ab00 <.LBB9_4>
8000aabe:	8932                	mv	s2,a2
    if (g_usbd_msc[busid].cbw.CB[4] < SCSIRESP_FIXEDSENSEDATA_SIZEOF) {
8000aac0:	01754483          	lbu	s1,23(a0)
8000aac4:	4649                	li	a2,18
8000aac6:	00c4e363          	bltu	s1,a2,8000aacc <.LBB9_3>
8000aaca:	44c9                	li	s1,18

8000aacc <.LBB9_3>:
8000aacc:	07000613          	li	a2,112
    uint8_t request_sense[SCSIRESP_FIXEDSENSEDATA_SIZEOF] = {
8000aad0:	c632                	sw	a2,12(sp)
8000aad2:	cc02                	sw	zero,24(sp)
8000aad4:	00011e23          	sh	zero,28(sp)
8000aad8:	ca02                	sw	zero,20(sp)
8000aada:	0a000637          	lui	a2,0xa000
    request_sense[2] = g_usbd_msc[busid].sKey;
8000aade:	03354683          	lbu	a3,51(a0)
    request_sense[12] = g_usbd_msc[busid].ASC;
8000aae2:	03451703          	lh	a4,52(a0)
    memcpy(*data, (uint8_t *)request_sense, data_len);
8000aae6:	4188                	lw	a0,0(a1)
    uint8_t request_sense[SCSIRESP_FIXEDSENSEDATA_SIZEOF] = {
8000aae8:	c832                	sw	a2,16(sp)
    request_sense[2] = g_usbd_msc[busid].sKey;
8000aaea:	00d10723          	sb	a3,14(sp)
    request_sense[12] = g_usbd_msc[busid].ASC;
8000aaee:	00e11c23          	sh	a4,24(sp)
    memcpy(*data, (uint8_t *)request_sense, data_len);
8000aaf2:	006c                	add	a1,sp,12
8000aaf4:	8626                	mv	a2,s1
8000aaf6:	dadfe0ef          	jal	800098a2 <memcpy>
    *len = data_len;
8000aafa:	00992023          	sw	s1,0(s2)
8000aafe:	a801                	j	8000ab0e <.LBB9_5>

8000ab00 <.LBB9_4>:
8000ab00:	4595                	li	a1,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
8000ab02:	02b509a3          	sb	a1,51(a0)
8000ab06:	02000593          	li	a1,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000ab0a:	02b51a23          	sh	a1,52(a0)

8000ab0e <.LBB9_5>:
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000ab0e:	00803533          	snez	a0,s0
8000ab12:	50b2                	lw	ra,44(sp)
8000ab14:	5422                	lw	s0,40(sp)
8000ab16:	5492                	lw	s1,36(sp)
8000ab18:	5902                	lw	s2,32(sp)
}
8000ab1a:	6145                	add	sp,sp,48
8000ab1c:	8082                	ret

Disassembly of section .text.SCSI_startStopUnit:

8000ab1e <SCSI_startStopUnit>:
{
8000ab1e:	25400693          	li	a3,596
    if (g_usbd_msc[busid].cbw.dDataLength != 0U) {
8000ab22:	02d50733          	mul	a4,a0,a3
8000ab26:	000976b7          	lui	a3,0x97
8000ab2a:	a6068693          	add	a3,a3,-1440 # 96a60 <g_usbd_msc>
8000ab2e:	9736                	add	a4,a4,a3
8000ab30:	4754                	lw	a3,12(a4)
8000ab32:	ca99                	beqz	a3,8000ab48 <.LBB11_2>
8000ab34:	4515                	li	a0,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
8000ab36:	02a709a3          	sb	a0,51(a4)
8000ab3a:	02000513          	li	a0,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000ab3e:	02a71a23          	sh	a0,52(a4)
    if (g_usbd_msc[busid].cbw.dDataLength != 0U) {
8000ab42:	0016b513          	seqz	a0,a3
}
8000ab46:	8082                	ret

8000ab48 <.LBB11_2>:
    if ((g_usbd_msc[busid].cbw.CB[4] & 0x3U) == 0x1U) /* START=1 */
8000ab48:	01774703          	lbu	a4,23(a4)
8000ab4c:	8b0d                	and	a4,a4,3
8000ab4e:	4789                	li	a5,2
8000ab50:	00f71e63          	bne	a4,a5,8000ab6c <.LBB11_4>
8000ab54:	25400713          	li	a4,596
        g_usbd_msc[busid].popup = true;
8000ab58:	02e50533          	mul	a0,a0,a4
8000ab5c:	00097737          	lui	a4,0x97
8000ab60:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
8000ab64:	953a                	add	a0,a0,a4
8000ab66:	4705                	li	a4,1
8000ab68:	02e50923          	sb	a4,50(a0)

8000ab6c <.LBB11_4>:
    *data = NULL;
8000ab6c:	0005a023          	sw	zero,0(a1)
    *len = 0;
8000ab70:	00062023          	sw	zero,0(a2) # a000000 <_flash_size+0x9f00000>
    if (g_usbd_msc[busid].cbw.dDataLength != 0U) {
8000ab74:	0016b513          	seqz	a0,a3
}
8000ab78:	8082                	ret

Disassembly of section .text.SCSI_readCapacity10:

8000ab7a <SCSI_readCapacity10>:
{
8000ab7a:	25400693          	li	a3,596
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000ab7e:	02d506b3          	mul	a3,a0,a3
8000ab82:	00097537          	lui	a0,0x97
8000ab86:	a6050513          	add	a0,a0,-1440 # 96a60 <g_usbd_msc>
8000ab8a:	96aa                	add	a3,a3,a0
8000ab8c:	46c8                	lw	a0,12(a3)
8000ab8e:	c931                	beqz	a0,8000abe2 <.LBB14_2>
        (uint8_t)(((g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN] - 1) >> 24) & 0xff),
8000ab90:	0116c703          	lbu	a4,17(a3)
8000ab94:	070a                	sll	a4,a4,0x2
8000ab96:	96ba                	add	a3,a3,a4
8000ab98:	42f8                	lw	a4,68(a3)
8000ab9a:	177d                	add	a4,a4,-1
8000ab9c:	01875813          	srl	a6,a4,0x18
        (uint8_t)((g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN] >> 24) & 0xff),
8000aba0:	42b4                	lw	a3,64(a3)
        (uint8_t)(((g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN] - 1) >> 16) & 0xff),
8000aba2:	01075293          	srl	t0,a4,0x10
        (uint8_t)(((g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN] - 1) >> 8) & 0xff),
8000aba6:	00875893          	srl	a7,a4,0x8
    memcpy(*data, (uint8_t *)capacity10, SCSIRESP_READCAPACITY10_SIZEOF);
8000abaa:	418c                	lw	a1,0(a1)
        (uint8_t)((g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN] >> 24) & 0xff),
8000abac:	0186d793          	srl	a5,a3,0x18
        (uint8_t)((g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN] >> 16) & 0xff),
8000abb0:	0106d313          	srl	t1,a3,0x10
        (uint8_t)((g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN] >> 8) & 0xff),
8000abb4:	0086d393          	srl	t2,a3,0x8
    memcpy(*data, (uint8_t *)capacity10, SCSIRESP_READCAPACITY10_SIZEOF);
8000abb8:	01058023          	sb	a6,0(a1)
8000abbc:	005580a3          	sb	t0,1(a1)
8000abc0:	01158123          	sb	a7,2(a1)
8000abc4:	00e581a3          	sb	a4,3(a1)
8000abc8:	00f58223          	sb	a5,4(a1)
8000abcc:	006582a3          	sb	t1,5(a1)
8000abd0:	00758323          	sb	t2,6(a1)
8000abd4:	00d583a3          	sb	a3,7(a1)
8000abd8:	45a1                	li	a1,8
    *len = SCSIRESP_READCAPACITY10_SIZEOF;
8000abda:	c20c                	sw	a1,0(a2)
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000abdc:	00a03533          	snez	a0,a0
}
8000abe0:	8082                	ret

8000abe2 <.LBB14_2>:
8000abe2:	4595                	li	a1,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
8000abe4:	02b689a3          	sb	a1,51(a3)
8000abe8:	02000593          	li	a1,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000abec:	02b69a23          	sh	a1,52(a3)
    if (g_usbd_msc[busid].cbw.dDataLength == 0U) {
8000abf0:	00a03533          	snez	a0,a0
}
8000abf4:	8082                	ret

Disassembly of section .text.SCSI_read12:

8000abf6 <SCSI_read12>:
{
8000abf6:	25400593          	li	a1,596
    if (((g_usbd_msc[busid].cbw.bmFlags & 0x80U) != 0x80U) || (g_usbd_msc[busid].cbw.dDataLength == 0U)) {
8000abfa:	02b505b3          	mul	a1,a0,a1
8000abfe:	00097637          	lui	a2,0x97
8000ac02:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
8000ac06:	95b2                	add	a1,a1,a2
8000ac08:	01058603          	lb	a2,16(a1)
8000ac0c:	00064b63          	bltz	a2,8000ac22 <.LBB16_2>

8000ac10 <.LBB16_1>:
8000ac10:	4501                	li	a0,0
8000ac12:	4615                	li	a2,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
8000ac14:	02c589a3          	sb	a2,51(a1)
8000ac18:	02000613          	li	a2,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000ac1c:	02c59a23          	sh	a2,52(a1)
}
8000ac20:	8082                	ret

8000ac22 <.LBB16_2>:
    if (((g_usbd_msc[busid].cbw.bmFlags & 0x80U) != 0x80U) || (g_usbd_msc[busid].cbw.dDataLength == 0U)) {
8000ac22:	00c5a803          	lw	a6,12(a1)
8000ac26:	fe0805e3          	beqz	a6,8000ac10 <.LBB16_1>
8000ac2a:	1141                	add	sp,sp,-16
8000ac2c:	c606                	sw	ra,12(sp)
8000ac2e:	25400693          	li	a3,596
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ac32:	02d506b3          	mul	a3,a0,a3
8000ac36:	00097737          	lui	a4,0x97
8000ac3a:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
8000ac3e:	96ba                	add	a3,a3,a4
8000ac40:	0156c703          	lbu	a4,21(a3)
8000ac44:	0166c783          	lbu	a5,22(a3)
8000ac48:	0762                	sll	a4,a4,0x18
8000ac4a:	0176c603          	lbu	a2,23(a3)
8000ac4e:	07c2                	sll	a5,a5,0x10
8000ac50:	00e7e8b3          	or	a7,a5,a4
8000ac54:	0186c283          	lbu	t0,24(a3)
8000ac58:	0622                	sll	a2,a2,0x8
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
8000ac5a:	0196c703          	lbu	a4,25(a3)
8000ac5e:	01a6c783          	lbu	a5,26(a3)
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ac62:	00566633          	or	a2,a2,t0
8000ac66:	00c8e633          	or	a2,a7,a2
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
8000ac6a:	01871893          	sll	a7,a4,0x18
8000ac6e:	01079293          	sll	t0,a5,0x10
8000ac72:	01b6c303          	lbu	t1,27(a3)
8000ac76:	01c6c383          	lbu	t2,28(a3)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ac7a:	0116c703          	lbu	a4,17(a3)
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
8000ac7e:	0112e8b3          	or	a7,t0,a7
8000ac82:	0322                	sll	t1,t1,0x8
8000ac84:	007367b3          	or	a5,t1,t2
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ac88:	070a                	sll	a4,a4,0x2
8000ac8a:	9736                	add	a4,a4,a3
8000ac8c:	04472283          	lw	t0,68(a4)
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
8000ac90:	00f8e7b3          	or	a5,a7,a5
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ac94:	de90                	sw	a2,56(a3)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ac96:	963e                	add	a2,a2,a5
    g_usbd_msc[busid].nsectors = GET_BE32(&g_usbd_msc[busid].cbw.CB[6]); /* Number of Blocks to transfer */
8000ac98:	dedc                	sw	a5,60(a3)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ac9a:	02c2f463          	bgeu	t0,a2,8000acc2 <.LBB16_5>
8000ac9e:	4515                	li	a0,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
8000aca0:	02a689a3          	sb	a0,51(a3)
8000aca4:	02100513          	li	a0,33
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000aca8:	02a69a23          	sh	a0,52(a3)
        USB_LOG_ERR("LBA out of range\r\n");
8000acac:	80010537          	lui	a0,0x80010
8000acb0:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
8000acb4:	e89fe0ef          	jal	80009b3c <printf>
8000acb8:	80010537          	lui	a0,0x80010
8000acbc:	1e350513          	add	a0,a0,483 # 800101e3 <.Lstr.23>
8000acc0:	a099                	j	8000ad06 <.LBB16_8>

8000acc2 <.LBB16_5>:
    if (g_usbd_msc[busid].cbw.dDataLength != (g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN])) {
8000acc2:	4330                	lw	a2,64(a4)
8000acc4:	02f60633          	mul	a2,a2,a5
8000acc8:	02c81563          	bne	a6,a2,8000acf2 <.LBB16_7>
8000accc:	25400613          	li	a2,596
    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_IN);
8000acd0:	02c50533          	mul	a0,a0,a2
8000acd4:	00097637          	lui	a2,0x97
8000acd8:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
8000acdc:	9532                	add	a0,a0,a2
8000acde:	24852503          	lw	a0,584(a0)
8000ace2:	4609                	li	a2,2
    g_usbd_msc[busid].stage = MSC_DATA_IN;
8000ace4:	00c58023          	sb	a2,0(a1)
    usb_osal_mq_send(g_usbd_msc[busid].usbd_msc_mq, MSC_DATA_IN);
8000ace8:	4589                	li	a1,2
8000acea:	9e7fc0ef          	jal	800076d0 <usb_osal_mq_send>
8000acee:	4505                	li	a0,1
8000acf0:	a025                	j	8000ad18 <.LBB16_9>

8000acf2 <.LBB16_7>:
        USB_LOG_ERR("scsi_blk_len does not match with dDataLength\r\n");
8000acf2:	80010537          	lui	a0,0x80010
8000acf6:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
8000acfa:	e43fe0ef          	jal	80009b3c <printf>
8000acfe:	80010537          	lui	a0,0x80010
8000ad02:	1b550513          	add	a0,a0,437 # 800101b5 <.Lstr.20>

8000ad06 <.LBB16_8>:
8000ad06:	410020ef          	jal	8000d116 <puts>
8000ad0a:	80011537          	lui	a0,0x80011
8000ad0e:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
8000ad12:	e2bfe0ef          	jal	80009b3c <printf>
8000ad16:	4501                	li	a0,0

8000ad18 <.LBB16_9>:
8000ad18:	40b2                	lw	ra,12(sp)
8000ad1a:	0141                	add	sp,sp,16
}
8000ad1c:	8082                	ret

Disassembly of section .text.SCSI_write10:

8000ad1e <SCSI_write10>:
{
8000ad1e:	1141                	add	sp,sp,-16
8000ad20:	c606                	sw	ra,12(sp)
8000ad22:	25400593          	li	a1,596
    if (((g_usbd_msc[busid].cbw.bmFlags & 0x80U) != 0x00U) || (g_usbd_msc[busid].cbw.dDataLength == 0U)) {
8000ad26:	02b505b3          	mul	a1,a0,a1
8000ad2a:	00097637          	lui	a2,0x97
8000ad2e:	a6060613          	add	a2,a2,-1440 # 96a60 <g_usbd_msc>
8000ad32:	95b2                	add	a1,a1,a2
8000ad34:	01058603          	lb	a2,16(a1)
8000ad38:	08064763          	bltz	a2,8000adc6 <.LBB17_4>
8000ad3c:	45d4                	lw	a3,12(a1)
8000ad3e:	c6c1                	beqz	a3,8000adc6 <.LBB17_4>
8000ad40:	25400613          	li	a2,596
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ad44:	02c50633          	mul	a2,a0,a2
8000ad48:	00097737          	lui	a4,0x97
8000ad4c:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
8000ad50:	00c707b3          	add	a5,a4,a2
8000ad54:	0157c603          	lbu	a2,21(a5)
8000ad58:	0167c703          	lbu	a4,22(a5)
8000ad5c:	01861813          	sll	a6,a2,0x18
8000ad60:	0177c603          	lbu	a2,23(a5)
8000ad64:	0742                	sll	a4,a4,0x10
8000ad66:	0187c883          	lbu	a7,24(a5)
8000ad6a:	01076833          	or	a6,a4,a6
8000ad6e:	0622                	sll	a2,a2,0x8
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
8000ad70:	01a7c283          	lbu	t0,26(a5)
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ad74:	01166633          	or	a2,a2,a7
    data_len = g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN];
8000ad78:	0117c703          	lbu	a4,17(a5)
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ad7c:	00c86633          	or	a2,a6,a2
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
8000ad80:	02a2                	sll	t0,t0,0x8
8000ad82:	01b7c883          	lbu	a7,27(a5)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ad86:	070a                	sll	a4,a4,0x2
8000ad88:	00e78833          	add	a6,a5,a4
8000ad8c:	04482303          	lw	t1,68(a6)
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
8000ad90:	0112e733          	or	a4,t0,a7
    g_usbd_msc[busid].start_sector = GET_BE32(&g_usbd_msc[busid].cbw.CB[2]); /* Logical Block Address of First Block */
8000ad94:	df90                	sw	a2,56(a5)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ad96:	963a                	add	a2,a2,a4
    g_usbd_msc[busid].nsectors = GET_BE16(&g_usbd_msc[busid].cbw.CB[7]); /* Number of Blocks to transfer */
8000ad98:	dfd8                	sw	a4,60(a5)
    if ((g_usbd_msc[busid].start_sector + g_usbd_msc[busid].nsectors) > g_usbd_msc[busid].scsi_blk_nbr[g_usbd_msc[busid].cbw.bLUN]) {
8000ad9a:	04c37163          	bgeu	t1,a2,8000addc <.LBB17_6>
        USB_LOG_ERR("LBA out of range\r\n");
8000ad9e:	80010537          	lui	a0,0x80010
8000ada2:	10350513          	add	a0,a0,259 # 80010103 <.L.str>
8000ada6:	d97fe0ef          	jal	80009b3c <printf>
8000adaa:	80010537          	lui	a0,0x80010
8000adae:	1e350513          	add	a0,a0,483 # 800101e3 <.Lstr.23>
8000adb2:	364020ef          	jal	8000d116 <puts>
8000adb6:	80011537          	lui	a0,0x80011
8000adba:	99e50513          	add	a0,a0,-1634 # 8001099e <.L.str.2>
8000adbe:	d7ffe0ef          	jal	80009b3c <printf>
8000adc2:	4501                	li	a0,0
8000adc4:	a809                	j	8000add6 <.LBB17_5>

8000adc6 <.LBB17_4>:
8000adc6:	4501                	li	a0,0
8000adc8:	4615                	li	a2,5
    g_usbd_msc[busid].sKey = (uint8_t)(KCQ >> 16);
8000adca:	02c589a3          	sb	a2,51(a1)
8000adce:	02000613          	li	a2,32
    g_usbd_msc[busid].ASC = (uint8_t)(KCQ >> 8);
8000add2:	02c59a23          	sh	a2,52(a1)

8000add6 <.LBB17_5>:
8000add6:	40b2                	lw	ra,12(sp)
}
8000add8:	0141                	add	sp,sp,16
8000adda:	8082                	ret

8000addc <.LBB17_6>:
    data_len = g_usbd_msc[busid].nsectors * g_usbd_msc[busid].scsi_blk_size[g_usbd_msc[busid].cbw.bLUN];
8000addc:	04082603          	lw	a2,64(a6)
8000ade0:	02e60633          	mul	a2,a2,a4
    if (g_usbd_msc[busid].cbw.dDataLength != data_len) {
8000ade4:	04c69163          	bne	a3,a2,8000ae26 <.LBB17_10>
8000ade8:	4605                	li	a2,1
8000adea:	20000713          	li	a4,512
    g_usbd_msc[busid].stage = MSC_DATA_OUT;
8000adee:	00c58023          	sb	a2,0(a1)
    data_len = MIN(data_len, CONFIG_USBDEV_MSC_MAX_BUFSIZE);
8000adf2:	00e6e463          	bltu	a3,a4,8000adfa <.LBB17_9>
8000adf6:	20000693          	li	a3,512

8000adfa <.LBB17_9>:
    usbd_ep_start_read(busid, mass_ep_data[busid][MSD_OUT_EP_IDX].ep_addr, g_usbd_msc[busid].block_buffer, data_len);
8000adfa:	00451593          	sll	a1,a0,0x4
8000adfe:	5e018613          	add	a2,gp,1504 # 81950 <mass_ep_data>
8000ae02:	95b2                	add	a1,a1,a2
8000ae04:	0005c583          	lbu	a1,0(a1)
8000ae08:	25400613          	li	a2,596
8000ae0c:	02c50633          	mul	a2,a0,a2
8000ae10:	00097737          	lui	a4,0x97
8000ae14:	a6070713          	add	a4,a4,-1440 # 96a60 <g_usbd_msc>
8000ae18:	963a                	add	a2,a2,a4
8000ae1a:	04860613          	add	a2,a2,72
8000ae1e:	0d2010ef          	jal	8000bef0 <usbd_ep_start_read>
8000ae22:	4505                	li	a0,1
8000ae24:	bf4d                	j	8000add6 <.LBB17_5>

8000ae26 <.LBB17_10>:
8000ae26:	4501                	li	a0,0
8000ae28:	b77d                	j	8000add6 <.LBB17_5>

Disassembly of section .text.usbd_msc_send_info:

8000ae2a <usbd_msc_send_info>:
{
8000ae2a:	1141                	add	sp,sp,-16
8000ae2c:	c606                	sw	ra,12(sp)
8000ae2e:	c422                	sw	s0,8(sp)
8000ae30:	c226                	sw	s1,4(sp)
8000ae32:	25400693          	li	a3,596
    size = MIN(size, g_usbd_msc[busid].cbw.dDataLength);
8000ae36:	02d504b3          	mul	s1,a0,a3
8000ae3a:	000976b7          	lui	a3,0x97
8000ae3e:	a6068693          	add	a3,a3,-1440 # 96a60 <g_usbd_msc>
8000ae42:	94b6                	add	s1,s1,a3
8000ae44:	44d8                	lw	a4,12(s1)
8000ae46:	86ae                	mv	a3,a1
8000ae48:	00e66363          	bltu	a2,a4,8000ae4e <.LBB19_2>
8000ae4c:	863a                	mv	a2,a4

8000ae4e <.LBB19_2>:
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, buffer, size);
8000ae4e:	00451593          	sll	a1,a0,0x4
8000ae52:	5e018713          	add	a4,gp,1504 # 81950 <mass_ep_data>
8000ae56:	95ba                	add	a1,a1,a4
8000ae58:	0085c583          	lbu	a1,8(a1)
8000ae5c:	470d                	li	a4,3
    g_usbd_msc[busid].stage = MSC_SEND_CSW;
8000ae5e:	00e48023          	sb	a4,0(s1)
    usbd_ep_start_write(busid, mass_ep_data[busid][MSD_IN_EP_IDX].ep_addr, buffer, size);
8000ae62:	0ff67413          	zext.b	s0,a2
8000ae66:	8636                	mv	a2,a3
8000ae68:	86a2                	mv	a3,s0
8000ae6a:	02a010ef          	jal	8000be94 <usbd_ep_start_write>
    g_usbd_msc[busid].csw.dDataResidue -= size;
8000ae6e:	54c8                	lw	a0,44(s1)
8000ae70:	8d01                	sub	a0,a0,s0
8000ae72:	d4c8                	sw	a0,44(s1)
    g_usbd_msc[busid].csw.bStatus = CSW_STATUS_CMD_PASSED;
8000ae74:	02048823          	sb	zero,48(s1)
8000ae78:	40b2                	lw	ra,12(sp)
8000ae7a:	4422                	lw	s0,8(sp)
8000ae7c:	4492                	lw	s1,4(sp)
}
8000ae7e:	0141                	add	sp,sp,16
8000ae80:	8082                	ret

Disassembly of section .text.usbd_class_event_notify_handler:

8000ae82 <usbd_class_event_notify_handler>:
{
8000ae82:	1101                	add	sp,sp,-32
8000ae84:	ce06                	sw	ra,28(sp)
8000ae86:	cc22                	sw	s0,24(sp)
8000ae88:	ca26                	sw	s1,20(sp)
8000ae8a:	c84a                	sw	s2,16(sp)
8000ae8c:	c64e                	sw	s3,12(sp)
8000ae8e:	c452                	sw	s4,8(sp)
8000ae90:	c256                	sw	s5,4(sp)
8000ae92:	89aa                	mv	s3,a0
8000ae94:	3d400513          	li	a0,980
8000ae98:	02a98533          	mul	a0,s3,a0
8000ae9c:	000896b7          	lui	a3,0x89
8000aea0:	39868693          	add	a3,a3,920 # 89398 <g_usbd_core>
8000aea4:	9536                	add	a0,a0,a3
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000aea6:	24c54683          	lbu	a3,588(a0)
8000aeaa:	c6b9                	beqz	a3,8000aef8 <.LBB5_12>
8000aeac:	8ab2                	mv	s5,a2
8000aeae:	892e                	mv	s2,a1
8000aeb0:	4401                	li	s0,0
8000aeb2:	24c50a13          	add	s4,a0,588
8000aeb6:	22c50493          	add	s1,a0,556
8000aeba:	a801                	j	8000aeca <.LBB5_4>

8000aebc <.LBB5_2>:
8000aebc:	9682                	jalr	a3

8000aebe <.LBB5_3>:
8000aebe:	000a4503          	lbu	a0,0(s4)
8000aec2:	0405                	add	s0,s0,1
8000aec4:	0491                	add	s1,s1,4
8000aec6:	02a47963          	bgeu	s0,a0,8000aef8 <.LBB5_12>

8000aeca <.LBB5_4>:
        struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000aeca:	4088                	lw	a0,0(s1)
        if (arg) {
8000aecc:	000a8f63          	beqz	s5,8000aeea <.LBB5_9>
            if (intf && intf->notify_handler && (desc->bInterfaceNumber == (intf->intf_num))) {
8000aed0:	d57d                	beqz	a0,8000aebe <.LBB5_3>
8000aed2:	4554                	lw	a3,12(a0)
8000aed4:	d6ed                	beqz	a3,8000aebe <.LBB5_3>
8000aed6:	002ac583          	lbu	a1,2(s5)
8000aeda:	01854503          	lbu	a0,24(a0)
8000aede:	fea590e3          	bne	a1,a0,8000aebe <.LBB5_3>
                intf->notify_handler(busid, event, arg);
8000aee2:	854e                	mv	a0,s3
8000aee4:	85ca                	mv	a1,s2
8000aee6:	8656                	mv	a2,s5
8000aee8:	bfd1                	j	8000aebc <.LBB5_2>

8000aeea <.LBB5_9>:
            if (intf && intf->notify_handler) {
8000aeea:	d971                	beqz	a0,8000aebe <.LBB5_3>
8000aeec:	4554                	lw	a3,12(a0)
8000aeee:	dae1                	beqz	a3,8000aebe <.LBB5_3>
                intf->notify_handler(busid, event, arg);
8000aef0:	854e                	mv	a0,s3
8000aef2:	85ca                	mv	a1,s2
8000aef4:	4601                	li	a2,0
8000aef6:	b7d9                	j	8000aebc <.LBB5_2>

8000aef8 <.LBB5_12>:
8000aef8:	40f2                	lw	ra,28(sp)
8000aefa:	4462                	lw	s0,24(sp)
8000aefc:	44d2                	lw	s1,20(sp)
8000aefe:	4942                	lw	s2,16(sp)
8000af00:	49b2                	lw	s3,12(sp)
8000af02:	4a22                	lw	s4,8(sp)
8000af04:	4a92                	lw	s5,4(sp)
}
8000af06:	6105                	add	sp,sp,32
8000af08:	8082                	ret

Disassembly of section .text.usbd_event_ep0_setup_complete_handler:

8000af0a <usbd_event_ep0_setup_complete_handler>:
{
8000af0a:	1101                	add	sp,sp,-32
8000af0c:	ce06                	sw	ra,28(sp)
8000af0e:	cc22                	sw	s0,24(sp)
8000af10:	ca26                	sw	s1,20(sp)
8000af12:	c84a                	sw	s2,16(sp)
8000af14:	c64e                	sw	s3,12(sp)
8000af16:	842a                	mv	s0,a0
8000af18:	3d400513          	li	a0,980
    struct usb_setup_packet *setup = &g_usbd_core[busid].setup;
8000af1c:	02a404b3          	mul	s1,s0,a0
8000af20:	00089537          	lui	a0,0x89
8000af24:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000af28:	94aa                	add	s1,s1,a0
    memcpy(setup, psetup, 8);
8000af2a:	0015c503          	lbu	a0,1(a1)
8000af2e:	0005c603          	lbu	a2,0(a1)
8000af32:	0025c683          	lbu	a3,2(a1)
8000af36:	0035c703          	lbu	a4,3(a1)
8000af3a:	0522                	sll	a0,a0,0x8
8000af3c:	8d51                	or	a0,a0,a2
8000af3e:	06c2                	sll	a3,a3,0x10
8000af40:	0762                	sll	a4,a4,0x18
8000af42:	8ed9                	or	a3,a3,a4
8000af44:	8d55                	or	a0,a0,a3
8000af46:	0055c683          	lbu	a3,5(a1)
8000af4a:	0045c703          	lbu	a4,4(a1)
8000af4e:	0065c783          	lbu	a5,6(a1)
8000af52:	0075c583          	lbu	a1,7(a1)
8000af56:	06a2                	sll	a3,a3,0x8
8000af58:	8ed9                	or	a3,a3,a4
8000af5a:	07c2                	sll	a5,a5,0x10
8000af5c:	05e2                	sll	a1,a1,0x18
8000af5e:	8ddd                	or	a1,a1,a5
8000af60:	8ecd                	or	a3,a3,a1
8000af62:	c0d4                	sw	a3,4(s1)
8000af64:	c088                	sw	a0,0(s1)
    if (setup->wLength > CONFIG_USBDEV_REQUEST_BUFFER_LEN) {
8000af66:	0105d693          	srl	a3,a1,0x10
8000af6a:	01861513          	sll	a0,a2,0x18
8000af6e:	20100593          	li	a1,513
8000af72:	8561                	sra	a0,a0,0x18
8000af74:	04b6e163          	bltu	a3,a1,8000afb6 <.LBB6_4>
8000af78:	02054f63          	bltz	a0,8000afb6 <.LBB6_4>
            USB_LOG_ERR("Request buffer too small\r\n");
8000af7c:	80010537          	lui	a0,0x80010
8000af80:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000af84:	bb9fe0ef          	jal	80009b3c <printf>
8000af88:	80010537          	lui	a0,0x80010
8000af8c:	22b50513          	add	a0,a0,555 # 8001022b <.Lstr.21>
8000af90:	186020ef          	jal	8000d116 <puts>
8000af94:	80011537          	lui	a0,0x80011
8000af98:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000af9c:	ba1fe0ef          	jal	80009b3c <printf>

8000afa0 <.LBB6_3>:
8000afa0:	08000593          	li	a1,128
8000afa4:	8522                	mv	a0,s0
8000afa6:	40f2                	lw	ra,28(sp)
8000afa8:	4462                	lw	s0,24(sp)
8000afaa:	44d2                	lw	s1,20(sp)
8000afac:	4942                	lw	s2,16(sp)
8000afae:	49b2                	lw	s3,12(sp)
8000afb0:	6105                	add	sp,sp,32
8000afb2:	6a30006f          	j	8000be54 <usbd_ep_set_stall>

8000afb6 <.LBB6_4>:
    g_usbd_core[busid].ep0_data_buf = g_usbd_core[busid].req_data;
8000afb6:	02848613          	add	a2,s1,40
8000afba:	c490                	sw	a2,8(s1)
    g_usbd_core[busid].ep0_data_buf_residue = setup->wLength;
8000afbc:	c4d4                	sw	a3,12(s1)
    g_usbd_core[busid].ep0_data_buf_len = setup->wLength;
8000afbe:	c894                	sw	a3,16(s1)
    g_usbd_core[busid].zlp_flag = false;
8000afc0:	00048a23          	sb	zero,20(s1)
    if (setup->wLength && ((setup->bmRequestType & USB_REQUEST_DIR_MASK) == USB_REQUEST_DIR_OUT)) {
8000afc4:	ce89                	beqz	a3,8000afde <.LBB6_7>
8000afc6:	00054c63          	bltz	a0,8000afde <.LBB6_7>
        usbd_ep_start_read(busid, USB_CONTROL_OUT_EP0, g_usbd_core[busid].ep0_data_buf, setup->wLength);
8000afca:	8522                	mv	a0,s0
8000afcc:	4581                	li	a1,0
8000afce:	40f2                	lw	ra,28(sp)
8000afd0:	4462                	lw	s0,24(sp)
8000afd2:	44d2                	lw	s1,20(sp)
8000afd4:	4942                	lw	s2,16(sp)
8000afd6:	49b2                	lw	s3,12(sp)
8000afd8:	6105                	add	sp,sp,32
8000afda:	7170006f          	j	8000bef0 <usbd_ep_start_read>

8000afde <.LBB6_7>:
8000afde:	00848993          	add	s3,s1,8
8000afe2:	01048913          	add	s2,s1,16
    if (!usbd_setup_request_handler(busid, setup, &g_usbd_core[busid].ep0_data_buf, &g_usbd_core[busid].ep0_data_buf_len)) {
8000afe6:	8522                	mv	a0,s0
8000afe8:	85a6                	mv	a1,s1
8000afea:	864e                	mv	a2,s3
8000afec:	86ca                	mv	a3,s2
8000afee:	2059                	jal	8000b074 <usbd_setup_request_handler>
8000aff0:	d945                	beqz	a0,8000afa0 <.LBB6_3>
    g_usbd_core[busid].ep0_data_buf_residue = MIN(g_usbd_core[busid].ep0_data_buf_len, setup->wLength);
8000aff2:	00092683          	lw	a3,0(s2)
8000aff6:	0064d583          	lhu	a1,6(s1)
8000affa:	00c48513          	add	a0,s1,12
8000affe:	00b6e363          	bltu	a3,a1,8000b004 <.LBB6_10>
8000b002:	86ae                	mv	a3,a1

8000b004 <.LBB6_10>:
8000b004:	20100593          	li	a1,513
8000b008:	c114                	sw	a3,0(a0)
    if (g_usbd_core[busid].ep0_data_buf_residue > CONFIG_USBDEV_REQUEST_BUFFER_LEN) {
8000b00a:	02b6ea63          	bltu	a3,a1,8000b03e <.LBB6_12>
        USB_LOG_ERR("Request buffer too small\r\n");
8000b00e:	80010537          	lui	a0,0x80010
8000b012:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b016:	b27fe0ef          	jal	80009b3c <printf>
8000b01a:	80010537          	lui	a0,0x80010
8000b01e:	22b50513          	add	a0,a0,555 # 8001022b <.Lstr.21>
8000b022:	0f4020ef          	jal	8000d116 <puts>
8000b026:	80011537          	lui	a0,0x80011
8000b02a:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b02e:	40f2                	lw	ra,28(sp)
8000b030:	4462                	lw	s0,24(sp)
8000b032:	44d2                	lw	s1,20(sp)
8000b034:	4942                	lw	s2,16(sp)
8000b036:	49b2                	lw	s3,12(sp)
8000b038:	6105                	add	sp,sp,32
8000b03a:	b03fe06f          	j	80009b3c <printf>

8000b03e <.LBB6_12>:
    usbd_ep_start_write(busid, USB_CONTROL_IN_EP0, g_usbd_core[busid].ep0_data_buf, g_usbd_core[busid].ep0_data_buf_residue);
8000b03e:	0009a603          	lw	a2,0(s3) # fffff000 <__AHB_SRAM_segment_end__+0xfbf7000>
8000b042:	08000593          	li	a1,128
8000b046:	8522                	mv	a0,s0
8000b048:	64d000ef          	jal	8000be94 <usbd_ep_start_write>
    if ((setup->wLength > g_usbd_core[busid].ep0_data_buf_len) && (!(g_usbd_core[busid].ep0_data_buf_len % USB_CTRL_EP_MPS))) {
8000b04c:	0064d583          	lhu	a1,6(s1)
8000b050:	00092503          	lw	a0,0(s2)
8000b054:	00b57963          	bgeu	a0,a1,8000b066 <.LBB6_15>
8000b058:	03f57513          	and	a0,a0,63
8000b05c:	e509                	bnez	a0,8000b066 <.LBB6_15>
8000b05e:	04d1                	add	s1,s1,20
8000b060:	4505                	li	a0,1
        g_usbd_core[busid].zlp_flag = true;
8000b062:	00a48023          	sb	a0,0(s1)

8000b066 <.LBB6_15>:
8000b066:	40f2                	lw	ra,28(sp)
8000b068:	4462                	lw	s0,24(sp)
8000b06a:	44d2                	lw	s1,20(sp)
8000b06c:	4942                	lw	s2,16(sp)
8000b06e:	49b2                	lw	s3,12(sp)
}
8000b070:	6105                	add	sp,sp,32
8000b072:	8082                	ret

Disassembly of section .text.usbd_setup_request_handler:

8000b074 <usbd_setup_request_handler>:
{
8000b074:	715d                	add	sp,sp,-80
8000b076:	c686                	sw	ra,76(sp)
8000b078:	c4a2                	sw	s0,72(sp)
8000b07a:	c2a6                	sw	s1,68(sp)
8000b07c:	c0ca                	sw	s2,64(sp)
8000b07e:	de4e                	sw	s3,60(sp)
8000b080:	dc52                	sw	s4,56(sp)
8000b082:	da56                	sw	s5,52(sp)
8000b084:	d85a                	sw	s6,48(sp)
8000b086:	d65e                	sw	s7,44(sp)
8000b088:	d462                	sw	s8,40(sp)
8000b08a:	d266                	sw	s9,36(sp)
8000b08c:	d06a                	sw	s10,32(sp)
8000b08e:	ce6e                	sw	s11,28(sp)
8000b090:	8dae                	mv	s11,a1
    switch (setup->bmRequestType & USB_REQUEST_TYPE_MASK) {
8000b092:	0005c583          	lbu	a1,0(a1)
8000b096:	0605f713          	and	a4,a1,96
8000b09a:	04000793          	li	a5,64
8000b09e:	8936                	mv	s2,a3
8000b0a0:	89b2                	mv	s3,a2
8000b0a2:	8a2a                	mv	s4,a0
8000b0a4:	0cf70163          	beq	a4,a5,8000b166 <.LBB7_18>
8000b0a8:	02000513          	li	a0,32
8000b0ac:	06a70a63          	beq	a4,a0,8000b120 <.LBB7_11>
8000b0b0:	6e071f63          	bnez	a4,8000b7ae <.LBB7_110>
    switch (setup->bmRequestType & USB_REQUEST_RECIPIENT_MASK) {
8000b0b4:	898d                	and	a1,a1,3
8000b0b6:	4509                	li	a0,2
8000b0b8:	2ca58563          	beq	a1,a0,8000b382 <.LBB7_49>
8000b0bc:	4505                	li	a0,1
8000b0be:	22a58563          	beq	a1,a0,8000b2e8 <.LBB7_42>
8000b0c2:	68059063          	bnez	a1,8000b742 <.LBB7_108>
    switch (setup->bRequest) {
8000b0c6:	001dc583          	lbu	a1,1(s11)
8000b0ca:	4525                	li	a0,9
8000b0cc:	66b56b63          	bltu	a0,a1,8000b742 <.LBB7_108>
8000b0d0:	002dc503          	lbu	a0,2(s11)
8000b0d4:	003dc603          	lbu	a2,3(s11)
8000b0d8:	00259693          	sll	a3,a1,0x2
8000b0dc:	80005737          	lui	a4,0x80005
8000b0e0:	ed470713          	add	a4,a4,-300 # 80004ed4 <.LJTI7_0>
8000b0e4:	96ba                	add	a3,a3,a4
8000b0e6:	4294                	lw	a3,0(a3)
8000b0e8:	0622                	sll	a2,a2,0x8
8000b0ea:	00a66b33          	or	s6,a2,a0
8000b0ee:	8682                	jr	a3

8000b0f0 <.LBB7_8>:
8000b0f0:	4505                	li	a0,1
            if (value == USB_FEATURE_REMOTE_WAKEUP) {
8000b0f2:	02ab1463          	bne	s6,a0,8000b11a <.LBB7_10>
8000b0f6:	3d400513          	li	a0,980
8000b0fa:	02aa0533          	mul	a0,s4,a0
8000b0fe:	00089637          	lui	a2,0x89
8000b102:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
8000b106:	9532                	add	a0,a0,a2
8000b108:	3d052603          	lw	a2,976(a0)
                if (setup->bRequest == USB_REQUEST_SET_FEATURE) {
8000b10c:	15f5                	add	a1,a1,-3
8000b10e:	00b035b3          	snez	a1,a1
8000b112:	05a5                	add	a1,a1,9
8000b114:	8552                	mv	a0,s4
8000b116:	9602                	jalr	a2
8000b118:	4505                	li	a0,1

8000b11a <.LBB7_10>:
            *len = 0;
8000b11a:	00092023          	sw	zero,0(s2)
8000b11e:	ad49                	j	8000b7b0 <.LBB7_111>

8000b120 <.LBB7_11>:
    if ((setup->bmRequestType & USB_REQUEST_RECIPIENT_MASK) == USB_REQUEST_RECIPIENT_INTERFACE) {
8000b120:	898d                	and	a1,a1,3
8000b122:	4505                	li	a0,1
8000b124:	14a58f63          	beq	a1,a0,8000b282 <.LBB7_34>
8000b128:	4509                	li	a0,2
8000b12a:	1aa59463          	bne	a1,a0,8000b2d2 <.LBB7_41>
8000b12e:	3d400593          	li	a1,980
8000b132:	02ba0533          	mul	a0,s4,a1
8000b136:	00089637          	lui	a2,0x89
8000b13a:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
8000b13e:	9532                	add	a0,a0,a2
8000b140:	24c54503          	lbu	a0,588(a0)
        for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b144:	18050763          	beqz	a0,8000b2d2 <.LBB7_41>
8000b148:	02ba05b3          	mul	a1,s4,a1
8000b14c:	95b2                	add	a1,a1,a2
8000b14e:	22c58593          	add	a1,a1,556
8000b152:	a029                	j	8000b15c <.LBB7_16>

8000b154 <.LBB7_15>:
8000b154:	157d                	add	a0,a0,-1
8000b156:	0591                	add	a1,a1,4
8000b158:	16050d63          	beqz	a0,8000b2d2 <.LBB7_41>

8000b15c <.LBB7_16>:
            struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000b15c:	4190                	lw	a2,0(a1)
8000b15e:	da7d                	beqz	a2,8000b154 <.LBB7_15>
            if (intf && intf->class_endpoint_handler) {
8000b160:	4258                	lw	a4,4(a2)
8000b162:	db6d                	beqz	a4,8000b154 <.LBB7_15>
8000b164:	aab1                	j	8000b2c0 <.LBB7_40>

8000b166 <.LBB7_18>:
8000b166:	3d400513          	li	a0,980
    if (g_usbd_core[busid].msosv1_desc) {
8000b16a:	02aa0433          	mul	s0,s4,a0
8000b16e:	000895b7          	lui	a1,0x89
8000b172:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b176:	942e                	add	s0,s0,a1
8000b178:	4c50                	lw	a2,28(s0)
8000b17a:	ca29                	beqz	a2,8000b1cc <.LBB7_23>
        if (setup->bRequest == g_usbd_core[busid].msosv1_desc->vendor_code) {
8000b17c:	001dc503          	lbu	a0,1(s11)
8000b180:	00464583          	lbu	a1,4(a2)
8000b184:	0ab51863          	bne	a0,a1,8000b234 <.LBB7_27>
            switch (setup->wIndex) {
8000b188:	005dc503          	lbu	a0,5(s11)
8000b18c:	004dc583          	lbu	a1,4(s11)
8000b190:	0522                	sll	a0,a0,0x8
8000b192:	8d4d                	or	a0,a0,a1
8000b194:	4595                	li	a1,5
8000b196:	0471                	add	s0,s0,28
8000b198:	28b50763          	beq	a0,a1,8000b426 <.LBB7_60>
8000b19c:	4591                	li	a1,4
8000b19e:	24b51763          	bne	a0,a1,8000b3ec <.LBB7_58>
                    USB_LOG_INFO("get Compat ID\r\n");
8000b1a2:	80010537          	lui	a0,0x80010
8000b1a6:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b1aa:	993fe0ef          	jal	80009b3c <printf>
8000b1ae:	8000f537          	lui	a0,0x8000f
8000b1b2:	3fc50513          	add	a0,a0,1020 # 8000f3fc <.Lstr.29>
8000b1b6:	761010ef          	jal	8000d116 <puts>
8000b1ba:	80011537          	lui	a0,0x80011
8000b1be:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b1c2:	97bfe0ef          	jal	80009b3c <printf>
                    desclen = g_usbd_core[busid].msosv1_desc->compat_id[0] +
8000b1c6:	4008                	lw	a0,0(s0)
8000b1c8:	450c                	lw	a1,8(a0)
8000b1ca:	ac59                	j	8000b460 <.LBB7_61>

8000b1cc <.LBB7_23>:
    } else if (g_usbd_core[busid].msosv2_desc) {
8000b1cc:	02aa0533          	mul	a0,s4,a0
8000b1d0:	952e                	add	a0,a0,a1
8000b1d2:	510c                	lw	a1,32(a0)
8000b1d4:	c1a5                	beqz	a1,8000b234 <.LBB7_27>
        if (setup->bRequest == g_usbd_core[busid].msosv2_desc->vendor_code) {
8000b1d6:	001dc603          	lbu	a2,1(s11)
8000b1da:	0065c583          	lbu	a1,6(a1)
8000b1de:	04b61b63          	bne	a2,a1,8000b234 <.LBB7_27>
            switch (setup->wIndex) {
8000b1e2:	005dc583          	lbu	a1,5(s11)
8000b1e6:	004dc603          	lbu	a2,4(s11)
8000b1ea:	05a2                	sll	a1,a1,0x8
8000b1ec:	8dd1                	or	a1,a1,a2
8000b1ee:	461d                	li	a2,7
8000b1f0:	1ec59e63          	bne	a1,a2,8000b3ec <.LBB7_58>
8000b1f4:	02050413          	add	s0,a0,32
                    USB_LOG_INFO("GET MS OS 2.0 Descriptor\r\n");
8000b1f8:	80010537          	lui	a0,0x80010
8000b1fc:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b200:	93dfe0ef          	jal	80009b3c <printf>
8000b204:	80010537          	lui	a0,0x80010
8000b208:	26950513          	add	a0,a0,617 # 80010269 <.Lstr.27>
8000b20c:	70b010ef          	jal	8000d116 <puts>
8000b210:	80011537          	lui	a0,0x80011
8000b214:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b218:	925fe0ef          	jal	80009b3c <printf>
                    memcpy(*data, g_usbd_core[busid].msosv2_desc->compat_id, g_usbd_core[busid].msosv2_desc->compat_id_len);
8000b21c:	4010                	lw	a2,0(s0)
8000b21e:	0009a503          	lw	a0,0(s3)
8000b222:	420c                	lw	a1,0(a2)
8000b224:	00465603          	lhu	a2,4(a2)
8000b228:	e7afe0ef          	jal	800098a2 <memcpy>
                    *len = g_usbd_core[busid].msosv2_desc->compat_id_len;
8000b22c:	4008                	lw	a0,0(s0)
8000b22e:	00455503          	lhu	a0,4(a0)
8000b232:	adad                	j	8000b8ac <.LBB7_122>

8000b234 <.LBB7_27>:
8000b234:	3d400513          	li	a0,980
8000b238:	02aa05b3          	mul	a1,s4,a0
8000b23c:	00089537          	lui	a0,0x89
8000b240:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000b244:	95aa                	add	a1,a1,a0
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b246:	24c5c503          	lbu	a0,588(a1)
8000b24a:	1c050363          	beqz	a0,8000b410 <.LBB7_59>
8000b24e:	4401                	li	s0,0
8000b250:	24c58a93          	add	s5,a1,588
8000b254:	22c58493          	add	s1,a1,556
8000b258:	a039                	j	8000b266 <.LBB7_30>

8000b25a <.LBB7_29>:
8000b25a:	0405                	add	s0,s0,1
8000b25c:	0ff57593          	zext.b	a1,a0
8000b260:	0491                	add	s1,s1,4
8000b262:	1ab47763          	bgeu	s0,a1,8000b410 <.LBB7_59>

8000b266 <.LBB7_30>:
        struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000b266:	408c                	lw	a1,0(s1)
        if (intf && intf->vendor_handler && (intf->vendor_handler(busid, setup, data, len) == 0)) {
8000b268:	d9ed                	beqz	a1,8000b25a <.LBB7_29>
8000b26a:	4598                	lw	a4,8(a1)
8000b26c:	d77d                	beqz	a4,8000b25a <.LBB7_29>
8000b26e:	8552                	mv	a0,s4
8000b270:	85ee                	mv	a1,s11
8000b272:	864e                	mv	a2,s3
8000b274:	86ca                	mv	a3,s2
8000b276:	9702                	jalr	a4
8000b278:	20050a63          	beqz	a0,8000b48c <.LBB7_62>
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b27c:	000ac503          	lbu	a0,0(s5)
8000b280:	bfe9                	j	8000b25a <.LBB7_29>

8000b282 <.LBB7_34>:
8000b282:	3d400593          	li	a1,980
8000b286:	02ba0533          	mul	a0,s4,a1
8000b28a:	00089637          	lui	a2,0x89
8000b28e:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
8000b292:	9532                	add	a0,a0,a2
8000b294:	24c54503          	lbu	a0,588(a0)
        for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b298:	cd0d                	beqz	a0,8000b2d2 <.LBB7_41>
8000b29a:	02ba05b3          	mul	a1,s4,a1
8000b29e:	95b2                	add	a1,a1,a2
8000b2a0:	22c58593          	add	a1,a1,556
8000b2a4:	a021                	j	8000b2ac <.LBB7_37>

8000b2a6 <.LBB7_36>:
8000b2a6:	157d                	add	a0,a0,-1
8000b2a8:	0591                	add	a1,a1,4
8000b2aa:	c505                	beqz	a0,8000b2d2 <.LBB7_41>

8000b2ac <.LBB7_37>:
            struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000b2ac:	4190                	lw	a2,0(a1)
            if (intf && intf->class_interface_handler && (intf->intf_num == (setup->wIndex & 0xFF))) {
8000b2ae:	de65                	beqz	a2,8000b2a6 <.LBB7_36>
8000b2b0:	4218                	lw	a4,0(a2)
8000b2b2:	db75                	beqz	a4,8000b2a6 <.LBB7_36>
8000b2b4:	01864603          	lbu	a2,24(a2)
8000b2b8:	004dc683          	lbu	a3,4(s11)
8000b2bc:	fed615e3          	bne	a2,a3,8000b2a6 <.LBB7_36>

8000b2c0 <.LBB7_40>:
8000b2c0:	8552                	mv	a0,s4
8000b2c2:	85ee                	mv	a1,s11
8000b2c4:	864e                	mv	a2,s3
8000b2c6:	86ca                	mv	a3,s2
8000b2c8:	9702                	jalr	a4
8000b2ca:	85aa                	mv	a1,a0
8000b2cc:	4505                	li	a0,1
            if (usbd_class_request_handler(busid, setup, data, len) < 0) {
8000b2ce:	4e05d163          	bgez	a1,8000b7b0 <.LBB7_111>

8000b2d2 <.LBB7_41>:
                USB_LOG_ERR("class request error\r\n");
8000b2d2:	80010537          	lui	a0,0x80010
8000b2d6:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b2da:	863fe0ef          	jal	80009b3c <printf>
8000b2de:	80011537          	lui	a0,0x80011
8000b2e2:	a5150513          	add	a0,a0,-1455 # 80010a51 <.Lstr.23>
8000b2e6:	a1b5                	j	8000b752 <.LBB7_109>

8000b2e8 <.LBB7_42>:
8000b2e8:	3d400513          	li	a0,980
    return (g_usbd_core[busid].configuration != 0);
8000b2ec:	02aa0533          	mul	a0,s4,a0
8000b2f0:	000895b7          	lui	a1,0x89
8000b2f4:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b2f8:	952e                	add	a0,a0,a1
8000b2fa:	22854503          	lbu	a0,552(a0)
    if (!is_device_configured(busid)) {
8000b2fe:	44050263          	beqz	a0,8000b742 <.LBB7_108>
8000b302:	003dc503          	lbu	a0,3(s11)
8000b306:	002dc583          	lbu	a1,2(s11)
8000b30a:	00851613          	sll	a2,a0,0x8
8000b30e:	005dc683          	lbu	a3,5(s11)
8000b312:	004dc703          	lbu	a4,4(s11)
    switch (setup->bRequest) {
8000b316:	001dc503          	lbu	a0,1(s11)
8000b31a:	00b66bb3          	or	s7,a2,a1
8000b31e:	06a2                	sll	a3,a3,0x8
8000b320:	45a5                	li	a1,9
8000b322:	00e6ec33          	or	s8,a3,a4
8000b326:	16a5c563          	blt	a1,a0,8000b490 <.LBB7_63>
8000b32a:	c549                	beqz	a0,8000b3b4 <.LBB7_53>
8000b32c:	4599                	li	a1,6
8000b32e:	40b51a63          	bne	a0,a1,8000b742 <.LBB7_108>
            if (type == 0x22) { /* HID_DESCRIPTOR_TYPE_HID_REPORT */
8000b332:	008bd513          	srl	a0,s7,0x8
8000b336:	02200593          	li	a1,34
8000b33a:	40b51463          	bne	a0,a1,8000b742 <.LBB7_108>
                USB_LOG_INFO("read hid report descriptor\r\n");
8000b33e:	80010537          	lui	a0,0x80010
8000b342:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b346:	ff6fe0ef          	jal	80009b3c <printf>
8000b34a:	16a20513          	add	a0,tp,362 # 16a <default_isr_51+0x1a>
8000b34e:	5c9010ef          	jal	8000d116 <puts>
8000b352:	80011537          	lui	a0,0x80011
8000b356:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b35a:	fe2fe0ef          	jal	80009b3c <printf>
8000b35e:	3d400513          	li	a0,980
8000b362:	02aa05b3          	mul	a1,s4,a0
8000b366:	00089537          	lui	a0,0x89
8000b36a:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000b36e:	95aa                	add	a1,a1,a0
8000b370:	24c5c503          	lbu	a0,588(a1)
8000b374:	3c050763          	beqz	a0,8000b742 <.LBB7_108>
                for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b378:	22c58593          	add	a1,a1,556
8000b37c:	0ffc7613          	zext.b	a2,s8
8000b380:	a881                	j	8000b3d0 <.LBB7_55>

8000b382 <.LBB7_49>:
8000b382:	3d400513          	li	a0,980
    return (g_usbd_core[busid].configuration != 0);
8000b386:	02aa0533          	mul	a0,s4,a0
8000b38a:	000895b7          	lui	a1,0x89
8000b38e:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b392:	952e                	add	a0,a0,a1
8000b394:	22854503          	lbu	a0,552(a0)
    if (!is_device_configured(busid)) {
8000b398:	3a050563          	beqz	a0,8000b742 <.LBB7_108>
    switch (setup->bRequest) {
8000b39c:	001dc503          	lbu	a0,1(s11)
8000b3a0:	004dc403          	lbu	s0,4(s11)
8000b3a4:	458d                	li	a1,3
8000b3a6:	22b50a63          	beq	a0,a1,8000b5da <.LBB7_82>
8000b3aa:	4585                	li	a1,1
8000b3ac:	1eb50663          	beq	a0,a1,8000b598 <.LBB7_80>
8000b3b0:	38051963          	bnez	a0,8000b742 <.LBB7_108>

8000b3b4 <.LBB7_53>:
8000b3b4:	0009a503          	lw	a0,0(s3)
8000b3b8:	00050023          	sb	zero,0(a0)
8000b3bc:	0009a503          	lw	a0,0(s3)
8000b3c0:	000500a3          	sb	zero,1(a0)
8000b3c4:	4509                	li	a0,2
8000b3c6:	a1dd                	j	8000b8ac <.LBB7_122>

8000b3c8 <.LBB7_54>:
                for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b3c8:	157d                	add	a0,a0,-1
8000b3ca:	0591                	add	a1,a1,4
8000b3cc:	36050b63          	beqz	a0,8000b742 <.LBB7_108>

8000b3d0 <.LBB7_55>:
                    struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000b3d0:	4180                	lw	s0,0(a1)
8000b3d2:	d87d                	beqz	s0,8000b3c8 <.LBB7_54>
                    if (intf && (intf->intf_num == intf_num)) {
8000b3d4:	01844683          	lbu	a3,24(s0)
8000b3d8:	fec698e3          	bne	a3,a2,8000b3c8 <.LBB7_54>
                        memcpy(*data, intf->hid_report_descriptor, intf->hid_report_descriptor_len);
8000b3dc:	0009a503          	lw	a0,0(s3)
8000b3e0:	480c                	lw	a1,16(s0)
8000b3e2:	4850                	lw	a2,20(s0)
8000b3e4:	cbefe0ef          	jal	800098a2 <memcpy>
                        *len = intf->hid_report_descriptor_len;
8000b3e8:	4848                	lw	a0,20(s0)
8000b3ea:	a1c9                	j	8000b8ac <.LBB7_122>

8000b3ec <.LBB7_58>:
8000b3ec:	80010537          	lui	a0,0x80010
8000b3f0:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b3f4:	f48fe0ef          	jal	80009b3c <printf>
8000b3f8:	80011537          	lui	a0,0x80011
8000b3fc:	a6650513          	add	a0,a0,-1434 # 80010a66 <.Lstr.30>
8000b400:	517010ef          	jal	8000d116 <puts>
8000b404:	80011537          	lui	a0,0x80011
8000b408:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b40c:	f30fe0ef          	jal	80009b3c <printf>

8000b410 <.LBB7_59>:
                USB_LOG_ERR("vendor request error\r\n");
8000b410:	80010537          	lui	a0,0x80010
8000b414:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b418:	f24fe0ef          	jal	80009b3c <printf>
8000b41c:	80010537          	lui	a0,0x80010
8000b420:	24550513          	add	a0,a0,581 # 80010245 <.Lstr.22>
8000b424:	a63d                	j	8000b752 <.LBB7_109>

8000b426 <.LBB7_60>:
                    USB_LOG_INFO("get Compat id properties\r\n");
8000b426:	80010537          	lui	a0,0x80010
8000b42a:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b42e:	f0efe0ef          	jal	80009b3c <printf>
8000b432:	80010537          	lui	a0,0x80010
8000b436:	28350513          	add	a0,a0,643 # 80010283 <.Lstr.28>
8000b43a:	4dd010ef          	jal	8000d116 <puts>
8000b43e:	80011537          	lui	a0,0x80011
8000b442:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b446:	ef6fe0ef          	jal	80009b3c <printf>
                    desclen = g_usbd_core[busid].msosv1_desc->comp_id_property[setup->wValue][0] +
8000b44a:	4008                	lw	a0,0(s0)
8000b44c:	002dc583          	lbu	a1,2(s11)
8000b450:	003dc603          	lbu	a2,3(s11)
8000b454:	4548                	lw	a0,12(a0)
8000b456:	058a                	sll	a1,a1,0x2
8000b458:	062a                	sll	a2,a2,0xa
8000b45a:	8dd1                	or	a1,a1,a2
8000b45c:	952e                	add	a0,a0,a1
8000b45e:	410c                	lw	a1,0(a0)

8000b460 <.LBB7_61>:
8000b460:	0015c503          	lbu	a0,1(a1)
8000b464:	0005c603          	lbu	a2,0(a1)
8000b468:	0025c683          	lbu	a3,2(a1)
8000b46c:	0522                	sll	a0,a0,0x8
8000b46e:	0035c703          	lbu	a4,3(a1)
8000b472:	8e49                	or	a2,a2,a0
8000b474:	06c2                	sll	a3,a3,0x10
8000b476:	0009a503          	lw	a0,0(s3)
8000b47a:	0762                	sll	a4,a4,0x18
8000b47c:	8ed9                	or	a3,a3,a4
8000b47e:	00d66433          	or	s0,a2,a3
8000b482:	8622                	mv	a2,s0
8000b484:	c1efe0ef          	jal	800098a2 <memcpy>
8000b488:	00892023          	sw	s0,0(s2)

8000b48c <.LBB7_62>:
8000b48c:	4505                	li	a0,1
8000b48e:	a60d                	j	8000b7b0 <.LBB7_111>

8000b490 <.LBB7_63>:
8000b490:	45a9                	li	a1,10
    switch (setup->bRequest) {
8000b492:	1ab50b63          	beq	a0,a1,8000b648 <.LBB7_86>
8000b496:	45ad                	li	a1,11
8000b498:	2ab51563          	bne	a0,a1,8000b742 <.LBB7_108>
8000b49c:	3d400513          	li	a0,980
    p = (uint8_t *)g_usbd_core[busid].descriptors;
8000b4a0:	02aa0533          	mul	a0,s4,a0
8000b4a4:	000895b7          	lui	a1,0x89
8000b4a8:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b4ac:	952e                	add	a0,a0,a1
8000b4ae:	4d04                	lw	s1,24(a0)
8000b4b0:	4981                	li	s3,0
8000b4b2:	4d81                	li	s11,0
8000b4b4:	4b01                	li	s6,0
    while (p[DESC_bLength] != 0U) {
8000b4b6:	0004c583          	lbu	a1,0(s1)
8000b4ba:	0ff00413          	li	s0,255
8000b4be:	4c95                	li	s9,5
8000b4c0:	0ffc7d13          	zext.b	s10,s8
8000b4c4:	0ffbf513          	zext.b	a0,s7
8000b4c8:	cc2a                	sw	a0,24(sp)
8000b4ca:	80010537          	lui	a0,0x80010
8000b4ce:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b4d2:	ca2a                	sw	a0,20(sp)
8000b4d4:	80010537          	lui	a0,0x80010
8000b4d8:	21150513          	add	a0,a0,529 # 80010211 <.L.str.13>
8000b4dc:	c82a                	sw	a0,16(sp)
8000b4de:	80011537          	lui	a0,0x80011
8000b4e2:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b4e6:	c62a                	sw	a0,12(sp)
8000b4e8:	4a91                	li	s5,4
8000b4ea:	4689                	li	a3,2
8000b4ec:	0ff00513          	li	a0,255
8000b4f0:	a821                	j	8000b508 <.LBB7_68>

8000b4f2 <.LBB7_66>:
8000b4f2:	89ae                	mv	s3,a1

8000b4f4 <.LBB7_67>:
        p += p[DESC_bLength];
8000b4f4:	0004c583          	lbu	a1,0(s1)
8000b4f8:	94ae                	add	s1,s1,a1
        current_desc_len += p[DESC_bLength];
8000b4fa:	0004c583          	lbu	a1,0(s1)
8000b4fe:	9b2e                	add	s6,s6,a1
        if (current_desc_len >= desc_len && desc_len) {
8000b500:	fffd8613          	add	a2,s11,-1
8000b504:	13666c63          	bltu	a2,s6,8000b63c <.LBB7_85>

8000b508 <.LBB7_68>:
    while (p[DESC_bLength] != 0U) {
8000b508:	0ff5f593          	zext.b	a1,a1
8000b50c:	12058863          	beqz	a1,8000b63c <.LBB7_85>
        switch (p[DESC_bDescriptorType]) {
8000b510:	0014c583          	lbu	a1,1(s1)
8000b514:	03958e63          	beq	a1,s9,8000b550 <.LBB7_75>
8000b518:	01558d63          	beq	a1,s5,8000b532 <.LBB7_73>
8000b51c:	fcd59ce3          	bne	a1,a3,8000b4f4 <.LBB7_67>
                           (p[CONF_DESC_wTotalLength + 1] << 8);
8000b520:	0034c583          	lbu	a1,3(s1)
                desc_len = (p[CONF_DESC_wTotalLength]) |
8000b524:	0024c603          	lbu	a2,2(s1)
8000b528:	4b01                	li	s6,0
                           (p[CONF_DESC_wTotalLength + 1] << 8);
8000b52a:	05a2                	sll	a1,a1,0x8
                desc_len = (p[CONF_DESC_wTotalLength]) |
8000b52c:	00c5edb3          	or	s11,a1,a2
8000b530:	b7d1                	j	8000b4f4 <.LBB7_67>

8000b532 <.LBB7_73>:
                cur_iface = p[INTF_DESC_bInterfaceNumber];
8000b532:	0024c503          	lbu	a0,2(s1)
                cur_alt_setting = p[INTF_DESC_bAlternateSetting];
8000b536:	0034c403          	lbu	s0,3(s1)
                if (cur_iface == iface &&
8000b53a:	018545b3          	xor	a1,a0,s8
8000b53e:	01744633          	xor	a2,s0,s7
8000b542:	8dd1                	or	a1,a1,a2
8000b544:	0ff5f613          	zext.b	a2,a1
8000b548:	85a6                	mv	a1,s1
8000b54a:	d645                	beqz	a2,8000b4f2 <.LBB7_66>
8000b54c:	85ce                	mv	a1,s3
8000b54e:	b755                	j	8000b4f2 <.LBB7_66>

8000b550 <.LBB7_75>:
                if (cur_iface == iface) {
8000b550:	0ff57593          	zext.b	a1,a0
8000b554:	fba590e3          	bne	a1,s10,8000b4f4 <.LBB7_67>
                    if (cur_alt_setting != alt_setting) {
8000b558:	0ff47513          	zext.b	a0,s0
8000b55c:	45e2                	lw	a1,24(sp)
8000b55e:	00b51763          	bne	a0,a1,8000b56c <.LBB7_78>
                        ret = usbd_set_endpoint(busid, ep_desc);
8000b562:	8552                	mv	a0,s4
8000b564:	85a6                	mv	a1,s1
8000b566:	256d                	jal	8000bc10 <usbd_set_endpoint>
8000b568:	845e                	mv	s0,s7
8000b56a:	a025                	j	8000b592 <.LBB7_79>

8000b56c <.LBB7_78>:
8000b56c:	4552                	lw	a0,20(sp)
    USB_LOG_INFO("Close ep:0x%02x type:%u\r\n",
8000b56e:	dcefe0ef          	jal	80009b3c <printf>
8000b572:	0034c603          	lbu	a2,3(s1)
8000b576:	0024c583          	lbu	a1,2(s1)
8000b57a:	8a0d                	and	a2,a2,3
8000b57c:	4542                	lw	a0,16(sp)
8000b57e:	dbefe0ef          	jal	80009b3c <printf>
8000b582:	4532                	lw	a0,12(sp)
8000b584:	db8fe0ef          	jal	80009b3c <printf>
    return usbd_ep_close(busid, ep->bEndpointAddress) == 0 ? true : false;
8000b588:	0024c583          	lbu	a1,2(s1)
8000b58c:	8552                	mv	a0,s4
8000b58e:	08b000ef          	jal	8000be18 <usbd_ep_close>

8000b592 <.LBB7_79>:
8000b592:	8562                	mv	a0,s8
8000b594:	4689                	li	a3,2
8000b596:	bfb9                	j	8000b4f4 <.LBB7_67>

8000b598 <.LBB7_80>:
            if (setup->wValue == USB_FEATURE_ENDPOINT_HALT) {
8000b598:	003dc503          	lbu	a0,3(s11)
8000b59c:	002dc583          	lbu	a1,2(s11)
8000b5a0:	0522                	sll	a0,a0,0x8
8000b5a2:	8d4d                	or	a0,a0,a1
8000b5a4:	18051d63          	bnez	a0,8000b73e <.LBB7_107>
                USB_LOG_ERR("ep:%02x clear halt\r\n", ep);
8000b5a8:	80010537          	lui	a0,0x80010
8000b5ac:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b5b0:	d8cfe0ef          	jal	80009b3c <printf>
8000b5b4:	80011537          	lui	a0,0x80011
8000b5b8:	9df50513          	add	a0,a0,-1569 # 800109df <.L.str.14>
8000b5bc:	85a2                	mv	a1,s0
8000b5be:	d7efe0ef          	jal	80009b3c <printf>
8000b5c2:	80011537          	lui	a0,0x80011
8000b5c6:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b5ca:	d72fe0ef          	jal	80009b3c <printf>
                usbd_ep_clear_stall(busid, ep);
8000b5ce:	8552                	mv	a0,s4
8000b5d0:	85a2                	mv	a1,s0
8000b5d2:	0a3000ef          	jal	8000be74 <usbd_ep_clear_stall>
8000b5d6:	4505                	li	a0,1
8000b5d8:	aae1                	j	8000b7b0 <.LBB7_111>

8000b5da <.LBB7_82>:
            if (setup->wValue == USB_FEATURE_ENDPOINT_HALT) {
8000b5da:	003dc503          	lbu	a0,3(s11)
8000b5de:	002dc583          	lbu	a1,2(s11)
8000b5e2:	0522                	sll	a0,a0,0x8
8000b5e4:	8d4d                	or	a0,a0,a1
8000b5e6:	14051c63          	bnez	a0,8000b73e <.LBB7_107>
                USB_LOG_ERR("ep:%02x set halt\r\n", ep);
8000b5ea:	80010537          	lui	a0,0x80010
8000b5ee:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b5f2:	d4afe0ef          	jal	80009b3c <printf>
8000b5f6:	8000f537          	lui	a0,0x8000f
8000b5fa:	3e950513          	add	a0,a0,1001 # 8000f3e9 <.L.str.15>
8000b5fe:	85a2                	mv	a1,s0
8000b600:	d3cfe0ef          	jal	80009b3c <printf>
8000b604:	80011537          	lui	a0,0x80011
8000b608:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b60c:	d30fe0ef          	jal	80009b3c <printf>
                usbd_ep_set_stall(busid, ep);
8000b610:	8552                	mv	a0,s4
8000b612:	85a2                	mv	a1,s0
8000b614:	041000ef          	jal	8000be54 <usbd_ep_set_stall>
8000b618:	ac2d                	j	8000b852 <.LBB7_118>

8000b61a <.LBB7_84>:
8000b61a:	3d400513          	li	a0,980
            *data = (uint8_t *)&g_usbd_core[busid].configuration;
8000b61e:	02aa0533          	mul	a0,s4,a0
8000b622:	000895b7          	lui	a1,0x89
8000b626:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b62a:	952e                	add	a0,a0,a1
8000b62c:	22850513          	add	a0,a0,552
8000b630:	00a9a023          	sw	a0,0(s3)
8000b634:	4505                	li	a0,1
            *len = 1;
8000b636:	00a92023          	sw	a0,0(s2)
8000b63a:	aa9d                	j	8000b7b0 <.LBB7_111>

8000b63c <.LBB7_85>:
    usbd_class_event_notify_handler(busid, USBD_EVENT_SET_INTERFACE, (void *)if_desc);
8000b63c:	45a1                	li	a1,8
8000b63e:	8552                	mv	a0,s4
8000b640:	864e                	mv	a2,s3
8000b642:	3081                	jal	8000ae82 <usbd_class_event_notify_handler>
8000b644:	4501                	li	a0,0
8000b646:	a49d                	j	8000b8ac <.LBB7_122>

8000b648 <.LBB7_86>:
            (*data)[0] = 0;
8000b648:	0009a503          	lw	a0,0(s3)
8000b64c:	00050023          	sb	zero,0(a0)
8000b650:	4505                	li	a0,1
8000b652:	aca9                	j	8000b8ac <.LBB7_122>

8000b654 <.LBB7_87>:
8000b654:	3d400513          	li	a0,980
    p = (uint8_t *)g_usbd_core[busid].descriptors;
8000b658:	02aa0533          	mul	a0,s4,a0
8000b65c:	000895b7          	lui	a1,0x89
8000b660:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b664:	952e                	add	a0,a0,a1
8000b666:	4d00                	lw	s0,24(a0)
8000b668:	4501                	li	a0,0
8000b66a:	4d01                	li	s10,0
8000b66c:	4c81                	li	s9,0
    while (p[DESC_bLength] != 0U) {
8000b66e:	00044583          	lbu	a1,0(s0)
8000b672:	0ff00613          	li	a2,255
8000b676:	4995                	li	s3,5
8000b678:	0ffb7a93          	zext.b	s5,s6
8000b67c:	4b91                	li	s7,4
8000b67e:	4c09                	li	s8,2
8000b680:	0ff00693          	li	a3,255
8000b684:	a829                	j	8000b69e <.LBB7_90>

8000b686 <.LBB7_88>:
                    p[INTF_DESC_bAlternateSetting];
8000b686:	00344603          	lbu	a2,3(s0)

8000b68a <.LBB7_89>:
        p += p[DESC_bLength];
8000b68a:	0ff5f593          	zext.b	a1,a1
8000b68e:	942e                	add	s0,s0,a1
        current_desc_len += p[DESC_bLength];
8000b690:	00044583          	lbu	a1,0(s0)
8000b694:	9cae                	add	s9,s9,a1
        if (current_desc_len >= desc_len && desc_len) {
8000b696:	fffd0713          	add	a4,s10,-1
8000b69a:	05976a63          	bltu	a4,s9,8000b6ee <.LBB7_100>

8000b69e <.LBB7_90>:
    while (p[DESC_bLength] != 0U) {
8000b69e:	0ff5f713          	zext.b	a4,a1
8000b6a2:	c731                	beqz	a4,8000b6ee <.LBB7_100>
        switch (p[DESC_bDescriptorType]) {
8000b6a4:	00144703          	lbu	a4,1(s0)
8000b6a8:	03370463          	beq	a4,s3,8000b6d0 <.LBB7_96>
8000b6ac:	fd770de3          	beq	a4,s7,8000b686 <.LBB7_88>
8000b6b0:	fd871de3          	bne	a4,s8,8000b68a <.LBB7_89>
                cur_config = p[CONF_DESC_bConfigurationValue];
8000b6b4:	00544683          	lbu	a3,5(s0)
                if (cur_config == config_index) {
8000b6b8:	fd5699e3          	bne	a3,s5,8000b68a <.LBB7_89>
                               (p[CONF_DESC_wTotalLength + 1] << 8);
8000b6bc:	00344503          	lbu	a0,3(s0)
                    desc_len = (p[CONF_DESC_wTotalLength]) |
8000b6c0:	00244683          	lbu	a3,2(s0)
8000b6c4:	4c81                	li	s9,0
                               (p[CONF_DESC_wTotalLength + 1] << 8);
8000b6c6:	0522                	sll	a0,a0,0x8
                    desc_len = (p[CONF_DESC_wTotalLength]) |
8000b6c8:	00d56d33          	or	s10,a0,a3
8000b6cc:	4505                	li	a0,1
8000b6ce:	a831                	j	8000b6ea <.LBB7_99>

8000b6d0 <.LBB7_96>:
                if ((cur_config != config_index) ||
8000b6d0:	0ff6f713          	zext.b	a4,a3
8000b6d4:	fb571be3          	bne	a4,s5,8000b68a <.LBB7_89>
8000b6d8:	0ff67713          	zext.b	a4,a2
8000b6dc:	f75d                	bnez	a4,8000b68a <.LBB7_89>
                found = usbd_set_endpoint(busid, (struct usb_endpoint_descriptor *)p);
8000b6de:	8552                	mv	a0,s4
8000b6e0:	85a2                	mv	a1,s0
8000b6e2:	233d                	jal	8000bc10 <usbd_set_endpoint>
        p += p[DESC_bLength];
8000b6e4:	00044583          	lbu	a1,0(s0)
8000b6e8:	4601                	li	a2,0

8000b6ea <.LBB7_99>:
8000b6ea:	86da                	mv	a3,s6
8000b6ec:	bf79                	j	8000b68a <.LBB7_89>

8000b6ee <.LBB7_100>:
            if (!usbd_set_configuration(busid, value, 0)) {
8000b6ee:	8905                	and	a0,a0,1
8000b6f0:	c539                	beqz	a0,8000b73e <.LBB7_107>
8000b6f2:	3d400513          	li	a0,980
                g_usbd_core[busid].configuration = value;
8000b6f6:	02aa09b3          	mul	s3,s4,a0
8000b6fa:	00089537          	lui	a0,0x89
8000b6fe:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000b702:	99aa                	add	s3,s3,a0
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b704:	24c9c503          	lbu	a0,588(s3)
                g_usbd_core[busid].configuration = value;
8000b708:	23698423          	sb	s6,552(s3)
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b70c:	12050e63          	beqz	a0,8000b848 <.LBB7_117>
8000b710:	4481                	li	s1,0
8000b712:	24c98a93          	add	s5,s3,588
8000b716:	22c98413          	add	s0,s3,556
8000b71a:	a039                	j	8000b728 <.LBB7_104>

8000b71c <.LBB7_103>:
8000b71c:	0485                	add	s1,s1,1
8000b71e:	0ff57593          	zext.b	a1,a0
8000b722:	0411                	add	s0,s0,4
8000b724:	12b4f263          	bgeu	s1,a1,8000b848 <.LBB7_117>

8000b728 <.LBB7_104>:
        struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000b728:	400c                	lw	a1,0(s0)
            if (intf && intf->notify_handler) {
8000b72a:	d9ed                	beqz	a1,8000b71c <.LBB7_103>
8000b72c:	45d4                	lw	a3,12(a1)
8000b72e:	d6fd                	beqz	a3,8000b71c <.LBB7_103>
                intf->notify_handler(busid, event, arg);
8000b730:	459d                	li	a1,7
8000b732:	8552                	mv	a0,s4
8000b734:	4601                	li	a2,0
8000b736:	9682                	jalr	a3
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000b738:	000ac503          	lbu	a0,0(s5)
8000b73c:	b7c5                	j	8000b71c <.LBB7_103>

8000b73e <.LBB7_107>:
8000b73e:	00092023          	sw	zero,0(s2)

8000b742 <.LBB7_108>:
                USB_LOG_ERR("standard request error\r\n");
8000b742:	80010537          	lui	a0,0x80010
8000b746:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b74a:	bf2fe0ef          	jal	80009b3c <printf>
8000b74e:	15220513          	add	a0,tp,338 # 152 <default_isr_51+0x2>

8000b752 <.LBB7_109>:
8000b752:	1c5010ef          	jal	8000d116 <puts>
8000b756:	80011537          	lui	a0,0x80011
8000b75a:	9da50413          	add	s0,a0,-1574 # 800109da <.L.str.2>
8000b75e:	8522                	mv	a0,s0
8000b760:	bdcfe0ef          	jal	80009b3c <printf>
    USB_LOG_INFO("Setup: "
8000b764:	80010537          	lui	a0,0x80010
8000b768:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b76c:	bd0fe0ef          	jal	80009b3c <printf>
8000b770:	003dc503          	lbu	a0,3(s11)
8000b774:	002dc683          	lbu	a3,2(s11)
8000b778:	000dc583          	lbu	a1,0(s11)
8000b77c:	001dc603          	lbu	a2,1(s11)
8000b780:	0522                	sll	a0,a0,0x8
8000b782:	8ec9                	or	a3,a3,a0
8000b784:	005dc503          	lbu	a0,5(s11)
8000b788:	004dc703          	lbu	a4,4(s11)
8000b78c:	007dc783          	lbu	a5,7(s11)
8000b790:	006dc483          	lbu	s1,6(s11)
8000b794:	0522                	sll	a0,a0,0x8
8000b796:	8f49                	or	a4,a4,a0
8000b798:	07a2                	sll	a5,a5,0x8
8000b79a:	8fc5                	or	a5,a5,s1
8000b79c:	80011537          	lui	a0,0x80011
8000b7a0:	9f450513          	add	a0,a0,-1548 # 800109f4 <.L.str.16>
8000b7a4:	b98fe0ef          	jal	80009b3c <printf>
8000b7a8:	8522                	mv	a0,s0
8000b7aa:	b92fe0ef          	jal	80009b3c <printf>

8000b7ae <.LBB7_110>:
8000b7ae:	4501                	li	a0,0

8000b7b0 <.LBB7_111>:
8000b7b0:	40b6                	lw	ra,76(sp)
8000b7b2:	4426                	lw	s0,72(sp)
8000b7b4:	4496                	lw	s1,68(sp)
8000b7b6:	4906                	lw	s2,64(sp)
8000b7b8:	59f2                	lw	s3,60(sp)
8000b7ba:	5a62                	lw	s4,56(sp)
8000b7bc:	5ad2                	lw	s5,52(sp)
8000b7be:	5b42                	lw	s6,48(sp)
8000b7c0:	5bb2                	lw	s7,44(sp)
8000b7c2:	5c22                	lw	s8,40(sp)
8000b7c4:	5c92                	lw	s9,36(sp)
8000b7c6:	5d02                	lw	s10,32(sp)
8000b7c8:	4df2                	lw	s11,28(sp)
}
8000b7ca:	6161                	add	sp,sp,80
8000b7cc:	8082                	ret

8000b7ce <.LBB7_112>:
            usbd_set_address(busid, value);
8000b7ce:	0ffb7593          	zext.b	a1,s6
8000b7d2:	8552                	mv	a0,s4
8000b7d4:	f69fb0ef          	jal	8000773c <usbd_set_address>
8000b7d8:	a8ad                	j	8000b852 <.LBB7_118>

8000b7da <.LBB7_113>:
8000b7da:	008b5413          	srl	s0,s6,0x8
8000b7de:	450d                	li	a0,3
8000b7e0:	0ffb7a93          	zext.b	s5,s6
    if ((type == USB_DESCRIPTOR_TYPE_STRING) && (index == USB_OSDESC_STRING_DESC_INDEX)) {
8000b7e4:	06a41b63          	bne	s0,a0,8000b85a <.LBB7_119>
8000b7e8:	0ee00513          	li	a0,238
8000b7ec:	06aa9763          	bne	s5,a0,8000b85a <.LBB7_119>
        USB_LOG_INFO("read MS OS 2.0 descriptor string\r\n");
8000b7f0:	80010537          	lui	a0,0x80010
8000b7f4:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b7f8:	b44fe0ef          	jal	80009b3c <printf>
8000b7fc:	80010537          	lui	a0,0x80010
8000b800:	29d50513          	add	a0,a0,669 # 8001029d <.Lstr.33>
8000b804:	113010ef          	jal	8000d116 <puts>
8000b808:	80011537          	lui	a0,0x80011
8000b80c:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b810:	b2cfe0ef          	jal	80009b3c <printf>
8000b814:	3d400513          	li	a0,980
        if (!g_usbd_core[busid].msosv1_desc) {
8000b818:	02aa06b3          	mul	a3,s4,a0
8000b81c:	00089537          	lui	a0,0x89
8000b820:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000b824:	96aa                	add	a3,a3,a0
8000b826:	4ec8                	lw	a0,28(a3)
8000b828:	f0050de3          	beqz	a0,8000b742 <.LBB7_108>
        memcpy(*data, (uint8_t *)g_usbd_core[busid].msosv1_desc->string, g_usbd_core[busid].msosv1_desc->string[0]);
8000b82c:	410c                	lw	a1,0(a0)
8000b82e:	0009a503          	lw	a0,0(s3)
8000b832:	0005c603          	lbu	a2,0(a1)
8000b836:	01c68413          	add	s0,a3,28
8000b83a:	868fe0ef          	jal	800098a2 <memcpy>
        *len = g_usbd_core[busid].msosv1_desc->string[0];
8000b83e:	4008                	lw	a0,0(s0)
8000b840:	4108                	lw	a0,0(a0)
8000b842:	00054503          	lbu	a0,0(a0)
8000b846:	a09d                	j	8000b8ac <.LBB7_122>

8000b848 <.LBB7_117>:
                g_usbd_core[busid].event_handler(busid, USBD_EVENT_CONFIGURED);
8000b848:	3d09a603          	lw	a2,976(s3)
8000b84c:	459d                	li	a1,7
8000b84e:	8552                	mv	a0,s4
8000b850:	9602                	jalr	a2

8000b852 <.LBB7_118>:
8000b852:	00092023          	sw	zero,0(s2)
8000b856:	4505                	li	a0,1
8000b858:	bfa1                	j	8000b7b0 <.LBB7_111>

8000b85a <.LBB7_119>:
8000b85a:	453d                	li	a0,15
    } else if (type == USB_DESCRIPTOR_TYPE_BINARY_OBJECT_STORE) {
8000b85c:	04a41c63          	bne	s0,a0,8000b8b4 <.LBB7_123>
        USB_LOG_INFO("read BOS descriptor string\r\n");
8000b860:	80010537          	lui	a0,0x80010
8000b864:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000b868:	ad4fe0ef          	jal	80009b3c <printf>
8000b86c:	18620513          	add	a0,tp,390 # 186 <default_isr_51+0x36>
8000b870:	0a7010ef          	jal	8000d116 <puts>
8000b874:	80011537          	lui	a0,0x80011
8000b878:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b87c:	ac0fe0ef          	jal	80009b3c <printf>
8000b880:	3d400513          	li	a0,980
        if (!g_usbd_core[busid].bos_desc) {
8000b884:	02aa06b3          	mul	a3,s4,a0
8000b888:	00089537          	lui	a0,0x89
8000b88c:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000b890:	96aa                	add	a3,a3,a0
8000b892:	52d0                	lw	a2,36(a3)
8000b894:	ea0607e3          	beqz	a2,8000b742 <.LBB7_108>
        memcpy(*data, (uint8_t *)g_usbd_core[busid].bos_desc->string, g_usbd_core[busid].bos_desc->string_len);
8000b898:	0009a503          	lw	a0,0(s3)
8000b89c:	420c                	lw	a1,0(a2)
8000b89e:	4250                	lw	a2,4(a2)
8000b8a0:	02468413          	add	s0,a3,36
8000b8a4:	ffffd0ef          	jal	800098a2 <memcpy>
        *len = g_usbd_core[busid].bos_desc->string_len;
8000b8a8:	4008                	lw	a0,0(s0)
8000b8aa:	4148                	lw	a0,4(a0)

8000b8ac <.LBB7_122>:
8000b8ac:	00a92023          	sw	a0,0(s2)
8000b8b0:	4505                	li	a0,1
8000b8b2:	bdfd                	j	8000b7b0 <.LBB7_111>

8000b8b4 <.LBB7_123>:
8000b8b4:	7ff00513          	li	a0,2047
    else if ((type == USB_DESCRIPTOR_TYPE_INTERFACE) || (type == USB_DESCRIPTOR_TYPE_ENDPOINT) ||
8000b8b8:	e96565e3          	bltu	a0,s6,8000b742 <.LBB7_108>
8000b8bc:	e00b7513          	and	a0,s6,-512
8000b8c0:	40000593          	li	a1,1024
8000b8c4:	e6b50fe3          	beq	a0,a1,8000b742 <.LBB7_108>
8000b8c8:	3d400513          	li	a0,980
    p = (uint8_t *)g_usbd_core[busid].descriptors;
8000b8cc:	02aa0533          	mul	a0,s4,a0
8000b8d0:	000895b7          	lui	a1,0x89
8000b8d4:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b8d8:	952e                	add	a0,a0,a1
8000b8da:	4d0c                	lw	a1,24(a0)
    while (p[DESC_bLength] != 0U) {
8000b8dc:	0005c503          	lbu	a0,0(a1)
8000b8e0:	c10d                	beqz	a0,8000b902 <.LBB7_131>
8000b8e2:	4601                	li	a2,0
8000b8e4:	a039                	j	8000b8f2 <.LBB7_128>

8000b8e6 <.LBB7_127>:
        p += p[DESC_bLength];
8000b8e6:	0ff57513          	zext.b	a0,a0
8000b8ea:	95aa                	add	a1,a1,a0
    while (p[DESC_bLength] != 0U) {
8000b8ec:	0005c503          	lbu	a0,0(a1)
8000b8f0:	c909                	beqz	a0,8000b902 <.LBB7_131>

8000b8f2 <.LBB7_128>:
        if (p[DESC_bDescriptorType] == type) {
8000b8f2:	0015c683          	lbu	a3,1(a1)
8000b8f6:	fed418e3          	bne	s0,a3,8000b8e6 <.LBB7_127>
            if (cur_index == index) {
8000b8fa:	03560963          	beq	a2,s5,8000b92c <.LBB7_132>
            cur_index++;
8000b8fe:	0605                	add	a2,a2,1
8000b900:	b7dd                	j	8000b8e6 <.LBB7_127>

8000b902 <.LBB7_131>:
        USB_LOG_ERR("descriptor <type:0x%02x,index:0x%02x> not found!\r\n", type, index);
8000b902:	80010537          	lui	a0,0x80010
8000b906:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000b90a:	a32fe0ef          	jal	80009b3c <printf>
8000b90e:	8000f537          	lui	a0,0x8000f
8000b912:	3b650513          	add	a0,a0,950 # 8000f3b6 <.L.str.10>
8000b916:	85a2                	mv	a1,s0
8000b918:	8656                	mv	a2,s5
8000b91a:	a22fe0ef          	jal	80009b3c <printf>
8000b91e:	80011537          	lui	a0,0x80011
8000b922:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000b926:	a16fe0ef          	jal	80009b3c <printf>
8000b92a:	bd21                	j	8000b742 <.LBB7_108>

8000b92c <.LBB7_132>:
8000b92c:	461d                	li	a2,7
        if ((type == USB_DESCRIPTOR_TYPE_CONFIGURATION) || ((type == USB_DESCRIPTOR_TYPE_OTHER_SPEED))) {
8000b92e:	00c40563          	beq	s0,a2,8000b938 <.LBB7_134>
8000b932:	4609                	li	a2,2
8000b934:	00c41963          	bne	s0,a2,8000b946 <.LBB7_135>

8000b938 <.LBB7_134>:
                   (p[CONF_DESC_wTotalLength + 1] << 8);
8000b938:	0035c503          	lbu	a0,3(a1)
            *len = (p[CONF_DESC_wTotalLength]) |
8000b93c:	0025c603          	lbu	a2,2(a1)
                   (p[CONF_DESC_wTotalLength + 1] << 8);
8000b940:	0522                	sll	a0,a0,0x8
            *len = (p[CONF_DESC_wTotalLength]) |
8000b942:	8e49                	or	a2,a2,a0
8000b944:	a019                	j	8000b94a <.LBB7_136>

8000b946 <.LBB7_135>:
            *len = p[DESC_bLength];
8000b946:	0ff57613          	zext.b	a2,a0

8000b94a <.LBB7_136>:
        memcpy(*data, p, *len);
8000b94a:	0009a503          	lw	a0,0(s3)
8000b94e:	00c92023          	sw	a2,0(s2)
8000b952:	f51fd0ef          	jal	800098a2 <memcpy>
8000b956:	4505                	li	a0,1
8000b958:	bda1                	j	8000b7b0 <.LBB7_111>

Disassembly of section .text.usbd_event_ep0_in_complete_handler:

8000b95a <usbd_event_ep0_in_complete_handler>:
{
8000b95a:	3d400593          	li	a1,980
    struct usb_setup_packet *setup = &g_usbd_core[busid].setup;
8000b95e:	02b50733          	mul	a4,a0,a1
8000b962:	000895b7          	lui	a1,0x89
8000b966:	39858593          	add	a1,a1,920 # 89398 <g_usbd_core>
8000b96a:	972e                	add	a4,a4,a1
    g_usbd_core[busid].ep0_data_buf += nbytes;
8000b96c:	4714                	lw	a3,8(a4)
    g_usbd_core[busid].ep0_data_buf_residue -= nbytes;
8000b96e:	475c                	lw	a5,12(a4)
8000b970:	85b2                	mv	a1,a2
    g_usbd_core[busid].ep0_data_buf += nbytes;
8000b972:	9636                	add	a2,a2,a3
8000b974:	c710                	sw	a2,8(a4)
    g_usbd_core[busid].ep0_data_buf_residue -= nbytes;
8000b976:	40b786b3          	sub	a3,a5,a1
8000b97a:	c754                	sw	a3,12(a4)
    if (g_usbd_core[busid].ep0_data_buf_residue != 0) {
8000b97c:	00b79d63          	bne	a5,a1,8000b996 <.LBB8_3>
        if (g_usbd_core[busid].zlp_flag == true) {
8000b980:	01474583          	lbu	a1,20(a4)
8000b984:	cd81                	beqz	a1,8000b99c <.LBB8_4>
8000b986:	0751                	add	a4,a4,20
            usbd_ep_start_write(busid, USB_CONTROL_IN_EP0, NULL, 0);
8000b988:	08000593          	li	a1,128
            g_usbd_core[busid].zlp_flag = false;
8000b98c:	00070023          	sb	zero,0(a4)
            usbd_ep_start_write(busid, USB_CONTROL_IN_EP0, NULL, 0);
8000b990:	4601                	li	a2,0
8000b992:	4681                	li	a3,0
8000b994:	a301                	j	8000be94 <usbd_ep_start_write>

8000b996 <.LBB8_3>:
        usbd_ep_start_write(busid, USB_CONTROL_IN_EP0, g_usbd_core[busid].ep0_data_buf, g_usbd_core[busid].ep0_data_buf_residue);
8000b996:	08000593          	li	a1,128
8000b99a:	a9ed                	j	8000be94 <usbd_ep_start_write>

8000b99c <.LBB8_4>:
            if (setup->wLength && ((setup->bmRequestType & USB_REQUEST_DIR_MASK) == USB_REQUEST_DIR_IN)) {
8000b99c:	00675583          	lhu	a1,6(a4)
8000b9a0:	c589                	beqz	a1,8000b9aa <.LBB8_6>
8000b9a2:	00070583          	lb	a1,0(a4)
8000b9a6:	0005c363          	bltz	a1,8000b9ac <.LBB8_7>

8000b9aa <.LBB8_6>:
}
8000b9aa:	8082                	ret

8000b9ac <.LBB8_7>:
                usbd_ep_start_read(busid, USB_CONTROL_OUT_EP0, NULL, 0);
8000b9ac:	4581                	li	a1,0
8000b9ae:	4601                	li	a2,0
8000b9b0:	4681                	li	a3,0
8000b9b2:	ab3d                	j	8000bef0 <usbd_ep_start_read>

Disassembly of section .text.usbd_event_ep0_out_complete_handler:

8000b9b4 <usbd_event_ep0_out_complete_handler>:
{
8000b9b4:	1141                	add	sp,sp,-16
8000b9b6:	c606                	sw	ra,12(sp)
8000b9b8:	c422                	sw	s0,8(sp)
    if (nbytes > 0) {
8000b9ba:	ce39                	beqz	a2,8000ba18 <.LBB9_4>
8000b9bc:	3d400593          	li	a1,980
8000b9c0:	02b505b3          	mul	a1,a0,a1
8000b9c4:	000896b7          	lui	a3,0x89
8000b9c8:	39868693          	add	a3,a3,920 # 89398 <g_usbd_core>
8000b9cc:	95b6                	add	a1,a1,a3
        g_usbd_core[busid].ep0_data_buf += nbytes;
8000b9ce:	4598                	lw	a4,8(a1)
        g_usbd_core[busid].ep0_data_buf_residue -= nbytes;
8000b9d0:	45dc                	lw	a5,12(a1)
        g_usbd_core[busid].ep0_data_buf += nbytes;
8000b9d2:	9732                	add	a4,a4,a2
8000b9d4:	c598                	sw	a4,8(a1)
        g_usbd_core[busid].ep0_data_buf_residue -= nbytes;
8000b9d6:	40c786b3          	sub	a3,a5,a2
8000b9da:	c5d4                	sw	a3,12(a1)
        if (g_usbd_core[busid].ep0_data_buf_residue == 0) {
8000b9dc:	04c79263          	bne	a5,a2,8000ba20 <.LBB9_5>
8000b9e0:	00858613          	add	a2,a1,8
8000b9e4:	3d400693          	li	a3,980
            g_usbd_core[busid].ep0_data_buf = g_usbd_core[busid].req_data;
8000b9e8:	02d506b3          	mul	a3,a0,a3
8000b9ec:	00089737          	lui	a4,0x89
8000b9f0:	39870713          	add	a4,a4,920 # 89398 <g_usbd_core>
8000b9f4:	96ba                	add	a3,a3,a4
8000b9f6:	02868713          	add	a4,a3,40
8000b9fa:	c218                	sw	a4,0(a2)
            if (!usbd_setup_request_handler(busid, setup, &g_usbd_core[busid].ep0_data_buf, &g_usbd_core[busid].ep0_data_buf_len)) {
8000b9fc:	06c1                	add	a3,a3,16
8000b9fe:	842a                	mv	s0,a0
8000ba00:	e74ff0ef          	jal	8000b074 <usbd_setup_request_handler>
                usbd_ep_set_stall(busid, USB_CONTROL_IN_EP0);
8000ba04:	08000593          	li	a1,128
            if (!usbd_setup_request_handler(busid, setup, &g_usbd_core[busid].ep0_data_buf, &g_usbd_core[busid].ep0_data_buf_len)) {
8000ba08:	c115                	beqz	a0,8000ba2c <.LBB9_6>
            usbd_ep_start_write(busid, USB_CONTROL_IN_EP0, NULL, 0);
8000ba0a:	8522                	mv	a0,s0
8000ba0c:	4601                	li	a2,0
8000ba0e:	4681                	li	a3,0
8000ba10:	40b2                	lw	ra,12(sp)
8000ba12:	4422                	lw	s0,8(sp)
8000ba14:	0141                	add	sp,sp,16
8000ba16:	a9bd                	j	8000be94 <usbd_ep_start_write>

8000ba18 <.LBB9_4>:
8000ba18:	40b2                	lw	ra,12(sp)
8000ba1a:	4422                	lw	s0,8(sp)
}
8000ba1c:	0141                	add	sp,sp,16
8000ba1e:	8082                	ret

8000ba20 <.LBB9_5>:
            usbd_ep_start_read(busid, USB_CONTROL_OUT_EP0, g_usbd_core[busid].ep0_data_buf, g_usbd_core[busid].ep0_data_buf_residue);
8000ba20:	4581                	li	a1,0
8000ba22:	863a                	mv	a2,a4
8000ba24:	40b2                	lw	ra,12(sp)
8000ba26:	4422                	lw	s0,8(sp)
8000ba28:	0141                	add	sp,sp,16
8000ba2a:	a1d9                	j	8000bef0 <usbd_ep_start_read>

8000ba2c <.LBB9_6>:
                usbd_ep_set_stall(busid, USB_CONTROL_IN_EP0);
8000ba2c:	8522                	mv	a0,s0
8000ba2e:	40b2                	lw	ra,12(sp)
8000ba30:	4422                	lw	s0,8(sp)
8000ba32:	0141                	add	sp,sp,16
8000ba34:	a105                	j	8000be54 <usbd_ep_set_stall>

Disassembly of section .text.usbd_event_ep_in_complete_handler:

8000ba36 <usbd_event_ep_in_complete_handler>:
    if (g_usbd_core[busid].tx_msg[ep & 0x7f].cb) {
8000ba36:	07f5f693          	and	a3,a1,127
8000ba3a:	4731                	li	a4,12
8000ba3c:	02e686b3          	mul	a3,a3,a4
8000ba40:	3d400713          	li	a4,980
8000ba44:	02e50733          	mul	a4,a0,a4
8000ba48:	000897b7          	lui	a5,0x89
8000ba4c:	39878793          	add	a5,a5,920 # 89398 <g_usbd_core>
8000ba50:	973e                	add	a4,a4,a5
8000ba52:	96ba                	add	a3,a3,a4
8000ba54:	2586a783          	lw	a5,600(a3)
8000ba58:	c391                	beqz	a5,8000ba5c <.LBB10_2>
        g_usbd_core[busid].tx_msg[ep & 0x7f].cb(busid, ep, nbytes);
8000ba5a:	8782                	jr	a5

8000ba5c <.LBB10_2>:
}
8000ba5c:	8082                	ret

Disassembly of section .text.usbd_event_ep_out_complete_handler:

8000ba5e <usbd_event_ep_out_complete_handler>:
    if (g_usbd_core[busid].rx_msg[ep & 0x7f].cb) {
8000ba5e:	07f5f693          	and	a3,a1,127
8000ba62:	4731                	li	a4,12
8000ba64:	02e686b3          	mul	a3,a3,a4
8000ba68:	3d400713          	li	a4,980
8000ba6c:	02e50733          	mul	a4,a0,a4
8000ba70:	000897b7          	lui	a5,0x89
8000ba74:	39878793          	add	a5,a5,920 # 89398 <g_usbd_core>
8000ba78:	973e                	add	a4,a4,a5
8000ba7a:	96ba                	add	a3,a3,a4
8000ba7c:	3186a783          	lw	a5,792(a3)
8000ba80:	c391                	beqz	a5,8000ba84 <.LBB11_2>
        g_usbd_core[busid].rx_msg[ep & 0x7f].cb(busid, ep, nbytes);
8000ba82:	8782                	jr	a5

8000ba84 <.LBB11_2>:
}
8000ba84:	8082                	ret

Disassembly of section .text.usbd_desc_register:

8000ba86 <usbd_desc_register>:
{
8000ba86:	1141                	add	sp,sp,-16
8000ba88:	c606                	sw	ra,12(sp)
8000ba8a:	c422                	sw	s0,8(sp)
8000ba8c:	c226                	sw	s1,4(sp)
8000ba8e:	842e                	mv	s0,a1
8000ba90:	3d400593          	li	a1,980
    memset(&g_usbd_core[busid], 0, sizeof(struct usbd_core_priv));
8000ba94:	02b504b3          	mul	s1,a0,a1
8000ba98:	00089537          	lui	a0,0x89
8000ba9c:	39850513          	add	a0,a0,920 # 89398 <g_usbd_core>
8000baa0:	94aa                	add	s1,s1,a0
8000baa2:	3d400613          	li	a2,980
8000baa6:	8526                	mv	a0,s1
8000baa8:	4581                	li	a1,0
8000baaa:	06e020ef          	jal	8000db18 <memset>
    g_usbd_core[busid].descriptors = desc;
8000baae:	cc80                	sw	s0,24(s1)
    g_usbd_core[busid].intf_offset = 0;
8000bab0:	24048623          	sb	zero,588(s1)
8000bab4:	08000513          	li	a0,128
    g_usbd_core[busid].tx_msg[0].ep = 0x80;
8000bab8:	24a48823          	sb	a0,592(s1)
    g_usbd_core[busid].tx_msg[0].cb = usbd_event_ep0_in_complete_handler;
8000babc:	8000c537          	lui	a0,0x8000c
8000bac0:	95a50513          	add	a0,a0,-1702 # 8000b95a <usbd_event_ep0_in_complete_handler>
8000bac4:	24a4ac23          	sw	a0,600(s1)
    g_usbd_core[busid].rx_msg[0].ep = 0x00;
8000bac8:	30048823          	sb	zero,784(s1)
    g_usbd_core[busid].rx_msg[0].cb = usbd_event_ep0_out_complete_handler;
8000bacc:	8000c537          	lui	a0,0x8000c
8000bad0:	9b450513          	add	a0,a0,-1612 # 8000b9b4 <usbd_event_ep0_out_complete_handler>
8000bad4:	30a4ac23          	sw	a0,792(s1)
8000bad8:	40b2                	lw	ra,12(sp)
8000bada:	4422                	lw	s0,8(sp)
8000badc:	4492                	lw	s1,4(sp)
}
8000bade:	0141                	add	sp,sp,16
8000bae0:	8082                	ret

Disassembly of section .text.usbd_add_interface:

8000bae2 <usbd_add_interface>:
#endif

void usbd_add_interface(uint8_t busid, struct usbd_interface *intf)
{
8000bae2:	3d400613          	li	a2,980
    intf->intf_num = g_usbd_core[busid].intf_offset;
8000bae6:	02c50533          	mul	a0,a0,a2
8000baea:	00089637          	lui	a2,0x89
8000baee:	39860613          	add	a2,a2,920 # 89398 <g_usbd_core>
8000baf2:	9532                	add	a0,a0,a2
8000baf4:	24c54603          	lbu	a2,588(a0)
8000baf8:	00c58c23          	sb	a2,24(a1)
    g_usbd_core[busid].intf[g_usbd_core[busid].intf_offset] = intf;
8000bafc:	00261693          	sll	a3,a2,0x2
8000bb00:	96aa                	add	a3,a3,a0
8000bb02:	22b6a623          	sw	a1,556(a3)
    g_usbd_core[busid].intf_offset++;
8000bb06:	0605                	add	a2,a2,1
8000bb08:	24c50623          	sb	a2,588(a0)
}
8000bb0c:	8082                	ret

Disassembly of section .text.usbd_add_endpoint:

8000bb0e <usbd_add_endpoint>:

void usbd_add_endpoint(uint8_t busid, struct usbd_endpoint *ep)
{
    if (ep->ep_addr & 0x80) {
8000bb0e:	0005c683          	lbu	a3,0(a1)
8000bb12:	01869713          	sll	a4,a3,0x18
8000bb16:	41875613          	sra	a2,a4,0x18
8000bb1a:	02074563          	bltz	a4,8000bb44 <.LBB17_2>
8000bb1e:	4731                	li	a4,12
        g_usbd_core[busid].tx_msg[ep->ep_addr & 0x7f].ep = ep->ep_addr;
        g_usbd_core[busid].tx_msg[ep->ep_addr & 0x7f].cb = ep->ep_cb;
    } else {
        g_usbd_core[busid].rx_msg[ep->ep_addr & 0x7f].ep = ep->ep_addr;
8000bb20:	02e686b3          	mul	a3,a3,a4
8000bb24:	3d400713          	li	a4,980
8000bb28:	02e50533          	mul	a0,a0,a4
8000bb2c:	00089737          	lui	a4,0x89
8000bb30:	39870713          	add	a4,a4,920 # 89398 <g_usbd_core>
        g_usbd_core[busid].rx_msg[ep->ep_addr & 0x7f].cb = ep->ep_cb;
8000bb34:	41cc                	lw	a1,4(a1)
        g_usbd_core[busid].rx_msg[ep->ep_addr & 0x7f].ep = ep->ep_addr;
8000bb36:	953a                	add	a0,a0,a4
8000bb38:	9536                	add	a0,a0,a3
8000bb3a:	30c50823          	sb	a2,784(a0)
        g_usbd_core[busid].rx_msg[ep->ep_addr & 0x7f].cb = ep->ep_cb;
8000bb3e:	30b52c23          	sw	a1,792(a0)
    }
}
8000bb42:	8082                	ret

8000bb44 <.LBB17_2>:
        g_usbd_core[busid].tx_msg[ep->ep_addr & 0x7f].ep = ep->ep_addr;
8000bb44:	07f6f693          	and	a3,a3,127
8000bb48:	4731                	li	a4,12
8000bb4a:	02e686b3          	mul	a3,a3,a4
8000bb4e:	3d400793          	li	a5,980
8000bb52:	02f50533          	mul	a0,a0,a5
8000bb56:	000897b7          	lui	a5,0x89
8000bb5a:	39878793          	add	a5,a5,920 # 89398 <g_usbd_core>
8000bb5e:	953e                	add	a0,a0,a5
8000bb60:	25050513          	add	a0,a0,592
8000bb64:	96aa                	add	a3,a3,a0
8000bb66:	00c68023          	sb	a2,0(a3)
        g_usbd_core[busid].tx_msg[ep->ep_addr & 0x7f].cb = ep->ep_cb;
8000bb6a:	41cc                	lw	a1,4(a1)
8000bb6c:	07f67613          	and	a2,a2,127
8000bb70:	02e60633          	mul	a2,a2,a4
8000bb74:	9532                	add	a0,a0,a2
8000bb76:	c50c                	sw	a1,8(a0)
}
8000bb78:	8082                	ret

Disassembly of section .text.usbd_initialize:

8000bb7a <usbd_initialize>:
{
    return g_usbd_core[busid].configuration;
}

int usbd_initialize(uint8_t busid, uint32_t reg_base, void (*event_handler)(uint8_t busid, uint8_t event))
{
8000bb7a:	1101                	add	sp,sp,-32
8000bb7c:	ce06                	sw	ra,28(sp)
8000bb7e:	cc22                	sw	s0,24(sp)
8000bb80:	ca26                	sw	s1,20(sp)
8000bb82:	c84a                	sw	s2,16(sp)
8000bb84:	c64e                	sw	s3,12(sp)
    int ret;
    struct usbd_bus *bus;

    if (busid >= CONFIG_USBDEV_MAX_BUS) {
8000bb86:	c505                	beqz	a0,8000bbae <.LBB19_3>
        USB_LOG_ERR("bus overflow\r\n");
8000bb88:	80010537          	lui	a0,0x80010
8000bb8c:	1f550513          	add	a0,a0,501 # 800101f5 <.L.str>
8000bb90:	fadfd0ef          	jal	80009b3c <printf>
8000bb94:	80010537          	lui	a0,0x80010
8000bb98:	25b50513          	add	a0,a0,603 # 8001025b <.Lstr.25>
8000bb9c:	57a010ef          	jal	8000d116 <puts>
8000bba0:	80011537          	lui	a0,0x80011
8000bba4:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000bba8:	f95fd0ef          	jal	80009b3c <printf>

8000bbac <.LBB19_2>:
        while (1) {
8000bbac:	a001                	j	8000bbac <.LBB19_2>

8000bbae <.LBB19_3>:
        }
    }

    bus = &g_usbdev_bus[busid];
    bus->reg_base = reg_base;
8000bbae:	5f818513          	add	a0,gp,1528 # 81968 <g_usbdev_bus>
8000bbb2:	c14c                	sw	a1,4(a0)

    g_usbd_core[busid].event_handler = event_handler;
8000bbb4:	00089537          	lui	a0,0x89
8000bbb8:	39850993          	add	s3,a0,920 # 89398 <g_usbd_core>
8000bbbc:	3cc9a823          	sw	a2,976(s3)
    ret = usb_dc_init(busid);
8000bbc0:	4501                	li	a0,0
8000bbc2:	28ed                	jal	8000bcbc <usb_dc_init>
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000bbc4:	24c9c583          	lbu	a1,588(s3)
    ret = usb_dc_init(busid);
8000bbc8:	892a                	mv	s2,a0
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000bbca:	c595                	beqz	a1,8000bbf6 <.LBB19_9>
8000bbcc:	4401                	li	s0,0
8000bbce:	22c98493          	add	s1,s3,556
8000bbd2:	a039                	j	8000bbe0 <.LBB19_6>

8000bbd4 <.LBB19_5>:
8000bbd4:	0405                	add	s0,s0,1
8000bbd6:	0ff5f513          	zext.b	a0,a1
8000bbda:	0491                	add	s1,s1,4
8000bbdc:	00a47d63          	bgeu	s0,a0,8000bbf6 <.LBB19_9>

8000bbe0 <.LBB19_6>:
        struct usbd_interface *intf = g_usbd_core[busid].intf[i];
8000bbe0:	4088                	lw	a0,0(s1)
            if (intf && intf->notify_handler) {
8000bbe2:	d96d                	beqz	a0,8000bbd4 <.LBB19_5>
8000bbe4:	4554                	lw	a3,12(a0)
8000bbe6:	d6fd                	beqz	a3,8000bbd4 <.LBB19_5>
                intf->notify_handler(busid, event, arg);
8000bbe8:	45ad                	li	a1,11
8000bbea:	4501                	li	a0,0
8000bbec:	4601                	li	a2,0
8000bbee:	9682                	jalr	a3
    for (uint8_t i = 0; i < g_usbd_core[busid].intf_offset; i++) {
8000bbf0:	24c9c583          	lbu	a1,588(s3)
8000bbf4:	b7c5                	j	8000bbd4 <.LBB19_5>

8000bbf6 <.LBB19_9>:
    usbd_class_event_notify_handler(busid, USBD_EVENT_INIT, NULL);
    g_usbd_core[busid].event_handler(busid, USBD_EVENT_INIT);
8000bbf6:	3d09a603          	lw	a2,976(s3)
8000bbfa:	45ad                	li	a1,11
8000bbfc:	4501                	li	a0,0
8000bbfe:	9602                	jalr	a2
    return ret;
8000bc00:	854a                	mv	a0,s2
8000bc02:	40f2                	lw	ra,28(sp)
8000bc04:	4462                	lw	s0,24(sp)
8000bc06:	44d2                	lw	s1,20(sp)
8000bc08:	4942                	lw	s2,16(sp)
8000bc0a:	49b2                	lw	s3,12(sp)
8000bc0c:	6105                	add	sp,sp,32
8000bc0e:	8082                	ret

Disassembly of section .text.usbd_set_endpoint:

8000bc10 <usbd_set_endpoint>:
{
8000bc10:	1141                	add	sp,sp,-16
8000bc12:	c606                	sw	ra,12(sp)
8000bc14:	c422                	sw	s0,8(sp)
8000bc16:	c226                	sw	s1,4(sp)
8000bc18:	842e                	mv	s0,a1
8000bc1a:	84aa                	mv	s1,a0
    USB_LOG_INFO("Open ep:0x%02x type:%u mps:%u\r\n",
8000bc1c:	80010537          	lui	a0,0x80010
8000bc20:	20350513          	add	a0,a0,515 # 80010203 <.L.str.7>
8000bc24:	f19fd0ef          	jal	80009b3c <printf>
8000bc28:	00344603          	lbu	a2,3(s0)
8000bc2c:	00544503          	lbu	a0,5(s0)
8000bc30:	00444683          	lbu	a3,4(s0)
8000bc34:	00244583          	lbu	a1,2(s0)
8000bc38:	8a0d                	and	a2,a2,3
8000bc3a:	0522                	sll	a0,a0,0x8
8000bc3c:	8d55                	or	a0,a0,a3
8000bc3e:	7ff57693          	and	a3,a0,2047
8000bc42:	13220513          	add	a0,tp,306 # 132 <default_isr_6+0xa>
8000bc46:	ef7fd0ef          	jal	80009b3c <printf>
8000bc4a:	80011537          	lui	a0,0x80011
8000bc4e:	9da50513          	add	a0,a0,-1574 # 800109da <.L.str.2>
8000bc52:	eebfd0ef          	jal	80009b3c <printf>
    return usbd_ep_open(busid, ep) == 0 ? true : false;
8000bc56:	8526                	mv	a0,s1
8000bc58:	85a2                	mv	a1,s0
8000bc5a:	2a09                	jal	8000bd6c <usbd_ep_open>
8000bc5c:	00153513          	seqz	a0,a0
8000bc60:	40b2                	lw	ra,12(sp)
8000bc62:	4422                	lw	s0,8(sp)
8000bc64:	4492                	lw	s1,4(sp)
8000bc66:	0141                	add	sp,sp,16
8000bc68:	8082                	ret

Disassembly of section .text.usb_osal_thread_delete:

8000bc6a <usb_osal_thread_delete>:
    vTaskDelete(thread);
8000bc6a:	1cf0006f          	j	8000c638 <vTaskDelete>

Disassembly of section .text.usb_osal_sem_create:

8000bc6e <usb_osal_sem_create>:
{
8000bc6e:	85aa                	mv	a1,a0
    return (usb_osal_sem_t)xSemaphoreCreateCounting(DAP_PACKET_COUNT, initial_count);
8000bc70:	4521                	li	a0,8
8000bc72:	0db0006f          	j	8000c54c <xQueueCreateCountingSemaphore>

Disassembly of section .text.usb_osal_sem_give:

8000bc76 <usb_osal_sem_give>:
{
8000bc76:	1141                	add	sp,sp,-16
8000bc78:	c606                	sw	ra,12(sp)
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
8000bc7a:	c402                	sw	zero,8(sp)
#define portMEMORY_BARRIER() __asm volatile( "" ::: "memory" )
/*-----------------------------------------------------------*/

portFORCE_INLINE static BaseType_t xPortIsInsideInterrupt( void )
{
    return (read_csr(CSR_MSCRATCH) > 0) ? 1 : 0;
8000bc7c:	340025f3          	csrr	a1,mscratch
    if (xPortIsInsideInterrupt()) {
8000bc80:	cd81                	beqz	a1,8000bc98 <.LBB5_4>
        ret = xSemaphoreGiveFromISR((SemaphoreHandle_t)sem, &xHigherPriorityTaskWoken);
8000bc82:	002c                	add	a1,sp,8
8000bc84:	ed7fb0ef          	jal	80007b5a <xQueueGiveFromISR>
8000bc88:	4585                	li	a1,1
        if (ret == pdPASS) {
8000bc8a:	00b51a63          	bne	a0,a1,8000bc9e <.LBB5_5>
8000bc8e:	45a2                	lw	a1,8(sp)
8000bc90:	c599                	beqz	a1,8000bc9e <.LBB5_5>
            portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
8000bc92:	c2cfc0ef          	jal	800080be <vTaskSwitchContext>
8000bc96:	a801                	j	8000bca6 <.LBB5_6>

8000bc98 <.LBB5_4>:
        ret = xSemaphoreGive((SemaphoreHandle_t)sem);
8000bc98:	4601                	li	a2,0
8000bc9a:	4681                	li	a3,0
8000bc9c:	2fa1                	jal	8000c3f4 <xQueueGenericSend>

8000bc9e <.LBB5_5>:
8000bc9e:	4605                	li	a2,1
8000bca0:	55c9                	li	a1,-14
    return (ret == pdPASS) ? 0 : -USB_ERR_TIMEOUT;
8000bca2:	00c51363          	bne	a0,a2,8000bca8 <.LBB5_7>

8000bca6 <.LBB5_6>:
8000bca6:	4581                	li	a1,0

8000bca8 <.LBB5_7>:
8000bca8:	852e                	mv	a0,a1
8000bcaa:	40b2                	lw	ra,12(sp)
8000bcac:	0141                	add	sp,sp,16
8000bcae:	8082                	ret

Disassembly of section .text.usb_osal_mq_create:

8000bcb0 <usb_osal_mq_create>:
    return (usb_osal_mq_t)xQueueCreate(max_msgs, sizeof(uintptr_t));
8000bcb0:	4591                	li	a1,4
8000bcb2:	4601                	li	a2,0
8000bcb4:	bc7fb06f          	j	8000787a <xQueueGenericCreate>

Disassembly of section .text.usb_osal_mq_delete:

8000bcb8 <usb_osal_mq_delete>:
    vQueueDelete((QueueHandle_t)mq);
8000bcb8:	852fc06f          	j	80007d0a <vQueueDelete>

Disassembly of section .text.usb_dc_init:

8000bcbc <usb_dc_init>:
{
8000bcbc:	1141                	add	sp,sp,-16
8000bcbe:	c606                	sw	ra,12(sp)
8000bcc0:	c422                	sw	s0,8(sp)
8000bcc2:	c226                	sw	s1,4(sp)
8000bcc4:	842a                	mv	s0,a0
    usb_dc_low_level_init(busid);
8000bcc6:	a75fb0ef          	jal	8000773a <usb_dc_low_level_init>
8000bcca:	28400513          	li	a0,644
    memset(&g_hpm_udc[busid], 0, sizeof(struct hpm_udc));
8000bcce:	02a40533          	mul	a0,s0,a0
8000bcd2:	c0018593          	add	a1,gp,-1024 # 80f70 <g_hpm_udc>
8000bcd6:	00a584b3          	add	s1,a1,a0
8000bcda:	00448513          	add	a0,s1,4
8000bcde:	28000613          	li	a2,640
8000bce2:	4581                	li	a1,0
8000bce4:	635010ef          	jal	8000db18 <memset>
    g_hpm_udc[busid].handle = &usb_device_handle[busid];
8000bce8:	00341593          	sll	a1,s0,0x3
    g_hpm_udc[busid].handle->regs = (USB_Type *)g_usbdev_bus[busid].reg_base;
8000bcec:	0008a537          	lui	a0,0x8a
8000bcf0:	5f818613          	add	a2,gp,1528 # 81968 <g_usbdev_bus>
8000bcf4:	962e                	add	a2,a2,a1
8000bcf6:	4250                	lw	a2,4(a2)
    g_hpm_udc[busid].handle = &usb_device_handle[busid];
8000bcf8:	80050513          	add	a0,a0,-2048 # 89800 <usb_device_handle>
8000bcfc:	952e                	add	a0,a0,a1
8000bcfe:	c088                	sw	a0,0(s1)
    g_hpm_udc[busid].handle->regs = (USB_Type *)g_usbdev_bus[busid].reg_base;
8000bd00:	c110                	sw	a2,0(a0)
8000bd02:	f300c6b7          	lui	a3,0xf300c
8000bd06:	00241493          	sll	s1,s0,0x2
    if (g_usbdev_bus[busid].reg_base == HPM_USB0_BASE) {
8000bd0a:	00d61c63          	bne	a2,a3,8000bd22 <.LBB2_2>
        _dcd_irqnum[busid] = IRQn_USB0;
8000bd0e:	6f418613          	add	a2,gp,1780 # 81a64 <_dcd_irqnum>
8000bd12:	9626                	add	a2,a2,s1
8000bd14:	03300693          	li	a3,51
8000bd18:	c214                	sw	a3,0(a2)
        _dcd_busid[0] = busid;
8000bd1a:	00089637          	lui	a2,0x89
8000bd1e:	388607a3          	sb	s0,911(a2) # 8938f <_dcd_busid.0>

8000bd22 <.LBB2_2>:
    if (busid == 0) {
8000bd22:	e819                	bnez	s0,8000bd38 <.LBB2_4>
        g_hpm_udc[busid].handle->dcd_data = &_dcd_data0;
8000bd24:	0008a637          	lui	a2,0x8a
8000bd28:	80060613          	add	a2,a2,-2048 # 89800 <usb_device_handle>
8000bd2c:	95b2                	add	a1,a1,a2
8000bd2e:	0008a637          	lui	a2,0x8a
8000bd32:	00060613          	mv	a2,a2
8000bd36:	c1d0                	sw	a2,4(a1)

8000bd38 <.LBB2_4>:
    usb_device_init(g_hpm_udc[busid].handle, int_mask);
8000bd38:	04700593          	li	a1,71
8000bd3c:	d6efa0ef          	jal	800062aa <usb_device_init>
    intc_m_enable_irq(_dcd_irqnum[busid]);
8000bd40:	6f418513          	add	a0,gp,1780 # 81a64 <_dcd_irqnum>
8000bd44:	9526                	add	a0,a0,s1
8000bd46:	4108                	lw	a0,0(a0)
                                                            ((irq >> 5) << 2));
8000bd48:	00355593          	srl	a1,a0,0x3
8000bd4c:	99f1                	and	a1,a1,-4
                                                            (target << HPM_PLIC_ENABLE_SHIFT_PER_TARGET) +
8000bd4e:	e4002637          	lui	a2,0xe4002
8000bd52:	95b2                	add	a1,a1,a2
    uint32_t current = *current_ptr;
8000bd54:	4190                	lw	a2,0(a1)
8000bd56:	4685                	li	a3,1
    current = current | (1 << (irq & 0x1F));
8000bd58:	00a69533          	sll	a0,a3,a0
8000bd5c:	8d51                	or	a0,a0,a2
    *current_ptr = current;
8000bd5e:	c188                	sw	a0,0(a1)
    return 0;
8000bd60:	4501                	li	a0,0
8000bd62:	40b2                	lw	ra,12(sp)
8000bd64:	4422                	lw	s0,8(sp)
8000bd66:	4492                	lw	s1,4(sp)
8000bd68:	0141                	add	sp,sp,16
8000bd6a:	8082                	ret

Disassembly of section .text.usbd_ep_open:

8000bd6c <usbd_ep_open>:

    return 0;
}

int usbd_ep_open(uint8_t busid, const struct usb_endpoint_descriptor *ep)
{
8000bd6c:	1101                	add	sp,sp,-32
8000bd6e:	ce06                	sw	ra,28(sp)
8000bd70:	cc22                	sw	s0,24(sp)
8000bd72:	ca26                	sw	s1,20(sp)
8000bd74:	c84a                	sw	s2,16(sp)
8000bd76:	842e                	mv	s0,a1
8000bd78:	28400593          	li	a1,644
    usb_endpoint_config_t tmp_ep_cfg;
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000bd7c:	02b504b3          	mul	s1,a0,a1
8000bd80:	c0018513          	add	a0,gp,-1024 # 80f70 <g_hpm_udc>
    uint8_t ep_idx = USB_EP_GET_IDX(ep->bEndpointAddress);

    tmp_ep_cfg.xfer = USB_GET_ENDPOINT_TYPE(ep->bmAttributes);
8000bd84:	00344583          	lbu	a1,3(s0)
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000bd88:	94aa                	add	s1,s1,a0
8000bd8a:	4088                	lw	a0,0(s1)
    uint8_t ep_idx = USB_EP_GET_IDX(ep->bEndpointAddress);
8000bd8c:	00244603          	lbu	a2,2(s0)
    tmp_ep_cfg.xfer = USB_GET_ENDPOINT_TYPE(ep->bmAttributes);
8000bd90:	898d                	and	a1,a1,3
8000bd92:	00b10623          	sb	a1,12(sp)
    tmp_ep_cfg.ep_addr = ep->bEndpointAddress;
    tmp_ep_cfg.max_packet_size = USB_GET_MAXPACKETSIZE(ep->wMaxPacketSize);
8000bd96:	00544583          	lbu	a1,5(s0)
8000bd9a:	00444683          	lbu	a3,4(s0)
    tmp_ep_cfg.ep_addr = ep->bEndpointAddress;
8000bd9e:	00c106a3          	sb	a2,13(sp)
    uint8_t ep_idx = USB_EP_GET_IDX(ep->bEndpointAddress);
8000bda2:	07f67913          	and	s2,a2,127
    tmp_ep_cfg.max_packet_size = USB_GET_MAXPACKETSIZE(ep->wMaxPacketSize);
8000bda6:	05a2                	sll	a1,a1,0x8
8000bda8:	8dd5                	or	a1,a1,a3
8000bdaa:	7ff5f593          	and	a1,a1,2047
8000bdae:	00b11723          	sh	a1,14(sp)

    usb_device_edpt_open(handle, &tmp_ep_cfg);
8000bdb2:	006c                	add	a1,sp,12
8000bdb4:	d60fa0ef          	jal	80006314 <usb_device_edpt_open>
8000bdb8:	00544503          	lbu	a0,5(s0)
8000bdbc:	00444583          	lbu	a1,4(s0)

    if (USB_EP_DIR_IS_OUT(ep->bEndpointAddress)) {
8000bdc0:	00240603          	lb	a2,2(s0)
8000bdc4:	0522                	sll	a0,a0,0x8
8000bdc6:	8d4d                	or	a0,a0,a1
8000bdc8:	7ff57513          	and	a0,a0,2047
8000bdcc:	45d1                	li	a1,20
8000bdce:	00064f63          	bltz	a2,8000bdec <.LBB6_2>
        g_hpm_udc[busid].out_ep[ep_idx].ep_mps = USB_GET_MAXPACKETSIZE(ep->wMaxPacketSize);
        g_hpm_udc[busid].out_ep[ep_idx].ep_type = USB_GET_ENDPOINT_TYPE(ep->bmAttributes);
8000bdd2:	00344603          	lbu	a2,3(s0)
        g_hpm_udc[busid].out_ep[ep_idx].ep_mps = USB_GET_MAXPACKETSIZE(ep->wMaxPacketSize);
8000bdd6:	02b905b3          	mul	a1,s2,a1
8000bdda:	95a6                	add	a1,a1,s1
8000bddc:	14a59223          	sh	a0,324(a1)
        g_hpm_udc[busid].out_ep[ep_idx].ep_type = USB_GET_ENDPOINT_TYPE(ep->bmAttributes);
8000bde0:	8a0d                	and	a2,a2,3
8000bde2:	14c58323          	sb	a2,326(a1)
        g_hpm_udc[busid].out_ep[ep_idx].ep_enable = true;
8000bde6:	14858513          	add	a0,a1,328
8000bdea:	a829                	j	8000be04 <.LBB6_3>

8000bdec <.LBB6_2>:
    } else {
        g_hpm_udc[busid].in_ep[ep_idx].ep_mps = USB_GET_MAXPACKETSIZE(ep->wMaxPacketSize);
        g_hpm_udc[busid].in_ep[ep_idx].ep_type = USB_GET_ENDPOINT_TYPE(ep->bmAttributes);
8000bdec:	00344603          	lbu	a2,3(s0)
        g_hpm_udc[busid].in_ep[ep_idx].ep_mps = USB_GET_MAXPACKETSIZE(ep->wMaxPacketSize);
8000bdf0:	02b905b3          	mul	a1,s2,a1
8000bdf4:	95a6                	add	a1,a1,s1
8000bdf6:	00a59223          	sh	a0,4(a1)
        g_hpm_udc[busid].in_ep[ep_idx].ep_type = USB_GET_ENDPOINT_TYPE(ep->bmAttributes);
8000bdfa:	8a0d                	and	a2,a2,3
8000bdfc:	00c58323          	sb	a2,6(a1)
        g_hpm_udc[busid].in_ep[ep_idx].ep_enable = true;
8000be00:	00858513          	add	a0,a1,8

8000be04 <.LBB6_3>:
8000be04:	4585                	li	a1,1
8000be06:	00b50023          	sb	a1,0(a0)
    }

    return 0;
8000be0a:	4501                	li	a0,0
8000be0c:	40f2                	lw	ra,28(sp)
8000be0e:	4462                	lw	s0,24(sp)
8000be10:	44d2                	lw	s1,20(sp)
8000be12:	4942                	lw	s2,16(sp)
8000be14:	6105                	add	sp,sp,32
8000be16:	8082                	ret

Disassembly of section .text.usbd_ep_close:

8000be18 <usbd_ep_close>:
}

int usbd_ep_close(uint8_t busid, const uint8_t ep)
{
8000be18:	1141                	add	sp,sp,-16
8000be1a:	c606                	sw	ra,12(sp)
8000be1c:	01859613          	sll	a2,a1,0x18
8000be20:	28400693          	li	a3,644
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000be24:	02d50533          	mul	a0,a0,a3
8000be28:	c0018693          	add	a3,gp,-1024 # 80f70 <g_hpm_udc>
8000be2c:	96aa                	add	a3,a3,a0
8000be2e:	4288                	lw	a0,0(a3)
8000be30:	07f5f713          	and	a4,a1,127
8000be34:	47d1                	li	a5,20
    uint8_t ep_idx = USB_EP_GET_IDX(ep);

    if (USB_EP_DIR_IS_OUT(ep)) {
8000be36:	02f70733          	mul	a4,a4,a5
8000be3a:	867d                	sra	a2,a2,0x1f
8000be3c:	ec067613          	and	a2,a2,-320
8000be40:	9636                	add	a2,a2,a3
8000be42:	963a                	add	a2,a2,a4
8000be44:	14060423          	sb	zero,328(a2) # e4002148 <__XPI0_segment_end__+0x63f02148>
        g_hpm_udc[busid].out_ep[ep_idx].ep_enable = false;
    } else {
        g_hpm_udc[busid].in_ep[ep_idx].ep_enable = false;
    }

    usb_device_edpt_close(handle, ep);
8000be48:	d42fa0ef          	jal	8000638a <usb_device_edpt_close>

    return 0;
8000be4c:	4501                	li	a0,0
8000be4e:	40b2                	lw	ra,12(sp)
8000be50:	0141                	add	sp,sp,16
8000be52:	8082                	ret

Disassembly of section .text.usbd_ep_set_stall:

8000be54 <usbd_ep_set_stall>:
}

int usbd_ep_set_stall(uint8_t busid, const uint8_t ep)
{
8000be54:	1141                	add	sp,sp,-16
8000be56:	c606                	sw	ra,12(sp)
8000be58:	28400613          	li	a2,644
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000be5c:	02c50533          	mul	a0,a0,a2
8000be60:	c0018613          	add	a2,gp,-1024 # 80f70 <g_hpm_udc>
8000be64:	9532                	add	a0,a0,a2
8000be66:	4108                	lw	a0,0(a0)

    usb_device_edpt_stall(handle, ep);
8000be68:	d18fa0ef          	jal	80006380 <usb_device_edpt_stall>
    return 0;
8000be6c:	4501                	li	a0,0
8000be6e:	40b2                	lw	ra,12(sp)
8000be70:	0141                	add	sp,sp,16
8000be72:	8082                	ret

Disassembly of section .text.usbd_ep_clear_stall:

8000be74 <usbd_ep_clear_stall>:
}

int usbd_ep_clear_stall(uint8_t busid, const uint8_t ep)
{
8000be74:	1141                	add	sp,sp,-16
8000be76:	c606                	sw	ra,12(sp)
8000be78:	28400613          	li	a2,644
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000be7c:	02c50533          	mul	a0,a0,a2
8000be80:	c0018613          	add	a2,gp,-1024 # 80f70 <g_hpm_udc>
8000be84:	9532                	add	a0,a0,a2
8000be86:	4108                	lw	a0,0(a0)

    usb_device_edpt_clear_stall(handle, ep);
8000be88:	cfcfa0ef          	jal	80006384 <usb_device_edpt_clear_stall>
    return 0;
8000be8c:	4501                	li	a0,0
8000be8e:	40b2                	lw	ra,12(sp)
8000be90:	0141                	add	sp,sp,16
8000be92:	8082                	ret

Disassembly of section .text.usbd_ep_start_write:

8000be94 <usbd_ep_start_write>:
    *stalled = usb_device_edpt_check_stall(handle, ep);
    return 0;
}

int usbd_ep_start_write(uint8_t busid, const uint8_t ep, const uint8_t *data, uint32_t data_len)
{
8000be94:	882a                	mv	a6,a0
8000be96:	28400513          	li	a0,644
    uint8_t ep_idx = USB_EP_GET_IDX(ep);
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000be9a:	02a80733          	mul	a4,a6,a0
8000be9e:	c0018513          	add	a0,gp,-1024 # 80f70 <g_hpm_udc>
8000bea2:	972a                	add	a4,a4,a0
8000bea4:	4308                	lw	a0,0(a4)

    if (!data && data_len) {
8000bea6:	e609                	bnez	a2,8000beb0 <.LBB11_3>
8000bea8:	57fd                	li	a5,-1
8000beaa:	c299                	beqz	a3,8000beb0 <.LBB11_3>
    g_hpm_udc[busid].in_ep[ep_idx].actual_xfer_len = 0;

    usb_device_edpt_xfer(handle, ep, (uint8_t *)data, data_len);

    return 0;
}
8000beac:	853e                	mv	a0,a5
8000beae:	8082                	ret

8000beb0 <.LBB11_3>:
    if (!g_hpm_udc[busid].in_ep[ep_idx].ep_enable) {
8000beb0:	07f5f893          	and	a7,a1,127
8000beb4:	47d1                	li	a5,20
8000beb6:	02f887b3          	mul	a5,a7,a5
8000beba:	973e                	add	a4,a4,a5
8000bebc:	00874703          	lbu	a4,8(a4)
8000bec0:	c715                	beqz	a4,8000beec <.LBB11_5>
8000bec2:	1141                	add	sp,sp,-16
8000bec4:	c606                	sw	ra,12(sp)
8000bec6:	28400713          	li	a4,644
    g_hpm_udc[busid].in_ep[ep_idx].xfer_buf = (uint8_t *)data;
8000beca:	02e80833          	mul	a6,a6,a4
8000bece:	c0018713          	add	a4,gp,-1024 # 80f70 <g_hpm_udc>
8000bed2:	9742                	add	a4,a4,a6
8000bed4:	973e                	add	a4,a4,a5
8000bed6:	c750                	sw	a2,12(a4)
    g_hpm_udc[busid].in_ep[ep_idx].xfer_len = data_len;
8000bed8:	cb14                	sw	a3,16(a4)
    g_hpm_udc[busid].in_ep[ep_idx].actual_xfer_len = 0;
8000beda:	00072a23          	sw	zero,20(a4)
    usb_device_edpt_xfer(handle, ep, (uint8_t *)data, data_len);
8000bede:	a64fe0ef          	jal	8000a142 <usb_device_edpt_xfer>
8000bee2:	4781                	li	a5,0
8000bee4:	40b2                	lw	ra,12(sp)
8000bee6:	0141                	add	sp,sp,16
}
8000bee8:	853e                	mv	a0,a5
8000beea:	8082                	ret

8000beec <.LBB11_5>:
8000beec:	5579                	li	a0,-2
8000beee:	8082                	ret

Disassembly of section .text.usbd_ep_start_read:

8000bef0 <usbd_ep_start_read>:

int usbd_ep_start_read(uint8_t busid, const uint8_t ep, uint8_t *data, uint32_t data_len)
{
8000bef0:	882a                	mv	a6,a0
8000bef2:	28400513          	li	a0,644
    uint8_t ep_idx = USB_EP_GET_IDX(ep);
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000bef6:	02a80733          	mul	a4,a6,a0
8000befa:	c0018513          	add	a0,gp,-1024 # 80f70 <g_hpm_udc>
8000befe:	972a                	add	a4,a4,a0
8000bf00:	4308                	lw	a0,0(a4)

    if (!data && data_len) {
8000bf02:	e609                	bnez	a2,8000bf0c <.LBB12_3>
8000bf04:	57fd                	li	a5,-1
8000bf06:	c299                	beqz	a3,8000bf0c <.LBB12_3>
    g_hpm_udc[busid].out_ep[ep_idx].actual_xfer_len = 0;

    usb_device_edpt_xfer(handle, ep, data, data_len);

    return 0;
}
8000bf08:	853e                	mv	a0,a5
8000bf0a:	8082                	ret

8000bf0c <.LBB12_3>:
    if (!g_hpm_udc[busid].out_ep[ep_idx].ep_enable) {
8000bf0c:	07f5f893          	and	a7,a1,127
8000bf10:	47d1                	li	a5,20
8000bf12:	02f887b3          	mul	a5,a7,a5
8000bf16:	973e                	add	a4,a4,a5
8000bf18:	14874703          	lbu	a4,328(a4)
8000bf1c:	cb05                	beqz	a4,8000bf4c <.LBB12_5>
8000bf1e:	1141                	add	sp,sp,-16
8000bf20:	c606                	sw	ra,12(sp)
8000bf22:	28400713          	li	a4,644
    g_hpm_udc[busid].out_ep[ep_idx].xfer_buf = (uint8_t *)data;
8000bf26:	02e80833          	mul	a6,a6,a4
8000bf2a:	c0018713          	add	a4,gp,-1024 # 80f70 <g_hpm_udc>
8000bf2e:	9742                	add	a4,a4,a6
8000bf30:	973e                	add	a4,a4,a5
8000bf32:	14c72623          	sw	a2,332(a4)
    g_hpm_udc[busid].out_ep[ep_idx].xfer_len = data_len;
8000bf36:	14d72823          	sw	a3,336(a4)
    g_hpm_udc[busid].out_ep[ep_idx].actual_xfer_len = 0;
8000bf3a:	14072a23          	sw	zero,340(a4)
    usb_device_edpt_xfer(handle, ep, data, data_len);
8000bf3e:	a04fe0ef          	jal	8000a142 <usb_device_edpt_xfer>
8000bf42:	4781                	li	a5,0
8000bf44:	40b2                	lw	ra,12(sp)
8000bf46:	0141                	add	sp,sp,16
}
8000bf48:	853e                	mv	a0,a5
8000bf4a:	8082                	ret

8000bf4c <.LBB12_5>:
8000bf4c:	5579                	li	a0,-2
8000bf4e:	8082                	ret

Disassembly of section .text.USBD_IRQHandler:

8000bf50 <USBD_IRQHandler>:

void USBD_IRQHandler(uint8_t busid)
{
8000bf50:	7179                	add	sp,sp,-48
8000bf52:	d606                	sw	ra,44(sp)
8000bf54:	d422                	sw	s0,40(sp)
8000bf56:	d226                	sw	s1,36(sp)
8000bf58:	d04a                	sw	s2,32(sp)
8000bf5a:	ce4e                	sw	s3,28(sp)
8000bf5c:	cc52                	sw	s4,24(sp)
8000bf5e:	ca56                	sw	s5,20(sp)
8000bf60:	c85a                	sw	s6,16(sp)
8000bf62:	c65e                	sw	s7,12(sp)
8000bf64:	c462                	sw	s8,8(sp)
8000bf66:	c266                	sw	s9,4(sp)
8000bf68:	c06a                	sw	s10,0(sp)
8000bf6a:	892a                	mv	s2,a0
8000bf6c:	28400513          	li	a0,644
    uint32_t int_status;
    usb_device_handle_t *handle = g_hpm_udc[busid].handle;
8000bf70:	02a90533          	mul	a0,s2,a0
8000bf74:	c0018593          	add	a1,gp,-1024 # 80f70 <g_hpm_udc>
8000bf78:	952e                	add	a0,a0,a1
8000bf7a:	00052b03          	lw	s6,0(a0)
    uint32_t transfer_len;
    bool ep_cb_req;

    /* Acknowledge handled interrupt */
    int_status = usb_device_status_flags(handle);
8000bf7e:	855a                	mv	a0,s6
8000bf80:	99efe0ef          	jal	8000a11e <usb_device_status_flags>
8000bf84:	842a                	mv	s0,a0
    int_status &= usb_device_interrupts(handle);
8000bf86:	855a                	mv	a0,s6
8000bf88:	9a6fe0ef          	jal	8000a12e <usb_device_interrupts>
8000bf8c:	8c69                	and	s0,s0,a0
    usb_device_clear_status_flags(handle, int_status);
8000bf8e:	855a                	mv	a0,s6
8000bf90:	85a2                	mv	a1,s0
8000bf92:	994fe0ef          	jal	8000a126 <usb_device_clear_status_flags>

    /* disabled interrupt sources */
    if (int_status == 0) {
8000bf96:	1a040163          	beqz	s0,8000c138 <.LBB13_30>
        return;
    }

    if (int_status & intr_error) {
8000bf9a:	00247513          	and	a0,s0,2
8000bf9e:	e901                	bnez	a0,8000bfae <.LBB13_4>
        USB_LOG_ERR("usbd intr error!\r\n");
    }

    if (int_status & intr_reset) {
8000bfa0:	04047513          	and	a0,s0,64
8000bfa4:	e915                	bnez	a0,8000bfd8 <.LBB13_5>

8000bfa6 <.LBB13_3>:
        memset(g_hpm_udc[busid].out_ep, 0, sizeof(struct hpm_ep_state) * USB_NUM_BIDIR_ENDPOINTS);
        usbd_event_reset_handler(busid);
        usb_device_bus_reset(handle, 64);
    }

    if (int_status & intr_suspend) {
8000bfa6:	10047513          	and	a0,s0,256
8000bfaa:	ed39                	bnez	a0,8000c008 <.LBB13_6>
8000bfac:	a885                	j	8000c01c <.LBB13_8>

8000bfae <.LBB13_4>:
        USB_LOG_ERR("usbd intr error!\r\n");
8000bfae:	80010537          	lui	a0,0x80010
8000bfb2:	2bf50513          	add	a0,a0,703 # 800102bf <.L.str>
8000bfb6:	b87fd0ef          	jal	80009b3c <printf>
8000bfba:	80010537          	lui	a0,0x80010
8000bfbe:	2cd50513          	add	a0,a0,717 # 800102cd <.Lstr>
8000bfc2:	154010ef          	jal	8000d116 <puts>
8000bfc6:	80011537          	lui	a0,0x80011
8000bfca:	a7b50513          	add	a0,a0,-1413 # 80010a7b <.L.str.2>
8000bfce:	b6ffd0ef          	jal	80009b3c <printf>
    if (int_status & intr_reset) {
8000bfd2:	04047513          	and	a0,s0,64
8000bfd6:	d961                	beqz	a0,8000bfa6 <.LBB13_3>

8000bfd8 <.LBB13_5>:
8000bfd8:	28400513          	li	a0,644
        memset(g_hpm_udc[busid].in_ep, 0, sizeof(struct hpm_ep_state) * USB_NUM_BIDIR_ENDPOINTS);
8000bfdc:	02a90533          	mul	a0,s2,a0
8000bfe0:	c0018593          	add	a1,gp,-1024 # 80f70 <g_hpm_udc>
8000bfe4:	952e                	add	a0,a0,a1
8000bfe6:	0511                	add	a0,a0,4
        memset(g_hpm_udc[busid].out_ep, 0, sizeof(struct hpm_ep_state) * USB_NUM_BIDIR_ENDPOINTS);
8000bfe8:	28000613          	li	a2,640
8000bfec:	4581                	li	a1,0
8000bfee:	32b010ef          	jal	8000db18 <memset>
        usbd_event_reset_handler(busid);
8000bff2:	854a                	mv	a0,s2
8000bff4:	d9cfb0ef          	jal	80007590 <usbd_event_reset_handler>
        usb_device_bus_reset(handle, 64);
8000bff8:	04000593          	li	a1,64
8000bffc:	855a                	mv	a0,s6
8000bffe:	a4cfa0ef          	jal	8000624a <usb_device_bus_reset>
    if (int_status & intr_suspend) {
8000c002:	10047513          	and	a0,s0,256
8000c006:	c919                	beqz	a0,8000c01c <.LBB13_8>

8000c008 <.LBB13_6>:
        if (usb_device_get_suspend_status(handle)) {
8000c008:	855a                	mv	a0,s6
8000c00a:	92cfe0ef          	jal	8000a136 <usb_device_get_suspend_status>
8000c00e:	c519                	beqz	a0,8000c01c <.LBB13_8>
            usbd_event_suspend_handler(busid);
8000c010:	854a                	mv	a0,s2
8000c012:	d64fb0ef          	jal	80007576 <usbd_event_suspend_handler>
            /* Note: Host may delay more than 3 ms before and/or after bus reset before doing enumeration. */
            if (usb_device_get_address(handle)) {
8000c016:	855a                	mv	a0,s6
8000c018:	ae8fa0ef          	jal	80006300 <usb_device_get_address>

8000c01c <.LBB13_8>:
            }
        }
    }

    if (int_status & intr_port_change) {
8000c01c:	00447513          	and	a0,s0,4
8000c020:	c909                	beqz	a0,8000c032 <.LBB13_11>
        if (!usb_device_get_port_ccs(handle)) {
8000c022:	855a                	mv	a0,s6
8000c024:	ae6fa0ef          	jal	8000630a <usb_device_get_port_ccs>
8000c028:	10050263          	beqz	a0,8000c12c <.LBB13_29>
            usbd_event_disconnect_handler(busid);
        } else {
            usbd_event_connect_handler(busid);
8000c02c:	854a                	mv	a0,s2
8000c02e:	d14fb0ef          	jal	80007542 <usbd_event_connect_handler>

8000c032 <.LBB13_11>:
        }
    }

    if (int_status & intr_usb) {
8000c032:	8805                	and	s0,s0,1
8000c034:	10040263          	beqz	s0,8000c138 <.LBB13_30>

8000c038 <.LBB13_12>:
        uint32_t const edpt_complete = usb_device_get_edpt_complete_status(handle);
8000c038:	855a                	mv	a0,s6
8000c03a:	a98fe0ef          	jal	8000a2d2 <usb_device_get_edpt_complete_status>
8000c03e:	8baa                	mv	s7,a0
        usb_device_clear_edpt_complete_status(handle, edpt_complete);
8000c040:	855a                	mv	a0,s6
8000c042:	85de                	mv	a1,s7
8000c044:	a96fe0ef          	jal	8000a2da <usb_device_clear_edpt_complete_status>
        uint32_t edpt_setup_status = usb_device_get_setup_status(handle);
8000c048:	855a                	mv	a0,s6
8000c04a:	a98fe0ef          	jal	8000a2e2 <usb_device_get_setup_status>

        if (edpt_setup_status) {
8000c04e:	cd11                	beqz	a0,8000c06a <.LBB13_14>
8000c050:	85aa                	mv	a1,a0
            /*------------- Set up Received -------------*/
            usb_device_clear_setup_status(handle, edpt_setup_status);
8000c052:	855a                	mv	a0,s6
8000c054:	a96fe0ef          	jal	8000a2ea <usb_device_clear_setup_status>
            dcd_qhd_t *qhd0 = usb_device_qhd_get(handle, 0);
8000c058:	855a                	mv	a0,s6
8000c05a:	4581                	li	a1,0
8000c05c:	8bafe0ef          	jal	8000a116 <usb_device_qhd_get>
            usbd_event_ep0_setup_complete_handler(busid, (uint8_t *)&qhd0->setup_request);
8000c060:	02850593          	add	a1,a0,40
8000c064:	854a                	mv	a0,s2
8000c066:	ea5fe0ef          	jal	8000af0a <usbd_event_ep0_setup_complete_handler>

8000c06a <.LBB13_14>:
        }

        if (edpt_complete) {
8000c06a:	0c0b8763          	beqz	s7,8000c138 <.LBB13_30>
8000c06e:	4401                	li	s0,0
8000c070:	4c7d                	li	s8,31
8000c072:	4c85                	li	s9,1
8000c074:	80010537          	lui	a0,0x80010
8000c078:	2bf50993          	add	s3,a0,703 # 800102bf <.L.str>
8000c07c:	80010537          	lui	a0,0x80010
8000c080:	2df50a13          	add	s4,a0,735 # 800102df <.Lstr.4>
8000c084:	80011537          	lui	a0,0x80011
8000c088:	a7b50a93          	add	s5,a0,-1413 # 80010a7b <.L.str.2>
8000c08c:	a829                	j	8000c0a6 <.LBB13_18>

8000c08e <.LBB13_16>:

                    /* Failed QTD also get ENDPTCOMPLETE set */
                    dcd_qtd_t *p_qtd = usb_device_qtd_get(handle, ep_idx);
                    while (1) {
                        if (p_qtd->halted || p_qtd->xact_err || p_qtd->buffer_err) {
                            USB_LOG_ERR("usbd transfer error!\r\n");
8000c08e:	854e                	mv	a0,s3
8000c090:	aadfd0ef          	jal	80009b3c <printf>
8000c094:	8552                	mv	a0,s4
8000c096:	080010ef          	jal	8000d116 <puts>
8000c09a:	8556                	mv	a0,s5
8000c09c:	aa1fd0ef          	jal	80009b3c <printf>

8000c0a0 <.LBB13_17>:
            for (uint8_t ep_idx = 0; ep_idx < USB_SOS_DCD_MAX_QHD_COUNT; ep_idx++) {
8000c0a0:	0405                	add	s0,s0,1
8000c0a2:	098d7b63          	bgeu	s10,s8,8000c138 <.LBB13_30>

8000c0a6 <.LBB13_18>:
8000c0a6:	01841493          	sll	s1,s0,0x18
8000c0aa:	80e5                	srl	s1,s1,0x19
    return ep_idx / 2 + ((ep_idx % 2) ? 16 : 0);
8000c0ac:	00441513          	sll	a0,s0,0x4
8000c0b0:	8941                	and	a0,a0,16
8000c0b2:	8d45                	or	a0,a0,s1
                if (edpt_complete & (1 << ep_idx2bit(ep_idx))) {
8000c0b4:	00abd533          	srl	a0,s7,a0
8000c0b8:	8905                	and	a0,a0,1
8000c0ba:	0ff47d13          	zext.b	s10,s0
8000c0be:	d16d                	beqz	a0,8000c0a0 <.LBB13_17>
                    dcd_qtd_t *p_qtd = usb_device_qtd_get(handle, ep_idx);
8000c0c0:	855a                	mv	a0,s6
8000c0c2:	85ea                	mv	a1,s10
8000c0c4:	978fa0ef          	jal	8000623c <usb_device_qtd_get>
                        if (p_qtd->halted || p_qtd->xact_err || p_qtd->buffer_err) {
8000c0c8:	414c                	lw	a1,4(a0)
8000c0ca:	0405f593          	and	a1,a1,64
8000c0ce:	f1e1                	bnez	a1,8000c08e <.LBB13_16>
8000c0d0:	4601                	li	a2,0
8000c0d2:	00450593          	add	a1,a0,4

8000c0d6 <.LBB13_21>:
8000c0d6:	4154                	lw	a3,4(a0)
8000c0d8:	8aa1                	and	a3,a3,8
8000c0da:	fad5                	bnez	a3,8000c08e <.LBB13_16>
8000c0dc:	4194                	lw	a3,0(a1)
8000c0de:	0206f693          	and	a3,a3,32
8000c0e2:	f6d5                	bnez	a3,8000c08e <.LBB13_16>
                            ep_cb_req = false;
                            break;
                        } else if (p_qtd->active) {
8000c0e4:	4194                	lw	a3,0(a1)
8000c0e6:	0806f693          	and	a3,a3,128
8000c0ea:	fadd                	bnez	a3,8000c0a0 <.LBB13_17>
                            ep_cb_req = false;
                            break;
                        } else {
                            transfer_len += p_qtd->expected_bytes - p_qtd->total_bytes;
8000c0ec:	01c55683          	lhu	a3,28(a0)
8000c0f0:	418c                	lw	a1,0(a1)
                        }

                        if (p_qtd->next == USB_SOC_DCD_QTD_NEXT_INVALID){
8000c0f2:	4118                	lw	a4,0(a0)
                            transfer_len += p_qtd->expected_bytes - p_qtd->total_bytes;
8000c0f4:	0586                	sll	a1,a1,0x1
8000c0f6:	81c5                	srl	a1,a1,0x11
8000c0f8:	9636                	add	a2,a2,a3
8000c0fa:	8e0d                	sub	a2,a2,a1
                        if (p_qtd->next == USB_SOC_DCD_QTD_NEXT_INVALID){
8000c0fc:	01970a63          	beq	a4,s9,8000c110 <.LBB13_26>
                            break;
                        } else {
                            p_qtd = (dcd_qtd_t *)p_qtd->next;
8000c100:	4108                	lw	a0,0(a0)
                        if (p_qtd->halted || p_qtd->xact_err || p_qtd->buffer_err) {
8000c102:	414c                	lw	a1,4(a0)
8000c104:	0405f693          	and	a3,a1,64
8000c108:	00450593          	add	a1,a0,4
8000c10c:	d6e9                	beqz	a3,8000c0d6 <.LBB13_21>
8000c10e:	b741                	j	8000c08e <.LBB13_16>

8000c110 <.LBB13_26>:
                        }
                    }

                    if (ep_cb_req) {
                        uint8_t const ep_addr = (ep_idx / 2) | ((ep_idx & 0x01) ? 0x80 : 0);
8000c110:	00741513          	sll	a0,s0,0x7
8000c114:	8d45                	or	a0,a0,s1
8000c116:	01851693          	sll	a3,a0,0x18
8000c11a:	0ff57593          	zext.b	a1,a0
                        if (ep_addr & 0x80) {
                            usbd_event_ep_in_complete_handler(busid, ep_addr, transfer_len);
                        } else {
                            usbd_event_ep_out_complete_handler(busid, ep_addr, transfer_len);
8000c11e:	854a                	mv	a0,s2
                        if (ep_addr & 0x80) {
8000c120:	0006c463          	bltz	a3,8000c128 <.LBB13_28>
                            usbd_event_ep_out_complete_handler(busid, ep_addr, transfer_len);
8000c124:	3a2d                	jal	8000ba5e <usbd_event_ep_out_complete_handler>
8000c126:	bfad                	j	8000c0a0 <.LBB13_17>

8000c128 <.LBB13_28>:
                            usbd_event_ep_in_complete_handler(busid, ep_addr, transfer_len);
8000c128:	3239                	jal	8000ba36 <usbd_event_ep_in_complete_handler>
8000c12a:	bf9d                	j	8000c0a0 <.LBB13_17>

8000c12c <.LBB13_29>:
            usbd_event_disconnect_handler(busid);
8000c12c:	854a                	mv	a0,s2
8000c12e:	c2efb0ef          	jal	8000755c <usbd_event_disconnect_handler>
    if (int_status & intr_usb) {
8000c132:	8805                	and	s0,s0,1
8000c134:	f00412e3          	bnez	s0,8000c038 <.LBB13_12>

8000c138 <.LBB13_30>:
8000c138:	50b2                	lw	ra,44(sp)
8000c13a:	5422                	lw	s0,40(sp)
8000c13c:	5492                	lw	s1,36(sp)
8000c13e:	5902                	lw	s2,32(sp)
8000c140:	49f2                	lw	s3,28(sp)
8000c142:	4a62                	lw	s4,24(sp)
8000c144:	4ad2                	lw	s5,20(sp)
8000c146:	4b42                	lw	s6,16(sp)
8000c148:	4bb2                	lw	s7,12(sp)
8000c14a:	4c22                	lw	s8,8(sp)
8000c14c:	4c92                	lw	s9,4(sp)
8000c14e:	4d02                	lw	s10,0(sp)
                    }
                }
            }
        }
    }
}
8000c150:	6145                	add	sp,sp,48
8000c152:	8082                	ret

Disassembly of section .text.vPortSetupTimerInterrupt:

8000c154 <vPortSetupTimerInterrupt>:

void vPortSetupTimerInterrupt( void )
{
    uint64_t ulCurrentTime;

    pullMachineTimerCompareRegister  = ( volatile uint64_t * const ) ( configMTIMECMP_BASE_ADDRESS );
8000c154:	e60005b7          	lui	a1,0xe6000
8000c158:	00858613          	add	a2,a1,8 # e6000008 <__XPI0_segment_end__+0x65f00008>
8000c15c:	68c1a223          	sw	a2,1668(gp) # 819f4 <pullMachineTimerCompareRegister>
    ulCurrentTime =  *( volatile uint64_t * const ) ( configMTIME_BASE_ADDRESS );
8000c160:	41c8                	lw	a0,4(a1)
8000c162:	4190                	lw	a2,0(a1)

    ullNextTime = ulCurrentTime + ( uint64_t ) uxTimerIncrementsForOneTick;
8000c164:	800056b7          	lui	a3,0x80005
8000c168:	f006a683          	lw	a3,-256(a3) # 80004f00 <uxTimerIncrementsForOneTick>
8000c16c:	00d60733          	add	a4,a2,a3
8000c170:	00c73633          	sltu	a2,a4,a2
8000c174:	9532                	add	a0,a0,a2
8000c176:	00080637          	lui	a2,0x80
8000c17a:	2ca62e23          	sw	a0,732(a2) # 802dc <ullNextTime+0x4>
8000c17e:	2ce62c23          	sw	a4,728(a2)
    *pullMachineTimerCompareRegister = ullNextTime;
8000c182:	c5c8                	sw	a0,12(a1)
8000c184:	c598                	sw	a4,8(a1)

    /* Prepare the time to use after the next tick interrupt. */
    ullNextTime += ( uint64_t ) uxTimerIncrementsForOneTick;
8000c186:	2d862503          	lw	a0,728(a2)
8000c18a:	2dc62583          	lw	a1,732(a2)
8000c18e:	96aa                	add	a3,a3,a0
8000c190:	00a6b533          	sltu	a0,a3,a0
8000c194:	952e                	add	a0,a0,a1
8000c196:	2cd62c23          	sw	a3,728(a2)
8000c19a:	2ca62e23          	sw	a0,732(a2)
}
8000c19e:	8082                	ret

Disassembly of section .text.pvPortMalloc:

8000c1a0 <pvPortMalloc>:
PRIVILEGED_DATA static size_t xBlockAllocatedBit = 0;

/*-----------------------------------------------------------*/

void * pvPortMalloc( size_t xWantedSize )
{
8000c1a0:	1141                	add	sp,sp,-16
8000c1a2:	c606                	sw	ra,12(sp)
8000c1a4:	c422                	sw	s0,8(sp)
8000c1a6:	c226                	sw	s1,4(sp)
8000c1a8:	842a                	mv	s0,a0
    BlockLink_t * pxBlock, * pxPreviousBlock, * pxNewBlockLink;
    void * pvReturn = NULL;

    vTaskSuspendAll();
8000c1aa:	23c9                	jal	8000c76c <vTaskSuspendAll>
    {
        /* If this is the first call to malloc then the heap will require
         * initialisation to setup the list of free blocks. */
        if( pxEnd == NULL )
8000c1ac:	6741a583          	lw	a1,1652(gp) # 819e4 <pxEnd>
8000c1b0:	c589                	beqz	a1,8000c1ba <.LBB0_2>

        /* Check the requested block size is not so large that the top bit is
         * set.  The top bit of the block size member of the BlockLink_t structure
         * is used to determine who owns the block - the application or the
         * kernel, so it must be free. */
        if( ( xWantedSize & xBlockAllocatedBit ) == 0 )
8000c1b2:	7081c503          	lbu	a0,1800(gp) # 81a78 <xBlockAllocatedBit>
8000c1b6:	057e                	sll	a0,a0,0x1f
8000c1b8:	a891                	j	8000c20c <.LBB0_5>

8000c1ba <.LBB0_2>:
    size_t xTotalHeapSize = configTOTAL_HEAP_SIZE;

    /* Ensure the heap starts on a correctly aligned boundary. */
    uxAddress = ( size_t ) ucHeap;

    if( ( uxAddress & portBYTE_ALIGNMENT_MASK ) != 0 )
8000c1ba:	73018593          	add	a1,gp,1840 # 81aa0 <ucHeap>
8000c1be:	0075f613          	and	a2,a1,7
8000c1c2:	852e                	mv	a0,a1
8000c1c4:	c601                	beqz	a2,8000c1cc <.LBB0_4>
8000c1c6:	00758513          	add	a0,a1,7
8000c1ca:	9961                	and	a0,a0,-8

8000c1cc <.LBB0_4>:

    pucAlignedHeap = ( uint8_t * ) uxAddress;

    /* xStart is used to hold a pointer to the first item in the list of free
     * blocks.  The void cast is used to prevent compiler warnings. */
    xStart.pxNextFreeBlock = ( void * ) pucAlignedHeap;
8000c1cc:	5ea1a823          	sw	a0,1520(gp) # 81960 <xStart>
8000c1d0:	5f018613          	add	a2,gp,1520 # 81960 <xStart>
    xStart.xBlockSize = ( size_t ) 0;
8000c1d4:	00062223          	sw	zero,4(a2)
8000c1d8:	6615                	lui	a2,0x5

    /* pxEnd is used to mark the end of the list of free blocks and is inserted
     * at the end of the heap space. */
    uxAddress = ( ( size_t ) pucAlignedHeap ) + xTotalHeapSize;
    uxAddress -= xHeapStructSize;
    uxAddress &= ~( ( size_t ) portBYTE_ALIGNMENT_MASK );
8000c1da:	95b2                	add	a1,a1,a2
8000c1dc:	ff85f613          	and	a2,a1,-8
8000c1e0:	ff860693          	add	a3,a2,-8 # 4ff8 <.LBB2_46+0x1a>
    pxEnd = ( void * ) uxAddress;
8000c1e4:	66d1aa23          	sw	a3,1652(gp) # 819e4 <pxEnd>
    pxEnd->xBlockSize = 0;
    pxEnd->pxNextFreeBlock = NULL;
8000c1e8:	fe062c23          	sw	zero,-8(a2)

    /* To start with there is a single free block that is sized to take up the
     * entire heap space, minus the space taken by pxEnd. */
    pxFirstFreeBlock = ( void * ) pucAlignedHeap;
    pxFirstFreeBlock->xBlockSize = uxAddress - ( size_t ) pxFirstFreeBlock;
    pxFirstFreeBlock->pxNextFreeBlock = pxEnd;
8000c1ec:	6741a583          	lw	a1,1652(gp) # 819e4 <pxEnd>
    pxEnd->xBlockSize = 0;
8000c1f0:	fe062e23          	sw	zero,-4(a2)
    pxFirstFreeBlock->xBlockSize = uxAddress - ( size_t ) pxFirstFreeBlock;
8000c1f4:	8e89                	sub	a3,a3,a0
8000c1f6:	c154                	sw	a3,4(a0)
    pxFirstFreeBlock->pxNextFreeBlock = pxEnd;
8000c1f8:	c10c                	sw	a1,0(a0)

    /* Only one block exists - and it covers the entire usable heap space. */
    xMinimumEverFreeBytesRemaining = pxFirstFreeBlock->xBlockSize;
8000c1fa:	62d1a823          	sw	a3,1584(gp) # 819a0 <xMinimumEverFreeBytesRemaining>
    xFreeBytesRemaining = pxFirstFreeBlock->xBlockSize;
8000c1fe:	62d1ac23          	sw	a3,1592(gp) # 819a8 <xFreeBytesRemaining>

    /* Work out the position of the top bit in a size_t variable. */
    xBlockAllocatedBit = ( ( size_t ) 1 ) << ( ( sizeof( size_t ) * heapBITS_PER_BYTE ) - 1 );
8000c202:	4605                	li	a2,1
8000c204:	70c18423          	sb	a2,1800(gp) # 81a78 <xBlockAllocatedBit>
8000c208:	80000537          	lui	a0,0x80000

8000c20c <.LBB0_5>:
        if( ( xWantedSize & xBlockAllocatedBit ) == 0 )
8000c20c:	fff40613          	add	a2,s0,-1
8000c210:	56d9                	li	a3,-10
8000c212:	4481                	li	s1,0
8000c214:	0ec6e463          	bltu	a3,a2,8000c2fc <.LBB0_31>
8000c218:	8d61                	and	a0,a0,s0
8000c21a:	0e051163          	bnez	a0,8000c2fc <.LBB0_31>
                if( ( xWantedSize & portBYTE_ALIGNMENT_MASK ) != 0x00 )
8000c21e:	00747513          	and	a0,s0,7
                ( ( xWantedSize + xHeapStructSize ) >  xWantedSize ) ) /* Overflow check */
8000c222:	00840613          	add	a2,s0,8
                if( ( xWantedSize & portBYTE_ALIGNMENT_MASK ) != 0x00 )
8000c226:	c901                	beqz	a0,8000c236 <.LBB0_9>
8000c228:	9861                	and	s0,s0,-8
8000c22a:	0441                	add	s0,s0,16
8000c22c:	00863533          	sltu	a0,a2,s0
8000c230:	40a00633          	neg	a2,a0
8000c234:	8e61                	and	a2,a2,s0

8000c236 <.LBB0_9>:
8000c236:	6381a503          	lw	a0,1592(gp) # 819a8 <xFreeBytesRemaining>
            if( ( xWantedSize > 0 ) && ( xWantedSize <= xFreeBytesRemaining ) )
8000c23a:	fff60693          	add	a3,a2,-1
8000c23e:	4481                	li	s1,0
8000c240:	0aa6fe63          	bgeu	a3,a0,8000c2fc <.LBB0_31>
                pxBlock = xStart.pxNextFreeBlock;
8000c244:	5f01a503          	lw	a0,1520(gp) # 81960 <xStart>
                while( ( pxBlock->xBlockSize < xWantedSize ) && ( pxBlock->pxNextFreeBlock != NULL ) )
8000c248:	4158                	lw	a4,4(a0)
                pxBlock = xStart.pxNextFreeBlock;
8000c24a:	5f018693          	add	a3,gp,1520 # 81960 <xStart>
                while( ( pxBlock->xBlockSize < xWantedSize ) && ( pxBlock->pxNextFreeBlock != NULL ) )
8000c24e:	00c77963          	bgeu	a4,a2,8000c260 <.LBB0_13>

8000c252 <.LBB0_11>:
8000c252:	411c                	lw	a5,0(a0)
8000c254:	c791                	beqz	a5,8000c260 <.LBB0_13>
8000c256:	86aa                	mv	a3,a0
8000c258:	853e                	mv	a0,a5
8000c25a:	43d8                	lw	a4,4(a5)
8000c25c:	fec76be3          	bltu	a4,a2,8000c252 <.LBB0_11>

8000c260 <.LBB0_13>:
                if( pxBlock != pxEnd )
8000c260:	02b50263          	beq	a0,a1,8000c284 <.LBB0_18>
                    pxPreviousBlock->pxNextFreeBlock = pxBlock->pxNextFreeBlock;
8000c264:	410c                	lw	a1,0(a0)
                    pvReturn = ( void * ) ( ( ( uint8_t * ) pxPreviousBlock->pxNextFreeBlock ) + xHeapStructSize );
8000c266:	4284                	lw	s1,0(a3)
                    if( ( pxBlock->xBlockSize - xWantedSize ) > heapMINIMUM_BLOCK_SIZE )
8000c268:	8f11                	sub	a4,a4,a2
8000c26a:	47c5                	li	a5,17
                    pxPreviousBlock->pxNextFreeBlock = pxBlock->pxNextFreeBlock;
8000c26c:	c28c                	sw	a1,0(a3)
                    if( ( pxBlock->xBlockSize - xWantedSize ) > heapMINIMUM_BLOCK_SIZE )
8000c26e:	04f76e63          	bltu	a4,a5,8000c2ca <.LBB0_28>
                        pxNewBlockLink = ( void * ) ( ( ( uint8_t * ) pxBlock ) + xWantedSize );
8000c272:	00c50433          	add	s0,a0,a2
                        configASSERT( ( ( ( size_t ) pxNewBlockLink ) & portBYTE_ALIGNMENT_MASK ) == 0 );
8000c276:	00747693          	and	a3,s0,7
8000c27a:	c699                	beqz	a3,8000c288 <.LBB0_19>
8000c27c:	30047073          	csrc	mstatus,8
8000c280:	9002                	ebreak

8000c282 <.LBB0_17>:
8000c282:	a001                	j	8000c282 <.LBB0_17>

8000c284 <.LBB0_18>:
8000c284:	4481                	li	s1,0
8000c286:	a89d                	j	8000c2fc <.LBB0_31>

8000c288 <.LBB0_19>:
                        pxNewBlockLink->xBlockSize = pxBlock->xBlockSize - xWantedSize;
8000c288:	c058                	sw	a4,4(s0)
                        pxBlock->xBlockSize = xWantedSize;
8000c28a:	c150                	sw	a2,4(a0)
8000c28c:	5f018693          	add	a3,gp,1520 # 81960 <xStart>

8000c290 <.LBB0_20>:
    BlockLink_t * pxIterator;
    uint8_t * puc;

    /* Iterate through the list until a block is found that has a higher address
     * than the block being inserted. */
    for( pxIterator = &xStart; pxIterator->pxNextFreeBlock < pxBlockToInsert; pxIterator = pxIterator->pxNextFreeBlock )
8000c290:	85b6                	mv	a1,a3
8000c292:	4294                	lw	a3,0(a3)
8000c294:	fe86eee3          	bltu	a3,s0,8000c290 <.LBB0_20>

    /* Do the block being inserted, and the block it is being inserted after
     * make a contiguous block of memory? */
    puc = ( uint8_t * ) pxIterator;

    if( ( puc + pxIterator->xBlockSize ) == ( uint8_t * ) pxBlockToInsert )
8000c298:	41dc                	lw	a5,4(a1)
8000c29a:	4058                	lw	a4,4(s0)
8000c29c:	00f58633          	add	a2,a1,a5
8000c2a0:	00861563          	bne	a2,s0,8000c2aa <.LBB0_23>
    {
        pxIterator->xBlockSize += pxBlockToInsert->xBlockSize;
8000c2a4:	973e                	add	a4,a4,a5
8000c2a6:	c1d8                	sw	a4,4(a1)
8000c2a8:	842e                	mv	s0,a1

8000c2aa <.LBB0_23>:

    /* Do the block being inserted, and the block it is being inserted before
     * make a contiguous block of memory? */
    puc = ( uint8_t * ) pxBlockToInsert;

    if( ( puc + pxBlockToInsert->xBlockSize ) == ( uint8_t * ) pxIterator->pxNextFreeBlock )
8000c2aa:	00e40633          	add	a2,s0,a4
8000c2ae:	00d61a63          	bne	a2,a3,8000c2c2 <.LBB0_26>
8000c2b2:	6741a603          	lw	a2,1652(gp) # 819e4 <pxEnd>
8000c2b6:	00c68663          	beq	a3,a2,8000c2c2 <.LBB0_26>
    {
        if( pxIterator->pxNextFreeBlock != pxEnd )
        {
            /* Form one big block from the two blocks. */
            pxBlockToInsert->xBlockSize += pxIterator->pxNextFreeBlock->xBlockSize;
8000c2ba:	42d0                	lw	a2,4(a3)
            pxBlockToInsert->pxNextFreeBlock = pxIterator->pxNextFreeBlock->pxNextFreeBlock;
8000c2bc:	4294                	lw	a3,0(a3)
            pxBlockToInsert->xBlockSize += pxIterator->pxNextFreeBlock->xBlockSize;
8000c2be:	963a                	add	a2,a2,a4
8000c2c0:	c050                	sw	a2,4(s0)

8000c2c2 <.LBB0_26>:
8000c2c2:	c014                	sw	a3,0(s0)

    /* If the block being inserted plugged a gab, so was merged with the block
     * before and the block after, then it's pxNextFreeBlock pointer will have
     * already been set, and should not be set here as that would make it point
     * to itself. */
    if( pxIterator != pxBlockToInsert )
8000c2c4:	00858363          	beq	a1,s0,8000c2ca <.LBB0_28>
    {
        pxIterator->pxNextFreeBlock = pxBlockToInsert;
8000c2c8:	c180                	sw	s0,0(a1)

8000c2ca <.LBB0_28>:
                    xFreeBytesRemaining -= pxBlock->xBlockSize;
8000c2ca:	414c                	lw	a1,4(a0)
8000c2cc:	6381a683          	lw	a3,1592(gp) # 819a8 <xFreeBytesRemaining>
                    if( xFreeBytesRemaining < xMinimumEverFreeBytesRemaining )
8000c2d0:	6301a783          	lw	a5,1584(gp) # 819a0 <xMinimumEverFreeBytesRemaining>
                    xFreeBytesRemaining -= pxBlock->xBlockSize;
8000c2d4:	8e8d                	sub	a3,a3,a1
8000c2d6:	62d1ac23          	sw	a3,1592(gp) # 819a8 <xFreeBytesRemaining>
                    if( xFreeBytesRemaining < xMinimumEverFreeBytesRemaining )
8000c2da:	00f6f463          	bgeu	a3,a5,8000c2e2 <.LBB0_30>
                        xMinimumEverFreeBytesRemaining = xFreeBytesRemaining;
8000c2de:	62d1a823          	sw	a3,1584(gp) # 819a0 <xMinimumEverFreeBytesRemaining>

8000c2e2 <.LBB0_30>:
                    pxBlock->xBlockSize |= xBlockAllocatedBit;
8000c2e2:	7081c603          	lbu	a2,1800(gp) # 81a78 <xBlockAllocatedBit>
8000c2e6:	04a1                	add	s1,s1,8
8000c2e8:	067e                	sll	a2,a2,0x1f
                    xNumberOfSuccessfulAllocations++;
8000c2ea:	6241a703          	lw	a4,1572(gp) # 81994 <xNumberOfSuccessfulAllocations>
                    pxBlock->xBlockSize |= xBlockAllocatedBit;
8000c2ee:	8dd1                	or	a1,a1,a2
8000c2f0:	c14c                	sw	a1,4(a0)
                    pxBlock->pxNextFreeBlock = NULL;
8000c2f2:	00052023          	sw	zero,0(a0) # 80000000 <_flash_size+0x7ff00000>
                    xNumberOfSuccessfulAllocations++;
8000c2f6:	0705                	add	a4,a4,1
8000c2f8:	62e1a223          	sw	a4,1572(gp) # 81994 <xNumberOfSuccessfulAllocations>

8000c2fc <.LBB0_31>:
    ( void ) xTaskResumeAll();
8000c2fc:	29b5                	jal	8000c778 <xTaskResumeAll>
    configASSERT( ( ( ( size_t ) pvReturn ) & ( size_t ) portBYTE_ALIGNMENT_MASK ) == 0 );
8000c2fe:	0074f513          	and	a0,s1,7
8000c302:	c509                	beqz	a0,8000c30c <.LBB0_34>
8000c304:	30047073          	csrc	mstatus,8
8000c308:	9002                	ebreak

8000c30a <.LBB0_33>:
8000c30a:	a001                	j	8000c30a <.LBB0_33>

8000c30c <.LBB0_34>:
    return pvReturn;
8000c30c:	8526                	mv	a0,s1
8000c30e:	40b2                	lw	ra,12(sp)
8000c310:	4422                	lw	s0,8(sp)
8000c312:	4492                	lw	s1,4(sp)
8000c314:	0141                	add	sp,sp,16
8000c316:	8082                	ret

Disassembly of section .text.vPortFree:

8000c318 <vPortFree>:
{
8000c318:	1141                	add	sp,sp,-16
8000c31a:	c606                	sw	ra,12(sp)
8000c31c:	c422                	sw	s0,8(sp)
8000c31e:	c226                	sw	s1,4(sp)
    if( pv != NULL )
8000c320:	c10d                	beqz	a0,8000c342 <.LBB1_5>
        configASSERT( ( pxLink->xBlockSize & xBlockAllocatedBit ) != 0 );
8000c322:	7081c603          	lbu	a2,1800(gp) # 81a78 <xBlockAllocatedBit>
8000c326:	ffc52583          	lw	a1,-4(a0)
8000c32a:	067e                	sll	a2,a2,0x1f
8000c32c:	00b676b3          	and	a3,a2,a1
8000c330:	ce91                	beqz	a3,8000c34c <.LBB1_6>
8000c332:	ff850413          	add	s0,a0,-8
        configASSERT( pxLink->pxNextFreeBlock == NULL );
8000c336:	4014                	lw	a3,0(s0)
8000c338:	ce91                	beqz	a3,8000c354 <.LBB1_8>
8000c33a:	30047073          	csrc	mstatus,8
8000c33e:	9002                	ebreak

8000c340 <.LBB1_4>:
8000c340:	a001                	j	8000c340 <.LBB1_4>

8000c342 <.LBB1_5>:
8000c342:	40b2                	lw	ra,12(sp)
8000c344:	4422                	lw	s0,8(sp)
8000c346:	4492                	lw	s1,4(sp)
}
8000c348:	0141                	add	sp,sp,16
8000c34a:	8082                	ret

8000c34c <.LBB1_6>:
        configASSERT( ( pxLink->xBlockSize & xBlockAllocatedBit ) != 0 );
8000c34c:	30047073          	csrc	mstatus,8
8000c350:	9002                	ebreak

8000c352 <.LBB1_7>:
8000c352:	a001                	j	8000c352 <.LBB1_7>

8000c354 <.LBB1_8>:
                pxLink->xBlockSize &= ~xBlockAllocatedBit;
8000c354:	fff64613          	not	a2,a2
8000c358:	8df1                	and	a1,a1,a2
8000c35a:	feb52e23          	sw	a1,-4(a0)
8000c35e:	84aa                	mv	s1,a0
                vTaskSuspendAll();
8000c360:	2131                	jal	8000c76c <vTaskSuspendAll>
                    xFreeBytesRemaining += pxLink->xBlockSize;
8000c362:	ffc4a603          	lw	a2,-4(s1)
8000c366:	6381a583          	lw	a1,1592(gp) # 819a8 <xFreeBytesRemaining>
8000c36a:	95b2                	add	a1,a1,a2
8000c36c:	62b1ac23          	sw	a1,1592(gp) # 819a8 <xFreeBytesRemaining>
8000c370:	5f018593          	add	a1,gp,1520 # 81960 <xStart>

8000c374 <.LBB1_9>:
    for( pxIterator = &xStart; pxIterator->pxNextFreeBlock < pxBlockToInsert; pxIterator = pxIterator->pxNextFreeBlock )
8000c374:	852e                	mv	a0,a1
8000c376:	418c                	lw	a1,0(a1)
8000c378:	fe85eee3          	bltu	a1,s0,8000c374 <.LBB1_9>
    if( ( puc + pxIterator->xBlockSize ) == ( uint8_t * ) pxBlockToInsert )
8000c37c:	4154                	lw	a3,4(a0)
8000c37e:	00d50733          	add	a4,a0,a3
8000c382:	00871563          	bne	a4,s0,8000c38c <.LBB1_12>
        pxIterator->xBlockSize += pxBlockToInsert->xBlockSize;
8000c386:	9636                	add	a2,a2,a3
8000c388:	c150                	sw	a2,4(a0)
8000c38a:	842a                	mv	s0,a0

8000c38c <.LBB1_12>:
    if( ( puc + pxBlockToInsert->xBlockSize ) == ( uint8_t * ) pxIterator->pxNextFreeBlock )
8000c38c:	00c406b3          	add	a3,s0,a2
8000c390:	00b69a63          	bne	a3,a1,8000c3a4 <.LBB1_15>
8000c394:	6741a683          	lw	a3,1652(gp) # 819e4 <pxEnd>
8000c398:	00d58663          	beq	a1,a3,8000c3a4 <.LBB1_15>
            pxBlockToInsert->xBlockSize += pxIterator->pxNextFreeBlock->xBlockSize;
8000c39c:	41d4                	lw	a3,4(a1)
            pxBlockToInsert->pxNextFreeBlock = pxIterator->pxNextFreeBlock->pxNextFreeBlock;
8000c39e:	418c                	lw	a1,0(a1)
            pxBlockToInsert->xBlockSize += pxIterator->pxNextFreeBlock->xBlockSize;
8000c3a0:	9636                	add	a2,a2,a3
8000c3a2:	c050                	sw	a2,4(s0)

8000c3a4 <.LBB1_15>:
8000c3a4:	c00c                	sw	a1,0(s0)
    if( pxIterator != pxBlockToInsert )
8000c3a6:	00850363          	beq	a0,s0,8000c3ac <.LBB1_17>
        pxIterator->pxNextFreeBlock = pxBlockToInsert;
8000c3aa:	c100                	sw	s0,0(a0)

8000c3ac <.LBB1_17>:
                    xNumberOfSuccessfulFrees++;
8000c3ac:	6201a583          	lw	a1,1568(gp) # 81990 <xNumberOfSuccessfulFrees>
8000c3b0:	0585                	add	a1,a1,1
8000c3b2:	62b1a023          	sw	a1,1568(gp) # 81990 <xNumberOfSuccessfulFrees>
8000c3b6:	40b2                	lw	ra,12(sp)
8000c3b8:	4422                	lw	s0,8(sp)
8000c3ba:	4492                	lw	s1,4(sp)
                ( void ) xTaskResumeAll();
8000c3bc:	0141                	add	sp,sp,16
8000c3be:	ae6d                	j	8000c778 <xTaskResumeAll>

Disassembly of section .text.vListInitialise:

8000c3c0 <vListInitialise>:
    pxList->pxIndex = ( ListItem_t * ) &( pxList->xListEnd ); /*lint !e826 !e740 !e9087 The mini list structure is used as the list end to save RAM.  This is checked and valid. */
8000c3c0:	00850593          	add	a1,a0,8
8000c3c4:	c14c                	sw	a1,4(a0)
8000c3c6:	567d                	li	a2,-1
    pxList->xListEnd.xItemValue = portMAX_DELAY;
8000c3c8:	c510                	sw	a2,8(a0)
    pxList->xListEnd.pxNext = ( ListItem_t * ) &( pxList->xListEnd );     /*lint !e826 !e740 !e9087 The mini list structure is used as the list end to save RAM.  This is checked and valid. */
8000c3ca:	c54c                	sw	a1,12(a0)
    pxList->xListEnd.pxPrevious = ( ListItem_t * ) &( pxList->xListEnd ); /*lint !e826 !e740 !e9087 The mini list structure is used as the list end to save RAM.  This is checked and valid. */
8000c3cc:	c90c                	sw	a1,16(a0)
    pxList->uxNumberOfItems = ( UBaseType_t ) 0U;
8000c3ce:	00052023          	sw	zero,0(a0)
}
8000c3d2:	8082                	ret

Disassembly of section .text.uxListRemove:

8000c3d4 <uxListRemove>:

UBaseType_t uxListRemove( ListItem_t * const pxItemToRemove )
{
/* The list item knows which list it is in.  Obtain the list from the list
 * item. */
    List_t * const pxList = pxItemToRemove->pxContainer;
8000c3d4:	490c                	lw	a1,16(a0)

    pxItemToRemove->pxNext->pxPrevious = pxItemToRemove->pxPrevious;
8000c3d6:	4510                	lw	a2,8(a0)
8000c3d8:	4154                	lw	a3,4(a0)

    /* Only used during decision coverage testing. */
    mtCOVERAGE_TEST_DELAY();

    /* Make sure the index is left pointing to a valid item. */
    if( pxList->pxIndex == pxItemToRemove )
8000c3da:	41d8                	lw	a4,4(a1)
    pxItemToRemove->pxNext->pxPrevious = pxItemToRemove->pxPrevious;
8000c3dc:	c690                	sw	a2,8(a3)
    pxItemToRemove->pxPrevious->pxNext = pxItemToRemove->pxNext;
8000c3de:	c254                	sw	a3,4(a2)
    if( pxList->pxIndex == pxItemToRemove )
8000c3e0:	00a71363          	bne	a4,a0,8000c3e6 <.LBB4_2>
    {
        pxList->pxIndex = pxItemToRemove->pxPrevious;
8000c3e4:	c1d0                	sw	a2,4(a1)

8000c3e6 <.LBB4_2>:
    else
    {
        mtCOVERAGE_TEST_MARKER();
    }

    pxItemToRemove->pxContainer = NULL;
8000c3e6:	00052823          	sw	zero,16(a0)
    ( pxList->uxNumberOfItems )--;
8000c3ea:	4188                	lw	a0,0(a1)
8000c3ec:	157d                	add	a0,a0,-1
8000c3ee:	c188                	sw	a0,0(a1)

    return pxList->uxNumberOfItems;
8000c3f0:	4188                	lw	a0,0(a1)
8000c3f2:	8082                	ret

Disassembly of section .text.xQueueGenericSend:

8000c3f4 <xQueueGenericSend>:
{
8000c3f4:	7179                	add	sp,sp,-48
8000c3f6:	d606                	sw	ra,44(sp)
8000c3f8:	d422                	sw	s0,40(sp)
8000c3fa:	d226                	sw	s1,36(sp)
8000c3fc:	d04a                	sw	s2,32(sp)
8000c3fe:	ce4e                	sw	s3,28(sp)
8000c400:	cc52                	sw	s4,24(sp)
8000c402:	ca56                	sw	s5,20(sp)
8000c404:	c85a                	sw	s6,16(sp)
8000c406:	c65e                	sw	s7,12(sp)
8000c408:	c432                	sw	a2,8(sp)
    configASSERT( pxQueue );
8000c40a:	c515                	beqz	a0,8000c436 <.LBB6_8>
8000c40c:	8ab6                	mv	s5,a3
8000c40e:	8baa                	mv	s7,a0
    configASSERT( !( ( pvItemToQueue == NULL ) && ( pxQueue->uxItemSize != ( UBaseType_t ) 0U ) ) );
8000c410:	c59d                	beqz	a1,8000c43e <.LBB6_10>

8000c412 <.LBB6_2>:
8000c412:	4509                	li	a0,2
    configASSERT( !( ( xCopyPosition == queueOVERWRITE ) && ( pxQueue->uxLength != 1 ) ) );
8000c414:	00aa9763          	bne	s5,a0,8000c422 <.LBB6_4>
8000c418:	03cba503          	lw	a0,60(s7)
8000c41c:	4685                	li	a3,1
8000c41e:	0cd51c63          	bne	a0,a3,8000c4f6 <.LBB6_29>

8000c422 <.LBB6_4>:
8000c422:	84b2                	mv	s1,a2
8000c424:	892e                	mv	s2,a1
            configASSERT( !( ( xTaskGetSchedulerState() == taskSCHEDULER_SUSPENDED ) && ( xTicksToWait != 0 ) ) );
8000c426:	e7bfb0ef          	jal	800082a0 <xTaskGetSchedulerState>
8000c42a:	e10d                	bnez	a0,8000c44c <.LBB6_13>
8000c42c:	c085                	beqz	s1,8000c44c <.LBB6_13>
8000c42e:	30047073          	csrc	mstatus,8
8000c432:	9002                	ebreak

8000c434 <.LBB6_7>:
8000c434:	a001                	j	8000c434 <.LBB6_7>

8000c436 <.LBB6_8>:
    configASSERT( pxQueue );
8000c436:	30047073          	csrc	mstatus,8
8000c43a:	9002                	ebreak

8000c43c <.LBB6_9>:
8000c43c:	a001                	j	8000c43c <.LBB6_9>

8000c43e <.LBB6_10>:
    configASSERT( !( ( pvItemToQueue == NULL ) && ( pxQueue->uxItemSize != ( UBaseType_t ) 0U ) ) );
8000c43e:	040ba503          	lw	a0,64(s7)
8000c442:	d961                	beqz	a0,8000c412 <.LBB6_2>
8000c444:	30047073          	csrc	mstatus,8
8000c448:	9002                	ebreak

8000c44a <.LBB6_12>:
8000c44a:	a001                	j	8000c44a <.LBB6_12>

8000c44c <.LBB6_13>:
        taskENTER_CRITICAL();
8000c44c:	b4bfb0ef          	jal	80007f96 <vTaskEnterCritical>
            if( ( pxQueue->uxMessagesWaiting < pxQueue->uxLength ) || ( xCopyPosition == queueOVERWRITE ) )
8000c450:	038ba503          	lw	a0,56(s7)
8000c454:	4589                	li	a1,2
8000c456:	0aba8463          	beq	s5,a1,8000c4fe <.LBB6_31>
8000c45a:	03cba583          	lw	a1,60(s7)
8000c45e:	0ab56063          	bltu	a0,a1,8000c4fe <.LBB6_31>
8000c462:	4b01                	li	s6,0
8000c464:	010b8993          	add	s3,s7,16
8000c468:	0ff00a13          	li	s4,255
8000c46c:	a829                	j	8000c486 <.LBB6_18>

8000c46e <.LBB6_16>:
                prvUnlockQueue( pxQueue );
8000c46e:	855e                	mv	a0,s7
8000c470:	e58fb0ef          	jal	80007ac8 <prvUnlockQueue>
                ( void ) xTaskResumeAll();
8000c474:	2611                	jal	8000c778 <xTaskResumeAll>

8000c476 <.LBB6_17>:
        taskENTER_CRITICAL();
8000c476:	b21fb0ef          	jal	80007f96 <vTaskEnterCritical>
            if( ( pxQueue->uxMessagesWaiting < pxQueue->uxLength ) || ( xCopyPosition == queueOVERWRITE ) )
8000c47a:	038ba503          	lw	a0,56(s7)
8000c47e:	03cba583          	lw	a1,60(s7)
8000c482:	06b56e63          	bltu	a0,a1,8000c4fe <.LBB6_31>

8000c486 <.LBB6_18>:
                if( xTicksToWait == ( TickType_t ) 0 )
8000c486:	4522                	lw	a0,8(sp)
8000c488:	c145                	beqz	a0,8000c528 <.LBB6_37>
                else if( xEntryTimeSet == pdFALSE )
8000c48a:	000b1663          	bnez	s6,8000c496 <.LBB6_21>
                    vTaskInternalSetTimeOutState( &xTimeOut );
8000c48e:	850a                	mv	a0,sp
8000c490:	d5dfb0ef          	jal	800081ec <vTaskInternalSetTimeOutState>
8000c494:	4b05                	li	s6,1

8000c496 <.LBB6_21>:
        taskEXIT_CRITICAL();
8000c496:	247d                	jal	8000c744 <vTaskExitCritical>
        vTaskSuspendAll();
8000c498:	2cd1                	jal	8000c76c <vTaskSuspendAll>
        prvLockQueue( pxQueue );
8000c49a:	afdfb0ef          	jal	80007f96 <vTaskEnterCritical>
8000c49e:	044bc503          	lbu	a0,68(s7)
8000c4a2:	05450163          	beq	a0,s4,8000c4e4 <.LBB6_27>
8000c4a6:	045bc503          	lbu	a0,69(s7)
8000c4aa:	05450363          	beq	a0,s4,8000c4f0 <.LBB6_28>

8000c4ae <.LBB6_23>:
8000c4ae:	2c59                	jal	8000c744 <vTaskExitCritical>
        if( xTaskCheckForTimeOut( &xTimeOut, &xTicksToWait ) == pdFALSE )
8000c4b0:	850a                	mv	a0,sp
8000c4b2:	002c                	add	a1,sp,8
8000c4b4:	d47fb0ef          	jal	800081fa <xTaskCheckForTimeOut>
8000c4b8:	e935                	bnez	a0,8000c52c <.LBB6_38>
    taskENTER_CRITICAL();
8000c4ba:	addfb0ef          	jal	80007f96 <vTaskEnterCritical>
        if( pxQueue->uxMessagesWaiting == pxQueue->uxLength )
8000c4be:	038ba483          	lw	s1,56(s7)
8000c4c2:	03cba403          	lw	s0,60(s7)
    taskEXIT_CRITICAL();
8000c4c6:	2cbd                	jal	8000c744 <vTaskExitCritical>
            if( prvIsQueueFull( pxQueue ) != pdFALSE )
8000c4c8:	fa8493e3          	bne	s1,s0,8000c46e <.LBB6_16>
                vTaskPlaceOnEventList( &( pxQueue->xTasksWaitingToSend ), xTicksToWait );
8000c4cc:	45a2                	lw	a1,8(sp)
8000c4ce:	854e                	mv	a0,s3
8000c4d0:	cb1fb0ef          	jal	80008180 <vTaskPlaceOnEventList>
                prvUnlockQueue( pxQueue );
8000c4d4:	855e                	mv	a0,s7
8000c4d6:	df2fb0ef          	jal	80007ac8 <prvUnlockQueue>
                if( xTaskResumeAll() == pdFALSE )
8000c4da:	2c79                	jal	8000c778 <xTaskResumeAll>
8000c4dc:	fd49                	bnez	a0,8000c476 <.LBB6_17>
                    portYIELD_WITHIN_API();
8000c4de:	00000073          	ecall
8000c4e2:	bf51                	j	8000c476 <.LBB6_17>

8000c4e4 <.LBB6_27>:
        prvLockQueue( pxQueue );
8000c4e4:	040b8223          	sb	zero,68(s7)
8000c4e8:	045bc503          	lbu	a0,69(s7)
8000c4ec:	fd4511e3          	bne	a0,s4,8000c4ae <.LBB6_23>

8000c4f0 <.LBB6_28>:
8000c4f0:	040b82a3          	sb	zero,69(s7)
8000c4f4:	bf6d                	j	8000c4ae <.LBB6_23>

8000c4f6 <.LBB6_29>:
    configASSERT( !( ( xCopyPosition == queueOVERWRITE ) && ( pxQueue->uxLength != 1 ) ) );
8000c4f6:	30047073          	csrc	mstatus,8
8000c4fa:	9002                	ebreak

8000c4fc <.LBB6_30>:
8000c4fc:	a001                	j	8000c4fc <.LBB6_30>

8000c4fe <.LBB6_31>:
                        xYieldRequired = prvCopyDataToQueue( pxQueue, pvItemToQueue, xCopyPosition );
8000c4fe:	855e                	mv	a0,s7
8000c500:	85ca                	mv	a1,s2
8000c502:	8656                	mv	a2,s5
8000c504:	d36fb0ef          	jal	80007a3a <prvCopyDataToQueue>
                        if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToReceive ) ) == pdFALSE )
8000c508:	024ba583          	lw	a1,36(s7)
8000c50c:	c981                	beqz	a1,8000c51c <.LBB6_34>
8000c50e:	024b8513          	add	a0,s7,36
                            if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToReceive ) ) != pdFALSE )
8000c512:	2bad                	jal	8000ca8c <xTaskRemoveFromEventList>
8000c514:	c519                	beqz	a0,8000c522 <.LBB6_36>
                                queueYIELD_IF_USING_PREEMPTION();
8000c516:	00000073          	ecall
8000c51a:	a021                	j	8000c522 <.LBB6_36>

8000c51c <.LBB6_34>:
                        else if( xYieldRequired != pdFALSE )
8000c51c:	c119                	beqz	a0,8000c522 <.LBB6_36>
                            queueYIELD_IF_USING_PREEMPTION();
8000c51e:	00000073          	ecall

8000c522 <.LBB6_36>:
                taskEXIT_CRITICAL();
8000c522:	240d                	jal	8000c744 <vTaskExitCritical>
8000c524:	4505                	li	a0,1
8000c526:	a801                	j	8000c536 <.LBB6_40>

8000c528 <.LBB6_37>:
                    taskEXIT_CRITICAL();
8000c528:	2c31                	jal	8000c744 <vTaskExitCritical>
8000c52a:	a029                	j	8000c534 <.LBB6_39>

8000c52c <.LBB6_38>:
            prvUnlockQueue( pxQueue );
8000c52c:	855e                	mv	a0,s7
8000c52e:	d9afb0ef          	jal	80007ac8 <prvUnlockQueue>
            ( void ) xTaskResumeAll();
8000c532:	2499                	jal	8000c778 <xTaskResumeAll>

8000c534 <.LBB6_39>:
8000c534:	4501                	li	a0,0

8000c536 <.LBB6_40>:
8000c536:	50b2                	lw	ra,44(sp)
8000c538:	5422                	lw	s0,40(sp)
8000c53a:	5492                	lw	s1,36(sp)
8000c53c:	5902                	lw	s2,32(sp)
8000c53e:	49f2                	lw	s3,28(sp)
8000c540:	4a62                	lw	s4,24(sp)
8000c542:	4ad2                	lw	s5,20(sp)
8000c544:	4b42                	lw	s6,16(sp)
8000c546:	4bb2                	lw	s7,12(sp)
}
8000c548:	6145                	add	sp,sp,48
8000c54a:	8082                	ret

Disassembly of section .text.xQueueCreateCountingSemaphore:

8000c54c <xQueueCreateCountingSemaphore>:
    {
8000c54c:	1141                	add	sp,sp,-16
8000c54e:	c606                	sw	ra,12(sp)
8000c550:	c422                	sw	s0,8(sp)
8000c552:	c226                	sw	s1,4(sp)
        if( ( uxMaxCount != 0 ) &&
8000c554:	c91d                	beqz	a0,8000c58a <.LBB9_5>
8000c556:	842e                	mv	s0,a1
8000c558:	84aa                	mv	s1,a0
8000c55a:	02b56863          	bltu	a0,a1,8000c58a <.LBB9_5>
            pxNewQueue = ( Queue_t * ) pvPortMalloc( sizeof( Queue_t ) + xQueueSizeInBytes ); /*lint !e9087 !e9079 see comment above. */
8000c55e:	05000513          	li	a0,80
8000c562:	393d                	jal	8000c1a0 <pvPortMalloc>
            if( pxNewQueue != NULL )
8000c564:	cd11                	beqz	a0,8000c580 <.LBB9_4>
8000c566:	c108                	sw	a0,0(a0)
    pxNewQueue->uxLength = uxQueueLength;
8000c568:	dd44                	sw	s1,60(a0)
    pxNewQueue->uxItemSize = uxItemSize;
8000c56a:	04052023          	sw	zero,64(a0)
    ( void ) xQueueGenericReset( pxNewQueue, pdTRUE );
8000c56e:	4585                	li	a1,1
8000c570:	84aa                	mv	s1,a0
8000c572:	a80fb0ef          	jal	800077f2 <xQueueGenericReset>
8000c576:	8526                	mv	a0,s1
8000c578:	4589                	li	a1,2
            pxNewQueue->ucQueueType = ucQueueType;
8000c57a:	04b48623          	sb	a1,76(s1)
                ( ( Queue_t * ) xHandle )->uxMessagesWaiting = uxInitialCount;
8000c57e:	dc80                	sw	s0,56(s1)

8000c580 <.LBB9_4>:
8000c580:	40b2                	lw	ra,12(sp)
8000c582:	4422                	lw	s0,8(sp)
8000c584:	4492                	lw	s1,4(sp)
        return xHandle;
8000c586:	0141                	add	sp,sp,16
8000c588:	8082                	ret

8000c58a <.LBB9_5>:
            configASSERT( xHandle );
8000c58a:	30047073          	csrc	mstatus,8
8000c58e:	9002                	ebreak

8000c590 <.LBB9_6>:
8000c590:	a001                	j	8000c590 <.LBB9_6>

Disassembly of section .text.xQueueGenericSendFromISR:

8000c592 <xQueueGenericSendFromISR>:
{
8000c592:	1141                	add	sp,sp,-16
8000c594:	c606                	sw	ra,12(sp)
8000c596:	c422                	sw	s0,8(sp)
8000c598:	c226                	sw	s1,4(sp)
8000c59a:	c04a                	sw	s2,0(sp)
    configASSERT( pxQueue );
8000c59c:	cd01                	beqz	a0,8000c5b4 <.LBB12_5>
    configASSERT( !( ( pvItemToQueue == NULL ) && ( pxQueue->uxItemSize != ( UBaseType_t ) 0U ) ) );
8000c59e:	c1bd                	beqz	a1,8000c604 <.LBB12_14>

8000c5a0 <.LBB12_2>:
8000c5a0:	4709                	li	a4,2
    configASSERT( !( ( xCopyPosition == queueOVERWRITE ) && ( pxQueue->uxLength != 1 ) ) );
8000c5a2:	00e69d63          	bne	a3,a4,8000c5bc <.LBB12_7>
8000c5a6:	5d58                	lw	a4,60(a0)
8000c5a8:	4785                	li	a5,1
8000c5aa:	06f71363          	bne	a4,a5,8000c610 <.LBB12_17>
        if( ( pxQueue->uxMessagesWaiting < pxQueue->uxLength ) || ( xCopyPosition == queueOVERWRITE ) )
8000c5ae:	03852003          	lw	zero,56(a0)
8000c5b2:	a809                	j	8000c5c4 <.LBB12_8>

8000c5b4 <.LBB12_5>:
    configASSERT( pxQueue );
8000c5b4:	30047073          	csrc	mstatus,8
8000c5b8:	9002                	ebreak

8000c5ba <.LBB12_6>:
8000c5ba:	a001                	j	8000c5ba <.LBB12_6>

8000c5bc <.LBB12_7>:
        if( ( pxQueue->uxMessagesWaiting < pxQueue->uxLength ) || ( xCopyPosition == queueOVERWRITE ) )
8000c5bc:	5d18                	lw	a4,56(a0)
8000c5be:	5d5c                	lw	a5,60(a0)
8000c5c0:	04f77c63          	bgeu	a4,a5,8000c618 <.LBB12_19>

8000c5c4 <.LBB12_8>:
8000c5c4:	8932                	mv	s2,a2
            const int8_t cTxLock = pxQueue->cTxLock;
8000c5c6:	04554483          	lbu	s1,69(a0)
            const UBaseType_t uxPreviousMessagesWaiting = pxQueue->uxMessagesWaiting;
8000c5ca:	03852003          	lw	zero,56(a0)
8000c5ce:	842a                	mv	s0,a0
            ( void ) prvCopyDataToQueue( pxQueue, pvItemToQueue, xCopyPosition );
8000c5d0:	8636                	mv	a2,a3
8000c5d2:	c68fb0ef          	jal	80007a3a <prvCopyDataToQueue>
8000c5d6:	07f00513          	li	a0,127
8000c5da:	04a48163          	beq	s1,a0,8000c61c <.LBB12_20>
8000c5de:	0ff00513          	li	a0,255
8000c5e2:	04a49163          	bne	s1,a0,8000c624 <.LBB12_22>
                        if( listLIST_IS_EMPTY( &( pxQueue->xTasksWaitingToReceive ) ) == pdFALSE )
8000c5e6:	504c                	lw	a1,36(s0)
8000c5e8:	4505                	li	a0,1
8000c5ea:	c1a9                	beqz	a1,8000c62c <.LBB12_24>
8000c5ec:	02440513          	add	a0,s0,36
                            if( xTaskRemoveFromEventList( &( pxQueue->xTasksWaitingToReceive ) ) != pdFALSE )
8000c5f0:	2971                	jal	8000ca8c <xTaskRemoveFromEventList>
8000c5f2:	02090c63          	beqz	s2,8000c62a <.LBB12_23>
8000c5f6:	85aa                	mv	a1,a0
8000c5f8:	4505                	li	a0,1
8000c5fa:	c98d                	beqz	a1,8000c62c <.LBB12_24>
8000c5fc:	4505                	li	a0,1
                                    *pxHigherPriorityTaskWoken = pdTRUE;
8000c5fe:	00a92023          	sw	a0,0(s2)
8000c602:	a02d                	j	8000c62c <.LBB12_24>

8000c604 <.LBB12_14>:
    configASSERT( !( ( pvItemToQueue == NULL ) && ( pxQueue->uxItemSize != ( UBaseType_t ) 0U ) ) );
8000c604:	4138                	lw	a4,64(a0)
8000c606:	df49                	beqz	a4,8000c5a0 <.LBB12_2>
8000c608:	30047073          	csrc	mstatus,8
8000c60c:	9002                	ebreak

8000c60e <.LBB12_16>:
8000c60e:	a001                	j	8000c60e <.LBB12_16>

8000c610 <.LBB12_17>:
    configASSERT( !( ( xCopyPosition == queueOVERWRITE ) && ( pxQueue->uxLength != 1 ) ) );
8000c610:	30047073          	csrc	mstatus,8
8000c614:	9002                	ebreak

8000c616 <.LBB12_18>:
8000c616:	a001                	j	8000c616 <.LBB12_18>

8000c618 <.LBB12_19>:
8000c618:	4501                	li	a0,0
8000c61a:	a809                	j	8000c62c <.LBB12_24>

8000c61c <.LBB12_20>:
                configASSERT( cTxLock != queueINT8_MAX );
8000c61c:	30047073          	csrc	mstatus,8
8000c620:	9002                	ebreak

8000c622 <.LBB12_21>:
8000c622:	a001                	j	8000c622 <.LBB12_21>

8000c624 <.LBB12_22>:
                pxQueue->cTxLock = ( int8_t ) ( cTxLock + 1 );
8000c624:	0485                	add	s1,s1,1
8000c626:	049402a3          	sb	s1,69(s0)

8000c62a <.LBB12_23>:
8000c62a:	4505                	li	a0,1

8000c62c <.LBB12_24>:
8000c62c:	40b2                	lw	ra,12(sp)
8000c62e:	4422                	lw	s0,8(sp)
8000c630:	4492                	lw	s1,4(sp)
8000c632:	4902                	lw	s2,0(sp)
    return xReturn;
8000c634:	0141                	add	sp,sp,16
8000c636:	8082                	ret

Disassembly of section .text.vTaskDelete:

8000c638 <vTaskDelete>:
    {
8000c638:	1141                	add	sp,sp,-16
8000c63a:	c606                	sw	ra,12(sp)
8000c63c:	c422                	sw	s0,8(sp)
8000c63e:	c226                	sw	s1,4(sp)
        portDISABLE_INTERRUPTS();
8000c640:	30047073          	csrc	mstatus,8
        if( xSchedulerRunning != pdFALSE )
8000c644:	6181a583          	lw	a1,1560(gp) # 81988 <xSchedulerRunning>
8000c648:	842a                	mv	s0,a0
8000c64a:	c981                	beqz	a1,8000c65a <.LBB1_2>
            ( pxCurrentTCB->uxCriticalNesting )++;
8000c64c:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000c650:	41f0                	lw	a2,68(a1)
8000c652:	0605                	add	a2,a2,1
8000c654:	c1f0                	sw	a2,68(a1)
            if( pxCurrentTCB->uxCriticalNesting == 1 )
8000c656:	6801a003          	lw	zero,1664(gp) # 819f0 <pxCurrentTCB>

8000c65a <.LBB1_2>:
            pxTCB = prvGetTCBFromHandle( xTaskToDelete );
8000c65a:	e019                	bnez	s0,8000c660 <.LBB1_4>
8000c65c:	6801a403          	lw	s0,1664(gp) # 819f0 <pxCurrentTCB>

8000c660 <.LBB1_4>:
            if( uxListRemove( &( pxTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
8000c660:	00440493          	add	s1,s0,4
8000c664:	8526                	mv	a0,s1
8000c666:	33bd                	jal	8000c3d4 <uxListRemove>
8000c668:	e505                	bnez	a0,8000c690 <.LBB1_7>
                taskRESET_READY_PRIORITY( pxTCB->uxPriority );
8000c66a:	5448                	lw	a0,44(s0)
8000c66c:	45d1                	li	a1,20
8000c66e:	02b505b3          	mul	a1,a0,a1
8000c672:	e8418613          	add	a2,gp,-380 # 811f4 <pxReadyTasksLists>
8000c676:	95b2                	add	a1,a1,a2
8000c678:	418c                	lw	a1,0(a1)
8000c67a:	e999                	bnez	a1,8000c690 <.LBB1_7>
8000c67c:	6441a603          	lw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
8000c680:	4685                	li	a3,1
8000c682:	00a69533          	sll	a0,a3,a0
8000c686:	fff54513          	not	a0,a0
8000c68a:	8d71                	and	a0,a0,a2
8000c68c:	64a1a223          	sw	a0,1604(gp) # 819b4 <uxTopReadyPriority>

8000c690 <.LBB1_7>:
            if( listLIST_ITEM_CONTAINER( &( pxTCB->xEventListItem ) ) != NULL )
8000c690:	5408                	lw	a0,40(s0)
8000c692:	c501                	beqz	a0,8000c69a <.LBB1_9>
8000c694:	01840513          	add	a0,s0,24
                ( void ) uxListRemove( &( pxTCB->xEventListItem ) );
8000c698:	3b35                	jal	8000c3d4 <uxListRemove>

8000c69a <.LBB1_9>:
            uxTaskNumber++;
8000c69a:	6481a583          	lw	a1,1608(gp) # 819b8 <uxTaskNumber>
8000c69e:	0585                	add	a1,a1,1
8000c6a0:	64b1a423          	sw	a1,1608(gp) # 819b8 <uxTaskNumber>
            if( pxTCB == pxCurrentTCB )
8000c6a4:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c6a8:	02a40463          	beq	s0,a0,8000c6d0 <.LBB1_12>
                --uxCurrentNumberOfTasks;
8000c6ac:	6541a583          	lw	a1,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
8000c6b0:	15fd                	add	a1,a1,-1
8000c6b2:	64b1aa23          	sw	a1,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
                vPortFreeStack( pxTCB->pxStack );
8000c6b6:	5808                	lw	a0,48(s0)
8000c6b8:	3185                	jal	8000c318 <vPortFree>
                vPortFree( pxTCB );
8000c6ba:	8522                	mv	a0,s0
8000c6bc:	39b1                	jal	8000c318 <vPortFree>
    if( listLIST_IS_EMPTY( pxDelayedTaskList ) != pdFALSE )
8000c6be:	6781a583          	lw	a1,1656(gp) # 819e8 <pxDelayedTaskList>
8000c6c2:	418c                	lw	a1,0(a1)
8000c6c4:	c18d                	beqz	a1,8000c6e6 <.LBB1_13>
        xNextTaskUnblockTime = listGET_ITEM_VALUE_OF_HEAD_ENTRY( pxDelayedTaskList );
8000c6c6:	6781a503          	lw	a0,1656(gp) # 819e8 <pxDelayedTaskList>
8000c6ca:	4548                	lw	a0,12(a0)
8000c6cc:	4108                	lw	a0,0(a0)
8000c6ce:	a829                	j	8000c6e8 <.LBB1_14>

8000c6d0 <.LBB1_12>:
                vListInsertEnd( &xTasksWaitingTermination, &( pxTCB->xStateListItem ) );
8000c6d0:	53418513          	add	a0,gp,1332 # 818a4 <xTasksWaitingTermination>
8000c6d4:	85a6                	mv	a1,s1
8000c6d6:	8d8fb0ef          	jal	800077ae <vListInsertEnd>
                ++uxDeletedTasksWaitingCleanUp;
8000c6da:	6501a583          	lw	a1,1616(gp) # 819c0 <uxDeletedTasksWaitingCleanUp>
8000c6de:	0585                	add	a1,a1,1
8000c6e0:	64b1a823          	sw	a1,1616(gp) # 819c0 <uxDeletedTasksWaitingCleanUp>
8000c6e4:	a021                	j	8000c6ec <.LBB1_15>

8000c6e6 <.LBB1_13>:
8000c6e6:	557d                	li	a0,-1

8000c6e8 <.LBB1_14>:
8000c6e8:	62a1a623          	sw	a0,1580(gp) # 8199c <xNextTaskUnblockTime>

8000c6ec <.LBB1_15>:
        if( xSchedulerRunning != pdFALSE )
8000c6ec:	6181a583          	lw	a1,1560(gp) # 81988 <xSchedulerRunning>
8000c6f0:	cd91                	beqz	a1,8000c70c <.LBB1_18>
            if( pxCurrentTCB->uxCriticalNesting > 0U )
8000c6f2:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000c6f6:	4270                	lw	a2,68(a2)
8000c6f8:	ca11                	beqz	a2,8000c70c <.LBB1_18>
                ( pxCurrentTCB->uxCriticalNesting )--;
8000c6fa:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000c6fe:	4274                	lw	a3,68(a2)
8000c700:	16fd                	add	a3,a3,-1
8000c702:	c274                	sw	a3,68(a2)
                if( pxCurrentTCB->uxCriticalNesting == 0U )
8000c704:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000c708:	41ec                	lw	a1,68(a1)
8000c70a:	c585                	beqz	a1,8000c732 <.LBB1_24>

8000c70c <.LBB1_18>:
        if( xSchedulerRunning != pdFALSE )
8000c70c:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
8000c710:	c509                	beqz	a0,8000c71a <.LBB1_20>

8000c712 <.LBB1_19>:
            if( pxTCB == pxCurrentTCB )
8000c712:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c716:	00a40763          	beq	s0,a0,8000c724 <.LBB1_21>

8000c71a <.LBB1_20>:
8000c71a:	40b2                	lw	ra,12(sp)
8000c71c:	4422                	lw	s0,8(sp)
8000c71e:	4492                	lw	s1,4(sp)
    }
8000c720:	0141                	add	sp,sp,16
8000c722:	8082                	ret

8000c724 <.LBB1_21>:
                configASSERT( uxSchedulerSuspended == 0 );
8000c724:	64c1a503          	lw	a0,1612(gp) # 819bc <uxSchedulerSuspended>
8000c728:	c919                	beqz	a0,8000c73e <.LBB1_25>
8000c72a:	30047073          	csrc	mstatus,8
8000c72e:	9002                	ebreak

8000c730 <.LBB1_23>:
8000c730:	a001                	j	8000c730 <.LBB1_23>

8000c732 <.LBB1_24>:
                    portENABLE_INTERRUPTS();
8000c732:	30046073          	csrs	mstatus,8
        if( xSchedulerRunning != pdFALSE )
8000c736:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
8000c73a:	fd61                	bnez	a0,8000c712 <.LBB1_19>
8000c73c:	bff9                	j	8000c71a <.LBB1_20>

8000c73e <.LBB1_25>:
                portYIELD_WITHIN_API();
8000c73e:	00000073          	ecall
8000c742:	bfe1                	j	8000c71a <.LBB1_20>

Disassembly of section .text.vTaskExitCritical:

8000c744 <vTaskExitCritical>:
        if( xSchedulerRunning != pdFALSE )
8000c744:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
8000c748:	cd11                	beqz	a0,8000c764 <.LBB3_3>
            if( pxCurrentTCB->uxCriticalNesting > 0U )
8000c74a:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000c74e:	41ec                	lw	a1,68(a1)
8000c750:	c991                	beqz	a1,8000c764 <.LBB3_3>
                ( pxCurrentTCB->uxCriticalNesting )--;
8000c752:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000c756:	41f0                	lw	a2,68(a1)
8000c758:	167d                	add	a2,a2,-1
8000c75a:	c1f0                	sw	a2,68(a1)
                if( pxCurrentTCB->uxCriticalNesting == 0U )
8000c75c:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c760:	4168                	lw	a0,68(a0)
8000c762:	c111                	beqz	a0,8000c766 <.LBB3_4>

8000c764 <.LBB3_3>:
    }
8000c764:	8082                	ret

8000c766 <.LBB3_4>:
                    portENABLE_INTERRUPTS();
8000c766:	30046073          	csrs	mstatus,8
    }
8000c76a:	8082                	ret

Disassembly of section .text.vTaskSuspendAll:

8000c76c <vTaskSuspendAll>:
    ++uxSchedulerSuspended;
8000c76c:	64c1a583          	lw	a1,1612(gp) # 819bc <uxSchedulerSuspended>
8000c770:	0585                	add	a1,a1,1
8000c772:	64b1a623          	sw	a1,1612(gp) # 819bc <uxSchedulerSuspended>
}
8000c776:	8082                	ret

Disassembly of section .text.xTaskResumeAll:

8000c778 <xTaskResumeAll>:
    configASSERT( uxSchedulerSuspended );
8000c778:	64c1a503          	lw	a0,1612(gp) # 819bc <uxSchedulerSuspended>
8000c77c:	30047073          	csrc	mstatus,8
8000c780:	c12d                	beqz	a0,8000c7e2 <.LBB7_10>
        if( xSchedulerRunning != pdFALSE )
8000c782:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
8000c786:	c901                	beqz	a0,8000c796 <.LBB7_3>
            ( pxCurrentTCB->uxCriticalNesting )++;
8000c788:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000c78c:	41f0                	lw	a2,68(a1)
8000c78e:	0605                	add	a2,a2,1
8000c790:	c1f0                	sw	a2,68(a1)
            if( pxCurrentTCB->uxCriticalNesting == 1 )
8000c792:	6801a003          	lw	zero,1664(gp) # 819f0 <pxCurrentTCB>

8000c796 <.LBB7_3>:
8000c796:	1141                	add	sp,sp,-16
8000c798:	c606                	sw	ra,12(sp)
8000c79a:	c422                	sw	s0,8(sp)
8000c79c:	c226                	sw	s1,4(sp)
8000c79e:	c04a                	sw	s2,0(sp)
        --uxSchedulerSuspended;
8000c7a0:	64c1a583          	lw	a1,1612(gp) # 819bc <uxSchedulerSuspended>
8000c7a4:	15fd                	add	a1,a1,-1
8000c7a6:	64b1a623          	sw	a1,1612(gp) # 819bc <uxSchedulerSuspended>
        if( uxSchedulerSuspended == ( UBaseType_t ) pdFALSE )
8000c7aa:	64c1a503          	lw	a0,1612(gp) # 819bc <uxSchedulerSuspended>
8000c7ae:	cd05                	beqz	a0,8000c7e6 <.LBB7_12>
8000c7b0:	4501                	li	a0,0

8000c7b2 <.LBB7_5>:
        if( xSchedulerRunning != pdFALSE )
8000c7b2:	6181a583          	lw	a1,1560(gp) # 81988 <xSchedulerRunning>
8000c7b6:	c185                	beqz	a1,8000c7d6 <.LBB7_9>
            if( pxCurrentTCB->uxCriticalNesting > 0U )
8000c7b8:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000c7bc:	4270                	lw	a2,68(a2)
8000c7be:	ce01                	beqz	a2,8000c7d6 <.LBB7_9>
                ( pxCurrentTCB->uxCriticalNesting )--;
8000c7c0:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000c7c4:	4274                	lw	a3,68(a2)
8000c7c6:	16fd                	add	a3,a3,-1
8000c7c8:	c274                	sw	a3,68(a2)
                if( pxCurrentTCB->uxCriticalNesting == 0U )
8000c7ca:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000c7ce:	41ec                	lw	a1,68(a1)
8000c7d0:	e199                	bnez	a1,8000c7d6 <.LBB7_9>
                    portENABLE_INTERRUPTS();
8000c7d2:	30046073          	csrs	mstatus,8

8000c7d6 <.LBB7_9>:
8000c7d6:	40b2                	lw	ra,12(sp)
8000c7d8:	4422                	lw	s0,8(sp)
8000c7da:	4492                	lw	s1,4(sp)
8000c7dc:	4902                	lw	s2,0(sp)
    return xAlreadyYielded;
8000c7de:	0141                	add	sp,sp,16
8000c7e0:	8082                	ret

8000c7e2 <.LBB7_10>:
    configASSERT( uxSchedulerSuspended );
8000c7e2:	9002                	ebreak

8000c7e4 <.LBB7_11>:
8000c7e4:	a001                	j	8000c7e4 <.LBB7_11>

8000c7e6 <.LBB7_12>:
            if( uxCurrentNumberOfTasks > ( UBaseType_t ) 0U )
8000c7e6:	6541a503          	lw	a0,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
8000c7ea:	d561                	beqz	a0,8000c7b2 <.LBB7_5>
                while( listLIST_IS_EMPTY( &xPendingReadyList ) == pdFALSE )
8000c7ec:	55c1a503          	lw	a0,1372(gp) # 818cc <xPendingReadyList>
8000c7f0:	c54d                	beqz	a0,8000c89a <.LBB7_26>
8000c7f2:	55c18e13          	add	t3,gp,1372 # 818cc <xPendingReadyList>
8000c7f6:	4385                	li	t2,1
8000c7f8:	4851                	li	a6,20
8000c7fa:	e8418793          	add	a5,gp,-380 # 811f4 <pxReadyTasksLists>
8000c7fe:	a021                	j	8000c806 <.LBB7_16>

8000c800 <.LBB7_15>:
8000c800:	55c1a503          	lw	a0,1372(gp) # 818cc <xPendingReadyList>
8000c804:	cd3d                	beqz	a0,8000c882 <.LBB7_22>

8000c806 <.LBB7_16>:
                    pxTCB = listGET_OWNER_OF_HEAD_ENTRY( ( &xPendingReadyList ) ); /*lint !e9079 void * is used as this macro is used with timers and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
8000c806:	00ce2503          	lw	a0,12(t3)
8000c80a:	4548                	lw	a0,12(a0)
                    listREMOVE_ITEM( &( pxTCB->xEventListItem ) );
8000c80c:	5518                	lw	a4,40(a0)
8000c80e:	5104                	lw	s1,32(a0)
8000c810:	4d40                	lw	s0,28(a0)
8000c812:	4350                	lw	a2,4(a4)
8000c814:	01850593          	add	a1,a0,24
8000c818:	c404                	sw	s1,8(s0)
8000c81a:	c0c0                	sw	s0,4(s1)
8000c81c:	00b61363          	bne	a2,a1,8000c822 <.LBB7_18>
8000c820:	c344                	sw	s1,4(a4)

8000c822 <.LBB7_18>:
8000c822:	02052423          	sw	zero,40(a0)
8000c826:	430c                	lw	a1,0(a4)
8000c828:	15fd                	add	a1,a1,-1
8000c82a:	c30c                	sw	a1,0(a4)
                    listREMOVE_ITEM( &( pxTCB->xStateListItem ) );
8000c82c:	4944                	lw	s1,20(a0)
8000c82e:	4540                	lw	s0,12(a0)
8000c830:	450c                	lw	a1,8(a0)
8000c832:	40d0                	lw	a2,4(s1)
8000c834:	00450713          	add	a4,a0,4
8000c838:	c580                	sw	s0,8(a1)
8000c83a:	c04c                	sw	a1,4(s0)
8000c83c:	00e61363          	bne	a2,a4,8000c842 <.LBB7_20>
8000c840:	c0c0                	sw	s0,4(s1)

8000c842 <.LBB7_20>:
8000c842:	408c                	lw	a1,0(s1)
8000c844:	15fd                	add	a1,a1,-1
8000c846:	c08c                	sw	a1,0(s1)
                    prvAddTaskToReadyList( pxTCB );
8000c848:	554c                	lw	a1,44(a0)
8000c84a:	6441a603          	lw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
8000c84e:	00b394b3          	sll	s1,t2,a1
8000c852:	8e45                	or	a2,a2,s1
8000c854:	64c1a223          	sw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
8000c858:	03058633          	mul	a2,a1,a6
8000c85c:	963e                	add	a2,a2,a5
8000c85e:	4244                	lw	s1,4(a2)
8000c860:	4480                	lw	s0,8(s1)
8000c862:	c504                	sw	s1,8(a0)
8000c864:	c540                	sw	s0,12(a0)
8000c866:	c058                	sw	a4,4(s0)
8000c868:	c498                	sw	a4,8(s1)
8000c86a:	c950                	sw	a2,20(a0)
8000c86c:	4208                	lw	a0,0(a2)
8000c86e:	0505                	add	a0,a0,1
8000c870:	c208                	sw	a0,0(a2)
                    if( pxTCB->uxPriority >= pxCurrentTCB->uxPriority )
8000c872:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c876:	5548                	lw	a0,44(a0)
8000c878:	f8a5e4e3          	bltu	a1,a0,8000c800 <.LBB7_15>
                        xYieldPending = pdTRUE;
8000c87c:	6071a423          	sw	t2,1544(gp) # 81978 <xYieldPending>
8000c880:	b741                	j	8000c800 <.LBB7_15>

8000c882 <.LBB7_22>:
    if( listLIST_IS_EMPTY( pxDelayedTaskList ) != pdFALSE )
8000c882:	6781a583          	lw	a1,1656(gp) # 819e8 <pxDelayedTaskList>
8000c886:	418c                	lw	a1,0(a1)
8000c888:	c591                	beqz	a1,8000c894 <.LBB7_24>
        xNextTaskUnblockTime = listGET_ITEM_VALUE_OF_HEAD_ENTRY( pxDelayedTaskList );
8000c88a:	6781a503          	lw	a0,1656(gp) # 819e8 <pxDelayedTaskList>
8000c88e:	4548                	lw	a0,12(a0)
8000c890:	4108                	lw	a0,0(a0)
8000c892:	a011                	j	8000c896 <.LBB7_25>

8000c894 <.LBB7_24>:
8000c894:	557d                	li	a0,-1

8000c896 <.LBB7_25>:
8000c896:	62a1a623          	sw	a0,1580(gp) # 8199c <xNextTaskUnblockTime>

8000c89a <.LBB7_26>:
                    TickType_t xPendedCounts = xPendedTicks; /* Non-volatile copy. */
8000c89a:	61c1a403          	lw	s0,1564(gp) # 8198c <xPendedTicks>
                    if( xPendedCounts > ( TickType_t ) 0U )
8000c89e:	cc01                	beqz	s0,8000c8b6 <.LBB7_32>
8000c8a0:	4485                	li	s1,1
8000c8a2:	a019                	j	8000c8a8 <.LBB7_29>

8000c8a4 <.LBB7_28>:
                            --xPendedCounts;
8000c8a4:	147d                	add	s0,s0,-1
                        } while( xPendedCounts > ( TickType_t ) 0U );
8000c8a6:	c411                	beqz	s0,8000c8b2 <.LBB7_31>

8000c8a8 <.LBB7_29>:
                            if( xTaskIncrementTick() != pdFALSE )
8000c8a8:	2871                	jal	8000c944 <xTaskIncrementTick>
8000c8aa:	dd6d                	beqz	a0,8000c8a4 <.LBB7_28>
                                xYieldPending = pdTRUE;
8000c8ac:	6091a423          	sw	s1,1544(gp) # 81978 <xYieldPending>
8000c8b0:	bfd5                	j	8000c8a4 <.LBB7_28>

8000c8b2 <.LBB7_31>:
                        xPendedTicks = 0;
8000c8b2:	6001ae23          	sw	zero,1564(gp) # 8198c <xPendedTicks>

8000c8b6 <.LBB7_32>:
                if( xYieldPending != pdFALSE )
8000c8b6:	6081a503          	lw	a0,1544(gp) # 81978 <xYieldPending>
8000c8ba:	ee050ce3          	beqz	a0,8000c7b2 <.LBB7_5>
                    taskYIELD_IF_USING_PREEMPTION();
8000c8be:	00000073          	ecall
8000c8c2:	4505                	li	a0,1
8000c8c4:	b5fd                	j	8000c7b2 <.LBB7_5>

Disassembly of section .text.prvIdleTask:

8000c8c6 <prvIdleTask>:
{
8000c8c6:	1101                	add	sp,sp,-32
8000c8c8:	ce06                	sw	ra,28(sp)
8000c8ca:	cc22                	sw	s0,24(sp)
8000c8cc:	ca26                	sw	s1,20(sp)
8000c8ce:	c84a                	sw	s2,16(sp)
8000c8d0:	c64e                	sw	s3,12(sp)
8000c8d2:	c452                	sw	s4,8(sp)
8000c8d4:	c256                	sw	s5,4(sp)
8000c8d6:	a029                	j	8000c8e0 <.LBB18_2>

8000c8d8 <.LBB18_1>:
                vPortFreeStack( pxTCB->pxStack );
8000c8d8:	5808                	lw	a0,48(s0)
8000c8da:	3c3d                	jal	8000c318 <vPortFree>
                vPortFree( pxTCB );
8000c8dc:	8522                	mv	a0,s0
8000c8de:	3c2d                	jal	8000c318 <vPortFree>

8000c8e0 <.LBB18_2>:
            while( uxDeletedTasksWaitingCleanUp > ( UBaseType_t ) 0U )
8000c8e0:	6501a503          	lw	a0,1616(gp) # 819c0 <uxDeletedTasksWaitingCleanUp>
8000c8e4:	dd75                	beqz	a0,8000c8e0 <.LBB18_2>
        portDISABLE_INTERRUPTS();
8000c8e6:	30047073          	csrc	mstatus,8
        if( xSchedulerRunning != pdFALSE )
8000c8ea:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
8000c8ee:	c901                	beqz	a0,8000c8fe <.LBB18_5>
            ( pxCurrentTCB->uxCriticalNesting )++;
8000c8f0:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c8f4:	416c                	lw	a1,68(a0)
8000c8f6:	0585                	add	a1,a1,1
8000c8f8:	c16c                	sw	a1,68(a0)
            if( pxCurrentTCB->uxCriticalNesting == 1 )
8000c8fa:	6801a003          	lw	zero,1664(gp) # 819f0 <pxCurrentTCB>

8000c8fe <.LBB18_5>:
                    pxTCB = listGET_OWNER_OF_HEAD_ENTRY( ( &xTasksWaitingTermination ) ); /*lint !e9079 void * is used as this macro is used with timers and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
8000c8fe:	5401a503          	lw	a0,1344(gp) # 818b0 <xTasksWaitingTermination+0xc>
8000c902:	4540                	lw	s0,12(a0)
                    ( void ) uxListRemove( &( pxTCB->xStateListItem ) );
8000c904:	00440513          	add	a0,s0,4
8000c908:	34f1                	jal	8000c3d4 <uxListRemove>
                    --uxCurrentNumberOfTasks;
8000c90a:	6541a503          	lw	a0,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
8000c90e:	157d                	add	a0,a0,-1
8000c910:	64a1aa23          	sw	a0,1620(gp) # 819c4 <uxCurrentNumberOfTasks>
                    --uxDeletedTasksWaitingCleanUp;
8000c914:	6501a503          	lw	a0,1616(gp) # 819c0 <uxDeletedTasksWaitingCleanUp>
8000c918:	157d                	add	a0,a0,-1
8000c91a:	64a1a823          	sw	a0,1616(gp) # 819c0 <uxDeletedTasksWaitingCleanUp>
        if( xSchedulerRunning != pdFALSE )
8000c91e:	6181a503          	lw	a0,1560(gp) # 81988 <xSchedulerRunning>
8000c922:	d95d                	beqz	a0,8000c8d8 <.LBB18_1>
            if( pxCurrentTCB->uxCriticalNesting > 0U )
8000c924:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c928:	4168                	lw	a0,68(a0)
8000c92a:	d55d                	beqz	a0,8000c8d8 <.LBB18_1>
                ( pxCurrentTCB->uxCriticalNesting )--;
8000c92c:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c930:	416c                	lw	a1,68(a0)
8000c932:	15fd                	add	a1,a1,-1
8000c934:	c16c                	sw	a1,68(a0)
                if( pxCurrentTCB->uxCriticalNesting == 0U )
8000c936:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000c93a:	4168                	lw	a0,68(a0)
8000c93c:	fd51                	bnez	a0,8000c8d8 <.LBB18_1>
                    portENABLE_INTERRUPTS();
8000c93e:	30046073          	csrs	mstatus,8
8000c942:	bf59                	j	8000c8d8 <.LBB18_1>

Disassembly of section .text.xTaskIncrementTick:

8000c944 <xTaskIncrementTick>:
    if( uxSchedulerSuspended == ( UBaseType_t ) pdFALSE )
8000c944:	64c1a503          	lw	a0,1612(gp) # 819bc <uxSchedulerSuspended>
8000c948:	c901                	beqz	a0,8000c958 <.LBB20_3>
        ++xPendedTicks;
8000c94a:	61c1a603          	lw	a2,1564(gp) # 8198c <xPendedTicks>
8000c94e:	4501                	li	a0,0
8000c950:	0605                	add	a2,a2,1
8000c952:	60c1ae23          	sw	a2,1564(gp) # 8198c <xPendedTicks>

8000c956 <.LBB20_2>:
    return xSwitchRequired;
8000c956:	8082                	ret

8000c958 <.LBB20_3>:
        const TickType_t xConstTickCount = xTickCount + ( TickType_t ) 1;
8000c958:	6141a583          	lw	a1,1556(gp) # 81984 <xTickCount>
8000c95c:	00158e93          	add	t4,a1,1
        xTickCount = xConstTickCount;
8000c960:	61d1aa23          	sw	t4,1556(gp) # 81984 <xTickCount>
        if( xConstTickCount == ( TickType_t ) 0U ) /*lint !e774 'if' does not always evaluate to false as it is looking for an overflow. */
8000c964:	040e9363          	bnez	t4,8000c9aa <.LBB20_11>
            taskSWITCH_DELAYED_LISTS();
8000c968:	6781a603          	lw	a2,1656(gp) # 819e8 <pxDelayedTaskList>
8000c96c:	4210                	lw	a2,0(a2)
8000c96e:	c609                	beqz	a2,8000c978 <.LBB20_7>
8000c970:	30047073          	csrc	mstatus,8
8000c974:	9002                	ebreak

8000c976 <.LBB20_6>:
8000c976:	a001                	j	8000c976 <.LBB20_6>

8000c978 <.LBB20_7>:
8000c978:	6781a603          	lw	a2,1656(gp) # 819e8 <pxDelayedTaskList>
8000c97c:	6701a703          	lw	a4,1648(gp) # 819e0 <pxOverflowDelayedTaskList>
8000c980:	66e1ac23          	sw	a4,1656(gp) # 819e8 <pxDelayedTaskList>
8000c984:	66c1a823          	sw	a2,1648(gp) # 819e0 <pxOverflowDelayedTaskList>
8000c988:	6281a683          	lw	a3,1576(gp) # 81998 <xNumOfOverflows>
8000c98c:	0685                	add	a3,a3,1
8000c98e:	62d1a423          	sw	a3,1576(gp) # 81998 <xNumOfOverflows>
    if( listLIST_IS_EMPTY( pxDelayedTaskList ) != pdFALSE )
8000c992:	6781a503          	lw	a0,1656(gp) # 819e8 <pxDelayedTaskList>
8000c996:	4108                	lw	a0,0(a0)
8000c998:	c511                	beqz	a0,8000c9a4 <.LBB20_9>
        xNextTaskUnblockTime = listGET_ITEM_VALUE_OF_HEAD_ENTRY( pxDelayedTaskList );
8000c99a:	6781a503          	lw	a0,1656(gp) # 819e8 <pxDelayedTaskList>
8000c99e:	4548                	lw	a0,12(a0)
8000c9a0:	4108                	lw	a0,0(a0)
8000c9a2:	a011                	j	8000c9a6 <.LBB20_10>

8000c9a4 <.LBB20_9>:
8000c9a4:	557d                	li	a0,-1

8000c9a6 <.LBB20_10>:
8000c9a6:	62a1a623          	sw	a0,1580(gp) # 8199c <xNextTaskUnblockTime>

8000c9aa <.LBB20_11>:
        if( xConstTickCount >= xNextTaskUnblockTime )
8000c9aa:	62c1a503          	lw	a0,1580(gp) # 8199c <xNextTaskUnblockTime>
8000c9ae:	00aef463          	bgeu	t4,a0,8000c9b6 <.LBB20_13>
8000c9b2:	4501                	li	a0,0
8000c9b4:	a845                	j	8000ca64 <.LBB20_27>

8000c9b6 <.LBB20_13>:
                if( listLIST_IS_EMPTY( pxDelayedTaskList ) != pdFALSE )
8000c9b6:	6781a503          	lw	a0,1656(gp) # 819e8 <pxDelayedTaskList>
8000c9ba:	4108                	lw	a0,0(a0)
8000c9bc:	587d                	li	a6,-1
8000c9be:	c14d                	beqz	a0,8000ca60 <.LBB20_26>
8000c9c0:	4501                	li	a0,0
8000c9c2:	48d1                	li	a7,20
8000c9c4:	e8418e13          	add	t3,gp,-380 # 811f4 <pxReadyTasksLists>
8000c9c8:	a029                	j	8000c9d2 <.LBB20_16>

8000c9ca <.LBB20_15>:
8000c9ca:	6781a583          	lw	a1,1656(gp) # 819e8 <pxDelayedTaskList>
8000c9ce:	418c                	lw	a1,0(a1)
8000c9d0:	c9c1                	beqz	a1,8000ca60 <.LBB20_26>

8000c9d2 <.LBB20_16>:
                    pxTCB = listGET_OWNER_OF_HEAD_ENTRY( pxDelayedTaskList ); /*lint !e9079 void * is used as this macro is used with timers and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
8000c9d2:	6781a603          	lw	a2,1656(gp) # 819e8 <pxDelayedTaskList>
8000c9d6:	4650                	lw	a2,12(a2)
8000c9d8:	465c                	lw	a5,12(a2)
                    xItemValue = listGET_LIST_ITEM_VALUE( &( pxTCB->xStateListItem ) );
8000c9da:	43d0                	lw	a2,4(a5)
                    if( xConstTickCount < xItemValue )
8000c9dc:	08cee163          	bltu	t4,a2,8000ca5e <.LBB20_25>
                    listREMOVE_ITEM( &( pxTCB->xStateListItem ) );
8000c9e0:	4bd8                	lw	a4,20(a5)
8000c9e2:	47d0                	lw	a2,12(a5)
8000c9e4:	478c                	lw	a1,8(a5)
8000c9e6:	4354                	lw	a3,4(a4)
8000c9e8:	00478f13          	add	t5,a5,4
8000c9ec:	c590                	sw	a2,8(a1)
8000c9ee:	c24c                	sw	a1,4(a2)
8000c9f0:	01e69363          	bne	a3,t5,8000c9f6 <.LBB20_19>
8000c9f4:	c350                	sw	a2,4(a4)

8000c9f6 <.LBB20_19>:
8000c9f6:	430c                	lw	a1,0(a4)
8000c9f8:	15fd                	add	a1,a1,-1
8000c9fa:	c30c                	sw	a1,0(a4)
                    if( listLIST_ITEM_CONTAINER( &( pxTCB->xEventListItem ) ) != NULL )
8000c9fc:	5798                	lw	a4,40(a5)
8000c9fe:	c30d                	beqz	a4,8000ca20 <.LBB20_23>
                        listREMOVE_ITEM( &( pxTCB->xEventListItem ) );
8000ca00:	5390                	lw	a2,32(a5)
8000ca02:	4fcc                	lw	a1,28(a5)
8000ca04:	00472f83          	lw	t6,4(a4)
                    if( listLIST_ITEM_CONTAINER( &( pxTCB->xEventListItem ) ) != NULL )
8000ca08:	01878693          	add	a3,a5,24
                        listREMOVE_ITEM( &( pxTCB->xEventListItem ) );
8000ca0c:	c590                	sw	a2,8(a1)
8000ca0e:	c24c                	sw	a1,4(a2)
8000ca10:	00df9363          	bne	t6,a3,8000ca16 <.LBB20_22>
8000ca14:	c350                	sw	a2,4(a4)

8000ca16 <.LBB20_22>:
8000ca16:	0207a423          	sw	zero,40(a5)
8000ca1a:	430c                	lw	a1,0(a4)
8000ca1c:	15fd                	add	a1,a1,-1
8000ca1e:	c30c                	sw	a1,0(a4)

8000ca20 <.LBB20_23>:
                    prvAddTaskToReadyList( pxTCB );
8000ca20:	57cc                	lw	a1,44(a5)
8000ca22:	6441a603          	lw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
8000ca26:	4685                	li	a3,1
8000ca28:	00b696b3          	sll	a3,a3,a1
8000ca2c:	8e55                	or	a2,a2,a3
8000ca2e:	64c1a223          	sw	a2,1604(gp) # 819b4 <uxTopReadyPriority>
8000ca32:	03158633          	mul	a2,a1,a7
8000ca36:	9672                	add	a2,a2,t3
8000ca38:	4254                	lw	a3,4(a2)
8000ca3a:	4698                	lw	a4,8(a3)
8000ca3c:	c794                	sw	a3,8(a5)
8000ca3e:	c7d8                	sw	a4,12(a5)
8000ca40:	01e72223          	sw	t5,4(a4)
8000ca44:	01e6a423          	sw	t5,8(a3)
8000ca48:	cbd0                	sw	a2,20(a5)
8000ca4a:	4214                	lw	a3,0(a2)
8000ca4c:	0685                	add	a3,a3,1
8000ca4e:	c214                	sw	a3,0(a2)
                            if( pxTCB->uxPriority >= pxCurrentTCB->uxPriority )
8000ca50:	6801a603          	lw	a2,1664(gp) # 819f0 <pxCurrentTCB>
8000ca54:	5650                	lw	a2,44(a2)
8000ca56:	f6c5eae3          	bltu	a1,a2,8000c9ca <.LBB20_15>
8000ca5a:	4505                	li	a0,1
8000ca5c:	b7bd                	j	8000c9ca <.LBB20_15>

8000ca5e <.LBB20_25>:
8000ca5e:	8832                	mv	a6,a2

8000ca60 <.LBB20_26>:
8000ca60:	6301a623          	sw	a6,1580(gp) # 8199c <xNextTaskUnblockTime>

8000ca64 <.LBB20_27>:
                if( listCURRENT_LIST_LENGTH( &( pxReadyTasksLists[ pxCurrentTCB->uxPriority ] ) ) > ( UBaseType_t ) 1 )
8000ca64:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000ca68:	55cc                	lw	a1,44(a1)
8000ca6a:	4651                	li	a2,20
8000ca6c:	02c585b3          	mul	a1,a1,a2
8000ca70:	e8418613          	add	a2,gp,-380 # 811f4 <pxReadyTasksLists>
8000ca74:	95b2                	add	a1,a1,a2
8000ca76:	418c                	lw	a1,0(a1)
8000ca78:	4605                	li	a2,1
8000ca7a:	00b67363          	bgeu	a2,a1,8000ca80 <.LBB20_29>
8000ca7e:	4505                	li	a0,1

8000ca80 <.LBB20_29>:
                if( xYieldPending != pdFALSE )
8000ca80:	6081a583          	lw	a1,1544(gp) # 81978 <xYieldPending>
8000ca84:	ec0589e3          	beqz	a1,8000c956 <.LBB20_2>
8000ca88:	4505                	li	a0,1
    return xSwitchRequired;
8000ca8a:	8082                	ret

Disassembly of section .text.xTaskRemoveFromEventList:

8000ca8c <xTaskRemoveFromEventList>:
    pxUnblockedTCB = listGET_OWNER_OF_HEAD_ENTRY( pxEventList ); /*lint !e9079 void * is used as this macro is used with timers and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
8000ca8c:	4548                	lw	a0,12(a0)
8000ca8e:	4548                	lw	a0,12(a0)
    configASSERT( pxUnblockedTCB );
8000ca90:	c521                	beqz	a0,8000cad8 <.LBB34_5>
    listREMOVE_ITEM( &( pxUnblockedTCB->xEventListItem ) );
8000ca92:	5510                	lw	a2,40(a0)
8000ca94:	5114                	lw	a3,32(a0)
8000ca96:	4d58                	lw	a4,28(a0)
8000ca98:	425c                	lw	a5,4(a2)
8000ca9a:	01850593          	add	a1,a0,24
8000ca9e:	c714                	sw	a3,8(a4)
8000caa0:	c2d8                	sw	a4,4(a3)
8000caa2:	00b79363          	bne	a5,a1,8000caa8 <.LBB34_3>
8000caa6:	c254                	sw	a3,4(a2)

8000caa8 <.LBB34_3>:
8000caa8:	02052423          	sw	zero,40(a0)
8000caac:	4214                	lw	a3,0(a2)
8000caae:	16fd                	add	a3,a3,-1
8000cab0:	c214                	sw	a3,0(a2)
    if( uxSchedulerSuspended == ( UBaseType_t ) pdFALSE )
8000cab2:	64c1a603          	lw	a2,1612(gp) # 819bc <uxSchedulerSuspended>
8000cab6:	c60d                	beqz	a2,8000cae0 <.LBB34_7>
        listINSERT_END( &( xPendingReadyList ), &( pxUnblockedTCB->xEventListItem ) );
8000cab8:	55c18693          	add	a3,gp,1372 # 818cc <xPendingReadyList>
8000cabc:	42d8                	lw	a4,4(a3)
8000cabe:	471c                	lw	a5,8(a4)
8000cac0:	cd58                	sw	a4,28(a0)
8000cac2:	d11c                	sw	a5,32(a0)
8000cac4:	c3cc                	sw	a1,4(a5)
8000cac6:	c70c                	sw	a1,8(a4)
8000cac8:	d514                	sw	a3,40(a0)
8000caca:	55c1a583          	lw	a1,1372(gp) # 818cc <xPendingReadyList>
8000cace:	0585                	add	a1,a1,1
8000cad0:	54b1ae23          	sw	a1,1372(gp) # 818cc <xPendingReadyList>
    if( pxUnblockedTCB->uxPriority > pxCurrentTCB->uxPriority )
8000cad4:	554c                	lw	a1,44(a0)
8000cad6:	a8a1                	j	8000cb2e <.LBB34_10>

8000cad8 <.LBB34_5>:
    configASSERT( pxUnblockedTCB );
8000cad8:	30047073          	csrc	mstatus,8
8000cadc:	9002                	ebreak

8000cade <.LBB34_6>:
8000cade:	a001                	j	8000cade <.LBB34_6>

8000cae0 <.LBB34_7>:
        listREMOVE_ITEM( &( pxUnblockedTCB->xStateListItem ) );
8000cae0:	494c                	lw	a1,20(a0)
8000cae2:	4554                	lw	a3,12(a0)
8000cae4:	4518                	lw	a4,8(a0)
8000cae6:	41dc                	lw	a5,4(a1)
8000cae8:	00450613          	add	a2,a0,4
8000caec:	c714                	sw	a3,8(a4)
8000caee:	c2d8                	sw	a4,4(a3)
8000caf0:	00c79363          	bne	a5,a2,8000caf6 <.LBB34_9>
8000caf4:	c1d4                	sw	a3,4(a1)

8000caf6 <.LBB34_9>:
8000caf6:	4194                	lw	a3,0(a1)
8000caf8:	16fd                	add	a3,a3,-1
8000cafa:	c194                	sw	a3,0(a1)
        prvAddTaskToReadyList( pxUnblockedTCB );
8000cafc:	554c                	lw	a1,44(a0)
8000cafe:	6441a703          	lw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000cb02:	4785                	li	a5,1
8000cb04:	00b797b3          	sll	a5,a5,a1
8000cb08:	8f5d                	or	a4,a4,a5
8000cb0a:	64e1a223          	sw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000cb0e:	46d1                	li	a3,20
8000cb10:	02d586b3          	mul	a3,a1,a3
8000cb14:	e8418713          	add	a4,gp,-380 # 811f4 <pxReadyTasksLists>
8000cb18:	96ba                	add	a3,a3,a4
8000cb1a:	42d8                	lw	a4,4(a3)
8000cb1c:	471c                	lw	a5,8(a4)
8000cb1e:	c518                	sw	a4,8(a0)
8000cb20:	c55c                	sw	a5,12(a0)
8000cb22:	c3d0                	sw	a2,4(a5)
8000cb24:	c710                	sw	a2,8(a4)
8000cb26:	c954                	sw	a3,20(a0)
8000cb28:	4288                	lw	a0,0(a3)
8000cb2a:	0505                	add	a0,a0,1
8000cb2c:	c288                	sw	a0,0(a3)

8000cb2e <.LBB34_10>:
    if( pxUnblockedTCB->uxPriority > pxCurrentTCB->uxPriority )
8000cb2e:	6801a503          	lw	a0,1664(gp) # 819f0 <pxCurrentTCB>
8000cb32:	5548                	lw	a0,44(a0)
8000cb34:	00b57663          	bgeu	a0,a1,8000cb40 <.LBB34_12>
        xYieldPending = pdTRUE;
8000cb38:	4505                	li	a0,1
8000cb3a:	60a1a423          	sw	a0,1544(gp) # 81978 <xYieldPending>
    return xReturn;
8000cb3e:	8082                	ret

8000cb40 <.LBB34_12>:
8000cb40:	4501                	li	a0,0
8000cb42:	8082                	ret

Disassembly of section .text.vTaskMissedYield:

8000cb44 <vTaskMissedYield>:
    xYieldPending = pdTRUE;
8000cb44:	4585                	li	a1,1
8000cb46:	60b1a423          	sw	a1,1544(gp) # 81978 <xYieldPending>
}
8000cb4a:	8082                	ret

Disassembly of section .text.xTaskPriorityDisinherit:

8000cb4c <xTaskPriorityDisinherit>:
        if( pxMutexHolder != NULL )
8000cb4c:	cd51                	beqz	a0,8000cbe8 <.LBB46_10>
            configASSERT( pxTCB == pxCurrentTCB );
8000cb4e:	6801a583          	lw	a1,1664(gp) # 819f0 <pxCurrentTCB>
8000cb52:	00a58663          	beq	a1,a0,8000cb5e <.LBB46_4>
8000cb56:	30047073          	csrc	mstatus,8
8000cb5a:	9002                	ebreak

8000cb5c <.LBB46_3>:
8000cb5c:	a001                	j	8000cb5c <.LBB46_3>

8000cb5e <.LBB46_4>:
            configASSERT( pxTCB->uxMutexesHeld );
8000cb5e:	496c                	lw	a1,84(a0)
8000cb60:	c5c9                	beqz	a1,8000cbea <.LBB46_11>
8000cb62:	862a                	mv	a2,a0
8000cb64:	4501                	li	a0,0
            ( pxTCB->uxMutexesHeld )--;
8000cb66:	fff58693          	add	a3,a1,-1
8000cb6a:	ca74                	sw	a3,84(a2)
            if( pxTCB->uxPriority != pxTCB->uxBasePriority )
8000cb6c:	eeb5                	bnez	a3,8000cbe8 <.LBB46_10>
8000cb6e:	85b2                	mv	a1,a2
8000cb70:	5654                	lw	a3,44(a2)
8000cb72:	4a30                	lw	a2,80(a2)
8000cb74:	06c68a63          	beq	a3,a2,8000cbe8 <.LBB46_10>
8000cb78:	1141                	add	sp,sp,-16
8000cb7a:	c606                	sw	ra,12(sp)
8000cb7c:	c422                	sw	s0,8(sp)
8000cb7e:	c226                	sw	s1,4(sp)
8000cb80:	84ae                	mv	s1,a1
                    if( uxListRemove( &( pxTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
8000cb82:	00458413          	add	s0,a1,4
8000cb86:	8522                	mv	a0,s0
8000cb88:	30b1                	jal	8000c3d4 <uxListRemove>
8000cb8a:	85a6                	mv	a1,s1
8000cb8c:	ed01                	bnez	a0,8000cba4 <.LBB46_9>
                        portRESET_READY_PRIORITY( pxTCB->uxPriority, uxTopReadyPriority );
8000cb8e:	55c8                	lw	a0,44(a1)
8000cb90:	6441a683          	lw	a3,1604(gp) # 819b4 <uxTopReadyPriority>
8000cb94:	4705                	li	a4,1
8000cb96:	00a71533          	sll	a0,a4,a0
8000cb9a:	fff54513          	not	a0,a0
8000cb9e:	8d75                	and	a0,a0,a3
8000cba0:	64a1a223          	sw	a0,1604(gp) # 819b4 <uxTopReadyPriority>

8000cba4 <.LBB46_9>:
                    pxTCB->uxPriority = pxTCB->uxBasePriority;
8000cba4:	49b0                	lw	a2,80(a1)
8000cba6:	d5d0                	sw	a2,44(a1)
8000cba8:	02000513          	li	a0,32
                    listSET_LIST_ITEM_VALUE( &( pxTCB->xEventListItem ), ( TickType_t ) configMAX_PRIORITIES - ( TickType_t ) pxTCB->uxPriority ); /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
8000cbac:	8d11                	sub	a0,a0,a2
8000cbae:	cd88                	sw	a0,24(a1)
                    prvAddTaskToReadyList( pxTCB );
8000cbb0:	6441a703          	lw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000cbb4:	4505                	li	a0,1
8000cbb6:	00c517b3          	sll	a5,a0,a2
8000cbba:	8f5d                	or	a4,a4,a5
8000cbbc:	64e1a223          	sw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000cbc0:	46d1                	li	a3,20
8000cbc2:	02d60633          	mul	a2,a2,a3
8000cbc6:	e8418693          	add	a3,gp,-380 # 811f4 <pxReadyTasksLists>
8000cbca:	9636                	add	a2,a2,a3
8000cbcc:	4254                	lw	a3,4(a2)
8000cbce:	4698                	lw	a4,8(a3)
8000cbd0:	c594                	sw	a3,8(a1)
8000cbd2:	c5d8                	sw	a4,12(a1)
8000cbd4:	c340                	sw	s0,4(a4)
8000cbd6:	c680                	sw	s0,8(a3)
8000cbd8:	c9d0                	sw	a2,20(a1)
8000cbda:	420c                	lw	a1,0(a2)
8000cbdc:	0585                	add	a1,a1,1
8000cbde:	c20c                	sw	a1,0(a2)
8000cbe0:	40b2                	lw	ra,12(sp)
8000cbe2:	4422                	lw	s0,8(sp)
8000cbe4:	4492                	lw	s1,4(sp)
8000cbe6:	0141                	add	sp,sp,16

8000cbe8 <.LBB46_10>:
        return xReturn;
8000cbe8:	8082                	ret

8000cbea <.LBB46_11>:
            configASSERT( pxTCB->uxMutexesHeld );
8000cbea:	30047073          	csrc	mstatus,8
8000cbee:	9002                	ebreak

8000cbf0 <.LBB46_12>:
8000cbf0:	a001                	j	8000cbf0 <.LBB46_12>

Disassembly of section .text.vTaskPriorityDisinheritAfterTimeout:

8000cbf2 <vTaskPriorityDisinheritAfterTimeout>:
        if( pxMutexHolder != NULL )
8000cbf2:	c131                	beqz	a0,8000cc36 <.LBB47_10>
            configASSERT( pxTCB->uxMutexesHeld );
8000cbf4:	4974                	lw	a3,84(a0)
8000cbf6:	c2a9                	beqz	a3,8000cc38 <.LBB47_11>
            if( pxTCB->uxBasePriority < uxHighestPriorityWaitingTask )
8000cbf8:	4930                	lw	a2,80(a0)
8000cbfa:	00c5e363          	bltu	a1,a2,8000cc00 <.LBB47_4>
8000cbfe:	862e                	mv	a2,a1

8000cc00 <.LBB47_4>:
8000cc00:	4585                	li	a1,1
            if( pxTCB->uxPriority != uxPriorityToUse )
8000cc02:	02b69a63          	bne	a3,a1,8000cc36 <.LBB47_10>
8000cc06:	554c                	lw	a1,44(a0)
8000cc08:	02c58763          	beq	a1,a2,8000cc36 <.LBB47_10>
                    configASSERT( pxTCB != pxCurrentTCB );
8000cc0c:	6801a683          	lw	a3,1664(gp) # 819f0 <pxCurrentTCB>
8000cc10:	02a68863          	beq	a3,a0,8000cc40 <.LBB47_13>
                    if( ( listGET_LIST_ITEM_VALUE( &( pxTCB->xEventListItem ) ) & taskEVENT_LIST_ITEM_VALUE_IN_USE ) == 0UL )
8000cc14:	4d14                	lw	a3,24(a0)
                    pxTCB->uxPriority = uxPriorityToUse;
8000cc16:	d550                	sw	a2,44(a0)
                    if( ( listGET_LIST_ITEM_VALUE( &( pxTCB->xEventListItem ) ) & taskEVENT_LIST_ITEM_VALUE_IN_USE ) == 0UL )
8000cc18:	0006c663          	bltz	a3,8000cc24 <.LBB47_9>
8000cc1c:	02000693          	li	a3,32
                        listSET_LIST_ITEM_VALUE( &( pxTCB->xEventListItem ), ( TickType_t ) configMAX_PRIORITIES - ( TickType_t ) uxPriorityToUse ); /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
8000cc20:	8e91                	sub	a3,a3,a2
8000cc22:	cd14                	sw	a3,24(a0)

8000cc24 <.LBB47_9>:
                    if( listIS_CONTAINED_WITHIN( &( pxReadyTasksLists[ uxPriorityUsedOnEntry ] ), &( pxTCB->xStateListItem ) ) != pdFALSE )
8000cc24:	4950                	lw	a2,20(a0)
8000cc26:	46d1                	li	a3,20
8000cc28:	02d585b3          	mul	a1,a1,a3
8000cc2c:	e8418693          	add	a3,gp,-380 # 811f4 <pxReadyTasksLists>
8000cc30:	95b6                	add	a1,a1,a3
8000cc32:	00b60b63          	beq	a2,a1,8000cc48 <.LBB47_15>

8000cc36 <.LBB47_10>:
    }
8000cc36:	8082                	ret

8000cc38 <.LBB47_11>:
            configASSERT( pxTCB->uxMutexesHeld );
8000cc38:	30047073          	csrc	mstatus,8
8000cc3c:	9002                	ebreak

8000cc3e <.LBB47_12>:
8000cc3e:	a001                	j	8000cc3e <.LBB47_12>

8000cc40 <.LBB47_13>:
                    configASSERT( pxTCB != pxCurrentTCB );
8000cc40:	30047073          	csrc	mstatus,8
8000cc44:	9002                	ebreak

8000cc46 <.LBB47_14>:
8000cc46:	a001                	j	8000cc46 <.LBB47_14>

8000cc48 <.LBB47_15>:
8000cc48:	1141                	add	sp,sp,-16
8000cc4a:	c606                	sw	ra,12(sp)
8000cc4c:	c422                	sw	s0,8(sp)
8000cc4e:	c226                	sw	s1,4(sp)
8000cc50:	00450413          	add	s0,a0,4
8000cc54:	84aa                	mv	s1,a0
                        if( uxListRemove( &( pxTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
8000cc56:	8522                	mv	a0,s0
8000cc58:	f7cff0ef          	jal	8000c3d4 <uxListRemove>
8000cc5c:	85a6                	mv	a1,s1
                        prvAddTaskToReadyList( pxTCB );
8000cc5e:	54d0                	lw	a2,44(s1)
8000cc60:	4685                	li	a3,1
8000cc62:	00c696b3          	sll	a3,a3,a2
                        if( uxListRemove( &( pxTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
8000cc66:	e901                	bnez	a0,8000cc76 <.LBB47_17>
                            portRESET_READY_PRIORITY( pxTCB->uxPriority, uxTopReadyPriority );
8000cc68:	6441a703          	lw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000cc6c:	fff6c793          	not	a5,a3
8000cc70:	8f7d                	and	a4,a4,a5
8000cc72:	64e1a223          	sw	a4,1604(gp) # 819b4 <uxTopReadyPriority>

8000cc76 <.LBB47_17>:
                        prvAddTaskToReadyList( pxTCB );
8000cc76:	6441a703          	lw	a4,1604(gp) # 819b4 <uxTopReadyPriority>
8000cc7a:	8ed9                	or	a3,a3,a4
8000cc7c:	64d1a223          	sw	a3,1604(gp) # 819b4 <uxTopReadyPriority>
8000cc80:	4551                	li	a0,20
8000cc82:	02a60533          	mul	a0,a2,a0
8000cc86:	e8418613          	add	a2,gp,-380 # 811f4 <pxReadyTasksLists>
8000cc8a:	9532                	add	a0,a0,a2
8000cc8c:	4150                	lw	a2,4(a0)
8000cc8e:	4614                	lw	a3,8(a2)
8000cc90:	c590                	sw	a2,8(a1)
8000cc92:	c5d4                	sw	a3,12(a1)
8000cc94:	c2c0                	sw	s0,4(a3)
8000cc96:	c600                	sw	s0,8(a2)
8000cc98:	c9c8                	sw	a0,20(a1)
8000cc9a:	410c                	lw	a1,0(a0)
8000cc9c:	0585                	add	a1,a1,1
8000cc9e:	c10c                	sw	a1,0(a0)
8000cca0:	40b2                	lw	ra,12(sp)
8000cca2:	4422                	lw	s0,8(sp)
8000cca4:	4492                	lw	s1,4(sp)
8000cca6:	0141                	add	sp,sp,16
    }
8000cca8:	8082                	ret

Disassembly of section .text.prvCheckForValidListAndQueue:

8000ccaa <prvCheckForValidListAndQueue>:
        pxOverflowTimerList = pxTemp;
    }
/*-----------------------------------------------------------*/

    static void prvCheckForValidListAndQueue( void )
    {
8000ccaa:	1141                	add	sp,sp,-16
8000ccac:	c606                	sw	ra,12(sp)
8000ccae:	c422                	sw	s0,8(sp)
8000ccb0:	c226                	sw	s1,4(sp)
8000ccb2:	c04a                	sw	s2,0(sp)
        /* Check that the list from which active timers are referenced, and the
         * queue used to communicate with the timer service, have been
         * initialised. */
        taskENTER_CRITICAL();
8000ccb4:	ae2fb0ef          	jal	80007f96 <vTaskEnterCritical>
        {
            if( xTimerQueue == NULL )
8000ccb8:	6101a503          	lw	a0,1552(gp) # 81980 <xTimerQueue>
8000ccbc:	e515                	bnez	a0,8000cce8 <.LBB1_2>
            {
                vListInitialise( &xActiveTimerList1 );
8000ccbe:	5ac18413          	add	s0,gp,1452 # 8191c <xActiveTimerList1>
8000ccc2:	8522                	mv	a0,s0
8000ccc4:	efcff0ef          	jal	8000c3c0 <vListInitialise>
                vListInitialise( &xActiveTimerList2 );
8000ccc8:	59818493          	add	s1,gp,1432 # 81908 <xActiveTimerList2>
8000cccc:	8526                	mv	a0,s1
8000ccce:	ef2ff0ef          	jal	8000c3c0 <vListInitialise>
                pxCurrentTimerList = &xActiveTimerList1;
8000ccd2:	6681ae23          	sw	s0,1660(gp) # 819ec <pxCurrentTimerList>
                pxOverflowTimerList = &xActiveTimerList2;
8000ccd6:	6691a623          	sw	s1,1644(gp) # 819dc <pxOverflowTimerList>

                        xTimerQueue = xQueueCreateStatic( ( UBaseType_t ) configTIMER_QUEUE_LENGTH, ( UBaseType_t ) sizeof( DaemonTaskMessage_t ), &( ucStaticTimerQueueStorage[ 0 ] ), &xStaticTimerQueue );
                    }
                #else
                    {
                        xTimerQueue = xQueueCreate( ( UBaseType_t ) configTIMER_QUEUE_LENGTH, sizeof( DaemonTaskMessage_t ) );
8000ccda:	4511                	li	a0,4
8000ccdc:	45c1                	li	a1,16
8000ccde:	4601                	li	a2,0
8000cce0:	b9bfa0ef          	jal	8000787a <xQueueGenericCreate>
8000cce4:	60a1a823          	sw	a0,1552(gp) # 81980 <xTimerQueue>

8000cce8 <.LBB1_2>:
8000cce8:	40b2                	lw	ra,12(sp)
8000ccea:	4422                	lw	s0,8(sp)
8000ccec:	4492                	lw	s1,4(sp)
8000ccee:	4902                	lw	s2,0(sp)
            else
            {
                mtCOVERAGE_TEST_MARKER();
            }
        }
        taskEXIT_CRITICAL();
8000ccf0:	0141                	add	sp,sp,16
8000ccf2:	bc89                	j	8000c744 <vTaskExitCritical>

Disassembly of section .text.prvSampleTimeNow:

8000ccf4 <prvSampleTimeNow>:
    {
8000ccf4:	1101                	add	sp,sp,-32
8000ccf6:	ce06                	sw	ra,28(sp)
8000ccf8:	cc22                	sw	s0,24(sp)
8000ccfa:	ca26                	sw	s1,20(sp)
8000ccfc:	c84a                	sw	s2,16(sp)
8000ccfe:	c64e                	sw	s3,12(sp)
8000cd00:	842a                	mv	s0,a0
        xTimeNow = xTaskGetTickCount();
8000cd02:	c78fb0ef          	jal	8000817a <xTaskGetTickCount>
        if( xTimeNow < xLastTime )
8000cd06:	6881a583          	lw	a1,1672(gp) # 819f8 <prvSampleTimeNow.xLastTime>
8000cd0a:	00b57c63          	bgeu	a0,a1,8000cd22 <.LBB18_4>
8000cd0e:	892a                	mv	s2,a0

8000cd10 <.LBB18_2>:
        while( listLIST_IS_EMPTY( pxCurrentTimerList ) == pdFALSE )
8000cd10:	67c1a503          	lw	a0,1660(gp) # 819ec <pxCurrentTimerList>
8000cd14:	410c                	lw	a1,0(a0)
8000cd16:	c981                	beqz	a1,8000cd26 <.LBB18_5>
            xNextExpireTime = listGET_ITEM_VALUE_OF_HEAD_ENTRY( pxCurrentTimerList );
8000cd18:	4548                	lw	a0,12(a0)
8000cd1a:	4108                	lw	a0,0(a0)
            prvProcessExpiredTimer( xNextExpireTime, tmrMAX_TIME_BEFORE_OVERFLOW );
8000cd1c:	55fd                	li	a1,-1
8000cd1e:	2035                	jal	8000cd4a <prvProcessExpiredTimer>
8000cd20:	bfc5                	j	8000cd10 <.LBB18_2>

8000cd22 <.LBB18_4>:
8000cd22:	4581                	li	a1,0
8000cd24:	a809                	j	8000cd36 <.LBB18_6>

8000cd26 <.LBB18_5>:
        pxCurrentTimerList = pxOverflowTimerList;
8000cd26:	66c1a603          	lw	a2,1644(gp) # 819dc <pxOverflowTimerList>
8000cd2a:	66c1ae23          	sw	a2,1660(gp) # 819ec <pxCurrentTimerList>
        pxOverflowTimerList = pxTemp;
8000cd2e:	66a1a623          	sw	a0,1644(gp) # 819dc <pxOverflowTimerList>
8000cd32:	4585                	li	a1,1
8000cd34:	854a                	mv	a0,s2

8000cd36 <.LBB18_6>:
8000cd36:	c00c                	sw	a1,0(s0)
        xLastTime = xTimeNow;
8000cd38:	68a1a423          	sw	a0,1672(gp) # 819f8 <prvSampleTimeNow.xLastTime>
8000cd3c:	40f2                	lw	ra,28(sp)
8000cd3e:	4462                	lw	s0,24(sp)
8000cd40:	44d2                	lw	s1,20(sp)
8000cd42:	4942                	lw	s2,16(sp)
8000cd44:	49b2                	lw	s3,12(sp)
        return xTimeNow;
8000cd46:	6105                	add	sp,sp,32
8000cd48:	8082                	ret

Disassembly of section .text.prvProcessExpiredTimer:

8000cd4a <prvProcessExpiredTimer>:
    {
8000cd4a:	1101                	add	sp,sp,-32
8000cd4c:	ce06                	sw	ra,28(sp)
8000cd4e:	cc22                	sw	s0,24(sp)
8000cd50:	ca26                	sw	s1,20(sp)
8000cd52:	c84a                	sw	s2,16(sp)
8000cd54:	c64e                	sw	s3,12(sp)
8000cd56:	c452                	sw	s4,8(sp)
8000cd58:	c256                	sw	s5,4(sp)
8000cd5a:	c05a                	sw	s6,0(sp)
        Timer_t * const pxTimer = ( Timer_t * ) listGET_OWNER_OF_HEAD_ENTRY( pxCurrentTimerList ); /*lint !e9087 !e9079 void * is used as this macro is used with tasks and co-routines too.  Alignment is known to be fine as the type of the pointer stored and retrieved is the same. */
8000cd5c:	67c1a603          	lw	a2,1660(gp) # 819ec <pxCurrentTimerList>
8000cd60:	4650                	lw	a2,12(a2)
8000cd62:	00c62b03          	lw	s6,12(a2)
8000cd66:	89ae                	mv	s3,a1
8000cd68:	842a                	mv	s0,a0
        ( void ) uxListRemove( &( pxTimer->xTimerListItem ) );
8000cd6a:	004b0913          	add	s2,s6,4
8000cd6e:	854a                	mv	a0,s2
8000cd70:	e64ff0ef          	jal	8000c3d4 <uxListRemove>
        if( ( pxTimer->ucStatus & tmrSTATUS_IS_AUTORELOAD ) != 0 )
8000cd74:	028b4503          	lbu	a0,40(s6)
8000cd78:	00457593          	and	a1,a0,4
8000cd7c:	e591                	bnez	a1,8000cd88 <.LBB19_2>
            pxTimer->ucStatus &= ~tmrSTATUS_IS_ACTIVE;
8000cd7e:	0fa57513          	and	a0,a0,250
8000cd82:	02ab0423          	sb	a0,40(s6)
8000cd86:	a099                	j	8000cdcc <.LBB19_10>

8000cd88 <.LBB19_2>:
8000cd88:	67c18a93          	add	s5,gp,1660 # 819ec <pxCurrentTimerList>
8000cd8c:	66c18a13          	add	s4,gp,1644 # 819dc <pxOverflowTimerList>
8000cd90:	a811                	j	8000cda4 <.LBB19_5>

8000cd92 <.LBB19_3>:
            if( ( ( TickType_t ) ( xTimeNow - xCommandTime ) ) >= pxTimer->xTimerPeriodInTicks ) /*lint !e961 MISRA exception as the casts are only redundant for some ports. */
8000cd92:	408985b3          	sub	a1,s3,s0
8000cd96:	02a5e663          	bltu	a1,a0,8000cdc2 <.LBB19_9>

8000cd9a <.LBB19_4>:
            pxTimer->pxCallbackFunction( ( TimerHandle_t ) pxTimer );
8000cd9a:	020b2583          	lw	a1,32(s6)
8000cd9e:	855a                	mv	a0,s6
8000cda0:	9582                	jalr	a1
8000cda2:	8426                	mv	s0,s1

8000cda4 <.LBB19_5>:
        while ( prvInsertTimerInActiveList( pxTimer, ( xExpiredTime + pxTimer->xTimerPeriodInTicks ), xTimeNow, xExpiredTime ) != pdFALSE )
8000cda4:	018b2503          	lw	a0,24(s6)
8000cda8:	008504b3          	add	s1,a0,s0
        listSET_LIST_ITEM_VALUE( &( pxTimer->xTimerListItem ), xNextExpiryTime );
8000cdac:	009b2223          	sw	s1,4(s6)
        listSET_LIST_ITEM_OWNER( &( pxTimer->xTimerListItem ), pxTimer );
8000cdb0:	016b2823          	sw	s6,16(s6)
        if( xNextExpiryTime <= xTimeNow )
8000cdb4:	fc99ffe3          	bgeu	s3,s1,8000cd92 <.LBB19_3>
            if( ( xTimeNow < xCommandTime ) && ( xNextExpiryTime >= xCommandTime ) )
8000cdb8:	0089f463          	bgeu	s3,s0,8000cdc0 <.LBB19_8>
8000cdbc:	fc84ffe3          	bgeu	s1,s0,8000cd9a <.LBB19_4>

8000cdc0 <.LBB19_8>:
8000cdc0:	8a56                	mv	s4,s5

8000cdc2 <.LBB19_9>:
8000cdc2:	000a2503          	lw	a0,0(s4)
8000cdc6:	85ca                	mv	a1,s2
8000cdc8:	9fdfa0ef          	jal	800077c4 <vListInsert>

8000cdcc <.LBB19_10>:
        pxTimer->pxCallbackFunction( ( TimerHandle_t ) pxTimer );
8000cdcc:	020b2783          	lw	a5,32(s6)
8000cdd0:	855a                	mv	a0,s6
8000cdd2:	40f2                	lw	ra,28(sp)
8000cdd4:	4462                	lw	s0,24(sp)
8000cdd6:	44d2                	lw	s1,20(sp)
8000cdd8:	4942                	lw	s2,16(sp)
8000cdda:	49b2                	lw	s3,12(sp)
8000cddc:	4a22                	lw	s4,8(sp)
8000cdde:	4a92                	lw	s5,4(sp)
8000cde0:	4b02                	lw	s6,0(sp)
8000cde2:	6105                	add	sp,sp,32
8000cde4:	8782                	jr	a5

Disassembly of section .text.reset_handler:

8000cde6 <reset_handler>:
{
8000cde6:	1141                	add	sp,sp,-16
8000cde8:	c606                	sw	ra,12(sp)
    fencei();
8000cdea:	0000100f          	fence.i
    system_init();
8000cdee:	22f5                	jal	8000cfda <system_init>
8000cdf0:	40b2                	lw	ra,12(sp)
    MAIN_ENTRY();
8000cdf2:	0141                	add	sp,sp,16
8000cdf4:	7fffb317          	auipc	t1,0x7fffb
8000cdf8:	17830067          	jr	376(t1) # 7f6c <main>

Disassembly of section .text.exception_handler:

8000cdfc <exception_handler>:

__attribute__((weak)) long exception_handler(long cause, long epc)
{
8000cdfc:	852e                	mv	a0,a1
        break;
    default:
        break;
    }
    /* Unhandled Trap */
    return epc;
8000cdfe:	8082                	ret

Disassembly of section .text.clock_set_source_divider:

8000ce00 <clock_set_source_divider>:
{
8000ce00:	1141                	add	sp,sp,-16
8000ce02:	c606                	sw	ra,12(sp)
8000ce04:	c422                	sw	s0,8(sp)
8000ce06:	c226                	sw	s1,4(sp)
    switch (clk_src_type) {
8000ce08:	01051693          	sll	a3,a0,0x10
8000ce0c:	82e1                	srl	a3,a3,0x18
8000ce0e:	47ad                	li	a5,11
8000ce10:	6715                	lui	a4,0x5
8000ce12:	06d7ee63          	bltu	a5,a3,8000ce8e <.LBB5_8>
8000ce16:	068a                	sll	a3,a3,0x2
8000ce18:	800057b7          	lui	a5,0x80005
8000ce1c:	f7c78793          	add	a5,a5,-132 # 80004f7c <.LJTI5_0>
8000ce20:	96be                	add	a3,a3,a5
8000ce22:	429c                	lw	a5,0(a3)
8000ce24:	5f370693          	add	a3,a4,1523 # 55f3 <.LBB6_10+0x29>
8000ce28:	8782                	jr	a5

8000ce2a <.LBB5_2>:
        if ((div < 1U) || (div > 256U)) {
8000ce2a:	eff60693          	add	a3,a2,-257
8000ce2e:	f0000713          	li	a4,-256
8000ce32:	06e6f163          	bgeu	a3,a4,8000ce94 <.LBB5_9>
8000ce36:	6515                	lui	a0,0x5
8000ce38:	5f050693          	add	a3,a0,1520 # 55f0 <.LBB6_10+0x26>
8000ce3c:	a0bd                	j	8000ceaa <.LBB5_11>

8000ce3e <.LBB5_4>:
8000ce3e:	6515                	lui	a0,0x5
8000ce40:	5fa50693          	add	a3,a0,1530 # 55fa <.LBB6_10+0x30>
8000ce44:	a09d                	j	8000ceaa <.LBB5_11>

8000ce46 <.LBB5_5>:
    uint32_t node_or_instance = GET_CLK_NODE_FROM_NAME(clock_name);
8000ce46:	0ff57513          	zext.b	a0,a0
8000ce4a:	0fc00693          	li	a3,252
        if (node_or_instance == clock_node_cpu0) {
8000ce4e:	02d51c63          	bne	a0,a3,8000ce86 <.LBB5_7>
            uint32_t expected_freq = get_frequency_for_source((clock_source_t) src) / div;
8000ce52:	852e                	mv	a0,a1
8000ce54:	8432                	mv	s0,a2
8000ce56:	84ae                	mv	s1,a1
8000ce58:	88dfb0ef          	jal	800086e4 <get_frequency_for_source>
8000ce5c:	02855533          	divu	a0,a0,s0
8000ce60:	0bebc5b7          	lui	a1,0xbebc
8000ce64:	1ff58593          	add	a1,a1,511 # bebc1ff <_flash_size+0xbdbc1ff>
            uint32_t ahb_sub_div = (expected_freq + BUS_FREQ_MAX - 1U) / BUS_FREQ_MAX;
8000ce68:	952e                	add	a0,a0,a1
8000ce6a:	55e645b7          	lui	a1,0x55e64
8000ce6e:	b8958593          	add	a1,a1,-1143 # 55e63b89 <_flash_size+0x55d63b89>
8000ce72:	02b536b3          	mulhu	a3,a0,a1
8000ce76:	82e9                	srl	a3,a3,0x1a
            sysctl_config_cpu0_domain_clock(HPM_SYSCTL, (clock_source_t) src, div, ahb_sub_div);
8000ce78:	f4000537          	lui	a0,0xf4000
8000ce7c:	85a6                	mv	a1,s1
8000ce7e:	8622                	mv	a2,s0
8000ce80:	a11fb0ef          	jal	80008890 <sysctl_config_cpu0_domain_clock>
8000ce84:	a015                	j	8000cea8 <.LBB5_10>

8000ce86 <.LBB5_7>:
8000ce86:	6515                	lui	a0,0x5
8000ce88:	5f850693          	add	a3,a0,1528 # 55f8 <.LBB6_10+0x2e>
8000ce8c:	a839                	j	8000ceaa <.LBB5_11>

8000ce8e <.LBB5_8>:
8000ce8e:	5f170693          	add	a3,a4,1521
8000ce92:	a821                	j	8000ceaa <.LBB5_11>

8000ce94 <.LBB5_9>:
            sysctl_config_clock(HPM_SYSCTL, (clock_node_t) node_or_instance, clk_src, div);
8000ce94:	0ff57693          	zext.b	a3,a0
8000ce98:	00f5f713          	and	a4,a1,15
8000ce9c:	f4000537          	lui	a0,0xf4000
8000cea0:	85b6                	mv	a1,a3
8000cea2:	86b2                	mv	a3,a2
8000cea4:	863a                	mv	a2,a4
8000cea6:	28d5                	jal	8000cf9a <sysctl_config_clock>

8000cea8 <.LBB5_10>:
8000cea8:	4681                	li	a3,0

8000ceaa <.LBB5_11>:
    return status;
8000ceaa:	8536                	mv	a0,a3
8000ceac:	40b2                	lw	ra,12(sp)
8000ceae:	4422                	lw	s0,8(sp)
8000ceb0:	4492                	lw	s1,4(sp)
8000ceb2:	0141                	add	sp,sp,16
8000ceb4:	8082                	ret

Disassembly of section .text.clock_add_to_group:

8000ceb6 <clock_add_to_group>:
    if (resource < sysctl_resource_end) {
8000ceb6:	01055613          	srl	a2,a0,0x10
8000ceba:	13600513          	li	a0,310
8000cebe:	00c56863          	bltu	a0,a2,8000cece <.LBB8_2>
        sysctl_enable_group_resource(HPM_SYSCTL, group, resource, true);
8000cec2:	0ff5f593          	zext.b	a1,a1
8000cec6:	f4000537          	lui	a0,0xf4000
8000ceca:	4685                	li	a3,1
8000cecc:	a8bd                	j	8000cf4a <sysctl_enable_group_resource>

8000cece <.LBB8_2>:
}
8000cece:	8082                	ret

Disassembly of section .text.clock_remove_from_group:

8000ced0 <clock_remove_from_group>:
    if (resource < sysctl_resource_end) {
8000ced0:	01055613          	srl	a2,a0,0x10
8000ced4:	13600513          	li	a0,310
8000ced8:	00c56863          	bltu	a0,a2,8000cee8 <.LBB9_2>
        sysctl_enable_group_resource(HPM_SYSCTL, group, resource, false);
8000cedc:	0ff5f593          	zext.b	a1,a1
8000cee0:	f4000537          	lui	a0,0xf4000
8000cee4:	4681                	li	a3,0
8000cee6:	a095                	j	8000cf4a <sysctl_enable_group_resource>

8000cee8 <.LBB9_2>:
}
8000cee8:	8082                	ret

Disassembly of section .text.clock_check_in_group:

8000ceea <clock_check_in_group>:
    uint32_t resource = GET_CLK_RESOURCE_FROM_NAME(clock_name);
8000ceea:	01055613          	srl	a2,a0,0x10
    return sysctl_check_group_resource_enable(HPM_SYSCTL, group, resource);
8000ceee:	0ff5f593          	zext.b	a1,a1
8000cef2:	f4000537          	lui	a0,0xf4000
8000cef6:	975fb06f          	j	8000886a <sysctl_check_group_resource_enable>

Disassembly of section .text.clock_connect_group_to_cpu:

8000cefa <clock_connect_group_to_cpu>:
    if (cpu == 0U) {
8000cefa:	c191                	beqz	a1,8000cefe <.LBB11_2>
}
8000cefc:	8082                	ret

8000cefe <.LBB11_2>:
8000cefe:	4585                	li	a1,1
        HPM_SYSCTL->AFFILIATE[cpu].SET = (1UL << group);
8000cf00:	00a59533          	sll	a0,a1,a0
8000cf04:	f40015b7          	lui	a1,0xf4001
8000cf08:	90a5a223          	sw	a0,-1788(a1) # f4000904 <__AHB_SRAM_segment_end__+0x3bf8904>
}
8000cf0c:	8082                	ret

Disassembly of section .text.clock_update_core_clock:

8000cf0e <clock_update_core_clock>:

void clock_update_core_clock(void)
{
8000cf0e:	1141                	add	sp,sp,-16
8000cf10:	c606                	sw	ra,12(sp)
8000cf12:	c422                	sw	s0,8(sp)
8000cf14:	f4002537          	lui	a0,0xf4002
    uint32_t mux = SYSCTL_CLOCK_CPU_MUX_GET(HPM_SYSCTL->CLOCK_CPU[0]);
8000cf18:	80052583          	lw	a1,-2048(a0) # f4001800 <__AHB_SRAM_segment_end__+0x3bf9800>
    uint32_t div = SYSCTL_CLOCK_CPU_DIV_GET(HPM_SYSCTL->CLOCK_CPU[0]) + 1U;
8000cf1c:	80052503          	lw	a0,-2048(a0)
8000cf20:	0ff57513          	zext.b	a0,a0
8000cf24:	00150413          	add	s0,a0,1
    return (get_frequency_for_source(mux) / div);
8000cf28:	01559513          	sll	a0,a1,0x15
8000cf2c:	8175                	srl	a0,a0,0x1d
8000cf2e:	fb6fb0ef          	jal	800086e4 <get_frequency_for_source>
8000cf32:	02855533          	divu	a0,a0,s0
    hpm_core_clock = clock_get_frequency(clock_cpu0);
8000cf36:	6aa1a423          	sw	a0,1704(gp) # 81a18 <hpm_core_clock>
8000cf3a:	40b2                	lw	ra,12(sp)
8000cf3c:	4422                	lw	s0,8(sp)
}
8000cf3e:	0141                	add	sp,sp,16
8000cf40:	8082                	ret

Disassembly of section .text.l1c_dc_invalidate_all:

8000cf42 <l1c_dc_invalidate_all>:
{
    __asm("fence.i");
}

void l1c_dc_invalidate_all(void)
{
8000cf42:	455d                	li	a0,23
}

/* send command */
__attribute__((always_inline)) static inline void l1c_cctl_cmd(uint8_t cmd)
{
    write_csr(CSR_MCCTLCOMMAND, cmd);
8000cf44:	7cc51073          	csrw	0x7cc,a0
    l1c_cctl_cmd(HPM_L1C_CCTL_CMD_L1D_INVAL_ALL);
}
8000cf48:	8082                	ret

Disassembly of section .text.sysctl_enable_group_resource:

8000cf4a <sysctl_enable_group_resource>:
{
8000cf4a:	4709                	li	a4,2
    if (resource < sysctl_resource_linkable_start) {
8000cf4c:	e5a9                	bnez	a1,8000cf96 <.LBB9_6>
8000cf4e:	10000593          	li	a1,256
8000cf52:	04b66263          	bltu	a2,a1,8000cf96 <.LBB9_6>
8000cf56:	4701                	li	a4,0
    index = (resource - sysctl_resource_linkable_start) / 32;
8000cf58:	f0060593          	add	a1,a2,-256
        ptr->GROUP0[index].VALUE = (ptr->GROUP0[index].VALUE & ~(1UL << offset)) | (enable ? (1UL << offset) : 0);
8000cf5c:	8185                	srl	a1,a1,0x1
8000cf5e:	99c1                	and	a1,a1,-16
8000cf60:	95aa                	add	a1,a1,a0
8000cf62:	7ff58893          	add	a7,a1,2047
8000cf66:	0018a803          	lw	a6,1(a7)
8000cf6a:	4785                	li	a5,1
8000cf6c:	00c797b3          	sll	a5,a5,a2
8000cf70:	fff7c593          	not	a1,a5
8000cf74:	00b87833          	and	a6,a6,a1
8000cf78:	40d005b3          	neg	a1,a3
8000cf7c:	8dfd                	and	a1,a1,a5
8000cf7e:	00b865b3          	or	a1,a6,a1
8000cf82:	00b8a0a3          	sw	a1,1(a7)
        if (enable) {
8000cf86:	ca81                	beqz	a3,8000cf96 <.LBB9_6>
8000cf88:	060a                	sll	a2,a2,0x2
8000cf8a:	9532                	add	a0,a0,a2

8000cf8c <.LBB9_4>:
    return ptr->RESOURCE[resource] & SYSCTL_RESOURCE_LOC_BUSY_MASK;
8000cf8c:	410c                	lw	a1,0(a0)
            while (sysctl_resource_target_is_busy(ptr, resource)) {
8000cf8e:	0586                	sll	a1,a1,0x1
8000cf90:	fe05cee3          	bltz	a1,8000cf8c <.LBB9_4>
8000cf94:	4701                	li	a4,0

8000cf96 <.LBB9_6>:
}
8000cf96:	853a                	mv	a0,a4
8000cf98:	8082                	ret

Disassembly of section .text.sysctl_config_clock:

8000cf9a <sysctl_config_clock>:
{
8000cf9a:	872a                	mv	a4,a0
8000cf9c:	02300793          	li	a5,35
8000cfa0:	4509                	li	a0,2
    if (node >= clock_node_adc_start) {
8000cfa2:	02b7eb63          	bltu	a5,a1,8000cfd8 <.LBB15_5>
8000cfa6:	479d                	li	a5,7
8000cfa8:	02c7e863          	bltu	a5,a2,8000cfd8 <.LBB15_5>
    ptr->CLOCK[node] = (ptr->CLOCK[node] & ~(SYSCTL_CLOCK_MUX_MASK | SYSCTL_CLOCK_DIV_MASK)) |
8000cfac:	058a                	sll	a1,a1,0x2
8000cfae:	00b70533          	add	a0,a4,a1
8000cfb2:	6589                	lui	a1,0x2
8000cfb4:	80458593          	add	a1,a1,-2044 # 1804 <.LBB2_292+0x1a>
8000cfb8:	952e                	add	a0,a0,a1
8000cfba:	410c                	lw	a1,0(a0)
8000cfbc:	8005f593          	and	a1,a1,-2048
        (SYSCTL_CLOCK_MUX_SET(source) | SYSCTL_CLOCK_DIV_SET(divide_by - 1));
8000cfc0:	0622                	sll	a2,a2,0x8
8000cfc2:	16fd                	add	a3,a3,-1
8000cfc4:	0ff6f693          	zext.b	a3,a3
8000cfc8:	8e55                	or	a2,a2,a3
    ptr->CLOCK[node] = (ptr->CLOCK[node] & ~(SYSCTL_CLOCK_MUX_MASK | SYSCTL_CLOCK_DIV_MASK)) |
8000cfca:	95b2                	add	a1,a1,a2
8000cfcc:	c10c                	sw	a1,0(a0)

8000cfce <.LBB15_3>:
 * @param[in] clock target clock
 * @return true if target clock is busy
 */
static inline bool sysctl_clock_target_is_busy(SYSCTL_Type *ptr, clock_node_t clock)
{
    return ptr->CLOCK[clock] & SYSCTL_CLOCK_LOC_BUSY_MASK;
8000cfce:	410c                	lw	a1,0(a0)
    while (sysctl_clock_target_is_busy(ptr, node)) {
8000cfd0:	0586                	sll	a1,a1,0x1
8000cfd2:	fe05cee3          	bltz	a1,8000cfce <.LBB15_3>
8000cfd6:	4501                	li	a0,0

8000cfd8 <.LBB15_5>:
}
8000cfd8:	8082                	ret

Disassembly of section .text.system_init:

8000cfda <system_init>:
#endif
    __plic_set_feature(HPM_PLIC_BASE, plic_feature);
}

__attribute__((weak)) void system_init(void)
{
8000cfda:	1141                	add	sp,sp,-16
#ifndef CONFIG_NOT_ENALBE_ACCESS_TO_CYCLE_CSR
    uint32_t mcounteren = read_csr(CSR_MCOUNTEREN);
8000cfdc:	30602573          	csrr	a0,mcounteren
    write_csr(CSR_MCOUNTEREN, mcounteren | 1); /* Enable MCYCLE */
8000cfe0:	00156513          	or	a0,a0,1
8000cfe4:	30651073          	csrw	mcounteren,a0
 * @param[in] mask interrupt mask to be disabled
 * @retval current mstatus value before irq mask is disabled
 */
ATTR_ALWAYS_INLINE static inline uint32_t disable_global_irq(uint32_t mask)
{
    return read_clear_csr(CSR_MSTATUS, mask);
8000cfe8:	c602                	sw	zero,12(sp)
8000cfea:	4521                	li	a0,8
8000cfec:	30053573          	csrrc	a0,mstatus,a0
8000cff0:	c62a                	sw	a0,12(sp)
8000cff2:	00c12003          	lw	zero,12(sp)
8000cff6:	4505                	li	a0,1
8000cff8:	052e                	sll	a0,a0,0xb
 * @brief   Disable IRQ from interrupt controller
 *
 */
ATTR_ALWAYS_INLINE static inline void disable_irq_from_intc(void)
{
    clear_csr(CSR_MIE, CSR_MIE_MEIE_MASK);
8000cffa:	30453073          	csrc	mie,a0
8000cffe:	e40005b7          	lui	a1,0xe4000
 * @param[in] feature Specific feature to be set
 *
 */
ATTR_ALWAYS_INLINE static inline void __plic_set_feature(uint32_t base, uint32_t feature)
{
    *(volatile uint32_t *) (base + HPM_PLIC_FEATURE_OFFSET) = feature;
8000d002:	0005a023          	sw	zero,0(a1) # e4000000 <__XPI0_segment_end__+0x63f00000>
    set_csr(CSR_MIE, CSR_MIE_MEIE_MASK);
8000d006:	30452073          	csrs	mie,a0
#else
#if !CONFIG_DISABLE_GLOBAL_IRQ_ON_STARTUP
    enable_global_irq(CSR_MSTATUS_MIE_MASK);
#endif
#endif
}
8000d00a:	0141                	add	sp,sp,16
8000d00c:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_puts_no_nl:

8000d00e <__SEGGER_RTL_puts_no_nl>:
8000d00e:	1101                	add	sp,sp,-32
8000d010:	000807b7          	lui	a5,0x80
8000d014:	cc22                	sw	s0,24(sp)
8000d016:	2687a403          	lw	s0,616(a5) # 80268 <stdout>
8000d01a:	ce06                	sw	ra,28(sp)
8000d01c:	c62a                	sw	a0,12(sp)
8000d01e:	3ab000ef          	jal	8000dbc8 <strlen>
8000d022:	862a                	mv	a2,a0
8000d024:	8522                	mv	a0,s0
8000d026:	4462                	lw	s0,24(sp)
8000d028:	45b2                	lw	a1,12(sp)
8000d02a:	40f2                	lw	ra,28(sp)
8000d02c:	6105                	add	sp,sp,32
8000d02e:	d87fc06f          	j	80009db4 <__SEGGER_RTL_X_file_write>

Disassembly of section .text.libc.signal:

8000d032 <signal>:
8000d032:	4795                	li	a5,5
8000d034:	02a7e263          	bltu	a5,a0,8000d058 <.L18>
8000d038:	50418693          	add	a3,gp,1284 # 81874 <__SEGGER_RTL_aSigTab>
8000d03c:	00251793          	sll	a5,a0,0x2
8000d040:	96be                	add	a3,a3,a5
8000d042:	4288                	lw	a0,0(a3)
8000d044:	50418713          	add	a4,gp,1284 # 81874 <__SEGGER_RTL_aSigTab>
8000d048:	e509                	bnez	a0,8000d052 <.L17>
8000d04a:	80009537          	lui	a0,0x80009
8000d04e:	97050513          	add	a0,a0,-1680 # 80008970 <__SEGGER_RTL_SIGNAL_SIG_DFL>

8000d052 <.L17>:
8000d052:	973e                	add	a4,a4,a5
8000d054:	c30c                	sw	a1,0(a4)
8000d056:	8082                	ret

8000d058 <.L18>:
8000d058:	80009537          	lui	a0,0x80009
8000d05c:	97450513          	add	a0,a0,-1676 # 80008974 <__SEGGER_RTL_SIGNAL_SIG_ERR>
8000d060:	8082                	ret

Disassembly of section .text.libc.raise:

8000d062 <raise>:
8000d062:	1141                	add	sp,sp,-16
8000d064:	c04a                	sw	s2,0(sp)
8000d066:	80009937          	lui	s2,0x80009
8000d06a:	97290593          	add	a1,s2,-1678 # 80008972 <__SEGGER_RTL_SIGNAL_SIG_IGN>
8000d06e:	c226                	sw	s1,4(sp)
8000d070:	c606                	sw	ra,12(sp)
8000d072:	c422                	sw	s0,8(sp)
8000d074:	84aa                	mv	s1,a0
8000d076:	3f75                	jal	8000d032 <signal>
8000d078:	800097b7          	lui	a5,0x80009
8000d07c:	97478793          	add	a5,a5,-1676 # 80008974 <__SEGGER_RTL_SIGNAL_SIG_ERR>
8000d080:	02f50d63          	beq	a0,a5,8000d0ba <.L24>
8000d084:	97290913          	add	s2,s2,-1678
8000d088:	842a                	mv	s0,a0
8000d08a:	03250163          	beq	a0,s2,8000d0ac <.L22>
8000d08e:	800095b7          	lui	a1,0x80009
8000d092:	97058793          	add	a5,a1,-1680 # 80008970 <__SEGGER_RTL_SIGNAL_SIG_DFL>
8000d096:	00f51563          	bne	a0,a5,8000d0a0 <.L23>
8000d09a:	4505                	li	a0,1
8000d09c:	fc3f50ef          	jal	8000305e <exit>

8000d0a0 <.L23>:
8000d0a0:	97058593          	add	a1,a1,-1680
8000d0a4:	8526                	mv	a0,s1
8000d0a6:	3771                	jal	8000d032 <signal>
8000d0a8:	8526                	mv	a0,s1
8000d0aa:	9402                	jalr	s0

8000d0ac <.L22>:
8000d0ac:	4501                	li	a0,0

8000d0ae <.L20>:
8000d0ae:	40b2                	lw	ra,12(sp)
8000d0b0:	4422                	lw	s0,8(sp)
8000d0b2:	4492                	lw	s1,4(sp)
8000d0b4:	4902                	lw	s2,0(sp)
8000d0b6:	0141                	add	sp,sp,16
8000d0b8:	8082                	ret

8000d0ba <.L24>:
8000d0ba:	557d                	li	a0,-1
8000d0bc:	bfcd                	j	8000d0ae <.L20>

Disassembly of section .text.libc.abort:

8000d0be <abort>:
8000d0be:	1141                	add	sp,sp,-16
8000d0c0:	c606                	sw	ra,12(sp)

8000d0c2 <.L27>:
8000d0c2:	4501                	li	a0,0
8000d0c4:	3f79                	jal	8000d062 <raise>
8000d0c6:	bff5                	j	8000d0c2 <.L27>

Disassembly of section .text.libc.__SEGGER_RTL_X_assert:

8000d0c8 <__SEGGER_RTL_X_assert>:
8000d0c8:	1101                	add	sp,sp,-32
8000d0ca:	cc22                	sw	s0,24(sp)
8000d0cc:	ca26                	sw	s1,20(sp)
8000d0ce:	842a                	mv	s0,a0
8000d0d0:	84ae                	mv	s1,a1
8000d0d2:	8532                	mv	a0,a2
8000d0d4:	858a                	mv	a1,sp
8000d0d6:	4629                	li	a2,10
8000d0d8:	ce06                	sw	ra,28(sp)
8000d0da:	87bfb0ef          	jal	80008954 <itoa>
8000d0de:	8526                	mv	a0,s1
8000d0e0:	373d                	jal	8000d00e <__SEGGER_RTL_puts_no_nl>
8000d0e2:	80005537          	lui	a0,0x80005
8000d0e6:	70450513          	add	a0,a0,1796 # 80005704 <.LC0>
8000d0ea:	3715                	jal	8000d00e <__SEGGER_RTL_puts_no_nl>
8000d0ec:	850a                	mv	a0,sp
8000d0ee:	3705                	jal	8000d00e <__SEGGER_RTL_puts_no_nl>
8000d0f0:	80005537          	lui	a0,0x80005
8000d0f4:	70850513          	add	a0,a0,1800 # 80005708 <.LC1>
8000d0f8:	3f19                	jal	8000d00e <__SEGGER_RTL_puts_no_nl>
8000d0fa:	8522                	mv	a0,s0
8000d0fc:	3f09                	jal	8000d00e <__SEGGER_RTL_puts_no_nl>
8000d0fe:	80005537          	lui	a0,0x80005
8000d102:	72050513          	add	a0,a0,1824 # 80005720 <.LC2>
8000d106:	3721                	jal	8000d00e <__SEGGER_RTL_puts_no_nl>
8000d108:	3f5d                	jal	8000d0be <abort>

Disassembly of section .text.libc.putchar:

8000d10a <putchar>:
8000d10a:	000807b7          	lui	a5,0x80
8000d10e:	2687a583          	lw	a1,616(a5) # 80268 <stdout>
8000d112:	8abfb06f          	j	800089bc <fputc>

Disassembly of section .text.libc.puts:

8000d116 <puts>:
8000d116:	1101                	add	sp,sp,-32
8000d118:	000807b7          	lui	a5,0x80
8000d11c:	ce06                	sw	ra,28(sp)
8000d11e:	cc22                	sw	s0,24(sp)
8000d120:	c62a                	sw	a0,12(sp)
8000d122:	2687a403          	lw	s0,616(a5) # 80268 <stdout>
8000d126:	2a3000ef          	jal	8000dbc8 <strlen>
8000d12a:	45b2                	lw	a1,12(sp)
8000d12c:	862a                	mv	a2,a0
8000d12e:	8522                	mv	a0,s0
8000d130:	c85fc0ef          	jal	80009db4 <__SEGGER_RTL_X_file_write>
8000d134:	57fd                	li	a5,-1
8000d136:	00f50763          	beq	a0,a5,8000d144 <.L53>
8000d13a:	4462                	lw	s0,24(sp)
8000d13c:	40f2                	lw	ra,28(sp)
8000d13e:	4529                	li	a0,10
8000d140:	6105                	add	sp,sp,32
8000d142:	b7e1                	j	8000d10a <putchar>

8000d144 <.L53>:
8000d144:	40f2                	lw	ra,28(sp)
8000d146:	4462                	lw	s0,24(sp)
8000d148:	6105                	add	sp,sp,32
8000d14a:	8082                	ret

Disassembly of section .text.libc.__adddf3:

8000d14c <__adddf3>:
8000d14c:	800007b7          	lui	a5,0x80000
8000d150:	00d5c8b3          	xor	a7,a1,a3
8000d154:	1008c263          	bltz	a7,8000d258 <.L__adddf3_subtract>
8000d158:	00b6e863          	bltu	a3,a1,8000d168 <.L__adddf3_add_already_ordered>
8000d15c:	8d31                	xor	a0,a0,a2
8000d15e:	8e29                	xor	a2,a2,a0
8000d160:	8d31                	xor	a0,a0,a2
8000d162:	8db5                	xor	a1,a1,a3
8000d164:	8ead                	xor	a3,a3,a1
8000d166:	8db5                	xor	a1,a1,a3

8000d168 <.L__adddf3_add_already_ordered>:
8000d168:	00159813          	sll	a6,a1,0x1
8000d16c:	01585813          	srl	a6,a6,0x15
8000d170:	00169893          	sll	a7,a3,0x1
8000d174:	0158d893          	srl	a7,a7,0x15
8000d178:	0c088063          	beqz	a7,8000d238 <.L__adddf3_add_zero>
8000d17c:	00180713          	add	a4,a6,1
8000d180:	0756                	sll	a4,a4,0x15
8000d182:	c759                	beqz	a4,8000d210 <.L__adddf3_done>
8000d184:	41180733          	sub	a4,a6,a7
8000d188:	03500293          	li	t0,53
8000d18c:	08e2e263          	bltu	t0,a4,8000d210 <.L__adddf3_done>
8000d190:	0145d813          	srl	a6,a1,0x14
8000d194:	06ae                	sll	a3,a3,0xb
8000d196:	8edd                	or	a3,a3,a5
8000d198:	82ad                	srl	a3,a3,0xb
8000d19a:	05ae                	sll	a1,a1,0xb
8000d19c:	8ddd                	or	a1,a1,a5
8000d19e:	85ad                	sra	a1,a1,0xb
8000d1a0:	02000293          	li	t0,32
8000d1a4:	06577763          	bgeu	a4,t0,8000d212 <.L__adddf3_add_shifted_word>
8000d1a8:	4881                	li	a7,0
8000d1aa:	cf01                	beqz	a4,8000d1c2 <.L__adddf3_add_no_shift>
8000d1ac:	40e002b3          	neg	t0,a4
8000d1b0:	005618b3          	sll	a7,a2,t0
8000d1b4:	00e65633          	srl	a2,a2,a4
8000d1b8:	005692b3          	sll	t0,a3,t0
8000d1bc:	9616                	add	a2,a2,t0
8000d1be:	00e6d6b3          	srl	a3,a3,a4

8000d1c2 <.L__adddf3_add_no_shift>:
8000d1c2:	9532                	add	a0,a0,a2
8000d1c4:	00c532b3          	sltu	t0,a0,a2
8000d1c8:	95b6                	add	a1,a1,a3
8000d1ca:	00d5b333          	sltu	t1,a1,a3
8000d1ce:	9596                	add	a1,a1,t0
8000d1d0:	00031463          	bnez	t1,8000d1d8 <.L__adddf3_normalization_required>
8000d1d4:	0255f163          	bgeu	a1,t0,8000d1f6 <.L__adddf3_already_normalized>

8000d1d8 <.L__adddf3_normalization_required>:
8000d1d8:	00280613          	add	a2,a6,2
8000d1dc:	0656                	sll	a2,a2,0x15
8000d1de:	c235                	beqz	a2,8000d242 <.L__adddf3_inf>
8000d1e0:	01f51613          	sll	a2,a0,0x1f
8000d1e4:	011032b3          	snez	t0,a7
8000d1e8:	005608b3          	add	a7,a2,t0
8000d1ec:	8105                	srl	a0,a0,0x1
8000d1ee:	01f59693          	sll	a3,a1,0x1f
8000d1f2:	8d55                	or	a0,a0,a3
8000d1f4:	8185                	srl	a1,a1,0x1

8000d1f6 <.L__adddf3_already_normalized>:
8000d1f6:	0805                	add	a6,a6,1
8000d1f8:	0852                	sll	a6,a6,0x14

8000d1fa <.L__adddf3_perform_rounding>:
8000d1fa:	0008da63          	bgez	a7,8000d20e <.L__adddf3_add_no_tie>
8000d1fe:	0505                	add	a0,a0,1
8000d200:	00153293          	seqz	t0,a0
8000d204:	9596                	add	a1,a1,t0
8000d206:	0886                	sll	a7,a7,0x1
8000d208:	00089363          	bnez	a7,8000d20e <.L__adddf3_add_no_tie>
8000d20c:	9979                	and	a0,a0,-2

8000d20e <.L__adddf3_add_no_tie>:
8000d20e:	95c2                	add	a1,a1,a6

8000d210 <.L__adddf3_done>:
8000d210:	8082                	ret

8000d212 <.L__adddf3_add_shifted_word>:
8000d212:	88b2                	mv	a7,a2
8000d214:	1701                	add	a4,a4,-32
8000d216:	cb11                	beqz	a4,8000d22a <.L__adddf3_already_aligned>
8000d218:	40e008b3          	neg	a7,a4
8000d21c:	011698b3          	sll	a7,a3,a7
8000d220:	00e6d6b3          	srl	a3,a3,a4
8000d224:	00c03733          	snez	a4,a2
8000d228:	98ba                	add	a7,a7,a4

8000d22a <.L__adddf3_already_aligned>:
8000d22a:	9536                	add	a0,a0,a3
8000d22c:	00d532b3          	sltu	t0,a0,a3
8000d230:	9596                	add	a1,a1,t0
8000d232:	fc55f2e3          	bgeu	a1,t0,8000d1f6 <.L__adddf3_already_normalized>
8000d236:	b74d                	j	8000d1d8 <.L__adddf3_normalization_required>

8000d238 <.L__adddf3_add_zero>:
8000d238:	fc081ce3          	bnez	a6,8000d210 <.L__adddf3_done>
8000d23c:	8dfd                	and	a1,a1,a5
8000d23e:	4501                	li	a0,0
8000d240:	bfc1                	j	8000d210 <.L__adddf3_done>

8000d242 <.L__adddf3_inf>:
8000d242:	0805                	add	a6,a6,1
8000d244:	01481593          	sll	a1,a6,0x14
8000d248:	4501                	li	a0,0
8000d24a:	b7d9                	j	8000d210 <.L__adddf3_done>

8000d24c <.L__adddf3_sub_inf_nan>:
8000d24c:	fce892e3          	bne	a7,a4,8000d210 <.L__adddf3_done>
8000d250:	7ff805b7          	lui	a1,0x7ff80
8000d254:	4501                	li	a0,0
8000d256:	bf6d                	j	8000d210 <.L__adddf3_done>

8000d258 <.L__adddf3_subtract>:
8000d258:	8ebd                	xor	a3,a3,a5
8000d25a:	00b6ed63          	bltu	a3,a1,8000d274 <.L__adddf3_sub_already_ordered>
8000d25e:	00b69463          	bne	a3,a1,8000d266 <.L__adddf3_sub_must_exchange>
8000d262:	00a66963          	bltu	a2,a0,8000d274 <.L__adddf3_sub_already_ordered>

8000d266 <.L__adddf3_sub_must_exchange>:
8000d266:	8ebd                	xor	a3,a3,a5
8000d268:	8d31                	xor	a0,a0,a2
8000d26a:	8e29                	xor	a2,a2,a0
8000d26c:	8d31                	xor	a0,a0,a2
8000d26e:	8db5                	xor	a1,a1,a3
8000d270:	8ead                	xor	a3,a3,a1
8000d272:	8db5                	xor	a1,a1,a3

8000d274 <.L__adddf3_sub_already_ordered>:
8000d274:	00b58833          	add	a6,a1,a1
8000d278:	00d688b3          	add	a7,a3,a3
8000d27c:	ffe00737          	lui	a4,0xffe00
8000d280:	fce876e3          	bgeu	a6,a4,8000d24c <.L__adddf3_sub_inf_nan>
8000d284:	01585813          	srl	a6,a6,0x15
8000d288:	0158d893          	srl	a7,a7,0x15
8000d28c:	0a088f63          	beqz	a7,8000d34a <.L__adddf3_subtracting_zero>
8000d290:	41180733          	sub	a4,a6,a7
8000d294:	03600293          	li	t0,54
8000d298:	f6e2ece3          	bltu	t0,a4,8000d210 <.L__adddf3_done>
8000d29c:	83c2                	mv	t2,a6
8000d29e:	0145d813          	srl	a6,a1,0x14
8000d2a2:	06ae                	sll	a3,a3,0xb
8000d2a4:	8edd                	or	a3,a3,a5
8000d2a6:	82ad                	srl	a3,a3,0xb
8000d2a8:	05ae                	sll	a1,a1,0xb
8000d2aa:	8ddd                	or	a1,a1,a5
8000d2ac:	81ad                	srl	a1,a1,0xb
8000d2ae:	4285                	li	t0,1
8000d2b0:	0ae2ef63          	bltu	t0,a4,8000d36e <.L__adddf3_sub_align_far>
8000d2b4:	00571a63          	bne	a4,t0,8000d2c8 <.L__adddf3_sub_already_aligned>
8000d2b8:	01f61713          	sll	a4,a2,0x1f
8000d2bc:	8205                	srl	a2,a2,0x1
8000d2be:	01f69893          	sll	a7,a3,0x1f
8000d2c2:	01166633          	or	a2,a2,a7
8000d2c6:	8285                	srl	a3,a3,0x1

8000d2c8 <.L__adddf3_sub_already_aligned>:
8000d2c8:	82aa                	mv	t0,a0
8000d2ca:	8d11                	sub	a0,a0,a2
8000d2cc:	00a2b2b3          	sltu	t0,t0,a0
8000d2d0:	8d95                	sub	a1,a1,a3
8000d2d2:	405585b3          	sub	a1,a1,t0
8000d2d6:	c711                	beqz	a4,8000d2e2 <.L__adddf3_sub_single_done>
8000d2d8:	00153293          	seqz	t0,a0
8000d2dc:	157d                	add	a0,a0,-1
8000d2de:	405585b3          	sub	a1,a1,t0

8000d2e2 <.L__adddf3_sub_single_done>:
8000d2e2:	c9ad                	beqz	a1,8000d354 <.L__adddf3_high_word_cancelled>
8000d2e4:	00b59293          	sll	t0,a1,0xb
8000d2e8:	1202ca63          	bltz	t0,8000d41c <.L__adddf3_sub_normalized>

8000d2ec <.L__adddf3_first_normalization_step>:
8000d2ec:	000522b3          	sltz	t0,a0
8000d2f0:	952a                	add	a0,a0,a0
8000d2f2:	95ae                	add	a1,a1,a1
8000d2f4:	9596                	add	a1,a1,t0
8000d2f6:	837d                	srl	a4,a4,0x1f
8000d2f8:	953a                	add	a0,a0,a4
8000d2fa:	4705                	li	a4,1

8000d2fc <.L__adddf3_try_shift_4>:
8000d2fc:	0115d293          	srl	t0,a1,0x11
8000d300:	00029963          	bnez	t0,8000d312 <.L__adddf3_cant_shift_4>
8000d304:	0711                	add	a4,a4,4 # ffe00004 <__AHB_SRAM_segment_end__+0xf9f8004>
8000d306:	0592                	sll	a1,a1,0x4
8000d308:	01c55293          	srl	t0,a0,0x1c
8000d30c:	0512                	sll	a0,a0,0x4
8000d30e:	9596                	add	a1,a1,t0
8000d310:	b7f5                	j	8000d2fc <.L__adddf3_try_shift_4>

8000d312 <.L__adddf3_cant_shift_4>:
8000d312:	00b59293          	sll	t0,a1,0xb
8000d316:	0002cc63          	bltz	t0,8000d32e <.L__adddf3_normalized>

8000d31a <.L__adddf3_normalize>:
8000d31a:	0705                	add	a4,a4,1
8000d31c:	000522b3          	sltz	t0,a0
8000d320:	952a                	add	a0,a0,a0
8000d322:	95ae                	add	a1,a1,a1
8000d324:	9596                	add	a1,a1,t0

8000d326 <.L__adddf3_pre_normalize>:
8000d326:	00b59293          	sll	t0,a1,0xb
8000d32a:	fe02d8e3          	bgez	t0,8000d31a <.L__adddf3_normalize>

8000d32e <.L__adddf3_normalized>:
8000d32e:	861e                	mv	a2,t2
8000d330:	00c77863          	bgeu	a4,a2,8000d340 <.L__adddf3_signed_zero>
8000d334:	40e80833          	sub	a6,a6,a4
8000d338:	187d                	add	a6,a6,-1
8000d33a:	0852                	sll	a6,a6,0x14
8000d33c:	95c2                	add	a1,a1,a6
8000d33e:	bdc9                	j	8000d210 <.L__adddf3_done>

8000d340 <.L__adddf3_signed_zero>:
8000d340:	00b85593          	srl	a1,a6,0xb
8000d344:	05fe                	sll	a1,a1,0x1f
8000d346:	4501                	li	a0,0
8000d348:	b5e1                	j	8000d210 <.L__adddf3_done>

8000d34a <.L__adddf3_subtracting_zero>:
8000d34a:	ec0813e3          	bnez	a6,8000d210 <.L__adddf3_done>
8000d34e:	4501                	li	a0,0
8000d350:	4581                	li	a1,0
8000d352:	bd7d                	j	8000d210 <.L__adddf3_done>

8000d354 <.L__adddf3_high_word_cancelled>:
8000d354:	00e56633          	or	a2,a0,a4
8000d358:	ea060ce3          	beqz	a2,8000d210 <.L__adddf3_done>
8000d35c:	001008b7          	lui	a7,0x100
8000d360:	f91576e3          	bgeu	a0,a7,8000d2ec <.L__adddf3_first_normalization_step>
8000d364:	85aa                	mv	a1,a0
8000d366:	853a                	mv	a0,a4
8000d368:	02000713          	li	a4,32
8000d36c:	bf6d                	j	8000d326 <.L__adddf3_pre_normalize>

8000d36e <.L__adddf3_sub_align_far>:
8000d36e:	02000293          	li	t0,32
8000d372:	04574863          	blt	a4,t0,8000d3c2 <.L__adddf3_aligned_on_top>
8000d376:	04570263          	beq	a4,t0,8000d3ba <.L__adddf3_word_aligned_on_top>
8000d37a:	1701                	add	a4,a4,-32
8000d37c:	40e002b3          	neg	t0,a4
8000d380:	00e65333          	srl	t1,a2,a4
8000d384:	005618b3          	sll	a7,a2,t0
8000d388:	00569633          	sll	a2,a3,t0
8000d38c:	961a                	add	a2,a2,t1
8000d38e:	00e6d6b3          	srl	a3,a3,a4
8000d392:	011038b3          	snez	a7,a7
8000d396:	00c8e8b3          	or	a7,a7,a2
8000d39a:	4601                	li	a2,0
8000d39c:	82aa                	mv	t0,a0
8000d39e:	8d15                	sub	a0,a0,a3
8000d3a0:	00a2b2b3          	sltu	t0,t0,a0
8000d3a4:	405585b3          	sub	a1,a1,t0
8000d3a8:	41100733          	neg	a4,a7
8000d3ac:	c729                	beqz	a4,8000d3f6 <.L__adddf3_sub_normalize>
8000d3ae:	00153293          	seqz	t0,a0
8000d3b2:	157d                	add	a0,a0,-1
8000d3b4:	405585b3          	sub	a1,a1,t0
8000d3b8:	a83d                	j	8000d3f6 <.L__adddf3_sub_normalize>

8000d3ba <.L__adddf3_word_aligned_on_top>:
8000d3ba:	88b2                	mv	a7,a2
8000d3bc:	8636                	mv	a2,a3
8000d3be:	4681                	li	a3,0
8000d3c0:	a821                	j	8000d3d8 <.L__adddf3_aligned_subtract>

8000d3c2 <.L__adddf3_aligned_on_top>:
8000d3c2:	40e002b3          	neg	t0,a4
8000d3c6:	00e65333          	srl	t1,a2,a4
8000d3ca:	005618b3          	sll	a7,a2,t0
8000d3ce:	00569633          	sll	a2,a3,t0
8000d3d2:	961a                	add	a2,a2,t1
8000d3d4:	00e6d6b3          	srl	a3,a3,a4

8000d3d8 <.L__adddf3_aligned_subtract>:
8000d3d8:	82aa                	mv	t0,a0
8000d3da:	8d11                	sub	a0,a0,a2
8000d3dc:	00a2b2b3          	sltu	t0,t0,a0
8000d3e0:	8d95                	sub	a1,a1,a3
8000d3e2:	405585b3          	sub	a1,a1,t0
8000d3e6:	41100733          	neg	a4,a7
8000d3ea:	c711                	beqz	a4,8000d3f6 <.L__adddf3_sub_normalize>
8000d3ec:	00153293          	seqz	t0,a0
8000d3f0:	157d                	add	a0,a0,-1
8000d3f2:	405585b3          	sub	a1,a1,t0

8000d3f6 <.L__adddf3_sub_normalize>:
8000d3f6:	00c59893          	sll	a7,a1,0xc
8000d3fa:	00b59293          	sll	t0,a1,0xb
8000d3fe:	0002cf63          	bltz	t0,8000d41c <.L__adddf3_sub_normalized>
8000d402:	187d                	add	a6,a6,-1
8000d404:	000522b3          	sltz	t0,a0
8000d408:	952a                	add	a0,a0,a0
8000d40a:	95ae                	add	a1,a1,a1
8000d40c:	9596                	add	a1,a1,t0
8000d40e:	000722b3          	sltz	t0,a4
8000d412:	973a                	add	a4,a4,a4
8000d414:	9516                	add	a0,a0,t0
8000d416:	005532b3          	sltu	t0,a0,t0
8000d41a:	9596                	add	a1,a1,t0

8000d41c <.L__adddf3_sub_normalized>:
8000d41c:	187d                	add	a6,a6,-1
8000d41e:	0852                	sll	a6,a6,0x14
8000d420:	88ba                	mv	a7,a4
8000d422:	bbe1                	j	8000d1fa <.L__adddf3_perform_rounding>

Disassembly of section .text.libc.__mulsf3:

8000d424 <__mulsf3>:
8000d424:	80000737          	lui	a4,0x80000
8000d428:	0ff00293          	li	t0,255
8000d42c:	00b547b3          	xor	a5,a0,a1
8000d430:	8ff9                	and	a5,a5,a4
8000d432:	00151613          	sll	a2,a0,0x1
8000d436:	8261                	srl	a2,a2,0x18
8000d438:	00159693          	sll	a3,a1,0x1
8000d43c:	82e1                	srl	a3,a3,0x18
8000d43e:	ce29                	beqz	a2,8000d498 <.L__mulsf3_lhs_zero_or_subnormal>
8000d440:	c6bd                	beqz	a3,8000d4ae <.L__mulsf3_rhs_zero_or_subnormal>
8000d442:	04560f63          	beq	a2,t0,8000d4a0 <.L__mulsf3_lhs_inf_or_nan>
8000d446:	06568963          	beq	a3,t0,8000d4b8 <.L__mulsf3_rhs_inf_or_nan>
8000d44a:	9636                	add	a2,a2,a3
8000d44c:	0522                	sll	a0,a0,0x8
8000d44e:	8d59                	or	a0,a0,a4
8000d450:	05a2                	sll	a1,a1,0x8
8000d452:	8dd9                	or	a1,a1,a4
8000d454:	02b506b3          	mul	a3,a0,a1
8000d458:	02b53533          	mulhu	a0,a0,a1
8000d45c:	00d036b3          	snez	a3,a3
8000d460:	8d55                	or	a0,a0,a3
8000d462:	00054463          	bltz	a0,8000d46a <.L__mulsf3_normalized>
8000d466:	0506                	sll	a0,a0,0x1
8000d468:	167d                	add	a2,a2,-1

8000d46a <.L__mulsf3_normalized>:
8000d46a:	f8160613          	add	a2,a2,-127
8000d46e:	04064863          	bltz	a2,8000d4be <.L__mulsf3_zero_or_underflow>
8000d472:	12fd                	add	t0,t0,-1
8000d474:	00565f63          	bge	a2,t0,8000d492 <.L__mulsf3_inf>
8000d478:	01851693          	sll	a3,a0,0x18
8000d47c:	8121                	srl	a0,a0,0x8
8000d47e:	065e                	sll	a2,a2,0x17
8000d480:	9532                	add	a0,a0,a2
8000d482:	0006d663          	bgez	a3,8000d48e <.L__mulsf3_apply_sign>
8000d486:	0505                	add	a0,a0,1
8000d488:	0686                	sll	a3,a3,0x1
8000d48a:	e291                	bnez	a3,8000d48e <.L__mulsf3_apply_sign>
8000d48c:	9979                	and	a0,a0,-2

8000d48e <.L__mulsf3_apply_sign>:
8000d48e:	8d5d                	or	a0,a0,a5
8000d490:	8082                	ret

8000d492 <.L__mulsf3_inf>:
8000d492:	7f800537          	lui	a0,0x7f800
8000d496:	bfe5                	j	8000d48e <.L__mulsf3_apply_sign>

8000d498 <.L__mulsf3_lhs_zero_or_subnormal>:
8000d498:	00568d63          	beq	a3,t0,8000d4b2 <.L__mulsf3_nan>

8000d49c <.L__mulsf3_signed_zero>:
8000d49c:	853e                	mv	a0,a5
8000d49e:	8082                	ret

8000d4a0 <.L__mulsf3_lhs_inf_or_nan>:
8000d4a0:	0526                	sll	a0,a0,0x9
8000d4a2:	e901                	bnez	a0,8000d4b2 <.L__mulsf3_nan>
8000d4a4:	fe5697e3          	bne	a3,t0,8000d492 <.L__mulsf3_inf>
8000d4a8:	05a6                	sll	a1,a1,0x9
8000d4aa:	e581                	bnez	a1,8000d4b2 <.L__mulsf3_nan>
8000d4ac:	b7dd                	j	8000d492 <.L__mulsf3_inf>

8000d4ae <.L__mulsf3_rhs_zero_or_subnormal>:
8000d4ae:	fe5617e3          	bne	a2,t0,8000d49c <.L__mulsf3_signed_zero>

8000d4b2 <.L__mulsf3_nan>:
8000d4b2:	7fc00537          	lui	a0,0x7fc00
8000d4b6:	8082                	ret

8000d4b8 <.L__mulsf3_rhs_inf_or_nan>:
8000d4b8:	05a6                	sll	a1,a1,0x9
8000d4ba:	fde5                	bnez	a1,8000d4b2 <.L__mulsf3_nan>
8000d4bc:	bfd9                	j	8000d492 <.L__mulsf3_inf>

8000d4be <.L__mulsf3_zero_or_underflow>:
8000d4be:	0605                	add	a2,a2,1
8000d4c0:	fe71                	bnez	a2,8000d49c <.L__mulsf3_signed_zero>
8000d4c2:	8521                	sra	a0,a0,0x8
8000d4c4:	00150293          	add	t0,a0,1 # 7fc00001 <_flash_size+0x7fb00001>
8000d4c8:	0509                	add	a0,a0,2
8000d4ca:	fc0299e3          	bnez	t0,8000d49c <.L__mulsf3_signed_zero>
8000d4ce:	00800537          	lui	a0,0x800
8000d4d2:	bf75                	j	8000d48e <.L__mulsf3_apply_sign>

Disassembly of section .text.libc.__muldf3:

8000d4d4 <__muldf3>:
8000d4d4:	800008b7          	lui	a7,0x80000
8000d4d8:	00d5c833          	xor	a6,a1,a3
8000d4dc:	01187eb3          	and	t4,a6,a7
8000d4e0:	00b58733          	add	a4,a1,a1
8000d4e4:	00d687b3          	add	a5,a3,a3
8000d4e8:	ffe00837          	lui	a6,0xffe00
8000d4ec:	0d077363          	bgeu	a4,a6,8000d5b2 <.L__muldf3_lhs_nan_or_inf>
8000d4f0:	0d07ff63          	bgeu	a5,a6,8000d5ce <.L__muldf3_rhs_nan_or_inf>
8000d4f4:	8355                	srl	a4,a4,0x15
8000d4f6:	c76d                	beqz	a4,8000d5e0 <.L__muldf3_signed_zero>
8000d4f8:	83d5                	srl	a5,a5,0x15
8000d4fa:	c3fd                	beqz	a5,8000d5e0 <.L__muldf3_signed_zero>
8000d4fc:	06ae                	sll	a3,a3,0xb
8000d4fe:	0116e6b3          	or	a3,a3,a7
8000d502:	82ad                	srl	a3,a3,0xb
8000d504:	05ae                	sll	a1,a1,0xb
8000d506:	0115e5b3          	or	a1,a1,a7
8000d50a:	01555813          	srl	a6,a0,0x15
8000d50e:	052e                	sll	a0,a0,0xb
8000d510:	010582b3          	add	t0,a1,a6
8000d514:	00f70333          	add	t1,a4,a5
8000d518:	02c50733          	mul	a4,a0,a2
8000d51c:	02c537b3          	mulhu	a5,a0,a2
8000d520:	02d50833          	mul	a6,a0,a3
8000d524:	02d538b3          	mulhu	a7,a0,a3
8000d528:	983e                	add	a6,a6,a5
8000d52a:	00f837b3          	sltu	a5,a6,a5
8000d52e:	98be                	add	a7,a7,a5
8000d530:	02c28533          	mul	a0,t0,a2
8000d534:	02c2b5b3          	mulhu	a1,t0,a2
8000d538:	982a                	add	a6,a6,a0
8000d53a:	00a83533          	sltu	a0,a6,a0
8000d53e:	98ae                	add	a7,a7,a1
8000d540:	00b8b5b3          	sltu	a1,a7,a1
8000d544:	98aa                	add	a7,a7,a0
8000d546:	00a8b533          	sltu	a0,a7,a0
8000d54a:	00b50633          	add	a2,a0,a1
8000d54e:	02d28533          	mul	a0,t0,a3
8000d552:	02d2b5b3          	mulhu	a1,t0,a3
8000d556:	9546                	add	a0,a0,a7
8000d558:	011538b3          	sltu	a7,a0,a7
8000d55c:	95c6                	add	a1,a1,a7
8000d55e:	95b2                	add	a1,a1,a2
8000d560:	00e03733          	snez	a4,a4
8000d564:	00e86833          	or	a6,a6,a4
8000d568:	871a                	mv	a4,t1
8000d56a:	00b59293          	sll	t0,a1,0xb
8000d56e:	0002cc63          	bltz	t0,8000d586 <.L__muldf3_normalized>
8000d572:	000822b3          	sltz	t0,a6
8000d576:	9842                	add	a6,a6,a6
8000d578:	00052333          	sltz	t1,a0
8000d57c:	952a                	add	a0,a0,a0
8000d57e:	9516                	add	a0,a0,t0
8000d580:	95ae                	add	a1,a1,a1
8000d582:	959a                	add	a1,a1,t1
8000d584:	177d                	add	a4,a4,-1 # 7fffffff <_flash_size+0x7fefffff>

8000d586 <.L__muldf3_normalized>:
8000d586:	3ff00793          	li	a5,1023
8000d58a:	8f1d                	sub	a4,a4,a5
8000d58c:	04074a63          	bltz	a4,8000d5e0 <.L__muldf3_signed_zero>
8000d590:	0786                	sll	a5,a5,0x1
8000d592:	04f75363          	bge	a4,a5,8000d5d8 <.L__muldf3_inf>
8000d596:	0752                	sll	a4,a4,0x14
8000d598:	95ba                	add	a1,a1,a4
8000d59a:	00085a63          	bgez	a6,8000d5ae <.L__muldf3_apply_sign>
8000d59e:	0505                	add	a0,a0,1 # 800001 <_flash_size+0x700001>
8000d5a0:	00153613          	seqz	a2,a0
8000d5a4:	95b2                	add	a1,a1,a2
8000d5a6:	0806                	sll	a6,a6,0x1
8000d5a8:	00081363          	bnez	a6,8000d5ae <.L__muldf3_apply_sign>
8000d5ac:	9979                	and	a0,a0,-2

8000d5ae <.L__muldf3_apply_sign>:
8000d5ae:	95f6                	add	a1,a1,t4
8000d5b0:	8082                	ret

8000d5b2 <.L__muldf3_lhs_nan_or_inf>:
8000d5b2:	01071a63          	bne	a4,a6,8000d5c6 <.L__muldf3_nan>
8000d5b6:	e901                	bnez	a0,8000d5c6 <.L__muldf3_nan>
8000d5b8:	00f86763          	bltu	a6,a5,8000d5c6 <.L__muldf3_nan>
8000d5bc:	0107e363          	bltu	a5,a6,8000d5c2 <.L__muldf3_rhs_could_be_zero>
8000d5c0:	e219                	bnez	a2,8000d5c6 <.L__muldf3_nan>

8000d5c2 <.L__muldf3_rhs_could_be_zero>:
8000d5c2:	83d5                	srl	a5,a5,0x15
8000d5c4:	eb91                	bnez	a5,8000d5d8 <.L__muldf3_inf>

8000d5c6 <.L__muldf3_nan>:
8000d5c6:	7ff805b7          	lui	a1,0x7ff80

8000d5ca <.L__muldf3_load_zero_lo>:
8000d5ca:	4501                	li	a0,0
8000d5cc:	8082                	ret

8000d5ce <.L__muldf3_rhs_nan_or_inf>:
8000d5ce:	ff079ce3          	bne	a5,a6,8000d5c6 <.L__muldf3_nan>
8000d5d2:	fa75                	bnez	a2,8000d5c6 <.L__muldf3_nan>
8000d5d4:	8355                	srl	a4,a4,0x15
8000d5d6:	db65                	beqz	a4,8000d5c6 <.L__muldf3_nan>

8000d5d8 <.L__muldf3_inf>:
8000d5d8:	7ff005b7          	lui	a1,0x7ff00
8000d5dc:	4501                	li	a0,0
8000d5de:	bfc1                	j	8000d5ae <.L__muldf3_apply_sign>

8000d5e0 <.L__muldf3_signed_zero>:
8000d5e0:	85f6                	mv	a1,t4
8000d5e2:	b7e5                	j	8000d5ca <.L__muldf3_load_zero_lo>

Disassembly of section .text.libc.__divsf3:

8000d5e4 <__divsf3>:
8000d5e4:	0ff00293          	li	t0,255
8000d5e8:	00151713          	sll	a4,a0,0x1
8000d5ec:	8361                	srl	a4,a4,0x18
8000d5ee:	00159793          	sll	a5,a1,0x1
8000d5f2:	83e1                	srl	a5,a5,0x18
8000d5f4:	00b54333          	xor	t1,a0,a1
8000d5f8:	01f35313          	srl	t1,t1,0x1f
8000d5fc:	037e                	sll	t1,t1,0x1f
8000d5fe:	cf5d                	beqz	a4,8000d6bc <.L__divsf3_lhs_zero_or_subnormal>
8000d600:	cbf9                	beqz	a5,8000d6d6 <.L__divsf3_rhs_zero_or_subnormal>
8000d602:	0c570563          	beq	a4,t0,8000d6cc <.L__divsf3_lhs_inf_or_nan>
8000d606:	0c578d63          	beq	a5,t0,8000d6e0 <.L__divsf3_rhs_inf_or_nan>
8000d60a:	8f1d                	sub	a4,a4,a5
8000d60c:	800052b7          	lui	t0,0x80005
8000d610:	fb428293          	add	t0,t0,-76 # 80004fb4 <__SEGGER_RTL_fdiv_reciprocal_table>
8000d614:	00f5d693          	srl	a3,a1,0xf
8000d618:	0fc6f693          	and	a3,a3,252
8000d61c:	9696                	add	a3,a3,t0
8000d61e:	429c                	lw	a5,0(a3)
8000d620:	4187d613          	sra	a2,a5,0x18
8000d624:	00f59693          	sll	a3,a1,0xf
8000d628:	82e1                	srl	a3,a3,0x18
8000d62a:	0016f293          	and	t0,a3,1
8000d62e:	8285                	srl	a3,a3,0x1
8000d630:	fc068693          	add	a3,a3,-64
8000d634:	9696                	add	a3,a3,t0
8000d636:	02d60633          	mul	a2,a2,a3
8000d63a:	07a2                	sll	a5,a5,0x8
8000d63c:	83a1                	srl	a5,a5,0x8
8000d63e:	963e                	add	a2,a2,a5
8000d640:	05a2                	sll	a1,a1,0x8
8000d642:	81a1                	srl	a1,a1,0x8
8000d644:	008007b7          	lui	a5,0x800
8000d648:	8ddd                	or	a1,a1,a5
8000d64a:	02c586b3          	mul	a3,a1,a2
8000d64e:	0522                	sll	a0,a0,0x8
8000d650:	8121                	srl	a0,a0,0x8
8000d652:	8d5d                	or	a0,a0,a5
8000d654:	02c697b3          	mulh	a5,a3,a2
8000d658:	00b532b3          	sltu	t0,a0,a1
8000d65c:	00551533          	sll	a0,a0,t0
8000d660:	40570733          	sub	a4,a4,t0
8000d664:	01465693          	srl	a3,a2,0x14
8000d668:	8a85                	and	a3,a3,1
8000d66a:	0016c693          	xor	a3,a3,1
8000d66e:	062e                	sll	a2,a2,0xb
8000d670:	8e1d                	sub	a2,a2,a5
8000d672:	8e15                	sub	a2,a2,a3
8000d674:	050a                	sll	a0,a0,0x2
8000d676:	02a617b3          	mulh	a5,a2,a0
8000d67a:	07e70613          	add	a2,a4,126
8000d67e:	055a                	sll	a0,a0,0x16
8000d680:	8d0d                	sub	a0,a0,a1
8000d682:	02b786b3          	mul	a3,a5,a1
8000d686:	0fe00293          	li	t0,254
8000d68a:	00567f63          	bgeu	a2,t0,8000d6a8 <.L__divsf3_underflow_or_overflow>
8000d68e:	40a68533          	sub	a0,a3,a0
8000d692:	000522b3          	sltz	t0,a0
8000d696:	9796                	add	a5,a5,t0
8000d698:	0017f513          	and	a0,a5,1
8000d69c:	8385                	srl	a5,a5,0x1
8000d69e:	953e                	add	a0,a0,a5
8000d6a0:	065e                	sll	a2,a2,0x17
8000d6a2:	9532                	add	a0,a0,a2
8000d6a4:	951a                	add	a0,a0,t1
8000d6a6:	8082                	ret

8000d6a8 <.L__divsf3_underflow_or_overflow>:
8000d6a8:	851a                	mv	a0,t1
8000d6aa:	00564563          	blt	a2,t0,8000d6b4 <.L__divsf3_done>
8000d6ae:	7f800337          	lui	t1,0x7f800

8000d6b2 <.L__divsf3_apply_sign>:
8000d6b2:	951a                	add	a0,a0,t1

8000d6b4 <.L__divsf3_done>:
8000d6b4:	8082                	ret

8000d6b6 <.L__divsf3_inf>:
8000d6b6:	7f800537          	lui	a0,0x7f800
8000d6ba:	bfe5                	j	8000d6b2 <.L__divsf3_apply_sign>

8000d6bc <.L__divsf3_lhs_zero_or_subnormal>:
8000d6bc:	c789                	beqz	a5,8000d6c6 <.L__divsf3_nan>
8000d6be:	02579363          	bne	a5,t0,8000d6e4 <.L__divsf3_signed_zero>
8000d6c2:	05a6                	sll	a1,a1,0x9
8000d6c4:	c185                	beqz	a1,8000d6e4 <.L__divsf3_signed_zero>

8000d6c6 <.L__divsf3_nan>:
8000d6c6:	7fc00537          	lui	a0,0x7fc00
8000d6ca:	8082                	ret

8000d6cc <.L__divsf3_lhs_inf_or_nan>:
8000d6cc:	0526                	sll	a0,a0,0x9
8000d6ce:	fd65                	bnez	a0,8000d6c6 <.L__divsf3_nan>
8000d6d0:	fe5793e3          	bne	a5,t0,8000d6b6 <.L__divsf3_inf>
8000d6d4:	bfcd                	j	8000d6c6 <.L__divsf3_nan>

8000d6d6 <.L__divsf3_rhs_zero_or_subnormal>:
8000d6d6:	fe5710e3          	bne	a4,t0,8000d6b6 <.L__divsf3_inf>
8000d6da:	0526                	sll	a0,a0,0x9
8000d6dc:	f56d                	bnez	a0,8000d6c6 <.L__divsf3_nan>
8000d6de:	bfe1                	j	8000d6b6 <.L__divsf3_inf>

8000d6e0 <.L__divsf3_rhs_inf_or_nan>:
8000d6e0:	05a6                	sll	a1,a1,0x9
8000d6e2:	f1f5                	bnez	a1,8000d6c6 <.L__divsf3_nan>

8000d6e4 <.L__divsf3_signed_zero>:
8000d6e4:	851a                	mv	a0,t1
8000d6e6:	8082                	ret

Disassembly of section .text.libc.__divdf3:

8000d6e8 <__divdf3>:
8000d6e8:	00169813          	sll	a6,a3,0x1
8000d6ec:	01585813          	srl	a6,a6,0x15
8000d6f0:	00159893          	sll	a7,a1,0x1
8000d6f4:	0158d893          	srl	a7,a7,0x15
8000d6f8:	00d5c3b3          	xor	t2,a1,a3
8000d6fc:	01f3d393          	srl	t2,t2,0x1f
8000d700:	03fe                	sll	t2,t2,0x1f
8000d702:	7ff00293          	li	t0,2047
8000d706:	16588e63          	beq	a7,t0,8000d882 <.L__divdf3_inf_nan_over>
8000d70a:	18080a63          	beqz	a6,8000d89e <.L__divdf3_div_zero>
8000d70e:	18580263          	beq	a6,t0,8000d892 <.L__divdf3_div_inf_nan>
8000d712:	18088263          	beqz	a7,8000d896 <.L__divdf3_signed_zero>
8000d716:	410888b3          	sub	a7,a7,a6
8000d71a:	3ff88893          	add	a7,a7,1023 # 800003ff <_flash_size+0x7ff003ff>
8000d71e:	05b2                	sll	a1,a1,0xc
8000d720:	81b1                	srl	a1,a1,0xc
8000d722:	06b2                	sll	a3,a3,0xc
8000d724:	82b1                	srl	a3,a3,0xc
8000d726:	00100737          	lui	a4,0x100
8000d72a:	8dd9                	or	a1,a1,a4
8000d72c:	8ed9                	or	a3,a3,a4
8000d72e:	00c53733          	sltu	a4,a0,a2
8000d732:	9736                	add	a4,a4,a3
8000d734:	8d99                	sub	a1,a1,a4
8000d736:	8d11                	sub	a0,a0,a2
8000d738:	0005dd63          	bgez	a1,8000d752 <.L__divdf3_can_subtract>
8000d73c:	00052733          	sltz	a4,a0
8000d740:	95ae                	add	a1,a1,a1
8000d742:	95ba                	add	a1,a1,a4
8000d744:	95b6                	add	a1,a1,a3
8000d746:	952a                	add	a0,a0,a0
8000d748:	9532                	add	a0,a0,a2
8000d74a:	00c53733          	sltu	a4,a0,a2
8000d74e:	95ba                	add	a1,a1,a4
8000d750:	18fd                	add	a7,a7,-1

8000d752 <.L__divdf3_can_subtract>:
8000d752:	1258dd63          	bge	a7,t0,8000d88c <.L__divdf3_signed_inf>
8000d756:	15105063          	blez	a7,8000d896 <.L__divdf3_signed_zero>
8000d75a:	05aa                	sll	a1,a1,0xa
8000d75c:	01655713          	srl	a4,a0,0x16
8000d760:	8dd9                	or	a1,a1,a4
8000d762:	052a                	sll	a0,a0,0xa
8000d764:	02d5d833          	divu	a6,a1,a3
8000d768:	02d80e33          	mul	t3,a6,a3
8000d76c:	41c585b3          	sub	a1,a1,t3
8000d770:	02c80733          	mul	a4,a6,a2
8000d774:	02c837b3          	mulhu	a5,a6,a2
8000d778:	00e53e33          	sltu	t3,a0,a4
8000d77c:	97f2                	add	a5,a5,t3
8000d77e:	8d19                	sub	a0,a0,a4
8000d780:	8d9d                	sub	a1,a1,a5
8000d782:	0005d863          	bgez	a1,8000d792 <.L__divdf3_qdash_correct_1>
8000d786:	187d                	add	a6,a6,-1 # ffdfffff <__AHB_SRAM_segment_end__+0xf9f7fff>
8000d788:	9532                	add	a0,a0,a2
8000d78a:	95b6                	add	a1,a1,a3
8000d78c:	00c532b3          	sltu	t0,a0,a2
8000d790:	9596                	add	a1,a1,t0

8000d792 <.L__divdf3_qdash_correct_1>:
8000d792:	05aa                	sll	a1,a1,0xa
8000d794:	01655293          	srl	t0,a0,0x16
8000d798:	9596                	add	a1,a1,t0
8000d79a:	052a                	sll	a0,a0,0xa
8000d79c:	02d5d2b3          	divu	t0,a1,a3
8000d7a0:	02d28733          	mul	a4,t0,a3
8000d7a4:	8d99                	sub	a1,a1,a4
8000d7a6:	02c28733          	mul	a4,t0,a2
8000d7aa:	02c2b7b3          	mulhu	a5,t0,a2
8000d7ae:	00e53e33          	sltu	t3,a0,a4
8000d7b2:	97f2                	add	a5,a5,t3
8000d7b4:	8d19                	sub	a0,a0,a4
8000d7b6:	8d9d                	sub	a1,a1,a5
8000d7b8:	0005d863          	bgez	a1,8000d7c8 <.L__divdf3_qdash_correct_2>
8000d7bc:	12fd                	add	t0,t0,-1
8000d7be:	9532                	add	a0,a0,a2
8000d7c0:	95b6                	add	a1,a1,a3
8000d7c2:	00c53e33          	sltu	t3,a0,a2
8000d7c6:	95f2                	add	a1,a1,t3

8000d7c8 <.L__divdf3_qdash_correct_2>:
8000d7c8:	082a                	sll	a6,a6,0xa
8000d7ca:	9816                	add	a6,a6,t0
8000d7cc:	05ae                	sll	a1,a1,0xb
8000d7ce:	01555e13          	srl	t3,a0,0x15
8000d7d2:	95f2                	add	a1,a1,t3
8000d7d4:	052e                	sll	a0,a0,0xb
8000d7d6:	02d5d2b3          	divu	t0,a1,a3
8000d7da:	02d28733          	mul	a4,t0,a3
8000d7de:	8d99                	sub	a1,a1,a4
8000d7e0:	02c28733          	mul	a4,t0,a2
8000d7e4:	02c2b7b3          	mulhu	a5,t0,a2
8000d7e8:	00e53e33          	sltu	t3,a0,a4
8000d7ec:	97f2                	add	a5,a5,t3
8000d7ee:	8d19                	sub	a0,a0,a4
8000d7f0:	8d9d                	sub	a1,a1,a5
8000d7f2:	0005d863          	bgez	a1,8000d802 <.L__divdf3_qdash_correct_3>
8000d7f6:	12fd                	add	t0,t0,-1
8000d7f8:	9532                	add	a0,a0,a2
8000d7fa:	95b6                	add	a1,a1,a3
8000d7fc:	00c53e33          	sltu	t3,a0,a2
8000d800:	95f2                	add	a1,a1,t3

8000d802 <.L__divdf3_qdash_correct_3>:
8000d802:	05ae                	sll	a1,a1,0xb
8000d804:	01555e13          	srl	t3,a0,0x15
8000d808:	95f2                	add	a1,a1,t3
8000d80a:	052e                	sll	a0,a0,0xb
8000d80c:	02d5d333          	divu	t1,a1,a3
8000d810:	02d30733          	mul	a4,t1,a3
8000d814:	8d99                	sub	a1,a1,a4
8000d816:	02c30733          	mul	a4,t1,a2
8000d81a:	02c337b3          	mulhu	a5,t1,a2
8000d81e:	00e53e33          	sltu	t3,a0,a4
8000d822:	97f2                	add	a5,a5,t3
8000d824:	8d19                	sub	a0,a0,a4
8000d826:	8d9d                	sub	a1,a1,a5
8000d828:	0005d863          	bgez	a1,8000d838 <.L__divdf3_qdash_correct_4>
8000d82c:	137d                	add	t1,t1,-1 # 7f7fffff <_flash_size+0x7f6fffff>
8000d82e:	9532                	add	a0,a0,a2
8000d830:	95b6                	add	a1,a1,a3
8000d832:	00c53e33          	sltu	t3,a0,a2
8000d836:	95f2                	add	a1,a1,t3

8000d838 <.L__divdf3_qdash_correct_4>:
8000d838:	02d6                	sll	t0,t0,0x15
8000d83a:	032a                	sll	t1,t1,0xa
8000d83c:	929a                	add	t0,t0,t1
8000d83e:	05ae                	sll	a1,a1,0xb
8000d840:	01555e13          	srl	t3,a0,0x15
8000d844:	95f2                	add	a1,a1,t3
8000d846:	052e                	sll	a0,a0,0xb
8000d848:	02d5d333          	divu	t1,a1,a3
8000d84c:	02d30733          	mul	a4,t1,a3
8000d850:	8d99                	sub	a1,a1,a4
8000d852:	02c30733          	mul	a4,t1,a2
8000d856:	02c337b3          	mulhu	a5,t1,a2
8000d85a:	00e53e33          	sltu	t3,a0,a4
8000d85e:	97f2                	add	a5,a5,t3
8000d860:	8d9d                	sub	a1,a1,a5
8000d862:	85fd                	sra	a1,a1,0x1f
8000d864:	932e                	add	t1,t1,a1
8000d866:	08d2                	sll	a7,a7,0x14
8000d868:	011805b3          	add	a1,a6,a7
8000d86c:	00135513          	srl	a0,t1,0x1
8000d870:	9516                	add	a0,a0,t0
8000d872:	00137313          	and	t1,t1,1
8000d876:	951a                	add	a0,a0,t1
8000d878:	00653733          	sltu	a4,a0,t1
8000d87c:	95ba                	add	a1,a1,a4
8000d87e:	959e                	add	a1,a1,t2
8000d880:	8082                	ret

8000d882 <.L__divdf3_inf_nan_over>:
8000d882:	05b2                	sll	a1,a1,0xc
8000d884:	00580f63          	beq	a6,t0,8000d8a2 <.L__divdf3_return_nan>
8000d888:	8dc9                	or	a1,a1,a0
8000d88a:	ed81                	bnez	a1,8000d8a2 <.L__divdf3_return_nan>

8000d88c <.L__divdf3_signed_inf>:
8000d88c:	7ff005b7          	lui	a1,0x7ff00
8000d890:	a021                	j	8000d898 <.L__divdf3_apply_sign>

8000d892 <.L__divdf3_div_inf_nan>:
8000d892:	06b2                	sll	a3,a3,0xc
8000d894:	e699                	bnez	a3,8000d8a2 <.L__divdf3_return_nan>

8000d896 <.L__divdf3_signed_zero>:
8000d896:	4581                	li	a1,0

8000d898 <.L__divdf3_apply_sign>:
8000d898:	959e                	add	a1,a1,t2

8000d89a <.L__divdf3_clr_low_ret>:
8000d89a:	4501                	li	a0,0
8000d89c:	8082                	ret

8000d89e <.L__divdf3_div_zero>:
8000d89e:	fe0897e3          	bnez	a7,8000d88c <.L__divdf3_signed_inf>

8000d8a2 <.L__divdf3_return_nan>:
8000d8a2:	7ff805b7          	lui	a1,0x7ff80
8000d8a6:	bfd5                	j	8000d89a <.L__divdf3_clr_low_ret>

Disassembly of section .text.libc.__eqsf2:

8000d8a8 <__eqsf2>:
8000d8a8:	ff000637          	lui	a2,0xff000
8000d8ac:	00151693          	sll	a3,a0,0x1
8000d8b0:	02d66063          	bltu	a2,a3,8000d8d0 <.L__eqsf2_one>
8000d8b4:	00159693          	sll	a3,a1,0x1
8000d8b8:	00d66c63          	bltu	a2,a3,8000d8d0 <.L__eqsf2_one>
8000d8bc:	00b56633          	or	a2,a0,a1
8000d8c0:	0606                	sll	a2,a2,0x1
8000d8c2:	c609                	beqz	a2,8000d8cc <.L__eqsf2_zero>
8000d8c4:	8d0d                	sub	a0,a0,a1
8000d8c6:	00a03533          	snez	a0,a0
8000d8ca:	8082                	ret

8000d8cc <.L__eqsf2_zero>:
8000d8cc:	4501                	li	a0,0
8000d8ce:	8082                	ret

8000d8d0 <.L__eqsf2_one>:
8000d8d0:	4505                	li	a0,1
8000d8d2:	8082                	ret

Disassembly of section .text.libc.__fixunssfdi:

8000d8d4 <__fixunssfdi>:
8000d8d4:	04054a63          	bltz	a0,8000d928 <.L__fixunssfdi_zero_result>
8000d8d8:	00151613          	sll	a2,a0,0x1
8000d8dc:	8261                	srl	a2,a2,0x18
8000d8de:	f8160613          	add	a2,a2,-127 # feffff81 <__AHB_SRAM_segment_end__+0xebf7f81>
8000d8e2:	04064363          	bltz	a2,8000d928 <.L__fixunssfdi_zero_result>
8000d8e6:	800006b7          	lui	a3,0x80000
8000d8ea:	02000293          	li	t0,32
8000d8ee:	00565b63          	bge	a2,t0,8000d904 <.L__fixunssfdi_long_shift>
8000d8f2:	40c00633          	neg	a2,a2
8000d8f6:	067d                	add	a2,a2,31
8000d8f8:	0522                	sll	a0,a0,0x8
8000d8fa:	8d55                	or	a0,a0,a3
8000d8fc:	00c55533          	srl	a0,a0,a2
8000d900:	4581                	li	a1,0
8000d902:	8082                	ret

8000d904 <.L__fixunssfdi_long_shift>:
8000d904:	40c00633          	neg	a2,a2
8000d908:	03f60613          	add	a2,a2,63
8000d90c:	02064163          	bltz	a2,8000d92e <.L__fixunssfdi_overflow_result>
8000d910:	00851593          	sll	a1,a0,0x8
8000d914:	8dd5                	or	a1,a1,a3
8000d916:	4501                	li	a0,0
8000d918:	c619                	beqz	a2,8000d926 <.L__fixunssfdi_shift_32>
8000d91a:	40c006b3          	neg	a3,a2
8000d91e:	00d59533          	sll	a0,a1,a3
8000d922:	00c5d5b3          	srl	a1,a1,a2

8000d926 <.L__fixunssfdi_shift_32>:
8000d926:	8082                	ret

8000d928 <.L__fixunssfdi_zero_result>:
8000d928:	4501                	li	a0,0
8000d92a:	4581                	li	a1,0
8000d92c:	8082                	ret

8000d92e <.L__fixunssfdi_overflow_result>:
8000d92e:	557d                	li	a0,-1
8000d930:	55fd                	li	a1,-1
8000d932:	8082                	ret

Disassembly of section .text.libc.__floatunsidf:

8000d934 <__floatunsidf>:
8000d934:	c131                	beqz	a0,8000d978 <.L__floatunsidf_zero>
8000d936:	41d00613          	li	a2,1053
8000d93a:	01055693          	srl	a3,a0,0x10
8000d93e:	e299                	bnez	a3,8000d944 <.L1^B9>
8000d940:	0542                	sll	a0,a0,0x10
8000d942:	1641                	add	a2,a2,-16

8000d944 <.L1^B9>:
8000d944:	01855693          	srl	a3,a0,0x18
8000d948:	e299                	bnez	a3,8000d94e <.L2^B9>
8000d94a:	0522                	sll	a0,a0,0x8
8000d94c:	1661                	add	a2,a2,-8

8000d94e <.L2^B9>:
8000d94e:	01c55693          	srl	a3,a0,0x1c
8000d952:	e299                	bnez	a3,8000d958 <.L3^B7>
8000d954:	0512                	sll	a0,a0,0x4
8000d956:	1671                	add	a2,a2,-4

8000d958 <.L3^B7>:
8000d958:	01e55693          	srl	a3,a0,0x1e
8000d95c:	e299                	bnez	a3,8000d962 <.L4^B9>
8000d95e:	050a                	sll	a0,a0,0x2
8000d960:	1679                	add	a2,a2,-2

8000d962 <.L4^B9>:
8000d962:	00054463          	bltz	a0,8000d96a <.L5^B7>
8000d966:	0506                	sll	a0,a0,0x1
8000d968:	167d                	add	a2,a2,-1

8000d96a <.L5^B7>:
8000d96a:	0652                	sll	a2,a2,0x14
8000d96c:	00b55693          	srl	a3,a0,0xb
8000d970:	0556                	sll	a0,a0,0x15
8000d972:	00c685b3          	add	a1,a3,a2
8000d976:	8082                	ret

8000d978 <.L__floatunsidf_zero>:
8000d978:	85aa                	mv	a1,a0
8000d97a:	8082                	ret

Disassembly of section .text.libc.__trunctfsf2:

8000d97c <__trunctfsf2>:
8000d97c:	4110                	lw	a2,0(a0)
8000d97e:	4154                	lw	a3,4(a0)
8000d980:	4518                	lw	a4,8(a0)
8000d982:	455c                	lw	a5,12(a0)
8000d984:	1101                	add	sp,sp,-32
8000d986:	850a                	mv	a0,sp
8000d988:	ce06                	sw	ra,28(sp)
8000d98a:	c032                	sw	a2,0(sp)
8000d98c:	c236                	sw	a3,4(sp)
8000d98e:	c43a                	sw	a4,8(sp)
8000d990:	c63e                	sw	a5,12(sp)
8000d992:	d34fb0ef          	jal	80008ec6 <__SEGGER_RTL_ldouble_to_double>
8000d996:	caafb0ef          	jal	80008e40 <__truncdfsf2>
8000d99a:	40f2                	lw	ra,28(sp)
8000d99c:	6105                	add	sp,sp,32
8000d99e:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_float32_signbit:

8000d9a0 <__SEGGER_RTL_float32_signbit>:
8000d9a0:	817d                	srl	a0,a0,0x1f
8000d9a2:	8082                	ret

Disassembly of section .text.libc.ldexpf:

8000d9a4 <ldexpf>:
8000d9a4:	01755713          	srl	a4,a0,0x17
8000d9a8:	0ff77713          	zext.b	a4,a4
8000d9ac:	fff70613          	add	a2,a4,-1 # fffff <__XPI0_segment_size__+0x2fff>
8000d9b0:	0fd00693          	li	a3,253
8000d9b4:	87aa                	mv	a5,a0
8000d9b6:	02c6e863          	bltu	a3,a2,8000d9e6 <.L780>
8000d9ba:	95ba                	add	a1,a1,a4
8000d9bc:	fff58713          	add	a4,a1,-1 # 7ff7ffff <_flash_size+0x7fe7ffff>
8000d9c0:	00e6eb63          	bltu	a3,a4,8000d9d6 <.L781>
8000d9c4:	80800737          	lui	a4,0x80800
8000d9c8:	177d                	add	a4,a4,-1 # 807fffff <__XPI0_segment_end__+0x6fffff>
8000d9ca:	00e577b3          	and	a5,a0,a4
8000d9ce:	05de                	sll	a1,a1,0x17
8000d9d0:	00f5e533          	or	a0,a1,a5
8000d9d4:	8082                	ret

8000d9d6 <.L781>:
8000d9d6:	80000537          	lui	a0,0x80000
8000d9da:	8d7d                	and	a0,a0,a5
8000d9dc:	00b05563          	blez	a1,8000d9e6 <.L780>
8000d9e0:	7f8007b7          	lui	a5,0x7f800
8000d9e4:	8d5d                	or	a0,a0,a5

8000d9e6 <.L780>:
8000d9e6:	8082                	ret

Disassembly of section .text.libc.frexpf:

8000d9e8 <frexpf>:
8000d9e8:	01755793          	srl	a5,a0,0x17
8000d9ec:	0ff7f793          	zext.b	a5,a5
8000d9f0:	4701                	li	a4,0
8000d9f2:	cf99                	beqz	a5,8000da10 <.L959>
8000d9f4:	0ff00613          	li	a2,255
8000d9f8:	00c78c63          	beq	a5,a2,8000da10 <.L959>
8000d9fc:	f8278713          	add	a4,a5,-126 # 7f7fff82 <_flash_size+0x7f6fff82>
8000da00:	808007b7          	lui	a5,0x80800
8000da04:	17fd                	add	a5,a5,-1 # 807fffff <__XPI0_segment_end__+0x6fffff>
8000da06:	00f576b3          	and	a3,a0,a5
8000da0a:	3f000537          	lui	a0,0x3f000
8000da0e:	8d55                	or	a0,a0,a3

8000da10 <.L959>:
8000da10:	c198                	sw	a4,0(a1)
8000da12:	8082                	ret

Disassembly of section .text.libc.fmodf:

8000da14 <fmodf>:
8000da14:	01755793          	srl	a5,a0,0x17
8000da18:	80000837          	lui	a6,0x80000
8000da1c:	17fd                	add	a5,a5,-1
8000da1e:	0fd00713          	li	a4,253
8000da22:	86aa                	mv	a3,a0
8000da24:	862e                	mv	a2,a1
8000da26:	00a87833          	and	a6,a6,a0
8000da2a:	02f76663          	bltu	a4,a5,8000da56 <.L991>
8000da2e:	0175d793          	srl	a5,a1,0x17
8000da32:	17fd                	add	a5,a5,-1
8000da34:	04f77063          	bgeu	a4,a5,8000da74 <.L992>
8000da38:	00151713          	sll	a4,a0,0x1

8000da3c <.L993>:
8000da3c:	00159793          	sll	a5,a1,0x1
8000da40:	ff000637          	lui	a2,0xff000
8000da44:	0cf66863          	bltu	a2,a5,8000db14 <.L1009>
8000da48:	ef11                	bnez	a4,8000da64 <.L995>
8000da4a:	ef81                	bnez	a5,8000da62 <.L994>

8000da4c <.L1011>:
8000da4c:	800057b7          	lui	a5,0x80005
8000da50:	6fc7a503          	lw	a0,1788(a5) # 800056fc <.Lmerged_single+0x14>
8000da54:	8082                	ret

8000da56 <.L991>:
8000da56:	00151713          	sll	a4,a0,0x1
8000da5a:	ff0007b7          	lui	a5,0xff000
8000da5e:	fce7ffe3          	bgeu	a5,a4,8000da3c <.L993>

8000da62 <.L994>:
8000da62:	8082                	ret

8000da64 <.L995>:
8000da64:	fec704e3          	beq	a4,a2,8000da4c <.L1011>
8000da68:	fec78de3          	beq	a5,a2,8000da62 <.L994>
8000da6c:	d3e5                	beqz	a5,8000da4c <.L1011>
8000da6e:	0586                	sll	a1,a1,0x1
8000da70:	0015d613          	srl	a2,a1,0x1

8000da74 <.L992>:
8000da74:	00169793          	sll	a5,a3,0x1
8000da78:	8385                	srl	a5,a5,0x1
8000da7a:	00f66663          	bltu	a2,a5,8000da86 <.L996>
8000da7e:	fec792e3          	bne	a5,a2,8000da62 <.L994>

8000da82 <.L1018>:
8000da82:	8542                	mv	a0,a6
8000da84:	8082                	ret

8000da86 <.L996>:
8000da86:	0177d713          	srl	a4,a5,0x17
8000da8a:	cb0d                	beqz	a4,8000dabc <.L1012>
8000da8c:	008007b7          	lui	a5,0x800
8000da90:	fff78593          	add	a1,a5,-1 # 7fffff <_flash_size+0x6fffff>
8000da94:	8eed                	and	a3,a3,a1
8000da96:	8fd5                	or	a5,a5,a3

8000da98 <.L998>:
8000da98:	01765593          	srl	a1,a2,0x17
8000da9c:	c985                	beqz	a1,8000dacc <.L1013>
8000da9e:	008006b7          	lui	a3,0x800
8000daa2:	fff68513          	add	a0,a3,-1 # 7fffff <_flash_size+0x6fffff>
8000daa6:	8e69                	and	a2,a2,a0
8000daa8:	8e55                	or	a2,a2,a3

8000daaa <.L1002>:
8000daaa:	40c786b3          	sub	a3,a5,a2
8000daae:	02e5c763          	blt	a1,a4,8000dadc <.L1003>
8000dab2:	0206cc63          	bltz	a3,8000daea <.L1015>
8000dab6:	8542                	mv	a0,a6
8000dab8:	ea95                	bnez	a3,8000daec <.L1004>
8000daba:	8082                	ret

8000dabc <.L1012>:
8000dabc:	4701                	li	a4,0
8000dabe:	008006b7          	lui	a3,0x800

8000dac2 <.L997>:
8000dac2:	0786                	sll	a5,a5,0x1
8000dac4:	177d                	add	a4,a4,-1
8000dac6:	fed7eee3          	bltu	a5,a3,8000dac2 <.L997>
8000daca:	b7f9                	j	8000da98 <.L998>

8000dacc <.L1013>:
8000dacc:	4581                	li	a1,0
8000dace:	008006b7          	lui	a3,0x800

8000dad2 <.L999>:
8000dad2:	0606                	sll	a2,a2,0x1
8000dad4:	15fd                	add	a1,a1,-1
8000dad6:	fed66ee3          	bltu	a2,a3,8000dad2 <.L999>
8000dada:	bfc1                	j	8000daaa <.L1002>

8000dadc <.L1003>:
8000dadc:	0006c463          	bltz	a3,8000dae4 <.L1001>
8000dae0:	d2cd                	beqz	a3,8000da82 <.L1018>
8000dae2:	87b6                	mv	a5,a3

8000dae4 <.L1001>:
8000dae4:	0786                	sll	a5,a5,0x1
8000dae6:	177d                	add	a4,a4,-1
8000dae8:	b7c9                	j	8000daaa <.L1002>

8000daea <.L1015>:
8000daea:	86be                	mv	a3,a5

8000daec <.L1004>:
8000daec:	008007b7          	lui	a5,0x800

8000daf0 <.L1006>:
8000daf0:	fff70513          	add	a0,a4,-1
8000daf4:	00f6ed63          	bltu	a3,a5,8000db0e <.L1007>
8000daf8:	00e04763          	bgtz	a4,8000db06 <.L1008>
8000dafc:	4785                	li	a5,1
8000dafe:	8f99                	sub	a5,a5,a4
8000db00:	00f6d6b3          	srl	a3,a3,a5
8000db04:	4501                	li	a0,0

8000db06 <.L1008>:
8000db06:	9836                	add	a6,a6,a3
8000db08:	055e                	sll	a0,a0,0x17
8000db0a:	9542                	add	a0,a0,a6
8000db0c:	8082                	ret

8000db0e <.L1007>:
8000db0e:	0686                	sll	a3,a3,0x1
8000db10:	872a                	mv	a4,a0
8000db12:	bff9                	j	8000daf0 <.L1006>

8000db14 <.L1009>:
8000db14:	852e                	mv	a0,a1
8000db16:	8082                	ret

Disassembly of section .text.libc.memset:

8000db18 <memset>:
8000db18:	872a                	mv	a4,a0
8000db1a:	c22d                	beqz	a2,8000db7c <.Lmemset_memset_end>

8000db1c <.Lmemset_unaligned_byte_set_loop>:
8000db1c:	01e51693          	sll	a3,a0,0x1e
8000db20:	c699                	beqz	a3,8000db2e <.Lmemset_fast_set>
8000db22:	00b50023          	sb	a1,0(a0) # 3f000000 <_flash_size+0x3ef00000>
8000db26:	0505                	add	a0,a0,1
8000db28:	167d                	add	a2,a2,-1 # feffffff <__AHB_SRAM_segment_end__+0xebf7fff>
8000db2a:	fa6d                	bnez	a2,8000db1c <.Lmemset_unaligned_byte_set_loop>
8000db2c:	a881                	j	8000db7c <.Lmemset_memset_end>

8000db2e <.Lmemset_fast_set>:
8000db2e:	0ff5f593          	zext.b	a1,a1
8000db32:	00859693          	sll	a3,a1,0x8
8000db36:	8dd5                	or	a1,a1,a3
8000db38:	01059693          	sll	a3,a1,0x10
8000db3c:	8dd5                	or	a1,a1,a3
8000db3e:	02000693          	li	a3,32
8000db42:	00d66f63          	bltu	a2,a3,8000db60 <.Lmemset_word_set>

8000db46 <.Lmemset_fast_set_loop>:
8000db46:	c10c                	sw	a1,0(a0)
8000db48:	c14c                	sw	a1,4(a0)
8000db4a:	c50c                	sw	a1,8(a0)
8000db4c:	c54c                	sw	a1,12(a0)
8000db4e:	c90c                	sw	a1,16(a0)
8000db50:	c94c                	sw	a1,20(a0)
8000db52:	cd0c                	sw	a1,24(a0)
8000db54:	cd4c                	sw	a1,28(a0)
8000db56:	9536                	add	a0,a0,a3
8000db58:	8e15                	sub	a2,a2,a3
8000db5a:	fed676e3          	bgeu	a2,a3,8000db46 <.Lmemset_fast_set_loop>
8000db5e:	ce19                	beqz	a2,8000db7c <.Lmemset_memset_end>

8000db60 <.Lmemset_word_set>:
8000db60:	4691                	li	a3,4
8000db62:	00d66863          	bltu	a2,a3,8000db72 <.Lmemset_byte_set_loop>

8000db66 <.Lmemset_word_set_loop>:
8000db66:	c10c                	sw	a1,0(a0)
8000db68:	9536                	add	a0,a0,a3
8000db6a:	8e15                	sub	a2,a2,a3
8000db6c:	fed67de3          	bgeu	a2,a3,8000db66 <.Lmemset_word_set_loop>
8000db70:	c611                	beqz	a2,8000db7c <.Lmemset_memset_end>

8000db72 <.Lmemset_byte_set_loop>:
8000db72:	00b50023          	sb	a1,0(a0)
8000db76:	0505                	add	a0,a0,1
8000db78:	167d                	add	a2,a2,-1
8000db7a:	fe65                	bnez	a2,8000db72 <.Lmemset_byte_set_loop>

8000db7c <.Lmemset_memset_end>:
8000db7c:	853a                	mv	a0,a4
8000db7e:	8082                	ret

Disassembly of section .text.libc.strcpy:

8000db80 <strcpy>:
8000db80:	862a                	mv	a2,a0
8000db82:	00357693          	and	a3,a0,3
8000db86:	ea8d                	bnez	a3,8000dbb8 <.Lstrcpy_bytestrcpy>
8000db88:	0035f693          	and	a3,a1,3
8000db8c:	e695                	bnez	a3,8000dbb8 <.Lstrcpy_bytestrcpy>
8000db8e:	feff02b7          	lui	t0,0xfeff0
8000db92:	eff28293          	add	t0,t0,-257 # fefefeff <__AHB_SRAM_segment_end__+0xebe7eff>
8000db96:	808086b7          	lui	a3,0x80808
8000db9a:	08068693          	add	a3,a3,128 # 80808080 <__XPI0_segment_end__+0x708080>

8000db9e <.Lstrcpy_wordstrcpy>:
8000db9e:	4198                	lw	a4,0(a1)
8000dba0:	fff74793          	not	a5,a4
8000dba4:	00570333          	add	t1,a4,t0
8000dba8:	0067f7b3          	and	a5,a5,t1
8000dbac:	8ff5                	and	a5,a5,a3
8000dbae:	e789                	bnez	a5,8000dbb8 <.Lstrcpy_bytestrcpy>
8000dbb0:	c218                	sw	a4,0(a2)
8000dbb2:	0591                	add	a1,a1,4
8000dbb4:	0611                	add	a2,a2,4
8000dbb6:	b7e5                	j	8000db9e <.Lstrcpy_wordstrcpy>

8000dbb8 <.Lstrcpy_bytestrcpy>:
8000dbb8:	00058683          	lb	a3,0(a1)
8000dbbc:	0585                	add	a1,a1,1
8000dbbe:	00d60023          	sb	a3,0(a2)
8000dbc2:	0605                	add	a2,a2,1
8000dbc4:	faf5                	bnez	a3,8000dbb8 <.Lstrcpy_bytestrcpy>
8000dbc6:	8082                	ret

Disassembly of section .text.libc.strlen:

8000dbc8 <strlen>:
8000dbc8:	85aa                	mv	a1,a0
8000dbca:	00357693          	and	a3,a0,3
8000dbce:	c29d                	beqz	a3,8000dbf4 <.Lstrlen_aligned>
8000dbd0:	00054603          	lbu	a2,0(a0)
8000dbd4:	ce21                	beqz	a2,8000dc2c <.Lstrlen_done>
8000dbd6:	0505                	add	a0,a0,1
8000dbd8:	00357693          	and	a3,a0,3
8000dbdc:	ce81                	beqz	a3,8000dbf4 <.Lstrlen_aligned>
8000dbde:	00054603          	lbu	a2,0(a0)
8000dbe2:	c629                	beqz	a2,8000dc2c <.Lstrlen_done>
8000dbe4:	0505                	add	a0,a0,1
8000dbe6:	00357693          	and	a3,a0,3
8000dbea:	c689                	beqz	a3,8000dbf4 <.Lstrlen_aligned>
8000dbec:	00054603          	lbu	a2,0(a0)
8000dbf0:	ce15                	beqz	a2,8000dc2c <.Lstrlen_done>
8000dbf2:	0505                	add	a0,a0,1

8000dbf4 <.Lstrlen_aligned>:
8000dbf4:	01010637          	lui	a2,0x1010
8000dbf8:	10160613          	add	a2,a2,257 # 1010101 <_flash_size+0xf10101>
8000dbfc:	00761693          	sll	a3,a2,0x7

8000dc00 <.Lstrlen_wordstrlen>:
8000dc00:	4118                	lw	a4,0(a0)
8000dc02:	0511                	add	a0,a0,4
8000dc04:	40c707b3          	sub	a5,a4,a2
8000dc08:	fff74713          	not	a4,a4
8000dc0c:	8ff9                	and	a5,a5,a4
8000dc0e:	8ff5                	and	a5,a5,a3
8000dc10:	dbe5                	beqz	a5,8000dc00 <.Lstrlen_wordstrlen>
8000dc12:	1571                	add	a0,a0,-4
8000dc14:	01879713          	sll	a4,a5,0x18
8000dc18:	eb11                	bnez	a4,8000dc2c <.Lstrlen_done>
8000dc1a:	0505                	add	a0,a0,1
8000dc1c:	01079713          	sll	a4,a5,0x10
8000dc20:	e711                	bnez	a4,8000dc2c <.Lstrlen_done>
8000dc22:	0505                	add	a0,a0,1
8000dc24:	00879713          	sll	a4,a5,0x8
8000dc28:	e311                	bnez	a4,8000dc2c <.Lstrlen_done>
8000dc2a:	0505                	add	a0,a0,1

8000dc2c <.Lstrlen_done>:
8000dc2c:	8d0d                	sub	a0,a0,a1
8000dc2e:	8082                	ret

Disassembly of section .text.libc.memmove:

8000dc30 <memmove>:
8000dc30:	0cb57b63          	bgeu	a0,a1,8000dd06 <.L2>
8000dc34:	00b547b3          	xor	a5,a0,a1
8000dc38:	8b8d                	and	a5,a5,3
8000dc3a:	872a                	mv	a4,a0
8000dc3c:	c395                	beqz	a5,8000dc60 <.L3>

8000dc3e <.L4>:
8000dc3e:	c601                	beqz	a2,8000dc46 <.L11>
8000dc40:	0035f793          	and	a5,a1,3
8000dc44:	e3b5                	bnez	a5,8000dca8 <.L12>

8000dc46 <.L11>:
8000dc46:	882e                	mv	a6,a1
8000dc48:	87ba                	mv	a5,a4
8000dc4a:	00c70333          	add	t1,a4,a2
8000dc4e:	488d                	li	a7,3
8000dc50:	a069                	j	8000dcda <.L13>

8000dc52 <.L6>:
8000dc52:	0005c683          	lbu	a3,0(a1)
8000dc56:	0585                	add	a1,a1,1
8000dc58:	0705                	add	a4,a4,1
8000dc5a:	167d                	add	a2,a2,-1
8000dc5c:	fed70fa3          	sb	a3,-1(a4)

8000dc60 <.L3>:
8000dc60:	00377693          	and	a3,a4,3
8000dc64:	e285                	bnez	a3,8000dc84 <.L46>
8000dc66:	480d                	li	a6,3

8000dc68 <.L5>:
8000dc68:	40d608b3          	sub	a7,a2,a3
8000dc6c:	01187d63          	bgeu	a6,a7,8000dc86 <.L7>
8000dc70:	00d588b3          	add	a7,a1,a3
8000dc74:	0008a303          	lw	t1,0(a7)
8000dc78:	00d708b3          	add	a7,a4,a3
8000dc7c:	0691                	add	a3,a3,4
8000dc7e:	0068a023          	sw	t1,0(a7)
8000dc82:	b7dd                	j	8000dc68 <.L5>

8000dc84 <.L46>:
8000dc84:	f679                	bnez	a2,8000dc52 <.L6>

8000dc86 <.L7>:
8000dc86:	ffc67813          	and	a6,a2,-4
8000dc8a:	8a0d                	and	a2,a2,3

8000dc8c <.L9>:
8000dc8c:	00f61363          	bne	a2,a5,8000dc92 <.L10>
8000dc90:	8082                	ret

8000dc92 <.L10>:
8000dc92:	00f806b3          	add	a3,a6,a5
8000dc96:	00d588b3          	add	a7,a1,a3
8000dc9a:	0008c883          	lbu	a7,0(a7)
8000dc9e:	96ba                	add	a3,a3,a4
8000dca0:	0785                	add	a5,a5,1 # 800001 <_flash_size+0x700001>
8000dca2:	01168023          	sb	a7,0(a3)
8000dca6:	b7dd                	j	8000dc8c <.L9>

8000dca8 <.L12>:
8000dca8:	0005c783          	lbu	a5,0(a1)
8000dcac:	0585                	add	a1,a1,1
8000dcae:	0705                	add	a4,a4,1
8000dcb0:	167d                	add	a2,a2,-1
8000dcb2:	fef70fa3          	sb	a5,-1(a4)
8000dcb6:	b761                	j	8000dc3e <.L4>

8000dcb8 <.L14>:
8000dcb8:	00082683          	lw	a3,0(a6) # 80000000 <_flash_size+0x7ff00000>
8000dcbc:	0791                	add	a5,a5,4
8000dcbe:	0811                	add	a6,a6,4
8000dcc0:	0086de13          	srl	t3,a3,0x8
8000dcc4:	fed78e23          	sb	a3,-4(a5)
8000dcc8:	ffc78ea3          	sb	t3,-3(a5)
8000dccc:	0106de13          	srl	t3,a3,0x10
8000dcd0:	82e1                	srl	a3,a3,0x18
8000dcd2:	ffc78f23          	sb	t3,-2(a5)
8000dcd6:	fed78fa3          	sb	a3,-1(a5)

8000dcda <.L13>:
8000dcda:	40f306b3          	sub	a3,t1,a5
8000dcde:	fcd8ede3          	bltu	a7,a3,8000dcb8 <.L14>
8000dce2:	ffc67813          	and	a6,a2,-4
8000dce6:	4781                	li	a5,0
8000dce8:	8a0d                	and	a2,a2,3

8000dcea <.L15>:
8000dcea:	00f61363          	bne	a2,a5,8000dcf0 <.L16>
8000dcee:	8082                	ret

8000dcf0 <.L16>:
8000dcf0:	00f806b3          	add	a3,a6,a5
8000dcf4:	00d588b3          	add	a7,a1,a3
8000dcf8:	0008c883          	lbu	a7,0(a7)
8000dcfc:	96ba                	add	a3,a3,a4
8000dcfe:	0785                	add	a5,a5,1
8000dd00:	01168023          	sb	a7,0(a3)
8000dd04:	b7dd                	j	8000dcea <.L15>

8000dd06 <.L2>:
8000dd06:	04a5f263          	bgeu	a1,a0,8000dd4a <.L38>
8000dd0a:	00c50833          	add	a6,a0,a2
8000dd0e:	95b2                	add	a1,a1,a2
8000dd10:	00b847b3          	xor	a5,a6,a1
8000dd14:	8b8d                	and	a5,a5,3
8000dd16:	c3b1                	beqz	a5,8000dd5a <.L18>

8000dd18 <.L19>:
8000dd18:	c601                	beqz	a2,8000dd20 <.L26>
8000dd1a:	0035f793          	and	a5,a1,3
8000dd1e:	ebc1                	bnez	a5,8000ddae <.L27>

8000dd20 <.L26>:
8000dd20:	86ae                	mv	a3,a1
8000dd22:	87c2                	mv	a5,a6
8000dd24:	40b60333          	sub	t1,a2,a1
8000dd28:	488d                	li	a7,3

8000dd2a <.L28>:
8000dd2a:	00668733          	add	a4,a3,t1
8000dd2e:	08e8e863          	bltu	a7,a4,8000ddbe <.L29>
8000dd32:	00265713          	srl	a4,a2,0x2
8000dd36:	57f1                	li	a5,-4
8000dd38:	02f70733          	mul	a4,a4,a5
8000dd3c:	4781                	li	a5,0
8000dd3e:	963a                	add	a2,a2,a4
8000dd40:	fff64613          	not	a2,a2

8000dd44 <.L30>:
8000dd44:	17fd                	add	a5,a5,-1
8000dd46:	08c79d63          	bne	a5,a2,8000dde0 <.L31>

8000dd4a <.L38>:
8000dd4a:	8082                	ret

8000dd4c <.L21>:
8000dd4c:	fff5c703          	lbu	a4,-1(a1)
8000dd50:	15fd                	add	a1,a1,-1
8000dd52:	187d                	add	a6,a6,-1
8000dd54:	167d                	add	a2,a2,-1
8000dd56:	00e80023          	sb	a4,0(a6)

8000dd5a <.L18>:
8000dd5a:	00387713          	and	a4,a6,3
8000dd5e:	c311                	beqz	a4,8000dd62 <.L20>
8000dd60:	f675                	bnez	a2,8000dd4c <.L21>

8000dd62 <.L20>:
8000dd62:	872e                	mv	a4,a1
8000dd64:	86c2                	mv	a3,a6
8000dd66:	40b60e33          	sub	t3,a2,a1
8000dd6a:	488d                	li	a7,3

8000dd6c <.L22>:
8000dd6c:	01c70333          	add	t1,a4,t3
8000dd70:	0068ee63          	bltu	a7,t1,8000dd8c <.L23>
8000dd74:	00265713          	srl	a4,a2,0x2
8000dd78:	56f1                	li	a3,-4
8000dd7a:	02d70733          	mul	a4,a4,a3
8000dd7e:	963a                	add	a2,a2,a4
8000dd80:	fff64613          	not	a2,a2

8000dd84 <.L24>:
8000dd84:	17fd                	add	a5,a5,-1
8000dd86:	00c79a63          	bne	a5,a2,8000dd9a <.L25>
8000dd8a:	8082                	ret

8000dd8c <.L23>:
8000dd8c:	1771                	add	a4,a4,-4
8000dd8e:	00072303          	lw	t1,0(a4)
8000dd92:	16f1                	add	a3,a3,-4
8000dd94:	0066a023          	sw	t1,0(a3)
8000dd98:	bfd1                	j	8000dd6c <.L22>

8000dd9a <.L25>:
8000dd9a:	00f706b3          	add	a3,a4,a5
8000dd9e:	00d588b3          	add	a7,a1,a3
8000dda2:	0008c883          	lbu	a7,0(a7)
8000dda6:	96c2                	add	a3,a3,a6
8000dda8:	01168023          	sb	a7,0(a3)
8000ddac:	bfe1                	j	8000dd84 <.L24>

8000ddae <.L27>:
8000ddae:	fff5c783          	lbu	a5,-1(a1)
8000ddb2:	15fd                	add	a1,a1,-1
8000ddb4:	187d                	add	a6,a6,-1
8000ddb6:	167d                	add	a2,a2,-1
8000ddb8:	00f80023          	sb	a5,0(a6)
8000ddbc:	bfb1                	j	8000dd18 <.L19>

8000ddbe <.L29>:
8000ddbe:	16f1                	add	a3,a3,-4
8000ddc0:	4298                	lw	a4,0(a3)
8000ddc2:	17f1                	add	a5,a5,-4
8000ddc4:	00875e13          	srl	t3,a4,0x8
8000ddc8:	01c780a3          	sb	t3,1(a5)
8000ddcc:	00e78023          	sb	a4,0(a5)
8000ddd0:	01075e13          	srl	t3,a4,0x10
8000ddd4:	8361                	srl	a4,a4,0x18
8000ddd6:	01c78123          	sb	t3,2(a5)
8000ddda:	00e781a3          	sb	a4,3(a5)
8000ddde:	b7b1                	j	8000dd2a <.L28>

8000dde0 <.L31>:
8000dde0:	00f706b3          	add	a3,a4,a5
8000dde4:	00d588b3          	add	a7,a1,a3
8000dde8:	0008c883          	lbu	a7,0(a7)
8000ddec:	96c2                	add	a3,a3,a6
8000ddee:	01168023          	sb	a7,0(a3)
8000ddf2:	bf89                	j	8000dd44 <.L30>

Disassembly of section .text.libc.memcmp:

8000ddf4 <memcmp>:
8000ddf4:	00b547b3          	xor	a5,a0,a1
8000ddf8:	8b8d                	and	a5,a5,3
8000ddfa:	872a                	mv	a4,a0
8000ddfc:	e3cd                	bnez	a5,8000de9e <.L58>

8000ddfe <.L62>:
8000ddfe:	00377793          	and	a5,a4,3
8000de02:	efb9                	bnez	a5,8000de60 <.L89>
8000de04:	480d                	li	a6,3

8000de06 <.L59>:
8000de06:	06c87f63          	bgeu	a6,a2,8000de84 <.L63>
8000de0a:	4308                	lw	a0,0(a4)
8000de0c:	4194                	lw	a3,0(a1)
8000de0e:	06d50763          	beq	a0,a3,8000de7c <.L64>

8000de12 <.L65>:
8000de12:	4314                	lw	a3,0(a4)
8000de14:	4198                	lw	a4,0(a1)
8000de16:	00e6c5b3          	xor	a1,a3,a4
8000de1a:	0ff5f513          	zext.b	a0,a1
8000de1e:	e50d                	bnez	a0,8000de48 <.L66>
8000de20:	0085d513          	srl	a0,a1,0x8
8000de24:	0ff57513          	zext.b	a0,a0
8000de28:	4785                	li	a5,1
8000de2a:	ed01                	bnez	a0,8000de42 <.L67>
8000de2c:	0105d513          	srl	a0,a1,0x10
8000de30:	0ff57513          	zext.b	a0,a0
8000de34:	4789                	li	a5,2
8000de36:	e511                	bnez	a0,8000de42 <.L67>
8000de38:	010007b7          	lui	a5,0x1000
8000de3c:	00f5b7b3          	sltu	a5,a1,a5
8000de40:	078d                	add	a5,a5,3 # 1000003 <_flash_size+0xf00003>

8000de42 <.L67>:
8000de42:	4501                	li	a0,0
8000de44:	04c7f263          	bgeu	a5,a2,8000de88 <.L57>

8000de48 <.L66>:
8000de48:	078e                	sll	a5,a5,0x3
8000de4a:	00f6d6b3          	srl	a3,a3,a5
8000de4e:	00f75733          	srl	a4,a4,a5
8000de52:	0ff6f693          	zext.b	a3,a3
8000de56:	0ff77713          	zext.b	a4,a4
8000de5a:	40e68533          	sub	a0,a3,a4
8000de5e:	8082                	ret

8000de60 <.L89>:
8000de60:	ce51                	beqz	a2,8000defc <.L81>
8000de62:	00074783          	lbu	a5,0(a4)
8000de66:	0005c683          	lbu	a3,0(a1)
8000de6a:	00d78563          	beq	a5,a3,8000de74 <.L61>

8000de6e <.L93>:
8000de6e:	40d78533          	sub	a0,a5,a3
8000de72:	8082                	ret

8000de74 <.L61>:
8000de74:	0705                	add	a4,a4,1
8000de76:	0585                	add	a1,a1,1
8000de78:	167d                	add	a2,a2,-1
8000de7a:	b751                	j	8000ddfe <.L62>

8000de7c <.L64>:
8000de7c:	0711                	add	a4,a4,4
8000de7e:	0591                	add	a1,a1,4
8000de80:	1671                	add	a2,a2,-4
8000de82:	b751                	j	8000de06 <.L59>

8000de84 <.L63>:
8000de84:	4501                	li	a0,0
8000de86:	f651                	bnez	a2,8000de12 <.L65>

8000de88 <.L57>:
8000de88:	8082                	ret

8000de8a <.L90>:
8000de8a:	ca2d                	beqz	a2,8000defc <.L81>
8000de8c:	00074783          	lbu	a5,0(a4)
8000de90:	0005c683          	lbu	a3,0(a1)
8000de94:	fcd79de3          	bne	a5,a3,8000de6e <.L93>
8000de98:	0705                	add	a4,a4,1
8000de9a:	0585                	add	a1,a1,1
8000de9c:	167d                	add	a2,a2,-1

8000de9e <.L58>:
8000de9e:	00377693          	and	a3,a4,3
8000dea2:	f6e5                	bnez	a3,8000de8a <.L90>
8000dea4:	480d                	li	a6,3

8000dea6 <.L68>:
8000dea6:	04c87863          	bgeu	a6,a2,8000def6 <.L70>
8000deaa:	0035c783          	lbu	a5,3(a1)
8000deae:	0025c503          	lbu	a0,2(a1)
8000deb2:	07a2                	sll	a5,a5,0x8
8000deb4:	97aa                	add	a5,a5,a0
8000deb6:	0015c503          	lbu	a0,1(a1)
8000deba:	07a2                	sll	a5,a5,0x8
8000debc:	97aa                	add	a5,a5,a0
8000debe:	0005c503          	lbu	a0,0(a1)
8000dec2:	07a2                	sll	a5,a5,0x8
8000dec4:	97aa                	add	a5,a5,a0
8000dec6:	4308                	lw	a0,0(a4)
8000dec8:	02f50363          	beq	a0,a5,8000deee <.L71>

8000decc <.L72>:
8000decc:	167d                	add	a2,a2,-1

8000dece <.L74>:
8000dece:	00d707b3          	add	a5,a4,a3
8000ded2:	00d58533          	add	a0,a1,a3
8000ded6:	0007c783          	lbu	a5,0(a5)
8000deda:	00054503          	lbu	a0,0(a0)
8000dede:	00c68563          	beq	a3,a2,8000dee8 <.L73>
8000dee2:	0685                	add	a3,a3,1
8000dee4:	fef505e3          	beq	a0,a5,8000dece <.L74>

8000dee8 <.L73>:
8000dee8:	40a78533          	sub	a0,a5,a0
8000deec:	8082                	ret

8000deee <.L71>:
8000deee:	0711                	add	a4,a4,4
8000def0:	0591                	add	a1,a1,4
8000def2:	1671                	add	a2,a2,-4
8000def4:	bf4d                	j	8000dea6 <.L68>

8000def6 <.L70>:
8000def6:	4501                	li	a0,0
8000def8:	da41                	beqz	a2,8000de88 <.L57>
8000defa:	bfc9                	j	8000decc <.L72>

8000defc <.L81>:
8000defc:	4501                	li	a0,0
8000defe:	8082                	ret

Disassembly of section .text.libc.strnlen:

8000df00 <strnlen>:
8000df00:	862a                	mv	a2,a0
8000df02:	852e                	mv	a0,a1
8000df04:	c9c9                	beqz	a1,8000df96 <.L528>
8000df06:	00064783          	lbu	a5,0(a2)
8000df0a:	c7c9                	beqz	a5,8000df94 <.L534>
8000df0c:	00367793          	and	a5,a2,3
8000df10:	00379693          	sll	a3,a5,0x3
8000df14:	00f58533          	add	a0,a1,a5
8000df18:	ffc67713          	and	a4,a2,-4
8000df1c:	57fd                	li	a5,-1
8000df1e:	00d797b3          	sll	a5,a5,a3
8000df22:	4314                	lw	a3,0(a4)
8000df24:	fff7c793          	not	a5,a5
8000df28:	feff05b7          	lui	a1,0xfeff0
8000df2c:	80808837          	lui	a6,0x80808
8000df30:	8fd5                	or	a5,a5,a3
8000df32:	488d                	li	a7,3
8000df34:	eff58593          	add	a1,a1,-257 # fefefeff <__AHB_SRAM_segment_end__+0xebe7eff>
8000df38:	08080813          	add	a6,a6,128 # 80808080 <__XPI0_segment_end__+0x708080>

8000df3c <.L530>:
8000df3c:	00a8ff63          	bgeu	a7,a0,8000df5a <.L529>
8000df40:	00b786b3          	add	a3,a5,a1
8000df44:	fff7c313          	not	t1,a5
8000df48:	0066f6b3          	and	a3,a3,t1
8000df4c:	0106f6b3          	and	a3,a3,a6
8000df50:	e689                	bnez	a3,8000df5a <.L529>
8000df52:	0711                	add	a4,a4,4
8000df54:	1571                	add	a0,a0,-4
8000df56:	431c                	lw	a5,0(a4)
8000df58:	b7d5                	j	8000df3c <.L530>

8000df5a <.L529>:
8000df5a:	0ff7f593          	zext.b	a1,a5
8000df5e:	c59d                	beqz	a1,8000df8c <.L531>
8000df60:	0087d593          	srl	a1,a5,0x8
8000df64:	0ff5f593          	zext.b	a1,a1
8000df68:	4685                	li	a3,1
8000df6a:	cd89                	beqz	a1,8000df84 <.L532>
8000df6c:	0107d593          	srl	a1,a5,0x10
8000df70:	0ff5f593          	zext.b	a1,a1
8000df74:	4689                	li	a3,2
8000df76:	c599                	beqz	a1,8000df84 <.L532>
8000df78:	010005b7          	lui	a1,0x1000
8000df7c:	468d                	li	a3,3
8000df7e:	00b7e363          	bltu	a5,a1,8000df84 <.L532>
8000df82:	4691                	li	a3,4

8000df84 <.L532>:
8000df84:	85aa                	mv	a1,a0
8000df86:	00a6f363          	bgeu	a3,a0,8000df8c <.L531>
8000df8a:	85b6                	mv	a1,a3

8000df8c <.L531>:
8000df8c:	8f11                	sub	a4,a4,a2
8000df8e:	00b70533          	add	a0,a4,a1
8000df92:	8082                	ret

8000df94 <.L534>:
8000df94:	4501                	li	a0,0

8000df96 <.L528>:
8000df96:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_stream_write:

8000df98 <__SEGGER_RTL_stream_write>:
8000df98:	5154                	lw	a3,36(a0)
8000df9a:	87ae                	mv	a5,a1
8000df9c:	853e                	mv	a0,a5
8000df9e:	4585                	li	a1,1
8000dfa0:	9d7fa06f          	j	80008976 <fwrite>

Disassembly of section .text.libc.__SEGGER_RTL_putc:

8000dfa4 <__SEGGER_RTL_putc>:
8000dfa4:	4918                	lw	a4,16(a0)
8000dfa6:	1101                	add	sp,sp,-32
8000dfa8:	0ff5f593          	zext.b	a1,a1
8000dfac:	cc22                	sw	s0,24(sp)
8000dfae:	ce06                	sw	ra,28(sp)
8000dfb0:	00b107a3          	sb	a1,15(sp)
8000dfb4:	411c                	lw	a5,0(a0)
8000dfb6:	842a                	mv	s0,a0
8000dfb8:	cb05                	beqz	a4,8000dfe8 <.L24>
8000dfba:	4154                	lw	a3,4(a0)
8000dfbc:	00d7ff63          	bgeu	a5,a3,8000dfda <.L26>
8000dfc0:	495c                	lw	a5,20(a0)
8000dfc2:	00178693          	add	a3,a5,1
8000dfc6:	973e                	add	a4,a4,a5
8000dfc8:	c954                	sw	a3,20(a0)
8000dfca:	00b70023          	sb	a1,0(a4)
8000dfce:	4958                	lw	a4,20(a0)
8000dfd0:	4d1c                	lw	a5,24(a0)
8000dfd2:	00f71463          	bne	a4,a5,8000dfda <.L26>
8000dfd6:	acbfb0ef          	jal	80009aa0 <__SEGGER_RTL_prin_flush>

8000dfda <.L26>:
8000dfda:	401c                	lw	a5,0(s0)
8000dfdc:	40f2                	lw	ra,28(sp)
8000dfde:	0785                	add	a5,a5,1
8000dfe0:	c01c                	sw	a5,0(s0)
8000dfe2:	4462                	lw	s0,24(sp)
8000dfe4:	6105                	add	sp,sp,32
8000dfe6:	8082                	ret

8000dfe8 <.L24>:
8000dfe8:	4558                	lw	a4,12(a0)
8000dfea:	c305                	beqz	a4,8000e00a <.L28>
8000dfec:	4154                	lw	a3,4(a0)
8000dfee:	00178613          	add	a2,a5,1
8000dff2:	00d61463          	bne	a2,a3,8000dffa <.L29>
8000dff6:	000107a3          	sb	zero,15(sp)

8000dffa <.L29>:
8000dffa:	fed7f0e3          	bgeu	a5,a3,8000dfda <.L26>
8000dffe:	00f14683          	lbu	a3,15(sp)
8000e002:	973e                	add	a4,a4,a5
8000e004:	00d70023          	sb	a3,0(a4)
8000e008:	bfc9                	j	8000dfda <.L26>

8000e00a <.L28>:
8000e00a:	4518                	lw	a4,8(a0)
8000e00c:	c305                	beqz	a4,8000e02c <.L30>
8000e00e:	4154                	lw	a3,4(a0)
8000e010:	00178613          	add	a2,a5,1
8000e014:	00d61463          	bne	a2,a3,8000e01c <.L31>
8000e018:	000107a3          	sb	zero,15(sp)

8000e01c <.L31>:
8000e01c:	fad7ffe3          	bgeu	a5,a3,8000dfda <.L26>
8000e020:	078a                	sll	a5,a5,0x2
8000e022:	973e                	add	a4,a4,a5
8000e024:	00f14783          	lbu	a5,15(sp)
8000e028:	c31c                	sw	a5,0(a4)
8000e02a:	bf45                	j	8000dfda <.L26>

8000e02c <.L30>:
8000e02c:	5118                	lw	a4,32(a0)
8000e02e:	d755                	beqz	a4,8000dfda <.L26>
8000e030:	4154                	lw	a3,4(a0)
8000e032:	fad7f4e3          	bgeu	a5,a3,8000dfda <.L26>
8000e036:	4605                	li	a2,1
8000e038:	00f10593          	add	a1,sp,15
8000e03c:	9702                	jalr	a4
8000e03e:	bf71                	j	8000dfda <.L26>

Disassembly of section .text.libc.__SEGGER_RTL_print_padding:

8000e040 <__SEGGER_RTL_print_padding>:
8000e040:	1141                	add	sp,sp,-16
8000e042:	c422                	sw	s0,8(sp)
8000e044:	c226                	sw	s1,4(sp)
8000e046:	c04a                	sw	s2,0(sp)
8000e048:	c606                	sw	ra,12(sp)
8000e04a:	84aa                	mv	s1,a0
8000e04c:	892e                	mv	s2,a1
8000e04e:	8432                	mv	s0,a2

8000e050 <.L37>:
8000e050:	147d                	add	s0,s0,-1
8000e052:	00045863          	bgez	s0,8000e062 <.L38>
8000e056:	40b2                	lw	ra,12(sp)
8000e058:	4422                	lw	s0,8(sp)
8000e05a:	4492                	lw	s1,4(sp)
8000e05c:	4902                	lw	s2,0(sp)
8000e05e:	0141                	add	sp,sp,16
8000e060:	8082                	ret

8000e062 <.L38>:
8000e062:	85ca                	mv	a1,s2
8000e064:	8526                	mv	a0,s1
8000e066:	3f3d                	jal	8000dfa4 <__SEGGER_RTL_putc>
8000e068:	b7e5                	j	8000e050 <.L37>

Disassembly of section .text.libc.sprintf:

8000e06a <sprintf>:
8000e06a:	7159                	add	sp,sp,-112
8000e06c:	c4a2                	sw	s0,72(sp)
8000e06e:	d2be                	sw	a5,100(sp)
8000e070:	842a                	mv	s0,a0
8000e072:	08bc                	add	a5,sp,88
8000e074:	0868                	add	a0,sp,28
8000e076:	c686                	sw	ra,76(sp)
8000e078:	c62e                	sw	a1,12(sp)
8000e07a:	ccb2                	sw	a2,88(sp)
8000e07c:	ceb6                	sw	a3,92(sp)
8000e07e:	d0ba                	sw	a4,96(sp)
8000e080:	d4c2                	sw	a6,104(sp)
8000e082:	d6c6                	sw	a7,108(sp)
8000e084:	cc3e                	sw	a5,24(sp)
8000e086:	a79fb0ef          	jal	80009afe <__SEGGER_RTL_init_prin>
8000e08a:	4662                	lw	a2,24(sp)
8000e08c:	45b2                	lw	a1,12(sp)
8000e08e:	800007b7          	lui	a5,0x80000
8000e092:	17fd                	add	a5,a5,-1 # 7fffffff <_flash_size+0x7fefffff>
8000e094:	0868                	add	a0,sp,28
8000e096:	d422                	sw	s0,40(sp)
8000e098:	d03e                	sw	a5,32(sp)
8000e09a:	2841                	jal	8000e12a <__SEGGER_RTL_vfprintf>
8000e09c:	40b6                	lw	ra,76(sp)
8000e09e:	4426                	lw	s0,72(sp)
8000e0a0:	6165                	add	sp,sp,112
8000e0a2:	8082                	ret

Disassembly of section .text.libc.vfprintf_l:

8000e0a4 <vfprintf_l>:
8000e0a4:	711d                	add	sp,sp,-96
8000e0a6:	ce86                	sw	ra,92(sp)
8000e0a8:	cca2                	sw	s0,88(sp)
8000e0aa:	caa6                	sw	s1,84(sp)
8000e0ac:	1080                	add	s0,sp,96
8000e0ae:	c8ca                	sw	s2,80(sp)
8000e0b0:	c6ce                	sw	s3,76(sp)
8000e0b2:	8932                	mv	s2,a2
8000e0b4:	fad42623          	sw	a3,-84(s0)
8000e0b8:	89aa                	mv	s3,a0
8000e0ba:	fab42423          	sw	a1,-88(s0)
8000e0be:	d5dfb0ef          	jal	80009e1a <__SEGGER_RTL_X_file_bufsize>
8000e0c2:	fa842583          	lw	a1,-88(s0)
8000e0c6:	00f50793          	add	a5,a0,15
8000e0ca:	9bc1                	and	a5,a5,-16
8000e0cc:	40f10133          	sub	sp,sp,a5
8000e0d0:	84aa                	mv	s1,a0
8000e0d2:	fb840513          	add	a0,s0,-72
8000e0d6:	a07fb0ef          	jal	80009adc <__SEGGER_RTL_init_prin_l>
8000e0da:	800007b7          	lui	a5,0x80000
8000e0de:	fac42603          	lw	a2,-84(s0)
8000e0e2:	17fd                	add	a5,a5,-1 # 7fffffff <_flash_size+0x7fefffff>
8000e0e4:	faf42e23          	sw	a5,-68(s0)
8000e0e8:	8000e7b7          	lui	a5,0x8000e
8000e0ec:	f9878793          	add	a5,a5,-104 # 8000df98 <__SEGGER_RTL_stream_write>
8000e0f0:	85ca                	mv	a1,s2
8000e0f2:	fb840513          	add	a0,s0,-72
8000e0f6:	fc242423          	sw	sp,-56(s0)
8000e0fa:	fc942823          	sw	s1,-48(s0)
8000e0fe:	fd342e23          	sw	s3,-36(s0)
8000e102:	fcf42c23          	sw	a5,-40(s0)
8000e106:	2015                	jal	8000e12a <__SEGGER_RTL_vfprintf>
8000e108:	fa040113          	add	sp,s0,-96
8000e10c:	40f6                	lw	ra,92(sp)
8000e10e:	4466                	lw	s0,88(sp)
8000e110:	44d6                	lw	s1,84(sp)
8000e112:	4946                	lw	s2,80(sp)
8000e114:	49b6                	lw	s3,76(sp)
8000e116:	6125                	add	sp,sp,96
8000e118:	8082                	ret

Disassembly of section .text.libc.vprintf:

8000e11a <vprintf>:
8000e11a:	000807b7          	lui	a5,0x80
8000e11e:	862e                	mv	a2,a1
8000e120:	85aa                	mv	a1,a0
8000e122:	2687a503          	lw	a0,616(a5) # 80268 <stdout>
8000e126:	9f1fb06f          	j	80009b16 <vfprintf>

Disassembly of section .text.libc.__SEGGER_RTL_vfprintf_short_float_long:

8000e12a <__SEGGER_RTL_vfprintf>:
8000e12a:	800057b7          	lui	a5,0x80005
8000e12e:	7175                	add	sp,sp,-144
8000e130:	51c78793          	add	a5,a5,1308 # 8000551c <.L9>
8000e134:	c83e                	sw	a5,16(sp)
8000e136:	800057b7          	lui	a5,0x80005
8000e13a:	dece                	sw	s3,124(sp)
8000e13c:	dad6                	sw	s5,116(sp)
8000e13e:	ceee                	sw	s11,92(sp)
8000e140:	c706                	sw	ra,140(sp)
8000e142:	c522                	sw	s0,136(sp)
8000e144:	c326                	sw	s1,132(sp)
8000e146:	c14a                	sw	s2,128(sp)
8000e148:	dcd2                	sw	s4,120(sp)
8000e14a:	d8da                	sw	s6,112(sp)
8000e14c:	d6de                	sw	s7,108(sp)
8000e14e:	d4e2                	sw	s8,104(sp)
8000e150:	d2e6                	sw	s9,100(sp)
8000e152:	d0ea                	sw	s10,96(sp)
8000e154:	56078793          	add	a5,a5,1376 # 80005560 <.L45>
8000e158:	00020db7          	lui	s11,0x20
8000e15c:	89aa                	mv	s3,a0
8000e15e:	8ab2                	mv	s5,a2
8000e160:	00052023          	sw	zero,0(a0)
8000e164:	ca3e                	sw	a5,20(sp)
8000e166:	021d8d93          	add	s11,s11,33 # 20021 <__DLM_segment_size__+0x21>

8000e16a <.L2>:
8000e16a:	00158a13          	add	s4,a1,1 # 1000001 <_flash_size+0xf00001>
8000e16e:	0005c583          	lbu	a1,0(a1)
8000e172:	e19d                	bnez	a1,8000e198 <.L229>
8000e174:	00c9a783          	lw	a5,12(s3)
8000e178:	cb91                	beqz	a5,8000e18c <.L230>
8000e17a:	0009a703          	lw	a4,0(s3)
8000e17e:	0049a683          	lw	a3,4(s3)
8000e182:	00d77563          	bgeu	a4,a3,8000e18c <.L230>
8000e186:	97ba                	add	a5,a5,a4
8000e188:	00078023          	sb	zero,0(a5)

8000e18c <.L230>:
8000e18c:	854e                	mv	a0,s3
8000e18e:	913fb0ef          	jal	80009aa0 <__SEGGER_RTL_prin_flush>
8000e192:	0009a503          	lw	a0,0(s3)
8000e196:	a2f9                	j	8000e364 <.L338>

8000e198 <.L229>:
8000e198:	02500793          	li	a5,37
8000e19c:	00f58563          	beq	a1,a5,8000e1a6 <.L231>

8000e1a0 <.L362>:
8000e1a0:	854e                	mv	a0,s3
8000e1a2:	3509                	jal	8000dfa4 <__SEGGER_RTL_putc>
8000e1a4:	aab9                	j	8000e302 <.L4>

8000e1a6 <.L231>:
8000e1a6:	4b81                	li	s7,0
8000e1a8:	03000613          	li	a2,48
8000e1ac:	05e00593          	li	a1,94
8000e1b0:	6505                	lui	a0,0x1
8000e1b2:	487d                	li	a6,31
8000e1b4:	48c1                	li	a7,16
8000e1b6:	6321                	lui	t1,0x8
8000e1b8:	a03d                	j	8000e1e6 <.L3>

8000e1ba <.L5>:
8000e1ba:	04b78f63          	beq	a5,a1,8000e218 <.L15>

8000e1be <.L232>:
8000e1be:	8a36                	mv	s4,a3
8000e1c0:	4b01                	li	s6,0
8000e1c2:	46a5                	li	a3,9
8000e1c4:	45a9                	li	a1,10

8000e1c6 <.L18>:
8000e1c6:	fd078713          	add	a4,a5,-48
8000e1ca:	0ff77613          	zext.b	a2,a4
8000e1ce:	08c6e363          	bltu	a3,a2,8000e254 <.L20>
8000e1d2:	02bb0b33          	mul	s6,s6,a1
8000e1d6:	0a05                	add	s4,s4,1
8000e1d8:	fffa4783          	lbu	a5,-1(s4)
8000e1dc:	9b3a                	add	s6,s6,a4
8000e1de:	b7e5                	j	8000e1c6 <.L18>

8000e1e0 <.L14>:
8000e1e0:	040beb93          	or	s7,s7,64

8000e1e4 <.L16>:
8000e1e4:	8a36                	mv	s4,a3

8000e1e6 <.L3>:
8000e1e6:	000a4783          	lbu	a5,0(s4)
8000e1ea:	001a0693          	add	a3,s4,1
8000e1ee:	fcf666e3          	bltu	a2,a5,8000e1ba <.L5>
8000e1f2:	fcf876e3          	bgeu	a6,a5,8000e1be <.L232>
8000e1f6:	fe078713          	add	a4,a5,-32
8000e1fa:	0ff77713          	zext.b	a4,a4
8000e1fe:	02e8e963          	bltu	a7,a4,8000e230 <.L7>
8000e202:	4442                	lw	s0,16(sp)
8000e204:	070a                	sll	a4,a4,0x2
8000e206:	9722                	add	a4,a4,s0
8000e208:	4318                	lw	a4,0(a4)
8000e20a:	8702                	jr	a4

8000e20c <.L13>:
8000e20c:	080beb93          	or	s7,s7,128
8000e210:	bfd1                	j	8000e1e4 <.L16>

8000e212 <.L12>:
8000e212:	006bebb3          	or	s7,s7,t1
8000e216:	b7f9                	j	8000e1e4 <.L16>

8000e218 <.L15>:
8000e218:	00abebb3          	or	s7,s7,a0
8000e21c:	b7e1                	j	8000e1e4 <.L16>

8000e21e <.L11>:
8000e21e:	020beb93          	or	s7,s7,32
8000e222:	b7c9                	j	8000e1e4 <.L16>

8000e224 <.L10>:
8000e224:	010beb93          	or	s7,s7,16
8000e228:	bf75                	j	8000e1e4 <.L16>

8000e22a <.L8>:
8000e22a:	200beb93          	or	s7,s7,512
8000e22e:	bf5d                	j	8000e1e4 <.L16>

8000e230 <.L7>:
8000e230:	02a00713          	li	a4,42
8000e234:	f8e795e3          	bne	a5,a4,8000e1be <.L232>
8000e238:	000aab03          	lw	s6,0(s5)
8000e23c:	004a8713          	add	a4,s5,4
8000e240:	000b5663          	bgez	s6,8000e24c <.L19>
8000e244:	41600b33          	neg	s6,s6
8000e248:	010beb93          	or	s7,s7,16

8000e24c <.L19>:
8000e24c:	0006c783          	lbu	a5,0(a3)
8000e250:	0a09                	add	s4,s4,2
8000e252:	8aba                	mv	s5,a4

8000e254 <.L20>:
8000e254:	000b5363          	bgez	s6,8000e25a <.L22>
8000e258:	4b01                	li	s6,0

8000e25a <.L22>:
8000e25a:	02e00713          	li	a4,46
8000e25e:	4481                	li	s1,0
8000e260:	04e79263          	bne	a5,a4,8000e2a4 <.L23>
8000e264:	000a4783          	lbu	a5,0(s4)
8000e268:	02a00713          	li	a4,42
8000e26c:	02e78263          	beq	a5,a4,8000e290 <.L24>
8000e270:	0a05                	add	s4,s4,1
8000e272:	46a5                	li	a3,9
8000e274:	45a9                	li	a1,10

8000e276 <.L25>:
8000e276:	fd078713          	add	a4,a5,-48
8000e27a:	0ff77613          	zext.b	a2,a4
8000e27e:	00c6ef63          	bltu	a3,a2,8000e29c <.L26>
8000e282:	02b484b3          	mul	s1,s1,a1
8000e286:	0a05                	add	s4,s4,1
8000e288:	fffa4783          	lbu	a5,-1(s4)
8000e28c:	94ba                	add	s1,s1,a4
8000e28e:	b7e5                	j	8000e276 <.L25>

8000e290 <.L24>:
8000e290:	000aa483          	lw	s1,0(s5)
8000e294:	001a4783          	lbu	a5,1(s4)
8000e298:	0a91                	add	s5,s5,4
8000e29a:	0a09                	add	s4,s4,2

8000e29c <.L26>:
8000e29c:	0004c463          	bltz	s1,8000e2a4 <.L23>
8000e2a0:	100beb93          	or	s7,s7,256

8000e2a4 <.L23>:
8000e2a4:	06c00713          	li	a4,108
8000e2a8:	06e78263          	beq	a5,a4,8000e30c <.L28>
8000e2ac:	02f76c63          	bltu	a4,a5,8000e2e4 <.L29>
8000e2b0:	06800713          	li	a4,104
8000e2b4:	06e78a63          	beq	a5,a4,8000e328 <.L30>
8000e2b8:	06a00713          	li	a4,106
8000e2bc:	04e78563          	beq	a5,a4,8000e306 <.L31>

8000e2c0 <.L32>:
8000e2c0:	05700713          	li	a4,87
8000e2c4:	2ef765e3          	bltu	a4,a5,8000edae <.L38>
8000e2c8:	04500713          	li	a4,69
8000e2cc:	2ce78863          	beq	a5,a4,8000e59c <.L39>
8000e2d0:	06f76763          	bltu	a4,a5,8000e33e <.L40>
8000e2d4:	c7c1                	beqz	a5,8000e35c <.L41>
8000e2d6:	02500713          	li	a4,37
8000e2da:	02500593          	li	a1,37
8000e2de:	ece781e3          	beq	a5,a4,8000e1a0 <.L362>
8000e2e2:	a005                	j	8000e302 <.L4>

8000e2e4 <.L29>:
8000e2e4:	07400713          	li	a4,116
8000e2e8:	00e78663          	beq	a5,a4,8000e2f4 <.L346>
8000e2ec:	07a00713          	li	a4,122
8000e2f0:	2ae79be3          	bne	a5,a4,8000eda6 <.L34>

8000e2f4 <.L346>:
8000e2f4:	000a4783          	lbu	a5,0(s4)
8000e2f8:	0a05                	add	s4,s4,1

8000e2fa <.L35>:
8000e2fa:	07800713          	li	a4,120
8000e2fe:	fcf771e3          	bgeu	a4,a5,8000e2c0 <.L32>

8000e302 <.L4>:
8000e302:	85d2                	mv	a1,s4
8000e304:	b59d                	j	8000e16a <.L2>

8000e306 <.L31>:
8000e306:	002beb93          	or	s7,s7,2
8000e30a:	b7ed                	j	8000e2f4 <.L346>

8000e30c <.L28>:
8000e30c:	000a4783          	lbu	a5,0(s4)
8000e310:	00e79863          	bne	a5,a4,8000e320 <.L36>
8000e314:	002beb93          	or	s7,s7,2

8000e318 <.L347>:
8000e318:	001a4783          	lbu	a5,1(s4)
8000e31c:	0a09                	add	s4,s4,2
8000e31e:	bff1                	j	8000e2fa <.L35>

8000e320 <.L36>:
8000e320:	0a05                	add	s4,s4,1
8000e322:	001beb93          	or	s7,s7,1
8000e326:	bfd1                	j	8000e2fa <.L35>

8000e328 <.L30>:
8000e328:	000a4783          	lbu	a5,0(s4)
8000e32c:	00e79563          	bne	a5,a4,8000e336 <.L37>
8000e330:	008beb93          	or	s7,s7,8
8000e334:	b7d5                	j	8000e318 <.L347>

8000e336 <.L37>:
8000e336:	0a05                	add	s4,s4,1
8000e338:	004beb93          	or	s7,s7,4
8000e33c:	bf7d                	j	8000e2fa <.L35>

8000e33e <.L40>:
8000e33e:	04600713          	li	a4,70
8000e342:	2ce78763          	beq	a5,a4,8000e610 <.L57>
8000e346:	04700713          	li	a4,71
8000e34a:	fae79ce3          	bne	a5,a4,8000e302 <.L4>
8000e34e:	6789                	lui	a5,0x2
8000e350:	00fbebb3          	or	s7,s7,a5

8000e354 <.L52>:
8000e354:	6905                	lui	s2,0x1
8000e356:	c0090913          	add	s2,s2,-1024 # c00 <__NOR_CFG_OPTION_segment_size__>
8000e35a:	a4c9                	j	8000e61c <.L353>

8000e35c <.L41>:
8000e35c:	854e                	mv	a0,s3
8000e35e:	f42fb0ef          	jal	80009aa0 <__SEGGER_RTL_prin_flush>
8000e362:	557d                	li	a0,-1

8000e364 <.L338>:
8000e364:	40ba                	lw	ra,140(sp)
8000e366:	442a                	lw	s0,136(sp)
8000e368:	449a                	lw	s1,132(sp)
8000e36a:	490a                	lw	s2,128(sp)
8000e36c:	59f6                	lw	s3,124(sp)
8000e36e:	5a66                	lw	s4,120(sp)
8000e370:	5ad6                	lw	s5,116(sp)
8000e372:	5b46                	lw	s6,112(sp)
8000e374:	5bb6                	lw	s7,108(sp)
8000e376:	5c26                	lw	s8,104(sp)
8000e378:	5c96                	lw	s9,100(sp)
8000e37a:	5d06                	lw	s10,96(sp)
8000e37c:	4df6                	lw	s11,92(sp)
8000e37e:	6149                	add	sp,sp,144
8000e380:	8082                	ret

8000e382 <.L55>:
8000e382:	000aa483          	lw	s1,0(s5)
8000e386:	1b7d                	add	s6,s6,-1
8000e388:	865a                	mv	a2,s6
8000e38a:	85de                	mv	a1,s7
8000e38c:	854e                	mv	a0,s3
8000e38e:	f34fb0ef          	jal	80009ac2 <__SEGGER_RTL_pre_padding>
8000e392:	004a8413          	add	s0,s5,4
8000e396:	0ff4f593          	zext.b	a1,s1
8000e39a:	854e                	mv	a0,s3
8000e39c:	3121                	jal	8000dfa4 <__SEGGER_RTL_putc>
8000e39e:	8aa2                	mv	s5,s0

8000e3a0 <.L371>:
8000e3a0:	010bfb93          	and	s7,s7,16
8000e3a4:	f40b8fe3          	beqz	s7,8000e302 <.L4>
8000e3a8:	865a                	mv	a2,s6
8000e3aa:	02000593          	li	a1,32
8000e3ae:	854e                	mv	a0,s3
8000e3b0:	3941                	jal	8000e040 <__SEGGER_RTL_print_padding>
8000e3b2:	bf81                	j	8000e302 <.L4>

8000e3b4 <.L50>:
8000e3b4:	008bf693          	and	a3,s7,8
8000e3b8:	000aa783          	lw	a5,0(s5)
8000e3bc:	0009a703          	lw	a4,0(s3)
8000e3c0:	0a91                	add	s5,s5,4
8000e3c2:	c681                	beqz	a3,8000e3ca <.L62>
8000e3c4:	00e78023          	sb	a4,0(a5) # 2000 <__BOOT_HEADER_segment_size__>
8000e3c8:	bf2d                	j	8000e302 <.L4>

8000e3ca <.L62>:
8000e3ca:	002bfb93          	and	s7,s7,2
8000e3ce:	c398                	sw	a4,0(a5)
8000e3d0:	f20b89e3          	beqz	s7,8000e302 <.L4>
8000e3d4:	0007a223          	sw	zero,4(a5)
8000e3d8:	b72d                	j	8000e302 <.L4>

8000e3da <.L47>:
8000e3da:	000aa403          	lw	s0,0(s5)
8000e3de:	895e                	mv	s2,s7
8000e3e0:	0a91                	add	s5,s5,4

8000e3e2 <.L65>:
8000e3e2:	e409                	bnez	s0,8000e3ec <.L66>
8000e3e4:	80005437          	lui	s0,0x80005
8000e3e8:	4ec40413          	add	s0,s0,1260 # 800054ec <.LC0>

8000e3ec <.L66>:
8000e3ec:	dff97b93          	and	s7,s2,-513
8000e3f0:	10097913          	and	s2,s2,256
8000e3f4:	02090563          	beqz	s2,8000e41e <.L67>
8000e3f8:	85a6                	mv	a1,s1
8000e3fa:	8522                	mv	a0,s0
8000e3fc:	3611                	jal	8000df00 <strnlen>

8000e3fe <.L348>:
8000e3fe:	40ab0b33          	sub	s6,s6,a0
8000e402:	84aa                	mv	s1,a0
8000e404:	865a                	mv	a2,s6
8000e406:	85de                	mv	a1,s7
8000e408:	854e                	mv	a0,s3
8000e40a:	eb8fb0ef          	jal	80009ac2 <__SEGGER_RTL_pre_padding>

8000e40e <.L69>:
8000e40e:	d8c9                	beqz	s1,8000e3a0 <.L371>
8000e410:	00044583          	lbu	a1,0(s0)
8000e414:	854e                	mv	a0,s3
8000e416:	0405                	add	s0,s0,1
8000e418:	3671                	jal	8000dfa4 <__SEGGER_RTL_putc>
8000e41a:	14fd                	add	s1,s1,-1
8000e41c:	bfcd                	j	8000e40e <.L69>

8000e41e <.L67>:
8000e41e:	8522                	mv	a0,s0
8000e420:	fa8ff0ef          	jal	8000dbc8 <strlen>
8000e424:	bfe9                	j	8000e3fe <.L348>

8000e426 <.L48>:
8000e426:	080bf713          	and	a4,s7,128
8000e42a:	000aa403          	lw	s0,0(s5)
8000e42e:	004a8693          	add	a3,s5,4
8000e432:	4581                	li	a1,0
8000e434:	02300c93          	li	s9,35
8000e438:	e311                	bnez	a4,8000e43c <.L71>
8000e43a:	4c81                	li	s9,0

8000e43c <.L71>:
8000e43c:	100beb93          	or	s7,s7,256
8000e440:	8ab6                	mv	s5,a3
8000e442:	44a1                	li	s1,8

8000e444 <.L72>:
8000e444:	100bf713          	and	a4,s7,256
8000e448:	e311                	bnez	a4,8000e44c <.L203>
8000e44a:	4485                	li	s1,1

8000e44c <.L203>:
8000e44c:	05800713          	li	a4,88
8000e450:	08e788e3          	beq	a5,a4,8000ece0 <.L204>
8000e454:	f9c78693          	add	a3,a5,-100
8000e458:	4705                	li	a4,1
8000e45a:	00d71733          	sll	a4,a4,a3
8000e45e:	01b776b3          	and	a3,a4,s11
8000e462:	00069ae3          	bnez	a3,8000ec76 <.L205>
8000e466:	00c75693          	srl	a3,a4,0xc
8000e46a:	1016f693          	and	a3,a3,257
8000e46e:	060699e3          	bnez	a3,8000ece0 <.L204>
8000e472:	06f00713          	li	a4,111
8000e476:	4c01                	li	s8,0
8000e478:	08e793e3          	bne	a5,a4,8000ecfe <.L206>

8000e47c <.L207>:
8000e47c:	00b467b3          	or	a5,s0,a1
8000e480:	06078fe3          	beqz	a5,8000ecfe <.L206>
8000e484:	183c                	add	a5,sp,56
8000e486:	01878733          	add	a4,a5,s8
8000e48a:	00747793          	and	a5,s0,7
8000e48e:	03078793          	add	a5,a5,48
8000e492:	00f70023          	sb	a5,0(a4)
8000e496:	800d                	srl	s0,s0,0x3
8000e498:	01d59793          	sll	a5,a1,0x1d
8000e49c:	0c05                	add	s8,s8,1 # 4001 <.LBB0_2+0x3b>
8000e49e:	8c5d                	or	s0,s0,a5
8000e4a0:	818d                	srl	a1,a1,0x3
8000e4a2:	bfe9                	j	8000e47c <.L207>

8000e4a4 <.L56>:
8000e4a4:	6709                	lui	a4,0x2
8000e4a6:	00ebebb3          	or	s7,s7,a4

8000e4aa <.L44>:
8000e4aa:	080bf713          	and	a4,s7,128
8000e4ae:	4c81                	li	s9,0
8000e4b0:	cb19                	beqz	a4,8000e4c6 <.L75>
8000e4b2:	6c8d                	lui	s9,0x3
8000e4b4:	07800713          	li	a4,120
8000e4b8:	058c8c93          	add	s9,s9,88 # 3058 <.LBB4_19+0x28>
8000e4bc:	00e79563          	bne	a5,a4,8000e4c6 <.L75>
8000e4c0:	6c8d                	lui	s9,0x3
8000e4c2:	078c8c93          	add	s9,s9,120 # 3078 <.LBB4_21+0x1c>

8000e4c6 <.L75>:
8000e4c6:	100bf713          	and	a4,s7,256

8000e4ca <.L365>:
8000e4ca:	c319                	beqz	a4,8000e4d0 <.L74>
8000e4cc:	dffbfb93          	and	s7,s7,-513

8000e4d0 <.L74>:
8000e4d0:	011b9613          	sll	a2,s7,0x11
8000e4d4:	002bf713          	and	a4,s7,2
8000e4d8:	004bf693          	and	a3,s7,4
8000e4dc:	08065563          	bgez	a2,8000e566 <.L76>
8000e4e0:	cf31                	beqz	a4,8000e53c <.L77>
8000e4e2:	007a8713          	add	a4,s5,7
8000e4e6:	9b61                	and	a4,a4,-8
8000e4e8:	4300                	lw	s0,0(a4)
8000e4ea:	434c                	lw	a1,4(a4)
8000e4ec:	00870a93          	add	s5,a4,8 # 2008 <__BOOT_HEADER_segment_size__+0x8>

8000e4f0 <.L78>:
8000e4f0:	cea1                	beqz	a3,8000e548 <.L79>
8000e4f2:	0442                	sll	s0,s0,0x10
8000e4f4:	8441                	sra	s0,s0,0x10

8000e4f6 <.L351>:
8000e4f6:	41f45593          	sra	a1,s0,0x1f

8000e4fa <.L80>:
8000e4fa:	0405dd63          	bgez	a1,8000e554 <.L82>
8000e4fe:	00803733          	snez	a4,s0
8000e502:	40b005b3          	neg	a1,a1
8000e506:	8d99                	sub	a1,a1,a4
8000e508:	40800433          	neg	s0,s0
8000e50c:	02d00c93          	li	s9,45

8000e510 <.L84>:
8000e510:	100bf713          	and	a4,s7,256
8000e514:	db05                	beqz	a4,8000e444 <.L72>
8000e516:	dffbfb93          	and	s7,s7,-513
8000e51a:	b72d                	j	8000e444 <.L72>

8000e51c <.L49>:
8000e51c:	080bf713          	and	a4,s7,128
8000e520:	03000c93          	li	s9,48
8000e524:	f34d                	bnez	a4,8000e4c6 <.L75>
8000e526:	4c81                	li	s9,0
8000e528:	bf79                	j	8000e4c6 <.L75>

8000e52a <.L46>:
8000e52a:	100bf713          	and	a4,s7,256
8000e52e:	4c81                	li	s9,0
8000e530:	bf69                	j	8000e4ca <.L365>

8000e532 <.L51>:
8000e532:	6711                	lui	a4,0x4
8000e534:	00ebebb3          	or	s7,s7,a4
8000e538:	4c81                	li	s9,0
8000e53a:	bf59                	j	8000e4d0 <.L74>

8000e53c <.L77>:
8000e53c:	000aa403          	lw	s0,0(s5)
8000e540:	0a91                	add	s5,s5,4
8000e542:	41f45593          	sra	a1,s0,0x1f
8000e546:	b76d                	j	8000e4f0 <.L78>

8000e548 <.L79>:
8000e548:	008bf713          	and	a4,s7,8
8000e54c:	d75d                	beqz	a4,8000e4fa <.L80>
8000e54e:	0462                	sll	s0,s0,0x18
8000e550:	8461                	sra	s0,s0,0x18
8000e552:	b755                	j	8000e4f6 <.L351>

8000e554 <.L82>:
8000e554:	020bf713          	and	a4,s7,32
8000e558:	ef1d                	bnez	a4,8000e596 <.L239>
8000e55a:	040bf713          	and	a4,s7,64
8000e55e:	db4d                	beqz	a4,8000e510 <.L84>
8000e560:	02000c93          	li	s9,32
8000e564:	b775                	j	8000e510 <.L84>

8000e566 <.L76>:
8000e566:	cf09                	beqz	a4,8000e580 <.L85>
8000e568:	007a8713          	add	a4,s5,7
8000e56c:	9b61                	and	a4,a4,-8
8000e56e:	4300                	lw	s0,0(a4)
8000e570:	434c                	lw	a1,4(a4)
8000e572:	00870a93          	add	s5,a4,8 # 4008 <.LBB0_2+0x42>

8000e576 <.L86>:
8000e576:	ca91                	beqz	a3,8000e58a <.L87>
8000e578:	0442                	sll	s0,s0,0x10
8000e57a:	8041                	srl	s0,s0,0x10

8000e57c <.L352>:
8000e57c:	4581                	li	a1,0
8000e57e:	bf49                	j	8000e510 <.L84>

8000e580 <.L85>:
8000e580:	000aa403          	lw	s0,0(s5)
8000e584:	4581                	li	a1,0
8000e586:	0a91                	add	s5,s5,4
8000e588:	b7fd                	j	8000e576 <.L86>

8000e58a <.L87>:
8000e58a:	008bf713          	and	a4,s7,8
8000e58e:	d349                	beqz	a4,8000e510 <.L84>
8000e590:	0ff47413          	zext.b	s0,s0
8000e594:	b7e5                	j	8000e57c <.L352>

8000e596 <.L239>:
8000e596:	02b00c93          	li	s9,43
8000e59a:	bf9d                	j	8000e510 <.L84>

8000e59c <.L39>:
8000e59c:	6789                	lui	a5,0x2
8000e59e:	00fbebb3          	or	s7,s7,a5

8000e5a2 <.L54>:
8000e5a2:	400be913          	or	s2,s7,1024

8000e5a6 <.L91>:
8000e5a6:	00297793          	and	a5,s2,2
8000e5aa:	cfa5                	beqz	a5,8000e622 <.L92>
8000e5ac:	000aa783          	lw	a5,0(s5)
8000e5b0:	1008                	add	a0,sp,32
8000e5b2:	004a8413          	add	s0,s5,4
8000e5b6:	4398                	lw	a4,0(a5)
8000e5b8:	8aa2                	mv	s5,s0
8000e5ba:	d03a                	sw	a4,32(sp)
8000e5bc:	43d8                	lw	a4,4(a5)
8000e5be:	d23a                	sw	a4,36(sp)
8000e5c0:	4798                	lw	a4,8(a5)
8000e5c2:	d43a                	sw	a4,40(sp)
8000e5c4:	47dc                	lw	a5,12(a5)
8000e5c6:	d63e                	sw	a5,44(sp)
8000e5c8:	bb4ff0ef          	jal	8000d97c <__trunctfsf2>
8000e5cc:	8baa                	mv	s7,a0

8000e5ce <.L93>:
8000e5ce:	10097793          	and	a5,s2,256
8000e5d2:	c3bd                	beqz	a5,8000e638 <.L240>
8000e5d4:	e889                	bnez	s1,8000e5e6 <.L94>
8000e5d6:	6785                	lui	a5,0x1
8000e5d8:	c0078793          	add	a5,a5,-1024 # c00 <__NOR_CFG_OPTION_segment_size__>
8000e5dc:	00f974b3          	and	s1,s2,a5
8000e5e0:	8c9d                	sub	s1,s1,a5
8000e5e2:	0014b493          	seqz	s1,s1

8000e5e6 <.L94>:
8000e5e6:	855e                	mv	a0,s7
8000e5e8:	96bfa0ef          	jal	80008f52 <__SEGGER_RTL_float32_isinf>
8000e5ec:	c921                	beqz	a0,8000e63c <.L95>

8000e5ee <.L117>:
8000e5ee:	6409                	lui	s0,0x2
8000e5f0:	00000593          	li	a1,0
8000e5f4:	855e                	mv	a0,s7
8000e5f6:	00897433          	and	s0,s2,s0
8000e5fa:	d9cfa0ef          	jal	80008b96 <__ltsf2>
8000e5fe:	40055b63          	bgez	a0,8000ea14 <.L341>
8000e602:	40040463          	beqz	s0,8000ea0a <.L244>
8000e606:	80005437          	lui	s0,0x80005
8000e60a:	4f440413          	add	s0,s0,1268 # 800054f4 <.LC1>
8000e60e:	a099                	j	8000e654 <.L122>

8000e610 <.L57>:
8000e610:	6789                	lui	a5,0x2
8000e612:	00fbebb3          	or	s7,s7,a5

8000e616 <.L53>:
8000e616:	6905                	lui	s2,0x1
8000e618:	80090913          	add	s2,s2,-2048 # 800 <.LBB2_28+0x6>

8000e61c <.L353>:
8000e61c:	012be933          	or	s2,s7,s2
8000e620:	b759                	j	8000e5a6 <.L91>

8000e622 <.L92>:
8000e622:	007a8793          	add	a5,s5,7
8000e626:	9be1                	and	a5,a5,-8
8000e628:	4388                	lw	a0,0(a5)
8000e62a:	43cc                	lw	a1,4(a5)
8000e62c:	00878a93          	add	s5,a5,8 # 2008 <__BOOT_HEADER_segment_size__+0x8>
8000e630:	811fa0ef          	jal	80008e40 <__truncdfsf2>
8000e634:	8baa                	mv	s7,a0
8000e636:	bf61                	j	8000e5ce <.L93>

8000e638 <.L240>:
8000e638:	4499                	li	s1,6
8000e63a:	b775                	j	8000e5e6 <.L94>

8000e63c <.L95>:
8000e63c:	855e                	mv	a0,s7
8000e63e:	903fa0ef          	jal	80008f40 <__SEGGER_RTL_float32_isnan>
8000e642:	c10d                	beqz	a0,8000e664 <.L101>
8000e644:	01291793          	sll	a5,s2,0x12
8000e648:	0007d963          	bgez	a5,8000e65a <.L243>
8000e64c:	80005437          	lui	s0,0x80005
8000e650:	51440413          	add	s0,s0,1300 # 80005514 <.LC5>

8000e654 <.L122>:
8000e654:	eff97913          	and	s2,s2,-257
8000e658:	b369                	j	8000e3e2 <.L65>

8000e65a <.L243>:
8000e65a:	80005437          	lui	s0,0x80005
8000e65e:	51840413          	add	s0,s0,1304 # 80005518 <.LC6>
8000e662:	bfcd                	j	8000e654 <.L122>

8000e664 <.L101>:
8000e664:	855e                	mv	a0,s7
8000e666:	8fbfa0ef          	jal	80008f60 <__SEGGER_RTL_float32_isnormal>
8000e66a:	e119                	bnez	a0,8000e670 <.L103>
8000e66c:	00000b93          	li	s7,0

8000e670 <.L103>:
8000e670:	855e                	mv	a0,s7
8000e672:	845e                	mv	s0,s7
8000e674:	b2cff0ef          	jal	8000d9a0 <__SEGGER_RTL_float32_signbit>
8000e678:	c519                	beqz	a0,8000e686 <.L104>
8000e67a:	80000437          	lui	s0,0x80000
8000e67e:	06096913          	or	s2,s2,96
8000e682:	01744433          	xor	s0,s0,s7

8000e686 <.L104>:
8000e686:	184c                	add	a1,sp,52
8000e688:	8522                	mv	a0,s0
8000e68a:	b5eff0ef          	jal	8000d9e8 <frexpf>
8000e68e:	5752                	lw	a4,52(sp)
8000e690:	478d                	li	a5,3
8000e692:	00000593          	li	a1,0
8000e696:	02e787b3          	mul	a5,a5,a4
8000e69a:	4729                	li	a4,10
8000e69c:	8522                	mv	a0,s0
8000e69e:	8ba2                	mv	s7,s0
8000e6a0:	02e7c7b3          	div	a5,a5,a4
8000e6a4:	da3e                	sw	a5,52(sp)
8000e6a6:	a02ff0ef          	jal	8000d8a8 <__eqsf2>
8000e6aa:	24051a63          	bnez	a0,8000e8fe <.L105>

8000e6ae <.L111>:
8000e6ae:	6785                	lui	a5,0x1
8000e6b0:	c0078793          	add	a5,a5,-1024 # c00 <__NOR_CFG_OPTION_segment_size__>
8000e6b4:	00f97c33          	and	s8,s2,a5
8000e6b8:	40000713          	li	a4,1024
8000e6bc:	5552                	lw	a0,52(sp)
8000e6be:	26ec1763          	bne	s8,a4,8000e92c <.L340>

8000e6c2 <.L106>:
8000e6c2:	02600793          	li	a5,38
8000e6c6:	32f51963          	bne	a0,a5,8000e9f8 <.L113>
8000e6ca:	800057b7          	lui	a5,0x80005
8000e6ce:	6f87a583          	lw	a1,1784(a5) # 800056f8 <.Lmerged_single+0x10>
8000e6d2:	855e                	mv	a0,s7
8000e6d4:	f11fe0ef          	jal	8000d5e4 <__divsf3>

8000e6d8 <.L354>:
8000e6d8:	00000593          	li	a1,0
8000e6dc:	8baa                	mv	s7,a0
8000e6de:	842a                	mv	s0,a0
8000e6e0:	9c8ff0ef          	jal	8000d8a8 <__eqsf2>
8000e6e4:	c52d                	beqz	a0,8000e74e <.L116>
8000e6e6:	855e                	mv	a0,s7
8000e6e8:	86bfa0ef          	jal	80008f52 <__SEGGER_RTL_float32_isinf>
8000e6ec:	f00511e3          	bnez	a0,8000e5ee <.L117>
8000e6f0:	57d2                	lw	a5,52(sp)
8000e6f2:	4701                	li	a4,0

8000e6f4 <.L118>:
8000e6f4:	80005cb7          	lui	s9,0x80005
8000e6f8:	c63e                	sw	a5,12(sp)
8000e6fa:	00178d13          	add	s10,a5,1
8000e6fe:	800057b7          	lui	a5,0x80005
8000e702:	6f07a583          	lw	a1,1776(a5) # 800056f0 <.Lmerged_single+0x8>
8000e706:	855e                	mv	a0,s7
8000e708:	cc3a                	sw	a4,24(sp)
8000e70a:	d2efa0ef          	jal	80008c38 <__gesf2>
8000e70e:	47b2                	lw	a5,12(sp)
8000e710:	4762                	lw	a4,24(sp)
8000e712:	32055163          	bgez	a0,8000ea34 <.L124>
8000e716:	c319                	beqz	a4,8000e71c <.L125>
8000e718:	845e                	mv	s0,s7
8000e71a:	da3e                	sw	a5,52(sp)

8000e71c <.L125>:
8000e71c:	80005637          	lui	a2,0x80005
8000e720:	6ec62703          	lw	a4,1772(a2) # 800056ec <.Lmerged_single+0x4>
8000e724:	5d52                	lw	s10,52(sp)
8000e726:	6f0cac83          	lw	s9,1776(s9) # 800056f0 <.Lmerged_single+0x8>
8000e72a:	87a2                	mv	a5,s0
8000e72c:	4681                	li	a3,0
8000e72e:	c63a                	sw	a4,12(sp)

8000e730 <.L126>:
8000e730:	45b2                	lw	a1,12(sp)
8000e732:	853e                	mv	a0,a5
8000e734:	ce36                	sw	a3,28(sp)
8000e736:	cc3e                	sw	a5,24(sp)
8000e738:	c5efa0ef          	jal	80008b96 <__ltsf2>
8000e73c:	47e2                	lw	a5,24(sp)
8000e73e:	46f2                	lw	a3,28(sp)
8000e740:	fffd0b93          	add	s7,s10,-1
8000e744:	30054363          	bltz	a0,8000ea4a <.L127>
8000e748:	c299                	beqz	a3,8000e74e <.L116>
8000e74a:	843e                	mv	s0,a5
8000e74c:	da6a                	sw	s10,52(sp)

8000e74e <.L116>:
8000e74e:	c499                	beqz	s1,8000e75c <.L129>
8000e750:	6785                	lui	a5,0x1
8000e752:	c0078793          	add	a5,a5,-1024 # c00 <__NOR_CFG_OPTION_segment_size__>
8000e756:	00fc1363          	bne	s8,a5,8000e75c <.L129>
8000e75a:	14fd                	add	s1,s1,-1

8000e75c <.L129>:
8000e75c:	40900533          	neg	a0,s1
8000e760:	ae6fb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e764:	55fd                	li	a1,-1
8000e766:	a3eff0ef          	jal	8000d9a4 <ldexpf>
8000e76a:	85a2                	mv	a1,s0
8000e76c:	a7cfa0ef          	jal	800089e8 <__addsf3>
8000e770:	80005cb7          	lui	s9,0x80005
8000e774:	6f0ca583          	lw	a1,1776(s9) # 800056f0 <.Lmerged_single+0x8>
8000e778:	8baa                	mv	s7,a0
8000e77a:	842a                	mv	s0,a0
8000e77c:	cbcfa0ef          	jal	80008c38 <__gesf2>
8000e780:	00054b63          	bltz	a0,8000e796 <.L130>
8000e784:	57d2                	lw	a5,52(sp)
8000e786:	6f0ca583          	lw	a1,1776(s9)
8000e78a:	855e                	mv	a0,s7
8000e78c:	0785                	add	a5,a5,1
8000e78e:	da3e                	sw	a5,52(sp)
8000e790:	e55fe0ef          	jal	8000d5e4 <__divsf3>
8000e794:	842a                	mv	s0,a0

8000e796 <.L130>:
8000e796:	c622                	sw	s0,12(sp)
8000e798:	2c049163          	bnez	s1,8000ea5a <.L132>

8000e79c <.L135>:
8000e79c:	4481                	li	s1,0

8000e79e <.L133>:
8000e79e:	00548793          	add	a5,s1,5
8000e7a2:	7c7d                	lui	s8,0xfffff
8000e7a4:	40fb0b33          	sub	s6,s6,a5
8000e7a8:	08097793          	and	a5,s2,128
8000e7ac:	7ffc0c13          	add	s8,s8,2047 # fffff7ff <__AHB_SRAM_segment_end__+0xfbf77ff>
8000e7b0:	8fc5                	or	a5,a5,s1
8000e7b2:	01897c33          	and	s8,s2,s8
8000e7b6:	c391                	beqz	a5,8000e7ba <.L139>
8000e7b8:	1b7d                	add	s6,s6,-1

8000e7ba <.L139>:
8000e7ba:	01391793          	sll	a5,s2,0x13
8000e7be:	4d05                	li	s10,1
8000e7c0:	0207dc63          	bgez	a5,8000e7f8 <.L140>
8000e7c4:	5bd2                	lw	s7,52(sp)
8000e7c6:	470d                	li	a4,3
8000e7c8:	02ebe733          	rem	a4,s7,a4
8000e7cc:	c31d                	beqz	a4,8000e7f2 <.L141>
8000e7ce:	0709                	add	a4,a4,2
8000e7d0:	56b5                	li	a3,-19
8000e7d2:	40e6d733          	sra	a4,a3,a4
8000e7d6:	8b05                	and	a4,a4,1
8000e7d8:	2c070e63          	beqz	a4,8000eab4 <.L142>
8000e7dc:	6f0ca583          	lw	a1,1776(s9)
8000e7e0:	4532                	lw	a0,12(sp)
8000e7e2:	1b7d                	add	s6,s6,-1
8000e7e4:	4d09                	li	s10,2
8000e7e6:	c3ffe0ef          	jal	8000d424 <__mulsf3>
8000e7ea:	fffb8793          	add	a5,s7,-1
8000e7ee:	842a                	mv	s0,a0
8000e7f0:	da3e                	sw	a5,52(sp)

8000e7f2 <.L141>:
8000e7f2:	0004d363          	bgez	s1,8000e7f8 <.L140>
8000e7f6:	4481                	li	s1,0

8000e7f8 <.L140>:
8000e7f8:	06097913          	and	s2,s2,96
8000e7fc:	00090363          	beqz	s2,8000e802 <.L144>
8000e800:	1b7d                	add	s6,s6,-1

8000e802 <.L144>:
8000e802:	5552                	lw	a0,52(sp)
8000e804:	894fb0ef          	jal	80009898 <abs>
8000e808:	06300793          	li	a5,99
8000e80c:	00a7d363          	bge	a5,a0,8000e812 <.L145>
8000e810:	1b7d                	add	s6,s6,-1

8000e812 <.L145>:
8000e812:	8522                	mv	a0,s0
8000e814:	8c0ff0ef          	jal	8000d8d4 <__fixunssfdi>
8000e818:	8bae                	mv	s7,a1
8000e81a:	8caa                	mv	s9,a0
8000e81c:	d7afa0ef          	jal	80008d96 <__floatundisf>
8000e820:	85aa                	mv	a1,a0
8000e822:	8522                	mv	a0,s0
8000e824:	9bcfa0ef          	jal	800089e0 <__subsf3>
8000e828:	842a                	mv	s0,a0

8000e82a <.L146>:
8000e82a:	895a                	mv	s2,s6
8000e82c:	000b5363          	bgez	s6,8000e832 <.L165>
8000e830:	4901                	li	s2,0

8000e832 <.L165>:
8000e832:	210c7793          	and	a5,s8,528
8000e836:	e399                	bnez	a5,8000e83c <.L167>

8000e838 <.L166>:
8000e838:	30091b63          	bnez	s2,8000eb4e <.L168>

8000e83c <.L167>:
8000e83c:	020c7713          	and	a4,s8,32
8000e840:	040c7793          	and	a5,s8,64
8000e844:	30070c63          	beqz	a4,8000eb5c <.L169>
8000e848:	02b00593          	li	a1,43
8000e84c:	c399                	beqz	a5,8000e852 <.L358>
8000e84e:	02d00593          	li	a1,45

8000e852 <.L358>:
8000e852:	854e                	mv	a0,s3
8000e854:	f50ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>

8000e858 <.L171>:
8000e858:	010c7793          	and	a5,s8,16
8000e85c:	e399                	bnez	a5,8000e862 <.L173>

8000e85e <.L172>:
8000e85e:	30091463          	bnez	s2,8000eb66 <.L174>

8000e862 <.L173>:
8000e862:	80003b37          	lui	s6,0x80003
8000e866:	070b0b13          	add	s6,s6,112 # 80003070 <__SEGGER_RTL_ipow10>

8000e86a <.L178>:
8000e86a:	1d7d                	add	s10,s10,-1
8000e86c:	003d1793          	sll	a5,s10,0x3
8000e870:	97da                	add	a5,a5,s6
8000e872:	4398                	lw	a4,0(a5)
8000e874:	43dc                	lw	a5,4(a5)
8000e876:	03000593          	li	a1,48

8000e87a <.L175>:
8000e87a:	00fbe663          	bltu	s7,a5,8000e886 <.L258>
8000e87e:	2f779b63          	bne	a5,s7,8000eb74 <.L176>
8000e882:	2eecf963          	bgeu	s9,a4,8000eb74 <.L176>

8000e886 <.L258>:
8000e886:	854e                	mv	a0,s3
8000e888:	f1cff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000e88c:	fc0d1fe3          	bnez	s10,8000e86a <.L178>
8000e890:	6b85                	lui	s7,0x1
8000e892:	800b8b93          	add	s7,s7,-2048 # 800 <.LBB2_28+0x6>
8000e896:	017c7bb3          	and	s7,s8,s7
8000e89a:	300b9163          	bnez	s7,8000eb9c <.L179>

8000e89e <.L183>:
8000e89e:	080c7793          	and	a5,s8,128
8000e8a2:	8fc5                	or	a5,a5,s1
8000e8a4:	c3a1                	beqz	a5,8000e8e4 <.L181>
8000e8a6:	02e00593          	li	a1,46
8000e8aa:	854e                	mv	a0,s3
8000e8ac:	ef8ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000e8b0:	47c1                	li	a5,16
8000e8b2:	8ca6                	mv	s9,s1
8000e8b4:	2e97d863          	bge	a5,s1,8000eba4 <.L186>
8000e8b8:	4cc1                	li	s9,16

8000e8ba <.L187>:
8000e8ba:	419484b3          	sub	s1,s1,s9
8000e8be:	8566                	mv	a0,s9
8000e8c0:	000b8563          	beqz	s7,8000e8ca <.L359>
8000e8c4:	5552                	lw	a0,52(sp)
8000e8c6:	40ac8533          	sub	a0,s9,a0

8000e8ca <.L359>:
8000e8ca:	97cfb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e8ce:	85a2                	mv	a1,s0
8000e8d0:	b55fe0ef          	jal	8000d424 <__mulsf3>
8000e8d4:	800ff0ef          	jal	8000d8d4 <__fixunssfdi>
8000e8d8:	8baa                	mv	s7,a0
8000e8da:	842e                	mv	s0,a1

8000e8dc <.L193>:
8000e8dc:	2c0c9863          	bnez	s9,8000ebac <.L194>

8000e8e0 <.L195>:
8000e8e0:	30049363          	bnez	s1,8000ebe6 <.L196>

8000e8e4 <.L181>:
8000e8e4:	400c7793          	and	a5,s8,1024
8000e8e8:	30079663          	bnez	a5,8000ebf4 <.L184>

8000e8ec <.L201>:
8000e8ec:	a0090be3          	beqz	s2,8000e302 <.L4>
8000e8f0:	197d                	add	s2,s2,-1
8000e8f2:	02000593          	li	a1,32
8000e8f6:	a6b5                	j	8000ec62 <.L360>

8000e8f8 <.L108>:
8000e8f8:	57d2                	lw	a5,52(sp)
8000e8fa:	0785                	add	a5,a5,1
8000e8fc:	da3e                	sw	a5,52(sp)

8000e8fe <.L105>:
8000e8fe:	5552                	lw	a0,52(sp)
8000e900:	0505                	add	a0,a0,1 # 1001 <__fw_size__+0x1>
8000e902:	944fb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e906:	85aa                	mv	a1,a0
8000e908:	855e                	mv	a0,s7
8000e90a:	afcfa0ef          	jal	80008c06 <__gtsf2>
8000e90e:	fea045e3          	bgtz	a0,8000e8f8 <.L108>

8000e912 <.L109>:
8000e912:	5552                	lw	a0,52(sp)
8000e914:	932fb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e918:	85aa                	mv	a1,a0
8000e91a:	855e                	mv	a0,s7
8000e91c:	a7afa0ef          	jal	80008b96 <__ltsf2>
8000e920:	d80557e3          	bgez	a0,8000e6ae <.L111>
8000e924:	57d2                	lw	a5,52(sp)
8000e926:	17fd                	add	a5,a5,-1
8000e928:	da3e                	sw	a5,52(sp)
8000e92a:	b7e5                	j	8000e912 <.L109>

8000e92c <.L340>:
8000e92c:	00fc1763          	bne	s8,a5,8000e93a <.L112>
8000e930:	d89559e3          	bge	a0,s1,8000e6c2 <.L106>
8000e934:	57f1                	li	a5,-4
8000e936:	0cf54163          	blt	a0,a5,8000e9f8 <.L113>

8000e93a <.L112>:
8000e93a:	08097793          	and	a5,s2,128
8000e93e:	c63e                	sw	a5,12(sp)
8000e940:	40097793          	and	a5,s2,1024
8000e944:	c789                	beqz	a5,8000e94e <.L147>
8000e946:	47b9                	li	a5,14
8000e948:	18a7d463          	bge	a5,a0,8000ead0 <.L148>

8000e94c <.L153>:
8000e94c:	4481                	li	s1,0

8000e94e <.L147>:
8000e94e:	57d2                	lw	a5,52(sp)
8000e950:	40900533          	neg	a0,s1
8000e954:	bff97c13          	and	s8,s2,-1025
8000e958:	ff178713          	add	a4,a5,-15
8000e95c:	00e55463          	bge	a0,a4,8000e964 <.L154>
8000e960:	ff078513          	add	a0,a5,-16

8000e964 <.L154>:
8000e964:	8e2fb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e968:	55fd                	li	a1,-1
8000e96a:	83aff0ef          	jal	8000d9a4 <ldexpf>
8000e96e:	85aa                	mv	a1,a0
8000e970:	855e                	mv	a0,s7
8000e972:	876fa0ef          	jal	800089e8 <__addsf3>
8000e976:	8d2a                	mv	s10,a0
8000e978:	842a                	mv	s0,a0
8000e97a:	5552                	lw	a0,52(sp)
8000e97c:	0505                	add	a0,a0,1
8000e97e:	8c8fb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e982:	85ea                	mv	a1,s10
8000e984:	a4cfa0ef          	jal	80008bd0 <__lesf2>
8000e988:	00a04563          	bgtz	a0,8000e992 <.L156>
8000e98c:	57d2                	lw	a5,52(sp)
8000e98e:	0785                	add	a5,a5,1
8000e990:	da3e                	sw	a5,52(sp)

8000e992 <.L156>:
8000e992:	57d2                	lw	a5,52(sp)
8000e994:	1a07c763          	bltz	a5,8000eb42 <.L158>
8000e998:	4541                	li	a0,16
8000e99a:	18f55663          	bge	a0,a5,8000eb26 <.L159>
8000e99e:	ff078713          	add	a4,a5,-16
8000e9a2:	8d1d                	sub	a0,a0,a5
8000e9a4:	da3a                	sw	a4,52(sp)
8000e9a6:	8a0fb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000e9aa:	85ea                	mv	a1,s10
8000e9ac:	a79fe0ef          	jal	8000d424 <__mulsf3>
8000e9b0:	f25fe0ef          	jal	8000d8d4 <__fixunssfdi>
8000e9b4:	8caa                	mv	s9,a0
8000e9b6:	8bae                	mv	s7,a1
8000e9b8:	00000413          	li	s0,0

8000e9bc <.L160>:
8000e9bc:	800037b7          	lui	a5,0x80003
8000e9c0:	07078793          	add	a5,a5,112 # 80003070 <__SEGGER_RTL_ipow10>
8000e9c4:	4d05                	li	s10,1

8000e9c6 <.L161>:
8000e9c6:	47d8                	lw	a4,12(a5)
8000e9c8:	07a1                	add	a5,a5,8
8000e9ca:	00ebe763          	bltu	s7,a4,8000e9d8 <.L257>
8000e9ce:	17771e63          	bne	a4,s7,8000eb4a <.L162>
8000e9d2:	4398                	lw	a4,0(a5)
8000e9d4:	16ecfb63          	bgeu	s9,a4,8000eb4a <.L162>

8000e9d8 <.L257>:
8000e9d8:	5752                	lw	a4,52(sp)
8000e9da:	009d07b3          	add	a5,s10,s1
8000e9de:	97ba                	add	a5,a5,a4
8000e9e0:	40fb0b33          	sub	s6,s6,a5
8000e9e4:	47b2                	lw	a5,12(sp)
8000e9e6:	8fc5                	or	a5,a5,s1
8000e9e8:	c391                	beqz	a5,8000e9ec <.L164>
8000e9ea:	1b7d                	add	s6,s6,-1

8000e9ec <.L164>:
8000e9ec:	06097793          	and	a5,s2,96
8000e9f0:	e2078de3          	beqz	a5,8000e82a <.L146>
8000e9f4:	1b7d                	add	s6,s6,-1
8000e9f6:	bd15                	j	8000e82a <.L146>

8000e9f8 <.L113>:
8000e9f8:	40a00533          	neg	a0,a0
8000e9fc:	84afb0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000ea00:	85aa                	mv	a1,a0
8000ea02:	855e                	mv	a0,s7
8000ea04:	a21fe0ef          	jal	8000d424 <__mulsf3>
8000ea08:	b9c1                	j	8000e6d8 <.L354>

8000ea0a <.L244>:
8000ea0a:	80005437          	lui	s0,0x80005
8000ea0e:	4fc40413          	add	s0,s0,1276 # 800054fc <.LC2>
8000ea12:	b189                	j	8000e654 <.L122>

8000ea14 <.L341>:
8000ea14:	c819                	beqz	s0,8000ea2a <.L245>
8000ea16:	80005437          	lui	s0,0x80005
8000ea1a:	50440413          	add	s0,s0,1284 # 80005504 <.LC3>

8000ea1e <.L123>:
8000ea1e:	02097793          	and	a5,s2,32
8000ea22:	c20799e3          	bnez	a5,8000e654 <.L122>
8000ea26:	0405                	add	s0,s0,1
8000ea28:	b135                	j	8000e654 <.L122>

8000ea2a <.L245>:
8000ea2a:	80005437          	lui	s0,0x80005
8000ea2e:	50c40413          	add	s0,s0,1292 # 8000550c <.LC4>
8000ea32:	b7f5                	j	8000ea1e <.L123>

8000ea34 <.L124>:
8000ea34:	800057b7          	lui	a5,0x80005
8000ea38:	6f07a583          	lw	a1,1776(a5) # 800056f0 <.Lmerged_single+0x8>
8000ea3c:	855e                	mv	a0,s7
8000ea3e:	ba7fe0ef          	jal	8000d5e4 <__divsf3>
8000ea42:	8baa                	mv	s7,a0
8000ea44:	87ea                	mv	a5,s10
8000ea46:	4705                	li	a4,1
8000ea48:	b175                	j	8000e6f4 <.L118>

8000ea4a <.L127>:
8000ea4a:	853e                	mv	a0,a5
8000ea4c:	85e6                	mv	a1,s9
8000ea4e:	9d7fe0ef          	jal	8000d424 <__mulsf3>
8000ea52:	87aa                	mv	a5,a0
8000ea54:	8d5e                	mv	s10,s7
8000ea56:	4685                	li	a3,1
8000ea58:	b9e1                	j	8000e730 <.L126>

8000ea5a <.L132>:
8000ea5a:	6785                	lui	a5,0x1
8000ea5c:	88078793          	add	a5,a5,-1920 # 880 <.LBB2_41+0x10>
8000ea60:	00f977b3          	and	a5,s2,a5
8000ea64:	80078793          	add	a5,a5,-2048
8000ea68:	d2079be3          	bnez	a5,8000e79e <.L133>
8000ea6c:	47c1                	li	a5,16
8000ea6e:	0097d363          	bge	a5,s1,8000ea74 <.L134>
8000ea72:	44c1                	li	s1,16

8000ea74 <.L134>:
8000ea74:	8526                	mv	a0,s1
8000ea76:	fd1fa0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000ea7a:	85a2                	mv	a1,s0
8000ea7c:	9a9fe0ef          	jal	8000d424 <__mulsf3>
8000ea80:	e55fe0ef          	jal	8000d8d4 <__fixunssfdi>
8000ea84:	00a5e7b3          	or	a5,a1,a0
8000ea88:	8c2a                	mv	s8,a0
8000ea8a:	8d2e                	mv	s10,a1
8000ea8c:	d00788e3          	beqz	a5,8000e79c <.L135>

8000ea90 <.L357>:
8000ea90:	4629                	li	a2,10
8000ea92:	4681                	li	a3,0
8000ea94:	98ffa0ef          	jal	80009422 <__umoddi3>
8000ea98:	8d4d                	or	a0,a0,a1
8000ea9a:	d00512e3          	bnez	a0,8000e79e <.L133>
8000ea9e:	8562                	mv	a0,s8
8000eaa0:	85ea                	mv	a1,s10
8000eaa2:	4629                	li	a2,10
8000eaa4:	4681                	li	a3,0
8000eaa6:	d5cfa0ef          	jal	80009002 <__udivdi3>
8000eaaa:	14fd                	add	s1,s1,-1
8000eaac:	8c2a                	mv	s8,a0
8000eaae:	8d2e                	mv	s10,a1
8000eab0:	f0e5                	bnez	s1,8000ea90 <.L357>
8000eab2:	b1ed                	j	8000e79c <.L135>

8000eab4 <.L142>:
8000eab4:	80005737          	lui	a4,0x80005
8000eab8:	6f472583          	lw	a1,1780(a4) # 800056f4 <.Lmerged_single+0xc>
8000eabc:	4532                	lw	a0,12(sp)
8000eabe:	1b79                	add	s6,s6,-2
8000eac0:	4d0d                	li	s10,3
8000eac2:	963fe0ef          	jal	8000d424 <__mulsf3>
8000eac6:	ffeb8793          	add	a5,s7,-2
8000eaca:	842a                	mv	s0,a0
8000eacc:	da3e                	sw	a5,52(sp)
8000eace:	b315                	j	8000e7f2 <.L141>

8000ead0 <.L148>:
8000ead0:	0505                	add	a0,a0,1
8000ead2:	8c89                	sub	s1,s1,a0
8000ead4:	47c1                	li	a5,16
8000ead6:	0097d363          	bge	a5,s1,8000eadc <.L149>
8000eada:	44c1                	li	s1,16

8000eadc <.L149>:
8000eadc:	08097793          	and	a5,s2,128
8000eae0:	e60797e3          	bnez	a5,8000e94e <.L147>
8000eae4:	800057b7          	lui	a5,0x80005
8000eae8:	6e87ac03          	lw	s8,1768(a5) # 800056e8 <.Lmerged_single>
8000eaec:	800057b7          	lui	a5,0x80005
8000eaf0:	6f07a403          	lw	s0,1776(a5) # 800056f0 <.Lmerged_single+0x8>

8000eaf4 <.L150>:
8000eaf4:	e4048ce3          	beqz	s1,8000e94c <.L153>
8000eaf8:	8526                	mv	a0,s1
8000eafa:	f4dfa0ef          	jal	80009a46 <__SEGGER_RTL_pow10f>
8000eafe:	85aa                	mv	a1,a0
8000eb00:	855e                	mv	a0,s7
8000eb02:	923fe0ef          	jal	8000d424 <__mulsf3>
8000eb06:	85e2                	mv	a1,s8
8000eb08:	ee1f90ef          	jal	800089e8 <__addsf3>
8000eb0c:	c66fa0ef          	jal	80008f72 <floorf>
8000eb10:	85a2                	mv	a1,s0
8000eb12:	f03fe0ef          	jal	8000da14 <fmodf>
8000eb16:	00000593          	li	a1,0
8000eb1a:	d8ffe0ef          	jal	8000d8a8 <__eqsf2>
8000eb1e:	e20518e3          	bnez	a0,8000e94e <.L147>
8000eb22:	14fd                	add	s1,s1,-1
8000eb24:	bfc1                	j	8000eaf4 <.L150>

8000eb26 <.L159>:
8000eb26:	856a                	mv	a0,s10
8000eb28:	da02                	sw	zero,52(sp)
8000eb2a:	dabfe0ef          	jal	8000d8d4 <__fixunssfdi>
8000eb2e:	8bae                	mv	s7,a1
8000eb30:	8caa                	mv	s9,a0
8000eb32:	a64fa0ef          	jal	80008d96 <__floatundisf>
8000eb36:	85aa                	mv	a1,a0
8000eb38:	856a                	mv	a0,s10
8000eb3a:	ea7f90ef          	jal	800089e0 <__subsf3>
8000eb3e:	842a                	mv	s0,a0
8000eb40:	bdb5                	j	8000e9bc <.L160>

8000eb42 <.L158>:
8000eb42:	da02                	sw	zero,52(sp)
8000eb44:	4c81                	li	s9,0
8000eb46:	4b81                	li	s7,0
8000eb48:	bd95                	j	8000e9bc <.L160>

8000eb4a <.L162>:
8000eb4a:	0d05                	add	s10,s10,1
8000eb4c:	bdad                	j	8000e9c6 <.L161>

8000eb4e <.L168>:
8000eb4e:	02000593          	li	a1,32
8000eb52:	854e                	mv	a0,s3
8000eb54:	197d                	add	s2,s2,-1
8000eb56:	c4eff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000eb5a:	b9f9                	j	8000e838 <.L166>

8000eb5c <.L169>:
8000eb5c:	ce078ee3          	beqz	a5,8000e858 <.L171>
8000eb60:	02000593          	li	a1,32
8000eb64:	b1fd                	j	8000e852 <.L358>

8000eb66 <.L174>:
8000eb66:	03000593          	li	a1,48
8000eb6a:	854e                	mv	a0,s3
8000eb6c:	197d                	add	s2,s2,-1
8000eb6e:	c36ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000eb72:	b1f5                	j	8000e85e <.L172>

8000eb74 <.L176>:
8000eb74:	40ec86b3          	sub	a3,s9,a4
8000eb78:	00dcb633          	sltu	a2,s9,a3
8000eb7c:	0585                	add	a1,a1,1
8000eb7e:	40fb8bb3          	sub	s7,s7,a5
8000eb82:	0ff5f593          	zext.b	a1,a1
8000eb86:	8cb6                	mv	s9,a3
8000eb88:	40cb8bb3          	sub	s7,s7,a2
8000eb8c:	b1fd                	j	8000e87a <.L175>

8000eb8e <.L182>:
8000eb8e:	17fd                	add	a5,a5,-1
8000eb90:	03000593          	li	a1,48
8000eb94:	854e                	mv	a0,s3
8000eb96:	da3e                	sw	a5,52(sp)
8000eb98:	c0cff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>

8000eb9c <.L179>:
8000eb9c:	57d2                	lw	a5,52(sp)
8000eb9e:	fef048e3          	bgtz	a5,8000eb8e <.L182>
8000eba2:	b9f5                	j	8000e89e <.L183>

8000eba4 <.L186>:
8000eba4:	d004dbe3          	bgez	s1,8000e8ba <.L187>
8000eba8:	4c81                	li	s9,0
8000ebaa:	bb01                	j	8000e8ba <.L187>

8000ebac <.L194>:
8000ebac:	1cfd                	add	s9,s9,-1
8000ebae:	003c9793          	sll	a5,s9,0x3
8000ebb2:	97da                	add	a5,a5,s6
8000ebb4:	4398                	lw	a4,0(a5)
8000ebb6:	43dc                	lw	a5,4(a5)
8000ebb8:	03000593          	li	a1,48

8000ebbc <.L190>:
8000ebbc:	00f46663          	bltu	s0,a5,8000ebc8 <.L259>
8000ebc0:	00879863          	bne	a5,s0,8000ebd0 <.L191>
8000ebc4:	00ebf663          	bgeu	s7,a4,8000ebd0 <.L191>

8000ebc8 <.L259>:
8000ebc8:	854e                	mv	a0,s3
8000ebca:	bdaff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ebce:	b339                	j	8000e8dc <.L193>

8000ebd0 <.L191>:
8000ebd0:	40eb86b3          	sub	a3,s7,a4
8000ebd4:	00dbb633          	sltu	a2,s7,a3
8000ebd8:	0585                	add	a1,a1,1
8000ebda:	8c1d                	sub	s0,s0,a5
8000ebdc:	0ff5f593          	zext.b	a1,a1
8000ebe0:	8bb6                	mv	s7,a3
8000ebe2:	8c11                	sub	s0,s0,a2
8000ebe4:	bfe1                	j	8000ebbc <.L190>

8000ebe6 <.L196>:
8000ebe6:	03000593          	li	a1,48
8000ebea:	854e                	mv	a0,s3
8000ebec:	14fd                	add	s1,s1,-1
8000ebee:	bb6ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ebf2:	b1fd                	j	8000e8e0 <.L195>

8000ebf4 <.L184>:
8000ebf4:	012c1793          	sll	a5,s8,0x12
8000ebf8:	06500593          	li	a1,101
8000ebfc:	0007d463          	bgez	a5,8000ec04 <.L197>
8000ec00:	04500593          	li	a1,69

8000ec04 <.L197>:
8000ec04:	854e                	mv	a0,s3
8000ec06:	b9eff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ec0a:	57d2                	lw	a5,52(sp)
8000ec0c:	0407df63          	bgez	a5,8000ec6a <.L198>
8000ec10:	02d00593          	li	a1,45
8000ec14:	854e                	mv	a0,s3
8000ec16:	b8eff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ec1a:	57d2                	lw	a5,52(sp)
8000ec1c:	40f007b3          	neg	a5,a5
8000ec20:	da3e                	sw	a5,52(sp)

8000ec22 <.L199>:
8000ec22:	55d2                	lw	a1,52(sp)
8000ec24:	06300793          	li	a5,99
8000ec28:	00b7df63          	bge	a5,a1,8000ec46 <.L200>
8000ec2c:	06400413          	li	s0,100
8000ec30:	0285c5b3          	div	a1,a1,s0
8000ec34:	854e                	mv	a0,s3
8000ec36:	03058593          	add	a1,a1,48
8000ec3a:	b6aff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ec3e:	57d2                	lw	a5,52(sp)
8000ec40:	0287e7b3          	rem	a5,a5,s0
8000ec44:	da3e                	sw	a5,52(sp)

8000ec46 <.L200>:
8000ec46:	55d2                	lw	a1,52(sp)
8000ec48:	4429                	li	s0,10
8000ec4a:	854e                	mv	a0,s3
8000ec4c:	0285c5b3          	div	a1,a1,s0
8000ec50:	03058593          	add	a1,a1,48
8000ec54:	b50ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ec58:	55d2                	lw	a1,52(sp)
8000ec5a:	0285e5b3          	rem	a1,a1,s0
8000ec5e:	03058593          	add	a1,a1,48

8000ec62 <.L360>:
8000ec62:	854e                	mv	a0,s3
8000ec64:	b40ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ec68:	b151                	j	8000e8ec <.L201>

8000ec6a <.L198>:
8000ec6a:	02b00593          	li	a1,43
8000ec6e:	854e                	mv	a0,s3
8000ec70:	b34ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ec74:	b77d                	j	8000ec22 <.L199>

8000ec76 <.L205>:
8000ec76:	6d21                	lui	s10,0x8
8000ec78:	892e                	mv	s2,a1
8000ec7a:	4c01                	li	s8,0
8000ec7c:	01abfd33          	and	s10,s7,s10
8000ec80:	470d                	li	a4,3
8000ec82:	02c00813          	li	a6,44

8000ec86 <.L208>:
8000ec86:	012467b3          	or	a5,s0,s2
8000ec8a:	cbb5                	beqz	a5,8000ecfe <.L206>
8000ec8c:	000d0d63          	beqz	s10,8000eca6 <.L214>
8000ec90:	003c7793          	and	a5,s8,3
8000ec94:	00e79963          	bne	a5,a4,8000eca6 <.L214>
8000ec98:	030c0793          	add	a5,s8,48
8000ec9c:	1018                	add	a4,sp,32
8000ec9e:	97ba                	add	a5,a5,a4
8000eca0:	ff078423          	sb	a6,-24(a5)
8000eca4:	0c05                	add	s8,s8,1

8000eca6 <.L214>:
8000eca6:	1018                	add	a4,sp,32
8000eca8:	030c0793          	add	a5,s8,48
8000ecac:	97ba                	add	a5,a5,a4
8000ecae:	4629                	li	a2,10
8000ecb0:	4681                	li	a3,0
8000ecb2:	8522                	mv	a0,s0
8000ecb4:	85ca                	mv	a1,s2
8000ecb6:	c63e                	sw	a5,12(sp)
8000ecb8:	f6afa0ef          	jal	80009422 <__umoddi3>
8000ecbc:	47b2                	lw	a5,12(sp)
8000ecbe:	03050513          	add	a0,a0,48
8000ecc2:	85ca                	mv	a1,s2
8000ecc4:	fea78423          	sb	a0,-24(a5)
8000ecc8:	4629                	li	a2,10
8000ecca:	8522                	mv	a0,s0
8000eccc:	4681                	li	a3,0
8000ecce:	b34fa0ef          	jal	80009002 <__udivdi3>
8000ecd2:	0c05                	add	s8,s8,1
8000ecd4:	842a                	mv	s0,a0
8000ecd6:	892e                	mv	s2,a1
8000ecd8:	02c00813          	li	a6,44
8000ecdc:	470d                	li	a4,3
8000ecde:	b765                	j	8000ec86 <.L208>

8000ece0 <.L204>:
8000ece0:	6709                	lui	a4,0x2
8000ece2:	800056b7          	lui	a3,0x80005
8000ece6:	80005637          	lui	a2,0x80005
8000ecea:	4c01                	li	s8,0
8000ecec:	00ebf733          	and	a4,s7,a4
8000ecf0:	4cc68693          	add	a3,a3,1228 # 800054cc <__SEGGER_RTL_hex_lc>
8000ecf4:	4dc60613          	add	a2,a2,1244 # 800054dc <__SEGGER_RTL_hex_uc>

8000ecf8 <.L209>:
8000ecf8:	00b467b3          	or	a5,s0,a1
8000ecfc:	e38d                	bnez	a5,8000ed1e <.L212>

8000ecfe <.L206>:
8000ecfe:	418484b3          	sub	s1,s1,s8
8000ed02:	0004d363          	bgez	s1,8000ed08 <.L216>
8000ed06:	4481                	li	s1,0

8000ed08 <.L216>:
8000ed08:	409b0b33          	sub	s6,s6,s1
8000ed0c:	0ff00793          	li	a5,255
8000ed10:	418b0b33          	sub	s6,s6,s8
8000ed14:	0397f863          	bgeu	a5,s9,8000ed44 <.L217>
8000ed18:	1b7d                	add	s6,s6,-1

8000ed1a <.L218>:
8000ed1a:	1b7d                	add	s6,s6,-1
8000ed1c:	a035                	j	8000ed48 <.L219>

8000ed1e <.L212>:
8000ed1e:	00f47793          	and	a5,s0,15
8000ed22:	cf19                	beqz	a4,8000ed40 <.L210>
8000ed24:	97b2                	add	a5,a5,a2

8000ed26 <.L361>:
8000ed26:	0007c783          	lbu	a5,0(a5)
8000ed2a:	1828                	add	a0,sp,56
8000ed2c:	9562                	add	a0,a0,s8
8000ed2e:	00f50023          	sb	a5,0(a0)
8000ed32:	8011                	srl	s0,s0,0x4
8000ed34:	01c59793          	sll	a5,a1,0x1c
8000ed38:	0c05                	add	s8,s8,1
8000ed3a:	8c5d                	or	s0,s0,a5
8000ed3c:	8191                	srl	a1,a1,0x4
8000ed3e:	bf6d                	j	8000ecf8 <.L209>

8000ed40 <.L210>:
8000ed40:	97b6                	add	a5,a5,a3
8000ed42:	b7d5                	j	8000ed26 <.L361>

8000ed44 <.L217>:
8000ed44:	fc0c9be3          	bnez	s9,8000ed1a <.L218>

8000ed48 <.L219>:
8000ed48:	200bf793          	and	a5,s7,512
8000ed4c:	e799                	bnez	a5,8000ed5a <.L220>
8000ed4e:	865a                	mv	a2,s6
8000ed50:	85de                	mv	a1,s7
8000ed52:	854e                	mv	a0,s3
8000ed54:	d6ffa0ef          	jal	80009ac2 <__SEGGER_RTL_pre_padding>
8000ed58:	4b01                	li	s6,0

8000ed5a <.L220>:
8000ed5a:	0ff00793          	li	a5,255
8000ed5e:	0197fc63          	bgeu	a5,s9,8000ed76 <.L221>
8000ed62:	03000593          	li	a1,48
8000ed66:	854e                	mv	a0,s3
8000ed68:	a3cff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>

8000ed6c <.L222>:
8000ed6c:	85e6                	mv	a1,s9
8000ed6e:	854e                	mv	a0,s3
8000ed70:	a34ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000ed74:	a019                	j	8000ed7a <.L223>

8000ed76 <.L221>:
8000ed76:	fe0c9be3          	bnez	s9,8000ed6c <.L222>

8000ed7a <.L223>:
8000ed7a:	865a                	mv	a2,s6
8000ed7c:	85de                	mv	a1,s7
8000ed7e:	854e                	mv	a0,s3
8000ed80:	d43fa0ef          	jal	80009ac2 <__SEGGER_RTL_pre_padding>
8000ed84:	8626                	mv	a2,s1
8000ed86:	03000593          	li	a1,48
8000ed8a:	854e                	mv	a0,s3
8000ed8c:	ab4ff0ef          	jal	8000e040 <__SEGGER_RTL_print_padding>

8000ed90 <.L224>:
8000ed90:	1c7d                	add	s8,s8,-1
8000ed92:	e00c4763          	bltz	s8,8000e3a0 <.L371>
8000ed96:	183c                	add	a5,sp,56
8000ed98:	97e2                	add	a5,a5,s8
8000ed9a:	0007c583          	lbu	a1,0(a5)
8000ed9e:	854e                	mv	a0,s3
8000eda0:	a04ff0ef          	jal	8000dfa4 <__SEGGER_RTL_putc>
8000eda4:	b7f5                	j	8000ed90 <.L224>

8000eda6 <.L34>:
8000eda6:	07800713          	li	a4,120
8000edaa:	d4f76c63          	bltu	a4,a5,8000e302 <.L4>

8000edae <.L38>:
8000edae:	fa878713          	add	a4,a5,-88
8000edb2:	0ff77713          	zext.b	a4,a4
8000edb6:	02000693          	li	a3,32
8000edba:	d4e6e463          	bltu	a3,a4,8000e302 <.L4>
8000edbe:	46d2                	lw	a3,20(sp)
8000edc0:	070a                	sll	a4,a4,0x2
8000edc2:	9736                	add	a4,a4,a3
8000edc4:	4318                	lw	a4,0(a4)
8000edc6:	8702                	jr	a4

Disassembly of section .text.libc.__SEGGER_RTL_ascii_isctype:

8000edc8 <__SEGGER_RTL_ascii_isctype>:
8000edc8:	07f00793          	li	a5,127
8000edcc:	02a7e263          	bltu	a5,a0,8000edf0 <.L3>
8000edd0:	800057b7          	lui	a5,0x80005
8000edd4:	66878793          	add	a5,a5,1640 # 80005668 <__SEGGER_RTL_ascii_ctype_map>
8000edd8:	953e                	add	a0,a0,a5
8000edda:	800067b7          	lui	a5,0x80006
8000edde:	94478793          	add	a5,a5,-1724 # 80005944 <__SEGGER_RTL_ascii_ctype_mask>
8000ede2:	95be                	add	a1,a1,a5
8000ede4:	00054503          	lbu	a0,0(a0)
8000ede8:	0005c783          	lbu	a5,0(a1)
8000edec:	8d7d                	and	a0,a0,a5
8000edee:	8082                	ret

8000edf0 <.L3>:
8000edf0:	4501                	li	a0,0
8000edf2:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_tolower:

8000edf4 <__SEGGER_RTL_ascii_tolower>:
8000edf4:	fbf50713          	add	a4,a0,-65
8000edf8:	47e5                	li	a5,25
8000edfa:	00e7e463          	bltu	a5,a4,8000ee02 <.L7>
8000edfe:	02050513          	add	a0,a0,32

8000ee02 <.L7>:
8000ee02:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_iswctype:

8000ee04 <__SEGGER_RTL_ascii_iswctype>:
8000ee04:	07f00793          	li	a5,127
8000ee08:	02a7e263          	bltu	a5,a0,8000ee2c <.L10>
8000ee0c:	800057b7          	lui	a5,0x80005
8000ee10:	66878793          	add	a5,a5,1640 # 80005668 <__SEGGER_RTL_ascii_ctype_map>
8000ee14:	953e                	add	a0,a0,a5
8000ee16:	800067b7          	lui	a5,0x80006
8000ee1a:	94478793          	add	a5,a5,-1724 # 80005944 <__SEGGER_RTL_ascii_ctype_mask>
8000ee1e:	95be                	add	a1,a1,a5
8000ee20:	00054503          	lbu	a0,0(a0)
8000ee24:	0005c783          	lbu	a5,0(a1)
8000ee28:	8d7d                	and	a0,a0,a5
8000ee2a:	8082                	ret

8000ee2c <.L10>:
8000ee2c:	4501                	li	a0,0
8000ee2e:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_towlower:

8000ee30 <__SEGGER_RTL_ascii_towlower>:
8000ee30:	fbf50713          	add	a4,a0,-65
8000ee34:	47e5                	li	a5,25
8000ee36:	00e7e463          	bltu	a5,a4,8000ee3e <.L14>
8000ee3a:	02050513          	add	a0,a0,32

8000ee3e <.L14>:
8000ee3e:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_ascii_wctomb:

8000ee40 <__SEGGER_RTL_ascii_wctomb>:
8000ee40:	07f00793          	li	a5,127
8000ee44:	00b7e663          	bltu	a5,a1,8000ee50 <.L66>
8000ee48:	00b50023          	sb	a1,0(a0)
8000ee4c:	4505                	li	a0,1
8000ee4e:	8082                	ret

8000ee50 <.L66>:
8000ee50:	5579                	li	a0,-2
8000ee52:	8082                	ret

Disassembly of section .text.libc.__SEGGER_RTL_current_locale:

8000ee54 <__SEGGER_RTL_current_locale>:
8000ee54:	6941a503          	lw	a0,1684(gp) # 81a04 <__SEGGER_RTL_locale_ptr>
8000ee58:	e509                	bnez	a0,8000ee62 <.L155>
8000ee5a:	00080537          	lui	a0,0x80
8000ee5e:	22450513          	add	a0,a0,548 # 80224 <__RAL_global_locale>

8000ee62 <.L155>:
8000ee62:	8082                	ret

Disassembly of section .segger.init.__SEGGER_init_lzss:

80018ebc <__SEGGER_init_lzss>:
80018ebc:	4008                	lw	a0,0(s0)
80018ebe:	404c                	lw	a1,4(s0)
80018ec0:	0421                	add	s0,s0,8
80018ec2:	08000793          	li	a5,128

80018ec6 <.L__SEGGER_init_lzss_NextByte>:
80018ec6:	0005c603          	lbu	a2,0(a1)
80018eca:	0585                	add	a1,a1,1
80018ecc:	c631                	beqz	a2,80018f18 <.L__SEGGER_init_lzss_Done>
80018ece:	02f66c63          	bltu	a2,a5,80018f06 <.L__SEGGER_init_lzss_LoopLiteral>
80018ed2:	f8060613          	add	a2,a2,-128
80018ed6:	c231                	beqz	a2,80018f1a <.L__SEGGER_init_lzss_Error>
80018ed8:	0005c683          	lbu	a3,0(a1)
80018edc:	0585                	add	a1,a1,1
80018ede:	00f6e963          	bltu	a3,a5,80018ef0 <.L__SEGGER_init_lzss_ShortRun>
80018ee2:	f8068693          	add	a3,a3,-128
80018ee6:	06a2                	sll	a3,a3,0x8
80018ee8:	0005c703          	lbu	a4,0(a1)
80018eec:	0585                	add	a1,a1,1
80018eee:	96ba                	add	a3,a3,a4

80018ef0 <.L__SEGGER_init_lzss_ShortRun>:
80018ef0:	40d50733          	sub	a4,a0,a3

80018ef4 <.L__SEGGER_init_lzss_LoopShort>:
80018ef4:	00074683          	lbu	a3,0(a4) # 2000 <__BOOT_HEADER_segment_size__>
80018ef8:	00d50023          	sb	a3,0(a0)
80018efc:	0705                	add	a4,a4,1
80018efe:	0505                	add	a0,a0,1
80018f00:	167d                	add	a2,a2,-1
80018f02:	fa6d                	bnez	a2,80018ef4 <.L__SEGGER_init_lzss_LoopShort>
80018f04:	b7c9                	j	80018ec6 <.L__SEGGER_init_lzss_NextByte>

80018f06 <.L__SEGGER_init_lzss_LoopLiteral>:
80018f06:	0005c683          	lbu	a3,0(a1)
80018f0a:	0585                	add	a1,a1,1
80018f0c:	00d50023          	sb	a3,0(a0)
80018f10:	0505                	add	a0,a0,1
80018f12:	167d                	add	a2,a2,-1
80018f14:	fa6d                	bnez	a2,80018f06 <.L__SEGGER_init_lzss_LoopLiteral>
80018f16:	bf45                	j	80018ec6 <.L__SEGGER_init_lzss_NextByte>

80018f18 <.L__SEGGER_init_lzss_Done>:
80018f18:	8082                	ret

80018f1a <.L__SEGGER_init_lzss_Error>:
80018f1a:	a001                	j	80018f1a <.L__SEGGER_init_lzss_Error>

Disassembly of section .segger.init.__SEGGER_init_zero:

80018f1c <__SEGGER_init_zero>:
80018f1c:	4008                	lw	a0,0(s0)
80018f1e:	404c                	lw	a1,4(s0)
80018f20:	0421                	add	s0,s0,8
80018f22:	c591                	beqz	a1,80018f2e <.L__SEGGER_init_zero_Done>

80018f24 <.L__SEGGER_init_zero_Loop>:
80018f24:	00050023          	sb	zero,0(a0)
80018f28:	0505                	add	a0,a0,1
80018f2a:	15fd                	add	a1,a1,-1
80018f2c:	fde5                	bnez	a1,80018f24 <.L__SEGGER_init_zero_Loop>

80018f2e <.L__SEGGER_init_zero_Done>:
80018f2e:	8082                	ret

Disassembly of section .segger.init.__SEGGER_init_copy:

80018f30 <__SEGGER_init_copy>:
80018f30:	4008                	lw	a0,0(s0)
80018f32:	404c                	lw	a1,4(s0)
80018f34:	4410                	lw	a2,8(s0)
80018f36:	0431                	add	s0,s0,12
80018f38:	ca09                	beqz	a2,80018f4a <.L__SEGGER_init_copy_Done>

80018f3a <.L__SEGGER_init_copy_Loop>:
80018f3a:	00058683          	lb	a3,0(a1)
80018f3e:	00d50023          	sb	a3,0(a0)
80018f42:	0505                	add	a0,a0,1
80018f44:	0585                	add	a1,a1,1
80018f46:	167d                	add	a2,a2,-1
80018f48:	fa6d                	bnez	a2,80018f3a <.L__SEGGER_init_copy_Loop>

80018f4a <.L__SEGGER_init_copy_Done>:
80018f4a:	8082                	ret
