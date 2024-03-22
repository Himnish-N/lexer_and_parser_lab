%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    int yylex();
    extern char *yytext;
    extern int yylineno;
    void yyerror(const char *);
    void skipTokens(int token);

    int error_flag = 0; 

%}

%token TOKEN_INT TOKEN_CHAR TOKEN_FLOAT TOKEN_DOUBLE TOKEN_VOID TOKEN_IF TOKEN_ELSE TOKEN_DO TOKEN_WHILE TOKEN_FOR TOKEN_SWITCH TOKEN_CASE TOKEN_BREAK TOKEN_MAIN TOKEN_DEFAULT TOKEN_INCLUDE TOKEN_STR_LITERAL TOKEN_INC TOKEN_DEC TOKEN_EQ TOKEN_NE TOKEN_LE TOKEN_GE TOKEN_AND TOKEN_OR TOKEN_NUM TOKEN_HEADER TOKEN_ID TOKEN_CHAR_LITERAL

%start START

%%

START : PROG;

PROG : TOKEN_INCLUDE '<' TOKEN_HEADER '>' PROG 
        | MAIN PROG
        | DECLR ';' PROG
        | ASSGN ';' PROG
        | error ';'
        |;

DECLR : TYPE LIST_VAR;

LIST_VAR : LIST_VAR ',' LIST_VAR2
        | LIST_VAR2;

LIST_VAR2 : ASSGN
        | ARRAY_DECL
        | TOKEN_ID;

ARRAY_DECL : TOKEN_ID DIMENSIONS  ;

DIMENSIONS : '[' TOKEN_NUM ']' DIMENSIONS | '[' TOKEN_NUM ']' ;

TYPE : TOKEN_INT 
        | TOKEN_FLOAT
        | TOKEN_CHAR
        | TOKEN_DOUBLE
        | TOKEN_VOID;

ASSGN : TOKEN_ID '=' EXPR ;

POSTFIX : TOKEN_INC | TOKEN_DEC ;

EXPR : EXPR RELOP E | E;

RELOP : '<' | '>' | TOKEN_EQ | TOKEN_GE | TOKEN_NE | TOKEN_LE | TOKEN_AND | TOKEN_OR ;

E : E '+' T
        | E '-' T
        | T ;

T : T '*' F
        | T '/' F
        | F ;

F : '(' EXPR ')' | POSTFIX TOKEN_ID | TOKEN_ID POSTFIX | TOKEN_NUM | TOKEN_CHAR_LITERAL | TOKEN_ID | '!'TOKEN_ID ;

MAIN : TYPE TOKEN_MAIN '(' EMPTY_LISTVAR ')' '{' STMT '}';

EMPTY_LISTVAR : LIST_VAR |  ;

STMT : SINGLE_STMT STMT 
        | BLOCK STMT 
        | ;

SINGLE_STMT : DECLR   ';'
        | ASSGN ';'
        | EXPR ';'
        | TOKEN_IF COND STMT ELSE
        | WHILE 
        | FORLOOP
        | SWITCH
        | DO;

ELSE : TOKEN_ELSE STMT | ;

DO : TOKEN_DO BLOCK TOKEN_WHILE '(' COND ')' ';';

SWITCH : TOKEN_SWITCH '(' EXPR ')' '{' CASES '}' ;

CASES : CASE CASES 
        | DEFAULT ;
        
CASE : TOKEN_CASE TOKEN_NUM ':' STMT  BREAK ;

BREAK : TOKEN_BREAK ';' | ;

DEFAULT : TOKEN_DEFAULT ':' STMT BREAK ;

BLOCK : '{' STMT '}' ;

WHILE : TOKEN_WHILE '(' COND ')' WHILE_2 ;

WHILE_2 : '{' STMT '}' | SINGLE_STMT |;

COND : EXPR ;

FORLOOP : TOKEN_FOR '(' FOR_INIT ';' FOR_COND ';' FOR_UPDATE ')' WHILE_2 ;

FOR_INIT : DECLR    
        | EMPTY_LISTVAR ;

FOR_COND : COND  ;

FOR_UPDATE : FOR_UPDATE ',' EXPR | EXPR |  ;





%%

void yyerror(const char *s){
    fflush(stdout);
    fprintf(stderr, "Error at line %d: %s @token %s\n", yylineno, s, yytext); // Print line number
    error_flag = 1; // Set syntax error flag
   skipTokens(';'); // Skip tokens until reaching a point where parsing can resume
}

void skipTokens(int token) {
    int next_token;
    do {
        next_token = yylex();
    } while (next_token != 0 && next_token != token);
    if (next_token!=0){
        yyparse();
    }
}

int main() {
    yylineno = 1; // Initialize yylineno
    yyparse();
    if (!error_flag) {
        printf("Valid Syntax\n");
    }
    return 0;
}