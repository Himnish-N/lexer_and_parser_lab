a: y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c -ll -o a

y.tab.c: parser.y
	bison -dy parser.y 

lex.yy.c: lexer.l y.tab.h
	lex lexer.l

clean:
	rm -f a y.tab.c y.tab.h lex.yy.c
