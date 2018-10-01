CC = gcc

ifndef HTSLIB_DIR
  $(error HTSLIB_DIR is undefined, see README.txt for details)
endif

all: ld

ld: ld.c
	$(CC) -Wall -O3 ld.c -I $(HTSLIB_DIR)/htslib -o ld -L$(HTSLIB_DIR) -Wl,-rpath,$(HTSLIB_DIR) -lhts

clean:
	\rm -f *.o  ld
