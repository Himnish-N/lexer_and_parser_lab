%{
	#include "Sym_table.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define YYSTYPE char*
	/*
		declare variables to help you keep track or store properties
		scope can be default value for this lab(implementation in the next lab)
	*/
	int type=-1;	//initial declaration of type for symbol table
	char* vval="~";	//initial declaration of value for symbol table
	int vtype=-1;	//initial declaration for type checking for symbol table
	int scope=0;	//initial declaration for scope
	void yyerror(char* s); // error handling function
	int yylex(); // declare the function performing lexical analysis
	extern int yylineno; // track the line number

%}

%token T_INT T_CHAR T_DOUBLE T_WHILE  T_INC T_DEC   T_OROR T_ANDAND T_EQCOMP T_NOTEQUAL T_GREATEREQ T_LESSEREQ T_LEFTSHIFT T_RIGHTSHIFT T_PRINTLN T_STRING  T_FLOAT T_BOOLEAN T_IF T_ELSE T_STRLITERAL T_DO T_INCLUDE T_HEADER T_MAIN T_ID T_NUM

%start START


%nonassoc T_IFX
%nonassoc T_ELSE

%%
START : PROG { printf("Valid syntax\n"); YYACCEPT; }	
        ;	
	  
PROG :  MAIN PROG				
	|DECLR ';' PROG 				
	| ASSGN ';' PROG 			
	| 					
	;
	 

DECLR : TYPE LISTVAR 
	;	


LISTVAR : LISTVAR ',' VAR 
	  | VAR
	  ;

VAR: T_ID '=' EXPR 	{
				/*
				    check if symbol is in the table
				    if it is then error for redeclared variable
				    else make entry and insert into table
				    insert value coming from EXPR
				    revert variables to default values:value,type
                   		 */
						 if(check_sym_tab($1))	//if variable is in table then variable is being re-declared
						{
							printf("Variable %s already declared\n",$1);
							yyerror($1);
						}
						else
						{
							insert_symbol($1,size(type),type,yylineno,scope);
							insert_val($1,vval,yylineno);
							vval="~";	//revert to default for checking
							type=-1;
						}
			}
     | T_ID 		{
				/*
                   			finished in lab 2
                    		*/
						if(check_sym_tab($1))	//if variable is in table then variable is being re-declared
						{
							printf("Variable %s already declared\n",$1);
							yyerror($1);
						}
						else{
							insert_symbol($1,size(type),type,yylineno,scope);
							type=-1;	//revert to default for checking
						}
			}	 

//assign type here to be returned to the declaration grammar
TYPE : T_INT {type = INT;}		//INT=2
       | T_FLOAT {type = FLOAT;}	//FLOAT=3
       | T_DOUBLE {type = DOUBLE;}	//DOUBLE=4
       | T_CHAR {type = CHAR;}		//CHAR=1
	   ;
    
/* Grammar for assignment */   
ASSGN : T_ID '=' EXPR 	{
			/*
               			 Check if variable is declared in the table
               			 insert value
            		*/
				if(!check_sym_tab($1))	//if variable not declared then value cannot be assigned
				{
					printf("Variable %s not declared\n",$1);
					yyerror($1);
				}
				else{
					if(vtype!=retrieve_type($1)){
						//printf("Mismatch Type\n");
						yyerror($3);
					}
					else
						insert_val($1,vval,yylineno);
					vval="~";		//to make sure previous values aren't inserted into other identifiers
					
					type = -1;
				}
			}
	;

EXPR : EXPR REL_OP E
       | E 	{vval=$1;}//store value using value variable declared before
       ;
	   
/* Expression Grammar */	   
E : E '+' T 	{ 
		/*
		        check type
		        if character type return error
		        convert to int/float perform calculation
		        convert back to string 
		        copy to grammar rule E
          	*/
			if(vtype==2)				//integer
				sprintf($$,"%d",(atoi($1)+atoi($3)));
			else if(vtype==3)			//float or double
				sprintf($$,"%lf",(atof($1)+atof($3)));
			else
			{
				printf("Character used in arithmetic\n");
				yyerror($$);
				$$="~";
			}
		}
    | E '-' T 	{ 
		/*
			check type
			if character type return error
			convert to int/float perform calculation
			convert back to string 
			copy to grammar rule E
            	*/
			if(vtype==2)				//integer
				sprintf($$,"%d",(atoi($1)-atoi($3)));
			else if(vtype==3)			//float or double
				sprintf($$,"%lf",(atof($1)-atof($3)));
			else
			{
				printf("Character used in arithmetic\n");
				yyerror($$);
				$$="~";
			}
		}
    | T {$$=$1;}//copy value from T to grammar rule E
    ;
	
	
T : T '*' F 	{ 
		/*
		        check type
		        if character type return error
		        convert to int/float perform calculation
		        convert back to string 
		        copy to grammar rule T
            	*/
			if(vtype==2)				//integer
				sprintf($$,"%d",(atoi($1)*atoi($3)));
			else if(vtype==3)			//float or double
				sprintf($$,"%lf",(atof($1)*atof($3)));
			else
			{
				printf("Character used in arithmetic\n");
				yyerror($$);
				$$="~";
			}
		}
    | T '/' F 	{ 
		/*
		        check type
		        if character type return error
		        convert to int/float perform calculation
		        convert back to string 
		        copy to grammar rule T
           	*/
			if(vtype==2)				//integer
				sprintf($$,"%d",(atoi($1)/atoi($3)));
			else if(vtype==3)			//float or double
				sprintf($$,"%lf",(atof($1)/atof($3)));
			else
			{
				printf("Character used in arithmetic\n");
				yyerror($$);
				$$="~";
			}
		}
    | F {$$=$1;}//copy value from F to grammar rule T
    ;

F : '(' EXPR ')'
    | T_ID 	{
		/*
		        check if variable is in table
		        check the value in the variable is default
		        if yes return error for variable not initialised
		        else duplicate value from T_STRLITERAL to F
		        check for type match
		        (secondary type variable used here)
            	*/
			if(check_sym_tab($1))		//check if variable is in symbol table
			{
				char* check=retrieve_val($1);
				if(check=="~")		//if variable has no value then can't be used for assignment
				{
					printf("Variable %s not initialised",$1);
					yyerror($1);
				}
				else
				{	
					$$=strdup(check);
					vtype=type_check(check);	
					if(vtype!=type && type!=-1)	//checks for matching type
					{
						//printf("Mismatch type\n");
						yyerror($1);
					}	
				}
			}
		}
    | T_NUM 	{
    		/*
		        duplicate value from T_NUM to F
		        check for type match
		        (secondary type variable used here)
                */
			$$=strdup($1); 
    		vtype=type_check($1);
    		if(vtype!=type && type!=-1)	//checks for matching type
			{
				//printf("Mismatch type\n");
				yyerror($1);
			}
			
		}
    | T_STRLITERAL {
            	/*
			duplicate value from T_STRLITERAL to F
			check for type match
			(secondary type variable used here)
            	*/
			$$=strdup($1); 
    		vtype=type_check($1);
    		if(vtype!=type && type!=-1)	//checks for matching type
			{
				//printf("Mismatch type\n");
				yyerror($1);
			}
		}
    ;



REL_OP :   T_LESSEREQ
	   | T_GREATEREQ
	   | '<' 
	   | '>' 
	   | T_EQCOMP
	   | T_NOTEQUAL
	   ;	


/* Grammar for main function */
//increment and decrement at particular points in the grammar to implement scope tracking
MAIN : TYPE T_MAIN '(' EMPTY_LISTVAR ')' '{' {scope++;}STMT '}'{scope--;};

EMPTY_LISTVAR : LISTVAR
		|	
		;

STMT : STMT_NO_BLOCK STMT
       | BLOCK STMT
       |
       ;


STMT_NO_BLOCK : DECLR ';'
       | ASSGN ';'
       | T_IF '(' COND ')' STMT %prec T_IFX	/* if loop*/
       | T_IF '(' COND ')' STMT T_ELSE STMT	/* if else loop */ 
       ;
       
//increment and decrement at particular points in the grammar to implement scope tracking
BLOCK : '{' {scope++;}STMT '}'{scope--;};

COND : EXPR 
       | ASSGN
       ;


%%


/* error handling function */
void yyerror(char* s)
{
	printf("Error :%s at %d \n",s,yylineno);
}


int main(int argc, char* argv[])
{
	/* initialise table here */
	t=init_table();
	yyparse();
	/* display final symbol table*/
	display_sym_tab();
	return 0;

}
