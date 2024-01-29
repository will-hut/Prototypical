DEPENDENCIES := -lpthread
CFLAGS = -Wall -Wextra -O3

# Platform detection ================================================================
UNAME := $(shell uname)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME), Darwin)
    # mac
    DEPENDENCIES += -lobjc -framework IOKit -framework CoreFoundation
else
    # linux
    DEPENDENCIES += -lrt
    ifeq ($(UNAME_M), aarch64)
        # armv8 (aarch64)
        LIBS = static/libftd2xx_linux_armv8.a
    else ifeq ($(UNAME_M), x86_64)
        # x86 64bit
        LIBS = static/libftd2xx_linux_x64.a
    else
        # unknown, just assume x86 64bit
        LIBS = static/libftd2xx_linux_x64.a
    endif
endif
# ===================================================================================

APP = sender


all: $(APP)

$(APP): main.c
	$(CC) main.c -o $(APP) $(LIBS) $(CFLAGS) $(DEPENDENCIES)
	
clean:
	-rm -f *.o ; rm $(APP);
