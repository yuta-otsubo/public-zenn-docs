# -*- coding: utf-8 -*-
A :=

ARTICLE_NAME := ${A}-$(shell date +%Y%m%d)

T :=

TITLE := "${T}"

.PHONY: help
help:
	@echo "記事の新規作成"
	@echo 'make new A=article_name T="title"'
	@echo "--------------------------------------------------"
	@echo "記事のプレビューの表示してリンクからアクセス"
	@echo "make preview"

.PHONY: new
new:
	@npx zenn new:article --slug ${ARTICLE_NAME} --title ${TITLE} --type tech --emoji 🐔

.PHONY: preview
preview:
	@npx zenn preview

