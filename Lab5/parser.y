%{
	
	#define YYSTYPE char*

	#include "icg.c"

	int yylex (void);
	void yyerror(const char *s);
	void skipTokens(int token);

	extern int yylineno;
	extern char *yytext;
	int err = 0;
	int temp_no = 1;
    int label_no = 1;

	FILE* icg_f;
%}

%start Start

%token WHILE DO IF ELSE
%token LESSER LESSEREQ GREATER GREATEREQ EQCOMP NOTEQ
%token ID NUM INTEGER

%%

Start: Prog { YYACCEPT; } ;

Prog: IfCond
    | DoWhlCond ;

IfCond: IF '(' Condition ')' '{' Body '}' {
        $2 = create_label();
        quad_gen("goto", " ", " ", $2);
        quad_gen("Label", " ", " ", $3);
    } ELSE '{' Body '}' {
        quad_gen("Label", " ", " ", $2);
      } ;

DoWhlCond: DO {
            $1 = create_label();
            quad_gen("Label", " ", " ", $1);
        } '{' Body '}' WHILE '(' DoWhlCondition ')' {
            $3 = create_label();  
            quad_gen("if", "t2", " ", $1);  
            quad_gen("goto", " ", " ", $1);
            quad_gen("Label", " ", " ", $3);
         } ;

Condition: F Relop F {
            $$ = create_temp();
            quad_gen($2, $1, $3, $$);
            
            $1 = create_label();
            quad_gen("ifFalse", $$, " ", $1);

            $$ = $1;
         } ;

DoWhlCondition: F Relop F {
                $$ = create_temp();
                quad_gen($2, $1, $3, $$);
              };

Relop: LESSER   { $$ = "<"; }
     | LESSEREQ { $$ = "<="; }
     | GREATER  { $$ = ">"; }
     | GREATEREQ{ $$ = ">="; }
     | EQCOMP   { $$ = "=="; }
     | NOTEQ    { $$ = "!="; } ;

Stmt: IfCond
    | DoWhlCond ';'
    | VarInit ';' ;

Body: Stmt Body
    | Stmt ;

VarInit: ID '=' E { quad_gen("=", $3, " ", $1); };

E: E '+' T {
 	$$ = create_temp();
	quad_gen("+", $1, $3, $$);
 }
 | E '-' T {
	$$ = create_temp();
	quad_gen("-", $1, $3, $$);
 }
 | T ;

T: T '*' F {
 	$$ = create_temp();
	quad_gen("*", $1, $3, $$);
}
 | T '/' F {
 	$$ = create_temp();
	quad_gen("/", $1, $3, $$);
}
 | F ;

F: '(' E ')' { $$ = $2; }
 | NUM
 | INTEGER
 | ID ;

%%

int main() {
	icg_f = fopen("output/icg.txt", "w");
	fclose(icg_f);

	yylineno = 1;
	if (!yyparse() && !err) {
		printf("Parsing successful\n");
	}
	else {
		printf("Parsing failed\n");
	}

	return 0;
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

void yyerror(const char *s) {
	fflush(stdout);
	err = 1;
	fprintf(stderr, "Error at line %d: %s\tToken: %s\n", yylineno, s, yytext);
	skipTokens(';'); 
}

