#ifndef output_h
#define output_h

/***************************************************/
/*                                                 */
/* output.h-                                       */
/*                                                 */
/* Header file associated with HLA code generation */
/*                                                 */
/***************************************************/

#include "enums.h"
#include "symbol.h"

extern enum AsmChoice	assembler;
extern enum gasChoice	gasSyntax;
extern int 				OptimizeStrings;
extern int 				sourceOutput;


extern void asmPuts( char *s );
extern void asmComment( char *s );
extern void asmPutc( char c );
extern void asmCpy( char *s, int len );
extern int asmPrintf( char *fmtstr, ...);


enum fpregnums
{
	reg_st0,
	reg_st1,
	reg_st2,
	reg_st3,
	reg_st4,
	reg_st5,
	reg_st6,
	reg_st7,
	numFPregs
};							

enum mmxregnums
{
	reg_mm0,
	reg_mm1,
	reg_mm2,
	reg_mm3,
	reg_mm4,
	reg_mm5,
	reg_mm6,
	reg_mm7,
	numMMXregs
};

enum xmmregnums
{
	reg_xmm0,
	reg_xmm1,
	reg_xmm2,
	reg_xmm3,
	reg_xmm4,
	reg_xmm5,
	reg_xmm6,
	reg_xmm7,
	numXMMregs
};

enum ctrlregnums
{
	reg_cr0,
	reg_cr1,
	reg_cr2,
	reg_cr3,
	reg_cr4,
	reg_cr5,
	reg_cr6,
	reg_cr7,
	numCTRLregs
};

enum dbgregnums
{
	reg_dr0,
	reg_dr1,
	reg_dr2,
	reg_dr3,
	reg_dr4,
	reg_dr5,
	reg_dr6,
	reg_dr7,
	numDBGregs
};

enum segregnums
{
	reg_eseg,
	reg_cseg,
	reg_sseg,
	reg_dseg,
	reg_fseg,
	reg_gseg,
	numSEGregs
};

#define isSegReg(r) ((r) < numSEGregs)


extern void cfasmMain
( 
	char *fName, 
	char *objName, 
	void *fileBuf, 
	int fileSize,
	int verbose 
);
	

extern int TrueLabel;
extern int FalseLabel;

extern int	need_raise;
extern int	need_HLA_PUSH_EXCEPTIONPTR;	
extern int	need_HLA_SET_EXCEPTIONPTR;	
extern int	need_HLA_GET_EXCEPTIONPTREBP;
extern int	need_ExceptionPtr;


extern int parsePtrExpr( char *expr );

extern void callUndefSym( char *undefSym );
extern void jmpTargetID( char *sym );
extern void jmpHere( int disp );
extern void callHere( int disp );
extern void condJumpHere( char *instr );	
extern void condJumpHere2( char *instr, union YYSTYPE *adrs );	
extern void EmitModRegRm( unsigned reg, struct adrsYYS *adrs, unsigned masmSwap );
extern void EmitShuffleOpcode( unsigned which );
extern void EmitXshiftOpcode( unsigned which );
extern void EmitXshiftImm
( 
	unsigned which, 
	unsigned reg 
);
extern char *rtnScale( struct adrsYYS *adrs );


extern void OutputMemParm
( 
	SymNode_t		*theProc,
	SymNode_t		*formal, 
	struct adrsYYS	*actual,
	int				valPrefix 
);

	
extern void EncodeAdrs
(
	struct adrsYYS	*adrs,
	unsigned 		*modRm,
	unsigned 		*hasSib,
	unsigned 		*sib,
	unsigned 		*dispType,
	int 			*disp,
	char 			*dispLabel,
	unsigned		masmSwap
);

extern void EncodeHLAAdrs
(
	struct adrsYYS	*adrs,
	unsigned 		*modRm,
	unsigned 		*hasSib,
	unsigned 		*sib,
	unsigned 		*dispType,
	int 			*disp,
	char 			*dispLabel
);

extern int CheckDisp( union YYSTYPE *disp );
extern void initAdrs
( 
	struct adrsYYS *adrs,
	int				baseReg, 
	int				indexReg,
	int				scale,
	int				disp
);

extern void initAdrs1
( 
	struct adrsYYS *adrs,
	int				baseReg, 
	int				disp
);

void initAdrs2
( 
	struct adrsYYS *adrs,
	char			*StaticName,
	int				baseReg, 
	int				indexReg,
	int				scale,
	int				disp
);


void initLbl( struct adrsYYS *adrs, char *lbl, int disp );


extern void mergeMem( struct memYYS *dest, struct memYYS *src );





// Internal codes for the implied instructions:

enum implied_instrs
{
	aaa_instr,
	aad_instr,
	aam_instr,
	aas_instr,
	cbw_instr,
	cdq_instr,
	clc_instr,
	cld_instr,
	cli_instr,
	clts_instr,
	cmc_instr,
	cpuid_instr,
	cwd_instr,
	cwde_instr,
	daa_instr,
	das_instr,
	hlt_instr,
	into_instr,
	invd_instr,
	iret_instr,
	iretd_instr,
	lahf_instr,
	leave_instr,
	nop_instr,
	popa_instr,
	popad_instr,
	popf_instr,
	popfd_instr,
	pusha_instr,
	pushad_instr,
	pushf_instr,
	pushfd_instr,
	rdmsr_instr,
	rdpmc_instr,
	rdtsc_instr,
	rsm_instr,
	sahf_instr,
	stc_instr,
	std_instr,
	sti_instr,
	wait_instr,
	wbinvd_instr,
	wrmsr_instr,
	xlat_instr,
	
	fxch_instr,
	fsqrt_instr,
	fscale_instr,
	fprem_instr,
	fprem1_instr,
	frndint_instr,
	fxtract_instr,
	fabs_instr,
	fchs_instr,
	fldl2e_instr,
	ftst_instr,
	fxam_instr,
	fldz_instr,
	fld1_instr,
	fldpi_instr,
	fldl2t_instr,
	fldlg2_instr,
	fldln2_instr,
	f2xm1_instr,
	fsin_instr,
	fcos_instr,
	fsincos_instr,
	fptan_instr,
	fpatan_instr,
	fyl2x_instr,
	fyl2xp1_instr,
	finit_instr,
	fninit_instr,
	fwait_instr,
	fclex_instr,
	fnclex_instr,
	fincstp_instr,
	fdecstp_instr,
	fnop_instr,
	
	_fcom_instr,
	_fcomp_instr,
	_fcompp_instr,
	_fucompp_instr,
	_fucom_instr,
	_fucomp_instr,
	
	emms_instr,
	
	// The following are not supported by MASM6,
	// so we always output them in hexadecimal form:
	
	sysenter_instr,
	sysexit_instr,
	ud2_instr,
	
	pause_instr,
	
	num_implied_instrs
		
};

	
// Emit an implied instruction to the object file:

extern void implied_instr( enum implied_instrs );





// Internal codes for the string instructions:

enum str_instrs
{
	movsb_instr,	
	movsw_instr,	
	movsd_instr,
		
	rep_movsb_instr,	
	rep_movsw_instr,	
	rep_movsd_instr,
		
	lodsb_instr,	
	lodsw_instr,	
	lodsd_instr,
		
	rep_lodsb_instr,	
	rep_lodsw_instr,	
	rep_lodsd_instr,
		
		
	stosb_instr,	
	stosw_instr,	
	stosd_instr,
		
	rep_stosb_instr,	
	rep_stosw_instr,	
	rep_stosd_instr,
		
	cmpsb_instr,	
	cmpsw_instr,	
	cmpsd_instr,
		
	repe_cmpsb_instr,	
	repe_cmpsw_instr,	
	repe_cmpsd_instr,
		
	repne_cmpsb_instr,	
	repne_cmpsw_instr,	
	repne_cmpsd_instr,
		
	scasb_instr,	
	scasw_instr,	
	scasd_instr,
		
	repe_scasb_instr,	
	repe_scasw_instr,	
	repe_scasd_instr,
		
	repne_scasb_instr,	
	repne_scasw_instr,	
	repne_scasd_instr,
		
		
	outsb_instr,	
	outsw_instr,	
	outsd_instr,
		
	rep_outsb_instr,	
	rep_outsw_instr,	
	rep_outsd_instr,
		
		
	insb_instr,	
	insw_instr,	
	insd_instr,
		
	rep_insb_instr,	
	rep_insw_instr,	
	rep_insd_instr,

	num_str_instrs
		
};

	
// Emit a string instruction to the object file:

extern void str_instr( enum str_instrs );

// Emit a return instruction

extern void ret_instr( int retSize );




// Internal codes for the FP instructions.
// Note: the code depends on the orders (and values) of this enumerated values.
// Do not change without carefully considering *everywhere* these constants are
// used (and their use is implied).

enum fp_instrs
{
	fadd_instr,
	fmul_instr,
	fcom_instr,
	fcomp_instr,
	fsub_instr,
	fsubr_instr,
	fdiv_instr,
	fdivr_instr,
	
	num_fp_instrs
};

enum fpp_instrs
{
	faddp_instr,
	fmulp_instr,
	freservedD0_instr,
	fcompp_instr,
	fsubp_instr,
	fsubrp_instr,
	fdivp_instr,
	fdivrp_instr,
		
	num_fpp_instrs
};


enum fpi_instrs
{
	fiadd_instr,
	fimul_instr,
	ficom_instr,
	ficomp_instr,
	fisub_instr,
	fisubr_instr,
	fidiv_instr,
	fidivr_instr,
	
	num_fpi_instrs
};


enum fp_op1Or2_instrs
{
	fcmovb_instr,
	fcmove_instr,
	fcmovbe_instr,
	fcmovu_instr,
	fcmovnb_instr,
	fcmovne_instr,
	fcmovnbe_instr,
	fcmovnu_instr,
	fucom_instr,
	fucomp_instr,
	
	fucomi_instr,	// These must appear last
	fcomi_instr,
	fucomip_instr,
	fcomip_instr,
	
	num_fp_op1Or2_instrs
};


enum sse_instrs
{
	addps_instr,
	andnps_instr,
	andps_instr,
	divps_instr,
	maxps_instr,
	minps_instr,
	mulps_instr,
	orps_instr,
	rcpps_instr,
	rsqrtps_instr,
	sqrtps_instr,
	subps_instr,
	xorps_instr,
	
	addss_instr,
	divss_instr,
	maxss_instr,
	minss_instr,
	mulss_instr,
	rcpss_instr,
	rsqrtss_instr,
	sqrtss_instr,
	subss_instr,
	
	addpd_instr,
	andnpd_instr,
	andpd_instr,
	divpd_instr,
	maxpd_instr,
	minpd_instr,
	mulpd_instr,
	orpd_instr,
	sqrtpd_instr,
	subpd_instr,
	xorpd_instr,
	
	addsd_instr,
	divsd_instr,
	maxsd_instr,
	minsd_instr,
	mulsd_instr,
	sqrtsd_instr,
	subsd_instr,
	
	
	cvtdq2ps_instr,
	cvtpd2dq_instr,
	cvtpd2ps_instr,
	cvtps2dq_instr,
	cvttpd2dq_instr,
	cvttps2dq_instr,
	
	
	movshdup_instr,
	movsldup_instr,	
	addsubps_instr,
	addsubpd_instr,
	haddps_instr,
	haddpd_instr,
	hsubps_instr,
	hsubpd_instr,
	
	num_sse_instrs
};

extern void sse_instr_m_r
(
	enum sse_instrs instr, 
	struct adrsYYS *adrs, 
	int reg
);
					  
extern void sse_instr_r_r
( 
	enum sse_instrs instr, 
	int srcReg, 
	int destReg
);


enum movsds_instrs
{
	_movsd_instr,
	movss_instr,
	
	num_movsds_instrs
};

extern void EmitMovsds_r_m
(
	enum movsds_instrs instr, 
	int reg,
	struct adrsYYS *adrs 
);
					  
extern void EmitMovsds_m_r
( 
	enum movsds_instrs instr, 
	struct adrsYYS *adrs, 
	int reg
);
					  
extern void EmitMovsds_r_r
( 
	enum movsds_instrs instr, 
	int srcReg, 
	int destReg
);






enum mw_rv_instrs
{
	sldt_instr,
	streg_instr,
	smsw_instr,
		
	num_mw_rv_instrs
};

enum ew_instrs
{
	lldt_instr,
	ltreg_instr,
	verr_instr,
	verw_instr,
	lmsw_instr,
	
	num_ew_instrs
};

enum ms_instrs
{
	sgdt_instr,
	sidt_instr,
	lgdt_instr,
	lidt_instr,
	
	num_ms_instrs
};

enum Gv_Ew_instrs
{
	lar_instr,
	lsl_instr,

	num_Gv_Ew_instrs
};

enum Vps_Mq_instrs
{
	movlps_instr,
	movhps_instr,
	
	num_Vps_Mq_instrs
};

enum Vps_VRq_instrs
{
	movhlps_instr,
	movlhps_instr,
	
	num_Vps_VRq_instrs
};

enum Vps_Wq_instrs
{
	unpcklps_instr,
	unpckhps_instr,
	
	num_Vps_Wq_instrs
};

enum Vpd_Mq_instrs
{
	movlpd_instr,
	movhpd_instr,
	
	num_Vpd_Mq_instrs
};


enum Vpd_Wq_instrs
{
	unpcklpd_instr,
	unpckhpd_instr,
	cvtdq2pd_instr,
	
	num_Vpd_Wq_instrs
};

enum Gv_Ev_instrs
{
	cmovo_instr,
	cmovno_instr,
	cmovb_instr,
	cmovnb_instr,
	cmovz_instr,
	cmovnz_instr,
	cmovbe_instr,
	cmovnbe_instr,
	cmovs_instr,
	cmovns_instr,
	cmovp_instr,
	cmovnp_instr,
	cmovl_instr,
	cmovnl_instr,
	cmovle_instr,
	cmovnle_instr,
	bsf_instr,
	bsr_instr,
	
	num_Gv_Ev_instrs
};

enum Gd_VRp_instrs
{
	movmskps_instr,
	movmskpd_instr,
	
	num_Gd_VRp_instrs
};


enum Pq_Qq_instrs
{
	packsswb_instr,
	pcmpgtb_instr,
	pcmpgtw_instr,
	pcmpgtd_instr,
	packuswb_instr,
	pcmpeqb_instr,
	pcmpeqw_instr,
	pcmpeqd_instr,
	paddq_instr,
	pmullw_instr,
	pavgb_instr,
	pavgw_instr,
	pmulhuw_instr,
	pmulhw_instr,
	pmuludq_instr,
	pmaddwd_instr,
	psadbw_instr,
	packssdw_instr,
	psubusb_instr,
	psubusw_instr,
	pminub_instr,
	pand_instr,
	paddusb_instr,
	paddusw_instr,
	pmaxub_instr,
	pandn_instr,
	psubsb_instr,
	psubsw_instr,
	pminsw_instr,
	por_instr,
	paddsb_instr,
	paddsw_instr,
	pmaxsw_instr,
	pxor_instr,
	psubb_instr,
	psubw_instr,
	psubd_instr,
	psubq_instr,
	paddb_instr,
	paddw_instr,
	paddd_instr,
	
	num_Pq_Qq_instrs
};
	


enum Vdq_Wq_instrs
{
	punpcklbw_instr,
	punpcklwd_instr,
	punpckldq_instr,
	punpckhbw_instr,
	punpckhwd_instr,
	punpckhdq_instr,
	punpcklqdq_instr,
	punpckhqdq_instr,
	lddqu_instr,
	
	num_Vdq_Wq_instrs
};


enum pshuf_instrs
{
	pshufw_instr,
	pshufhw_instr,
	pshufd_instr,
	pshuflw_instr,
	
	num_pshuf_instrs
};

enum psr_psl_instrs
{
	psrlw_instr,
	psraw_instr,
	psllw_instr,
	psrld_instr,
	psrad_instr,
	pslld_instr,
	psrlq_instr,
	psllq_instr,
	psrldq_instr,
	pslldq_instr,
	
	num_psr_psl_instrs
};


enum set_Eb_instrs
{
	seto_instr,
	setno_instr,
	setb_instr,
	setnb_instr,
	setz_instr,
	setnz_instr,
	setbe_instr,
	setnbe_instr,
	sets_instr,
	setns_instr,
	setp_instr,
	setnp_instr,
	setl_instr,
	setnl_instr,
	setle_instr,
	setnle_instr,
	
	num_set_Eb_instrs
};


enum bt_instrs
{
	bt_instr,			// Order is *very* important here! Do not change. Ever.
	bts_instr,
	btr_instr,
	btc_instr,
	lockbts_instr,		// All lock instrs must be greater than the std instrs.
	lockbtr_instr,
	lockbtc_instr,	
	
	num_bt_instrs
};


enum shxd_instrs
{
	shld_instr,
	shrd_instr,
	
	num_shxd_instrs
};

enum movXx_instrs
{
	movsx_instr,
	movzx_instr,
	
	num_movXx_instrs
};

enum subCmpss_instrs
{
	cmpeqss_instr,
	cmpltss_instr,
	cmpless_instr,
	cmpunordss_instr,
	cmpness_instr,
	cmpnltss_instr,
	cmpnless_instr,
	cmpordss_instr,
	
	num_subCmpss_instrs
};

enum subCmpps_instrs
{
	cmpeqps_instr,
	cmpltps_instr,
	cmpleps_instr,
	cmpunordps_instr,
	cmpneps_instr,
	cmpnltps_instr,
	cmpnleps_instr,
	cmpordps_instr,
	
	num_subCmpps_instrs
};

enum subCmpsd_instrs
{
	cmpeqsd_instr,
	cmpltsd_instr,
	cmplesd_instr,
	cmpunordsd_instr,
	cmpnesd_instr,
	cmpnltsd_instr,
	cmpnlesd_instr,
	cmpordsd_instr,
	
	num_subCmpsd_instrs
};

enum subCmppd_instrs
{
	cmpeqpd_instr,
	cmpltpd_instr,
	cmplepd_instr,
	cmpunordpd_instr,
	cmpnepd_instr,
	cmpnltpd_instr,
	cmpnlepd_instr,
	cmpordpd_instr,
	
	num_subCmppd_instrs
};

enum com_instrs
{
	comiss_instr,
	comisd_instr,
	ucomiss_instr,
	ucomisd_instr,
	
	num_com_instrs
};

enum pd2pi_instrs
{
	cvtpd2pi_instr,
	cvttpd2pi_instr,
	
	num_pd2pi_instrs
};


enum pdsd2pdss_instrs
{
	cvtps2pd_instr,
	cvtsd2ss_instr,
	
	num_pdsd2pdss_instrs
};


enum ps2pi_instrs
{
	cvtps2pi_instr,
	cvttps2pi_instr,
	
	num_ps2pi_instrs
};



extern void Emitps2pi_r_r( int instr, int SrcReg, int destReg );
extern void Emitps2pi_m_r( int instr, struct adrsYYS *adrs, int destReg );
 
extern void Emit_Movddup_r_r( int srcReg, int destReg );
extern void Emit_Movddup( struct adrsYYS *adrs, int destReg );

enum sd2si_instrs
{
	cvtsd2si_instr,
	cvttsd2si_instr,
	
	num_sd2si_instrs
};



extern void Emitsd2si_r_r( enum sd2si_instrs, int srcReg, int destReg );
extern void Emitsd2si_m_r( enum sd2si_instrs, struct adrsYYS *adrs, int destReg );
 
 
 

enum ss2si_instrs
{
	cvtss2si_instr,
	cvttss2si_instr,
	
	num_ss2si_instrs
};



extern void Emitss2si_r_r( enum ss2si_instrs, int srcReg, int destReg );
extern void Emitss2si_m_r( enum ss2si_instrs, struct adrsYYS *adrs, int destReg );

extern void Emitss2sd_r_r( int srcReg, int destReg );
extern void Emitss2sd_m_r( struct adrsYYS *adrs, int destReg );
 
 
 

enum si2sds_instrs
{
	cvtsi2sd_instr,
	cvtsi2ss_instr,
	
	num_si2sds_instrs
};



extern void Emitsi2sds_r_r( enum si2sds_instrs, int srcReg, int destReg );
extern void Emitsi2sds_m_r( enum si2sds_instrs, struct adrsYYS *adrs, int destReg );
 
 
enum pi2pdps_instrs
{
	cvtpi2pd_instr,
	cvtpi2ps_instr,
	
	num_pi2pdps_instrs
};

extern void Emitpi2pdps_r_r( int instr, int SrcReg, int destReg );
extern void Emitpi2pdps_m_r( int instr, struct adrsYYS *adrs, int destReg );


enum fence_instrs
{
	lfence_instr,
	mfence_instr,
	sfence_instr,
	
	num_fence_instrs
};

extern void fence_instr( enum fence_instrs instr );

enum monitor_instrs
{
	monitor_instr,
	mwait_instr,
	
	num_monitor_instrs
};

extern void EmitMonitor( enum monitor_instrs instr );
 
 
enum ldstmxcsr_instrs
{
	ldmxcsr_instr,
	stmxcsr_instr,
	
	num_ldstmxcsr_instrs
};

extern void EmitMxcsr( enum ldstmxcsr_instrs instr, struct adrsYYS *adrs );

 
extern void EmitPssd2pdss_r_r( int instr, int SrcReg, int destReg );
extern void EmitPssd2pdss_m_r( int instr, struct adrsYYS *adrs, int destReg );

extern void EmitPd2pi_r_r( int instr, int SrcReg, int destReg );
extern void EmitPd2pi_m_r( int instr, struct adrsYYS *adrs, int destReg );


extern void EmitCvt1_r_r( int instr, int srcReg, int destReg );
extern void EmitCvt1_m_r( int instr, struct adrsYYS *adrs, int destReg );

extern void EmitCom_r_r( int instr, int srcReg, int destReg );
extern void EmitCom_m_r( int instr, struct adrsYYS *adrs, int destReg );



extern void EmitAddSubPs_r_r( int srcReg, int destReg );
extern void EmitAddSubPs_m_r( struct adrsYYS *adrs, int destReg );
extern void EmitAddSubPd_r_r( int srcReg, int destReg );
extern void EmitAddSubPd_m_r( struct adrsYYS *adrs, int destReg );

extern void EmitMaskMovq_r_r( int srcReg, int destReg );
extern void EmitMaskMovdqu_r_r( int srcReg, int destReg );

extern void EmitMovntq_r_m( int srcReg, struct adrsYYS *adrs );
extern void EmitMovntdq_r_m( int srcReg, struct adrsYYS *adrs );

extern void EmitPmovmskb_r_r( int srcReg, int gpReg, int prefix );
			 
extern void EmitMovq2dq_r_r( int mReg, int xReg );
extern void EmitMovdq2q_r_r( int xReg, int mReg );

extern void EmitCmpXchg8b( struct adrsYYS *adrs );

extern void EmitShufxx_r_r( int prefix, int cnst, int srcReg, int destReg );
extern void EmitShufxx_m_r( int prefix, int cnst, struct adrsYYS *adrs, int destReg );

extern void EmitXadd_r_r( int srcReg, int destReg );
extern void EmitXadd_r_m( int srcReg, struct adrsYYS *adrs, int lockPrefix );

extern void EmitPextrw_r_r( int cnst, int gpReg, int destReg, int prefix );

extern void EmitPinsrw_r_r( int cnst, int gpReg, int destReg, int prefix );
extern void EmitPinsrw_m_r( int cnst, struct adrsYYS *adrs, int destReg, int prefix );

extern void EmitMovnti_r_m( int reg, struct adrsYYS *adrs );
 
extern void EmitCmpps_r_r( int subop, int srcReg, int destReg );
extern void EmitCmpss_r_r( int subop, int srcReg, int destReg );
extern void EmitCmppd_r_r( int subop, int srcReg, int destReg );
extern void EmitCmpsd_r_r( int subop, int srcReg, int destReg );

extern void EmitCmpps_m_r( int subop, struct adrsYYS *adrs, int destReg );
extern void EmitCmpss_m_r( int subop, struct adrsYYS *adrs, int destReg );
extern void EmitCmppd_m_r( int subop, struct adrsYYS *adrs, int destReg );
extern void EmitCmpsd_m_r( int subop, struct adrsYYS *adrs, int destReg );

extern void EmitMovxx_m_r( int instr, struct adrsYYS *adrs, int reg );
extern void EmitMovxx_r_r( int instr, int srcReg, int destReg );


extern int isDispOnly( struct adrsYYS *adrs );

extern void EmitLxS( int segreg, int reg, struct adrsYYS *adrs );

extern void EmitLea_m_r( struct adrsYYS *adrs, int reg );
extern void EmitLea_m_r2( struct adrsYYS *adrs, int reg );
extern void initLea_m_r( int baseReg, int disp, int reg );

extern void initMov_r_m( int reg, int regmem, int disp, int size );
extern void initMov_m_r( int regmem, int disp, int reg, int size );

extern void EmitMov_p_r( union YYSTYPE *v, int reg );
extern void EmitMov_o_r( char *label, int disp, int reg );
extern void EmitMov_oa_r( struct adrsYYS *adrs, int reg );
extern void EmitMov_o_m( char *label, int disp, struct adrsYYS *adrs );
extern void EmitMov_r_r( int src, int dest );
extern void EmitMov_r_m( int reg, struct adrsYYS *adrs, int size );
extern void EmitMov_m_r( struct adrsYYS *adrs, int reg, int size );
extern void EmitMov_c_r( unsigned cnst, int dest );
extern void EmitMov_c_m( unsigned cnst, struct adrsYYS *adrs );
extern void EmitMov_r_sr( int gpreg, int sreg );
extern void EmitMov_sr_r( int sreg, int gpreg );
extern void EmitMov_sr_m( int sreg, struct adrsYYS *adrs );
extern void EmitMov_m_sr( struct adrsYYS *adrs, int sreg );
extern void EmitMov_r_dr( int reg, int dreg );
extern void EmitMov_dr_r( int dreg, int reg );
extern void EmitMov_r_cr( int reg, int creg );
extern void EmitMov_cr_r( int creg, int reg );

extern void Emit_bt_r_r( enum bt_instrs instr, int src, int dest );
extern void Emit_bt_c_r( enum bt_instrs instr, int bitnum, int reg );
extern void Emit_bt_r_m( enum bt_instrs instr, int reg, struct adrsYYS *adrs );
extern void Emit_bt_c_m( enum bt_instrs instr, int bitnum, struct adrsYYS *adrs );


extern void Emit_set_Eb_r( enum set_Eb_instrs instr, int reg );
extern void Emit_set_Eb_m( enum set_Eb_instrs instr, struct adrsYYS *adrs );
 
extern void Emit_shxd_c_r_r
( 
	enum shxd_instrs instr, 
	int bitcnt, 
	int src, 
	int dest 
);

extern void Emit_shxd_cl_r_r
( 
	enum shxd_instrs instr, 
	int src, 
	int dest 
);

extern void Emit_shxd_c_r_m
( 
	enum shxd_instrs instr, 
	int bitcnt, 
	int reg, 
	struct adrsYYS *adrs 
);

extern void Emit_shxd_cl_r_m
( 
	enum shxd_instrs instr, 
	int reg, 
	struct adrsYYS *adrs 
);




extern void Emit_psl_psr_imm
( 
	enum psr_psl_instrs instr, 
	int cnt, 
	int reg, 
	int isXmm 
);

void Emit_psl_psr_r
( 
	enum psr_psl_instrs instr, 
	int src, 
	int dest, 
	int isXmm 
);

void Emit_psl_psr_m
( 
	enum psr_psl_instrs instr, 
	struct adrsYYS *adrs, 
	int reg, 
	int isXmm 
);
	


extern void Emit_pshuf_r
( 
	enum pshuf_instrs instr,
	int cnt, 
	int src, 
	int dest 
);

extern void Emit_pshuf_m
( 
	enum pshuf_instrs instr,
	int cnt, 
	struct adrsYYS *adrs, 
	int dest 
);
	
	
extern void Emit_Vdq_Wq_r
( 
	enum Vdq_Wq_instrs instr, 
	int src, 
	int dest, 
	int isXmm 
);
extern void Emit_Vdq_Wq_m
( 
	enum Vdq_Wq_instrs instr, 
	struct adrsYYS *adrs, 
	int reg, 
	int isXmm 
);

extern void Emit_Vdq_Wd_r
( 
	enum Vdq_Wq_instrs instr, 
	int src, 
	int dest, 
	int isXmm 
);
extern void Emit_Vdq_Wd_m
( 
	enum Vdq_Wq_instrs instr, 
	struct adrsYYS *adrs, 
	int reg, 
	int isXmm 
);

extern void Emit_Pq_Qq_r
( 
	enum Pq_Qq_instrs instr, 
	int src, 
	int dest,
	int isXmm 
);
extern void Emit_Pq_Qq_m
( 
	enum Pq_Qq_instrs instr, 
	struct adrsYYS *adrs, 
	int reg,
	int isXmm 
);


//extern void Emit_Pq_Qd_r( enum Pq_Qd_instrs instr, int src, int dest );
//extern void Emit_Pq_Qd_m( enum Pq_Qd_instrs instr, struct adrsYYS *adrs, int mreg );

extern void Emit_Gd_VRp_r( enum Gd_VRp_instrs instr, int xreg, int reg );

extern void Emit_Gv_Ev_r( enum Gv_Ev_instrs instr, int src, int dest );
extern void Emit_Gv_Ev_m( enum Gv_Ev_instrs instr, struct adrsYYS *adrs, int reg );

extern void Emit_Vpd_Wq_r( enum Vpd_Wq_instrs instr, int src, int dest );
extern void Emit_Vpd_Wq_m( enum Vpd_Wq_instrs instr, struct adrsYYS *adrs, int reg );


extern void Emit_Vsd_Mq_m( enum Vpd_Mq_instrs instr, int reg, struct adrsYYS *adrs );
extern void Emit_Mq_Vsd_m( enum Vpd_Mq_instrs instr, struct adrsYYS *adrs, int reg );

extern void Emit_Vps_Wq_m( enum Vps_Wq_instrs instr, struct adrsYYS *adrs, int reg );
extern void Emit_Vps_Wq_r( enum Vps_Wq_instrs instr, int src, int dest );

extern void Emit_Vps_VRq( enum Vps_VRq_instrs instr, int src, int dest );
extern void Emit_Vps_Mq( enum Vps_Mq_instrs instr, int reg, struct adrsYYS *adrs );
extern void Emit_Mq_Vps( enum Vps_Mq_instrs instr, struct adrsYYS *adrs, int reg );

extern void Emit_Gv_Ew_r( enum Gv_Ew_instrs instr, int src, int dest );
extern void Emit_Gv_Ew_m( enum Gv_Ew_instrs instr, struct adrsYYS *adrs, int reg );

extern void Emit_invlpg( struct adrsYYS *adrs );
extern void Emit_ms_m( enum ms_instrs instr, struct adrsYYS *adrs );

extern void Emit_mw_rv_r( enum mw_rv_instrs instr, int reg );
extern void Emit_mw_rv_m( enum mw_rv_instrs instr, struct adrsYYS *adrs );

extern void Emit_ew_r( enum ew_instrs instr, int reg );
extern void Emit_ew_m( enum ew_instrs instr, struct adrsYYS *adrs );


// Emit single-byte instructions to the object file:

enum generic_instrs
{
	add_instr,
	adc_instr,
	and_instr,
	xor_instr,
	or_instr,
	sbb_instr,
	sub_instr,
	cmp_instr,
	
	lockadd_instr,
	lockadc_instr,
	lockand_instr,
	lockxor_instr,
	lockor_instr,
	locksbb_instr,
	locksub_instr,
	lockcmp_instr,

	num_generic_instrs
};

extern void EmitGeneric_r_r( enum generic_instrs instr, int src, int dest );

extern void EmitGeneric_r_m
( 
	enum generic_instrs instr, 
	int src, 
	struct adrsYYS *adrs 
);

extern void EmitGeneric_m_r
( 
	enum generic_instrs instr, 
	struct adrsYYS *adrs, 
	int dest 
);

extern void EmitGeneric_i_r
( 
	enum generic_instrs instr, 
	union YYSTYPE *v, 
	int dest 
);

extern void EmitGeneric_c_r( enum generic_instrs instr, int cnst, int destReg );

extern void EmitGeneric_i_m
( 
	enum generic_instrs instr, 
	union YYSTYPE *v, 
	struct adrsYYS *adrs 
);

extern void EmitGeneric_c_m
( 
	enum generic_instrs instr, 
	int cnst, 
	struct adrsYYS *adrs 
);


enum unary_instrs
{
	dec_instr,
	inc_instr,
	neg_instr,
	not_instr,
	mul_instr,
	imul_instr,
	div_instr,
	idiv_instr,
	mod_instr,
	imod_instr,
	lockdec_instr,
	lockinc_instr,
	lockneg_instr,
	locknot_instr,
	
	num_unary_instrs
};

#define isLockUnary(i) ((i) >= lockdec_instr )
#define unlockUnary(i) ((i) - lockdec_instr )

extern void EmitUnary_r( enum unary_instrs instr, int reg );
extern void EmitUnary_m( enum unary_instrs instr, struct adrsYYS *adrs );


extern void EmitBound_r_m
( 
	int reg, 
	struct adrsYYS *mem,
	unsigned size 
);

extern void EmitBound_r_c_c
( 
	int 		reg, 
	unsigned 	lower,
	unsigned 	upper,
	unsigned 	size
	 
);


extern void EmitArpl_r_r( int src, int dest );
extern void EmitArpl_r_m( int dest, struct adrsYYS *adrs );


enum jcc_instrs
{
	ja_instr,
	jae_instr,
	jb_instr,
	jbe_instr,
	jc_instr,
	je_instr,
	jg_instr,
	jge_instr,
	jl_instr,
	jle_instr,
	jna_instr,
	jnae_instr,
	jnb_instr,
	jnbe_instr,
	jnc_instr,
	jne_instr,
	jng_instr,
	jnge_instr,
	jnl_instr,
	jnle_instr,
	jno_instr,
	jnp_instr,
	jns_instr,
	jnz_instr,
	jo_instr,
	jp_instr,
	jpe_instr,
	jpo_instr,
	js_instr,
	jz_instr,
	jcxz_instr,
	jecxz_instr,
	loop_instr,
	loope_instr,
	loopne_instr,
	loopz_instr,
	loopnz_instr,
	
	num_jcc_instrs
};	
	
	



extern void processCondJump
( 
	enum jcc_instrs instr, 
	char *target, 
	int TrueLabel, 
	int FalseLabel 
);


extern void EmitCondJump
( 
	enum jcc_instrs instr, 
	char *target 
);


extern void EmitTest_r_r( int src, int dest );
extern void EmitTest_r_m( int src, struct adrsYYS *adrs );
extern void EmitTest_m_r( struct adrsYYS *adrs, int src );
extern void EmitTest_c_r( union YYSTYPE *cnst, int dest );
extern void EmitTest_c_m( union YYSTYPE *cnst, struct adrsYYS *adrs );
	
	
extern void EmitXchg_r_r( int locked, int src, int dest );	
extern void EmitXchg_r_m( int locked, int reg, struct adrsYYS *adrs );	
	

enum shiftAndRotate_instrs
{
	rol_instr,
	ror_instr,
	rcl_instr,
	rcr_instr,
	shl_instr,
	sal_instr,
	shr_instr,
	sar_instr,
	
	num_shiftAndRotate_instrs
};
	
extern void EmitShiftRotate_c_r
(
	enum shiftAndRotate_instrs instr,
	int shiftVal,
	int reg,
	int size
);
	
extern void EmitShiftRotate_cl_r
(
	enum shiftAndRotate_instrs instr,
	int reg,
	int size
);
	
extern void EmitShiftRotate_c_m
(
	enum shiftAndRotate_instrs instr,
	int shiftVal,
	struct adrsYYS *adrs
);
	
extern void EmitShiftRotate_cl_m
(
	enum shiftAndRotate_instrs instr,
	struct adrsYYS *adrs
);
	

enum inout_instrs
{
	in_instr,
	out_instr,
	
	num_inout_instrs
};
	
extern void EmitInOut( enum inout_instrs instr, int port, int reg );
extern void EmitInOutDX( enum inout_instrs instr, int reg );
	
	
extern void EmitIntMul_r_r( int src, int dest );
extern void EmitIntMul_m_r( struct adrsYYS *adrs, int dest );
extern void EmitIntMul_c_r_r( int cnst, int src, int dest );
extern void EmitIntMul_c_m_r( int cnst, struct adrsYYS *adrs, int dest );

extern void call_proc( SymNode_t *proc );
extern void call_thunk( struct adrsYYS *adrs );
extern void EmitCallLabel( char *label );
extern void EmitCall_m( struct adrsYYS *adrs );
extern void EmitCall_r( int reg );


extern void EmitEnter_c_c( int nesting, int vars );

extern void EmitInt_c( int intnum );

extern void EmitJmp_r( int reg );
extern void EmitJmp_m( struct adrsYYS *adrs );
extern void EmitJmpLabel( char *label );


extern void EmitBswap_r( int reg );

extern void EmitCmpXchg_r_r( int locked, int src, int dest );
extern void EmitCmpXchg_m_r( int locked, struct adrsYYS *adrs, int reg );

	
// here i am

// Emit floating-point arithmetic instructions to the object file:

extern void fp_arith_noOp_instr( enum fp_instrs );
extern void fp_arith_sti_st0_instr( enum fp_instrs, enum fpregnums fpreg );
extern void fp_arith_st0_sti_instr( enum fp_instrs, enum fpregnums fpreg );
extern void fp_arith_mem_instr( enum fp_instrs, struct adrsYYS *adrs );

extern void fpp_arith_noOp_instr( enum fpp_instrs );
extern void fpp_arith_sti_st0_instr( enum fpp_instrs, enum fpregnums fpreg );
extern void fpp_arith_st0_sti_instr( enum fpp_instrs, enum fpregnums fpreg );

extern void fpi_arith_mem_instr( enum fpi_instrs, struct adrsYYS *adrs );

extern void fp_op1Or2_instr( enum fp_op1Or2_instrs, enum fpregnums fpreg ); 

extern void fld_sti( enum fpregnums fpreg );
extern void fld_mem( struct adrsYYS *adrs );

extern void fst_sti( enum fpregnums fpreg );
extern void fst_mem( struct adrsYYS *adrs );
extern void fstp_sti( enum fpregnums fpreg );
extern void fstp_mem( struct adrsYYS *adrs );

extern void fild_mem( struct adrsYYS *adrs );
extern void fist_mem( struct adrsYYS *adrs );
extern void fistp_mem( struct adrsYYS *adrs );
extern void fisttp_mem( struct adrsYYS *adrs );

extern void fbld_mem( struct adrsYYS *adrs );
extern void fbstp_mem( struct adrsYYS *adrs );

extern void fxch_sti( enum fpregnums fpreg );
extern void ffree_sti( enum fpregnums fpreg );

extern void fldenv_mem( struct adrsYYS *adrs );
extern void fstenv_mem( struct adrsYYS *adrs, unsigned emitWait );

extern void frstor_mem( struct adrsYYS *adrs );
extern void fsave_mem( struct adrsYYS *adrs, unsigned emitWait );

extern void fxrstor_mem( struct adrsYYS *adrs );
extern void fxsave_mem( struct adrsYYS *adrs );

extern void fldcw_mem( struct adrsYYS *adrs );
extern void fstcw_mem( struct adrsYYS *adrs, unsigned emitWait );

extern void fstsw_mem( struct adrsYYS *adrs, unsigned emitWait );
extern void fstsw_ax( unsigned emitWait );

extern void movd_r_m( int reg, struct adrsYYS *adrs, int prefix66 );
extern void movd_m_r( struct adrsYYS *adrs, int reg, int prefix66 );

extern void movd_r32_r( int r32, int reg, int prefix66 );
extern void movd_r_r32( int reg, int r32, int prefix66 );

extern void movq_regmmx_m( int reg, struct adrsYYS *adrs );
extern void movq_m_regmmx( struct adrsYYS *adrs, int reg );
extern void movq_regxmm_m( int reg, struct adrsYYS *adrs );
extern void movq_m_regxmm( struct adrsYYS *adrs, int reg );
extern void movq_r_r( int reg1, int reg2, int prefix66 );
	
	
	
enum sse_mov_instrs
{
	movaps_instr,
	movups_instr,
	movapd_instr,
	movupd_instr,
	movdqa_instr,
	movdqu_instr,
	
	num_sse_mov_instrs
};	
					  
extern void sse_mov_instr_r_m
( 
	enum sse_mov_instrs instr, 
	int reg,
	struct adrsYYS *adrs 
);
					  
extern void sse_mov_instr_m_r
( 
	enum sse_mov_instrs instr, 
	struct adrsYYS *adrs, 
	int reg
);
					  
extern void sse_mov_instr_r_r
( 
	enum sse_mov_instrs instr, 
	int srcReg, 
	int destReg
);



extern void EmitMovss_r_m
( 
	int reg,
	struct adrsYYS *adrs 
);
					  
extern void EmitMovss_m_r
( 
	struct adrsYYS *adrs, 
	int reg
);
					  
extern void EmitMovss_r_r
( 
	int srcReg, 
	int destReg
);

					  
enum m8_instrs
{
	clflush_instr,
	prefetch0_instr,
	prefetch1_instr,
	prefetch2_instr,
	prefetchnta_instr,
	
	num_m8_instrs
};


extern void EmitM8Instrs( int instr, struct adrsYYS *adrs );
					  
enum movnt_instrs
{
	movntpd_instr,
	movntps_instr,
	
	num_movnt_instrs
};


extern void EmitMovntp( int instr, int reg, struct adrsYYS *adrs );	


extern void movsb( void );
extern void movsd( void );
extern void movsw( void );

extern void pop_r( int theReg );
extern void popfd( void );

extern void push_mem( struct adrsYYS *adrs, int forcedSize );
extern void push_memInit( char *sn, int baseReg, int disp, int size );
extern void push_disp( char *label, int size );
extern void push_offset( union YYSTYPE *offset );
extern void push_r( int theReg );
extern void push_sr( int theSegReg );
extern void Pushd( unsigned d );
extern void Pushw( unsigned d );
extern void pushfd( void );
extern void pushf( void );

extern void pop_mem( struct adrsYYS *adrs, int forcedSize );
extern void pop_memInit( char *sn, int baseReg, int disp, int size );
extern void pop_r( int theReg );
extern void pop_sr( int theReg );
extern void popad( void );
extern void popaw( void );
extern void popf( void );
extern void popfd( void );

extern void rep_movsb( void );
extern void rep_movsd( void );
extern void rep_movsw( void );

extern void cseg_prefix( void );
extern void dseg_prefix( void );
extern void eseg_prefix( void );
extern void fseg_prefix( void );
extern void gseg_prefix( void );
extern void sseg_prefix( void );





extern void PassValpConst( SymNode_t *sym, union YYSTYPE *value );
extern enum regnums RegStrToReg( char *reg );

void PushActualValue( struct adrsYYS *actual, int useReg );



extern void EmitLabelledString
( 
	char *theStr, 
	char *theLabel 
);

extern void EmitImmExtern( char *theSymbol, enum PrimType labelType );
	 


extern void EmitByteString
(
	char	*theString,
	int		zeroTerminate
);

extern void EmitWordString( char *theString );

extern void EmitBooleanExpr
( 
	struct opnodeYYS *o, 
	char *target,
	int tfjmp 
);

void FreeOperand( struct opnodeYYS *o );

extern void ComparableNodes
( 
	struct operandYYS *left, 
	struct operandYYS *right,
	char *operator
);


extern void SkeletalOutput( void );


 /*
 ** Label Emission Functions
 */

extern void EmitLabel( char *theLabel, unsigned size );
extern void EmitTypedLabel( char *theLabel, enum PrimType pType );
extern void EmitTypedLabelNum( char *theLabel, char *labelType, int num );
extern void EmitExtern( SymNode_t *sym, unsigned size );
extern void EmitTypedExtern
( 
	SymNode_t		*sym, 
	char 			*theSymbol, 
	enum PrimType	labelType 
);
extern void EmitVMTExtern( SymNode_t *sym, char *theSymbol );
extern void EmitPublic( char *theLabel );
extern void EmitTypedPublic( char *theLabel, enum PrimType pType );
extern void EmitAdrs( char *theLabel );
extern void extPubIterator( outputBuf *output );
extern void EmitPointer( union YYSTYPE *adrs );
extern void EmitDispOnly( struct adrsYYS *adrs );
extern void EmitOffset( char *offset, int disp );

 /*
 ** Data and other Emission Functions
 */

extern void EmitDwordConst( unsigned theConst, char *comment );
extern void EmitLWordConst( void *theConst );
extern void EmitQWordConst( void *theConst );
extern void EmitWordConst( unsigned theConst );
extern void EmitByteConst( unsigned theConst, char *comment );
extern void EmitReal4Const( float theConst );
extern void EmitReal8Const( double theConst );
extern void EmitReal10Const( flt80_t theConst );
extern void EmitArrayConst( enum PrimType pType, int elements, unsigned value );
extern void EmitData( char *label, enum PrimType pType, char* Operand );

extern void EmitLword( void );
extern void EmitQword( void );
extern void EmitTbyte( void );
extern void EmitDword( void );
extern void EmitWord( void );
extern void EmitByte( void );
extern void EmitArray( enum PrimType pType, int elements );
extern void ReserveTypedStorage
( 
	char		*theVar, 
	SymNode_t	*theType, 
	int 		elements 
);
extern void ReserveUntypedStorage( char *theVar, int bytes );
extern void ReserveStorage( unsigned size );

extern void EmitByteStr( char *theStr, int ZeroTerminate );

extern int  EmitString( char *theStr );
extern void EmitWString( char *theStr, int theLabel );
extern void EmitLabeledString( char *theStr, char *theLabel );


//extern enum PrimType OutName( char *StaticName, SymNode_t *Type );
//extern void OutNameAndType( char *StaticName, SymNode_t *Type );
extern void OutValue
( 
	char			*Name, 
	SymNode_t		*Type, 
	union YYSTYPE	*Value 
);
extern void OutStaticConst
( 
	char 			*StaticName, 
	SymNode_t 		*sym, 
	union YYSTYPE 	*val 
);

extern int StaticConstToStr
( 
	SymNode_t 		*type, 
	union YYSTYPE 	*value, 
	char 			*dest 
);


extern void EmitAlign( unsigned alignment );
extern void StartProc( char *procname );
extern void EndProc( char *procname );
extern void AlignStack( void );
extern void AllocateLocals( unsigned localSize );
extern void StdEntry( int RoundedOffset, int NoEntry );
extern void StdExit( int StkSize, int cdeclProc, int NoLeave );
extern void IteratorExit( int StkSize );
extern void ConstructDisplay( int lexlevel, int RoundedOffset, int NoEnter );
extern void EmitStmtLbl( char *label );
extern void EmitGlobalStmtLbl( char *label );
extern void EmitStmtLblNum( char *label, int num );
extern void NewLn( void );
extern void EmitSegment( char *SegName, char *align, char *className );
extern void EndSeg( char *SegName );


 /*
 ** Backpatching functions
 */

extern void IterateBP( void );
extern void EmitBackPatchss( char *sym, char *equals, enum PrimType pType );
extern void EmitBackPatchds( char *sym, int symNum, char *equals );
extern void EmitBackPatchdsc
( 
	char *sym, 
	int symNum, 
	char *equals, 
	char *comment 
);

extern void EmitBackPatchddc
( 
	char	*sym, 
	int		symNum,
	char	*equals,
	int		eqNum,
	char	*comment
);




 /*
 ** Segment output related functions
 */

extern char* DsegName;
extern char* DsegAlign;
extern char* DsegClass;
extern int   DsegUsed;

extern char* CsegName;
extern char* CsegAlign;
extern char* CsegClass;
extern int   CsegUsed;

extern char* ROsegName;
extern char* ROsegAlign;
extern char* ROsegClass;
extern int   ROsegUsed;

extern char* StrSegName;
extern char* StrSegAlign;
extern char* StrSegClass;
extern int   StrSegUsed;

extern char* BssSegName;
extern char* BssSegAlign;
extern char* BssSegClass;
extern int   BssSegUsed;

extern char  extPubName[ 256 ];
extern char  csname[ 256 ];
extern char  dataname[ 256 ];
extern char  bssname[ 256 ];
extern char  roname[ 256 ];
extern char  constname[ 256 ];


enum SegTypes { segCode, segData, segBss, segRO, segConst };

extern void PushSeg( enum SegTypes s );
extern void PopSeg( void );

extern void startDseg( void );
extern void endDseg( void );

extern void startCseg( void );
extern void endCseg( void );

extern void startROseg( void );
extern void endROseg( void );

extern void startStrSeg( void );
extern void endStrSeg( void );

extern void startBssSeg( void );
extern void endBssSeg( void );

extern void EmitSegments( outputBuf *dest );



 /*
 ** General code generation stuff:
 */


extern void PushStaticAdrs( char *theLabel );
extern void EmitExceptionCode( int FullExceptions );
extern void BeginMain( int CurOffset );
extern void EndMain( void );
extern void EndSourceFile( void );


/*
** Instruction Emission
*/

extern void EmitComment( char *comment );

extern void Emit0( char *Instr );

extern void Emit1L( char *Instr, char *Operand );
extern void Emit1M( char *Instr, char *Operand );
extern void Emit1R( char *Instr, char *Operand );
extern void Emit1C( char *Instr, char *Operand );

extern void Emit2rr( char *Instr, char *Op1, char *Op2 );
extern void Emit2rm( char *Instr, char *Op1, char *Op2 );
extern void Emit2mr( char *Instr, char *Op1, char *Op2 );
extern void Emit2rc( char *Instr, char *Op1, char *Op2 );
extern void Emit2mc( char *Instr, char *Op1, char *Op2 );

extern void EmitIRC( char *Instr, char *reg, union YYSTYPE *theConst );
extern void EmitIMC( char *Instr, char *mem, union YYSTYPE *theConst );

extern void Emit2cc( char *Instr, char *Op1, char *Op2 );
extern void Emit2cr( char *Instr, char *Op1, char *Op2 );

extern void Emit3rrc
( 
	char *Instr, 
	char *Op1, 
	char *Op2, 
	char *Op3 
);

extern void Emit3mrc
( 
	char *Instr, 
	char *Op1, 
	char *Op2, 
	char *Op3 
);

extern void Emit3rmc
( 
	char *Instr, 
	char *Op1, 
	char *Op2, 
	char *Op3 
);

extern void Emit3rrr
( 
	char *Instr, 
	char *Op1, 
	char *Op2, 
	char *Op3 
);

extern void Emit3mrr
( 
	char *Instr, 
	char *Op1, 
	char *Op2, 
	char *Op3 
);

extern void EmitXmit( void );

void CompatGpReg( int reg1, int reg2 );
void CompatGpRegConst( union YYSTYPE *cnst, int reg );
void CompatMemConst( union YYSTYPE *cnst, struct adrsYYS *adrs );

int strToReg( char *strReg );

#endif
