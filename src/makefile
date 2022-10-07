run: all
		sudo ./Timer

all: Timer

Timer: lcd_main.o
		ld lcd_main.o -o Timer

lcd_main.o: lcd_main.s
		as -c lcd_main.s -o lcd_main.o

clean:
		rm -rf *.o *~ Timer
