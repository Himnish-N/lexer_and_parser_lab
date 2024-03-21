%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(char *);

%}

/* Token declarations, ensure these match with your lexer */
%token INT CHAR FLOAT DOUBLE WHILE FOR DO IF ELSE INCLUDE MAIN ID NUM STRLITERAL HEADER
%token EQCOMP GREATEREQ LESSEREQ NOTEQ INC DEC ANDAND OROR
%token '(' ')' '{' '}' '[' ']' ';' ','

/* Operator precedence */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%left '+' '-'
%left '*' '/'
%left EQCOMP NOTEQ
%left '<' '>' GREATEREQ LESSEREQ
%left ANDAND OROR

%start program

%%

/* Grammar rules */

type
    : INT    { /* Action for INT type, if any */ }
    | CHAR   { /* Action for CHAR type, if any */ }
    | FLOAT  { /* Action for FLOAT type, if any */ }
    | DOUBLE { /* Action for DOUBLE type, if any */ }
    ;

program
    : /* empty */
    | program statement
    ;

statement
    : include_statement
    | main_function
    | declaration ';'
    | assignment ';'
    | if_statement
    | while_loop
    | block
    ;

include_statement
    : INCLUDE '<' HEADER '>'
    ;

main_function
    : type MAIN '(' ')' '{' statements '}'
    ;

declaration
    : type variable_list
    ;

variable_list
    : ID
    | variable_list ',' ID
    ;

assignment
    : ID '=' expression
    ;

expression
    : expression relop expression
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | '(' expression ')'
    | ID
    | NUM
    ;

relop
    : '<'
    | '>'
    | EQCOMP
    | NOTEQ
    | LESSEREQ
    | GREATEREQ
    ;

if_statement
    : IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

while_loop
    : WHILE '(' expression ')' statement
    ;

block
    : '{' statements '}'
    ;

statements
    : /* empty */
    | statements statement
    ;

%%

/* Main function */
int main() {
    printf("Parsing begins...\n");
    return yyparse();
}

/* Error handling function */
void yyerror(char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int yywrap(void){
    return 1;}
