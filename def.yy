%{
#include <string>
#include <stdio.h>
#include <stack>
#include <iostream>
#include <map>
#include <vector>
#include <fstream>
#include <sstream>
using namespace std;
void writeRPN(char*);
void writeRPNx(char);
void writeTriple(string);
void createInteger(string id);
extern int yyerror(char *msg,...);
extern "C" int yylex();
extern "C" int yyerror(const char*msg,...);
vector<string> code;
vector<string> codef;
stack<string> stos;

struct zmienna {
string wartosc;
int iwartosc
int typ;
float fwartosc;

zmienna(string wartosc, int typ)
{
	this->wartosc = wartosc;
	this->typ = typ;
}
zmienna(int iwartosc, int typ)
{
	this->iwartosc = iwartosc;
	this->typ = typ;
}
zmienna(float fwartosc, int typ)
{
	this->fwartosc = fwartosc;
	this->typ = typ;
}
};

map <string,zmienna> symbols;
#define INT1 1
#define FLOAT2 2
#define STRING3 3
%}


%union 
{char *text;
int	ival;
double  dval;};
%token <text> ID 
%token <ival> LC
%token <dval> LP
%token START ENDD END
%token LEQ GEQ
%token INTEGER DOUBLE 
%token IF FI WHILE 
%token ARRAY DARRAY
%token SHOW NL
%%



wlinii
	:wlinii linia		{printf("wl\n");}
	|linia			{printf("l\n");}
	;

linia
	:przyp ';'	
	;

przyp
	:INTEGER ID '=' wyr {createInteger($2)}
	|ID '=' wyr		{writeRPN($1); stos.push($1); writeTriple("=");}
	;

wyr
	:wyr '+' skladnik	{writeRPNx('+'); writeTriple("+");}
	|wyr '-' skladnik	{writeRPNx('-'); writeTriple("-");}
	|skladnik		{ ;}
	;
skladnik
	:skladnik '*' czynnik	{writeRPNx('*'); writeTriple("*");}
	|skladnik '/' czynnik	{writeRPNx('/'); writeTriple("/");}
	|czynnik		{ ;}
	;
czynnik
	:ID			{writeRPN($1); stos.push($1); } 
	|LC			{char buff[512]; sprintf(buff,"%d",$1); writeRPN(buff);
                                 stos.push(std::to_string($1));}
	|LP			{char buff[512]; sprintf(buff,"%f",$1); writeRPN(buff); 
				stos.push(std::to_string($1));}
	|'(' wyr ')'		{ ;}
	;
%%


void writeRPN(char *znak)
{
    FILE *f = fopen("RPN.txt", "a");//musi istniec
    if (f == NULL)
    {
        perror("file RPN error");
        return ;
    }
    fprintf (f, "%s", znak);
    fclose(f);
}

void writeRPNx(char znak)
{
    FILE *f = fopen("RPN.txt", "a");//musi istniec
    if (f == NULL)
    {
        perror("file RPN error");
        return ;
    }
    fprintf (f, "%c", znak);
    fclose(f);
}

void writeTriple(string znak)
{
 string arc1;
 string arc2;
 stringstream stream;
 static int it = 0; 
 stream << "result" << it;
 it++;
 string result = stream.str();

 arc2 = stos.top();// asdf, dd, 67, 679, 7.9
 stos.pop();
 arc1 = stos.top();
 stos.pop();
 string type_of1 = isdigit(arc1[0]) ? "i" : "w";
 string type_of2 = isdigit(arc2[0]) ? "i" : "w";

 symbols[arc2] = INT1;
 symbols[arc1] = INT1;


 code.push_back("l" + type_of1 + " $t0 , "+ arc1);
	if(znak == "=")
	{
	cout<<arc1<<" "<<arc2<<endl;
	code.push_back("sw $t0 , "+arc2);
	}
	else
	{
	 	code.push_back("l" + type_of2 + " $t1 , "+ arc2);
		if(znak == "+")
			code.push_back("add $t0 , $t0 , $t1");
		else if(znak == "-")
			code.push_back("sub $t0 , $t0 , $t1");
		else if(znak == "*")
			code.push_back("mul $t0 , $t0 , $t1");
		else if(znak == "/")
			code.push_back("div $t0 , $t0 , $t1");
		else
	 		throw std::logic_error ("error operatora");
	
 		code.push_back("sw $t0 , "+result);
	}


code.push_back(" ");

// zapis do pliku
cout << "W: " << result << " = " << arc1 << " " << znak << " " << arc2 << endl;

fstream pFile("triplelog.txt", std::fstream::app);
pFile<<"W: "<< result << " = " << arc1 << " " << znak << " " << arc2<<endl;
pFile.close();

 stos.push(result);
}

void header()
{
	codef.push_back(".data");
	for (std::map<string,int>::iterator it=symbols.begin(); it!=symbols.end(); ++it)
	{
		stringstream tmp;
        	tmp << it->first << ":		.word	0";
		codef.push_back(tmp.str());
	}	
	codef.push_back("\n.text");

	for(auto line: code)
		codef.push_back("\t" + line);
	
}

void createInteger(string id)
{
	// dodaj nowy do mapy ( konstruktor struktury pod wskazane id(stos.top,)) typ na sztywno int
	// if stos.top().typ == 1
	// yyerror("you can`t put float into int \n");
}

int main(int argc, char *argv[])
{		

	//fstream pFile("triplelog.txt", std::fstream::out);
	//pFile.close();
	fstream pFile("code.asm", std::fstream::out);
	pFile.close();
	yyparse();
	header();	
	fstream codeFile("code.asm", std::fstream::out);
	
	for(auto line: codef)
		codeFile<<line<<endl;

	codeFile.close();
	return 0;
}


