CODEGEN:=../wuppercodegen/cli.py

TEST_FILES:= \
	output/warning.txt \
	output/simple.txt \
	output/function.txt \
	output/ref.txt \
	output/group.txt \
	output/attribute.txt \
	output/bitfield.txt \
	output/in_group.txt \
	output/lookup_group.txt \
	output/has_write_bitfields.txt \
	output/sequence1.txt \
	output/sequence2.txt \
	output/sequence3.txt \
	output/sequence4.txt \
	output/tree.txt \
	output/doc.txt

ERROR_FILES:= \
	output/bitfield-order.err \
	output/bitfield-range.err \
	output/syntax.err

.PHONY: clean doc

all: test errors

test: ${TEST_FILES} output/diff.html output/diff-bitfields.html

errors: ${ERROR_FILES}

clean:
	rm -rf output/*

output/%.txt : ${CODEGEN} input/%.yaml input/%.txt.template
	@mkdir -p output
	./$^ $@
	@diff $@ ref

output/%.err : ${CODEGEN} input/%.yaml input/%.err.template
	@mkdir -p output
	-./$^ $@ 2>&1 > $@
	@diff $@ ref

output/diff.html : ${CODEGEN} input/diff-ref.yaml input/diff.yaml input/diff.html.template
	@mkdir -p output
	./${CODEGEN} --diff input/diff-ref.yaml input/diff.yaml input/diff.html.template output/diff.html
	@diff $@ ref

output/diff-bitfields.html : ${CODEGEN} input/diff-bitfields-ref.yaml input/diff-bitfields.yaml input/diff.html.template
	@mkdir -p output
	./${CODEGEN} --diff input/diff-bitfields-ref.yaml input/diff-bitfields.yaml input/diff.html.template output/diff-bitfields.html
	@diff $@ ref
