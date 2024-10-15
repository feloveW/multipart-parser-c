CFLAGS?=-std=gnu99 -O4 -Wall -fPIC

default: multipart.so

multipart_parser.o: multipart_parser.c multipart_parser.h
lua-multipart-parser.o : lua-multipart-parser.c

multipart.so: lua-multipart-parser.o multipart_parser.o
	$(CC) -shared $^ -o multipart.so

clean:
	rm -f *.o *.so
