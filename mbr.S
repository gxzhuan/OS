;主引导程序
SECTION MBR vstart=0x7c00
	mov ax,0x0000	;设置栈指应该是程序一开始就应该做的事情,这个值是参照1m内存空间布局图选择的，以后会刻意避开
	mov ss,ax
	mov ax,0x7c00
	mov sp,ax	
 
;清屏利用0x06号功能，上卷全部行，则可以达到清屏的目的
;int 0x10 功能号: 0x06 功能描述：上卷全部行
;    AL : 上卷的行数，若为0，则表示全部
;    AH : 上卷行属性
;    (CL, CH) : 窗口左上角（X,Y）的位置
;    (DL, DH) : 窗口右下角（X,Y）的位置
;
;
;
	mov ax,0x0600
	mov bx,0x0700	;BH是设置缺省属性，属性是指背景色，前景色，是否闪烁等，例如07H表示黑底白字，70H表示灰底黑字等等。
	mov cx,0x0000 ;左上角：（0,0）
	mov dx,0x184f	;VGA文本模式中，一行只能显示80个字符,共25行
	              ;下标从0开始，0x18 = 24, 0x4f = 79,
								;即：DL = 79, DH = 24
	int 0x10      ;AX, BX, CX, DX设置完毕后就可以调用0x10号中断
	
;以下3行是获取光标的位置，在光标处打印字符，利用0x10号终端的3号子功能
	mov ax,0x0300	;3号子功能是获取光标的位置，AH = 0x03
	mov bx,0x0000	;BH寄存器存储的是待获取光标的页号，
	int 0x10      ;输出：CH=光标开始行，CH=光标结束行
                ;      DH=光标所在行号，DL=光标所在列号
	

;下面是打印字符串，利用0x10号中断的13号子功能
	mov ax,0x0000
	mov es,ax
	mov ax,message
	mov bp,ax
	mov ax,0x1301 ;13号子功能为打印字符串及其属性，存入AH中
                ;AL设置写字符串的方式，AL=0x01：显示字符串，光标跟随移动
	mov bx,0x0002	;BL是字符属性，02是黑底绿字，07是黑底白字
                ;BH存储要显示的页号，此处是第0页
	mov cx,0x0028 ;CX=字符串长度，不包括结束字符0
	int 0x10
	
	jmp $
	message db "Hello World!\nThis is the first program."
	times 510-($-$$) db 0
	db 0x55,0xaa
