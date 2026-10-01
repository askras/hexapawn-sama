DOCS := cards guide examples field rules rating
OUT := build
PDF := $(patsubst %,$(OUT)/%.pdf,$(DOCS))

# Вспомогательные файлы сборки. Список один и тот же для промежуточной
# уборки после каждого документа и для clean — иначе эти две строки
# со временем разойдутся. Держим его вровень с .gitignore.
#
# Состав проверен на трёх способах сборки:
#   xelatex               aux, log, out
#   xelatex -synctex=1    плюс synctex.gz (так запускают редакторы)
#   latexmk -xelatex      плюс fls, fdb_latexmk, xdv
# Последние пять make сам не создаёт, но их оставляет сборка из редактора,
# и без них clean не вернул бы каталог src в исходное состояние.
# toc в списке про запас: ни один документ сейчас не вызывает
# \tableofcontents, но если добавит, clean уже будет его знать.
AUX := aux log out toc synctex.gz fls fdb_latexmk xdv

# Уборка нужна в двух местах. make всегда собирает через cd src, поэтому сам
# он мусор в корне не оставляет — но xelatex, запущенный из корня (то есть
# как xelatex src/examples.tex), пишет *.log рядом с Makefile, минуя src/.
# Такая сборка всё равно падает на \input{board.tex}, однако лог успевает
# остаться. Поэтому чистим оба каталога, чтобы clean всегда возвращал
# проект в исходное состояние.
JUNK := $(addprefix src/*.,$(AUX)) $(addprefix *,$(AUX))

# Промежуточные PDF в src/ — из них make копирует готовые в build/, а
# редакторная сборка (latexmk) кладёт их туда же напрямую. В .gitignore они
# помечены как промежуточные, поэтому clean обязан их убирать — иначе после
# clean в src/ остаются шесть PDF, и исходное состояние не восстановилось.
# Их нельзя вернуть в JUNK: make нужен src/*.pdf на время cp, а уборка
# в правиле идёт после копирования, так что порядок не мешает.
JUNK += src/*.pdf

all: $(PDF)

$(OUT)/%.pdf: src/%.tex
	cd src && xelatex -interaction=nonstopmode $(<F) >/dev/null 2>&1
	cd src && xelatex -interaction=nonstopmode $(<F) >/dev/null 2>&1
	mkdir -p $(@D)
	cp src/$(basename $(<F)).pdf $(@D)/
	rm -f $(JUNK)

clean:
	rm -rf $(OUT)
	rm -f $(JUNK)

.PHONY: all clean
