%{
#include "y.tab.h"
#include <stdio.h>

%}

digit       [0-9]
letter      [a-zA-Z]

%%


"int"                    { return INT; }
"char"                   { return CHAR; }
"float"                  { return FLOAT; }
"double"                 { return DOUBLE; }
"while"                  { return WHILE; }
"for"                    { return FOR; }
"do"                     { return DO; }
"if"                     { return IF; }
"else"                   { return ELSE; }
"include"                { return INCLUDE; }
"main"                   { return MAIN; }


{letter}({letter}|{digit})*  { return ID; }
{digit}+                     { return NUM; }


\"[^"\n]*\"              { return STRLITERAL; }
"\<"[^>\n]+">"            { return HEADER; }



"=="                     { return EQCOMP; }
">="                     { return GREATEREQ; }
"<="                     { return LESSEREQ; }
"!="                     { return NOTEQ; }
"++"                     { return INC; }
"--"                     { return DEC; }
"||"                     { return OROR; }
"&&"                     { return ANDAND; }
"!"                      { return '!'; }
"("                      { return '('; }
")"                      { return ')'; }
"["                      { return '['; }
"]"                      { return ']'; }
"{"                      { return '{'; }
"}"                      { return '}'; }
";"                      { return ';'; }
","                      { return ','; }
"+"                      { return '+'; }
"-"                      { return '-'; }
"*"                      { return '*'; }
"/"                      { return '/'; }
"<"                      { return '<'; }
">"                      { return '>'; }
"="                      { return '='; }

[ \t\r\n]+               ; 

%%
