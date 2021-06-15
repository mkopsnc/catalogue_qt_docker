inputs	= $(wildcard *.mmd)
outputs	= $(patsubst %.mmd,%.png,$(inputs))

all: $(outputs)

%.png: %.mmd
	mmdc -i $< -o $@
