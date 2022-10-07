run: all
		./Timer

all: Timer
 
Timer: lib.o Timer_v3_lib.o
		ld Timer_v3_lib.o lib.o -o Timer

lib.o: lib.s
		as -c lib.s -o lib.o
 
Timer_v3_lib.o: Timer_v3_lib.s
		as -c Timer_v3_lib.s -o Timer_v3_lib.o
 
clean:
		rm -rf *.o *~ Timer
