.PHONY: clean

BINARY=tinyelfscarf

$(BINARY): $(BINARY).asm
	nasm -f bin -o $@ $<
	chmod +x $@

clean:
	rm $(BINARY)
