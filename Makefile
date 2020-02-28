.PHONY: all, en, tw, clean
en:
	sphinx-build . _build/html/en

tw:
	sphinx-build -M gettext . _build
	sphinx-intl update -l zh_TW
	sphinx-build -Dlanguage=zh_TW . _build/html/zh_TW

all:
	sphinx-build . _build/html/en
	sphinx-build -M gettext . _build
	sphinx-intl update -l zh_TW
	sphinx-build -Dlanguage=zh_TW . _build/html/zh_TW

clean:
	rm -rf _build
