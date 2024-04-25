#!/bin/bash

lex lexer.l
yacc -d parser.y -Wno
gcc -g y.tab.c lex.yy.c -ll

./a.out<test1.c>output1.txt
./a.out<test2.c>output2.txt
./a.out<test3.c>output3.txt
