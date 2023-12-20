#TOPDIR  := $(shell cd ..; pwd)
#include $(TOPDIR)/Rules.make

DEPENDENCIES := -lpthread
UNAME := $(shell uname)
# Assume target is Mac OS if build host is Mac OS; any other host targets Linux
ifeq ($(UNAME), Darwin)
	DEPENDENCIES += -lobjc -framework IOKit -framework CoreFoundation
else
	DEPENDENCIES += -lrt
endif

CFLAGS = -Wall -Wextra

APP = testapp


all: $(APP)

$(APP): main.c
	$(CC) main.c -o $(APP) /usr/local/lib/libftd2xx.a $(CFLAGS) $(DEPENDENCIES)
	
clean:
	-rm -f *.o ; rm $(APP);
