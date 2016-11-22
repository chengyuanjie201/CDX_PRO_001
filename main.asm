/**************************�궨��**************************************/
CCON 	EQU 0D8H;����PCA�����⹦�ܼĴ���
CMOD 	EQU 0D9H
CCAPM0	EQU	0DAH
CCAPM1	EQU	0DBH
CL		EQU	0E9H
CH		EQU	0F9H
CR		BIT CCON.6
CCAP0L	EQU 0EAH
CCAP0H	EQU 0FAH
LCDPORT EQU P1	;LCD���ݿ�
T0TH0	EQU	0ECH
T0TL0	EQU	78H
T1TH1	EQU	0FFH
T1TL1	EQU	0FFH
/*************************��������**************************************/
LED0 	BIT P1.1;LED0
LED1 	BIT P1.0;LED1
LED2 	BIT P3.4;LED2
RS		BIT P1.3;LCD����/����ѡ��
EN		BIT P1.2;LCDʹ��
KEY1	BIT P3.2;����1
KEY2	BIT P3.3;����2
KEYVAL	DATA 47H;������ֵ
CHANNEL	DATA 48H;ͨ���� 1:INA  2:INB
NUM_BF1	DATA 50H;���ݻ��� 50H-52H
NUM_BF2	DATA 55H;���ݻ��� 53H-55H
POT_POS BIT  00H;С����λ��
KEY1_FLG BIT 01H;����1��־
STATEA	BIT  02H;
STATEB	BIT  03H;
/***************************�������******************************/	
	ORG 0000H
	SJMP SYSINTI
	ORG 000BH
	LJMP TIMER0;��ʱ��0�ж����
	ORG 001BH
	LJMP TIMER1;��ʱ��1�ж����
	ORG 0033H
	AJMP PCA_ISR;PCA�ж����
	ORG 0040H
/************************ϵͳ������ʼ��***************************/
SYSINTI:
	MOV SP,#40H;��ջ��ʼ��
	CLR STATEA
	CLR STATEB
/**************************ִ��һ��*******************************/
STEP:
	ACALL INIT_LCD1602
	ACALL INIT_TIMER
	ACALL INIT_PCA
	SETB EA
/**************************ѭ��ִ��*******************************/	
MAIN:
	ACALL DIS_UPDATE
	AJMP MAIN

	
		
	
//*************************LCDд����*********************************
//	@��������LCD_W_CMD
//	@��ڲ���:R4
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//******************************************************************/
LCD_W_CMD:
	CLR RS
	ANL LCDPORT,#0FH
	MOV A,R4
	ANL A,#0F0H
	ORL LCDPORT,A
	CLR EN
	NOP
	NOP
	NOP
	NOP
	SETB EN
	ANL LCDPORT,#0FH
	MOV A,R4
	SWAP A
	ANL A,#0F0H
	ORL LCDPORT,A
	CLR EN
	NOP
	NOP
	NOP
	NOP
	SETB EN
	ACALL DELAY1MS
RET
//*************************LCDд����*********************************
//	@��������LCD_W_DAT
//	@��ڲ���:R4
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//******************************************************************/
LCD_W_DAT:
	SETB RS
	ANL LCDPORT,#0FH
	MOV A,R4
	ANL A,#0F0H
	ORL LCDPORT,A
	CLR EN
	NOP
	NOP
	NOP
	NOP
	SETB EN
	ANL LCDPORT,#0FH
	MOV A,R4
	SWAP A
	ANL A,#0F0H
	ORL LCDPORT,A
	CLR EN
	NOP
	NOP
	NOP
	NOP
	SETB EN
	ACALL DELAY1MS
RET
//*************************LCD��ʼ��*********************************
//	@��������DELAY1MS
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//******************************************************************/
INIT_LCD1602:;LCD1602��ʼ�� ��������R4
	MOV R4,#02H
	ACALL LCD_W_CMD
	MOV R4,#28H
	ACALL LCD_W_CMD
	MOV R4,#0CH
	ACALL LCD_W_CMD
	MOV R4,#06H
	ACALL LCD_W_CMD
	MOV R4,#01H
	ACALL LCD_W_CMD
	MOV R4,#0
	ACALL LCD_W_DAT
	MOV R4,#0
	ACALL LCD_W_DAT
	MOV R4,#80H;lcdλ��ָ�� 
	ACALL LCD_W_CMD
RET
//*************************LCD��ʾ����*******************************
//	@��������DISPY_NUM
//	@��ڲ���:X����R1,Y����R2,С����λ��POT_POS(0:�ڶ�λ��1:����λ),���ݻ����׵�ַR0
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//******************************************************************/
DISPY_NUM:
	CJNE R1,#0,DIS_NXT1
	MOV A,#80H;
	SJMP POS_SET
DIS_NXT1:
	MOV A,#0C0H;
POS_SET:
	ADD A,R2
	MOV R4,A
	ACALL LCD_W_CMD;��������
	JB POT_POS,SWCH
	MOV A,#30H
	ADD A,@R0
	MOV R4,A
	ACALL LCD_W_DAT
	MOV R4,#'.'
	ACALL LCD_W_DAT
	INC R0
	MOV A,@R0
	MOV B,#10
	DIV AB
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	MOV A,B
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	INC R0
	MOV A,@R0
	MOV B,#10
	DIV AB
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	MOV A,B
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	AJMP EXT_DIS
SWCH:
	MOV A,@R0
	MOV B,#10
	DIV AB
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	MOV A,B
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	MOV R4,#'.'
	ACALL LCD_W_DAT
	INC R0
	MOV A,#30H
	ADD A,@R0
	MOV R4,A
	ACALL LCD_W_DAT
	INC R0
	MOV A,@R0
	MOV B,#10
	DIV AB
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
	MOV A,B
	ADD A,#30H
	MOV R4,A
	ACALL LCD_W_DAT
EXT_DIS:
	MOV R4,#'s'
	ACALL LCD_W_DAT
RET
//*******************************DIS_UPDATE********************************//
//	@��������DIS_UPDATE
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//*************************************************************************/
DIS_UPDATE:
	MOV R4,#80H;��ʾ<-INA:X.XXXX->
	ACALL LCD_W_CMD
	MOV R4,#'<'
	ACALL LCD_W_DAT
	MOV R4,#'-'
	ACALL LCD_W_DAT
	MOV R4,#'I'
	ACALL LCD_W_DAT
	MOV R4,#'N'
	ACALL LCD_W_DAT
	MOV R4,#'A'
	ACALL LCD_W_DAT
	MOV R4,#':'
	ACALL LCD_W_DAT
	MOV R1,#0000H
	MOV R2,#0006H
	MOV R0,#NUM_BF1
	ACALL DISPY_NUM
	MOV R4,#80H+14
	ACALL LCD_W_CMD
	MOV R4,#'-'
	ACALL LCD_W_DAT
	MOV R4,#'>'
	ACALL LCD_W_DAT
	
	MOV R4,#0C0H;��ʾ<-INB:X.XXXX->
	ACALL LCD_W_CMD
	MOV R4,#'<'
	ACALL LCD_W_DAT
	MOV R4,#'-'
	ACALL LCD_W_DAT
	MOV R4,#'I'
	ACALL LCD_W_DAT
	MOV R4,#'N'
	ACALL LCD_W_DAT
	MOV R4,#'B'
	ACALL LCD_W_DAT
	MOV R4,#':'
	ACALL LCD_W_DAT
	MOV R1,#0001H
	MOV R2,#0006H
	MOV R0,#NUM_BF2
	ACALL DISPY_NUM
	MOV R4,#0C0H+14
	ACALL LCD_W_CMD
	MOV R4,#'-'
	ACALL LCD_W_DAT
	MOV R4,#'>'
	ACALL LCD_W_DAT
RET
//*******************************ϵͳ��ʱ1ms***********************************//
//	@��������DELAY1MS
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//******************************************************************************/
DELAY1MS: 
    MOV R7,#01H
DL1:
    MOV R6,#8EH
DL0:
    MOV R5,#02H
    DJNZ R5,$
    DJNZ R6,DL0
    DJNZ R7,DL1
RET
//*******************************PCA��ʼ��********************************//
//	@��������INIT_PCA
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//*************************************************************************/
INIT_PCA:;PCA��ʼ�� 
	MOV CCON,#0
	MOV CMOD,#1
	MOV CCAPM0,#31H
	MOV CCAPM1,#31H
	SETB IE.6
	MOV CL,#0H
	MOV CH,#0H
RET
//*******************************��ʱ��0/1��ʼ��********************************/
//	@��������INIT_TIMER
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//******************************************************************************/
INIT_TIMER:;��ʱ��1��ʼ�� ģʽ1 ��ʱֵ5ms ���ڰ������
	MOV TMOD,#11H
    MOV TH0,#T0TH0
    MOV TL0,#T0TL0
    SETB ET0;T0�жϿ���
	SETB ET1;T0�жϿ���
	SETB TR0
	CLR TR1
RET
//*******************************����ɨ��********************************/
//	@��������KEYSCAN
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************/
KEYSCAN:
	JNB KEY1_FLG,NXTSCAN
	JB KEY1,EXT_SCAN
KEY1OK:
	JNB KEY1,KEY1OK;�ȴ������ͷ�
	MOV KEYVAL,#01H
	;**********************************�������㣨��λ������****************************
	CLR EA
	CLR STATEA
	CLR STATEB
	CLR CR
	CLR TR1
	CLR POT_POS
	CPL LED0
	MOV 50H,#0
	MOV 51H,#0
	MOV 52H,#0
	MOV 55H,#0
	MOV 56H,#0
	MOV 57H,#0
	SETB EA
	SJMP EXT_SCAN
NXTSCAN:
	JB KEY1,EXT_SCAN
	SETB KEY1_FLG
EXT_SCAN:
RET
//*******************************LEDӦ�ó���********************************/
//	@��������LED_APP
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************/
LED_APP:
	MOV A,CHANNEL
	CJNE A,#1,NXT_LED
	CPL LED1
	SJMP EXT_LED
NXT_LED:
	CPL LED2
EXT_LED:
RET
//*******************************PCA0�����ӳ���********************************/
//	@��������PCA0_Trig_APP
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************/
PCA0_Trig_APP:
	JB STATEA,STOP_PCA0
	SETB STATEA
	JB POT_POS,POS1
	MOV CL,#9CH
	MOV CH,#0FFH
	SETB CR
	SJMP EXT_PCA0_Trig_APP
POS1:
	MOV CL,#18H
	MOV CH,#0FCH
	SETB CR
	SJMP EXT_PCA0_Trig_APP
STOP_PCA0:
	CLR CR
	CLR STATEA
EXT_PCA0_Trig_APP:	
RET
//*******************************PCA1�����ӳ���********************************/
//	@��������PCA1_Trig_APP
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************/
PCA1_Trig_APP:
	JB STATEB,STOP_PCA1
	SETB STATEB
	JB POT_POS,POS2
	MOV TL1,#9CH
	MOV TH1,#0FFH
	SETB TR1
	SJMP EXT_PCA1_Trig_APP
POS2:
	MOV TL1,#18H
	MOV TH1,#0FCH
	SETB TR1
	SJMP EXT_PCA1_Trig_APP
STOP_PCA1:
	CLR TR1
	CLR STATEB
EXT_PCA1_Trig_APP:	
RET
//*******************************PCA0Ӧ�ó���********************************/
//	@��������PCA0_APP
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************/
PCA0_APP:
	JB POT_POS,SW
	MOV R0,#NUM_BF1+2
	MOV CL,#9CH
	MOV CH,#0FFH
	INC @R0
	CJNE @R0,#100,EXT_PCA0_APP
	MOV @R0,#0
	DEC R0
	INC @R0
	CJNE @R0,#100,EXT_PCA0_APP
	MOV @R0,#0
	DEC R0
	INC @R0
	CJNE @R0,#10,EXT_PCA0_APP
	MOV @R0,#10
	SETB POT_POS 
	SJMP EXT_PCA0_APP
SW:
	MOV R0,#NUM_BF1+2
	MOV CL,#18H
	MOV CH,#0FCH
	INC @R0
	CJNE @R0,#100,EXT_PCA0_APP
	MOV @R0,#0
	DEC R0
	INC @R0
	CJNE @R0,#10,EXT_PCA0_APP
	MOV @R0,#0
	DEC R0
	INC @R0
	CJNE @R0,#100,EXT_PCA0_APP
	MOV @R0,#0
EXT_PCA0_APP:
RET
//*******************************PCA1Ӧ�ó���********************************/
//	@��������PCA1_APP
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************/
PCA1_APP:
	JB POT_POS,SW1
	MOV R1,#NUM_BF2+2
	MOV TL1,#9CH
	MOV TH1,#0FFH
	INC @R1
	CJNE @R1,#100,EXT_PCA1_APP
	MOV @R1,#0
	DEC R1
	INC @R1
	CJNE @R1,#100,EXT_PCA1_APP
	MOV @R1,#0
	DEC R1
	INC @R1
	CJNE @R1,#10,EXT_PCA1_APP
	MOV @R1,#10
	SETB POT_POS 
	SJMP EXT_PCA1_APP
SW1:
	MOV R1,#NUM_BF1+2
	MOV TL1,#18H
	MOV TH1,#0FCH
	INC @R1
	CJNE @R1,#100,EXT_PCA1_APP
	MOV @R1,#0
	DEC R1
	INC @R1
	CJNE @R0,#10,EXT_PCA1_APP
	MOV @R1,#0
	DEC R1
	INC @R1
	CJNE @R1,#100,EXT_PCA1_APP
	MOV @R1,#0
EXT_PCA1_APP:
RET
//*********************************ISR**************************************//

//*****************************��ʱ��0�ж�**********************************//
//	@��������TIMER1
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//**************************************************************************//
TIMER0:
	PUSH PSW
    PUSH ACC
	CLR  RS1
	SETB RS0
	;========================
	ACALL LED_APP
	ACALL KEYSCAN
	;========================
EXT_T0:
    POP ACC
	POP PSW
RETI
//*****************************��ʱ��1�ж�**********************************//
//	@��������TIMER1
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//**************************************************************************//
TIMER1:
	PUSH PSW
    PUSH ACC
	SETB RS1
	SETB RS0
	;========================
	ACALL PCA1_APP
	;========================
EXT_T1:
    POP ACC
    POP PSW
RETI
//*****************************PCA_ISR**********************************//
//	@��������PCA_ISR
//	@��ڲ���:��
//	@���أ���
//	@���ڣ�2016-11-13
//	@���ߣ�Chen	
//************************************************************************//
PCA_ISR:
	PUSH PSW
    PUSH ACC
	CLR  RS1
	SETB RS0
	;========================
	JNB CCON.0,NXT1_PCA;PCA0�ж�����
	CLR CCON.0
	LCALL PCA0_Trig_APP
	SJMP EXT_PCA
NXT1_PCA:
	JNB CCON.1,NXT2_PCA;PCA1�ж�
	CLR CCON.1
	LCALL PCA1_Trig_APP
	SJMP EXT_PCA
NXT2_PCA:
	JNB CCON.7,NXT2_PCA;PCA����ж�
	CLR CCON.7;PCA����ж�λ�������
	LCALL PCA0_APP
	;========================
EXT_PCA:
    POP ACC
    POP PSW
RETI
//***********************************END************************************//
END