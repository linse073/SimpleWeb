OUTPUT_DIR = ../../lib
PLATFORM = $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifeq ($(PLATFORM), Darwin)
SHARED = -fPIC
CFLAGS = -O0 -Wall -pedantic -DNDEBUG
BUNDLE = -bundle -undefined dynamic_lookup
else
SHARED = -fPIC --shared
CFLAGS = -g -O0 -Wall
endif

INCLUDE += -I../../skynet/3rd/lua
TARGET = $(OUTPUT_DIR)/$(LIBS)
# Need OBJS LIBS

.PHONY: all clean

.c.o:
	$(CC) -c $(SHARED) $(CFLAGS) $(INCLUDE) $(BUILD_CFLAGS) -o $@ $<

.cpp.o:
	g++ -c $(SHARED) $(CFLAGS) $(INCLUDE) $(BUILD_CFLAGS) -std=c++17 -o $@ $<

all: $(TARGET)

$(TARGET): $(OBJS)
ifeq ($(PLATFORM), Darwin)
	g++ $(LDFLAGS) $(BUNDLE) -std=c++17 $^ -o $@
else
	g++ $(CFLAGS) $(INCLUDE) $(SHARED) -std=c++17 $^ -o $@
endif

clean:
	rm -f $(OBJS)
