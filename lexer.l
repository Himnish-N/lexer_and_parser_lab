%{
#include "y.tab.h"
#include<stdio.h>
extern int yylineno; 
extern  void yyerror(const char*);

%}

digit [0-9]
letter [a-zA-z]
id ({letter}|_)({letter}|{digit}|_)*
digits {digit}+
opFraction (\.{digits})?
opExponent ([Ee][-+]?{digits})?
number {digits}{opFraction}{opExponent}


%%
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[\f\r\t ]                 { ; }
\n                    {yylineno++;}
int                  { return TOKEN_INT; }
char                 { return TOKEN_CHAR; }
float                { return TOKEN_FLOAT; }
double               { return TOKEN_DOUBLE; }
void                 { return TOKEN_VOID; }
if                   { return TOKEN_IF; }
else                 { return TOKEN_ELSE; }
do                   { return TOKEN_DO; }
while                { return TOKEN_WHILE; }
for                  { return TOKEN_FOR; }
switch               { return TOKEN_SWITCH; }
case                 { return TOKEN_CASE; }
break                { return TOKEN_BREAK; }
main                 { return TOKEN_MAIN;}   
default              { return TOKEN_DEFAULT; }
#include             { return TOKEN_INCLUDE; }
\".*\"               { return TOKEN_STR_LITERAL;}
"++"                 { return TOKEN_INC; }
"--"                 { return TOKEN_DEC; }
"=="                 { return TOKEN_EQ; }
"!="                 { return TOKEN_NE; }
"<="                 { return TOKEN_LE; }
">="                 { return TOKEN_GE; }
"&&"                 { return TOKEN_AND; }
"||"                 { return TOKEN_OR; }
"="                  { return *yytext; }
"."                  { return *yytext; }
","                  { return *yytext; }
";"                  { return *yytext; }
":"                  { return *yytext; }
"("                  { return *yytext; }
")"                  { return *yytext; }
"{"                  { return *yytext; }
"}"                  { return *yytext; }
"["                  { return *yytext; }
"]"                  { return *yytext; }
"*"                  { return *yytext; }
"\'"                 { return *yytext; }
"+"                  { return *yytext; }
"-"                  { return *yytext; }
"/"                  { return *yytext; }
">"                  { return *yytext; }
"<"                  { return *yytext; }
"!"                  { return *yytext; }
\'.\'                { return TOKEN_CHAR_LITERAL;}
{number}             { return TOKEN_NUM;}
{id}\.h              { return TOKEN_HEADER;}
{id}                 { return TOKEN_ID;}
.                   { yyerror("Invalid character:"); }
%%


int yywrap()
{
    return 1;
}
