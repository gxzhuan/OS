%include "boot.inc"
;主引导程序
SECTION MBR vstart=0x7c00
	mov ax, 0x0000	;设置栈指应该是程序一开始就应该做的事情,这个值是参照1m内存空间布局图选择的，以后会刻意避开
	mov ss, ax
	mov ax, 0x7c00
	mov sp, ax	
  mov ax, 0xb800  ;0xB8000~0xBFFFF这32k的内存用于文本模式的显示适配器
  mov gs, ax
 
;清屏利用0x06号功能，上卷全部行，则可以达到清屏的目的
;int 0x10 功能号: 0x06 功能描述：上卷全部行
;    AL : 上卷的行数，若为0，则表示全部
;    AH : 上卷行属性
;    (CL, CH) : 窗口左上角（X,Y）的位置
;    (DL, DH) : 窗口右下角（X,Y）的位置

	mov ax,0x0600
	mov bx,0x0700	;BH是设置缺省属性，属性是指背景色，前景色，是否闪烁等，例如07H表示黑底白字，70H表示灰底黑字等等。
	mov cx,0x0000 ;左上角：（0,0）
	mov dx,0x184f	;VGA文本模式中，一行只能显示80个字符,共25行
	              ;下标从0开始，0x18 = 24, 0x4f = 79,
								;即：DL = 79, DH = 24
	int 0x10      ;AX, BX, CX, DX设置完毕后就可以调用0x10号中断
	
;以下是利用显示适配器打印 Hello,world!的代码
  mov byte [gs:0x00], "M"
  mov byte [gs:0x01], 0xA4 ;A表示绿色背景，4表示前景色为红色
	
  mov byte [gs:0x02], "B"
  mov byte [gs:0x03], 0xA4 
	
  mov byte [gs:0x04], "R"
  mov byte [gs:0x05], 0xA4 
	
  mov byte [gs:0x06], "0"
  mov byte [gs:0x07], 0xA4 
	
  mov byte [gs:0x08], "0"
  mov byte [gs:0x09], 0xA4 
	
  mov byte [gs:0x0A], "0"
  mov byte [gs:0x0B], 0xA4 

	mov eax, LOADER_START_SECTOR    ;起始扇区lba地址
	mov bx,  LOADER_BASE_ADDR       ;写入地址
	mov cx,  1                      ;待读入的扇区数
	call rd_disk_m_16               ;以下读取程序的起始部分

	jmp LOADER_BASE_ADDR

rd_disk_m_16:
                  ;eax=LBA扇区号
                  ;bx=将数据写入的内存地址
                  ;cx=读入的扇区数
	mov esi, eax    ;备份eax
	mov di,  cx     ;备份cx
;读写硬盘：
;第一步：设置要读取的扇区数
	mov dx, 0x1f2
	mov al, cl
	out dx, al
	mov eax, esi    ;恢复ax

;第二步：将LBA地址存入0x1f3 ~ 0x1f6
	;LBA地址7~0位写入端口0x1f3
	mov dx, 0x1f3
	out dx, al

	;LBA地址15~8位写入端口0x1f4
	mov cl, 8
	shr eax, cl
	mov dx, 0x1f4
	out dx,al

	;LBA地址23~16位写入端口0x1f5
	shr eax, cl
	mov dx, 0x1f5
	out dx, al

	shr eax, cl
	and al,  0x0f   ;LBA第24~27位
	or  al, 0xe0    ;设置7~4位为1110，表示LBA模式
	mov dx, 0x1f6
	out dx, al

;第三步：向0x1f7端口写入读命令,0x20
	mov dx, 0x1f7
	mov al, 0x20
	out dx, al

;第四步：检测硬盘状态
	.not_ready:
		;同一端口，写时表示写入命令字，读时表示读取硬盘状态
		nop
		in al, dx
		and al, 0x88  ;第3位为1表示硬盘控制器已准备好数据传输
								  ;第7位为1表示硬盘忙
		cmp al, 0x08
		jnz .not_ready  ;若未准备好，则继续等

;第五步：从0x1f0端口读取数据
	mov ax, di
	mov dx, 256  ;di为要读取的扇区数，一个扇区有512个字节，每次
							 ;读取一个字，共需要256次
	mul dx
	mov cx, ax
	mov dx, 0x1f0
	.go_on_read:
		in ax, dx
		mov [bx], ax
		add bx, 2
		loop .go_on_read
		ret

;	jmp $
	times 510-($-$$) db 0
	db 0x55,0xaa
