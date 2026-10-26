ASM = as
LINK = ld
SYSLIBROOT = "$(shell xcrun --sdk macosx --show-sdk-path)"
SRC = dgame.s termopts.s
TARGET = dgame
OBJ = dgame.o termopts.o

all: prin

prin: $(OBJ)
	ld \
	-e _start \
	-o dgame \
	-lSystem \
	-lc \
	-arch x86_64 \
	-syslibroot $(SYSLIBROOT) \
	-platform_version macos 26.7 25.0 \
	$(OBJ) \

	rm $(OBJ)

$(OBJ): $(SRC)
	as -g -o dgame.o dgame.s
	as -g -o termopts.o termopts.s
