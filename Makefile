HTML_OUTPUT = docs
GETTEXT_OUTPUT = gettext

.PHONY: all, en, tw, lc, clean, clean_lc
en:
	sphinx-build . ${HTML_OUTPUT}/en

tw: 
	sphinx-build -Dlanguage=zh_TW . ${HTML_OUTPUT}/zh_TW

lc:
	sphinx-build -M gettext . ${GETTEXT_OUTPUT}
	sphinx-intl update -l zh_TW -p ${GETTEXT_OUTPUT}/gettext

all:
	make en
	make tw

clean:
	rm -rf ${HTML_OUTPUT}/en ${HTML_OUTPUT}/zh_TW

clean_lc:
	rm -rf locales ${GETTEXT_OUTPUT}
