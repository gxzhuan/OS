%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

;以下是利用显示适配器打印 Hello,world!的代码
  mov byte [gs:0x00], "H"
  mov byte [gs:0x01], 0xA4 ;A表示绿色背景，4表示前景色为红色
	
  mov byte [gs:0x02], "e"
  mov byte [gs:0x03], 0xA4 
	
  mov byte [gs:0x04], "l"
  mov byte [gs:0x05], 0xA4 
	
  mov byte [gs:0x06], "l"
  mov byte [gs:0x07], 0xA4 
	
  mov byte [gs:0x08], "o"
  mov byte [gs:0x09], 0xA4 
	
  mov byte [gs:0x0A], ","
  mov byte [gs:0x0B], 0xA4 
	
  mov byte [gs:0x0C], "w"
  mov byte [gs:0x0D], 0xA4 
	
  mov byte [gs:0x0E], "o"
  mov byte [gs:0x0F], 0xA4 
	
  mov byte [gs:0x10], "r"
  mov byte [gs:0x11], 0xA4 
	
  mov byte [gs:0x12], "l"
  mov byte [gs:0x13], 0xA4 
	
;  mov byte [gs:0x14], "d"
;  mov byte [gs:0x15], 0xA4 
	
  mov byte [gs:0x16], "!"
  mov byte [gs:0x17], 0xA4 
	
  jmp $