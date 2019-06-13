%{
#include <stdlib.h>
#include <string.h>
#include "def.tab.hh"
extern int yylineno;
int yyerror(const char *msg,...);
%}
%%
\<			{return '<';}
\>			{return '>';}
\=			{return '=';}
\+			{return '+';} 
\-			{return '-';}
\*			{return '*';}
\/			{return '/';}
\(			{return '(';}
\)			{return ')';}
\[			{return '[';}
\]			{return ']';}
\{			{return '{';}
\}			{return '}';}
\;			{yylineno++;return ';';}
\n			{;}
\ |\t			{;}
\<\=			{return LEQ;}
\>\=			{return GEQ;}
\=\=		{return EQ;}
\!\=		{return NEQ;}
"START"     {return    START;}
"INTEGER"   {fprintf(yyout, "int\n"); return    INTEGER;}
"DOUBLE"    {fprintf(yyout, "double\n");return    DOUBLE;}
"IF"        {return    IF;}
"SHOW"      {return    SHOW;}
"READ"		{return    READ;}
"WHILE"	 	{return    WHILE;}
"END"		{return    END;}
"ARRAY"		{return    ARRAY;}
"DARRAY"	{return    DARRAY;}
"END."		{return    ENDD;} 
[_a-zA-Z][_a-zA-Z0-9]*	{yylval.text = strdup(yytext);return  ID;}
[1-9][0-9]*|0 			{yylval.ival = atoi(yytext);return  LC;}
(0|[1-9][0-9]*)\.[0-9]+ 	{yylval.dval = atof(yytext);return  LP;}
. 				{return    yyerror("error, nie ma takiego leksemu\n");}
%%
int yyerror(const char *msg,...)
{
	printf("%d: %s", yylineno, msg);
	exit(1);
}


