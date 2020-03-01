HTML_OUTPUT = docs
GETTEXT_OUTPUT = _build/gettext

.PHONY: all, en, tw, clean
en:
	sphinx-build . ${HTML_OUTPUT}/en

tw:
	sphinx-build -M gettext . ${GETTEXT_OUTPUT}
	sphinx-intl update -l zh_TW
	sphinx-build -Dlanguage=zh_TW . ${HTML_OUTPUT}/zh_TW

all:
	make en
	make tw

clean:
	rm -rf ${HTML_OUTPUT} ${GETTEXT_OUTPUT}
