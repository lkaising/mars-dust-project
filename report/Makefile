.DEFAULT_GOAL := all
LATEXMK ?= latexmk

.PHONY: all watch verify figures clean cleanall help

all:
	$(LATEXMK) -halt-on-error report.tex

watch:
	$(LATEXMK) -halt-on-error -pvc -view=none report.tex

verify: all
	@test -s build/report.pdf
	@if grep -E 'LaTeX Warning: (There were undefined references|Citation .* undefined|Reference .* undefined)|Missing character:|Overfull \\[hv]box|Please \(re\)run Biber' build/report.log; then \
		echo "Unresolved typesetting issues in build/report.log"; exit 1; \
	fi
	pdfinfo build/report.pdf
	pdffonts build/report.pdf

figures:
	@test -f ../output/variable_seasons/climate_record.pdf
	@test -f ../output/baseline/storm_switch.pdf
	@test -f ../output/recharge_sweep/recharge_sweep.pdf
	cp ../output/variable_seasons/climate_record.pdf figures/climate_record.pdf
	cp ../output/baseline/storm_switch.pdf figures/storm_switch.pdf
	cp ../output/recharge_sweep/recharge_sweep.pdf figures/recharge_sweep.pdf

clean:
	$(LATEXMK) -c report.tex

cleanall:
	$(LATEXMK) -C report.tex

help:
	@echo "make          Build build/report.pdf"
	@echo "make watch    Rebuild on save; Ctrl+C stops the watcher"
	@echo "make verify   Build, check log, and inspect PDF metadata/fonts"
	@echo "make figures  Refresh local copies of the three MATLAB PDFs"
	@echo "make clean    Remove auxiliary files; keep the PDF"
	@echo "make cleanall Remove generated files, including the PDF"
